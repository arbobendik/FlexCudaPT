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

struct Random
{
    uint state;
    float value;
};

static __device__ float random_0(uint * state_0)
{
    uint _S297 = hash(*state_0);
    *state_0 = _S297;
    return float((*state_0) >> int(8)) * 5.9604644775390625e-08f;
}

static __device__ Random Random_x24init_0(uint state_1, float value_0)
{
    Random _S298;
    (&_S298)->state = state_1;
    (&_S298)->value = value_0;
    return _S298;
}

__device__ Random pcg(uint state_2)
{
    uint _S299 = state_2;
    float value_1 = random_0(&_S299);
    return Random_x24init_0(_S299, value_1);
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
    uint2  _S300 = (fcptEnvironmentCdfSize());
    uint2  _S301 = _S300 - make_uint2 (1U, 0U);
    float2  _S302 = make_float2 ((F32_atan2((- dir_2.y), (dir_2.x))) / 6.28318548202514648f + 0.5f, (F32_acos((clamp_1(dir_2.z, -1.0f, 1.0f)))) / 3.14159274101257324f);
    float2  _S303 = make_float2 ((float)_S301.x, (float)_S301.y);
    float2  _S304 = _S302 * _S303;
    uint2  _S305 = make_uint2 ((uint)_S304.x, (uint)_S304.y);
    uint2  _S306 = min_0(_S305, _S301 - make_uint2 (1U));
    float4  _S307 = (fcptEnvironmentCdf((_S306)));
    float _S308 = _S307.y;
    uint _S309 = _S301.x;
    float4  _S310 = (fcptEnvironmentCdf((make_uint2 (_S309, _S306.y))));
    float _S311 = _S308 * _S310.y;
    return _S311 * float(_S309 * _S301.y) / (19.73921012878417969f * length_1(float2 {dir_2.x, dir_2.y}));
}

__device__ float upsample(float3  rgb_0, float wavelength_0)
{
    float _S312 = dot_0(make_float3 (-0.08011700212955475f, 1.08901798725128174f, -0.00889899954199791f), rgb_0);
    float _S313 = dot_0(make_float3 (0.12177000194787979f, -1.22903203964233398f, 1.10724997520446777f), rgb_0);
    float _S314 = dot_0(make_float3 (1.17252397537231445f, -1.21603405475616455f, 0.04350199922919273f), rgb_0);
    float3  _S315 = make_float3 (_S312, _S313, _S314);
    float _S316 = (wavelength_0 - 0.44999998807907104f) / 0.02999999932944775f;
    float _S317 = (wavelength_0 - 0.63999998569488525f) / 0.03999999910593033f;
    return _S312 + _S313 * (F32_exp((-0.5f * _S316 * _S316))) + _S314 * (F32_exp((-0.5f * _S317 * _S317)));
}

__device__ BSDFMaterial atWavelength(BSDFMaterial material_0, float wavelength_1)
{
    BSDFMaterial at_0 = material_0;
    float _S318 = upsample(material_0.albedo, wavelength_1);
    float3  _S319 = make_float3 (_S318);
    (&at_0)->albedo = _S319;
    float _S320 = upsample(material_0.emissive, wavelength_1);
    float3  _S321 = make_float3 (_S320);
    (&at_0)->emissive = _S321;
    float _S322 = upsample(material_0.absorption, wavelength_1);
    float3  _S323 = make_float3 (_S322);
    (&at_0)->absorption = _S323;
    float _S324 = upsample(material_0.specular_tint, wavelength_1);
    float3  _S325 = make_float3 (_S324);
    (&at_0)->specular_tint = _S325;
    float _S326 = upsample(material_0.translucent, wavelength_1);
    float3  _S327 = make_float3 (_S326);
    (&at_0)->translucent = _S327;
    float _S328 = upsample(material_0.sheen, wavelength_1);
    float3  _S329 = make_float3 (_S328);
    (&at_0)->sheen = _S329;
    return at_0;
}

__device__ BSDFMaterial pathMaterial(BSDFMaterial material_1, float wavelength_2)
{
    BSDFMaterial _S330;
    if(wavelength_2 > 0.0f)
    {
        BSDFMaterial _S331 = atWavelength(material_1, wavelength_2);
        _S330 = _S331;
    }
    else
    {
        _S330 = material_1;
    }
    return _S330;
}

static __device__ float3  negate_0(float3  x_13)
{
    return - x_13;
}

static __device__ float sign_0(float e_1)
{
    float _S332;
    if(e_1 > 0.0f)
    {
        _S332 = 1.0f;
    }
    else
    {
        if(e_1 < 0.0f)
        {
            _S332 = -1.0f;
        }
        else
        {
            _S332 = 0.0f;
        }
    }
    return _S332;
}

struct AnisotropicFrame
{
    float3  tangent;
    float2  alphas;
};

static __device__ AnisotropicFrame AnisotropicFrame_x24init_0(float3  tangent_0, float2  alphas_0)
{
    AnisotropicFrame _S333;
    (&_S333)->tangent = tangent_0;
    (&_S333)->alphas = alphas_0;
    return _S333;
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_1)
{
    float3  a_1 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S334 = (F32_abs((dot_0(n_1, a_1)))) > 0.9999847412109375f;
    float3  a_2;
    if(_S334)
    {
        float3  _S335 = make_float3 (1.0f, 0.0f, 0.0f);
        a_2 = _S335;
    }
    else
    {
        a_2 = a_1;
    }
    float3  _S336 = cross_0(n_1, a_2);
    float3  _S337 = ((((_S336)) * make_float3(rnorm3df(((_S336)).x, ((_S336)).y, ((_S336)).z))));
    float3  _S338 = cross_0(n_1, _S337);
    return make_float3 (v_0.x) * _S337 + make_float3 (v_0.y) * n_1 + make_float3 (v_0.z) * _S338;
}

__device__ AnisotropicFrame anisotropicFrame(BSDFMaterial material_2, float3  n_i_0)
{
    float _S339 = material_2.roughness;
    float _S340 = _S339 * _S339;
    bool _S341 = (material_2.anisotropy) == 0.0f;
    bool _S342;
    if(_S341)
    {
        _S342 = true;
    }
    else
    {
        _S342 = !(_S340 > 0.0f);
    }
    if(_S342)
    {
        return AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f));
    }
    float3  _S343 = material_2.tangent - n_i_0 * make_float3 (dot_0(n_i_0, material_2.tangent));
    float3  _S344 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_i_0);
    bool _S345 = (dot_0(_S343, _S343)) > 0.0f;
    float3  _S346 = _slang_select(_S345, _S343,_S344);
    float3  _S347 = ((((_S346)) * make_float3(rnorm3df(((_S346)).x, ((_S346)).y, ((_S346)).z))));
    float _S348 = 6.28318548202514648f * material_2.anisotropic_rotation;
    float _S349 = (F32_sqrt((1.0f - 0.89999997615814209f * (F32_abs((material_2.anisotropy))))));
    float _S350 = 1.0f / _S349;
    bool _S351 = (material_2.anisotropy) < 0.0f;
    float _S352 = _slang_select(_S351, _S350,_S349);
    return AnisotropicFrame_x24init_0(_S347 * make_float3 ((F32_cos((_S348)))) + cross_0(n_i_0, _S347) * make_float3 ((F32_sin((_S348)))), make_float2 (_S340 / _S352, _S340 * _S352));
}

struct SheenProfile
{
    bool on;
    float albedo;
};

static __device__ SheenProfile SheenProfile_x24init_0(bool on_0, float albedo_0)
{
    SheenProfile _S353;
    (&_S353)->on = on_0;
    (&_S353)->albedo = albedo_0;
    return _S353;
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
    SheenProfile _S354 = SheenProfile_x24init_0(false, 0.0f);
    float _S355 = rgb_to_greyscale(material_3.sheen);
    bool _S356 = _S355 > 0.0f;
    SheenProfile profile_0;
    if(_S356)
    {
        float _S357 = clamp_1((F32_sqrt(((F32_max((dot_0(n_i_1, v_1)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S358 = (U32_min((uint(_S357)), (22U)));
        float _S359 = (F32_sqrt((0.05000000074505806f)));
        float _S360 = (F32_sqrt((0.10000000149011612f)));
        bool _S361 = (material_3.velvet) > 0.0f;
        float _S362 = _slang_select(_S361, _S360,_S359);
        float _S363 = (clamp_1((F32_sqrt(((F32_max((material_3.sheen_roughness), (0.0f)))))), _S362, 1.0f) - _S362) / (1.0f - _S362) * 23.0f;
        uint _S364 = (U32_min((uint(_S363)), (22U)));
        uint _S365 = _S358 * 24U + _S364;
        float _S366 = _S357 - float(_S358);
        float _S367 = _S363 - float(_S364);
        if(_S361)
        {
            uint _S368 = _S365 + 24U;
            float _S369 = VELVET_ALBEDO_0[_S365] + (VELVET_ALBEDO_0[_S368] - VELVET_ALBEDO_0[_S365]) * _S366;
            uint _S370 = _S365 + 1U;
            float _S371 = VELVET_ALBEDO_0[_S370] + (VELVET_ALBEDO_0[_S368 + 1U] - VELVET_ALBEDO_0[_S370]) * _S366;
            SheenProfile _S372 = SheenProfile_x24init_0(true, _S369 + (_S371 - _S369) * _S367);
            profile_0 = _S372;
        }
        else
        {
            uint _S373 = _S365 + 24U;
            float _S374 = SHEEN_ALBEDO_0[_S365] + (SHEEN_ALBEDO_0[_S373] - SHEEN_ALBEDO_0[_S365]) * _S366;
            uint _S375 = _S365 + 1U;
            float _S376 = SHEEN_ALBEDO_0[_S375] + (SHEEN_ALBEDO_0[_S373 + 1U] - SHEEN_ALBEDO_0[_S375]) * _S366;
            SheenProfile _S377 = SheenProfile_x24init_0(true, (F32_exp((_S374 + (_S376 - _S374) * _S367))));
            profile_0 = _S377;
        }
    }
    else
    {
        profile_0 = _S354;
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
    Weights _S378;
    (&_S378)->v_dot_h = v_dot_h_0;
    (&_S378)->refracted = refracted_1;
    (&_S378)->F = F_0;
    (&_S378)->reflect_weight = reflect_weight_0;
    (&_S378)->diffuse_weight = diffuse_weight_0;
    (&_S378)->refract_weight = refract_weight_0;
    (&_S378)->p_diffuse = p_diffuse_0;
    (&_S378)->p_reflect = p_reflect_0;
    (&_S378)->p_refract = p_refract_0;
    (&_S378)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S378)->p_toon = p_toon_0;
    (&_S378)->sheen = sheen_0;
    (&_S378)->toon = toon_0;
    return _S378;
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
    float3  _S379 = make_float3 (alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z);
    float3  _S380 = ((((_S379)) * make_float3(rnorm3df(((_S379)).x, ((_S379)).y, ((_S379)).z))));
    float _S381 = _S380.x;
    float _S382 = _S380.y;
    float _S383 = _S381 * _S381 + _S382 * _S382;
    float3  _S384;
    if(_S383 > 0.0f)
    {
        float3  _S385 = make_float3 (- _S382, _S381, 0.0f);
        float _S386 = (rsqrtf((_S383)));
        _S384 = _S385 * make_float3 (_S386);
    }
    else
    {
        _S384 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S387 = cross_0(_S380, _S384);
    float _S388 = (F32_sqrt((U1_0)));
    float _S389 = 6.28318548202514648f * U2_0;
    float _S390 = _S388 * (F32_cos((_S389)));
    float t2_0 = _S388 * (F32_sin((_S389)));
    float _S391 = 0.5f * (1.0f + _S380.z);
    float t2_1 = (1.0f - _S391) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S390 * _S390)))))) + _S391 * t2_0;
    float3  _S392 = make_float3 (_S390) * _S384 + make_float3 (t2_1) * _S387;
    float _S393 = unshared_0(_S390);
    float _S394 = unshared_0(_S390);
    float3  _S395 = _S392 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S393 * _S394 - t2_1 * t2_1))))))) * _S380;
    float3  _S396 = make_float3 (alpha_0 * _S395.x, alpha_0 * _S395.y, (F32_max((0.0f), (_S395.z))));
    float3  _S397 = ((((_S396)) * make_float3(rnorm3df(((_S396)).x, ((_S396)).y, ((_S396)).z))));
    return _S397;
}

__device__ float3  worldToTangent(float3  v_2, float3  n_3)
{
    float3  a_3 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S398 = (F32_abs((dot_0(n_3, a_3)))) > 0.9999847412109375f;
    float3  a_4;
    if(_S398)
    {
        float3  _S399 = make_float3 (1.0f, 0.0f, 0.0f);
        a_4 = _S399;
    }
    else
    {
        a_4 = a_3;
    }
    float3  _S400 = cross_0(n_3, a_4);
    float3  _S401 = ((((_S400)) * make_float3(rnorm3df(((_S400)).x, ((_S400)).y, ((_S400)).z))));
    float3  _S402 = cross_0(n_3, _S401);
    return make_float3 (dot_0(v_2, _S401), dot_0(v_2, n_3), dot_0(v_2, _S402));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_3, float3  n_i_2, float alpha_1, AnisotropicFrame frame_0, uint * random_state_2)
{
    Random _S403 = pcg(*random_state_2);
    Random _S404 = pcg(_S403.state);
    *random_state_2 = _S404.state;
    float _S405 = frame_0.alphas.x;
    bool _S406 = _S405 > 0.0f;
    if(_S406)
    {
        float3  _S407 = anisotropicLocal(v_3, frame_0.tangent, n_i_2);
        float _S408 = frame_0.alphas.y;
        float3  _S409 = make_float3 (_S405 * _S407.x, _S408 * _S407.y, _S407.z);
        float3  _S410 = ((((_S409)) * make_float3(rnorm3df(((_S409)).x, ((_S409)).y, ((_S409)).z))));
        float3  _S411 = sampleGGXVNDF(_S410, 1.0f, _S403.value, _S404.value);
        float3  _S412 = make_float3 (_S405 * _S411.x, _S408 * _S411.y, _S411.z);
        float3  _S413 = ((((_S412)) * make_float3(rnorm3df(((_S412)).x, ((_S412)).y, ((_S412)).z))));
        return make_float3 (_S413.x) * frame_0.tangent + make_float3 (_S413.y) * cross_0(n_i_2, frame_0.tangent) + make_float3 (_S413.z) * n_i_2;
    }
    float3  _S414 = worldToTangent(v_3, n_i_2);
    float3  _S415 = sampleGGXVNDF(float3 {_S414.x, _S414.z, _S414.y}, alpha_1, _S403.value, _S404.value);
    float3  _S416 = float3 {_S415.x, _S415.z, _S415.y};
    float3  _S417 = tangentToWorld(_S416, n_i_2);
    return _S417;
}

__device__ __forceinline__ float3  sampledHalf(float3  v_4, float3  n_i_3, float alpha_2, AnisotropicFrame frame_1, uint random_state_3)
{
    uint state_3 = random_state_3;
    float3  _S418 = sampleHalfVector(v_4, n_i_3, alpha_2, frame_1, &state_3);
    return _S418;
}

__device__ __forceinline__ float3  refractedHalf(float3  in_dir_0, float3  out_dir_0, float3  n_4, float eta_i_0, float eta_o_0)
{
    float3  _S419 = negate_0(in_dir_0);
    float3  _S420 = negate_0(make_float3 (eta_i_0) * _S419 + make_float3 (eta_o_0) * out_dir_0);
    float3  _S421 = ((((_S420)) * make_float3(rnorm3df(((_S420)).x, ((_S420)).y, ((_S420)).z))));
    float _S422 = sign_0(dot_0(n_4, _S419));
    float _S423 = sign_0(dot_0(_S420, n_4 * make_float3 (_S422)));
    return _S421 * make_float3 (_S423);
}

__device__ __forceinline__ float3  reflectedHalf(float3  in_dir_1, float3  out_dir_1)
{
    float3  _S424 = negate_0(in_dir_1);
    float3  _S425 = _S424 + out_dir_1;
    float3  _S426 = ((((_S425)) * make_float3(rnorm3df(((_S425)).x, ((_S425)).y, ((_S425)).z))));
    return _S426;
}

static __device__ float3  refract_0(float3  i_5, float3  n_5, float eta_0)
{
    float _S427 = dot_0(n_5, i_5);
    float _S428 = 1.0f - eta_0 * eta_0 * (1.0f - _S427 * _S427);
    if(_S428 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_5 - make_float3 (eta_0 * _S427 + (F32_sqrt((_S428)))) * n_5;
}

__device__ float fresnel(float cos_theta_0, float eta_i_1, float eta_o_1)
{
    float _S429 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S430 = eta_i_1 / eta_o_1 * _S429;
    bool _S431 = _S430 < 1.0f;
    float kr_0;
    if(_S431)
    {
        float _S432 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S430 * _S430))))));
        float _S433 = eta_o_1 * cos_theta_0;
        float _S434 = eta_i_1 * _S432;
        float _S435 = (_S433 - _S434) / (_S433 + _S434);
        float _S436 = eta_i_1 * cos_theta_0;
        float _S437 = eta_o_1 * _S432;
        float _S438 = (_S436 - _S437) / (_S436 + _S437);
        float _S439 = (_S435 * _S435 + _S438 * _S438) / 2.0f;
        kr_0 = _S439;
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
    float _S440 = dot_0(ggx_n_0, v_5);
    float _S441 = eta_i_2 / eta_o_2;
    float3  _S442 = refract_0(in_dir_2, ggx_n_0, _S441);
    float3  _S443 = ((((_S442)) * make_float3(rnorm3df(((_S442)).x, ((_S442)).y, ((_S442)).z))));
    float _S444 = (F32_min(((F32_sqrt((material_4.specular_level))) * (F32_abs((eta_i_2 - eta_o_2))) / (eta_i_2 + eta_o_2)), (0.9999847412109375f)));
    float _S445 = _S444 * _S444;
    float _S446 = (1.0f + _S444) / (1.0f - _S444);
    float _S447 = (F32_abs((_S440)));
    bool _S448 = eta_i_2 > eta_o_2;
    float sheen_component_0;
    if(_S448)
    {
        sheen_component_0 = _S446;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    float toon_component_0;
    if(_S448)
    {
        toon_component_0 = 1.0f;
    }
    else
    {
        toon_component_0 = _S446;
    }
    float _S449 = fresnel(_S447, sheen_component_0, toon_component_0);
    bool _S450 = (eta_i_2 * eta_i_2 * (1.0f - _S440 * _S440)) >= (eta_o_2 * eta_o_2);
    float3  _S451;
    if(_S450)
    {
        _S451 = make_float3 (1.0f);
    }
    else
    {
        float3  _S452 = material_4.specular_tint * make_float3 (_S445);
        _S451 = _S452 + (make_float3 (1.0f) - _S452) * make_float3 (_S449 - _S445) / make_float3 (1.0f - _S445);
    }
    float3  _S453 = make_float3 (1.0f);
    float3  _S454 = make_float3 (0.0f);
    float3  sheen_1;
    float3  scale_1;
    if(sheen_profile_0.on)
    {
        float _S455 = (F32_min((sheen_profile_0.albedo), (1.0f)));
        float3  _S456 = make_float3 (1.0f) - material_4.sheen * make_float3 (_S455);
        float _S457 = rgb_to_greyscale(material_4.sheen);
        float _S458 = _S457 * _S455;
        float3  _S459 = material_4.sheen / make_float3 ((F32_max((sheen_profile_0.albedo), (1.0f))));
        sheen_component_0 = _S458;
        sheen_1 = _S459;
        scale_1 = _S456;
    }
    else
    {
        sheen_component_0 = 0.0f;
        sheen_1 = _S454;
        scale_1 = _S453;
    }
    float _S460 = (F32_abs((material_4.toon.x)));
    bool _S461 = _S460 > 0.0f;
    float3  toon_1;
    if(_S461)
    {
        float _S462 = (F32_min((_S460), (1.0f)));
        float3  scale_2 = scale_1 * make_float3 (1.0f - _S462);
        float _S463 = rgb_to_greyscale(material_4.albedo);
        float _S464 = _S462 * _S463;
        float3  _S465 = make_float3 (_S462) * material_4.albedo;
        toon_component_0 = _S464;
        toon_1 = _S465;
        scale_1 = scale_2;
    }
    else
    {
        toon_component_0 = 0.0f;
        toon_1 = _S454;
    }
    bool _S466 = (material_4.metallic) > 0.0f;
    float3  rebounce_0;
    if(_S466)
    {
        float _S467 = frame_2.alphas.x;
        float _S468 = (F32_sqrt(((F32_min((_S467), (frame_2.alphas.y))))));
        bool _S469 = _S467 > 0.0f;
        float _S470 = _slang_select(_S469, _S468,material_4.roughness);
        float _S471 = _S470 * _S470;
        float _S472 = (F32_pow((_S471), (1.81585001945495605f))) * (2.15371990203857422f - 0.73285001516342163f * _S471) / (1.0f + 1.28094995021820068f * _S471);
        bool _S473 = _S471 > 0.0f;
        float _S474 = _slang_select(_S473, _S472,0.0f);
        float _S475 = clamp_1(dot_0(n_i_4, v_5), 0.0f, 1.0f);
        float _S476 = _S471 * _S470;
        float _S477 = (F32_min((1.00064504146575928f - _S470 * (0.00375499995425344f + _S475 * (-0.04133399948477745f + _S475 * (-0.90938502550125122f + _S475 * 0.35275399684906006f))) - _S471 * (0.27602800726890564f + _S475 * (1.27023398876190186f + _S475 * 0.04740000143647194f)) - _S476 * (0.31452900171279907f - _S475 * 0.34830701351165771f) + _S476 * _S470 * 0.27229699492454529f), (1.0f)));
        float3  _S478 = min_1(make_float3 (1.0f) / (make_float3 (1.0f) - material_4.albedo * make_float3 (_S474)), make_float3 (1.0f / (F32_max((_S477), (0.0000152587890625f)))));
        rebounce_0 = _S478;
    }
    else
    {
        rebounce_0 = _S453;
    }
    float3  _S479 = mix_0(_S451, material_4.albedo * rebounce_0, material_4.metallic);
    float3  F_1 = _S479 * scale_1;
    float _S480 = rgb_to_greyscale(F_1);
    float _S481 = 1.0f - material_4.metallic;
    float3  _S482 = make_float3 (1.0f) - _S451;
    float3  _S483 = make_float3 ((1.0f - material_4.transmission) * _S481) * _S482 * scale_1;
    float3  _S484 = make_float3 (material_4.transmission * _S481) * _S482 * scale_1;
    float _S485 = (F32_max((_S480), (0.0f)));
    float _S486 = rgb_to_greyscale(_S483);
    float _S487 = (F32_max((_S486), (0.0f)));
    float _S488 = rgb_to_greyscale(_S484);
    float _S489 = sign_0(length_0(_S443));
    float _S490 = (F32_max((_S488 * _S489), (0.0f)));
    float _S491 = _S485 + _S487 + _S490 + toon_component_0;
    float _S492 = (F32_min((sheen_component_0), (1.0f)));
    bool _S493 = sheen_component_0 > 0.0f;
    bool _S494;
    if(_S493)
    {
        _S494 = !(_S491 > 0.0f);
    }
    else
    {
        _S494 = false;
    }
    float _S495 = _slang_select(_S494, 1.0f,_S492);
    float _S496 = (1.0f - _S495) / (F32_max((_S491), (0.0000152587890625f)));
    float _S497 = _S487 * _S496;
    float _S498 = _S485 * _S496;
    float _S499 = _S490 * _S496;
    return Weights_x24init_0(_S440, _S443, F_1, 1.0f, _S483, _S484, _S497, _S498, _S499, _S495, toon_component_0 * _S496, sheen_1, toon_1);
}

__device__ float translucentShare(BSDFMaterial material_5)
{
    float _S500 = rgb_to_greyscale(material_5.translucent);
    float _S501 = rgb_to_greyscale(material_5.albedo);
    float _S502 = _S500 / (_S501 + _S500);
    bool _S503 = _S500 > 0.0f;
    float _S504 = _slang_select(_S503, _S502,0.0f);
    return _S504;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float n_i_dot_v_0, BSDFMaterial material_6, Weights w_1)
{
    float _S505 = translucentShare(material_6);
    float _S506 = w_1.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S507 = w_1.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S508 = 1.0f - _S505;
    bool _S509 = n_i_dot_l_0 < 0.0f;
    float _S510 = _slang_select(_S509, _S505,_S508);
    float _S511 = _S507 * _S510;
    bool _S512 = _S505 > 0.0f;
    float _S513 = _slang_select(_S512, _S511,_S506);
    bool _S514 = n_i_dot_v_0 > 0.0f;
    float _S515 = _slang_select(_S514, _S513,0.0f);
    return _S515;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_5, BSDFMaterial material_7, Weights w_2)
{
    float _S516 = translucentShare(material_7);
    bool _S517 = (dot_0(n_i_5, l_0)) < 0.0f;
    float3  _S518 = _slang_select(_S517, material_7.translucent,material_7.albedo);
    float _S519 = 1.0f - _S516;
    float _S520 = _slang_select(_S517, _S516,_S519);
    float3  _S521 = _S518 / make_float3 (_S520);
    bool _S522 = _S516 > 0.0f;
    float3  _S523 = _slang_select(_S522, _S521,material_7.albedo);
    return w_2.diffuse_weight * _S523 / make_float3 (w_2.p_diffuse);
}

