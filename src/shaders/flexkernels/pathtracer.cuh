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
        FKLight _S288 = (fcptLight((_S286.y)));
        float _S289 = sphereDensity(_S288.position, _S288.variance, start_5);
        return probability_1 * _S289;
    }
    uint _S290 = _S286.y;
    uint _S291 = (fcptTriangleOffset((_S290)));
    Matrix<float, 3, 3>  _S292 = (fcptWorldTriangle((_S290), (_S291 + _S286.z)));
    float _S293 = solidAngle(probability_1, cross_0(_S292.rows[int(1)] - _S292.rows[int(0)], _S292.rows[int(2)] - _S292.rows[int(0)]), light_point_0 - start_5);
    return _S293;
}

static __device__ float3  environment_0(float3  dir_2, uint depth_0, uint lobe_0)
{
    uint2  _S294 = (fcptEnvironmentMapSize());
    bool _S295 = all_0(_S294 > make_uint2 (1U));
    if(_S295)
    {
        float3  _S296 = (fcptEnvMapSample((dir_2), (depth_0), (lobe_0)));
        return _S296;
    }
    float3  _S297 = (fcptAmbient());
    return _S297;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S298 = (fcptEnvironmentCdfSize());
    bool _S299 = !all_0(_S298 > make_uint2 (1U));
    if(_S299)
    {
        return false;
    }
    uint2  _S300 = (fcptEnvironmentMapSize());
    return all_0(_S300 > make_uint2 (1U));
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

static __device__ float environmentPdf_0(float3  dir_3)
{
    uint2  _S301 = (fcptEnvironmentCdfSize());
    uint2  _S302 = _S301 - make_uint2 (1U, 0U);
    float2  _S303 = make_float2 ((F32_atan2((- dir_3.y), (dir_3.x))) / 6.28318548202514648f + 0.5f, (F32_acos((clamp_1(dir_3.z, -1.0f, 1.0f)))) / 3.14159274101257324f);
    float2  _S304 = make_float2 ((float)_S302.x, (float)_S302.y);
    float2  _S305 = _S303 * _S304;
    uint2  _S306 = make_uint2 ((uint)_S305.x, (uint)_S305.y);
    uint2  _S307 = min_0(_S306, _S302 - make_uint2 (1U));
    float4  _S308 = (fcptEnvironmentCdf((_S307)));
    float _S309 = _S308.y;
    uint _S310 = _S302.x;
    float4  _S311 = (fcptEnvironmentCdf((make_uint2 (_S310, _S307.y))));
    float _S312 = _S309 * _S311.y;
    return _S312 * float(_S310 * _S302.y) / (19.73921012878417969f * length_1(float2 {dir_3.x, dir_3.y}));
}

static __device__ float escapeWeight_0(float pdf_0, float3  dir_4)
{
    bool _S313 = pdf_0 <= 0.0f;
    bool _S314;
    if(_S313)
    {
        _S314 = true;
    }
    else
    {
        bool _S315 = environmentMapped_0();
        _S314 = !_S315;
    }
    if(_S314)
    {
        return 1.0f;
    }
    float _S316 = environmentPdf_0(dir_4);
    return pdf_0 / (pdf_0 + _S316);
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
    uint2  _S317 = make_uint2 (k_0 * 3242174889U, k_0 * 2447445414U) >> make_uint2 (16U);
    uint _S318 = (fkBlueNoiseSize());
    return (_S317 * make_uint2 (_S318)) >> make_uint2 (16U);
}

__device__ uint stream(uint seed_3, uint index_0)
{
    uint _S319 = hash(index_0);
    uint _S320 = hash(seed_3 ^ _S319);
    return _S320;
}

static __device__ Random Random_x24init_0(uint state_0, float value_0)
{
    Random _S321;
    (&_S321)->state = state_0;
    (&_S321)->value = value_0;
    return _S321;
}

__device__ Random pcg(uint state_1)
{
    uint _S322 = hash(state_1);
    float value_1 = float(_S322 >> int(8)) * 5.9604644775390625e-08f;
    return Random_x24init_0(_S322, value_1);
}

__device__ __noinline__ Random draw(uint address_0, uint variable_0)
{
    uint _S323 = address_0 >> 22U;
    uint _S324 = _S323 / 32U;
    uint2  _S325 = make_uint2 (address_0 & 2047U, (address_0 >> 11U) & 2047U);
    uint _S326 = variable_0 & 2147483647U;
    uint2  _S327 = noiseOffset(_S326);
    uint2  _S328 = _S325 + _S327;
    uint2  _S329 = noiseOffset(4096U + _S324);
    uint2  _S330 = _S328 + _S329;
    uint _S331 = (fkBlueNoiseSize());
    uint2  _S332 = _S330 & make_uint2 (_S331 - 1U);
    uint _S333 = (fkBlueNoise((_S332.x), (_S332.y), ((_S323 + ((_S324 * 2654435769U) >> 27U)) % 32U)));
    bool _S334 = (variable_0 & 2147483648U) != 0U;
    uint _S335 = stream(address_0, _S326);
    Random _S336 = pcg(_S335);
    float _S337;
    if(_S333 == 4294967295U)
    {
        if(_S334)
        {
            Random _S338 = pcg(_S336.state);
            _S337 = _S338.value;
        }
        else
        {
            _S337 = _S336.value;
        }
    }
    else
    {
        uint _S339;
        if(_S334)
        {
            _S339 = _S333 >> 16U;
        }
        else
        {
            _S339 = _S333 & 65535U;
        }
        _S337 = (float(_S339) + 0.5f) / 6.5536e+04f;
    }
    return Random_x24init_0(address_0, _S337);
}

__device__ float upsample(float3  rgb_0, float wavelength_0)
{
    float _S340 = dot_0(make_float3 (-0.08011700212955475f, 1.08901798725128174f, -0.00889899954199791f), rgb_0);
    float _S341 = dot_0(make_float3 (0.12177000194787979f, -1.22903203964233398f, 1.10724997520446777f), rgb_0);
    float _S342 = dot_0(make_float3 (1.17252397537231445f, -1.21603405475616455f, 0.04350199922919273f), rgb_0);
    float3  _S343 = make_float3 (_S340, _S341, _S342);
    float _S344 = (wavelength_0 - 0.44999998807907104f) / 0.02999999932944775f;
    float _S345 = (wavelength_0 - 0.63999998569488525f) / 0.03999999910593033f;
    return _S340 + _S341 * (F32_exp((-0.5f * _S344 * _S344))) + _S342 * (F32_exp((-0.5f * _S345 * _S345)));
}

__device__ BSDFMaterial atWavelength(BSDFMaterial material_0, float wavelength_1)
{
    BSDFMaterial at_0 = material_0;
    float _S346 = upsample(material_0.albedo, wavelength_1);
    float3  _S347 = make_float3 (_S346);
    (&at_0)->albedo = _S347;
    float _S348 = upsample(material_0.emissive, wavelength_1);
    float3  _S349 = make_float3 (_S348);
    (&at_0)->emissive = _S349;
    float _S350 = upsample(material_0.absorption, wavelength_1);
    float3  _S351 = make_float3 (_S350);
    (&at_0)->absorption = _S351;
    float _S352 = upsample(material_0.specular_tint, wavelength_1);
    float3  _S353 = make_float3 (_S352);
    (&at_0)->specular_tint = _S353;
    float _S354 = upsample(material_0.translucent, wavelength_1);
    float3  _S355 = make_float3 (_S354);
    (&at_0)->translucent = _S355;
    float _S356 = upsample(material_0.sheen, wavelength_1);
    float3  _S357 = make_float3 (_S356);
    (&at_0)->sheen = _S357;
    float _S358 = upsample(material_0.coat_tint, wavelength_1);
    float3  _S359 = make_float3 (_S358);
    (&at_0)->coat_tint = _S359;
    return at_0;
}

__device__ BSDFMaterial pathMaterial(BSDFMaterial material_1, float wavelength_2)
{
    BSDFMaterial _S360;
    if(wavelength_2 > 0.0f)
    {
        BSDFMaterial _S361 = atWavelength(material_1, wavelength_2);
        _S360 = _S361;
    }
    else
    {
        _S360 = material_1;
    }
    return _S360;
}

static __device__ float3  negate_0(float3  x_13)
{
    return - x_13;
}

static __device__ float sign_0(float e_1)
{
    float _S362;
    if(e_1 > 0.0f)
    {
        _S362 = 1.0f;
    }
    else
    {
        if(e_1 < 0.0f)
        {
            _S362 = -1.0f;
        }
        else
        {
            _S362 = 0.0f;
        }
    }
    return _S362;
}

struct AnisotropicFrame
{
    float3  tangent;
    float2  alphas;
};

static __device__ AnisotropicFrame AnisotropicFrame_x24init_0(float3  tangent_0, float2  alphas_0)
{
    AnisotropicFrame _S363;
    (&_S363)->tangent = tangent_0;
    (&_S363)->alphas = alphas_0;
    return _S363;
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_1)
{
    float3  a_1 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S364 = (F32_abs((dot_0(n_1, a_1)))) > 0.9999847412109375f;
    float3  a_2;
    if(_S364)
    {
        float3  _S365 = make_float3 (1.0f, 0.0f, 0.0f);
        a_2 = _S365;
    }
    else
    {
        a_2 = a_1;
    }
    float3  _S366 = cross_0(n_1, a_2);
    float3  _S367 = ((((_S366)) * make_float3(rnorm3df(((_S366)).x, ((_S366)).y, ((_S366)).z))));
    float3  _S368 = cross_0(n_1, _S367);
    return make_float3 (v_0.x) * _S367 + make_float3 (v_0.y) * n_1 + make_float3 (v_0.z) * _S368;
}

__device__ AnisotropicFrame anisotropicFrame(BSDFMaterial material_2, float3  n_i_0)
{
    float _S369 = material_2.roughness;
    float _S370 = _S369 * _S369;
    bool _S371 = (material_2.anisotropy) == 0.0f;
    bool _S372;
    if(_S371)
    {
        _S372 = true;
    }
    else
    {
        _S372 = !(_S370 > 0.0f);
    }
    if(_S372)
    {
        return AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f));
    }
    float3  _S373 = material_2.tangent - n_i_0 * make_float3 (dot_0(n_i_0, material_2.tangent));
    float3  _S374 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_i_0);
    bool _S375 = (dot_0(_S373, _S373)) > 0.0f;
    float3  _S376 = _slang_select(_S375, _S373,_S374);
    float3  _S377 = ((((_S376)) * make_float3(rnorm3df(((_S376)).x, ((_S376)).y, ((_S376)).z))));
    float _S378 = 6.28318548202514648f * material_2.anisotropic_rotation;
    float _S379 = (F32_sqrt((1.0f - 0.89999997615814209f * (F32_abs((material_2.anisotropy))))));
    float _S380 = 1.0f / _S379;
    bool _S381 = (material_2.anisotropy) < 0.0f;
    float _S382 = _slang_select(_S381, _S380,_S379);
    return AnisotropicFrame_x24init_0(_S377 * make_float3 ((F32_cos((_S378)))) + cross_0(n_i_0, _S377) * make_float3 ((F32_sin((_S378)))), make_float2 (_S370 / _S382, _S370 * _S382));
}

struct SheenProfile
{
    bool on;
    float albedo;
};

static __device__ SheenProfile SheenProfile_x24init_0(bool on_0, float albedo_0)
{
    SheenProfile _S383;
    (&_S383)->on = on_0;
    (&_S383)->albedo = albedo_0;
    return _S383;
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
    SheenProfile _S384 = SheenProfile_x24init_0(false, 0.0f);
    float _S385 = rgb_to_greyscale(material_3.sheen);
    bool _S386 = _S385 > 0.0f;
    SheenProfile profile_0;
    if(_S386)
    {
        float _S387 = clamp_1((F32_sqrt(((F32_max((dot_0(n_i_1, v_1)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S388 = (U32_min((uint(_S387)), (22U)));
        float _S389 = (F32_sqrt((0.05000000074505806f)));
        float _S390 = (F32_sqrt((0.10000000149011612f)));
        bool _S391 = (material_3.velvet) > 0.0f;
        float _S392 = _slang_select(_S391, _S390,_S389);
        float _S393 = (clamp_1((F32_sqrt(((F32_max((material_3.sheen_roughness), (0.0f)))))), _S392, 1.0f) - _S392) / (1.0f - _S392) * 23.0f;
        uint _S394 = (U32_min((uint(_S393)), (22U)));
        uint _S395 = _S388 * 24U + _S394;
        float _S396 = _S387 - float(_S388);
        float _S397 = _S393 - float(_S394);
        if(_S391)
        {
            uint _S398 = _S395 + 24U;
            float _S399 = VELVET_ALBEDO_0[_S395] + (VELVET_ALBEDO_0[_S398] - VELVET_ALBEDO_0[_S395]) * _S396;
            uint _S400 = _S395 + 1U;
            float _S401 = VELVET_ALBEDO_0[_S400] + (VELVET_ALBEDO_0[_S398 + 1U] - VELVET_ALBEDO_0[_S400]) * _S396;
            SheenProfile _S402 = SheenProfile_x24init_0(true, _S399 + (_S401 - _S399) * _S397);
            profile_0 = _S402;
        }
        else
        {
            uint _S403 = _S395 + 24U;
            float _S404 = SHEEN_ALBEDO_0[_S395] + (SHEEN_ALBEDO_0[_S403] - SHEEN_ALBEDO_0[_S395]) * _S396;
            uint _S405 = _S395 + 1U;
            float _S406 = SHEEN_ALBEDO_0[_S405] + (SHEEN_ALBEDO_0[_S403 + 1U] - SHEEN_ALBEDO_0[_S405]) * _S396;
            SheenProfile _S407 = SheenProfile_x24init_0(true, (F32_exp((_S404 + (_S406 - _S404) * _S397))));
            profile_0 = _S407;
        }
    }
    else
    {
        profile_0 = _S384;
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
    CoatFrame _S408;
    (&_S408)->normal = normal_3;
    (&_S408)->alpha = alpha_0;
    (&_S408)->ior = ior_0;
    return _S408;
}

__device__ __forceinline__ CoatFrame coatFrame(BSDFMaterial material_4, float3  n_2)
{
    CoatFrame _S409 = CoatFrame_x24init_0(make_float3 (0.0f), 0.0f, 0.0f);
    bool _S410 = (material_4.coat) > 0.0f;
    CoatFrame frame_0;
    if(_S410)
    {
        float3  _S411 = material_4.coat_normal;
        bool _S412 = (dot_0(_S411, _S411)) > 0.0f;
        float3  _S413 = material_4.coat_normal;
        float3  _S414 = ((((_S413)) * make_float3(rnorm3df(((_S413)).x, ((_S413)).y, ((_S413)).z))));
        float3  _S415 = _slang_select(_S412, _S414,n_2);
        float _S416 = sign_0(dot_0(_S415, n_2));
        float _S417 = material_4.coat_roughness;
        CoatFrame _S418 = CoatFrame_x24init_0(_S415 * make_float3 (_S416), _S417 * _S417, (F32_max((material_4.coat_ior), (1.00999999046325684f))));
        frame_0 = _S418;
    }
    else
    {
        frame_0 = _S409;
    }
    return frame_0;
}

__device__ __forceinline__ float3  coatSeries(CoatFrame coat_frame_0, BSDFMaterial material_5)
{
    float3  _S419 = make_float3 (0.0f);
    bool _S420 = (coat_frame_0.ior) > 0.0f;
    float3  series_0;
    if(_S420)
    {
        float _S421 = coat_frame_0.ior * coat_frame_0.ior;
        float _S422 = _S421 * _S421;
        float _S423 = coat_frame_0.ior - 1.0f;
        float _S424 = coat_frame_0.ior + 1.0f;
        float _S425 = _S421 - 1.0f;
        float _S426 = _S421 + 1.0f;
        float _S427 = _S422 - 1.0f;
        float _S428 = _S426 * _S427;
        float _S429 = 0.5f + _S423 * (3.0f * coat_frame_0.ior + 1.0f) / (6.0f * _S424 * _S424) + _S421 * _S425 * _S425 / (_S426 * _S426 * _S426) * (F32_log((_S423 / _S424))) - 2.0f * _S421 * coat_frame_0.ior * (_S421 + 2.0f * coat_frame_0.ior - 1.0f) / _S428 + 8.0f * _S422 * (_S422 + 1.0f) / (_S428 * _S427) * (F32_log((coat_frame_0.ior)));
        float _S430 = 1.0f - (1.0f - _S429) / _S421;
        float3  _S431 = material_5.coat_tint;
        float3  _S432 = _S431 * _S431 * make_float3 (1.0f - _S430) / (make_float3 (1.0f) - material_5.albedo * make_float3 (_S430));
        series_0 = _S432;
    }
    else
    {
        series_0 = _S419;
    }
    return series_0;
}

__device__ __forceinline__ float3  reflectedHalf(float3  in_dir_0, float3  out_dir_0)
{
    float3  _S433 = negate_0(in_dir_0);
    float3  _S434 = _S433 + out_dir_0;
    float3  _S435 = ((((_S434)) * make_float3(rnorm3df(((_S434)).x, ((_S434)).y, ((_S434)).z))));
    return _S435;
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
    float _S436 = dot_0(n_3, i_6);
    float _S437 = 1.0f - eta_0 * eta_0 * (1.0f - _S436 * _S436);
    if(_S437 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_6 - make_float3 (eta_0 * _S436 + (F32_sqrt((_S437)))) * n_3;
}

__device__ float fresnel(float cos_theta_0, float eta_i_0, float eta_o_0)
{
    float _S438 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S439 = eta_i_0 / eta_o_0 * _S438;
    bool _S440 = _S439 < 1.0f;
    float kr_0;
    if(_S440)
    {
        float _S441 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S439 * _S439))))));
        bool _S442 = eta_i_0 == eta_o_0;
        float _S443 = _slang_select(_S442, cos_theta_0,_S441);
        float _S444 = eta_o_0 * cos_theta_0;
        float _S445 = eta_i_0 * _S443;
        float _S446 = (_S444 - _S445) / (_S444 + _S445);
        float _S447 = eta_i_0 * cos_theta_0;
        float _S448 = eta_o_0 * _S443;
        float _S449 = (_S447 - _S448) / (_S447 + _S448);
        float _S450 = (_S446 * _S446 + _S449 * _S449) / 2.0f;
        kr_0 = _S450;
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
    float _S451 = alpha_1 * alpha_1;
    float _S452 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S451 + (1.0f - _S451) * n_dot_x_0 * n_dot_x_0))));
    bool _S453 = alpha_1 > 0.0f;
    float _S454 = _slang_select(_S453, _S452,1.0f);
    return _S454;
}

__device__ __forceinline__ float coatFresnel(float3  in_dir_1, float3  v_2, float3  coat_h_0, CoatFrame coat_frame_1, float eta_i_1, bool behind_0)
{
    float _S455 = dot_0(coat_frame_1.normal, reflect_0(in_dir_1, coat_h_0));
    float _S456 = (F32_abs((dot_0(v_2, coat_h_0))));
    float _S457 = eta_i_1 / coat_frame_1.ior * (F32_sqrt(((F32_max((1.0f - _S456 * _S456), (0.0f))))));
    float _S458 = (F32_sqrt(((F32_max((1.0f - _S457 * _S457), (0.0f))))));
    float _S459 = _slang_select(behind_0, _S458,_S456);
    float _S460 = _slang_select(behind_0, coat_frame_1.ior,1.0f);
    float _S461 = _slang_select(behind_0, 1.0f,coat_frame_1.ior);
    float _S462 = fresnel(_S459, _S460, _S461);
    float _S463 = smithG1(coat_frame_1.alpha, _S455);
    float _S464 = _S462 * _S463;
    bool _S465 = _S455 > 0.0f;
    float _S466 = _slang_select(_S465, _S464,0.0f);
    return _S466;
}

static __device__ float3  mix_0(float3  e1_0, float3  e2_0, float e3_0)
{
    return e1_0 * make_float3 (1.0f - e3_0) + e2_0 * make_float3 (e3_0);
}

static __device__ Weights Weights_x24init_0(float v_dot_h_0, float3  refracted_1, float3  F_0, float reflect_weight_0, float3  diffuse_weight_0, float3  refract_weight_0, float p_diffuse_0, float p_reflect_0, float p_refract_0, float p_sheen_velvet_0, float p_toon_0, float3  sheen_0, float3  toon_0, float3  coat_0, float p_coat_0)
{
    Weights _S467;
    (&_S467)->v_dot_h = v_dot_h_0;
    (&_S467)->refracted = refracted_1;
    (&_S467)->F = F_0;
    (&_S467)->reflect_weight = reflect_weight_0;
    (&_S467)->diffuse_weight = diffuse_weight_0;
    (&_S467)->refract_weight = refract_weight_0;
    (&_S467)->p_diffuse = p_diffuse_0;
    (&_S467)->p_reflect = p_reflect_0;
    (&_S467)->p_refract = p_refract_0;
    (&_S467)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S467)->p_toon = p_toon_0;
    (&_S467)->sheen = sheen_0;
    (&_S467)->toon = toon_0;
    (&_S467)->coat = coat_0;
    (&_S467)->p_coat = p_coat_0;
    return _S467;
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

__device__ __forceinline__ Weights lobeWeights(float3  in_dir_2, float3  v_3, float3  n_i_2, float3  h_0, float3  coat_h_1, float3  ggx_n_0, float3  coat_n_0, AnisotropicFrame frame_1, SheenProfile sheen_profile_0, CoatFrame coat_frame_2, float3  coat_series_0, BSDFMaterial material_6, float eta_i_2, float eta_o_1)
{
    float _S468 = (F32_min(((F32_sqrt((material_6.specular_level))) * (F32_abs((eta_i_2 - eta_o_1))) / (eta_i_2 + eta_o_1)), (0.9999847412109375f)));
    float _S469 = _S468 * _S468;
    float _S470 = (1.0f + _S468) / (1.0f - _S468);
    float3  _S471 = make_float3 (1.0f);
    float3  _S472 = make_float3 (0.0f);
    float sheen_component_0;
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
    float toon_component_0;
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
    float _S497 = dot_0(h_0, v_3);
    float _S498 = eta_i_2 / eta_o_1;
    float3  _S499 = refract_0(in_dir_2, h_0, _S498);
    float3  _S500 = ((((_S499)) * make_float3(rnorm3df(((_S499)).x, ((_S499)).y, ((_S499)).z))));
    float _S501 = (F32_abs((_S497)));
    bool _S502 = eta_i_2 > eta_o_1;
    float _S503;
    if(_S502)
    {
        _S503 = _S470;
    }
    else
    {
        _S503 = 1.0f;
    }
    float _S504;
    if(_S502)
    {
        _S504 = 1.0f;
    }
    else
    {
        _S504 = _S470;
    }
    float _S505 = fresnel(_S501, _S503, _S504);
    float _S506 = eta_i_2 * eta_i_2;
    float _S507 = eta_o_1 * eta_o_1;
    bool _S508 = (_S506 * (1.0f - _S497 * _S497)) >= _S507;
    float3  _S509;
    if(_S508)
    {
        _S509 = _S471;
    }
    else
    {
        float3  _S510 = material_6.specular_tint * make_float3 (_S469);
        _S509 = _S510 + (make_float3 (1.0f) - _S510) * make_float3 (_S505 - _S469) / make_float3 (1.0f - _S469);
    }
    bool _S511 = (dot_0(coat_h_1, coat_h_1)) > 0.0f;
    float3  coat_1;
    float3  up_0;
    float3  through_0;
    if(_S511)
    {
        float _S512 = coatFresnel(in_dir_2, v_3, coat_h_1, coat_frame_2, eta_i_2, _S502);
        float _S513 = material_6.coat * _S512;
        float3  _S514 = material_6.coat_tint;
        float3  _S515 = _S514 * _S514;
        float3  _S516 = _slang_select(_S502, _S515,_S471);
        float3  _S517 = make_float3 (_S513) * _S516;
        float _S518 = 1.0f - _S512;
        bool _S519 = !_S502;
        float3  _S520 = _slang_select(_S519, coat_series_0,_S471);
        float3  _S521 = mix_0(_S471, make_float3 (_S518) * _S520, material_6.coat);
        float3  _S522 = mix_0(_S471, make_float3 (_S518) * material_6.coat_tint, material_6.coat);
        coat_1 = _S517;
        up_0 = _S521;
        through_0 = _S522;
    }
    else
    {
        coat_1 = _S472;
        up_0 = _S471;
        through_0 = _S471;
    }
    float3  _S523 = scale_1 * coat_1;
    float _S524 = rgb_to_greyscale(_S523);
    float3  _S525 = material_6.albedo * rebounce_0;
    float3  _S526 = mix_0(_S509, _S525, material_6.metallic);
    float3  F_1 = _S526 * scale_1 * up_0;
    float _S527 = rgb_to_greyscale(F_1);
    float _S528 = 1.0f - material_6.metallic;
    float _S529 = (1.0f - material_6.transmission) * _S528;
    float3  _S530 = make_float3 (1.0f) - _S509;
    float3  _S531 = make_float3 (_S529) * _S530 * scale_1 * up_0;
    float _S532 = material_6.transmission * _S528;
    float3  _S533 = make_float3 (_S532) * _S530 * scale_1 * through_0;
    float _S534 = (F32_max((_S527), (0.0f)));
    float _S535 = rgb_to_greyscale(_S531);
    float _S536 = (F32_max((_S535), (0.0f)));
    float _S537 = rgb_to_greyscale(_S533);
    float _S538 = sign_0(length_0(_S500));
    float _S539 = (F32_max((_S537 * _S538), (0.0f)));
    float _S540 = _S534 + _S536 + _S539 + toon_component_0 + _S524;
    float _S541 = (F32_min((sheen_component_0), (1.0f)));
    bool _S542 = sheen_component_0 > 0.0f;
    bool _S543;
    if(_S542)
    {
        _S543 = !(_S540 > 0.0f);
    }
    else
    {
        _S543 = false;
    }
    float _S544 = _slang_select(_S543, 1.0f,_S541);
    float _S545 = (1.0f - _S544) / (F32_max((_S540), (0.0000152587890625f)));
    float _S546 = _S536 * _S545;
    float _S547 = _S534 * _S545;
    float _S548 = _S539 * _S545;
    Weights _S549 = Weights_x24init_0(_S497, _S500, F_1, 1.0f, _S531, _S533, _S546, _S547, _S548, _S544, toon_component_0 * _S545, sheen_1, toon_1, _S523, _S524 * _S545);
    bool _S550 = any_1(ggx_n_0 != h_0);
    Weights leaving_0;
    if(_S550)
    {
        float _S551 = dot_0(ggx_n_0, v_3);
        float _S552 = eta_i_2 / eta_o_1;
        float3  _S553 = refract_0(in_dir_2, ggx_n_0, _S552);
        float3  _S554 = ((((_S553)) * make_float3(rnorm3df(((_S553)).x, ((_S553)).y, ((_S553)).z))));
        float _S555 = (F32_abs((_S551)));
        if(_S502)
        {
            _S503 = _S470;
        }
        else
        {
            _S503 = 1.0f;
        }
        if(_S502)
        {
            _S504 = 1.0f;
        }
        else
        {
            _S504 = _S470;
        }
        float _S556 = fresnel(_S555, _S503, _S504);
        bool _S557 = (_S506 * (1.0f - _S551 * _S551)) >= _S507;
        if(_S557)
        {
            _S509 = _S471;
        }
        else
        {
            float3  _S558 = material_6.specular_tint * make_float3 (_S469);
            _S509 = _S558 + (make_float3 (1.0f) - _S558) * make_float3 (_S556 - _S469) / make_float3 (1.0f - _S469);
        }
        if(_S511)
        {
            float _S559 = coatFresnel(in_dir_2, v_3, coat_h_1, coat_frame_2, eta_i_2, _S502);
            float _S560 = material_6.coat * _S559;
            float3  _S561 = material_6.coat_tint;
            float3  _S562 = _S561 * _S561;
            float3  _S563 = _slang_select(_S502, _S562,_S471);
            float3  _S564 = make_float3 (_S560) * _S563;
            float _S565 = 1.0f - _S559;
            bool _S566 = !_S502;
            float3  _S567 = _slang_select(_S566, coat_series_0,_S471);
            float3  _S568 = mix_0(_S471, make_float3 (_S565) * _S567, material_6.coat);
            float3  _S569 = mix_0(_S471, make_float3 (_S565) * material_6.coat_tint, material_6.coat);
            coat_1 = _S564;
            up_0 = _S568;
            through_0 = _S569;
        }
        else
        {
            coat_1 = _S472;
            up_0 = _S471;
            through_0 = _S471;
        }
        float3  _S570 = scale_1 * coat_1;
        float _S571 = rgb_to_greyscale(_S570);
        float3  _S572 = mix_0(_S509, _S525, material_6.metallic);
        float3  F_2 = _S572 * scale_1 * up_0;
        float _S573 = rgb_to_greyscale(F_2);
        float3  _S574 = make_float3 (1.0f) - _S509;
        float3  _S575 = make_float3 (_S529) * _S574 * scale_1 * up_0;
        float3  _S576 = make_float3 (_S532) * _S574 * scale_1 * through_0;
        float _S577 = (F32_max((_S573), (0.0f)));
        float _S578 = rgb_to_greyscale(_S575);
        float _S579 = (F32_max((_S578), (0.0f)));
        float _S580 = rgb_to_greyscale(_S576);
        float _S581 = sign_0(length_0(_S554));
        float _S582 = (F32_max((_S580 * _S581), (0.0f)));
        float _S583 = _S577 + _S579 + _S582 + toon_component_0 + _S571;
        if(_S542)
        {
            _S543 = !(_S583 > 0.0f);
        }
        else
        {
            _S543 = false;
        }
        float _S584 = _slang_select(_S543, 1.0f,_S541);
        float _S585 = (1.0f - _S584) / (F32_max((_S583), (0.0000152587890625f)));
        float _S586 = _S579 * _S585;
        float _S587 = _S577 * _S585;
        float _S588 = _S582 * _S585;
        Weights _S589 = Weights_x24init_0(_S551, _S554, F_2, 1.0f, _S575, _S576, _S586, _S587, _S588, _S584, toon_component_0 * _S585, sheen_1, toon_1, _S570, _S571 * _S585);
        leaving_0 = _S589;
    }
    else
    {
        leaving_0 = _S549;
    }
    bool _S590 = any_1(coat_n_0 != coat_h_1);
    Weights coated_0;
    if(_S590)
    {
        float _S591 = eta_i_2 / eta_o_1;
        float3  _S592 = refract_0(in_dir_2, h_0, _S591);
        float3  _S593 = ((((_S592)) * make_float3(rnorm3df(((_S592)).x, ((_S592)).y, ((_S592)).z))));
        if(_S502)
        {
            sheen_component_0 = _S470;
        }
        else
        {
            sheen_component_0 = 1.0f;
        }
        if(_S502)
        {
            _S503 = 1.0f;
        }
        else
        {
            _S503 = _S470;
        }
        float _S594 = fresnel(_S501, sheen_component_0, _S503);
        if(_S508)
        {
            rebounce_0 = _S471;
        }
        else
        {
            float3  _S595 = material_6.specular_tint * make_float3 (_S469);
            rebounce_0 = _S595 + (make_float3 (1.0f) - _S595) * make_float3 (_S594 - _S469) / make_float3 (1.0f - _S469);
        }
        bool _S596 = (dot_0(coat_n_0, coat_n_0)) > 0.0f;
        if(_S596)
        {
            float _S597 = coatFresnel(in_dir_2, v_3, coat_n_0, coat_frame_2, eta_i_2, _S502);
            float _S598 = material_6.coat * _S597;
            float3  _S599 = material_6.coat_tint;
            float3  _S600 = _S599 * _S599;
            float3  _S601 = _slang_select(_S502, _S600,_S471);
            float3  _S602 = make_float3 (_S598) * _S601;
            float _S603 = 1.0f - _S597;
            bool _S604 = !_S502;
            float3  _S605 = _slang_select(_S604, coat_series_0,_S471);
            float3  _S606 = mix_0(_S471, make_float3 (_S603) * _S605, material_6.coat);
            float3  _S607 = mix_0(_S471, make_float3 (_S603) * material_6.coat_tint, material_6.coat);
            coat_1 = _S602;
            up_0 = _S606;
            through_0 = _S607;
        }
        else
        {
            coat_1 = _S472;
            up_0 = _S471;
            through_0 = _S471;
        }
        float3  _S608 = scale_1 * coat_1;
        float _S609 = rgb_to_greyscale(_S608);
        float3  _S610 = mix_0(rebounce_0, _S525, material_6.metallic);
        float3  F_3 = _S610 * scale_1 * up_0;
        float _S611 = rgb_to_greyscale(F_3);
        float3  _S612 = make_float3 (1.0f) - rebounce_0;
        float3  _S613 = make_float3 (_S529) * _S612 * scale_1 * up_0;
        float3  _S614 = make_float3 (_S532) * _S612 * scale_1 * through_0;
        float _S615 = (F32_max((_S611), (0.0f)));
        float _S616 = rgb_to_greyscale(_S613);
        float _S617 = (F32_max((_S616), (0.0f)));
        float _S618 = rgb_to_greyscale(_S614);
        float _S619 = sign_0(length_0(_S593));
        float _S620 = (F32_max((_S618 * _S619), (0.0f)));
        float _S621 = _S615 + _S617 + _S620 + toon_component_0 + _S609;
        if(_S542)
        {
            _S543 = !(_S621 > 0.0f);
        }
        else
        {
            _S543 = false;
        }
        float _S622 = _slang_select(_S543, 1.0f,_S541);
        float _S623 = (1.0f - _S622) / (F32_max((_S621), (0.0000152587890625f)));
        float _S624 = _S617 * _S623;
        float _S625 = _S615 * _S623;
        float _S626 = _S620 * _S623;
        Weights _S627 = Weights_x24init_0(_S497, _S593, F_3, 1.0f, _S613, _S614, _S624, _S625, _S626, _S622, toon_component_0 * _S623, sheen_1, toon_1, _S608, _S609 * _S623);
        coated_0 = _S627;
    }
    else
    {
        coated_0 = _S549;
    }
    return Weights_x24init_0(leaving_0.v_dot_h, leaving_0.refracted, leaving_0.F, leaving_0.reflect_weight, _S549.diffuse_weight, leaving_0.refract_weight, _S549.p_diffuse, leaving_0.p_reflect, leaving_0.p_refract, _S549.p_sheen_velvet, _S549.p_toon, sheen_1, toon_1, coated_0.coat, coated_0.p_coat);
}

