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
        int2  _S157 = make_int2 (int(-1));
        bool _S158 = previousValid_0(p_8);
        int2  _S159 = _slang_select(_S158, p_8,_S157);
        return _S159;
    }
    float3  _S160 = make_float3 (0.0f);
    FKHit _S161 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S162 = Domain_x24init_0(_S160, _S160, &_S161, 0.0f, 0.0f);
    Domain dom_3 = _S162;
    uint2  _S163 = (fcptRenderSize());
    int2  _S164 = make_int2 ((int)_S163.x, (int)_S163.y);
    bool _S165 = any_0(p_8 >= _S164);
    bool _S166;
    if(_S165)
    {
        _S166 = true;
    }
    else
    {
        bool _S167 = (fcptStoredDomainInitial((p_8), (seed_2), (&dom_3)));
        _S166 = !_S167;
    }
    if(_S166)
    {
        return make_int2 (int(-1));
    }
    Domain _S168 = dom_3;
    int2  _S169 = temporalNeighbor_0(p_8, &_S168, seed_2);
    return _S169;
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
    FKRay _S170;
    (&_S170)->origin = origin_0;
    (&_S170)->unit_direction = unit_direction_0;
    return _S170;
}

static __device__ float3  skyRadiance_0(float3  origin_1, FKSurface * surface_0, bool is_inside_1, float3  dir_1, ShadowContext * context_0, uint random_state_0)
{
    bool _S171 = wrongSide_0(is_inside_1, false, dir_1, surface_0->geometry_n);
    bool _S172 = is_inside_1 != _S171;
    float _S173 = surface_0->geometry_offset;
    float3  _S174 = surface_0->smooth_n;
    float3  _S175 = - surface_0->smooth_n;
    float3  _S176 = _slang_select(_S172, _S175,_S174);
    FKRay _S177 = Ray_x24init_0(origin_1 + make_float3 (_S173) * _S176, dir_1);
    bool _S178 = (dot_0(context_0->side, dir_1)) > 0.0f;
    bool _S179 = (fcptWorldReadsPath());
    float3  _S180;
    if(_S179)
    {
        _S180 = make_float3 (1.0f);
    }
    else
    {
        float3  _S181 = (fcptEnvMapSample((dir_1), (0U), (3U)));
        _S180 = _S181;
    }
    float3  _S182 = context_0->extinction_behind;
    float3  _S183 = context_0->extinction_front;
    float3  _S184 = _slang_select(_S178, _S183,_S182);
    uint _S185 = context_0->fillings.x;
    uint _S186 = context_0->fillings.y;
    uint _S187 = _slang_select(_S178, _S186,_S185);
    uint _S188 = context_0->depth;
    uint _S189 = context_0->lobe;
    bool _S190 = context_0->surface;
    bool _S191;
    if(_S190)
    {
        _S191 = !context_0->fiber;
    }
    else
    {
        _S191 = false;
    }
    float _S192 = context_0->length;
    float _S193 = context_0->width;
    FKHit _S194 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    float3  _S195 = (fcptShadowTransmittanceIn((_S177), (4.294967296e+09f), (_S184), (_S187), (random_state_0), (_S188), (_S189), (_S191), (_S192), (_S193), (_S194), (_S194)));
    return _S180 * _S195;
}

static __device__ uint searchCDF_0(uint2  start_4, uint2  step_0, uint count_1, float u_0)
{
    uint _S196 = count_1 - 1U;
    uint low_0 = 0U;
    uint high_0 = _S196;
    for(;;)
    {
        if(low_0 < high_0)
        {
        }
        else
        {
            break;
        }
        uint _S197 = (low_0 + high_0) / 2U;
        float4  _S198 = (fcptEnvironmentCdf((start_4 + step_0 * make_uint2 (_S197))));
        bool _S199 = (_S198.x) > u_0;
        if(_S199)
        {
            high_0 = _S197;
        }
        else
        {
            uint _S200 = _S197 + 1U;
            low_0 = _S200;
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
    float3  _S201 = ((((light_dir_0)) * make_float3(rnorm3df(((light_dir_0)).x, ((light_dir_0)).y, ((light_dir_0)).z))));
    bool _S202 = (dot_0(smooth_n_0, _S201)) < 0.0f;
    if(_S202)
    {
        return make_float3 (0.0f);
    }
    float3  _S203 = make_float3 (geometry_offset_0) * smooth_n_0;
    float3  _S204 = origin_2 + _S203;
    FKRay _S205 = Ray_x24init_0(_S204, _S201);
    bool _S206 = (dot_0(context_1->side, light_dir_0 + _S203)) > 0.0f;
    float _S207 = shadowLength(light_dir_0);
    float3  _S208 = context_1->extinction_behind;
    float3  _S209 = context_1->extinction_front;
    float3  _S210 = _slang_select(_S206, _S209,_S208);
    uint _S211 = context_1->fillings.x;
    uint _S212 = context_1->fillings.y;
    uint _S213 = _slang_select(_S206, _S212,_S211);
    uint _S214 = context_1->depth;
    uint _S215 = context_1->lobe;
    bool _S216 = context_1->surface;
    bool _S217;
    if(_S216)
    {
        _S217 = !context_1->fiber;
    }
    else
    {
        _S217 = false;
    }
    float _S218 = context_1->length;
    float _S219 = context_1->width;
    FKHit _S220;
    if(context_1->fiber)
    {
        _S220 = context_1->own;
    }
    else
    {
        _S220 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    }
    float3  _S221 = (fcptShadowTransmittanceIn((_S205), (_S207), (_S210), (_S213), (random_state_1), (_S214), (_S215), (_S217), (_S218), (_S219), (_S220), (*light_0)));
    return _S221;
}

__device__ float sine(float c_0)
{
    return (F32_sqrt(((F32_max((1.0f - c_0 * c_0), (0.0f))))));
}

__device__ float cosSubClamped(float sin_a_0, float cos_a_0, float sin_b_0, float cos_b_0)
{
    float _S222 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    bool _S223 = cos_a_0 > cos_b_0;
    float _S224 = _slang_select(_S223, 1.0f,_S222);
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
    float _S240 = _S239 * node_0.cos_theta_o - _S231 * _S232;
    bool _S241 = _S231 > (node_0.cos_theta_o);
    float _S242 = _slang_select(_S241, 0.0f,_S240);
    float _S243 = cosSubClamped(_S242, _S238, _S236, _S235);
    bool _S244 = _S243 <= 0.0f;
    if(_S244)
    {
        return 0.0f;
    }
    float _S245 = - dot_0(_S228, normal_0);
    float _S246 = node_0.phi * _S243 / (F32_max((_S229), (length_0(_S226) / 2.0f)));
    float _S247 = sine(_S245);
    float _S248 = cosSubClamped(_S247, _S245, _S236, _S235);
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
        FKLight _S289 = (fcptLight((_S287.y)));
        float _S290 = sphereDensity(_S289.position, _S289.variance, start_5);
        return probability_1 * _S290;
    }
    uint _S291 = _S287.y;
    uint _S292 = (fcptTriangleOffset((_S291)));
    Matrix<float, 3, 3>  _S293 = (fcptWorldTriangle((_S291), (_S292 + _S287.z)));
    float _S294 = solidAngle(probability_1, cross_0(_S293.rows[int(1)] - _S293.rows[int(0)], _S293.rows[int(2)] - _S293.rows[int(0)]), light_point_0 - start_5);
    return _S294;
}

static __device__ float3  environment_0(float3  dir_2, uint depth_0, uint lobe_0)
{
    uint2  _S295 = (fcptEnvironmentMapSize());
    bool _S296 = all_0(_S295 > make_uint2 (1U));
    if(_S296)
    {
        float3  _S297 = (fcptEnvMapSample((dir_2), (depth_0), (lobe_0)));
        return _S297;
    }
    float3  _S298 = (fcptAmbient());
    return _S298;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S299 = (fcptEnvironmentCdfSize());
    bool _S300 = !all_0(_S299 > make_uint2 (1U));
    if(_S300)
    {
        return false;
    }
    uint2  _S301 = (fcptEnvironmentMapSize());
    return all_0(_S301 > make_uint2 (1U));
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
    uint2  _S302 = (fcptEnvironmentCdfSize());
    uint2  _S303 = _S302 - make_uint2 (1U, 0U);
    float2  _S304 = make_float2 ((F32_atan2((- dir_3.y), (dir_3.x))) / 6.28318548202514648f + 0.5f, (F32_acos((clamp_1(dir_3.z, -1.0f, 1.0f)))) / 3.14159274101257324f);
    float2  _S305 = make_float2 ((float)_S303.x, (float)_S303.y);
    float2  _S306 = _S304 * _S305;
    uint2  _S307 = make_uint2 ((uint)_S306.x, (uint)_S306.y);
    uint2  _S308 = min_0(_S307, _S303 - make_uint2 (1U));
    float4  _S309 = (fcptEnvironmentCdf((_S308)));
    float _S310 = _S309.y;
    uint _S311 = _S303.x;
    float4  _S312 = (fcptEnvironmentCdf((make_uint2 (_S311, _S308.y))));
    float _S313 = _S310 * _S312.y;
    return _S313 * float(_S311 * _S303.y) / (19.73921012878417969f * length_1(float2 {dir_3.x, dir_3.y}));
}

static __device__ float escapeWeight_0(float pdf_0, float3  dir_4)
{
    bool _S314 = pdf_0 <= 0.0f;
    bool _S315;
    if(_S314)
    {
        _S315 = true;
    }
    else
    {
        bool _S316 = environmentMapped_0();
        _S315 = !_S316;
    }
    if(_S315)
    {
        return 1.0f;
    }
    float _S317 = environmentPdf_0(dir_4);
    return pdf_0 / (pdf_0 + _S317);
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

__device__ uint2  noiseOffset(uint k_0)
{
    uint2  _S318 = make_uint2 (k_0 * 3242174889U, k_0 * 2447445414U) >> make_uint2 (16U);
    uint _S319 = (fkBlueNoiseSize());
    return (_S318 * make_uint2 (_S319)) >> make_uint2 (16U);
}

__device__ uint stream(uint seed_3, uint index_0)
{
    uint _S320 = hash(index_0);
    uint _S321 = hash(seed_3 ^ _S320);
    return _S321;
}

static __device__ Random Random_x24init_0(uint state_0, float value_0)
{
    Random _S322;
    (&_S322)->state = state_0;
    (&_S322)->value = value_0;
    return _S322;
}

__device__ Random pcg(uint state_1)
{
    uint _S323 = hash(state_1);
    float value_1 = float(_S323 >> int(8)) * 5.9604644775390625e-08f;
    return Random_x24init_0(_S323, value_1);
}

__device__ __noinline__ Random draw(uint address_0, uint variable_0)
{
    uint _S324 = address_0 >> 22U;
    uint _S325 = _S324 / 32U;
    uint2  _S326 = make_uint2 (address_0 & 2047U, (address_0 >> 11U) & 2047U);
    uint _S327 = variable_0 & 2147483647U;
    uint2  _S328 = noiseOffset(_S327);
    uint2  _S329 = _S326 + _S328;
    uint2  _S330 = noiseOffset(4096U + _S325);
    uint2  _S331 = _S329 + _S330;
    uint _S332 = (fkBlueNoiseSize());
    uint2  _S333 = _S331 & make_uint2 (_S332 - 1U);
    uint _S334 = (fkBlueNoise((_S333.x), (_S333.y), ((_S324 + ((_S325 * 2654435769U) >> 27U)) % 32U)));
    bool _S335 = (variable_0 & 2147483648U) != 0U;
    uint _S336 = stream(address_0, _S327);
    Random _S337 = pcg(_S336);
    uint _S338 = _S334 & 65535U;
    uint _S339 = _S334 >> 16U;
    uint _S340 = _slang_select(_S335, _S339,_S338);
    float _S341 = (float(_S340) + 0.5f) / 6.5536e+04f;
    Random _S342 = pcg(_S337.state);
    float _S343 = _slang_select(_S335, _S342.value,_S337.value);
    bool _S344 = _S334 == 4294967295U;
    float _S345 = _slang_select(_S344, _S343,_S341);
    return Random_x24init_0(address_0, _S345);
}

__device__ static const FixedArray<float, 243>  SPECTRAL_PRIMARIES_0 = { {
    0.028201999142766f, 9.99999997475242708e-07f, 0.97179698944091797f, 0.02820000052452087f, 0.0f, 0.97180002927780151f, 0.02819300070405006f, 0.0f, 0.97180700302124023f, 0.0281750001013279f, 0.0f, 0.9718250036239624f, 0.02813299931585789f, 0.0f, 0.97186702489852905f, 0.02804199978709221f, 0.0f, 0.9719579815864563f, 0.02786399982869625f, 0.0f, 0.97213602066040039f, 0.0275299996137619f, 0.0f, 0.9724699854850769f, 0.02692800015211105f, 0.0f, 0.97307199239730835f, 0.02592499926686287f, 0.0f, 0.97407501935958862f, 0.02444599941372871f, 0.0f, 0.97555398941040039f, 0.02258899994194508f, 0.0f, 0.97741097211837769f, 0.02068600058555603f, 0.0f, 0.97931402921676636f, 0.01939599961042404f, 0.0f, 0.98060399293899536f, 0.01972600072622299f, 0.0f, 0.9802740216255188f, 0.02305700071156025f, 0.0f, 0.97694301605224609f, 0.0282990001142025f, 0.00548999989405274f, 0.96621102094650269f, 0.02276800014078617f, 0.04560500010848045f, 0.93162697553634644f, 0.0118180001154542f, 0.11352799832820892f, 0.87465399503707886f, 0.00192399998195469f, 0.20037899911403656f, 0.79769700765609741f, 0.0f, 0.29692500829696655f, 0.70307499170303345f, 0.0f, 0.40064999461174011f, 0.5993499755859375f, 0.0f, 0.50742298364639282f, 0.49257698655128479f, 0.0f, 0.61289197206497192f, 0.38710799813270569f, 0.0f, 0.71311402320861816f, 0.28688600659370422f, 0.0f, 0.8042140007019043f, 0.1957859992980957f, 0.0f, 0.88220900297164917f, 0.11779099702835083f, 0.0f, 0.94313102960586548f, 0.05686900019645691f, 0.0f, 0.98336499929428101f, 0.01663500070571899f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.99855601787567139f, 0.00144400005228817f, 0.0f, 0.97892600297927856f, 0.02107400074601173f, 0.03028500080108643f, 0.92923498153686523f, 0.04047999903559685f, 0.10447199642658234f, 0.84615302085876465f, 0.04937500134110451f, 0.21104000508785248f, 0.73897498846054077f, 0.04998499900102615f, 0.33820000290870667f, 0.61719298362731934f, 0.04460699856281281f, 0.47420701384544373f, 0.49019300937652588f, 0.03559999912977219f, 0.60847699642181396f, 0.3664110004901886f, 0.02511199936270714f, 0.73185497522354126f, 0.25317299365997314f, 0.01497200038284063f, 0.83687901496887207f, 0.15642799437046051f, 0.00669299997389317f, 0.91802400350570679f, 0.08053100109100342f, 0.00144499994348735f, 0.97194302082061768f, 0.02805699966847897f, 0.0f, 0.99879997968673706f, 0.00120000005699694f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.99999898672103882f, 0.0f, 9.99999997475242708e-07f, 0.99999898672103882f, 0.0f, 9.99999997475242708e-07f, 0.99999898672103882f, 0.0f, 9.99999997475242708e-07f, 0.99999797344207764f, 9.99999997475242708e-07f, 9.99999997475242708e-07f, 0.99999797344207764f, 9.99999997475242708e-07f, 9.99999997475242708e-07f, 0.99999701976776123f, 9.99999997475242708e-07f, 1.99999999495048542e-06f, 0.99999499320983887f, 1.99999999495048542e-06f, 3.00000010611256585e-06f, 0.99999302625656128f, 1.99999999495048542e-06f, 4.99999987368937582e-06f, 0.99998897314071655f, 3.99999998990097083e-06f, 7.00000009601353668e-06f, 0.9999840259552002f, 6.00000021222513169e-06f, 0.00000999999974738f, 0.99997901916503906f, 0.0000079999999798f, 0.00001299999985349f, 0.99997401237487793f, 0.00000999999974738f, 0.0000159999999596f, 0.99997299909591675f, 0.00001200000042445f, 0.00001499999962107f, 0.99996697902679443f, 0.00001499999962107f, 0.00001800000063668f, 0.9999690055847168f, 0.00001499999962107f, 0.0000159999999596f, 0.9999619722366333f, 0.00001700000029814f, 0.00002099999983329f
} };
__device__ float upsample(float3  rgb_0, float wavelength_0)
{
    float _S346 = clamp_1((wavelength_0 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    uint _S347 = (U32_min((uint(_S346)), (79U)));
    uint _S348 = 3U * _S347;
    float3  _S349 = make_float3 (SPECTRAL_PRIMARIES_0[_S348], SPECTRAL_PRIMARIES_0[_S348 + 1U], SPECTRAL_PRIMARIES_0[_S348 + 2U]);
    float3  _S350 = make_float3 (SPECTRAL_PRIMARIES_0[_S348 + 3U], SPECTRAL_PRIMARIES_0[_S348 + 4U], SPECTRAL_PRIMARIES_0[_S348 + 5U]);
    return dot_0(rgb_0, _S349 + (_S350 - _S349) * make_float3 (_S346 - float(_S347)));
}

__device__ BSDFMaterial atWavelength(BSDFMaterial material_0, float wavelength_1)
{
    BSDFMaterial at_0 = material_0;
    float _S351 = upsample(material_0.albedo, wavelength_1);
    float3  _S352 = make_float3 (_S351);
    (&at_0)->albedo = _S352;
    float _S353 = upsample(material_0.emissive, wavelength_1);
    float3  _S354 = make_float3 (_S353);
    (&at_0)->emissive = _S354;
    float _S355 = upsample(material_0.absorption, wavelength_1);
    float3  _S356 = make_float3 (_S355);
    (&at_0)->absorption = _S356;
    float _S357 = upsample(material_0.specular_tint, wavelength_1);
    float3  _S358 = make_float3 (_S357);
    (&at_0)->specular_tint = _S358;
    float _S359 = upsample(material_0.translucent, wavelength_1);
    float3  _S360 = make_float3 (_S359);
    (&at_0)->translucent = _S360;
    float _S361 = upsample(material_0.sheen, wavelength_1);
    float3  _S362 = make_float3 (_S361);
    (&at_0)->sheen = _S362;
    return at_0;
}

__device__ BSDFMaterial pathMaterial(BSDFMaterial material_1, float wavelength_2)
{
    BSDFMaterial _S363;
    if(wavelength_2 > 0.0f)
    {
        BSDFMaterial _S364 = atWavelength(material_1, wavelength_2);
        _S363 = _S364;
    }
    else
    {
        _S363 = material_1;
    }
    return _S363;
}

static __device__ float3  negate_0(float3  x_13)
{
    return - x_13;
}

static __device__ float sign_0(float e_1)
{
    bool _S365 = e_1 < 0.0f;
    float _S366 = _slang_select(_S365, -1.0f,0.0f);
    bool _S367 = e_1 > 0.0f;
    float _S368 = _slang_select(_S367, 1.0f,_S366);
    return _S368;
}

struct AnisotropicFrame
{
    float3  tangent;
    float2  alphas;
};

static __device__ AnisotropicFrame AnisotropicFrame_x24init_0(float3  tangent_0, float2  alphas_0)
{
    AnisotropicFrame _S369;
    (&_S369)->tangent = tangent_0;
    (&_S369)->alphas = alphas_0;
    return _S369;
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_1)
{
    float3  a_1 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S370 = (F32_abs((dot_0(n_1, a_1)))) > 0.9999847412109375f;
    float3  a_2;
    if(_S370)
    {
        float3  _S371 = make_float3 (1.0f, 0.0f, 0.0f);
        a_2 = _S371;
    }
    else
    {
        a_2 = a_1;
    }
    float3  _S372 = cross_0(n_1, a_2);
    float3  _S373 = ((((_S372)) * make_float3(rnorm3df(((_S372)).x, ((_S372)).y, ((_S372)).z))));
    float3  _S374 = cross_0(n_1, _S373);
    return make_float3 (v_0.x) * _S373 + make_float3 (v_0.y) * n_1 + make_float3 (v_0.z) * _S374;
}

__device__ AnisotropicFrame anisotropicFrame(BSDFMaterial material_2, float3  n_i_0)
{
    float _S375 = material_2.roughness;
    float _S376 = _S375 * _S375;
    bool _S377 = (material_2.anisotropy) == 0.0f;
    bool _S378;
    if(_S377)
    {
        _S378 = true;
    }
    else
    {
        _S378 = !(_S376 > 0.0f);
    }
    if(_S378)
    {
        return AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f));
    }
    float3  _S379 = material_2.tangent - n_i_0 * make_float3 (dot_0(n_i_0, material_2.tangent));
    float3  _S380 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_i_0);
    bool _S381 = (dot_0(_S379, _S379)) > 0.0f;
    float3  _S382 = _slang_select(_S381, _S379,_S380);
    float3  _S383 = ((((_S382)) * make_float3(rnorm3df(((_S382)).x, ((_S382)).y, ((_S382)).z))));
    float _S384 = 6.28318548202514648f * material_2.anisotropic_rotation;
    float _S385 = (F32_sqrt((1.0f - 0.89999997615814209f * (F32_abs((material_2.anisotropy))))));
    float _S386 = 1.0f / _S385;
    bool _S387 = (material_2.anisotropy) < 0.0f;
    float _S388 = _slang_select(_S387, _S386,_S385);
    return AnisotropicFrame_x24init_0(_S383 * make_float3 ((F32_cos((_S384)))) + cross_0(n_i_0, _S383) * make_float3 ((F32_sin((_S384)))), make_float2 (_S376 / _S388, _S376 * _S388));
}

struct SheenProfile
{
    bool on;
    float albedo;
};

static __device__ SheenProfile SheenProfile_x24init_0(bool on_0, float albedo_0)
{
    SheenProfile _S389;
    (&_S389)->on = on_0;
    (&_S389)->albedo = albedo_0;
    return _S389;
}

__device__ float rgb_to_greyscale(float3  rgb_1)
{
    return dot_0(rgb_1, make_float3 (0.29899999499320984f, 0.58700001239776611f, 0.11400000005960464f));
}

__device__ static const FixedArray<float, 576>  VELVET_ALBEDO_0 = { {
    1.03603994846343994f, 1.04969000816345215f, 1.02470004558563232f, 1.01461005210876465f, 1.00961005687713623f, 1.00680005550384521f, 1.0050499439239502f, 1.00390005111694336f, 1.00312995910644531f, 1.00258004665374756f, 1.00213003158569336f, 1.0017399787902832f, 1.00138998031616211f, 1.00112998485565186f, 1.00097000598907471f, 1.00092995166778564f, 1.00098001956939697f, 1.00108003616333008f, 1.0011899471282959f, 1.00127995014190674f, 1.0013200044631958f, 1.00134003162384033f, 1.00133001804351807f, 1.00130999088287354f, 0.90734100341796875f, 0.98275798559188843f, 0.98386698961257935f, 0.98714500665664673f, 0.98988902568817139f, 0.99194902181625366f, 0.99348098039627075f, 0.99463999271392822f, 0.99551397562026978f, 0.99620199203491211f, 0.99678301811218262f, 0.99725902080535889f, 0.99762099981307983f, 0.99788099527359009f, 0.99806898832321167f, 0.99822998046875f, 0.9984009861946106f, 0.99860197305679321f, 0.99882900714874268f, 0.99905097484588623f, 0.99924802780151367f, 0.99941599369049072f, 0.99955397844314575f, 0.99966597557067871f, 0.47049999237060547f, 0.72047901153564453f, 0.82541298866271973f, 0.88024801015853882f, 0.91317099332809448f, 0.93422400951385498f, 0.94845300912857056f, 0.9585450291633606f, 0.96597200632095337f, 0.97161900997161865f, 0.97599798440933228f, 0.97946298122406006f, 0.98225301504135132f, 0.98453700542449951f, 0.98643702268600464f, 0.98803901672363281f, 0.98940402269363403f, 0.99057799577713013f, 0.99159497022628784f, 0.9924740195274353f, 0.99323201179504395f, 0.99394601583480835f, 0.9946179986000061f, 0.99514299631118774f, 0.10339099913835526f, 0.37652701139450073f, 0.58990597724914551f, 0.7168310284614563f, 0.79374098777770996f, 0.8438420295715332f, 0.87787497043609619f, 0.90189200639724731f, 0.919514000415802f, 0.93284100294113159f, 0.94317400455474854f, 0.95135498046875f, 0.95794999599456787f, 0.9633520245552063f, 0.96783697605133057f, 0.97160798311233521f, 0.97481298446655273f, 0.97755998373031616f, 0.97992998361587524f, 0.98198497295379639f, 0.98377299308776855f, 0.98532998561859131f, 0.98668897151947021f, 0.98788100481033325f, 0.00549574987962842f, 0.12130799889564514f, 0.33038300275802612f, 0.50957399606704712f, 0.63582301139831543f, 0.72130399942398071f, 0.78063100576400757f, 0.82337701320648193f, 0.85500001907348633f, 0.87895798683166504f, 0.89755398035049438f, 0.91228801012039185f, 0.92417001724243164f, 0.93390399217605591f, 0.94199001789093018f, 0.94878798723220825f, 0.95456397533416748f, 0.95951497554779053f, 0.96378600597381592f, 0.96749001741409302f, 0.97071200609207153f, 0.97352099418640137f, 0.97597402334213257f, 0.97811698913574219f, 0.00006616840255447f, 0.01978570036590099f, 0.13480900228023529f, 0.30441498756408691f, 0.4568449854850769f, 0.57461702823638916f, 0.66137099266052246f, 0.72547799348831177f, 0.77361601591110229f, 0.81061500310897827f, 0.83951497077941895f, 0.86248302459716797f, 0.88104599714279175f, 0.89627498388290405f, 0.90893799066543579f, 0.91959297657012939f, 0.92865198850631714f, 0.93641901016235352f, 0.94312202930450439f, 0.94893598556518555f, 0.95399397611618042f, 0.95840400457382202f, 0.96225601434707642f, 0.96562099456787109f, 6.08604011631541653e-08f, 0.00167625001631677f, 0.03686590120196342f, 0.14405199885368347f, 0.28643798828125f, 0.41852200031280518f, 0.5268089771270752f, 0.61179697513580322f, 0.67761099338531494f, 0.72897201776504517f, 0.76956802606582642f, 0.80211901664733887f, 0.82861298322677612f, 0.85041999816894531f, 0.86859399080276489f, 0.88391202688217163f, 0.89695101976394653f, 0.90814197063446045f, 0.91780698299407959f, 0.9261929988861084f, 0.933493971824646f, 0.93986201286315918f, 0.94542300701141357f, 0.95028501749038696f, 1.25722999719246609e-12f, 0.00005344190140022f, 0.00689807021990418f, 0.05298750102519989f, 0.15135200321674347f, 0.27379500865936279f, 0.38978201150894165f, 0.48924699425697327f, 0.57068902254104614f, 0.6363450288772583f, 0.68930798768997192f, 0.73230600357055664f, 0.7675589919090271f, 0.79679697751998901f, 0.82128000259399414f, 0.84197902679443359f, 0.85963702201843262f, 0.87481701374053955f, 0.88794499635696411f, 0.89934700727462769f, 0.90928000211715698f, 0.91794902086257935f, 0.92552399635314941f, 0.93214702606201172f, 1.32430000482605838e-19f, 4.34398998550022952e-07f, 0.00078319699969143f, 0.01505979988723993f, 0.06700140237808228f, 0.15685500204563141f, 0.26414799690246582f, 0.36752399802207947f, 0.45892399549484253f, 0.53633898496627808f, 0.60086798667907715f, 0.65432101488113403f, 0.69876497983932495f, 0.73594701290130615f, 0.76730400323867798f, 0.79397499561309814f, 0.8168100118637085f, 0.83649301528930664f, 0.85354900360107422f, 0.86838698387145996f, 0.88132798671722412f, 0.89263200759887695f, 0.90251702070236206f, 0.91116297245025635f, 1.21214998864702984e-29f, 5.61858004566317959e-10f, 0.00004580340100802f, 0.00315008009783924f, 0.02455909922719002f, 0.07877019792795181f, 0.16104799509048462f, 0.25635600090026855f, 0.34949898719787598f, 0.43382999300956726f, 0.50729697942733765f, 0.57010501623153687f, 0.62341398000717163f, 0.66865599155426025f, 0.70718997716903687f, 0.74018502235412598f, 0.76862901449203491f, 0.79324597120285034f, 0.8146439790725708f, 0.83329999446868896f, 0.84960097074508667f, 0.86386102437973022f, 0.87634098529815674f, 0.88726699352264404f, 1.17709071003284634e-43f, 6.58941014274917747e-14f, 1.12094994619837962e-06f, 0.00044787500519305f, 0.00728174997493625f, 0.03418119996786118f, 0.08846849948167801f, 0.16411800682544708f, 0.24980400502681732f, 0.33453500270843506f, 0.41271701455116272f, 0.48244500160217285f, 0.54331201314926147f, 0.59608602523803711f, 0.64167797565460205f, 0.68114197254180908f, 0.71539402008056641f, 0.7452319860458374f, 0.77129900455474854f, 0.79410398006439209f, 0.81407999992370605f, 0.83158797025680542f, 0.846934974193573f, 0.86038398742675781f, 0.0f, 3.5722200588590534e-19f, 8.93677043478646738e-09f, 0.00003873859895975f, 0.00167270004749298f, 0.01264849957078695f, 0.04320650175213814f, 0.09630840271711349f, 0.16610400378704071f, 0.24392600357532501f, 0.32165700197219849f, 0.394569993019104f, 0.46081000566482544f, 0.51976299285888672f, 0.57175701856613159f, 0.61742901802062988f, 0.65750598907470703f, 0.69269400835037231f, 0.72362500429153442f, 0.75082802772521973f, 0.77473902702331543f, 0.79575198888778687f, 0.81420797109603882f, 0.83040601015090942f, 0.0f, 3.95292991891679393e-26f, 1.71184993263961971e-11f, 1.77651998001238098e-06f, 0.0002783710078802f, 0.00388711993582547f, 0.01858510076999664f, 0.05124599859118462f, 0.10246899724006653f, 0.16709500551223755f, 0.23837999999523163f, 0.31022000312805176f, 0.37857699394226074f, 0.44168499112129211f, 0.4988040030002594f, 0.54993897676467896f, 0.59550100564956665f, 0.63594001531600952f, 0.67177599668502808f, 0.70349597930908203f, 0.73152798414230347f, 0.75625097751617432f, 0.77802300453186035f, 0.79716801643371582f, 0.0f, 3.2483199352805935e-35f, 5.40527002565222188e-15f, 3.64182994871953269e-08f, 0.00003074659980484f, 0.00094859098317102f, 0.00691073015332222f, 0.02452139928936958f, 0.05809320136904716f, 0.10707399994134903f, 0.16711099445819855f, 0.23287899792194366f, 0.29971298575401306f, 0.36412099003791809f, 0.42443698644638062f, 0.47984799742698669f, 0.53011900186538696f, 0.57539498805999756f, 0.61597698926925659f, 0.65218400955200195f, 0.6844019889831543f, 0.71295899152755737f, 0.73819798231124878f, 0.7604449987411499f, 0.0f, 0.0f, 1.7447100275121598e-19f, 2.68698008287771017e-10f, 2.01520992959558498e-06f, 0.00017266000213567f, 0.00214895000681281f, 0.01039279997348785f, 0.03002390079200268f, 0.06362999975681305f, 0.11018999665975571f, 0.16611799597740173f, 0.22714599967002869f, 0.2896830141544342f, 0.35065999627113342f, 0.40850698947906494f, 0.46232399344444275f, 0.51169002056121826f, 0.55654400587081909f, 0.59701400995254517f, 0.63333100080490112f, 0.66571998596191406f, 0.69448697566986084f, 0.71991300582885742f, 0.0f, 0.0f, 3.08185990824019565e-25f, 5.37352009676722586e-13f, 6.76860025805581245e-08f, 0.00002156710070267f, 0.00053187098819762f, 0.00379640003666282f, 0.01394980028271675f, 0.03477099910378456f, 0.06777119636535645f, 0.11182600259780884f, 0.16402900218963623f, 0.22092700004577637f, 0.27971801161766052f, 0.33767500519752502f, 0.3932889997959137f, 0.44556498527526855f, 0.493927001953125f, 0.53815799951553345f, 0.57827800512313843f, 0.61434602737426758f, 0.64652997255325317f, 0.67506802082061768f, 0.0f, 0.0f, 1.27565998769738086e-32f, 1.98236004320260421e-16f, 9.54645029693779179e-10f, 1.650769945626962e-06f, 0.00009778440289665f, 0.00114505004603416f, 0.00568277994170785f, 0.01722680032253265f, 0.03851649910211563f, 0.0704336017370224f, 0.11193899810314178f, 0.16071000695228577f, 0.21397699415683746f, 0.2693760097026825f, 0.32457900047302246f, 0.37806499004364014f, 0.42872300744056702f, 0.4758630096912384f, 0.51915699243545532f, 0.55846899747848511f, 0.59376901388168335f, 0.62519502639770508f, 0.0f, 0.0f, 3.7106383335321156e-42f, 7.81385018096993734e-21f, 4.26179013954253172e-12f, 6.59224994592477742e-08f, 0.00001210350001202f, 0.00026765500660986f, 0.00194808002561331f, 0.00754345022141933f, 0.01991299912333488f, 0.04105570167303085f, 0.0715148001909256f, 0.11042399704456329f, 0.15595099329948425f, 0.20584699511528015f, 0.25806799530982971f, 0.31055599451065063f, 0.36178100109100342f, 0.41049200296401978f, 0.45592901110649109f, 0.49765899777412415f, 0.53551197052001953f, 0.56948697566986084f, 0.0f, 0.0f, 0.0f, 1.4501699354155858e-26f, 3.9408500097373126e-15f, 1.07906994450956972e-09f, 8.70304006639344152e-07f, 0.0000440725016233f, 0.0005269440007396f, 0.00279516004957259f, 0.00910075008869171f, 0.02173379994928837f, 0.04219720140099525f, 0.07087449729442596f, 0.10709299892187119f, 0.14939899742603302f, 0.19591200351715088f, 0.24481700360774994f, 0.29424700140953064f, 0.34261700510978699f, 0.38869300484657288f, 0.43174698948860168f, 0.47139298915863037f, 0.50751799345016479f, 0.0f, 0.0f, 0.0f, 3.37722993781223165e-34f, 3.80885988849822355e-19f, 4.90656994200922014e-12f, 2.86603007992880521e-08f, 4.38328015661682002e-06f, 0.00010134100011783f, 0.00081476598279551f, 0.00349242007359862f, 0.01008209958672523f, 0.02243220061063766f, 0.04172819852828979f, 0.06827779859304428f, 0.10154099762439728f, 0.14030000567436218f, 0.18292999267578125f, 0.22785000503063202f, 0.27340999245643616f, 0.31820300221443176f, 0.36118099093437195f, 0.40175101161003113f, 0.43962100148200989f, 0.0f, 0.0f, 0.0f, 9.8090892502737195e-45f, 1.13511000171572082e-24f, 3.09601003078345365e-15f, 2.82900008974351636e-10f, 2.00208006617685896e-07f, 0.00001151220021711f, 0.00016400900494773f, 0.00102415005676448f, 0.00382522004656494f, 0.01021770015358925f, 0.02173330076038837f, 0.03936100006103516f, 0.06336659938097f, 0.09330789744853973f, 0.12818600237369537f, 0.16668100655078888f, 0.20739200711250305f, 0.24903899431228638f, 0.29063498973846436f, 0.33134400844573975f, 0.37064099311828613f, 0.0f, 0.0f, 0.0f, 0.0f, 8.14998004479130106e-33f, 6.36954985683458947e-20f, 3.45817992297714483e-13f, 2.37365993527305363e-09f, 5.25424979969102424e-07f, 0.00001739979961712f, 0.00018874299712479f, 0.00102673994842917f, 0.00357491988688707f, 0.00922095961868763f, 0.01929700002074242f, 0.03473329916596413f, 0.05588230118155479f, 0.08250939846038818f, 0.1139099970459938f, 0.14910100400447845f, 0.18701300024986267f, 0.22664099931716919f, 0.26713100075721741f, 0.3078019917011261f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 7.3832999238063224e-28f, 4.4141699295504271e-18f, 1.48473995684877957e-12f, 3.29401994569877843e-09f, 4.59630996374471579e-07f, 0.00001273939960811f, 0.00013086199760437f, 0.00071139499777928f, 0.00253174011595547f, 0.00673073995858431f, 0.01454710029065609f, 0.02702569961547852f, 0.04481859877705574f, 0.06811539828777313f, 0.09668000042438507f, 0.12994599342346191f, 0.1671299934387207f, 0.2073339968919754f, 0.24963200092315674f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 3.35172992357784324e-37f, 1.16603995591046571e-24f, 3.39939997419364372e-17f, 1.64230001126197678e-12f, 1.9398800343850553e-09f, 2.402420022917795e-07f, 7.1422400651499629e-06f, 0.00008337580220541f, 0.0005176099948585f, 0.00207298994064331f, 0.00607771007344127f, 0.01419879961758852f, 0.0280108992010355f, 0.04858930036425591f, 0.07628270238637924f, 0.11069700121879578f, 0.15084299445152283f, 0.19536399841308594f
} };
__device__ static const FixedArray<float, 576>  SHEEN_ALBEDO_0 = { {
    0.62089997529983521f, 0.49450001120567322f, 0.38080000877380371f, 0.28439998626708984f, 0.20010000467300415f, 0.1257999986410141f, 0.05990000069141388f, 0.00109999999403954f, -0.05160000175237656f, -0.09889999777078629f, -0.14159999787807465f, -0.18009999394416809f, -0.2151000052690506f, -0.24690000712871552f, -0.27590000629425049f, -0.30230000615119934f, -0.32649999856948853f, -0.34860000014305115f, -0.36890000104904175f, -0.38760000467300415f, -0.40479999780654907f, -0.42070001363754272f, -0.43439999222755432f, -0.44929999113082886f, 0.59240001440048218f, 0.47049999237060547f, 0.35899999737739563f, 0.26440000534057617f, 0.18150000274181366f, 0.10830000042915344f, 0.04329999908804893f, -0.01470000017434359f, -0.066600002348423f, -0.11339999735355377f, -0.15549999475479126f, -0.19370000064373016f, -0.22820000350475311f, -0.25970000028610229f, -0.28830000758171082f, -0.31450000405311584f, -0.33840000629425049f, -0.36039999127388f, -0.38049998879432678f, -0.39899998903274536f, -0.41609999537467957f, -0.43180000782012939f, -0.44539999961853027f, -0.46070000529289246f, 0.5228000283241272f, 0.40599998831748962f, 0.30259999632835388f, 0.21250000596046448f, 0.13330000638961792f, 0.06319999694824219f, 0.00069999997504056f, -0.05510000139474869f, -0.10520000010728836f, -0.15039999783039093f, -0.19120000302791595f, -0.2281000018119812f, -0.26170000433921814f, -0.2921999990940094f, -0.31999999284744263f, -0.34549999237060547f, -0.36869999766349792f, -0.39010000228881836f, -0.40970000624656677f, -0.42770001292228699f, -0.44440001249313354f, -0.45969998836517334f, -0.47389999032020569f, -0.48800000548362732f, 0.43569999933242798f, 0.32769998908042908f, 0.23160000145435333f, 0.14730000495910645f, 0.07280000299215317f, 0.00659999996423721f, -0.05260000005364418f, -0.10559999942779541f, -0.1534000039100647f, -0.19650000333786011f, -0.23549999296665192f, -0.27090001106262207f, -0.30309998989105225f, -0.33239999413490295f, -0.35920000076293945f, -0.38359999656677246f, -0.40599998831748962f, -0.42660000920295715f, -0.44549998641014099f, -0.46290001273155212f, -0.47900000214576721f, -0.49380001425743103f, -0.50749999284744263f, -0.52090001106262207f, 0.33129999041557312f, 0.23459999263286591f, 0.14740000665187836f, 0.07010000199079514f, 0.00139999995008111f, -0.0601000003516674f, -0.11519999802112579f, -0.16490000486373901f, -0.20970000326633453f, -0.25029999017715454f, -0.28720000386238098f, -0.3206000030040741f, -0.35109999775886536f, -0.37900000810623169f, -0.40439999103546143f, -0.42770001292228699f, -0.44900000095367432f, -0.46869999170303345f, -0.48669999837875366f, -0.5033000111579895f, -0.5187000036239624f, -0.53289997577667236f, -0.54600000381469727f, -0.55860000848770142f, 0.21109999716281891f, 0.12790000438690186f, 0.0511000007390976f, -0.01769999973475933f, -0.07970000058412552f, -0.13549999892711639f, -0.18600000441074371f, -0.23160000145435333f, -0.27300000190734863f, -0.31069999933242798f, -0.34490001201629639f, -0.37619999051094055f, -0.40470001101493835f, -0.43070000410079956f, -0.4546000063419342f, -0.476500004529953f, -0.49660000205039978f, -0.51510000228881836f, -0.53210002183914185f, -0.54780000448226929f, -0.56230002641677856f, -0.57580000162124634f, -0.58819997310638428f, -0.60009998083114624f, 0.0754999965429306f, 0.00800000037997961f, -0.05649999901652336f, -0.11569999903440475f, -0.16979999840259552f, -0.21920000016689301f, -0.26420000195503235f, -0.3052000105381012f, -0.34270000457763672f, -0.37689998745918274f, -0.40819999575614929f, -0.43680000305175781f, -0.46299999952316284f, -0.48710000514984131f, -0.50910001993179321f, -0.52939999103546143f, -0.54809999465942383f, -0.56529998779296875f, -0.5810999870300293f, -0.59570002555847168f, -0.60930001735687256f, -0.6218000054359436f, -0.63340002298355103f, -0.6445000171661377f, -0.07569999992847443f, -0.12489999830722809f, -0.17569999396800995f, -0.22380000352859497f, -0.26890000700950623f, -0.3107999861240387f, -0.34959998726844788f, -0.38539999723434448f, -0.41839998960494995f, -0.44870001077651978f, -0.47659999132156372f, -0.50230002403259277f, -0.52590000629425049f, -0.54759997129440308f, -0.56760001182556152f, -0.58600002527236938f, -0.6029999852180481f, -0.61870002746582031f, -0.63330000638961792f, -0.64670002460479736f, -0.6590999960899353f, -0.67059999704360962f, -0.68129998445510864f, -0.69160002470016479f, -0.24320000410079956f, -0.27120000123977661f, -0.30640000104904175f, -0.34209999442100525f, -0.37700000405311584f, -0.41060000658035278f, -0.44229999184608459f, -0.47220000624656677f, -0.50010001659393311f, -0.52600002288818359f, -0.55010002851486206f, -0.57239997386932373f, -0.59310001134872437f, -0.61220002174377441f, -0.62989997863769531f, -0.64620000123977661f, -0.66140002012252808f, -0.6754000186920166f, -0.68839997053146362f, -0.70039999485015869f, -0.71160000562667847f, -0.72200000286102295f, -0.73159998655319214f, -0.74089998006820679f, -0.42809998989105225f, -0.43149998784065247f, -0.44920000433921814f, -0.47099998593330383f, -0.49459999799728394f, -0.51880002021789551f, -0.54269999265670776f, -0.5658000111579895f, -0.58799999952316284f, -0.60900002717971802f, -0.62870001792907715f, -0.64730000495910645f, -0.6646999716758728f, -0.68080002069473267f, -0.69590002298355103f, -0.70999997854232788f, -0.72299998998641968f, -0.73509997129440308f, -0.74639999866485596f, -0.75690001249313354f, -0.76670002937316895f, -0.77579998970031738f, -0.78430002927780151f, -0.79250001907348633f, -0.63230001926422119f, -0.60759997367858887f, -0.60519999265670776f, -0.61119997501373291f, -0.62209999561309814f, -0.63580000400543213f, -0.65090000629425049f, -0.66659998893737793f, -0.68239998817443848f, -0.69789999723434448f, -0.71289998292922974f, -0.7271999716758728f, -0.74089998006820679f, -0.75379997491836548f, -0.76590001583099365f, -0.77740001678466797f, -0.78810000419616699f, -0.79809999465942383f, -0.80750000476837158f, -0.81629997491836548f, -0.82450002431869507f, -0.83209997415542603f, -0.83929997682571411f, -0.84630000591278076f, -0.85790002346038818f, -0.80119997262954712f, -0.77600002288818359f, -0.76410001516342163f, -0.76059997081756592f, -0.76239997148513794f, -0.76770001649856567f, -0.7750999927520752f, -0.78380000591278076f, -0.79309999942779541f, -0.80279999971389771f, -0.8125f, -0.82200002670288086f, -0.8312000036239624f, -0.8400999903678894f, -0.84859997034072876f, -0.85670000314712524f, -0.86440002918243408f, -0.8716999888420105f, -0.87849998474121094f, -0.88499999046325684f, -0.89099997282028198f, -0.89670002460479736f, -0.90240001678466797f, -1.10769999027252197f, -1.01429998874664307f, -0.96329998970031738f, -0.93110001087188721f, -0.91140002012252808f, -0.89990001916885376f, -0.89410001039505005f, -0.89219999313354492f, -0.89289999008178711f, -0.89539998769760132f, -0.89910000562667847f, -0.9035000205039978f, -0.90850001573562622f, -0.91360002756118774f, -0.9189000129699707f, -0.92419999837875366f, -0.92940002679824829f, -0.93440002202987671f, -0.93930000066757202f, -0.9440000057220459f, -0.94849997758865356f, -0.95270001888275146f, -0.95679998397827148f, -0.96100002527236938f, -1.38499999046325684f, -1.24950003623962402f, -1.16919994354248047f, -1.11409997940063477f, -1.07599997520446777f, -1.0494999885559082f, -1.03129994869232178f, -1.01880002021789551f, -1.01059997081756592f, -1.00539994239807129f, -1.00240004062652588f, -1.00109994411468506f, -1.0009000301361084f, -1.00150001049041748f, -1.00279998779296875f, -1.00440001487731934f, -1.00639998912811279f, -1.00849997997283936f, -1.01069998741149902f, -1.0130000114440918f, -1.01530003547668457f, -1.01750004291534424f, -1.01979994773864746f, -1.02230000495910645f, -1.69420003890991211f, -1.51020002365112305f, -1.39649999141693115f, -1.31540000438690186f, -1.2565000057220459f, -1.21309995651245117f, -1.18079996109008789f, -1.15649998188018799f, -1.13820004463195801f, -1.12440001964569092f, -1.11389994621276855f, -1.10599994659423828f, -1.10010004043579102f, -1.09560000896453857f, -1.09230005741119385f, -1.09000003337860107f, -1.08829998970031738f, -1.08710002899169922f, -1.08640003204345703f, -1.08599996566772461f, -1.08580005168914795f, -1.08580005168914795f, -1.08599996566772461f, -1.0866999626159668f, -2.04089999198913574f, -1.80079996585845947f, -1.64869999885559082f, -1.53789997100830078f, -1.45539999008178711f, -1.392799973487854f, -1.34459996223449707f, -1.30700004100799561f, -1.27730000019073486f, -1.25380003452301025f, -1.23489999771118164f, -1.21959996223449707f, -1.20720005035400391f, -1.19700002670288086f, -1.18859994411468506f, -1.18169999122619629f, -1.17589998245239258f, -1.17100000381469727f, -1.16690003871917725f, -1.16349995136260986f, -1.16059994697570801f, -1.15810000896453857f, -1.15600001811981201f, -1.15470004081726074f, -2.43269991874694824f, -2.12700009346008301f, -1.93060004711151123f, -1.78569996356964111f, -1.67610001564025879f, -1.59159994125366211f, -1.52530002593994141f, -1.47249996662139893f, -1.4299999475479126f, -1.39540004730224609f, -1.36689996719360352f, -1.3432999849319458f, -1.32350003719329834f, -1.30680000782012939f, -1.29270005226135254f, -1.28059995174407959f, -1.27009999752044678f, -1.26110005378723145f, -1.25329995155334473f, -1.24639999866485596f, -1.24039995670318604f, -1.23500001430511475f, -1.23029994964599609f, -1.22669994831085205f, -2.87989997863769531f, -2.49659991264343262f, -2.24860000610351562f, -2.06410002708435059f, -1.92330002784729004f, -1.8135000467300415f, -1.72640001773834229f, -1.65620005130767822f, -1.59899997711181641f, -1.55169999599456787f, -1.51230001449584961f, -1.47909998893737793f, -1.45099997520446777f, -1.42690002918243408f, -1.40610003471374512f, -1.3881000280380249f, -1.37240004539489746f, -1.35860002040863037f, -1.34640002250671387f, -1.33570003509521484f, -1.32609999179840088f, -1.31749999523162842f, -1.30980002880096436f, -1.30359995365142822f, -3.39750003814697266f, -2.92090010643005371f, -2.6119999885559082f, -2.38100004196166992f, -2.20359992980957031f, -2.0643000602722168f, -1.95290005207061768f, -1.86249995231628418f, -1.7882000207901001f, -1.72619998455047607f, -1.67410004138946533f, -1.62989997863769531f, -1.59200000762939453f, -1.55929994583129883f, -1.53090000152587891f, -1.50610005855560303f, -1.48430001735687256f, -1.46500003337860107f, -1.44790005683898926f, -1.43260002136230469f, -1.4189000129699707f, -1.40649998188018799f, -1.39540004730224609f, -1.38629996776580811f, -4.00810003280639648f, -3.41639995574951172f, -3.03419995307922363f, -2.74749994277954102f, -2.52649998664855957f, -2.35209989547729492f, -2.21210002899169922f, -2.09780001640319824f, -2.00309991836547852f, -1.92390000820159912f, -1.85679996013641357f, -1.7994999885559082f, -1.75020003318786621f, -1.70739996433258057f, -1.66999995708465576f, -1.6371999979019165f, -1.60819995403289795f, -1.58239996433258057f, -1.55949997901916504f, -1.53890001773834229f, -1.52040004730224609f, -1.50370001792907715f, -1.48860001564025879f, -1.47609996795654297f, -4.7491002082824707f, -4.00920009613037109f, -3.53640007972717285f, -3.18140006065368652f, -2.90700006484985352f, -2.69000005722045898f, -2.5150001049041748f, -2.37150001525878906f, -2.25230002403259277f, -2.15199995040893555f, -2.06680011749267578f, -1.99370002746582031f, -1.93060004711151123f, -1.87559998035430908f, -1.82739996910095215f, -1.78489995002746582f, -1.74730002880096436f, -1.71379995346069336f, -1.68389999866485596f, -1.65699994564056396f, -1.63279998302459717f, -1.6109999418258667f, -1.59109997749328613f, -1.5746999979019165f, -5.68760013580322266f, -4.74030017852783203f, -4.15259981155395508f, -3.71110010147094727f, -3.36949992179870605f, -3.09859991073608398f, -2.87960004806518555f, -2.69939994812011719f, -2.54920005798339844f, -2.42239999771118164f, -2.31439995765686035f, -2.22140002250671387f, -2.1408998966217041f, -2.07069993019104004f, -2.00900006294250488f, -1.95459997653961182f, -1.90629994869232178f, -1.86329996585845947f, -1.82480001449584961f, -1.79030001163482666f, -1.75919997692108154f, -1.73099994659423828f, -1.70550000667572021f, -1.68429994583129883f, -6.68940019607543945f, -5.34350013732910156f, -4.86259984970092773f, -4.34409999847412109f, -3.93390011787414551f, -3.60269999504089355f, -3.33100008964538574f, -3.10509991645812988f, -2.91510009765625f, -2.75390005111694336f, -2.61590003967285156f, -2.49690008163452148f, -2.3935999870300293f, -2.30340003967285156f, -2.22420001029968262f, -2.15440011024475098f, -2.09240007400512695f, -2.03730010986328125f, -1.98800003528594971f, -1.94369995594024658f, -1.90390002727508545f, -1.86790001392364502f, -1.83480000495910645f, -1.8078000545501709f, -9.69550037384033203f, -7.62489986419677734f, -6.61070013046264648f, -5.72329998016357422f, -5.04829978942871094f, -4.52129983901977539f, -4.10120010375976562f, -3.76049995422363281f, -3.48009991645812988f, -3.24640011787414551f, -3.04959988594055176f, -2.88229990005493164f, -2.738800048828125f, -2.61479997634887695f, -2.50699996948242188f, -2.41269993782043457f, -2.32960009574890137f, -2.25620007514953613f, -2.19090008735656738f, -2.13269996643066406f, -2.08049988746643066f, -2.03349995613098145f, -1.99049997329711914f, -1.95369994640350342f
} };
__device__ __forceinline__ SheenProfile sheenProfile(float3  v_1, float3  n_i_1, BSDFMaterial material_3)
{
    SheenProfile _S390 = SheenProfile_x24init_0(false, 0.0f);
    float _S391 = rgb_to_greyscale(material_3.sheen);
    bool _S392 = _S391 > 0.0f;
    SheenProfile profile_0;
    if(_S392)
    {
        float _S393 = clamp_1((F32_sqrt(((F32_max((dot_0(n_i_1, v_1)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S394 = (U32_min((uint(_S393)), (22U)));
        float _S395 = (F32_sqrt((0.05000000074505806f)));
        float _S396 = (F32_sqrt((0.00999999977648258f)));
        bool _S397 = (material_3.velvet) > 0.0f;
        float _S398 = _slang_select(_S397, _S396,_S395);
        float _S399 = (clamp_1((F32_sqrt(((F32_max((material_3.sheen_roughness), (0.0f)))))), _S398, 1.0f) - _S398) / (1.0f - _S398) * 23.0f;
        uint _S400 = (U32_min((uint(_S399)), (22U)));
        uint _S401 = _S394 * 24U + _S400;
        float _S402 = _S393 - float(_S394);
        float _S403 = _S399 - float(_S400);
        if(_S397)
        {
            uint _S404 = _S401 + 24U;
            float _S405 = VELVET_ALBEDO_0[_S401] + (VELVET_ALBEDO_0[_S404] - VELVET_ALBEDO_0[_S401]) * _S402;
            uint _S406 = _S401 + 1U;
            float _S407 = VELVET_ALBEDO_0[_S406] + (VELVET_ALBEDO_0[_S404 + 1U] - VELVET_ALBEDO_0[_S406]) * _S402;
            SheenProfile _S408 = SheenProfile_x24init_0(true, _S405 + (_S407 - _S405) * _S403);
            profile_0 = _S408;
        }
        else
        {
            uint _S409 = _S401 + 24U;
            float _S410 = SHEEN_ALBEDO_0[_S401] + (SHEEN_ALBEDO_0[_S409] - SHEEN_ALBEDO_0[_S401]) * _S402;
            uint _S411 = _S401 + 1U;
            float _S412 = SHEEN_ALBEDO_0[_S411] + (SHEEN_ALBEDO_0[_S409 + 1U] - SHEEN_ALBEDO_0[_S411]) * _S402;
            SheenProfile _S413 = SheenProfile_x24init_0(true, (F32_exp((_S410 + (_S412 - _S410) * _S403))));
            profile_0 = _S413;
        }
    }
    else
    {
        profile_0 = _S390;
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
    Weights _S414;
    (&_S414)->v_dot_h = v_dot_h_0;
    (&_S414)->refracted = refracted_1;
    (&_S414)->F = F_0;
    (&_S414)->reflect_weight = reflect_weight_0;
    (&_S414)->diffuse_weight = diffuse_weight_0;
    (&_S414)->refract_weight = refract_weight_0;
    (&_S414)->p_diffuse = p_diffuse_0;
    (&_S414)->p_reflect = p_reflect_0;
    (&_S414)->p_refract = p_refract_0;
    (&_S414)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S414)->p_toon = p_toon_0;
    (&_S414)->sheen = sheen_0;
    (&_S414)->toon = toon_0;
    return _S414;
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
    float3  _S415 = make_float3 (alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z);
    float3  _S416 = ((((_S415)) * make_float3(rnorm3df(((_S415)).x, ((_S415)).y, ((_S415)).z))));
    float _S417 = _S416.x;
    float _S418 = _S416.y;
    float _S419 = _S417 * _S417 + _S418 * _S418;
    float3  _S420 = make_float3 (1.0f, 0.0f, 0.0f);
    float3  _S421 = make_float3 (- _S418, _S417, 0.0f);
    float _S422 = (rsqrtf((_S419)));
    float3  _S423 = _S421 * make_float3 (_S422);
    bool _S424 = _S419 > 0.0f;
    float3  _S425 = _slang_select(_S424, _S423,_S420);
    float3  _S426 = cross_0(_S416, _S425);
    float _S427 = (F32_sqrt((U1_0)));
    float _S428 = 6.28318548202514648f * U2_0;
    float _S429 = _S427 * (F32_cos((_S428)));
    float t2_0 = _S427 * (F32_sin((_S428)));
    float _S430 = 0.5f * (1.0f + _S416.z);
    float t2_1 = (1.0f - _S430) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S429 * _S429)))))) + _S430 * t2_0;
    float3  _S431 = make_float3 (_S429) * _S425 + make_float3 (t2_1) * _S426;
    float _S432 = unshared_0(_S429);
    float _S433 = unshared_0(_S429);
    float3  _S434 = _S431 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S432 * _S433 - t2_1 * t2_1))))))) * _S416;
    float3  _S435 = make_float3 (alpha_0 * _S434.x, alpha_0 * _S434.y, (F32_max((0.0f), (_S434.z))));
    float3  _S436 = ((((_S435)) * make_float3(rnorm3df(((_S435)).x, ((_S435)).y, ((_S435)).z))));
    return _S436;
}

