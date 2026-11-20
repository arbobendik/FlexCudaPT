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
    float3  _S179 = (fcptEnvMapSample((dir_1), (0U), (3U)));
    float3  _S180 = context_0->extinction_behind;
    float3  _S181 = context_0->extinction_front;
    float3  _S182 = _slang_select(_S178, _S181,_S180);
    uint _S183 = context_0->fillings.x;
    uint _S184 = context_0->fillings.y;
    uint _S185 = _slang_select(_S178, _S184,_S183);
    uint _S186 = context_0->depth;
    uint _S187 = context_0->lobe;
    bool _S188 = context_0->surface;
    bool _S189;
    if(_S188)
    {
        _S189 = !context_0->fiber;
    }
    else
    {
        _S189 = false;
    }
    float _S190 = context_0->length;
    float _S191 = context_0->width;
    FKHit _S192 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    float3  _S193 = (fcptShadowTransmittanceIn((_S177), (4.294967296e+09f), (_S182), (_S185), (random_state_0), (_S186), (_S187), (_S189), (_S190), (_S191), (_S192), (_S192)));
    return _S179 * _S193;
}

static __device__ uint searchCDF_0(uint2  start_4, uint2  step_0, uint count_1, float u_0)
{
    uint _S194 = count_1 - 1U;
    uint low_0 = 0U;
    uint high_0 = _S194;
    for(;;)
    {
        if(low_0 < high_0)
        {
        }
        else
        {
            break;
        }
        uint _S195 = (low_0 + high_0) / 2U;
        float4  _S196 = (fcptEnvironmentCdf((start_4 + step_0 * make_uint2 (_S195))));
        bool _S197 = (_S196.x) > u_0;
        if(_S197)
        {
            high_0 = _S195;
        }
        else
        {
            uint _S198 = _S195 + 1U;
            low_0 = _S198;
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
    float3  _S199 = ((((light_dir_0)) * make_float3(rnorm3df(((light_dir_0)).x, ((light_dir_0)).y, ((light_dir_0)).z))));
    bool _S200 = (dot_0(smooth_n_0, _S199)) < 0.0f;
    if(_S200)
    {
        return make_float3 (0.0f);
    }
    float3  _S201 = make_float3 (geometry_offset_0) * smooth_n_0;
    float3  _S202 = origin_2 + _S201;
    FKRay _S203 = Ray_x24init_0(_S202, _S199);
    bool _S204 = (dot_0(context_1->side, light_dir_0 + _S201)) > 0.0f;
    float _S205 = shadowLength(light_dir_0);
    float3  _S206 = context_1->extinction_behind;
    float3  _S207 = context_1->extinction_front;
    float3  _S208 = _slang_select(_S204, _S207,_S206);
    uint _S209 = context_1->fillings.x;
    uint _S210 = context_1->fillings.y;
    uint _S211 = _slang_select(_S204, _S210,_S209);
    uint _S212 = context_1->depth;
    uint _S213 = context_1->lobe;
    bool _S214 = context_1->surface;
    bool _S215;
    if(_S214)
    {
        _S215 = !context_1->fiber;
    }
    else
    {
        _S215 = false;
    }
    float _S216 = context_1->length;
    float _S217 = context_1->width;
    FKHit _S218;
    if(context_1->fiber)
    {
        _S218 = context_1->own;
    }
    else
    {
        _S218 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    }
    float3  _S219 = (fcptShadowTransmittanceIn((_S203), (_S205), (_S208), (_S211), (random_state_1), (_S212), (_S213), (_S215), (_S216), (_S217), (_S218), (*light_0)));
    return _S219;
}

__device__ float sine(float c_0)
{
    return (F32_sqrt(((F32_max((1.0f - c_0 * c_0), (0.0f))))));
}

__device__ float cosSubClamped(float sin_a_0, float cos_a_0, float sin_b_0, float cos_b_0)
{
    float _S220 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    bool _S221 = cos_a_0 > cos_b_0;
    float _S222 = _slang_select(_S221, 1.0f,_S220);
    return _S222;
}

__device__ float importance(LightNode node_0, float3  p_9, float3  normal_0)
{
    float3  _S223 = (node_0.low + node_0.high) * make_float3 (0.5f);
    float3  _S224 = node_0.high - node_0.low;
    float3  _S225 = p_9 - _S223;
    float3  _S226 = ((((_S225)) * make_float3(rnorm3df(((_S225)).x, ((_S225)).y, ((_S225)).z))));
    float _S227 = dot_0(_S225, _S225);
    float _S228 = dot_0(_S224, _S224) / 4.0f;
    float _S229 = (F32_abs((dot_0(node_0.w, _S226))));
    float _S230 = sine(node_0.cos_theta_o);
    float _S231 = (F32_sqrt(((F32_max((1.0f - _S228 / _S227), (0.0f))))));
    bool _S232 = _S227 < _S228;
    float _S233 = _slang_select(_S232, -1.0f,_S231);
    float _S234 = sine(_S233);
    float _S235 = sine(_S229);
    float _S236 = cosSubClamped(_S235, _S229, _S230, node_0.cos_theta_o);
    float _S237 = sine(_S229);
    float _S238 = _S237 * node_0.cos_theta_o - _S229 * _S230;
    bool _S239 = _S229 > (node_0.cos_theta_o);
    float _S240 = _slang_select(_S239, 0.0f,_S238);
    float _S241 = cosSubClamped(_S240, _S236, _S234, _S233);
    bool _S242 = _S241 <= 0.0f;
    if(_S242)
    {
        return 0.0f;
    }
    float _S243 = - dot_0(_S226, normal_0);
    float _S244 = node_0.phi * _S241 / (F32_max((_S227), (length_0(_S224) / 2.0f)));
    float _S245 = sine(_S243);
    float _S246 = cosSubClamped(_S245, _S243, _S234, _S233);
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
        FKLight _S287 = (fcptLight((_S285.y)));
        float _S288 = sphereDensity(_S287.position, _S287.variance, start_5);
        return probability_1 * _S288;
    }
    uint _S289 = _S285.y;
    uint _S290 = (fcptTriangleOffset((_S289)));
    Matrix<float, 3, 3>  _S291 = (fcptWorldTriangle((_S289), (_S290 + _S285.z)));
    float _S292 = solidAngle(probability_1, cross_0(_S291.rows[int(1)] - _S291.rows[int(0)], _S291.rows[int(2)] - _S291.rows[int(0)]), light_point_0 - start_5);
    return _S292;
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
    Random _S293;
    (&_S293)->state = state_0;
    (&_S293)->value = value_0;
    return _S293;
}

__device__ Random pcg(uint state_1)
{
    uint _S294 = hash(state_1);
    float value_1 = float(_S294 >> int(8)) * 5.9604644775390625e-08f;
    return Random_x24init_0(_S294, value_1);
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
    uint2  _S295 = (fcptEnvironmentCdfSize());
    uint2  _S296 = _S295 - make_uint2 (1U, 0U);
    float2  _S297 = make_float2 ((F32_atan2((- dir_2.y), (dir_2.x))) / 6.28318548202514648f + 0.5f, (F32_acos((clamp_1(dir_2.z, -1.0f, 1.0f)))) / 3.14159274101257324f);
    float2  _S298 = make_float2 ((float)_S296.x, (float)_S296.y);
    float2  _S299 = _S297 * _S298;
    uint2  _S300 = make_uint2 ((uint)_S299.x, (uint)_S299.y);
    uint2  _S301 = min_0(_S300, _S296 - make_uint2 (1U));
    float4  _S302 = (fcptEnvironmentCdf((_S301)));
    float _S303 = _S302.y;
    uint _S304 = _S296.x;
    float4  _S305 = (fcptEnvironmentCdf((make_uint2 (_S304, _S301.y))));
    float _S306 = _S303 * _S305.y;
    return _S306 * float(_S304 * _S296.y) / (19.73921012878417969f * length_1(float2 {dir_2.x, dir_2.y}));
}

static __device__ float3  negate_0(float3  x_13)
{
    return - x_13;
}

static __device__ float sign_0(float e_1)
{
    bool _S307 = e_1 < 0.0f;
    float _S308 = _slang_select(_S307, -1.0f,0.0f);
    bool _S309 = e_1 > 0.0f;
    float _S310 = _slang_select(_S309, 1.0f,_S308);
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
    float3  _S362 = make_float3 (1.0f, 0.0f, 0.0f);
    float3  _S363 = make_float3 (- _S360, _S359, 0.0f);
    float _S364 = (rsqrtf((_S361)));
    float3  _S365 = _S363 * make_float3 (_S364);
    bool _S366 = _S361 > 0.0f;
    float3  _S367 = _slang_select(_S366, _S365,_S362);
    float3  _S368 = cross_0(_S358, _S367);
    float _S369 = (F32_sqrt((U1_0)));
    float _S370 = 6.28318548202514648f * U2_0;
    float _S371 = _S369 * (F32_cos((_S370)));
    float t2_0 = _S369 * (F32_sin((_S370)));
    float _S372 = 0.5f * (1.0f + _S358.z);
    float t2_1 = (1.0f - _S372) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S371 * _S371)))))) + _S372 * t2_0;
    float3  _S373 = make_float3 (_S371) * _S367 + make_float3 (t2_1) * _S368;
    float _S374 = unshared_0(_S371);
    float _S375 = unshared_0(_S371);
    float3  _S376 = _S373 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S374 * _S375 - t2_1 * t2_1))))))) * _S358;
    float3  _S377 = make_float3 (alpha_0 * _S376.x, alpha_0 * _S376.y, (F32_max((0.0f), (_S376.z))));
    float3  _S378 = ((((_S377)) * make_float3(rnorm3df(((_S377)).x, ((_S377)).y, ((_S377)).z))));
    return _S378;
}

__device__ float3  worldToTangent(float3  v_2, float3  n_3)
{
    float3  a_3 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S379 = (F32_abs((dot_0(n_3, a_3)))) > 0.9999847412109375f;
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
    float3  _S381 = cross_0(n_3, a_4);
    float3  _S382 = ((((_S381)) * make_float3(rnorm3df(((_S381)).x, ((_S381)).y, ((_S381)).z))));
    float3  _S383 = cross_0(n_3, _S382);
    return make_float3 (dot_0(v_2, _S382), dot_0(v_2, n_3), dot_0(v_2, _S383));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_3, float3  n_i_2, float alpha_1, AnisotropicFrame frame_0, uint * random_state_2)
{
    Random _S384 = pcg(*random_state_2);
    Random _S385 = pcg(_S384.state);
    *random_state_2 = _S385.state;
    float _S386 = frame_0.alphas.x;
    bool _S387 = _S386 > 0.0f;
    if(_S387)
    {
        float3  _S388 = anisotropicLocal(v_3, frame_0.tangent, n_i_2);
        float _S389 = frame_0.alphas.y;
        float3  _S390 = make_float3 (_S386 * _S388.x, _S389 * _S388.y, _S388.z);
        float3  _S391 = ((((_S390)) * make_float3(rnorm3df(((_S390)).x, ((_S390)).y, ((_S390)).z))));
        float3  _S392 = sampleGGXVNDF(_S391, 1.0f, _S384.value, _S385.value);
        float3  _S393 = make_float3 (_S386 * _S392.x, _S389 * _S392.y, _S392.z);
        float3  _S394 = ((((_S393)) * make_float3(rnorm3df(((_S393)).x, ((_S393)).y, ((_S393)).z))));
        return make_float3 (_S394.x) * frame_0.tangent + make_float3 (_S394.y) * cross_0(n_i_2, frame_0.tangent) + make_float3 (_S394.z) * n_i_2;
    }
    float3  _S395 = worldToTangent(v_3, n_i_2);
    float3  _S396 = sampleGGXVNDF(float3 {_S395.x, _S395.z, _S395.y}, alpha_1, _S384.value, _S385.value);
    float3  _S397 = float3 {_S396.x, _S396.z, _S396.y};
    float3  _S398 = tangentToWorld(_S397, n_i_2);
    return _S398;
}

__device__ __forceinline__ float3  sampledHalf(float3  v_4, float3  n_i_3, float alpha_2, AnisotropicFrame frame_1, uint random_state_3)
{
    uint state_2 = random_state_3;
    float3  _S399 = sampleHalfVector(v_4, n_i_3, alpha_2, frame_1, &state_2);
    return _S399;
}

__device__ __forceinline__ float3  refractedHalf(float3  in_dir_0, float3  out_dir_0, float3  n_4, float eta_i_0, float eta_o_0)
{
    float3  _S400 = negate_0(in_dir_0);
    float3  _S401 = negate_0(make_float3 (eta_i_0) * _S400 + make_float3 (eta_o_0) * out_dir_0);
    float3  _S402 = ((((_S401)) * make_float3(rnorm3df(((_S401)).x, ((_S401)).y, ((_S401)).z))));
    float _S403 = sign_0(dot_0(n_4, _S400));
    float _S404 = sign_0(dot_0(_S401, n_4 * make_float3 (_S403)));
    return _S402 * make_float3 (_S404);
}

__device__ __forceinline__ float3  reflectedHalf(float3  in_dir_1, float3  out_dir_1)
{
    float3  _S405 = negate_0(in_dir_1);
    float3  _S406 = _S405 + out_dir_1;
    float3  _S407 = ((((_S406)) * make_float3(rnorm3df(((_S406)).x, ((_S406)).y, ((_S406)).z))));
    return _S407;
}

static __device__ float3  refract_0(float3  i_5, float3  n_5, float eta_0)
{
    float _S408 = dot_0(n_5, i_5);
    float _S409 = 1.0f - eta_0 * eta_0 * (1.0f - _S408 * _S408);
    if(_S409 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_5 - make_float3 (eta_0 * _S408 + (F32_sqrt((_S409)))) * n_5;
}

__device__ float fresnel(float cos_theta_0, float eta_i_1, float eta_o_1)
{
    float _S410 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S411 = eta_i_1 / eta_o_1 * _S410;
    bool _S412 = _S411 < 1.0f;
    float kr_0;
    if(_S412)
    {
        float _S413 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S411 * _S411))))));
        bool _S414 = eta_i_1 == eta_o_1;
        float _S415 = _slang_select(_S414, cos_theta_0,_S413);
        float _S416 = eta_o_1 * cos_theta_0;
        float _S417 = eta_i_1 * _S415;
        float _S418 = (_S416 - _S417) / (_S416 + _S417);
        float _S419 = eta_i_1 * cos_theta_0;
        float _S420 = eta_o_1 * _S415;
        float _S421 = (_S419 - _S420) / (_S419 + _S420);
        float _S422 = (_S418 * _S418 + _S421 * _S421) / 2.0f;
        kr_0 = _S422;
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
    float _S423 = dot_0(ggx_n_0, v_5);
    float _S424 = eta_i_2 / eta_o_2;
    float3  _S425 = refract_0(in_dir_2, ggx_n_0, _S424);
    float3  _S426 = ((((_S425)) * make_float3(rnorm3df(((_S425)).x, ((_S425)).y, ((_S425)).z))));
    float _S427 = (F32_min(((F32_sqrt((material_2.specular_level))) * (F32_abs((eta_i_2 - eta_o_2))) / (eta_i_2 + eta_o_2)), (0.9999847412109375f)));
    float _S428 = _S427 * _S427;
    float _S429 = (1.0f + _S427) / (1.0f - _S427);
    float _S430 = (F32_abs((_S423)));
    bool _S431 = eta_i_2 > eta_o_2;
    float _S432 = _slang_select(_S431, _S429,1.0f);
    float _S433 = _slang_select(_S431, 1.0f,_S429);
    float _S434 = fresnel(_S430, _S432, _S433);
    bool _S435 = (eta_i_2 * eta_i_2 * (1.0f - _S423 * _S423)) >= (eta_o_2 * eta_o_2);
    float3  _S436 = material_2.specular_tint * make_float3 (_S428);
    float3  _S437 = _S436 + (make_float3 (1.0f) - _S436) * make_float3 (_S434 - _S428) / make_float3 (1.0f - _S428);
    float3  _S438 = make_float3 (1.0f);
    float3  _S439 = _slang_select(_S435, _S438,_S437);
    float3  _S440 = make_float3 (0.0f);
    float sheen_component_0;
    float3  sheen_1;
    float3  scale_1;
    if(sheen_profile_0.on)
    {
        float _S441 = (F32_min((sheen_profile_0.albedo), (1.0f)));
        float3  _S442 = make_float3 (1.0f) - material_2.sheen * make_float3 (_S441);
        float _S443 = rgb_to_greyscale(material_2.sheen);
        float _S444 = _S443 * _S441;
        float3  _S445 = material_2.sheen / make_float3 ((F32_max((sheen_profile_0.albedo), (1.0f))));
        sheen_component_0 = _S444;
        sheen_1 = _S445;
        scale_1 = _S442;
    }
    else
    {
        sheen_component_0 = 0.0f;
        sheen_1 = _S440;
        scale_1 = _S438;
    }
    float _S446 = (F32_abs((material_2.toon.x)));
    bool _S447 = _S446 > 0.0f;
    float toon_component_0;
    float3  toon_1;
    if(_S447)
    {
        float _S448 = (F32_min((_S446), (1.0f)));
        float3  scale_2 = scale_1 * make_float3 (1.0f - _S448);
        float _S449 = rgb_to_greyscale(material_2.albedo);
        float _S450 = _S448 * _S449;
        float3  _S451 = make_float3 (_S448) * material_2.albedo;
        toon_component_0 = _S450;
        toon_1 = _S451;
        scale_1 = scale_2;
    }
    else
    {
        toon_component_0 = 0.0f;
        toon_1 = _S440;
    }
    bool _S452 = (material_2.metallic) > 0.0f;
    float3  rebounce_0;
    if(_S452)
    {
        float _S453 = frame_2.alphas.x;
        float _S454 = (F32_sqrt(((F32_min((_S453), (frame_2.alphas.y))))));
        bool _S455 = _S453 > 0.0f;
        float _S456 = _slang_select(_S455, _S454,material_2.roughness);
        float _S457 = _S456 * _S456;
        float _S458 = (F32_pow((_S457), (1.81585001945495605f))) * (2.15371990203857422f - 0.73285001516342163f * _S457) / (1.0f + 1.28094995021820068f * _S457);
        bool _S459 = _S457 > 0.0f;
        float _S460 = _slang_select(_S459, _S458,0.0f);
        float _S461 = clamp_1(dot_0(n_i_4, v_5), 0.0f, 1.0f);
        float _S462 = _S457 * _S456;
        float _S463 = (F32_min((1.00064504146575928f - _S456 * (0.00375499995425344f + _S461 * (-0.04133399948477745f + _S461 * (-0.90938502550125122f + _S461 * 0.35275399684906006f))) - _S457 * (0.27602800726890564f + _S461 * (1.27023398876190186f + _S461 * 0.04740000143647194f)) - _S462 * (0.31452900171279907f - _S461 * 0.34830701351165771f) + _S462 * _S456 * 0.27229699492454529f), (1.0f)));
        float3  _S464 = min_1(make_float3 (1.0f) / (make_float3 (1.0f) - material_2.albedo * make_float3 (_S460)), make_float3 (1.0f / (F32_max((_S463), (0.0000152587890625f)))));
        rebounce_0 = _S464;
    }
    else
    {
        rebounce_0 = _S438;
    }
    float3  _S465 = mix_0(_S439, material_2.albedo * rebounce_0, material_2.metallic);
    float3  F_1 = _S465 * scale_1;
    float _S466 = rgb_to_greyscale(F_1);
    float _S467 = 1.0f - material_2.metallic;
    float3  _S468 = make_float3 (1.0f) - _S439;
    float3  _S469 = make_float3 ((1.0f - material_2.transmission) * _S467) * _S468 * scale_1;
    float3  _S470 = make_float3 (material_2.transmission * _S467) * _S468 * scale_1;
    float _S471 = (F32_max((_S466), (0.0f)));
    float _S472 = rgb_to_greyscale(_S469);
    float _S473 = (F32_max((_S472), (0.0f)));
    float _S474 = rgb_to_greyscale(_S470);
    float _S475 = sign_0(length_0(_S426));
    float _S476 = (F32_max((_S474 * _S475), (0.0f)));
    float _S477 = _S471 + _S473 + _S476 + toon_component_0;
    float _S478 = (F32_min((sheen_component_0), (1.0f)));
    bool _S479 = sheen_component_0 > 0.0f;
    bool _S480;
    if(_S479)
    {
        _S480 = !(_S477 > 0.0f);
    }
    else
    {
        _S480 = false;
    }
    float _S481 = _slang_select(_S480, 1.0f,_S478);
    float _S482 = (1.0f - _S481) / (F32_max((_S477), (0.0000152587890625f)));
    float _S483 = _S473 * _S482;
    float _S484 = _S471 * _S482;
    float _S485 = _S476 * _S482;
    return Weights_x24init_0(_S423, _S426, F_1, 1.0f, _S469, _S470, _S483, _S484, _S485, _S481, toon_component_0 * _S482, sheen_1, toon_1);
}

__device__ float translucentShare(BSDFMaterial material_3)
{
    float _S486 = rgb_to_greyscale(material_3.translucent);
    float _S487 = rgb_to_greyscale(material_3.albedo);
    float _S488 = _S486 / (_S487 + _S486);
    bool _S489 = _S486 > 0.0f;
    float _S490 = _slang_select(_S489, _S488,0.0f);
    return _S490;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float n_i_dot_v_0, BSDFMaterial material_4, Weights w_1)
{
    float _S491 = translucentShare(material_4);
    float _S492 = w_1.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S493 = w_1.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S494 = 1.0f - _S491;
    bool _S495 = n_i_dot_l_0 < 0.0f;
    float _S496 = _slang_select(_S495, _S491,_S494);
    float _S497 = _S493 * _S496;
    bool _S498 = _S491 > 0.0f;
    float _S499 = _slang_select(_S498, _S497,_S492);
    bool _S500 = n_i_dot_v_0 > 0.0f;
    float _S501 = _slang_select(_S500, _S499,0.0f);
    return _S501;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_5, BSDFMaterial material_5, Weights w_2)
{
    float _S502 = translucentShare(material_5);
    bool _S503 = (dot_0(n_i_5, l_0)) < 0.0f;
    float3  _S504 = _slang_select(_S503, material_5.translucent,material_5.albedo);
    float _S505 = 1.0f - _S502;
    float _S506 = _slang_select(_S503, _S502,_S505);
    float3  _S507 = _S504 / make_float3 (_S506);
    bool _S508 = _S502 > 0.0f;
    float3  _S509 = _slang_select(_S508, _S507,material_5.albedo);
    return w_2.diffuse_weight * _S509 / make_float3 (w_2.p_diffuse);
}

__device__ float smithG1(float alpha_3, float n_dot_x_0)
{
    float _S510 = alpha_3 * alpha_3;
    float _S511 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S510 + (1.0f - _S510) * n_dot_x_0 * n_dot_x_0))));
    bool _S512 = alpha_3 > 0.0f;
    float _S513 = _slang_select(_S512, _S511,1.0f);
    return _S513;
}

__device__ float trowbridgeReitz(float alpha_4, float n_dot_h_0)
{
    float _S514 = alpha_4 * alpha_4;
    float _S515 = (1.0f - n_dot_h_0) * (1.0f + n_dot_h_0) + _S514 * n_dot_h_0 * n_dot_h_0;
    return _S514 / (F32_max((3.14159274101257324f * _S515 * _S515), (1.17549435082228751e-38f)));
}