__device__ float smithG1(float alpha_3, float n_dot_x_0)
{
    float _S524 = alpha_3 * alpha_3;
    float _S525 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S524 + (1.0f - _S524) * n_dot_x_0 * n_dot_x_0))));
    bool _S526 = alpha_3 > 0.0f;
    float _S527 = _slang_select(_S526, _S525,1.0f);
    return _S527;
}

__device__ float trowbridgeReitz(float alpha_4, float n_dot_h_0)
{
    float _S528 = alpha_4 * alpha_4;
    float _S529 = (1.0f - n_dot_h_0) * (1.0f + n_dot_h_0) + _S528 * n_dot_h_0 * n_dot_h_0;
    return _S528 / (F32_max((3.14159274101257324f * _S529 * _S529), (1.17549435082228751e-38f)));
}

__device__ float anisotropicG1(float3  w_3, float2  alphas_1)
{
    float _S530 = (F32_max((w_3.z), (0.0f)));
    return 2.0f * _S530 / (_S530 + length_0(make_float3 (alphas_1.x * w_3.x, alphas_1.y * w_3.y, _S530)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_2)
{
    float _S531 = alphas_2.x;
    float _S532 = h_0.x / _S531;
    float _S533 = alphas_2.y;
    float _S534 = h_0.y / _S533;
    float _S535 = h_0.z;
    float _S536 = _S532 * _S532 + _S534 * _S534 + _S535 * _S535;
    return 1.0f / (F32_max((3.14159274101257324f * _S531 * _S533 * _S536 * _S536), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float3  v_6, float3  h_1, float3  n_i_6, float n_i_dot_v_1, float alpha_5, AnisotropicFrame frame_3, float v_dot_h_1)
{
    float _S537 = dot_0(n_i_6, h_1);
    float _S538 = smithG1(alpha_5, n_i_dot_v_1);
    float _S539 = _S538 * v_dot_h_1;
    float _S540 = trowbridgeReitz(alpha_5, _S537);
    float _S541 = _S539 * _S540 / n_i_dot_v_1;
    bool _S542 = alpha_5 > 0.0f;
    bool _S543;
    if(_S542)
    {
        _S543 = v_dot_h_1 > 0.0f;
    }
    else
    {
        _S543 = false;
    }
    if(_S543)
    {
        _S543 = _S537 > 0.0f;
    }
    else
    {
        _S543 = false;
    }
    if(_S543)
    {
        _S543 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S543 = false;
    }
    float _S544 = _slang_select(_S543, _S541,0.0f);
    bool _S545 = (frame_3.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S545)
    {
        float3  _S546 = anisotropicLocal(v_6, frame_3.tangent, n_i_6);
        float _S547 = anisotropicG1(_S546, frame_3.alphas);
        float3  _S548 = anisotropicLocal(h_1, frame_3.tangent, n_i_6);
        float _S549 = anisotropicD(_S548, frame_3.alphas);
        float _S550 = _S547 * _S549;
        float _S551 = _S550 * v_dot_h_1 / n_i_dot_v_1;
        bool _S552 = v_dot_h_1 > 0.0f;
        if(_S552)
        {
            _S543 = _S537 > 0.0f;
        }
        else
        {
            _S543 = false;
        }
        if(_S543)
        {
            _S543 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S543 = false;
        }
        float _S553 = _slang_select(_S543, _S551,0.0f);
        pdf_h_0 = _S553;
    }
    else
    {
        pdf_h_0 = _S544;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float l_dot_h_0, float pdf_h_1, Weights w_4, float eta_i_3, float eta_o_3)
{
    float _S554 = eta_i_3 * w_4.v_dot_h + eta_o_3 * l_dot_h_0;
    float _S555 = w_4.p_refract * pdf_h_1 * eta_o_3 * eta_o_3 * (F32_abs((l_dot_h_0))) / (_S554 * _S554);
    bool _S556 = eta_i_3 != eta_o_3;
    bool _S557;
    if(_S556)
    {
        _S557 = l_dot_h_0 < 0.0f;
    }
    else
    {
        _S557 = false;
    }
    float _S558 = _slang_select(_S557, _S555,0.0f);
    return _S558;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_7, float alpha_6, AnisotropicFrame frame_4, BSDFMaterial material_8, Weights w_5)
{
    float _S559 = - dot_0(n_i_7, l_1);
    float _S560 = smithG1(alpha_6, (F32_max((_S559), (0.0f))));
    bool _S561 = (frame_4.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S561)
    {
        float3  _S562 = negate_0(n_i_7);
        float3  _S563 = anisotropicLocal(l_1, frame_4.tangent, _S562);
        float _S564 = anisotropicG1(_S563, frame_4.alphas);
        G1_l_0 = _S564;
    }
    else
    {
        G1_l_0 = _S560;
    }
    return w_5.refract_weight * make_float3 (G1_l_0) * material_8.albedo / make_float3 (w_5.p_refract);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_1, float n_i_dot_v_2, Weights w_6)
{
    float _S565 = w_6.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S566 = n_i_dot_l_1 > 0.0f;
    bool _S567;
    if(_S566)
    {
        _S567 = n_i_dot_v_2 > 0.0f;
    }
    else
    {
        _S567 = false;
    }
    float _S568 = _slang_select(_S567, _S565,0.0f);
    return _S568;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  v_7, float3  n_i_8, BSDFMaterial material_9, Weights w_7)
{
    float3  _S569 = l_2 + v_7;
    float3  _S570 = ((((_S569)) * make_float3(rnorm3df(((_S569)).x, ((_S569)).y, ((_S569)).z))));
    float _S571 = dot_0(n_i_8, _S570);
    float _S572 = (F32_max((dot_0(n_i_8, l_2)), (0.0f)));
    float _S573 = (F32_max((dot_0(n_i_8, v_7)), (0.0f)));
    float _S574 = 1.0f / (F32_max((material_9.sheen_roughness), (0.05000000074505806f)));
    float _S575 = 1.0f - _S571 * _S571;
    float _S576 = (2.0f + _S574) * (F32_pow(((F32_max((_S575), (0.0f)))), (0.5f * _S574))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S572 + _S573 - _S572 * _S573)), (0.0000152587890625f)));
    bool _S577 = (material_9.velvet) > 0.0f;
    float f_1;
    if(_S577)
    {
        float _S578 = (F32_max((material_9.sheen_roughness), (0.00999999977648258f)));
        float _S579 = _S578 * _S578;
        float _S580 = (F32_max((_S575), (0.0000152587890625f)));
        float _S581 = (F32_exp((- _S571 * _S571 / (_S580 * _S579)))) / (3.14159274101257324f * _S579 * _S580 * _S580) * (F32_min((1.0f), (2.0f * _S571 * (F32_min((_S572), (_S573))) / (F32_max(((F32_abs((dot_0(_S570, v_7))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S572 * _S573), (0.0000152587890625f)));
        f_1 = _S581;
    }
    else
    {
        f_1 = _S576;
    }
    return w_7.sheen * make_float3 (f_1 * _S572 * 2.0f * 3.14159274101257324f / w_7.p_sheen_velvet);
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
    float _S582;
    if(t_13 < a_5)
    {
        _S582 = 1.0f;
    }
    else
    {
        _S582 = (F32_max((1.0f - (t_13 - a_5) / (F32_max((s_0), (0.0000152587890625f)))), (0.0f)));
    }
    return _S582;
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
        float _S583 = (F32_sin(((F32_min((t_14), (a_6))))));
        integral_0 = _S583 * _S583 / 2.0f;
    }
    bool _S584 = t_14 > a_6;
    bool _S585;
    if(_S584)
    {
        _S585 = s_1 > 0.0f;
    }
    else
    {
        _S585 = false;
    }
    if(_S585)
    {
        float _S586;
        if(glossy_0)
        {
            float _S587 = (F32_cos((a_6)));
            float _S588 = (F32_cos((t_14)));
            _S586 = (1.0f + a_6 / s_1) * (_S587 - _S588) - ((F32_sin((t_14))) - t_14 * _S588 - ((F32_sin((a_6))) - a_6 * _S587)) / s_1;
        }
        else
        {
            float _S589 = 2.0f * a_6;
            float _S590 = (F32_cos((_S589)));
            float _S591 = 2.0f * t_14;
            float _S592 = (F32_cos((_S591)));
            _S586 = (1.0f + a_6 / s_1) * (_S590 - _S592) / 4.0f - ((F32_sin((_S591))) / 8.0f - t_14 * _S592 / 4.0f - ((F32_sin((_S589))) / 8.0f - a_6 * _S590 / 4.0f)) / s_1;
        }
        float integral_1 = integral_0 + _S586;
        integral_0 = integral_1;
    }
    return integral_0;
}

static __device__ ToonProfile ToonProfile_x24init_0(bool glossy_1, float a_7, float s_2, float b_1, float norm_0, float view_0, float3  axis_0)
{
    ToonProfile _S593;
    (&_S593)->glossy = glossy_1;
    (&_S593)->a = a_7;
    (&_S593)->s = s_2;
    (&_S593)->b = b_1;
    (&_S593)->norm = norm_0;
    (&_S593)->view = view_0;
    (&_S593)->axis = axis_0;
    return _S593;
}

__device__ __forceinline__ ToonProfile toonProfile(float3  v_8, float3  n_i_9, BSDFMaterial material_10)
{
    float _S594 = material_10.toon.x;
    bool _S595 = _S594 < 0.0f;
    float _S596 = clamp_1(material_10.toon.y / _S594, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S597 = clamp_1(material_10.toon.z / _S594, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S598 = (F32_min((_S596 + _S597), (1.57079637050628662f)));
    float _S599 = dot_0(n_i_9, v_8);
    float _S600 = toonP((F32_acos(((F32_min((_S599), (1.0f)))))), _S596, _S597);
    float3  _S601;
    if(_S595)
    {
        float3  _S602 = make_float3 (2.0f * _S599) * n_i_9 - v_8;
        float3  _S603 = ((((_S602)) * make_float3(rnorm3df(((_S602)).x, ((_S602)).y, ((_S602)).z))));
        _S601 = _S603;
    }
    else
    {
        _S601 = n_i_9;
    }
    float _S604 = toonIntegral(_S598, _S596, _S597, _S595);
    return ToonProfile_x24init_0(_S595, _S596, _S597, _S598, 6.28318548202514648f * _S604, _S600, _S601);
}

__device__ __forceinline__ float toonPDF(float3  l_3, float3  n_i_10, ToonProfile profile_1, Weights w_8)
{
    float _S605 = dot_0(n_i_10, l_3);
    float _S606 = dot_0(l_3, profile_1.axis);
    float _S607 = _slang_select(profile_1.glossy, _S606,_S605);
    float _S608 = (F32_acos((clamp_1(_S607, -1.0f, 1.0f))));
    float _S609 = toonP(_S608, profile_1.a, profile_1.s);
    float _S610 = w_8.p_toon * _S609;
    float _S611 = _slang_select(profile_1.glossy, 1.0f,_S605);
    float _S612 = _S610 * _S611 / profile_1.norm;
    bool _S613;
    if(profile_1.glossy)
    {
        _S613 = true;
    }
    else
    {
        _S613 = _S605 > 0.0f;
    }
    float _S614 = _slang_select(_S613, _S612,0.0f);
    return _S614;
}

__device__ __forceinline__ float3  toonBSDF(float3  l_4, float3  n_i_11, ToonProfile profile_2, Weights w_9)
{
    float _S615 = (F32_max((dot_0(n_i_11, l_4)), (0.0f)));
    float _S616 = _slang_select(profile_2.glossy, _S615,profile_2.view);
    return w_9.toon * make_float3 (_S616) / make_float3 (w_9.p_toon);
}

__device__ __forceinline__ float reflectPDF(float pdf_h_2, Weights w_10)
{
    float _S617 = w_10.p_reflect * pdf_h_2 / (4.0f * w_10.v_dot_h);
    bool _S618 = pdf_h_2 > 0.0f;
    float _S619 = _slang_select(_S618, _S617,0.0f);
    return _S619;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_5, float3  n_i_12, float alpha_7, AnisotropicFrame frame_5, Weights w_11)
{
    float _S620 = dot_0(n_i_12, l_5);
    float _S621 = smithG1(alpha_7, (F32_max((_S620), (0.0f))));
    bool _S622 = (frame_5.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S622)
    {
        float3  _S623 = anisotropicLocal(l_5, frame_5.tangent, n_i_12);
        float _S624 = anisotropicG1(_S623, frame_5.alphas);
        G1_l_1 = _S624;
    }
    else
    {
        G1_l_1 = _S621;
    }
    return make_float3 (w_11.reflect_weight * G1_l_1) * w_11.F / make_float3 (w_11.p_reflect);
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_3, float3  out_dir_2, float3  n_6, BSDFMaterial material_11, float eta_i_4, float eta_o_4, bool refracted_2, uint random_state_4, FixedArray<float3 , 5>  * throughputs_0, FixedArray<float, 5>  * pdfs_0)
{
    float3  ggx_n_1;
    float3  _S625 = negate_0(in_dir_3);
    float _S626 = dot_0(n_6, _S625);
    float _S627 = sign_0(_S626);
    float3  _S628 = n_6 * make_float3 (_S627);
    float _S629 = dot_0(_S628, out_dir_2);
    float _S630 = material_11.roughness;
    float _S631 = _S630 * _S630;
    AnisotropicFrame _S632 = anisotropicFrame(material_11, _S628);
    SheenProfile _S633 = sheenProfile(_S625, _S628, material_11);
    float _S634 = rgb_to_greyscale(material_11.translucent);
    bool _S635 = _S634 > 0.0f;
    bool _S636 = (dot_0(n_6, out_dir_2) * _S626) < 0.0f;
    bool _S637 = (F32_abs((material_11.toon.x))) > 0.0f;
    uint _S638;
    if(_S637)
    {
        _S638 = 5U;
    }
    else
    {
        _S638 = 4U;
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
        float3  _S639 = make_float3 (0.0f);
        (*throughputs_0)[i_7] = _S639;
        (*pdfs_0)[i_7] = 0.0f;
        uint i_8 = i_7 + 1U;
        i_7 = i_8;
    }
    float3  _S640 = make_float3 (0.0f);
    Weights _S641 = Weights_x24init_0(0.0f, _S640, _S640, 0.0f, _S640, _S640, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, _S640, _S640);
    uint half_of_0 = 4294967295U;
    Weights w_12 = _S641;
    float3  ggx_n_2 = _S640;
    i_7 = 0U;
    for(;;)
    {
        if(i_7 < _S638)
        {
        }
        else
        {
            break;
        }
        uint _S642;
        if(i_7 == 3U)
        {
            _S642 = 4U;
        }
        else
        {
            if(i_7 == 4U)
            {
                _S642 = 6U;
            }
            else
            {
                _S642 = i_7;
            }
        }
        bool _S643 = _S642 == 0U;
        bool _S644;
        if(_S643)
        {
            _S644 = _S635;
        }
        else
        {
            _S644 = false;
        }
        bool _S645;
        if(_S644)
        {
            _S645 = _S636;
        }
        else
        {
            _S645 = _S642 == 1U;
        }
        bool _S646 = _S645 != refracted_2;
        if(_S646)
        {
            ggx_n_1 = ggx_n_2;
            uint i_9 = i_7 + 1U;
            ggx_n_2 = ggx_n_1;
            i_7 = i_9;
            continue;
        }
        uint _S647;
        if(_S642 == 6U)
        {
            _S647 = 0U;
        }
        else
        {
            if(_S642 == 4U)
            {
                _S647 = 2U;
            }
            else
            {
                _S647 = _S642;
            }
        }
        bool _S648 = _S647 != half_of_0;
        uint half_of_1;
        Weights w_13;
        if(_S648)
        {
            bool _S649 = _S647 == 0U;
            if(_S649)
            {
                float3  _S650 = sampledHalf(_S625, _S628, _S631, _S632, random_state_4);
                ggx_n_1 = _S650;
            }
            else
            {
                bool _S651 = _S647 == 1U;
                if(_S651)
                {
                    float3  _S652 = refractedHalf(in_dir_3, out_dir_2, n_6, eta_i_4, eta_o_4);
                    ggx_n_1 = _S652;
                }
                else
                {
                    float3  _S653 = reflectedHalf(in_dir_3, out_dir_2);
                    ggx_n_1 = _S653;
                }
            }
            Weights _S654 = lobeWeights(in_dir_3, _S625, _S628, ggx_n_1, _S632, _S633, material_11, eta_i_4, eta_o_4);
            w_13 = _S654;
            half_of_1 = _S647;
        }
        else
        {
            w_13 = w_12;
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S642)
        {
        case 0U:
            {
                float _S655 = diffusePDF(_S629, (F32_abs((_S626))), material_11, w_13);
                (*pdfs_0)[int(0)] = _S655;
                float3  _S656 = diffuseBSDF(out_dir_2, _S628, material_11, w_13);
                (*throughputs_0)[int(0)] = _S656;
                break;
            }
        case 1U:
            {
                float _S657 = dot_0(out_dir_2, ggx_n_1);
                float _S658 = vndfPDF(_S625, ggx_n_1, _S628, (F32_abs((_S626))), _S631, _S632, w_13.v_dot_h);
                float _S659 = refractPDF(_S657, _S658, w_13, eta_i_4, eta_o_4);
                (*pdfs_0)[int(1)] = _S659;
                float3  _S660 = refractBSDF(out_dir_2, _S628, _S631, _S632, material_11, w_13);
                (*throughputs_0)[int(1)] = _S660;
                break;
            }
        case 4U:
            {
                float _S661 = sheenVelvetPDF(_S629, (F32_abs((_S626))), w_13);
                (*pdfs_0)[int(3)] = _S661;
                float3  _S662 = sheenVelvetBSDF(out_dir_2, _S625, _S628, material_11, w_13);
                (*throughputs_0)[int(3)] = _S662;
                break;
            }
        case 6U:
            {
                ToonProfile _S663 = toonProfile(_S625, _S628, material_11);
                float _S664 = toonPDF(out_dir_2, _S628, _S663, w_13);
                (*pdfs_0)[int(4)] = _S664;
                float3  _S665 = toonBSDF(out_dir_2, _S628, _S663, w_13);
                (*throughputs_0)[int(4)] = _S665;
                break;
            }
        default:
            {
                float _S666 = vndfPDF(_S625, ggx_n_1, _S628, (F32_abs((_S626))), _S631, _S632, w_13.v_dot_h);
                float _S667 = reflectPDF(_S666, w_13);
                (*pdfs_0)[int(2)] = _S667;
                float3  _S668 = reflectBSDF(out_dir_2, _S628, _S631, _S632, w_13);
                (*throughputs_0)[int(2)] = _S668;
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
    ggx_n_1 = _S640;
    for(;;)
    {
        if(i_7 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S669 = ((*pdfs_0)[i_7]) > 0.0f;
        if(_S669)
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
    bool _S670 = wrongSide_0(is_inside_2, false, dir_3, surface_1->geometry_n);
    float3  _S671 = BSDF(in_dir_4, dir_3, surface_1->smooth_n, *material_12, eta_1.x, eta_1.y, _S670, random_state_5, terms_0, pdfs_1);
    float3  _S672 = make_float3 (0.0f);
    uint i_11 = 0U;
    float3  f_3 = _S672;
    for(;;)
    {
        if(i_11 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S673 = ((*pdfs_1)[i_11]) > 0.0f;
        if(_S673)
        {
            float3  _S674 = (*terms_0)[i_11] * make_float3 ((*pdfs_1)[i_11]) / make_float3 ((*pdfs_1)[i_11] + pdf_0);
            (*terms_0)[i_11] = _S674;
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
    FKSurface _S675 = surface_2;
    BSDFMaterial _S676 = material_13;
    FixedArray<float3 , 5>  terms_1;
    FixedArray<float, 5>  pdfs_2;
    float3  _S677 = skyLobes_0(in_dir_5, dir_4, &_S675, &_S676, eta_2, is_inside_3, pdf_1, random_state_6, &terms_1, &pdfs_2);
    return _S677;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_5, float3  radiance_0, float3  color_0, uint random_state_7)
{
    SkySample _S678;
    (&_S678)->dir = dir_5;
    (&_S678)->radiance = radiance_0;
    (&_S678)->color = color_0;
    (&_S678)->random_state = random_state_7;
    return _S678;
}

static __device__ __noinline__ float3  skyColor_0(float3  in_dir_6, float3  dir_6, FKSurface * surface_3, float wavelength_3, float2  eta_3, bool is_inside_4, float pdf_2, uint random_state_8, uint depth_0)
{
    BSDFMaterial _S679 = pathMaterial(surface_3->material, wavelength_3);
    BSDFMaterial _S680 = _S679;
    FixedArray<float3 , 5>  terms_2;
    FixedArray<float, 5>  pdfs_3;
    float3  _S681 = skyLobes_0(in_dir_6, dir_6, surface_3, &_S680, eta_3, is_inside_4, pdf_2, random_state_8, &terms_2, &pdfs_3);
    float3  _S682 = make_float3 (0.0f);
    bool shaded_0 = false;
    float3  world_0 = _S682;
    uint i_13 = 0U;
    float3  color_1 = _S682;
    for(;;)
    {
        if(i_13 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S683 = (pdfs_3[i_13]) > 0.0f;
        if(_S683)
        {
            bool _S684 = (fcptWorldReadsPath());
            bool _S685;
            if(_S684)
            {
                _S685 = true;
            }
            else
            {
                _S685 = !shaded_0;
            }
            bool shaded_1;
            float3  world_1;
            if(_S685)
            {
                uint _S686;
                if(i_13 == 3U)
                {
                    _S686 = 4U;
                }
                else
                {
                    if(i_13 == 4U)
                    {
                        _S686 = 6U;
                    }
                    else
                    {
                        _S686 = i_13;
                    }
                }
                float3  _S687 = (fcptEnvMapSample((dir_6), (depth_0), (_S686)));
                world_1 = _S687;
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
    uint2  _S688 = (fcptEnvironmentCdfSize());
    uint2  _S689 = make_uint2 (1U, 0U);
    uint2  _S690 = _S688 - _S689;
    Random _S691 = pcg(init_random_state_0);
    Random _S692 = pcg(_S691.state);
    Random _S693 = pcg(_S692.state);
    Random _S694 = pcg(_S693.state);
    uint _S695 = _S690.x;
    uint _S696 = searchCDF_0(make_uint2 (_S695, 0U), make_uint2 (0U, 1U), _S690.y, _S691.value);
    uint _S697 = searchCDF_0(make_uint2 (0U, _S696), _S689, _S695, _S692.value);
    float2  _S698 = make_float2 ((float)_S690.x, (float)_S690.y);
    float2  _S699 = (make_float2 (float(_S697), float(_S696)) + make_float2 (_S693.value, _S694.value)) / _S698 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S700 = _S699.y;
    float _S701 = (F32_sin((_S700)));
    float _S702 = _S699.x;
    float3  _S703 = make_float3 (- _S701 * (F32_cos((_S702))), _S701 * (F32_sin((_S702))), (F32_cos((_S700))));
    float _S704 = environmentPdf_0(_S703);
    BSDFMaterial _S705 = pathMaterial(surface_4->material, wavelength_4);
    float3  _S706 = ray_0->unit_direction;
    float3  _S707 = skyBSDF(ray_0->unit_direction, _S703, *surface_4, _S705, eta_4, is_inside_5, _S704, lobe_state_0);
    bool _S708 = !(_S704 > 0.0f);
    bool _S709;
    if(_S708)
    {
        _S709 = true;
    }
    else
    {
        _S709 = all_1(_S707 == make_float3 (0.0f));
    }
    if(_S709)
    {
        float3  _S710 = make_float3 (0.0f);
        return SkySample_x24init_0(_S703, _S710, _S710, _S694.state);
    }
    bool _S711 = (fcptWorldReadsPath());
    float3  seen_0;
    if(_S711)
    {
        float3  _S712 = skyColor_0(_S706, _S703, surface_4, wavelength_4, eta_4, is_inside_5, _S704, lobe_state_0, context_2->depth + 1U);
        seen_0 = _S712;
    }
    else
    {
        seen_0 = _S707;
    }
    float3  _S713 = skyRadiance_0(ray_0->origin, surface_4, is_inside_5, _S703, context_2, _S694.state);
    return SkySample_x24init_0(_S703, _S713, seen_0 * _S713, _S694.state);
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
    SampleBSDF _S714 = (fcptConnectHair((surface_5->hair), ((&surface_5->material)->albedo), ((&surface_5->material)->specular_tint), (in_dir_7), (light_1->dir)));
    float3  _S715 = _S714.throughput * make_float3 (_S714.pdf);
    float _S716 = light_1->density;
    float _S717 = 1.0f + _S714.pdf * _S714.pdf / (light_1->density * light_1->density);
    bool _S718;
    if(competing_0)
    {
        _S718 = _S716 > 0.0f;
    }
    else
    {
        _S718 = false;
    }
    float _S719 = _slang_select(_S718, _S717,1.0f);
    return _S715 / make_float3 (_S719) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_7, float3  radiance_1, float density_0, uint random_state_9)
{
    TreeSample _S720;
    (&_S720)->dir = dir_7;
    (&_S720)->radiance = radiance_1;
    (&_S720)->density = density_0;
    (&_S720)->random_state = random_state_9;
    return _S720;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_12, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S721 = importance(first_1, p_12, normal_3);
    float _S722 = importance(second_1, p_12, normal_3);
    float2  _S723 = make_float2 (_S721, _S722);
    bool _S724 = _S721 == 0.0f;
    bool _S725;
    if(_S724)
    {
        _S725 = _S722 == 0.0f;
    }
    else
    {
        _S725 = false;
    }
    if(_S725)
    {
        return 2U;
    }
    float _S726 = _S721 + _S722;
    bool _S727 = _S722 > 0.0f;
    if(_S727)
    {
        _S725 = (*pick_0 * _S726) >= _S721;
    }
    else
    {
        _S725 = false;
    }
    uint _S728 = uint(_S725);
    float _S729 = (F32_min(((*pick_0 * _S726 - float(_S728) * _S721) / _slang_vector_get_element(_S723, _S728)), (0.99999994039535522f)));
    *pick_0 = _S729;
    float _S730 = *probability_3 * (_slang_vector_get_element(_S723, _S728) / _S726);
    *probability_3 = _S730;
    return _S728;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_13, float u1_0, float u2_0)
{
    float3  _S731 = center_1 - p_13;
    float _S732 = radius_1 * radius_1 / dot_0(_S731, _S731);
    float _S733 = u1_0 * _S732 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S732), (0.0f)))))));
    float _S734 = 2.0f * u1_0;
    bool _S735 = _S732 >= 1.0f;
    float _S736 = _slang_select(_S735, _S734,_S733);
    float _S737 = (F32_sqrt(((F32_max((_S736 * (2.0f - _S736)), (0.0f))))));
    float _S738 = 6.28318548202514648f * u2_0;
    float3  _S739 = make_float3 (_S737 * (F32_cos((_S738))), 1.0f - _S736, _S737 * (F32_sin((_S738))));
    float3  _S740 = ((((_S731)) * make_float3(rnorm3df(((_S731)).x, ((_S731)).y, ((_S731)).z))));
    float3  _S741 = tangentToWorld(_S739, _S740);
    return _S741;
}

__device__ float3  pointLightRadiance(float3  color_3, float intensity_0, float radius_2)
{
    return color_3 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S742 = center_2 - ray_1->origin;
    float _S743 = dot_0(_S742, ray_1->unit_direction);
    float _S744 = dot_0(_S742, _S742) - _S743 * _S743;
    float _S745 = radius_3 * radius_3;
    bool _S746 = _S744 > _S745;
    if(_S746)
    {
        return 4.294967296e+09f;
    }
    float _S747 = (F32_sqrt((_S745 - _S744)));
    float _S748 = _S743 - _S747;
    float _S749 = _S743 + _S747;
    bool _S750 = _S748 > 0.0000152587890625f;
    bool _S751;
    if(_S750)
    {
        _S751 = _S748 < max_len_0;
    }
    else
    {
        _S751 = false;
    }
    if(_S751)
    {
        return _S748;
    }
    bool _S752 = _S749 > 0.0000152587890625f;
    if(_S752)
    {
        _S751 = _S749 < max_len_0;
    }
    else
    {
        _S751 = false;
    }
    if(_S751)
    {
        return _S749;
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
    Random _S753 = pcg(init_random_state_1);
    Random _S754 = pcg(_S753.state);
    Random _S755 = pcg(_S754.state);
    float3  _S756 = make_float3 (0.0f);
    TreeSample _S757 = TreeSample_x24init_0(_S756, _S756, 0.0f, _S755.state);
    TreeSample sample_0 = _S757;
    float3  _S758 = _slang_select(sided_0, _S756,smooth_n_2);
    float3  _S759 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S753.value;
    float probability_4 = 1.0f;
    uint n_7 = 0U;
    for(;;)
    {
        uint4  _S760 = (fcptLightNode((n_7)));
        if((_S760.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S761 = (fcptLightSecond((n_7)));
        uint _S762 = n_7 + 1U;
        LightNode _S763 = (fcptLightBounds((_S762)));
        LightNode _S764 = (fcptLightBounds((_S761)));
        uint _S765 = pickChild(_S763, _S764, origin_4, _S758, &pick_1, &probability_4);
        bool _S766 = _S765 > 1U;
        if(_S766)
        {
            return sample_0;
        }
        bool _S767 = _S765 == 1U;
        uint _S768 = _slang_select(_S767, _S761,_S762);
        n_7 = _S768;
    }
    bool _S769 = n_7 == 0U;
    bool _S770;
    if(_S769)
    {
        LightNode _S771 = (fcptLightBounds((0U)));
        float _S772 = importance(_S771, origin_4, _S758);
        _S770 = !(_S772 > 0.0f);
    }
    else
    {
        _S770 = false;
    }
    if(_S770)
    {
        return sample_0;
    }
    uint4  _S773 = (fcptLightNode((n_7)));
    FKHit _S774 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S775 = (_S773.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S775)
    {
        FKLight _S776 = (fcptLight((_S773.y)));
        if(sided_0)
        {
            float _S777 = sign_0(dot_0(geometry_n_1, _S776.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S777);
            float3  _S778 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S778;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S759;
            lift_n_0 = smooth_n_2;
        }
        bool _S779 = (_S776.variance) == 0.0f;
        if(_S779)
        {
            float3  _S780 = _S776.position - emitter_point_0;
            float3  _S781 = ((((_S780)) * make_float3(rnorm3df(((_S780)).x, ((_S780)).y, ((_S780)).z))));
            (&sample_0)->dir = _S781;
            float3  _S782 = _S776.color * make_float3 (_S776.intensity) / make_float3 (dot_0(_S780, _S780) * probability_4);
            (&sample_0)->radiance = _S782;
            shadow_1 = _S780;
        }
        else
        {
            float3  _S783 = sampleSphere(_S776.position, _S776.variance, emitter_point_0, _S754.value, _S755.value);
            (&sample_0)->dir = _S783;
            float _S784 = sphereDensity(_S776.position, _S776.variance, emitter_point_0);
            float _S785 = probability_4 * _S784;
            (&sample_0)->density = _S785;
            float3  _S786 = pointLightRadiance(_S776.color, _S776.intensity, _S776.variance);
            float3  _S787 = _S786 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S787;
            FKRay _S788 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S789 = raySphere_0(_S776.position, _S776.variance, &_S788, 4.294967296e+09f);
            float3  _S790 = (&sample_0)->dir * make_float3 (_S789);
            shadow_1 = _S790;
        }
        emitter_0 = _S774;
        emitter_point_0 = _S756;
    }
    else
    {
        uint _S791 = _S773.y;
        uint _S792 = (fcptTriangleOffset((_S791)));
        uint _S793 = _S792 + _S773.z;
        Matrix<float, 3, 3>  _S794 = (fcptWorldTriangle((_S791), (_S793)));
        float _S795 = (F32_sqrt((_S754.value)));
        float2  _S796 = make_float2 (_S795 * (1.0f - _S755.value), _S795 * _S755.value);
        float3  _S797 = mul_0(make_float3 (1.0f - _S795, _S796.x, _S796.y), _S794);
        if(sided_0)
        {
            float _S798 = sign_0(dot_0(geometry_n_1, _S797 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S798);
            float3  _S799 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S799;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S800 = !((dot_0(smooth_n_2, _S797 - origin_4)) > 0.0f);
            if(_S800)
            {
                return sample_0;
            }
            emitter_point_0 = _S759;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S796, _S791, _S793, 0U, 0.0f);
        float3  _S801 = _S797 - emitter_point_0;
        float3  _S802 = ((((_S801)) * make_float3(rnorm3df(((_S801)).x, ((_S801)).y, ((_S801)).z))));
        (&sample_0)->dir = _S802;
        float _S803 = solidAngle(probability_4, cross_0(_S794.rows[int(1)] - _S794.rows[int(0)], _S794.rows[int(2)] - _S794.rows[int(0)]), _S801);
        (&sample_0)->density = _S803;
        bool _S804 = (fcptShadowFirst());
        bool _S805 = !_S804;
        if(_S805)
        {
            FKSurface _S806 = (fcptLightSurfaceAt((emitter_1), (_S797), (_S755.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S797 - origin_4))));
            (&sample_0)->random_state = _S806.random_state;
            float3  _S807 = _slang_select(_S806.skip, _S756,_S806.material.emissive);
            float3  _S808 = _S807 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S808;
        }
        shadow_1 = _S801;
        emitter_0 = emitter_1;
        emitter_point_0 = _S797;
    }
    FKHit _S809 = emitter_0;
    float3  _S810 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S755.state, &_S809);
    bool _S811 = (fcptShadowFirst());
    if(_S811)
    {
        _S770 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S770 = false;
    }
    if(_S770)
    {
        _S770 = !all_1(_S810 == _S756);
    }
    else
    {
        _S770 = false;
    }
    if(_S770)
    {
        FKSurface _S812 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S755.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S812.random_state;
        float3  _S813 = _slang_select(_S812.skip, _S756,_S812.material.emissive);
        float3  _S814 = _S813 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S814;
    }
    float3  _S815 = (&sample_0)->radiance * _S810;
    bool _S816 = all_1(_S810 == _S756);
    float3  _S817 = _slang_select(_S816, _S756,_S815);
    (&sample_0)->radiance = _S817;
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
    float _S818 = 1.0f / (1.0f + b_2 / a_8 * (b_2 / a_8));
    bool _S819 = b_2 > 0.0f;
    float _S820 = _slang_select(_S819, _S818,1.0f);
    return _S820;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S821 = vertex_0->none;
    if(_S821)
    {
        return 1.0f;
    }
    uint _S822 = (fcptLightSlot((*hit_1)));
    float _S823 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S822, light_point_1);
    float _S824 = powerHeuristic(vertex_0->pdf, _S823);
    return _S824;
}

static __device__ float3  environment_0(float3  dir_8, uint depth_1, uint lobe_0)
{
    uint2  _S825 = (fcptEnvironmentMapSize());
    bool _S826 = (_S825.x) > 1U;
    bool _S827;
    if(_S826)
    {
        uint2  _S828 = (fcptEnvironmentMapSize());
        _S827 = (_S828.y) > 1U;
    }
    else
    {
        _S827 = false;
    }
    if(_S827)
    {
        float3  _S829 = (fcptEnvMapSample((dir_8), (depth_1), (lobe_0)));
        return _S829;
    }
    float3  _S830 = (fcptAmbient());
    return _S830;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S831 = (fcptEnvironmentCdfSize());
    bool _S832 = (_S831.x) > 1U;
    bool _S833;
    if(_S832)
    {
        uint2  _S834 = (fcptEnvironmentCdfSize());
        _S833 = (_S834.y) > 1U;
    }
    else
    {
        _S833 = false;
    }
    bool _S835 = !_S833;
    if(_S835)
    {
        return false;
    }
    uint2  _S836 = (fcptEnvironmentMapSize());
    bool _S837 = (_S836.x) > 1U;
    if(_S837)
    {
        uint2  _S838 = (fcptEnvironmentMapSize());
        _S833 = (_S838.y) > 1U;
    }
    else
    {
        _S833 = false;
    }
    return _S833;
}

static __device__ float escapeWeight_0(float pdf_3, float3  dir_9)
{
    bool _S839 = pdf_3 <= 0.0f;
    bool _S840;
    if(_S839)
    {
        _S840 = true;
    }
    else
    {
        bool _S841 = environmentMapped_0();
        _S840 = !_S841;
    }
    if(_S840)
    {
        return 1.0f;
    }
    float _S842 = environmentPdf_0(dir_9);
    return pdf_3 / (pdf_3 + _S842);
}

static __device__ void restir_duplicates_0(uint3  global_invocation_id_1, uint3  local_invocation_id_0, uint local_invocation_index_3)
{
    uint2  _S843 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S844 = make_int2 ((int)_S843.x, (int)_S843.y);
    uint _S845 = previousSeed_0(_S844);
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
            uint _S846 = previousSeed_0(_S844 + make_int2 (x_16, y_5));
            bool _S847 = _S846 == _S845;
            uint _S848 = _slang_select(_S847, 1U,0U);
            uint count_3 = count_2 + _S848;
            int x_17 = x_16 + int(1);
            x_16 = x_17;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S849 = float(count_2 - 1U) / 288.0f;
    bool _S850 = _S845 != 0U;
    float _S851 = _slang_select(_S850, _S849,0.0f);
    fcptStoreDuplication((_S844), (make_uint4 ((F32_asuint((_S851))), 0U, 0U, 0U)));
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
    float _S852 = rgb_to_greyscale(abs_0(f_5));
    return _S852;
}

__device__ uint stream(uint seed_3, uint index_0)
{
    uint _S853 = hash(index_0);
    uint _S854 = hash(seed_3 ^ _S853);
    return _S854;
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
    float _S855 = resamplingTarget(weight_0);
    bool _S856 = _S855 > 0.0f;
    bool _S857;
    if(_S856)
    {
        _S857 = _S855 < 3.00000000549775576e+38f;
    }
    else
    {
        _S857 = false;
    }
    bool _S858 = !_S857;
    if(_S858)
    {
        return;
    }
    bool _S859 = sel_2->sums;
    if(_S859)
    {
        float3  _S860 = sel_2->color + weight_0;
        sel_2->color = _S860;
        return;
    }
    float _S861 = sel_2->w_sum + _S855;
    sel_2->w_sum = _S861;
    float3  _S862 = sel_2->color + weight_0;
    sel_2->color = _S862;
    Random _S863 = pcg(sel_2->random_state);
    sel_2->random_state = _S863.state;
    bool _S864 = (_S863.value * sel_2->w_sum) <= _S855;
    if(_S864)
    {
        sel_2->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_3;
    float3  _S865 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S865;
    float _S866 = r_3.jac * shifted_0.jac;
    (&candidate_1)->jac = _S866;
    offer(sel_3, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S867 = resamplingTarget((&r_4)->f);
    float _S868 = sel_4.w_sum / _S867;
    bool _S869 = _S867 > 0.0f;
    float _S870 = _slang_select(_S869, _S868,0.0f);
    (&r_4)->w = _S870;
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
    uint2  _S871 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S872 = make_int2 ((int)_S871.x, (int)_S871.y);
    float3  _S873 = make_float3 (0.0f);
    FKHit _S874 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S875 = Domain_x24init_0(_S873, _S873, &_S874, 0.0f, 0.0f);
    Domain dom_4 = _S875;
    bool _S876 = (fcptCurrentDomain((_S872), (&dom_4)));
    bool _S877 = !_S876;
    if(_S877)
    {
        Reservoir _S878 = (Reservoir{});
        fcptStoreReservoirPrevious((_S872), (_S878), ((&dom_4)->hit));
        return;
    }
    Reservoir _S879 = (fcptLoadReservoirTemporal((_S872)));
    uint t_15 = 0U;
    float count_4 = 0.0f;
    float c_sum_1 = _S879.c;
    for(;;)
    {
        uint _S880 = (fcptRestirNeighbours());
        if(t_15 < _S880)
        {
        }
        else
        {
            break;
        }
        int2  _S881 = partner_0(_S872, t_15);
        Domain neighbor_0 = _S875;
        bool _S882 = (fcptCurrentDomain((_S881), (&neighbor_0)));
        if(_S882)
        {
            float count_5 = count_4 + 1.0f;
            uint4  _S883 = (fcptReservoirTemporal((_S881), (0U)));
            float c_sum_2 = c_sum_1 + (U32_asfloat((_S883.w)));
            count_4 = count_5;
            c_sum_1 = c_sum_2;
        }
        uint t_16 = t_15 + 1U;
        t_15 = t_16;
    }
    float _S884 = _S879.c / (F32_max((count_4), (1.0f)));
    float _S885 = resamplingTarget(_S879.f);
    bool _S886 = count_4 == 0.0f;
    float _S887 = _slang_select(_S886, 1.0f,0.0f);
    Selection _S888 = (Selection{});
    Selection sel_5 = _S888;
    uint _S889 = (fcptFrame());
    uint _S890 = hash(_S889);
    uint _S891 = global_invocation_id_2.x;
    uint2  _S892 = (fcptRenderSize());
    uint _S893 = stream(_S890, _S891 + _S892.x * global_invocation_id_2.y);
    uint _S894 = stream(_S893, 195U);
    (&sel_5)->random_state = _S894;
    t_15 = 0U;
    float canonical_mis_0 = _S887;
    for(;;)
    {
        uint _S895 = (fcptRestirNeighbours());
        if(t_15 < _S895)
        {
        }
        else
        {
            break;
        }
        int2  _S896 = partner_0(_S872, t_15);
        Domain neighbor_dom_0 = _S875;
        bool _S897 = (fcptCurrentDomain((_S896), (&neighbor_dom_0)));
        if(_S897)
        {
            Reservoir _S898 = (fcptLoadReservoirTemporal((_S896)));
            uint4  _S899 = (fcptShiftData((_S896), (t_15)));
            float4  _S900 = asfloat_0(_S899);
            uint4  _S901 = (fcptShiftData((_S872), (t_15)));
            float4  _S902 = asfloat_0(_S901);
            float _S903 = pairShare(_S898.c, _S884, c_sum_1);
            bool _S904 = _S885 > 0.0f;
            float canonical_mis_1;
            if(_S904)
            {
                float _S905 = resamplingTarget(float3 {_S902.x, _S902.y, _S902.z});
                float _S906 = canonicalWeight(_S903, _S884, _S885, _S898.c, _S905);
                float canonical_mis_2 = canonical_mis_0 + _S906;
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float3  _S907 = float3 {_S900.x, _S900.y, _S900.z};
            Shift _S908 = Shift_x24init_0(_S907, _S900.w);
            float _S909 = resamplingTarget(_S898.f);
            float _S910 = resamplingTarget(_S907);
            float _S911 = neighborWeight(_S903, _S898.c, _S909, _S884, _S910);
            offerShifted(&sel_5, _S898, _S908, _S911);
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_17 = t_15 + 1U;
        t_15 = t_17;
    }
    offerShifted(&sel_5, _S879, Shift_x24init_0(_S879.f, 1.0f), canonical_mis_0);
    Reservoir _S912 = finalize(sel_5, c_sum_1);
    fcptStoreReservoirPrevious((_S872), (_S912), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S872), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S872), (make_float4 ((&sel_5)->color.x, (&sel_5)->color.y, (&sel_5)->color.z, 0.0f)));
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

__device__ float confidenceCap(float duplicated_0)
{
    float _S958 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S958;
}

__device__ float2  temporalWeights(float c_2, float p_c_1, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S959 = c_2 * p_c_1;
    float _S960 = c_t_0 * p_t_0;
    return make_float2 (_S959 / (_S959 + c_t_0 * g_previous_0), _S960 / (_S960 + c_2 * g_current_0));
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S961 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S962 = make_int2 ((int)_S961.x, (int)_S961.y);
    float3  _S963 = make_float3 (0.0f);
    FKHit _S964 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S965 = Domain_x24init_0(_S963, _S963, &_S964, 0.0f, 0.0f);
    Domain dom_5 = _S965;
    bool _S966 = (fcptCurrentDomain((_S962), (&dom_5)));
    bool _S967 = !_S966;
    if(_S967)
    {
        Reservoir _S968 = (Reservoir{});
        fcptStoreReservoirTemporal((_S962), (_S968), ((&dom_5)->hit));
        return;
    }
    Reservoir _S969 = (fcptLoadReservoirInitial((_S962)));
    bool _S970 = (fcptTemporalQueued());
    bool _S971 = (fcptSceneUnchanged());
    bool _S972;
    if(_S971)
    {
        _S972 = true;
    }
    else
    {
        _S972 = !_S970;
    }
    int2  _S973;
    if(_S972)
    {
        int2  _S974 = sampleNeighbor_0(_S962, _S969.seed);
        _S973 = _S974;
    }
    else
    {
        int2  _S975 = (fcptLoadTemporalNeighbor((_S962)));
        _S973 = _S975;
    }
    bool _S976 = (_S973.x) >= int(0);
    Reservoir r_5;
    if(_S976)
    {
        Reservoir _S977 = (fcptLoadReservoirPrevious((_S973)));
        uint4  _S978 = (fcptDuplication((_S973)));
        float _S979 = (U32_asfloat((_S978.x)));
        uint _S980 = (fcptRestirDecorrelation());
        bool _S981 = _S980 == 1U;
        float _S982 = _slang_select(_S981, _S979,0.0f);
        float _S983 = confidenceCap(_S982);
        float _S984 = (F32_min((_S977.c), (_S983)));
        bool _S985 = (fcptSceneUnchanged());
        float4  _S986 = make_float4 (_S977.f.x, _S977.f.y, _S977.f.z, 1.0f);
        bool _S987 = !_S985;
        if(_S987)
        {
            _S972 = _S970;
        }
        else
        {
            _S972 = false;
        }
        float4  to_current_0;
        if(_S972)
        {
            uint4  _S988 = (fcptTemporalShift((_S962), (0U)));
            float4  _S989 = asfloat_0(_S988);
            to_current_0 = _S989;
        }
        else
        {
            if(_S987)
            {
                Shift _S990 = temporalShiftAt_0(_S962, _S973, 0U);
                float4  _S991 = make_float4 (_S990.f.x, _S990.f.y, _S990.f.z, _S990.jac);
                to_current_0 = _S991;
            }
            else
            {
                to_current_0 = _S986;
            }
        }
        Domain own_1 = _S965;
        if(_S985)
        {
            _S972 = true;
        }
        else
        {
            bool _S992 = (fcptPreviousScenes());
            bool _S993 = !_S992;
            if(_S993)
            {
                _S972 = (_S969.w) > 0.0f;
            }
            else
            {
                _S972 = false;
            }
            if(_S972)
            {
                bool _S994 = (fcptStoredDomainInitial((_S962), (_S969.seed), (&own_1)));
                _S972 = _S994;
            }
            else
            {
                _S972 = false;
            }
            if(_S972)
            {
                Domain _S995 = (fcptPreviousDomain((_S973), (_S969.seed)));
                Domain _S996 = _S995;
                Domain _S997 = own_1;
                bool _S998 = sameDomain_0(&_S996, &_S997);
                _S972 = _S998;
            }
            else
            {
                _S972 = false;
            }
        }
        float4  _S999 = make_float4 (_S969.f.x, _S969.f.y, _S969.f.z, 1.0f);
        bool _S1000 = !_S972;
        if(_S1000)
        {
            _S972 = _S970;
        }
        else
        {
            _S972 = false;
        }
        float4  to_previous_0;
        if(_S972)
        {
            uint4  _S1001 = (fcptTemporalShift((_S962), (1U)));
            float4  _S1002 = asfloat_0(_S1001);
            to_previous_0 = _S1002;
        }
        else
        {
            if(_S1000)
            {
                Shift _S1003 = temporalShiftAt_0(_S962, _S973, 1U);
                float4  _S1004 = make_float4 (_S1003.f.x, _S1003.f.y, _S1003.f.z, _S1003.jac);
                to_previous_0 = _S1004;
            }
            else
            {
                to_previous_0 = _S999;
            }
        }
        float _S1005 = resamplingTarget(_S969.f);
        float _S1006 = resamplingTarget(_S977.f);
        Selection _S1007 = (Selection{});
        Selection sel_6 = _S1007;
        uint _S1008 = (fcptFrame());
        uint _S1009 = hash(_S1008);
        uint _S1010 = global_invocation_id_7.x;
        uint2  _S1011 = (fcptRenderSize());
        uint _S1012 = stream(_S1009, _S1010 + _S1011.x * global_invocation_id_7.y);
        uint _S1013 = stream(_S1012, 194U);
        (&sel_6)->random_state = _S1013;
        float4  _S1014 = to_previous_0;
        float _S1015 = resamplingTarget(float3 {_S1014.x, _S1014.y, _S1014.z});
        float4  _S1016 = to_current_0;
        float3  _S1017 = float3 {_S1016.x, _S1016.y, _S1016.z};
        float _S1018 = resamplingTarget(_S1017);
        float2  _S1019 = temporalWeights(_S969.c, _S1005, _S984, _S1006, _S1015, _S1018);
        offerShifted(&sel_6, _S969, Shift_x24init_0(_S969.f, 1.0f), _S1019.x);
        offerShifted(&sel_6, _S977, Shift_x24init_0(_S1017, to_current_0.w), _S1019.y);
        Reservoir _S1020 = finalize(sel_6, _S969.c + _S984);
        r_5 = _S1020;
    }
    else
    {
        r_5 = _S969;
    }
    fcptStoreReservoirTemporal((_S962), (r_5), ((&dom_5)->hit));
    return;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_6)
{
    uint _S1021 = (1U << count_6) - 1U;
    return (e_2 & (~(_S1021 << offset_1))) | ((newbits_0 & _S1021) << offset_1);
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S1022 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S1023 = make_int2 ((int)_S1022.x, (int)_S1022.y);
    float3  _S1024 = make_float3 (0.0f);
    float2  _S1025 = make_float2 (0.0f);
    FKHit _S1026 = Hit_x24init_0(_S1025, 0U, 0U, 0U, 0.0f);
    Domain _S1027 = Domain_x24init_0(_S1024, _S1024, &_S1026, 0.0f, 0.0f);
    Domain dom_6 = _S1027;
    bool _S1028 = (fcptCurrentDomain((_S1023), (&dom_6)));
    bool _S1029 = !_S1028;
    if(_S1029)
    {
        Reservoir _S1030 = (Reservoir{});
        fcptStoreReservoirInitial((_S1023), (_S1030), ((&dom_6)->hit));
        return;
    }
    uint _S1031 = (fcptFrame());
    uint _S1032 = hash(_S1031);
    uint _S1033 = global_invocation_id_8.x;
    uint2  _S1034 = (fcptRenderSize());
    uint _S1035 = global_invocation_id_8.y;
    uint _S1036 = stream(_S1032, _S1033 + _S1034.x * _S1035);
    uint2  _S1037 = (fcptRenderSize());
    uint _S1038 = stream(_S1033 + _S1037.x * _S1035, 512U);
    Selection _S1039 = (Selection{});
    Selection initial_0 = _S1039;
    uint _S1040 = stream(_S1036, 193U);
    (&initial_0)->random_state = _S1040;
    bool _S1041 = (fcptRestirUsed());
    bool _S1042 = !_S1041;
    (&initial_0)->sums = _S1042;
    uint _S1043 = stream(_S1036, 0U);
    (&(&initial_0)->r)->seed = _S1043;
    FKHit _S1044 = Hit_x24init_0(_S1025, 4294967295U, 0U, 0U, 0.0f);
    uint _S1045 = (fcptSamples());
    float _S1046 = 1.0f / float(_S1045);
    FKHit hit_2 = _S1044;
    uint i_20 = 0U;
    float3  seen_1 = _S1024;
    for(;;)
    {
        uint _S1047 = (fcptSamples());
        if(i_20 < _S1047)
        {
        }
        else
        {
            break;
        }
        Reservoir _S1048 = (Reservoir{});
        Reservoir r_6 = _S1048;
        uint _S1049 = stream(_S1036, i_20);
        (&r_6)->seed = _S1049;
        uint _S1050 = (fcptFrame());
        uint _S1051 = (fcptSamples());
        uint _S1052 = _S1050 * _S1051 + i_20;
        uint _S1053 = insertBits_0(0U, 1U, 24U, 1U);
        uint _S1054 = insertBits_0(_S1053, (_S1038 + _S1052 * 2654435769U) >> 25U, 25U, 7U);
        (&r_6)->path = _S1054;
        Domain path_0 = _S1027;
        bool _S1055 = (fcptStoredDomainInitial((_S1023), ((&r_6)->seed), (&path_0)));
        bool _S1056 = !_S1055;
        if(_S1056)
        {
            float3  _S1057 = (fcptMissed((_S1023), (path_0), (_S1046)));
            float3  seen_2 = seen_1 + _S1057;
            seen_1 = seen_2;
            uint i_21 = i_20 + 1U;
            i_20 = i_21;
            continue;
        }
        Domain _S1058 = path_0;
        Reservoir _S1059 = r_6;
        Shift _S1060 = passWalk_0(&_S1058, &_S1059, false, _S1046, &initial_0);
        bool _S1061 = ((&(&initial_0)->r)->seed) == ((&r_6)->seed);
        FKHit hit_3;
        if(_S1061)
        {
            FKHit _S1062 = (&path_0)->hit;
            hit_3 = _S1062;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_21 = i_20 + 1U;
        i_20 = i_21;
    }
    uint _S1063 = (fcptSamples());
    float3  seen_3 = seen_1 + (&initial_0)->glow / make_float3 (float(_S1063));
    if((&initial_0)->sums)
    {
        seen_1 = seen_3 + (&initial_0)->color;
    }
    else
    {
        seen_1 = seen_3;
    }
    fcptAddColor((_S1023), (make_float4 (seen_1.x, seen_1.y, seen_1.z, 1.0f)));
    Reservoir _S1064 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S1023), (_S1064), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_4, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S1065;
    (&_S1065)->none = none_0;
    (&_S1065)->pdf = pdf_4;
    (&_S1065)->origin = origin_5;
    (&_S1065)->smooth_n = smooth_n_3;
    (&_S1065)->start = start_6;
    return _S1065;
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
    Vertex _S1066;
    (&_S1066)->rough = rough_0;
    (&_S1066)->lobe = lobe_1;
    (&_S1066)->pdf = pdf_5;
    (&_S1066)->cos = cos_0;
    (&_S1066)->inside = inside_0;
    return _S1066;
}

static __device__ float freeFlight_0(float u_1, float sigma_0)
{
    return - (F32_log((1.0f - u_1))) / sigma_0;
}

__device__ float3  pathColor(float3  f_6, float3  weight_1, float wavelength_5)
{
    float3  _S1067;
    if(wavelength_5 > 0.0f)
    {
        float _S1068 = upsample(f_6, wavelength_5);
        _S1067 = weight_1 * make_float3 (_S1068);
    }
    else
    {
        _S1067 = f_6;
    }
    return _S1067;
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

static __device__ float3  flightWeight_0(float3  scatter_0, float3  extinction_0, float sigma_1, float distance_2, bool scatters_0)
{
    float3  _S1069 = exp_0((make_float3 (sigma_1) - extinction_0) * make_float3 (distance_2));
    float3  _S1070 = scatter_0 * _S1069 / make_float3 (sigma_1);
    float3  _S1071 = _slang_select(scatters_0, _S1070,_S1069);
    return _S1071;
}

static __device__ bool scatterSampled_0(bool replay_1, uint b_4, uint stop_0, bool varying_0)
{
    bool _S1072 = !replay_1;
    bool _S1073;
    if(_S1072)
    {
        _S1073 = true;
    }
    else
    {
        bool _S1074 = b_4 == stop_0;
        if(_S1074)
        {
            _S1073 = !varying_0;
        }
        else
        {
            _S1073 = false;
        }
    }
    return _S1073;
}

static __device__ uint arrivalLobe_0(uint b_5, uint prev_lobe_0)
{
    bool _S1075 = b_5 > 0U;
    uint _S1076 = _slang_select(_S1075, prev_lobe_0,3U);
    return _S1076;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_2, uint lobe_2, bool surface_6, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S1077;
    (&_S1077)->extinction_behind = extinction_behind_0;
    (&_S1077)->extinction_front = extinction_front_0;
    (&_S1077)->fillings = fillings_0;
    (&_S1077)->side = side_0;
    (&_S1077)->depth = depth_2;
    (&_S1077)->lobe = lobe_2;
    (&_S1077)->surface = surface_6;
    (&_S1077)->length = length_2;
    (&_S1077)->width = width_1;
    (&_S1077)->own = *own_2;
    (&_S1077)->fiber = fiber_0;
    return _S1077;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S1078 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S1078)
    {
        return 0.07957746833562851f;
    }
    float _S1079 = g_0 * g_0;
    return (1.0f - _S1079) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S1079 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_10, float3  b_6)
{
    float3  _S1080 = a_10 / b_6;
    float3  _S1081 = make_float3 (0.0f);
    bool3  _S1082 = b_6 == _S1081;
    float3  _S1083 = _slang_select(_S1082, _S1081,_S1080);
    return _S1083;
}

__device__ Reservoir withEnd(Reservoir r_7, uint end_type_0, uint end_0, float3  f_7)
{
    Reservoir candidate_2 = r_7;
    uint _S1084 = insertBits_0(r_7.path, end_0, 0U, 5U);
    uint _S1085 = insertBits_0(_S1084, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S1085;
    (&candidate_2)->f = f_7;
    return candidate_2;
}

__device__ float survivalProbability(float3  throughput_0, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_0.x), ((F32_max((throughput_0.y), (throughput_0.z)))))) / density_1), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_10)
{
    Random _S1086 = pcg(random_state_10);
    Random _S1087 = pcg(_S1086.state);
    float _S1088 = 1.0f - 2.0f * _S1086.value;
    float _S1089 = (F32_sqrt(((F32_max((1.0f - _S1088 * _S1088), (0.0f))))));
    float _S1090 = 6.28318548202514648f * _S1087.value;
    return make_float3 (_S1089 * (F32_cos((_S1090))), _S1089 * (F32_sin((_S1090))), _S1088);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_10, uint random_state_11, float * pdf_6)
{
    bool _S1091 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1091)
    {
        *pdf_6 = 0.07957746833562851f;
        float3  _S1092 = isotropic_0(random_state_11);
        return _S1092;
    }
    Random _S1093 = pcg(random_state_11);
    Random _S1094 = pcg(_S1093.state);
    float _S1095 = g_1 * g_1;
    float _S1096 = 2.0f * g_1;
    float _S1097 = (1.0f - _S1095) / (1.0f - g_1 + _S1096 * _S1093.value);
    float _S1098 = clamp_1((1.0f + _S1095 - _S1097 * _S1097) / _S1096, -1.0f, 1.0f);
    float _S1099 = (F32_sqrt(((F32_max((1.0f - _S1098 * _S1098), (0.0f))))));
    float _S1100 = 6.28318548202514648f * _S1094.value;
    float _S1101 = phaseHG_0(g_1, _S1098);
    *pdf_6 = _S1101;
    float3  _S1102 = tangentToWorld(make_float3 (_S1099 * (F32_cos((_S1100))), _S1098, _S1099 * (F32_sin((_S1100)))), dir_10);
    float3  _S1103 = ((((_S1102)) * make_float3(rnorm3df(((_S1102)).x, ((_S1102)).y, ((_S1102)).z))));
    return _S1103;
}

static __device__ Vertex scatteredVertex_0(bool is_inside_6)
{
    return Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_6);
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_1, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_1, float velvet_0, float3  toon_2, float dispersion_0)
{
    BSDFMaterial _S1104;
    (&_S1104)->albedo = albedo_1;
    (&_S1104)->emissive = emissive_0;
    (&_S1104)->roughness = roughness_0;
    (&_S1104)->metallic = metallic_0;
    (&_S1104)->transmission = transmission_0;
    (&_S1104)->ior = ior_0;
    (&_S1104)->absorption = absorption_0;
    (&_S1104)->specular_tint = specular_tint_0;
    (&_S1104)->specular_level = specular_level_0;
    (&_S1104)->translucent = translucent_0;
    (&_S1104)->sheen = sheen_2;
    (&_S1104)->sheen_roughness = sheen_roughness_0;
    (&_S1104)->anisotropy = anisotropy_0;
    (&_S1104)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1104)->tangent = tangent_1;
    (&_S1104)->velvet = velvet_0;
    (&_S1104)->toon = toon_2;
    (&_S1104)->dispersion = dispersion_0;
    return _S1104;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1105;
    (&_S1105)->scatter = scatter_1;
    (&_S1105)->extinction = extinction_1;
    (&_S1105)->g = g_2;
    return _S1105;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_14, bool skip_0, uint random_state_12, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1106;
    (&_S1106)->smooth_n = smooth_n_4;
    (&_S1106)->geometry_n = geometry_n_2;
    (&_S1106)->geometry_offset = geometry_offset_2;
    (&_S1106)->material = *material_14;
    (&_S1106)->skip = skip_0;
    (&_S1106)->random_state = random_state_12;
    (&_S1106)->coverage = coverage_0;
    (&_S1106)->encloses = encloses_0;
    (&_S1106)->volume = *volume_0;
    (&_S1106)->fills = fills_0;
    (&_S1106)->hair = hair_0;
    return _S1106;
}

static __device__ FKSurface emitting_0(FKSurface * surface_7, bool top_0)
{
    FKSurface lower_0 = *surface_7;
    float3  _S1107 = (&surface_7->material)->emissive;
    float3  _S1108 = make_float3 (0.0f);
    bool _S1109 = !top_0;
    float3  _S1110 = _slang_select(_S1109, _S1108,_S1107);
    (&(&lower_0)->material)->emissive = _S1110;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_8, float u_2)
{
    float _S1111 = surface_8->coverage;
    bool _S1112 = u_2 < _S1111;
    if(_S1112)
    {
        return *surface_8;
    }
    float3  _S1113 = make_float3 (0.0f);
    float3  _S1114 = make_float3 (1.0f);
    BSDFMaterial _S1115 = Material_x24init_0(_S1113, _S1113, 0.0f, 0.0f, 0.0f, 0.0f, _S1113, _S1114, 1.0f, _S1113, _S1113, 0.5f, 0.0f, 0.0f, _S1113, 0.0f, _S1113, 0.0f);
    BSDFMaterial material_15 = _S1115;
    (&material_15)->albedo = _S1114;
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
    bool _S1116 = transmission_1 > 0.0f;
    bool _S1117;
    if(_S1116)
    {
        _S1117 = true;
    }
    else
    {
        _S1117 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1118;
    if(_S1117)
    {
        _S1118 = 1.0f;
    }
    else
    {
        _S1118 = -1.0f;
    }
    return _S1118;
}

static __device__ bool arrivesBehind_0(float3  dir_11, float3  n_8)
{
    return (dot_0(dir_11, n_8)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_9, float3  dir_12)
{
    float3  _S1119 = surface_9->geometry_n;
    float _S1120 = facingSign((&surface_9->material)->transmission, surface_9->geometry_n, dir_12);
    FKSurface faced_0 = *surface_9;
    float3  _S1121 = surface_9->smooth_n * make_float3 (_S1120);
    (&faced_0)->smooth_n = _S1121;
    float3  _S1122 = _S1119 * make_float3 (_S1120);
    (&faced_0)->geometry_n = _S1122;
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
    float3  _S1123 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1123));
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
    bool _S1124;
    if(open_0)
    {
        _S1124 = prev_rough_0;
    }
    else
    {
        _S1124 = false;
    }
    if(_S1124)
    {
        _S1124 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S1124 = false;
    }
    return _S1124;
}

__device__ bool dispersive(BSDFMaterial material_16)
{
    bool _S1125 = (material_16.dispersion) > 0.0f;
    bool _S1126;
    if(_S1125)
    {
        _S1126 = (material_16.ior) != 1.0f;
    }
    else
    {
        _S1126 = false;
    }
    return _S1126;
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
        uint _S1127 = (low_1 + high_1 + 1U) / 2U;
        bool _S1128 = (WAVELENGTH_CDF_0[_S1127]) <= u_3;
        if(_S1128)
        {
            low_1 = _S1127;
        }
        else
        {
            uint _S1129 = _S1127 - 1U;
            high_1 = _S1129;
        }
    }
    uint _S1130 = low_1;
    float _S1131 = WAVELENGTH_CDF_0[low_1 + 1U] - WAVELENGTH_CDF_0[low_1];
    return make_float2 (0.37999999523162842f + 0.00499999988824129f * (float(low_1) + (u_3 - WAVELENGTH_CDF_0[_S1130]) / _S1131), _S1131 / 0.00499999988824129f);
}

__device__ static const FixedArray<float, 243>  WAVELENGTH_WEIGHTS_0 = { {
    0.00547470012679696f, -0.00465690018609166f, 0.03257500007748604f, 0.00934640038758516f, -0.00796370021998882f, 0.05577300116419792f, 0.01846100017428398f, -0.01579399965703487f, 0.11072999984025955f, 0.0416410006582737f, -0.03577499836683273f, 0.2513900101184845f, 0.09349299967288971f, -0.08071800321340561f, 0.56742000579833984f, 0.1585099995136261f, -0.13764999806880951f, 0.97018998861312866f, 0.30943000316619873f, -0.27083000540733337f, 1.91740000247955322f, 0.55217999219894409f, -0.48754000663757324f, 3.46889996528625488f, 0.95016998052597046f, -0.84802001714706421f, 6.09439992904663086f, 1.42110002040863037f, -1.28929996490478516f, 9.45199966430664062f, 1.73409998416900635f, -1.6062999963760376f, 12.12800025939941406f, 2.08030009269714355f, -1.98810005187988281f, 15.68700027465820312f, 2.20600008964538574f, -2.20120000839233398f, 18.47699928283691406f, 2.03040003776550293f, -2.17700004577636719f, 19.92700004577636719f, 1.63429999351501465f, -2.00340008735656738f, 20.86899948120117188f, 0.99410998821258545f, -1.62629997730255127f, 20.57799911499023438f, 0.20011000335216522f, -1.11409997940063477f, 19.72100067138671875f, -0.67960000038146973f, -0.45403000712394714f, 17.77599906921386719f, -1.61679995059967041f, 0.37860000133514404f, 14.71500015258789062f, -2.53410005569458008f, 1.27540004253387451f, 11.86499977111816406f, -3.39079999923706055f, 2.2146000862121582f, 9.17669963836669922f, -4.03749990463256836f, 3.0522000789642334f, 6.59509992599487305f, -4.61299991607666016f, 3.89779996871948242f, 4.64589977264404297f, -5.43039989471435547f, 5.0121002197265625f, 3.3199000358581543f, -6.37769985198974609f, 6.33809995651245117f, 2.29699993133544922f, -7.44140005111694336f, 7.91739988327026367f, 1.45389997959136963f, -8.38580036163330078f, 9.60109996795654297f, 0.66465997695922852f, -9.0167999267578125f, 11.23999977111816406f, -0.04403600096702576f, -9.17749977111816406f, 12.63199996948242188f, -0.58126997947692871f, -8.97550010681152344f, 13.91499996185302734f, -0.95730000734329224f, -8.25290012359619141f, 14.86200046539306641f, -1.24430000782012939f, -6.92129993438720703f, 15.03899955749511719f, -1.43069994449615479f, -5.29169988632202148f, 14.90900039672851562f, -1.55149996280670166f, -3.43219995498657227f, 14.70499992370605469f, -1.63569998741149902f, -1.27190005779266357f, 14.24400043487548828f, -1.67030000686645508f, 1.15170001983642578f, 13.32199954986572266f, -1.636199951171875f, 3.73889994621276855f, 12.21199989318847656f, -1.56920003890991211f, 6.43590021133422852f, 10.94699954986572266f, -1.47730004787445068f, 9.16440010070800781f, 9.54769992828369141f, -1.36399996280670166f, 12.02000045776367188f, 8.18799972534179688f, -1.25450003147125244f, 14.78699970245361328f, 6.74429988861083984f, -1.13110005855560303f, 16.72299957275390625f, 5.08780002593994141f, -0.96561002731323242f, 18.14299964904785156f, 3.57019996643066406f, -0.80725997686386108f, 19.91900062561035156f, 2.36269998550415039f, -0.69273000955581665f, 21.05500030517578125f, 1.31369996070861816f, -0.58597999811172485f, 21.3899993896484375f, 0.42390000820159912f, -0.48298001289367676f, 20.99300003051757812f, -0.23857000470161438f, -0.39412000775337219f, 19.82200050354003906f, -0.6866300106048584f, -0.31501999497413635f, 18.12000083923339844f, -0.9412500262260437f, -0.24890999495983124f, 15.7089996337890625f, -1.02020001411437988f, -0.19076000154018402f, 13.19799995422363281f, -0.98919999599456787f, -0.14401000738143921f, 11.23999977111816406f, -0.93347001075744629f, -0.11133000254631042f, 9.36649990081787109f, -0.83820998668670654f, -0.08524099737405777f, 7.41249990463256836f, -0.70064002275466919f, -0.06283199787139893f, 5.71229982376098633f, -0.56079000234603882f, -0.04586699977517128f, 4.42280006408691406f, -0.44653001427650452f, -0.03396600112318993f, 3.34489989280700684f, -0.34457001090049744f, -0.02482499927282333f, 2.49309992790222168f, -0.26017999649047852f, -0.01808100007474422f, 1.82239997386932373f, -0.1921599954366684f, -0.01296999957412481f, 1.29499995708465576f, -0.13766999542713165f, -0.00907570030540228f, 0.92928999662399292f, -0.09956400096416473f, -0.00641620019450784f, 0.61835998296737671f, -0.06671299785375595f, -0.00421149982139468f, 0.40211999416351318f, -0.04354599863290787f, -0.00271830009296536f, 0.2844499945640564f, -0.03087200038135052f, -0.00191440002527088f, 0.20672999322414398f, -0.02246100082993507f, -0.00138829997740686f, 0.15044000744819641f, -0.01634499989449978f, -0.00101030000951141f, 0.10942000150680542f, -0.01188699994236231f, -0.0007347899954766f, 0.07099699974060059f, -0.00771349994465709f, -0.00047679000999779f, 0.04539500176906586f, -0.00493190018460155f, -0.00030484999297187f, 0.03424099832773209f, -0.00372010003775358f, -0.00022995000472292f, 0.02557599917054176f, -0.00277870008721948f, -0.00017175999528263f, 0.01842200011014938f, -0.00200140010565519f, -0.0001237099932041f, 0.01316899992525578f, -0.00143079995177686f, -0.00008843900286593f, 0.00838890019804239f, -0.00091141002485529f, -0.00005633700129692f, 0.00537079991772771f, -0.00058350997278467f, -0.00003606799873523f, 0.00328280008397996f, -0.00035665999166667f, -0.00002204600059486f, 0.00196009990759194f, -0.00021296000340953f, -0.00001316300040344f, 0.00168939994182438f, -0.00018354000349063f, -0.00001134499962063f, 0.00141050003003329f, -0.00015325000276789f, -0.00000947250009631f, 0.00097123999148607f, -0.00010551999730524f, -6.52239987175562419e-06f, 0.00066868000430986f, -0.00007264900341397f, -4.49060007667867467e-06f
} };
__device__ float3  wavelengthWeights(float wavelength_6)
{
    float _S1132 = clamp_1((wavelength_6 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    uint _S1133 = (U32_min((uint(_S1132)), (79U)));
    uint _S1134 = 3U * _S1133;
    float3  _S1135 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1134], WAVELENGTH_WEIGHTS_0[_S1134 + 1U], WAVELENGTH_WEIGHTS_0[_S1134 + 2U]);
    float3  _S1136 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1134 + 3U], WAVELENGTH_WEIGHTS_0[_S1134 + 4U], WAVELENGTH_WEIGHTS_0[_S1134 + 5U]);
    return _S1135 + (_S1136 - _S1135) * make_float3 (_S1132 - float(_S1133));
}

__device__ float dispersedIor(float ior_1, float dispersion_1, float wavelength_7)
{
    float _S1137 = (ior_1 - 1.0f) * dispersion_1 / 1.90962409973144531f;
    float _S1138 = _S1137 * (1.0f / (wavelength_7 * wavelength_7) - 2.89662933349609375f);
    bool _S1139 = dispersion_1 > 0.0f;
    float _S1140 = _slang_select(_S1139, _S1138,0.0f);
    return ior_1 + _S1140;
}

__device__ float2  vertexEta(BSDFMaterial material_17, float n_dot_v_0)
{
    bool _S1141 = n_dot_v_0 < 0.0f;
    float _S1142 = _slang_select(_S1141, material_17.ior,1.0f);
    float _S1143 = _slang_select(_S1141, 1.0f,material_17.ior);
    return make_float2 (_S1142, _S1143);
}

__device__ float2  wavelengthEta(BSDFMaterial material_18, float n_dot_v_1, float wavelength_8)
{
    BSDFMaterial refractive_0 = material_18;
    float _S1144 = dispersedIor(material_18.ior, material_18.dispersion, wavelength_8);
    bool _S1145 = wavelength_8 > 0.0f;
    float _S1146 = _slang_select(_S1145, _S1144,material_18.ior);
    (&refractive_0)->ior = _S1146;
    float2  _S1147 = vertexEta(refractive_0, n_dot_v_1);
    return _S1147;
}

__device__ bool neeDecision(BSDFMaterial material_19, float n_dot_v_2, float eta_i_5, float eta_o_5)
{
    float _S1148 = fresnel((F32_abs((n_dot_v_2))), eta_i_5, eta_o_5);
    float3  _S1149 = mix_0(make_float3 (_S1148), material_19.albedo, material_19.metallic);
    float _S1150 = rgb_to_greyscale(_S1149);
    float _S1151 = (F32_max(((1.0f - _S1150) * (1.0f - material_19.metallic) * (1.0f - material_19.transmission)), (0.0f)));
    bool _S1152 = _S1151 > 0.03999999910593033f;
    bool _S1153;
    if(_S1152)
    {
        _S1153 = true;
    }
    else
    {
        _S1153 = (material_19.roughness) > 0.20000000298023224f;
    }
    return _S1153;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_20)
{
    float _S1154 = rgb_to_greyscale(material_20->translucent);
    return _S1154 > 0.0f;
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
    MediumSides _S1155;
    (&_S1155)->behind = *behind_0;
    (&_S1155)->front = *front_0;
    (&_S1155)->fillings = fillings_1;
    (&_S1155)->face = face_1;
    return _S1155;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_10, FKMedium * medium_0, uint filling_0, float3  dir_13, FKMedium * outside_0)
{
    float3  _S1156 = surface_10->geometry_n;
    MediumSides _S1157 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_10->geometry_n);
    MediumSides sides_0 = _S1157;
    bool _S1158 = surface_10->encloses;
    if(_S1158)
    {
        (&sides_0)->behind = surface_10->volume;
        *&((&(&sides_0)->fillings)->x) = surface_10->fills;
        bool _S1159 = (dot_0(dir_13, _S1156)) > 0.0f;
        if(_S1159)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_11, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_14, uint depth_3, uint lobe_3, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1160 = surface_11->geometry_n;
    ShadowContext _S1161 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_11->geometry_n, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
    bool _S1162 = surface_11->encloses;
    ShadowContext context_4;
    if(_S1162)
    {
        FKSurface faced_1 = *surface_11;
        float3  _S1163 = - _S1160;
        float3  _S1164 = _slang_select(turned_0, _S1163,_S1160);
        (&faced_1)->geometry_n = _S1164;
        FKMedium _S1165 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1166 = faced_1;
        FKMedium _S1167 = _S1165;
        MediumSides _S1168 = mediumSides_0(&_S1166, &_S1167, filling_1, dir_14, outside_1);
        ShadowContext _S1169 = ShadowContext_x24init_0(_S1168.behind.extinction, _S1168.front.extinction, _S1168.fillings, _S1160, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
        if(turned_0)
        {
            uint2  _S1170 = _S1168.fillings;
            ShadowContext _S1171 = ShadowContext_x24init_0(_S1168.front.extinction, _S1168.behind.extinction, uint2 {_S1170.y, _S1170.x}, _S1160, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
            context_4 = _S1171;
        }
        else
        {
            context_4 = _S1169;
        }
    }
    else
    {
        context_4 = _S1161;
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

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_8, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_4, BSDFMaterial * material_21, float eta_i_6, float eta_o_6, bool competing_1, uint random_state_13)
{
    float3  _S1172 = light_2->dir;
    bool _S1173 = (dot_0(geometry_n_4, - in_dir_8) * dot_0(geometry_n_4, light_2->dir)) <= 0.0f;
    FixedArray<float3 , 5>  throughputs_1;
    FixedArray<float, 5>  pdfs_4;
    float3  _S1174 = BSDF(in_dir_8, _S1172, smooth_n_5, *material_21, eta_i_6, eta_o_6, _S1173, random_state_13, &throughputs_1, &pdfs_4);
    bool _S1175 = !competing_1;
    bool _S1176;
    if(_S1175)
    {
        _S1176 = true;
    }
    else
    {
        _S1176 = (light_2->density) == 0.0f;
    }
    if(_S1176)
    {
        return _S1174 * light_2->radiance;
    }
    float3  _S1177 = make_float3 (0.0f);
    uint i_26 = 0U;
    float3  weighted_0 = _S1177;
    for(;;)
    {
        if(i_26 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S1178 = (pdfs_4[i_26]) > 0.0f;
        if(_S1178)
        {
            float _S1179 = light_2->density;
            float _S1180 = pdfs_4[i_26] / light_2->density;
            float3  weighted_1 = weighted_0 + throughputs_1[i_26] * make_float3 (pdfs_4[i_26]) / make_float3 (_S1179 * (1.0f + _S1180 * _S1180));
            weighted_0 = weighted_1;
        }
        uint i_27 = i_26 + 1U;
        i_26 = i_27;
    }
    return weighted_0 * light_2->radiance * make_float3 (light_2->density);
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_1, uint random_state_14, bool refracted_3, uint lobe_4, float pdf_7)
{
    SampleBSDF _S1181;
    (&_S1181)->unit_direction = unit_direction_1;
    (&_S1181)->throughput = throughput_1;
    (&_S1181)->random_state = random_state_14;
    (&_S1181)->refracted = refracted_3;
    (&_S1181)->lobe = lobe_4;
    (&_S1181)->pdf = pdf_7;
    return _S1181;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  v_9, float3  n_i_13, float n_i_dot_v_3, BSDFMaterial material_22, Weights w_14, uint random_state_15)
{
    float3  _S1182 = make_float3 (1.0f);
    SampleBSDF _S1183 = SampleBSDF_x24init_0(_S1182, _S1182, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S1183;
    Random _S1184 = pcg(random_state_15);
    Random _S1185 = pcg(_S1184.state);
    (&sample_1)->random_state = _S1185.state;
    float _S1186 = _S1184.value;
    float _S1187 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1186 * _S1186))))));
    float _S1188 = 6.28318548202514648f * _S1185.value;
    float3  _S1189 = tangentToWorld(make_float3 (_S1187 * (F32_cos((_S1188))), _S1184.value, _S1187 * (F32_sin((_S1188)))), n_i_13);
    (&sample_1)->unit_direction = _S1189;
    (&sample_1)->lobe = 4U;
    float3  _S1190 = sheenVelvetBSDF((&sample_1)->unit_direction, v_9, n_i_13, material_22, w_14);
    (&sample_1)->throughput = _S1190;
    float _S1191 = sheenVelvetPDF(_S1184.value, n_i_dot_v_3, w_14);
    (&sample_1)->pdf = _S1191;
    return sample_1;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1192 = (F32_sqrt((random_1_0)));
    float _S1193 = 6.28318548202514648f * random_2_0;
    float _S1194 = _S1192 * (F32_cos((_S1193)));
    float _S1195 = _S1192 * (F32_sin((_S1193)));
    float _S1196 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1194 * _S1194 - _S1195 * _S1195))))));
    return make_float3 (_S1194, _S1196, _S1195);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_4, float3  n_i_14, float n_i_dot_v_4, BSDFMaterial material_23, Weights w_15, uint random_state_16)
{
    float3  _S1197 = make_float3 (1.0f);
    SampleBSDF _S1198 = SampleBSDF_x24init_0(_S1197, _S1197, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S1198;
    Random _S1199 = pcg(random_state_16);
    Random _S1200 = pcg(_S1199.state);
    (&sample_2)->random_state = _S1200.state;
    float3  _S1201 = sampleCosWeightedHemisphere(_S1199.value, _S1200.value);
    float _S1202 = translucentShare(material_23);
    bool _S1203 = u_4 < (w_15.p_diffuse * _S1202);
    float _S1204 = _S1201.y;
    float _S1205 = - _S1204;
    float _S1206 = _slang_select(_S1203, _S1205,_S1204);
    float3  _S1207 = tangentToWorld(make_float3 (_S1201.x, _S1206, _S1201.z), n_i_14);
    (&sample_2)->unit_direction = _S1207;
    (&sample_2)->refracted = _S1203;
    (&sample_2)->lobe = 0U;
    float3  _S1208 = diffuseBSDF((&sample_2)->unit_direction, n_i_14, material_23, w_15);
    (&sample_2)->throughput = _S1208;
    float _S1209 = diffusePDF(_S1206, n_i_dot_v_4, material_23, w_15);
    (&sample_2)->pdf = _S1209;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF toonSample(float3  n_i_15, ToonProfile profile_3, Weights w_16, uint random_state_17)
{
    float3  _S1210 = make_float3 (1.0f);
    SampleBSDF _S1211 = SampleBSDF_x24init_0(_S1210, _S1210, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S1211;
    Random _S1212 = pcg(random_state_17);
    Random _S1213 = pcg(_S1212.state);
    (&sample_3)->random_state = _S1213.state;
    float _S1214 = _S1212.value * profile_3.norm / 6.28318548202514648f;
    float t_23;
    if(profile_3.glossy)
    {
        t_23 = (F32_acos((clamp_1(1.0f - _S1214, -1.0f, 1.0f))));
    }
    else
    {
        t_23 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1214)))), (1.0f))))));
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
        float _S1215 = toonP(t_23, profile_3.a, profile_3.s);
        float _S1216 = _S1215 * (F32_sin((t_23)));
        float _S1217;
        if(profile_3.glossy)
        {
            _S1217 = 1.0f;
        }
        else
        {
            _S1217 = (F32_cos((t_23)));
        }
        float _S1218 = _S1216 * _S1217;
        float _S1219 = toonIntegral(t_23, profile_3.a, profile_3.s, profile_3.glossy);
        float _S1220 = (_S1219 - _S1214) / _S1218;
        bool _S1221 = _S1218 > 0.0f;
        float _S1222 = _slang_select(_S1221, _S1220,0.0f);
        float _S1223 = clamp_1(t_23 - _S1222, 0.0f, profile_3.b);
        int k_1 = k_0 + int(1);
        t_23 = _S1223;
        k_0 = k_1;
    }
    float _S1224 = 6.28318548202514648f * _S1213.value;
    float _S1225 = (F32_sin((t_23)));
    float3  _S1226 = tangentToWorld(make_float3 (_S1225 * (F32_cos((_S1224))), (F32_cos((t_23))), _S1225 * (F32_sin((_S1224)))), profile_3.axis);
    (&sample_3)->unit_direction = _S1226;
    bool _S1227 = (dot_0(n_i_15, (&sample_3)->unit_direction)) < 0.0f;
    (&sample_3)->refracted = _S1227;
    (&sample_3)->lobe = 6U;
    float3  _S1228 = toonBSDF((&sample_3)->unit_direction, n_i_15, profile_3, w_16);
    (&sample_3)->throughput = _S1228;
    float _S1229 = toonPDF((&sample_3)->unit_direction, n_i_15, profile_3, w_16);
    (&sample_3)->pdf = _S1229;
    return sample_3;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_16, float alpha_8, AnisotropicFrame frame_6, BSDFMaterial material_24, Weights w_17, float pdf_h_3, float eta_i_7, float eta_o_7, uint random_state_18)
{
    float3  _S1230 = make_float3 (1.0f);
    SampleBSDF _S1231 = SampleBSDF_x24init_0(_S1230, _S1230, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S1231;
    (&sample_4)->unit_direction = w_17.refracted;
    (&sample_4)->random_state = random_state_18;
    (&sample_4)->refracted = true;
    (&sample_4)->lobe = 1U;
    float3  _S1232 = refractBSDF((&sample_4)->unit_direction, n_i_16, alpha_8, frame_6, material_24, w_17);
    (&sample_4)->throughput = _S1232;
    float _S1233 = refractPDF(dot_0((&sample_4)->unit_direction, ggx_n_3), pdf_h_3, w_17, eta_i_7, eta_o_7);
    (&sample_4)->pdf = _S1233;
    return sample_4;
}

static __device__ float3  reflect_0(float3  i_28, float3  n_9)
{
    return i_28 - make_float3 (2.0f * dot_0(n_9, i_28)) * n_9;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_9, float3  ggx_n_4, float3  n_i_17, float alpha_9, AnisotropicFrame frame_7, Weights w_18, float pdf_h_4, uint random_state_19)
{
    float3  _S1234 = make_float3 (1.0f);
    SampleBSDF _S1235 = SampleBSDF_x24init_0(_S1234, _S1234, 0U, false, 0U, 0.0f);
    SampleBSDF sample_5 = _S1235;
    float3  _S1236 = reflect_0(in_dir_9, ggx_n_4);
    float3  _S1237 = ((((_S1236)) * make_float3(rnorm3df(((_S1236)).x, ((_S1236)).y, ((_S1236)).z))));
    (&sample_5)->unit_direction = _S1237;
    (&sample_5)->random_state = random_state_19;
    (&sample_5)->lobe = 2U;
    float3  _S1238 = reflectBSDF((&sample_5)->unit_direction, n_i_17, alpha_9, frame_7, w_18);
    (&sample_5)->throughput = _S1238;
    float _S1239 = reflectPDF(pdf_h_4, w_18);
    (&sample_5)->pdf = _S1239;
    return sample_5;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_10, float3  n_10, BSDFMaterial material_25, float eta_i_8, float eta_o_8, uint random_init_0, float2  screen_space_0)
{
    uint random_state_20 = random_init_0;
    float3  _S1240 = negate_0(in_dir_10);
    float _S1241 = dot_0(n_10, _S1240);
    float _S1242 = sign_0(_S1241);
    float3  n_i_18 = n_10 * make_float3 (_S1242);
    float _S1243 = (F32_abs((_S1241)));
    float _S1244 = material_25.roughness;
    float _S1245 = _S1244 * _S1244;
    AnisotropicFrame _S1246 = anisotropicFrame(material_25, n_i_18);
    SheenProfile _S1247 = sheenProfile(_S1240, n_i_18, material_25);
    float3  _S1248 = sampleHalfVector(_S1240, n_i_18, _S1245, _S1246, &random_state_20);
    Weights _S1249 = lobeWeights(in_dir_10, _S1240, n_i_18, _S1248, _S1246, _S1247, material_25, eta_i_8, eta_o_8);
    Random _S1250 = pcg(random_state_20);
    random_state_20 = _S1250.state;
    bool _S1251 = (_S1250.value) < (_S1249.p_sheen_velvet);
    if(_S1251)
    {
        SampleBSDF _S1252 = sheenVelvetSample(_S1240, n_i_18, _S1243, material_25, _S1249, random_state_20);
        return _S1252;
    }
    float _S1253 = _S1250.value - _S1249.p_sheen_velvet;
    bool _S1254 = _S1253 < (_S1249.p_diffuse);
    if(_S1254)
    {
        SampleBSDF _S1255 = diffuseSample(_S1253, n_i_18, _S1243, material_25, _S1249, random_state_20);
        return _S1255;
    }
    bool _S1256 = _S1253 < (_S1249.p_diffuse + _S1249.p_toon);
    if(_S1256)
    {
        ToonProfile _S1257 = toonProfile(_S1240, n_i_18, material_25);
        SampleBSDF _S1258 = toonSample(n_i_18, _S1257, _S1249, random_state_20);
        return _S1258;
    }
    float _S1259 = vndfPDF(_S1240, _S1248, n_i_18, _S1243, _S1245, _S1246, _S1249.v_dot_h);
    bool _S1260 = (_S1253 - _S1249.p_toon) < (_S1249.p_diffuse + _S1249.p_refract);
    if(_S1260)
    {
        SampleBSDF _S1261 = refractSample(_S1248, n_i_18, _S1245, _S1246, material_25, _S1249, _S1259, eta_i_8, eta_o_8, random_state_20);
        return _S1261;
    }
    SampleBSDF _S1262 = reflectSample(in_dir_10, _S1248, n_i_18, _S1245, _S1246, _S1249, _S1259, random_state_20);
    return _S1262;
}

__device__ bool withinInverseFootprint(float pdf_8, bool diffuse_0, float prev_cos_0, float distance_5, float threshold_1)
{
    bool _S1263 = pdf_8 > 0.0f;
    bool _S1264;
    if(_S1263)
    {
        if(diffuse_0)
        {
            _S1264 = true;
        }
        else
        {
            _S1264 = (pdf_8 * prev_cos_0 / (distance_5 * distance_5) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S1264 = false;
    }
    return _S1264;
}

__device__ bool roughLobe(float pdf_9, bool diffuse_1, float roughness_1)
{
    bool _S1265 = pdf_9 > 0.0f;
    bool _S1266;
    if(_S1265)
    {
        if(diffuse_1)
        {
            _S1266 = true;
        }
        else
        {
            _S1266 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S1266 = false;
    }
    return _S1266;
}

static __device__ bool passesLayer_0(uint layers_0, bool refracting_0, bool passed_0)
{
    bool _S1267 = layers_0 > 1U;
    bool _S1268;
    if(_S1267)
    {
        _S1268 = refracting_0 != passed_0;
    }
    else
    {
        _S1268 = false;
    }
    return _S1268;
}

static __device__ float widened_0(float spread_1, float pdf_10, bool delta_0)
{
    float _S1269 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * pdf_10))))), (3.14159274101257324f)));
    bool _S1270 = !delta_0;
    float _S1271 = _slang_select(_S1270, _S1269,0.0f);
    return spread_1 + _S1271;
}