__device__ float3  worldToTangent(float3  v_2, float3  n_3)
{
    float3  a_3 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S437 = (F32_abs((dot_0(n_3, a_3)))) > 0.9999847412109375f;
    float3  a_4;
    if(_S437)
    {
        float3  _S438 = make_float3 (1.0f, 0.0f, 0.0f);
        a_4 = _S438;
    }
    else
    {
        a_4 = a_3;
    }
    float3  _S439 = cross_0(n_3, a_4);
    float3  _S440 = ((((_S439)) * make_float3(rnorm3df(((_S439)).x, ((_S439)).y, ((_S439)).z))));
    float3  _S441 = cross_0(n_3, _S440);
    return make_float3 (dot_0(v_2, _S440), dot_0(v_2, n_3), dot_0(v_2, _S441));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_3, float3  n_i_2, float alpha_1, AnisotropicFrame frame_0, uint * random_state_2)
{
    Random _S442 = draw(*random_state_2, 0U);
    Random _S443 = draw(*random_state_2, 2147483648U);
    *random_state_2 = _S443.state;
    float _S444 = frame_0.alphas.x;
    bool _S445 = _S444 > 0.0f;
    if(_S445)
    {
        float3  _S446 = anisotropicLocal(v_3, frame_0.tangent, n_i_2);
        float _S447 = frame_0.alphas.y;
        float3  _S448 = make_float3 (_S444 * _S446.x, _S447 * _S446.y, _S446.z);
        float3  _S449 = ((((_S448)) * make_float3(rnorm3df(((_S448)).x, ((_S448)).y, ((_S448)).z))));
        float3  _S450 = sampleGGXVNDF(_S449, 1.0f, _S442.value, _S443.value);
        float3  _S451 = make_float3 (_S444 * _S450.x, _S447 * _S450.y, _S450.z);
        float3  _S452 = ((((_S451)) * make_float3(rnorm3df(((_S451)).x, ((_S451)).y, ((_S451)).z))));
        return make_float3 (_S452.x) * frame_0.tangent + make_float3 (_S452.y) * cross_0(n_i_2, frame_0.tangent) + make_float3 (_S452.z) * n_i_2;
    }
    float3  _S453 = worldToTangent(v_3, n_i_2);
    float3  _S454 = sampleGGXVNDF(float3 {_S453.x, _S453.z, _S453.y}, alpha_1, _S442.value, _S443.value);
    float3  _S455 = float3 {_S454.x, _S454.z, _S454.y};
    float3  _S456 = tangentToWorld(_S455, n_i_2);
    return _S456;
}

__device__ __forceinline__ float3  sampledHalf(float3  v_4, float3  n_i_3, float alpha_2, AnisotropicFrame frame_1, uint random_state_3)
{
    uint state_2 = random_state_3;
    float3  _S457 = sampleHalfVector(v_4, n_i_3, alpha_2, frame_1, &state_2);
    return _S457;
}

__device__ __forceinline__ float3  refractedHalf(float3  in_dir_0, float3  out_dir_0, float3  n_4, float eta_i_0, float eta_o_0)
{
    float3  _S458 = negate_0(in_dir_0);
    float3  _S459 = negate_0(make_float3 (eta_i_0) * _S458 + make_float3 (eta_o_0) * out_dir_0);
    float3  _S460 = ((((_S459)) * make_float3(rnorm3df(((_S459)).x, ((_S459)).y, ((_S459)).z))));
    float _S461 = sign_0(dot_0(n_4, _S458));
    float _S462 = sign_0(dot_0(_S459, n_4 * make_float3 (_S461)));
    return _S460 * make_float3 (_S462);
}

__device__ __forceinline__ float3  reflectedHalf(float3  in_dir_1, float3  out_dir_1)
{
    float3  _S463 = negate_0(in_dir_1);
    float3  _S464 = _S463 + out_dir_1;
    float3  _S465 = ((((_S464)) * make_float3(rnorm3df(((_S464)).x, ((_S464)).y, ((_S464)).z))));
    return _S465;
}

