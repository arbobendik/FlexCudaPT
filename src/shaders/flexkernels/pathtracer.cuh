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

struct SheenProfile
{
    bool on;
    float albedo;
};

static __device__ SheenProfile SheenProfile_x24init_0(bool on_0, float albedo_0)
{
    SheenProfile _S331;
    (&_S331)->on = on_0;
    (&_S331)->albedo = albedo_0;
    return _S331;
}

__device__ float rgb_to_greyscale(float3  rgb_0)
{
    return dot_0(rgb_0, make_float3 (0.29899999499320984f, 0.58700001239776611f, 0.11400000005960464f));
}

__device__ static const FixedArray<float, 576>  VELVET_ALBEDO_0 = { {
    1.00383996963500977f, 1.00428998470306396f, 1.00356996059417725f, 1.00303995609283447f, 1.00261998176574707f, 1.00229001045227051f, 1.00198996067047119f, 1.00171005725860596f, 1.00144004821777344f, 1.00120997428894043f, 1.00102996826171875f, 1.00092005729675293f, 1.00088000297546387f, 1.0009000301361084f, 1.00095999240875244f, 1.00106000900268555f, 1.00115001201629639f, 1.00124001502990723f, 1.001289963722229f, 1.0013200044631958f, 1.00133001804351807f, 1.00133001804351807f, 1.0013200044631958f, 1.00129997730255127f, 0.99086397886276245f, 0.9934689998626709f, 0.99439799785614014f, 0.99513500928878784f, 0.99574202299118042f, 0.9962649941444397f, 0.99671798944473267f, 0.99709898233413696f, 0.997406005859375f, 0.99764800071716309f, 0.99783498048782349f, 0.99798601865768433f, 0.99811899662017822f, 0.99825501441955566f, 0.99840497970581055f, 0.99857097864151001f, 0.99874699115753174f, 0.99892902374267578f, 0.9990919828414917f, 0.99923902750015259f, 0.99936902523040771f, 0.99948000907897949f, 0.99957501888275146f, 0.99965798854827881f, 0.94088798761367798f, 0.95128101110458374f, 0.95866602659225464f, 0.96450901031494141f, 0.96921002864837646f, 0.973052978515625f, 0.97623497247695923f, 0.97890102863311768f, 0.98115700483322144f, 0.98308497667312622f, 0.98474901914596558f, 0.98619699478149414f, 0.98746699094772339f, 0.98858797550201416f, 0.98958402872085571f, 0.99047297239303589f, 0.99127000570297241f, 0.99198299646377563f, 0.99262100458145142f, 0.99318897724151611f, 0.99372398853302002f, 0.99426800012588501f, 0.99475300312042236f, 0.99514400959014893f, 0.86131101846694946f, 0.88463401794433594f, 0.90212702751159668f, 0.91595500707626343f, 0.92708200216293335f, 0.93617302179336548f, 0.94370102882385254f, 0.95000702142715454f, 0.95534700155258179f, 0.9599120020866394f, 0.96384698152542114f, 0.96726799011230469f, 0.97026199102401733f, 0.97289901971817017f, 0.97523599863052368f, 0.97731602191925049f, 0.97917401790618896f, 0.98083901405334473f, 0.98233497142791748f, 0.98368102312088013f, 0.98489302396774292f, 0.98598498106002808f, 0.98697298765182495f, 0.98787301778793335f, 0.75306302309036255f, 0.79328000545501709f, 0.82418698072433472f, 0.84881901741027832f, 0.86874997615814209f, 0.88506197929382324f, 0.89858502149581909f, 0.9099239706993103f, 0.91952997446060181f, 0.9277459979057312f, 0.93483197689056396f, 0.94099199771881104f, 0.9463840126991272f, 0.95113497972488403f, 0.95534402132034302f, 0.95908999443054199f, 0.9624369740486145f, 0.96543699502944946f, 0.96813201904296875f, 0.97055697441101074f, 0.97274202108383179f, 0.97471201419830322f, 0.97649002075195312f, 0.97809398174285889f, 0.62183499336242676f, 0.68052101135253906f, 0.72705197334289551f, 0.76452702283859253f, 0.79505598545074463f, 0.82021200656890869f, 0.84120297431945801f, 0.85885602235794067f, 0.87384098768234253f, 0.88667500019073486f, 0.89775800704956055f, 0.90739899873733521f, 0.91584599018096924f, 0.92329102754592896f, 0.929889976978302f, 0.93576502799987793f, 0.94101500511169434f, 0.94572198390960693f, 0.94994997978210449f, 0.95375597476959229f, 0.95718497037887573f, 0.9602770209312439f, 0.96306699514389038f, 0.96558600664138794f, 0.47742500901222229f, 0.5522189736366272f, 0.61415499448776245f, 0.66520899534225464f, 0.70744901895523071f, 0.74262100458145142f, 0.77213901281356812f, 0.7971159815788269f, 0.81841897964477539f, 0.83673000335693359f, 0.85258400440216064f, 0.86640900373458862f, 0.87854301929473877f, 0.88924998044967651f, 0.89874798059463501f, 0.90721100568771362f, 0.91477799415588379f, 0.92156499624252319f, 0.92766499519348145f, 0.93315702676773071f, 0.9381060004234314f, 0.94257098436355591f, 0.94660097360610962f, 0.95023900270462036f, 0.33539599180221558f, 0.41908100247383118f, 0.49247598648071289f, 0.55531197786331177f, 0.60879099369049072f, 0.65415602922439575f, 0.69274699687957764f, 0.72571200132369995f, 0.75402498245239258f, 0.77849102020263672f, 0.79976201057434082f, 0.81836599111557007f, 0.83474302291870117f, 0.84922301769256592f, 0.86208897829055786f, 0.87356698513031006f, 0.88384199142456055f, 0.89306402206420898f, 0.90135800838470459f, 0.9088289737701416f, 0.91556602716445923f, 0.92164498567581177f, 0.92713397741317749f, 0.93208998441696167f, 0.21194499731063843f, 0.29365798830986023f, 0.37110498547554016f, 0.44143900275230408f, 0.5036969780921936f, 0.55801302194595337f, 0.60521197319030762f, 0.64614301919937134f, 0.68169897794723511f, 0.71268302202224731f, 0.73979401588439941f, 0.76362699270248413f, 0.78467601537704468f, 0.80335497856140137f, 0.82000100612640381f, 0.83488202095031738f, 0.8482239842414856f, 0.86021500825881958f, 0.87101101875305176f, 0.88074499368667603f, 0.88952797651290894f, 0.89745801687240601f, 0.90461999177932739f, 0.91109001636505127f, 0.11949499696493149f, 0.18745699524879456f, 0.25997200608253479f, 0.33120998740196228f, 0.39773499965667725f, 0.45832300186157227f, 0.51248997449874878f, 0.56048798561096191f, 0.6028980016708374f, 0.64032697677612305f, 0.67339599132537842f, 0.70268499851226807f, 0.72870397567749023f, 0.75189602375030518f, 0.77263599634170532f, 0.7912449836730957f, 0.80796998739242554f, 0.82303100824356079f, 0.8366129994392395f, 0.84887397289276123f, 0.85994899272918701f, 0.86995697021484375f, 0.87900298833847046f, 0.88717901706695557f, 0.05942929908633232f, 0.10839699953794479f, 0.16785700619220734f, 0.23236599564552307f, 0.29767501354217529f, 0.36022999882698059f, 0.41842898726463318f, 0.47170799970626831f, 0.5198180079460144f, 0.56301301717758179f, 0.60171198844909668f, 0.63635998964309692f, 0.66739702224731445f, 0.69524997472763062f, 0.720287024974823f, 0.74283498525619507f, 0.76317602396011353f, 0.78155702352523804f, 0.79817098379135132f, 0.81319701671600342f, 0.8267899751663208f, 0.83908802270889282f, 0.85021400451660156f, 0.86027902364730835f, 0.02584660053253174f, 0.05619670078158379f, 0.09917669743299484f, 0.15162299573421478f, 0.20941600203514099f, 0.26902499794960022f, 0.32757499814033508f, 0.38318398594856262f, 0.43501600623130798f, 0.48271399736404419f, 0.52620798349380493f, 0.56570100784301758f, 0.60149699449539185f, 0.63392102718353271f, 0.66328197717666626f, 0.68988502025604248f, 0.7139970064163208f, 0.7358660101890564f, 0.75570398569107056f, 0.77369099855422974f, 0.78999698162078857f, 0.80477499961853027f, 0.81816202402114868f, 0.83028298616409302f, 0.00968609005212784f, 0.02591750025749207f, 0.05318830162286758f, 0.09121809899806976f, 0.13777700066566467f, 0.18976299464702606f, 0.244159996509552f, 0.29880800843238831f, 0.35169300436973572f, 0.40180501341819763f, 0.44872200489044189f, 0.49213200807571411f, 0.53206497430801392f, 0.5686650276184082f, 0.60214298963546753f, 0.63272500038146973f, 0.66062301397323608f, 0.68605399131774902f, 0.70922297239303589f, 0.73031198978424072f, 0.74948400259017944f, 0.76689702272415161f, 0.78270000219345093f, 0.79702901840209961f, 0.00303822988644242f, 0.01048239972442389f, 0.02568300068378448f, 0.05025380104780197f, 0.08408640325069427f, 0.12561400234699249f, 0.17249999940395355f, 0.22232000529766083f, 0.27309399843215942f, 0.32321798801422119f, 0.37149098515510559f, 0.4173240065574646f, 0.4603630006313324f, 0.50043797492980957f, 0.53755801916122437f, 0.57181298732757568f, 0.60333001613616943f, 0.63226902484893799f, 0.65877401828765869f, 0.68301999568939209f, 0.70514601469039917f, 0.7253040075302124f, 0.74363899230957031f, 0.76029098033905029f, 0.00076204299693927f, 0.00361976004205644f, 0.0110037000849843f, 0.02512970007956028f, 0.04727460071444511f, 0.07745999842882156f, 0.11460299789905548f, 0.1569570004940033f, 0.20258499681949615f, 0.24971699714660645f, 0.29707801342010498f, 0.34340900182723999f, 0.38799500465393066f, 0.43043500185012817f, 0.47039699554443359f, 0.50777101516723633f, 0.54253697395324707f, 0.57473397254943848f, 0.60444700717926025f, 0.63179397583007812f, 0.65686798095703125f, 0.67979699373245239f, 0.70071202516555786f, 0.71974599361419678f, 0.00014345299859997f, 0.00102306995540857f, 0.00407376000657678f, 0.01122699957340956f, 0.02423799969255924f, 0.04415180161595345f, 0.07109060138463974f, 0.10433399677276611f, 0.14259399473667145f, 0.184347003698349f, 0.2281080037355423f, 0.27265200018882751f, 0.31696400046348572f, 0.36016398668289185f, 0.40178799629211426f, 0.44139501452445984f, 0.47875601053237915f, 0.51375597715377808f, 0.54635101556777954f, 0.57658302783966064f, 0.60447400808334351f, 0.63009101152420044f, 0.65352898836135864f, 0.67488902807235718f, 0.00001858420000644f, 0.0002227969962405f, 0.00124967005103827f, 0.00435766018927097f, 0.01113030035048723f, 0.0229835007339716f, 0.04079980030655861f, 0.06477940082550049f, 0.09447769820690155f, 0.12897300720214844f, 0.16708999872207642f, 0.20760199427604675f, 0.24936899542808533f, 0.29154899716377258f, 0.3332040011882782f, 0.37377101182937622f, 0.41274300217628479f, 0.44977998733520508f, 0.4846780002117157f, 0.51733100414276123f, 0.54769200086593628f, 0.57572799921035767f, 0.6014779806137085f, 0.62501102685928345f, 1.46482000218384201e-06f, 0.00003429050047998f, 0.0002985020109918f, 0.00140504003502429f, 0.00443577999249101f, 0.01069260016083717f, 0.02133879996836185f, 0.0371410995721817f, 0.05836030095815659f, 0.08476380258798599f, 0.11572299897670746f, 0.1503559947013855f, 0.18766500055789948f, 0.22665500640869141f, 0.26647698879241943f, 0.30632400512695312f, 0.34550899267196655f, 0.38344401121139526f, 0.41970700025558472f, 0.45401400327682495f, 0.48618701100349426f, 0.51614201068878174f, 0.54384201765060425f, 0.56930899620056152f, 5.83937982412408019e-08f, 3.2765999549155822e-06f, 0.00005055400106357f, 0.00035111699253321f, 0.00145683996379375f, 0.00427943980321288f, 0.0098936902359128f, 0.01927389949560165f, 0.03310279920697212f, 0.05168719962239265f, 0.07495570182800293f, 0.10250899940729141f, 0.13370099663734436f, 0.1677280068397522f, 0.20372100174427032f, 0.24084299802780151f, 0.27840098738670349f, 0.31564199924468994f, 0.35190799832344055f, 0.38674798607826233f, 0.41985601186752319f, 0.45104199647903442f, 0.48021000623703003f, 0.50734001398086548f, 8.73966010672688753e-10f, 1.57741993689342053e-07f, 5.21975016454234719e-06f, 0.00006079579907237f, 0.00036219600588083f, 0.00138045998755842f, 0.00386844994500279f, 0.00871635042130947f, 0.01675550080835819f, 0.02860799990594387f, 0.04461279883980751f, 0.06480839848518372f, 0.08895269781351089f, 0.11656700074672699f, 0.1470009982585907f, 0.17950700223445892f, 0.21331800520420074f, 0.24785000085830688f, 0.28237700462341309f, 0.31631898880004883f, 0.34923198819160461f, 0.38083100318908691f, 0.41094100475311279f, 0.43946701288223267f, 2.8866399288257627e-12f, 2.63671995348602195e-09f, 2.51094007808205788e-07f, 5.97520011069718748e-06f, 0.00005859580051037f, 0.0003192939911969f, 0.00116373994387686f, 0.00319523992948234f, 0.00714873988181353f, 0.0137449000030756f, 0.0235638003796339f, 0.03696820139884949f, 0.05407309904694557f, 0.0747511014342308f, 0.09866459667682648f, 0.12531900405883789f, 0.15412400662899017f, 0.18446199595928192f, 0.21573600172996521f, 0.24741099774837494f, 0.27903899550437927f, 0.310263991355896f, 0.34082499146461487f, 0.37054198980331421f, 6.94488983838260476e-16f, 7.04290011727115584e-12f, 3.21448001550095341e-09f, 2.20180993437679717e-07f, 4.50593006462440826e-06f, 0.00004154839916737f, 0.00022262999846134f, 0.00081575999502093f, 0.00227530999109149f, 0.00519366981461644f, 0.01020010001957417f, 0.0178545992821455f, 0.02856850065290928f, 0.04256030172109604f, 0.05984469875693321f, 0.08025020360946655f, 0.10345599800348282f, 0.12904399633407593f, 0.15654699504375458f, 0.1854960024356842f, 0.21545499563217163f, 0.24603499472141266f, 0.27690801024436951f, 0.3078019917011261f, 5.46278023199234311e-22f, 3.43167987041791307e-16f, 2.29294990113093622e-12f, 9.57796952860689998e-10f, 6.87986982939037262e-08f, 1.5533599935224629e-06f, 0.00001600819996384f, 0.00009555240103509f, 0.00038631301140413f, 0.00117554003372788f, 0.00289549003355205f, 0.00607588002458215f, 0.01126710046082735f, 0.01896269991993904f, 0.02954130060970783f, 0.04323289915919304f, 0.06011129915714264f, 0.0801049992442131f, 0.10301999747753143f, 0.12857000529766083f, 0.15640300512313843f, 0.18612800538539886f, 0.21734000742435455f, 0.24963200092315674f, 0.0f, 0.0f, 3.09890004335006815e-24f, 2.21276004416278673e-18f, 2.67358004631774657e-14f, 2.24439997836833882e-11f, 3.13075010360819306e-09f, 1.26480998119404831e-07f, 2.12951999856159091e-06f, 0.00001907769910758f, 0.00010753999958979f, 0.00042892698547803f, 0.00131604995112866f, 0.00330013991333544f, 0.00707077002152801f, 0.01337909977883101f, 0.02291939966380596f, 0.03622379899024963f, 0.05359359830617905f, 0.07507230341434479f, 0.10045900195837021f, 0.12935000658035278f, 0.16119599342346191f, 0.19536399841308594f
} };
__device__ static const FixedArray<float, 576>  SHEEN_ALBEDO_0 = { {
    0.62089997529983521f, 0.49450001120567322f, 0.38080000877380371f, 0.28439998626708984f, 0.20010000467300415f, 0.1257999986410141f, 0.05990000069141388f, 0.00109999999403954f, -0.05160000175237656f, -0.09889999777078629f, -0.14159999787807465f, -0.18009999394416809f, -0.2151000052690506f, -0.24690000712871552f, -0.27590000629425049f, -0.30230000615119934f, -0.32649999856948853f, -0.34860000014305115f, -0.36890000104904175f, -0.38760000467300415f, -0.40479999780654907f, -0.42070001363754272f, -0.43439999222755432f, -0.44929999113082886f, 0.59240001440048218f, 0.47049999237060547f, 0.35899999737739563f, 0.26440000534057617f, 0.18150000274181366f, 0.10830000042915344f, 0.04329999908804893f, -0.01470000017434359f, -0.066600002348423f, -0.11339999735355377f, -0.15549999475479126f, -0.19370000064373016f, -0.22820000350475311f, -0.25970000028610229f, -0.28830000758171082f, -0.31450000405311584f, -0.33840000629425049f, -0.36039999127388f, -0.38049998879432678f, -0.39899998903274536f, -0.41609999537467957f, -0.43180000782012939f, -0.44539999961853027f, -0.46070000529289246f, 0.5228000283241272f, 0.40599998831748962f, 0.30259999632835388f, 0.21250000596046448f, 0.13330000638961792f, 0.06319999694824219f, 0.00069999997504056f, -0.05510000139474869f, -0.10520000010728836f, -0.15039999783039093f, -0.19120000302791595f, -0.2281000018119812f, -0.26170000433921814f, -0.2921999990940094f, -0.31999999284744263f, -0.34549999237060547f, -0.36869999766349792f, -0.39010000228881836f, -0.40970000624656677f, -0.42770001292228699f, -0.44440001249313354f, -0.45969998836517334f, -0.47389999032020569f, -0.48800000548362732f, 0.43569999933242798f, 0.32769998908042908f, 0.23160000145435333f, 0.14730000495910645f, 0.07280000299215317f, 0.00659999996423721f, -0.05260000005364418f, -0.10559999942779541f, -0.1534000039100647f, -0.19650000333786011f, -0.23549999296665192f, -0.27090001106262207f, -0.30309998989105225f, -0.33239999413490295f, -0.35920000076293945f, -0.38359999656677246f, -0.40599998831748962f, -0.42660000920295715f, -0.44549998641014099f, -0.46290001273155212f, -0.47900000214576721f, -0.49380001425743103f, -0.50749999284744263f, -0.52090001106262207f, 0.33129999041557312f, 0.23459999263286591f, 0.14740000665187836f, 0.07010000199079514f, 0.00139999995008111f, -0.0601000003516674f, -0.11519999802112579f, -0.16490000486373901f, -0.20970000326633453f, -0.25029999017715454f, -0.28720000386238098f, -0.3206000030040741f, -0.35109999775886536f, -0.37900000810623169f, -0.40439999103546143f, -0.42770001292228699f, -0.44900000095367432f, -0.46869999170303345f, -0.48669999837875366f, -0.5033000111579895f, -0.5187000036239624f, -0.53289997577667236f, -0.54600000381469727f, -0.55860000848770142f, 0.21109999716281891f, 0.12790000438690186f, 0.0511000007390976f, -0.01769999973475933f, -0.07970000058412552f, -0.13549999892711639f, -0.18600000441074371f, -0.23160000145435333f, -0.27300000190734863f, -0.31069999933242798f, -0.34490001201629639f, -0.37619999051094055f, -0.40470001101493835f, -0.43070000410079956f, -0.4546000063419342f, -0.476500004529953f, -0.49660000205039978f, -0.51510000228881836f, -0.53210002183914185f, -0.54780000448226929f, -0.56230002641677856f, -0.57580000162124634f, -0.58819997310638428f, -0.60009998083114624f, 0.0754999965429306f, 0.00800000037997961f, -0.05649999901652336f, -0.11569999903440475f, -0.16979999840259552f, -0.21920000016689301f, -0.26420000195503235f, -0.3052000105381012f, -0.34270000457763672f, -0.37689998745918274f, -0.40819999575614929f, -0.43680000305175781f, -0.46299999952316284f, -0.48710000514984131f, -0.50910001993179321f, -0.52939999103546143f, -0.54809999465942383f, -0.56529998779296875f, -0.5810999870300293f, -0.59570002555847168f, -0.60930001735687256f, -0.6218000054359436f, -0.63340002298355103f, -0.6445000171661377f, -0.07569999992847443f, -0.12489999830722809f, -0.17569999396800995f, -0.22380000352859497f, -0.26890000700950623f, -0.3107999861240387f, -0.34959998726844788f, -0.38539999723434448f, -0.41839998960494995f, -0.44870001077651978f, -0.47659999132156372f, -0.50230002403259277f, -0.52590000629425049f, -0.54759997129440308f, -0.56760001182556152f, -0.58600002527236938f, -0.6029999852180481f, -0.61870002746582031f, -0.63330000638961792f, -0.64670002460479736f, -0.6590999960899353f, -0.67059999704360962f, -0.68129998445510864f, -0.69160002470016479f, -0.24320000410079956f, -0.27120000123977661f, -0.30640000104904175f, -0.34209999442100525f, -0.37700000405311584f, -0.41060000658035278f, -0.44229999184608459f, -0.47220000624656677f, -0.50010001659393311f, -0.52600002288818359f, -0.55010002851486206f, -0.57239997386932373f, -0.59310001134872437f, -0.61220002174377441f, -0.62989997863769531f, -0.64620000123977661f, -0.66140002012252808f, -0.6754000186920166f, -0.68839997053146362f, -0.70039999485015869f, -0.71160000562667847f, -0.72200000286102295f, -0.73159998655319214f, -0.74089998006820679f, -0.42809998989105225f, -0.43149998784065247f, -0.44920000433921814f, -0.47099998593330383f, -0.49459999799728394f, -0.51880002021789551f, -0.54269999265670776f, -0.5658000111579895f, -0.58799999952316284f, -0.60900002717971802f, -0.62870001792907715f, -0.64730000495910645f, -0.6646999716758728f, -0.68080002069473267f, -0.69590002298355103f, -0.70999997854232788f, -0.72299998998641968f, -0.73509997129440308f, -0.74639999866485596f, -0.75690001249313354f, -0.76670002937316895f, -0.77579998970031738f, -0.78430002927780151f, -0.79250001907348633f, -0.63230001926422119f, -0.60759997367858887f, -0.60519999265670776f, -0.61119997501373291f, -0.62209999561309814f, -0.63580000400543213f, -0.65090000629425049f, -0.66659998893737793f, -0.68239998817443848f, -0.69789999723434448f, -0.71289998292922974f, -0.7271999716758728f, -0.74089998006820679f, -0.75379997491836548f, -0.76590001583099365f, -0.77740001678466797f, -0.78810000419616699f, -0.79809999465942383f, -0.80750000476837158f, -0.81629997491836548f, -0.82450002431869507f, -0.83209997415542603f, -0.83929997682571411f, -0.84630000591278076f, -0.85790002346038818f, -0.80119997262954712f, -0.77600002288818359f, -0.76410001516342163f, -0.76059997081756592f, -0.76239997148513794f, -0.76770001649856567f, -0.7750999927520752f, -0.78380000591278076f, -0.79309999942779541f, -0.80279999971389771f, -0.8125f, -0.82200002670288086f, -0.8312000036239624f, -0.8400999903678894f, -0.84859997034072876f, -0.85670000314712524f, -0.86440002918243408f, -0.8716999888420105f, -0.87849998474121094f, -0.88499999046325684f, -0.89099997282028198f, -0.89670002460479736f, -0.90240001678466797f, -1.10769999027252197f, -1.01429998874664307f, -0.96329998970031738f, -0.93110001087188721f, -0.91140002012252808f, -0.89990001916885376f, -0.89410001039505005f, -0.89219999313354492f, -0.89289999008178711f, -0.89539998769760132f, -0.89910000562667847f, -0.9035000205039978f, -0.90850001573562622f, -0.91360002756118774f, -0.9189000129699707f, -0.92419999837875366f, -0.92940002679824829f, -0.93440002202987671f, -0.93930000066757202f, -0.9440000057220459f, -0.94849997758865356f, -0.95270001888275146f, -0.95679998397827148f, -0.96100002527236938f, -1.38499999046325684f, -1.24950003623962402f, -1.16919994354248047f, -1.11409997940063477f, -1.07599997520446777f, -1.0494999885559082f, -1.03129994869232178f, -1.01880002021789551f, -1.01059997081756592f, -1.00539994239807129f, -1.00240004062652588f, -1.00109994411468506f, -1.0009000301361084f, -1.00150001049041748f, -1.00279998779296875f, -1.00440001487731934f, -1.00639998912811279f, -1.00849997997283936f, -1.01069998741149902f, -1.0130000114440918f, -1.01530003547668457f, -1.01750004291534424f, -1.01979994773864746f, -1.02230000495910645f, -1.69420003890991211f, -1.51020002365112305f, -1.39649999141693115f, -1.31540000438690186f, -1.2565000057220459f, -1.21309995651245117f, -1.18079996109008789f, -1.15649998188018799f, -1.13820004463195801f, -1.12440001964569092f, -1.11389994621276855f, -1.10599994659423828f, -1.10010004043579102f, -1.09560000896453857f, -1.09230005741119385f, -1.09000003337860107f, -1.08829998970031738f, -1.08710002899169922f, -1.08640003204345703f, -1.08599996566772461f, -1.08580005168914795f, -1.08580005168914795f, -1.08599996566772461f, -1.0866999626159668f, -2.04089999198913574f, -1.80079996585845947f, -1.64869999885559082f, -1.53789997100830078f, -1.45539999008178711f, -1.392799973487854f, -1.34459996223449707f, -1.30700004100799561f, -1.27730000019073486f, -1.25380003452301025f, -1.23489999771118164f, -1.21959996223449707f, -1.20720005035400391f, -1.19700002670288086f, -1.18859994411468506f, -1.18169999122619629f, -1.17589998245239258f, -1.17100000381469727f, -1.16690003871917725f, -1.16349995136260986f, -1.16059994697570801f, -1.15810000896453857f, -1.15600001811981201f, -1.15470004081726074f, -2.43269991874694824f, -2.12700009346008301f, -1.93060004711151123f, -1.78569996356964111f, -1.67610001564025879f, -1.59159994125366211f, -1.52530002593994141f, -1.47249996662139893f, -1.4299999475479126f, -1.39540004730224609f, -1.36689996719360352f, -1.3432999849319458f, -1.32350003719329834f, -1.30680000782012939f, -1.29270005226135254f, -1.28059995174407959f, -1.27009999752044678f, -1.26110005378723145f, -1.25329995155334473f, -1.24639999866485596f, -1.24039995670318604f, -1.23500001430511475f, -1.23029994964599609f, -1.22669994831085205f, -2.87989997863769531f, -2.49659991264343262f, -2.24860000610351562f, -2.06410002708435059f, -1.92330002784729004f, -1.8135000467300415f, -1.72640001773834229f, -1.65620005130767822f, -1.59899997711181641f, -1.55169999599456787f, -1.51230001449584961f, -1.47909998893737793f, -1.45099997520446777f, -1.42690002918243408f, -1.40610003471374512f, -1.3881000280380249f, -1.37240004539489746f, -1.35860002040863037f, -1.34640002250671387f, -1.33570003509521484f, -1.32609999179840088f, -1.31749999523162842f, -1.30980002880096436f, -1.30359995365142822f, -3.39750003814697266f, -2.92090010643005371f, -2.6119999885559082f, -2.38100004196166992f, -2.20359992980957031f, -2.0643000602722168f, -1.95290005207061768f, -1.86249995231628418f, -1.7882000207901001f, -1.72619998455047607f, -1.67410004138946533f, -1.62989997863769531f, -1.59200000762939453f, -1.55929994583129883f, -1.53090000152587891f, -1.50610005855560303f, -1.48430001735687256f, -1.46500003337860107f, -1.44790005683898926f, -1.43260002136230469f, -1.4189000129699707f, -1.40649998188018799f, -1.39540004730224609f, -1.38629996776580811f, -4.00810003280639648f, -3.41639995574951172f, -3.03419995307922363f, -2.74749994277954102f, -2.52649998664855957f, -2.35209989547729492f, -2.21210002899169922f, -2.09780001640319824f, -2.00309991836547852f, -1.92390000820159912f, -1.85679996013641357f, -1.7994999885559082f, -1.75020003318786621f, -1.70739996433258057f, -1.66999995708465576f, -1.6371999979019165f, -1.60819995403289795f, -1.58239996433258057f, -1.55949997901916504f, -1.53890001773834229f, -1.52040004730224609f, -1.50370001792907715f, -1.48860001564025879f, -1.47609996795654297f, -4.7491002082824707f, -4.00920009613037109f, -3.53640007972717285f, -3.18140006065368652f, -2.90700006484985352f, -2.69000005722045898f, -2.5150001049041748f, -2.37150001525878906f, -2.25230002403259277f, -2.15199995040893555f, -2.06680011749267578f, -1.99370002746582031f, -1.93060004711151123f, -1.87559998035430908f, -1.82739996910095215f, -1.78489995002746582f, -1.74730002880096436f, -1.71379995346069336f, -1.68389999866485596f, -1.65699994564056396f, -1.63279998302459717f, -1.6109999418258667f, -1.59109997749328613f, -1.5746999979019165f, -5.68760013580322266f, -4.74030017852783203f, -4.15259981155395508f, -3.71110010147094727f, -3.36949992179870605f, -3.09859991073608398f, -2.87960004806518555f, -2.69939994812011719f, -2.54920005798339844f, -2.42239999771118164f, -2.31439995765686035f, -2.22140002250671387f, -2.1408998966217041f, -2.07069993019104004f, -2.00900006294250488f, -1.95459997653961182f, -1.90629994869232178f, -1.86329996585845947f, -1.82480001449584961f, -1.79030001163482666f, -1.75919997692108154f, -1.73099994659423828f, -1.70550000667572021f, -1.68429994583129883f, -6.68940019607543945f, -5.34350013732910156f, -4.86259984970092773f, -4.34409999847412109f, -3.93390011787414551f, -3.60269999504089355f, -3.33100008964538574f, -3.10509991645812988f, -2.91510009765625f, -2.75390005111694336f, -2.61590003967285156f, -2.49690008163452148f, -2.3935999870300293f, -2.30340003967285156f, -2.22420001029968262f, -2.15440011024475098f, -2.09240007400512695f, -2.03730010986328125f, -1.98800003528594971f, -1.94369995594024658f, -1.90390002727508545f, -1.86790001392364502f, -1.83480000495910645f, -1.8078000545501709f, -9.69550037384033203f, -7.62489986419677734f, -6.61070013046264648f, -5.72329998016357422f, -5.04829978942871094f, -4.52129983901977539f, -4.10120010375976562f, -3.76049995422363281f, -3.48009991645812988f, -3.24640011787414551f, -3.04959988594055176f, -2.88229990005493164f, -2.738800048828125f, -2.61479997634887695f, -2.50699996948242188f, -2.41269993782043457f, -2.32960009574890137f, -2.25620007514953613f, -2.19090008735656738f, -2.13269996643066406f, -2.08049988746643066f, -2.03349995613098145f, -1.99049997329711914f, -1.95369994640350342f
} };
__device__ __forceinline__ SheenProfile sheenProfile(float3  v_1, float3  n_i_1, BSDFMaterial material_1)
{
    SheenProfile _S332 = SheenProfile_x24init_0(false, 0.0f);
    float _S333 = rgb_to_greyscale(material_1.sheen);
    bool _S334 = _S333 > 0.0f;
    SheenProfile profile_0;
    if(_S334)
    {
        float _S335 = clamp_1((F32_sqrt(((F32_max((dot_0(n_i_1, v_1)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S336 = (U32_min((uint(_S335)), (22U)));
        float _S337 = (F32_sqrt((0.05000000074505806f)));
        float _S338 = (F32_sqrt((0.10000000149011612f)));
        bool _S339 = (material_1.velvet) > 0.0f;
        float _S340 = _slang_select(_S339, _S338,_S337);
        float _S341 = (clamp_1((F32_sqrt(((F32_max((material_1.sheen_roughness), (0.0f)))))), _S340, 1.0f) - _S340) / (1.0f - _S340) * 23.0f;
        uint _S342 = (U32_min((uint(_S341)), (22U)));
        uint _S343 = _S336 * 24U + _S342;
        float _S344 = _S335 - float(_S336);
        float _S345 = _S341 - float(_S342);
        if(_S339)
        {
            uint _S346 = _S343 + 24U;
            float _S347 = VELVET_ALBEDO_0[_S343] + (VELVET_ALBEDO_0[_S346] - VELVET_ALBEDO_0[_S343]) * _S344;
            uint _S348 = _S343 + 1U;
            float _S349 = VELVET_ALBEDO_0[_S348] + (VELVET_ALBEDO_0[_S346 + 1U] - VELVET_ALBEDO_0[_S348]) * _S344;
            SheenProfile _S350 = SheenProfile_x24init_0(true, _S347 + (_S349 - _S347) * _S345);
            profile_0 = _S350;
        }
        else
        {
            uint _S351 = _S343 + 24U;
            float _S352 = SHEEN_ALBEDO_0[_S343] + (SHEEN_ALBEDO_0[_S351] - SHEEN_ALBEDO_0[_S343]) * _S344;
            uint _S353 = _S343 + 1U;
            float _S354 = SHEEN_ALBEDO_0[_S353] + (SHEEN_ALBEDO_0[_S351 + 1U] - SHEEN_ALBEDO_0[_S353]) * _S344;
            SheenProfile _S355 = SheenProfile_x24init_0(true, (F32_exp((_S352 + (_S354 - _S352) * _S345))));
            profile_0 = _S355;
        }
    }
    else
    {
        profile_0 = _S332;
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
    Weights _S356;
    (&_S356)->v_dot_h = v_dot_h_0;
    (&_S356)->refracted = refracted_1;
    (&_S356)->F = F_0;
    (&_S356)->reflect_weight = reflect_weight_0;
    (&_S356)->diffuse_weight = diffuse_weight_0;
    (&_S356)->refract_weight = refract_weight_0;
    (&_S356)->p_diffuse = p_diffuse_0;
    (&_S356)->p_reflect = p_reflect_0;
    (&_S356)->p_refract = p_refract_0;
    (&_S356)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S356)->p_toon = p_toon_0;
    (&_S356)->sheen = sheen_0;
    (&_S356)->toon = toon_0;
    return _S356;
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
    float3  _S357 = make_float3 (alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z);
    float3  _S358 = ((((_S357)) * make_float3(rnorm3df(((_S357)).x, ((_S357)).y, ((_S357)).z))));
    float _S359 = _S358.x;
    float _S360 = _S358.y;
    float _S361 = _S359 * _S359 + _S360 * _S360;
    float3  _S362;
    if(_S361 > 0.0f)
    {
        float3  _S363 = make_float3 (- _S360, _S359, 0.0f);
        float _S364 = (rsqrtf((_S361)));
        _S362 = _S363 * make_float3 (_S364);
    }
    else
    {
        _S362 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S365 = cross_0(_S358, _S362);
    float _S366 = (F32_sqrt((U1_0)));
    float _S367 = 6.28318548202514648f * U2_0;
    float _S368 = _S366 * (F32_cos((_S367)));
    float t2_0 = _S366 * (F32_sin((_S367)));
    float _S369 = 0.5f * (1.0f + _S358.z);
    float t2_1 = (1.0f - _S369) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S368 * _S368)))))) + _S369 * t2_0;
    float3  _S370 = make_float3 (_S368) * _S362 + make_float3 (t2_1) * _S365;
    float _S371 = unshared_0(_S368);
    float _S372 = unshared_0(_S368);
    float3  _S373 = _S370 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S371 * _S372 - t2_1 * t2_1))))))) * _S358;
    float3  _S374 = make_float3 (alpha_0 * _S373.x, alpha_0 * _S373.y, (F32_max((0.0f), (_S373.z))));
    float3  _S375 = ((((_S374)) * make_float3(rnorm3df(((_S374)).x, ((_S374)).y, ((_S374)).z))));
    return _S375;
}

