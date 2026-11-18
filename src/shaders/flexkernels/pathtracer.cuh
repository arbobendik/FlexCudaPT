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

__device__ uint2  noiseOffset(uint k_0)
{
    uint2  _S297 = make_uint2 (k_0 * 3242174889U, k_0 * 2447445414U) >> make_uint2 (16U);
    uint _S298 = (fkBlueNoiseSize());
    return (_S297 * make_uint2 (_S298)) >> make_uint2 (16U);
}

__device__ uint stream(uint seed_3, uint index_0)
{
    uint _S299 = hash(index_0);
    uint _S300 = hash(seed_3 ^ _S299);
    return _S300;
}

static __device__ float random_0(uint * state_0)
{
    uint _S301 = hash(*state_0);
    *state_0 = _S301;
    return float((*state_0) >> int(8)) * 5.9604644775390625e-08f;
}

static __device__ Random Random_x24init_0(uint state_1, float value_0)
{
    Random _S302;
    (&_S302)->state = state_1;
    (&_S302)->value = value_0;
    return _S302;
}

__device__ Random pcg(uint state_2)
{
    uint _S303 = state_2;
    float value_1 = random_0(&_S303);
    return Random_x24init_0(_S303, value_1);
}

__device__ __noinline__ Random draw(uint address_0, uint variable_0)
{
    uint _S304 = address_0 >> 22U;
    uint _S305 = _S304 / 32U;
    uint2  _S306 = make_uint2 (address_0 & 2047U, (address_0 >> 11U) & 2047U);
    uint _S307 = variable_0 & 2147483647U;
    uint2  _S308 = noiseOffset(_S307);
    uint2  _S309 = _S306 + _S308;
    uint2  _S310 = noiseOffset(4096U + _S305);
    uint2  _S311 = _S309 + _S310;
    uint _S312 = (fkBlueNoiseSize());
    uint2  _S313 = _S311 & make_uint2 (_S312 - 1U);
    uint _S314 = (fkBlueNoise((_S313.x), (_S313.y), ((_S304 + ((_S305 * 2654435769U) >> 27U)) % 32U)));
    bool _S315 = (variable_0 & 2147483648U) != 0U;
    uint _S316 = stream(address_0, _S307);
    Random _S317 = pcg(_S316);
    float _S318;
    if(_S314 == 4294967295U)
    {
        if(_S315)
        {
            Random _S319 = pcg(_S317.state);
            _S318 = _S319.value;
        }
        else
        {
            _S318 = _S317.value;
        }
    }
    else
    {
        uint _S320;
        if(_S315)
        {
            _S320 = _S314 >> 16U;
        }
        else
        {
            _S320 = _S314 & 65535U;
        }
        _S318 = (float(_S320) + 0.5f) / 6.5536e+04f;
    }
    return Random_x24init_0(address_0, _S318);
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
    uint2  _S321 = (fcptEnvironmentCdfSize());
    uint2  _S322 = _S321 - make_uint2 (1U, 0U);
    float2  _S323 = make_float2 ((F32_atan2((- dir_2.y), (dir_2.x))) / 6.28318548202514648f + 0.5f, (F32_acos((clamp_1(dir_2.z, -1.0f, 1.0f)))) / 3.14159274101257324f);
    float2  _S324 = make_float2 ((float)_S322.x, (float)_S322.y);
    float2  _S325 = _S323 * _S324;
    uint2  _S326 = make_uint2 ((uint)_S325.x, (uint)_S325.y);
    uint2  _S327 = min_0(_S326, _S322 - make_uint2 (1U));
    float4  _S328 = (fcptEnvironmentCdf((_S327)));
    float _S329 = _S328.y;
    uint _S330 = _S322.x;
    float4  _S331 = (fcptEnvironmentCdf((make_uint2 (_S330, _S327.y))));
    float _S332 = _S329 * _S331.y;
    return _S332 * float(_S330 * _S322.y) / (19.73921012878417969f * length_1(float2 {dir_2.x, dir_2.y}));
}

static __device__ float3  negate_0(float3  x_13)
{
    return - x_13;
}

static __device__ float sign_0(float e_1)
{
    float _S333;
    if(e_1 > 0.0f)
    {
        _S333 = 1.0f;
    }
    else
    {
        if(e_1 < 0.0f)
        {
            _S333 = -1.0f;
        }
        else
        {
            _S333 = 0.0f;
        }
    }
    return _S333;
}

struct AnisotropicFrame
{
    float3  tangent;
    float2  alphas;
};

static __device__ AnisotropicFrame AnisotropicFrame_x24init_0(float3  tangent_0, float2  alphas_0)
{
    AnisotropicFrame _S334;
    (&_S334)->tangent = tangent_0;
    (&_S334)->alphas = alphas_0;
    return _S334;
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_1)
{
    float3  a_1 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S335 = (F32_abs((dot_0(n_1, a_1)))) > 0.9999847412109375f;
    float3  a_2;
    if(_S335)
    {
        float3  _S336 = make_float3 (1.0f, 0.0f, 0.0f);
        a_2 = _S336;
    }
    else
    {
        a_2 = a_1;
    }
    float3  _S337 = cross_0(n_1, a_2);
    float3  _S338 = ((((_S337)) * make_float3(rnorm3df(((_S337)).x, ((_S337)).y, ((_S337)).z))));
    float3  _S339 = cross_0(n_1, _S338);
    return make_float3 (v_0.x) * _S338 + make_float3 (v_0.y) * n_1 + make_float3 (v_0.z) * _S339;
}

__device__ AnisotropicFrame anisotropicFrame(BSDFMaterial material_0, float3  n_i_0)
{
    float _S340 = material_0.roughness;
    float _S341 = _S340 * _S340;
    bool _S342 = (material_0.anisotropy) == 0.0f;
    bool _S343;
    if(_S342)
    {
        _S343 = true;
    }
    else
    {
        _S343 = !(_S341 > 0.0f);
    }
    if(_S343)
    {
        return AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f));
    }
    float3  _S344 = material_0.tangent - n_i_0 * make_float3 (dot_0(n_i_0, material_0.tangent));
    float3  _S345 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_i_0);
    bool _S346 = (dot_0(_S344, _S344)) > 0.0f;
    float3  _S347 = _slang_select(_S346, _S344,_S345);
    float3  _S348 = ((((_S347)) * make_float3(rnorm3df(((_S347)).x, ((_S347)).y, ((_S347)).z))));
    float _S349 = 6.28318548202514648f * material_0.anisotropic_rotation;
    float _S350 = (F32_sqrt((1.0f - 0.89999997615814209f * (F32_abs((material_0.anisotropy))))));
    float _S351 = 1.0f / _S350;
    bool _S352 = (material_0.anisotropy) < 0.0f;
    float _S353 = _slang_select(_S352, _S351,_S350);
    return AnisotropicFrame_x24init_0(_S348 * make_float3 ((F32_cos((_S349)))) + cross_0(n_i_0, _S348) * make_float3 ((F32_sin((_S349)))), make_float2 (_S341 / _S353, _S341 * _S353));
}

__device__ float rgb_to_greyscale(float3  rgb_0)
{
    return dot_0(rgb_0, make_float3 (0.29899999499320984f, 0.58700001239776611f, 0.11400000005960464f));
}

__device__ float3  coatNormal(BSDFMaterial material_1, float3  n_2)
{
    float3  _S354 = material_1.coat_normal;
    bool _S355 = (dot_0(_S354, _S354)) > 0.0f;
    float3  _S356 = material_1.coat_normal;
    float3  _S357 = ((((_S356)) * make_float3(rnorm3df(((_S356)).x, ((_S356)).y, ((_S356)).z))));
    float3  _S358 = _slang_select(_S355, _S357,n_2);
    float _S359 = sign_0(dot_0(_S358, n_2));
    return _S358 * make_float3 (_S359);
}

__device__ float3  anisotropicLocal(float3  w_0, float3  t_12, float3  n_3)
{
    return make_float3 (dot_0(w_0, t_12), dot_0(w_0, cross_0(n_3, t_12)), dot_0(w_0, n_3));
}

static __device__ float unshared_0(float x_14)
{
    return x_14;
}

__device__ float3  sampleGGXVNDF(float3  Ve_0, float alpha_0, float U1_0, float U2_0)
{
    float3  _S360 = make_float3 (alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z);
    float3  _S361 = ((((_S360)) * make_float3(rnorm3df(((_S360)).x, ((_S360)).y, ((_S360)).z))));
    float _S362 = _S361.x;
    float _S363 = _S361.y;
    float _S364 = _S362 * _S362 + _S363 * _S363;
    float3  _S365;
    if(_S364 > 0.0f)
    {
        float3  _S366 = make_float3 (- _S363, _S362, 0.0f);
        float _S367 = (rsqrtf((_S364)));
        _S365 = _S366 * make_float3 (_S367);
    }
    else
    {
        _S365 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S368 = cross_0(_S361, _S365);
    float _S369 = (F32_sqrt((U1_0)));
    float _S370 = 6.28318548202514648f * U2_0;
    float _S371 = _S369 * (F32_cos((_S370)));
    float t2_0 = _S369 * (F32_sin((_S370)));
    float _S372 = 0.5f * (1.0f + _S361.z);
    float t2_1 = (1.0f - _S372) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S371 * _S371)))))) + _S372 * t2_0;
    float3  _S373 = make_float3 (_S371) * _S365 + make_float3 (t2_1) * _S368;
    float _S374 = unshared_0(_S371);
    float _S375 = unshared_0(_S371);
    float3  _S376 = _S373 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S374 * _S375 - t2_1 * t2_1))))))) * _S361;
    float3  _S377 = make_float3 (alpha_0 * _S376.x, alpha_0 * _S376.y, (F32_max((0.0f), (_S376.z))));
    float3  _S378 = ((((_S377)) * make_float3(rnorm3df(((_S377)).x, ((_S377)).y, ((_S377)).z))));
    return _S378;
}

__device__ float3  worldToTangent(float3  v_1, float3  n_4)
{
    float3  a_3 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S379 = (F32_abs((dot_0(n_4, a_3)))) > 0.9999847412109375f;
    float3  a_4;
    if(_S379)
    {
        float3  _S380 = make_float3 (1.0f, 0.0f, 0.0f);
        a_4 = _S380;
    }
    else
    {
        a_4 = a_3;
    }
    float3  _S381 = cross_0(n_4, a_4);
    float3  _S382 = ((((_S381)) * make_float3(rnorm3df(((_S381)).x, ((_S381)).y, ((_S381)).z))));
    float3  _S383 = cross_0(n_4, _S382);
    return make_float3 (dot_0(v_1, _S382), dot_0(v_1, n_4), dot_0(v_1, _S383));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_2, float3  n_i_1, float alpha_1, AnisotropicFrame frame_0, uint * random_state_2, uint first_1)
{
    Random _S384 = draw(*random_state_2, first_1);
    Random _S385 = draw(*random_state_2, first_1 | 2147483648U);
    *random_state_2 = _S385.state;
    float _S386 = frame_0.alphas.x;
    bool _S387 = _S386 > 0.0f;
    if(_S387)
    {
        float3  _S388 = anisotropicLocal(v_2, frame_0.tangent, n_i_1);
        float _S389 = frame_0.alphas.y;
        float3  _S390 = make_float3 (_S386 * _S388.x, _S389 * _S388.y, _S388.z);
        float3  _S391 = ((((_S390)) * make_float3(rnorm3df(((_S390)).x, ((_S390)).y, ((_S390)).z))));
        float3  _S392 = sampleGGXVNDF(_S391, 1.0f, _S384.value, _S385.value);
        float3  _S393 = make_float3 (_S386 * _S392.x, _S389 * _S392.y, _S392.z);
        float3  _S394 = ((((_S393)) * make_float3(rnorm3df(((_S393)).x, ((_S393)).y, ((_S393)).z))));
        return make_float3 (_S394.x) * frame_0.tangent + make_float3 (_S394.y) * cross_0(n_i_1, frame_0.tangent) + make_float3 (_S394.z) * n_i_1;
    }
    float3  _S395 = worldToTangent(v_2, n_i_1);
    float3  _S396 = sampleGGXVNDF(float3 {_S395.x, _S395.z, _S395.y}, alpha_1, _S384.value, _S385.value);
    float3  _S397 = float3 {_S396.x, _S396.z, _S396.y};
    float3  _S398 = tangentToWorld(_S397, n_i_1);
    return _S398;
}

__device__ __forceinline__ float3  coatHalf(float3  v_3, float3  n_i_2, BSDFMaterial material_2, uint random_state_3)
{
    float3  _S399 = coatNormal(material_2, n_i_2);
    bool _S400 = (material_2.coat) > 0.0f;
    bool _S401;
    if(_S400)
    {
        _S401 = (dot_0(_S399, v_3)) > 0.0f;
    }
    else
    {
        _S401 = false;
    }
    bool _S402 = !_S401;
    if(_S402)
    {
        return make_float3 (0.0f);
    }
    uint state_3 = random_state_3;
    float _S403 = material_2.coat_roughness;
    float3  _S404 = sampleHalfVector(v_3, _S399, _S403 * _S403, AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f)), &state_3, 1U);
    return _S404;
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
    float3  coat;
    float p_coat;
    float coat_pdf;
};

static __device__ Weights Weights_x24init_0(float v_dot_h_0, float3  refracted_1, float3  F_0, float reflect_weight_0, float3  diffuse_weight_0, float3  refract_weight_0, float p_diffuse_0, float p_reflect_0, float p_refract_0, float p_sheen_velvet_0, float p_toon_0, float3  sheen_0, float3  coat_0, float p_coat_0, float coat_pdf_0)
{
    Weights _S405;
    (&_S405)->v_dot_h = v_dot_h_0;
    (&_S405)->refracted = refracted_1;
    (&_S405)->F = F_0;
    (&_S405)->reflect_weight = reflect_weight_0;
    (&_S405)->diffuse_weight = diffuse_weight_0;
    (&_S405)->refract_weight = refract_weight_0;
    (&_S405)->p_diffuse = p_diffuse_0;
    (&_S405)->p_reflect = p_reflect_0;
    (&_S405)->p_refract = p_refract_0;
    (&_S405)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S405)->p_toon = p_toon_0;
    (&_S405)->sheen = sheen_0;
    (&_S405)->coat = coat_0;
    (&_S405)->p_coat = p_coat_0;
    (&_S405)->coat_pdf = coat_pdf_0;
    return _S405;
}

__device__ __forceinline__ float3  sampledHalf(float3  v_4, float3  n_i_3, float alpha_2, AnisotropicFrame frame_1, uint random_state_4)
{
    uint state_4 = random_state_4;
    float3  _S406 = sampleHalfVector(v_4, n_i_3, alpha_2, frame_1, &state_4, 0U);
    return _S406;
}

__device__ __forceinline__ float3  refractedHalf(float3  in_dir_0, float3  out_dir_0, float3  n_5, float eta_i_0, float eta_o_0)
{
    float3  _S407 = negate_0(in_dir_0);
    float3  _S408 = negate_0(make_float3 (eta_i_0) * _S407 + make_float3 (eta_o_0) * out_dir_0);
    float3  _S409 = ((((_S408)) * make_float3(rnorm3df(((_S408)).x, ((_S408)).y, ((_S408)).z))));
    float _S410 = sign_0(dot_0(n_5, _S407));
    float _S411 = sign_0(dot_0(_S408, n_5 * make_float3 (_S410)));
    return _S409 * make_float3 (_S411);
}

__device__ __forceinline__ float3  reflectedHalf(float3  in_dir_1, float3  out_dir_1)
{
    float3  _S412 = negate_0(in_dir_1);
    float3  _S413 = _S412 + out_dir_1;
    float3  _S414 = ((((_S413)) * make_float3(rnorm3df(((_S413)).x, ((_S413)).y, ((_S413)).z))));
    return _S414;
}

static __device__ float3  refract_0(float3  i_5, float3  n_6, float eta_0)
{
    float _S415 = dot_0(n_6, i_5);
    float _S416 = 1.0f - eta_0 * eta_0 * (1.0f - _S415 * _S415);
    if(_S416 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_5 - make_float3 (eta_0 * _S415 + (F32_sqrt((_S416)))) * n_6;
}

__device__ float fresnel(float cos_theta_0, float eta_i_1, float eta_o_1)
{
    float _S417 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S418 = eta_i_1 / eta_o_1 * _S417;
    bool _S419 = _S418 < 1.0f;
    float kr_0;
    if(_S419)
    {
        float _S420 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S418 * _S418))))));
        float _S421 = eta_o_1 * cos_theta_0;
        float _S422 = eta_i_1 * _S420;
        float _S423 = (_S421 - _S422) / (_S421 + _S422);
        float _S424 = eta_i_1 * cos_theta_0;
        float _S425 = eta_o_1 * _S420;
        float _S426 = (_S424 - _S425) / (_S424 + _S425);
        float _S427 = (_S423 * _S423 + _S426 * _S426) / 2.0f;
        kr_0 = _S427;
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

static __device__ float3  reflect_0(float3  i_7, float3  n_7)
{
    return i_7 - make_float3 (2.0f * dot_0(n_7, i_7)) * n_7;
}

__device__ float smithG1(float alpha_3, float n_dot_x_0)
{
    float _S428 = alpha_3 * alpha_3;
    float _S429 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S428 + (1.0f - _S428) * n_dot_x_0 * n_dot_x_0))));
    bool _S430 = alpha_3 > 0.0f;
    float _S431 = _slang_select(_S430, _S429,1.0f);
    return _S431;
}

__device__ float trowbridgeReitz(float alpha_4, float n_dot_h_0)
{
    float _S432 = alpha_4 * alpha_4;
    float _S433 = (1.0f - n_dot_h_0) * (1.0f + n_dot_h_0) + _S432 * n_dot_h_0 * n_dot_h_0;
    return _S432 / (F32_max((3.14159274101257324f * _S433 * _S433), (1.17549435082228751e-38f)));
}

static __device__ float3  mix_0(float3  e1_0, float3  e2_0, float e3_0)
{
    return e1_0 * make_float3 (1.0f - e3_0) + e2_0 * make_float3 (e3_0);
}

