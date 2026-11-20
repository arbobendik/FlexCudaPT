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
};

static __device__ Weights Weights_x24init_0(float v_dot_h_0, float3  refracted_1, float3  F_0, float reflect_weight_0, float3  diffuse_weight_0, float3  refract_weight_0, float p_diffuse_0, float p_reflect_0, float p_refract_0, float p_sheen_velvet_0, float p_toon_0, float3  sheen_0)
{
    Weights _S331;
    (&_S331)->v_dot_h = v_dot_h_0;
    (&_S331)->refracted = refracted_1;
    (&_S331)->F = F_0;
    (&_S331)->reflect_weight = reflect_weight_0;
    (&_S331)->diffuse_weight = diffuse_weight_0;
    (&_S331)->refract_weight = refract_weight_0;
    (&_S331)->p_diffuse = p_diffuse_0;
    (&_S331)->p_reflect = p_reflect_0;
    (&_S331)->p_refract = p_refract_0;
    (&_S331)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S331)->p_toon = p_toon_0;
    (&_S331)->sheen = sheen_0;
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

__device__ __forceinline__ float3  sampledHalf(float3  v_3, float3  n_i_2, float alpha_2, AnisotropicFrame frame_1, uint random_state_3)
{
    uint state_3 = random_state_3;
    float3  _S371 = sampleHalfVector(v_3, n_i_2, alpha_2, frame_1, &state_3);
    return _S371;
}

__device__ __forceinline__ float3  refractedHalf(float3  in_dir_0, float3  out_dir_0, float3  n_4, float eta_i_0, float eta_o_0)
{
    float3  _S372 = negate_0(in_dir_0);
    float3  _S373 = negate_0(make_float3 (eta_i_0) * _S372 + make_float3 (eta_o_0) * out_dir_0);
    float3  _S374 = ((((_S373)) * make_float3(rnorm3df(((_S373)).x, ((_S373)).y, ((_S373)).z))));
    float _S375 = sign_0(dot_0(n_4, _S372));
    float _S376 = sign_0(dot_0(_S373, n_4 * make_float3 (_S375)));
    return _S374 * make_float3 (_S376);
}

__device__ __forceinline__ float3  reflectedHalf(float3  in_dir_1, float3  out_dir_1)
{
    float3  _S377 = negate_0(in_dir_1);
    float3  _S378 = _S377 + out_dir_1;
    float3  _S379 = ((((_S378)) * make_float3(rnorm3df(((_S378)).x, ((_S378)).y, ((_S378)).z))));
    return _S379;
}

static __device__ float3  refract_0(float3  i_5, float3  n_5, float eta_0)
{
    float _S380 = dot_0(n_5, i_5);
    float _S381 = 1.0f - eta_0 * eta_0 * (1.0f - _S380 * _S380);
    if(_S381 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_5 - make_float3 (eta_0 * _S380 + (F32_sqrt((_S381)))) * n_5;
}

__device__ float fresnel(float cos_theta_0, float eta_i_1, float eta_o_1)
{
    float _S382 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S383 = eta_i_1 / eta_o_1 * _S382;
    bool _S384 = _S383 < 1.0f;
    float kr_0;
    if(_S384)
    {
        float _S385 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S383 * _S383))))));
        float _S386 = eta_o_1 * cos_theta_0;
        float _S387 = eta_i_1 * _S385;
        float _S388 = (_S386 - _S387) / (_S386 + _S387);
        float _S389 = eta_i_1 * cos_theta_0;
        float _S390 = eta_o_1 * _S385;
        float _S391 = (_S389 - _S390) / (_S389 + _S390);
        float _S392 = (_S388 * _S388 + _S391 * _S391) / 2.0f;
        kr_0 = _S392;
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