__device__ float3  worldToTangent(float3  v_2, float3  n_3)
{
    float3  a_3 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S376 = (F32_abs((dot_0(n_3, a_3)))) > 0.9999847412109375f;
    float3  a_4;
    if(_S376)
    {
        float3  _S377 = make_float3 (1.0f, 0.0f, 0.0f);
        a_4 = _S377;
    }
    else
    {
        a_4 = a_3;
    }
    float3  _S378 = cross_0(n_3, a_4);
    float3  _S379 = ((((_S378)) * make_float3(rnorm3df(((_S378)).x, ((_S378)).y, ((_S378)).z))));
    float3  _S380 = cross_0(n_3, _S379);
    return make_float3 (dot_0(v_2, _S379), dot_0(v_2, n_3), dot_0(v_2, _S380));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_3, float3  n_i_2, float alpha_1, AnisotropicFrame frame_0, uint * random_state_2)
{
    Random _S381 = pcg(*random_state_2);
    Random _S382 = pcg(_S381.state);
    *random_state_2 = _S382.state;
    float _S383 = frame_0.alphas.x;
    bool _S384 = _S383 > 0.0f;
    if(_S384)
    {
        float3  _S385 = anisotropicLocal(v_3, frame_0.tangent, n_i_2);
        float _S386 = frame_0.alphas.y;
        float3  _S387 = make_float3 (_S383 * _S385.x, _S386 * _S385.y, _S385.z);
        float3  _S388 = ((((_S387)) * make_float3(rnorm3df(((_S387)).x, ((_S387)).y, ((_S387)).z))));
        float3  _S389 = sampleGGXVNDF(_S388, 1.0f, _S381.value, _S382.value);
        float3  _S390 = make_float3 (_S383 * _S389.x, _S386 * _S389.y, _S389.z);
        float3  _S391 = ((((_S390)) * make_float3(rnorm3df(((_S390)).x, ((_S390)).y, ((_S390)).z))));
        return make_float3 (_S391.x) * frame_0.tangent + make_float3 (_S391.y) * cross_0(n_i_2, frame_0.tangent) + make_float3 (_S391.z) * n_i_2;
    }
    float3  _S392 = worldToTangent(v_3, n_i_2);
    float3  _S393 = sampleGGXVNDF(float3 {_S392.x, _S392.z, _S392.y}, alpha_1, _S381.value, _S382.value);
    float3  _S394 = float3 {_S393.x, _S393.z, _S393.y};
    float3  _S395 = tangentToWorld(_S394, n_i_2);
    return _S395;
}

__device__ __forceinline__ float3  sampledHalf(float3  v_4, float3  n_i_3, float alpha_2, AnisotropicFrame frame_1, uint random_state_3)
{
    uint state_3 = random_state_3;
    float3  _S396 = sampleHalfVector(v_4, n_i_3, alpha_2, frame_1, &state_3);
    return _S396;
}

__device__ __forceinline__ float3  refractedHalf(float3  in_dir_0, float3  out_dir_0, float3  n_4, float eta_i_0, float eta_o_0)
{
    float3  _S397 = negate_0(in_dir_0);
    float3  _S398 = negate_0(make_float3 (eta_i_0) * _S397 + make_float3 (eta_o_0) * out_dir_0);
    float3  _S399 = ((((_S398)) * make_float3(rnorm3df(((_S398)).x, ((_S398)).y, ((_S398)).z))));
    float _S400 = sign_0(dot_0(n_4, _S397));
    float _S401 = sign_0(dot_0(_S398, n_4 * make_float3 (_S400)));
    return _S399 * make_float3 (_S401);
}

__device__ __forceinline__ float3  reflectedHalf(float3  in_dir_1, float3  out_dir_1)
{
    float3  _S402 = negate_0(in_dir_1);
    float3  _S403 = _S402 + out_dir_1;
    float3  _S404 = ((((_S403)) * make_float3(rnorm3df(((_S403)).x, ((_S403)).y, ((_S403)).z))));
    return _S404;
}

static __device__ float3  refract_0(float3  i_5, float3  n_5, float eta_0)
{
    float _S405 = dot_0(n_5, i_5);
    float _S406 = 1.0f - eta_0 * eta_0 * (1.0f - _S405 * _S405);
    if(_S406 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_5 - make_float3 (eta_0 * _S405 + (F32_sqrt((_S406)))) * n_5;
}

__device__ float fresnel(float cos_theta_0, float eta_i_1, float eta_o_1)
{
    float _S407 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S408 = eta_i_1 / eta_o_1 * _S407;
    bool _S409 = _S408 < 1.0f;
    float kr_0;
    if(_S409)
    {
        float _S410 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S408 * _S408))))));
        float _S411 = eta_o_1 * cos_theta_0;
        float _S412 = eta_i_1 * _S410;
        float _S413 = (_S411 - _S412) / (_S411 + _S412);
        float _S414 = eta_i_1 * cos_theta_0;
        float _S415 = eta_o_1 * _S410;
        float _S416 = (_S414 - _S415) / (_S414 + _S415);
        float _S417 = (_S413 * _S413 + _S416 * _S416) / 2.0f;
        kr_0 = _S417;
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

__device__ __forceinline__ Weights lobeWeights(float3  in_dir_2, float3  v_5, float3  n_i_4, float3  ggx_n_0, AnisotropicFrame frame_2, SheenProfile sheen_profile_0, BSDFMaterial material_2, float eta_i_2, float eta_o_2)
{
    float _S418 = dot_0(ggx_n_0, v_5);
    float _S419 = eta_i_2 / eta_o_2;
    float3  _S420 = refract_0(in_dir_2, ggx_n_0, _S419);
    float3  _S421 = ((((_S420)) * make_float3(rnorm3df(((_S420)).x, ((_S420)).y, ((_S420)).z))));
    float _S422 = (F32_min(((F32_sqrt((material_2.specular_level))) * (F32_abs((eta_i_2 - eta_o_2))) / (eta_i_2 + eta_o_2)), (0.9999847412109375f)));
    float _S423 = _S422 * _S422;
    float _S424 = (1.0f + _S422) / (1.0f - _S422);
    float _S425 = (F32_abs((_S418)));
    bool _S426 = eta_i_2 > eta_o_2;
    float sheen_component_0;
    if(_S426)
    {
        sheen_component_0 = _S424;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    float toon_component_0;
    if(_S426)
    {
        toon_component_0 = 1.0f;
    }
    else
    {
        toon_component_0 = _S424;
    }
    float _S427 = fresnel(_S425, sheen_component_0, toon_component_0);
    bool _S428 = (eta_i_2 * eta_i_2 * (1.0f - _S418 * _S418)) >= (eta_o_2 * eta_o_2);
    float3  _S429;
    if(_S428)
    {
        _S429 = make_float3 (1.0f);
    }
    else
    {
        float3  _S430 = material_2.specular_tint * make_float3 (_S423);
        _S429 = _S430 + (make_float3 (1.0f) - _S430) * make_float3 (_S427 - _S423) / make_float3 (1.0f - _S423);
    }
    float3  _S431 = make_float3 (1.0f);
    float3  _S432 = make_float3 (0.0f);
    float3  sheen_1;
    float3  scale_1;
    if(sheen_profile_0.on)
    {
        float _S433 = (F32_min((sheen_profile_0.albedo), (1.0f)));
        float3  _S434 = make_float3 (1.0f) - material_2.sheen * make_float3 (_S433);
        float _S435 = rgb_to_greyscale(material_2.sheen);
        float _S436 = _S435 * _S433;
        float3  _S437 = material_2.sheen / make_float3 ((F32_max((sheen_profile_0.albedo), (1.0f))));
        sheen_component_0 = _S436;
        sheen_1 = _S437;
        scale_1 = _S434;
    }
    else
    {
        sheen_component_0 = 0.0f;
        sheen_1 = _S432;
        scale_1 = _S431;
    }
    float _S438 = (F32_abs((material_2.toon.x)));
    bool _S439 = _S438 > 0.0f;
    float3  toon_1;
    if(_S439)
    {
        float _S440 = (F32_min((_S438), (1.0f)));
        float3  scale_2 = scale_1 * make_float3 (1.0f - _S440);
        float _S441 = rgb_to_greyscale(material_2.albedo);
        float _S442 = _S440 * _S441;
        float3  _S443 = make_float3 (_S440) * material_2.albedo;
        toon_component_0 = _S442;
        toon_1 = _S443;
        scale_1 = scale_2;
    }
    else
    {
        toon_component_0 = 0.0f;
        toon_1 = _S432;
    }
    bool _S444 = (material_2.metallic) > 0.0f;
    float3  rebounce_0;
    if(_S444)
    {
        float _S445 = frame_2.alphas.x;
        float _S446 = (F32_sqrt(((F32_min((_S445), (frame_2.alphas.y))))));
        bool _S447 = _S445 > 0.0f;
        float _S448 = _slang_select(_S447, _S446,material_2.roughness);
        float _S449 = _S448 * _S448;
        float _S450 = (F32_pow((_S449), (1.81585001945495605f))) * (2.15371990203857422f - 0.73285001516342163f * _S449) / (1.0f + 1.28094995021820068f * _S449);
        bool _S451 = _S449 > 0.0f;
        float _S452 = _slang_select(_S451, _S450,0.0f);
        float _S453 = clamp_1(dot_0(n_i_4, v_5), 0.0f, 1.0f);
        float _S454 = _S449 * _S448;
        float _S455 = (F32_min((1.00064504146575928f - _S448 * (0.00375499995425344f + _S453 * (-0.04133399948477745f + _S453 * (-0.90938502550125122f + _S453 * 0.35275399684906006f))) - _S449 * (0.27602800726890564f + _S453 * (1.27023398876190186f + _S453 * 0.04740000143647194f)) - _S454 * (0.31452900171279907f - _S453 * 0.34830701351165771f) + _S454 * _S448 * 0.27229699492454529f), (1.0f)));
        float3  _S456 = min_1(make_float3 (1.0f) / (make_float3 (1.0f) - material_2.albedo * make_float3 (_S452)), make_float3 (1.0f / (F32_max((_S455), (0.0000152587890625f)))));
        rebounce_0 = _S456;
    }
    else
    {
        rebounce_0 = _S431;
    }
    float3  _S457 = mix_0(_S429, material_2.albedo * rebounce_0, material_2.metallic);
    float3  F_1 = _S457 * scale_1;
    float _S458 = rgb_to_greyscale(F_1);
    float _S459 = 1.0f - material_2.metallic;
    float3  _S460 = make_float3 (1.0f) - _S429;
    float3  _S461 = make_float3 ((1.0f - material_2.transmission) * _S459) * _S460 * scale_1;
    float3  _S462 = make_float3 (material_2.transmission * _S459) * _S460 * scale_1;
    float _S463 = (F32_max((_S458), (0.0f)));
    float _S464 = rgb_to_greyscale(_S461);
    float _S465 = (F32_max((_S464), (0.0f)));
    float _S466 = rgb_to_greyscale(_S462);
    float _S467 = sign_0(length_0(_S421));
    float _S468 = (F32_max((_S466 * _S467), (0.0f)));
    float _S469 = _S463 + _S465 + _S468 + toon_component_0;
    float _S470 = (F32_min((sheen_component_0), (1.0f)));
    bool _S471 = sheen_component_0 > 0.0f;
    bool _S472;
    if(_S471)
    {
        _S472 = !(_S469 > 0.0f);
    }
    else
    {
        _S472 = false;
    }
    float _S473 = _slang_select(_S472, 1.0f,_S470);
    float _S474 = (1.0f - _S473) / (F32_max((_S469), (0.0000152587890625f)));
    float _S475 = _S465 * _S474;
    float _S476 = _S463 * _S474;
    float _S477 = _S468 * _S474;
    return Weights_x24init_0(_S418, _S421, F_1, 1.0f, _S461, _S462, _S475, _S476, _S477, _S473, toon_component_0 * _S474, sheen_1, toon_1);
}

__device__ float translucentShare(BSDFMaterial material_3)
{
    float _S478 = rgb_to_greyscale(material_3.translucent);
    float _S479 = rgb_to_greyscale(material_3.albedo);
    float _S480 = _S478 / (_S479 + _S478);
    bool _S481 = _S478 > 0.0f;
    float _S482 = _slang_select(_S481, _S480,0.0f);
    return _S482;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float n_i_dot_v_0, BSDFMaterial material_4, Weights w_1)
{
    float _S483 = translucentShare(material_4);
    float _S484 = w_1.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S485 = w_1.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S486 = 1.0f - _S483;
    bool _S487 = n_i_dot_l_0 < 0.0f;
    float _S488 = _slang_select(_S487, _S483,_S486);
    float _S489 = _S485 * _S488;
    bool _S490 = _S483 > 0.0f;
    float _S491 = _slang_select(_S490, _S489,_S484);
    bool _S492 = n_i_dot_v_0 > 0.0f;
    float _S493 = _slang_select(_S492, _S491,0.0f);
    return _S493;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_5, BSDFMaterial material_5, Weights w_2)
{
    float _S494 = translucentShare(material_5);
    bool _S495 = (dot_0(n_i_5, l_0)) < 0.0f;
    float3  _S496 = _slang_select(_S495, material_5.translucent,material_5.albedo);
    float _S497 = 1.0f - _S494;
    float _S498 = _slang_select(_S495, _S494,_S497);
    float3  _S499 = _S496 / make_float3 (_S498);
    bool _S500 = _S494 > 0.0f;
    float3  _S501 = _slang_select(_S500, _S499,material_5.albedo);
    return w_2.diffuse_weight * _S501 / make_float3 (w_2.p_diffuse);
}

__device__ float smithG1(float alpha_3, float n_dot_x_0)
{
    float _S502 = alpha_3 * alpha_3;
    float _S503 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S502 + (1.0f - _S502) * n_dot_x_0 * n_dot_x_0))));
    bool _S504 = alpha_3 > 0.0f;
    float _S505 = _slang_select(_S504, _S503,1.0f);
    return _S505;
}

__device__ float trowbridgeReitz(float alpha_4, float n_dot_h_0)
{
    float _S506 = alpha_4 * alpha_4;
    float _S507 = (1.0f - n_dot_h_0) * (1.0f + n_dot_h_0) + _S506 * n_dot_h_0 * n_dot_h_0;
    return _S506 / (F32_max((3.14159274101257324f * _S507 * _S507), (1.17549435082228751e-38f)));
}