__device__ float anisotropicG1(float3  w_3, float2  alphas_1)
{
    float _S516 = (F32_max((w_3.z), (0.0f)));
    return 2.0f * _S516 / (_S516 + length_0(make_float3 (alphas_1.x * w_3.x, alphas_1.y * w_3.y, _S516)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_2)
{
    float _S517 = alphas_2.x;
    float _S518 = h_0.x / _S517;
    float _S519 = alphas_2.y;
    float _S520 = h_0.y / _S519;
    float _S521 = h_0.z;
    float _S522 = _S518 * _S518 + _S520 * _S520 + _S521 * _S521;
    return 1.0f / (F32_max((3.14159274101257324f * _S517 * _S519 * _S522 * _S522), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float3  v_6, float3  h_1, float3  n_i_6, float n_i_dot_v_1, float alpha_5, AnisotropicFrame frame_3, float v_dot_h_1)
{
    float _S523 = dot_0(n_i_6, h_1);
    float _S524 = smithG1(alpha_5, n_i_dot_v_1);
    float _S525 = _S524 * v_dot_h_1;
    float _S526 = trowbridgeReitz(alpha_5, _S523);
    float _S527 = _S525 * _S526 / n_i_dot_v_1;
    bool _S528 = alpha_5 > 0.0f;
    bool _S529;
    if(_S528)
    {
        _S529 = v_dot_h_1 > 0.0f;
    }
    else
    {
        _S529 = false;
    }
    if(_S529)
    {
        _S529 = _S523 > 0.0f;
    }
    else
    {
        _S529 = false;
    }
    if(_S529)
    {
        _S529 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S529 = false;
    }
    float _S530 = _slang_select(_S529, _S527,0.0f);
    bool _S531 = (frame_3.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S531)
    {
        float3  _S532 = anisotropicLocal(v_6, frame_3.tangent, n_i_6);
        float _S533 = anisotropicG1(_S532, frame_3.alphas);
        float3  _S534 = anisotropicLocal(h_1, frame_3.tangent, n_i_6);
        float _S535 = anisotropicD(_S534, frame_3.alphas);
        float _S536 = _S533 * _S535;
        float _S537 = _S536 * v_dot_h_1 / n_i_dot_v_1;
        bool _S538 = v_dot_h_1 > 0.0f;
        if(_S538)
        {
            _S529 = _S523 > 0.0f;
        }
        else
        {
            _S529 = false;
        }
        if(_S529)
        {
            _S529 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S529 = false;
        }
        float _S539 = _slang_select(_S529, _S537,0.0f);
        pdf_h_0 = _S539;
    }
    else
    {
        pdf_h_0 = _S530;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float l_dot_h_0, float pdf_h_1, Weights w_4, float eta_i_3, float eta_o_3)
{
    float _S540 = eta_i_3 * w_4.v_dot_h + eta_o_3 * l_dot_h_0;
    float _S541 = w_4.p_refract * pdf_h_1 * eta_o_3 * eta_o_3 * (F32_abs((l_dot_h_0))) / (_S540 * _S540);
    bool _S542 = eta_i_3 != eta_o_3;
    bool _S543;
    if(_S542)
    {
        _S543 = l_dot_h_0 < 0.0f;
    }
    else
    {
        _S543 = false;
    }
    float _S544 = _slang_select(_S543, _S541,0.0f);
    return _S544;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_7, float alpha_6, AnisotropicFrame frame_4, BSDFMaterial material_6, Weights w_5)
{
    float _S545 = - dot_0(n_i_7, l_1);
    float _S546 = smithG1(alpha_6, (F32_max((_S545), (0.0f))));
    bool _S547 = (frame_4.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S547)
    {
        float3  _S548 = negate_0(n_i_7);
        float3  _S549 = anisotropicLocal(l_1, frame_4.tangent, _S548);
        float _S550 = anisotropicG1(_S549, frame_4.alphas);
        G1_l_0 = _S550;
    }
    else
    {
        G1_l_0 = _S546;
    }
    bool _S551 = (material_6.ior) == 1.0f;
    float _S552 = _slang_select(_S551, 1.0f,G1_l_0);
    return w_5.refract_weight * make_float3 (_S552) * material_6.albedo / make_float3 (w_5.p_refract);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_1, float n_i_dot_v_2, Weights w_6)
{
    float _S553 = w_6.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S554 = n_i_dot_l_1 > 0.0f;
    bool _S555;
    if(_S554)
    {
        _S555 = n_i_dot_v_2 > 0.0f;
    }
    else
    {
        _S555 = false;
    }
    float _S556 = _slang_select(_S555, _S553,0.0f);
    return _S556;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  v_7, float3  n_i_8, BSDFMaterial material_7, Weights w_7)
{
    float3  _S557 = l_2 + v_7;
    float3  _S558 = ((((_S557)) * make_float3(rnorm3df(((_S557)).x, ((_S557)).y, ((_S557)).z))));
    float _S559 = dot_0(n_i_8, _S558);
    float _S560 = (F32_max((dot_0(n_i_8, l_2)), (0.0f)));
    float _S561 = (F32_max((dot_0(n_i_8, v_7)), (0.0f)));
    float _S562 = 1.0f / (F32_max((material_7.sheen_roughness), (0.05000000074505806f)));
    float _S563 = 1.0f - _S559 * _S559;
    float _S564 = (2.0f + _S562) * (F32_pow(((F32_max((_S563), (0.0f)))), (0.5f * _S562))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S560 + _S561 - _S560 * _S561)), (0.0000152587890625f)));
    bool _S565 = (material_7.velvet) > 0.0f;
    float f_1;
    if(_S565)
    {
        float _S566 = (F32_max((material_7.sheen_roughness), (0.00999999977648258f)));
        float _S567 = _S566 * _S566;
        float _S568 = (F32_max((_S563), (0.0000152587890625f)));
        float _S569 = (F32_exp((- _S559 * _S559 / (_S568 * _S567)))) / (3.14159274101257324f * _S567 * _S568 * _S568) * (F32_min((1.0f), (2.0f * _S559 * (F32_min((_S560), (_S561))) / (F32_max(((F32_abs((dot_0(_S558, v_7))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S560 * _S561), (0.0000152587890625f)));
        f_1 = _S569;
    }
    else
    {
        f_1 = _S564;
    }
    return w_7.sheen * make_float3 (f_1 * _S560 * 2.0f * 3.14159274101257324f / w_7.p_sheen_velvet);
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
    float _S570 = (F32_max((1.0f - (t_13 - a_5) / (F32_max((s_0), (0.0000152587890625f)))), (0.0f)));
    bool _S571 = t_13 < a_5;
    float _S572 = _slang_select(_S571, 1.0f,_S570);
    return _S572;
}

__device__ __forceinline__ float toonIntegral(float t_14, float a_6, float s_1, bool glossy_0)
{
    float _S573 = (F32_min((t_14), (a_6)));
    float _S574 = (F32_sin((_S573)));
    float _S575 = _S574 * _S574 / 2.0f;
    float _S576 = 1.0f - (F32_cos((_S573)));
    float _S577 = _slang_select(glossy_0, _S576,_S575);
    bool _S578 = t_14 > a_6;
    bool _S579;
    if(_S578)
    {
        _S579 = s_1 > 0.0f;
    }
    else
    {
        _S579 = false;
    }
    float integral_0;
    if(_S579)
    {
        if(glossy_0)
        {
            float _S580 = (F32_cos((a_6)));
            float _S581 = (F32_cos((t_14)));
            integral_0 = (1.0f + a_6 / s_1) * (_S580 - _S581) - ((F32_sin((t_14))) - t_14 * _S581 - ((F32_sin((a_6))) - a_6 * _S580)) / s_1;
        }
        else
        {
            float _S582 = 2.0f * a_6;
            float _S583 = (F32_cos((_S582)));
            float _S584 = 2.0f * t_14;
            float _S585 = (F32_cos((_S584)));
            integral_0 = (1.0f + a_6 / s_1) * (_S583 - _S585) / 4.0f - ((F32_sin((_S584))) / 8.0f - t_14 * _S585 / 4.0f - ((F32_sin((_S582))) / 8.0f - a_6 * _S583 / 4.0f)) / s_1;
        }
        float integral_1 = _S577 + integral_0;
        integral_0 = integral_1;
    }
    else
    {
        integral_0 = _S577;
    }
    return integral_0;
}

static __device__ ToonProfile ToonProfile_x24init_0(bool glossy_1, float a_7, float s_2, float b_1, float norm_0, float view_0, float3  axis_0)
{
    ToonProfile _S586;
    (&_S586)->glossy = glossy_1;
    (&_S586)->a = a_7;
    (&_S586)->s = s_2;
    (&_S586)->b = b_1;
    (&_S586)->norm = norm_0;
    (&_S586)->view = view_0;
    (&_S586)->axis = axis_0;
    return _S586;
}

__device__ __forceinline__ ToonProfile toonProfile(float3  v_8, float3  n_i_9, BSDFMaterial material_8)
{
    float _S587 = material_8.toon.x;
    bool _S588 = _S587 < 0.0f;
    float _S589 = clamp_1(material_8.toon.y / _S587, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S590 = clamp_1(material_8.toon.z / _S587, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S591 = (F32_min((_S589 + _S590), (1.57079637050628662f)));
    float _S592 = dot_0(n_i_9, v_8);
    float _S593 = toonP((F32_acos(((F32_min((_S592), (1.0f)))))), _S589, _S590);
    float3  _S594 = make_float3 (2.0f * _S592) * n_i_9 - v_8;
    float3  _S595 = ((((_S594)) * make_float3(rnorm3df(((_S594)).x, ((_S594)).y, ((_S594)).z))));
    float3  _S596 = _slang_select(_S588, _S595,n_i_9);
    float _S597 = toonIntegral(_S591, _S589, _S590, _S588);
    return ToonProfile_x24init_0(_S588, _S589, _S590, _S591, 6.28318548202514648f * _S597, _S593, _S596);
}

__device__ __forceinline__ float toonPDF(float3  l_3, float3  n_i_10, ToonProfile profile_1, Weights w_8)
{
    float _S598 = dot_0(n_i_10, l_3);
    float _S599 = dot_0(l_3, profile_1.axis);
    float _S600 = _slang_select(profile_1.glossy, _S599,_S598);
    float _S601 = (F32_acos((clamp_1(_S600, -1.0f, 1.0f))));
    float _S602 = toonP(_S601, profile_1.a, profile_1.s);
    float _S603 = w_8.p_toon * _S602;
    float _S604 = _slang_select(profile_1.glossy, 1.0f,_S598);
    float _S605 = _S603 * _S604 / profile_1.norm;
    bool _S606;
    if(profile_1.glossy)
    {
        _S606 = true;
    }
    else
    {
        _S606 = _S598 > 0.0f;
    }
    float _S607 = _slang_select(_S606, _S605,0.0f);
    return _S607;
}

__device__ __forceinline__ float3  toonBSDF(float3  l_4, float3  n_i_11, ToonProfile profile_2, Weights w_9)
{
    float _S608 = (F32_max((dot_0(n_i_11, l_4)), (0.0f)));
    float _S609 = _slang_select(profile_2.glossy, _S608,profile_2.view);
    return w_9.toon * make_float3 (_S609) / make_float3 (w_9.p_toon);
}

__device__ __forceinline__ float reflectPDF(float pdf_h_2, Weights w_10)
{
    float _S610 = w_10.p_reflect * pdf_h_2 / (4.0f * w_10.v_dot_h);
    bool _S611 = pdf_h_2 > 0.0f;
    float _S612 = _slang_select(_S611, _S610,0.0f);
    return _S612;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_5, float3  n_i_12, float alpha_7, AnisotropicFrame frame_5, Weights w_11)
{
    float _S613 = dot_0(n_i_12, l_5);
    float _S614 = smithG1(alpha_7, (F32_max((_S613), (0.0f))));
    bool _S615 = (frame_5.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S615)
    {
        float3  _S616 = anisotropicLocal(l_5, frame_5.tangent, n_i_12);
        float _S617 = anisotropicG1(_S616, frame_5.alphas);
        G1_l_1 = _S617;
    }
    else
    {
        G1_l_1 = _S614;
    }
    return make_float3 (w_11.reflect_weight * G1_l_1) * w_11.F / make_float3 (w_11.p_reflect);
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_3, float3  out_dir_2, float3  n_6, BSDFMaterial material_9, float eta_i_4, float eta_o_4, bool refracted_2, uint random_state_4, FixedArray<float3 , 5>  * throughputs_0, FixedArray<float, 5>  * pdfs_0)
{
    float3  ggx_n_1;
    float3  _S618 = negate_0(in_dir_3);
    float _S619 = dot_0(n_6, _S618);
    float _S620 = sign_0(_S619);
    float3  _S621 = n_6 * make_float3 (_S620);
    float _S622 = dot_0(_S621, out_dir_2);
    float _S623 = material_9.roughness;
    float _S624 = _S623 * _S623;
    AnisotropicFrame _S625 = anisotropicFrame(material_9, _S621);
    SheenProfile _S626 = sheenProfile(_S618, _S621, material_9);
    float _S627 = rgb_to_greyscale(material_9.translucent);
    bool _S628 = _S627 > 0.0f;
    bool _S629 = (dot_0(n_6, out_dir_2) * _S619) < 0.0f;
    bool _S630 = (F32_abs((material_9.toon.x))) > 0.0f;
    uint _S631;
    if(_S630)
    {
        _S631 = 5U;
    }
    else
    {
        _S631 = 4U;
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
        float3  _S632 = make_float3 (0.0f);
        (*throughputs_0)[i_7] = _S632;
        (*pdfs_0)[i_7] = 0.0f;
        uint i_8 = i_7 + 1U;
        i_7 = i_8;
    }
    float3  _S633 = make_float3 (0.0f);
    Weights _S634 = Weights_x24init_0(0.0f, _S633, _S633, 0.0f, _S633, _S633, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, _S633, _S633);
    uint half_of_0 = 4294967295U;
    Weights w_12 = _S634;
    float3  ggx_n_2 = _S633;
    i_7 = 0U;
    for(;;)
    {
        if(i_7 < _S631)
        {
        }
        else
        {
            break;
        }
        uint _S635;
        if(i_7 == 3U)
        {
            _S635 = 4U;
        }
        else
        {
            if(i_7 == 4U)
            {
                _S635 = 6U;
            }
            else
            {
                _S635 = i_7;
            }
        }
        bool _S636 = _S635 == 0U;
        bool _S637;
        if(_S636)
        {
            _S637 = _S628;
        }
        else
        {
            _S637 = false;
        }
        bool _S638;
        if(_S637)
        {
            _S638 = _S629;
        }
        else
        {
            _S638 = _S635 == 1U;
        }
        bool _S639 = _S638 != refracted_2;
        if(_S639)
        {
            ggx_n_1 = ggx_n_2;
            uint i_9 = i_7 + 1U;
            ggx_n_2 = ggx_n_1;
            i_7 = i_9;
            continue;
        }
        uint _S640;
        if(_S635 == 6U)
        {
            _S640 = 0U;
        }
        else
        {
            if(_S635 == 4U)
            {
                _S640 = 2U;
            }
            else
            {
                _S640 = _S635;
            }
        }
        bool _S641 = _S640 != half_of_0;
        uint half_of_1;
        Weights w_13;
        if(_S641)
        {
            bool _S642 = _S640 == 0U;
            if(_S642)
            {
                float3  _S643 = sampledHalf(_S618, _S621, _S624, _S625, random_state_4);
                ggx_n_1 = _S643;
            }
            else
            {
                bool _S644 = _S640 == 1U;
                if(_S644)
                {
                    float3  _S645 = refractedHalf(in_dir_3, out_dir_2, n_6, eta_i_4, eta_o_4);
                    ggx_n_1 = _S645;
                }
                else
                {
                    float3  _S646 = reflectedHalf(in_dir_3, out_dir_2);
                    ggx_n_1 = _S646;
                }
            }
            Weights _S647 = lobeWeights(in_dir_3, _S618, _S621, ggx_n_1, _S625, _S626, material_9, eta_i_4, eta_o_4);
            w_13 = _S647;
            half_of_1 = _S640;
        }
        else
        {
            w_13 = w_12;
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S635)
        {
        case 0U:
            {
                float _S648 = diffusePDF(_S622, (F32_abs((_S619))), material_9, w_13);
                (*pdfs_0)[int(0)] = _S648;
                float3  _S649 = diffuseBSDF(out_dir_2, _S621, material_9, w_13);
                (*throughputs_0)[int(0)] = _S649;
                break;
            }
        case 1U:
            {
                float _S650 = dot_0(out_dir_2, ggx_n_1);
                float _S651 = vndfPDF(_S618, ggx_n_1, _S621, (F32_abs((_S619))), _S624, _S625, w_13.v_dot_h);
                float _S652 = refractPDF(_S650, _S651, w_13, eta_i_4, eta_o_4);
                (*pdfs_0)[int(1)] = _S652;
                float3  _S653 = refractBSDF(out_dir_2, _S621, _S624, _S625, material_9, w_13);
                (*throughputs_0)[int(1)] = _S653;
                break;
            }
        case 4U:
            {
                float _S654 = sheenVelvetPDF(_S622, (F32_abs((_S619))), w_13);
                (*pdfs_0)[int(3)] = _S654;
                float3  _S655 = sheenVelvetBSDF(out_dir_2, _S618, _S621, material_9, w_13);
                (*throughputs_0)[int(3)] = _S655;
                break;
            }
        case 6U:
            {
                ToonProfile _S656 = toonProfile(_S618, _S621, material_9);
                float _S657 = toonPDF(out_dir_2, _S621, _S656, w_13);
                (*pdfs_0)[int(4)] = _S657;
                float3  _S658 = toonBSDF(out_dir_2, _S621, _S656, w_13);
                (*throughputs_0)[int(4)] = _S658;
                break;
            }
        default:
            {
                float _S659 = vndfPDF(_S618, ggx_n_1, _S621, (F32_abs((_S619))), _S624, _S625, w_13.v_dot_h);
                float _S660 = reflectPDF(_S659, w_13);
                (*pdfs_0)[int(2)] = _S660;
                float3  _S661 = reflectBSDF(out_dir_2, _S621, _S624, _S625, w_13);
                (*throughputs_0)[int(2)] = _S661;
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
    ggx_n_1 = _S633;
    for(;;)
    {
        if(i_7 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S662 = ((*pdfs_0)[i_7]) > 0.0f;
        if(_S662)
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
    bool _S663 = wrongSide_0(is_inside_2, false, dir_3, surface_1->geometry_n);
    float3  _S664 = BSDF(in_dir_4, dir_3, surface_1->smooth_n, surface_1->material, eta_1.x, eta_1.y, _S663, random_state_5, terms_0, pdfs_1);
    float3  _S665 = make_float3 (0.0f);
    uint i_11 = 0U;
    float3  f_3 = _S665;
    for(;;)
    {
        if(i_11 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S666 = ((*pdfs_1)[i_11]) > 0.0f;
        if(_S666)
        {
            float3  _S667 = (*terms_0)[i_11] * make_float3 ((*pdfs_1)[i_11]) / make_float3 ((*pdfs_1)[i_11] + pdf_0);
            (*terms_0)[i_11] = _S667;
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
    FKSurface _S668 = surface_2;
    FixedArray<float3 , 5>  terms_1;
    FixedArray<float, 5>  pdfs_2;
    float3  _S669 = skyLobes_0(in_dir_5, dir_4, &_S668, eta_2, is_inside_3, pdf_1, random_state_6, &terms_1, &pdfs_2);
    return _S669;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_5, float3  radiance_0, float3  color_0, uint random_state_7)
{
    SkySample _S670;
    (&_S670)->dir = dir_5;
    (&_S670)->radiance = radiance_0;
    (&_S670)->color = color_0;
    (&_S670)->random_state = random_state_7;
    return _S670;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_3, float2  eta_3, bool is_inside_4, uint init_random_state_0, uint lobe_state_0, ShadowContext * context_2)
{
    uint2  _S671 = (fcptEnvironmentCdfSize());
    uint2  _S672 = make_uint2 (1U, 0U);
    uint2  _S673 = _S671 - _S672;
    Random _S674 = pcg(init_random_state_0);
    Random _S675 = pcg(_S674.state);
    Random _S676 = pcg(_S675.state);
    Random _S677 = pcg(_S676.state);
    uint _S678 = _S673.x;
    uint _S679 = searchCDF_0(make_uint2 (_S678, 0U), make_uint2 (0U, 1U), _S673.y, _S674.value);
    uint _S680 = searchCDF_0(make_uint2 (0U, _S679), _S672, _S678, _S675.value);
    float2  _S681 = make_float2 ((float)_S673.x, (float)_S673.y);
    float2  _S682 = (make_float2 (float(_S680), float(_S679)) + make_float2 (_S676.value, _S677.value)) / _S681 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S683 = _S682.y;
    float _S684 = (F32_sin((_S683)));
    float _S685 = _S682.x;
    float3  _S686 = make_float3 (- _S684 * (F32_cos((_S685))), _S684 * (F32_sin((_S685))), (F32_cos((_S683))));
    float _S687 = environmentPdf_0(_S686);
    float3  _S688 = skyBSDF(ray_0->unit_direction, _S686, *surface_3, eta_3, is_inside_4, _S687, lobe_state_0);
    bool _S689 = !(_S687 > 0.0f);
    bool _S690;
    if(_S689)
    {
        _S690 = true;
    }
    else
    {
        _S690 = all_1(_S688 == make_float3 (0.0f));
    }
    if(_S690)
    {
        float3  _S691 = make_float3 (0.0f);
        return SkySample_x24init_0(_S686, _S691, _S691, _S677.state);
    }
    float3  _S692 = skyRadiance_0(ray_0->origin, surface_3, is_inside_4, _S686, context_2, _S677.state);
    return SkySample_x24init_0(_S686, _S692, _S688 * _S692, _S677.state);
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
    SampleBSDF _S693 = (fcptConnectHair((surface_4->hair), ((&surface_4->material)->albedo), ((&surface_4->material)->specular_tint), (in_dir_6), (light_1->dir)));
    float3  _S694 = _S693.throughput * make_float3 (_S693.pdf);
    float _S695 = light_1->density;
    float _S696 = 1.0f + _S693.pdf * _S693.pdf / (light_1->density * light_1->density);
    bool _S697;
    if(competing_0)
    {
        _S697 = _S695 > 0.0f;
    }
    else
    {
        _S697 = false;
    }
    float _S698 = _slang_select(_S697, _S696,1.0f);
    return _S694 / make_float3 (_S698) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_6, float3  radiance_1, float density_0, uint random_state_8)
{
    TreeSample _S699;
    (&_S699)->dir = dir_6;
    (&_S699)->radiance = radiance_1;
    (&_S699)->density = density_0;
    (&_S699)->random_state = random_state_8;
    return _S699;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_12, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S700 = importance(first_1, p_12, normal_3);
    float _S701 = importance(second_1, p_12, normal_3);
    float2  _S702 = make_float2 (_S700, _S701);
    bool _S703 = _S700 == 0.0f;
    bool _S704;
    if(_S703)
    {
        _S704 = _S701 == 0.0f;
    }
    else
    {
        _S704 = false;
    }
    if(_S704)
    {
        return 2U;
    }
    float _S705 = _S700 + _S701;
    bool _S706 = _S701 > 0.0f;
    if(_S706)
    {
        _S704 = (*pick_0 * _S705) >= _S700;
    }
    else
    {
        _S704 = false;
    }
    uint _S707 = uint(_S704);
    float _S708 = (F32_min(((*pick_0 * _S705 - float(_S707) * _S700) / _slang_vector_get_element(_S702, _S707)), (0.99999994039535522f)));
    *pick_0 = _S708;
    float _S709 = *probability_3 * (_slang_vector_get_element(_S702, _S707) / _S705);
    *probability_3 = _S709;
    return _S707;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_13, float u1_0, float u2_0)
{
    float3  _S710 = center_1 - p_13;
    float _S711 = radius_1 * radius_1 / dot_0(_S710, _S710);
    float _S712 = u1_0 * _S711 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S711), (0.0f)))))));
    float _S713 = 2.0f * u1_0;
    bool _S714 = _S711 >= 1.0f;
    float _S715 = _slang_select(_S714, _S713,_S712);
    float _S716 = (F32_sqrt(((F32_max((_S715 * (2.0f - _S715)), (0.0f))))));
    float _S717 = 6.28318548202514648f * u2_0;
    float3  _S718 = make_float3 (_S716 * (F32_cos((_S717))), 1.0f - _S715, _S716 * (F32_sin((_S717))));
    float3  _S719 = ((((_S710)) * make_float3(rnorm3df(((_S710)).x, ((_S710)).y, ((_S710)).z))));
    float3  _S720 = tangentToWorld(_S718, _S719);
    return _S720;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S721 = center_2 - ray_1->origin;
    float _S722 = dot_0(_S721, ray_1->unit_direction);
    float _S723 = dot_0(_S721, _S721) - _S722 * _S722;
    float _S724 = radius_3 * radius_3;
    bool _S725 = _S723 > _S724;
    if(_S725)
    {
        return 4.294967296e+09f;
    }
    float _S726 = (F32_sqrt((_S724 - _S723)));
    float _S727 = _S722 - _S726;
    float _S728 = _S722 + _S726;
    bool _S729 = _S727 > 0.0000152587890625f;
    bool _S730;
    if(_S729)
    {
        _S730 = _S727 < max_len_0;
    }
    else
    {
        _S730 = false;
    }
    if(_S730)
    {
        return _S727;
    }
    bool _S731 = _S728 > 0.0000152587890625f;
    if(_S731)
    {
        _S730 = _S728 < max_len_0;
    }
    else
    {
        _S730 = false;
    }
    if(_S730)
    {
        return _S728;
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
    Random _S732 = pcg(init_random_state_1);
    Random _S733 = pcg(_S732.state);
    Random _S734 = pcg(_S733.state);
    float3  _S735 = make_float3 (0.0f);
    TreeSample _S736 = TreeSample_x24init_0(_S735, _S735, 0.0f, _S734.state);
    TreeSample sample_0 = _S736;
    float3  _S737 = _slang_select(sided_0, _S735,smooth_n_2);
    float3  _S738 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S732.value;
    float probability_4 = 1.0f;
    uint n_7 = 0U;
    for(;;)
    {
        uint4  _S739 = (fcptLightNode((n_7)));
        if((_S739.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S740 = (fcptLightSecond((n_7)));
        uint _S741 = n_7 + 1U;
        LightNode _S742 = (fcptLightBounds((_S741)));
        LightNode _S743 = (fcptLightBounds((_S740)));
        uint _S744 = pickChild(_S742, _S743, origin_4, _S737, &pick_1, &probability_4);
        bool _S745 = _S744 > 1U;
        if(_S745)
        {
            return sample_0;
        }
        bool _S746 = _S744 == 1U;
        uint _S747 = _slang_select(_S746, _S740,_S741);
        n_7 = _S747;
    }
    bool _S748 = n_7 == 0U;
    bool _S749;
    if(_S748)
    {
        LightNode _S750 = (fcptLightBounds((0U)));
        float _S751 = importance(_S750, origin_4, _S737);
        _S749 = !(_S751 > 0.0f);
    }
    else
    {
        _S749 = false;
    }
    if(_S749)
    {
        return sample_0;
    }
    uint4  _S752 = (fcptLightNode((n_7)));
    FKHit _S753 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S754 = (_S752.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S754)
    {
        FKLight _S755 = (fcptLight((_S752.y)));
        if(sided_0)
        {
            float _S756 = sign_0(dot_0(geometry_n_1, _S755.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S756);
            float3  _S757 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S757;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S738;
            lift_n_0 = smooth_n_2;
        }
        bool _S758 = (_S755.variance) == 0.0f;
        if(_S758)
        {
            float3  _S759 = _S755.position - emitter_point_0;
            float3  _S760 = ((((_S759)) * make_float3(rnorm3df(((_S759)).x, ((_S759)).y, ((_S759)).z))));
            (&sample_0)->dir = _S760;
            float3  _S761 = _S755.color * make_float3 (_S755.intensity) / make_float3 (dot_0(_S759, _S759) * probability_4);
            (&sample_0)->radiance = _S761;
            shadow_1 = _S759;
        }
        else
        {
            float3  _S762 = sampleSphere(_S755.position, _S755.variance, emitter_point_0, _S733.value, _S734.value);
            (&sample_0)->dir = _S762;
            float _S763 = sphereDensity(_S755.position, _S755.variance, emitter_point_0);
            float _S764 = probability_4 * _S763;
            (&sample_0)->density = _S764;
            float3  _S765 = pointLightRadiance(_S755.color, _S755.intensity, _S755.variance);
            float3  _S766 = _S765 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S766;
            FKRay _S767 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S768 = raySphere_0(_S755.position, _S755.variance, &_S767, 4.294967296e+09f);
            float3  _S769 = (&sample_0)->dir * make_float3 (_S768);
            shadow_1 = _S769;
        }
        emitter_0 = _S753;
        emitter_point_0 = _S735;
    }
    else
    {
        uint _S770 = _S752.y;
        uint _S771 = (fcptTriangleOffset((_S770)));
        uint _S772 = _S771 + _S752.z;
        Matrix<float, 3, 3>  _S773 = (fcptWorldTriangle((_S770), (_S772)));
        float _S774 = (F32_sqrt((_S733.value)));
        float2  _S775 = make_float2 (_S774 * (1.0f - _S734.value), _S774 * _S734.value);
        float3  _S776 = mul_0(make_float3 (1.0f - _S774, _S775.x, _S775.y), _S773);
        if(sided_0)
        {
            float _S777 = sign_0(dot_0(geometry_n_1, _S776 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S777);
            float3  _S778 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S778;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S779 = !((dot_0(smooth_n_2, _S776 - origin_4)) > 0.0f);
            if(_S779)
            {
                return sample_0;
            }
            emitter_point_0 = _S738;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S775, _S770, _S772, 0U, 0.0f);
        float3  _S780 = _S776 - emitter_point_0;
        float3  _S781 = ((((_S780)) * make_float3(rnorm3df(((_S780)).x, ((_S780)).y, ((_S780)).z))));
        (&sample_0)->dir = _S781;
        float _S782 = solidAngle(probability_4, cross_0(_S773.rows[int(1)] - _S773.rows[int(0)], _S773.rows[int(2)] - _S773.rows[int(0)]), _S780);
        (&sample_0)->density = _S782;
        bool _S783 = (fcptShadowFirst());
        bool _S784 = !_S783;
        if(_S784)
        {
            FKSurface _S785 = (fcptLightSurfaceAt((emitter_1), (_S776), (_S734.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S776 - origin_4))));
            (&sample_0)->random_state = _S785.random_state;
            float3  _S786 = _slang_select(_S785.skip, _S735,_S785.material.emissive);
            float3  _S787 = _S786 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S787;
        }
        shadow_1 = _S780;
        emitter_0 = emitter_1;
        emitter_point_0 = _S776;
    }
    FKHit _S788 = emitter_0;
    float3  _S789 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S734.state, &_S788);
    bool _S790 = (fcptShadowFirst());
    if(_S790)
    {
        _S749 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S749 = false;
    }
    if(_S749)
    {
        _S749 = !all_1(_S789 == _S735);
    }
    else
    {
        _S749 = false;
    }
    if(_S749)
    {
        FKSurface _S791 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S734.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S791.random_state;
        float3  _S792 = _slang_select(_S791.skip, _S735,_S791.material.emissive);
        float3  _S793 = _S792 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S793;
    }
    float3  _S794 = (&sample_0)->radiance * _S789;
    bool _S795 = all_1(_S789 == _S735);
    float3  _S796 = _slang_select(_S795, _S735,_S794);
    (&sample_0)->radiance = _S796;
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
    float _S797 = 1.0f / (1.0f + b_2 / a_8 * (b_2 / a_8));
    bool _S798 = b_2 > 0.0f;
    float _S799 = _slang_select(_S798, _S797,1.0f);
    return _S799;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S800 = vertex_0->none;
    if(_S800)
    {
        return 1.0f;
    }
    uint _S801 = (fcptLightSlot((*hit_1)));
    float _S802 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S801, light_point_1);
    float _S803 = powerHeuristic(vertex_0->pdf, _S802);
    return _S803;
}

static __device__ float3  environment_0(float3  dir_7, uint depth_0, uint lobe_0)
{
    uint2  _S804 = (fcptEnvironmentMapSize());
    bool _S805 = all_0(_S804 > make_uint2 (1U));
    if(_S805)
    {
        float3  _S806 = (fcptEnvMapSample((dir_7), (depth_0), (lobe_0)));
        return _S806;
    }
    float3  _S807 = (fcptAmbient());
    return _S807;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S808 = (fcptEnvironmentCdfSize());
    bool _S809 = !all_0(_S808 > make_uint2 (1U));
    if(_S809)
    {
        return false;
    }
    uint2  _S810 = (fcptEnvironmentMapSize());
    return all_0(_S810 > make_uint2 (1U));
}

static __device__ float escapeWeight_0(float pdf_2, float3  dir_8)
{
    bool _S811 = pdf_2 <= 0.0f;
    bool _S812;
    if(_S811)
    {
        _S812 = true;
    }
    else
    {
        bool _S813 = environmentMapped_0();
        _S812 = !_S813;
    }
    if(_S812)
    {
        return 1.0f;
    }
    float _S814 = environmentPdf_0(dir_8);
    return pdf_2 / (pdf_2 + _S814);
}

static __device__ void restir_duplicates_0(uint3  global_invocation_id_1, uint3  local_invocation_id_0, uint local_invocation_index_3)
{
    uint2  _S815 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S816 = make_int2 ((int)_S815.x, (int)_S815.y);
    uint _S817 = previousSeed_0(_S816);
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
            uint _S818 = previousSeed_0(_S816 + make_int2 (x_16, y_5));
            bool _S819 = _S818 == _S817;
            uint _S820 = _slang_select(_S819, 1U,0U);
            uint count_3 = count_2 + _S820;
            int x_17 = x_16 + int(1);
            x_16 = x_17;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S821 = float(count_2 - 1U) / 288.0f;
    bool _S822 = _S817 != 0U;
    float _S823 = _slang_select(_S822, _S821,0.0f);
    fcptStoreDuplication((_S816), (make_uint4 ((F32_asuint((_S823))), 0U, 0U, 0U)));
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
    float _S824 = rgb_to_greyscale(abs_0(f_5));
    return _S824;
}

__device__ uint stream(uint seed_3, uint index_0)
{
    uint _S825 = hash(index_0);
    uint _S826 = hash(seed_3 ^ _S825);
    return _S826;
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

__device__ void offer(Selection * sel_2, Reservoir candidate_0, float3  weight_0)
{
    float _S827 = resamplingTarget(weight_0);
    bool _S828 = _S827 > 0.0f;
    bool _S829;
    if(_S828)
    {
        _S829 = _S827 < 3.00000000549775576e+38f;
    }
    else
    {
        _S829 = false;
    }
    bool _S830 = !_S829;
    if(_S830)
    {
        return;
    }
    bool _S831 = sel_2->sums;
    if(_S831)
    {
        float3  _S832 = sel_2->color + weight_0;
        sel_2->color = _S832;
        return;
    }
    float _S833 = sel_2->w_sum + _S827;
    sel_2->w_sum = _S833;
    float3  _S834 = sel_2->color + weight_0;
    sel_2->color = _S834;
    Random _S835 = pcg(sel_2->random_state);
    sel_2->random_state = _S835.state;
    bool _S836 = (_S835.value * sel_2->w_sum) <= _S827;
    if(_S836)
    {
        sel_2->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_3;
    float3  _S837 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S837;
    float _S838 = r_3.jac * shifted_0.jac;
    (&candidate_1)->jac = _S838;
    offer(sel_3, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S839 = resamplingTarget((&r_4)->f);
    float _S840 = sel_4.w_sum / _S839;
    bool _S841 = _S839 > 0.0f;
    float _S842 = _slang_select(_S841, _S840,0.0f);
    (&r_4)->w = _S842;
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
    uint2  _S843 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S844 = make_int2 ((int)_S843.x, (int)_S843.y);
    float3  _S845 = make_float3 (0.0f);
    FKHit _S846 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S847 = Domain_x24init_0(_S845, _S845, &_S846, 0.0f, 0.0f);
    Domain dom_4 = _S847;
    bool _S848 = (fcptCurrentDomain((_S844), (&dom_4)));
    bool _S849 = !_S848;
    if(_S849)
    {
        Reservoir _S850 = (Reservoir{});
        fcptStoreReservoirPrevious((_S844), (_S850), ((&dom_4)->hit));
        return;
    }
    Reservoir _S851 = (fcptLoadReservoirTemporal((_S844)));
    uint t_15 = 0U;
    float count_4 = 0.0f;
    float c_sum_0 = _S851.c;
    for(;;)
    {
        uint _S852 = (fcptRestirNeighbours());
        if(t_15 < _S852)
        {
        }
        else
        {
            break;
        }
        int2  _S853 = partner_0(_S844, t_15);
        Domain neighbor_0 = _S847;
        bool _S854 = (fcptCurrentDomain((_S853), (&neighbor_0)));
        if(_S854)
        {
            float count_5 = count_4 + 1.0f;
            uint4  _S855 = (fcptReservoirTemporal((_S853), (0U)));
            float c_sum_1 = c_sum_0 + (U32_asfloat((_S855.w)));
            count_4 = count_5;
            c_sum_0 = c_sum_1;
        }
        uint t_16 = t_15 + 1U;
        t_15 = t_16;
    }
    float _S856 = _S851.c / (F32_max((count_4), (1.0f)));
    float _S857 = resamplingTarget(_S851.f);
    bool _S858 = count_4 == 0.0f;
    float _S859 = _slang_select(_S858, 1.0f,0.0f);
    Selection _S860 = (Selection{});
    Selection sel_5 = _S860;
    uint _S861 = (fcptFrame());
    uint _S862 = hash(_S861);
    uint _S863 = global_invocation_id_2.x;
    uint2  _S864 = (fcptRenderSize());
    uint _S865 = stream(_S862, _S863 + _S864.x * global_invocation_id_2.y);
    uint _S866 = stream(_S865, 195U);
    (&sel_5)->random_state = _S866;
    t_15 = 0U;
    float canonical_mis_0 = _S859;
    for(;;)
    {
        uint _S867 = (fcptRestirNeighbours());
        if(t_15 < _S867)
        {
        }
        else
        {
            break;
        }
        int2  _S868 = partner_0(_S844, t_15);
        Domain neighbor_dom_0 = _S847;
        bool _S869 = (fcptCurrentDomain((_S868), (&neighbor_dom_0)));
        if(_S869)
        {
            Reservoir _S870 = (fcptLoadReservoirTemporal((_S868)));
            uint4  _S871 = (fcptShiftData((_S868), (t_15)));
            float4  _S872 = asfloat_0(_S871);
            uint4  _S873 = (fcptShiftData((_S844), (t_15)));
            float4  _S874 = asfloat_0(_S873);
            float _S875 = (_S870.c + _S856) / c_sum_0;
            bool _S876 = _S857 > 0.0f;
            float canonical_mis_1;
            if(_S876)
            {
                float _S877 = _S875 * _S856 * _S857;
                float _S878 = _S856 * _S857;
                float _S879 = resamplingTarget(float3 {_S874.x, _S874.y, _S874.z});
                float canonical_mis_2 = canonical_mis_0 + _S877 / (_S878 + _S870.c * _S879);
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float _S880 = resamplingTarget(_S870.f);
            float3  _S881 = float3 {_S872.x, _S872.y, _S872.z};
            Shift _S882 = Shift_x24init_0(_S881, _S872.w);
            float _S883 = _S875 * _S870.c * _S880;
            float _S884 = _S870.c * _S880;
            float _S885 = resamplingTarget(_S881);
            offerShifted(&sel_5, _S870, _S882, _S883 / (_S884 + _S856 * _S885));
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_17 = t_15 + 1U;
        t_15 = t_17;
    }
    offerShifted(&sel_5, _S851, Shift_x24init_0(_S851.f, 1.0f), canonical_mis_0);
    Reservoir _S886 = finalize(sel_5, c_sum_0);
    fcptStoreReservoirPrevious((_S844), (_S886), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S844), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S844), (make_float4 ((&sel_5)->color.x, (&sel_5)->color.y, (&sel_5)->color.z, 0.0f)));
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
    uint _S887 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S888 = _S887 != 4294967295U;
    if(_S888)
    {
        uint2  _S889 = make_uint2 (_S887, _S887 >> 14U) & make_uint2 (16383U);
        int2  _S890 = make_int2 ((int)_S889.x, (int)_S889.y);
        ShiftJob _S891 = (ShiftJob{});
        ShiftJob shift_job_0 = _S891;
        Shift _S892 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S893 = _S887 >> 28U;
        bool _S894 = spatialJob_0(_S890, _S893, &shift_job_0, true);
        Shift shifted_1;
        if(_S894)
        {
            Domain _S895 = (&shift_job_0)->dom;
            Reservoir _S896 = (&shift_job_0)->r;
            Shift _S897 = passShift_0(&_S895, &_S896);
            shifted_1 = _S897;
        }
        else
        {
            shifted_1 = _S892;
        }
        fcptStoreShiftData((_S890), (_S893), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S898 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S899 = make_int2 ((int)_S898.x, (int)_S898.y);
    FixedArray<uint, 3>  _S900;
    spatialBins_0(_S899, &_S900);
    FixedArray<uint, 3>  _S901 = _S900;
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
        bool _S902 = (_S901[t_18]) == 40U;
        if(_S902)
        {
            fcptStoreShiftData((_S899), (t_18), (make_uint4 (0U)));
        }
        uint t_19 = t_18 + 1U;
        t_18 = t_19;
    }
    FixedArray<uint, 3>  _S903 = _S901;
    queueShifts_0(_S899, &_S903, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S904 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S905 = make_int2 ((int)_S904.x, (int)_S904.y);
    FixedArray<uint, 3>  _S906;
    spatialBins_0(_S905, &_S906);
    FixedArray<uint, 3>  _S907 = _S906;
    countShifts_0(&_S907, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S908 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S909 = _S908 != 4294967295U;
    if(_S909)
    {
        uint2  _S910 = make_uint2 (_S908, _S908 >> 14U) & make_uint2 (16383U);
        int2  _S911 = make_int2 ((int)_S910.x, (int)_S910.y);
        int2  _S912 = (fcptLoadTemporalNeighbor((_S911)));
        uint _S913 = _S908 >> 28U;
        Shift _S914 = temporalShiftAt_0(_S911, _S912, _S913);
        fcptStoreTemporalShift((_S911), (_S913), (make_uint4 (asuint_1(_S914.f).x, asuint_1(_S914.f).y, asuint_1(_S914.f).z, (F32_asuint((_S914.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S915 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S916 = make_int2 ((int)_S915.x, (int)_S915.y);
    FixedArray<uint, 3>  _S917;
    temporalBins_0(_S916, &_S917);
    FixedArray<uint, 3>  _S918 = _S917;
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
        bool _S919 = (_S918[t_20]) == 40U;
        if(_S919)
        {
            fcptStoreTemporalShift((_S916), (t_20), (make_uint4 (0U)));
        }
        uint t_21 = t_20 + 1U;
        t_20 = t_21;
    }
    FixedArray<uint, 3>  _S920 = _S918;
    queueShifts_0(_S916, &_S920, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S921 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S922 = make_int2 ((int)_S921.x, (int)_S921.y);
    bool _S923 = (fcptSceneUnchanged());
    bool _S924 = !_S923;
    bool _S925;
    if(_S924)
    {
        uint2  _S926 = (fcptRenderSize());
        int2  _S927 = make_int2 ((int)_S926.x, (int)_S926.y);
        _S925 = all_0(_S922 < _S927);
    }
    else
    {
        _S925 = false;
    }
    if(_S925)
    {
        Reservoir _S928 = (fcptLoadReservoirInitial((_S922)));
        int2  _S929 = sampleNeighbor_0(_S922, _S928.seed);
        fcptStoreTemporalNeighbor((_S922), (_S929));
    }
    FixedArray<uint, 3>  _S930;
    temporalBins_0(_S922, &_S930);
    FixedArray<uint, 3>  _S931 = _S930;
    countShifts_0(&_S931, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_9, float b_3, float t_22)
{
    return a_9 + (b_3 - a_9) * t_22;
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S932 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S933 = make_int2 ((int)_S932.x, (int)_S932.y);
    float3  _S934 = make_float3 (0.0f);
    FKHit _S935 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S936 = Domain_x24init_0(_S934, _S934, &_S935, 0.0f, 0.0f);
    Domain dom_5 = _S936;
    bool _S937 = (fcptCurrentDomain((_S933), (&dom_5)));
    bool _S938 = !_S937;
    if(_S938)
    {
        Reservoir _S939 = (Reservoir{});
        fcptStoreReservoirTemporal((_S933), (_S939), ((&dom_5)->hit));
        return;
    }
    Reservoir _S940 = (fcptLoadReservoirInitial((_S933)));
    bool _S941 = (fcptTemporalQueued());
    bool _S942 = (fcptSceneUnchanged());
    bool _S943;
    if(_S942)
    {
        _S943 = true;
    }
    else
    {
        _S943 = !_S941;
    }
    int2  _S944;
    if(_S943)
    {
        int2  _S945 = sampleNeighbor_0(_S933, _S940.seed);
        _S944 = _S945;
    }
    else
    {
        int2  _S946 = (fcptLoadTemporalNeighbor((_S933)));
        _S944 = _S946;
    }
    bool _S947 = (_S944.x) >= int(0);
    Reservoir r_5;
    if(_S947)
    {
        Reservoir _S948 = (fcptLoadReservoirPrevious((_S944)));
        uint4  _S949 = (fcptDuplication((_S944)));
        float _S950 = (U32_asfloat((_S949.x)));
        uint _S951 = (fcptRestirDecorrelation());
        bool _S952 = _S951 == 1U;
        float _S953 = _slang_select(_S952, _S950,0.0f);
        float _S954 = interpolate_0(20.0f, 1.0f, (F32_pow((_S953), (0.10000000149011612f))));
        float _S955 = (F32_min((_S948.c), (_S954)));
        bool _S956 = (fcptSceneUnchanged());
        float4  _S957 = make_float4 (_S948.f.x, _S948.f.y, _S948.f.z, 1.0f);
        bool _S958 = !_S956;
        if(_S958)
        {
            _S943 = _S941;
        }
        else
        {
            _S943 = false;
        }
        float4  to_current_0;
        if(_S943)
        {
            uint4  _S959 = (fcptTemporalShift((_S933), (0U)));
            float4  _S960 = asfloat_0(_S959);
            to_current_0 = _S960;
        }
        else
        {
            if(_S958)
            {
                Shift _S961 = temporalShiftAt_0(_S933, _S944, 0U);
                float4  _S962 = make_float4 (_S961.f.x, _S961.f.y, _S961.f.z, _S961.jac);
                to_current_0 = _S962;
            }
            else
            {
                to_current_0 = _S957;
            }
        }
        Domain own_1 = _S936;
        if(_S956)
        {
            _S943 = true;
        }
        else
        {
            bool _S963 = (fcptPreviousScenes());
            bool _S964 = !_S963;
            if(_S964)
            {
                _S943 = (_S940.w) > 0.0f;
            }
            else
            {
                _S943 = false;
            }
            if(_S943)
            {
                bool _S965 = (fcptStoredDomainInitial((_S933), (_S940.seed), (&own_1)));
                _S943 = _S965;
            }
            else
            {
                _S943 = false;
            }
            if(_S943)
            {
                Domain _S966 = (fcptPreviousDomain((_S944), (_S940.seed)));
                Domain _S967 = _S966;
                Domain _S968 = own_1;
                bool _S969 = sameDomain_0(&_S967, &_S968);
                _S943 = _S969;
            }
            else
            {
                _S943 = false;
            }
        }
        float4  _S970 = make_float4 (_S940.f.x, _S940.f.y, _S940.f.z, 1.0f);
        bool _S971 = !_S943;
        if(_S971)
        {
            _S943 = _S941;
        }
        else
        {
            _S943 = false;
        }
        float4  to_previous_0;
        if(_S943)
        {
            uint4  _S972 = (fcptTemporalShift((_S933), (1U)));
            float4  _S973 = asfloat_0(_S972);
            to_previous_0 = _S973;
        }
        else
        {
            if(_S971)
            {
                Shift _S974 = temporalShiftAt_0(_S933, _S944, 1U);
                float4  _S975 = make_float4 (_S974.f.x, _S974.f.y, _S974.f.z, _S974.jac);
                to_previous_0 = _S975;
            }
            else
            {
                to_previous_0 = _S970;
            }
        }
        float _S976 = resamplingTarget(_S940.f);
        float _S977 = resamplingTarget(_S948.f);
        Selection _S978 = (Selection{});
        Selection sel_6 = _S978;
        uint _S979 = (fcptFrame());
        uint _S980 = hash(_S979);
        uint _S981 = global_invocation_id_7.x;
        uint2  _S982 = (fcptRenderSize());
        uint _S983 = stream(_S980, _S981 + _S982.x * global_invocation_id_7.y);
        uint _S984 = stream(_S983, 194U);
        (&sel_6)->random_state = _S984;
        float _S985 = _S940.c * _S976;
        float4  _S986 = to_previous_0;
        float _S987 = resamplingTarget(float3 {_S986.x, _S986.y, _S986.z});
        float _S988 = _S985 / (_S985 + _S955 * _S987);
        float _S989 = _S955 * _S977;
        float4  _S990 = to_current_0;
        float3  _S991 = float3 {_S990.x, _S990.y, _S990.z};
        float _S992 = resamplingTarget(_S991);
        float _S993 = _S989 / (_S989 + _S940.c * _S992);
        float2  _S994 = make_float2 (_S988, _S993);
        offerShifted(&sel_6, _S940, Shift_x24init_0(_S940.f, 1.0f), _S988);
        offerShifted(&sel_6, _S948, Shift_x24init_0(_S991, to_current_0.w), _S993);
        Reservoir _S995 = finalize(sel_6, _S940.c + _S955);
        r_5 = _S995;
    }
    else
    {
        r_5 = _S940;
    }
    fcptStoreReservoirTemporal((_S933), (r_5), ((&dom_5)->hit));
    return;
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S996 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S997 = make_int2 ((int)_S996.x, (int)_S996.y);
    float3  _S998 = make_float3 (0.0f);
    float2  _S999 = make_float2 (0.0f);
    FKHit _S1000 = Hit_x24init_0(_S999, 0U, 0U, 0U, 0.0f);
    Domain _S1001 = Domain_x24init_0(_S998, _S998, &_S1000, 0.0f, 0.0f);
    Domain dom_6 = _S1001;
    bool _S1002 = (fcptCurrentDomain((_S997), (&dom_6)));
    bool _S1003 = !_S1002;
    if(_S1003)
    {
        Reservoir _S1004 = (Reservoir{});
        fcptStoreReservoirInitial((_S997), (_S1004), ((&dom_6)->hit));
        return;
    }
    uint _S1005 = (fcptFrame());
    uint _S1006 = hash(_S1005);
    uint _S1007 = global_invocation_id_8.x;
    uint2  _S1008 = (fcptRenderSize());
    uint _S1009 = stream(_S1006, _S1007 + _S1008.x * global_invocation_id_8.y);
    Selection _S1010 = (Selection{});
    Selection initial_0 = _S1010;
    uint _S1011 = stream(_S1009, 193U);
    (&initial_0)->random_state = _S1011;
    bool _S1012 = (fcptRestirUsed());
    bool _S1013 = !_S1012;
    (&initial_0)->sums = _S1013;
    uint _S1014 = stream(_S1009, 0U);
    (&(&initial_0)->r)->seed = _S1014;
    FKHit _S1015 = Hit_x24init_0(_S999, 4294967295U, 0U, 0U, 0.0f);
    uint _S1016 = (fcptSamples());
    float _S1017 = 1.0f / float(_S1016);
    FKHit hit_2 = _S1015;
    uint i_18 = 0U;
    float3  seen_0 = _S998;
    for(;;)
    {
        uint _S1018 = (fcptSamples());
        if(i_18 < _S1018)
        {
        }
        else
        {
            break;
        }
        Reservoir _S1019 = (Reservoir{});
        Reservoir r_6 = _S1019;
        uint _S1020 = stream(_S1009, i_18);
        (&r_6)->seed = _S1020;
        Domain path_0 = _S1001;
        bool _S1021 = (fcptStoredDomainInitial((_S997), ((&r_6)->seed), (&path_0)));
        bool _S1022 = !_S1021;
        if(_S1022)
        {
            float3  _S1023 = (fcptMissed((_S997), (path_0), (_S1017)));
            float3  seen_1 = seen_0 + _S1023;
            seen_0 = seen_1;
            uint i_19 = i_18 + 1U;
            i_18 = i_19;
            continue;
        }
        Domain _S1024 = path_0;
        Reservoir _S1025 = r_6;
        Shift _S1026 = passWalk_0(&_S1024, &_S1025, false, _S1017, &initial_0);
        bool _S1027 = ((&(&initial_0)->r)->seed) == ((&r_6)->seed);
        FKHit hit_3;
        if(_S1027)
        {
            FKHit _S1028 = (&path_0)->hit;
            hit_3 = _S1028;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_19 = i_18 + 1U;
        i_18 = i_19;
    }
    uint _S1029 = (fcptSamples());
    float3  seen_2 = seen_0 + (&initial_0)->glow / make_float3 (float(_S1029));
    float3  _S1030 = seen_2 + (&initial_0)->color;
    bool _S1031 = (&initial_0)->sums;
    float3  _S1032 = _slang_select(_S1031, _S1030,seen_2);
    fcptAddColor((_S997), (make_float4 (_S1032.x, _S1032.y, _S1032.z, 1.0f)));
    Reservoir _S1033 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S997), (_S1033), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_3, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S1034;
    (&_S1034)->none = none_0;
    (&_S1034)->pdf = pdf_3;
    (&_S1034)->origin = origin_5;
    (&_S1034)->smooth_n = smooth_n_3;
    (&_S1034)->start = start_6;
    return _S1034;
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
    Vertex _S1035;
    (&_S1035)->rough = rough_0;
    (&_S1035)->lobe = lobe_1;
    (&_S1035)->pdf = pdf_4;
    (&_S1035)->cos = cos_0;
    (&_S1035)->inside = inside_0;
    return _S1035;
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

static __device__ float3  flightWeight_0(float3  scatter_0, float3  extinction_0, float sigma_0, float distance_2, bool scatters_0)
{
    float3  _S1036 = exp_0((make_float3 (sigma_0) - extinction_0) * make_float3 (distance_2));
    float3  _S1037 = scatter_0 * _S1036 / make_float3 (sigma_0);
    float3  _S1038 = _slang_select(scatters_0, _S1037,_S1036);
    return _S1038;
}

static __device__ uint arrivalLobe_0(uint b_4, uint prev_lobe_0)
{
    bool _S1039 = b_4 > 0U;
    uint _S1040 = _slang_select(_S1039, prev_lobe_0,3U);
    return _S1040;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_2, bool surface_5, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S1041;
    (&_S1041)->extinction_behind = extinction_behind_0;
    (&_S1041)->extinction_front = extinction_front_0;
    (&_S1041)->fillings = fillings_0;
    (&_S1041)->side = side_0;
    (&_S1041)->depth = depth_1;
    (&_S1041)->lobe = lobe_2;
    (&_S1041)->surface = surface_5;
    (&_S1041)->length = length_2;
    (&_S1041)->width = width_1;
    (&_S1041)->own = *own_2;
    (&_S1041)->fiber = fiber_0;
    return _S1041;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S1042 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S1042)
    {
        return 0.07957746833562851f;
    }
    float _S1043 = g_0 * g_0;
    return (1.0f - _S1043) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S1043 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_10, float3  b_5)
{
    float3  _S1044 = a_10 / b_5;
    float3  _S1045 = make_float3 (0.0f);
    bool3  _S1046 = b_5 == _S1045;
    float3  _S1047 = _slang_select(_S1046, _S1045,_S1044);
    return _S1047;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_6)
{
    uint _S1048 = (1U << count_6) - 1U;
    return (e_2 & (~(_S1048 << offset_1))) | ((newbits_0 & _S1048) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_7, uint end_type_0, uint end_0, float3  f_6)
{
    Reservoir candidate_2 = r_7;
    uint _S1049 = insertBits_0(r_7.path, end_0, 0U, 5U);
    uint _S1050 = insertBits_0(_S1049, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S1050;
    (&candidate_2)->f = f_6;
    return candidate_2;
}

__device__ float survivalProbability(float3  throughput_0, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_0.x), ((F32_max((throughput_0.y), (throughput_0.z)))))) / density_1), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_9)
{
    Random _S1051 = pcg(random_state_9);
    Random _S1052 = pcg(_S1051.state);
    float _S1053 = 1.0f - 2.0f * _S1051.value;
    float _S1054 = (F32_sqrt(((F32_max((1.0f - _S1053 * _S1053), (0.0f))))));
    float _S1055 = 6.28318548202514648f * _S1052.value;
    return make_float3 (_S1054 * (F32_cos((_S1055))), _S1054 * (F32_sin((_S1055))), _S1053);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_9, uint random_state_10, float * pdf_5)
{
    bool _S1056 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1056)
    {
        *pdf_5 = 0.07957746833562851f;
        float3  _S1057 = isotropic_0(random_state_10);
        return _S1057;
    }
    Random _S1058 = pcg(random_state_10);
    Random _S1059 = pcg(_S1058.state);
    float _S1060 = g_1 * g_1;
    float _S1061 = 2.0f * g_1;
    float _S1062 = (1.0f - _S1060) / (1.0f - g_1 + _S1061 * _S1058.value);
    float _S1063 = clamp_1((1.0f + _S1060 - _S1062 * _S1062) / _S1061, -1.0f, 1.0f);
    float _S1064 = (F32_sqrt(((F32_max((1.0f - _S1063 * _S1063), (0.0f))))));
    float _S1065 = 6.28318548202514648f * _S1059.value;
    float _S1066 = phaseHG_0(g_1, _S1063);
    *pdf_5 = _S1066;
    float3  _S1067 = tangentToWorld(make_float3 (_S1064 * (F32_cos((_S1065))), _S1063, _S1064 * (F32_sin((_S1065)))), dir_9);
    float3  _S1068 = ((((_S1067)) * make_float3(rnorm3df(((_S1067)).x, ((_S1067)).y, ((_S1067)).z))));
    return _S1068;
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_1, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_1, float velvet_0, float3  toon_2, float dispersion_0)
{
    BSDFMaterial _S1069;
    (&_S1069)->albedo = albedo_1;
    (&_S1069)->emissive = emissive_0;
    (&_S1069)->roughness = roughness_0;
    (&_S1069)->metallic = metallic_0;
    (&_S1069)->transmission = transmission_0;
    (&_S1069)->ior = ior_0;
    (&_S1069)->absorption = absorption_0;
    (&_S1069)->specular_tint = specular_tint_0;
    (&_S1069)->specular_level = specular_level_0;
    (&_S1069)->translucent = translucent_0;
    (&_S1069)->sheen = sheen_2;
    (&_S1069)->sheen_roughness = sheen_roughness_0;
    (&_S1069)->anisotropy = anisotropy_0;
    (&_S1069)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1069)->tangent = tangent_1;
    (&_S1069)->velvet = velvet_0;
    (&_S1069)->toon = toon_2;
    (&_S1069)->dispersion = dispersion_0;
    return _S1069;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1070;
    (&_S1070)->scatter = scatter_1;
    (&_S1070)->extinction = extinction_1;
    (&_S1070)->g = g_2;
    return _S1070;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_10, bool skip_0, uint random_state_11, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1071;
    (&_S1071)->smooth_n = smooth_n_4;
    (&_S1071)->geometry_n = geometry_n_2;
    (&_S1071)->geometry_offset = geometry_offset_2;
    (&_S1071)->material = *material_10;
    (&_S1071)->skip = skip_0;
    (&_S1071)->random_state = random_state_11;
    (&_S1071)->coverage = coverage_0;
    (&_S1071)->encloses = encloses_0;
    (&_S1071)->volume = *volume_0;
    (&_S1071)->fills = fills_0;
    (&_S1071)->hair = hair_0;
    return _S1071;
}

static __device__ FKSurface emitting_0(FKSurface * surface_6, bool top_0)
{
    FKSurface lower_0 = *surface_6;
    float3  _S1072 = (&surface_6->material)->emissive;
    float3  _S1073 = make_float3 (0.0f);
    bool _S1074 = !top_0;
    float3  _S1075 = _slang_select(_S1074, _S1073,_S1072);
    (&(&lower_0)->material)->emissive = _S1075;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_7, float u_1)
{
    float _S1076 = surface_7->coverage;
    bool _S1077 = u_1 < _S1076;
    if(_S1077)
    {
        return *surface_7;
    }
    float3  _S1078 = make_float3 (0.0f);
    float3  _S1079 = make_float3 (1.0f);
    BSDFMaterial _S1080 = Material_x24init_0(_S1078, _S1078, 0.0f, 0.0f, 0.0f, 0.0f, _S1078, _S1079, 1.0f, _S1078, _S1078, 0.5f, 0.0f, 0.0f, _S1078, 0.0f, _S1078, 0.0f);
    BSDFMaterial material_11 = _S1080;
    (&material_11)->albedo = _S1079;
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
    bool _S1081 = transmission_1 > 0.0f;
    bool _S1082;
    if(_S1081)
    {
        _S1082 = true;
    }
    else
    {
        _S1082 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1083 = _slang_select(_S1082, 1.0f,-1.0f);
    return _S1083;
}

static __device__ bool arrivesBehind_0(float3  dir_10, float3  n_8)
{
    return (dot_0(dir_10, n_8)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_8, float3  dir_11)
{
    float3  _S1084 = surface_8->geometry_n;
    float _S1085 = facingSign((&surface_8->material)->transmission, surface_8->geometry_n, dir_11);
    FKSurface faced_0 = *surface_8;
    float3  _S1086 = surface_8->smooth_n * make_float3 (_S1085);
    (&faced_0)->smooth_n = _S1086;
    float3  _S1087 = _S1084 * make_float3 (_S1085);
    (&faced_0)->geometry_n = _S1087;
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
    float3  _S1088 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1088));
}

__device__ bool dispersive(BSDFMaterial material_12)
{
    bool _S1089 = (material_12.dispersion) > 0.0f;
    bool _S1090;
    if(_S1089)
    {
        _S1090 = (material_12.ior) != 1.0f;
    }
    else
    {
        _S1090 = false;
    }
    return _S1090;
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
        uint _S1091 = (low_1 + high_1 + 1U) / 2U;
        bool _S1092 = (WAVELENGTH_CDF_0[_S1091]) <= u_2;
        if(_S1092)
        {
            low_1 = _S1091;
        }
        else
        {
            uint _S1093 = _S1091 - 1U;
            high_1 = _S1093;
        }
    }
    uint _S1094 = low_1;
    float _S1095 = WAVELENGTH_CDF_0[low_1 + 1U] - WAVELENGTH_CDF_0[low_1];
    return make_float2 (0.37999999523162842f + 0.00499999988824129f * (float(low_1) + (u_2 - WAVELENGTH_CDF_0[_S1094]) / _S1095), _S1095 / 0.00499999988824129f);
}

__device__ static const FixedArray<float, 243>  WAVELENGTH_WEIGHTS_0 = { {
    0.00547470012679696f, -0.00465690018609166f, 0.03257500007748604f, 0.00934640038758516f, -0.00796370021998882f, 0.05577300116419792f, 0.01846100017428398f, -0.01579399965703487f, 0.11072999984025955f, 0.0416410006582737f, -0.03577499836683273f, 0.2513900101184845f, 0.09349299967288971f, -0.08071800321340561f, 0.56742000579833984f, 0.1585099995136261f, -0.13764999806880951f, 0.97018998861312866f, 0.30943000316619873f, -0.27083000540733337f, 1.91740000247955322f, 0.55217999219894409f, -0.48754000663757324f, 3.46889996528625488f, 0.95016998052597046f, -0.84802001714706421f, 6.09439992904663086f, 1.42110002040863037f, -1.28929996490478516f, 9.45199966430664062f, 1.73409998416900635f, -1.6062999963760376f, 12.12800025939941406f, 2.08030009269714355f, -1.98810005187988281f, 15.68700027465820312f, 2.20600008964538574f, -2.20120000839233398f, 18.47699928283691406f, 2.03040003776550293f, -2.17700004577636719f, 19.92700004577636719f, 1.63429999351501465f, -2.00340008735656738f, 20.86899948120117188f, 0.99410998821258545f, -1.62629997730255127f, 20.57799911499023438f, 0.20011000335216522f, -1.11409997940063477f, 19.72100067138671875f, -0.67960000038146973f, -0.45403000712394714f, 17.77599906921386719f, -1.61679995059967041f, 0.37860000133514404f, 14.71500015258789062f, -2.53410005569458008f, 1.27540004253387451f, 11.86499977111816406f, -3.39079999923706055f, 2.2146000862121582f, 9.17669963836669922f, -4.03749990463256836f, 3.0522000789642334f, 6.59509992599487305f, -4.61299991607666016f, 3.89779996871948242f, 4.64589977264404297f, -5.43039989471435547f, 5.0121002197265625f, 3.3199000358581543f, -6.37769985198974609f, 6.33809995651245117f, 2.29699993133544922f, -7.44140005111694336f, 7.91739988327026367f, 1.45389997959136963f, -8.38580036163330078f, 9.60109996795654297f, 0.66465997695922852f, -9.0167999267578125f, 11.23999977111816406f, -0.04403600096702576f, -9.17749977111816406f, 12.63199996948242188f, -0.58126997947692871f, -8.97550010681152344f, 13.91499996185302734f, -0.95730000734329224f, -8.25290012359619141f, 14.86200046539306641f, -1.24430000782012939f, -6.92129993438720703f, 15.03899955749511719f, -1.43069994449615479f, -5.29169988632202148f, 14.90900039672851562f, -1.55149996280670166f, -3.43219995498657227f, 14.70499992370605469f, -1.63569998741149902f, -1.27190005779266357f, 14.24400043487548828f, -1.67030000686645508f, 1.15170001983642578f, 13.32199954986572266f, -1.636199951171875f, 3.73889994621276855f, 12.21199989318847656f, -1.56920003890991211f, 6.43590021133422852f, 10.94699954986572266f, -1.47730004787445068f, 9.16440010070800781f, 9.54769992828369141f, -1.36399996280670166f, 12.02000045776367188f, 8.18799972534179688f, -1.25450003147125244f, 14.78699970245361328f, 6.74429988861083984f, -1.13110005855560303f, 16.72299957275390625f, 5.08780002593994141f, -0.96561002731323242f, 18.14299964904785156f, 3.57019996643066406f, -0.80725997686386108f, 19.91900062561035156f, 2.36269998550415039f, -0.69273000955581665f, 21.05500030517578125f, 1.31369996070861816f, -0.58597999811172485f, 21.3899993896484375f, 0.42390000820159912f, -0.48298001289367676f, 20.99300003051757812f, -0.23857000470161438f, -0.39412000775337219f, 19.82200050354003906f, -0.6866300106048584f, -0.31501999497413635f, 18.12000083923339844f, -0.9412500262260437f, -0.24890999495983124f, 15.7089996337890625f, -1.02020001411437988f, -0.19076000154018402f, 13.19799995422363281f, -0.98919999599456787f, -0.14401000738143921f, 11.23999977111816406f, -0.93347001075744629f, -0.11133000254631042f, 9.36649990081787109f, -0.83820998668670654f, -0.08524099737405777f, 7.41249990463256836f, -0.70064002275466919f, -0.06283199787139893f, 5.71229982376098633f, -0.56079000234603882f, -0.04586699977517128f, 4.42280006408691406f, -0.44653001427650452f, -0.03396600112318993f, 3.34489989280700684f, -0.34457001090049744f, -0.02482499927282333f, 2.49309992790222168f, -0.26017999649047852f, -0.01808100007474422f, 1.82239997386932373f, -0.1921599954366684f, -0.01296999957412481f, 1.29499995708465576f, -0.13766999542713165f, -0.00907570030540228f, 0.92928999662399292f, -0.09956400096416473f, -0.00641620019450784f, 0.61835998296737671f, -0.06671299785375595f, -0.00421149982139468f, 0.40211999416351318f, -0.04354599863290787f, -0.00271830009296536f, 0.2844499945640564f, -0.03087200038135052f, -0.00191440002527088f, 0.20672999322414398f, -0.02246100082993507f, -0.00138829997740686f, 0.15044000744819641f, -0.01634499989449978f, -0.00101030000951141f, 0.10942000150680542f, -0.01188699994236231f, -0.0007347899954766f, 0.07099699974060059f, -0.00771349994465709f, -0.00047679000999779f, 0.04539500176906586f, -0.00493190018460155f, -0.00030484999297187f, 0.03424099832773209f, -0.00372010003775358f, -0.00022995000472292f, 0.02557599917054176f, -0.00277870008721948f, -0.00017175999528263f, 0.01842200011014938f, -0.00200140010565519f, -0.0001237099932041f, 0.01316899992525578f, -0.00143079995177686f, -0.00008843900286593f, 0.00838890019804239f, -0.00091141002485529f, -0.00005633700129692f, 0.00537079991772771f, -0.00058350997278467f, -0.00003606799873523f, 0.00328280008397996f, -0.00035665999166667f, -0.00002204600059486f, 0.00196009990759194f, -0.00021296000340953f, -0.00001316300040344f, 0.00168939994182438f, -0.00018354000349063f, -0.00001134499962063f, 0.00141050003003329f, -0.00015325000276789f, -0.00000947250009631f, 0.00097123999148607f, -0.00010551999730524f, -6.52239987175562419e-06f, 0.00066868000430986f, -0.00007264900341397f, -4.49060007667867467e-06f
} };
__device__ float3  wavelengthWeights(float wavelength_0)
{
    float _S1096 = clamp_1((wavelength_0 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    uint _S1097 = (U32_min((uint(_S1096)), (79U)));
    uint _S1098 = 3U * _S1097;
    float3  _S1099 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1098], WAVELENGTH_WEIGHTS_0[_S1098 + 1U], WAVELENGTH_WEIGHTS_0[_S1098 + 2U]);
    float3  _S1100 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1098 + 3U], WAVELENGTH_WEIGHTS_0[_S1098 + 4U], WAVELENGTH_WEIGHTS_0[_S1098 + 5U]);
    return _S1099 + (_S1100 - _S1099) * make_float3 (_S1096 - float(_S1097));
}

__device__ float dispersedIor(float ior_1, float dispersion_1, float wavelength_1)
{
    float _S1101 = (ior_1 - 1.0f) * dispersion_1 / 1.90962409973144531f;
    float _S1102 = _S1101 * (1.0f / (wavelength_1 * wavelength_1) - 2.89662933349609375f);
    bool _S1103 = dispersion_1 > 0.0f;
    float _S1104 = _slang_select(_S1103, _S1102,0.0f);
    return ior_1 + _S1104;
}

__device__ float2  vertexEta(BSDFMaterial material_13, float n_dot_v_0)
{
    bool _S1105 = n_dot_v_0 < 0.0f;
    float _S1106 = _slang_select(_S1105, material_13.ior,1.0f);
    float _S1107 = _slang_select(_S1105, 1.0f,material_13.ior);
    return make_float2 (_S1106, _S1107);
}

__device__ bool neeDecision(BSDFMaterial material_14, float n_dot_v_1, float eta_i_5, float eta_o_5)
{
    float _S1108 = fresnel((F32_abs((n_dot_v_1))), eta_i_5, eta_o_5);
    float3  _S1109 = mix_0(make_float3 (_S1108), material_14.albedo, material_14.metallic);
    float _S1110 = rgb_to_greyscale(_S1109);
    float _S1111 = (F32_max(((1.0f - _S1110) * (1.0f - material_14.metallic) * (1.0f - material_14.transmission)), (0.0f)));
    bool _S1112 = _S1111 > 0.03999999910593033f;
    bool _S1113;
    if(_S1112)
    {
        _S1113 = true;
    }
    else
    {
        _S1113 = (material_14.roughness) > 0.20000000298023224f;
    }
    return _S1113;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_15)
{
    float _S1114 = rgb_to_greyscale(material_15->translucent);
    return _S1114 > 0.0f;
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
    MediumSides _S1115;
    (&_S1115)->behind = *behind_0;
    (&_S1115)->front = *front_0;
    (&_S1115)->fillings = fillings_1;
    (&_S1115)->face = face_1;
    return _S1115;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_9, FKMedium * medium_0, uint filling_0, float3  dir_12, FKMedium * outside_0)
{
    float3  _S1116 = surface_9->geometry_n;
    MediumSides _S1117 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_9->geometry_n);
    MediumSides sides_0 = _S1117;
    bool _S1118 = surface_9->encloses;
    if(_S1118)
    {
        (&sides_0)->behind = surface_9->volume;
        *&((&(&sides_0)->fillings)->x) = surface_9->fills;
        bool _S1119 = (dot_0(dir_12, _S1116)) > 0.0f;
        if(_S1119)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_10, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_13, uint depth_2, uint lobe_3, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1120 = surface_10->geometry_n;
    ShadowContext _S1121 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_10->geometry_n, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
    bool _S1122 = surface_10->encloses;
    ShadowContext context_4;
    if(_S1122)
    {
        FKSurface faced_1 = *surface_10;
        float3  _S1123 = - _S1120;
        float3  _S1124 = _slang_select(turned_0, _S1123,_S1120);
        (&faced_1)->geometry_n = _S1124;
        FKMedium _S1125 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1126 = faced_1;
        FKMedium _S1127 = _S1125;
        MediumSides _S1128 = mediumSides_0(&_S1126, &_S1127, filling_1, dir_13, outside_1);
        ShadowContext _S1129 = ShadowContext_x24init_0(_S1128.behind.extinction, _S1128.front.extinction, _S1128.fillings, _S1120, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
        if(turned_0)
        {
            uint2  _S1130 = _S1128.fillings;
            ShadowContext _S1131 = ShadowContext_x24init_0(_S1128.front.extinction, _S1128.behind.extinction, uint2 {_S1130.y, _S1130.x}, _S1120, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
            context_4 = _S1131;
        }
        else
        {
            context_4 = _S1129;
        }
    }
    else
    {
        context_4 = _S1121;
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

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_7, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_3, BSDFMaterial * material_16, float eta_i_6, float eta_o_6, bool competing_1, uint random_state_12)
{
    float3  _S1132 = light_2->dir;
    bool _S1133 = (dot_0(geometry_n_3, - in_dir_7) * dot_0(geometry_n_3, light_2->dir)) <= 0.0f;
    FixedArray<float3 , 5>  throughputs_1;
    FixedArray<float, 5>  pdfs_3;
    float3  _S1134 = BSDF(in_dir_7, _S1132, smooth_n_5, *material_16, eta_i_6, eta_o_6, _S1133, random_state_12, &throughputs_1, &pdfs_3);
    bool _S1135 = !competing_1;
    bool _S1136;
    if(_S1135)
    {
        _S1136 = true;
    }
    else
    {
        _S1136 = (light_2->density) == 0.0f;
    }
    if(_S1136)
    {
        return _S1134 * light_2->radiance;
    }
    float3  _S1137 = make_float3 (0.0f);
    uint i_24 = 0U;
    float3  weighted_0 = _S1137;
    for(;;)
    {
        if(i_24 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S1138 = (pdfs_3[i_24]) > 0.0f;
        if(_S1138)
        {
            float _S1139 = light_2->density;
            float _S1140 = pdfs_3[i_24] / light_2->density;
            float3  weighted_1 = weighted_0 + throughputs_1[i_24] * make_float3 (pdfs_3[i_24]) / make_float3 (_S1139 * (1.0f + _S1140 * _S1140));
            weighted_0 = weighted_1;
        }
        uint i_25 = i_24 + 1U;
        i_24 = i_25;
    }
    return weighted_0 * light_2->radiance * make_float3 (light_2->density);
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_1, uint random_state_13, bool refracted_3, uint lobe_4, float pdf_6)
{
    SampleBSDF _S1141;
    (&_S1141)->unit_direction = unit_direction_1;
    (&_S1141)->throughput = throughput_1;
    (&_S1141)->random_state = random_state_13;
    (&_S1141)->refracted = refracted_3;
    (&_S1141)->lobe = lobe_4;
    (&_S1141)->pdf = pdf_6;
    return _S1141;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  v_9, float3  n_i_13, float n_i_dot_v_3, BSDFMaterial material_17, Weights w_14, uint random_state_14)
{
    float3  _S1142 = make_float3 (1.0f);
    SampleBSDF _S1143 = SampleBSDF_x24init_0(_S1142, _S1142, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S1143;
    Random _S1144 = pcg(random_state_14);
    Random _S1145 = pcg(_S1144.state);
    (&sample_1)->random_state = _S1145.state;
    float _S1146 = _S1144.value;
    float _S1147 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1146 * _S1146))))));
    float _S1148 = 6.28318548202514648f * _S1145.value;
    float3  _S1149 = tangentToWorld(make_float3 (_S1147 * (F32_cos((_S1148))), _S1144.value, _S1147 * (F32_sin((_S1148)))), n_i_13);
    (&sample_1)->unit_direction = _S1149;
    (&sample_1)->lobe = 4U;
    float3  _S1150 = sheenVelvetBSDF((&sample_1)->unit_direction, v_9, n_i_13, material_17, w_14);
    (&sample_1)->throughput = _S1150;
    float _S1151 = sheenVelvetPDF(_S1144.value, n_i_dot_v_3, w_14);
    (&sample_1)->pdf = _S1151;
    return sample_1;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1152 = (F32_sqrt((random_1_0)));
    float _S1153 = 6.28318548202514648f * random_2_0;
    float _S1154 = _S1152 * (F32_cos((_S1153)));
    float _S1155 = _S1152 * (F32_sin((_S1153)));
    float _S1156 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1154 * _S1154 - _S1155 * _S1155))))));
    return make_float3 (_S1154, _S1156, _S1155);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_3, float3  n_i_14, float n_i_dot_v_4, BSDFMaterial material_18, Weights w_15, uint random_state_15)
{
    float3  _S1157 = make_float3 (1.0f);
    SampleBSDF _S1158 = SampleBSDF_x24init_0(_S1157, _S1157, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S1158;
    Random _S1159 = pcg(random_state_15);
    Random _S1160 = pcg(_S1159.state);
    (&sample_2)->random_state = _S1160.state;
    float3  _S1161 = sampleCosWeightedHemisphere(_S1159.value, _S1160.value);
    float _S1162 = translucentShare(material_18);
    bool _S1163 = u_3 < (w_15.p_diffuse * _S1162);
    float _S1164 = _S1161.y;
    float _S1165 = - _S1164;
    float _S1166 = _slang_select(_S1163, _S1165,_S1164);
    float3  _S1167 = tangentToWorld(make_float3 (_S1161.x, _S1166, _S1161.z), n_i_14);
    (&sample_2)->unit_direction = _S1167;
    (&sample_2)->refracted = _S1163;
    (&sample_2)->lobe = 0U;
    float3  _S1168 = diffuseBSDF((&sample_2)->unit_direction, n_i_14, material_18, w_15);
    (&sample_2)->throughput = _S1168;
    float _S1169 = diffusePDF(_S1166, n_i_dot_v_4, material_18, w_15);
    (&sample_2)->pdf = _S1169;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF toonSample(float3  n_i_15, ToonProfile profile_3, Weights w_16, uint random_state_16)
{
    float3  _S1170 = make_float3 (1.0f);
    Random _S1171 = pcg(random_state_16);
    Random _S1172 = pcg(_S1171.state);
    float _S1173 = _S1171.value * profile_3.norm / 6.28318548202514648f;
    float _S1174 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1173)))), (1.0f))))));
    float _S1175 = (F32_acos((clamp_1(1.0f - _S1173, -1.0f, 1.0f))));
    float _S1176 = _slang_select(profile_3.glossy, _S1175,_S1174);
    float _S1177 = (profile_3.a + profile_3.b) / 2.0f;
    bool _S1178 = _S1176 < (profile_3.a);
    float _S1179 = _slang_select(_S1178, _S1176,_S1177);
    float t_23 = _S1179;
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
        float _S1180 = toonP(t_23, profile_3.a, profile_3.s);
        float _S1181 = _S1180 * (F32_sin((t_23)));
        float _S1182 = (F32_cos((t_23)));
        float _S1183 = _slang_select(profile_3.glossy, 1.0f,_S1182);
        float _S1184 = _S1181 * _S1183;
        float _S1185 = toonIntegral(t_23, profile_3.a, profile_3.s, profile_3.glossy);
        float _S1186 = (_S1185 - _S1173) / _S1184;
        bool _S1187 = _S1184 > 0.0f;
        float _S1188 = _slang_select(_S1187, _S1186,0.0f);
        float _S1189 = clamp_1(t_23 - _S1188, 0.0f, profile_3.b);
        int k_1 = k_0 + int(1);
        t_23 = _S1189;
        k_0 = k_1;
    }
    float _S1190 = 6.28318548202514648f * _S1172.value;
    float _S1191 = (F32_sin((t_23)));
    float3  _S1192 = tangentToWorld(make_float3 (_S1191 * (F32_cos((_S1190))), (F32_cos((t_23))), _S1191 * (F32_sin((_S1190)))), profile_3.axis);
    float3  _S1193 = toonBSDF(_S1192, n_i_15, profile_3, w_16);
    bool _S1194 = (dot_0(n_i_15, _S1192)) < 0.0f;
    float _S1195 = toonPDF(_S1192, n_i_15, profile_3, w_16);
    return SampleBSDF_x24init_0(_S1192, _S1193, _S1172.state, _S1194, 6U, _S1195);
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_16, float alpha_8, AnisotropicFrame frame_6, BSDFMaterial material_19, Weights w_17, float pdf_h_3, float eta_i_7, float eta_o_7, uint random_state_17)
{
    float3  _S1196 = make_float3 (1.0f);
    SampleBSDF _S1197 = SampleBSDF_x24init_0(_S1196, _S1196, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S1197;
    (&sample_3)->unit_direction = w_17.refracted;
    (&sample_3)->random_state = random_state_17;
    (&sample_3)->refracted = true;
    (&sample_3)->lobe = 1U;
    float3  _S1198 = refractBSDF((&sample_3)->unit_direction, n_i_16, alpha_8, frame_6, material_19, w_17);
    (&sample_3)->throughput = _S1198;
    float _S1199 = refractPDF(dot_0((&sample_3)->unit_direction, ggx_n_3), pdf_h_3, w_17, eta_i_7, eta_o_7);
    (&sample_3)->pdf = _S1199;
    return sample_3;
}

static __device__ float3  reflect_0(float3  i_26, float3  n_9)
{
    return i_26 - make_float3 (2.0f * dot_0(n_9, i_26)) * n_9;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_8, float3  ggx_n_4, float3  n_i_17, float alpha_9, AnisotropicFrame frame_7, Weights w_18, float pdf_h_4, uint random_state_18)
{
    float3  _S1200 = make_float3 (1.0f);
    SampleBSDF _S1201 = SampleBSDF_x24init_0(_S1200, _S1200, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S1201;
    float3  _S1202 = reflect_0(in_dir_8, ggx_n_4);
    float3  _S1203 = ((((_S1202)) * make_float3(rnorm3df(((_S1202)).x, ((_S1202)).y, ((_S1202)).z))));
    (&sample_4)->unit_direction = _S1203;
    (&sample_4)->random_state = random_state_18;
    (&sample_4)->lobe = 2U;
    float3  _S1204 = reflectBSDF((&sample_4)->unit_direction, n_i_17, alpha_9, frame_7, w_18);
    (&sample_4)->throughput = _S1204;
    float _S1205 = reflectPDF(pdf_h_4, w_18);
    (&sample_4)->pdf = _S1205;
    return sample_4;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_9, float3  n_10, BSDFMaterial material_20, float eta_i_8, float eta_o_8, uint random_init_0, float2  screen_space_0)
{
    uint random_state_19 = random_init_0;
    float3  _S1206 = negate_0(in_dir_9);
    float _S1207 = dot_0(n_10, _S1206);
    float _S1208 = sign_0(_S1207);
    float3  n_i_18 = n_10 * make_float3 (_S1208);
    float _S1209 = (F32_abs((_S1207)));
    float _S1210 = material_20.roughness;
    float _S1211 = _S1210 * _S1210;
    AnisotropicFrame _S1212 = anisotropicFrame(material_20, n_i_18);
    SheenProfile _S1213 = sheenProfile(_S1206, n_i_18, material_20);
    float3  _S1214 = sampleHalfVector(_S1206, n_i_18, _S1211, _S1212, &random_state_19);
    Weights _S1215 = lobeWeights(in_dir_9, _S1206, n_i_18, _S1214, _S1212, _S1213, material_20, eta_i_8, eta_o_8);
    Random _S1216 = pcg(random_state_19);
    random_state_19 = _S1216.state;
    bool _S1217 = (_S1216.value) < (_S1215.p_sheen_velvet);
    if(_S1217)
    {
        SampleBSDF _S1218 = sheenVelvetSample(_S1206, n_i_18, _S1209, material_20, _S1215, random_state_19);
        return _S1218;
    }
    float _S1219 = _S1216.value - _S1215.p_sheen_velvet;
    bool _S1220 = _S1219 < (_S1215.p_diffuse);
    if(_S1220)
    {
        SampleBSDF _S1221 = diffuseSample(_S1219, n_i_18, _S1209, material_20, _S1215, random_state_19);
        return _S1221;
    }
    bool _S1222 = _S1219 < (_S1215.p_diffuse + _S1215.p_toon);
    if(_S1222)
    {
        ToonProfile _S1223 = toonProfile(_S1206, n_i_18, material_20);
        SampleBSDF _S1224 = toonSample(n_i_18, _S1223, _S1215, random_state_19);
        return _S1224;
    }
    float _S1225 = vndfPDF(_S1206, _S1214, n_i_18, _S1209, _S1211, _S1212, _S1215.v_dot_h);
    bool _S1226 = (_S1219 - _S1215.p_toon) < (_S1215.p_diffuse + _S1215.p_refract);
    if(_S1226)
    {
        SampleBSDF _S1227 = refractSample(_S1214, n_i_18, _S1211, _S1212, material_20, _S1215, _S1225, eta_i_8, eta_o_8, random_state_19);
        return _S1227;
    }
    SampleBSDF _S1228 = reflectSample(in_dir_9, _S1214, n_i_18, _S1211, _S1212, _S1215, _S1225, random_state_19);
    return _S1228;
}

static __device__ bool boundsVolume_0(FKSurface * surface_11)
{
    return surface_11->encloses;
}

static __device__ Shift walk_0(Domain * dom_7, Reservoir * r_8, bool replay_1, float scale_3, Selection * sel_7)
{
    float spread_1;
    bool turned_1;
    bool is_inside_5;
    bool viewed_0;
    bool _S1229;
    bool _S1230;
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
    int _S1231;
    Shift ended_0;
    float density_3;
    float spread_2;
    float width_4;
    float sky_pdf_1;
    float spread_3;
    float width_5;
    uint b_7;
    float3  _S1232 = make_float3 (0.0f);
    Shift _S1233 = Shift_x24init_0(_S1232, 0.0f);
    uint _S1234 = r_8->path;
    uint _S1235 = extractBits_0(r_8->path, 0U, 5U);
    uint _S1236 = extractBits_0(_S1234, 5U, 5U);
    uint _S1237 = extractBits_0(_S1234, 10U, 2U);
    uint _S1238 = extractBits_0(_S1234, 12U, 3U);
    bool passes_0;
    if(replay_1)
    {
        bool _S1239 = _S1238 >= 3U;
        uint _S1240 = _slang_select(_S1239, 1U,0U);
        uint _S1241 = _S1235 + _S1240;
        uint _S1242 = (fcptMaxBounces());
        passes_0 = _S1241 > _S1242;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1233;
    }
    uint _S1243 = _S1236 - 1U;
    bool _S1244 = _S1238 == 3U;
    uint _S1245 = _slang_select(_S1244, 1U,0U);
    uint _S1246 = _S1235 + _S1245;
    bool _S1247 = _S1237 == 0U;
    uint _S1248 = _slang_select(_S1247, _S1246,_S1243);
    FKHit _S1249 = (fcptReservoirHit((*r_8)));
    float3  _S1250 = dom_7->x0;
    float3  _S1251 = dom_7->x1 - dom_7->x0;
    float3  _S1252 = ((((_S1251)) * make_float3(rnorm3df(((_S1251)).x, ((_S1251)).y, ((_S1251)).z))));
    FKRay _S1253 = Ray_x24init_0(dom_7->x1, _S1252);
    FKRay ray_2 = _S1253;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1232;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_1 = throughput_3;
    float3  glowed_0 = _S1232;
    float3  extinction_in_0 = _S1232;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1254 = dom_7->spread;
    float _S1255 = dom_7->width;
    float _S1256 = length_0(_S1251);
    NEEVertex _S1257 = NEEVertex_x24init_0(true, 0.0f, _S1232, _S1232, _S1232);
    NEEVertex nee_vertex_0 = _S1257;
    Vertex _S1258 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S1258;
    Reservoir _S1259 = (Reservoir{});
    Reservoir chain_0 = _S1259;
    uint _S1260 = r_8->seed;
    (&chain_0)->seed = r_8->seed;
    (&ray_2)->origin = _S1250;
    (&hit_4)->distance = _S1256;
    FKMedium _S1261 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1262 = filling_2;
    bool _S1263 = (fcptVaryingUsed());
    uint _S1264 = _slang_select(_S1263, _S1262,4294967295U);
    filling_2 = _S1264;
    scatter_in_0 = _S1261.scatter;
    extinction_in_0 = _S1261.extinction;
    g_in_0 = _S1261.g;
    Reservoir _S1265 = chain_0;
    uint _S1266 = filling_2;
    for(;;)
    {
        bool _S1267 = (fcptVaryingUsed());
        if(_S1267)
        {
            passes_0 = _S1266 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1268 = (fcptMajorant((_S1266)));
            spread_1 = _S1268;
        }
        else
        {
            spread_1 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_1)
        {
            turned_1 = 4294967295U == _S1248;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1237 == 1U;
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
            ended_0 = _S1233;
            sky_pdf_0 = 0.0f;
            spread_1 = _S1254;
            width_3 = _S1255;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_6 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1269 = (&prev_0)->rough;
        if(_S1269)
        {
            turned_1 = !(spread_1 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S1270 = stream(_S1260, 384U);
        uint tracking_0 = _S1270;
        weight_1 = throughput_3;
        glowed_0 = _S1232;
        b_6 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        threshold_0 = _S1254;
        width_3 = _S1255;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1231 = int(1);
                break;
            }
            uint _S1271 = b_6 + 320U;
            bool _S1272 = b_6 == 4294967295U;
            uint _S1273 = _slang_select(_S1272, 384U,_S1271);
            uint _S1274 = stream(_S1260, _S1273);
            Random _S1275 = pcg(_S1274);
            float _S1276 = - (F32_log((1.0f - _S1275.value))) / spread_1;
            if(passes_0)
            {
                float3  _S1277 = (&ray_2)->origin;
                float3  _S1278 = (&ray_2)->unit_direction;
                float _S1279 = (&hit_4)->distance;
                uint _S1280 = _slang_select(_S1272, 0U,b_6);
                uint _S1281 = (&prev_0)->lobe;
                uint _S1282 = _slang_select(_S1272, 3U,_S1281);
                float _S1283 = (fcptTrackMedium((_S1266), (_S1277), (_S1278), (_S1279), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1280), (_S1282), (_S1272)));
                wavelength_2 = _S1283;
            }
            else
            {
                wavelength_2 = _S1276;
            }
            bool _S1284 = !(wavelength_2 < ((&hit_4)->distance));
            if(_S1284)
            {
                _S1231 = int(1);
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
                float3  _S1285 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S1286 = sel_7->glow + _S1285;
                sel_7->glow = _S1286;
            }
            else
            {
            }
            glowed_0 = _S1232;
            uint b_8 = b_6 + 1U;
            float3  _S1287 = (&ray_2)->origin + make_float3 (wavelength_2) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1287;
            float3  _S1288 = flightWeight_0(scatter_in_0, extinction_in_0, spread_1, wavelength_2, true);
            float3  _S1289 = weight_1;
            float3  _S1290 = _slang_select(passes_0, _S1289,_S1288);
            float3  throughput_4 = throughput_2 * _S1290;
            uint _S1291 = stream(_S1260, b_8 + 320U);
            tracking_0 = _S1291;
            weight_1 = throughput_3;
            float width_6 = width_3 + threshold_0 * wavelength_2;
            float _S1292 = threshold_0 + 3.14159274101257324f;
            bool _S1293 = !replay_1;
            if(_S1293)
            {
                is_inside_5 = true;
            }
            else
            {
                bool _S1294 = b_8 == _S1248;
                if(_S1294)
                {
                    is_inside_5 = !passes_0;
                }
                else
                {
                    is_inside_5 = false;
                }
            }
            TreeSample _S1295 = TreeSample_x24init_0(_S1232, _S1232, 0.0f, 0U);
            if(is_inside_5)
            {
                float3  _S1296 = (&ray_2)->origin;
                float3  _S1297 = (&ray_2)->unit_direction;
                float3  _S1298 = (&ray_2)->unit_direction;
                uint _S1299 = stream(_S1260, b_8 + 64U);
                float3  _S1300 = extinction_in_0;
                float3  _S1301 = extinction_in_0;
                uint2  _S1302 = make_uint2 (_S1266);
                float3  _S1303 = (&ray_2)->unit_direction;
                uint _S1304 = arrivalLobe_0(b_8, (&prev_0)->lobe);
                FKHit _S1305 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1306 = _S1305;
                ShadowContext _S1307 = ShadowContext_x24init_0(_S1300, _S1301, _S1302, _S1303, b_8, _S1304, false, wavelength_2, width_6, &_S1306, false);
                ShadowContext _S1308 = _S1307;
                TreeSample _S1309 = sampleLightTree_0(_S1296, _S1297, _S1298, 0.0f, true, _S1299, &_S1308);
                light_3 = _S1309;
            }
            else
            {
                light_3 = _S1295;
            }
            float _S1310 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S1311 = (fcptMaxBounces());
            bool _S1312 = b_8 < _S1311;
            if(_S1312)
            {
                viewed_0 = (light_3.density) > 0.0f;
            }
            else
            {
                viewed_0 = false;
            }
            float _S1313 = _slang_select(viewed_0, _S1310,0.0f);
            float3  _S1314 = throughput_4 * light_3.radiance;
            float _S1315 = powerHeuristic(light_3.density, _S1313);
            float3  _S1316 = _S1314 * make_float3 (_S1310 * _S1315);
            float3  _S1317 = _slang_select(is_inside_5, _S1316,_S1232);
            if(replay_1)
            {
                _S1229 = b_8 == _S1248;
            }
            else
            {
                _S1229 = false;
            }
            if(_S1229)
            {
                bool _S1318 = _S1237 == 2U;
                if(_S1318)
                {
                    float _S1319 = resamplingTarget(_S1317);
                    passes_0 = _S1319 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1320 = Shift_x24init_0(_S1317, 1.0f);
                    _S1231 = int(0);
                    ended_0 = _S1320;
                    spread_1 = _S1292;
                    wavelength_2 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_8;
                    break;
                }
                _S1231 = int(0);
                ended_0 = _S1233;
                spread_1 = _S1292;
                wavelength_2 = width_6;
                chain_throughput_0 = throughput_4;
                layer_0 = b_8;
                break;
            }
            if(_S1293)
            {
                Reservoir candidate_3 = _S1265;
                uint _S1321 = extractBits_0(_S1265.path, 10U, 2U);
                bool _S1322 = _S1321 == 1U;
                if(_S1322)
                {
                    float3  _S1323 = safeDivide(_S1317, _S1232);
                    (&candidate_3)->radiance = _S1323;
                }
                else
                {
                    uint _S1324 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                    uint _S1325 = insertBits_0(_S1324, 2U, 10U, 2U);
                    (&candidate_3)->path = _S1325;
                }
                Reservoir _S1326 = withEnd(candidate_3, 0U, b_8, _S1317);
                offer(sel_7, _S1326, _S1317 * make_float3 (scale_3) / make_float3 (density_2));
                float _S1327 = survivalProbability(abs_0(throughput_4), density_2);
                uint _S1328 = stream(_S1260, b_8 + 128U);
                Random _S1329 = pcg(_S1328);
                bool _S1330 = _S1327 < (_S1329.value);
                if(_S1330)
                {
                    _S1230 = true;
                }
                else
                {
                    uint _S1331 = (fcptMaxBounces());
                    _S1230 = b_8 >= _S1331;
                }
                if(_S1230)
                {
                    _S1231 = int(0);
                    ended_0 = _S1233;
                    spread_1 = _S1292;
                    wavelength_2 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_8;
                    break;
                }
                float _S1332 = density_2 * _S1327;
                density_2 = _S1332;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1333 = stream(_S1260, b_8);
            float3  _S1334 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1333, &phase_pdf_0);
            (&ray_2)->unit_direction = _S1334;
            NEEVertex _S1335 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S1232, (&ray_2)->origin);
            nee_vertex_0 = _S1335;
            Vertex _S1336 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, false);
            prev_0 = _S1336;
            float _S1337 = (&prev_0)->pdf;
            FKRay _S1338 = ray_2;
            FKHit _S1339 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1340 = (fcptTraverseInstanceBVH((_S1338), (true), (4.294967296e+09f), (false), (_S1339), (false)));
            hit_4 = _S1340;
            b_6 = b_8;
            throughput_2 = throughput_4;
            threshold_0 = _S1292;
            width_3 = width_6;
            sky_pdf_0 = _S1337;
        }
        if(_S1231 != int(1))
        {
            width_3 = wavelength_2;
            throughput_2 = chain_throughput_0;
            b_6 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1233;
        spread_1 = threshold_0;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1341 = b_6 == 4294967295U;
    bool _S1342 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1342)
    {
        bool _S1343 = !(&nee_vertex_0)->none;
        float _S1344 = _slang_select(_S1343, sky_pdf_0,0.0f);
        float _S1345 = escapeWeight_0(_S1344, (&ray_2)->unit_direction);
        float3  _S1346 = environment_0((&ray_2)->unit_direction, b_6, (&prev_0)->lobe);
        float3  _S1347 = throughput_2 * _S1346;
        if(replay_1)
        {
            bool _S1348 = b_6 == _S1248;
            if(_S1348)
            {
                passes_0 = _S1237 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S1347 * make_float3 (_S1345) / make_float3 (r_8->jac), density_2 / r_8->jac);
            }
            if(_S1247)
            {
                passes_0 = _S1244;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_6 == _S1235;
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
                return Shift_x24init_0(_S1347 * make_float3 (_S1345), 1.0f);
            }
            return _S1233;
        }
        Reservoir candidate_4 = chain_0;
        uint _S1349 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1350 = _S1349 == 1U;
        if(_S1350)
        {
            uint _S1351 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S1352 = _S1351 == b_6;
            float _S1353 = _slang_select(_S1352, 1.0f,_S1345);
            float3  _S1354 = safeDivide(_S1347 * make_float3 (_S1353), _S1232);
            (&candidate_4)->radiance = _S1354;
        }
        else
        {
            bool _S1355 = (&prev_0)->rough;
            if(_S1355)
            {
                uint _S1356 = insertBits_0(0U, b_6 + 1U, 5U, 5U);
                uint _S1357 = insertBits_0(_S1356, 3U, 10U, 2U);
                uint _S1358 = insertBits_0(_S1357, (&prev_0)->lobe, 15U, 3U);
                bool _S1359 = (&prev_0)->inside;
                uint _S1360 = _slang_select(_S1359, 1U,0U);
                uint _S1361 = insertBits_0(_S1358, _S1360, 22U, 1U);
                (&candidate_4)->path = _S1361;
                (&candidate_4)->jac = (&prev_0)->pdf;
                (&candidate_4)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S1362 = _S1347 * make_float3 (_S1345);
        Reservoir _S1363 = withEnd(candidate_4, 3U, b_6, _S1362);
        offer(sel_7, _S1363, _S1362 * make_float3 (scale_3) / make_float3 (density_2));
        return _S1233;
    }
    float3  _S1364 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S1364;
    bool _S1365 = (fcptVaryingUsed());
    if(_S1365)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1366 = !replay_1;
        if(_S1366)
        {
            float3  _S1367 = throughput_2 * glowed_0 / make_float3 (density_2);
            float3  _S1368 = sel_7->glow + _S1367;
            sel_7->glow = _S1368;
        }
        float3  _S1369 = throughput_2 * weight_1;
        throughput_2 = _S1369;
    }
    else
    {
        float3  _S1370 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
        float3  _S1371 = throughput_2 * _S1370;
        throughput_2 = _S1371;
    }
    float _S1372 = width_3 + spread_1 * (&hit_4)->distance;
    uint _S1373 = b_6 + 1U;
    b_6 = _S1373;
    layer_0 = 0U;
    width_3 = _S1372;
    passes_0 = false;
    threshold_0 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    wavelength_2 = 0.0f;
    chain_throughput_0 = _S1232;
    float3  reconnection_0 = _S1232;
    viewed_0 = _S1341;
    for(;;)
    {
        bool _S1374 = ((&hit_4)->is_point_light) == 1U;
        if(replay_1)
        {
            _S1229 = _S1237 == 1U;
        }
        else
        {
            _S1229 = false;
        }
        if(_S1229)
        {
            _S1230 = b_6 == _S1236;
        }
        else
        {
            _S1230 = false;
        }
        bool _S1375;
        if(_S1230)
        {
            bool _S1376 = ((&hit_4)->instance_index) != (_S1249.instance_index);
            if(_S1376)
            {
                _S1375 = true;
            }
            else
            {
                _S1375 = ((&hit_4)->triangle_index) != (_S1249.triangle_index);
            }
        }
        else
        {
            _S1375 = false;
        }
        if(_S1375)
        {
            return _S1233;
        }
        FKMedium _S1377 = Medium_x24init_0(_S1232, _S1232, 0.0f);
        BSDFMaterial _S1378 = Material_x24init_0(_S1232, _S1232, 0.0f, 0.0f, 0.0f, 0.0f, _S1232, throughput_3, 1.0f, _S1232, _S1232, 0.5f, 0.0f, 0.0f, _S1232, 0.0f, _S1232, 0.0f);
        FKMedium _S1379 = _S1377;
        FKSurface _S1380 = Surface_x24init_0(_S1232, _S1232, 0.0f, &_S1378, false, 0U, 1.0f, false, &_S1379, 4294967295U, _S1232);
        bool _S1381 = !_S1374;
        bool scatter_2;
        bool is_inside_6;
        float geometry_density_0;
        float3  throughput_5;
        FKSurface surface_12;
        if(_S1381)
        {
            uint _S1382 = stream(_S1260, b_6);
            uint _S1383 = arrivalLobe_0(b_6, (&prev_0)->lobe);
            FKSurface _S1384 = (fcptSurfaceAtPath((hit_4), ((&ray_2)->origin), (_S1382), (width_3), (layer_0), (b_6), (_S1383), ((&ray_2)->unit_direction)));
            bool _S1385 = !passes_0;
            FKSurface _S1386 = _S1384;
            FKSurface _S1387 = emitting_0(&_S1386, _S1385);
            uint _S1388 = stream(_S1260, b_6 + 256U);
            Random _S1389 = pcg(_S1388);
            FKSurface _S1390 = _S1387;
            FKSurface _S1391 = uncovered_0(&_S1390, _S1389.value);
            float _S1392 = facingSign(_S1391.material.transmission, _S1391.geometry_n, (&ray_2)->unit_direction);
            bool _S1393 = _S1392 < 0.0f;
            bool _S1394 = (_S1391.material.transmission) > 0.0f;
            if(_S1394)
            {
                bool _S1395 = arrivesBehind_0((&ray_2)->unit_direction, _S1391.geometry_n);
                scatter_2 = _S1395;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1396 = _S1391;
            FKSurface _S1397 = facingRay_0(&_S1396, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S1398 = arrivesBehind_0((&ray_2)->unit_direction, _S1397.geometry_n);
                is_inside_6 = _S1398;
            }
            else
            {
                is_inside_6 = scatter_2;
            }
            if(is_inside_6)
            {
                float3  _S1399 = beerLambert((&hit_4)->distance, _S1397.material.absorption);
                float3  _S1400 = throughput_2 * _S1399;
                throughput_5 = _S1400;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S1401 = !_S1397.skip;
            float geometry_density_1 = (F32_abs((dot_0(_S1397.geometry_n, (&ray_2)->unit_direction)))) / ((&hit_4)->distance * (&hit_4)->distance);
            bool _S1402 = b_6 == _S1373;
            if(_S1402)
            {
                float _S1403 = 0.00251327408477664f / geometry_density_1;
                geometry_density_0 = _S1403;
            }
            else
            {
                geometry_density_0 = threshold_0;
            }
            float _S1404 = geometry_density_0;
            scatter_2 = _S1401;
            geometry_density_0 = geometry_density_1;
            threshold_0 = _S1404;
            surface_12 = _S1397;
            turned_1 = _S1393;
        }
        else
        {
            scatter_2 = false;
            geometry_density_0 = 0.0f;
            surface_12 = _S1380;
            throughput_5 = throughput_2;
            is_inside_6 = is_inside_5;
        }
        bool _S1405;
        if(scatter_2)
        {
            _S1405 = (&prev_0)->rough;
        }
        else
        {
            _S1405 = false;
        }
        bool _S1406;
        if(_S1405)
        {
            _S1406 = ((&prev_0)->pdf * geometry_density_0 * threshold_0) <= 1.0f;
        }
        else
        {
            _S1406 = false;
        }
        FKSurface _S1407 = surface_12;
        FKSurface _S1408 = surface_12;
        float _S1409 = dot_0(surface_12.smooth_n, - (&ray_2)->unit_direction);
        bool _S1410 = (fcptDispersionUsed());
        bool _S1411;
        if(_S1410)
        {
            _S1411 = wavelength_2 == 0.0f;
        }
        else
        {
            _S1411 = false;
        }
        bool _S1412;
        if(_S1411)
        {
            _S1412 = scatter_2;
        }
        else
        {
            _S1412 = false;
        }
        bool _S1413;
        if(_S1412)
        {
            bool _S1414 = dispersive(_S1407.material);
            _S1413 = _S1414;
        }
        else
        {
            _S1413 = false;
        }
        float3  throughput_6;
        if(_S1413)
        {
            uint _S1415 = stream(_S1260, 512U);
            Random _S1416 = pcg(_S1415);
            float2  _S1417 = sampleWavelength(_S1416.value);
            float _S1418 = _S1417.x;
            float3  _S1419 = wavelengthWeights(_S1418);
            float3  _S1420 = throughput_5 * (_S1419 / make_float3 (_S1417.y));
            wavelength_2 = _S1418;
            throughput_6 = _S1420;
        }
        else
        {
            throughput_6 = throughput_5;
        }
        BSDFMaterial refractive_0 = _S1407.material;
        float _S1421 = dispersedIor(_S1407.material.ior, _S1407.material.dispersion, wavelength_2);
        bool _S1422 = wavelength_2 > 0.0f;
        float _S1423 = _slang_select(_S1422, _S1421,_S1407.material.ior);
        (&refractive_0)->ior = _S1423;
        float2  _S1424 = vertexEta(refractive_0, _S1409);
        bool _S1425;
        if(scatter_2)
        {
            uint _S1426 = (fcptMaxBounces());
            bool _S1427 = b_6 >= _S1426;
            if(_S1427)
            {
                _S1425 = true;
            }
            else
            {
                bool _S1428 = neeDecision(_S1407.material, _S1409, _S1424.x, _S1424.y);
                _S1425 = _S1428;
            }
        }
        else
        {
            _S1425 = false;
        }
        bool _S1429;
        if(passes_0)
        {
            _S1429 = true;
        }
        else
        {
            _S1429 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1429)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1425;
        }
        bool _S1430 = (fcptHairUsed());
        bool _S1431;
        if(_S1430)
        {
            float3  _S1432 = surface_12.hair;
            _S1431 = (dot_0(_S1432, _S1432)) > 0.0f;
        }
        else
        {
            _S1431 = false;
        }
        bool _S1433;
        if(_S1431)
        {
            _S1433 = true;
        }
        else
        {
            BSDFMaterial _S1434 = _S1407.material;
            bool _S1435 = isTranslucent_0(&_S1434);
            _S1433 = _S1435;
        }
        bool _S1436;
        if(_S1433)
        {
            _S1436 = true;
        }
        else
        {
            bool _S1437 = (_S1407.material.transmission) > 0.0f;
            if(_S1437)
            {
                uint _S1438 = (fcptLayers((hit_4)));
                _S1436 = _S1438 == 1U;
            }
            else
            {
                _S1436 = false;
            }
        }
        float3  emission_0;
        if(_S1374)
        {
            float3  _S1439 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1439;
        }
        else
        {
            emission_0 = _S1407.material.emissive;
        }
        bool _S1440 = !replay_1;
        bool _S1441;
        if(_S1440)
        {
            _S1441 = true;
        }
        else
        {
            _S1441 = b_6 >= _S1248;
        }
        bool _S1442;
        if(_S1441)
        {
            float _S1443 = rgb_to_greyscale(emission_0);
            _S1442 = _S1443 > 0.0f;
        }
        else
        {
            _S1442 = false;
        }
        float3  emission_1;
        if(_S1442)
        {
            NEEVertex _S1444 = nee_vertex_0;
            FKHit _S1445 = hit_4;
            float _S1446 = emissionWeight_0(&_S1444, &_S1445, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1446);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1447;
        if(replay_1)
        {
            _S1447 = _S1237 == 1U;
        }
        else
        {
            _S1447 = false;
        }
        bool _S1448;
        if(_S1447)
        {
            _S1448 = b_6 > _S1236;
        }
        else
        {
            _S1448 = false;
        }
        bool _S1449;
        if(_S1448)
        {
            _S1449 = b_6 == _S1235;
        }
        else
        {
            _S1449 = false;
        }
        bool _S1450;
        if(_S1449)
        {
            bool _S1451 = _S1238 == 1U;
            if(_S1451)
            {
                _S1450 = true;
            }
            else
            {
                _S1450 = _S1238 == 2U;
            }
        }
        else
        {
            _S1450 = false;
        }
        if(_S1450)
        {
            bool _S1452 = _S1374 != (_S1238 == 2U);
            if(_S1452)
            {
                return _S1233;
            }
            return Shift_x24init_0(throughput_6 * emission_1 / make_float3 (r_8->jac), density_2 / r_8->jac);
        }
        uint _S1453 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1454 = _S1453 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1455 = insertBits_0(0U, b_6, 5U, 5U);
        uint _S1456 = insertBits_0(_S1455, 1U, 10U, 2U);
        uint _S1457 = insertBits_0(_S1456, (&prev_0)->lobe, 15U, 3U);
        bool _S1458 = (&prev_0)->inside;
        uint _S1459 = _slang_select(_S1458, 1U,0U);
        uint _S1460 = insertBits_0(_S1457, _S1459, 22U, 1U);
        (&here_0)->path = _S1460;
        uint _S1461 = (&here_0)->path;
        uint _S1462 = _slang_select(_S1422, 1U,0U);
        uint _S1463 = insertBits_0(_S1461, _S1462, 23U, 1U);
        (&here_0)->path = _S1463;
        float _S1464 = (&prev_0)->pdf * geometry_density_0;
        (&here_0)->jac = _S1464;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1465;
        if(replay_1)
        {
            _S1465 = _S1237 == 1U;
        }
        else
        {
            _S1465 = false;
        }
        bool _S1466;
        if(_S1465)
        {
            _S1466 = b_6 == _S1236;
        }
        else
        {
            _S1466 = false;
        }
        bool _S1467 = b_6 == _S1248;
        bool _S1468;
        if(_S1467)
        {
            bool _S1469 = !scatter_2;
            if(_S1469)
            {
                _S1468 = true;
            }
            else
            {
                bool _S1470 = _S1237 != 1U;
                if(_S1470)
                {
                    _S1468 = _S1237 != 3U;
                }
                else
                {
                    _S1468 = false;
                }
            }
        }
        else
        {
            _S1468 = false;
        }
        bool _S1471;
        if(_S1468)
        {
            _S1471 = _S1237 == 2U;
        }
        else
        {
            _S1471 = false;
        }
        bool _S1472;
        if(_S1471)
        {
            _S1472 = !_S1406;
        }
        else
        {
            _S1472 = false;
        }
        bool _S1473;
        if(_S1472)
        {
            _S1473 = _S1238 != 4U;
        }
        else
        {
            _S1473 = false;
        }
        bool _S1474 = _S1236 == _S1235;
        bool _S1475;
        if(_S1474)
        {
            _S1475 = _S1238 == 0U;
        }
        else
        {
            _S1475 = false;
        }
        bool _S1476;
        if(_S1475)
        {
            _S1476 = ((&hit_4)->instance_index) == (_S1249.instance_index);
        }
        else
        {
            _S1476 = false;
        }
        bool _S1477;
        if(_S1476)
        {
            _S1477 = ((&hit_4)->triangle_index) == (_S1249.triangle_index);
        }
        else
        {
            _S1477 = false;
        }
        bool _S1478;
        if(_S1477)
        {
            _S1478 = _S1406;
        }
        else
        {
            _S1478 = false;
        }
        bool _S1479 = _slang_select(_S1466, _S1478,_S1473);
        bool _S1480;
        if(nee_0)
        {
            _S1480 = _slang_select(replay_1, _S1479,scatter_2);
        }
        else
        {
            _S1480 = false;
        }
        TreeSample _S1481 = TreeSample_x24init_0(_S1232, _S1232, 0.0f, 0U);
        uint2  _S1482 = make_uint2 (0U);
        float2  _S1483 = make_float2 (0.0f);
        FKHit _S1484 = Hit_x24init_0(_S1483, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1485 = _S1484;
        ShadowContext _S1486 = ShadowContext_x24init_0(_S1232, _S1232, _S1482, _S1232, 0U, 0U, false, 0.0f, 0.0f, &_S1485, false);
        bool _S1487;
        if(nee_0)
        {
            _S1487 = _S1441;
        }
        else
        {
            _S1487 = false;
        }
        ShadowContext context_5;
        if(_S1487)
        {
            uint _S1488 = arrivalLobe_0(b_6, (&prev_0)->lobe);
            FKMedium _S1489 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1490 = surface_12;
            FKHit _S1491 = hit_4;
            FKMedium _S1492 = _S1489;
            ShadowContext _S1493 = shadowContext_0(&_S1490, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_6, _S1488, (&hit_4)->distance, width_3, &_S1491, _S1431, &_S1492);
            context_5 = _S1493;
        }
        else
        {
            context_5 = _S1486;
        }
        float3  throughput_7;
        float3  lit_0;
        if(_S1480)
        {
            float3  _S1494 = (&ray_2)->origin;
            if(_S1431)
            {
                throughput_7 = _S1232;
            }
            else
            {
                throughput_7 = _S1408.smooth_n;
            }
            FKSurface _S1495 = surface_12;
            uint _S1496 = stream(_S1260, b_6 + 64U);
            ShadowContext _S1497 = context_5;
            TreeSample _S1498 = sampleLightTree_0(_S1494, throughput_7, surface_12.geometry_n, surface_12.geometry_offset, _S1436, _S1496, &_S1497);
            bool _S1499 = any_1((_S1498.radiance) != _S1232);
            if(_S1499)
            {
                if(_S1431)
                {
                    uint _S1500 = (fcptMaxBounces());
                    bool _S1501 = b_6 < _S1500;
                    FKSurface _S1502 = surface_12;
                    TreeSample _S1503 = _S1498;
                    float3  _S1504 = hairLight_0(&_S1502, (&ray_2)->unit_direction, &_S1503, _S1501);
                    lit_0 = _S1504;
                }
                else
                {
                    float _S1505 = _S1424.x;
                    float _S1506 = _S1424.y;
                    uint _S1507 = (fcptMaxBounces());
                    bool _S1508 = b_6 < _S1507;
                    TreeSample _S1509 = _S1498;
                    BSDFMaterial _S1510 = _S1407.material;
                    float3  _S1511 = lightBSDF_0((&ray_2)->unit_direction, &_S1509, _S1408.smooth_n, _S1495.geometry_n, &_S1510, _S1505, _S1506, _S1508, surface_12.random_state);
                    lit_0 = _S1511;
                }
            }
            else
            {
                lit_0 = _S1232;
            }
            light_3 = _S1498;
        }
        else
        {
            light_3 = _S1481;
            lit_0 = _S1232;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1512;
        bool _S1513;
        float density_4;
        if(_S1466)
        {
            bool _S1514 = !_S1406;
            if(_S1514)
            {
                return _S1233;
            }
            uint _S1515 = extractBits_0(_S1234, 23U, 1U);
            bool _S1516 = _S1422 != (_S1515 == 1U);
            if(_S1516)
            {
                return _S1233;
            }
            float3  throughput_8 = throughput_6 * make_float3 (geometry_density_0);
            float density_5 = density_2 * geometry_density_0;
            if(_S1474)
            {
                viewed_1 = _S1238 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                return Shift_x24init_0(throughput_8 * emission_1 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1474)
            {
                refracted_4 = _S1238 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S1517 = !nee_0;
                if(_S1517)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1518 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1518 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1233;
                }
                return Shift_x24init_0(throughput_8 * lit_0 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1474)
            {
                wrong_side_0 = _S1238 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1519 = !nee_0;
                if(_S1519)
                {
                    return _S1233;
                }
                float _S1520 = environmentPdf_0(r_8->dir);
                float3  _S1521 = skyBSDF((&ray_2)->unit_direction, r_8->dir, surface_12, _S1424, is_inside_6, _S1520, surface_12.random_state);
                return Shift_x24init_0(throughput_8 * _S1521 * r_8->radiance / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            uint _S1522 = extractBits_0(_S1234, 21U, 1U);
            bool _S1523 = nee_0 != (_S1522 == 1U);
            if(_S1523)
            {
                return _S1233;
            }
            throughput_7 = throughput_8;
            density_4 = density_5;
        }
        else
        {
            if(replay_1)
            {
                viewed_1 = _S1467;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1524 = !scatter_2;
                if(_S1524)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1525 = _S1237 != 1U;
                    if(_S1525)
                    {
                        refracted_4 = _S1237 != 3U;
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
                bool _S1526 = _S1237 == 2U;
                if(_S1526)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1406;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1238 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1431)
                    {
                        return _S1233;
                    }
                    uint _S1527 = stream(_S1260, b_6 + 448U);
                    FKRay _S1528 = ray_2;
                    FKSurface _S1529 = surface_12;
                    ShadowContext _S1530 = context_5;
                    SkySample _S1531 = sampleSky_0(&_S1528, &_S1529, _S1424, is_inside_6, _S1527, surface_12.random_state, &_S1530);
                    return Shift_x24init_0(throughput_6 * _S1531.color, 1.0f);
                }
                if(_S1526)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1406;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1532 = rgb_to_greyscale(light_3.radiance);
                    bool _S1533 = !(_S1532 > 0.0f);
                    if(_S1533)
                    {
                        return _S1233;
                    }
                    return Shift_x24init_0(throughput_6 * lit_0, 1.0f);
                }
                if(_S1247)
                {
                    passes_0 = _S1238 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1374;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_6 * emission_1, 1.0f);
                }
                if(_S1247)
                {
                    passes_0 = _S1238 == 1U;
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
                    passes_0 = !_S1406;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_6 * emission_1, 1.0f);
                }
                return _S1233;
            }
            else
            {
                if(_S1440)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1534 = b_6 > 0U;
                    if(_S1534)
                    {
                        Reservoir candidate_5 = chain_0;
                        if(_S1454)
                        {
                            float3  _S1535 = safeDivide(throughput_6 * emission_1, chain_throughput_0);
                            (&candidate_5)->radiance = _S1535;
                        }
                        else
                        {
                            if(_S1406)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1536 = throughput_6 * emission_1;
                        Reservoir _S1537 = withEnd(candidate_5, 1U, b_6, _S1536);
                        offer(sel_7, _S1537, _S1536 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1538 = throughput_6 * emission_1;
                        float3  _S1539 = sel_7->glow + _S1538;
                        sel_7->glow = _S1539;
                    }
                    if(nee_0)
                    {
                        float3  _S1540 = throughput_6 * lit_0;
                        Reservoir candidate_6 = chain_0;
                        if(_S1454)
                        {
                            float3  _S1541 = safeDivide(_S1540, chain_throughput_0);
                            (&candidate_6)->radiance = _S1541;
                        }
                        else
                        {
                            if(_S1406)
                            {
                                candidate_6 = here_0;
                                uint _S1542 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1542;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1543 = insertBits_0(0U, b_6 + 1U, 5U, 5U);
                                uint _S1544 = insertBits_0(_S1543, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1544;
                            }
                        }
                        Reservoir _S1545 = withEnd(candidate_6, 0U, b_6, _S1540);
                        offer(sel_7, _S1545, _S1540 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1431)
                        {
                            _S1512 = false;
                        }
                        else
                        {
                            bool _S1546 = environmentMapped_0();
                            _S1512 = _S1546;
                        }
                    }
                    else
                    {
                        _S1512 = false;
                    }
                    if(_S1512)
                    {
                        uint _S1547 = (fcptMaxBounces());
                        _S1513 = b_6 < _S1547;
                    }
                    else
                    {
                        _S1513 = false;
                    }
                    if(_S1513)
                    {
                        uint _S1548 = stream(_S1260, b_6 + 448U);
                        FKRay _S1549 = ray_2;
                        FKSurface _S1550 = surface_12;
                        ShadowContext _S1551 = context_5;
                        SkySample _S1552 = sampleSky_0(&_S1549, &_S1550, _S1424, is_inside_6, _S1548, surface_12.random_state, &_S1551);
                        float3  _S1553 = throughput_6 * _S1552.color;
                        Reservoir candidate_7 = chain_0;
                        if(_S1454)
                        {
                            float3  _S1554 = safeDivide(_S1553, chain_throughput_0);
                            (&candidate_7)->radiance = _S1554;
                        }
                        else
                        {
                            if(_S1406)
                            {
                                candidate_7 = here_0;
                                uint _S1555 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1555;
                                (&candidate_7)->dir = _S1552.dir;
                                (&candidate_7)->radiance = _S1552.radiance;
                            }
                            else
                            {
                                uint _S1556 = insertBits_0(0U, b_6 + 1U, 5U, 5U);
                                uint _S1557 = insertBits_0(_S1556, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1557;
                            }
                        }
                        Reservoir _S1558 = withEnd(candidate_7, 4U, b_6, _S1553);
                        offer(sel_7, _S1558, _S1553 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                }
            }
            throughput_7 = throughput_6;
            density_4 = density_2;
        }
        bool _S1559;
        bool _S1560;
        bool _S1561;
        bool straight_0;
        bool _S1562;
        bool _S1563;
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
                viewed_1 = _S1467;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1575 = extractBits_0(_S1234, 15U, 3U);
            uint _S1576 = extractBits_0(_S1234, 18U, 3U);
            uint _S1577 = _slang_select(_S1466, _S1576,_S1575);
            float3  _S1578 = r_8->dir;
            bool refracted_5 = _S1577 == 1U;
            SampleBSDF _S1579 = SampleBSDF_x24init_0(_S1232, _S1232, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1579;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1580 = extractBits_0(_S1234, 22U, 1U);
                bool _S1581 = is_inside_6 != (_S1580 == 1U);
                if(_S1581)
                {
                    return _S1233;
                }
                bool _S1582 = _S1237 == 1U;
                if(_S1582)
                {
                    float3  _S1583 = (fcptHitPosition((_S1249)));
                    throughput_9 = _S1583;
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
                    BSDFMaterial _S1584 = _S1407.material;
                    bool _S1585 = isTranslucent_0(&_S1584);
                    if(_S1585)
                    {
                        refracted_4 = _S1577 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1586 = throughput_9 - (&ray_2)->origin;
                        float3  _S1587 = _slang_select(_S1582, _S1586,_S1578);
                        wrong_side_0 = (dot_0(_S1408.smooth_n, _S1587) * _S1409) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1582)
                {
                    float3  _S1588 = (&ray_2)->origin;
                    FKSurface _S1589 = surface_12;
                    float3  _S1590 = - _S1408.smooth_n;
                    bool _S1591 = is_inside_6 != refracted_4;
                    float3  _S1592 = _slang_select(_S1591, _S1590,_S1408.smooth_n);
                    float3  _S1593 = throughput_9 - (_S1588 + make_float3 (_S1589.geometry_offset) * _S1592);
                    float3  _S1594 = ((((_S1593)) * make_float3(rnorm3df(((_S1593)).x, ((_S1593)).y, ((_S1593)).z))));
                    reconnection_1 = _S1594;
                }
                else
                {
                    reconnection_1 = _S1578;
                }
                if(_S1431)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1595 = wrongSide_0(is_inside_6, refracted_4, reconnection_1, surface_12.geometry_n);
                    wrong_side_0 = _S1595;
                }
                if(wrong_side_0)
                {
                    return _S1233;
                }
                float3  _S1596 = throughput_9;
                throughput_9 = reconnection_1;
                b_9 = _S1577;
                wrong_side_0 = false;
                reconnection_1 = _S1596;
            }
            else
            {
                bool _S1597 = !_S1466;
                if(_S1597)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1598;
                    if(_S1431)
                    {
                        SampleBSDF _S1599 = (fcptSampleHair((surface_12.hair), (_S1407.material.albedo), (_S1407.material.specular_tint), ((&ray_2)->unit_direction), (surface_12.random_state)));
                        _S1598 = _S1599;
                    }
                    else
                    {
                        SampleBSDF _S1600 = sampleBSDF((&ray_2)->unit_direction, _S1408.smooth_n, _S1407.material, _S1424.x, _S1424.y, surface_12.random_state, _S1483);
                        _S1598 = _S1600;
                    }
                    bsdf_sampled_0 = _S1598;
                    if(_S1431)
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
                            return _S1233;
                        }
                        break;
                    }
                    if(_S1431)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1601 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_12.geometry_n);
                        wrong_side_0 = _S1601;
                    }
                    if(wrong_side_0)
                    {
                        _S1512 = (_S1407.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1512 = false;
                    }
                    if(_S1512)
                    {
                        SampleBSDF _S1602 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S1407.material, _S1424.x, _S1424.y, (&bsdf_sampled_0)->random_state, _S1483);
                        (&bsdf_sampled_0)->unit_direction = _S1602.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1602.refracted;
                        (&bsdf_sampled_0)->throughput = _S1602.throughput;
                        (&bsdf_sampled_0)->lobe = _S1602.lobe;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1603 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n)) * surface_12.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1603;
                        }
                    }
                    uint _S1604 = (&bsdf_sampled_0)->lobe;
                    float3  _S1605 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1606 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1607 = (&bsdf_sampled_0)->pdf;
                    float _S1608 = _slang_select(wrong_side_0, 0.0f,_S1607);
                    (&lobe_5)->pdf = _S1608;
                    throughput_9 = _S1605;
                    b_9 = _S1604;
                    refracted_4 = _S1606;
                }
                else
                {
                    throughput_9 = _S1578;
                    b_9 = _S1577;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1512 = true;
            }
            else
            {
                _S1512 = _S1466;
            }
            float3  chain_throughput_1;
            if(_S1512)
            {
                if(_S1431)
                {
                    SampleBSDF _S1609 = (fcptConnectHair((surface_12.hair), (_S1407.material.albedo), (_S1407.material.specular_tint), ((&ray_2)->unit_direction), (throughput_9)));
                    lobe_5 = _S1609;
                }
                else
                {
                    float3  _S1610 = (&ray_2)->unit_direction;
                    float3  _S1611 = negate_0(_S1610);
                    float _S1612 = sign_0(_S1409);
                    float3  _S1613 = _S1408.smooth_n * make_float3 (_S1612);
                    float _S1614 = dot_0(_S1613, throughput_9);
                    float _S1615 = _S1407.material.roughness;
                    float _S1616 = _S1615 * _S1615;
                    AnisotropicFrame _S1617 = anisotropicFrame(_S1407.material, _S1613);
                    SheenProfile _S1618 = sheenProfile(_S1611, _S1613, _S1407.material);
                    float3  _S1619 = reflectedHalf(_S1610, throughput_9);
                    bool _S1620 = b_9 == 1U;
                    if(_S1620)
                    {
                        float3  _S1621 = refractedHalf(_S1610, throughput_9, _S1408.smooth_n, _S1424.x, _S1424.y);
                        throughput_10 = _S1621;
                    }
                    else
                    {
                        throughput_10 = _S1619;
                    }
                    bool _S1622 = b_9 == 0U;
                    if(_S1622)
                    {
                        _S1513 = true;
                    }
                    else
                    {
                        _S1513 = b_9 == 6U;
                    }
                    if(_S1513)
                    {
                        float3  _S1623 = sampledHalf(_S1611, _S1613, _S1616, _S1617, surface_12.random_state);
                        throughput_11 = _S1623;
                    }
                    else
                    {
                        throughput_11 = throughput_10;
                    }
                    float _S1624 = _S1424.x;
                    float _S1625 = _S1424.y;
                    Weights _S1626 = lobeWeights(_S1610, _S1611, _S1613, throughput_11, _S1617, _S1618, _S1407.material, _S1624, _S1625);
                    float _S1627 = (F32_abs((_S1409)));
                    float _S1628 = vndfPDF(_S1611, throughput_11, _S1613, _S1627, _S1616, _S1617, _S1626.v_dot_h);
                    switch(b_9)
                    {
                    case 0U:
                        {
                            float _S1629 = diffusePDF(_S1614, _S1627, _S1407.material, _S1626);
                            float3  _S1630 = diffuseBSDF(throughput_9, _S1613, _S1407.material, _S1626);
                            density_6 = _S1629;
                            chain_throughput_1 = _S1630;
                            break;
                        }
                    case 1U:
                        {
                            float _S1631 = refractPDF(dot_0(throughput_9, throughput_11), _S1628, _S1626, _S1624, _S1625);
                            float3  _S1632 = refractBSDF(throughput_9, _S1613, _S1616, _S1617, _S1407.material, _S1626);
                            density_6 = _S1631;
                            chain_throughput_1 = _S1632;
                            break;
                        }
                    case 4U:
                        {
                            float _S1633 = sheenVelvetPDF(_S1614, _S1627, _S1626);
                            float3  _S1634 = sheenVelvetBSDF(throughput_9, _S1611, _S1613, _S1407.material, _S1626);
                            density_6 = _S1633;
                            chain_throughput_1 = _S1634;
                            break;
                        }
                    case 6U:
                        {
                            ToonProfile _S1635 = toonProfile(_S1611, _S1613, _S1407.material);
                            float _S1636 = toonPDF(throughput_9, _S1613, _S1635, _S1626);
                            float3  _S1637 = toonBSDF(throughput_9, _S1613, _S1635, _S1626);
                            density_6 = _S1636;
                            chain_throughput_1 = _S1637;
                            break;
                        }
                    default:
                        {
                            float _S1638 = reflectPDF(_S1628, _S1626);
                            float3  _S1639 = reflectBSDF(throughput_9, _S1613, _S1616, _S1617, _S1626);
                            density_6 = _S1638;
                            chain_throughput_1 = _S1639;
                            break;
                        }
                    }
                    bool _S1640 = density_6 > 0.0f;
                    if(_S1640)
                    {
                        SampleBSDF _S1641 = SampleBSDF_x24init_0(throughput_9, chain_throughput_1, surface_12.random_state, _S1620, b_9, density_6);
                        lobe_5 = _S1641;
                    }
                }
            }
            bool _S1642 = b_9 == 0U;
            if(_S1642)
            {
                _S1513 = true;
            }
            else
            {
                _S1513 = b_9 == 4U;
            }
            if(_S1513)
            {
                _S1559 = true;
            }
            else
            {
                _S1559 = b_9 == 6U;
            }
            if(_S1431)
            {
                _S1560 = false;
            }
            else
            {
                bool _S1643 = !_S1559;
                if(_S1643)
                {
                    bool _S1644 = (_S1407.material.roughness) == 0.0f;
                    if(_S1644)
                    {
                        _S1560 = true;
                    }
                    else
                    {
                        bool _S1645 = b_9 == 1U;
                        if(_S1645)
                        {
                            _S1560 = (_S1424.x) == (_S1424.y);
                        }
                        else
                        {
                            _S1560 = false;
                        }
                    }
                }
                else
                {
                    _S1560 = false;
                }
            }
            bool _S1646 = !_S1431;
            if(_S1646)
            {
                _S1561 = b_9 == 1U;
            }
            else
            {
                _S1561 = false;
            }
            if(_S1561)
            {
                straight_0 = (_S1407.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1562 = _S1646;
            }
            else
            {
                _S1562 = false;
            }
            if(_S1562)
            {
                _S1563 = b_9 == 1U;
            }
            else
            {
                _S1563 = false;
            }
            if(_S1563)
            {
                _S1564 = (_S1424.x) == (_S1424.y);
            }
            else
            {
                _S1564 = false;
            }
            BSDFMaterial _S1647 = _S1407.material;
            bool _S1648 = isTranslucent_0(&_S1647);
            if(_S1648)
            {
                _S1565 = _S1642;
            }
            else
            {
                _S1565 = false;
            }
            if(_S1565)
            {
                _S1566 = (dot_0(throughput_9, surface_12.geometry_n)) < 0.0f;
            }
            else
            {
                _S1566 = false;
            }
            if(nee_0)
            {
                _S1567 = !_S1560;
            }
            else
            {
                _S1567 = false;
            }
            if(_S1567)
            {
                _S1568 = !wrong_side_0;
            }
            else
            {
                _S1568 = false;
            }
            if(_S1568)
            {
                float _S1649 = (&lobe_5)->pdf;
                float3  _S1650 = (&ray_2)->origin;
                float3  _S1651 = _slang_select(_S1436, _S1232,_S1408.smooth_n);
                float3  _S1652 = (&ray_2)->origin;
                FKSurface _S1653 = surface_12;
                float3  _S1654 = - _S1408.smooth_n;
                float3  _S1655 = _slang_select(_S1566, _S1654,_S1408.smooth_n);
                NEEVertex _S1656 = NEEVertex_x24init_0(false, _S1649, _S1650, _S1651, _S1652 + make_float3 (_S1653.geometry_offset) * _S1655);
                nee_vertex_0 = _S1656;
            }
            else
            {
                if(_S1431)
                {
                    _S1569 = true;
                }
                else
                {
                    bool _S1657 = b_9 != 1U;
                    if(_S1657)
                    {
                        _S1569 = true;
                    }
                    else
                    {
                        _S1569 = (_S1424.x) != (_S1424.y);
                    }
                }
                if(_S1569)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1658 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1658)
            {
                if(_S1559)
                {
                    _S1569 = true;
                }
                else
                {
                    _S1569 = ((&lobe_5)->pdf * (&prev_0)->cos / ((&hit_4)->distance * (&hit_4)->distance) * threshold_0) <= 1.0f;
                }
            }
            else
            {
                _S1569 = false;
            }
            bool _S1659 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1659)
            {
                if(_S1559)
                {
                    _S1570 = true;
                }
                else
                {
                    _S1570 = (_S1407.material.roughness) >= 0.20000000298023224f;
                }
            }
            else
            {
                _S1570 = false;
            }
            if(_S1466)
            {
                bool _S1660 = !_S1569;
                if(_S1660)
                {
                    return _S1233;
                }
                bool _S1661 = _S1238 != 1U;
                if(_S1661)
                {
                    _S1571 = _S1238 != 2U;
                }
                else
                {
                    _S1571 = false;
                }
                if(_S1571)
                {
                    float _S1662 = (&lobe_5)->pdf;
                    float _S1663 = _slang_select(nee_0, _S1662,0.0f);
                    float _S1664 = escapeWeight_0(_S1663, _S1578);
                    if(_S1474)
                    {
                        passes_0 = _S1244;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1665 = _slang_select(passes_0, _S1664,1.0f);
                    return Shift_x24init_0(throughput_7 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_8->radiance * make_float3 (_S1665) / make_float3 (r_8->jac), density_4 * (&lobe_5)->pdf / r_8->jac);
                }
                float3  _S1666 = throughput_7 * make_float3 ((&lobe_5)->pdf);
                float _S1667 = density_4 * (&lobe_5)->pdf;
                throughput_10 = _S1666;
                density_6 = _S1667;
            }
            else
            {
                throughput_10 = throughput_7;
                density_6 = density_4;
            }
            uint _S1668 = (fcptLayers((hit_4)));
            bool _S1669 = _S1668 > 1U;
            if(_S1669)
            {
                _S1571 = (b_9 == 1U) != passes_0;
            }
            else
            {
                _S1571 = false;
            }
            if(viewed_1)
            {
                _S1572 = _S1571;
            }
            else
            {
                _S1572 = false;
            }
            if(_S1572)
            {
                return _S1233;
            }
            if(replay_1)
            {
                _S1573 = b_6 <= _S1248;
            }
            else
            {
                _S1573 = false;
            }
            if(_S1573)
            {
                _S1574 = _S1406;
            }
            else
            {
                _S1574 = false;
            }
            bool _S1670;
            if(_S1574)
            {
                _S1670 = _S1569;
            }
            else
            {
                _S1670 = false;
            }
            bool _S1671;
            if(_S1670)
            {
                _S1671 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1671 = !_S1570;
                }
                else
                {
                    _S1671 = false;
                }
            }
            if(_S1671)
            {
                return _S1233;
            }
            if(viewed_1)
            {
                float3  _S1672 = throughput_10 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1673 = (&lobe_5)->pdf;
                throughput_11 = _S1672;
                sky_pdf_2 = _S1673;
            }
            else
            {
                float3  _S1674 = throughput_10 * max_0((&lobe_5)->throughput, _S1232);
                throughput_11 = _S1674;
                sky_pdf_2 = density_6;
            }
            bool _S1675;
            if(_S1440)
            {
                _S1675 = !_S1454;
            }
            else
            {
                _S1675 = false;
            }
            bool _S1676;
            if(_S1675)
            {
                _S1676 = _S1406;
            }
            else
            {
                _S1676 = false;
            }
            bool _S1677;
            if(_S1676)
            {
                _S1677 = _S1569;
            }
            else
            {
                _S1677 = false;
            }
            if(_S1677)
            {
                chain_0 = here_0;
                uint _S1678 = insertBits_0((&chain_0)->path, b_9, 18U, 3U);
                uint _S1679 = _slang_select(nee_0, 1U,0U);
                uint _S1680 = insertBits_0(_S1678, _S1679, 21U, 1U);
                (&chain_0)->path = _S1680;
                float _S1681 = (&chain_0)->jac * (&lobe_5)->pdf;
                (&chain_0)->jac = _S1681;
                (&chain_0)->dir = throughput_9;
                chain_throughput_1 = throughput_11;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1682 = surface_12;
            Vertex _S1683 = Vertex_x24init_0(_S1570, b_9, (&lobe_5)->pdf, (F32_abs((dot_0(surface_12.geometry_n, throughput_9)))), is_inside_6);
            prev_0 = _S1683;
            float _S1684 = (&lobe_5)->pdf;
            bool _S1685 = b_9 == 1U;
            bool _S1686;
            if(_S1685)
            {
                _S1686 = (_S1424.x) == (_S1424.y);
            }
            else
            {
                _S1686 = false;
            }
            float sky_pdf_3 = _slang_select(_S1686, sky_pdf_0,_S1684);
            float _S1687 = _slang_select(_S1431, 0.0f,sky_pdf_3);
            float _S1688 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * (&lobe_5)->pdf))))), (3.14159274101257324f)));
            bool _S1689 = !_S1560;
            float _S1690 = _slang_select(_S1689, _S1688,0.0f);
            float _S1691 = spread_1 + _S1690;
            bool _S1692;
            if(refracted_4)
            {
                _S1692 = !_S1566;
            }
            else
            {
                _S1692 = false;
            }
            bool is_inside_7;
            if(_S1692)
            {
                bool _S1693 = !is_inside_6;
                is_inside_7 = _S1693;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            FKSurface _S1694 = surface_12;
            bool _S1695 = boundsVolume_0(&_S1694);
            bool _S1696;
            if(_S1695)
            {
                _S1696 = !_S1571;
            }
            else
            {
                _S1696 = false;
            }
            if(_S1696)
            {
                FKSurface faced_2 = surface_12;
                float3  _S1697 = - _S1682.geometry_n;
                float3  _S1698 = _slang_select(turned_1, _S1697,_S1682.geometry_n);
                (&faced_2)->geometry_n = _S1698;
                FKMedium _S1699 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1700 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1701 = faced_2;
                FKMedium _S1702 = _S1699;
                FKMedium _S1703 = _S1700;
                MediumSides _S1704 = mediumSides_0(&_S1701, &_S1702, filling_2, (&ray_2)->unit_direction, &_S1703);
                bool _S1705 = ((dot_0(throughput_9, _S1682.geometry_n)) > 0.0f) == ((dot_0(_S1682.geometry_n, (&faced_2)->geometry_n)) > 0.0f);
                float3  _S1706 = _slang_select(_S1705, _S1704.front.scatter,_S1704.behind.scatter);
                scatter_in_0 = _S1706;
                float3  _S1707 = _slang_select(_S1705, _S1704.front.extinction,_S1704.behind.extinction);
                extinction_in_0 = _S1707;
                float _S1708 = _slang_select(_S1705, _S1704.front.g,_S1704.behind.g);
                g_in_0 = _S1708;
                uint _S1709 = _S1704.fillings.x;
                uint _S1710 = _S1704.fillings.y;
                uint _S1711 = _slang_select(_S1705, _S1710,_S1709);
                bool _S1712 = (fcptVaryingUsed());
                uint _S1713 = _slang_select(_S1712, _S1711,4294967295U);
                filling_2 = _S1713;
            }
            (&ray_2)->unit_direction = throughput_9;
            bool _S1714 = !_S1571;
            if(_S1714)
            {
                FKSurface _S1715 = surface_12;
                float _S1716 = _slang_select(straight_0, 0.0f,_S1715.geometry_offset);
                float3  _S1717 = - _S1408.smooth_n;
                bool _S1718 = is_inside_7 != _S1566;
                float3  _S1719 = _slang_select(_S1718, _S1717,_S1408.smooth_n);
                float3  _S1720 = (&ray_2)->origin + make_float3 (_S1716) * _S1719;
                (&ray_2)->origin = _S1720;
            }
            throughput_10 = throughput_11;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1571;
            viewed_1 = _S1564;
            sky_pdf_2 = _S1687;
            spread_4 = _S1691;
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
            spread_4 = spread_1;
            straight_0 = false;
            is_inside_5 = is_inside_6;
        }
        float density_7;
        if(_S1440)
        {
            if(_S1374)
            {
                float3  _S1721 = throughput_10 * emission_1;
                Reservoir candidate_8 = chain_0;
                uint _S1722 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1723 = _S1722 == 1U;
                if(_S1723)
                {
                    float3  _S1724 = safeDivide(_S1721, chain_throughput_0);
                    (&candidate_8)->radiance = _S1724;
                }
                Reservoir _S1725 = withEnd(candidate_8, 2U, b_6, _S1721);
                offer(sel_7, _S1725, _S1721 * make_float3 (scale_3) / make_float3 (density_6));
            }
            if(_S1374)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1726 = survivalProbability(abs_0(throughput_10), density_6);
                density_7 = _S1726;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1727 = stream(_S1260, b_6 + 128U);
            Random _S1728 = pcg(_S1727);
            bool _S1729 = density_7 < (_S1728.value);
            if(_S1729)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1730 = (fcptMaxBounces());
                wrong_side_0 = b_6 >= _S1730;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1731 = density_6 * density_7;
            density_7 = _S1731;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1732 = layer_0 ^ 1U;
        uint _S1733 = _slang_select(passes_0, _S1732,0U);
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
            uint _S1734 = b_9 + 1U;
            b_6 = _S1734;
            layer_0 = _S1733;
            continue;
        }
        FKRay _S1735 = ray_2;
        float _S1736 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_1)
        {
            refracted_4 = _S1467;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S1237 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1737 = _slang_select(wrong_side_0, _S1736,4.294967296e+09f);
        bool _S1738 = !_S1431;
        if(straight_0)
        {
            _S1512 = true;
        }
        else
        {
            _S1512 = _S1431;
        }
        FKHit _S1739;
        if(_S1512)
        {
            _S1739 = hit_4;
        }
        else
        {
            _S1739 = _S1484;
        }
        FKHit _S1740 = (fcptTraverseInstanceBVH((_S1735), (_S1381), (_S1737), (_S1738), (_S1739), (viewed_1)));
        hit_4 = _S1740;
        if(replay_1)
        {
            _S1513 = _S1467;
        }
        else
        {
            _S1513 = false;
        }
        if(_S1513)
        {
            _S1559 = _S1237 == 1U;
        }
        else
        {
            _S1559 = false;
        }
        if(_S1559)
        {
            _S1560 = ((&hit_4)->instance_index) == (_S1249.instance_index);
        }
        else
        {
            _S1560 = false;
        }
        if(_S1560)
        {
            _S1561 = ((&hit_4)->triangle_index) == (_S1249.triangle_index);
        }
        else
        {
            _S1561 = false;
        }
        if(_S1561)
        {
            (&hit_4)->uv = _S1249.uv;
            float _S1741 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S1741;
        }
        if(replay_1)
        {
            _S1562 = _S1467;
        }
        else
        {
            _S1562 = false;
        }
        if(_S1562)
        {
            _S1563 = _S1237 == 3U;
        }
        else
        {
            _S1563 = false;
        }
        if(_S1563)
        {
            _S1564 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1564 = false;
        }
        if(_S1564)
        {
            return _S1233;
        }
        Reservoir _S1742 = chain_0;
        uint _S1743 = filling_2;
        for(;;)
        {
            bool _S1744 = (fcptVaryingUsed());
            if(_S1744)
            {
                _S1565 = _S1743 != 4294967295U;
            }
            else
            {
                _S1565 = false;
            }
            float _S1745;
            if(_S1565)
            {
                float _S1746 = (fcptMajorant((_S1743)));
                _S1745 = _S1746;
            }
            else
            {
                _S1745 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_1)
            {
                _S1566 = _S1467;
            }
            else
            {
                _S1566 = false;
            }
            if(_S1566)
            {
                _S1567 = _S1237 == 1U;
            }
            else
            {
                _S1567 = false;
            }
            if(_S1567)
            {
                _S1568 = _S1745 > 0.0f;
            }
            else
            {
                _S1568 = false;
            }
            if(_S1568)
            {
                ended_0 = _S1233;
                sky_pdf_1 = sky_pdf_2;
                spread_2 = spread_4;
                width_4 = width_3;
                density_3 = density_7;
                throughput_11 = throughput_10;
                b_9 = b_6;
                _S1569 = true;
                break;
            }
            bool _S1747 = (&prev_0)->rough;
            if(_S1747)
            {
                _S1569 = !(_S1745 > 0.0f);
            }
            else
            {
                _S1569 = false;
            }
            (&prev_0)->rough = _S1569;
            uint _S1748 = b_6 + 320U;
            bool _S1749 = b_6 == 4294967295U;
            uint _S1750 = _slang_select(_S1749, 384U,_S1748);
            uint _S1751 = stream(_S1260, _S1750);
            uint tracking_1 = _S1751;
            weight_1 = throughput_3;
            glowed_0 = _S1232;
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
                    _S1231 = int(2);
                    break;
                }
                uint _S1752 = b_9 + 320U;
                bool _S1753 = b_9 == 4294967295U;
                uint _S1754 = _slang_select(_S1753, 384U,_S1752);
                uint _S1755 = stream(_S1260, _S1754);
                Random _S1756 = pcg(_S1755);
                float _S1757 = - (F32_log((1.0f - _S1756.value))) / _S1745;
                if(_S1565)
                {
                    float3  _S1758 = (&ray_2)->origin;
                    float3  _S1759 = (&ray_2)->unit_direction;
                    float _S1760 = (&hit_4)->distance;
                    uint _S1761 = _slang_select(_S1753, 0U,b_9);
                    uint _S1762 = (&prev_0)->lobe;
                    uint _S1763 = _slang_select(_S1753, 3U,_S1762);
                    float _S1764 = (fcptTrackMedium((_S1743), (_S1758), (_S1759), (_S1760), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1761), (_S1763), (_S1753)));
                    spread_3 = _S1764;
                }
                else
                {
                    spread_3 = _S1757;
                }
                bool _S1765 = !(spread_3 < ((&hit_4)->distance));
                if(_S1765)
                {
                    _S1231 = int(2);
                    break;
                }
                if(_S1565)
                {
                    _S1570 = _S1440;
                }
                else
                {
                    _S1570 = false;
                }
                if(_S1570)
                {
                    float3  _S1766 = throughput_11 * glowed_0 / make_float3 (density_3);
                    float3  _S1767 = sel_7->glow + _S1766;
                    sel_7->glow = _S1767;
                }
                else
                {
                }
                glowed_0 = _S1232;
                uint b_10 = b_9 + 1U;
                float3  _S1768 = (&ray_2)->origin + make_float3 (spread_3) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1768;
                float3  _S1769 = flightWeight_0(scatter_in_0, extinction_in_0, _S1745, spread_3, true);
                float3  _S1770 = weight_1;
                float3  _S1771 = _slang_select(_S1565, _S1770,_S1769);
                float3  throughput_12 = throughput_11 * _S1771;
                uint _S1772 = stream(_S1260, b_10 + 320U);
                tracking_1 = _S1772;
                weight_1 = throughput_3;
                float width_7 = width_4 + spread_2 * spread_3;
                float _S1773 = spread_2 + 3.14159274101257324f;
                if(_S1440)
                {
                    _S1571 = true;
                }
                else
                {
                    bool _S1774 = b_10 == _S1248;
                    if(_S1774)
                    {
                        _S1571 = !_S1565;
                    }
                    else
                    {
                        _S1571 = false;
                    }
                }
                TreeSample light_4;
                if(_S1571)
                {
                    float3  _S1775 = (&ray_2)->origin;
                    float3  _S1776 = (&ray_2)->unit_direction;
                    float3  _S1777 = (&ray_2)->unit_direction;
                    uint _S1778 = stream(_S1260, b_10 + 64U);
                    float3  _S1779 = extinction_in_0;
                    float3  _S1780 = extinction_in_0;
                    uint2  _S1781 = make_uint2 (_S1743);
                    float3  _S1782 = (&ray_2)->unit_direction;
                    uint _S1783 = arrivalLobe_0(b_10, (&prev_0)->lobe);
                    FKHit _S1784 = _S1484;
                    ShadowContext _S1785 = ShadowContext_x24init_0(_S1779, _S1780, _S1781, _S1782, b_10, _S1783, false, spread_3, width_7, &_S1784, false);
                    ShadowContext _S1786 = _S1785;
                    TreeSample _S1787 = sampleLightTree_0(_S1775, _S1776, _S1777, 0.0f, true, _S1778, &_S1786);
                    light_4 = _S1787;
                }
                else
                {
                    light_4 = _S1481;
                }
                float _S1788 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1789 = (fcptMaxBounces());
                bool _S1790 = b_10 < _S1789;
                if(_S1790)
                {
                    _S1572 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1572 = false;
                }
                float _S1791 = _slang_select(_S1572, _S1788,0.0f);
                float3  _S1792 = throughput_12 * light_4.radiance;
                float _S1793 = powerHeuristic(light_4.density, _S1791);
                float3  _S1794 = _S1792 * make_float3 (_S1788 * _S1793);
                float3  _S1795 = _slang_select(_S1571, _S1794,_S1232);
                if(replay_1)
                {
                    _S1573 = b_10 == _S1248;
                }
                else
                {
                    _S1573 = false;
                }
                if(_S1573)
                {
                    bool _S1796 = _S1237 == 2U;
                    if(_S1796)
                    {
                        float _S1797 = resamplingTarget(_S1795);
                        _S1574 = _S1797 > 0.0f;
                    }
                    else
                    {
                        _S1574 = false;
                    }
                    if(_S1574)
                    {
                        Shift _S1798 = Shift_x24init_0(_S1795, 1.0f);
                        _S1231 = int(1);
                        ended_0 = _S1798;
                        spread_3 = _S1773;
                        width_5 = width_7;
                        throughput_9 = throughput_12;
                        b_7 = b_10;
                        break;
                    }
                    _S1231 = int(1);
                    ended_0 = _S1233;
                    spread_3 = _S1773;
                    width_5 = width_7;
                    throughput_9 = throughput_12;
                    b_7 = b_10;
                    break;
                }
                if(_S1440)
                {
                    Reservoir candidate_9 = _S1742;
                    uint _S1799 = extractBits_0(_S1742.path, 10U, 2U);
                    bool _S1800 = _S1799 == 1U;
                    if(_S1800)
                    {
                        float3  _S1801 = safeDivide(_S1795, chain_throughput_0);
                        (&candidate_9)->radiance = _S1801;
                    }
                    else
                    {
                        uint _S1802 = insertBits_0(0U, b_10 + 1U, 5U, 5U);
                        uint _S1803 = insertBits_0(_S1802, 2U, 10U, 2U);
                        (&candidate_9)->path = _S1803;
                    }
                    Reservoir _S1804 = withEnd(candidate_9, 0U, b_10, _S1795);
                    offer(sel_7, _S1804, _S1795 * make_float3 (scale_3) / make_float3 (density_3));
                    float _S1805 = survivalProbability(abs_0(throughput_12), density_3);
                    uint _S1806 = stream(_S1260, b_10 + 128U);
                    Random _S1807 = pcg(_S1806);
                    bool _S1808 = _S1805 < (_S1807.value);
                    if(_S1808)
                    {
                        _S1574 = true;
                    }
                    else
                    {
                        uint _S1809 = (fcptMaxBounces());
                        _S1574 = b_10 >= _S1809;
                    }
                    if(_S1574)
                    {
                        _S1231 = int(1);
                        ended_0 = _S1233;
                        spread_3 = _S1773;
                        width_5 = width_7;
                        throughput_9 = throughput_12;
                        b_7 = b_10;
                        break;
                    }
                    float _S1810 = density_3 * _S1805;
                    density_3 = _S1810;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1811 = stream(_S1260, b_10);
                float3  _S1812 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1811, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1812;
                NEEVertex _S1813 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1232, (&ray_2)->origin);
                nee_vertex_0 = _S1813;
                Vertex _S1814 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_5);
                prev_0 = _S1814;
                float _S1815 = (&prev_0)->pdf;
                FKRay _S1816 = ray_2;
                FKHit _S1817 = (fcptTraverseInstanceBVH((_S1816), (true), (4.294967296e+09f), (false), (_S1484), (false)));
                hit_4 = _S1817;
                b_9 = b_10;
                throughput_11 = throughput_12;
                spread_2 = _S1773;
                width_4 = width_7;
                sky_pdf_1 = _S1815;
            }
            if(_S1231 != int(2))
            {
                spread_2 = spread_3;
                width_4 = width_5;
                throughput_11 = throughput_9;
                b_9 = b_7;
                _S1569 = true;
                break;
            }
            ended_0 = _S1233;
            _S1569 = false;
            break;
        }
        if(_S1569)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1570 = b_9 == b_6;
        }
        else
        {
            _S1570 = false;
        }
        bool _S1818 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S1818)
        {
            bool _S1819 = !(&nee_vertex_0)->none;
            float _S1820 = _slang_select(_S1819, sky_pdf_1,0.0f);
            float _S1821 = escapeWeight_0(_S1820, (&ray_2)->unit_direction);
            float3  _S1822 = environment_0((&ray_2)->unit_direction, b_9, (&prev_0)->lobe);
            float3  _S1823 = throughput_11 * _S1822;
            if(replay_1)
            {
                bool _S1824 = b_9 == _S1248;
                if(_S1824)
                {
                    passes_0 = _S1237 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1823 * make_float3 (_S1821) / make_float3 (r_8->jac), density_3 / r_8->jac);
                }
                if(_S1247)
                {
                    passes_0 = _S1244;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_9 == _S1235;
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
                    return Shift_x24init_0(_S1823 * make_float3 (_S1821), 1.0f);
                }
                return _S1233;
            }
            Reservoir candidate_10 = chain_0;
            uint _S1825 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1826 = _S1825 == 1U;
            if(_S1826)
            {
                uint _S1827 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1828 = _S1827 == b_9;
                float _S1829 = _slang_select(_S1828, 1.0f,_S1821);
                float3  _S1830 = safeDivide(_S1823 * make_float3 (_S1829), chain_throughput_0);
                (&candidate_10)->radiance = _S1830;
            }
            else
            {
                bool _S1831 = (&prev_0)->rough;
                if(_S1831)
                {
                    uint _S1832 = insertBits_0(0U, b_9 + 1U, 5U, 5U);
                    uint _S1833 = insertBits_0(_S1832, 3U, 10U, 2U);
                    uint _S1834 = insertBits_0(_S1833, (&prev_0)->lobe, 15U, 3U);
                    bool _S1835 = (&prev_0)->inside;
                    uint _S1836 = _slang_select(_S1835, 1U,0U);
                    uint _S1837 = insertBits_0(_S1834, _S1836, 22U, 1U);
                    (&candidate_10)->path = _S1837;
                    (&candidate_10)->jac = (&prev_0)->pdf;
                    (&candidate_10)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1838 = _S1823 * make_float3 (_S1821);
            Reservoir _S1839 = withEnd(candidate_10, 3U, b_9, _S1838);
            offer(sel_7, _S1839, _S1838 * make_float3 (scale_3) / make_float3 (density_3));
            break;
        }
        float3  _S1840 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1840;
        bool _S1841 = (fcptVaryingUsed());
        if(_S1841)
        {
            _S1571 = filling_2 != 4294967295U;
        }
        else
        {
            _S1571 = false;
        }
        if(_S1571)
        {
            if(_S1440)
            {
                float3  _S1842 = throughput_11 * glowed_0 / make_float3 (density_3);
                float3  _S1843 = sel_7->glow + _S1842;
                sel_7->glow = _S1843;
            }
            float3  _S1844 = throughput_11 * weight_1;
            throughput_9 = _S1844;
        }
        else
        {
            float3  _S1845 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S1846 = throughput_11 * _S1845;
            throughput_9 = _S1846;
        }
        float _S1847 = width_4 + spread_2 * (&hit_4)->distance;
        viewed_0 = _S1570;
        width_3 = _S1847;
        throughput_2 = throughput_9;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_1 = spread_2;
        uint _S1734 = b_9 + 1U;
        b_6 = _S1734;
        layer_0 = _S1733;
    }
    return _S1233;
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

