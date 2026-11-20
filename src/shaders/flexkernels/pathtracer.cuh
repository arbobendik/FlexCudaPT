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

static __device__ float3  negate_0(float3  x_13)
{
    return - x_13;
}

static __device__ float sign_0(float e_1)
{
    float _S316;
    if(e_1 > 0.0f)
    {
        _S316 = 1.0f;
    }
    else
    {
        if(e_1 < 0.0f)
        {
            _S316 = -1.0f;
        }
        else
        {
            _S316 = 0.0f;
        }
    }
    return _S316;
}

struct AnisotropicFrame
{
    float3  tangent;
    float2  alphas;
};

static __device__ AnisotropicFrame AnisotropicFrame_x24init_0(float3  tangent_0, float2  alphas_0)
{
    AnisotropicFrame _S317;
    (&_S317)->tangent = tangent_0;
    (&_S317)->alphas = alphas_0;
    return _S317;
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_1)
{
    float3  a_1 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S318 = (F32_abs((dot_0(n_1, a_1)))) > 0.9999847412109375f;
    float3  a_2;
    if(_S318)
    {
        float3  _S319 = make_float3 (1.0f, 0.0f, 0.0f);
        a_2 = _S319;
    }
    else
    {
        a_2 = a_1;
    }
    float3  _S320 = cross_0(n_1, a_2);
    float3  _S321 = ((((_S320)) * make_float3(rnorm3df(((_S320)).x, ((_S320)).y, ((_S320)).z))));
    float3  _S322 = cross_0(n_1, _S321);
    return make_float3 (v_0.x) * _S321 + make_float3 (v_0.y) * n_1 + make_float3 (v_0.z) * _S322;
}

__device__ AnisotropicFrame anisotropicFrame(BSDFMaterial material_1, float3  n_i_0)
{
    float _S323 = material_1.roughness;
    float _S324 = _S323 * _S323;
    bool _S325 = (material_1.anisotropy) == 0.0f;
    bool _S326;
    if(_S325)
    {
        _S326 = true;
    }
    else
    {
        _S326 = !(_S324 > 0.0f);
    }
    if(_S326)
    {
        return AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f));
    }
    float3  _S327 = material_1.tangent - n_i_0 * make_float3 (dot_0(n_i_0, material_1.tangent));
    float3  _S328 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_i_0);
    bool _S329 = (dot_0(_S327, _S327)) > 0.0f;
    float3  _S330 = _slang_select(_S329, _S327,_S328);
    float3  _S331 = ((((_S330)) * make_float3(rnorm3df(((_S330)).x, ((_S330)).y, ((_S330)).z))));
    float _S332 = 6.28318548202514648f * material_1.anisotropic_rotation;
    float _S333 = (F32_sqrt((1.0f - 0.89999997615814209f * (F32_abs((material_1.anisotropy))))));
    float _S334 = 1.0f / _S333;
    bool _S335 = (material_1.anisotropy) < 0.0f;
    float _S336 = _slang_select(_S335, _S334,_S333);
    return AnisotropicFrame_x24init_0(_S331 * make_float3 ((F32_cos((_S332)))) + cross_0(n_i_0, _S331) * make_float3 ((F32_sin((_S332)))), make_float2 (_S324 / _S336, _S324 * _S336));
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

static __device__ ViewTerms ViewTerms_x24init_0(float3  v_1, float3  n_i_1, AnisotropicFrame * frame_0, float3  scale_1, float sheen_component_0, float3  sheen_0, float3  view_0, float3  rebounce_0, float toon_view_0, float3  toon_axis_0)
{
    ViewTerms _S337;
    (&_S337)->v = v_1;
    (&_S337)->n_i = n_i_1;
    (&_S337)->frame = *frame_0;
    (&_S337)->scale = scale_1;
    (&_S337)->sheen_component = sheen_component_0;
    (&_S337)->sheen = sheen_0;
    (&_S337)->view = view_0;
    (&_S337)->rebounce = rebounce_0;
    (&_S337)->toon_view = toon_view_0;
    (&_S337)->toon_axis = toon_axis_0;
    return _S337;
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

__device__ float3  anisotropicLocal(float3  w_0, float3  t_12, float3  n_2)
{
    return make_float3 (dot_0(w_0, t_12), dot_0(w_0, cross_0(n_2, t_12)), dot_0(w_0, n_2));
}

static __device__ float unshared_0(float x_15)
{
    return x_15;
}

__device__ float3  sampleGGXVNDF(float3  Ve_0, float alpha_0, float U1_0, float U2_0)
{
    float3  _S338 = make_float3 (alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z);
    float3  _S339 = ((((_S338)) * make_float3(rnorm3df(((_S338)).x, ((_S338)).y, ((_S338)).z))));
    float _S340 = _S339.x;
    float _S341 = _S339.y;
    float _S342 = _S340 * _S340 + _S341 * _S341;
    float3  _S343;
    if(_S342 > 0.0f)
    {
        float3  _S344 = make_float3 (- _S341, _S340, 0.0f);
        float _S345 = (rsqrtf((_S342)));
        _S343 = _S344 * make_float3 (_S345);
    }
    else
    {
        _S343 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S346 = cross_0(_S339, _S343);
    float _S347 = (F32_sqrt((U1_0)));
    float _S348 = 6.28318548202514648f * U2_0;
    float _S349 = _S347 * (F32_cos((_S348)));
    float t2_0 = _S347 * (F32_sin((_S348)));
    float _S350 = 0.5f * (1.0f + _S339.z);
    float t2_1 = (1.0f - _S350) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S349 * _S349)))))) + _S350 * t2_0;
    float3  _S351 = make_float3 (_S349) * _S343 + make_float3 (t2_1) * _S346;
    float _S352 = unshared_0(_S349);
    float _S353 = unshared_0(_S349);
    float3  _S354 = _S351 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S352 * _S353 - t2_1 * t2_1))))))) * _S339;
    float3  _S355 = make_float3 (alpha_0 * _S354.x, alpha_0 * _S354.y, (F32_max((0.0f), (_S354.z))));
    float3  _S356 = ((((_S355)) * make_float3(rnorm3df(((_S355)).x, ((_S355)).y, ((_S355)).z))));
    return _S356;
}

__device__ float3  worldToTangent(float3  v_2, float3  n_3)
{
    float3  a_3 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S357 = (F32_abs((dot_0(n_3, a_3)))) > 0.9999847412109375f;
    float3  a_4;
    if(_S357)
    {
        float3  _S358 = make_float3 (1.0f, 0.0f, 0.0f);
        a_4 = _S358;
    }
    else
    {
        a_4 = a_3;
    }
    float3  _S359 = cross_0(n_3, a_4);
    float3  _S360 = ((((_S359)) * make_float3(rnorm3df(((_S359)).x, ((_S359)).y, ((_S359)).z))));
    float3  _S361 = cross_0(n_3, _S360);
    return make_float3 (dot_0(v_2, _S360), dot_0(v_2, n_3), dot_0(v_2, _S361));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_3, float3  n_i_2, float alpha_1, AnisotropicFrame frame_1, uint * random_state_2)
{
    Random _S362 = pcg(*random_state_2);
    Random _S363 = pcg(_S362.state);
    *random_state_2 = _S363.state;
    float _S364 = frame_1.alphas.x;
    bool _S365 = _S364 > 0.0f;
    if(_S365)
    {
        float3  _S366 = anisotropicLocal(v_3, frame_1.tangent, n_i_2);
        float _S367 = frame_1.alphas.y;
        float3  _S368 = make_float3 (_S364 * _S366.x, _S367 * _S366.y, _S366.z);
        float3  _S369 = ((((_S368)) * make_float3(rnorm3df(((_S368)).x, ((_S368)).y, ((_S368)).z))));
        float3  _S370 = sampleGGXVNDF(_S369, 1.0f, _S362.value, _S363.value);
        float3  _S371 = make_float3 (_S364 * _S370.x, _S367 * _S370.y, _S370.z);
        float3  _S372 = ((((_S371)) * make_float3(rnorm3df(((_S371)).x, ((_S371)).y, ((_S371)).z))));
        return make_float3 (_S372.x) * frame_1.tangent + make_float3 (_S372.y) * cross_0(n_i_2, frame_1.tangent) + make_float3 (_S372.z) * n_i_2;
    }
    float3  _S373 = worldToTangent(v_3, n_i_2);
    float3  _S374 = sampleGGXVNDF(float3 {_S373.x, _S373.z, _S373.y}, alpha_1, _S362.value, _S363.value);
    float3  _S375 = float3 {_S374.x, _S374.z, _S374.y};
    float3  _S376 = tangentToWorld(_S375, n_i_2);
    return _S376;
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

static __device__ float3  refract_0(float3  i_6, float3  n_4, float eta_0)
{
    float _S377 = dot_0(n_4, i_6);
    float _S378 = 1.0f - eta_0 * eta_0 * (1.0f - _S377 * _S377);
    if(_S378 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_6 - make_float3 (eta_0 * _S377 + (F32_sqrt((_S378)))) * n_4;
}

__device__ float fresnel(float cos_theta_0, float eta_i_0, float eta_o_0)
{
    float _S379 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S380 = eta_i_0 / eta_o_0 * _S379;
    bool _S381 = _S380 < 1.0f;
    float kr_0;
    if(_S381)
    {
        float _S382 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S380 * _S380))))));
        float _S383 = eta_o_0 * cos_theta_0;
        float _S384 = eta_i_0 * _S382;
        float _S385 = (_S383 - _S384) / (_S383 + _S384);
        float _S386 = eta_i_0 * cos_theta_0;
        float _S387 = eta_o_0 * _S382;
        float _S388 = (_S386 - _S387) / (_S386 + _S387);
        float _S389 = (_S385 * _S385 + _S388 * _S388) / 2.0f;
        kr_0 = _S389;
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
    float _S390 = (F32_max((w_1.z), (0.0f)));
    return 2.0f * _S390 / (_S390 + length_0(make_float3 (alphas_1.x * w_1.x, alphas_1.y * w_1.y, _S390)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_2)
{
    float _S391 = alphas_2.x;
    float _S392 = h_0.x / _S391;
    float _S393 = alphas_2.y;
    float _S394 = h_0.y / _S393;
    float _S395 = h_0.z;
    float _S396 = _S392 * _S392 + _S394 * _S394 + _S395 * _S395;
    return 1.0f / (F32_max((3.14159274101257324f * _S391 * _S393 * _S396 * _S396), (1.17549435082228751e-38f)));
}

static __device__ HalfTerms HalfTerms_x24init_0(float v_dot_h_0, float n_dot_h_0, float3  refracted_1, float3  F_0, float F_greyscale_0, float reflect_weight_0, float3  diffuse_weight_0, float3  refract_weight_0, float p_diffuse_0, float p_reflect_0, float p_refract_0, float translucent_share_1, float3  sheen_1, float p_sheen_velvet_0, float3  view_1, float3  tangent_1, float2  alphas_3, float visible_0, float p_toon_0, float3  toon_1, float toon_a_1, float toon_s_1, float toon_b_1, bool toon_glossy_1, float toon_norm_1, float toon_view_1, float3  toon_axis_1)
{
    HalfTerms _S397;
    (&_S397)->v_dot_h = v_dot_h_0;
    (&_S397)->n_dot_h = n_dot_h_0;
    (&_S397)->refracted = refracted_1;
    (&_S397)->F = F_0;
    (&_S397)->F_greyscale = F_greyscale_0;
    (&_S397)->reflect_weight = reflect_weight_0;
    (&_S397)->diffuse_weight = diffuse_weight_0;
    (&_S397)->refract_weight = refract_weight_0;
    (&_S397)->p_diffuse = p_diffuse_0;
    (&_S397)->p_reflect = p_reflect_0;
    (&_S397)->p_refract = p_refract_0;
    (&_S397)->translucent_share = translucent_share_1;
    (&_S397)->sheen = sheen_1;
    (&_S397)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S397)->view = view_1;
    (&_S397)->tangent = tangent_1;
    (&_S397)->alphas = alphas_3;
    (&_S397)->visible = visible_0;
    (&_S397)->p_toon = p_toon_0;
    (&_S397)->toon = toon_1;
    (&_S397)->toon_a = toon_a_1;
    (&_S397)->toon_s = toon_s_1;
    (&_S397)->toon_b = toon_b_1;
    (&_S397)->toon_glossy = toon_glossy_1;
    (&_S397)->toon_norm = toon_norm_1;
    (&_S397)->toon_view = toon_view_1;
    (&_S397)->toon_axis = toon_axis_1;
    return _S397;
}

__device__ HalfTerms precomputeHalf(float3  in_dir_0, float3  ggx_n_0, BSDFMaterial material_2, float eta_i_1, float eta_o_1, MaterialTerms terms_0, ViewTerms view_terms_0)
{
    float _S398 = dot_0(ggx_n_0, view_terms_0.v);
    float _S399 = dot_0(view_terms_0.n_i, ggx_n_0);
    float _S400 = eta_i_1 / eta_o_1;
    float3  _S401 = refract_0(in_dir_0, ggx_n_0, _S400);
    float3  _S402 = ((((_S401)) * make_float3(rnorm3df(((_S401)).x, ((_S401)).y, ((_S401)).z))));
    float _S403 = (F32_abs((_S398)));
    bool _S404 = eta_i_1 > eta_o_1;
    float visible_1;
    if(_S404)
    {
        visible_1 = terms_0.eta_level;
    }
    else
    {
        visible_1 = 1.0f;
    }
    float _S405;
    if(_S404)
    {
        _S405 = 1.0f;
    }
    else
    {
        _S405 = terms_0.eta_level;
    }
    float _S406 = fresnel(_S403, visible_1, _S405);
    bool _S407 = (eta_i_1 * eta_i_1 * (1.0f - _S398 * _S398)) >= (eta_o_1 * eta_o_1);
    float3  _S408;
    if(_S407)
    {
        _S408 = make_float3 (1.0f);
    }
    else
    {
        float3  _S409 = material_2.specular_tint * make_float3 (terms_0.f0);
        _S408 = _S409 + (make_float3 (1.0f) - _S409) * make_float3 (_S406 - terms_0.f0) / make_float3 (1.0f - terms_0.f0);
    }
    float3  _S410 = mix_0(_S408, material_2.albedo * view_terms_0.rebounce, material_2.metallic);
    float3  F_1 = _S410 * view_terms_0.scale;
    float _S411 = rgb_to_greyscale(F_1);
    float _S412 = 1.0f - material_2.metallic;
    float3  _S413 = make_float3 (1.0f) - _S408;
    float3  _S414 = make_float3 ((1.0f - material_2.transmission) * _S412) * _S413 * view_terms_0.scale;
    float3  _S415 = make_float3 (material_2.transmission * _S412) * _S413 * view_terms_0.scale;
    float _S416 = (F32_max((_S411), (0.0f)));
    float _S417 = rgb_to_greyscale(_S414);
    float _S418 = (F32_max((_S417), (0.0f)));
    float _S419 = rgb_to_greyscale(_S415);
    float _S420 = sign_0(length_0(_S402));
    float _S421 = (F32_max((_S419 * _S420), (0.0f)));
    float _S422 = _S416 + _S418 + _S421 + terms_0.toon_component;
    float _S423 = (F32_min((view_terms_0.sheen_component), (1.0f)));
    bool _S424 = (view_terms_0.sheen_component) > 0.0f;
    bool _S425;
    if(_S424)
    {
        _S425 = !(_S422 > 0.0f);
    }
    else
    {
        _S425 = false;
    }
    float _S426 = _slang_select(_S425, 1.0f,_S423);
    float _S427 = (1.0f - _S426) / (F32_max((_S422), (0.0000152587890625f)));
    float _S428 = _S418 * _S427;
    float _S429 = _S416 * _S427;
    float _S430 = _S421 * _S427;
    bool _S431 = (view_terms_0.frame.alphas.x) > 0.0f;
    if(_S431)
    {
        float3  _S432 = anisotropicLocal(view_terms_0.v, view_terms_0.frame.tangent, view_terms_0.n_i);
        float _S433 = anisotropicG1(_S432, view_terms_0.frame.alphas);
        float3  _S434 = anisotropicLocal(ggx_n_0, view_terms_0.frame.tangent, view_terms_0.n_i);
        float _S435 = anisotropicD(_S434, view_terms_0.frame.alphas);
        float _S436 = _S433 * _S435;
        visible_1 = _S436;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return HalfTerms_x24init_0(_S398, _S399, _S402, F_1, _S411, 1.0f, _S414, _S415, _S428, _S429, _S430, terms_0.translucent_share, view_terms_0.sheen, _S426, view_terms_0.view, view_terms_0.frame.tangent, view_terms_0.frame.alphas, visible_1, terms_0.toon_component * _S427, terms_0.toon, terms_0.toon_a, terms_0.toon_s, terms_0.toon_b, terms_0.toon_glossy, terms_0.toon_norm, view_terms_0.toon_view, view_terms_0.toon_axis);
}

__device__ float smithG1(float alpha_2, float n_dot_x_0)
{
    float _S437 = alpha_2 * alpha_2;
    float _S438 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S437 + (1.0f - _S437) * n_dot_x_0 * n_dot_x_0))));
    bool _S439 = alpha_2 > 0.0f;
    float _S440 = _slang_select(_S439, _S438,1.0f);
    return _S440;
}