__device__ __forceinline__ Weights lobeWeights(float3  in_dir_2, float3  v_5, float3  n_i_4, float3  ggx_n_0, float3  coat_h_0, AnisotropicFrame frame_2, BSDFMaterial material_3, float eta_i_2, float eta_o_2)
{
    float _S434 = dot_0(ggx_n_0, v_5);
    float _S435 = eta_i_2 / eta_o_2;
    float3  _S436 = refract_0(in_dir_2, ggx_n_0, _S435);
    float3  _S437 = ((((_S436)) * make_float3(rnorm3df(((_S436)).x, ((_S436)).y, ((_S436)).z))));
    float _S438 = (F32_min(((F32_sqrt((material_3.specular_level))) * (F32_abs((eta_i_2 - eta_o_2))) / (eta_i_2 + eta_o_2)), (0.9999847412109375f)));
    float _S439 = _S438 * _S438;
    float _S440 = (1.0f + _S438) / (1.0f - _S438);
    float _S441 = (F32_abs((_S434)));
    bool _S442 = eta_i_2 > eta_o_2;
    float sheen_component_0;
    if(_S442)
    {
        sheen_component_0 = _S440;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    float toon_component_0;
    if(_S442)
    {
        toon_component_0 = 1.0f;
    }
    else
    {
        toon_component_0 = _S440;
    }
    float _S443 = fresnel(_S441, sheen_component_0, toon_component_0);
    bool _S444 = (eta_i_2 * eta_i_2 * (1.0f - _S434 * _S434)) >= (eta_o_2 * eta_o_2);
    float3  _S445;
    if(_S444)
    {
        _S445 = make_float3 (1.0f);
    }
    else
    {
        float3  _S446 = material_3.specular_tint * make_float3 (_S439);
        _S445 = _S446 + (make_float3 (1.0f) - _S446) * make_float3 (_S443 - _S439) / make_float3 (1.0f - _S439);
    }
    float3  _S447 = make_float3 (1.0f);
    float3  _S448 = make_float3 (0.0f);
    float _S449 = rgb_to_greyscale(material_3.sheen);
    bool _S450 = _S449 > 0.0f;
    float3  sheen_1;
    float3  scale_1;
    if(_S450)
    {
        float _S451 = clamp_1((F32_sqrt(((F32_max((dot_0(n_i_4, v_5)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S452 = (U32_min((uint(_S451)), (22U)));
        float least_0 = (F32_sqrt((0.05000000074505806f)));
        float _S453 = (F32_sqrt((0.10000000149011612f)));
        bool _S454 = (material_3.velvet) > 0.0f;
        float _S455 = _slang_select(_S454, _S453,least_0);
        float _S456 = (clamp_1((F32_sqrt(((F32_max((material_3.sheen_roughness), (0.0f)))))), _S455, 1.0f) - _S455) / (1.0f - _S455) * 23.0f;
        uint _S457 = (U32_min((uint(_S456)), (22U)));
        uint _S458 = _S452 * 24U + _S457;
        float _S459 = _S451 - float(_S452);
        float _S460 = _S456 - float(_S457);
        uint _S461 = _S458 + 24U;
        float a_5 = SHEEN_ALBEDO_0[_S458] + (SHEEN_ALBEDO_0[_S461] - SHEEN_ALBEDO_0[_S458]) * _S459;
        uint _S462 = _S458 + 1U;
        uint _S463 = _S461 + 1U;
        float b_1 = SHEEN_ALBEDO_0[_S462] + (SHEEN_ALBEDO_0[_S463] - SHEEN_ALBEDO_0[_S462]) * _S459;
        float _S464 = (F32_exp((a_5 + (b_1 - a_5) * _S460)));
        if(_S454)
        {
            float a_6 = VELVET_ALBEDO_0[_S458] + (VELVET_ALBEDO_0[_S461] - VELVET_ALBEDO_0[_S458]) * _S459;
            float b_2 = VELVET_ALBEDO_0[_S462] + (VELVET_ALBEDO_0[_S463] - VELVET_ALBEDO_0[_S462]) * _S459;
            float _S465 = a_6 + (b_2 - a_6) * _S460;
            sheen_component_0 = _S465;
        }
        else
        {
            sheen_component_0 = _S464;
        }
        float _S466 = (F32_min((sheen_component_0), (1.0f)));
        float3  _S467 = make_float3 (1.0f) - material_3.sheen * make_float3 (_S466);
        float _S468 = rgb_to_greyscale(material_3.sheen);
        float _S469 = _S468 * _S466;
        float3  _S470 = material_3.sheen / make_float3 ((F32_max((sheen_component_0), (1.0f))));
        sheen_component_0 = _S469;
        sheen_1 = _S470;
        scale_1 = _S467;
    }
    else
    {
        sheen_component_0 = 0.0f;
        sheen_1 = _S448;
        scale_1 = _S447;
    }
    float _S471 = (F32_abs((material_3.toon.x)));
    bool _S472 = _S471 > 0.0f;
    if(_S472)
    {
        float _S473 = (F32_min((_S471), (1.0f)));
        float3  scale_2 = scale_1 * make_float3 (1.0f - _S473);
        float _S474 = rgb_to_greyscale(material_3.albedo);
        float _S475 = _S473 * _S474;
        toon_component_0 = _S475;
        scale_1 = scale_2;
    }
    else
    {
        toon_component_0 = 0.0f;
    }
    bool _S476 = (material_3.metallic) > 0.0f;
    float3  rebounce_0;
    if(_S476)
    {
        float _S477 = frame_2.alphas.x;
        float _S478 = (F32_sqrt(((F32_min((_S477), (frame_2.alphas.y))))));
        bool _S479 = _S477 > 0.0f;
        float _S480 = _slang_select(_S479, _S478,material_3.roughness);
        float _S481 = _S480 * _S480;
        float _S482 = (F32_pow((_S481), (1.81585001945495605f))) * (2.15371990203857422f - 0.73285001516342163f * _S481) / (1.0f + 1.28094995021820068f * _S481);
        bool _S483 = _S481 > 0.0f;
        float _S484 = _slang_select(_S483, _S482,0.0f);
        float _S485 = clamp_1(dot_0(n_i_4, v_5), 0.0f, 1.0f);
        float _S486 = _S481 * _S480;
        float _S487 = (F32_min((1.00064504146575928f - _S480 * (0.00375499995425344f + _S485 * (-0.04133399948477745f + _S485 * (-0.90938502550125122f + _S485 * 0.35275399684906006f))) - _S481 * (0.27602800726890564f + _S485 * (1.27023398876190186f + _S485 * 0.04740000143647194f)) - _S486 * (0.31452900171279907f - _S485 * 0.34830701351165771f) + _S486 * _S480 * 0.27229699492454529f), (1.0f)));
        float3  _S488 = min_1(make_float3 (1.0f) / (make_float3 (1.0f) - material_3.albedo * make_float3 (_S484)), make_float3 (1.0f / (F32_max((_S487), (0.0000152587890625f)))));
        rebounce_0 = _S488;
    }
    else
    {
        rebounce_0 = _S447;
    }
    bool _S489 = (dot_0(coat_h_0, coat_h_0)) > 0.0f;
    float coat_pdf_1;
    float3  coat_1;
    float3  up_0;
    float3  through_0;
    if(_S489)
    {
        float3  _S490 = coatNormal(material_3, n_i_4);
        float _S491 = material_3.coat_roughness;
        float _S492 = _S491 * _S491;
        float _S493 = (F32_max((material_3.coat_ior), (1.00999999046325684f)));
        float _S494 = dot_0(_S490, reflect_0(in_dir_2, coat_h_0));
        float _S495 = (F32_abs((dot_0(v_5, coat_h_0))));
        float _S496 = eta_i_2 / _S493 * (F32_sqrt(((F32_max((1.0f - _S495 * _S495), (0.0f))))));
        float _S497 = (F32_sqrt(((F32_max((1.0f - _S496 * _S496), (0.0f))))));
        float _S498 = _slang_select(_S442, _S497,_S495);
        float _S499 = _slang_select(_S442, _S493,1.0f);
        float _S500 = _slang_select(_S442, 1.0f,_S493);
        float _S501 = fresnel(_S498, _S499, _S500);
        float _S502 = smithG1(_S492, _S494);
        float _S503 = _S501 * _S502;
        bool _S504 = _S494 > 0.0f;
        float _S505 = _slang_select(_S504, _S503,0.0f);
        float _S506 = material_3.coat * _S505;
        float3  _S507 = material_3.coat_tint;
        float3  _S508 = _S507 * _S507;
        float3  _S509 = _slang_select(_S442, _S508,_S447);
        float3  _S510 = make_float3 (_S506) * _S509;
        float _S511 = dot_0(_S490, v_5);
        float _S512 = smithG1(_S492, _S511);
        float _S513 = trowbridgeReitz(_S492, dot_0(_S490, coat_h_0));
        float _S514 = _S512 * _S513 / (4.0f * _S511);
        bool _S515 = _S492 > 0.0f;
        float _S516 = _slang_select(_S515, _S514,0.0f);
        bool _S517 = !_S442;
        if(_S517)
        {
            float _S518 = _S493 * _S493;
            float _S519 = _S518 * _S518;
            float _S520 = _S493 - 1.0f;
            float _S521 = _S493 + 1.0f;
            float _S522 = _S518 - 1.0f;
            float _S523 = _S518 + 1.0f;
            float _S524 = _S519 - 1.0f;
            float _S525 = _S523 * _S524;
            float _S526 = 0.5f + _S520 * (3.0f * _S493 + 1.0f) / (6.0f * _S521 * _S521) + _S518 * _S522 * _S522 / (_S523 * _S523 * _S523) * (F32_log((_S520 / _S521))) - 2.0f * _S518 * _S493 * (_S518 + 2.0f * _S493 - 1.0f) / _S525 + 8.0f * _S519 * (_S519 + 1.0f) / (_S525 * _S524) * (F32_log((_S493)));
            float _S527 = 1.0f - (1.0f - _S526) / _S518;
            float3  _S528 = _S508 * make_float3 (1.0f - _S527) / (make_float3 (1.0f) - material_3.albedo * make_float3 (_S527));
            coat_1 = _S528;
        }
        else
        {
            coat_1 = _S447;
        }
        float _S529 = 1.0f - _S505;
        float3  _S530 = mix_0(_S447, make_float3 (_S529) * coat_1, material_3.coat);
        float3  _S531 = mix_0(_S447, make_float3 (_S529) * material_3.coat_tint, material_3.coat);
        coat_1 = _S510;
        up_0 = _S530;
        through_0 = _S531;
        coat_pdf_1 = _S516;
    }
    else
    {
        coat_1 = _S448;
        up_0 = _S447;
        through_0 = _S447;
        coat_pdf_1 = 0.0f;
    }
    float3  _S532 = scale_1 * coat_1;
    float _S533 = rgb_to_greyscale(_S532);
    float3  _S534 = mix_0(_S445, material_3.albedo * rebounce_0, material_3.metallic);
    float3  F_1 = _S534 * scale_1 * up_0;
    float _S535 = rgb_to_greyscale(F_1);
    float _S536 = 1.0f - material_3.metallic;
    float3  _S537 = make_float3 (1.0f) - _S445;
    float3  _S538 = make_float3 ((1.0f - material_3.transmission) * _S536) * _S537 * scale_1 * up_0;
    float3  _S539 = make_float3 (material_3.transmission * _S536) * _S537 * scale_1 * through_0;
    float _S540 = (F32_max((_S535), (0.0f)));
    float _S541 = rgb_to_greyscale(_S538);
    float _S542 = (F32_max((_S541), (0.0f)));
    float _S543 = rgb_to_greyscale(_S539);
    float _S544 = sign_0(length_0(_S437));
    float _S545 = (F32_max((_S543 * _S544), (0.0f)));
    float _S546 = _S540 + _S542 + _S545 + toon_component_0 + _S533;
    float _S547 = (F32_min((sheen_component_0), (1.0f)));
    bool _S548 = sheen_component_0 > 0.0f;
    bool _S549;
    if(_S548)
    {
        _S549 = !(_S546 > 0.0f);
    }
    else
    {
        _S549 = false;
    }
    float _S550 = _slang_select(_S549, 1.0f,_S547);
    float _S551 = (1.0f - _S550) / (F32_max((_S546), (0.0000152587890625f)));
    float _S552 = _S542 * _S551;
    float _S553 = _S540 * _S551;
    float _S554 = _S545 * _S551;
    return Weights_x24init_0(_S434, _S437, F_1, 1.0f, _S538, _S539, _S552, _S553, _S554, _S550, toon_component_0 * _S551, sheen_1, _S532, _S533 * _S551, coat_pdf_1);
}

__device__ float translucentShare(BSDFMaterial material_4)
{
    float _S555 = rgb_to_greyscale(material_4.translucent);
    float _S556 = rgb_to_greyscale(material_4.albedo);
    float _S557 = _S555 / (_S556 + _S555);
    bool _S558 = _S555 > 0.0f;
    float _S559 = _slang_select(_S558, _S557,0.0f);
    return _S559;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float n_i_dot_v_0, BSDFMaterial material_5, Weights w_1)
{
    float _S560 = translucentShare(material_5);
    float _S561 = w_1.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S562 = w_1.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S563 = 1.0f - _S560;
    bool _S564 = n_i_dot_l_0 < 0.0f;
    float _S565 = _slang_select(_S564, _S560,_S563);
    float _S566 = _S562 * _S565;
    bool _S567 = _S560 > 0.0f;
    float _S568 = _slang_select(_S567, _S566,_S561);
    bool _S569 = n_i_dot_v_0 > 0.0f;
    float _S570 = _slang_select(_S569, _S568,0.0f);
    return _S570;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_5, BSDFMaterial material_6, Weights w_2)
{
    float _S571 = translucentShare(material_6);
    bool _S572 = (dot_0(n_i_5, l_0)) < 0.0f;
    float3  _S573 = _slang_select(_S572, material_6.translucent,material_6.albedo);
    float _S574 = 1.0f - _S571;
    float _S575 = _slang_select(_S572, _S571,_S574);
    float3  _S576 = _S573 / make_float3 (_S575);
    bool _S577 = _S571 > 0.0f;
    float3  _S578 = _slang_select(_S577, _S576,material_6.albedo);
    return w_2.diffuse_weight * _S578 / make_float3 (w_2.p_diffuse);
}

__device__ float anisotropicG1(float3  w_3, float2  alphas_1)
{
    float _S579 = (F32_max((w_3.z), (0.0f)));
    return 2.0f * _S579 / (_S579 + length_0(make_float3 (alphas_1.x * w_3.x, alphas_1.y * w_3.y, _S579)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_2)
{
    float _S580 = alphas_2.x;
    float _S581 = h_0.x / _S580;
    float _S582 = alphas_2.y;
    float _S583 = h_0.y / _S582;
    float _S584 = h_0.z;
    float _S585 = _S581 * _S581 + _S583 * _S583 + _S584 * _S584;
    return 1.0f / (F32_max((3.14159274101257324f * _S580 * _S582 * _S585 * _S585), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float3  v_6, float3  h_1, float3  n_i_6, float n_i_dot_v_1, float alpha_5, AnisotropicFrame frame_3, float v_dot_h_1)
{
    float _S586 = dot_0(n_i_6, h_1);
    float _S587 = smithG1(alpha_5, n_i_dot_v_1);
    float _S588 = _S587 * v_dot_h_1;
    float _S589 = trowbridgeReitz(alpha_5, _S586);
    float _S590 = _S588 * _S589 / n_i_dot_v_1;
    bool _S591 = alpha_5 > 0.0f;
    bool _S592;
    if(_S591)
    {
        _S592 = v_dot_h_1 > 0.0f;
    }
    else
    {
        _S592 = false;
    }
    if(_S592)
    {
        _S592 = _S586 > 0.0f;
    }
    else
    {
        _S592 = false;
    }
    if(_S592)
    {
        _S592 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S592 = false;
    }
    float _S593 = _slang_select(_S592, _S590,0.0f);
    bool _S594 = (frame_3.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S594)
    {
        float3  _S595 = anisotropicLocal(v_6, frame_3.tangent, n_i_6);
        float _S596 = anisotropicG1(_S595, frame_3.alphas);
        float3  _S597 = anisotropicLocal(h_1, frame_3.tangent, n_i_6);
        float _S598 = anisotropicD(_S597, frame_3.alphas);
        float _S599 = _S596 * _S598;
        float _S600 = _S599 * v_dot_h_1 / n_i_dot_v_1;
        bool _S601 = v_dot_h_1 > 0.0f;
        if(_S601)
        {
            _S592 = _S586 > 0.0f;
        }
        else
        {
            _S592 = false;
        }
        if(_S592)
        {
            _S592 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S592 = false;
        }
        float _S602 = _slang_select(_S592, _S600,0.0f);
        pdf_h_0 = _S602;
    }
    else
    {
        pdf_h_0 = _S593;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float l_dot_h_0, float pdf_h_1, Weights w_4, float eta_i_3, float eta_o_3)
{
    float _S603 = eta_i_3 * w_4.v_dot_h + eta_o_3 * l_dot_h_0;
    float _S604 = w_4.p_refract * pdf_h_1 * eta_o_3 * eta_o_3 * (F32_abs((l_dot_h_0))) / (_S603 * _S603);
    bool _S605 = eta_i_3 != eta_o_3;
    bool _S606;
    if(_S605)
    {
        _S606 = l_dot_h_0 < 0.0f;
    }
    else
    {
        _S606 = false;
    }
    float _S607 = _slang_select(_S606, _S604,0.0f);
    return _S607;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_7, float alpha_6, AnisotropicFrame frame_4, BSDFMaterial material_7, Weights w_5)
{
    float _S608 = - dot_0(n_i_7, l_1);
    float _S609 = smithG1(alpha_6, (F32_max((_S608), (0.0f))));
    bool _S610 = (frame_4.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S610)
    {
        float3  _S611 = negate_0(n_i_7);
        float3  _S612 = anisotropicLocal(l_1, frame_4.tangent, _S611);
        float _S613 = anisotropicG1(_S612, frame_4.alphas);
        G1_l_0 = _S613;
    }
    else
    {
        G1_l_0 = _S609;
    }
    return w_5.refract_weight * make_float3 (G1_l_0) * material_7.albedo / make_float3 (w_5.p_refract);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_1, float n_i_dot_v_2, Weights w_6)
{
    float _S614 = w_6.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S615 = n_i_dot_l_1 > 0.0f;
    bool _S616;
    if(_S615)
    {
        _S616 = n_i_dot_v_2 > 0.0f;
    }
    else
    {
        _S616 = false;
    }
    float _S617 = _slang_select(_S616, _S614,0.0f);
    return _S617;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  v_7, float3  n_i_8, BSDFMaterial material_8, Weights w_7)
{
    float3  _S618 = l_2 + v_7;
    float3  _S619 = ((((_S618)) * make_float3(rnorm3df(((_S618)).x, ((_S618)).y, ((_S618)).z))));
    float _S620 = dot_0(n_i_8, _S619);
    float _S621 = (F32_max((dot_0(n_i_8, l_2)), (0.0f)));
    float _S622 = (F32_max((dot_0(n_i_8, v_7)), (0.0f)));
    float _S623 = 1.0f / (F32_max((material_8.sheen_roughness), (0.05000000074505806f)));
    float _S624 = 1.0f - _S620 * _S620;
    float _S625 = (2.0f + _S623) * (F32_pow(((F32_max((_S624), (0.0f)))), (0.5f * _S623))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S621 + _S622 - _S621 * _S622)), (0.0000152587890625f)));
    bool _S626 = (material_8.velvet) > 0.0f;
    float f_1;
    if(_S626)
    {
        float _S627 = (F32_max((material_8.sheen_roughness), (0.00999999977648258f)));
        float _S628 = _S627 * _S627;
        float _S629 = (F32_max((_S624), (0.0000152587890625f)));
        float _S630 = (F32_exp((- _S620 * _S620 / (_S629 * _S628)))) / (3.14159274101257324f * _S628 * _S629 * _S629) * (F32_min((1.0f), (2.0f * _S620 * (F32_min((_S621), (_S622))) / (F32_max(((F32_abs((dot_0(_S619, v_7))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S621 * _S622), (0.0000152587890625f)));
        f_1 = _S630;
    }
    else
    {
        f_1 = _S625;
    }
    return w_7.sheen * make_float3 (f_1 * _S621 * 2.0f * 3.14159274101257324f / w_7.p_sheen_velvet);
}

__device__ __forceinline__ float coatPDF(Weights w_8)
{
    return w_8.p_coat * w_8.coat_pdf;
}

__device__ __forceinline__ float3  coatBSDF(Weights w_9)
{
    return w_9.coat / make_float3 (w_9.p_coat);
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
    ToonShape _S631;
    (&_S631)->toon = toon_0;
    (&_S631)->a = a_7;
    (&_S631)->s = s_0;
    (&_S631)->b = b_3;
    (&_S631)->glossy = glossy_0;
    (&_S631)->norm = norm_0;
    (&_S631)->view = view_0;
    (&_S631)->axis = axis_0;
    return _S631;
}

__device__ __forceinline__ ToonShape toonShape(float3  v_8, float3  n_i_9, BSDFMaterial material_9)
{
    float _S632 = material_9.toon.x;
    bool _S633 = _S632 < 0.0f;
    float3  _S634 = make_float3 ((F32_min(((F32_abs((_S632)))), (1.0f)))) * material_9.albedo;
    float _S635 = clamp_1(material_9.toon.y / _S632, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S636 = clamp_1(material_9.toon.z / _S632, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S637 = (F32_min((_S635 + _S636), (1.57079637050628662f)));
    float integral_0;
    if(_S633)
    {
        integral_0 = 1.0f - (F32_cos(((F32_min((_S637), (_S635))))));
    }
    else
    {
        float _S638 = (F32_sin(((F32_min((_S637), (_S635))))));
        integral_0 = _S638 * _S638 / 2.0f;
    }
    bool _S639 = _S637 > _S635;
    bool _S640;
    if(_S639)
    {
        _S640 = _S636 > 0.0f;
    }
    else
    {
        _S640 = false;
    }
    float _S641;
    if(_S640)
    {
        if(_S633)
        {
            float _S642 = (F32_cos((_S635)));
            float _S643 = (F32_cos((_S637)));
            _S641 = (1.0f + _S635 / _S636) * (_S642 - _S643) - ((F32_sin((_S637))) - _S637 * _S643 - ((F32_sin((_S635))) - _S635 * _S642)) / _S636;
        }
        else
        {
            float _S644 = 2.0f * _S635;
            float _S645 = (F32_cos((_S644)));
            float _S646 = 2.0f * _S637;
            float _S647 = (F32_cos((_S646)));
            _S641 = (1.0f + _S635 / _S636) * (_S645 - _S647) / 4.0f - ((F32_sin((_S646))) / 8.0f - _S637 * _S647 / 4.0f - ((F32_sin((_S644))) / 8.0f - _S635 * _S645 / 4.0f)) / _S636;
        }
        float integral_1 = integral_0 + _S641;
        integral_0 = integral_1;
    }
    float _S648 = dot_0(n_i_9, v_8);
    float _S649 = (F32_acos(((F32_min((_S648), (1.0f))))));
    if(_S649 < _S635)
    {
        _S641 = 1.0f;
    }
    else
    {
        _S641 = (F32_max((1.0f - (_S649 - _S635) / (F32_max((_S636), (0.0000152587890625f)))), (0.0f)));
    }
    float3  _S650;
    if(_S633)
    {
        float3  _S651 = make_float3 (2.0f * _S648) * n_i_9 - v_8;
        float3  _S652 = ((((_S651)) * make_float3(rnorm3df(((_S651)).x, ((_S651)).y, ((_S651)).z))));
        _S650 = _S652;
    }
    else
    {
        _S650 = n_i_9;
    }
    return ToonShape_x24init_0(_S634, _S635, _S636, _S637, _S633, 6.28318548202514648f * integral_0, _S641, _S650);
}

__device__ __forceinline__ float toonPDF(float n_i_dot_l_2, float l_dot_h_1, ToonShape shape_0, Weights w_10)
{
    float _S653 = _slang_select(shape_0.glossy, l_dot_h_1,n_i_dot_l_2);
    float _S654 = (F32_acos((clamp_1(_S653, -1.0f, 1.0f))));
    float _S655;
    if(_S654 < (shape_0.a))
    {
        _S655 = 1.0f;
    }
    else
    {
        _S655 = (F32_max((1.0f - (_S654 - shape_0.a) / (F32_max((shape_0.s), (0.0000152587890625f)))), (0.0f)));
    }
    float _S656 = w_10.p_toon * _S655;
    float _S657 = _slang_select(shape_0.glossy, 1.0f,n_i_dot_l_2);
    float _S658 = _S656 * _S657 / shape_0.norm;
    bool _S659;
    if(shape_0.glossy)
    {
        _S659 = true;
    }
    else
    {
        _S659 = n_i_dot_l_2 > 0.0f;
    }
    float _S660 = _slang_select(_S659, _S658,0.0f);
    return _S660;
}

__device__ __forceinline__ float3  toonBSDF(float3  l_3, float3  n_i_10, ToonShape shape_1, Weights w_11)
{
    float _S661 = (F32_max((dot_0(n_i_10, l_3)), (0.0f)));
    float _S662 = _slang_select(shape_1.glossy, _S661,shape_1.view);
    return shape_1.toon * make_float3 (_S662) / make_float3 (w_11.p_toon);
}

__device__ __forceinline__ float reflectPDF(float pdf_h_2, Weights w_12)
{
    float _S663 = w_12.p_reflect * pdf_h_2 / (4.0f * w_12.v_dot_h);
    bool _S664 = pdf_h_2 > 0.0f;
    float _S665 = _slang_select(_S664, _S663,0.0f);
    return _S665;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_4, float3  n_i_11, float alpha_7, AnisotropicFrame frame_5, Weights w_13)
{
    float _S666 = dot_0(n_i_11, l_4);
    float _S667 = smithG1(alpha_7, (F32_max((_S666), (0.0f))));
    bool _S668 = (frame_5.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S668)
    {
        float3  _S669 = anisotropicLocal(l_4, frame_5.tangent, n_i_11);
        float _S670 = anisotropicG1(_S669, frame_5.alphas);
        G1_l_1 = _S670;
    }
    else
    {
        G1_l_1 = _S667;
    }
    return make_float3 (w_13.reflect_weight * G1_l_1) * w_13.F / make_float3 (w_13.p_reflect);
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_3, float3  out_dir_2, float3  n_8, BSDFMaterial material_10, float eta_i_4, float eta_o_4, bool refracted_2, uint random_state_5, FixedArray<float3 , 6>  * throughputs_0, FixedArray<float, 6>  * pdfs_0)
{
    float3  ggx_n_1;
    float3  _S671 = negate_0(in_dir_3);
    float _S672 = dot_0(n_8, _S671);
    float _S673 = sign_0(_S672);
    float3  _S674 = n_8 * make_float3 (_S673);
    float _S675 = dot_0(_S674, out_dir_2);
    float _S676 = material_10.roughness;
    float _S677 = _S676 * _S676;
    AnisotropicFrame _S678 = anisotropicFrame(material_10, _S674);
    float _S679 = rgb_to_greyscale(material_10.translucent);
    bool _S680 = _S679 > 0.0f;
    bool _S681 = (dot_0(n_8, out_dir_2) * _S672) < 0.0f;
    bool _S682 = (F32_abs((material_10.toon.x))) > 0.0f;
    bool _S683 = (material_10.coat) > 0.0f;
    uint _S684;
    if(_S683)
    {
        _S684 = 6U;
    }
    else
    {
        if(_S682)
        {
            _S684 = 5U;
        }
        else
        {
            _S684 = 4U;
        }
    }
    uint i_8 = 0U;
    for(;;)
    {
        if(i_8 < 6U)
        {
        }
        else
        {
            break;
        }
        float3  _S685 = make_float3 (0.0f);
        (*throughputs_0)[i_8] = _S685;
        (*pdfs_0)[i_8] = 0.0f;
        uint i_9 = i_8 + 1U;
        i_8 = i_9;
    }
    float3  _S686 = coatHalf(_S671, _S674, material_10, random_state_5);
    float3  _S687 = make_float3 (0.0f);
    Weights _S688 = Weights_x24init_0(0.0f, _S687, _S687, 0.0f, _S687, _S687, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, _S687, _S687, 0.0f, 0.0f);
    uint half_of_0 = 4294967295U;
    Weights w_14 = _S688;
    float3  ggx_n_2 = _S687;
    i_8 = 0U;
    for(;;)
    {
        if(i_8 < _S684)
        {
        }
        else
        {
            break;
        }
        uint _S689;
        if(i_8 == 3U)
        {
            _S689 = 4U;
        }
        else
        {
            if(i_8 == 4U)
            {
                _S689 = 6U;
            }
            else
            {
                if(i_8 == 5U)
                {
                    _S689 = 5U;
                }
                else
                {
                    _S689 = i_8;
                }
            }
        }
        bool _S690 = _S689 == 0U;
        bool _S691;
        if(_S690)
        {
            _S691 = _S680;
        }
        else
        {
            _S691 = false;
        }
        bool _S692;
        if(_S691)
        {
            _S692 = _S681;
        }
        else
        {
            _S692 = _S689 == 1U;
        }
        bool _S693 = _S692 != refracted_2;
        bool _S694;
        if(_S693)
        {
            _S694 = true;
        }
        else
        {
            bool _S695 = _S689 == 6U;
            if(_S695)
            {
                _S694 = !_S682;
            }
            else
            {
                _S694 = false;
            }
        }
        if(_S694)
        {
            ggx_n_1 = ggx_n_2;
            uint i_10 = i_8 + 1U;
            ggx_n_2 = ggx_n_1;
            i_8 = i_10;
            continue;
        }
        uint _S696;
        if(_S689 == 6U)
        {
            _S696 = 0U;
        }
        else
        {
            if(_S689 == 4U)
            {
                _S696 = 2U;
            }
            else
            {
                _S696 = _S689;
            }
        }
        bool _S697 = _S696 != half_of_0;
        uint half_of_1;
        Weights w_15;
        if(_S697)
        {
            bool _S698 = _S696 == 0U;
            bool _S699;
            if(_S698)
            {
                _S699 = true;
            }
            else
            {
                _S699 = _S696 == 5U;
            }
            if(_S699)
            {
                float3  _S700 = sampledHalf(_S671, _S674, _S677, _S678, random_state_5);
                ggx_n_1 = _S700;
            }
            else
            {
                bool _S701 = _S696 == 1U;
                if(_S701)
                {
                    float3  _S702 = refractedHalf(in_dir_3, out_dir_2, n_8, eta_i_4, eta_o_4);
                    ggx_n_1 = _S702;
                }
                else
                {
                    float3  _S703 = reflectedHalf(in_dir_3, out_dir_2);
                    ggx_n_1 = _S703;
                }
            }
            float3  _S704 = reflectedHalf(in_dir_3, out_dir_2);
            bool _S705 = _S689 == 5U;
            float3  _S706 = _slang_select(_S705, _S704,_S686);
            Weights _S707 = lobeWeights(in_dir_3, _S671, _S674, ggx_n_1, _S706, _S678, material_10, eta_i_4, eta_o_4);
            w_15 = _S707;
            half_of_1 = _S696;
        }
        else
        {
            w_15 = w_14;
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S689)
        {
        case 0U:
            {
                float _S708 = diffusePDF(_S675, (F32_abs((_S672))), material_10, w_15);
                (*pdfs_0)[int(0)] = _S708;
                float3  _S709 = diffuseBSDF(out_dir_2, _S674, material_10, w_15);
                (*throughputs_0)[int(0)] = _S709;
                break;
            }
        case 1U:
            {
                float _S710 = dot_0(out_dir_2, ggx_n_1);
                float _S711 = vndfPDF(_S671, ggx_n_1, _S674, (F32_abs((_S672))), _S677, _S678, w_15.v_dot_h);
                float _S712 = refractPDF(_S710, _S711, w_15, eta_i_4, eta_o_4);
                (*pdfs_0)[int(1)] = _S712;
                float3  _S713 = refractBSDF(out_dir_2, _S674, _S677, _S678, material_10, w_15);
                (*throughputs_0)[int(1)] = _S713;
                break;
            }
        case 4U:
            {
                float _S714 = sheenVelvetPDF(_S675, (F32_abs((_S672))), w_15);
                (*pdfs_0)[int(3)] = _S714;
                float3  _S715 = sheenVelvetBSDF(out_dir_2, _S671, _S674, material_10, w_15);
                (*throughputs_0)[int(3)] = _S715;
                break;
            }
        case 5U:
            {
                float _S716 = coatPDF(w_15);
                (*pdfs_0)[int(5)] = _S716;
                float3  _S717 = coatBSDF(w_15);
                (*throughputs_0)[int(5)] = _S717;
                break;
            }
        case 6U:
            {
                ToonShape _S718 = toonShape(_S671, _S674, material_10);
                float _S719 = toonPDF(_S675, dot_0(out_dir_2, _S718.axis), _S718, w_15);
                (*pdfs_0)[int(4)] = _S719;
                float3  _S720 = toonBSDF(out_dir_2, _S674, _S718, w_15);
                (*throughputs_0)[int(4)] = _S720;
                break;
            }
        default:
            {
                float _S721 = vndfPDF(_S671, ggx_n_1, _S674, (F32_abs((_S672))), _S677, _S678, w_15.v_dot_h);
                float _S722 = reflectPDF(_S721, w_15);
                (*pdfs_0)[int(2)] = _S722;
                float3  _S723 = reflectBSDF(out_dir_2, _S674, _S677, _S678, w_15);
                (*throughputs_0)[int(2)] = _S723;
                break;
            }
        }
        half_of_0 = half_of_1;
        w_14 = w_15;
        uint i_10 = i_8 + 1U;
        ggx_n_2 = ggx_n_1;
        i_8 = i_10;
    }
    i_8 = 0U;
    ggx_n_1 = _S687;
    for(;;)
    {
        if(i_8 < 6U)
        {
        }
        else
        {
            break;
        }
        bool _S724 = ((*pdfs_0)[i_8]) > 0.0f;
        if(_S724)
        {
            float3  f_2 = ggx_n_1 + (*throughputs_0)[i_8] * make_float3 ((*pdfs_0)[i_8]);
            ggx_n_1 = f_2;
        }
        uint i_11 = i_8 + 1U;
        i_8 = i_11;
    }
    return ggx_n_1;
}

static __device__ __forceinline__ float3  skyLobes_0(float3  in_dir_4, float3  dir_3, FKSurface * surface_1, float2  eta_1, bool is_inside_2, float pdf_0, uint random_state_6, FixedArray<float3 , 6>  * terms_0, FixedArray<float, 6>  * pdfs_1)
{
    bool _S725 = wrongSide_0(is_inside_2, false, dir_3, surface_1->geometry_n);
    float3  _S726 = BSDF(in_dir_4, dir_3, surface_1->smooth_n, surface_1->material, eta_1.x, eta_1.y, _S725, random_state_6, terms_0, pdfs_1);
    float3  _S727 = make_float3 (0.0f);
    uint i_12 = 0U;
    float3  f_3 = _S727;
    for(;;)
    {
        if(i_12 < 6U)
        {
        }
        else
        {
            break;
        }
        bool _S728 = ((*pdfs_1)[i_12]) > 0.0f;
        if(_S728)
        {
            float3  _S729 = (*terms_0)[i_12] * make_float3 ((*pdfs_1)[i_12]) / make_float3 ((*pdfs_1)[i_12] + pdf_0);
            (*terms_0)[i_12] = _S729;
            float3  f_4 = f_3 + (*terms_0)[i_12];
            f_3 = f_4;
        }
        uint i_13 = i_12 + 1U;
        i_12 = i_13;
    }
    return f_3;
}

__device__ float3  skyBSDF(float3  in_dir_5, float3  dir_4, FKSurface surface_2, float2  eta_2, bool is_inside_3, float pdf_1, uint random_state_7)
{
    FKSurface _S730 = surface_2;
    FixedArray<float3 , 6>  terms_1;
    FixedArray<float, 6>  pdfs_2;
    float3  _S731 = skyLobes_0(in_dir_5, dir_4, &_S730, eta_2, is_inside_3, pdf_1, random_state_7, &terms_1, &pdfs_2);
    return _S731;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_5, float3  radiance_0, float3  color_0, uint random_state_8)
{
    SkySample _S732;
    (&_S732)->dir = dir_5;
    (&_S732)->radiance = radiance_0;
    (&_S732)->color = color_0;
    (&_S732)->random_state = random_state_8;
    return _S732;
}

static __device__ __noinline__ float3  skyColor_0(float3  in_dir_6, float3  dir_6, FKSurface * surface_3, float2  eta_3, bool is_inside_4, float pdf_2, uint random_state_9, uint depth_0)
{
    FixedArray<float3 , 6>  terms_2;
    FixedArray<float, 6>  pdfs_3;
    float3  _S733 = skyLobes_0(in_dir_6, dir_6, surface_3, eta_3, is_inside_4, pdf_2, random_state_9, &terms_2, &pdfs_3);
    float3  _S734 = make_float3 (0.0f);
    bool shaded_0 = false;
    float3  world_0 = _S734;
    uint i_14 = 0U;
    float3  color_1 = _S734;
    for(;;)
    {
        if(i_14 < 6U)
        {
        }
        else
        {
            break;
        }
        bool _S735 = (pdfs_3[i_14]) > 0.0f;
        if(_S735)
        {
            bool _S736 = (fcptWorldReadsPath());
            bool _S737;
            if(_S736)
            {
                _S737 = true;
            }
            else
            {
                _S737 = !shaded_0;
            }
            bool shaded_1;
            float3  world_1;
            if(_S737)
            {
                uint _S738;
                if(i_14 == 3U)
                {
                    _S738 = 4U;
                }
                else
                {
                    if(i_14 == 4U)
                    {
                        _S738 = 6U;
                    }
                    else
                    {
                        if(i_14 == 5U)
                        {
                            _S738 = 5U;
                        }
                        else
                        {
                            _S738 = i_14;
                        }
                    }
                }
                float3  _S739 = (fcptEnvMapSample((dir_6), (depth_0), (_S738)));
                world_1 = _S739;
                shaded_1 = true;
            }
            else
            {
                world_1 = world_0;
                shaded_1 = shaded_0;
            }
            float3  color_2 = color_1 + terms_2[i_14] * world_1;
            shaded_0 = shaded_1;
            world_0 = world_1;
            color_1 = color_2;
        }
        uint i_15 = i_14 + 1U;
        i_14 = i_15;
    }
    return color_1;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_4, float2  eta_4, bool is_inside_5, uint init_random_state_0, uint lobe_state_0, ShadowContext * context_2)
{
    uint2  _S740 = (fcptEnvironmentCdfSize());
    uint2  _S741 = make_uint2 (1U, 0U);
    uint2  _S742 = _S740 - _S741;
    Random _S743 = draw(init_random_state_0, 6U);
    Random _S744 = draw(init_random_state_0, 2147483654U);
    Random _S745 = draw(init_random_state_0, 7U);
    Random _S746 = draw(init_random_state_0, 2147483655U);
    uint _S747 = _S742.x;
    uint _S748 = searchCDF_0(make_uint2 (_S747, 0U), make_uint2 (0U, 1U), _S742.y, _S743.value);
    uint _S749 = searchCDF_0(make_uint2 (0U, _S748), _S741, _S747, _S744.value);
    float2  _S750 = make_float2 ((float)_S742.x, (float)_S742.y);
    float2  _S751 = (make_float2 (float(_S749), float(_S748)) + make_float2 (_S745.value, _S746.value)) / _S750 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S752 = _S751.y;
    float _S753 = (F32_sin((_S752)));
    float _S754 = _S751.x;
    float3  _S755 = make_float3 (- _S753 * (F32_cos((_S754))), _S753 * (F32_sin((_S754))), (F32_cos((_S752))));
    float _S756 = environmentPdf_0(_S755);
    float3  _S757 = ray_0->unit_direction;
    float3  _S758 = skyBSDF(ray_0->unit_direction, _S755, *surface_4, eta_4, is_inside_5, _S756, lobe_state_0);
    bool _S759 = !(_S756 > 0.0f);
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
        return SkySample_x24init_0(_S755, _S761, _S761, _S746.state);
    }
    bool _S762 = (fcptWorldReadsPath());
    float3  seen_0;
    if(_S762)
    {
        float3  _S763 = skyColor_0(_S757, _S755, surface_4, eta_4, is_inside_5, _S756, lobe_state_0, context_2->depth + 1U);
        seen_0 = _S763;
    }
    else
    {
        seen_0 = _S758;
    }
    float3  _S764 = skyRadiance_0(ray_0->origin, surface_4, is_inside_5, _S755, context_2, _S746.state);
    return SkySample_x24init_0(_S755, _S764, seen_0 * _S764, _S746.state);
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

static __device__ TreeSample TreeSample_x24init_0(float3  dir_7, float3  radiance_1, float density_0, uint random_state_10)
{
    TreeSample _S771;
    (&_S771)->dir = dir_7;
    (&_S771)->radiance = radiance_1;
    (&_S771)->density = density_0;
    (&_S771)->random_state = random_state_10;
    return _S771;
}

__device__ uint pickChild(LightNode first_2, LightNode second_1, float3  p_12, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S772 = importance(first_2, p_12, normal_3);
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
        int i_16 = int(0);
        float sum_0 = 0.0f;
        for(;;)
        {
            if(i_16 < int(3))
            {
            }
            else
            {
                break;
            }
            float sum_1 = sum_0 + _slang_vector_get_element(left_1, i_16) * _slang_vector_get_element(right_1.rows[i_16], j_1);
            i_16 = i_16 + int(1);
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
    uint n_9 = 0U;
    for(;;)
    {
        uint4  _S811 = (fcptLightNode((n_9)));
        if((_S811.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S812 = (fcptLightSecond((n_9)));
        uint _S813 = n_9 + 1U;
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
        n_9 = _S819;
    }
    bool _S820 = n_9 == 0U;
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
    uint4  _S824 = (fcptLightNode((n_9)));
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

__device__ float powerHeuristic(float a_8, float b_4)
{
    float _S869 = 1.0f / (1.0f + b_4 / a_8 * (b_4 / a_8));
    bool _S870 = b_4 > 0.0f;
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

static __device__ float3  environment_0(float3  dir_8, uint depth_1, uint lobe_0)
{
    uint2  _S876 = (fcptEnvironmentMapSize());
    bool _S877 = (_S876.x) > 1U;
    bool _S878;
    if(_S877)
    {
        uint2  _S879 = (fcptEnvironmentMapSize());
        _S878 = (_S879.y) > 1U;
    }
    else
    {
        _S878 = false;
    }
    if(_S878)
    {
        float3  _S880 = (fcptEnvMapSample((dir_8), (depth_1), (lobe_0)));
        return _S880;
    }
    float3  _S881 = (fcptAmbient());
    return _S881;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S882 = (fcptEnvironmentCdfSize());
    bool _S883 = (_S882.x) > 1U;
    bool _S884;
    if(_S883)
    {
        uint2  _S885 = (fcptEnvironmentCdfSize());
        _S884 = (_S885.y) > 1U;
    }
    else
    {
        _S884 = false;
    }
    bool _S886 = !_S884;
    if(_S886)
    {
        return false;
    }
    uint2  _S887 = (fcptEnvironmentMapSize());
    bool _S888 = (_S887.x) > 1U;
    if(_S888)
    {
        uint2  _S889 = (fcptEnvironmentMapSize());
        _S884 = (_S889.y) > 1U;
    }
    else
    {
        _S884 = false;
    }
    return _S884;
}

static __device__ float escapeWeight_0(float pdf_3, float3  dir_9)
{
    bool _S890 = pdf_3 <= 0.0f;
    bool _S891;
    if(_S890)
    {
        _S891 = true;
    }
    else
    {
        bool _S892 = environmentMapped_0();
        _S891 = !_S892;
    }
    if(_S891)
    {
        return 1.0f;
    }
    float _S893 = environmentPdf_0(dir_9);
    return pdf_3 / (pdf_3 + _S893);
}

static __device__ void restir_duplicates_0(uint3  global_invocation_id_1, uint3  local_invocation_id_0, uint local_invocation_index_3)
{
    uint2  _S894 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S895 = make_int2 ((int)_S894.x, (int)_S894.y);
    uint _S896 = previousSeed_0(_S895);
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
            uint _S897 = previousSeed_0(_S895 + make_int2 (x_16, y_5));
            bool _S898 = _S897 == _S896;
            uint _S899 = _slang_select(_S898, 1U,0U);
            uint count_3 = count_2 + _S899;
            int x_17 = x_16 + int(1);
            x_16 = x_17;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S900 = float(count_2 - 1U) / 288.0f;
    bool _S901 = _S896 != 0U;
    float _S902 = _slang_select(_S901, _S900,0.0f);
    fcptStoreDuplication((_S895), (make_uint4 ((F32_asuint((_S902))), 0U, 0U, 0U)));
    return;
}

static __device__ float3  abs_0(float3  x_18)
{
    float3  result_7;
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
        *_slang_vector_get_element_ptr(&result_7, i_17) = (F32_abs((_slang_vector_get_element(x_18, i_17))));
        i_17 = i_17 + int(1);
    }
    return result_7;
}

__device__ float resamplingTarget(float3  f_5)
{
    float _S903 = rgb_to_greyscale(abs_0(f_5));
    return _S903;
}

static __device__ float4  asfloat_0(uint4  x_19)
{
    float4  result_8;
    int i_18 = int(0);
    for(;;)
    {
        if(i_18 < int(4))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_8, i_18) = (U32_asfloat((_slang_vector_get_element(x_19, i_18))));
        i_18 = i_18 + int(1);
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
    float _S904 = resamplingTarget(weight_0);
    bool _S905 = _S904 > 0.0f;
    bool _S906;
    if(_S905)
    {
        _S906 = _S904 < 3.00000000549775576e+38f;
    }
    else
    {
        _S906 = false;
    }
    bool _S907 = !_S906;
    if(_S907)
    {
        return;
    }
    bool _S908 = sel_2->sums;
    if(_S908)
    {
        float3  _S909 = sel_2->color + weight_0;
        sel_2->color = _S909;
        return;
    }
    float _S910 = sel_2->w_sum + _S904;
    sel_2->w_sum = _S910;
    float3  _S911 = sel_2->color + weight_0;
    sel_2->color = _S911;
    Random _S912 = pcg(sel_2->random_state);
    sel_2->random_state = _S912.state;
    bool _S913 = (_S912.value * sel_2->w_sum) <= _S904;
    if(_S913)
    {
        sel_2->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_3;
    float3  _S914 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S914;
    float _S915 = r_3.jac * shifted_0.jac;
    (&candidate_1)->jac = _S915;
    offer(sel_3, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S916 = resamplingTarget((&r_4)->f);
    float _S917 = sel_4.w_sum / _S916;
    bool _S918 = _S916 > 0.0f;
    float _S919 = _slang_select(_S918, _S917,0.0f);
    (&r_4)->w = _S919;
    (&r_4)->c = c_1;
    return r_4;
}

static __device__ uint2  asuint_0(float2  x_20)
{
    uint2  result_9;
    int i_19 = int(0);
    for(;;)
    {
        if(i_19 < int(2))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_9, i_19) = (F32_asuint((_slang_vector_get_element(x_20, i_19))));
        i_19 = i_19 + int(1);
    }
    return result_9;
}

static __device__ void restir_spatial_0(uint3  global_invocation_id_2)
{
    uint2  _S920 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S921 = make_int2 ((int)_S920.x, (int)_S920.y);
    float3  _S922 = make_float3 (0.0f);
    FKHit _S923 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S924 = Domain_x24init_0(_S922, _S922, &_S923, 0.0f, 0.0f);
    Domain dom_4 = _S924;
    bool _S925 = (fcptCurrentDomain((_S921), (&dom_4)));
    bool _S926 = !_S925;
    if(_S926)
    {
        Reservoir _S927 = (Reservoir{});
        fcptStoreReservoirPrevious((_S921), (_S927), ((&dom_4)->hit));
        return;
    }
    Reservoir _S928 = (fcptLoadReservoirTemporal((_S921)));
    uint t_13 = 0U;
    float count_4 = 0.0f;
    float c_sum_1 = _S928.c;
    for(;;)
    {
        uint _S929 = (fcptRestirNeighbours());
        if(t_13 < _S929)
        {
        }
        else
        {
            break;
        }
        int2  _S930 = partner_0(_S921, t_13);
        Domain neighbor_0 = _S924;
        bool _S931 = (fcptCurrentDomain((_S930), (&neighbor_0)));
        if(_S931)
        {
            float count_5 = count_4 + 1.0f;
            uint4  _S932 = (fcptReservoirTemporal((_S930), (0U)));
            float c_sum_2 = c_sum_1 + (U32_asfloat((_S932.w)));
            count_4 = count_5;
            c_sum_1 = c_sum_2;
        }
        uint t_14 = t_13 + 1U;
        t_13 = t_14;
    }
    float _S933 = _S928.c / (F32_max((count_4), (1.0f)));
    float _S934 = resamplingTarget(_S928.f);
    bool _S935 = count_4 == 0.0f;
    float _S936 = _slang_select(_S935, 1.0f,0.0f);
    Selection _S937 = (Selection{});
    Selection sel_5 = _S937;
    uint _S938 = (fcptFrame());
    uint _S939 = hash(_S938);
    uint _S940 = global_invocation_id_2.x;
    uint2  _S941 = (fcptRenderSize());
    uint _S942 = stream(_S939, _S940 + _S941.x * global_invocation_id_2.y);
    uint _S943 = stream(_S942, 195U);
    (&sel_5)->random_state = _S943;
    t_13 = 0U;
    float canonical_mis_0 = _S936;
    for(;;)
    {
        uint _S944 = (fcptRestirNeighbours());
        if(t_13 < _S944)
        {
        }
        else
        {
            break;
        }
        int2  _S945 = partner_0(_S921, t_13);
        Domain neighbor_dom_0 = _S924;
        bool _S946 = (fcptCurrentDomain((_S945), (&neighbor_dom_0)));
        if(_S946)
        {
            Reservoir _S947 = (fcptLoadReservoirTemporal((_S945)));
            uint4  _S948 = (fcptShiftData((_S945), (t_13)));
            float4  _S949 = asfloat_0(_S948);
            uint4  _S950 = (fcptShiftData((_S921), (t_13)));
            float4  _S951 = asfloat_0(_S950);
            float _S952 = pairShare(_S947.c, _S933, c_sum_1);
            bool _S953 = _S934 > 0.0f;
            float canonical_mis_1;
            if(_S953)
            {
                float _S954 = resamplingTarget(float3 {_S951.x, _S951.y, _S951.z});
                float _S955 = canonicalWeight(_S952, _S933, _S934, _S947.c, _S954);
                float canonical_mis_2 = canonical_mis_0 + _S955;
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float3  _S956 = float3 {_S949.x, _S949.y, _S949.z};
            Shift _S957 = Shift_x24init_0(_S956, _S949.w);
            float _S958 = resamplingTarget(_S947.f);
            float _S959 = resamplingTarget(_S956);
            float _S960 = neighborWeight(_S952, _S947.c, _S958, _S933, _S959);
            offerShifted(&sel_5, _S947, _S957, _S960);
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_15 = t_13 + 1U;
        t_13 = t_15;
    }
    offerShifted(&sel_5, _S928, Shift_x24init_0(_S928.f, 1.0f), canonical_mis_0);
    Reservoir _S961 = finalize(sel_5, c_sum_1);
    fcptStoreReservoirPrevious((_S921), (_S961), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S921), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S921), (make_float4 ((&sel_5)->color.x, (&sel_5)->color.y, (&sel_5)->color.z, 0.0f)));
    return;
}

static __device__ uint3  asuint_1(float3  x_21)
{
    uint3  result_10;
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
        *_slang_vector_get_element_ptr(&result_10, i_20) = (F32_asuint((_slang_vector_get_element(x_21, i_20))));
        i_20 = i_20 + int(1);
    }
    return result_10;
}

static __device__ void restir_shift_0(uint3  workgroup_id_1, uint local_invocation_index_4)
{
    uint _S962 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S963 = _S962 != 4294967295U;
    if(_S963)
    {
        uint2  _S964 = make_uint2 (_S962, _S962 >> 14U) & make_uint2 (16383U);
        int2  _S965 = make_int2 ((int)_S964.x, (int)_S964.y);
        ShiftJob _S966 = (ShiftJob{});
        ShiftJob shift_job_0 = _S966;
        Shift _S967 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S968 = _S962 >> 28U;
        bool _S969 = spatialJob_0(_S965, _S968, &shift_job_0, true);
        Shift shifted_1;
        if(_S969)
        {
            Domain _S970 = (&shift_job_0)->dom;
            Reservoir _S971 = (&shift_job_0)->r;
            Shift _S972 = passShift_0(&_S970, &_S971);
            shifted_1 = _S972;
        }
        else
        {
            shifted_1 = _S967;
        }
        fcptStoreShiftData((_S965), (_S968), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S973 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S974 = make_int2 ((int)_S973.x, (int)_S973.y);
    FixedArray<uint, 3>  _S975;
    spatialBins_0(_S974, &_S975);
    FixedArray<uint, 3>  _S976 = _S975;
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
        bool _S977 = (_S976[t_16]) == 40U;
        if(_S977)
        {
            fcptStoreShiftData((_S974), (t_16), (make_uint4 (0U)));
        }
        uint t_17 = t_16 + 1U;
        t_16 = t_17;
    }
    FixedArray<uint, 3>  _S978 = _S976;
    queueShifts_0(_S974, &_S978, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S979 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S980 = make_int2 ((int)_S979.x, (int)_S979.y);
    FixedArray<uint, 3>  _S981;
    spatialBins_0(_S980, &_S981);
    FixedArray<uint, 3>  _S982 = _S981;
    countShifts_0(&_S982, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S983 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S984 = _S983 != 4294967295U;
    if(_S984)
    {
        uint2  _S985 = make_uint2 (_S983, _S983 >> 14U) & make_uint2 (16383U);
        int2  _S986 = make_int2 ((int)_S985.x, (int)_S985.y);
        int2  _S987 = (fcptLoadTemporalNeighbor((_S986)));
        uint _S988 = _S983 >> 28U;
        Shift _S989 = temporalShiftAt_0(_S986, _S987, _S988);
        fcptStoreTemporalShift((_S986), (_S988), (make_uint4 (asuint_1(_S989.f).x, asuint_1(_S989.f).y, asuint_1(_S989.f).z, (F32_asuint((_S989.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S990 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S991 = make_int2 ((int)_S990.x, (int)_S990.y);
    FixedArray<uint, 3>  _S992;
    temporalBins_0(_S991, &_S992);
    FixedArray<uint, 3>  _S993 = _S992;
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
        bool _S994 = (_S993[t_18]) == 40U;
        if(_S994)
        {
            fcptStoreTemporalShift((_S991), (t_18), (make_uint4 (0U)));
        }
        uint t_19 = t_18 + 1U;
        t_18 = t_19;
    }
    FixedArray<uint, 3>  _S995 = _S993;
    queueShifts_0(_S991, &_S995, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S996 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S997 = make_int2 ((int)_S996.x, (int)_S996.y);
    bool _S998 = (fcptSceneUnchanged());
    bool _S999 = !_S998;
    bool _S1000;
    if(_S999)
    {
        uint2  _S1001 = (fcptRenderSize());
        int2  _S1002 = make_int2 ((int)_S1001.x, (int)_S1001.y);
        _S1000 = all_0(_S997 < _S1002);
    }
    else
    {
        _S1000 = false;
    }
    if(_S1000)
    {
        Reservoir _S1003 = (fcptLoadReservoirInitial((_S997)));
        int2  _S1004 = sampleNeighbor_0(_S997, _S1003.seed);
        fcptStoreTemporalNeighbor((_S997), (_S1004));
    }
    FixedArray<uint, 3>  _S1005;
    temporalBins_0(_S997, &_S1005);
    FixedArray<uint, 3>  _S1006 = _S1005;
    countShifts_0(&_S1006, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_9, float b_5, float t_20)
{
    return a_9 + (b_5 - a_9) * t_20;
}

__device__ float confidenceCap(float duplicated_0)
{
    float _S1007 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S1007;
}

__device__ float2  temporalWeights(float c_2, float p_c_1, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S1008 = c_2 * p_c_1;
    float _S1009 = c_t_0 * p_t_0;
    return make_float2 (_S1008 / (_S1008 + c_t_0 * g_previous_0), _S1009 / (_S1009 + c_2 * g_current_0));
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S1010 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S1011 = make_int2 ((int)_S1010.x, (int)_S1010.y);
    float3  _S1012 = make_float3 (0.0f);
    FKHit _S1013 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S1014 = Domain_x24init_0(_S1012, _S1012, &_S1013, 0.0f, 0.0f);
    Domain dom_5 = _S1014;
    bool _S1015 = (fcptCurrentDomain((_S1011), (&dom_5)));
    bool _S1016 = !_S1015;
    if(_S1016)
    {
        Reservoir _S1017 = (Reservoir{});
        fcptStoreReservoirTemporal((_S1011), (_S1017), ((&dom_5)->hit));
        return;
    }
    Reservoir _S1018 = (fcptLoadReservoirInitial((_S1011)));
    bool _S1019 = (fcptTemporalQueued());
    bool _S1020 = (fcptSceneUnchanged());
    bool _S1021;
    if(_S1020)
    {
        _S1021 = true;
    }
    else
    {
        _S1021 = !_S1019;
    }
    int2  _S1022;
    if(_S1021)
    {
        int2  _S1023 = sampleNeighbor_0(_S1011, _S1018.seed);
        _S1022 = _S1023;
    }
    else
    {
        int2  _S1024 = (fcptLoadTemporalNeighbor((_S1011)));
        _S1022 = _S1024;
    }
    bool _S1025 = (_S1022.x) >= int(0);
    Reservoir r_5;
    if(_S1025)
    {
        Reservoir _S1026 = (fcptLoadReservoirPrevious((_S1022)));
        uint4  _S1027 = (fcptDuplication((_S1022)));
        float _S1028 = (U32_asfloat((_S1027.x)));
        uint _S1029 = (fcptRestirDecorrelation());
        bool _S1030 = _S1029 == 1U;
        float _S1031 = _slang_select(_S1030, _S1028,0.0f);
        float _S1032 = confidenceCap(_S1031);
        float _S1033 = (F32_min((_S1026.c), (_S1032)));
        bool _S1034 = (fcptSceneUnchanged());
        float4  _S1035 = make_float4 (_S1026.f.x, _S1026.f.y, _S1026.f.z, 1.0f);
        bool _S1036 = !_S1034;
        if(_S1036)
        {
            _S1021 = _S1019;
        }
        else
        {
            _S1021 = false;
        }
        float4  to_current_0;
        if(_S1021)
        {
            uint4  _S1037 = (fcptTemporalShift((_S1011), (0U)));
            float4  _S1038 = asfloat_0(_S1037);
            to_current_0 = _S1038;
        }
        else
        {
            if(_S1036)
            {
                Shift _S1039 = temporalShiftAt_0(_S1011, _S1022, 0U);
                float4  _S1040 = make_float4 (_S1039.f.x, _S1039.f.y, _S1039.f.z, _S1039.jac);
                to_current_0 = _S1040;
            }
            else
            {
                to_current_0 = _S1035;
            }
        }
        Domain own_1 = _S1014;
        if(_S1034)
        {
            _S1021 = true;
        }
        else
        {
            bool _S1041 = (fcptPreviousScenes());
            bool _S1042 = !_S1041;
            if(_S1042)
            {
                _S1021 = (_S1018.w) > 0.0f;
            }
            else
            {
                _S1021 = false;
            }
            if(_S1021)
            {
                bool _S1043 = (fcptStoredDomainInitial((_S1011), (_S1018.seed), (&own_1)));
                _S1021 = _S1043;
            }
            else
            {
                _S1021 = false;
            }
            if(_S1021)
            {
                Domain _S1044 = (fcptPreviousDomain((_S1022), (_S1018.seed)));
                Domain _S1045 = _S1044;
                Domain _S1046 = own_1;
                bool _S1047 = sameDomain_0(&_S1045, &_S1046);
                _S1021 = _S1047;
            }
            else
            {
                _S1021 = false;
            }
        }
        float4  _S1048 = make_float4 (_S1018.f.x, _S1018.f.y, _S1018.f.z, 1.0f);
        bool _S1049 = !_S1021;
        if(_S1049)
        {
            _S1021 = _S1019;
        }
        else
        {
            _S1021 = false;
        }
        float4  to_previous_0;
        if(_S1021)
        {
            uint4  _S1050 = (fcptTemporalShift((_S1011), (1U)));
            float4  _S1051 = asfloat_0(_S1050);
            to_previous_0 = _S1051;
        }
        else
        {
            if(_S1049)
            {
                Shift _S1052 = temporalShiftAt_0(_S1011, _S1022, 1U);
                float4  _S1053 = make_float4 (_S1052.f.x, _S1052.f.y, _S1052.f.z, _S1052.jac);
                to_previous_0 = _S1053;
            }
            else
            {
                to_previous_0 = _S1048;
            }
        }
        float _S1054 = resamplingTarget(_S1018.f);
        float _S1055 = resamplingTarget(_S1026.f);
        Selection _S1056 = (Selection{});
        Selection sel_6 = _S1056;
        uint _S1057 = (fcptFrame());
        uint _S1058 = hash(_S1057);
        uint _S1059 = global_invocation_id_7.x;
        uint2  _S1060 = (fcptRenderSize());
        uint _S1061 = stream(_S1058, _S1059 + _S1060.x * global_invocation_id_7.y);
        uint _S1062 = stream(_S1061, 194U);
        (&sel_6)->random_state = _S1062;
        float4  _S1063 = to_previous_0;
        float _S1064 = resamplingTarget(float3 {_S1063.x, _S1063.y, _S1063.z});
        float4  _S1065 = to_current_0;
        float3  _S1066 = float3 {_S1065.x, _S1065.y, _S1065.z};
        float _S1067 = resamplingTarget(_S1066);
        float2  _S1068 = temporalWeights(_S1018.c, _S1054, _S1033, _S1055, _S1064, _S1067);
        offerShifted(&sel_6, _S1018, Shift_x24init_0(_S1018.f, 1.0f), _S1068.x);
        offerShifted(&sel_6, _S1026, Shift_x24init_0(_S1066, to_current_0.w), _S1068.y);
        Reservoir _S1069 = finalize(sel_6, _S1018.c + _S1033);
        r_5 = _S1069;
    }
    else
    {
        r_5 = _S1018;
    }
    fcptStoreReservoirTemporal((_S1011), (r_5), ((&dom_5)->hit));
    return;
}

__device__ uint noiseOrigin(uint2  p_14, uint k_1)
{
    uint _S1070 = ((p_14.x) >> 11U) | (((p_14.y) >> 11U) << 4U);
    uint2  _S1071 = noiseOffset(8192U + (k_1 >> 10U) + (_S1070 << 20U));
    uint2  _S1072 = (p_14 + _S1071) & make_uint2 (2047U);
    return ((_S1072.x) | ((_S1072.y) << 11U)) | ((k_1 & 1023U) << 22U);
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_6)
{
    uint _S1073 = (1U << count_6) - 1U;
    return (e_2 & (~(_S1073 << offset_1))) | ((newbits_0 & _S1073) << offset_1);
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S1074 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S1075 = make_int2 ((int)_S1074.x, (int)_S1074.y);
    float3  _S1076 = make_float3 (0.0f);
    float2  _S1077 = make_float2 (0.0f);
    FKHit _S1078 = Hit_x24init_0(_S1077, 0U, 0U, 0U, 0.0f);
    Domain _S1079 = Domain_x24init_0(_S1076, _S1076, &_S1078, 0.0f, 0.0f);
    Domain dom_6 = _S1079;
    bool _S1080 = (fcptCurrentDomain((_S1075), (&dom_6)));
    bool _S1081 = !_S1080;
    if(_S1081)
    {
        Reservoir _S1082 = (Reservoir{});
        fcptStoreReservoirInitial((_S1075), (_S1082), ((&dom_6)->hit));
        return;
    }
    uint _S1083 = (fcptFrame());
    uint _S1084 = hash(_S1083);
    uint _S1085 = global_invocation_id_8.x;
    uint2  _S1086 = (fcptRenderSize());
    uint _S1087 = global_invocation_id_8.y;
    uint _S1088 = stream(_S1084, _S1085 + _S1086.x * _S1087);
    uint2  _S1089 = (fcptRenderSize());
    uint _S1090 = stream(_S1085 + _S1089.x * _S1087, 512U);
    Selection _S1091 = (Selection{});
    Selection initial_0 = _S1091;
    uint _S1092 = stream(_S1088, 193U);
    (&initial_0)->random_state = _S1092;
    bool _S1093 = (fcptRestirUsed());
    bool _S1094 = !_S1093;
    (&initial_0)->sums = _S1094;
    uint _S1095 = stream(_S1088, 0U);
    (&(&initial_0)->r)->seed = _S1095;
    FKHit _S1096 = Hit_x24init_0(_S1077, 4294967295U, 0U, 0U, 0.0f);
    uint _S1097 = (fcptSamples());
    float _S1098 = 1.0f / float(_S1097);
    FKHit hit_2 = _S1096;
    uint i_21 = 0U;
    float3  seen_1 = _S1076;
    for(;;)
    {
        uint _S1099 = (fcptSamples());
        if(i_21 < _S1099)
        {
        }
        else
        {
            break;
        }
        Reservoir _S1100 = (Reservoir{});
        Reservoir r_6 = _S1100;
        uint _S1101 = (fcptFrame());
        uint _S1102 = (fcptSamples());
        uint _S1103 = _S1101 * _S1102 + i_21;
        uint _S1104 = noiseOrigin(_S1074, _S1103);
        (&r_6)->seed = _S1104;
        uint _S1105 = insertBits_0(0U, 1U, 24U, 1U);
        uint _S1106 = insertBits_0(_S1105, (_S1090 + _S1103 * 2654435769U) >> 25U, 25U, 7U);
        (&r_6)->path = _S1106;
        Domain path_0 = _S1079;
        bool _S1107 = (fcptStoredDomainInitial((_S1075), ((&r_6)->seed), (&path_0)));
        bool _S1108 = !_S1107;
        if(_S1108)
        {
            float3  _S1109 = (fcptMissed((_S1075), (path_0), (_S1098)));
            float3  seen_2 = seen_1 + _S1109;
            seen_1 = seen_2;
            uint i_22 = i_21 + 1U;
            i_21 = i_22;
            continue;
        }
        Domain _S1110 = path_0;
        Reservoir _S1111 = r_6;
        Shift _S1112 = passWalk_0(&_S1110, &_S1111, false, _S1098, &initial_0);
        bool _S1113 = ((&(&initial_0)->r)->seed) == ((&r_6)->seed);
        FKHit hit_3;
        if(_S1113)
        {
            FKHit _S1114 = (&path_0)->hit;
            hit_3 = _S1114;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_22 = i_21 + 1U;
        i_21 = i_22;
    }
    uint _S1115 = (fcptSamples());
    float3  seen_3 = seen_1 + (&initial_0)->glow / make_float3 (float(_S1115));
    if((&initial_0)->sums)
    {
        seen_1 = seen_3 + (&initial_0)->color;
    }
    else
    {
        seen_1 = seen_3;
    }
    fcptAddColor((_S1075), (make_float4 (seen_1.x, seen_1.y, seen_1.z, 1.0f)));
    Reservoir _S1116 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S1075), (_S1116), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_4, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S1117;
    (&_S1117)->none = none_0;
    (&_S1117)->pdf = pdf_4;
    (&_S1117)->origin = origin_5;
    (&_S1117)->smooth_n = smooth_n_3;
    (&_S1117)->start = start_6;
    return _S1117;
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
    Vertex _S1118;
    (&_S1118)->rough = rough_0;
    (&_S1118)->lobe = lobe_1;
    (&_S1118)->pdf = pdf_5;
    (&_S1118)->cos = cos_0;
    (&_S1118)->inside = inside_0;
    return _S1118;
}

__device__ uint noiseAddress(uint origin_6, uint bounce_0)
{
    uint2  _S1119 = make_uint2 (origin_6 & 2047U, (origin_6 >> 11U) & 2047U);
    uint2  _S1120 = noiseOffset(64U + bounce_0 * 17U);
    uint2  _S1121 = (_S1119 + _S1120) & make_uint2 (2047U);
    return ((_S1121.x) | ((_S1121.y) << 11U)) | ((origin_6 >> 22U) << 22U);
}

static __device__ float freeFlight_0(float u_1, float sigma_0)
{
    return - (F32_log((1.0f - u_1))) / sigma_0;
}

__device__ float upsample(float3  rgb_1, float wavelength_0)
{
    float _S1122 = dot_0(make_float3 (-0.08011700212955475f, 1.08901798725128174f, -0.00889899954199791f), rgb_1);
    float _S1123 = dot_0(make_float3 (0.12177000194787979f, -1.22903203964233398f, 1.10724997520446777f), rgb_1);
    float _S1124 = dot_0(make_float3 (1.17252397537231445f, -1.21603405475616455f, 0.04350199922919273f), rgb_1);
    float3  _S1125 = make_float3 (_S1122, _S1123, _S1124);
    float _S1126 = (wavelength_0 - 0.44999998807907104f) / 0.02999999932944775f;
    float _S1127 = (wavelength_0 - 0.63999998569488525f) / 0.03999999910593033f;
    return _S1122 + _S1123 * (F32_exp((-0.5f * _S1126 * _S1126))) + _S1124 * (F32_exp((-0.5f * _S1127 * _S1127)));
}

__device__ float3  pathColor(float3  f_6, float3  weight_1, float wavelength_1)
{
    float3  _S1128;
    if(wavelength_1 > 0.0f)
    {
        float _S1129 = upsample(f_6, wavelength_1);
        _S1128 = weight_1 * make_float3 (_S1129);
    }
    else
    {
        _S1128 = f_6;
    }
    return _S1128;
}

static __device__ float3  exp_0(float3  x_22)
{
    float3  result_11;
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
        *_slang_vector_get_element_ptr(&result_11, i_23) = (F32_exp((_slang_vector_get_element(x_22, i_23))));
        i_23 = i_23 + int(1);
    }
    return result_11;
}

static __device__ float3  flightWeight_0(float3  scatter_0, float3  extinction_0, float sigma_1, float distance_2, bool scatters_0)
{
    float3  _S1130 = exp_0((make_float3 (sigma_1) - extinction_0) * make_float3 (distance_2));
    float3  _S1131 = scatter_0 * _S1130 / make_float3 (sigma_1);
    float3  _S1132 = _slang_select(scatters_0, _S1131,_S1130);
    return _S1132;
}

static __device__ bool scatterSampled_0(bool replay_1, uint b_6, uint stop_0, bool varying_0)
{
    bool _S1133 = !replay_1;
    bool _S1134;
    if(_S1133)
    {
        _S1134 = true;
    }
    else
    {
        bool _S1135 = b_6 == stop_0;
        if(_S1135)
        {
            _S1134 = !varying_0;
        }
        else
        {
            _S1134 = false;
        }
    }
    return _S1134;
}

static __device__ uint arrivalLobe_0(uint b_7, uint prev_lobe_0)
{
    bool _S1136 = b_7 > 0U;
    uint _S1137 = _slang_select(_S1136, prev_lobe_0,3U);
    return _S1137;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_2, uint lobe_2, bool surface_6, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S1138;
    (&_S1138)->extinction_behind = extinction_behind_0;
    (&_S1138)->extinction_front = extinction_front_0;
    (&_S1138)->fillings = fillings_0;
    (&_S1138)->side = side_0;
    (&_S1138)->depth = depth_2;
    (&_S1138)->lobe = lobe_2;
    (&_S1138)->surface = surface_6;
    (&_S1138)->length = length_2;
    (&_S1138)->width = width_1;
    (&_S1138)->own = *own_2;
    (&_S1138)->fiber = fiber_0;
    return _S1138;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S1139 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S1139)
    {
        return 0.07957746833562851f;
    }
    float _S1140 = g_0 * g_0;
    return (1.0f - _S1140) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S1140 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_10, float3  b_8)
{
    float3  _S1141 = a_10 / b_8;
    float3  _S1142 = make_float3 (0.0f);
    bool3  _S1143 = b_8 == _S1142;
    float3  _S1144 = _slang_select(_S1143, _S1142,_S1141);
    return _S1144;
}

__device__ Reservoir withEnd(Reservoir r_7, uint end_type_0, uint end_0, float3  f_7)
{
    Reservoir candidate_2 = r_7;
    uint _S1145 = insertBits_0(r_7.path, end_0, 0U, 5U);
    uint _S1146 = insertBits_0(_S1145, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S1146;
    (&candidate_2)->f = f_7;
    return candidate_2;
}

__device__ float survivalProbability(float3  throughput_0, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_0.x), ((F32_max((throughput_0.y), (throughput_0.z)))))) / density_1), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_11)
{
    Random _S1147 = draw(random_state_11, 11U);
    Random _S1148 = draw(random_state_11, 2147483659U);
    float _S1149 = 1.0f - 2.0f * _S1147.value;
    float _S1150 = (F32_sqrt(((F32_max((1.0f - _S1149 * _S1149), (0.0f))))));
    float _S1151 = 6.28318548202514648f * _S1148.value;
    return make_float3 (_S1150 * (F32_cos((_S1151))), _S1150 * (F32_sin((_S1151))), _S1149);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_10, uint random_state_12, float * pdf_6)
{
    bool _S1152 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1152)
    {
        *pdf_6 = 0.07957746833562851f;
        float3  _S1153 = isotropic_0(random_state_12);
        return _S1153;
    }
    Random _S1154 = draw(random_state_12, 11U);
    Random _S1155 = draw(random_state_12, 2147483659U);
    float _S1156 = g_1 * g_1;
    float _S1157 = 2.0f * g_1;
    float _S1158 = (1.0f - _S1156) / (1.0f - g_1 + _S1157 * _S1154.value);
    float _S1159 = clamp_1((1.0f + _S1156 - _S1158 * _S1158) / _S1157, -1.0f, 1.0f);
    float _S1160 = (F32_sqrt(((F32_max((1.0f - _S1159 * _S1159), (0.0f))))));
    float _S1161 = 6.28318548202514648f * _S1155.value;
    float _S1162 = phaseHG_0(g_1, _S1159);
    *pdf_6 = _S1162;
    float3  _S1163 = tangentToWorld(make_float3 (_S1160 * (F32_cos((_S1161))), _S1159, _S1160 * (F32_sin((_S1161)))), dir_10);
    float3  _S1164 = ((((_S1163)) * make_float3(rnorm3df(((_S1163)).x, ((_S1163)).y, ((_S1163)).z))));
    return _S1164;
}

static __device__ Vertex scatteredVertex_0(bool is_inside_6)
{
    return Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_6);
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_0, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_1, float velvet_0, float3  toon_1, float dispersion_0, float coat_2, float coat_roughness_0, float coat_ior_0, float3  coat_tint_0, float3  coat_normal_0)
{
    BSDFMaterial _S1165;
    (&_S1165)->albedo = albedo_0;
    (&_S1165)->emissive = emissive_0;
    (&_S1165)->roughness = roughness_0;
    (&_S1165)->metallic = metallic_0;
    (&_S1165)->transmission = transmission_0;
    (&_S1165)->ior = ior_0;
    (&_S1165)->absorption = absorption_0;
    (&_S1165)->specular_tint = specular_tint_0;
    (&_S1165)->specular_level = specular_level_0;
    (&_S1165)->translucent = translucent_0;
    (&_S1165)->sheen = sheen_2;
    (&_S1165)->sheen_roughness = sheen_roughness_0;
    (&_S1165)->anisotropy = anisotropy_0;
    (&_S1165)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1165)->tangent = tangent_1;
    (&_S1165)->velvet = velvet_0;
    (&_S1165)->toon = toon_1;
    (&_S1165)->dispersion = dispersion_0;
    (&_S1165)->coat = coat_2;
    (&_S1165)->coat_roughness = coat_roughness_0;
    (&_S1165)->coat_ior = coat_ior_0;
    (&_S1165)->coat_tint = coat_tint_0;
    (&_S1165)->coat_normal = coat_normal_0;
    return _S1165;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1166;
    (&_S1166)->scatter = scatter_1;
    (&_S1166)->extinction = extinction_1;
    (&_S1166)->g = g_2;
    return _S1166;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_11, bool skip_0, uint random_state_13, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1167;
    (&_S1167)->smooth_n = smooth_n_4;
    (&_S1167)->geometry_n = geometry_n_2;
    (&_S1167)->geometry_offset = geometry_offset_2;
    (&_S1167)->material = *material_11;
    (&_S1167)->skip = skip_0;
    (&_S1167)->random_state = random_state_13;
    (&_S1167)->coverage = coverage_0;
    (&_S1167)->encloses = encloses_0;
    (&_S1167)->volume = *volume_0;
    (&_S1167)->fills = fills_0;
    (&_S1167)->hair = hair_0;
    return _S1167;
}

static __device__ FKSurface emitting_0(FKSurface * surface_7, bool top_0)
{
    FKSurface lower_0 = *surface_7;
    float3  _S1168 = (&surface_7->material)->emissive;
    float3  _S1169 = make_float3 (0.0f);
    bool _S1170 = !top_0;
    float3  _S1171 = _slang_select(_S1170, _S1169,_S1168);
    (&(&lower_0)->material)->emissive = _S1171;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_8, float u_2)
{
    float _S1172 = surface_8->coverage;
    bool _S1173 = u_2 < _S1172;
    if(_S1173)
    {
        return *surface_8;
    }
    float3  _S1174 = make_float3 (0.0f);
    float3  _S1175 = make_float3 (1.0f);
    BSDFMaterial _S1176 = Material_x24init_0(_S1174, _S1174, 0.0f, 0.0f, 0.0f, 0.0f, _S1174, _S1175, 1.0f, _S1174, _S1174, 0.5f, 0.0f, 0.0f, _S1174, 0.0f, _S1174, 0.0f, 0.0f, 0.02999999932944775f, 1.5f, _S1175, _S1174);
    BSDFMaterial material_12 = _S1176;
    (&material_12)->albedo = _S1175;
    (&material_12)->emissive = (&surface_8->material)->emissive;
    (&material_12)->transmission = 1.0f;
    (&material_12)->ior = 1.0f;
    (&material_12)->absorption = (&surface_8->material)->absorption;
    FKSurface through_1 = *surface_8;
    (&through_1)->material = material_12;
    return through_1;
}

__device__ float facingSign(float transmission_1, float3  face_0, float3  direction_0)
{
    bool _S1177 = transmission_1 > 0.0f;
    bool _S1178;
    if(_S1177)
    {
        _S1178 = true;
    }
    else
    {
        _S1178 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1179;
    if(_S1178)
    {
        _S1179 = 1.0f;
    }
    else
    {
        _S1179 = -1.0f;
    }
    return _S1179;
}

static __device__ bool arrivesBehind_0(float3  dir_11, float3  n_10)
{
    return (dot_0(dir_11, n_10)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_9, float3  dir_12)
{
    float3  _S1180 = surface_9->geometry_n;
    float _S1181 = facingSign((&surface_9->material)->transmission, surface_9->geometry_n, dir_12);
    FKSurface faced_0 = *surface_9;
    float3  _S1182 = surface_9->smooth_n * make_float3 (_S1181);
    (&faced_0)->smooth_n = _S1182;
    float3  _S1183 = _S1180 * make_float3 (_S1181);
    (&faced_0)->geometry_n = _S1183;
    return faced_0;
}

static __device__ float3  max_0(float3  x_23, float3  y_7)
{
    float3  result_12;
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
        *_slang_vector_get_element_ptr(&result_12, i_24) = (F32_max((_slang_vector_get_element(x_23, i_24)), (_slang_vector_get_element(y_7, i_24))));
        i_24 = i_24 + int(1);
    }
    return result_12;
}

static __device__ float3  log_0(float3  x_24)
{
    float3  result_13;
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
        *_slang_vector_get_element_ptr(&result_13, i_25) = (F32_log((_slang_vector_get_element(x_24, i_25))));
        i_25 = i_25 + int(1);
    }
    return result_13;
}

__device__ float3  beerLambert(float distance_3, float3  absorption_1)
{
    float3  _S1184 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1184));
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
    bool _S1185;
    if(open_0)
    {
        _S1185 = prev_rough_0;
    }
    else
    {
        _S1185 = false;
    }
    if(_S1185)
    {
        _S1185 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S1185 = false;
    }
    return _S1185;
}

__device__ bool dispersive(BSDFMaterial material_13)
{
    bool _S1186 = (material_13.dispersion) > 0.0f;
    bool _S1187;
    if(_S1186)
    {
        _S1187 = (material_13.ior) != 1.0f;
    }
    else
    {
        _S1187 = false;
    }
    return _S1187;
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
        uint _S1188 = (low_1 + high_1 + 1U) / 2U;
        bool _S1189 = (WAVELENGTH_CDF_0[_S1188]) <= u_3;
        if(_S1189)
        {
            low_1 = _S1188;
        }
        else
        {
            uint _S1190 = _S1188 - 1U;
            high_1 = _S1190;
        }
    }
    uint _S1191 = low_1;
    float _S1192 = WAVELENGTH_CDF_0[low_1 + 1U] - WAVELENGTH_CDF_0[low_1];
    return make_float2 (0.37999999523162842f + 0.00499999988824129f * (float(low_1) + (u_3 - WAVELENGTH_CDF_0[_S1191]) / _S1192), _S1192 / 0.00499999988824129f);
}

__device__ static const FixedArray<float, 243>  WAVELENGTH_WEIGHTS_0 = { {
    0.00547470012679696f, -0.00465690018609166f, 0.03257500007748604f, 0.00934640038758516f, -0.00796370021998882f, 0.05577300116419792f, 0.01846100017428398f, -0.01579399965703487f, 0.11072999984025955f, 0.0416410006582737f, -0.03577499836683273f, 0.2513900101184845f, 0.09349299967288971f, -0.08071800321340561f, 0.56742000579833984f, 0.1585099995136261f, -0.13764999806880951f, 0.97018998861312866f, 0.30943000316619873f, -0.27083000540733337f, 1.91740000247955322f, 0.55217999219894409f, -0.48754000663757324f, 3.46889996528625488f, 0.95016998052597046f, -0.84802001714706421f, 6.09439992904663086f, 1.42110002040863037f, -1.28929996490478516f, 9.45199966430664062f, 1.73409998416900635f, -1.6062999963760376f, 12.12800025939941406f, 2.08030009269714355f, -1.98810005187988281f, 15.68700027465820312f, 2.20600008964538574f, -2.20120000839233398f, 18.47699928283691406f, 2.03040003776550293f, -2.17700004577636719f, 19.92700004577636719f, 1.63429999351501465f, -2.00340008735656738f, 20.86899948120117188f, 0.99410998821258545f, -1.62629997730255127f, 20.57799911499023438f, 0.20011000335216522f, -1.11409997940063477f, 19.72100067138671875f, -0.67960000038146973f, -0.45403000712394714f, 17.77599906921386719f, -1.61679995059967041f, 0.37860000133514404f, 14.71500015258789062f, -2.53410005569458008f, 1.27540004253387451f, 11.86499977111816406f, -3.39079999923706055f, 2.2146000862121582f, 9.17669963836669922f, -4.03749990463256836f, 3.0522000789642334f, 6.59509992599487305f, -4.61299991607666016f, 3.89779996871948242f, 4.64589977264404297f, -5.43039989471435547f, 5.0121002197265625f, 3.3199000358581543f, -6.37769985198974609f, 6.33809995651245117f, 2.29699993133544922f, -7.44140005111694336f, 7.91739988327026367f, 1.45389997959136963f, -8.38580036163330078f, 9.60109996795654297f, 0.66465997695922852f, -9.0167999267578125f, 11.23999977111816406f, -0.04403600096702576f, -9.17749977111816406f, 12.63199996948242188f, -0.58126997947692871f, -8.97550010681152344f, 13.91499996185302734f, -0.95730000734329224f, -8.25290012359619141f, 14.86200046539306641f, -1.24430000782012939f, -6.92129993438720703f, 15.03899955749511719f, -1.43069994449615479f, -5.29169988632202148f, 14.90900039672851562f, -1.55149996280670166f, -3.43219995498657227f, 14.70499992370605469f, -1.63569998741149902f, -1.27190005779266357f, 14.24400043487548828f, -1.67030000686645508f, 1.15170001983642578f, 13.32199954986572266f, -1.636199951171875f, 3.73889994621276855f, 12.21199989318847656f, -1.56920003890991211f, 6.43590021133422852f, 10.94699954986572266f, -1.47730004787445068f, 9.16440010070800781f, 9.54769992828369141f, -1.36399996280670166f, 12.02000045776367188f, 8.18799972534179688f, -1.25450003147125244f, 14.78699970245361328f, 6.74429988861083984f, -1.13110005855560303f, 16.72299957275390625f, 5.08780002593994141f, -0.96561002731323242f, 18.14299964904785156f, 3.57019996643066406f, -0.80725997686386108f, 19.91900062561035156f, 2.36269998550415039f, -0.69273000955581665f, 21.05500030517578125f, 1.31369996070861816f, -0.58597999811172485f, 21.3899993896484375f, 0.42390000820159912f, -0.48298001289367676f, 20.99300003051757812f, -0.23857000470161438f, -0.39412000775337219f, 19.82200050354003906f, -0.6866300106048584f, -0.31501999497413635f, 18.12000083923339844f, -0.9412500262260437f, -0.24890999495983124f, 15.7089996337890625f, -1.02020001411437988f, -0.19076000154018402f, 13.19799995422363281f, -0.98919999599456787f, -0.14401000738143921f, 11.23999977111816406f, -0.93347001075744629f, -0.11133000254631042f, 9.36649990081787109f, -0.83820998668670654f, -0.08524099737405777f, 7.41249990463256836f, -0.70064002275466919f, -0.06283199787139893f, 5.71229982376098633f, -0.56079000234603882f, -0.04586699977517128f, 4.42280006408691406f, -0.44653001427650452f, -0.03396600112318993f, 3.34489989280700684f, -0.34457001090049744f, -0.02482499927282333f, 2.49309992790222168f, -0.26017999649047852f, -0.01808100007474422f, 1.82239997386932373f, -0.1921599954366684f, -0.01296999957412481f, 1.29499995708465576f, -0.13766999542713165f, -0.00907570030540228f, 0.92928999662399292f, -0.09956400096416473f, -0.00641620019450784f, 0.61835998296737671f, -0.06671299785375595f, -0.00421149982139468f, 0.40211999416351318f, -0.04354599863290787f, -0.00271830009296536f, 0.2844499945640564f, -0.03087200038135052f, -0.00191440002527088f, 0.20672999322414398f, -0.02246100082993507f, -0.00138829997740686f, 0.15044000744819641f, -0.01634499989449978f, -0.00101030000951141f, 0.10942000150680542f, -0.01188699994236231f, -0.0007347899954766f, 0.07099699974060059f, -0.00771349994465709f, -0.00047679000999779f, 0.04539500176906586f, -0.00493190018460155f, -0.00030484999297187f, 0.03424099832773209f, -0.00372010003775358f, -0.00022995000472292f, 0.02557599917054176f, -0.00277870008721948f, -0.00017175999528263f, 0.01842200011014938f, -0.00200140010565519f, -0.0001237099932041f, 0.01316899992525578f, -0.00143079995177686f, -0.00008843900286593f, 0.00838890019804239f, -0.00091141002485529f, -0.00005633700129692f, 0.00537079991772771f, -0.00058350997278467f, -0.00003606799873523f, 0.00328280008397996f, -0.00035665999166667f, -0.00002204600059486f, 0.00196009990759194f, -0.00021296000340953f, -0.00001316300040344f, 0.00168939994182438f, -0.00018354000349063f, -0.00001134499962063f, 0.00141050003003329f, -0.00015325000276789f, -0.00000947250009631f, 0.00097123999148607f, -0.00010551999730524f, -6.52239987175562419e-06f, 0.00066868000430986f, -0.00007264900341397f, -4.49060007667867467e-06f
} };
__device__ float3  wavelengthWeights(float wavelength_2)
{
    float _S1193 = clamp_1((wavelength_2 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    uint _S1194 = (U32_min((uint(_S1193)), (79U)));
    uint _S1195 = 3U * _S1194;
    float3  _S1196 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1195], WAVELENGTH_WEIGHTS_0[_S1195 + 1U], WAVELENGTH_WEIGHTS_0[_S1195 + 2U]);
    float3  _S1197 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1195 + 3U], WAVELENGTH_WEIGHTS_0[_S1195 + 4U], WAVELENGTH_WEIGHTS_0[_S1195 + 5U]);
    return _S1196 + (_S1197 - _S1196) * make_float3 (_S1193 - float(_S1194));
}

__device__ BSDFMaterial atWavelength(BSDFMaterial material_14, float wavelength_3)
{
    BSDFMaterial at_0 = material_14;
    float _S1198 = upsample(material_14.albedo, wavelength_3);
    float3  _S1199 = make_float3 (_S1198);
    (&at_0)->albedo = _S1199;
    float _S1200 = upsample(material_14.emissive, wavelength_3);
    float3  _S1201 = make_float3 (_S1200);
    (&at_0)->emissive = _S1201;
    float _S1202 = upsample(material_14.absorption, wavelength_3);
    float3  _S1203 = make_float3 (_S1202);
    (&at_0)->absorption = _S1203;
    float _S1204 = upsample(material_14.specular_tint, wavelength_3);
    float3  _S1205 = make_float3 (_S1204);
    (&at_0)->specular_tint = _S1205;
    float _S1206 = upsample(material_14.translucent, wavelength_3);
    float3  _S1207 = make_float3 (_S1206);
    (&at_0)->translucent = _S1207;
    float _S1208 = upsample(material_14.sheen, wavelength_3);
    float3  _S1209 = make_float3 (_S1208);
    (&at_0)->sheen = _S1209;
    float _S1210 = upsample(material_14.coat_tint, wavelength_3);
    float3  _S1211 = make_float3 (_S1210);
    (&at_0)->coat_tint = _S1211;
    return at_0;
}

__device__ float dispersedIor(float ior_1, float dispersion_1, float wavelength_4)
{
    float _S1212 = (ior_1 - 1.0f) * dispersion_1 / 1.90962409973144531f;
    float _S1213 = _S1212 * (1.0f / (wavelength_4 * wavelength_4) - 2.89662933349609375f);
    bool _S1214 = dispersion_1 > 0.0f;
    float _S1215 = _slang_select(_S1214, _S1213,0.0f);
    return ior_1 + _S1215;
}

__device__ float2  vertexEta(BSDFMaterial material_15, float n_dot_v_0)
{
    bool _S1216 = n_dot_v_0 < 0.0f;
    float _S1217 = _slang_select(_S1216, material_15.ior,1.0f);
    float _S1218 = _slang_select(_S1216, 1.0f,material_15.ior);
    return make_float2 (_S1217, _S1218);
}

__device__ float2  wavelengthEta(BSDFMaterial material_16, float n_dot_v_1, float wavelength_5)
{
    BSDFMaterial refractive_0 = material_16;
    float _S1219 = dispersedIor(material_16.ior, material_16.dispersion, wavelength_5);
    bool _S1220 = wavelength_5 > 0.0f;
    float _S1221 = _slang_select(_S1220, _S1219,material_16.ior);
    (&refractive_0)->ior = _S1221;
    float2  _S1222 = vertexEta(refractive_0, n_dot_v_1);
    return _S1222;
}

__device__ bool neeDecision(BSDFMaterial material_17, float n_dot_v_2, float eta_i_5, float eta_o_5)
{
    float _S1223 = fresnel((F32_abs((n_dot_v_2))), eta_i_5, eta_o_5);
    float3  _S1224 = mix_0(make_float3 (_S1223), material_17.albedo, material_17.metallic);
    float _S1225 = rgb_to_greyscale(_S1224);
    float _S1226 = (F32_max(((1.0f - _S1225) * (1.0f - material_17.metallic) * (1.0f - material_17.transmission)), (0.0f)));
    bool _S1227 = _S1226 > 0.03999999910593033f;
    bool _S1228;
    if(_S1227)
    {
        _S1228 = true;
    }
    else
    {
        _S1228 = (material_17.roughness) > 0.20000000298023224f;
    }
    return _S1228;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_18)
{
    float _S1229 = rgb_to_greyscale(material_18->translucent);
    return _S1229 > 0.0f;
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
    MediumSides _S1230;
    (&_S1230)->behind = *behind_0;
    (&_S1230)->front = *front_0;
    (&_S1230)->fillings = fillings_1;
    (&_S1230)->face = face_1;
    return _S1230;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_10, FKMedium * medium_0, uint filling_0, float3  dir_13, FKMedium * outside_0)
{
    float3  _S1231 = surface_10->geometry_n;
    MediumSides _S1232 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_10->geometry_n);
    MediumSides sides_0 = _S1232;
    bool _S1233 = surface_10->encloses;
    if(_S1233)
    {
        (&sides_0)->behind = surface_10->volume;
        *&((&(&sides_0)->fillings)->x) = surface_10->fills;
        bool _S1234 = (dot_0(dir_13, _S1231)) > 0.0f;
        if(_S1234)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_11, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_14, uint depth_3, uint lobe_3, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1235 = surface_11->geometry_n;
    ShadowContext _S1236 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_11->geometry_n, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
    bool _S1237 = surface_11->encloses;
    ShadowContext context_4;
    if(_S1237)
    {
        FKSurface faced_1 = *surface_11;
        float3  _S1238 = - _S1235;
        float3  _S1239 = _slang_select(turned_0, _S1238,_S1235);
        (&faced_1)->geometry_n = _S1239;
        FKMedium _S1240 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1241 = faced_1;
        FKMedium _S1242 = _S1240;
        MediumSides _S1243 = mediumSides_0(&_S1241, &_S1242, filling_1, dir_14, outside_1);
        ShadowContext _S1244 = ShadowContext_x24init_0(_S1243.behind.extinction, _S1243.front.extinction, _S1243.fillings, _S1235, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
        if(turned_0)
        {
            uint2  _S1245 = _S1243.fillings;
            ShadowContext _S1246 = ShadowContext_x24init_0(_S1243.front.extinction, _S1243.behind.extinction, uint2 {_S1245.y, _S1245.x}, _S1235, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
            context_4 = _S1246;
        }
        else
        {
            context_4 = _S1244;
        }
    }
    else
    {
        context_4 = _S1236;
    }
    return context_4;
}

static __device__ bool any_1(bool3  x_25)
{
    bool result_14 = false;
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
        if(result_14)
        {
            result_14 = true;
        }
        else
        {
            result_14 = (bool((_slang_vector_get_element(x_25, i_26))));
        }
        i_26 = i_26 + int(1);
    }
    return result_14;
}

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_8, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_4, BSDFMaterial * material_19, float eta_i_6, float eta_o_6, bool competing_1, uint random_state_14)
{
    float3  _S1247 = light_2->dir;
    bool _S1248 = (dot_0(geometry_n_4, - in_dir_8) * dot_0(geometry_n_4, light_2->dir)) <= 0.0f;
    FixedArray<float3 , 6>  throughputs_1;
    FixedArray<float, 6>  pdfs_4;
    float3  _S1249 = BSDF(in_dir_8, _S1247, smooth_n_5, *material_19, eta_i_6, eta_o_6, _S1248, random_state_14, &throughputs_1, &pdfs_4);
    bool _S1250 = !competing_1;
    bool _S1251;
    if(_S1250)
    {
        _S1251 = true;
    }
    else
    {
        _S1251 = (light_2->density) == 0.0f;
    }
    if(_S1251)
    {
        return _S1249 * light_2->radiance;
    }
    float3  _S1252 = make_float3 (0.0f);
    uint i_27 = 0U;
    float3  weighted_0 = _S1252;
    for(;;)
    {
        if(i_27 < 6U)
        {
        }
        else
        {
            break;
        }
        bool _S1253 = (pdfs_4[i_27]) > 0.0f;
        if(_S1253)
        {
            float _S1254 = light_2->density;
            float _S1255 = pdfs_4[i_27] / light_2->density;
            float3  weighted_1 = weighted_0 + throughputs_1[i_27] * make_float3 (pdfs_4[i_27]) / make_float3 (_S1254 * (1.0f + _S1255 * _S1255));
            weighted_0 = weighted_1;
        }
        uint i_28 = i_27 + 1U;
        i_27 = i_28;
    }
    return weighted_0 * light_2->radiance * make_float3 (light_2->density);
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_1, uint random_state_15, bool refracted_3, uint lobe_4, float pdf_7)
{
    SampleBSDF _S1256;
    (&_S1256)->unit_direction = unit_direction_1;
    (&_S1256)->throughput = throughput_1;
    (&_S1256)->random_state = random_state_15;
    (&_S1256)->refracted = refracted_3;
    (&_S1256)->lobe = lobe_4;
    (&_S1256)->pdf = pdf_7;
    return _S1256;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  v_9, float3  n_i_12, float n_i_dot_v_3, BSDFMaterial material_20, Weights w_16, uint random_state_16)
{
    float3  _S1257 = make_float3 (1.0f);
    SampleBSDF _S1258 = SampleBSDF_x24init_0(_S1257, _S1257, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S1258;
    Random _S1259 = draw(random_state_16, 3U);
    Random _S1260 = draw(random_state_16, 2147483651U);
    (&sample_1)->random_state = _S1260.state;
    float _S1261 = _S1259.value;
    float _S1262 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1261 * _S1261))))));
    float _S1263 = 6.28318548202514648f * _S1260.value;
    float3  _S1264 = tangentToWorld(make_float3 (_S1262 * (F32_cos((_S1263))), _S1259.value, _S1262 * (F32_sin((_S1263)))), n_i_12);
    (&sample_1)->unit_direction = _S1264;
    (&sample_1)->lobe = 4U;
    float3  _S1265 = sheenVelvetBSDF((&sample_1)->unit_direction, v_9, n_i_12, material_20, w_16);
    (&sample_1)->throughput = _S1265;
    float _S1266 = sheenVelvetPDF(_S1259.value, n_i_dot_v_3, w_16);
    (&sample_1)->pdf = _S1266;
    return sample_1;
}

__device__ __forceinline__ SampleBSDF coatSample(float3  in_dir_9, float3  coat_h_1, Weights w_17, uint random_state_17)
{
    float3  _S1267 = make_float3 (1.0f);
    SampleBSDF _S1268 = SampleBSDF_x24init_0(_S1267, _S1267, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S1268;
    float3  _S1269 = reflect_0(in_dir_9, coat_h_1);
    float3  _S1270 = ((((_S1269)) * make_float3(rnorm3df(((_S1269)).x, ((_S1269)).y, ((_S1269)).z))));
    (&sample_2)->unit_direction = _S1270;
    (&sample_2)->random_state = random_state_17;
    (&sample_2)->lobe = 5U;
    float3  _S1271 = coatBSDF(w_17);
    (&sample_2)->throughput = _S1271;
    float _S1272 = coatPDF(w_17);
    (&sample_2)->pdf = _S1272;
    return sample_2;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1273 = (F32_sqrt((random_1_0)));
    float _S1274 = 6.28318548202514648f * random_2_0;
    float _S1275 = _S1273 * (F32_cos((_S1274)));
    float _S1276 = _S1273 * (F32_sin((_S1274)));
    float _S1277 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1275 * _S1275 - _S1276 * _S1276))))));
    return make_float3 (_S1275, _S1277, _S1276);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_4, float3  n_i_13, float n_i_dot_v_4, BSDFMaterial material_21, Weights w_18, uint random_state_18)
{
    float3  _S1278 = make_float3 (1.0f);
    SampleBSDF _S1279 = SampleBSDF_x24init_0(_S1278, _S1278, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S1279;
    Random _S1280 = draw(random_state_18, 3U);
    Random _S1281 = draw(random_state_18, 2147483651U);
    (&sample_3)->random_state = _S1281.state;
    float3  _S1282 = sampleCosWeightedHemisphere(_S1280.value, _S1281.value);
    float _S1283 = translucentShare(material_21);
    bool _S1284 = u_4 < (w_18.p_diffuse * _S1283);
    float _S1285 = _S1282.y;
    float _S1286 = - _S1285;
    float _S1287 = _slang_select(_S1284, _S1286,_S1285);
    float3  _S1288 = tangentToWorld(make_float3 (_S1282.x, _S1287, _S1282.z), n_i_13);
    (&sample_3)->unit_direction = _S1288;
    (&sample_3)->refracted = _S1284;
    (&sample_3)->lobe = 0U;
    float3  _S1289 = diffuseBSDF((&sample_3)->unit_direction, n_i_13, material_21, w_18);
    (&sample_3)->throughput = _S1289;
    float _S1290 = diffusePDF(_S1287, n_i_dot_v_4, material_21, w_18);
    (&sample_3)->pdf = _S1290;
    return sample_3;
}

__device__ __forceinline__ SampleBSDF toonSample(float3  n_i_14, ToonShape shape_2, Weights w_19, uint random_state_19)
{
    float3  _S1291 = make_float3 (1.0f);
    SampleBSDF _S1292 = SampleBSDF_x24init_0(_S1291, _S1291, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S1292;
    Random _S1293 = draw(random_state_19, 3U);
    Random _S1294 = draw(random_state_19, 2147483651U);
    (&sample_4)->random_state = _S1294.state;
    float _S1295 = _S1293.value * shape_2.norm / 6.28318548202514648f;
    float t_21;
    if(shape_2.glossy)
    {
        t_21 = (F32_acos((clamp_1(1.0f - _S1295, -1.0f, 1.0f))));
    }
    else
    {
        t_21 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1295)))), (1.0f))))));
    }
    if(t_21 < (shape_2.a))
    {
    }
    else
    {
        t_21 = (shape_2.a + shape_2.b) / 2.0f;
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
        float _S1296;
        if(t_21 < (shape_2.a))
        {
            _S1296 = 1.0f;
        }
        else
        {
            _S1296 = (F32_max((1.0f - (t_21 - shape_2.a) / (F32_max((shape_2.s), (0.0000152587890625f)))), (0.0f)));
        }
        float integral_2;
        if(shape_2.glossy)
        {
            integral_2 = 1.0f - (F32_cos(((F32_min((t_21), (shape_2.a))))));
        }
        else
        {
            float _S1297 = (F32_sin(((F32_min((t_21), (shape_2.a))))));
            integral_2 = _S1297 * _S1297 / 2.0f;
        }
        bool _S1298 = t_21 > (shape_2.a);
        bool _S1299;
        if(_S1298)
        {
            _S1299 = (shape_2.s) > 0.0f;
        }
        else
        {
            _S1299 = false;
        }
        float integral_3;
        if(_S1299)
        {
            if(shape_2.glossy)
            {
                float _S1300 = (F32_cos((shape_2.a)));
                float _S1301 = (F32_cos((t_21)));
                integral_3 = (1.0f + shape_2.a / shape_2.s) * (_S1300 - _S1301) - ((F32_sin((t_21))) - t_21 * _S1301 - ((F32_sin((shape_2.a))) - shape_2.a * _S1300)) / shape_2.s;
            }
            else
            {
                float _S1302 = 2.0f * shape_2.a;
                float _S1303 = (F32_cos((_S1302)));
                float _S1304 = 2.0f * t_21;
                float _S1305 = (F32_cos((_S1304)));
                integral_3 = (1.0f + shape_2.a / shape_2.s) * (_S1303 - _S1305) / 4.0f - ((F32_sin((_S1304))) / 8.0f - t_21 * _S1305 / 4.0f - ((F32_sin((_S1302))) / 8.0f - shape_2.a * _S1303 / 4.0f)) / shape_2.s;
            }
            float integral_4 = integral_2 + integral_3;
            integral_3 = integral_4;
        }
        else
        {
            integral_3 = integral_2;
        }
        float _S1306 = _S1296 * (F32_sin((t_21)));
        float _S1307;
        if(shape_2.glossy)
        {
            _S1307 = 1.0f;
        }
        else
        {
            _S1307 = (F32_cos((t_21)));
        }
        float _S1308 = _S1306 * _S1307;
        float _S1309 = (integral_3 - _S1295) / _S1308;
        bool _S1310 = _S1308 > 0.0f;
        float _S1311 = _slang_select(_S1310, _S1309,0.0f);
        float _S1312 = clamp_1(t_21 - _S1311, 0.0f, shape_2.b);
        int k_3 = k_2 + int(1);
        t_21 = _S1312;
        k_2 = k_3;
    }
    float _S1313 = 6.28318548202514648f * _S1294.value;
    float _S1314 = (F32_sin((t_21)));
    float3  _S1315 = tangentToWorld(make_float3 (_S1314 * (F32_cos((_S1313))), (F32_cos((t_21))), _S1314 * (F32_sin((_S1313)))), shape_2.axis);
    (&sample_4)->unit_direction = _S1315;
    bool _S1316 = (dot_0(n_i_14, (&sample_4)->unit_direction)) < 0.0f;
    (&sample_4)->refracted = _S1316;
    (&sample_4)->lobe = 6U;
    float3  _S1317 = toonBSDF((&sample_4)->unit_direction, n_i_14, shape_2, w_19);
    (&sample_4)->throughput = _S1317;
    float _S1318 = toonPDF(dot_0(n_i_14, (&sample_4)->unit_direction), dot_0((&sample_4)->unit_direction, shape_2.axis), shape_2, w_19);
    (&sample_4)->pdf = _S1318;
    return sample_4;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_15, float alpha_8, AnisotropicFrame frame_6, BSDFMaterial material_22, Weights w_20, float pdf_h_3, float eta_i_7, float eta_o_7, uint random_state_20)
{
    float3  _S1319 = make_float3 (1.0f);
    SampleBSDF _S1320 = SampleBSDF_x24init_0(_S1319, _S1319, 0U, false, 0U, 0.0f);
    SampleBSDF sample_5 = _S1320;
    (&sample_5)->unit_direction = w_20.refracted;
    (&sample_5)->random_state = random_state_20;
    (&sample_5)->refracted = true;
    (&sample_5)->lobe = 1U;
    float3  _S1321 = refractBSDF((&sample_5)->unit_direction, n_i_15, alpha_8, frame_6, material_22, w_20);
    (&sample_5)->throughput = _S1321;
    float _S1322 = refractPDF(dot_0((&sample_5)->unit_direction, ggx_n_3), pdf_h_3, w_20, eta_i_7, eta_o_7);
    (&sample_5)->pdf = _S1322;
    return sample_5;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_10, float3  ggx_n_4, float3  n_i_16, float alpha_9, AnisotropicFrame frame_7, Weights w_21, float pdf_h_4, uint random_state_21)
{
    float3  _S1323 = make_float3 (1.0f);
    SampleBSDF _S1324 = SampleBSDF_x24init_0(_S1323, _S1323, 0U, false, 0U, 0.0f);
    SampleBSDF sample_6 = _S1324;
    float3  _S1325 = reflect_0(in_dir_10, ggx_n_4);
    float3  _S1326 = ((((_S1325)) * make_float3(rnorm3df(((_S1325)).x, ((_S1325)).y, ((_S1325)).z))));
    (&sample_6)->unit_direction = _S1326;
    (&sample_6)->random_state = random_state_21;
    (&sample_6)->lobe = 2U;
    float3  _S1327 = reflectBSDF((&sample_6)->unit_direction, n_i_16, alpha_9, frame_7, w_21);
    (&sample_6)->throughput = _S1327;
    float _S1328 = reflectPDF(pdf_h_4, w_21);
    (&sample_6)->pdf = _S1328;
    return sample_6;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_11, float3  n_11, BSDFMaterial material_23, float eta_i_8, float eta_o_8, uint random_init_0, float2  screen_space_0)
{
    uint random_state_22 = random_init_0;
    float3  _S1329 = negate_0(in_dir_11);
    float _S1330 = dot_0(n_11, _S1329);
    float _S1331 = sign_0(_S1330);
    float3  n_i_17 = n_11 * make_float3 (_S1331);
    float _S1332 = (F32_abs((_S1330)));
    float _S1333 = material_23.roughness;
    float _S1334 = _S1333 * _S1333;
    AnisotropicFrame _S1335 = anisotropicFrame(material_23, n_i_17);
    float3  _S1336 = sampleHalfVector(_S1329, n_i_17, _S1334, _S1335, &random_state_22, 0U);
    float3  _S1337 = coatHalf(_S1329, n_i_17, material_23, random_init_0);
    Weights _S1338 = lobeWeights(in_dir_11, _S1329, n_i_17, _S1336, _S1337, _S1335, material_23, eta_i_8, eta_o_8);
    Random _S1339 = draw(random_state_22, 2U);
    random_state_22 = _S1339.state;
    bool _S1340 = (_S1339.value) < (_S1338.p_sheen_velvet);
    if(_S1340)
    {
        SampleBSDF _S1341 = sheenVelvetSample(_S1329, n_i_17, _S1332, material_23, _S1338, random_state_22);
        return _S1341;
    }
    float _S1342 = _S1339.value - _S1338.p_sheen_velvet;
    bool _S1343 = _S1342 < (_S1338.p_coat);
    if(_S1343)
    {
        SampleBSDF _S1344 = coatSample(in_dir_11, _S1337, _S1338, random_state_22);
        return _S1344;
    }
    float _S1345 = _S1342 - _S1338.p_coat;
    bool _S1346 = _S1345 < (_S1338.p_diffuse);
    if(_S1346)
    {
        SampleBSDF _S1347 = diffuseSample(_S1345, n_i_17, _S1332, material_23, _S1338, random_state_22);
        return _S1347;
    }
    bool _S1348 = _S1345 < (_S1338.p_diffuse + _S1338.p_toon);
    if(_S1348)
    {
        ToonShape _S1349 = toonShape(_S1329, n_i_17, material_23);
        SampleBSDF _S1350 = toonSample(n_i_17, _S1349, _S1338, random_state_22);
        return _S1350;
    }
    float _S1351 = vndfPDF(_S1329, _S1336, n_i_17, _S1332, _S1334, _S1335, _S1338.v_dot_h);
    bool _S1352 = (_S1345 - _S1338.p_toon) < (_S1338.p_diffuse + _S1338.p_refract);
    if(_S1352)
    {
        SampleBSDF _S1353 = refractSample(_S1336, n_i_17, _S1334, _S1335, material_23, _S1338, _S1351, eta_i_8, eta_o_8, random_state_22);
        return _S1353;
    }
    SampleBSDF _S1354 = reflectSample(in_dir_11, _S1336, n_i_17, _S1334, _S1335, _S1338, _S1351, random_state_22);
    return _S1354;
}

__device__ bool withinInverseFootprint(float pdf_8, bool diffuse_0, float prev_cos_0, float distance_5, float threshold_1)
{
    bool _S1355 = pdf_8 > 0.0f;
    bool _S1356;
    if(_S1355)
    {
        if(diffuse_0)
        {
            _S1356 = true;
        }
        else
        {
            _S1356 = (pdf_8 * prev_cos_0 / (distance_5 * distance_5) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S1356 = false;
    }
    return _S1356;
}

__device__ bool roughLobe(float pdf_9, bool diffuse_1, float roughness_1)
{
    bool _S1357 = pdf_9 > 0.0f;
    bool _S1358;
    if(_S1357)
    {
        if(diffuse_1)
        {
            _S1358 = true;
        }
        else
        {
            _S1358 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S1358 = false;
    }
    return _S1358;
}

static __device__ bool passesLayer_0(uint layers_0, bool refracting_0, bool passed_0)
{
    bool _S1359 = layers_0 > 1U;
    bool _S1360;
    if(_S1359)
    {
        _S1360 = refracting_0 != passed_0;
    }
    else
    {
        _S1360 = false;
    }
    return _S1360;
}

static __device__ float widened_0(float spread_1, float pdf_10, bool delta_0)
{
    float _S1361 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * pdf_10))))), (3.14159274101257324f)));
    bool _S1362 = !delta_0;
    float _S1363 = _slang_select(_S1362, _S1361,0.0f);
    return spread_1 + _S1363;
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
    bool _S1364;
    float density_2;
    float wavelength_6;
    float width_3;
    float sky_pdf_0;
    float threshold_2;
    uint b_9;
    uint layer_0;
    float3  throughput_2;
    float3  spectral_weight_0;
    TreeSample light_3;
    int _S1365;
    Shift ended_0;
    float density_3;
    float spread_3;
    float width_4;
    float sky_pdf_1;
    float spread_4;
    float width_5;
    uint b_10;
    float3  _S1366 = make_float3 (0.0f);
    Shift _S1367 = Shift_x24init_0(_S1366, 0.0f);
    uint _S1368 = r_8->path;
    uint _S1369 = extractBits_0(r_8->path, 0U, 5U);
    uint _S1370 = extractBits_0(_S1368, 5U, 5U);
    uint _S1371 = extractBits_0(_S1368, 10U, 2U);
    uint _S1372 = extractBits_0(_S1368, 12U, 3U);
    bool passes_0;
    if(replay_2)
    {
        bool _S1373 = _S1372 >= 3U;
        uint _S1374 = _slang_select(_S1373, 1U,0U);
        uint _S1375 = _S1369 + _S1374;
        uint _S1376 = (fcptMaxBounces());
        passes_0 = _S1375 > _S1376;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1367;
    }
    uint _S1377 = _S1370 - 1U;
    bool _S1378 = _S1372 == 3U;
    uint _S1379 = _slang_select(_S1378, 1U,0U);
    uint _S1380 = _S1369 + _S1379;
    bool _S1381 = _S1371 == 0U;
    uint _S1382 = _slang_select(_S1381, _S1380,_S1377);
    FKHit _S1383 = (fcptReservoirHit((*r_8)));
    float3  _S1384 = dom_7->x0;
    float3  _S1385 = dom_7->x1 - dom_7->x0;
    float3  _S1386 = ((((_S1385)) * make_float3(rnorm3df(((_S1385)).x, ((_S1385)).y, ((_S1385)).z))));
    FKRay _S1387 = Ray_x24init_0(dom_7->x1, _S1386);
    FKRay ray_2 = _S1387;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1366;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_2 = throughput_3;
    float3  glowed_0 = _S1366;
    float3  extinction_in_0 = _S1366;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1388 = dom_7->spread;
    float _S1389 = dom_7->width;
    float _S1390 = length_0(_S1385);
    NEEVertex _S1391 = NEEVertex_x24init_0(true, 0.0f, _S1366, _S1366, _S1366);
    NEEVertex nee_vertex_0 = _S1391;
    Vertex _S1392 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S1392;
    Reservoir _S1393 = (Reservoir{});
    Reservoir chain_0 = _S1393;
    uint _S1394 = r_8->seed;
    (&chain_0)->seed = r_8->seed;
    uint _S1395 = extractBits_0(_S1368, 24U, 8U);
    uint _S1396 = insertBits_0(0U, _S1395, 24U, 8U);
    (&chain_0)->path = _S1396;
    (&ray_2)->origin = _S1384;
    (&hit_4)->distance = _S1390;
    FKMedium _S1397 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1398 = filling_2;
    bool _S1399 = (fcptVaryingUsed());
    uint _S1400 = _slang_select(_S1399, _S1398,4294967295U);
    filling_2 = _S1400;
    scatter_in_0 = _S1397.scatter;
    extinction_in_0 = _S1397.extinction;
    g_in_0 = _S1397.g;
    Reservoir _S1401 = chain_0;
    uint _S1402 = filling_2;
    for(;;)
    {
        bool _S1403 = (fcptVaryingUsed());
        if(_S1403)
        {
            passes_0 = _S1402 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1404 = (fcptMajorant((_S1402)));
            spread_2 = _S1404;
        }
        else
        {
            spread_2 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_2)
        {
            turned_1 = 4294967295U == _S1382;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1371 == 1U;
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
            ended_0 = _S1367;
            sky_pdf_0 = 0.0f;
            spread_2 = _S1388;
            width_3 = _S1389;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_9 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1405 = (&prev_0)->rough;
        if(_S1405)
        {
            turned_1 = !(spread_2 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S1406 = stream(_S1394, 384U);
        uint tracking_0 = _S1406;
        weight_2 = throughput_3;
        glowed_0 = _S1366;
        b_9 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        wavelength_6 = _S1388;
        width_3 = _S1389;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1365 = int(1);
                break;
            }
            uint _S1407 = noiseAddress(_S1394, b_9);
            Random _S1408 = draw(_S1407, 10U);
            float _S1409 = freeFlight_0(_S1408.value, spread_2);
            if(passes_0)
            {
                float3  _S1410 = (&ray_2)->origin;
                float3  _S1411 = (&ray_2)->unit_direction;
                float _S1412 = (&hit_4)->distance;
                bool _S1413 = b_9 == 4294967295U;
                uint _S1414 = _slang_select(_S1413, 0U,b_9);
                uint _S1415 = (&prev_0)->lobe;
                uint _S1416 = _slang_select(_S1413, 3U,_S1415);
                float _S1417 = (fcptTrackMedium((_S1402), (_S1410), (_S1411), (_S1412), (&tracking_0), (&weight_2), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1414), (_S1416), (_S1413)));
                threshold_2 = _S1417;
            }
            else
            {
                threshold_2 = _S1409;
            }
            bool _S1418 = !(threshold_2 < ((&hit_4)->distance));
            if(_S1418)
            {
                _S1365 = int(1);
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
                float3  _S1419 = pathColor(throughput_2 * glowed_0, throughput_3, 0.0f);
                float3  _S1420 = _S1419 / make_float3 (density_2);
                float3  _S1421 = sel_7->glow + _S1420;
                sel_7->glow = _S1421;
            }
            else
            {
            }
            glowed_0 = _S1366;
            uint b_11 = b_9 + 1U;
            float3  _S1422 = (&ray_2)->origin + make_float3 (threshold_2) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1422;
            float3  _S1423 = flightWeight_0(scatter_in_0, extinction_in_0, spread_2, threshold_2, true);
            float3  _S1424 = weight_2;
            float _S1425 = upsample(weight_2, 0.0f);
            float3  _S1426 = make_float3 (_S1425);
            float3  _S1427 = _slang_select(false, _S1426,_S1424);
            float3  _S1428 = _slang_select(passes_0, _S1427,_S1423);
            float3  throughput_4 = throughput_2 * _S1428;
            uint _S1429 = stream(_S1394, b_11 + 320U);
            tracking_0 = _S1429;
            weight_2 = throughput_3;
            float width_6 = width_3 + wavelength_6 * threshold_2;
            float _S1430 = wavelength_6 + 3.14159274101257324f;
            bool _S1431 = scatterSampled_0(replay_2, b_11, _S1382, passes_0);
            TreeSample _S1432 = TreeSample_x24init_0(_S1366, _S1366, 0.0f, 0U);
            if(_S1431)
            {
                float3  _S1433 = (&ray_2)->origin;
                float3  _S1434 = (&ray_2)->unit_direction;
                float3  _S1435 = (&ray_2)->unit_direction;
                uint _S1436 = noiseAddress(_S1394, b_11);
                float3  _S1437 = extinction_in_0;
                float3  _S1438 = extinction_in_0;
                uint2  _S1439 = make_uint2 (_S1402);
                float3  _S1440 = (&ray_2)->unit_direction;
                uint _S1441 = arrivalLobe_0(b_11, (&prev_0)->lobe);
                FKHit _S1442 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1443 = _S1442;
                ShadowContext _S1444 = ShadowContext_x24init_0(_S1437, _S1438, _S1439, _S1440, b_11, _S1441, false, threshold_2, width_6, &_S1443, false);
                ShadowContext _S1445 = _S1444;
                TreeSample _S1446 = sampleLightTree_0(_S1433, _S1434, _S1435, 0.0f, true, _S1436, &_S1445);
                light_3 = _S1446;
            }
            else
            {
                light_3 = _S1432;
            }
            float _S1447 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S1448 = (fcptMaxBounces());
            bool _S1449 = b_11 < _S1448;
            if(_S1449)
            {
                is_inside_7 = (light_3.density) > 0.0f;
            }
            else
            {
                is_inside_7 = false;
            }
            float _S1450 = _slang_select(is_inside_7, _S1447,0.0f);
            float3  _S1451 = throughput_4 * light_3.radiance;
            float _S1452 = powerHeuristic(light_3.density, _S1450);
            float3  _S1453 = pathColor(_S1451 * make_float3 (_S1447 * _S1452), throughput_3, 0.0f);
            float3  _S1454 = _slang_select(_S1431, _S1453,_S1366);
            if(replay_2)
            {
                viewed_0 = b_11 == _S1382;
            }
            else
            {
                viewed_0 = false;
            }
            if(viewed_0)
            {
                bool _S1455 = _S1371 == 2U;
                if(_S1455)
                {
                    float _S1456 = resamplingTarget(_S1454);
                    passes_0 = _S1456 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1457 = Shift_x24init_0(_S1454, 1.0f);
                    _S1365 = int(0);
                    ended_0 = _S1457;
                    spread_2 = _S1430;
                    threshold_2 = width_6;
                    spectral_weight_0 = throughput_4;
                    layer_0 = b_11;
                    break;
                }
                _S1365 = int(0);
                ended_0 = _S1367;
                spread_2 = _S1430;
                threshold_2 = width_6;
                spectral_weight_0 = throughput_4;
                layer_0 = b_11;
                break;
            }
            bool _S1458 = !replay_2;
            if(_S1458)
            {
                Reservoir candidate_3 = _S1401;
                uint _S1459 = extractBits_0(_S1401.path, 24U, 8U);
                uint _S1460 = insertBits_0(0U, _S1459, 24U, 8U);
                uint _S1461 = extractBits_0(_S1401.path, 10U, 2U);
                bool _S1462 = _S1461 == 1U;
                if(_S1462)
                {
                    float3  _S1463 = safeDivide(_S1454, _S1366);
                    (&candidate_3)->radiance = _S1463;
                }
                else
                {
                    uint _S1464 = insertBits_0(_S1460, b_11 + 1U, 5U, 5U);
                    uint _S1465 = insertBits_0(_S1464, 2U, 10U, 2U);
                    (&candidate_3)->path = _S1465;
                }
                Reservoir _S1466 = withEnd(candidate_3, 0U, b_11, _S1454);
                offer(sel_7, _S1466, _S1454 * make_float3 (scale_3) / make_float3 (density_2));
                float _S1467 = survivalProbability(abs_0(throughput_4), density_2);
                uint _S1468 = noiseAddress(_S1394, b_11);
                Random _S1469 = draw(_S1468, 8U);
                bool _S1470 = _S1467 < (_S1469.value);
                if(_S1470)
                {
                    _S1364 = true;
                }
                else
                {
                    uint _S1471 = (fcptMaxBounces());
                    _S1364 = b_11 >= _S1471;
                }
                if(_S1364)
                {
                    _S1365 = int(0);
                    ended_0 = _S1367;
                    spread_2 = _S1430;
                    threshold_2 = width_6;
                    spectral_weight_0 = throughput_4;
                    layer_0 = b_11;
                    break;
                }
                float _S1472 = density_2 * _S1467;
                density_2 = _S1472;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1473 = noiseAddress(_S1394, b_11);
            float3  _S1474 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1473, &phase_pdf_0);
            (&ray_2)->unit_direction = _S1474;
            NEEVertex _S1475 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S1366, (&ray_2)->origin);
            nee_vertex_0 = _S1475;
            Vertex _S1476 = scatteredVertex_0(false);
            prev_0 = _S1476;
            float _S1477 = (&prev_0)->pdf;
            FKRay _S1478 = ray_2;
            FKHit _S1479 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1480 = (fcptTraverseInstanceBVH((_S1478), (true), (4.294967296e+09f), (false), (_S1479), (false)));
            hit_4 = _S1480;
            b_9 = b_11;
            throughput_2 = throughput_4;
            wavelength_6 = _S1430;
            width_3 = width_6;
            sky_pdf_0 = _S1477;
        }
        if(_S1365 != int(1))
        {
            width_3 = threshold_2;
            throughput_2 = spectral_weight_0;
            b_9 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1367;
        spread_2 = wavelength_6;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1481 = b_9 == 4294967295U;
    bool _S1482 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1482)
    {
        bool _S1483 = !(&nee_vertex_0)->none;
        float _S1484 = _slang_select(_S1483, sky_pdf_0,0.0f);
        float _S1485 = escapeWeight_0(_S1484, (&ray_2)->unit_direction);
        float3  _S1486 = environment_0((&ray_2)->unit_direction, b_9, (&prev_0)->lobe);
        float3  _S1487 = pathColor(throughput_2 * _S1486, throughput_3, 0.0f);
        if(replay_2)
        {
            bool _S1488 = b_9 == _S1382;
            if(_S1488)
            {
                passes_0 = _S1371 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S1487 * make_float3 (_S1485) / make_float3 (r_8->jac), density_2 / r_8->jac);
            }
            if(_S1381)
            {
                passes_0 = _S1378;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_9 == _S1369;
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
                return Shift_x24init_0(_S1487 * make_float3 (_S1485), 1.0f);
            }
            return _S1367;
        }
        Reservoir candidate_4 = chain_0;
        uint _S1489 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1490 = _S1489 == 1U;
        if(_S1490)
        {
            uint _S1491 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S1492 = _S1491 == b_9;
            float _S1493 = _slang_select(_S1492, 1.0f,_S1485);
            float3  _S1494 = safeDivide(_S1487 * make_float3 (_S1493), _S1366);
            (&candidate_4)->radiance = _S1494;
        }
        else
        {
            bool _S1495 = (&prev_0)->rough;
            if(_S1495)
            {
                uint _S1496 = insertBits_0(_S1396, b_9 + 1U, 5U, 5U);
                uint _S1497 = insertBits_0(_S1496, 3U, 10U, 2U);
                uint _S1498 = insertBits_0(_S1497, (&prev_0)->lobe, 15U, 3U);
                bool _S1499 = (&prev_0)->inside;
                uint _S1500 = _slang_select(_S1499, 1U,0U);
                uint _S1501 = insertBits_0(_S1498, _S1500, 22U, 1U);
                (&candidate_4)->path = _S1501;
                (&candidate_4)->jac = (&prev_0)->pdf;
                (&candidate_4)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S1502 = _S1487 * make_float3 (_S1485);
        Reservoir _S1503 = withEnd(candidate_4, 3U, b_9, _S1502);
        offer(sel_7, _S1503, _S1502 * make_float3 (scale_3) / make_float3 (density_2));
        return _S1367;
    }
    float3  _S1504 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S1504;
    bool _S1505 = (fcptVaryingUsed());
    if(_S1505)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1506 = !replay_2;
        if(_S1506)
        {
            float3  _S1507 = pathColor(throughput_2 * glowed_0, throughput_3, 0.0f);
            float3  _S1508 = _S1507 / make_float3 (density_2);
            float3  _S1509 = sel_7->glow + _S1508;
            sel_7->glow = _S1509;
        }
        float3  _S1510 = throughput_2 * weight_2;
        throughput_2 = _S1510;
    }
    else
    {
        float3  _S1511 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
        float3  _S1512 = throughput_2 * _S1511;
        throughput_2 = _S1512;
    }
    float _S1513 = width_3 + spread_2 * (&hit_4)->distance;
    uint _S1514 = b_9 + 1U;
    b_9 = _S1514;
    layer_0 = 0U;
    width_3 = _S1513;
    passes_0 = false;
    wavelength_6 = 0.0f;
    threshold_2 = 0.0f;
    turned_1 = false;
    is_inside_7 = false;
    spectral_weight_0 = throughput_3;
    float3  chain_throughput_0 = _S1366;
    float3  reconnection_0 = _S1366;
    viewed_0 = _S1481;
    for(;;)
    {
        bool _S1515 = ((&hit_4)->is_point_light) == 1U;
        if(replay_2)
        {
            _S1364 = _S1371 == 1U;
        }
        else
        {
            _S1364 = false;
        }
        bool _S1516;
        if(_S1364)
        {
            _S1516 = b_9 == _S1370;
        }
        else
        {
            _S1516 = false;
        }
        bool _S1517;
        if(_S1516)
        {
            bool _S1518 = ((&hit_4)->instance_index) != (_S1383.instance_index);
            if(_S1518)
            {
                _S1517 = true;
            }
            else
            {
                _S1517 = ((&hit_4)->triangle_index) != (_S1383.triangle_index);
            }
        }
        else
        {
            _S1517 = false;
        }
        if(_S1517)
        {
            return _S1367;
        }
        FKMedium _S1519 = Medium_x24init_0(_S1366, _S1366, 0.0f);
        BSDFMaterial _S1520 = Material_x24init_0(_S1366, _S1366, 0.0f, 0.0f, 0.0f, 0.0f, _S1366, throughput_3, 1.0f, _S1366, _S1366, 0.5f, 0.0f, 0.0f, _S1366, 0.0f, _S1366, 0.0f, 0.0f, 0.02999999932944775f, 1.5f, throughput_3, _S1366);
        FKMedium _S1521 = _S1519;
        FKSurface _S1522 = Surface_x24init_0(_S1366, _S1366, 0.0f, &_S1520, false, 0U, 1.0f, false, &_S1521, 4294967295U, _S1366);
        bool _S1523 = !_S1515;
        bool scatter_2;
        bool is_inside_8;
        float geometry_density_2;
        float3  throughput_5;
        FKSurface surface_13;
        if(_S1523)
        {
            uint _S1524 = noiseAddress(_S1394, b_9);
            uint _S1525 = arrivalLobe_0(b_9, (&prev_0)->lobe);
            FKSurface _S1526 = (fcptSurfaceAtPath((hit_4), ((&ray_2)->origin), (_S1524), (width_3), (layer_0), (b_9), (_S1525), ((&ray_2)->unit_direction)));
            bool _S1527 = !passes_0;
            FKSurface _S1528 = _S1526;
            FKSurface _S1529 = emitting_0(&_S1528, _S1527);
            uint _S1530 = noiseAddress(_S1394, b_9);
            Random _S1531 = draw(_S1530, 9U);
            FKSurface _S1532 = _S1529;
            FKSurface _S1533 = uncovered_0(&_S1532, _S1531.value);
            float _S1534 = facingSign(_S1533.material.transmission, _S1533.geometry_n, (&ray_2)->unit_direction);
            bool _S1535 = _S1534 < 0.0f;
            bool _S1536 = (_S1533.material.transmission) > 0.0f;
            if(_S1536)
            {
                bool _S1537 = arrivesBehind_0((&ray_2)->unit_direction, _S1533.geometry_n);
                scatter_2 = _S1537;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1538 = _S1533;
            FKSurface _S1539 = facingRay_0(&_S1538, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S1540 = arrivesBehind_0((&ray_2)->unit_direction, _S1539.geometry_n);
                is_inside_8 = _S1540;
            }
            else
            {
                is_inside_8 = scatter_2;
            }
            if(is_inside_8)
            {
                float _S1541 = (&hit_4)->distance;
                float _S1542 = upsample(_S1539.material.absorption, wavelength_6);
                float3  _S1543 = make_float3 (_S1542);
                bool _S1544 = wavelength_6 > 0.0f;
                float3  _S1545 = _slang_select(_S1544, _S1543,_S1539.material.absorption);
                float3  _S1546 = beerLambert(_S1541, _S1545);
                float3  _S1547 = throughput_2 * _S1546;
                throughput_5 = _S1547;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S1548 = !_S1539.skip;
            float geometry_density_3 = geometryDensity(_S1539.geometry_n, (&ray_2)->unit_direction, (&hit_4)->distance);
            bool _S1549 = b_9 == _S1514;
            if(_S1549)
            {
                float _S1550 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S1550;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            float _S1551 = geometry_density_2;
            scatter_2 = _S1548;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S1551;
            surface_13 = _S1539;
            turned_1 = _S1535;
        }
        else
        {
            scatter_2 = false;
            geometry_density_2 = 0.0f;
            surface_13 = _S1522;
            throughput_5 = throughput_2;
            is_inside_8 = is_inside_7;
        }
        bool _S1552 = withinFootprint(scatter_2, (&prev_0)->rough, (&prev_0)->pdf, geometry_density_2, threshold_2);
        FKSurface _S1553 = surface_13;
        float _S1554 = dot_0(surface_13.smooth_n, - (&ray_2)->unit_direction);
        bool _S1555 = (fcptDispersionUsed());
        bool _S1556;
        if(_S1555)
        {
            _S1556 = wavelength_6 == 0.0f;
        }
        else
        {
            _S1556 = false;
        }
        bool _S1557;
        if(_S1556)
        {
            _S1557 = scatter_2;
        }
        else
        {
            _S1557 = false;
        }
        bool _S1558;
        if(_S1557)
        {
            bool _S1559 = dispersive(surface_13.material);
            _S1558 = _S1559;
        }
        else
        {
            _S1558 = false;
        }
        float3  throughput_6;
        if(_S1558)
        {
            uint _S1560 = stream(_S1394, 512U);
            Random _S1561 = pcg(_S1560);
            uint _S1562 = extractBits_0(_S1368, 25U, 7U);
            float _S1563 = (float(_S1562) + _S1561.value) / 128.0f;
            uint _S1564 = extractBits_0(_S1368, 24U, 1U);
            bool _S1565 = _S1564 == 1U;
            float _S1566 = _slang_select(_S1565, _S1563,_S1561.value);
            float2  _S1567 = sampleWavelength(_S1566);
            float wavelength_7 = _S1567.x;
            float3  _S1568 = wavelengthWeights(wavelength_7);
            float3  _S1569 = _S1568 / make_float3 (_S1567.y);
            float _S1570 = upsample(throughput_5, wavelength_7);
            float3  _S1571 = make_float3 (_S1570);
            float _S1572 = upsample(scatter_in_0, wavelength_7);
            float3  _S1573 = make_float3 (_S1572);
            scatter_in_0 = _S1573;
            float _S1574 = upsample(extinction_in_0, wavelength_7);
            float3  _S1575 = make_float3 (_S1574);
            extinction_in_0 = _S1575;
            wavelength_6 = wavelength_7;
            throughput_6 = _S1571;
            spectral_weight_0 = _S1569;
        }
        else
        {
            throughput_6 = throughput_5;
        }
        bool _S1576 = wavelength_6 > 0.0f;
        BSDFMaterial _S1577;
        if(_S1576)
        {
            BSDFMaterial _S1578 = atWavelength(surface_13.material, wavelength_6);
            _S1577 = _S1578;
        }
        else
        {
            _S1577 = surface_13.material;
        }
        float2  _S1579 = wavelengthEta(_S1577, _S1554, wavelength_6);
        bool _S1580;
        if(scatter_2)
        {
            bool _S1581 = neeDecision(_S1577, _S1554, _S1579.x, _S1579.y);
            _S1580 = _S1581;
        }
        else
        {
            _S1580 = false;
        }
        bool _S1582;
        if(passes_0)
        {
            _S1582 = true;
        }
        else
        {
            _S1582 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1582)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1580;
        }
        bool _S1583 = (fcptHairUsed());
        bool _S1584;
        if(_S1583)
        {
            float3  _S1585 = surface_13.hair;
            _S1584 = (dot_0(_S1585, _S1585)) > 0.0f;
        }
        else
        {
            _S1584 = false;
        }
        bool _S1586;
        if(_S1584)
        {
            _S1586 = true;
        }
        else
        {
            BSDFMaterial _S1587 = _S1577;
            bool _S1588 = isTranslucent_0(&_S1587);
            _S1586 = _S1588;
        }
        bool _S1589;
        if(_S1586)
        {
            _S1589 = true;
        }
        else
        {
            bool _S1590 = (_S1577.transmission) > 0.0f;
            if(_S1590)
            {
                uint _S1591 = (fcptLayers((hit_4)));
                _S1589 = _S1591 == 1U;
            }
            else
            {
                _S1589 = false;
            }
        }
        BSDFMaterial _S1592 = _S1577;
        float3  emission_0;
        if(_S1515)
        {
            float3  _S1593 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1593;
        }
        else
        {
            emission_0 = _S1592.emissive;
        }
        float _S1594 = rgb_to_greyscale(emission_0);
        bool _S1595 = _S1594 > 0.0f;
        float3  emission_1;
        if(_S1595)
        {
            NEEVertex _S1596 = nee_vertex_0;
            FKHit _S1597 = hit_4;
            float _S1598 = emissionWeight_0(&_S1596, &_S1597, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1598);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1599;
        if(replay_2)
        {
            _S1599 = _S1371 == 1U;
        }
        else
        {
            _S1599 = false;
        }
        bool _S1600;
        if(_S1599)
        {
            _S1600 = b_9 > _S1370;
        }
        else
        {
            _S1600 = false;
        }
        bool _S1601;
        if(_S1600)
        {
            _S1601 = b_9 == _S1369;
        }
        else
        {
            _S1601 = false;
        }
        bool _S1602;
        if(_S1601)
        {
            bool _S1603 = _S1372 == 1U;
            if(_S1603)
            {
                _S1602 = true;
            }
            else
            {
                _S1602 = _S1372 == 2U;
            }
        }
        else
        {
            _S1602 = false;
        }
        if(_S1602)
        {
            bool _S1604 = _S1515 != (_S1372 == 2U);
            if(_S1604)
            {
                return _S1367;
            }
            float3  _S1605 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_6);
            return Shift_x24init_0(_S1605 / make_float3 (r_8->jac), density_2 / r_8->jac);
        }
        uint _S1606 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1607 = _S1606 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1608 = insertBits_0(_S1396, b_9, 5U, 5U);
        uint _S1609 = insertBits_0(_S1608, 1U, 10U, 2U);
        uint _S1610 = insertBits_0(_S1609, (&prev_0)->lobe, 15U, 3U);
        bool _S1611 = (&prev_0)->inside;
        uint _S1612 = _slang_select(_S1611, 1U,0U);
        uint _S1613 = insertBits_0(_S1610, _S1612, 22U, 1U);
        (&here_0)->path = _S1613;
        uint _S1614 = (&here_0)->path;
        uint _S1615 = _slang_select(_S1576, 1U,0U);
        uint _S1616 = insertBits_0(_S1614, _S1615, 23U, 1U);
        (&here_0)->path = _S1616;
        float _S1617 = (&prev_0)->pdf * geometry_density_2;
        (&here_0)->jac = _S1617;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1618;
        if(replay_2)
        {
            _S1618 = _S1371 == 1U;
        }
        else
        {
            _S1618 = false;
        }
        bool _S1619;
        if(_S1618)
        {
            _S1619 = b_9 == _S1370;
        }
        else
        {
            _S1619 = false;
        }
        bool _S1620 = b_9 == _S1382;
        bool _S1621;
        if(_S1620)
        {
            bool _S1622 = !scatter_2;
            if(_S1622)
            {
                _S1621 = true;
            }
            else
            {
                bool _S1623 = _S1371 != 1U;
                if(_S1623)
                {
                    _S1621 = _S1371 != 3U;
                }
                else
                {
                    _S1621 = false;
                }
            }
        }
        else
        {
            _S1621 = false;
        }
        bool _S1624;
        if(_S1621)
        {
            _S1624 = _S1371 == 2U;
        }
        else
        {
            _S1624 = false;
        }
        bool _S1625;
        if(_S1624)
        {
            _S1625 = !_S1552;
        }
        else
        {
            _S1625 = false;
        }
        bool _S1626;
        if(_S1625)
        {
            _S1626 = _S1372 != 4U;
        }
        else
        {
            _S1626 = false;
        }
        bool _S1627 = _S1370 == _S1369;
        bool _S1628;
        if(_S1627)
        {
            _S1628 = _S1372 == 0U;
        }
        else
        {
            _S1628 = false;
        }
        bool _S1629;
        if(_S1628)
        {
            _S1629 = ((&hit_4)->instance_index) == (_S1383.instance_index);
        }
        else
        {
            _S1629 = false;
        }
        bool _S1630;
        if(_S1629)
        {
            _S1630 = ((&hit_4)->triangle_index) == (_S1383.triangle_index);
        }
        else
        {
            _S1630 = false;
        }
        bool _S1631;
        if(_S1630)
        {
            _S1631 = _S1552;
        }
        else
        {
            _S1631 = false;
        }
        bool _S1632 = _slang_select(_S1619, _S1631,_S1626);
        bool _S1633;
        if(nee_0)
        {
            _S1633 = _slang_select(replay_2, _S1632,scatter_2);
        }
        else
        {
            _S1633 = false;
        }
        TreeSample _S1634 = TreeSample_x24init_0(_S1366, _S1366, 0.0f, 0U);
        uint2  _S1635 = make_uint2 (0U);
        float2  _S1636 = make_float2 (0.0f);
        FKHit _S1637 = Hit_x24init_0(_S1636, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1638 = _S1637;
        ShadowContext _S1639 = ShadowContext_x24init_0(_S1366, _S1366, _S1635, _S1366, 0U, 0U, false, 0.0f, 0.0f, &_S1638, false);
        ShadowContext context_5;
        if(nee_0)
        {
            uint _S1640 = arrivalLobe_0(b_9, (&prev_0)->lobe);
            FKMedium _S1641 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1642 = surface_13;
            FKHit _S1643 = hit_4;
            FKMedium _S1644 = _S1641;
            ShadowContext _S1645 = shadowContext_0(&_S1642, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_9, _S1640, (&hit_4)->distance, width_3, &_S1643, _S1584, &_S1644);
            context_5 = _S1645;
        }
        else
        {
            context_5 = _S1639;
        }
        float3  throughput_7;
        float3  lit_0;
        if(_S1633)
        {
            float3  _S1646 = (&ray_2)->origin;
            if(_S1584)
            {
                throughput_7 = _S1366;
            }
            else
            {
                throughput_7 = _S1553.smooth_n;
            }
            FKSurface _S1647 = surface_13;
            uint _S1648 = noiseAddress(_S1394, b_9);
            ShadowContext _S1649 = context_5;
            TreeSample _S1650 = sampleLightTree_0(_S1646, throughput_7, surface_13.geometry_n, surface_13.geometry_offset, _S1589, _S1648, &_S1649);
            bool _S1651 = any_1((_S1650.radiance) != _S1366);
            if(_S1651)
            {
                if(_S1584)
                {
                    uint _S1652 = (fcptMaxBounces());
                    bool _S1653 = b_9 < _S1652;
                    FKSurface _S1654 = surface_13;
                    TreeSample _S1655 = _S1650;
                    float3  _S1656 = hairLight_0(&_S1654, (&ray_2)->unit_direction, &_S1655, _S1653);
                    lit_0 = _S1656;
                }
                else
                {
                    float _S1657 = _S1579.x;
                    float _S1658 = _S1579.y;
                    uint _S1659 = (fcptMaxBounces());
                    bool _S1660 = b_9 < _S1659;
                    TreeSample _S1661 = _S1650;
                    BSDFMaterial _S1662 = _S1577;
                    float3  _S1663 = lightBSDF_0((&ray_2)->unit_direction, &_S1661, _S1553.smooth_n, _S1647.geometry_n, &_S1662, _S1657, _S1658, _S1660, surface_13.random_state);
                    lit_0 = _S1663;
                }
            }
            else
            {
                lit_0 = _S1366;
            }
            light_3 = _S1650;
        }
        else
        {
            light_3 = _S1634;
            lit_0 = _S1366;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1664;
        bool _S1665;
        float density_4;
        if(_S1619)
        {
            bool _S1666 = !_S1552;
            if(_S1666)
            {
                return _S1367;
            }
            uint _S1667 = extractBits_0(_S1368, 23U, 1U);
            bool _S1668 = _S1576 != (_S1667 == 1U);
            if(_S1668)
            {
                return _S1367;
            }
            float3  throughput_8 = throughput_6 * make_float3 (geometry_density_2);
            float density_5 = density_2 * geometry_density_2;
            if(_S1627)
            {
                viewed_1 = _S1372 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                float3  _S1669 = pathColor(throughput_8 * emission_1, spectral_weight_0, wavelength_6);
                return Shift_x24init_0(_S1669 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1627)
            {
                refracted_4 = _S1372 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S1670 = !nee_0;
                if(_S1670)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1671 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1671 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1367;
                }
                float3  _S1672 = pathColor(throughput_8 * lit_0, spectral_weight_0, wavelength_6);
                return Shift_x24init_0(_S1672 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1627)
            {
                wrong_side_0 = _S1372 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1673 = !nee_0;
                if(_S1673)
                {
                    return _S1367;
                }
                bool _S1674 = (fcptWorldReadsPath());
                if(_S1674)
                {
                    float _S1675 = environmentPdf_0(r_8->dir);
                    uint _S1676 = b_9 + 1U;
                    FKSurface _S1677 = surface_13;
                    float3  _S1678 = skyColor_0((&ray_2)->unit_direction, r_8->dir, &_S1677, _S1579, is_inside_8, _S1675, surface_13.random_state, _S1676);
                    float3  _S1679 = pathColor(throughput_8 * (_S1678 * r_8->radiance), spectral_weight_0, wavelength_6);
                    return Shift_x24init_0(_S1679 / make_float3 (r_8->jac), density_5 / r_8->jac);
                }
                float _S1680 = environmentPdf_0(r_8->dir);
                float3  _S1681 = skyBSDF((&ray_2)->unit_direction, r_8->dir, surface_13, _S1579, is_inside_8, _S1680, surface_13.random_state);
                float3  _S1682 = pathColor(throughput_8 * _S1681 * r_8->radiance, spectral_weight_0, wavelength_6);
                return Shift_x24init_0(_S1682 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            uint _S1683 = extractBits_0(_S1368, 21U, 1U);
            bool _S1684 = nee_0 != (_S1683 == 1U);
            if(_S1684)
            {
                return _S1367;
            }
            throughput_7 = throughput_8;
            density_4 = density_5;
        }
        else
        {
            if(replay_2)
            {
                viewed_1 = _S1620;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1685 = !scatter_2;
                if(_S1685)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1686 = _S1371 != 1U;
                    if(_S1686)
                    {
                        refracted_4 = _S1371 != 3U;
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
                bool _S1687 = _S1371 == 2U;
                if(_S1687)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1552;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1372 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1584)
                    {
                        return _S1367;
                    }
                    uint _S1688 = noiseAddress(_S1394, b_9);
                    FKRay _S1689 = ray_2;
                    FKSurface _S1690 = surface_13;
                    ShadowContext _S1691 = context_5;
                    SkySample _S1692 = sampleSky_0(&_S1689, &_S1690, _S1579, is_inside_8, _S1688, surface_13.random_state, &_S1691);
                    float3  _S1693 = pathColor(throughput_6 * _S1692.color, spectral_weight_0, wavelength_6);
                    return Shift_x24init_0(_S1693, 1.0f);
                }
                if(_S1687)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1552;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1694 = rgb_to_greyscale(light_3.radiance);
                    bool _S1695 = !(_S1694 > 0.0f);
                    if(_S1695)
                    {
                        return _S1367;
                    }
                    float3  _S1696 = pathColor(throughput_6 * lit_0, spectral_weight_0, wavelength_6);
                    return Shift_x24init_0(_S1696, 1.0f);
                }
                if(_S1381)
                {
                    passes_0 = _S1372 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1515;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float3  _S1697 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_6);
                    return Shift_x24init_0(_S1697, 1.0f);
                }
                if(_S1381)
                {
                    passes_0 = _S1372 == 1U;
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
                    passes_0 = !_S1552;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float3  _S1698 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_6);
                    return Shift_x24init_0(_S1698, 1.0f);
                }
                return _S1367;
            }
            else
            {
                bool _S1699 = !replay_2;
                if(_S1699)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1700 = b_9 > 0U;
                    if(_S1700)
                    {
                        Reservoir candidate_5 = chain_0;
                        if(_S1607)
                        {
                            float3  _S1701 = safeDivide(throughput_6 * emission_1, chain_throughput_0);
                            (&candidate_5)->radiance = _S1701;
                        }
                        else
                        {
                            if(_S1552)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1702 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_6);
                        Reservoir _S1703 = withEnd(candidate_5, 1U, b_9, _S1702);
                        offer(sel_7, _S1703, _S1702 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1704 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_6);
                        float3  _S1705 = sel_7->glow + _S1704;
                        sel_7->glow = _S1705;
                    }
                    if(nee_0)
                    {
                        float3  _S1706 = pathColor(throughput_6 * lit_0, spectral_weight_0, wavelength_6);
                        Reservoir candidate_6 = chain_0;
                        if(_S1607)
                        {
                            float3  _S1707 = safeDivide(_S1706, chain_throughput_0);
                            (&candidate_6)->radiance = _S1707;
                        }
                        else
                        {
                            if(_S1552)
                            {
                                candidate_6 = here_0;
                                uint _S1708 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1708;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1709 = insertBits_0(_S1396, b_9 + 1U, 5U, 5U);
                                uint _S1710 = insertBits_0(_S1709, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1710;
                            }
                        }
                        Reservoir _S1711 = withEnd(candidate_6, 0U, b_9, _S1706);
                        offer(sel_7, _S1711, _S1706 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1584)
                        {
                            _S1664 = false;
                        }
                        else
                        {
                            bool _S1712 = environmentMapped_0();
                            _S1664 = _S1712;
                        }
                    }
                    else
                    {
                        _S1664 = false;
                    }
                    if(_S1664)
                    {
                        uint _S1713 = (fcptMaxBounces());
                        _S1665 = b_9 < _S1713;
                    }
                    else
                    {
                        _S1665 = false;
                    }
                    if(_S1665)
                    {
                        uint _S1714 = noiseAddress(_S1394, b_9);
                        FKRay _S1715 = ray_2;
                        FKSurface _S1716 = surface_13;
                        ShadowContext _S1717 = context_5;
                        SkySample _S1718 = sampleSky_0(&_S1715, &_S1716, _S1579, is_inside_8, _S1714, surface_13.random_state, &_S1717);
                        float3  _S1719 = pathColor(throughput_6 * _S1718.color, spectral_weight_0, wavelength_6);
                        Reservoir candidate_7 = chain_0;
                        if(_S1607)
                        {
                            float3  _S1720 = safeDivide(_S1719, chain_throughput_0);
                            (&candidate_7)->radiance = _S1720;
                        }
                        else
                        {
                            if(_S1552)
                            {
                                candidate_7 = here_0;
                                uint _S1721 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1721;
                                (&candidate_7)->dir = _S1718.dir;
                                (&candidate_7)->radiance = _S1718.radiance;
                            }
                            else
                            {
                                uint _S1722 = insertBits_0(_S1396, b_9 + 1U, 5U, 5U);
                                uint _S1723 = insertBits_0(_S1722, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1723;
                            }
                        }
                        Reservoir _S1724 = withEnd(candidate_7, 4U, b_9, _S1719);
                        offer(sel_7, _S1724, _S1719 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                }
            }
            throughput_7 = throughput_6;
            density_4 = density_2;
        }
        bool _S1725;
        bool _S1726;
        bool _S1727;
        bool straight_0;
        bool _S1728;
        bool _S1729;
        bool _S1730;
        bool _S1731;
        bool _S1732;
        bool _S1733;
        bool _S1734;
        bool _S1735;
        bool _S1736;
        bool _S1737;
        bool _S1738;
        bool _S1739;
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
                viewed_1 = _S1620;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1740 = extractBits_0(_S1368, 15U, 3U);
            uint _S1741 = extractBits_0(_S1368, 18U, 3U);
            uint _S1742 = _slang_select(_S1619, _S1741,_S1740);
            float3  _S1743 = r_8->dir;
            bool refracted_5 = _S1742 == 1U;
            SampleBSDF _S1744 = SampleBSDF_x24init_0(_S1366, _S1366, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1744;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1745 = extractBits_0(_S1368, 22U, 1U);
                bool _S1746 = is_inside_8 != (_S1745 == 1U);
                if(_S1746)
                {
                    return _S1367;
                }
                bool _S1747 = _S1371 == 1U;
                if(_S1747)
                {
                    float3  _S1748 = (fcptHitPosition((_S1383)));
                    throughput_9 = _S1748;
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
                    BSDFMaterial _S1749 = _S1577;
                    bool _S1750 = isTranslucent_0(&_S1749);
                    if(_S1750)
                    {
                        refracted_4 = _S1742 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1751 = throughput_9 - (&ray_2)->origin;
                        float3  _S1752 = _slang_select(_S1747, _S1751,_S1743);
                        wrong_side_0 = (dot_0(_S1553.smooth_n, _S1752) * _S1554) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1747)
                {
                    float3  _S1753 = (&ray_2)->origin;
                    FKSurface _S1754 = surface_13;
                    float3  _S1755 = - _S1553.smooth_n;
                    bool _S1756 = is_inside_8 != refracted_4;
                    float3  _S1757 = _slang_select(_S1756, _S1755,_S1553.smooth_n);
                    float3  _S1758 = throughput_9 - (_S1753 + make_float3 (_S1754.geometry_offset) * _S1757);
                    float3  _S1759 = ((((_S1758)) * make_float3(rnorm3df(((_S1758)).x, ((_S1758)).y, ((_S1758)).z))));
                    reconnection_1 = _S1759;
                }
                else
                {
                    reconnection_1 = _S1743;
                }
                if(_S1584)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1760 = wrongSide_0(is_inside_8, refracted_4, reconnection_1, surface_13.geometry_n);
                    wrong_side_0 = _S1760;
                }
                if(wrong_side_0)
                {
                    return _S1367;
                }
                float3  _S1761 = throughput_9;
                throughput_9 = reconnection_1;
                b_12 = _S1742;
                wrong_side_0 = false;
                reconnection_1 = _S1761;
            }
            else
            {
                bool _S1762 = !_S1619;
                if(_S1762)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1763;
                    if(_S1584)
                    {
                        SampleBSDF _S1764 = (fcptSampleHair((surface_13.hair), (_S1577.albedo), (_S1577.specular_tint), ((&ray_2)->unit_direction), (surface_13.random_state)));
                        _S1763 = _S1764;
                    }
                    else
                    {
                        SampleBSDF _S1765 = sampleBSDF((&ray_2)->unit_direction, _S1553.smooth_n, _S1577, _S1579.x, _S1579.y, surface_13.random_state, _S1636);
                        _S1763 = _S1765;
                    }
                    bsdf_sampled_0 = _S1763;
                    if(_S1584)
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
                            return _S1367;
                        }
                        break;
                    }
                    if(_S1584)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1766 = wrongSide_0(is_inside_8, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_13.geometry_n);
                        wrong_side_0 = _S1766;
                    }
                    if(wrong_side_0)
                    {
                        _S1664 = (_S1577.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1664 = false;
                    }
                    if(_S1664)
                    {
                        SampleBSDF _S1767 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_13.geometry_n, _S1577, _S1579.x, _S1579.y, (&bsdf_sampled_0)->random_state, _S1636);
                        (&bsdf_sampled_0)->unit_direction = _S1767.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1767.refracted;
                        (&bsdf_sampled_0)->throughput = _S1767.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1768 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_13.geometry_n)) * surface_13.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1768;
                        }
                    }
                    uint _S1769 = (&bsdf_sampled_0)->lobe;
                    float3  _S1770 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1771 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1772 = (&bsdf_sampled_0)->pdf;
                    float _S1773 = _slang_select(wrong_side_0, 0.0f,_S1772);
                    (&lobe_5)->pdf = _S1773;
                    throughput_9 = _S1770;
                    b_12 = _S1769;
                    refracted_4 = _S1771;
                }
                else
                {
                    throughput_9 = _S1743;
                    b_12 = _S1742;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1664 = true;
            }
            else
            {
                _S1664 = _S1619;
            }
            float3  chain_throughput_1;
            if(_S1664)
            {
                if(_S1584)
                {
                    SampleBSDF _S1774 = (fcptConnectHair((surface_13.hair), (_S1577.albedo), (_S1577.specular_tint), ((&ray_2)->unit_direction), (throughput_9)));
                    lobe_5 = _S1774;
                }
                else
                {
                    float3  _S1775 = (&ray_2)->unit_direction;
                    float3  _S1776 = negate_0(_S1775);
                    float _S1777 = sign_0(_S1554);
                    float3  _S1778 = _S1553.smooth_n * make_float3 (_S1777);
                    float _S1779 = dot_0(_S1778, throughput_9);
                    float _S1780 = _S1577.roughness;
                    float _S1781 = _S1780 * _S1780;
                    AnisotropicFrame _S1782 = anisotropicFrame(_S1577, _S1778);
                    float3  _S1783 = reflectedHalf(_S1775, throughput_9);
                    bool _S1784 = b_12 == 1U;
                    if(_S1784)
                    {
                        float3  _S1785 = refractedHalf(_S1775, throughput_9, _S1553.smooth_n, _S1579.x, _S1579.y);
                        throughput_10 = _S1785;
                    }
                    else
                    {
                        throughput_10 = _S1783;
                    }
                    FKSurface _S1786 = surface_13;
                    float3  _S1787 = coatHalf(_S1776, _S1778, _S1577, surface_13.random_state);
                    bool _S1788 = b_12 == 5U;
                    float3  _S1789 = _slang_select(_S1788, throughput_10,_S1787);
                    bool _S1790 = b_12 == 0U;
                    if(_S1790)
                    {
                        _S1665 = true;
                    }
                    else
                    {
                        _S1665 = b_12 == 6U;
                    }
                    if(_S1665)
                    {
                        _S1725 = true;
                    }
                    else
                    {
                        _S1725 = _S1788;
                    }
                    if(_S1725)
                    {
                        float3  _S1791 = sampledHalf(_S1776, _S1778, _S1781, _S1782, _S1786.random_state);
                        throughput_11 = _S1791;
                    }
                    else
                    {
                        throughput_11 = throughput_10;
                    }
                    float _S1792 = _S1579.x;
                    float _S1793 = _S1579.y;
                    Weights _S1794 = lobeWeights(_S1775, _S1776, _S1778, throughput_11, _S1789, _S1782, _S1577, _S1792, _S1793);
                    float _S1795 = (F32_abs((_S1554)));
                    float _S1796 = vndfPDF(_S1776, throughput_11, _S1778, _S1795, _S1781, _S1782, _S1794.v_dot_h);
                    switch(b_12)
                    {
                    case 0U:
                        {
                            float _S1797 = diffusePDF(_S1779, _S1795, _S1577, _S1794);
                            float3  _S1798 = diffuseBSDF(throughput_9, _S1778, _S1577, _S1794);
                            density_6 = _S1797;
                            chain_throughput_1 = _S1798;
                            break;
                        }
                    case 1U:
                        {
                            float _S1799 = refractPDF(dot_0(throughput_9, throughput_11), _S1796, _S1794, _S1792, _S1793);
                            float3  _S1800 = refractBSDF(throughput_9, _S1778, _S1781, _S1782, _S1577, _S1794);
                            density_6 = _S1799;
                            chain_throughput_1 = _S1800;
                            break;
                        }
                    case 4U:
                        {
                            float _S1801 = sheenVelvetPDF(_S1779, _S1795, _S1794);
                            float3  _S1802 = sheenVelvetBSDF(throughput_9, _S1776, _S1778, _S1577, _S1794);
                            density_6 = _S1801;
                            chain_throughput_1 = _S1802;
                            break;
                        }
                    case 5U:
                        {
                            float _S1803 = coatPDF(_S1794);
                            float3  _S1804 = coatBSDF(_S1794);
                            density_6 = _S1803;
                            chain_throughput_1 = _S1804;
                            break;
                        }
                    case 6U:
                        {
                            ToonShape _S1805 = toonShape(_S1776, _S1778, _S1577);
                            float _S1806 = toonPDF(_S1779, dot_0(throughput_9, _S1805.axis), _S1805, _S1794);
                            float3  _S1807 = toonBSDF(throughput_9, _S1778, _S1805, _S1794);
                            density_6 = _S1806;
                            chain_throughput_1 = _S1807;
                            break;
                        }
                    default:
                        {
                            float _S1808 = reflectPDF(_S1796, _S1794);
                            float3  _S1809 = reflectBSDF(throughput_9, _S1778, _S1781, _S1782, _S1794);
                            density_6 = _S1808;
                            chain_throughput_1 = _S1809;
                            break;
                        }
                    }
                    bool _S1810 = density_6 > 0.0f;
                    if(_S1810)
                    {
                        SampleBSDF _S1811 = SampleBSDF_x24init_0(throughput_9, chain_throughput_1, _S1786.random_state, _S1784, b_12, density_6);
                        lobe_5 = _S1811;
                    }
                }
            }
            bool _S1812 = b_12 == 0U;
            if(_S1812)
            {
                _S1665 = true;
            }
            else
            {
                _S1665 = b_12 == 4U;
            }
            if(_S1665)
            {
                _S1725 = true;
            }
            else
            {
                _S1725 = b_12 == 6U;
            }
            BSDFMaterial _S1813 = _S1577;
            BSDFMaterial _S1814 = _S1577;
            bool _S1815 = b_12 == 5U;
            float _S1816 = _slang_select(_S1815, _S1814.coat_roughness,_S1813.roughness);
            if(_S1584)
            {
                _S1726 = false;
            }
            else
            {
                bool _S1817 = !_S1725;
                if(_S1817)
                {
                    bool _S1818 = _S1816 == 0.0f;
                    if(_S1818)
                    {
                        _S1726 = true;
                    }
                    else
                    {
                        bool _S1819 = b_12 == 1U;
                        if(_S1819)
                        {
                            _S1726 = (_S1579.x) == (_S1579.y);
                        }
                        else
                        {
                            _S1726 = false;
                        }
                    }
                }
                else
                {
                    _S1726 = false;
                }
            }
            bool _S1820 = !_S1584;
            if(_S1820)
            {
                _S1727 = b_12 == 1U;
            }
            else
            {
                _S1727 = false;
            }
            if(_S1727)
            {
                straight_0 = (_S1577.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1728 = _S1820;
            }
            else
            {
                _S1728 = false;
            }
            if(_S1728)
            {
                _S1729 = b_12 == 1U;
            }
            else
            {
                _S1729 = false;
            }
            if(_S1729)
            {
                _S1730 = (_S1579.x) == (_S1579.y);
            }
            else
            {
                _S1730 = false;
            }
            BSDFMaterial _S1821 = _S1577;
            bool _S1822 = isTranslucent_0(&_S1821);
            if(_S1822)
            {
                _S1731 = _S1812;
            }
            else
            {
                _S1731 = false;
            }
            if(_S1731)
            {
                _S1732 = (dot_0(throughput_9, surface_13.geometry_n)) < 0.0f;
            }
            else
            {
                _S1732 = false;
            }
            if(nee_0)
            {
                _S1733 = !_S1726;
            }
            else
            {
                _S1733 = false;
            }
            if(_S1733)
            {
                _S1734 = !wrong_side_0;
            }
            else
            {
                _S1734 = false;
            }
            if(_S1734)
            {
                float _S1823 = (&lobe_5)->pdf;
                float3  _S1824 = (&ray_2)->origin;
                float3  _S1825 = _slang_select(_S1589, _S1366,_S1553.smooth_n);
                float3  _S1826 = (&ray_2)->origin;
                FKSurface _S1827 = surface_13;
                float3  _S1828 = - _S1553.smooth_n;
                float3  _S1829 = _slang_select(_S1732, _S1828,_S1553.smooth_n);
                NEEVertex _S1830 = NEEVertex_x24init_0(false, _S1823, _S1824, _S1825, _S1826 + make_float3 (_S1827.geometry_offset) * _S1829);
                nee_vertex_0 = _S1830;
            }
            else
            {
                if(_S1584)
                {
                    _S1735 = true;
                }
                else
                {
                    bool _S1831 = b_12 != 1U;
                    if(_S1831)
                    {
                        _S1735 = true;
                    }
                    else
                    {
                        _S1735 = (_S1579.x) != (_S1579.y);
                    }
                }
                if(_S1735)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1832 = withinInverseFootprint((&lobe_5)->pdf, _S1725, (&prev_0)->cos, (&hit_4)->distance, threshold_2);
            bool _S1833 = roughLobe((&lobe_5)->pdf, _S1725, _S1816);
            if(_S1619)
            {
                bool _S1834 = !_S1832;
                if(_S1834)
                {
                    return _S1367;
                }
                bool _S1835 = _S1372 != 1U;
                if(_S1835)
                {
                    _S1735 = _S1372 != 2U;
                }
                else
                {
                    _S1735 = false;
                }
                if(_S1735)
                {
                    float _S1836 = (&lobe_5)->pdf;
                    float _S1837 = _slang_select(nee_0, _S1836,0.0f);
                    float _S1838 = escapeWeight_0(_S1837, _S1743);
                    if(_S1627)
                    {
                        passes_0 = _S1378;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1839 = _slang_select(passes_0, _S1838,1.0f);
                    return Shift_x24init_0(throughput_7 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_8->radiance * make_float3 (_S1839) / make_float3 (r_8->jac), density_4 * (&lobe_5)->pdf / r_8->jac);
                }
                float3  _S1840 = throughput_7 * make_float3 ((&lobe_5)->pdf);
                float _S1841 = density_4 * (&lobe_5)->pdf;
                throughput_10 = _S1840;
                density_6 = _S1841;
            }
            else
            {
                throughput_10 = throughput_7;
                density_6 = density_4;
            }
            uint _S1842 = (fcptLayers((hit_4)));
            bool _S1843 = b_12 == 1U;
            bool _S1844 = passesLayer_0(_S1842, _S1843, passes_0);
            if(viewed_1)
            {
                _S1735 = _S1844;
            }
            else
            {
                _S1735 = false;
            }
            if(_S1735)
            {
                return _S1367;
            }
            if(replay_2)
            {
                _S1736 = b_9 <= _S1382;
            }
            else
            {
                _S1736 = false;
            }
            if(_S1736)
            {
                _S1737 = _S1552;
            }
            else
            {
                _S1737 = false;
            }
            if(_S1737)
            {
                _S1738 = _S1832;
            }
            else
            {
                _S1738 = false;
            }
            if(_S1738)
            {
                _S1739 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1739 = !_S1833;
                }
                else
                {
                    _S1739 = false;
                }
            }
            if(_S1739)
            {
                return _S1367;
            }
            if(viewed_1)
            {
                float3  _S1845 = throughput_10 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1846 = (&lobe_5)->pdf;
                throughput_11 = _S1845;
                sky_pdf_2 = _S1846;
            }
            else
            {
                float3  _S1847 = throughput_10 * max_0((&lobe_5)->throughput, _S1366);
                throughput_11 = _S1847;
                sky_pdf_2 = density_6;
            }
            bool _S1848 = !replay_2;
            bool _S1849;
            if(_S1848)
            {
                _S1849 = !_S1607;
            }
            else
            {
                _S1849 = false;
            }
            bool _S1850;
            if(_S1849)
            {
                _S1850 = _S1552;
            }
            else
            {
                _S1850 = false;
            }
            bool _S1851;
            if(_S1850)
            {
                _S1851 = _S1832;
            }
            else
            {
                _S1851 = false;
            }
            if(_S1851)
            {
                chain_0 = here_0;
                uint _S1852 = insertBits_0((&chain_0)->path, b_12, 18U, 3U);
                uint _S1853 = _slang_select(nee_0, 1U,0U);
                uint _S1854 = insertBits_0(_S1852, _S1853, 21U, 1U);
                (&chain_0)->path = _S1854;
                float _S1855 = (&chain_0)->jac * (&lobe_5)->pdf;
                (&chain_0)->jac = _S1855;
                (&chain_0)->dir = throughput_9;
                chain_throughput_1 = throughput_11;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1856 = surface_13;
            Vertex _S1857 = Vertex_x24init_0(_S1833, b_12, (&lobe_5)->pdf, (F32_abs((dot_0(surface_13.geometry_n, throughput_9)))), is_inside_8);
            prev_0 = _S1857;
            float _S1858 = (&lobe_5)->pdf;
            bool _S1859;
            if(_S1843)
            {
                _S1859 = (_S1579.x) == (_S1579.y);
            }
            else
            {
                _S1859 = false;
            }
            float sky_pdf_3 = _slang_select(_S1859, sky_pdf_0,_S1858);
            float _S1860 = _slang_select(_S1584, 0.0f,sky_pdf_3);
            float _S1861 = widened_0(spread_2, (&lobe_5)->pdf, _S1726);
            bool _S1862;
            if(refracted_4)
            {
                _S1862 = !_S1732;
            }
            else
            {
                _S1862 = false;
            }
            bool is_inside_9;
            if(_S1862)
            {
                bool _S1863 = !is_inside_8;
                is_inside_9 = _S1863;
            }
            else
            {
                is_inside_9 = is_inside_8;
            }
            FKSurface _S1864 = surface_13;
            bool _S1865 = boundsVolume_0(&_S1864);
            bool _S1866;
            if(_S1865)
            {
                _S1866 = !_S1844;
            }
            else
            {
                _S1866 = false;
            }
            if(_S1866)
            {
                FKSurface faced_2 = surface_13;
                float3  _S1867 = - _S1856.geometry_n;
                float3  _S1868 = _slang_select(turned_1, _S1867,_S1856.geometry_n);
                (&faced_2)->geometry_n = _S1868;
                FKMedium _S1869 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1870 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1871 = faced_2;
                FKMedium _S1872 = _S1869;
                FKMedium _S1873 = _S1870;
                MediumSides _S1874 = mediumSides_0(&_S1871, &_S1872, filling_2, (&ray_2)->unit_direction, &_S1873);
                bool _S1875 = leavesInFront_0((&faced_2)->geometry_n, throughput_9, _S1856.geometry_n);
                float3  _S1876 = _slang_select(_S1875, _S1874.front.scatter,_S1874.behind.scatter);
                scatter_in_0 = _S1876;
                float3  _S1877 = scatter_in_0;
                float _S1878 = upsample(scatter_in_0, wavelength_6);
                float3  _S1879 = make_float3 (_S1878);
                float3  _S1880 = _slang_select(_S1576, _S1879,_S1877);
                scatter_in_0 = _S1880;
                float3  _S1881 = _slang_select(_S1875, _S1874.front.extinction,_S1874.behind.extinction);
                extinction_in_0 = _S1881;
                float3  _S1882 = extinction_in_0;
                float _S1883 = upsample(extinction_in_0, wavelength_6);
                float3  _S1884 = make_float3 (_S1883);
                float3  _S1885 = _slang_select(_S1576, _S1884,_S1882);
                extinction_in_0 = _S1885;
                float _S1886 = _slang_select(_S1875, _S1874.front.g,_S1874.behind.g);
                g_in_0 = _S1886;
                uint _S1887 = _S1874.fillings.x;
                uint _S1888 = _S1874.fillings.y;
                uint _S1889 = _slang_select(_S1875, _S1888,_S1887);
                bool _S1890 = (fcptVaryingUsed());
                uint _S1891 = _slang_select(_S1890, _S1889,4294967295U);
                filling_2 = _S1891;
            }
            (&ray_2)->unit_direction = throughput_9;
            bool _S1892 = !_S1844;
            if(_S1892)
            {
                FKSurface _S1893 = surface_13;
                float _S1894 = _slang_select(straight_0, 0.0f,_S1893.geometry_offset);
                float3  _S1895 = - _S1553.smooth_n;
                bool _S1896 = is_inside_9 != _S1732;
                float3  _S1897 = _slang_select(_S1896, _S1895,_S1553.smooth_n);
                float3  _S1898 = (&ray_2)->origin + make_float3 (_S1894) * _S1897;
                (&ray_2)->origin = _S1898;
            }
            throughput_10 = throughput_11;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1844;
            viewed_1 = _S1730;
            sky_pdf_2 = _S1860;
            spread_5 = _S1861;
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
        bool _S1899 = !replay_2;
        float density_7;
        if(_S1899)
        {
            if(_S1515)
            {
                float3  _S1900 = pathColor(throughput_10 * emission_1, spectral_weight_0, wavelength_6);
                Reservoir candidate_8 = chain_0;
                uint _S1901 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1902 = _S1901 == 1U;
                if(_S1902)
                {
                    float3  _S1903 = safeDivide(_S1900, chain_throughput_0);
                    (&candidate_8)->radiance = _S1903;
                }
                Reservoir _S1904 = withEnd(candidate_8, 2U, b_9, _S1900);
                offer(sel_7, _S1904, _S1900 * make_float3 (scale_3) / make_float3 (density_6));
            }
            if(_S1515)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1905 = survivalProbability(abs_0(throughput_10), density_6);
                density_7 = _S1905;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1906 = noiseAddress(_S1394, b_9);
            Random _S1907 = draw(_S1906, 8U);
            bool _S1908 = density_7 < (_S1907.value);
            if(_S1908)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1909 = (fcptMaxBounces());
                wrong_side_0 = b_9 >= _S1909;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1910 = density_6 * density_7;
            density_7 = _S1910;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1911 = layer_0 ^ 1U;
        uint _S1912 = _slang_select(passes_0, _S1911,0U);
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
            uint _S1913 = b_12 + 1U;
            b_9 = _S1913;
            layer_0 = _S1912;
            continue;
        }
        FKRay _S1914 = ray_2;
        float _S1915 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_2)
        {
            refracted_4 = _S1620;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S1371 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1916 = _slang_select(wrong_side_0, _S1915,4.294967296e+09f);
        bool _S1917 = !_S1584;
        if(straight_0)
        {
            _S1664 = true;
        }
        else
        {
            _S1664 = _S1584;
        }
        FKHit _S1918;
        if(_S1664)
        {
            _S1918 = hit_4;
        }
        else
        {
            _S1918 = _S1637;
        }
        FKHit _S1919 = (fcptTraverseInstanceBVH((_S1914), (_S1523), (_S1916), (_S1917), (_S1918), (viewed_1)));
        hit_4 = _S1919;
        if(replay_2)
        {
            _S1665 = _S1620;
        }
        else
        {
            _S1665 = false;
        }
        if(_S1665)
        {
            _S1725 = _S1371 == 1U;
        }
        else
        {
            _S1725 = false;
        }
        if(_S1725)
        {
            _S1726 = ((&hit_4)->instance_index) == (_S1383.instance_index);
        }
        else
        {
            _S1726 = false;
        }
        if(_S1726)
        {
            _S1727 = ((&hit_4)->triangle_index) == (_S1383.triangle_index);
        }
        else
        {
            _S1727 = false;
        }
        if(_S1727)
        {
            (&hit_4)->uv = _S1383.uv;
            float _S1920 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S1920;
        }
        if(replay_2)
        {
            _S1728 = _S1620;
        }
        else
        {
            _S1728 = false;
        }
        if(_S1728)
        {
            _S1729 = _S1371 == 3U;
        }
        else
        {
            _S1729 = false;
        }
        if(_S1729)
        {
            _S1730 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1730 = false;
        }
        if(_S1730)
        {
            return _S1367;
        }
        Reservoir _S1921 = chain_0;
        uint _S1922 = filling_2;
        for(;;)
        {
            bool _S1923 = (fcptVaryingUsed());
            if(_S1923)
            {
                _S1731 = _S1922 != 4294967295U;
            }
            else
            {
                _S1731 = false;
            }
            float _S1924;
            if(_S1731)
            {
                float _S1925 = (fcptMajorant((_S1922)));
                _S1924 = _S1925;
            }
            else
            {
                _S1924 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_2)
            {
                _S1732 = _S1620;
            }
            else
            {
                _S1732 = false;
            }
            if(_S1732)
            {
                _S1733 = _S1371 == 1U;
            }
            else
            {
                _S1733 = false;
            }
            if(_S1733)
            {
                _S1734 = _S1924 > 0.0f;
            }
            else
            {
                _S1734 = false;
            }
            if(_S1734)
            {
                ended_0 = _S1367;
                sky_pdf_1 = sky_pdf_2;
                spread_3 = spread_5;
                width_4 = width_3;
                density_3 = density_7;
                throughput_11 = throughput_10;
                b_12 = b_9;
                _S1735 = true;
                break;
            }
            bool _S1926 = (&prev_0)->rough;
            if(_S1926)
            {
                _S1735 = !(_S1924 > 0.0f);
            }
            else
            {
                _S1735 = false;
            }
            (&prev_0)->rough = _S1735;
            uint _S1927 = b_9 + 320U;
            bool _S1928 = b_9 == 4294967295U;
            uint _S1929 = _slang_select(_S1928, 384U,_S1927);
            uint _S1930 = stream(_S1394, _S1929);
            uint tracking_1 = _S1930;
            weight_2 = throughput_3;
            glowed_0 = _S1366;
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
                    _S1365 = int(2);
                    break;
                }
                uint _S1931 = noiseAddress(_S1394, b_12);
                Random _S1932 = draw(_S1931, 10U);
                float _S1933 = freeFlight_0(_S1932.value, _S1924);
                if(_S1731)
                {
                    float3  _S1934 = (&ray_2)->origin;
                    float3  _S1935 = (&ray_2)->unit_direction;
                    float _S1936 = (&hit_4)->distance;
                    bool _S1937 = b_12 == 4294967295U;
                    uint _S1938 = _slang_select(_S1937, 0U,b_12);
                    uint _S1939 = (&prev_0)->lobe;
                    uint _S1940 = _slang_select(_S1937, 3U,_S1939);
                    float _S1941 = (fcptTrackMedium((_S1922), (_S1934), (_S1935), (_S1936), (&tracking_1), (&weight_2), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1938), (_S1940), (_S1937)));
                    spread_4 = _S1941;
                }
                else
                {
                    spread_4 = _S1933;
                }
                bool _S1942 = !(spread_4 < ((&hit_4)->distance));
                if(_S1942)
                {
                    _S1365 = int(2);
                    break;
                }
                if(_S1731)
                {
                    _S1736 = _S1899;
                }
                else
                {
                    _S1736 = false;
                }
                if(_S1736)
                {
                    float3  _S1943 = pathColor(throughput_11 * glowed_0, spectral_weight_0, wavelength_6);
                    float3  _S1944 = _S1943 / make_float3 (density_3);
                    float3  _S1945 = sel_7->glow + _S1944;
                    sel_7->glow = _S1945;
                }
                else
                {
                }
                glowed_0 = _S1366;
                uint b_13 = b_12 + 1U;
                float3  _S1946 = (&ray_2)->origin + make_float3 (spread_4) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1946;
                float3  _S1947 = flightWeight_0(scatter_in_0, extinction_in_0, _S1924, spread_4, true);
                float3  _S1948 = weight_2;
                float _S1949 = upsample(weight_2, wavelength_6);
                float3  _S1950 = make_float3 (_S1949);
                float3  _S1951 = _slang_select(_S1576, _S1950,_S1948);
                float3  _S1952 = _slang_select(_S1731, _S1951,_S1947);
                float3  throughput_12 = throughput_11 * _S1952;
                uint _S1953 = stream(_S1394, b_13 + 320U);
                tracking_1 = _S1953;
                weight_2 = throughput_3;
                float width_7 = width_4 + spread_3 * spread_4;
                float _S1954 = spread_3 + 3.14159274101257324f;
                bool _S1955 = scatterSampled_0(replay_2, b_13, _S1382, _S1731);
                TreeSample light_4;
                if(_S1955)
                {
                    float3  _S1956 = (&ray_2)->origin;
                    float3  _S1957 = (&ray_2)->unit_direction;
                    float3  _S1958 = (&ray_2)->unit_direction;
                    uint _S1959 = noiseAddress(_S1394, b_13);
                    float3  _S1960 = extinction_in_0;
                    float3  _S1961 = extinction_in_0;
                    uint2  _S1962 = make_uint2 (_S1922);
                    float3  _S1963 = (&ray_2)->unit_direction;
                    uint _S1964 = arrivalLobe_0(b_13, (&prev_0)->lobe);
                    FKHit _S1965 = _S1637;
                    ShadowContext _S1966 = ShadowContext_x24init_0(_S1960, _S1961, _S1962, _S1963, b_13, _S1964, false, spread_4, width_7, &_S1965, false);
                    ShadowContext _S1967 = _S1966;
                    TreeSample _S1968 = sampleLightTree_0(_S1956, _S1957, _S1958, 0.0f, true, _S1959, &_S1967);
                    light_4 = _S1968;
                }
                else
                {
                    light_4 = _S1634;
                }
                float _S1969 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1970 = (fcptMaxBounces());
                bool _S1971 = b_13 < _S1970;
                if(_S1971)
                {
                    _S1737 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1737 = false;
                }
                float _S1972 = _slang_select(_S1737, _S1969,0.0f);
                float3  _S1973 = throughput_12 * light_4.radiance;
                float _S1974 = powerHeuristic(light_4.density, _S1972);
                float3  _S1975 = pathColor(_S1973 * make_float3 (_S1969 * _S1974), spectral_weight_0, wavelength_6);
                float3  _S1976 = _slang_select(_S1955, _S1975,_S1366);
                if(replay_2)
                {
                    _S1738 = b_13 == _S1382;
                }
                else
                {
                    _S1738 = false;
                }
                if(_S1738)
                {
                    bool _S1977 = _S1371 == 2U;
                    if(_S1977)
                    {
                        float _S1978 = resamplingTarget(_S1976);
                        _S1739 = _S1978 > 0.0f;
                    }
                    else
                    {
                        _S1739 = false;
                    }
                    if(_S1739)
                    {
                        Shift _S1979 = Shift_x24init_0(_S1976, 1.0f);
                        _S1365 = int(1);
                        ended_0 = _S1979;
                        spread_4 = _S1954;
                        width_5 = width_7;
                        throughput_9 = throughput_12;
                        b_10 = b_13;
                        break;
                    }
                    _S1365 = int(1);
                    ended_0 = _S1367;
                    spread_4 = _S1954;
                    width_5 = width_7;
                    throughput_9 = throughput_12;
                    b_10 = b_13;
                    break;
                }
                if(_S1899)
                {
                    Reservoir candidate_9 = _S1921;
                    uint _S1980 = extractBits_0(_S1921.path, 24U, 8U);
                    uint _S1981 = insertBits_0(0U, _S1980, 24U, 8U);
                    uint _S1982 = extractBits_0(_S1921.path, 10U, 2U);
                    bool _S1983 = _S1982 == 1U;
                    if(_S1983)
                    {
                        float3  _S1984 = safeDivide(_S1976, chain_throughput_0);
                        (&candidate_9)->radiance = _S1984;
                    }
                    else
                    {
                        uint _S1985 = insertBits_0(_S1981, b_13 + 1U, 5U, 5U);
                        uint _S1986 = insertBits_0(_S1985, 2U, 10U, 2U);
                        (&candidate_9)->path = _S1986;
                    }
                    Reservoir _S1987 = withEnd(candidate_9, 0U, b_13, _S1976);
                    offer(sel_7, _S1987, _S1976 * make_float3 (scale_3) / make_float3 (density_3));
                    float _S1988 = survivalProbability(abs_0(throughput_12), density_3);
                    uint _S1989 = noiseAddress(_S1394, b_13);
                    Random _S1990 = draw(_S1989, 8U);
                    bool _S1991 = _S1988 < (_S1990.value);
                    if(_S1991)
                    {
                        _S1739 = true;
                    }
                    else
                    {
                        uint _S1992 = (fcptMaxBounces());
                        _S1739 = b_13 >= _S1992;
                    }
                    if(_S1739)
                    {
                        _S1365 = int(1);
                        ended_0 = _S1367;
                        spread_4 = _S1954;
                        width_5 = width_7;
                        throughput_9 = throughput_12;
                        b_10 = b_13;
                        break;
                    }
                    float _S1993 = density_3 * _S1988;
                    density_3 = _S1993;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1994 = noiseAddress(_S1394, b_13);
                float3  _S1995 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1994, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1995;
                NEEVertex _S1996 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1366, (&ray_2)->origin);
                nee_vertex_0 = _S1996;
                Vertex _S1997 = scatteredVertex_0(is_inside_7);
                prev_0 = _S1997;
                float _S1998 = (&prev_0)->pdf;
                FKRay _S1999 = ray_2;
                FKHit _S2000 = (fcptTraverseInstanceBVH((_S1999), (true), (4.294967296e+09f), (false), (_S1637), (false)));
                hit_4 = _S2000;
                b_12 = b_13;
                throughput_11 = throughput_12;
                spread_3 = _S1954;
                width_4 = width_7;
                sky_pdf_1 = _S1998;
            }
            if(_S1365 != int(2))
            {
                spread_3 = spread_4;
                width_4 = width_5;
                throughput_11 = throughput_9;
                b_12 = b_10;
                _S1735 = true;
                break;
            }
            ended_0 = _S1367;
            _S1735 = false;
            break;
        }
        if(_S1735)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1736 = b_12 == b_9;
        }
        else
        {
            _S1736 = false;
        }
        bool _S2001 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S2001)
        {
            bool _S2002 = !(&nee_vertex_0)->none;
            float _S2003 = _slang_select(_S2002, sky_pdf_1,0.0f);
            float _S2004 = escapeWeight_0(_S2003, (&ray_2)->unit_direction);
            float3  _S2005 = environment_0((&ray_2)->unit_direction, b_12, (&prev_0)->lobe);
            float3  _S2006 = pathColor(throughput_11 * _S2005, spectral_weight_0, wavelength_6);
            if(replay_2)
            {
                bool _S2007 = b_12 == _S1382;
                if(_S2007)
                {
                    passes_0 = _S1371 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S2006 * make_float3 (_S2004) / make_float3 (r_8->jac), density_3 / r_8->jac);
                }
                if(_S1381)
                {
                    passes_0 = _S1378;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_12 == _S1369;
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
                    return Shift_x24init_0(_S2006 * make_float3 (_S2004), 1.0f);
                }
                return _S1367;
            }
            Reservoir candidate_10 = chain_0;
            uint _S2008 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S2009 = _S2008 == 1U;
            if(_S2009)
            {
                uint _S2010 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S2011 = _S2010 == b_12;
                float _S2012 = _slang_select(_S2011, 1.0f,_S2004);
                float3  _S2013 = safeDivide(_S2006 * make_float3 (_S2012), chain_throughput_0);
                (&candidate_10)->radiance = _S2013;
            }
            else
            {
                bool _S2014 = (&prev_0)->rough;
                if(_S2014)
                {
                    uint _S2015 = insertBits_0(_S1396, b_12 + 1U, 5U, 5U);
                    uint _S2016 = insertBits_0(_S2015, 3U, 10U, 2U);
                    uint _S2017 = insertBits_0(_S2016, (&prev_0)->lobe, 15U, 3U);
                    bool _S2018 = (&prev_0)->inside;
                    uint _S2019 = _slang_select(_S2018, 1U,0U);
                    uint _S2020 = insertBits_0(_S2017, _S2019, 22U, 1U);
                    (&candidate_10)->path = _S2020;
                    (&candidate_10)->jac = (&prev_0)->pdf;
                    (&candidate_10)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S2021 = _S2006 * make_float3 (_S2004);
            Reservoir _S2022 = withEnd(candidate_10, 3U, b_12, _S2021);
            offer(sel_7, _S2022, _S2021 * make_float3 (scale_3) / make_float3 (density_3));
            break;
        }
        float3  _S2023 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S2023;
        bool _S2024 = (fcptVaryingUsed());
        if(_S2024)
        {
            _S1737 = filling_2 != 4294967295U;
        }
        else
        {
            _S1737 = false;
        }
        if(_S1737)
        {
            if(_S1899)
            {
                float3  _S2025 = pathColor(throughput_11 * glowed_0, spectral_weight_0, wavelength_6);
                float3  _S2026 = _S2025 / make_float3 (density_3);
                float3  _S2027 = sel_7->glow + _S2026;
                sel_7->glow = _S2027;
            }
            float3  _S2028 = throughput_11 * weight_2;
            throughput_9 = _S2028;
        }
        else
        {
            float3  _S2029 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S2030 = throughput_11 * _S2029;
            throughput_9 = _S2030;
        }
        float _S2031 = width_4 + spread_3 * (&hit_4)->distance;
        viewed_0 = _S1736;
        width_3 = _S2031;
        throughput_2 = throughput_9;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_2 = spread_3;
        uint _S1913 = b_12 + 1U;
        b_9 = _S1913;
        layer_0 = _S1912;
    }
    return _S1367;
}