__device__ float translucentShare(BSDFMaterial material_7)
{
    float _S628 = rgb_to_greyscale(material_7.translucent);
    float _S629 = rgb_to_greyscale(material_7.albedo);
    float _S630 = _S628 / (_S629 + _S628);
    bool _S631 = _S628 > 0.0f;
    float _S632 = _slang_select(_S631, _S630,0.0f);
    return _S632;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float n_i_dot_v_0, BSDFMaterial material_8, Weights w_0)
{
    float _S633 = translucentShare(material_8);
    float _S634 = w_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S635 = w_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S636 = 1.0f - _S633;
    bool _S637 = n_i_dot_l_0 < 0.0f;
    float _S638 = _slang_select(_S637, _S633,_S636);
    float _S639 = _S635 * _S638;
    bool _S640 = _S633 > 0.0f;
    float _S641 = _slang_select(_S640, _S639,_S634);
    bool _S642 = n_i_dot_v_0 > 0.0f;
    float _S643 = _slang_select(_S642, _S641,0.0f);
    return _S643;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_3, BSDFMaterial material_9, Weights w_1)
{
    float _S644 = translucentShare(material_9);
    bool _S645 = (dot_0(n_i_3, l_0)) < 0.0f;
    float3  _S646 = _slang_select(_S645, material_9.translucent,material_9.albedo);
    float _S647 = 1.0f - _S644;
    float _S648 = _slang_select(_S645, _S644,_S647);
    float3  _S649 = _S646 / make_float3 (_S648);
    bool _S650 = _S644 > 0.0f;
    float3  _S651 = _slang_select(_S650, _S649,material_9.albedo);
    return w_1.diffuse_weight * _S651 / make_float3 (w_1.p_diffuse);
}

__device__ float trowbridgeReitz(float alpha_2, float n_dot_h_0)
{
    float _S652 = alpha_2 * alpha_2;
    float _S653 = (1.0f - n_dot_h_0) * (1.0f + n_dot_h_0) + _S652 * n_dot_h_0 * n_dot_h_0;
    return _S652 / (F32_max((3.14159274101257324f * _S653 * _S653), (1.17549435082228751e-38f)));
}

__device__ float3  anisotropicLocal(float3  w_2, float3  t_12, float3  n_5)
{
    return make_float3 (dot_0(w_2, t_12), dot_0(w_2, cross_0(n_5, t_12)), dot_0(w_2, n_5));
}

__device__ float anisotropicG1(float3  w_3, float2  alphas_1)
{
    float _S654 = (F32_max((w_3.z), (0.0f)));
    return 2.0f * _S654 / (_S654 + length_0(make_float3 (alphas_1.x * w_3.x, alphas_1.y * w_3.y, _S654)));
}