static __device__ float3  refract_0(float3  i_5, float3  n_5, float eta_0)
{
    float _S466 = dot_0(n_5, i_5);
    float _S467 = 1.0f - eta_0 * eta_0 * (1.0f - _S466 * _S466);
    if(_S467 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_5 - make_float3 (eta_0 * _S466 + (F32_sqrt((_S467)))) * n_5;
}

__device__ float fresnel(float cos_theta_0, float eta_i_1, float eta_o_1)
{
    float _S468 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S469 = eta_i_1 / eta_o_1 * _S468;
    bool _S470 = _S469 < 1.0f;
    float kr_0;
    if(_S470)
    {
        float _S471 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S469 * _S469))))));
        bool _S472 = eta_i_1 == eta_o_1;
        float _S473 = _slang_select(_S472, cos_theta_0,_S471);
        float _S474 = eta_o_1 * cos_theta_0;
        float _S475 = eta_i_1 * _S473;
        float _S476 = (_S474 - _S475) / (_S474 + _S475);
        float _S477 = eta_i_1 * cos_theta_0;
        float _S478 = eta_o_1 * _S473;
        float _S479 = (_S477 - _S478) / (_S477 + _S478);
        float _S480 = (_S476 * _S476 + _S479 * _S479) / 2.0f;
        kr_0 = _S480;
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
    float _S481 = dot_0(ggx_n_0, v_5);
    float _S482 = eta_i_2 / eta_o_2;
    float3  _S483 = refract_0(in_dir_2, ggx_n_0, _S482);
    float3  _S484 = ((((_S483)) * make_float3(rnorm3df(((_S483)).x, ((_S483)).y, ((_S483)).z))));
    float _S485 = (F32_min(((F32_sqrt((material_4.specular_level))) * (F32_abs((eta_i_2 - eta_o_2))) / (eta_i_2 + eta_o_2)), (0.9999847412109375f)));
    float _S486 = _S485 * _S485;
    float _S487 = (1.0f + _S485) / (1.0f - _S485);
    float _S488 = (F32_abs((_S481)));
    bool _S489 = eta_i_2 > eta_o_2;
    float _S490 = _slang_select(_S489, _S487,1.0f);
    float _S491 = _slang_select(_S489, 1.0f,_S487);
    float _S492 = fresnel(_S488, _S490, _S491);
    bool _S493 = (eta_i_2 * eta_i_2 * (1.0f - _S481 * _S481)) >= (eta_o_2 * eta_o_2);
    float3  _S494 = material_4.specular_tint * make_float3 (_S486);
    float3  _S495 = _S494 + (make_float3 (1.0f) - _S494) * make_float3 (_S492 - _S486) / make_float3 (1.0f - _S486);
    float3  _S496 = make_float3 (1.0f);
    float3  _S497 = _slang_select(_S493, _S496,_S495);
    float3  _S498 = make_float3 (0.0f);
    float sheen_component_0;
    float3  sheen_1;
    float3  scale_1;
    if(sheen_profile_0.on)
    {
        float _S499 = (F32_min((sheen_profile_0.albedo), (1.0f)));
        float3  _S500 = make_float3 (1.0f) - material_4.sheen * make_float3 (_S499);
        float _S501 = rgb_to_greyscale(material_4.sheen);
        float _S502 = _S501 * _S499;
        float3  _S503 = material_4.sheen / make_float3 ((F32_max((sheen_profile_0.albedo), (1.0f))));
        sheen_component_0 = _S502;
        sheen_1 = _S503;
        scale_1 = _S500;
    }
    else
    {
        sheen_component_0 = 0.0f;
        sheen_1 = _S498;
        scale_1 = _S496;
    }
    float _S504 = (F32_abs((material_4.toon.x)));
    bool _S505 = _S504 > 0.0f;
    float toon_component_0;
    float3  toon_1;
    if(_S505)
    {
        float _S506 = (F32_min((_S504), (1.0f)));
        float3  scale_2 = scale_1 * make_float3 (1.0f - _S506);
        float _S507 = rgb_to_greyscale(material_4.albedo);
        float _S508 = _S506 * _S507;
        float3  _S509 = make_float3 (_S506) * material_4.albedo;
        toon_component_0 = _S508;
        toon_1 = _S509;
        scale_1 = scale_2;
    }
    else
    {
        toon_component_0 = 0.0f;
        toon_1 = _S498;
    }
    bool _S510 = (material_4.metallic) > 0.0f;
    float3  rebounce_0;
    if(_S510)
    {
        float _S511 = frame_2.alphas.x;
        float _S512 = (F32_sqrt(((F32_min((_S511), (frame_2.alphas.y))))));
        bool _S513 = _S511 > 0.0f;
        float _S514 = _slang_select(_S513, _S512,material_4.roughness);
        float _S515 = _S514 * _S514;
        float _S516 = (F32_pow((_S515), (1.81585001945495605f))) * (2.15371990203857422f - 0.73285001516342163f * _S515) / (1.0f + 1.28094995021820068f * _S515);
        bool _S517 = _S515 > 0.0f;
        float _S518 = _slang_select(_S517, _S516,0.0f);
        float _S519 = clamp_1(dot_0(n_i_4, v_5), 0.0f, 1.0f);
        float _S520 = _S515 * _S514;
        float _S521 = (F32_min((1.00064504146575928f - _S514 * (0.00375499995425344f + _S519 * (-0.04133399948477745f + _S519 * (-0.90938502550125122f + _S519 * 0.35275399684906006f))) - _S515 * (0.27602800726890564f + _S519 * (1.27023398876190186f + _S519 * 0.04740000143647194f)) - _S520 * (0.31452900171279907f - _S519 * 0.34830701351165771f) + _S520 * _S514 * 0.27229699492454529f), (1.0f)));
        float3  _S522 = min_1(make_float3 (1.0f) / (make_float3 (1.0f) - material_4.albedo * make_float3 (_S518)), make_float3 (1.0f / (F32_max((_S521), (0.0000152587890625f)))));
        rebounce_0 = _S522;
    }
    else
    {
        rebounce_0 = _S496;
    }
    float3  _S523 = mix_0(_S497, material_4.albedo * rebounce_0, material_4.metallic);
    float3  F_1 = _S523 * scale_1;
    float _S524 = rgb_to_greyscale(F_1);
    float _S525 = 1.0f - material_4.metallic;
    float3  _S526 = make_float3 (1.0f) - _S497;
    float3  _S527 = make_float3 ((1.0f - material_4.transmission) * _S525) * _S526 * scale_1;
    float3  _S528 = make_float3 (material_4.transmission * _S525) * _S526 * scale_1;
    float _S529 = (F32_max((_S524), (0.0f)));
    float _S530 = rgb_to_greyscale(_S527);
    float _S531 = (F32_max((_S530), (0.0f)));
    float _S532 = rgb_to_greyscale(_S528);
    float _S533 = sign_0(length_0(_S484));
    float _S534 = (F32_max((_S532 * _S533), (0.0f)));
    float _S535 = _S529 + _S531 + _S534 + toon_component_0;
    float _S536 = (F32_min((sheen_component_0), (1.0f)));
    bool _S537 = sheen_component_0 > 0.0f;
    bool _S538;
    if(_S537)
    {
        _S538 = !(_S535 > 0.0f);
    }
    else
    {
        _S538 = false;
    }
    float _S539 = _slang_select(_S538, 1.0f,_S536);
    float _S540 = (1.0f - _S539) / (F32_max((_S535), (0.0000152587890625f)));
    float _S541 = _S531 * _S540;
    float _S542 = _S529 * _S540;
    float _S543 = _S534 * _S540;
    return Weights_x24init_0(_S481, _S484, F_1, 1.0f, _S527, _S528, _S541, _S542, _S543, _S539, toon_component_0 * _S540, sheen_1, toon_1);
}

__device__ float translucentShare(BSDFMaterial material_5)
{
    float _S544 = rgb_to_greyscale(material_5.translucent);
    float _S545 = rgb_to_greyscale(material_5.albedo);
    float _S546 = _S544 / (_S545 + _S544);
    bool _S547 = _S544 > 0.0f;
    float _S548 = _slang_select(_S547, _S546,0.0f);
    return _S548;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float n_i_dot_v_0, BSDFMaterial material_6, Weights w_1)
{
    float _S549 = translucentShare(material_6);
    float _S550 = w_1.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S551 = w_1.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S552 = 1.0f - _S549;
    bool _S553 = n_i_dot_l_0 < 0.0f;
    float _S554 = _slang_select(_S553, _S549,_S552);
    float _S555 = _S551 * _S554;
    bool _S556 = _S549 > 0.0f;
    float _S557 = _slang_select(_S556, _S555,_S550);
    bool _S558 = n_i_dot_v_0 > 0.0f;
    float _S559 = _slang_select(_S558, _S557,0.0f);
    return _S559;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_5, BSDFMaterial material_7, Weights w_2)
{
    float _S560 = translucentShare(material_7);
    bool _S561 = (dot_0(n_i_5, l_0)) < 0.0f;
    float3  _S562 = _slang_select(_S561, material_7.translucent,material_7.albedo);
    float _S563 = 1.0f - _S560;
    float _S564 = _slang_select(_S561, _S560,_S563);
    float3  _S565 = _S562 / make_float3 (_S564);
    bool _S566 = _S560 > 0.0f;
    float3  _S567 = _slang_select(_S566, _S565,material_7.albedo);
    return w_2.diffuse_weight * _S567 / make_float3 (w_2.p_diffuse);
}

__device__ float smithG1(float alpha_3, float n_dot_x_0)
{
    float _S568 = alpha_3 * alpha_3;
    float _S569 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S568 + (1.0f - _S568) * n_dot_x_0 * n_dot_x_0))));
    bool _S570 = alpha_3 > 0.0f;
    float _S571 = _slang_select(_S570, _S569,1.0f);
    return _S571;
}

__device__ float trowbridgeReitz(float alpha_4, float n_dot_h_0)
{
    float _S572 = alpha_4 * alpha_4;
    float _S573 = (1.0f - n_dot_h_0) * (1.0f + n_dot_h_0) + _S572 * n_dot_h_0 * n_dot_h_0;
    return _S572 / (F32_max((3.14159274101257324f * _S573 * _S573), (1.17549435082228751e-38f)));
}