__device__ Random normal_distribution(uint state_3)
{
    Random _S1848 = pcg(state_3);
    Random _S1849 = pcg(_S1848.state);
    float _S1850 = 6.28318548202514648f * _S1848.value;
    float _S1851 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S1849.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1849.state, _S1851 * (F32_cos((_S1850))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_4, float3  value_2)
{
    RandomSphere _S1852;
    (&_S1852)->state = state_4;
    (&_S1852)->value = value_2;
    return _S1852;
}

__device__ RandomSphere random_sphere(uint state_5)
{
    Random _S1853 = normal_distribution(state_5);
    Random _S1854 = normal_distribution(_S1853.state);
    Random _S1855 = normal_distribution(_S1854.state);
    float3  _S1856 = make_float3 (_S1853.value, _S1854.value, _S1855.value);
    float3  _S1857 = ((((_S1856)) * make_float3(rnorm3df(((_S1856)).x, ((_S1856)).y, ((_S1856)).z))));
    return RandomSphere_x24init_0(_S1855.state, _S1857);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_11)
{
    float3  _S1858 = p1_0 - p0_0;
    float3  _S1859 = p2_0 - p0_0;
    float2  _S1860 = uv1_0 - uv0_0;
    float2  _S1861 = uv2_0 - uv0_0;
    float _S1862 = _S1860.x;
    float _S1863 = _S1861.y;
    float _S1864 = _S1860.y;
    float _S1865 = _S1861.x;
    float _S1866 = _S1862 * _S1863 - _S1864 * _S1865;
    float _S1867 = 1.0f / _S1866;
    float3  t_24 = (_S1858 * make_float3 (_S1863) - _S1859 * make_float3 (_S1864)) * make_float3 (_S1867);
    float3  _S1868 = (_S1859 * make_float3 (_S1862) - _S1858 * make_float3 (_S1865)) * make_float3 (_S1867);
    float3  _S1869 = t_24 - n_11 * make_float3 (dot_0(n_11, t_24));
    float3  _S1870 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_11);
    bool _S1871 = (dot_0(_S1869, _S1869)) > 0.0f;
    float3  _S1872 = _slang_select(_S1871, _S1869,_S1870);
    float3  _S1873 = ((((_S1872)) * make_float3(rnorm3df(((_S1872)).x, ((_S1872)).y, ((_S1872)).z))));
    bool _S1874 = (dot_0(cross_0(n_11, _S1873), _S1868)) > 0.0f;
    float3  t_25;
    if(_S1874)
    {
        float3  _S1875 = negate_0(_S1873);
        t_25 = _S1875;
    }
    else
    {
        t_25 = _S1873;
    }
    float3  _S1876 = cross_0(n_11, t_25);
    return makeMatrix<float, 3, 3> (t_25, _S1876, n_11);
}

