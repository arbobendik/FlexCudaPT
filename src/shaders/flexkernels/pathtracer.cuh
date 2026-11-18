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
        uint _S288 = _S286.y;
        FKLight _S289 = (fcptLight((_S288)));
        FKLight _S290 = (fcptLight((_S288)));
        float _S291 = sphereDensity(_S289.position, _S290.variance, start_5);
        return probability_1 * _S291;
    }
    uint _S292 = _S286.y;
    uint _S293 = (fcptTriangleOffset((_S292)));
    Matrix<float, 3, 3>  _S294 = (fcptWorldTriangle((_S292), (_S293 + _S286.z)));
    float _S295 = solidAngle(probability_1, cross_0(_S294.rows[int(1)] - _S294.rows[int(0)], _S294.rows[int(2)] - _S294.rows[int(0)]), light_point_0 - start_5);
    return _S295;
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

static __device__ Random Random_x24init_0(uint state_0, float value_0)
{
    Random _S296;
    (&_S296)->state = state_0;
    (&_S296)->value = value_0;
    return _S296;
}

__device__ Random pcg(uint state_1)
{
    uint _S297 = hash(state_1);
    float value_1 = float(_S297 >> int(8)) * 5.9604644775390625e-08f;
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
    1.03603994846343994f, 1.04969000816345215f, 1.02470004558563232f, 1.01461005210876465f, 1.00961005687713623f, 1.00680005550384521f, 1.0050499439239502f, 1.00390005111694336f, 1.00312995910644531f, 1.00258004665374756f, 1.00213003158569336f, 1.0017399787902832f, 1.00138998031616211f, 1.00112998485565186f, 1.00097000598907471f, 1.00092995166778564f, 1.00098001956939697f, 1.00108003616333008f, 1.0011899471282959f, 1.00127995014190674f, 1.0013200044631958f, 1.00134003162384033f, 1.00133001804351807f, 1.00130999088287354f, 0.90734100341796875f, 0.98275798559188843f, 0.98386698961257935f, 0.98714500665664673f, 0.98988902568817139f, 0.99194902181625366f, 0.99348098039627075f, 0.99463999271392822f, 0.99551397562026978f, 0.99620199203491211f, 0.99678301811218262f, 0.99725902080535889f, 0.99762099981307983f, 0.99788099527359009f, 0.99806898832321167f, 0.99822998046875f, 0.9984009861946106f, 0.99860197305679321f, 0.99882900714874268f, 0.99905097484588623f, 0.99924802780151367f, 0.99941599369049072f, 0.99955397844314575f, 0.99966597557067871f, 0.47049999237060547f, 0.72047901153564453f, 0.82541298866271973f, 0.88024801015853882f, 0.91317099332809448f, 0.93422400951385498f, 0.94845300912857056f, 0.9585450291633606f, 0.96597200632095337f, 0.97161900997161865f, 0.97599798440933228f, 0.97946298122406006f, 0.98225301504135132f, 0.98453700542449951f, 0.98643702268600464f, 0.98803901672363281f, 0.98940402269363403f, 0.99057799577713013f, 0.99159497022628784f, 0.9924740195274353f, 0.99323201179504395f, 0.99394601583480835f, 0.9946179986000061f, 0.99514299631118774f, 0.10339099913835526f, 0.37652701139450073f, 0.58990597724914551f, 0.7168310284614563f, 0.79374098777770996f, 0.8438420295715332f, 0.87787497043609619f, 0.90189200639724731f, 0.919514000415802f, 0.93284100294113159f, 0.94317400455474854f, 0.95135498046875f, 0.95794999599456787f, 0.9633520245552063f, 0.96783697605133057f, 0.97160798311233521f, 0.97481298446655273f, 0.97755998373031616f, 0.97992998361587524f, 0.98198497295379639f, 0.98377299308776855f, 0.98532998561859131f, 0.98668897151947021f, 0.98788100481033325f, 0.00549574987962842f, 0.12130799889564514f, 0.33038300275802612f, 0.50957399606704712f, 0.63582301139831543f, 0.72130399942398071f, 0.78063100576400757f, 0.82337701320648193f, 0.85500001907348633f, 0.87895798683166504f, 0.89755398035049438f, 0.91228801012039185f, 0.92417001724243164f, 0.93390399217605591f, 0.94199001789093018f, 0.94878798723220825f, 0.95456397533416748f, 0.95951497554779053f, 0.96378600597381592f, 0.96749001741409302f, 0.97071200609207153f, 0.97352099418640137f, 0.97597402334213257f, 0.97811698913574219f, 0.00006616840255447f, 0.01978570036590099f, 0.13480900228023529f, 0.30441498756408691f, 0.4568449854850769f, 0.57461702823638916f, 0.66137099266052246f, 0.72547799348831177f, 0.77361601591110229f, 0.81061500310897827f, 0.83951497077941895f, 0.86248302459716797f, 0.88104599714279175f, 0.89627498388290405f, 0.90893799066543579f, 0.91959297657012939f, 0.92865198850631714f, 0.93641901016235352f, 0.94312202930450439f, 0.94893598556518555f, 0.95399397611618042f, 0.95840400457382202f, 0.96225601434707642f, 0.96562099456787109f, 6.08604011631541653e-08f, 0.00167625001631677f, 0.03686590120196342f, 0.14405199885368347f, 0.28643798828125f, 0.41852200031280518f, 0.5268089771270752f, 0.61179697513580322f, 0.67761099338531494f, 0.72897201776504517f, 0.76956802606582642f, 0.80211901664733887f, 0.82861298322677612f, 0.85041999816894531f, 0.86859399080276489f, 0.88391202688217163f, 0.89695101976394653f, 0.90814197063446045f, 0.91780698299407959f, 0.9261929988861084f, 0.933493971824646f, 0.93986201286315918f, 0.94542300701141357f, 0.95028501749038696f, 1.25722999719246609e-12f, 0.00005344190140022f, 0.00689807021990418f, 0.05298750102519989f, 0.15135200321674347f, 0.27379500865936279f, 0.38978201150894165f, 0.48924699425697327f, 0.57068902254104614f, 0.6363450288772583f, 0.68930798768997192f, 0.73230600357055664f, 0.7675589919090271f, 0.79679697751998901f, 0.82128000259399414f, 0.84197902679443359f, 0.85963702201843262f, 0.87481701374053955f, 0.88794499635696411f, 0.89934700727462769f, 0.90928000211715698f, 0.91794902086257935f, 0.92552399635314941f, 0.93214702606201172f, 1.32430000482605838e-19f, 4.34398998550022952e-07f, 0.00078319699969143f, 0.01505979988723993f, 0.06700140237808228f, 0.15685500204563141f, 0.26414799690246582f, 0.36752399802207947f, 0.45892399549484253f, 0.53633898496627808f, 0.60086798667907715f, 0.65432101488113403f, 0.69876497983932495f, 0.73594701290130615f, 0.76730400323867798f, 0.79397499561309814f, 0.8168100118637085f, 0.83649301528930664f, 0.85354900360107422f, 0.86838698387145996f, 0.88132798671722412f, 0.89263200759887695f, 0.90251702070236206f, 0.91116297245025635f, 1.21214998864702984e-29f, 5.61858004566317959e-10f, 0.00004580340100802f, 0.00315008009783924f, 0.02455909922719002f, 0.07877019792795181f, 0.16104799509048462f, 0.25635600090026855f, 0.34949898719787598f, 0.43382999300956726f, 0.50729697942733765f, 0.57010501623153687f, 0.62341398000717163f, 0.66865599155426025f, 0.70718997716903687f, 0.74018502235412598f, 0.76862901449203491f, 0.79324597120285034f, 0.8146439790725708f, 0.83329999446868896f, 0.84960097074508667f, 0.86386102437973022f, 0.87634098529815674f, 0.88726699352264404f, 1.17709071003284634e-43f, 6.58941014274917747e-14f, 1.12094994619837962e-06f, 0.00044787500519305f, 0.00728174997493625f, 0.03418119996786118f, 0.08846849948167801f, 0.16411800682544708f, 0.24980400502681732f, 0.33453500270843506f, 0.41271701455116272f, 0.48244500160217285f, 0.54331201314926147f, 0.59608602523803711f, 0.64167797565460205f, 0.68114197254180908f, 0.71539402008056641f, 0.7452319860458374f, 0.77129900455474854f, 0.79410398006439209f, 0.81407999992370605f, 0.83158797025680542f, 0.846934974193573f, 0.86038398742675781f, 0.0f, 3.5722200588590534e-19f, 8.93677043478646738e-09f, 0.00003873859895975f, 0.00167270004749298f, 0.01264849957078695f, 0.04320650175213814f, 0.09630840271711349f, 0.16610400378704071f, 0.24392600357532501f, 0.32165700197219849f, 0.394569993019104f, 0.46081000566482544f, 0.51976299285888672f, 0.57175701856613159f, 0.61742901802062988f, 0.65750598907470703f, 0.69269400835037231f, 0.72362500429153442f, 0.75082802772521973f, 0.77473902702331543f, 0.79575198888778687f, 0.81420797109603882f, 0.83040601015090942f, 0.0f, 3.95292991891679393e-26f, 1.71184993263961971e-11f, 1.77651998001238098e-06f, 0.0002783710078802f, 0.00388711993582547f, 0.01858510076999664f, 0.05124599859118462f, 0.10246899724006653f, 0.16709500551223755f, 0.23837999999523163f, 0.31022000312805176f, 0.37857699394226074f, 0.44168499112129211f, 0.4988040030002594f, 0.54993897676467896f, 0.59550100564956665f, 0.63594001531600952f, 0.67177599668502808f, 0.70349597930908203f, 0.73152798414230347f, 0.75625097751617432f, 0.77802300453186035f, 0.79716801643371582f, 0.0f, 3.2483199352805935e-35f, 5.40527002565222188e-15f, 3.64182994871953269e-08f, 0.00003074659980484f, 0.00094859098317102f, 0.00691073015332222f, 0.02452139928936958f, 0.05809320136904716f, 0.10707399994134903f, 0.16711099445819855f, 0.23287899792194366f, 0.29971298575401306f, 0.36412099003791809f, 0.42443698644638062f, 0.47984799742698669f, 0.53011900186538696f, 0.57539498805999756f, 0.61597698926925659f, 0.65218400955200195f, 0.6844019889831543f, 0.71295899152755737f, 0.73819798231124878f, 0.7604449987411499f, 0.0f, 0.0f, 1.7447100275121598e-19f, 2.68698008287771017e-10f, 2.01520992959558498e-06f, 0.00017266000213567f, 0.00214895000681281f, 0.01039279997348785f, 0.03002390079200268f, 0.06362999975681305f, 0.11018999665975571f, 0.16611799597740173f, 0.22714599967002869f, 0.2896830141544342f, 0.35065999627113342f, 0.40850698947906494f, 0.46232399344444275f, 0.51169002056121826f, 0.55654400587081909f, 0.59701400995254517f, 0.63333100080490112f, 0.66571998596191406f, 0.69448697566986084f, 0.71991300582885742f, 0.0f, 0.0f, 3.08185990824019565e-25f, 5.37352009676722586e-13f, 6.76860025805581245e-08f, 0.00002156710070267f, 0.00053187098819762f, 0.00379640003666282f, 0.01394980028271675f, 0.03477099910378456f, 0.06777119636535645f, 0.11182600259780884f, 0.16402900218963623f, 0.22092700004577637f, 0.27971801161766052f, 0.33767500519752502f, 0.3932889997959137f, 0.44556498527526855f, 0.493927001953125f, 0.53815799951553345f, 0.57827800512313843f, 0.61434602737426758f, 0.64652997255325317f, 0.67506802082061768f, 0.0f, 0.0f, 1.27565998769738086e-32f, 1.98236004320260421e-16f, 9.54645029693779179e-10f, 1.650769945626962e-06f, 0.00009778440289665f, 0.00114505004603416f, 0.00568277994170785f, 0.01722680032253265f, 0.03851649910211563f, 0.0704336017370224f, 0.11193899810314178f, 0.16071000695228577f, 0.21397699415683746f, 0.2693760097026825f, 0.32457900047302246f, 0.37806499004364014f, 0.42872300744056702f, 0.4758630096912384f, 0.51915699243545532f, 0.55846899747848511f, 0.59376901388168335f, 0.62519502639770508f, 0.0f, 0.0f, 3.7106383335321156e-42f, 7.81385018096993734e-21f, 4.26179013954253172e-12f, 6.59224994592477742e-08f, 0.00001210350001202f, 0.00026765500660986f, 0.00194808002561331f, 0.00754345022141933f, 0.01991299912333488f, 0.04105570167303085f, 0.0715148001909256f, 0.11042399704456329f, 0.15595099329948425f, 0.20584699511528015f, 0.25806799530982971f, 0.31055599451065063f, 0.36178100109100342f, 0.41049200296401978f, 0.45592901110649109f, 0.49765899777412415f, 0.53551197052001953f, 0.56948697566986084f, 0.0f, 0.0f, 0.0f, 1.4501699354155858e-26f, 3.9408500097373126e-15f, 1.07906994450956972e-09f, 8.70304006639344152e-07f, 0.0000440725016233f, 0.0005269440007396f, 0.00279516004957259f, 0.00910075008869171f, 0.02173379994928837f, 0.04219720140099525f, 0.07087449729442596f, 0.10709299892187119f, 0.14939899742603302f, 0.19591200351715088f, 0.24481700360774994f, 0.29424700140953064f, 0.34261700510978699f, 0.38869300484657288f, 0.43174698948860168f, 0.47139298915863037f, 0.50751799345016479f, 0.0f, 0.0f, 0.0f, 3.37722993781223165e-34f, 3.80885988849822355e-19f, 4.90656994200922014e-12f, 2.86603007992880521e-08f, 4.38328015661682002e-06f, 0.00010134100011783f, 0.00081476598279551f, 0.00349242007359862f, 0.01008209958672523f, 0.02243220061063766f, 0.04172819852828979f, 0.06827779859304428f, 0.10154099762439728f, 0.14030000567436218f, 0.18292999267578125f, 0.22785000503063202f, 0.27340999245643616f, 0.31820300221443176f, 0.36118099093437195f, 0.40175101161003113f, 0.43962100148200989f, 0.0f, 0.0f, 0.0f, 9.8090892502737195e-45f, 1.13511000171572082e-24f, 3.09601003078345365e-15f, 2.82900008974351636e-10f, 2.00208006617685896e-07f, 0.00001151220021711f, 0.00016400900494773f, 0.00102415005676448f, 0.00382522004656494f, 0.01021770015358925f, 0.02173330076038837f, 0.03936100006103516f, 0.06336659938097f, 0.09330789744853973f, 0.12818600237369537f, 0.16668100655078888f, 0.20739200711250305f, 0.24903899431228638f, 0.29063498973846436f, 0.33134400844573975f, 0.37064099311828613f, 0.0f, 0.0f, 0.0f, 0.0f, 8.14998004479130106e-33f, 6.36954985683458947e-20f, 3.45817992297714483e-13f, 2.37365993527305363e-09f, 5.25424979969102424e-07f, 0.00001739979961712f, 0.00018874299712479f, 0.00102673994842917f, 0.00357491988688707f, 0.00922095961868763f, 0.01929700002074242f, 0.03473329916596413f, 0.05588230118155479f, 0.08250939846038818f, 0.1139099970459938f, 0.14910100400447845f, 0.18701300024986267f, 0.22664099931716919f, 0.26713100075721741f, 0.3078019917011261f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 7.3832999238063224e-28f, 4.4141699295504271e-18f, 1.48473995684877957e-12f, 3.29401994569877843e-09f, 4.59630996374471579e-07f, 0.00001273939960811f, 0.00013086199760437f, 0.00071139499777928f, 0.00253174011595547f, 0.00673073995858431f, 0.01454710029065609f, 0.02702569961547852f, 0.04481859877705574f, 0.06811539828777313f, 0.09668000042438507f, 0.12994599342346191f, 0.1671299934387207f, 0.2073339968919754f, 0.24963200092315674f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, 3.35172992357784324e-37f, 1.16603995591046571e-24f, 3.39939997419364372e-17f, 1.64230001126197678e-12f, 1.9398800343850553e-09f, 2.402420022917795e-07f, 7.1422400651499629e-06f, 0.00008337580220541f, 0.0005176099948585f, 0.00207298994064331f, 0.00607771007344127f, 0.01419879961758852f, 0.0280108992010355f, 0.04858930036425591f, 0.07628270238637924f, 0.11069700121879578f, 0.15084299445152283f, 0.19536399841308594f
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
        float _S338 = (F32_sqrt((0.00999999977648258f)));
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
    uint state_2 = random_state_3;
    float3  _S396 = sampleHalfVector(v_4, n_i_3, alpha_2, frame_1, &state_2);
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
        bool _S411 = eta_i_1 == eta_o_1;
        float _S412 = _slang_select(_S411, cos_theta_0,_S410);
        float _S413 = eta_o_1 * cos_theta_0;
        float _S414 = eta_i_1 * _S412;
        float _S415 = (_S413 - _S414) / (_S413 + _S414);
        float _S416 = eta_i_1 * cos_theta_0;
        float _S417 = eta_o_1 * _S412;
        float _S418 = (_S416 - _S417) / (_S416 + _S417);
        float _S419 = (_S415 * _S415 + _S418 * _S418) / 2.0f;
        kr_0 = _S419;
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
    float _S420 = dot_0(ggx_n_0, v_5);
    float _S421 = eta_i_2 / eta_o_2;
    float3  _S422 = refract_0(in_dir_2, ggx_n_0, _S421);
    float3  _S423 = ((((_S422)) * make_float3(rnorm3df(((_S422)).x, ((_S422)).y, ((_S422)).z))));
    float _S424 = (F32_min(((F32_sqrt((material_2.specular_level))) * (F32_abs((eta_i_2 - eta_o_2))) / (eta_i_2 + eta_o_2)), (0.9999847412109375f)));
    float _S425 = _S424 * _S424;
    float _S426 = (1.0f + _S424) / (1.0f - _S424);
    float _S427 = (F32_abs((_S420)));
    bool _S428 = eta_i_2 > eta_o_2;
    float sheen_component_0;
    if(_S428)
    {
        sheen_component_0 = _S426;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    float toon_component_0;
    if(_S428)
    {
        toon_component_0 = 1.0f;
    }
    else
    {
        toon_component_0 = _S426;
    }
    float _S429 = fresnel(_S427, sheen_component_0, toon_component_0);
    bool _S430 = (eta_i_2 * eta_i_2 * (1.0f - _S420 * _S420)) >= (eta_o_2 * eta_o_2);
    float3  _S431;
    if(_S430)
    {
        _S431 = make_float3 (1.0f);
    }
    else
    {
        float3  _S432 = material_2.specular_tint * make_float3 (_S425);
        _S431 = _S432 + (make_float3 (1.0f) - _S432) * make_float3 (_S429 - _S425) / make_float3 (1.0f - _S425);
    }
    float3  _S433 = make_float3 (1.0f);
    float3  _S434 = make_float3 (0.0f);
    float3  sheen_1;
    float3  scale_1;
    if(sheen_profile_0.on)
    {
        float _S435 = (F32_min((sheen_profile_0.albedo), (1.0f)));
        float3  _S436 = make_float3 (1.0f) - material_2.sheen * make_float3 (_S435);
        float _S437 = rgb_to_greyscale(material_2.sheen);
        float _S438 = _S437 * _S435;
        float3  _S439 = material_2.sheen / make_float3 ((F32_max((sheen_profile_0.albedo), (1.0f))));
        sheen_component_0 = _S438;
        sheen_1 = _S439;
        scale_1 = _S436;
    }
    else
    {
        sheen_component_0 = 0.0f;
        sheen_1 = _S434;
        scale_1 = _S433;
    }
    float _S440 = (F32_abs((material_2.toon.x)));
    bool _S441 = _S440 > 0.0f;
    float3  toon_1;
    if(_S441)
    {
        float _S442 = (F32_min((_S440), (1.0f)));
        float3  scale_2 = scale_1 * make_float3 (1.0f - _S442);
        float _S443 = rgb_to_greyscale(material_2.albedo);
        float _S444 = _S442 * _S443;
        float3  _S445 = make_float3 (_S442) * material_2.albedo;
        toon_component_0 = _S444;
        toon_1 = _S445;
        scale_1 = scale_2;
    }
    else
    {
        toon_component_0 = 0.0f;
        toon_1 = _S434;
    }
    bool _S446 = (material_2.metallic) > 0.0f;
    float3  rebounce_0;
    if(_S446)
    {
        float _S447 = frame_2.alphas.x;
        float _S448 = (F32_sqrt(((F32_min((_S447), (frame_2.alphas.y))))));
        bool _S449 = _S447 > 0.0f;
        float _S450 = _slang_select(_S449, _S448,material_2.roughness);
        float _S451 = _S450 * _S450;
        float _S452 = (F32_pow((_S451), (1.81585001945495605f))) * (2.15371990203857422f - 0.73285001516342163f * _S451) / (1.0f + 1.28094995021820068f * _S451);
        bool _S453 = _S451 > 0.0f;
        float _S454 = _slang_select(_S453, _S452,0.0f);
        float _S455 = clamp_1(dot_0(n_i_4, v_5), 0.0f, 1.0f);
        float _S456 = _S451 * _S450;
        float _S457 = (F32_min((1.00064504146575928f - _S450 * (0.00375499995425344f + _S455 * (-0.04133399948477745f + _S455 * (-0.90938502550125122f + _S455 * 0.35275399684906006f))) - _S451 * (0.27602800726890564f + _S455 * (1.27023398876190186f + _S455 * 0.04740000143647194f)) - _S456 * (0.31452900171279907f - _S455 * 0.34830701351165771f) + _S456 * _S450 * 0.27229699492454529f), (1.0f)));
        float3  _S458 = min_1(make_float3 (1.0f) / (make_float3 (1.0f) - material_2.albedo * make_float3 (_S454)), make_float3 (1.0f / (F32_max((_S457), (0.0000152587890625f)))));
        rebounce_0 = _S458;
    }
    else
    {
        rebounce_0 = _S433;
    }
    float3  _S459 = mix_0(_S431, material_2.albedo * rebounce_0, material_2.metallic);
    float3  F_1 = _S459 * scale_1;
    float _S460 = rgb_to_greyscale(F_1);
    float _S461 = 1.0f - material_2.metallic;
    float3  _S462 = make_float3 (1.0f) - _S431;
    float3  _S463 = make_float3 ((1.0f - material_2.transmission) * _S461) * _S462 * scale_1;
    float3  _S464 = make_float3 (material_2.transmission * _S461) * _S462 * scale_1;
    float _S465 = (F32_max((_S460), (0.0f)));
    float _S466 = rgb_to_greyscale(_S463);
    float _S467 = (F32_max((_S466), (0.0f)));
    float _S468 = rgb_to_greyscale(_S464);
    float _S469 = sign_0(length_0(_S423));
    float _S470 = (F32_max((_S468 * _S469), (0.0f)));
    float _S471 = _S465 + _S467 + _S470 + toon_component_0;
    float _S472 = (F32_min((sheen_component_0), (1.0f)));
    bool _S473 = sheen_component_0 > 0.0f;
    bool _S474;
    if(_S473)
    {
        _S474 = !(_S471 > 0.0f);
    }
    else
    {
        _S474 = false;
    }
    float _S475 = _slang_select(_S474, 1.0f,_S472);
    float _S476 = (1.0f - _S475) / (F32_max((_S471), (0.0000152587890625f)));
    float _S477 = _S467 * _S476;
    float _S478 = _S465 * _S476;
    float _S479 = _S470 * _S476;
    return Weights_x24init_0(_S420, _S423, F_1, 1.0f, _S463, _S464, _S477, _S478, _S479, _S475, toon_component_0 * _S476, sheen_1, toon_1);
}

__device__ float translucentShare(BSDFMaterial material_3)
{
    float _S480 = rgb_to_greyscale(material_3.translucent);
    float _S481 = rgb_to_greyscale(material_3.albedo);
    float _S482 = _S480 / (_S481 + _S480);
    bool _S483 = _S480 > 0.0f;
    float _S484 = _slang_select(_S483, _S482,0.0f);
    return _S484;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float n_i_dot_v_0, BSDFMaterial material_4, Weights w_1)
{
    float _S485 = translucentShare(material_4);
    float _S486 = w_1.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S487 = w_1.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S488 = 1.0f - _S485;
    bool _S489 = n_i_dot_l_0 < 0.0f;
    float _S490 = _slang_select(_S489, _S485,_S488);
    float _S491 = _S487 * _S490;
    bool _S492 = _S485 > 0.0f;
    float _S493 = _slang_select(_S492, _S491,_S486);
    bool _S494 = n_i_dot_v_0 > 0.0f;
    float _S495 = _slang_select(_S494, _S493,0.0f);
    return _S495;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_5, BSDFMaterial material_5, Weights w_2)
{
    float _S496 = translucentShare(material_5);
    bool _S497 = (dot_0(n_i_5, l_0)) < 0.0f;
    float3  _S498 = _slang_select(_S497, material_5.translucent,material_5.albedo);
    float _S499 = 1.0f - _S496;
    float _S500 = _slang_select(_S497, _S496,_S499);
    float3  _S501 = _S498 / make_float3 (_S500);
    bool _S502 = _S496 > 0.0f;
    float3  _S503 = _slang_select(_S502, _S501,material_5.albedo);
    return w_2.diffuse_weight * _S503 / make_float3 (w_2.p_diffuse);
}

__device__ float smithG1(float alpha_3, float n_dot_x_0)
{
    float _S504 = alpha_3 * alpha_3;
    float _S505 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S504 + (1.0f - _S504) * n_dot_x_0 * n_dot_x_0))));
    bool _S506 = alpha_3 > 0.0f;
    float _S507 = _slang_select(_S506, _S505,1.0f);
    return _S507;
}