static __device__ bool boundsVolume_0(FKSurface * surface_12)
{
    return surface_12->encloses;
}

static __device__ bool leavesInFront_0(float3  face_2, float3  dir_15, float3  g_3)
{
    return ((dot_0(dir_15, g_3)) > 0.0f) == ((dot_0(g_3, face_2)) > 0.0f);
}

static __device__ Shift walk_0(Domain * dom_7, Reservoir * r_8, bool replay_2, float scale_3, Selection * sel_7)
{
    float spread_2;
    bool turned_1;
    bool is_inside_7;
    bool viewed_0;
    bool _S1272;
    float density_2;
    float wavelength_9;
    float width_3;
    float sky_pdf_0;
    float threshold_2;
    uint b_7;
    uint layer_0;
    float3  throughput_2;
    float3  spectral_weight_0;
    TreeSample light_3;
    int _S1273;
    Shift ended_0;
    float density_3;
    float spread_3;
    float width_4;
    float sky_pdf_1;
    float spread_4;
    float width_5;
    uint b_8;
    float3  _S1274 = make_float3 (0.0f);
    Shift _S1275 = Shift_x24init_0(_S1274, 0.0f);
    uint _S1276 = r_8->path;
    uint _S1277 = extractBits_0(r_8->path, 0U, 5U);
    uint _S1278 = extractBits_0(_S1276, 5U, 5U);
    uint _S1279 = extractBits_0(_S1276, 10U, 2U);
    uint _S1280 = extractBits_0(_S1276, 12U, 3U);
    bool passes_0;
    if(replay_2)
    {
        bool _S1281 = _S1280 >= 3U;
        uint _S1282 = _slang_select(_S1281, 1U,0U);
        uint _S1283 = _S1277 + _S1282;
        uint _S1284 = (fcptMaxBounces());
        passes_0 = _S1283 > _S1284;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1275;
    }
    uint _S1285 = _S1278 - 1U;
    bool _S1286 = _S1280 == 3U;
    uint _S1287 = _slang_select(_S1286, 1U,0U);
    uint _S1288 = _S1277 + _S1287;
    bool _S1289 = _S1279 == 0U;
    uint _S1290 = _slang_select(_S1289, _S1288,_S1285);
    FKHit _S1291 = (fcptReservoirHit((*r_8)));
    float3  _S1292 = dom_7->x0;
    float3  _S1293 = dom_7->x1 - dom_7->x0;
    float3  _S1294 = ((((_S1293)) * make_float3(rnorm3df(((_S1293)).x, ((_S1293)).y, ((_S1293)).z))));
    FKRay _S1295 = Ray_x24init_0(dom_7->x1, _S1294);
    FKRay ray_2 = _S1295;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1274;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_2 = throughput_3;
    float3  glowed_0 = _S1274;
    float3  extinction_in_0 = _S1274;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1296 = dom_7->spread;
    float _S1297 = dom_7->width;
    float _S1298 = length_0(_S1293);
    NEEVertex _S1299 = NEEVertex_x24init_0(true, 0.0f, _S1274, _S1274, _S1274);
    NEEVertex nee_vertex_0 = _S1299;
    Vertex _S1300 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S1300;
    Reservoir _S1301 = (Reservoir{});
    Reservoir chain_0 = _S1301;
    uint _S1302 = r_8->seed;
    (&chain_0)->seed = r_8->seed;
    uint _S1303 = extractBits_0(_S1276, 24U, 8U);
    uint _S1304 = insertBits_0(0U, _S1303, 24U, 8U);
    (&chain_0)->path = _S1304;
    (&ray_2)->origin = _S1292;
    (&hit_4)->distance = _S1298;
    FKMedium _S1305 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1306 = filling_2;
    bool _S1307 = (fcptVaryingUsed());
    uint _S1308 = _slang_select(_S1307, _S1306,4294967295U);
    filling_2 = _S1308;
    scatter_in_0 = _S1305.scatter;
    extinction_in_0 = _S1305.extinction;
    g_in_0 = _S1305.g;
    Reservoir _S1309 = chain_0;
    uint _S1310 = filling_2;
    for(;;)
    {
        bool _S1311 = (fcptVaryingUsed());
        if(_S1311)
        {
            passes_0 = _S1310 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1312 = (fcptMajorant((_S1310)));
            spread_2 = _S1312;
        }
        else
        {
            spread_2 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_2)
        {
            turned_1 = 4294967295U == _S1290;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1279 == 1U;
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
            ended_0 = _S1275;
            sky_pdf_0 = 0.0f;
            spread_2 = _S1296;
            width_3 = _S1297;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_7 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1313 = (&prev_0)->rough;
        if(_S1313)
        {
            turned_1 = !(spread_2 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S1314 = stream(_S1302, 384U);
        uint tracking_0 = _S1314;
        weight_2 = throughput_3;
        glowed_0 = _S1274;
        b_7 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        wavelength_9 = _S1296;
        width_3 = _S1297;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1273 = int(1);
                break;
            }
            uint _S1315 = b_7 + 320U;
            bool _S1316 = b_7 == 4294967295U;
            uint _S1317 = _slang_select(_S1316, 384U,_S1315);
            uint _S1318 = stream(_S1302, _S1317);
            Random _S1319 = pcg(_S1318);
            float _S1320 = freeFlight_0(_S1319.value, spread_2);
            if(passes_0)
            {
                float3  _S1321 = (&ray_2)->origin;
                float3  _S1322 = (&ray_2)->unit_direction;
                float _S1323 = (&hit_4)->distance;
                uint _S1324 = _slang_select(_S1316, 0U,b_7);
                uint _S1325 = (&prev_0)->lobe;
                uint _S1326 = _slang_select(_S1316, 3U,_S1325);
                float _S1327 = (fcptTrackMedium((_S1310), (_S1321), (_S1322), (_S1323), (&tracking_0), (&weight_2), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1324), (_S1326), (_S1316)));
                threshold_2 = _S1327;
            }
            else
            {
                threshold_2 = _S1320;
            }
            bool _S1328 = !(threshold_2 < ((&hit_4)->distance));
            if(_S1328)
            {
                _S1273 = int(1);
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
                float3  _S1329 = pathColor(throughput_2 * glowed_0, throughput_3, 0.0f);
                float3  _S1330 = _S1329 / make_float3 (density_2);
                float3  _S1331 = sel_7->glow + _S1330;
                sel_7->glow = _S1331;
            }
            else
            {
            }
            glowed_0 = _S1274;
            uint b_9 = b_7 + 1U;
            float3  _S1332 = (&ray_2)->origin + make_float3 (threshold_2) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1332;
            float3  _S1333 = flightWeight_0(scatter_in_0, extinction_in_0, spread_2, threshold_2, true);
            float3  _S1334 = weight_2;
            float _S1335 = upsample(weight_2, 0.0f);
            float3  _S1336 = make_float3 (_S1335);
            float3  _S1337 = _slang_select(false, _S1336,_S1334);
            float3  _S1338 = _slang_select(passes_0, _S1337,_S1333);
            float3  throughput_4 = throughput_2 * _S1338;
            uint _S1339 = stream(_S1302, b_9 + 320U);
            tracking_0 = _S1339;
            weight_2 = throughput_3;
            float width_6 = width_3 + wavelength_9 * threshold_2;
            float _S1340 = wavelength_9 + 3.14159274101257324f;
            bool _S1341 = scatterSampled_0(replay_2, b_9, _S1290, passes_0);
            TreeSample _S1342 = TreeSample_x24init_0(_S1274, _S1274, 0.0f, 0U);
            if(_S1341)
            {
                float3  _S1343 = (&ray_2)->origin;
                float3  _S1344 = (&ray_2)->unit_direction;
                float3  _S1345 = (&ray_2)->unit_direction;
                uint _S1346 = stream(_S1302, b_9 + 64U);
                float3  _S1347 = extinction_in_0;
                float3  _S1348 = extinction_in_0;
                uint2  _S1349 = make_uint2 (_S1310);
                float3  _S1350 = (&ray_2)->unit_direction;
                uint _S1351 = arrivalLobe_0(b_9, (&prev_0)->lobe);
                FKHit _S1352 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1353 = _S1352;
                ShadowContext _S1354 = ShadowContext_x24init_0(_S1347, _S1348, _S1349, _S1350, b_9, _S1351, false, threshold_2, width_6, &_S1353, false);
                ShadowContext _S1355 = _S1354;
                TreeSample _S1356 = sampleLightTree_0(_S1343, _S1344, _S1345, 0.0f, true, _S1346, &_S1355);
                light_3 = _S1356;
            }
            else
            {
                light_3 = _S1342;
            }
            float _S1357 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S1358 = (fcptMaxBounces());
            bool _S1359 = b_9 < _S1358;
            if(_S1359)
            {
                is_inside_7 = (light_3.density) > 0.0f;
            }
            else
            {
                is_inside_7 = false;
            }
            float _S1360 = _slang_select(is_inside_7, _S1357,0.0f);
            float3  _S1361 = throughput_4 * light_3.radiance;
            float _S1362 = powerHeuristic(light_3.density, _S1360);
            float3  _S1363 = pathColor(_S1361 * make_float3 (_S1357 * _S1362), throughput_3, 0.0f);
            float3  _S1364 = _slang_select(_S1341, _S1363,_S1274);
            if(replay_2)
            {
                viewed_0 = b_9 == _S1290;
            }
            else
            {
                viewed_0 = false;
            }
            if(viewed_0)
            {
                bool _S1365 = _S1279 == 2U;
                if(_S1365)
                {
                    float _S1366 = resamplingTarget(_S1364);
                    passes_0 = _S1366 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1367 = Shift_x24init_0(_S1364, 1.0f);
                    _S1273 = int(0);
                    ended_0 = _S1367;
                    spread_2 = _S1340;
                    threshold_2 = width_6;
                    spectral_weight_0 = throughput_4;
                    layer_0 = b_9;
                    break;
                }
                _S1273 = int(0);
                ended_0 = _S1275;
                spread_2 = _S1340;
                threshold_2 = width_6;
                spectral_weight_0 = throughput_4;
                layer_0 = b_9;
                break;
            }
            bool _S1368 = !replay_2;
            if(_S1368)
            {
                Reservoir candidate_3 = _S1309;
                uint _S1369 = extractBits_0(_S1309.path, 24U, 8U);
                uint _S1370 = insertBits_0(0U, _S1369, 24U, 8U);
                uint _S1371 = extractBits_0(_S1309.path, 10U, 2U);
                bool _S1372 = _S1371 == 1U;
                if(_S1372)
                {
                    float3  _S1373 = safeDivide(_S1364, _S1274);
                    (&candidate_3)->radiance = _S1373;
                }
                else
                {
                    uint _S1374 = insertBits_0(_S1370, b_9 + 1U, 5U, 5U);
                    uint _S1375 = insertBits_0(_S1374, 2U, 10U, 2U);
                    (&candidate_3)->path = _S1375;
                }
                Reservoir _S1376 = withEnd(candidate_3, 0U, b_9, _S1364);
                offer(sel_7, _S1376, _S1364 * make_float3 (scale_3) / make_float3 (density_2));
                float _S1377 = survivalProbability(abs_0(throughput_4), density_2);
                uint _S1378 = stream(_S1302, b_9 + 128U);
                Random _S1379 = pcg(_S1378);
                bool _S1380 = _S1377 < (_S1379.value);
                if(_S1380)
                {
                    _S1272 = true;
                }
                else
                {
                    uint _S1381 = (fcptMaxBounces());
                    _S1272 = b_9 >= _S1381;
                }
                if(_S1272)
                {
                    _S1273 = int(0);
                    ended_0 = _S1275;
                    spread_2 = _S1340;
                    threshold_2 = width_6;
                    spectral_weight_0 = throughput_4;
                    layer_0 = b_9;
                    break;
                }
                float _S1382 = density_2 * _S1377;
                density_2 = _S1382;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1383 = stream(_S1302, b_9);
            float3  _S1384 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1383, &phase_pdf_0);
            (&ray_2)->unit_direction = _S1384;
            NEEVertex _S1385 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S1274, (&ray_2)->origin);
            nee_vertex_0 = _S1385;
            Vertex _S1386 = scatteredVertex_0(false);
            prev_0 = _S1386;
            float _S1387 = (&prev_0)->pdf;
            FKRay _S1388 = ray_2;
            FKHit _S1389 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1390 = (fcptTraverseInstanceBVH((_S1388), (true), (4.294967296e+09f), (false), (_S1389), (false)));
            hit_4 = _S1390;
            b_7 = b_9;
            throughput_2 = throughput_4;
            wavelength_9 = _S1340;
            width_3 = width_6;
            sky_pdf_0 = _S1387;
        }
        if(_S1273 != int(1))
        {
            width_3 = threshold_2;
            throughput_2 = spectral_weight_0;
            b_7 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1275;
        spread_2 = wavelength_9;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1391 = b_7 == 4294967295U;
    bool _S1392 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1392)
    {
        bool _S1393 = !(&nee_vertex_0)->none;
        float _S1394 = _slang_select(_S1393, sky_pdf_0,0.0f);
        float _S1395 = escapeWeight_0(_S1394, (&ray_2)->unit_direction);
        float3  _S1396 = environment_0((&ray_2)->unit_direction, b_7, (&prev_0)->lobe);
        float3  _S1397 = pathColor(throughput_2 * _S1396, throughput_3, 0.0f);
        if(replay_2)
        {
            bool _S1398 = b_7 == _S1290;
            if(_S1398)
            {
                passes_0 = _S1279 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S1397 * make_float3 (_S1395) / make_float3 (r_8->jac), density_2 / r_8->jac);
            }
            if(_S1289)
            {
                passes_0 = _S1286;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_7 == _S1277;
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
                return Shift_x24init_0(_S1397 * make_float3 (_S1395), 1.0f);
            }
            return _S1275;
        }
        Reservoir candidate_4 = chain_0;
        uint _S1399 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1400 = _S1399 == 1U;
        if(_S1400)
        {
            uint _S1401 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S1402 = _S1401 == b_7;
            float _S1403 = _slang_select(_S1402, 1.0f,_S1395);
            float3  _S1404 = safeDivide(_S1397 * make_float3 (_S1403), _S1274);
            (&candidate_4)->radiance = _S1404;
        }
        else
        {
            bool _S1405 = (&prev_0)->rough;
            if(_S1405)
            {
                uint _S1406 = insertBits_0(_S1304, b_7 + 1U, 5U, 5U);
                uint _S1407 = insertBits_0(_S1406, 3U, 10U, 2U);
                uint _S1408 = insertBits_0(_S1407, (&prev_0)->lobe, 15U, 3U);
                bool _S1409 = (&prev_0)->inside;
                uint _S1410 = _slang_select(_S1409, 1U,0U);
                uint _S1411 = insertBits_0(_S1408, _S1410, 22U, 1U);
                (&candidate_4)->path = _S1411;
                (&candidate_4)->jac = (&prev_0)->pdf;
                (&candidate_4)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S1412 = _S1397 * make_float3 (_S1395);
        Reservoir _S1413 = withEnd(candidate_4, 3U, b_7, _S1412);
        offer(sel_7, _S1413, _S1412 * make_float3 (scale_3) / make_float3 (density_2));
        return _S1275;
    }
    float3  _S1414 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S1414;
    bool _S1415 = (fcptVaryingUsed());
    if(_S1415)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1416 = !replay_2;
        if(_S1416)
        {
            float3  _S1417 = pathColor(throughput_2 * glowed_0, throughput_3, 0.0f);
            float3  _S1418 = _S1417 / make_float3 (density_2);
            float3  _S1419 = sel_7->glow + _S1418;
            sel_7->glow = _S1419;
        }
        float3  _S1420 = throughput_2 * weight_2;
        throughput_2 = _S1420;
    }
    else
    {
        float3  _S1421 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
        float3  _S1422 = throughput_2 * _S1421;
        throughput_2 = _S1422;
    }
    float _S1423 = width_3 + spread_2 * (&hit_4)->distance;
    uint _S1424 = b_7 + 1U;
    b_7 = _S1424;
    layer_0 = 0U;
    width_3 = _S1423;
    passes_0 = false;
    wavelength_9 = 0.0f;
    threshold_2 = 0.0f;
    turned_1 = false;
    is_inside_7 = false;
    spectral_weight_0 = throughput_3;
    float3  chain_throughput_0 = _S1274;
    float3  reconnection_0 = _S1274;
    viewed_0 = _S1391;
    for(;;)
    {
        bool _S1425 = ((&hit_4)->is_point_light) == 1U;
        if(replay_2)
        {
            _S1272 = _S1279 == 1U;
        }
        else
        {
            _S1272 = false;
        }
        bool _S1426;
        if(_S1272)
        {
            _S1426 = b_7 == _S1278;
        }
        else
        {
            _S1426 = false;
        }
        bool _S1427;
        if(_S1426)
        {
            bool _S1428 = ((&hit_4)->instance_index) != (_S1291.instance_index);
            if(_S1428)
            {
                _S1427 = true;
            }
            else
            {
                _S1427 = ((&hit_4)->triangle_index) != (_S1291.triangle_index);
            }
        }
        else
        {
            _S1427 = false;
        }
        if(_S1427)
        {
            return _S1275;
        }
        FKMedium _S1429 = Medium_x24init_0(_S1274, _S1274, 0.0f);
        BSDFMaterial _S1430 = Material_x24init_0(_S1274, _S1274, 0.0f, 0.0f, 0.0f, 0.0f, _S1274, throughput_3, 1.0f, _S1274, _S1274, 0.5f, 0.0f, 0.0f, _S1274, 0.0f, _S1274, 0.0f);
        FKMedium _S1431 = _S1429;
        FKSurface _S1432 = Surface_x24init_0(_S1274, _S1274, 0.0f, &_S1430, false, 0U, 1.0f, false, &_S1431, 4294967295U, _S1274);
        bool _S1433 = !_S1425;
        bool scatter_2;
        bool is_inside_8;
        float geometry_density_2;
        float3  throughput_5;
        FKSurface surface_13;
        if(_S1433)
        {
            uint _S1434 = stream(_S1302, b_7);
            uint _S1435 = arrivalLobe_0(b_7, (&prev_0)->lobe);
            FKSurface _S1436 = (fcptSurfaceAtPath((hit_4), ((&ray_2)->origin), (_S1434), (width_3), (layer_0), (b_7), (_S1435), ((&ray_2)->unit_direction)));
            bool _S1437 = !passes_0;
            FKSurface _S1438 = _S1436;
            FKSurface _S1439 = emitting_0(&_S1438, _S1437);
            uint _S1440 = stream(_S1302, b_7 + 256U);
            Random _S1441 = pcg(_S1440);
            FKSurface _S1442 = _S1439;
            FKSurface _S1443 = uncovered_0(&_S1442, _S1441.value);
            float _S1444 = facingSign(_S1443.material.transmission, _S1443.geometry_n, (&ray_2)->unit_direction);
            bool _S1445 = _S1444 < 0.0f;
            bool _S1446 = (_S1443.material.transmission) > 0.0f;
            if(_S1446)
            {
                bool _S1447 = arrivesBehind_0((&ray_2)->unit_direction, _S1443.geometry_n);
                scatter_2 = _S1447;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1448 = _S1443;
            FKSurface _S1449 = facingRay_0(&_S1448, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S1450 = arrivesBehind_0((&ray_2)->unit_direction, _S1449.geometry_n);
                is_inside_8 = _S1450;
            }
            else
            {
                is_inside_8 = scatter_2;
            }
            if(is_inside_8)
            {
                float _S1451 = (&hit_4)->distance;
                float _S1452 = upsample(_S1449.material.absorption, wavelength_9);
                float3  _S1453 = make_float3 (_S1452);
                bool _S1454 = wavelength_9 > 0.0f;
                float3  _S1455 = _slang_select(_S1454, _S1453,_S1449.material.absorption);
                float3  _S1456 = beerLambert(_S1451, _S1455);
                float3  _S1457 = throughput_2 * _S1456;
                throughput_5 = _S1457;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S1458 = !_S1449.skip;
            float geometry_density_3 = geometryDensity(_S1449.geometry_n, (&ray_2)->unit_direction, (&hit_4)->distance);
            bool _S1459 = b_7 == _S1424;
            if(_S1459)
            {
                float _S1460 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S1460;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            float _S1461 = geometry_density_2;
            scatter_2 = _S1458;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S1461;
            surface_13 = _S1449;
            turned_1 = _S1445;
        }
        else
        {
            scatter_2 = false;
            geometry_density_2 = 0.0f;
            surface_13 = _S1432;
            throughput_5 = throughput_2;
            is_inside_8 = is_inside_7;
        }
        bool _S1462 = withinFootprint(scatter_2, (&prev_0)->rough, (&prev_0)->pdf, geometry_density_2, threshold_2);
        FKSurface _S1463 = surface_13;
        float _S1464 = dot_0(surface_13.smooth_n, - (&ray_2)->unit_direction);
        bool _S1465 = (fcptDispersionUsed());
        bool _S1466;
        if(_S1465)
        {
            _S1466 = wavelength_9 == 0.0f;
        }
        else
        {
            _S1466 = false;
        }
        bool _S1467;
        if(_S1466)
        {
            _S1467 = scatter_2;
        }
        else
        {
            _S1467 = false;
        }
        bool _S1468;
        if(_S1467)
        {
            bool _S1469 = dispersive(surface_13.material);
            _S1468 = _S1469;
        }
        else
        {
            _S1468 = false;
        }
        float3  throughput_6;
        if(_S1468)
        {
            uint _S1470 = stream(_S1302, 512U);
            Random _S1471 = pcg(_S1470);
            uint _S1472 = extractBits_0(_S1276, 25U, 7U);
            float _S1473 = (float(_S1472) + _S1471.value) / 128.0f;
            uint _S1474 = extractBits_0(_S1276, 24U, 1U);
            bool _S1475 = _S1474 == 1U;
            float _S1476 = _slang_select(_S1475, _S1473,_S1471.value);
            float2  _S1477 = sampleWavelength(_S1476);
            float wavelength_10 = _S1477.x;
            float3  _S1478 = wavelengthWeights(wavelength_10);
            float3  _S1479 = _S1478 / make_float3 (_S1477.y);
            float _S1480 = upsample(throughput_5, wavelength_10);
            float3  _S1481 = make_float3 (_S1480);
            float _S1482 = upsample(scatter_in_0, wavelength_10);
            float3  _S1483 = make_float3 (_S1482);
            scatter_in_0 = _S1483;
            float _S1484 = upsample(extinction_in_0, wavelength_10);
            float3  _S1485 = make_float3 (_S1484);
            extinction_in_0 = _S1485;
            wavelength_9 = wavelength_10;
            throughput_6 = _S1481;
            spectral_weight_0 = _S1479;
        }
        else
        {
            throughput_6 = throughput_5;
        }
        BSDFMaterial _S1486 = pathMaterial(surface_13.material, wavelength_9);
        float2  _S1487 = wavelengthEta(_S1486, _S1464, wavelength_9);
        bool _S1488;
        if(scatter_2)
        {
            bool _S1489 = neeDecision(_S1486, _S1464, _S1487.x, _S1487.y);
            _S1488 = _S1489;
        }
        else
        {
            _S1488 = false;
        }
        bool _S1490;
        if(passes_0)
        {
            _S1490 = true;
        }
        else
        {
            _S1490 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1490)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1488;
        }
        bool _S1491 = (fcptHairUsed());
        bool _S1492;
        if(_S1491)
        {
            float3  _S1493 = surface_13.hair;
            _S1492 = (dot_0(_S1493, _S1493)) > 0.0f;
        }
        else
        {
            _S1492 = false;
        }
        bool _S1494;
        if(_S1492)
        {
            _S1494 = true;
        }
        else
        {
            BSDFMaterial _S1495 = _S1486;
            bool _S1496 = isTranslucent_0(&_S1495);
            _S1494 = _S1496;
        }
        bool _S1497;
        if(_S1494)
        {
            _S1497 = true;
        }
        else
        {
            bool _S1498 = (_S1486.transmission) > 0.0f;
            if(_S1498)
            {
                uint _S1499 = (fcptLayers((hit_4)));
                _S1497 = _S1499 == 1U;
            }
            else
            {
                _S1497 = false;
            }
        }
        float3  emission_0;
        if(_S1425)
        {
            float3  _S1500 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1500;
        }
        else
        {
            emission_0 = _S1486.emissive;
        }
        bool _S1501 = !replay_2;
        bool _S1502;
        if(_S1501)
        {
            _S1502 = true;
        }
        else
        {
            _S1502 = b_7 >= _S1290;
        }
        bool _S1503;
        if(_S1502)
        {
            float _S1504 = rgb_to_greyscale(emission_0);
            _S1503 = _S1504 > 0.0f;
        }
        else
        {
            _S1503 = false;
        }
        float3  emission_1;
        if(_S1503)
        {
            NEEVertex _S1505 = nee_vertex_0;
            FKHit _S1506 = hit_4;
            float _S1507 = emissionWeight_0(&_S1505, &_S1506, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1507);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1508;
        if(replay_2)
        {
            _S1508 = _S1279 == 1U;
        }
        else
        {
            _S1508 = false;
        }
        bool _S1509;
        if(_S1508)
        {
            _S1509 = b_7 > _S1278;
        }
        else
        {
            _S1509 = false;
        }
        bool _S1510;
        if(_S1509)
        {
            _S1510 = b_7 == _S1277;
        }
        else
        {
            _S1510 = false;
        }
        bool _S1511;
        if(_S1510)
        {
            bool _S1512 = _S1280 == 1U;
            if(_S1512)
            {
                _S1511 = true;
            }
            else
            {
                _S1511 = _S1280 == 2U;
            }
        }
        else
        {
            _S1511 = false;
        }
        if(_S1511)
        {
            bool _S1513 = _S1425 != (_S1280 == 2U);
            if(_S1513)
            {
                return _S1275;
            }
            float3  _S1514 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_9);
            return Shift_x24init_0(_S1514 / make_float3 (r_8->jac), density_2 / r_8->jac);
        }
        uint _S1515 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1516 = _S1515 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1517 = insertBits_0(_S1304, b_7, 5U, 5U);
        uint _S1518 = insertBits_0(_S1517, 1U, 10U, 2U);
        uint _S1519 = insertBits_0(_S1518, (&prev_0)->lobe, 15U, 3U);
        bool _S1520 = (&prev_0)->inside;
        uint _S1521 = _slang_select(_S1520, 1U,0U);
        uint _S1522 = insertBits_0(_S1519, _S1521, 22U, 1U);
        (&here_0)->path = _S1522;
        uint _S1523 = (&here_0)->path;
        bool _S1524 = wavelength_9 > 0.0f;
        uint _S1525 = _slang_select(_S1524, 1U,0U);
        uint _S1526 = insertBits_0(_S1523, _S1525, 23U, 1U);
        (&here_0)->path = _S1526;
        float _S1527 = (&prev_0)->pdf * geometry_density_2;
        (&here_0)->jac = _S1527;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1528;
        if(replay_2)
        {
            _S1528 = _S1279 == 1U;
        }
        else
        {
            _S1528 = false;
        }
        bool _S1529;
        if(_S1528)
        {
            _S1529 = b_7 == _S1278;
        }
        else
        {
            _S1529 = false;
        }
        bool _S1530 = b_7 == _S1290;
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
                bool _S1533 = _S1279 != 1U;
                if(_S1533)
                {
                    _S1531 = _S1279 != 3U;
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
            _S1534 = _S1279 == 2U;
        }
        else
        {
            _S1534 = false;
        }
        bool _S1535;
        if(_S1534)
        {
            _S1535 = !_S1462;
        }
        else
        {
            _S1535 = false;
        }
        bool _S1536;
        if(_S1535)
        {
            _S1536 = _S1280 != 4U;
        }
        else
        {
            _S1536 = false;
        }
        bool _S1537 = _S1278 == _S1277;
        bool _S1538;
        if(_S1537)
        {
            _S1538 = _S1280 == 0U;
        }
        else
        {
            _S1538 = false;
        }
        bool _S1539;
        if(_S1538)
        {
            _S1539 = ((&hit_4)->instance_index) == (_S1291.instance_index);
        }
        else
        {
            _S1539 = false;
        }
        bool _S1540;
        if(_S1539)
        {
            _S1540 = ((&hit_4)->triangle_index) == (_S1291.triangle_index);
        }
        else
        {
            _S1540 = false;
        }
        bool _S1541;
        if(_S1540)
        {
            _S1541 = _S1462;
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
        TreeSample _S1544 = TreeSample_x24init_0(_S1274, _S1274, 0.0f, 0U);
        uint2  _S1545 = make_uint2 (0U);
        float2  _S1546 = make_float2 (0.0f);
        FKHit _S1547 = Hit_x24init_0(_S1546, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1548 = _S1547;
        ShadowContext _S1549 = ShadowContext_x24init_0(_S1274, _S1274, _S1545, _S1274, 0U, 0U, false, 0.0f, 0.0f, &_S1548, false);
        bool _S1550;
        if(nee_0)
        {
            _S1550 = _S1502;
        }
        else
        {
            _S1550 = false;
        }
        ShadowContext context_5;
        if(_S1550)
        {
            uint _S1551 = arrivalLobe_0(b_7, (&prev_0)->lobe);
            FKMedium _S1552 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1553 = surface_13;
            FKHit _S1554 = hit_4;
            FKMedium _S1555 = _S1552;
            ShadowContext _S1556 = shadowContext_0(&_S1553, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_7, _S1551, (&hit_4)->distance, width_3, &_S1554, _S1492, &_S1555);
            context_5 = _S1556;
        }
        else
        {
            context_5 = _S1549;
        }
        float3  throughput_7;
        float3  lit_0;
        if(_S1543)
        {
            float3  _S1557 = (&ray_2)->origin;
            if(_S1492)
            {
                throughput_7 = _S1274;
            }
            else
            {
                throughput_7 = _S1463.smooth_n;
            }
            FKSurface _S1558 = surface_13;
            uint _S1559 = stream(_S1302, b_7 + 64U);
            ShadowContext _S1560 = context_5;
            TreeSample _S1561 = sampleLightTree_0(_S1557, throughput_7, surface_13.geometry_n, surface_13.geometry_offset, _S1497, _S1559, &_S1560);
            bool _S1562 = any_1((_S1561.radiance) != _S1274);
            if(_S1562)
            {
                if(_S1492)
                {
                    uint _S1563 = (fcptMaxBounces());
                    bool _S1564 = b_7 < _S1563;
                    FKSurface _S1565 = surface_13;
                    TreeSample _S1566 = _S1561;
                    float3  _S1567 = hairLight_0(&_S1565, (&ray_2)->unit_direction, &_S1566, _S1564);
                    lit_0 = _S1567;
                }
                else
                {
                    float _S1568 = _S1487.x;
                    float _S1569 = _S1487.y;
                    uint _S1570 = (fcptMaxBounces());
                    bool _S1571 = b_7 < _S1570;
                    TreeSample _S1572 = _S1561;
                    BSDFMaterial _S1573 = _S1486;
                    float3  _S1574 = lightBSDF_0((&ray_2)->unit_direction, &_S1572, _S1463.smooth_n, _S1558.geometry_n, &_S1573, _S1568, _S1569, _S1571, surface_13.random_state);
                    lit_0 = _S1574;
                }
            }
            else
            {
                lit_0 = _S1274;
            }
            light_3 = _S1561;
        }
        else
        {
            light_3 = _S1544;
            lit_0 = _S1274;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1575;
        bool _S1576;
        float density_4;
        if(_S1529)
        {
            bool _S1577 = !_S1462;
            if(_S1577)
            {
                return _S1275;
            }
            uint _S1578 = extractBits_0(_S1276, 23U, 1U);
            bool _S1579 = _S1524 != (_S1578 == 1U);
            if(_S1579)
            {
                return _S1275;
            }
            float3  throughput_8 = throughput_6 * make_float3 (geometry_density_2);
            float density_5 = density_2 * geometry_density_2;
            if(_S1537)
            {
                viewed_1 = _S1280 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                float3  _S1580 = pathColor(throughput_8 * emission_1, spectral_weight_0, wavelength_9);
                return Shift_x24init_0(_S1580 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1537)
            {
                refracted_4 = _S1280 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S1581 = !nee_0;
                if(_S1581)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1582 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1582 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1275;
                }
                float3  _S1583 = pathColor(throughput_8 * lit_0, spectral_weight_0, wavelength_9);
                return Shift_x24init_0(_S1583 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1537)
            {
                wrong_side_0 = _S1280 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1584 = !nee_0;
                if(_S1584)
                {
                    return _S1275;
                }
                bool _S1585 = (fcptWorldReadsPath());
                if(_S1585)
                {
                    float _S1586 = environmentPdf_0(r_8->dir);
                    uint _S1587 = b_7 + 1U;
                    FKSurface _S1588 = surface_13;
                    float3  _S1589 = skyColor_0((&ray_2)->unit_direction, r_8->dir, &_S1588, wavelength_9, _S1487, is_inside_8, _S1586, surface_13.random_state, _S1587);
                    float3  _S1590 = pathColor(throughput_8 * (_S1589 * r_8->radiance), spectral_weight_0, wavelength_9);
                    return Shift_x24init_0(_S1590 / make_float3 (r_8->jac), density_5 / r_8->jac);
                }
                float _S1591 = environmentPdf_0(r_8->dir);
                float3  _S1592 = skyBSDF((&ray_2)->unit_direction, r_8->dir, surface_13, _S1486, _S1487, is_inside_8, _S1591, surface_13.random_state);
                float3  _S1593 = pathColor(throughput_8 * _S1592 * r_8->radiance, spectral_weight_0, wavelength_9);
                return Shift_x24init_0(_S1593 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            uint _S1594 = extractBits_0(_S1276, 21U, 1U);
            bool _S1595 = nee_0 != (_S1594 == 1U);
            if(_S1595)
            {
                return _S1275;
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
                bool _S1596 = !scatter_2;
                if(_S1596)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1597 = _S1279 != 1U;
                    if(_S1597)
                    {
                        refracted_4 = _S1279 != 3U;
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
                bool _S1598 = _S1279 == 2U;
                if(_S1598)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1462;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1280 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1492)
                    {
                        return _S1275;
                    }
                    uint _S1599 = stream(_S1302, b_7 + 448U);
                    FKRay _S1600 = ray_2;
                    FKSurface _S1601 = surface_13;
                    ShadowContext _S1602 = context_5;
                    SkySample _S1603 = sampleSky_0(&_S1600, &_S1601, wavelength_9, _S1487, is_inside_8, _S1599, surface_13.random_state, &_S1602);
                    float3  _S1604 = pathColor(throughput_6 * _S1603.color, spectral_weight_0, wavelength_9);
                    return Shift_x24init_0(_S1604, 1.0f);
                }
                if(_S1598)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1462;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1605 = rgb_to_greyscale(light_3.radiance);
                    bool _S1606 = !(_S1605 > 0.0f);
                    if(_S1606)
                    {
                        return _S1275;
                    }
                    float3  _S1607 = pathColor(throughput_6 * lit_0, spectral_weight_0, wavelength_9);
                    return Shift_x24init_0(_S1607, 1.0f);
                }
                if(_S1289)
                {
                    passes_0 = _S1280 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1425;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float3  _S1608 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_9);
                    return Shift_x24init_0(_S1608, 1.0f);
                }
                if(_S1289)
                {
                    passes_0 = _S1280 == 1U;
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
                    passes_0 = !_S1462;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float3  _S1609 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_9);
                    return Shift_x24init_0(_S1609, 1.0f);
                }
                return _S1275;
            }
            else
            {
                if(_S1501)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1610 = b_7 > 0U;
                    if(_S1610)
                    {
                        Reservoir candidate_5 = chain_0;
                        if(_S1516)
                        {
                            float3  _S1611 = safeDivide(throughput_6 * emission_1, chain_throughput_0);
                            (&candidate_5)->radiance = _S1611;
                        }
                        else
                        {
                            if(_S1462)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1612 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_9);
                        Reservoir _S1613 = withEnd(candidate_5, 1U, b_7, _S1612);
                        offer(sel_7, _S1613, _S1612 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1614 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_9);
                        float3  _S1615 = sel_7->glow + _S1614;
                        sel_7->glow = _S1615;
                    }
                    if(nee_0)
                    {
                        float3  _S1616 = pathColor(throughput_6 * lit_0, spectral_weight_0, wavelength_9);
                        Reservoir candidate_6 = chain_0;
                        if(_S1516)
                        {
                            float3  _S1617 = safeDivide(_S1616, chain_throughput_0);
                            (&candidate_6)->radiance = _S1617;
                        }
                        else
                        {
                            if(_S1462)
                            {
                                candidate_6 = here_0;
                                uint _S1618 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1618;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1619 = insertBits_0(_S1304, b_7 + 1U, 5U, 5U);
                                uint _S1620 = insertBits_0(_S1619, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1620;
                            }
                        }
                        Reservoir _S1621 = withEnd(candidate_6, 0U, b_7, _S1616);
                        offer(sel_7, _S1621, _S1616 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1492)
                        {
                            _S1575 = false;
                        }
                        else
                        {
                            bool _S1622 = environmentMapped_0();
                            _S1575 = _S1622;
                        }
                    }
                    else
                    {
                        _S1575 = false;
                    }
                    if(_S1575)
                    {
                        uint _S1623 = (fcptMaxBounces());
                        _S1576 = b_7 < _S1623;
                    }
                    else
                    {
                        _S1576 = false;
                    }
                    if(_S1576)
                    {
                        uint _S1624 = stream(_S1302, b_7 + 448U);
                        FKRay _S1625 = ray_2;
                        FKSurface _S1626 = surface_13;
                        ShadowContext _S1627 = context_5;
                        SkySample _S1628 = sampleSky_0(&_S1625, &_S1626, wavelength_9, _S1487, is_inside_8, _S1624, surface_13.random_state, &_S1627);
                        float3  _S1629 = pathColor(throughput_6 * _S1628.color, spectral_weight_0, wavelength_9);
                        Reservoir candidate_7 = chain_0;
                        if(_S1516)
                        {
                            float3  _S1630 = safeDivide(_S1629, chain_throughput_0);
                            (&candidate_7)->radiance = _S1630;
                        }
                        else
                        {
                            if(_S1462)
                            {
                                candidate_7 = here_0;
                                uint _S1631 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1631;
                                (&candidate_7)->dir = _S1628.dir;
                                (&candidate_7)->radiance = _S1628.radiance;
                            }
                            else
                            {
                                uint _S1632 = insertBits_0(_S1304, b_7 + 1U, 5U, 5U);
                                uint _S1633 = insertBits_0(_S1632, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1633;
                            }
                        }
                        Reservoir _S1634 = withEnd(candidate_7, 4U, b_7, _S1629);
                        offer(sel_7, _S1634, _S1629 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                }
            }
            throughput_7 = throughput_6;
            density_4 = density_2;
        }
        bool _S1635;
        bool _S1636;
        bool _S1637;
        bool straight_0;
        bool _S1638;
        bool _S1639;
        bool _S1640;
        bool _S1641;
        bool _S1642;
        bool _S1643;
        bool _S1644;
        bool _S1645;
        bool _S1646;
        bool _S1647;
        bool _S1648;
        bool _S1649;
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
                viewed_1 = _S1530;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1650 = extractBits_0(_S1276, 15U, 3U);
            uint _S1651 = extractBits_0(_S1276, 18U, 3U);
            uint _S1652 = _slang_select(_S1529, _S1651,_S1650);
            float3  _S1653 = r_8->dir;
            bool refracted_5 = _S1652 == 1U;
            SampleBSDF _S1654 = SampleBSDF_x24init_0(_S1274, _S1274, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1654;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1655 = extractBits_0(_S1276, 22U, 1U);
                bool _S1656 = is_inside_8 != (_S1655 == 1U);
                if(_S1656)
                {
                    return _S1275;
                }
                bool _S1657 = _S1279 == 1U;
                if(_S1657)
                {
                    float3  _S1658 = (fcptHitPosition((_S1291)));
                    throughput_9 = _S1658;
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
                    BSDFMaterial _S1659 = _S1486;
                    bool _S1660 = isTranslucent_0(&_S1659);
                    if(_S1660)
                    {
                        refracted_4 = _S1652 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1661 = throughput_9 - (&ray_2)->origin;
                        float3  _S1662 = _slang_select(_S1657, _S1661,_S1653);
                        wrong_side_0 = (dot_0(_S1463.smooth_n, _S1662) * _S1464) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1657)
                {
                    float3  _S1663 = (&ray_2)->origin;
                    FKSurface _S1664 = surface_13;
                    float3  _S1665 = - _S1463.smooth_n;
                    bool _S1666 = is_inside_8 != refracted_4;
                    float3  _S1667 = _slang_select(_S1666, _S1665,_S1463.smooth_n);
                    float3  _S1668 = throughput_9 - (_S1663 + make_float3 (_S1664.geometry_offset) * _S1667);
                    float3  _S1669 = ((((_S1668)) * make_float3(rnorm3df(((_S1668)).x, ((_S1668)).y, ((_S1668)).z))));
                    reconnection_1 = _S1669;
                }
                else
                {
                    reconnection_1 = _S1653;
                }
                if(_S1492)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1670 = wrongSide_0(is_inside_8, refracted_4, reconnection_1, surface_13.geometry_n);
                    wrong_side_0 = _S1670;
                }
                if(wrong_side_0)
                {
                    return _S1275;
                }
                float3  _S1671 = throughput_9;
                throughput_9 = reconnection_1;
                b_10 = _S1652;
                wrong_side_0 = false;
                reconnection_1 = _S1671;
            }
            else
            {
                bool _S1672 = !_S1529;
                if(_S1672)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1673;
                    if(_S1492)
                    {
                        SampleBSDF _S1674 = (fcptSampleHair((surface_13.hair), (_S1486.albedo), (_S1486.specular_tint), ((&ray_2)->unit_direction), (surface_13.random_state)));
                        _S1673 = _S1674;
                    }
                    else
                    {
                        SampleBSDF _S1675 = sampleBSDF((&ray_2)->unit_direction, _S1463.smooth_n, _S1486, _S1487.x, _S1487.y, surface_13.random_state, _S1546);
                        _S1673 = _S1675;
                    }
                    bsdf_sampled_0 = _S1673;
                    if(_S1492)
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
                            return _S1275;
                        }
                        break;
                    }
                    if(_S1492)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1676 = wrongSide_0(is_inside_8, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_13.geometry_n);
                        wrong_side_0 = _S1676;
                    }
                    if(wrong_side_0)
                    {
                        _S1575 = (_S1486.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1575 = false;
                    }
                    if(_S1575)
                    {
                        SampleBSDF _S1677 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_13.geometry_n, _S1486, _S1487.x, _S1487.y, (&bsdf_sampled_0)->random_state, _S1546);
                        (&bsdf_sampled_0)->unit_direction = _S1677.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1677.refracted;
                        (&bsdf_sampled_0)->throughput = _S1677.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1678 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_13.geometry_n)) * surface_13.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1678;
                        }
                    }
                    uint _S1679 = (&bsdf_sampled_0)->lobe;
                    float3  _S1680 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1681 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1682 = (&bsdf_sampled_0)->pdf;
                    float _S1683 = _slang_select(wrong_side_0, 0.0f,_S1682);
                    (&lobe_5)->pdf = _S1683;
                    throughput_9 = _S1680;
                    b_10 = _S1679;
                    refracted_4 = _S1681;
                }
                else
                {
                    throughput_9 = _S1653;
                    b_10 = _S1652;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1575 = true;
            }
            else
            {
                _S1575 = _S1529;
            }
            float3  chain_throughput_1;
            if(_S1575)
            {
                if(_S1492)
                {
                    SampleBSDF _S1684 = (fcptConnectHair((surface_13.hair), (_S1486.albedo), (_S1486.specular_tint), ((&ray_2)->unit_direction), (throughput_9)));
                    lobe_5 = _S1684;
                }
                else
                {
                    float3  _S1685 = (&ray_2)->unit_direction;
                    float3  _S1686 = negate_0(_S1685);
                    float _S1687 = sign_0(_S1464);
                    float3  _S1688 = _S1463.smooth_n * make_float3 (_S1687);
                    float _S1689 = dot_0(_S1688, throughput_9);
                    float _S1690 = _S1486.roughness;
                    float _S1691 = _S1690 * _S1690;
                    AnisotropicFrame _S1692 = anisotropicFrame(_S1486, _S1688);
                    SheenProfile _S1693 = sheenProfile(_S1686, _S1688, _S1486);
                    float3  _S1694 = reflectedHalf(_S1685, throughput_9);
                    bool _S1695 = b_10 == 1U;
                    if(_S1695)
                    {
                        float3  _S1696 = refractedHalf(_S1685, throughput_9, _S1463.smooth_n, _S1487.x, _S1487.y);
                        throughput_10 = _S1696;
                    }
                    else
                    {
                        throughput_10 = _S1694;
                    }
                    bool _S1697 = b_10 == 0U;
                    if(_S1697)
                    {
                        _S1576 = true;
                    }
                    else
                    {
                        _S1576 = b_10 == 6U;
                    }
                    if(_S1576)
                    {
                        float3  _S1698 = sampledHalf(_S1686, _S1688, _S1691, _S1692, surface_13.random_state);
                        throughput_11 = _S1698;
                    }
                    else
                    {
                        throughput_11 = throughput_10;
                    }
                    float _S1699 = _S1487.x;
                    float _S1700 = _S1487.y;
                    Weights _S1701 = lobeWeights(_S1685, _S1686, _S1688, throughput_11, _S1692, _S1693, _S1486, _S1699, _S1700);
                    float _S1702 = (F32_abs((_S1464)));
                    float _S1703 = vndfPDF(_S1686, throughput_11, _S1688, _S1702, _S1691, _S1692, _S1701.v_dot_h);
                    switch(b_10)
                    {
                    case 0U:
                        {
                            float _S1704 = diffusePDF(_S1689, _S1702, _S1486, _S1701);
                            float3  _S1705 = diffuseBSDF(throughput_9, _S1688, _S1486, _S1701);
                            density_6 = _S1704;
                            chain_throughput_1 = _S1705;
                            break;
                        }
                    case 1U:
                        {
                            float _S1706 = refractPDF(dot_0(throughput_9, throughput_11), _S1703, _S1701, _S1699, _S1700);
                            float3  _S1707 = refractBSDF(throughput_9, _S1688, _S1691, _S1692, _S1486, _S1701);
                            density_6 = _S1706;
                            chain_throughput_1 = _S1707;
                            break;
                        }
                    case 4U:
                        {
                            float _S1708 = sheenVelvetPDF(_S1689, _S1702, _S1701);
                            float3  _S1709 = sheenVelvetBSDF(throughput_9, _S1686, _S1688, _S1486, _S1701);
                            density_6 = _S1708;
                            chain_throughput_1 = _S1709;
                            break;
                        }
                    case 6U:
                        {
                            ToonProfile _S1710 = toonProfile(_S1686, _S1688, _S1486);
                            float _S1711 = toonPDF(throughput_9, _S1688, _S1710, _S1701);
                            float3  _S1712 = toonBSDF(throughput_9, _S1688, _S1710, _S1701);
                            density_6 = _S1711;
                            chain_throughput_1 = _S1712;
                            break;
                        }
                    default:
                        {
                            float _S1713 = reflectPDF(_S1703, _S1701);
                            float3  _S1714 = reflectBSDF(throughput_9, _S1688, _S1691, _S1692, _S1701);
                            density_6 = _S1713;
                            chain_throughput_1 = _S1714;
                            break;
                        }
                    }
                    bool _S1715 = density_6 > 0.0f;
                    if(_S1715)
                    {
                        SampleBSDF _S1716 = SampleBSDF_x24init_0(throughput_9, chain_throughput_1, surface_13.random_state, _S1695, b_10, density_6);
                        lobe_5 = _S1716;
                    }
                }
            }
            bool _S1717 = b_10 == 0U;
            if(_S1717)
            {
                _S1576 = true;
            }
            else
            {
                _S1576 = b_10 == 4U;
            }
            if(_S1576)
            {
                _S1635 = true;
            }
            else
            {
                _S1635 = b_10 == 6U;
            }
            if(_S1492)
            {
                _S1636 = false;
            }
            else
            {
                bool _S1718 = !_S1635;
                if(_S1718)
                {
                    bool _S1719 = (_S1486.roughness) == 0.0f;
                    if(_S1719)
                    {
                        _S1636 = true;
                    }
                    else
                    {
                        bool _S1720 = b_10 == 1U;
                        if(_S1720)
                        {
                            _S1636 = (_S1487.x) == (_S1487.y);
                        }
                        else
                        {
                            _S1636 = false;
                        }
                    }
                }
                else
                {
                    _S1636 = false;
                }
            }
            bool _S1721 = !_S1492;
            if(_S1721)
            {
                _S1637 = b_10 == 1U;
            }
            else
            {
                _S1637 = false;
            }
            if(_S1637)
            {
                straight_0 = (_S1486.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1638 = _S1721;
            }
            else
            {
                _S1638 = false;
            }
            if(_S1638)
            {
                _S1639 = b_10 == 1U;
            }
            else
            {
                _S1639 = false;
            }
            if(_S1639)
            {
                _S1640 = (_S1487.x) == (_S1487.y);
            }
            else
            {
                _S1640 = false;
            }
            BSDFMaterial _S1722 = _S1486;
            bool _S1723 = isTranslucent_0(&_S1722);
            if(_S1723)
            {
                _S1641 = _S1717;
            }
            else
            {
                _S1641 = false;
            }
            if(_S1641)
            {
                _S1642 = (dot_0(throughput_9, surface_13.geometry_n)) < 0.0f;
            }
            else
            {
                _S1642 = false;
            }
            if(nee_0)
            {
                _S1643 = !_S1636;
            }
            else
            {
                _S1643 = false;
            }
            if(_S1643)
            {
                _S1644 = !wrong_side_0;
            }
            else
            {
                _S1644 = false;
            }
            if(_S1644)
            {
                float _S1724 = (&lobe_5)->pdf;
                float3  _S1725 = (&ray_2)->origin;
                float3  _S1726 = _slang_select(_S1497, _S1274,_S1463.smooth_n);
                float3  _S1727 = (&ray_2)->origin;
                FKSurface _S1728 = surface_13;
                float3  _S1729 = - _S1463.smooth_n;
                float3  _S1730 = _slang_select(_S1642, _S1729,_S1463.smooth_n);
                NEEVertex _S1731 = NEEVertex_x24init_0(false, _S1724, _S1725, _S1726, _S1727 + make_float3 (_S1728.geometry_offset) * _S1730);
                nee_vertex_0 = _S1731;
            }
            else
            {
                if(_S1492)
                {
                    _S1645 = true;
                }
                else
                {
                    bool _S1732 = b_10 != 1U;
                    if(_S1732)
                    {
                        _S1645 = true;
                    }
                    else
                    {
                        _S1645 = (_S1487.x) != (_S1487.y);
                    }
                }
                if(_S1645)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1733 = withinInverseFootprint((&lobe_5)->pdf, _S1635, (&prev_0)->cos, (&hit_4)->distance, threshold_2);
            bool _S1734 = roughLobe((&lobe_5)->pdf, _S1635, _S1486.roughness);
            if(_S1529)
            {
                bool _S1735 = !_S1733;
                if(_S1735)
                {
                    return _S1275;
                }
                bool _S1736 = _S1280 != 1U;
                if(_S1736)
                {
                    _S1645 = _S1280 != 2U;
                }
                else
                {
                    _S1645 = false;
                }
                if(_S1645)
                {
                    float _S1737 = (&lobe_5)->pdf;
                    float _S1738 = _slang_select(nee_0, _S1737,0.0f);
                    float _S1739 = escapeWeight_0(_S1738, _S1653);
                    if(_S1537)
                    {
                        passes_0 = _S1286;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1740 = _slang_select(passes_0, _S1739,1.0f);
                    return Shift_x24init_0(throughput_7 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_8->radiance * make_float3 (_S1740) / make_float3 (r_8->jac), density_4 * (&lobe_5)->pdf / r_8->jac);
                }
                float3  _S1741 = throughput_7 * make_float3 ((&lobe_5)->pdf);
                float _S1742 = density_4 * (&lobe_5)->pdf;
                throughput_10 = _S1741;
                density_6 = _S1742;
            }
            else
            {
                throughput_10 = throughput_7;
                density_6 = density_4;
            }
            uint _S1743 = (fcptLayers((hit_4)));
            bool _S1744 = b_10 == 1U;
            bool _S1745 = passesLayer_0(_S1743, _S1744, passes_0);
            if(viewed_1)
            {
                _S1645 = _S1745;
            }
            else
            {
                _S1645 = false;
            }
            if(_S1645)
            {
                return _S1275;
            }
            if(replay_2)
            {
                _S1646 = b_7 <= _S1290;
            }
            else
            {
                _S1646 = false;
            }
            if(_S1646)
            {
                _S1647 = _S1462;
            }
            else
            {
                _S1647 = false;
            }
            if(_S1647)
            {
                _S1648 = _S1733;
            }
            else
            {
                _S1648 = false;
            }
            if(_S1648)
            {
                _S1649 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1649 = !_S1734;
                }
                else
                {
                    _S1649 = false;
                }
            }
            if(_S1649)
            {
                return _S1275;
            }
            if(viewed_1)
            {
                float3  _S1746 = throughput_10 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1747 = (&lobe_5)->pdf;
                throughput_11 = _S1746;
                sky_pdf_2 = _S1747;
            }
            else
            {
                float3  _S1748 = throughput_10 * max_0((&lobe_5)->throughput, _S1274);
                throughput_11 = _S1748;
                sky_pdf_2 = density_6;
            }
            bool _S1749;
            if(_S1501)
            {
                _S1749 = !_S1516;
            }
            else
            {
                _S1749 = false;
            }
            bool _S1750;
            if(_S1749)
            {
                _S1750 = _S1462;
            }
            else
            {
                _S1750 = false;
            }
            bool _S1751;
            if(_S1750)
            {
                _S1751 = _S1733;
            }
            else
            {
                _S1751 = false;
            }
            if(_S1751)
            {
                chain_0 = here_0;
                uint _S1752 = insertBits_0((&chain_0)->path, b_10, 18U, 3U);
                uint _S1753 = _slang_select(nee_0, 1U,0U);
                uint _S1754 = insertBits_0(_S1752, _S1753, 21U, 1U);
                (&chain_0)->path = _S1754;
                float _S1755 = (&chain_0)->jac * (&lobe_5)->pdf;
                (&chain_0)->jac = _S1755;
                (&chain_0)->dir = throughput_9;
                chain_throughput_1 = throughput_11;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1756 = surface_13;
            Vertex _S1757 = Vertex_x24init_0(_S1734, b_10, (&lobe_5)->pdf, (F32_abs((dot_0(surface_13.geometry_n, throughput_9)))), is_inside_8);
            prev_0 = _S1757;
            float _S1758 = (&lobe_5)->pdf;
            bool _S1759;
            if(_S1744)
            {
                _S1759 = (_S1487.x) == (_S1487.y);
            }
            else
            {
                _S1759 = false;
            }
            float sky_pdf_3 = _slang_select(_S1759, sky_pdf_0,_S1758);
            float _S1760 = _slang_select(_S1492, 0.0f,sky_pdf_3);
            float _S1761 = widened_0(spread_2, (&lobe_5)->pdf, _S1636);
            bool _S1762;
            if(refracted_4)
            {
                _S1762 = !_S1642;
            }
            else
            {
                _S1762 = false;
            }
            bool is_inside_9;
            if(_S1762)
            {
                bool _S1763 = !is_inside_8;
                is_inside_9 = _S1763;
            }
            else
            {
                is_inside_9 = is_inside_8;
            }
            FKSurface _S1764 = surface_13;
            bool _S1765 = boundsVolume_0(&_S1764);
            bool _S1766;
            if(_S1765)
            {
                _S1766 = !_S1745;
            }
            else
            {
                _S1766 = false;
            }
            if(_S1766)
            {
                FKSurface faced_2 = surface_13;
                float3  _S1767 = - _S1756.geometry_n;
                float3  _S1768 = _slang_select(turned_1, _S1767,_S1756.geometry_n);
                (&faced_2)->geometry_n = _S1768;
                FKMedium _S1769 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1770 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1771 = faced_2;
                FKMedium _S1772 = _S1769;
                FKMedium _S1773 = _S1770;
                MediumSides _S1774 = mediumSides_0(&_S1771, &_S1772, filling_2, (&ray_2)->unit_direction, &_S1773);
                bool _S1775 = leavesInFront_0((&faced_2)->geometry_n, throughput_9, _S1756.geometry_n);
                float3  _S1776 = _slang_select(_S1775, _S1774.front.scatter,_S1774.behind.scatter);
                scatter_in_0 = _S1776;
                float3  _S1777 = scatter_in_0;
                float _S1778 = upsample(scatter_in_0, wavelength_9);
                float3  _S1779 = make_float3 (_S1778);
                float3  _S1780 = _slang_select(_S1524, _S1779,_S1777);
                scatter_in_0 = _S1780;
                float3  _S1781 = _slang_select(_S1775, _S1774.front.extinction,_S1774.behind.extinction);
                extinction_in_0 = _S1781;
                float3  _S1782 = extinction_in_0;
                float _S1783 = upsample(extinction_in_0, wavelength_9);
                float3  _S1784 = make_float3 (_S1783);
                float3  _S1785 = _slang_select(_S1524, _S1784,_S1782);
                extinction_in_0 = _S1785;
                float _S1786 = _slang_select(_S1775, _S1774.front.g,_S1774.behind.g);
                g_in_0 = _S1786;
                uint _S1787 = _S1774.fillings.x;
                uint _S1788 = _S1774.fillings.y;
                uint _S1789 = _slang_select(_S1775, _S1788,_S1787);
                bool _S1790 = (fcptVaryingUsed());
                uint _S1791 = _slang_select(_S1790, _S1789,4294967295U);
                filling_2 = _S1791;
            }
            (&ray_2)->unit_direction = throughput_9;
            bool _S1792 = !_S1745;
            if(_S1792)
            {
                FKSurface _S1793 = surface_13;
                float _S1794 = _slang_select(straight_0, 0.0f,_S1793.geometry_offset);
                float3  _S1795 = - _S1463.smooth_n;
                bool _S1796 = is_inside_9 != _S1642;
                float3  _S1797 = _slang_select(_S1796, _S1795,_S1463.smooth_n);
                float3  _S1798 = (&ray_2)->origin + make_float3 (_S1794) * _S1797;
                (&ray_2)->origin = _S1798;
            }
            throughput_10 = throughput_11;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1745;
            viewed_1 = _S1640;
            sky_pdf_2 = _S1760;
            spread_5 = _S1761;
            reconnection_0 = reconnection_1;
            is_inside_7 = is_inside_9;
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
            is_inside_7 = is_inside_8;
        }
        float density_7;
        if(_S1501)
        {
            if(_S1425)
            {
                float3  _S1799 = pathColor(throughput_10 * emission_1, spectral_weight_0, wavelength_9);
                Reservoir candidate_8 = chain_0;
                uint _S1800 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1801 = _S1800 == 1U;
                if(_S1801)
                {
                    float3  _S1802 = safeDivide(_S1799, chain_throughput_0);
                    (&candidate_8)->radiance = _S1802;
                }
                Reservoir _S1803 = withEnd(candidate_8, 2U, b_7, _S1799);
                offer(sel_7, _S1803, _S1799 * make_float3 (scale_3) / make_float3 (density_6));
            }
            if(_S1425)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1804 = survivalProbability(abs_0(throughput_10), density_6);
                density_7 = _S1804;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1805 = stream(_S1302, b_7 + 128U);
            Random _S1806 = pcg(_S1805);
            bool _S1807 = density_7 < (_S1806.value);
            if(_S1807)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1808 = (fcptMaxBounces());
                wrong_side_0 = b_7 >= _S1808;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1809 = density_6 * density_7;
            density_7 = _S1809;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1810 = layer_0 ^ 1U;
        uint _S1811 = _slang_select(passes_0, _S1810,0U);
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
            uint _S1812 = b_10 + 1U;
            b_7 = _S1812;
            layer_0 = _S1811;
            continue;
        }
        FKRay _S1813 = ray_2;
        float _S1814 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
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
            wrong_side_0 = _S1279 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1815 = _slang_select(wrong_side_0, _S1814,4.294967296e+09f);
        bool _S1816 = !_S1492;
        if(straight_0)
        {
            _S1575 = true;
        }
        else
        {
            _S1575 = _S1492;
        }
        FKHit _S1817;
        if(_S1575)
        {
            _S1817 = hit_4;
        }
        else
        {
            _S1817 = _S1547;
        }
        FKHit _S1818 = (fcptTraverseInstanceBVH((_S1813), (_S1433), (_S1815), (_S1816), (_S1817), (viewed_1)));
        hit_4 = _S1818;
        if(replay_2)
        {
            _S1576 = _S1530;
        }
        else
        {
            _S1576 = false;
        }
        if(_S1576)
        {
            _S1635 = _S1279 == 1U;
        }
        else
        {
            _S1635 = false;
        }
        if(_S1635)
        {
            _S1636 = ((&hit_4)->instance_index) == (_S1291.instance_index);
        }
        else
        {
            _S1636 = false;
        }
        if(_S1636)
        {
            _S1637 = ((&hit_4)->triangle_index) == (_S1291.triangle_index);
        }
        else
        {
            _S1637 = false;
        }
        if(_S1637)
        {
            (&hit_4)->uv = _S1291.uv;
            float _S1819 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S1819;
        }
        if(replay_2)
        {
            _S1638 = _S1530;
        }
        else
        {
            _S1638 = false;
        }
        if(_S1638)
        {
            _S1639 = _S1279 == 3U;
        }
        else
        {
            _S1639 = false;
        }
        if(_S1639)
        {
            _S1640 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1640 = false;
        }
        if(_S1640)
        {
            return _S1275;
        }
        Reservoir _S1820 = chain_0;
        uint _S1821 = filling_2;
        for(;;)
        {
            bool _S1822 = (fcptVaryingUsed());
            if(_S1822)
            {
                _S1641 = _S1821 != 4294967295U;
            }
            else
            {
                _S1641 = false;
            }
            float _S1823;
            if(_S1641)
            {
                float _S1824 = (fcptMajorant((_S1821)));
                _S1823 = _S1824;
            }
            else
            {
                _S1823 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_2)
            {
                _S1642 = _S1530;
            }
            else
            {
                _S1642 = false;
            }
            if(_S1642)
            {
                _S1643 = _S1279 == 1U;
            }
            else
            {
                _S1643 = false;
            }
            if(_S1643)
            {
                _S1644 = _S1823 > 0.0f;
            }
            else
            {
                _S1644 = false;
            }
            if(_S1644)
            {
                ended_0 = _S1275;
                sky_pdf_1 = sky_pdf_2;
                spread_3 = spread_5;
                width_4 = width_3;
                density_3 = density_7;
                throughput_11 = throughput_10;
                b_10 = b_7;
                _S1645 = true;
                break;
            }
            bool _S1825 = (&prev_0)->rough;
            if(_S1825)
            {
                _S1645 = !(_S1823 > 0.0f);
            }
            else
            {
                _S1645 = false;
            }
            (&prev_0)->rough = _S1645;
            uint _S1826 = b_7 + 320U;
            bool _S1827 = b_7 == 4294967295U;
            uint _S1828 = _slang_select(_S1827, 384U,_S1826);
            uint _S1829 = stream(_S1302, _S1828);
            uint tracking_1 = _S1829;
            weight_2 = throughput_3;
            glowed_0 = _S1274;
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
                    _S1273 = int(2);
                    break;
                }
                uint _S1830 = b_10 + 320U;
                bool _S1831 = b_10 == 4294967295U;
                uint _S1832 = _slang_select(_S1831, 384U,_S1830);
                uint _S1833 = stream(_S1302, _S1832);
                Random _S1834 = pcg(_S1833);
                float _S1835 = freeFlight_0(_S1834.value, _S1823);
                if(_S1641)
                {
                    float3  _S1836 = (&ray_2)->origin;
                    float3  _S1837 = (&ray_2)->unit_direction;
                    float _S1838 = (&hit_4)->distance;
                    uint _S1839 = _slang_select(_S1831, 0U,b_10);
                    uint _S1840 = (&prev_0)->lobe;
                    uint _S1841 = _slang_select(_S1831, 3U,_S1840);
                    float _S1842 = (fcptTrackMedium((_S1821), (_S1836), (_S1837), (_S1838), (&tracking_1), (&weight_2), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1839), (_S1841), (_S1831)));
                    spread_4 = _S1842;
                }
                else
                {
                    spread_4 = _S1835;
                }
                bool _S1843 = !(spread_4 < ((&hit_4)->distance));
                if(_S1843)
                {
                    _S1273 = int(2);
                    break;
                }
                if(_S1641)
                {
                    _S1646 = _S1501;
                }
                else
                {
                    _S1646 = false;
                }
                if(_S1646)
                {
                    float3  _S1844 = pathColor(throughput_11 * glowed_0, spectral_weight_0, wavelength_9);
                    float3  _S1845 = _S1844 / make_float3 (density_3);
                    float3  _S1846 = sel_7->glow + _S1845;
                    sel_7->glow = _S1846;
                }
                else
                {
                }
                glowed_0 = _S1274;
                uint b_11 = b_10 + 1U;
                float3  _S1847 = (&ray_2)->origin + make_float3 (spread_4) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1847;
                float3  _S1848 = flightWeight_0(scatter_in_0, extinction_in_0, _S1823, spread_4, true);
                float3  _S1849 = weight_2;
                float _S1850 = upsample(weight_2, wavelength_9);
                float3  _S1851 = make_float3 (_S1850);
                float3  _S1852 = _slang_select(_S1524, _S1851,_S1849);
                float3  _S1853 = _slang_select(_S1641, _S1852,_S1848);
                float3  throughput_12 = throughput_11 * _S1853;
                uint _S1854 = stream(_S1302, b_11 + 320U);
                tracking_1 = _S1854;
                weight_2 = throughput_3;
                float width_7 = width_4 + spread_3 * spread_4;
                float _S1855 = spread_3 + 3.14159274101257324f;
                bool _S1856 = scatterSampled_0(replay_2, b_11, _S1290, _S1641);
                TreeSample light_4;
                if(_S1856)
                {
                    float3  _S1857 = (&ray_2)->origin;
                    float3  _S1858 = (&ray_2)->unit_direction;
                    float3  _S1859 = (&ray_2)->unit_direction;
                    uint _S1860 = stream(_S1302, b_11 + 64U);
                    float3  _S1861 = extinction_in_0;
                    float3  _S1862 = extinction_in_0;
                    uint2  _S1863 = make_uint2 (_S1821);
                    float3  _S1864 = (&ray_2)->unit_direction;
                    uint _S1865 = arrivalLobe_0(b_11, (&prev_0)->lobe);
                    FKHit _S1866 = _S1547;
                    ShadowContext _S1867 = ShadowContext_x24init_0(_S1861, _S1862, _S1863, _S1864, b_11, _S1865, false, spread_4, width_7, &_S1866, false);
                    ShadowContext _S1868 = _S1867;
                    TreeSample _S1869 = sampleLightTree_0(_S1857, _S1858, _S1859, 0.0f, true, _S1860, &_S1868);
                    light_4 = _S1869;
                }
                else
                {
                    light_4 = _S1544;
                }
                float _S1870 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1871 = (fcptMaxBounces());
                bool _S1872 = b_11 < _S1871;
                if(_S1872)
                {
                    _S1647 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1647 = false;
                }
                float _S1873 = _slang_select(_S1647, _S1870,0.0f);
                float3  _S1874 = throughput_12 * light_4.radiance;
                float _S1875 = powerHeuristic(light_4.density, _S1873);
                float3  _S1876 = pathColor(_S1874 * make_float3 (_S1870 * _S1875), spectral_weight_0, wavelength_9);
                float3  _S1877 = _slang_select(_S1856, _S1876,_S1274);
                if(replay_2)
                {
                    _S1648 = b_11 == _S1290;
                }
                else
                {
                    _S1648 = false;
                }
                if(_S1648)
                {
                    bool _S1878 = _S1279 == 2U;
                    if(_S1878)
                    {
                        float _S1879 = resamplingTarget(_S1877);
                        _S1649 = _S1879 > 0.0f;
                    }
                    else
                    {
                        _S1649 = false;
                    }
                    if(_S1649)
                    {
                        Shift _S1880 = Shift_x24init_0(_S1877, 1.0f);
                        _S1273 = int(1);
                        ended_0 = _S1880;
                        spread_4 = _S1855;
                        width_5 = width_7;
                        throughput_9 = throughput_12;
                        b_8 = b_11;
                        break;
                    }
                    _S1273 = int(1);
                    ended_0 = _S1275;
                    spread_4 = _S1855;
                    width_5 = width_7;
                    throughput_9 = throughput_12;
                    b_8 = b_11;
                    break;
                }
                if(_S1501)
                {
                    Reservoir candidate_9 = _S1820;
                    uint _S1881 = extractBits_0(_S1820.path, 24U, 8U);
                    uint _S1882 = insertBits_0(0U, _S1881, 24U, 8U);
                    uint _S1883 = extractBits_0(_S1820.path, 10U, 2U);
                    bool _S1884 = _S1883 == 1U;
                    if(_S1884)
                    {
                        float3  _S1885 = safeDivide(_S1877, chain_throughput_0);
                        (&candidate_9)->radiance = _S1885;
                    }
                    else
                    {
                        uint _S1886 = insertBits_0(_S1882, b_11 + 1U, 5U, 5U);
                        uint _S1887 = insertBits_0(_S1886, 2U, 10U, 2U);
                        (&candidate_9)->path = _S1887;
                    }
                    Reservoir _S1888 = withEnd(candidate_9, 0U, b_11, _S1877);
                    offer(sel_7, _S1888, _S1877 * make_float3 (scale_3) / make_float3 (density_3));
                    float _S1889 = survivalProbability(abs_0(throughput_12), density_3);
                    uint _S1890 = stream(_S1302, b_11 + 128U);
                    Random _S1891 = pcg(_S1890);
                    bool _S1892 = _S1889 < (_S1891.value);
                    if(_S1892)
                    {
                        _S1649 = true;
                    }
                    else
                    {
                        uint _S1893 = (fcptMaxBounces());
                        _S1649 = b_11 >= _S1893;
                    }
                    if(_S1649)
                    {
                        _S1273 = int(1);
                        ended_0 = _S1275;
                        spread_4 = _S1855;
                        width_5 = width_7;
                        throughput_9 = throughput_12;
                        b_8 = b_11;
                        break;
                    }
                    float _S1894 = density_3 * _S1889;
                    density_3 = _S1894;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1895 = stream(_S1302, b_11);
                float3  _S1896 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1895, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1896;
                NEEVertex _S1897 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1274, (&ray_2)->origin);
                nee_vertex_0 = _S1897;
                Vertex _S1898 = scatteredVertex_0(is_inside_7);
                prev_0 = _S1898;
                float _S1899 = (&prev_0)->pdf;
                FKRay _S1900 = ray_2;
                FKHit _S1901 = (fcptTraverseInstanceBVH((_S1900), (true), (4.294967296e+09f), (false), (_S1547), (false)));
                hit_4 = _S1901;
                b_10 = b_11;
                throughput_11 = throughput_12;
                spread_3 = _S1855;
                width_4 = width_7;
                sky_pdf_1 = _S1899;
            }
            if(_S1273 != int(2))
            {
                spread_3 = spread_4;
                width_4 = width_5;
                throughput_11 = throughput_9;
                b_10 = b_8;
                _S1645 = true;
                break;
            }
            ended_0 = _S1275;
            _S1645 = false;
            break;
        }
        if(_S1645)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1646 = b_10 == b_7;
        }
        else
        {
            _S1646 = false;
        }
        bool _S1902 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S1902)
        {
            bool _S1903 = !(&nee_vertex_0)->none;
            float _S1904 = _slang_select(_S1903, sky_pdf_1,0.0f);
            float _S1905 = escapeWeight_0(_S1904, (&ray_2)->unit_direction);
            float3  _S1906 = environment_0((&ray_2)->unit_direction, b_10, (&prev_0)->lobe);
            float3  _S1907 = pathColor(throughput_11 * _S1906, spectral_weight_0, wavelength_9);
            if(replay_2)
            {
                bool _S1908 = b_10 == _S1290;
                if(_S1908)
                {
                    passes_0 = _S1279 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1907 * make_float3 (_S1905) / make_float3 (r_8->jac), density_3 / r_8->jac);
                }
                if(_S1289)
                {
                    passes_0 = _S1286;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_10 == _S1277;
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
                    return Shift_x24init_0(_S1907 * make_float3 (_S1905), 1.0f);
                }
                return _S1275;
            }
            Reservoir candidate_10 = chain_0;
            uint _S1909 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1910 = _S1909 == 1U;
            if(_S1910)
            {
                uint _S1911 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1912 = _S1911 == b_10;
                float _S1913 = _slang_select(_S1912, 1.0f,_S1905);
                float3  _S1914 = safeDivide(_S1907 * make_float3 (_S1913), chain_throughput_0);
                (&candidate_10)->radiance = _S1914;
            }
            else
            {
                bool _S1915 = (&prev_0)->rough;
                if(_S1915)
                {
                    uint _S1916 = insertBits_0(_S1304, b_10 + 1U, 5U, 5U);
                    uint _S1917 = insertBits_0(_S1916, 3U, 10U, 2U);
                    uint _S1918 = insertBits_0(_S1917, (&prev_0)->lobe, 15U, 3U);
                    bool _S1919 = (&prev_0)->inside;
                    uint _S1920 = _slang_select(_S1919, 1U,0U);
                    uint _S1921 = insertBits_0(_S1918, _S1920, 22U, 1U);
                    (&candidate_10)->path = _S1921;
                    (&candidate_10)->jac = (&prev_0)->pdf;
                    (&candidate_10)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1922 = _S1907 * make_float3 (_S1905);
            Reservoir _S1923 = withEnd(candidate_10, 3U, b_10, _S1922);
            offer(sel_7, _S1923, _S1922 * make_float3 (scale_3) / make_float3 (density_3));
            break;
        }
        float3  _S1924 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1924;
        bool _S1925 = (fcptVaryingUsed());
        if(_S1925)
        {
            _S1647 = filling_2 != 4294967295U;
        }
        else
        {
            _S1647 = false;
        }
        if(_S1647)
        {
            if(_S1501)
            {
                float3  _S1926 = pathColor(throughput_11 * glowed_0, spectral_weight_0, wavelength_9);
                float3  _S1927 = _S1926 / make_float3 (density_3);
                float3  _S1928 = sel_7->glow + _S1927;
                sel_7->glow = _S1928;
            }
            float3  _S1929 = throughput_11 * weight_2;
            throughput_9 = _S1929;
        }
        else
        {
            float3  _S1930 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S1931 = throughput_11 * _S1930;
            throughput_9 = _S1931;
        }
        float _S1932 = width_4 + spread_3 * (&hit_4)->distance;
        viewed_0 = _S1646;
        width_3 = _S1932;
        throughput_2 = throughput_9;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_2 = spread_3;
        uint _S1812 = b_10 + 1U;
        b_7 = _S1812;
        layer_0 = _S1811;
    }
    return _S1275;
}

