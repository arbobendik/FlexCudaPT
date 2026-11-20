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

static __device__ HalfTerms HalfTerms_x24init_0(float v_dot_h_0, float n_dot_h_0, float3  refracted_1, float3  F_0, float F_greyscale_0, float reflect_weight_0, float3  diffuse_weight_0, float3  refract_weight_0, float p_diffuse_0, float p_reflect_0, float p_refract_0, float translucent_share_1, float3  sheen_1, float p_sheen_velvet_0, float3  view_1, float3  tangent_1, float2  alphas_1, float visible_0, float p_toon_0, float3  toon_1, float toon_a_1, float toon_s_1, float toon_b_1, bool toon_glossy_1, float toon_norm_1, float toon_view_1, float3  toon_axis_1)
{
    HalfTerms _S338;
    (&_S338)->v_dot_h = v_dot_h_0;
    (&_S338)->n_dot_h = n_dot_h_0;
    (&_S338)->refracted = refracted_1;
    (&_S338)->F = F_0;
    (&_S338)->F_greyscale = F_greyscale_0;
    (&_S338)->reflect_weight = reflect_weight_0;
    (&_S338)->diffuse_weight = diffuse_weight_0;
    (&_S338)->refract_weight = refract_weight_0;
    (&_S338)->p_diffuse = p_diffuse_0;
    (&_S338)->p_reflect = p_reflect_0;
    (&_S338)->p_refract = p_refract_0;
    (&_S338)->translucent_share = translucent_share_1;
    (&_S338)->sheen = sheen_1;
    (&_S338)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S338)->view = view_1;
    (&_S338)->tangent = tangent_1;
    (&_S338)->alphas = alphas_1;
    (&_S338)->visible = visible_0;
    (&_S338)->p_toon = p_toon_0;
    (&_S338)->toon = toon_1;
    (&_S338)->toon_a = toon_a_1;
    (&_S338)->toon_s = toon_s_1;
    (&_S338)->toon_b = toon_b_1;
    (&_S338)->toon_glossy = toon_glossy_1;
    (&_S338)->toon_norm = toon_norm_1;
    (&_S338)->toon_view = toon_view_1;
    (&_S338)->toon_axis = toon_axis_1;
    return _S338;
}

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
    float3  _S339 = make_float3 (alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z);
    float3  _S340 = ((((_S339)) * make_float3(rnorm3df(((_S339)).x, ((_S339)).y, ((_S339)).z))));
    float _S341 = _S340.x;
    float _S342 = _S340.y;
    float _S343 = _S341 * _S341 + _S342 * _S342;
    float3  _S344;
    if(_S343 > 0.0f)
    {
        float3  _S345 = make_float3 (- _S342, _S341, 0.0f);
        float _S346 = (rsqrtf((_S343)));
        _S344 = _S345 * make_float3 (_S346);
    }
    else
    {
        _S344 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S347 = cross_0(_S340, _S344);
    float _S348 = (F32_sqrt((U1_0)));
    float _S349 = 6.28318548202514648f * U2_0;
    float _S350 = _S348 * (F32_cos((_S349)));
    float t2_0 = _S348 * (F32_sin((_S349)));
    float _S351 = 0.5f * (1.0f + _S340.z);
    float t2_1 = (1.0f - _S351) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S350 * _S350)))))) + _S351 * t2_0;
    float3  _S352 = make_float3 (_S350) * _S344 + make_float3 (t2_1) * _S347;
    float _S353 = unshared_0(_S350);
    float _S354 = unshared_0(_S350);
    float3  _S355 = _S352 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S353 * _S354 - t2_1 * t2_1))))))) * _S340;
    float3  _S356 = make_float3 (alpha_0 * _S355.x, alpha_0 * _S355.y, (F32_max((0.0f), (_S355.z))));
    float3  _S357 = ((((_S356)) * make_float3(rnorm3df(((_S356)).x, ((_S356)).y, ((_S356)).z))));
    return _S357;
}

__device__ float3  worldToTangent(float3  v_2, float3  n_3)
{
    float3  a_3 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S358 = (F32_abs((dot_0(n_3, a_3)))) > 0.9999847412109375f;
    float3  a_4;
    if(_S358)
    {
        float3  _S359 = make_float3 (1.0f, 0.0f, 0.0f);
        a_4 = _S359;
    }
    else
    {
        a_4 = a_3;
    }
    float3  _S360 = cross_0(n_3, a_4);
    float3  _S361 = ((((_S360)) * make_float3(rnorm3df(((_S360)).x, ((_S360)).y, ((_S360)).z))));
    float3  _S362 = cross_0(n_3, _S361);
    return make_float3 (dot_0(v_2, _S361), dot_0(v_2, n_3), dot_0(v_2, _S362));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_3, float3  n_i_2, float alpha_1, AnisotropicFrame frame_1, uint * random_state_2)
{
    Random _S363 = pcg(*random_state_2);
    Random _S364 = pcg(_S363.state);
    *random_state_2 = _S364.state;
    float _S365 = frame_1.alphas.x;
    bool _S366 = _S365 > 0.0f;
    if(_S366)
    {
        float3  _S367 = anisotropicLocal(v_3, frame_1.tangent, n_i_2);
        float _S368 = frame_1.alphas.y;
        float3  _S369 = make_float3 (_S365 * _S367.x, _S368 * _S367.y, _S367.z);
        float3  _S370 = ((((_S369)) * make_float3(rnorm3df(((_S369)).x, ((_S369)).y, ((_S369)).z))));
        float3  _S371 = sampleGGXVNDF(_S370, 1.0f, _S363.value, _S364.value);
        float3  _S372 = make_float3 (_S365 * _S371.x, _S368 * _S371.y, _S371.z);
        float3  _S373 = ((((_S372)) * make_float3(rnorm3df(((_S372)).x, ((_S372)).y, ((_S372)).z))));
        return make_float3 (_S373.x) * frame_1.tangent + make_float3 (_S373.y) * cross_0(n_i_2, frame_1.tangent) + make_float3 (_S373.z) * n_i_2;
    }
    float3  _S374 = worldToTangent(v_3, n_i_2);
    float3  _S375 = sampleGGXVNDF(float3 {_S374.x, _S374.z, _S374.y}, alpha_1, _S363.value, _S364.value);
    float3  _S376 = float3 {_S375.x, _S375.z, _S375.y};
    float3  _S377 = tangentToWorld(_S376, n_i_2);
    return _S377;
}

__device__ float3  sampledHalf(float3  in_dir_0, float3  n_4, BSDFMaterial material_2, uint random_state_3, ViewTerms view_terms_0)
{
    uint state_3 = random_state_3;
    float3  _S378 = negate_0(in_dir_0);
    float _S379 = sign_0(dot_0(n_4, _S378));
    float _S380 = material_2.roughness;
    float3  _S381 = sampleHalfVector(_S378, n_4 * make_float3 (_S379), _S380 * _S380, view_terms_0.frame, &state_3);
    return _S381;
}

__device__ float3  refractedHalf(float3  in_dir_1, float3  out_dir_0, float3  n_5, float eta_i_0, float eta_o_0)
{
    float3  _S382 = negate_0(in_dir_1);
    float3  _S383 = negate_0(make_float3 (eta_i_0) * _S382 + make_float3 (eta_o_0) * out_dir_0);
    float3  _S384 = ((((_S383)) * make_float3(rnorm3df(((_S383)).x, ((_S383)).y, ((_S383)).z))));
    float _S385 = sign_0(dot_0(n_5, _S382));
    float _S386 = sign_0(dot_0(_S383, n_5 * make_float3 (_S385)));
    return _S384 * make_float3 (_S386);
}

__device__ float3  reflectedHalf(float3  in_dir_2, float3  out_dir_1)
{
    float3  _S387 = negate_0(in_dir_2);
    float3  _S388 = _S387 + out_dir_1;
    float3  _S389 = ((((_S388)) * make_float3(rnorm3df(((_S388)).x, ((_S388)).y, ((_S388)).z))));
    return _S389;
}

static __device__ float3  refract_0(float3  i_6, float3  n_6, float eta_0)
{
    float _S390 = dot_0(n_6, i_6);
    float _S391 = 1.0f - eta_0 * eta_0 * (1.0f - _S390 * _S390);
    if(_S391 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_6 - make_float3 (eta_0 * _S390 + (F32_sqrt((_S391)))) * n_6;
}

__device__ float fresnel(float cos_theta_0, float eta_i_1, float eta_o_1)
{
    float _S392 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S393 = eta_i_1 / eta_o_1 * _S392;
    bool _S394 = _S393 < 1.0f;
    float kr_0;
    if(_S394)
    {
        float _S395 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S393 * _S393))))));
        float _S396 = eta_o_1 * cos_theta_0;
        float _S397 = eta_i_1 * _S395;
        float _S398 = (_S396 - _S397) / (_S396 + _S397);
        float _S399 = eta_i_1 * cos_theta_0;
        float _S400 = eta_o_1 * _S395;
        float _S401 = (_S399 - _S400) / (_S399 + _S400);
        float _S402 = (_S398 * _S398 + _S401 * _S401) / 2.0f;
        kr_0 = _S402;
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

__device__ float anisotropicG1(float3  w_1, float2  alphas_2)
{
    float _S403 = (F32_max((w_1.z), (0.0f)));
    return 2.0f * _S403 / (_S403 + length_0(make_float3 (alphas_2.x * w_1.x, alphas_2.y * w_1.y, _S403)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_3)
{
    float _S404 = alphas_3.x;
    float _S405 = h_0.x / _S404;
    float _S406 = alphas_3.y;
    float _S407 = h_0.y / _S406;
    float _S408 = h_0.z;
    float _S409 = _S405 * _S405 + _S407 * _S407 + _S408 * _S408;
    return 1.0f / (F32_max((3.14159274101257324f * _S404 * _S406 * _S409 * _S409), (1.17549435082228751e-38f)));
}

__device__ HalfTerms precomputeHalf(float3  in_dir_3, float3  ggx_n_0, BSDFMaterial material_3, float eta_i_2, float eta_o_2, MaterialTerms terms_0, ViewTerms view_terms_1)
{
    float _S410 = dot_0(ggx_n_0, view_terms_1.v);
    float _S411 = dot_0(view_terms_1.n_i, ggx_n_0);
    float _S412 = eta_i_2 / eta_o_2;
    float3  _S413 = refract_0(in_dir_3, ggx_n_0, _S412);
    float3  _S414 = ((((_S413)) * make_float3(rnorm3df(((_S413)).x, ((_S413)).y, ((_S413)).z))));
    float _S415 = (F32_abs((_S410)));
    bool _S416 = eta_i_2 > eta_o_2;
    float visible_1;
    if(_S416)
    {
        visible_1 = terms_0.eta_level;
    }
    else
    {
        visible_1 = 1.0f;
    }
    float _S417;
    if(_S416)
    {
        _S417 = 1.0f;
    }
    else
    {
        _S417 = terms_0.eta_level;
    }
    float _S418 = fresnel(_S415, visible_1, _S417);
    bool _S419 = (eta_i_2 * eta_i_2 * (1.0f - _S410 * _S410)) >= (eta_o_2 * eta_o_2);
    float3  _S420;
    if(_S419)
    {
        _S420 = make_float3 (1.0f);
    }
    else
    {
        float3  _S421 = material_3.specular_tint * make_float3 (terms_0.f0);
        _S420 = _S421 + (make_float3 (1.0f) - _S421) * make_float3 (_S418 - terms_0.f0) / make_float3 (1.0f - terms_0.f0);
    }
    float3  _S422 = mix_0(_S420, material_3.albedo * view_terms_1.rebounce, material_3.metallic);
    float3  F_1 = _S422 * view_terms_1.scale;
    float _S423 = rgb_to_greyscale(F_1);
    float _S424 = 1.0f - material_3.metallic;
    float3  _S425 = make_float3 (1.0f) - _S420;
    float3  _S426 = make_float3 ((1.0f - material_3.transmission) * _S424) * _S425 * view_terms_1.scale;
    float3  _S427 = make_float3 (material_3.transmission * _S424) * _S425 * view_terms_1.scale;
    float _S428 = (F32_max((_S423), (0.0f)));
    float _S429 = rgb_to_greyscale(_S426);
    float _S430 = (F32_max((_S429), (0.0f)));
    float _S431 = rgb_to_greyscale(_S427);
    float _S432 = sign_0(length_0(_S414));
    float _S433 = (F32_max((_S431 * _S432), (0.0f)));
    float _S434 = _S428 + _S430 + _S433 + terms_0.toon_component;
    float _S435 = (F32_min((view_terms_1.sheen_component), (1.0f)));
    bool _S436 = (view_terms_1.sheen_component) > 0.0f;
    bool _S437;
    if(_S436)
    {
        _S437 = !(_S434 > 0.0f);
    }
    else
    {
        _S437 = false;
    }
    float _S438 = _slang_select(_S437, 1.0f,_S435);
    float _S439 = (1.0f - _S438) / (F32_max((_S434), (0.0000152587890625f)));
    float _S440 = _S430 * _S439;
    float _S441 = _S428 * _S439;
    float _S442 = _S433 * _S439;
    bool _S443 = (view_terms_1.frame.alphas.x) > 0.0f;
    if(_S443)
    {
        float3  _S444 = anisotropicLocal(view_terms_1.v, view_terms_1.frame.tangent, view_terms_1.n_i);
        float _S445 = anisotropicG1(_S444, view_terms_1.frame.alphas);
        float3  _S446 = anisotropicLocal(ggx_n_0, view_terms_1.frame.tangent, view_terms_1.n_i);
        float _S447 = anisotropicD(_S446, view_terms_1.frame.alphas);
        float _S448 = _S445 * _S447;
        visible_1 = _S448;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return HalfTerms_x24init_0(_S410, _S411, _S414, F_1, _S423, 1.0f, _S426, _S427, _S440, _S441, _S442, terms_0.translucent_share, view_terms_1.sheen, _S438, view_terms_1.view, view_terms_1.frame.tangent, view_terms_1.frame.alphas, visible_1, terms_0.toon_component * _S439, terms_0.toon, terms_0.toon_a, terms_0.toon_s, terms_0.toon_b, terms_0.toon_glossy, terms_0.toon_norm, view_terms_1.toon_view, view_terms_1.toon_axis);
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_2, HalfTerms lobes_0, float eta_i_3, float eta_o_3)
{
    float _S449 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S450 = lobes_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S451 = 1.0f - lobes_0.translucent_share;
    bool _S452 = n_i_dot_l_0 < 0.0f;
    float _S453 = _slang_select(_S452, lobes_0.translucent_share,_S451);
    float _S454 = _S450 * _S453;
    bool _S455 = (lobes_0.translucent_share) > 0.0f;
    float _S456 = _slang_select(_S455, _S454,_S449);
    bool _S457 = n_i_dot_v_0 > 0.0f;
    float _S458 = _slang_select(_S457, _S456,0.0f);
    return _S458;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_3, float alpha_3, BSDFMaterial material_4, HalfTerms lobes_1)
{
    bool _S459 = (dot_0(n_i_3, l_0)) < 0.0f;
    float3  _S460 = _slang_select(_S459, material_4.translucent,material_4.albedo);
    float _S461 = 1.0f - lobes_1.translucent_share;
    float _S462 = _slang_select(_S459, lobes_1.translucent_share,_S461);
    float3  _S463 = _S460 / make_float3 (_S462);
    bool _S464 = (lobes_1.translucent_share) > 0.0f;
    float3  _S465 = _slang_select(_S464, _S463,material_4.albedo);
    return lobes_1.diffuse_weight * _S465 / make_float3 (lobes_1.p_diffuse);
}

__device__ float smithG1(float alpha_4, float n_dot_x_0)
{
    float _S466 = alpha_4 * alpha_4;
    float _S467 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S466 + (1.0f - _S466) * n_dot_x_0 * n_dot_x_0))));
    bool _S468 = alpha_4 > 0.0f;
    float _S469 = _slang_select(_S468, _S467,1.0f);
    return _S469;
}