__device__ float trowbridgeReitz(float alpha_3, float n_dot_h_1)
{
    float _S441 = alpha_3 * alpha_3;
    float _S442 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S441 * n_dot_h_1 * n_dot_h_1;
    return _S441 / (F32_max((3.14159274101257324f * _S442 * _S442), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float lobeDensity(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_4, HalfTerms lobes_0, float eta_i_2, float eta_o_2, uint lobe_0)
{
    bool _S443 = lobe_0 == 0U;
    if(_S443)
    {
        float _S444 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
        float _S445 = lobes_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
        float _S446 = 1.0f - lobes_0.translucent_share;
        bool _S447 = n_i_dot_l_0 < 0.0f;
        float _S448 = _slang_select(_S447, lobes_0.translucent_share,_S446);
        float _S449 = _S445 * _S448;
        bool _S450 = (lobes_0.translucent_share) > 0.0f;
        float _S451 = _slang_select(_S450, _S449,_S444);
        bool _S452 = n_i_dot_v_0 > 0.0f;
        float _S453 = _slang_select(_S452, _S451,0.0f);
        return _S453;
    }
    bool _S454 = lobe_0 == 4U;
    bool _S455;
    if(_S454)
    {
        float _S456 = lobes_0.p_sheen_velvet * 0.5f * 0.31830987334251404f;
        bool _S457 = n_i_dot_l_0 > 0.0f;
        if(_S457)
        {
            _S455 = n_i_dot_v_0 > 0.0f;
        }
        else
        {
            _S455 = false;
        }
        float _S458 = _slang_select(_S455, _S456,0.0f);
        return _S458;
    }
    bool _S459 = lobe_0 == 6U;
    float pdf_h_0;
    if(_S459)
    {
        float _S460 = _slang_select(lobes_0.toon_glossy, l_dot_h_0,n_i_dot_l_0);
        float _S461 = (F32_acos((clamp_1(_S460, -1.0f, 1.0f))));
        if(_S461 < (lobes_0.toon_a))
        {
            pdf_h_0 = 1.0f;
        }
        else
        {
            pdf_h_0 = (F32_max((1.0f - (_S461 - lobes_0.toon_a) / (F32_max((lobes_0.toon_s), (0.0000152587890625f)))), (0.0f)));
        }
        float _S462 = lobes_0.p_toon * pdf_h_0;
        float _S463 = _slang_select(lobes_0.toon_glossy, 1.0f,n_i_dot_l_0);
        float _S464 = _S462 * _S463 / lobes_0.toon_norm;
        if(lobes_0.toon_glossy)
        {
            _S455 = true;
        }
        else
        {
            _S455 = n_i_dot_l_0 > 0.0f;
        }
        float _S465 = _slang_select(_S455, _S464,0.0f);
        return _S465;
    }
    float _S466 = smithG1(alpha_4, n_i_dot_v_0);
    float _S467 = _S466 * lobes_0.v_dot_h;
    float _S468 = trowbridgeReitz(alpha_4, lobes_0.n_dot_h);
    float _S469 = _S467 * _S468 / n_i_dot_v_0;
    bool _S470 = alpha_4 > 0.0f;
    if(_S470)
    {
        _S455 = (lobes_0.v_dot_h) > 0.0f;
    }
    else
    {
        _S455 = false;
    }
    if(_S455)
    {
        _S455 = (lobes_0.n_dot_h) > 0.0f;
    }
    else
    {
        _S455 = false;
    }
    if(_S455)
    {
        _S455 = n_i_dot_v_0 > 0.0f;
    }
    else
    {
        _S455 = false;
    }
    float _S471 = _slang_select(_S455, _S469,0.0f);
    bool _S472 = (lobes_0.alphas.x) > 0.0f;
    if(_S472)
    {
        float _S473 = lobes_0.visible * lobes_0.v_dot_h / n_i_dot_v_0;
        bool _S474 = (lobes_0.v_dot_h) > 0.0f;
        if(_S474)
        {
            _S455 = (lobes_0.n_dot_h) > 0.0f;
        }
        else
        {
            _S455 = false;
        }
        if(_S455)
        {
            _S455 = n_i_dot_v_0 > 0.0f;
        }
        else
        {
            _S455 = false;
        }
        float _S475 = _slang_select(_S455, _S473,0.0f);
        pdf_h_0 = _S475;
    }
    else
    {
        pdf_h_0 = _S471;
    }
    bool _S476 = lobe_0 == 1U;
    if(_S476)
    {
        float _S477 = eta_i_2 * lobes_0.v_dot_h + eta_o_2 * l_dot_h_0;
        float _S478 = lobes_0.p_refract * pdf_h_0 * eta_o_2 * eta_o_2 * (F32_abs((l_dot_h_0))) / (_S477 * _S477);
        bool _S479 = eta_i_2 != eta_o_2;
        if(_S479)
        {
            _S455 = l_dot_h_0 < 0.0f;
        }
        else
        {
            _S455 = false;
        }
        float _S480 = _slang_select(_S455, _S478,0.0f);
        return _S480;
    }
    float _S481 = lobes_0.p_reflect * pdf_h_0 / (4.0f * lobes_0.v_dot_h);
    bool _S482 = pdf_h_0 > 0.0f;
    float _S483 = _slang_select(_S482, _S481,0.0f);
    return _S483;
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_0, uint random_state_3, bool refracted_2, uint lobe_1, float pdf_0)
{
    SampleBSDF _S484;
    (&_S484)->unit_direction = unit_direction_1;
    (&_S484)->throughput = throughput_0;
    (&_S484)->random_state = random_state_3;
    (&_S484)->refracted = refracted_2;
    (&_S484)->lobe = lobe_1;
    (&_S484)->pdf = pdf_0;
    return _S484;
}

__device__ __forceinline__ float3  lobeThroughput(float3  l_0, float3  n_i_3, float alpha_5, BSDFMaterial material_3, HalfTerms lobes_1, uint lobe_2)
{
    bool _S485 = lobe_2 == 0U;
    if(_S485)
    {
        bool _S486 = (dot_0(n_i_3, l_0)) < 0.0f;
        float3  _S487 = _slang_select(_S486, material_3.translucent,material_3.albedo);
        float _S488 = 1.0f - lobes_1.translucent_share;
        float _S489 = _slang_select(_S486, lobes_1.translucent_share,_S488);
        float3  _S490 = _S487 / make_float3 (_S489);
        bool _S491 = (lobes_1.translucent_share) > 0.0f;
        float3  _S492 = _slang_select(_S491, _S490,material_3.albedo);
        return lobes_1.diffuse_weight * _S492 / make_float3 (lobes_1.p_diffuse);
    }
    bool _S493 = lobe_2 == 4U;
    float f_1;
    if(_S493)
    {
        float3  _S494 = l_0 + lobes_1.view;
        float3  _S495 = ((((_S494)) * make_float3(rnorm3df(((_S494)).x, ((_S494)).y, ((_S494)).z))));
        float _S496 = dot_0(n_i_3, _S495);
        float _S497 = (F32_max((dot_0(n_i_3, l_0)), (0.0f)));
        float _S498 = (F32_max((dot_0(n_i_3, lobes_1.view)), (0.0f)));
        float _S499 = 1.0f / (F32_max((material_3.sheen_roughness), (0.05000000074505806f)));
        float _S500 = 1.0f - _S496 * _S496;
        float _S501 = (2.0f + _S499) * (F32_pow(((F32_max((_S500), (0.0f)))), (0.5f * _S499))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S497 + _S498 - _S497 * _S498)), (0.0000152587890625f)));
        bool _S502 = (material_3.velvet) > 0.0f;
        if(_S502)
        {
            float _S503 = (F32_max((material_3.sheen_roughness), (0.00999999977648258f)));
            float _S504 = _S503 * _S503;
            float _S505 = (F32_max((_S500), (0.0000152587890625f)));
            float _S506 = (F32_exp((- _S496 * _S496 / (_S505 * _S504)))) / (3.14159274101257324f * _S504 * _S505 * _S505) * (F32_min((1.0f), (2.0f * _S496 * (F32_min((_S497), (_S498))) / (F32_max(((F32_abs((dot_0(_S495, lobes_1.view))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S497 * _S498), (0.0000152587890625f)));
            f_1 = _S506;
        }
        else
        {
            f_1 = _S501;
        }
        return lobes_1.sheen * make_float3 (f_1 * _S497 * 2.0f * 3.14159274101257324f / lobes_1.p_sheen_velvet);
    }
    bool _S507 = lobe_2 == 6U;
    if(_S507)
    {
        float _S508 = (F32_max((dot_0(n_i_3, l_0)), (0.0f)));
        float _S509 = _slang_select(lobes_1.toon_glossy, _S508,lobes_1.toon_view);
        return lobes_1.toon * make_float3 (_S509) / make_float3 (lobes_1.p_toon);
    }
    bool _S510 = lobe_2 == 1U;
    if(_S510)
    {
        float _S511 = - dot_0(n_i_3, l_0);
        float _S512 = smithG1(alpha_5, (F32_max((_S511), (0.0f))));
        bool _S513 = (lobes_1.alphas.x) > 0.0f;
        if(_S513)
        {
            float3  _S514 = negate_0(n_i_3);
            float3  _S515 = anisotropicLocal(l_0, lobes_1.tangent, _S514);
            float _S516 = anisotropicG1(_S515, lobes_1.alphas);
            f_1 = _S516;
        }
        else
        {
            f_1 = _S512;
        }
        return lobes_1.refract_weight * make_float3 (f_1) * material_3.albedo / make_float3 (lobes_1.p_refract);
    }
    float _S517 = dot_0(n_i_3, l_0);
    float _S518 = smithG1(alpha_5, (F32_max((_S517), (0.0f))));
    bool _S519 = (lobes_1.alphas.x) > 0.0f;
    if(_S519)
    {
        float3  _S520 = anisotropicLocal(l_0, lobes_1.tangent, n_i_3);
        float _S521 = anisotropicG1(_S520, lobes_1.alphas);
        f_1 = _S521;
    }
    else
    {
        f_1 = _S518;
    }
    return make_float3 (lobes_1.reflect_weight * f_1) * lobes_1.F / make_float3 (lobes_1.p_reflect);
}

__device__ __forceinline__ SampleBSDF lobeBSDF(float3  in_dir_1, float3  out_dir_0, float3  n_5, BSDFMaterial material_4, float eta_i_3, float eta_o_3, uint lobe_3, uint random_init_0, MaterialTerms terms_1, ViewTerms view_terms_1)
{
    uint random_state_4 = random_init_0;
    float3  _S522 = negate_0(in_dir_1);
    float _S523 = dot_0(n_5, _S522);
    float _S524 = sign_0(_S523);
    float3  _S525 = n_5 * make_float3 (_S524);
    float _S526 = material_4.roughness;
    float _S527 = _S526 * _S526;
    float3  _S528 = _S522 + out_dir_0;
    float3  ggx_n_1 = ((((_S528)) * make_float3(rnorm3df(((_S528)).x, ((_S528)).y, ((_S528)).z))));
    float _S529 = dot_0(out_dir_0, ggx_n_1);
    bool _S530 = lobe_3 == 0U;
    float3  ggx_n_2;
    if(_S530)
    {
        float3  _S531 = sampleHalfVector(_S522, _S525, _S527, view_terms_1.frame, &random_state_4);
        ggx_n_2 = _S531;
    }
    else
    {
        ggx_n_2 = ggx_n_1;
    }
    bool _S532 = lobe_3 == 1U;
    float l_dot_h_1;
    if(_S532)
    {
        float3  _S533 = negate_0(make_float3 (eta_i_3) * _S522 + make_float3 (eta_o_3) * out_dir_0);
        float3  _S534 = ((((_S533)) * make_float3(rnorm3df(((_S533)).x, ((_S533)).y, ((_S533)).z))));
        float _S535 = sign_0(dot_0(_S533, _S525));
        float3  ggx_n_3 = _S534 * make_float3 (_S535);
        float _S536 = dot_0(out_dir_0, ggx_n_3);
        ggx_n_2 = ggx_n_3;
        l_dot_h_1 = _S536;
    }
    else
    {
        l_dot_h_1 = _S529;
    }
    bool _S537 = lobe_3 == 2U;
    if(_S537)
    {
        float3  _S538 = ((((_S528)) * make_float3(rnorm3df(((_S528)).x, ((_S528)).y, ((_S528)).z))));
        ggx_n_2 = _S538;
    }
    bool _S539 = lobe_3 == 4U;
    if(_S539)
    {
        float3  _S540 = ((((_S528)) * make_float3(rnorm3df(((_S528)).x, ((_S528)).y, ((_S528)).z))));
        ggx_n_2 = _S540;
    }
    bool _S541 = lobe_3 == 6U;
    if(_S541)
    {
        float3  _S542 = sampleHalfVector(_S522, _S525, _S527, view_terms_1.frame, &random_state_4);
        float _S543 = dot_0(out_dir_0, view_terms_1.toon_axis);
        ggx_n_2 = _S542;
        l_dot_h_1 = _S543;
    }
    HalfTerms _S544 = precomputeHalf(in_dir_1, ggx_n_2, material_4, eta_i_3, eta_o_3, terms_1, view_terms_1);
    float _S545 = lobeDensity(dot_0(_S525, out_dir_0), l_dot_h_1, (F32_abs((_S523))), _S527, _S544, eta_i_3, eta_o_3, lobe_3);
    bool _S546 = !(_S545 > 0.0f);
    if(_S546)
    {
        float3  _S547 = make_float3 (0.0f);
        return SampleBSDF_x24init_0(_S547, _S547, 0U, false, 0U, 0.0f);
    }
    float3  _S548 = lobeThroughput(out_dir_0, _S525, _S527, material_4, _S544, lobe_3);
    return SampleBSDF_x24init_0(out_dir_0, _S548, random_state_4, _S532, lobe_3, _S545);
}

__device__ __forceinline__ float3  neeBSDF(float3  in_dir_2, float3  dir_3, float3  n_6, BSDFMaterial material_5, float eta_i_4, float eta_o_4, bool refracted_3, float pdf_1, bool power_0, uint random_state_5, MaterialTerms terms_2, ViewTerms view_terms_2)
{
    float3  _S549 = make_float3 (0.0f);
    uint _S550;
    if((F32_abs((material_5.toon.x))) > 0.0f)
    {
        _S550 = 5U;
    }
    else
    {
        _S550 = 4U;
    }
    uint i_7 = 0U;
    float3  f_2 = _S549;
    for(;;)
    {
        if(i_7 < _S550)
        {
        }
        else
        {
            break;
        }
        uint _S551;
        if(i_7 == 3U)
        {
            _S551 = 4U;
        }
        else
        {
            if(i_7 == 4U)
            {
                _S551 = 6U;
            }
            else
            {
                _S551 = i_7;
            }
        }
        bool _S552 = _S551 == 0U;
        if(_S552)
        {
        }
        bool _S553;
        if(_S552)
        {
            float _S554 = rgb_to_greyscale(material_5.translucent);
            _S553 = _S554 > 0.0f;
        }
        else
        {
            _S553 = false;
        }
        bool _S555;
        if(_S553)
        {
            float _S556 = dot_0(n_6, dir_3);
            float3  _S557 = negate_0(in_dir_2);
            _S555 = ((_S556 * dot_0(n_6, _S557)) < 0.0f) == refracted_3;
        }
        else
        {
            _S555 = (_S551 == 1U) == refracted_3;
        }
        float3  f_3;
        if(_S555)
        {
            SampleBSDF _S558 = lobeBSDF(in_dir_2, dir_3, n_6, material_5, eta_i_4, eta_o_4, _S551, random_state_5, terms_2, view_terms_2);
            bool _S559 = (_S558.pdf) > 0.0f;
            if(_S559)
            {
                if(power_0)
                {
                    float _S560 = _S558.pdf / pdf_1;
                    float3  f_4 = f_2 + _S558.throughput * make_float3 (_S558.pdf) / make_float3 (pdf_1 * (1.0f + _S560 * _S560));
                    f_3 = f_4;
                }
                else
                {
                    float3  f_5 = f_2 + _S558.throughput * make_float3 (_S558.pdf) / make_float3 (_S558.pdf + pdf_1);
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

__device__ float3  skyBSDF(float3  in_dir_3, float3  dir_4, FKSurface surface_1, float2  eta_1, bool is_inside_2, float pdf_2, uint random_state_6)
{
    bool _S561 = wrongSide_0(is_inside_2, false, dir_4, surface_1.geometry_n);
    float _S562 = eta_1.x;
    float _S563 = eta_1.y;
    float _S564 = (F32_min(((F32_sqrt((surface_1.material.specular_level))) * (F32_abs((_S562 - _S563))) / (_S562 + _S563)), (0.9999847412109375f)));
    float _S565 = _S564 * _S564;
    float _S566 = (1.0f + _S564) / (1.0f - _S564);
    float3  _S567 = make_float3 (0.0f);
    float _S568 = surface_1.material.toon.x;
    bool _S569 = _S568 < 0.0f;
    float _S570 = (F32_abs((_S568)));
    bool _S571 = _S570 > 0.0f;
    float toon_scale_1;
    float toon_component_1;
    float toon_a_2;
    float toon_s_2;
    float toon_b_2;
    float toon_norm_2;
    float3  toon_2;
    if(_S571)
    {
        float _S572 = (F32_min((_S570), (1.0f)));
        float _S573 = 1.0f - _S572;
        float _S574 = rgb_to_greyscale(surface_1.material.albedo);
        float _S575 = _S572 * _S574;
        float3  _S576 = make_float3 (_S572) * surface_1.material.albedo;
        float toon_a_3 = clamp_1(surface_1.material.toon.y / _S568, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
        float toon_s_3 = clamp_1(surface_1.material.toon.z / _S568, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
        float _S577 = (F32_min((toon_a_3 + toon_s_3), (1.57079637050628662f)));
        if(_S569)
        {
            toon_scale_1 = 1.0f - (F32_cos(((F32_min((_S577), (toon_a_3))))));
        }
        else
        {
            float _S578 = (F32_sin(((F32_min((_S577), (toon_a_3))))));
            toon_scale_1 = _S578 * _S578 / 2.0f;
        }
        bool _S579 = _S577 > toon_a_3;
        bool _S580;
        if(_S579)
        {
            _S580 = toon_s_3 > 0.0f;
        }
        else
        {
            _S580 = false;
        }
        if(_S580)
        {
            if(_S569)
            {
                float _S581 = (F32_cos((toon_a_3)));
                float _S582 = (F32_cos((_S577)));
                toon_component_1 = (1.0f + toon_a_3 / toon_s_3) * (_S581 - _S582) - ((F32_sin((_S577))) - _S577 * _S582 - ((F32_sin((toon_a_3))) - toon_a_3 * _S581)) / toon_s_3;
            }
            else
            {
                float _S583 = 2.0f * toon_a_3;
                float _S584 = (F32_cos((_S583)));
                float _S585 = 2.0f * _S577;
                float _S586 = (F32_cos((_S585)));
                toon_component_1 = (1.0f + toon_a_3 / toon_s_3) * (_S584 - _S586) / 4.0f - ((F32_sin((_S585))) / 8.0f - _S577 * _S586 / 4.0f - ((F32_sin((_S583))) / 8.0f - toon_a_3 * _S584 / 4.0f)) / toon_s_3;
            }
            float integral_0 = toon_scale_1 + toon_component_1;
            toon_scale_1 = integral_0;
        }
        else
        {
        }
        float _S587 = 6.28318548202514648f * toon_scale_1;
        toon_scale_1 = _S573;
        toon_component_1 = _S575;
        toon_2 = _S576;
        toon_a_2 = toon_a_3;
        toon_s_2 = toon_s_3;
        toon_b_2 = _S577;
        toon_norm_2 = _S587;
    }
    else
    {
        toon_scale_1 = 1.0f;
        toon_component_1 = 0.0f;
        toon_2 = _S567;
        toon_a_2 = 0.0f;
        toon_s_2 = 0.0f;
        toon_b_2 = 0.0f;
        toon_norm_2 = 1.0f;
    }
    float _S588 = translucentShare(surface_1.material);
    MaterialTerms _S589 = MaterialTerms_x24init_0(_S565, _S566, _S588, toon_scale_1, toon_component_1, toon_2, toon_a_2, toon_s_2, toon_b_2, _S569, toon_norm_2);
    float3  _S590 = negate_0(in_dir_3);
    float _S591 = sign_0(dot_0(surface_1.smooth_n, _S590));
    float3  _S592 = surface_1.smooth_n * make_float3 (_S591);
    AnisotropicFrame _S593 = anisotropicFrame(surface_1.material, _S592);
    float3  _S594 = make_float3 (1.0f);
    float _S595 = rgb_to_greyscale(surface_1.material.sheen);
    bool _S596 = _S595 > 0.0f;
    float sheen_component_1;
    float3  sheen_2;
    float3  view_2;
    float3  scale_2;
    if(_S596)
    {
        float _S597 = clamp_1((F32_sqrt(((F32_max((dot_0(_S592, _S590)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S598 = (U32_min((uint(_S597)), (22U)));
        float least_0 = (F32_sqrt((0.05000000074505806f)));
        float _S599 = (F32_sqrt((0.10000000149011612f)));
        bool _S600 = (surface_1.material.velvet) > 0.0f;
        float _S601 = _slang_select(_S600, _S599,least_0);
        float _S602 = (clamp_1((F32_sqrt(((F32_max((surface_1.material.sheen_roughness), (0.0f)))))), _S601, 1.0f) - _S601) / (1.0f - _S601) * 23.0f;
        uint _S603 = (U32_min((uint(_S602)), (22U)));
        uint _S604 = _S598 * 24U + _S603;
        float _S605 = _S597 - float(_S598);
        float _S606 = _S602 - float(_S603);
        uint _S607 = _S604 + 24U;
        float a_5 = SHEEN_ALBEDO_0[_S604] + (SHEEN_ALBEDO_0[_S607] - SHEEN_ALBEDO_0[_S604]) * _S605;
        uint _S608 = _S604 + 1U;
        uint _S609 = _S607 + 1U;
        float b_1 = SHEEN_ALBEDO_0[_S608] + (SHEEN_ALBEDO_0[_S609] - SHEEN_ALBEDO_0[_S608]) * _S605;
        float _S610 = (F32_exp((a_5 + (b_1 - a_5) * _S606)));
        if(_S600)
        {
            float a_6 = VELVET_ALBEDO_0[_S604] + (VELVET_ALBEDO_0[_S607] - VELVET_ALBEDO_0[_S604]) * _S605;
            float b_2 = VELVET_ALBEDO_0[_S608] + (VELVET_ALBEDO_0[_S609] - VELVET_ALBEDO_0[_S608]) * _S605;
            float _S611 = a_6 + (b_2 - a_6) * _S606;
            sheen_component_1 = _S611;
        }
        else
        {
            sheen_component_1 = _S610;
        }
        float _S612 = (F32_min((sheen_component_1), (1.0f)));
        float3  _S613 = make_float3 (1.0f) - surface_1.material.sheen * make_float3 (_S612);
        float _S614 = rgb_to_greyscale(surface_1.material.sheen);
        float _S615 = _S614 * _S612;
        float3  _S616 = surface_1.material.sheen / make_float3 ((F32_max((sheen_component_1), (1.0f))));
        sheen_component_1 = _S615;
        sheen_2 = _S616;
        view_2 = _S590;
        scale_2 = _S613;
    }
    else
    {
        sheen_component_1 = 0.0f;
        sheen_2 = _S567;
        view_2 = _S567;
        scale_2 = _S594;
    }
    float3  scale_3 = scale_2 * make_float3 (_S589.toon_scale);
    float toon_view_2;
    float3  toon_axis_2;
    if(_S571)
    {
        float _S617 = dot_0(_S592, _S590);
        float _S618 = (F32_acos(((F32_min((_S617), (1.0f))))));
        if(_S618 < (_S589.toon_a))
        {
            toon_scale_1 = 1.0f;
        }
        else
        {
            toon_scale_1 = (F32_max((1.0f - (_S618 - _S589.toon_a) / (F32_max((_S589.toon_s), (0.0000152587890625f)))), (0.0f)));
        }
        if(_S589.toon_glossy)
        {
            float3  _S619 = make_float3 (2.0f * _S617) * _S592 - _S590;
            float3  _S620 = ((((_S619)) * make_float3(rnorm3df(((_S619)).x, ((_S619)).y, ((_S619)).z))));
            toon_2 = _S620;
        }
        else
        {
            toon_2 = _S592;
        }
        toon_view_2 = toon_scale_1;
        toon_axis_2 = toon_2;
    }
    else
    {
        toon_view_2 = 0.0f;
        toon_axis_2 = _S592;
    }
    float _S621 = _S593.alphas.x;
    float _S622 = (F32_sqrt(((F32_min((_S621), (_S593.alphas.y))))));
    bool _S623 = _S621 > 0.0f;
    float _S624 = _slang_select(_S623, _S622,surface_1.material.roughness);
    float _S625 = _S624 * _S624;
    float _S626 = (F32_pow((_S625), (1.81585001945495605f))) * (2.15371990203857422f - 0.73285001516342163f * _S625) / (1.0f + 1.28094995021820068f * _S625);
    bool _S627 = _S625 > 0.0f;
    float _S628 = _slang_select(_S627, _S626,0.0f);
    float _S629 = clamp_1(dot_0(_S592, _S590), 0.0f, 1.0f);
    float _S630 = _S625 * _S624;
    float _S631 = (F32_min((1.00064504146575928f - _S624 * (0.00375499995425344f + _S629 * (-0.04133399948477745f + _S629 * (-0.90938502550125122f + _S629 * 0.35275399684906006f))) - _S625 * (0.27602800726890564f + _S629 * (1.27023398876190186f + _S629 * 0.04740000143647194f)) - _S630 * (0.31452900171279907f - _S629 * 0.34830701351165771f) + _S630 * _S624 * 0.27229699492454529f), (1.0f)));
    float3  _S632 = min_1(make_float3 (1.0f) / (make_float3 (1.0f) - surface_1.material.albedo * make_float3 (_S628)), make_float3 (1.0f / (F32_max((_S631), (0.0000152587890625f)))));
    AnisotropicFrame _S633 = _S593;
    ViewTerms _S634 = ViewTerms_x24init_0(_S590, _S592, &_S633, scale_3, sheen_component_1, sheen_2, view_2, _S632, toon_view_2, toon_axis_2);
    float3  _S635 = neeBSDF(in_dir_3, dir_4, surface_1.smooth_n, surface_1.material, _S562, _S563, _S561, pdf_2, false, random_state_6, _S589, _S634);
    return _S635;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_5, float3  radiance_0, float3  color_0, uint random_state_7)
{
    SkySample _S636;
    (&_S636)->dir = dir_5;
    (&_S636)->radiance = radiance_0;
    (&_S636)->color = color_0;
    (&_S636)->random_state = random_state_7;
    return _S636;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_2, float2  eta_2, bool is_inside_3, uint init_random_state_0, uint lobe_state_0, ShadowContext * context_2)
{
    uint2  _S637 = (fcptEnvironmentCdfSize());
    uint2  _S638 = make_uint2 (1U, 0U);
    uint2  _S639 = _S637 - _S638;
    Random _S640 = pcg(init_random_state_0);
    Random _S641 = pcg(_S640.state);
    Random _S642 = pcg(_S641.state);
    Random _S643 = pcg(_S642.state);
    uint _S644 = _S639.x;
    uint _S645 = searchCDF_0(make_uint2 (_S644, 0U), make_uint2 (0U, 1U), _S639.y, _S640.value);
    uint _S646 = searchCDF_0(make_uint2 (0U, _S645), _S638, _S644, _S641.value);
    float2  _S647 = make_float2 ((float)_S639.x, (float)_S639.y);
    float2  _S648 = (make_float2 (float(_S646), float(_S645)) + make_float2 (_S642.value, _S643.value)) / _S647 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S649 = _S648.y;
    float _S650 = (F32_sin((_S649)));
    float _S651 = _S648.x;
    float3  _S652 = make_float3 (- _S650 * (F32_cos((_S651))), _S650 * (F32_sin((_S651))), (F32_cos((_S649))));
    float _S653 = environmentPdf_0(_S652);
    float3  _S654 = skyBSDF(ray_0->unit_direction, _S652, *surface_2, eta_2, is_inside_3, _S653, lobe_state_0);
    bool _S655 = !(_S653 > 0.0f);
    bool _S656;
    if(_S655)
    {
        _S656 = true;
    }
    else
    {
        _S656 = all_1(_S654 == make_float3 (0.0f));
    }
    if(_S656)
    {
        float3  _S657 = make_float3 (0.0f);
        return SkySample_x24init_0(_S652, _S657, _S657, _S643.state);
    }
    float3  _S658 = skyRadiance_0(ray_0->origin, surface_2, is_inside_3, _S652, context_2, _S643.state);
    return SkySample_x24init_0(_S652, _S658, _S654 * _S658, _S643.state);
}

struct TreeSample
{
    float3  dir;
    float3  radiance;
    float density;
    uint random_state;
};

static __device__ float3  hairLight_0(FKSurface * surface_3, float3  in_dir_4, TreeSample * light_1, bool competing_0)
{
    SampleBSDF _S659 = (fcptConnectHair((surface_3->hair), ((&surface_3->material)->albedo), ((&surface_3->material)->specular_tint), (in_dir_4), (light_1->dir)));
    float3  _S660 = _S659.throughput * make_float3 (_S659.pdf);
    float _S661 = light_1->density;
    float _S662 = 1.0f + _S659.pdf * _S659.pdf / (light_1->density * light_1->density);
    bool _S663;
    if(competing_0)
    {
        _S663 = _S661 > 0.0f;
    }
    else
    {
        _S663 = false;
    }
    float _S664 = _slang_select(_S663, _S662,1.0f);
    return _S660 / make_float3 (_S664) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_6, float3  radiance_1, float density_0, uint random_state_8)
{
    TreeSample _S665;
    (&_S665)->dir = dir_6;
    (&_S665)->radiance = radiance_1;
    (&_S665)->density = density_0;
    (&_S665)->random_state = random_state_8;
    return _S665;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_12, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S666 = importance(first_1, p_12, normal_3);
    float _S667 = importance(second_1, p_12, normal_3);
    float2  _S668 = make_float2 (_S666, _S667);
    bool _S669 = _S666 == 0.0f;
    bool _S670;
    if(_S669)
    {
        _S670 = _S667 == 0.0f;
    }
    else
    {
        _S670 = false;
    }
    if(_S670)
    {
        return 2U;
    }
    float _S671 = _S666 + _S667;
    bool _S672 = _S667 > 0.0f;
    if(_S672)
    {
        _S670 = (*pick_0 * _S671) >= _S666;
    }
    else
    {
        _S670 = false;
    }
    uint _S673 = uint(_S670);
    float _S674 = (F32_min(((*pick_0 * _S671 - float(_S673) * _S666) / _slang_vector_get_element(_S668, _S673)), (0.99999994039535522f)));
    *pick_0 = _S674;
    float _S675 = *probability_3 * (_slang_vector_get_element(_S668, _S673) / _S671);
    *probability_3 = _S675;
    return _S673;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_13, float u1_0, float u2_0)
{
    float3  _S676 = center_1 - p_13;
    float _S677 = radius_1 * radius_1 / dot_0(_S676, _S676);
    float _S678 = u1_0 * _S677 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S677), (0.0f)))))));
    float _S679 = 2.0f * u1_0;
    bool _S680 = _S677 >= 1.0f;
    float _S681 = _slang_select(_S680, _S679,_S678);
    float _S682 = (F32_sqrt(((F32_max((_S681 * (2.0f - _S681)), (0.0f))))));
    float _S683 = 6.28318548202514648f * u2_0;
    float3  _S684 = make_float3 (_S682 * (F32_cos((_S683))), 1.0f - _S681, _S682 * (F32_sin((_S683))));
    float3  _S685 = ((((_S676)) * make_float3(rnorm3df(((_S676)).x, ((_S676)).y, ((_S676)).z))));
    float3  _S686 = tangentToWorld(_S684, _S685);
    return _S686;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S687 = center_2 - ray_1->origin;
    float _S688 = dot_0(_S687, ray_1->unit_direction);
    float _S689 = dot_0(_S687, _S687) - _S688 * _S688;
    float _S690 = radius_3 * radius_3;
    bool _S691 = _S689 > _S690;
    if(_S691)
    {
        return 4.294967296e+09f;
    }
    float _S692 = (F32_sqrt((_S690 - _S689)));
    float _S693 = _S688 - _S692;
    float _S694 = _S688 + _S692;
    bool _S695 = _S693 > 0.0000152587890625f;
    bool _S696;
    if(_S695)
    {
        _S696 = _S693 < max_len_0;
    }
    else
    {
        _S696 = false;
    }
    if(_S696)
    {
        return _S693;
    }
    bool _S697 = _S694 > 0.0000152587890625f;
    if(_S697)
    {
        _S696 = _S694 < max_len_0;
    }
    else
    {
        _S696 = false;
    }
    if(_S696)
    {
        return _S694;
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
    Random _S698 = pcg(init_random_state_1);
    Random _S699 = pcg(_S698.state);
    Random _S700 = pcg(_S699.state);
    float3  _S701 = make_float3 (0.0f);
    TreeSample _S702 = TreeSample_x24init_0(_S701, _S701, 0.0f, _S700.state);
    TreeSample sample_0 = _S702;
    float3  _S703 = _slang_select(sided_0, _S701,smooth_n_2);
    float3  _S704 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S698.value;
    float probability_4 = 1.0f;
    uint n_7 = 0U;
    for(;;)
    {
        uint4  _S705 = (fcptLightNode((n_7)));
        if((_S705.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S706 = (fcptLightSecond((n_7)));
        uint _S707 = n_7 + 1U;
        LightNode _S708 = (fcptLightBounds((_S707)));
        LightNode _S709 = (fcptLightBounds((_S706)));
        uint _S710 = pickChild(_S708, _S709, origin_4, _S703, &pick_1, &probability_4);
        bool _S711 = _S710 > 1U;
        if(_S711)
        {
            return sample_0;
        }
        bool _S712 = _S710 == 1U;
        uint _S713 = _slang_select(_S712, _S706,_S707);
        n_7 = _S713;
    }
    bool _S714 = n_7 == 0U;
    bool _S715;
    if(_S714)
    {
        LightNode _S716 = (fcptLightBounds((0U)));
        float _S717 = importance(_S716, origin_4, _S703);
        _S715 = !(_S717 > 0.0f);
    }
    else
    {
        _S715 = false;
    }
    if(_S715)
    {
        return sample_0;
    }
    uint4  _S718 = (fcptLightNode((n_7)));
    FKHit _S719 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S720 = (_S718.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S720)
    {
        FKLight _S721 = (fcptLight((_S718.y)));
        if(sided_0)
        {
            float _S722 = sign_0(dot_0(geometry_n_1, _S721.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S722);
            float3  _S723 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S723;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S704;
            lift_n_0 = smooth_n_2;
        }
        bool _S724 = (_S721.variance) == 0.0f;
        if(_S724)
        {
            float3  _S725 = _S721.position - emitter_point_0;
            float3  _S726 = ((((_S725)) * make_float3(rnorm3df(((_S725)).x, ((_S725)).y, ((_S725)).z))));
            (&sample_0)->dir = _S726;
            float3  _S727 = _S721.color * make_float3 (_S721.intensity) / make_float3 (dot_0(_S725, _S725) * probability_4);
            (&sample_0)->radiance = _S727;
            shadow_1 = _S725;
        }
        else
        {
            float3  _S728 = sampleSphere(_S721.position, _S721.variance, emitter_point_0, _S699.value, _S700.value);
            (&sample_0)->dir = _S728;
            float _S729 = sphereDensity(_S721.position, _S721.variance, emitter_point_0);
            float _S730 = probability_4 * _S729;
            (&sample_0)->density = _S730;
            float3  _S731 = pointLightRadiance(_S721.color, _S721.intensity, _S721.variance);
            float3  _S732 = _S731 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S732;
            FKRay _S733 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S734 = raySphere_0(_S721.position, _S721.variance, &_S733, 4.294967296e+09f);
            float3  _S735 = (&sample_0)->dir * make_float3 (_S734);
            shadow_1 = _S735;
        }
        emitter_0 = _S719;
        emitter_point_0 = _S701;
    }
    else
    {
        uint _S736 = _S718.y;
        uint _S737 = (fcptTriangleOffset((_S736)));
        uint _S738 = _S737 + _S718.z;
        Matrix<float, 3, 3>  _S739 = (fcptWorldTriangle((_S736), (_S738)));
        float _S740 = (F32_sqrt((_S699.value)));
        float2  _S741 = make_float2 (_S740 * (1.0f - _S700.value), _S740 * _S700.value);
        float3  _S742 = mul_0(make_float3 (1.0f - _S740, _S741.x, _S741.y), _S739);
        if(sided_0)
        {
            float _S743 = sign_0(dot_0(geometry_n_1, _S742 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S743);
            float3  _S744 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S744;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S745 = !((dot_0(smooth_n_2, _S742 - origin_4)) > 0.0f);
            if(_S745)
            {
                return sample_0;
            }
            emitter_point_0 = _S704;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S741, _S736, _S738, 0U, 0.0f);
        float3  _S746 = _S742 - emitter_point_0;
        float3  _S747 = ((((_S746)) * make_float3(rnorm3df(((_S746)).x, ((_S746)).y, ((_S746)).z))));
        (&sample_0)->dir = _S747;
        float _S748 = solidAngle(probability_4, cross_0(_S739.rows[int(1)] - _S739.rows[int(0)], _S739.rows[int(2)] - _S739.rows[int(0)]), _S746);
        (&sample_0)->density = _S748;
        bool _S749 = (fcptShadowFirst());
        bool _S750 = !_S749;
        if(_S750)
        {
            FKSurface _S751 = (fcptLightSurfaceAt((emitter_1), (_S742), (_S700.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S742 - origin_4))));
            (&sample_0)->random_state = _S751.random_state;
            float3  _S752 = _slang_select(_S751.skip, _S701,_S751.material.emissive);
            float3  _S753 = _S752 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S753;
        }
        shadow_1 = _S746;
        emitter_0 = emitter_1;
        emitter_point_0 = _S742;
    }
    FKHit _S754 = emitter_0;
    float3  _S755 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S700.state, &_S754);
    bool _S756 = (fcptShadowFirst());
    if(_S756)
    {
        _S715 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S715 = false;
    }
    if(_S715)
    {
        _S715 = !all_1(_S755 == _S701);
    }
    else
    {
        _S715 = false;
    }
    if(_S715)
    {
        FKSurface _S757 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S700.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S757.random_state;
        float3  _S758 = _slang_select(_S757.skip, _S701,_S757.material.emissive);
        float3  _S759 = _S758 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S759;
    }
    float3  _S760 = (&sample_0)->radiance * _S755;
    bool _S761 = all_1(_S755 == _S701);
    float3  _S762 = _slang_select(_S761, _S701,_S760);
    (&sample_0)->radiance = _S762;
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
    float _S763 = 1.0f / (1.0f + b_3 / a_7 * (b_3 / a_7));
    bool _S764 = b_3 > 0.0f;
    float _S765 = _slang_select(_S764, _S763,1.0f);
    return _S765;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S766 = vertex_0->none;
    if(_S766)
    {
        return 1.0f;
    }
    uint _S767 = (fcptLightSlot((*hit_1)));
    float _S768 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S767, light_point_1);
    float _S769 = powerHeuristic(vertex_0->pdf, _S768);
    return _S769;
}

static __device__ float3  environment_0(float3  dir_7, uint depth_0, uint lobe_4)
{
    uint2  _S770 = (fcptEnvironmentMapSize());
    bool _S771 = (_S770.x) > 1U;
    bool _S772;
    if(_S771)
    {
        uint2  _S773 = (fcptEnvironmentMapSize());
        _S772 = (_S773.y) > 1U;
    }
    else
    {
        _S772 = false;
    }
    if(_S772)
    {
        float3  _S774 = (fcptEnvMapSample((dir_7), (depth_0), (lobe_4)));
        return _S774;
    }
    float3  _S775 = (fcptAmbient());
    return _S775;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S776 = (fcptEnvironmentCdfSize());
    bool _S777 = (_S776.x) > 1U;
    bool _S778;
    if(_S777)
    {
        uint2  _S779 = (fcptEnvironmentCdfSize());
        _S778 = (_S779.y) > 1U;
    }
    else
    {
        _S778 = false;
    }
    bool _S780 = !_S778;
    if(_S780)
    {
        return false;
    }
    uint2  _S781 = (fcptEnvironmentMapSize());
    bool _S782 = (_S781.x) > 1U;
    if(_S782)
    {
        uint2  _S783 = (fcptEnvironmentMapSize());
        _S778 = (_S783.y) > 1U;
    }
    else
    {
        _S778 = false;
    }
    return _S778;
}

static __device__ float escapeWeight_0(float pdf_3, float3  dir_8)
{
    bool _S784 = pdf_3 <= 0.0f;
    bool _S785;
    if(_S784)
    {
        _S785 = true;
    }
    else
    {
        bool _S786 = environmentMapped_0();
        _S785 = !_S786;
    }
    if(_S785)
    {
        return 1.0f;
    }
    float _S787 = environmentPdf_0(dir_8);
    return pdf_3 / (pdf_3 + _S787);
}

static __device__ void restir_duplicates_0(uint3  global_invocation_id_1, uint3  local_invocation_id_0, uint local_invocation_index_3)
{
    uint2  _S788 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S789 = make_int2 ((int)_S788.x, (int)_S788.y);
    uint _S790 = previousSeed_0(_S789);
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
            uint _S791 = previousSeed_0(_S789 + make_int2 (x_16, y_5));
            bool _S792 = _S791 == _S790;
            uint _S793 = _slang_select(_S792, 1U,0U);
            uint count_3 = count_2 + _S793;
            int x_17 = x_16 + int(1);
            x_16 = x_17;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S794 = float(count_2 - 1U) / 288.0f;
    bool _S795 = _S790 != 0U;
    float _S796 = _slang_select(_S795, _S794,0.0f);
    fcptStoreDuplication((_S789), (make_uint4 ((F32_asuint((_S796))), 0U, 0U, 0U)));
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
    float _S797 = rgb_to_greyscale(abs_0(f_6));
    return _S797;
}

__device__ uint stream(uint seed_3, uint index_0)
{
    uint _S798 = hash(index_0);
    uint _S799 = hash(seed_3 ^ _S798);
    return _S799;
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
    float _S800 = resamplingTarget(weight_0);
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
    float _S812 = resamplingTarget((&r_4)->f);
    float _S813 = sel_4.w_sum / _S812;
    bool _S814 = _S812 > 0.0f;
    float _S815 = _slang_select(_S814, _S813,0.0f);
    (&r_4)->w = _S815;
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
    float _S830 = resamplingTarget(_S824.f);
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
                float _S850 = resamplingTarget(float3 {_S847.x, _S847.y, _S847.z});
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
            float _S854 = resamplingTarget(_S843.f);
            float _S855 = resamplingTarget(_S852);
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
        float _S950 = resamplingTarget(_S914.f);
        float _S951 = resamplingTarget(_S922.f);
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
        float _S960 = resamplingTarget(float3 {_S959.x, _S959.y, _S959.z});
        float4  _S961 = to_current_0;
        float3  _S962 = float3 {_S961.x, _S961.y, _S961.z};
        float _S963 = resamplingTarget(_S962);
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
    uint i_14 = 0U;
    float3  seen_0 = _S968;
    for(;;)
    {
        uint _S988 = (fcptSamples());
        if(i_14 < _S988)
        {
        }
        else
        {
            break;
        }
        Reservoir _S989 = (Reservoir{});
        Reservoir r_6 = _S989;
        uint _S990 = stream(_S979, i_14);
        (&r_6)->seed = _S990;
        Domain path_0 = _S971;
        bool _S991 = (fcptStoredDomainInitial((_S967), ((&r_6)->seed), (&path_0)));
        bool _S992 = !_S991;
        if(_S992)
        {
            float3  _S993 = (fcptMissed((_S967), (path_0), (_S987)));
            float3  seen_1 = seen_0 + _S993;
            seen_0 = seen_1;
            uint i_15 = i_14 + 1U;
            i_14 = i_15;
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
        uint i_15 = i_14 + 1U;
        i_14 = i_15;
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

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_4, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S1001;
    (&_S1001)->none = none_0;
    (&_S1001)->pdf = pdf_4;
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

static __device__ Vertex Vertex_x24init_0(bool rough_0, uint lobe_5, float pdf_5, float cos_0, bool inside_0)
{
    Vertex _S1002;
    (&_S1002)->rough = rough_0;
    (&_S1002)->lobe = lobe_5;
    (&_S1002)->pdf = pdf_5;
    (&_S1002)->cos = cos_0;
    (&_S1002)->inside = inside_0;
    return _S1002;
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

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_6, bool surface_4, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S1011;
    (&_S1011)->extinction_behind = extinction_behind_0;
    (&_S1011)->extinction_front = extinction_front_0;
    (&_S1011)->fillings = fillings_0;
    (&_S1011)->side = side_0;
    (&_S1011)->depth = depth_1;
    (&_S1011)->lobe = lobe_6;
    (&_S1011)->surface = surface_4;
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

__device__ Reservoir withEnd(Reservoir r_7, uint end_type_0, uint end_0, float3  f_7)
{
    Reservoir candidate_2 = r_7;
    uint _S1019 = insertBits_0(r_7.path, end_0, 0U, 5U);
    uint _S1020 = insertBits_0(_S1019, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S1020;
    (&candidate_2)->f = f_7;
    return candidate_2;
}

__device__ float survivalProbability(float3  throughput_1, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_1.x), ((F32_max((throughput_1.y), (throughput_1.z)))))) / density_1), (0.0f)))), (1.0f)));
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

static __device__ float3  samplePhase_0(float g_1, float3  dir_9, uint random_state_10, float * pdf_6)
{
    bool _S1026 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1026)
    {
        *pdf_6 = 0.07957746833562851f;
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
    *pdf_6 = _S1036;
    float3  _S1037 = tangentToWorld(make_float3 (_S1034 * (F32_cos((_S1035))), _S1033, _S1034 * (F32_sin((_S1035)))), dir_9);
    float3  _S1038 = ((((_S1037)) * make_float3(rnorm3df(((_S1037)).x, ((_S1037)).y, ((_S1037)).z))));
    return _S1038;
}

static __device__ Vertex scatteredVertex_0(bool is_inside_4)
{
    return Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_4);
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_0, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_3, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2, float velvet_0, float3  toon_3, float dispersion_0)
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
    (&_S1039)->sheen = sheen_3;
    (&_S1039)->sheen_roughness = sheen_roughness_0;
    (&_S1039)->anisotropy = anisotropy_0;
    (&_S1039)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1039)->tangent = tangent_2;
    (&_S1039)->velvet = velvet_0;
    (&_S1039)->toon = toon_3;
    (&_S1039)->dispersion = dispersion_0;
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

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_6, bool skip_0, uint random_state_11, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1041;
    (&_S1041)->smooth_n = smooth_n_4;
    (&_S1041)->geometry_n = geometry_n_2;
    (&_S1041)->geometry_offset = geometry_offset_2;
    (&_S1041)->material = *material_6;
    (&_S1041)->skip = skip_0;
    (&_S1041)->random_state = random_state_11;
    (&_S1041)->coverage = coverage_0;
    (&_S1041)->encloses = encloses_0;
    (&_S1041)->volume = *volume_0;
    (&_S1041)->fills = fills_0;
    (&_S1041)->hair = hair_0;
    return _S1041;
}

static __device__ FKSurface emitting_0(FKSurface * surface_5, bool top_0)
{
    FKSurface lower_0 = *surface_5;
    float3  _S1042 = (&surface_5->material)->emissive;
    float3  _S1043 = make_float3 (0.0f);
    bool _S1044 = !top_0;
    float3  _S1045 = _slang_select(_S1044, _S1043,_S1042);
    (&(&lower_0)->material)->emissive = _S1045;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_6, float u_2)
{
    float _S1046 = surface_6->coverage;
    bool _S1047 = u_2 < _S1046;
    if(_S1047)
    {
        return *surface_6;
    }
    float3  _S1048 = make_float3 (0.0f);
    float3  _S1049 = make_float3 (1.0f);
    BSDFMaterial _S1050 = Material_x24init_0(_S1048, _S1048, 0.0f, 0.0f, 0.0f, 0.0f, _S1048, _S1049, 1.0f, _S1048, _S1048, 0.5f, 0.0f, 0.0f, _S1048, 0.0f, _S1048, 0.0f);
    BSDFMaterial material_7 = _S1050;
    (&material_7)->albedo = _S1049;
    (&material_7)->emissive = (&surface_6->material)->emissive;
    (&material_7)->transmission = 1.0f;
    (&material_7)->ior = 1.0f;
    (&material_7)->absorption = (&surface_6->material)->absorption;
    FKSurface through_0 = *surface_6;
    (&through_0)->material = material_7;
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

static __device__ bool arrivesBehind_0(float3  dir_10, float3  n_8)
{
    return (dot_0(dir_10, n_8)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_7, float3  dir_11)
{
    float3  _S1054 = surface_7->geometry_n;
    float _S1055 = facingSign((&surface_7->material)->transmission, surface_7->geometry_n, dir_11);
    FKSurface faced_0 = *surface_7;
    float3  _S1056 = surface_7->smooth_n * make_float3 (_S1055);
    (&faced_0)->smooth_n = _S1056;
    float3  _S1057 = _S1054 * make_float3 (_S1055);
    (&faced_0)->geometry_n = _S1057;
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

__device__ bool dispersive(BSDFMaterial material_8)
{
    bool _S1060 = (material_8.dispersion) > 0.0f;
    bool _S1061;
    if(_S1060)
    {
        _S1061 = (material_8.ior) != 1.0f;
    }
    else
    {
        _S1061 = false;
    }
    return _S1061;
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
        uint _S1062 = (low_1 + high_1 + 1U) / 2U;
        bool _S1063 = (WAVELENGTH_CDF_0[_S1062]) <= u_3;
        if(_S1063)
        {
            low_1 = _S1062;
        }
        else
        {
            uint _S1064 = _S1062 - 1U;
            high_1 = _S1064;
        }
    }
    uint _S1065 = low_1;
    float _S1066 = WAVELENGTH_CDF_0[low_1 + 1U] - WAVELENGTH_CDF_0[low_1];
    return make_float2 (0.37999999523162842f + 0.00499999988824129f * (float(low_1) + (u_3 - WAVELENGTH_CDF_0[_S1065]) / _S1066), _S1066 / 0.00499999988824129f);
}

__device__ static const FixedArray<float, 243>  WAVELENGTH_WEIGHTS_0 = { {
    0.00547470012679696f, -0.00465690018609166f, 0.03257500007748604f, 0.00934640038758516f, -0.00796370021998882f, 0.05577300116419792f, 0.01846100017428398f, -0.01579399965703487f, 0.11072999984025955f, 0.0416410006582737f, -0.03577499836683273f, 0.2513900101184845f, 0.09349299967288971f, -0.08071800321340561f, 0.56742000579833984f, 0.1585099995136261f, -0.13764999806880951f, 0.97018998861312866f, 0.30943000316619873f, -0.27083000540733337f, 1.91740000247955322f, 0.55217999219894409f, -0.48754000663757324f, 3.46889996528625488f, 0.95016998052597046f, -0.84802001714706421f, 6.09439992904663086f, 1.42110002040863037f, -1.28929996490478516f, 9.45199966430664062f, 1.73409998416900635f, -1.6062999963760376f, 12.12800025939941406f, 2.08030009269714355f, -1.98810005187988281f, 15.68700027465820312f, 2.20600008964538574f, -2.20120000839233398f, 18.47699928283691406f, 2.03040003776550293f, -2.17700004577636719f, 19.92700004577636719f, 1.63429999351501465f, -2.00340008735656738f, 20.86899948120117188f, 0.99410998821258545f, -1.62629997730255127f, 20.57799911499023438f, 0.20011000335216522f, -1.11409997940063477f, 19.72100067138671875f, -0.67960000038146973f, -0.45403000712394714f, 17.77599906921386719f, -1.61679995059967041f, 0.37860000133514404f, 14.71500015258789062f, -2.53410005569458008f, 1.27540004253387451f, 11.86499977111816406f, -3.39079999923706055f, 2.2146000862121582f, 9.17669963836669922f, -4.03749990463256836f, 3.0522000789642334f, 6.59509992599487305f, -4.61299991607666016f, 3.89779996871948242f, 4.64589977264404297f, -5.43039989471435547f, 5.0121002197265625f, 3.3199000358581543f, -6.37769985198974609f, 6.33809995651245117f, 2.29699993133544922f, -7.44140005111694336f, 7.91739988327026367f, 1.45389997959136963f, -8.38580036163330078f, 9.60109996795654297f, 0.66465997695922852f, -9.0167999267578125f, 11.23999977111816406f, -0.04403600096702576f, -9.17749977111816406f, 12.63199996948242188f, -0.58126997947692871f, -8.97550010681152344f, 13.91499996185302734f, -0.95730000734329224f, -8.25290012359619141f, 14.86200046539306641f, -1.24430000782012939f, -6.92129993438720703f, 15.03899955749511719f, -1.43069994449615479f, -5.29169988632202148f, 14.90900039672851562f, -1.55149996280670166f, -3.43219995498657227f, 14.70499992370605469f, -1.63569998741149902f, -1.27190005779266357f, 14.24400043487548828f, -1.67030000686645508f, 1.15170001983642578f, 13.32199954986572266f, -1.636199951171875f, 3.73889994621276855f, 12.21199989318847656f, -1.56920003890991211f, 6.43590021133422852f, 10.94699954986572266f, -1.47730004787445068f, 9.16440010070800781f, 9.54769992828369141f, -1.36399996280670166f, 12.02000045776367188f, 8.18799972534179688f, -1.25450003147125244f, 14.78699970245361328f, 6.74429988861083984f, -1.13110005855560303f, 16.72299957275390625f, 5.08780002593994141f, -0.96561002731323242f, 18.14299964904785156f, 3.57019996643066406f, -0.80725997686386108f, 19.91900062561035156f, 2.36269998550415039f, -0.69273000955581665f, 21.05500030517578125f, 1.31369996070861816f, -0.58597999811172485f, 21.3899993896484375f, 0.42390000820159912f, -0.48298001289367676f, 20.99300003051757812f, -0.23857000470161438f, -0.39412000775337219f, 19.82200050354003906f, -0.6866300106048584f, -0.31501999497413635f, 18.12000083923339844f, -0.9412500262260437f, -0.24890999495983124f, 15.7089996337890625f, -1.02020001411437988f, -0.19076000154018402f, 13.19799995422363281f, -0.98919999599456787f, -0.14401000738143921f, 11.23999977111816406f, -0.93347001075744629f, -0.11133000254631042f, 9.36649990081787109f, -0.83820998668670654f, -0.08524099737405777f, 7.41249990463256836f, -0.70064002275466919f, -0.06283199787139893f, 5.71229982376098633f, -0.56079000234603882f, -0.04586699977517128f, 4.42280006408691406f, -0.44653001427650452f, -0.03396600112318993f, 3.34489989280700684f, -0.34457001090049744f, -0.02482499927282333f, 2.49309992790222168f, -0.26017999649047852f, -0.01808100007474422f, 1.82239997386932373f, -0.1921599954366684f, -0.01296999957412481f, 1.29499995708465576f, -0.13766999542713165f, -0.00907570030540228f, 0.92928999662399292f, -0.09956400096416473f, -0.00641620019450784f, 0.61835998296737671f, -0.06671299785375595f, -0.00421149982139468f, 0.40211999416351318f, -0.04354599863290787f, -0.00271830009296536f, 0.2844499945640564f, -0.03087200038135052f, -0.00191440002527088f, 0.20672999322414398f, -0.02246100082993507f, -0.00138829997740686f, 0.15044000744819641f, -0.01634499989449978f, -0.00101030000951141f, 0.10942000150680542f, -0.01188699994236231f, -0.0007347899954766f, 0.07099699974060059f, -0.00771349994465709f, -0.00047679000999779f, 0.04539500176906586f, -0.00493190018460155f, -0.00030484999297187f, 0.03424099832773209f, -0.00372010003775358f, -0.00022995000472292f, 0.02557599917054176f, -0.00277870008721948f, -0.00017175999528263f, 0.01842200011014938f, -0.00200140010565519f, -0.0001237099932041f, 0.01316899992525578f, -0.00143079995177686f, -0.00008843900286593f, 0.00838890019804239f, -0.00091141002485529f, -0.00005633700129692f, 0.00537079991772771f, -0.00058350997278467f, -0.00003606799873523f, 0.00328280008397996f, -0.00035665999166667f, -0.00002204600059486f, 0.00196009990759194f, -0.00021296000340953f, -0.00001316300040344f, 0.00168939994182438f, -0.00018354000349063f, -0.00001134499962063f, 0.00141050003003329f, -0.00015325000276789f, -0.00000947250009631f, 0.00097123999148607f, -0.00010551999730524f, -6.52239987175562419e-06f, 0.00066868000430986f, -0.00007264900341397f, -4.49060007667867467e-06f
} };
__device__ float3  wavelengthWeights(float wavelength_0)
{
    float _S1067 = clamp_1((wavelength_0 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    uint _S1068 = (U32_min((uint(_S1067)), (79U)));
    uint _S1069 = 3U * _S1068;
    float3  _S1070 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1069], WAVELENGTH_WEIGHTS_0[_S1069 + 1U], WAVELENGTH_WEIGHTS_0[_S1069 + 2U]);
    float3  _S1071 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1069 + 3U], WAVELENGTH_WEIGHTS_0[_S1069 + 4U], WAVELENGTH_WEIGHTS_0[_S1069 + 5U]);
    return _S1070 + (_S1071 - _S1070) * make_float3 (_S1067 - float(_S1068));
}

__device__ float dispersedIor(float ior_1, float dispersion_1, float wavelength_1)
{
    float _S1072 = (ior_1 - 1.0f) * dispersion_1 / 1.90962409973144531f;
    float _S1073 = _S1072 * (1.0f / (wavelength_1 * wavelength_1) - 2.89662933349609375f);
    bool _S1074 = dispersion_1 > 0.0f;
    float _S1075 = _slang_select(_S1074, _S1073,0.0f);
    return ior_1 + _S1075;
}

__device__ float2  vertexEta(BSDFMaterial material_9, float n_dot_v_0)
{
    bool _S1076 = n_dot_v_0 < 0.0f;
    float _S1077 = _slang_select(_S1076, material_9.ior,1.0f);
    float _S1078 = _slang_select(_S1076, 1.0f,material_9.ior);
    return make_float2 (_S1077, _S1078);
}

__device__ bool neeDecision(BSDFMaterial material_10, float n_dot_v_1, float eta_i_5, float eta_o_5)
{
    float _S1079 = fresnel((F32_abs((n_dot_v_1))), eta_i_5, eta_o_5);
    float3  _S1080 = mix_0(make_float3 (_S1079), material_10.albedo, material_10.metallic);
    float _S1081 = rgb_to_greyscale(_S1080);
    float _S1082 = (F32_max(((1.0f - _S1081) * (1.0f - material_10.metallic) * (1.0f - material_10.transmission)), (0.0f)));
    bool _S1083 = _S1082 > 0.03999999910593033f;
    bool _S1084;
    if(_S1083)
    {
        _S1084 = true;
    }
    else
    {
        _S1084 = (material_10.roughness) > 0.20000000298023224f;
    }
    return _S1084;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_11)
{
    float _S1085 = rgb_to_greyscale(material_11->translucent);
    return _S1085 > 0.0f;
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
    MediumSides _S1086;
    (&_S1086)->behind = *behind_0;
    (&_S1086)->front = *front_0;
    (&_S1086)->fillings = fillings_1;
    (&_S1086)->face = face_1;
    return _S1086;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_8, FKMedium * medium_0, uint filling_0, float3  dir_12, FKMedium * outside_0)
{
    float3  _S1087 = surface_8->geometry_n;
    MediumSides _S1088 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_8->geometry_n);
    MediumSides sides_0 = _S1088;
    bool _S1089 = surface_8->encloses;
    if(_S1089)
    {
        (&sides_0)->behind = surface_8->volume;
        *&((&(&sides_0)->fillings)->x) = surface_8->fills;
        bool _S1090 = (dot_0(dir_12, _S1087)) > 0.0f;
        if(_S1090)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_9, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_13, uint depth_2, uint lobe_7, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1091 = surface_9->geometry_n;
    ShadowContext _S1092 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_9->geometry_n, depth_2, lobe_7, true, length_3, width_2, own_3, fiber_1);
    bool _S1093 = surface_9->encloses;
    ShadowContext context_4;
    if(_S1093)
    {
        FKSurface faced_1 = *surface_9;
        float3  _S1094 = - _S1091;
        float3  _S1095 = _slang_select(turned_0, _S1094,_S1091);
        (&faced_1)->geometry_n = _S1095;
        FKMedium _S1096 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1097 = faced_1;
        FKMedium _S1098 = _S1096;
        MediumSides _S1099 = mediumSides_0(&_S1097, &_S1098, filling_1, dir_13, outside_1);
        ShadowContext _S1100 = ShadowContext_x24init_0(_S1099.behind.extinction, _S1099.front.extinction, _S1099.fillings, _S1091, depth_2, lobe_7, true, length_3, width_2, own_3, fiber_1);
        if(turned_0)
        {
            uint2  _S1101 = _S1099.fillings;
            ShadowContext _S1102 = ShadowContext_x24init_0(_S1099.front.extinction, _S1099.behind.extinction, uint2 {_S1101.y, _S1101.x}, _S1091, depth_2, lobe_7, true, length_3, width_2, own_3, fiber_1);
            context_4 = _S1102;
        }
        else
        {
            context_4 = _S1100;
        }
    }
    else
    {
        context_4 = _S1092;
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

__device__ __forceinline__ float3  BSDF(float3  in_dir_5, float3  out_dir_1, float3  n_9, float3  g_n_0, BSDFMaterial material_12, float eta_i_6, float eta_o_6, uint random_state_12, MaterialTerms terms_3, ViewTerms view_terms_3)
{
    float3  _S1103 = negate_0(in_dir_5);
    bool _S1104 = (dot_0(g_n_0, _S1103) * dot_0(g_n_0, out_dir_1)) > 0.0f;
    if(_S1104)
    {
        SampleBSDF _S1105 = lobeBSDF(in_dir_5, out_dir_1, n_9, material_12, eta_i_6, eta_o_6, 0U, random_state_12, terms_3, view_terms_3);
        SampleBSDF _S1106 = lobeBSDF(in_dir_5, out_dir_1, n_9, material_12, eta_i_6, eta_o_6, 2U, random_state_12, terms_3, view_terms_3);
        SampleBSDF _S1107 = lobeBSDF(in_dir_5, out_dir_1, n_9, material_12, eta_i_6, eta_o_6, 4U, random_state_12, terms_3, view_terms_3);
        bool _S1108 = (F32_abs((material_12.toon.x))) > 0.0f;
        if(_S1108)
        {
            SampleBSDF _S1109 = lobeBSDF(in_dir_5, out_dir_1, n_9, material_12, eta_i_6, eta_o_6, 6U, random_state_12, terms_3, view_terms_3);
            return _S1105.throughput * make_float3 (_S1105.pdf) + _S1106.throughput * make_float3 (_S1106.pdf) + _S1107.throughput * make_float3 (_S1107.pdf) + _S1109.throughput * make_float3 (_S1109.pdf);
        }
        return _S1105.throughput * make_float3 (_S1105.pdf) + _S1106.throughput * make_float3 (_S1106.pdf) + _S1107.throughput * make_float3 (_S1107.pdf);
    }
    SampleBSDF _S1110 = lobeBSDF(in_dir_5, out_dir_1, n_9, material_12, eta_i_6, eta_o_6, 1U, random_state_12, terms_3, view_terms_3);
    return _S1110.throughput * make_float3 (_S1110.pdf);
}

__device__ float3  translucentCorrection(float3  in_dir_6, float3  out_dir_2, float3  n_10, float3  g_n_1, BSDFMaterial material_13, float eta_i_7, float eta_o_7, uint random_state_13, MaterialTerms terms_4, ViewTerms view_terms_4)
{
    float _S1111 = dot_0(n_10, out_dir_2);
    float3  _S1112 = negate_0(in_dir_6);
    bool _S1113 = (_S1111 * dot_0(n_10, _S1112)) < 0.0f;
    SampleBSDF _S1114 = lobeBSDF(in_dir_6, out_dir_2, n_10, material_13, eta_i_7, eta_o_7, 0U, random_state_13, terms_4, view_terms_4);
    float3  _S1115 = negate_0(in_dir_6);
    bool _S1116 = (dot_0(g_n_1, _S1115) * dot_0(g_n_1, out_dir_2)) > 0.0f;
    float3  _S1117 = make_float3 (0.0f);
    float3  _S1118 = _S1114.throughput * make_float3 (_S1114.pdf);
    float _S1119 = _slang_select(_S1116, -1.0f,1.0f);
    float3  _S1120 = _S1118 * make_float3 (_S1119);
    float3  _S1121 = _slang_select(_S1113, _S1120,_S1117);
    return _S1121;
}

__device__ float3  translucentBSDF(float3  in_dir_7, float3  out_dir_3, float3  n_11, float3  g_n_2, BSDFMaterial material_14, float eta_i_8, float eta_o_8, uint random_state_14)
{
    float _S1122 = (F32_min(((F32_sqrt((material_14.specular_level))) * (F32_abs((eta_i_8 - eta_o_8))) / (eta_i_8 + eta_o_8)), (0.9999847412109375f)));
    float _S1123 = _S1122 * _S1122;
    float _S1124 = (1.0f + _S1122) / (1.0f - _S1122);
    float3  _S1125 = make_float3 (0.0f);
    float _S1126 = material_14.toon.x;
    bool _S1127 = _S1126 < 0.0f;
    float _S1128 = (F32_abs((_S1126)));
    bool _S1129 = _S1128 > 0.0f;
    float toon_scale_2;
    float toon_component_2;
    float toon_a_4;
    float toon_s_4;
    float toon_b_3;
    float toon_norm_3;
    float3  toon_4;
    if(_S1129)
    {
        float _S1130 = (F32_min((_S1128), (1.0f)));
        float _S1131 = 1.0f - _S1130;
        float _S1132 = rgb_to_greyscale(material_14.albedo);
        float _S1133 = _S1130 * _S1132;
        float3  _S1134 = make_float3 (_S1130) * material_14.albedo;
        float toon_a_5 = clamp_1(material_14.toon.y / _S1126, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
        float toon_s_5 = clamp_1(material_14.toon.z / _S1126, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
        float _S1135 = (F32_min((toon_a_5 + toon_s_5), (1.57079637050628662f)));
        if(_S1127)
        {
            toon_scale_2 = 1.0f - (F32_cos(((F32_min((_S1135), (toon_a_5))))));
        }
        else
        {
            float _S1136 = (F32_sin(((F32_min((_S1135), (toon_a_5))))));
            toon_scale_2 = _S1136 * _S1136 / 2.0f;
        }
        bool _S1137 = _S1135 > toon_a_5;
        bool _S1138;
        if(_S1137)
        {
            _S1138 = toon_s_5 > 0.0f;
        }
        else
        {
            _S1138 = false;
        }
        if(_S1138)
        {
            if(_S1127)
            {
                float _S1139 = (F32_cos((toon_a_5)));
                float _S1140 = (F32_cos((_S1135)));
                toon_component_2 = (1.0f + toon_a_5 / toon_s_5) * (_S1139 - _S1140) - ((F32_sin((_S1135))) - _S1135 * _S1140 - ((F32_sin((toon_a_5))) - toon_a_5 * _S1139)) / toon_s_5;
            }
            else
            {
                float _S1141 = 2.0f * toon_a_5;
                float _S1142 = (F32_cos((_S1141)));
                float _S1143 = 2.0f * _S1135;
                float _S1144 = (F32_cos((_S1143)));
                toon_component_2 = (1.0f + toon_a_5 / toon_s_5) * (_S1142 - _S1144) / 4.0f - ((F32_sin((_S1143))) / 8.0f - _S1135 * _S1144 / 4.0f - ((F32_sin((_S1141))) / 8.0f - toon_a_5 * _S1142 / 4.0f)) / toon_s_5;
            }
            float integral_1 = toon_scale_2 + toon_component_2;
            toon_scale_2 = integral_1;
        }
        else
        {
        }
        float _S1145 = 6.28318548202514648f * toon_scale_2;
        toon_scale_2 = _S1131;
        toon_component_2 = _S1133;
        toon_4 = _S1134;
        toon_a_4 = toon_a_5;
        toon_s_4 = toon_s_5;
        toon_b_3 = _S1135;
        toon_norm_3 = _S1145;
    }
    else
    {
        toon_scale_2 = 1.0f;
        toon_component_2 = 0.0f;
        toon_4 = _S1125;
        toon_a_4 = 0.0f;
        toon_s_4 = 0.0f;
        toon_b_3 = 0.0f;
        toon_norm_3 = 1.0f;
    }
    float _S1146 = translucentShare(material_14);
    MaterialTerms _S1147 = MaterialTerms_x24init_0(_S1123, _S1124, _S1146, toon_scale_2, toon_component_2, toon_4, toon_a_4, toon_s_4, toon_b_3, _S1127, toon_norm_3);
    float3  _S1148 = negate_0(in_dir_7);
    float _S1149 = sign_0(dot_0(n_11, _S1148));
    float3  _S1150 = n_11 * make_float3 (_S1149);
    AnisotropicFrame _S1151 = anisotropicFrame(material_14, _S1150);
    float3  _S1152 = make_float3 (1.0f);
    float _S1153 = rgb_to_greyscale(material_14.sheen);
    bool _S1154 = _S1153 > 0.0f;
    float sheen_component_2;
    float3  sheen_4;
    float3  view_3;
    float3  scale_4;
    if(_S1154)
    {
        float _S1155 = clamp_1((F32_sqrt(((F32_max((dot_0(_S1150, _S1148)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S1156 = (U32_min((uint(_S1155)), (22U)));
        float least_1 = (F32_sqrt((0.05000000074505806f)));
        float _S1157 = (F32_sqrt((0.10000000149011612f)));
        bool _S1158 = (material_14.velvet) > 0.0f;
        float _S1159 = _slang_select(_S1158, _S1157,least_1);
        float _S1160 = (clamp_1((F32_sqrt(((F32_max((material_14.sheen_roughness), (0.0f)))))), _S1159, 1.0f) - _S1159) / (1.0f - _S1159) * 23.0f;
        uint _S1161 = (U32_min((uint(_S1160)), (22U)));
        uint _S1162 = _S1156 * 24U + _S1161;
        float _S1163 = _S1155 - float(_S1156);
        float _S1164 = _S1160 - float(_S1161);
        uint _S1165 = _S1162 + 24U;
        float a_10 = SHEEN_ALBEDO_0[_S1162] + (SHEEN_ALBEDO_0[_S1165] - SHEEN_ALBEDO_0[_S1162]) * _S1163;
        uint _S1166 = _S1162 + 1U;
        uint _S1167 = _S1165 + 1U;
        float b_8 = SHEEN_ALBEDO_0[_S1166] + (SHEEN_ALBEDO_0[_S1167] - SHEEN_ALBEDO_0[_S1166]) * _S1163;
        float _S1168 = (F32_exp((a_10 + (b_8 - a_10) * _S1164)));
        if(_S1158)
        {
            float a_11 = VELVET_ALBEDO_0[_S1162] + (VELVET_ALBEDO_0[_S1165] - VELVET_ALBEDO_0[_S1162]) * _S1163;
            float b_9 = VELVET_ALBEDO_0[_S1166] + (VELVET_ALBEDO_0[_S1167] - VELVET_ALBEDO_0[_S1166]) * _S1163;
            float _S1169 = a_11 + (b_9 - a_11) * _S1164;
            sheen_component_2 = _S1169;
        }
        else
        {
            sheen_component_2 = _S1168;
        }
        float _S1170 = (F32_min((sheen_component_2), (1.0f)));
        float3  _S1171 = make_float3 (1.0f) - material_14.sheen * make_float3 (_S1170);
        float _S1172 = rgb_to_greyscale(material_14.sheen);
        float _S1173 = _S1172 * _S1170;
        float3  _S1174 = material_14.sheen / make_float3 ((F32_max((sheen_component_2), (1.0f))));
        sheen_component_2 = _S1173;
        sheen_4 = _S1174;
        view_3 = _S1148;
        scale_4 = _S1171;
    }
    else
    {
        sheen_component_2 = 0.0f;
        sheen_4 = _S1125;
        view_3 = _S1125;
        scale_4 = _S1152;
    }
    float3  scale_5 = scale_4 * make_float3 (_S1147.toon_scale);
    float toon_view_3;
    float3  toon_axis_3;
    if(_S1129)
    {
        float _S1175 = dot_0(_S1150, _S1148);
        float _S1176 = (F32_acos(((F32_min((_S1175), (1.0f))))));
        if(_S1176 < (_S1147.toon_a))
        {
            toon_scale_2 = 1.0f;
        }
        else
        {
            toon_scale_2 = (F32_max((1.0f - (_S1176 - _S1147.toon_a) / (F32_max((_S1147.toon_s), (0.0000152587890625f)))), (0.0f)));
        }
        if(_S1147.toon_glossy)
        {
            float3  _S1177 = make_float3 (2.0f * _S1175) * _S1150 - _S1148;
            float3  _S1178 = ((((_S1177)) * make_float3(rnorm3df(((_S1177)).x, ((_S1177)).y, ((_S1177)).z))));
            toon_4 = _S1178;
        }
        else
        {
            toon_4 = _S1150;
        }
        toon_view_3 = toon_scale_2;
        toon_axis_3 = toon_4;
    }
    else
    {
        toon_view_3 = 0.0f;
        toon_axis_3 = _S1150;
    }
    float _S1179 = _S1151.alphas.x;
    float _S1180 = (F32_sqrt(((F32_min((_S1179), (_S1151.alphas.y))))));
    bool _S1181 = _S1179 > 0.0f;
    float _S1182 = _slang_select(_S1181, _S1180,material_14.roughness);
    float _S1183 = _S1182 * _S1182;
    float _S1184 = (F32_pow((_S1183), (1.81585001945495605f))) * (2.15371990203857422f - 0.73285001516342163f * _S1183) / (1.0f + 1.28094995021820068f * _S1183);
    bool _S1185 = _S1183 > 0.0f;
    float _S1186 = _slang_select(_S1185, _S1184,0.0f);
    float _S1187 = clamp_1(dot_0(_S1150, _S1148), 0.0f, 1.0f);
    float _S1188 = _S1183 * _S1182;
    float _S1189 = (F32_min((1.00064504146575928f - _S1182 * (0.00375499995425344f + _S1187 * (-0.04133399948477745f + _S1187 * (-0.90938502550125122f + _S1187 * 0.35275399684906006f))) - _S1183 * (0.27602800726890564f + _S1187 * (1.27023398876190186f + _S1187 * 0.04740000143647194f)) - _S1188 * (0.31452900171279907f - _S1187 * 0.34830701351165771f) + _S1188 * _S1182 * 0.27229699492454529f), (1.0f)));
    float3  _S1190 = min_1(make_float3 (1.0f) / (make_float3 (1.0f) - material_14.albedo * make_float3 (_S1186)), make_float3 (1.0f / (F32_max((_S1189), (0.0000152587890625f)))));
    AnisotropicFrame _S1191 = _S1151;
    ViewTerms _S1192 = ViewTerms_x24init_0(_S1148, _S1150, &_S1191, scale_5, sheen_component_2, sheen_4, view_3, _S1190, toon_view_3, toon_axis_3);
    float3  _S1193 = BSDF(in_dir_7, out_dir_3, n_11, g_n_2, material_14, eta_i_8, eta_o_8, random_state_14, _S1147, _S1192);
    float3  _S1194 = translucentCorrection(in_dir_7, out_dir_3, n_11, g_n_2, material_14, eta_i_8, eta_o_8, random_state_14, _S1147, _S1192);
    return _S1193 + _S1194;
}

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_8, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_4, BSDFMaterial * material_15, float eta_i_9, float eta_o_9, bool competing_1, uint random_state_15)
{
    bool _S1195 = !competing_1;
    bool _S1196;
    if(_S1195)
    {
        _S1196 = true;
    }
    else
    {
        _S1196 = (light_2->density) == 0.0f;
    }
    if(_S1196)
    {
        bool _S1197 = isTranslucent_0(material_15);
        _S1196 = _S1197;
    }
    else
    {
        _S1196 = false;
    }
    if(_S1196)
    {
        float3  _S1198 = translucentBSDF(in_dir_8, light_2->dir, smooth_n_5, geometry_n_4, *material_15, eta_i_9, eta_o_9, random_state_15);
        return _S1198 * light_2->radiance;
    }
    float _S1199 = (F32_min(((F32_sqrt((material_15->specular_level))) * (F32_abs((eta_i_9 - eta_o_9))) / (eta_i_9 + eta_o_9)), (0.9999847412109375f)));
    float _S1200 = _S1199 * _S1199;
    float _S1201 = (1.0f + _S1199) / (1.0f - _S1199);
    float3  _S1202 = make_float3 (0.0f);
    float3  _S1203 = material_15->toon;
    float _S1204 = material_15->toon.x;
    bool _S1205 = _S1204 < 0.0f;
    float _S1206 = (F32_abs((_S1204)));
    bool _S1207 = _S1206 > 0.0f;
    float toon_scale_3;
    float toon_component_3;
    float toon_a_6;
    float toon_s_6;
    float toon_b_4;
    float toon_norm_4;
    float3  toon_5;
    if(_S1207)
    {
        float _S1208 = (F32_min((_S1206), (1.0f)));
        float _S1209 = 1.0f - _S1208;
        float3  _S1210 = material_15->albedo;
        float _S1211 = rgb_to_greyscale(material_15->albedo);
        float _S1212 = _S1208 * _S1211;
        float3  _S1213 = make_float3 (_S1208) * _S1210;
        float toon_a_7 = clamp_1(_S1203.y / _S1204, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
        float toon_s_7 = clamp_1(_S1203.z / _S1204, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
        float _S1214 = (F32_min((toon_a_7 + toon_s_7), (1.57079637050628662f)));
        if(_S1205)
        {
            toon_scale_3 = 1.0f - (F32_cos(((F32_min((_S1214), (toon_a_7))))));
        }
        else
        {
            float _S1215 = (F32_sin(((F32_min((_S1214), (toon_a_7))))));
            toon_scale_3 = _S1215 * _S1215 / 2.0f;
        }
        bool _S1216 = _S1214 > toon_a_7;
        if(_S1216)
        {
            _S1196 = toon_s_7 > 0.0f;
        }
        else
        {
            _S1196 = false;
        }
        if(_S1196)
        {
            if(_S1205)
            {
                float _S1217 = (F32_cos((toon_a_7)));
                float _S1218 = (F32_cos((_S1214)));
                toon_component_3 = (1.0f + toon_a_7 / toon_s_7) * (_S1217 - _S1218) - ((F32_sin((_S1214))) - _S1214 * _S1218 - ((F32_sin((toon_a_7))) - toon_a_7 * _S1217)) / toon_s_7;
            }
            else
            {
                float _S1219 = 2.0f * toon_a_7;
                float _S1220 = (F32_cos((_S1219)));
                float _S1221 = 2.0f * _S1214;
                float _S1222 = (F32_cos((_S1221)));
                toon_component_3 = (1.0f + toon_a_7 / toon_s_7) * (_S1220 - _S1222) / 4.0f - ((F32_sin((_S1221))) / 8.0f - _S1214 * _S1222 / 4.0f - ((F32_sin((_S1219))) / 8.0f - toon_a_7 * _S1220 / 4.0f)) / toon_s_7;
            }
            float integral_2 = toon_scale_3 + toon_component_3;
            toon_scale_3 = integral_2;
        }
        else
        {
        }
        float _S1223 = 6.28318548202514648f * toon_scale_3;
        toon_scale_3 = _S1209;
        toon_component_3 = _S1212;
        toon_5 = _S1213;
        toon_a_6 = toon_a_7;
        toon_s_6 = toon_s_7;
        toon_b_4 = _S1214;
        toon_norm_4 = _S1223;
    }
    else
    {
        toon_scale_3 = 1.0f;
        toon_component_3 = 0.0f;
        toon_5 = _S1202;
        toon_a_6 = 0.0f;
        toon_s_6 = 0.0f;
        toon_b_4 = 0.0f;
        toon_norm_4 = 1.0f;
    }
    float _S1224 = translucentShare(*material_15);
    MaterialTerms _S1225 = MaterialTerms_x24init_0(_S1200, _S1201, _S1224, toon_scale_3, toon_component_3, toon_5, toon_a_6, toon_s_6, toon_b_4, _S1205, toon_norm_4);
    float3  _S1226 = negate_0(in_dir_8);
    float _S1227 = sign_0(dot_0(smooth_n_5, _S1226));
    float3  _S1228 = smooth_n_5 * make_float3 (_S1227);
    AnisotropicFrame _S1229 = anisotropicFrame(*material_15, _S1228);
    float3  _S1230 = make_float3 (1.0f);
    float3  _S1231 = material_15->sheen;
    float _S1232 = rgb_to_greyscale(material_15->sheen);
    bool _S1233 = _S1232 > 0.0f;
    float sheen_component_3;
    float3  sheen_5;
    float3  view_4;
    float3  scale_6;
    if(_S1233)
    {
        float _S1234 = clamp_1((F32_sqrt(((F32_max((dot_0(_S1228, _S1226)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S1235 = (U32_min((uint(_S1234)), (22U)));
        float least_2 = (F32_sqrt((0.05000000074505806f)));
        float _S1236 = (F32_sqrt((0.10000000149011612f)));
        bool _S1237 = (material_15->velvet) > 0.0f;
        float _S1238 = _slang_select(_S1237, _S1236,least_2);
        float _S1239 = (clamp_1((F32_sqrt(((F32_max((material_15->sheen_roughness), (0.0f)))))), _S1238, 1.0f) - _S1238) / (1.0f - _S1238) * 23.0f;
        uint _S1240 = (U32_min((uint(_S1239)), (22U)));
        uint _S1241 = _S1235 * 24U + _S1240;
        float _S1242 = _S1234 - float(_S1235);
        float _S1243 = _S1239 - float(_S1240);
        uint _S1244 = _S1241 + 24U;
        float a_12 = SHEEN_ALBEDO_0[_S1241] + (SHEEN_ALBEDO_0[_S1244] - SHEEN_ALBEDO_0[_S1241]) * _S1242;
        uint _S1245 = _S1241 + 1U;
        uint _S1246 = _S1244 + 1U;
        float b_10 = SHEEN_ALBEDO_0[_S1245] + (SHEEN_ALBEDO_0[_S1246] - SHEEN_ALBEDO_0[_S1245]) * _S1242;
        float _S1247 = (F32_exp((a_12 + (b_10 - a_12) * _S1243)));
        if(_S1237)
        {
            float a_13 = VELVET_ALBEDO_0[_S1241] + (VELVET_ALBEDO_0[_S1244] - VELVET_ALBEDO_0[_S1241]) * _S1242;
            float b_11 = VELVET_ALBEDO_0[_S1245] + (VELVET_ALBEDO_0[_S1246] - VELVET_ALBEDO_0[_S1245]) * _S1242;
            float _S1248 = a_13 + (b_11 - a_13) * _S1243;
            sheen_component_3 = _S1248;
        }
        else
        {
            sheen_component_3 = _S1247;
        }
        float _S1249 = (F32_min((sheen_component_3), (1.0f)));
        float3  _S1250 = make_float3 (1.0f) - _S1231 * make_float3 (_S1249);
        float _S1251 = rgb_to_greyscale(_S1231);
        float _S1252 = _S1251 * _S1249;
        float3  _S1253 = _S1231 / make_float3 ((F32_max((sheen_component_3), (1.0f))));
        sheen_component_3 = _S1252;
        sheen_5 = _S1253;
        view_4 = _S1226;
        scale_6 = _S1250;
    }
    else
    {
        sheen_component_3 = 0.0f;
        sheen_5 = _S1202;
        view_4 = _S1202;
        scale_6 = _S1230;
    }
    float3  scale_7 = scale_6 * make_float3 (_S1225.toon_scale);
    float toon_view_4;
    float3  toon_axis_4;
    if(_S1207)
    {
        float _S1254 = dot_0(_S1228, _S1226);
        float _S1255 = (F32_acos(((F32_min((_S1254), (1.0f))))));
        if(_S1255 < (_S1225.toon_a))
        {
            toon_scale_3 = 1.0f;
        }
        else
        {
            toon_scale_3 = (F32_max((1.0f - (_S1255 - _S1225.toon_a) / (F32_max((_S1225.toon_s), (0.0000152587890625f)))), (0.0f)));
        }
        if(_S1225.toon_glossy)
        {
            float3  _S1256 = make_float3 (2.0f * _S1254) * _S1228 - _S1226;
            float3  _S1257 = ((((_S1256)) * make_float3(rnorm3df(((_S1256)).x, ((_S1256)).y, ((_S1256)).z))));
            toon_5 = _S1257;
        }
        else
        {
            toon_5 = _S1228;
        }
        toon_view_4 = toon_scale_3;
        toon_axis_4 = toon_5;
    }
    else
    {
        toon_view_4 = 0.0f;
        toon_axis_4 = _S1228;
    }
    float _S1258 = material_15->roughness;
    float _S1259 = _S1229.alphas.x;
    float _S1260 = (F32_sqrt(((F32_min((_S1259), (_S1229.alphas.y))))));
    bool _S1261 = _S1259 > 0.0f;
    float _S1262 = _slang_select(_S1261, _S1260,_S1258);
    float _S1263 = _S1262 * _S1262;
    float _S1264 = (F32_pow((_S1263), (1.81585001945495605f))) * (2.15371990203857422f - 0.73285001516342163f * _S1263) / (1.0f + 1.28094995021820068f * _S1263);
    bool _S1265 = _S1263 > 0.0f;
    float _S1266 = _slang_select(_S1265, _S1264,0.0f);
    float _S1267 = clamp_1(dot_0(_S1228, _S1226), 0.0f, 1.0f);
    float _S1268 = _S1263 * _S1262;
    float _S1269 = (F32_min((1.00064504146575928f - _S1262 * (0.00375499995425344f + _S1267 * (-0.04133399948477745f + _S1267 * (-0.90938502550125122f + _S1267 * 0.35275399684906006f))) - _S1263 * (0.27602800726890564f + _S1267 * (1.27023398876190186f + _S1267 * 0.04740000143647194f)) - _S1268 * (0.31452900171279907f - _S1267 * 0.34830701351165771f) + _S1268 * _S1262 * 0.27229699492454529f), (1.0f)));
    float3  _S1270 = min_1(make_float3 (1.0f) / (make_float3 (1.0f) - material_15->albedo * make_float3 (_S1266)), make_float3 (1.0f / (F32_max((_S1269), (0.0000152587890625f)))));
    AnisotropicFrame _S1271 = _S1229;
    ViewTerms _S1272 = ViewTerms_x24init_0(_S1226, _S1228, &_S1271, scale_7, sheen_component_3, sheen_5, view_4, _S1270, toon_view_4, toon_axis_4);
    if(_S1195)
    {
        _S1196 = true;
    }
    else
    {
        _S1196 = (light_2->density) == 0.0f;
    }
    if(_S1196)
    {
        float3  _S1273 = BSDF(in_dir_8, light_2->dir, smooth_n_5, geometry_n_4, *material_15, eta_i_9, eta_o_9, random_state_15, _S1225, _S1272);
        return _S1273 * light_2->radiance;
    }
    float3  _S1274 = light_2->dir;
    bool _S1275 = (dot_0(geometry_n_4, - in_dir_8) * dot_0(geometry_n_4, light_2->dir)) <= 0.0f;
    float3  _S1276 = neeBSDF(in_dir_8, _S1274, smooth_n_5, *material_15, eta_i_9, eta_o_9, _S1275, light_2->density, true, random_state_15, _S1225, _S1272);
    return _S1276 * light_2->radiance * make_float3 (light_2->density);
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1277 = (F32_sqrt((random_1_0)));
    float _S1278 = 6.28318548202514648f * random_2_0;
    float _S1279 = _S1277 * (F32_cos((_S1278)));
    float _S1280 = _S1277 * (F32_sin((_S1278)));
    float _S1281 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1279 * _S1279 - _S1280 * _S1280))))));
    return make_float3 (_S1279, _S1281, _S1280);
}

static __device__ float3  reflect_0(float3  i_20, float3  n_12)
{
    return i_20 - make_float3 (2.0f * dot_0(n_12, i_20)) * n_12;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_9, float3  n_13, BSDFMaterial material_16, float eta_i_10, float eta_o_10, uint random_init_1, float2  screen_space_0, MaterialTerms terms_5, ViewTerms view_terms_5)
{
    uint random_state_16 = random_init_1;
    float3  _S1282 = negate_0(in_dir_9);
    float _S1283 = dot_0(n_13, _S1282);
    float _S1284 = sign_0(_S1283);
    float3  n_i_4 = n_13 * make_float3 (_S1284);
    float _S1285 = (F32_abs((_S1283)));
    float _S1286 = material_16.roughness;
    float _S1287 = _S1286 * _S1286;
    float3  _S1288 = sampleHalfVector(_S1282, n_i_4, _S1287, view_terms_5.frame, &random_state_16);
    HalfTerms _S1289 = precomputeHalf(in_dir_9, _S1288, material_16, eta_i_10, eta_o_10, terms_5, view_terms_5);
    float3  _S1290 = make_float3 (1.0f);
    SampleBSDF _S1291 = SampleBSDF_x24init_0(_S1290, _S1290, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S1291;
    Random _S1292 = pcg(random_state_16);
    random_state_16 = _S1292.state;
    bool _S1293 = (_S1292.value) < (_S1289.p_sheen_velvet);
    if(_S1293)
    {
        Random _S1294 = pcg(random_state_16);
        Random _S1295 = pcg(_S1294.state);
        (&sample_1)->random_state = _S1295.state;
        float _S1296 = _S1294.value;
        float _S1297 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1296 * _S1296))))));
        float _S1298 = 6.28318548202514648f * _S1295.value;
        float3  _S1299 = tangentToWorld(make_float3 (_S1297 * (F32_cos((_S1298))), _S1294.value, _S1297 * (F32_sin((_S1298)))), n_i_4);
        (&sample_1)->unit_direction = _S1299;
        float3  _S1300 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S1287, material_16, _S1289, 4U);
        (&sample_1)->throughput = _S1300;
        float _S1301 = lobeDensity(_S1294.value, 0.0f, _S1285, _S1287, _S1289, eta_i_10, eta_o_10, 4U);
        (&sample_1)->pdf = _S1301;
        (&sample_1)->lobe = 4U;
        return sample_1;
    }
    float u_4 = _S1292.value - _S1289.p_sheen_velvet;
    bool _S1302 = u_4 < (_S1289.p_diffuse);
    if(_S1302)
    {
        Random _S1303 = pcg(random_state_16);
        Random _S1304 = pcg(_S1303.state);
        (&sample_1)->random_state = _S1304.state;
        float3  _S1305 = sampleCosWeightedHemisphere(_S1303.value, _S1304.value);
        bool _S1306 = u_4 < (_S1289.p_diffuse * _S1289.translucent_share);
        float _S1307 = _S1305.y;
        float _S1308 = - _S1307;
        float _S1309 = _slang_select(_S1306, _S1308,_S1307);
        float3  _S1310 = tangentToWorld(make_float3 (_S1305.x, _S1309, _S1305.z), n_i_4);
        (&sample_1)->unit_direction = _S1310;
        float3  _S1311 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S1287, material_16, _S1289, 0U);
        (&sample_1)->throughput = _S1311;
        float _S1312 = lobeDensity(_S1309, 0.0f, _S1285, _S1287, _S1289, eta_i_10, eta_o_10, 0U);
        (&sample_1)->pdf = _S1312;
        (&sample_1)->refracted = _S1306;
        return sample_1;
    }
    bool _S1313 = u_4 < (_S1289.p_diffuse + _S1289.p_toon);
    if(_S1313)
    {
        Random _S1314 = pcg(random_state_16);
        Random _S1315 = pcg(_S1314.state);
        (&sample_1)->random_state = _S1315.state;
        float _S1316 = _S1314.value * _S1289.toon_norm / 6.28318548202514648f;
        float t_21;
        if(_S1289.toon_glossy)
        {
            t_21 = (F32_acos((clamp_1(1.0f - _S1316, -1.0f, 1.0f))));
        }
        else
        {
            t_21 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1316)))), (1.0f))))));
        }
        if(t_21 < (_S1289.toon_a))
        {
        }
        else
        {
            t_21 = (_S1289.toon_a + _S1289.toon_b) / 2.0f;
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
            float _S1317;
            if(t_21 < (_S1289.toon_a))
            {
                _S1317 = 1.0f;
            }
            else
            {
                _S1317 = (F32_max((1.0f - (t_21 - _S1289.toon_a) / (F32_max((_S1289.toon_s), (0.0000152587890625f)))), (0.0f)));
            }
            float integral_3;
            if(_S1289.toon_glossy)
            {
                integral_3 = 1.0f - (F32_cos(((F32_min((t_21), (_S1289.toon_a))))));
            }
            else
            {
                float _S1318 = (F32_sin(((F32_min((t_21), (_S1289.toon_a))))));
                integral_3 = _S1318 * _S1318 / 2.0f;
            }
            bool _S1319 = t_21 > (_S1289.toon_a);
            bool _S1320;
            if(_S1319)
            {
                _S1320 = (_S1289.toon_s) > 0.0f;
            }
            else
            {
                _S1320 = false;
            }
            float integral_4;
            if(_S1320)
            {
                if(_S1289.toon_glossy)
                {
                    float _S1321 = (F32_cos((_S1289.toon_a)));
                    float _S1322 = (F32_cos((t_21)));
                    integral_4 = (1.0f + _S1289.toon_a / _S1289.toon_s) * (_S1321 - _S1322) - ((F32_sin((t_21))) - t_21 * _S1322 - ((F32_sin((_S1289.toon_a))) - _S1289.toon_a * _S1321)) / _S1289.toon_s;
                }
                else
                {
                    float _S1323 = 2.0f * _S1289.toon_a;
                    float _S1324 = (F32_cos((_S1323)));
                    float _S1325 = 2.0f * t_21;
                    float _S1326 = (F32_cos((_S1325)));
                    integral_4 = (1.0f + _S1289.toon_a / _S1289.toon_s) * (_S1324 - _S1326) / 4.0f - ((F32_sin((_S1325))) / 8.0f - t_21 * _S1326 / 4.0f - ((F32_sin((_S1323))) / 8.0f - _S1289.toon_a * _S1324 / 4.0f)) / _S1289.toon_s;
                }
                float integral_5 = integral_3 + integral_4;
                integral_4 = integral_5;
            }
            else
            {
                integral_4 = integral_3;
            }
            float _S1327 = _S1317 * (F32_sin((t_21)));
            float _S1328;
            if(_S1289.toon_glossy)
            {
                _S1328 = 1.0f;
            }
            else
            {
                _S1328 = (F32_cos((t_21)));
            }
            float _S1329 = _S1327 * _S1328;
            float _S1330 = (integral_4 - _S1316) / _S1329;
            bool _S1331 = _S1329 > 0.0f;
            float _S1332 = _slang_select(_S1331, _S1330,0.0f);
            float _S1333 = clamp_1(t_21 - _S1332, 0.0f, _S1289.toon_b);
            int k_1 = k_0 + int(1);
            t_21 = _S1333;
            k_0 = k_1;
        }
        float _S1334 = 6.28318548202514648f * _S1315.value;
        float _S1335 = (F32_sin((t_21)));
        float3  _S1336 = tangentToWorld(make_float3 (_S1335 * (F32_cos((_S1334))), (F32_cos((t_21))), _S1335 * (F32_sin((_S1334)))), _S1289.toon_axis);
        (&sample_1)->unit_direction = _S1336;
        float3  _S1337 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S1287, material_16, _S1289, 6U);
        (&sample_1)->throughput = _S1337;
        float _S1338 = lobeDensity(dot_0(n_i_4, (&sample_1)->unit_direction), dot_0((&sample_1)->unit_direction, _S1289.toon_axis), _S1285, _S1287, _S1289, eta_i_10, eta_o_10, 6U);
        (&sample_1)->pdf = _S1338;
        bool _S1339 = (dot_0(n_i_4, (&sample_1)->unit_direction)) < 0.0f;
        (&sample_1)->refracted = _S1339;
        (&sample_1)->lobe = 6U;
        return sample_1;
    }
    float u_5 = u_4 - _S1289.p_toon;
    bool _S1340 = u_5 < (_S1289.p_diffuse + _S1289.p_refract);
    if(_S1340)
    {
        (&sample_1)->unit_direction = _S1289.refracted;
        float _S1341 = lobeDensity(0.0f, dot_0((&sample_1)->unit_direction, _S1288), _S1285, _S1287, _S1289, eta_i_10, eta_o_10, 1U);
        (&sample_1)->pdf = _S1341;
        float3  _S1342 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S1287, material_16, _S1289, 1U);
        (&sample_1)->throughput = _S1342;
        (&sample_1)->random_state = random_state_16;
        (&sample_1)->refracted = true;
        (&sample_1)->lobe = 1U;
        return sample_1;
    }
    float3  _S1343 = reflect_0(in_dir_9, _S1288);
    float3  _S1344 = ((((_S1343)) * make_float3(rnorm3df(((_S1343)).x, ((_S1343)).y, ((_S1343)).z))));
    (&sample_1)->unit_direction = _S1344;
    float3  _S1345 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S1287, material_16, _S1289, 2U);
    (&sample_1)->throughput = _S1345;
    (&sample_1)->random_state = random_state_16;
    (&sample_1)->lobe = 2U;
    float _S1346 = lobeDensity(0.0f, 0.0f, _S1285, _S1287, _S1289, eta_i_10, eta_o_10, 2U);
    (&sample_1)->pdf = _S1346;
    return sample_1;
}

__device__ bool withinInverseFootprint(float pdf_7, bool diffuse_0, float prev_cos_0, float distance_5, float threshold_1)
{
    bool _S1347 = pdf_7 > 0.0f;
    bool _S1348;
    if(_S1347)
    {
        if(diffuse_0)
        {
            _S1348 = true;
        }
        else
        {
            _S1348 = (pdf_7 * prev_cos_0 / (distance_5 * distance_5) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S1348 = false;
    }
    return _S1348;
}

__device__ bool roughLobe(float pdf_8, bool diffuse_1, float roughness_1)
{
    bool _S1349 = pdf_8 > 0.0f;
    bool _S1350;
    if(_S1349)
    {
        if(diffuse_1)
        {
            _S1350 = true;
        }
        else
        {
            _S1350 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S1350 = false;
    }
    return _S1350;
}

static __device__ bool passesLayer_0(uint layers_0, bool refracting_0, bool passed_0)
{
    bool _S1351 = layers_0 > 1U;
    bool _S1352;
    if(_S1351)
    {
        _S1352 = refracting_0 != passed_0;
    }
    else
    {
        _S1352 = false;
    }
    return _S1352;
}

static __device__ float widened_0(float spread_1, float pdf_9, bool delta_0)
{
    float _S1353 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * pdf_9))))), (3.14159274101257324f)));
    bool _S1354 = !delta_0;
    float _S1355 = _slang_select(_S1354, _S1353,0.0f);
    return spread_1 + _S1355;
}