__device__ float trowbridgeReitz(float alpha_4, float n_dot_h_0)
{
    float _S508 = alpha_4 * alpha_4;
    float _S509 = (1.0f - n_dot_h_0) * (1.0f + n_dot_h_0) + _S508 * n_dot_h_0 * n_dot_h_0;
    return _S508 / (F32_max((3.14159274101257324f * _S509 * _S509), (1.17549435082228751e-38f)));
}

__device__ float anisotropicG1(float3  w_3, float2  alphas_1)
{
    float _S510 = (F32_max((w_3.z), (0.0f)));
    return 2.0f * _S510 / (_S510 + length_0(make_float3 (alphas_1.x * w_3.x, alphas_1.y * w_3.y, _S510)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_2)
{
    float _S511 = alphas_2.x;
    float _S512 = h_0.x / _S511;
    float _S513 = alphas_2.y;
    float _S514 = h_0.y / _S513;
    float _S515 = h_0.z;
    float _S516 = _S512 * _S512 + _S514 * _S514 + _S515 * _S515;
    return 1.0f / (F32_max((3.14159274101257324f * _S511 * _S513 * _S516 * _S516), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float3  v_6, float3  h_1, float3  n_i_6, float n_i_dot_v_1, float alpha_5, AnisotropicFrame frame_3, float v_dot_h_1)
{
    float _S517 = dot_0(n_i_6, h_1);
    float _S518 = smithG1(alpha_5, n_i_dot_v_1);
    float _S519 = _S518 * v_dot_h_1;
    float _S520 = trowbridgeReitz(alpha_5, _S517);
    float _S521 = _S519 * _S520 / n_i_dot_v_1;
    bool _S522 = alpha_5 > 0.0f;
    bool _S523;
    if(_S522)
    {
        _S523 = v_dot_h_1 > 0.0f;
    }
    else
    {
        _S523 = false;
    }
    if(_S523)
    {
        _S523 = _S517 > 0.0f;
    }
    else
    {
        _S523 = false;
    }
    if(_S523)
    {
        _S523 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S523 = false;
    }
    float _S524 = _slang_select(_S523, _S521,0.0f);
    bool _S525 = (frame_3.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S525)
    {
        float3  _S526 = anisotropicLocal(v_6, frame_3.tangent, n_i_6);
        float _S527 = anisotropicG1(_S526, frame_3.alphas);
        float3  _S528 = anisotropicLocal(h_1, frame_3.tangent, n_i_6);
        float _S529 = anisotropicD(_S528, frame_3.alphas);
        float _S530 = _S527 * _S529;
        float _S531 = _S530 * v_dot_h_1 / n_i_dot_v_1;
        bool _S532 = v_dot_h_1 > 0.0f;
        if(_S532)
        {
            _S523 = _S517 > 0.0f;
        }
        else
        {
            _S523 = false;
        }
        if(_S523)
        {
            _S523 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S523 = false;
        }
        float _S533 = _slang_select(_S523, _S531,0.0f);
        pdf_h_0 = _S533;
    }
    else
    {
        pdf_h_0 = _S524;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float l_dot_h_0, float pdf_h_1, Weights w_4, float eta_i_3, float eta_o_3)
{
    float _S534 = eta_i_3 * w_4.v_dot_h + eta_o_3 * l_dot_h_0;
    float _S535 = w_4.p_refract * pdf_h_1 * eta_o_3 * eta_o_3 * (F32_abs((l_dot_h_0))) / (_S534 * _S534);
    bool _S536 = eta_i_3 != eta_o_3;
    bool _S537;
    if(_S536)
    {
        _S537 = l_dot_h_0 < 0.0f;
    }
    else
    {
        _S537 = false;
    }
    float _S538 = _slang_select(_S537, _S535,0.0f);
    return _S538;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_7, float alpha_6, AnisotropicFrame frame_4, BSDFMaterial material_6, Weights w_5)
{
    float _S539 = - dot_0(n_i_7, l_1);
    float _S540 = smithG1(alpha_6, (F32_max((_S539), (0.0f))));
    bool _S541 = (frame_4.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S541)
    {
        float3  _S542 = negate_0(n_i_7);
        float3  _S543 = anisotropicLocal(l_1, frame_4.tangent, _S542);
        float _S544 = anisotropicG1(_S543, frame_4.alphas);
        G1_l_0 = _S544;
    }
    else
    {
        G1_l_0 = _S540;
    }
    bool _S545 = (material_6.ior) == 1.0f;
    float _S546 = _slang_select(_S545, 1.0f,G1_l_0);
    return w_5.refract_weight * make_float3 (_S546) * material_6.albedo / make_float3 (w_5.p_refract);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_1, float n_i_dot_v_2, Weights w_6)
{
    float _S547 = w_6.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S548 = n_i_dot_l_1 > 0.0f;
    bool _S549;
    if(_S548)
    {
        _S549 = n_i_dot_v_2 > 0.0f;
    }
    else
    {
        _S549 = false;
    }
    float _S550 = _slang_select(_S549, _S547,0.0f);
    return _S550;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  v_7, float3  n_i_8, BSDFMaterial material_7, Weights w_7)
{
    float3  _S551 = l_2 + v_7;
    float3  _S552 = ((((_S551)) * make_float3(rnorm3df(((_S551)).x, ((_S551)).y, ((_S551)).z))));
    float _S553 = dot_0(n_i_8, _S552);
    float _S554 = (F32_max((dot_0(n_i_8, l_2)), (0.0f)));
    float _S555 = (F32_max((dot_0(n_i_8, v_7)), (0.0f)));
    float _S556 = 1.0f / (F32_max((material_7.sheen_roughness), (0.05000000074505806f)));
    float _S557 = 1.0f - _S553 * _S553;
    float _S558 = (2.0f + _S556) * (F32_pow(((F32_max((_S557), (0.0f)))), (0.5f * _S556))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S554 + _S555 - _S554 * _S555)), (0.0000152587890625f)));
    bool _S559 = (material_7.velvet) > 0.0f;
    float f_1;
    if(_S559)
    {
        float _S560 = (F32_max((material_7.sheen_roughness), (0.00999999977648258f)));
        float _S561 = _S560 * _S560;
        float _S562 = (F32_max((_S557), (0.0000152587890625f)));
        float _S563 = (F32_exp((- _S553 * _S553 / (_S562 * _S561)))) / (3.14159274101257324f * _S561 * _S562 * _S562) * (F32_min((1.0f), (2.0f * _S553 * (F32_min((_S554), (_S555))) / (F32_max(((F32_abs((dot_0(_S552, v_7))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S554 * _S555), (0.0000152587890625f)));
        f_1 = _S563;
    }
    else
    {
        f_1 = _S558;
    }
    return w_7.sheen * make_float3 (f_1 * _S554 * 2.0f * 3.14159274101257324f / w_7.p_sheen_velvet);
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
    float _S564;
    if(t_13 < a_5)
    {
        _S564 = 1.0f;
    }
    else
    {
        _S564 = (F32_max((1.0f - (t_13 - a_5) / (F32_max((s_0), (0.0000152587890625f)))), (0.0f)));
    }
    return _S564;
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
        float _S565 = (F32_sin(((F32_min((t_14), (a_6))))));
        integral_0 = _S565 * _S565 / 2.0f;
    }
    bool _S566 = t_14 > a_6;
    bool _S567;
    if(_S566)
    {
        _S567 = s_1 > 0.0f;
    }
    else
    {
        _S567 = false;
    }
    if(_S567)
    {
        float _S568;
        if(glossy_0)
        {
            float _S569 = (F32_cos((a_6)));
            float _S570 = (F32_cos((t_14)));
            _S568 = (1.0f + a_6 / s_1) * (_S569 - _S570) - ((F32_sin((t_14))) - t_14 * _S570 - ((F32_sin((a_6))) - a_6 * _S569)) / s_1;
        }
        else
        {
            float _S571 = 2.0f * a_6;
            float _S572 = (F32_cos((_S571)));
            float _S573 = 2.0f * t_14;
            float _S574 = (F32_cos((_S573)));
            _S568 = (1.0f + a_6 / s_1) * (_S572 - _S574) / 4.0f - ((F32_sin((_S573))) / 8.0f - t_14 * _S574 / 4.0f - ((F32_sin((_S571))) / 8.0f - a_6 * _S572 / 4.0f)) / s_1;
        }
        float integral_1 = integral_0 + _S568;
        integral_0 = integral_1;
    }
    return integral_0;
}

static __device__ ToonProfile ToonProfile_x24init_0(bool glossy_1, float a_7, float s_2, float b_1, float norm_0, float view_0, float3  axis_0)
{
    ToonProfile _S575;
    (&_S575)->glossy = glossy_1;
    (&_S575)->a = a_7;
    (&_S575)->s = s_2;
    (&_S575)->b = b_1;
    (&_S575)->norm = norm_0;
    (&_S575)->view = view_0;
    (&_S575)->axis = axis_0;
    return _S575;
}

__device__ __forceinline__ ToonProfile toonProfile(float3  v_8, float3  n_i_9, BSDFMaterial material_8)
{
    float _S576 = material_8.toon.x;
    bool _S577 = _S576 < 0.0f;
    float _S578 = clamp_1(material_8.toon.y / _S576, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S579 = clamp_1(material_8.toon.z / _S576, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S580 = (F32_min((_S578 + _S579), (1.57079637050628662f)));
    float _S581 = dot_0(n_i_9, v_8);
    float _S582 = toonP((F32_acos(((F32_min((_S581), (1.0f)))))), _S578, _S579);
    float3  _S583;
    if(_S577)
    {
        float3  _S584 = make_float3 (2.0f * _S581) * n_i_9 - v_8;
        float3  _S585 = ((((_S584)) * make_float3(rnorm3df(((_S584)).x, ((_S584)).y, ((_S584)).z))));
        _S583 = _S585;
    }
    else
    {
        _S583 = n_i_9;
    }
    float _S586 = toonIntegral(_S580, _S578, _S579, _S577);
    return ToonProfile_x24init_0(_S577, _S578, _S579, _S580, 6.28318548202514648f * _S586, _S582, _S583);
}

__device__ __forceinline__ float toonPDF(float3  l_3, float3  n_i_10, ToonProfile profile_1, Weights w_8)
{
    float _S587 = dot_0(n_i_10, l_3);
    float _S588 = dot_0(l_3, profile_1.axis);
    float _S589 = _slang_select(profile_1.glossy, _S588,_S587);
    float _S590 = (F32_acos((clamp_1(_S589, -1.0f, 1.0f))));
    float _S591 = toonP(_S590, profile_1.a, profile_1.s);
    float _S592 = w_8.p_toon * _S591;
    float _S593 = _slang_select(profile_1.glossy, 1.0f,_S587);
    float _S594 = _S592 * _S593 / profile_1.norm;
    bool _S595;
    if(profile_1.glossy)
    {
        _S595 = true;
    }
    else
    {
        _S595 = _S587 > 0.0f;
    }
    float _S596 = _slang_select(_S595, _S594,0.0f);
    return _S596;
}

__device__ __forceinline__ float3  toonBSDF(float3  l_4, float3  n_i_11, ToonProfile profile_2, Weights w_9)
{
    float _S597 = (F32_max((dot_0(n_i_11, l_4)), (0.0f)));
    float _S598 = _slang_select(profile_2.glossy, _S597,profile_2.view);
    return w_9.toon * make_float3 (_S598) / make_float3 (w_9.p_toon);
}

__device__ __forceinline__ float reflectPDF(float pdf_h_2, Weights w_10)
{
    float _S599 = w_10.p_reflect * pdf_h_2 / (4.0f * w_10.v_dot_h);
    bool _S600 = pdf_h_2 > 0.0f;
    float _S601 = _slang_select(_S600, _S599,0.0f);
    return _S601;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_5, float3  n_i_12, float alpha_7, AnisotropicFrame frame_5, Weights w_11)
{
    float _S602 = dot_0(n_i_12, l_5);
    float _S603 = smithG1(alpha_7, (F32_max((_S602), (0.0f))));
    bool _S604 = (frame_5.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S604)
    {
        float3  _S605 = anisotropicLocal(l_5, frame_5.tangent, n_i_12);
        float _S606 = anisotropicG1(_S605, frame_5.alphas);
        G1_l_1 = _S606;
    }
    else
    {
        G1_l_1 = _S603;
    }
    return make_float3 (w_11.reflect_weight * G1_l_1) * w_11.F / make_float3 (w_11.p_reflect);
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_3, float3  out_dir_2, float3  n_6, BSDFMaterial material_9, float eta_i_4, float eta_o_4, bool refracted_2, uint random_state_4, FixedArray<float3 , 5>  * throughputs_0, FixedArray<float, 5>  * pdfs_0)
{
    float3  ggx_n_1;
    float3  _S607 = negate_0(in_dir_3);
    float _S608 = dot_0(n_6, _S607);
    float _S609 = sign_0(_S608);
    float3  _S610 = n_6 * make_float3 (_S609);
    float _S611 = dot_0(_S610, out_dir_2);
    float _S612 = material_9.roughness;
    float _S613 = _S612 * _S612;
    AnisotropicFrame _S614 = anisotropicFrame(material_9, _S610);
    SheenProfile _S615 = sheenProfile(_S607, _S610, material_9);
    float _S616 = rgb_to_greyscale(material_9.translucent);
    bool _S617 = _S616 > 0.0f;
    bool _S618 = (dot_0(n_6, out_dir_2) * _S608) < 0.0f;
    bool _S619 = (F32_abs((material_9.toon.x))) > 0.0f;
    uint _S620;
    if(_S619)
    {
        _S620 = 5U;
    }
    else
    {
        _S620 = 4U;
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
        float3  _S621 = make_float3 (0.0f);
        (*throughputs_0)[i_7] = _S621;
        (*pdfs_0)[i_7] = 0.0f;
        uint i_8 = i_7 + 1U;
        i_7 = i_8;
    }
    float3  _S622 = make_float3 (0.0f);
    Weights _S623 = Weights_x24init_0(0.0f, _S622, _S622, 0.0f, _S622, _S622, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, _S622, _S622);
    uint half_of_0 = 4294967295U;
    Weights w_12 = _S623;
    float3  ggx_n_2 = _S622;
    i_7 = 0U;
    for(;;)
    {
        if(i_7 < _S620)
        {
        }
        else
        {
            break;
        }
        uint _S624;
        if(i_7 == 3U)
        {
            _S624 = 4U;
        }
        else
        {
            if(i_7 == 4U)
            {
                _S624 = 6U;
            }
            else
            {
                _S624 = i_7;
            }
        }
        bool _S625 = _S624 == 0U;
        bool _S626;
        if(_S625)
        {
            _S626 = _S617;
        }
        else
        {
            _S626 = false;
        }
        bool _S627;
        if(_S626)
        {
            _S627 = _S618;
        }
        else
        {
            _S627 = _S624 == 1U;
        }
        bool _S628 = _S627 != refracted_2;
        if(_S628)
        {
            ggx_n_1 = ggx_n_2;
            uint i_9 = i_7 + 1U;
            ggx_n_2 = ggx_n_1;
            i_7 = i_9;
            continue;
        }
        uint _S629;
        if(_S624 == 6U)
        {
            _S629 = 0U;
        }
        else
        {
            if(_S624 == 4U)
            {
                _S629 = 2U;
            }
            else
            {
                _S629 = _S624;
            }
        }
        bool _S630 = _S629 != half_of_0;
        uint half_of_1;
        Weights w_13;
        if(_S630)
        {
            bool _S631 = _S629 == 0U;
            if(_S631)
            {
                float3  _S632 = sampledHalf(_S607, _S610, _S613, _S614, random_state_4);
                ggx_n_1 = _S632;
            }
            else
            {
                bool _S633 = _S629 == 1U;
                if(_S633)
                {
                    float3  _S634 = refractedHalf(in_dir_3, out_dir_2, n_6, eta_i_4, eta_o_4);
                    ggx_n_1 = _S634;
                }
                else
                {
                    float3  _S635 = reflectedHalf(in_dir_3, out_dir_2);
                    ggx_n_1 = _S635;
                }
            }
            Weights _S636 = lobeWeights(in_dir_3, _S607, _S610, ggx_n_1, _S614, _S615, material_9, eta_i_4, eta_o_4);
            w_13 = _S636;
            half_of_1 = _S629;
        }
        else
        {
            w_13 = w_12;
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S624)
        {
        case 0U:
            {
                float _S637 = diffusePDF(_S611, (F32_abs((_S608))), material_9, w_13);
                (*pdfs_0)[int(0)] = _S637;
                float3  _S638 = diffuseBSDF(out_dir_2, _S610, material_9, w_13);
                (*throughputs_0)[int(0)] = _S638;
                break;
            }
        case 1U:
            {
                float _S639 = dot_0(out_dir_2, ggx_n_1);
                float _S640 = vndfPDF(_S607, ggx_n_1, _S610, (F32_abs((_S608))), _S613, _S614, w_13.v_dot_h);
                float _S641 = refractPDF(_S639, _S640, w_13, eta_i_4, eta_o_4);
                (*pdfs_0)[int(1)] = _S641;
                float3  _S642 = refractBSDF(out_dir_2, _S610, _S613, _S614, material_9, w_13);
                (*throughputs_0)[int(1)] = _S642;
                break;
            }
        case 4U:
            {
                float _S643 = sheenVelvetPDF(_S611, (F32_abs((_S608))), w_13);
                (*pdfs_0)[int(3)] = _S643;
                float3  _S644 = sheenVelvetBSDF(out_dir_2, _S607, _S610, material_9, w_13);
                (*throughputs_0)[int(3)] = _S644;
                break;
            }
        case 6U:
            {
                ToonProfile _S645 = toonProfile(_S607, _S610, material_9);
                float _S646 = toonPDF(out_dir_2, _S610, _S645, w_13);
                (*pdfs_0)[int(4)] = _S646;
                float3  _S647 = toonBSDF(out_dir_2, _S610, _S645, w_13);
                (*throughputs_0)[int(4)] = _S647;
                break;
            }
        default:
            {
                float _S648 = vndfPDF(_S607, ggx_n_1, _S610, (F32_abs((_S608))), _S613, _S614, w_13.v_dot_h);
                float _S649 = reflectPDF(_S648, w_13);
                (*pdfs_0)[int(2)] = _S649;
                float3  _S650 = reflectBSDF(out_dir_2, _S610, _S613, _S614, w_13);
                (*throughputs_0)[int(2)] = _S650;
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
    ggx_n_1 = _S622;
    for(;;)
    {
        if(i_7 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S651 = ((*pdfs_0)[i_7]) > 0.0f;
        if(_S651)
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
    bool _S652 = wrongSide_0(is_inside_2, false, dir_3, surface_1->geometry_n);
    float3  _S653 = BSDF(in_dir_4, dir_3, surface_1->smooth_n, surface_1->material, eta_1.x, eta_1.y, _S652, random_state_5, terms_0, pdfs_1);
    float3  _S654 = make_float3 (0.0f);
    uint i_11 = 0U;
    float3  f_3 = _S654;
    for(;;)
    {
        if(i_11 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S655 = ((*pdfs_1)[i_11]) > 0.0f;
        if(_S655)
        {
            float3  _S656 = (*terms_0)[i_11] * make_float3 ((*pdfs_1)[i_11]) / make_float3 ((*pdfs_1)[i_11] + pdf_0);
            (*terms_0)[i_11] = _S656;
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
    FKSurface _S657 = surface_2;
    FixedArray<float3 , 5>  terms_1;
    FixedArray<float, 5>  pdfs_2;
    float3  _S658 = skyLobes_0(in_dir_5, dir_4, &_S657, eta_2, is_inside_3, pdf_1, random_state_6, &terms_1, &pdfs_2);
    return _S658;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_5, float3  radiance_0, float3  color_0, uint random_state_7)
{
    SkySample _S659;
    (&_S659)->dir = dir_5;
    (&_S659)->radiance = radiance_0;
    (&_S659)->color = color_0;
    (&_S659)->random_state = random_state_7;
    return _S659;
}

static __device__ __noinline__ float3  skyColor_0(float3  in_dir_6, float3  dir_6, FKSurface * surface_3, float2  eta_3, bool is_inside_4, float pdf_2, uint random_state_8, uint depth_0)
{
    FixedArray<float3 , 5>  terms_2;
    FixedArray<float, 5>  pdfs_3;
    float3  _S660 = skyLobes_0(in_dir_6, dir_6, surface_3, eta_3, is_inside_4, pdf_2, random_state_8, &terms_2, &pdfs_3);
    float3  _S661 = make_float3 (0.0f);
    bool shaded_0 = false;
    float3  world_0 = _S661;
    uint i_13 = 0U;
    float3  color_1 = _S661;
    for(;;)
    {
        if(i_13 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S662 = (pdfs_3[i_13]) > 0.0f;
        if(_S662)
        {
            bool _S663 = (fcptWorldReadsPath());
            bool _S664;
            if(_S663)
            {
                _S664 = true;
            }
            else
            {
                _S664 = !shaded_0;
            }
            bool shaded_1;
            float3  world_1;
            if(_S664)
            {
                uint _S665;
                if(i_13 == 3U)
                {
                    _S665 = 4U;
                }
                else
                {
                    if(i_13 == 4U)
                    {
                        _S665 = 6U;
                    }
                    else
                    {
                        _S665 = i_13;
                    }
                }
                float3  _S666 = (fcptEnvMapSample((dir_6), (depth_0), (_S665)));
                world_1 = _S666;
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

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_4, float2  eta_4, bool is_inside_5, uint init_random_state_0, uint lobe_state_0, ShadowContext * context_2)
{
    uint2  _S667 = (fcptEnvironmentCdfSize());
    uint2  _S668 = make_uint2 (1U, 0U);
    uint2  _S669 = _S667 - _S668;
    Random _S670 = pcg(init_random_state_0);
    Random _S671 = pcg(_S670.state);
    Random _S672 = pcg(_S671.state);
    Random _S673 = pcg(_S672.state);
    uint _S674 = _S669.x;
    uint _S675 = searchCDF_0(make_uint2 (_S674, 0U), make_uint2 (0U, 1U), _S669.y, _S670.value);
    uint _S676 = searchCDF_0(make_uint2 (0U, _S675), _S668, _S674, _S671.value);
    float2  _S677 = make_float2 ((float)_S669.x, (float)_S669.y);
    float2  _S678 = (make_float2 (float(_S676), float(_S675)) + make_float2 (_S672.value, _S673.value)) / _S677 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S679 = _S678.y;
    float _S680 = (F32_sin((_S679)));
    float _S681 = _S678.x;
    float3  _S682 = make_float3 (- _S680 * (F32_cos((_S681))), _S680 * (F32_sin((_S681))), (F32_cos((_S679))));
    float _S683 = environmentPdf_0(_S682);
    float3  _S684 = ray_0->unit_direction;
    float3  _S685 = skyBSDF(ray_0->unit_direction, _S682, *surface_4, eta_4, is_inside_5, _S683, lobe_state_0);
    bool _S686 = !(_S683 > 0.0f);
    bool _S687;
    if(_S686)
    {
        _S687 = true;
    }
    else
    {
        _S687 = all_1(_S685 == make_float3 (0.0f));
    }
    if(_S687)
    {
        float3  _S688 = make_float3 (0.0f);
        return SkySample_x24init_0(_S682, _S688, _S688, _S673.state);
    }
    bool _S689 = (fcptWorldReadsPath());
    float3  seen_0;
    if(_S689)
    {
        float3  _S690 = skyColor_0(_S684, _S682, surface_4, eta_4, is_inside_5, _S683, lobe_state_0, context_2->depth + 1U);
        seen_0 = _S690;
    }
    else
    {
        seen_0 = _S685;
    }
    float3  _S691 = skyRadiance_0(ray_0->origin, surface_4, is_inside_5, _S682, context_2, _S673.state);
    return SkySample_x24init_0(_S682, _S691, seen_0 * _S691, _S673.state);
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
    SampleBSDF _S692 = (fcptConnectHair((surface_5->hair), ((&surface_5->material)->albedo), ((&surface_5->material)->specular_tint), (in_dir_7), (light_1->dir)));
    float3  _S693 = _S692.throughput * make_float3 (_S692.pdf);
    float _S694 = light_1->density;
    float _S695 = 1.0f + _S692.pdf * _S692.pdf / (light_1->density * light_1->density);
    bool _S696;
    if(competing_0)
    {
        _S696 = _S694 > 0.0f;
    }
    else
    {
        _S696 = false;
    }
    float _S697 = _slang_select(_S696, _S695,1.0f);
    return _S693 / make_float3 (_S697) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_7, float3  radiance_1, float density_0, uint random_state_9)
{
    TreeSample _S698;
    (&_S698)->dir = dir_7;
    (&_S698)->radiance = radiance_1;
    (&_S698)->density = density_0;
    (&_S698)->random_state = random_state_9;
    return _S698;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_12, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S699 = importance(first_1, p_12, normal_3);
    float _S700 = importance(second_1, p_12, normal_3);
    float2  _S701 = make_float2 (_S699, _S700);
    bool _S702 = _S699 == 0.0f;
    bool _S703;
    if(_S702)
    {
        _S703 = _S700 == 0.0f;
    }
    else
    {
        _S703 = false;
    }
    if(_S703)
    {
        return 2U;
    }
    float _S704 = _S699 + _S700;
    bool _S705 = _S700 > 0.0f;
    if(_S705)
    {
        _S703 = (*pick_0 * _S704) >= _S699;
    }
    else
    {
        _S703 = false;
    }
    uint _S706 = uint(_S703);
    float _S707 = (F32_min(((*pick_0 * _S704 - float(_S706) * _S699) / _slang_vector_get_element(_S701, _S706)), (0.99999994039535522f)));
    *pick_0 = _S707;
    float _S708 = *probability_3 * (_slang_vector_get_element(_S701, _S706) / _S704);
    *probability_3 = _S708;
    return _S706;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_13, float u1_0, float u2_0)
{
    float3  _S709 = center_1 - p_13;
    float _S710 = radius_1 * radius_1 / dot_0(_S709, _S709);
    float _S711 = u1_0 * _S710 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S710), (0.0f)))))));
    float _S712 = 2.0f * u1_0;
    bool _S713 = _S710 >= 1.0f;
    float _S714 = _slang_select(_S713, _S712,_S711);
    float _S715 = (F32_sqrt(((F32_max((_S714 * (2.0f - _S714)), (0.0f))))));
    float _S716 = 6.28318548202514648f * u2_0;
    float3  _S717 = make_float3 (_S715 * (F32_cos((_S716))), 1.0f - _S714, _S715 * (F32_sin((_S716))));
    float3  _S718 = ((((_S709)) * make_float3(rnorm3df(((_S709)).x, ((_S709)).y, ((_S709)).z))));
    float3  _S719 = tangentToWorld(_S717, _S718);
    return _S719;
}

__device__ float3  pointLightRadiance(float3  color_3, float intensity_0, float radius_2)
{
    return color_3 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S720 = center_2 - ray_1->origin;
    float _S721 = dot_0(_S720, ray_1->unit_direction);
    float _S722 = dot_0(_S720, _S720) - _S721 * _S721;
    float _S723 = radius_3 * radius_3;
    bool _S724 = _S722 > _S723;
    if(_S724)
    {
        return 4.294967296e+09f;
    }
    float _S725 = (F32_sqrt((_S723 - _S722)));
    float _S726 = _S721 - _S725;
    float _S727 = _S721 + _S725;
    bool _S728 = _S726 > 0.0000152587890625f;
    bool _S729;
    if(_S728)
    {
        _S729 = _S726 < max_len_0;
    }
    else
    {
        _S729 = false;
    }
    if(_S729)
    {
        return _S726;
    }
    bool _S730 = _S727 > 0.0000152587890625f;
    if(_S730)
    {
        _S729 = _S727 < max_len_0;
    }
    else
    {
        _S729 = false;
    }
    if(_S729)
    {
        return _S727;
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
    Random _S731 = pcg(init_random_state_1);
    Random _S732 = pcg(_S731.state);
    Random _S733 = pcg(_S732.state);
    float3  _S734 = make_float3 (0.0f);
    TreeSample _S735 = TreeSample_x24init_0(_S734, _S734, 0.0f, _S733.state);
    TreeSample sample_0 = _S735;
    float3  _S736 = _slang_select(sided_0, _S734,smooth_n_2);
    float3  _S737 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S731.value;
    float probability_4 = 1.0f;
    uint n_7 = 0U;
    for(;;)
    {
        uint4  _S738 = (fcptLightNode((n_7)));
        if((_S738.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S739 = (fcptLightSecond((n_7)));
        uint _S740 = n_7 + 1U;
        LightNode _S741 = (fcptLightBounds((_S740)));
        LightNode _S742 = (fcptLightBounds((_S739)));
        uint _S743 = pickChild(_S741, _S742, origin_4, _S736, &pick_1, &probability_4);
        bool _S744 = _S743 > 1U;
        if(_S744)
        {
            return sample_0;
        }
        bool _S745 = _S743 == 1U;
        uint _S746 = _slang_select(_S745, _S739,_S740);
        n_7 = _S746;
    }
    bool _S747 = n_7 == 0U;
    bool _S748;
    if(_S747)
    {
        LightNode _S749 = (fcptLightBounds((0U)));
        float _S750 = importance(_S749, origin_4, _S736);
        _S748 = !(_S750 > 0.0f);
    }
    else
    {
        _S748 = false;
    }
    if(_S748)
    {
        return sample_0;
    }
    uint4  _S751 = (fcptLightNode((n_7)));
    FKHit _S752 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S753 = (_S751.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S753)
    {
        FKLight _S754 = (fcptLight((_S751.y)));
        if(sided_0)
        {
            float _S755 = sign_0(dot_0(geometry_n_1, _S754.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S755);
            float3  _S756 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S756;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S737;
            lift_n_0 = smooth_n_2;
        }
        bool _S757 = (_S754.variance) == 0.0f;
        if(_S757)
        {
            float3  _S758 = _S754.position - emitter_point_0;
            float3  _S759 = ((((_S758)) * make_float3(rnorm3df(((_S758)).x, ((_S758)).y, ((_S758)).z))));
            (&sample_0)->dir = _S759;
            float3  _S760 = _S754.color * make_float3 (_S754.intensity) / make_float3 (dot_0(_S758, _S758) * probability_4);
            (&sample_0)->radiance = _S760;
            shadow_1 = _S758;
        }
        else
        {
            float3  _S761 = sampleSphere(_S754.position, _S754.variance, emitter_point_0, _S732.value, _S733.value);
            (&sample_0)->dir = _S761;
            float _S762 = sphereDensity(_S754.position, _S754.variance, emitter_point_0);
            float _S763 = probability_4 * _S762;
            (&sample_0)->density = _S763;
            float3  _S764 = pointLightRadiance(_S754.color, _S754.intensity, _S754.variance);
            float3  _S765 = _S764 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S765;
            FKRay _S766 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S767 = raySphere_0(_S754.position, _S754.variance, &_S766, 4.294967296e+09f);
            float3  _S768 = (&sample_0)->dir * make_float3 (_S767);
            shadow_1 = _S768;
        }
        emitter_0 = _S752;
        emitter_point_0 = _S734;
    }
    else
    {
        uint _S769 = _S751.y;
        uint _S770 = (fcptTriangleOffset((_S769)));
        uint _S771 = _S770 + _S751.z;
        Matrix<float, 3, 3>  _S772 = (fcptWorldTriangle((_S769), (_S771)));
        float _S773 = (F32_sqrt((_S732.value)));
        float2  _S774 = make_float2 (_S773 * (1.0f - _S733.value), _S773 * _S733.value);
        float3  _S775 = mul_0(make_float3 (1.0f - _S773, _S774.x, _S774.y), _S772);
        if(sided_0)
        {
            float _S776 = sign_0(dot_0(geometry_n_1, _S775 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S776);
            float3  _S777 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S777;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S778 = !((dot_0(smooth_n_2, _S775 - origin_4)) > 0.0f);
            if(_S778)
            {
                return sample_0;
            }
            emitter_point_0 = _S737;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S774, _S769, _S771, 0U, 0.0f);
        float3  _S779 = _S775 - emitter_point_0;
        float3  _S780 = ((((_S779)) * make_float3(rnorm3df(((_S779)).x, ((_S779)).y, ((_S779)).z))));
        (&sample_0)->dir = _S780;
        float _S781 = solidAngle(probability_4, cross_0(_S772.rows[int(1)] - _S772.rows[int(0)], _S772.rows[int(2)] - _S772.rows[int(0)]), _S779);
        (&sample_0)->density = _S781;
        bool _S782 = (fcptShadowFirst());
        bool _S783 = !_S782;
        if(_S783)
        {
            FKSurface _S784 = (fcptLightSurfaceAt((emitter_1), (_S775), (_S733.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S775 - origin_4))));
            (&sample_0)->random_state = _S784.random_state;
            float3  _S785 = _slang_select(_S784.skip, _S734,_S784.material.emissive);
            float3  _S786 = _S785 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S786;
        }
        shadow_1 = _S779;
        emitter_0 = emitter_1;
        emitter_point_0 = _S775;
    }
    FKHit _S787 = emitter_0;
    float3  _S788 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S733.state, &_S787);
    bool _S789 = (fcptShadowFirst());
    if(_S789)
    {
        _S748 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S748 = false;
    }
    if(_S748)
    {
        _S748 = !all_1(_S788 == _S734);
    }
    else
    {
        _S748 = false;
    }
    if(_S748)
    {
        FKSurface _S790 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S733.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S790.random_state;
        float3  _S791 = _slang_select(_S790.skip, _S734,_S790.material.emissive);
        float3  _S792 = _S791 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S792;
    }
    float3  _S793 = (&sample_0)->radiance * _S788;
    bool _S794 = all_1(_S788 == _S734);
    float3  _S795 = _slang_select(_S794, _S734,_S793);
    (&sample_0)->radiance = _S795;
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
    float _S796 = 1.0f / (1.0f + b_2 / a_8 * (b_2 / a_8));
    bool _S797 = b_2 > 0.0f;
    float _S798 = _slang_select(_S797, _S796,1.0f);
    return _S798;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S799 = vertex_0->none;
    if(_S799)
    {
        return 1.0f;
    }
    uint _S800 = (fcptLightSlot((*hit_1)));
    float _S801 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S800, light_point_1);
    float _S802 = powerHeuristic(vertex_0->pdf, _S801);
    return _S802;
}

static __device__ float3  environment_0(float3  dir_8, uint depth_1, uint lobe_0)
{
    uint2  _S803 = (fcptEnvironmentMapSize());
    bool _S804 = (_S803.x) > 1U;
    bool _S805;
    if(_S804)
    {
        uint2  _S806 = (fcptEnvironmentMapSize());
        _S805 = (_S806.y) > 1U;
    }
    else
    {
        _S805 = false;
    }
    if(_S805)
    {
        float3  _S807 = (fcptEnvMapSample((dir_8), (depth_1), (lobe_0)));
        return _S807;
    }
    float3  _S808 = (fcptAmbient());
    return _S808;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S809 = (fcptEnvironmentCdfSize());
    bool _S810 = (_S809.x) > 1U;
    bool _S811;
    if(_S810)
    {
        uint2  _S812 = (fcptEnvironmentCdfSize());
        _S811 = (_S812.y) > 1U;
    }
    else
    {
        _S811 = false;
    }
    bool _S813 = !_S811;
    if(_S813)
    {
        return false;
    }
    uint2  _S814 = (fcptEnvironmentMapSize());
    bool _S815 = (_S814.x) > 1U;
    if(_S815)
    {
        uint2  _S816 = (fcptEnvironmentMapSize());
        _S811 = (_S816.y) > 1U;
    }
    else
    {
        _S811 = false;
    }
    return _S811;
}

static __device__ float escapeWeight_0(float pdf_3, float3  dir_9)
{
    bool _S817 = pdf_3 <= 0.0f;
    bool _S818;
    if(_S817)
    {
        _S818 = true;
    }
    else
    {
        bool _S819 = environmentMapped_0();
        _S818 = !_S819;
    }
    if(_S818)
    {
        return 1.0f;
    }
    float _S820 = environmentPdf_0(dir_9);
    return pdf_3 / (pdf_3 + _S820);
}

static __device__ void restir_duplicates_0(uint3  global_invocation_id_1, uint3  local_invocation_id_0, uint local_invocation_index_3)
{
    uint2  _S821 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S822 = make_int2 ((int)_S821.x, (int)_S821.y);
    uint _S823 = previousSeed_0(_S822);
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
            uint _S824 = previousSeed_0(_S822 + make_int2 (x_16, y_5));
            bool _S825 = _S824 == _S823;
            uint _S826 = _slang_select(_S825, 1U,0U);
            uint count_3 = count_2 + _S826;
            int x_17 = x_16 + int(1);
            x_16 = x_17;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S827 = float(count_2 - 1U) / 288.0f;
    bool _S828 = _S823 != 0U;
    float _S829 = _slang_select(_S828, _S827,0.0f);
    fcptStoreDuplication((_S822), (make_uint4 ((F32_asuint((_S829))), 0U, 0U, 0U)));
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
    float _S830 = rgb_to_greyscale(abs_0(f_5));
    return _S830;
}

__device__ uint stream(uint seed_3, uint index_0)
{
    uint _S831 = hash(index_0);
    uint _S832 = hash(seed_3 ^ _S831);
    return _S832;
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

__device__ void offer(Selection * sel_2, Reservoir candidate_0, float3  weight_0)
{
    float _S833 = resamplingTarget(weight_0);
    bool _S834 = _S833 > 0.0f;
    bool _S835;
    if(_S834)
    {
        _S835 = _S833 < 3.00000000549775576e+38f;
    }
    else
    {
        _S835 = false;
    }
    bool _S836 = !_S835;
    if(_S836)
    {
        return;
    }
    bool _S837 = sel_2->sums;
    if(_S837)
    {
        float3  _S838 = sel_2->color + weight_0;
        sel_2->color = _S838;
        return;
    }
    float _S839 = sel_2->w_sum + _S833;
    sel_2->w_sum = _S839;
    float3  _S840 = sel_2->color + weight_0;
    sel_2->color = _S840;
    Random _S841 = pcg(sel_2->random_state);
    sel_2->random_state = _S841.state;
    bool _S842 = (_S841.value * sel_2->w_sum) <= _S833;
    if(_S842)
    {
        sel_2->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_3;
    float3  _S843 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S843;
    float _S844 = r_3.jac * shifted_0.jac;
    (&candidate_1)->jac = _S844;
    offer(sel_3, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S845 = resamplingTarget((&r_4)->f);
    float _S846 = sel_4.w_sum / _S845;
    bool _S847 = _S845 > 0.0f;
    float _S848 = _slang_select(_S847, _S846,0.0f);
    (&r_4)->w = _S848;
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
    uint2  _S849 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S850 = make_int2 ((int)_S849.x, (int)_S849.y);
    float3  _S851 = make_float3 (0.0f);
    FKHit _S852 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S853 = Domain_x24init_0(_S851, _S851, &_S852, 0.0f, 0.0f);
    Domain dom_4 = _S853;
    bool _S854 = (fcptCurrentDomain((_S850), (&dom_4)));
    bool _S855 = !_S854;
    if(_S855)
    {
        Reservoir _S856 = (Reservoir{});
        fcptStoreReservoirPrevious((_S850), (_S856), ((&dom_4)->hit));
        return;
    }
    Reservoir _S857 = (fcptLoadReservoirTemporal((_S850)));
    uint t_15 = 0U;
    float count_4 = 0.0f;
    float c_sum_0 = _S857.c;
    for(;;)
    {
        uint _S858 = (fcptRestirNeighbours());
        if(t_15 < _S858)
        {
        }
        else
        {
            break;
        }
        int2  _S859 = partner_0(_S850, t_15);
        Domain neighbor_0 = _S853;
        bool _S860 = (fcptCurrentDomain((_S859), (&neighbor_0)));
        if(_S860)
        {
            float count_5 = count_4 + 1.0f;
            uint4  _S861 = (fcptReservoirTemporal((_S859), (0U)));
            float c_sum_1 = c_sum_0 + (U32_asfloat((_S861.w)));
            count_4 = count_5;
            c_sum_0 = c_sum_1;
        }
        uint t_16 = t_15 + 1U;
        t_15 = t_16;
    }
    float _S862 = _S857.c / (F32_max((count_4), (1.0f)));
    float _S863 = resamplingTarget(_S857.f);
    bool _S864 = count_4 == 0.0f;
    float _S865 = _slang_select(_S864, 1.0f,0.0f);
    Selection _S866 = (Selection{});
    Selection sel_5 = _S866;
    uint _S867 = (fcptFrame());
    uint _S868 = hash(_S867);
    uint _S869 = global_invocation_id_2.x;
    uint2  _S870 = (fcptRenderSize());
    uint _S871 = stream(_S868, _S869 + _S870.x * global_invocation_id_2.y);
    uint _S872 = stream(_S871, 195U);
    (&sel_5)->random_state = _S872;
    t_15 = 0U;
    float canonical_mis_0 = _S865;
    for(;;)
    {
        uint _S873 = (fcptRestirNeighbours());
        if(t_15 < _S873)
        {
        }
        else
        {
            break;
        }
        int2  _S874 = partner_0(_S850, t_15);
        Domain neighbor_dom_0 = _S853;
        bool _S875 = (fcptCurrentDomain((_S874), (&neighbor_dom_0)));
        if(_S875)
        {
            Reservoir _S876 = (fcptLoadReservoirTemporal((_S874)));
            uint4  _S877 = (fcptShiftData((_S874), (t_15)));
            float4  _S878 = asfloat_0(_S877);
            uint4  _S879 = (fcptShiftData((_S850), (t_15)));
            float4  _S880 = asfloat_0(_S879);
            float _S881 = (_S876.c + _S862) / c_sum_0;
            bool _S882 = _S863 > 0.0f;
            float canonical_mis_1;
            if(_S882)
            {
                float _S883 = _S881 * _S862 * _S863;
                float _S884 = _S862 * _S863;
                float _S885 = resamplingTarget(float3 {_S880.x, _S880.y, _S880.z});
                float canonical_mis_2 = canonical_mis_0 + _S883 / (_S884 + _S876.c * _S885);
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float _S886 = resamplingTarget(_S876.f);
            float3  _S887 = float3 {_S878.x, _S878.y, _S878.z};
            Shift _S888 = Shift_x24init_0(_S887, _S878.w);
            float _S889 = _S881 * _S876.c * _S886;
            float _S890 = _S876.c * _S886;
            float _S891 = resamplingTarget(_S887);
            offerShifted(&sel_5, _S876, _S888, _S889 / (_S890 + _S862 * _S891));
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_17 = t_15 + 1U;
        t_15 = t_17;
    }
    offerShifted(&sel_5, _S857, Shift_x24init_0(_S857.f, 1.0f), canonical_mis_0);
    Reservoir _S892 = finalize(sel_5, c_sum_0);
    fcptStoreReservoirPrevious((_S850), (_S892), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S850), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S850), (make_float4 ((&sel_5)->color.x, (&sel_5)->color.y, (&sel_5)->color.z, 0.0f)));
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
    uint _S893 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S894 = _S893 != 4294967295U;
    if(_S894)
    {
        uint2  _S895 = make_uint2 (_S893, _S893 >> 14U) & make_uint2 (16383U);
        int2  _S896 = make_int2 ((int)_S895.x, (int)_S895.y);
        ShiftJob _S897 = (ShiftJob{});
        ShiftJob shift_job_0 = _S897;
        Shift _S898 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S899 = _S893 >> 28U;
        bool _S900 = spatialJob_0(_S896, _S899, &shift_job_0, true);
        Shift shifted_1;
        if(_S900)
        {
            Domain _S901 = (&shift_job_0)->dom;
            Reservoir _S902 = (&shift_job_0)->r;
            Shift _S903 = passShift_0(&_S901, &_S902);
            shifted_1 = _S903;
        }
        else
        {
            shifted_1 = _S898;
        }
        fcptStoreShiftData((_S896), (_S899), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S904 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S905 = make_int2 ((int)_S904.x, (int)_S904.y);
    FixedArray<uint, 3>  _S906;
    spatialBins_0(_S905, &_S906);
    FixedArray<uint, 3>  _S907 = _S906;
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
        bool _S908 = (_S907[t_18]) == 40U;
        if(_S908)
        {
            fcptStoreShiftData((_S905), (t_18), (make_uint4 (0U)));
        }
        uint t_19 = t_18 + 1U;
        t_18 = t_19;
    }
    FixedArray<uint, 3>  _S909 = _S907;
    queueShifts_0(_S905, &_S909, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S910 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S911 = make_int2 ((int)_S910.x, (int)_S910.y);
    FixedArray<uint, 3>  _S912;
    spatialBins_0(_S911, &_S912);
    FixedArray<uint, 3>  _S913 = _S912;
    countShifts_0(&_S913, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S914 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S915 = _S914 != 4294967295U;
    if(_S915)
    {
        uint2  _S916 = make_uint2 (_S914, _S914 >> 14U) & make_uint2 (16383U);
        int2  _S917 = make_int2 ((int)_S916.x, (int)_S916.y);
        int2  _S918 = (fcptLoadTemporalNeighbor((_S917)));
        uint _S919 = _S914 >> 28U;
        Shift _S920 = temporalShiftAt_0(_S917, _S918, _S919);
        fcptStoreTemporalShift((_S917), (_S919), (make_uint4 (asuint_1(_S920.f).x, asuint_1(_S920.f).y, asuint_1(_S920.f).z, (F32_asuint((_S920.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S921 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S922 = make_int2 ((int)_S921.x, (int)_S921.y);
    FixedArray<uint, 3>  _S923;
    temporalBins_0(_S922, &_S923);
    FixedArray<uint, 3>  _S924 = _S923;
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
        bool _S925 = (_S924[t_20]) == 40U;
        if(_S925)
        {
            fcptStoreTemporalShift((_S922), (t_20), (make_uint4 (0U)));
        }
        uint t_21 = t_20 + 1U;
        t_20 = t_21;
    }
    FixedArray<uint, 3>  _S926 = _S924;
    queueShifts_0(_S922, &_S926, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S927 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S928 = make_int2 ((int)_S927.x, (int)_S927.y);
    bool _S929 = (fcptSceneUnchanged());
    bool _S930 = !_S929;
    bool _S931;
    if(_S930)
    {
        uint2  _S932 = (fcptRenderSize());
        int2  _S933 = make_int2 ((int)_S932.x, (int)_S932.y);
        _S931 = all_0(_S928 < _S933);
    }
    else
    {
        _S931 = false;
    }
    if(_S931)
    {
        Reservoir _S934 = (fcptLoadReservoirInitial((_S928)));
        int2  _S935 = sampleNeighbor_0(_S928, _S934.seed);
        fcptStoreTemporalNeighbor((_S928), (_S935));
    }
    FixedArray<uint, 3>  _S936;
    temporalBins_0(_S928, &_S936);
    FixedArray<uint, 3>  _S937 = _S936;
    countShifts_0(&_S937, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_9, float b_3, float t_22)
{
    return a_9 + (b_3 - a_9) * t_22;
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S938 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S939 = make_int2 ((int)_S938.x, (int)_S938.y);
    float3  _S940 = make_float3 (0.0f);
    FKHit _S941 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S942 = Domain_x24init_0(_S940, _S940, &_S941, 0.0f, 0.0f);
    Domain dom_5 = _S942;
    bool _S943 = (fcptCurrentDomain((_S939), (&dom_5)));
    bool _S944 = !_S943;
    if(_S944)
    {
        Reservoir _S945 = (Reservoir{});
        fcptStoreReservoirTemporal((_S939), (_S945), ((&dom_5)->hit));
        return;
    }
    Reservoir _S946 = (fcptLoadReservoirInitial((_S939)));
    bool _S947 = (fcptTemporalQueued());
    bool _S948 = (fcptSceneUnchanged());
    bool _S949;
    if(_S948)
    {
        _S949 = true;
    }
    else
    {
        _S949 = !_S947;
    }
    int2  _S950;
    if(_S949)
    {
        int2  _S951 = sampleNeighbor_0(_S939, _S946.seed);
        _S950 = _S951;
    }
    else
    {
        int2  _S952 = (fcptLoadTemporalNeighbor((_S939)));
        _S950 = _S952;
    }
    bool _S953 = (_S950.x) >= int(0);
    Reservoir r_5;
    if(_S953)
    {
        Reservoir _S954 = (fcptLoadReservoirPrevious((_S950)));
        uint4  _S955 = (fcptDuplication((_S950)));
        float _S956 = (U32_asfloat((_S955.x)));
        uint _S957 = (fcptRestirDecorrelation());
        bool _S958 = _S957 == 1U;
        float _S959 = _slang_select(_S958, _S956,0.0f);
        float _S960 = interpolate_0(20.0f, 1.0f, (F32_pow((_S959), (0.10000000149011612f))));
        float _S961 = (F32_min((_S954.c), (_S960)));
        bool _S962 = (fcptSceneUnchanged());
        float4  _S963 = make_float4 (_S954.f.x, _S954.f.y, _S954.f.z, 1.0f);
        bool _S964 = !_S962;
        if(_S964)
        {
            _S949 = _S947;
        }
        else
        {
            _S949 = false;
        }
        float4  to_current_0;
        if(_S949)
        {
            uint4  _S965 = (fcptTemporalShift((_S939), (0U)));
            float4  _S966 = asfloat_0(_S965);
            to_current_0 = _S966;
        }
        else
        {
            if(_S964)
            {
                Shift _S967 = temporalShiftAt_0(_S939, _S950, 0U);
                float4  _S968 = make_float4 (_S967.f.x, _S967.f.y, _S967.f.z, _S967.jac);
                to_current_0 = _S968;
            }
            else
            {
                to_current_0 = _S963;
            }
        }
        Domain own_1 = _S942;
        if(_S962)
        {
            _S949 = true;
        }
        else
        {
            bool _S969 = (fcptPreviousScenes());
            bool _S970 = !_S969;
            if(_S970)
            {
                _S949 = (_S946.w) > 0.0f;
            }
            else
            {
                _S949 = false;
            }
            if(_S949)
            {
                bool _S971 = (fcptStoredDomainInitial((_S939), (_S946.seed), (&own_1)));
                _S949 = _S971;
            }
            else
            {
                _S949 = false;
            }
            if(_S949)
            {
                Domain _S972 = (fcptPreviousDomain((_S950), (_S946.seed)));
                Domain _S973 = _S972;
                Domain _S974 = own_1;
                bool _S975 = sameDomain_0(&_S973, &_S974);
                _S949 = _S975;
            }
            else
            {
                _S949 = false;
            }
        }
        float4  _S976 = make_float4 (_S946.f.x, _S946.f.y, _S946.f.z, 1.0f);
        bool _S977 = !_S949;
        if(_S977)
        {
            _S949 = _S947;
        }
        else
        {
            _S949 = false;
        }
        float4  to_previous_0;
        if(_S949)
        {
            uint4  _S978 = (fcptTemporalShift((_S939), (1U)));
            float4  _S979 = asfloat_0(_S978);
            to_previous_0 = _S979;
        }
        else
        {
            if(_S977)
            {
                Shift _S980 = temporalShiftAt_0(_S939, _S950, 1U);
                float4  _S981 = make_float4 (_S980.f.x, _S980.f.y, _S980.f.z, _S980.jac);
                to_previous_0 = _S981;
            }
            else
            {
                to_previous_0 = _S976;
            }
        }
        float _S982 = resamplingTarget(_S946.f);
        float _S983 = resamplingTarget(_S954.f);
        Selection _S984 = (Selection{});
        Selection sel_6 = _S984;
        uint _S985 = (fcptFrame());
        uint _S986 = hash(_S985);
        uint _S987 = global_invocation_id_7.x;
        uint2  _S988 = (fcptRenderSize());
        uint _S989 = stream(_S986, _S987 + _S988.x * global_invocation_id_7.y);
        uint _S990 = stream(_S989, 194U);
        (&sel_6)->random_state = _S990;
        float _S991 = _S946.c * _S982;
        float4  _S992 = to_previous_0;
        float _S993 = resamplingTarget(float3 {_S992.x, _S992.y, _S992.z});
        float _S994 = _S991 / (_S991 + _S961 * _S993);
        float _S995 = _S961 * _S983;
        float4  _S996 = to_current_0;
        float3  _S997 = float3 {_S996.x, _S996.y, _S996.z};
        float _S998 = resamplingTarget(_S997);
        float _S999 = _S995 / (_S995 + _S946.c * _S998);
        float2  _S1000 = make_float2 (_S994, _S999);
        offerShifted(&sel_6, _S946, Shift_x24init_0(_S946.f, 1.0f), _S994);
        offerShifted(&sel_6, _S954, Shift_x24init_0(_S997, to_current_0.w), _S999);
        Reservoir _S1001 = finalize(sel_6, _S946.c + _S961);
        r_5 = _S1001;
    }
    else
    {
        r_5 = _S946;
    }
    fcptStoreReservoirTemporal((_S939), (r_5), ((&dom_5)->hit));
    return;
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S1002 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S1003 = make_int2 ((int)_S1002.x, (int)_S1002.y);
    float3  _S1004 = make_float3 (0.0f);
    float2  _S1005 = make_float2 (0.0f);
    FKHit _S1006 = Hit_x24init_0(_S1005, 0U, 0U, 0U, 0.0f);
    Domain _S1007 = Domain_x24init_0(_S1004, _S1004, &_S1006, 0.0f, 0.0f);
    Domain dom_6 = _S1007;
    bool _S1008 = (fcptCurrentDomain((_S1003), (&dom_6)));
    bool _S1009 = !_S1008;
    if(_S1009)
    {
        Reservoir _S1010 = (Reservoir{});
        fcptStoreReservoirInitial((_S1003), (_S1010), ((&dom_6)->hit));
        return;
    }
    uint _S1011 = (fcptFrame());
    uint _S1012 = hash(_S1011);
    uint _S1013 = global_invocation_id_8.x;
    uint2  _S1014 = (fcptRenderSize());
    uint _S1015 = stream(_S1012, _S1013 + _S1014.x * global_invocation_id_8.y);
    Selection _S1016 = (Selection{});
    Selection initial_0 = _S1016;
    uint _S1017 = stream(_S1015, 193U);
    (&initial_0)->random_state = _S1017;
    bool _S1018 = (fcptRestirUsed());
    bool _S1019 = !_S1018;
    (&initial_0)->sums = _S1019;
    uint _S1020 = stream(_S1015, 0U);
    (&(&initial_0)->r)->seed = _S1020;
    FKHit _S1021 = Hit_x24init_0(_S1005, 4294967295U, 0U, 0U, 0.0f);
    uint _S1022 = (fcptSamples());
    float _S1023 = 1.0f / float(_S1022);
    FKHit hit_2 = _S1021;
    uint i_20 = 0U;
    float3  seen_1 = _S1004;
    for(;;)
    {
        uint _S1024 = (fcptSamples());
        if(i_20 < _S1024)
        {
        }
        else
        {
            break;
        }
        Reservoir _S1025 = (Reservoir{});
        Reservoir r_6 = _S1025;
        uint _S1026 = stream(_S1015, i_20);
        (&r_6)->seed = _S1026;
        Domain path_0 = _S1007;
        bool _S1027 = (fcptStoredDomainInitial((_S1003), ((&r_6)->seed), (&path_0)));
        bool _S1028 = !_S1027;
        if(_S1028)
        {
            float3  _S1029 = (fcptMissed((_S1003), (path_0), (_S1023)));
            float3  seen_2 = seen_1 + _S1029;
            seen_1 = seen_2;
            uint i_21 = i_20 + 1U;
            i_20 = i_21;
            continue;
        }
        Domain _S1030 = path_0;
        Reservoir _S1031 = r_6;
        Shift _S1032 = passWalk_0(&_S1030, &_S1031, false, _S1023, &initial_0);
        bool _S1033 = ((&(&initial_0)->r)->seed) == ((&r_6)->seed);
        FKHit hit_3;
        if(_S1033)
        {
            FKHit _S1034 = (&path_0)->hit;
            hit_3 = _S1034;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_21 = i_20 + 1U;
        i_20 = i_21;
    }
    uint _S1035 = (fcptSamples());
    float3  seen_3 = seen_1 + (&initial_0)->glow / make_float3 (float(_S1035));
    if((&initial_0)->sums)
    {
        seen_1 = seen_3 + (&initial_0)->color;
    }
    else
    {
        seen_1 = seen_3;
    }
    fcptAddColor((_S1003), (make_float4 (seen_1.x, seen_1.y, seen_1.z, 1.0f)));
    Reservoir _S1036 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S1003), (_S1036), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_4, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S1037;
    (&_S1037)->none = none_0;
    (&_S1037)->pdf = pdf_4;
    (&_S1037)->origin = origin_5;
    (&_S1037)->smooth_n = smooth_n_3;
    (&_S1037)->start = start_6;
    return _S1037;
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
    Vertex _S1038;
    (&_S1038)->rough = rough_0;
    (&_S1038)->lobe = lobe_1;
    (&_S1038)->pdf = pdf_5;
    (&_S1038)->cos = cos_0;
    (&_S1038)->inside = inside_0;
    return _S1038;
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

static __device__ float3  flightWeight_0(float3  scatter_0, float3  extinction_0, float sigma_0, float distance_2, bool scatters_0)
{
    float3  _S1039 = exp_0((make_float3 (sigma_0) - extinction_0) * make_float3 (distance_2));
    float3  _S1040 = scatter_0 * _S1039 / make_float3 (sigma_0);
    float3  _S1041 = _slang_select(scatters_0, _S1040,_S1039);
    return _S1041;
}

static __device__ uint arrivalLobe_0(uint b_4, uint prev_lobe_0)
{
    bool _S1042 = b_4 > 0U;
    uint _S1043 = _slang_select(_S1042, prev_lobe_0,3U);
    return _S1043;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_2, uint lobe_2, bool surface_6, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S1044;
    (&_S1044)->extinction_behind = extinction_behind_0;
    (&_S1044)->extinction_front = extinction_front_0;
    (&_S1044)->fillings = fillings_0;
    (&_S1044)->side = side_0;
    (&_S1044)->depth = depth_2;
    (&_S1044)->lobe = lobe_2;
    (&_S1044)->surface = surface_6;
    (&_S1044)->length = length_2;
    (&_S1044)->width = width_1;
    (&_S1044)->own = *own_2;
    (&_S1044)->fiber = fiber_0;
    return _S1044;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S1045 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S1045)
    {
        return 0.07957746833562851f;
    }
    float _S1046 = g_0 * g_0;
    return (1.0f - _S1046) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S1046 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_10, float3  b_5)
{
    float3  _S1047 = a_10 / b_5;
    float3  _S1048 = make_float3 (0.0f);
    bool3  _S1049 = b_5 == _S1048;
    float3  _S1050 = _slang_select(_S1049, _S1048,_S1047);
    return _S1050;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_6)
{
    uint _S1051 = (1U << count_6) - 1U;
    return (e_2 & (~(_S1051 << offset_1))) | ((newbits_0 & _S1051) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_7, uint end_type_0, uint end_0, float3  f_6)
{
    Reservoir candidate_2 = r_7;
    uint _S1052 = insertBits_0(r_7.path, end_0, 0U, 5U);
    uint _S1053 = insertBits_0(_S1052, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S1053;
    (&candidate_2)->f = f_6;
    return candidate_2;
}

__device__ float survivalProbability(float3  throughput_0, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_0.x), ((F32_max((throughput_0.y), (throughput_0.z)))))) / density_1), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_10)
{
    Random _S1054 = pcg(random_state_10);
    Random _S1055 = pcg(_S1054.state);
    float _S1056 = 1.0f - 2.0f * _S1054.value;
    float _S1057 = (F32_sqrt(((F32_max((1.0f - _S1056 * _S1056), (0.0f))))));
    float _S1058 = 6.28318548202514648f * _S1055.value;
    return make_float3 (_S1057 * (F32_cos((_S1058))), _S1057 * (F32_sin((_S1058))), _S1056);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_10, uint random_state_11, float * pdf_6)
{
    bool _S1059 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1059)
    {
        *pdf_6 = 0.07957746833562851f;
        float3  _S1060 = isotropic_0(random_state_11);
        return _S1060;
    }
    Random _S1061 = pcg(random_state_11);
    Random _S1062 = pcg(_S1061.state);
    float _S1063 = g_1 * g_1;
    float _S1064 = 2.0f * g_1;
    float _S1065 = (1.0f - _S1063) / (1.0f - g_1 + _S1064 * _S1061.value);
    float _S1066 = clamp_1((1.0f + _S1063 - _S1065 * _S1065) / _S1064, -1.0f, 1.0f);
    float _S1067 = (F32_sqrt(((F32_max((1.0f - _S1066 * _S1066), (0.0f))))));
    float _S1068 = 6.28318548202514648f * _S1062.value;
    float _S1069 = phaseHG_0(g_1, _S1066);
    *pdf_6 = _S1069;
    float3  _S1070 = tangentToWorld(make_float3 (_S1067 * (F32_cos((_S1068))), _S1066, _S1067 * (F32_sin((_S1068)))), dir_10);
    float3  _S1071 = ((((_S1070)) * make_float3(rnorm3df(((_S1070)).x, ((_S1070)).y, ((_S1070)).z))));
    return _S1071;
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_1, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_1, float velvet_0, float3  toon_2, float dispersion_0)
{
    BSDFMaterial _S1072;
    (&_S1072)->albedo = albedo_1;
    (&_S1072)->emissive = emissive_0;
    (&_S1072)->roughness = roughness_0;
    (&_S1072)->metallic = metallic_0;
    (&_S1072)->transmission = transmission_0;
    (&_S1072)->ior = ior_0;
    (&_S1072)->absorption = absorption_0;
    (&_S1072)->specular_tint = specular_tint_0;
    (&_S1072)->specular_level = specular_level_0;
    (&_S1072)->translucent = translucent_0;
    (&_S1072)->sheen = sheen_2;
    (&_S1072)->sheen_roughness = sheen_roughness_0;
    (&_S1072)->anisotropy = anisotropy_0;
    (&_S1072)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1072)->tangent = tangent_1;
    (&_S1072)->velvet = velvet_0;
    (&_S1072)->toon = toon_2;
    (&_S1072)->dispersion = dispersion_0;
    return _S1072;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1073;
    (&_S1073)->scatter = scatter_1;
    (&_S1073)->extinction = extinction_1;
    (&_S1073)->g = g_2;
    return _S1073;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_10, bool skip_0, uint random_state_12, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1074;
    (&_S1074)->smooth_n = smooth_n_4;
    (&_S1074)->geometry_n = geometry_n_2;
    (&_S1074)->geometry_offset = geometry_offset_2;
    (&_S1074)->material = *material_10;
    (&_S1074)->skip = skip_0;
    (&_S1074)->random_state = random_state_12;
    (&_S1074)->coverage = coverage_0;
    (&_S1074)->encloses = encloses_0;
    (&_S1074)->volume = *volume_0;
    (&_S1074)->fills = fills_0;
    (&_S1074)->hair = hair_0;
    return _S1074;
}

static __device__ FKSurface emitting_0(FKSurface * surface_7, bool top_0)
{
    FKSurface lower_0 = *surface_7;
    float3  _S1075 = (&surface_7->material)->emissive;
    float3  _S1076 = make_float3 (0.0f);
    bool _S1077 = !top_0;
    float3  _S1078 = _slang_select(_S1077, _S1076,_S1075);
    (&(&lower_0)->material)->emissive = _S1078;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_8, float u_1)
{
    float _S1079 = surface_8->coverage;
    bool _S1080 = u_1 < _S1079;
    if(_S1080)
    {
        return *surface_8;
    }
    float3  _S1081 = make_float3 (0.0f);
    float3  _S1082 = make_float3 (1.0f);
    BSDFMaterial _S1083 = Material_x24init_0(_S1081, _S1081, 0.0f, 0.0f, 0.0f, 0.0f, _S1081, _S1082, 1.0f, _S1081, _S1081, 0.5f, 0.0f, 0.0f, _S1081, 0.0f, _S1081, 0.0f);
    BSDFMaterial material_11 = _S1083;
    (&material_11)->albedo = _S1082;
    (&material_11)->emissive = (&surface_8->material)->emissive;
    (&material_11)->transmission = 1.0f;
    (&material_11)->ior = 1.0f;
    (&material_11)->absorption = (&surface_8->material)->absorption;
    FKSurface through_0 = *surface_8;
    (&through_0)->material = material_11;
    return through_0;
}

__device__ float facingSign(float transmission_1, float3  face_0, float3  direction_0)
{
    bool _S1084 = transmission_1 > 0.0f;
    bool _S1085;
    if(_S1084)
    {
        _S1085 = true;
    }
    else
    {
        _S1085 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1086;
    if(_S1085)
    {
        _S1086 = 1.0f;
    }
    else
    {
        _S1086 = -1.0f;
    }
    return _S1086;
}

static __device__ bool arrivesBehind_0(float3  dir_11, float3  n_8)
{
    return (dot_0(dir_11, n_8)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_9, float3  dir_12)
{
    float3  _S1087 = surface_9->geometry_n;
    float _S1088 = facingSign((&surface_9->material)->transmission, surface_9->geometry_n, dir_12);
    FKSurface faced_0 = *surface_9;
    float3  _S1089 = surface_9->smooth_n * make_float3 (_S1088);
    (&faced_0)->smooth_n = _S1089;
    float3  _S1090 = _S1087 * make_float3 (_S1088);
    (&faced_0)->geometry_n = _S1090;
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
    float3  _S1091 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1091));
}

__device__ bool dispersive(BSDFMaterial material_12)
{
    bool _S1092 = (material_12.dispersion) > 0.0f;
    bool _S1093;
    if(_S1092)
    {
        _S1093 = (material_12.ior) != 1.0f;
    }
    else
    {
        _S1093 = false;
    }
    return _S1093;
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
        uint _S1094 = (low_1 + high_1 + 1U) / 2U;
        bool _S1095 = (WAVELENGTH_CDF_0[_S1094]) <= u_2;
        if(_S1095)
        {
            low_1 = _S1094;
        }
        else
        {
            uint _S1096 = _S1094 - 1U;
            high_1 = _S1096;
        }
    }
    uint _S1097 = low_1;
    float _S1098 = WAVELENGTH_CDF_0[low_1 + 1U] - WAVELENGTH_CDF_0[low_1];
    return make_float2 (0.37999999523162842f + 0.00499999988824129f * (float(low_1) + (u_2 - WAVELENGTH_CDF_0[_S1097]) / _S1098), _S1098 / 0.00499999988824129f);
}

__device__ static const FixedArray<float, 243>  WAVELENGTH_WEIGHTS_0 = { {
    0.00547470012679696f, -0.00465690018609166f, 0.03257500007748604f, 0.00934640038758516f, -0.00796370021998882f, 0.05577300116419792f, 0.01846100017428398f, -0.01579399965703487f, 0.11072999984025955f, 0.0416410006582737f, -0.03577499836683273f, 0.2513900101184845f, 0.09349299967288971f, -0.08071800321340561f, 0.56742000579833984f, 0.1585099995136261f, -0.13764999806880951f, 0.97018998861312866f, 0.30943000316619873f, -0.27083000540733337f, 1.91740000247955322f, 0.55217999219894409f, -0.48754000663757324f, 3.46889996528625488f, 0.95016998052597046f, -0.84802001714706421f, 6.09439992904663086f, 1.42110002040863037f, -1.28929996490478516f, 9.45199966430664062f, 1.73409998416900635f, -1.6062999963760376f, 12.12800025939941406f, 2.08030009269714355f, -1.98810005187988281f, 15.68700027465820312f, 2.20600008964538574f, -2.20120000839233398f, 18.47699928283691406f, 2.03040003776550293f, -2.17700004577636719f, 19.92700004577636719f, 1.63429999351501465f, -2.00340008735656738f, 20.86899948120117188f, 0.99410998821258545f, -1.62629997730255127f, 20.57799911499023438f, 0.20011000335216522f, -1.11409997940063477f, 19.72100067138671875f, -0.67960000038146973f, -0.45403000712394714f, 17.77599906921386719f, -1.61679995059967041f, 0.37860000133514404f, 14.71500015258789062f, -2.53410005569458008f, 1.27540004253387451f, 11.86499977111816406f, -3.39079999923706055f, 2.2146000862121582f, 9.17669963836669922f, -4.03749990463256836f, 3.0522000789642334f, 6.59509992599487305f, -4.61299991607666016f, 3.89779996871948242f, 4.64589977264404297f, -5.43039989471435547f, 5.0121002197265625f, 3.3199000358581543f, -6.37769985198974609f, 6.33809995651245117f, 2.29699993133544922f, -7.44140005111694336f, 7.91739988327026367f, 1.45389997959136963f, -8.38580036163330078f, 9.60109996795654297f, 0.66465997695922852f, -9.0167999267578125f, 11.23999977111816406f, -0.04403600096702576f, -9.17749977111816406f, 12.63199996948242188f, -0.58126997947692871f, -8.97550010681152344f, 13.91499996185302734f, -0.95730000734329224f, -8.25290012359619141f, 14.86200046539306641f, -1.24430000782012939f, -6.92129993438720703f, 15.03899955749511719f, -1.43069994449615479f, -5.29169988632202148f, 14.90900039672851562f, -1.55149996280670166f, -3.43219995498657227f, 14.70499992370605469f, -1.63569998741149902f, -1.27190005779266357f, 14.24400043487548828f, -1.67030000686645508f, 1.15170001983642578f, 13.32199954986572266f, -1.636199951171875f, 3.73889994621276855f, 12.21199989318847656f, -1.56920003890991211f, 6.43590021133422852f, 10.94699954986572266f, -1.47730004787445068f, 9.16440010070800781f, 9.54769992828369141f, -1.36399996280670166f, 12.02000045776367188f, 8.18799972534179688f, -1.25450003147125244f, 14.78699970245361328f, 6.74429988861083984f, -1.13110005855560303f, 16.72299957275390625f, 5.08780002593994141f, -0.96561002731323242f, 18.14299964904785156f, 3.57019996643066406f, -0.80725997686386108f, 19.91900062561035156f, 2.36269998550415039f, -0.69273000955581665f, 21.05500030517578125f, 1.31369996070861816f, -0.58597999811172485f, 21.3899993896484375f, 0.42390000820159912f, -0.48298001289367676f, 20.99300003051757812f, -0.23857000470161438f, -0.39412000775337219f, 19.82200050354003906f, -0.6866300106048584f, -0.31501999497413635f, 18.12000083923339844f, -0.9412500262260437f, -0.24890999495983124f, 15.7089996337890625f, -1.02020001411437988f, -0.19076000154018402f, 13.19799995422363281f, -0.98919999599456787f, -0.14401000738143921f, 11.23999977111816406f, -0.93347001075744629f, -0.11133000254631042f, 9.36649990081787109f, -0.83820998668670654f, -0.08524099737405777f, 7.41249990463256836f, -0.70064002275466919f, -0.06283199787139893f, 5.71229982376098633f, -0.56079000234603882f, -0.04586699977517128f, 4.42280006408691406f, -0.44653001427650452f, -0.03396600112318993f, 3.34489989280700684f, -0.34457001090049744f, -0.02482499927282333f, 2.49309992790222168f, -0.26017999649047852f, -0.01808100007474422f, 1.82239997386932373f, -0.1921599954366684f, -0.01296999957412481f, 1.29499995708465576f, -0.13766999542713165f, -0.00907570030540228f, 0.92928999662399292f, -0.09956400096416473f, -0.00641620019450784f, 0.61835998296737671f, -0.06671299785375595f, -0.00421149982139468f, 0.40211999416351318f, -0.04354599863290787f, -0.00271830009296536f, 0.2844499945640564f, -0.03087200038135052f, -0.00191440002527088f, 0.20672999322414398f, -0.02246100082993507f, -0.00138829997740686f, 0.15044000744819641f, -0.01634499989449978f, -0.00101030000951141f, 0.10942000150680542f, -0.01188699994236231f, -0.0007347899954766f, 0.07099699974060059f, -0.00771349994465709f, -0.00047679000999779f, 0.04539500176906586f, -0.00493190018460155f, -0.00030484999297187f, 0.03424099832773209f, -0.00372010003775358f, -0.00022995000472292f, 0.02557599917054176f, -0.00277870008721948f, -0.00017175999528263f, 0.01842200011014938f, -0.00200140010565519f, -0.0001237099932041f, 0.01316899992525578f, -0.00143079995177686f, -0.00008843900286593f, 0.00838890019804239f, -0.00091141002485529f, -0.00005633700129692f, 0.00537079991772771f, -0.00058350997278467f, -0.00003606799873523f, 0.00328280008397996f, -0.00035665999166667f, -0.00002204600059486f, 0.00196009990759194f, -0.00021296000340953f, -0.00001316300040344f, 0.00168939994182438f, -0.00018354000349063f, -0.00001134499962063f, 0.00141050003003329f, -0.00015325000276789f, -0.00000947250009631f, 0.00097123999148607f, -0.00010551999730524f, -6.52239987175562419e-06f, 0.00066868000430986f, -0.00007264900341397f, -4.49060007667867467e-06f
} };
__device__ float3  wavelengthWeights(float wavelength_0)
{
    float _S1099 = clamp_1((wavelength_0 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    uint _S1100 = (U32_min((uint(_S1099)), (79U)));
    uint _S1101 = 3U * _S1100;
    float3  _S1102 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1101], WAVELENGTH_WEIGHTS_0[_S1101 + 1U], WAVELENGTH_WEIGHTS_0[_S1101 + 2U]);
    float3  _S1103 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1101 + 3U], WAVELENGTH_WEIGHTS_0[_S1101 + 4U], WAVELENGTH_WEIGHTS_0[_S1101 + 5U]);
    return _S1102 + (_S1103 - _S1102) * make_float3 (_S1099 - float(_S1100));
}

__device__ float dispersedIor(float ior_1, float dispersion_1, float wavelength_1)
{
    float _S1104 = (ior_1 - 1.0f) * dispersion_1 / 1.90962409973144531f;
    float _S1105 = _S1104 * (1.0f / (wavelength_1 * wavelength_1) - 2.89662933349609375f);
    bool _S1106 = dispersion_1 > 0.0f;
    float _S1107 = _slang_select(_S1106, _S1105,0.0f);
    return ior_1 + _S1107;
}

__device__ float2  vertexEta(BSDFMaterial material_13, float n_dot_v_0)
{
    bool _S1108 = n_dot_v_0 < 0.0f;
    float _S1109 = _slang_select(_S1108, material_13.ior,1.0f);
    float _S1110 = _slang_select(_S1108, 1.0f,material_13.ior);
    return make_float2 (_S1109, _S1110);
}

__device__ bool neeDecision(BSDFMaterial material_14, float n_dot_v_1, float eta_i_5, float eta_o_5)
{
    float _S1111 = fresnel((F32_abs((n_dot_v_1))), eta_i_5, eta_o_5);
    float3  _S1112 = mix_0(make_float3 (_S1111), material_14.albedo, material_14.metallic);
    float _S1113 = rgb_to_greyscale(_S1112);
    float _S1114 = (F32_max(((1.0f - _S1113) * (1.0f - material_14.metallic) * (1.0f - material_14.transmission)), (0.0f)));
    bool _S1115 = _S1114 > 0.03999999910593033f;
    bool _S1116;
    if(_S1115)
    {
        _S1116 = true;
    }
    else
    {
        _S1116 = (material_14.roughness) > 0.20000000298023224f;
    }
    return _S1116;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_15)
{
    float _S1117 = rgb_to_greyscale(material_15->translucent);
    return _S1117 > 0.0f;
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
    MediumSides _S1118;
    (&_S1118)->behind = *behind_0;
    (&_S1118)->front = *front_0;
    (&_S1118)->fillings = fillings_1;
    (&_S1118)->face = face_1;
    return _S1118;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_10, FKMedium * medium_0, uint filling_0, float3  dir_13, FKMedium * outside_0)
{
    float3  _S1119 = surface_10->geometry_n;
    MediumSides _S1120 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_10->geometry_n);
    MediumSides sides_0 = _S1120;
    bool _S1121 = surface_10->encloses;
    if(_S1121)
    {
        (&sides_0)->behind = surface_10->volume;
        *&((&(&sides_0)->fillings)->x) = surface_10->fills;
        bool _S1122 = (dot_0(dir_13, _S1119)) > 0.0f;
        if(_S1122)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_11, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_14, uint depth_3, uint lobe_3, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1123 = surface_11->geometry_n;
    ShadowContext _S1124 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_11->geometry_n, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
    bool _S1125 = surface_11->encloses;
    ShadowContext context_4;
    if(_S1125)
    {
        FKSurface faced_1 = *surface_11;
        float3  _S1126 = - _S1123;
        float3  _S1127 = _slang_select(turned_0, _S1126,_S1123);
        (&faced_1)->geometry_n = _S1127;
        FKMedium _S1128 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1129 = faced_1;
        FKMedium _S1130 = _S1128;
        MediumSides _S1131 = mediumSides_0(&_S1129, &_S1130, filling_1, dir_14, outside_1);
        ShadowContext _S1132 = ShadowContext_x24init_0(_S1131.behind.extinction, _S1131.front.extinction, _S1131.fillings, _S1123, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
        if(turned_0)
        {
            uint2  _S1133 = _S1131.fillings;
            ShadowContext _S1134 = ShadowContext_x24init_0(_S1131.front.extinction, _S1131.behind.extinction, uint2 {_S1133.y, _S1133.x}, _S1123, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
            context_4 = _S1134;
        }
        else
        {
            context_4 = _S1132;
        }
    }
    else
    {
        context_4 = _S1124;
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

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_8, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_3, BSDFMaterial * material_16, float eta_i_6, float eta_o_6, bool competing_1, uint random_state_13)
{
    float3  _S1135 = light_2->dir;
    bool _S1136 = (dot_0(geometry_n_3, - in_dir_8) * dot_0(geometry_n_3, light_2->dir)) <= 0.0f;
    FixedArray<float3 , 5>  throughputs_1;
    FixedArray<float, 5>  pdfs_4;
    float3  _S1137 = BSDF(in_dir_8, _S1135, smooth_n_5, *material_16, eta_i_6, eta_o_6, _S1136, random_state_13, &throughputs_1, &pdfs_4);
    bool _S1138 = !competing_1;
    bool _S1139;
    if(_S1138)
    {
        _S1139 = true;
    }
    else
    {
        _S1139 = (light_2->density) == 0.0f;
    }
    if(_S1139)
    {
        return _S1137 * light_2->radiance;
    }
    float3  _S1140 = make_float3 (0.0f);
    uint i_26 = 0U;
    float3  weighted_0 = _S1140;
    for(;;)
    {
        if(i_26 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S1141 = (pdfs_4[i_26]) > 0.0f;
        if(_S1141)
        {
            float _S1142 = light_2->density;
            float _S1143 = pdfs_4[i_26] / light_2->density;
            float3  weighted_1 = weighted_0 + throughputs_1[i_26] * make_float3 (pdfs_4[i_26]) / make_float3 (_S1142 * (1.0f + _S1143 * _S1143));
            weighted_0 = weighted_1;
        }
        uint i_27 = i_26 + 1U;
        i_26 = i_27;
    }
    return weighted_0 * light_2->radiance * make_float3 (light_2->density);
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_1, uint random_state_14, bool refracted_3, uint lobe_4, float pdf_7)
{
    SampleBSDF _S1144;
    (&_S1144)->unit_direction = unit_direction_1;
    (&_S1144)->throughput = throughput_1;
    (&_S1144)->random_state = random_state_14;
    (&_S1144)->refracted = refracted_3;
    (&_S1144)->lobe = lobe_4;
    (&_S1144)->pdf = pdf_7;
    return _S1144;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  v_9, float3  n_i_13, float n_i_dot_v_3, BSDFMaterial material_17, Weights w_14, uint random_state_15)
{
    float3  _S1145 = make_float3 (1.0f);
    SampleBSDF _S1146 = SampleBSDF_x24init_0(_S1145, _S1145, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S1146;
    Random _S1147 = pcg(random_state_15);
    Random _S1148 = pcg(_S1147.state);
    (&sample_1)->random_state = _S1148.state;
    float _S1149 = _S1147.value;
    float _S1150 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1149 * _S1149))))));
    float _S1151 = 6.28318548202514648f * _S1148.value;
    float3  _S1152 = tangentToWorld(make_float3 (_S1150 * (F32_cos((_S1151))), _S1147.value, _S1150 * (F32_sin((_S1151)))), n_i_13);
    (&sample_1)->unit_direction = _S1152;
    (&sample_1)->lobe = 4U;
    float3  _S1153 = sheenVelvetBSDF((&sample_1)->unit_direction, v_9, n_i_13, material_17, w_14);
    (&sample_1)->throughput = _S1153;
    float _S1154 = sheenVelvetPDF(_S1147.value, n_i_dot_v_3, w_14);
    (&sample_1)->pdf = _S1154;
    return sample_1;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1155 = (F32_sqrt((random_1_0)));
    float _S1156 = 6.28318548202514648f * random_2_0;
    float _S1157 = _S1155 * (F32_cos((_S1156)));
    float _S1158 = _S1155 * (F32_sin((_S1156)));
    float _S1159 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1157 * _S1157 - _S1158 * _S1158))))));
    return make_float3 (_S1157, _S1159, _S1158);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_3, float3  n_i_14, float n_i_dot_v_4, BSDFMaterial material_18, Weights w_15, uint random_state_16)
{
    float3  _S1160 = make_float3 (1.0f);
    SampleBSDF _S1161 = SampleBSDF_x24init_0(_S1160, _S1160, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S1161;
    Random _S1162 = pcg(random_state_16);
    Random _S1163 = pcg(_S1162.state);
    (&sample_2)->random_state = _S1163.state;
    float3  _S1164 = sampleCosWeightedHemisphere(_S1162.value, _S1163.value);
    float _S1165 = translucentShare(material_18);
    bool _S1166 = u_3 < (w_15.p_diffuse * _S1165);
    float _S1167 = _S1164.y;
    float _S1168 = - _S1167;
    float _S1169 = _slang_select(_S1166, _S1168,_S1167);
    float3  _S1170 = tangentToWorld(make_float3 (_S1164.x, _S1169, _S1164.z), n_i_14);
    (&sample_2)->unit_direction = _S1170;
    (&sample_2)->refracted = _S1166;
    (&sample_2)->lobe = 0U;
    float3  _S1171 = diffuseBSDF((&sample_2)->unit_direction, n_i_14, material_18, w_15);
    (&sample_2)->throughput = _S1171;
    float _S1172 = diffusePDF(_S1169, n_i_dot_v_4, material_18, w_15);
    (&sample_2)->pdf = _S1172;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF toonSample(float3  n_i_15, ToonProfile profile_3, Weights w_16, uint random_state_17)
{
    float3  _S1173 = make_float3 (1.0f);
    SampleBSDF _S1174 = SampleBSDF_x24init_0(_S1173, _S1173, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S1174;
    Random _S1175 = pcg(random_state_17);
    Random _S1176 = pcg(_S1175.state);
    (&sample_3)->random_state = _S1176.state;
    float _S1177 = _S1175.value * profile_3.norm / 6.28318548202514648f;
    float t_23;
    if(profile_3.glossy)
    {
        t_23 = (F32_acos((clamp_1(1.0f - _S1177, -1.0f, 1.0f))));
    }
    else
    {
        t_23 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1177)))), (1.0f))))));
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
        float _S1178 = toonP(t_23, profile_3.a, profile_3.s);
        float _S1179 = _S1178 * (F32_sin((t_23)));
        float _S1180;
        if(profile_3.glossy)
        {
            _S1180 = 1.0f;
        }
        else
        {
            _S1180 = (F32_cos((t_23)));
        }
        float _S1181 = _S1179 * _S1180;
        float _S1182 = toonIntegral(t_23, profile_3.a, profile_3.s, profile_3.glossy);
        float _S1183 = (_S1182 - _S1177) / _S1181;
        bool _S1184 = _S1181 > 0.0f;
        float _S1185 = _slang_select(_S1184, _S1183,0.0f);
        float _S1186 = clamp_1(t_23 - _S1185, 0.0f, profile_3.b);
        int k_1 = k_0 + int(1);
        t_23 = _S1186;
        k_0 = k_1;
    }
    float _S1187 = 6.28318548202514648f * _S1176.value;
    float _S1188 = (F32_sin((t_23)));
    float3  _S1189 = tangentToWorld(make_float3 (_S1188 * (F32_cos((_S1187))), (F32_cos((t_23))), _S1188 * (F32_sin((_S1187)))), profile_3.axis);
    (&sample_3)->unit_direction = _S1189;
    bool _S1190 = (dot_0(n_i_15, (&sample_3)->unit_direction)) < 0.0f;
    (&sample_3)->refracted = _S1190;
    (&sample_3)->lobe = 6U;
    float3  _S1191 = toonBSDF((&sample_3)->unit_direction, n_i_15, profile_3, w_16);
    (&sample_3)->throughput = _S1191;
    float _S1192 = toonPDF((&sample_3)->unit_direction, n_i_15, profile_3, w_16);
    (&sample_3)->pdf = _S1192;
    return sample_3;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_16, float alpha_8, AnisotropicFrame frame_6, BSDFMaterial material_19, Weights w_17, float pdf_h_3, float eta_i_7, float eta_o_7, uint random_state_18)
{
    float3  _S1193 = make_float3 (1.0f);
    SampleBSDF _S1194 = SampleBSDF_x24init_0(_S1193, _S1193, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S1194;
    (&sample_4)->unit_direction = w_17.refracted;
    (&sample_4)->random_state = random_state_18;
    (&sample_4)->refracted = true;
    (&sample_4)->lobe = 1U;
    float3  _S1195 = refractBSDF((&sample_4)->unit_direction, n_i_16, alpha_8, frame_6, material_19, w_17);
    (&sample_4)->throughput = _S1195;
    float _S1196 = refractPDF(dot_0((&sample_4)->unit_direction, ggx_n_3), pdf_h_3, w_17, eta_i_7, eta_o_7);
    (&sample_4)->pdf = _S1196;
    return sample_4;
}

static __device__ float3  reflect_0(float3  i_28, float3  n_9)
{
    return i_28 - make_float3 (2.0f * dot_0(n_9, i_28)) * n_9;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_9, float3  ggx_n_4, float3  n_i_17, float alpha_9, AnisotropicFrame frame_7, Weights w_18, float pdf_h_4, uint random_state_19)
{
    float3  _S1197 = make_float3 (1.0f);
    SampleBSDF _S1198 = SampleBSDF_x24init_0(_S1197, _S1197, 0U, false, 0U, 0.0f);
    SampleBSDF sample_5 = _S1198;
    float3  _S1199 = reflect_0(in_dir_9, ggx_n_4);
    float3  _S1200 = ((((_S1199)) * make_float3(rnorm3df(((_S1199)).x, ((_S1199)).y, ((_S1199)).z))));
    (&sample_5)->unit_direction = _S1200;
    (&sample_5)->random_state = random_state_19;
    (&sample_5)->lobe = 2U;
    float3  _S1201 = reflectBSDF((&sample_5)->unit_direction, n_i_17, alpha_9, frame_7, w_18);
    (&sample_5)->throughput = _S1201;
    float _S1202 = reflectPDF(pdf_h_4, w_18);
    (&sample_5)->pdf = _S1202;
    return sample_5;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_10, float3  n_10, BSDFMaterial material_20, float eta_i_8, float eta_o_8, uint random_init_0, float2  screen_space_0)
{
    uint random_state_20 = random_init_0;
    float3  _S1203 = negate_0(in_dir_10);
    float _S1204 = dot_0(n_10, _S1203);
    float _S1205 = sign_0(_S1204);
    float3  n_i_18 = n_10 * make_float3 (_S1205);
    float _S1206 = (F32_abs((_S1204)));
    float _S1207 = material_20.roughness;
    float _S1208 = _S1207 * _S1207;
    AnisotropicFrame _S1209 = anisotropicFrame(material_20, n_i_18);
    SheenProfile _S1210 = sheenProfile(_S1203, n_i_18, material_20);
    float3  _S1211 = sampleHalfVector(_S1203, n_i_18, _S1208, _S1209, &random_state_20);
    Weights _S1212 = lobeWeights(in_dir_10, _S1203, n_i_18, _S1211, _S1209, _S1210, material_20, eta_i_8, eta_o_8);
    Random _S1213 = pcg(random_state_20);
    random_state_20 = _S1213.state;
    bool _S1214 = (_S1213.value) < (_S1212.p_sheen_velvet);
    if(_S1214)
    {
        SampleBSDF _S1215 = sheenVelvetSample(_S1203, n_i_18, _S1206, material_20, _S1212, random_state_20);
        return _S1215;
    }
    float _S1216 = _S1213.value - _S1212.p_sheen_velvet;
    bool _S1217 = _S1216 < (_S1212.p_diffuse);
    if(_S1217)
    {
        SampleBSDF _S1218 = diffuseSample(_S1216, n_i_18, _S1206, material_20, _S1212, random_state_20);
        return _S1218;
    }
    bool _S1219 = _S1216 < (_S1212.p_diffuse + _S1212.p_toon);
    if(_S1219)
    {
        ToonProfile _S1220 = toonProfile(_S1203, n_i_18, material_20);
        SampleBSDF _S1221 = toonSample(n_i_18, _S1220, _S1212, random_state_20);
        return _S1221;
    }
    float _S1222 = vndfPDF(_S1203, _S1211, n_i_18, _S1206, _S1208, _S1209, _S1212.v_dot_h);
    bool _S1223 = (_S1216 - _S1212.p_toon) < (_S1212.p_diffuse + _S1212.p_refract);
    if(_S1223)
    {
        SampleBSDF _S1224 = refractSample(_S1211, n_i_18, _S1208, _S1209, material_20, _S1212, _S1222, eta_i_8, eta_o_8, random_state_20);
        return _S1224;
    }
    SampleBSDF _S1225 = reflectSample(in_dir_10, _S1211, n_i_18, _S1208, _S1209, _S1212, _S1222, random_state_20);
    return _S1225;
}

static __device__ bool boundsVolume_0(FKSurface * surface_12)
{
    return surface_12->encloses;
}

static __device__ Shift walk_0(Domain * dom_7, Reservoir * r_8, bool replay_1, float scale_3, Selection * sel_7)
{
    float spread_1;
    bool turned_1;
    bool is_inside_6;
    bool viewed_0;
    bool _S1226;
    bool _S1227;
    float density_2;
    float threshold_0;
    float width_3;
    float sky_pdf_0;
    float wavelength_2;
    uint b_6;
    uint layer_0;
    float3  throughput_2;
    float3  chain_throughput_0;
    TreeSample light_3;
    int _S1228;
    Shift ended_0;
    float density_3;
    float spread_2;
    float width_4;
    float sky_pdf_1;
    float spread_3;
    float width_5;
    uint b_7;
    float3  _S1229 = make_float3 (0.0f);
    Shift _S1230 = Shift_x24init_0(_S1229, 0.0f);
    uint _S1231 = r_8->path;
    uint _S1232 = extractBits_0(r_8->path, 0U, 5U);
    uint _S1233 = extractBits_0(_S1231, 5U, 5U);
    uint _S1234 = extractBits_0(_S1231, 10U, 2U);
    uint _S1235 = extractBits_0(_S1231, 12U, 3U);
    bool passes_0;
    if(replay_1)
    {
        bool _S1236 = _S1235 >= 3U;
        uint _S1237 = _slang_select(_S1236, 1U,0U);
        uint _S1238 = _S1232 + _S1237;
        uint _S1239 = (fcptMaxBounces());
        passes_0 = _S1238 > _S1239;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1230;
    }
    uint _S1240 = _S1233 - 1U;
    bool _S1241 = _S1235 == 3U;
    uint _S1242 = _slang_select(_S1241, 1U,0U);
    uint _S1243 = _S1232 + _S1242;
    bool _S1244 = _S1234 == 0U;
    uint _S1245 = _slang_select(_S1244, _S1243,_S1240);
    FKHit _S1246 = (fcptReservoirHit((*r_8)));
    float3  _S1247 = dom_7->x0;
    float3  _S1248 = dom_7->x1 - dom_7->x0;
    float3  _S1249 = ((((_S1248)) * make_float3(rnorm3df(((_S1248)).x, ((_S1248)).y, ((_S1248)).z))));
    FKRay _S1250 = Ray_x24init_0(dom_7->x1, _S1249);
    FKRay ray_2 = _S1250;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1229;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_1 = throughput_3;
    float3  glowed_0 = _S1229;
    float3  extinction_in_0 = _S1229;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1251 = dom_7->spread;
    float _S1252 = dom_7->width;
    float _S1253 = length_0(_S1248);
    NEEVertex _S1254 = NEEVertex_x24init_0(true, 0.0f, _S1229, _S1229, _S1229);
    NEEVertex nee_vertex_0 = _S1254;
    Vertex _S1255 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S1255;
    Reservoir _S1256 = (Reservoir{});
    Reservoir chain_0 = _S1256;
    uint _S1257 = r_8->seed;
    (&chain_0)->seed = r_8->seed;
    (&ray_2)->origin = _S1247;
    (&hit_4)->distance = _S1253;
    FKMedium _S1258 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1259 = filling_2;
    bool _S1260 = (fcptVaryingUsed());
    uint _S1261 = _slang_select(_S1260, _S1259,4294967295U);
    filling_2 = _S1261;
    scatter_in_0 = _S1258.scatter;
    extinction_in_0 = _S1258.extinction;
    g_in_0 = _S1258.g;
    Reservoir _S1262 = chain_0;
    uint _S1263 = filling_2;
    for(;;)
    {
        bool _S1264 = (fcptVaryingUsed());
        if(_S1264)
        {
            passes_0 = _S1263 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1265 = (fcptMajorant((_S1263)));
            spread_1 = _S1265;
        }
        else
        {
            spread_1 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_1)
        {
            turned_1 = 4294967295U == _S1245;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1234 == 1U;
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
            ended_0 = _S1230;
            sky_pdf_0 = 0.0f;
            spread_1 = _S1251;
            width_3 = _S1252;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_6 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1266 = (&prev_0)->rough;
        if(_S1266)
        {
            turned_1 = !(spread_1 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S1267 = stream(_S1257, 384U);
        uint tracking_0 = _S1267;
        weight_1 = throughput_3;
        glowed_0 = _S1229;
        b_6 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        threshold_0 = _S1251;
        width_3 = _S1252;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1228 = int(1);
                break;
            }
            uint _S1268 = b_6 + 320U;
            bool _S1269 = b_6 == 4294967295U;
            uint _S1270 = _slang_select(_S1269, 384U,_S1268);
            uint _S1271 = stream(_S1257, _S1270);
            Random _S1272 = pcg(_S1271);
            float _S1273 = - (F32_log((1.0f - _S1272.value))) / spread_1;
            if(passes_0)
            {
                float3  _S1274 = (&ray_2)->origin;
                float3  _S1275 = (&ray_2)->unit_direction;
                float _S1276 = (&hit_4)->distance;
                uint _S1277 = _slang_select(_S1269, 0U,b_6);
                uint _S1278 = (&prev_0)->lobe;
                uint _S1279 = _slang_select(_S1269, 3U,_S1278);
                float _S1280 = (fcptTrackMedium((_S1263), (_S1274), (_S1275), (_S1276), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1277), (_S1279), (_S1269)));
                wavelength_2 = _S1280;
            }
            else
            {
                wavelength_2 = _S1273;
            }
            bool _S1281 = !(wavelength_2 < ((&hit_4)->distance));
            if(_S1281)
            {
                _S1228 = int(1);
                break;
            }
            if(passes_0)
            {
                turned_1 = !replay_1;
            }
            else
            {
                turned_1 = false;
            }
            if(turned_1)
            {
                float3  _S1282 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S1283 = sel_7->glow + _S1282;
                sel_7->glow = _S1283;
            }
            else
            {
            }
            glowed_0 = _S1229;
            uint b_8 = b_6 + 1U;
            float3  _S1284 = (&ray_2)->origin + make_float3 (wavelength_2) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1284;
            float3  _S1285 = flightWeight_0(scatter_in_0, extinction_in_0, spread_1, wavelength_2, true);
            float3  _S1286 = weight_1;
            float3  _S1287 = _slang_select(passes_0, _S1286,_S1285);
            float3  throughput_4 = throughput_2 * _S1287;
            uint _S1288 = stream(_S1257, b_8 + 320U);
            tracking_0 = _S1288;
            weight_1 = throughput_3;
            float width_6 = width_3 + threshold_0 * wavelength_2;
            float _S1289 = threshold_0 + 3.14159274101257324f;
            bool _S1290 = !replay_1;
            if(_S1290)
            {
                is_inside_6 = true;
            }
            else
            {
                bool _S1291 = b_8 == _S1245;
                if(_S1291)
                {
                    is_inside_6 = !passes_0;
                }
                else
                {
                    is_inside_6 = false;
                }
            }
            TreeSample _S1292 = TreeSample_x24init_0(_S1229, _S1229, 0.0f, 0U);
            if(is_inside_6)
            {
                float3  _S1293 = (&ray_2)->origin;
                float3  _S1294 = (&ray_2)->unit_direction;
                float3  _S1295 = (&ray_2)->unit_direction;
                uint _S1296 = stream(_S1257, b_8 + 64U);
                float3  _S1297 = extinction_in_0;
                float3  _S1298 = extinction_in_0;
                uint2  _S1299 = make_uint2 (_S1263);
                float3  _S1300 = (&ray_2)->unit_direction;
                uint _S1301 = arrivalLobe_0(b_8, (&prev_0)->lobe);
                FKHit _S1302 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1303 = _S1302;
                ShadowContext _S1304 = ShadowContext_x24init_0(_S1297, _S1298, _S1299, _S1300, b_8, _S1301, false, wavelength_2, width_6, &_S1303, false);
                ShadowContext _S1305 = _S1304;
                TreeSample _S1306 = sampleLightTree_0(_S1293, _S1294, _S1295, 0.0f, true, _S1296, &_S1305);
                light_3 = _S1306;
            }
            else
            {
                light_3 = _S1292;
            }
            float _S1307 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S1308 = (fcptMaxBounces());
            bool _S1309 = b_8 < _S1308;
            if(_S1309)
            {
                viewed_0 = (light_3.density) > 0.0f;
            }
            else
            {
                viewed_0 = false;
            }
            float _S1310 = _slang_select(viewed_0, _S1307,0.0f);
            float3  _S1311 = throughput_4 * light_3.radiance;
            float _S1312 = powerHeuristic(light_3.density, _S1310);
            float3  _S1313 = _S1311 * make_float3 (_S1307 * _S1312);
            float3  _S1314 = _slang_select(is_inside_6, _S1313,_S1229);
            if(replay_1)
            {
                _S1226 = b_8 == _S1245;
            }
            else
            {
                _S1226 = false;
            }
            if(_S1226)
            {
                bool _S1315 = _S1234 == 2U;
                if(_S1315)
                {
                    float _S1316 = resamplingTarget(_S1314);
                    passes_0 = _S1316 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1317 = Shift_x24init_0(_S1314, 1.0f);
                    _S1228 = int(0);
                    ended_0 = _S1317;
                    spread_1 = _S1289;
                    wavelength_2 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_8;
                    break;
                }
                _S1228 = int(0);
                ended_0 = _S1230;
                spread_1 = _S1289;
                wavelength_2 = width_6;
                chain_throughput_0 = throughput_4;
                layer_0 = b_8;
                break;
            }
            if(_S1290)
            {
                Reservoir candidate_3 = _S1262;
                uint _S1318 = extractBits_0(_S1262.path, 10U, 2U);
                bool _S1319 = _S1318 == 1U;
                if(_S1319)
                {
                    float3  _S1320 = safeDivide(_S1314, _S1229);
                    (&candidate_3)->radiance = _S1320;
                }
                else
                {
                    uint _S1321 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                    uint _S1322 = insertBits_0(_S1321, 2U, 10U, 2U);
                    (&candidate_3)->path = _S1322;
                }
                Reservoir _S1323 = withEnd(candidate_3, 0U, b_8, _S1314);
                offer(sel_7, _S1323, _S1314 * make_float3 (scale_3) / make_float3 (density_2));
                float _S1324 = survivalProbability(abs_0(throughput_4), density_2);
                uint _S1325 = stream(_S1257, b_8 + 128U);
                Random _S1326 = pcg(_S1325);
                bool _S1327 = _S1324 < (_S1326.value);
                if(_S1327)
                {
                    _S1227 = true;
                }
                else
                {
                    uint _S1328 = (fcptMaxBounces());
                    _S1227 = b_8 >= _S1328;
                }
                if(_S1227)
                {
                    _S1228 = int(0);
                    ended_0 = _S1230;
                    spread_1 = _S1289;
                    wavelength_2 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_8;
                    break;
                }
                float _S1329 = density_2 * _S1324;
                density_2 = _S1329;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1330 = stream(_S1257, b_8);
            float3  _S1331 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1330, &phase_pdf_0);
            (&ray_2)->unit_direction = _S1331;
            NEEVertex _S1332 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S1229, (&ray_2)->origin);
            nee_vertex_0 = _S1332;
            Vertex _S1333 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, false);
            prev_0 = _S1333;
            float _S1334 = (&prev_0)->pdf;
            FKRay _S1335 = ray_2;
            FKHit _S1336 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1337 = (fcptTraverseInstanceBVH((_S1335), (true), (4.294967296e+09f), (false), (_S1336), (false)));
            hit_4 = _S1337;
            b_6 = b_8;
            throughput_2 = throughput_4;
            threshold_0 = _S1289;
            width_3 = width_6;
            sky_pdf_0 = _S1334;
        }
        if(_S1228 != int(1))
        {
            width_3 = wavelength_2;
            throughput_2 = chain_throughput_0;
            b_6 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1230;
        spread_1 = threshold_0;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1338 = b_6 == 4294967295U;
    bool _S1339 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1339)
    {
        bool _S1340 = !(&nee_vertex_0)->none;
        float _S1341 = _slang_select(_S1340, sky_pdf_0,0.0f);
        float _S1342 = escapeWeight_0(_S1341, (&ray_2)->unit_direction);
        float3  _S1343 = environment_0((&ray_2)->unit_direction, b_6, (&prev_0)->lobe);
        float3  _S1344 = throughput_2 * _S1343;
        if(replay_1)
        {
            bool _S1345 = b_6 == _S1245;
            if(_S1345)
            {
                passes_0 = _S1234 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S1344 * make_float3 (_S1342) / make_float3 (r_8->jac), density_2 / r_8->jac);
            }
            if(_S1244)
            {
                passes_0 = _S1241;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_6 == _S1232;
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
                return Shift_x24init_0(_S1344 * make_float3 (_S1342), 1.0f);
            }
            return _S1230;
        }
        Reservoir candidate_4 = chain_0;
        uint _S1346 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1347 = _S1346 == 1U;
        if(_S1347)
        {
            uint _S1348 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S1349 = _S1348 == b_6;
            float _S1350 = _slang_select(_S1349, 1.0f,_S1342);
            float3  _S1351 = safeDivide(_S1344 * make_float3 (_S1350), _S1229);
            (&candidate_4)->radiance = _S1351;
        }
        else
        {
            bool _S1352 = (&prev_0)->rough;
            if(_S1352)
            {
                uint _S1353 = insertBits_0(0U, b_6 + 1U, 5U, 5U);
                uint _S1354 = insertBits_0(_S1353, 3U, 10U, 2U);
                uint _S1355 = insertBits_0(_S1354, (&prev_0)->lobe, 15U, 3U);
                bool _S1356 = (&prev_0)->inside;
                uint _S1357 = _slang_select(_S1356, 1U,0U);
                uint _S1358 = insertBits_0(_S1355, _S1357, 22U, 1U);
                (&candidate_4)->path = _S1358;
                (&candidate_4)->jac = (&prev_0)->pdf;
                (&candidate_4)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S1359 = _S1344 * make_float3 (_S1342);
        Reservoir _S1360 = withEnd(candidate_4, 3U, b_6, _S1359);
        offer(sel_7, _S1360, _S1359 * make_float3 (scale_3) / make_float3 (density_2));
        return _S1230;
    }
    float3  _S1361 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S1361;
    bool _S1362 = (fcptVaryingUsed());
    if(_S1362)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1363 = !replay_1;
        if(_S1363)
        {
            float3  _S1364 = throughput_2 * glowed_0 / make_float3 (density_2);
            float3  _S1365 = sel_7->glow + _S1364;
            sel_7->glow = _S1365;
        }
        float3  _S1366 = throughput_2 * weight_1;
        throughput_2 = _S1366;
    }
    else
    {
        float3  _S1367 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
        float3  _S1368 = throughput_2 * _S1367;
        throughput_2 = _S1368;
    }
    float _S1369 = width_3 + spread_1 * (&hit_4)->distance;
    uint _S1370 = b_6 + 1U;
    b_6 = _S1370;
    layer_0 = 0U;
    width_3 = _S1369;
    passes_0 = false;
    threshold_0 = 0.0f;
    turned_1 = false;
    is_inside_6 = false;
    wavelength_2 = 0.0f;
    chain_throughput_0 = _S1229;
    float3  reconnection_0 = _S1229;
    viewed_0 = _S1338;
    for(;;)
    {
        bool _S1371 = ((&hit_4)->is_point_light) == 1U;
        if(replay_1)
        {
            _S1226 = _S1234 == 1U;
        }
        else
        {
            _S1226 = false;
        }
        if(_S1226)
        {
            _S1227 = b_6 == _S1233;
        }
        else
        {
            _S1227 = false;
        }
        bool _S1372;
        if(_S1227)
        {
            bool _S1373 = ((&hit_4)->instance_index) != (_S1246.instance_index);
            if(_S1373)
            {
                _S1372 = true;
            }
            else
            {
                _S1372 = ((&hit_4)->triangle_index) != (_S1246.triangle_index);
            }
        }
        else
        {
            _S1372 = false;
        }
        if(_S1372)
        {
            return _S1230;
        }
        FKMedium _S1374 = Medium_x24init_0(_S1229, _S1229, 0.0f);
        BSDFMaterial _S1375 = Material_x24init_0(_S1229, _S1229, 0.0f, 0.0f, 0.0f, 0.0f, _S1229, throughput_3, 1.0f, _S1229, _S1229, 0.5f, 0.0f, 0.0f, _S1229, 0.0f, _S1229, 0.0f);
        FKMedium _S1376 = _S1374;
        FKSurface _S1377 = Surface_x24init_0(_S1229, _S1229, 0.0f, &_S1375, false, 0U, 1.0f, false, &_S1376, 4294967295U, _S1229);
        bool _S1378 = !_S1371;
        bool scatter_2;
        bool is_inside_7;
        float geometry_density_0;
        float3  throughput_5;
        FKSurface surface_13;
        if(_S1378)
        {
            uint _S1379 = stream(_S1257, b_6);
            uint _S1380 = arrivalLobe_0(b_6, (&prev_0)->lobe);
            FKSurface _S1381 = (fcptSurfaceAtPath((hit_4), ((&ray_2)->origin), (_S1379), (width_3), (layer_0), (b_6), (_S1380), ((&ray_2)->unit_direction)));
            bool _S1382 = !passes_0;
            FKSurface _S1383 = _S1381;
            FKSurface _S1384 = emitting_0(&_S1383, _S1382);
            uint _S1385 = stream(_S1257, b_6 + 256U);
            Random _S1386 = pcg(_S1385);
            FKSurface _S1387 = _S1384;
            FKSurface _S1388 = uncovered_0(&_S1387, _S1386.value);
            float _S1389 = facingSign(_S1388.material.transmission, _S1388.geometry_n, (&ray_2)->unit_direction);
            bool _S1390 = _S1389 < 0.0f;
            bool _S1391 = (_S1388.material.transmission) > 0.0f;
            if(_S1391)
            {
                bool _S1392 = arrivesBehind_0((&ray_2)->unit_direction, _S1388.geometry_n);
                scatter_2 = _S1392;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1393 = _S1388;
            FKSurface _S1394 = facingRay_0(&_S1393, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S1395 = arrivesBehind_0((&ray_2)->unit_direction, _S1394.geometry_n);
                is_inside_7 = _S1395;
            }
            else
            {
                is_inside_7 = scatter_2;
            }
            if(is_inside_7)
            {
                float3  _S1396 = beerLambert((&hit_4)->distance, _S1394.material.absorption);
                float3  _S1397 = throughput_2 * _S1396;
                throughput_5 = _S1397;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S1398 = !_S1394.skip;
            float geometry_density_1 = (F32_abs((dot_0(_S1394.geometry_n, (&ray_2)->unit_direction)))) / ((&hit_4)->distance * (&hit_4)->distance);
            bool _S1399 = b_6 == _S1370;
            if(_S1399)
            {
                float _S1400 = 0.00251327408477664f / geometry_density_1;
                geometry_density_0 = _S1400;
            }
            else
            {
                geometry_density_0 = threshold_0;
            }
            float _S1401 = geometry_density_0;
            scatter_2 = _S1398;
            geometry_density_0 = geometry_density_1;
            threshold_0 = _S1401;
            surface_13 = _S1394;
            turned_1 = _S1390;
        }
        else
        {
            scatter_2 = false;
            geometry_density_0 = 0.0f;
            surface_13 = _S1377;
            throughput_5 = throughput_2;
            is_inside_7 = is_inside_6;
        }
        bool _S1402;
        if(scatter_2)
        {
            _S1402 = (&prev_0)->rough;
        }
        else
        {
            _S1402 = false;
        }
        bool _S1403;
        if(_S1402)
        {
            _S1403 = ((&prev_0)->pdf * geometry_density_0 * threshold_0) <= 1.0f;
        }
        else
        {
            _S1403 = false;
        }
        FKSurface _S1404 = surface_13;
        FKSurface _S1405 = surface_13;
        float _S1406 = dot_0(surface_13.smooth_n, - (&ray_2)->unit_direction);
        bool _S1407 = (fcptDispersionUsed());
        bool _S1408;
        if(_S1407)
        {
            _S1408 = wavelength_2 == 0.0f;
        }
        else
        {
            _S1408 = false;
        }
        bool _S1409;
        if(_S1408)
        {
            _S1409 = scatter_2;
        }
        else
        {
            _S1409 = false;
        }
        bool _S1410;
        if(_S1409)
        {
            bool _S1411 = dispersive(_S1404.material);
            _S1410 = _S1411;
        }
        else
        {
            _S1410 = false;
        }
        float3  throughput_6;
        if(_S1410)
        {
            uint _S1412 = stream(_S1257, 512U);
            Random _S1413 = pcg(_S1412);
            float2  _S1414 = sampleWavelength(_S1413.value);
            float _S1415 = _S1414.x;
            float3  _S1416 = wavelengthWeights(_S1415);
            float3  _S1417 = throughput_5 * (_S1416 / make_float3 (_S1414.y));
            wavelength_2 = _S1415;
            throughput_6 = _S1417;
        }
        else
        {
            throughput_6 = throughput_5;
        }
        BSDFMaterial refractive_0 = _S1404.material;
        float _S1418 = dispersedIor(_S1404.material.ior, _S1404.material.dispersion, wavelength_2);
        bool _S1419 = wavelength_2 > 0.0f;
        float _S1420 = _slang_select(_S1419, _S1418,_S1404.material.ior);
        (&refractive_0)->ior = _S1420;
        float2  _S1421 = vertexEta(refractive_0, _S1406);
        bool _S1422;
        if(scatter_2)
        {
            uint _S1423 = (fcptMaxBounces());
            bool _S1424 = b_6 >= _S1423;
            if(_S1424)
            {
                _S1422 = true;
            }
            else
            {
                bool _S1425 = neeDecision(_S1404.material, _S1406, _S1421.x, _S1421.y);
                _S1422 = _S1425;
            }
        }
        else
        {
            _S1422 = false;
        }
        bool _S1426;
        if(passes_0)
        {
            _S1426 = true;
        }
        else
        {
            _S1426 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1426)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1422;
        }
        bool _S1427 = (fcptHairUsed());
        bool _S1428;
        if(_S1427)
        {
            float3  _S1429 = surface_13.hair;
            _S1428 = (dot_0(_S1429, _S1429)) > 0.0f;
        }
        else
        {
            _S1428 = false;
        }
        bool _S1430;
        if(_S1428)
        {
            _S1430 = true;
        }
        else
        {
            BSDFMaterial _S1431 = _S1404.material;
            bool _S1432 = isTranslucent_0(&_S1431);
            _S1430 = _S1432;
        }
        bool _S1433;
        if(_S1430)
        {
            _S1433 = true;
        }
        else
        {
            bool _S1434 = (_S1404.material.transmission) > 0.0f;
            if(_S1434)
            {
                uint _S1435 = (fcptLayers((hit_4)));
                _S1433 = _S1435 == 1U;
            }
            else
            {
                _S1433 = false;
            }
        }
        float3  emission_0;
        if(_S1371)
        {
            float3  _S1436 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1436;
        }
        else
        {
            emission_0 = _S1404.material.emissive;
        }
        bool _S1437 = !replay_1;
        bool _S1438;
        if(_S1437)
        {
            _S1438 = true;
        }
        else
        {
            _S1438 = b_6 >= _S1245;
        }
        bool _S1439;
        if(_S1438)
        {
            float _S1440 = rgb_to_greyscale(emission_0);
            _S1439 = _S1440 > 0.0f;
        }
        else
        {
            _S1439 = false;
        }
        float3  emission_1;
        if(_S1439)
        {
            NEEVertex _S1441 = nee_vertex_0;
            FKHit _S1442 = hit_4;
            float _S1443 = emissionWeight_0(&_S1441, &_S1442, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1443);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1444;
        if(replay_1)
        {
            _S1444 = _S1234 == 1U;
        }
        else
        {
            _S1444 = false;
        }
        bool _S1445;
        if(_S1444)
        {
            _S1445 = b_6 > _S1233;
        }
        else
        {
            _S1445 = false;
        }
        bool _S1446;
        if(_S1445)
        {
            _S1446 = b_6 == _S1232;
        }
        else
        {
            _S1446 = false;
        }
        bool _S1447;
        if(_S1446)
        {
            bool _S1448 = _S1235 == 1U;
            if(_S1448)
            {
                _S1447 = true;
            }
            else
            {
                _S1447 = _S1235 == 2U;
            }
        }
        else
        {
            _S1447 = false;
        }
        if(_S1447)
        {
            bool _S1449 = _S1371 != (_S1235 == 2U);
            if(_S1449)
            {
                return _S1230;
            }
            return Shift_x24init_0(throughput_6 * emission_1 / make_float3 (r_8->jac), density_2 / r_8->jac);
        }
        uint _S1450 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1451 = _S1450 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1452 = insertBits_0(0U, b_6, 5U, 5U);
        uint _S1453 = insertBits_0(_S1452, 1U, 10U, 2U);
        uint _S1454 = insertBits_0(_S1453, (&prev_0)->lobe, 15U, 3U);
        bool _S1455 = (&prev_0)->inside;
        uint _S1456 = _slang_select(_S1455, 1U,0U);
        uint _S1457 = insertBits_0(_S1454, _S1456, 22U, 1U);
        (&here_0)->path = _S1457;
        uint _S1458 = (&here_0)->path;
        uint _S1459 = _slang_select(_S1419, 1U,0U);
        uint _S1460 = insertBits_0(_S1458, _S1459, 23U, 1U);
        (&here_0)->path = _S1460;
        float _S1461 = (&prev_0)->pdf * geometry_density_0;
        (&here_0)->jac = _S1461;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1462;
        if(replay_1)
        {
            _S1462 = _S1234 == 1U;
        }
        else
        {
            _S1462 = false;
        }
        bool _S1463;
        if(_S1462)
        {
            _S1463 = b_6 == _S1233;
        }
        else
        {
            _S1463 = false;
        }
        bool _S1464 = b_6 == _S1245;
        bool _S1465;
        if(_S1464)
        {
            bool _S1466 = !scatter_2;
            if(_S1466)
            {
                _S1465 = true;
            }
            else
            {
                bool _S1467 = _S1234 != 1U;
                if(_S1467)
                {
                    _S1465 = _S1234 != 3U;
                }
                else
                {
                    _S1465 = false;
                }
            }
        }
        else
        {
            _S1465 = false;
        }
        bool _S1468;
        if(_S1465)
        {
            _S1468 = _S1234 == 2U;
        }
        else
        {
            _S1468 = false;
        }
        bool _S1469;
        if(_S1468)
        {
            _S1469 = !_S1403;
        }
        else
        {
            _S1469 = false;
        }
        bool _S1470;
        if(_S1469)
        {
            _S1470 = _S1235 != 4U;
        }
        else
        {
            _S1470 = false;
        }
        bool _S1471 = _S1233 == _S1232;
        bool _S1472;
        if(_S1471)
        {
            _S1472 = _S1235 == 0U;
        }
        else
        {
            _S1472 = false;
        }
        bool _S1473;
        if(_S1472)
        {
            _S1473 = ((&hit_4)->instance_index) == (_S1246.instance_index);
        }
        else
        {
            _S1473 = false;
        }
        bool _S1474;
        if(_S1473)
        {
            _S1474 = ((&hit_4)->triangle_index) == (_S1246.triangle_index);
        }
        else
        {
            _S1474 = false;
        }
        bool _S1475;
        if(_S1474)
        {
            _S1475 = _S1403;
        }
        else
        {
            _S1475 = false;
        }
        bool _S1476 = _slang_select(_S1463, _S1475,_S1470);
        bool _S1477;
        if(nee_0)
        {
            _S1477 = _slang_select(replay_1, _S1476,scatter_2);
        }
        else
        {
            _S1477 = false;
        }
        TreeSample _S1478 = TreeSample_x24init_0(_S1229, _S1229, 0.0f, 0U);
        uint2  _S1479 = make_uint2 (0U);
        float2  _S1480 = make_float2 (0.0f);
        FKHit _S1481 = Hit_x24init_0(_S1480, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1482 = _S1481;
        ShadowContext _S1483 = ShadowContext_x24init_0(_S1229, _S1229, _S1479, _S1229, 0U, 0U, false, 0.0f, 0.0f, &_S1482, false);
        bool _S1484;
        if(nee_0)
        {
            _S1484 = _S1438;
        }
        else
        {
            _S1484 = false;
        }
        ShadowContext context_5;
        if(_S1484)
        {
            uint _S1485 = arrivalLobe_0(b_6, (&prev_0)->lobe);
            FKMedium _S1486 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1487 = surface_13;
            FKHit _S1488 = hit_4;
            FKMedium _S1489 = _S1486;
            ShadowContext _S1490 = shadowContext_0(&_S1487, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_6, _S1485, (&hit_4)->distance, width_3, &_S1488, _S1428, &_S1489);
            context_5 = _S1490;
        }
        else
        {
            context_5 = _S1483;
        }
        float3  throughput_7;
        float3  lit_0;
        if(_S1477)
        {
            float3  _S1491 = (&ray_2)->origin;
            if(_S1428)
            {
                throughput_7 = _S1229;
            }
            else
            {
                throughput_7 = _S1405.smooth_n;
            }
            FKSurface _S1492 = surface_13;
            uint _S1493 = stream(_S1257, b_6 + 64U);
            ShadowContext _S1494 = context_5;
            TreeSample _S1495 = sampleLightTree_0(_S1491, throughput_7, surface_13.geometry_n, surface_13.geometry_offset, _S1433, _S1493, &_S1494);
            bool _S1496 = any_1((_S1495.radiance) != _S1229);
            if(_S1496)
            {
                if(_S1428)
                {
                    uint _S1497 = (fcptMaxBounces());
                    bool _S1498 = b_6 < _S1497;
                    FKSurface _S1499 = surface_13;
                    TreeSample _S1500 = _S1495;
                    float3  _S1501 = hairLight_0(&_S1499, (&ray_2)->unit_direction, &_S1500, _S1498);
                    lit_0 = _S1501;
                }
                else
                {
                    float _S1502 = _S1421.x;
                    float _S1503 = _S1421.y;
                    uint _S1504 = (fcptMaxBounces());
                    bool _S1505 = b_6 < _S1504;
                    TreeSample _S1506 = _S1495;
                    BSDFMaterial _S1507 = _S1404.material;
                    float3  _S1508 = lightBSDF_0((&ray_2)->unit_direction, &_S1506, _S1405.smooth_n, _S1492.geometry_n, &_S1507, _S1502, _S1503, _S1505, surface_13.random_state);
                    lit_0 = _S1508;
                }
            }
            else
            {
                lit_0 = _S1229;
            }
            light_3 = _S1495;
        }
        else
        {
            light_3 = _S1478;
            lit_0 = _S1229;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1509;
        bool _S1510;
        float density_4;
        if(_S1463)
        {
            bool _S1511 = !_S1403;
            if(_S1511)
            {
                return _S1230;
            }
            uint _S1512 = extractBits_0(_S1231, 23U, 1U);
            bool _S1513 = _S1419 != (_S1512 == 1U);
            if(_S1513)
            {
                return _S1230;
            }
            float3  throughput_8 = throughput_6 * make_float3 (geometry_density_0);
            float density_5 = density_2 * geometry_density_0;
            if(_S1471)
            {
                viewed_1 = _S1235 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                return Shift_x24init_0(throughput_8 * emission_1 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1471)
            {
                refracted_4 = _S1235 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S1514 = !nee_0;
                if(_S1514)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1515 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1515 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1230;
                }
                return Shift_x24init_0(throughput_8 * lit_0 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1471)
            {
                wrong_side_0 = _S1235 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1516 = !nee_0;
                if(_S1516)
                {
                    return _S1230;
                }
                bool _S1517 = (fcptWorldReadsPath());
                if(_S1517)
                {
                    float _S1518 = environmentPdf_0(r_8->dir);
                    uint _S1519 = b_6 + 1U;
                    FKSurface _S1520 = surface_13;
                    float3  _S1521 = skyColor_0((&ray_2)->unit_direction, r_8->dir, &_S1520, _S1421, is_inside_7, _S1518, surface_13.random_state, _S1519);
                    return Shift_x24init_0(throughput_8 * (_S1521 * r_8->radiance) / make_float3 (r_8->jac), density_5 / r_8->jac);
                }
                float _S1522 = environmentPdf_0(r_8->dir);
                float3  _S1523 = skyBSDF((&ray_2)->unit_direction, r_8->dir, surface_13, _S1421, is_inside_7, _S1522, surface_13.random_state);
                return Shift_x24init_0(throughput_8 * _S1523 * r_8->radiance / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            uint _S1524 = extractBits_0(_S1231, 21U, 1U);
            bool _S1525 = nee_0 != (_S1524 == 1U);
            if(_S1525)
            {
                return _S1230;
            }
            throughput_7 = throughput_8;
            density_4 = density_5;
        }
        else
        {
            if(replay_1)
            {
                viewed_1 = _S1464;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1526 = !scatter_2;
                if(_S1526)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1527 = _S1234 != 1U;
                    if(_S1527)
                    {
                        refracted_4 = _S1234 != 3U;
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
                bool _S1528 = _S1234 == 2U;
                if(_S1528)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1403;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1235 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1428)
                    {
                        return _S1230;
                    }
                    uint _S1529 = stream(_S1257, b_6 + 448U);
                    FKRay _S1530 = ray_2;
                    FKSurface _S1531 = surface_13;
                    ShadowContext _S1532 = context_5;
                    SkySample _S1533 = sampleSky_0(&_S1530, &_S1531, _S1421, is_inside_7, _S1529, surface_13.random_state, &_S1532);
                    return Shift_x24init_0(throughput_6 * _S1533.color, 1.0f);
                }
                if(_S1528)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1403;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1534 = rgb_to_greyscale(light_3.radiance);
                    bool _S1535 = !(_S1534 > 0.0f);
                    if(_S1535)
                    {
                        return _S1230;
                    }
                    return Shift_x24init_0(throughput_6 * lit_0, 1.0f);
                }
                if(_S1244)
                {
                    passes_0 = _S1235 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1371;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_6 * emission_1, 1.0f);
                }
                if(_S1244)
                {
                    passes_0 = _S1235 == 1U;
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
                    passes_0 = !_S1403;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_6 * emission_1, 1.0f);
                }
                return _S1230;
            }
            else
            {
                if(_S1437)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1536 = b_6 > 0U;
                    if(_S1536)
                    {
                        Reservoir candidate_5 = chain_0;
                        if(_S1451)
                        {
                            float3  _S1537 = safeDivide(throughput_6 * emission_1, chain_throughput_0);
                            (&candidate_5)->radiance = _S1537;
                        }
                        else
                        {
                            if(_S1403)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1538 = throughput_6 * emission_1;
                        Reservoir _S1539 = withEnd(candidate_5, 1U, b_6, _S1538);
                        offer(sel_7, _S1539, _S1538 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1540 = throughput_6 * emission_1;
                        float3  _S1541 = sel_7->glow + _S1540;
                        sel_7->glow = _S1541;
                    }
                    if(nee_0)
                    {
                        float3  _S1542 = throughput_6 * lit_0;
                        Reservoir candidate_6 = chain_0;
                        if(_S1451)
                        {
                            float3  _S1543 = safeDivide(_S1542, chain_throughput_0);
                            (&candidate_6)->radiance = _S1543;
                        }
                        else
                        {
                            if(_S1403)
                            {
                                candidate_6 = here_0;
                                uint _S1544 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1544;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1545 = insertBits_0(0U, b_6 + 1U, 5U, 5U);
                                uint _S1546 = insertBits_0(_S1545, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1546;
                            }
                        }
                        Reservoir _S1547 = withEnd(candidate_6, 0U, b_6, _S1542);
                        offer(sel_7, _S1547, _S1542 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1428)
                        {
                            _S1509 = false;
                        }
                        else
                        {
                            bool _S1548 = environmentMapped_0();
                            _S1509 = _S1548;
                        }
                    }
                    else
                    {
                        _S1509 = false;
                    }
                    if(_S1509)
                    {
                        uint _S1549 = (fcptMaxBounces());
                        _S1510 = b_6 < _S1549;
                    }
                    else
                    {
                        _S1510 = false;
                    }
                    if(_S1510)
                    {
                        uint _S1550 = stream(_S1257, b_6 + 448U);
                        FKRay _S1551 = ray_2;
                        FKSurface _S1552 = surface_13;
                        ShadowContext _S1553 = context_5;
                        SkySample _S1554 = sampleSky_0(&_S1551, &_S1552, _S1421, is_inside_7, _S1550, surface_13.random_state, &_S1553);
                        float3  _S1555 = throughput_6 * _S1554.color;
                        Reservoir candidate_7 = chain_0;
                        if(_S1451)
                        {
                            float3  _S1556 = safeDivide(_S1555, chain_throughput_0);
                            (&candidate_7)->radiance = _S1556;
                        }
                        else
                        {
                            if(_S1403)
                            {
                                candidate_7 = here_0;
                                uint _S1557 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1557;
                                (&candidate_7)->dir = _S1554.dir;
                                (&candidate_7)->radiance = _S1554.radiance;
                            }
                            else
                            {
                                uint _S1558 = insertBits_0(0U, b_6 + 1U, 5U, 5U);
                                uint _S1559 = insertBits_0(_S1558, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1559;
                            }
                        }
                        Reservoir _S1560 = withEnd(candidate_7, 4U, b_6, _S1555);
                        offer(sel_7, _S1560, _S1555 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                }
            }
            throughput_7 = throughput_6;
            density_4 = density_2;
        }
        bool _S1561;
        bool _S1562;
        bool _S1563;
        bool straight_0;
        bool _S1564;
        bool _S1565;
        bool _S1566;
        bool _S1567;
        bool _S1568;
        bool _S1569;
        bool _S1570;
        bool _S1571;
        bool _S1572;
        bool _S1573;
        bool _S1574;
        bool _S1575;
        bool _S1576;
        float density_6;
        float sky_pdf_2;
        float spread_4;
        uint b_9;
        float3  throughput_9;
        float3  throughput_10;
        float3  throughput_11;
        if(scatter_2)
        {
            if(replay_1)
            {
                viewed_1 = _S1464;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1577 = extractBits_0(_S1231, 15U, 3U);
            uint _S1578 = extractBits_0(_S1231, 18U, 3U);
            uint _S1579 = _slang_select(_S1463, _S1578,_S1577);
            float3  _S1580 = r_8->dir;
            bool refracted_5 = _S1579 == 1U;
            SampleBSDF _S1581 = SampleBSDF_x24init_0(_S1229, _S1229, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1581;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1582 = extractBits_0(_S1231, 22U, 1U);
                bool _S1583 = is_inside_7 != (_S1582 == 1U);
                if(_S1583)
                {
                    return _S1230;
                }
                bool _S1584 = _S1234 == 1U;
                if(_S1584)
                {
                    float3  _S1585 = (fcptHitPosition((_S1246)));
                    throughput_9 = _S1585;
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
                    BSDFMaterial _S1586 = _S1404.material;
                    bool _S1587 = isTranslucent_0(&_S1586);
                    if(_S1587)
                    {
                        refracted_4 = _S1579 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1588 = throughput_9 - (&ray_2)->origin;
                        float3  _S1589 = _slang_select(_S1584, _S1588,_S1580);
                        wrong_side_0 = (dot_0(_S1405.smooth_n, _S1589) * _S1406) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1584)
                {
                    float3  _S1590 = (&ray_2)->origin;
                    FKSurface _S1591 = surface_13;
                    float3  _S1592 = - _S1405.smooth_n;
                    bool _S1593 = is_inside_7 != refracted_4;
                    float3  _S1594 = _slang_select(_S1593, _S1592,_S1405.smooth_n);
                    float3  _S1595 = throughput_9 - (_S1590 + make_float3 (_S1591.geometry_offset) * _S1594);
                    float3  _S1596 = ((((_S1595)) * make_float3(rnorm3df(((_S1595)).x, ((_S1595)).y, ((_S1595)).z))));
                    reconnection_1 = _S1596;
                }
                else
                {
                    reconnection_1 = _S1580;
                }
                if(_S1428)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1597 = wrongSide_0(is_inside_7, refracted_4, reconnection_1, surface_13.geometry_n);
                    wrong_side_0 = _S1597;
                }
                if(wrong_side_0)
                {
                    return _S1230;
                }
                float3  _S1598 = throughput_9;
                throughput_9 = reconnection_1;
                b_9 = _S1579;
                wrong_side_0 = false;
                reconnection_1 = _S1598;
            }
            else
            {
                bool _S1599 = !_S1463;
                if(_S1599)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1600;
                    if(_S1428)
                    {
                        SampleBSDF _S1601 = (fcptSampleHair((surface_13.hair), (_S1404.material.albedo), (_S1404.material.specular_tint), ((&ray_2)->unit_direction), (surface_13.random_state)));
                        _S1600 = _S1601;
                    }
                    else
                    {
                        SampleBSDF _S1602 = sampleBSDF((&ray_2)->unit_direction, _S1405.smooth_n, _S1404.material, _S1421.x, _S1421.y, surface_13.random_state, _S1480);
                        _S1600 = _S1602;
                    }
                    bsdf_sampled_0 = _S1600;
                    if(_S1428)
                    {
                        refracted_4 = !(((&bsdf_sampled_0)->pdf) > 0.0f);
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        if(replay_1)
                        {
                            return _S1230;
                        }
                        break;
                    }
                    if(_S1428)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1603 = wrongSide_0(is_inside_7, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_13.geometry_n);
                        wrong_side_0 = _S1603;
                    }
                    if(wrong_side_0)
                    {
                        _S1509 = (_S1404.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1509 = false;
                    }
                    if(_S1509)
                    {
                        SampleBSDF _S1604 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_13.geometry_n, _S1404.material, _S1421.x, _S1421.y, (&bsdf_sampled_0)->random_state, _S1480);
                        (&bsdf_sampled_0)->unit_direction = _S1604.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1604.refracted;
                        (&bsdf_sampled_0)->throughput = _S1604.throughput;
                        (&bsdf_sampled_0)->lobe = _S1604.lobe;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1605 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_13.geometry_n)) * surface_13.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1605;
                        }
                    }
                    uint _S1606 = (&bsdf_sampled_0)->lobe;
                    float3  _S1607 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1608 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1609 = (&bsdf_sampled_0)->pdf;
                    float _S1610 = _slang_select(wrong_side_0, 0.0f,_S1609);
                    (&lobe_5)->pdf = _S1610;
                    throughput_9 = _S1607;
                    b_9 = _S1606;
                    refracted_4 = _S1608;
                }
                else
                {
                    throughput_9 = _S1580;
                    b_9 = _S1579;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1509 = true;
            }
            else
            {
                _S1509 = _S1463;
            }
            float3  chain_throughput_1;
            if(_S1509)
            {
                if(_S1428)
                {
                    SampleBSDF _S1611 = (fcptConnectHair((surface_13.hair), (_S1404.material.albedo), (_S1404.material.specular_tint), ((&ray_2)->unit_direction), (throughput_9)));
                    lobe_5 = _S1611;
                }
                else
                {
                    float3  _S1612 = (&ray_2)->unit_direction;
                    float3  _S1613 = negate_0(_S1612);
                    float _S1614 = sign_0(_S1406);
                    float3  _S1615 = _S1405.smooth_n * make_float3 (_S1614);
                    float _S1616 = dot_0(_S1615, throughput_9);
                    float _S1617 = _S1404.material.roughness;
                    float _S1618 = _S1617 * _S1617;
                    AnisotropicFrame _S1619 = anisotropicFrame(_S1404.material, _S1615);
                    SheenProfile _S1620 = sheenProfile(_S1613, _S1615, _S1404.material);
                    float3  _S1621 = reflectedHalf(_S1612, throughput_9);
                    bool _S1622 = b_9 == 1U;
                    if(_S1622)
                    {
                        float3  _S1623 = refractedHalf(_S1612, throughput_9, _S1405.smooth_n, _S1421.x, _S1421.y);
                        throughput_10 = _S1623;
                    }
                    else
                    {
                        throughput_10 = _S1621;
                    }
                    bool _S1624 = b_9 == 0U;
                    if(_S1624)
                    {
                        _S1510 = true;
                    }
                    else
                    {
                        _S1510 = b_9 == 6U;
                    }
                    if(_S1510)
                    {
                        float3  _S1625 = sampledHalf(_S1613, _S1615, _S1618, _S1619, surface_13.random_state);
                        throughput_11 = _S1625;
                    }
                    else
                    {
                        throughput_11 = throughput_10;
                    }
                    float _S1626 = _S1421.x;
                    float _S1627 = _S1421.y;
                    Weights _S1628 = lobeWeights(_S1612, _S1613, _S1615, throughput_11, _S1619, _S1620, _S1404.material, _S1626, _S1627);
                    float _S1629 = (F32_abs((_S1406)));
                    float _S1630 = vndfPDF(_S1613, throughput_11, _S1615, _S1629, _S1618, _S1619, _S1628.v_dot_h);
                    switch(b_9)
                    {
                    case 0U:
                        {
                            float _S1631 = diffusePDF(_S1616, _S1629, _S1404.material, _S1628);
                            float3  _S1632 = diffuseBSDF(throughput_9, _S1615, _S1404.material, _S1628);
                            density_6 = _S1631;
                            chain_throughput_1 = _S1632;
                            break;
                        }
                    case 1U:
                        {
                            float _S1633 = refractPDF(dot_0(throughput_9, throughput_11), _S1630, _S1628, _S1626, _S1627);
                            float3  _S1634 = refractBSDF(throughput_9, _S1615, _S1618, _S1619, _S1404.material, _S1628);
                            density_6 = _S1633;
                            chain_throughput_1 = _S1634;
                            break;
                        }
                    case 4U:
                        {
                            float _S1635 = sheenVelvetPDF(_S1616, _S1629, _S1628);
                            float3  _S1636 = sheenVelvetBSDF(throughput_9, _S1613, _S1615, _S1404.material, _S1628);
                            density_6 = _S1635;
                            chain_throughput_1 = _S1636;
                            break;
                        }
                    case 6U:
                        {
                            ToonProfile _S1637 = toonProfile(_S1613, _S1615, _S1404.material);
                            float _S1638 = toonPDF(throughput_9, _S1615, _S1637, _S1628);
                            float3  _S1639 = toonBSDF(throughput_9, _S1615, _S1637, _S1628);
                            density_6 = _S1638;
                            chain_throughput_1 = _S1639;
                            break;
                        }
                    default:
                        {
                            float _S1640 = reflectPDF(_S1630, _S1628);
                            float3  _S1641 = reflectBSDF(throughput_9, _S1615, _S1618, _S1619, _S1628);
                            density_6 = _S1640;
                            chain_throughput_1 = _S1641;
                            break;
                        }
                    }
                    bool _S1642 = density_6 > 0.0f;
                    if(_S1642)
                    {
                        SampleBSDF _S1643 = SampleBSDF_x24init_0(throughput_9, chain_throughput_1, surface_13.random_state, _S1622, b_9, density_6);
                        lobe_5 = _S1643;
                    }
                }
            }
            bool _S1644 = b_9 == 0U;
            if(_S1644)
            {
                _S1510 = true;
            }
            else
            {
                _S1510 = b_9 == 4U;
            }
            if(_S1510)
            {
                _S1561 = true;
            }
            else
            {
                _S1561 = b_9 == 6U;
            }
            if(_S1428)
            {
                _S1562 = false;
            }
            else
            {
                bool _S1645 = !_S1561;
                if(_S1645)
                {
                    bool _S1646 = (_S1404.material.roughness) == 0.0f;
                    if(_S1646)
                    {
                        _S1562 = true;
                    }
                    else
                    {
                        bool _S1647 = b_9 == 1U;
                        if(_S1647)
                        {
                            _S1562 = (_S1421.x) == (_S1421.y);
                        }
                        else
                        {
                            _S1562 = false;
                        }
                    }
                }
                else
                {
                    _S1562 = false;
                }
            }
            bool _S1648 = !_S1428;
            if(_S1648)
            {
                _S1563 = b_9 == 1U;
            }
            else
            {
                _S1563 = false;
            }
            if(_S1563)
            {
                straight_0 = (_S1404.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1564 = _S1648;
            }
            else
            {
                _S1564 = false;
            }
            if(_S1564)
            {
                _S1565 = b_9 == 1U;
            }
            else
            {
                _S1565 = false;
            }
            if(_S1565)
            {
                _S1566 = (_S1421.x) == (_S1421.y);
            }
            else
            {
                _S1566 = false;
            }
            BSDFMaterial _S1649 = _S1404.material;
            bool _S1650 = isTranslucent_0(&_S1649);
            if(_S1650)
            {
                _S1567 = _S1644;
            }
            else
            {
                _S1567 = false;
            }
            if(_S1567)
            {
                _S1568 = (dot_0(throughput_9, surface_13.geometry_n)) < 0.0f;
            }
            else
            {
                _S1568 = false;
            }
            if(nee_0)
            {
                _S1569 = !_S1562;
            }
            else
            {
                _S1569 = false;
            }
            if(_S1569)
            {
                _S1570 = !wrong_side_0;
            }
            else
            {
                _S1570 = false;
            }
            if(_S1570)
            {
                float _S1651 = (&lobe_5)->pdf;
                float3  _S1652 = (&ray_2)->origin;
                float3  _S1653 = _slang_select(_S1433, _S1229,_S1405.smooth_n);
                float3  _S1654 = (&ray_2)->origin;
                FKSurface _S1655 = surface_13;
                float3  _S1656 = - _S1405.smooth_n;
                float3  _S1657 = _slang_select(_S1568, _S1656,_S1405.smooth_n);
                NEEVertex _S1658 = NEEVertex_x24init_0(false, _S1651, _S1652, _S1653, _S1654 + make_float3 (_S1655.geometry_offset) * _S1657);
                nee_vertex_0 = _S1658;
            }
            else
            {
                if(_S1428)
                {
                    _S1571 = true;
                }
                else
                {
                    bool _S1659 = b_9 != 1U;
                    if(_S1659)
                    {
                        _S1571 = true;
                    }
                    else
                    {
                        _S1571 = (_S1421.x) != (_S1421.y);
                    }
                }
                if(_S1571)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1660 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1660)
            {
                if(_S1561)
                {
                    _S1571 = true;
                }
                else
                {
                    _S1571 = ((&lobe_5)->pdf * (&prev_0)->cos / ((&hit_4)->distance * (&hit_4)->distance) * threshold_0) <= 1.0f;
                }
            }
            else
            {
                _S1571 = false;
            }
            bool _S1661 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1661)
            {
                if(_S1561)
                {
                    _S1572 = true;
                }
                else
                {
                    _S1572 = (_S1404.material.roughness) >= 0.20000000298023224f;
                }
            }
            else
            {
                _S1572 = false;
            }
            if(_S1463)
            {
                bool _S1662 = !_S1571;
                if(_S1662)
                {
                    return _S1230;
                }
                bool _S1663 = _S1235 != 1U;
                if(_S1663)
                {
                    _S1573 = _S1235 != 2U;
                }
                else
                {
                    _S1573 = false;
                }
                if(_S1573)
                {
                    float _S1664 = (&lobe_5)->pdf;
                    float _S1665 = _slang_select(nee_0, _S1664,0.0f);
                    float _S1666 = escapeWeight_0(_S1665, _S1580);
                    if(_S1471)
                    {
                        passes_0 = _S1241;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1667 = _slang_select(passes_0, _S1666,1.0f);
                    return Shift_x24init_0(throughput_7 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_8->radiance * make_float3 (_S1667) / make_float3 (r_8->jac), density_4 * (&lobe_5)->pdf / r_8->jac);
                }
                float3  _S1668 = throughput_7 * make_float3 ((&lobe_5)->pdf);
                float _S1669 = density_4 * (&lobe_5)->pdf;
                throughput_10 = _S1668;
                density_6 = _S1669;
            }
            else
            {
                throughput_10 = throughput_7;
                density_6 = density_4;
            }
            uint _S1670 = (fcptLayers((hit_4)));
            bool _S1671 = _S1670 > 1U;
            if(_S1671)
            {
                _S1573 = (b_9 == 1U) != passes_0;
            }
            else
            {
                _S1573 = false;
            }
            if(viewed_1)
            {
                _S1574 = _S1573;
            }
            else
            {
                _S1574 = false;
            }
            if(_S1574)
            {
                return _S1230;
            }
            if(replay_1)
            {
                _S1575 = b_6 <= _S1245;
            }
            else
            {
                _S1575 = false;
            }
            if(_S1575)
            {
                _S1576 = _S1403;
            }
            else
            {
                _S1576 = false;
            }
            bool _S1672;
            if(_S1576)
            {
                _S1672 = _S1571;
            }
            else
            {
                _S1672 = false;
            }
            bool _S1673;
            if(_S1672)
            {
                _S1673 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1673 = !_S1572;
                }
                else
                {
                    _S1673 = false;
                }
            }
            if(_S1673)
            {
                return _S1230;
            }
            if(viewed_1)
            {
                float3  _S1674 = throughput_10 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1675 = (&lobe_5)->pdf;
                throughput_11 = _S1674;
                sky_pdf_2 = _S1675;
            }
            else
            {
                float3  _S1676 = throughput_10 * max_0((&lobe_5)->throughput, _S1229);
                throughput_11 = _S1676;
                sky_pdf_2 = density_6;
            }
            bool _S1677;
            if(_S1437)
            {
                _S1677 = !_S1451;
            }
            else
            {
                _S1677 = false;
            }
            bool _S1678;
            if(_S1677)
            {
                _S1678 = _S1403;
            }
            else
            {
                _S1678 = false;
            }
            bool _S1679;
            if(_S1678)
            {
                _S1679 = _S1571;
            }
            else
            {
                _S1679 = false;
            }
            if(_S1679)
            {
                chain_0 = here_0;
                uint _S1680 = insertBits_0((&chain_0)->path, b_9, 18U, 3U);
                uint _S1681 = _slang_select(nee_0, 1U,0U);
                uint _S1682 = insertBits_0(_S1680, _S1681, 21U, 1U);
                (&chain_0)->path = _S1682;
                float _S1683 = (&chain_0)->jac * (&lobe_5)->pdf;
                (&chain_0)->jac = _S1683;
                (&chain_0)->dir = throughput_9;
                chain_throughput_1 = throughput_11;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1684 = surface_13;
            Vertex _S1685 = Vertex_x24init_0(_S1572, b_9, (&lobe_5)->pdf, (F32_abs((dot_0(surface_13.geometry_n, throughput_9)))), is_inside_7);
            prev_0 = _S1685;
            float _S1686 = (&lobe_5)->pdf;
            bool _S1687 = b_9 == 1U;
            bool _S1688;
            if(_S1687)
            {
                _S1688 = (_S1421.x) == (_S1421.y);
            }
            else
            {
                _S1688 = false;
            }
            float sky_pdf_3 = _slang_select(_S1688, sky_pdf_0,_S1686);
            float _S1689 = _slang_select(_S1428, 0.0f,sky_pdf_3);
            float _S1690 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * (&lobe_5)->pdf))))), (3.14159274101257324f)));
            bool _S1691 = !_S1562;
            float _S1692 = _slang_select(_S1691, _S1690,0.0f);
            float _S1693 = spread_1 + _S1692;
            bool _S1694;
            if(refracted_4)
            {
                _S1694 = !_S1568;
            }
            else
            {
                _S1694 = false;
            }
            bool is_inside_8;
            if(_S1694)
            {
                bool _S1695 = !is_inside_7;
                is_inside_8 = _S1695;
            }
            else
            {
                is_inside_8 = is_inside_7;
            }
            FKSurface _S1696 = surface_13;
            bool _S1697 = boundsVolume_0(&_S1696);
            bool _S1698;
            if(_S1697)
            {
                _S1698 = !_S1573;
            }
            else
            {
                _S1698 = false;
            }
            if(_S1698)
            {
                FKSurface faced_2 = surface_13;
                float3  _S1699 = - _S1684.geometry_n;
                float3  _S1700 = _slang_select(turned_1, _S1699,_S1684.geometry_n);
                (&faced_2)->geometry_n = _S1700;
                FKMedium _S1701 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1702 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1703 = faced_2;
                FKMedium _S1704 = _S1701;
                FKMedium _S1705 = _S1702;
                MediumSides _S1706 = mediumSides_0(&_S1703, &_S1704, filling_2, (&ray_2)->unit_direction, &_S1705);
                bool _S1707 = ((dot_0(throughput_9, _S1684.geometry_n)) > 0.0f) == ((dot_0(_S1684.geometry_n, (&faced_2)->geometry_n)) > 0.0f);
                float3  _S1708 = _slang_select(_S1707, _S1706.front.scatter,_S1706.behind.scatter);
                scatter_in_0 = _S1708;
                float3  _S1709 = _slang_select(_S1707, _S1706.front.extinction,_S1706.behind.extinction);
                extinction_in_0 = _S1709;
                float _S1710 = _slang_select(_S1707, _S1706.front.g,_S1706.behind.g);
                g_in_0 = _S1710;
                uint _S1711 = _S1706.fillings.x;
                uint _S1712 = _S1706.fillings.y;
                uint _S1713 = _slang_select(_S1707, _S1712,_S1711);
                bool _S1714 = (fcptVaryingUsed());
                uint _S1715 = _slang_select(_S1714, _S1713,4294967295U);
                filling_2 = _S1715;
            }
            (&ray_2)->unit_direction = throughput_9;
            bool _S1716 = !_S1573;
            if(_S1716)
            {
                FKSurface _S1717 = surface_13;
                float _S1718 = _slang_select(straight_0, 0.0f,_S1717.geometry_offset);
                float3  _S1719 = - _S1405.smooth_n;
                bool _S1720 = is_inside_8 != _S1568;
                float3  _S1721 = _slang_select(_S1720, _S1719,_S1405.smooth_n);
                float3  _S1722 = (&ray_2)->origin + make_float3 (_S1718) * _S1721;
                (&ray_2)->origin = _S1722;
            }
            throughput_10 = throughput_11;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1573;
            viewed_1 = _S1566;
            sky_pdf_2 = _S1689;
            spread_4 = _S1693;
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
            spread_4 = spread_1;
            straight_0 = false;
            is_inside_6 = is_inside_7;
        }
        float density_7;
        if(_S1437)
        {
            if(_S1371)
            {
                float3  _S1723 = throughput_10 * emission_1;
                Reservoir candidate_8 = chain_0;
                uint _S1724 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1725 = _S1724 == 1U;
                if(_S1725)
                {
                    float3  _S1726 = safeDivide(_S1723, chain_throughput_0);
                    (&candidate_8)->radiance = _S1726;
                }
                Reservoir _S1727 = withEnd(candidate_8, 2U, b_6, _S1723);
                offer(sel_7, _S1727, _S1723 * make_float3 (scale_3) / make_float3 (density_6));
            }
            if(_S1371)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1728 = survivalProbability(abs_0(throughput_10), density_6);
                density_7 = _S1728;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1729 = stream(_S1257, b_6 + 128U);
            Random _S1730 = pcg(_S1729);
            bool _S1731 = density_7 < (_S1730.value);
            if(_S1731)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1732 = (fcptMaxBounces());
                wrong_side_0 = b_6 >= _S1732;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1733 = density_6 * density_7;
            density_7 = _S1733;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1734 = layer_0 ^ 1U;
        uint _S1735 = _slang_select(passes_0, _S1734,0U);
        if(passes_0)
        {
            (&prev_0)->rough = false;
            (&hit_4)->distance = 0.0f;
            b_9 = b_6;
            viewed_0 = viewed_1;
            throughput_2 = throughput_10;
            density_2 = density_7;
            sky_pdf_0 = sky_pdf_2;
            spread_1 = spread_4;
            uint _S1736 = b_9 + 1U;
            b_6 = _S1736;
            layer_0 = _S1735;
            continue;
        }
        FKRay _S1737 = ray_2;
        float _S1738 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_1)
        {
            refracted_4 = _S1464;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S1234 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1739 = _slang_select(wrong_side_0, _S1738,4.294967296e+09f);
        bool _S1740 = !_S1428;
        if(straight_0)
        {
            _S1509 = true;
        }
        else
        {
            _S1509 = _S1428;
        }
        FKHit _S1741;
        if(_S1509)
        {
            _S1741 = hit_4;
        }
        else
        {
            _S1741 = _S1481;
        }
        FKHit _S1742 = (fcptTraverseInstanceBVH((_S1737), (_S1378), (_S1739), (_S1740), (_S1741), (viewed_1)));
        hit_4 = _S1742;
        if(replay_1)
        {
            _S1510 = _S1464;
        }
        else
        {
            _S1510 = false;
        }
        if(_S1510)
        {
            _S1561 = _S1234 == 1U;
        }
        else
        {
            _S1561 = false;
        }
        if(_S1561)
        {
            _S1562 = ((&hit_4)->instance_index) == (_S1246.instance_index);
        }
        else
        {
            _S1562 = false;
        }
        if(_S1562)
        {
            _S1563 = ((&hit_4)->triangle_index) == (_S1246.triangle_index);
        }
        else
        {
            _S1563 = false;
        }
        if(_S1563)
        {
            (&hit_4)->uv = _S1246.uv;
            float _S1743 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S1743;
        }
        if(replay_1)
        {
            _S1564 = _S1464;
        }
        else
        {
            _S1564 = false;
        }
        if(_S1564)
        {
            _S1565 = _S1234 == 3U;
        }
        else
        {
            _S1565 = false;
        }
        if(_S1565)
        {
            _S1566 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1566 = false;
        }
        if(_S1566)
        {
            return _S1230;
        }
        Reservoir _S1744 = chain_0;
        uint _S1745 = filling_2;
        for(;;)
        {
            bool _S1746 = (fcptVaryingUsed());
            if(_S1746)
            {
                _S1567 = _S1745 != 4294967295U;
            }
            else
            {
                _S1567 = false;
            }
            float _S1747;
            if(_S1567)
            {
                float _S1748 = (fcptMajorant((_S1745)));
                _S1747 = _S1748;
            }
            else
            {
                _S1747 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_1)
            {
                _S1568 = _S1464;
            }
            else
            {
                _S1568 = false;
            }
            if(_S1568)
            {
                _S1569 = _S1234 == 1U;
            }
            else
            {
                _S1569 = false;
            }
            if(_S1569)
            {
                _S1570 = _S1747 > 0.0f;
            }
            else
            {
                _S1570 = false;
            }
            if(_S1570)
            {
                ended_0 = _S1230;
                sky_pdf_1 = sky_pdf_2;
                spread_2 = spread_4;
                width_4 = width_3;
                density_3 = density_7;
                throughput_11 = throughput_10;
                b_9 = b_6;
                _S1571 = true;
                break;
            }
            bool _S1749 = (&prev_0)->rough;
            if(_S1749)
            {
                _S1571 = !(_S1747 > 0.0f);
            }
            else
            {
                _S1571 = false;
            }
            (&prev_0)->rough = _S1571;
            uint _S1750 = b_6 + 320U;
            bool _S1751 = b_6 == 4294967295U;
            uint _S1752 = _slang_select(_S1751, 384U,_S1750);
            uint _S1753 = stream(_S1257, _S1752);
            uint tracking_1 = _S1753;
            weight_1 = throughput_3;
            glowed_0 = _S1229;
            b_9 = b_6;
            throughput_11 = throughput_10;
            density_3 = density_7;
            spread_2 = spread_4;
            width_4 = width_3;
            sky_pdf_1 = sky_pdf_2;
            for(;;)
            {
                if(((&hit_4)->instance_index) != 4294967295U)
                {
                }
                else
                {
                    _S1228 = int(2);
                    break;
                }
                uint _S1754 = b_9 + 320U;
                bool _S1755 = b_9 == 4294967295U;
                uint _S1756 = _slang_select(_S1755, 384U,_S1754);
                uint _S1757 = stream(_S1257, _S1756);
                Random _S1758 = pcg(_S1757);
                float _S1759 = - (F32_log((1.0f - _S1758.value))) / _S1747;
                if(_S1567)
                {
                    float3  _S1760 = (&ray_2)->origin;
                    float3  _S1761 = (&ray_2)->unit_direction;
                    float _S1762 = (&hit_4)->distance;
                    uint _S1763 = _slang_select(_S1755, 0U,b_9);
                    uint _S1764 = (&prev_0)->lobe;
                    uint _S1765 = _slang_select(_S1755, 3U,_S1764);
                    float _S1766 = (fcptTrackMedium((_S1745), (_S1760), (_S1761), (_S1762), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1763), (_S1765), (_S1755)));
                    spread_3 = _S1766;
                }
                else
                {
                    spread_3 = _S1759;
                }
                bool _S1767 = !(spread_3 < ((&hit_4)->distance));
                if(_S1767)
                {
                    _S1228 = int(2);
                    break;
                }
                if(_S1567)
                {
                    _S1572 = _S1437;
                }
                else
                {
                    _S1572 = false;
                }
                if(_S1572)
                {
                    float3  _S1768 = throughput_11 * glowed_0 / make_float3 (density_3);
                    float3  _S1769 = sel_7->glow + _S1768;
                    sel_7->glow = _S1769;
                }
                else
                {
                }
                glowed_0 = _S1229;
                uint b_10 = b_9 + 1U;
                float3  _S1770 = (&ray_2)->origin + make_float3 (spread_3) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1770;
                float3  _S1771 = flightWeight_0(scatter_in_0, extinction_in_0, _S1747, spread_3, true);
                float3  _S1772 = weight_1;
                float3  _S1773 = _slang_select(_S1567, _S1772,_S1771);
                float3  throughput_12 = throughput_11 * _S1773;
                uint _S1774 = stream(_S1257, b_10 + 320U);
                tracking_1 = _S1774;
                weight_1 = throughput_3;
                float width_7 = width_4 + spread_2 * spread_3;
                float _S1775 = spread_2 + 3.14159274101257324f;
                if(_S1437)
                {
                    _S1573 = true;
                }
                else
                {
                    bool _S1776 = b_10 == _S1245;
                    if(_S1776)
                    {
                        _S1573 = !_S1567;
                    }
                    else
                    {
                        _S1573 = false;
                    }
                }
                TreeSample light_4;
                if(_S1573)
                {
                    float3  _S1777 = (&ray_2)->origin;
                    float3  _S1778 = (&ray_2)->unit_direction;
                    float3  _S1779 = (&ray_2)->unit_direction;
                    uint _S1780 = stream(_S1257, b_10 + 64U);
                    float3  _S1781 = extinction_in_0;
                    float3  _S1782 = extinction_in_0;
                    uint2  _S1783 = make_uint2 (_S1745);
                    float3  _S1784 = (&ray_2)->unit_direction;
                    uint _S1785 = arrivalLobe_0(b_10, (&prev_0)->lobe);
                    FKHit _S1786 = _S1481;
                    ShadowContext _S1787 = ShadowContext_x24init_0(_S1781, _S1782, _S1783, _S1784, b_10, _S1785, false, spread_3, width_7, &_S1786, false);
                    ShadowContext _S1788 = _S1787;
                    TreeSample _S1789 = sampleLightTree_0(_S1777, _S1778, _S1779, 0.0f, true, _S1780, &_S1788);
                    light_4 = _S1789;
                }
                else
                {
                    light_4 = _S1478;
                }
                float _S1790 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1791 = (fcptMaxBounces());
                bool _S1792 = b_10 < _S1791;
                if(_S1792)
                {
                    _S1574 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1574 = false;
                }
                float _S1793 = _slang_select(_S1574, _S1790,0.0f);
                float3  _S1794 = throughput_12 * light_4.radiance;
                float _S1795 = powerHeuristic(light_4.density, _S1793);
                float3  _S1796 = _S1794 * make_float3 (_S1790 * _S1795);
                float3  _S1797 = _slang_select(_S1573, _S1796,_S1229);
                if(replay_1)
                {
                    _S1575 = b_10 == _S1245;
                }
                else
                {
                    _S1575 = false;
                }
                if(_S1575)
                {
                    bool _S1798 = _S1234 == 2U;
                    if(_S1798)
                    {
                        float _S1799 = resamplingTarget(_S1797);
                        _S1576 = _S1799 > 0.0f;
                    }
                    else
                    {
                        _S1576 = false;
                    }
                    if(_S1576)
                    {
                        Shift _S1800 = Shift_x24init_0(_S1797, 1.0f);
                        _S1228 = int(1);
                        ended_0 = _S1800;
                        spread_3 = _S1775;
                        width_5 = width_7;
                        throughput_9 = throughput_12;
                        b_7 = b_10;
                        break;
                    }
                    _S1228 = int(1);
                    ended_0 = _S1230;
                    spread_3 = _S1775;
                    width_5 = width_7;
                    throughput_9 = throughput_12;
                    b_7 = b_10;
                    break;
                }
                if(_S1437)
                {
                    Reservoir candidate_9 = _S1744;
                    uint _S1801 = extractBits_0(_S1744.path, 10U, 2U);
                    bool _S1802 = _S1801 == 1U;
                    if(_S1802)
                    {
                        float3  _S1803 = safeDivide(_S1797, chain_throughput_0);
                        (&candidate_9)->radiance = _S1803;
                    }
                    else
                    {
                        uint _S1804 = insertBits_0(0U, b_10 + 1U, 5U, 5U);
                        uint _S1805 = insertBits_0(_S1804, 2U, 10U, 2U);
                        (&candidate_9)->path = _S1805;
                    }
                    Reservoir _S1806 = withEnd(candidate_9, 0U, b_10, _S1797);
                    offer(sel_7, _S1806, _S1797 * make_float3 (scale_3) / make_float3 (density_3));
                    float _S1807 = survivalProbability(abs_0(throughput_12), density_3);
                    uint _S1808 = stream(_S1257, b_10 + 128U);
                    Random _S1809 = pcg(_S1808);
                    bool _S1810 = _S1807 < (_S1809.value);
                    if(_S1810)
                    {
                        _S1576 = true;
                    }
                    else
                    {
                        uint _S1811 = (fcptMaxBounces());
                        _S1576 = b_10 >= _S1811;
                    }
                    if(_S1576)
                    {
                        _S1228 = int(1);
                        ended_0 = _S1230;
                        spread_3 = _S1775;
                        width_5 = width_7;
                        throughput_9 = throughput_12;
                        b_7 = b_10;
                        break;
                    }
                    float _S1812 = density_3 * _S1807;
                    density_3 = _S1812;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1813 = stream(_S1257, b_10);
                float3  _S1814 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1813, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1814;
                NEEVertex _S1815 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1229, (&ray_2)->origin);
                nee_vertex_0 = _S1815;
                Vertex _S1816 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_6);
                prev_0 = _S1816;
                float _S1817 = (&prev_0)->pdf;
                FKRay _S1818 = ray_2;
                FKHit _S1819 = (fcptTraverseInstanceBVH((_S1818), (true), (4.294967296e+09f), (false), (_S1481), (false)));
                hit_4 = _S1819;
                b_9 = b_10;
                throughput_11 = throughput_12;
                spread_2 = _S1775;
                width_4 = width_7;
                sky_pdf_1 = _S1817;
            }
            if(_S1228 != int(2))
            {
                spread_2 = spread_3;
                width_4 = width_5;
                throughput_11 = throughput_9;
                b_9 = b_7;
                _S1571 = true;
                break;
            }
            ended_0 = _S1230;
            _S1571 = false;
            break;
        }
        if(_S1571)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1572 = b_9 == b_6;
        }
        else
        {
            _S1572 = false;
        }
        bool _S1820 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S1820)
        {
            bool _S1821 = !(&nee_vertex_0)->none;
            float _S1822 = _slang_select(_S1821, sky_pdf_1,0.0f);
            float _S1823 = escapeWeight_0(_S1822, (&ray_2)->unit_direction);
            float3  _S1824 = environment_0((&ray_2)->unit_direction, b_9, (&prev_0)->lobe);
            float3  _S1825 = throughput_11 * _S1824;
            if(replay_1)
            {
                bool _S1826 = b_9 == _S1245;
                if(_S1826)
                {
                    passes_0 = _S1234 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1825 * make_float3 (_S1823) / make_float3 (r_8->jac), density_3 / r_8->jac);
                }
                if(_S1244)
                {
                    passes_0 = _S1241;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_9 == _S1232;
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
                    return Shift_x24init_0(_S1825 * make_float3 (_S1823), 1.0f);
                }
                return _S1230;
            }
            Reservoir candidate_10 = chain_0;
            uint _S1827 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1828 = _S1827 == 1U;
            if(_S1828)
            {
                uint _S1829 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1830 = _S1829 == b_9;
                float _S1831 = _slang_select(_S1830, 1.0f,_S1823);
                float3  _S1832 = safeDivide(_S1825 * make_float3 (_S1831), chain_throughput_0);
                (&candidate_10)->radiance = _S1832;
            }
            else
            {
                bool _S1833 = (&prev_0)->rough;
                if(_S1833)
                {
                    uint _S1834 = insertBits_0(0U, b_9 + 1U, 5U, 5U);
                    uint _S1835 = insertBits_0(_S1834, 3U, 10U, 2U);
                    uint _S1836 = insertBits_0(_S1835, (&prev_0)->lobe, 15U, 3U);
                    bool _S1837 = (&prev_0)->inside;
                    uint _S1838 = _slang_select(_S1837, 1U,0U);
                    uint _S1839 = insertBits_0(_S1836, _S1838, 22U, 1U);
                    (&candidate_10)->path = _S1839;
                    (&candidate_10)->jac = (&prev_0)->pdf;
                    (&candidate_10)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1840 = _S1825 * make_float3 (_S1823);
            Reservoir _S1841 = withEnd(candidate_10, 3U, b_9, _S1840);
            offer(sel_7, _S1841, _S1840 * make_float3 (scale_3) / make_float3 (density_3));
            break;
        }
        float3  _S1842 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1842;
        bool _S1843 = (fcptVaryingUsed());
        if(_S1843)
        {
            _S1573 = filling_2 != 4294967295U;
        }
        else
        {
            _S1573 = false;
        }
        if(_S1573)
        {
            if(_S1437)
            {
                float3  _S1844 = throughput_11 * glowed_0 / make_float3 (density_3);
                float3  _S1845 = sel_7->glow + _S1844;
                sel_7->glow = _S1845;
            }
            float3  _S1846 = throughput_11 * weight_1;
            throughput_9 = _S1846;
        }
        else
        {
            float3  _S1847 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S1848 = throughput_11 * _S1847;
            throughput_9 = _S1848;
        }
        float _S1849 = width_4 + spread_2 * (&hit_4)->distance;
        viewed_0 = _S1572;
        width_3 = _S1849;
        throughput_2 = throughput_9;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_1 = spread_2;
        uint _S1736 = b_9 + 1U;
        b_6 = _S1736;
        layer_0 = _S1735;
    }
    return _S1230;
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
    Random _S1850 = pcg(state_3);
    Random _S1851 = pcg(_S1850.state);
    float _S1852 = 6.28318548202514648f * _S1850.value;
    float _S1853 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S1851.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1851.state, _S1853 * (F32_cos((_S1852))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_4, float3  value_2)
{
    RandomSphere _S1854;
    (&_S1854)->state = state_4;
    (&_S1854)->value = value_2;
    return _S1854;
}

__device__ RandomSphere random_sphere(uint state_5)
{
    Random _S1855 = normal_distribution(state_5);
    Random _S1856 = normal_distribution(_S1855.state);
    Random _S1857 = normal_distribution(_S1856.state);
    float3  _S1858 = make_float3 (_S1855.value, _S1856.value, _S1857.value);
    float3  _S1859 = ((((_S1858)) * make_float3(rnorm3df(((_S1858)).x, ((_S1858)).y, ((_S1858)).z))));
    return RandomSphere_x24init_0(_S1857.state, _S1859);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_11)
{
    float3  _S1860 = p1_0 - p0_0;
    float3  _S1861 = p2_0 - p0_0;
    float2  _S1862 = uv1_0 - uv0_0;
    float2  _S1863 = uv2_0 - uv0_0;
    float _S1864 = _S1862.x;
    float _S1865 = _S1863.y;
    float _S1866 = _S1862.y;
    float _S1867 = _S1863.x;
    float _S1868 = _S1864 * _S1865 - _S1866 * _S1867;
    float _S1869 = 1.0f / _S1868;
    float3  t_24 = (_S1860 * make_float3 (_S1865) - _S1861 * make_float3 (_S1866)) * make_float3 (_S1869);
    float3  _S1870 = (_S1861 * make_float3 (_S1864) - _S1860 * make_float3 (_S1867)) * make_float3 (_S1869);
    float3  _S1871 = t_24 - n_11 * make_float3 (dot_0(n_11, t_24));
    float3  _S1872 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_11);
    bool _S1873 = (dot_0(_S1871, _S1871)) > 0.0f;
    float3  _S1874 = _slang_select(_S1873, _S1871,_S1872);
    float3  _S1875 = ((((_S1874)) * make_float3(rnorm3df(((_S1874)).x, ((_S1874)).y, ((_S1874)).z))));
    bool _S1876 = (dot_0(cross_0(n_11, _S1875), _S1870)) > 0.0f;
    float3  t_25;
    if(_S1876)
    {
        float3  _S1877 = negate_0(_S1875);
        t_25 = _S1877;
    }
    else
    {
        t_25 = _S1875;
    }
    float3  _S1878 = cross_0(n_11, t_25);
    return makeMatrix<float, 3, 3> (t_25, _S1878, n_11);
}

__device__ float3  tangentToWorldNormalMap(float3  v_10, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_10, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_4, float3  uvw_0, float3  position_0)
{
    float3  _S1879 = t1_0 - t0_0;
    float3  _S1880 = t2_2 - t0_0;
    float3  _S1881 = t2_2 - t1_0;
    float _S1882 = (F32_min((length_0(_S1879)), ((F32_min((length_0(_S1880)), (length_0(_S1881)))))));
    float3  _S1883 = make_float3 (distance_1(position_0, t0_0), distance_1(position_0, t1_0), distance_1(position_0, t2_2));
    float3  _S1884 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1885 = dot_0(geometry_n_4, _S1884);
    float3  _S1886 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1887 = dot_0(geometry_n_4, _S1886);
    float3  _S1888 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1889 = acos_0(abs_0(make_float3 (_S1885, _S1887, dot_0(geometry_n_4, _S1888))));
    float3  _S1890 = clamp_2(tan_0(_S1889), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S1883 * _S1890, uvw_0), 0.0f, _S1882 * 0.125f);
}

__device__ float3  straightThrough(BSDFMaterial material_21)
{
    return make_float3 (material_21.transmission * (1.0f - material_21.metallic)) * material_21.albedo;
}

__device__ float hairRow(float3  in_dir_11, float3  t_26, float3  out_dir_3, uint p_14, float w_19, float alpha_10, uint nt_0)
{
    uint _S1891 = p_14 % 4U;
    float _S1892 = w_19 * HAIR_WIDTHS_0[_S1891];
    float _S1893 = (F32_asin((clamp_1(dot_0(out_dir_3, t_26), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_11, t_26), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1891] * alpha_10;
    return ((F32_asinh((_S1893 / _S1892))) / (F32_asinh((3.14159274101257324f / _S1892))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_12, float3  t_27, float3  out_dir_4, uint np_0)
{
    float3  _S1894 = worldToTangent(out_dir_4, t_27);
    float3  _S1895 = worldToTangent(in_dir_12, t_27);
    return (F32_frac((((F32_atan2((_S1894.z), (_S1894.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1895.z), (1.17549435082228751e-38f - _S1895.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_13, float3  t_28, uint p_15, float row_0, float column_0, float w_20, float alpha_11, uint nt_1, uint np_1)
{
    float3  _S1896 = worldToTangent(in_dir_13, t_28);
    uint _S1897 = p_15 % 4U;
    float _S1898 = w_20 * HAIR_WIDTHS_0[_S1897];
    float _S1899 = (F32_asin((clamp_1(dot_0(in_dir_13, t_28), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1897] * alpha_11 + _S1898 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1898))))));
    float _S1900 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1896.z), (1.17549435082228751e-38f - _S1896.x)));
    float _S1901 = (F32_cos((_S1899)));
    float3  _S1902 = tangentToWorld(make_float3 (_S1901 * (F32_cos((_S1900))), (F32_sin((_S1899))), _S1901 * (F32_sin((_S1900)))), t_28);
    return _S1902;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_12, BSDFMaterial material_22, float coverage_1)
{
    float3  _S1903;
    if((material_22.ior) == 1.0f)
    {
        float3  _S1904 = straightThrough(material_22);
        _S1903 = _S1904;
    }
    else
    {
        _S1903 = make_float3 (0.0f);
    }
    return _S1903 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_8, Reservoir r_9, bool replay_2, float scale_4, Selection * sel_8)
{
    Domain _S1905 = dom_8;
    Reservoir _S1906 = r_9;
    Shift _S1907 = walk_0(&_S1905, &_S1906, replay_2, scale_4, sel_8);
    return _S1907;
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