__device__ float anisotropicG1(float3  w_3, float2  alphas_1)
{
    float _S508 = (F32_max((w_3.z), (0.0f)));
    return 2.0f * _S508 / (_S508 + length_0(make_float3 (alphas_1.x * w_3.x, alphas_1.y * w_3.y, _S508)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_2)
{
    float _S509 = alphas_2.x;
    float _S510 = h_0.x / _S509;
    float _S511 = alphas_2.y;
    float _S512 = h_0.y / _S511;
    float _S513 = h_0.z;
    float _S514 = _S510 * _S510 + _S512 * _S512 + _S513 * _S513;
    return 1.0f / (F32_max((3.14159274101257324f * _S509 * _S511 * _S514 * _S514), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float3  v_6, float3  h_1, float3  n_i_6, float n_i_dot_v_1, float alpha_5, AnisotropicFrame frame_3, float v_dot_h_1)
{
    float _S515 = dot_0(n_i_6, h_1);
    float _S516 = smithG1(alpha_5, n_i_dot_v_1);
    float _S517 = _S516 * v_dot_h_1;
    float _S518 = trowbridgeReitz(alpha_5, _S515);
    float _S519 = _S517 * _S518 / n_i_dot_v_1;
    bool _S520 = alpha_5 > 0.0f;
    bool _S521;
    if(_S520)
    {
        _S521 = v_dot_h_1 > 0.0f;
    }
    else
    {
        _S521 = false;
    }
    if(_S521)
    {
        _S521 = _S515 > 0.0f;
    }
    else
    {
        _S521 = false;
    }
    if(_S521)
    {
        _S521 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S521 = false;
    }
    float _S522 = _slang_select(_S521, _S519,0.0f);
    bool _S523 = (frame_3.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S523)
    {
        float3  _S524 = anisotropicLocal(v_6, frame_3.tangent, n_i_6);
        float _S525 = anisotropicG1(_S524, frame_3.alphas);
        float3  _S526 = anisotropicLocal(h_1, frame_3.tangent, n_i_6);
        float _S527 = anisotropicD(_S526, frame_3.alphas);
        float _S528 = _S525 * _S527;
        float _S529 = _S528 * v_dot_h_1 / n_i_dot_v_1;
        bool _S530 = v_dot_h_1 > 0.0f;
        if(_S530)
        {
            _S521 = _S515 > 0.0f;
        }
        else
        {
            _S521 = false;
        }
        if(_S521)
        {
            _S521 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S521 = false;
        }
        float _S531 = _slang_select(_S521, _S529,0.0f);
        pdf_h_0 = _S531;
    }
    else
    {
        pdf_h_0 = _S522;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float l_dot_h_0, float pdf_h_1, Weights w_4, float eta_i_3, float eta_o_3)
{
    float _S532 = eta_i_3 * w_4.v_dot_h + eta_o_3 * l_dot_h_0;
    float _S533 = w_4.p_refract * pdf_h_1 * eta_o_3 * eta_o_3 * (F32_abs((l_dot_h_0))) / (_S532 * _S532);
    bool _S534 = eta_i_3 != eta_o_3;
    bool _S535;
    if(_S534)
    {
        _S535 = l_dot_h_0 < 0.0f;
    }
    else
    {
        _S535 = false;
    }
    float _S536 = _slang_select(_S535, _S533,0.0f);
    return _S536;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_7, float alpha_6, AnisotropicFrame frame_4, BSDFMaterial material_6, Weights w_5)
{
    float _S537 = - dot_0(n_i_7, l_1);
    float _S538 = smithG1(alpha_6, (F32_max((_S537), (0.0f))));
    bool _S539 = (frame_4.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S539)
    {
        float3  _S540 = negate_0(n_i_7);
        float3  _S541 = anisotropicLocal(l_1, frame_4.tangent, _S540);
        float _S542 = anisotropicG1(_S541, frame_4.alphas);
        G1_l_0 = _S542;
    }
    else
    {
        G1_l_0 = _S538;
    }
    return w_5.refract_weight * make_float3 (G1_l_0) * material_6.albedo / make_float3 (w_5.p_refract);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_1, float n_i_dot_v_2, Weights w_6)
{
    float _S543 = w_6.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S544 = n_i_dot_l_1 > 0.0f;
    bool _S545;
    if(_S544)
    {
        _S545 = n_i_dot_v_2 > 0.0f;
    }
    else
    {
        _S545 = false;
    }
    float _S546 = _slang_select(_S545, _S543,0.0f);
    return _S546;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  v_7, float3  n_i_8, BSDFMaterial material_7, Weights w_7)
{
    float3  _S547 = l_2 + v_7;
    float3  _S548 = ((((_S547)) * make_float3(rnorm3df(((_S547)).x, ((_S547)).y, ((_S547)).z))));
    float _S549 = dot_0(n_i_8, _S548);
    float _S550 = (F32_max((dot_0(n_i_8, l_2)), (0.0f)));
    float _S551 = (F32_max((dot_0(n_i_8, v_7)), (0.0f)));
    float _S552 = 1.0f / (F32_max((material_7.sheen_roughness), (0.05000000074505806f)));
    float _S553 = 1.0f - _S549 * _S549;
    float _S554 = (2.0f + _S552) * (F32_pow(((F32_max((_S553), (0.0f)))), (0.5f * _S552))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S550 + _S551 - _S550 * _S551)), (0.0000152587890625f)));
    bool _S555 = (material_7.velvet) > 0.0f;
    float f_1;
    if(_S555)
    {
        float _S556 = (F32_max((material_7.sheen_roughness), (0.00999999977648258f)));
        float _S557 = _S556 * _S556;
        float _S558 = (F32_max((_S553), (0.0000152587890625f)));
        float _S559 = (F32_exp((- _S549 * _S549 / (_S558 * _S557)))) / (3.14159274101257324f * _S557 * _S558 * _S558) * (F32_min((1.0f), (2.0f * _S549 * (F32_min((_S550), (_S551))) / (F32_max(((F32_abs((dot_0(_S548, v_7))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S550 * _S551), (0.0000152587890625f)));
        f_1 = _S559;
    }
    else
    {
        f_1 = _S554;
    }
    return w_7.sheen * make_float3 (f_1 * _S550 * 2.0f * 3.14159274101257324f / w_7.p_sheen_velvet);
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
    float _S560;
    if(t_13 < a_5)
    {
        _S560 = 1.0f;
    }
    else
    {
        _S560 = (F32_max((1.0f - (t_13 - a_5) / (F32_max((s_0), (0.0000152587890625f)))), (0.0f)));
    }
    return _S560;
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
        float _S561 = (F32_sin(((F32_min((t_14), (a_6))))));
        integral_0 = _S561 * _S561 / 2.0f;
    }
    bool _S562 = t_14 > a_6;
    bool _S563;
    if(_S562)
    {
        _S563 = s_1 > 0.0f;
    }
    else
    {
        _S563 = false;
    }
    if(_S563)
    {
        float _S564;
        if(glossy_0)
        {
            float _S565 = (F32_cos((a_6)));
            float _S566 = (F32_cos((t_14)));
            _S564 = (1.0f + a_6 / s_1) * (_S565 - _S566) - ((F32_sin((t_14))) - t_14 * _S566 - ((F32_sin((a_6))) - a_6 * _S565)) / s_1;
        }
        else
        {
            float _S567 = 2.0f * a_6;
            float _S568 = (F32_cos((_S567)));
            float _S569 = 2.0f * t_14;
            float _S570 = (F32_cos((_S569)));
            _S564 = (1.0f + a_6 / s_1) * (_S568 - _S570) / 4.0f - ((F32_sin((_S569))) / 8.0f - t_14 * _S570 / 4.0f - ((F32_sin((_S567))) / 8.0f - a_6 * _S568 / 4.0f)) / s_1;
        }
        float integral_1 = integral_0 + _S564;
        integral_0 = integral_1;
    }
    return integral_0;
}

static __device__ ToonProfile ToonProfile_x24init_0(bool glossy_1, float a_7, float s_2, float b_1, float norm_0, float view_0, float3  axis_0)
{
    ToonProfile _S571;
    (&_S571)->glossy = glossy_1;
    (&_S571)->a = a_7;
    (&_S571)->s = s_2;
    (&_S571)->b = b_1;
    (&_S571)->norm = norm_0;
    (&_S571)->view = view_0;
    (&_S571)->axis = axis_0;
    return _S571;
}

__device__ __forceinline__ ToonProfile toonProfile(float3  v_8, float3  n_i_9, BSDFMaterial material_8)
{
    float _S572 = material_8.toon.x;
    bool _S573 = _S572 < 0.0f;
    float _S574 = clamp_1(material_8.toon.y / _S572, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S575 = clamp_1(material_8.toon.z / _S572, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S576 = (F32_min((_S574 + _S575), (1.57079637050628662f)));
    float _S577 = dot_0(n_i_9, v_8);
    float _S578 = toonP((F32_acos(((F32_min((_S577), (1.0f)))))), _S574, _S575);
    float3  _S579;
    if(_S573)
    {
        float3  _S580 = make_float3 (2.0f * _S577) * n_i_9 - v_8;
        float3  _S581 = ((((_S580)) * make_float3(rnorm3df(((_S580)).x, ((_S580)).y, ((_S580)).z))));
        _S579 = _S581;
    }
    else
    {
        _S579 = n_i_9;
    }
    float _S582 = toonIntegral(_S576, _S574, _S575, _S573);
    return ToonProfile_x24init_0(_S573, _S574, _S575, _S576, 6.28318548202514648f * _S582, _S578, _S579);
}

__device__ __forceinline__ float toonPDF(float3  l_3, float3  n_i_10, ToonProfile profile_1, Weights w_8)
{
    float _S583 = dot_0(n_i_10, l_3);
    float _S584 = dot_0(l_3, profile_1.axis);
    float _S585 = _slang_select(profile_1.glossy, _S584,_S583);
    float _S586 = (F32_acos((clamp_1(_S585, -1.0f, 1.0f))));
    float _S587 = toonP(_S586, profile_1.a, profile_1.s);
    float _S588 = w_8.p_toon * _S587;
    float _S589 = _slang_select(profile_1.glossy, 1.0f,_S583);
    float _S590 = _S588 * _S589 / profile_1.norm;
    bool _S591;
    if(profile_1.glossy)
    {
        _S591 = true;
    }
    else
    {
        _S591 = _S583 > 0.0f;
    }
    float _S592 = _slang_select(_S591, _S590,0.0f);
    return _S592;
}

__device__ __forceinline__ float3  toonBSDF(float3  l_4, float3  n_i_11, ToonProfile profile_2, Weights w_9)
{
    float _S593 = (F32_max((dot_0(n_i_11, l_4)), (0.0f)));
    float _S594 = _slang_select(profile_2.glossy, _S593,profile_2.view);
    return w_9.toon * make_float3 (_S594) / make_float3 (w_9.p_toon);
}

__device__ __forceinline__ float reflectPDF(float pdf_h_2, Weights w_10)
{
    float _S595 = w_10.p_reflect * pdf_h_2 / (4.0f * w_10.v_dot_h);
    bool _S596 = pdf_h_2 > 0.0f;
    float _S597 = _slang_select(_S596, _S595,0.0f);
    return _S597;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_5, float3  n_i_12, float alpha_7, AnisotropicFrame frame_5, Weights w_11)
{
    float _S598 = dot_0(n_i_12, l_5);
    float _S599 = smithG1(alpha_7, (F32_max((_S598), (0.0f))));
    bool _S600 = (frame_5.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S600)
    {
        float3  _S601 = anisotropicLocal(l_5, frame_5.tangent, n_i_12);
        float _S602 = anisotropicG1(_S601, frame_5.alphas);
        G1_l_1 = _S602;
    }
    else
    {
        G1_l_1 = _S599;
    }
    return make_float3 (w_11.reflect_weight * G1_l_1) * w_11.F / make_float3 (w_11.p_reflect);
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_3, float3  out_dir_2, float3  n_6, BSDFMaterial material_9, float eta_i_4, float eta_o_4, bool refracted_2, uint random_state_4, FixedArray<float3 , 5>  * throughputs_0, FixedArray<float, 5>  * pdfs_0)
{
    float3  ggx_n_1;
    float3  _S603 = negate_0(in_dir_3);
    float _S604 = dot_0(n_6, _S603);
    float _S605 = sign_0(_S604);
    float3  _S606 = n_6 * make_float3 (_S605);
    float _S607 = dot_0(_S606, out_dir_2);
    float _S608 = material_9.roughness;
    float _S609 = _S608 * _S608;
    AnisotropicFrame _S610 = anisotropicFrame(material_9, _S606);
    SheenProfile _S611 = sheenProfile(_S603, _S606, material_9);
    float _S612 = rgb_to_greyscale(material_9.translucent);
    bool _S613 = _S612 > 0.0f;
    bool _S614 = (dot_0(n_6, out_dir_2) * _S604) < 0.0f;
    bool _S615 = (F32_abs((material_9.toon.x))) > 0.0f;
    uint _S616;
    if(_S615)
    {
        _S616 = 5U;
    }
    else
    {
        _S616 = 4U;
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
        float3  _S617 = make_float3 (0.0f);
        (*throughputs_0)[i_7] = _S617;
        (*pdfs_0)[i_7] = 0.0f;
        uint i_8 = i_7 + 1U;
        i_7 = i_8;
    }
    float3  _S618 = make_float3 (0.0f);
    Weights _S619 = Weights_x24init_0(0.0f, _S618, _S618, 0.0f, _S618, _S618, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, _S618, _S618);
    uint half_of_0 = 4294967295U;
    Weights w_12 = _S619;
    float3  ggx_n_2 = _S618;
    i_7 = 0U;
    for(;;)
    {
        if(i_7 < _S616)
        {
        }
        else
        {
            break;
        }
        uint _S620;
        if(i_7 == 3U)
        {
            _S620 = 4U;
        }
        else
        {
            if(i_7 == 4U)
            {
                _S620 = 6U;
            }
            else
            {
                _S620 = i_7;
            }
        }
        bool _S621 = _S620 == 0U;
        bool _S622;
        if(_S621)
        {
            _S622 = _S613;
        }
        else
        {
            _S622 = false;
        }
        bool _S623;
        if(_S622)
        {
            _S623 = _S614;
        }
        else
        {
            _S623 = _S620 == 1U;
        }
        bool _S624 = _S623 != refracted_2;
        if(_S624)
        {
            ggx_n_1 = ggx_n_2;
            uint i_9 = i_7 + 1U;
            ggx_n_2 = ggx_n_1;
            i_7 = i_9;
            continue;
        }
        uint _S625;
        if(_S620 == 6U)
        {
            _S625 = 0U;
        }
        else
        {
            if(_S620 == 4U)
            {
                _S625 = 2U;
            }
            else
            {
                _S625 = _S620;
            }
        }
        bool _S626 = _S625 != half_of_0;
        uint half_of_1;
        Weights w_13;
        if(_S626)
        {
            bool _S627 = _S625 == 0U;
            if(_S627)
            {
                float3  _S628 = sampledHalf(_S603, _S606, _S609, _S610, random_state_4);
                ggx_n_1 = _S628;
            }
            else
            {
                bool _S629 = _S625 == 1U;
                if(_S629)
                {
                    float3  _S630 = refractedHalf(in_dir_3, out_dir_2, n_6, eta_i_4, eta_o_4);
                    ggx_n_1 = _S630;
                }
                else
                {
                    float3  _S631 = reflectedHalf(in_dir_3, out_dir_2);
                    ggx_n_1 = _S631;
                }
            }
            Weights _S632 = lobeWeights(in_dir_3, _S603, _S606, ggx_n_1, _S610, _S611, material_9, eta_i_4, eta_o_4);
            w_13 = _S632;
            half_of_1 = _S625;
        }
        else
        {
            w_13 = w_12;
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S620)
        {
        case 0U:
            {
                float _S633 = diffusePDF(_S607, (F32_abs((_S604))), material_9, w_13);
                (*pdfs_0)[int(0)] = _S633;
                float3  _S634 = diffuseBSDF(out_dir_2, _S606, material_9, w_13);
                (*throughputs_0)[int(0)] = _S634;
                break;
            }
        case 1U:
            {
                float _S635 = dot_0(out_dir_2, ggx_n_1);
                float _S636 = vndfPDF(_S603, ggx_n_1, _S606, (F32_abs((_S604))), _S609, _S610, w_13.v_dot_h);
                float _S637 = refractPDF(_S635, _S636, w_13, eta_i_4, eta_o_4);
                (*pdfs_0)[int(1)] = _S637;
                float3  _S638 = refractBSDF(out_dir_2, _S606, _S609, _S610, material_9, w_13);
                (*throughputs_0)[int(1)] = _S638;
                break;
            }
        case 4U:
            {
                float _S639 = sheenVelvetPDF(_S607, (F32_abs((_S604))), w_13);
                (*pdfs_0)[int(3)] = _S639;
                float3  _S640 = sheenVelvetBSDF(out_dir_2, _S603, _S606, material_9, w_13);
                (*throughputs_0)[int(3)] = _S640;
                break;
            }
        case 6U:
            {
                ToonProfile _S641 = toonProfile(_S603, _S606, material_9);
                float _S642 = toonPDF(out_dir_2, _S606, _S641, w_13);
                (*pdfs_0)[int(4)] = _S642;
                float3  _S643 = toonBSDF(out_dir_2, _S606, _S641, w_13);
                (*throughputs_0)[int(4)] = _S643;
                break;
            }
        default:
            {
                float _S644 = vndfPDF(_S603, ggx_n_1, _S606, (F32_abs((_S604))), _S609, _S610, w_13.v_dot_h);
                float _S645 = reflectPDF(_S644, w_13);
                (*pdfs_0)[int(2)] = _S645;
                float3  _S646 = reflectBSDF(out_dir_2, _S606, _S609, _S610, w_13);
                (*throughputs_0)[int(2)] = _S646;
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
    ggx_n_1 = _S618;
    for(;;)
    {
        if(i_7 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S647 = ((*pdfs_0)[i_7]) > 0.0f;
        if(_S647)
        {
            float3  f_2 = ggx_n_1 + (*throughputs_0)[i_7] * make_float3 ((*pdfs_0)[i_7]);
            ggx_n_1 = f_2;
        }
        uint i_10 = i_7 + 1U;
        i_7 = i_10;
    }
    return ggx_n_1;
}

static __device__ __forceinline__ float3  skyLobes_0(float3  in_dir_4, float3  dir_3, FKSurface * surface_1, float2  eta_1, bool is_inside_2, float pdf_0, uint random_state_5, FixedArray<float3 , 5>  * terms_0, FixedArray<float, 5>  * pdfs_1)
{
    bool _S648 = wrongSide_0(is_inside_2, false, dir_3, surface_1->geometry_n);
    float3  _S649 = BSDF(in_dir_4, dir_3, surface_1->smooth_n, surface_1->material, eta_1.x, eta_1.y, _S648, random_state_5, terms_0, pdfs_1);
    float3  _S650 = make_float3 (0.0f);
    uint i_11 = 0U;
    float3  f_3 = _S650;
    for(;;)
    {
        if(i_11 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S651 = ((*pdfs_1)[i_11]) > 0.0f;
        if(_S651)
        {
            float3  _S652 = (*terms_0)[i_11] * make_float3 ((*pdfs_1)[i_11]) / make_float3 ((*pdfs_1)[i_11] + pdf_0);
            (*terms_0)[i_11] = _S652;
            float3  f_4 = f_3 + (*terms_0)[i_11];
            f_3 = f_4;
        }
        uint i_12 = i_11 + 1U;
        i_11 = i_12;
    }
    return f_3;
}

__device__ float3  skyBSDF(float3  in_dir_5, float3  dir_4, FKSurface surface_2, float2  eta_2, bool is_inside_3, float pdf_1, uint random_state_6)
{
    FKSurface _S653 = surface_2;
    FixedArray<float3 , 5>  terms_1;
    FixedArray<float, 5>  pdfs_2;
    float3  _S654 = skyLobes_0(in_dir_5, dir_4, &_S653, eta_2, is_inside_3, pdf_1, random_state_6, &terms_1, &pdfs_2);
    return _S654;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_5, float3  radiance_0, float3  color_0, uint random_state_7)
{
    SkySample _S655;
    (&_S655)->dir = dir_5;
    (&_S655)->radiance = radiance_0;
    (&_S655)->color = color_0;
    (&_S655)->random_state = random_state_7;
    return _S655;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_3, float2  eta_3, bool is_inside_4, uint init_random_state_0, uint lobe_state_0, ShadowContext * context_2)
{
    uint2  _S656 = (fcptEnvironmentCdfSize());
    uint2  _S657 = make_uint2 (1U, 0U);
    uint2  _S658 = _S656 - _S657;
    Random _S659 = pcg(init_random_state_0);
    Random _S660 = pcg(_S659.state);
    Random _S661 = pcg(_S660.state);
    Random _S662 = pcg(_S661.state);
    uint _S663 = _S658.x;
    uint _S664 = searchCDF_0(make_uint2 (_S663, 0U), make_uint2 (0U, 1U), _S658.y, _S659.value);
    uint _S665 = searchCDF_0(make_uint2 (0U, _S664), _S657, _S663, _S660.value);
    float2  _S666 = make_float2 ((float)_S658.x, (float)_S658.y);
    float2  _S667 = (make_float2 (float(_S665), float(_S664)) + make_float2 (_S661.value, _S662.value)) / _S666 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S668 = _S667.y;
    float _S669 = (F32_sin((_S668)));
    float _S670 = _S667.x;
    float3  _S671 = make_float3 (- _S669 * (F32_cos((_S670))), _S669 * (F32_sin((_S670))), (F32_cos((_S668))));
    float _S672 = environmentPdf_0(_S671);
    float3  _S673 = skyBSDF(ray_0->unit_direction, _S671, *surface_3, eta_3, is_inside_4, _S672, lobe_state_0);
    bool _S674 = !(_S672 > 0.0f);
    bool _S675;
    if(_S674)
    {
        _S675 = true;
    }
    else
    {
        _S675 = all_1(_S673 == make_float3 (0.0f));
    }
    if(_S675)
    {
        float3  _S676 = make_float3 (0.0f);
        return SkySample_x24init_0(_S671, _S676, _S676, _S662.state);
    }
    float3  _S677 = skyRadiance_0(ray_0->origin, surface_3, is_inside_4, _S671, context_2, _S662.state);
    return SkySample_x24init_0(_S671, _S677, _S673 * _S677, _S662.state);
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

static __device__ float3  hairLight_0(FKSurface * surface_4, float3  in_dir_6, TreeSample * light_1, bool competing_0)
{
    SampleBSDF _S678 = (fcptConnectHair((surface_4->hair), ((&surface_4->material)->albedo), ((&surface_4->material)->specular_tint), (in_dir_6), (light_1->dir)));
    float3  _S679 = _S678.throughput * make_float3 (_S678.pdf);
    float _S680 = light_1->density;
    float _S681 = 1.0f + _S678.pdf * _S678.pdf / (light_1->density * light_1->density);
    bool _S682;
    if(competing_0)
    {
        _S682 = _S680 > 0.0f;
    }
    else
    {
        _S682 = false;
    }
    float _S683 = _slang_select(_S682, _S681,1.0f);
    return _S679 / make_float3 (_S683) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_6, float3  radiance_1, float density_0, uint random_state_8)
{
    TreeSample _S684;
    (&_S684)->dir = dir_6;
    (&_S684)->radiance = radiance_1;
    (&_S684)->density = density_0;
    (&_S684)->random_state = random_state_8;
    return _S684;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_12, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S685 = importance(first_1, p_12, normal_3);
    float _S686 = importance(second_1, p_12, normal_3);
    float2  _S687 = make_float2 (_S685, _S686);
    bool _S688 = _S685 == 0.0f;
    bool _S689;
    if(_S688)
    {
        _S689 = _S686 == 0.0f;
    }
    else
    {
        _S689 = false;
    }
    if(_S689)
    {
        return 2U;
    }
    float _S690 = _S685 + _S686;
    bool _S691 = _S686 > 0.0f;
    if(_S691)
    {
        _S689 = (*pick_0 * _S690) >= _S685;
    }
    else
    {
        _S689 = false;
    }
    uint _S692 = uint(_S689);
    float _S693 = (F32_min(((*pick_0 * _S690 - float(_S692) * _S685) / _slang_vector_get_element(_S687, _S692)), (0.99999994039535522f)));
    *pick_0 = _S693;
    float _S694 = *probability_3 * (_slang_vector_get_element(_S687, _S692) / _S690);
    *probability_3 = _S694;
    return _S692;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_13, float u1_0, float u2_0)
{
    float3  _S695 = center_1 - p_13;
    float _S696 = radius_1 * radius_1 / dot_0(_S695, _S695);
    float _S697 = u1_0 * _S696 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S696), (0.0f)))))));
    float _S698 = 2.0f * u1_0;
    bool _S699 = _S696 >= 1.0f;
    float _S700 = _slang_select(_S699, _S698,_S697);
    float _S701 = (F32_sqrt(((F32_max((_S700 * (2.0f - _S700)), (0.0f))))));
    float _S702 = 6.28318548202514648f * u2_0;
    float3  _S703 = make_float3 (_S701 * (F32_cos((_S702))), 1.0f - _S700, _S701 * (F32_sin((_S702))));
    float3  _S704 = ((((_S695)) * make_float3(rnorm3df(((_S695)).x, ((_S695)).y, ((_S695)).z))));
    float3  _S705 = tangentToWorld(_S703, _S704);
    return _S705;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S706 = center_2 - ray_1->origin;
    float _S707 = dot_0(_S706, ray_1->unit_direction);
    float _S708 = dot_0(_S706, _S706) - _S707 * _S707;
    float _S709 = radius_3 * radius_3;
    bool _S710 = _S708 > _S709;
    if(_S710)
    {
        return 4.294967296e+09f;
    }
    float _S711 = (F32_sqrt((_S709 - _S708)));
    float _S712 = _S707 - _S711;
    float _S713 = _S707 + _S711;
    bool _S714 = _S712 > 0.0000152587890625f;
    bool _S715;
    if(_S714)
    {
        _S715 = _S712 < max_len_0;
    }
    else
    {
        _S715 = false;
    }
    if(_S715)
    {
        return _S712;
    }
    bool _S716 = _S713 > 0.0000152587890625f;
    if(_S716)
    {
        _S715 = _S713 < max_len_0;
    }
    else
    {
        _S715 = false;
    }
    if(_S715)
    {
        return _S713;
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
    Random _S717 = pcg(init_random_state_1);
    Random _S718 = pcg(_S717.state);
    Random _S719 = pcg(_S718.state);
    float3  _S720 = make_float3 (0.0f);
    TreeSample _S721 = TreeSample_x24init_0(_S720, _S720, 0.0f, _S719.state);
    TreeSample sample_0 = _S721;
    float3  _S722 = _slang_select(sided_0, _S720,smooth_n_2);
    float3  _S723 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S717.value;
    float probability_4 = 1.0f;
    uint n_7 = 0U;
    for(;;)
    {
        uint4  _S724 = (fcptLightNode((n_7)));
        if((_S724.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S725 = (fcptLightSecond((n_7)));
        uint _S726 = n_7 + 1U;
        LightNode _S727 = (fcptLightBounds((_S726)));
        LightNode _S728 = (fcptLightBounds((_S725)));
        uint _S729 = pickChild(_S727, _S728, origin_4, _S722, &pick_1, &probability_4);
        bool _S730 = _S729 > 1U;
        if(_S730)
        {
            return sample_0;
        }
        bool _S731 = _S729 == 1U;
        uint _S732 = _slang_select(_S731, _S725,_S726);
        n_7 = _S732;
    }
    bool _S733 = n_7 == 0U;
    bool _S734;
    if(_S733)
    {
        LightNode _S735 = (fcptLightBounds((0U)));
        float _S736 = importance(_S735, origin_4, _S722);
        _S734 = !(_S736 > 0.0f);
    }
    else
    {
        _S734 = false;
    }
    if(_S734)
    {
        return sample_0;
    }
    uint4  _S737 = (fcptLightNode((n_7)));
    FKHit _S738 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S739 = (_S737.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S739)
    {
        FKLight _S740 = (fcptLight((_S737.y)));
        if(sided_0)
        {
            float _S741 = sign_0(dot_0(geometry_n_1, _S740.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S741);
            float3  _S742 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S742;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S723;
            lift_n_0 = smooth_n_2;
        }
        bool _S743 = (_S740.variance) == 0.0f;
        if(_S743)
        {
            float3  _S744 = _S740.position - emitter_point_0;
            float3  _S745 = ((((_S744)) * make_float3(rnorm3df(((_S744)).x, ((_S744)).y, ((_S744)).z))));
            (&sample_0)->dir = _S745;
            float3  _S746 = _S740.color * make_float3 (_S740.intensity) / make_float3 (dot_0(_S744, _S744) * probability_4);
            (&sample_0)->radiance = _S746;
            shadow_1 = _S744;
        }
        else
        {
            float3  _S747 = sampleSphere(_S740.position, _S740.variance, emitter_point_0, _S718.value, _S719.value);
            (&sample_0)->dir = _S747;
            float _S748 = sphereDensity(_S740.position, _S740.variance, emitter_point_0);
            float _S749 = probability_4 * _S748;
            (&sample_0)->density = _S749;
            float3  _S750 = pointLightRadiance(_S740.color, _S740.intensity, _S740.variance);
            float3  _S751 = _S750 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S751;
            FKRay _S752 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S753 = raySphere_0(_S740.position, _S740.variance, &_S752, 4.294967296e+09f);
            float3  _S754 = (&sample_0)->dir * make_float3 (_S753);
            shadow_1 = _S754;
        }
        emitter_0 = _S738;
        emitter_point_0 = _S720;
    }
    else
    {
        uint _S755 = _S737.y;
        uint _S756 = (fcptTriangleOffset((_S755)));
        uint _S757 = _S756 + _S737.z;
        Matrix<float, 3, 3>  _S758 = (fcptWorldTriangle((_S755), (_S757)));
        float _S759 = (F32_sqrt((_S718.value)));
        float2  _S760 = make_float2 (_S759 * (1.0f - _S719.value), _S759 * _S719.value);
        float3  _S761 = mul_0(make_float3 (1.0f - _S759, _S760.x, _S760.y), _S758);
        if(sided_0)
        {
            float _S762 = sign_0(dot_0(geometry_n_1, _S761 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S762);
            float3  _S763 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S763;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S764 = !((dot_0(smooth_n_2, _S761 - origin_4)) > 0.0f);
            if(_S764)
            {
                return sample_0;
            }
            emitter_point_0 = _S723;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S760, _S755, _S757, 0U, 0.0f);
        float3  _S765 = _S761 - emitter_point_0;
        float3  _S766 = ((((_S765)) * make_float3(rnorm3df(((_S765)).x, ((_S765)).y, ((_S765)).z))));
        (&sample_0)->dir = _S766;
        float _S767 = solidAngle(probability_4, cross_0(_S758.rows[int(1)] - _S758.rows[int(0)], _S758.rows[int(2)] - _S758.rows[int(0)]), _S765);
        (&sample_0)->density = _S767;
        bool _S768 = (fcptShadowFirst());
        bool _S769 = !_S768;
        if(_S769)
        {
            FKSurface _S770 = (fcptLightSurfaceAt((emitter_1), (_S761), (_S719.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S761 - origin_4))));
            (&sample_0)->random_state = _S770.random_state;
            float3  _S771 = _slang_select(_S770.skip, _S720,_S770.material.emissive);
            float3  _S772 = _S771 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S772;
        }
        shadow_1 = _S765;
        emitter_0 = emitter_1;
        emitter_point_0 = _S761;
    }
    FKHit _S773 = emitter_0;
    float3  _S774 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S719.state, &_S773);
    bool _S775 = (fcptShadowFirst());
    if(_S775)
    {
        _S734 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S734 = false;
    }
    if(_S734)
    {
        _S734 = !all_1(_S774 == _S720);
    }
    else
    {
        _S734 = false;
    }
    if(_S734)
    {
        FKSurface _S776 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S719.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S776.random_state;
        float3  _S777 = _slang_select(_S776.skip, _S720,_S776.material.emissive);
        float3  _S778 = _S777 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S778;
    }
    float3  _S779 = (&sample_0)->radiance * _S774;
    bool _S780 = all_1(_S774 == _S720);
    float3  _S781 = _slang_select(_S780, _S720,_S779);
    (&sample_0)->radiance = _S781;
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
    float _S782 = 1.0f / (1.0f + b_2 / a_8 * (b_2 / a_8));
    bool _S783 = b_2 > 0.0f;
    float _S784 = _slang_select(_S783, _S782,1.0f);
    return _S784;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S785 = vertex_0->none;
    if(_S785)
    {
        return 1.0f;
    }
    uint _S786 = (fcptLightSlot((*hit_1)));
    float _S787 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S786, light_point_1);
    float _S788 = powerHeuristic(vertex_0->pdf, _S787);
    return _S788;
}

static __device__ float3  environment_0(float3  dir_7, uint depth_0, uint lobe_0)
{
    uint2  _S789 = (fcptEnvironmentMapSize());
    bool _S790 = (_S789.x) > 1U;
    bool _S791;
    if(_S790)
    {
        uint2  _S792 = (fcptEnvironmentMapSize());
        _S791 = (_S792.y) > 1U;
    }
    else
    {
        _S791 = false;
    }
    if(_S791)
    {
        float3  _S793 = (fcptEnvMapSample((dir_7), (depth_0), (lobe_0)));
        return _S793;
    }
    float3  _S794 = (fcptAmbient());
    return _S794;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S795 = (fcptEnvironmentCdfSize());
    bool _S796 = (_S795.x) > 1U;
    bool _S797;
    if(_S796)
    {
        uint2  _S798 = (fcptEnvironmentCdfSize());
        _S797 = (_S798.y) > 1U;
    }
    else
    {
        _S797 = false;
    }
    bool _S799 = !_S797;
    if(_S799)
    {
        return false;
    }
    uint2  _S800 = (fcptEnvironmentMapSize());
    bool _S801 = (_S800.x) > 1U;
    if(_S801)
    {
        uint2  _S802 = (fcptEnvironmentMapSize());
        _S797 = (_S802.y) > 1U;
    }
    else
    {
        _S797 = false;
    }
    return _S797;
}

static __device__ float escapeWeight_0(float pdf_2, float3  dir_8)
{
    bool _S803 = pdf_2 <= 0.0f;
    bool _S804;
    if(_S803)
    {
        _S804 = true;
    }
    else
    {
        bool _S805 = environmentMapped_0();
        _S804 = !_S805;
    }
    if(_S804)
    {
        return 1.0f;
    }
    float _S806 = environmentPdf_0(dir_8);
    return pdf_2 / (pdf_2 + _S806);
}

static __device__ void restir_duplicates_0(uint3  global_invocation_id_1, uint3  local_invocation_id_0, uint local_invocation_index_3)
{
    uint2  _S807 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S808 = make_int2 ((int)_S807.x, (int)_S807.y);
    uint _S809 = previousSeed_0(_S808);
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
            uint _S810 = previousSeed_0(_S808 + make_int2 (x_16, y_5));
            bool _S811 = _S810 == _S809;
            uint _S812 = _slang_select(_S811, 1U,0U);
            uint count_3 = count_2 + _S812;
            int x_17 = x_16 + int(1);
            x_16 = x_17;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S813 = float(count_2 - 1U) / 288.0f;
    bool _S814 = _S809 != 0U;
    float _S815 = _slang_select(_S814, _S813,0.0f);
    fcptStoreDuplication((_S808), (make_uint4 ((F32_asuint((_S815))), 0U, 0U, 0U)));
    return;
}

static __device__ float3  abs_0(float3  x_18)
{
    float3  result_7;
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
        *_slang_vector_get_element_ptr(&result_7, i_14) = (F32_abs((_slang_vector_get_element(x_18, i_14))));
        i_14 = i_14 + int(1);
    }
    return result_7;
}

__device__ float resamplingTarget(float3  f_5)
{
    float _S816 = rgb_to_greyscale(abs_0(f_5));
    return _S816;
}

__device__ uint stream(uint seed_3, uint index_0)
{
    uint _S817 = hash(index_0);
    uint _S818 = hash(seed_3 ^ _S817);
    return _S818;
}

static __device__ float4  asfloat_0(uint4  x_19)
{
    float4  result_8;
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
        *_slang_vector_get_element_ptr(&result_8, i_15) = (U32_asfloat((_slang_vector_get_element(x_19, i_15))));
        i_15 = i_15 + int(1);
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
    float _S819 = resamplingTarget(weight_0);
    bool _S820 = _S819 > 0.0f;
    bool _S821;
    if(_S820)
    {
        _S821 = _S819 < 3.00000000549775576e+38f;
    }
    else
    {
        _S821 = false;
    }
    bool _S822 = !_S821;
    if(_S822)
    {
        return;
    }
    bool _S823 = sel_2->sums;
    if(_S823)
    {
        float3  _S824 = sel_2->color + weight_0;
        sel_2->color = _S824;
        return;
    }
    float _S825 = sel_2->w_sum + _S819;
    sel_2->w_sum = _S825;
    float3  _S826 = sel_2->color + weight_0;
    sel_2->color = _S826;
    Random _S827 = pcg(sel_2->random_state);
    sel_2->random_state = _S827.state;
    bool _S828 = (_S827.value * sel_2->w_sum) <= _S819;
    if(_S828)
    {
        sel_2->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_3;
    float3  _S829 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S829;
    float _S830 = r_3.jac * shifted_0.jac;
    (&candidate_1)->jac = _S830;
    offer(sel_3, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S831 = resamplingTarget((&r_4)->f);
    float _S832 = sel_4.w_sum / _S831;
    bool _S833 = _S831 > 0.0f;
    float _S834 = _slang_select(_S833, _S832,0.0f);
    (&r_4)->w = _S834;
    (&r_4)->c = c_1;
    return r_4;
}

static __device__ uint2  asuint_0(float2  x_20)
{
    uint2  result_9;
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
        *_slang_vector_get_element_ptr(&result_9, i_16) = (F32_asuint((_slang_vector_get_element(x_20, i_16))));
        i_16 = i_16 + int(1);
    }
    return result_9;
}

static __device__ void restir_spatial_0(uint3  global_invocation_id_2)
{
    uint2  _S835 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S836 = make_int2 ((int)_S835.x, (int)_S835.y);
    float3  _S837 = make_float3 (0.0f);
    FKHit _S838 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S839 = Domain_x24init_0(_S837, _S837, &_S838, 0.0f, 0.0f);
    Domain dom_4 = _S839;
    bool _S840 = (fcptCurrentDomain((_S836), (&dom_4)));
    bool _S841 = !_S840;
    if(_S841)
    {
        Reservoir _S842 = (Reservoir{});
        fcptStoreReservoirPrevious((_S836), (_S842), ((&dom_4)->hit));
        return;
    }
    Reservoir _S843 = (fcptLoadReservoirTemporal((_S836)));
    uint t_15 = 0U;
    float count_4 = 0.0f;
    float c_sum_1 = _S843.c;
    for(;;)
    {
        uint _S844 = (fcptRestirNeighbours());
        if(t_15 < _S844)
        {
        }
        else
        {
            break;
        }
        int2  _S845 = partner_0(_S836, t_15);
        Domain neighbor_0 = _S839;
        bool _S846 = (fcptCurrentDomain((_S845), (&neighbor_0)));
        if(_S846)
        {
            float count_5 = count_4 + 1.0f;
            uint4  _S847 = (fcptReservoirTemporal((_S845), (0U)));
            float c_sum_2 = c_sum_1 + (U32_asfloat((_S847.w)));
            count_4 = count_5;
            c_sum_1 = c_sum_2;
        }
        uint t_16 = t_15 + 1U;
        t_15 = t_16;
    }
    float _S848 = _S843.c / (F32_max((count_4), (1.0f)));
    float _S849 = resamplingTarget(_S843.f);
    bool _S850 = count_4 == 0.0f;
    float _S851 = _slang_select(_S850, 1.0f,0.0f);
    Selection _S852 = (Selection{});
    Selection sel_5 = _S852;
    uint _S853 = (fcptFrame());
    uint _S854 = hash(_S853);
    uint _S855 = global_invocation_id_2.x;
    uint2  _S856 = (fcptRenderSize());
    uint _S857 = stream(_S854, _S855 + _S856.x * global_invocation_id_2.y);
    uint _S858 = stream(_S857, 195U);
    (&sel_5)->random_state = _S858;
    t_15 = 0U;
    float canonical_mis_0 = _S851;
    for(;;)
    {
        uint _S859 = (fcptRestirNeighbours());
        if(t_15 < _S859)
        {
        }
        else
        {
            break;
        }
        int2  _S860 = partner_0(_S836, t_15);
        Domain neighbor_dom_0 = _S839;
        bool _S861 = (fcptCurrentDomain((_S860), (&neighbor_dom_0)));
        if(_S861)
        {
            Reservoir _S862 = (fcptLoadReservoirTemporal((_S860)));
            uint4  _S863 = (fcptShiftData((_S860), (t_15)));
            float4  _S864 = asfloat_0(_S863);
            uint4  _S865 = (fcptShiftData((_S836), (t_15)));
            float4  _S866 = asfloat_0(_S865);
            float _S867 = pairShare(_S862.c, _S848, c_sum_1);
            bool _S868 = _S849 > 0.0f;
            float canonical_mis_1;
            if(_S868)
            {
                float _S869 = resamplingTarget(float3 {_S866.x, _S866.y, _S866.z});
                float _S870 = canonicalWeight(_S867, _S848, _S849, _S862.c, _S869);
                float canonical_mis_2 = canonical_mis_0 + _S870;
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float3  _S871 = float3 {_S864.x, _S864.y, _S864.z};
            Shift _S872 = Shift_x24init_0(_S871, _S864.w);
            float _S873 = resamplingTarget(_S862.f);
            float _S874 = resamplingTarget(_S871);
            float _S875 = neighborWeight(_S867, _S862.c, _S873, _S848, _S874);
            offerShifted(&sel_5, _S862, _S872, _S875);
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_17 = t_15 + 1U;
        t_15 = t_17;
    }
    offerShifted(&sel_5, _S843, Shift_x24init_0(_S843.f, 1.0f), canonical_mis_0);
    Reservoir _S876 = finalize(sel_5, c_sum_1);
    fcptStoreReservoirPrevious((_S836), (_S876), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S836), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S836), (make_float4 ((&sel_5)->color.x, (&sel_5)->color.y, (&sel_5)->color.z, 0.0f)));
    return;
}

static __device__ uint3  asuint_1(float3  x_21)
{
    uint3  result_10;
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
        *_slang_vector_get_element_ptr(&result_10, i_17) = (F32_asuint((_slang_vector_get_element(x_21, i_17))));
        i_17 = i_17 + int(1);
    }
    return result_10;
}

static __device__ void restir_shift_0(uint3  workgroup_id_1, uint local_invocation_index_4)
{
    uint _S877 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S878 = _S877 != 4294967295U;
    if(_S878)
    {
        uint2  _S879 = make_uint2 (_S877, _S877 >> 14U) & make_uint2 (16383U);
        int2  _S880 = make_int2 ((int)_S879.x, (int)_S879.y);
        ShiftJob _S881 = (ShiftJob{});
        ShiftJob shift_job_0 = _S881;
        Shift _S882 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S883 = _S877 >> 28U;
        bool _S884 = spatialJob_0(_S880, _S883, &shift_job_0, true);
        Shift shifted_1;
        if(_S884)
        {
            Domain _S885 = (&shift_job_0)->dom;
            Reservoir _S886 = (&shift_job_0)->r;
            Shift _S887 = passShift_0(&_S885, &_S886);
            shifted_1 = _S887;
        }
        else
        {
            shifted_1 = _S882;
        }
        fcptStoreShiftData((_S880), (_S883), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S888 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S889 = make_int2 ((int)_S888.x, (int)_S888.y);
    FixedArray<uint, 3>  _S890;
    spatialBins_0(_S889, &_S890);
    FixedArray<uint, 3>  _S891 = _S890;
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
        bool _S892 = (_S891[t_18]) == 40U;
        if(_S892)
        {
            fcptStoreShiftData((_S889), (t_18), (make_uint4 (0U)));
        }
        uint t_19 = t_18 + 1U;
        t_18 = t_19;
    }
    FixedArray<uint, 3>  _S893 = _S891;
    queueShifts_0(_S889, &_S893, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S894 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S895 = make_int2 ((int)_S894.x, (int)_S894.y);
    FixedArray<uint, 3>  _S896;
    spatialBins_0(_S895, &_S896);
    FixedArray<uint, 3>  _S897 = _S896;
    countShifts_0(&_S897, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S898 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S899 = _S898 != 4294967295U;
    if(_S899)
    {
        uint2  _S900 = make_uint2 (_S898, _S898 >> 14U) & make_uint2 (16383U);
        int2  _S901 = make_int2 ((int)_S900.x, (int)_S900.y);
        int2  _S902 = (fcptLoadTemporalNeighbor((_S901)));
        uint _S903 = _S898 >> 28U;
        Shift _S904 = temporalShiftAt_0(_S901, _S902, _S903);
        fcptStoreTemporalShift((_S901), (_S903), (make_uint4 (asuint_1(_S904.f).x, asuint_1(_S904.f).y, asuint_1(_S904.f).z, (F32_asuint((_S904.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S905 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S906 = make_int2 ((int)_S905.x, (int)_S905.y);
    FixedArray<uint, 3>  _S907;
    temporalBins_0(_S906, &_S907);
    FixedArray<uint, 3>  _S908 = _S907;
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
        bool _S909 = (_S908[t_20]) == 40U;
        if(_S909)
        {
            fcptStoreTemporalShift((_S906), (t_20), (make_uint4 (0U)));
        }
        uint t_21 = t_20 + 1U;
        t_20 = t_21;
    }
    FixedArray<uint, 3>  _S910 = _S908;
    queueShifts_0(_S906, &_S910, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S911 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S912 = make_int2 ((int)_S911.x, (int)_S911.y);
    bool _S913 = (fcptSceneUnchanged());
    bool _S914 = !_S913;
    bool _S915;
    if(_S914)
    {
        uint2  _S916 = (fcptRenderSize());
        int2  _S917 = make_int2 ((int)_S916.x, (int)_S916.y);
        _S915 = all_0(_S912 < _S917);
    }
    else
    {
        _S915 = false;
    }
    if(_S915)
    {
        Reservoir _S918 = (fcptLoadReservoirInitial((_S912)));
        int2  _S919 = sampleNeighbor_0(_S912, _S918.seed);
        fcptStoreTemporalNeighbor((_S912), (_S919));
    }
    FixedArray<uint, 3>  _S920;
    temporalBins_0(_S912, &_S920);
    FixedArray<uint, 3>  _S921 = _S920;
    countShifts_0(&_S921, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_9, float b_3, float t_22)
{
    return a_9 + (b_3 - a_9) * t_22;
}

__device__ float confidenceCap(float duplicated_0)
{
    float _S922 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S922;
}

__device__ float2  temporalWeights(float c_2, float p_c_1, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S923 = c_2 * p_c_1;
    float _S924 = c_t_0 * p_t_0;
    return make_float2 (_S923 / (_S923 + c_t_0 * g_previous_0), _S924 / (_S924 + c_2 * g_current_0));
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S925 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S926 = make_int2 ((int)_S925.x, (int)_S925.y);
    float3  _S927 = make_float3 (0.0f);
    FKHit _S928 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S929 = Domain_x24init_0(_S927, _S927, &_S928, 0.0f, 0.0f);
    Domain dom_5 = _S929;
    bool _S930 = (fcptCurrentDomain((_S926), (&dom_5)));
    bool _S931 = !_S930;
    if(_S931)
    {
        Reservoir _S932 = (Reservoir{});
        fcptStoreReservoirTemporal((_S926), (_S932), ((&dom_5)->hit));
        return;
    }
    Reservoir _S933 = (fcptLoadReservoirInitial((_S926)));
    bool _S934 = (fcptTemporalQueued());
    bool _S935 = (fcptSceneUnchanged());
    bool _S936;
    if(_S935)
    {
        _S936 = true;
    }
    else
    {
        _S936 = !_S934;
    }
    int2  _S937;
    if(_S936)
    {
        int2  _S938 = sampleNeighbor_0(_S926, _S933.seed);
        _S937 = _S938;
    }
    else
    {
        int2  _S939 = (fcptLoadTemporalNeighbor((_S926)));
        _S937 = _S939;
    }
    bool _S940 = (_S937.x) >= int(0);
    Reservoir r_5;
    if(_S940)
    {
        Reservoir _S941 = (fcptLoadReservoirPrevious((_S937)));
        uint4  _S942 = (fcptDuplication((_S937)));
        float _S943 = (U32_asfloat((_S942.x)));
        uint _S944 = (fcptRestirDecorrelation());
        bool _S945 = _S944 == 1U;
        float _S946 = _slang_select(_S945, _S943,0.0f);
        float _S947 = confidenceCap(_S946);
        float _S948 = (F32_min((_S941.c), (_S947)));
        bool _S949 = (fcptSceneUnchanged());
        float4  _S950 = make_float4 (_S941.f.x, _S941.f.y, _S941.f.z, 1.0f);
        bool _S951 = !_S949;
        if(_S951)
        {
            _S936 = _S934;
        }
        else
        {
            _S936 = false;
        }
        float4  to_current_0;
        if(_S936)
        {
            uint4  _S952 = (fcptTemporalShift((_S926), (0U)));
            float4  _S953 = asfloat_0(_S952);
            to_current_0 = _S953;
        }
        else
        {
            if(_S951)
            {
                Shift _S954 = temporalShiftAt_0(_S926, _S937, 0U);
                float4  _S955 = make_float4 (_S954.f.x, _S954.f.y, _S954.f.z, _S954.jac);
                to_current_0 = _S955;
            }
            else
            {
                to_current_0 = _S950;
            }
        }
        Domain own_1 = _S929;
        if(_S949)
        {
            _S936 = true;
        }
        else
        {
            bool _S956 = (fcptPreviousScenes());
            bool _S957 = !_S956;
            if(_S957)
            {
                _S936 = (_S933.w) > 0.0f;
            }
            else
            {
                _S936 = false;
            }
            if(_S936)
            {
                bool _S958 = (fcptStoredDomainInitial((_S926), (_S933.seed), (&own_1)));
                _S936 = _S958;
            }
            else
            {
                _S936 = false;
            }
            if(_S936)
            {
                Domain _S959 = (fcptPreviousDomain((_S937), (_S933.seed)));
                Domain _S960 = _S959;
                Domain _S961 = own_1;
                bool _S962 = sameDomain_0(&_S960, &_S961);
                _S936 = _S962;
            }
            else
            {
                _S936 = false;
            }
        }
        float4  _S963 = make_float4 (_S933.f.x, _S933.f.y, _S933.f.z, 1.0f);
        bool _S964 = !_S936;
        if(_S964)
        {
            _S936 = _S934;
        }
        else
        {
            _S936 = false;
        }
        float4  to_previous_0;
        if(_S936)
        {
            uint4  _S965 = (fcptTemporalShift((_S926), (1U)));
            float4  _S966 = asfloat_0(_S965);
            to_previous_0 = _S966;
        }
        else
        {
            if(_S964)
            {
                Shift _S967 = temporalShiftAt_0(_S926, _S937, 1U);
                float4  _S968 = make_float4 (_S967.f.x, _S967.f.y, _S967.f.z, _S967.jac);
                to_previous_0 = _S968;
            }
            else
            {
                to_previous_0 = _S963;
            }
        }
        float _S969 = resamplingTarget(_S933.f);
        float _S970 = resamplingTarget(_S941.f);
        Selection _S971 = (Selection{});
        Selection sel_6 = _S971;
        uint _S972 = (fcptFrame());
        uint _S973 = hash(_S972);
        uint _S974 = global_invocation_id_7.x;
        uint2  _S975 = (fcptRenderSize());
        uint _S976 = stream(_S973, _S974 + _S975.x * global_invocation_id_7.y);
        uint _S977 = stream(_S976, 194U);
        (&sel_6)->random_state = _S977;
        float4  _S978 = to_previous_0;
        float _S979 = resamplingTarget(float3 {_S978.x, _S978.y, _S978.z});
        float4  _S980 = to_current_0;
        float3  _S981 = float3 {_S980.x, _S980.y, _S980.z};
        float _S982 = resamplingTarget(_S981);
        float2  _S983 = temporalWeights(_S933.c, _S969, _S948, _S970, _S979, _S982);
        offerShifted(&sel_6, _S933, Shift_x24init_0(_S933.f, 1.0f), _S983.x);
        offerShifted(&sel_6, _S941, Shift_x24init_0(_S981, to_current_0.w), _S983.y);
        Reservoir _S984 = finalize(sel_6, _S933.c + _S948);
        r_5 = _S984;
    }
    else
    {
        r_5 = _S933;
    }
    fcptStoreReservoirTemporal((_S926), (r_5), ((&dom_5)->hit));
    return;
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S985 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S986 = make_int2 ((int)_S985.x, (int)_S985.y);
    float3  _S987 = make_float3 (0.0f);
    float2  _S988 = make_float2 (0.0f);
    FKHit _S989 = Hit_x24init_0(_S988, 0U, 0U, 0U, 0.0f);
    Domain _S990 = Domain_x24init_0(_S987, _S987, &_S989, 0.0f, 0.0f);
    Domain dom_6 = _S990;
    bool _S991 = (fcptCurrentDomain((_S986), (&dom_6)));
    bool _S992 = !_S991;
    if(_S992)
    {
        Reservoir _S993 = (Reservoir{});
        fcptStoreReservoirInitial((_S986), (_S993), ((&dom_6)->hit));
        return;
    }
    uint _S994 = (fcptFrame());
    uint _S995 = hash(_S994);
    uint _S996 = global_invocation_id_8.x;
    uint2  _S997 = (fcptRenderSize());
    uint _S998 = stream(_S995, _S996 + _S997.x * global_invocation_id_8.y);
    Selection _S999 = (Selection{});
    Selection initial_0 = _S999;
    uint _S1000 = stream(_S998, 193U);
    (&initial_0)->random_state = _S1000;
    bool _S1001 = (fcptRestirUsed());
    bool _S1002 = !_S1001;
    (&initial_0)->sums = _S1002;
    uint _S1003 = stream(_S998, 0U);
    (&(&initial_0)->r)->seed = _S1003;
    FKHit _S1004 = Hit_x24init_0(_S988, 4294967295U, 0U, 0U, 0.0f);
    uint _S1005 = (fcptSamples());
    float _S1006 = 1.0f / float(_S1005);
    FKHit hit_2 = _S1004;
    uint i_18 = 0U;
    float3  seen_0 = _S987;
    for(;;)
    {
        uint _S1007 = (fcptSamples());
        if(i_18 < _S1007)
        {
        }
        else
        {
            break;
        }
        Reservoir _S1008 = (Reservoir{});
        Reservoir r_6 = _S1008;
        uint _S1009 = stream(_S998, i_18);
        (&r_6)->seed = _S1009;
        Domain path_0 = _S990;
        bool _S1010 = (fcptStoredDomainInitial((_S986), ((&r_6)->seed), (&path_0)));
        bool _S1011 = !_S1010;
        if(_S1011)
        {
            float3  _S1012 = (fcptMissed((_S986), (path_0), (_S1006)));
            float3  seen_1 = seen_0 + _S1012;
            seen_0 = seen_1;
            uint i_19 = i_18 + 1U;
            i_18 = i_19;
            continue;
        }
        Domain _S1013 = path_0;
        Reservoir _S1014 = r_6;
        Shift _S1015 = passWalk_0(&_S1013, &_S1014, false, _S1006, &initial_0);
        bool _S1016 = ((&(&initial_0)->r)->seed) == ((&r_6)->seed);
        FKHit hit_3;
        if(_S1016)
        {
            FKHit _S1017 = (&path_0)->hit;
            hit_3 = _S1017;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_19 = i_18 + 1U;
        i_18 = i_19;
    }
    uint _S1018 = (fcptSamples());
    float3  seen_2 = seen_0 + (&initial_0)->glow / make_float3 (float(_S1018));
    if((&initial_0)->sums)
    {
        seen_0 = seen_2 + (&initial_0)->color;
    }
    else
    {
        seen_0 = seen_2;
    }
    fcptAddColor((_S986), (make_float4 (seen_0.x, seen_0.y, seen_0.z, 1.0f)));
    Reservoir _S1019 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S986), (_S1019), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_3, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S1020;
    (&_S1020)->none = none_0;
    (&_S1020)->pdf = pdf_3;
    (&_S1020)->origin = origin_5;
    (&_S1020)->smooth_n = smooth_n_3;
    (&_S1020)->start = start_6;
    return _S1020;
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
    Vertex _S1021;
    (&_S1021)->rough = rough_0;
    (&_S1021)->lobe = lobe_1;
    (&_S1021)->pdf = pdf_4;
    (&_S1021)->cos = cos_0;
    (&_S1021)->inside = inside_0;
    return _S1021;
}

static __device__ float freeFlight_0(float u_1, float sigma_0)
{
    return - (F32_log((1.0f - u_1))) / sigma_0;
}

static __device__ float3  exp_0(float3  x_22)
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
        *_slang_vector_get_element_ptr(&result_11, i_20) = (F32_exp((_slang_vector_get_element(x_22, i_20))));
        i_20 = i_20 + int(1);
    }
    return result_11;
}

static __device__ float3  flightWeight_0(float3  scatter_0, float3  extinction_0, float sigma_1, float distance_2, bool scatters_0)
{
    float3  _S1022 = exp_0((make_float3 (sigma_1) - extinction_0) * make_float3 (distance_2));
    float3  _S1023 = scatter_0 * _S1022 / make_float3 (sigma_1);
    float3  _S1024 = _slang_select(scatters_0, _S1023,_S1022);
    return _S1024;
}

static __device__ bool scatterSampled_0(bool replay_1, uint b_4, uint stop_0, bool varying_0)
{
    bool _S1025 = !replay_1;
    bool _S1026;
    if(_S1025)
    {
        _S1026 = true;
    }
    else
    {
        bool _S1027 = b_4 == stop_0;
        if(_S1027)
        {
            _S1026 = !varying_0;
        }
        else
        {
            _S1026 = false;
        }
    }
    return _S1026;
}

static __device__ uint arrivalLobe_0(uint b_5, uint prev_lobe_0)
{
    bool _S1028 = b_5 > 0U;
    uint _S1029 = _slang_select(_S1028, prev_lobe_0,3U);
    return _S1029;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_2, bool surface_5, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S1030;
    (&_S1030)->extinction_behind = extinction_behind_0;
    (&_S1030)->extinction_front = extinction_front_0;
    (&_S1030)->fillings = fillings_0;
    (&_S1030)->side = side_0;
    (&_S1030)->depth = depth_1;
    (&_S1030)->lobe = lobe_2;
    (&_S1030)->surface = surface_5;
    (&_S1030)->length = length_2;
    (&_S1030)->width = width_1;
    (&_S1030)->own = *own_2;
    (&_S1030)->fiber = fiber_0;
    return _S1030;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S1031 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S1031)
    {
        return 0.07957746833562851f;
    }
    float _S1032 = g_0 * g_0;
    return (1.0f - _S1032) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S1032 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_10, float3  b_6)
{
    float3  _S1033 = a_10 / b_6;
    float3  _S1034 = make_float3 (0.0f);
    bool3  _S1035 = b_6 == _S1034;
    float3  _S1036 = _slang_select(_S1035, _S1034,_S1033);
    return _S1036;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_6)
{
    uint _S1037 = (1U << count_6) - 1U;
    return (e_2 & (~(_S1037 << offset_1))) | ((newbits_0 & _S1037) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_7, uint end_type_0, uint end_0, float3  f_6)
{
    Reservoir candidate_2 = r_7;
    uint _S1038 = insertBits_0(r_7.path, end_0, 0U, 5U);
    uint _S1039 = insertBits_0(_S1038, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S1039;
    (&candidate_2)->f = f_6;
    return candidate_2;
}

__device__ float survivalProbability(float3  throughput_0, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_0.x), ((F32_max((throughput_0.y), (throughput_0.z)))))) / density_1), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_9)
{
    Random _S1040 = pcg(random_state_9);
    Random _S1041 = pcg(_S1040.state);
    float _S1042 = 1.0f - 2.0f * _S1040.value;
    float _S1043 = (F32_sqrt(((F32_max((1.0f - _S1042 * _S1042), (0.0f))))));
    float _S1044 = 6.28318548202514648f * _S1041.value;
    return make_float3 (_S1043 * (F32_cos((_S1044))), _S1043 * (F32_sin((_S1044))), _S1042);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_9, uint random_state_10, float * pdf_5)
{
    bool _S1045 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1045)
    {
        *pdf_5 = 0.07957746833562851f;
        float3  _S1046 = isotropic_0(random_state_10);
        return _S1046;
    }
    Random _S1047 = pcg(random_state_10);
    Random _S1048 = pcg(_S1047.state);
    float _S1049 = g_1 * g_1;
    float _S1050 = 2.0f * g_1;
    float _S1051 = (1.0f - _S1049) / (1.0f - g_1 + _S1050 * _S1047.value);
    float _S1052 = clamp_1((1.0f + _S1049 - _S1051 * _S1051) / _S1050, -1.0f, 1.0f);
    float _S1053 = (F32_sqrt(((F32_max((1.0f - _S1052 * _S1052), (0.0f))))));
    float _S1054 = 6.28318548202514648f * _S1048.value;
    float _S1055 = phaseHG_0(g_1, _S1052);
    *pdf_5 = _S1055;
    float3  _S1056 = tangentToWorld(make_float3 (_S1053 * (F32_cos((_S1054))), _S1052, _S1053 * (F32_sin((_S1054)))), dir_9);
    float3  _S1057 = ((((_S1056)) * make_float3(rnorm3df(((_S1056)).x, ((_S1056)).y, ((_S1056)).z))));
    return _S1057;
}

static __device__ Vertex scatteredVertex_0(bool is_inside_5)
{
    return Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_5);
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_1, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_1, float velvet_0, float3  toon_2, float dispersion_0)
{
    BSDFMaterial _S1058;
    (&_S1058)->albedo = albedo_1;
    (&_S1058)->emissive = emissive_0;
    (&_S1058)->roughness = roughness_0;
    (&_S1058)->metallic = metallic_0;
    (&_S1058)->transmission = transmission_0;
    (&_S1058)->ior = ior_0;
    (&_S1058)->absorption = absorption_0;
    (&_S1058)->specular_tint = specular_tint_0;
    (&_S1058)->specular_level = specular_level_0;
    (&_S1058)->translucent = translucent_0;
    (&_S1058)->sheen = sheen_2;
    (&_S1058)->sheen_roughness = sheen_roughness_0;
    (&_S1058)->anisotropy = anisotropy_0;
    (&_S1058)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1058)->tangent = tangent_1;
    (&_S1058)->velvet = velvet_0;
    (&_S1058)->toon = toon_2;
    (&_S1058)->dispersion = dispersion_0;
    return _S1058;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1059;
    (&_S1059)->scatter = scatter_1;
    (&_S1059)->extinction = extinction_1;
    (&_S1059)->g = g_2;
    return _S1059;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_10, bool skip_0, uint random_state_11, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1060;
    (&_S1060)->smooth_n = smooth_n_4;
    (&_S1060)->geometry_n = geometry_n_2;
    (&_S1060)->geometry_offset = geometry_offset_2;
    (&_S1060)->material = *material_10;
    (&_S1060)->skip = skip_0;
    (&_S1060)->random_state = random_state_11;
    (&_S1060)->coverage = coverage_0;
    (&_S1060)->encloses = encloses_0;
    (&_S1060)->volume = *volume_0;
    (&_S1060)->fills = fills_0;
    (&_S1060)->hair = hair_0;
    return _S1060;
}

static __device__ FKSurface emitting_0(FKSurface * surface_6, bool top_0)
{
    FKSurface lower_0 = *surface_6;
    float3  _S1061 = (&surface_6->material)->emissive;
    float3  _S1062 = make_float3 (0.0f);
    bool _S1063 = !top_0;
    float3  _S1064 = _slang_select(_S1063, _S1062,_S1061);
    (&(&lower_0)->material)->emissive = _S1064;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_7, float u_2)
{
    float _S1065 = surface_7->coverage;
    bool _S1066 = u_2 < _S1065;
    if(_S1066)
    {
        return *surface_7;
    }
    float3  _S1067 = make_float3 (0.0f);
    float3  _S1068 = make_float3 (1.0f);
    BSDFMaterial _S1069 = Material_x24init_0(_S1067, _S1067, 0.0f, 0.0f, 0.0f, 0.0f, _S1067, _S1068, 1.0f, _S1067, _S1067, 0.5f, 0.0f, 0.0f, _S1067, 0.0f, _S1067, 0.0f);
    BSDFMaterial material_11 = _S1069;
    (&material_11)->albedo = _S1068;
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
    bool _S1070 = transmission_1 > 0.0f;
    bool _S1071;
    if(_S1070)
    {
        _S1071 = true;
    }
    else
    {
        _S1071 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1072;
    if(_S1071)
    {
        _S1072 = 1.0f;
    }
    else
    {
        _S1072 = -1.0f;
    }
    return _S1072;
}

static __device__ bool arrivesBehind_0(float3  dir_10, float3  n_8)
{
    return (dot_0(dir_10, n_8)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_8, float3  dir_11)
{
    float3  _S1073 = surface_8->geometry_n;
    float _S1074 = facingSign((&surface_8->material)->transmission, surface_8->geometry_n, dir_11);
    FKSurface faced_0 = *surface_8;
    float3  _S1075 = surface_8->smooth_n * make_float3 (_S1074);
    (&faced_0)->smooth_n = _S1075;
    float3  _S1076 = _S1073 * make_float3 (_S1074);
    (&faced_0)->geometry_n = _S1076;
    return faced_0;
}

static __device__ float3  max_0(float3  x_23, float3  y_7)
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
        *_slang_vector_get_element_ptr(&result_12, i_21) = (F32_max((_slang_vector_get_element(x_23, i_21)), (_slang_vector_get_element(y_7, i_21))));
        i_21 = i_21 + int(1);
    }
    return result_12;
}

static __device__ float3  log_0(float3  x_24)
{
    float3  result_13;
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
        *_slang_vector_get_element_ptr(&result_13, i_22) = (F32_log((_slang_vector_get_element(x_24, i_22))));
        i_22 = i_22 + int(1);
    }
    return result_13;
}

__device__ float3  beerLambert(float distance_3, float3  absorption_1)
{
    float3  _S1077 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1077));
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
    bool _S1078;
    if(open_0)
    {
        _S1078 = prev_rough_0;
    }
    else
    {
        _S1078 = false;
    }
    if(_S1078)
    {
        _S1078 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S1078 = false;
    }
    return _S1078;
}

__device__ bool dispersive(BSDFMaterial material_12)
{
    bool _S1079 = (material_12.dispersion) > 0.0f;
    bool _S1080;
    if(_S1079)
    {
        _S1080 = (material_12.ior) != 1.0f;
    }
    else
    {
        _S1080 = false;
    }
    return _S1080;
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
        uint _S1081 = (low_1 + high_1 + 1U) / 2U;
        bool _S1082 = (WAVELENGTH_CDF_0[_S1081]) <= u_3;
        if(_S1082)
        {
            low_1 = _S1081;
        }
        else
        {
            uint _S1083 = _S1081 - 1U;
            high_1 = _S1083;
        }
    }
    uint _S1084 = low_1;
    float _S1085 = WAVELENGTH_CDF_0[low_1 + 1U] - WAVELENGTH_CDF_0[low_1];
    return make_float2 (0.37999999523162842f + 0.00499999988824129f * (float(low_1) + (u_3 - WAVELENGTH_CDF_0[_S1084]) / _S1085), _S1085 / 0.00499999988824129f);
}

__device__ static const FixedArray<float, 243>  WAVELENGTH_WEIGHTS_0 = { {
    0.00547470012679696f, -0.00465690018609166f, 0.03257500007748604f, 0.00934640038758516f, -0.00796370021998882f, 0.05577300116419792f, 0.01846100017428398f, -0.01579399965703487f, 0.11072999984025955f, 0.0416410006582737f, -0.03577499836683273f, 0.2513900101184845f, 0.09349299967288971f, -0.08071800321340561f, 0.56742000579833984f, 0.1585099995136261f, -0.13764999806880951f, 0.97018998861312866f, 0.30943000316619873f, -0.27083000540733337f, 1.91740000247955322f, 0.55217999219894409f, -0.48754000663757324f, 3.46889996528625488f, 0.95016998052597046f, -0.84802001714706421f, 6.09439992904663086f, 1.42110002040863037f, -1.28929996490478516f, 9.45199966430664062f, 1.73409998416900635f, -1.6062999963760376f, 12.12800025939941406f, 2.08030009269714355f, -1.98810005187988281f, 15.68700027465820312f, 2.20600008964538574f, -2.20120000839233398f, 18.47699928283691406f, 2.03040003776550293f, -2.17700004577636719f, 19.92700004577636719f, 1.63429999351501465f, -2.00340008735656738f, 20.86899948120117188f, 0.99410998821258545f, -1.62629997730255127f, 20.57799911499023438f, 0.20011000335216522f, -1.11409997940063477f, 19.72100067138671875f, -0.67960000038146973f, -0.45403000712394714f, 17.77599906921386719f, -1.61679995059967041f, 0.37860000133514404f, 14.71500015258789062f, -2.53410005569458008f, 1.27540004253387451f, 11.86499977111816406f, -3.39079999923706055f, 2.2146000862121582f, 9.17669963836669922f, -4.03749990463256836f, 3.0522000789642334f, 6.59509992599487305f, -4.61299991607666016f, 3.89779996871948242f, 4.64589977264404297f, -5.43039989471435547f, 5.0121002197265625f, 3.3199000358581543f, -6.37769985198974609f, 6.33809995651245117f, 2.29699993133544922f, -7.44140005111694336f, 7.91739988327026367f, 1.45389997959136963f, -8.38580036163330078f, 9.60109996795654297f, 0.66465997695922852f, -9.0167999267578125f, 11.23999977111816406f, -0.04403600096702576f, -9.17749977111816406f, 12.63199996948242188f, -0.58126997947692871f, -8.97550010681152344f, 13.91499996185302734f, -0.95730000734329224f, -8.25290012359619141f, 14.86200046539306641f, -1.24430000782012939f, -6.92129993438720703f, 15.03899955749511719f, -1.43069994449615479f, -5.29169988632202148f, 14.90900039672851562f, -1.55149996280670166f, -3.43219995498657227f, 14.70499992370605469f, -1.63569998741149902f, -1.27190005779266357f, 14.24400043487548828f, -1.67030000686645508f, 1.15170001983642578f, 13.32199954986572266f, -1.636199951171875f, 3.73889994621276855f, 12.21199989318847656f, -1.56920003890991211f, 6.43590021133422852f, 10.94699954986572266f, -1.47730004787445068f, 9.16440010070800781f, 9.54769992828369141f, -1.36399996280670166f, 12.02000045776367188f, 8.18799972534179688f, -1.25450003147125244f, 14.78699970245361328f, 6.74429988861083984f, -1.13110005855560303f, 16.72299957275390625f, 5.08780002593994141f, -0.96561002731323242f, 18.14299964904785156f, 3.57019996643066406f, -0.80725997686386108f, 19.91900062561035156f, 2.36269998550415039f, -0.69273000955581665f, 21.05500030517578125f, 1.31369996070861816f, -0.58597999811172485f, 21.3899993896484375f, 0.42390000820159912f, -0.48298001289367676f, 20.99300003051757812f, -0.23857000470161438f, -0.39412000775337219f, 19.82200050354003906f, -0.6866300106048584f, -0.31501999497413635f, 18.12000083923339844f, -0.9412500262260437f, -0.24890999495983124f, 15.7089996337890625f, -1.02020001411437988f, -0.19076000154018402f, 13.19799995422363281f, -0.98919999599456787f, -0.14401000738143921f, 11.23999977111816406f, -0.93347001075744629f, -0.11133000254631042f, 9.36649990081787109f, -0.83820998668670654f, -0.08524099737405777f, 7.41249990463256836f, -0.70064002275466919f, -0.06283199787139893f, 5.71229982376098633f, -0.56079000234603882f, -0.04586699977517128f, 4.42280006408691406f, -0.44653001427650452f, -0.03396600112318993f, 3.34489989280700684f, -0.34457001090049744f, -0.02482499927282333f, 2.49309992790222168f, -0.26017999649047852f, -0.01808100007474422f, 1.82239997386932373f, -0.1921599954366684f, -0.01296999957412481f, 1.29499995708465576f, -0.13766999542713165f, -0.00907570030540228f, 0.92928999662399292f, -0.09956400096416473f, -0.00641620019450784f, 0.61835998296737671f, -0.06671299785375595f, -0.00421149982139468f, 0.40211999416351318f, -0.04354599863290787f, -0.00271830009296536f, 0.2844499945640564f, -0.03087200038135052f, -0.00191440002527088f, 0.20672999322414398f, -0.02246100082993507f, -0.00138829997740686f, 0.15044000744819641f, -0.01634499989449978f, -0.00101030000951141f, 0.10942000150680542f, -0.01188699994236231f, -0.0007347899954766f, 0.07099699974060059f, -0.00771349994465709f, -0.00047679000999779f, 0.04539500176906586f, -0.00493190018460155f, -0.00030484999297187f, 0.03424099832773209f, -0.00372010003775358f, -0.00022995000472292f, 0.02557599917054176f, -0.00277870008721948f, -0.00017175999528263f, 0.01842200011014938f, -0.00200140010565519f, -0.0001237099932041f, 0.01316899992525578f, -0.00143079995177686f, -0.00008843900286593f, 0.00838890019804239f, -0.00091141002485529f, -0.00005633700129692f, 0.00537079991772771f, -0.00058350997278467f, -0.00003606799873523f, 0.00328280008397996f, -0.00035665999166667f, -0.00002204600059486f, 0.00196009990759194f, -0.00021296000340953f, -0.00001316300040344f, 0.00168939994182438f, -0.00018354000349063f, -0.00001134499962063f, 0.00141050003003329f, -0.00015325000276789f, -0.00000947250009631f, 0.00097123999148607f, -0.00010551999730524f, -6.52239987175562419e-06f, 0.00066868000430986f, -0.00007264900341397f, -4.49060007667867467e-06f
} };
__device__ float3  wavelengthWeights(float wavelength_0)
{
    float _S1086 = clamp_1((wavelength_0 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    uint _S1087 = (U32_min((uint(_S1086)), (79U)));
    uint _S1088 = 3U * _S1087;
    float3  _S1089 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1088], WAVELENGTH_WEIGHTS_0[_S1088 + 1U], WAVELENGTH_WEIGHTS_0[_S1088 + 2U]);
    float3  _S1090 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1088 + 3U], WAVELENGTH_WEIGHTS_0[_S1088 + 4U], WAVELENGTH_WEIGHTS_0[_S1088 + 5U]);
    return _S1089 + (_S1090 - _S1089) * make_float3 (_S1086 - float(_S1087));
}

__device__ float dispersedIor(float ior_1, float dispersion_1, float wavelength_1)
{
    float _S1091 = (ior_1 - 1.0f) * dispersion_1 / 1.90962409973144531f;
    float _S1092 = _S1091 * (1.0f / (wavelength_1 * wavelength_1) - 2.89662933349609375f);
    bool _S1093 = dispersion_1 > 0.0f;
    float _S1094 = _slang_select(_S1093, _S1092,0.0f);
    return ior_1 + _S1094;
}

__device__ float2  vertexEta(BSDFMaterial material_13, float n_dot_v_0)
{
    bool _S1095 = n_dot_v_0 < 0.0f;
    float _S1096 = _slang_select(_S1095, material_13.ior,1.0f);
    float _S1097 = _slang_select(_S1095, 1.0f,material_13.ior);
    return make_float2 (_S1096, _S1097);
}

__device__ bool neeDecision(BSDFMaterial material_14, float n_dot_v_1, float eta_i_5, float eta_o_5)
{
    float _S1098 = fresnel((F32_abs((n_dot_v_1))), eta_i_5, eta_o_5);
    float3  _S1099 = mix_0(make_float3 (_S1098), material_14.albedo, material_14.metallic);
    float _S1100 = rgb_to_greyscale(_S1099);
    float _S1101 = (F32_max(((1.0f - _S1100) * (1.0f - material_14.metallic) * (1.0f - material_14.transmission)), (0.0f)));
    bool _S1102 = _S1101 > 0.03999999910593033f;
    bool _S1103;
    if(_S1102)
    {
        _S1103 = true;
    }
    else
    {
        _S1103 = (material_14.roughness) > 0.20000000298023224f;
    }
    return _S1103;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_15)
{
    float _S1104 = rgb_to_greyscale(material_15->translucent);
    return _S1104 > 0.0f;
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
    MediumSides _S1105;
    (&_S1105)->behind = *behind_0;
    (&_S1105)->front = *front_0;
    (&_S1105)->fillings = fillings_1;
    (&_S1105)->face = face_1;
    return _S1105;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_9, FKMedium * medium_0, uint filling_0, float3  dir_12, FKMedium * outside_0)
{
    float3  _S1106 = surface_9->geometry_n;
    MediumSides _S1107 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_9->geometry_n);
    MediumSides sides_0 = _S1107;
    bool _S1108 = surface_9->encloses;
    if(_S1108)
    {
        (&sides_0)->behind = surface_9->volume;
        *&((&(&sides_0)->fillings)->x) = surface_9->fills;
        bool _S1109 = (dot_0(dir_12, _S1106)) > 0.0f;
        if(_S1109)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_10, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_13, uint depth_2, uint lobe_3, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1110 = surface_10->geometry_n;
    ShadowContext _S1111 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_10->geometry_n, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
    bool _S1112 = surface_10->encloses;
    ShadowContext context_4;
    if(_S1112)
    {
        FKSurface faced_1 = *surface_10;
        float3  _S1113 = - _S1110;
        float3  _S1114 = _slang_select(turned_0, _S1113,_S1110);
        (&faced_1)->geometry_n = _S1114;
        FKMedium _S1115 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1116 = faced_1;
        FKMedium _S1117 = _S1115;
        MediumSides _S1118 = mediumSides_0(&_S1116, &_S1117, filling_1, dir_13, outside_1);
        ShadowContext _S1119 = ShadowContext_x24init_0(_S1118.behind.extinction, _S1118.front.extinction, _S1118.fillings, _S1110, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
        if(turned_0)
        {
            uint2  _S1120 = _S1118.fillings;
            ShadowContext _S1121 = ShadowContext_x24init_0(_S1118.front.extinction, _S1118.behind.extinction, uint2 {_S1120.y, _S1120.x}, _S1110, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
            context_4 = _S1121;
        }
        else
        {
            context_4 = _S1119;
        }
    }
    else
    {
        context_4 = _S1111;
    }
    return context_4;
}

static __device__ bool any_1(bool3  x_25)
{
    bool result_14 = false;
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
        if(result_14)
        {
            result_14 = true;
        }
        else
        {
            result_14 = (bool((_slang_vector_get_element(x_25, i_23))));
        }
        i_23 = i_23 + int(1);
    }
    return result_14;
}

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_7, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_4, BSDFMaterial * material_16, float eta_i_6, float eta_o_6, bool competing_1, uint random_state_12)
{
    float3  _S1122 = light_2->dir;
    bool _S1123 = (dot_0(geometry_n_4, - in_dir_7) * dot_0(geometry_n_4, light_2->dir)) <= 0.0f;
    FixedArray<float3 , 5>  throughputs_1;
    FixedArray<float, 5>  pdfs_3;
    float3  _S1124 = BSDF(in_dir_7, _S1122, smooth_n_5, *material_16, eta_i_6, eta_o_6, _S1123, random_state_12, &throughputs_1, &pdfs_3);
    bool _S1125 = !competing_1;
    bool _S1126;
    if(_S1125)
    {
        _S1126 = true;
    }
    else
    {
        _S1126 = (light_2->density) == 0.0f;
    }
    if(_S1126)
    {
        return _S1124 * light_2->radiance;
    }
    float3  _S1127 = make_float3 (0.0f);
    uint i_24 = 0U;
    float3  weighted_0 = _S1127;
    for(;;)
    {
        if(i_24 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S1128 = (pdfs_3[i_24]) > 0.0f;
        if(_S1128)
        {
            float _S1129 = light_2->density;
            float _S1130 = pdfs_3[i_24] / light_2->density;
            float3  weighted_1 = weighted_0 + throughputs_1[i_24] * make_float3 (pdfs_3[i_24]) / make_float3 (_S1129 * (1.0f + _S1130 * _S1130));
            weighted_0 = weighted_1;
        }
        uint i_25 = i_24 + 1U;
        i_24 = i_25;
    }
    return weighted_0 * light_2->radiance * make_float3 (light_2->density);
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_1, uint random_state_13, bool refracted_3, uint lobe_4, float pdf_6)
{
    SampleBSDF _S1131;
    (&_S1131)->unit_direction = unit_direction_1;
    (&_S1131)->throughput = throughput_1;
    (&_S1131)->random_state = random_state_13;
    (&_S1131)->refracted = refracted_3;
    (&_S1131)->lobe = lobe_4;
    (&_S1131)->pdf = pdf_6;
    return _S1131;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  v_9, float3  n_i_13, float n_i_dot_v_3, BSDFMaterial material_17, Weights w_14, uint random_state_14)
{
    float3  _S1132 = make_float3 (1.0f);
    SampleBSDF _S1133 = SampleBSDF_x24init_0(_S1132, _S1132, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S1133;
    Random _S1134 = pcg(random_state_14);
    Random _S1135 = pcg(_S1134.state);
    (&sample_1)->random_state = _S1135.state;
    float _S1136 = _S1134.value;
    float _S1137 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1136 * _S1136))))));
    float _S1138 = 6.28318548202514648f * _S1135.value;
    float3  _S1139 = tangentToWorld(make_float3 (_S1137 * (F32_cos((_S1138))), _S1134.value, _S1137 * (F32_sin((_S1138)))), n_i_13);
    (&sample_1)->unit_direction = _S1139;
    (&sample_1)->lobe = 4U;
    float3  _S1140 = sheenVelvetBSDF((&sample_1)->unit_direction, v_9, n_i_13, material_17, w_14);
    (&sample_1)->throughput = _S1140;
    float _S1141 = sheenVelvetPDF(_S1134.value, n_i_dot_v_3, w_14);
    (&sample_1)->pdf = _S1141;
    return sample_1;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1142 = (F32_sqrt((random_1_0)));
    float _S1143 = 6.28318548202514648f * random_2_0;
    float _S1144 = _S1142 * (F32_cos((_S1143)));
    float _S1145 = _S1142 * (F32_sin((_S1143)));
    float _S1146 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1144 * _S1144 - _S1145 * _S1145))))));
    return make_float3 (_S1144, _S1146, _S1145);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_4, float3  n_i_14, float n_i_dot_v_4, BSDFMaterial material_18, Weights w_15, uint random_state_15)
{
    float3  _S1147 = make_float3 (1.0f);
    SampleBSDF _S1148 = SampleBSDF_x24init_0(_S1147, _S1147, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S1148;
    Random _S1149 = pcg(random_state_15);
    Random _S1150 = pcg(_S1149.state);
    (&sample_2)->random_state = _S1150.state;
    float3  _S1151 = sampleCosWeightedHemisphere(_S1149.value, _S1150.value);
    float _S1152 = translucentShare(material_18);
    bool _S1153 = u_4 < (w_15.p_diffuse * _S1152);
    float _S1154 = _S1151.y;
    float _S1155 = - _S1154;
    float _S1156 = _slang_select(_S1153, _S1155,_S1154);
    float3  _S1157 = tangentToWorld(make_float3 (_S1151.x, _S1156, _S1151.z), n_i_14);
    (&sample_2)->unit_direction = _S1157;
    (&sample_2)->refracted = _S1153;
    (&sample_2)->lobe = 0U;
    float3  _S1158 = diffuseBSDF((&sample_2)->unit_direction, n_i_14, material_18, w_15);
    (&sample_2)->throughput = _S1158;
    float _S1159 = diffusePDF(_S1156, n_i_dot_v_4, material_18, w_15);
    (&sample_2)->pdf = _S1159;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF toonSample(float3  n_i_15, ToonProfile profile_3, Weights w_16, uint random_state_16)
{
    float3  _S1160 = make_float3 (1.0f);
    SampleBSDF _S1161 = SampleBSDF_x24init_0(_S1160, _S1160, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S1161;
    Random _S1162 = pcg(random_state_16);
    Random _S1163 = pcg(_S1162.state);
    (&sample_3)->random_state = _S1163.state;
    float _S1164 = _S1162.value * profile_3.norm / 6.28318548202514648f;
    float t_23;
    if(profile_3.glossy)
    {
        t_23 = (F32_acos((clamp_1(1.0f - _S1164, -1.0f, 1.0f))));
    }
    else
    {
        t_23 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1164)))), (1.0f))))));
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
        float _S1165 = toonP(t_23, profile_3.a, profile_3.s);
        float _S1166 = _S1165 * (F32_sin((t_23)));
        float _S1167;
        if(profile_3.glossy)
        {
            _S1167 = 1.0f;
        }
        else
        {
            _S1167 = (F32_cos((t_23)));
        }
        float _S1168 = _S1166 * _S1167;
        float _S1169 = toonIntegral(t_23, profile_3.a, profile_3.s, profile_3.glossy);
        float _S1170 = (_S1169 - _S1164) / _S1168;
        bool _S1171 = _S1168 > 0.0f;
        float _S1172 = _slang_select(_S1171, _S1170,0.0f);
        float _S1173 = clamp_1(t_23 - _S1172, 0.0f, profile_3.b);
        int k_1 = k_0 + int(1);
        t_23 = _S1173;
        k_0 = k_1;
    }
    float _S1174 = 6.28318548202514648f * _S1163.value;
    float _S1175 = (F32_sin((t_23)));
    float3  _S1176 = tangentToWorld(make_float3 (_S1175 * (F32_cos((_S1174))), (F32_cos((t_23))), _S1175 * (F32_sin((_S1174)))), profile_3.axis);
    (&sample_3)->unit_direction = _S1176;
    bool _S1177 = (dot_0(n_i_15, (&sample_3)->unit_direction)) < 0.0f;
    (&sample_3)->refracted = _S1177;
    (&sample_3)->lobe = 6U;
    float3  _S1178 = toonBSDF((&sample_3)->unit_direction, n_i_15, profile_3, w_16);
    (&sample_3)->throughput = _S1178;
    float _S1179 = toonPDF((&sample_3)->unit_direction, n_i_15, profile_3, w_16);
    (&sample_3)->pdf = _S1179;
    return sample_3;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_16, float alpha_8, AnisotropicFrame frame_6, BSDFMaterial material_19, Weights w_17, float pdf_h_3, float eta_i_7, float eta_o_7, uint random_state_17)
{
    float3  _S1180 = make_float3 (1.0f);
    SampleBSDF _S1181 = SampleBSDF_x24init_0(_S1180, _S1180, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S1181;
    (&sample_4)->unit_direction = w_17.refracted;
    (&sample_4)->random_state = random_state_17;
    (&sample_4)->refracted = true;
    (&sample_4)->lobe = 1U;
    float3  _S1182 = refractBSDF((&sample_4)->unit_direction, n_i_16, alpha_8, frame_6, material_19, w_17);
    (&sample_4)->throughput = _S1182;
    float _S1183 = refractPDF(dot_0((&sample_4)->unit_direction, ggx_n_3), pdf_h_3, w_17, eta_i_7, eta_o_7);
    (&sample_4)->pdf = _S1183;
    return sample_4;
}

static __device__ float3  reflect_0(float3  i_26, float3  n_9)
{
    return i_26 - make_float3 (2.0f * dot_0(n_9, i_26)) * n_9;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_8, float3  ggx_n_4, float3  n_i_17, float alpha_9, AnisotropicFrame frame_7, Weights w_18, float pdf_h_4, uint random_state_18)
{
    float3  _S1184 = make_float3 (1.0f);
    SampleBSDF _S1185 = SampleBSDF_x24init_0(_S1184, _S1184, 0U, false, 0U, 0.0f);
    SampleBSDF sample_5 = _S1185;
    float3  _S1186 = reflect_0(in_dir_8, ggx_n_4);
    float3  _S1187 = ((((_S1186)) * make_float3(rnorm3df(((_S1186)).x, ((_S1186)).y, ((_S1186)).z))));
    (&sample_5)->unit_direction = _S1187;
    (&sample_5)->random_state = random_state_18;
    (&sample_5)->lobe = 2U;
    float3  _S1188 = reflectBSDF((&sample_5)->unit_direction, n_i_17, alpha_9, frame_7, w_18);
    (&sample_5)->throughput = _S1188;
    float _S1189 = reflectPDF(pdf_h_4, w_18);
    (&sample_5)->pdf = _S1189;
    return sample_5;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_9, float3  n_10, BSDFMaterial material_20, float eta_i_8, float eta_o_8, uint random_init_0, float2  screen_space_0)
{
    uint random_state_19 = random_init_0;
    float3  _S1190 = negate_0(in_dir_9);
    float _S1191 = dot_0(n_10, _S1190);
    float _S1192 = sign_0(_S1191);
    float3  n_i_18 = n_10 * make_float3 (_S1192);
    float _S1193 = (F32_abs((_S1191)));
    float _S1194 = material_20.roughness;
    float _S1195 = _S1194 * _S1194;
    AnisotropicFrame _S1196 = anisotropicFrame(material_20, n_i_18);
    SheenProfile _S1197 = sheenProfile(_S1190, n_i_18, material_20);
    float3  _S1198 = sampleHalfVector(_S1190, n_i_18, _S1195, _S1196, &random_state_19);
    Weights _S1199 = lobeWeights(in_dir_9, _S1190, n_i_18, _S1198, _S1196, _S1197, material_20, eta_i_8, eta_o_8);
    Random _S1200 = pcg(random_state_19);
    random_state_19 = _S1200.state;
    bool _S1201 = (_S1200.value) < (_S1199.p_sheen_velvet);
    if(_S1201)
    {
        SampleBSDF _S1202 = sheenVelvetSample(_S1190, n_i_18, _S1193, material_20, _S1199, random_state_19);
        return _S1202;
    }
    float _S1203 = _S1200.value - _S1199.p_sheen_velvet;
    bool _S1204 = _S1203 < (_S1199.p_diffuse);
    if(_S1204)
    {
        SampleBSDF _S1205 = diffuseSample(_S1203, n_i_18, _S1193, material_20, _S1199, random_state_19);
        return _S1205;
    }
    bool _S1206 = _S1203 < (_S1199.p_diffuse + _S1199.p_toon);
    if(_S1206)
    {
        ToonProfile _S1207 = toonProfile(_S1190, n_i_18, material_20);
        SampleBSDF _S1208 = toonSample(n_i_18, _S1207, _S1199, random_state_19);
        return _S1208;
    }
    float _S1209 = vndfPDF(_S1190, _S1198, n_i_18, _S1193, _S1195, _S1196, _S1199.v_dot_h);
    bool _S1210 = (_S1203 - _S1199.p_toon) < (_S1199.p_diffuse + _S1199.p_refract);
    if(_S1210)
    {
        SampleBSDF _S1211 = refractSample(_S1198, n_i_18, _S1195, _S1196, material_20, _S1199, _S1209, eta_i_8, eta_o_8, random_state_19);
        return _S1211;
    }
    SampleBSDF _S1212 = reflectSample(in_dir_9, _S1198, n_i_18, _S1195, _S1196, _S1199, _S1209, random_state_19);
    return _S1212;
}

__device__ bool withinInverseFootprint(float pdf_7, bool diffuse_0, float prev_cos_0, float distance_5, float threshold_1)
{
    bool _S1213 = pdf_7 > 0.0f;
    bool _S1214;
    if(_S1213)
    {
        if(diffuse_0)
        {
            _S1214 = true;
        }
        else
        {
            _S1214 = (pdf_7 * prev_cos_0 / (distance_5 * distance_5) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S1214 = false;
    }
    return _S1214;
}

__device__ bool roughLobe(float pdf_8, bool diffuse_1, float roughness_1)
{
    bool _S1215 = pdf_8 > 0.0f;
    bool _S1216;
    if(_S1215)
    {
        if(diffuse_1)
        {
            _S1216 = true;
        }
        else
        {
            _S1216 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S1216 = false;
    }
    return _S1216;
}

static __device__ bool passesLayer_0(uint layers_0, bool refracting_0, bool passed_0)
{
    bool _S1217 = layers_0 > 1U;
    bool _S1218;
    if(_S1217)
    {
        _S1218 = refracting_0 != passed_0;
    }
    else
    {
        _S1218 = false;
    }
    return _S1218;
}

static __device__ float widened_0(float spread_1, float pdf_9, bool delta_0)
{
    float _S1219 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * pdf_9))))), (3.14159274101257324f)));
    bool _S1220 = !delta_0;
    float _S1221 = _slang_select(_S1220, _S1219,0.0f);
    return spread_1 + _S1221;
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
    bool _S1222;
    float density_2;
    float threshold_2;
    float width_3;
    float sky_pdf_0;
    float wavelength_2;
    uint b_7;
    uint layer_0;
    float3  throughput_2;
    float3  chain_throughput_0;
    TreeSample light_3;
    int _S1223;
    Shift ended_0;
    float density_3;
    float spread_3;
    float width_4;
    float sky_pdf_1;
    float spread_4;
    float width_5;
    uint b_8;
    float3  _S1224 = make_float3 (0.0f);
    Shift _S1225 = Shift_x24init_0(_S1224, 0.0f);
    uint _S1226 = r_8->path;
    uint _S1227 = extractBits_0(r_8->path, 0U, 5U);
    uint _S1228 = extractBits_0(_S1226, 5U, 5U);
    uint _S1229 = extractBits_0(_S1226, 10U, 2U);
    uint _S1230 = extractBits_0(_S1226, 12U, 3U);
    bool passes_0;
    if(replay_2)
    {
        bool _S1231 = _S1230 >= 3U;
        uint _S1232 = _slang_select(_S1231, 1U,0U);
        uint _S1233 = _S1227 + _S1232;
        uint _S1234 = (fcptMaxBounces());
        passes_0 = _S1233 > _S1234;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1225;
    }
    uint _S1235 = _S1228 - 1U;
    bool _S1236 = _S1230 == 3U;
    uint _S1237 = _slang_select(_S1236, 1U,0U);
    uint _S1238 = _S1227 + _S1237;
    bool _S1239 = _S1229 == 0U;
    uint _S1240 = _slang_select(_S1239, _S1238,_S1235);
    FKHit _S1241 = (fcptReservoirHit((*r_8)));
    float3  _S1242 = dom_7->x0;
    float3  _S1243 = dom_7->x1 - dom_7->x0;
    float3  _S1244 = ((((_S1243)) * make_float3(rnorm3df(((_S1243)).x, ((_S1243)).y, ((_S1243)).z))));
    FKRay _S1245 = Ray_x24init_0(dom_7->x1, _S1244);
    FKRay ray_2 = _S1245;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1224;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_1 = throughput_3;
    float3  glowed_0 = _S1224;
    float3  extinction_in_0 = _S1224;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1246 = dom_7->spread;
    float _S1247 = dom_7->width;
    float _S1248 = length_0(_S1243);
    NEEVertex _S1249 = NEEVertex_x24init_0(true, 0.0f, _S1224, _S1224, _S1224);
    NEEVertex nee_vertex_0 = _S1249;
    Vertex _S1250 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S1250;
    Reservoir _S1251 = (Reservoir{});
    Reservoir chain_0 = _S1251;
    uint _S1252 = r_8->seed;
    (&chain_0)->seed = r_8->seed;
    (&ray_2)->origin = _S1242;
    (&hit_4)->distance = _S1248;
    FKMedium _S1253 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1254 = filling_2;
    bool _S1255 = (fcptVaryingUsed());
    uint _S1256 = _slang_select(_S1255, _S1254,4294967295U);
    filling_2 = _S1256;
    scatter_in_0 = _S1253.scatter;
    extinction_in_0 = _S1253.extinction;
    g_in_0 = _S1253.g;
    Reservoir _S1257 = chain_0;
    uint _S1258 = filling_2;
    for(;;)
    {
        bool _S1259 = (fcptVaryingUsed());
        if(_S1259)
        {
            passes_0 = _S1258 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1260 = (fcptMajorant((_S1258)));
            spread_2 = _S1260;
        }
        else
        {
            spread_2 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_2)
        {
            turned_1 = 4294967295U == _S1240;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1229 == 1U;
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
            ended_0 = _S1225;
            sky_pdf_0 = 0.0f;
            spread_2 = _S1246;
            width_3 = _S1247;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_7 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1261 = (&prev_0)->rough;
        if(_S1261)
        {
            turned_1 = !(spread_2 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S1262 = stream(_S1252, 384U);
        uint tracking_0 = _S1262;
        weight_1 = throughput_3;
        glowed_0 = _S1224;
        b_7 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        threshold_2 = _S1246;
        width_3 = _S1247;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1223 = int(1);
                break;
            }
            uint _S1263 = b_7 + 320U;
            bool _S1264 = b_7 == 4294967295U;
            uint _S1265 = _slang_select(_S1264, 384U,_S1263);
            uint _S1266 = stream(_S1252, _S1265);
            Random _S1267 = pcg(_S1266);
            float _S1268 = freeFlight_0(_S1267.value, spread_2);
            if(passes_0)
            {
                float3  _S1269 = (&ray_2)->origin;
                float3  _S1270 = (&ray_2)->unit_direction;
                float _S1271 = (&hit_4)->distance;
                uint _S1272 = _slang_select(_S1264, 0U,b_7);
                uint _S1273 = (&prev_0)->lobe;
                uint _S1274 = _slang_select(_S1264, 3U,_S1273);
                float _S1275 = (fcptTrackMedium((_S1258), (_S1269), (_S1270), (_S1271), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1272), (_S1274), (_S1264)));
                wavelength_2 = _S1275;
            }
            else
            {
                wavelength_2 = _S1268;
            }
            bool _S1276 = !(wavelength_2 < ((&hit_4)->distance));
            if(_S1276)
            {
                _S1223 = int(1);
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
                float3  _S1277 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S1278 = sel_7->glow + _S1277;
                sel_7->glow = _S1278;
            }
            else
            {
            }
            glowed_0 = _S1224;
            uint b_9 = b_7 + 1U;
            float3  _S1279 = (&ray_2)->origin + make_float3 (wavelength_2) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1279;
            float3  _S1280 = flightWeight_0(scatter_in_0, extinction_in_0, spread_2, wavelength_2, true);
            float3  _S1281 = weight_1;
            float3  _S1282 = _slang_select(passes_0, _S1281,_S1280);
            float3  throughput_4 = throughput_2 * _S1282;
            uint _S1283 = stream(_S1252, b_9 + 320U);
            tracking_0 = _S1283;
            weight_1 = throughput_3;
            float width_6 = width_3 + threshold_2 * wavelength_2;
            float _S1284 = threshold_2 + 3.14159274101257324f;
            bool _S1285 = scatterSampled_0(replay_2, b_9, _S1240, passes_0);
            TreeSample _S1286 = TreeSample_x24init_0(_S1224, _S1224, 0.0f, 0U);
            if(_S1285)
            {
                float3  _S1287 = (&ray_2)->origin;
                float3  _S1288 = (&ray_2)->unit_direction;
                float3  _S1289 = (&ray_2)->unit_direction;
                uint _S1290 = stream(_S1252, b_9 + 64U);
                float3  _S1291 = extinction_in_0;
                float3  _S1292 = extinction_in_0;
                uint2  _S1293 = make_uint2 (_S1258);
                float3  _S1294 = (&ray_2)->unit_direction;
                uint _S1295 = arrivalLobe_0(b_9, (&prev_0)->lobe);
                FKHit _S1296 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1297 = _S1296;
                ShadowContext _S1298 = ShadowContext_x24init_0(_S1291, _S1292, _S1293, _S1294, b_9, _S1295, false, wavelength_2, width_6, &_S1297, false);
                ShadowContext _S1299 = _S1298;
                TreeSample _S1300 = sampleLightTree_0(_S1287, _S1288, _S1289, 0.0f, true, _S1290, &_S1299);
                light_3 = _S1300;
            }
            else
            {
                light_3 = _S1286;
            }
            float _S1301 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S1302 = (fcptMaxBounces());
            bool _S1303 = b_9 < _S1302;
            if(_S1303)
            {
                is_inside_6 = (light_3.density) > 0.0f;
            }
            else
            {
                is_inside_6 = false;
            }
            float _S1304 = _slang_select(is_inside_6, _S1301,0.0f);
            float3  _S1305 = throughput_4 * light_3.radiance;
            float _S1306 = powerHeuristic(light_3.density, _S1304);
            float3  _S1307 = _S1305 * make_float3 (_S1301 * _S1306);
            float3  _S1308 = _slang_select(_S1285, _S1307,_S1224);
            if(replay_2)
            {
                viewed_0 = b_9 == _S1240;
            }
            else
            {
                viewed_0 = false;
            }
            if(viewed_0)
            {
                bool _S1309 = _S1229 == 2U;
                if(_S1309)
                {
                    float _S1310 = resamplingTarget(_S1308);
                    passes_0 = _S1310 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1311 = Shift_x24init_0(_S1308, 1.0f);
                    _S1223 = int(0);
                    ended_0 = _S1311;
                    spread_2 = _S1284;
                    wavelength_2 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_9;
                    break;
                }
                _S1223 = int(0);
                ended_0 = _S1225;
                spread_2 = _S1284;
                wavelength_2 = width_6;
                chain_throughput_0 = throughput_4;
                layer_0 = b_9;
                break;
            }
            bool _S1312 = !replay_2;
            if(_S1312)
            {
                Reservoir candidate_3 = _S1257;
                uint _S1313 = extractBits_0(_S1257.path, 10U, 2U);
                bool _S1314 = _S1313 == 1U;
                if(_S1314)
                {
                    float3  _S1315 = safeDivide(_S1308, _S1224);
                    (&candidate_3)->radiance = _S1315;
                }
                else
                {
                    uint _S1316 = insertBits_0(0U, b_9 + 1U, 5U, 5U);
                    uint _S1317 = insertBits_0(_S1316, 2U, 10U, 2U);
                    (&candidate_3)->path = _S1317;
                }
                Reservoir _S1318 = withEnd(candidate_3, 0U, b_9, _S1308);
                offer(sel_7, _S1318, _S1308 * make_float3 (scale_3) / make_float3 (density_2));
                float _S1319 = survivalProbability(abs_0(throughput_4), density_2);
                uint _S1320 = stream(_S1252, b_9 + 128U);
                Random _S1321 = pcg(_S1320);
                bool _S1322 = _S1319 < (_S1321.value);
                if(_S1322)
                {
                    _S1222 = true;
                }
                else
                {
                    uint _S1323 = (fcptMaxBounces());
                    _S1222 = b_9 >= _S1323;
                }
                if(_S1222)
                {
                    _S1223 = int(0);
                    ended_0 = _S1225;
                    spread_2 = _S1284;
                    wavelength_2 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_9;
                    break;
                }
                float _S1324 = density_2 * _S1319;
                density_2 = _S1324;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1325 = stream(_S1252, b_9);
            float3  _S1326 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1325, &phase_pdf_0);
            (&ray_2)->unit_direction = _S1326;
            NEEVertex _S1327 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S1224, (&ray_2)->origin);
            nee_vertex_0 = _S1327;
            Vertex _S1328 = scatteredVertex_0(false);
            prev_0 = _S1328;
            float _S1329 = (&prev_0)->pdf;
            FKRay _S1330 = ray_2;
            FKHit _S1331 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1332 = (fcptTraverseInstanceBVH((_S1330), (true), (4.294967296e+09f), (false), (_S1331), (false)));
            hit_4 = _S1332;
            b_7 = b_9;
            throughput_2 = throughput_4;
            threshold_2 = _S1284;
            width_3 = width_6;
            sky_pdf_0 = _S1329;
        }
        if(_S1223 != int(1))
        {
            width_3 = wavelength_2;
            throughput_2 = chain_throughput_0;
            b_7 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1225;
        spread_2 = threshold_2;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1333 = b_7 == 4294967295U;
    bool _S1334 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1334)
    {
        bool _S1335 = !(&nee_vertex_0)->none;
        float _S1336 = _slang_select(_S1335, sky_pdf_0,0.0f);
        float _S1337 = escapeWeight_0(_S1336, (&ray_2)->unit_direction);
        float3  _S1338 = environment_0((&ray_2)->unit_direction, b_7, (&prev_0)->lobe);
        float3  _S1339 = throughput_2 * _S1338;
        if(replay_2)
        {
            bool _S1340 = b_7 == _S1240;
            if(_S1340)
            {
                passes_0 = _S1229 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S1339 * make_float3 (_S1337) / make_float3 (r_8->jac), density_2 / r_8->jac);
            }
            if(_S1239)
            {
                passes_0 = _S1236;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_7 == _S1227;
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
                return Shift_x24init_0(_S1339 * make_float3 (_S1337), 1.0f);
            }
            return _S1225;
        }
        Reservoir candidate_4 = chain_0;
        uint _S1341 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1342 = _S1341 == 1U;
        if(_S1342)
        {
            uint _S1343 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S1344 = _S1343 == b_7;
            float _S1345 = _slang_select(_S1344, 1.0f,_S1337);
            float3  _S1346 = safeDivide(_S1339 * make_float3 (_S1345), _S1224);
            (&candidate_4)->radiance = _S1346;
        }
        else
        {
            bool _S1347 = (&prev_0)->rough;
            if(_S1347)
            {
                uint _S1348 = insertBits_0(0U, b_7 + 1U, 5U, 5U);
                uint _S1349 = insertBits_0(_S1348, 3U, 10U, 2U);
                uint _S1350 = insertBits_0(_S1349, (&prev_0)->lobe, 15U, 3U);
                bool _S1351 = (&prev_0)->inside;
                uint _S1352 = _slang_select(_S1351, 1U,0U);
                uint _S1353 = insertBits_0(_S1350, _S1352, 22U, 1U);
                (&candidate_4)->path = _S1353;
                (&candidate_4)->jac = (&prev_0)->pdf;
                (&candidate_4)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S1354 = _S1339 * make_float3 (_S1337);
        Reservoir _S1355 = withEnd(candidate_4, 3U, b_7, _S1354);
        offer(sel_7, _S1355, _S1354 * make_float3 (scale_3) / make_float3 (density_2));
        return _S1225;
    }
    float3  _S1356 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S1356;
    bool _S1357 = (fcptVaryingUsed());
    if(_S1357)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1358 = !replay_2;
        if(_S1358)
        {
            float3  _S1359 = throughput_2 * glowed_0 / make_float3 (density_2);
            float3  _S1360 = sel_7->glow + _S1359;
            sel_7->glow = _S1360;
        }
        float3  _S1361 = throughput_2 * weight_1;
        throughput_2 = _S1361;
    }
    else
    {
        float3  _S1362 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
        float3  _S1363 = throughput_2 * _S1362;
        throughput_2 = _S1363;
    }
    float _S1364 = width_3 + spread_2 * (&hit_4)->distance;
    uint _S1365 = b_7 + 1U;
    b_7 = _S1365;
    layer_0 = 0U;
    width_3 = _S1364;
    passes_0 = false;
    threshold_2 = 0.0f;
    turned_1 = false;
    is_inside_6 = false;
    wavelength_2 = 0.0f;
    chain_throughput_0 = _S1224;
    float3  reconnection_0 = _S1224;
    viewed_0 = _S1333;
    for(;;)
    {
        bool _S1366 = ((&hit_4)->is_point_light) == 1U;
        if(replay_2)
        {
            _S1222 = _S1229 == 1U;
        }
        else
        {
            _S1222 = false;
        }
        bool _S1367;
        if(_S1222)
        {
            _S1367 = b_7 == _S1228;
        }
        else
        {
            _S1367 = false;
        }
        bool _S1368;
        if(_S1367)
        {
            bool _S1369 = ((&hit_4)->instance_index) != (_S1241.instance_index);
            if(_S1369)
            {
                _S1368 = true;
            }
            else
            {
                _S1368 = ((&hit_4)->triangle_index) != (_S1241.triangle_index);
            }
        }
        else
        {
            _S1368 = false;
        }
        if(_S1368)
        {
            return _S1225;
        }
        FKMedium _S1370 = Medium_x24init_0(_S1224, _S1224, 0.0f);
        BSDFMaterial _S1371 = Material_x24init_0(_S1224, _S1224, 0.0f, 0.0f, 0.0f, 0.0f, _S1224, throughput_3, 1.0f, _S1224, _S1224, 0.5f, 0.0f, 0.0f, _S1224, 0.0f, _S1224, 0.0f);
        FKMedium _S1372 = _S1370;
        FKSurface _S1373 = Surface_x24init_0(_S1224, _S1224, 0.0f, &_S1371, false, 0U, 1.0f, false, &_S1372, 4294967295U, _S1224);
        bool _S1374 = !_S1366;
        bool scatter_2;
        bool is_inside_7;
        float geometry_density_2;
        float3  throughput_5;
        FKSurface surface_12;
        if(_S1374)
        {
            uint _S1375 = stream(_S1252, b_7);
            uint _S1376 = arrivalLobe_0(b_7, (&prev_0)->lobe);
            FKSurface _S1377 = (fcptSurfaceAtPath((hit_4), ((&ray_2)->origin), (_S1375), (width_3), (layer_0), (b_7), (_S1376), ((&ray_2)->unit_direction)));
            bool _S1378 = !passes_0;
            FKSurface _S1379 = _S1377;
            FKSurface _S1380 = emitting_0(&_S1379, _S1378);
            uint _S1381 = stream(_S1252, b_7 + 256U);
            Random _S1382 = pcg(_S1381);
            FKSurface _S1383 = _S1380;
            FKSurface _S1384 = uncovered_0(&_S1383, _S1382.value);
            float _S1385 = facingSign(_S1384.material.transmission, _S1384.geometry_n, (&ray_2)->unit_direction);
            bool _S1386 = _S1385 < 0.0f;
            bool _S1387 = (_S1384.material.transmission) > 0.0f;
            if(_S1387)
            {
                bool _S1388 = arrivesBehind_0((&ray_2)->unit_direction, _S1384.geometry_n);
                scatter_2 = _S1388;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1389 = _S1384;
            FKSurface _S1390 = facingRay_0(&_S1389, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S1391 = arrivesBehind_0((&ray_2)->unit_direction, _S1390.geometry_n);
                is_inside_7 = _S1391;
            }
            else
            {
                is_inside_7 = scatter_2;
            }
            if(is_inside_7)
            {
                float3  _S1392 = beerLambert((&hit_4)->distance, _S1390.material.absorption);
                float3  _S1393 = throughput_2 * _S1392;
                throughput_5 = _S1393;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S1394 = !_S1390.skip;
            float geometry_density_3 = geometryDensity(_S1390.geometry_n, (&ray_2)->unit_direction, (&hit_4)->distance);
            bool _S1395 = b_7 == _S1365;
            if(_S1395)
            {
                float _S1396 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S1396;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            float _S1397 = geometry_density_2;
            scatter_2 = _S1394;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S1397;
            surface_12 = _S1390;
            turned_1 = _S1386;
        }
        else
        {
            scatter_2 = false;
            geometry_density_2 = 0.0f;
            surface_12 = _S1373;
            throughput_5 = throughput_2;
            is_inside_7 = is_inside_6;
        }
        bool _S1398 = withinFootprint(scatter_2, (&prev_0)->rough, (&prev_0)->pdf, geometry_density_2, threshold_2);
        FKSurface _S1399 = surface_12;
        FKSurface _S1400 = surface_12;
        float _S1401 = dot_0(surface_12.smooth_n, - (&ray_2)->unit_direction);
        bool _S1402 = (fcptDispersionUsed());
        bool _S1403;
        if(_S1402)
        {
            _S1403 = wavelength_2 == 0.0f;
        }
        else
        {
            _S1403 = false;
        }
        bool _S1404;
        if(_S1403)
        {
            _S1404 = scatter_2;
        }
        else
        {
            _S1404 = false;
        }
        bool _S1405;
        if(_S1404)
        {
            bool _S1406 = dispersive(_S1399.material);
            _S1405 = _S1406;
        }
        else
        {
            _S1405 = false;
        }
        float3  throughput_6;
        if(_S1405)
        {
            uint _S1407 = stream(_S1252, 512U);
            Random _S1408 = pcg(_S1407);
            float2  _S1409 = sampleWavelength(_S1408.value);
            float _S1410 = _S1409.x;
            float3  _S1411 = wavelengthWeights(_S1410);
            float3  _S1412 = throughput_5 * (_S1411 / make_float3 (_S1409.y));
            wavelength_2 = _S1410;
            throughput_6 = _S1412;
        }
        else
        {
            throughput_6 = throughput_5;
        }
        BSDFMaterial refractive_0 = _S1399.material;
        float _S1413 = dispersedIor(_S1399.material.ior, _S1399.material.dispersion, wavelength_2);
        bool _S1414 = wavelength_2 > 0.0f;
        float _S1415 = _slang_select(_S1414, _S1413,_S1399.material.ior);
        (&refractive_0)->ior = _S1415;
        float2  _S1416 = vertexEta(refractive_0, _S1401);
        bool _S1417;
        if(scatter_2)
        {
            bool _S1418 = neeDecision(_S1399.material, _S1401, _S1416.x, _S1416.y);
            _S1417 = _S1418;
        }
        else
        {
            _S1417 = false;
        }
        bool _S1419;
        if(passes_0)
        {
            _S1419 = true;
        }
        else
        {
            _S1419 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1419)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1417;
        }
        bool _S1420 = (fcptHairUsed());
        bool _S1421;
        if(_S1420)
        {
            float3  _S1422 = surface_12.hair;
            _S1421 = (dot_0(_S1422, _S1422)) > 0.0f;
        }
        else
        {
            _S1421 = false;
        }
        bool _S1423;
        if(_S1421)
        {
            _S1423 = true;
        }
        else
        {
            BSDFMaterial _S1424 = _S1399.material;
            bool _S1425 = isTranslucent_0(&_S1424);
            _S1423 = _S1425;
        }
        bool _S1426;
        if(_S1423)
        {
            _S1426 = true;
        }
        else
        {
            bool _S1427 = (_S1399.material.transmission) > 0.0f;
            if(_S1427)
            {
                uint _S1428 = (fcptLayers((hit_4)));
                _S1426 = _S1428 == 1U;
            }
            else
            {
                _S1426 = false;
            }
        }
        float3  emission_0;
        if(_S1366)
        {
            float3  _S1429 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1429;
        }
        else
        {
            emission_0 = _S1399.material.emissive;
        }
        bool _S1430 = !replay_2;
        bool _S1431;
        if(_S1430)
        {
            _S1431 = true;
        }
        else
        {
            _S1431 = b_7 >= _S1240;
        }
        bool _S1432;
        if(_S1431)
        {
            float _S1433 = rgb_to_greyscale(emission_0);
            _S1432 = _S1433 > 0.0f;
        }
        else
        {
            _S1432 = false;
        }
        float3  emission_1;
        if(_S1432)
        {
            NEEVertex _S1434 = nee_vertex_0;
            FKHit _S1435 = hit_4;
            float _S1436 = emissionWeight_0(&_S1434, &_S1435, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1436);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1437;
        if(replay_2)
        {
            _S1437 = _S1229 == 1U;
        }
        else
        {
            _S1437 = false;
        }
        bool _S1438;
        if(_S1437)
        {
            _S1438 = b_7 > _S1228;
        }
        else
        {
            _S1438 = false;
        }
        bool _S1439;
        if(_S1438)
        {
            _S1439 = b_7 == _S1227;
        }
        else
        {
            _S1439 = false;
        }
        bool _S1440;
        if(_S1439)
        {
            bool _S1441 = _S1230 == 1U;
            if(_S1441)
            {
                _S1440 = true;
            }
            else
            {
                _S1440 = _S1230 == 2U;
            }
        }
        else
        {
            _S1440 = false;
        }
        if(_S1440)
        {
            bool _S1442 = _S1366 != (_S1230 == 2U);
            if(_S1442)
            {
                return _S1225;
            }
            return Shift_x24init_0(throughput_6 * emission_1 / make_float3 (r_8->jac), density_2 / r_8->jac);
        }
        uint _S1443 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1444 = _S1443 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1445 = insertBits_0(0U, b_7, 5U, 5U);
        uint _S1446 = insertBits_0(_S1445, 1U, 10U, 2U);
        uint _S1447 = insertBits_0(_S1446, (&prev_0)->lobe, 15U, 3U);
        bool _S1448 = (&prev_0)->inside;
        uint _S1449 = _slang_select(_S1448, 1U,0U);
        uint _S1450 = insertBits_0(_S1447, _S1449, 22U, 1U);
        (&here_0)->path = _S1450;
        uint _S1451 = (&here_0)->path;
        uint _S1452 = _slang_select(_S1414, 1U,0U);
        uint _S1453 = insertBits_0(_S1451, _S1452, 23U, 1U);
        (&here_0)->path = _S1453;
        float _S1454 = (&prev_0)->pdf * geometry_density_2;
        (&here_0)->jac = _S1454;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1455;
        if(replay_2)
        {
            _S1455 = _S1229 == 1U;
        }
        else
        {
            _S1455 = false;
        }
        bool _S1456;
        if(_S1455)
        {
            _S1456 = b_7 == _S1228;
        }
        else
        {
            _S1456 = false;
        }
        bool _S1457 = b_7 == _S1240;
        bool _S1458;
        if(_S1457)
        {
            bool _S1459 = !scatter_2;
            if(_S1459)
            {
                _S1458 = true;
            }
            else
            {
                bool _S1460 = _S1229 != 1U;
                if(_S1460)
                {
                    _S1458 = _S1229 != 3U;
                }
                else
                {
                    _S1458 = false;
                }
            }
        }
        else
        {
            _S1458 = false;
        }
        bool _S1461;
        if(_S1458)
        {
            _S1461 = _S1229 == 2U;
        }
        else
        {
            _S1461 = false;
        }
        bool _S1462;
        if(_S1461)
        {
            _S1462 = !_S1398;
        }
        else
        {
            _S1462 = false;
        }
        bool _S1463;
        if(_S1462)
        {
            _S1463 = _S1230 != 4U;
        }
        else
        {
            _S1463 = false;
        }
        bool _S1464 = _S1228 == _S1227;
        bool _S1465;
        if(_S1464)
        {
            _S1465 = _S1230 == 0U;
        }
        else
        {
            _S1465 = false;
        }
        bool _S1466;
        if(_S1465)
        {
            _S1466 = ((&hit_4)->instance_index) == (_S1241.instance_index);
        }
        else
        {
            _S1466 = false;
        }
        bool _S1467;
        if(_S1466)
        {
            _S1467 = ((&hit_4)->triangle_index) == (_S1241.triangle_index);
        }
        else
        {
            _S1467 = false;
        }
        bool _S1468;
        if(_S1467)
        {
            _S1468 = _S1398;
        }
        else
        {
            _S1468 = false;
        }
        bool _S1469 = _slang_select(_S1456, _S1468,_S1463);
        bool _S1470;
        if(nee_0)
        {
            _S1470 = _slang_select(replay_2, _S1469,scatter_2);
        }
        else
        {
            _S1470 = false;
        }
        TreeSample _S1471 = TreeSample_x24init_0(_S1224, _S1224, 0.0f, 0U);
        uint2  _S1472 = make_uint2 (0U);
        float2  _S1473 = make_float2 (0.0f);
        FKHit _S1474 = Hit_x24init_0(_S1473, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1475 = _S1474;
        ShadowContext _S1476 = ShadowContext_x24init_0(_S1224, _S1224, _S1472, _S1224, 0U, 0U, false, 0.0f, 0.0f, &_S1475, false);
        bool _S1477;
        if(nee_0)
        {
            _S1477 = _S1431;
        }
        else
        {
            _S1477 = false;
        }
        ShadowContext context_5;
        if(_S1477)
        {
            uint _S1478 = arrivalLobe_0(b_7, (&prev_0)->lobe);
            FKMedium _S1479 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1480 = surface_12;
            FKHit _S1481 = hit_4;
            FKMedium _S1482 = _S1479;
            ShadowContext _S1483 = shadowContext_0(&_S1480, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_7, _S1478, (&hit_4)->distance, width_3, &_S1481, _S1421, &_S1482);
            context_5 = _S1483;
        }
        else
        {
            context_5 = _S1476;
        }
        float3  throughput_7;
        float3  lit_0;
        if(_S1470)
        {
            float3  _S1484 = (&ray_2)->origin;
            if(_S1421)
            {
                throughput_7 = _S1224;
            }
            else
            {
                throughput_7 = _S1400.smooth_n;
            }
            FKSurface _S1485 = surface_12;
            uint _S1486 = stream(_S1252, b_7 + 64U);
            ShadowContext _S1487 = context_5;
            TreeSample _S1488 = sampleLightTree_0(_S1484, throughput_7, surface_12.geometry_n, surface_12.geometry_offset, _S1426, _S1486, &_S1487);
            bool _S1489 = any_1((_S1488.radiance) != _S1224);
            if(_S1489)
            {
                if(_S1421)
                {
                    uint _S1490 = (fcptMaxBounces());
                    bool _S1491 = b_7 < _S1490;
                    FKSurface _S1492 = surface_12;
                    TreeSample _S1493 = _S1488;
                    float3  _S1494 = hairLight_0(&_S1492, (&ray_2)->unit_direction, &_S1493, _S1491);
                    lit_0 = _S1494;
                }
                else
                {
                    float _S1495 = _S1416.x;
                    float _S1496 = _S1416.y;
                    uint _S1497 = (fcptMaxBounces());
                    bool _S1498 = b_7 < _S1497;
                    TreeSample _S1499 = _S1488;
                    BSDFMaterial _S1500 = _S1399.material;
                    float3  _S1501 = lightBSDF_0((&ray_2)->unit_direction, &_S1499, _S1400.smooth_n, _S1485.geometry_n, &_S1500, _S1495, _S1496, _S1498, surface_12.random_state);
                    lit_0 = _S1501;
                }
            }
            else
            {
                lit_0 = _S1224;
            }
            light_3 = _S1488;
        }
        else
        {
            light_3 = _S1471;
            lit_0 = _S1224;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1502;
        bool _S1503;
        float density_4;
        if(_S1456)
        {
            bool _S1504 = !_S1398;
            if(_S1504)
            {
                return _S1225;
            }
            uint _S1505 = extractBits_0(_S1226, 23U, 1U);
            bool _S1506 = _S1414 != (_S1505 == 1U);
            if(_S1506)
            {
                return _S1225;
            }
            float3  throughput_8 = throughput_6 * make_float3 (geometry_density_2);
            float density_5 = density_2 * geometry_density_2;
            if(_S1464)
            {
                viewed_1 = _S1230 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                return Shift_x24init_0(throughput_8 * emission_1 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1464)
            {
                refracted_4 = _S1230 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S1507 = !nee_0;
                if(_S1507)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1508 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1508 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1225;
                }
                return Shift_x24init_0(throughput_8 * lit_0 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1464)
            {
                wrong_side_0 = _S1230 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1509 = !nee_0;
                if(_S1509)
                {
                    return _S1225;
                }
                float _S1510 = environmentPdf_0(r_8->dir);
                float3  _S1511 = skyBSDF((&ray_2)->unit_direction, r_8->dir, surface_12, _S1416, is_inside_7, _S1510, surface_12.random_state);
                return Shift_x24init_0(throughput_8 * _S1511 * r_8->radiance / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            uint _S1512 = extractBits_0(_S1226, 21U, 1U);
            bool _S1513 = nee_0 != (_S1512 == 1U);
            if(_S1513)
            {
                return _S1225;
            }
            throughput_7 = throughput_8;
            density_4 = density_5;
        }
        else
        {
            if(replay_2)
            {
                viewed_1 = _S1457;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1514 = !scatter_2;
                if(_S1514)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1515 = _S1229 != 1U;
                    if(_S1515)
                    {
                        refracted_4 = _S1229 != 3U;
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
                bool _S1516 = _S1229 == 2U;
                if(_S1516)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1398;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1230 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1421)
                    {
                        return _S1225;
                    }
                    uint _S1517 = stream(_S1252, b_7 + 448U);
                    FKRay _S1518 = ray_2;
                    FKSurface _S1519 = surface_12;
                    ShadowContext _S1520 = context_5;
                    SkySample _S1521 = sampleSky_0(&_S1518, &_S1519, _S1416, is_inside_7, _S1517, surface_12.random_state, &_S1520);
                    return Shift_x24init_0(throughput_6 * _S1521.color, 1.0f);
                }
                if(_S1516)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1398;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1522 = rgb_to_greyscale(light_3.radiance);
                    bool _S1523 = !(_S1522 > 0.0f);
                    if(_S1523)
                    {
                        return _S1225;
                    }
                    return Shift_x24init_0(throughput_6 * lit_0, 1.0f);
                }
                if(_S1239)
                {
                    passes_0 = _S1230 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1366;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_6 * emission_1, 1.0f);
                }
                if(_S1239)
                {
                    passes_0 = _S1230 == 1U;
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
                    passes_0 = !_S1398;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_6 * emission_1, 1.0f);
                }
                return _S1225;
            }
            else
            {
                if(_S1430)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1524 = b_7 > 0U;
                    if(_S1524)
                    {
                        Reservoir candidate_5 = chain_0;
                        if(_S1444)
                        {
                            float3  _S1525 = safeDivide(throughput_6 * emission_1, chain_throughput_0);
                            (&candidate_5)->radiance = _S1525;
                        }
                        else
                        {
                            if(_S1398)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1526 = throughput_6 * emission_1;
                        Reservoir _S1527 = withEnd(candidate_5, 1U, b_7, _S1526);
                        offer(sel_7, _S1527, _S1526 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1528 = throughput_6 * emission_1;
                        float3  _S1529 = sel_7->glow + _S1528;
                        sel_7->glow = _S1529;
                    }
                    if(nee_0)
                    {
                        float3  _S1530 = throughput_6 * lit_0;
                        Reservoir candidate_6 = chain_0;
                        if(_S1444)
                        {
                            float3  _S1531 = safeDivide(_S1530, chain_throughput_0);
                            (&candidate_6)->radiance = _S1531;
                        }
                        else
                        {
                            if(_S1398)
                            {
                                candidate_6 = here_0;
                                uint _S1532 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1532;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1533 = insertBits_0(0U, b_7 + 1U, 5U, 5U);
                                uint _S1534 = insertBits_0(_S1533, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1534;
                            }
                        }
                        Reservoir _S1535 = withEnd(candidate_6, 0U, b_7, _S1530);
                        offer(sel_7, _S1535, _S1530 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1421)
                        {
                            _S1502 = false;
                        }
                        else
                        {
                            bool _S1536 = environmentMapped_0();
                            _S1502 = _S1536;
                        }
                    }
                    else
                    {
                        _S1502 = false;
                    }
                    if(_S1502)
                    {
                        uint _S1537 = (fcptMaxBounces());
                        _S1503 = b_7 < _S1537;
                    }
                    else
                    {
                        _S1503 = false;
                    }
                    if(_S1503)
                    {
                        uint _S1538 = stream(_S1252, b_7 + 448U);
                        FKRay _S1539 = ray_2;
                        FKSurface _S1540 = surface_12;
                        ShadowContext _S1541 = context_5;
                        SkySample _S1542 = sampleSky_0(&_S1539, &_S1540, _S1416, is_inside_7, _S1538, surface_12.random_state, &_S1541);
                        float3  _S1543 = throughput_6 * _S1542.color;
                        Reservoir candidate_7 = chain_0;
                        if(_S1444)
                        {
                            float3  _S1544 = safeDivide(_S1543, chain_throughput_0);
                            (&candidate_7)->radiance = _S1544;
                        }
                        else
                        {
                            if(_S1398)
                            {
                                candidate_7 = here_0;
                                uint _S1545 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1545;
                                (&candidate_7)->dir = _S1542.dir;
                                (&candidate_7)->radiance = _S1542.radiance;
                            }
                            else
                            {
                                uint _S1546 = insertBits_0(0U, b_7 + 1U, 5U, 5U);
                                uint _S1547 = insertBits_0(_S1546, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1547;
                            }
                        }
                        Reservoir _S1548 = withEnd(candidate_7, 4U, b_7, _S1543);
                        offer(sel_7, _S1548, _S1543 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                }
            }
            throughput_7 = throughput_6;
            density_4 = density_2;
        }
        bool _S1549;
        bool _S1550;
        bool _S1551;
        bool straight_0;
        bool _S1552;
        bool _S1553;
        bool _S1554;
        bool _S1555;
        bool _S1556;
        bool _S1557;
        bool _S1558;
        bool _S1559;
        bool _S1560;
        bool _S1561;
        bool _S1562;
        bool _S1563;
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
                viewed_1 = _S1457;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1564 = extractBits_0(_S1226, 15U, 3U);
            uint _S1565 = extractBits_0(_S1226, 18U, 3U);
            uint _S1566 = _slang_select(_S1456, _S1565,_S1564);
            float3  _S1567 = r_8->dir;
            bool refracted_5 = _S1566 == 1U;
            SampleBSDF _S1568 = SampleBSDF_x24init_0(_S1224, _S1224, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1568;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1569 = extractBits_0(_S1226, 22U, 1U);
                bool _S1570 = is_inside_7 != (_S1569 == 1U);
                if(_S1570)
                {
                    return _S1225;
                }
                bool _S1571 = _S1229 == 1U;
                if(_S1571)
                {
                    float3  _S1572 = (fcptHitPosition((_S1241)));
                    throughput_9 = _S1572;
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
                    BSDFMaterial _S1573 = _S1399.material;
                    bool _S1574 = isTranslucent_0(&_S1573);
                    if(_S1574)
                    {
                        refracted_4 = _S1566 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1575 = throughput_9 - (&ray_2)->origin;
                        float3  _S1576 = _slang_select(_S1571, _S1575,_S1567);
                        wrong_side_0 = (dot_0(_S1400.smooth_n, _S1576) * _S1401) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1571)
                {
                    float3  _S1577 = (&ray_2)->origin;
                    FKSurface _S1578 = surface_12;
                    float3  _S1579 = - _S1400.smooth_n;
                    bool _S1580 = is_inside_7 != refracted_4;
                    float3  _S1581 = _slang_select(_S1580, _S1579,_S1400.smooth_n);
                    float3  _S1582 = throughput_9 - (_S1577 + make_float3 (_S1578.geometry_offset) * _S1581);
                    float3  _S1583 = ((((_S1582)) * make_float3(rnorm3df(((_S1582)).x, ((_S1582)).y, ((_S1582)).z))));
                    reconnection_1 = _S1583;
                }
                else
                {
                    reconnection_1 = _S1567;
                }
                if(_S1421)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1584 = wrongSide_0(is_inside_7, refracted_4, reconnection_1, surface_12.geometry_n);
                    wrong_side_0 = _S1584;
                }
                if(wrong_side_0)
                {
                    return _S1225;
                }
                float3  _S1585 = throughput_9;
                throughput_9 = reconnection_1;
                b_10 = _S1566;
                wrong_side_0 = false;
                reconnection_1 = _S1585;
            }
            else
            {
                bool _S1586 = !_S1456;
                if(_S1586)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1587;
                    if(_S1421)
                    {
                        SampleBSDF _S1588 = (fcptSampleHair((surface_12.hair), (_S1399.material.albedo), (_S1399.material.specular_tint), ((&ray_2)->unit_direction), (surface_12.random_state)));
                        _S1587 = _S1588;
                    }
                    else
                    {
                        SampleBSDF _S1589 = sampleBSDF((&ray_2)->unit_direction, _S1400.smooth_n, _S1399.material, _S1416.x, _S1416.y, surface_12.random_state, _S1473);
                        _S1587 = _S1589;
                    }
                    bsdf_sampled_0 = _S1587;
                    if(_S1421)
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
                            return _S1225;
                        }
                        break;
                    }
                    if(_S1421)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1590 = wrongSide_0(is_inside_7, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_12.geometry_n);
                        wrong_side_0 = _S1590;
                    }
                    if(wrong_side_0)
                    {
                        _S1502 = (_S1399.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1502 = false;
                    }
                    if(_S1502)
                    {
                        SampleBSDF _S1591 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S1399.material, _S1416.x, _S1416.y, (&bsdf_sampled_0)->random_state, _S1473);
                        (&bsdf_sampled_0)->unit_direction = _S1591.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1591.refracted;
                        (&bsdf_sampled_0)->throughput = _S1591.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1592 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n)) * surface_12.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1592;
                        }
                    }
                    uint _S1593 = (&bsdf_sampled_0)->lobe;
                    float3  _S1594 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1595 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1596 = (&bsdf_sampled_0)->pdf;
                    float _S1597 = _slang_select(wrong_side_0, 0.0f,_S1596);
                    (&lobe_5)->pdf = _S1597;
                    throughput_9 = _S1594;
                    b_10 = _S1593;
                    refracted_4 = _S1595;
                }
                else
                {
                    throughput_9 = _S1567;
                    b_10 = _S1566;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1502 = true;
            }
            else
            {
                _S1502 = _S1456;
            }
            float3  chain_throughput_1;
            if(_S1502)
            {
                if(_S1421)
                {
                    SampleBSDF _S1598 = (fcptConnectHair((surface_12.hair), (_S1399.material.albedo), (_S1399.material.specular_tint), ((&ray_2)->unit_direction), (throughput_9)));
                    lobe_5 = _S1598;
                }
                else
                {
                    float3  _S1599 = (&ray_2)->unit_direction;
                    float3  _S1600 = negate_0(_S1599);
                    float _S1601 = sign_0(_S1401);
                    float3  _S1602 = _S1400.smooth_n * make_float3 (_S1601);
                    float _S1603 = dot_0(_S1602, throughput_9);
                    float _S1604 = _S1399.material.roughness;
                    float _S1605 = _S1604 * _S1604;
                    AnisotropicFrame _S1606 = anisotropicFrame(_S1399.material, _S1602);
                    SheenProfile _S1607 = sheenProfile(_S1600, _S1602, _S1399.material);
                    float3  _S1608 = reflectedHalf(_S1599, throughput_9);
                    bool _S1609 = b_10 == 1U;
                    if(_S1609)
                    {
                        float3  _S1610 = refractedHalf(_S1599, throughput_9, _S1400.smooth_n, _S1416.x, _S1416.y);
                        throughput_10 = _S1610;
                    }
                    else
                    {
                        throughput_10 = _S1608;
                    }
                    bool _S1611 = b_10 == 0U;
                    if(_S1611)
                    {
                        _S1503 = true;
                    }
                    else
                    {
                        _S1503 = b_10 == 6U;
                    }
                    if(_S1503)
                    {
                        float3  _S1612 = sampledHalf(_S1600, _S1602, _S1605, _S1606, surface_12.random_state);
                        throughput_11 = _S1612;
                    }
                    else
                    {
                        throughput_11 = throughput_10;
                    }
                    float _S1613 = _S1416.x;
                    float _S1614 = _S1416.y;
                    Weights _S1615 = lobeWeights(_S1599, _S1600, _S1602, throughput_11, _S1606, _S1607, _S1399.material, _S1613, _S1614);
                    float _S1616 = (F32_abs((_S1401)));
                    float _S1617 = vndfPDF(_S1600, throughput_11, _S1602, _S1616, _S1605, _S1606, _S1615.v_dot_h);
                    switch(b_10)
                    {
                    case 0U:
                        {
                            float _S1618 = diffusePDF(_S1603, _S1616, _S1399.material, _S1615);
                            float3  _S1619 = diffuseBSDF(throughput_9, _S1602, _S1399.material, _S1615);
                            density_6 = _S1618;
                            chain_throughput_1 = _S1619;
                            break;
                        }
                    case 1U:
                        {
                            float _S1620 = refractPDF(dot_0(throughput_9, throughput_11), _S1617, _S1615, _S1613, _S1614);
                            float3  _S1621 = refractBSDF(throughput_9, _S1602, _S1605, _S1606, _S1399.material, _S1615);
                            density_6 = _S1620;
                            chain_throughput_1 = _S1621;
                            break;
                        }
                    case 4U:
                        {
                            float _S1622 = sheenVelvetPDF(_S1603, _S1616, _S1615);
                            float3  _S1623 = sheenVelvetBSDF(throughput_9, _S1600, _S1602, _S1399.material, _S1615);
                            density_6 = _S1622;
                            chain_throughput_1 = _S1623;
                            break;
                        }
                    case 6U:
                        {
                            ToonProfile _S1624 = toonProfile(_S1600, _S1602, _S1399.material);
                            float _S1625 = toonPDF(throughput_9, _S1602, _S1624, _S1615);
                            float3  _S1626 = toonBSDF(throughput_9, _S1602, _S1624, _S1615);
                            density_6 = _S1625;
                            chain_throughput_1 = _S1626;
                            break;
                        }
                    default:
                        {
                            float _S1627 = reflectPDF(_S1617, _S1615);
                            float3  _S1628 = reflectBSDF(throughput_9, _S1602, _S1605, _S1606, _S1615);
                            density_6 = _S1627;
                            chain_throughput_1 = _S1628;
                            break;
                        }
                    }
                    bool _S1629 = density_6 > 0.0f;
                    if(_S1629)
                    {
                        SampleBSDF _S1630 = SampleBSDF_x24init_0(throughput_9, chain_throughput_1, surface_12.random_state, _S1609, b_10, density_6);
                        lobe_5 = _S1630;
                    }
                }
            }
            bool _S1631 = b_10 == 0U;
            if(_S1631)
            {
                _S1503 = true;
            }
            else
            {
                _S1503 = b_10 == 4U;
            }
            if(_S1503)
            {
                _S1549 = true;
            }
            else
            {
                _S1549 = b_10 == 6U;
            }
            if(_S1421)
            {
                _S1550 = false;
            }
            else
            {
                bool _S1632 = !_S1549;
                if(_S1632)
                {
                    bool _S1633 = (_S1399.material.roughness) == 0.0f;
                    if(_S1633)
                    {
                        _S1550 = true;
                    }
                    else
                    {
                        bool _S1634 = b_10 == 1U;
                        if(_S1634)
                        {
                            _S1550 = (_S1416.x) == (_S1416.y);
                        }
                        else
                        {
                            _S1550 = false;
                        }
                    }
                }
                else
                {
                    _S1550 = false;
                }
            }
            bool _S1635 = !_S1421;
            if(_S1635)
            {
                _S1551 = b_10 == 1U;
            }
            else
            {
                _S1551 = false;
            }
            if(_S1551)
            {
                straight_0 = (_S1399.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1552 = _S1635;
            }
            else
            {
                _S1552 = false;
            }
            if(_S1552)
            {
                _S1553 = b_10 == 1U;
            }
            else
            {
                _S1553 = false;
            }
            if(_S1553)
            {
                _S1554 = (_S1416.x) == (_S1416.y);
            }
            else
            {
                _S1554 = false;
            }
            BSDFMaterial _S1636 = _S1399.material;
            bool _S1637 = isTranslucent_0(&_S1636);
            if(_S1637)
            {
                _S1555 = _S1631;
            }
            else
            {
                _S1555 = false;
            }
            if(_S1555)
            {
                _S1556 = (dot_0(throughput_9, surface_12.geometry_n)) < 0.0f;
            }
            else
            {
                _S1556 = false;
            }
            if(nee_0)
            {
                _S1557 = !_S1550;
            }
            else
            {
                _S1557 = false;
            }
            if(_S1557)
            {
                _S1558 = !wrong_side_0;
            }
            else
            {
                _S1558 = false;
            }
            if(_S1558)
            {
                float _S1638 = (&lobe_5)->pdf;
                float3  _S1639 = (&ray_2)->origin;
                float3  _S1640 = _slang_select(_S1426, _S1224,_S1400.smooth_n);
                float3  _S1641 = (&ray_2)->origin;
                FKSurface _S1642 = surface_12;
                float3  _S1643 = - _S1400.smooth_n;
                float3  _S1644 = _slang_select(_S1556, _S1643,_S1400.smooth_n);
                NEEVertex _S1645 = NEEVertex_x24init_0(false, _S1638, _S1639, _S1640, _S1641 + make_float3 (_S1642.geometry_offset) * _S1644);
                nee_vertex_0 = _S1645;
            }
            else
            {
                if(_S1421)
                {
                    _S1559 = true;
                }
                else
                {
                    bool _S1646 = b_10 != 1U;
                    if(_S1646)
                    {
                        _S1559 = true;
                    }
                    else
                    {
                        _S1559 = (_S1416.x) != (_S1416.y);
                    }
                }
                if(_S1559)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1647 = withinInverseFootprint((&lobe_5)->pdf, _S1549, (&prev_0)->cos, (&hit_4)->distance, threshold_2);
            bool _S1648 = roughLobe((&lobe_5)->pdf, _S1549, _S1399.material.roughness);
            if(_S1456)
            {
                bool _S1649 = !_S1647;
                if(_S1649)
                {
                    return _S1225;
                }
                bool _S1650 = _S1230 != 1U;
                if(_S1650)
                {
                    _S1559 = _S1230 != 2U;
                }
                else
                {
                    _S1559 = false;
                }
                if(_S1559)
                {
                    float _S1651 = (&lobe_5)->pdf;
                    float _S1652 = _slang_select(nee_0, _S1651,0.0f);
                    float _S1653 = escapeWeight_0(_S1652, _S1567);
                    if(_S1464)
                    {
                        passes_0 = _S1236;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1654 = _slang_select(passes_0, _S1653,1.0f);
                    return Shift_x24init_0(throughput_7 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_8->radiance * make_float3 (_S1654) / make_float3 (r_8->jac), density_4 * (&lobe_5)->pdf / r_8->jac);
                }
                float3  _S1655 = throughput_7 * make_float3 ((&lobe_5)->pdf);
                float _S1656 = density_4 * (&lobe_5)->pdf;
                throughput_10 = _S1655;
                density_6 = _S1656;
            }
            else
            {
                throughput_10 = throughput_7;
                density_6 = density_4;
            }
            uint _S1657 = (fcptLayers((hit_4)));
            bool _S1658 = b_10 == 1U;
            bool _S1659 = passesLayer_0(_S1657, _S1658, passes_0);
            if(viewed_1)
            {
                _S1559 = _S1659;
            }
            else
            {
                _S1559 = false;
            }
            if(_S1559)
            {
                return _S1225;
            }
            if(replay_2)
            {
                _S1560 = b_7 <= _S1240;
            }
            else
            {
                _S1560 = false;
            }
            if(_S1560)
            {
                _S1561 = _S1398;
            }
            else
            {
                _S1561 = false;
            }
            if(_S1561)
            {
                _S1562 = _S1647;
            }
            else
            {
                _S1562 = false;
            }
            if(_S1562)
            {
                _S1563 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1563 = !_S1648;
                }
                else
                {
                    _S1563 = false;
                }
            }
            if(_S1563)
            {
                return _S1225;
            }
            if(viewed_1)
            {
                float3  _S1660 = throughput_10 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1661 = (&lobe_5)->pdf;
                throughput_11 = _S1660;
                sky_pdf_2 = _S1661;
            }
            else
            {
                float3  _S1662 = throughput_10 * max_0((&lobe_5)->throughput, _S1224);
                throughput_11 = _S1662;
                sky_pdf_2 = density_6;
            }
            bool _S1663;
            if(_S1430)
            {
                _S1663 = !_S1444;
            }
            else
            {
                _S1663 = false;
            }
            bool _S1664;
            if(_S1663)
            {
                _S1664 = _S1398;
            }
            else
            {
                _S1664 = false;
            }
            bool _S1665;
            if(_S1664)
            {
                _S1665 = _S1647;
            }
            else
            {
                _S1665 = false;
            }
            if(_S1665)
            {
                chain_0 = here_0;
                uint _S1666 = insertBits_0((&chain_0)->path, b_10, 18U, 3U);
                uint _S1667 = _slang_select(nee_0, 1U,0U);
                uint _S1668 = insertBits_0(_S1666, _S1667, 21U, 1U);
                (&chain_0)->path = _S1668;
                float _S1669 = (&chain_0)->jac * (&lobe_5)->pdf;
                (&chain_0)->jac = _S1669;
                (&chain_0)->dir = throughput_9;
                chain_throughput_1 = throughput_11;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1670 = surface_12;
            Vertex _S1671 = Vertex_x24init_0(_S1648, b_10, (&lobe_5)->pdf, (F32_abs((dot_0(surface_12.geometry_n, throughput_9)))), is_inside_7);
            prev_0 = _S1671;
            float _S1672 = (&lobe_5)->pdf;
            bool _S1673;
            if(_S1658)
            {
                _S1673 = (_S1416.x) == (_S1416.y);
            }
            else
            {
                _S1673 = false;
            }
            float sky_pdf_3 = _slang_select(_S1673, sky_pdf_0,_S1672);
            float _S1674 = _slang_select(_S1421, 0.0f,sky_pdf_3);
            float _S1675 = widened_0(spread_2, (&lobe_5)->pdf, _S1550);
            bool _S1676;
            if(refracted_4)
            {
                _S1676 = !_S1556;
            }
            else
            {
                _S1676 = false;
            }
            bool is_inside_8;
            if(_S1676)
            {
                bool _S1677 = !is_inside_7;
                is_inside_8 = _S1677;
            }
            else
            {
                is_inside_8 = is_inside_7;
            }
            FKSurface _S1678 = surface_12;
            bool _S1679 = boundsVolume_0(&_S1678);
            bool _S1680;
            if(_S1679)
            {
                _S1680 = !_S1659;
            }
            else
            {
                _S1680 = false;
            }
            if(_S1680)
            {
                FKSurface faced_2 = surface_12;
                float3  _S1681 = - _S1670.geometry_n;
                float3  _S1682 = _slang_select(turned_1, _S1681,_S1670.geometry_n);
                (&faced_2)->geometry_n = _S1682;
                FKMedium _S1683 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1684 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1685 = faced_2;
                FKMedium _S1686 = _S1683;
                FKMedium _S1687 = _S1684;
                MediumSides _S1688 = mediumSides_0(&_S1685, &_S1686, filling_2, (&ray_2)->unit_direction, &_S1687);
                bool _S1689 = leavesInFront_0((&faced_2)->geometry_n, throughput_9, _S1670.geometry_n);
                float3  _S1690 = _slang_select(_S1689, _S1688.front.scatter,_S1688.behind.scatter);
                scatter_in_0 = _S1690;
                float3  _S1691 = _slang_select(_S1689, _S1688.front.extinction,_S1688.behind.extinction);
                extinction_in_0 = _S1691;
                float _S1692 = _slang_select(_S1689, _S1688.front.g,_S1688.behind.g);
                g_in_0 = _S1692;
                uint _S1693 = _S1688.fillings.x;
                uint _S1694 = _S1688.fillings.y;
                uint _S1695 = _slang_select(_S1689, _S1694,_S1693);
                bool _S1696 = (fcptVaryingUsed());
                uint _S1697 = _slang_select(_S1696, _S1695,4294967295U);
                filling_2 = _S1697;
            }
            (&ray_2)->unit_direction = throughput_9;
            bool _S1698 = !_S1659;
            if(_S1698)
            {
                FKSurface _S1699 = surface_12;
                float _S1700 = _slang_select(straight_0, 0.0f,_S1699.geometry_offset);
                float3  _S1701 = - _S1400.smooth_n;
                bool _S1702 = is_inside_8 != _S1556;
                float3  _S1703 = _slang_select(_S1702, _S1701,_S1400.smooth_n);
                float3  _S1704 = (&ray_2)->origin + make_float3 (_S1700) * _S1703;
                (&ray_2)->origin = _S1704;
            }
            throughput_10 = throughput_11;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1659;
            viewed_1 = _S1554;
            sky_pdf_2 = _S1674;
            spread_5 = _S1675;
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
        if(_S1430)
        {
            if(_S1366)
            {
                float3  _S1705 = throughput_10 * emission_1;
                Reservoir candidate_8 = chain_0;
                uint _S1706 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1707 = _S1706 == 1U;
                if(_S1707)
                {
                    float3  _S1708 = safeDivide(_S1705, chain_throughput_0);
                    (&candidate_8)->radiance = _S1708;
                }
                Reservoir _S1709 = withEnd(candidate_8, 2U, b_7, _S1705);
                offer(sel_7, _S1709, _S1705 * make_float3 (scale_3) / make_float3 (density_6));
            }
            if(_S1366)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1710 = survivalProbability(abs_0(throughput_10), density_6);
                density_7 = _S1710;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1711 = stream(_S1252, b_7 + 128U);
            Random _S1712 = pcg(_S1711);
            bool _S1713 = density_7 < (_S1712.value);
            if(_S1713)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1714 = (fcptMaxBounces());
                wrong_side_0 = b_7 >= _S1714;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1715 = density_6 * density_7;
            density_7 = _S1715;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1716 = layer_0 ^ 1U;
        uint _S1717 = _slang_select(passes_0, _S1716,0U);
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
            uint _S1718 = b_10 + 1U;
            b_7 = _S1718;
            layer_0 = _S1717;
            continue;
        }
        FKRay _S1719 = ray_2;
        float _S1720 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_2)
        {
            refracted_4 = _S1457;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S1229 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1721 = _slang_select(wrong_side_0, _S1720,4.294967296e+09f);
        bool _S1722 = !_S1421;
        if(straight_0)
        {
            _S1502 = true;
        }
        else
        {
            _S1502 = _S1421;
        }
        FKHit _S1723;
        if(_S1502)
        {
            _S1723 = hit_4;
        }
        else
        {
            _S1723 = _S1474;
        }
        FKHit _S1724 = (fcptTraverseInstanceBVH((_S1719), (_S1374), (_S1721), (_S1722), (_S1723), (viewed_1)));
        hit_4 = _S1724;
        if(replay_2)
        {
            _S1503 = _S1457;
        }
        else
        {
            _S1503 = false;
        }
        if(_S1503)
        {
            _S1549 = _S1229 == 1U;
        }
        else
        {
            _S1549 = false;
        }
        if(_S1549)
        {
            _S1550 = ((&hit_4)->instance_index) == (_S1241.instance_index);
        }
        else
        {
            _S1550 = false;
        }
        if(_S1550)
        {
            _S1551 = ((&hit_4)->triangle_index) == (_S1241.triangle_index);
        }
        else
        {
            _S1551 = false;
        }
        if(_S1551)
        {
            (&hit_4)->uv = _S1241.uv;
            float _S1725 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S1725;
        }
        if(replay_2)
        {
            _S1552 = _S1457;
        }
        else
        {
            _S1552 = false;
        }
        if(_S1552)
        {
            _S1553 = _S1229 == 3U;
        }
        else
        {
            _S1553 = false;
        }
        if(_S1553)
        {
            _S1554 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1554 = false;
        }
        if(_S1554)
        {
            return _S1225;
        }
        Reservoir _S1726 = chain_0;
        uint _S1727 = filling_2;
        for(;;)
        {
            bool _S1728 = (fcptVaryingUsed());
            if(_S1728)
            {
                _S1555 = _S1727 != 4294967295U;
            }
            else
            {
                _S1555 = false;
            }
            float _S1729;
            if(_S1555)
            {
                float _S1730 = (fcptMajorant((_S1727)));
                _S1729 = _S1730;
            }
            else
            {
                _S1729 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_2)
            {
                _S1556 = _S1457;
            }
            else
            {
                _S1556 = false;
            }
            if(_S1556)
            {
                _S1557 = _S1229 == 1U;
            }
            else
            {
                _S1557 = false;
            }
            if(_S1557)
            {
                _S1558 = _S1729 > 0.0f;
            }
            else
            {
                _S1558 = false;
            }
            if(_S1558)
            {
                ended_0 = _S1225;
                sky_pdf_1 = sky_pdf_2;
                spread_3 = spread_5;
                width_4 = width_3;
                density_3 = density_7;
                throughput_11 = throughput_10;
                b_10 = b_7;
                _S1559 = true;
                break;
            }
            bool _S1731 = (&prev_0)->rough;
            if(_S1731)
            {
                _S1559 = !(_S1729 > 0.0f);
            }
            else
            {
                _S1559 = false;
            }
            (&prev_0)->rough = _S1559;
            uint _S1732 = b_7 + 320U;
            bool _S1733 = b_7 == 4294967295U;
            uint _S1734 = _slang_select(_S1733, 384U,_S1732);
            uint _S1735 = stream(_S1252, _S1734);
            uint tracking_1 = _S1735;
            weight_1 = throughput_3;
            glowed_0 = _S1224;
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
                    _S1223 = int(2);
                    break;
                }
                uint _S1736 = b_10 + 320U;
                bool _S1737 = b_10 == 4294967295U;
                uint _S1738 = _slang_select(_S1737, 384U,_S1736);
                uint _S1739 = stream(_S1252, _S1738);
                Random _S1740 = pcg(_S1739);
                float _S1741 = freeFlight_0(_S1740.value, _S1729);
                if(_S1555)
                {
                    float3  _S1742 = (&ray_2)->origin;
                    float3  _S1743 = (&ray_2)->unit_direction;
                    float _S1744 = (&hit_4)->distance;
                    uint _S1745 = _slang_select(_S1737, 0U,b_10);
                    uint _S1746 = (&prev_0)->lobe;
                    uint _S1747 = _slang_select(_S1737, 3U,_S1746);
                    float _S1748 = (fcptTrackMedium((_S1727), (_S1742), (_S1743), (_S1744), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1745), (_S1747), (_S1737)));
                    spread_4 = _S1748;
                }
                else
                {
                    spread_4 = _S1741;
                }
                bool _S1749 = !(spread_4 < ((&hit_4)->distance));
                if(_S1749)
                {
                    _S1223 = int(2);
                    break;
                }
                if(_S1555)
                {
                    _S1560 = _S1430;
                }
                else
                {
                    _S1560 = false;
                }
                if(_S1560)
                {
                    float3  _S1750 = throughput_11 * glowed_0 / make_float3 (density_3);
                    float3  _S1751 = sel_7->glow + _S1750;
                    sel_7->glow = _S1751;
                }
                else
                {
                }
                glowed_0 = _S1224;
                uint b_11 = b_10 + 1U;
                float3  _S1752 = (&ray_2)->origin + make_float3 (spread_4) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1752;
                float3  _S1753 = flightWeight_0(scatter_in_0, extinction_in_0, _S1729, spread_4, true);
                float3  _S1754 = weight_1;
                float3  _S1755 = _slang_select(_S1555, _S1754,_S1753);
                float3  throughput_12 = throughput_11 * _S1755;
                uint _S1756 = stream(_S1252, b_11 + 320U);
                tracking_1 = _S1756;
                weight_1 = throughput_3;
                float width_7 = width_4 + spread_3 * spread_4;
                float _S1757 = spread_3 + 3.14159274101257324f;
                bool _S1758 = scatterSampled_0(replay_2, b_11, _S1240, _S1555);
                TreeSample light_4;
                if(_S1758)
                {
                    float3  _S1759 = (&ray_2)->origin;
                    float3  _S1760 = (&ray_2)->unit_direction;
                    float3  _S1761 = (&ray_2)->unit_direction;
                    uint _S1762 = stream(_S1252, b_11 + 64U);
                    float3  _S1763 = extinction_in_0;
                    float3  _S1764 = extinction_in_0;
                    uint2  _S1765 = make_uint2 (_S1727);
                    float3  _S1766 = (&ray_2)->unit_direction;
                    uint _S1767 = arrivalLobe_0(b_11, (&prev_0)->lobe);
                    FKHit _S1768 = _S1474;
                    ShadowContext _S1769 = ShadowContext_x24init_0(_S1763, _S1764, _S1765, _S1766, b_11, _S1767, false, spread_4, width_7, &_S1768, false);
                    ShadowContext _S1770 = _S1769;
                    TreeSample _S1771 = sampleLightTree_0(_S1759, _S1760, _S1761, 0.0f, true, _S1762, &_S1770);
                    light_4 = _S1771;
                }
                else
                {
                    light_4 = _S1471;
                }
                float _S1772 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1773 = (fcptMaxBounces());
                bool _S1774 = b_11 < _S1773;
                if(_S1774)
                {
                    _S1561 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1561 = false;
                }
                float _S1775 = _slang_select(_S1561, _S1772,0.0f);
                float3  _S1776 = throughput_12 * light_4.radiance;
                float _S1777 = powerHeuristic(light_4.density, _S1775);
                float3  _S1778 = _S1776 * make_float3 (_S1772 * _S1777);
                float3  _S1779 = _slang_select(_S1758, _S1778,_S1224);
                if(replay_2)
                {
                    _S1562 = b_11 == _S1240;
                }
                else
                {
                    _S1562 = false;
                }
                if(_S1562)
                {
                    bool _S1780 = _S1229 == 2U;
                    if(_S1780)
                    {
                        float _S1781 = resamplingTarget(_S1779);
                        _S1563 = _S1781 > 0.0f;
                    }
                    else
                    {
                        _S1563 = false;
                    }
                    if(_S1563)
                    {
                        Shift _S1782 = Shift_x24init_0(_S1779, 1.0f);
                        _S1223 = int(1);
                        ended_0 = _S1782;
                        spread_4 = _S1757;
                        width_5 = width_7;
                        throughput_9 = throughput_12;
                        b_8 = b_11;
                        break;
                    }
                    _S1223 = int(1);
                    ended_0 = _S1225;
                    spread_4 = _S1757;
                    width_5 = width_7;
                    throughput_9 = throughput_12;
                    b_8 = b_11;
                    break;
                }
                if(_S1430)
                {
                    Reservoir candidate_9 = _S1726;
                    uint _S1783 = extractBits_0(_S1726.path, 10U, 2U);
                    bool _S1784 = _S1783 == 1U;
                    if(_S1784)
                    {
                        float3  _S1785 = safeDivide(_S1779, chain_throughput_0);
                        (&candidate_9)->radiance = _S1785;
                    }
                    else
                    {
                        uint _S1786 = insertBits_0(0U, b_11 + 1U, 5U, 5U);
                        uint _S1787 = insertBits_0(_S1786, 2U, 10U, 2U);
                        (&candidate_9)->path = _S1787;
                    }
                    Reservoir _S1788 = withEnd(candidate_9, 0U, b_11, _S1779);
                    offer(sel_7, _S1788, _S1779 * make_float3 (scale_3) / make_float3 (density_3));
                    float _S1789 = survivalProbability(abs_0(throughput_12), density_3);
                    uint _S1790 = stream(_S1252, b_11 + 128U);
                    Random _S1791 = pcg(_S1790);
                    bool _S1792 = _S1789 < (_S1791.value);
                    if(_S1792)
                    {
                        _S1563 = true;
                    }
                    else
                    {
                        uint _S1793 = (fcptMaxBounces());
                        _S1563 = b_11 >= _S1793;
                    }
                    if(_S1563)
                    {
                        _S1223 = int(1);
                        ended_0 = _S1225;
                        spread_4 = _S1757;
                        width_5 = width_7;
                        throughput_9 = throughput_12;
                        b_8 = b_11;
                        break;
                    }
                    float _S1794 = density_3 * _S1789;
                    density_3 = _S1794;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1795 = stream(_S1252, b_11);
                float3  _S1796 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1795, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1796;
                NEEVertex _S1797 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1224, (&ray_2)->origin);
                nee_vertex_0 = _S1797;
                Vertex _S1798 = scatteredVertex_0(is_inside_6);
                prev_0 = _S1798;
                float _S1799 = (&prev_0)->pdf;
                FKRay _S1800 = ray_2;
                FKHit _S1801 = (fcptTraverseInstanceBVH((_S1800), (true), (4.294967296e+09f), (false), (_S1474), (false)));
                hit_4 = _S1801;
                b_10 = b_11;
                throughput_11 = throughput_12;
                spread_3 = _S1757;
                width_4 = width_7;
                sky_pdf_1 = _S1799;
            }
            if(_S1223 != int(2))
            {
                spread_3 = spread_4;
                width_4 = width_5;
                throughput_11 = throughput_9;
                b_10 = b_8;
                _S1559 = true;
                break;
            }
            ended_0 = _S1225;
            _S1559 = false;
            break;
        }
        if(_S1559)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1560 = b_10 == b_7;
        }
        else
        {
            _S1560 = false;
        }
        bool _S1802 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S1802)
        {
            bool _S1803 = !(&nee_vertex_0)->none;
            float _S1804 = _slang_select(_S1803, sky_pdf_1,0.0f);
            float _S1805 = escapeWeight_0(_S1804, (&ray_2)->unit_direction);
            float3  _S1806 = environment_0((&ray_2)->unit_direction, b_10, (&prev_0)->lobe);
            float3  _S1807 = throughput_11 * _S1806;
            if(replay_2)
            {
                bool _S1808 = b_10 == _S1240;
                if(_S1808)
                {
                    passes_0 = _S1229 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1807 * make_float3 (_S1805) / make_float3 (r_8->jac), density_3 / r_8->jac);
                }
                if(_S1239)
                {
                    passes_0 = _S1236;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_10 == _S1227;
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
                    return Shift_x24init_0(_S1807 * make_float3 (_S1805), 1.0f);
                }
                return _S1225;
            }
            Reservoir candidate_10 = chain_0;
            uint _S1809 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1810 = _S1809 == 1U;
            if(_S1810)
            {
                uint _S1811 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1812 = _S1811 == b_10;
                float _S1813 = _slang_select(_S1812, 1.0f,_S1805);
                float3  _S1814 = safeDivide(_S1807 * make_float3 (_S1813), chain_throughput_0);
                (&candidate_10)->radiance = _S1814;
            }
            else
            {
                bool _S1815 = (&prev_0)->rough;
                if(_S1815)
                {
                    uint _S1816 = insertBits_0(0U, b_10 + 1U, 5U, 5U);
                    uint _S1817 = insertBits_0(_S1816, 3U, 10U, 2U);
                    uint _S1818 = insertBits_0(_S1817, (&prev_0)->lobe, 15U, 3U);
                    bool _S1819 = (&prev_0)->inside;
                    uint _S1820 = _slang_select(_S1819, 1U,0U);
                    uint _S1821 = insertBits_0(_S1818, _S1820, 22U, 1U);
                    (&candidate_10)->path = _S1821;
                    (&candidate_10)->jac = (&prev_0)->pdf;
                    (&candidate_10)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1822 = _S1807 * make_float3 (_S1805);
            Reservoir _S1823 = withEnd(candidate_10, 3U, b_10, _S1822);
            offer(sel_7, _S1823, _S1822 * make_float3 (scale_3) / make_float3 (density_3));
            break;
        }
        float3  _S1824 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1824;
        bool _S1825 = (fcptVaryingUsed());
        if(_S1825)
        {
            _S1561 = filling_2 != 4294967295U;
        }
        else
        {
            _S1561 = false;
        }
        if(_S1561)
        {
            if(_S1430)
            {
                float3  _S1826 = throughput_11 * glowed_0 / make_float3 (density_3);
                float3  _S1827 = sel_7->glow + _S1826;
                sel_7->glow = _S1827;
            }
            float3  _S1828 = throughput_11 * weight_1;
            throughput_9 = _S1828;
        }
        else
        {
            float3  _S1829 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S1830 = throughput_11 * _S1829;
            throughput_9 = _S1830;
        }
        float _S1831 = width_4 + spread_3 * (&hit_4)->distance;
        viewed_0 = _S1560;
        width_3 = _S1831;
        throughput_2 = throughput_9;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_2 = spread_3;
        uint _S1718 = b_10 + 1U;
        b_7 = _S1718;
        layer_0 = _S1717;
    }
    return _S1225;
}

static __device__ Shift shift_0(Domain * dom_8, Reservoir * r_9)
{
    Selection _S1832 = (Selection{});
    Selection sel_8 = _S1832;
    bool _S1833 = (r_9->w) <= 0.0f;
    if(_S1833)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S1834 = walk_0(dom_8, r_9, true, 0.0f, &sel_8);
    return _S1834;
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
        *_slang_vector_get_element_ptr(&result_15, i_27) = (F32_tan((_slang_vector_get_element(x_27, i_27))));
        i_27 = i_27 + int(1);
    }
    return result_15;
}