__device__ __forceinline__ Weights lobeWeights(float3  in_dir_2, float3  v_4, float3  n_i_3, float3  ggx_n_0, AnisotropicFrame frame_2, BSDFMaterial material_1, float eta_i_2, float eta_o_2)
{
    float _S393 = dot_0(ggx_n_0, v_4);
    float _S394 = eta_i_2 / eta_o_2;
    float3  _S395 = refract_0(in_dir_2, ggx_n_0, _S394);
    float3  _S396 = ((((_S395)) * make_float3(rnorm3df(((_S395)).x, ((_S395)).y, ((_S395)).z))));
    float _S397 = (F32_min(((F32_sqrt((material_1.specular_level))) * (F32_abs((eta_i_2 - eta_o_2))) / (eta_i_2 + eta_o_2)), (0.9999847412109375f)));
    float _S398 = _S397 * _S397;
    float _S399 = (1.0f + _S397) / (1.0f - _S397);
    float _S400 = (F32_abs((_S393)));
    bool _S401 = eta_i_2 > eta_o_2;
    float sheen_component_0;
    if(_S401)
    {
        sheen_component_0 = _S399;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    float toon_component_0;
    if(_S401)
    {
        toon_component_0 = 1.0f;
    }
    else
    {
        toon_component_0 = _S399;
    }
    float _S402 = fresnel(_S400, sheen_component_0, toon_component_0);
    bool _S403 = (eta_i_2 * eta_i_2 * (1.0f - _S393 * _S393)) >= (eta_o_2 * eta_o_2);
    float3  _S404;
    if(_S403)
    {
        _S404 = make_float3 (1.0f);
    }
    else
    {
        float3  _S405 = material_1.specular_tint * make_float3 (_S398);
        _S404 = _S405 + (make_float3 (1.0f) - _S405) * make_float3 (_S402 - _S398) / make_float3 (1.0f - _S398);
    }
    float3  _S406 = make_float3 (1.0f);
    float3  _S407 = make_float3 (0.0f);
    float _S408 = rgb_to_greyscale(material_1.sheen);
    bool _S409 = _S408 > 0.0f;
    float3  sheen_1;
    float3  scale_1;
    if(_S409)
    {
        float _S410 = clamp_1((F32_sqrt(((F32_max((dot_0(n_i_3, v_4)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S411 = (U32_min((uint(_S410)), (22U)));
        float least_0 = (F32_sqrt((0.05000000074505806f)));
        float _S412 = (F32_sqrt((0.10000000149011612f)));
        bool _S413 = (material_1.velvet) > 0.0f;
        float _S414 = _slang_select(_S413, _S412,least_0);
        float _S415 = (clamp_1((F32_sqrt(((F32_max((material_1.sheen_roughness), (0.0f)))))), _S414, 1.0f) - _S414) / (1.0f - _S414) * 23.0f;
        uint _S416 = (U32_min((uint(_S415)), (22U)));
        uint _S417 = _S411 * 24U + _S416;
        float _S418 = _S410 - float(_S411);
        float _S419 = _S415 - float(_S416);
        uint _S420 = _S417 + 24U;
        float a_5 = SHEEN_ALBEDO_0[_S417] + (SHEEN_ALBEDO_0[_S420] - SHEEN_ALBEDO_0[_S417]) * _S418;
        uint _S421 = _S417 + 1U;
        uint _S422 = _S420 + 1U;
        float b_1 = SHEEN_ALBEDO_0[_S421] + (SHEEN_ALBEDO_0[_S422] - SHEEN_ALBEDO_0[_S421]) * _S418;
        float _S423 = (F32_exp((a_5 + (b_1 - a_5) * _S419)));
        if(_S413)
        {
            float a_6 = VELVET_ALBEDO_0[_S417] + (VELVET_ALBEDO_0[_S420] - VELVET_ALBEDO_0[_S417]) * _S418;
            float b_2 = VELVET_ALBEDO_0[_S421] + (VELVET_ALBEDO_0[_S422] - VELVET_ALBEDO_0[_S421]) * _S418;
            float _S424 = a_6 + (b_2 - a_6) * _S419;
            sheen_component_0 = _S424;
        }
        else
        {
            sheen_component_0 = _S423;
        }
        float _S425 = (F32_min((sheen_component_0), (1.0f)));
        float3  _S426 = make_float3 (1.0f) - material_1.sheen * make_float3 (_S425);
        float _S427 = rgb_to_greyscale(material_1.sheen);
        float _S428 = _S427 * _S425;
        float3  _S429 = material_1.sheen / make_float3 ((F32_max((sheen_component_0), (1.0f))));
        sheen_component_0 = _S428;
        sheen_1 = _S429;
        scale_1 = _S426;
    }
    else
    {
        sheen_component_0 = 0.0f;
        sheen_1 = _S407;
        scale_1 = _S406;
    }
    float _S430 = (F32_abs((material_1.toon.x)));
    bool _S431 = _S430 > 0.0f;
    if(_S431)
    {
        float _S432 = (F32_min((_S430), (1.0f)));
        float3  scale_2 = scale_1 * make_float3 (1.0f - _S432);
        float _S433 = rgb_to_greyscale(material_1.albedo);
        float _S434 = _S432 * _S433;
        toon_component_0 = _S434;
        scale_1 = scale_2;
    }
    else
    {
        toon_component_0 = 0.0f;
    }
    bool _S435 = (material_1.metallic) > 0.0f;
    float3  rebounce_0;
    if(_S435)
    {
        float _S436 = frame_2.alphas.x;
        float _S437 = (F32_sqrt(((F32_min((_S436), (frame_2.alphas.y))))));
        bool _S438 = _S436 > 0.0f;
        float _S439 = _slang_select(_S438, _S437,material_1.roughness);
        float _S440 = _S439 * _S439;
        float _S441 = (F32_pow((_S440), (1.81585001945495605f))) * (2.15371990203857422f - 0.73285001516342163f * _S440) / (1.0f + 1.28094995021820068f * _S440);
        bool _S442 = _S440 > 0.0f;
        float _S443 = _slang_select(_S442, _S441,0.0f);
        float _S444 = clamp_1(dot_0(n_i_3, v_4), 0.0f, 1.0f);
        float _S445 = _S440 * _S439;
        float _S446 = (F32_min((1.00064504146575928f - _S439 * (0.00375499995425344f + _S444 * (-0.04133399948477745f + _S444 * (-0.90938502550125122f + _S444 * 0.35275399684906006f))) - _S440 * (0.27602800726890564f + _S444 * (1.27023398876190186f + _S444 * 0.04740000143647194f)) - _S445 * (0.31452900171279907f - _S444 * 0.34830701351165771f) + _S445 * _S439 * 0.27229699492454529f), (1.0f)));
        float3  _S447 = min_1(make_float3 (1.0f) / (make_float3 (1.0f) - material_1.albedo * make_float3 (_S443)), make_float3 (1.0f / (F32_max((_S446), (0.0000152587890625f)))));
        rebounce_0 = _S447;
    }
    else
    {
        rebounce_0 = _S406;
    }
    float3  _S448 = mix_0(_S404, material_1.albedo * rebounce_0, material_1.metallic);
    float3  F_1 = _S448 * scale_1;
    float _S449 = rgb_to_greyscale(F_1);
    float _S450 = 1.0f - material_1.metallic;
    float3  _S451 = make_float3 (1.0f) - _S404;
    float3  _S452 = make_float3 ((1.0f - material_1.transmission) * _S450) * _S451 * scale_1;
    float3  _S453 = make_float3 (material_1.transmission * _S450) * _S451 * scale_1;
    float _S454 = (F32_max((_S449), (0.0f)));
    float _S455 = rgb_to_greyscale(_S452);
    float _S456 = (F32_max((_S455), (0.0f)));
    float _S457 = rgb_to_greyscale(_S453);
    float _S458 = sign_0(length_0(_S396));
    float _S459 = (F32_max((_S457 * _S458), (0.0f)));
    float _S460 = _S454 + _S456 + _S459 + toon_component_0;
    float _S461 = (F32_min((sheen_component_0), (1.0f)));
    bool _S462 = sheen_component_0 > 0.0f;
    bool _S463;
    if(_S462)
    {
        _S463 = !(_S460 > 0.0f);
    }
    else
    {
        _S463 = false;
    }
    float _S464 = _slang_select(_S463, 1.0f,_S461);
    float _S465 = (1.0f - _S464) / (F32_max((_S460), (0.0000152587890625f)));
    float _S466 = _S456 * _S465;
    float _S467 = _S454 * _S465;
    float _S468 = _S459 * _S465;
    return Weights_x24init_0(_S393, _S396, F_1, 1.0f, _S452, _S453, _S466, _S467, _S468, _S464, toon_component_0 * _S465, sheen_1);
}

__device__ float translucentShare(BSDFMaterial material_2)
{
    float _S469 = rgb_to_greyscale(material_2.translucent);
    float _S470 = rgb_to_greyscale(material_2.albedo);
    float _S471 = _S469 / (_S470 + _S469);
    bool _S472 = _S469 > 0.0f;
    float _S473 = _slang_select(_S472, _S471,0.0f);
    return _S473;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float n_i_dot_v_0, BSDFMaterial material_3, Weights w_1)
{
    float _S474 = translucentShare(material_3);
    float _S475 = w_1.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S476 = w_1.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S477 = 1.0f - _S474;
    bool _S478 = n_i_dot_l_0 < 0.0f;
    float _S479 = _slang_select(_S478, _S474,_S477);
    float _S480 = _S476 * _S479;
    bool _S481 = _S474 > 0.0f;
    float _S482 = _slang_select(_S481, _S480,_S475);
    bool _S483 = n_i_dot_v_0 > 0.0f;
    float _S484 = _slang_select(_S483, _S482,0.0f);
    return _S484;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_4, BSDFMaterial material_4, Weights w_2)
{
    float _S485 = translucentShare(material_4);
    bool _S486 = (dot_0(n_i_4, l_0)) < 0.0f;
    float3  _S487 = _slang_select(_S486, material_4.translucent,material_4.albedo);
    float _S488 = 1.0f - _S485;
    float _S489 = _slang_select(_S486, _S485,_S488);
    float3  _S490 = _S487 / make_float3 (_S489);
    bool _S491 = _S485 > 0.0f;
    float3  _S492 = _slang_select(_S491, _S490,material_4.albedo);
    return w_2.diffuse_weight * _S492 / make_float3 (w_2.p_diffuse);
}

__device__ float smithG1(float alpha_3, float n_dot_x_0)
{
    float _S493 = alpha_3 * alpha_3;
    float _S494 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S493 + (1.0f - _S493) * n_dot_x_0 * n_dot_x_0))));
    bool _S495 = alpha_3 > 0.0f;
    float _S496 = _slang_select(_S495, _S494,1.0f);
    return _S496;
}

__device__ float trowbridgeReitz(float alpha_4, float n_dot_h_0)
{
    float _S497 = alpha_4 * alpha_4;
    float _S498 = (1.0f - n_dot_h_0) * (1.0f + n_dot_h_0) + _S497 * n_dot_h_0 * n_dot_h_0;
    return _S497 / (F32_max((3.14159274101257324f * _S498 * _S498), (1.17549435082228751e-38f)));
}

__device__ float anisotropicG1(float3  w_3, float2  alphas_1)
{
    float _S499 = (F32_max((w_3.z), (0.0f)));
    return 2.0f * _S499 / (_S499 + length_0(make_float3 (alphas_1.x * w_3.x, alphas_1.y * w_3.y, _S499)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_2)
{
    float _S500 = alphas_2.x;
    float _S501 = h_0.x / _S500;
    float _S502 = alphas_2.y;
    float _S503 = h_0.y / _S502;
    float _S504 = h_0.z;
    float _S505 = _S501 * _S501 + _S503 * _S503 + _S504 * _S504;
    return 1.0f / (F32_max((3.14159274101257324f * _S500 * _S502 * _S505 * _S505), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float3  v_5, float3  h_1, float3  n_i_5, float n_i_dot_v_1, float alpha_5, AnisotropicFrame frame_3, float v_dot_h_1)
{
    float _S506 = dot_0(n_i_5, h_1);
    float _S507 = smithG1(alpha_5, n_i_dot_v_1);
    float _S508 = _S507 * v_dot_h_1;
    float _S509 = trowbridgeReitz(alpha_5, _S506);
    float _S510 = _S508 * _S509 / n_i_dot_v_1;
    bool _S511 = alpha_5 > 0.0f;
    bool _S512;
    if(_S511)
    {
        _S512 = v_dot_h_1 > 0.0f;
    }
    else
    {
        _S512 = false;
    }
    if(_S512)
    {
        _S512 = _S506 > 0.0f;
    }
    else
    {
        _S512 = false;
    }
    if(_S512)
    {
        _S512 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S512 = false;
    }
    float _S513 = _slang_select(_S512, _S510,0.0f);
    bool _S514 = (frame_3.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S514)
    {
        float3  _S515 = anisotropicLocal(v_5, frame_3.tangent, n_i_5);
        float _S516 = anisotropicG1(_S515, frame_3.alphas);
        float3  _S517 = anisotropicLocal(h_1, frame_3.tangent, n_i_5);
        float _S518 = anisotropicD(_S517, frame_3.alphas);
        float _S519 = _S516 * _S518;
        float _S520 = _S519 * v_dot_h_1 / n_i_dot_v_1;
        bool _S521 = v_dot_h_1 > 0.0f;
        if(_S521)
        {
            _S512 = _S506 > 0.0f;
        }
        else
        {
            _S512 = false;
        }
        if(_S512)
        {
            _S512 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S512 = false;
        }
        float _S522 = _slang_select(_S512, _S520,0.0f);
        pdf_h_0 = _S522;
    }
    else
    {
        pdf_h_0 = _S513;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float l_dot_h_0, float pdf_h_1, Weights w_4, float eta_i_3, float eta_o_3)
{
    float _S523 = eta_i_3 * w_4.v_dot_h + eta_o_3 * l_dot_h_0;
    float _S524 = w_4.p_refract * pdf_h_1 * eta_o_3 * eta_o_3 * (F32_abs((l_dot_h_0))) / (_S523 * _S523);
    bool _S525 = eta_i_3 != eta_o_3;
    bool _S526;
    if(_S525)
    {
        _S526 = l_dot_h_0 < 0.0f;
    }
    else
    {
        _S526 = false;
    }
    float _S527 = _slang_select(_S526, _S524,0.0f);
    return _S527;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_6, float alpha_6, AnisotropicFrame frame_4, BSDFMaterial material_5, Weights w_5)
{
    float _S528 = - dot_0(n_i_6, l_1);
    float _S529 = smithG1(alpha_6, (F32_max((_S528), (0.0f))));
    bool _S530 = (frame_4.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S530)
    {
        float3  _S531 = negate_0(n_i_6);
        float3  _S532 = anisotropicLocal(l_1, frame_4.tangent, _S531);
        float _S533 = anisotropicG1(_S532, frame_4.alphas);
        G1_l_0 = _S533;
    }
    else
    {
        G1_l_0 = _S529;
    }
    return w_5.refract_weight * make_float3 (G1_l_0) * material_5.albedo / make_float3 (w_5.p_refract);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_1, float n_i_dot_v_2, Weights w_6)
{
    float _S534 = w_6.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S535 = n_i_dot_l_1 > 0.0f;
    bool _S536;
    if(_S535)
    {
        _S536 = n_i_dot_v_2 > 0.0f;
    }
    else
    {
        _S536 = false;
    }
    float _S537 = _slang_select(_S536, _S534,0.0f);
    return _S537;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  v_6, float3  n_i_7, BSDFMaterial material_6, Weights w_7)
{
    float3  _S538 = l_2 + v_6;
    float3  _S539 = ((((_S538)) * make_float3(rnorm3df(((_S538)).x, ((_S538)).y, ((_S538)).z))));
    float _S540 = dot_0(n_i_7, _S539);
    float _S541 = (F32_max((dot_0(n_i_7, l_2)), (0.0f)));
    float _S542 = (F32_max((dot_0(n_i_7, v_6)), (0.0f)));
    float _S543 = 1.0f / (F32_max((material_6.sheen_roughness), (0.05000000074505806f)));
    float _S544 = 1.0f - _S540 * _S540;
    float _S545 = (2.0f + _S543) * (F32_pow(((F32_max((_S544), (0.0f)))), (0.5f * _S543))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S541 + _S542 - _S541 * _S542)), (0.0000152587890625f)));
    bool _S546 = (material_6.velvet) > 0.0f;
    float f_1;
    if(_S546)
    {
        float _S547 = (F32_max((material_6.sheen_roughness), (0.00999999977648258f)));
        float _S548 = _S547 * _S547;
        float _S549 = (F32_max((_S544), (0.0000152587890625f)));
        float _S550 = (F32_exp((- _S540 * _S540 / (_S549 * _S548)))) / (3.14159274101257324f * _S548 * _S549 * _S549) * (F32_min((1.0f), (2.0f * _S540 * (F32_min((_S541), (_S542))) / (F32_max(((F32_abs((dot_0(_S539, v_6))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S541 * _S542), (0.0000152587890625f)));
        f_1 = _S550;
    }
    else
    {
        f_1 = _S545;
    }
    return w_7.sheen * make_float3 (f_1 * _S541 * 2.0f * 3.14159274101257324f / w_7.p_sheen_velvet);
}

struct ToonShape
{
    float3  toon;
    float a;
    float s;
    float b;
    bool glossy;
    float norm;
    float view;
    float3  axis;
};

static __device__ ToonShape ToonShape_x24init_0(float3  toon_0, float a_7, float s_0, float b_3, bool glossy_0, float norm_0, float view_0, float3  axis_0)
{
    ToonShape _S551;
    (&_S551)->toon = toon_0;
    (&_S551)->a = a_7;
    (&_S551)->s = s_0;
    (&_S551)->b = b_3;
    (&_S551)->glossy = glossy_0;
    (&_S551)->norm = norm_0;
    (&_S551)->view = view_0;
    (&_S551)->axis = axis_0;
    return _S551;
}

__device__ __forceinline__ ToonShape toonShape(float3  v_7, float3  n_i_8, BSDFMaterial material_7)
{
    float _S552 = material_7.toon.x;
    bool _S553 = _S552 < 0.0f;
    float3  _S554 = make_float3 ((F32_min(((F32_abs((_S552)))), (1.0f)))) * material_7.albedo;
    float _S555 = clamp_1(material_7.toon.y / _S552, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S556 = clamp_1(material_7.toon.z / _S552, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S557 = (F32_min((_S555 + _S556), (1.57079637050628662f)));
    float integral_0;
    if(_S553)
    {
        integral_0 = 1.0f - (F32_cos(((F32_min((_S557), (_S555))))));
    }
    else
    {
        float _S558 = (F32_sin(((F32_min((_S557), (_S555))))));
        integral_0 = _S558 * _S558 / 2.0f;
    }
    bool _S559 = _S557 > _S555;
    bool _S560;
    if(_S559)
    {
        _S560 = _S556 > 0.0f;
    }
    else
    {
        _S560 = false;
    }
    float _S561;
    if(_S560)
    {
        if(_S553)
        {
            float _S562 = (F32_cos((_S555)));
            float _S563 = (F32_cos((_S557)));
            _S561 = (1.0f + _S555 / _S556) * (_S562 - _S563) - ((F32_sin((_S557))) - _S557 * _S563 - ((F32_sin((_S555))) - _S555 * _S562)) / _S556;
        }
        else
        {
            float _S564 = 2.0f * _S555;
            float _S565 = (F32_cos((_S564)));
            float _S566 = 2.0f * _S557;
            float _S567 = (F32_cos((_S566)));
            _S561 = (1.0f + _S555 / _S556) * (_S565 - _S567) / 4.0f - ((F32_sin((_S566))) / 8.0f - _S557 * _S567 / 4.0f - ((F32_sin((_S564))) / 8.0f - _S555 * _S565 / 4.0f)) / _S556;
        }
        float integral_1 = integral_0 + _S561;
        integral_0 = integral_1;
    }
    float _S568 = dot_0(n_i_8, v_7);
    float _S569 = (F32_acos(((F32_min((_S568), (1.0f))))));
    if(_S569 < _S555)
    {
        _S561 = 1.0f;
    }
    else
    {
        _S561 = (F32_max((1.0f - (_S569 - _S555) / (F32_max((_S556), (0.0000152587890625f)))), (0.0f)));
    }
    float3  _S570;
    if(_S553)
    {
        float3  _S571 = make_float3 (2.0f * _S568) * n_i_8 - v_7;
        float3  _S572 = ((((_S571)) * make_float3(rnorm3df(((_S571)).x, ((_S571)).y, ((_S571)).z))));
        _S570 = _S572;
    }
    else
    {
        _S570 = n_i_8;
    }
    return ToonShape_x24init_0(_S554, _S555, _S556, _S557, _S553, 6.28318548202514648f * integral_0, _S561, _S570);
}

__device__ __forceinline__ float toonPDF(float n_i_dot_l_2, float l_dot_h_1, ToonShape shape_0, Weights w_8)
{
    float _S573 = _slang_select(shape_0.glossy, l_dot_h_1,n_i_dot_l_2);
    float _S574 = (F32_acos((clamp_1(_S573, -1.0f, 1.0f))));
    float _S575;
    if(_S574 < (shape_0.a))
    {
        _S575 = 1.0f;
    }
    else
    {
        _S575 = (F32_max((1.0f - (_S574 - shape_0.a) / (F32_max((shape_0.s), (0.0000152587890625f)))), (0.0f)));
    }
    float _S576 = w_8.p_toon * _S575;
    float _S577 = _slang_select(shape_0.glossy, 1.0f,n_i_dot_l_2);
    float _S578 = _S576 * _S577 / shape_0.norm;
    bool _S579;
    if(shape_0.glossy)
    {
        _S579 = true;
    }
    else
    {
        _S579 = n_i_dot_l_2 > 0.0f;
    }
    float _S580 = _slang_select(_S579, _S578,0.0f);
    return _S580;
}

__device__ __forceinline__ float3  toonBSDF(float3  l_3, float3  n_i_9, ToonShape shape_1, Weights w_9)
{
    float _S581 = (F32_max((dot_0(n_i_9, l_3)), (0.0f)));
    float _S582 = _slang_select(shape_1.glossy, _S581,shape_1.view);
    return shape_1.toon * make_float3 (_S582) / make_float3 (w_9.p_toon);
}

__device__ __forceinline__ float reflectPDF(float pdf_h_2, Weights w_10)
{
    float _S583 = w_10.p_reflect * pdf_h_2 / (4.0f * w_10.v_dot_h);
    bool _S584 = pdf_h_2 > 0.0f;
    float _S585 = _slang_select(_S584, _S583,0.0f);
    return _S585;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_4, float3  n_i_10, float alpha_7, AnisotropicFrame frame_5, Weights w_11)
{
    float _S586 = dot_0(n_i_10, l_4);
    float _S587 = smithG1(alpha_7, (F32_max((_S586), (0.0f))));
    bool _S588 = (frame_5.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S588)
    {
        float3  _S589 = anisotropicLocal(l_4, frame_5.tangent, n_i_10);
        float _S590 = anisotropicG1(_S589, frame_5.alphas);
        G1_l_1 = _S590;
    }
    else
    {
        G1_l_1 = _S587;
    }
    return make_float3 (w_11.reflect_weight * G1_l_1) * w_11.F / make_float3 (w_11.p_reflect);
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_3, float3  out_dir_2, float3  n_6, BSDFMaterial material_8, float eta_i_4, float eta_o_4, bool refracted_2, uint random_state_4, FixedArray<float3 , 5>  * throughputs_0, FixedArray<float, 5>  * pdfs_0)
{
    float3  ggx_n_1;
    float3  _S591 = negate_0(in_dir_3);
    float _S592 = dot_0(n_6, _S591);
    float _S593 = sign_0(_S592);
    float3  _S594 = n_6 * make_float3 (_S593);
    float _S595 = dot_0(_S594, out_dir_2);
    float _S596 = material_8.roughness;
    float _S597 = _S596 * _S596;
    AnisotropicFrame _S598 = anisotropicFrame(material_8, _S594);
    float _S599 = rgb_to_greyscale(material_8.translucent);
    bool _S600 = _S599 > 0.0f;
    bool _S601 = (dot_0(n_6, out_dir_2) * _S592) < 0.0f;
    uint _S602;
    if((F32_abs((material_8.toon.x))) > 0.0f)
    {
        _S602 = 5U;
    }
    else
    {
        _S602 = 4U;
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
        float3  _S603 = make_float3 (0.0f);
        (*throughputs_0)[i_7] = _S603;
        (*pdfs_0)[i_7] = 0.0f;
        uint i_8 = i_7 + 1U;
        i_7 = i_8;
    }
    float3  _S604 = make_float3 (0.0f);
    Weights _S605 = Weights_x24init_0(0.0f, _S604, _S604, 0.0f, _S604, _S604, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, _S604);
    uint half_of_0 = 4294967295U;
    Weights w_12 = _S605;
    float3  ggx_n_2 = _S604;
    i_7 = 0U;
    for(;;)
    {
        if(i_7 < _S602)
        {
        }
        else
        {
            break;
        }
        uint _S606;
        if(i_7 == 3U)
        {
            _S606 = 4U;
        }
        else
        {
            if(i_7 == 4U)
            {
                _S606 = 6U;
            }
            else
            {
                _S606 = i_7;
            }
        }
        bool _S607 = _S606 == 0U;
        bool _S608;
        if(_S607)
        {
            _S608 = _S600;
        }
        else
        {
            _S608 = false;
        }
        bool _S609;
        if(_S608)
        {
            _S609 = _S601;
        }
        else
        {
            _S609 = _S606 == 1U;
        }
        bool _S610 = _S609 != refracted_2;
        if(_S610)
        {
            ggx_n_1 = ggx_n_2;
            uint i_9 = i_7 + 1U;
            ggx_n_2 = ggx_n_1;
            i_7 = i_9;
            continue;
        }
        uint _S611;
        if(_S606 == 6U)
        {
            _S611 = 0U;
        }
        else
        {
            if(_S606 == 4U)
            {
                _S611 = 2U;
            }
            else
            {
                _S611 = _S606;
            }
        }
        bool _S612 = _S611 != half_of_0;
        uint half_of_1;
        Weights w_13;
        if(_S612)
        {
            bool _S613 = _S611 == 0U;
            if(_S613)
            {
                float3  _S614 = sampledHalf(_S591, _S594, _S597, _S598, random_state_4);
                ggx_n_1 = _S614;
            }
            else
            {
                bool _S615 = _S611 == 1U;
                if(_S615)
                {
                    float3  _S616 = refractedHalf(in_dir_3, out_dir_2, n_6, eta_i_4, eta_o_4);
                    ggx_n_1 = _S616;
                }
                else
                {
                    float3  _S617 = reflectedHalf(in_dir_3, out_dir_2);
                    ggx_n_1 = _S617;
                }
            }
            Weights _S618 = lobeWeights(in_dir_3, _S591, _S594, ggx_n_1, _S598, material_8, eta_i_4, eta_o_4);
            w_13 = _S618;
            half_of_1 = _S611;
        }
        else
        {
            w_13 = w_12;
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S606)
        {
        case 0U:
            {
                float _S619 = diffusePDF(_S595, (F32_abs((_S592))), material_8, w_13);
                (*pdfs_0)[int(0)] = _S619;
                float3  _S620 = diffuseBSDF(out_dir_2, _S594, material_8, w_13);
                (*throughputs_0)[int(0)] = _S620;
                break;
            }
        case 1U:
            {
                float _S621 = dot_0(out_dir_2, ggx_n_1);
                float _S622 = vndfPDF(_S591, ggx_n_1, _S594, (F32_abs((_S592))), _S597, _S598, w_13.v_dot_h);
                float _S623 = refractPDF(_S621, _S622, w_13, eta_i_4, eta_o_4);
                (*pdfs_0)[int(1)] = _S623;
                float3  _S624 = refractBSDF(out_dir_2, _S594, _S597, _S598, material_8, w_13);
                (*throughputs_0)[int(1)] = _S624;
                break;
            }
        case 4U:
            {
                float _S625 = sheenVelvetPDF(_S595, (F32_abs((_S592))), w_13);
                (*pdfs_0)[int(3)] = _S625;
                float3  _S626 = sheenVelvetBSDF(out_dir_2, _S591, _S594, material_8, w_13);
                (*throughputs_0)[int(3)] = _S626;
                break;
            }
        case 6U:
            {
                ToonShape _S627 = toonShape(_S591, _S594, material_8);
                float _S628 = toonPDF(_S595, dot_0(out_dir_2, _S627.axis), _S627, w_13);
                (*pdfs_0)[int(4)] = _S628;
                float3  _S629 = toonBSDF(out_dir_2, _S594, _S627, w_13);
                (*throughputs_0)[int(4)] = _S629;
                break;
            }
        default:
            {
                float _S630 = vndfPDF(_S591, ggx_n_1, _S594, (F32_abs((_S592))), _S597, _S598, w_13.v_dot_h);
                float _S631 = reflectPDF(_S630, w_13);
                (*pdfs_0)[int(2)] = _S631;
                float3  _S632 = reflectBSDF(out_dir_2, _S594, _S597, _S598, w_13);
                (*throughputs_0)[int(2)] = _S632;
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
    ggx_n_1 = _S604;
    for(;;)
    {
        if(i_7 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S633 = ((*pdfs_0)[i_7]) > 0.0f;
        if(_S633)
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
    bool _S634 = wrongSide_0(is_inside_2, false, dir_3, surface_1->geometry_n);
    float3  _S635 = BSDF(in_dir_4, dir_3, surface_1->smooth_n, surface_1->material, eta_1.x, eta_1.y, _S634, random_state_5, terms_0, pdfs_1);
    float3  _S636 = make_float3 (0.0f);
    uint i_11 = 0U;
    float3  f_3 = _S636;
    for(;;)
    {
        if(i_11 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S637 = ((*pdfs_1)[i_11]) > 0.0f;
        if(_S637)
        {
            float3  _S638 = (*terms_0)[i_11] * make_float3 ((*pdfs_1)[i_11]) / make_float3 ((*pdfs_1)[i_11] + pdf_0);
            (*terms_0)[i_11] = _S638;
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
    FKSurface _S639 = surface_2;
    FixedArray<float3 , 5>  terms_1;
    FixedArray<float, 5>  pdfs_2;
    float3  _S640 = skyLobes_0(in_dir_5, dir_4, &_S639, eta_2, is_inside_3, pdf_1, random_state_6, &terms_1, &pdfs_2);
    return _S640;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_5, float3  radiance_0, float3  color_0, uint random_state_7)
{
    SkySample _S641;
    (&_S641)->dir = dir_5;
    (&_S641)->radiance = radiance_0;
    (&_S641)->color = color_0;
    (&_S641)->random_state = random_state_7;
    return _S641;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_3, float2  eta_3, bool is_inside_4, uint init_random_state_0, uint lobe_state_0, ShadowContext * context_2)
{
    uint2  _S642 = (fcptEnvironmentCdfSize());
    uint2  _S643 = make_uint2 (1U, 0U);
    uint2  _S644 = _S642 - _S643;
    Random _S645 = pcg(init_random_state_0);
    Random _S646 = pcg(_S645.state);
    Random _S647 = pcg(_S646.state);
    Random _S648 = pcg(_S647.state);
    uint _S649 = _S644.x;
    uint _S650 = searchCDF_0(make_uint2 (_S649, 0U), make_uint2 (0U, 1U), _S644.y, _S645.value);
    uint _S651 = searchCDF_0(make_uint2 (0U, _S650), _S643, _S649, _S646.value);
    float2  _S652 = make_float2 ((float)_S644.x, (float)_S644.y);
    float2  _S653 = (make_float2 (float(_S651), float(_S650)) + make_float2 (_S647.value, _S648.value)) / _S652 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S654 = _S653.y;
    float _S655 = (F32_sin((_S654)));
    float _S656 = _S653.x;
    float3  _S657 = make_float3 (- _S655 * (F32_cos((_S656))), _S655 * (F32_sin((_S656))), (F32_cos((_S654))));
    float _S658 = environmentPdf_0(_S657);
    float3  _S659 = skyBSDF(ray_0->unit_direction, _S657, *surface_3, eta_3, is_inside_4, _S658, lobe_state_0);
    bool _S660 = !(_S658 > 0.0f);
    bool _S661;
    if(_S660)
    {
        _S661 = true;
    }
    else
    {
        _S661 = all_1(_S659 == make_float3 (0.0f));
    }
    if(_S661)
    {
        float3  _S662 = make_float3 (0.0f);
        return SkySample_x24init_0(_S657, _S662, _S662, _S648.state);
    }
    float3  _S663 = skyRadiance_0(ray_0->origin, surface_3, is_inside_4, _S657, context_2, _S648.state);
    return SkySample_x24init_0(_S657, _S663, _S659 * _S663, _S648.state);
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
    SampleBSDF _S664 = (fcptConnectHair((surface_4->hair), ((&surface_4->material)->albedo), ((&surface_4->material)->specular_tint), (in_dir_6), (light_1->dir)));
    float3  _S665 = _S664.throughput * make_float3 (_S664.pdf);
    float _S666 = light_1->density;
    float _S667 = 1.0f + _S664.pdf * _S664.pdf / (light_1->density * light_1->density);
    bool _S668;
    if(competing_0)
    {
        _S668 = _S666 > 0.0f;
    }
    else
    {
        _S668 = false;
    }
    float _S669 = _slang_select(_S668, _S667,1.0f);
    return _S665 / make_float3 (_S669) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_6, float3  radiance_1, float density_0, uint random_state_8)
{
    TreeSample _S670;
    (&_S670)->dir = dir_6;
    (&_S670)->radiance = radiance_1;
    (&_S670)->density = density_0;
    (&_S670)->random_state = random_state_8;
    return _S670;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_12, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S671 = importance(first_1, p_12, normal_3);
    float _S672 = importance(second_1, p_12, normal_3);
    float2  _S673 = make_float2 (_S671, _S672);
    bool _S674 = _S671 == 0.0f;
    bool _S675;
    if(_S674)
    {
        _S675 = _S672 == 0.0f;
    }
    else
    {
        _S675 = false;
    }
    if(_S675)
    {
        return 2U;
    }
    float _S676 = _S671 + _S672;
    bool _S677 = _S672 > 0.0f;
    if(_S677)
    {
        _S675 = (*pick_0 * _S676) >= _S671;
    }
    else
    {
        _S675 = false;
    }
    uint _S678 = uint(_S675);
    float _S679 = (F32_min(((*pick_0 * _S676 - float(_S678) * _S671) / _slang_vector_get_element(_S673, _S678)), (0.99999994039535522f)));
    *pick_0 = _S679;
    float _S680 = *probability_3 * (_slang_vector_get_element(_S673, _S678) / _S676);
    *probability_3 = _S680;
    return _S678;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_13, float u1_0, float u2_0)
{
    float3  _S681 = center_1 - p_13;
    float _S682 = radius_1 * radius_1 / dot_0(_S681, _S681);
    float _S683 = u1_0 * _S682 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S682), (0.0f)))))));
    float _S684 = 2.0f * u1_0;
    bool _S685 = _S682 >= 1.0f;
    float _S686 = _slang_select(_S685, _S684,_S683);
    float _S687 = (F32_sqrt(((F32_max((_S686 * (2.0f - _S686)), (0.0f))))));
    float _S688 = 6.28318548202514648f * u2_0;
    float3  _S689 = make_float3 (_S687 * (F32_cos((_S688))), 1.0f - _S686, _S687 * (F32_sin((_S688))));
    float3  _S690 = ((((_S681)) * make_float3(rnorm3df(((_S681)).x, ((_S681)).y, ((_S681)).z))));
    float3  _S691 = tangentToWorld(_S689, _S690);
    return _S691;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S692 = center_2 - ray_1->origin;
    float _S693 = dot_0(_S692, ray_1->unit_direction);
    float _S694 = dot_0(_S692, _S692) - _S693 * _S693;
    float _S695 = radius_3 * radius_3;
    bool _S696 = _S694 > _S695;
    if(_S696)
    {
        return 4.294967296e+09f;
    }
    float _S697 = (F32_sqrt((_S695 - _S694)));
    float _S698 = _S693 - _S697;
    float _S699 = _S693 + _S697;
    bool _S700 = _S698 > 0.0000152587890625f;
    bool _S701;
    if(_S700)
    {
        _S701 = _S698 < max_len_0;
    }
    else
    {
        _S701 = false;
    }
    if(_S701)
    {
        return _S698;
    }
    bool _S702 = _S699 > 0.0000152587890625f;
    if(_S702)
    {
        _S701 = _S699 < max_len_0;
    }
    else
    {
        _S701 = false;
    }
    if(_S701)
    {
        return _S699;
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
    Random _S703 = pcg(init_random_state_1);
    Random _S704 = pcg(_S703.state);
    Random _S705 = pcg(_S704.state);
    float3  _S706 = make_float3 (0.0f);
    TreeSample _S707 = TreeSample_x24init_0(_S706, _S706, 0.0f, _S705.state);
    TreeSample sample_0 = _S707;
    float3  _S708 = _slang_select(sided_0, _S706,smooth_n_2);
    float3  _S709 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S703.value;
    float probability_4 = 1.0f;
    uint n_7 = 0U;
    for(;;)
    {
        uint4  _S710 = (fcptLightNode((n_7)));
        if((_S710.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S711 = (fcptLightSecond((n_7)));
        uint _S712 = n_7 + 1U;
        LightNode _S713 = (fcptLightBounds((_S712)));
        LightNode _S714 = (fcptLightBounds((_S711)));
        uint _S715 = pickChild(_S713, _S714, origin_4, _S708, &pick_1, &probability_4);
        bool _S716 = _S715 > 1U;
        if(_S716)
        {
            return sample_0;
        }
        bool _S717 = _S715 == 1U;
        uint _S718 = _slang_select(_S717, _S711,_S712);
        n_7 = _S718;
    }
    bool _S719 = n_7 == 0U;
    bool _S720;
    if(_S719)
    {
        LightNode _S721 = (fcptLightBounds((0U)));
        float _S722 = importance(_S721, origin_4, _S708);
        _S720 = !(_S722 > 0.0f);
    }
    else
    {
        _S720 = false;
    }
    if(_S720)
    {
        return sample_0;
    }
    uint4  _S723 = (fcptLightNode((n_7)));
    FKHit _S724 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S725 = (_S723.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S725)
    {
        FKLight _S726 = (fcptLight((_S723.y)));
        if(sided_0)
        {
            float _S727 = sign_0(dot_0(geometry_n_1, _S726.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S727);
            float3  _S728 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S728;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S709;
            lift_n_0 = smooth_n_2;
        }
        bool _S729 = (_S726.variance) == 0.0f;
        if(_S729)
        {
            float3  _S730 = _S726.position - emitter_point_0;
            float3  _S731 = ((((_S730)) * make_float3(rnorm3df(((_S730)).x, ((_S730)).y, ((_S730)).z))));
            (&sample_0)->dir = _S731;
            float3  _S732 = _S726.color * make_float3 (_S726.intensity) / make_float3 (dot_0(_S730, _S730) * probability_4);
            (&sample_0)->radiance = _S732;
            shadow_1 = _S730;
        }
        else
        {
            float3  _S733 = sampleSphere(_S726.position, _S726.variance, emitter_point_0, _S704.value, _S705.value);
            (&sample_0)->dir = _S733;
            float _S734 = sphereDensity(_S726.position, _S726.variance, emitter_point_0);
            float _S735 = probability_4 * _S734;
            (&sample_0)->density = _S735;
            float3  _S736 = pointLightRadiance(_S726.color, _S726.intensity, _S726.variance);
            float3  _S737 = _S736 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S737;
            FKRay _S738 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S739 = raySphere_0(_S726.position, _S726.variance, &_S738, 4.294967296e+09f);
            float3  _S740 = (&sample_0)->dir * make_float3 (_S739);
            shadow_1 = _S740;
        }
        emitter_0 = _S724;
        emitter_point_0 = _S706;
    }
    else
    {
        uint _S741 = _S723.y;
        uint _S742 = (fcptTriangleOffset((_S741)));
        uint _S743 = _S742 + _S723.z;
        Matrix<float, 3, 3>  _S744 = (fcptWorldTriangle((_S741), (_S743)));
        float _S745 = (F32_sqrt((_S704.value)));
        float2  _S746 = make_float2 (_S745 * (1.0f - _S705.value), _S745 * _S705.value);
        float3  _S747 = mul_0(make_float3 (1.0f - _S745, _S746.x, _S746.y), _S744);
        if(sided_0)
        {
            float _S748 = sign_0(dot_0(geometry_n_1, _S747 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S748);
            float3  _S749 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S749;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S750 = !((dot_0(smooth_n_2, _S747 - origin_4)) > 0.0f);
            if(_S750)
            {
                return sample_0;
            }
            emitter_point_0 = _S709;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S746, _S741, _S743, 0U, 0.0f);
        float3  _S751 = _S747 - emitter_point_0;
        float3  _S752 = ((((_S751)) * make_float3(rnorm3df(((_S751)).x, ((_S751)).y, ((_S751)).z))));
        (&sample_0)->dir = _S752;
        float _S753 = solidAngle(probability_4, cross_0(_S744.rows[int(1)] - _S744.rows[int(0)], _S744.rows[int(2)] - _S744.rows[int(0)]), _S751);
        (&sample_0)->density = _S753;
        bool _S754 = (fcptShadowFirst());
        bool _S755 = !_S754;
        if(_S755)
        {
            FKSurface _S756 = (fcptLightSurfaceAt((emitter_1), (_S747), (_S705.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S747 - origin_4))));
            (&sample_0)->random_state = _S756.random_state;
            float3  _S757 = _slang_select(_S756.skip, _S706,_S756.material.emissive);
            float3  _S758 = _S757 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S758;
        }
        shadow_1 = _S751;
        emitter_0 = emitter_1;
        emitter_point_0 = _S747;
    }
    FKHit _S759 = emitter_0;
    float3  _S760 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S705.state, &_S759);
    bool _S761 = (fcptShadowFirst());
    if(_S761)
    {
        _S720 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S720 = false;
    }
    if(_S720)
    {
        _S720 = !all_1(_S760 == _S706);
    }
    else
    {
        _S720 = false;
    }
    if(_S720)
    {
        FKSurface _S762 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S705.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S762.random_state;
        float3  _S763 = _slang_select(_S762.skip, _S706,_S762.material.emissive);
        float3  _S764 = _S763 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S764;
    }
    float3  _S765 = (&sample_0)->radiance * _S760;
    bool _S766 = all_1(_S760 == _S706);
    float3  _S767 = _slang_select(_S766, _S706,_S765);
    (&sample_0)->radiance = _S767;
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

__device__ float powerHeuristic(float a_8, float b_4)
{
    float _S768 = 1.0f / (1.0f + b_4 / a_8 * (b_4 / a_8));
    bool _S769 = b_4 > 0.0f;
    float _S770 = _slang_select(_S769, _S768,1.0f);
    return _S770;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S771 = vertex_0->none;
    if(_S771)
    {
        return 1.0f;
    }
    uint _S772 = (fcptLightSlot((*hit_1)));
    float _S773 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S772, light_point_1);
    float _S774 = powerHeuristic(vertex_0->pdf, _S773);
    return _S774;
}

static __device__ float3  environment_0(float3  dir_7, uint depth_0, uint lobe_0)
{
    uint2  _S775 = (fcptEnvironmentMapSize());
    bool _S776 = (_S775.x) > 1U;
    bool _S777;
    if(_S776)
    {
        uint2  _S778 = (fcptEnvironmentMapSize());
        _S777 = (_S778.y) > 1U;
    }
    else
    {
        _S777 = false;
    }
    if(_S777)
    {
        float3  _S779 = (fcptEnvMapSample((dir_7), (depth_0), (lobe_0)));
        return _S779;
    }
    float3  _S780 = (fcptAmbient());
    return _S780;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S781 = (fcptEnvironmentCdfSize());
    bool _S782 = (_S781.x) > 1U;
    bool _S783;
    if(_S782)
    {
        uint2  _S784 = (fcptEnvironmentCdfSize());
        _S783 = (_S784.y) > 1U;
    }
    else
    {
        _S783 = false;
    }
    bool _S785 = !_S783;
    if(_S785)
    {
        return false;
    }
    uint2  _S786 = (fcptEnvironmentMapSize());
    bool _S787 = (_S786.x) > 1U;
    if(_S787)
    {
        uint2  _S788 = (fcptEnvironmentMapSize());
        _S783 = (_S788.y) > 1U;
    }
    else
    {
        _S783 = false;
    }
    return _S783;
}

static __device__ float escapeWeight_0(float pdf_2, float3  dir_8)
{
    bool _S789 = pdf_2 <= 0.0f;
    bool _S790;
    if(_S789)
    {
        _S790 = true;
    }
    else
    {
        bool _S791 = environmentMapped_0();
        _S790 = !_S791;
    }
    if(_S790)
    {
        return 1.0f;
    }
    float _S792 = environmentPdf_0(dir_8);
    return pdf_2 / (pdf_2 + _S792);
}

static __device__ void restir_duplicates_0(uint3  global_invocation_id_1, uint3  local_invocation_id_0, uint local_invocation_index_3)
{
    uint2  _S793 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S794 = make_int2 ((int)_S793.x, (int)_S793.y);
    uint _S795 = previousSeed_0(_S794);
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
            uint _S796 = previousSeed_0(_S794 + make_int2 (x_16, y_5));
            bool _S797 = _S796 == _S795;
            uint _S798 = _slang_select(_S797, 1U,0U);
            uint count_3 = count_2 + _S798;
            int x_17 = x_16 + int(1);
            x_16 = x_17;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S799 = float(count_2 - 1U) / 288.0f;
    bool _S800 = _S795 != 0U;
    float _S801 = _slang_select(_S800, _S799,0.0f);
    fcptStoreDuplication((_S794), (make_uint4 ((F32_asuint((_S801))), 0U, 0U, 0U)));
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
    float _S802 = rgb_to_greyscale(abs_0(f_5));
    return _S802;
}

__device__ uint stream(uint seed_3, uint index_0)
{
    uint _S803 = hash(index_0);
    uint _S804 = hash(seed_3 ^ _S803);
    return _S804;
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
    float _S805 = resamplingTarget(weight_0);
    bool _S806 = _S805 > 0.0f;
    bool _S807;
    if(_S806)
    {
        _S807 = _S805 < 3.00000000549775576e+38f;
    }
    else
    {
        _S807 = false;
    }
    bool _S808 = !_S807;
    if(_S808)
    {
        return;
    }
    bool _S809 = sel_2->sums;
    if(_S809)
    {
        float3  _S810 = sel_2->color + weight_0;
        sel_2->color = _S810;
        return;
    }
    float _S811 = sel_2->w_sum + _S805;
    sel_2->w_sum = _S811;
    float3  _S812 = sel_2->color + weight_0;
    sel_2->color = _S812;
    Random _S813 = pcg(sel_2->random_state);
    sel_2->random_state = _S813.state;
    bool _S814 = (_S813.value * sel_2->w_sum) <= _S805;
    if(_S814)
    {
        sel_2->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_3;
    float3  _S815 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S815;
    float _S816 = r_3.jac * shifted_0.jac;
    (&candidate_1)->jac = _S816;
    offer(sel_3, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S817 = resamplingTarget((&r_4)->f);
    float _S818 = sel_4.w_sum / _S817;
    bool _S819 = _S817 > 0.0f;
    float _S820 = _slang_select(_S819, _S818,0.0f);
    (&r_4)->w = _S820;
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
    uint2  _S821 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S822 = make_int2 ((int)_S821.x, (int)_S821.y);
    float3  _S823 = make_float3 (0.0f);
    FKHit _S824 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S825 = Domain_x24init_0(_S823, _S823, &_S824, 0.0f, 0.0f);
    Domain dom_4 = _S825;
    bool _S826 = (fcptCurrentDomain((_S822), (&dom_4)));
    bool _S827 = !_S826;
    if(_S827)
    {
        Reservoir _S828 = (Reservoir{});
        fcptStoreReservoirPrevious((_S822), (_S828), ((&dom_4)->hit));
        return;
    }
    Reservoir _S829 = (fcptLoadReservoirTemporal((_S822)));
    uint t_13 = 0U;
    float count_4 = 0.0f;
    float c_sum_1 = _S829.c;
    for(;;)
    {
        uint _S830 = (fcptRestirNeighbours());
        if(t_13 < _S830)
        {
        }
        else
        {
            break;
        }
        int2  _S831 = partner_0(_S822, t_13);
        Domain neighbor_0 = _S825;
        bool _S832 = (fcptCurrentDomain((_S831), (&neighbor_0)));
        if(_S832)
        {
            float count_5 = count_4 + 1.0f;
            uint4  _S833 = (fcptReservoirTemporal((_S831), (0U)));
            float c_sum_2 = c_sum_1 + (U32_asfloat((_S833.w)));
            count_4 = count_5;
            c_sum_1 = c_sum_2;
        }
        uint t_14 = t_13 + 1U;
        t_13 = t_14;
    }
    float _S834 = _S829.c / (F32_max((count_4), (1.0f)));
    float _S835 = resamplingTarget(_S829.f);
    bool _S836 = count_4 == 0.0f;
    float _S837 = _slang_select(_S836, 1.0f,0.0f);
    Selection _S838 = (Selection{});
    Selection sel_5 = _S838;
    uint _S839 = (fcptFrame());
    uint _S840 = hash(_S839);
    uint _S841 = global_invocation_id_2.x;
    uint2  _S842 = (fcptRenderSize());
    uint _S843 = stream(_S840, _S841 + _S842.x * global_invocation_id_2.y);
    uint _S844 = stream(_S843, 195U);
    (&sel_5)->random_state = _S844;
    t_13 = 0U;
    float canonical_mis_0 = _S837;
    for(;;)
    {
        uint _S845 = (fcptRestirNeighbours());
        if(t_13 < _S845)
        {
        }
        else
        {
            break;
        }
        int2  _S846 = partner_0(_S822, t_13);
        Domain neighbor_dom_0 = _S825;
        bool _S847 = (fcptCurrentDomain((_S846), (&neighbor_dom_0)));
        if(_S847)
        {
            Reservoir _S848 = (fcptLoadReservoirTemporal((_S846)));
            uint4  _S849 = (fcptShiftData((_S846), (t_13)));
            float4  _S850 = asfloat_0(_S849);
            uint4  _S851 = (fcptShiftData((_S822), (t_13)));
            float4  _S852 = asfloat_0(_S851);
            float _S853 = pairShare(_S848.c, _S834, c_sum_1);
            bool _S854 = _S835 > 0.0f;
            float canonical_mis_1;
            if(_S854)
            {
                float _S855 = resamplingTarget(float3 {_S852.x, _S852.y, _S852.z});
                float _S856 = canonicalWeight(_S853, _S834, _S835, _S848.c, _S855);
                float canonical_mis_2 = canonical_mis_0 + _S856;
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float3  _S857 = float3 {_S850.x, _S850.y, _S850.z};
            Shift _S858 = Shift_x24init_0(_S857, _S850.w);
            float _S859 = resamplingTarget(_S848.f);
            float _S860 = resamplingTarget(_S857);
            float _S861 = neighborWeight(_S853, _S848.c, _S859, _S834, _S860);
            offerShifted(&sel_5, _S848, _S858, _S861);
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_15 = t_13 + 1U;
        t_13 = t_15;
    }
    offerShifted(&sel_5, _S829, Shift_x24init_0(_S829.f, 1.0f), canonical_mis_0);
    Reservoir _S862 = finalize(sel_5, c_sum_1);
    fcptStoreReservoirPrevious((_S822), (_S862), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S822), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S822), (make_float4 ((&sel_5)->color.x, (&sel_5)->color.y, (&sel_5)->color.z, 0.0f)));
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
    uint _S863 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S864 = _S863 != 4294967295U;
    if(_S864)
    {
        uint2  _S865 = make_uint2 (_S863, _S863 >> 14U) & make_uint2 (16383U);
        int2  _S866 = make_int2 ((int)_S865.x, (int)_S865.y);
        ShiftJob _S867 = (ShiftJob{});
        ShiftJob shift_job_0 = _S867;
        Shift _S868 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S869 = _S863 >> 28U;
        bool _S870 = spatialJob_0(_S866, _S869, &shift_job_0, true);
        Shift shifted_1;
        if(_S870)
        {
            Domain _S871 = (&shift_job_0)->dom;
            Reservoir _S872 = (&shift_job_0)->r;
            Shift _S873 = passShift_0(&_S871, &_S872);
            shifted_1 = _S873;
        }
        else
        {
            shifted_1 = _S868;
        }
        fcptStoreShiftData((_S866), (_S869), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S874 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S875 = make_int2 ((int)_S874.x, (int)_S874.y);
    FixedArray<uint, 3>  _S876;
    spatialBins_0(_S875, &_S876);
    FixedArray<uint, 3>  _S877 = _S876;
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
        bool _S878 = (_S877[t_16]) == 40U;
        if(_S878)
        {
            fcptStoreShiftData((_S875), (t_16), (make_uint4 (0U)));
        }
        uint t_17 = t_16 + 1U;
        t_16 = t_17;
    }
    FixedArray<uint, 3>  _S879 = _S877;
    queueShifts_0(_S875, &_S879, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S880 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S881 = make_int2 ((int)_S880.x, (int)_S880.y);
    FixedArray<uint, 3>  _S882;
    spatialBins_0(_S881, &_S882);
    FixedArray<uint, 3>  _S883 = _S882;
    countShifts_0(&_S883, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S884 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S885 = _S884 != 4294967295U;
    if(_S885)
    {
        uint2  _S886 = make_uint2 (_S884, _S884 >> 14U) & make_uint2 (16383U);
        int2  _S887 = make_int2 ((int)_S886.x, (int)_S886.y);
        int2  _S888 = (fcptLoadTemporalNeighbor((_S887)));
        uint _S889 = _S884 >> 28U;
        Shift _S890 = temporalShiftAt_0(_S887, _S888, _S889);
        fcptStoreTemporalShift((_S887), (_S889), (make_uint4 (asuint_1(_S890.f).x, asuint_1(_S890.f).y, asuint_1(_S890.f).z, (F32_asuint((_S890.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S891 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S892 = make_int2 ((int)_S891.x, (int)_S891.y);
    FixedArray<uint, 3>  _S893;
    temporalBins_0(_S892, &_S893);
    FixedArray<uint, 3>  _S894 = _S893;
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
        bool _S895 = (_S894[t_18]) == 40U;
        if(_S895)
        {
            fcptStoreTemporalShift((_S892), (t_18), (make_uint4 (0U)));
        }
        uint t_19 = t_18 + 1U;
        t_18 = t_19;
    }
    FixedArray<uint, 3>  _S896 = _S894;
    queueShifts_0(_S892, &_S896, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S897 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S898 = make_int2 ((int)_S897.x, (int)_S897.y);
    bool _S899 = (fcptSceneUnchanged());
    bool _S900 = !_S899;
    bool _S901;
    if(_S900)
    {
        uint2  _S902 = (fcptRenderSize());
        int2  _S903 = make_int2 ((int)_S902.x, (int)_S902.y);
        _S901 = all_0(_S898 < _S903);
    }
    else
    {
        _S901 = false;
    }
    if(_S901)
    {
        Reservoir _S904 = (fcptLoadReservoirInitial((_S898)));
        int2  _S905 = sampleNeighbor_0(_S898, _S904.seed);
        fcptStoreTemporalNeighbor((_S898), (_S905));
    }
    FixedArray<uint, 3>  _S906;
    temporalBins_0(_S898, &_S906);
    FixedArray<uint, 3>  _S907 = _S906;
    countShifts_0(&_S907, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_9, float b_5, float t_20)
{
    return a_9 + (b_5 - a_9) * t_20;
}

__device__ float confidenceCap(float duplicated_0)
{
    float _S908 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S908;
}

__device__ float2  temporalWeights(float c_2, float p_c_1, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S909 = c_2 * p_c_1;
    float _S910 = c_t_0 * p_t_0;
    return make_float2 (_S909 / (_S909 + c_t_0 * g_previous_0), _S910 / (_S910 + c_2 * g_current_0));
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S911 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S912 = make_int2 ((int)_S911.x, (int)_S911.y);
    float3  _S913 = make_float3 (0.0f);
    FKHit _S914 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S915 = Domain_x24init_0(_S913, _S913, &_S914, 0.0f, 0.0f);
    Domain dom_5 = _S915;
    bool _S916 = (fcptCurrentDomain((_S912), (&dom_5)));
    bool _S917 = !_S916;
    if(_S917)
    {
        Reservoir _S918 = (Reservoir{});
        fcptStoreReservoirTemporal((_S912), (_S918), ((&dom_5)->hit));
        return;
    }
    Reservoir _S919 = (fcptLoadReservoirInitial((_S912)));
    bool _S920 = (fcptTemporalQueued());
    bool _S921 = (fcptSceneUnchanged());
    bool _S922;
    if(_S921)
    {
        _S922 = true;
    }
    else
    {
        _S922 = !_S920;
    }
    int2  _S923;
    if(_S922)
    {
        int2  _S924 = sampleNeighbor_0(_S912, _S919.seed);
        _S923 = _S924;
    }
    else
    {
        int2  _S925 = (fcptLoadTemporalNeighbor((_S912)));
        _S923 = _S925;
    }
    bool _S926 = (_S923.x) >= int(0);
    Reservoir r_5;
    if(_S926)
    {
        Reservoir _S927 = (fcptLoadReservoirPrevious((_S923)));
        uint4  _S928 = (fcptDuplication((_S923)));
        float _S929 = (U32_asfloat((_S928.x)));
        uint _S930 = (fcptRestirDecorrelation());
        bool _S931 = _S930 == 1U;
        float _S932 = _slang_select(_S931, _S929,0.0f);
        float _S933 = confidenceCap(_S932);
        float _S934 = (F32_min((_S927.c), (_S933)));
        bool _S935 = (fcptSceneUnchanged());
        float4  _S936 = make_float4 (_S927.f.x, _S927.f.y, _S927.f.z, 1.0f);
        bool _S937 = !_S935;
        if(_S937)
        {
            _S922 = _S920;
        }
        else
        {
            _S922 = false;
        }
        float4  to_current_0;
        if(_S922)
        {
            uint4  _S938 = (fcptTemporalShift((_S912), (0U)));
            float4  _S939 = asfloat_0(_S938);
            to_current_0 = _S939;
        }
        else
        {
            if(_S937)
            {
                Shift _S940 = temporalShiftAt_0(_S912, _S923, 0U);
                float4  _S941 = make_float4 (_S940.f.x, _S940.f.y, _S940.f.z, _S940.jac);
                to_current_0 = _S941;
            }
            else
            {
                to_current_0 = _S936;
            }
        }
        Domain own_1 = _S915;
        if(_S935)
        {
            _S922 = true;
        }
        else
        {
            bool _S942 = (fcptPreviousScenes());
            bool _S943 = !_S942;
            if(_S943)
            {
                _S922 = (_S919.w) > 0.0f;
            }
            else
            {
                _S922 = false;
            }
            if(_S922)
            {
                bool _S944 = (fcptStoredDomainInitial((_S912), (_S919.seed), (&own_1)));
                _S922 = _S944;
            }
            else
            {
                _S922 = false;
            }
            if(_S922)
            {
                Domain _S945 = (fcptPreviousDomain((_S923), (_S919.seed)));
                Domain _S946 = _S945;
                Domain _S947 = own_1;
                bool _S948 = sameDomain_0(&_S946, &_S947);
                _S922 = _S948;
            }
            else
            {
                _S922 = false;
            }
        }
        float4  _S949 = make_float4 (_S919.f.x, _S919.f.y, _S919.f.z, 1.0f);
        bool _S950 = !_S922;
        if(_S950)
        {
            _S922 = _S920;
        }
        else
        {
            _S922 = false;
        }
        float4  to_previous_0;
        if(_S922)
        {
            uint4  _S951 = (fcptTemporalShift((_S912), (1U)));
            float4  _S952 = asfloat_0(_S951);
            to_previous_0 = _S952;
        }
        else
        {
            if(_S950)
            {
                Shift _S953 = temporalShiftAt_0(_S912, _S923, 1U);
                float4  _S954 = make_float4 (_S953.f.x, _S953.f.y, _S953.f.z, _S953.jac);
                to_previous_0 = _S954;
            }
            else
            {
                to_previous_0 = _S949;
            }
        }
        float _S955 = resamplingTarget(_S919.f);
        float _S956 = resamplingTarget(_S927.f);
        Selection _S957 = (Selection{});
        Selection sel_6 = _S957;
        uint _S958 = (fcptFrame());
        uint _S959 = hash(_S958);
        uint _S960 = global_invocation_id_7.x;
        uint2  _S961 = (fcptRenderSize());
        uint _S962 = stream(_S959, _S960 + _S961.x * global_invocation_id_7.y);
        uint _S963 = stream(_S962, 194U);
        (&sel_6)->random_state = _S963;
        float4  _S964 = to_previous_0;
        float _S965 = resamplingTarget(float3 {_S964.x, _S964.y, _S964.z});
        float4  _S966 = to_current_0;
        float3  _S967 = float3 {_S966.x, _S966.y, _S966.z};
        float _S968 = resamplingTarget(_S967);
        float2  _S969 = temporalWeights(_S919.c, _S955, _S934, _S956, _S965, _S968);
        offerShifted(&sel_6, _S919, Shift_x24init_0(_S919.f, 1.0f), _S969.x);
        offerShifted(&sel_6, _S927, Shift_x24init_0(_S967, to_current_0.w), _S969.y);
        Reservoir _S970 = finalize(sel_6, _S919.c + _S934);
        r_5 = _S970;
    }
    else
    {
        r_5 = _S919;
    }
    fcptStoreReservoirTemporal((_S912), (r_5), ((&dom_5)->hit));
    return;
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S971 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S972 = make_int2 ((int)_S971.x, (int)_S971.y);
    float3  _S973 = make_float3 (0.0f);
    float2  _S974 = make_float2 (0.0f);
    FKHit _S975 = Hit_x24init_0(_S974, 0U, 0U, 0U, 0.0f);
    Domain _S976 = Domain_x24init_0(_S973, _S973, &_S975, 0.0f, 0.0f);
    Domain dom_6 = _S976;
    bool _S977 = (fcptCurrentDomain((_S972), (&dom_6)));
    bool _S978 = !_S977;
    if(_S978)
    {
        Reservoir _S979 = (Reservoir{});
        fcptStoreReservoirInitial((_S972), (_S979), ((&dom_6)->hit));
        return;
    }
    uint _S980 = (fcptFrame());
    uint _S981 = hash(_S980);
    uint _S982 = global_invocation_id_8.x;
    uint2  _S983 = (fcptRenderSize());
    uint _S984 = stream(_S981, _S982 + _S983.x * global_invocation_id_8.y);
    Selection _S985 = (Selection{});
    Selection initial_0 = _S985;
    uint _S986 = stream(_S984, 193U);
    (&initial_0)->random_state = _S986;
    bool _S987 = (fcptRestirUsed());
    bool _S988 = !_S987;
    (&initial_0)->sums = _S988;
    uint _S989 = stream(_S984, 0U);
    (&(&initial_0)->r)->seed = _S989;
    FKHit _S990 = Hit_x24init_0(_S974, 4294967295U, 0U, 0U, 0.0f);
    uint _S991 = (fcptSamples());
    float _S992 = 1.0f / float(_S991);
    FKHit hit_2 = _S990;
    uint i_18 = 0U;
    float3  seen_0 = _S973;
    for(;;)
    {
        uint _S993 = (fcptSamples());
        if(i_18 < _S993)
        {
        }
        else
        {
            break;
        }
        Reservoir _S994 = (Reservoir{});
        Reservoir r_6 = _S994;
        uint _S995 = stream(_S984, i_18);
        (&r_6)->seed = _S995;
        Domain path_0 = _S976;
        bool _S996 = (fcptStoredDomainInitial((_S972), ((&r_6)->seed), (&path_0)));
        bool _S997 = !_S996;
        if(_S997)
        {
            float3  _S998 = (fcptMissed((_S972), (path_0), (_S992)));
            float3  seen_1 = seen_0 + _S998;
            seen_0 = seen_1;
            uint i_19 = i_18 + 1U;
            i_18 = i_19;
            continue;
        }
        Domain _S999 = path_0;
        Reservoir _S1000 = r_6;
        Shift _S1001 = passWalk_0(&_S999, &_S1000, false, _S992, &initial_0);
        bool _S1002 = ((&(&initial_0)->r)->seed) == ((&r_6)->seed);
        FKHit hit_3;
        if(_S1002)
        {
            FKHit _S1003 = (&path_0)->hit;
            hit_3 = _S1003;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_19 = i_18 + 1U;
        i_18 = i_19;
    }
    uint _S1004 = (fcptSamples());
    float3  seen_2 = seen_0 + (&initial_0)->glow / make_float3 (float(_S1004));
    if((&initial_0)->sums)
    {
        seen_0 = seen_2 + (&initial_0)->color;
    }
    else
    {
        seen_0 = seen_2;
    }
    fcptAddColor((_S972), (make_float4 (seen_0.x, seen_0.y, seen_0.z, 1.0f)));
    Reservoir _S1005 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S972), (_S1005), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_3, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S1006;
    (&_S1006)->none = none_0;
    (&_S1006)->pdf = pdf_3;
    (&_S1006)->origin = origin_5;
    (&_S1006)->smooth_n = smooth_n_3;
    (&_S1006)->start = start_6;
    return _S1006;
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
    Vertex _S1007;
    (&_S1007)->rough = rough_0;
    (&_S1007)->lobe = lobe_1;
    (&_S1007)->pdf = pdf_4;
    (&_S1007)->cos = cos_0;
    (&_S1007)->inside = inside_0;
    return _S1007;
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
    float3  _S1008 = exp_0((make_float3 (sigma_1) - extinction_0) * make_float3 (distance_2));
    float3  _S1009 = scatter_0 * _S1008 / make_float3 (sigma_1);
    float3  _S1010 = _slang_select(scatters_0, _S1009,_S1008);
    return _S1010;
}

static __device__ bool scatterSampled_0(bool replay_1, uint b_6, uint stop_0, bool varying_0)
{
    bool _S1011 = !replay_1;
    bool _S1012;
    if(_S1011)
    {
        _S1012 = true;
    }
    else
    {
        bool _S1013 = b_6 == stop_0;
        if(_S1013)
        {
            _S1012 = !varying_0;
        }
        else
        {
            _S1012 = false;
        }
    }
    return _S1012;
}

static __device__ uint arrivalLobe_0(uint b_7, uint prev_lobe_0)
{
    bool _S1014 = b_7 > 0U;
    uint _S1015 = _slang_select(_S1014, prev_lobe_0,3U);
    return _S1015;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_2, bool surface_5, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S1016;
    (&_S1016)->extinction_behind = extinction_behind_0;
    (&_S1016)->extinction_front = extinction_front_0;
    (&_S1016)->fillings = fillings_0;
    (&_S1016)->side = side_0;
    (&_S1016)->depth = depth_1;
    (&_S1016)->lobe = lobe_2;
    (&_S1016)->surface = surface_5;
    (&_S1016)->length = length_2;
    (&_S1016)->width = width_1;
    (&_S1016)->own = *own_2;
    (&_S1016)->fiber = fiber_0;
    return _S1016;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S1017 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S1017)
    {
        return 0.07957746833562851f;
    }
    float _S1018 = g_0 * g_0;
    return (1.0f - _S1018) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S1018 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_10, float3  b_8)
{
    float3  _S1019 = a_10 / b_8;
    float3  _S1020 = make_float3 (0.0f);
    bool3  _S1021 = b_8 == _S1020;
    float3  _S1022 = _slang_select(_S1021, _S1020,_S1019);
    return _S1022;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_6)
{
    uint _S1023 = (1U << count_6) - 1U;
    return (e_2 & (~(_S1023 << offset_1))) | ((newbits_0 & _S1023) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_7, uint end_type_0, uint end_0, float3  f_6)
{
    Reservoir candidate_2 = r_7;
    uint _S1024 = insertBits_0(r_7.path, end_0, 0U, 5U);
    uint _S1025 = insertBits_0(_S1024, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S1025;
    (&candidate_2)->f = f_6;
    return candidate_2;
}

__device__ float survivalProbability(float3  throughput_0, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_0.x), ((F32_max((throughput_0.y), (throughput_0.z)))))) / density_1), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_9)
{
    Random _S1026 = pcg(random_state_9);
    Random _S1027 = pcg(_S1026.state);
    float _S1028 = 1.0f - 2.0f * _S1026.value;
    float _S1029 = (F32_sqrt(((F32_max((1.0f - _S1028 * _S1028), (0.0f))))));
    float _S1030 = 6.28318548202514648f * _S1027.value;
    return make_float3 (_S1029 * (F32_cos((_S1030))), _S1029 * (F32_sin((_S1030))), _S1028);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_9, uint random_state_10, float * pdf_5)
{
    bool _S1031 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1031)
    {
        *pdf_5 = 0.07957746833562851f;
        float3  _S1032 = isotropic_0(random_state_10);
        return _S1032;
    }
    Random _S1033 = pcg(random_state_10);
    Random _S1034 = pcg(_S1033.state);
    float _S1035 = g_1 * g_1;
    float _S1036 = 2.0f * g_1;
    float _S1037 = (1.0f - _S1035) / (1.0f - g_1 + _S1036 * _S1033.value);
    float _S1038 = clamp_1((1.0f + _S1035 - _S1037 * _S1037) / _S1036, -1.0f, 1.0f);
    float _S1039 = (F32_sqrt(((F32_max((1.0f - _S1038 * _S1038), (0.0f))))));
    float _S1040 = 6.28318548202514648f * _S1034.value;
    float _S1041 = phaseHG_0(g_1, _S1038);
    *pdf_5 = _S1041;
    float3  _S1042 = tangentToWorld(make_float3 (_S1039 * (F32_cos((_S1040))), _S1038, _S1039 * (F32_sin((_S1040)))), dir_9);
    float3  _S1043 = ((((_S1042)) * make_float3(rnorm3df(((_S1042)).x, ((_S1042)).y, ((_S1042)).z))));
    return _S1043;
}

static __device__ Vertex scatteredVertex_0(bool is_inside_5)
{
    return Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_5);
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_0, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_1, float velvet_0, float3  toon_1, float dispersion_0)
{
    BSDFMaterial _S1044;
    (&_S1044)->albedo = albedo_0;
    (&_S1044)->emissive = emissive_0;
    (&_S1044)->roughness = roughness_0;
    (&_S1044)->metallic = metallic_0;
    (&_S1044)->transmission = transmission_0;
    (&_S1044)->ior = ior_0;
    (&_S1044)->absorption = absorption_0;
    (&_S1044)->specular_tint = specular_tint_0;
    (&_S1044)->specular_level = specular_level_0;
    (&_S1044)->translucent = translucent_0;
    (&_S1044)->sheen = sheen_2;
    (&_S1044)->sheen_roughness = sheen_roughness_0;
    (&_S1044)->anisotropy = anisotropy_0;
    (&_S1044)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1044)->tangent = tangent_1;
    (&_S1044)->velvet = velvet_0;
    (&_S1044)->toon = toon_1;
    (&_S1044)->dispersion = dispersion_0;
    return _S1044;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1045;
    (&_S1045)->scatter = scatter_1;
    (&_S1045)->extinction = extinction_1;
    (&_S1045)->g = g_2;
    return _S1045;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_9, bool skip_0, uint random_state_11, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1046;
    (&_S1046)->smooth_n = smooth_n_4;
    (&_S1046)->geometry_n = geometry_n_2;
    (&_S1046)->geometry_offset = geometry_offset_2;
    (&_S1046)->material = *material_9;
    (&_S1046)->skip = skip_0;
    (&_S1046)->random_state = random_state_11;
    (&_S1046)->coverage = coverage_0;
    (&_S1046)->encloses = encloses_0;
    (&_S1046)->volume = *volume_0;
    (&_S1046)->fills = fills_0;
    (&_S1046)->hair = hair_0;
    return _S1046;
}

static __device__ FKSurface emitting_0(FKSurface * surface_6, bool top_0)
{
    FKSurface lower_0 = *surface_6;
    float3  _S1047 = (&surface_6->material)->emissive;
    float3  _S1048 = make_float3 (0.0f);
    bool _S1049 = !top_0;
    float3  _S1050 = _slang_select(_S1049, _S1048,_S1047);
    (&(&lower_0)->material)->emissive = _S1050;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_7, float u_2)
{
    float _S1051 = surface_7->coverage;
    bool _S1052 = u_2 < _S1051;
    if(_S1052)
    {
        return *surface_7;
    }
    float3  _S1053 = make_float3 (0.0f);
    float3  _S1054 = make_float3 (1.0f);
    BSDFMaterial _S1055 = Material_x24init_0(_S1053, _S1053, 0.0f, 0.0f, 0.0f, 0.0f, _S1053, _S1054, 1.0f, _S1053, _S1053, 0.5f, 0.0f, 0.0f, _S1053, 0.0f, _S1053, 0.0f);
    BSDFMaterial material_10 = _S1055;
    (&material_10)->albedo = _S1054;
    (&material_10)->emissive = (&surface_7->material)->emissive;
    (&material_10)->transmission = 1.0f;
    (&material_10)->ior = 1.0f;
    (&material_10)->absorption = (&surface_7->material)->absorption;
    FKSurface through_0 = *surface_7;
    (&through_0)->material = material_10;
    return through_0;
}

__device__ float facingSign(float transmission_1, float3  face_0, float3  direction_0)
{
    bool _S1056 = transmission_1 > 0.0f;
    bool _S1057;
    if(_S1056)
    {
        _S1057 = true;
    }
    else
    {
        _S1057 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1058;
    if(_S1057)
    {
        _S1058 = 1.0f;
    }
    else
    {
        _S1058 = -1.0f;
    }
    return _S1058;
}

static __device__ bool arrivesBehind_0(float3  dir_10, float3  n_8)
{
    return (dot_0(dir_10, n_8)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_8, float3  dir_11)
{
    float3  _S1059 = surface_8->geometry_n;
    float _S1060 = facingSign((&surface_8->material)->transmission, surface_8->geometry_n, dir_11);
    FKSurface faced_0 = *surface_8;
    float3  _S1061 = surface_8->smooth_n * make_float3 (_S1060);
    (&faced_0)->smooth_n = _S1061;
    float3  _S1062 = _S1059 * make_float3 (_S1060);
    (&faced_0)->geometry_n = _S1062;
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
    float3  _S1063 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1063));
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
    bool _S1064;
    if(open_0)
    {
        _S1064 = prev_rough_0;
    }
    else
    {
        _S1064 = false;
    }
    if(_S1064)
    {
        _S1064 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S1064 = false;
    }
    return _S1064;
}

__device__ bool dispersive(BSDFMaterial material_11)
{
    bool _S1065 = (material_11.dispersion) > 0.0f;
    bool _S1066;
    if(_S1065)
    {
        _S1066 = (material_11.ior) != 1.0f;
    }
    else
    {
        _S1066 = false;
    }
    return _S1066;
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
        uint _S1067 = (low_1 + high_1 + 1U) / 2U;
        bool _S1068 = (WAVELENGTH_CDF_0[_S1067]) <= u_3;
        if(_S1068)
        {
            low_1 = _S1067;
        }
        else
        {
            uint _S1069 = _S1067 - 1U;
            high_1 = _S1069;
        }
    }
    uint _S1070 = low_1;
    float _S1071 = WAVELENGTH_CDF_0[low_1 + 1U] - WAVELENGTH_CDF_0[low_1];
    return make_float2 (0.37999999523162842f + 0.00499999988824129f * (float(low_1) + (u_3 - WAVELENGTH_CDF_0[_S1070]) / _S1071), _S1071 / 0.00499999988824129f);
}

__device__ static const FixedArray<float, 243>  WAVELENGTH_WEIGHTS_0 = { {
    0.00547470012679696f, -0.00465690018609166f, 0.03257500007748604f, 0.00934640038758516f, -0.00796370021998882f, 0.05577300116419792f, 0.01846100017428398f, -0.01579399965703487f, 0.11072999984025955f, 0.0416410006582737f, -0.03577499836683273f, 0.2513900101184845f, 0.09349299967288971f, -0.08071800321340561f, 0.56742000579833984f, 0.1585099995136261f, -0.13764999806880951f, 0.97018998861312866f, 0.30943000316619873f, -0.27083000540733337f, 1.91740000247955322f, 0.55217999219894409f, -0.48754000663757324f, 3.46889996528625488f, 0.95016998052597046f, -0.84802001714706421f, 6.09439992904663086f, 1.42110002040863037f, -1.28929996490478516f, 9.45199966430664062f, 1.73409998416900635f, -1.6062999963760376f, 12.12800025939941406f, 2.08030009269714355f, -1.98810005187988281f, 15.68700027465820312f, 2.20600008964538574f, -2.20120000839233398f, 18.47699928283691406f, 2.03040003776550293f, -2.17700004577636719f, 19.92700004577636719f, 1.63429999351501465f, -2.00340008735656738f, 20.86899948120117188f, 0.99410998821258545f, -1.62629997730255127f, 20.57799911499023438f, 0.20011000335216522f, -1.11409997940063477f, 19.72100067138671875f, -0.67960000038146973f, -0.45403000712394714f, 17.77599906921386719f, -1.61679995059967041f, 0.37860000133514404f, 14.71500015258789062f, -2.53410005569458008f, 1.27540004253387451f, 11.86499977111816406f, -3.39079999923706055f, 2.2146000862121582f, 9.17669963836669922f, -4.03749990463256836f, 3.0522000789642334f, 6.59509992599487305f, -4.61299991607666016f, 3.89779996871948242f, 4.64589977264404297f, -5.43039989471435547f, 5.0121002197265625f, 3.3199000358581543f, -6.37769985198974609f, 6.33809995651245117f, 2.29699993133544922f, -7.44140005111694336f, 7.91739988327026367f, 1.45389997959136963f, -8.38580036163330078f, 9.60109996795654297f, 0.66465997695922852f, -9.0167999267578125f, 11.23999977111816406f, -0.04403600096702576f, -9.17749977111816406f, 12.63199996948242188f, -0.58126997947692871f, -8.97550010681152344f, 13.91499996185302734f, -0.95730000734329224f, -8.25290012359619141f, 14.86200046539306641f, -1.24430000782012939f, -6.92129993438720703f, 15.03899955749511719f, -1.43069994449615479f, -5.29169988632202148f, 14.90900039672851562f, -1.55149996280670166f, -3.43219995498657227f, 14.70499992370605469f, -1.63569998741149902f, -1.27190005779266357f, 14.24400043487548828f, -1.67030000686645508f, 1.15170001983642578f, 13.32199954986572266f, -1.636199951171875f, 3.73889994621276855f, 12.21199989318847656f, -1.56920003890991211f, 6.43590021133422852f, 10.94699954986572266f, -1.47730004787445068f, 9.16440010070800781f, 9.54769992828369141f, -1.36399996280670166f, 12.02000045776367188f, 8.18799972534179688f, -1.25450003147125244f, 14.78699970245361328f, 6.74429988861083984f, -1.13110005855560303f, 16.72299957275390625f, 5.08780002593994141f, -0.96561002731323242f, 18.14299964904785156f, 3.57019996643066406f, -0.80725997686386108f, 19.91900062561035156f, 2.36269998550415039f, -0.69273000955581665f, 21.05500030517578125f, 1.31369996070861816f, -0.58597999811172485f, 21.3899993896484375f, 0.42390000820159912f, -0.48298001289367676f, 20.99300003051757812f, -0.23857000470161438f, -0.39412000775337219f, 19.82200050354003906f, -0.6866300106048584f, -0.31501999497413635f, 18.12000083923339844f, -0.9412500262260437f, -0.24890999495983124f, 15.7089996337890625f, -1.02020001411437988f, -0.19076000154018402f, 13.19799995422363281f, -0.98919999599456787f, -0.14401000738143921f, 11.23999977111816406f, -0.93347001075744629f, -0.11133000254631042f, 9.36649990081787109f, -0.83820998668670654f, -0.08524099737405777f, 7.41249990463256836f, -0.70064002275466919f, -0.06283199787139893f, 5.71229982376098633f, -0.56079000234603882f, -0.04586699977517128f, 4.42280006408691406f, -0.44653001427650452f, -0.03396600112318993f, 3.34489989280700684f, -0.34457001090049744f, -0.02482499927282333f, 2.49309992790222168f, -0.26017999649047852f, -0.01808100007474422f, 1.82239997386932373f, -0.1921599954366684f, -0.01296999957412481f, 1.29499995708465576f, -0.13766999542713165f, -0.00907570030540228f, 0.92928999662399292f, -0.09956400096416473f, -0.00641620019450784f, 0.61835998296737671f, -0.06671299785375595f, -0.00421149982139468f, 0.40211999416351318f, -0.04354599863290787f, -0.00271830009296536f, 0.2844499945640564f, -0.03087200038135052f, -0.00191440002527088f, 0.20672999322414398f, -0.02246100082993507f, -0.00138829997740686f, 0.15044000744819641f, -0.01634499989449978f, -0.00101030000951141f, 0.10942000150680542f, -0.01188699994236231f, -0.0007347899954766f, 0.07099699974060059f, -0.00771349994465709f, -0.00047679000999779f, 0.04539500176906586f, -0.00493190018460155f, -0.00030484999297187f, 0.03424099832773209f, -0.00372010003775358f, -0.00022995000472292f, 0.02557599917054176f, -0.00277870008721948f, -0.00017175999528263f, 0.01842200011014938f, -0.00200140010565519f, -0.0001237099932041f, 0.01316899992525578f, -0.00143079995177686f, -0.00008843900286593f, 0.00838890019804239f, -0.00091141002485529f, -0.00005633700129692f, 0.00537079991772771f, -0.00058350997278467f, -0.00003606799873523f, 0.00328280008397996f, -0.00035665999166667f, -0.00002204600059486f, 0.00196009990759194f, -0.00021296000340953f, -0.00001316300040344f, 0.00168939994182438f, -0.00018354000349063f, -0.00001134499962063f, 0.00141050003003329f, -0.00015325000276789f, -0.00000947250009631f, 0.00097123999148607f, -0.00010551999730524f, -6.52239987175562419e-06f, 0.00066868000430986f, -0.00007264900341397f, -4.49060007667867467e-06f
} };
__device__ float3  wavelengthWeights(float wavelength_0)
{
    float _S1072 = clamp_1((wavelength_0 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    uint _S1073 = (U32_min((uint(_S1072)), (79U)));
    uint _S1074 = 3U * _S1073;
    float3  _S1075 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1074], WAVELENGTH_WEIGHTS_0[_S1074 + 1U], WAVELENGTH_WEIGHTS_0[_S1074 + 2U]);
    float3  _S1076 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1074 + 3U], WAVELENGTH_WEIGHTS_0[_S1074 + 4U], WAVELENGTH_WEIGHTS_0[_S1074 + 5U]);
    return _S1075 + (_S1076 - _S1075) * make_float3 (_S1072 - float(_S1073));
}

__device__ float dispersedIor(float ior_1, float dispersion_1, float wavelength_1)
{
    float _S1077 = (ior_1 - 1.0f) * dispersion_1 / 1.90962409973144531f;
    float _S1078 = _S1077 * (1.0f / (wavelength_1 * wavelength_1) - 2.89662933349609375f);
    bool _S1079 = dispersion_1 > 0.0f;
    float _S1080 = _slang_select(_S1079, _S1078,0.0f);
    return ior_1 + _S1080;
}

__device__ float2  vertexEta(BSDFMaterial material_12, float n_dot_v_0)
{
    bool _S1081 = n_dot_v_0 < 0.0f;
    float _S1082 = _slang_select(_S1081, material_12.ior,1.0f);
    float _S1083 = _slang_select(_S1081, 1.0f,material_12.ior);
    return make_float2 (_S1082, _S1083);
}

__device__ bool neeDecision(BSDFMaterial material_13, float n_dot_v_1, float eta_i_5, float eta_o_5)
{
    float _S1084 = fresnel((F32_abs((n_dot_v_1))), eta_i_5, eta_o_5);
    float3  _S1085 = mix_0(make_float3 (_S1084), material_13.albedo, material_13.metallic);
    float _S1086 = rgb_to_greyscale(_S1085);
    float _S1087 = (F32_max(((1.0f - _S1086) * (1.0f - material_13.metallic) * (1.0f - material_13.transmission)), (0.0f)));
    bool _S1088 = _S1087 > 0.03999999910593033f;
    bool _S1089;
    if(_S1088)
    {
        _S1089 = true;
    }
    else
    {
        _S1089 = (material_13.roughness) > 0.20000000298023224f;
    }
    return _S1089;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_14)
{
    float _S1090 = rgb_to_greyscale(material_14->translucent);
    return _S1090 > 0.0f;
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
    MediumSides _S1091;
    (&_S1091)->behind = *behind_0;
    (&_S1091)->front = *front_0;
    (&_S1091)->fillings = fillings_1;
    (&_S1091)->face = face_1;
    return _S1091;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_9, FKMedium * medium_0, uint filling_0, float3  dir_12, FKMedium * outside_0)
{
    float3  _S1092 = surface_9->geometry_n;
    MediumSides _S1093 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_9->geometry_n);
    MediumSides sides_0 = _S1093;
    bool _S1094 = surface_9->encloses;
    if(_S1094)
    {
        (&sides_0)->behind = surface_9->volume;
        *&((&(&sides_0)->fillings)->x) = surface_9->fills;
        bool _S1095 = (dot_0(dir_12, _S1092)) > 0.0f;
        if(_S1095)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_10, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_13, uint depth_2, uint lobe_3, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1096 = surface_10->geometry_n;
    ShadowContext _S1097 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_10->geometry_n, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
    bool _S1098 = surface_10->encloses;
    ShadowContext context_4;
    if(_S1098)
    {
        FKSurface faced_1 = *surface_10;
        float3  _S1099 = - _S1096;
        float3  _S1100 = _slang_select(turned_0, _S1099,_S1096);
        (&faced_1)->geometry_n = _S1100;
        FKMedium _S1101 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1102 = faced_1;
        FKMedium _S1103 = _S1101;
        MediumSides _S1104 = mediumSides_0(&_S1102, &_S1103, filling_1, dir_13, outside_1);
        ShadowContext _S1105 = ShadowContext_x24init_0(_S1104.behind.extinction, _S1104.front.extinction, _S1104.fillings, _S1096, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
        if(turned_0)
        {
            uint2  _S1106 = _S1104.fillings;
            ShadowContext _S1107 = ShadowContext_x24init_0(_S1104.front.extinction, _S1104.behind.extinction, uint2 {_S1106.y, _S1106.x}, _S1096, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
            context_4 = _S1107;
        }
        else
        {
            context_4 = _S1105;
        }
    }
    else
    {
        context_4 = _S1097;
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

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_7, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_4, BSDFMaterial * material_15, float eta_i_6, float eta_o_6, bool competing_1, uint random_state_12)
{
    float3  _S1108 = light_2->dir;
    bool _S1109 = (dot_0(geometry_n_4, - in_dir_7) * dot_0(geometry_n_4, light_2->dir)) <= 0.0f;
    FixedArray<float3 , 5>  throughputs_1;
    FixedArray<float, 5>  pdfs_3;
    float3  _S1110 = BSDF(in_dir_7, _S1108, smooth_n_5, *material_15, eta_i_6, eta_o_6, _S1109, random_state_12, &throughputs_1, &pdfs_3);
    bool _S1111 = !competing_1;
    bool _S1112;
    if(_S1111)
    {
        _S1112 = true;
    }
    else
    {
        _S1112 = (light_2->density) == 0.0f;
    }
    if(_S1112)
    {
        return _S1110 * light_2->radiance;
    }
    float3  _S1113 = make_float3 (0.0f);
    uint i_24 = 0U;
    float3  weighted_0 = _S1113;
    for(;;)
    {
        if(i_24 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S1114 = (pdfs_3[i_24]) > 0.0f;
        if(_S1114)
        {
            float _S1115 = light_2->density;
            float _S1116 = pdfs_3[i_24] / light_2->density;
            float3  weighted_1 = weighted_0 + throughputs_1[i_24] * make_float3 (pdfs_3[i_24]) / make_float3 (_S1115 * (1.0f + _S1116 * _S1116));
            weighted_0 = weighted_1;
        }
        uint i_25 = i_24 + 1U;
        i_24 = i_25;
    }
    return weighted_0 * light_2->radiance * make_float3 (light_2->density);
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_1, uint random_state_13, bool refracted_3, uint lobe_4, float pdf_6)
{
    SampleBSDF _S1117;
    (&_S1117)->unit_direction = unit_direction_1;
    (&_S1117)->throughput = throughput_1;
    (&_S1117)->random_state = random_state_13;
    (&_S1117)->refracted = refracted_3;
    (&_S1117)->lobe = lobe_4;
    (&_S1117)->pdf = pdf_6;
    return _S1117;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  v_8, float3  n_i_11, float n_i_dot_v_3, BSDFMaterial material_16, Weights w_14, uint random_state_14)
{
    float3  _S1118 = make_float3 (1.0f);
    SampleBSDF _S1119 = SampleBSDF_x24init_0(_S1118, _S1118, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S1119;
    Random _S1120 = pcg(random_state_14);
    Random _S1121 = pcg(_S1120.state);
    (&sample_1)->random_state = _S1121.state;
    float _S1122 = _S1120.value;
    float _S1123 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1122 * _S1122))))));
    float _S1124 = 6.28318548202514648f * _S1121.value;
    float3  _S1125 = tangentToWorld(make_float3 (_S1123 * (F32_cos((_S1124))), _S1120.value, _S1123 * (F32_sin((_S1124)))), n_i_11);
    (&sample_1)->unit_direction = _S1125;
    (&sample_1)->lobe = 4U;
    float3  _S1126 = sheenVelvetBSDF((&sample_1)->unit_direction, v_8, n_i_11, material_16, w_14);
    (&sample_1)->throughput = _S1126;
    float _S1127 = sheenVelvetPDF(_S1120.value, n_i_dot_v_3, w_14);
    (&sample_1)->pdf = _S1127;
    return sample_1;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1128 = (F32_sqrt((random_1_0)));
    float _S1129 = 6.28318548202514648f * random_2_0;
    float _S1130 = _S1128 * (F32_cos((_S1129)));
    float _S1131 = _S1128 * (F32_sin((_S1129)));
    float _S1132 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1130 * _S1130 - _S1131 * _S1131))))));
    return make_float3 (_S1130, _S1132, _S1131);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_4, float3  n_i_12, float n_i_dot_v_4, BSDFMaterial material_17, Weights w_15, uint random_state_15)
{
    float3  _S1133 = make_float3 (1.0f);
    SampleBSDF _S1134 = SampleBSDF_x24init_0(_S1133, _S1133, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S1134;
    Random _S1135 = pcg(random_state_15);
    Random _S1136 = pcg(_S1135.state);
    (&sample_2)->random_state = _S1136.state;
    float3  _S1137 = sampleCosWeightedHemisphere(_S1135.value, _S1136.value);
    float _S1138 = translucentShare(material_17);
    bool _S1139 = u_4 < (w_15.p_diffuse * _S1138);
    float _S1140 = _S1137.y;
    float _S1141 = - _S1140;
    float _S1142 = _slang_select(_S1139, _S1141,_S1140);
    float3  _S1143 = tangentToWorld(make_float3 (_S1137.x, _S1142, _S1137.z), n_i_12);
    (&sample_2)->unit_direction = _S1143;
    (&sample_2)->refracted = _S1139;
    (&sample_2)->lobe = 0U;
    float3  _S1144 = diffuseBSDF((&sample_2)->unit_direction, n_i_12, material_17, w_15);
    (&sample_2)->throughput = _S1144;
    float _S1145 = diffusePDF(_S1142, n_i_dot_v_4, material_17, w_15);
    (&sample_2)->pdf = _S1145;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF toonSample(float3  n_i_13, ToonShape shape_2, Weights w_16, uint random_state_16)
{
    float3  _S1146 = make_float3 (1.0f);
    SampleBSDF _S1147 = SampleBSDF_x24init_0(_S1146, _S1146, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S1147;
    Random _S1148 = pcg(random_state_16);
    Random _S1149 = pcg(_S1148.state);
    (&sample_3)->random_state = _S1149.state;
    float _S1150 = _S1148.value * shape_2.norm / 6.28318548202514648f;
    float t_21;
    if(shape_2.glossy)
    {
        t_21 = (F32_acos((clamp_1(1.0f - _S1150, -1.0f, 1.0f))));
    }
    else
    {
        t_21 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1150)))), (1.0f))))));
    }
    if(t_21 < (shape_2.a))
    {
    }
    else
    {
        t_21 = (shape_2.a + shape_2.b) / 2.0f;
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
        float _S1151;
        if(t_21 < (shape_2.a))
        {
            _S1151 = 1.0f;
        }
        else
        {
            _S1151 = (F32_max((1.0f - (t_21 - shape_2.a) / (F32_max((shape_2.s), (0.0000152587890625f)))), (0.0f)));
        }
        float integral_2;
        if(shape_2.glossy)
        {
            integral_2 = 1.0f - (F32_cos(((F32_min((t_21), (shape_2.a))))));
        }
        else
        {
            float _S1152 = (F32_sin(((F32_min((t_21), (shape_2.a))))));
            integral_2 = _S1152 * _S1152 / 2.0f;
        }
        bool _S1153 = t_21 > (shape_2.a);
        bool _S1154;
        if(_S1153)
        {
            _S1154 = (shape_2.s) > 0.0f;
        }
        else
        {
            _S1154 = false;
        }
        float integral_3;
        if(_S1154)
        {
            if(shape_2.glossy)
            {
                float _S1155 = (F32_cos((shape_2.a)));
                float _S1156 = (F32_cos((t_21)));
                integral_3 = (1.0f + shape_2.a / shape_2.s) * (_S1155 - _S1156) - ((F32_sin((t_21))) - t_21 * _S1156 - ((F32_sin((shape_2.a))) - shape_2.a * _S1155)) / shape_2.s;
            }
            else
            {
                float _S1157 = 2.0f * shape_2.a;
                float _S1158 = (F32_cos((_S1157)));
                float _S1159 = 2.0f * t_21;
                float _S1160 = (F32_cos((_S1159)));
                integral_3 = (1.0f + shape_2.a / shape_2.s) * (_S1158 - _S1160) / 4.0f - ((F32_sin((_S1159))) / 8.0f - t_21 * _S1160 / 4.0f - ((F32_sin((_S1157))) / 8.0f - shape_2.a * _S1158 / 4.0f)) / shape_2.s;
            }
            float integral_4 = integral_2 + integral_3;
            integral_3 = integral_4;
        }
        else
        {
            integral_3 = integral_2;
        }
        float _S1161 = _S1151 * (F32_sin((t_21)));
        float _S1162;
        if(shape_2.glossy)
        {
            _S1162 = 1.0f;
        }
        else
        {
            _S1162 = (F32_cos((t_21)));
        }
        float _S1163 = _S1161 * _S1162;
        float _S1164 = (integral_3 - _S1150) / _S1163;
        bool _S1165 = _S1163 > 0.0f;
        float _S1166 = _slang_select(_S1165, _S1164,0.0f);
        float _S1167 = clamp_1(t_21 - _S1166, 0.0f, shape_2.b);
        int k_1 = k_0 + int(1);
        t_21 = _S1167;
        k_0 = k_1;
    }
    float _S1168 = 6.28318548202514648f * _S1149.value;
    float _S1169 = (F32_sin((t_21)));
    float3  _S1170 = tangentToWorld(make_float3 (_S1169 * (F32_cos((_S1168))), (F32_cos((t_21))), _S1169 * (F32_sin((_S1168)))), shape_2.axis);
    (&sample_3)->unit_direction = _S1170;
    bool _S1171 = (dot_0(n_i_13, (&sample_3)->unit_direction)) < 0.0f;
    (&sample_3)->refracted = _S1171;
    (&sample_3)->lobe = 6U;
    float3  _S1172 = toonBSDF((&sample_3)->unit_direction, n_i_13, shape_2, w_16);
    (&sample_3)->throughput = _S1172;
    float _S1173 = toonPDF(dot_0(n_i_13, (&sample_3)->unit_direction), dot_0((&sample_3)->unit_direction, shape_2.axis), shape_2, w_16);
    (&sample_3)->pdf = _S1173;
    return sample_3;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_14, float alpha_8, AnisotropicFrame frame_6, BSDFMaterial material_18, Weights w_17, float pdf_h_3, float eta_i_7, float eta_o_7, uint random_state_17)
{
    float3  _S1174 = make_float3 (1.0f);
    SampleBSDF _S1175 = SampleBSDF_x24init_0(_S1174, _S1174, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S1175;
    (&sample_4)->unit_direction = w_17.refracted;
    (&sample_4)->random_state = random_state_17;
    (&sample_4)->refracted = true;
    (&sample_4)->lobe = 1U;
    float3  _S1176 = refractBSDF((&sample_4)->unit_direction, n_i_14, alpha_8, frame_6, material_18, w_17);
    (&sample_4)->throughput = _S1176;
    float _S1177 = refractPDF(dot_0((&sample_4)->unit_direction, ggx_n_3), pdf_h_3, w_17, eta_i_7, eta_o_7);
    (&sample_4)->pdf = _S1177;
    return sample_4;
}

static __device__ float3  reflect_0(float3  i_26, float3  n_9)
{
    return i_26 - make_float3 (2.0f * dot_0(n_9, i_26)) * n_9;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_8, float3  ggx_n_4, float3  n_i_15, float alpha_9, AnisotropicFrame frame_7, Weights w_18, float pdf_h_4, uint random_state_18)
{
    float3  _S1178 = make_float3 (1.0f);
    SampleBSDF _S1179 = SampleBSDF_x24init_0(_S1178, _S1178, 0U, false, 0U, 0.0f);
    SampleBSDF sample_5 = _S1179;
    float3  _S1180 = reflect_0(in_dir_8, ggx_n_4);
    float3  _S1181 = ((((_S1180)) * make_float3(rnorm3df(((_S1180)).x, ((_S1180)).y, ((_S1180)).z))));
    (&sample_5)->unit_direction = _S1181;
    (&sample_5)->random_state = random_state_18;
    (&sample_5)->lobe = 2U;
    float3  _S1182 = reflectBSDF((&sample_5)->unit_direction, n_i_15, alpha_9, frame_7, w_18);
    (&sample_5)->throughput = _S1182;
    float _S1183 = reflectPDF(pdf_h_4, w_18);
    (&sample_5)->pdf = _S1183;
    return sample_5;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_9, float3  n_10, BSDFMaterial material_19, float eta_i_8, float eta_o_8, uint random_init_0, float2  screen_space_0)
{
    uint random_state_19 = random_init_0;
    float3  _S1184 = negate_0(in_dir_9);
    float _S1185 = dot_0(n_10, _S1184);
    float _S1186 = sign_0(_S1185);
    float3  n_i_16 = n_10 * make_float3 (_S1186);
    float _S1187 = (F32_abs((_S1185)));
    float _S1188 = material_19.roughness;
    float _S1189 = _S1188 * _S1188;
    AnisotropicFrame _S1190 = anisotropicFrame(material_19, n_i_16);
    float3  _S1191 = sampleHalfVector(_S1184, n_i_16, _S1189, _S1190, &random_state_19);
    Weights _S1192 = lobeWeights(in_dir_9, _S1184, n_i_16, _S1191, _S1190, material_19, eta_i_8, eta_o_8);
    Random _S1193 = pcg(random_state_19);
    random_state_19 = _S1193.state;
    bool _S1194 = (_S1193.value) < (_S1192.p_sheen_velvet);
    if(_S1194)
    {
        SampleBSDF _S1195 = sheenVelvetSample(_S1184, n_i_16, _S1187, material_19, _S1192, random_state_19);
        return _S1195;
    }
    float _S1196 = _S1193.value - _S1192.p_sheen_velvet;
    bool _S1197 = _S1196 < (_S1192.p_diffuse);
    if(_S1197)
    {
        SampleBSDF _S1198 = diffuseSample(_S1196, n_i_16, _S1187, material_19, _S1192, random_state_19);
        return _S1198;
    }
    bool _S1199 = _S1196 < (_S1192.p_diffuse + _S1192.p_toon);
    if(_S1199)
    {
        ToonShape _S1200 = toonShape(_S1184, n_i_16, material_19);
        SampleBSDF _S1201 = toonSample(n_i_16, _S1200, _S1192, random_state_19);
        return _S1201;
    }
    float _S1202 = vndfPDF(_S1184, _S1191, n_i_16, _S1187, _S1189, _S1190, _S1192.v_dot_h);
    bool _S1203 = (_S1196 - _S1192.p_toon) < (_S1192.p_diffuse + _S1192.p_refract);
    if(_S1203)
    {
        SampleBSDF _S1204 = refractSample(_S1191, n_i_16, _S1189, _S1190, material_19, _S1192, _S1202, eta_i_8, eta_o_8, random_state_19);
        return _S1204;
    }
    SampleBSDF _S1205 = reflectSample(in_dir_9, _S1191, n_i_16, _S1189, _S1190, _S1192, _S1202, random_state_19);
    return _S1205;
}

__device__ bool withinInverseFootprint(float pdf_7, bool diffuse_0, float prev_cos_0, float distance_5, float threshold_1)
{
    bool _S1206 = pdf_7 > 0.0f;
    bool _S1207;
    if(_S1206)
    {
        if(diffuse_0)
        {
            _S1207 = true;
        }
        else
        {
            _S1207 = (pdf_7 * prev_cos_0 / (distance_5 * distance_5) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S1207 = false;
    }
    return _S1207;
}

__device__ bool roughLobe(float pdf_8, bool diffuse_1, float roughness_1)
{
    bool _S1208 = pdf_8 > 0.0f;
    bool _S1209;
    if(_S1208)
    {
        if(diffuse_1)
        {
            _S1209 = true;
        }
        else
        {
            _S1209 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S1209 = false;
    }
    return _S1209;
}

static __device__ bool passesLayer_0(uint layers_0, bool refracting_0, bool passed_0)
{
    bool _S1210 = layers_0 > 1U;
    bool _S1211;
    if(_S1210)
    {
        _S1211 = refracting_0 != passed_0;
    }
    else
    {
        _S1211 = false;
    }
    return _S1211;
}

static __device__ float widened_0(float spread_1, float pdf_9, bool delta_0)
{
    float _S1212 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * pdf_9))))), (3.14159274101257324f)));
    bool _S1213 = !delta_0;
    float _S1214 = _slang_select(_S1213, _S1212,0.0f);
    return spread_1 + _S1214;
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
    bool _S1215;
    float density_2;
    float threshold_2;
    float width_3;
    float sky_pdf_0;
    float wavelength_2;
    uint b_9;
    uint layer_0;
    float3  throughput_2;
    float3  chain_throughput_0;
    TreeSample light_3;
    int _S1216;
    Shift ended_0;
    float density_3;
    float spread_3;
    float width_4;
    float sky_pdf_1;
    float spread_4;
    float width_5;
    uint b_10;
    float3  _S1217 = make_float3 (0.0f);
    Shift _S1218 = Shift_x24init_0(_S1217, 0.0f);
    uint _S1219 = r_8->path;
    uint _S1220 = extractBits_0(r_8->path, 0U, 5U);
    uint _S1221 = extractBits_0(_S1219, 5U, 5U);
    uint _S1222 = extractBits_0(_S1219, 10U, 2U);
    uint _S1223 = extractBits_0(_S1219, 12U, 3U);
    bool passes_0;
    if(replay_2)
    {
        bool _S1224 = _S1223 >= 3U;
        uint _S1225 = _slang_select(_S1224, 1U,0U);
        uint _S1226 = _S1220 + _S1225;
        uint _S1227 = (fcptMaxBounces());
        passes_0 = _S1226 > _S1227;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1218;
    }
    uint _S1228 = _S1221 - 1U;
    bool _S1229 = _S1223 == 3U;
    uint _S1230 = _slang_select(_S1229, 1U,0U);
    uint _S1231 = _S1220 + _S1230;
    bool _S1232 = _S1222 == 0U;
    uint _S1233 = _slang_select(_S1232, _S1231,_S1228);
    FKHit _S1234 = (fcptReservoirHit((*r_8)));
    float3  _S1235 = dom_7->x0;
    float3  _S1236 = dom_7->x1 - dom_7->x0;
    float3  _S1237 = ((((_S1236)) * make_float3(rnorm3df(((_S1236)).x, ((_S1236)).y, ((_S1236)).z))));
    FKRay _S1238 = Ray_x24init_0(dom_7->x1, _S1237);
    FKRay ray_2 = _S1238;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1217;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_1 = throughput_3;
    float3  glowed_0 = _S1217;
    float3  extinction_in_0 = _S1217;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1239 = dom_7->spread;
    float _S1240 = dom_7->width;
    float _S1241 = length_0(_S1236);
    NEEVertex _S1242 = NEEVertex_x24init_0(true, 0.0f, _S1217, _S1217, _S1217);
    NEEVertex nee_vertex_0 = _S1242;
    Vertex _S1243 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S1243;
    Reservoir _S1244 = (Reservoir{});
    Reservoir chain_0 = _S1244;
    uint _S1245 = r_8->seed;
    (&chain_0)->seed = r_8->seed;
    (&ray_2)->origin = _S1235;
    (&hit_4)->distance = _S1241;
    FKMedium _S1246 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1247 = filling_2;
    bool _S1248 = (fcptVaryingUsed());
    uint _S1249 = _slang_select(_S1248, _S1247,4294967295U);
    filling_2 = _S1249;
    scatter_in_0 = _S1246.scatter;
    extinction_in_0 = _S1246.extinction;
    g_in_0 = _S1246.g;
    Reservoir _S1250 = chain_0;
    uint _S1251 = filling_2;
    for(;;)
    {
        bool _S1252 = (fcptVaryingUsed());
        if(_S1252)
        {
            passes_0 = _S1251 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1253 = (fcptMajorant((_S1251)));
            spread_2 = _S1253;
        }
        else
        {
            spread_2 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_2)
        {
            turned_1 = 4294967295U == _S1233;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1222 == 1U;
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
            ended_0 = _S1218;
            sky_pdf_0 = 0.0f;
            spread_2 = _S1239;
            width_3 = _S1240;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_9 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1254 = (&prev_0)->rough;
        if(_S1254)
        {
            turned_1 = !(spread_2 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S1255 = stream(_S1245, 384U);
        uint tracking_0 = _S1255;
        weight_1 = throughput_3;
        glowed_0 = _S1217;
        b_9 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        threshold_2 = _S1239;
        width_3 = _S1240;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1216 = int(1);
                break;
            }
            uint _S1256 = b_9 + 320U;
            bool _S1257 = b_9 == 4294967295U;
            uint _S1258 = _slang_select(_S1257, 384U,_S1256);
            uint _S1259 = stream(_S1245, _S1258);
            Random _S1260 = pcg(_S1259);
            float _S1261 = freeFlight_0(_S1260.value, spread_2);
            if(passes_0)
            {
                float3  _S1262 = (&ray_2)->origin;
                float3  _S1263 = (&ray_2)->unit_direction;
                float _S1264 = (&hit_4)->distance;
                uint _S1265 = _slang_select(_S1257, 0U,b_9);
                uint _S1266 = (&prev_0)->lobe;
                uint _S1267 = _slang_select(_S1257, 3U,_S1266);
                float _S1268 = (fcptTrackMedium((_S1251), (_S1262), (_S1263), (_S1264), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1265), (_S1267), (_S1257)));
                wavelength_2 = _S1268;
            }
            else
            {
                wavelength_2 = _S1261;
            }
            bool _S1269 = !(wavelength_2 < ((&hit_4)->distance));
            if(_S1269)
            {
                _S1216 = int(1);
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
                float3  _S1270 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S1271 = sel_7->glow + _S1270;
                sel_7->glow = _S1271;
            }
            else
            {
            }
            glowed_0 = _S1217;
            uint b_11 = b_9 + 1U;
            float3  _S1272 = (&ray_2)->origin + make_float3 (wavelength_2) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1272;
            float3  _S1273 = flightWeight_0(scatter_in_0, extinction_in_0, spread_2, wavelength_2, true);
            float3  _S1274 = weight_1;
            float3  _S1275 = _slang_select(passes_0, _S1274,_S1273);
            float3  throughput_4 = throughput_2 * _S1275;
            uint _S1276 = stream(_S1245, b_11 + 320U);
            tracking_0 = _S1276;
            weight_1 = throughput_3;
            float width_6 = width_3 + threshold_2 * wavelength_2;
            float _S1277 = threshold_2 + 3.14159274101257324f;
            bool _S1278 = scatterSampled_0(replay_2, b_11, _S1233, passes_0);
            TreeSample _S1279 = TreeSample_x24init_0(_S1217, _S1217, 0.0f, 0U);
            if(_S1278)
            {
                float3  _S1280 = (&ray_2)->origin;
                float3  _S1281 = (&ray_2)->unit_direction;
                float3  _S1282 = (&ray_2)->unit_direction;
                uint _S1283 = stream(_S1245, b_11 + 64U);
                float3  _S1284 = extinction_in_0;
                float3  _S1285 = extinction_in_0;
                uint2  _S1286 = make_uint2 (_S1251);
                float3  _S1287 = (&ray_2)->unit_direction;
                uint _S1288 = arrivalLobe_0(b_11, (&prev_0)->lobe);
                FKHit _S1289 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1290 = _S1289;
                ShadowContext _S1291 = ShadowContext_x24init_0(_S1284, _S1285, _S1286, _S1287, b_11, _S1288, false, wavelength_2, width_6, &_S1290, false);
                ShadowContext _S1292 = _S1291;
                TreeSample _S1293 = sampleLightTree_0(_S1280, _S1281, _S1282, 0.0f, true, _S1283, &_S1292);
                light_3 = _S1293;
            }
            else
            {
                light_3 = _S1279;
            }
            float _S1294 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S1295 = (fcptMaxBounces());
            bool _S1296 = b_11 < _S1295;
            if(_S1296)
            {
                is_inside_6 = (light_3.density) > 0.0f;
            }
            else
            {
                is_inside_6 = false;
            }
            float _S1297 = _slang_select(is_inside_6, _S1294,0.0f);
            float3  _S1298 = throughput_4 * light_3.radiance;
            float _S1299 = powerHeuristic(light_3.density, _S1297);
            float3  _S1300 = _S1298 * make_float3 (_S1294 * _S1299);
            float3  _S1301 = _slang_select(_S1278, _S1300,_S1217);
            if(replay_2)
            {
                viewed_0 = b_11 == _S1233;
            }
            else
            {
                viewed_0 = false;
            }
            if(viewed_0)
            {
                bool _S1302 = _S1222 == 2U;
                if(_S1302)
                {
                    float _S1303 = resamplingTarget(_S1301);
                    passes_0 = _S1303 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1304 = Shift_x24init_0(_S1301, 1.0f);
                    _S1216 = int(0);
                    ended_0 = _S1304;
                    spread_2 = _S1277;
                    wavelength_2 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_11;
                    break;
                }
                _S1216 = int(0);
                ended_0 = _S1218;
                spread_2 = _S1277;
                wavelength_2 = width_6;
                chain_throughput_0 = throughput_4;
                layer_0 = b_11;
                break;
            }
            bool _S1305 = !replay_2;
            if(_S1305)
            {
                Reservoir candidate_3 = _S1250;
                uint _S1306 = extractBits_0(_S1250.path, 10U, 2U);
                bool _S1307 = _S1306 == 1U;
                if(_S1307)
                {
                    float3  _S1308 = safeDivide(_S1301, _S1217);
                    (&candidate_3)->radiance = _S1308;
                }
                else
                {
                    uint _S1309 = insertBits_0(0U, b_11 + 1U, 5U, 5U);
                    uint _S1310 = insertBits_0(_S1309, 2U, 10U, 2U);
                    (&candidate_3)->path = _S1310;
                }
                Reservoir _S1311 = withEnd(candidate_3, 0U, b_11, _S1301);
                offer(sel_7, _S1311, _S1301 * make_float3 (scale_3) / make_float3 (density_2));
                float _S1312 = survivalProbability(abs_0(throughput_4), density_2);
                uint _S1313 = stream(_S1245, b_11 + 128U);
                Random _S1314 = pcg(_S1313);
                bool _S1315 = _S1312 < (_S1314.value);
                if(_S1315)
                {
                    _S1215 = true;
                }
                else
                {
                    uint _S1316 = (fcptMaxBounces());
                    _S1215 = b_11 >= _S1316;
                }
                if(_S1215)
                {
                    _S1216 = int(0);
                    ended_0 = _S1218;
                    spread_2 = _S1277;
                    wavelength_2 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_11;
                    break;
                }
                float _S1317 = density_2 * _S1312;
                density_2 = _S1317;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1318 = stream(_S1245, b_11);
            float3  _S1319 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1318, &phase_pdf_0);
            (&ray_2)->unit_direction = _S1319;
            NEEVertex _S1320 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S1217, (&ray_2)->origin);
            nee_vertex_0 = _S1320;
            Vertex _S1321 = scatteredVertex_0(false);
            prev_0 = _S1321;
            float _S1322 = (&prev_0)->pdf;
            FKRay _S1323 = ray_2;
            FKHit _S1324 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1325 = (fcptTraverseInstanceBVH((_S1323), (true), (4.294967296e+09f), (false), (_S1324), (false)));
            hit_4 = _S1325;
            b_9 = b_11;
            throughput_2 = throughput_4;
            threshold_2 = _S1277;
            width_3 = width_6;
            sky_pdf_0 = _S1322;
        }
        if(_S1216 != int(1))
        {
            width_3 = wavelength_2;
            throughput_2 = chain_throughput_0;
            b_9 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1218;
        spread_2 = threshold_2;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1326 = b_9 == 4294967295U;
    bool _S1327 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1327)
    {
        bool _S1328 = !(&nee_vertex_0)->none;
        float _S1329 = _slang_select(_S1328, sky_pdf_0,0.0f);
        float _S1330 = escapeWeight_0(_S1329, (&ray_2)->unit_direction);
        float3  _S1331 = environment_0((&ray_2)->unit_direction, b_9, (&prev_0)->lobe);
        float3  _S1332 = throughput_2 * _S1331;
        if(replay_2)
        {
            bool _S1333 = b_9 == _S1233;
            if(_S1333)
            {
                passes_0 = _S1222 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S1332 * make_float3 (_S1330) / make_float3 (r_8->jac), density_2 / r_8->jac);
            }
            if(_S1232)
            {
                passes_0 = _S1229;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_9 == _S1220;
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
                return Shift_x24init_0(_S1332 * make_float3 (_S1330), 1.0f);
            }
            return _S1218;
        }
        Reservoir candidate_4 = chain_0;
        uint _S1334 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1335 = _S1334 == 1U;
        if(_S1335)
        {
            uint _S1336 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S1337 = _S1336 == b_9;
            float _S1338 = _slang_select(_S1337, 1.0f,_S1330);
            float3  _S1339 = safeDivide(_S1332 * make_float3 (_S1338), _S1217);
            (&candidate_4)->radiance = _S1339;
        }
        else
        {
            bool _S1340 = (&prev_0)->rough;
            if(_S1340)
            {
                uint _S1341 = insertBits_0(0U, b_9 + 1U, 5U, 5U);
                uint _S1342 = insertBits_0(_S1341, 3U, 10U, 2U);
                uint _S1343 = insertBits_0(_S1342, (&prev_0)->lobe, 15U, 3U);
                bool _S1344 = (&prev_0)->inside;
                uint _S1345 = _slang_select(_S1344, 1U,0U);
                uint _S1346 = insertBits_0(_S1343, _S1345, 22U, 1U);
                (&candidate_4)->path = _S1346;
                (&candidate_4)->jac = (&prev_0)->pdf;
                (&candidate_4)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S1347 = _S1332 * make_float3 (_S1330);
        Reservoir _S1348 = withEnd(candidate_4, 3U, b_9, _S1347);
        offer(sel_7, _S1348, _S1347 * make_float3 (scale_3) / make_float3 (density_2));
        return _S1218;
    }
    float3  _S1349 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S1349;
    bool _S1350 = (fcptVaryingUsed());
    if(_S1350)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1351 = !replay_2;
        if(_S1351)
        {
            float3  _S1352 = throughput_2 * glowed_0 / make_float3 (density_2);
            float3  _S1353 = sel_7->glow + _S1352;
            sel_7->glow = _S1353;
        }
        float3  _S1354 = throughput_2 * weight_1;
        throughput_2 = _S1354;
    }
    else
    {
        float3  _S1355 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
        float3  _S1356 = throughput_2 * _S1355;
        throughput_2 = _S1356;
    }
    float _S1357 = width_3 + spread_2 * (&hit_4)->distance;
    uint _S1358 = b_9 + 1U;
    b_9 = _S1358;
    layer_0 = 0U;
    width_3 = _S1357;
    passes_0 = false;
    threshold_2 = 0.0f;
    turned_1 = false;
    is_inside_6 = false;
    wavelength_2 = 0.0f;
    chain_throughput_0 = _S1217;
    float3  reconnection_0 = _S1217;
    viewed_0 = _S1326;
    for(;;)
    {
        bool _S1359 = ((&hit_4)->is_point_light) == 1U;
        if(replay_2)
        {
            _S1215 = _S1222 == 1U;
        }
        else
        {
            _S1215 = false;
        }
        bool _S1360;
        if(_S1215)
        {
            _S1360 = b_9 == _S1221;
        }
        else
        {
            _S1360 = false;
        }
        bool _S1361;
        if(_S1360)
        {
            bool _S1362 = ((&hit_4)->instance_index) != (_S1234.instance_index);
            if(_S1362)
            {
                _S1361 = true;
            }
            else
            {
                _S1361 = ((&hit_4)->triangle_index) != (_S1234.triangle_index);
            }
        }
        else
        {
            _S1361 = false;
        }
        if(_S1361)
        {
            return _S1218;
        }
        FKMedium _S1363 = Medium_x24init_0(_S1217, _S1217, 0.0f);
        BSDFMaterial _S1364 = Material_x24init_0(_S1217, _S1217, 0.0f, 0.0f, 0.0f, 0.0f, _S1217, throughput_3, 1.0f, _S1217, _S1217, 0.5f, 0.0f, 0.0f, _S1217, 0.0f, _S1217, 0.0f);
        FKMedium _S1365 = _S1363;
        FKSurface _S1366 = Surface_x24init_0(_S1217, _S1217, 0.0f, &_S1364, false, 0U, 1.0f, false, &_S1365, 4294967295U, _S1217);
        bool _S1367 = !_S1359;
        bool scatter_2;
        bool is_inside_7;
        float geometry_density_2;
        float3  throughput_5;
        FKSurface surface_12;
        if(_S1367)
        {
            uint _S1368 = stream(_S1245, b_9);
            uint _S1369 = arrivalLobe_0(b_9, (&prev_0)->lobe);
            FKSurface _S1370 = (fcptSurfaceAtPath((hit_4), ((&ray_2)->origin), (_S1368), (width_3), (layer_0), (b_9), (_S1369), ((&ray_2)->unit_direction)));
            bool _S1371 = !passes_0;
            FKSurface _S1372 = _S1370;
            FKSurface _S1373 = emitting_0(&_S1372, _S1371);
            uint _S1374 = stream(_S1245, b_9 + 256U);
            Random _S1375 = pcg(_S1374);
            FKSurface _S1376 = _S1373;
            FKSurface _S1377 = uncovered_0(&_S1376, _S1375.value);
            float _S1378 = facingSign(_S1377.material.transmission, _S1377.geometry_n, (&ray_2)->unit_direction);
            bool _S1379 = _S1378 < 0.0f;
            bool _S1380 = (_S1377.material.transmission) > 0.0f;
            if(_S1380)
            {
                bool _S1381 = arrivesBehind_0((&ray_2)->unit_direction, _S1377.geometry_n);
                scatter_2 = _S1381;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1382 = _S1377;
            FKSurface _S1383 = facingRay_0(&_S1382, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S1384 = arrivesBehind_0((&ray_2)->unit_direction, _S1383.geometry_n);
                is_inside_7 = _S1384;
            }
            else
            {
                is_inside_7 = scatter_2;
            }
            if(is_inside_7)
            {
                float3  _S1385 = beerLambert((&hit_4)->distance, _S1383.material.absorption);
                float3  _S1386 = throughput_2 * _S1385;
                throughput_5 = _S1386;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S1387 = !_S1383.skip;
            float geometry_density_3 = geometryDensity(_S1383.geometry_n, (&ray_2)->unit_direction, (&hit_4)->distance);
            bool _S1388 = b_9 == _S1358;
            if(_S1388)
            {
                float _S1389 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S1389;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            float _S1390 = geometry_density_2;
            scatter_2 = _S1387;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S1390;
            surface_12 = _S1383;
            turned_1 = _S1379;
        }
        else
        {
            scatter_2 = false;
            geometry_density_2 = 0.0f;
            surface_12 = _S1366;
            throughput_5 = throughput_2;
            is_inside_7 = is_inside_6;
        }
        bool _S1391 = withinFootprint(scatter_2, (&prev_0)->rough, (&prev_0)->pdf, geometry_density_2, threshold_2);
        FKSurface _S1392 = surface_12;
        FKSurface _S1393 = surface_12;
        float _S1394 = dot_0(surface_12.smooth_n, - (&ray_2)->unit_direction);
        bool _S1395 = (fcptDispersionUsed());
        bool _S1396;
        if(_S1395)
        {
            _S1396 = wavelength_2 == 0.0f;
        }
        else
        {
            _S1396 = false;
        }
        bool _S1397;
        if(_S1396)
        {
            _S1397 = scatter_2;
        }
        else
        {
            _S1397 = false;
        }
        bool _S1398;
        if(_S1397)
        {
            bool _S1399 = dispersive(_S1392.material);
            _S1398 = _S1399;
        }
        else
        {
            _S1398 = false;
        }
        float3  throughput_6;
        if(_S1398)
        {
            uint _S1400 = stream(_S1245, 512U);
            Random _S1401 = pcg(_S1400);
            float2  _S1402 = sampleWavelength(_S1401.value);
            float _S1403 = _S1402.x;
            float3  _S1404 = wavelengthWeights(_S1403);
            float3  _S1405 = throughput_5 * (_S1404 / make_float3 (_S1402.y));
            wavelength_2 = _S1403;
            throughput_6 = _S1405;
        }
        else
        {
            throughput_6 = throughput_5;
        }
        BSDFMaterial refractive_0 = _S1392.material;
        float _S1406 = dispersedIor(_S1392.material.ior, _S1392.material.dispersion, wavelength_2);
        bool _S1407 = wavelength_2 > 0.0f;
        float _S1408 = _slang_select(_S1407, _S1406,_S1392.material.ior);
        (&refractive_0)->ior = _S1408;
        float2  _S1409 = vertexEta(refractive_0, _S1394);
        bool _S1410;
        if(scatter_2)
        {
            bool _S1411 = neeDecision(_S1392.material, _S1394, _S1409.x, _S1409.y);
            _S1410 = _S1411;
        }
        else
        {
            _S1410 = false;
        }
        bool _S1412;
        if(passes_0)
        {
            _S1412 = true;
        }
        else
        {
            _S1412 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1412)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1410;
        }
        bool _S1413 = (fcptHairUsed());
        bool _S1414;
        if(_S1413)
        {
            float3  _S1415 = surface_12.hair;
            _S1414 = (dot_0(_S1415, _S1415)) > 0.0f;
        }
        else
        {
            _S1414 = false;
        }
        bool _S1416;
        if(_S1414)
        {
            _S1416 = true;
        }
        else
        {
            BSDFMaterial _S1417 = _S1392.material;
            bool _S1418 = isTranslucent_0(&_S1417);
            _S1416 = _S1418;
        }
        bool _S1419;
        if(_S1416)
        {
            _S1419 = true;
        }
        else
        {
            bool _S1420 = (_S1392.material.transmission) > 0.0f;
            if(_S1420)
            {
                uint _S1421 = (fcptLayers((hit_4)));
                _S1419 = _S1421 == 1U;
            }
            else
            {
                _S1419 = false;
            }
        }
        float3  emission_0;
        if(_S1359)
        {
            float3  _S1422 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1422;
        }
        else
        {
            emission_0 = _S1392.material.emissive;
        }
        bool _S1423 = !replay_2;
        bool _S1424;
        if(_S1423)
        {
            _S1424 = true;
        }
        else
        {
            _S1424 = b_9 >= _S1233;
        }
        bool _S1425;
        if(_S1424)
        {
            float _S1426 = rgb_to_greyscale(emission_0);
            _S1425 = _S1426 > 0.0f;
        }
        else
        {
            _S1425 = false;
        }
        float3  emission_1;
        if(_S1425)
        {
            NEEVertex _S1427 = nee_vertex_0;
            FKHit _S1428 = hit_4;
            float _S1429 = emissionWeight_0(&_S1427, &_S1428, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1429);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1430;
        if(replay_2)
        {
            _S1430 = _S1222 == 1U;
        }
        else
        {
            _S1430 = false;
        }
        bool _S1431;
        if(_S1430)
        {
            _S1431 = b_9 > _S1221;
        }
        else
        {
            _S1431 = false;
        }
        bool _S1432;
        if(_S1431)
        {
            _S1432 = b_9 == _S1220;
        }
        else
        {
            _S1432 = false;
        }
        bool _S1433;
        if(_S1432)
        {
            bool _S1434 = _S1223 == 1U;
            if(_S1434)
            {
                _S1433 = true;
            }
            else
            {
                _S1433 = _S1223 == 2U;
            }
        }
        else
        {
            _S1433 = false;
        }
        if(_S1433)
        {
            bool _S1435 = _S1359 != (_S1223 == 2U);
            if(_S1435)
            {
                return _S1218;
            }
            return Shift_x24init_0(throughput_6 * emission_1 / make_float3 (r_8->jac), density_2 / r_8->jac);
        }
        uint _S1436 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1437 = _S1436 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1438 = insertBits_0(0U, b_9, 5U, 5U);
        uint _S1439 = insertBits_0(_S1438, 1U, 10U, 2U);
        uint _S1440 = insertBits_0(_S1439, (&prev_0)->lobe, 15U, 3U);
        bool _S1441 = (&prev_0)->inside;
        uint _S1442 = _slang_select(_S1441, 1U,0U);
        uint _S1443 = insertBits_0(_S1440, _S1442, 22U, 1U);
        (&here_0)->path = _S1443;
        uint _S1444 = (&here_0)->path;
        uint _S1445 = _slang_select(_S1407, 1U,0U);
        uint _S1446 = insertBits_0(_S1444, _S1445, 23U, 1U);
        (&here_0)->path = _S1446;
        float _S1447 = (&prev_0)->pdf * geometry_density_2;
        (&here_0)->jac = _S1447;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1448;
        if(replay_2)
        {
            _S1448 = _S1222 == 1U;
        }
        else
        {
            _S1448 = false;
        }
        bool _S1449;
        if(_S1448)
        {
            _S1449 = b_9 == _S1221;
        }
        else
        {
            _S1449 = false;
        }
        bool _S1450 = b_9 == _S1233;
        bool _S1451;
        if(_S1450)
        {
            bool _S1452 = !scatter_2;
            if(_S1452)
            {
                _S1451 = true;
            }
            else
            {
                bool _S1453 = _S1222 != 1U;
                if(_S1453)
                {
                    _S1451 = _S1222 != 3U;
                }
                else
                {
                    _S1451 = false;
                }
            }
        }
        else
        {
            _S1451 = false;
        }
        bool _S1454;
        if(_S1451)
        {
            _S1454 = _S1222 == 2U;
        }
        else
        {
            _S1454 = false;
        }
        bool _S1455;
        if(_S1454)
        {
            _S1455 = !_S1391;
        }
        else
        {
            _S1455 = false;
        }
        bool _S1456;
        if(_S1455)
        {
            _S1456 = _S1223 != 4U;
        }
        else
        {
            _S1456 = false;
        }
        bool _S1457 = _S1221 == _S1220;
        bool _S1458;
        if(_S1457)
        {
            _S1458 = _S1223 == 0U;
        }
        else
        {
            _S1458 = false;
        }
        bool _S1459;
        if(_S1458)
        {
            _S1459 = ((&hit_4)->instance_index) == (_S1234.instance_index);
        }
        else
        {
            _S1459 = false;
        }
        bool _S1460;
        if(_S1459)
        {
            _S1460 = ((&hit_4)->triangle_index) == (_S1234.triangle_index);
        }
        else
        {
            _S1460 = false;
        }
        bool _S1461;
        if(_S1460)
        {
            _S1461 = _S1391;
        }
        else
        {
            _S1461 = false;
        }
        bool _S1462 = _slang_select(_S1449, _S1461,_S1456);
        bool _S1463;
        if(nee_0)
        {
            _S1463 = _slang_select(replay_2, _S1462,scatter_2);
        }
        else
        {
            _S1463 = false;
        }
        TreeSample _S1464 = TreeSample_x24init_0(_S1217, _S1217, 0.0f, 0U);
        uint2  _S1465 = make_uint2 (0U);
        float2  _S1466 = make_float2 (0.0f);
        FKHit _S1467 = Hit_x24init_0(_S1466, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1468 = _S1467;
        ShadowContext _S1469 = ShadowContext_x24init_0(_S1217, _S1217, _S1465, _S1217, 0U, 0U, false, 0.0f, 0.0f, &_S1468, false);
        bool _S1470;
        if(nee_0)
        {
            _S1470 = _S1424;
        }
        else
        {
            _S1470 = false;
        }
        ShadowContext context_5;
        if(_S1470)
        {
            uint _S1471 = arrivalLobe_0(b_9, (&prev_0)->lobe);
            FKMedium _S1472 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1473 = surface_12;
            FKHit _S1474 = hit_4;
            FKMedium _S1475 = _S1472;
            ShadowContext _S1476 = shadowContext_0(&_S1473, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_9, _S1471, (&hit_4)->distance, width_3, &_S1474, _S1414, &_S1475);
            context_5 = _S1476;
        }
        else
        {
            context_5 = _S1469;
        }
        float3  throughput_7;
        float3  lit_0;
        if(_S1463)
        {
            float3  _S1477 = (&ray_2)->origin;
            if(_S1414)
            {
                throughput_7 = _S1217;
            }
            else
            {
                throughput_7 = _S1393.smooth_n;
            }
            FKSurface _S1478 = surface_12;
            uint _S1479 = stream(_S1245, b_9 + 64U);
            ShadowContext _S1480 = context_5;
            TreeSample _S1481 = sampleLightTree_0(_S1477, throughput_7, surface_12.geometry_n, surface_12.geometry_offset, _S1419, _S1479, &_S1480);
            bool _S1482 = any_1((_S1481.radiance) != _S1217);
            if(_S1482)
            {
                if(_S1414)
                {
                    uint _S1483 = (fcptMaxBounces());
                    bool _S1484 = b_9 < _S1483;
                    FKSurface _S1485 = surface_12;
                    TreeSample _S1486 = _S1481;
                    float3  _S1487 = hairLight_0(&_S1485, (&ray_2)->unit_direction, &_S1486, _S1484);
                    lit_0 = _S1487;
                }
                else
                {
                    float _S1488 = _S1409.x;
                    float _S1489 = _S1409.y;
                    uint _S1490 = (fcptMaxBounces());
                    bool _S1491 = b_9 < _S1490;
                    TreeSample _S1492 = _S1481;
                    BSDFMaterial _S1493 = _S1392.material;
                    float3  _S1494 = lightBSDF_0((&ray_2)->unit_direction, &_S1492, _S1393.smooth_n, _S1478.geometry_n, &_S1493, _S1488, _S1489, _S1491, surface_12.random_state);
                    lit_0 = _S1494;
                }
            }
            else
            {
                lit_0 = _S1217;
            }
            light_3 = _S1481;
        }
        else
        {
            light_3 = _S1464;
            lit_0 = _S1217;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1495;
        bool _S1496;
        float density_4;
        if(_S1449)
        {
            bool _S1497 = !_S1391;
            if(_S1497)
            {
                return _S1218;
            }
            uint _S1498 = extractBits_0(_S1219, 23U, 1U);
            bool _S1499 = _S1407 != (_S1498 == 1U);
            if(_S1499)
            {
                return _S1218;
            }
            float3  throughput_8 = throughput_6 * make_float3 (geometry_density_2);
            float density_5 = density_2 * geometry_density_2;
            if(_S1457)
            {
                viewed_1 = _S1223 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                return Shift_x24init_0(throughput_8 * emission_1 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1457)
            {
                refracted_4 = _S1223 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S1500 = !nee_0;
                if(_S1500)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1501 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1501 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1218;
                }
                return Shift_x24init_0(throughput_8 * lit_0 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1457)
            {
                wrong_side_0 = _S1223 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1502 = !nee_0;
                if(_S1502)
                {
                    return _S1218;
                }
                float _S1503 = environmentPdf_0(r_8->dir);
                float3  _S1504 = skyBSDF((&ray_2)->unit_direction, r_8->dir, surface_12, _S1409, is_inside_7, _S1503, surface_12.random_state);
                return Shift_x24init_0(throughput_8 * _S1504 * r_8->radiance / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            uint _S1505 = extractBits_0(_S1219, 21U, 1U);
            bool _S1506 = nee_0 != (_S1505 == 1U);
            if(_S1506)
            {
                return _S1218;
            }
            throughput_7 = throughput_8;
            density_4 = density_5;
        }
        else
        {
            if(replay_2)
            {
                viewed_1 = _S1450;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1507 = !scatter_2;
                if(_S1507)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1508 = _S1222 != 1U;
                    if(_S1508)
                    {
                        refracted_4 = _S1222 != 3U;
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
                bool _S1509 = _S1222 == 2U;
                if(_S1509)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1391;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1223 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1414)
                    {
                        return _S1218;
                    }
                    uint _S1510 = stream(_S1245, b_9 + 448U);
                    FKRay _S1511 = ray_2;
                    FKSurface _S1512 = surface_12;
                    ShadowContext _S1513 = context_5;
                    SkySample _S1514 = sampleSky_0(&_S1511, &_S1512, _S1409, is_inside_7, _S1510, surface_12.random_state, &_S1513);
                    return Shift_x24init_0(throughput_6 * _S1514.color, 1.0f);
                }
                if(_S1509)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1391;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1515 = rgb_to_greyscale(light_3.radiance);
                    bool _S1516 = !(_S1515 > 0.0f);
                    if(_S1516)
                    {
                        return _S1218;
                    }
                    return Shift_x24init_0(throughput_6 * lit_0, 1.0f);
                }
                if(_S1232)
                {
                    passes_0 = _S1223 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1359;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_6 * emission_1, 1.0f);
                }
                if(_S1232)
                {
                    passes_0 = _S1223 == 1U;
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
                    passes_0 = !_S1391;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_6 * emission_1, 1.0f);
                }
                return _S1218;
            }
            else
            {
                if(_S1423)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1517 = b_9 > 0U;
                    if(_S1517)
                    {
                        Reservoir candidate_5 = chain_0;
                        if(_S1437)
                        {
                            float3  _S1518 = safeDivide(throughput_6 * emission_1, chain_throughput_0);
                            (&candidate_5)->radiance = _S1518;
                        }
                        else
                        {
                            if(_S1391)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1519 = throughput_6 * emission_1;
                        Reservoir _S1520 = withEnd(candidate_5, 1U, b_9, _S1519);
                        offer(sel_7, _S1520, _S1519 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1521 = throughput_6 * emission_1;
                        float3  _S1522 = sel_7->glow + _S1521;
                        sel_7->glow = _S1522;
                    }
                    if(nee_0)
                    {
                        float3  _S1523 = throughput_6 * lit_0;
                        Reservoir candidate_6 = chain_0;
                        if(_S1437)
                        {
                            float3  _S1524 = safeDivide(_S1523, chain_throughput_0);
                            (&candidate_6)->radiance = _S1524;
                        }
                        else
                        {
                            if(_S1391)
                            {
                                candidate_6 = here_0;
                                uint _S1525 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1525;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1526 = insertBits_0(0U, b_9 + 1U, 5U, 5U);
                                uint _S1527 = insertBits_0(_S1526, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1527;
                            }
                        }
                        Reservoir _S1528 = withEnd(candidate_6, 0U, b_9, _S1523);
                        offer(sel_7, _S1528, _S1523 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1414)
                        {
                            _S1495 = false;
                        }
                        else
                        {
                            bool _S1529 = environmentMapped_0();
                            _S1495 = _S1529;
                        }
                    }
                    else
                    {
                        _S1495 = false;
                    }
                    if(_S1495)
                    {
                        uint _S1530 = (fcptMaxBounces());
                        _S1496 = b_9 < _S1530;
                    }
                    else
                    {
                        _S1496 = false;
                    }
                    if(_S1496)
                    {
                        uint _S1531 = stream(_S1245, b_9 + 448U);
                        FKRay _S1532 = ray_2;
                        FKSurface _S1533 = surface_12;
                        ShadowContext _S1534 = context_5;
                        SkySample _S1535 = sampleSky_0(&_S1532, &_S1533, _S1409, is_inside_7, _S1531, surface_12.random_state, &_S1534);
                        float3  _S1536 = throughput_6 * _S1535.color;
                        Reservoir candidate_7 = chain_0;
                        if(_S1437)
                        {
                            float3  _S1537 = safeDivide(_S1536, chain_throughput_0);
                            (&candidate_7)->radiance = _S1537;
                        }
                        else
                        {
                            if(_S1391)
                            {
                                candidate_7 = here_0;
                                uint _S1538 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1538;
                                (&candidate_7)->dir = _S1535.dir;
                                (&candidate_7)->radiance = _S1535.radiance;
                            }
                            else
                            {
                                uint _S1539 = insertBits_0(0U, b_9 + 1U, 5U, 5U);
                                uint _S1540 = insertBits_0(_S1539, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1540;
                            }
                        }
                        Reservoir _S1541 = withEnd(candidate_7, 4U, b_9, _S1536);
                        offer(sel_7, _S1541, _S1536 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                }
            }
            throughput_7 = throughput_6;
            density_4 = density_2;
        }
        bool _S1542;
        bool _S1543;
        bool _S1544;
        bool straight_0;
        bool _S1545;
        bool _S1546;
        bool _S1547;
        bool _S1548;
        bool _S1549;
        bool _S1550;
        bool _S1551;
        bool _S1552;
        bool _S1553;
        bool _S1554;
        bool _S1555;
        bool _S1556;
        float density_6;
        float sky_pdf_2;
        float spread_5;
        uint b_12;
        float3  throughput_9;
        float3  throughput_10;
        float3  throughput_11;
        if(scatter_2)
        {
            if(replay_2)
            {
                viewed_1 = _S1450;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1557 = extractBits_0(_S1219, 15U, 3U);
            uint _S1558 = extractBits_0(_S1219, 18U, 3U);
            uint _S1559 = _slang_select(_S1449, _S1558,_S1557);
            float3  _S1560 = r_8->dir;
            bool refracted_5 = _S1559 == 1U;
            SampleBSDF _S1561 = SampleBSDF_x24init_0(_S1217, _S1217, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1561;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1562 = extractBits_0(_S1219, 22U, 1U);
                bool _S1563 = is_inside_7 != (_S1562 == 1U);
                if(_S1563)
                {
                    return _S1218;
                }
                bool _S1564 = _S1222 == 1U;
                if(_S1564)
                {
                    float3  _S1565 = (fcptHitPosition((_S1234)));
                    throughput_9 = _S1565;
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
                    BSDFMaterial _S1566 = _S1392.material;
                    bool _S1567 = isTranslucent_0(&_S1566);
                    if(_S1567)
                    {
                        refracted_4 = _S1559 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1568 = throughput_9 - (&ray_2)->origin;
                        float3  _S1569 = _slang_select(_S1564, _S1568,_S1560);
                        wrong_side_0 = (dot_0(_S1393.smooth_n, _S1569) * _S1394) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1564)
                {
                    float3  _S1570 = (&ray_2)->origin;
                    FKSurface _S1571 = surface_12;
                    float3  _S1572 = - _S1393.smooth_n;
                    bool _S1573 = is_inside_7 != refracted_4;
                    float3  _S1574 = _slang_select(_S1573, _S1572,_S1393.smooth_n);
                    float3  _S1575 = throughput_9 - (_S1570 + make_float3 (_S1571.geometry_offset) * _S1574);
                    float3  _S1576 = ((((_S1575)) * make_float3(rnorm3df(((_S1575)).x, ((_S1575)).y, ((_S1575)).z))));
                    reconnection_1 = _S1576;
                }
                else
                {
                    reconnection_1 = _S1560;
                }
                if(_S1414)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1577 = wrongSide_0(is_inside_7, refracted_4, reconnection_1, surface_12.geometry_n);
                    wrong_side_0 = _S1577;
                }
                if(wrong_side_0)
                {
                    return _S1218;
                }
                float3  _S1578 = throughput_9;
                throughput_9 = reconnection_1;
                b_12 = _S1559;
                wrong_side_0 = false;
                reconnection_1 = _S1578;
            }
            else
            {
                bool _S1579 = !_S1449;
                if(_S1579)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1580;
                    if(_S1414)
                    {
                        SampleBSDF _S1581 = (fcptSampleHair((surface_12.hair), (_S1392.material.albedo), (_S1392.material.specular_tint), ((&ray_2)->unit_direction), (surface_12.random_state)));
                        _S1580 = _S1581;
                    }
                    else
                    {
                        SampleBSDF _S1582 = sampleBSDF((&ray_2)->unit_direction, _S1393.smooth_n, _S1392.material, _S1409.x, _S1409.y, surface_12.random_state, _S1466);
                        _S1580 = _S1582;
                    }
                    bsdf_sampled_0 = _S1580;
                    if(_S1414)
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
                            return _S1218;
                        }
                        break;
                    }
                    if(_S1414)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1583 = wrongSide_0(is_inside_7, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_12.geometry_n);
                        wrong_side_0 = _S1583;
                    }
                    if(wrong_side_0)
                    {
                        _S1495 = (_S1392.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1495 = false;
                    }
                    if(_S1495)
                    {
                        SampleBSDF _S1584 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S1392.material, _S1409.x, _S1409.y, (&bsdf_sampled_0)->random_state, _S1466);
                        (&bsdf_sampled_0)->unit_direction = _S1584.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1584.refracted;
                        (&bsdf_sampled_0)->throughput = _S1584.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1585 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n)) * surface_12.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1585;
                        }
                    }
                    uint _S1586 = (&bsdf_sampled_0)->lobe;
                    float3  _S1587 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1588 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1589 = (&bsdf_sampled_0)->pdf;
                    float _S1590 = _slang_select(wrong_side_0, 0.0f,_S1589);
                    (&lobe_5)->pdf = _S1590;
                    throughput_9 = _S1587;
                    b_12 = _S1586;
                    refracted_4 = _S1588;
                }
                else
                {
                    throughput_9 = _S1560;
                    b_12 = _S1559;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1495 = true;
            }
            else
            {
                _S1495 = _S1449;
            }
            float3  chain_throughput_1;
            if(_S1495)
            {
                if(_S1414)
                {
                    SampleBSDF _S1591 = (fcptConnectHair((surface_12.hair), (_S1392.material.albedo), (_S1392.material.specular_tint), ((&ray_2)->unit_direction), (throughput_9)));
                    lobe_5 = _S1591;
                }
                else
                {
                    float3  _S1592 = (&ray_2)->unit_direction;
                    float3  _S1593 = negate_0(_S1592);
                    float _S1594 = sign_0(_S1394);
                    float3  _S1595 = _S1393.smooth_n * make_float3 (_S1594);
                    float _S1596 = dot_0(_S1595, throughput_9);
                    float _S1597 = _S1392.material.roughness;
                    float _S1598 = _S1597 * _S1597;
                    AnisotropicFrame _S1599 = anisotropicFrame(_S1392.material, _S1595);
                    float3  _S1600 = reflectedHalf(_S1592, throughput_9);
                    bool _S1601 = b_12 == 1U;
                    if(_S1601)
                    {
                        float3  _S1602 = refractedHalf(_S1592, throughput_9, _S1393.smooth_n, _S1409.x, _S1409.y);
                        throughput_10 = _S1602;
                    }
                    else
                    {
                        throughput_10 = _S1600;
                    }
                    bool _S1603 = b_12 == 0U;
                    if(_S1603)
                    {
                        _S1496 = true;
                    }
                    else
                    {
                        _S1496 = b_12 == 6U;
                    }
                    if(_S1496)
                    {
                        float3  _S1604 = sampledHalf(_S1593, _S1595, _S1598, _S1599, surface_12.random_state);
                        throughput_11 = _S1604;
                    }
                    else
                    {
                        throughput_11 = throughput_10;
                    }
                    float _S1605 = _S1409.x;
                    float _S1606 = _S1409.y;
                    Weights _S1607 = lobeWeights(_S1592, _S1593, _S1595, throughput_11, _S1599, _S1392.material, _S1605, _S1606);
                    float _S1608 = (F32_abs((_S1394)));
                    float _S1609 = vndfPDF(_S1593, throughput_11, _S1595, _S1608, _S1598, _S1599, _S1607.v_dot_h);
                    switch(b_12)
                    {
                    case 0U:
                        {
                            float _S1610 = diffusePDF(_S1596, _S1608, _S1392.material, _S1607);
                            float3  _S1611 = diffuseBSDF(throughput_9, _S1595, _S1392.material, _S1607);
                            density_6 = _S1610;
                            chain_throughput_1 = _S1611;
                            break;
                        }
                    case 1U:
                        {
                            float _S1612 = refractPDF(dot_0(throughput_9, throughput_11), _S1609, _S1607, _S1605, _S1606);
                            float3  _S1613 = refractBSDF(throughput_9, _S1595, _S1598, _S1599, _S1392.material, _S1607);
                            density_6 = _S1612;
                            chain_throughput_1 = _S1613;
                            break;
                        }
                    case 4U:
                        {
                            float _S1614 = sheenVelvetPDF(_S1596, _S1608, _S1607);
                            float3  _S1615 = sheenVelvetBSDF(throughput_9, _S1593, _S1595, _S1392.material, _S1607);
                            density_6 = _S1614;
                            chain_throughput_1 = _S1615;
                            break;
                        }
                    case 6U:
                        {
                            ToonShape _S1616 = toonShape(_S1593, _S1595, _S1392.material);
                            float _S1617 = toonPDF(_S1596, dot_0(throughput_9, _S1616.axis), _S1616, _S1607);
                            float3  _S1618 = toonBSDF(throughput_9, _S1595, _S1616, _S1607);
                            density_6 = _S1617;
                            chain_throughput_1 = _S1618;
                            break;
                        }
                    default:
                        {
                            float _S1619 = reflectPDF(_S1609, _S1607);
                            float3  _S1620 = reflectBSDF(throughput_9, _S1595, _S1598, _S1599, _S1607);
                            density_6 = _S1619;
                            chain_throughput_1 = _S1620;
                            break;
                        }
                    }
                    bool _S1621 = density_6 > 0.0f;
                    if(_S1621)
                    {
                        SampleBSDF _S1622 = SampleBSDF_x24init_0(throughput_9, chain_throughput_1, surface_12.random_state, _S1601, b_12, density_6);
                        lobe_5 = _S1622;
                    }
                }
            }
            bool _S1623 = b_12 == 0U;
            if(_S1623)
            {
                _S1496 = true;
            }
            else
            {
                _S1496 = b_12 == 4U;
            }
            if(_S1496)
            {
                _S1542 = true;
            }
            else
            {
                _S1542 = b_12 == 6U;
            }
            if(_S1414)
            {
                _S1543 = false;
            }
            else
            {
                bool _S1624 = !_S1542;
                if(_S1624)
                {
                    bool _S1625 = (_S1392.material.roughness) == 0.0f;
                    if(_S1625)
                    {
                        _S1543 = true;
                    }
                    else
                    {
                        bool _S1626 = b_12 == 1U;
                        if(_S1626)
                        {
                            _S1543 = (_S1409.x) == (_S1409.y);
                        }
                        else
                        {
                            _S1543 = false;
                        }
                    }
                }
                else
                {
                    _S1543 = false;
                }
            }
            bool _S1627 = !_S1414;
            if(_S1627)
            {
                _S1544 = b_12 == 1U;
            }
            else
            {
                _S1544 = false;
            }
            if(_S1544)
            {
                straight_0 = (_S1392.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1545 = _S1627;
            }
            else
            {
                _S1545 = false;
            }
            if(_S1545)
            {
                _S1546 = b_12 == 1U;
            }
            else
            {
                _S1546 = false;
            }
            if(_S1546)
            {
                _S1547 = (_S1409.x) == (_S1409.y);
            }
            else
            {
                _S1547 = false;
            }
            BSDFMaterial _S1628 = _S1392.material;
            bool _S1629 = isTranslucent_0(&_S1628);
            if(_S1629)
            {
                _S1548 = _S1623;
            }
            else
            {
                _S1548 = false;
            }
            if(_S1548)
            {
                _S1549 = (dot_0(throughput_9, surface_12.geometry_n)) < 0.0f;
            }
            else
            {
                _S1549 = false;
            }
            if(nee_0)
            {
                _S1550 = !_S1543;
            }
            else
            {
                _S1550 = false;
            }
            if(_S1550)
            {
                _S1551 = !wrong_side_0;
            }
            else
            {
                _S1551 = false;
            }
            if(_S1551)
            {
                float _S1630 = (&lobe_5)->pdf;
                float3  _S1631 = (&ray_2)->origin;
                float3  _S1632 = _slang_select(_S1419, _S1217,_S1393.smooth_n);
                float3  _S1633 = (&ray_2)->origin;
                FKSurface _S1634 = surface_12;
                float3  _S1635 = - _S1393.smooth_n;
                float3  _S1636 = _slang_select(_S1549, _S1635,_S1393.smooth_n);
                NEEVertex _S1637 = NEEVertex_x24init_0(false, _S1630, _S1631, _S1632, _S1633 + make_float3 (_S1634.geometry_offset) * _S1636);
                nee_vertex_0 = _S1637;
            }
            else
            {
                if(_S1414)
                {
                    _S1552 = true;
                }
                else
                {
                    bool _S1638 = b_12 != 1U;
                    if(_S1638)
                    {
                        _S1552 = true;
                    }
                    else
                    {
                        _S1552 = (_S1409.x) != (_S1409.y);
                    }
                }
                if(_S1552)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1639 = withinInverseFootprint((&lobe_5)->pdf, _S1542, (&prev_0)->cos, (&hit_4)->distance, threshold_2);
            bool _S1640 = roughLobe((&lobe_5)->pdf, _S1542, _S1392.material.roughness);
            if(_S1449)
            {
                bool _S1641 = !_S1639;
                if(_S1641)
                {
                    return _S1218;
                }
                bool _S1642 = _S1223 != 1U;
                if(_S1642)
                {
                    _S1552 = _S1223 != 2U;
                }
                else
                {
                    _S1552 = false;
                }
                if(_S1552)
                {
                    float _S1643 = (&lobe_5)->pdf;
                    float _S1644 = _slang_select(nee_0, _S1643,0.0f);
                    float _S1645 = escapeWeight_0(_S1644, _S1560);
                    if(_S1457)
                    {
                        passes_0 = _S1229;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1646 = _slang_select(passes_0, _S1645,1.0f);
                    return Shift_x24init_0(throughput_7 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_8->radiance * make_float3 (_S1646) / make_float3 (r_8->jac), density_4 * (&lobe_5)->pdf / r_8->jac);
                }
                float3  _S1647 = throughput_7 * make_float3 ((&lobe_5)->pdf);
                float _S1648 = density_4 * (&lobe_5)->pdf;
                throughput_10 = _S1647;
                density_6 = _S1648;
            }
            else
            {
                throughput_10 = throughput_7;
                density_6 = density_4;
            }
            uint _S1649 = (fcptLayers((hit_4)));
            bool _S1650 = b_12 == 1U;
            bool _S1651 = passesLayer_0(_S1649, _S1650, passes_0);
            if(viewed_1)
            {
                _S1552 = _S1651;
            }
            else
            {
                _S1552 = false;
            }
            if(_S1552)
            {
                return _S1218;
            }
            if(replay_2)
            {
                _S1553 = b_9 <= _S1233;
            }
            else
            {
                _S1553 = false;
            }
            if(_S1553)
            {
                _S1554 = _S1391;
            }
            else
            {
                _S1554 = false;
            }
            if(_S1554)
            {
                _S1555 = _S1639;
            }
            else
            {
                _S1555 = false;
            }
            if(_S1555)
            {
                _S1556 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1556 = !_S1640;
                }
                else
                {
                    _S1556 = false;
                }
            }
            if(_S1556)
            {
                return _S1218;
            }
            if(viewed_1)
            {
                float3  _S1652 = throughput_10 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1653 = (&lobe_5)->pdf;
                throughput_11 = _S1652;
                sky_pdf_2 = _S1653;
            }
            else
            {
                float3  _S1654 = throughput_10 * max_0((&lobe_5)->throughput, _S1217);
                throughput_11 = _S1654;
                sky_pdf_2 = density_6;
            }
            bool _S1655;
            if(_S1423)
            {
                _S1655 = !_S1437;
            }
            else
            {
                _S1655 = false;
            }
            bool _S1656;
            if(_S1655)
            {
                _S1656 = _S1391;
            }
            else
            {
                _S1656 = false;
            }
            bool _S1657;
            if(_S1656)
            {
                _S1657 = _S1639;
            }
            else
            {
                _S1657 = false;
            }
            if(_S1657)
            {
                chain_0 = here_0;
                uint _S1658 = insertBits_0((&chain_0)->path, b_12, 18U, 3U);
                uint _S1659 = _slang_select(nee_0, 1U,0U);
                uint _S1660 = insertBits_0(_S1658, _S1659, 21U, 1U);
                (&chain_0)->path = _S1660;
                float _S1661 = (&chain_0)->jac * (&lobe_5)->pdf;
                (&chain_0)->jac = _S1661;
                (&chain_0)->dir = throughput_9;
                chain_throughput_1 = throughput_11;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1662 = surface_12;
            Vertex _S1663 = Vertex_x24init_0(_S1640, b_12, (&lobe_5)->pdf, (F32_abs((dot_0(surface_12.geometry_n, throughput_9)))), is_inside_7);
            prev_0 = _S1663;
            float _S1664 = (&lobe_5)->pdf;
            bool _S1665;
            if(_S1650)
            {
                _S1665 = (_S1409.x) == (_S1409.y);
            }
            else
            {
                _S1665 = false;
            }
            float sky_pdf_3 = _slang_select(_S1665, sky_pdf_0,_S1664);
            float _S1666 = _slang_select(_S1414, 0.0f,sky_pdf_3);
            float _S1667 = widened_0(spread_2, (&lobe_5)->pdf, _S1543);
            bool _S1668;
            if(refracted_4)
            {
                _S1668 = !_S1549;
            }
            else
            {
                _S1668 = false;
            }
            bool is_inside_8;
            if(_S1668)
            {
                bool _S1669 = !is_inside_7;
                is_inside_8 = _S1669;
            }
            else
            {
                is_inside_8 = is_inside_7;
            }
            FKSurface _S1670 = surface_12;
            bool _S1671 = boundsVolume_0(&_S1670);
            bool _S1672;
            if(_S1671)
            {
                _S1672 = !_S1651;
            }
            else
            {
                _S1672 = false;
            }
            if(_S1672)
            {
                FKSurface faced_2 = surface_12;
                float3  _S1673 = - _S1662.geometry_n;
                float3  _S1674 = _slang_select(turned_1, _S1673,_S1662.geometry_n);
                (&faced_2)->geometry_n = _S1674;
                FKMedium _S1675 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1676 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1677 = faced_2;
                FKMedium _S1678 = _S1675;
                FKMedium _S1679 = _S1676;
                MediumSides _S1680 = mediumSides_0(&_S1677, &_S1678, filling_2, (&ray_2)->unit_direction, &_S1679);
                bool _S1681 = leavesInFront_0((&faced_2)->geometry_n, throughput_9, _S1662.geometry_n);
                float3  _S1682 = _slang_select(_S1681, _S1680.front.scatter,_S1680.behind.scatter);
                scatter_in_0 = _S1682;
                float3  _S1683 = _slang_select(_S1681, _S1680.front.extinction,_S1680.behind.extinction);
                extinction_in_0 = _S1683;
                float _S1684 = _slang_select(_S1681, _S1680.front.g,_S1680.behind.g);
                g_in_0 = _S1684;
                uint _S1685 = _S1680.fillings.x;
                uint _S1686 = _S1680.fillings.y;
                uint _S1687 = _slang_select(_S1681, _S1686,_S1685);
                bool _S1688 = (fcptVaryingUsed());
                uint _S1689 = _slang_select(_S1688, _S1687,4294967295U);
                filling_2 = _S1689;
            }
            (&ray_2)->unit_direction = throughput_9;
            bool _S1690 = !_S1651;
            if(_S1690)
            {
                FKSurface _S1691 = surface_12;
                float _S1692 = _slang_select(straight_0, 0.0f,_S1691.geometry_offset);
                float3  _S1693 = - _S1393.smooth_n;
                bool _S1694 = is_inside_8 != _S1549;
                float3  _S1695 = _slang_select(_S1694, _S1693,_S1393.smooth_n);
                float3  _S1696 = (&ray_2)->origin + make_float3 (_S1692) * _S1695;
                (&ray_2)->origin = _S1696;
            }
            throughput_10 = throughput_11;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1651;
            viewed_1 = _S1547;
            sky_pdf_2 = _S1666;
            spread_5 = _S1667;
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
        if(_S1423)
        {
            if(_S1359)
            {
                float3  _S1697 = throughput_10 * emission_1;
                Reservoir candidate_8 = chain_0;
                uint _S1698 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1699 = _S1698 == 1U;
                if(_S1699)
                {
                    float3  _S1700 = safeDivide(_S1697, chain_throughput_0);
                    (&candidate_8)->radiance = _S1700;
                }
                Reservoir _S1701 = withEnd(candidate_8, 2U, b_9, _S1697);
                offer(sel_7, _S1701, _S1697 * make_float3 (scale_3) / make_float3 (density_6));
            }
            if(_S1359)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1702 = survivalProbability(abs_0(throughput_10), density_6);
                density_7 = _S1702;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1703 = stream(_S1245, b_9 + 128U);
            Random _S1704 = pcg(_S1703);
            bool _S1705 = density_7 < (_S1704.value);
            if(_S1705)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1706 = (fcptMaxBounces());
                wrong_side_0 = b_9 >= _S1706;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1707 = density_6 * density_7;
            density_7 = _S1707;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1708 = layer_0 ^ 1U;
        uint _S1709 = _slang_select(passes_0, _S1708,0U);
        if(passes_0)
        {
            (&prev_0)->rough = false;
            (&hit_4)->distance = 0.0f;
            b_12 = b_9;
            viewed_0 = viewed_1;
            throughput_2 = throughput_10;
            density_2 = density_7;
            sky_pdf_0 = sky_pdf_2;
            spread_2 = spread_5;
            uint _S1710 = b_12 + 1U;
            b_9 = _S1710;
            layer_0 = _S1709;
            continue;
        }
        FKRay _S1711 = ray_2;
        float _S1712 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_2)
        {
            refracted_4 = _S1450;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S1222 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1713 = _slang_select(wrong_side_0, _S1712,4.294967296e+09f);
        bool _S1714 = !_S1414;
        if(straight_0)
        {
            _S1495 = true;
        }
        else
        {
            _S1495 = _S1414;
        }
        FKHit _S1715;
        if(_S1495)
        {
            _S1715 = hit_4;
        }
        else
        {
            _S1715 = _S1467;
        }
        FKHit _S1716 = (fcptTraverseInstanceBVH((_S1711), (_S1367), (_S1713), (_S1714), (_S1715), (viewed_1)));
        hit_4 = _S1716;
        if(replay_2)
        {
            _S1496 = _S1450;
        }
        else
        {
            _S1496 = false;
        }
        if(_S1496)
        {
            _S1542 = _S1222 == 1U;
        }
        else
        {
            _S1542 = false;
        }
        if(_S1542)
        {
            _S1543 = ((&hit_4)->instance_index) == (_S1234.instance_index);
        }
        else
        {
            _S1543 = false;
        }
        if(_S1543)
        {
            _S1544 = ((&hit_4)->triangle_index) == (_S1234.triangle_index);
        }
        else
        {
            _S1544 = false;
        }
        if(_S1544)
        {
            (&hit_4)->uv = _S1234.uv;
            float _S1717 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S1717;
        }
        if(replay_2)
        {
            _S1545 = _S1450;
        }
        else
        {
            _S1545 = false;
        }
        if(_S1545)
        {
            _S1546 = _S1222 == 3U;
        }
        else
        {
            _S1546 = false;
        }
        if(_S1546)
        {
            _S1547 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1547 = false;
        }
        if(_S1547)
        {
            return _S1218;
        }
        Reservoir _S1718 = chain_0;
        uint _S1719 = filling_2;
        for(;;)
        {
            bool _S1720 = (fcptVaryingUsed());
            if(_S1720)
            {
                _S1548 = _S1719 != 4294967295U;
            }
            else
            {
                _S1548 = false;
            }
            float _S1721;
            if(_S1548)
            {
                float _S1722 = (fcptMajorant((_S1719)));
                _S1721 = _S1722;
            }
            else
            {
                _S1721 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_2)
            {
                _S1549 = _S1450;
            }
            else
            {
                _S1549 = false;
            }
            if(_S1549)
            {
                _S1550 = _S1222 == 1U;
            }
            else
            {
                _S1550 = false;
            }
            if(_S1550)
            {
                _S1551 = _S1721 > 0.0f;
            }
            else
            {
                _S1551 = false;
            }
            if(_S1551)
            {
                ended_0 = _S1218;
                sky_pdf_1 = sky_pdf_2;
                spread_3 = spread_5;
                width_4 = width_3;
                density_3 = density_7;
                throughput_11 = throughput_10;
                b_12 = b_9;
                _S1552 = true;
                break;
            }
            bool _S1723 = (&prev_0)->rough;
            if(_S1723)
            {
                _S1552 = !(_S1721 > 0.0f);
            }
            else
            {
                _S1552 = false;
            }
            (&prev_0)->rough = _S1552;
            uint _S1724 = b_9 + 320U;
            bool _S1725 = b_9 == 4294967295U;
            uint _S1726 = _slang_select(_S1725, 384U,_S1724);
            uint _S1727 = stream(_S1245, _S1726);
            uint tracking_1 = _S1727;
            weight_1 = throughput_3;
            glowed_0 = _S1217;
            b_12 = b_9;
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
                    _S1216 = int(2);
                    break;
                }
                uint _S1728 = b_12 + 320U;
                bool _S1729 = b_12 == 4294967295U;
                uint _S1730 = _slang_select(_S1729, 384U,_S1728);
                uint _S1731 = stream(_S1245, _S1730);
                Random _S1732 = pcg(_S1731);
                float _S1733 = freeFlight_0(_S1732.value, _S1721);
                if(_S1548)
                {
                    float3  _S1734 = (&ray_2)->origin;
                    float3  _S1735 = (&ray_2)->unit_direction;
                    float _S1736 = (&hit_4)->distance;
                    uint _S1737 = _slang_select(_S1729, 0U,b_12);
                    uint _S1738 = (&prev_0)->lobe;
                    uint _S1739 = _slang_select(_S1729, 3U,_S1738);
                    float _S1740 = (fcptTrackMedium((_S1719), (_S1734), (_S1735), (_S1736), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1737), (_S1739), (_S1729)));
                    spread_4 = _S1740;
                }
                else
                {
                    spread_4 = _S1733;
                }
                bool _S1741 = !(spread_4 < ((&hit_4)->distance));
                if(_S1741)
                {
                    _S1216 = int(2);
                    break;
                }
                if(_S1548)
                {
                    _S1553 = _S1423;
                }
                else
                {
                    _S1553 = false;
                }
                if(_S1553)
                {
                    float3  _S1742 = throughput_11 * glowed_0 / make_float3 (density_3);
                    float3  _S1743 = sel_7->glow + _S1742;
                    sel_7->glow = _S1743;
                }
                else
                {
                }
                glowed_0 = _S1217;
                uint b_13 = b_12 + 1U;
                float3  _S1744 = (&ray_2)->origin + make_float3 (spread_4) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1744;
                float3  _S1745 = flightWeight_0(scatter_in_0, extinction_in_0, _S1721, spread_4, true);
                float3  _S1746 = weight_1;
                float3  _S1747 = _slang_select(_S1548, _S1746,_S1745);
                float3  throughput_12 = throughput_11 * _S1747;
                uint _S1748 = stream(_S1245, b_13 + 320U);
                tracking_1 = _S1748;
                weight_1 = throughput_3;
                float width_7 = width_4 + spread_3 * spread_4;
                float _S1749 = spread_3 + 3.14159274101257324f;
                bool _S1750 = scatterSampled_0(replay_2, b_13, _S1233, _S1548);
                TreeSample light_4;
                if(_S1750)
                {
                    float3  _S1751 = (&ray_2)->origin;
                    float3  _S1752 = (&ray_2)->unit_direction;
                    float3  _S1753 = (&ray_2)->unit_direction;
                    uint _S1754 = stream(_S1245, b_13 + 64U);
                    float3  _S1755 = extinction_in_0;
                    float3  _S1756 = extinction_in_0;
                    uint2  _S1757 = make_uint2 (_S1719);
                    float3  _S1758 = (&ray_2)->unit_direction;
                    uint _S1759 = arrivalLobe_0(b_13, (&prev_0)->lobe);
                    FKHit _S1760 = _S1467;
                    ShadowContext _S1761 = ShadowContext_x24init_0(_S1755, _S1756, _S1757, _S1758, b_13, _S1759, false, spread_4, width_7, &_S1760, false);
                    ShadowContext _S1762 = _S1761;
                    TreeSample _S1763 = sampleLightTree_0(_S1751, _S1752, _S1753, 0.0f, true, _S1754, &_S1762);
                    light_4 = _S1763;
                }
                else
                {
                    light_4 = _S1464;
                }
                float _S1764 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1765 = (fcptMaxBounces());
                bool _S1766 = b_13 < _S1765;
                if(_S1766)
                {
                    _S1554 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1554 = false;
                }
                float _S1767 = _slang_select(_S1554, _S1764,0.0f);
                float3  _S1768 = throughput_12 * light_4.radiance;
                float _S1769 = powerHeuristic(light_4.density, _S1767);
                float3  _S1770 = _S1768 * make_float3 (_S1764 * _S1769);
                float3  _S1771 = _slang_select(_S1750, _S1770,_S1217);
                if(replay_2)
                {
                    _S1555 = b_13 == _S1233;
                }
                else
                {
                    _S1555 = false;
                }
                if(_S1555)
                {
                    bool _S1772 = _S1222 == 2U;
                    if(_S1772)
                    {
                        float _S1773 = resamplingTarget(_S1771);
                        _S1556 = _S1773 > 0.0f;
                    }
                    else
                    {
                        _S1556 = false;
                    }
                    if(_S1556)
                    {
                        Shift _S1774 = Shift_x24init_0(_S1771, 1.0f);
                        _S1216 = int(1);
                        ended_0 = _S1774;
                        spread_4 = _S1749;
                        width_5 = width_7;
                        throughput_9 = throughput_12;
                        b_10 = b_13;
                        break;
                    }
                    _S1216 = int(1);
                    ended_0 = _S1218;
                    spread_4 = _S1749;
                    width_5 = width_7;
                    throughput_9 = throughput_12;
                    b_10 = b_13;
                    break;
                }
                if(_S1423)
                {
                    Reservoir candidate_9 = _S1718;
                    uint _S1775 = extractBits_0(_S1718.path, 10U, 2U);
                    bool _S1776 = _S1775 == 1U;
                    if(_S1776)
                    {
                        float3  _S1777 = safeDivide(_S1771, chain_throughput_0);
                        (&candidate_9)->radiance = _S1777;
                    }
                    else
                    {
                        uint _S1778 = insertBits_0(0U, b_13 + 1U, 5U, 5U);
                        uint _S1779 = insertBits_0(_S1778, 2U, 10U, 2U);
                        (&candidate_9)->path = _S1779;
                    }
                    Reservoir _S1780 = withEnd(candidate_9, 0U, b_13, _S1771);
                    offer(sel_7, _S1780, _S1771 * make_float3 (scale_3) / make_float3 (density_3));
                    float _S1781 = survivalProbability(abs_0(throughput_12), density_3);
                    uint _S1782 = stream(_S1245, b_13 + 128U);
                    Random _S1783 = pcg(_S1782);
                    bool _S1784 = _S1781 < (_S1783.value);
                    if(_S1784)
                    {
                        _S1556 = true;
                    }
                    else
                    {
                        uint _S1785 = (fcptMaxBounces());
                        _S1556 = b_13 >= _S1785;
                    }
                    if(_S1556)
                    {
                        _S1216 = int(1);
                        ended_0 = _S1218;
                        spread_4 = _S1749;
                        width_5 = width_7;
                        throughput_9 = throughput_12;
                        b_10 = b_13;
                        break;
                    }
                    float _S1786 = density_3 * _S1781;
                    density_3 = _S1786;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1787 = stream(_S1245, b_13);
                float3  _S1788 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1787, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1788;
                NEEVertex _S1789 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1217, (&ray_2)->origin);
                nee_vertex_0 = _S1789;
                Vertex _S1790 = scatteredVertex_0(is_inside_6);
                prev_0 = _S1790;
                float _S1791 = (&prev_0)->pdf;
                FKRay _S1792 = ray_2;
                FKHit _S1793 = (fcptTraverseInstanceBVH((_S1792), (true), (4.294967296e+09f), (false), (_S1467), (false)));
                hit_4 = _S1793;
                b_12 = b_13;
                throughput_11 = throughput_12;
                spread_3 = _S1749;
                width_4 = width_7;
                sky_pdf_1 = _S1791;
            }
            if(_S1216 != int(2))
            {
                spread_3 = spread_4;
                width_4 = width_5;
                throughput_11 = throughput_9;
                b_12 = b_10;
                _S1552 = true;
                break;
            }
            ended_0 = _S1218;
            _S1552 = false;
            break;
        }
        if(_S1552)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1553 = b_12 == b_9;
        }
        else
        {
            _S1553 = false;
        }
        bool _S1794 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S1794)
        {
            bool _S1795 = !(&nee_vertex_0)->none;
            float _S1796 = _slang_select(_S1795, sky_pdf_1,0.0f);
            float _S1797 = escapeWeight_0(_S1796, (&ray_2)->unit_direction);
            float3  _S1798 = environment_0((&ray_2)->unit_direction, b_12, (&prev_0)->lobe);
            float3  _S1799 = throughput_11 * _S1798;
            if(replay_2)
            {
                bool _S1800 = b_12 == _S1233;
                if(_S1800)
                {
                    passes_0 = _S1222 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1799 * make_float3 (_S1797) / make_float3 (r_8->jac), density_3 / r_8->jac);
                }
                if(_S1232)
                {
                    passes_0 = _S1229;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_12 == _S1220;
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
                    return Shift_x24init_0(_S1799 * make_float3 (_S1797), 1.0f);
                }
                return _S1218;
            }
            Reservoir candidate_10 = chain_0;
            uint _S1801 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1802 = _S1801 == 1U;
            if(_S1802)
            {
                uint _S1803 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1804 = _S1803 == b_12;
                float _S1805 = _slang_select(_S1804, 1.0f,_S1797);
                float3  _S1806 = safeDivide(_S1799 * make_float3 (_S1805), chain_throughput_0);
                (&candidate_10)->radiance = _S1806;
            }
            else
            {
                bool _S1807 = (&prev_0)->rough;
                if(_S1807)
                {
                    uint _S1808 = insertBits_0(0U, b_12 + 1U, 5U, 5U);
                    uint _S1809 = insertBits_0(_S1808, 3U, 10U, 2U);
                    uint _S1810 = insertBits_0(_S1809, (&prev_0)->lobe, 15U, 3U);
                    bool _S1811 = (&prev_0)->inside;
                    uint _S1812 = _slang_select(_S1811, 1U,0U);
                    uint _S1813 = insertBits_0(_S1810, _S1812, 22U, 1U);
                    (&candidate_10)->path = _S1813;
                    (&candidate_10)->jac = (&prev_0)->pdf;
                    (&candidate_10)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1814 = _S1799 * make_float3 (_S1797);
            Reservoir _S1815 = withEnd(candidate_10, 3U, b_12, _S1814);
            offer(sel_7, _S1815, _S1814 * make_float3 (scale_3) / make_float3 (density_3));
            break;
        }
        float3  _S1816 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1816;
        bool _S1817 = (fcptVaryingUsed());
        if(_S1817)
        {
            _S1554 = filling_2 != 4294967295U;
        }
        else
        {
            _S1554 = false;
        }
        if(_S1554)
        {
            if(_S1423)
            {
                float3  _S1818 = throughput_11 * glowed_0 / make_float3 (density_3);
                float3  _S1819 = sel_7->glow + _S1818;
                sel_7->glow = _S1819;
            }
            float3  _S1820 = throughput_11 * weight_1;
            throughput_9 = _S1820;
        }
        else
        {
            float3  _S1821 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S1822 = throughput_11 * _S1821;
            throughput_9 = _S1822;
        }
        float _S1823 = width_4 + spread_3 * (&hit_4)->distance;
        viewed_0 = _S1553;
        width_3 = _S1823;
        throughput_2 = throughput_9;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_2 = spread_3;
        uint _S1710 = b_12 + 1U;
        b_9 = _S1710;
        layer_0 = _S1709;
    }
    return _S1218;
}

static __device__ Shift shift_0(Domain * dom_8, Reservoir * r_9)
{
    Selection _S1824 = (Selection{});
    Selection sel_8 = _S1824;
    bool _S1825 = (r_9->w) <= 0.0f;
    if(_S1825)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S1826 = walk_0(dom_8, r_9, true, 0.0f, &sel_8);
    return _S1826;
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
    Random _S1827 = pcg(state_4);
    Random _S1828 = pcg(_S1827.state);
    float _S1829 = 6.28318548202514648f * _S1827.value;
    float _S1830 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S1828.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1828.state, _S1830 * (F32_cos((_S1829))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_5, float3  value_2)
{
    RandomSphere _S1831;
    (&_S1831)->state = state_5;
    (&_S1831)->value = value_2;
    return _S1831;
}

__device__ RandomSphere random_sphere(uint state_6)
{
    Random _S1832 = normal_distribution(state_6);
    Random _S1833 = normal_distribution(_S1832.state);
    Random _S1834 = normal_distribution(_S1833.state);
    float3  _S1835 = make_float3 (_S1832.value, _S1833.value, _S1834.value);
    float3  _S1836 = ((((_S1835)) * make_float3(rnorm3df(((_S1835)).x, ((_S1835)).y, ((_S1835)).z))));
    return RandomSphere_x24init_0(_S1834.state, _S1836);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_11)
{
    float3  _S1837 = p1_0 - p0_0;
    float3  _S1838 = p2_0 - p0_0;
    float2  _S1839 = uv1_0 - uv0_0;
    float2  _S1840 = uv2_0 - uv0_0;
    float _S1841 = _S1839.x;
    float _S1842 = _S1840.y;
    float _S1843 = _S1839.y;
    float _S1844 = _S1840.x;
    float _S1845 = _S1841 * _S1842 - _S1843 * _S1844;
    float _S1846 = 1.0f / _S1845;
    float3  t_22 = (_S1837 * make_float3 (_S1842) - _S1838 * make_float3 (_S1843)) * make_float3 (_S1846);
    float3  _S1847 = (_S1838 * make_float3 (_S1841) - _S1837 * make_float3 (_S1844)) * make_float3 (_S1846);
    float3  _S1848 = t_22 - n_11 * make_float3 (dot_0(n_11, t_22));
    float3  t_23 = ((((_S1848)) * make_float3(rnorm3df(((_S1848)).x, ((_S1848)).y, ((_S1848)).z))));
    bool _S1849 = (dot_0(cross_0(n_11, t_23), _S1847)) > 0.0f;
    float3  t_24;
    if(_S1849)
    {
        float3  _S1850 = negate_0(t_23);
        t_24 = _S1850;
    }
    else
    {
        t_24 = t_23;
    }
    float3  _S1851 = cross_0(n_11, t_24);
    return makeMatrix<float, 3, 3> (t_24, _S1851, n_11);
}

__device__ float3  tangentToWorldNormalMap(float3  v_9, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_9, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_5, float3  uvw_0, float3  position_0)
{
    float3  _S1852 = t1_0 - t0_0;
    float3  _S1853 = t2_2 - t0_0;
    float3  _S1854 = t2_2 - t1_0;
    float _S1855 = (F32_min((length_0(_S1852)), ((F32_min((length_0(_S1853)), (length_0(_S1854)))))));
    float3  _S1856 = make_float3 (distance_1(position_0, t0_0), distance_1(position_0, t1_0), distance_1(position_0, t2_2));
    float3  _S1857 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1858 = dot_0(geometry_n_5, _S1857);
    float3  _S1859 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1860 = dot_0(geometry_n_5, _S1859);
    float3  _S1861 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1862 = acos_0(abs_0(make_float3 (_S1858, _S1860, dot_0(geometry_n_5, _S1861))));
    float3  _S1863 = clamp_2(tan_0(_S1862), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S1856 * _S1863, uvw_0), 0.0f, _S1855 * 0.125f);
}

__device__ float3  straightThrough(float3  dir_15, float3  n_12, BSDFMaterial material_20)
{
    float3  _S1864 = negate_0(dir_15);
    float _S1865 = sign_0(dot_0(n_12, _S1864));
    float3  _S1866 = n_12 * make_float3 (_S1865);
    AnisotropicFrame _S1867 = anisotropicFrame(material_20, _S1866);
    bool _S1868 = (_S1867.alphas.x) > 0.0f;
    if(_S1868)
    {
        float _S1869 = material_20.transmission * (1.0f - material_20.metallic);
        float3  _S1870 = negate_0(_S1866);
        float3  _S1871 = anisotropicLocal(dir_15, _S1867.tangent, _S1870);
        float _S1872 = anisotropicG1(_S1871, _S1867.alphas);
        return make_float3 (_S1869 * _S1872) * material_20.albedo;
    }
    float _S1873 = material_20.transmission * (1.0f - material_20.metallic);
    float _S1874 = material_20.roughness;
    float _S1875 = smithG1(_S1874 * _S1874, (F32_abs((dot_0(n_12, dir_15)))));
    return make_float3 (_S1873 * _S1875) * material_20.albedo;
}

__device__ float hairRow(float3  in_dir_10, float3  t_25, float3  out_dir_3, uint p_14, float w_19, float alpha_10, uint nt_0)
{
    uint _S1876 = p_14 % 4U;
    float _S1877 = w_19 * HAIR_WIDTHS_0[_S1876];
    float _S1878 = (F32_asin((clamp_1(dot_0(out_dir_3, t_25), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_10, t_25), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1876] * alpha_10;
    return ((F32_asinh((_S1878 / _S1877))) / (F32_asinh((3.14159274101257324f / _S1877))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_11, float3  t_26, float3  out_dir_4, uint np_0)
{
    float3  _S1879 = worldToTangent(out_dir_4, t_26);
    float3  _S1880 = worldToTangent(in_dir_11, t_26);
    return (F32_frac((((F32_atan2((_S1879.z), (_S1879.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1880.z), (1.17549435082228751e-38f - _S1880.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_12, float3  t_27, uint p_15, float row_0, float column_0, float w_20, float alpha_11, uint nt_1, uint np_1)
{
    float3  _S1881 = worldToTangent(in_dir_12, t_27);
    uint _S1882 = p_15 % 4U;
    float _S1883 = w_20 * HAIR_WIDTHS_0[_S1882];
    float _S1884 = (F32_asin((clamp_1(dot_0(in_dir_12, t_27), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1882] * alpha_11 + _S1883 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1883))))));
    float _S1885 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1881.z), (1.17549435082228751e-38f - _S1881.x)));
    float _S1886 = (F32_cos((_S1884)));
    float3  _S1887 = tangentToWorld(make_float3 (_S1886 * (F32_cos((_S1885))), (F32_sin((_S1884))), _S1886 * (F32_sin((_S1885)))), t_27);
    return _S1887;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_13, BSDFMaterial material_21, float coverage_1)
{
    float3  _S1888;
    if((material_21.ior) == 1.0f)
    {
        float3  _S1889 = straightThrough(toward_1, n_13, material_21);
        _S1888 = _S1889;
    }
    else
    {
        _S1888 = make_float3 (0.0f);
    }
    return _S1888 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_9, Reservoir r_10, bool replay_3, float scale_4, Selection * sel_9)
{
    Domain _S1890 = dom_9;
    Reservoir _S1891 = r_10;
    Shift _S1892 = walk_0(&_S1890, &_S1891, replay_3, scale_4, sel_9);
    return _S1892;
}

__device__ Shift shift_hook(Domain dom_10, Reservoir r_11)
{
    Domain _S1893 = dom_10;
    Reservoir _S1894 = r_11;
    Shift _S1895 = shift_0(&_S1893, &_S1894);
    return _S1895;
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