__device__ float anisotropicD(float3  h_1, float2  alphas_2)
{
    float _S655 = alphas_2.x;
    float _S656 = h_1.x / _S655;
    float _S657 = alphas_2.y;
    float _S658 = h_1.y / _S657;
    float _S659 = h_1.z;
    float _S660 = _S656 * _S656 + _S658 * _S658 + _S659 * _S659;
    return 1.0f / (F32_max((3.14159274101257324f * _S655 * _S657 * _S660 * _S660), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float3  v_4, float3  h_2, float3  n_i_4, float n_i_dot_v_1, float alpha_3, AnisotropicFrame frame_2, float v_dot_h_1)
{
    float _S661 = dot_0(n_i_4, h_2);
    float _S662 = smithG1(alpha_3, n_i_dot_v_1);
    float _S663 = _S662 * v_dot_h_1;
    float _S664 = trowbridgeReitz(alpha_3, _S661);
    float _S665 = _S663 * _S664 / n_i_dot_v_1;
    bool _S666 = alpha_3 > 0.0f;
    bool _S667;
    if(_S666)
    {
        _S667 = v_dot_h_1 > 0.0f;
    }
    else
    {
        _S667 = false;
    }
    if(_S667)
    {
        _S667 = _S661 > 0.0f;
    }
    else
    {
        _S667 = false;
    }
    if(_S667)
    {
        _S667 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S667 = false;
    }
    float _S668 = _slang_select(_S667, _S665,0.0f);
    bool _S669 = (frame_2.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S669)
    {
        float3  _S670 = anisotropicLocal(v_4, frame_2.tangent, n_i_4);
        float _S671 = anisotropicG1(_S670, frame_2.alphas);
        float3  _S672 = anisotropicLocal(h_2, frame_2.tangent, n_i_4);
        float _S673 = anisotropicD(_S672, frame_2.alphas);
        float _S674 = _S671 * _S673;
        float _S675 = _S674 * v_dot_h_1 / n_i_dot_v_1;
        bool _S676 = v_dot_h_1 > 0.0f;
        if(_S676)
        {
            _S667 = _S661 > 0.0f;
        }
        else
        {
            _S667 = false;
        }
        if(_S667)
        {
            _S667 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S667 = false;
        }
        float _S677 = _slang_select(_S667, _S675,0.0f);
        pdf_h_0 = _S677;
    }
    else
    {
        pdf_h_0 = _S668;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float l_dot_h_0, float pdf_h_1, Weights w_4, float eta_i_3, float eta_o_2)
{
    float _S678 = eta_i_3 * w_4.v_dot_h + eta_o_2 * l_dot_h_0;
    float _S679 = w_4.p_refract * pdf_h_1 * eta_o_2 * eta_o_2 * (F32_abs((l_dot_h_0))) / (_S678 * _S678);
    bool _S680 = eta_i_3 != eta_o_2;
    bool _S681;
    if(_S680)
    {
        _S681 = l_dot_h_0 < 0.0f;
    }
    else
    {
        _S681 = false;
    }
    float _S682 = _slang_select(_S681, _S679,0.0f);
    return _S682;
}

__device__ float maskingG1(float3  l_1, float3  n_i_5, float side_0, float alpha_4, AnisotropicFrame frame_3)
{
    float _S683 = smithG1(alpha_4, (F32_max((side_0 * dot_0(n_i_5, l_1)), (0.0f))));
    bool _S684 = (frame_3.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S684)
    {
        float3  _S685 = anisotropicLocal(l_1, frame_3.tangent, n_i_5 * make_float3 (side_0));
        float _S686 = anisotropicG1(_S685, frame_3.alphas);
        G1_l_0 = _S686;
    }
    else
    {
        G1_l_0 = _S683;
    }
    return G1_l_0;
}

__device__ __forceinline__ float3  refractBSDF(float G1_l_1, BSDFMaterial material_10, Weights w_5)
{
    return w_5.refract_weight * make_float3 (G1_l_1) * material_10.albedo / make_float3 (w_5.p_refract);
}

__device__ __forceinline__ float reflectPDF(float pdf_h_2, Weights w_6)
{
    float _S687 = w_6.p_reflect * pdf_h_2 / (4.0f * w_6.v_dot_h);
    bool _S688 = pdf_h_2 > 0.0f;
    float _S689 = _slang_select(_S688, _S687,0.0f);
    return _S689;
}

__device__ __forceinline__ float3  reflectBSDF(float G1_l_2, Weights w_7)
{
    return make_float3 (w_7.reflect_weight * G1_l_2) * w_7.F / make_float3 (w_7.p_reflect);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_1, float n_i_dot_v_2, Weights w_8)
{
    float _S690 = w_8.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S691 = n_i_dot_l_1 > 0.0f;
    bool _S692;
    if(_S691)
    {
        _S692 = n_i_dot_v_2 > 0.0f;
    }
    else
    {
        _S692 = false;
    }
    float _S693 = _slang_select(_S692, _S690,0.0f);
    return _S693;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  v_5, float3  n_i_6, BSDFMaterial material_11, Weights w_9)
{
    float3  _S694 = l_2 + v_5;
    float3  _S695 = ((((_S694)) * make_float3(rnorm3df(((_S694)).x, ((_S694)).y, ((_S694)).z))));
    float _S696 = dot_0(n_i_6, _S695);
    float _S697 = (F32_max((dot_0(n_i_6, l_2)), (0.0f)));
    float _S698 = (F32_max((dot_0(n_i_6, v_5)), (0.0f)));
    float _S699 = 1.0f / (F32_max((material_11.sheen_roughness), (0.05000000074505806f)));
    float _S700 = 1.0f - _S696 * _S696;
    float _S701 = (2.0f + _S699) * (F32_pow(((F32_max((_S700), (0.0f)))), (0.5f * _S699))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S697 + _S698 - _S697 * _S698)), (0.0000152587890625f)));
    bool _S702 = (material_11.velvet) > 0.0f;
    float f_1;
    if(_S702)
    {
        float _S703 = (F32_max((material_11.sheen_roughness), (0.00999999977648258f)));
        float _S704 = _S703 * _S703;
        float _S705 = (F32_max((_S700), (0.0000152587890625f)));
        float _S706 = (F32_exp((- _S696 * _S696 / (_S705 * _S704)))) / (3.14159274101257324f * _S704 * _S705 * _S705) * (F32_min((1.0f), (2.0f * _S696 * (F32_min((_S697), (_S698))) / (F32_max(((F32_abs((dot_0(_S695, v_5))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S697 * _S698), (0.0000152587890625f)));
        f_1 = _S706;
    }
    else
    {
        f_1 = _S701;
    }
    return w_9.sheen * make_float3 (f_1 * _S697 * 2.0f * 3.14159274101257324f / w_9.p_sheen_velvet);
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
    float _S707;
    if(t_13 < a_3)
    {
        _S707 = 1.0f;
    }
    else
    {
        _S707 = (F32_max((1.0f - (t_13 - a_3) / (F32_max((s_0), (0.0000152587890625f)))), (0.0f)));
    }
    return _S707;
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
        float _S708 = (F32_sin(((F32_min((t_14), (a_4))))));
        integral_0 = _S708 * _S708 / 2.0f;
    }
    bool _S709 = t_14 > a_4;
    bool _S710;
    if(_S709)
    {
        _S710 = s_1 > 0.0f;
    }
    else
    {
        _S710 = false;
    }
    if(_S710)
    {
        float _S711;
        if(glossy_0)
        {
            float _S712 = (F32_cos((a_4)));
            float _S713 = (F32_cos((t_14)));
            _S711 = (1.0f + a_4 / s_1) * (_S712 - _S713) - ((F32_sin((t_14))) - t_14 * _S713 - ((F32_sin((a_4))) - a_4 * _S712)) / s_1;
        }
        else
        {
            float _S714 = 2.0f * a_4;
            float _S715 = (F32_cos((_S714)));
            float _S716 = 2.0f * t_14;
            float _S717 = (F32_cos((_S716)));
            _S711 = (1.0f + a_4 / s_1) * (_S715 - _S717) / 4.0f - ((F32_sin((_S716))) / 8.0f - t_14 * _S717 / 4.0f - ((F32_sin((_S714))) / 8.0f - a_4 * _S715 / 4.0f)) / s_1;
        }
        float integral_1 = integral_0 + _S711;
        integral_0 = integral_1;
    }
    return integral_0;
}

static __device__ ToonProfile ToonProfile_x24init_0(bool glossy_1, float a_5, float s_2, float b_1, float norm_0, float view_0, float3  axis_0)
{
    ToonProfile _S718;
    (&_S718)->glossy = glossy_1;
    (&_S718)->a = a_5;
    (&_S718)->s = s_2;
    (&_S718)->b = b_1;
    (&_S718)->norm = norm_0;
    (&_S718)->view = view_0;
    (&_S718)->axis = axis_0;
    return _S718;
}

__device__ __forceinline__ ToonProfile toonProfile(float3  v_6, float3  n_i_7, BSDFMaterial material_12)
{
    float _S719 = material_12.toon.x;
    bool _S720 = _S719 < 0.0f;
    float _S721 = clamp_1(material_12.toon.y / _S719, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S722 = clamp_1(material_12.toon.z / _S719, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S723 = (F32_min((_S721 + _S722), (1.57079637050628662f)));
    float _S724 = dot_0(n_i_7, v_6);
    float _S725 = toonP((F32_acos(((F32_min((_S724), (1.0f)))))), _S721, _S722);
    float3  _S726;
    if(_S720)
    {
        float3  _S727 = make_float3 (2.0f * _S724) * n_i_7 - v_6;
        float3  _S728 = ((((_S727)) * make_float3(rnorm3df(((_S727)).x, ((_S727)).y, ((_S727)).z))));
        _S726 = _S728;
    }
    else
    {
        _S726 = n_i_7;
    }
    float _S729 = toonIntegral(_S723, _S721, _S722, _S720);
    return ToonProfile_x24init_0(_S720, _S721, _S722, _S723, 6.28318548202514648f * _S729, _S725, _S726);
}

__device__ __forceinline__ float toonPDF(float3  l_3, float3  n_i_8, ToonProfile profile_1, Weights w_10)
{
    float _S730 = dot_0(n_i_8, l_3);
    float _S731 = dot_0(l_3, profile_1.axis);
    float _S732 = _slang_select(profile_1.glossy, _S731,_S730);
    float _S733 = (F32_acos((clamp_1(_S732, -1.0f, 1.0f))));
    float _S734 = toonP(_S733, profile_1.a, profile_1.s);
    float _S735 = w_10.p_toon * _S734;
    float _S736 = _slang_select(profile_1.glossy, 1.0f,_S730);
    float _S737 = _S735 * _S736 / profile_1.norm;
    bool _S738;
    if(profile_1.glossy)
    {
        _S738 = true;
    }
    else
    {
        _S738 = _S730 > 0.0f;
    }
    float _S739 = _slang_select(_S738, _S737,0.0f);
    return _S739;
}

__device__ __forceinline__ float3  toonBSDF(float3  l_4, float3  n_i_9, ToonProfile profile_2, Weights w_11)
{
    float _S740 = (F32_max((dot_0(n_i_9, l_4)), (0.0f)));
    float _S741 = _slang_select(profile_2.glossy, _S740,profile_2.view);
    return w_11.toon * make_float3 (_S741) / make_float3 (w_11.p_toon);
}

__device__ __forceinline__ float coatPDF(float3  v_7, float3  coat_h_2, CoatFrame coat_frame_3, Weights w_12)
{
    float _S742 = dot_0(coat_frame_3.normal, v_7);
    float _S743 = smithG1(coat_frame_3.alpha, _S742);
    float _S744 = trowbridgeReitz(coat_frame_3.alpha, dot_0(coat_frame_3.normal, coat_h_2));
    float _S745 = _S743 * _S744 / (4.0f * _S742);
    bool _S746 = (coat_frame_3.alpha) > 0.0f;
    float _S747 = _slang_select(_S746, _S745,0.0f);
    return w_12.p_coat * _S747;
}

__device__ __forceinline__ float3  coatBSDF(Weights w_13)
{
    return w_13.coat / make_float3 (w_13.p_coat);
}

__device__ __forceinline__ void BSDF(float3  in_dir_3, float3  out_dir_1, float3  n_6, BSDFMaterial material_13, float eta_i_4, float eta_o_3, bool refracted_2, Facets facets_0, FixedArray<float3 , 6>  * throughputs_0, FixedArray<float, 6>  * pdfs_0)
{
    float3  _S748 = negate_0(in_dir_3);
    float _S749 = dot_0(n_6, _S748);
    float _S750 = sign_0(_S749);
    float3  _S751 = n_6 * make_float3 (_S750);
    float _S752 = dot_0(_S751, out_dir_1);
    float _S753 = material_13.roughness;
    float _S754 = _S753 * _S753;
    AnisotropicFrame _S755 = anisotropicFrame(material_13, _S751);
    SheenProfile _S756 = sheenProfile(_S748, _S751, material_13);
    CoatFrame _S757 = coatFrame(material_13, _S751);
    float3  _S758 = coatSeries(_S757, material_13);
    float _S759 = rgb_to_greyscale(material_13.translucent);
    bool _S760 = _S759 > 0.0f;
    bool _S761 = (dot_0(n_6, out_dir_1) * _S749) < 0.0f;
    bool _S762 = (F32_abs((material_13.toon.x))) > 0.0f;
    float3  _S763 = facets_0.coat_h;
    bool _S764 = (dot_0(_S763, _S763)) > 0.0f;
    bool _S765;
    if(_S760)
    {
        _S765 = _S761;
    }
    else
    {
        _S765 = false;
    }
    bool _S766 = _S765 == refracted_2;
    bool _S767 = !refracted_2;
    if(_S767)
    {
        _S765 = _S762;
    }
    else
    {
        _S765 = false;
    }
    bool _S768;
    if(_S767)
    {
        _S768 = _S764;
    }
    else
    {
        _S768 = false;
    }
    float3  _S769 = negate_0(make_float3 (eta_i_4) * _S748 + make_float3 (eta_o_3) * out_dir_1);
    float3  _S770 = ((((_S769)) * make_float3(rnorm3df(((_S769)).x, ((_S769)).y, ((_S769)).z))));
    float3  _S771 = reflectedHalf(in_dir_3, out_dir_1);
    float _S772 = sign_0(dot_0(_S770, _S751));
    float3  _S773 = _S770 * make_float3 (_S772);
    float3  _S774 = _slang_select(refracted_2, _S773,_S771);
    float3  _S775 = make_float3 (0.0f);
    float3  _S776 = _slang_select(_S768, _S771,_S775);
    Weights _S777 = lobeWeights(in_dir_3, _S748, _S751, facets_0.h, facets_0.coat_h, _S774, _S776, _S755, _S756, _S757, _S758, material_13, eta_i_4, eta_o_3);
    float _S778 = (F32_abs((_S749)));
    float _S779 = diffusePDF(_S752, _S778, material_13, _S777);
    float _S780 = _slang_select(_S766, _S779,0.0f);
    (*pdfs_0)[int(0)] = _S780;
    float3  _S781 = diffuseBSDF(out_dir_1, _S751, material_13, _S777);
    float3  _S782 = _slang_select(_S766, _S781,_S775);
    (*throughputs_0)[int(0)] = _S782;
    float _S783 = vndfPDF(_S748, _S774, _S751, _S778, _S754, _S755, _S777.v_dot_h);
    float _S784 = refractPDF(dot_0(out_dir_1, _S774), _S783, _S777, eta_i_4, eta_o_3);
    float _S785 = _slang_select(refracted_2, _S784,0.0f);
    (*pdfs_0)[int(1)] = _S785;
    float _S786 = maskingG1(out_dir_1, _S751, -1.0f, _S754, _S755);
    float3  _S787 = refractBSDF(_S786, material_13, _S777);
    float3  _S788 = _slang_select(refracted_2, _S787,_S775);
    (*throughputs_0)[int(1)] = _S788;
    float _S789 = reflectPDF(_S783, _S777);
    float _S790 = _slang_select(_S767, _S789,0.0f);
    (*pdfs_0)[int(2)] = _S790;
    float _S791 = maskingG1(out_dir_1, _S751, 1.0f, _S754, _S755);
    float3  _S792 = reflectBSDF(_S791, _S777);
    float3  _S793 = _slang_select(_S767, _S792,_S775);
    (*throughputs_0)[int(2)] = _S793;
    float _S794 = sheenVelvetPDF(_S752, _S778, _S777);
    float _S795 = _slang_select(_S767, _S794,0.0f);
    (*pdfs_0)[int(3)] = _S795;
    float3  _S796 = sheenVelvetBSDF(out_dir_1, _S748, _S751, material_13, _S777);
    float3  _S797 = _slang_select(_S767, _S796,_S775);
    (*throughputs_0)[int(3)] = _S797;
    ToonProfile _S798 = toonProfile(_S748, _S751, material_13);
    float _S799 = toonPDF(out_dir_1, _S751, _S798, _S777);
    float _S800 = _slang_select(_S765, _S799,0.0f);
    (*pdfs_0)[int(4)] = _S800;
    float3  _S801 = toonBSDF(out_dir_1, _S751, _S798, _S777);
    float3  _S802 = _slang_select(_S765, _S801,_S775);
    (*throughputs_0)[int(4)] = _S802;
    float _S803 = coatPDF(_S748, _S776, _S757, _S777);
    float _S804 = _slang_select(_S768, _S803,0.0f);
    (*pdfs_0)[int(5)] = _S804;
    float3  _S805 = coatBSDF(_S777);
    float3  _S806 = _slang_select(_S768, _S805,_S775);
    (*throughputs_0)[int(5)] = _S806;
    return;
}

static __device__ __forceinline__ float3  skyLobes_0(float3  in_dir_4, float3  dir_5, FKSurface * surface_1, BSDFMaterial * material_14, float2  eta_1, bool is_inside_2, Facets * facets_1, float pdf_1, FixedArray<float3 , 6>  * terms_0, FixedArray<float, 6>  * pdfs_1)
{
    bool _S807 = wrongSide_0(is_inside_2, false, dir_5, surface_1->geometry_n);
    BSDF(in_dir_4, dir_5, surface_1->smooth_n, *material_14, eta_1.x, eta_1.y, _S807, *facets_1, terms_0, pdfs_1);
    float3  _S808 = make_float3 (0.0f);
    uint i_9 = 0U;
    float3  f_2 = _S808;
    for(;;)
    {
        if(i_9 < 6U)
        {
        }
        else
        {
            break;
        }
        bool _S809 = ((*pdfs_1)[i_9]) > 0.0f;
        if(_S809)
        {
            float3  _S810 = (*terms_0)[i_9] * make_float3 ((*pdfs_1)[i_9]) / make_float3 ((*pdfs_1)[i_9] + pdf_1);
            (*terms_0)[i_9] = _S810;
            float3  f_3 = f_2 + (*terms_0)[i_9];
            f_2 = f_3;
        }
        uint i_10 = i_9 + 1U;
        i_9 = i_10;
    }
    return f_2;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_6, float3  radiance_0, float3  color_0, uint random_state_2)
{
    SkySample _S811;
    (&_S811)->dir = dir_6;
    (&_S811)->radiance = radiance_0;
    (&_S811)->color = color_0;
    (&_S811)->random_state = random_state_2;
    return _S811;
}

static __device__ __noinline__ float3  skyColor_0(float3  dir_7, FixedArray<float3 , 6>  * terms_1, FixedArray<float, 6>  * pdfs_2, uint depth_1)
{
    float3  _S812 = make_float3 (0.0f);
    bool shaded_0 = false;
    float3  world_0 = _S812;
    uint i_11 = 0U;
    float3  color_1 = _S812;
    for(;;)
    {
        if(i_11 < 6U)
        {
        }
        else
        {
            break;
        }
        bool _S813 = ((*pdfs_2)[i_11]) > 0.0f;
        if(_S813)
        {
            bool _S814 = (fcptWorldReadsPath());
            bool _S815;
            if(_S814)
            {
                _S815 = true;
            }
            else
            {
                _S815 = !shaded_0;
            }
            bool shaded_1;
            float3  world_1;
            if(_S815)
            {
                uint _S816;
                if(i_11 == 3U)
                {
                    _S816 = 4U;
                }
                else
                {
                    if(i_11 == 4U)
                    {
                        _S816 = 6U;
                    }
                    else
                    {
                        if(i_11 == 5U)
                        {
                            _S816 = 5U;
                        }
                        else
                        {
                            _S816 = i_11;
                        }
                    }
                }
                float3  _S817 = (fcptEnvMapSample((dir_7), (depth_1), (_S816)));
                world_1 = _S817;
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
    uint2  _S818 = (fcptEnvironmentCdfSize());
    uint2  _S819 = make_uint2 (1U, 0U);
    uint2  _S820 = _S818 - _S819;
    Random _S821 = draw(init_random_state_0, 6U);
    Random _S822 = draw(init_random_state_0, 2147483654U);
    Random _S823 = draw(init_random_state_0, 7U);
    Random _S824 = draw(init_random_state_0, 2147483655U);
    uint _S825 = _S820.x;
    uint _S826 = searchCDF_0(make_uint2 (_S825, 0U), make_uint2 (0U, 1U), _S820.y, _S821.value);
    uint _S827 = searchCDF_0(make_uint2 (0U, _S826), _S819, _S825, _S822.value);
    float2  _S828 = make_float2 ((float)_S820.x, (float)_S820.y);
    float2  _S829 = (make_float2 (float(_S827), float(_S826)) + make_float2 (_S823.value, _S824.value)) / _S828 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S830 = _S829.y;
    float _S831 = (F32_sin((_S830)));
    float _S832 = _S829.x;
    float3  _S833 = make_float3 (- _S831 * (F32_cos((_S832))), _S831 * (F32_sin((_S832))), (F32_cos((_S830))));
    float _S834 = environmentPdf_0(_S833);
    BSDFMaterial _S835 = pathMaterial(surface_2->material, wavelength_3);
    BSDFMaterial _S836 = _S835;
    FixedArray<float3 , 6>  terms_2;
    FixedArray<float, 6>  pdfs_3;
    float3  _S837 = skyLobes_0(ray_0->unit_direction, _S833, surface_2, &_S836, eta_2, is_inside_3, facets_2, _S834, &terms_2, &pdfs_3);
    bool _S838 = !(_S834 > 0.0f);
    bool _S839;
    if(_S838)
    {
        _S839 = true;
    }
    else
    {
        _S839 = all_1(_S837 == make_float3 (0.0f));
    }
    if(_S839)
    {
        float3  _S840 = make_float3 (0.0f);
        return SkySample_x24init_0(_S833, _S840, _S840, _S824.state);
    }
    bool _S841 = (fcptWorldReadsPath());
    float3  seen_0;
    if(_S841)
    {
        uint _S842 = context_2->depth + 1U;
        FixedArray<float3 , 6>  _S843 = terms_2;
        FixedArray<float, 6>  _S844 = pdfs_3;
        float3  _S845 = skyColor_0(_S833, &_S843, &_S844, _S842);
        seen_0 = _S845;
    }
    else
    {
        seen_0 = _S837;
    }
    float3  _S846 = skyRadiance_0(ray_0->origin, surface_2, is_inside_3, _S833, context_2, _S824.state);
    return SkySample_x24init_0(_S833, _S846, seen_0 * _S846, _S824.state);
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

static __device__ float3  hairLight_0(FKSurface * surface_3, float3  in_dir_5, TreeSample * light_1, bool competing_0)
{
    SampleBSDF _S847 = (fcptConnectHair((surface_3->hair), ((&surface_3->material)->albedo), ((&surface_3->material)->specular_tint), (in_dir_5), (light_1->dir)));
    float3  _S848 = _S847.throughput * make_float3 (_S847.pdf);
    float _S849 = light_1->density;
    float _S850 = 1.0f + _S847.pdf * _S847.pdf / (light_1->density * light_1->density);
    bool _S851;
    if(competing_0)
    {
        _S851 = _S849 > 0.0f;
    }
    else
    {
        _S851 = false;
    }
    float _S852 = _slang_select(_S851, _S850,1.0f);
    return _S848 / make_float3 (_S852) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_8, float3  radiance_1, float density_0, uint random_state_3)
{
    TreeSample _S853;
    (&_S853)->dir = dir_8;
    (&_S853)->radiance = radiance_1;
    (&_S853)->density = density_0;
    (&_S853)->random_state = random_state_3;
    return _S853;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_12, float3  normal_4, float * pick_0, float * probability_3)
{
    float _S854 = importance(first_1, p_12, normal_4);
    float _S855 = importance(second_1, p_12, normal_4);
    float2  _S856 = make_float2 (_S854, _S855);
    bool _S857 = _S854 == 0.0f;
    bool _S858;
    if(_S857)
    {
        _S858 = _S855 == 0.0f;
    }
    else
    {
        _S858 = false;
    }
    if(_S858)
    {
        return 2U;
    }
    float _S859 = _S854 + _S855;
    bool _S860 = _S855 > 0.0f;
    if(_S860)
    {
        _S858 = (*pick_0 * _S859) >= _S854;
    }
    else
    {
        _S858 = false;
    }
    uint _S861 = uint(_S858);
    float _S862 = (F32_min(((*pick_0 * _S859 - float(_S861) * _S854) / _slang_vector_get_element(_S856, _S861)), (0.99999994039535522f)));
    *pick_0 = _S862;
    float _S863 = *probability_3 * (_slang_vector_get_element(_S856, _S861) / _S859);
    *probability_3 = _S863;
    return _S861;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_13, float u1_0, float u2_0)
{
    float3  _S864 = center_1 - p_13;
    float _S865 = radius_1 * radius_1 / dot_0(_S864, _S864);
    float _S866 = u1_0 * _S865 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S865), (0.0f)))))));
    float _S867 = 2.0f * u1_0;
    bool _S868 = _S865 >= 1.0f;
    float _S869 = _slang_select(_S868, _S867,_S866);
    float _S870 = (F32_sqrt(((F32_max((_S869 * (2.0f - _S869)), (0.0f))))));
    float _S871 = 6.28318548202514648f * u2_0;
    float3  _S872 = make_float3 (_S870 * (F32_cos((_S871))), 1.0f - _S869, _S870 * (F32_sin((_S871))));
    float3  _S873 = ((((_S864)) * make_float3(rnorm3df(((_S864)).x, ((_S864)).y, ((_S864)).z))));
    float3  _S874 = tangentToWorld(_S872, _S873);
    return _S874;
}

__device__ float3  pointLightRadiance(float3  color_3, float intensity_0, float radius_2)
{
    return color_3 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S875 = center_2 - ray_1->origin;
    float _S876 = dot_0(_S875, ray_1->unit_direction);
    float _S877 = dot_0(_S875, _S875) - _S876 * _S876;
    float _S878 = radius_3 * radius_3;
    bool _S879 = _S877 > _S878;
    if(_S879)
    {
        return 4.294967296e+09f;
    }
    float _S880 = (F32_sqrt((_S878 - _S877)));
    float _S881 = _S876 - _S880;
    float _S882 = _S876 + _S880;
    bool _S883 = _S881 > 0.0000152587890625f;
    bool _S884;
    if(_S883)
    {
        _S884 = _S881 < max_len_0;
    }
    else
    {
        _S884 = false;
    }
    if(_S884)
    {
        return _S881;
    }
    bool _S885 = _S882 > 0.0000152587890625f;
    if(_S885)
    {
        _S884 = _S882 < max_len_0;
    }
    else
    {
        _S884 = false;
    }
    if(_S884)
    {
        return _S882;
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
    Random _S886 = draw(init_random_state_1, 4U);
    Random _S887 = draw(init_random_state_1, 5U);
    Random _S888 = draw(init_random_state_1, 2147483653U);
    float3  _S889 = make_float3 (0.0f);
    TreeSample _S890 = TreeSample_x24init_0(_S889, _S889, 0.0f, _S888.state);
    TreeSample sample_0 = _S890;
    float3  _S891 = _slang_select(sided_0, _S889,smooth_n_2);
    float3  _S892 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S886.value;
    float probability_4 = 1.0f;
    uint n_7 = 0U;
    for(;;)
    {
        uint4  _S893 = (fcptLightNode((n_7)));
        if((_S893.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S894 = (fcptLightSecond((n_7)));
        uint _S895 = n_7 + 1U;
        LightNode _S896 = (fcptLightBounds((_S895)));
        LightNode _S897 = (fcptLightBounds((_S894)));
        uint _S898 = pickChild(_S896, _S897, origin_4, _S891, &pick_1, &probability_4);
        bool _S899 = _S898 > 1U;
        if(_S899)
        {
            return sample_0;
        }
        bool _S900 = _S898 == 1U;
        uint _S901 = _slang_select(_S900, _S894,_S895);
        n_7 = _S901;
    }
    bool _S902 = n_7 == 0U;
    bool _S903;
    if(_S902)
    {
        LightNode _S904 = (fcptLightBounds((0U)));
        float _S905 = importance(_S904, origin_4, _S891);
        _S903 = !(_S905 > 0.0f);
    }
    else
    {
        _S903 = false;
    }
    if(_S903)
    {
        return sample_0;
    }
    uint4  _S906 = (fcptLightNode((n_7)));
    FKHit _S907 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S908 = (_S906.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S908)
    {
        FKLight _S909 = (fcptLight((_S906.y)));
        if(sided_0)
        {
            float _S910 = sign_0(dot_0(geometry_n_1, _S909.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S910);
            float3  _S911 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S911;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S892;
            lift_n_0 = smooth_n_2;
        }
        bool _S912 = (_S909.variance) == 0.0f;
        if(_S912)
        {
            float3  _S913 = _S909.position - emitter_point_0;
            float3  _S914 = ((((_S913)) * make_float3(rnorm3df(((_S913)).x, ((_S913)).y, ((_S913)).z))));
            (&sample_0)->dir = _S914;
            float3  _S915 = _S909.color * make_float3 (_S909.intensity) / make_float3 (dot_0(_S913, _S913) * probability_4);
            (&sample_0)->radiance = _S915;
            shadow_1 = _S913;
        }
        else
        {
            float3  _S916 = sampleSphere(_S909.position, _S909.variance, emitter_point_0, _S887.value, _S888.value);
            (&sample_0)->dir = _S916;
            float _S917 = sphereDensity(_S909.position, _S909.variance, emitter_point_0);
            float _S918 = probability_4 * _S917;
            (&sample_0)->density = _S918;
            float3  _S919 = pointLightRadiance(_S909.color, _S909.intensity, _S909.variance);
            float3  _S920 = _S919 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S920;
            FKRay _S921 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S922 = raySphere_0(_S909.position, _S909.variance, &_S921, 4.294967296e+09f);
            float3  _S923 = (&sample_0)->dir * make_float3 (_S922);
            shadow_1 = _S923;
        }
        emitter_0 = _S907;
        emitter_point_0 = _S889;
    }
    else
    {
        uint _S924 = _S906.y;
        uint _S925 = (fcptTriangleOffset((_S924)));
        uint _S926 = _S925 + _S906.z;
        Matrix<float, 3, 3>  _S927 = (fcptWorldTriangle((_S924), (_S926)));
        float _S928 = (F32_sqrt((_S887.value)));
        float2  _S929 = make_float2 (_S928 * (1.0f - _S888.value), _S928 * _S888.value);
        float3  _S930 = mul_0(make_float3 (1.0f - _S928, _S929.x, _S929.y), _S927);
        if(sided_0)
        {
            float _S931 = sign_0(dot_0(geometry_n_1, _S930 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S931);
            float3  _S932 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S932;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S933 = !((dot_0(smooth_n_2, _S930 - origin_4)) > 0.0f);
            if(_S933)
            {
                return sample_0;
            }
            emitter_point_0 = _S892;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S929, _S924, _S926, 0U, 0.0f);
        float3  _S934 = _S930 - emitter_point_0;
        float3  _S935 = ((((_S934)) * make_float3(rnorm3df(((_S934)).x, ((_S934)).y, ((_S934)).z))));
        (&sample_0)->dir = _S935;
        float _S936 = solidAngle(probability_4, cross_0(_S927.rows[int(1)] - _S927.rows[int(0)], _S927.rows[int(2)] - _S927.rows[int(0)]), _S934);
        (&sample_0)->density = _S936;
        bool _S937 = (fcptShadowFirst());
        bool _S938 = !_S937;
        if(_S938)
        {
            FKSurface _S939 = (fcptLightSurfaceAt((emitter_1), (_S930), (_S888.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S930 - origin_4))));
            (&sample_0)->random_state = _S939.random_state;
            float3  _S940 = _slang_select(_S939.skip, _S889,_S939.material.emissive);
            float3  _S941 = _S940 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S941;
        }
        shadow_1 = _S934;
        emitter_0 = emitter_1;
        emitter_point_0 = _S930;
    }
    FKHit _S942 = emitter_0;
    float3  _S943 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S888.state, &_S942);
    bool _S944 = (fcptShadowFirst());
    if(_S944)
    {
        _S903 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S903 = false;
    }
    if(_S903)
    {
        _S903 = !all_1(_S943 == _S889);
    }
    else
    {
        _S903 = false;
    }
    if(_S903)
    {
        FKSurface _S945 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S888.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S945.random_state;
        float3  _S946 = _slang_select(_S945.skip, _S889,_S945.material.emissive);
        float3  _S947 = _S946 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S947;
    }
    float3  _S948 = (&sample_0)->radiance * _S943;
    bool _S949 = all_1(_S943 == _S889);
    float3  _S950 = _slang_select(_S949, _S889,_S948);
    (&sample_0)->radiance = _S950;
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
    float _S951 = 1.0f / (1.0f + b_2 / a_6 * (b_2 / a_6));
    bool _S952 = b_2 > 0.0f;
    float _S953 = _slang_select(_S952, _S951,1.0f);
    return _S953;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S954 = vertex_0->none;
    if(_S954)
    {
        return 1.0f;
    }
    uint _S955 = (fcptLightSlot((*hit_1)));
    float _S956 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S955, light_point_1);
    float _S957 = powerHeuristic(vertex_0->pdf, _S956);
    return _S957;
}

struct Vertex
{
    bool rough;
    uint lobe;
    float pdf;
    float cos;
    bool inside;
};

__device__ float3  pathColor(float3  f_4, float3  weight_0, float wavelength_4)
{
    float3  _S958;
    if(wavelength_4 > 0.0f)
    {
        float _S959 = upsample(f_4, wavelength_4);
        _S958 = weight_0 * make_float3 (_S959);
    }
    else
    {
        _S958 = f_4;
    }
    return _S958;
}

__device__ float3  safeDivide(float3  a_7, float3  b_3)
{
    float3  _S960 = a_7 / b_3;
    float3  _S961 = make_float3 (0.0f);
    bool3  _S962 = b_3 == _S961;
    float3  _S963 = _slang_select(_S962, _S961,_S960);
    return _S963;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_2)
{
    uint _S964 = (1U << count_2) - 1U;
    return (e_2 & (~(_S964 << offset_1))) | ((newbits_0 & _S964) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_3, uint end_type_0, uint end_0, float3  f_5)
{
    Reservoir candidate_0 = r_3;
    uint _S965 = insertBits_0(r_3.path, end_0, 0U, 5U);
    uint _S966 = insertBits_0(_S965, end_type_0, 12U, 3U);
    (&candidate_0)->path = _S966;
    (&candidate_0)->f = f_5;
    return candidate_0;
}

static __device__ float3  abs_0(float3  x_16)
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
        *_slang_vector_get_element_ptr(&result_8, i_14) = (F32_abs((_slang_vector_get_element(x_16, i_14))));
        i_14 = i_14 + int(1);
    }
    return result_8;
}

__device__ float resamplingTarget(float3  f_6)
{
    float _S967 = rgb_to_greyscale(abs_0(f_6));
    return _S967;
}

__device__ void offer(Selection * sel_2, Reservoir candidate_1, float3  weight_1)
{
    float _S968 = resamplingTarget(weight_1);
    bool _S969 = _S968 > 0.0f;
    bool _S970;
    if(_S969)
    {
        _S970 = _S968 < 3.00000000549775576e+38f;
    }
    else
    {
        _S970 = false;
    }
    bool _S971 = !_S970;
    if(_S971)
    {
        return;
    }
    bool _S972 = sel_2->sums;
    if(_S972)
    {
        float3  _S973 = sel_2->color + weight_1;
        sel_2->color = _S973;
        return;
    }
    float _S974 = sel_2->w_sum + _S968;
    sel_2->w_sum = _S974;
    float3  _S975 = sel_2->color + weight_1;
    sel_2->color = _S975;
    Random _S976 = pcg(sel_2->random_state);
    sel_2->random_state = _S976.state;
    bool _S977 = (_S976.value * sel_2->w_sum) <= _S968;
    if(_S977)
    {
        sel_2->r = candidate_1;
    }
    return;
}

static __device__ Shift escape_0(Reservoir * r_4, bool replay_1, uint stop_0, uint rc_0, uint end_1, uint end_type_1, float scale_3, uint strata_0, Reservoir * chain_0, float3  chain_throughput_0, uint b_4, FKRay * ray_2, float3  throughput_0, float density_1, Vertex * prev_0, NEEVertex * nee_vertex_0, float sky_pdf_0, float3  spectral_weight_0, float wavelength_5, Selection * sel_3)
{
    Shift _S978 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
    bool _S979 = !nee_vertex_0->none;
    float _S980 = _slang_select(_S979, sky_pdf_0,0.0f);
    float3  _S981 = ray_2->unit_direction;
    float _S982 = escapeWeight_0(_S980, ray_2->unit_direction);
    uint _S983 = prev_0->lobe;
    float3  _S984 = environment_0(_S981, b_4, prev_0->lobe);
    float3  _S985 = pathColor(throughput_0 * _S984, spectral_weight_0, wavelength_5);
    if(replay_1)
    {
        bool _S986 = b_4 == stop_0;
        bool _S987;
        if(_S986)
        {
            _S987 = rc_0 == 3U;
        }
        else
        {
            _S987 = false;
        }
        if(_S987)
        {
            return Shift_x24init_0(_S985 * make_float3 (_S982) / make_float3 (r_4->jac), density_1 / r_4->jac);
        }
        bool _S988 = rc_0 == 0U;
        if(_S988)
        {
            _S987 = end_type_1 == 3U;
        }
        else
        {
            _S987 = false;
        }
        if(_S987)
        {
            _S987 = b_4 == end_1;
        }
        else
        {
            _S987 = false;
        }
        if(_S987)
        {
            _S987 = !prev_0->rough;
        }
        else
        {
            _S987 = false;
        }
        if(_S987)
        {
            return Shift_x24init_0(_S985 * make_float3 (_S982), 1.0f);
        }
        return _S978;
    }
    Reservoir candidate_2 = *chain_0;
    uint _S989 = chain_0->path;
    uint _S990 = extractBits_0(chain_0->path, 10U, 2U);
    bool _S991 = _S990 == 1U;
    if(_S991)
    {
        uint _S992 = extractBits_0(_S989, 5U, 5U);
        bool _S993 = _S992 == b_4;
        float _S994 = _slang_select(_S993, 1.0f,_S982);
        float3  _S995 = safeDivide(_S985 * make_float3 (_S994), chain_throughput_0);
        (&candidate_2)->radiance = _S995;
    }
    else
    {
        bool _S996 = prev_0->rough;
        if(_S996)
        {
            uint _S997 = insertBits_0(strata_0, b_4 + 1U, 5U, 5U);
            uint _S998 = insertBits_0(_S997, 3U, 10U, 2U);
            uint _S999 = insertBits_0(_S998, _S983, 15U, 3U);
            bool _S1000 = prev_0->inside;
            uint _S1001 = _slang_select(_S1000, 1U,0U);
            uint _S1002 = insertBits_0(_S999, _S1001, 22U, 1U);
            (&candidate_2)->path = _S1002;
            (&candidate_2)->jac = prev_0->pdf;
            (&candidate_2)->dir = _S981;
        }
    }
    float3  _S1003 = _S985 * make_float3 (_S982);
    Reservoir _S1004 = withEnd(candidate_2, 3U, b_4, _S1003);
    offer(sel_3, _S1004, _S1003 * make_float3 (scale_3) / make_float3 (density_1));
    return _S978;
}

static __device__ void restir_duplicates_0(uint3  global_invocation_id_1, uint3  local_invocation_id_0, uint local_invocation_index_3)
{
    uint2  _S1005 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S1006 = make_int2 ((int)_S1005.x, (int)_S1005.y);
    uint _S1007 = previousSeed_0(_S1006);
    int y_5 = int(-8);
    uint count_3 = 0U;
    for(;;)
    {
        if(y_5 <= int(8))
        {
        }
        else
        {
            break;
        }
        int x_17 = int(-8);
        for(;;)
        {
            if(x_17 <= int(8))
            {
            }
            else
            {
                break;
            }
            uint _S1008 = previousSeed_0(_S1006 + make_int2 (x_17, y_5));
            bool _S1009 = _S1008 == _S1007;
            uint _S1010 = _slang_select(_S1009, 1U,0U);
            uint count_4 = count_3 + _S1010;
            int x_18 = x_17 + int(1);
            x_17 = x_18;
            count_3 = count_4;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S1011 = float(count_3 - 1U) / 288.0f;
    bool _S1012 = _S1007 != 0U;
    float _S1013 = _slang_select(_S1012, _S1011,0.0f);
    fcptStoreDuplication((_S1006), (make_uint4 ((F32_asuint((_S1013))), 0U, 0U, 0U)));
    return;
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

__device__ void offerShifted(Selection * sel_4, Reservoir r_5, Shift shifted_0, float mis_0)
{
    Reservoir candidate_3 = r_5;
    float3  _S1014 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_3)->f = _S1014;
    float _S1015 = r_5.jac * shifted_0.jac;
    (&candidate_3)->jac = _S1015;
    offer(sel_4, candidate_3, make_float3 (mis_0) * shifted_0.f * make_float3 (r_5.w));
    return;
}

__device__ Reservoir finalize(Selection sel_5, float c_1)
{
    Reservoir r_6 = sel_5.r;
    float _S1016 = resamplingTarget((&r_6)->f);
    float _S1017 = sel_5.w_sum / _S1016;
    bool _S1018 = _S1016 > 0.0f;
    float _S1019 = _slang_select(_S1018, _S1017,0.0f);
    (&r_6)->w = _S1019;
    (&r_6)->c = c_1;
    return r_6;
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
    uint2  _S1020 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S1021 = make_int2 ((int)_S1020.x, (int)_S1020.y);
    float3  _S1022 = make_float3 (0.0f);
    FKHit _S1023 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S1024 = Domain_x24init_0(_S1022, _S1022, &_S1023, 0.0f, 0.0f);
    Domain dom_4 = _S1024;
    bool _S1025 = (fcptCurrentDomain((_S1021), (&dom_4)));
    bool _S1026 = !_S1025;
    if(_S1026)
    {
        Reservoir _S1027 = (Reservoir{});
        fcptStoreReservoirPrevious((_S1021), (_S1027), ((&dom_4)->hit));
        return;
    }
    Reservoir _S1028 = (fcptLoadReservoirTemporal((_S1021)));
    uint t_15 = 0U;
    float count_5 = 0.0f;
    float c_sum_0 = _S1028.c;
    for(;;)
    {
        uint _S1029 = (fcptRestirNeighbours());
        if(t_15 < _S1029)
        {
        }
        else
        {
            break;
        }
        int2  _S1030 = partner_0(_S1021, t_15);
        Domain neighbor_0 = _S1024;
        bool _S1031 = (fcptCurrentDomain((_S1030), (&neighbor_0)));
        if(_S1031)
        {
            float count_6 = count_5 + 1.0f;
            uint4  _S1032 = (fcptReservoirTemporal((_S1030), (0U)));
            float c_sum_1 = c_sum_0 + (U32_asfloat((_S1032.w)));
            count_5 = count_6;
            c_sum_0 = c_sum_1;
        }
        uint t_16 = t_15 + 1U;
        t_15 = t_16;
    }
    float _S1033 = _S1028.c / (F32_max((count_5), (1.0f)));
    float _S1034 = resamplingTarget(_S1028.f);
    bool _S1035 = count_5 == 0.0f;
    float _S1036 = _slang_select(_S1035, 1.0f,0.0f);
    Selection _S1037 = (Selection{});
    Selection sel_6 = _S1037;
    uint _S1038 = (fcptFrame());
    uint _S1039 = hash(_S1038);
    uint _S1040 = global_invocation_id_2.x;
    uint2  _S1041 = (fcptRenderSize());
    uint _S1042 = stream(_S1039, _S1040 + _S1041.x * global_invocation_id_2.y);
    uint _S1043 = stream(_S1042, 195U);
    (&sel_6)->random_state = _S1043;
    t_15 = 0U;
    float canonical_mis_0 = _S1036;
    for(;;)
    {
        uint _S1044 = (fcptRestirNeighbours());
        if(t_15 < _S1044)
        {
        }
        else
        {
            break;
        }
        int2  _S1045 = partner_0(_S1021, t_15);
        Domain neighbor_dom_0 = _S1024;
        bool _S1046 = (fcptCurrentDomain((_S1045), (&neighbor_dom_0)));
        if(_S1046)
        {
            Reservoir _S1047 = (fcptLoadReservoirTemporal((_S1045)));
            uint4  _S1048 = (fcptShiftData((_S1045), (t_15)));
            float4  _S1049 = asfloat_0(_S1048);
            uint4  _S1050 = (fcptShiftData((_S1021), (t_15)));
            float4  _S1051 = asfloat_0(_S1050);
            float _S1052 = (_S1047.c + _S1033) / c_sum_0;
            bool _S1053 = _S1034 > 0.0f;
            float canonical_mis_1;
            if(_S1053)
            {
                float _S1054 = _S1052 * _S1033 * _S1034;
                float _S1055 = _S1033 * _S1034;
                float _S1056 = resamplingTarget(float3 {_S1051.x, _S1051.y, _S1051.z});
                float canonical_mis_2 = canonical_mis_0 + _S1054 / (_S1055 + _S1047.c * _S1056);
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float _S1057 = resamplingTarget(_S1047.f);
            float3  _S1058 = float3 {_S1049.x, _S1049.y, _S1049.z};
            Shift _S1059 = Shift_x24init_0(_S1058, _S1049.w);
            float _S1060 = _S1052 * _S1047.c * _S1057;
            float _S1061 = _S1047.c * _S1057;
            float _S1062 = resamplingTarget(_S1058);
            offerShifted(&sel_6, _S1047, _S1059, _S1060 / (_S1061 + _S1033 * _S1062));
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_17 = t_15 + 1U;
        t_15 = t_17;
    }
    offerShifted(&sel_6, _S1028, Shift_x24init_0(_S1028.f, 1.0f), canonical_mis_0);
    Reservoir _S1063 = finalize(sel_6, c_sum_0);
    fcptStoreReservoirPrevious((_S1021), (_S1063), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S1021), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S1021), (make_float4 ((&sel_6)->color.x, (&sel_6)->color.y, (&sel_6)->color.z, 0.0f)));
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
    uint _S1064 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S1065 = _S1064 != 4294967295U;
    if(_S1065)
    {
        uint2  _S1066 = make_uint2 (_S1064, _S1064 >> 14U) & make_uint2 (16383U);
        int2  _S1067 = make_int2 ((int)_S1066.x, (int)_S1066.y);
        ShiftJob _S1068 = (ShiftJob{});
        ShiftJob shift_job_0 = _S1068;
        Shift _S1069 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S1070 = _S1064 >> 28U;
        bool _S1071 = spatialJob_0(_S1067, _S1070, &shift_job_0, true);
        Shift shifted_1;
        if(_S1071)
        {
            Domain _S1072 = (&shift_job_0)->dom;
            Reservoir _S1073 = (&shift_job_0)->r;
            Shift _S1074 = passShift_0(&_S1072, &_S1073);
            shifted_1 = _S1074;
        }
        else
        {
            shifted_1 = _S1069;
        }
        fcptStoreShiftData((_S1067), (_S1070), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S1075 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S1076 = make_int2 ((int)_S1075.x, (int)_S1075.y);
    FixedArray<uint, 3>  _S1077;
    spatialBins_0(_S1076, &_S1077);
    FixedArray<uint, 3>  _S1078 = _S1077;
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
        bool _S1079 = (_S1078[t_18]) == 40U;
        if(_S1079)
        {
            fcptStoreShiftData((_S1076), (t_18), (make_uint4 (0U)));
        }
        uint t_19 = t_18 + 1U;
        t_18 = t_19;
    }
    FixedArray<uint, 3>  _S1080 = _S1078;
    queueShifts_0(_S1076, &_S1080, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S1081 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S1082 = make_int2 ((int)_S1081.x, (int)_S1081.y);
    FixedArray<uint, 3>  _S1083;
    spatialBins_0(_S1082, &_S1083);
    FixedArray<uint, 3>  _S1084 = _S1083;
    countShifts_0(&_S1084, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S1085 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S1086 = _S1085 != 4294967295U;
    if(_S1086)
    {
        uint2  _S1087 = make_uint2 (_S1085, _S1085 >> 14U) & make_uint2 (16383U);
        int2  _S1088 = make_int2 ((int)_S1087.x, (int)_S1087.y);
        int2  _S1089 = (fcptLoadTemporalNeighbor((_S1088)));
        uint _S1090 = _S1085 >> 28U;
        Shift _S1091 = temporalShiftAt_0(_S1088, _S1089, _S1090);
        fcptStoreTemporalShift((_S1088), (_S1090), (make_uint4 (asuint_1(_S1091.f).x, asuint_1(_S1091.f).y, asuint_1(_S1091.f).z, (F32_asuint((_S1091.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S1092 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S1093 = make_int2 ((int)_S1092.x, (int)_S1092.y);
    FixedArray<uint, 3>  _S1094;
    temporalBins_0(_S1093, &_S1094);
    FixedArray<uint, 3>  _S1095 = _S1094;
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
        bool _S1096 = (_S1095[t_20]) == 40U;
        if(_S1096)
        {
            fcptStoreTemporalShift((_S1093), (t_20), (make_uint4 (0U)));
        }
        uint t_21 = t_20 + 1U;
        t_20 = t_21;
    }
    FixedArray<uint, 3>  _S1097 = _S1095;
    queueShifts_0(_S1093, &_S1097, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S1098 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S1099 = make_int2 ((int)_S1098.x, (int)_S1098.y);
    bool _S1100 = (fcptSceneUnchanged());
    bool _S1101 = !_S1100;
    bool _S1102;
    if(_S1101)
    {
        uint2  _S1103 = (fcptRenderSize());
        int2  _S1104 = make_int2 ((int)_S1103.x, (int)_S1103.y);
        _S1102 = all_0(_S1099 < _S1104);
    }
    else
    {
        _S1102 = false;
    }
    if(_S1102)
    {
        Reservoir _S1105 = (fcptLoadReservoirInitial((_S1099)));
        int2  _S1106 = sampleNeighbor_0(_S1099, _S1105.seed);
        fcptStoreTemporalNeighbor((_S1099), (_S1106));
    }
    FixedArray<uint, 3>  _S1107;
    temporalBins_0(_S1099, &_S1107);
    FixedArray<uint, 3>  _S1108 = _S1107;
    countShifts_0(&_S1108, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_8, float b_5, float t_22)
{
    return a_8 + (b_5 - a_8) * t_22;
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S1109 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S1110 = make_int2 ((int)_S1109.x, (int)_S1109.y);
    float3  _S1111 = make_float3 (0.0f);
    FKHit _S1112 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S1113 = Domain_x24init_0(_S1111, _S1111, &_S1112, 0.0f, 0.0f);
    Domain dom_5 = _S1113;
    bool _S1114 = (fcptCurrentDomain((_S1110), (&dom_5)));
    bool _S1115 = !_S1114;
    if(_S1115)
    {
        Reservoir _S1116 = (Reservoir{});
        fcptStoreReservoirTemporal((_S1110), (_S1116), ((&dom_5)->hit));
        return;
    }
    Reservoir _S1117 = (fcptLoadReservoirInitial((_S1110)));
    bool _S1118 = (fcptTemporalQueued());
    bool _S1119 = (fcptSceneUnchanged());
    bool _S1120;
    if(_S1119)
    {
        _S1120 = true;
    }
    else
    {
        _S1120 = !_S1118;
    }
    int2  _S1121;
    if(_S1120)
    {
        int2  _S1122 = sampleNeighbor_0(_S1110, _S1117.seed);
        _S1121 = _S1122;
    }
    else
    {
        int2  _S1123 = (fcptLoadTemporalNeighbor((_S1110)));
        _S1121 = _S1123;
    }
    bool _S1124 = (_S1121.x) >= int(0);
    Reservoir r_7;
    if(_S1124)
    {
        Reservoir _S1125 = (fcptLoadReservoirPrevious((_S1121)));
        uint4  _S1126 = (fcptDuplication((_S1121)));
        float _S1127 = (U32_asfloat((_S1126.x)));
        uint _S1128 = (fcptRestirDecorrelation());
        bool _S1129 = _S1128 == 1U;
        float _S1130 = _slang_select(_S1129, _S1127,0.0f);
        float _S1131 = interpolate_0(20.0f, 1.0f, (F32_pow((_S1130), (0.10000000149011612f))));
        float _S1132 = (F32_min((_S1125.c), (_S1131)));
        bool _S1133 = (fcptSceneUnchanged());
        float4  _S1134 = make_float4 (_S1125.f.x, _S1125.f.y, _S1125.f.z, 1.0f);
        bool _S1135 = !_S1133;
        if(_S1135)
        {
            _S1120 = _S1118;
        }
        else
        {
            _S1120 = false;
        }
        float4  to_current_0;
        if(_S1120)
        {
            uint4  _S1136 = (fcptTemporalShift((_S1110), (0U)));
            float4  _S1137 = asfloat_0(_S1136);
            to_current_0 = _S1137;
        }
        else
        {
            if(_S1135)
            {
                Shift _S1138 = temporalShiftAt_0(_S1110, _S1121, 0U);
                float4  _S1139 = make_float4 (_S1138.f.x, _S1138.f.y, _S1138.f.z, _S1138.jac);
                to_current_0 = _S1139;
            }
            else
            {
                to_current_0 = _S1134;
            }
        }
        Domain own_1 = _S1113;
        if(_S1133)
        {
            _S1120 = true;
        }
        else
        {
            bool _S1140 = (fcptPreviousScenes());
            bool _S1141 = !_S1140;
            if(_S1141)
            {
                _S1120 = (_S1117.w) > 0.0f;
            }
            else
            {
                _S1120 = false;
            }
            if(_S1120)
            {
                bool _S1142 = (fcptStoredDomainInitial((_S1110), (_S1117.seed), (&own_1)));
                _S1120 = _S1142;
            }
            else
            {
                _S1120 = false;
            }
            if(_S1120)
            {
                Domain _S1143 = (fcptPreviousDomain((_S1121), (_S1117.seed)));
                Domain _S1144 = _S1143;
                Domain _S1145 = own_1;
                bool _S1146 = sameDomain_0(&_S1144, &_S1145);
                _S1120 = _S1146;
            }
            else
            {
                _S1120 = false;
            }
        }
        float4  _S1147 = make_float4 (_S1117.f.x, _S1117.f.y, _S1117.f.z, 1.0f);
        bool _S1148 = !_S1120;
        if(_S1148)
        {
            _S1120 = _S1118;
        }
        else
        {
            _S1120 = false;
        }
        float4  to_previous_0;
        if(_S1120)
        {
            uint4  _S1149 = (fcptTemporalShift((_S1110), (1U)));
            float4  _S1150 = asfloat_0(_S1149);
            to_previous_0 = _S1150;
        }
        else
        {
            if(_S1148)
            {
                Shift _S1151 = temporalShiftAt_0(_S1110, _S1121, 1U);
                float4  _S1152 = make_float4 (_S1151.f.x, _S1151.f.y, _S1151.f.z, _S1151.jac);
                to_previous_0 = _S1152;
            }
            else
            {
                to_previous_0 = _S1147;
            }
        }
        float _S1153 = resamplingTarget(_S1117.f);
        float _S1154 = resamplingTarget(_S1125.f);
        Selection _S1155 = (Selection{});
        Selection sel_7 = _S1155;
        uint _S1156 = (fcptFrame());
        uint _S1157 = hash(_S1156);
        uint _S1158 = global_invocation_id_7.x;
        uint2  _S1159 = (fcptRenderSize());
        uint _S1160 = stream(_S1157, _S1158 + _S1159.x * global_invocation_id_7.y);
        uint _S1161 = stream(_S1160, 194U);
        (&sel_7)->random_state = _S1161;
        float _S1162 = _S1117.c * _S1153;
        float4  _S1163 = to_previous_0;
        float _S1164 = resamplingTarget(float3 {_S1163.x, _S1163.y, _S1163.z});
        float _S1165 = _S1162 / (_S1162 + _S1132 * _S1164);
        float _S1166 = _S1132 * _S1154;
        float4  _S1167 = to_current_0;
        float3  _S1168 = float3 {_S1167.x, _S1167.y, _S1167.z};
        float _S1169 = resamplingTarget(_S1168);
        float _S1170 = _S1166 / (_S1166 + _S1117.c * _S1169);
        float2  _S1171 = make_float2 (_S1165, _S1170);
        offerShifted(&sel_7, _S1117, Shift_x24init_0(_S1117.f, 1.0f), _S1165);
        offerShifted(&sel_7, _S1125, Shift_x24init_0(_S1168, to_current_0.w), _S1170);
        Reservoir _S1172 = finalize(sel_7, _S1117.c + _S1132);
        r_7 = _S1172;
    }
    else
    {
        r_7 = _S1117;
    }
    fcptStoreReservoirTemporal((_S1110), (r_7), ((&dom_5)->hit));
    return;
}

__device__ uint noiseOrigin(uint2  p_14, uint k_1)
{
    uint _S1173 = ((p_14.x) >> 11U) | (((p_14.y) >> 11U) << 4U);
    uint2  _S1174 = noiseOffset(8192U + (k_1 >> 10U) + (_S1173 << 20U));
    uint2  _S1175 = (p_14 + _S1174) & make_uint2 (2047U);
    return ((_S1175.x) | ((_S1175.y) << 11U)) | ((k_1 & 1023U) << 22U);
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S1176 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S1177 = make_int2 ((int)_S1176.x, (int)_S1176.y);
    float3  _S1178 = make_float3 (0.0f);
    float2  _S1179 = make_float2 (0.0f);
    FKHit _S1180 = Hit_x24init_0(_S1179, 0U, 0U, 0U, 0.0f);
    Domain _S1181 = Domain_x24init_0(_S1178, _S1178, &_S1180, 0.0f, 0.0f);
    Domain dom_6 = _S1181;
    bool _S1182 = (fcptCurrentDomain((_S1177), (&dom_6)));
    bool _S1183 = !_S1182;
    if(_S1183)
    {
        Reservoir _S1184 = (Reservoir{});
        fcptStoreReservoirInitial((_S1177), (_S1184), ((&dom_6)->hit));
        return;
    }
    uint _S1185 = (fcptFrame());
    uint _S1186 = hash(_S1185);
    uint _S1187 = global_invocation_id_8.x;
    uint2  _S1188 = (fcptRenderSize());
    uint _S1189 = global_invocation_id_8.y;
    uint _S1190 = stream(_S1186, _S1187 + _S1188.x * _S1189);
    uint2  _S1191 = (fcptRenderSize());
    uint _S1192 = stream(_S1187 + _S1191.x * _S1189, 512U);
    Selection _S1193 = (Selection{});
    Selection initial_0 = _S1193;
    uint _S1194 = stream(_S1190, 193U);
    (&initial_0)->random_state = _S1194;
    bool _S1195 = (fcptRestirUsed());
    bool _S1196 = !_S1195;
    (&initial_0)->sums = _S1196;
    uint _S1197 = stream(_S1190, 0U);
    (&(&initial_0)->r)->seed = _S1197;
    FKHit _S1198 = Hit_x24init_0(_S1179, 4294967295U, 0U, 0U, 0.0f);
    uint _S1199 = (fcptSamples());
    float _S1200 = 1.0f / float(_S1199);
    FKHit hit_2 = _S1198;
    uint i_18 = 0U;
    float3  seen_1 = _S1178;
    for(;;)
    {
        uint _S1201 = (fcptSamples());
        if(i_18 < _S1201)
        {
        }
        else
        {
            break;
        }
        Reservoir _S1202 = (Reservoir{});
        Reservoir r_8 = _S1202;
        uint _S1203 = (fcptFrame());
        uint _S1204 = (fcptSamples());
        uint _S1205 = _S1203 * _S1204 + i_18;
        uint _S1206 = noiseOrigin(_S1176, _S1205);
        (&r_8)->seed = _S1206;
        uint _S1207 = insertBits_0(0U, 1U, 24U, 1U);
        uint _S1208 = insertBits_0(_S1207, (_S1192 + _S1205 * 2654435769U) >> 25U, 25U, 7U);
        (&r_8)->path = _S1208;
        Domain path_0 = _S1181;
        bool _S1209 = (fcptStoredDomainInitial((_S1177), ((&r_8)->seed), (&path_0)));
        bool _S1210 = !_S1209;
        if(_S1210)
        {
            float3  _S1211 = (fcptMissed((_S1177), (path_0), (_S1200)));
            float3  seen_2 = seen_1 + _S1211;
            seen_1 = seen_2;
            uint i_19 = i_18 + 1U;
            i_18 = i_19;
            continue;
        }
        Domain _S1212 = path_0;
        Reservoir _S1213 = r_8;
        Shift _S1214 = passWalk_0(&_S1212, &_S1213, false, _S1200, &initial_0);
        bool _S1215 = ((&(&initial_0)->r)->seed) == ((&r_8)->seed);
        FKHit hit_3;
        if(_S1215)
        {
            FKHit _S1216 = (&path_0)->hit;
            hit_3 = _S1216;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_19 = i_18 + 1U;
        i_18 = i_19;
    }
    uint _S1217 = (fcptSamples());
    float3  seen_3 = seen_1 + (&initial_0)->glow / make_float3 (float(_S1217));
    if((&initial_0)->sums)
    {
        seen_1 = seen_3 + (&initial_0)->color;
    }
    else
    {
        seen_1 = seen_3;
    }
    fcptAddColor((_S1177), (make_float4 (seen_1.x, seen_1.y, seen_1.z, 1.0f)));
    Reservoir _S1218 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S1177), (_S1218), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_2, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S1219;
    (&_S1219)->none = none_0;
    (&_S1219)->pdf = pdf_2;
    (&_S1219)->origin = origin_5;
    (&_S1219)->smooth_n = smooth_n_3;
    (&_S1219)->start = start_6;
    return _S1219;
}

static __device__ Vertex Vertex_x24init_0(bool rough_0, uint lobe_1, float pdf_3, float cos_0, bool inside_0)
{
    Vertex _S1220;
    (&_S1220)->rough = rough_0;
    (&_S1220)->lobe = lobe_1;
    (&_S1220)->pdf = pdf_3;
    (&_S1220)->cos = cos_0;
    (&_S1220)->inside = inside_0;
    return _S1220;
}

__device__ uint noiseAddress(uint origin_6, uint bounce_0)
{
    uint2  _S1221 = make_uint2 (origin_6 & 2047U, (origin_6 >> 11U) & 2047U);
    uint2  _S1222 = noiseOffset(64U + bounce_0 * 17U);
    uint2  _S1223 = (_S1221 + _S1222) & make_uint2 (2047U);
    return ((_S1223.x) | ((_S1223.y) << 11U)) | ((origin_6 >> 22U) << 22U);
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

static __device__ float3  flightWeight_0(float3  scatter_0, float3  extinction_0, float sigma_0, float distance_2, bool scatters_0)
{
    float3  _S1224 = exp_0((make_float3 (sigma_0) - extinction_0) * make_float3 (distance_2));
    float3  _S1225 = scatter_0 * _S1224 / make_float3 (sigma_0);
    float3  _S1226 = _slang_select(scatters_0, _S1225,_S1224);
    return _S1226;
}

static __device__ uint arrivalLobe_0(uint b_6, uint prev_lobe_0)
{
    bool _S1227 = b_6 > 0U;
    uint _S1228 = _slang_select(_S1227, prev_lobe_0,3U);
    return _S1228;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_1, uint depth_2, uint lobe_2, bool surface_4, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S1229;
    (&_S1229)->extinction_behind = extinction_behind_0;
    (&_S1229)->extinction_front = extinction_front_0;
    (&_S1229)->fillings = fillings_0;
    (&_S1229)->side = side_1;
    (&_S1229)->depth = depth_2;
    (&_S1229)->lobe = lobe_2;
    (&_S1229)->surface = surface_4;
    (&_S1229)->length = length_2;
    (&_S1229)->width = width_1;
    (&_S1229)->own = *own_2;
    (&_S1229)->fiber = fiber_0;
    return _S1229;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S1230 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S1230)
    {
        return 0.07957746833562851f;
    }
    float _S1231 = g_0 * g_0;
    return (1.0f - _S1231) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S1231 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float survivalProbability(float3  throughput_1, float density_2)
{
    return (F32_min(((F32_max(((F32_max((throughput_1.x), ((F32_max((throughput_1.y), (throughput_1.z)))))) / density_2), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_4)
{
    Random _S1232 = draw(random_state_4, 11U);
    Random _S1233 = draw(random_state_4, 2147483659U);
    float _S1234 = 1.0f - 2.0f * _S1232.value;
    float _S1235 = (F32_sqrt(((F32_max((1.0f - _S1234 * _S1234), (0.0f))))));
    float _S1236 = 6.28318548202514648f * _S1233.value;
    return make_float3 (_S1235 * (F32_cos((_S1236))), _S1235 * (F32_sin((_S1236))), _S1234);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_9, uint random_state_5, float * pdf_4)
{
    bool _S1237 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1237)
    {
        *pdf_4 = 0.07957746833562851f;
        float3  _S1238 = isotropic_0(random_state_5);
        return _S1238;
    }
    Random _S1239 = draw(random_state_5, 11U);
    Random _S1240 = draw(random_state_5, 2147483659U);
    float _S1241 = g_1 * g_1;
    float _S1242 = 2.0f * g_1;
    float _S1243 = (1.0f - _S1241) / (1.0f - g_1 + _S1242 * _S1239.value);
    float _S1244 = clamp_1((1.0f + _S1241 - _S1243 * _S1243) / _S1242, -1.0f, 1.0f);
    float _S1245 = (F32_sqrt(((F32_max((1.0f - _S1244 * _S1244), (0.0f))))));
    float _S1246 = 6.28318548202514648f * _S1240.value;
    float _S1247 = phaseHG_0(g_1, _S1244);
    *pdf_4 = _S1247;
    float3  _S1248 = tangentToWorld(make_float3 (_S1245 * (F32_cos((_S1246))), _S1244, _S1245 * (F32_sin((_S1246)))), dir_9);
    float3  _S1249 = ((((_S1248)) * make_float3(rnorm3df(((_S1248)).x, ((_S1248)).y, ((_S1248)).z))));
    return _S1249;
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_1, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_1, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_1, float velvet_0, float3  toon_2, float dispersion_0, float coat_2, float coat_roughness_0, float coat_ior_0, float3  coat_tint_0, float3  coat_normal_0)
{
    BSDFMaterial _S1250;
    (&_S1250)->albedo = albedo_1;
    (&_S1250)->emissive = emissive_0;
    (&_S1250)->roughness = roughness_0;
    (&_S1250)->metallic = metallic_0;
    (&_S1250)->transmission = transmission_0;
    (&_S1250)->ior = ior_1;
    (&_S1250)->absorption = absorption_0;
    (&_S1250)->specular_tint = specular_tint_0;
    (&_S1250)->specular_level = specular_level_0;
    (&_S1250)->translucent = translucent_0;
    (&_S1250)->sheen = sheen_2;
    (&_S1250)->sheen_roughness = sheen_roughness_0;
    (&_S1250)->anisotropy = anisotropy_0;
    (&_S1250)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1250)->tangent = tangent_1;
    (&_S1250)->velvet = velvet_0;
    (&_S1250)->toon = toon_2;
    (&_S1250)->dispersion = dispersion_0;
    (&_S1250)->coat = coat_2;
    (&_S1250)->coat_roughness = coat_roughness_0;
    (&_S1250)->coat_ior = coat_ior_0;
    (&_S1250)->coat_tint = coat_tint_0;
    (&_S1250)->coat_normal = coat_normal_0;
    return _S1250;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1251;
    (&_S1251)->scatter = scatter_1;
    (&_S1251)->extinction = extinction_1;
    (&_S1251)->g = g_2;
    return _S1251;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_15, bool skip_0, uint random_state_6, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1252;
    (&_S1252)->smooth_n = smooth_n_4;
    (&_S1252)->geometry_n = geometry_n_2;
    (&_S1252)->geometry_offset = geometry_offset_2;
    (&_S1252)->material = *material_15;
    (&_S1252)->skip = skip_0;
    (&_S1252)->random_state = random_state_6;
    (&_S1252)->coverage = coverage_0;
    (&_S1252)->encloses = encloses_0;
    (&_S1252)->volume = *volume_0;
    (&_S1252)->fills = fills_0;
    (&_S1252)->hair = hair_0;
    return _S1252;
}

static __device__ FKSurface emitting_0(FKSurface * surface_5, bool top_0)
{
    FKSurface lower_0 = *surface_5;
    float3  _S1253 = (&surface_5->material)->emissive;
    float3  _S1254 = make_float3 (0.0f);
    bool _S1255 = !top_0;
    float3  _S1256 = _slang_select(_S1255, _S1254,_S1253);
    (&(&lower_0)->material)->emissive = _S1256;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_6, float u_1)
{
    float _S1257 = surface_6->coverage;
    bool _S1258 = u_1 < _S1257;
    if(_S1258)
    {
        return *surface_6;
    }
    float3  _S1259 = make_float3 (0.0f);
    float3  _S1260 = make_float3 (1.0f);
    BSDFMaterial _S1261 = Material_x24init_0(_S1259, _S1259, 0.0f, 0.0f, 0.0f, 0.0f, _S1259, _S1260, 1.0f, _S1259, _S1259, 0.5f, 0.0f, 0.0f, _S1259, 0.0f, _S1259, 0.0f, 0.0f, 0.02999999932944775f, 1.5f, _S1260, _S1259);
    BSDFMaterial material_16 = _S1261;
    (&material_16)->albedo = _S1260;
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
    bool _S1262 = transmission_1 > 0.0f;
    bool _S1263;
    if(_S1262)
    {
        _S1263 = true;
    }
    else
    {
        _S1263 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1264;
    if(_S1263)
    {
        _S1264 = 1.0f;
    }
    else
    {
        _S1264 = -1.0f;
    }
    return _S1264;
}

static __device__ bool arrivesBehind_0(float3  dir_10, float3  n_8)
{
    return (dot_0(dir_10, n_8)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_7, float3  dir_11)
{
    float3  _S1265 = surface_7->geometry_n;
    float _S1266 = facingSign((&surface_7->material)->transmission, surface_7->geometry_n, dir_11);
    FKSurface faced_0 = *surface_7;
    float3  _S1267 = surface_7->smooth_n * make_float3 (_S1266);
    (&faced_0)->smooth_n = _S1267;
    float3  _S1268 = _S1265 * make_float3 (_S1266);
    (&faced_0)->geometry_n = _S1268;
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
    float3  _S1269 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1269));
}

__device__ bool dispersive(BSDFMaterial material_17)
{
    bool _S1270 = (material_17.dispersion) > 0.0f;
    bool _S1271;
    if(_S1270)
    {
        _S1271 = (material_17.ior) != 1.0f;
    }
    else
    {
        _S1271 = false;
    }
    return _S1271;
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
        uint _S1272 = (low_1 + high_1 + 1U) / 2U;
        bool _S1273 = (WAVELENGTH_CDF_0[_S1272]) <= u_2;
        if(_S1273)
        {
            low_1 = _S1272;
        }
        else
        {
            uint _S1274 = _S1272 - 1U;
            high_1 = _S1274;
        }
    }
    uint _S1275 = low_1;
    float _S1276 = WAVELENGTH_CDF_0[low_1 + 1U] - WAVELENGTH_CDF_0[low_1];
    return make_float2 (0.37999999523162842f + 0.00499999988824129f * (float(low_1) + (u_2 - WAVELENGTH_CDF_0[_S1275]) / _S1276), _S1276 / 0.00499999988824129f);
}

__device__ static const FixedArray<float, 243>  WAVELENGTH_WEIGHTS_0 = { {
    0.00547470012679696f, -0.00465690018609166f, 0.03257500007748604f, 0.00934640038758516f, -0.00796370021998882f, 0.05577300116419792f, 0.01846100017428398f, -0.01579399965703487f, 0.11072999984025955f, 0.0416410006582737f, -0.03577499836683273f, 0.2513900101184845f, 0.09349299967288971f, -0.08071800321340561f, 0.56742000579833984f, 0.1585099995136261f, -0.13764999806880951f, 0.97018998861312866f, 0.30943000316619873f, -0.27083000540733337f, 1.91740000247955322f, 0.55217999219894409f, -0.48754000663757324f, 3.46889996528625488f, 0.95016998052597046f, -0.84802001714706421f, 6.09439992904663086f, 1.42110002040863037f, -1.28929996490478516f, 9.45199966430664062f, 1.73409998416900635f, -1.6062999963760376f, 12.12800025939941406f, 2.08030009269714355f, -1.98810005187988281f, 15.68700027465820312f, 2.20600008964538574f, -2.20120000839233398f, 18.47699928283691406f, 2.03040003776550293f, -2.17700004577636719f, 19.92700004577636719f, 1.63429999351501465f, -2.00340008735656738f, 20.86899948120117188f, 0.99410998821258545f, -1.62629997730255127f, 20.57799911499023438f, 0.20011000335216522f, -1.11409997940063477f, 19.72100067138671875f, -0.67960000038146973f, -0.45403000712394714f, 17.77599906921386719f, -1.61679995059967041f, 0.37860000133514404f, 14.71500015258789062f, -2.53410005569458008f, 1.27540004253387451f, 11.86499977111816406f, -3.39079999923706055f, 2.2146000862121582f, 9.17669963836669922f, -4.03749990463256836f, 3.0522000789642334f, 6.59509992599487305f, -4.61299991607666016f, 3.89779996871948242f, 4.64589977264404297f, -5.43039989471435547f, 5.0121002197265625f, 3.3199000358581543f, -6.37769985198974609f, 6.33809995651245117f, 2.29699993133544922f, -7.44140005111694336f, 7.91739988327026367f, 1.45389997959136963f, -8.38580036163330078f, 9.60109996795654297f, 0.66465997695922852f, -9.0167999267578125f, 11.23999977111816406f, -0.04403600096702576f, -9.17749977111816406f, 12.63199996948242188f, -0.58126997947692871f, -8.97550010681152344f, 13.91499996185302734f, -0.95730000734329224f, -8.25290012359619141f, 14.86200046539306641f, -1.24430000782012939f, -6.92129993438720703f, 15.03899955749511719f, -1.43069994449615479f, -5.29169988632202148f, 14.90900039672851562f, -1.55149996280670166f, -3.43219995498657227f, 14.70499992370605469f, -1.63569998741149902f, -1.27190005779266357f, 14.24400043487548828f, -1.67030000686645508f, 1.15170001983642578f, 13.32199954986572266f, -1.636199951171875f, 3.73889994621276855f, 12.21199989318847656f, -1.56920003890991211f, 6.43590021133422852f, 10.94699954986572266f, -1.47730004787445068f, 9.16440010070800781f, 9.54769992828369141f, -1.36399996280670166f, 12.02000045776367188f, 8.18799972534179688f, -1.25450003147125244f, 14.78699970245361328f, 6.74429988861083984f, -1.13110005855560303f, 16.72299957275390625f, 5.08780002593994141f, -0.96561002731323242f, 18.14299964904785156f, 3.57019996643066406f, -0.80725997686386108f, 19.91900062561035156f, 2.36269998550415039f, -0.69273000955581665f, 21.05500030517578125f, 1.31369996070861816f, -0.58597999811172485f, 21.3899993896484375f, 0.42390000820159912f, -0.48298001289367676f, 20.99300003051757812f, -0.23857000470161438f, -0.39412000775337219f, 19.82200050354003906f, -0.6866300106048584f, -0.31501999497413635f, 18.12000083923339844f, -0.9412500262260437f, -0.24890999495983124f, 15.7089996337890625f, -1.02020001411437988f, -0.19076000154018402f, 13.19799995422363281f, -0.98919999599456787f, -0.14401000738143921f, 11.23999977111816406f, -0.93347001075744629f, -0.11133000254631042f, 9.36649990081787109f, -0.83820998668670654f, -0.08524099737405777f, 7.41249990463256836f, -0.70064002275466919f, -0.06283199787139893f, 5.71229982376098633f, -0.56079000234603882f, -0.04586699977517128f, 4.42280006408691406f, -0.44653001427650452f, -0.03396600112318993f, 3.34489989280700684f, -0.34457001090049744f, -0.02482499927282333f, 2.49309992790222168f, -0.26017999649047852f, -0.01808100007474422f, 1.82239997386932373f, -0.1921599954366684f, -0.01296999957412481f, 1.29499995708465576f, -0.13766999542713165f, -0.00907570030540228f, 0.92928999662399292f, -0.09956400096416473f, -0.00641620019450784f, 0.61835998296737671f, -0.06671299785375595f, -0.00421149982139468f, 0.40211999416351318f, -0.04354599863290787f, -0.00271830009296536f, 0.2844499945640564f, -0.03087200038135052f, -0.00191440002527088f, 0.20672999322414398f, -0.02246100082993507f, -0.00138829997740686f, 0.15044000744819641f, -0.01634499989449978f, -0.00101030000951141f, 0.10942000150680542f, -0.01188699994236231f, -0.0007347899954766f, 0.07099699974060059f, -0.00771349994465709f, -0.00047679000999779f, 0.04539500176906586f, -0.00493190018460155f, -0.00030484999297187f, 0.03424099832773209f, -0.00372010003775358f, -0.00022995000472292f, 0.02557599917054176f, -0.00277870008721948f, -0.00017175999528263f, 0.01842200011014938f, -0.00200140010565519f, -0.0001237099932041f, 0.01316899992525578f, -0.00143079995177686f, -0.00008843900286593f, 0.00838890019804239f, -0.00091141002485529f, -0.00005633700129692f, 0.00537079991772771f, -0.00058350997278467f, -0.00003606799873523f, 0.00328280008397996f, -0.00035665999166667f, -0.00002204600059486f, 0.00196009990759194f, -0.00021296000340953f, -0.00001316300040344f, 0.00168939994182438f, -0.00018354000349063f, -0.00001134499962063f, 0.00141050003003329f, -0.00015325000276789f, -0.00000947250009631f, 0.00097123999148607f, -0.00010551999730524f, -6.52239987175562419e-06f, 0.00066868000430986f, -0.00007264900341397f, -4.49060007667867467e-06f
} };
__device__ float3  wavelengthWeights(float wavelength_6)
{
    float _S1277 = clamp_1((wavelength_6 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    uint _S1278 = (U32_min((uint(_S1277)), (79U)));
    uint _S1279 = 3U * _S1278;
    float3  _S1280 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1279], WAVELENGTH_WEIGHTS_0[_S1279 + 1U], WAVELENGTH_WEIGHTS_0[_S1279 + 2U]);
    float3  _S1281 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1279 + 3U], WAVELENGTH_WEIGHTS_0[_S1279 + 4U], WAVELENGTH_WEIGHTS_0[_S1279 + 5U]);
    return _S1280 + (_S1281 - _S1280) * make_float3 (_S1277 - float(_S1278));
}

__device__ float dispersedIor(float ior_2, float dispersion_1, float wavelength_7)
{
    float _S1282 = (ior_2 - 1.0f) * dispersion_1 / 1.90962409973144531f;
    float _S1283 = _S1282 * (1.0f / (wavelength_7 * wavelength_7) - 2.89662933349609375f);
    bool _S1284 = dispersion_1 > 0.0f;
    float _S1285 = _slang_select(_S1284, _S1283,0.0f);
    return ior_2 + _S1285;
}

__device__ float2  vertexEta(BSDFMaterial material_18, float n_dot_v_0)
{
    bool _S1286 = n_dot_v_0 < 0.0f;
    float _S1287 = _slang_select(_S1286, material_18.ior,1.0f);
    float _S1288 = _slang_select(_S1286, 1.0f,material_18.ior);
    return make_float2 (_S1287, _S1288);
}

__device__ float2  wavelengthEta(BSDFMaterial material_19, float n_dot_v_1, float wavelength_8)
{
    BSDFMaterial refractive_0 = material_19;
    float _S1289 = dispersedIor(material_19.ior, material_19.dispersion, wavelength_8);
    bool _S1290 = wavelength_8 > 0.0f;
    float _S1291 = _slang_select(_S1290, _S1289,material_19.ior);
    (&refractive_0)->ior = _S1291;
    float2  _S1292 = vertexEta(refractive_0, n_dot_v_1);
    return _S1292;
}

static __device__ float unshared_0(float x_25)
{
    return x_25;
}

__device__ float3  sampleGGXVNDF(float3  Ve_0, float alpha_5, float U1_0, float U2_0)
{
    float3  _S1293 = make_float3 (alpha_5 * Ve_0.x, alpha_5 * Ve_0.y, Ve_0.z);
    float3  _S1294 = ((((_S1293)) * make_float3(rnorm3df(((_S1293)).x, ((_S1293)).y, ((_S1293)).z))));
    float _S1295 = _S1294.x;
    float _S1296 = _S1294.y;
    float _S1297 = _S1295 * _S1295 + _S1296 * _S1296;
    float3  _S1298;
    if(_S1297 > 0.0f)
    {
        float3  _S1299 = make_float3 (- _S1296, _S1295, 0.0f);
        float _S1300 = (rsqrtf((_S1297)));
        _S1298 = _S1299 * make_float3 (_S1300);
    }
    else
    {
        _S1298 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S1301 = cross_0(_S1294, _S1298);
    float _S1302 = (F32_sqrt((U1_0)));
    float _S1303 = 6.28318548202514648f * U2_0;
    float _S1304 = _S1302 * (F32_cos((_S1303)));
    float t2_0 = _S1302 * (F32_sin((_S1303)));
    float _S1305 = 0.5f * (1.0f + _S1294.z);
    float t2_1 = (1.0f - _S1305) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S1304 * _S1304)))))) + _S1305 * t2_0;
    float3  _S1306 = make_float3 (_S1304) * _S1298 + make_float3 (t2_1) * _S1301;
    float _S1307 = unshared_0(_S1304);
    float _S1308 = unshared_0(_S1304);
    float3  _S1309 = _S1306 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S1307 * _S1308 - t2_1 * t2_1))))))) * _S1294;
    float3  _S1310 = make_float3 (alpha_5 * _S1309.x, alpha_5 * _S1309.y, (F32_max((0.0f), (_S1309.z))));
    float3  _S1311 = ((((_S1310)) * make_float3(rnorm3df(((_S1310)).x, ((_S1310)).y, ((_S1310)).z))));
    return _S1311;
}

__device__ float3  worldToTangent(float3  v_8, float3  n_9)
{
    float3  a_9 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S1312 = (F32_abs((dot_0(n_9, a_9)))) > 0.9999847412109375f;
    float3  a_10;
    if(_S1312)
    {
        float3  _S1313 = make_float3 (1.0f, 0.0f, 0.0f);
        a_10 = _S1313;
    }
    else
    {
        a_10 = a_9;
    }
    float3  _S1314 = cross_0(n_9, a_10);
    float3  _S1315 = ((((_S1314)) * make_float3(rnorm3df(((_S1314)).x, ((_S1314)).y, ((_S1314)).z))));
    float3  _S1316 = cross_0(n_9, _S1315);
    return make_float3 (dot_0(v_8, _S1315), dot_0(v_8, n_9), dot_0(v_8, _S1316));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_9, float3  n_i_10, float alpha_6, AnisotropicFrame frame_4, uint * random_state_7, uint first_2)
{
    Random _S1317 = draw(*random_state_7, first_2);
    Random _S1318 = draw(*random_state_7, first_2 | 2147483648U);
    *random_state_7 = _S1318.state;
    float _S1319 = frame_4.alphas.x;
    bool _S1320 = _S1319 > 0.0f;
    if(_S1320)
    {
        float3  _S1321 = anisotropicLocal(v_9, frame_4.tangent, n_i_10);
        float _S1322 = frame_4.alphas.y;
        float3  _S1323 = make_float3 (_S1319 * _S1321.x, _S1322 * _S1321.y, _S1321.z);
        float3  _S1324 = ((((_S1323)) * make_float3(rnorm3df(((_S1323)).x, ((_S1323)).y, ((_S1323)).z))));
        float3  _S1325 = sampleGGXVNDF(_S1324, 1.0f, _S1317.value, _S1318.value);
        float3  _S1326 = make_float3 (_S1319 * _S1325.x, _S1322 * _S1325.y, _S1325.z);
        float3  _S1327 = ((((_S1326)) * make_float3(rnorm3df(((_S1326)).x, ((_S1326)).y, ((_S1326)).z))));
        return make_float3 (_S1327.x) * frame_4.tangent + make_float3 (_S1327.y) * cross_0(n_i_10, frame_4.tangent) + make_float3 (_S1327.z) * n_i_10;
    }
    float3  _S1328 = worldToTangent(v_9, n_i_10);
    float3  _S1329 = sampleGGXVNDF(float3 {_S1328.x, _S1328.z, _S1328.y}, alpha_6, _S1317.value, _S1318.value);
    float3  _S1330 = float3 {_S1329.x, _S1329.z, _S1329.y};
    float3  _S1331 = tangentToWorld(_S1330, n_i_10);
    return _S1331;
}

__device__ __forceinline__ float3  coatHalf(float3  v_10, CoatFrame coat_frame_4, uint random_state_8)
{
    bool _S1332 = !((dot_0(coat_frame_4.normal, v_10)) > 0.0f);
    if(_S1332)
    {
        return make_float3 (0.0f);
    }
    uint state_2 = random_state_8;
    float3  _S1333 = sampleHalfVector(v_10, coat_frame_4.normal, coat_frame_4.alpha, AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f)), &state_2, 1U);
    return _S1333;
}

static __device__ Facets Facets_x24init_0(float3  h_3, float3  coat_h_3)
{
    Facets _S1334;
    (&_S1334)->h = h_3;
    (&_S1334)->coat_h = coat_h_3;
    return _S1334;
}

__device__ Facets drawFacets(float3  in_dir_6, float3  n_10, BSDFMaterial material_20, uint random_state_9)
{
    float3  _S1335 = negate_0(in_dir_6);
    float _S1336 = sign_0(dot_0(n_10, _S1335));
    float3  _S1337 = n_10 * make_float3 (_S1336);
    uint state_3 = random_state_9;
    float _S1338 = material_20.roughness;
    float _S1339 = _S1338 * _S1338;
    AnisotropicFrame _S1340 = anisotropicFrame(material_20, _S1337);
    float3  _S1341 = sampleHalfVector(_S1335, _S1337, _S1339, _S1340, &state_3, 0U);
    CoatFrame _S1342 = coatFrame(material_20, _S1337);
    float3  _S1343 = coatHalf(_S1335, _S1342, random_state_9);
    return Facets_x24init_0(_S1341, _S1343);
}

__device__ bool neeDecision(BSDFMaterial material_21, float n_dot_v_2, float eta_i_5, float eta_o_4)
{
    float _S1344 = fresnel((F32_abs((n_dot_v_2))), eta_i_5, eta_o_4);
    float3  _S1345 = mix_0(make_float3 (_S1344), material_21.albedo, material_21.metallic);
    float _S1346 = rgb_to_greyscale(_S1345);
    float _S1347 = (F32_max(((1.0f - _S1346) * (1.0f - material_21.metallic) * (1.0f - material_21.transmission)), (0.0f)));
    bool _S1348 = _S1347 > 0.03999999910593033f;
    bool _S1349;
    if(_S1348)
    {
        _S1349 = true;
    }
    else
    {
        _S1349 = (material_21.roughness) > 0.20000000298023224f;
    }
    return _S1349;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_22)
{
    float _S1350 = rgb_to_greyscale(material_22->translucent);
    return _S1350 > 0.0f;
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
    MediumSides _S1351;
    (&_S1351)->behind = *behind_1;
    (&_S1351)->front = *front_0;
    (&_S1351)->fillings = fillings_1;
    (&_S1351)->face = face_1;
    return _S1351;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_8, FKMedium * medium_0, uint filling_0, float3  dir_12, FKMedium * outside_0)
{
    float3  _S1352 = surface_8->geometry_n;
    MediumSides _S1353 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_8->geometry_n);
    MediumSides sides_0 = _S1353;
    bool _S1354 = surface_8->encloses;
    if(_S1354)
    {
        (&sides_0)->behind = surface_8->volume;
        *&((&(&sides_0)->fillings)->x) = surface_8->fills;
        bool _S1355 = (dot_0(dir_12, _S1352)) > 0.0f;
        if(_S1355)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_9, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_13, uint depth_3, uint lobe_3, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1356 = surface_9->geometry_n;
    ShadowContext _S1357 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_9->geometry_n, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
    bool _S1358 = surface_9->encloses;
    ShadowContext context_4;
    if(_S1358)
    {
        FKSurface faced_1 = *surface_9;
        float3  _S1359 = - _S1356;
        float3  _S1360 = _slang_select(turned_0, _S1359,_S1356);
        (&faced_1)->geometry_n = _S1360;
        FKMedium _S1361 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1362 = faced_1;
        FKMedium _S1363 = _S1361;
        MediumSides _S1364 = mediumSides_0(&_S1362, &_S1363, filling_1, dir_13, outside_1);
        ShadowContext _S1365 = ShadowContext_x24init_0(_S1364.behind.extinction, _S1364.front.extinction, _S1364.fillings, _S1356, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
        if(turned_0)
        {
            uint2  _S1366 = _S1364.fillings;
            ShadowContext _S1367 = ShadowContext_x24init_0(_S1364.front.extinction, _S1364.behind.extinction, uint2 {_S1366.y, _S1366.x}, _S1356, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
            context_4 = _S1367;
        }
        else
        {
            context_4 = _S1365;
        }
    }
    else
    {
        context_4 = _S1357;
    }
    return context_4;
}

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_7, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_3, BSDFMaterial * material_23, float eta_i_6, float eta_o_5, bool competing_1, Facets * facets_3)
{
    float3  _S1368 = light_2->dir;
    bool _S1369 = (dot_0(geometry_n_3, - in_dir_7) * dot_0(geometry_n_3, light_2->dir)) <= 0.0f;
    FixedArray<float3 , 6>  throughputs_1;
    FixedArray<float, 6>  pdfs_4;
    BSDF(in_dir_7, _S1368, smooth_n_5, *material_23, eta_i_6, eta_o_5, _S1369, *facets_3, &throughputs_1, &pdfs_4);
    bool _S1370;
    if(competing_1)
    {
        _S1370 = (light_2->density) != 0.0f;
    }
    else
    {
        _S1370 = false;
    }
    float3  _S1371 = make_float3 (0.0f);
    uint i_23 = 0U;
    float3  f_7 = _S1371;
    for(;;)
    {
        if(i_23 < 6U)
        {
        }
        else
        {
            break;
        }
        bool _S1372 = (pdfs_4[i_23]) > 0.0f;
        if(_S1372)
        {
            float3  f_8;
            if(_S1370)
            {
                float _S1373 = light_2->density;
                float _S1374 = pdfs_4[i_23] / light_2->density;
                float3  f_9 = f_7 + throughputs_1[i_23] * make_float3 (pdfs_4[i_23]) / make_float3 (_S1373 * (1.0f + _S1374 * _S1374));
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
    if(_S1370)
    {
        f_7 = f_7 * light_2->radiance * make_float3 (light_2->density);
    }
    else
    {
        f_7 = f_7 * light_2->radiance;
    }
    return f_7;
}

__device__ float3  skyBSDF(float3  in_dir_8, float3  dir_14, FKSurface surface_10, BSDFMaterial material_24, float2  eta_3, bool is_inside_4, Facets facets_4, float pdf_5)
{
    FKSurface _S1375 = surface_10;
    BSDFMaterial _S1376 = material_24;
    Facets _S1377 = facets_4;
    FixedArray<float3 , 6>  terms_3;
    FixedArray<float, 6>  pdfs_5;
    float3  _S1378 = skyLobes_0(in_dir_8, dir_14, &_S1375, &_S1376, eta_3, is_inside_4, &_S1377, pdf_5, &terms_3, &pdfs_5);
    return _S1378;
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_2, uint random_state_10, bool refracted_3, uint lobe_4, float pdf_6)
{
    SampleBSDF _S1379;
    (&_S1379)->unit_direction = unit_direction_1;
    (&_S1379)->throughput = throughput_2;
    (&_S1379)->random_state = random_state_10;
    (&_S1379)->refracted = refracted_3;
    (&_S1379)->lobe = lobe_4;
    (&_S1379)->pdf = pdf_6;
    return _S1379;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  v_11, float3  n_i_11, float n_i_dot_v_3, BSDFMaterial material_25, Weights w_14, uint random_state_11)
{
    Random _S1380 = draw(random_state_11, 3U);
    Random _S1381 = draw(random_state_11, 2147483651U);
    float _S1382 = _S1380.value;
    float _S1383 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1382 * _S1382))))));
    float _S1384 = 6.28318548202514648f * _S1381.value;
    float3  _S1385 = tangentToWorld(make_float3 (_S1383 * (F32_cos((_S1384))), _S1380.value, _S1383 * (F32_sin((_S1384)))), n_i_11);
    float3  _S1386 = sheenVelvetBSDF(_S1385, v_11, n_i_11, material_25, w_14);
    float _S1387 = sheenVelvetPDF(_S1380.value, n_i_dot_v_3, w_14);
    return SampleBSDF_x24init_0(_S1385, _S1386, _S1381.state, false, 4U, _S1387);
}

__device__ __forceinline__ SampleBSDF coatSample(float3  in_dir_9, float3  v_12, float3  coat_h_4, CoatFrame coat_frame_5, Weights w_15, uint random_state_12)
{
    float3  _S1388 = reflect_0(in_dir_9, coat_h_4);
    float3  _S1389 = ((((_S1388)) * make_float3(rnorm3df(((_S1388)).x, ((_S1388)).y, ((_S1388)).z))));
    float3  _S1390 = coatBSDF(w_15);
    float _S1391 = coatPDF(v_12, coat_h_4, coat_frame_5, w_15);
    return SampleBSDF_x24init_0(_S1389, _S1390, random_state_12, false, 5U, _S1391);
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1392 = (F32_sqrt((random_1_0)));
    float _S1393 = 6.28318548202514648f * random_2_0;
    float _S1394 = _S1392 * (F32_cos((_S1393)));
    float _S1395 = _S1392 * (F32_sin((_S1393)));
    float _S1396 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1394 * _S1394 - _S1395 * _S1395))))));
    return make_float3 (_S1394, _S1396, _S1395);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_3, float3  n_i_12, float n_i_dot_v_4, BSDFMaterial material_26, Weights w_16, uint random_state_13)
{
    Random _S1397 = draw(random_state_13, 3U);
    Random _S1398 = draw(random_state_13, 2147483651U);
    float3  _S1399 = sampleCosWeightedHemisphere(_S1397.value, _S1398.value);
    float _S1400 = translucentShare(material_26);
    bool _S1401 = u_3 < (w_16.p_diffuse * _S1400);
    float _S1402 = _S1399.y;
    float _S1403 = - _S1402;
    float _S1404 = _slang_select(_S1401, _S1403,_S1402);
    float3  _S1405 = tangentToWorld(make_float3 (_S1399.x, _S1404, _S1399.z), n_i_12);
    float3  _S1406 = diffuseBSDF(_S1405, n_i_12, material_26, w_16);
    float _S1407 = diffusePDF(_S1404, n_i_dot_v_4, material_26, w_16);
    return SampleBSDF_x24init_0(_S1405, _S1406, _S1398.state, _S1401, 0U, _S1407);
}