static __device__ float3  acos_0(float3  x_28)
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
        *_slang_vector_get_element_ptr(&result_16, i_28) = (F32_acos((_slang_vector_get_element(x_28, i_28))));
        i_28 = i_28 + int(1);
    }
    return result_16;
}

__device__ Random normal_distribution(uint state_4)
{
    Random _S1835 = pcg(state_4);
    Random _S1836 = pcg(_S1835.state);
    float _S1837 = 6.28318548202514648f * _S1835.value;
    float _S1838 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S1836.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1836.state, _S1838 * (F32_cos((_S1837))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_5, float3  value_2)
{
    RandomSphere _S1839;
    (&_S1839)->state = state_5;
    (&_S1839)->value = value_2;
    return _S1839;
}

__device__ RandomSphere random_sphere(uint state_6)
{
    Random _S1840 = normal_distribution(state_6);
    Random _S1841 = normal_distribution(_S1840.state);
    Random _S1842 = normal_distribution(_S1841.state);
    float3  _S1843 = make_float3 (_S1840.value, _S1841.value, _S1842.value);
    float3  _S1844 = ((((_S1843)) * make_float3(rnorm3df(((_S1843)).x, ((_S1843)).y, ((_S1843)).z))));
    return RandomSphere_x24init_0(_S1842.state, _S1844);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_11)
{
    float3  _S1845 = p1_0 - p0_0;
    float3  _S1846 = p2_0 - p0_0;
    float2  _S1847 = uv1_0 - uv0_0;
    float2  _S1848 = uv2_0 - uv0_0;
    float _S1849 = _S1847.x;
    float _S1850 = _S1848.y;
    float _S1851 = _S1847.y;
    float _S1852 = _S1848.x;
    float _S1853 = _S1849 * _S1850 - _S1851 * _S1852;
    float _S1854 = 1.0f / _S1853;
    float3  t_24 = (_S1845 * make_float3 (_S1850) - _S1846 * make_float3 (_S1851)) * make_float3 (_S1854);
    float3  _S1855 = (_S1846 * make_float3 (_S1849) - _S1845 * make_float3 (_S1852)) * make_float3 (_S1854);
    float3  _S1856 = t_24 - n_11 * make_float3 (dot_0(n_11, t_24));
    float3  t_25 = ((((_S1856)) * make_float3(rnorm3df(((_S1856)).x, ((_S1856)).y, ((_S1856)).z))));
    bool _S1857 = (dot_0(cross_0(n_11, t_25), _S1855)) > 0.0f;
    float3  t_26;
    if(_S1857)
    {
        float3  _S1858 = negate_0(t_25);
        t_26 = _S1858;
    }
    else
    {
        t_26 = t_25;
    }
    float3  _S1859 = cross_0(n_11, t_26);
    return makeMatrix<float, 3, 3> (t_26, _S1859, n_11);
}

__device__ float3  tangentToWorldNormalMap(float3  v_10, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_10, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_5, float3  uvw_0, float3  position_0)
{
    float3  _S1860 = t1_0 - t0_0;
    float3  _S1861 = t2_2 - t0_0;
    float3  _S1862 = t2_2 - t1_0;
    float _S1863 = (F32_min((length_0(_S1860)), ((F32_min((length_0(_S1861)), (length_0(_S1862)))))));
    float3  _S1864 = make_float3 (distance_1(position_0, t0_0), distance_1(position_0, t1_0), distance_1(position_0, t2_2));
    float3  _S1865 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1866 = dot_0(geometry_n_5, _S1865);
    float3  _S1867 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1868 = dot_0(geometry_n_5, _S1867);
    float3  _S1869 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1870 = acos_0(abs_0(make_float3 (_S1866, _S1868, dot_0(geometry_n_5, _S1869))));
    float3  _S1871 = clamp_2(tan_0(_S1870), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S1864 * _S1871, uvw_0), 0.0f, _S1863 * 0.125f);
}