__device__ float trowbridgeReitz(float alpha_5, float n_dot_h_1)
{
    float _S470 = alpha_5 * alpha_5;
    float _S471 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S470 * n_dot_h_1 * n_dot_h_1;
    return _S470 / (F32_max((3.14159274101257324f * _S471 * _S471), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float n_i_dot_v_1, float alpha_6, HalfTerms lobes_2)
{
    float _S472 = smithG1(alpha_6, n_i_dot_v_1);
    float _S473 = _S472 * lobes_2.v_dot_h;
    float _S474 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    float _S475 = _S473 * _S474 / n_i_dot_v_1;
    bool _S476 = alpha_6 > 0.0f;
    bool _S477;
    if(_S476)
    {
        _S477 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S477 = false;
    }
    if(_S477)
    {
        _S477 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S477 = false;
    }
    if(_S477)
    {
        _S477 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S477 = false;
    }
    float _S478 = _slang_select(_S477, _S475,0.0f);
    bool _S479 = (lobes_2.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S479)
    {
        float _S480 = lobes_2.visible * lobes_2.v_dot_h / n_i_dot_v_1;
        bool _S481 = (lobes_2.v_dot_h) > 0.0f;
        if(_S481)
        {
            _S477 = (lobes_2.n_dot_h) > 0.0f;
        }
        else
        {
            _S477 = false;
        }
        if(_S477)
        {
            _S477 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S477 = false;
        }
        float _S482 = _slang_select(_S477, _S480,0.0f);
        pdf_h_0 = _S482;
    }
    else
    {
        pdf_h_0 = _S478;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float n_i_dot_l_1, float l_dot_h_1, float n_i_dot_v_2, float alpha_7, HalfTerms lobes_3, float eta_i_4, float eta_o_4)
{
    float _S483 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    float _S484 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    float _S485 = lobes_3.p_refract * _S483 * eta_o_4 * eta_o_4 * (F32_abs((l_dot_h_1))) / (_S484 * _S484);
    bool _S486 = eta_i_4 != eta_o_4;
    bool _S487;
    if(_S486)
    {
        _S487 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S487 = false;
    }
    float _S488 = _slang_select(_S487, _S485,0.0f);
    return _S488;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_4, float alpha_8, BSDFMaterial material_5, HalfTerms lobes_4)
{
    float _S489 = - dot_0(n_i_4, l_1);
    float _S490 = smithG1(alpha_8, (F32_max((_S489), (0.0f))));
    bool _S491 = (lobes_4.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S491)
    {
        float3  _S492 = negate_0(n_i_4);
        float3  _S493 = anisotropicLocal(l_1, lobes_4.tangent, _S492);
        float _S494 = anisotropicG1(_S493, lobes_4.alphas);
        G1_l_0 = _S494;
    }
    else
    {
        G1_l_0 = _S490;
    }
    return lobes_4.refract_weight * make_float3 (G1_l_0) * material_5.albedo / make_float3 (lobes_4.p_refract);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_2, float l_dot_h_2, float n_i_dot_v_3, float alpha_9, HalfTerms lobes_5, float eta_i_5, float eta_o_5)
{
    float _S495 = lobes_5.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S496 = n_i_dot_l_2 > 0.0f;
    bool _S497;
    if(_S496)
    {
        _S497 = n_i_dot_v_3 > 0.0f;
    }
    else
    {
        _S497 = false;
    }
    float _S498 = _slang_select(_S497, _S495,0.0f);
    return _S498;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  n_i_5, float alpha_10, BSDFMaterial material_6, HalfTerms lobes_6)
{
    float3  _S499 = l_2 + lobes_6.view;
    float3  _S500 = ((((_S499)) * make_float3(rnorm3df(((_S499)).x, ((_S499)).y, ((_S499)).z))));
    float _S501 = dot_0(n_i_5, _S500);
    float _S502 = (F32_max((dot_0(n_i_5, l_2)), (0.0f)));
    float _S503 = (F32_max((dot_0(n_i_5, lobes_6.view)), (0.0f)));
    float _S504 = 1.0f / (F32_max((material_6.sheen_roughness), (0.05000000074505806f)));
    float _S505 = 1.0f - _S501 * _S501;
    float _S506 = (2.0f + _S504) * (F32_pow(((F32_max((_S505), (0.0f)))), (0.5f * _S504))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S502 + _S503 - _S502 * _S503)), (0.0000152587890625f)));
    bool _S507 = (material_6.velvet) > 0.0f;
    float f_1;
    if(_S507)
    {
        float _S508 = (F32_max((material_6.sheen_roughness), (0.00999999977648258f)));
        float _S509 = _S508 * _S508;
        float _S510 = (F32_max((_S505), (0.0000152587890625f)));
        float _S511 = (F32_exp((- _S501 * _S501 / (_S510 * _S509)))) / (3.14159274101257324f * _S509 * _S510 * _S510) * (F32_min((1.0f), (2.0f * _S501 * (F32_min((_S502), (_S503))) / (F32_max(((F32_abs((dot_0(_S500, lobes_6.view))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S502 * _S503), (0.0000152587890625f)));
        f_1 = _S511;
    }
    else
    {
        f_1 = _S506;
    }
    return lobes_6.sheen * make_float3 (f_1 * _S502 * 2.0f * 3.14159274101257324f / lobes_6.p_sheen_velvet);
}

__device__ __forceinline__ float toonPDF(float n_i_dot_l_3, float l_dot_h_3, float n_i_dot_v_4, float alpha_11, HalfTerms lobes_7, float eta_i_6, float eta_o_6)
{
    float _S512 = _slang_select(lobes_7.toon_glossy, l_dot_h_3,n_i_dot_l_3);
    float _S513 = (F32_acos((clamp_1(_S512, -1.0f, 1.0f))));
    float _S514;
    if(_S513 < (lobes_7.toon_a))
    {
        _S514 = 1.0f;
    }
    else
    {
        _S514 = (F32_max((1.0f - (_S513 - lobes_7.toon_a) / (F32_max((lobes_7.toon_s), (0.0000152587890625f)))), (0.0f)));
    }
    float _S515 = lobes_7.p_toon * _S514;
    float _S516 = _slang_select(lobes_7.toon_glossy, 1.0f,n_i_dot_l_3);
    float _S517 = _S515 * _S516 / lobes_7.toon_norm;
    bool _S518;
    if(lobes_7.toon_glossy)
    {
        _S518 = true;
    }
    else
    {
        _S518 = n_i_dot_l_3 > 0.0f;
    }
    float _S519 = _slang_select(_S518, _S517,0.0f);
    return _S519;
}

__device__ __forceinline__ float3  toonBSDF(float3  l_3, float3  n_i_6, float alpha_12, BSDFMaterial material_7, HalfTerms lobes_8)
{
    float _S520 = (F32_max((dot_0(n_i_6, l_3)), (0.0f)));
    float _S521 = _slang_select(lobes_8.toon_glossy, _S520,lobes_8.toon_view);
    return lobes_8.toon * make_float3 (_S521) / make_float3 (lobes_8.p_toon);
}

__device__ __forceinline__ float reflectPDF(float n_i_dot_l_4, float l_dot_h_4, float n_i_dot_v_5, float alpha_13, HalfTerms lobes_9, float eta_i_7, float eta_o_7)
{
    float _S522 = vndfPDF(n_i_dot_v_5, alpha_13, lobes_9);
    float _S523 = lobes_9.p_reflect * _S522 / (4.0f * lobes_9.v_dot_h);
    bool _S524 = _S522 > 0.0f;
    float _S525 = _slang_select(_S524, _S523,0.0f);
    return _S525;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_4, float3  n_i_7, float alpha_14, BSDFMaterial material_8, HalfTerms lobes_10)
{
    float _S526 = dot_0(n_i_7, l_4);
    float _S527 = smithG1(alpha_14, (F32_max((_S526), (0.0f))));
    bool _S528 = (lobes_10.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S528)
    {
        float3  _S529 = anisotropicLocal(l_4, lobes_10.tangent, n_i_7);
        float _S530 = anisotropicG1(_S529, lobes_10.alphas);
        G1_l_1 = _S530;
    }
    else
    {
        G1_l_1 = _S527;
    }
    return make_float3 (lobes_10.reflect_weight * G1_l_1) * lobes_10.F / make_float3 (lobes_10.p_reflect);
}

__device__ __forceinline__ float3  misWeighted(float3  throughput_0, float lobe_pdf_0, float pdf_0, bool power_0)
{
    if(power_0)
    {
        float _S531 = lobe_pdf_0 / pdf_0;
        return throughput_0 * make_float3 (lobe_pdf_0) / make_float3 (pdf_0 * (1.0f + _S531 * _S531));
    }
    return throughput_0 * make_float3 (lobe_pdf_0) / make_float3 (lobe_pdf_0 + pdf_0);
}

static __device__ float3  neeLobes_0(float3  in_dir_4, float3  dir_3, float3  n_7, BSDFMaterial * material_9, float eta_i_8, float eta_o_8, bool refracted_2, float pdf_1, bool power_1, uint random_state_4, MaterialTerms * terms_1, ViewTerms * view_terms_2, FixedArray<float3 , 5>  * each_0, uint * reached_0)
{
    float3  _S532 = negate_0(in_dir_4);
    float _S533 = dot_0(n_7, _S532);
    float _S534 = sign_0(_S533);
    float3  _S535 = n_7 * make_float3 (_S534);
    float _S536 = dot_0(_S535, dir_3);
    float _S537 = material_9->roughness * material_9->roughness;
    float3  _S538 = make_float3 (0.0f);
    *reached_0 = 0U;
    HalfTerms _S539 = HalfTerms_x24init_0(0.0f, 0.0f, _S538, _S538, 0.0f, 0.0f, _S538, _S538, 0.0f, 0.0f, 0.0f, 0.0f, _S538, 0.0f, _S538, _S538, make_float2 (0.0f), 0.0f, 0.0f, _S538, 0.0f, 0.0f, 0.0f, false, 1.0f, 0.0f, _S538);
    uint _S540;
    if((F32_abs((material_9->toon.x))) > 0.0f)
    {
        _S540 = 5U;
    }
    else
    {
        _S540 = 4U;
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
        (*each_0)[i_7] = _S538;
        uint i_8 = i_7 + 1U;
        i_7 = i_8;
    }
    uint half_of_0 = 4294967295U;
    HalfTerms lobe_terms_0 = _S539;
    float3  ggx_n_1 = _S538;
    i_7 = 0U;
    float3  f_2 = _S538;
    for(;;)
    {
        if(i_7 < _S540)
        {
        }
        else
        {
            break;
        }
        uint _S541;
        if(i_7 == 3U)
        {
            _S541 = 4U;
        }
        else
        {
            if(i_7 == 4U)
            {
                _S541 = 6U;
            }
            else
            {
                _S541 = i_7;
            }
        }
        bool _S542 = _S541 == 0U;
        if(_S542)
        {
        }
        bool _S543;
        if(_S542)
        {
            float _S544 = rgb_to_greyscale(material_9->translucent);
            _S543 = _S544 > 0.0f;
        }
        else
        {
            _S543 = false;
        }
        bool _S545;
        if(_S543)
        {
            float _S546 = dot_0(n_7, dir_3);
            float3  _S547 = negate_0(in_dir_4);
            _S545 = ((_S546 * dot_0(n_7, _S547)) < 0.0f) == refracted_2;
        }
        else
        {
            _S545 = (_S541 == 1U) == refracted_2;
        }
        float3  ggx_n_2;
        if(_S545)
        {
            uint _S548;
            if(_S541 == 6U)
            {
                _S548 = 0U;
            }
            else
            {
                if(_S541 == 4U)
                {
                    _S548 = 2U;
                }
                else
                {
                    _S548 = _S541;
                }
            }
            bool _S549 = _S548 != half_of_0;
            uint half_of_1;
            HalfTerms lobe_terms_1;
            if(_S549)
            {
                bool _S550 = _S548 == 0U;
                if(_S550)
                {
                    float3  _S551 = sampledHalf(in_dir_4, n_7, *material_9, random_state_4, *view_terms_2);
                    ggx_n_2 = _S551;
                }
                else
                {
                    bool _S552 = _S548 == 1U;
                    if(_S552)
                    {
                        float3  _S553 = refractedHalf(in_dir_4, dir_3, n_7, eta_i_8, eta_o_8);
                        ggx_n_2 = _S553;
                    }
                    else
                    {
                        float3  _S554 = reflectedHalf(in_dir_4, dir_3);
                        ggx_n_2 = _S554;
                    }
                }
                HalfTerms _S555 = precomputeHalf(in_dir_4, ggx_n_2, *material_9, eta_i_8, eta_o_8, *terms_1, *view_terms_2);
                lobe_terms_1 = _S555;
                half_of_1 = _S548;
            }
            else
            {
                lobe_terms_1 = lobe_terms_0;
                ggx_n_2 = ggx_n_1;
                half_of_1 = half_of_0;
            }
            float3  throughput_1;
            float lobe_pdf_1;
            switch(_S541)
            {
            case 0U:
                {
                    float _S556 = diffusePDF(_S536, 0.0f, (F32_abs((_S533))), _S537, lobe_terms_1, eta_i_8, eta_o_8);
                    float3  _S557 = diffuseBSDF(dir_3, _S535, _S537, *material_9, lobe_terms_1);
                    lobe_pdf_1 = _S556;
                    throughput_1 = _S557;
                    break;
                }
            case 1U:
                {
                    float _S558 = refractPDF(_S536, dot_0(dir_3, ggx_n_2), (F32_abs((_S533))), _S537, lobe_terms_1, eta_i_8, eta_o_8);
                    float3  _S559 = refractBSDF(dir_3, _S535, _S537, *material_9, lobe_terms_1);
                    lobe_pdf_1 = _S558;
                    throughput_1 = _S559;
                    break;
                }
            case 4U:
                {
                    float _S560 = sheenVelvetPDF(_S536, 0.0f, (F32_abs((_S533))), _S537, lobe_terms_1, eta_i_8, eta_o_8);
                    float3  _S561 = sheenVelvetBSDF(dir_3, _S535, _S537, *material_9, lobe_terms_1);
                    lobe_pdf_1 = _S560;
                    throughput_1 = _S561;
                    break;
                }
            case 6U:
                {
                    float _S562 = toonPDF(_S536, dot_0(dir_3, lobe_terms_1.toon_axis), (F32_abs((_S533))), _S537, lobe_terms_1, eta_i_8, eta_o_8);
                    float3  _S563 = toonBSDF(dir_3, _S535, _S537, *material_9, lobe_terms_1);
                    lobe_pdf_1 = _S562;
                    throughput_1 = _S563;
                    break;
                }
            default:
                {
                    float _S564 = reflectPDF(_S536, 0.0f, (F32_abs((_S533))), _S537, lobe_terms_1, eta_i_8, eta_o_8);
                    float3  _S565 = reflectBSDF(dir_3, _S535, _S537, *material_9, lobe_terms_1);
                    lobe_pdf_1 = _S564;
                    throughput_1 = _S565;
                    break;
                }
            }
            bool _S566 = lobe_pdf_1 > 0.0f;
            float3  f_3;
            if(_S566)
            {
                float3  _S567 = misWeighted(throughput_1, lobe_pdf_1, pdf_1, power_1);
                (*each_0)[i_7] = _S567;
                uint _S568 = (*reached_0) | (1U << i_7);
                *reached_0 = _S568;
                float3  f_4 = f_2 + (*each_0)[i_7];
                f_3 = f_4;
            }
            else
            {
                f_3 = f_2;
            }
            half_of_0 = half_of_1;
            lobe_terms_0 = lobe_terms_1;
            f_2 = f_3;
        }
        else
        {
            ggx_n_2 = ggx_n_1;
        }
        uint i_9 = i_7 + 1U;
        ggx_n_1 = ggx_n_2;
        i_7 = i_9;
    }
    return f_2;
}

__device__ __forceinline__ float3  neeBSDF(float3  in_dir_5, float3  dir_4, float3  n_8, BSDFMaterial material_10, float eta_i_9, float eta_o_9, bool refracted_3, float pdf_2, bool power_2, uint random_state_5, MaterialTerms terms_2, ViewTerms view_terms_3)
{
    uint reached_1 = 0U;
    BSDFMaterial _S569 = material_10;
    MaterialTerms _S570 = terms_2;
    ViewTerms _S571 = view_terms_3;
    FixedArray<float3 , 5>  each_1;
    float3  _S572 = neeLobes_0(in_dir_5, dir_4, n_8, &_S569, eta_i_9, eta_o_9, refracted_3, pdf_2, power_2, random_state_5, &_S570, &_S571, &each_1, &reached_1);
    return _S572;
}

__device__ float3  skyBSDF(float3  in_dir_6, float3  dir_5, FKSurface surface_1, float2  eta_1, bool is_inside_2, float pdf_3, uint random_state_6)
{
    bool _S573 = wrongSide_0(is_inside_2, false, dir_5, surface_1.geometry_n);
    float _S574 = eta_1.x;
    float _S575 = eta_1.y;
    float _S576 = (F32_min(((F32_sqrt((surface_1.material.specular_level))) * (F32_abs((_S574 - _S575))) / (_S574 + _S575)), (0.9999847412109375f)));
    float _S577 = _S576 * _S576;
    float _S578 = (1.0f + _S576) / (1.0f - _S576);
    float3  _S579 = make_float3 (0.0f);
    float _S580 = surface_1.material.toon.x;
    bool _S581 = _S580 < 0.0f;
    float _S582 = (F32_abs((_S580)));
    bool _S583 = _S582 > 0.0f;
    float toon_scale_1;
    float toon_component_1;
    float toon_a_2;
    float toon_s_2;
    float toon_b_2;
    float toon_norm_2;
    float3  toon_2;
    if(_S583)
    {
        float _S584 = (F32_min((_S582), (1.0f)));
        float _S585 = 1.0f - _S584;
        float _S586 = rgb_to_greyscale(surface_1.material.albedo);
        float _S587 = _S584 * _S586;
        float3  _S588 = make_float3 (_S584) * surface_1.material.albedo;
        float toon_a_3 = clamp_1(surface_1.material.toon.y / _S580, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
        float toon_s_3 = clamp_1(surface_1.material.toon.z / _S580, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
        float _S589 = (F32_min((toon_a_3 + toon_s_3), (1.57079637050628662f)));
        if(_S581)
        {
            toon_scale_1 = 1.0f - (F32_cos(((F32_min((_S589), (toon_a_3))))));
        }
        else
        {
            float _S590 = (F32_sin(((F32_min((_S589), (toon_a_3))))));
            toon_scale_1 = _S590 * _S590 / 2.0f;
        }
        bool _S591 = _S589 > toon_a_3;
        bool _S592;
        if(_S591)
        {
            _S592 = toon_s_3 > 0.0f;
        }
        else
        {
            _S592 = false;
        }
        if(_S592)
        {
            if(_S581)
            {
                float _S593 = (F32_cos((toon_a_3)));
                float _S594 = (F32_cos((_S589)));
                toon_component_1 = (1.0f + toon_a_3 / toon_s_3) * (_S593 - _S594) - ((F32_sin((_S589))) - _S589 * _S594 - ((F32_sin((toon_a_3))) - toon_a_3 * _S593)) / toon_s_3;
            }
            else
            {
                float _S595 = 2.0f * toon_a_3;
                float _S596 = (F32_cos((_S595)));
                float _S597 = 2.0f * _S589;
                float _S598 = (F32_cos((_S597)));
                toon_component_1 = (1.0f + toon_a_3 / toon_s_3) * (_S596 - _S598) / 4.0f - ((F32_sin((_S597))) / 8.0f - _S589 * _S598 / 4.0f - ((F32_sin((_S595))) / 8.0f - toon_a_3 * _S596 / 4.0f)) / toon_s_3;
            }
            float integral_0 = toon_scale_1 + toon_component_1;
            toon_scale_1 = integral_0;
        }
        else
        {
        }
        float _S599 = 6.28318548202514648f * toon_scale_1;
        toon_scale_1 = _S585;
        toon_component_1 = _S587;
        toon_2 = _S588;
        toon_a_2 = toon_a_3;
        toon_s_2 = toon_s_3;
        toon_b_2 = _S589;
        toon_norm_2 = _S599;
    }
    else
    {
        toon_scale_1 = 1.0f;
        toon_component_1 = 0.0f;
        toon_2 = _S579;
        toon_a_2 = 0.0f;
        toon_s_2 = 0.0f;
        toon_b_2 = 0.0f;
        toon_norm_2 = 1.0f;
    }
    float _S600 = translucentShare(surface_1.material);
    MaterialTerms _S601 = MaterialTerms_x24init_0(_S577, _S578, _S600, toon_scale_1, toon_component_1, toon_2, toon_a_2, toon_s_2, toon_b_2, _S581, toon_norm_2);
    float3  _S602 = negate_0(in_dir_6);
    float _S603 = sign_0(dot_0(surface_1.smooth_n, _S602));
    float3  _S604 = surface_1.smooth_n * make_float3 (_S603);
    AnisotropicFrame _S605 = anisotropicFrame(surface_1.material, _S604);
    float3  _S606 = make_float3 (1.0f);
    float _S607 = rgb_to_greyscale(surface_1.material.sheen);
    bool _S608 = _S607 > 0.0f;
    float sheen_component_1;
    float3  sheen_2;
    float3  view_2;
    float3  scale_2;
    if(_S608)
    {
        float _S609 = clamp_1((F32_sqrt(((F32_max((dot_0(_S604, _S602)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S610 = (U32_min((uint(_S609)), (22U)));
        float least_0 = (F32_sqrt((0.05000000074505806f)));
        float _S611 = (F32_sqrt((0.10000000149011612f)));
        bool _S612 = (surface_1.material.velvet) > 0.0f;
        float _S613 = _slang_select(_S612, _S611,least_0);
        float _S614 = (clamp_1((F32_sqrt(((F32_max((surface_1.material.sheen_roughness), (0.0f)))))), _S613, 1.0f) - _S613) / (1.0f - _S613) * 23.0f;
        uint _S615 = (U32_min((uint(_S614)), (22U)));
        uint _S616 = _S610 * 24U + _S615;
        float _S617 = _S609 - float(_S610);
        float _S618 = _S614 - float(_S615);
        uint _S619 = _S616 + 24U;
        float a_5 = SHEEN_ALBEDO_0[_S616] + (SHEEN_ALBEDO_0[_S619] - SHEEN_ALBEDO_0[_S616]) * _S617;
        uint _S620 = _S616 + 1U;
        uint _S621 = _S619 + 1U;
        float b_1 = SHEEN_ALBEDO_0[_S620] + (SHEEN_ALBEDO_0[_S621] - SHEEN_ALBEDO_0[_S620]) * _S617;
        float _S622 = (F32_exp((a_5 + (b_1 - a_5) * _S618)));
        if(_S612)
        {
            float a_6 = VELVET_ALBEDO_0[_S616] + (VELVET_ALBEDO_0[_S619] - VELVET_ALBEDO_0[_S616]) * _S617;
            float b_2 = VELVET_ALBEDO_0[_S620] + (VELVET_ALBEDO_0[_S621] - VELVET_ALBEDO_0[_S620]) * _S617;
            float _S623 = a_6 + (b_2 - a_6) * _S618;
            sheen_component_1 = _S623;
        }
        else
        {
            sheen_component_1 = _S622;
        }
        float _S624 = (F32_min((sheen_component_1), (1.0f)));
        float3  _S625 = make_float3 (1.0f) - surface_1.material.sheen * make_float3 (_S624);
        float _S626 = rgb_to_greyscale(surface_1.material.sheen);
        float _S627 = _S626 * _S624;
        float3  _S628 = surface_1.material.sheen / make_float3 ((F32_max((sheen_component_1), (1.0f))));
        sheen_component_1 = _S627;
        sheen_2 = _S628;
        view_2 = _S602;
        scale_2 = _S625;
    }
    else
    {
        sheen_component_1 = 0.0f;
        sheen_2 = _S579;
        view_2 = _S579;
        scale_2 = _S606;
    }
    float3  scale_3 = scale_2 * make_float3 (_S601.toon_scale);
    float toon_view_2;
    float3  toon_axis_2;
    if(_S583)
    {
        float _S629 = dot_0(_S604, _S602);
        float _S630 = (F32_acos(((F32_min((_S629), (1.0f))))));
        if(_S630 < (_S601.toon_a))
        {
            toon_scale_1 = 1.0f;
        }
        else
        {
            toon_scale_1 = (F32_max((1.0f - (_S630 - _S601.toon_a) / (F32_max((_S601.toon_s), (0.0000152587890625f)))), (0.0f)));
        }
        if(_S601.toon_glossy)
        {
            float3  _S631 = make_float3 (2.0f * _S629) * _S604 - _S602;
            float3  _S632 = ((((_S631)) * make_float3(rnorm3df(((_S631)).x, ((_S631)).y, ((_S631)).z))));
            toon_2 = _S632;
        }
        else
        {
            toon_2 = _S604;
        }
        toon_view_2 = toon_scale_1;
        toon_axis_2 = toon_2;
    }
    else
    {
        toon_view_2 = 0.0f;
        toon_axis_2 = _S604;
    }
    float _S633 = _S605.alphas.x;
    float _S634 = (F32_sqrt(((F32_min((_S633), (_S605.alphas.y))))));
    bool _S635 = _S633 > 0.0f;
    float _S636 = _slang_select(_S635, _S634,surface_1.material.roughness);
    float _S637 = _S636 * _S636;
    float _S638 = (F32_pow((_S637), (1.81585001945495605f))) * (2.15371990203857422f - 0.73285001516342163f * _S637) / (1.0f + 1.28094995021820068f * _S637);
    bool _S639 = _S637 > 0.0f;
    float _S640 = _slang_select(_S639, _S638,0.0f);
    float _S641 = clamp_1(dot_0(_S604, _S602), 0.0f, 1.0f);
    float _S642 = _S637 * _S636;
    float _S643 = (F32_min((1.00064504146575928f - _S636 * (0.00375499995425344f + _S641 * (-0.04133399948477745f + _S641 * (-0.90938502550125122f + _S641 * 0.35275399684906006f))) - _S637 * (0.27602800726890564f + _S641 * (1.27023398876190186f + _S641 * 0.04740000143647194f)) - _S642 * (0.31452900171279907f - _S641 * 0.34830701351165771f) + _S642 * _S636 * 0.27229699492454529f), (1.0f)));
    float3  _S644 = min_1(make_float3 (1.0f) / (make_float3 (1.0f) - surface_1.material.albedo * make_float3 (_S640)), make_float3 (1.0f / (F32_max((_S643), (0.0000152587890625f)))));
    AnisotropicFrame _S645 = _S605;
    ViewTerms _S646 = ViewTerms_x24init_0(_S602, _S604, &_S645, scale_3, sheen_component_1, sheen_2, view_2, _S644, toon_view_2, toon_axis_2);
    float3  _S647 = neeBSDF(in_dir_6, dir_5, surface_1.smooth_n, surface_1.material, _S574, _S575, _S573, pdf_3, false, random_state_6, _S601, _S646);
    return _S647;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_6, float3  radiance_0, float3  color_0, uint random_state_7)
{
    SkySample _S648;
    (&_S648)->dir = dir_6;
    (&_S648)->radiance = radiance_0;
    (&_S648)->color = color_0;
    (&_S648)->random_state = random_state_7;
    return _S648;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_2, float2  eta_2, bool is_inside_3, uint init_random_state_0, uint lobe_state_0, ShadowContext * context_2)
{
    uint2  _S649 = (fcptEnvironmentCdfSize());
    uint2  _S650 = make_uint2 (1U, 0U);
    uint2  _S651 = _S649 - _S650;
    Random _S652 = pcg(init_random_state_0);
    Random _S653 = pcg(_S652.state);
    Random _S654 = pcg(_S653.state);
    Random _S655 = pcg(_S654.state);
    uint _S656 = _S651.x;
    uint _S657 = searchCDF_0(make_uint2 (_S656, 0U), make_uint2 (0U, 1U), _S651.y, _S652.value);
    uint _S658 = searchCDF_0(make_uint2 (0U, _S657), _S650, _S656, _S653.value);
    float2  _S659 = make_float2 ((float)_S651.x, (float)_S651.y);
    float2  _S660 = (make_float2 (float(_S658), float(_S657)) + make_float2 (_S654.value, _S655.value)) / _S659 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S661 = _S660.y;
    float _S662 = (F32_sin((_S661)));
    float _S663 = _S660.x;
    float3  _S664 = make_float3 (- _S662 * (F32_cos((_S663))), _S662 * (F32_sin((_S663))), (F32_cos((_S661))));
    float _S665 = environmentPdf_0(_S664);
    float3  _S666 = skyBSDF(ray_0->unit_direction, _S664, *surface_2, eta_2, is_inside_3, _S665, lobe_state_0);
    bool _S667 = !(_S665 > 0.0f);
    bool _S668;
    if(_S667)
    {
        _S668 = true;
    }
    else
    {
        _S668 = all_1(_S666 == make_float3 (0.0f));
    }
    if(_S668)
    {
        float3  _S669 = make_float3 (0.0f);
        return SkySample_x24init_0(_S664, _S669, _S669, _S655.state);
    }
    float3  _S670 = skyRadiance_0(ray_0->origin, surface_2, is_inside_3, _S664, context_2, _S655.state);
    return SkySample_x24init_0(_S664, _S670, _S666 * _S670, _S655.state);
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

static __device__ float3  hairLight_0(FKSurface * surface_3, float3  in_dir_7, TreeSample * light_1, bool competing_0)
{
    SampleBSDF _S671 = (fcptConnectHair((surface_3->hair), ((&surface_3->material)->albedo), ((&surface_3->material)->specular_tint), (in_dir_7), (light_1->dir)));
    float3  _S672 = _S671.throughput * make_float3 (_S671.pdf);
    float _S673 = light_1->density;
    float _S674 = 1.0f + _S671.pdf * _S671.pdf / (light_1->density * light_1->density);
    bool _S675;
    if(competing_0)
    {
        _S675 = _S673 > 0.0f;
    }
    else
    {
        _S675 = false;
    }
    float _S676 = _slang_select(_S675, _S674,1.0f);
    return _S672 / make_float3 (_S676) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_7, float3  radiance_1, float density_0, uint random_state_8)
{
    TreeSample _S677;
    (&_S677)->dir = dir_7;
    (&_S677)->radiance = radiance_1;
    (&_S677)->density = density_0;
    (&_S677)->random_state = random_state_8;
    return _S677;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_12, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S678 = importance(first_1, p_12, normal_3);
    float _S679 = importance(second_1, p_12, normal_3);
    float2  _S680 = make_float2 (_S678, _S679);
    bool _S681 = _S678 == 0.0f;
    bool _S682;
    if(_S681)
    {
        _S682 = _S679 == 0.0f;
    }
    else
    {
        _S682 = false;
    }
    if(_S682)
    {
        return 2U;
    }
    float _S683 = _S678 + _S679;
    bool _S684 = _S679 > 0.0f;
    if(_S684)
    {
        _S682 = (*pick_0 * _S683) >= _S678;
    }
    else
    {
        _S682 = false;
    }
    uint _S685 = uint(_S682);
    float _S686 = (F32_min(((*pick_0 * _S683 - float(_S685) * _S678) / _slang_vector_get_element(_S680, _S685)), (0.99999994039535522f)));
    *pick_0 = _S686;
    float _S687 = *probability_3 * (_slang_vector_get_element(_S680, _S685) / _S683);
    *probability_3 = _S687;
    return _S685;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_13, float u1_0, float u2_0)
{
    float3  _S688 = center_1 - p_13;
    float _S689 = radius_1 * radius_1 / dot_0(_S688, _S688);
    float _S690 = u1_0 * _S689 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S689), (0.0f)))))));
    float _S691 = 2.0f * u1_0;
    bool _S692 = _S689 >= 1.0f;
    float _S693 = _slang_select(_S692, _S691,_S690);
    float _S694 = (F32_sqrt(((F32_max((_S693 * (2.0f - _S693)), (0.0f))))));
    float _S695 = 6.28318548202514648f * u2_0;
    float3  _S696 = make_float3 (_S694 * (F32_cos((_S695))), 1.0f - _S693, _S694 * (F32_sin((_S695))));
    float3  _S697 = ((((_S688)) * make_float3(rnorm3df(((_S688)).x, ((_S688)).y, ((_S688)).z))));
    float3  _S698 = tangentToWorld(_S696, _S697);
    return _S698;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S699 = center_2 - ray_1->origin;
    float _S700 = dot_0(_S699, ray_1->unit_direction);
    float _S701 = dot_0(_S699, _S699) - _S700 * _S700;
    float _S702 = radius_3 * radius_3;
    bool _S703 = _S701 > _S702;
    if(_S703)
    {
        return 4.294967296e+09f;
    }
    float _S704 = (F32_sqrt((_S702 - _S701)));
    float _S705 = _S700 - _S704;
    float _S706 = _S700 + _S704;
    bool _S707 = _S705 > 0.0000152587890625f;
    bool _S708;
    if(_S707)
    {
        _S708 = _S705 < max_len_0;
    }
    else
    {
        _S708 = false;
    }
    if(_S708)
    {
        return _S705;
    }
    bool _S709 = _S706 > 0.0000152587890625f;
    if(_S709)
    {
        _S708 = _S706 < max_len_0;
    }
    else
    {
        _S708 = false;
    }
    if(_S708)
    {
        return _S706;
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
    Random _S710 = pcg(init_random_state_1);
    Random _S711 = pcg(_S710.state);
    Random _S712 = pcg(_S711.state);
    float3  _S713 = make_float3 (0.0f);
    TreeSample _S714 = TreeSample_x24init_0(_S713, _S713, 0.0f, _S712.state);
    TreeSample sample_0 = _S714;
    float3  _S715 = _slang_select(sided_0, _S713,smooth_n_2);
    float3  _S716 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S710.value;
    float probability_4 = 1.0f;
    uint n_9 = 0U;
    for(;;)
    {
        uint4  _S717 = (fcptLightNode((n_9)));
        if((_S717.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S718 = (fcptLightSecond((n_9)));
        uint _S719 = n_9 + 1U;
        LightNode _S720 = (fcptLightBounds((_S719)));
        LightNode _S721 = (fcptLightBounds((_S718)));
        uint _S722 = pickChild(_S720, _S721, origin_4, _S715, &pick_1, &probability_4);
        bool _S723 = _S722 > 1U;
        if(_S723)
        {
            return sample_0;
        }
        bool _S724 = _S722 == 1U;
        uint _S725 = _slang_select(_S724, _S718,_S719);
        n_9 = _S725;
    }
    bool _S726 = n_9 == 0U;
    bool _S727;
    if(_S726)
    {
        LightNode _S728 = (fcptLightBounds((0U)));
        float _S729 = importance(_S728, origin_4, _S715);
        _S727 = !(_S729 > 0.0f);
    }
    else
    {
        _S727 = false;
    }
    if(_S727)
    {
        return sample_0;
    }
    uint4  _S730 = (fcptLightNode((n_9)));
    FKHit _S731 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S732 = (_S730.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S732)
    {
        FKLight _S733 = (fcptLight((_S730.y)));
        if(sided_0)
        {
            float _S734 = sign_0(dot_0(geometry_n_1, _S733.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S734);
            float3  _S735 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S735;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S716;
            lift_n_0 = smooth_n_2;
        }
        bool _S736 = (_S733.variance) == 0.0f;
        if(_S736)
        {
            float3  _S737 = _S733.position - emitter_point_0;
            float3  _S738 = ((((_S737)) * make_float3(rnorm3df(((_S737)).x, ((_S737)).y, ((_S737)).z))));
            (&sample_0)->dir = _S738;
            float3  _S739 = _S733.color * make_float3 (_S733.intensity) / make_float3 (dot_0(_S737, _S737) * probability_4);
            (&sample_0)->radiance = _S739;
            shadow_1 = _S737;
        }
        else
        {
            float3  _S740 = sampleSphere(_S733.position, _S733.variance, emitter_point_0, _S711.value, _S712.value);
            (&sample_0)->dir = _S740;
            float _S741 = sphereDensity(_S733.position, _S733.variance, emitter_point_0);
            float _S742 = probability_4 * _S741;
            (&sample_0)->density = _S742;
            float3  _S743 = pointLightRadiance(_S733.color, _S733.intensity, _S733.variance);
            float3  _S744 = _S743 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S744;
            FKRay _S745 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S746 = raySphere_0(_S733.position, _S733.variance, &_S745, 4.294967296e+09f);
            float3  _S747 = (&sample_0)->dir * make_float3 (_S746);
            shadow_1 = _S747;
        }
        emitter_0 = _S731;
        emitter_point_0 = _S713;
    }
    else
    {
        uint _S748 = _S730.y;
        uint _S749 = (fcptTriangleOffset((_S748)));
        uint _S750 = _S749 + _S730.z;
        Matrix<float, 3, 3>  _S751 = (fcptWorldTriangle((_S748), (_S750)));
        float _S752 = (F32_sqrt((_S711.value)));
        float2  _S753 = make_float2 (_S752 * (1.0f - _S712.value), _S752 * _S712.value);
        float3  _S754 = mul_0(make_float3 (1.0f - _S752, _S753.x, _S753.y), _S751);
        if(sided_0)
        {
            float _S755 = sign_0(dot_0(geometry_n_1, _S754 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S755);
            float3  _S756 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S756;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S757 = !((dot_0(smooth_n_2, _S754 - origin_4)) > 0.0f);
            if(_S757)
            {
                return sample_0;
            }
            emitter_point_0 = _S716;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S753, _S748, _S750, 0U, 0.0f);
        float3  _S758 = _S754 - emitter_point_0;
        float3  _S759 = ((((_S758)) * make_float3(rnorm3df(((_S758)).x, ((_S758)).y, ((_S758)).z))));
        (&sample_0)->dir = _S759;
        float _S760 = solidAngle(probability_4, cross_0(_S751.rows[int(1)] - _S751.rows[int(0)], _S751.rows[int(2)] - _S751.rows[int(0)]), _S758);
        (&sample_0)->density = _S760;
        bool _S761 = (fcptShadowFirst());
        bool _S762 = !_S761;
        if(_S762)
        {
            FKSurface _S763 = (fcptLightSurfaceAt((emitter_1), (_S754), (_S712.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S754 - origin_4))));
            (&sample_0)->random_state = _S763.random_state;
            float3  _S764 = _slang_select(_S763.skip, _S713,_S763.material.emissive);
            float3  _S765 = _S764 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S765;
        }
        shadow_1 = _S758;
        emitter_0 = emitter_1;
        emitter_point_0 = _S754;
    }
    FKHit _S766 = emitter_0;
    float3  _S767 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S712.state, &_S766);
    bool _S768 = (fcptShadowFirst());
    if(_S768)
    {
        _S727 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S727 = false;
    }
    if(_S727)
    {
        _S727 = !all_1(_S767 == _S713);
    }
    else
    {
        _S727 = false;
    }
    if(_S727)
    {
        FKSurface _S769 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S712.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S769.random_state;
        float3  _S770 = _slang_select(_S769.skip, _S713,_S769.material.emissive);
        float3  _S771 = _S770 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S771;
    }
    float3  _S772 = (&sample_0)->radiance * _S767;
    bool _S773 = all_1(_S767 == _S713);
    float3  _S774 = _slang_select(_S773, _S713,_S772);
    (&sample_0)->radiance = _S774;
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
    float _S775 = 1.0f / (1.0f + b_3 / a_7 * (b_3 / a_7));
    bool _S776 = b_3 > 0.0f;
    float _S777 = _slang_select(_S776, _S775,1.0f);
    return _S777;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S778 = vertex_0->none;
    if(_S778)
    {
        return 1.0f;
    }
    uint _S779 = (fcptLightSlot((*hit_1)));
    float _S780 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S779, light_point_1);
    float _S781 = powerHeuristic(vertex_0->pdf, _S780);
    return _S781;
}

static __device__ float3  environment_0(float3  dir_8, uint depth_0, uint lobe_0)
{
    uint2  _S782 = (fcptEnvironmentMapSize());
    bool _S783 = (_S782.x) > 1U;
    bool _S784;
    if(_S783)
    {
        uint2  _S785 = (fcptEnvironmentMapSize());
        _S784 = (_S785.y) > 1U;
    }
    else
    {
        _S784 = false;
    }
    if(_S784)
    {
        float3  _S786 = (fcptEnvMapSample((dir_8), (depth_0), (lobe_0)));
        return _S786;
    }
    float3  _S787 = (fcptAmbient());
    return _S787;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S788 = (fcptEnvironmentCdfSize());
    bool _S789 = (_S788.x) > 1U;
    bool _S790;
    if(_S789)
    {
        uint2  _S791 = (fcptEnvironmentCdfSize());
        _S790 = (_S791.y) > 1U;
    }
    else
    {
        _S790 = false;
    }
    bool _S792 = !_S790;
    if(_S792)
    {
        return false;
    }
    uint2  _S793 = (fcptEnvironmentMapSize());
    bool _S794 = (_S793.x) > 1U;
    if(_S794)
    {
        uint2  _S795 = (fcptEnvironmentMapSize());
        _S790 = (_S795.y) > 1U;
    }
    else
    {
        _S790 = false;
    }
    return _S790;
}

static __device__ float escapeWeight_0(float pdf_4, float3  dir_9)
{
    bool _S796 = pdf_4 <= 0.0f;
    bool _S797;
    if(_S796)
    {
        _S797 = true;
    }
    else
    {
        bool _S798 = environmentMapped_0();
        _S797 = !_S798;
    }
    if(_S797)
    {
        return 1.0f;
    }
    float _S799 = environmentPdf_0(dir_9);
    return pdf_4 / (pdf_4 + _S799);
}

static __device__ void restir_duplicates_0(uint3  global_invocation_id_1, uint3  local_invocation_id_0, uint local_invocation_index_3)
{
    uint2  _S800 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S801 = make_int2 ((int)_S800.x, (int)_S800.y);
    uint _S802 = previousSeed_0(_S801);
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
            uint _S803 = previousSeed_0(_S801 + make_int2 (x_16, y_5));
            bool _S804 = _S803 == _S802;
            uint _S805 = _slang_select(_S804, 1U,0U);
            uint count_3 = count_2 + _S805;
            int x_17 = x_16 + int(1);
            x_16 = x_17;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S806 = float(count_2 - 1U) / 288.0f;
    bool _S807 = _S802 != 0U;
    float _S808 = _slang_select(_S807, _S806,0.0f);
    fcptStoreDuplication((_S801), (make_uint4 ((F32_asuint((_S808))), 0U, 0U, 0U)));
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

__device__ float resamplingTarget(float3  f_5)
{
    float _S809 = rgb_to_greyscale(abs_0(f_5));
    return _S809;
}

__device__ uint stream(uint seed_3, uint index_0)
{
    uint _S810 = hash(index_0);
    uint _S811 = hash(seed_3 ^ _S810);
    return _S811;
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
    float _S812 = resamplingTarget(weight_0);
    bool _S813 = _S812 > 0.0f;
    bool _S814;
    if(_S813)
    {
        _S814 = _S812 < 3.00000000549775576e+38f;
    }
    else
    {
        _S814 = false;
    }
    bool _S815 = !_S814;
    if(_S815)
    {
        return;
    }
    bool _S816 = sel_2->sums;
    if(_S816)
    {
        float3  _S817 = sel_2->color + weight_0;
        sel_2->color = _S817;
        return;
    }
    float _S818 = sel_2->w_sum + _S812;
    sel_2->w_sum = _S818;
    float3  _S819 = sel_2->color + weight_0;
    sel_2->color = _S819;
    Random _S820 = pcg(sel_2->random_state);
    sel_2->random_state = _S820.state;
    bool _S821 = (_S820.value * sel_2->w_sum) <= _S812;
    if(_S821)
    {
        sel_2->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_3;
    float3  _S822 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S822;
    float _S823 = r_3.jac * shifted_0.jac;
    (&candidate_1)->jac = _S823;
    offer(sel_3, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S824 = resamplingTarget((&r_4)->f);
    float _S825 = sel_4.w_sum / _S824;
    bool _S826 = _S824 > 0.0f;
    float _S827 = _slang_select(_S826, _S825,0.0f);
    (&r_4)->w = _S827;
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
    uint2  _S828 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S829 = make_int2 ((int)_S828.x, (int)_S828.y);
    float3  _S830 = make_float3 (0.0f);
    FKHit _S831 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S832 = Domain_x24init_0(_S830, _S830, &_S831, 0.0f, 0.0f);
    Domain dom_4 = _S832;
    bool _S833 = (fcptCurrentDomain((_S829), (&dom_4)));
    bool _S834 = !_S833;
    if(_S834)
    {
        Reservoir _S835 = (Reservoir{});
        fcptStoreReservoirPrevious((_S829), (_S835), ((&dom_4)->hit));
        return;
    }
    Reservoir _S836 = (fcptLoadReservoirTemporal((_S829)));
    uint t_13 = 0U;
    float count_4 = 0.0f;
    float c_sum_1 = _S836.c;
    for(;;)
    {
        uint _S837 = (fcptRestirNeighbours());
        if(t_13 < _S837)
        {
        }
        else
        {
            break;
        }
        int2  _S838 = partner_0(_S829, t_13);
        Domain neighbor_0 = _S832;
        bool _S839 = (fcptCurrentDomain((_S838), (&neighbor_0)));
        if(_S839)
        {
            float count_5 = count_4 + 1.0f;
            uint4  _S840 = (fcptReservoirTemporal((_S838), (0U)));
            float c_sum_2 = c_sum_1 + (U32_asfloat((_S840.w)));
            count_4 = count_5;
            c_sum_1 = c_sum_2;
        }
        uint t_14 = t_13 + 1U;
        t_13 = t_14;
    }
    float _S841 = _S836.c / (F32_max((count_4), (1.0f)));
    float _S842 = resamplingTarget(_S836.f);
    bool _S843 = count_4 == 0.0f;
    float _S844 = _slang_select(_S843, 1.0f,0.0f);
    Selection _S845 = (Selection{});
    Selection sel_5 = _S845;
    uint _S846 = (fcptFrame());
    uint _S847 = hash(_S846);
    uint _S848 = global_invocation_id_2.x;
    uint2  _S849 = (fcptRenderSize());
    uint _S850 = stream(_S847, _S848 + _S849.x * global_invocation_id_2.y);
    uint _S851 = stream(_S850, 195U);
    (&sel_5)->random_state = _S851;
    t_13 = 0U;
    float canonical_mis_0 = _S844;
    for(;;)
    {
        uint _S852 = (fcptRestirNeighbours());
        if(t_13 < _S852)
        {
        }
        else
        {
            break;
        }
        int2  _S853 = partner_0(_S829, t_13);
        Domain neighbor_dom_0 = _S832;
        bool _S854 = (fcptCurrentDomain((_S853), (&neighbor_dom_0)));
        if(_S854)
        {
            Reservoir _S855 = (fcptLoadReservoirTemporal((_S853)));
            uint4  _S856 = (fcptShiftData((_S853), (t_13)));
            float4  _S857 = asfloat_0(_S856);
            uint4  _S858 = (fcptShiftData((_S829), (t_13)));
            float4  _S859 = asfloat_0(_S858);
            float _S860 = pairShare(_S855.c, _S841, c_sum_1);
            bool _S861 = _S842 > 0.0f;
            float canonical_mis_1;
            if(_S861)
            {
                float _S862 = resamplingTarget(float3 {_S859.x, _S859.y, _S859.z});
                float _S863 = canonicalWeight(_S860, _S841, _S842, _S855.c, _S862);
                float canonical_mis_2 = canonical_mis_0 + _S863;
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float3  _S864 = float3 {_S857.x, _S857.y, _S857.z};
            Shift _S865 = Shift_x24init_0(_S864, _S857.w);
            float _S866 = resamplingTarget(_S855.f);
            float _S867 = resamplingTarget(_S864);
            float _S868 = neighborWeight(_S860, _S855.c, _S866, _S841, _S867);
            offerShifted(&sel_5, _S855, _S865, _S868);
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_15 = t_13 + 1U;
        t_13 = t_15;
    }
    offerShifted(&sel_5, _S836, Shift_x24init_0(_S836.f, 1.0f), canonical_mis_0);
    Reservoir _S869 = finalize(sel_5, c_sum_1);
    fcptStoreReservoirPrevious((_S829), (_S869), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S829), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S829), (make_float4 ((&sel_5)->color.x, (&sel_5)->color.y, (&sel_5)->color.z, 0.0f)));
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
    uint _S870 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S871 = _S870 != 4294967295U;
    if(_S871)
    {
        uint2  _S872 = make_uint2 (_S870, _S870 >> 14U) & make_uint2 (16383U);
        int2  _S873 = make_int2 ((int)_S872.x, (int)_S872.y);
        ShiftJob _S874 = (ShiftJob{});
        ShiftJob shift_job_0 = _S874;
        Shift _S875 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S876 = _S870 >> 28U;
        bool _S877 = spatialJob_0(_S873, _S876, &shift_job_0, true);
        Shift shifted_1;
        if(_S877)
        {
            Domain _S878 = (&shift_job_0)->dom;
            Reservoir _S879 = (&shift_job_0)->r;
            Shift _S880 = passShift_0(&_S878, &_S879);
            shifted_1 = _S880;
        }
        else
        {
            shifted_1 = _S875;
        }
        fcptStoreShiftData((_S873), (_S876), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S881 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S882 = make_int2 ((int)_S881.x, (int)_S881.y);
    FixedArray<uint, 3>  _S883;
    spatialBins_0(_S882, &_S883);
    FixedArray<uint, 3>  _S884 = _S883;
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
        bool _S885 = (_S884[t_16]) == 40U;
        if(_S885)
        {
            fcptStoreShiftData((_S882), (t_16), (make_uint4 (0U)));
        }
        uint t_17 = t_16 + 1U;
        t_16 = t_17;
    }
    FixedArray<uint, 3>  _S886 = _S884;
    queueShifts_0(_S882, &_S886, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S887 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S888 = make_int2 ((int)_S887.x, (int)_S887.y);
    FixedArray<uint, 3>  _S889;
    spatialBins_0(_S888, &_S889);
    FixedArray<uint, 3>  _S890 = _S889;
    countShifts_0(&_S890, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S891 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S892 = _S891 != 4294967295U;
    if(_S892)
    {
        uint2  _S893 = make_uint2 (_S891, _S891 >> 14U) & make_uint2 (16383U);
        int2  _S894 = make_int2 ((int)_S893.x, (int)_S893.y);
        int2  _S895 = (fcptLoadTemporalNeighbor((_S894)));
        uint _S896 = _S891 >> 28U;
        Shift _S897 = temporalShiftAt_0(_S894, _S895, _S896);
        fcptStoreTemporalShift((_S894), (_S896), (make_uint4 (asuint_1(_S897.f).x, asuint_1(_S897.f).y, asuint_1(_S897.f).z, (F32_asuint((_S897.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S898 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S899 = make_int2 ((int)_S898.x, (int)_S898.y);
    FixedArray<uint, 3>  _S900;
    temporalBins_0(_S899, &_S900);
    FixedArray<uint, 3>  _S901 = _S900;
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
        bool _S902 = (_S901[t_18]) == 40U;
        if(_S902)
        {
            fcptStoreTemporalShift((_S899), (t_18), (make_uint4 (0U)));
        }
        uint t_19 = t_18 + 1U;
        t_18 = t_19;
    }
    FixedArray<uint, 3>  _S903 = _S901;
    queueShifts_0(_S899, &_S903, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S904 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S905 = make_int2 ((int)_S904.x, (int)_S904.y);
    bool _S906 = (fcptSceneUnchanged());
    bool _S907 = !_S906;
    bool _S908;
    if(_S907)
    {
        uint2  _S909 = (fcptRenderSize());
        int2  _S910 = make_int2 ((int)_S909.x, (int)_S909.y);
        _S908 = all_0(_S905 < _S910);
    }
    else
    {
        _S908 = false;
    }
    if(_S908)
    {
        Reservoir _S911 = (fcptLoadReservoirInitial((_S905)));
        int2  _S912 = sampleNeighbor_0(_S905, _S911.seed);
        fcptStoreTemporalNeighbor((_S905), (_S912));
    }
    FixedArray<uint, 3>  _S913;
    temporalBins_0(_S905, &_S913);
    FixedArray<uint, 3>  _S914 = _S913;
    countShifts_0(&_S914, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_8, float b_4, float t_20)
{
    return a_8 + (b_4 - a_8) * t_20;
}

__device__ float confidenceCap(float duplicated_0)
{
    float _S915 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S915;
}

__device__ float2  temporalWeights(float c_2, float p_c_1, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S916 = c_2 * p_c_1;
    float _S917 = c_t_0 * p_t_0;
    return make_float2 (_S916 / (_S916 + c_t_0 * g_previous_0), _S917 / (_S917 + c_2 * g_current_0));
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S918 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S919 = make_int2 ((int)_S918.x, (int)_S918.y);
    float3  _S920 = make_float3 (0.0f);
    FKHit _S921 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S922 = Domain_x24init_0(_S920, _S920, &_S921, 0.0f, 0.0f);
    Domain dom_5 = _S922;
    bool _S923 = (fcptCurrentDomain((_S919), (&dom_5)));
    bool _S924 = !_S923;
    if(_S924)
    {
        Reservoir _S925 = (Reservoir{});
        fcptStoreReservoirTemporal((_S919), (_S925), ((&dom_5)->hit));
        return;
    }
    Reservoir _S926 = (fcptLoadReservoirInitial((_S919)));
    bool _S927 = (fcptTemporalQueued());
    bool _S928 = (fcptSceneUnchanged());
    bool _S929;
    if(_S928)
    {
        _S929 = true;
    }
    else
    {
        _S929 = !_S927;
    }
    int2  _S930;
    if(_S929)
    {
        int2  _S931 = sampleNeighbor_0(_S919, _S926.seed);
        _S930 = _S931;
    }
    else
    {
        int2  _S932 = (fcptLoadTemporalNeighbor((_S919)));
        _S930 = _S932;
    }
    bool _S933 = (_S930.x) >= int(0);
    Reservoir r_5;
    if(_S933)
    {
        Reservoir _S934 = (fcptLoadReservoirPrevious((_S930)));
        uint4  _S935 = (fcptDuplication((_S930)));
        float _S936 = (U32_asfloat((_S935.x)));
        uint _S937 = (fcptRestirDecorrelation());
        bool _S938 = _S937 == 1U;
        float _S939 = _slang_select(_S938, _S936,0.0f);
        float _S940 = confidenceCap(_S939);
        float _S941 = (F32_min((_S934.c), (_S940)));
        bool _S942 = (fcptSceneUnchanged());
        float4  _S943 = make_float4 (_S934.f.x, _S934.f.y, _S934.f.z, 1.0f);
        bool _S944 = !_S942;
        if(_S944)
        {
            _S929 = _S927;
        }
        else
        {
            _S929 = false;
        }
        float4  to_current_0;
        if(_S929)
        {
            uint4  _S945 = (fcptTemporalShift((_S919), (0U)));
            float4  _S946 = asfloat_0(_S945);
            to_current_0 = _S946;
        }
        else
        {
            if(_S944)
            {
                Shift _S947 = temporalShiftAt_0(_S919, _S930, 0U);
                float4  _S948 = make_float4 (_S947.f.x, _S947.f.y, _S947.f.z, _S947.jac);
                to_current_0 = _S948;
            }
            else
            {
                to_current_0 = _S943;
            }
        }
        Domain own_1 = _S922;
        if(_S942)
        {
            _S929 = true;
        }
        else
        {
            bool _S949 = (fcptPreviousScenes());
            bool _S950 = !_S949;
            if(_S950)
            {
                _S929 = (_S926.w) > 0.0f;
            }
            else
            {
                _S929 = false;
            }
            if(_S929)
            {
                bool _S951 = (fcptStoredDomainInitial((_S919), (_S926.seed), (&own_1)));
                _S929 = _S951;
            }
            else
            {
                _S929 = false;
            }
            if(_S929)
            {
                Domain _S952 = (fcptPreviousDomain((_S930), (_S926.seed)));
                Domain _S953 = _S952;
                Domain _S954 = own_1;
                bool _S955 = sameDomain_0(&_S953, &_S954);
                _S929 = _S955;
            }
            else
            {
                _S929 = false;
            }
        }
        float4  _S956 = make_float4 (_S926.f.x, _S926.f.y, _S926.f.z, 1.0f);
        bool _S957 = !_S929;
        if(_S957)
        {
            _S929 = _S927;
        }
        else
        {
            _S929 = false;
        }
        float4  to_previous_0;
        if(_S929)
        {
            uint4  _S958 = (fcptTemporalShift((_S919), (1U)));
            float4  _S959 = asfloat_0(_S958);
            to_previous_0 = _S959;
        }
        else
        {
            if(_S957)
            {
                Shift _S960 = temporalShiftAt_0(_S919, _S930, 1U);
                float4  _S961 = make_float4 (_S960.f.x, _S960.f.y, _S960.f.z, _S960.jac);
                to_previous_0 = _S961;
            }
            else
            {
                to_previous_0 = _S956;
            }
        }
        float _S962 = resamplingTarget(_S926.f);
        float _S963 = resamplingTarget(_S934.f);
        Selection _S964 = (Selection{});
        Selection sel_6 = _S964;
        uint _S965 = (fcptFrame());
        uint _S966 = hash(_S965);
        uint _S967 = global_invocation_id_7.x;
        uint2  _S968 = (fcptRenderSize());
        uint _S969 = stream(_S966, _S967 + _S968.x * global_invocation_id_7.y);
        uint _S970 = stream(_S969, 194U);
        (&sel_6)->random_state = _S970;
        float4  _S971 = to_previous_0;
        float _S972 = resamplingTarget(float3 {_S971.x, _S971.y, _S971.z});
        float4  _S973 = to_current_0;
        float3  _S974 = float3 {_S973.x, _S973.y, _S973.z};
        float _S975 = resamplingTarget(_S974);
        float2  _S976 = temporalWeights(_S926.c, _S962, _S941, _S963, _S972, _S975);
        offerShifted(&sel_6, _S926, Shift_x24init_0(_S926.f, 1.0f), _S976.x);
        offerShifted(&sel_6, _S934, Shift_x24init_0(_S974, to_current_0.w), _S976.y);
        Reservoir _S977 = finalize(sel_6, _S926.c + _S941);
        r_5 = _S977;
    }
    else
    {
        r_5 = _S926;
    }
    fcptStoreReservoirTemporal((_S919), (r_5), ((&dom_5)->hit));
    return;
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S978 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S979 = make_int2 ((int)_S978.x, (int)_S978.y);
    float3  _S980 = make_float3 (0.0f);
    float2  _S981 = make_float2 (0.0f);
    FKHit _S982 = Hit_x24init_0(_S981, 0U, 0U, 0U, 0.0f);
    Domain _S983 = Domain_x24init_0(_S980, _S980, &_S982, 0.0f, 0.0f);
    Domain dom_6 = _S983;
    bool _S984 = (fcptCurrentDomain((_S979), (&dom_6)));
    bool _S985 = !_S984;
    if(_S985)
    {
        Reservoir _S986 = (Reservoir{});
        fcptStoreReservoirInitial((_S979), (_S986), ((&dom_6)->hit));
        return;
    }
    uint _S987 = (fcptFrame());
    uint _S988 = hash(_S987);
    uint _S989 = global_invocation_id_8.x;
    uint2  _S990 = (fcptRenderSize());
    uint _S991 = stream(_S988, _S989 + _S990.x * global_invocation_id_8.y);
    Selection _S992 = (Selection{});
    Selection initial_0 = _S992;
    uint _S993 = stream(_S991, 193U);
    (&initial_0)->random_state = _S993;
    bool _S994 = (fcptRestirUsed());
    bool _S995 = !_S994;
    (&initial_0)->sums = _S995;
    uint _S996 = stream(_S991, 0U);
    (&(&initial_0)->r)->seed = _S996;
    FKHit _S997 = Hit_x24init_0(_S981, 4294967295U, 0U, 0U, 0.0f);
    uint _S998 = (fcptSamples());
    float _S999 = 1.0f / float(_S998);
    FKHit hit_2 = _S997;
    uint i_15 = 0U;
    float3  seen_0 = _S980;
    for(;;)
    {
        uint _S1000 = (fcptSamples());
        if(i_15 < _S1000)
        {
        }
        else
        {
            break;
        }
        Reservoir _S1001 = (Reservoir{});
        Reservoir r_6 = _S1001;
        uint _S1002 = stream(_S991, i_15);
        (&r_6)->seed = _S1002;
        Domain path_0 = _S983;
        bool _S1003 = (fcptStoredDomainInitial((_S979), ((&r_6)->seed), (&path_0)));
        bool _S1004 = !_S1003;
        if(_S1004)
        {
            float3  _S1005 = (fcptMissed((_S979), (path_0), (_S999)));
            float3  seen_1 = seen_0 + _S1005;
            seen_0 = seen_1;
            uint i_16 = i_15 + 1U;
            i_15 = i_16;
            continue;
        }
        Domain _S1006 = path_0;
        Reservoir _S1007 = r_6;
        Shift _S1008 = passWalk_0(&_S1006, &_S1007, false, _S999, &initial_0);
        bool _S1009 = ((&(&initial_0)->r)->seed) == ((&r_6)->seed);
        FKHit hit_3;
        if(_S1009)
        {
            FKHit _S1010 = (&path_0)->hit;
            hit_3 = _S1010;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_16 = i_15 + 1U;
        i_15 = i_16;
    }
    uint _S1011 = (fcptSamples());
    float3  seen_2 = seen_0 + (&initial_0)->glow / make_float3 (float(_S1011));
    if((&initial_0)->sums)
    {
        seen_0 = seen_2 + (&initial_0)->color;
    }
    else
    {
        seen_0 = seen_2;
    }
    fcptAddColor((_S979), (make_float4 (seen_0.x, seen_0.y, seen_0.z, 1.0f)));
    Reservoir _S1012 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S979), (_S1012), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_5, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S1013;
    (&_S1013)->none = none_0;
    (&_S1013)->pdf = pdf_5;
    (&_S1013)->origin = origin_5;
    (&_S1013)->smooth_n = smooth_n_3;
    (&_S1013)->start = start_6;
    return _S1013;
}

struct Vertex
{
    bool rough;
    uint lobe;
    float pdf;
    float cos;
    bool inside;
};

static __device__ Vertex Vertex_x24init_0(bool rough_0, uint lobe_1, float pdf_6, float cos_0, bool inside_0)
{
    Vertex _S1014;
    (&_S1014)->rough = rough_0;
    (&_S1014)->lobe = lobe_1;
    (&_S1014)->pdf = pdf_6;
    (&_S1014)->cos = cos_0;
    (&_S1014)->inside = inside_0;
    return _S1014;
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
    float3  _S1015 = exp_0((make_float3 (sigma_1) - extinction_0) * make_float3 (distance_2));
    float3  _S1016 = scatter_0 * _S1015 / make_float3 (sigma_1);
    float3  _S1017 = _slang_select(scatters_0, _S1016,_S1015);
    return _S1017;
}

static __device__ bool scatterSampled_0(bool replay_1, uint b_5, uint stop_0, bool varying_0)
{
    bool _S1018 = !replay_1;
    bool _S1019;
    if(_S1018)
    {
        _S1019 = true;
    }
    else
    {
        bool _S1020 = b_5 == stop_0;
        if(_S1020)
        {
            _S1019 = !varying_0;
        }
        else
        {
            _S1019 = false;
        }
    }
    return _S1019;
}

static __device__ uint arrivalLobe_0(uint b_6, uint prev_lobe_0)
{
    bool _S1021 = b_6 > 0U;
    uint _S1022 = _slang_select(_S1021, prev_lobe_0,3U);
    return _S1022;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_2, bool surface_4, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S1023;
    (&_S1023)->extinction_behind = extinction_behind_0;
    (&_S1023)->extinction_front = extinction_front_0;
    (&_S1023)->fillings = fillings_0;
    (&_S1023)->side = side_0;
    (&_S1023)->depth = depth_1;
    (&_S1023)->lobe = lobe_2;
    (&_S1023)->surface = surface_4;
    (&_S1023)->length = length_2;
    (&_S1023)->width = width_1;
    (&_S1023)->own = *own_2;
    (&_S1023)->fiber = fiber_0;
    return _S1023;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S1024 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S1024)
    {
        return 0.07957746833562851f;
    }
    float _S1025 = g_0 * g_0;
    return (1.0f - _S1025) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S1025 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_9, float3  b_7)
{
    float3  _S1026 = a_9 / b_7;
    float3  _S1027 = make_float3 (0.0f);
    bool3  _S1028 = b_7 == _S1027;
    float3  _S1029 = _slang_select(_S1028, _S1027,_S1026);
    return _S1029;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_6)
{
    uint _S1030 = (1U << count_6) - 1U;
    return (e_2 & (~(_S1030 << offset_1))) | ((newbits_0 & _S1030) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_7, uint end_type_0, uint end_0, float3  f_6)
{
    Reservoir candidate_2 = r_7;
    uint _S1031 = insertBits_0(r_7.path, end_0, 0U, 5U);
    uint _S1032 = insertBits_0(_S1031, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S1032;
    (&candidate_2)->f = f_6;
    return candidate_2;
}

__device__ float survivalProbability(float3  throughput_2, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_2.x), ((F32_max((throughput_2.y), (throughput_2.z)))))) / density_1), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_9)
{
    Random _S1033 = pcg(random_state_9);
    Random _S1034 = pcg(_S1033.state);
    float _S1035 = 1.0f - 2.0f * _S1033.value;
    float _S1036 = (F32_sqrt(((F32_max((1.0f - _S1035 * _S1035), (0.0f))))));
    float _S1037 = 6.28318548202514648f * _S1034.value;
    return make_float3 (_S1036 * (F32_cos((_S1037))), _S1036 * (F32_sin((_S1037))), _S1035);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_10, uint random_state_10, float * pdf_7)
{
    bool _S1038 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1038)
    {
        *pdf_7 = 0.07957746833562851f;
        float3  _S1039 = isotropic_0(random_state_10);
        return _S1039;
    }
    Random _S1040 = pcg(random_state_10);
    Random _S1041 = pcg(_S1040.state);
    float _S1042 = g_1 * g_1;
    float _S1043 = 2.0f * g_1;
    float _S1044 = (1.0f - _S1042) / (1.0f - g_1 + _S1043 * _S1040.value);
    float _S1045 = clamp_1((1.0f + _S1042 - _S1044 * _S1044) / _S1043, -1.0f, 1.0f);
    float _S1046 = (F32_sqrt(((F32_max((1.0f - _S1045 * _S1045), (0.0f))))));
    float _S1047 = 6.28318548202514648f * _S1041.value;
    float _S1048 = phaseHG_0(g_1, _S1045);
    *pdf_7 = _S1048;
    float3  _S1049 = tangentToWorld(make_float3 (_S1046 * (F32_cos((_S1047))), _S1045, _S1046 * (F32_sin((_S1047)))), dir_10);
    float3  _S1050 = ((((_S1049)) * make_float3(rnorm3df(((_S1049)).x, ((_S1049)).y, ((_S1049)).z))));
    return _S1050;
}

static __device__ Vertex scatteredVertex_0(bool is_inside_4)
{
    return Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_4);
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_0, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_3, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2, float velvet_0, float3  toon_3, float dispersion_0)
{
    BSDFMaterial _S1051;
    (&_S1051)->albedo = albedo_0;
    (&_S1051)->emissive = emissive_0;
    (&_S1051)->roughness = roughness_0;
    (&_S1051)->metallic = metallic_0;
    (&_S1051)->transmission = transmission_0;
    (&_S1051)->ior = ior_0;
    (&_S1051)->absorption = absorption_0;
    (&_S1051)->specular_tint = specular_tint_0;
    (&_S1051)->specular_level = specular_level_0;
    (&_S1051)->translucent = translucent_0;
    (&_S1051)->sheen = sheen_3;
    (&_S1051)->sheen_roughness = sheen_roughness_0;
    (&_S1051)->anisotropy = anisotropy_0;
    (&_S1051)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1051)->tangent = tangent_2;
    (&_S1051)->velvet = velvet_0;
    (&_S1051)->toon = toon_3;
    (&_S1051)->dispersion = dispersion_0;
    return _S1051;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1052;
    (&_S1052)->scatter = scatter_1;
    (&_S1052)->extinction = extinction_1;
    (&_S1052)->g = g_2;
    return _S1052;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_11, bool skip_0, uint random_state_11, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1053;
    (&_S1053)->smooth_n = smooth_n_4;
    (&_S1053)->geometry_n = geometry_n_2;
    (&_S1053)->geometry_offset = geometry_offset_2;
    (&_S1053)->material = *material_11;
    (&_S1053)->skip = skip_0;
    (&_S1053)->random_state = random_state_11;
    (&_S1053)->coverage = coverage_0;
    (&_S1053)->encloses = encloses_0;
    (&_S1053)->volume = *volume_0;
    (&_S1053)->fills = fills_0;
    (&_S1053)->hair = hair_0;
    return _S1053;
}

static __device__ FKSurface emitting_0(FKSurface * surface_5, bool top_0)
{
    FKSurface lower_0 = *surface_5;
    float3  _S1054 = (&surface_5->material)->emissive;
    float3  _S1055 = make_float3 (0.0f);
    bool _S1056 = !top_0;
    float3  _S1057 = _slang_select(_S1056, _S1055,_S1054);
    (&(&lower_0)->material)->emissive = _S1057;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_6, float u_2)
{
    float _S1058 = surface_6->coverage;
    bool _S1059 = u_2 < _S1058;
    if(_S1059)
    {
        return *surface_6;
    }
    float3  _S1060 = make_float3 (0.0f);
    float3  _S1061 = make_float3 (1.0f);
    BSDFMaterial _S1062 = Material_x24init_0(_S1060, _S1060, 0.0f, 0.0f, 0.0f, 0.0f, _S1060, _S1061, 1.0f, _S1060, _S1060, 0.5f, 0.0f, 0.0f, _S1060, 0.0f, _S1060, 0.0f);
    BSDFMaterial material_12 = _S1062;
    (&material_12)->albedo = _S1061;
    (&material_12)->emissive = (&surface_6->material)->emissive;
    (&material_12)->transmission = 1.0f;
    (&material_12)->ior = 1.0f;
    (&material_12)->absorption = (&surface_6->material)->absorption;
    FKSurface through_0 = *surface_6;
    (&through_0)->material = material_12;
    return through_0;
}

__device__ float facingSign(float transmission_1, float3  face_0, float3  direction_0)
{
    bool _S1063 = transmission_1 > 0.0f;
    bool _S1064;
    if(_S1063)
    {
        _S1064 = true;
    }
    else
    {
        _S1064 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1065;
    if(_S1064)
    {
        _S1065 = 1.0f;
    }
    else
    {
        _S1065 = -1.0f;
    }
    return _S1065;
}

static __device__ bool arrivesBehind_0(float3  dir_11, float3  n_10)
{
    return (dot_0(dir_11, n_10)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_7, float3  dir_12)
{
    float3  _S1066 = surface_7->geometry_n;
    float _S1067 = facingSign((&surface_7->material)->transmission, surface_7->geometry_n, dir_12);
    FKSurface faced_0 = *surface_7;
    float3  _S1068 = surface_7->smooth_n * make_float3 (_S1067);
    (&faced_0)->smooth_n = _S1068;
    float3  _S1069 = _S1066 * make_float3 (_S1067);
    (&faced_0)->geometry_n = _S1069;
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
    float3  _S1070 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1070));
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
    bool _S1071;
    if(open_0)
    {
        _S1071 = prev_rough_0;
    }
    else
    {
        _S1071 = false;
    }
    if(_S1071)
    {
        _S1071 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S1071 = false;
    }
    return _S1071;
}

__device__ bool dispersive(BSDFMaterial material_13)
{
    bool _S1072 = (material_13.dispersion) > 0.0f;
    bool _S1073;
    if(_S1072)
    {
        _S1073 = (material_13.ior) != 1.0f;
    }
    else
    {
        _S1073 = false;
    }
    return _S1073;
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
        uint _S1074 = (low_1 + high_1 + 1U) / 2U;
        bool _S1075 = (WAVELENGTH_CDF_0[_S1074]) <= u_3;
        if(_S1075)
        {
            low_1 = _S1074;
        }
        else
        {
            uint _S1076 = _S1074 - 1U;
            high_1 = _S1076;
        }
    }
    uint _S1077 = low_1;
    float _S1078 = WAVELENGTH_CDF_0[low_1 + 1U] - WAVELENGTH_CDF_0[low_1];
    return make_float2 (0.37999999523162842f + 0.00499999988824129f * (float(low_1) + (u_3 - WAVELENGTH_CDF_0[_S1077]) / _S1078), _S1078 / 0.00499999988824129f);
}

__device__ static const FixedArray<float, 243>  WAVELENGTH_WEIGHTS_0 = { {
    0.00547470012679696f, -0.00465690018609166f, 0.03257500007748604f, 0.00934640038758516f, -0.00796370021998882f, 0.05577300116419792f, 0.01846100017428398f, -0.01579399965703487f, 0.11072999984025955f, 0.0416410006582737f, -0.03577499836683273f, 0.2513900101184845f, 0.09349299967288971f, -0.08071800321340561f, 0.56742000579833984f, 0.1585099995136261f, -0.13764999806880951f, 0.97018998861312866f, 0.30943000316619873f, -0.27083000540733337f, 1.91740000247955322f, 0.55217999219894409f, -0.48754000663757324f, 3.46889996528625488f, 0.95016998052597046f, -0.84802001714706421f, 6.09439992904663086f, 1.42110002040863037f, -1.28929996490478516f, 9.45199966430664062f, 1.73409998416900635f, -1.6062999963760376f, 12.12800025939941406f, 2.08030009269714355f, -1.98810005187988281f, 15.68700027465820312f, 2.20600008964538574f, -2.20120000839233398f, 18.47699928283691406f, 2.03040003776550293f, -2.17700004577636719f, 19.92700004577636719f, 1.63429999351501465f, -2.00340008735656738f, 20.86899948120117188f, 0.99410998821258545f, -1.62629997730255127f, 20.57799911499023438f, 0.20011000335216522f, -1.11409997940063477f, 19.72100067138671875f, -0.67960000038146973f, -0.45403000712394714f, 17.77599906921386719f, -1.61679995059967041f, 0.37860000133514404f, 14.71500015258789062f, -2.53410005569458008f, 1.27540004253387451f, 11.86499977111816406f, -3.39079999923706055f, 2.2146000862121582f, 9.17669963836669922f, -4.03749990463256836f, 3.0522000789642334f, 6.59509992599487305f, -4.61299991607666016f, 3.89779996871948242f, 4.64589977264404297f, -5.43039989471435547f, 5.0121002197265625f, 3.3199000358581543f, -6.37769985198974609f, 6.33809995651245117f, 2.29699993133544922f, -7.44140005111694336f, 7.91739988327026367f, 1.45389997959136963f, -8.38580036163330078f, 9.60109996795654297f, 0.66465997695922852f, -9.0167999267578125f, 11.23999977111816406f, -0.04403600096702576f, -9.17749977111816406f, 12.63199996948242188f, -0.58126997947692871f, -8.97550010681152344f, 13.91499996185302734f, -0.95730000734329224f, -8.25290012359619141f, 14.86200046539306641f, -1.24430000782012939f, -6.92129993438720703f, 15.03899955749511719f, -1.43069994449615479f, -5.29169988632202148f, 14.90900039672851562f, -1.55149996280670166f, -3.43219995498657227f, 14.70499992370605469f, -1.63569998741149902f, -1.27190005779266357f, 14.24400043487548828f, -1.67030000686645508f, 1.15170001983642578f, 13.32199954986572266f, -1.636199951171875f, 3.73889994621276855f, 12.21199989318847656f, -1.56920003890991211f, 6.43590021133422852f, 10.94699954986572266f, -1.47730004787445068f, 9.16440010070800781f, 9.54769992828369141f, -1.36399996280670166f, 12.02000045776367188f, 8.18799972534179688f, -1.25450003147125244f, 14.78699970245361328f, 6.74429988861083984f, -1.13110005855560303f, 16.72299957275390625f, 5.08780002593994141f, -0.96561002731323242f, 18.14299964904785156f, 3.57019996643066406f, -0.80725997686386108f, 19.91900062561035156f, 2.36269998550415039f, -0.69273000955581665f, 21.05500030517578125f, 1.31369996070861816f, -0.58597999811172485f, 21.3899993896484375f, 0.42390000820159912f, -0.48298001289367676f, 20.99300003051757812f, -0.23857000470161438f, -0.39412000775337219f, 19.82200050354003906f, -0.6866300106048584f, -0.31501999497413635f, 18.12000083923339844f, -0.9412500262260437f, -0.24890999495983124f, 15.7089996337890625f, -1.02020001411437988f, -0.19076000154018402f, 13.19799995422363281f, -0.98919999599456787f, -0.14401000738143921f, 11.23999977111816406f, -0.93347001075744629f, -0.11133000254631042f, 9.36649990081787109f, -0.83820998668670654f, -0.08524099737405777f, 7.41249990463256836f, -0.70064002275466919f, -0.06283199787139893f, 5.71229982376098633f, -0.56079000234603882f, -0.04586699977517128f, 4.42280006408691406f, -0.44653001427650452f, -0.03396600112318993f, 3.34489989280700684f, -0.34457001090049744f, -0.02482499927282333f, 2.49309992790222168f, -0.26017999649047852f, -0.01808100007474422f, 1.82239997386932373f, -0.1921599954366684f, -0.01296999957412481f, 1.29499995708465576f, -0.13766999542713165f, -0.00907570030540228f, 0.92928999662399292f, -0.09956400096416473f, -0.00641620019450784f, 0.61835998296737671f, -0.06671299785375595f, -0.00421149982139468f, 0.40211999416351318f, -0.04354599863290787f, -0.00271830009296536f, 0.2844499945640564f, -0.03087200038135052f, -0.00191440002527088f, 0.20672999322414398f, -0.02246100082993507f, -0.00138829997740686f, 0.15044000744819641f, -0.01634499989449978f, -0.00101030000951141f, 0.10942000150680542f, -0.01188699994236231f, -0.0007347899954766f, 0.07099699974060059f, -0.00771349994465709f, -0.00047679000999779f, 0.04539500176906586f, -0.00493190018460155f, -0.00030484999297187f, 0.03424099832773209f, -0.00372010003775358f, -0.00022995000472292f, 0.02557599917054176f, -0.00277870008721948f, -0.00017175999528263f, 0.01842200011014938f, -0.00200140010565519f, -0.0001237099932041f, 0.01316899992525578f, -0.00143079995177686f, -0.00008843900286593f, 0.00838890019804239f, -0.00091141002485529f, -0.00005633700129692f, 0.00537079991772771f, -0.00058350997278467f, -0.00003606799873523f, 0.00328280008397996f, -0.00035665999166667f, -0.00002204600059486f, 0.00196009990759194f, -0.00021296000340953f, -0.00001316300040344f, 0.00168939994182438f, -0.00018354000349063f, -0.00001134499962063f, 0.00141050003003329f, -0.00015325000276789f, -0.00000947250009631f, 0.00097123999148607f, -0.00010551999730524f, -6.52239987175562419e-06f, 0.00066868000430986f, -0.00007264900341397f, -4.49060007667867467e-06f
} };
__device__ float3  wavelengthWeights(float wavelength_0)
{
    float _S1079 = clamp_1((wavelength_0 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    uint _S1080 = (U32_min((uint(_S1079)), (79U)));
    uint _S1081 = 3U * _S1080;
    float3  _S1082 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1081], WAVELENGTH_WEIGHTS_0[_S1081 + 1U], WAVELENGTH_WEIGHTS_0[_S1081 + 2U]);
    float3  _S1083 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1081 + 3U], WAVELENGTH_WEIGHTS_0[_S1081 + 4U], WAVELENGTH_WEIGHTS_0[_S1081 + 5U]);
    return _S1082 + (_S1083 - _S1082) * make_float3 (_S1079 - float(_S1080));
}

__device__ float dispersedIor(float ior_1, float dispersion_1, float wavelength_1)
{
    float _S1084 = (ior_1 - 1.0f) * dispersion_1 / 1.90962409973144531f;
    float _S1085 = _S1084 * (1.0f / (wavelength_1 * wavelength_1) - 2.89662933349609375f);
    bool _S1086 = dispersion_1 > 0.0f;
    float _S1087 = _slang_select(_S1086, _S1085,0.0f);
    return ior_1 + _S1087;
}

__device__ float2  vertexEta(BSDFMaterial material_14, float n_dot_v_0)
{
    bool _S1088 = n_dot_v_0 < 0.0f;
    float _S1089 = _slang_select(_S1088, material_14.ior,1.0f);
    float _S1090 = _slang_select(_S1088, 1.0f,material_14.ior);
    return make_float2 (_S1089, _S1090);
}

__device__ bool neeDecision(BSDFMaterial material_15, float n_dot_v_1, float eta_i_10, float eta_o_10)
{
    float _S1091 = fresnel((F32_abs((n_dot_v_1))), eta_i_10, eta_o_10);
    float3  _S1092 = mix_0(make_float3 (_S1091), material_15.albedo, material_15.metallic);
    float _S1093 = rgb_to_greyscale(_S1092);
    float _S1094 = (F32_max(((1.0f - _S1093) * (1.0f - material_15.metallic) * (1.0f - material_15.transmission)), (0.0f)));
    bool _S1095 = _S1094 > 0.03999999910593033f;
    bool _S1096;
    if(_S1095)
    {
        _S1096 = true;
    }
    else
    {
        _S1096 = (material_15.roughness) > 0.20000000298023224f;
    }
    return _S1096;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_16)
{
    float _S1097 = rgb_to_greyscale(material_16->translucent);
    return _S1097 > 0.0f;
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
    MediumSides _S1098;
    (&_S1098)->behind = *behind_0;
    (&_S1098)->front = *front_0;
    (&_S1098)->fillings = fillings_1;
    (&_S1098)->face = face_1;
    return _S1098;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_8, FKMedium * medium_0, uint filling_0, float3  dir_13, FKMedium * outside_0)
{
    float3  _S1099 = surface_8->geometry_n;
    MediumSides _S1100 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_8->geometry_n);
    MediumSides sides_0 = _S1100;
    bool _S1101 = surface_8->encloses;
    if(_S1101)
    {
        (&sides_0)->behind = surface_8->volume;
        *&((&(&sides_0)->fillings)->x) = surface_8->fills;
        bool _S1102 = (dot_0(dir_13, _S1099)) > 0.0f;
        if(_S1102)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_9, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_14, uint depth_2, uint lobe_3, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1103 = surface_9->geometry_n;
    ShadowContext _S1104 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_9->geometry_n, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
    bool _S1105 = surface_9->encloses;
    ShadowContext context_4;
    if(_S1105)
    {
        FKSurface faced_1 = *surface_9;
        float3  _S1106 = - _S1103;
        float3  _S1107 = _slang_select(turned_0, _S1106,_S1103);
        (&faced_1)->geometry_n = _S1107;
        FKMedium _S1108 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1109 = faced_1;
        FKMedium _S1110 = _S1108;
        MediumSides _S1111 = mediumSides_0(&_S1109, &_S1110, filling_1, dir_14, outside_1);
        ShadowContext _S1112 = ShadowContext_x24init_0(_S1111.behind.extinction, _S1111.front.extinction, _S1111.fillings, _S1103, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
        if(turned_0)
        {
            uint2  _S1113 = _S1111.fillings;
            ShadowContext _S1114 = ShadowContext_x24init_0(_S1111.front.extinction, _S1111.behind.extinction, uint2 {_S1113.y, _S1113.x}, _S1103, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
            context_4 = _S1114;
        }
        else
        {
            context_4 = _S1112;
        }
    }
    else
    {
        context_4 = _S1104;
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

__device__ __forceinline__ float3  BSDF(float3  in_dir_8, float3  out_dir_2, float3  n_11, float3  g_n_0, BSDFMaterial material_17, float eta_i_11, float eta_o_11, uint random_state_12, MaterialTerms terms_3, ViewTerms view_terms_4)
{
    float3  _S1115 = negate_0(in_dir_8);
    float _S1116 = dot_0(n_11, _S1115);
    float _S1117 = sign_0(_S1116);
    float3  _S1118 = n_11 * make_float3 (_S1117);
    float _S1119 = dot_0(_S1118, out_dir_2);
    float _S1120 = material_17.roughness;
    float _S1121 = _S1120 * _S1120;
    bool _S1122 = (dot_0(g_n_0, _S1115) * dot_0(g_n_0, out_dir_2)) > 0.0f;
    uint _S1123;
    if((F32_abs((material_17.toon.x))) > 0.0f)
    {
        _S1123 = 1U;
    }
    else
    {
        _S1123 = 0U;
    }
    if(_S1122)
    {
        _S1123 = 3U + _S1123;
    }
    else
    {
        _S1123 = 1U;
    }
    float3  _S1124 = make_float3 (0.0f);
    HalfTerms _S1125 = HalfTerms_x24init_0(0.0f, 0.0f, _S1124, _S1124, 0.0f, 0.0f, _S1124, _S1124, 0.0f, 0.0f, 0.0f, 0.0f, _S1124, 0.0f, _S1124, _S1124, make_float2 (0.0f), 0.0f, 0.0f, _S1124, 0.0f, 0.0f, 0.0f, false, 1.0f, 0.0f, _S1124);
    uint half_of_2 = 4294967295U;
    HalfTerms lobe_terms_2 = _S1125;
    float3  ggx_n_3 = _S1124;
    float3  f_7 = _S1124;
    uint i_21 = 0U;
    for(;;)
    {
        if(i_21 < _S1123)
        {
        }
        else
        {
            break;
        }
        uint _S1126;
        if(!_S1122)
        {
            _S1126 = 1U;
        }
        else
        {
            if(i_21 == 0U)
            {
                _S1126 = 0U;
            }
            else
            {
                if(i_21 == 1U)
                {
                    _S1126 = 2U;
                }
                else
                {
                    if(i_21 == 2U)
                    {
                        _S1126 = 4U;
                    }
                    else
                    {
                        _S1126 = 6U;
                    }
                }
            }
        }
        uint _S1127;
        if(_S1126 == 6U)
        {
            _S1127 = 0U;
        }
        else
        {
            if(_S1126 == 4U)
            {
                _S1127 = 2U;
            }
            else
            {
                _S1127 = _S1126;
            }
        }
        bool _S1128 = _S1127 != half_of_2;
        float3  ggx_n_4;
        if(_S1128)
        {
            bool _S1129 = _S1127 == 0U;
            if(_S1129)
            {
                float3  _S1130 = sampledHalf(in_dir_8, n_11, material_17, random_state_12, view_terms_4);
                ggx_n_4 = _S1130;
            }
            else
            {
                bool _S1131 = _S1127 == 1U;
                if(_S1131)
                {
                    float3  _S1132 = refractedHalf(in_dir_8, out_dir_2, n_11, eta_i_11, eta_o_11);
                    ggx_n_4 = _S1132;
                }
                else
                {
                    float3  _S1133 = reflectedHalf(in_dir_8, out_dir_2);
                    ggx_n_4 = _S1133;
                }
            }
            HalfTerms _S1134 = precomputeHalf(in_dir_8, ggx_n_4, material_17, eta_i_11, eta_o_11, terms_3, view_terms_4);
            lobe_terms_2 = _S1134;
            half_of_2 = _S1127;
        }
        else
        {
            ggx_n_4 = ggx_n_3;
        }
        float3  throughput_3;
        float pdf_8;
        switch(_S1126)
        {
        case 0U:
            {
                float _S1135 = diffusePDF(_S1119, 0.0f, (F32_abs((_S1116))), _S1121, lobe_terms_2, eta_i_11, eta_o_11);
                float3  _S1136 = diffuseBSDF(out_dir_2, _S1118, _S1121, material_17, lobe_terms_2);
                pdf_8 = _S1135;
                throughput_3 = _S1136;
                break;
            }
        case 1U:
            {
                float _S1137 = refractPDF(_S1119, dot_0(out_dir_2, ggx_n_4), (F32_abs((_S1116))), _S1121, lobe_terms_2, eta_i_11, eta_o_11);
                float3  _S1138 = refractBSDF(out_dir_2, _S1118, _S1121, material_17, lobe_terms_2);
                pdf_8 = _S1137;
                throughput_3 = _S1138;
                break;
            }
        case 4U:
            {
                float _S1139 = sheenVelvetPDF(_S1119, 0.0f, (F32_abs((_S1116))), _S1121, lobe_terms_2, eta_i_11, eta_o_11);
                float3  _S1140 = sheenVelvetBSDF(out_dir_2, _S1118, _S1121, material_17, lobe_terms_2);
                pdf_8 = _S1139;
                throughput_3 = _S1140;
                break;
            }
        case 6U:
            {
                float _S1141 = toonPDF(_S1119, dot_0(out_dir_2, lobe_terms_2.toon_axis), (F32_abs((_S1116))), _S1121, lobe_terms_2, eta_i_11, eta_o_11);
                float3  _S1142 = toonBSDF(out_dir_2, _S1118, _S1121, material_17, lobe_terms_2);
                pdf_8 = _S1141;
                throughput_3 = _S1142;
                break;
            }
        default:
            {
                float _S1143 = reflectPDF(_S1119, 0.0f, (F32_abs((_S1116))), _S1121, lobe_terms_2, eta_i_11, eta_o_11);
                float3  _S1144 = reflectBSDF(out_dir_2, _S1118, _S1121, material_17, lobe_terms_2);
                pdf_8 = _S1143;
                throughput_3 = _S1144;
                break;
            }
        }
        float3  _S1145;
        if(pdf_8 > 0.0f)
        {
            _S1145 = throughput_3 * make_float3 (pdf_8);
        }
        else
        {
            _S1145 = _S1124;
        }
        if(i_21 == 0U)
        {
            f_7 = _S1145;
        }
        else
        {
            f_7 = f_7 + _S1145;
        }
        uint i_22 = i_21 + 1U;
        ggx_n_3 = ggx_n_4;
        i_21 = i_22;
    }
    return f_7;
}

__device__ float3  translucentCorrection(float3  in_dir_9, float3  out_dir_3, float3  n_12, float3  g_n_1, BSDFMaterial material_18, float eta_i_12, float eta_o_12, uint random_state_13, MaterialTerms terms_4, ViewTerms view_terms_5)
{
    float _S1146 = dot_0(n_12, out_dir_3);
    float3  _S1147 = negate_0(in_dir_9);
    bool _S1148 = (_S1146 * dot_0(n_12, _S1147)) < 0.0f;
    float3  _S1149 = negate_0(in_dir_9);
    float _S1150 = dot_0(n_12, _S1149);
    float _S1151 = sign_0(_S1150);
    float3  _S1152 = n_12 * make_float3 (_S1151);
    float _S1153 = material_18.roughness;
    float _S1154 = _S1153 * _S1153;
    float3  _S1155 = sampledHalf(in_dir_9, n_12, material_18, random_state_13, view_terms_5);
    HalfTerms _S1156 = precomputeHalf(in_dir_9, _S1155, material_18, eta_i_12, eta_o_12, terms_4, view_terms_5);
    float _S1157 = diffusePDF(dot_0(_S1152, out_dir_3), 0.0f, (F32_abs((_S1150))), _S1154, _S1156, eta_i_12, eta_o_12);
    float3  _S1158;
    if(_S1157 > 0.0f)
    {
        float3  _S1159 = diffuseBSDF(out_dir_3, _S1152, _S1154, material_18, _S1156);
        _S1158 = _S1159 * make_float3 (_S1157);
    }
    else
    {
        _S1158 = make_float3 (0.0f);
    }
    float3  _S1160 = negate_0(in_dir_9);
    bool _S1161 = (dot_0(g_n_1, _S1160) * dot_0(g_n_1, out_dir_3)) > 0.0f;
    float3  _S1162 = make_float3 (0.0f);
    float _S1163 = _slang_select(_S1161, -1.0f,1.0f);
    float3  _S1164 = _S1158 * make_float3 (_S1163);
    float3  _S1165 = _slang_select(_S1148, _S1164,_S1162);
    return _S1165;
}

__device__ float3  translucentBSDF(float3  in_dir_10, float3  out_dir_4, float3  n_13, float3  g_n_2, BSDFMaterial material_19, float eta_i_13, float eta_o_13, uint random_state_14)
{
    float _S1166 = (F32_min(((F32_sqrt((material_19.specular_level))) * (F32_abs((eta_i_13 - eta_o_13))) / (eta_i_13 + eta_o_13)), (0.9999847412109375f)));
    float _S1167 = _S1166 * _S1166;
    float _S1168 = (1.0f + _S1166) / (1.0f - _S1166);
    float3  _S1169 = make_float3 (0.0f);
    float _S1170 = material_19.toon.x;
    bool _S1171 = _S1170 < 0.0f;
    float _S1172 = (F32_abs((_S1170)));
    bool _S1173 = _S1172 > 0.0f;
    float toon_scale_2;
    float toon_component_2;
    float toon_a_4;
    float toon_s_4;
    float toon_b_3;
    float toon_norm_3;
    float3  toon_4;
    if(_S1173)
    {
        float _S1174 = (F32_min((_S1172), (1.0f)));
        float _S1175 = 1.0f - _S1174;
        float _S1176 = rgb_to_greyscale(material_19.albedo);
        float _S1177 = _S1174 * _S1176;
        float3  _S1178 = make_float3 (_S1174) * material_19.albedo;
        float toon_a_5 = clamp_1(material_19.toon.y / _S1170, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
        float toon_s_5 = clamp_1(material_19.toon.z / _S1170, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
        float _S1179 = (F32_min((toon_a_5 + toon_s_5), (1.57079637050628662f)));
        if(_S1171)
        {
            toon_scale_2 = 1.0f - (F32_cos(((F32_min((_S1179), (toon_a_5))))));
        }
        else
        {
            float _S1180 = (F32_sin(((F32_min((_S1179), (toon_a_5))))));
            toon_scale_2 = _S1180 * _S1180 / 2.0f;
        }
        bool _S1181 = _S1179 > toon_a_5;
        bool _S1182;
        if(_S1181)
        {
            _S1182 = toon_s_5 > 0.0f;
        }
        else
        {
            _S1182 = false;
        }
        if(_S1182)
        {
            if(_S1171)
            {
                float _S1183 = (F32_cos((toon_a_5)));
                float _S1184 = (F32_cos((_S1179)));
                toon_component_2 = (1.0f + toon_a_5 / toon_s_5) * (_S1183 - _S1184) - ((F32_sin((_S1179))) - _S1179 * _S1184 - ((F32_sin((toon_a_5))) - toon_a_5 * _S1183)) / toon_s_5;
            }
            else
            {
                float _S1185 = 2.0f * toon_a_5;
                float _S1186 = (F32_cos((_S1185)));
                float _S1187 = 2.0f * _S1179;
                float _S1188 = (F32_cos((_S1187)));
                toon_component_2 = (1.0f + toon_a_5 / toon_s_5) * (_S1186 - _S1188) / 4.0f - ((F32_sin((_S1187))) / 8.0f - _S1179 * _S1188 / 4.0f - ((F32_sin((_S1185))) / 8.0f - toon_a_5 * _S1186 / 4.0f)) / toon_s_5;
            }
            float integral_1 = toon_scale_2 + toon_component_2;
            toon_scale_2 = integral_1;
        }
        else
        {
        }
        float _S1189 = 6.28318548202514648f * toon_scale_2;
        toon_scale_2 = _S1175;
        toon_component_2 = _S1177;
        toon_4 = _S1178;
        toon_a_4 = toon_a_5;
        toon_s_4 = toon_s_5;
        toon_b_3 = _S1179;
        toon_norm_3 = _S1189;
    }
    else
    {
        toon_scale_2 = 1.0f;
        toon_component_2 = 0.0f;
        toon_4 = _S1169;
        toon_a_4 = 0.0f;
        toon_s_4 = 0.0f;
        toon_b_3 = 0.0f;
        toon_norm_3 = 1.0f;
    }
    float _S1190 = translucentShare(material_19);
    MaterialTerms _S1191 = MaterialTerms_x24init_0(_S1167, _S1168, _S1190, toon_scale_2, toon_component_2, toon_4, toon_a_4, toon_s_4, toon_b_3, _S1171, toon_norm_3);
    float3  _S1192 = negate_0(in_dir_10);
    float _S1193 = sign_0(dot_0(n_13, _S1192));
    float3  _S1194 = n_13 * make_float3 (_S1193);
    AnisotropicFrame _S1195 = anisotropicFrame(material_19, _S1194);
    float3  _S1196 = make_float3 (1.0f);
    float _S1197 = rgb_to_greyscale(material_19.sheen);
    bool _S1198 = _S1197 > 0.0f;
    float sheen_component_2;
    float3  sheen_4;
    float3  view_3;
    float3  scale_4;
    if(_S1198)
    {
        float _S1199 = clamp_1((F32_sqrt(((F32_max((dot_0(_S1194, _S1192)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S1200 = (U32_min((uint(_S1199)), (22U)));
        float least_1 = (F32_sqrt((0.05000000074505806f)));
        float _S1201 = (F32_sqrt((0.10000000149011612f)));
        bool _S1202 = (material_19.velvet) > 0.0f;
        float _S1203 = _slang_select(_S1202, _S1201,least_1);
        float _S1204 = (clamp_1((F32_sqrt(((F32_max((material_19.sheen_roughness), (0.0f)))))), _S1203, 1.0f) - _S1203) / (1.0f - _S1203) * 23.0f;
        uint _S1205 = (U32_min((uint(_S1204)), (22U)));
        uint _S1206 = _S1200 * 24U + _S1205;
        float _S1207 = _S1199 - float(_S1200);
        float _S1208 = _S1204 - float(_S1205);
        uint _S1209 = _S1206 + 24U;
        float a_10 = SHEEN_ALBEDO_0[_S1206] + (SHEEN_ALBEDO_0[_S1209] - SHEEN_ALBEDO_0[_S1206]) * _S1207;
        uint _S1210 = _S1206 + 1U;
        uint _S1211 = _S1209 + 1U;
        float b_8 = SHEEN_ALBEDO_0[_S1210] + (SHEEN_ALBEDO_0[_S1211] - SHEEN_ALBEDO_0[_S1210]) * _S1207;
        float _S1212 = (F32_exp((a_10 + (b_8 - a_10) * _S1208)));
        if(_S1202)
        {
            float a_11 = VELVET_ALBEDO_0[_S1206] + (VELVET_ALBEDO_0[_S1209] - VELVET_ALBEDO_0[_S1206]) * _S1207;
            float b_9 = VELVET_ALBEDO_0[_S1210] + (VELVET_ALBEDO_0[_S1211] - VELVET_ALBEDO_0[_S1210]) * _S1207;
            float _S1213 = a_11 + (b_9 - a_11) * _S1208;
            sheen_component_2 = _S1213;
        }
        else
        {
            sheen_component_2 = _S1212;
        }
        float _S1214 = (F32_min((sheen_component_2), (1.0f)));
        float3  _S1215 = make_float3 (1.0f) - material_19.sheen * make_float3 (_S1214);
        float _S1216 = rgb_to_greyscale(material_19.sheen);
        float _S1217 = _S1216 * _S1214;
        float3  _S1218 = material_19.sheen / make_float3 ((F32_max((sheen_component_2), (1.0f))));
        sheen_component_2 = _S1217;
        sheen_4 = _S1218;
        view_3 = _S1192;
        scale_4 = _S1215;
    }
    else
    {
        sheen_component_2 = 0.0f;
        sheen_4 = _S1169;
        view_3 = _S1169;
        scale_4 = _S1196;
    }
    float3  scale_5 = scale_4 * make_float3 (_S1191.toon_scale);
    float toon_view_3;
    float3  toon_axis_3;
    if(_S1173)
    {
        float _S1219 = dot_0(_S1194, _S1192);
        float _S1220 = (F32_acos(((F32_min((_S1219), (1.0f))))));
        if(_S1220 < (_S1191.toon_a))
        {
            toon_scale_2 = 1.0f;
        }
        else
        {
            toon_scale_2 = (F32_max((1.0f - (_S1220 - _S1191.toon_a) / (F32_max((_S1191.toon_s), (0.0000152587890625f)))), (0.0f)));
        }
        if(_S1191.toon_glossy)
        {
            float3  _S1221 = make_float3 (2.0f * _S1219) * _S1194 - _S1192;
            float3  _S1222 = ((((_S1221)) * make_float3(rnorm3df(((_S1221)).x, ((_S1221)).y, ((_S1221)).z))));
            toon_4 = _S1222;
        }
        else
        {
            toon_4 = _S1194;
        }
        toon_view_3 = toon_scale_2;
        toon_axis_3 = toon_4;
    }
    else
    {
        toon_view_3 = 0.0f;
        toon_axis_3 = _S1194;
    }
    float _S1223 = _S1195.alphas.x;
    float _S1224 = (F32_sqrt(((F32_min((_S1223), (_S1195.alphas.y))))));
    bool _S1225 = _S1223 > 0.0f;
    float _S1226 = _slang_select(_S1225, _S1224,material_19.roughness);
    float _S1227 = _S1226 * _S1226;
    float _S1228 = (F32_pow((_S1227), (1.81585001945495605f))) * (2.15371990203857422f - 0.73285001516342163f * _S1227) / (1.0f + 1.28094995021820068f * _S1227);
    bool _S1229 = _S1227 > 0.0f;
    float _S1230 = _slang_select(_S1229, _S1228,0.0f);
    float _S1231 = clamp_1(dot_0(_S1194, _S1192), 0.0f, 1.0f);
    float _S1232 = _S1227 * _S1226;
    float _S1233 = (F32_min((1.00064504146575928f - _S1226 * (0.00375499995425344f + _S1231 * (-0.04133399948477745f + _S1231 * (-0.90938502550125122f + _S1231 * 0.35275399684906006f))) - _S1227 * (0.27602800726890564f + _S1231 * (1.27023398876190186f + _S1231 * 0.04740000143647194f)) - _S1232 * (0.31452900171279907f - _S1231 * 0.34830701351165771f) + _S1232 * _S1226 * 0.27229699492454529f), (1.0f)));
    float3  _S1234 = min_1(make_float3 (1.0f) / (make_float3 (1.0f) - material_19.albedo * make_float3 (_S1230)), make_float3 (1.0f / (F32_max((_S1233), (0.0000152587890625f)))));
    AnisotropicFrame _S1235 = _S1195;
    ViewTerms _S1236 = ViewTerms_x24init_0(_S1192, _S1194, &_S1235, scale_5, sheen_component_2, sheen_4, view_3, _S1234, toon_view_3, toon_axis_3);
    float3  _S1237 = BSDF(in_dir_10, out_dir_4, n_13, g_n_2, material_19, eta_i_13, eta_o_13, random_state_14, _S1191, _S1236);
    float3  _S1238 = translucentCorrection(in_dir_10, out_dir_4, n_13, g_n_2, material_19, eta_i_13, eta_o_13, random_state_14, _S1191, _S1236);
    return _S1237 + _S1238;
}

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_11, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_4, BSDFMaterial * material_20, float eta_i_14, float eta_o_14, bool competing_1, uint random_state_15)
{
    bool _S1239 = !competing_1;
    bool _S1240;
    if(_S1239)
    {
        _S1240 = true;
    }
    else
    {
        _S1240 = (light_2->density) == 0.0f;
    }
    if(_S1240)
    {
        bool _S1241 = isTranslucent_0(material_20);
        _S1240 = _S1241;
    }
    else
    {
        _S1240 = false;
    }
    if(_S1240)
    {
        float3  _S1242 = translucentBSDF(in_dir_11, light_2->dir, smooth_n_5, geometry_n_4, *material_20, eta_i_14, eta_o_14, random_state_15);
        return _S1242 * light_2->radiance;
    }
    float _S1243 = (F32_min(((F32_sqrt((material_20->specular_level))) * (F32_abs((eta_i_14 - eta_o_14))) / (eta_i_14 + eta_o_14)), (0.9999847412109375f)));
    float _S1244 = _S1243 * _S1243;
    float _S1245 = (1.0f + _S1243) / (1.0f - _S1243);
    float3  _S1246 = make_float3 (0.0f);
    float3  _S1247 = material_20->toon;
    float _S1248 = material_20->toon.x;
    bool _S1249 = _S1248 < 0.0f;
    float _S1250 = (F32_abs((_S1248)));
    bool _S1251 = _S1250 > 0.0f;
    float toon_scale_3;
    float toon_component_3;
    float toon_a_6;
    float toon_s_6;
    float toon_b_4;
    float toon_norm_4;
    float3  toon_5;
    if(_S1251)
    {
        float _S1252 = (F32_min((_S1250), (1.0f)));
        float _S1253 = 1.0f - _S1252;
        float3  _S1254 = material_20->albedo;
        float _S1255 = rgb_to_greyscale(material_20->albedo);
        float _S1256 = _S1252 * _S1255;
        float3  _S1257 = make_float3 (_S1252) * _S1254;
        float toon_a_7 = clamp_1(_S1247.y / _S1248, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
        float toon_s_7 = clamp_1(_S1247.z / _S1248, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
        float _S1258 = (F32_min((toon_a_7 + toon_s_7), (1.57079637050628662f)));
        if(_S1249)
        {
            toon_scale_3 = 1.0f - (F32_cos(((F32_min((_S1258), (toon_a_7))))));
        }
        else
        {
            float _S1259 = (F32_sin(((F32_min((_S1258), (toon_a_7))))));
            toon_scale_3 = _S1259 * _S1259 / 2.0f;
        }
        bool _S1260 = _S1258 > toon_a_7;
        if(_S1260)
        {
            _S1240 = toon_s_7 > 0.0f;
        }
        else
        {
            _S1240 = false;
        }
        if(_S1240)
        {
            if(_S1249)
            {
                float _S1261 = (F32_cos((toon_a_7)));
                float _S1262 = (F32_cos((_S1258)));
                toon_component_3 = (1.0f + toon_a_7 / toon_s_7) * (_S1261 - _S1262) - ((F32_sin((_S1258))) - _S1258 * _S1262 - ((F32_sin((toon_a_7))) - toon_a_7 * _S1261)) / toon_s_7;
            }
            else
            {
                float _S1263 = 2.0f * toon_a_7;
                float _S1264 = (F32_cos((_S1263)));
                float _S1265 = 2.0f * _S1258;
                float _S1266 = (F32_cos((_S1265)));
                toon_component_3 = (1.0f + toon_a_7 / toon_s_7) * (_S1264 - _S1266) / 4.0f - ((F32_sin((_S1265))) / 8.0f - _S1258 * _S1266 / 4.0f - ((F32_sin((_S1263))) / 8.0f - toon_a_7 * _S1264 / 4.0f)) / toon_s_7;
            }
            float integral_2 = toon_scale_3 + toon_component_3;
            toon_scale_3 = integral_2;
        }
        else
        {
        }
        float _S1267 = 6.28318548202514648f * toon_scale_3;
        toon_scale_3 = _S1253;
        toon_component_3 = _S1256;
        toon_5 = _S1257;
        toon_a_6 = toon_a_7;
        toon_s_6 = toon_s_7;
        toon_b_4 = _S1258;
        toon_norm_4 = _S1267;
    }
    else
    {
        toon_scale_3 = 1.0f;
        toon_component_3 = 0.0f;
        toon_5 = _S1246;
        toon_a_6 = 0.0f;
        toon_s_6 = 0.0f;
        toon_b_4 = 0.0f;
        toon_norm_4 = 1.0f;
    }
    float _S1268 = translucentShare(*material_20);
    MaterialTerms _S1269 = MaterialTerms_x24init_0(_S1244, _S1245, _S1268, toon_scale_3, toon_component_3, toon_5, toon_a_6, toon_s_6, toon_b_4, _S1249, toon_norm_4);
    float3  _S1270 = negate_0(in_dir_11);
    float _S1271 = sign_0(dot_0(smooth_n_5, _S1270));
    float3  _S1272 = smooth_n_5 * make_float3 (_S1271);
    AnisotropicFrame _S1273 = anisotropicFrame(*material_20, _S1272);
    float3  _S1274 = make_float3 (1.0f);
    float3  _S1275 = material_20->sheen;
    float _S1276 = rgb_to_greyscale(material_20->sheen);
    bool _S1277 = _S1276 > 0.0f;
    float sheen_component_3;
    float3  sheen_5;
    float3  view_4;
    float3  scale_6;
    if(_S1277)
    {
        float _S1278 = clamp_1((F32_sqrt(((F32_max((dot_0(_S1272, _S1270)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S1279 = (U32_min((uint(_S1278)), (22U)));
        float least_2 = (F32_sqrt((0.05000000074505806f)));
        float _S1280 = (F32_sqrt((0.10000000149011612f)));
        bool _S1281 = (material_20->velvet) > 0.0f;
        float _S1282 = _slang_select(_S1281, _S1280,least_2);
        float _S1283 = (clamp_1((F32_sqrt(((F32_max((material_20->sheen_roughness), (0.0f)))))), _S1282, 1.0f) - _S1282) / (1.0f - _S1282) * 23.0f;
        uint _S1284 = (U32_min((uint(_S1283)), (22U)));
        uint _S1285 = _S1279 * 24U + _S1284;
        float _S1286 = _S1278 - float(_S1279);
        float _S1287 = _S1283 - float(_S1284);
        uint _S1288 = _S1285 + 24U;
        float a_12 = SHEEN_ALBEDO_0[_S1285] + (SHEEN_ALBEDO_0[_S1288] - SHEEN_ALBEDO_0[_S1285]) * _S1286;
        uint _S1289 = _S1285 + 1U;
        uint _S1290 = _S1288 + 1U;
        float b_10 = SHEEN_ALBEDO_0[_S1289] + (SHEEN_ALBEDO_0[_S1290] - SHEEN_ALBEDO_0[_S1289]) * _S1286;
        float _S1291 = (F32_exp((a_12 + (b_10 - a_12) * _S1287)));
        if(_S1281)
        {
            float a_13 = VELVET_ALBEDO_0[_S1285] + (VELVET_ALBEDO_0[_S1288] - VELVET_ALBEDO_0[_S1285]) * _S1286;
            float b_11 = VELVET_ALBEDO_0[_S1289] + (VELVET_ALBEDO_0[_S1290] - VELVET_ALBEDO_0[_S1289]) * _S1286;
            float _S1292 = a_13 + (b_11 - a_13) * _S1287;
            sheen_component_3 = _S1292;
        }
        else
        {
            sheen_component_3 = _S1291;
        }
        float _S1293 = (F32_min((sheen_component_3), (1.0f)));
        float3  _S1294 = make_float3 (1.0f) - _S1275 * make_float3 (_S1293);
        float _S1295 = rgb_to_greyscale(_S1275);
        float _S1296 = _S1295 * _S1293;
        float3  _S1297 = _S1275 / make_float3 ((F32_max((sheen_component_3), (1.0f))));
        sheen_component_3 = _S1296;
        sheen_5 = _S1297;
        view_4 = _S1270;
        scale_6 = _S1294;
    }
    else
    {
        sheen_component_3 = 0.0f;
        sheen_5 = _S1246;
        view_4 = _S1246;
        scale_6 = _S1274;
    }
    float3  scale_7 = scale_6 * make_float3 (_S1269.toon_scale);
    float toon_view_4;
    float3  toon_axis_4;
    if(_S1251)
    {
        float _S1298 = dot_0(_S1272, _S1270);
        float _S1299 = (F32_acos(((F32_min((_S1298), (1.0f))))));
        if(_S1299 < (_S1269.toon_a))
        {
            toon_scale_3 = 1.0f;
        }
        else
        {
            toon_scale_3 = (F32_max((1.0f - (_S1299 - _S1269.toon_a) / (F32_max((_S1269.toon_s), (0.0000152587890625f)))), (0.0f)));
        }
        if(_S1269.toon_glossy)
        {
            float3  _S1300 = make_float3 (2.0f * _S1298) * _S1272 - _S1270;
            float3  _S1301 = ((((_S1300)) * make_float3(rnorm3df(((_S1300)).x, ((_S1300)).y, ((_S1300)).z))));
            toon_5 = _S1301;
        }
        else
        {
            toon_5 = _S1272;
        }
        toon_view_4 = toon_scale_3;
        toon_axis_4 = toon_5;
    }
    else
    {
        toon_view_4 = 0.0f;
        toon_axis_4 = _S1272;
    }
    float _S1302 = material_20->roughness;
    float _S1303 = _S1273.alphas.x;
    float _S1304 = (F32_sqrt(((F32_min((_S1303), (_S1273.alphas.y))))));
    bool _S1305 = _S1303 > 0.0f;
    float _S1306 = _slang_select(_S1305, _S1304,_S1302);
    float _S1307 = _S1306 * _S1306;
    float _S1308 = (F32_pow((_S1307), (1.81585001945495605f))) * (2.15371990203857422f - 0.73285001516342163f * _S1307) / (1.0f + 1.28094995021820068f * _S1307);
    bool _S1309 = _S1307 > 0.0f;
    float _S1310 = _slang_select(_S1309, _S1308,0.0f);
    float _S1311 = clamp_1(dot_0(_S1272, _S1270), 0.0f, 1.0f);
    float _S1312 = _S1307 * _S1306;
    float _S1313 = (F32_min((1.00064504146575928f - _S1306 * (0.00375499995425344f + _S1311 * (-0.04133399948477745f + _S1311 * (-0.90938502550125122f + _S1311 * 0.35275399684906006f))) - _S1307 * (0.27602800726890564f + _S1311 * (1.27023398876190186f + _S1311 * 0.04740000143647194f)) - _S1312 * (0.31452900171279907f - _S1311 * 0.34830701351165771f) + _S1312 * _S1306 * 0.27229699492454529f), (1.0f)));
    float3  _S1314 = min_1(make_float3 (1.0f) / (make_float3 (1.0f) - material_20->albedo * make_float3 (_S1310)), make_float3 (1.0f / (F32_max((_S1313), (0.0000152587890625f)))));
    AnisotropicFrame _S1315 = _S1273;
    ViewTerms _S1316 = ViewTerms_x24init_0(_S1270, _S1272, &_S1315, scale_7, sheen_component_3, sheen_5, view_4, _S1314, toon_view_4, toon_axis_4);
    if(_S1239)
    {
        _S1240 = true;
    }
    else
    {
        _S1240 = (light_2->density) == 0.0f;
    }
    if(_S1240)
    {
        float3  _S1317 = BSDF(in_dir_11, light_2->dir, smooth_n_5, geometry_n_4, *material_20, eta_i_14, eta_o_14, random_state_15, _S1269, _S1316);
        return _S1317 * light_2->radiance;
    }
    float3  _S1318 = light_2->dir;
    bool _S1319 = (dot_0(geometry_n_4, - in_dir_11) * dot_0(geometry_n_4, light_2->dir)) <= 0.0f;
    float3  _S1320 = neeBSDF(in_dir_11, _S1318, smooth_n_5, *material_20, eta_i_14, eta_o_14, _S1319, light_2->density, true, random_state_15, _S1269, _S1316);
    return _S1320 * light_2->radiance * make_float3 (light_2->density);
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_4, uint random_state_16, bool refracted_4, uint lobe_4, float pdf_9)
{
    SampleBSDF _S1321;
    (&_S1321)->unit_direction = unit_direction_1;
    (&_S1321)->throughput = throughput_4;
    (&_S1321)->random_state = random_state_16;
    (&_S1321)->refracted = refracted_4;
    (&_S1321)->lobe = lobe_4;
    (&_S1321)->pdf = pdf_9;
    return _S1321;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  n_i_8, float n_i_dot_v_6, float alpha_15, BSDFMaterial material_21, HalfTerms lobes_11, float eta_i_15, float eta_o_15, uint random_state_17)
{
    float3  _S1322 = make_float3 (1.0f);
    SampleBSDF _S1323 = SampleBSDF_x24init_0(_S1322, _S1322, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S1323;
    Random _S1324 = pcg(random_state_17);
    Random _S1325 = pcg(_S1324.state);
    (&sample_1)->random_state = _S1325.state;
    float _S1326 = _S1324.value;
    float _S1327 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1326 * _S1326))))));
    float _S1328 = 6.28318548202514648f * _S1325.value;
    float3  _S1329 = tangentToWorld(make_float3 (_S1327 * (F32_cos((_S1328))), _S1324.value, _S1327 * (F32_sin((_S1328)))), n_i_8);
    (&sample_1)->unit_direction = _S1329;
    (&sample_1)->lobe = 4U;
    float3  _S1330 = sheenVelvetBSDF((&sample_1)->unit_direction, n_i_8, alpha_15, material_21, lobes_11);
    (&sample_1)->throughput = _S1330;
    float _S1331 = sheenVelvetPDF(_S1324.value, 0.0f, n_i_dot_v_6, alpha_15, lobes_11, eta_i_15, eta_o_15);
    (&sample_1)->pdf = _S1331;
    return sample_1;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1332 = (F32_sqrt((random_1_0)));
    float _S1333 = 6.28318548202514648f * random_2_0;
    float _S1334 = _S1332 * (F32_cos((_S1333)));
    float _S1335 = _S1332 * (F32_sin((_S1333)));
    float _S1336 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1334 * _S1334 - _S1335 * _S1335))))));
    return make_float3 (_S1334, _S1336, _S1335);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_4, float3  n_i_9, float n_i_dot_v_7, float alpha_16, BSDFMaterial material_22, HalfTerms lobes_12, float eta_i_16, float eta_o_16, uint random_state_18)
{
    float3  _S1337 = make_float3 (1.0f);
    SampleBSDF _S1338 = SampleBSDF_x24init_0(_S1337, _S1337, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S1338;
    Random _S1339 = pcg(random_state_18);
    Random _S1340 = pcg(_S1339.state);
    (&sample_2)->random_state = _S1340.state;
    float3  _S1341 = sampleCosWeightedHemisphere(_S1339.value, _S1340.value);
    bool _S1342 = u_4 < (lobes_12.p_diffuse * lobes_12.translucent_share);
    float _S1343 = _S1341.y;
    float _S1344 = - _S1343;
    float _S1345 = _slang_select(_S1342, _S1344,_S1343);
    float3  _S1346 = tangentToWorld(make_float3 (_S1341.x, _S1345, _S1341.z), n_i_9);
    (&sample_2)->unit_direction = _S1346;
    (&sample_2)->refracted = _S1342;
    (&sample_2)->lobe = 0U;
    float3  _S1347 = diffuseBSDF((&sample_2)->unit_direction, n_i_9, alpha_16, material_22, lobes_12);
    (&sample_2)->throughput = _S1347;
    float _S1348 = diffusePDF(_S1345, 0.0f, n_i_dot_v_7, alpha_16, lobes_12, eta_i_16, eta_o_16);
    (&sample_2)->pdf = _S1348;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF toonSample(float3  n_i_10, float n_i_dot_v_8, float alpha_17, BSDFMaterial material_23, HalfTerms lobes_13, float eta_i_17, float eta_o_17, uint random_state_19)
{
    float3  _S1349 = make_float3 (1.0f);
    SampleBSDF _S1350 = SampleBSDF_x24init_0(_S1349, _S1349, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S1350;
    Random _S1351 = pcg(random_state_19);
    Random _S1352 = pcg(_S1351.state);
    (&sample_3)->random_state = _S1352.state;
    float _S1353 = _S1351.value * lobes_13.toon_norm / 6.28318548202514648f;
    float t_21;
    if(lobes_13.toon_glossy)
    {
        t_21 = (F32_acos((clamp_1(1.0f - _S1353, -1.0f, 1.0f))));
    }
    else
    {
        t_21 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1353)))), (1.0f))))));
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
        float _S1354;
        if(t_21 < (lobes_13.toon_a))
        {
            _S1354 = 1.0f;
        }
        else
        {
            _S1354 = (F32_max((1.0f - (t_21 - lobes_13.toon_a) / (F32_max((lobes_13.toon_s), (0.0000152587890625f)))), (0.0f)));
        }
        float integral_3;
        if(lobes_13.toon_glossy)
        {
            integral_3 = 1.0f - (F32_cos(((F32_min((t_21), (lobes_13.toon_a))))));
        }
        else
        {
            float _S1355 = (F32_sin(((F32_min((t_21), (lobes_13.toon_a))))));
            integral_3 = _S1355 * _S1355 / 2.0f;
        }
        bool _S1356 = t_21 > (lobes_13.toon_a);
        bool _S1357;
        if(_S1356)
        {
            _S1357 = (lobes_13.toon_s) > 0.0f;
        }
        else
        {
            _S1357 = false;
        }
        float integral_4;
        if(_S1357)
        {
            if(lobes_13.toon_glossy)
            {
                float _S1358 = (F32_cos((lobes_13.toon_a)));
                float _S1359 = (F32_cos((t_21)));
                integral_4 = (1.0f + lobes_13.toon_a / lobes_13.toon_s) * (_S1358 - _S1359) - ((F32_sin((t_21))) - t_21 * _S1359 - ((F32_sin((lobes_13.toon_a))) - lobes_13.toon_a * _S1358)) / lobes_13.toon_s;
            }
            else
            {
                float _S1360 = 2.0f * lobes_13.toon_a;
                float _S1361 = (F32_cos((_S1360)));
                float _S1362 = 2.0f * t_21;
                float _S1363 = (F32_cos((_S1362)));
                integral_4 = (1.0f + lobes_13.toon_a / lobes_13.toon_s) * (_S1361 - _S1363) / 4.0f - ((F32_sin((_S1362))) / 8.0f - t_21 * _S1363 / 4.0f - ((F32_sin((_S1360))) / 8.0f - lobes_13.toon_a * _S1361 / 4.0f)) / lobes_13.toon_s;
            }
            float integral_5 = integral_3 + integral_4;
            integral_4 = integral_5;
        }
        else
        {
            integral_4 = integral_3;
        }
        float _S1364 = _S1354 * (F32_sin((t_21)));
        float _S1365;
        if(lobes_13.toon_glossy)
        {
            _S1365 = 1.0f;
        }
        else
        {
            _S1365 = (F32_cos((t_21)));
        }
        float _S1366 = _S1364 * _S1365;
        float _S1367 = (integral_4 - _S1353) / _S1366;
        bool _S1368 = _S1366 > 0.0f;
        float _S1369 = _slang_select(_S1368, _S1367,0.0f);
        float _S1370 = clamp_1(t_21 - _S1369, 0.0f, lobes_13.toon_b);
        int k_1 = k_0 + int(1);
        t_21 = _S1370;
        k_0 = k_1;
    }
    float _S1371 = 6.28318548202514648f * _S1352.value;
    float _S1372 = (F32_sin((t_21)));
    float3  _S1373 = tangentToWorld(make_float3 (_S1372 * (F32_cos((_S1371))), (F32_cos((t_21))), _S1372 * (F32_sin((_S1371)))), lobes_13.toon_axis);
    (&sample_3)->unit_direction = _S1373;
    bool _S1374 = (dot_0(n_i_10, (&sample_3)->unit_direction)) < 0.0f;
    (&sample_3)->refracted = _S1374;
    (&sample_3)->lobe = 6U;
    float3  _S1375 = toonBSDF((&sample_3)->unit_direction, n_i_10, alpha_17, material_23, lobes_13);
    (&sample_3)->throughput = _S1375;
    float _S1376 = toonPDF(dot_0(n_i_10, (&sample_3)->unit_direction), dot_0((&sample_3)->unit_direction, lobes_13.toon_axis), n_i_dot_v_8, alpha_17, lobes_13, eta_i_17, eta_o_17);
    (&sample_3)->pdf = _S1376;
    return sample_3;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_5, float3  n_i_11, float n_i_dot_v_9, float alpha_18, BSDFMaterial material_24, HalfTerms lobes_14, float eta_i_18, float eta_o_18, uint random_state_20)
{
    float3  _S1377 = make_float3 (1.0f);
    SampleBSDF _S1378 = SampleBSDF_x24init_0(_S1377, _S1377, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S1378;
    (&sample_4)->unit_direction = lobes_14.refracted;
    (&sample_4)->random_state = random_state_20;
    (&sample_4)->refracted = true;
    (&sample_4)->lobe = 1U;
    float3  _S1379 = refractBSDF((&sample_4)->unit_direction, n_i_11, alpha_18, material_24, lobes_14);
    (&sample_4)->throughput = _S1379;
    float _S1380 = refractPDF(0.0f, dot_0((&sample_4)->unit_direction, ggx_n_5), n_i_dot_v_9, alpha_18, lobes_14, eta_i_18, eta_o_18);
    (&sample_4)->pdf = _S1380;
    return sample_4;
}

static __device__ float3  reflect_0(float3  i_23, float3  n_14)
{
    return i_23 - make_float3 (2.0f * dot_0(n_14, i_23)) * n_14;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_12, float3  ggx_n_6, float3  n_i_12, float n_i_dot_v_10, float alpha_19, BSDFMaterial material_25, HalfTerms lobes_15, float eta_i_19, float eta_o_19, uint random_state_21)
{
    float3  _S1381 = make_float3 (1.0f);
    SampleBSDF _S1382 = SampleBSDF_x24init_0(_S1381, _S1381, 0U, false, 0U, 0.0f);
    SampleBSDF sample_5 = _S1382;
    float3  _S1383 = reflect_0(in_dir_12, ggx_n_6);
    float3  _S1384 = ((((_S1383)) * make_float3(rnorm3df(((_S1383)).x, ((_S1383)).y, ((_S1383)).z))));
    (&sample_5)->unit_direction = _S1384;
    (&sample_5)->random_state = random_state_21;
    (&sample_5)->lobe = 2U;
    float3  _S1385 = reflectBSDF((&sample_5)->unit_direction, n_i_12, alpha_19, material_25, lobes_15);
    (&sample_5)->throughput = _S1385;
    float _S1386 = reflectPDF(0.0f, 0.0f, n_i_dot_v_10, alpha_19, lobes_15, eta_i_19, eta_o_19);
    (&sample_5)->pdf = _S1386;
    return sample_5;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_13, float3  n_15, BSDFMaterial material_26, float eta_i_20, float eta_o_20, uint random_init_0, float2  screen_space_0, MaterialTerms terms_5, ViewTerms view_terms_6)
{
    uint random_state_22 = random_init_0;
    float3  _S1387 = negate_0(in_dir_13);
    float _S1388 = dot_0(n_15, _S1387);
    float _S1389 = sign_0(_S1388);
    float3  n_i_13 = n_15 * make_float3 (_S1389);
    float _S1390 = (F32_abs((_S1388)));
    float _S1391 = material_26.roughness;
    float _S1392 = _S1391 * _S1391;
    float3  _S1393 = sampleHalfVector(_S1387, n_i_13, _S1392, view_terms_6.frame, &random_state_22);
    HalfTerms _S1394 = precomputeHalf(in_dir_13, _S1393, material_26, eta_i_20, eta_o_20, terms_5, view_terms_6);
    Random _S1395 = pcg(random_state_22);
    random_state_22 = _S1395.state;
    bool _S1396 = (_S1395.value) < (_S1394.p_sheen_velvet);
    if(_S1396)
    {
        SampleBSDF _S1397 = sheenVelvetSample(n_i_13, _S1390, _S1392, material_26, _S1394, eta_i_20, eta_o_20, random_state_22);
        return _S1397;
    }
    float _S1398 = _S1395.value - _S1394.p_sheen_velvet;
    bool _S1399 = _S1398 < (_S1394.p_diffuse);
    if(_S1399)
    {
        SampleBSDF _S1400 = diffuseSample(_S1398, n_i_13, _S1390, _S1392, material_26, _S1394, eta_i_20, eta_o_20, random_state_22);
        return _S1400;
    }
    bool _S1401 = _S1398 < (_S1394.p_diffuse + _S1394.p_toon);
    if(_S1401)
    {
        SampleBSDF _S1402 = toonSample(n_i_13, _S1390, _S1392, material_26, _S1394, eta_i_20, eta_o_20, random_state_22);
        return _S1402;
    }
    bool _S1403 = (_S1398 - _S1394.p_toon) < (_S1394.p_diffuse + _S1394.p_refract);
    if(_S1403)
    {
        SampleBSDF _S1404 = refractSample(_S1393, n_i_13, _S1390, _S1392, material_26, _S1394, eta_i_20, eta_o_20, random_state_22);
        return _S1404;
    }
    SampleBSDF _S1405 = reflectSample(in_dir_13, _S1393, n_i_13, _S1390, _S1392, material_26, _S1394, eta_i_20, eta_o_20, random_state_22);
    return _S1405;
}

__device__ bool withinInverseFootprint(float pdf_10, bool diffuse_0, float prev_cos_0, float distance_5, float threshold_1)
{
    bool _S1406 = pdf_10 > 0.0f;
    bool _S1407;
    if(_S1406)
    {
        if(diffuse_0)
        {
            _S1407 = true;
        }
        else
        {
            _S1407 = (pdf_10 * prev_cos_0 / (distance_5 * distance_5) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S1407 = false;
    }
    return _S1407;
}

__device__ bool roughLobe(float pdf_11, bool diffuse_1, float roughness_1)
{
    bool _S1408 = pdf_11 > 0.0f;
    bool _S1409;
    if(_S1408)
    {
        if(diffuse_1)
        {
            _S1409 = true;
        }
        else
        {
            _S1409 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S1409 = false;
    }
    return _S1409;
}

static __device__ bool passesLayer_0(uint layers_0, bool refracting_0, bool passed_0)
{
    bool _S1410 = layers_0 > 1U;
    bool _S1411;
    if(_S1410)
    {
        _S1411 = refracting_0 != passed_0;
    }
    else
    {
        _S1411 = false;
    }
    return _S1411;
}

static __device__ float widened_0(float spread_1, float pdf_12, bool delta_0)
{
    float _S1412 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * pdf_12))))), (3.14159274101257324f)));
    bool _S1413 = !delta_0;
    float _S1414 = _slang_select(_S1413, _S1412,0.0f);
    return spread_1 + _S1414;
}

static __device__ bool boundsVolume_0(FKSurface * surface_10)
{
    return surface_10->encloses;
}

static __device__ bool leavesInFront_0(float3  face_2, float3  dir_15, float3  g_3)
{
    return ((dot_0(dir_15, g_3)) > 0.0f) == ((dot_0(g_3, face_2)) > 0.0f);
}

static __device__ Shift walk_0(Domain * dom_7, Reservoir * r_8, bool replay_2, float scale_8, Selection * sel_7)
{
    float spread_2;
    bool turned_1;
    bool is_inside_5;
    bool viewed_0;
    bool _S1415;
    float density_2;
    float threshold_2;
    float width_3;
    float sky_pdf_0;
    float wavelength_2;
    uint b_12;
    uint layer_0;
    float3  throughput_5;
    float3  chain_throughput_0;
    TreeSample light_3;
    int _S1416;
    Shift ended_0;
    float sky_pdf_1;
    float spread_3;
    float width_4;
    uint b_13;
    float3  _S1417 = make_float3 (0.0f);
    Shift _S1418 = Shift_x24init_0(_S1417, 0.0f);
    uint _S1419 = r_8->path;
    uint _S1420 = extractBits_0(r_8->path, 0U, 5U);
    uint _S1421 = extractBits_0(_S1419, 5U, 5U);
    uint _S1422 = extractBits_0(_S1419, 10U, 2U);
    uint _S1423 = extractBits_0(_S1419, 12U, 3U);
    bool passes_0;
    if(replay_2)
    {
        bool _S1424 = _S1423 >= 3U;
        uint _S1425 = _slang_select(_S1424, 1U,0U);
        uint _S1426 = _S1420 + _S1425;
        uint _S1427 = (fcptMaxBounces());
        passes_0 = _S1426 > _S1427;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1418;
    }
    uint _S1428 = _S1421 - 1U;
    bool _S1429 = _S1423 == 3U;
    uint _S1430 = _slang_select(_S1429, 1U,0U);
    uint _S1431 = _S1420 + _S1430;
    bool _S1432 = _S1422 == 0U;
    uint _S1433 = _slang_select(_S1432, _S1431,_S1428);
    FKHit _S1434 = (fcptReservoirHit((*r_8)));
    float3  _S1435 = dom_7->x0;
    float3  _S1436 = dom_7->x1 - dom_7->x0;
    float3  _S1437 = ((((_S1436)) * make_float3(rnorm3df(((_S1436)).x, ((_S1436)).y, ((_S1436)).z))));
    FKRay _S1438 = Ray_x24init_0(dom_7->x1, _S1437);
    FKRay ray_2 = _S1438;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1417;
    float3  throughput_6 = make_float3 (1.0f);
    float3  weight_1 = throughput_6;
    float3  glowed_0 = _S1417;
    float3  extinction_in_0 = _S1417;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1439 = dom_7->spread;
    float _S1440 = dom_7->width;
    float _S1441 = length_0(_S1436);
    NEEVertex _S1442 = NEEVertex_x24init_0(true, 0.0f, _S1417, _S1417, _S1417);
    NEEVertex nee_vertex_0 = _S1442;
    Vertex _S1443 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S1443;
    Reservoir _S1444 = (Reservoir{});
    Reservoir chain_0 = _S1444;
    uint _S1445 = r_8->seed;
    (&chain_0)->seed = r_8->seed;
    (&ray_2)->origin = _S1435;
    (&hit_4)->distance = _S1441;
    FKMedium _S1446 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1447 = filling_2;
    bool _S1448 = (fcptVaryingUsed());
    uint _S1449 = _slang_select(_S1448, _S1447,4294967295U);
    filling_2 = _S1449;
    scatter_in_0 = _S1446.scatter;
    extinction_in_0 = _S1446.extinction;
    g_in_0 = _S1446.g;
    Reservoir _S1450 = chain_0;
    uint _S1451 = filling_2;
    for(;;)
    {
        bool _S1452 = (fcptVaryingUsed());
        if(_S1452)
        {
            passes_0 = _S1451 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1453 = (fcptMajorant((_S1451)));
            spread_2 = _S1453;
        }
        else
        {
            spread_2 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_2)
        {
            turned_1 = 4294967295U == _S1433;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1422 == 1U;
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
            ended_0 = _S1418;
            sky_pdf_0 = 0.0f;
            spread_2 = _S1439;
            width_3 = _S1440;
            density_2 = 1.0f;
            throughput_5 = throughput_6;
            b_12 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1454 = (&prev_0)->rough;
        if(_S1454)
        {
            turned_1 = !(spread_2 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S1455 = stream(_S1445, 384U);
        uint tracking_0 = _S1455;
        weight_1 = throughput_6;
        glowed_0 = _S1417;
        b_12 = 4294967295U;
        throughput_5 = throughput_6;
        density_2 = 1.0f;
        threshold_2 = _S1439;
        width_3 = _S1440;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1416 = int(1);
                break;
            }
            uint _S1456 = b_12 + 320U;
            bool _S1457 = b_12 == 4294967295U;
            uint _S1458 = _slang_select(_S1457, 384U,_S1456);
            uint _S1459 = stream(_S1445, _S1458);
            Random _S1460 = pcg(_S1459);
            float _S1461 = freeFlight_0(_S1460.value, spread_2);
            if(passes_0)
            {
                float3  _S1462 = (&ray_2)->origin;
                float3  _S1463 = (&ray_2)->unit_direction;
                float _S1464 = (&hit_4)->distance;
                uint _S1465 = _slang_select(_S1457, 0U,b_12);
                uint _S1466 = (&prev_0)->lobe;
                uint _S1467 = _slang_select(_S1457, 3U,_S1466);
                float _S1468 = (fcptTrackMedium((_S1451), (_S1462), (_S1463), (_S1464), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1465), (_S1467), (_S1457)));
                wavelength_2 = _S1468;
            }
            else
            {
                wavelength_2 = _S1461;
            }
            bool _S1469 = !(wavelength_2 < ((&hit_4)->distance));
            if(_S1469)
            {
                _S1416 = int(1);
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
                float3  _S1470 = throughput_5 * glowed_0 / make_float3 (density_2);
                float3  _S1471 = sel_7->glow + _S1470;
                sel_7->glow = _S1471;
            }
            else
            {
            }
            glowed_0 = _S1417;
            uint b_14 = b_12 + 1U;
            float3  _S1472 = (&ray_2)->origin + make_float3 (wavelength_2) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1472;
            float3  _S1473 = flightWeight_0(scatter_in_0, extinction_in_0, spread_2, wavelength_2, true);
            float3  _S1474 = weight_1;
            float3  _S1475 = _slang_select(passes_0, _S1474,_S1473);
            float3  throughput_7 = throughput_5 * _S1475;
            uint _S1476 = stream(_S1445, b_14 + 320U);
            tracking_0 = _S1476;
            weight_1 = throughput_6;
            float width_5 = width_3 + threshold_2 * wavelength_2;
            float _S1477 = threshold_2 + 3.14159274101257324f;
            bool _S1478 = scatterSampled_0(replay_2, b_14, _S1433, passes_0);
            TreeSample _S1479 = TreeSample_x24init_0(_S1417, _S1417, 0.0f, 0U);
            if(_S1478)
            {
                float3  _S1480 = (&ray_2)->origin;
                float3  _S1481 = (&ray_2)->unit_direction;
                float3  _S1482 = (&ray_2)->unit_direction;
                uint _S1483 = stream(_S1445, b_14 + 64U);
                float3  _S1484 = extinction_in_0;
                float3  _S1485 = extinction_in_0;
                uint2  _S1486 = make_uint2 (_S1451);
                float3  _S1487 = (&ray_2)->unit_direction;
                uint _S1488 = arrivalLobe_0(b_14, (&prev_0)->lobe);
                FKHit _S1489 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1490 = _S1489;
                ShadowContext _S1491 = ShadowContext_x24init_0(_S1484, _S1485, _S1486, _S1487, b_14, _S1488, false, wavelength_2, width_5, &_S1490, false);
                ShadowContext _S1492 = _S1491;
                TreeSample _S1493 = sampleLightTree_0(_S1480, _S1481, _S1482, 0.0f, true, _S1483, &_S1492);
                light_3 = _S1493;
            }
            else
            {
                light_3 = _S1479;
            }
            float _S1494 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S1495 = (fcptMaxBounces());
            bool _S1496 = b_14 < _S1495;
            if(_S1496)
            {
                is_inside_5 = (light_3.density) > 0.0f;
            }
            else
            {
                is_inside_5 = false;
            }
            float _S1497 = _slang_select(is_inside_5, _S1494,0.0f);
            float3  _S1498 = throughput_7 * light_3.radiance;
            float _S1499 = powerHeuristic(light_3.density, _S1497);
            float3  _S1500 = _S1498 * make_float3 (_S1494 * _S1499);
            float3  _S1501 = _slang_select(_S1478, _S1500,_S1417);
            if(replay_2)
            {
                viewed_0 = b_14 == _S1433;
            }
            else
            {
                viewed_0 = false;
            }
            if(viewed_0)
            {
                bool _S1502 = _S1422 == 2U;
                if(_S1502)
                {
                    float _S1503 = resamplingTarget(_S1501);
                    passes_0 = _S1503 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1504 = Shift_x24init_0(_S1501, 1.0f);
                    _S1416 = int(0);
                    ended_0 = _S1504;
                    spread_2 = _S1477;
                    wavelength_2 = width_5;
                    chain_throughput_0 = throughput_7;
                    layer_0 = b_14;
                    break;
                }
                _S1416 = int(0);
                ended_0 = _S1418;
                spread_2 = _S1477;
                wavelength_2 = width_5;
                chain_throughput_0 = throughput_7;
                layer_0 = b_14;
                break;
            }
            bool _S1505 = !replay_2;
            if(_S1505)
            {
                Reservoir candidate_3 = _S1450;
                uint _S1506 = extractBits_0(_S1450.path, 10U, 2U);
                bool _S1507 = _S1506 == 1U;
                if(_S1507)
                {
                    float3  _S1508 = safeDivide(_S1501, _S1417);
                    (&candidate_3)->radiance = _S1508;
                }
                else
                {
                    uint _S1509 = insertBits_0(0U, b_14 + 1U, 5U, 5U);
                    uint _S1510 = insertBits_0(_S1509, 2U, 10U, 2U);
                    (&candidate_3)->path = _S1510;
                }
                Reservoir _S1511 = withEnd(candidate_3, 0U, b_14, _S1501);
                offer(sel_7, _S1511, _S1501 * make_float3 (scale_8) / make_float3 (density_2));
                float _S1512 = survivalProbability(abs_0(throughput_7), density_2);
                uint _S1513 = stream(_S1445, b_14 + 128U);
                Random _S1514 = pcg(_S1513);
                bool _S1515 = _S1512 < (_S1514.value);
                if(_S1515)
                {
                    _S1415 = true;
                }
                else
                {
                    uint _S1516 = (fcptMaxBounces());
                    _S1415 = b_14 >= _S1516;
                }
                if(_S1415)
                {
                    _S1416 = int(0);
                    ended_0 = _S1418;
                    spread_2 = _S1477;
                    wavelength_2 = width_5;
                    chain_throughput_0 = throughput_7;
                    layer_0 = b_14;
                    break;
                }
                float _S1517 = density_2 * _S1512;
                density_2 = _S1517;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1518 = stream(_S1445, b_14);
            float3  _S1519 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1518, &phase_pdf_0);
            (&ray_2)->unit_direction = _S1519;
            NEEVertex _S1520 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S1417, (&ray_2)->origin);
            nee_vertex_0 = _S1520;
            Vertex _S1521 = scatteredVertex_0(false);
            prev_0 = _S1521;
            float _S1522 = (&prev_0)->pdf;
            FKRay _S1523 = ray_2;
            FKHit _S1524 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1525 = (fcptTraverseInstanceBVH((_S1523), (true), (4.294967296e+09f), (false), (_S1524), (false)));
            hit_4 = _S1525;
            b_12 = b_14;
            throughput_5 = throughput_7;
            threshold_2 = _S1477;
            width_3 = width_5;
            sky_pdf_0 = _S1522;
        }
        if(_S1416 != int(1))
        {
            width_3 = wavelength_2;
            throughput_5 = chain_throughput_0;
            b_12 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1418;
        spread_2 = threshold_2;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1526 = b_12 == 4294967295U;
    bool _S1527 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1527)
    {
        bool _S1528 = !(&nee_vertex_0)->none;
        float _S1529 = _slang_select(_S1528, sky_pdf_0,0.0f);
        float _S1530 = escapeWeight_0(_S1529, (&ray_2)->unit_direction);
        float3  _S1531 = environment_0((&ray_2)->unit_direction, b_12, (&prev_0)->lobe);
        float3  _S1532 = throughput_5 * _S1531;
        if(replay_2)
        {
            bool _S1533 = b_12 == _S1433;
            if(_S1533)
            {
                passes_0 = _S1422 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S1532 * make_float3 (_S1530) / make_float3 (r_8->jac), density_2 / r_8->jac);
            }
            if(_S1432)
            {
                passes_0 = _S1429;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_12 == _S1420;
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
                return Shift_x24init_0(_S1532 * make_float3 (_S1530), 1.0f);
            }
            return _S1418;
        }
        Reservoir candidate_4 = chain_0;
        uint _S1534 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1535 = _S1534 == 1U;
        if(_S1535)
        {
            uint _S1536 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S1537 = _S1536 == b_12;
            float _S1538 = _slang_select(_S1537, 1.0f,_S1530);
            float3  _S1539 = safeDivide(_S1532 * make_float3 (_S1538), _S1417);
            (&candidate_4)->radiance = _S1539;
        }
        else
        {
            bool _S1540 = (&prev_0)->rough;
            if(_S1540)
            {
                uint _S1541 = insertBits_0(0U, b_12 + 1U, 5U, 5U);
                uint _S1542 = insertBits_0(_S1541, 3U, 10U, 2U);
                uint _S1543 = insertBits_0(_S1542, (&prev_0)->lobe, 15U, 3U);
                bool _S1544 = (&prev_0)->inside;
                uint _S1545 = _slang_select(_S1544, 1U,0U);
                uint _S1546 = insertBits_0(_S1543, _S1545, 22U, 1U);
                (&candidate_4)->path = _S1546;
                (&candidate_4)->jac = (&prev_0)->pdf;
                (&candidate_4)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S1547 = _S1532 * make_float3 (_S1530);
        Reservoir _S1548 = withEnd(candidate_4, 3U, b_12, _S1547);
        offer(sel_7, _S1548, _S1547 * make_float3 (scale_8) / make_float3 (density_2));
        return _S1418;
    }
    float3  _S1549 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S1549;
    bool _S1550 = (fcptVaryingUsed());
    if(_S1550)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1551 = !replay_2;
        if(_S1551)
        {
            float3  _S1552 = throughput_5 * glowed_0 / make_float3 (density_2);
            float3  _S1553 = sel_7->glow + _S1552;
            sel_7->glow = _S1553;
        }
        float3  _S1554 = throughput_5 * weight_1;
        throughput_5 = _S1554;
    }
    else
    {
        float3  _S1555 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
        float3  _S1556 = throughput_5 * _S1555;
        throughput_5 = _S1556;
    }
    float _S1557 = width_3 + spread_2 * (&hit_4)->distance;
    uint _S1558 = b_12 + 1U;
    b_12 = _S1558;
    layer_0 = 0U;
    width_3 = _S1557;
    passes_0 = false;
    threshold_2 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    wavelength_2 = 0.0f;
    chain_throughput_0 = _S1417;
    float3  reconnection_0 = _S1417;
    viewed_0 = _S1526;
    for(;;)
    {
        bool _S1559 = ((&hit_4)->is_point_light) == 1U;
        if(replay_2)
        {
            _S1415 = _S1422 == 1U;
        }
        else
        {
            _S1415 = false;
        }
        bool _S1560;
        if(_S1415)
        {
            _S1560 = b_12 == _S1421;
        }
        else
        {
            _S1560 = false;
        }
        bool _S1561;
        if(_S1560)
        {
            bool _S1562 = ((&hit_4)->instance_index) != (_S1434.instance_index);
            if(_S1562)
            {
                _S1561 = true;
            }
            else
            {
                _S1561 = ((&hit_4)->triangle_index) != (_S1434.triangle_index);
            }
        }
        else
        {
            _S1561 = false;
        }
        if(_S1561)
        {
            return _S1418;
        }
        FKMedium _S1563 = Medium_x24init_0(_S1417, _S1417, 0.0f);
        BSDFMaterial _S1564 = Material_x24init_0(_S1417, _S1417, 0.0f, 0.0f, 0.0f, 0.0f, _S1417, throughput_6, 1.0f, _S1417, _S1417, 0.5f, 0.0f, 0.0f, _S1417, 0.0f, _S1417, 0.0f);
        FKMedium _S1565 = _S1563;
        FKSurface _S1566 = Surface_x24init_0(_S1417, _S1417, 0.0f, &_S1564, false, 0U, 1.0f, false, &_S1565, 4294967295U, _S1417);
        bool _S1567 = !_S1559;
        bool scatter_2;
        bool is_inside_6;
        float geometry_density_2;
        float3  throughput_8;
        FKSurface surface_11;
        if(_S1567)
        {
            uint _S1568 = stream(_S1445, b_12);
            uint _S1569 = arrivalLobe_0(b_12, (&prev_0)->lobe);
            FKSurface _S1570 = (fcptSurfaceAtPath((hit_4), ((&ray_2)->origin), (_S1568), (width_3), (layer_0), (b_12), (_S1569), ((&ray_2)->unit_direction)));
            bool _S1571 = !passes_0;
            FKSurface _S1572 = _S1570;
            FKSurface _S1573 = emitting_0(&_S1572, _S1571);
            uint _S1574 = stream(_S1445, b_12 + 256U);
            Random _S1575 = pcg(_S1574);
            FKSurface _S1576 = _S1573;
            FKSurface _S1577 = uncovered_0(&_S1576, _S1575.value);
            float _S1578 = facingSign(_S1577.material.transmission, _S1577.geometry_n, (&ray_2)->unit_direction);
            bool _S1579 = _S1578 < 0.0f;
            bool _S1580 = (_S1577.material.transmission) > 0.0f;
            if(_S1580)
            {
                bool _S1581 = arrivesBehind_0((&ray_2)->unit_direction, _S1577.geometry_n);
                scatter_2 = _S1581;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1582 = _S1577;
            FKSurface _S1583 = facingRay_0(&_S1582, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S1584 = arrivesBehind_0((&ray_2)->unit_direction, _S1583.geometry_n);
                is_inside_6 = _S1584;
            }
            else
            {
                is_inside_6 = scatter_2;
            }
            if(is_inside_6)
            {
                float3  _S1585 = beerLambert((&hit_4)->distance, _S1583.material.absorption);
                float3  _S1586 = throughput_5 * _S1585;
                throughput_8 = _S1586;
            }
            else
            {
                throughput_8 = throughput_5;
            }
            bool _S1587 = !_S1583.skip;
            float geometry_density_3 = geometryDensity(_S1583.geometry_n, (&ray_2)->unit_direction, (&hit_4)->distance);
            bool _S1588 = b_12 == _S1558;
            if(_S1588)
            {
                float _S1589 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S1589;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            float _S1590 = geometry_density_2;
            scatter_2 = _S1587;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S1590;
            surface_11 = _S1583;
            turned_1 = _S1579;
        }
        else
        {
            scatter_2 = false;
            geometry_density_2 = 0.0f;
            surface_11 = _S1566;
            throughput_8 = throughput_5;
            is_inside_6 = is_inside_5;
        }
        bool _S1591 = withinFootprint(scatter_2, (&prev_0)->rough, (&prev_0)->pdf, geometry_density_2, threshold_2);
        FKSurface _S1592 = surface_11;
        FKSurface _S1593 = surface_11;
        float _S1594 = dot_0(surface_11.smooth_n, - (&ray_2)->unit_direction);
        bool _S1595 = (fcptDispersionUsed());
        bool _S1596;
        if(_S1595)
        {
            _S1596 = wavelength_2 == 0.0f;
        }
        else
        {
            _S1596 = false;
        }
        bool _S1597;
        if(_S1596)
        {
            _S1597 = scatter_2;
        }
        else
        {
            _S1597 = false;
        }
        bool _S1598;
        if(_S1597)
        {
            bool _S1599 = dispersive(_S1592.material);
            _S1598 = _S1599;
        }
        else
        {
            _S1598 = false;
        }
        float3  throughput_9;
        if(_S1598)
        {
            uint _S1600 = stream(_S1445, 512U);
            Random _S1601 = pcg(_S1600);
            float2  _S1602 = sampleWavelength(_S1601.value);
            float _S1603 = _S1602.x;
            float3  _S1604 = wavelengthWeights(_S1603);
            float3  _S1605 = throughput_8 * (_S1604 / make_float3 (_S1602.y));
            wavelength_2 = _S1603;
            throughput_9 = _S1605;
        }
        else
        {
            throughput_9 = throughput_8;
        }
        BSDFMaterial refractive_0 = _S1592.material;
        float _S1606 = dispersedIor(_S1592.material.ior, _S1592.material.dispersion, wavelength_2);
        bool _S1607 = wavelength_2 > 0.0f;
        float _S1608 = _slang_select(_S1607, _S1606,_S1592.material.ior);
        (&refractive_0)->ior = _S1608;
        float2  _S1609 = vertexEta(refractive_0, _S1594);
        bool _S1610;
        if(scatter_2)
        {
            bool _S1611 = neeDecision(_S1592.material, _S1594, _S1609.x, _S1609.y);
            _S1610 = _S1611;
        }
        else
        {
            _S1610 = false;
        }
        bool _S1612;
        if(passes_0)
        {
            _S1612 = true;
        }
        else
        {
            _S1612 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1612)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1610;
        }
        bool _S1613 = (fcptHairUsed());
        bool _S1614;
        if(_S1613)
        {
            float3  _S1615 = surface_11.hair;
            _S1614 = (dot_0(_S1615, _S1615)) > 0.0f;
        }
        else
        {
            _S1614 = false;
        }
        bool _S1616;
        if(_S1614)
        {
            _S1616 = true;
        }
        else
        {
            BSDFMaterial _S1617 = _S1592.material;
            bool _S1618 = isTranslucent_0(&_S1617);
            _S1616 = _S1618;
        }
        bool _S1619;
        if(_S1616)
        {
            _S1619 = true;
        }
        else
        {
            bool _S1620 = (_S1592.material.transmission) > 0.0f;
            if(_S1620)
            {
                uint _S1621 = (fcptLayers((hit_4)));
                _S1619 = _S1621 == 1U;
            }
            else
            {
                _S1619 = false;
            }
        }
        float3  emission_0;
        if(_S1559)
        {
            float3  _S1622 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1622;
        }
        else
        {
            emission_0 = _S1592.material.emissive;
        }
        float _S1623 = rgb_to_greyscale(emission_0);
        bool _S1624 = _S1623 > 0.0f;
        float3  emission_1;
        if(_S1624)
        {
            NEEVertex _S1625 = nee_vertex_0;
            FKHit _S1626 = hit_4;
            float _S1627 = emissionWeight_0(&_S1625, &_S1626, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1627);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1628;
        if(replay_2)
        {
            _S1628 = _S1422 == 1U;
        }
        else
        {
            _S1628 = false;
        }
        bool _S1629;
        if(_S1628)
        {
            _S1629 = b_12 > _S1421;
        }
        else
        {
            _S1629 = false;
        }
        bool _S1630;
        if(_S1629)
        {
            _S1630 = b_12 == _S1420;
        }
        else
        {
            _S1630 = false;
        }
        bool _S1631;
        if(_S1630)
        {
            bool _S1632 = _S1423 == 1U;
            if(_S1632)
            {
                _S1631 = true;
            }
            else
            {
                _S1631 = _S1423 == 2U;
            }
        }
        else
        {
            _S1631 = false;
        }
        if(_S1631)
        {
            bool _S1633 = _S1559 != (_S1423 == 2U);
            if(_S1633)
            {
                return _S1418;
            }
            return Shift_x24init_0(throughput_9 * emission_1 / make_float3 (r_8->jac), density_2 / r_8->jac);
        }
        uint _S1634 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1635 = _S1634 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1636 = insertBits_0(0U, b_12, 5U, 5U);
        uint _S1637 = insertBits_0(_S1636, 1U, 10U, 2U);
        uint _S1638 = insertBits_0(_S1637, (&prev_0)->lobe, 15U, 3U);
        bool _S1639 = (&prev_0)->inside;
        uint _S1640 = _slang_select(_S1639, 1U,0U);
        uint _S1641 = insertBits_0(_S1638, _S1640, 22U, 1U);
        (&here_0)->path = _S1641;
        uint _S1642 = (&here_0)->path;
        uint _S1643 = _slang_select(_S1607, 1U,0U);
        uint _S1644 = insertBits_0(_S1642, _S1643, 23U, 1U);
        (&here_0)->path = _S1644;
        float _S1645 = (&prev_0)->pdf * geometry_density_2;
        (&here_0)->jac = _S1645;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1646;
        if(replay_2)
        {
            _S1646 = _S1422 == 1U;
        }
        else
        {
            _S1646 = false;
        }
        bool _S1647;
        if(_S1646)
        {
            _S1647 = b_12 == _S1421;
        }
        else
        {
            _S1647 = false;
        }
        bool _S1648 = b_12 == _S1433;
        bool _S1649;
        if(_S1648)
        {
            bool _S1650 = !scatter_2;
            if(_S1650)
            {
                _S1649 = true;
            }
            else
            {
                bool _S1651 = _S1422 != 1U;
                if(_S1651)
                {
                    _S1649 = _S1422 != 3U;
                }
                else
                {
                    _S1649 = false;
                }
            }
        }
        else
        {
            _S1649 = false;
        }
        bool _S1652;
        if(_S1649)
        {
            _S1652 = _S1422 == 2U;
        }
        else
        {
            _S1652 = false;
        }
        bool _S1653;
        if(_S1652)
        {
            _S1653 = !_S1591;
        }
        else
        {
            _S1653 = false;
        }
        bool _S1654;
        if(_S1653)
        {
            _S1654 = _S1423 != 4U;
        }
        else
        {
            _S1654 = false;
        }
        bool _S1655 = _S1421 == _S1420;
        bool _S1656;
        if(_S1655)
        {
            _S1656 = _S1423 == 0U;
        }
        else
        {
            _S1656 = false;
        }
        bool _S1657;
        if(_S1656)
        {
            _S1657 = ((&hit_4)->instance_index) == (_S1434.instance_index);
        }
        else
        {
            _S1657 = false;
        }
        bool _S1658;
        if(_S1657)
        {
            _S1658 = ((&hit_4)->triangle_index) == (_S1434.triangle_index);
        }
        else
        {
            _S1658 = false;
        }
        bool _S1659;
        if(_S1658)
        {
            _S1659 = _S1591;
        }
        else
        {
            _S1659 = false;
        }
        bool _S1660 = _slang_select(_S1647, _S1659,_S1654);
        bool _S1661;
        if(nee_0)
        {
            _S1661 = _slang_select(replay_2, _S1660,scatter_2);
        }
        else
        {
            _S1661 = false;
        }
        TreeSample _S1662 = TreeSample_x24init_0(_S1417, _S1417, 0.0f, 0U);
        uint2  _S1663 = make_uint2 (0U);
        float2  _S1664 = make_float2 (0.0f);
        FKHit _S1665 = Hit_x24init_0(_S1664, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1666 = _S1665;
        ShadowContext _S1667 = ShadowContext_x24init_0(_S1417, _S1417, _S1663, _S1417, 0U, 0U, false, 0.0f, 0.0f, &_S1666, false);
        ShadowContext context_5;
        if(nee_0)
        {
            uint _S1668 = arrivalLobe_0(b_12, (&prev_0)->lobe);
            FKMedium _S1669 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1670 = surface_11;
            FKHit _S1671 = hit_4;
            FKMedium _S1672 = _S1669;
            ShadowContext _S1673 = shadowContext_0(&_S1670, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_12, _S1668, (&hit_4)->distance, width_3, &_S1671, _S1614, &_S1672);
            context_5 = _S1673;
        }
        else
        {
            context_5 = _S1667;
        }
        float3  throughput_10;
        float3  lit_0;
        if(_S1661)
        {
            float3  _S1674 = (&ray_2)->origin;
            if(_S1614)
            {
                throughput_10 = _S1417;
            }
            else
            {
                throughput_10 = _S1593.smooth_n;
            }
            FKSurface _S1675 = surface_11;
            uint _S1676 = stream(_S1445, b_12 + 64U);
            ShadowContext _S1677 = context_5;
            TreeSample _S1678 = sampleLightTree_0(_S1674, throughput_10, surface_11.geometry_n, surface_11.geometry_offset, _S1619, _S1676, &_S1677);
            bool _S1679 = any_1((_S1678.radiance) != _S1417);
            if(_S1679)
            {
                if(_S1614)
                {
                    uint _S1680 = (fcptMaxBounces());
                    bool _S1681 = b_12 < _S1680;
                    FKSurface _S1682 = surface_11;
                    TreeSample _S1683 = _S1678;
                    float3  _S1684 = hairLight_0(&_S1682, (&ray_2)->unit_direction, &_S1683, _S1681);
                    lit_0 = _S1684;
                }
                else
                {
                    float _S1685 = _S1609.x;
                    float _S1686 = _S1609.y;
                    uint _S1687 = (fcptMaxBounces());
                    bool _S1688 = b_12 < _S1687;
                    TreeSample _S1689 = _S1678;
                    BSDFMaterial _S1690 = _S1592.material;
                    float3  _S1691 = lightBSDF_0((&ray_2)->unit_direction, &_S1689, _S1593.smooth_n, _S1675.geometry_n, &_S1690, _S1685, _S1686, _S1688, surface_11.random_state);
                    lit_0 = _S1691;
                }
            }
            else
            {
                lit_0 = _S1417;
            }
            light_3 = _S1678;
        }
        else
        {
            light_3 = _S1662;
            lit_0 = _S1417;
        }
        bool viewed_1;
        bool refracted_5;
        bool wrong_side_0;
        bool _S1692;
        bool _S1693;
        float density_3;
        if(_S1647)
        {
            bool _S1694 = !_S1591;
            if(_S1694)
            {
                return _S1418;
            }
            uint _S1695 = extractBits_0(_S1419, 23U, 1U);
            bool _S1696 = _S1607 != (_S1695 == 1U);
            if(_S1696)
            {
                return _S1418;
            }
            float3  throughput_11 = throughput_9 * make_float3 (geometry_density_2);
            float density_4 = density_2 * geometry_density_2;
            if(_S1655)
            {
                viewed_1 = _S1423 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                return Shift_x24init_0(throughput_11 * emission_1 / make_float3 (r_8->jac), density_4 / r_8->jac);
            }
            if(_S1655)
            {
                refracted_5 = _S1423 == 0U;
            }
            else
            {
                refracted_5 = false;
            }
            if(refracted_5)
            {
                bool _S1697 = !nee_0;
                if(_S1697)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1698 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1698 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1418;
                }
                return Shift_x24init_0(throughput_11 * lit_0 / make_float3 (r_8->jac), density_4 / r_8->jac);
            }
            if(_S1655)
            {
                wrong_side_0 = _S1423 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1699 = !nee_0;
                if(_S1699)
                {
                    return _S1418;
                }
                float _S1700 = environmentPdf_0(r_8->dir);
                float3  _S1701 = skyBSDF((&ray_2)->unit_direction, r_8->dir, surface_11, _S1609, is_inside_6, _S1700, surface_11.random_state);
                return Shift_x24init_0(throughput_11 * _S1701 * r_8->radiance / make_float3 (r_8->jac), density_4 / r_8->jac);
            }
            uint _S1702 = extractBits_0(_S1419, 21U, 1U);
            bool _S1703 = nee_0 != (_S1702 == 1U);
            if(_S1703)
            {
                return _S1418;
            }
            throughput_10 = throughput_11;
            density_3 = density_4;
        }
        else
        {
            if(replay_2)
            {
                viewed_1 = _S1648;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1704 = !scatter_2;
                if(_S1704)
                {
                    refracted_5 = true;
                }
                else
                {
                    bool _S1705 = _S1422 != 1U;
                    if(_S1705)
                    {
                        refracted_5 = _S1422 != 3U;
                    }
                    else
                    {
                        refracted_5 = false;
                    }
                }
            }
            else
            {
                refracted_5 = false;
            }
            if(refracted_5)
            {
                bool _S1706 = _S1422 == 2U;
                if(_S1706)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1591;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1423 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1614)
                    {
                        return _S1418;
                    }
                    uint _S1707 = stream(_S1445, b_12 + 448U);
                    FKRay _S1708 = ray_2;
                    FKSurface _S1709 = surface_11;
                    ShadowContext _S1710 = context_5;
                    SkySample _S1711 = sampleSky_0(&_S1708, &_S1709, _S1609, is_inside_6, _S1707, surface_11.random_state, &_S1710);
                    return Shift_x24init_0(throughput_9 * _S1711.color, 1.0f);
                }
                if(_S1706)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1591;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1712 = rgb_to_greyscale(light_3.radiance);
                    bool _S1713 = !(_S1712 > 0.0f);
                    if(_S1713)
                    {
                        return _S1418;
                    }
                    return Shift_x24init_0(throughput_9 * lit_0, 1.0f);
                }
                if(_S1432)
                {
                    passes_0 = _S1423 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1559;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_9 * emission_1, 1.0f);
                }
                if(_S1432)
                {
                    passes_0 = _S1423 == 1U;
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
                    passes_0 = !_S1591;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_9 * emission_1, 1.0f);
                }
                return _S1418;
            }
            else
            {
                bool _S1714 = !replay_2;
                if(_S1714)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1715 = b_12 > 0U;
                    if(_S1715)
                    {
                        Reservoir candidate_5 = chain_0;
                        if(_S1635)
                        {
                            float3  _S1716 = safeDivide(throughput_9 * emission_1, chain_throughput_0);
                            (&candidate_5)->radiance = _S1716;
                        }
                        else
                        {
                            if(_S1591)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1717 = throughput_9 * emission_1;
                        Reservoir _S1718 = withEnd(candidate_5, 1U, b_12, _S1717);
                        offer(sel_7, _S1718, _S1717 * make_float3 (scale_8) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1719 = throughput_9 * emission_1;
                        float3  _S1720 = sel_7->glow + _S1719;
                        sel_7->glow = _S1720;
                    }
                    if(nee_0)
                    {
                        float3  _S1721 = throughput_9 * lit_0;
                        Reservoir candidate_6 = chain_0;
                        if(_S1635)
                        {
                            float3  _S1722 = safeDivide(_S1721, chain_throughput_0);
                            (&candidate_6)->radiance = _S1722;
                        }
                        else
                        {
                            if(_S1591)
                            {
                                candidate_6 = here_0;
                                uint _S1723 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1723;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1724 = insertBits_0(0U, b_12 + 1U, 5U, 5U);
                                uint _S1725 = insertBits_0(_S1724, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1725;
                            }
                        }
                        Reservoir _S1726 = withEnd(candidate_6, 0U, b_12, _S1721);
                        offer(sel_7, _S1726, _S1721 * make_float3 (scale_8) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1614)
                        {
                            _S1692 = false;
                        }
                        else
                        {
                            bool _S1727 = environmentMapped_0();
                            _S1692 = _S1727;
                        }
                    }
                    else
                    {
                        _S1692 = false;
                    }
                    if(_S1692)
                    {
                        uint _S1728 = (fcptMaxBounces());
                        _S1693 = b_12 < _S1728;
                    }
                    else
                    {
                        _S1693 = false;
                    }
                    if(_S1693)
                    {
                        uint _S1729 = stream(_S1445, b_12 + 448U);
                        FKRay _S1730 = ray_2;
                        FKSurface _S1731 = surface_11;
                        ShadowContext _S1732 = context_5;
                        SkySample _S1733 = sampleSky_0(&_S1730, &_S1731, _S1609, is_inside_6, _S1729, surface_11.random_state, &_S1732);
                        float3  _S1734 = throughput_9 * _S1733.color;
                        Reservoir candidate_7 = chain_0;
                        if(_S1635)
                        {
                            float3  _S1735 = safeDivide(_S1734, chain_throughput_0);
                            (&candidate_7)->radiance = _S1735;
                        }
                        else
                        {
                            if(_S1591)
                            {
                                candidate_7 = here_0;
                                uint _S1736 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1736;
                                (&candidate_7)->dir = _S1733.dir;
                                (&candidate_7)->radiance = _S1733.radiance;
                            }
                            else
                            {
                                uint _S1737 = insertBits_0(0U, b_12 + 1U, 5U, 5U);
                                uint _S1738 = insertBits_0(_S1737, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1738;
                            }
                        }
                        Reservoir _S1739 = withEnd(candidate_7, 4U, b_12, _S1734);
                        offer(sel_7, _S1739, _S1734 * make_float3 (scale_8) / make_float3 (density_2));
                    }
                }
            }
            throughput_10 = throughput_9;
            density_3 = density_2;
        }
        bool _S1740;
        bool _S1741;
        bool _S1742;
        bool straight_0;
        bool _S1743;
        bool _S1744;
        bool _S1745;
        bool _S1746;
        bool _S1747;
        bool _S1748;
        bool _S1749;
        bool _S1750;
        bool _S1751;
        bool _S1752;
        bool _S1753;
        bool _S1754;
        float density_5;
        float sky_pdf_2;
        float spread_4;
        float density_6;
        float toon_b_5;
        float density_7;
        float spread_5;
        float width_6;
        uint b_15;
        float3  throughput_12;
        float3  throughput_13;
        float3  throughput_14;
        if(scatter_2)
        {
            MaterialTerms _S1755 = MaterialTerms_x24init_0(0.0f, 0.0f, 0.0f, 0.0f, 0.0f, _S1417, 0.0f, 0.0f, 0.0f, false, 0.0f);
            AnisotropicFrame _S1756 = AnisotropicFrame_x24init_0(_S1417, _S1664);
            ViewTerms _S1757 = ViewTerms_x24init_0(_S1417, _S1417, &_S1756, _S1417, 0.0f, _S1417, _S1417, _S1417, 0.0f, _S1417);
            bool _S1758 = !_S1614;
            float3  reconnection_1;
            float3  chain_throughput_1;
            MaterialTerms terms_6;
            ViewTerms view_terms_7;
            if(_S1758)
            {
                float _S1759 = _S1609.x;
                float _S1760 = _S1609.y;
                float _S1761 = (F32_min(((F32_sqrt((_S1592.material.specular_level))) * (F32_abs((_S1759 - _S1760))) / (_S1759 + _S1760)), (0.9999847412109375f)));
                float _S1762 = _S1761 * _S1761;
                float _S1763 = (1.0f + _S1761) / (1.0f - _S1761);
                float _S1764 = _S1592.material.toon.x;
                bool _S1765 = _S1764 < 0.0f;
                float _S1766 = (F32_abs((_S1764)));
                bool _S1767 = _S1766 > 0.0f;
                if(_S1767)
                {
                    float _S1768 = (F32_min((_S1766), (1.0f)));
                    float _S1769 = 1.0f - _S1768;
                    float _S1770 = rgb_to_greyscale(_S1592.material.albedo);
                    float _S1771 = _S1768 * _S1770;
                    float3  _S1772 = make_float3 (_S1768) * _S1592.material.albedo;
                    float toon_a_8 = clamp_1(_S1592.material.toon.y / _S1764, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
                    float toon_s_8 = clamp_1(_S1592.material.toon.z / _S1764, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
                    float _S1773 = (F32_min((toon_a_8 + toon_s_8), (1.57079637050628662f)));
                    if(_S1765)
                    {
                        density_5 = 1.0f - (F32_cos(((F32_min((_S1773), (toon_a_8))))));
                    }
                    else
                    {
                        float _S1774 = (F32_sin(((F32_min((_S1773), (toon_a_8))))));
                        density_5 = _S1774 * _S1774 / 2.0f;
                    }
                    bool _S1775 = _S1773 > toon_a_8;
                    if(_S1775)
                    {
                        viewed_1 = toon_s_8 > 0.0f;
                    }
                    else
                    {
                        viewed_1 = false;
                    }
                    if(viewed_1)
                    {
                        if(_S1765)
                        {
                            float _S1776 = (F32_cos((toon_a_8)));
                            float _S1777 = (F32_cos((_S1773)));
                            sky_pdf_2 = (1.0f + toon_a_8 / toon_s_8) * (_S1776 - _S1777) - ((F32_sin((_S1773))) - _S1773 * _S1777 - ((F32_sin((toon_a_8))) - toon_a_8 * _S1776)) / toon_s_8;
                        }
                        else
                        {
                            float _S1778 = 2.0f * toon_a_8;
                            float _S1779 = (F32_cos((_S1778)));
                            float _S1780 = 2.0f * _S1773;
                            float _S1781 = (F32_cos((_S1780)));
                            sky_pdf_2 = (1.0f + toon_a_8 / toon_s_8) * (_S1779 - _S1781) / 4.0f - ((F32_sin((_S1780))) / 8.0f - _S1773 * _S1781 / 4.0f - ((F32_sin((_S1778))) / 8.0f - toon_a_8 * _S1779 / 4.0f)) / toon_s_8;
                        }
                        float integral_6 = density_5 + sky_pdf_2;
                        sky_pdf_2 = integral_6;
                    }
                    else
                    {
                        sky_pdf_2 = density_5;
                    }
                    float _S1782 = 6.28318548202514648f * sky_pdf_2;
                    density_5 = _S1769;
                    sky_pdf_2 = _S1771;
                    throughput_12 = _S1772;
                    spread_4 = toon_a_8;
                    density_6 = toon_s_8;
                    toon_b_5 = _S1773;
                    density_7 = _S1782;
                }
                else
                {
                    density_5 = 1.0f;
                    sky_pdf_2 = 0.0f;
                    throughput_12 = _S1417;
                    spread_4 = 0.0f;
                    density_6 = 0.0f;
                    toon_b_5 = 0.0f;
                    density_7 = 1.0f;
                }
                float _S1783 = translucentShare(_S1592.material);
                MaterialTerms _S1784 = MaterialTerms_x24init_0(_S1762, _S1763, _S1783, density_5, sky_pdf_2, throughput_12, spread_4, density_6, toon_b_5, _S1765, density_7);
                float3  _S1785 = (&ray_2)->unit_direction;
                float3  _S1786 = negate_0(_S1785);
                float _S1787 = sign_0(dot_0(_S1593.smooth_n, _S1786));
                float3  _S1788 = _S1593.smooth_n * make_float3 (_S1787);
                AnisotropicFrame _S1789 = anisotropicFrame(_S1592.material, _S1788);
                float _S1790 = rgb_to_greyscale(_S1592.material.sheen);
                bool _S1791 = _S1790 > 0.0f;
                if(_S1791)
                {
                    float _S1792 = clamp_1((F32_sqrt(((F32_max((dot_0(_S1788, _S1786)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
                    uint _S1793 = (U32_min((uint(_S1792)), (22U)));
                    float least_3 = (F32_sqrt((0.05000000074505806f)));
                    float _S1794 = (F32_sqrt((0.10000000149011612f)));
                    bool _S1795 = (_S1592.material.velvet) > 0.0f;
                    float _S1796 = _slang_select(_S1795, _S1794,least_3);
                    float _S1797 = (clamp_1((F32_sqrt(((F32_max((_S1592.material.sheen_roughness), (0.0f)))))), _S1796, 1.0f) - _S1796) / (1.0f - _S1796) * 23.0f;
                    uint _S1798 = (U32_min((uint(_S1797)), (22U)));
                    uint _S1799 = _S1793 * 24U + _S1798;
                    float _S1800 = _S1792 - float(_S1793);
                    float _S1801 = _S1797 - float(_S1798);
                    uint _S1802 = _S1799 + 24U;
                    float a_14 = SHEEN_ALBEDO_0[_S1799] + (SHEEN_ALBEDO_0[_S1802] - SHEEN_ALBEDO_0[_S1799]) * _S1800;
                    uint _S1803 = _S1799 + 1U;
                    uint _S1804 = _S1802 + 1U;
                    float b_16 = SHEEN_ALBEDO_0[_S1803] + (SHEEN_ALBEDO_0[_S1804] - SHEEN_ALBEDO_0[_S1803]) * _S1800;
                    float _S1805 = (F32_exp((a_14 + (b_16 - a_14) * _S1801)));
                    if(_S1795)
                    {
                        float a_15 = VELVET_ALBEDO_0[_S1799] + (VELVET_ALBEDO_0[_S1802] - VELVET_ALBEDO_0[_S1799]) * _S1800;
                        float b_17 = VELVET_ALBEDO_0[_S1803] + (VELVET_ALBEDO_0[_S1804] - VELVET_ALBEDO_0[_S1803]) * _S1800;
                        float _S1806 = a_15 + (b_17 - a_15) * _S1801;
                        spread_5 = _S1806;
                    }
                    else
                    {
                        spread_5 = _S1805;
                    }
                    float _S1807 = (F32_min((spread_5), (1.0f)));
                    float3  _S1808 = make_float3 (1.0f) - _S1592.material.sheen * make_float3 (_S1807);
                    float _S1809 = rgb_to_greyscale(_S1592.material.sheen);
                    float _S1810 = _S1809 * _S1807;
                    float3  _S1811 = _S1592.material.sheen / make_float3 ((F32_max((spread_5), (1.0f))));
                    reconnection_1 = _S1808;
                    spread_5 = _S1810;
                    throughput_13 = _S1811;
                    throughput_14 = _S1786;
                }
                else
                {
                    reconnection_1 = throughput_6;
                    spread_5 = 0.0f;
                    throughput_13 = _S1417;
                    throughput_14 = _S1417;
                }
                float3  scale_9 = reconnection_1 * make_float3 (_S1784.toon_scale);
                if(_S1767)
                {
                    float _S1812 = dot_0(_S1788, _S1786);
                    float _S1813 = (F32_acos(((F32_min((_S1812), (1.0f))))));
                    if(_S1813 < (_S1784.toon_a))
                    {
                        width_6 = 1.0f;
                    }
                    else
                    {
                        width_6 = (F32_max((1.0f - (_S1813 - _S1784.toon_a) / (F32_max((_S1784.toon_s), (0.0000152587890625f)))), (0.0f)));
                    }
                    if(_S1784.toon_glossy)
                    {
                        float3  _S1814 = make_float3 (2.0f * _S1812) * _S1788 - _S1786;
                        float3  _S1815 = ((((_S1814)) * make_float3(rnorm3df(((_S1814)).x, ((_S1814)).y, ((_S1814)).z))));
                        chain_throughput_1 = _S1815;
                    }
                    else
                    {
                        chain_throughput_1 = _S1788;
                    }
                }
                else
                {
                    width_6 = 0.0f;
                    chain_throughput_1 = _S1788;
                }
                float _S1816 = _S1789.alphas.x;
                float _S1817 = (F32_sqrt(((F32_min((_S1816), (_S1789.alphas.y))))));
                bool _S1818 = _S1816 > 0.0f;
                float _S1819 = _slang_select(_S1818, _S1817,_S1592.material.roughness);
                float _S1820 = _S1819 * _S1819;
                float _S1821 = (F32_pow((_S1820), (1.81585001945495605f))) * (2.15371990203857422f - 0.73285001516342163f * _S1820) / (1.0f + 1.28094995021820068f * _S1820);
                bool _S1822 = _S1820 > 0.0f;
                float _S1823 = _slang_select(_S1822, _S1821,0.0f);
                float _S1824 = clamp_1(dot_0(_S1788, _S1786), 0.0f, 1.0f);
                float _S1825 = _S1820 * _S1819;
                float _S1826 = (F32_min((1.00064504146575928f - _S1819 * (0.00375499995425344f + _S1824 * (-0.04133399948477745f + _S1824 * (-0.90938502550125122f + _S1824 * 0.35275399684906006f))) - _S1820 * (0.27602800726890564f + _S1824 * (1.27023398876190186f + _S1824 * 0.04740000143647194f)) - _S1825 * (0.31452900171279907f - _S1824 * 0.34830701351165771f) + _S1825 * _S1819 * 0.27229699492454529f), (1.0f)));
                float3  _S1827 = min_1(make_float3 (1.0f) / (make_float3 (1.0f) - _S1592.material.albedo * make_float3 (_S1823)), make_float3 (1.0f / (F32_max((_S1826), (0.0000152587890625f)))));
                AnisotropicFrame _S1828 = _S1789;
                ViewTerms _S1829 = ViewTerms_x24init_0(_S1786, _S1788, &_S1828, scale_9, spread_5, throughput_13, throughput_14, _S1827, width_6, chain_throughput_1);
                terms_6 = _S1784;
                view_terms_7 = _S1829;
            }
            else
            {
                terms_6 = _S1755;
                view_terms_7 = _S1757;
            }
            if(replay_2)
            {
                viewed_1 = _S1648;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1830 = extractBits_0(_S1419, 15U, 3U);
            uint _S1831 = extractBits_0(_S1419, 18U, 3U);
            uint _S1832 = _slang_select(_S1647, _S1831,_S1830);
            float3  _S1833 = r_8->dir;
            bool refracted_6 = _S1832 == 1U;
            SampleBSDF _S1834 = SampleBSDF_x24init_0(_S1417, _S1417, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1834;
            if(viewed_1)
            {
                uint _S1835 = extractBits_0(_S1419, 22U, 1U);
                bool _S1836 = is_inside_6 != (_S1835 == 1U);
                if(_S1836)
                {
                    return _S1418;
                }
                bool _S1837 = _S1422 == 1U;
                if(_S1837)
                {
                    float3  _S1838 = (fcptHitPosition((_S1434)));
                    throughput_12 = _S1838;
                }
                else
                {
                    throughput_12 = reconnection_0;
                }
                if(refracted_6)
                {
                    refracted_5 = true;
                }
                else
                {
                    BSDFMaterial _S1839 = _S1592.material;
                    bool _S1840 = isTranslucent_0(&_S1839);
                    if(_S1840)
                    {
                        refracted_5 = _S1832 == 0U;
                    }
                    else
                    {
                        refracted_5 = false;
                    }
                    if(refracted_5)
                    {
                        float3  _S1841 = throughput_12 - (&ray_2)->origin;
                        float3  _S1842 = _slang_select(_S1837, _S1841,_S1833);
                        wrong_side_0 = (dot_0(_S1593.smooth_n, _S1842) * _S1594) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_5 = wrong_side_0;
                }
                if(_S1837)
                {
                    float3  _S1843 = (&ray_2)->origin;
                    FKSurface _S1844 = surface_11;
                    float3  _S1845 = - _S1593.smooth_n;
                    bool _S1846 = is_inside_6 != refracted_5;
                    float3  _S1847 = _slang_select(_S1846, _S1845,_S1593.smooth_n);
                    float3  _S1848 = throughput_12 - (_S1843 + make_float3 (_S1844.geometry_offset) * _S1847);
                    float3  _S1849 = ((((_S1848)) * make_float3(rnorm3df(((_S1848)).x, ((_S1848)).y, ((_S1848)).z))));
                    reconnection_1 = _S1849;
                }
                else
                {
                    reconnection_1 = _S1833;
                }
                if(_S1614)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1850 = wrongSide_0(is_inside_6, refracted_5, reconnection_1, surface_11.geometry_n);
                    wrong_side_0 = _S1850;
                }
                if(wrong_side_0)
                {
                    return _S1418;
                }
                float3  _S1851 = throughput_12;
                throughput_12 = reconnection_1;
                b_15 = _S1832;
                wrong_side_0 = false;
                reconnection_1 = _S1851;
            }
            else
            {
                bool _S1852 = !_S1647;
                if(_S1852)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1853;
                    if(_S1614)
                    {
                        SampleBSDF _S1854 = (fcptSampleHair((surface_11.hair), (_S1592.material.albedo), (_S1592.material.specular_tint), ((&ray_2)->unit_direction), (surface_11.random_state)));
                        _S1853 = _S1854;
                    }
                    else
                    {
                        SampleBSDF _S1855 = sampleBSDF((&ray_2)->unit_direction, _S1593.smooth_n, _S1592.material, _S1609.x, _S1609.y, surface_11.random_state, _S1664, terms_6, view_terms_7);
                        _S1853 = _S1855;
                    }
                    bsdf_sampled_0 = _S1853;
                    if(_S1614)
                    {
                        refracted_5 = !(((&bsdf_sampled_0)->pdf) > 0.0f);
                    }
                    else
                    {
                        refracted_5 = false;
                    }
                    if(refracted_5)
                    {
                        if(replay_2)
                        {
                            return _S1418;
                        }
                        break;
                    }
                    if(_S1614)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1856 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_11.geometry_n);
                        wrong_side_0 = _S1856;
                    }
                    if(wrong_side_0)
                    {
                        _S1692 = (_S1592.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1692 = false;
                    }
                    if(_S1692)
                    {
                        float3  _S1857 = (&bsdf_sampled_0)->unit_direction;
                        FKSurface _S1858 = surface_11;
                        float _S1859 = _S1609.x;
                        float _S1860 = _S1609.y;
                        uint _S1861 = (&bsdf_sampled_0)->random_state;
                        float3  _S1862 = (&bsdf_sampled_0)->unit_direction;
                        float3  _S1863 = negate_0(_S1862);
                        float _S1864 = sign_0(dot_0(_S1858.geometry_n, _S1863));
                        float3  _S1865 = _S1858.geometry_n * make_float3 (_S1864);
                        AnisotropicFrame _S1866 = anisotropicFrame(_S1592.material, _S1865);
                        float _S1867 = rgb_to_greyscale(_S1592.material.sheen);
                        bool _S1868 = _S1867 > 0.0f;
                        if(_S1868)
                        {
                            float _S1869 = clamp_1((F32_sqrt(((F32_max((dot_0(_S1865, _S1863)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
                            uint _S1870 = (U32_min((uint(_S1869)), (22U)));
                            float least_4 = (F32_sqrt((0.05000000074505806f)));
                            float _S1871 = (F32_sqrt((0.10000000149011612f)));
                            bool _S1872 = (_S1592.material.velvet) > 0.0f;
                            float _S1873 = _slang_select(_S1872, _S1871,least_4);
                            float _S1874 = (clamp_1((F32_sqrt(((F32_max((_S1592.material.sheen_roughness), (0.0f)))))), _S1873, 1.0f) - _S1873) / (1.0f - _S1873) * 23.0f;
                            uint _S1875 = (U32_min((uint(_S1874)), (22U)));
                            uint _S1876 = _S1870 * 24U + _S1875;
                            float _S1877 = _S1869 - float(_S1870);
                            float _S1878 = _S1874 - float(_S1875);
                            uint _S1879 = _S1876 + 24U;
                            float a_16 = SHEEN_ALBEDO_0[_S1876] + (SHEEN_ALBEDO_0[_S1879] - SHEEN_ALBEDO_0[_S1876]) * _S1877;
                            uint _S1880 = _S1876 + 1U;
                            uint _S1881 = _S1879 + 1U;
                            float b_18 = SHEEN_ALBEDO_0[_S1880] + (SHEEN_ALBEDO_0[_S1881] - SHEEN_ALBEDO_0[_S1880]) * _S1877;
                            float _S1882 = (F32_exp((a_16 + (b_18 - a_16) * _S1878)));
                            if(_S1872)
                            {
                                float a_17 = VELVET_ALBEDO_0[_S1876] + (VELVET_ALBEDO_0[_S1879] - VELVET_ALBEDO_0[_S1876]) * _S1877;
                                float b_19 = VELVET_ALBEDO_0[_S1880] + (VELVET_ALBEDO_0[_S1881] - VELVET_ALBEDO_0[_S1880]) * _S1877;
                                float _S1883 = a_17 + (b_19 - a_17) * _S1878;
                                spread_5 = _S1883;
                            }
                            else
                            {
                                spread_5 = _S1882;
                            }
                            float _S1884 = (F32_min((spread_5), (1.0f)));
                            float3  _S1885 = make_float3 (1.0f) - _S1592.material.sheen * make_float3 (_S1884);
                            float _S1886 = rgb_to_greyscale(_S1592.material.sheen);
                            float _S1887 = _S1886 * _S1884;
                            float3  _S1888 = _S1592.material.sheen / make_float3 ((F32_max((spread_5), (1.0f))));
                            reconnection_1 = _S1885;
                            spread_5 = _S1887;
                            throughput_13 = _S1888;
                            throughput_14 = _S1863;
                        }
                        else
                        {
                            reconnection_1 = throughput_6;
                            spread_5 = 0.0f;
                            throughput_13 = _S1417;
                            throughput_14 = _S1417;
                        }
                        float3  scale_10 = reconnection_1 * make_float3 (terms_6.toon_scale);
                        bool _S1889 = (F32_abs((_S1592.material.toon.x))) > 0.0f;
                        if(_S1889)
                        {
                            float _S1890 = dot_0(_S1865, _S1863);
                            float _S1891 = (F32_acos(((F32_min((_S1890), (1.0f))))));
                            MaterialTerms _S1892 = terms_6;
                            if(_S1891 < (terms_6.toon_a))
                            {
                                density_5 = 1.0f;
                            }
                            else
                            {
                                density_5 = (F32_max((1.0f - (_S1891 - _S1892.toon_a) / (F32_max((terms_6.toon_s), (0.0000152587890625f)))), (0.0f)));
                            }
                            if(terms_6.toon_glossy)
                            {
                                float3  _S1893 = make_float3 (2.0f * _S1890) * _S1865 - _S1863;
                                float3  _S1894 = ((((_S1893)) * make_float3(rnorm3df(((_S1893)).x, ((_S1893)).y, ((_S1893)).z))));
                                throughput_12 = _S1894;
                            }
                            else
                            {
                                throughput_12 = _S1865;
                            }
                            width_6 = density_5;
                            chain_throughput_1 = throughput_12;
                        }
                        else
                        {
                            width_6 = 0.0f;
                            chain_throughput_1 = _S1865;
                        }
                        float _S1895 = _S1866.alphas.x;
                        float _S1896 = (F32_sqrt(((F32_min((_S1895), (_S1866.alphas.y))))));
                        bool _S1897 = _S1895 > 0.0f;
                        float _S1898 = _slang_select(_S1897, _S1896,_S1592.material.roughness);
                        float _S1899 = _S1898 * _S1898;
                        float _S1900 = (F32_pow((_S1899), (1.81585001945495605f))) * (2.15371990203857422f - 0.73285001516342163f * _S1899) / (1.0f + 1.28094995021820068f * _S1899);
                        bool _S1901 = _S1899 > 0.0f;
                        float _S1902 = _slang_select(_S1901, _S1900,0.0f);
                        float _S1903 = clamp_1(dot_0(_S1865, _S1863), 0.0f, 1.0f);
                        float _S1904 = _S1899 * _S1898;
                        float _S1905 = (F32_min((1.00064504146575928f - _S1898 * (0.00375499995425344f + _S1903 * (-0.04133399948477745f + _S1903 * (-0.90938502550125122f + _S1903 * 0.35275399684906006f))) - _S1899 * (0.27602800726890564f + _S1903 * (1.27023398876190186f + _S1903 * 0.04740000143647194f)) - _S1904 * (0.31452900171279907f - _S1903 * 0.34830701351165771f) + _S1904 * _S1898 * 0.27229699492454529f), (1.0f)));
                        float3  _S1906 = min_1(make_float3 (1.0f) / (make_float3 (1.0f) - _S1592.material.albedo * make_float3 (_S1902)), make_float3 (1.0f / (F32_max((_S1905), (0.0000152587890625f)))));
                        AnisotropicFrame _S1907 = _S1866;
                        ViewTerms _S1908 = ViewTerms_x24init_0(_S1863, _S1865, &_S1907, scale_10, spread_5, throughput_13, throughput_14, _S1906, width_6, chain_throughput_1);
                        SampleBSDF _S1909 = sampleBSDF(_S1857, _S1858.geometry_n, _S1592.material, _S1859, _S1860, _S1861, _S1664, terms_6, _S1908);
                        (&bsdf_sampled_0)->unit_direction = _S1909.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1909.refracted;
                        (&bsdf_sampled_0)->throughput = _S1909.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1910 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_11.geometry_n)) * surface_11.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1910;
                        }
                    }
                    uint _S1911 = (&bsdf_sampled_0)->lobe;
                    float3  _S1912 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1913 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1914 = (&bsdf_sampled_0)->pdf;
                    float _S1915 = _slang_select(wrong_side_0, 0.0f,_S1914);
                    (&lobe_5)->pdf = _S1915;
                    throughput_12 = _S1912;
                    b_15 = _S1911;
                    refracted_5 = _S1913;
                }
                else
                {
                    throughput_12 = _S1833;
                    b_15 = _S1832;
                    wrong_side_0 = false;
                    refracted_5 = refracted_6;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1692 = true;
            }
            else
            {
                _S1692 = _S1647;
            }
            if(_S1692)
            {
                if(_S1614)
                {
                    SampleBSDF _S1916 = (fcptConnectHair((surface_11.hair), (_S1592.material.albedo), (_S1592.material.specular_tint), ((&ray_2)->unit_direction), (throughput_12)));
                    lobe_5 = _S1916;
                }
                else
                {
                    float3  _S1917 = (&ray_2)->unit_direction;
                    float _S1918 = sign_0(_S1594);
                    float3  _S1919 = _S1593.smooth_n * make_float3 (_S1918);
                    float _S1920 = dot_0(_S1919, throughput_12);
                    float _S1921 = _S1592.material.roughness;
                    float _S1922 = _S1921 * _S1921;
                    float3  _S1923 = reflectedHalf(_S1917, throughput_12);
                    bool _S1924 = b_15 == 1U;
                    if(_S1924)
                    {
                        float3  _S1925 = refractedHalf(_S1917, throughput_12, _S1593.smooth_n, _S1609.x, _S1609.y);
                        throughput_13 = _S1925;
                    }
                    else
                    {
                        throughput_13 = _S1923;
                    }
                    bool _S1926 = b_15 == 0U;
                    if(_S1926)
                    {
                        _S1693 = true;
                    }
                    else
                    {
                        _S1693 = b_15 == 6U;
                    }
                    if(_S1693)
                    {
                        float3  _S1927 = sampledHalf(_S1917, _S1593.smooth_n, _S1592.material, surface_11.random_state, view_terms_7);
                        throughput_14 = _S1927;
                    }
                    else
                    {
                        throughput_14 = throughput_13;
                    }
                    float _S1928 = _S1609.x;
                    float _S1929 = _S1609.y;
                    HalfTerms _S1930 = precomputeHalf(_S1917, throughput_14, _S1592.material, _S1928, _S1929, terms_6, view_terms_7);
                    switch(b_15)
                    {
                    case 0U:
                        {
                            float _S1931 = diffusePDF(_S1920, 0.0f, (F32_abs((_S1594))), _S1922, _S1930, _S1928, _S1929);
                            float3  _S1932 = diffuseBSDF(throughput_12, _S1919, _S1922, _S1592.material, _S1930);
                            density_5 = _S1931;
                            chain_throughput_1 = _S1932;
                            break;
                        }
                    case 1U:
                        {
                            float _S1933 = refractPDF(_S1920, dot_0(throughput_12, throughput_14), (F32_abs((_S1594))), _S1922, _S1930, _S1928, _S1929);
                            float3  _S1934 = refractBSDF(throughput_12, _S1919, _S1922, _S1592.material, _S1930);
                            density_5 = _S1933;
                            chain_throughput_1 = _S1934;
                            break;
                        }
                    case 4U:
                        {
                            float _S1935 = sheenVelvetPDF(_S1920, 0.0f, (F32_abs((_S1594))), _S1922, _S1930, _S1928, _S1929);
                            float3  _S1936 = sheenVelvetBSDF(throughput_12, _S1919, _S1922, _S1592.material, _S1930);
                            density_5 = _S1935;
                            chain_throughput_1 = _S1936;
                            break;
                        }
                    case 6U:
                        {
                            float _S1937 = toonPDF(_S1920, dot_0(throughput_12, _S1930.toon_axis), (F32_abs((_S1594))), _S1922, _S1930, _S1928, _S1929);
                            float3  _S1938 = toonBSDF(throughput_12, _S1919, _S1922, _S1592.material, _S1930);
                            density_5 = _S1937;
                            chain_throughput_1 = _S1938;
                            break;
                        }
                    default:
                        {
                            float _S1939 = reflectPDF(_S1920, 0.0f, (F32_abs((_S1594))), _S1922, _S1930, _S1928, _S1929);
                            float3  _S1940 = reflectBSDF(throughput_12, _S1919, _S1922, _S1592.material, _S1930);
                            density_5 = _S1939;
                            chain_throughput_1 = _S1940;
                            break;
                        }
                    }
                    bool _S1941 = density_5 > 0.0f;
                    if(_S1941)
                    {
                        SampleBSDF _S1942 = SampleBSDF_x24init_0(throughput_12, chain_throughput_1, surface_11.random_state, _S1924, b_15, density_5);
                        lobe_5 = _S1942;
                    }
                }
            }
            bool _S1943 = b_15 == 0U;
            if(_S1943)
            {
                _S1693 = true;
            }
            else
            {
                _S1693 = b_15 == 4U;
            }
            if(_S1693)
            {
                _S1740 = true;
            }
            else
            {
                _S1740 = b_15 == 6U;
            }
            if(_S1614)
            {
                _S1741 = false;
            }
            else
            {
                bool _S1944 = !_S1740;
                if(_S1944)
                {
                    bool _S1945 = (_S1592.material.roughness) == 0.0f;
                    if(_S1945)
                    {
                        _S1741 = true;
                    }
                    else
                    {
                        bool _S1946 = b_15 == 1U;
                        if(_S1946)
                        {
                            _S1741 = (_S1609.x) == (_S1609.y);
                        }
                        else
                        {
                            _S1741 = false;
                        }
                    }
                }
                else
                {
                    _S1741 = false;
                }
            }
            if(_S1758)
            {
                _S1742 = b_15 == 1U;
            }
            else
            {
                _S1742 = false;
            }
            if(_S1742)
            {
                straight_0 = (_S1592.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1743 = _S1758;
            }
            else
            {
                _S1743 = false;
            }
            if(_S1743)
            {
                _S1744 = b_15 == 1U;
            }
            else
            {
                _S1744 = false;
            }
            if(_S1744)
            {
                _S1745 = (_S1609.x) == (_S1609.y);
            }
            else
            {
                _S1745 = false;
            }
            BSDFMaterial _S1947 = _S1592.material;
            bool _S1948 = isTranslucent_0(&_S1947);
            if(_S1948)
            {
                _S1746 = _S1943;
            }
            else
            {
                _S1746 = false;
            }
            if(_S1746)
            {
                _S1747 = (dot_0(throughput_12, surface_11.geometry_n)) < 0.0f;
            }
            else
            {
                _S1747 = false;
            }
            if(nee_0)
            {
                _S1748 = !_S1741;
            }
            else
            {
                _S1748 = false;
            }
            if(_S1748)
            {
                _S1749 = !wrong_side_0;
            }
            else
            {
                _S1749 = false;
            }
            if(_S1749)
            {
                float _S1949 = (&lobe_5)->pdf;
                float3  _S1950 = (&ray_2)->origin;
                float3  _S1951 = _slang_select(_S1619, _S1417,_S1593.smooth_n);
                float3  _S1952 = (&ray_2)->origin;
                FKSurface _S1953 = surface_11;
                float3  _S1954 = - _S1593.smooth_n;
                float3  _S1955 = _slang_select(_S1747, _S1954,_S1593.smooth_n);
                NEEVertex _S1956 = NEEVertex_x24init_0(false, _S1949, _S1950, _S1951, _S1952 + make_float3 (_S1953.geometry_offset) * _S1955);
                nee_vertex_0 = _S1956;
            }
            else
            {
                if(_S1614)
                {
                    _S1750 = true;
                }
                else
                {
                    bool _S1957 = b_15 != 1U;
                    if(_S1957)
                    {
                        _S1750 = true;
                    }
                    else
                    {
                        _S1750 = (_S1609.x) != (_S1609.y);
                    }
                }
                if(_S1750)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1958 = withinInverseFootprint((&lobe_5)->pdf, _S1740, (&prev_0)->cos, (&hit_4)->distance, threshold_2);
            bool _S1959 = roughLobe((&lobe_5)->pdf, _S1740, _S1592.material.roughness);
            if(_S1647)
            {
                bool _S1960 = !_S1958;
                if(_S1960)
                {
                    return _S1418;
                }
                bool _S1961 = _S1423 != 1U;
                if(_S1961)
                {
                    _S1750 = _S1423 != 2U;
                }
                else
                {
                    _S1750 = false;
                }
                if(_S1750)
                {
                    float _S1962 = (&lobe_5)->pdf;
                    float _S1963 = _slang_select(nee_0, _S1962,0.0f);
                    float _S1964 = escapeWeight_0(_S1963, _S1833);
                    if(_S1655)
                    {
                        passes_0 = _S1429;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1965 = _slang_select(passes_0, _S1964,1.0f);
                    return Shift_x24init_0(throughput_10 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_8->radiance * make_float3 (_S1965) / make_float3 (r_8->jac), density_3 * (&lobe_5)->pdf / r_8->jac);
                }
                float3  _S1966 = throughput_10 * make_float3 ((&lobe_5)->pdf);
                float _S1967 = density_3 * (&lobe_5)->pdf;
                throughput_13 = _S1966;
                density_5 = _S1967;
            }
            else
            {
                throughput_13 = throughput_10;
                density_5 = density_3;
            }
            uint _S1968 = (fcptLayers((hit_4)));
            bool _S1969 = b_15 == 1U;
            bool _S1970 = passesLayer_0(_S1968, _S1969, passes_0);
            if(viewed_1)
            {
                _S1750 = _S1970;
            }
            else
            {
                _S1750 = false;
            }
            if(_S1750)
            {
                return _S1418;
            }
            if(replay_2)
            {
                _S1751 = b_12 <= _S1433;
            }
            else
            {
                _S1751 = false;
            }
            if(_S1751)
            {
                _S1752 = _S1591;
            }
            else
            {
                _S1752 = false;
            }
            if(_S1752)
            {
                _S1753 = _S1958;
            }
            else
            {
                _S1753 = false;
            }
            if(_S1753)
            {
                _S1754 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1754 = !_S1959;
                }
                else
                {
                    _S1754 = false;
                }
            }
            if(_S1754)
            {
                return _S1418;
            }
            if(viewed_1)
            {
                float3  _S1971 = throughput_13 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1972 = (&lobe_5)->pdf;
                throughput_14 = _S1971;
                sky_pdf_2 = _S1972;
            }
            else
            {
                float3  _S1973 = throughput_13 * max_0((&lobe_5)->throughput, _S1417);
                throughput_14 = _S1973;
                sky_pdf_2 = density_5;
            }
            bool _S1974 = !replay_2;
            bool _S1975;
            if(_S1974)
            {
                _S1975 = !_S1635;
            }
            else
            {
                _S1975 = false;
            }
            bool _S1976;
            if(_S1975)
            {
                _S1976 = _S1591;
            }
            else
            {
                _S1976 = false;
            }
            bool _S1977;
            if(_S1976)
            {
                _S1977 = _S1958;
            }
            else
            {
                _S1977 = false;
            }
            if(_S1977)
            {
                chain_0 = here_0;
                uint _S1978 = insertBits_0((&chain_0)->path, b_15, 18U, 3U);
                uint _S1979 = _slang_select(nee_0, 1U,0U);
                uint _S1980 = insertBits_0(_S1978, _S1979, 21U, 1U);
                (&chain_0)->path = _S1980;
                float _S1981 = (&chain_0)->jac * (&lobe_5)->pdf;
                (&chain_0)->jac = _S1981;
                (&chain_0)->dir = throughput_12;
                chain_throughput_1 = throughput_14;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1982 = surface_11;
            Vertex _S1983 = Vertex_x24init_0(_S1959, b_15, (&lobe_5)->pdf, (F32_abs((dot_0(surface_11.geometry_n, throughput_12)))), is_inside_6);
            prev_0 = _S1983;
            float _S1984 = (&lobe_5)->pdf;
            bool _S1985;
            if(_S1969)
            {
                _S1985 = (_S1609.x) == (_S1609.y);
            }
            else
            {
                _S1985 = false;
            }
            float sky_pdf_3 = _slang_select(_S1985, sky_pdf_0,_S1984);
            float _S1986 = _slang_select(_S1614, 0.0f,sky_pdf_3);
            float _S1987 = widened_0(spread_2, (&lobe_5)->pdf, _S1741);
            bool _S1988;
            if(refracted_5)
            {
                _S1988 = !_S1747;
            }
            else
            {
                _S1988 = false;
            }
            bool is_inside_7;
            if(_S1988)
            {
                bool _S1989 = !is_inside_6;
                is_inside_7 = _S1989;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            FKSurface _S1990 = surface_11;
            bool _S1991 = boundsVolume_0(&_S1990);
            bool _S1992;
            if(_S1991)
            {
                _S1992 = !_S1970;
            }
            else
            {
                _S1992 = false;
            }
            if(_S1992)
            {
                FKSurface faced_2 = surface_11;
                float3  _S1993 = - _S1982.geometry_n;
                float3  _S1994 = _slang_select(turned_1, _S1993,_S1982.geometry_n);
                (&faced_2)->geometry_n = _S1994;
                FKMedium _S1995 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1996 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1997 = faced_2;
                FKMedium _S1998 = _S1995;
                FKMedium _S1999 = _S1996;
                MediumSides _S2000 = mediumSides_0(&_S1997, &_S1998, filling_2, (&ray_2)->unit_direction, &_S1999);
                bool _S2001 = leavesInFront_0((&faced_2)->geometry_n, throughput_12, _S1982.geometry_n);
                float3  _S2002 = _slang_select(_S2001, _S2000.front.scatter,_S2000.behind.scatter);
                scatter_in_0 = _S2002;
                float3  _S2003 = _slang_select(_S2001, _S2000.front.extinction,_S2000.behind.extinction);
                extinction_in_0 = _S2003;
                float _S2004 = _slang_select(_S2001, _S2000.front.g,_S2000.behind.g);
                g_in_0 = _S2004;
                uint _S2005 = _S2000.fillings.x;
                uint _S2006 = _S2000.fillings.y;
                uint _S2007 = _slang_select(_S2001, _S2006,_S2005);
                bool _S2008 = (fcptVaryingUsed());
                uint _S2009 = _slang_select(_S2008, _S2007,4294967295U);
                filling_2 = _S2009;
            }
            (&ray_2)->unit_direction = throughput_12;
            bool _S2010 = !_S1970;
            if(_S2010)
            {
                FKSurface _S2011 = surface_11;
                float _S2012 = _slang_select(straight_0, 0.0f,_S2011.geometry_offset);
                float3  _S2013 = - _S1593.smooth_n;
                bool _S2014 = is_inside_7 != _S1747;
                float3  _S2015 = _slang_select(_S2014, _S2013,_S1593.smooth_n);
                float3  _S2016 = (&ray_2)->origin + make_float3 (_S2012) * _S2015;
                (&ray_2)->origin = _S2016;
            }
            throughput_13 = throughput_14;
            chain_throughput_0 = chain_throughput_1;
            density_5 = sky_pdf_2;
            passes_0 = _S1970;
            viewed_1 = _S1745;
            sky_pdf_2 = _S1986;
            spread_4 = _S1987;
            reconnection_0 = reconnection_1;
            is_inside_5 = is_inside_7;
        }
        else
        {
            (&prev_0)->rough = false;
            (&prev_0)->pdf = 0.0f;
            throughput_13 = throughput_10;
            density_5 = density_3;
            passes_0 = false;
            viewed_1 = viewed_0;
            sky_pdf_2 = 0.0f;
            spread_4 = spread_2;
            straight_0 = false;
            is_inside_5 = is_inside_6;
        }
        bool _S2017 = !replay_2;
        if(_S2017)
        {
            if(_S1559)
            {
                float3  _S2018 = throughput_13 * emission_1;
                Reservoir candidate_8 = chain_0;
                uint _S2019 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S2020 = _S2019 == 1U;
                if(_S2020)
                {
                    float3  _S2021 = safeDivide(_S2018, chain_throughput_0);
                    (&candidate_8)->radiance = _S2021;
                }
                Reservoir _S2022 = withEnd(candidate_8, 2U, b_12, _S2018);
                offer(sel_7, _S2022, _S2018 * make_float3 (scale_8) / make_float3 (density_5));
            }
            if(_S1559)
            {
                refracted_5 = true;
            }
            else
            {
                refracted_5 = scatter_2;
            }
            if(refracted_5)
            {
                float _S2023 = survivalProbability(abs_0(throughput_13), density_5);
                density_6 = _S2023;
            }
            else
            {
                density_6 = 1.0f;
            }
            uint _S2024 = stream(_S1445, b_12 + 128U);
            Random _S2025 = pcg(_S2024);
            bool _S2026 = density_6 < (_S2025.value);
            if(_S2026)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S2027 = (fcptMaxBounces());
                wrong_side_0 = b_12 >= _S2027;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S2028 = density_5 * density_6;
            density_6 = _S2028;
        }
        else
        {
            density_6 = density_5;
        }
        uint _S2029 = layer_0 ^ 1U;
        uint _S2030 = _slang_select(passes_0, _S2029,0U);
        if(passes_0)
        {
            (&prev_0)->rough = false;
            (&hit_4)->distance = 0.0f;
            b_15 = b_12;
            viewed_0 = viewed_1;
            throughput_5 = throughput_13;
            density_2 = density_6;
            sky_pdf_0 = sky_pdf_2;
            spread_2 = spread_4;
            uint _S2031 = b_15 + 1U;
            b_12 = _S2031;
            layer_0 = _S2030;
            continue;
        }
        FKRay _S2032 = ray_2;
        float _S2033 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_2)
        {
            refracted_5 = _S1648;
        }
        else
        {
            refracted_5 = false;
        }
        if(refracted_5)
        {
            wrong_side_0 = _S1422 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S2034 = _slang_select(wrong_side_0, _S2033,4.294967296e+09f);
        bool _S2035 = !_S1614;
        if(straight_0)
        {
            _S1692 = true;
        }
        else
        {
            _S1692 = _S1614;
        }
        FKHit _S2036;
        if(_S1692)
        {
            _S2036 = hit_4;
        }
        else
        {
            _S2036 = _S1665;
        }
        FKHit _S2037 = (fcptTraverseInstanceBVH((_S2032), (_S1567), (_S2034), (_S2035), (_S2036), (viewed_1)));
        hit_4 = _S2037;
        if(replay_2)
        {
            _S1693 = _S1648;
        }
        else
        {
            _S1693 = false;
        }
        if(_S1693)
        {
            _S1740 = _S1422 == 1U;
        }
        else
        {
            _S1740 = false;
        }
        if(_S1740)
        {
            _S1741 = ((&hit_4)->instance_index) == (_S1434.instance_index);
        }
        else
        {
            _S1741 = false;
        }
        if(_S1741)
        {
            _S1742 = ((&hit_4)->triangle_index) == (_S1434.triangle_index);
        }
        else
        {
            _S1742 = false;
        }
        if(_S1742)
        {
            (&hit_4)->uv = _S1434.uv;
            float _S2038 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S2038;
        }
        if(replay_2)
        {
            _S1743 = _S1648;
        }
        else
        {
            _S1743 = false;
        }
        if(_S1743)
        {
            _S1744 = _S1422 == 3U;
        }
        else
        {
            _S1744 = false;
        }
        if(_S1744)
        {
            _S1745 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1745 = false;
        }
        if(_S1745)
        {
            return _S1418;
        }
        Reservoir _S2039 = chain_0;
        uint _S2040 = filling_2;
        for(;;)
        {
            bool _S2041 = (fcptVaryingUsed());
            if(_S2041)
            {
                _S1746 = _S2040 != 4294967295U;
            }
            else
            {
                _S1746 = false;
            }
            if(_S1746)
            {
                float _S2042 = (fcptMajorant((_S2040)));
                toon_b_5 = _S2042;
            }
            else
            {
                toon_b_5 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_2)
            {
                _S1747 = _S1648;
            }
            else
            {
                _S1747 = false;
            }
            if(_S1747)
            {
                _S1748 = _S1422 == 1U;
            }
            else
            {
                _S1748 = false;
            }
            if(_S1748)
            {
                _S1749 = toon_b_5 > 0.0f;
            }
            else
            {
                _S1749 = false;
            }
            if(_S1749)
            {
                ended_0 = _S1418;
                sky_pdf_1 = sky_pdf_2;
                spread_5 = spread_4;
                width_6 = width_3;
                density_7 = density_6;
                throughput_14 = throughput_13;
                b_15 = b_12;
                _S1750 = true;
                break;
            }
            bool _S2043 = (&prev_0)->rough;
            if(_S2043)
            {
                _S1750 = !(toon_b_5 > 0.0f);
            }
            else
            {
                _S1750 = false;
            }
            (&prev_0)->rough = _S1750;
            uint _S2044 = b_12 + 320U;
            bool _S2045 = b_12 == 4294967295U;
            uint _S2046 = _slang_select(_S2045, 384U,_S2044);
            uint _S2047 = stream(_S1445, _S2046);
            uint tracking_1 = _S2047;
            weight_1 = throughput_6;
            glowed_0 = _S1417;
            b_15 = b_12;
            throughput_14 = throughput_13;
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
                    _S1416 = int(2);
                    break;
                }
                uint _S2048 = b_15 + 320U;
                bool _S2049 = b_15 == 4294967295U;
                uint _S2050 = _slang_select(_S2049, 384U,_S2048);
                uint _S2051 = stream(_S1445, _S2050);
                Random _S2052 = pcg(_S2051);
                float _S2053 = freeFlight_0(_S2052.value, toon_b_5);
                if(_S1746)
                {
                    float3  _S2054 = (&ray_2)->origin;
                    float3  _S2055 = (&ray_2)->unit_direction;
                    float _S2056 = (&hit_4)->distance;
                    uint _S2057 = _slang_select(_S2049, 0U,b_15);
                    uint _S2058 = (&prev_0)->lobe;
                    uint _S2059 = _slang_select(_S2049, 3U,_S2058);
                    float _S2060 = (fcptTrackMedium((_S2040), (_S2054), (_S2055), (_S2056), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S2057), (_S2059), (_S2049)));
                    spread_3 = _S2060;
                }
                else
                {
                    spread_3 = _S2053;
                }
                bool _S2061 = !(spread_3 < ((&hit_4)->distance));
                if(_S2061)
                {
                    _S1416 = int(2);
                    break;
                }
                if(_S1746)
                {
                    _S1751 = _S2017;
                }
                else
                {
                    _S1751 = false;
                }
                if(_S1751)
                {
                    float3  _S2062 = throughput_14 * glowed_0 / make_float3 (density_7);
                    float3  _S2063 = sel_7->glow + _S2062;
                    sel_7->glow = _S2063;
                }
                else
                {
                }
                glowed_0 = _S1417;
                uint b_20 = b_15 + 1U;
                float3  _S2064 = (&ray_2)->origin + make_float3 (spread_3) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S2064;
                float3  _S2065 = flightWeight_0(scatter_in_0, extinction_in_0, toon_b_5, spread_3, true);
                float3  _S2066 = weight_1;
                float3  _S2067 = _slang_select(_S1746, _S2066,_S2065);
                float3  throughput_15 = throughput_14 * _S2067;
                uint _S2068 = stream(_S1445, b_20 + 320U);
                tracking_1 = _S2068;
                weight_1 = throughput_6;
                float width_7 = width_6 + spread_5 * spread_3;
                float _S2069 = spread_5 + 3.14159274101257324f;
                bool _S2070 = scatterSampled_0(replay_2, b_20, _S1433, _S1746);
                TreeSample light_4;
                if(_S2070)
                {
                    float3  _S2071 = (&ray_2)->origin;
                    float3  _S2072 = (&ray_2)->unit_direction;
                    float3  _S2073 = (&ray_2)->unit_direction;
                    uint _S2074 = stream(_S1445, b_20 + 64U);
                    float3  _S2075 = extinction_in_0;
                    float3  _S2076 = extinction_in_0;
                    uint2  _S2077 = make_uint2 (_S2040);
                    float3  _S2078 = (&ray_2)->unit_direction;
                    uint _S2079 = arrivalLobe_0(b_20, (&prev_0)->lobe);
                    FKHit _S2080 = _S1665;
                    ShadowContext _S2081 = ShadowContext_x24init_0(_S2075, _S2076, _S2077, _S2078, b_20, _S2079, false, spread_3, width_7, &_S2080, false);
                    ShadowContext _S2082 = _S2081;
                    TreeSample _S2083 = sampleLightTree_0(_S2071, _S2072, _S2073, 0.0f, true, _S2074, &_S2082);
                    light_4 = _S2083;
                }
                else
                {
                    light_4 = _S1662;
                }
                float _S2084 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S2085 = (fcptMaxBounces());
                bool _S2086 = b_20 < _S2085;
                if(_S2086)
                {
                    _S1752 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1752 = false;
                }
                float _S2087 = _slang_select(_S1752, _S2084,0.0f);
                float3  _S2088 = throughput_15 * light_4.radiance;
                float _S2089 = powerHeuristic(light_4.density, _S2087);
                float3  _S2090 = _S2088 * make_float3 (_S2084 * _S2089);
                float3  _S2091 = _slang_select(_S2070, _S2090,_S1417);
                if(replay_2)
                {
                    _S1753 = b_20 == _S1433;
                }
                else
                {
                    _S1753 = false;
                }
                if(_S1753)
                {
                    bool _S2092 = _S1422 == 2U;
                    if(_S2092)
                    {
                        float _S2093 = resamplingTarget(_S2091);
                        _S1754 = _S2093 > 0.0f;
                    }
                    else
                    {
                        _S1754 = false;
                    }
                    if(_S1754)
                    {
                        Shift _S2094 = Shift_x24init_0(_S2091, 1.0f);
                        _S1416 = int(1);
                        ended_0 = _S2094;
                        spread_3 = _S2069;
                        width_4 = width_7;
                        throughput_12 = throughput_15;
                        b_13 = b_20;
                        break;
                    }
                    _S1416 = int(1);
                    ended_0 = _S1418;
                    spread_3 = _S2069;
                    width_4 = width_7;
                    throughput_12 = throughput_15;
                    b_13 = b_20;
                    break;
                }
                if(_S2017)
                {
                    Reservoir candidate_9 = _S2039;
                    uint _S2095 = extractBits_0(_S2039.path, 10U, 2U);
                    bool _S2096 = _S2095 == 1U;
                    if(_S2096)
                    {
                        float3  _S2097 = safeDivide(_S2091, chain_throughput_0);
                        (&candidate_9)->radiance = _S2097;
                    }
                    else
                    {
                        uint _S2098 = insertBits_0(0U, b_20 + 1U, 5U, 5U);
                        uint _S2099 = insertBits_0(_S2098, 2U, 10U, 2U);
                        (&candidate_9)->path = _S2099;
                    }
                    Reservoir _S2100 = withEnd(candidate_9, 0U, b_20, _S2091);
                    offer(sel_7, _S2100, _S2091 * make_float3 (scale_8) / make_float3 (density_7));
                    float _S2101 = survivalProbability(abs_0(throughput_15), density_7);
                    uint _S2102 = stream(_S1445, b_20 + 128U);
                    Random _S2103 = pcg(_S2102);
                    bool _S2104 = _S2101 < (_S2103.value);
                    if(_S2104)
                    {
                        _S1754 = true;
                    }
                    else
                    {
                        uint _S2105 = (fcptMaxBounces());
                        _S1754 = b_20 >= _S2105;
                    }
                    if(_S1754)
                    {
                        _S1416 = int(1);
                        ended_0 = _S1418;
                        spread_3 = _S2069;
                        width_4 = width_7;
                        throughput_12 = throughput_15;
                        b_13 = b_20;
                        break;
                    }
                    float _S2106 = density_7 * _S2101;
                    density_7 = _S2106;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S2107 = stream(_S1445, b_20);
                float3  _S2108 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S2107, &phase_pdf_1);
                (&ray_2)->unit_direction = _S2108;
                NEEVertex _S2109 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1417, (&ray_2)->origin);
                nee_vertex_0 = _S2109;
                Vertex _S2110 = scatteredVertex_0(is_inside_5);
                prev_0 = _S2110;
                float _S2111 = (&prev_0)->pdf;
                FKRay _S2112 = ray_2;
                FKHit _S2113 = (fcptTraverseInstanceBVH((_S2112), (true), (4.294967296e+09f), (false), (_S1665), (false)));
                hit_4 = _S2113;
                b_15 = b_20;
                throughput_14 = throughput_15;
                spread_5 = _S2069;
                width_6 = width_7;
                sky_pdf_1 = _S2111;
            }
            if(_S1416 != int(2))
            {
                spread_5 = spread_3;
                width_6 = width_4;
                throughput_14 = throughput_12;
                b_15 = b_13;
                _S1750 = true;
                break;
            }
            ended_0 = _S1418;
            _S1750 = false;
            break;
        }
        if(_S1750)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1751 = b_15 == b_12;
        }
        else
        {
            _S1751 = false;
        }
        bool _S2114 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S2114)
        {
            bool _S2115 = !(&nee_vertex_0)->none;
            float _S2116 = _slang_select(_S2115, sky_pdf_1,0.0f);
            float _S2117 = escapeWeight_0(_S2116, (&ray_2)->unit_direction);
            float3  _S2118 = environment_0((&ray_2)->unit_direction, b_15, (&prev_0)->lobe);
            float3  _S2119 = throughput_14 * _S2118;
            if(replay_2)
            {
                bool _S2120 = b_15 == _S1433;
                if(_S2120)
                {
                    passes_0 = _S1422 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S2119 * make_float3 (_S2117) / make_float3 (r_8->jac), density_7 / r_8->jac);
                }
                if(_S1432)
                {
                    passes_0 = _S1429;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_15 == _S1420;
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
                    return Shift_x24init_0(_S2119 * make_float3 (_S2117), 1.0f);
                }
                return _S1418;
            }
            Reservoir candidate_10 = chain_0;
            uint _S2121 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S2122 = _S2121 == 1U;
            if(_S2122)
            {
                uint _S2123 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S2124 = _S2123 == b_15;
                float _S2125 = _slang_select(_S2124, 1.0f,_S2117);
                float3  _S2126 = safeDivide(_S2119 * make_float3 (_S2125), chain_throughput_0);
                (&candidate_10)->radiance = _S2126;
            }
            else
            {
                bool _S2127 = (&prev_0)->rough;
                if(_S2127)
                {
                    uint _S2128 = insertBits_0(0U, b_15 + 1U, 5U, 5U);
                    uint _S2129 = insertBits_0(_S2128, 3U, 10U, 2U);
                    uint _S2130 = insertBits_0(_S2129, (&prev_0)->lobe, 15U, 3U);
                    bool _S2131 = (&prev_0)->inside;
                    uint _S2132 = _slang_select(_S2131, 1U,0U);
                    uint _S2133 = insertBits_0(_S2130, _S2132, 22U, 1U);
                    (&candidate_10)->path = _S2133;
                    (&candidate_10)->jac = (&prev_0)->pdf;
                    (&candidate_10)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S2134 = _S2119 * make_float3 (_S2117);
            Reservoir _S2135 = withEnd(candidate_10, 3U, b_15, _S2134);
            offer(sel_7, _S2135, _S2134 * make_float3 (scale_8) / make_float3 (density_7));
            break;
        }
        float3  _S2136 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S2136;
        bool _S2137 = (fcptVaryingUsed());
        if(_S2137)
        {
            _S1752 = filling_2 != 4294967295U;
        }
        else
        {
            _S1752 = false;
        }
        if(_S1752)
        {
            if(_S2017)
            {
                float3  _S2138 = throughput_14 * glowed_0 / make_float3 (density_7);
                float3  _S2139 = sel_7->glow + _S2138;
                sel_7->glow = _S2139;
            }
            float3  _S2140 = throughput_14 * weight_1;
            throughput_12 = _S2140;
        }
        else
        {
            float3  _S2141 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S2142 = throughput_14 * _S2141;
            throughput_12 = _S2142;
        }
        float _S2143 = width_6 + spread_5 * (&hit_4)->distance;
        viewed_0 = _S1751;
        width_3 = _S2143;
        throughput_5 = throughput_12;
        density_2 = density_7;
        sky_pdf_0 = sky_pdf_1;
        spread_2 = spread_5;
        uint _S2031 = b_15 + 1U;
        b_12 = _S2031;
        layer_0 = _S2030;
    }
    return _S1418;
}

static __device__ Shift shift_0(Domain * dom_8, Reservoir * r_9)
{
    Selection _S2144 = (Selection{});
    Selection sel_8 = _S2144;
    bool _S2145 = (r_9->w) <= 0.0f;
    if(_S2145)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S2146 = walk_0(dom_8, r_9, true, 0.0f, &sel_8);
    return _S2146;
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
        *_slang_vector_get_element_ptr(&result_15, i_24) = (F32_tan((_slang_vector_get_element(x_27, i_24))));
        i_24 = i_24 + int(1);
    }
    return result_15;
}

static __device__ float3  acos_0(float3  x_28)
{
    float3  result_16;
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
        *_slang_vector_get_element_ptr(&result_16, i_25) = (F32_acos((_slang_vector_get_element(x_28, i_25))));
        i_25 = i_25 + int(1);
    }
    return result_16;
}

__device__ Random normal_distribution(uint state_4)
{
    Random _S2147 = pcg(state_4);
    Random _S2148 = pcg(_S2147.state);
    float _S2149 = 6.28318548202514648f * _S2147.value;
    float _S2150 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S2148.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S2148.state, _S2150 * (F32_cos((_S2149))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_5, float3  value_2)
{
    RandomSphere _S2151;
    (&_S2151)->state = state_5;
    (&_S2151)->value = value_2;
    return _S2151;
}

__device__ RandomSphere random_sphere(uint state_6)
{
    Random _S2152 = normal_distribution(state_6);
    Random _S2153 = normal_distribution(_S2152.state);
    Random _S2154 = normal_distribution(_S2153.state);
    float3  _S2155 = make_float3 (_S2152.value, _S2153.value, _S2154.value);
    float3  _S2156 = ((((_S2155)) * make_float3(rnorm3df(((_S2155)).x, ((_S2155)).y, ((_S2155)).z))));
    return RandomSphere_x24init_0(_S2154.state, _S2156);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_16)
{
    float3  _S2157 = p1_0 - p0_0;
    float3  _S2158 = p2_0 - p0_0;
    float2  _S2159 = uv1_0 - uv0_0;
    float2  _S2160 = uv2_0 - uv0_0;
    float _S2161 = _S2159.x;
    float _S2162 = _S2160.y;
    float _S2163 = _S2159.y;
    float _S2164 = _S2160.x;
    float _S2165 = _S2161 * _S2162 - _S2163 * _S2164;
    float _S2166 = 1.0f / _S2165;
    float3  t_22 = (_S2157 * make_float3 (_S2162) - _S2158 * make_float3 (_S2163)) * make_float3 (_S2166);
    float3  _S2167 = (_S2158 * make_float3 (_S2161) - _S2157 * make_float3 (_S2164)) * make_float3 (_S2166);
    float3  _S2168 = t_22 - n_16 * make_float3 (dot_0(n_16, t_22));
    float3  t_23 = ((((_S2168)) * make_float3(rnorm3df(((_S2168)).x, ((_S2168)).y, ((_S2168)).z))));
    bool _S2169 = (dot_0(cross_0(n_16, t_23), _S2167)) > 0.0f;
    float3  t_24;
    if(_S2169)
    {
        float3  _S2170 = negate_0(t_23);
        t_24 = _S2170;
    }
    else
    {
        t_24 = t_23;
    }
    float3  _S2171 = cross_0(n_16, t_24);
    return makeMatrix<float, 3, 3> (t_24, _S2171, n_16);
}

__device__ float3  tangentToWorldNormalMap(float3  v_4, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_4, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_5, float3  uvw_0, float3  position_0)
{
    float3  _S2172 = t1_0 - t0_0;
    float3  _S2173 = t2_2 - t0_0;
    float3  _S2174 = t2_2 - t1_0;
    float _S2175 = (F32_min((length_0(_S2172)), ((F32_min((length_0(_S2173)), (length_0(_S2174)))))));
    float3  _S2176 = make_float3 (distance_1(position_0, t0_0), distance_1(position_0, t1_0), distance_1(position_0, t2_2));
    float3  _S2177 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S2178 = dot_0(geometry_n_5, _S2177);
    float3  _S2179 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S2180 = dot_0(geometry_n_5, _S2179);
    float3  _S2181 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S2182 = acos_0(abs_0(make_float3 (_S2178, _S2180, dot_0(geometry_n_5, _S2181))));
    float3  _S2183 = clamp_2(tan_0(_S2182), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S2176 * _S2183, uvw_0), 0.0f, _S2175 * 0.125f);
}

__device__ MaterialTerms precomputeMaterial(BSDFMaterial material_27, float eta_i_21, float eta_o_21)
{
    float _S2184 = (F32_min(((F32_sqrt((material_27.specular_level))) * (F32_abs((eta_i_21 - eta_o_21))) / (eta_i_21 + eta_o_21)), (0.9999847412109375f)));
    float _S2185 = _S2184 * _S2184;
    float _S2186 = (1.0f + _S2184) / (1.0f - _S2184);
    float3  _S2187 = make_float3 (0.0f);
    float _S2188 = material_27.toon.x;
    bool _S2189 = _S2188 < 0.0f;
    float _S2190 = (F32_abs((_S2188)));
    bool _S2191 = _S2190 > 0.0f;
    float toon_scale_4;
    float toon_component_4;
    float toon_a_9;
    float toon_s_9;
    float toon_b_6;
    float toon_norm_5;
    float3  toon_6;
    if(_S2191)
    {
        float _S2192 = (F32_min((_S2190), (1.0f)));
        float _S2193 = 1.0f - _S2192;
        float _S2194 = rgb_to_greyscale(material_27.albedo);
        float _S2195 = _S2192 * _S2194;
        float3  _S2196 = make_float3 (_S2192) * material_27.albedo;
        float toon_a_10 = clamp_1(material_27.toon.y / _S2188, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
        float toon_s_10 = clamp_1(material_27.toon.z / _S2188, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
        float _S2197 = (F32_min((toon_a_10 + toon_s_10), (1.57079637050628662f)));
        if(_S2189)
        {
            toon_scale_4 = 1.0f - (F32_cos(((F32_min((_S2197), (toon_a_10))))));
        }
        else
        {
            float _S2198 = (F32_sin(((F32_min((_S2197), (toon_a_10))))));
            toon_scale_4 = _S2198 * _S2198 / 2.0f;
        }
        bool _S2199 = _S2197 > toon_a_10;
        bool _S2200;
        if(_S2199)
        {
            _S2200 = toon_s_10 > 0.0f;
        }
        else
        {
            _S2200 = false;
        }
        if(_S2200)
        {
            if(_S2189)
            {
                float _S2201 = (F32_cos((toon_a_10)));
                float _S2202 = (F32_cos((_S2197)));
                toon_component_4 = (1.0f + toon_a_10 / toon_s_10) * (_S2201 - _S2202) - ((F32_sin((_S2197))) - _S2197 * _S2202 - ((F32_sin((toon_a_10))) - toon_a_10 * _S2201)) / toon_s_10;
            }
            else
            {
                float _S2203 = 2.0f * toon_a_10;
                float _S2204 = (F32_cos((_S2203)));
                float _S2205 = 2.0f * _S2197;
                float _S2206 = (F32_cos((_S2205)));
                toon_component_4 = (1.0f + toon_a_10 / toon_s_10) * (_S2204 - _S2206) / 4.0f - ((F32_sin((_S2205))) / 8.0f - _S2197 * _S2206 / 4.0f - ((F32_sin((_S2203))) / 8.0f - toon_a_10 * _S2204 / 4.0f)) / toon_s_10;
            }
            float integral_7 = toon_scale_4 + toon_component_4;
            toon_scale_4 = integral_7;
        }
        float _S2207 = 6.28318548202514648f * toon_scale_4;
        toon_scale_4 = _S2193;
        toon_component_4 = _S2195;
        toon_6 = _S2196;
        toon_a_9 = toon_a_10;
        toon_s_9 = toon_s_10;
        toon_b_6 = _S2197;
        toon_norm_5 = _S2207;
    }
    else
    {
        toon_scale_4 = 1.0f;
        toon_component_4 = 0.0f;
        toon_6 = _S2187;
        toon_a_9 = 0.0f;
        toon_s_9 = 0.0f;
        toon_b_6 = 0.0f;
        toon_norm_5 = 1.0f;
    }
    float _S2208 = translucentShare(material_27);
    return MaterialTerms_x24init_0(_S2185, _S2186, _S2208, toon_scale_4, toon_component_4, toon_6, toon_a_9, toon_s_9, toon_b_6, _S2189, toon_norm_5);
}

__device__ ViewTerms precomputeView(float3  in_dir_14, float3  n_17, BSDFMaterial material_28, MaterialTerms terms_7)
{
    float3  _S2209 = negate_0(in_dir_14);
    float _S2210 = sign_0(dot_0(n_17, _S2209));
    float3  _S2211 = n_17 * make_float3 (_S2210);
    AnisotropicFrame _S2212 = anisotropicFrame(material_28, _S2211);
    float3  _S2213 = make_float3 (1.0f);
    float3  _S2214 = make_float3 (0.0f);
    float _S2215 = rgb_to_greyscale(material_28.sheen);
    bool _S2216 = _S2215 > 0.0f;
    float sheen_component_4;
    float3  sheen_6;
    float3  view_5;
    float3  scale_11;
    if(_S2216)
    {
        float _S2217 = clamp_1((F32_sqrt(((F32_max((dot_0(_S2211, _S2209)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S2218 = (U32_min((uint(_S2217)), (22U)));
        float least_5 = (F32_sqrt((0.05000000074505806f)));
        float _S2219 = (F32_sqrt((0.10000000149011612f)));
        bool _S2220 = (material_28.velvet) > 0.0f;
        float _S2221 = _slang_select(_S2220, _S2219,least_5);
        float _S2222 = (clamp_1((F32_sqrt(((F32_max((material_28.sheen_roughness), (0.0f)))))), _S2221, 1.0f) - _S2221) / (1.0f - _S2221) * 23.0f;
        uint _S2223 = (U32_min((uint(_S2222)), (22U)));
        uint _S2224 = _S2218 * 24U + _S2223;
        float _S2225 = _S2217 - float(_S2218);
        float _S2226 = _S2222 - float(_S2223);
        uint _S2227 = _S2224 + 24U;
        float a_18 = SHEEN_ALBEDO_0[_S2224] + (SHEEN_ALBEDO_0[_S2227] - SHEEN_ALBEDO_0[_S2224]) * _S2225;
        uint _S2228 = _S2224 + 1U;
        uint _S2229 = _S2227 + 1U;
        float b_21 = SHEEN_ALBEDO_0[_S2228] + (SHEEN_ALBEDO_0[_S2229] - SHEEN_ALBEDO_0[_S2228]) * _S2225;
        float _S2230 = (F32_exp((a_18 + (b_21 - a_18) * _S2226)));
        if(_S2220)
        {
            float a_19 = VELVET_ALBEDO_0[_S2224] + (VELVET_ALBEDO_0[_S2227] - VELVET_ALBEDO_0[_S2224]) * _S2225;
            float b_22 = VELVET_ALBEDO_0[_S2228] + (VELVET_ALBEDO_0[_S2229] - VELVET_ALBEDO_0[_S2228]) * _S2225;
            float _S2231 = a_19 + (b_22 - a_19) * _S2226;
            sheen_component_4 = _S2231;
        }
        else
        {
            sheen_component_4 = _S2230;
        }
        float _S2232 = (F32_min((sheen_component_4), (1.0f)));
        float3  _S2233 = make_float3 (1.0f) - material_28.sheen * make_float3 (_S2232);
        float _S2234 = rgb_to_greyscale(material_28.sheen);
        float _S2235 = _S2234 * _S2232;
        float3  _S2236 = material_28.sheen / make_float3 ((F32_max((sheen_component_4), (1.0f))));
        sheen_component_4 = _S2235;
        sheen_6 = _S2236;
        view_5 = _S2209;
        scale_11 = _S2233;
    }
    else
    {
        sheen_component_4 = 0.0f;
        sheen_6 = _S2214;
        view_5 = _S2214;
        scale_11 = _S2213;
    }
    float3  scale_12 = scale_11 * make_float3 (terms_7.toon_scale);
    bool _S2237 = (F32_abs((material_28.toon.x))) > 0.0f;
    float toon_view_5;
    float3  toon_axis_5;
    if(_S2237)
    {
        float _S2238 = dot_0(_S2211, _S2209);
        float _S2239 = (F32_acos(((F32_min((_S2238), (1.0f))))));
        if(_S2239 < (terms_7.toon_a))
        {
            toon_view_5 = 1.0f;
        }
        else
        {
            toon_view_5 = (F32_max((1.0f - (_S2239 - terms_7.toon_a) / (F32_max((terms_7.toon_s), (0.0000152587890625f)))), (0.0f)));
        }
        if(terms_7.toon_glossy)
        {
            float3  _S2240 = make_float3 (2.0f * _S2238) * _S2211 - _S2209;
            float3  _S2241 = ((((_S2240)) * make_float3(rnorm3df(((_S2240)).x, ((_S2240)).y, ((_S2240)).z))));
            scale_11 = _S2241;
        }
        else
        {
            scale_11 = _S2211;
        }
        toon_axis_5 = scale_11;
    }
    else
    {
        toon_view_5 = 0.0f;
        toon_axis_5 = _S2211;
    }
    float _S2242 = _S2212.alphas.x;
    float _S2243 = (F32_sqrt(((F32_min((_S2242), (_S2212.alphas.y))))));
    bool _S2244 = _S2242 > 0.0f;
    float _S2245 = _slang_select(_S2244, _S2243,material_28.roughness);
    float _S2246 = _S2245 * _S2245;
    float _S2247 = (F32_pow((_S2246), (1.81585001945495605f))) * (2.15371990203857422f - 0.73285001516342163f * _S2246) / (1.0f + 1.28094995021820068f * _S2246);
    bool _S2248 = _S2246 > 0.0f;
    float _S2249 = _slang_select(_S2248, _S2247,0.0f);
    float _S2250 = clamp_1(dot_0(_S2211, _S2209), 0.0f, 1.0f);
    float _S2251 = _S2246 * _S2245;
    float _S2252 = (F32_min((1.00064504146575928f - _S2245 * (0.00375499995425344f + _S2250 * (-0.04133399948477745f + _S2250 * (-0.90938502550125122f + _S2250 * 0.35275399684906006f))) - _S2246 * (0.27602800726890564f + _S2250 * (1.27023398876190186f + _S2250 * 0.04740000143647194f)) - _S2251 * (0.31452900171279907f - _S2250 * 0.34830701351165771f) + _S2251 * _S2245 * 0.27229699492454529f), (1.0f)));
    float3  _S2253 = min_1(make_float3 (1.0f) / (make_float3 (1.0f) - material_28.albedo * make_float3 (_S2249)), make_float3 (1.0f / (F32_max((_S2252), (0.0000152587890625f)))));
    AnisotropicFrame _S2254 = _S2212;
    ViewTerms _S2255 = ViewTerms_x24init_0(_S2209, _S2211, &_S2254, scale_12, sheen_component_4, sheen_6, view_5, _S2253, toon_view_5, toon_axis_5);
    return _S2255;
}

__device__ float3  straightThrough(float3  dir_16, float3  n_18, BSDFMaterial material_29)
{
    float3  _S2256 = negate_0(dir_16);
    float _S2257 = sign_0(dot_0(n_18, _S2256));
    float3  _S2258 = n_18 * make_float3 (_S2257);
    AnisotropicFrame _S2259 = anisotropicFrame(material_29, _S2258);
    bool _S2260 = (_S2259.alphas.x) > 0.0f;
    if(_S2260)
    {
        float _S2261 = material_29.transmission * (1.0f - material_29.metallic);
        float3  _S2262 = negate_0(_S2258);
        float3  _S2263 = anisotropicLocal(dir_16, _S2259.tangent, _S2262);
        float _S2264 = anisotropicG1(_S2263, _S2259.alphas);
        return make_float3 (_S2261 * _S2264) * material_29.albedo;
    }
    float _S2265 = material_29.transmission * (1.0f - material_29.metallic);
    float _S2266 = material_29.roughness;
    float _S2267 = smithG1(_S2266 * _S2266, (F32_abs((dot_0(n_18, dir_16)))));
    return make_float3 (_S2265 * _S2267) * material_29.albedo;
}

__device__ float hairRow(float3  in_dir_15, float3  t_25, float3  out_dir_5, uint p_14, float w_2, float alpha_20, uint nt_0)
{
    uint _S2268 = p_14 % 4U;
    float _S2269 = w_2 * HAIR_WIDTHS_0[_S2268];
    float _S2270 = (F32_asin((clamp_1(dot_0(out_dir_5, t_25), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_15, t_25), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S2268] * alpha_20;
    return ((F32_asinh((_S2270 / _S2269))) / (F32_asinh((3.14159274101257324f / _S2269))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_16, float3  t_26, float3  out_dir_6, uint np_0)
{
    float3  _S2271 = worldToTangent(out_dir_6, t_26);
    float3  _S2272 = worldToTangent(in_dir_16, t_26);
    return (F32_frac((((F32_atan2((_S2271.z), (_S2271.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S2272.z), (1.17549435082228751e-38f - _S2272.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_17, float3  t_27, uint p_15, float row_0, float column_0, float w_3, float alpha_21, uint nt_1, uint np_1)
{
    float3  _S2273 = worldToTangent(in_dir_17, t_27);
    uint _S2274 = p_15 % 4U;
    float _S2275 = w_3 * HAIR_WIDTHS_0[_S2274];
    float _S2276 = (F32_asin((clamp_1(dot_0(in_dir_17, t_27), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S2274] * alpha_21 + _S2275 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S2275))))));
    float _S2277 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S2273.z), (1.17549435082228751e-38f - _S2273.x)));
    float _S2278 = (F32_cos((_S2276)));
    float3  _S2279 = tangentToWorld(make_float3 (_S2278 * (F32_cos((_S2277))), (F32_sin((_S2276))), _S2278 * (F32_sin((_S2277)))), t_27);
    return _S2279;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_19, BSDFMaterial material_30, float coverage_1)
{
    float3  _S2280;
    if((material_30.ior) == 1.0f)
    {
        float3  _S2281 = straightThrough(toward_1, n_19, material_30);
        _S2280 = _S2281;
    }
    else
    {
        _S2280 = make_float3 (0.0f);
    }
    return _S2280 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_9, Reservoir r_10, bool replay_3, float scale_13, Selection * sel_9)
{
    Domain _S2282 = dom_9;
    Reservoir _S2283 = r_10;
    Shift _S2284 = walk_0(&_S2282, &_S2283, replay_3, scale_13, sel_9);
    return _S2284;
}

__device__ Shift shift_hook(Domain dom_10, Reservoir r_11)
{
    Domain _S2285 = dom_10;
    Reservoir _S2286 = r_11;
    Shift _S2287 = shift_0(&_S2285, &_S2286);
    return _S2287;
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