__device__ __forceinline__ SampleBSDF toonSample(float3  n_i_13, ToonProfile profile_3, Weights w_17, uint random_state_14)
{
    Random _S1408 = draw(random_state_14, 3U);
    Random _S1409 = draw(random_state_14, 2147483651U);
    float _S1410 = _S1408.value * profile_3.norm / 6.28318548202514648f;
    float t_23;
    if(profile_3.glossy)
    {
        t_23 = (F32_acos((clamp_1(1.0f - _S1410, -1.0f, 1.0f))));
    }
    else
    {
        t_23 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1410)))), (1.0f))))));
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
        float _S1411 = toonP(t_23, profile_3.a, profile_3.s);
        float _S1412 = _S1411 * (F32_sin((t_23)));
        float _S1413;
        if(profile_3.glossy)
        {
            _S1413 = 1.0f;
        }
        else
        {
            _S1413 = (F32_cos((t_23)));
        }
        float _S1414 = _S1412 * _S1413;
        float _S1415 = toonIntegral(t_23, profile_3.a, profile_3.s, profile_3.glossy);
        float _S1416 = (_S1415 - _S1410) / _S1414;
        bool _S1417 = _S1414 > 0.0f;
        float _S1418 = _slang_select(_S1417, _S1416,0.0f);
        float _S1419 = clamp_1(t_23 - _S1418, 0.0f, profile_3.b);
        int k_3 = k_2 + int(1);
        t_23 = _S1419;
        k_2 = k_3;
    }
    float _S1420 = 6.28318548202514648f * _S1409.value;
    float _S1421 = (F32_sin((t_23)));
    float3  _S1422 = tangentToWorld(make_float3 (_S1421 * (F32_cos((_S1420))), (F32_cos((t_23))), _S1421 * (F32_sin((_S1420)))), profile_3.axis);
    float3  _S1423 = toonBSDF(_S1422, n_i_13, profile_3, w_17);
    bool _S1424 = (dot_0(n_i_13, _S1422)) < 0.0f;
    float _S1425 = toonPDF(_S1422, n_i_13, profile_3, w_17);
    return SampleBSDF_x24init_0(_S1422, _S1423, _S1409.state, _S1424, 6U, _S1425);
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_1, float3  n_i_14, float alpha_7, AnisotropicFrame frame_5, BSDFMaterial material_27, Weights w_18, float pdf_h_3, float eta_i_7, float eta_o_6, uint random_state_15)
{
    float _S1426 = maskingG1(w_18.refracted, n_i_14, -1.0f, alpha_7, frame_5);
    float3  _S1427 = refractBSDF(_S1426, material_27, w_18);
    float _S1428 = refractPDF(dot_0(w_18.refracted, ggx_n_1), pdf_h_3, w_18, eta_i_7, eta_o_6);
    return SampleBSDF_x24init_0(w_18.refracted, _S1427, random_state_15, true, 1U, _S1428);
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_10, float3  ggx_n_2, float3  n_i_15, float alpha_8, AnisotropicFrame frame_6, Weights w_19, float pdf_h_4, uint random_state_16)
{
    float3  _S1429 = reflect_0(in_dir_10, ggx_n_2);
    float3  _S1430 = ((((_S1429)) * make_float3(rnorm3df(((_S1429)).x, ((_S1429)).y, ((_S1429)).z))));
    float _S1431 = maskingG1(_S1430, n_i_15, 1.0f, alpha_8, frame_6);
    float3  _S1432 = reflectBSDF(_S1431, w_19);
    float _S1433 = reflectPDF(pdf_h_4, w_19);
    return SampleBSDF_x24init_0(_S1430, _S1432, random_state_16, false, 2U, _S1433);
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_11, float3  n_11, BSDFMaterial material_28, float eta_i_8, float eta_o_7, Facets facets_5, uint random_init_0, float2  screen_space_0)
{
    float3  _S1434 = negate_0(in_dir_11);
    float _S1435 = dot_0(n_11, _S1434);
    float _S1436 = sign_0(_S1435);
    float3  n_i_16 = n_11 * make_float3 (_S1436);
    float _S1437 = (F32_abs((_S1435)));
    float _S1438 = material_28.roughness;
    float _S1439 = _S1438 * _S1438;
    AnisotropicFrame _S1440 = anisotropicFrame(material_28, n_i_16);
    SheenProfile _S1441 = sheenProfile(_S1434, n_i_16, material_28);
    CoatFrame _S1442 = coatFrame(material_28, n_i_16);
    float3  _S1443 = coatSeries(_S1442, material_28);
    Weights _S1444 = lobeWeights(in_dir_11, _S1434, n_i_16, facets_5.h, facets_5.coat_h, facets_5.h, facets_5.coat_h, _S1440, _S1441, _S1442, _S1443, material_28, eta_i_8, eta_o_7);
    Random _S1445 = draw(random_init_0, 2U);
    bool _S1446 = (_S1445.value) < (_S1444.p_sheen_velvet);
    if(_S1446)
    {
        SampleBSDF _S1447 = sheenVelvetSample(_S1434, n_i_16, _S1437, material_28, _S1444, _S1445.state);
        return _S1447;
    }
    float _S1448 = _S1445.value - _S1444.p_sheen_velvet;
    bool _S1449 = _S1448 < (_S1444.p_coat);
    if(_S1449)
    {
        SampleBSDF _S1450 = coatSample(in_dir_11, _S1434, facets_5.coat_h, _S1442, _S1444, _S1445.state);
        return _S1450;
    }
    float _S1451 = _S1448 - _S1444.p_coat;
    bool _S1452 = _S1451 < (_S1444.p_diffuse);
    if(_S1452)
    {
        SampleBSDF _S1453 = diffuseSample(_S1451, n_i_16, _S1437, material_28, _S1444, _S1445.state);
        return _S1453;
    }
    bool _S1454 = _S1451 < (_S1444.p_diffuse + _S1444.p_toon);
    if(_S1454)
    {
        ToonProfile _S1455 = toonProfile(_S1434, n_i_16, material_28);
        SampleBSDF _S1456 = toonSample(n_i_16, _S1455, _S1444, _S1445.state);
        return _S1456;
    }
    float _S1457 = vndfPDF(_S1434, facets_5.h, n_i_16, _S1437, _S1439, _S1440, _S1444.v_dot_h);
    bool _S1458 = (_S1451 - _S1444.p_toon) < (_S1444.p_diffuse + _S1444.p_refract);
    if(_S1458)
    {
        SampleBSDF _S1459 = refractSample(facets_5.h, n_i_16, _S1439, _S1440, material_28, _S1444, _S1457, eta_i_8, eta_o_7, _S1445.state);
        return _S1459;
    }
    SampleBSDF _S1460 = reflectSample(in_dir_11, facets_5.h, n_i_16, _S1439, _S1440, _S1444, _S1457, _S1445.state);
    return _S1460;
}