static __device__ bool boundsVolume_0(FKSurface * surface_10)
{
    return surface_10->encloses;
}

static __device__ bool leavesInFront_0(float3  face_2, float3  dir_14, float3  g_3)
{
    return ((dot_0(dir_14, g_3)) > 0.0f) == ((dot_0(g_3, face_2)) > 0.0f);
}

static __device__ Shift walk_0(Domain * dom_7, Reservoir * r_8, bool replay_2, float scale_8, Selection * sel_7)
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
    uint b_12;
    uint layer_0;
    float3  throughput_2;
    float3  chain_throughput_0;
    TreeSample light_3;
    int _S1356;
    Shift ended_0;
    float sky_pdf_1;
    float spread_3;
    float width_4;
    uint b_13;
    float3  _S1357 = make_float3 (0.0f);
    Shift _S1358 = Shift_x24init_0(_S1357, 0.0f);
    uint _S1359 = r_8->path;
    uint _S1360 = extractBits_0(r_8->path, 0U, 5U);
    uint _S1361 = extractBits_0(_S1359, 5U, 5U);
    uint _S1362 = extractBits_0(_S1359, 10U, 2U);
    uint _S1363 = extractBits_0(_S1359, 12U, 3U);
    bool passes_0;
    if(replay_2)
    {
        bool _S1364 = _S1363 >= 3U;
        uint _S1365 = _slang_select(_S1364, 1U,0U);
        uint _S1366 = _S1360 + _S1365;
        uint _S1367 = (fcptMaxBounces());
        passes_0 = _S1366 > _S1367;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1358;
    }
    uint _S1368 = _S1361 - 1U;
    bool _S1369 = _S1363 == 3U;
    uint _S1370 = _slang_select(_S1369, 1U,0U);
    uint _S1371 = _S1360 + _S1370;
    bool _S1372 = _S1362 == 0U;
    uint _S1373 = _slang_select(_S1372, _S1371,_S1368);
    FKHit _S1374 = (fcptReservoirHit((*r_8)));
    float3  _S1375 = dom_7->x0;
    float3  _S1376 = dom_7->x1 - dom_7->x0;
    float3  _S1377 = ((((_S1376)) * make_float3(rnorm3df(((_S1376)).x, ((_S1376)).y, ((_S1376)).z))));
    FKRay _S1378 = Ray_x24init_0(dom_7->x1, _S1377);
    FKRay ray_2 = _S1378;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1357;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_1 = throughput_3;
    float3  glowed_0 = _S1357;
    float3  extinction_in_0 = _S1357;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1379 = dom_7->spread;
    float _S1380 = dom_7->width;
    float _S1381 = length_0(_S1376);
    NEEVertex _S1382 = NEEVertex_x24init_0(true, 0.0f, _S1357, _S1357, _S1357);
    NEEVertex nee_vertex_0 = _S1382;
    Vertex _S1383 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S1383;
    Reservoir _S1384 = (Reservoir{});
    Reservoir chain_0 = _S1384;
    uint _S1385 = r_8->seed;
    (&chain_0)->seed = r_8->seed;
    (&ray_2)->origin = _S1375;
    (&hit_4)->distance = _S1381;
    FKMedium _S1386 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1387 = filling_2;
    bool _S1388 = (fcptVaryingUsed());
    uint _S1389 = _slang_select(_S1388, _S1387,4294967295U);
    filling_2 = _S1389;
    scatter_in_0 = _S1386.scatter;
    extinction_in_0 = _S1386.extinction;
    g_in_0 = _S1386.g;
    Reservoir _S1390 = chain_0;
    uint _S1391 = filling_2;
    for(;;)
    {
        bool _S1392 = (fcptVaryingUsed());
        if(_S1392)
        {
            passes_0 = _S1391 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1393 = (fcptMajorant((_S1391)));
            spread_2 = _S1393;
        }
        else
        {
            spread_2 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_2)
        {
            turned_1 = 4294967295U == _S1373;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1362 == 1U;
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
            ended_0 = _S1358;
            sky_pdf_0 = 0.0f;
            spread_2 = _S1379;
            width_3 = _S1380;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_12 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1394 = (&prev_0)->rough;
        if(_S1394)
        {
            turned_1 = !(spread_2 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S1395 = stream(_S1385, 384U);
        uint tracking_0 = _S1395;
        weight_1 = throughput_3;
        glowed_0 = _S1357;
        b_12 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        threshold_2 = _S1379;
        width_3 = _S1380;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1356 = int(1);
                break;
            }
            uint _S1396 = b_12 + 320U;
            bool _S1397 = b_12 == 4294967295U;
            uint _S1398 = _slang_select(_S1397, 384U,_S1396);
            uint _S1399 = stream(_S1385, _S1398);
            Random _S1400 = pcg(_S1399);
            float _S1401 = freeFlight_0(_S1400.value, spread_2);
            if(passes_0)
            {
                float3  _S1402 = (&ray_2)->origin;
                float3  _S1403 = (&ray_2)->unit_direction;
                float _S1404 = (&hit_4)->distance;
                uint _S1405 = _slang_select(_S1397, 0U,b_12);
                uint _S1406 = (&prev_0)->lobe;
                uint _S1407 = _slang_select(_S1397, 3U,_S1406);
                float _S1408 = (fcptTrackMedium((_S1391), (_S1402), (_S1403), (_S1404), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1405), (_S1407), (_S1397)));
                wavelength_2 = _S1408;
            }
            else
            {
                wavelength_2 = _S1401;
            }
            bool _S1409 = !(wavelength_2 < ((&hit_4)->distance));
            if(_S1409)
            {
                _S1356 = int(1);
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
                float3  _S1410 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S1411 = sel_7->glow + _S1410;
                sel_7->glow = _S1411;
            }
            else
            {
            }
            glowed_0 = _S1357;
            uint b_14 = b_12 + 1U;
            float3  _S1412 = (&ray_2)->origin + make_float3 (wavelength_2) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1412;
            float3  _S1413 = flightWeight_0(scatter_in_0, extinction_in_0, spread_2, wavelength_2, true);
            float3  _S1414 = weight_1;
            float3  _S1415 = _slang_select(passes_0, _S1414,_S1413);
            float3  throughput_4 = throughput_2 * _S1415;
            uint _S1416 = stream(_S1385, b_14 + 320U);
            tracking_0 = _S1416;
            weight_1 = throughput_3;
            float width_5 = width_3 + threshold_2 * wavelength_2;
            float _S1417 = threshold_2 + 3.14159274101257324f;
            bool _S1418 = scatterSampled_0(replay_2, b_14, _S1373, passes_0);
            TreeSample _S1419 = TreeSample_x24init_0(_S1357, _S1357, 0.0f, 0U);
            if(_S1418)
            {
                float3  _S1420 = (&ray_2)->origin;
                float3  _S1421 = (&ray_2)->unit_direction;
                float3  _S1422 = (&ray_2)->unit_direction;
                uint _S1423 = stream(_S1385, b_14 + 64U);
                float3  _S1424 = extinction_in_0;
                float3  _S1425 = extinction_in_0;
                uint2  _S1426 = make_uint2 (_S1391);
                float3  _S1427 = (&ray_2)->unit_direction;
                uint _S1428 = arrivalLobe_0(b_14, (&prev_0)->lobe);
                FKHit _S1429 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1430 = _S1429;
                ShadowContext _S1431 = ShadowContext_x24init_0(_S1424, _S1425, _S1426, _S1427, b_14, _S1428, false, wavelength_2, width_5, &_S1430, false);
                ShadowContext _S1432 = _S1431;
                TreeSample _S1433 = sampleLightTree_0(_S1420, _S1421, _S1422, 0.0f, true, _S1423, &_S1432);
                light_3 = _S1433;
            }
            else
            {
                light_3 = _S1419;
            }
            float _S1434 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S1435 = (fcptMaxBounces());
            bool _S1436 = b_14 < _S1435;
            if(_S1436)
            {
                is_inside_5 = (light_3.density) > 0.0f;
            }
            else
            {
                is_inside_5 = false;
            }
            float _S1437 = _slang_select(is_inside_5, _S1434,0.0f);
            float3  _S1438 = throughput_4 * light_3.radiance;
            float _S1439 = powerHeuristic(light_3.density, _S1437);
            float3  _S1440 = _S1438 * make_float3 (_S1434 * _S1439);
            float3  _S1441 = _slang_select(_S1418, _S1440,_S1357);
            if(replay_2)
            {
                viewed_0 = b_14 == _S1373;
            }
            else
            {
                viewed_0 = false;
            }
            if(viewed_0)
            {
                bool _S1442 = _S1362 == 2U;
                if(_S1442)
                {
                    float _S1443 = resamplingTarget(_S1441);
                    passes_0 = _S1443 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1444 = Shift_x24init_0(_S1441, 1.0f);
                    _S1356 = int(0);
                    ended_0 = _S1444;
                    spread_2 = _S1417;
                    wavelength_2 = width_5;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_14;
                    break;
                }
                _S1356 = int(0);
                ended_0 = _S1358;
                spread_2 = _S1417;
                wavelength_2 = width_5;
                chain_throughput_0 = throughput_4;
                layer_0 = b_14;
                break;
            }
            bool _S1445 = !replay_2;
            if(_S1445)
            {
                Reservoir candidate_3 = _S1390;
                uint _S1446 = extractBits_0(_S1390.path, 10U, 2U);
                bool _S1447 = _S1446 == 1U;
                if(_S1447)
                {
                    float3  _S1448 = safeDivide(_S1441, _S1357);
                    (&candidate_3)->radiance = _S1448;
                }
                else
                {
                    uint _S1449 = insertBits_0(0U, b_14 + 1U, 5U, 5U);
                    uint _S1450 = insertBits_0(_S1449, 2U, 10U, 2U);
                    (&candidate_3)->path = _S1450;
                }
                Reservoir _S1451 = withEnd(candidate_3, 0U, b_14, _S1441);
                offer(sel_7, _S1451, _S1441 * make_float3 (scale_8) / make_float3 (density_2));
                float _S1452 = survivalProbability(abs_0(throughput_4), density_2);
                uint _S1453 = stream(_S1385, b_14 + 128U);
                Random _S1454 = pcg(_S1453);
                bool _S1455 = _S1452 < (_S1454.value);
                if(_S1455)
                {
                    scatter_2 = true;
                }
                else
                {
                    uint _S1456 = (fcptMaxBounces());
                    scatter_2 = b_14 >= _S1456;
                }
                if(scatter_2)
                {
                    _S1356 = int(0);
                    ended_0 = _S1358;
                    spread_2 = _S1417;
                    wavelength_2 = width_5;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_14;
                    break;
                }
                float _S1457 = density_2 * _S1452;
                density_2 = _S1457;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1458 = stream(_S1385, b_14);
            float3  _S1459 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1458, &phase_pdf_0);
            (&ray_2)->unit_direction = _S1459;
            NEEVertex _S1460 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S1357, (&ray_2)->origin);
            nee_vertex_0 = _S1460;
            Vertex _S1461 = scatteredVertex_0(false);
            prev_0 = _S1461;
            float _S1462 = (&prev_0)->pdf;
            FKRay _S1463 = ray_2;
            FKHit _S1464 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1465 = (fcptTraverseInstanceBVH((_S1463), (true), (4.294967296e+09f), (false), (_S1464), (false)));
            hit_4 = _S1465;
            b_12 = b_14;
            throughput_2 = throughput_4;
            threshold_2 = _S1417;
            width_3 = width_5;
            sky_pdf_0 = _S1462;
        }
        if(_S1356 != int(1))
        {
            width_3 = wavelength_2;
            throughput_2 = chain_throughput_0;
            b_12 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1358;
        spread_2 = threshold_2;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1466 = b_12 == 4294967295U;
    bool _S1467 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1467)
    {
        bool _S1468 = !(&nee_vertex_0)->none;
        float _S1469 = _slang_select(_S1468, sky_pdf_0,0.0f);
        float _S1470 = escapeWeight_0(_S1469, (&ray_2)->unit_direction);
        float3  _S1471 = environment_0((&ray_2)->unit_direction, b_12, (&prev_0)->lobe);
        float3  _S1472 = throughput_2 * _S1471;
        if(replay_2)
        {
            bool _S1473 = b_12 == _S1373;
            if(_S1473)
            {
                passes_0 = _S1362 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S1472 * make_float3 (_S1470) / make_float3 (r_8->jac), density_2 / r_8->jac);
            }
            if(_S1372)
            {
                passes_0 = _S1369;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_12 == _S1360;
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
                return Shift_x24init_0(_S1472 * make_float3 (_S1470), 1.0f);
            }
            return _S1358;
        }
        Reservoir candidate_4 = chain_0;
        uint _S1474 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1475 = _S1474 == 1U;
        if(_S1475)
        {
            uint _S1476 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S1477 = _S1476 == b_12;
            float _S1478 = _slang_select(_S1477, 1.0f,_S1470);
            float3  _S1479 = safeDivide(_S1472 * make_float3 (_S1478), _S1357);
            (&candidate_4)->radiance = _S1479;
        }
        else
        {
            bool _S1480 = (&prev_0)->rough;
            if(_S1480)
            {
                uint _S1481 = insertBits_0(0U, b_12 + 1U, 5U, 5U);
                uint _S1482 = insertBits_0(_S1481, 3U, 10U, 2U);
                uint _S1483 = insertBits_0(_S1482, (&prev_0)->lobe, 15U, 3U);
                bool _S1484 = (&prev_0)->inside;
                uint _S1485 = _slang_select(_S1484, 1U,0U);
                uint _S1486 = insertBits_0(_S1483, _S1485, 22U, 1U);
                (&candidate_4)->path = _S1486;
                (&candidate_4)->jac = (&prev_0)->pdf;
                (&candidate_4)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S1487 = _S1472 * make_float3 (_S1470);
        Reservoir _S1488 = withEnd(candidate_4, 3U, b_12, _S1487);
        offer(sel_7, _S1488, _S1487 * make_float3 (scale_8) / make_float3 (density_2));
        return _S1358;
    }
    float3  _S1489 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S1489;
    bool _S1490 = (fcptVaryingUsed());
    if(_S1490)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1491 = !replay_2;
        if(_S1491)
        {
            float3  _S1492 = throughput_2 * glowed_0 / make_float3 (density_2);
            float3  _S1493 = sel_7->glow + _S1492;
            sel_7->glow = _S1493;
        }
        float3  _S1494 = throughput_2 * weight_1;
        throughput_2 = _S1494;
    }
    else
    {
        float3  _S1495 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
        float3  _S1496 = throughput_2 * _S1495;
        throughput_2 = _S1496;
    }
    float _S1497 = width_3 + spread_2 * (&hit_4)->distance;
    uint _S1498 = b_12 + 1U;
    b_12 = _S1498;
    layer_0 = 0U;
    width_3 = _S1497;
    passes_0 = false;
    threshold_2 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    wavelength_2 = 0.0f;
    chain_throughput_0 = _S1357;
    float3  reconnection_0 = _S1357;
    viewed_0 = _S1466;
    for(;;)
    {
        bool _S1499 = ((&hit_4)->is_point_light) == 1U;
        FKMedium _S1500 = Medium_x24init_0(_S1357, _S1357, 0.0f);
        BSDFMaterial _S1501 = Material_x24init_0(_S1357, _S1357, 0.0f, 0.0f, 0.0f, 0.0f, _S1357, throughput_3, 1.0f, _S1357, _S1357, 0.5f, 0.0f, 0.0f, _S1357, 0.0f, _S1357, 0.0f);
        FKMedium _S1502 = _S1500;
        FKSurface _S1503 = Surface_x24init_0(_S1357, _S1357, 0.0f, &_S1501, false, 0U, 1.0f, false, &_S1502, 4294967295U, _S1357);
        bool _S1504 = !_S1499;
        bool is_inside_6;
        float geometry_density_2;
        float3  throughput_5;
        FKSurface surface_11;
        if(_S1504)
        {
            uint _S1505 = stream(_S1385, b_12);
            uint _S1506 = arrivalLobe_0(b_12, (&prev_0)->lobe);
            FKSurface _S1507 = (fcptSurfaceAtPath((hit_4), ((&ray_2)->origin), (_S1505), (width_3), (layer_0), (b_12), (_S1506), ((&ray_2)->unit_direction)));
            bool _S1508 = !passes_0;
            FKSurface _S1509 = _S1507;
            FKSurface _S1510 = emitting_0(&_S1509, _S1508);
            uint _S1511 = stream(_S1385, b_12 + 256U);
            Random _S1512 = pcg(_S1511);
            FKSurface _S1513 = _S1510;
            FKSurface _S1514 = uncovered_0(&_S1513, _S1512.value);
            float _S1515 = facingSign(_S1514.material.transmission, _S1514.geometry_n, (&ray_2)->unit_direction);
            bool _S1516 = _S1515 < 0.0f;
            bool _S1517 = (_S1514.material.transmission) > 0.0f;
            if(_S1517)
            {
                bool _S1518 = arrivesBehind_0((&ray_2)->unit_direction, _S1514.geometry_n);
                scatter_2 = _S1518;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1519 = _S1514;
            FKSurface _S1520 = facingRay_0(&_S1519, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S1521 = arrivesBehind_0((&ray_2)->unit_direction, _S1520.geometry_n);
                is_inside_6 = _S1521;
            }
            else
            {
                is_inside_6 = scatter_2;
            }
            if(is_inside_6)
            {
                float3  _S1522 = beerLambert((&hit_4)->distance, _S1520.material.absorption);
                float3  _S1523 = throughput_2 * _S1522;
                throughput_5 = _S1523;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S1524 = !_S1520.skip;
            float geometry_density_3 = geometryDensity(_S1520.geometry_n, (&ray_2)->unit_direction, (&hit_4)->distance);
            bool _S1525 = b_12 == _S1498;
            if(_S1525)
            {
                float _S1526 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S1526;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            float _S1527 = geometry_density_2;
            scatter_2 = _S1524;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S1527;
            surface_11 = _S1520;
            turned_1 = _S1516;
        }
        else
        {
            scatter_2 = false;
            geometry_density_2 = 0.0f;
            surface_11 = _S1503;
            throughput_5 = throughput_2;
            is_inside_6 = is_inside_5;
        }
        bool _S1528 = withinFootprint(scatter_2, (&prev_0)->rough, (&prev_0)->pdf, geometry_density_2, threshold_2);
        FKSurface _S1529 = surface_11;
        FKSurface _S1530 = surface_11;
        float _S1531 = dot_0(surface_11.smooth_n, - (&ray_2)->unit_direction);
        bool _S1532 = (fcptDispersionUsed());
        bool _S1533;
        if(_S1532)
        {
            _S1533 = wavelength_2 == 0.0f;
        }
        else
        {
            _S1533 = false;
        }
        bool _S1534;
        if(_S1533)
        {
            _S1534 = scatter_2;
        }
        else
        {
            _S1534 = false;
        }
        bool _S1535;
        if(_S1534)
        {
            bool _S1536 = dispersive(_S1529.material);
            _S1535 = _S1536;
        }
        else
        {
            _S1535 = false;
        }
        float3  throughput_6;
        if(_S1535)
        {
            uint _S1537 = stream(_S1385, 512U);
            Random _S1538 = pcg(_S1537);
            float2  _S1539 = sampleWavelength(_S1538.value);
            float _S1540 = _S1539.x;
            float3  _S1541 = wavelengthWeights(_S1540);
            float3  _S1542 = throughput_5 * (_S1541 / make_float3 (_S1539.y));
            wavelength_2 = _S1540;
            throughput_6 = _S1542;
        }
        else
        {
            throughput_6 = throughput_5;
        }
        BSDFMaterial refractive_0 = _S1529.material;
        float _S1543 = dispersedIor(_S1529.material.ior, _S1529.material.dispersion, wavelength_2);
        bool _S1544 = wavelength_2 > 0.0f;
        float _S1545 = _slang_select(_S1544, _S1543,_S1529.material.ior);
        (&refractive_0)->ior = _S1545;
        float2  _S1546 = vertexEta(refractive_0, _S1531);
        bool _S1547;
        if(scatter_2)
        {
            bool _S1548 = neeDecision(_S1529.material, _S1531, _S1546.x, _S1546.y);
            _S1547 = _S1548;
        }
        else
        {
            _S1547 = false;
        }
        bool _S1549;
        if(passes_0)
        {
            _S1549 = true;
        }
        else
        {
            _S1549 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1549)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1547;
        }
        bool _S1550 = (fcptHairUsed());
        bool _S1551;
        if(_S1550)
        {
            float3  _S1552 = surface_11.hair;
            _S1551 = (dot_0(_S1552, _S1552)) > 0.0f;
        }
        else
        {
            _S1551 = false;
        }
        bool _S1553;
        if(_S1551)
        {
            _S1553 = true;
        }
        else
        {
            BSDFMaterial _S1554 = _S1529.material;
            bool _S1555 = isTranslucent_0(&_S1554);
            _S1553 = _S1555;
        }
        bool _S1556;
        if(_S1553)
        {
            _S1556 = true;
        }
        else
        {
            bool _S1557 = (_S1529.material.transmission) > 0.0f;
            if(_S1557)
            {
                uint _S1558 = (fcptLayers((hit_4)));
                _S1556 = _S1558 == 1U;
            }
            else
            {
                _S1556 = false;
            }
        }
        float3  emission_0;
        if(_S1499)
        {
            float3  _S1559 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1559;
        }
        else
        {
            emission_0 = _S1529.material.emissive;
        }
        float _S1560 = rgb_to_greyscale(emission_0);
        bool _S1561 = _S1560 > 0.0f;
        float3  emission_1;
        if(_S1561)
        {
            NEEVertex _S1562 = nee_vertex_0;
            FKHit _S1563 = hit_4;
            float _S1564 = emissionWeight_0(&_S1562, &_S1563, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1564);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1565;
        if(replay_2)
        {
            _S1565 = _S1362 == 1U;
        }
        else
        {
            _S1565 = false;
        }
        bool _S1566;
        if(_S1565)
        {
            _S1566 = b_12 > _S1361;
        }
        else
        {
            _S1566 = false;
        }
        bool _S1567;
        if(_S1566)
        {
            _S1567 = b_12 == _S1360;
        }
        else
        {
            _S1567 = false;
        }
        bool _S1568;
        if(_S1567)
        {
            bool _S1569 = _S1363 == 1U;
            if(_S1569)
            {
                _S1568 = true;
            }
            else
            {
                _S1568 = _S1363 == 2U;
            }
        }
        else
        {
            _S1568 = false;
        }
        if(_S1568)
        {
            bool _S1570 = _S1499 != (_S1363 == 2U);
            if(_S1570)
            {
                return _S1358;
            }
            return Shift_x24init_0(throughput_6 * emission_1 / make_float3 (r_8->jac), density_2 / r_8->jac);
        }
        uint _S1571 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1572 = _S1571 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1573 = insertBits_0(0U, b_12, 5U, 5U);
        uint _S1574 = insertBits_0(_S1573, 1U, 10U, 2U);
        uint _S1575 = insertBits_0(_S1574, (&prev_0)->lobe, 15U, 3U);
        bool _S1576 = (&prev_0)->inside;
        uint _S1577 = _slang_select(_S1576, 1U,0U);
        uint _S1578 = insertBits_0(_S1575, _S1577, 22U, 1U);
        (&here_0)->path = _S1578;
        uint _S1579 = (&here_0)->path;
        uint _S1580 = _slang_select(_S1544, 1U,0U);
        uint _S1581 = insertBits_0(_S1579, _S1580, 23U, 1U);
        (&here_0)->path = _S1581;
        float _S1582 = (&prev_0)->pdf * geometry_density_2;
        (&here_0)->jac = _S1582;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1583;
        if(replay_2)
        {
            _S1583 = _S1362 == 1U;
        }
        else
        {
            _S1583 = false;
        }
        bool _S1584;
        if(_S1583)
        {
            _S1584 = b_12 == _S1361;
        }
        else
        {
            _S1584 = false;
        }
        bool _S1585 = b_12 == _S1373;
        bool _S1586;
        if(_S1585)
        {
            bool _S1587 = !scatter_2;
            if(_S1587)
            {
                _S1586 = true;
            }
            else
            {
                bool _S1588 = _S1362 != 1U;
                if(_S1588)
                {
                    _S1586 = _S1362 != 3U;
                }
                else
                {
                    _S1586 = false;
                }
            }
        }
        else
        {
            _S1586 = false;
        }
        bool _S1589;
        if(_S1586)
        {
            _S1589 = _S1362 == 2U;
        }
        else
        {
            _S1589 = false;
        }
        bool _S1590;
        if(_S1589)
        {
            _S1590 = !_S1528;
        }
        else
        {
            _S1590 = false;
        }
        bool _S1591;
        if(_S1590)
        {
            _S1591 = _S1363 != 4U;
        }
        else
        {
            _S1591 = false;
        }
        bool _S1592 = _S1361 == _S1360;
        bool _S1593;
        if(_S1592)
        {
            _S1593 = _S1363 == 0U;
        }
        else
        {
            _S1593 = false;
        }
        bool _S1594;
        if(_S1593)
        {
            _S1594 = ((&hit_4)->instance_index) == (_S1374.instance_index);
        }
        else
        {
            _S1594 = false;
        }
        bool _S1595;
        if(_S1594)
        {
            _S1595 = ((&hit_4)->triangle_index) == (_S1374.triangle_index);
        }
        else
        {
            _S1595 = false;
        }
        bool _S1596;
        if(_S1595)
        {
            _S1596 = _S1528;
        }
        else
        {
            _S1596 = false;
        }
        bool _S1597 = _slang_select(_S1584, _S1596,_S1591);
        bool _S1598;
        if(nee_0)
        {
            _S1598 = _slang_select(replay_2, _S1597,scatter_2);
        }
        else
        {
            _S1598 = false;
        }
        TreeSample _S1599 = TreeSample_x24init_0(_S1357, _S1357, 0.0f, 0U);
        uint2  _S1600 = make_uint2 (0U);
        float2  _S1601 = make_float2 (0.0f);
        FKHit _S1602 = Hit_x24init_0(_S1601, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1603 = _S1602;
        ShadowContext _S1604 = ShadowContext_x24init_0(_S1357, _S1357, _S1600, _S1357, 0U, 0U, false, 0.0f, 0.0f, &_S1603, false);
        ShadowContext context_5;
        if(nee_0)
        {
            uint _S1605 = arrivalLobe_0(b_12, (&prev_0)->lobe);
            FKMedium _S1606 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1607 = surface_11;
            FKHit _S1608 = hit_4;
            FKMedium _S1609 = _S1606;
            ShadowContext _S1610 = shadowContext_0(&_S1607, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_12, _S1605, (&hit_4)->distance, width_3, &_S1608, _S1551, &_S1609);
            context_5 = _S1610;
        }
        else
        {
            context_5 = _S1604;
        }
        float3  throughput_7;
        float3  lit_0;
        if(_S1598)
        {
            float3  _S1611 = (&ray_2)->origin;
            if(_S1551)
            {
                throughput_7 = _S1357;
            }
            else
            {
                throughput_7 = _S1530.smooth_n;
            }
            FKSurface _S1612 = surface_11;
            uint _S1613 = stream(_S1385, b_12 + 64U);
            ShadowContext _S1614 = context_5;
            TreeSample _S1615 = sampleLightTree_0(_S1611, throughput_7, surface_11.geometry_n, surface_11.geometry_offset, _S1556, _S1613, &_S1614);
            bool _S1616 = any_1((_S1615.radiance) != _S1357);
            if(_S1616)
            {
                if(_S1551)
                {
                    uint _S1617 = (fcptMaxBounces());
                    bool _S1618 = b_12 < _S1617;
                    FKSurface _S1619 = surface_11;
                    TreeSample _S1620 = _S1615;
                    float3  _S1621 = hairLight_0(&_S1619, (&ray_2)->unit_direction, &_S1620, _S1618);
                    lit_0 = _S1621;
                }
                else
                {
                    float _S1622 = _S1546.x;
                    float _S1623 = _S1546.y;
                    uint _S1624 = (fcptMaxBounces());
                    bool _S1625 = b_12 < _S1624;
                    TreeSample _S1626 = _S1615;
                    BSDFMaterial _S1627 = _S1529.material;
                    float3  _S1628 = lightBSDF_0((&ray_2)->unit_direction, &_S1626, _S1530.smooth_n, _S1612.geometry_n, &_S1627, _S1622, _S1623, _S1625, surface_11.random_state);
                    lit_0 = _S1628;
                }
            }
            else
            {
                lit_0 = _S1357;
            }
            light_3 = _S1615;
        }
        else
        {
            light_3 = _S1599;
            lit_0 = _S1357;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1629;
        bool _S1630;
        float density_3;
        if(_S1584)
        {
            bool _S1631 = ((&hit_4)->instance_index) != (_S1374.instance_index);
            if(_S1631)
            {
                viewed_1 = true;
            }
            else
            {
                viewed_1 = ((&hit_4)->triangle_index) != (_S1374.triangle_index);
            }
            if(viewed_1)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = !_S1528;
            }
            if(refracted_4)
            {
                return _S1358;
            }
            uint _S1632 = extractBits_0(_S1359, 23U, 1U);
            bool _S1633 = _S1544 != (_S1632 == 1U);
            if(_S1633)
            {
                return _S1358;
            }
            float3  throughput_8 = throughput_6 * make_float3 (geometry_density_2);
            float density_4 = density_2 * geometry_density_2;
            if(_S1592)
            {
                wrong_side_0 = _S1363 == 1U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                return Shift_x24init_0(throughput_8 * emission_1 / make_float3 (r_8->jac), density_4 / r_8->jac);
            }
            if(_S1592)
            {
                _S1629 = _S1363 == 0U;
            }
            else
            {
                _S1629 = false;
            }
            if(_S1629)
            {
                bool _S1634 = !nee_0;
                if(_S1634)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1635 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1635 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1358;
                }
                return Shift_x24init_0(throughput_8 * lit_0 / make_float3 (r_8->jac), density_4 / r_8->jac);
            }
            if(_S1592)
            {
                _S1630 = _S1363 == 4U;
            }
            else
            {
                _S1630 = false;
            }
            if(_S1630)
            {
                bool _S1636 = !nee_0;
                if(_S1636)
                {
                    return _S1358;
                }
                float _S1637 = environmentPdf_0(r_8->dir);
                float3  _S1638 = skyBSDF((&ray_2)->unit_direction, r_8->dir, surface_11, _S1546, is_inside_6, _S1637, surface_11.random_state);
                return Shift_x24init_0(throughput_8 * _S1638 * r_8->radiance / make_float3 (r_8->jac), density_4 / r_8->jac);
            }
            uint _S1639 = extractBits_0(_S1359, 21U, 1U);
            bool _S1640 = nee_0 != (_S1639 == 1U);
            if(_S1640)
            {
                return _S1358;
            }
            throughput_7 = throughput_8;
            density_3 = density_4;
        }
        else
        {
            if(replay_2)
            {
                viewed_1 = _S1585;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1641 = !scatter_2;
                if(_S1641)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1642 = _S1362 != 1U;
                    if(_S1642)
                    {
                        refracted_4 = _S1362 != 3U;
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
                bool _S1643 = _S1362 == 2U;
                if(_S1643)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1528;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1363 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1551)
                    {
                        return _S1358;
                    }
                    uint _S1644 = stream(_S1385, b_12 + 448U);
                    FKRay _S1645 = ray_2;
                    FKSurface _S1646 = surface_11;
                    ShadowContext _S1647 = context_5;
                    SkySample _S1648 = sampleSky_0(&_S1645, &_S1646, _S1546, is_inside_6, _S1644, surface_11.random_state, &_S1647);
                    return Shift_x24init_0(throughput_6 * _S1648.color, 1.0f);
                }
                if(_S1643)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1528;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1649 = rgb_to_greyscale(light_3.radiance);
                    bool _S1650 = !(_S1649 > 0.0f);
                    if(_S1650)
                    {
                        return _S1358;
                    }
                    return Shift_x24init_0(throughput_6 * lit_0, 1.0f);
                }
                if(_S1372)
                {
                    passes_0 = _S1363 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1499;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_6 * emission_1, 1.0f);
                }
                if(_S1372)
                {
                    passes_0 = _S1363 == 1U;
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
                    passes_0 = !_S1528;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_6 * emission_1, 1.0f);
                }
                return _S1358;
            }
            else
            {
                bool _S1651 = !replay_2;
                if(_S1651)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1652 = b_12 > 0U;
                    if(_S1652)
                    {
                        Reservoir candidate_5 = chain_0;
                        if(_S1572)
                        {
                            float3  _S1653 = safeDivide(throughput_6 * emission_1, chain_throughput_0);
                            (&candidate_5)->radiance = _S1653;
                        }
                        else
                        {
                            if(_S1528)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1654 = throughput_6 * emission_1;
                        Reservoir _S1655 = withEnd(candidate_5, 1U, b_12, _S1654);
                        offer(sel_7, _S1655, _S1654 * make_float3 (scale_8) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1656 = throughput_6 * emission_1;
                        float3  _S1657 = sel_7->glow + _S1656;
                        sel_7->glow = _S1657;
                    }
                    if(nee_0)
                    {
                        float3  _S1658 = throughput_6 * lit_0;
                        Reservoir candidate_6 = chain_0;
                        if(_S1572)
                        {
                            float3  _S1659 = safeDivide(_S1658, chain_throughput_0);
                            (&candidate_6)->radiance = _S1659;
                        }
                        else
                        {
                            if(_S1528)
                            {
                                candidate_6 = here_0;
                                uint _S1660 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1660;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1661 = insertBits_0(0U, b_12 + 1U, 5U, 5U);
                                uint _S1662 = insertBits_0(_S1661, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1662;
                            }
                        }
                        Reservoir _S1663 = withEnd(candidate_6, 0U, b_12, _S1658);
                        offer(sel_7, _S1663, _S1658 * make_float3 (scale_8) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1551)
                        {
                            _S1629 = false;
                        }
                        else
                        {
                            bool _S1664 = environmentMapped_0();
                            _S1629 = _S1664;
                        }
                    }
                    else
                    {
                        _S1629 = false;
                    }
                    if(_S1629)
                    {
                        uint _S1665 = (fcptMaxBounces());
                        _S1630 = b_12 < _S1665;
                    }
                    else
                    {
                        _S1630 = false;
                    }
                    if(_S1630)
                    {
                        uint _S1666 = stream(_S1385, b_12 + 448U);
                        FKRay _S1667 = ray_2;
                        FKSurface _S1668 = surface_11;
                        ShadowContext _S1669 = context_5;
                        SkySample _S1670 = sampleSky_0(&_S1667, &_S1668, _S1546, is_inside_6, _S1666, surface_11.random_state, &_S1669);
                        float3  _S1671 = throughput_6 * _S1670.color;
                        Reservoir candidate_7 = chain_0;
                        if(_S1572)
                        {
                            float3  _S1672 = safeDivide(_S1671, chain_throughput_0);
                            (&candidate_7)->radiance = _S1672;
                        }
                        else
                        {
                            if(_S1528)
                            {
                                candidate_7 = here_0;
                                uint _S1673 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1673;
                                (&candidate_7)->dir = _S1670.dir;
                                (&candidate_7)->radiance = _S1670.radiance;
                            }
                            else
                            {
                                uint _S1674 = insertBits_0(0U, b_12 + 1U, 5U, 5U);
                                uint _S1675 = insertBits_0(_S1674, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1675;
                            }
                        }
                        Reservoir _S1676 = withEnd(candidate_7, 4U, b_12, _S1671);
                        offer(sel_7, _S1676, _S1671 * make_float3 (scale_8) / make_float3 (density_2));
                    }
                }
            }
            throughput_7 = throughput_6;
            density_3 = density_2;
        }
        bool _S1677;
        bool _S1678;
        bool _S1679;
        bool straight_0;
        bool _S1680;
        bool _S1681;
        bool _S1682;
        bool _S1683;
        bool _S1684;
        bool _S1685;
        bool _S1686;
        bool _S1687;
        bool _S1688;
        bool _S1689;
        bool _S1690;
        bool _S1691;
        float density_5;
        float sky_pdf_2;
        float spread_4;
        float density_6;
        float toon_b_5;
        float density_7;
        float spread_5;
        float width_6;
        uint b_15;
        float3  throughput_9;
        float3  throughput_10;
        float3  throughput_11;
        if(scatter_2)
        {
            MaterialTerms _S1692 = MaterialTerms_x24init_0(0.0f, 0.0f, 0.0f, 0.0f, 0.0f, _S1357, 0.0f, 0.0f, 0.0f, false, 0.0f);
            AnisotropicFrame _S1693 = AnisotropicFrame_x24init_0(_S1357, _S1601);
            ViewTerms _S1694 = ViewTerms_x24init_0(_S1357, _S1357, &_S1693, _S1357, 0.0f, _S1357, _S1357, _S1357, 0.0f, _S1357);
            bool _S1695 = !_S1551;
            float3  reconnection_1;
            float3  chain_throughput_1;
            MaterialTerms terms_6;
            ViewTerms view_terms_6;
            if(_S1695)
            {
                float _S1696 = _S1546.x;
                float _S1697 = _S1546.y;
                float _S1698 = (F32_min(((F32_sqrt((_S1529.material.specular_level))) * (F32_abs((_S1696 - _S1697))) / (_S1696 + _S1697)), (0.9999847412109375f)));
                float _S1699 = _S1698 * _S1698;
                float _S1700 = (1.0f + _S1698) / (1.0f - _S1698);
                float _S1701 = _S1529.material.toon.x;
                bool _S1702 = _S1701 < 0.0f;
                float _S1703 = (F32_abs((_S1701)));
                bool _S1704 = _S1703 > 0.0f;
                if(_S1704)
                {
                    float _S1705 = (F32_min((_S1703), (1.0f)));
                    float _S1706 = 1.0f - _S1705;
                    float _S1707 = rgb_to_greyscale(_S1529.material.albedo);
                    float _S1708 = _S1705 * _S1707;
                    float3  _S1709 = make_float3 (_S1705) * _S1529.material.albedo;
                    float toon_a_8 = clamp_1(_S1529.material.toon.y / _S1701, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
                    float toon_s_8 = clamp_1(_S1529.material.toon.z / _S1701, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
                    float _S1710 = (F32_min((toon_a_8 + toon_s_8), (1.57079637050628662f)));
                    if(_S1702)
                    {
                        density_5 = 1.0f - (F32_cos(((F32_min((_S1710), (toon_a_8))))));
                    }
                    else
                    {
                        float _S1711 = (F32_sin(((F32_min((_S1710), (toon_a_8))))));
                        density_5 = _S1711 * _S1711 / 2.0f;
                    }
                    bool _S1712 = _S1710 > toon_a_8;
                    if(_S1712)
                    {
                        viewed_1 = toon_s_8 > 0.0f;
                    }
                    else
                    {
                        viewed_1 = false;
                    }
                    if(viewed_1)
                    {
                        if(_S1702)
                        {
                            float _S1713 = (F32_cos((toon_a_8)));
                            float _S1714 = (F32_cos((_S1710)));
                            sky_pdf_2 = (1.0f + toon_a_8 / toon_s_8) * (_S1713 - _S1714) - ((F32_sin((_S1710))) - _S1710 * _S1714 - ((F32_sin((toon_a_8))) - toon_a_8 * _S1713)) / toon_s_8;
                        }
                        else
                        {
                            float _S1715 = 2.0f * toon_a_8;
                            float _S1716 = (F32_cos((_S1715)));
                            float _S1717 = 2.0f * _S1710;
                            float _S1718 = (F32_cos((_S1717)));
                            sky_pdf_2 = (1.0f + toon_a_8 / toon_s_8) * (_S1716 - _S1718) / 4.0f - ((F32_sin((_S1717))) / 8.0f - _S1710 * _S1718 / 4.0f - ((F32_sin((_S1715))) / 8.0f - toon_a_8 * _S1716 / 4.0f)) / toon_s_8;
                        }
                        float integral_6 = density_5 + sky_pdf_2;
                        sky_pdf_2 = integral_6;
                    }
                    else
                    {
                        sky_pdf_2 = density_5;
                    }
                    float _S1719 = 6.28318548202514648f * sky_pdf_2;
                    density_5 = _S1706;
                    sky_pdf_2 = _S1708;
                    throughput_9 = _S1709;
                    spread_4 = toon_a_8;
                    density_6 = toon_s_8;
                    toon_b_5 = _S1710;
                    density_7 = _S1719;
                }
                else
                {
                    density_5 = 1.0f;
                    sky_pdf_2 = 0.0f;
                    throughput_9 = _S1357;
                    spread_4 = 0.0f;
                    density_6 = 0.0f;
                    toon_b_5 = 0.0f;
                    density_7 = 1.0f;
                }
                float _S1720 = translucentShare(_S1529.material);
                MaterialTerms _S1721 = MaterialTerms_x24init_0(_S1699, _S1700, _S1720, density_5, sky_pdf_2, throughput_9, spread_4, density_6, toon_b_5, _S1702, density_7);
                float3  _S1722 = (&ray_2)->unit_direction;
                float3  _S1723 = negate_0(_S1722);
                float _S1724 = sign_0(dot_0(_S1530.smooth_n, _S1723));
                float3  _S1725 = _S1530.smooth_n * make_float3 (_S1724);
                AnisotropicFrame _S1726 = anisotropicFrame(_S1529.material, _S1725);
                float _S1727 = rgb_to_greyscale(_S1529.material.sheen);
                bool _S1728 = _S1727 > 0.0f;
                if(_S1728)
                {
                    float _S1729 = clamp_1((F32_sqrt(((F32_max((dot_0(_S1725, _S1723)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
                    uint _S1730 = (U32_min((uint(_S1729)), (22U)));
                    float least_3 = (F32_sqrt((0.05000000074505806f)));
                    float _S1731 = (F32_sqrt((0.10000000149011612f)));
                    bool _S1732 = (_S1529.material.velvet) > 0.0f;
                    float _S1733 = _slang_select(_S1732, _S1731,least_3);
                    float _S1734 = (clamp_1((F32_sqrt(((F32_max((_S1529.material.sheen_roughness), (0.0f)))))), _S1733, 1.0f) - _S1733) / (1.0f - _S1733) * 23.0f;
                    uint _S1735 = (U32_min((uint(_S1734)), (22U)));
                    uint _S1736 = _S1730 * 24U + _S1735;
                    float _S1737 = _S1729 - float(_S1730);
                    float _S1738 = _S1734 - float(_S1735);
                    uint _S1739 = _S1736 + 24U;
                    float a_14 = SHEEN_ALBEDO_0[_S1736] + (SHEEN_ALBEDO_0[_S1739] - SHEEN_ALBEDO_0[_S1736]) * _S1737;
                    uint _S1740 = _S1736 + 1U;
                    uint _S1741 = _S1739 + 1U;
                    float b_16 = SHEEN_ALBEDO_0[_S1740] + (SHEEN_ALBEDO_0[_S1741] - SHEEN_ALBEDO_0[_S1740]) * _S1737;
                    float _S1742 = (F32_exp((a_14 + (b_16 - a_14) * _S1738)));
                    if(_S1732)
                    {
                        float a_15 = VELVET_ALBEDO_0[_S1736] + (VELVET_ALBEDO_0[_S1739] - VELVET_ALBEDO_0[_S1736]) * _S1737;
                        float b_17 = VELVET_ALBEDO_0[_S1740] + (VELVET_ALBEDO_0[_S1741] - VELVET_ALBEDO_0[_S1740]) * _S1737;
                        float _S1743 = a_15 + (b_17 - a_15) * _S1738;
                        spread_5 = _S1743;
                    }
                    else
                    {
                        spread_5 = _S1742;
                    }
                    float _S1744 = (F32_min((spread_5), (1.0f)));
                    float3  _S1745 = make_float3 (1.0f) - _S1529.material.sheen * make_float3 (_S1744);
                    float _S1746 = rgb_to_greyscale(_S1529.material.sheen);
                    float _S1747 = _S1746 * _S1744;
                    float3  _S1748 = _S1529.material.sheen / make_float3 ((F32_max((spread_5), (1.0f))));
                    reconnection_1 = _S1745;
                    spread_5 = _S1747;
                    throughput_10 = _S1748;
                    throughput_11 = _S1723;
                }
                else
                {
                    reconnection_1 = throughput_3;
                    spread_5 = 0.0f;
                    throughput_10 = _S1357;
                    throughput_11 = _S1357;
                }
                float3  scale_9 = reconnection_1 * make_float3 (_S1721.toon_scale);
                if(_S1704)
                {
                    float _S1749 = dot_0(_S1725, _S1723);
                    float _S1750 = (F32_acos(((F32_min((_S1749), (1.0f))))));
                    if(_S1750 < (_S1721.toon_a))
                    {
                        width_6 = 1.0f;
                    }
                    else
                    {
                        width_6 = (F32_max((1.0f - (_S1750 - _S1721.toon_a) / (F32_max((_S1721.toon_s), (0.0000152587890625f)))), (0.0f)));
                    }
                    if(_S1721.toon_glossy)
                    {
                        float3  _S1751 = make_float3 (2.0f * _S1749) * _S1725 - _S1723;
                        float3  _S1752 = ((((_S1751)) * make_float3(rnorm3df(((_S1751)).x, ((_S1751)).y, ((_S1751)).z))));
                        chain_throughput_1 = _S1752;
                    }
                    else
                    {
                        chain_throughput_1 = _S1725;
                    }
                }
                else
                {
                    width_6 = 0.0f;
                    chain_throughput_1 = _S1725;
                }
                float _S1753 = _S1726.alphas.x;
                float _S1754 = (F32_sqrt(((F32_min((_S1753), (_S1726.alphas.y))))));
                bool _S1755 = _S1753 > 0.0f;
                float _S1756 = _slang_select(_S1755, _S1754,_S1529.material.roughness);
                float _S1757 = _S1756 * _S1756;
                float _S1758 = (F32_pow((_S1757), (1.81585001945495605f))) * (2.15371990203857422f - 0.73285001516342163f * _S1757) / (1.0f + 1.28094995021820068f * _S1757);
                bool _S1759 = _S1757 > 0.0f;
                float _S1760 = _slang_select(_S1759, _S1758,0.0f);
                float _S1761 = clamp_1(dot_0(_S1725, _S1723), 0.0f, 1.0f);
                float _S1762 = _S1757 * _S1756;
                float _S1763 = (F32_min((1.00064504146575928f - _S1756 * (0.00375499995425344f + _S1761 * (-0.04133399948477745f + _S1761 * (-0.90938502550125122f + _S1761 * 0.35275399684906006f))) - _S1757 * (0.27602800726890564f + _S1761 * (1.27023398876190186f + _S1761 * 0.04740000143647194f)) - _S1762 * (0.31452900171279907f - _S1761 * 0.34830701351165771f) + _S1762 * _S1756 * 0.27229699492454529f), (1.0f)));
                float3  _S1764 = min_1(make_float3 (1.0f) / (make_float3 (1.0f) - _S1529.material.albedo * make_float3 (_S1760)), make_float3 (1.0f / (F32_max((_S1763), (0.0000152587890625f)))));
                AnisotropicFrame _S1765 = _S1726;
                ViewTerms _S1766 = ViewTerms_x24init_0(_S1723, _S1725, &_S1765, scale_9, spread_5, throughput_10, throughput_11, _S1764, width_6, chain_throughput_1);
                terms_6 = _S1721;
                view_terms_6 = _S1766;
            }
            else
            {
                terms_6 = _S1692;
                view_terms_6 = _S1694;
            }
            if(replay_2)
            {
                viewed_1 = _S1585;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1767 = extractBits_0(_S1359, 15U, 3U);
            uint _S1768 = extractBits_0(_S1359, 18U, 3U);
            uint _S1769 = _slang_select(_S1584, _S1768,_S1767);
            float3  _S1770 = r_8->dir;
            bool refracted_5 = _S1769 == 1U;
            SampleBSDF _S1771 = SampleBSDF_x24init_0(_S1357, _S1357, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_8 = _S1771;
            SampleBSDF _S1772;
            if(viewed_1)
            {
                uint _S1773 = extractBits_0(_S1359, 22U, 1U);
                bool _S1774 = is_inside_6 != (_S1773 == 1U);
                if(_S1774)
                {
                    return _S1358;
                }
                bool _S1775 = _S1362 == 1U;
                if(_S1775)
                {
                    float3  _S1776 = (fcptHitPosition((_S1374)));
                    throughput_9 = _S1776;
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
                    BSDFMaterial _S1777 = _S1529.material;
                    bool _S1778 = isTranslucent_0(&_S1777);
                    if(_S1778)
                    {
                        refracted_4 = _S1769 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1779 = throughput_9 - (&ray_2)->origin;
                        float3  _S1780 = _slang_select(_S1775, _S1779,_S1770);
                        wrong_side_0 = (dot_0(_S1530.smooth_n, _S1780) * _S1531) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1775)
                {
                    float3  _S1781 = (&ray_2)->origin;
                    FKSurface _S1782 = surface_11;
                    float3  _S1783 = - _S1530.smooth_n;
                    bool _S1784 = is_inside_6 != refracted_4;
                    float3  _S1785 = _slang_select(_S1784, _S1783,_S1530.smooth_n);
                    float3  _S1786 = throughput_9 - (_S1781 + make_float3 (_S1782.geometry_offset) * _S1785);
                    float3  _S1787 = ((((_S1786)) * make_float3(rnorm3df(((_S1786)).x, ((_S1786)).y, ((_S1786)).z))));
                    reconnection_1 = _S1787;
                }
                else
                {
                    reconnection_1 = _S1770;
                }
                if(_S1551)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1788 = wrongSide_0(is_inside_6, refracted_4, reconnection_1, surface_11.geometry_n);
                    wrong_side_0 = _S1788;
                }
                if(wrong_side_0)
                {
                    return _S1358;
                }
                float3  _S1789 = throughput_9;
                throughput_9 = reconnection_1;
                b_15 = _S1769;
                wrong_side_0 = false;
                reconnection_1 = _S1789;
            }
            else
            {
                bool _S1790 = !_S1584;
                if(_S1790)
                {
                    SampleBSDF bsdf_sampled_0;
                    if(_S1551)
                    {
                        SampleBSDF _S1791 = (fcptSampleHair((surface_11.hair), (_S1529.material.albedo), (_S1529.material.specular_tint), ((&ray_2)->unit_direction), (surface_11.random_state)));
                        _S1772 = _S1791;
                    }
                    else
                    {
                        SampleBSDF _S1792 = sampleBSDF((&ray_2)->unit_direction, _S1530.smooth_n, _S1529.material, _S1546.x, _S1546.y, surface_11.random_state, _S1601, terms_6, view_terms_6);
                        _S1772 = _S1792;
                    }
                    bsdf_sampled_0 = _S1772;
                    if(_S1551)
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
                            return _S1358;
                        }
                        break;
                    }
                    if(_S1551)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1793 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_11.geometry_n);
                        wrong_side_0 = _S1793;
                    }
                    if(wrong_side_0)
                    {
                        _S1629 = (_S1529.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1629 = false;
                    }
                    if(_S1629)
                    {
                        float3  _S1794 = (&bsdf_sampled_0)->unit_direction;
                        FKSurface _S1795 = surface_11;
                        float _S1796 = _S1546.x;
                        float _S1797 = _S1546.y;
                        uint _S1798 = (&bsdf_sampled_0)->random_state;
                        float3  _S1799 = (&bsdf_sampled_0)->unit_direction;
                        float3  _S1800 = negate_0(_S1799);
                        float _S1801 = sign_0(dot_0(_S1795.geometry_n, _S1800));
                        float3  _S1802 = _S1795.geometry_n * make_float3 (_S1801);
                        AnisotropicFrame _S1803 = anisotropicFrame(_S1529.material, _S1802);
                        float _S1804 = rgb_to_greyscale(_S1529.material.sheen);
                        bool _S1805 = _S1804 > 0.0f;
                        if(_S1805)
                        {
                            float _S1806 = clamp_1((F32_sqrt(((F32_max((dot_0(_S1802, _S1800)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
                            uint _S1807 = (U32_min((uint(_S1806)), (22U)));
                            float least_4 = (F32_sqrt((0.05000000074505806f)));
                            float _S1808 = (F32_sqrt((0.10000000149011612f)));
                            bool _S1809 = (_S1529.material.velvet) > 0.0f;
                            float _S1810 = _slang_select(_S1809, _S1808,least_4);
                            float _S1811 = (clamp_1((F32_sqrt(((F32_max((_S1529.material.sheen_roughness), (0.0f)))))), _S1810, 1.0f) - _S1810) / (1.0f - _S1810) * 23.0f;
                            uint _S1812 = (U32_min((uint(_S1811)), (22U)));
                            uint _S1813 = _S1807 * 24U + _S1812;
                            float _S1814 = _S1806 - float(_S1807);
                            float _S1815 = _S1811 - float(_S1812);
                            uint _S1816 = _S1813 + 24U;
                            float a_16 = SHEEN_ALBEDO_0[_S1813] + (SHEEN_ALBEDO_0[_S1816] - SHEEN_ALBEDO_0[_S1813]) * _S1814;
                            uint _S1817 = _S1813 + 1U;
                            uint _S1818 = _S1816 + 1U;
                            float b_18 = SHEEN_ALBEDO_0[_S1817] + (SHEEN_ALBEDO_0[_S1818] - SHEEN_ALBEDO_0[_S1817]) * _S1814;
                            float _S1819 = (F32_exp((a_16 + (b_18 - a_16) * _S1815)));
                            if(_S1809)
                            {
                                float a_17 = VELVET_ALBEDO_0[_S1813] + (VELVET_ALBEDO_0[_S1816] - VELVET_ALBEDO_0[_S1813]) * _S1814;
                                float b_19 = VELVET_ALBEDO_0[_S1817] + (VELVET_ALBEDO_0[_S1818] - VELVET_ALBEDO_0[_S1817]) * _S1814;
                                float _S1820 = a_17 + (b_19 - a_17) * _S1815;
                                spread_5 = _S1820;
                            }
                            else
                            {
                                spread_5 = _S1819;
                            }
                            float _S1821 = (F32_min((spread_5), (1.0f)));
                            float3  _S1822 = make_float3 (1.0f) - _S1529.material.sheen * make_float3 (_S1821);
                            float _S1823 = rgb_to_greyscale(_S1529.material.sheen);
                            float _S1824 = _S1823 * _S1821;
                            float3  _S1825 = _S1529.material.sheen / make_float3 ((F32_max((spread_5), (1.0f))));
                            reconnection_1 = _S1822;
                            spread_5 = _S1824;
                            throughput_10 = _S1825;
                            throughput_11 = _S1800;
                        }
                        else
                        {
                            reconnection_1 = throughput_3;
                            spread_5 = 0.0f;
                            throughput_10 = _S1357;
                            throughput_11 = _S1357;
                        }
                        float3  scale_10 = reconnection_1 * make_float3 (terms_6.toon_scale);
                        bool _S1826 = (F32_abs((_S1529.material.toon.x))) > 0.0f;
                        if(_S1826)
                        {
                            float _S1827 = dot_0(_S1802, _S1800);
                            float _S1828 = (F32_acos(((F32_min((_S1827), (1.0f))))));
                            MaterialTerms _S1829 = terms_6;
                            if(_S1828 < (terms_6.toon_a))
                            {
                                density_5 = 1.0f;
                            }
                            else
                            {
                                density_5 = (F32_max((1.0f - (_S1828 - _S1829.toon_a) / (F32_max((terms_6.toon_s), (0.0000152587890625f)))), (0.0f)));
                            }
                            if(terms_6.toon_glossy)
                            {
                                float3  _S1830 = make_float3 (2.0f * _S1827) * _S1802 - _S1800;
                                float3  _S1831 = ((((_S1830)) * make_float3(rnorm3df(((_S1830)).x, ((_S1830)).y, ((_S1830)).z))));
                                throughput_9 = _S1831;
                            }
                            else
                            {
                                throughput_9 = _S1802;
                            }
                            width_6 = density_5;
                            chain_throughput_1 = throughput_9;
                        }
                        else
                        {
                            width_6 = 0.0f;
                            chain_throughput_1 = _S1802;
                        }
                        float _S1832 = _S1803.alphas.x;
                        float _S1833 = (F32_sqrt(((F32_min((_S1832), (_S1803.alphas.y))))));
                        bool _S1834 = _S1832 > 0.0f;
                        float _S1835 = _slang_select(_S1834, _S1833,_S1529.material.roughness);
                        float _S1836 = _S1835 * _S1835;
                        float _S1837 = (F32_pow((_S1836), (1.81585001945495605f))) * (2.15371990203857422f - 0.73285001516342163f * _S1836) / (1.0f + 1.28094995021820068f * _S1836);
                        bool _S1838 = _S1836 > 0.0f;
                        float _S1839 = _slang_select(_S1838, _S1837,0.0f);
                        float _S1840 = clamp_1(dot_0(_S1802, _S1800), 0.0f, 1.0f);
                        float _S1841 = _S1836 * _S1835;
                        float _S1842 = (F32_min((1.00064504146575928f - _S1835 * (0.00375499995425344f + _S1840 * (-0.04133399948477745f + _S1840 * (-0.90938502550125122f + _S1840 * 0.35275399684906006f))) - _S1836 * (0.27602800726890564f + _S1840 * (1.27023398876190186f + _S1840 * 0.04740000143647194f)) - _S1841 * (0.31452900171279907f - _S1840 * 0.34830701351165771f) + _S1841 * _S1835 * 0.27229699492454529f), (1.0f)));
                        float3  _S1843 = min_1(make_float3 (1.0f) / (make_float3 (1.0f) - _S1529.material.albedo * make_float3 (_S1839)), make_float3 (1.0f / (F32_max((_S1842), (0.0000152587890625f)))));
                        AnisotropicFrame _S1844 = _S1803;
                        ViewTerms _S1845 = ViewTerms_x24init_0(_S1800, _S1802, &_S1844, scale_10, spread_5, throughput_10, throughput_11, _S1843, width_6, chain_throughput_1);
                        SampleBSDF _S1846 = sampleBSDF(_S1794, _S1795.geometry_n, _S1529.material, _S1796, _S1797, _S1798, _S1601, terms_6, _S1845);
                        (&bsdf_sampled_0)->unit_direction = _S1846.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1846.refracted;
                        (&bsdf_sampled_0)->throughput = _S1846.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1847 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_11.geometry_n)) * surface_11.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1847;
                        }
                    }
                    uint _S1848 = (&bsdf_sampled_0)->lobe;
                    float3  _S1849 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1850 = (&bsdf_sampled_0)->refracted;
                    lobe_8 = bsdf_sampled_0;
                    float _S1851 = (&bsdf_sampled_0)->pdf;
                    float _S1852 = _slang_select(wrong_side_0, 0.0f,_S1851);
                    (&lobe_8)->pdf = _S1852;
                    throughput_9 = _S1849;
                    b_15 = _S1848;
                    refracted_4 = _S1850;
                }
                else
                {
                    throughput_9 = _S1770;
                    b_15 = _S1769;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1629 = true;
            }
            else
            {
                _S1629 = _S1584;
            }
            if(_S1629)
            {
                if(_S1551)
                {
                    SampleBSDF _S1853 = (fcptConnectHair((surface_11.hair), (_S1529.material.albedo), (_S1529.material.specular_tint), ((&ray_2)->unit_direction), (throughput_9)));
                    _S1772 = _S1853;
                }
                else
                {
                    SampleBSDF _S1854 = lobeBSDF((&ray_2)->unit_direction, throughput_9, _S1530.smooth_n, _S1529.material, _S1546.x, _S1546.y, b_15, surface_11.random_state, terms_6, view_terms_6);
                    _S1772 = _S1854;
                }
                lobe_8 = _S1772;
            }
            bool _S1855 = b_15 == 0U;
            if(_S1855)
            {
                _S1630 = true;
            }
            else
            {
                _S1630 = b_15 == 4U;
            }
            if(_S1630)
            {
                _S1677 = true;
            }
            else
            {
                _S1677 = b_15 == 6U;
            }
            if(_S1551)
            {
                _S1678 = false;
            }
            else
            {
                bool _S1856 = !_S1677;
                if(_S1856)
                {
                    bool _S1857 = (_S1529.material.roughness) == 0.0f;
                    if(_S1857)
                    {
                        _S1678 = true;
                    }
                    else
                    {
                        bool _S1858 = b_15 == 1U;
                        if(_S1858)
                        {
                            _S1678 = (_S1546.x) == (_S1546.y);
                        }
                        else
                        {
                            _S1678 = false;
                        }
                    }
                }
                else
                {
                    _S1678 = false;
                }
            }
            if(_S1695)
            {
                _S1679 = b_15 == 1U;
            }
            else
            {
                _S1679 = false;
            }
            if(_S1679)
            {
                straight_0 = (_S1529.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1680 = _S1695;
            }
            else
            {
                _S1680 = false;
            }
            if(_S1680)
            {
                _S1681 = b_15 == 1U;
            }
            else
            {
                _S1681 = false;
            }
            if(_S1681)
            {
                _S1682 = (_S1546.x) == (_S1546.y);
            }
            else
            {
                _S1682 = false;
            }
            BSDFMaterial _S1859 = _S1529.material;
            bool _S1860 = isTranslucent_0(&_S1859);
            if(_S1860)
            {
                _S1683 = _S1855;
            }
            else
            {
                _S1683 = false;
            }
            if(_S1683)
            {
                _S1684 = (dot_0(throughput_9, surface_11.geometry_n)) < 0.0f;
            }
            else
            {
                _S1684 = false;
            }
            if(nee_0)
            {
                _S1685 = !_S1678;
            }
            else
            {
                _S1685 = false;
            }
            if(_S1685)
            {
                _S1686 = !wrong_side_0;
            }
            else
            {
                _S1686 = false;
            }
            if(_S1686)
            {
                float _S1861 = (&lobe_8)->pdf;
                float3  _S1862 = (&ray_2)->origin;
                float3  _S1863 = _slang_select(_S1556, _S1357,_S1530.smooth_n);
                float3  _S1864 = (&ray_2)->origin;
                FKSurface _S1865 = surface_11;
                float3  _S1866 = - _S1530.smooth_n;
                float3  _S1867 = _slang_select(_S1684, _S1866,_S1530.smooth_n);
                NEEVertex _S1868 = NEEVertex_x24init_0(false, _S1861, _S1862, _S1863, _S1864 + make_float3 (_S1865.geometry_offset) * _S1867);
                nee_vertex_0 = _S1868;
            }
            else
            {
                if(_S1551)
                {
                    _S1687 = true;
                }
                else
                {
                    bool _S1869 = b_15 != 1U;
                    if(_S1869)
                    {
                        _S1687 = true;
                    }
                    else
                    {
                        _S1687 = (_S1546.x) != (_S1546.y);
                    }
                }
                if(_S1687)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1870 = withinInverseFootprint((&lobe_8)->pdf, _S1677, (&prev_0)->cos, (&hit_4)->distance, threshold_2);
            bool _S1871 = roughLobe((&lobe_8)->pdf, _S1677, _S1529.material.roughness);
            if(_S1584)
            {
                bool _S1872 = !_S1870;
                if(_S1872)
                {
                    return _S1358;
                }
                bool _S1873 = _S1363 != 1U;
                if(_S1873)
                {
                    _S1687 = _S1363 != 2U;
                }
                else
                {
                    _S1687 = false;
                }
                if(_S1687)
                {
                    float _S1874 = (&lobe_8)->pdf;
                    float _S1875 = _slang_select(nee_0, _S1874,0.0f);
                    float _S1876 = escapeWeight_0(_S1875, _S1770);
                    if(_S1592)
                    {
                        passes_0 = _S1369;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1877 = _slang_select(passes_0, _S1876,1.0f);
                    return Shift_x24init_0(throughput_7 * ((&lobe_8)->throughput * make_float3 ((&lobe_8)->pdf)) * r_8->radiance * make_float3 (_S1877) / make_float3 (r_8->jac), density_3 * (&lobe_8)->pdf / r_8->jac);
                }
                float3  _S1878 = throughput_7 * make_float3 ((&lobe_8)->pdf);
                float _S1879 = density_3 * (&lobe_8)->pdf;
                throughput_10 = _S1878;
                density_5 = _S1879;
            }
            else
            {
                throughput_10 = throughput_7;
                density_5 = density_3;
            }
            uint _S1880 = (fcptLayers((hit_4)));
            bool _S1881 = b_15 == 1U;
            bool _S1882 = passesLayer_0(_S1880, _S1881, passes_0);
            if(viewed_1)
            {
                _S1687 = _S1882;
            }
            else
            {
                _S1687 = false;
            }
            if(_S1687)
            {
                return _S1358;
            }
            if(replay_2)
            {
                _S1688 = b_12 <= _S1373;
            }
            else
            {
                _S1688 = false;
            }
            if(_S1688)
            {
                _S1689 = _S1528;
            }
            else
            {
                _S1689 = false;
            }
            if(_S1689)
            {
                _S1690 = _S1870;
            }
            else
            {
                _S1690 = false;
            }
            if(_S1690)
            {
                _S1691 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1691 = !_S1871;
                }
                else
                {
                    _S1691 = false;
                }
            }
            if(_S1691)
            {
                return _S1358;
            }
            if(viewed_1)
            {
                float3  _S1883 = throughput_10 * ((&lobe_8)->throughput * make_float3 ((&lobe_8)->pdf));
                float _S1884 = (&lobe_8)->pdf;
                throughput_11 = _S1883;
                sky_pdf_2 = _S1884;
            }
            else
            {
                float3  _S1885 = throughput_10 * max_0((&lobe_8)->throughput, _S1357);
                throughput_11 = _S1885;
                sky_pdf_2 = density_5;
            }
            bool _S1886 = !replay_2;
            bool _S1887;
            if(_S1886)
            {
                _S1887 = !_S1572;
            }
            else
            {
                _S1887 = false;
            }
            bool _S1888;
            if(_S1887)
            {
                _S1888 = _S1528;
            }
            else
            {
                _S1888 = false;
            }
            bool _S1889;
            if(_S1888)
            {
                _S1889 = _S1870;
            }
            else
            {
                _S1889 = false;
            }
            if(_S1889)
            {
                chain_0 = here_0;
                uint _S1890 = insertBits_0((&chain_0)->path, b_15, 18U, 3U);
                uint _S1891 = _slang_select(nee_0, 1U,0U);
                uint _S1892 = insertBits_0(_S1890, _S1891, 21U, 1U);
                (&chain_0)->path = _S1892;
                float _S1893 = (&chain_0)->jac * (&lobe_8)->pdf;
                (&chain_0)->jac = _S1893;
                (&chain_0)->dir = throughput_9;
                chain_throughput_1 = throughput_11;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1894 = surface_11;
            Vertex _S1895 = Vertex_x24init_0(_S1871, b_15, (&lobe_8)->pdf, (F32_abs((dot_0(surface_11.geometry_n, throughput_9)))), is_inside_6);
            prev_0 = _S1895;
            float _S1896 = (&lobe_8)->pdf;
            bool _S1897;
            if(_S1881)
            {
                _S1897 = (_S1546.x) == (_S1546.y);
            }
            else
            {
                _S1897 = false;
            }
            float sky_pdf_3 = _slang_select(_S1897, sky_pdf_0,_S1896);
            float _S1898 = _slang_select(_S1551, 0.0f,sky_pdf_3);
            float _S1899 = widened_0(spread_2, (&lobe_8)->pdf, _S1678);
            bool _S1900;
            if(refracted_4)
            {
                _S1900 = !_S1684;
            }
            else
            {
                _S1900 = false;
            }
            bool is_inside_7;
            if(_S1900)
            {
                bool _S1901 = !is_inside_6;
                is_inside_7 = _S1901;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            FKSurface _S1902 = surface_11;
            bool _S1903 = boundsVolume_0(&_S1902);
            bool _S1904;
            if(_S1903)
            {
                _S1904 = !_S1882;
            }
            else
            {
                _S1904 = false;
            }
            if(_S1904)
            {
                FKSurface faced_2 = surface_11;
                float3  _S1905 = - _S1894.geometry_n;
                float3  _S1906 = _slang_select(turned_1, _S1905,_S1894.geometry_n);
                (&faced_2)->geometry_n = _S1906;
                FKMedium _S1907 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1908 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1909 = faced_2;
                FKMedium _S1910 = _S1907;
                FKMedium _S1911 = _S1908;
                MediumSides _S1912 = mediumSides_0(&_S1909, &_S1910, filling_2, (&ray_2)->unit_direction, &_S1911);
                bool _S1913 = leavesInFront_0((&faced_2)->geometry_n, throughput_9, _S1894.geometry_n);
                float3  _S1914 = _slang_select(_S1913, _S1912.front.scatter,_S1912.behind.scatter);
                scatter_in_0 = _S1914;
                float3  _S1915 = _slang_select(_S1913, _S1912.front.extinction,_S1912.behind.extinction);
                extinction_in_0 = _S1915;
                float _S1916 = _slang_select(_S1913, _S1912.front.g,_S1912.behind.g);
                g_in_0 = _S1916;
                uint _S1917 = _S1912.fillings.x;
                uint _S1918 = _S1912.fillings.y;
                uint _S1919 = _slang_select(_S1913, _S1918,_S1917);
                bool _S1920 = (fcptVaryingUsed());
                uint _S1921 = _slang_select(_S1920, _S1919,4294967295U);
                filling_2 = _S1921;
            }
            (&ray_2)->unit_direction = throughput_9;
            bool _S1922 = !_S1882;
            if(_S1922)
            {
                FKSurface _S1923 = surface_11;
                float _S1924 = _slang_select(straight_0, 0.0f,_S1923.geometry_offset);
                float3  _S1925 = - _S1530.smooth_n;
                bool _S1926 = is_inside_7 != _S1684;
                float3  _S1927 = _slang_select(_S1926, _S1925,_S1530.smooth_n);
                float3  _S1928 = (&ray_2)->origin + make_float3 (_S1924) * _S1927;
                (&ray_2)->origin = _S1928;
            }
            throughput_10 = throughput_11;
            chain_throughput_0 = chain_throughput_1;
            density_5 = sky_pdf_2;
            passes_0 = _S1882;
            viewed_1 = _S1682;
            sky_pdf_2 = _S1898;
            spread_4 = _S1899;
            reconnection_0 = reconnection_1;
            is_inside_5 = is_inside_7;
        }
        else
        {
            (&prev_0)->rough = false;
            (&prev_0)->pdf = 0.0f;
            throughput_10 = throughput_7;
            density_5 = density_3;
            passes_0 = false;
            viewed_1 = viewed_0;
            sky_pdf_2 = 0.0f;
            spread_4 = spread_2;
            straight_0 = false;
            is_inside_5 = is_inside_6;
        }
        bool _S1929 = !replay_2;
        if(_S1929)
        {
            if(_S1499)
            {
                float3  _S1930 = throughput_10 * emission_1;
                Reservoir candidate_8 = chain_0;
                uint _S1931 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1932 = _S1931 == 1U;
                if(_S1932)
                {
                    float3  _S1933 = safeDivide(_S1930, chain_throughput_0);
                    (&candidate_8)->radiance = _S1933;
                }
                Reservoir _S1934 = withEnd(candidate_8, 2U, b_12, _S1930);
                offer(sel_7, _S1934, _S1930 * make_float3 (scale_8) / make_float3 (density_5));
            }
            if(_S1499)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1935 = survivalProbability(abs_0(throughput_10), density_5);
                density_6 = _S1935;
            }
            else
            {
                density_6 = 1.0f;
            }
            uint _S1936 = stream(_S1385, b_12 + 128U);
            Random _S1937 = pcg(_S1936);
            bool _S1938 = density_6 < (_S1937.value);
            if(_S1938)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1939 = (fcptMaxBounces());
                wrong_side_0 = b_12 >= _S1939;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1940 = density_5 * density_6;
            density_6 = _S1940;
        }
        else
        {
            density_6 = density_5;
        }
        uint _S1941 = layer_0 ^ 1U;
        uint _S1942 = _slang_select(passes_0, _S1941,0U);
        if(passes_0)
        {
            (&prev_0)->rough = false;
            (&hit_4)->distance = 0.0f;
            b_15 = b_12;
            viewed_0 = viewed_1;
            throughput_2 = throughput_10;
            density_2 = density_6;
            sky_pdf_0 = sky_pdf_2;
            spread_2 = spread_4;
            uint _S1943 = b_15 + 1U;
            b_12 = _S1943;
            layer_0 = _S1942;
            continue;
        }
        FKRay _S1944 = ray_2;
        float _S1945 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_2)
        {
            refracted_4 = _S1585;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S1362 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1946 = _slang_select(wrong_side_0, _S1945,4.294967296e+09f);
        bool _S1947 = !_S1551;
        if(straight_0)
        {
            _S1629 = true;
        }
        else
        {
            _S1629 = _S1551;
        }
        FKHit _S1948;
        if(_S1629)
        {
            _S1948 = hit_4;
        }
        else
        {
            _S1948 = _S1602;
        }
        FKHit _S1949 = (fcptTraverseInstanceBVH((_S1944), (_S1504), (_S1946), (_S1947), (_S1948), (viewed_1)));
        hit_4 = _S1949;
        if(replay_2)
        {
            _S1630 = _S1585;
        }
        else
        {
            _S1630 = false;
        }
        if(_S1630)
        {
            _S1677 = _S1362 == 1U;
        }
        else
        {
            _S1677 = false;
        }
        if(_S1677)
        {
            _S1678 = ((&hit_4)->instance_index) == (_S1374.instance_index);
        }
        else
        {
            _S1678 = false;
        }
        if(_S1678)
        {
            _S1679 = ((&hit_4)->triangle_index) == (_S1374.triangle_index);
        }
        else
        {
            _S1679 = false;
        }
        if(_S1679)
        {
            (&hit_4)->uv = _S1374.uv;
            float _S1950 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S1950;
        }
        if(replay_2)
        {
            _S1680 = _S1585;
        }
        else
        {
            _S1680 = false;
        }
        if(_S1680)
        {
            _S1681 = _S1362 == 3U;
        }
        else
        {
            _S1681 = false;
        }
        if(_S1681)
        {
            _S1682 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1682 = false;
        }
        if(_S1682)
        {
            return _S1358;
        }
        Reservoir _S1951 = chain_0;
        uint _S1952 = filling_2;
        for(;;)
        {
            bool _S1953 = (fcptVaryingUsed());
            if(_S1953)
            {
                _S1683 = _S1952 != 4294967295U;
            }
            else
            {
                _S1683 = false;
            }
            if(_S1683)
            {
                float _S1954 = (fcptMajorant((_S1952)));
                toon_b_5 = _S1954;
            }
            else
            {
                toon_b_5 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_2)
            {
                _S1684 = _S1585;
            }
            else
            {
                _S1684 = false;
            }
            if(_S1684)
            {
                _S1685 = _S1362 == 1U;
            }
            else
            {
                _S1685 = false;
            }
            if(_S1685)
            {
                _S1686 = toon_b_5 > 0.0f;
            }
            else
            {
                _S1686 = false;
            }
            if(_S1686)
            {
                ended_0 = _S1358;
                sky_pdf_1 = sky_pdf_2;
                spread_5 = spread_4;
                width_6 = width_3;
                density_7 = density_6;
                throughput_11 = throughput_10;
                b_15 = b_12;
                _S1687 = true;
                break;
            }
            bool _S1955 = (&prev_0)->rough;
            if(_S1955)
            {
                _S1687 = !(toon_b_5 > 0.0f);
            }
            else
            {
                _S1687 = false;
            }
            (&prev_0)->rough = _S1687;
            uint _S1956 = b_12 + 320U;
            bool _S1957 = b_12 == 4294967295U;
            uint _S1958 = _slang_select(_S1957, 384U,_S1956);
            uint _S1959 = stream(_S1385, _S1958);
            uint tracking_1 = _S1959;
            weight_1 = throughput_3;
            glowed_0 = _S1357;
            b_15 = b_12;
            throughput_11 = throughput_10;
            density_7 = density_6;
            spread_5 = spread_4;
            width_6 = width_3;
            sky_pdf_1 = sky_pdf_2;
            for(;;)
            {
                if(((&hit_4)->instance_index) != 4294967295U)
                {
                }
                else
                {
                    _S1356 = int(2);
                    break;
                }
                uint _S1960 = b_15 + 320U;
                bool _S1961 = b_15 == 4294967295U;
                uint _S1962 = _slang_select(_S1961, 384U,_S1960);
                uint _S1963 = stream(_S1385, _S1962);
                Random _S1964 = pcg(_S1963);
                float _S1965 = freeFlight_0(_S1964.value, toon_b_5);
                if(_S1683)
                {
                    float3  _S1966 = (&ray_2)->origin;
                    float3  _S1967 = (&ray_2)->unit_direction;
                    float _S1968 = (&hit_4)->distance;
                    uint _S1969 = _slang_select(_S1961, 0U,b_15);
                    uint _S1970 = (&prev_0)->lobe;
                    uint _S1971 = _slang_select(_S1961, 3U,_S1970);
                    float _S1972 = (fcptTrackMedium((_S1952), (_S1966), (_S1967), (_S1968), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1969), (_S1971), (_S1961)));
                    spread_3 = _S1972;
                }
                else
                {
                    spread_3 = _S1965;
                }
                bool _S1973 = !(spread_3 < ((&hit_4)->distance));
                if(_S1973)
                {
                    _S1356 = int(2);
                    break;
                }
                if(_S1683)
                {
                    _S1688 = _S1929;
                }
                else
                {
                    _S1688 = false;
                }
                if(_S1688)
                {
                    float3  _S1974 = throughput_11 * glowed_0 / make_float3 (density_7);
                    float3  _S1975 = sel_7->glow + _S1974;
                    sel_7->glow = _S1975;
                }
                else
                {
                }
                glowed_0 = _S1357;
                uint b_20 = b_15 + 1U;
                float3  _S1976 = (&ray_2)->origin + make_float3 (spread_3) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1976;
                float3  _S1977 = flightWeight_0(scatter_in_0, extinction_in_0, toon_b_5, spread_3, true);
                float3  _S1978 = weight_1;
                float3  _S1979 = _slang_select(_S1683, _S1978,_S1977);
                float3  throughput_12 = throughput_11 * _S1979;
                uint _S1980 = stream(_S1385, b_20 + 320U);
                tracking_1 = _S1980;
                weight_1 = throughput_3;
                float width_7 = width_6 + spread_5 * spread_3;
                float _S1981 = spread_5 + 3.14159274101257324f;
                bool _S1982 = scatterSampled_0(replay_2, b_20, _S1373, _S1683);
                TreeSample light_4;
                if(_S1982)
                {
                    float3  _S1983 = (&ray_2)->origin;
                    float3  _S1984 = (&ray_2)->unit_direction;
                    float3  _S1985 = (&ray_2)->unit_direction;
                    uint _S1986 = stream(_S1385, b_20 + 64U);
                    float3  _S1987 = extinction_in_0;
                    float3  _S1988 = extinction_in_0;
                    uint2  _S1989 = make_uint2 (_S1952);
                    float3  _S1990 = (&ray_2)->unit_direction;
                    uint _S1991 = arrivalLobe_0(b_20, (&prev_0)->lobe);
                    FKHit _S1992 = _S1602;
                    ShadowContext _S1993 = ShadowContext_x24init_0(_S1987, _S1988, _S1989, _S1990, b_20, _S1991, false, spread_3, width_7, &_S1992, false);
                    ShadowContext _S1994 = _S1993;
                    TreeSample _S1995 = sampleLightTree_0(_S1983, _S1984, _S1985, 0.0f, true, _S1986, &_S1994);
                    light_4 = _S1995;
                }
                else
                {
                    light_4 = _S1599;
                }
                float _S1996 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1997 = (fcptMaxBounces());
                bool _S1998 = b_20 < _S1997;
                if(_S1998)
                {
                    _S1689 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1689 = false;
                }
                float _S1999 = _slang_select(_S1689, _S1996,0.0f);
                float3  _S2000 = throughput_12 * light_4.radiance;
                float _S2001 = powerHeuristic(light_4.density, _S1999);
                float3  _S2002 = _S2000 * make_float3 (_S1996 * _S2001);
                float3  _S2003 = _slang_select(_S1982, _S2002,_S1357);
                if(replay_2)
                {
                    _S1690 = b_20 == _S1373;
                }
                else
                {
                    _S1690 = false;
                }
                if(_S1690)
                {
                    bool _S2004 = _S1362 == 2U;
                    if(_S2004)
                    {
                        float _S2005 = resamplingTarget(_S2003);
                        _S1691 = _S2005 > 0.0f;
                    }
                    else
                    {
                        _S1691 = false;
                    }
                    if(_S1691)
                    {
                        Shift _S2006 = Shift_x24init_0(_S2003, 1.0f);
                        _S1356 = int(1);
                        ended_0 = _S2006;
                        spread_3 = _S1981;
                        width_4 = width_7;
                        throughput_9 = throughput_12;
                        b_13 = b_20;
                        break;
                    }
                    _S1356 = int(1);
                    ended_0 = _S1358;
                    spread_3 = _S1981;
                    width_4 = width_7;
                    throughput_9 = throughput_12;
                    b_13 = b_20;
                    break;
                }
                if(_S1929)
                {
                    Reservoir candidate_9 = _S1951;
                    uint _S2007 = extractBits_0(_S1951.path, 10U, 2U);
                    bool _S2008 = _S2007 == 1U;
                    if(_S2008)
                    {
                        float3  _S2009 = safeDivide(_S2003, chain_throughput_0);
                        (&candidate_9)->radiance = _S2009;
                    }
                    else
                    {
                        uint _S2010 = insertBits_0(0U, b_20 + 1U, 5U, 5U);
                        uint _S2011 = insertBits_0(_S2010, 2U, 10U, 2U);
                        (&candidate_9)->path = _S2011;
                    }
                    Reservoir _S2012 = withEnd(candidate_9, 0U, b_20, _S2003);
                    offer(sel_7, _S2012, _S2003 * make_float3 (scale_8) / make_float3 (density_7));
                    float _S2013 = survivalProbability(abs_0(throughput_12), density_7);
                    uint _S2014 = stream(_S1385, b_20 + 128U);
                    Random _S2015 = pcg(_S2014);
                    bool _S2016 = _S2013 < (_S2015.value);
                    if(_S2016)
                    {
                        _S1691 = true;
                    }
                    else
                    {
                        uint _S2017 = (fcptMaxBounces());
                        _S1691 = b_20 >= _S2017;
                    }
                    if(_S1691)
                    {
                        _S1356 = int(1);
                        ended_0 = _S1358;
                        spread_3 = _S1981;
                        width_4 = width_7;
                        throughput_9 = throughput_12;
                        b_13 = b_20;
                        break;
                    }
                    float _S2018 = density_7 * _S2013;
                    density_7 = _S2018;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S2019 = stream(_S1385, b_20);
                float3  _S2020 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S2019, &phase_pdf_1);
                (&ray_2)->unit_direction = _S2020;
                NEEVertex _S2021 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1357, (&ray_2)->origin);
                nee_vertex_0 = _S2021;
                Vertex _S2022 = scatteredVertex_0(is_inside_5);
                prev_0 = _S2022;
                float _S2023 = (&prev_0)->pdf;
                FKRay _S2024 = ray_2;
                FKHit _S2025 = (fcptTraverseInstanceBVH((_S2024), (true), (4.294967296e+09f), (false), (_S1602), (false)));
                hit_4 = _S2025;
                b_15 = b_20;
                throughput_11 = throughput_12;
                spread_5 = _S1981;
                width_6 = width_7;
                sky_pdf_1 = _S2023;
            }
            if(_S1356 != int(2))
            {
                spread_5 = spread_3;
                width_6 = width_4;
                throughput_11 = throughput_9;
                b_15 = b_13;
                _S1687 = true;
                break;
            }
            ended_0 = _S1358;
            _S1687 = false;
            break;
        }
        if(_S1687)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1688 = b_15 == b_12;
        }
        else
        {
            _S1688 = false;
        }
        bool _S2026 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S2026)
        {
            bool _S2027 = !(&nee_vertex_0)->none;
            float _S2028 = _slang_select(_S2027, sky_pdf_1,0.0f);
            float _S2029 = escapeWeight_0(_S2028, (&ray_2)->unit_direction);
            float3  _S2030 = environment_0((&ray_2)->unit_direction, b_15, (&prev_0)->lobe);
            float3  _S2031 = throughput_11 * _S2030;
            if(replay_2)
            {
                bool _S2032 = b_15 == _S1373;
                if(_S2032)
                {
                    passes_0 = _S1362 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S2031 * make_float3 (_S2029) / make_float3 (r_8->jac), density_7 / r_8->jac);
                }
                if(_S1372)
                {
                    passes_0 = _S1369;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_15 == _S1360;
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
                    return Shift_x24init_0(_S2031 * make_float3 (_S2029), 1.0f);
                }
                return _S1358;
            }
            Reservoir candidate_10 = chain_0;
            uint _S2033 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S2034 = _S2033 == 1U;
            if(_S2034)
            {
                uint _S2035 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S2036 = _S2035 == b_15;
                float _S2037 = _slang_select(_S2036, 1.0f,_S2029);
                float3  _S2038 = safeDivide(_S2031 * make_float3 (_S2037), chain_throughput_0);
                (&candidate_10)->radiance = _S2038;
            }
            else
            {
                bool _S2039 = (&prev_0)->rough;
                if(_S2039)
                {
                    uint _S2040 = insertBits_0(0U, b_15 + 1U, 5U, 5U);
                    uint _S2041 = insertBits_0(_S2040, 3U, 10U, 2U);
                    uint _S2042 = insertBits_0(_S2041, (&prev_0)->lobe, 15U, 3U);
                    bool _S2043 = (&prev_0)->inside;
                    uint _S2044 = _slang_select(_S2043, 1U,0U);
                    uint _S2045 = insertBits_0(_S2042, _S2044, 22U, 1U);
                    (&candidate_10)->path = _S2045;
                    (&candidate_10)->jac = (&prev_0)->pdf;
                    (&candidate_10)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S2046 = _S2031 * make_float3 (_S2029);
            Reservoir _S2047 = withEnd(candidate_10, 3U, b_15, _S2046);
            offer(sel_7, _S2047, _S2046 * make_float3 (scale_8) / make_float3 (density_7));
            break;
        }
        float3  _S2048 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S2048;
        bool _S2049 = (fcptVaryingUsed());
        if(_S2049)
        {
            _S1689 = filling_2 != 4294967295U;
        }
        else
        {
            _S1689 = false;
        }
        if(_S1689)
        {
            if(_S1929)
            {
                float3  _S2050 = throughput_11 * glowed_0 / make_float3 (density_7);
                float3  _S2051 = sel_7->glow + _S2050;
                sel_7->glow = _S2051;
            }
            float3  _S2052 = throughput_11 * weight_1;
            throughput_9 = _S2052;
        }
        else
        {
            float3  _S2053 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S2054 = throughput_11 * _S2053;
            throughput_9 = _S2054;
        }
        float _S2055 = width_6 + spread_5 * (&hit_4)->distance;
        viewed_0 = _S1688;
        width_3 = _S2055;
        throughput_2 = throughput_9;
        density_2 = density_7;
        sky_pdf_0 = sky_pdf_1;
        spread_2 = spread_5;
        uint _S1943 = b_15 + 1U;
        b_12 = _S1943;
        layer_0 = _S1942;
    }
    return _S1358;
}

static __device__ Shift shift_0(Domain * dom_8, Reservoir * r_9)
{
    Selection _S2056 = (Selection{});
    Selection sel_8 = _S2056;
    bool _S2057 = (r_9->w) <= 0.0f;
    if(_S2057)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S2058 = walk_0(dom_8, r_9, true, 0.0f, &sel_8);
    return _S2058;
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
    Random _S2059 = pcg(state_3);
    Random _S2060 = pcg(_S2059.state);
    float _S2061 = 6.28318548202514648f * _S2059.value;
    float _S2062 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S2060.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S2060.state, _S2062 * (F32_cos((_S2061))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_4, float3  value_2)
{
    RandomSphere _S2063;
    (&_S2063)->state = state_4;
    (&_S2063)->value = value_2;
    return _S2063;
}

__device__ RandomSphere random_sphere(uint state_5)
{
    Random _S2064 = normal_distribution(state_5);
    Random _S2065 = normal_distribution(_S2064.state);
    Random _S2066 = normal_distribution(_S2065.state);
    float3  _S2067 = make_float3 (_S2064.value, _S2065.value, _S2066.value);
    float3  _S2068 = ((((_S2067)) * make_float3(rnorm3df(((_S2067)).x, ((_S2067)).y, ((_S2067)).z))));
    return RandomSphere_x24init_0(_S2066.state, _S2068);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_14)
{
    float3  _S2069 = p1_0 - p0_0;
    float3  _S2070 = p2_0 - p0_0;
    float2  _S2071 = uv1_0 - uv0_0;
    float2  _S2072 = uv2_0 - uv0_0;
    float _S2073 = _S2071.x;
    float _S2074 = _S2072.y;
    float _S2075 = _S2071.y;
    float _S2076 = _S2072.x;
    float _S2077 = _S2073 * _S2074 - _S2075 * _S2076;
    float _S2078 = 1.0f / _S2077;
    float3  t_22 = (_S2069 * make_float3 (_S2074) - _S2070 * make_float3 (_S2075)) * make_float3 (_S2078);
    float3  _S2079 = (_S2070 * make_float3 (_S2073) - _S2069 * make_float3 (_S2076)) * make_float3 (_S2078);
    float3  _S2080 = t_22 - n_14 * make_float3 (dot_0(n_14, t_22));
    float3  t_23 = ((((_S2080)) * make_float3(rnorm3df(((_S2080)).x, ((_S2080)).y, ((_S2080)).z))));
    bool _S2081 = (dot_0(cross_0(n_14, t_23), _S2079)) > 0.0f;
    float3  t_24;
    if(_S2081)
    {
        float3  _S2082 = negate_0(t_23);
        t_24 = _S2082;
    }
    else
    {
        t_24 = t_23;
    }
    float3  _S2083 = cross_0(n_14, t_24);
    return makeMatrix<float, 3, 3> (t_24, _S2083, n_14);
}

__device__ float3  tangentToWorldNormalMap(float3  v_4, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_4, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_5, float3  uvw_0, float3  position_0)
{
    float3  _S2084 = t1_0 - t0_0;
    float3  _S2085 = t2_2 - t0_0;
    float3  _S2086 = t2_2 - t1_0;
    float _S2087 = (F32_min((length_0(_S2084)), ((F32_min((length_0(_S2085)), (length_0(_S2086)))))));
    float3  _S2088 = make_float3 (distance_1(position_0, t0_0), distance_1(position_0, t1_0), distance_1(position_0, t2_2));
    float3  _S2089 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S2090 = dot_0(geometry_n_5, _S2089);
    float3  _S2091 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S2092 = dot_0(geometry_n_5, _S2091);
    float3  _S2093 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S2094 = acos_0(abs_0(make_float3 (_S2090, _S2092, dot_0(geometry_n_5, _S2093))));
    float3  _S2095 = clamp_2(tan_0(_S2094), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S2088 * _S2095, uvw_0), 0.0f, _S2087 * 0.125f);
}

__device__ MaterialTerms precomputeMaterial(BSDFMaterial material_17, float eta_i_11, float eta_o_11)
{
    float _S2096 = (F32_min(((F32_sqrt((material_17.specular_level))) * (F32_abs((eta_i_11 - eta_o_11))) / (eta_i_11 + eta_o_11)), (0.9999847412109375f)));
    float _S2097 = _S2096 * _S2096;
    float _S2098 = (1.0f + _S2096) / (1.0f - _S2096);
    float3  _S2099 = make_float3 (0.0f);
    float _S2100 = material_17.toon.x;
    bool _S2101 = _S2100 < 0.0f;
    float _S2102 = (F32_abs((_S2100)));
    bool _S2103 = _S2102 > 0.0f;
    float toon_scale_4;
    float toon_component_4;
    float toon_a_9;
    float toon_s_9;
    float toon_b_6;
    float toon_norm_5;
    float3  toon_6;
    if(_S2103)
    {
        float _S2104 = (F32_min((_S2102), (1.0f)));
        float _S2105 = 1.0f - _S2104;
        float _S2106 = rgb_to_greyscale(material_17.albedo);
        float _S2107 = _S2104 * _S2106;
        float3  _S2108 = make_float3 (_S2104) * material_17.albedo;
        float toon_a_10 = clamp_1(material_17.toon.y / _S2100, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
        float toon_s_10 = clamp_1(material_17.toon.z / _S2100, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
        float _S2109 = (F32_min((toon_a_10 + toon_s_10), (1.57079637050628662f)));
        if(_S2101)
        {
            toon_scale_4 = 1.0f - (F32_cos(((F32_min((_S2109), (toon_a_10))))));
        }
        else
        {
            float _S2110 = (F32_sin(((F32_min((_S2109), (toon_a_10))))));
            toon_scale_4 = _S2110 * _S2110 / 2.0f;
        }
        bool _S2111 = _S2109 > toon_a_10;
        bool _S2112;
        if(_S2111)
        {
            _S2112 = toon_s_10 > 0.0f;
        }
        else
        {
            _S2112 = false;
        }
        if(_S2112)
        {
            if(_S2101)
            {
                float _S2113 = (F32_cos((toon_a_10)));
                float _S2114 = (F32_cos((_S2109)));
                toon_component_4 = (1.0f + toon_a_10 / toon_s_10) * (_S2113 - _S2114) - ((F32_sin((_S2109))) - _S2109 * _S2114 - ((F32_sin((toon_a_10))) - toon_a_10 * _S2113)) / toon_s_10;
            }
            else
            {
                float _S2115 = 2.0f * toon_a_10;
                float _S2116 = (F32_cos((_S2115)));
                float _S2117 = 2.0f * _S2109;
                float _S2118 = (F32_cos((_S2117)));
                toon_component_4 = (1.0f + toon_a_10 / toon_s_10) * (_S2116 - _S2118) / 4.0f - ((F32_sin((_S2117))) / 8.0f - _S2109 * _S2118 / 4.0f - ((F32_sin((_S2115))) / 8.0f - toon_a_10 * _S2116 / 4.0f)) / toon_s_10;
            }
            float integral_7 = toon_scale_4 + toon_component_4;
            toon_scale_4 = integral_7;
        }
        float _S2119 = 6.28318548202514648f * toon_scale_4;
        toon_scale_4 = _S2105;
        toon_component_4 = _S2107;
        toon_6 = _S2108;
        toon_a_9 = toon_a_10;
        toon_s_9 = toon_s_10;
        toon_b_6 = _S2109;
        toon_norm_5 = _S2119;
    }
    else
    {
        toon_scale_4 = 1.0f;
        toon_component_4 = 0.0f;
        toon_6 = _S2099;
        toon_a_9 = 0.0f;
        toon_s_9 = 0.0f;
        toon_b_6 = 0.0f;
        toon_norm_5 = 1.0f;
    }
    float _S2120 = translucentShare(material_17);
    return MaterialTerms_x24init_0(_S2097, _S2098, _S2120, toon_scale_4, toon_component_4, toon_6, toon_a_9, toon_s_9, toon_b_6, _S2101, toon_norm_5);
}

__device__ ViewTerms precomputeView(float3  in_dir_10, float3  n_15, BSDFMaterial material_18, MaterialTerms terms_7)
{
    float3  _S2121 = negate_0(in_dir_10);
    float _S2122 = sign_0(dot_0(n_15, _S2121));
    float3  _S2123 = n_15 * make_float3 (_S2122);
    AnisotropicFrame _S2124 = anisotropicFrame(material_18, _S2123);
    float3  _S2125 = make_float3 (1.0f);
    float3  _S2126 = make_float3 (0.0f);
    float _S2127 = rgb_to_greyscale(material_18.sheen);
    bool _S2128 = _S2127 > 0.0f;
    float sheen_component_4;
    float3  sheen_6;
    float3  view_5;
    float3  scale_11;
    if(_S2128)
    {
        float _S2129 = clamp_1((F32_sqrt(((F32_max((dot_0(_S2123, _S2121)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S2130 = (U32_min((uint(_S2129)), (22U)));
        float least_5 = (F32_sqrt((0.05000000074505806f)));
        float _S2131 = (F32_sqrt((0.10000000149011612f)));
        bool _S2132 = (material_18.velvet) > 0.0f;
        float _S2133 = _slang_select(_S2132, _S2131,least_5);
        float _S2134 = (clamp_1((F32_sqrt(((F32_max((material_18.sheen_roughness), (0.0f)))))), _S2133, 1.0f) - _S2133) / (1.0f - _S2133) * 23.0f;
        uint _S2135 = (U32_min((uint(_S2134)), (22U)));
        uint _S2136 = _S2130 * 24U + _S2135;
        float _S2137 = _S2129 - float(_S2130);
        float _S2138 = _S2134 - float(_S2135);
        uint _S2139 = _S2136 + 24U;
        float a_18 = SHEEN_ALBEDO_0[_S2136] + (SHEEN_ALBEDO_0[_S2139] - SHEEN_ALBEDO_0[_S2136]) * _S2137;
        uint _S2140 = _S2136 + 1U;
        uint _S2141 = _S2139 + 1U;
        float b_21 = SHEEN_ALBEDO_0[_S2140] + (SHEEN_ALBEDO_0[_S2141] - SHEEN_ALBEDO_0[_S2140]) * _S2137;
        float _S2142 = (F32_exp((a_18 + (b_21 - a_18) * _S2138)));
        if(_S2132)
        {
            float a_19 = VELVET_ALBEDO_0[_S2136] + (VELVET_ALBEDO_0[_S2139] - VELVET_ALBEDO_0[_S2136]) * _S2137;
            float b_22 = VELVET_ALBEDO_0[_S2140] + (VELVET_ALBEDO_0[_S2141] - VELVET_ALBEDO_0[_S2140]) * _S2137;
            float _S2143 = a_19 + (b_22 - a_19) * _S2138;
            sheen_component_4 = _S2143;
        }
        else
        {
            sheen_component_4 = _S2142;
        }
        float _S2144 = (F32_min((sheen_component_4), (1.0f)));
        float3  _S2145 = make_float3 (1.0f) - material_18.sheen * make_float3 (_S2144);
        float _S2146 = rgb_to_greyscale(material_18.sheen);
        float _S2147 = _S2146 * _S2144;
        float3  _S2148 = material_18.sheen / make_float3 ((F32_max((sheen_component_4), (1.0f))));
        sheen_component_4 = _S2147;
        sheen_6 = _S2148;
        view_5 = _S2121;
        scale_11 = _S2145;
    }
    else
    {
        sheen_component_4 = 0.0f;
        sheen_6 = _S2126;
        view_5 = _S2126;
        scale_11 = _S2125;
    }
    float3  scale_12 = scale_11 * make_float3 (terms_7.toon_scale);
    bool _S2149 = (F32_abs((material_18.toon.x))) > 0.0f;
    float toon_view_5;
    float3  toon_axis_5;
    if(_S2149)
    {
        float _S2150 = dot_0(_S2123, _S2121);
        float _S2151 = (F32_acos(((F32_min((_S2150), (1.0f))))));
        if(_S2151 < (terms_7.toon_a))
        {
            toon_view_5 = 1.0f;
        }
        else
        {
            toon_view_5 = (F32_max((1.0f - (_S2151 - terms_7.toon_a) / (F32_max((terms_7.toon_s), (0.0000152587890625f)))), (0.0f)));
        }
        if(terms_7.toon_glossy)
        {
            float3  _S2152 = make_float3 (2.0f * _S2150) * _S2123 - _S2121;
            float3  _S2153 = ((((_S2152)) * make_float3(rnorm3df(((_S2152)).x, ((_S2152)).y, ((_S2152)).z))));
            scale_11 = _S2153;
        }
        else
        {
            scale_11 = _S2123;
        }
        toon_axis_5 = scale_11;
    }
    else
    {
        toon_view_5 = 0.0f;
        toon_axis_5 = _S2123;
    }
    float _S2154 = _S2124.alphas.x;
    float _S2155 = (F32_sqrt(((F32_min((_S2154), (_S2124.alphas.y))))));
    bool _S2156 = _S2154 > 0.0f;
    float _S2157 = _slang_select(_S2156, _S2155,material_18.roughness);
    float _S2158 = _S2157 * _S2157;
    float _S2159 = (F32_pow((_S2158), (1.81585001945495605f))) * (2.15371990203857422f - 0.73285001516342163f * _S2158) / (1.0f + 1.28094995021820068f * _S2158);
    bool _S2160 = _S2158 > 0.0f;
    float _S2161 = _slang_select(_S2160, _S2159,0.0f);
    float _S2162 = clamp_1(dot_0(_S2123, _S2121), 0.0f, 1.0f);
    float _S2163 = _S2158 * _S2157;
    float _S2164 = (F32_min((1.00064504146575928f - _S2157 * (0.00375499995425344f + _S2162 * (-0.04133399948477745f + _S2162 * (-0.90938502550125122f + _S2162 * 0.35275399684906006f))) - _S2158 * (0.27602800726890564f + _S2162 * (1.27023398876190186f + _S2162 * 0.04740000143647194f)) - _S2163 * (0.31452900171279907f - _S2162 * 0.34830701351165771f) + _S2163 * _S2157 * 0.27229699492454529f), (1.0f)));
    float3  _S2165 = min_1(make_float3 (1.0f) / (make_float3 (1.0f) - material_18.albedo * make_float3 (_S2161)), make_float3 (1.0f / (F32_max((_S2164), (0.0000152587890625f)))));
    AnisotropicFrame _S2166 = _S2124;
    ViewTerms _S2167 = ViewTerms_x24init_0(_S2121, _S2123, &_S2166, scale_12, sheen_component_4, sheen_6, view_5, _S2165, toon_view_5, toon_axis_5);
    return _S2167;
}

__device__ float3  straightThrough(float3  dir_15, float3  n_16, BSDFMaterial material_19)
{
    float3  _S2168 = negate_0(dir_15);
    float _S2169 = sign_0(dot_0(n_16, _S2168));
    float3  _S2170 = n_16 * make_float3 (_S2169);
    AnisotropicFrame _S2171 = anisotropicFrame(material_19, _S2170);
    bool _S2172 = (_S2171.alphas.x) > 0.0f;
    if(_S2172)
    {
        float _S2173 = material_19.transmission * (1.0f - material_19.metallic);
        float3  _S2174 = negate_0(_S2170);
        float3  _S2175 = anisotropicLocal(dir_15, _S2171.tangent, _S2174);
        float _S2176 = anisotropicG1(_S2175, _S2171.alphas);
        return make_float3 (_S2173 * _S2176) * material_19.albedo;
    }
    float _S2177 = material_19.transmission * (1.0f - material_19.metallic);
    float _S2178 = material_19.roughness;
    float _S2179 = smithG1(_S2178 * _S2178, (F32_abs((dot_0(n_16, dir_15)))));
    return make_float3 (_S2177 * _S2179) * material_19.albedo;
}

__device__ float hairRow(float3  in_dir_11, float3  t_25, float3  out_dir_4, uint p_14, float w_2, float alpha_6, uint nt_0)
{
    uint _S2180 = p_14 % 4U;
    float _S2181 = w_2 * HAIR_WIDTHS_0[_S2180];
    float _S2182 = (F32_asin((clamp_1(dot_0(out_dir_4, t_25), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_11, t_25), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S2180] * alpha_6;
    return ((F32_asinh((_S2182 / _S2181))) / (F32_asinh((3.14159274101257324f / _S2181))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_12, float3  t_26, float3  out_dir_5, uint np_0)
{
    float3  _S2183 = worldToTangent(out_dir_5, t_26);
    float3  _S2184 = worldToTangent(in_dir_12, t_26);
    return (F32_frac((((F32_atan2((_S2183.z), (_S2183.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S2184.z), (1.17549435082228751e-38f - _S2184.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_13, float3  t_27, uint p_15, float row_0, float column_0, float w_3, float alpha_7, uint nt_1, uint np_1)
{
    float3  _S2185 = worldToTangent(in_dir_13, t_27);
    uint _S2186 = p_15 % 4U;
    float _S2187 = w_3 * HAIR_WIDTHS_0[_S2186];
    float _S2188 = (F32_asin((clamp_1(dot_0(in_dir_13, t_27), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S2186] * alpha_7 + _S2187 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S2187))))));
    float _S2189 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S2185.z), (1.17549435082228751e-38f - _S2185.x)));
    float _S2190 = (F32_cos((_S2188)));
    float3  _S2191 = tangentToWorld(make_float3 (_S2190 * (F32_cos((_S2189))), (F32_sin((_S2188))), _S2190 * (F32_sin((_S2189)))), t_27);
    return _S2191;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_17, BSDFMaterial material_20, float coverage_1)
{
    float3  _S2192;
    if((material_20.ior) == 1.0f)
    {
        float3  _S2193 = straightThrough(toward_1, n_17, material_20);
        _S2192 = _S2193;
    }
    else
    {
        _S2192 = make_float3 (0.0f);
    }
    return _S2192 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_9, Reservoir r_10, bool replay_3, float scale_13, Selection * sel_9)
{
    Domain _S2194 = dom_9;
    Reservoir _S2195 = r_10;
    Shift _S2196 = walk_0(&_S2194, &_S2195, replay_3, scale_13, sel_9);
    return _S2196;
}

__device__ Shift shift_hook(Domain dom_10, Reservoir r_11)
{
    Domain _S2197 = dom_10;
    Reservoir _S2198 = r_11;
    Shift _S2199 = shift_0(&_S2197, &_S2198);
    return _S2199;
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