static __device__ Shift shift_0(Domain * dom_8, Reservoir * r_9)
{
    Selection _S1933 = (Selection{});
    Selection sel_8 = _S1933;
    bool _S1934 = (r_9->w) <= 0.0f;
    if(_S1934)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S1935 = walk_0(dom_8, r_9, true, 0.0f, &sel_8);
    return _S1935;
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

__device__ Random normal_distribution(uint state_4)
{
    Random _S1936 = pcg(state_4);
    Random _S1937 = pcg(_S1936.state);
    float _S1938 = 6.28318548202514648f * _S1936.value;
    float _S1939 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S1937.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1937.state, _S1939 * (F32_cos((_S1938))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_5, float3  value_2)
{
    RandomSphere _S1940;
    (&_S1940)->state = state_5;
    (&_S1940)->value = value_2;
    return _S1940;
}

__device__ RandomSphere random_sphere(uint state_6)
{
    Random _S1941 = normal_distribution(state_6);
    Random _S1942 = normal_distribution(_S1941.state);
    Random _S1943 = normal_distribution(_S1942.state);
    float3  _S1944 = make_float3 (_S1941.value, _S1942.value, _S1943.value);
    float3  _S1945 = ((((_S1944)) * make_float3(rnorm3df(((_S1944)).x, ((_S1944)).y, ((_S1944)).z))));
    return RandomSphere_x24init_0(_S1943.state, _S1945);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_11)
{
    float3  _S1946 = p1_0 - p0_0;
    float3  _S1947 = p2_0 - p0_0;
    float2  _S1948 = uv1_0 - uv0_0;
    float2  _S1949 = uv2_0 - uv0_0;
    float _S1950 = _S1948.x;
    float _S1951 = _S1949.y;
    float _S1952 = _S1948.y;
    float _S1953 = _S1949.x;
    float _S1954 = _S1950 * _S1951 - _S1952 * _S1953;
    float _S1955 = 1.0f / _S1954;
    float3  t_24 = (_S1946 * make_float3 (_S1951) - _S1947 * make_float3 (_S1952)) * make_float3 (_S1955);
    float3  _S1956 = (_S1947 * make_float3 (_S1950) - _S1946 * make_float3 (_S1953)) * make_float3 (_S1955);
    float3  _S1957 = t_24 - n_11 * make_float3 (dot_0(n_11, t_24));
    float3  t_25 = ((((_S1957)) * make_float3(rnorm3df(((_S1957)).x, ((_S1957)).y, ((_S1957)).z))));
    bool _S1958 = (dot_0(cross_0(n_11, t_25), _S1956)) > 0.0f;
    float3  t_26;
    if(_S1958)
    {
        float3  _S1959 = negate_0(t_25);
        t_26 = _S1959;
    }
    else
    {
        t_26 = t_25;
    }
    float3  _S1960 = cross_0(n_11, t_26);
    return makeMatrix<float, 3, 3> (t_26, _S1960, n_11);
}

__device__ float3  tangentToWorldNormalMap(float3  v_10, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_10, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_5, float3  uvw_0, float3  position_0)
{
    float3  _S1961 = t1_0 - t0_0;
    float3  _S1962 = t2_2 - t0_0;
    float3  _S1963 = t2_2 - t1_0;
    float _S1964 = (F32_min((length_0(_S1961)), ((F32_min((length_0(_S1962)), (length_0(_S1963)))))));
    float3  _S1965 = make_float3 (distance_1(position_0, t0_0), distance_1(position_0, t1_0), distance_1(position_0, t2_2));
    float3  _S1966 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1967 = dot_0(geometry_n_5, _S1966);
    float3  _S1968 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1969 = dot_0(geometry_n_5, _S1968);
    float3  _S1970 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1971 = acos_0(abs_0(make_float3 (_S1967, _S1969, dot_0(geometry_n_5, _S1970))));
    float3  _S1972 = clamp_2(tan_0(_S1971), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S1965 * _S1972, uvw_0), 0.0f, _S1964 * 0.125f);
}

__device__ float3  straightThrough(float3  dir_16, float3  n_12, BSDFMaterial material_26)
{
    float3  _S1973 = negate_0(dir_16);
    float _S1974 = sign_0(dot_0(n_12, _S1973));
    float3  _S1975 = n_12 * make_float3 (_S1974);
    AnisotropicFrame _S1976 = anisotropicFrame(material_26, _S1975);
    bool _S1977 = (_S1976.alphas.x) > 0.0f;
    if(_S1977)
    {
        float _S1978 = material_26.transmission * (1.0f - material_26.metallic);
        float3  _S1979 = negate_0(_S1975);
        float3  _S1980 = anisotropicLocal(dir_16, _S1976.tangent, _S1979);
        float _S1981 = anisotropicG1(_S1980, _S1976.alphas);
        return make_float3 (_S1978 * _S1981) * material_26.albedo;
    }
    float _S1982 = material_26.transmission * (1.0f - material_26.metallic);
    float _S1983 = material_26.roughness;
    float _S1984 = smithG1(_S1983 * _S1983, (F32_abs((dot_0(n_12, dir_16)))));
    return make_float3 (_S1982 * _S1984) * material_26.albedo;
}

__device__ float hairRow(float3  in_dir_11, float3  t_27, float3  out_dir_3, uint p_14, float w_19, float alpha_10, uint nt_0)
{
    uint _S1985 = p_14 % 4U;
    float _S1986 = w_19 * HAIR_WIDTHS_0[_S1985];
    float _S1987 = (F32_asin((clamp_1(dot_0(out_dir_3, t_27), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_11, t_27), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1985] * alpha_10;
    return ((F32_asinh((_S1987 / _S1986))) / (F32_asinh((3.14159274101257324f / _S1986))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_12, float3  t_28, float3  out_dir_4, uint np_0)
{
    float3  _S1988 = worldToTangent(out_dir_4, t_28);
    float3  _S1989 = worldToTangent(in_dir_12, t_28);
    return (F32_frac((((F32_atan2((_S1988.z), (_S1988.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1989.z), (1.17549435082228751e-38f - _S1989.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_13, float3  t_29, uint p_15, float row_0, float column_0, float w_20, float alpha_11, uint nt_1, uint np_1)
{
    float3  _S1990 = worldToTangent(in_dir_13, t_29);
    uint _S1991 = p_15 % 4U;
    float _S1992 = w_20 * HAIR_WIDTHS_0[_S1991];
    float _S1993 = (F32_asin((clamp_1(dot_0(in_dir_13, t_29), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1991] * alpha_11 + _S1992 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1992))))));
    float _S1994 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1990.z), (1.17549435082228751e-38f - _S1990.x)));
    float _S1995 = (F32_cos((_S1993)));
    float3  _S1996 = tangentToWorld(make_float3 (_S1995 * (F32_cos((_S1994))), (F32_sin((_S1993))), _S1995 * (F32_sin((_S1994)))), t_29);
    return _S1996;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_13, BSDFMaterial material_27, float coverage_1)
{
    float3  _S1997;
    if((material_27.ior) == 1.0f)
    {
        float3  _S1998 = straightThrough(toward_1, n_13, material_27);
        _S1997 = _S1998;
    }
    else
    {
        _S1997 = make_float3 (0.0f);
    }
    return _S1997 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_9, Reservoir r_10, bool replay_3, float scale_4, Selection * sel_9)
{
    Domain _S1999 = dom_9;
    Reservoir _S2000 = r_10;
    Shift _S2001 = walk_0(&_S1999, &_S2000, replay_3, scale_4, sel_9);
    return _S2001;
}

__device__ Shift shift_hook(Domain dom_10, Reservoir r_11)
{
    Domain _S2002 = dom_10;
    Reservoir _S2003 = r_11;
    Shift _S2004 = shift_0(&_S2002, &_S2003);
    return _S2004;
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