__device__ __forceinline__ float3  refractedHalf(float3  in_dir_12, float3  out_dir_2, float3  n_12, float eta_i_9, float eta_o_8)
{
    float3  _S1461 = negate_0(in_dir_12);
    float3  _S1462 = negate_0(make_float3 (eta_i_9) * _S1461 + make_float3 (eta_o_8) * out_dir_2);
    float3  _S1463 = ((((_S1462)) * make_float3(rnorm3df(((_S1462)).x, ((_S1462)).y, ((_S1462)).z))));
    float _S1464 = sign_0(dot_0(n_12, _S1461));
    float _S1465 = sign_0(dot_0(_S1462, n_12 * make_float3 (_S1464)));
    return _S1463 * make_float3 (_S1465);
}

static __device__ bool boundsVolume_0(FKSurface * surface_11)
{
    return surface_11->encloses;
}

static __device__ Shift walk_0(Domain * dom_7, Reservoir * r_9, bool replay_2, float scale_4, Selection * sel_8)
{
    float spread_1;
    bool turned_1;
    bool is_inside_5;
    bool viewed_0;
    bool _S1466;
    bool _S1467;
    float density_3;
    float wavelength_9;
    float width_3;
    float sky_pdf_1;
    float threshold_0;
    uint b_7;
    uint layer_0;
    float3  throughput_3;
    float3  spectral_weight_1;
    TreeSample light_3;
    int _S1468;
    Shift ended_0;
    float density_4;
    float spread_2;
    float width_4;
    float sky_pdf_2;
    float spread_3;
    float width_5;
    uint b_8;
    float3  _S1469 = make_float3 (0.0f);
    Shift _S1470 = Shift_x24init_0(_S1469, 0.0f);
    uint _S1471 = r_9->path;
    uint _S1472 = extractBits_0(r_9->path, 0U, 5U);
    uint _S1473 = extractBits_0(_S1471, 5U, 5U);
    uint _S1474 = extractBits_0(_S1471, 10U, 2U);
    uint _S1475 = extractBits_0(_S1471, 12U, 3U);
    bool passes_0;
    if(replay_2)
    {
        bool _S1476 = _S1475 >= 3U;
        uint _S1477 = _slang_select(_S1476, 1U,0U);
        uint _S1478 = _S1472 + _S1477;
        uint _S1479 = (fcptMaxBounces());
        passes_0 = _S1478 > _S1479;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1470;
    }
    uint _S1480 = _S1473 - 1U;
    bool _S1481 = _S1475 == 3U;
    uint _S1482 = _slang_select(_S1481, 1U,0U);
    uint _S1483 = _S1472 + _S1482;
    bool _S1484 = _S1474 == 0U;
    uint _S1485 = _slang_select(_S1484, _S1483,_S1480);
    FKHit _S1486 = (fcptReservoirHit((*r_9)));
    float3  _S1487 = dom_7->x0;
    float3  _S1488 = dom_7->x1 - dom_7->x0;
    float3  _S1489 = ((((_S1488)) * make_float3(rnorm3df(((_S1488)).x, ((_S1488)).y, ((_S1488)).z))));
    FKRay _S1490 = Ray_x24init_0(dom_7->x1, _S1489);
    FKRay ray_3 = _S1490;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1469;
    float3  throughput_4 = make_float3 (1.0f);
    float3  weight_2 = throughput_4;
    float3  glowed_0 = _S1469;
    float3  extinction_in_0 = _S1469;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1491 = dom_7->spread;
    float _S1492 = dom_7->width;
    float _S1493 = length_0(_S1488);
    NEEVertex _S1494 = NEEVertex_x24init_0(true, 0.0f, _S1469, _S1469, _S1469);
    NEEVertex nee_vertex_1 = _S1494;
    Vertex _S1495 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_1 = _S1495;
    Reservoir _S1496 = (Reservoir{});
    Reservoir chain_1 = _S1496;
    uint _S1497 = r_9->seed;
    (&chain_1)->seed = r_9->seed;
    uint _S1498 = extractBits_0(_S1471, 24U, 8U);
    uint _S1499 = insertBits_0(0U, _S1498, 24U, 8U);
    (&chain_1)->path = _S1499;
    (&ray_3)->origin = _S1487;
    (&hit_4)->distance = _S1493;
    FKMedium _S1500 = (fcptCameraMedium(((&ray_3)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1501 = filling_2;
    bool _S1502 = (fcptVaryingUsed());
    uint _S1503 = _slang_select(_S1502, _S1501,4294967295U);
    filling_2 = _S1503;
    scatter_in_0 = _S1500.scatter;
    extinction_in_0 = _S1500.extinction;
    g_in_0 = _S1500.g;
    Reservoir _S1504 = chain_1;
    uint _S1505 = filling_2;
    for(;;)
    {
        bool _S1506 = (fcptVaryingUsed());
        if(_S1506)
        {
            passes_0 = _S1505 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1507 = (fcptMajorant((_S1505)));
            spread_1 = _S1507;
        }
        else
        {
            spread_1 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_2)
        {
            turned_1 = 4294967295U == _S1485;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1474 == 1U;
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
            ended_0 = _S1470;
            sky_pdf_1 = 0.0f;
            spread_1 = _S1491;
            width_3 = _S1492;
            density_3 = 1.0f;
            throughput_3 = throughput_4;
            b_7 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1508 = (&prev_1)->rough;
        if(_S1508)
        {
            turned_1 = !(spread_1 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_1)->rough = turned_1;
        uint _S1509 = stream(_S1497, 384U);
        uint tracking_0 = _S1509;
        weight_2 = throughput_4;
        glowed_0 = _S1469;
        b_7 = 4294967295U;
        throughput_3 = throughput_4;
        density_3 = 1.0f;
        wavelength_9 = _S1491;
        width_3 = _S1492;
        sky_pdf_1 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1468 = int(1);
                break;
            }
            float _S1510 = (&hit_4)->distance;
            if(passes_0)
            {
                float3  _S1511 = (&ray_3)->origin;
                float3  _S1512 = (&ray_3)->unit_direction;
                float _S1513 = (&hit_4)->distance;
                bool _S1514 = b_7 == 4294967295U;
                uint _S1515 = _slang_select(_S1514, 0U,b_7);
                uint _S1516 = (&prev_1)->lobe;
                uint _S1517 = _slang_select(_S1514, 3U,_S1516);
                float _S1518 = (fcptTrackMedium((_S1505), (_S1511), (_S1512), (_S1513), (&tracking_0), (&weight_2), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1515), (_S1517), (_S1514)));
                threshold_0 = _S1518;
            }
            else
            {
                bool _S1519 = spread_1 > 0.0f;
                if(_S1519)
                {
                    uint _S1520 = noiseAddress(_S1497, b_7);
                    Random _S1521 = draw(_S1520, 10U);
                    float _S1522 = - (F32_log((1.0f - _S1521.value))) / spread_1;
                    threshold_0 = _S1522;
                }
                else
                {
                    threshold_0 = _S1510;
                }
            }
            bool _S1523 = !(threshold_0 < ((&hit_4)->distance));
            if(_S1523)
            {
                _S1468 = int(1);
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
                float3  _S1524 = pathColor(throughput_3 * glowed_0, throughput_4, 0.0f);
                float3  _S1525 = _S1524 / make_float3 (density_3);
                float3  _S1526 = sel_8->glow + _S1525;
                sel_8->glow = _S1526;
            }
            else
            {
            }
            glowed_0 = _S1469;
            uint b_9 = b_7 + 1U;
            float3  _S1527 = (&ray_3)->origin + make_float3 (threshold_0) * (&ray_3)->unit_direction;
            (&ray_3)->origin = _S1527;
            float3  _S1528 = flightWeight_0(scatter_in_0, extinction_in_0, spread_1, threshold_0, true);
            float3  _S1529 = weight_2;
            float _S1530 = upsample(weight_2, 0.0f);
            float3  _S1531 = make_float3 (_S1530);
            float3  _S1532 = _slang_select(false, _S1531,_S1529);
            float3  _S1533 = _slang_select(passes_0, _S1532,_S1528);
            float3  throughput_5 = throughput_3 * _S1533;
            uint _S1534 = stream(_S1497, b_9 + 320U);
            tracking_0 = _S1534;
            weight_2 = throughput_4;
            float width_6 = width_3 + wavelength_9 * threshold_0;
            float _S1535 = wavelength_9 + 3.14159274101257324f;
            bool _S1536 = !replay_2;
            if(_S1536)
            {
                is_inside_5 = true;
            }
            else
            {
                bool _S1537 = b_9 == _S1485;
                if(_S1537)
                {
                    is_inside_5 = !passes_0;
                }
                else
                {
                    is_inside_5 = false;
                }
            }
            TreeSample _S1538 = TreeSample_x24init_0(_S1469, _S1469, 0.0f, 0U);
            if(is_inside_5)
            {
                float3  _S1539 = (&ray_3)->origin;
                float3  _S1540 = (&ray_3)->unit_direction;
                float3  _S1541 = (&ray_3)->unit_direction;
                uint _S1542 = noiseAddress(_S1497, b_9);
                float3  _S1543 = extinction_in_0;
                float3  _S1544 = extinction_in_0;
                uint2  _S1545 = make_uint2 (_S1505);
                float3  _S1546 = (&ray_3)->unit_direction;
                uint _S1547 = arrivalLobe_0(b_9, (&prev_1)->lobe);
                FKHit _S1548 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1549 = _S1548;
                ShadowContext _S1550 = ShadowContext_x24init_0(_S1543, _S1544, _S1545, _S1546, b_9, _S1547, false, threshold_0, width_6, &_S1549, false);
                ShadowContext _S1551 = _S1550;
                TreeSample _S1552 = sampleLightTree_0(_S1539, _S1540, _S1541, 0.0f, true, _S1542, &_S1551);
                light_3 = _S1552;
            }
            else
            {
                light_3 = _S1538;
            }
            float _S1553 = phaseHG_0(g_in_0, dot_0((&ray_3)->unit_direction, light_3.dir));
            uint _S1554 = (fcptMaxBounces());
            bool _S1555 = b_9 < _S1554;
            if(_S1555)
            {
                viewed_0 = (light_3.density) > 0.0f;
            }
            else
            {
                viewed_0 = false;
            }
            float _S1556 = _slang_select(viewed_0, _S1553,0.0f);
            float3  _S1557 = throughput_5 * light_3.radiance;
            float _S1558 = powerHeuristic(light_3.density, _S1556);
            float3  _S1559 = pathColor(_S1557 * make_float3 (_S1553 * _S1558), throughput_4, 0.0f);
            float3  _S1560 = _slang_select(is_inside_5, _S1559,_S1469);
            if(replay_2)
            {
                _S1466 = b_9 == _S1485;
            }
            else
            {
                _S1466 = false;
            }
            if(_S1466)
            {
                bool _S1561 = _S1474 == 2U;
                if(_S1561)
                {
                    float _S1562 = resamplingTarget(_S1560);
                    passes_0 = _S1562 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1563 = Shift_x24init_0(_S1560, 1.0f);
                    _S1468 = int(0);
                    ended_0 = _S1563;
                    spread_1 = _S1535;
                    threshold_0 = width_6;
                    spectral_weight_1 = throughput_5;
                    layer_0 = b_9;
                    break;
                }
                _S1468 = int(0);
                ended_0 = _S1470;
                spread_1 = _S1535;
                threshold_0 = width_6;
                spectral_weight_1 = throughput_5;
                layer_0 = b_9;
                break;
            }
            if(_S1536)
            {
                Reservoir candidate_4 = _S1504;
                uint _S1564 = extractBits_0(_S1504.path, 24U, 8U);
                uint _S1565 = insertBits_0(0U, _S1564, 24U, 8U);
                uint _S1566 = extractBits_0(_S1504.path, 10U, 2U);
                bool _S1567 = _S1566 == 1U;
                if(_S1567)
                {
                    float3  _S1568 = safeDivide(_S1560, _S1469);
                    (&candidate_4)->radiance = _S1568;
                }
                else
                {
                    uint _S1569 = insertBits_0(_S1565, b_9 + 1U, 5U, 5U);
                    uint _S1570 = insertBits_0(_S1569, 2U, 10U, 2U);
                    (&candidate_4)->path = _S1570;
                }
                Reservoir _S1571 = withEnd(candidate_4, 0U, b_9, _S1560);
                offer(sel_8, _S1571, _S1560 * make_float3 (scale_4) / make_float3 (density_3));
                float _S1572 = survivalProbability(abs_0(throughput_5), density_3);
                uint _S1573 = (fcptMaxBounces());
                bool _S1574 = b_9 >= _S1573;
                if(_S1574)
                {
                    _S1467 = true;
                }
                else
                {
                    bool _S1575 = _S1572 < 1.0f;
                    if(_S1575)
                    {
                        uint _S1576 = noiseAddress(_S1497, b_9);
                        Random _S1577 = draw(_S1576, 8U);
                        _S1467 = _S1572 < (_S1577.value);
                    }
                    else
                    {
                        _S1467 = false;
                    }
                }
                if(_S1467)
                {
                    _S1468 = int(0);
                    ended_0 = _S1470;
                    spread_1 = _S1535;
                    threshold_0 = width_6;
                    spectral_weight_1 = throughput_5;
                    layer_0 = b_9;
                    break;
                }
                float _S1578 = density_3 * _S1572;
                density_3 = _S1578;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1579 = noiseAddress(_S1497, b_9);
            float3  _S1580 = samplePhase_0(g_in_0, (&ray_3)->unit_direction, _S1579, &phase_pdf_0);
            (&ray_3)->unit_direction = _S1580;
            NEEVertex _S1581 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_3)->origin, _S1469, (&ray_3)->origin);
            nee_vertex_1 = _S1581;
            Vertex _S1582 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, false);
            prev_1 = _S1582;
            float _S1583 = (&prev_1)->pdf;
            FKRay _S1584 = ray_3;
            FKHit _S1585 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1586 = (fcptTraverseInstanceBVH((_S1584), (true), (4.294967296e+09f), (false), (_S1585), (false)));
            hit_4 = _S1586;
            b_7 = b_9;
            throughput_3 = throughput_5;
            wavelength_9 = _S1535;
            width_3 = width_6;
            sky_pdf_1 = _S1583;
        }
        if(_S1468 != int(1))
        {
            width_3 = threshold_0;
            throughput_3 = spectral_weight_1;
            b_7 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1470;
        spread_1 = wavelength_9;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1587 = b_7 == 4294967295U;
    bool _S1588 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1588)
    {
        Reservoir _S1589 = chain_1;
        FKRay _S1590 = ray_3;
        Vertex _S1591 = prev_1;
        NEEVertex _S1592 = nee_vertex_1;
        Shift _S1593 = escape_0(r_9, replay_2, _S1485, _S1474, _S1472, _S1475, scale_4, _S1499, &_S1589, _S1469, b_7, &_S1590, throughput_3, density_3, &_S1591, &_S1592, sky_pdf_1, throughput_4, 0.0f, sel_8);
        return _S1593;
    }
    FKHit _S1594 = hit_4;
    uint _S1595 = filling_2;
    float3  _S1596 = scatter_in_0;
    float3  _S1597 = extinction_in_0;
    float3  _S1598 = weight_2;
    float3  _S1599 = glowed_0;
    float3  _S1600 = (&ray_3)->origin + make_float3 (_S1594.distance) * (&ray_3)->unit_direction;
    (&ray_3)->origin = _S1600;
    bool _S1601 = (fcptVaryingUsed());
    if(_S1601)
    {
        passes_0 = _S1595 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1602 = !replay_2;
        if(_S1602)
        {
            float3  _S1603 = pathColor(throughput_3 * _S1599, throughput_4, 0.0f);
            float3  _S1604 = _S1603 / make_float3 (density_3);
            float3  _S1605 = sel_8->glow + _S1604;
            sel_8->glow = _S1605;
        }
        else
        {
        }
        float3  _S1606 = throughput_3 * _S1598;
        throughput_3 = _S1606;
    }
    else
    {
        float3  _S1607 = flightWeight_0(_S1596, _S1597, (_S1596.x + _S1596.y + _S1596.z) / 3.0f, _S1594.distance, false);
        float3  _S1608 = throughput_3 * _S1607;
        throughput_3 = _S1608;
    }
    float width_7 = width_3 + spread_1 * _S1594.distance;
    uint _S1609 = b_7 + 1U;
    b_7 = _S1609;
    layer_0 = 0U;
    width_3 = width_7;
    passes_0 = false;
    wavelength_9 = 0.0f;
    threshold_0 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    spectral_weight_1 = throughput_4;
    float3  chain_throughput_1 = _S1469;
    float3  reconnection_0 = _S1469;
    viewed_0 = _S1587;
    for(;;)
    {
        bool _S1610 = ((&hit_4)->is_point_light) == 1U;
        if(replay_2)
        {
            _S1466 = _S1474 == 1U;
        }
        else
        {
            _S1466 = false;
        }
        if(_S1466)
        {
            _S1467 = b_7 == _S1473;
        }
        else
        {
            _S1467 = false;
        }
        bool _S1611;
        if(_S1467)
        {
            bool _S1612 = ((&hit_4)->instance_index) != (_S1486.instance_index);
            if(_S1612)
            {
                _S1611 = true;
            }
            else
            {
                _S1611 = ((&hit_4)->triangle_index) != (_S1486.triangle_index);
            }
        }
        else
        {
            _S1611 = false;
        }
        if(_S1611)
        {
            return _S1470;
        }
        FKMedium _S1613 = Medium_x24init_0(_S1469, _S1469, 0.0f);
        BSDFMaterial _S1614 = Material_x24init_0(_S1469, _S1469, 0.0f, 0.0f, 0.0f, 0.0f, _S1469, throughput_4, 1.0f, _S1469, _S1469, 0.5f, 0.0f, 0.0f, _S1469, 0.0f, _S1469, 0.0f, 0.0f, 0.02999999932944775f, 1.5f, throughput_4, _S1469);
        FKMedium _S1615 = _S1613;
        FKSurface _S1616 = Surface_x24init_0(_S1469, _S1469, 0.0f, &_S1614, false, 0U, 1.0f, false, &_S1615, 4294967295U, _S1469);
        bool _S1617 = !_S1610;
        bool scatter_2;
        bool is_inside_6;
        float geometry_density_0;
        float3  throughput_6;
        FKSurface surface_12;
        if(_S1617)
        {
            uint _S1618 = noiseAddress(_S1497, b_7);
            uint _S1619 = arrivalLobe_0(b_7, (&prev_1)->lobe);
            FKSurface _S1620 = (fcptSurfaceAtPath((hit_4), ((&ray_3)->origin), (_S1618), (width_3), (layer_0), (b_7), (_S1619), ((&ray_3)->unit_direction)));
            bool _S1621 = !passes_0;
            FKSurface _S1622 = _S1620;
            FKSurface _S1623 = emitting_0(&_S1622, _S1621);
            uint _S1624 = noiseAddress(_S1497, b_7);
            Random _S1625 = draw(_S1624, 9U);
            FKSurface _S1626 = _S1623;
            FKSurface _S1627 = uncovered_0(&_S1626, _S1625.value);
            float _S1628 = facingSign(_S1627.material.transmission, _S1627.geometry_n, (&ray_3)->unit_direction);
            bool _S1629 = _S1628 < 0.0f;
            bool _S1630 = (_S1627.material.transmission) > 0.0f;
            if(_S1630)
            {
                bool _S1631 = arrivesBehind_0((&ray_3)->unit_direction, _S1627.geometry_n);
                scatter_2 = _S1631;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1632 = _S1627;
            FKSurface _S1633 = facingRay_0(&_S1632, (&ray_3)->unit_direction);
            if(passes_0)
            {
                bool _S1634 = arrivesBehind_0((&ray_3)->unit_direction, _S1633.geometry_n);
                is_inside_6 = _S1634;
            }
            else
            {
                is_inside_6 = scatter_2;
            }
            if(is_inside_6)
            {
                float _S1635 = (&hit_4)->distance;
                float _S1636 = upsample(_S1633.material.absorption, wavelength_9);
                float3  _S1637 = make_float3 (_S1636);
                bool _S1638 = wavelength_9 > 0.0f;
                float3  _S1639 = _slang_select(_S1638, _S1637,_S1633.material.absorption);
                float3  _S1640 = beerLambert(_S1635, _S1639);
                float3  _S1641 = throughput_3 * _S1640;
                throughput_6 = _S1641;
            }
            else
            {
                throughput_6 = throughput_3;
            }
            bool _S1642 = !_S1633.skip;
            float geometry_density_1 = (F32_abs((dot_0(_S1633.geometry_n, (&ray_3)->unit_direction)))) / ((&hit_4)->distance * (&hit_4)->distance);
            bool _S1643 = b_7 == _S1609;
            if(_S1643)
            {
                float _S1644 = 0.00251327408477664f / geometry_density_1;
                geometry_density_0 = _S1644;
            }
            else
            {
                geometry_density_0 = threshold_0;
            }
            float _S1645 = geometry_density_0;
            scatter_2 = _S1642;
            geometry_density_0 = geometry_density_1;
            threshold_0 = _S1645;
            surface_12 = _S1633;
            turned_1 = _S1629;
        }
        else
        {
            scatter_2 = false;
            geometry_density_0 = 0.0f;
            surface_12 = _S1616;
            throughput_6 = throughput_3;
            is_inside_6 = is_inside_5;
        }
        bool _S1646;
        if(scatter_2)
        {
            _S1646 = (&prev_1)->rough;
        }
        else
        {
            _S1646 = false;
        }
        bool _S1647;
        if(_S1646)
        {
            _S1647 = ((&prev_1)->pdf * geometry_density_0 * threshold_0) <= 1.0f;
        }
        else
        {
            _S1647 = false;
        }
        FKSurface _S1648 = surface_12;
        float _S1649 = dot_0(surface_12.smooth_n, - (&ray_3)->unit_direction);
        bool _S1650 = (fcptDispersionUsed());
        bool _S1651;
        if(_S1650)
        {
            _S1651 = wavelength_9 == 0.0f;
        }
        else
        {
            _S1651 = false;
        }
        bool _S1652;
        if(_S1651)
        {
            _S1652 = scatter_2;
        }
        else
        {
            _S1652 = false;
        }
        bool _S1653;
        if(_S1652)
        {
            bool _S1654 = dispersive(surface_12.material);
            _S1653 = _S1654;
        }
        else
        {
            _S1653 = false;
        }
        float3  throughput_7;
        if(_S1653)
        {
            uint _S1655 = stream(_S1497, 512U);
            Random _S1656 = pcg(_S1655);
            uint _S1657 = extractBits_0(_S1471, 25U, 7U);
            float _S1658 = (float(_S1657) + _S1656.value) / 128.0f;
            uint _S1659 = extractBits_0(_S1471, 24U, 1U);
            bool _S1660 = _S1659 == 1U;
            float _S1661 = _slang_select(_S1660, _S1658,_S1656.value);
            float2  _S1662 = sampleWavelength(_S1661);
            float wavelength_10 = _S1662.x;
            float3  _S1663 = wavelengthWeights(wavelength_10);
            float3  _S1664 = _S1663 / make_float3 (_S1662.y);
            float _S1665 = upsample(throughput_6, wavelength_10);
            float3  _S1666 = make_float3 (_S1665);
            float _S1667 = upsample(scatter_in_0, wavelength_10);
            float3  _S1668 = make_float3 (_S1667);
            scatter_in_0 = _S1668;
            float _S1669 = upsample(extinction_in_0, wavelength_10);
            float3  _S1670 = make_float3 (_S1669);
            extinction_in_0 = _S1670;
            wavelength_9 = wavelength_10;
            throughput_7 = _S1666;
            spectral_weight_1 = _S1664;
        }
        else
        {
            throughput_7 = throughput_6;
        }
        BSDFMaterial _S1671 = pathMaterial(surface_12.material, wavelength_9);
        float2  _S1672 = wavelengthEta(_S1671, _S1649, wavelength_9);
        FKSurface _S1673 = surface_12;
        Facets _S1674 = drawFacets((&ray_3)->unit_direction, _S1648.smooth_n, _S1671, surface_12.random_state);
        bool _S1675;
        if(scatter_2)
        {
            bool _S1676 = neeDecision(_S1671, _S1649, _S1672.x, _S1672.y);
            _S1675 = _S1676;
        }
        else
        {
            _S1675 = false;
        }
        bool _S1677;
        if(passes_0)
        {
            _S1677 = true;
        }
        else
        {
            _S1677 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1677)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1675;
        }
        bool _S1678 = (fcptHairUsed());
        bool _S1679;
        if(_S1678)
        {
            float3  _S1680 = surface_12.hair;
            _S1679 = (dot_0(_S1680, _S1680)) > 0.0f;
        }
        else
        {
            _S1679 = false;
        }
        bool _S1681;
        if(_S1679)
        {
            _S1681 = true;
        }
        else
        {
            BSDFMaterial _S1682 = _S1671;
            bool _S1683 = isTranslucent_0(&_S1682);
            _S1681 = _S1683;
        }
        bool _S1684;
        if(_S1681)
        {
            _S1684 = true;
        }
        else
        {
            bool _S1685 = (_S1671.transmission) > 0.0f;
            if(_S1685)
            {
                uint _S1686 = (fcptLayers((hit_4)));
                _S1684 = _S1686 == 1U;
            }
            else
            {
                _S1684 = false;
            }
        }
        float3  emission_0;
        if(_S1610)
        {
            float3  _S1687 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1687;
        }
        else
        {
            emission_0 = _S1671.emissive;
        }
        bool _S1688 = !replay_2;
        bool _S1689;
        if(_S1688)
        {
            _S1689 = true;
        }
        else
        {
            _S1689 = b_7 >= _S1485;
        }
        bool _S1690;
        if(_S1689)
        {
            float _S1691 = rgb_to_greyscale(emission_0);
            _S1690 = _S1691 > 0.0f;
        }
        else
        {
            _S1690 = false;
        }
        float3  emission_1;
        if(_S1690)
        {
            NEEVertex _S1692 = nee_vertex_1;
            FKHit _S1693 = hit_4;
            float _S1694 = emissionWeight_0(&_S1692, &_S1693, (&ray_3)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1694);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1695;
        if(replay_2)
        {
            _S1695 = _S1474 == 1U;
        }
        else
        {
            _S1695 = false;
        }
        bool _S1696;
        if(_S1695)
        {
            _S1696 = b_7 > _S1473;
        }
        else
        {
            _S1696 = false;
        }
        bool _S1697;
        if(_S1696)
        {
            _S1697 = b_7 == _S1472;
        }
        else
        {
            _S1697 = false;
        }
        bool _S1698;
        if(_S1697)
        {
            bool _S1699 = _S1475 == 1U;
            if(_S1699)
            {
                _S1698 = true;
            }
            else
            {
                _S1698 = _S1475 == 2U;
            }
        }
        else
        {
            _S1698 = false;
        }
        if(_S1698)
        {
            bool _S1700 = _S1610 != (_S1475 == 2U);
            if(_S1700)
            {
                return _S1470;
            }
            float3  _S1701 = pathColor(throughput_7 * emission_1, spectral_weight_1, wavelength_9);
            return Shift_x24init_0(_S1701 / make_float3 (r_9->jac), density_3 / r_9->jac);
        }
        uint _S1702 = extractBits_0((&chain_1)->path, 10U, 2U);
        bool _S1703 = _S1702 == 1U;
        Reservoir here_0 = chain_1;
        uint _S1704 = insertBits_0(_S1499, b_7, 5U, 5U);
        uint _S1705 = insertBits_0(_S1704, 1U, 10U, 2U);
        uint _S1706 = insertBits_0(_S1705, (&prev_1)->lobe, 15U, 3U);
        bool _S1707 = (&prev_1)->inside;
        uint _S1708 = _slang_select(_S1707, 1U,0U);
        uint _S1709 = insertBits_0(_S1706, _S1708, 22U, 1U);
        (&here_0)->path = _S1709;
        uint _S1710 = (&here_0)->path;
        bool _S1711 = wavelength_9 > 0.0f;
        uint _S1712 = _slang_select(_S1711, 1U,0U);
        uint _S1713 = insertBits_0(_S1710, _S1712, 23U, 1U);
        (&here_0)->path = _S1713;
        float _S1714 = (&prev_1)->pdf * geometry_density_0;
        (&here_0)->jac = _S1714;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1715;
        if(replay_2)
        {
            _S1715 = _S1474 == 1U;
        }
        else
        {
            _S1715 = false;
        }
        bool _S1716;
        if(_S1715)
        {
            _S1716 = b_7 == _S1473;
        }
        else
        {
            _S1716 = false;
        }
        bool _S1717 = b_7 == _S1485;
        bool _S1718;
        if(_S1717)
        {
            bool _S1719 = !scatter_2;
            if(_S1719)
            {
                _S1718 = true;
            }
            else
            {
                bool _S1720 = _S1474 != 1U;
                if(_S1720)
                {
                    _S1718 = _S1474 != 3U;
                }
                else
                {
                    _S1718 = false;
                }
            }
        }
        else
        {
            _S1718 = false;
        }
        bool _S1721;
        if(_S1718)
        {
            _S1721 = _S1474 == 2U;
        }
        else
        {
            _S1721 = false;
        }
        bool _S1722;
        if(_S1721)
        {
            _S1722 = !_S1647;
        }
        else
        {
            _S1722 = false;
        }
        bool _S1723;
        if(_S1722)
        {
            _S1723 = _S1475 != 4U;
        }
        else
        {
            _S1723 = false;
        }
        bool _S1724 = _S1473 == _S1472;
        bool _S1725;
        if(_S1724)
        {
            _S1725 = _S1475 == 0U;
        }
        else
        {
            _S1725 = false;
        }
        bool _S1726;
        if(_S1725)
        {
            _S1726 = ((&hit_4)->instance_index) == (_S1486.instance_index);
        }
        else
        {
            _S1726 = false;
        }
        bool _S1727;
        if(_S1726)
        {
            _S1727 = ((&hit_4)->triangle_index) == (_S1486.triangle_index);
        }
        else
        {
            _S1727 = false;
        }
        bool _S1728;
        if(_S1727)
        {
            _S1728 = _S1647;
        }
        else
        {
            _S1728 = false;
        }
        bool _S1729 = _slang_select(_S1716, _S1728,_S1723);
        bool _S1730;
        if(nee_0)
        {
            _S1730 = _slang_select(replay_2, _S1729,scatter_2);
        }
        else
        {
            _S1730 = false;
        }
        TreeSample _S1731 = TreeSample_x24init_0(_S1469, _S1469, 0.0f, 0U);
        uint2  _S1732 = make_uint2 (0U);
        float2  _S1733 = make_float2 (0.0f);
        FKHit _S1734 = Hit_x24init_0(_S1733, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1735 = _S1734;
        ShadowContext _S1736 = ShadowContext_x24init_0(_S1469, _S1469, _S1732, _S1469, 0U, 0U, false, 0.0f, 0.0f, &_S1735, false);
        bool _S1737;
        if(nee_0)
        {
            _S1737 = _S1689;
        }
        else
        {
            _S1737 = false;
        }
        ShadowContext context_5;
        if(_S1737)
        {
            uint _S1738 = arrivalLobe_0(b_7, (&prev_1)->lobe);
            FKMedium _S1739 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1740 = surface_12;
            FKHit _S1741 = hit_4;
            FKMedium _S1742 = _S1739;
            ShadowContext _S1743 = shadowContext_0(&_S1740, turned_1, extinction_in_0, filling_2, (&ray_3)->unit_direction, b_7, _S1738, (&hit_4)->distance, width_3, &_S1741, _S1679, &_S1742);
            context_5 = _S1743;
        }
        else
        {
            context_5 = _S1736;
        }
        float3  throughput_8;
        float3  lit_0;
        if(_S1730)
        {
            float3  _S1744 = (&ray_3)->origin;
            if(_S1679)
            {
                throughput_8 = _S1469;
            }
            else
            {
                throughput_8 = _S1648.smooth_n;
            }
            FKSurface _S1745 = surface_12;
            uint _S1746 = noiseAddress(_S1497, b_7);
            ShadowContext _S1747 = context_5;
            TreeSample _S1748 = sampleLightTree_0(_S1744, throughput_8, surface_12.geometry_n, surface_12.geometry_offset, _S1684, _S1746, &_S1747);
            bool _S1749 = any_1((_S1748.radiance) != _S1469);
            if(_S1749)
            {
                if(_S1679)
                {
                    uint _S1750 = (fcptMaxBounces());
                    bool _S1751 = b_7 < _S1750;
                    FKSurface _S1752 = surface_12;
                    TreeSample _S1753 = _S1748;
                    float3  _S1754 = hairLight_0(&_S1752, (&ray_3)->unit_direction, &_S1753, _S1751);
                    lit_0 = _S1754;
                }
                else
                {
                    float _S1755 = _S1672.x;
                    float _S1756 = _S1672.y;
                    uint _S1757 = (fcptMaxBounces());
                    bool _S1758 = b_7 < _S1757;
                    TreeSample _S1759 = _S1748;
                    BSDFMaterial _S1760 = _S1671;
                    Facets _S1761 = _S1674;
                    float3  _S1762 = lightBSDF_0((&ray_3)->unit_direction, &_S1759, _S1648.smooth_n, _S1745.geometry_n, &_S1760, _S1755, _S1756, _S1758, &_S1761);
                    lit_0 = _S1762;
                }
            }
            else
            {
                lit_0 = _S1469;
            }
            light_3 = _S1748;
        }
        else
        {
            light_3 = _S1731;
            lit_0 = _S1469;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1763;
        bool _S1764;
        float density_5;
        if(_S1716)
        {
            bool _S1765 = !_S1647;
            if(_S1765)
            {
                return _S1470;
            }
            uint _S1766 = extractBits_0(_S1471, 23U, 1U);
            bool _S1767 = _S1711 != (_S1766 == 1U);
            if(_S1767)
            {
                return _S1470;
            }
            float3  throughput_9 = throughput_7 * make_float3 (geometry_density_0);
            float density_6 = density_3 * geometry_density_0;
            if(_S1724)
            {
                viewed_1 = _S1475 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                float3  _S1768 = pathColor(throughput_9 * emission_1, spectral_weight_1, wavelength_9);
                return Shift_x24init_0(_S1768 / make_float3 (r_9->jac), density_6 / r_9->jac);
            }
            if(_S1724)
            {
                refracted_4 = _S1475 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S1769 = !nee_0;
                if(_S1769)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1770 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1770 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1470;
                }
                float3  _S1771 = pathColor(throughput_9 * lit_0, spectral_weight_1, wavelength_9);
                return Shift_x24init_0(_S1771 / make_float3 (r_9->jac), density_6 / r_9->jac);
            }
            if(_S1724)
            {
                wrong_side_0 = _S1475 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1772 = !nee_0;
                if(_S1772)
                {
                    return _S1470;
                }
                bool _S1773 = (fcptWorldReadsPath());
                if(_S1773)
                {
                    float3  _S1774 = r_9->dir;
                    float _S1775 = environmentPdf_0(r_9->dir);
                    FKSurface _S1776 = surface_12;
                    BSDFMaterial _S1777 = _S1671;
                    Facets _S1778 = _S1674;
                    FixedArray<float3 , 6>  terms_4;
                    FixedArray<float, 6>  pdfs_6;
                    float3  _S1779 = skyLobes_0((&ray_3)->unit_direction, _S1774, &_S1776, &_S1777, _S1672, is_inside_6, &_S1778, _S1775, &terms_4, &pdfs_6);
                    uint _S1780 = b_7 + 1U;
                    FixedArray<float3 , 6>  _S1781 = terms_4;
                    FixedArray<float, 6>  _S1782 = pdfs_6;
                    float3  _S1783 = skyColor_0(_S1774, &_S1781, &_S1782, _S1780);
                    float3  _S1784 = pathColor(throughput_9 * (_S1783 * r_9->radiance), spectral_weight_1, wavelength_9);
                    return Shift_x24init_0(_S1784 / make_float3 (r_9->jac), density_6 / r_9->jac);
                }
                float _S1785 = environmentPdf_0(r_9->dir);
                float3  _S1786 = skyBSDF((&ray_3)->unit_direction, r_9->dir, surface_12, _S1671, _S1672, is_inside_6, _S1674, _S1785);
                float3  _S1787 = pathColor(throughput_9 * _S1786 * r_9->radiance, spectral_weight_1, wavelength_9);
                return Shift_x24init_0(_S1787 / make_float3 (r_9->jac), density_6 / r_9->jac);
            }
            uint _S1788 = extractBits_0(_S1471, 21U, 1U);
            bool _S1789 = nee_0 != (_S1788 == 1U);
            if(_S1789)
            {
                return _S1470;
            }
            throughput_8 = throughput_9;
            density_5 = density_6;
        }
        else
        {
            if(replay_2)
            {
                viewed_1 = _S1717;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1790 = !scatter_2;
                if(_S1790)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1791 = _S1474 != 1U;
                    if(_S1791)
                    {
                        refracted_4 = _S1474 != 3U;
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
                bool _S1792 = _S1474 == 2U;
                if(_S1792)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1647;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1475 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1679)
                    {
                        return _S1470;
                    }
                    uint _S1793 = noiseAddress(_S1497, b_7);
                    FKRay _S1794 = ray_3;
                    FKSurface _S1795 = surface_12;
                    Facets _S1796 = _S1674;
                    ShadowContext _S1797 = context_5;
                    SkySample _S1798 = sampleSky_0(&_S1794, &_S1795, wavelength_9, _S1672, is_inside_6, _S1793, &_S1796, &_S1797);
                    float3  _S1799 = pathColor(throughput_7 * _S1798.color, spectral_weight_1, wavelength_9);
                    return Shift_x24init_0(_S1799, 1.0f);
                }
                if(_S1792)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1647;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1800 = rgb_to_greyscale(light_3.radiance);
                    bool _S1801 = !(_S1800 > 0.0f);
                    if(_S1801)
                    {
                        return _S1470;
                    }
                    float3  _S1802 = pathColor(throughput_7 * lit_0, spectral_weight_1, wavelength_9);
                    return Shift_x24init_0(_S1802, 1.0f);
                }
                if(_S1484)
                {
                    passes_0 = _S1475 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1610;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float3  _S1803 = pathColor(throughput_7 * emission_1, spectral_weight_1, wavelength_9);
                    return Shift_x24init_0(_S1803, 1.0f);
                }
                if(_S1484)
                {
                    passes_0 = _S1475 == 1U;
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
                    passes_0 = !_S1647;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float3  _S1804 = pathColor(throughput_7 * emission_1, spectral_weight_1, wavelength_9);
                    return Shift_x24init_0(_S1804, 1.0f);
                }
                return _S1470;
            }
            else
            {
                if(_S1688)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1805 = b_7 > 0U;
                    if(_S1805)
                    {
                        Reservoir candidate_5 = chain_1;
                        if(_S1703)
                        {
                            float3  _S1806 = safeDivide(throughput_7 * emission_1, chain_throughput_1);
                            (&candidate_5)->radiance = _S1806;
                        }
                        else
                        {
                            if(_S1647)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1807 = pathColor(throughput_7 * emission_1, spectral_weight_1, wavelength_9);
                        Reservoir _S1808 = withEnd(candidate_5, 1U, b_7, _S1807);
                        offer(sel_8, _S1808, _S1807 * make_float3 (scale_4) / make_float3 (density_3));
                    }
                    else
                    {
                        float3  _S1809 = pathColor(throughput_7 * emission_1, spectral_weight_1, wavelength_9);
                        float3  _S1810 = sel_8->glow + _S1809;
                        sel_8->glow = _S1810;
                    }
                    if(nee_0)
                    {
                        float3  _S1811 = pathColor(throughput_7 * lit_0, spectral_weight_1, wavelength_9);
                        Reservoir candidate_6 = chain_1;
                        if(_S1703)
                        {
                            float3  _S1812 = safeDivide(_S1811, chain_throughput_1);
                            (&candidate_6)->radiance = _S1812;
                        }
                        else
                        {
                            if(_S1647)
                            {
                                candidate_6 = here_0;
                                uint _S1813 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1813;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1814 = insertBits_0(_S1499, b_7 + 1U, 5U, 5U);
                                uint _S1815 = insertBits_0(_S1814, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1815;
                            }
                        }
                        Reservoir _S1816 = withEnd(candidate_6, 0U, b_7, _S1811);
                        offer(sel_8, _S1816, _S1811 * make_float3 (scale_4) / make_float3 (density_3));
                    }
                    if(nee_0)
                    {
                        if(_S1679)
                        {
                            _S1763 = false;
                        }
                        else
                        {
                            bool _S1817 = environmentMapped_0();
                            _S1763 = _S1817;
                        }
                    }
                    else
                    {
                        _S1763 = false;
                    }
                    if(_S1763)
                    {
                        uint _S1818 = (fcptMaxBounces());
                        _S1764 = b_7 < _S1818;
                    }
                    else
                    {
                        _S1764 = false;
                    }
                    if(_S1764)
                    {
                        uint _S1819 = noiseAddress(_S1497, b_7);
                        FKRay _S1820 = ray_3;
                        FKSurface _S1821 = surface_12;
                        Facets _S1822 = _S1674;
                        ShadowContext _S1823 = context_5;
                        SkySample _S1824 = sampleSky_0(&_S1820, &_S1821, wavelength_9, _S1672, is_inside_6, _S1819, &_S1822, &_S1823);
                        float3  _S1825 = pathColor(throughput_7 * _S1824.color, spectral_weight_1, wavelength_9);
                        Reservoir candidate_7 = chain_1;
                        if(_S1703)
                        {
                            float3  _S1826 = safeDivide(_S1825, chain_throughput_1);
                            (&candidate_7)->radiance = _S1826;
                        }
                        else
                        {
                            if(_S1647)
                            {
                                candidate_7 = here_0;
                                uint _S1827 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1827;
                                (&candidate_7)->dir = _S1824.dir;
                                (&candidate_7)->radiance = _S1824.radiance;
                            }
                            else
                            {
                                uint _S1828 = insertBits_0(_S1499, b_7 + 1U, 5U, 5U);
                                uint _S1829 = insertBits_0(_S1828, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1829;
                            }
                        }
                        Reservoir _S1830 = withEnd(candidate_7, 4U, b_7, _S1825);
                        offer(sel_8, _S1830, _S1825 * make_float3 (scale_4) / make_float3 (density_3));
                    }
                }
            }
            throughput_8 = throughput_7;
            density_5 = density_3;
        }
        bool _S1831;
        bool _S1832;
        bool _S1833;
        bool straight_0;
        bool _S1834;
        bool _S1835;
        bool _S1836;
        bool _S1837;
        bool _S1838;
        bool _S1839;
        bool _S1840;
        bool _S1841;
        bool _S1842;
        bool _S1843;
        bool _S1844;
        bool _S1845;
        bool _S1846;
        float density_7;
        float sky_pdf_3;
        float spread_4;
        uint b_10;
        float3  throughput_10;
        float3  throughput_11;
        float3  throughput_12;
        if(scatter_2)
        {
            if(replay_2)
            {
                viewed_1 = _S1717;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1847 = extractBits_0(_S1471, 15U, 3U);
            uint _S1848 = extractBits_0(_S1471, 18U, 3U);
            uint _S1849 = _slang_select(_S1716, _S1848,_S1847);
            float3  _S1850 = r_9->dir;
            bool refracted_5 = _S1849 == 1U;
            SampleBSDF _S1851 = SampleBSDF_x24init_0(_S1469, _S1469, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1851;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1852 = extractBits_0(_S1471, 22U, 1U);
                bool _S1853 = is_inside_6 != (_S1852 == 1U);
                if(_S1853)
                {
                    return _S1470;
                }
                bool _S1854 = _S1474 == 1U;
                if(_S1854)
                {
                    float3  _S1855 = (fcptHitPosition((_S1486)));
                    throughput_10 = _S1855;
                }
                else
                {
                    throughput_10 = reconnection_0;
                }
                if(refracted_5)
                {
                    refracted_4 = true;
                }
                else
                {
                    BSDFMaterial _S1856 = _S1671;
                    bool _S1857 = isTranslucent_0(&_S1856);
                    if(_S1857)
                    {
                        refracted_4 = _S1849 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1858 = throughput_10 - (&ray_3)->origin;
                        float3  _S1859 = _slang_select(_S1854, _S1858,_S1850);
                        wrong_side_0 = (dot_0(_S1648.smooth_n, _S1859) * _S1649) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1854)
                {
                    float3  _S1860 = (&ray_3)->origin;
                    FKSurface _S1861 = surface_12;
                    float3  _S1862 = - _S1648.smooth_n;
                    bool _S1863 = is_inside_6 != refracted_4;
                    float3  _S1864 = _slang_select(_S1863, _S1862,_S1648.smooth_n);
                    float3  _S1865 = throughput_10 - (_S1860 + make_float3 (_S1861.geometry_offset) * _S1864);
                    float3  _S1866 = ((((_S1865)) * make_float3(rnorm3df(((_S1865)).x, ((_S1865)).y, ((_S1865)).z))));
                    reconnection_1 = _S1866;
                }
                else
                {
                    reconnection_1 = _S1850;
                }
                if(_S1679)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1867 = wrongSide_0(is_inside_6, refracted_4, reconnection_1, surface_12.geometry_n);
                    wrong_side_0 = _S1867;
                }
                if(wrong_side_0)
                {
                    return _S1470;
                }
                float3  _S1868 = throughput_10;
                throughput_10 = reconnection_1;
                b_10 = _S1849;
                wrong_side_0 = false;
                reconnection_1 = _S1868;
            }
            else
            {
                bool _S1869 = !_S1716;
                if(_S1869)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1870;
                    if(_S1679)
                    {
                        SampleBSDF _S1871 = (fcptSampleHair((surface_12.hair), (_S1671.albedo), (_S1671.specular_tint), ((&ray_3)->unit_direction), (_S1673.random_state)));
                        _S1870 = _S1871;
                    }
                    else
                    {
                        SampleBSDF _S1872 = sampleBSDF((&ray_3)->unit_direction, _S1648.smooth_n, _S1671, _S1672.x, _S1672.y, _S1674, _S1673.random_state, _S1733);
                        _S1870 = _S1872;
                    }
                    bsdf_sampled_0 = _S1870;
                    if(_S1679)
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
                            return _S1470;
                        }
                        break;
                    }
                    if(_S1679)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1873 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_12.geometry_n);
                        wrong_side_0 = _S1873;
                    }
                    if(wrong_side_0)
                    {
                        _S1763 = (_S1671.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1763 = false;
                    }
                    if(_S1763)
                    {
                        float _S1874 = _S1672.x;
                        float _S1875 = _S1672.y;
                        Facets _S1876 = drawFacets((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S1671, (&bsdf_sampled_0)->random_state);
                        SampleBSDF _S1877 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S1671, _S1874, _S1875, _S1876, (&bsdf_sampled_0)->random_state, _S1733);
                        (&bsdf_sampled_0)->unit_direction = _S1877.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1877.refracted;
                        (&bsdf_sampled_0)->throughput = _S1877.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1878 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n)) * surface_12.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1878;
                        }
                    }
                    uint _S1879 = (&bsdf_sampled_0)->lobe;
                    float3  _S1880 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1881 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1882 = (&bsdf_sampled_0)->pdf;
                    float _S1883 = _slang_select(wrong_side_0, 0.0f,_S1882);
                    (&lobe_5)->pdf = _S1883;
                    throughput_10 = _S1880;
                    b_10 = _S1879;
                    refracted_4 = _S1881;
                }
                else
                {
                    throughput_10 = _S1850;
                    b_10 = _S1849;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1763 = true;
            }
            else
            {
                _S1763 = _S1716;
            }
            if(_S1763)
            {
                if(_S1679)
                {
                    SampleBSDF _S1884 = (fcptConnectHair((surface_12.hair), (_S1671.albedo), (_S1671.specular_tint), ((&ray_3)->unit_direction), (throughput_10)));
                    lobe_5 = _S1884;
                }
                else
                {
                    float3  _S1885 = (&ray_3)->unit_direction;
                    float3  _S1886 = negate_0(_S1885);
                    float _S1887 = sign_0(_S1649);
                    float3  _S1888 = _S1648.smooth_n * make_float3 (_S1887);
                    float _S1889 = dot_0(_S1888, throughput_10);
                    float _S1890 = _S1671.roughness;
                    float _S1891 = _S1890 * _S1890;
                    AnisotropicFrame _S1892 = anisotropicFrame(_S1671, _S1888);
                    SheenProfile _S1893 = sheenProfile(_S1886, _S1888, _S1671);
                    CoatFrame _S1894 = coatFrame(_S1671, _S1888);
                    float3  _S1895 = coatSeries(_S1894, _S1671);
                    float3  _S1896 = reflectedHalf(_S1885, throughput_10);
                    bool _S1897 = b_10 == 1U;
                    if(_S1897)
                    {
                        float3  _S1898 = refractedHalf(_S1885, throughput_10, _S1648.smooth_n, _S1672.x, _S1672.y);
                        throughput_11 = _S1898;
                    }
                    else
                    {
                        throughput_11 = _S1896;
                    }
                    float3  _S1899 = _S1674.coat_h;
                    bool _S1900 = (dot_0(_S1899, _S1899)) > 0.0f;
                    float3  _S1901 = _slang_select(_S1900, _S1896,_S1469);
                    float _S1902 = _S1672.x;
                    float _S1903 = _S1672.y;
                    Weights _S1904 = lobeWeights(_S1885, _S1886, _S1888, _S1674.h, _S1674.coat_h, throughput_11, _S1901, _S1892, _S1893, _S1894, _S1895, _S1671, _S1902, _S1903);
                    float _S1905 = (F32_abs((_S1649)));
                    float _S1906 = vndfPDF(_S1886, throughput_11, _S1888, _S1905, _S1891, _S1892, _S1904.v_dot_h);
                    switch(b_10)
                    {
                    case 0U:
                        {
                            float _S1907 = diffusePDF(_S1889, _S1905, _S1671, _S1904);
                            float3  _S1908 = diffuseBSDF(throughput_10, _S1888, _S1671, _S1904);
                            density_7 = _S1907;
                            throughput_12 = _S1908;
                            break;
                        }
                    case 1U:
                        {
                            float _S1909 = refractPDF(dot_0(throughput_10, throughput_11), _S1906, _S1904, _S1902, _S1903);
                            float _S1910 = maskingG1(throughput_10, _S1888, -1.0f, _S1891, _S1892);
                            float3  _S1911 = refractBSDF(_S1910, _S1671, _S1904);
                            density_7 = _S1909;
                            throughput_12 = _S1911;
                            break;
                        }
                    case 4U:
                        {
                            float _S1912 = sheenVelvetPDF(_S1889, _S1905, _S1904);
                            float3  _S1913 = sheenVelvetBSDF(throughput_10, _S1886, _S1888, _S1671, _S1904);
                            density_7 = _S1912;
                            throughput_12 = _S1913;
                            break;
                        }
                    case 5U:
                        {
                            float _S1914 = coatPDF(_S1886, _S1901, _S1894, _S1904);
                            float3  _S1915 = coatBSDF(_S1904);
                            density_7 = _S1914;
                            throughput_12 = _S1915;
                            break;
                        }
                    case 6U:
                        {
                            ToonProfile _S1916 = toonProfile(_S1886, _S1888, _S1671);
                            float _S1917 = toonPDF(throughput_10, _S1888, _S1916, _S1904);
                            float3  _S1918 = toonBSDF(throughput_10, _S1888, _S1916, _S1904);
                            density_7 = _S1917;
                            throughput_12 = _S1918;
                            break;
                        }
                    default:
                        {
                            float _S1919 = reflectPDF(_S1906, _S1904);
                            float _S1920 = maskingG1(throughput_10, _S1888, 1.0f, _S1891, _S1892);
                            float3  _S1921 = reflectBSDF(_S1920, _S1904);
                            density_7 = _S1919;
                            throughput_12 = _S1921;
                            break;
                        }
                    }
                    bool _S1922 = density_7 > 0.0f;
                    if(_S1922)
                    {
                        SampleBSDF _S1923 = SampleBSDF_x24init_0(throughput_10, throughput_12, _S1673.random_state, _S1897, b_10, density_7);
                        lobe_5 = _S1923;
                    }
                }
            }
            bool _S1924 = b_10 == 0U;
            if(_S1924)
            {
                _S1764 = true;
            }
            else
            {
                _S1764 = b_10 == 4U;
            }
            if(_S1764)
            {
                _S1831 = true;
            }
            else
            {
                _S1831 = b_10 == 6U;
            }
            bool _S1925 = b_10 == 5U;
            float _S1926 = _slang_select(_S1925, _S1671.coat_roughness,_S1671.roughness);
            if(_S1679)
            {
                _S1832 = false;
            }
            else
            {
                bool _S1927 = !_S1831;
                if(_S1927)
                {
                    bool _S1928 = _S1926 == 0.0f;
                    if(_S1928)
                    {
                        _S1832 = true;
                    }
                    else
                    {
                        bool _S1929 = b_10 == 1U;
                        if(_S1929)
                        {
                            _S1832 = (_S1672.x) == (_S1672.y);
                        }
                        else
                        {
                            _S1832 = false;
                        }
                    }
                }
                else
                {
                    _S1832 = false;
                }
            }
            bool _S1930 = !_S1679;
            if(_S1930)
            {
                _S1833 = b_10 == 1U;
            }
            else
            {
                _S1833 = false;
            }
            if(_S1833)
            {
                straight_0 = (_S1671.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1834 = _S1930;
            }
            else
            {
                _S1834 = false;
            }
            if(_S1834)
            {
                _S1835 = b_10 == 1U;
            }
            else
            {
                _S1835 = false;
            }
            if(_S1835)
            {
                _S1836 = (_S1672.x) == (_S1672.y);
            }
            else
            {
                _S1836 = false;
            }
            BSDFMaterial _S1931 = _S1671;
            bool _S1932 = isTranslucent_0(&_S1931);
            if(_S1932)
            {
                _S1837 = _S1924;
            }
            else
            {
                _S1837 = false;
            }
            if(_S1837)
            {
                _S1838 = (dot_0(throughput_10, surface_12.geometry_n)) < 0.0f;
            }
            else
            {
                _S1838 = false;
            }
            if(nee_0)
            {
                _S1839 = !_S1832;
            }
            else
            {
                _S1839 = false;
            }
            if(_S1839)
            {
                _S1840 = !wrong_side_0;
            }
            else
            {
                _S1840 = false;
            }
            if(_S1840)
            {
                float _S1933 = (&lobe_5)->pdf;
                float3  _S1934 = (&ray_3)->origin;
                float3  _S1935 = _slang_select(_S1684, _S1469,_S1648.smooth_n);
                float3  _S1936 = (&ray_3)->origin;
                FKSurface _S1937 = surface_12;
                float3  _S1938 = - _S1648.smooth_n;
                float3  _S1939 = _slang_select(_S1838, _S1938,_S1648.smooth_n);
                NEEVertex _S1940 = NEEVertex_x24init_0(false, _S1933, _S1934, _S1935, _S1936 + make_float3 (_S1937.geometry_offset) * _S1939);
                nee_vertex_1 = _S1940;
            }
            else
            {
                if(_S1679)
                {
                    _S1841 = true;
                }
                else
                {
                    bool _S1941 = b_10 != 1U;
                    if(_S1941)
                    {
                        _S1841 = true;
                    }
                    else
                    {
                        _S1841 = (_S1672.x) != (_S1672.y);
                    }
                }
                if(_S1841)
                {
                    (&nee_vertex_1)->none = true;
                }
            }
            bool _S1942 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1942)
            {
                if(_S1831)
                {
                    _S1841 = true;
                }
                else
                {
                    _S1841 = ((&lobe_5)->pdf * (&prev_1)->cos / ((&hit_4)->distance * (&hit_4)->distance) * threshold_0) <= 1.0f;
                }
            }
            else
            {
                _S1841 = false;
            }
            bool _S1943 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1943)
            {
                if(_S1831)
                {
                    _S1842 = true;
                }
                else
                {
                    _S1842 = _S1926 >= 0.20000000298023224f;
                }
            }
            else
            {
                _S1842 = false;
            }
            if(_S1716)
            {
                bool _S1944 = !_S1841;
                if(_S1944)
                {
                    return _S1470;
                }
                bool _S1945 = _S1475 != 1U;
                if(_S1945)
                {
                    _S1843 = _S1475 != 2U;
                }
                else
                {
                    _S1843 = false;
                }
                if(_S1843)
                {
                    float _S1946 = (&lobe_5)->pdf;
                    float _S1947 = _slang_select(nee_0, _S1946,0.0f);
                    float _S1948 = escapeWeight_0(_S1947, _S1850);
                    if(_S1724)
                    {
                        passes_0 = _S1481;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1949 = _slang_select(passes_0, _S1948,1.0f);
                    return Shift_x24init_0(throughput_8 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_9->radiance * make_float3 (_S1949) / make_float3 (r_9->jac), density_5 * (&lobe_5)->pdf / r_9->jac);
                }
                float3  _S1950 = throughput_8 * make_float3 ((&lobe_5)->pdf);
                float _S1951 = density_5 * (&lobe_5)->pdf;
                throughput_11 = _S1950;
                density_7 = _S1951;
            }
            else
            {
                throughput_11 = throughput_8;
                density_7 = density_5;
            }
            uint _S1952 = (fcptLayers((hit_4)));
            bool _S1953 = _S1952 > 1U;
            if(_S1953)
            {
                _S1843 = (b_10 == 1U) != passes_0;
            }
            else
            {
                _S1843 = false;
            }
            if(viewed_1)
            {
                _S1844 = _S1843;
            }
            else
            {
                _S1844 = false;
            }
            if(_S1844)
            {
                return _S1470;
            }
            if(replay_2)
            {
                _S1845 = b_7 <= _S1485;
            }
            else
            {
                _S1845 = false;
            }
            if(_S1845)
            {
                _S1846 = _S1647;
            }
            else
            {
                _S1846 = false;
            }
            bool _S1954;
            if(_S1846)
            {
                _S1954 = _S1841;
            }
            else
            {
                _S1954 = false;
            }
            bool _S1955;
            if(_S1954)
            {
                _S1955 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1955 = !_S1842;
                }
                else
                {
                    _S1955 = false;
                }
            }
            if(_S1955)
            {
                return _S1470;
            }
            if(viewed_1)
            {
                float3  _S1956 = throughput_11 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1957 = (&lobe_5)->pdf;
                throughput_12 = _S1956;
                sky_pdf_3 = _S1957;
            }
            else
            {
                float3  _S1958 = throughput_11 * max_0((&lobe_5)->throughput, _S1469);
                throughput_12 = _S1958;
                sky_pdf_3 = density_7;
            }
            bool _S1959;
            if(_S1688)
            {
                _S1959 = !_S1703;
            }
            else
            {
                _S1959 = false;
            }
            bool _S1960;
            if(_S1959)
            {
                _S1960 = _S1647;
            }
            else
            {
                _S1960 = false;
            }
            bool _S1961;
            if(_S1960)
            {
                _S1961 = _S1841;
            }
            else
            {
                _S1961 = false;
            }
            float3  chain_throughput_2;
            if(_S1961)
            {
                chain_1 = here_0;
                uint _S1962 = insertBits_0((&chain_1)->path, b_10, 18U, 3U);
                uint _S1963 = _slang_select(nee_0, 1U,0U);
                uint _S1964 = insertBits_0(_S1962, _S1963, 21U, 1U);
                (&chain_1)->path = _S1964;
                float _S1965 = (&chain_1)->jac * (&lobe_5)->pdf;
                (&chain_1)->jac = _S1965;
                (&chain_1)->dir = throughput_10;
                chain_throughput_2 = throughput_12;
            }
            else
            {
                chain_throughput_2 = chain_throughput_1;
            }
            FKSurface _S1966 = surface_12;
            Vertex _S1967 = Vertex_x24init_0(_S1842, b_10, (&lobe_5)->pdf, (F32_abs((dot_0(surface_12.geometry_n, throughput_10)))), is_inside_6);
            prev_1 = _S1967;
            float _S1968 = (&lobe_5)->pdf;
            bool _S1969 = b_10 == 1U;
            bool _S1970;
            if(_S1969)
            {
                _S1970 = (_S1672.x) == (_S1672.y);
            }
            else
            {
                _S1970 = false;
            }
            float sky_pdf_4 = _slang_select(_S1970, sky_pdf_1,_S1968);
            float _S1971 = _slang_select(_S1679, 0.0f,sky_pdf_4);
            float _S1972 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * (&lobe_5)->pdf))))), (3.14159274101257324f)));
            bool _S1973 = !_S1832;
            float _S1974 = _slang_select(_S1973, _S1972,0.0f);
            float _S1975 = spread_1 + _S1974;
            bool _S1976;
            if(refracted_4)
            {
                _S1976 = !_S1838;
            }
            else
            {
                _S1976 = false;
            }
            bool is_inside_7;
            if(_S1976)
            {
                bool _S1977 = !is_inside_6;
                is_inside_7 = _S1977;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            FKSurface _S1978 = surface_12;
            bool _S1979 = boundsVolume_0(&_S1978);
            bool _S1980;
            if(_S1979)
            {
                _S1980 = !_S1843;
            }
            else
            {
                _S1980 = false;
            }
            if(_S1980)
            {
                FKSurface faced_2 = surface_12;
                float3  _S1981 = - _S1966.geometry_n;
                float3  _S1982 = _slang_select(turned_1, _S1981,_S1966.geometry_n);
                (&faced_2)->geometry_n = _S1982;
                FKMedium _S1983 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1984 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1985 = faced_2;
                FKMedium _S1986 = _S1983;
                FKMedium _S1987 = _S1984;
                MediumSides _S1988 = mediumSides_0(&_S1985, &_S1986, filling_2, (&ray_3)->unit_direction, &_S1987);
                bool _S1989 = ((dot_0(throughput_10, _S1966.geometry_n)) > 0.0f) == ((dot_0(_S1966.geometry_n, (&faced_2)->geometry_n)) > 0.0f);
                float3  _S1990 = _slang_select(_S1989, _S1988.front.scatter,_S1988.behind.scatter);
                scatter_in_0 = _S1990;
                float3  _S1991 = scatter_in_0;
                float _S1992 = upsample(scatter_in_0, wavelength_9);
                float3  _S1993 = make_float3 (_S1992);
                float3  _S1994 = _slang_select(_S1711, _S1993,_S1991);
                scatter_in_0 = _S1994;
                float3  _S1995 = _slang_select(_S1989, _S1988.front.extinction,_S1988.behind.extinction);
                extinction_in_0 = _S1995;
                float3  _S1996 = extinction_in_0;
                float _S1997 = upsample(extinction_in_0, wavelength_9);
                float3  _S1998 = make_float3 (_S1997);
                float3  _S1999 = _slang_select(_S1711, _S1998,_S1996);
                extinction_in_0 = _S1999;
                float _S2000 = _slang_select(_S1989, _S1988.front.g,_S1988.behind.g);
                g_in_0 = _S2000;
                uint _S2001 = _S1988.fillings.x;
                uint _S2002 = _S1988.fillings.y;
                uint _S2003 = _slang_select(_S1989, _S2002,_S2001);
                bool _S2004 = (fcptVaryingUsed());
                uint _S2005 = _slang_select(_S2004, _S2003,4294967295U);
                filling_2 = _S2005;
            }
            (&ray_3)->unit_direction = throughput_10;
            bool _S2006 = !_S1843;
            if(_S2006)
            {
                FKSurface _S2007 = surface_12;
                float _S2008 = _slang_select(straight_0, 0.0f,_S2007.geometry_offset);
                float3  _S2009 = - _S1648.smooth_n;
                bool _S2010 = is_inside_7 != _S1838;
                float3  _S2011 = _slang_select(_S2010, _S2009,_S1648.smooth_n);
                float3  _S2012 = (&ray_3)->origin + make_float3 (_S2008) * _S2011;
                (&ray_3)->origin = _S2012;
            }
            throughput_11 = throughput_12;
            chain_throughput_1 = chain_throughput_2;
            density_7 = sky_pdf_3;
            passes_0 = _S1843;
            viewed_1 = _S1836;
            sky_pdf_3 = _S1971;
            spread_4 = _S1975;
            reconnection_0 = reconnection_1;
            is_inside_5 = is_inside_7;
        }
        else
        {
            (&prev_1)->rough = false;
            (&prev_1)->pdf = 0.0f;
            throughput_11 = throughput_8;
            density_7 = density_5;
            passes_0 = false;
            viewed_1 = viewed_0;
            sky_pdf_3 = 0.0f;
            spread_4 = spread_1;
            straight_0 = false;
            is_inside_5 = is_inside_6;
        }
        float density_8;
        if(_S1688)
        {
            if(_S1610)
            {
                float3  _S2013 = pathColor(throughput_11 * emission_1, spectral_weight_1, wavelength_9);
                Reservoir candidate_8 = chain_1;
                uint _S2014 = extractBits_0((&chain_1)->path, 10U, 2U);
                bool _S2015 = _S2014 == 1U;
                if(_S2015)
                {
                    float3  _S2016 = safeDivide(_S2013, chain_throughput_1);
                    (&candidate_8)->radiance = _S2016;
                }
                Reservoir _S2017 = withEnd(candidate_8, 2U, b_7, _S2013);
                offer(sel_8, _S2017, _S2013 * make_float3 (scale_4) / make_float3 (density_7));
            }
            if(_S1610)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S2018 = survivalProbability(abs_0(throughput_11), density_7);
                density_8 = _S2018;
            }
            else
            {
                density_8 = 1.0f;
            }
            uint _S2019 = (fcptMaxBounces());
            bool _S2020 = b_7 >= _S2019;
            if(_S2020)
            {
                wrong_side_0 = true;
            }
            else
            {
                bool _S2021 = density_8 < 1.0f;
                if(_S2021)
                {
                    uint _S2022 = noiseAddress(_S1497, b_7);
                    Random _S2023 = draw(_S2022, 8U);
                    wrong_side_0 = density_8 < (_S2023.value);
                }
                else
                {
                    wrong_side_0 = false;
                }
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S2024 = density_7 * density_8;
            density_8 = _S2024;
        }
        else
        {
            density_8 = density_7;
        }
        uint _S2025 = layer_0 ^ 1U;
        uint _S2026 = _slang_select(passes_0, _S2025,0U);
        if(passes_0)
        {
            (&prev_1)->rough = false;
            (&hit_4)->distance = 0.0f;
            b_10 = b_7;
            viewed_0 = viewed_1;
            throughput_3 = throughput_11;
            density_3 = density_8;
            sky_pdf_1 = sky_pdf_3;
            spread_1 = spread_4;
            uint _S2027 = b_10 + 1U;
            b_7 = _S2027;
            layer_0 = _S2026;
            continue;
        }
        FKRay _S2028 = ray_3;
        float _S2029 = distance_1(reconnection_0, (&ray_3)->origin) * 1.0010000467300415f;
        if(replay_2)
        {
            refracted_4 = _S1717;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S1474 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S2030 = _slang_select(wrong_side_0, _S2029,4.294967296e+09f);
        bool _S2031 = !_S1679;
        if(straight_0)
        {
            _S1763 = true;
        }
        else
        {
            _S1763 = _S1679;
        }
        FKHit _S2032;
        if(_S1763)
        {
            _S2032 = hit_4;
        }
        else
        {
            _S2032 = _S1734;
        }
        FKHit _S2033 = (fcptTraverseInstanceBVH((_S2028), (_S1617), (_S2030), (_S2031), (_S2032), (viewed_1)));
        hit_4 = _S2033;
        if(replay_2)
        {
            _S1764 = _S1717;
        }
        else
        {
            _S1764 = false;
        }
        if(_S1764)
        {
            _S1831 = _S1474 == 1U;
        }
        else
        {
            _S1831 = false;
        }
        if(_S1831)
        {
            _S1832 = ((&hit_4)->instance_index) == (_S1486.instance_index);
        }
        else
        {
            _S1832 = false;
        }
        if(_S1832)
        {
            _S1833 = ((&hit_4)->triangle_index) == (_S1486.triangle_index);
        }
        else
        {
            _S1833 = false;
        }
        if(_S1833)
        {
            (&hit_4)->uv = _S1486.uv;
            float _S2034 = distance_1(reconnection_0, (&ray_3)->origin);
            (&hit_4)->distance = _S2034;
        }
        if(replay_2)
        {
            _S1834 = _S1717;
        }
        else
        {
            _S1834 = false;
        }
        if(_S1834)
        {
            _S1835 = _S1474 == 3U;
        }
        else
        {
            _S1835 = false;
        }
        if(_S1835)
        {
            _S1836 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1836 = false;
        }
        if(_S1836)
        {
            return _S1470;
        }
        Reservoir _S2035 = chain_1;
        uint _S2036 = filling_2;
        for(;;)
        {
            bool _S2037 = (fcptVaryingUsed());
            if(_S2037)
            {
                _S1837 = _S2036 != 4294967295U;
            }
            else
            {
                _S1837 = false;
            }
            float _S2038;
            if(_S1837)
            {
                float _S2039 = (fcptMajorant((_S2036)));
                _S2038 = _S2039;
            }
            else
            {
                _S2038 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_2)
            {
                _S1838 = _S1717;
            }
            else
            {
                _S1838 = false;
            }
            if(_S1838)
            {
                _S1839 = _S1474 == 1U;
            }
            else
            {
                _S1839 = false;
            }
            if(_S1839)
            {
                _S1840 = _S2038 > 0.0f;
            }
            else
            {
                _S1840 = false;
            }
            if(_S1840)
            {
                ended_0 = _S1470;
                sky_pdf_2 = sky_pdf_3;
                spread_2 = spread_4;
                width_4 = width_3;
                density_4 = density_8;
                throughput_12 = throughput_11;
                b_10 = b_7;
                _S1841 = true;
                break;
            }
            bool _S2040 = (&prev_1)->rough;
            if(_S2040)
            {
                _S1841 = !(_S2038 > 0.0f);
            }
            else
            {
                _S1841 = false;
            }
            (&prev_1)->rough = _S1841;
            uint _S2041 = b_7 + 320U;
            bool _S2042 = b_7 == 4294967295U;
            uint _S2043 = _slang_select(_S2042, 384U,_S2041);
            uint _S2044 = stream(_S1497, _S2043);
            uint tracking_1 = _S2044;
            weight_2 = throughput_4;
            glowed_0 = _S1469;
            b_10 = b_7;
            throughput_12 = throughput_11;
            density_4 = density_8;
            spread_2 = spread_4;
            width_4 = width_3;
            sky_pdf_2 = sky_pdf_3;
            for(;;)
            {
                if(((&hit_4)->instance_index) != 4294967295U)
                {
                }
                else
                {
                    _S1468 = int(2);
                    break;
                }
                float _S2045 = (&hit_4)->distance;
                if(_S1837)
                {
                    float3  _S2046 = (&ray_3)->origin;
                    float3  _S2047 = (&ray_3)->unit_direction;
                    float _S2048 = (&hit_4)->distance;
                    bool _S2049 = b_10 == 4294967295U;
                    uint _S2050 = _slang_select(_S2049, 0U,b_10);
                    uint _S2051 = (&prev_1)->lobe;
                    uint _S2052 = _slang_select(_S2049, 3U,_S2051);
                    float _S2053 = (fcptTrackMedium((_S2036), (_S2046), (_S2047), (_S2048), (&tracking_1), (&weight_2), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S2050), (_S2052), (_S2049)));
                    spread_3 = _S2053;
                }
                else
                {
                    bool _S2054 = _S2038 > 0.0f;
                    if(_S2054)
                    {
                        uint _S2055 = noiseAddress(_S1497, b_10);
                        Random _S2056 = draw(_S2055, 10U);
                        float _S2057 = - (F32_log((1.0f - _S2056.value))) / _S2038;
                        spread_3 = _S2057;
                    }
                    else
                    {
                        spread_3 = _S2045;
                    }
                }
                bool _S2058 = !(spread_3 < ((&hit_4)->distance));
                if(_S2058)
                {
                    _S1468 = int(2);
                    break;
                }
                if(_S1837)
                {
                    _S1842 = _S1688;
                }
                else
                {
                    _S1842 = false;
                }
                if(_S1842)
                {
                    float3  _S2059 = pathColor(throughput_12 * glowed_0, spectral_weight_1, wavelength_9);
                    float3  _S2060 = _S2059 / make_float3 (density_4);
                    float3  _S2061 = sel_8->glow + _S2060;
                    sel_8->glow = _S2061;
                }
                else
                {
                }
                glowed_0 = _S1469;
                uint b_11 = b_10 + 1U;
                float3  _S2062 = (&ray_3)->origin + make_float3 (spread_3) * (&ray_3)->unit_direction;
                (&ray_3)->origin = _S2062;
                float3  _S2063 = flightWeight_0(scatter_in_0, extinction_in_0, _S2038, spread_3, true);
                float3  _S2064 = weight_2;
                float _S2065 = upsample(weight_2, wavelength_9);
                float3  _S2066 = make_float3 (_S2065);
                float3  _S2067 = _slang_select(_S1711, _S2066,_S2064);
                float3  _S2068 = _slang_select(_S1837, _S2067,_S2063);
                float3  throughput_13 = throughput_12 * _S2068;
                uint _S2069 = stream(_S1497, b_11 + 320U);
                tracking_1 = _S2069;
                weight_2 = throughput_4;
                float width_8 = width_4 + spread_2 * spread_3;
                float _S2070 = spread_2 + 3.14159274101257324f;
                if(_S1688)
                {
                    _S1843 = true;
                }
                else
                {
                    bool _S2071 = b_11 == _S1485;
                    if(_S2071)
                    {
                        _S1843 = !_S1837;
                    }
                    else
                    {
                        _S1843 = false;
                    }
                }
                TreeSample light_4;
                if(_S1843)
                {
                    float3  _S2072 = (&ray_3)->origin;
                    float3  _S2073 = (&ray_3)->unit_direction;
                    float3  _S2074 = (&ray_3)->unit_direction;
                    uint _S2075 = noiseAddress(_S1497, b_11);
                    float3  _S2076 = extinction_in_0;
                    float3  _S2077 = extinction_in_0;
                    uint2  _S2078 = make_uint2 (_S2036);
                    float3  _S2079 = (&ray_3)->unit_direction;
                    uint _S2080 = arrivalLobe_0(b_11, (&prev_1)->lobe);
                    FKHit _S2081 = _S1734;
                    ShadowContext _S2082 = ShadowContext_x24init_0(_S2076, _S2077, _S2078, _S2079, b_11, _S2080, false, spread_3, width_8, &_S2081, false);
                    ShadowContext _S2083 = _S2082;
                    TreeSample _S2084 = sampleLightTree_0(_S2072, _S2073, _S2074, 0.0f, true, _S2075, &_S2083);
                    light_4 = _S2084;
                }
                else
                {
                    light_4 = _S1731;
                }
                float _S2085 = phaseHG_0(g_in_0, dot_0((&ray_3)->unit_direction, light_4.dir));
                uint _S2086 = (fcptMaxBounces());
                bool _S2087 = b_11 < _S2086;
                if(_S2087)
                {
                    _S1844 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1844 = false;
                }
                float _S2088 = _slang_select(_S1844, _S2085,0.0f);
                float3  _S2089 = throughput_13 * light_4.radiance;
                float _S2090 = powerHeuristic(light_4.density, _S2088);
                float3  _S2091 = pathColor(_S2089 * make_float3 (_S2085 * _S2090), spectral_weight_1, wavelength_9);
                float3  _S2092 = _slang_select(_S1843, _S2091,_S1469);
                if(replay_2)
                {
                    _S1845 = b_11 == _S1485;
                }
                else
                {
                    _S1845 = false;
                }
                if(_S1845)
                {
                    bool _S2093 = _S1474 == 2U;
                    if(_S2093)
                    {
                        float _S2094 = resamplingTarget(_S2092);
                        _S1846 = _S2094 > 0.0f;
                    }
                    else
                    {
                        _S1846 = false;
                    }
                    if(_S1846)
                    {
                        Shift _S2095 = Shift_x24init_0(_S2092, 1.0f);
                        _S1468 = int(1);
                        ended_0 = _S2095;
                        spread_3 = _S2070;
                        width_5 = width_8;
                        throughput_10 = throughput_13;
                        b_8 = b_11;
                        break;
                    }
                    _S1468 = int(1);
                    ended_0 = _S1470;
                    spread_3 = _S2070;
                    width_5 = width_8;
                    throughput_10 = throughput_13;
                    b_8 = b_11;
                    break;
                }
                if(_S1688)
                {
                    Reservoir candidate_9 = _S2035;
                    uint _S2096 = extractBits_0(_S2035.path, 24U, 8U);
                    uint _S2097 = insertBits_0(0U, _S2096, 24U, 8U);
                    uint _S2098 = extractBits_0(_S2035.path, 10U, 2U);
                    bool _S2099 = _S2098 == 1U;
                    if(_S2099)
                    {
                        float3  _S2100 = safeDivide(_S2092, chain_throughput_1);
                        (&candidate_9)->radiance = _S2100;
                    }
                    else
                    {
                        uint _S2101 = insertBits_0(_S2097, b_11 + 1U, 5U, 5U);
                        uint _S2102 = insertBits_0(_S2101, 2U, 10U, 2U);
                        (&candidate_9)->path = _S2102;
                    }
                    Reservoir _S2103 = withEnd(candidate_9, 0U, b_11, _S2092);
                    offer(sel_8, _S2103, _S2092 * make_float3 (scale_4) / make_float3 (density_4));
                    float _S2104 = survivalProbability(abs_0(throughput_13), density_4);
                    uint _S2105 = (fcptMaxBounces());
                    bool _S2106 = b_11 >= _S2105;
                    if(_S2106)
                    {
                        _S1846 = true;
                    }
                    else
                    {
                        bool _S2107 = _S2104 < 1.0f;
                        if(_S2107)
                        {
                            uint _S2108 = noiseAddress(_S1497, b_11);
                            Random _S2109 = draw(_S2108, 8U);
                            _S1846 = _S2104 < (_S2109.value);
                        }
                        else
                        {
                            _S1846 = false;
                        }
                    }
                    if(_S1846)
                    {
                        _S1468 = int(1);
                        ended_0 = _S1470;
                        spread_3 = _S2070;
                        width_5 = width_8;
                        throughput_10 = throughput_13;
                        b_8 = b_11;
                        break;
                    }
                    float _S2110 = density_4 * _S2104;
                    density_4 = _S2110;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S2111 = noiseAddress(_S1497, b_11);
                float3  _S2112 = samplePhase_0(g_in_0, (&ray_3)->unit_direction, _S2111, &phase_pdf_1);
                (&ray_3)->unit_direction = _S2112;
                NEEVertex _S2113 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_3)->origin, _S1469, (&ray_3)->origin);
                nee_vertex_1 = _S2113;
                Vertex _S2114 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_5);
                prev_1 = _S2114;
                float _S2115 = (&prev_1)->pdf;
                FKRay _S2116 = ray_3;
                FKHit _S2117 = (fcptTraverseInstanceBVH((_S2116), (true), (4.294967296e+09f), (false), (_S1734), (false)));
                hit_4 = _S2117;
                b_10 = b_11;
                throughput_12 = throughput_13;
                spread_2 = _S2070;
                width_4 = width_8;
                sky_pdf_2 = _S2115;
            }
            if(_S1468 != int(2))
            {
                spread_2 = spread_3;
                width_4 = width_5;
                throughput_12 = throughput_10;
                b_10 = b_8;
                _S1841 = true;
                break;
            }
            ended_0 = _S1470;
            _S1841 = false;
            break;
        }
        if(_S1841)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1842 = b_10 == b_7;
        }
        else
        {
            _S1842 = false;
        }
        bool _S2118 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S2118)
        {
            Reservoir _S2119 = chain_1;
            FKRay _S2120 = ray_3;
            Vertex _S2121 = prev_1;
            NEEVertex _S2122 = nee_vertex_1;
            Shift _S2123 = escape_0(r_9, replay_2, _S1485, _S1474, _S1472, _S1475, scale_4, _S1499, &_S2119, chain_throughput_1, b_10, &_S2120, throughput_12, density_4, &_S2121, &_S2122, sky_pdf_2, spectral_weight_1, wavelength_9, sel_8);
            return _S2123;
        }
        FKHit _S2124 = hit_4;
        uint _S2125 = filling_2;
        float3  _S2126 = scatter_in_0;
        float3  _S2127 = extinction_in_0;
        float3  _S2128 = weight_2;
        float3  _S2129 = glowed_0;
        float3  _S2130 = (&ray_3)->origin + make_float3 (_S2124.distance) * (&ray_3)->unit_direction;
        (&ray_3)->origin = _S2130;
        bool _S2131 = (fcptVaryingUsed());
        if(_S2131)
        {
            _S1843 = _S2125 != 4294967295U;
        }
        else
        {
            _S1843 = false;
        }
        if(_S1843)
        {
            if(_S1688)
            {
                float3  _S2132 = pathColor(throughput_12 * _S2129, spectral_weight_1, wavelength_9);
                float3  _S2133 = _S2132 / make_float3 (density_4);
                float3  _S2134 = sel_8->glow + _S2133;
                sel_8->glow = _S2134;
            }
            else
            {
            }
            float3  _S2135 = throughput_12 * _S2128;
            throughput_10 = _S2135;
        }
        else
        {
            float3  _S2136 = flightWeight_0(_S2126, _S2127, (_S2126.x + _S2126.y + _S2126.z) / 3.0f, _S2124.distance, false);
            float3  _S2137 = throughput_12 * _S2136;
            throughput_10 = _S2137;
        }
        float width_9 = width_4 + spread_2 * _S2124.distance;
        viewed_0 = _S1842;
        width_3 = width_9;
        throughput_3 = throughput_10;
        density_3 = density_4;
        sky_pdf_1 = sky_pdf_2;
        spread_1 = spread_2;
        uint _S2027 = b_10 + 1U;
        b_7 = _S2027;
        layer_0 = _S2026;
    }
    return _S1470;
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