__device__ float anisotropicG1(float3  w_3, float2  alphas_1)
{
    float _S574 = (F32_max((w_3.z), (0.0f)));
    return 2.0f * _S574 / (_S574 + length_0(make_float3 (alphas_1.x * w_3.x, alphas_1.y * w_3.y, _S574)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_2)
{
    float _S575 = alphas_2.x;
    float _S576 = h_0.x / _S575;
    float _S577 = alphas_2.y;
    float _S578 = h_0.y / _S577;
    float _S579 = h_0.z;
    float _S580 = _S576 * _S576 + _S578 * _S578 + _S579 * _S579;
    return 1.0f / (F32_max((3.14159274101257324f * _S575 * _S577 * _S580 * _S580), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float3  v_6, float3  h_1, float3  n_i_6, float n_i_dot_v_1, float alpha_5, AnisotropicFrame frame_3, float v_dot_h_1)
{
    float _S581 = dot_0(n_i_6, h_1);
    float _S582 = smithG1(alpha_5, n_i_dot_v_1);
    float _S583 = _S582 * v_dot_h_1;
    float _S584 = trowbridgeReitz(alpha_5, _S581);
    float _S585 = _S583 * _S584 / n_i_dot_v_1;
    bool _S586 = alpha_5 > 0.0f;
    bool _S587;
    if(_S586)
    {
        _S587 = v_dot_h_1 > 0.0f;
    }
    else
    {
        _S587 = false;
    }
    if(_S587)
    {
        _S587 = _S581 > 0.0f;
    }
    else
    {
        _S587 = false;
    }
    if(_S587)
    {
        _S587 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S587 = false;
    }
    float _S588 = _slang_select(_S587, _S585,0.0f);
    bool _S589 = (frame_3.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S589)
    {
        float3  _S590 = anisotropicLocal(v_6, frame_3.tangent, n_i_6);
        float _S591 = anisotropicG1(_S590, frame_3.alphas);
        float3  _S592 = anisotropicLocal(h_1, frame_3.tangent, n_i_6);
        float _S593 = anisotropicD(_S592, frame_3.alphas);
        float _S594 = _S591 * _S593;
        float _S595 = _S594 * v_dot_h_1 / n_i_dot_v_1;
        bool _S596 = v_dot_h_1 > 0.0f;
        if(_S596)
        {
            _S587 = _S581 > 0.0f;
        }
        else
        {
            _S587 = false;
        }
        if(_S587)
        {
            _S587 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S587 = false;
        }
        float _S597 = _slang_select(_S587, _S595,0.0f);
        pdf_h_0 = _S597;
    }
    else
    {
        pdf_h_0 = _S588;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float l_dot_h_0, float pdf_h_1, Weights w_4, float eta_i_3, float eta_o_3)
{
    float _S598 = eta_i_3 * w_4.v_dot_h + eta_o_3 * l_dot_h_0;
    float _S599 = w_4.p_refract * pdf_h_1 * eta_o_3 * eta_o_3 * (F32_abs((l_dot_h_0))) / (_S598 * _S598);
    bool _S600 = eta_i_3 != eta_o_3;
    bool _S601;
    if(_S600)
    {
        _S601 = l_dot_h_0 < 0.0f;
    }
    else
    {
        _S601 = false;
    }
    float _S602 = _slang_select(_S601, _S599,0.0f);
    return _S602;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_7, float alpha_6, AnisotropicFrame frame_4, BSDFMaterial material_8, Weights w_5)
{
    float _S603 = - dot_0(n_i_7, l_1);
    float _S604 = smithG1(alpha_6, (F32_max((_S603), (0.0f))));
    bool _S605 = (frame_4.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S605)
    {
        float3  _S606 = negate_0(n_i_7);
        float3  _S607 = anisotropicLocal(l_1, frame_4.tangent, _S606);
        float _S608 = anisotropicG1(_S607, frame_4.alphas);
        G1_l_0 = _S608;
    }
    else
    {
        G1_l_0 = _S604;
    }
    bool _S609 = (material_8.ior) == 1.0f;
    float _S610 = _slang_select(_S609, 1.0f,G1_l_0);
    return w_5.refract_weight * make_float3 (_S610) * material_8.albedo / make_float3 (w_5.p_refract);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_1, float n_i_dot_v_2, Weights w_6)
{
    float _S611 = w_6.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S612 = n_i_dot_l_1 > 0.0f;
    bool _S613;
    if(_S612)
    {
        _S613 = n_i_dot_v_2 > 0.0f;
    }
    else
    {
        _S613 = false;
    }
    float _S614 = _slang_select(_S613, _S611,0.0f);
    return _S614;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  v_7, float3  n_i_8, BSDFMaterial material_9, Weights w_7)
{
    float3  _S615 = l_2 + v_7;
    float3  _S616 = ((((_S615)) * make_float3(rnorm3df(((_S615)).x, ((_S615)).y, ((_S615)).z))));
    float _S617 = dot_0(n_i_8, _S616);
    float _S618 = (F32_max((dot_0(n_i_8, l_2)), (0.0f)));
    float _S619 = (F32_max((dot_0(n_i_8, v_7)), (0.0f)));
    float _S620 = 1.0f / (F32_max((material_9.sheen_roughness), (0.05000000074505806f)));
    float _S621 = 1.0f - _S617 * _S617;
    float _S622 = (2.0f + _S620) * (F32_pow(((F32_max((_S621), (0.0f)))), (0.5f * _S620))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S618 + _S619 - _S618 * _S619)), (0.0000152587890625f)));
    bool _S623 = (material_9.velvet) > 0.0f;
    float f_1;
    if(_S623)
    {
        float _S624 = (F32_max((material_9.sheen_roughness), (0.00999999977648258f)));
        float _S625 = _S624 * _S624;
        float _S626 = (F32_max((_S621), (0.0000152587890625f)));
        float _S627 = (F32_exp((- _S617 * _S617 / (_S626 * _S625)))) / (3.14159274101257324f * _S625 * _S626 * _S626) * (F32_min((1.0f), (2.0f * _S617 * (F32_min((_S618), (_S619))) / (F32_max(((F32_abs((dot_0(_S616, v_7))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S618 * _S619), (0.0000152587890625f)));
        f_1 = _S627;
    }
    else
    {
        f_1 = _S622;
    }
    return w_7.sheen * make_float3 (f_1 * _S618 * 2.0f * 3.14159274101257324f / w_7.p_sheen_velvet);
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
    float _S628 = (F32_max((1.0f - (t_13 - a_5) / (F32_max((s_0), (0.0000152587890625f)))), (0.0f)));
    bool _S629 = t_13 < a_5;
    float _S630 = _slang_select(_S629, 1.0f,_S628);
    return _S630;
}

__device__ __forceinline__ float toonIntegral(float t_14, float a_6, float s_1, bool glossy_0)
{
    float _S631 = (F32_min((t_14), (a_6)));
    float _S632 = (F32_sin((_S631)));
    float _S633 = _S632 * _S632 / 2.0f;
    float _S634 = 1.0f - (F32_cos((_S631)));
    float _S635 = _slang_select(glossy_0, _S634,_S633);
    bool _S636 = t_14 > a_6;
    bool _S637;
    if(_S636)
    {
        _S637 = s_1 > 0.0f;
    }
    else
    {
        _S637 = false;
    }
    float integral_0;
    if(_S637)
    {
        if(glossy_0)
        {
            float _S638 = (F32_cos((a_6)));
            float _S639 = (F32_cos((t_14)));
            integral_0 = (1.0f + a_6 / s_1) * (_S638 - _S639) - ((F32_sin((t_14))) - t_14 * _S639 - ((F32_sin((a_6))) - a_6 * _S638)) / s_1;
        }
        else
        {
            float _S640 = 2.0f * a_6;
            float _S641 = (F32_cos((_S640)));
            float _S642 = 2.0f * t_14;
            float _S643 = (F32_cos((_S642)));
            integral_0 = (1.0f + a_6 / s_1) * (_S641 - _S643) / 4.0f - ((F32_sin((_S642))) / 8.0f - t_14 * _S643 / 4.0f - ((F32_sin((_S640))) / 8.0f - a_6 * _S641 / 4.0f)) / s_1;
        }
        float integral_1 = _S635 + integral_0;
        integral_0 = integral_1;
    }
    else
    {
        integral_0 = _S635;
    }
    return integral_0;
}

static __device__ ToonProfile ToonProfile_x24init_0(bool glossy_1, float a_7, float s_2, float b_1, float norm_0, float view_0, float3  axis_0)
{
    ToonProfile _S644;
    (&_S644)->glossy = glossy_1;
    (&_S644)->a = a_7;
    (&_S644)->s = s_2;
    (&_S644)->b = b_1;
    (&_S644)->norm = norm_0;
    (&_S644)->view = view_0;
    (&_S644)->axis = axis_0;
    return _S644;
}

__device__ __forceinline__ ToonProfile toonProfile(float3  v_8, float3  n_i_9, BSDFMaterial material_10)
{
    float _S645 = material_10.toon.x;
    bool _S646 = _S645 < 0.0f;
    float _S647 = clamp_1(material_10.toon.y / _S645, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S648 = clamp_1(material_10.toon.z / _S645, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S649 = (F32_min((_S647 + _S648), (1.57079637050628662f)));
    float _S650 = dot_0(n_i_9, v_8);
    float _S651 = toonP((F32_acos(((F32_min((_S650), (1.0f)))))), _S647, _S648);
    float3  _S652 = make_float3 (2.0f * _S650) * n_i_9 - v_8;
    float3  _S653 = ((((_S652)) * make_float3(rnorm3df(((_S652)).x, ((_S652)).y, ((_S652)).z))));
    float3  _S654 = _slang_select(_S646, _S653,n_i_9);
    float _S655 = toonIntegral(_S649, _S647, _S648, _S646);
    return ToonProfile_x24init_0(_S646, _S647, _S648, _S649, 6.28318548202514648f * _S655, _S651, _S654);
}

__device__ __forceinline__ float toonPDF(float3  l_3, float3  n_i_10, ToonProfile profile_1, Weights w_8)
{
    float _S656 = dot_0(n_i_10, l_3);
    float _S657 = dot_0(l_3, profile_1.axis);
    float _S658 = _slang_select(profile_1.glossy, _S657,_S656);
    float _S659 = (F32_acos((clamp_1(_S658, -1.0f, 1.0f))));
    float _S660 = toonP(_S659, profile_1.a, profile_1.s);
    float _S661 = w_8.p_toon * _S660;
    float _S662 = _slang_select(profile_1.glossy, 1.0f,_S656);
    float _S663 = _S661 * _S662 / profile_1.norm;
    bool _S664;
    if(profile_1.glossy)
    {
        _S664 = true;
    }
    else
    {
        _S664 = _S656 > 0.0f;
    }
    float _S665 = _slang_select(_S664, _S663,0.0f);
    return _S665;
}

__device__ __forceinline__ float3  toonBSDF(float3  l_4, float3  n_i_11, ToonProfile profile_2, Weights w_9)
{
    float _S666 = (F32_max((dot_0(n_i_11, l_4)), (0.0f)));
    float _S667 = _slang_select(profile_2.glossy, _S666,profile_2.view);
    return w_9.toon * make_float3 (_S667) / make_float3 (w_9.p_toon);
}

__device__ __forceinline__ float reflectPDF(float pdf_h_2, Weights w_10)
{
    float _S668 = w_10.p_reflect * pdf_h_2 / (4.0f * w_10.v_dot_h);
    bool _S669 = pdf_h_2 > 0.0f;
    float _S670 = _slang_select(_S669, _S668,0.0f);
    return _S670;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_5, float3  n_i_12, float alpha_7, AnisotropicFrame frame_5, Weights w_11)
{
    float _S671 = dot_0(n_i_12, l_5);
    float _S672 = smithG1(alpha_7, (F32_max((_S671), (0.0f))));
    bool _S673 = (frame_5.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S673)
    {
        float3  _S674 = anisotropicLocal(l_5, frame_5.tangent, n_i_12);
        float _S675 = anisotropicG1(_S674, frame_5.alphas);
        G1_l_1 = _S675;
    }
    else
    {
        G1_l_1 = _S672;
    }
    return make_float3 (w_11.reflect_weight * G1_l_1) * w_11.F / make_float3 (w_11.p_reflect);
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_3, float3  out_dir_2, float3  n_6, BSDFMaterial material_11, float eta_i_4, float eta_o_4, bool refracted_2, uint random_state_4, FixedArray<float3 , 5>  * throughputs_0, FixedArray<float, 5>  * pdfs_0)
{
    float3  ggx_n_1;
    float3  _S676 = negate_0(in_dir_3);
    float _S677 = dot_0(n_6, _S676);
    float _S678 = sign_0(_S677);
    float3  _S679 = n_6 * make_float3 (_S678);
    float _S680 = dot_0(_S679, out_dir_2);
    float _S681 = material_11.roughness;
    float _S682 = _S681 * _S681;
    AnisotropicFrame _S683 = anisotropicFrame(material_11, _S679);
    SheenProfile _S684 = sheenProfile(_S676, _S679, material_11);
    float _S685 = rgb_to_greyscale(material_11.translucent);
    bool _S686 = _S685 > 0.0f;
    bool _S687 = (dot_0(n_6, out_dir_2) * _S677) < 0.0f;
    bool _S688 = (F32_abs((material_11.toon.x))) > 0.0f;
    uint _S689;
    if(_S688)
    {
        _S689 = 5U;
    }
    else
    {
        _S689 = 4U;
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
        float3  _S690 = make_float3 (0.0f);
        (*throughputs_0)[i_7] = _S690;
        (*pdfs_0)[i_7] = 0.0f;
        uint i_8 = i_7 + 1U;
        i_7 = i_8;
    }
    float3  _S691 = make_float3 (0.0f);
    Weights _S692 = Weights_x24init_0(0.0f, _S691, _S691, 0.0f, _S691, _S691, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, _S691, _S691);
    uint half_of_0 = 4294967295U;
    Weights w_12 = _S692;
    float3  ggx_n_2 = _S691;
    i_7 = 0U;
    for(;;)
    {
        if(i_7 < _S689)
        {
        }
        else
        {
            break;
        }
        uint _S693;
        if(i_7 == 3U)
        {
            _S693 = 4U;
        }
        else
        {
            if(i_7 == 4U)
            {
                _S693 = 6U;
            }
            else
            {
                _S693 = i_7;
            }
        }
        bool _S694 = _S693 == 0U;
        bool _S695;
        if(_S694)
        {
            _S695 = _S686;
        }
        else
        {
            _S695 = false;
        }
        bool _S696;
        if(_S695)
        {
            _S696 = _S687;
        }
        else
        {
            _S696 = _S693 == 1U;
        }
        bool _S697 = _S696 != refracted_2;
        if(_S697)
        {
            ggx_n_1 = ggx_n_2;
            uint i_9 = i_7 + 1U;
            ggx_n_2 = ggx_n_1;
            i_7 = i_9;
            continue;
        }
        uint _S698;
        if(_S693 == 6U)
        {
            _S698 = 0U;
        }
        else
        {
            if(_S693 == 4U)
            {
                _S698 = 2U;
            }
            else
            {
                _S698 = _S693;
            }
        }
        bool _S699 = _S698 != half_of_0;
        uint half_of_1;
        Weights w_13;
        if(_S699)
        {
            bool _S700 = _S698 == 0U;
            if(_S700)
            {
                float3  _S701 = sampledHalf(_S676, _S679, _S682, _S683, random_state_4);
                ggx_n_1 = _S701;
            }
            else
            {
                bool _S702 = _S698 == 1U;
                if(_S702)
                {
                    float3  _S703 = refractedHalf(in_dir_3, out_dir_2, n_6, eta_i_4, eta_o_4);
                    ggx_n_1 = _S703;
                }
                else
                {
                    float3  _S704 = reflectedHalf(in_dir_3, out_dir_2);
                    ggx_n_1 = _S704;
                }
            }
            Weights _S705 = lobeWeights(in_dir_3, _S676, _S679, ggx_n_1, _S683, _S684, material_11, eta_i_4, eta_o_4);
            w_13 = _S705;
            half_of_1 = _S698;
        }
        else
        {
            w_13 = w_12;
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S693)
        {
        case 0U:
            {
                float _S706 = diffusePDF(_S680, (F32_abs((_S677))), material_11, w_13);
                (*pdfs_0)[int(0)] = _S706;
                float3  _S707 = diffuseBSDF(out_dir_2, _S679, material_11, w_13);
                (*throughputs_0)[int(0)] = _S707;
                break;
            }
        case 1U:
            {
                float _S708 = dot_0(out_dir_2, ggx_n_1);
                float _S709 = vndfPDF(_S676, ggx_n_1, _S679, (F32_abs((_S677))), _S682, _S683, w_13.v_dot_h);
                float _S710 = refractPDF(_S708, _S709, w_13, eta_i_4, eta_o_4);
                (*pdfs_0)[int(1)] = _S710;
                float3  _S711 = refractBSDF(out_dir_2, _S679, _S682, _S683, material_11, w_13);
                (*throughputs_0)[int(1)] = _S711;
                break;
            }
        case 4U:
            {
                float _S712 = sheenVelvetPDF(_S680, (F32_abs((_S677))), w_13);
                (*pdfs_0)[int(3)] = _S712;
                float3  _S713 = sheenVelvetBSDF(out_dir_2, _S676, _S679, material_11, w_13);
                (*throughputs_0)[int(3)] = _S713;
                break;
            }
        case 6U:
            {
                ToonProfile _S714 = toonProfile(_S676, _S679, material_11);
                float _S715 = toonPDF(out_dir_2, _S679, _S714, w_13);
                (*pdfs_0)[int(4)] = _S715;
                float3  _S716 = toonBSDF(out_dir_2, _S679, _S714, w_13);
                (*throughputs_0)[int(4)] = _S716;
                break;
            }
        default:
            {
                float _S717 = vndfPDF(_S676, ggx_n_1, _S679, (F32_abs((_S677))), _S682, _S683, w_13.v_dot_h);
                float _S718 = reflectPDF(_S717, w_13);
                (*pdfs_0)[int(2)] = _S718;
                float3  _S719 = reflectBSDF(out_dir_2, _S679, _S682, _S683, w_13);
                (*throughputs_0)[int(2)] = _S719;
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
    ggx_n_1 = _S691;
    for(;;)
    {
        if(i_7 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S720 = ((*pdfs_0)[i_7]) > 0.0f;
        if(_S720)
        {
            float3  f_2 = ggx_n_1 + (*throughputs_0)[i_7] * make_float3 ((*pdfs_0)[i_7]);
            ggx_n_1 = f_2;
        }
        uint i_10 = i_7 + 1U;
        i_7 = i_10;
    }
    return ggx_n_1;
}

static __device__ __forceinline__ float3  skyLobes_0(float3  in_dir_4, float3  dir_5, FKSurface * surface_1, BSDFMaterial * material_12, float2  eta_1, bool is_inside_2, float pdf_1, uint random_state_5, FixedArray<float3 , 5>  * terms_0, FixedArray<float, 5>  * pdfs_1)
{
    bool _S721 = wrongSide_0(is_inside_2, false, dir_5, surface_1->geometry_n);
    float3  _S722 = BSDF(in_dir_4, dir_5, surface_1->smooth_n, *material_12, eta_1.x, eta_1.y, _S721, random_state_5, terms_0, pdfs_1);
    float3  _S723 = make_float3 (0.0f);
    uint i_11 = 0U;
    float3  f_3 = _S723;
    for(;;)
    {
        if(i_11 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S724 = ((*pdfs_1)[i_11]) > 0.0f;
        if(_S724)
        {
            float3  _S725 = (*terms_0)[i_11] * make_float3 ((*pdfs_1)[i_11]) / make_float3 ((*pdfs_1)[i_11] + pdf_1);
            (*terms_0)[i_11] = _S725;
            float3  f_4 = f_3 + (*terms_0)[i_11];
            f_3 = f_4;
        }
        uint i_12 = i_11 + 1U;
        i_11 = i_12;
    }
    return f_3;
}

__device__ float3  skyBSDF(float3  in_dir_5, float3  dir_6, FKSurface surface_2, BSDFMaterial material_13, float2  eta_2, bool is_inside_3, float pdf_2, uint random_state_6)
{
    FKSurface _S726 = surface_2;
    BSDFMaterial _S727 = material_13;
    FixedArray<float3 , 5>  terms_1;
    FixedArray<float, 5>  pdfs_2;
    float3  _S728 = skyLobes_0(in_dir_5, dir_6, &_S726, &_S727, eta_2, is_inside_3, pdf_2, random_state_6, &terms_1, &pdfs_2);
    return _S728;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_7, float3  radiance_0, float3  color_0, uint random_state_7)
{
    SkySample _S729;
    (&_S729)->dir = dir_7;
    (&_S729)->radiance = radiance_0;
    (&_S729)->color = color_0;
    (&_S729)->random_state = random_state_7;
    return _S729;
}

static __device__ __noinline__ float3  skyColor_0(float3  in_dir_6, float3  dir_8, FKSurface * surface_3, float wavelength_3, float2  eta_3, bool is_inside_4, float pdf_3, uint random_state_8, uint depth_1)
{
    BSDFMaterial _S730 = pathMaterial(surface_3->material, wavelength_3);
    BSDFMaterial _S731 = _S730;
    FixedArray<float3 , 5>  terms_2;
    FixedArray<float, 5>  pdfs_3;
    float3  _S732 = skyLobes_0(in_dir_6, dir_8, surface_3, &_S731, eta_3, is_inside_4, pdf_3, random_state_8, &terms_2, &pdfs_3);
    float3  _S733 = make_float3 (0.0f);
    bool shaded_0 = false;
    float3  world_0 = _S733;
    uint i_13 = 0U;
    float3  color_1 = _S733;
    for(;;)
    {
        if(i_13 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S734 = (pdfs_3[i_13]) > 0.0f;
        if(_S734)
        {
            bool _S735 = (fcptWorldReadsPath());
            bool _S736;
            if(_S735)
            {
                _S736 = true;
            }
            else
            {
                _S736 = !shaded_0;
            }
            bool shaded_1;
            float3  world_1;
            if(_S736)
            {
                uint _S737;
                if(i_13 == 3U)
                {
                    _S737 = 4U;
                }
                else
                {
                    if(i_13 == 4U)
                    {
                        _S737 = 6U;
                    }
                    else
                    {
                        _S737 = i_13;
                    }
                }
                float3  _S738 = (fcptEnvMapSample((dir_8), (depth_1), (_S737)));
                world_1 = _S738;
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
    uint2  _S739 = (fcptEnvironmentCdfSize());
    uint2  _S740 = make_uint2 (1U, 0U);
    uint2  _S741 = _S739 - _S740;
    Random _S742 = draw(init_random_state_0, 6U);
    Random _S743 = draw(init_random_state_0, 2147483654U);
    Random _S744 = draw(init_random_state_0, 7U);
    Random _S745 = draw(init_random_state_0, 2147483655U);
    uint _S746 = _S741.x;
    uint _S747 = searchCDF_0(make_uint2 (_S746, 0U), make_uint2 (0U, 1U), _S741.y, _S742.value);
    uint _S748 = searchCDF_0(make_uint2 (0U, _S747), _S740, _S746, _S743.value);
    float2  _S749 = make_float2 ((float)_S741.x, (float)_S741.y);
    float2  _S750 = (make_float2 (float(_S748), float(_S747)) + make_float2 (_S744.value, _S745.value)) / _S749 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S751 = _S750.y;
    float _S752 = (F32_sin((_S751)));
    float _S753 = _S750.x;
    float3  _S754 = make_float3 (- _S752 * (F32_cos((_S753))), _S752 * (F32_sin((_S753))), (F32_cos((_S751))));
    float _S755 = environmentPdf_0(_S754);
    BSDFMaterial _S756 = pathMaterial(surface_4->material, wavelength_4);
    float3  _S757 = ray_0->unit_direction;
    float3  _S758 = skyBSDF(ray_0->unit_direction, _S754, *surface_4, _S756, eta_4, is_inside_5, _S755, lobe_state_0);
    bool _S759 = !(_S755 > 0.0f);
    bool _S760;
    if(_S759)
    {
        _S760 = true;
    }
    else
    {
        _S760 = all_1(_S758 == make_float3 (0.0f));
    }
    if(_S760)
    {
        float3  _S761 = make_float3 (0.0f);
        return SkySample_x24init_0(_S754, _S761, _S761, _S745.state);
    }
    bool _S762 = (fcptWorldReadsPath());
    float3  seen_0;
    if(_S762)
    {
        float3  _S763 = skyColor_0(_S757, _S754, surface_4, wavelength_4, eta_4, is_inside_5, _S755, lobe_state_0, context_2->depth + 1U);
        seen_0 = _S763;
    }
    else
    {
        seen_0 = _S758;
    }
    float3  _S764 = skyRadiance_0(ray_0->origin, surface_4, is_inside_5, _S754, context_2, _S745.state);
    return SkySample_x24init_0(_S754, _S764, seen_0 * _S764, _S745.state);
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
    SampleBSDF _S765 = (fcptConnectHair((surface_5->hair), ((&surface_5->material)->albedo), ((&surface_5->material)->specular_tint), (in_dir_7), (light_1->dir)));
    float3  _S766 = _S765.throughput * make_float3 (_S765.pdf);
    float _S767 = light_1->density;
    float _S768 = 1.0f + _S765.pdf * _S765.pdf / (light_1->density * light_1->density);
    bool _S769;
    if(competing_0)
    {
        _S769 = _S767 > 0.0f;
    }
    else
    {
        _S769 = false;
    }
    float _S770 = _slang_select(_S769, _S768,1.0f);
    return _S766 / make_float3 (_S770) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_9, float3  radiance_1, float density_0, uint random_state_9)
{
    TreeSample _S771;
    (&_S771)->dir = dir_9;
    (&_S771)->radiance = radiance_1;
    (&_S771)->density = density_0;
    (&_S771)->random_state = random_state_9;
    return _S771;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_12, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S772 = importance(first_1, p_12, normal_3);
    float _S773 = importance(second_1, p_12, normal_3);
    float2  _S774 = make_float2 (_S772, _S773);
    bool _S775 = _S772 == 0.0f;
    bool _S776;
    if(_S775)
    {
        _S776 = _S773 == 0.0f;
    }
    else
    {
        _S776 = false;
    }
    if(_S776)
    {
        return 2U;
    }
    float _S777 = _S772 + _S773;
    bool _S778 = _S773 > 0.0f;
    if(_S778)
    {
        _S776 = (*pick_0 * _S777) >= _S772;
    }
    else
    {
        _S776 = false;
    }
    uint _S779 = uint(_S776);
    float _S780 = (F32_min(((*pick_0 * _S777 - float(_S779) * _S772) / _slang_vector_get_element(_S774, _S779)), (0.99999994039535522f)));
    *pick_0 = _S780;
    float _S781 = *probability_3 * (_slang_vector_get_element(_S774, _S779) / _S777);
    *probability_3 = _S781;
    return _S779;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_13, float u1_0, float u2_0)
{
    float3  _S782 = center_1 - p_13;
    float _S783 = radius_1 * radius_1 / dot_0(_S782, _S782);
    float _S784 = u1_0 * _S783 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S783), (0.0f)))))));
    float _S785 = 2.0f * u1_0;
    bool _S786 = _S783 >= 1.0f;
    float _S787 = _slang_select(_S786, _S785,_S784);
    float _S788 = (F32_sqrt(((F32_max((_S787 * (2.0f - _S787)), (0.0f))))));
    float _S789 = 6.28318548202514648f * u2_0;
    float3  _S790 = make_float3 (_S788 * (F32_cos((_S789))), 1.0f - _S787, _S788 * (F32_sin((_S789))));
    float3  _S791 = ((((_S782)) * make_float3(rnorm3df(((_S782)).x, ((_S782)).y, ((_S782)).z))));
    float3  _S792 = tangentToWorld(_S790, _S791);
    return _S792;
}

__device__ float3  pointLightRadiance(float3  color_3, float intensity_0, float radius_2)
{
    return color_3 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S793 = center_2 - ray_1->origin;
    float _S794 = dot_0(_S793, ray_1->unit_direction);
    float _S795 = dot_0(_S793, _S793) - _S794 * _S794;
    float _S796 = radius_3 * radius_3;
    bool _S797 = _S795 > _S796;
    if(_S797)
    {
        return 4.294967296e+09f;
    }
    float _S798 = (F32_sqrt((_S796 - _S795)));
    float _S799 = _S794 - _S798;
    float _S800 = _S794 + _S798;
    bool _S801 = _S799 > 0.0000152587890625f;
    bool _S802;
    if(_S801)
    {
        _S802 = _S799 < max_len_0;
    }
    else
    {
        _S802 = false;
    }
    if(_S802)
    {
        return _S799;
    }
    bool _S803 = _S800 > 0.0000152587890625f;
    if(_S803)
    {
        _S802 = _S800 < max_len_0;
    }
    else
    {
        _S802 = false;
    }
    if(_S802)
    {
        return _S800;
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
    Random _S804 = draw(init_random_state_1, 4U);
    Random _S805 = draw(init_random_state_1, 5U);
    Random _S806 = draw(init_random_state_1, 2147483653U);
    float3  _S807 = make_float3 (0.0f);
    TreeSample _S808 = TreeSample_x24init_0(_S807, _S807, 0.0f, _S806.state);
    TreeSample sample_0 = _S808;
    float3  _S809 = _slang_select(sided_0, _S807,smooth_n_2);
    float3  _S810 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S804.value;
    float probability_4 = 1.0f;
    uint n_7 = 0U;
    for(;;)
    {
        uint4  _S811 = (fcptLightNode((n_7)));
        if((_S811.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S812 = (fcptLightSecond((n_7)));
        uint _S813 = n_7 + 1U;
        LightNode _S814 = (fcptLightBounds((_S813)));
        LightNode _S815 = (fcptLightBounds((_S812)));
        uint _S816 = pickChild(_S814, _S815, origin_4, _S809, &pick_1, &probability_4);
        bool _S817 = _S816 > 1U;
        if(_S817)
        {
            return sample_0;
        }
        bool _S818 = _S816 == 1U;
        uint _S819 = _slang_select(_S818, _S812,_S813);
        n_7 = _S819;
    }
    bool _S820 = n_7 == 0U;
    bool _S821;
    if(_S820)
    {
        LightNode _S822 = (fcptLightBounds((0U)));
        float _S823 = importance(_S822, origin_4, _S809);
        _S821 = !(_S823 > 0.0f);
    }
    else
    {
        _S821 = false;
    }
    if(_S821)
    {
        return sample_0;
    }
    uint4  _S824 = (fcptLightNode((n_7)));
    FKHit _S825 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S826 = (_S824.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S826)
    {
        FKLight _S827 = (fcptLight((_S824.y)));
        if(sided_0)
        {
            float _S828 = sign_0(dot_0(geometry_n_1, _S827.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S828);
            float3  _S829 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S829;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S810;
            lift_n_0 = smooth_n_2;
        }
        bool _S830 = (_S827.variance) == 0.0f;
        if(_S830)
        {
            float3  _S831 = _S827.position - emitter_point_0;
            float3  _S832 = ((((_S831)) * make_float3(rnorm3df(((_S831)).x, ((_S831)).y, ((_S831)).z))));
            (&sample_0)->dir = _S832;
            float3  _S833 = _S827.color * make_float3 (_S827.intensity) / make_float3 (dot_0(_S831, _S831) * probability_4);
            (&sample_0)->radiance = _S833;
            shadow_1 = _S831;
        }
        else
        {
            float3  _S834 = sampleSphere(_S827.position, _S827.variance, emitter_point_0, _S805.value, _S806.value);
            (&sample_0)->dir = _S834;
            float _S835 = sphereDensity(_S827.position, _S827.variance, emitter_point_0);
            float _S836 = probability_4 * _S835;
            (&sample_0)->density = _S836;
            float3  _S837 = pointLightRadiance(_S827.color, _S827.intensity, _S827.variance);
            float3  _S838 = _S837 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S838;
            FKRay _S839 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S840 = raySphere_0(_S827.position, _S827.variance, &_S839, 4.294967296e+09f);
            float3  _S841 = (&sample_0)->dir * make_float3 (_S840);
            shadow_1 = _S841;
        }
        emitter_0 = _S825;
        emitter_point_0 = _S807;
    }
    else
    {
        uint _S842 = _S824.y;
        uint _S843 = (fcptTriangleOffset((_S842)));
        uint _S844 = _S843 + _S824.z;
        Matrix<float, 3, 3>  _S845 = (fcptWorldTriangle((_S842), (_S844)));
        float _S846 = (F32_sqrt((_S805.value)));
        float2  _S847 = make_float2 (_S846 * (1.0f - _S806.value), _S846 * _S806.value);
        float3  _S848 = mul_0(make_float3 (1.0f - _S846, _S847.x, _S847.y), _S845);
        if(sided_0)
        {
            float _S849 = sign_0(dot_0(geometry_n_1, _S848 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S849);
            float3  _S850 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S850;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S851 = !((dot_0(smooth_n_2, _S848 - origin_4)) > 0.0f);
            if(_S851)
            {
                return sample_0;
            }
            emitter_point_0 = _S810;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S847, _S842, _S844, 0U, 0.0f);
        float3  _S852 = _S848 - emitter_point_0;
        float3  _S853 = ((((_S852)) * make_float3(rnorm3df(((_S852)).x, ((_S852)).y, ((_S852)).z))));
        (&sample_0)->dir = _S853;
        float _S854 = solidAngle(probability_4, cross_0(_S845.rows[int(1)] - _S845.rows[int(0)], _S845.rows[int(2)] - _S845.rows[int(0)]), _S852);
        (&sample_0)->density = _S854;
        bool _S855 = (fcptShadowFirst());
        bool _S856 = !_S855;
        if(_S856)
        {
            FKSurface _S857 = (fcptLightSurfaceAt((emitter_1), (_S848), (_S806.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S848 - origin_4))));
            (&sample_0)->random_state = _S857.random_state;
            float3  _S858 = _slang_select(_S857.skip, _S807,_S857.material.emissive);
            float3  _S859 = _S858 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S859;
        }
        shadow_1 = _S852;
        emitter_0 = emitter_1;
        emitter_point_0 = _S848;
    }
    FKHit _S860 = emitter_0;
    float3  _S861 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S806.state, &_S860);
    bool _S862 = (fcptShadowFirst());
    if(_S862)
    {
        _S821 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S821 = false;
    }
    if(_S821)
    {
        _S821 = !all_1(_S861 == _S807);
    }
    else
    {
        _S821 = false;
    }
    if(_S821)
    {
        FKSurface _S863 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S806.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S863.random_state;
        float3  _S864 = _slang_select(_S863.skip, _S807,_S863.material.emissive);
        float3  _S865 = _S864 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S865;
    }
    float3  _S866 = (&sample_0)->radiance * _S861;
    bool _S867 = all_1(_S861 == _S807);
    float3  _S868 = _slang_select(_S867, _S807,_S866);
    (&sample_0)->radiance = _S868;
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
    float _S869 = 1.0f / (1.0f + b_2 / a_8 * (b_2 / a_8));
    bool _S870 = b_2 > 0.0f;
    float _S871 = _slang_select(_S870, _S869,1.0f);
    return _S871;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S872 = vertex_0->none;
    if(_S872)
    {
        return 1.0f;
    }
    uint _S873 = (fcptLightSlot((*hit_1)));
    float _S874 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S873, light_point_1);
    float _S875 = powerHeuristic(vertex_0->pdf, _S874);
    return _S875;
}

struct Vertex
{
    bool rough;
    uint lobe;
    float pdf;
    float cos;
    bool inside;
};

__device__ float3  pathColor(float3  f_5, float3  weight_0, float wavelength_5)
{
    float _S876 = upsample(f_5, wavelength_5);
    float3  _S877 = weight_0 * make_float3 (_S876);
    bool _S878 = wavelength_5 > 0.0f;
    float3  _S879 = _slang_select(_S878, _S877,f_5);
    return _S879;
}

__device__ float3  safeDivide(float3  a_9, float3  b_3)
{
    float3  _S880 = a_9 / b_3;
    float3  _S881 = make_float3 (0.0f);
    bool3  _S882 = b_3 == _S881;
    float3  _S883 = _slang_select(_S882, _S881,_S880);
    return _S883;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_2)
{
    uint _S884 = (1U << count_2) - 1U;
    return (e_2 & (~(_S884 << offset_1))) | ((newbits_0 & _S884) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_3, uint end_type_0, uint end_0, float3  f_6)
{
    Reservoir candidate_0 = r_3;
    uint _S885 = insertBits_0(r_3.path, end_0, 0U, 5U);
    uint _S886 = insertBits_0(_S885, end_type_0, 12U, 3U);
    (&candidate_0)->path = _S886;
    (&candidate_0)->f = f_6;
    return candidate_0;
}

static __device__ float3  abs_0(float3  x_16)
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
        *_slang_vector_get_element_ptr(&result_7, i_16) = (F32_abs((_slang_vector_get_element(x_16, i_16))));
        i_16 = i_16 + int(1);
    }
    return result_7;
}

__device__ float resamplingTarget(float3  f_7)
{
    float _S887 = rgb_to_greyscale(abs_0(f_7));
    return _S887;
}

__device__ void offer(Selection * sel_2, Reservoir candidate_1, float3  weight_1)
{
    float _S888 = resamplingTarget(weight_1);
    bool _S889 = _S888 > 0.0f;
    bool _S890;
    if(_S889)
    {
        _S890 = _S888 < 3.00000000549775576e+38f;
    }
    else
    {
        _S890 = false;
    }
    bool _S891 = !_S890;
    if(_S891)
    {
        return;
    }
    bool _S892 = sel_2->sums;
    if(_S892)
    {
        float3  _S893 = sel_2->color + weight_1;
        sel_2->color = _S893;
        return;
    }
    float _S894 = sel_2->w_sum + _S888;
    sel_2->w_sum = _S894;
    float3  _S895 = sel_2->color + weight_1;
    sel_2->color = _S895;
    Random _S896 = pcg(sel_2->random_state);
    sel_2->random_state = _S896.state;
    bool _S897 = (_S896.value * sel_2->w_sum) <= _S888;
    if(_S897)
    {
        sel_2->r = candidate_1;
    }
    return;
}

static __device__ Shift escape_0(Reservoir * r_4, bool replay_1, uint stop_0, uint rc_0, uint end_1, uint end_type_1, float scale_3, uint strata_0, Reservoir * chain_0, float3  chain_throughput_0, uint b_4, FKRay * ray_2, float3  throughput_0, float density_1, Vertex * prev_0, NEEVertex * nee_vertex_0, float sky_pdf_0, float3  spectral_weight_0, float wavelength_6, Selection * sel_3)
{
    Shift _S898 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
    bool _S899 = !nee_vertex_0->none;
    float _S900 = _slang_select(_S899, sky_pdf_0,0.0f);
    float3  _S901 = ray_2->unit_direction;
    float _S902 = escapeWeight_0(_S900, ray_2->unit_direction);
    uint _S903 = prev_0->lobe;
    float3  _S904 = environment_0(_S901, b_4, prev_0->lobe);
    float3  _S905 = pathColor(throughput_0 * _S904, spectral_weight_0, wavelength_6);
    if(replay_1)
    {
        bool _S906 = b_4 == stop_0;
        bool _S907;
        if(_S906)
        {
            _S907 = rc_0 == 3U;
        }
        else
        {
            _S907 = false;
        }
        if(_S907)
        {
            return Shift_x24init_0(_S905 * make_float3 (_S902) / make_float3 (r_4->jac), density_1 / r_4->jac);
        }
        bool _S908 = rc_0 == 0U;
        if(_S908)
        {
            _S907 = end_type_1 == 3U;
        }
        else
        {
            _S907 = false;
        }
        if(_S907)
        {
            _S907 = b_4 == end_1;
        }
        else
        {
            _S907 = false;
        }
        if(_S907)
        {
            _S907 = !prev_0->rough;
        }
        else
        {
            _S907 = false;
        }
        if(_S907)
        {
            return Shift_x24init_0(_S905 * make_float3 (_S902), 1.0f);
        }
        return _S898;
    }
    Reservoir candidate_2 = *chain_0;
    uint _S909 = chain_0->path;
    uint _S910 = extractBits_0(chain_0->path, 10U, 2U);
    bool _S911 = _S910 == 1U;
    if(_S911)
    {
        uint _S912 = extractBits_0(_S909, 5U, 5U);
        bool _S913 = _S912 == b_4;
        float _S914 = _slang_select(_S913, 1.0f,_S902);
        float3  _S915 = safeDivide(_S905 * make_float3 (_S914), chain_throughput_0);
        (&candidate_2)->radiance = _S915;
    }
    else
    {
        bool _S916 = prev_0->rough;
        if(_S916)
        {
            uint _S917 = insertBits_0(strata_0, b_4 + 1U, 5U, 5U);
            uint _S918 = insertBits_0(_S917, 3U, 10U, 2U);
            uint _S919 = insertBits_0(_S918, _S903, 15U, 3U);
            bool _S920 = prev_0->inside;
            uint _S921 = _slang_select(_S920, 1U,0U);
            uint _S922 = insertBits_0(_S919, _S921, 22U, 1U);
            (&candidate_2)->path = _S922;
            (&candidate_2)->jac = prev_0->pdf;
            (&candidate_2)->dir = _S901;
        }
    }
    float3  _S923 = _S905 * make_float3 (_S902);
    Reservoir _S924 = withEnd(candidate_2, 3U, b_4, _S923);
    offer(sel_3, _S924, _S923 * make_float3 (scale_3) / make_float3 (density_1));
    return _S898;
}

static __device__ void restir_duplicates_0(uint3  global_invocation_id_1, uint3  local_invocation_id_0, uint local_invocation_index_3)
{
    uint2  _S925 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S926 = make_int2 ((int)_S925.x, (int)_S925.y);
    uint _S927 = previousSeed_0(_S926);
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
            uint _S928 = previousSeed_0(_S926 + make_int2 (x_17, y_5));
            bool _S929 = _S928 == _S927;
            uint _S930 = _slang_select(_S929, 1U,0U);
            uint count_4 = count_3 + _S930;
            int x_18 = x_17 + int(1);
            x_17 = x_18;
            count_3 = count_4;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S931 = float(count_3 - 1U) / 288.0f;
    bool _S932 = _S927 != 0U;
    float _S933 = _slang_select(_S932, _S931,0.0f);
    fcptStoreDuplication((_S926), (make_uint4 ((F32_asuint((_S933))), 0U, 0U, 0U)));
    return;
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

__device__ void offerShifted(Selection * sel_4, Reservoir r_5, Shift shifted_0, float mis_0)
{
    Reservoir candidate_3 = r_5;
    float3  _S934 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_3)->f = _S934;
    float _S935 = r_5.jac * shifted_0.jac;
    (&candidate_3)->jac = _S935;
    offer(sel_4, candidate_3, make_float3 (mis_0) * shifted_0.f * make_float3 (r_5.w));
    return;
}

__device__ Reservoir finalize(Selection sel_5, float c_1)
{
    Reservoir r_6 = sel_5.r;
    float _S936 = resamplingTarget((&r_6)->f);
    float _S937 = sel_5.w_sum / _S936;
    bool _S938 = _S936 > 0.0f;
    float _S939 = _slang_select(_S938, _S937,0.0f);
    (&r_6)->w = _S939;
    (&r_6)->c = c_1;
    return r_6;
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
    uint2  _S940 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S941 = make_int2 ((int)_S940.x, (int)_S940.y);
    float3  _S942 = make_float3 (0.0f);
    FKHit _S943 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S944 = Domain_x24init_0(_S942, _S942, &_S943, 0.0f, 0.0f);
    Domain dom_4 = _S944;
    bool _S945 = (fcptCurrentDomain((_S941), (&dom_4)));
    bool _S946 = !_S945;
    if(_S946)
    {
        Reservoir _S947 = (Reservoir{});
        fcptStoreReservoirPrevious((_S941), (_S947), ((&dom_4)->hit));
        return;
    }
    Reservoir _S948 = (fcptLoadReservoirTemporal((_S941)));
    uint t_15 = 0U;
    float count_5 = 0.0f;
    float c_sum_0 = _S948.c;
    for(;;)
    {
        uint _S949 = (fcptRestirNeighbours());
        if(t_15 < _S949)
        {
        }
        else
        {
            break;
        }
        int2  _S950 = partner_0(_S941, t_15);
        Domain neighbor_0 = _S944;
        bool _S951 = (fcptCurrentDomain((_S950), (&neighbor_0)));
        if(_S951)
        {
            float count_6 = count_5 + 1.0f;
            uint4  _S952 = (fcptReservoirTemporal((_S950), (0U)));
            float c_sum_1 = c_sum_0 + (U32_asfloat((_S952.w)));
            count_5 = count_6;
            c_sum_0 = c_sum_1;
        }
        uint t_16 = t_15 + 1U;
        t_15 = t_16;
    }
    float _S953 = _S948.c / (F32_max((count_5), (1.0f)));
    float _S954 = resamplingTarget(_S948.f);
    bool _S955 = count_5 == 0.0f;
    float _S956 = _slang_select(_S955, 1.0f,0.0f);
    Selection _S957 = (Selection{});
    Selection sel_6 = _S957;
    uint _S958 = (fcptFrame());
    uint _S959 = hash(_S958);
    uint _S960 = global_invocation_id_2.x;
    uint2  _S961 = (fcptRenderSize());
    uint _S962 = stream(_S959, _S960 + _S961.x * global_invocation_id_2.y);
    uint _S963 = stream(_S962, 195U);
    (&sel_6)->random_state = _S963;
    t_15 = 0U;
    float canonical_mis_0 = _S956;
    for(;;)
    {
        uint _S964 = (fcptRestirNeighbours());
        if(t_15 < _S964)
        {
        }
        else
        {
            break;
        }
        int2  _S965 = partner_0(_S941, t_15);
        Domain neighbor_dom_0 = _S944;
        bool _S966 = (fcptCurrentDomain((_S965), (&neighbor_dom_0)));
        if(_S966)
        {
            Reservoir _S967 = (fcptLoadReservoirTemporal((_S965)));
            uint4  _S968 = (fcptShiftData((_S965), (t_15)));
            float4  _S969 = asfloat_0(_S968);
            uint4  _S970 = (fcptShiftData((_S941), (t_15)));
            float4  _S971 = asfloat_0(_S970);
            float _S972 = (_S967.c + _S953) / c_sum_0;
            bool _S973 = _S954 > 0.0f;
            float canonical_mis_1;
            if(_S973)
            {
                float _S974 = _S972 * _S953 * _S954;
                float _S975 = _S953 * _S954;
                float _S976 = resamplingTarget(float3 {_S971.x, _S971.y, _S971.z});
                float canonical_mis_2 = canonical_mis_0 + _S974 / (_S975 + _S967.c * _S976);
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float _S977 = resamplingTarget(_S967.f);
            float3  _S978 = float3 {_S969.x, _S969.y, _S969.z};
            Shift _S979 = Shift_x24init_0(_S978, _S969.w);
            float _S980 = _S972 * _S967.c * _S977;
            float _S981 = _S967.c * _S977;
            float _S982 = resamplingTarget(_S978);
            offerShifted(&sel_6, _S967, _S979, _S980 / (_S981 + _S953 * _S982));
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_17 = t_15 + 1U;
        t_15 = t_17;
    }
    offerShifted(&sel_6, _S948, Shift_x24init_0(_S948.f, 1.0f), canonical_mis_0);
    Reservoir _S983 = finalize(sel_6, c_sum_0);
    fcptStoreReservoirPrevious((_S941), (_S983), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S941), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S941), (make_float4 ((&sel_6)->color.x, (&sel_6)->color.y, (&sel_6)->color.z, 0.0f)));
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
    uint _S984 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S985 = _S984 != 4294967295U;
    if(_S985)
    {
        uint2  _S986 = make_uint2 (_S984, _S984 >> 14U) & make_uint2 (16383U);
        int2  _S987 = make_int2 ((int)_S986.x, (int)_S986.y);
        ShiftJob _S988 = (ShiftJob{});
        ShiftJob shift_job_0 = _S988;
        Shift _S989 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S990 = _S984 >> 28U;
        bool _S991 = spatialJob_0(_S987, _S990, &shift_job_0, true);
        Shift shifted_1;
        if(_S991)
        {
            Domain _S992 = (&shift_job_0)->dom;
            Reservoir _S993 = (&shift_job_0)->r;
            Shift _S994 = passShift_0(&_S992, &_S993);
            shifted_1 = _S994;
        }
        else
        {
            shifted_1 = _S989;
        }
        fcptStoreShiftData((_S987), (_S990), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S995 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S996 = make_int2 ((int)_S995.x, (int)_S995.y);
    FixedArray<uint, 3>  _S997;
    spatialBins_0(_S996, &_S997);
    FixedArray<uint, 3>  _S998 = _S997;
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
        bool _S999 = (_S998[t_18]) == 40U;
        if(_S999)
        {
            fcptStoreShiftData((_S996), (t_18), (make_uint4 (0U)));
        }
        uint t_19 = t_18 + 1U;
        t_18 = t_19;
    }
    FixedArray<uint, 3>  _S1000 = _S998;
    queueShifts_0(_S996, &_S1000, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S1001 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S1002 = make_int2 ((int)_S1001.x, (int)_S1001.y);
    FixedArray<uint, 3>  _S1003;
    spatialBins_0(_S1002, &_S1003);
    FixedArray<uint, 3>  _S1004 = _S1003;
    countShifts_0(&_S1004, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S1005 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S1006 = _S1005 != 4294967295U;
    if(_S1006)
    {
        uint2  _S1007 = make_uint2 (_S1005, _S1005 >> 14U) & make_uint2 (16383U);
        int2  _S1008 = make_int2 ((int)_S1007.x, (int)_S1007.y);
        int2  _S1009 = (fcptLoadTemporalNeighbor((_S1008)));
        uint _S1010 = _S1005 >> 28U;
        Shift _S1011 = temporalShiftAt_0(_S1008, _S1009, _S1010);
        fcptStoreTemporalShift((_S1008), (_S1010), (make_uint4 (asuint_1(_S1011.f).x, asuint_1(_S1011.f).y, asuint_1(_S1011.f).z, (F32_asuint((_S1011.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S1012 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S1013 = make_int2 ((int)_S1012.x, (int)_S1012.y);
    FixedArray<uint, 3>  _S1014;
    temporalBins_0(_S1013, &_S1014);
    FixedArray<uint, 3>  _S1015 = _S1014;
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
        bool _S1016 = (_S1015[t_20]) == 40U;
        if(_S1016)
        {
            fcptStoreTemporalShift((_S1013), (t_20), (make_uint4 (0U)));
        }
        uint t_21 = t_20 + 1U;
        t_20 = t_21;
    }
    FixedArray<uint, 3>  _S1017 = _S1015;
    queueShifts_0(_S1013, &_S1017, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S1018 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S1019 = make_int2 ((int)_S1018.x, (int)_S1018.y);
    bool _S1020 = (fcptSceneUnchanged());
    bool _S1021 = !_S1020;
    bool _S1022;
    if(_S1021)
    {
        uint2  _S1023 = (fcptRenderSize());
        int2  _S1024 = make_int2 ((int)_S1023.x, (int)_S1023.y);
        _S1022 = all_0(_S1019 < _S1024);
    }
    else
    {
        _S1022 = false;
    }
    if(_S1022)
    {
        Reservoir _S1025 = (fcptLoadReservoirInitial((_S1019)));
        int2  _S1026 = sampleNeighbor_0(_S1019, _S1025.seed);
        fcptStoreTemporalNeighbor((_S1019), (_S1026));
    }
    FixedArray<uint, 3>  _S1027;
    temporalBins_0(_S1019, &_S1027);
    FixedArray<uint, 3>  _S1028 = _S1027;
    countShifts_0(&_S1028, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_10, float b_5, float t_22)
{
    return a_10 + (b_5 - a_10) * t_22;
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S1029 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S1030 = make_int2 ((int)_S1029.x, (int)_S1029.y);
    float3  _S1031 = make_float3 (0.0f);
    FKHit _S1032 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S1033 = Domain_x24init_0(_S1031, _S1031, &_S1032, 0.0f, 0.0f);
    Domain dom_5 = _S1033;
    bool _S1034 = (fcptCurrentDomain((_S1030), (&dom_5)));
    bool _S1035 = !_S1034;
    if(_S1035)
    {
        Reservoir _S1036 = (Reservoir{});
        fcptStoreReservoirTemporal((_S1030), (_S1036), ((&dom_5)->hit));
        return;
    }
    Reservoir _S1037 = (fcptLoadReservoirInitial((_S1030)));
    bool _S1038 = (fcptTemporalQueued());
    bool _S1039 = (fcptSceneUnchanged());
    bool _S1040;
    if(_S1039)
    {
        _S1040 = true;
    }
    else
    {
        _S1040 = !_S1038;
    }
    int2  _S1041;
    if(_S1040)
    {
        int2  _S1042 = sampleNeighbor_0(_S1030, _S1037.seed);
        _S1041 = _S1042;
    }
    else
    {
        int2  _S1043 = (fcptLoadTemporalNeighbor((_S1030)));
        _S1041 = _S1043;
    }
    bool _S1044 = (_S1041.x) >= int(0);
    Reservoir r_7;
    if(_S1044)
    {
        Reservoir _S1045 = (fcptLoadReservoirPrevious((_S1041)));
        uint4  _S1046 = (fcptDuplication((_S1041)));
        float _S1047 = (U32_asfloat((_S1046.x)));
        uint _S1048 = (fcptRestirDecorrelation());
        bool _S1049 = _S1048 == 1U;
        float _S1050 = _slang_select(_S1049, _S1047,0.0f);
        float _S1051 = interpolate_0(20.0f, 1.0f, (F32_pow((_S1050), (0.10000000149011612f))));
        float _S1052 = (F32_min((_S1045.c), (_S1051)));
        bool _S1053 = (fcptSceneUnchanged());
        float4  _S1054 = make_float4 (_S1045.f.x, _S1045.f.y, _S1045.f.z, 1.0f);
        bool _S1055 = !_S1053;
        if(_S1055)
        {
            _S1040 = _S1038;
        }
        else
        {
            _S1040 = false;
        }
        float4  to_current_0;
        if(_S1040)
        {
            uint4  _S1056 = (fcptTemporalShift((_S1030), (0U)));
            float4  _S1057 = asfloat_0(_S1056);
            to_current_0 = _S1057;
        }
        else
        {
            if(_S1055)
            {
                Shift _S1058 = temporalShiftAt_0(_S1030, _S1041, 0U);
                float4  _S1059 = make_float4 (_S1058.f.x, _S1058.f.y, _S1058.f.z, _S1058.jac);
                to_current_0 = _S1059;
            }
            else
            {
                to_current_0 = _S1054;
            }
        }
        Domain own_1 = _S1033;
        if(_S1053)
        {
            _S1040 = true;
        }
        else
        {
            bool _S1060 = (fcptPreviousScenes());
            bool _S1061 = !_S1060;
            if(_S1061)
            {
                _S1040 = (_S1037.w) > 0.0f;
            }
            else
            {
                _S1040 = false;
            }
            if(_S1040)
            {
                bool _S1062 = (fcptStoredDomainInitial((_S1030), (_S1037.seed), (&own_1)));
                _S1040 = _S1062;
            }
            else
            {
                _S1040 = false;
            }
            if(_S1040)
            {
                Domain _S1063 = (fcptPreviousDomain((_S1041), (_S1037.seed)));
                Domain _S1064 = _S1063;
                Domain _S1065 = own_1;
                bool _S1066 = sameDomain_0(&_S1064, &_S1065);
                _S1040 = _S1066;
            }
            else
            {
                _S1040 = false;
            }
        }
        float4  _S1067 = make_float4 (_S1037.f.x, _S1037.f.y, _S1037.f.z, 1.0f);
        bool _S1068 = !_S1040;
        if(_S1068)
        {
            _S1040 = _S1038;
        }
        else
        {
            _S1040 = false;
        }
        float4  to_previous_0;
        if(_S1040)
        {
            uint4  _S1069 = (fcptTemporalShift((_S1030), (1U)));
            float4  _S1070 = asfloat_0(_S1069);
            to_previous_0 = _S1070;
        }
        else
        {
            if(_S1068)
            {
                Shift _S1071 = temporalShiftAt_0(_S1030, _S1041, 1U);
                float4  _S1072 = make_float4 (_S1071.f.x, _S1071.f.y, _S1071.f.z, _S1071.jac);
                to_previous_0 = _S1072;
            }
            else
            {
                to_previous_0 = _S1067;
            }
        }
        float _S1073 = resamplingTarget(_S1037.f);
        float _S1074 = resamplingTarget(_S1045.f);
        Selection _S1075 = (Selection{});
        Selection sel_7 = _S1075;
        uint _S1076 = (fcptFrame());
        uint _S1077 = hash(_S1076);
        uint _S1078 = global_invocation_id_7.x;
        uint2  _S1079 = (fcptRenderSize());
        uint _S1080 = stream(_S1077, _S1078 + _S1079.x * global_invocation_id_7.y);
        uint _S1081 = stream(_S1080, 194U);
        (&sel_7)->random_state = _S1081;
        float _S1082 = _S1037.c * _S1073;
        float4  _S1083 = to_previous_0;
        float _S1084 = resamplingTarget(float3 {_S1083.x, _S1083.y, _S1083.z});
        float _S1085 = _S1082 / (_S1082 + _S1052 * _S1084);
        float _S1086 = _S1052 * _S1074;
        float4  _S1087 = to_current_0;
        float3  _S1088 = float3 {_S1087.x, _S1087.y, _S1087.z};
        float _S1089 = resamplingTarget(_S1088);
        float _S1090 = _S1086 / (_S1086 + _S1037.c * _S1089);
        float2  _S1091 = make_float2 (_S1085, _S1090);
        offerShifted(&sel_7, _S1037, Shift_x24init_0(_S1037.f, 1.0f), _S1085);
        offerShifted(&sel_7, _S1045, Shift_x24init_0(_S1088, to_current_0.w), _S1090);
        Reservoir _S1092 = finalize(sel_7, _S1037.c + _S1052);
        r_7 = _S1092;
    }
    else
    {
        r_7 = _S1037;
    }
    fcptStoreReservoirTemporal((_S1030), (r_7), ((&dom_5)->hit));
    return;
}

__device__ uint noiseOrigin(uint2  p_14, uint k_1)
{
    uint _S1093 = ((p_14.x) >> 11U) | (((p_14.y) >> 11U) << 4U);
    uint2  _S1094 = noiseOffset(8192U + (k_1 >> 10U) + (_S1093 << 20U));
    uint2  _S1095 = (p_14 + _S1094) & make_uint2 (2047U);
    return ((_S1095.x) | ((_S1095.y) << 11U)) | ((k_1 & 1023U) << 22U);
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S1096 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S1097 = make_int2 ((int)_S1096.x, (int)_S1096.y);
    float3  _S1098 = make_float3 (0.0f);
    float2  _S1099 = make_float2 (0.0f);
    FKHit _S1100 = Hit_x24init_0(_S1099, 0U, 0U, 0U, 0.0f);
    Domain _S1101 = Domain_x24init_0(_S1098, _S1098, &_S1100, 0.0f, 0.0f);
    Domain dom_6 = _S1101;
    bool _S1102 = (fcptCurrentDomain((_S1097), (&dom_6)));
    bool _S1103 = !_S1102;
    if(_S1103)
    {
        Reservoir _S1104 = (Reservoir{});
        fcptStoreReservoirInitial((_S1097), (_S1104), ((&dom_6)->hit));
        return;
    }
    uint _S1105 = (fcptFrame());
    uint _S1106 = hash(_S1105);
    uint _S1107 = global_invocation_id_8.x;
    uint2  _S1108 = (fcptRenderSize());
    uint _S1109 = global_invocation_id_8.y;
    uint _S1110 = stream(_S1106, _S1107 + _S1108.x * _S1109);
    uint2  _S1111 = (fcptRenderSize());
    uint _S1112 = stream(_S1107 + _S1111.x * _S1109, 512U);
    Selection _S1113 = (Selection{});
    Selection initial_0 = _S1113;
    uint _S1114 = stream(_S1110, 193U);
    (&initial_0)->random_state = _S1114;
    bool _S1115 = (fcptRestirUsed());
    bool _S1116 = !_S1115;
    (&initial_0)->sums = _S1116;
    uint _S1117 = stream(_S1110, 0U);
    (&(&initial_0)->r)->seed = _S1117;
    FKHit _S1118 = Hit_x24init_0(_S1099, 4294967295U, 0U, 0U, 0.0f);
    uint _S1119 = (fcptSamples());
    float _S1120 = 1.0f / float(_S1119);
    FKHit hit_2 = _S1118;
    uint i_20 = 0U;
    float3  seen_1 = _S1098;
    for(;;)
    {
        uint _S1121 = (fcptSamples());
        if(i_20 < _S1121)
        {
        }
        else
        {
            break;
        }
        Reservoir _S1122 = (Reservoir{});
        Reservoir r_8 = _S1122;
        uint _S1123 = (fcptFrame());
        uint _S1124 = (fcptSamples());
        uint _S1125 = _S1123 * _S1124 + i_20;
        uint _S1126 = noiseOrigin(_S1096, _S1125);
        (&r_8)->seed = _S1126;
        uint _S1127 = insertBits_0(0U, 1U, 24U, 1U);
        uint _S1128 = insertBits_0(_S1127, (_S1112 + _S1125 * 2654435769U) >> 25U, 25U, 7U);
        (&r_8)->path = _S1128;
        Domain path_0 = _S1101;
        bool _S1129 = (fcptStoredDomainInitial((_S1097), ((&r_8)->seed), (&path_0)));
        bool _S1130 = !_S1129;
        if(_S1130)
        {
            float3  _S1131 = (fcptMissed((_S1097), (path_0), (_S1120)));
            float3  seen_2 = seen_1 + _S1131;
            seen_1 = seen_2;
            uint i_21 = i_20 + 1U;
            i_20 = i_21;
            continue;
        }
        Domain _S1132 = path_0;
        Reservoir _S1133 = r_8;
        Shift _S1134 = passWalk_0(&_S1132, &_S1133, false, _S1120, &initial_0);
        bool _S1135 = ((&(&initial_0)->r)->seed) == ((&r_8)->seed);
        FKHit hit_3;
        if(_S1135)
        {
            FKHit _S1136 = (&path_0)->hit;
            hit_3 = _S1136;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_21 = i_20 + 1U;
        i_20 = i_21;
    }
    uint _S1137 = (fcptSamples());
    float3  seen_3 = seen_1 + (&initial_0)->glow / make_float3 (float(_S1137));
    float3  _S1138 = seen_3 + (&initial_0)->color;
    bool _S1139 = (&initial_0)->sums;
    float3  _S1140 = _slang_select(_S1139, _S1138,seen_3);
    fcptAddColor((_S1097), (make_float4 (_S1140.x, _S1140.y, _S1140.z, 1.0f)));
    Reservoir _S1141 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S1097), (_S1141), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_4, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S1142;
    (&_S1142)->none = none_0;
    (&_S1142)->pdf = pdf_4;
    (&_S1142)->origin = origin_5;
    (&_S1142)->smooth_n = smooth_n_3;
    (&_S1142)->start = start_6;
    return _S1142;
}

static __device__ Vertex Vertex_x24init_0(bool rough_0, uint lobe_1, float pdf_5, float cos_0, bool inside_0)
{
    Vertex _S1143;
    (&_S1143)->rough = rough_0;
    (&_S1143)->lobe = lobe_1;
    (&_S1143)->pdf = pdf_5;
    (&_S1143)->cos = cos_0;
    (&_S1143)->inside = inside_0;
    return _S1143;
}

static __device__ bool any_1(bool3  x_22)
{
    bool result_11 = false;
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
        if(result_11)
        {
            result_11 = true;
        }
        else
        {
            result_11 = (bool((_slang_vector_get_element(x_22, i_22))));
        }
        i_22 = i_22 + int(1);
    }
    return result_11;
}

__device__ uint noiseAddress(uint origin_6, uint bounce_0)
{
    uint2  _S1144 = make_uint2 (origin_6 & 2047U, (origin_6 >> 11U) & 2047U);
    uint2  _S1145 = noiseOffset(64U + bounce_0 * 17U);
    uint2  _S1146 = (_S1144 + _S1145) & make_uint2 (2047U);
    return ((_S1146.x) | ((_S1146.y) << 11U)) | ((origin_6 >> 22U) << 22U);
}

static __device__ float3  exp_0(float3  x_23)
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
        *_slang_vector_get_element_ptr(&result_12, i_23) = (F32_exp((_slang_vector_get_element(x_23, i_23))));
        i_23 = i_23 + int(1);
    }
    return result_12;
}

static __device__ float3  flightWeight_0(float3  scatter_0, float3  extinction_0, float distance_2, bool scatters_0)
{
    float3  _S1147 = exp_0(- scatter_0 * make_float3 (distance_2));
    float3  _S1148 = make_float3 (3.0f) * exp_0(- extinction_0 * make_float3 (distance_2));
    float3  _S1149 = _S1148 / make_float3 (_S1147.x + _S1147.y + _S1147.z);
    float3  _S1150 = scatter_0 * _S1148 / make_float3 (dot_0(scatter_0, _S1147));
    float3  _S1151 = _slang_select(scatters_0, _S1150,_S1149);
    return _S1151;
}

static __device__ uint arrivalLobe_0(uint b_6, uint prev_lobe_0)
{
    bool _S1152 = b_6 > 0U;
    uint _S1153 = _slang_select(_S1152, prev_lobe_0,3U);
    return _S1153;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_2, uint lobe_2, bool surface_6, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S1154;
    (&_S1154)->extinction_behind = extinction_behind_0;
    (&_S1154)->extinction_front = extinction_front_0;
    (&_S1154)->fillings = fillings_0;
    (&_S1154)->side = side_0;
    (&_S1154)->depth = depth_2;
    (&_S1154)->lobe = lobe_2;
    (&_S1154)->surface = surface_6;
    (&_S1154)->length = length_2;
    (&_S1154)->width = width_1;
    (&_S1154)->own = *own_2;
    (&_S1154)->fiber = fiber_0;
    return _S1154;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S1155 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S1155)
    {
        return 0.07957746833562851f;
    }
    float _S1156 = g_0 * g_0;
    return (1.0f - _S1156) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S1156 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float survivalProbability(float3  throughput_1, float density_2)
{
    return (F32_min(((F32_max(((F32_max((throughput_1.x), ((F32_max((throughput_1.y), (throughput_1.z)))))) / density_2), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_10)
{
    Random _S1157 = draw(random_state_10, 11U);
    Random _S1158 = draw(random_state_10, 2147483659U);
    float _S1159 = 1.0f - 2.0f * _S1157.value;
    float _S1160 = (F32_sqrt(((F32_max((1.0f - _S1159 * _S1159), (0.0f))))));
    float _S1161 = 6.28318548202514648f * _S1158.value;
    return make_float3 (_S1160 * (F32_cos((_S1161))), _S1160 * (F32_sin((_S1161))), _S1159);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_10, uint random_state_11, float * pdf_6)
{
    bool _S1162 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1162)
    {
        *pdf_6 = 0.07957746833562851f;
        float3  _S1163 = isotropic_0(random_state_11);
        return _S1163;
    }
    Random _S1164 = draw(random_state_11, 11U);
    Random _S1165 = draw(random_state_11, 2147483659U);
    float _S1166 = g_1 * g_1;
    float _S1167 = 2.0f * g_1;
    float _S1168 = (1.0f - _S1166) / (1.0f - g_1 + _S1167 * _S1164.value);
    float _S1169 = clamp_1((1.0f + _S1166 - _S1168 * _S1168) / _S1167, -1.0f, 1.0f);
    float _S1170 = (F32_sqrt(((F32_max((1.0f - _S1169 * _S1169), (0.0f))))));
    float _S1171 = 6.28318548202514648f * _S1165.value;
    float _S1172 = phaseHG_0(g_1, _S1169);
    *pdf_6 = _S1172;
    float3  _S1173 = tangentToWorld(make_float3 (_S1170 * (F32_cos((_S1171))), _S1169, _S1170 * (F32_sin((_S1171)))), dir_10);
    float3  _S1174 = ((((_S1173)) * make_float3(rnorm3df(((_S1173)).x, ((_S1173)).y, ((_S1173)).z))));
    return _S1174;
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_1, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_1, float velvet_0, float3  toon_2, float dispersion_0)
{
    BSDFMaterial _S1175;
    (&_S1175)->albedo = albedo_1;
    (&_S1175)->emissive = emissive_0;
    (&_S1175)->roughness = roughness_0;
    (&_S1175)->metallic = metallic_0;
    (&_S1175)->transmission = transmission_0;
    (&_S1175)->ior = ior_0;
    (&_S1175)->absorption = absorption_0;
    (&_S1175)->specular_tint = specular_tint_0;
    (&_S1175)->specular_level = specular_level_0;
    (&_S1175)->translucent = translucent_0;
    (&_S1175)->sheen = sheen_2;
    (&_S1175)->sheen_roughness = sheen_roughness_0;
    (&_S1175)->anisotropy = anisotropy_0;
    (&_S1175)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1175)->tangent = tangent_1;
    (&_S1175)->velvet = velvet_0;
    (&_S1175)->toon = toon_2;
    (&_S1175)->dispersion = dispersion_0;
    return _S1175;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1176;
    (&_S1176)->scatter = scatter_1;
    (&_S1176)->extinction = extinction_1;
    (&_S1176)->g = g_2;
    return _S1176;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_14, bool skip_0, uint random_state_12, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1177;
    (&_S1177)->smooth_n = smooth_n_4;
    (&_S1177)->geometry_n = geometry_n_2;
    (&_S1177)->geometry_offset = geometry_offset_2;
    (&_S1177)->material = *material_14;
    (&_S1177)->skip = skip_0;
    (&_S1177)->random_state = random_state_12;
    (&_S1177)->coverage = coverage_0;
    (&_S1177)->encloses = encloses_0;
    (&_S1177)->volume = *volume_0;
    (&_S1177)->fills = fills_0;
    (&_S1177)->hair = hair_0;
    return _S1177;
}

static __device__ FKSurface emitting_0(FKSurface * surface_7, bool top_0)
{
    FKSurface lower_0 = *surface_7;
    float3  _S1178 = (&surface_7->material)->emissive;
    float3  _S1179 = make_float3 (0.0f);
    bool _S1180 = !top_0;
    float3  _S1181 = _slang_select(_S1180, _S1179,_S1178);
    (&(&lower_0)->material)->emissive = _S1181;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_8, float u_1)
{
    float _S1182 = surface_8->coverage;
    bool _S1183 = u_1 < _S1182;
    if(_S1183)
    {
        return *surface_8;
    }
    float3  _S1184 = make_float3 (0.0f);
    float3  _S1185 = make_float3 (1.0f);
    BSDFMaterial _S1186 = Material_x24init_0(_S1184, _S1184, 0.0f, 0.0f, 0.0f, 0.0f, _S1184, _S1185, 1.0f, _S1184, _S1184, 0.5f, 0.0f, 0.0f, _S1184, 0.0f, _S1184, 0.0f);
    BSDFMaterial material_15 = _S1186;
    (&material_15)->albedo = _S1185;
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
    bool _S1187 = transmission_1 > 0.0f;
    bool _S1188;
    if(_S1187)
    {
        _S1188 = true;
    }
    else
    {
        _S1188 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1189 = _slang_select(_S1188, 1.0f,-1.0f);
    return _S1189;
}

static __device__ bool arrivesBehind_0(float3  dir_11, float3  n_8)
{
    return (dot_0(dir_11, n_8)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_9, float3  dir_12)
{
    float3  _S1190 = surface_9->geometry_n;
    float _S1191 = facingSign((&surface_9->material)->transmission, surface_9->geometry_n, dir_12);
    FKSurface faced_0 = *surface_9;
    float3  _S1192 = surface_9->smooth_n * make_float3 (_S1191);
    (&faced_0)->smooth_n = _S1192;
    float3  _S1193 = _S1190 * make_float3 (_S1191);
    (&faced_0)->geometry_n = _S1193;
    return faced_0;
}

static __device__ float3  max_0(float3  x_24, float3  y_7)
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
        *_slang_vector_get_element_ptr(&result_13, i_24) = (F32_max((_slang_vector_get_element(x_24, i_24)), (_slang_vector_get_element(y_7, i_24))));
        i_24 = i_24 + int(1);
    }
    return result_13;
}

static __device__ float3  log_0(float3  x_25)
{
    float3  result_14;
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
        *_slang_vector_get_element_ptr(&result_14, i_25) = (F32_log((_slang_vector_get_element(x_25, i_25))));
        i_25 = i_25 + int(1);
    }
    return result_14;
}

__device__ float3  beerLambert(float distance_3, float3  absorption_1)
{
    float3  _S1194 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1194));
}

__device__ bool dispersive(BSDFMaterial material_16)
{
    bool _S1195 = (material_16.dispersion) > 0.0f;
    bool _S1196;
    if(_S1195)
    {
        _S1196 = (material_16.ior) != 1.0f;
    }
    else
    {
        _S1196 = false;
    }
    return _S1196;
}

__device__ static const FixedArray<float, 81>  WAVELENGTH_CDF_0 = { {
    0.0f, 0.00006510900129797f, 0.00018772999465f, 0.00045414001215249f, 0.00105610000900924f, 0.00218509999103844f, 0.00430169980973005f, 0.00824129953980446f, 0.01521500013768673f, 0.02649199962615967f, 0.04202799871563911f, 0.06183499842882156f, 0.08581099659204483f, 0.11225000023841858f, 0.1395999938249588f, 0.16642999649047852f, 0.19130000472068787f, 0.21376000344753265f, 0.23378999531269073f, 0.25200000405311584f, 0.26912999153137207f, 0.28512999415397644f, 0.3002299964427948f, 0.31536000967025757f, 0.33153998851776123f, 0.34944000840187073f, 0.36937999725341797f, 0.39127999544143677f, 0.41528999805450439f, 0.4412899911403656f, 0.46840000152587891f, 0.49524000287055969f, 0.52063000202178955f, 0.54398000240325928f, 0.56476002931594849f, 0.58348000049591064f, 0.60238999128341675f, 0.62285000085830688f, 0.64474999904632568f, 0.66809999942779541f, 0.69291001558303833f, 0.71846002340316772f, 0.74393999576568604f, 0.76951998472213745f, 0.79534000158309937f, 0.82078999280929565f, 0.8454899787902832f, 0.86935001611709595f, 0.89191997051239014f, 0.91228997707366943f, 0.92987000942230225f, 0.94483000040054321f, 0.95753002166748047f, 0.96790999174118042f, 0.97605997323989868f, 0.98237001895904541f, 0.98721998929977417f, 0.9908599853515625f, 0.99356001615524292f, 0.99550998210906982f, 0.9969099760055542f, 0.99787998199462891f, 0.99852001667022705f, 0.99895000457763672f, 0.99924999475479126f, 0.99948000907897949f, 0.99963998794555664f, 0.99975001811981201f, 0.99983000755310059f, 0.99988001585006714f, 0.99990999698638916f, 0.99993997812271118f, 0.99996238946914673f, 0.99997591972351074f, 0.9999845027923584f, 0.99998998641967773f, 0.99999326467514038f, 0.99999552965164185f, 0.99999749660491943f, 0.99999898672103882f, 1.0f
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
        uint _S1197 = (low_1 + high_1 + 1U) / 2U;
        bool _S1198 = (WAVELENGTH_CDF_0[_S1197]) <= u_2;
        if(_S1198)
        {
            low_1 = _S1197;
        }
        else
        {
            uint _S1199 = _S1197 - 1U;
            high_1 = _S1199;
        }
    }
    uint _S1200 = low_1;
    float _S1201 = WAVELENGTH_CDF_0[low_1 + 1U] - WAVELENGTH_CDF_0[low_1];
    return make_float2 (0.37999999523162842f + 0.00499999988824129f * (float(low_1) + (u_2 - WAVELENGTH_CDF_0[_S1200]) / _S1201), _S1201 / 0.00499999988824129f);
}

__device__ static const FixedArray<float, 243>  WAVELENGTH_WEIGHTS_0 = { {
    0.00547470012679696f, -0.00465690018609166f, 0.03257500007748604f, 0.00934640038758516f, -0.00796370021998882f, 0.05577300116419792f, 0.01846100017428398f, -0.01579399965703487f, 0.11072999984025955f, 0.0416410006582737f, -0.03577499836683273f, 0.2513900101184845f, 0.09349299967288971f, -0.08071800321340561f, 0.56742000579833984f, 0.1585099995136261f, -0.13764999806880951f, 0.97018998861312866f, 0.30943000316619873f, -0.27083000540733337f, 1.91740000247955322f, 0.55217999219894409f, -0.48754000663757324f, 3.46889996528625488f, 0.95016998052597046f, -0.84802001714706421f, 6.09439992904663086f, 1.42110002040863037f, -1.28929996490478516f, 9.45199966430664062f, 1.73409998416900635f, -1.6062999963760376f, 12.12800025939941406f, 2.08030009269714355f, -1.98810005187988281f, 15.68700027465820312f, 2.20600008964538574f, -2.20120000839233398f, 18.47699928283691406f, 2.03040003776550293f, -2.17700004577636719f, 19.92700004577636719f, 1.63429999351501465f, -2.00340008735656738f, 20.86899948120117188f, 0.99410998821258545f, -1.62629997730255127f, 20.57799911499023438f, 0.20011000335216522f, -1.11409997940063477f, 19.72100067138671875f, -0.67960000038146973f, -0.45403000712394714f, 17.77599906921386719f, -1.61679995059967041f, 0.37860000133514404f, 14.71500015258789062f, -2.53410005569458008f, 1.27540004253387451f, 11.86499977111816406f, -3.39079999923706055f, 2.2146000862121582f, 9.17669963836669922f, -4.03749990463256836f, 3.0522000789642334f, 6.59509992599487305f, -4.61299991607666016f, 3.89779996871948242f, 4.64589977264404297f, -5.43039989471435547f, 5.0121002197265625f, 3.3199000358581543f, -6.37769985198974609f, 6.33809995651245117f, 2.29699993133544922f, -7.44140005111694336f, 7.91739988327026367f, 1.45389997959136963f, -8.38580036163330078f, 9.60109996795654297f, 0.66465997695922852f, -9.0167999267578125f, 11.23999977111816406f, -0.04403600096702576f, -9.17749977111816406f, 12.63199996948242188f, -0.58126997947692871f, -8.97550010681152344f, 13.91499996185302734f, -0.95730000734329224f, -8.25290012359619141f, 14.86200046539306641f, -1.24430000782012939f, -6.92129993438720703f, 15.03899955749511719f, -1.43069994449615479f, -5.29169988632202148f, 14.90900039672851562f, -1.55149996280670166f, -3.43219995498657227f, 14.70499992370605469f, -1.63569998741149902f, -1.27190005779266357f, 14.24400043487548828f, -1.67030000686645508f, 1.15170001983642578f, 13.32199954986572266f, -1.636199951171875f, 3.73889994621276855f, 12.21199989318847656f, -1.56920003890991211f, 6.43590021133422852f, 10.94699954986572266f, -1.47730004787445068f, 9.16440010070800781f, 9.54769992828369141f, -1.36399996280670166f, 12.02000045776367188f, 8.18799972534179688f, -1.25450003147125244f, 14.78699970245361328f, 6.74429988861083984f, -1.13110005855560303f, 16.72299957275390625f, 5.08780002593994141f, -0.96561002731323242f, 18.14299964904785156f, 3.57019996643066406f, -0.80725997686386108f, 19.91900062561035156f, 2.36269998550415039f, -0.69273000955581665f, 21.05500030517578125f, 1.31369996070861816f, -0.58597999811172485f, 21.3899993896484375f, 0.42390000820159912f, -0.48298001289367676f, 20.99300003051757812f, -0.23857000470161438f, -0.39412000775337219f, 19.82200050354003906f, -0.6866300106048584f, -0.31501999497413635f, 18.12000083923339844f, -0.9412500262260437f, -0.24890999495983124f, 15.7089996337890625f, -1.02020001411437988f, -0.19076000154018402f, 13.19799995422363281f, -0.98919999599456787f, -0.14401000738143921f, 11.23999977111816406f, -0.93347001075744629f, -0.11133000254631042f, 9.36649990081787109f, -0.83820998668670654f, -0.08524099737405777f, 7.41249990463256836f, -0.70064002275466919f, -0.06283199787139893f, 5.71229982376098633f, -0.56079000234603882f, -0.04586699977517128f, 4.42280006408691406f, -0.44653001427650452f, -0.03396600112318993f, 3.34489989280700684f, -0.34457001090049744f, -0.02482499927282333f, 2.49309992790222168f, -0.26017999649047852f, -0.01808100007474422f, 1.82239997386932373f, -0.1921599954366684f, -0.01296999957412481f, 1.29499995708465576f, -0.13766999542713165f, -0.00907570030540228f, 0.92928999662399292f, -0.09956400096416473f, -0.00641620019450784f, 0.61835998296737671f, -0.06671299785375595f, -0.00421149982139468f, 0.40211999416351318f, -0.04354599863290787f, -0.00271830009296536f, 0.2844499945640564f, -0.03087200038135052f, -0.00191440002527088f, 0.20672999322414398f, -0.02246100082993507f, -0.00138829997740686f, 0.15044000744819641f, -0.01634499989449978f, -0.00101030000951141f, 0.10942000150680542f, -0.01188699994236231f, -0.0007347899954766f, 0.07099699974060059f, -0.00771349994465709f, -0.00047679000999779f, 0.04539500176906586f, -0.00493190018460155f, -0.00030484999297187f, 0.03424099832773209f, -0.00372010003775358f, -0.00022995000472292f, 0.02557599917054176f, -0.00277870008721948f, -0.00017175999528263f, 0.01842200011014938f, -0.00200140010565519f, -0.0001237099932041f, 0.01316899992525578f, -0.00143079995177686f, -0.00008843900286593f, 0.00838890019804239f, -0.00091141002485529f, -0.00005633700129692f, 0.00537079991772771f, -0.00058350997278467f, -0.00003606799873523f, 0.00328280008397996f, -0.00035665999166667f, -0.00002204600059486f, 0.00196009990759194f, -0.00021296000340953f, -0.00001316300040344f, 0.00168939994182438f, -0.00018354000349063f, -0.00001134499962063f, 0.00141050003003329f, -0.00015325000276789f, -0.00000947250009631f, 0.00097123999148607f, -0.00010551999730524f, -6.52239987175562419e-06f, 0.00066868000430986f, -0.00007264900341397f, -4.49060007667867467e-06f
} };
__device__ float3  wavelengthWeights(float wavelength_7)
{
    float _S1202 = clamp_1((wavelength_7 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    uint _S1203 = (U32_min((uint(_S1202)), (79U)));
    uint _S1204 = 3U * _S1203;
    float3  _S1205 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1204], WAVELENGTH_WEIGHTS_0[_S1204 + 1U], WAVELENGTH_WEIGHTS_0[_S1204 + 2U]);
    float3  _S1206 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1204 + 3U], WAVELENGTH_WEIGHTS_0[_S1204 + 4U], WAVELENGTH_WEIGHTS_0[_S1204 + 5U]);
    return _S1205 + (_S1206 - _S1205) * make_float3 (_S1202 - float(_S1203));
}

__device__ float dispersedIor(float ior_1, float dispersion_1, float wavelength_8)
{
    float _S1207 = (ior_1 - 1.0f) * dispersion_1 / 1.90962409973144531f;
    float _S1208 = _S1207 * (1.0f / (wavelength_8 * wavelength_8) - 2.89662933349609375f);
    bool _S1209 = dispersion_1 > 0.0f;
    float _S1210 = _slang_select(_S1209, _S1208,0.0f);
    return ior_1 + _S1210;
}

__device__ float2  vertexEta(BSDFMaterial material_17, float n_dot_v_0)
{
    bool _S1211 = n_dot_v_0 < 0.0f;
    float _S1212 = _slang_select(_S1211, material_17.ior,1.0f);
    float _S1213 = _slang_select(_S1211, 1.0f,material_17.ior);
    return make_float2 (_S1212, _S1213);
}

__device__ float2  wavelengthEta(BSDFMaterial material_18, float n_dot_v_1, float wavelength_9)
{
    BSDFMaterial refractive_0 = material_18;
    float _S1214 = dispersedIor(material_18.ior, material_18.dispersion, wavelength_9);
    bool _S1215 = wavelength_9 > 0.0f;
    float _S1216 = _slang_select(_S1215, _S1214,material_18.ior);
    (&refractive_0)->ior = _S1216;
    float2  _S1217 = vertexEta(refractive_0, n_dot_v_1);
    return _S1217;
}

__device__ bool neeDecision(BSDFMaterial material_19, float n_dot_v_2, float eta_i_5, float eta_o_5)
{
    float _S1218 = fresnel((F32_abs((n_dot_v_2))), eta_i_5, eta_o_5);
    float3  _S1219 = mix_0(make_float3 (_S1218), material_19.albedo, material_19.metallic);
    float _S1220 = rgb_to_greyscale(_S1219);
    float _S1221 = (F32_max(((1.0f - _S1220) * (1.0f - material_19.metallic) * (1.0f - material_19.transmission)), (0.0f)));
    bool _S1222 = _S1221 > 0.03999999910593033f;
    bool _S1223;
    if(_S1222)
    {
        _S1223 = true;
    }
    else
    {
        _S1223 = (material_19.roughness) > 0.20000000298023224f;
    }
    return _S1223;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_20)
{
    float _S1224 = rgb_to_greyscale(material_20->translucent);
    return _S1224 > 0.0f;
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
    MediumSides _S1225;
    (&_S1225)->behind = *behind_0;
    (&_S1225)->front = *front_0;
    (&_S1225)->fillings = fillings_1;
    (&_S1225)->face = face_1;
    return _S1225;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_10, FKMedium * medium_0, uint filling_0, float3  dir_13, FKMedium * outside_0)
{
    float3  _S1226 = surface_10->geometry_n;
    MediumSides _S1227 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_10->geometry_n);
    MediumSides sides_0 = _S1227;
    bool _S1228 = surface_10->encloses;
    if(_S1228)
    {
        (&sides_0)->behind = surface_10->volume;
        *&((&(&sides_0)->fillings)->x) = surface_10->fills;
        bool _S1229 = (dot_0(dir_13, _S1226)) > 0.0f;
        if(_S1229)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_11, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_14, uint depth_3, uint lobe_3, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1230 = surface_11->geometry_n;
    ShadowContext _S1231 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_11->geometry_n, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
    bool _S1232 = surface_11->encloses;
    ShadowContext context_4;
    if(_S1232)
    {
        FKSurface faced_1 = *surface_11;
        float3  _S1233 = - _S1230;
        float3  _S1234 = _slang_select(turned_0, _S1233,_S1230);
        (&faced_1)->geometry_n = _S1234;
        FKMedium _S1235 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1236 = faced_1;
        FKMedium _S1237 = _S1235;
        MediumSides _S1238 = mediumSides_0(&_S1236, &_S1237, filling_1, dir_14, outside_1);
        ShadowContext _S1239 = ShadowContext_x24init_0(_S1238.behind.extinction, _S1238.front.extinction, _S1238.fillings, _S1230, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
        if(turned_0)
        {
            uint2  _S1240 = _S1238.fillings;
            ShadowContext _S1241 = ShadowContext_x24init_0(_S1238.front.extinction, _S1238.behind.extinction, uint2 {_S1240.y, _S1240.x}, _S1230, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
            context_4 = _S1241;
        }
        else
        {
            context_4 = _S1239;
        }
    }
    else
    {
        context_4 = _S1231;
    }
    return context_4;
}

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_8, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_3, BSDFMaterial * material_21, float eta_i_6, float eta_o_6, bool competing_1, uint random_state_13)
{
    float3  _S1242 = light_2->dir;
    bool _S1243 = (dot_0(geometry_n_3, - in_dir_8) * dot_0(geometry_n_3, light_2->dir)) <= 0.0f;
    FixedArray<float3 , 5>  throughputs_1;
    FixedArray<float, 5>  pdfs_4;
    float3  _S1244 = BSDF(in_dir_8, _S1242, smooth_n_5, *material_21, eta_i_6, eta_o_6, _S1243, random_state_13, &throughputs_1, &pdfs_4);
    bool _S1245 = !competing_1;
    bool _S1246;
    if(_S1245)
    {
        _S1246 = true;
    }
    else
    {
        _S1246 = (light_2->density) == 0.0f;
    }
    if(_S1246)
    {
        return _S1244 * light_2->radiance;
    }
    float3  _S1247 = make_float3 (0.0f);
    uint i_26 = 0U;
    float3  weighted_0 = _S1247;
    for(;;)
    {
        if(i_26 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S1248 = (pdfs_4[i_26]) > 0.0f;
        if(_S1248)
        {
            float _S1249 = light_2->density;
            float _S1250 = pdfs_4[i_26] / light_2->density;
            float3  weighted_1 = weighted_0 + throughputs_1[i_26] * make_float3 (pdfs_4[i_26]) / make_float3 (_S1249 * (1.0f + _S1250 * _S1250));
            weighted_0 = weighted_1;
        }
        uint i_27 = i_26 + 1U;
        i_26 = i_27;
    }
    return weighted_0 * light_2->radiance * make_float3 (light_2->density);
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_2, uint random_state_14, bool refracted_3, uint lobe_4, float pdf_7)
{
    SampleBSDF _S1251;
    (&_S1251)->unit_direction = unit_direction_1;
    (&_S1251)->throughput = throughput_2;
    (&_S1251)->random_state = random_state_14;
    (&_S1251)->refracted = refracted_3;
    (&_S1251)->lobe = lobe_4;
    (&_S1251)->pdf = pdf_7;
    return _S1251;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  v_9, float3  n_i_13, float n_i_dot_v_3, BSDFMaterial material_22, Weights w_14, uint random_state_15)
{
    Random _S1252 = draw(random_state_15, 3U);
    Random _S1253 = draw(random_state_15, 2147483651U);
    float _S1254 = _S1252.value;
    float _S1255 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1254 * _S1254))))));
    float _S1256 = 6.28318548202514648f * _S1253.value;
    float3  _S1257 = tangentToWorld(make_float3 (_S1255 * (F32_cos((_S1256))), _S1252.value, _S1255 * (F32_sin((_S1256)))), n_i_13);
    float3  _S1258 = sheenVelvetBSDF(_S1257, v_9, n_i_13, material_22, w_14);
    float _S1259 = sheenVelvetPDF(_S1252.value, n_i_dot_v_3, w_14);
    return SampleBSDF_x24init_0(_S1257, _S1258, _S1253.state, false, 4U, _S1259);
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1260 = (F32_sqrt((random_1_0)));
    float _S1261 = 6.28318548202514648f * random_2_0;
    float _S1262 = _S1260 * (F32_cos((_S1261)));
    float _S1263 = _S1260 * (F32_sin((_S1261)));
    float _S1264 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1262 * _S1262 - _S1263 * _S1263))))));
    return make_float3 (_S1262, _S1264, _S1263);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_3, float3  n_i_14, float n_i_dot_v_4, BSDFMaterial material_23, Weights w_15, uint random_state_16)
{
    Random _S1265 = draw(random_state_16, 3U);
    Random _S1266 = draw(random_state_16, 2147483651U);
    float3  _S1267 = sampleCosWeightedHemisphere(_S1265.value, _S1266.value);
    float _S1268 = translucentShare(material_23);
    bool _S1269 = u_3 < (w_15.p_diffuse * _S1268);
    float _S1270 = _S1267.y;
    float _S1271 = - _S1270;
    float _S1272 = _slang_select(_S1269, _S1271,_S1270);
    float3  _S1273 = tangentToWorld(make_float3 (_S1267.x, _S1272, _S1267.z), n_i_14);
    float3  _S1274 = diffuseBSDF(_S1273, n_i_14, material_23, w_15);
    float _S1275 = diffusePDF(_S1272, n_i_dot_v_4, material_23, w_15);
    return SampleBSDF_x24init_0(_S1273, _S1274, _S1266.state, _S1269, 0U, _S1275);
}

__device__ __forceinline__ SampleBSDF toonSample(float3  n_i_15, ToonProfile profile_3, Weights w_16, uint random_state_17)
{
    Random _S1276 = draw(random_state_17, 3U);
    Random _S1277 = draw(random_state_17, 2147483651U);
    float _S1278 = _S1276.value * profile_3.norm / 6.28318548202514648f;
    float _S1279 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1278)))), (1.0f))))));
    float _S1280 = (F32_acos((clamp_1(1.0f - _S1278, -1.0f, 1.0f))));
    float _S1281 = _slang_select(profile_3.glossy, _S1280,_S1279);
    float _S1282 = (profile_3.a + profile_3.b) / 2.0f;
    bool _S1283 = _S1281 < (profile_3.a);
    float _S1284 = _slang_select(_S1283, _S1281,_S1282);
    float t_23 = _S1284;
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
        float _S1285 = toonP(t_23, profile_3.a, profile_3.s);
        float _S1286 = _S1285 * (F32_sin((t_23)));
        float _S1287 = (F32_cos((t_23)));
        float _S1288 = _slang_select(profile_3.glossy, 1.0f,_S1287);
        float _S1289 = _S1286 * _S1288;
        float _S1290 = toonIntegral(t_23, profile_3.a, profile_3.s, profile_3.glossy);
        float _S1291 = (_S1290 - _S1278) / _S1289;
        bool _S1292 = _S1289 > 0.0f;
        float _S1293 = _slang_select(_S1292, _S1291,0.0f);
        float _S1294 = clamp_1(t_23 - _S1293, 0.0f, profile_3.b);
        int k_3 = k_2 + int(1);
        t_23 = _S1294;
        k_2 = k_3;
    }
    float _S1295 = 6.28318548202514648f * _S1277.value;
    float _S1296 = (F32_sin((t_23)));
    float3  _S1297 = tangentToWorld(make_float3 (_S1296 * (F32_cos((_S1295))), (F32_cos((t_23))), _S1296 * (F32_sin((_S1295)))), profile_3.axis);
    float3  _S1298 = toonBSDF(_S1297, n_i_15, profile_3, w_16);
    bool _S1299 = (dot_0(n_i_15, _S1297)) < 0.0f;
    float _S1300 = toonPDF(_S1297, n_i_15, profile_3, w_16);
    return SampleBSDF_x24init_0(_S1297, _S1298, _S1277.state, _S1299, 6U, _S1300);
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_16, float alpha_8, AnisotropicFrame frame_6, BSDFMaterial material_24, Weights w_17, float pdf_h_3, float eta_i_7, float eta_o_7, uint random_state_18)
{
    float3  _S1301 = make_float3 (1.0f);
    SampleBSDF _S1302 = SampleBSDF_x24init_0(_S1301, _S1301, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S1302;
    (&sample_1)->unit_direction = w_17.refracted;
    (&sample_1)->random_state = random_state_18;
    (&sample_1)->refracted = true;
    (&sample_1)->lobe = 1U;
    float3  _S1303 = refractBSDF((&sample_1)->unit_direction, n_i_16, alpha_8, frame_6, material_24, w_17);
    (&sample_1)->throughput = _S1303;
    float _S1304 = refractPDF(dot_0((&sample_1)->unit_direction, ggx_n_3), pdf_h_3, w_17, eta_i_7, eta_o_7);
    (&sample_1)->pdf = _S1304;
    return sample_1;
}

static __device__ float3  reflect_0(float3  i_28, float3  n_9)
{
    return i_28 - make_float3 (2.0f * dot_0(n_9, i_28)) * n_9;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_9, float3  ggx_n_4, float3  n_i_17, float alpha_9, AnisotropicFrame frame_7, Weights w_18, float pdf_h_4, uint random_state_19)
{
    float3  _S1305 = make_float3 (1.0f);
    SampleBSDF _S1306 = SampleBSDF_x24init_0(_S1305, _S1305, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S1306;
    float3  _S1307 = reflect_0(in_dir_9, ggx_n_4);
    float3  _S1308 = ((((_S1307)) * make_float3(rnorm3df(((_S1307)).x, ((_S1307)).y, ((_S1307)).z))));
    (&sample_2)->unit_direction = _S1308;
    (&sample_2)->random_state = random_state_19;
    (&sample_2)->lobe = 2U;
    float3  _S1309 = reflectBSDF((&sample_2)->unit_direction, n_i_17, alpha_9, frame_7, w_18);
    (&sample_2)->throughput = _S1309;
    float _S1310 = reflectPDF(pdf_h_4, w_18);
    (&sample_2)->pdf = _S1310;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_10, float3  n_10, BSDFMaterial material_25, float eta_i_8, float eta_o_8, uint random_init_0, float2  screen_space_0)
{
    uint random_state_20 = random_init_0;
    float3  _S1311 = negate_0(in_dir_10);
    float _S1312 = dot_0(n_10, _S1311);
    float _S1313 = sign_0(_S1312);
    float3  n_i_18 = n_10 * make_float3 (_S1313);
    float _S1314 = (F32_abs((_S1312)));
    float _S1315 = material_25.roughness;
    float _S1316 = _S1315 * _S1315;
    AnisotropicFrame _S1317 = anisotropicFrame(material_25, n_i_18);
    SheenProfile _S1318 = sheenProfile(_S1311, n_i_18, material_25);
    float3  _S1319 = sampleHalfVector(_S1311, n_i_18, _S1316, _S1317, &random_state_20);
    Weights _S1320 = lobeWeights(in_dir_10, _S1311, n_i_18, _S1319, _S1317, _S1318, material_25, eta_i_8, eta_o_8);
    Random _S1321 = draw(random_state_20, 2U);
    random_state_20 = _S1321.state;
    bool _S1322 = (_S1321.value) < (_S1320.p_sheen_velvet);
    if(_S1322)
    {
        SampleBSDF _S1323 = sheenVelvetSample(_S1311, n_i_18, _S1314, material_25, _S1320, random_state_20);
        return _S1323;
    }
    float _S1324 = _S1321.value - _S1320.p_sheen_velvet;
    bool _S1325 = _S1324 < (_S1320.p_diffuse);
    if(_S1325)
    {
        SampleBSDF _S1326 = diffuseSample(_S1324, n_i_18, _S1314, material_25, _S1320, random_state_20);
        return _S1326;
    }
    bool _S1327 = _S1324 < (_S1320.p_diffuse + _S1320.p_toon);
    if(_S1327)
    {
        ToonProfile _S1328 = toonProfile(_S1311, n_i_18, material_25);
        SampleBSDF _S1329 = toonSample(n_i_18, _S1328, _S1320, random_state_20);
        return _S1329;
    }
    float _S1330 = vndfPDF(_S1311, _S1319, n_i_18, _S1314, _S1316, _S1317, _S1320.v_dot_h);
    bool _S1331 = (_S1324 - _S1320.p_toon) < (_S1320.p_diffuse + _S1320.p_refract);
    if(_S1331)
    {
        SampleBSDF _S1332 = refractSample(_S1319, n_i_18, _S1316, _S1317, material_25, _S1320, _S1330, eta_i_8, eta_o_8, random_state_20);
        return _S1332;
    }
    SampleBSDF _S1333 = reflectSample(in_dir_10, _S1319, n_i_18, _S1316, _S1317, _S1320, _S1330, random_state_20);
    return _S1333;
}

static __device__ bool boundsVolume_0(FKSurface * surface_12)
{
    return surface_12->encloses;
}

static __device__ Shift walk_0(Domain * dom_7, Reservoir * r_9, bool replay_2, float scale_4, Selection * sel_8)
{
    bool turned_1;
    bool is_inside_6;
    bool viewed_0;
    bool _S1334;
    bool _S1335;
    bool _S1336;
    uint b_7;
    uint layer_0;
    float3  throughput_3;
    float3  spectral_weight_1;
    float density_3;
    float spread_1;
    float width_3;
    float sky_pdf_1;
    float wavelength_10;
    float threshold_0;
    TreeSample light_3;
    int _S1337;
    Shift ended_0;
    float density_4;
    float spread_2;
    float width_4;
    float sky_pdf_2;
    uint b_8;
    float spread_3;
    float width_5;
    float3  _S1338 = make_float3 (0.0f);
    Shift _S1339 = Shift_x24init_0(_S1338, 0.0f);
    uint _S1340 = r_9->path;
    uint _S1341 = extractBits_0(r_9->path, 0U, 5U);
    uint _S1342 = extractBits_0(_S1340, 5U, 5U);
    uint _S1343 = extractBits_0(_S1340, 10U, 2U);
    uint _S1344 = extractBits_0(_S1340, 12U, 3U);
    bool passes_0;
    if(replay_2)
    {
        bool _S1345 = _S1344 >= 3U;
        uint _S1346 = _slang_select(_S1345, 1U,0U);
        uint _S1347 = _S1341 + _S1346;
        uint _S1348 = (fcptMaxBounces());
        passes_0 = _S1347 > _S1348;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1339;
    }
    uint _S1349 = _S1342 - 1U;
    bool _S1350 = _S1344 == 3U;
    uint _S1351 = _slang_select(_S1350, 1U,0U);
    uint _S1352 = _S1341 + _S1351;
    bool _S1353 = _S1343 == 0U;
    uint _S1354 = _slang_select(_S1353, _S1352,_S1349);
    FKHit _S1355 = (fcptReservoirHit((*r_9)));
    float3  _S1356 = dom_7->x0;
    float3  _S1357 = dom_7->x1 - dom_7->x0;
    float3  _S1358 = ((((_S1357)) * make_float3(rnorm3df(((_S1357)).x, ((_S1357)).y, ((_S1357)).z))));
    FKRay _S1359 = Ray_x24init_0(dom_7->x1, _S1358);
    FKRay ray_3 = _S1359;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1338;
    float3  throughput_4 = make_float3 (1.0f);
    float3  weight_2 = throughput_4;
    float3  glowed_0 = _S1338;
    float3  extinction_in_0 = _S1338;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1360 = dom_7->spread;
    float _S1361 = dom_7->width;
    float _S1362 = length_0(_S1357);
    NEEVertex _S1363 = NEEVertex_x24init_0(true, 0.0f, _S1338, _S1338, _S1338);
    NEEVertex nee_vertex_1 = _S1363;
    Vertex _S1364 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_1 = _S1364;
    Reservoir _S1365 = (Reservoir{});
    Reservoir chain_1 = _S1365;
    uint _S1366 = r_9->seed;
    (&chain_1)->seed = r_9->seed;
    uint _S1367 = extractBits_0(_S1340, 24U, 8U);
    uint _S1368 = insertBits_0(0U, _S1367, 24U, 8U);
    (&chain_1)->path = _S1368;
    (&ray_3)->origin = _S1356;
    (&hit_4)->distance = _S1362;
    FKMedium _S1369 = (fcptCameraMedium(((&ray_3)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1370 = filling_2;
    bool _S1371 = (fcptVaryingUsed());
    uint _S1372 = _slang_select(_S1371, _S1370,4294967295U);
    filling_2 = _S1372;
    scatter_in_0 = _S1369.scatter;
    extinction_in_0 = _S1369.extinction;
    g_in_0 = _S1369.g;
    Reservoir _S1373 = chain_1;
    uint _S1374 = filling_2;
    for(;;)
    {
        bool _S1375 = (fcptVaryingUsed());
        if(_S1375)
        {
            passes_0 = _S1374 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1376 = (fcptMajorant((_S1374)));
            turned_1 = _S1376 > 0.0f;
        }
        else
        {
            turned_1 = any_1(scatter_in_0 > make_float3 (0.0f));
        }
        if(replay_2)
        {
            is_inside_6 = 4294967295U == _S1354;
        }
        else
        {
            is_inside_6 = false;
        }
        if(is_inside_6)
        {
            is_inside_6 = _S1343 == 1U;
        }
        else
        {
            is_inside_6 = false;
        }
        if(is_inside_6)
        {
            is_inside_6 = turned_1;
        }
        else
        {
            is_inside_6 = false;
        }
        if(is_inside_6)
        {
            ended_0 = _S1339;
            sky_pdf_1 = 0.0f;
            spread_1 = _S1360;
            width_3 = _S1361;
            density_3 = 1.0f;
            throughput_3 = throughput_4;
            b_7 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1377 = (&prev_1)->rough;
        if(_S1377)
        {
            is_inside_6 = !turned_1;
        }
        else
        {
            is_inside_6 = false;
        }
        (&prev_1)->rough = is_inside_6;
        uint _S1378 = stream(_S1366, 384U);
        uint tracking_0 = _S1378;
        weight_2 = throughput_4;
        glowed_0 = _S1338;
        b_7 = 4294967295U;
        throughput_3 = throughput_4;
        density_3 = 1.0f;
        spread_1 = _S1360;
        width_3 = _S1361;
        sky_pdf_1 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1337 = int(1);
                break;
            }
            float _S1379 = (&hit_4)->distance;
            if(passes_0)
            {
                float3  _S1380 = (&ray_3)->origin;
                float3  _S1381 = (&ray_3)->unit_direction;
                float _S1382 = (&hit_4)->distance;
                bool _S1383 = b_7 == 4294967295U;
                uint _S1384 = _slang_select(_S1383, 0U,b_7);
                uint _S1385 = (&prev_1)->lobe;
                uint _S1386 = _slang_select(_S1383, 3U,_S1385);
                float _S1387 = (fcptTrackMedium((_S1374), (_S1380), (_S1381), (_S1382), (&tracking_0), (&weight_2), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1384), (_S1386), (_S1383)));
                wavelength_10 = _S1387;
            }
            else
            {
                if(turned_1)
                {
                    uint _S1388 = noiseAddress(_S1366, b_7);
                    Random _S1389 = draw(_S1388, 10U);
                    float _S1390 = 3.0f * _S1389.value;
                    uint _S1391 = (U32_min((uint(_S1390)), (2U)));
                    float _S1392 = - (F32_log((1.0f - (_S1390 - float(_S1391))))) / *_slang_vector_get_element_ptr(&scatter_in_0, _S1391);
                    wavelength_10 = _S1392;
                }
                else
                {
                    wavelength_10 = _S1379;
                }
            }
            bool _S1393 = !(wavelength_10 < ((&hit_4)->distance));
            if(_S1393)
            {
                _S1337 = int(1);
                break;
            }
            if(passes_0)
            {
                is_inside_6 = !replay_2;
            }
            else
            {
                is_inside_6 = false;
            }
            if(is_inside_6)
            {
                float3  _S1394 = pathColor(throughput_3 * glowed_0, throughput_4, 0.0f);
                float3  _S1395 = _S1394 / make_float3 (density_3);
                float3  _S1396 = sel_8->glow + _S1395;
                sel_8->glow = _S1396;
            }
            else
            {
            }
            glowed_0 = _S1338;
            uint b_9 = b_7 + 1U;
            float3  _S1397 = (&ray_3)->origin + make_float3 (wavelength_10) * (&ray_3)->unit_direction;
            (&ray_3)->origin = _S1397;
            float3  _S1398 = flightWeight_0(scatter_in_0, extinction_in_0, wavelength_10, true);
            float3  _S1399 = weight_2;
            float _S1400 = upsample(weight_2, 0.0f);
            float3  _S1401 = make_float3 (_S1400);
            float3  _S1402 = _slang_select(false, _S1401,_S1399);
            float3  _S1403 = _slang_select(passes_0, _S1402,_S1398);
            float3  throughput_5 = throughput_3 * _S1403;
            uint _S1404 = stream(_S1366, b_9 + 320U);
            tracking_0 = _S1404;
            weight_2 = throughput_4;
            float width_6 = width_3 + spread_1 * wavelength_10;
            float _S1405 = spread_1 + 3.14159274101257324f;
            bool _S1406 = !replay_2;
            if(_S1406)
            {
                viewed_0 = true;
            }
            else
            {
                bool _S1407 = b_9 == _S1354;
                if(_S1407)
                {
                    viewed_0 = !passes_0;
                }
                else
                {
                    viewed_0 = false;
                }
            }
            TreeSample _S1408 = TreeSample_x24init_0(_S1338, _S1338, 0.0f, 0U);
            if(viewed_0)
            {
                float3  _S1409 = (&ray_3)->origin;
                float3  _S1410 = (&ray_3)->unit_direction;
                float3  _S1411 = (&ray_3)->unit_direction;
                uint _S1412 = noiseAddress(_S1366, b_9);
                float3  _S1413 = extinction_in_0;
                float3  _S1414 = extinction_in_0;
                uint2  _S1415 = make_uint2 (_S1374);
                float3  _S1416 = (&ray_3)->unit_direction;
                uint _S1417 = arrivalLobe_0(b_9, (&prev_1)->lobe);
                FKHit _S1418 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1419 = _S1418;
                ShadowContext _S1420 = ShadowContext_x24init_0(_S1413, _S1414, _S1415, _S1416, b_9, _S1417, false, wavelength_10, width_6, &_S1419, false);
                ShadowContext _S1421 = _S1420;
                TreeSample _S1422 = sampleLightTree_0(_S1409, _S1410, _S1411, 0.0f, true, _S1412, &_S1421);
                light_3 = _S1422;
            }
            else
            {
                light_3 = _S1408;
            }
            float _S1423 = phaseHG_0(g_in_0, dot_0((&ray_3)->unit_direction, light_3.dir));
            uint _S1424 = (fcptMaxBounces());
            bool _S1425 = b_9 < _S1424;
            if(_S1425)
            {
                _S1334 = (light_3.density) > 0.0f;
            }
            else
            {
                _S1334 = false;
            }
            float _S1426 = _slang_select(_S1334, _S1423,0.0f);
            float3  _S1427 = throughput_5 * light_3.radiance;
            float _S1428 = powerHeuristic(light_3.density, _S1426);
            float3  _S1429 = pathColor(_S1427 * make_float3 (_S1423 * _S1428), throughput_4, 0.0f);
            float3  _S1430 = _slang_select(viewed_0, _S1429,_S1338);
            if(replay_2)
            {
                _S1335 = b_9 == _S1354;
            }
            else
            {
                _S1335 = false;
            }
            if(_S1335)
            {
                bool _S1431 = _S1343 == 2U;
                if(_S1431)
                {
                    float _S1432 = resamplingTarget(_S1430);
                    passes_0 = _S1432 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1433 = Shift_x24init_0(_S1430, 1.0f);
                    _S1337 = int(0);
                    ended_0 = _S1433;
                    wavelength_10 = _S1405;
                    threshold_0 = width_6;
                    spectral_weight_1 = throughput_5;
                    layer_0 = b_9;
                    break;
                }
                _S1337 = int(0);
                ended_0 = _S1339;
                wavelength_10 = _S1405;
                threshold_0 = width_6;
                spectral_weight_1 = throughput_5;
                layer_0 = b_9;
                break;
            }
            if(_S1406)
            {
                Reservoir candidate_4 = _S1373;
                uint _S1434 = extractBits_0(_S1373.path, 24U, 8U);
                uint _S1435 = insertBits_0(0U, _S1434, 24U, 8U);
                uint _S1436 = extractBits_0(_S1373.path, 10U, 2U);
                bool _S1437 = _S1436 == 1U;
                if(_S1437)
                {
                    float3  _S1438 = safeDivide(_S1430, _S1338);
                    (&candidate_4)->radiance = _S1438;
                }
                else
                {
                    uint _S1439 = insertBits_0(_S1435, b_9 + 1U, 5U, 5U);
                    uint _S1440 = insertBits_0(_S1439, 2U, 10U, 2U);
                    (&candidate_4)->path = _S1440;
                }
                Reservoir _S1441 = withEnd(candidate_4, 0U, b_9, _S1430);
                offer(sel_8, _S1441, _S1430 * make_float3 (scale_4) / make_float3 (density_3));
                float _S1442 = survivalProbability(abs_0(throughput_5), density_3);
                uint _S1443 = (fcptMaxBounces());
                bool _S1444 = b_9 >= _S1443;
                if(_S1444)
                {
                    _S1336 = true;
                }
                else
                {
                    bool _S1445 = _S1442 < 1.0f;
                    if(_S1445)
                    {
                        uint _S1446 = noiseAddress(_S1366, b_9);
                        Random _S1447 = draw(_S1446, 8U);
                        _S1336 = _S1442 < (_S1447.value);
                    }
                    else
                    {
                        _S1336 = false;
                    }
                }
                if(_S1336)
                {
                    _S1337 = int(0);
                    ended_0 = _S1339;
                    wavelength_10 = _S1405;
                    threshold_0 = width_6;
                    spectral_weight_1 = throughput_5;
                    layer_0 = b_9;
                    break;
                }
                float _S1448 = density_3 * _S1442;
                density_3 = _S1448;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1449 = noiseAddress(_S1366, b_9);
            float3  _S1450 = samplePhase_0(g_in_0, (&ray_3)->unit_direction, _S1449, &phase_pdf_0);
            (&ray_3)->unit_direction = _S1450;
            NEEVertex _S1451 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_3)->origin, _S1338, (&ray_3)->origin);
            nee_vertex_1 = _S1451;
            Vertex _S1452 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, false);
            prev_1 = _S1452;
            float _S1453 = (&prev_1)->pdf;
            FKRay _S1454 = ray_3;
            FKHit _S1455 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1456 = (fcptTraverseInstanceBVH((_S1454), (true), (4.294967296e+09f), (false), (_S1455), (false)));
            hit_4 = _S1456;
            b_7 = b_9;
            throughput_3 = throughput_5;
            spread_1 = _S1405;
            width_3 = width_6;
            sky_pdf_1 = _S1453;
        }
        if(_S1337 != int(1))
        {
            spread_1 = wavelength_10;
            width_3 = threshold_0;
            throughput_3 = spectral_weight_1;
            b_7 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1339;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1457 = b_7 == 4294967295U;
    bool _S1458 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1458)
    {
        Reservoir _S1459 = chain_1;
        FKRay _S1460 = ray_3;
        Vertex _S1461 = prev_1;
        NEEVertex _S1462 = nee_vertex_1;
        Shift _S1463 = escape_0(r_9, replay_2, _S1354, _S1343, _S1341, _S1344, scale_4, _S1368, &_S1459, _S1338, b_7, &_S1460, throughput_3, density_3, &_S1461, &_S1462, sky_pdf_1, throughput_4, 0.0f, sel_8);
        return _S1463;
    }
    FKHit _S1464 = hit_4;
    uint _S1465 = filling_2;
    float3  _S1466 = scatter_in_0;
    float3  _S1467 = extinction_in_0;
    float3  _S1468 = weight_2;
    float3  _S1469 = glowed_0;
    float3  _S1470 = (&ray_3)->origin + make_float3 (_S1464.distance) * (&ray_3)->unit_direction;
    (&ray_3)->origin = _S1470;
    bool _S1471 = (fcptVaryingUsed());
    if(_S1471)
    {
        passes_0 = _S1465 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1472 = !replay_2;
        if(_S1472)
        {
            float3  _S1473 = pathColor(throughput_3 * _S1469, throughput_4, 0.0f);
            float3  _S1474 = _S1473 / make_float3 (density_3);
            float3  _S1475 = sel_8->glow + _S1474;
            sel_8->glow = _S1475;
        }
        else
        {
        }
        float3  _S1476 = throughput_3 * _S1468;
        throughput_3 = _S1476;
    }
    else
    {
        float3  _S1477 = flightWeight_0(_S1466, _S1467, _S1464.distance, false);
        float3  _S1478 = throughput_3 * _S1477;
        throughput_3 = _S1478;
    }
    float width_7 = width_3 + spread_1 * _S1464.distance;
    uint _S1479 = b_7 + 1U;
    b_7 = _S1479;
    layer_0 = 0U;
    width_3 = width_7;
    passes_0 = false;
    wavelength_10 = 0.0f;
    threshold_0 = 0.0f;
    turned_1 = false;
    is_inside_6 = false;
    spectral_weight_1 = throughput_4;
    float3  chain_throughput_1 = _S1338;
    float3  reconnection_0 = _S1338;
    viewed_0 = _S1457;
    for(;;)
    {
        bool _S1480 = ((&hit_4)->is_point_light) == 1U;
        if(replay_2)
        {
            _S1334 = _S1343 == 1U;
        }
        else
        {
            _S1334 = false;
        }
        if(_S1334)
        {
            _S1335 = b_7 == _S1342;
        }
        else
        {
            _S1335 = false;
        }
        if(_S1335)
        {
            bool _S1481 = ((&hit_4)->instance_index) != (_S1355.instance_index);
            if(_S1481)
            {
                _S1336 = true;
            }
            else
            {
                _S1336 = ((&hit_4)->triangle_index) != (_S1355.triangle_index);
            }
        }
        else
        {
            _S1336 = false;
        }
        if(_S1336)
        {
            return _S1339;
        }
        FKMedium _S1482 = Medium_x24init_0(_S1338, _S1338, 0.0f);
        BSDFMaterial _S1483 = Material_x24init_0(_S1338, _S1338, 0.0f, 0.0f, 0.0f, 0.0f, _S1338, throughput_4, 1.0f, _S1338, _S1338, 0.5f, 0.0f, 0.0f, _S1338, 0.0f, _S1338, 0.0f);
        FKMedium _S1484 = _S1482;
        FKSurface _S1485 = Surface_x24init_0(_S1338, _S1338, 0.0f, &_S1483, false, 0U, 1.0f, false, &_S1484, 4294967295U, _S1338);
        bool _S1486 = !_S1480;
        bool scatter_2;
        bool is_inside_7;
        float3  throughput_6;
        float geometry_density_0;
        FKSurface surface_13;
        if(_S1486)
        {
            uint _S1487 = noiseAddress(_S1366, b_7);
            uint _S1488 = arrivalLobe_0(b_7, (&prev_1)->lobe);
            FKSurface _S1489 = (fcptSurfaceAtPath((hit_4), ((&ray_3)->origin), (_S1487), (width_3), (layer_0), (b_7), (_S1488), ((&ray_3)->unit_direction)));
            bool _S1490 = !passes_0;
            FKSurface _S1491 = _S1489;
            FKSurface _S1492 = emitting_0(&_S1491, _S1490);
            uint _S1493 = noiseAddress(_S1366, b_7);
            Random _S1494 = draw(_S1493, 9U);
            FKSurface _S1495 = _S1492;
            FKSurface _S1496 = uncovered_0(&_S1495, _S1494.value);
            float _S1497 = facingSign(_S1496.material.transmission, _S1496.geometry_n, (&ray_3)->unit_direction);
            bool _S1498 = _S1497 < 0.0f;
            bool _S1499 = (_S1496.material.transmission) > 0.0f;
            if(_S1499)
            {
                bool _S1500 = arrivesBehind_0((&ray_3)->unit_direction, _S1496.geometry_n);
                scatter_2 = _S1500;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1501 = _S1496;
            FKSurface _S1502 = facingRay_0(&_S1501, (&ray_3)->unit_direction);
            if(passes_0)
            {
                bool _S1503 = arrivesBehind_0((&ray_3)->unit_direction, _S1502.geometry_n);
                is_inside_7 = _S1503;
            }
            else
            {
                is_inside_7 = scatter_2;
            }
            if(is_inside_7)
            {
                float _S1504 = (&hit_4)->distance;
                float _S1505 = upsample(_S1502.material.absorption, wavelength_10);
                float3  _S1506 = make_float3 (_S1505);
                bool _S1507 = wavelength_10 > 0.0f;
                float3  _S1508 = _slang_select(_S1507, _S1506,_S1502.material.absorption);
                float3  _S1509 = beerLambert(_S1504, _S1508);
                float3  _S1510 = throughput_3 * _S1509;
                throughput_6 = _S1510;
            }
            else
            {
                throughput_6 = throughput_3;
            }
            bool _S1511 = !_S1502.skip;
            float geometry_density_1 = (F32_abs((dot_0(_S1502.geometry_n, (&ray_3)->unit_direction)))) / ((&hit_4)->distance * (&hit_4)->distance);
            bool _S1512 = b_7 == _S1479;
            if(_S1512)
            {
                float _S1513 = 0.00251327408477664f / geometry_density_1;
                geometry_density_0 = _S1513;
            }
            else
            {
                geometry_density_0 = threshold_0;
            }
            float _S1514 = geometry_density_0;
            scatter_2 = _S1511;
            geometry_density_0 = geometry_density_1;
            threshold_0 = _S1514;
            surface_13 = _S1502;
            turned_1 = _S1498;
        }
        else
        {
            scatter_2 = false;
            geometry_density_0 = 0.0f;
            surface_13 = _S1485;
            throughput_6 = throughput_3;
            is_inside_7 = is_inside_6;
        }
        bool _S1515;
        if(scatter_2)
        {
            _S1515 = (&prev_1)->rough;
        }
        else
        {
            _S1515 = false;
        }
        bool _S1516;
        if(_S1515)
        {
            _S1516 = ((&prev_1)->pdf * geometry_density_0 * threshold_0) <= 1.0f;
        }
        else
        {
            _S1516 = false;
        }
        FKSurface _S1517 = surface_13;
        float _S1518 = dot_0(surface_13.smooth_n, - (&ray_3)->unit_direction);
        bool _S1519 = (fcptDispersionUsed());
        bool _S1520;
        if(_S1519)
        {
            _S1520 = wavelength_10 == 0.0f;
        }
        else
        {
            _S1520 = false;
        }
        bool _S1521;
        if(_S1520)
        {
            _S1521 = scatter_2;
        }
        else
        {
            _S1521 = false;
        }
        bool _S1522;
        if(_S1521)
        {
            bool _S1523 = dispersive(surface_13.material);
            _S1522 = _S1523;
        }
        else
        {
            _S1522 = false;
        }
        float3  throughput_7;
        if(_S1522)
        {
            uint _S1524 = stream(_S1366, 512U);
            Random _S1525 = pcg(_S1524);
            uint _S1526 = extractBits_0(_S1340, 25U, 7U);
            float _S1527 = (float(_S1526) + _S1525.value) / 128.0f;
            uint _S1528 = extractBits_0(_S1340, 24U, 1U);
            bool _S1529 = _S1528 == 1U;
            float _S1530 = _slang_select(_S1529, _S1527,_S1525.value);
            float2  _S1531 = sampleWavelength(_S1530);
            float wavelength_11 = _S1531.x;
            float3  _S1532 = wavelengthWeights(wavelength_11);
            float3  _S1533 = _S1532 / make_float3 (_S1531.y);
            float _S1534 = upsample(throughput_6, wavelength_11);
            float3  _S1535 = make_float3 (_S1534);
            float _S1536 = upsample(scatter_in_0, wavelength_11);
            float3  _S1537 = make_float3 (_S1536);
            scatter_in_0 = _S1537;
            float _S1538 = upsample(extinction_in_0, wavelength_11);
            float3  _S1539 = make_float3 (_S1538);
            extinction_in_0 = _S1539;
            wavelength_10 = wavelength_11;
            throughput_7 = _S1535;
            spectral_weight_1 = _S1533;
        }
        else
        {
            throughput_7 = throughput_6;
        }
        BSDFMaterial _S1540 = pathMaterial(surface_13.material, wavelength_10);
        float2  _S1541 = wavelengthEta(_S1540, _S1518, wavelength_10);
        bool _S1542;
        if(scatter_2)
        {
            uint _S1543 = (fcptMaxBounces());
            bool _S1544 = b_7 >= _S1543;
            if(_S1544)
            {
                _S1542 = true;
            }
            else
            {
                bool _S1545 = neeDecision(_S1540, _S1518, _S1541.x, _S1541.y);
                _S1542 = _S1545;
            }
        }
        else
        {
            _S1542 = false;
        }
        bool _S1546;
        if(passes_0)
        {
            _S1546 = true;
        }
        else
        {
            _S1546 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1546)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1542;
        }
        bool _S1547 = (fcptHairUsed());
        bool _S1548;
        if(_S1547)
        {
            float3  _S1549 = surface_13.hair;
            _S1548 = (dot_0(_S1549, _S1549)) > 0.0f;
        }
        else
        {
            _S1548 = false;
        }
        bool _S1550;
        if(_S1548)
        {
            _S1550 = true;
        }
        else
        {
            BSDFMaterial _S1551 = _S1540;
            bool _S1552 = isTranslucent_0(&_S1551);
            _S1550 = _S1552;
        }
        bool _S1553;
        if(_S1550)
        {
            _S1553 = true;
        }
        else
        {
            bool _S1554 = (_S1540.transmission) > 0.0f;
            if(_S1554)
            {
                uint _S1555 = (fcptLayers((hit_4)));
                _S1553 = _S1555 == 1U;
            }
            else
            {
                _S1553 = false;
            }
        }
        float3  emission_0;
        if(_S1480)
        {
            float3  _S1556 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1556;
        }
        else
        {
            emission_0 = _S1540.emissive;
        }
        bool _S1557 = !replay_2;
        bool _S1558;
        if(_S1557)
        {
            _S1558 = true;
        }
        else
        {
            _S1558 = b_7 >= _S1354;
        }
        bool _S1559;
        if(_S1558)
        {
            float _S1560 = rgb_to_greyscale(emission_0);
            _S1559 = _S1560 > 0.0f;
        }
        else
        {
            _S1559 = false;
        }
        float3  emission_1;
        if(_S1559)
        {
            NEEVertex _S1561 = nee_vertex_1;
            FKHit _S1562 = hit_4;
            float _S1563 = emissionWeight_0(&_S1561, &_S1562, (&ray_3)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1563);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1564;
        if(replay_2)
        {
            _S1564 = _S1343 == 1U;
        }
        else
        {
            _S1564 = false;
        }
        bool _S1565;
        if(_S1564)
        {
            _S1565 = b_7 > _S1342;
        }
        else
        {
            _S1565 = false;
        }
        bool _S1566;
        if(_S1565)
        {
            _S1566 = b_7 == _S1341;
        }
        else
        {
            _S1566 = false;
        }
        bool _S1567;
        if(_S1566)
        {
            bool _S1568 = _S1344 == 1U;
            if(_S1568)
            {
                _S1567 = true;
            }
            else
            {
                _S1567 = _S1344 == 2U;
            }
        }
        else
        {
            _S1567 = false;
        }
        if(_S1567)
        {
            bool _S1569 = _S1480 != (_S1344 == 2U);
            if(_S1569)
            {
                return _S1339;
            }
            float3  _S1570 = pathColor(throughput_7 * emission_1, spectral_weight_1, wavelength_10);
            return Shift_x24init_0(_S1570 / make_float3 (r_9->jac), density_3 / r_9->jac);
        }
        uint _S1571 = extractBits_0((&chain_1)->path, 10U, 2U);
        bool _S1572 = _S1571 == 1U;
        Reservoir here_0 = chain_1;
        uint _S1573 = insertBits_0(_S1368, b_7, 5U, 5U);
        uint _S1574 = insertBits_0(_S1573, 1U, 10U, 2U);
        uint _S1575 = insertBits_0(_S1574, (&prev_1)->lobe, 15U, 3U);
        bool _S1576 = (&prev_1)->inside;
        uint _S1577 = _slang_select(_S1576, 1U,0U);
        uint _S1578 = insertBits_0(_S1575, _S1577, 22U, 1U);
        (&here_0)->path = _S1578;
        uint _S1579 = (&here_0)->path;
        bool _S1580 = wavelength_10 > 0.0f;
        uint _S1581 = _slang_select(_S1580, 1U,0U);
        uint _S1582 = insertBits_0(_S1579, _S1581, 23U, 1U);
        (&here_0)->path = _S1582;
        float _S1583 = (&prev_1)->pdf * geometry_density_0;
        (&here_0)->jac = _S1583;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1584;
        if(replay_2)
        {
            _S1584 = _S1343 == 1U;
        }
        else
        {
            _S1584 = false;
        }
        bool _S1585;
        if(_S1584)
        {
            _S1585 = b_7 == _S1342;
        }
        else
        {
            _S1585 = false;
        }
        bool _S1586 = b_7 == _S1354;
        bool _S1587;
        if(_S1586)
        {
            bool _S1588 = !scatter_2;
            if(_S1588)
            {
                _S1587 = true;
            }
            else
            {
                bool _S1589 = _S1343 != 1U;
                if(_S1589)
                {
                    _S1587 = _S1343 != 3U;
                }
                else
                {
                    _S1587 = false;
                }
            }
        }
        else
        {
            _S1587 = false;
        }
        bool _S1590;
        if(_S1587)
        {
            _S1590 = _S1343 == 2U;
        }
        else
        {
            _S1590 = false;
        }
        bool _S1591;
        if(_S1590)
        {
            _S1591 = !_S1516;
        }
        else
        {
            _S1591 = false;
        }
        bool _S1592;
        if(_S1591)
        {
            _S1592 = _S1344 != 4U;
        }
        else
        {
            _S1592 = false;
        }
        bool _S1593 = _S1342 == _S1341;
        bool _S1594;
        if(_S1593)
        {
            _S1594 = _S1344 == 0U;
        }
        else
        {
            _S1594 = false;
        }
        bool _S1595;
        if(_S1594)
        {
            _S1595 = ((&hit_4)->instance_index) == (_S1355.instance_index);
        }
        else
        {
            _S1595 = false;
        }
        bool _S1596;
        if(_S1595)
        {
            _S1596 = ((&hit_4)->triangle_index) == (_S1355.triangle_index);
        }
        else
        {
            _S1596 = false;
        }
        bool _S1597;
        if(_S1596)
        {
            _S1597 = _S1516;
        }
        else
        {
            _S1597 = false;
        }
        bool _S1598 = _slang_select(_S1585, _S1597,_S1592);
        bool _S1599;
        if(nee_0)
        {
            _S1599 = _slang_select(replay_2, _S1598,scatter_2);
        }
        else
        {
            _S1599 = false;
        }
        TreeSample _S1600 = TreeSample_x24init_0(_S1338, _S1338, 0.0f, 0U);
        uint2  _S1601 = make_uint2 (0U);
        float2  _S1602 = make_float2 (0.0f);
        FKHit _S1603 = Hit_x24init_0(_S1602, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1604 = _S1603;
        ShadowContext _S1605 = ShadowContext_x24init_0(_S1338, _S1338, _S1601, _S1338, 0U, 0U, false, 0.0f, 0.0f, &_S1604, false);
        bool _S1606;
        if(nee_0)
        {
            _S1606 = _S1558;
        }
        else
        {
            _S1606 = false;
        }
        ShadowContext context_5;
        if(_S1606)
        {
            uint _S1607 = arrivalLobe_0(b_7, (&prev_1)->lobe);
            FKMedium _S1608 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1609 = surface_13;
            FKHit _S1610 = hit_4;
            FKMedium _S1611 = _S1608;
            ShadowContext _S1612 = shadowContext_0(&_S1609, turned_1, extinction_in_0, filling_2, (&ray_3)->unit_direction, b_7, _S1607, (&hit_4)->distance, width_3, &_S1610, _S1548, &_S1611);
            context_5 = _S1612;
        }
        else
        {
            context_5 = _S1605;
        }
        float3  throughput_8;
        float3  lit_0;
        if(_S1599)
        {
            float3  _S1613 = (&ray_3)->origin;
            if(_S1548)
            {
                throughput_8 = _S1338;
            }
            else
            {
                throughput_8 = _S1517.smooth_n;
            }
            FKSurface _S1614 = surface_13;
            uint _S1615 = noiseAddress(_S1366, b_7);
            ShadowContext _S1616 = context_5;
            TreeSample _S1617 = sampleLightTree_0(_S1613, throughput_8, surface_13.geometry_n, surface_13.geometry_offset, _S1553, _S1615, &_S1616);
            bool _S1618 = any_1((_S1617.radiance) != _S1338);
            if(_S1618)
            {
                if(_S1548)
                {
                    uint _S1619 = (fcptMaxBounces());
                    bool _S1620 = b_7 < _S1619;
                    FKSurface _S1621 = surface_13;
                    TreeSample _S1622 = _S1617;
                    float3  _S1623 = hairLight_0(&_S1621, (&ray_3)->unit_direction, &_S1622, _S1620);
                    lit_0 = _S1623;
                }
                else
                {
                    float _S1624 = _S1541.x;
                    float _S1625 = _S1541.y;
                    uint _S1626 = (fcptMaxBounces());
                    bool _S1627 = b_7 < _S1626;
                    TreeSample _S1628 = _S1617;
                    BSDFMaterial _S1629 = _S1540;
                    float3  _S1630 = lightBSDF_0((&ray_3)->unit_direction, &_S1628, _S1517.smooth_n, _S1614.geometry_n, &_S1629, _S1624, _S1625, _S1627, surface_13.random_state);
                    lit_0 = _S1630;
                }
            }
            else
            {
                lit_0 = _S1338;
            }
            light_3 = _S1617;
        }
        else
        {
            light_3 = _S1600;
            lit_0 = _S1338;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1631;
        bool _S1632;
        float density_5;
        if(_S1585)
        {
            bool _S1633 = !_S1516;
            if(_S1633)
            {
                return _S1339;
            }
            uint _S1634 = extractBits_0(_S1340, 23U, 1U);
            bool _S1635 = _S1580 != (_S1634 == 1U);
            if(_S1635)
            {
                return _S1339;
            }
            float3  throughput_9 = throughput_7 * make_float3 (geometry_density_0);
            float density_6 = density_3 * geometry_density_0;
            if(_S1593)
            {
                viewed_1 = _S1344 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                float3  _S1636 = pathColor(throughput_9 * emission_1, spectral_weight_1, wavelength_10);
                return Shift_x24init_0(_S1636 / make_float3 (r_9->jac), density_6 / r_9->jac);
            }
            if(_S1593)
            {
                refracted_4 = _S1344 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S1637 = !nee_0;
                if(_S1637)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1638 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1638 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1339;
                }
                float3  _S1639 = pathColor(throughput_9 * lit_0, spectral_weight_1, wavelength_10);
                return Shift_x24init_0(_S1639 / make_float3 (r_9->jac), density_6 / r_9->jac);
            }
            if(_S1593)
            {
                wrong_side_0 = _S1344 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1640 = !nee_0;
                if(_S1640)
                {
                    return _S1339;
                }
                bool _S1641 = (fcptWorldReadsPath());
                if(_S1641)
                {
                    float _S1642 = environmentPdf_0(r_9->dir);
                    uint _S1643 = b_7 + 1U;
                    FKSurface _S1644 = surface_13;
                    float3  _S1645 = skyColor_0((&ray_3)->unit_direction, r_9->dir, &_S1644, wavelength_10, _S1541, is_inside_7, _S1642, surface_13.random_state, _S1643);
                    float3  _S1646 = pathColor(throughput_9 * (_S1645 * r_9->radiance), spectral_weight_1, wavelength_10);
                    return Shift_x24init_0(_S1646 / make_float3 (r_9->jac), density_6 / r_9->jac);
                }
                float _S1647 = environmentPdf_0(r_9->dir);
                float3  _S1648 = skyBSDF((&ray_3)->unit_direction, r_9->dir, surface_13, _S1540, _S1541, is_inside_7, _S1647, surface_13.random_state);
                float3  _S1649 = pathColor(throughput_9 * _S1648 * r_9->radiance, spectral_weight_1, wavelength_10);
                return Shift_x24init_0(_S1649 / make_float3 (r_9->jac), density_6 / r_9->jac);
            }
            uint _S1650 = extractBits_0(_S1340, 21U, 1U);
            bool _S1651 = nee_0 != (_S1650 == 1U);
            if(_S1651)
            {
                return _S1339;
            }
            throughput_8 = throughput_9;
            density_5 = density_6;
        }
        else
        {
            if(replay_2)
            {
                viewed_1 = _S1586;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1652 = !scatter_2;
                if(_S1652)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1653 = _S1343 != 1U;
                    if(_S1653)
                    {
                        refracted_4 = _S1343 != 3U;
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
                bool _S1654 = _S1343 == 2U;
                if(_S1654)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1516;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1344 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1548)
                    {
                        return _S1339;
                    }
                    uint _S1655 = noiseAddress(_S1366, b_7);
                    FKRay _S1656 = ray_3;
                    FKSurface _S1657 = surface_13;
                    ShadowContext _S1658 = context_5;
                    SkySample _S1659 = sampleSky_0(&_S1656, &_S1657, wavelength_10, _S1541, is_inside_7, _S1655, surface_13.random_state, &_S1658);
                    float3  _S1660 = pathColor(throughput_7 * _S1659.color, spectral_weight_1, wavelength_10);
                    return Shift_x24init_0(_S1660, 1.0f);
                }
                if(_S1654)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1516;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1661 = rgb_to_greyscale(light_3.radiance);
                    bool _S1662 = !(_S1661 > 0.0f);
                    if(_S1662)
                    {
                        return _S1339;
                    }
                    float3  _S1663 = pathColor(throughput_7 * lit_0, spectral_weight_1, wavelength_10);
                    return Shift_x24init_0(_S1663, 1.0f);
                }
                if(_S1353)
                {
                    passes_0 = _S1344 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1480;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float3  _S1664 = pathColor(throughput_7 * emission_1, spectral_weight_1, wavelength_10);
                    return Shift_x24init_0(_S1664, 1.0f);
                }
                if(_S1353)
                {
                    passes_0 = _S1344 == 1U;
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
                    passes_0 = !_S1516;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float3  _S1665 = pathColor(throughput_7 * emission_1, spectral_weight_1, wavelength_10);
                    return Shift_x24init_0(_S1665, 1.0f);
                }
                return _S1339;
            }
            else
            {
                if(_S1557)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1666 = b_7 > 0U;
                    if(_S1666)
                    {
                        Reservoir candidate_5 = chain_1;
                        if(_S1572)
                        {
                            float3  _S1667 = safeDivide(throughput_7 * emission_1, chain_throughput_1);
                            (&candidate_5)->radiance = _S1667;
                        }
                        else
                        {
                            if(_S1516)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1668 = pathColor(throughput_7 * emission_1, spectral_weight_1, wavelength_10);
                        Reservoir _S1669 = withEnd(candidate_5, 1U, b_7, _S1668);
                        offer(sel_8, _S1669, _S1668 * make_float3 (scale_4) / make_float3 (density_3));
                    }
                    else
                    {
                        float3  _S1670 = pathColor(throughput_7 * emission_1, spectral_weight_1, wavelength_10);
                        float3  _S1671 = sel_8->glow + _S1670;
                        sel_8->glow = _S1671;
                    }
                    if(nee_0)
                    {
                        float3  _S1672 = pathColor(throughput_7 * lit_0, spectral_weight_1, wavelength_10);
                        Reservoir candidate_6 = chain_1;
                        if(_S1572)
                        {
                            float3  _S1673 = safeDivide(_S1672, chain_throughput_1);
                            (&candidate_6)->radiance = _S1673;
                        }
                        else
                        {
                            if(_S1516)
                            {
                                candidate_6 = here_0;
                                uint _S1674 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1674;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1675 = insertBits_0(_S1368, b_7 + 1U, 5U, 5U);
                                uint _S1676 = insertBits_0(_S1675, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1676;
                            }
                        }
                        Reservoir _S1677 = withEnd(candidate_6, 0U, b_7, _S1672);
                        offer(sel_8, _S1677, _S1672 * make_float3 (scale_4) / make_float3 (density_3));
                    }
                    if(nee_0)
                    {
                        if(_S1548)
                        {
                            _S1631 = false;
                        }
                        else
                        {
                            bool _S1678 = environmentMapped_0();
                            _S1631 = _S1678;
                        }
                    }
                    else
                    {
                        _S1631 = false;
                    }
                    if(_S1631)
                    {
                        uint _S1679 = (fcptMaxBounces());
                        _S1632 = b_7 < _S1679;
                    }
                    else
                    {
                        _S1632 = false;
                    }
                    if(_S1632)
                    {
                        uint _S1680 = noiseAddress(_S1366, b_7);
                        FKRay _S1681 = ray_3;
                        FKSurface _S1682 = surface_13;
                        ShadowContext _S1683 = context_5;
                        SkySample _S1684 = sampleSky_0(&_S1681, &_S1682, wavelength_10, _S1541, is_inside_7, _S1680, surface_13.random_state, &_S1683);
                        float3  _S1685 = pathColor(throughput_7 * _S1684.color, spectral_weight_1, wavelength_10);
                        Reservoir candidate_7 = chain_1;
                        if(_S1572)
                        {
                            float3  _S1686 = safeDivide(_S1685, chain_throughput_1);
                            (&candidate_7)->radiance = _S1686;
                        }
                        else
                        {
                            if(_S1516)
                            {
                                candidate_7 = here_0;
                                uint _S1687 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1687;
                                (&candidate_7)->dir = _S1684.dir;
                                (&candidate_7)->radiance = _S1684.radiance;
                            }
                            else
                            {
                                uint _S1688 = insertBits_0(_S1368, b_7 + 1U, 5U, 5U);
                                uint _S1689 = insertBits_0(_S1688, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1689;
                            }
                        }
                        Reservoir _S1690 = withEnd(candidate_7, 4U, b_7, _S1685);
                        offer(sel_8, _S1690, _S1685 * make_float3 (scale_4) / make_float3 (density_3));
                    }
                }
            }
            throughput_8 = throughput_7;
            density_5 = density_3;
        }
        bool _S1691;
        bool _S1692;
        bool _S1693;
        bool straight_0;
        bool _S1694;
        bool _S1695;
        bool _S1696;
        bool _S1697;
        bool _S1698;
        bool _S1699;
        bool _S1700;
        bool _S1701;
        bool _S1702;
        bool _S1703;
        bool _S1704;
        bool _S1705;
        bool _S1706;
        bool _S1707;
        uint b_10;
        float3  throughput_10;
        float3  throughput_11;
        float3  throughput_12;
        float density_7;
        float sky_pdf_3;
        float spread_4;
        if(scatter_2)
        {
            if(replay_2)
            {
                viewed_1 = _S1586;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1708 = extractBits_0(_S1340, 15U, 3U);
            uint _S1709 = extractBits_0(_S1340, 18U, 3U);
            uint _S1710 = _slang_select(_S1585, _S1709,_S1708);
            float3  _S1711 = r_9->dir;
            bool refracted_5 = _S1710 == 1U;
            SampleBSDF _S1712 = SampleBSDF_x24init_0(_S1338, _S1338, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1712;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1713 = extractBits_0(_S1340, 22U, 1U);
                bool _S1714 = is_inside_7 != (_S1713 == 1U);
                if(_S1714)
                {
                    return _S1339;
                }
                bool _S1715 = _S1343 == 1U;
                if(_S1715)
                {
                    float3  _S1716 = (fcptHitPosition((_S1355)));
                    throughput_10 = _S1716;
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
                    BSDFMaterial _S1717 = _S1540;
                    bool _S1718 = isTranslucent_0(&_S1717);
                    if(_S1718)
                    {
                        refracted_4 = _S1710 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1719 = throughput_10 - (&ray_3)->origin;
                        float3  _S1720 = _slang_select(_S1715, _S1719,_S1711);
                        wrong_side_0 = (dot_0(_S1517.smooth_n, _S1720) * _S1518) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1715)
                {
                    float3  _S1721 = (&ray_3)->origin;
                    FKSurface _S1722 = surface_13;
                    float3  _S1723 = - _S1517.smooth_n;
                    bool _S1724 = is_inside_7 != refracted_4;
                    float3  _S1725 = _slang_select(_S1724, _S1723,_S1517.smooth_n);
                    float3  _S1726 = throughput_10 - (_S1721 + make_float3 (_S1722.geometry_offset) * _S1725);
                    float3  _S1727 = ((((_S1726)) * make_float3(rnorm3df(((_S1726)).x, ((_S1726)).y, ((_S1726)).z))));
                    reconnection_1 = _S1727;
                }
                else
                {
                    reconnection_1 = _S1711;
                }
                if(_S1548)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1728 = wrongSide_0(is_inside_7, refracted_4, reconnection_1, surface_13.geometry_n);
                    wrong_side_0 = _S1728;
                }
                if(wrong_side_0)
                {
                    return _S1339;
                }
                float3  _S1729 = throughput_10;
                throughput_10 = reconnection_1;
                b_10 = _S1710;
                wrong_side_0 = false;
                reconnection_1 = _S1729;
            }
            else
            {
                bool _S1730 = !_S1585;
                if(_S1730)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1731;
                    if(_S1548)
                    {
                        SampleBSDF _S1732 = (fcptSampleHair((surface_13.hair), (_S1540.albedo), (_S1540.specular_tint), ((&ray_3)->unit_direction), (surface_13.random_state)));
                        _S1731 = _S1732;
                    }
                    else
                    {
                        SampleBSDF _S1733 = sampleBSDF((&ray_3)->unit_direction, _S1517.smooth_n, _S1540, _S1541.x, _S1541.y, surface_13.random_state, _S1602);
                        _S1731 = _S1733;
                    }
                    bsdf_sampled_0 = _S1731;
                    if(_S1548)
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
                            return _S1339;
                        }
                        break;
                    }
                    if(_S1548)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1734 = wrongSide_0(is_inside_7, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_13.geometry_n);
                        wrong_side_0 = _S1734;
                    }
                    if(wrong_side_0)
                    {
                        _S1631 = (_S1540.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1631 = false;
                    }
                    if(_S1631)
                    {
                        SampleBSDF _S1735 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_13.geometry_n, _S1540, _S1541.x, _S1541.y, (&bsdf_sampled_0)->random_state, _S1602);
                        (&bsdf_sampled_0)->unit_direction = _S1735.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1735.refracted;
                        (&bsdf_sampled_0)->throughput = _S1735.throughput;
                        (&bsdf_sampled_0)->lobe = _S1735.lobe;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1736 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_13.geometry_n)) * surface_13.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1736;
                        }
                    }
                    uint _S1737 = (&bsdf_sampled_0)->lobe;
                    float3  _S1738 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1739 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1740 = (&bsdf_sampled_0)->pdf;
                    float _S1741 = _slang_select(wrong_side_0, 0.0f,_S1740);
                    (&lobe_5)->pdf = _S1741;
                    throughput_10 = _S1738;
                    b_10 = _S1737;
                    refracted_4 = _S1739;
                }
                else
                {
                    throughput_10 = _S1711;
                    b_10 = _S1710;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1631 = true;
            }
            else
            {
                _S1631 = _S1585;
            }
            float3  chain_throughput_2;
            if(_S1631)
            {
                if(_S1548)
                {
                    SampleBSDF _S1742 = (fcptConnectHair((surface_13.hair), (_S1540.albedo), (_S1540.specular_tint), ((&ray_3)->unit_direction), (throughput_10)));
                    lobe_5 = _S1742;
                }
                else
                {
                    float3  _S1743 = (&ray_3)->unit_direction;
                    float3  _S1744 = negate_0(_S1743);
                    float _S1745 = sign_0(_S1518);
                    float3  _S1746 = _S1517.smooth_n * make_float3 (_S1745);
                    float _S1747 = dot_0(_S1746, throughput_10);
                    float _S1748 = _S1540.roughness;
                    float _S1749 = _S1748 * _S1748;
                    AnisotropicFrame _S1750 = anisotropicFrame(_S1540, _S1746);
                    SheenProfile _S1751 = sheenProfile(_S1744, _S1746, _S1540);
                    float3  _S1752 = reflectedHalf(_S1743, throughput_10);
                    bool _S1753 = b_10 == 1U;
                    if(_S1753)
                    {
                        float3  _S1754 = refractedHalf(_S1743, throughput_10, _S1517.smooth_n, _S1541.x, _S1541.y);
                        throughput_11 = _S1754;
                    }
                    else
                    {
                        throughput_11 = _S1752;
                    }
                    bool _S1755 = b_10 == 0U;
                    if(_S1755)
                    {
                        _S1632 = true;
                    }
                    else
                    {
                        _S1632 = b_10 == 6U;
                    }
                    if(_S1632)
                    {
                        float3  _S1756 = sampledHalf(_S1744, _S1746, _S1749, _S1750, surface_13.random_state);
                        throughput_12 = _S1756;
                    }
                    else
                    {
                        throughput_12 = throughput_11;
                    }
                    float _S1757 = _S1541.x;
                    float _S1758 = _S1541.y;
                    Weights _S1759 = lobeWeights(_S1743, _S1744, _S1746, throughput_12, _S1750, _S1751, _S1540, _S1757, _S1758);
                    float _S1760 = (F32_abs((_S1518)));
                    float _S1761 = vndfPDF(_S1744, throughput_12, _S1746, _S1760, _S1749, _S1750, _S1759.v_dot_h);
                    switch(b_10)
                    {
                    case 0U:
                        {
                            float _S1762 = diffusePDF(_S1747, _S1760, _S1540, _S1759);
                            float3  _S1763 = diffuseBSDF(throughput_10, _S1746, _S1540, _S1759);
                            density_7 = _S1762;
                            chain_throughput_2 = _S1763;
                            break;
                        }
                    case 1U:
                        {
                            float _S1764 = refractPDF(dot_0(throughput_10, throughput_12), _S1761, _S1759, _S1757, _S1758);
                            float3  _S1765 = refractBSDF(throughput_10, _S1746, _S1749, _S1750, _S1540, _S1759);
                            density_7 = _S1764;
                            chain_throughput_2 = _S1765;
                            break;
                        }
                    case 4U:
                        {
                            float _S1766 = sheenVelvetPDF(_S1747, _S1760, _S1759);
                            float3  _S1767 = sheenVelvetBSDF(throughput_10, _S1744, _S1746, _S1540, _S1759);
                            density_7 = _S1766;
                            chain_throughput_2 = _S1767;
                            break;
                        }
                    case 6U:
                        {
                            ToonProfile _S1768 = toonProfile(_S1744, _S1746, _S1540);
                            float _S1769 = toonPDF(throughput_10, _S1746, _S1768, _S1759);
                            float3  _S1770 = toonBSDF(throughput_10, _S1746, _S1768, _S1759);
                            density_7 = _S1769;
                            chain_throughput_2 = _S1770;
                            break;
                        }
                    default:
                        {
                            float _S1771 = reflectPDF(_S1761, _S1759);
                            float3  _S1772 = reflectBSDF(throughput_10, _S1746, _S1749, _S1750, _S1759);
                            density_7 = _S1771;
                            chain_throughput_2 = _S1772;
                            break;
                        }
                    }
                    bool _S1773 = density_7 > 0.0f;
                    if(_S1773)
                    {
                        SampleBSDF _S1774 = SampleBSDF_x24init_0(throughput_10, chain_throughput_2, surface_13.random_state, _S1753, b_10, density_7);
                        lobe_5 = _S1774;
                    }
                }
            }
            bool _S1775 = b_10 == 0U;
            if(_S1775)
            {
                _S1632 = true;
            }
            else
            {
                _S1632 = b_10 == 4U;
            }
            if(_S1632)
            {
                _S1691 = true;
            }
            else
            {
                _S1691 = b_10 == 6U;
            }
            if(_S1548)
            {
                _S1692 = false;
            }
            else
            {
                bool _S1776 = !_S1691;
                if(_S1776)
                {
                    bool _S1777 = (_S1540.roughness) == 0.0f;
                    if(_S1777)
                    {
                        _S1692 = true;
                    }
                    else
                    {
                        bool _S1778 = b_10 == 1U;
                        if(_S1778)
                        {
                            _S1692 = (_S1541.x) == (_S1541.y);
                        }
                        else
                        {
                            _S1692 = false;
                        }
                    }
                }
                else
                {
                    _S1692 = false;
                }
            }
            bool _S1779 = !_S1548;
            if(_S1779)
            {
                _S1693 = b_10 == 1U;
            }
            else
            {
                _S1693 = false;
            }
            if(_S1693)
            {
                straight_0 = (_S1540.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1694 = _S1779;
            }
            else
            {
                _S1694 = false;
            }
            if(_S1694)
            {
                _S1695 = b_10 == 1U;
            }
            else
            {
                _S1695 = false;
            }
            if(_S1695)
            {
                _S1696 = (_S1541.x) == (_S1541.y);
            }
            else
            {
                _S1696 = false;
            }
            BSDFMaterial _S1780 = _S1540;
            bool _S1781 = isTranslucent_0(&_S1780);
            if(_S1781)
            {
                _S1697 = _S1775;
            }
            else
            {
                _S1697 = false;
            }
            if(_S1697)
            {
                _S1698 = (dot_0(throughput_10, surface_13.geometry_n)) < 0.0f;
            }
            else
            {
                _S1698 = false;
            }
            if(nee_0)
            {
                _S1699 = !_S1692;
            }
            else
            {
                _S1699 = false;
            }
            if(_S1699)
            {
                _S1700 = !wrong_side_0;
            }
            else
            {
                _S1700 = false;
            }
            if(_S1700)
            {
                float _S1782 = (&lobe_5)->pdf;
                float3  _S1783 = (&ray_3)->origin;
                float3  _S1784 = _slang_select(_S1553, _S1338,_S1517.smooth_n);
                float3  _S1785 = (&ray_3)->origin;
                FKSurface _S1786 = surface_13;
                float3  _S1787 = - _S1517.smooth_n;
                float3  _S1788 = _slang_select(_S1698, _S1787,_S1517.smooth_n);
                NEEVertex _S1789 = NEEVertex_x24init_0(false, _S1782, _S1783, _S1784, _S1785 + make_float3 (_S1786.geometry_offset) * _S1788);
                nee_vertex_1 = _S1789;
            }
            else
            {
                if(_S1548)
                {
                    _S1701 = true;
                }
                else
                {
                    bool _S1790 = b_10 != 1U;
                    if(_S1790)
                    {
                        _S1701 = true;
                    }
                    else
                    {
                        _S1701 = (_S1541.x) != (_S1541.y);
                    }
                }
                if(_S1701)
                {
                    (&nee_vertex_1)->none = true;
                }
            }
            bool _S1791 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1791)
            {
                if(_S1691)
                {
                    _S1701 = true;
                }
                else
                {
                    _S1701 = ((&lobe_5)->pdf * (&prev_1)->cos / ((&hit_4)->distance * (&hit_4)->distance) * threshold_0) <= 1.0f;
                }
            }
            else
            {
                _S1701 = false;
            }
            bool _S1792 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1792)
            {
                if(_S1691)
                {
                    _S1702 = true;
                }
                else
                {
                    _S1702 = (_S1540.roughness) >= 0.20000000298023224f;
                }
            }
            else
            {
                _S1702 = false;
            }
            if(_S1585)
            {
                bool _S1793 = !_S1701;
                if(_S1793)
                {
                    return _S1339;
                }
                bool _S1794 = _S1344 != 1U;
                if(_S1794)
                {
                    _S1703 = _S1344 != 2U;
                }
                else
                {
                    _S1703 = false;
                }
                if(_S1703)
                {
                    float _S1795 = (&lobe_5)->pdf;
                    float _S1796 = _slang_select(nee_0, _S1795,0.0f);
                    float _S1797 = escapeWeight_0(_S1796, _S1711);
                    if(_S1593)
                    {
                        passes_0 = _S1350;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1798 = _slang_select(passes_0, _S1797,1.0f);
                    return Shift_x24init_0(throughput_8 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_9->radiance * make_float3 (_S1798) / make_float3 (r_9->jac), density_5 * (&lobe_5)->pdf / r_9->jac);
                }
                float3  _S1799 = throughput_8 * make_float3 ((&lobe_5)->pdf);
                float _S1800 = density_5 * (&lobe_5)->pdf;
                throughput_11 = _S1799;
                density_7 = _S1800;
            }
            else
            {
                throughput_11 = throughput_8;
                density_7 = density_5;
            }
            uint _S1801 = (fcptLayers((hit_4)));
            bool _S1802 = _S1801 > 1U;
            if(_S1802)
            {
                _S1703 = (b_10 == 1U) != passes_0;
            }
            else
            {
                _S1703 = false;
            }
            if(viewed_1)
            {
                _S1704 = _S1703;
            }
            else
            {
                _S1704 = false;
            }
            if(_S1704)
            {
                return _S1339;
            }
            if(replay_2)
            {
                _S1705 = b_7 <= _S1354;
            }
            else
            {
                _S1705 = false;
            }
            if(_S1705)
            {
                _S1706 = _S1516;
            }
            else
            {
                _S1706 = false;
            }
            if(_S1706)
            {
                _S1707 = _S1701;
            }
            else
            {
                _S1707 = false;
            }
            bool _S1803;
            if(_S1707)
            {
                _S1803 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1803 = !_S1702;
                }
                else
                {
                    _S1803 = false;
                }
            }
            if(_S1803)
            {
                return _S1339;
            }
            if(viewed_1)
            {
                float3  _S1804 = throughput_11 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1805 = (&lobe_5)->pdf;
                throughput_12 = _S1804;
                sky_pdf_3 = _S1805;
            }
            else
            {
                float3  _S1806 = throughput_11 * max_0((&lobe_5)->throughput, _S1338);
                throughput_12 = _S1806;
                sky_pdf_3 = density_7;
            }
            bool _S1807;
            if(_S1557)
            {
                _S1807 = !_S1572;
            }
            else
            {
                _S1807 = false;
            }
            bool _S1808;
            if(_S1807)
            {
                _S1808 = _S1516;
            }
            else
            {
                _S1808 = false;
            }
            bool _S1809;
            if(_S1808)
            {
                _S1809 = _S1701;
            }
            else
            {
                _S1809 = false;
            }
            if(_S1809)
            {
                chain_1 = here_0;
                uint _S1810 = insertBits_0((&chain_1)->path, b_10, 18U, 3U);
                uint _S1811 = _slang_select(nee_0, 1U,0U);
                uint _S1812 = insertBits_0(_S1810, _S1811, 21U, 1U);
                (&chain_1)->path = _S1812;
                float _S1813 = (&chain_1)->jac * (&lobe_5)->pdf;
                (&chain_1)->jac = _S1813;
                (&chain_1)->dir = throughput_10;
                chain_throughput_2 = throughput_12;
            }
            else
            {
                chain_throughput_2 = chain_throughput_1;
            }
            FKSurface _S1814 = surface_13;
            Vertex _S1815 = Vertex_x24init_0(_S1702, b_10, (&lobe_5)->pdf, (F32_abs((dot_0(surface_13.geometry_n, throughput_10)))), is_inside_7);
            prev_1 = _S1815;
            float _S1816 = (&lobe_5)->pdf;
            bool _S1817 = b_10 == 1U;
            bool _S1818;
            if(_S1817)
            {
                _S1818 = (_S1541.x) == (_S1541.y);
            }
            else
            {
                _S1818 = false;
            }
            float sky_pdf_4 = _slang_select(_S1818, sky_pdf_1,_S1816);
            float _S1819 = _slang_select(_S1548, 0.0f,sky_pdf_4);
            float _S1820 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * (&lobe_5)->pdf))))), (3.14159274101257324f)));
            bool _S1821 = !_S1692;
            float _S1822 = _slang_select(_S1821, _S1820,0.0f);
            float _S1823 = spread_1 + _S1822;
            bool _S1824;
            if(refracted_4)
            {
                _S1824 = !_S1698;
            }
            else
            {
                _S1824 = false;
            }
            bool is_inside_8;
            if(_S1824)
            {
                bool _S1825 = !is_inside_7;
                is_inside_8 = _S1825;
            }
            else
            {
                is_inside_8 = is_inside_7;
            }
            FKSurface _S1826 = surface_13;
            bool _S1827 = boundsVolume_0(&_S1826);
            bool _S1828;
            if(_S1827)
            {
                _S1828 = !_S1703;
            }
            else
            {
                _S1828 = false;
            }
            if(_S1828)
            {
                FKSurface faced_2 = surface_13;
                float3  _S1829 = - _S1814.geometry_n;
                float3  _S1830 = _slang_select(turned_1, _S1829,_S1814.geometry_n);
                (&faced_2)->geometry_n = _S1830;
                FKMedium _S1831 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1832 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1833 = faced_2;
                FKMedium _S1834 = _S1831;
                FKMedium _S1835 = _S1832;
                MediumSides _S1836 = mediumSides_0(&_S1833, &_S1834, filling_2, (&ray_3)->unit_direction, &_S1835);
                bool _S1837 = ((dot_0(throughput_10, _S1814.geometry_n)) > 0.0f) == ((dot_0(_S1814.geometry_n, (&faced_2)->geometry_n)) > 0.0f);
                float3  _S1838 = _slang_select(_S1837, _S1836.front.scatter,_S1836.behind.scatter);
                scatter_in_0 = _S1838;
                float3  _S1839 = scatter_in_0;
                float _S1840 = upsample(scatter_in_0, wavelength_10);
                float3  _S1841 = make_float3 (_S1840);
                float3  _S1842 = _slang_select(_S1580, _S1841,_S1839);
                scatter_in_0 = _S1842;
                float3  _S1843 = _slang_select(_S1837, _S1836.front.extinction,_S1836.behind.extinction);
                extinction_in_0 = _S1843;
                float3  _S1844 = extinction_in_0;
                float _S1845 = upsample(extinction_in_0, wavelength_10);
                float3  _S1846 = make_float3 (_S1845);
                float3  _S1847 = _slang_select(_S1580, _S1846,_S1844);
                extinction_in_0 = _S1847;
                float _S1848 = _slang_select(_S1837, _S1836.front.g,_S1836.behind.g);
                g_in_0 = _S1848;
                uint _S1849 = _S1836.fillings.x;
                uint _S1850 = _S1836.fillings.y;
                uint _S1851 = _slang_select(_S1837, _S1850,_S1849);
                bool _S1852 = (fcptVaryingUsed());
                uint _S1853 = _slang_select(_S1852, _S1851,4294967295U);
                filling_2 = _S1853;
            }
            (&ray_3)->unit_direction = throughput_10;
            bool _S1854 = !_S1703;
            if(_S1854)
            {
                FKSurface _S1855 = surface_13;
                float _S1856 = _slang_select(straight_0, 0.0f,_S1855.geometry_offset);
                float3  _S1857 = - _S1517.smooth_n;
                bool _S1858 = is_inside_8 != _S1698;
                float3  _S1859 = _slang_select(_S1858, _S1857,_S1517.smooth_n);
                float3  _S1860 = (&ray_3)->origin + make_float3 (_S1856) * _S1859;
                (&ray_3)->origin = _S1860;
            }
            throughput_11 = throughput_12;
            chain_throughput_1 = chain_throughput_2;
            density_7 = sky_pdf_3;
            passes_0 = _S1703;
            viewed_1 = _S1696;
            sky_pdf_3 = _S1819;
            spread_4 = _S1823;
            reconnection_0 = reconnection_1;
            is_inside_6 = is_inside_8;
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
            is_inside_6 = is_inside_7;
        }
        float density_8;
        if(_S1557)
        {
            if(_S1480)
            {
                float3  _S1861 = pathColor(throughput_11 * emission_1, spectral_weight_1, wavelength_10);
                Reservoir candidate_8 = chain_1;
                uint _S1862 = extractBits_0((&chain_1)->path, 10U, 2U);
                bool _S1863 = _S1862 == 1U;
                if(_S1863)
                {
                    float3  _S1864 = safeDivide(_S1861, chain_throughput_1);
                    (&candidate_8)->radiance = _S1864;
                }
                Reservoir _S1865 = withEnd(candidate_8, 2U, b_7, _S1861);
                offer(sel_8, _S1865, _S1861 * make_float3 (scale_4) / make_float3 (density_7));
            }
            if(_S1480)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1866 = survivalProbability(abs_0(throughput_11), density_7);
                density_8 = _S1866;
            }
            else
            {
                density_8 = 1.0f;
            }
            uint _S1867 = (fcptMaxBounces());
            bool _S1868 = b_7 >= _S1867;
            if(_S1868)
            {
                wrong_side_0 = true;
            }
            else
            {
                bool _S1869 = density_8 < 1.0f;
                if(_S1869)
                {
                    uint _S1870 = noiseAddress(_S1366, b_7);
                    Random _S1871 = draw(_S1870, 8U);
                    wrong_side_0 = density_8 < (_S1871.value);
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
            float _S1872 = density_7 * density_8;
            density_8 = _S1872;
        }
        else
        {
            density_8 = density_7;
        }
        uint _S1873 = layer_0 ^ 1U;
        uint _S1874 = _slang_select(passes_0, _S1873,0U);
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
            uint _S1875 = b_10 + 1U;
            b_7 = _S1875;
            layer_0 = _S1874;
            continue;
        }
        FKRay _S1876 = ray_3;
        float _S1877 = distance_1(reconnection_0, (&ray_3)->origin) * 1.0010000467300415f;
        if(replay_2)
        {
            refracted_4 = _S1586;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S1343 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1878 = _slang_select(wrong_side_0, _S1877,4.294967296e+09f);
        bool _S1879 = !_S1548;
        if(straight_0)
        {
            _S1631 = true;
        }
        else
        {
            _S1631 = _S1548;
        }
        FKHit _S1880;
        if(_S1631)
        {
            _S1880 = hit_4;
        }
        else
        {
            _S1880 = _S1603;
        }
        FKHit _S1881 = (fcptTraverseInstanceBVH((_S1876), (_S1486), (_S1878), (_S1879), (_S1880), (viewed_1)));
        hit_4 = _S1881;
        if(replay_2)
        {
            _S1632 = _S1586;
        }
        else
        {
            _S1632 = false;
        }
        if(_S1632)
        {
            _S1691 = _S1343 == 1U;
        }
        else
        {
            _S1691 = false;
        }
        if(_S1691)
        {
            _S1692 = ((&hit_4)->instance_index) == (_S1355.instance_index);
        }
        else
        {
            _S1692 = false;
        }
        if(_S1692)
        {
            _S1693 = ((&hit_4)->triangle_index) == (_S1355.triangle_index);
        }
        else
        {
            _S1693 = false;
        }
        if(_S1693)
        {
            (&hit_4)->uv = _S1355.uv;
            float _S1882 = distance_1(reconnection_0, (&ray_3)->origin);
            (&hit_4)->distance = _S1882;
        }
        if(replay_2)
        {
            _S1694 = _S1586;
        }
        else
        {
            _S1694 = false;
        }
        if(_S1694)
        {
            _S1695 = _S1343 == 3U;
        }
        else
        {
            _S1695 = false;
        }
        if(_S1695)
        {
            _S1696 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1696 = false;
        }
        if(_S1696)
        {
            return _S1339;
        }
        Reservoir _S1883 = chain_1;
        uint _S1884 = filling_2;
        for(;;)
        {
            bool _S1885 = (fcptVaryingUsed());
            if(_S1885)
            {
                _S1697 = _S1884 != 4294967295U;
            }
            else
            {
                _S1697 = false;
            }
            if(_S1697)
            {
                float _S1886 = (fcptMajorant((_S1884)));
                _S1698 = _S1886 > 0.0f;
            }
            else
            {
                _S1698 = any_1(scatter_in_0 > make_float3 (0.0f));
            }
            if(replay_2)
            {
                _S1699 = _S1586;
            }
            else
            {
                _S1699 = false;
            }
            if(_S1699)
            {
                _S1700 = _S1343 == 1U;
            }
            else
            {
                _S1700 = false;
            }
            if(_S1700)
            {
                _S1701 = _S1698;
            }
            else
            {
                _S1701 = false;
            }
            if(_S1701)
            {
                ended_0 = _S1339;
                sky_pdf_2 = sky_pdf_3;
                spread_2 = spread_4;
                width_4 = width_3;
                density_4 = density_8;
                throughput_12 = throughput_11;
                b_10 = b_7;
                _S1702 = true;
                break;
            }
            bool _S1887 = (&prev_1)->rough;
            if(_S1887)
            {
                _S1702 = !_S1698;
            }
            else
            {
                _S1702 = false;
            }
            (&prev_1)->rough = _S1702;
            uint _S1888 = b_7 + 320U;
            bool _S1889 = b_7 == 4294967295U;
            uint _S1890 = _slang_select(_S1889, 384U,_S1888);
            uint _S1891 = stream(_S1366, _S1890);
            uint tracking_1 = _S1891;
            weight_2 = throughput_4;
            glowed_0 = _S1338;
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
                    _S1337 = int(2);
                    break;
                }
                float _S1892 = (&hit_4)->distance;
                if(_S1697)
                {
                    float3  _S1893 = (&ray_3)->origin;
                    float3  _S1894 = (&ray_3)->unit_direction;
                    float _S1895 = (&hit_4)->distance;
                    bool _S1896 = b_10 == 4294967295U;
                    uint _S1897 = _slang_select(_S1896, 0U,b_10);
                    uint _S1898 = (&prev_1)->lobe;
                    uint _S1899 = _slang_select(_S1896, 3U,_S1898);
                    float _S1900 = (fcptTrackMedium((_S1884), (_S1893), (_S1894), (_S1895), (&tracking_1), (&weight_2), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1897), (_S1899), (_S1896)));
                    spread_3 = _S1900;
                }
                else
                {
                    if(_S1698)
                    {
                        uint _S1901 = noiseAddress(_S1366, b_10);
                        Random _S1902 = draw(_S1901, 10U);
                        float _S1903 = 3.0f * _S1902.value;
                        uint _S1904 = (U32_min((uint(_S1903)), (2U)));
                        float _S1905 = - (F32_log((1.0f - (_S1903 - float(_S1904))))) / *_slang_vector_get_element_ptr(&scatter_in_0, _S1904);
                        spread_3 = _S1905;
                    }
                    else
                    {
                        spread_3 = _S1892;
                    }
                }
                bool _S1906 = !(spread_3 < ((&hit_4)->distance));
                if(_S1906)
                {
                    _S1337 = int(2);
                    break;
                }
                if(_S1697)
                {
                    _S1703 = _S1557;
                }
                else
                {
                    _S1703 = false;
                }
                if(_S1703)
                {
                    float3  _S1907 = pathColor(throughput_12 * glowed_0, spectral_weight_1, wavelength_10);
                    float3  _S1908 = _S1907 / make_float3 (density_4);
                    float3  _S1909 = sel_8->glow + _S1908;
                    sel_8->glow = _S1909;
                }
                else
                {
                }
                glowed_0 = _S1338;
                uint b_11 = b_10 + 1U;
                float3  _S1910 = (&ray_3)->origin + make_float3 (spread_3) * (&ray_3)->unit_direction;
                (&ray_3)->origin = _S1910;
                float3  _S1911 = flightWeight_0(scatter_in_0, extinction_in_0, spread_3, true);
                float3  _S1912 = weight_2;
                float _S1913 = upsample(weight_2, wavelength_10);
                float3  _S1914 = make_float3 (_S1913);
                float3  _S1915 = _slang_select(_S1580, _S1914,_S1912);
                float3  _S1916 = _slang_select(_S1697, _S1915,_S1911);
                float3  throughput_13 = throughput_12 * _S1916;
                uint _S1917 = stream(_S1366, b_11 + 320U);
                tracking_1 = _S1917;
                weight_2 = throughput_4;
                float width_8 = width_4 + spread_2 * spread_3;
                float _S1918 = spread_2 + 3.14159274101257324f;
                if(_S1557)
                {
                    _S1704 = true;
                }
                else
                {
                    bool _S1919 = b_11 == _S1354;
                    if(_S1919)
                    {
                        _S1704 = !_S1697;
                    }
                    else
                    {
                        _S1704 = false;
                    }
                }
                TreeSample light_4;
                if(_S1704)
                {
                    float3  _S1920 = (&ray_3)->origin;
                    float3  _S1921 = (&ray_3)->unit_direction;
                    float3  _S1922 = (&ray_3)->unit_direction;
                    uint _S1923 = noiseAddress(_S1366, b_11);
                    float3  _S1924 = extinction_in_0;
                    float3  _S1925 = extinction_in_0;
                    uint2  _S1926 = make_uint2 (_S1884);
                    float3  _S1927 = (&ray_3)->unit_direction;
                    uint _S1928 = arrivalLobe_0(b_11, (&prev_1)->lobe);
                    FKHit _S1929 = _S1603;
                    ShadowContext _S1930 = ShadowContext_x24init_0(_S1924, _S1925, _S1926, _S1927, b_11, _S1928, false, spread_3, width_8, &_S1929, false);
                    ShadowContext _S1931 = _S1930;
                    TreeSample _S1932 = sampleLightTree_0(_S1920, _S1921, _S1922, 0.0f, true, _S1923, &_S1931);
                    light_4 = _S1932;
                }
                else
                {
                    light_4 = _S1600;
                }
                float _S1933 = phaseHG_0(g_in_0, dot_0((&ray_3)->unit_direction, light_4.dir));
                uint _S1934 = (fcptMaxBounces());
                bool _S1935 = b_11 < _S1934;
                if(_S1935)
                {
                    _S1705 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1705 = false;
                }
                float _S1936 = _slang_select(_S1705, _S1933,0.0f);
                float3  _S1937 = throughput_13 * light_4.radiance;
                float _S1938 = powerHeuristic(light_4.density, _S1936);
                float3  _S1939 = pathColor(_S1937 * make_float3 (_S1933 * _S1938), spectral_weight_1, wavelength_10);
                float3  _S1940 = _slang_select(_S1704, _S1939,_S1338);
                if(replay_2)
                {
                    _S1706 = b_11 == _S1354;
                }
                else
                {
                    _S1706 = false;
                }
                if(_S1706)
                {
                    bool _S1941 = _S1343 == 2U;
                    if(_S1941)
                    {
                        float _S1942 = resamplingTarget(_S1940);
                        _S1707 = _S1942 > 0.0f;
                    }
                    else
                    {
                        _S1707 = false;
                    }
                    if(_S1707)
                    {
                        Shift _S1943 = Shift_x24init_0(_S1940, 1.0f);
                        _S1337 = int(1);
                        ended_0 = _S1943;
                        spread_3 = _S1918;
                        width_5 = width_8;
                        throughput_10 = throughput_13;
                        b_8 = b_11;
                        break;
                    }
                    _S1337 = int(1);
                    ended_0 = _S1339;
                    spread_3 = _S1918;
                    width_5 = width_8;
                    throughput_10 = throughput_13;
                    b_8 = b_11;
                    break;
                }
                if(_S1557)
                {
                    Reservoir candidate_9 = _S1883;
                    uint _S1944 = extractBits_0(_S1883.path, 24U, 8U);
                    uint _S1945 = insertBits_0(0U, _S1944, 24U, 8U);
                    uint _S1946 = extractBits_0(_S1883.path, 10U, 2U);
                    bool _S1947 = _S1946 == 1U;
                    if(_S1947)
                    {
                        float3  _S1948 = safeDivide(_S1940, chain_throughput_1);
                        (&candidate_9)->radiance = _S1948;
                    }
                    else
                    {
                        uint _S1949 = insertBits_0(_S1945, b_11 + 1U, 5U, 5U);
                        uint _S1950 = insertBits_0(_S1949, 2U, 10U, 2U);
                        (&candidate_9)->path = _S1950;
                    }
                    Reservoir _S1951 = withEnd(candidate_9, 0U, b_11, _S1940);
                    offer(sel_8, _S1951, _S1940 * make_float3 (scale_4) / make_float3 (density_4));
                    float _S1952 = survivalProbability(abs_0(throughput_13), density_4);
                    uint _S1953 = (fcptMaxBounces());
                    bool _S1954 = b_11 >= _S1953;
                    if(_S1954)
                    {
                        _S1707 = true;
                    }
                    else
                    {
                        bool _S1955 = _S1952 < 1.0f;
                        if(_S1955)
                        {
                            uint _S1956 = noiseAddress(_S1366, b_11);
                            Random _S1957 = draw(_S1956, 8U);
                            _S1707 = _S1952 < (_S1957.value);
                        }
                        else
                        {
                            _S1707 = false;
                        }
                    }
                    if(_S1707)
                    {
                        _S1337 = int(1);
                        ended_0 = _S1339;
                        spread_3 = _S1918;
                        width_5 = width_8;
                        throughput_10 = throughput_13;
                        b_8 = b_11;
                        break;
                    }
                    float _S1958 = density_4 * _S1952;
                    density_4 = _S1958;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1959 = noiseAddress(_S1366, b_11);
                float3  _S1960 = samplePhase_0(g_in_0, (&ray_3)->unit_direction, _S1959, &phase_pdf_1);
                (&ray_3)->unit_direction = _S1960;
                NEEVertex _S1961 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_3)->origin, _S1338, (&ray_3)->origin);
                nee_vertex_1 = _S1961;
                Vertex _S1962 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_6);
                prev_1 = _S1962;
                float _S1963 = (&prev_1)->pdf;
                FKRay _S1964 = ray_3;
                FKHit _S1965 = (fcptTraverseInstanceBVH((_S1964), (true), (4.294967296e+09f), (false), (_S1603), (false)));
                hit_4 = _S1965;
                b_10 = b_11;
                throughput_12 = throughput_13;
                spread_2 = _S1918;
                width_4 = width_8;
                sky_pdf_2 = _S1963;
            }
            if(_S1337 != int(2))
            {
                spread_2 = spread_3;
                width_4 = width_5;
                throughput_12 = throughput_10;
                b_10 = b_8;
                _S1702 = true;
                break;
            }
            ended_0 = _S1339;
            _S1702 = false;
            break;
        }
        if(_S1702)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1703 = b_10 == b_7;
        }
        else
        {
            _S1703 = false;
        }
        bool _S1966 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S1966)
        {
            Reservoir _S1967 = chain_1;
            FKRay _S1968 = ray_3;
            Vertex _S1969 = prev_1;
            NEEVertex _S1970 = nee_vertex_1;
            Shift _S1971 = escape_0(r_9, replay_2, _S1354, _S1343, _S1341, _S1344, scale_4, _S1368, &_S1967, chain_throughput_1, b_10, &_S1968, throughput_12, density_4, &_S1969, &_S1970, sky_pdf_2, spectral_weight_1, wavelength_10, sel_8);
            return _S1971;
        }
        FKHit _S1972 = hit_4;
        uint _S1973 = filling_2;
        float3  _S1974 = scatter_in_0;
        float3  _S1975 = extinction_in_0;
        float3  _S1976 = weight_2;
        float3  _S1977 = glowed_0;
        float3  _S1978 = (&ray_3)->origin + make_float3 (_S1972.distance) * (&ray_3)->unit_direction;
        (&ray_3)->origin = _S1978;
        bool _S1979 = (fcptVaryingUsed());
        if(_S1979)
        {
            _S1704 = _S1973 != 4294967295U;
        }
        else
        {
            _S1704 = false;
        }
        if(_S1704)
        {
            if(_S1557)
            {
                float3  _S1980 = pathColor(throughput_12 * _S1977, spectral_weight_1, wavelength_10);
                float3  _S1981 = _S1980 / make_float3 (density_4);
                float3  _S1982 = sel_8->glow + _S1981;
                sel_8->glow = _S1982;
            }
            else
            {
            }
            float3  _S1983 = throughput_12 * _S1976;
            throughput_10 = _S1983;
        }
        else
        {
            float3  _S1984 = flightWeight_0(_S1974, _S1975, _S1972.distance, false);
            float3  _S1985 = throughput_12 * _S1984;
            throughput_10 = _S1985;
        }
        float width_9 = width_4 + spread_2 * _S1972.distance;
        viewed_0 = _S1703;
        width_3 = width_9;
        throughput_3 = throughput_10;
        density_3 = density_4;
        sky_pdf_1 = sky_pdf_2;
        spread_1 = spread_2;
        uint _S1875 = b_10 + 1U;
        b_7 = _S1875;
        layer_0 = _S1874;
    }
    return _S1339;
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
    Random _S1986 = pcg(state_3);
    Random _S1987 = pcg(_S1986.state);
    float _S1988 = 6.28318548202514648f * _S1986.value;
    float _S1989 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S1987.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1987.state, _S1989 * (F32_cos((_S1988))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_4, float3  value_2)
{
    RandomSphere _S1990;
    (&_S1990)->state = state_4;
    (&_S1990)->value = value_2;
    return _S1990;
}