static __device__ Shift shift_0(Domain * dom_8, Reservoir * r_9)
{
    Selection _S2032 = (Selection{});
    Selection sel_8 = _S2032;
    bool _S2033 = (r_9->w) <= 0.0f;
    if(_S2033)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S2034 = walk_0(dom_8, r_9, true, 0.0f, &sel_8);
    return _S2034;
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

__device__ Random normal_distribution(uint state_5)
{
    Random _S2035 = pcg(state_5);
    Random _S2036 = pcg(_S2035.state);
    float _S2037 = 6.28318548202514648f * _S2035.value;
    float _S2038 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S2036.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S2036.state, _S2038 * (F32_cos((_S2037))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_6, float3  value_2)
{
    RandomSphere _S2039;
    (&_S2039)->state = state_6;
    (&_S2039)->value = value_2;
    return _S2039;
}

__device__ RandomSphere random_sphere(uint state_7)
{
    Random _S2040 = normal_distribution(state_7);
    Random _S2041 = normal_distribution(_S2040.state);
    Random _S2042 = normal_distribution(_S2041.state);
    float3  _S2043 = make_float3 (_S2040.value, _S2041.value, _S2042.value);
    float3  _S2044 = ((((_S2043)) * make_float3(rnorm3df(((_S2043)).x, ((_S2043)).y, ((_S2043)).z))));
    return RandomSphere_x24init_0(_S2042.state, _S2044);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_12)
{
    float3  _S2045 = p1_0 - p0_0;
    float3  _S2046 = p2_0 - p0_0;
    float2  _S2047 = uv1_0 - uv0_0;
    float2  _S2048 = uv2_0 - uv0_0;
    float _S2049 = _S2047.x;
    float _S2050 = _S2048.y;
    float _S2051 = _S2047.y;
    float _S2052 = _S2048.x;
    float _S2053 = _S2049 * _S2050 - _S2051 * _S2052;
    float _S2054 = 1.0f / _S2053;
    float3  t_22 = (_S2045 * make_float3 (_S2050) - _S2046 * make_float3 (_S2051)) * make_float3 (_S2054);
    float3  _S2055 = (_S2046 * make_float3 (_S2049) - _S2045 * make_float3 (_S2052)) * make_float3 (_S2054);
    float3  _S2056 = t_22 - n_12 * make_float3 (dot_0(n_12, t_22));
    float3  t_23 = ((((_S2056)) * make_float3(rnorm3df(((_S2056)).x, ((_S2056)).y, ((_S2056)).z))));
    bool _S2057 = (dot_0(cross_0(n_12, t_23), _S2055)) > 0.0f;
    float3  t_24;
    if(_S2057)
    {
        float3  _S2058 = negate_0(t_23);
        t_24 = _S2058;
    }
    else
    {
        t_24 = t_23;
    }
    float3  _S2059 = cross_0(n_12, t_24);
    return makeMatrix<float, 3, 3> (t_24, _S2059, n_12);
}

__device__ float3  tangentToWorldNormalMap(float3  v_10, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_10, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_5, float3  uvw_0, float3  position_0)
{
    float3  _S2060 = t1_0 - t0_0;
    float3  _S2061 = t2_2 - t0_0;
    float3  _S2062 = t2_2 - t1_0;
    float _S2063 = (F32_min((length_0(_S2060)), ((F32_min((length_0(_S2061)), (length_0(_S2062)))))));
    float3  _S2064 = make_float3 (distance_1(position_0, t0_0), distance_1(position_0, t1_0), distance_1(position_0, t2_2));
    float3  _S2065 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S2066 = dot_0(geometry_n_5, _S2065);
    float3  _S2067 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S2068 = dot_0(geometry_n_5, _S2067);
    float3  _S2069 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S2070 = acos_0(abs_0(make_float3 (_S2066, _S2068, dot_0(geometry_n_5, _S2069))));
    float3  _S2071 = clamp_2(tan_0(_S2070), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S2064 * _S2071, uvw_0), 0.0f, _S2063 * 0.125f);
}

__device__ float3  straightThrough(float3  dir_16, float3  n_13, BSDFMaterial material_24)
{
    float3  _S2072 = negate_0(dir_16);
    float _S2073 = sign_0(dot_0(n_13, _S2072));
    float3  _S2074 = n_13 * make_float3 (_S2073);
    AnisotropicFrame _S2075 = anisotropicFrame(material_24, _S2074);
    bool _S2076 = (_S2075.alphas.x) > 0.0f;
    if(_S2076)
    {
        float _S2077 = material_24.transmission * (1.0f - material_24.metallic);
        float3  _S2078 = negate_0(_S2074);
        float3  _S2079 = anisotropicLocal(dir_16, _S2075.tangent, _S2078);
        float _S2080 = anisotropicG1(_S2079, _S2075.alphas);
        return make_float3 (_S2077 * _S2080) * material_24.albedo;
    }
    float _S2081 = material_24.transmission * (1.0f - material_24.metallic);
    float _S2082 = material_24.roughness;
    float _S2083 = smithG1(_S2082 * _S2082, (F32_abs((dot_0(n_13, dir_16)))));
    return make_float3 (_S2081 * _S2083) * material_24.albedo;
}

__device__ float hairRow(float3  in_dir_12, float3  t_25, float3  out_dir_3, uint p_15, float w_22, float alpha_10, uint nt_0)
{
    uint _S2084 = p_15 % 4U;
    float _S2085 = w_22 * HAIR_WIDTHS_0[_S2084];
    float _S2086 = (F32_asin((clamp_1(dot_0(out_dir_3, t_25), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_12, t_25), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S2084] * alpha_10;
    return ((F32_asinh((_S2086 / _S2085))) / (F32_asinh((3.14159274101257324f / _S2085))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_13, float3  t_26, float3  out_dir_4, uint np_0)
{
    float3  _S2087 = worldToTangent(out_dir_4, t_26);
    float3  _S2088 = worldToTangent(in_dir_13, t_26);
    return (F32_frac((((F32_atan2((_S2087.z), (_S2087.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S2088.z), (1.17549435082228751e-38f - _S2088.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_14, float3  t_27, uint p_16, float row_0, float column_0, float w_23, float alpha_11, uint nt_1, uint np_1)
{
    float3  _S2089 = worldToTangent(in_dir_14, t_27);
    uint _S2090 = p_16 % 4U;
    float _S2091 = w_23 * HAIR_WIDTHS_0[_S2090];
    float _S2092 = (F32_asin((clamp_1(dot_0(in_dir_14, t_27), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S2090] * alpha_11 + _S2091 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S2091))))));
    float _S2093 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S2089.z), (1.17549435082228751e-38f - _S2089.x)));
    float _S2094 = (F32_cos((_S2092)));
    float3  _S2095 = tangentToWorld(make_float3 (_S2094 * (F32_cos((_S2093))), (F32_sin((_S2092))), _S2094 * (F32_sin((_S2093)))), t_27);
    return _S2095;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_14, BSDFMaterial material_25, float coverage_1)
{
    float3  through_2;
    if((material_25.ior) == 1.0f)
    {
        float3  _S2096 = straightThrough(toward_1, n_14, material_25);
        through_2 = _S2096;
    }
    else
    {
        through_2 = make_float3 (0.0f);
    }
    bool _S2097 = (material_25.coat) > 0.0f;
    if(_S2097)
    {
        float3  _S2098 = coatNormal(material_25, n_14);
        float _S2099 = fresnel((F32_abs((dot_0(_S2098, toward_1)))), 1.0f, (F32_max((material_25.coat_ior), (1.00999999046325684f))));
        float3  _S2100 = mix_0(make_float3 (1.0f), make_float3 (1.0f - _S2099) * material_25.coat_tint, material_25.coat);
        float3  through_3 = through_2 * _S2100;
        through_2 = through_3;
    }
    return through_2 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_9, Reservoir r_10, bool replay_3, float scale_4, Selection * sel_9)
{
    Domain _S2101 = dom_9;
    Reservoir _S2102 = r_10;
    Shift _S2103 = walk_0(&_S2101, &_S2102, replay_3, scale_4, sel_9);
    return _S2103;
}

__device__ Shift shift_hook(Domain dom_10, Reservoir r_11)
{
    Domain _S2104 = dom_10;
    Reservoir _S2105 = r_11;
    Shift _S2106 = shift_0(&_S2104, &_S2105);
    return _S2106;
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

__device__ uint noiseWhite(uint x_29, uint y_8, uint t_28, uint size_0)
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
        uint _S2107;
        if(i_31 < 2U)
        {
            _S2107 = x_29;
        }
        else
        {
            _S2107 = (x_29 + size_0 / 2U) & (size_0 - 1U);
        }
        uint l_5 = _S2107;
        uint r_12 = y_8;
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
            uint _S2108 = hash(((r_12 ^ (t_28 << 16U)) ^ (k_4 << 28U)) ^ ((i_31 & 1U) << 31U));
            uint _S2109 = l_5 ^ (_S2108 & (size_0 - 1U));
            uint k_5 = k_4 + 1U;
            l_5 = r_12;
            r_12 = _S2109;
            k_4 = k_5;
        }
        uint _S2110 = l_5 + r_12 * size_0;
        uint _S2111 = size_0 * size_0;
        uint _S2112;
        if(_S2111 >= 65536U)
        {
            uint _S2113 = _S2110 / (_S2111 / 65536U);
            _S2112 = _S2113;
        }
        else
        {
            uint _S2114 = 65536U / _S2111;
            _S2112 = _S2110 * _S2114;
        }
        ranks_0[i_31] = _S2112;
        uint i_32 = i_31 + 1U;
        i_31 = i_32;
    }
    bool _S2115 = (ranks_0[int(0)]) == 65535U;
    bool _S2116;
    if(_S2115)
    {
        _S2116 = (ranks_0[int(1)]) == 65535U;
    }
    else
    {
        _S2116 = false;
    }
    bool _S2117 = (ranks_0[int(2)]) == 65535U;
    bool _S2118;
    if(_S2117)
    {
        _S2118 = (ranks_0[int(3)]) == 65535U;
    }
    else
    {
        _S2118 = false;
    }
    if(_S2116)
    {
        _S2116 = (ranks_0[int(3)]) != 65535U;
    }
    else
    {
        _S2116 = false;
    }
    if(_S2116)
    {
        _S2116 = true;
    }
    else
    {
        if(_S2118)
        {
            _S2116 = (ranks_0[int(1)]) != 65535U;
        }
        else
        {
            _S2116 = false;
        }
    }
    uint _S2119 = ranks_0[int(0)];
    if(_S2116)
    {
        i_31 = ranks_0[int(3)];
    }
    else
    {
        i_31 = ranks_0[int(1)];
    }
    return _S2119 | (i_31 << 16U);
}

__device__ uint3  noiseBlock(uint sweep_0, uint colour_0, uint block_0, uint size_1)
{
    uint _S2120 = hash(sweep_0 * 7919U + 1U);
    uint _S2121 = size_1 / 16U;
    uint _S2122 = block_0 % _S2121;
    uint _S2123 = block_0 / _S2121;
    uint _S2124 = _S2123 % _S2121;
    uint _S2125 = block_0 / (_S2121 * _S2121);
    uint3  _S2126 = make_uint3 (_S2122, _S2124, _S2125);
    uint3  _S2127 = make_uint3 (colour_0 & 1U, (colour_0 >> 1U) & 1U, colour_0 >> 2U);
    return _S2126 * make_uint3 (16U) + _S2127 * make_uint3 (8U) + make_uint3 (_S2120 & 7U, (_S2120 >> 3U) & 7U, (_S2120 >> 6U) & 7U);
}

#undef Matrix