__device__ float3  tangentToWorldNormalMap(float3  v_10, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_10, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_4, float3  uvw_0, float3  position_0)
{
    float3  _S1877 = t1_0 - t0_0;
    float3  _S1878 = t2_2 - t0_0;
    float3  _S1879 = t2_2 - t1_0;
    float _S1880 = (F32_min((length_0(_S1877)), ((F32_min((length_0(_S1878)), (length_0(_S1879)))))));
    float3  _S1881 = make_float3 (distance_1(position_0, t0_0), distance_1(position_0, t1_0), distance_1(position_0, t2_2));
    float3  _S1882 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1883 = dot_0(geometry_n_4, _S1882);
    float3  _S1884 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1885 = dot_0(geometry_n_4, _S1884);
    float3  _S1886 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1887 = acos_0(abs_0(make_float3 (_S1883, _S1885, dot_0(geometry_n_4, _S1886))));
    float3  _S1888 = clamp_2(tan_0(_S1887), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S1881 * _S1888, uvw_0), 0.0f, _S1880 * 0.125f);
}

__device__ float3  straightThrough(BSDFMaterial material_21)
{
    return make_float3 (material_21.transmission * (1.0f - material_21.metallic)) * material_21.albedo;
}

__device__ float hairRow(float3  in_dir_10, float3  t_26, float3  out_dir_3, uint p_14, float w_19, float alpha_10, uint nt_0)
{
    uint _S1889 = p_14 % 4U;
    float _S1890 = w_19 * HAIR_WIDTHS_0[_S1889];
    float _S1891 = (F32_asin((clamp_1(dot_0(out_dir_3, t_26), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_10, t_26), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1889] * alpha_10;
    return ((F32_asinh((_S1891 / _S1890))) / (F32_asinh((3.14159274101257324f / _S1890))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_11, float3  t_27, float3  out_dir_4, uint np_0)
{
    float3  _S1892 = worldToTangent(out_dir_4, t_27);
    float3  _S1893 = worldToTangent(in_dir_11, t_27);
    return (F32_frac((((F32_atan2((_S1892.z), (_S1892.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1893.z), (1.17549435082228751e-38f - _S1893.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_12, float3  t_28, uint p_15, float row_0, float column_0, float w_20, float alpha_11, uint nt_1, uint np_1)
{
    float3  _S1894 = worldToTangent(in_dir_12, t_28);
    uint _S1895 = p_15 % 4U;
    float _S1896 = w_20 * HAIR_WIDTHS_0[_S1895];
    float _S1897 = (F32_asin((clamp_1(dot_0(in_dir_12, t_28), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1895] * alpha_11 + _S1896 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1896))))));
    float _S1898 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1894.z), (1.17549435082228751e-38f - _S1894.x)));
    float _S1899 = (F32_cos((_S1897)));
    float3  _S1900 = tangentToWorld(make_float3 (_S1899 * (F32_cos((_S1898))), (F32_sin((_S1897))), _S1899 * (F32_sin((_S1898)))), t_28);
    return _S1900;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_12, BSDFMaterial material_22, float coverage_1)
{
    float3  _S1901;
    if((material_22.ior) == 1.0f)
    {
        float3  _S1902 = straightThrough(material_22);
        _S1901 = _S1902;
    }
    else
    {
        _S1901 = make_float3 (0.0f);
    }
    return _S1901 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_8, Reservoir r_9, bool replay_2, float scale_4, Selection * sel_8)
{
    Domain _S1903 = dom_8;
    Reservoir _S1904 = r_9;
    Shift _S1905 = walk_0(&_S1903, &_S1904, replay_2, scale_4, sel_8);
    return _S1905;
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