__device__ RandomSphere random_sphere(uint state_5)
{
    Random _S1991 = normal_distribution(state_5);
    Random _S1992 = normal_distribution(_S1991.state);
    Random _S1993 = normal_distribution(_S1992.state);
    float3  _S1994 = make_float3 (_S1991.value, _S1992.value, _S1993.value);
    float3  _S1995 = ((((_S1994)) * make_float3(rnorm3df(((_S1994)).x, ((_S1994)).y, ((_S1994)).z))));
    return RandomSphere_x24init_0(_S1993.state, _S1995);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_11)
{
    float3  _S1996 = p1_0 - p0_0;
    float3  _S1997 = p2_0 - p0_0;
    float2  _S1998 = uv1_0 - uv0_0;
    float2  _S1999 = uv2_0 - uv0_0;
    float _S2000 = _S1998.x;
    float _S2001 = _S1999.y;
    float _S2002 = _S1998.y;
    float _S2003 = _S1999.x;
    float _S2004 = _S2000 * _S2001 - _S2002 * _S2003;
    float _S2005 = 1.0f / _S2004;
    float3  t_24 = (_S1996 * make_float3 (_S2001) - _S1997 * make_float3 (_S2002)) * make_float3 (_S2005);
    float3  _S2006 = (_S1997 * make_float3 (_S2000) - _S1996 * make_float3 (_S2003)) * make_float3 (_S2005);
    float3  _S2007 = t_24 - n_11 * make_float3 (dot_0(n_11, t_24));
    float3  _S2008 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_11);
    bool _S2009 = (dot_0(_S2007, _S2007)) > 0.0f;
    float3  _S2010 = _slang_select(_S2009, _S2007,_S2008);
    float3  _S2011 = ((((_S2010)) * make_float3(rnorm3df(((_S2010)).x, ((_S2010)).y, ((_S2010)).z))));
    bool _S2012 = (dot_0(cross_0(n_11, _S2011), _S2006)) > 0.0f;
    float3  t_25;
    if(_S2012)
    {
        float3  _S2013 = negate_0(_S2011);
        t_25 = _S2013;
    }
    else
    {
        t_25 = _S2011;
    }
    float3  _S2014 = cross_0(n_11, t_25);
    return makeMatrix<float, 3, 3> (t_25, _S2014, n_11);
}