__device__ Random normal_distribution(uint state_4)
{
    Random _S2138 = pcg(state_4);
    Random _S2139 = pcg(_S2138.state);
    float _S2140 = 6.28318548202514648f * _S2138.value;
    float _S2141 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S2139.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S2139.state, _S2141 * (F32_cos((_S2140))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_5, float3  value_2)
{
    RandomSphere _S2142;
    (&_S2142)->state = state_5;
    (&_S2142)->value = value_2;
    return _S2142;
}

__device__ RandomSphere random_sphere(uint state_6)
{
    Random _S2143 = normal_distribution(state_6);
    Random _S2144 = normal_distribution(_S2143.state);
    Random _S2145 = normal_distribution(_S2144.state);
    float3  _S2146 = make_float3 (_S2143.value, _S2144.value, _S2145.value);
    float3  _S2147 = ((((_S2146)) * make_float3(rnorm3df(((_S2146)).x, ((_S2146)).y, ((_S2146)).z))));
    return RandomSphere_x24init_0(_S2145.state, _S2147);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_13)
{
    float3  _S2148 = p1_0 - p0_0;
    float3  _S2149 = p2_0 - p0_0;
    float2  _S2150 = uv1_0 - uv0_0;
    float2  _S2151 = uv2_0 - uv0_0;
    float _S2152 = _S2150.x;
    float _S2153 = _S2151.y;
    float _S2154 = _S2150.y;
    float _S2155 = _S2151.x;
    float _S2156 = _S2152 * _S2153 - _S2154 * _S2155;
    float _S2157 = 1.0f / _S2156;
    float3  t_24 = (_S2148 * make_float3 (_S2153) - _S2149 * make_float3 (_S2154)) * make_float3 (_S2157);
    float3  _S2158 = (_S2149 * make_float3 (_S2152) - _S2148 * make_float3 (_S2155)) * make_float3 (_S2157);
    float3  _S2159 = t_24 - n_13 * make_float3 (dot_0(n_13, t_24));
    float3  t_25 = ((((_S2159)) * make_float3(rnorm3df(((_S2159)).x, ((_S2159)).y, ((_S2159)).z))));
    bool _S2160 = (dot_0(cross_0(n_13, t_25), _S2158)) > 0.0f;
    float3  t_26;
    if(_S2160)
    {
        float3  _S2161 = negate_0(t_25);
        t_26 = _S2161;
    }
    else
    {
        t_26 = t_25;
    }
    float3  _S2162 = cross_0(n_13, t_26);
    return makeMatrix<float, 3, 3> (t_26, _S2162, n_13);
}

__device__ float3  tangentToWorldNormalMap(float3  v_13, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_13, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_4, float3  uvw_0, float3  position_0)
{
    float3  _S2163 = t1_0 - t0_0;
    float3  _S2164 = t2_2 - t0_0;
    float3  _S2165 = t2_2 - t1_0;
    float _S2166 = (F32_min((length_0(_S2163)), ((F32_min((length_0(_S2164)), (length_0(_S2165)))))));
    float3  _S2167 = make_float3 (distance_1(position_0, t0_0), distance_1(position_0, t1_0), distance_1(position_0, t2_2));
    float3  _S2168 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S2169 = dot_0(geometry_n_4, _S2168);
    float3  _S2170 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S2171 = dot_0(geometry_n_4, _S2170);
    float3  _S2172 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S2173 = acos_0(abs_0(make_float3 (_S2169, _S2171, dot_0(geometry_n_4, _S2172))));
    float3  _S2174 = clamp_2(tan_0(_S2173), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S2167 * _S2174, uvw_0), 0.0f, _S2166 * 0.125f);
}