__device__ float3  straightThrough(float3  dir_15, float3  n_12, BSDFMaterial material_21)
{
    float3  _S1872 = negate_0(dir_15);
    float _S1873 = sign_0(dot_0(n_12, _S1872));
    float3  _S1874 = n_12 * make_float3 (_S1873);
    AnisotropicFrame _S1875 = anisotropicFrame(material_21, _S1874);
    bool _S1876 = (_S1875.alphas.x) > 0.0f;
    if(_S1876)
    {
        float _S1877 = material_21.transmission * (1.0f - material_21.metallic);
        float3  _S1878 = negate_0(_S1874);
        float3  _S1879 = anisotropicLocal(dir_15, _S1875.tangent, _S1878);
        float _S1880 = anisotropicG1(_S1879, _S1875.alphas);
        return make_float3 (_S1877 * _S1880) * material_21.albedo;
    }
    float _S1881 = material_21.transmission * (1.0f - material_21.metallic);
    float _S1882 = material_21.roughness;
    float _S1883 = smithG1(_S1882 * _S1882, (F32_abs((dot_0(n_12, dir_15)))));
    return make_float3 (_S1881 * _S1883) * material_21.albedo;
}

__device__ float hairRow(float3  in_dir_10, float3  t_27, float3  out_dir_3, uint p_14, float w_19, float alpha_10, uint nt_0)
{
    uint _S1884 = p_14 % 4U;
    float _S1885 = w_19 * HAIR_WIDTHS_0[_S1884];
    float _S1886 = (F32_asin((clamp_1(dot_0(out_dir_3, t_27), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_10, t_27), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1884] * alpha_10;
    return ((F32_asinh((_S1886 / _S1885))) / (F32_asinh((3.14159274101257324f / _S1885))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_11, float3  t_28, float3  out_dir_4, uint np_0)
{
    float3  _S1887 = worldToTangent(out_dir_4, t_28);
    float3  _S1888 = worldToTangent(in_dir_11, t_28);
    return (F32_frac((((F32_atan2((_S1887.z), (_S1887.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1888.z), (1.17549435082228751e-38f - _S1888.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_12, float3  t_29, uint p_15, float row_0, float column_0, float w_20, float alpha_11, uint nt_1, uint np_1)
{
    float3  _S1889 = worldToTangent(in_dir_12, t_29);
    uint _S1890 = p_15 % 4U;
    float _S1891 = w_20 * HAIR_WIDTHS_0[_S1890];
    float _S1892 = (F32_asin((clamp_1(dot_0(in_dir_12, t_29), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1890] * alpha_11 + _S1891 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1891))))));
    float _S1893 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1889.z), (1.17549435082228751e-38f - _S1889.x)));
    float _S1894 = (F32_cos((_S1892)));
    float3  _S1895 = tangentToWorld(make_float3 (_S1894 * (F32_cos((_S1893))), (F32_sin((_S1892))), _S1894 * (F32_sin((_S1893)))), t_29);
    return _S1895;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_13, BSDFMaterial material_22, float coverage_1)
{
    float3  _S1896;
    if((material_22.ior) == 1.0f)
    {
        float3  _S1897 = straightThrough(toward_1, n_13, material_22);
        _S1896 = _S1897;
    }
    else
    {
        _S1896 = make_float3 (0.0f);
    }
    return _S1896 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_9, Reservoir r_10, bool replay_3, float scale_4, Selection * sel_9)
{
    Domain _S1898 = dom_9;
    Reservoir _S1899 = r_10;
    Shift _S1900 = walk_0(&_S1898, &_S1899, replay_3, scale_4, sel_9);
    return _S1900;
}

__device__ Shift shift_hook(Domain dom_10, Reservoir r_11)
{
    Domain _S1901 = dom_10;
    Reservoir _S1902 = r_11;
    Shift _S1903 = shift_0(&_S1901, &_S1902);
    return _S1903;
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