__device__ float3  tangentToWorldNormalMap(float3  v_10, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_10, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_4, float3  uvw_0, float3  position_0)
{
    float3  _S2015 = t1_0 - t0_0;
    float3  _S2016 = t2_2 - t0_0;
    float3  _S2017 = t2_2 - t1_0;
    float _S2018 = (F32_min((length_0(_S2015)), ((F32_min((length_0(_S2016)), (length_0(_S2017)))))));
    float3  _S2019 = make_float3 (distance_1(position_0, t0_0), distance_1(position_0, t1_0), distance_1(position_0, t2_2));
    float3  _S2020 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S2021 = dot_0(geometry_n_4, _S2020);
    float3  _S2022 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S2023 = dot_0(geometry_n_4, _S2022);
    float3  _S2024 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S2025 = acos_0(abs_0(make_float3 (_S2021, _S2023, dot_0(geometry_n_4, _S2024))));
    float3  _S2026 = clamp_2(tan_0(_S2025), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S2019 * _S2026, uvw_0), 0.0f, _S2018 * 0.125f);
}

__device__ float3  straightThrough(BSDFMaterial material_26)
{
    return make_float3 (material_26.transmission * (1.0f - material_26.metallic)) * material_26.albedo;
}

__device__ float hairRow(float3  in_dir_11, float3  t_26, float3  out_dir_3, uint p_15, float w_19, float alpha_10, uint nt_0)
{
    uint _S2027 = p_15 % 4U;
    float _S2028 = w_19 * HAIR_WIDTHS_0[_S2027];
    float _S2029 = (F32_asin((clamp_1(dot_0(out_dir_3, t_26), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_11, t_26), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S2027] * alpha_10;
    return ((F32_asinh((_S2029 / _S2028))) / (F32_asinh((3.14159274101257324f / _S2028))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_12, float3  t_27, float3  out_dir_4, uint np_0)
{
    float3  _S2030 = worldToTangent(out_dir_4, t_27);
    float3  _S2031 = worldToTangent(in_dir_12, t_27);
    return (F32_frac((((F32_atan2((_S2030.z), (_S2030.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S2031.z), (1.17549435082228751e-38f - _S2031.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_13, float3  t_28, uint p_16, float row_0, float column_0, float w_20, float alpha_11, uint nt_1, uint np_1)
{
    float3  _S2032 = worldToTangent(in_dir_13, t_28);
    uint _S2033 = p_16 % 4U;
    float _S2034 = w_20 * HAIR_WIDTHS_0[_S2033];
    float _S2035 = (F32_asin((clamp_1(dot_0(in_dir_13, t_28), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S2033] * alpha_11 + _S2034 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S2034))))));
    float _S2036 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S2032.z), (1.17549435082228751e-38f - _S2032.x)));
    float _S2037 = (F32_cos((_S2035)));
    float3  _S2038 = tangentToWorld(make_float3 (_S2037 * (F32_cos((_S2036))), (F32_sin((_S2035))), _S2037 * (F32_sin((_S2036)))), t_28);
    return _S2038;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_12, BSDFMaterial material_27, float coverage_1)
{
    float3  _S2039;
    if((material_27.ior) == 1.0f)
    {
        float3  _S2040 = straightThrough(material_27);
        _S2039 = _S2040;
    }
    else
    {
        _S2039 = make_float3 (0.0f);
    }
    return _S2039 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_8, Reservoir r_10, bool replay_3, float scale_5, Selection * sel_9)
{
    Domain _S2041 = dom_8;
    Reservoir _S2042 = r_10;
    Shift _S2043 = walk_0(&_S2041, &_S2042, replay_3, scale_5, sel_9);
    return _S2043;
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

__device__ uint noiseWhite(uint x_29, uint y_8, uint t_29, uint size_0)
{
    FixedArray<uint, 4>  ranks_0;
    uint i_31 = 0U;
    for(;;)
    {
        if(i_31 < 4U)
        {
        }
        else
        {
            break;
        }
        uint _S2044 = size_0 - 1U;
        uint _S2045 = (x_29 + size_0 / 2U) & _S2044;
        bool _S2046 = i_31 < 2U;
        uint _S2047 = _slang_select(_S2046, x_29,_S2045);
        uint l_6 = _S2047;
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
            uint _S2048 = hash(((r_11 ^ (t_29 << 16U)) ^ (k_4 << 28U)) ^ ((i_31 & 1U) << 31U));
            uint _S2049 = l_6 ^ (_S2048 & _S2044);
            uint k_5 = k_4 + 1U;
            l_6 = r_11;
            r_11 = _S2049;
            k_4 = k_5;
        }
        uint _S2050 = l_6 + r_11 * size_0;
        uint _S2051 = size_0 * size_0;
        uint _S2052;
        if(_S2051 >= 65536U)
        {
            uint _S2053 = _S2050 / (_S2051 / 65536U);
            _S2052 = _S2053;
        }
        else
        {
            uint _S2054 = 65536U / _S2051;
            _S2052 = _S2050 * _S2054;
        }
        ranks_0[i_31] = _S2052;
        uint i_32 = i_31 + 1U;
        i_31 = i_32;
    }
    bool _S2055 = (ranks_0[int(0)]) == 65535U;
    bool _S2056;
    if(_S2055)
    {
        _S2056 = (ranks_0[int(1)]) == 65535U;
    }
    else
    {
        _S2056 = false;
    }
    bool _S2057 = (ranks_0[int(2)]) == 65535U;
    bool _S2058;
    if(_S2057)
    {
        _S2058 = (ranks_0[int(3)]) == 65535U;
    }
    else
    {
        _S2058 = false;
    }
    if(_S2056)
    {
        _S2056 = (ranks_0[int(3)]) != 65535U;
    }
    else
    {
        _S2056 = false;
    }
    if(_S2056)
    {
        _S2056 = true;
    }
    else
    {
        if(_S2058)
        {
            _S2056 = (ranks_0[int(1)]) != 65535U;
        }
        else
        {
            _S2056 = false;
        }
    }
    uint _S2059 = ranks_0[int(0)];
    uint _S2060 = ranks_0[int(1)];
    uint _S2061 = ranks_0[int(3)];
    uint _S2062 = _slang_select(_S2056, _S2061,_S2060);
    return _S2059 | (_S2062 << 16U);
}

__device__ uint3  noiseBlock(uint sweep_0, uint colour_0, uint block_0, uint size_1)
{
    uint _S2063 = hash(sweep_0 * 7919U + 1U);
    uint _S2064 = size_1 / 16U;
    uint _S2065 = block_0 % _S2064;
    uint _S2066 = block_0 / _S2064;
    uint _S2067 = _S2066 % _S2064;
    uint _S2068 = block_0 / (_S2064 * _S2064);
    uint3  _S2069 = make_uint3 (_S2065, _S2067, _S2068);
    uint3  _S2070 = make_uint3 (colour_0 & 1U, (colour_0 >> 1U) & 1U, colour_0 >> 2U);
    return _S2069 * make_uint3 (16U) + _S2070 * make_uint3 (8U) + make_uint3 (_S2063 & 7U, (_S2063 >> 3U) & 7U, (_S2063 >> 6U) & 7U);
}

#undef Matrix