__device__ float3  straightThrough(float3  dir_15, float3  n_14, BSDFMaterial material_29)
{
    float3  _S2175 = negate_0(dir_15);
    float _S2176 = sign_0(dot_0(n_14, _S2175));
    float3  _S2177 = n_14 * make_float3 (_S2176);
    AnisotropicFrame _S2178 = anisotropicFrame(material_29, _S2177);
    bool _S2179 = (_S2178.alphas.x) > 0.0f;
    if(_S2179)
    {
        float _S2180 = material_29.transmission * (1.0f - material_29.metallic);
        float3  _S2181 = negate_0(_S2177);
        float3  _S2182 = anisotropicLocal(dir_15, _S2178.tangent, _S2181);
        float _S2183 = anisotropicG1(_S2182, _S2178.alphas);
        return make_float3 (_S2180 * _S2183) * material_29.albedo;
    }
    float _S2184 = material_29.transmission * (1.0f - material_29.metallic);
    float _S2185 = material_29.roughness;
    float _S2186 = smithG1(_S2185 * _S2185, (F32_abs((dot_0(n_14, dir_15)))));
    return make_float3 (_S2184 * _S2186) * material_29.albedo;
}

__device__ float hairRow(float3  in_dir_13, float3  t_27, float3  out_dir_3, uint p_15, float w_20, float alpha_9, uint nt_0)
{
    uint _S2187 = p_15 % 4U;
    float _S2188 = w_20 * HAIR_WIDTHS_0[_S2187];
    float _S2189 = (F32_asin((clamp_1(dot_0(out_dir_3, t_27), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_13, t_27), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S2187] * alpha_9;
    return ((F32_asinh((_S2189 / _S2188))) / (F32_asinh((3.14159274101257324f / _S2188))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_14, float3  t_28, float3  out_dir_4, uint np_0)
{
    float3  _S2190 = worldToTangent(out_dir_4, t_28);
    float3  _S2191 = worldToTangent(in_dir_14, t_28);
    return (F32_frac((((F32_atan2((_S2190.z), (_S2190.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S2191.z), (1.17549435082228751e-38f - _S2191.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_15, float3  t_29, uint p_16, float row_0, float column_0, float w_21, float alpha_10, uint nt_1, uint np_1)
{
    float3  _S2192 = worldToTangent(in_dir_15, t_29);
    uint _S2193 = p_16 % 4U;
    float _S2194 = w_21 * HAIR_WIDTHS_0[_S2193];
    float _S2195 = (F32_asin((clamp_1(dot_0(in_dir_15, t_29), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S2193] * alpha_10 + _S2194 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S2194))))));
    float _S2196 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S2192.z), (1.17549435082228751e-38f - _S2192.x)));
    float _S2197 = (F32_cos((_S2195)));
    float3  _S2198 = tangentToWorld(make_float3 (_S2197 * (F32_cos((_S2196))), (F32_sin((_S2195))), _S2197 * (F32_sin((_S2196)))), t_29);
    return _S2198;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_15, BSDFMaterial material_30, float coverage_1)
{
    float3  through_2;
    if((material_30.ior) == 1.0f)
    {
        float3  _S2199 = straightThrough(toward_1, n_15, material_30);
        through_2 = _S2199;
    }
    else
    {
        through_2 = make_float3 (0.0f);
    }
    CoatFrame _S2200 = coatFrame(material_30, n_15);
    bool _S2201 = (_S2200.ior) > 0.0f;
    if(_S2201)
    {
        float _S2202 = fresnel((F32_abs((dot_0(_S2200.normal, toward_1)))), 1.0f, _S2200.ior);
        float3  _S2203 = mix_0(make_float3 (1.0f), make_float3 (1.0f - _S2202) * material_30.coat_tint, material_30.coat);
        float3  through_3 = through_2 * _S2203;
        through_2 = through_3;
    }
    return through_2 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_8, Reservoir r_10, bool replay_3, float scale_5, Selection * sel_9)
{
    Domain _S2204 = dom_8;
    Reservoir _S2205 = r_10;
    Shift _S2206 = walk_0(&_S2204, &_S2205, replay_3, scale_5, sel_9);
    return _S2206;
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
        uint _S2207;
        if(i_27 < 2U)
        {
            _S2207 = x_29;
        }
        else
        {
            _S2207 = (x_29 + size_0 / 2U) & (size_0 - 1U);
        }
        uint l_5 = _S2207;
        uint r_11 = y_8;
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
            uint _S2208 = hash(((r_11 ^ (t_30 << 16U)) ^ (k_4 << 28U)) ^ ((i_27 & 1U) << 31U));
            uint _S2209 = l_5 ^ (_S2208 & (size_0 - 1U));
            uint k_5 = k_4 + 1U;
            l_5 = r_11;
            r_11 = _S2209;
            k_4 = k_5;
        }
        uint _S2210 = l_5 + r_11 * size_0;
        uint _S2211 = size_0 * size_0;
        uint _S2212;
        if(_S2211 >= 65536U)
        {
            uint _S2213 = _S2210 / (_S2211 / 65536U);
            _S2212 = _S2213;
        }
        else
        {
            uint _S2214 = 65536U / _S2211;
            _S2212 = _S2210 * _S2214;
        }
        ranks_0[i_27] = _S2212;
        uint i_28 = i_27 + 1U;
        i_27 = i_28;
    }
    bool _S2215 = (ranks_0[int(0)]) == 65535U;
    bool _S2216;
    if(_S2215)
    {
        _S2216 = (ranks_0[int(1)]) == 65535U;
    }
    else
    {
        _S2216 = false;
    }
    bool _S2217 = (ranks_0[int(2)]) == 65535U;
    bool _S2218;
    if(_S2217)
    {
        _S2218 = (ranks_0[int(3)]) == 65535U;
    }
    else
    {
        _S2218 = false;
    }
    if(_S2216)
    {
        _S2216 = (ranks_0[int(3)]) != 65535U;
    }
    else
    {
        _S2216 = false;
    }
    if(_S2216)
    {
        _S2216 = true;
    }
    else
    {
        if(_S2218)
        {
            _S2216 = (ranks_0[int(1)]) != 65535U;
        }
        else
        {
            _S2216 = false;
        }
    }
    uint _S2219 = ranks_0[int(0)];
    if(_S2216)
    {
        i_27 = ranks_0[int(3)];
    }
    else
    {
        i_27 = ranks_0[int(1)];
    }
    return _S2219 | (i_27 << 16U);
}

__device__ uint3  noiseBlock(uint sweep_0, uint colour_0, uint block_0, uint size_1)
{
    uint _S2220 = hash(sweep_0 * 7919U + 1U);
    uint _S2221 = size_1 / 16U;
    uint _S2222 = block_0 % _S2221;
    uint _S2223 = block_0 / _S2221;
    uint _S2224 = _S2223 % _S2221;
    uint _S2225 = block_0 / (_S2221 * _S2221);
    uint3  _S2226 = make_uint3 (_S2222, _S2224, _S2225);
    uint3  _S2227 = make_uint3 (colour_0 & 1U, (colour_0 >> 1U) & 1U, colour_0 >> 2U);
    return _S2226 * make_uint3 (16U) + _S2227 * make_uint3 (8U) + make_uint3 (_S2220 & 7U, (_S2220 >> 3U) & 7U, (_S2220 >> 6U) & 7U);
}

#undef Matrix
