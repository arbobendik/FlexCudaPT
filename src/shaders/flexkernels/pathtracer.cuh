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

__device__ __forceinline__ MaterialTerms precomputeMaterial(BSDFMaterial material_1, float eta_i_0, float eta_o_0)
{
    float _S316 = (F32_min(((F32_sqrt((material_1.specular_level))) * (F32_abs((eta_i_0 - eta_o_0))) / (eta_i_0 + eta_o_0)), (0.9999847412109375f)));
    float _S317 = _S316 * _S316;
    float _S318 = (1.0f + _S316) / (1.0f - _S316);
    float3  _S319 = make_float3 (0.0f);
    float _S320 = material_1.toon.x;
    bool _S321 = _S320 < 0.0f;
    float _S322 = (F32_abs((_S320)));
    bool _S323 = _S322 > 0.0f;
    float toon_scale_1;
    float toon_component_1;
    float toon_a_1;
    float toon_s_1;
    float toon_b_1;
    float toon_norm_1;
    float3  toon_1;
    if(_S323)
    {
        float _S324 = (F32_min((_S322), (1.0f)));
        float _S325 = 1.0f - _S324;
        float _S326 = rgb_to_greyscale(material_1.albedo);
        float _S327 = _S324 * _S326;
        float3  _S328 = make_float3 (_S324) * material_1.albedo;
        float toon_a_2 = clamp_1(material_1.toon.y / _S320, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
        float toon_s_2 = clamp_1(material_1.toon.z / _S320, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
        float _S329 = (F32_min((toon_a_2 + toon_s_2), (1.57079637050628662f)));
        if(_S321)
        {
            toon_scale_1 = 1.0f - (F32_cos(((F32_min((_S329), (toon_a_2))))));
        }
        else
        {
            float _S330 = (F32_sin(((F32_min((_S329), (toon_a_2))))));
            toon_scale_1 = _S330 * _S330 / 2.0f;
        }
        bool _S331 = _S329 > toon_a_2;
        bool _S332;
        if(_S331)
        {
            _S332 = toon_s_2 > 0.0f;
        }
        else
        {
            _S332 = false;
        }
        if(_S332)
        {
            if(_S321)
            {
                float _S333 = (F32_cos((toon_a_2)));
                float _S334 = (F32_cos((_S329)));
                toon_component_1 = (1.0f + toon_a_2 / toon_s_2) * (_S333 - _S334) - ((F32_sin((_S329))) - _S329 * _S334 - ((F32_sin((toon_a_2))) - toon_a_2 * _S333)) / toon_s_2;
            }
            else
            {
                float _S335 = 2.0f * toon_a_2;
                float _S336 = (F32_cos((_S335)));
                float _S337 = 2.0f * _S329;
                float _S338 = (F32_cos((_S337)));
                toon_component_1 = (1.0f + toon_a_2 / toon_s_2) * (_S336 - _S338) / 4.0f - ((F32_sin((_S337))) / 8.0f - _S329 * _S338 / 4.0f - ((F32_sin((_S335))) / 8.0f - toon_a_2 * _S336 / 4.0f)) / toon_s_2;
            }
            float integral_0 = toon_scale_1 + toon_component_1;
            toon_scale_1 = integral_0;
        }
        float _S339 = 6.28318548202514648f * toon_scale_1;
        toon_scale_1 = _S325;
        toon_component_1 = _S327;
        toon_1 = _S328;
        toon_a_1 = toon_a_2;
        toon_s_1 = toon_s_2;
        toon_b_1 = _S329;
        toon_norm_1 = _S339;
    }
    else
    {
        toon_scale_1 = 1.0f;
        toon_component_1 = 0.0f;
        toon_1 = _S319;
        toon_a_1 = 0.0f;
        toon_s_1 = 0.0f;
        toon_b_1 = 0.0f;
        toon_norm_1 = 1.0f;
    }
    float _S340 = translucentShare(material_1);
    return MaterialTerms_x24init_0(_S317, _S318, _S340, toon_scale_1, toon_component_1, toon_1, toon_a_1, toon_s_1, toon_b_1, _S321, toon_norm_1);
}

struct AnisotropicFrame
{
    float3  tangent;
    float2  alphas;
};

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

static __device__ float3  negate_0(float3  x_13)
{
    return - x_13;
}

static __device__ float sign_0(float e_1)
{
    float _S341;
    if(e_1 > 0.0f)
    {
        _S341 = 1.0f;
    }
    else
    {
        if(e_1 < 0.0f)
        {
            _S341 = -1.0f;
        }
        else
        {
            _S341 = 0.0f;
        }
    }
    return _S341;
}

static __device__ AnisotropicFrame AnisotropicFrame_x24init_0(float3  tangent_0, float2  alphas_0)
{
    AnisotropicFrame _S342;
    (&_S342)->tangent = tangent_0;
    (&_S342)->alphas = alphas_0;
    return _S342;
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_1)
{
    float3  a_1 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S343 = (F32_abs((dot_0(n_1, a_1)))) > 0.9999847412109375f;
    float3  a_2;
    if(_S343)
    {
        float3  _S344 = make_float3 (1.0f, 0.0f, 0.0f);
        a_2 = _S344;
    }
    else
    {
        a_2 = a_1;
    }
    float3  _S345 = cross_0(n_1, a_2);
    float3  _S346 = ((((_S345)) * make_float3(rnorm3df(((_S345)).x, ((_S345)).y, ((_S345)).z))));
    float3  _S347 = cross_0(n_1, _S346);
    return make_float3 (v_0.x) * _S346 + make_float3 (v_0.y) * n_1 + make_float3 (v_0.z) * _S347;
}

__device__ AnisotropicFrame anisotropicFrame(BSDFMaterial material_2, float3  n_i_0)
{
    float _S348 = material_2.roughness;
    float _S349 = _S348 * _S348;
    bool _S350 = (material_2.anisotropy) == 0.0f;
    bool _S351;
    if(_S350)
    {
        _S351 = true;
    }
    else
    {
        _S351 = !(_S349 > 0.0f);
    }
    if(_S351)
    {
        return AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f));
    }
    float3  _S352 = material_2.tangent - n_i_0 * make_float3 (dot_0(n_i_0, material_2.tangent));
    float3  _S353 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_i_0);
    bool _S354 = (dot_0(_S352, _S352)) > 0.0f;
    float3  _S355 = _slang_select(_S354, _S352,_S353);
    float3  _S356 = ((((_S355)) * make_float3(rnorm3df(((_S355)).x, ((_S355)).y, ((_S355)).z))));
    float _S357 = 6.28318548202514648f * material_2.anisotropic_rotation;
    float _S358 = (F32_sqrt((1.0f - 0.89999997615814209f * (F32_abs((material_2.anisotropy))))));
    float _S359 = 1.0f / _S358;
    bool _S360 = (material_2.anisotropy) < 0.0f;
    float _S361 = _slang_select(_S360, _S359,_S358);
    return AnisotropicFrame_x24init_0(_S356 * make_float3 ((F32_cos((_S357)))) + cross_0(n_i_0, _S356) * make_float3 ((F32_sin((_S357)))), make_float2 (_S349 / _S361, _S349 * _S361));
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

static __device__ ViewTerms ViewTerms_x24init_0(float3  v_1, float3  n_i_1, AnisotropicFrame * frame_0, float3  scale_1, float sheen_component_0, float3  sheen_0, float3  view_0, float3  rebounce_0, float toon_view_0, float3  toon_axis_0)
{
    ViewTerms _S362;
    (&_S362)->v = v_1;
    (&_S362)->n_i = n_i_1;
    (&_S362)->frame = *frame_0;
    (&_S362)->scale = scale_1;
    (&_S362)->sheen_component = sheen_component_0;
    (&_S362)->sheen = sheen_0;
    (&_S362)->view = view_0;
    (&_S362)->rebounce = rebounce_0;
    (&_S362)->toon_view = toon_view_0;
    (&_S362)->toon_axis = toon_axis_0;
    return _S362;
}

__device__ __forceinline__ ViewTerms precomputeView(float3  in_dir_0, float3  n_2, BSDFMaterial material_3, MaterialTerms terms_0)
{
    float3  _S363 = negate_0(in_dir_0);
    float _S364 = sign_0(dot_0(n_2, _S363));
    float3  _S365 = n_2 * make_float3 (_S364);
    AnisotropicFrame _S366 = anisotropicFrame(material_3, _S365);
    float3  _S367 = make_float3 (1.0f);
    float3  _S368 = make_float3 (0.0f);
    float _S369 = rgb_to_greyscale(material_3.sheen);
    bool _S370 = _S369 > 0.0f;
    float sheen_component_1;
    float3  sheen_1;
    float3  view_1;
    float3  scale_2;
    if(_S370)
    {
        float _S371 = clamp_1((F32_sqrt(((F32_max((dot_0(_S365, _S363)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S372 = (U32_min((uint(_S371)), (22U)));
        float least_0 = (F32_sqrt((0.05000000074505806f)));
        float _S373 = (F32_sqrt((0.10000000149011612f)));
        bool _S374 = (material_3.velvet) > 0.0f;
        float _S375 = _slang_select(_S374, _S373,least_0);
        float _S376 = (clamp_1((F32_sqrt(((F32_max((material_3.sheen_roughness), (0.0f)))))), _S375, 1.0f) - _S375) / (1.0f - _S375) * 23.0f;
        uint _S377 = (U32_min((uint(_S376)), (22U)));
        uint _S378 = _S372 * 24U + _S377;
        float _S379 = _S371 - float(_S372);
        float _S380 = _S376 - float(_S377);
        uint _S381 = _S378 + 24U;
        float a_3 = SHEEN_ALBEDO_0[_S378] + (SHEEN_ALBEDO_0[_S381] - SHEEN_ALBEDO_0[_S378]) * _S379;
        uint _S382 = _S378 + 1U;
        uint _S383 = _S381 + 1U;
        float b_1 = SHEEN_ALBEDO_0[_S382] + (SHEEN_ALBEDO_0[_S383] - SHEEN_ALBEDO_0[_S382]) * _S379;
        float _S384 = (F32_exp((a_3 + (b_1 - a_3) * _S380)));
        if(_S374)
        {
            float a_4 = VELVET_ALBEDO_0[_S378] + (VELVET_ALBEDO_0[_S381] - VELVET_ALBEDO_0[_S378]) * _S379;
            float b_2 = VELVET_ALBEDO_0[_S382] + (VELVET_ALBEDO_0[_S383] - VELVET_ALBEDO_0[_S382]) * _S379;
            float _S385 = a_4 + (b_2 - a_4) * _S380;
            sheen_component_1 = _S385;
        }
        else
        {
            sheen_component_1 = _S384;
        }
        float _S386 = (F32_min((sheen_component_1), (1.0f)));
        float3  _S387 = make_float3 (1.0f) - material_3.sheen * make_float3 (_S386);
        float _S388 = rgb_to_greyscale(material_3.sheen);
        float _S389 = _S388 * _S386;
        float3  _S390 = material_3.sheen / make_float3 ((F32_max((sheen_component_1), (1.0f))));
        sheen_component_1 = _S389;
        sheen_1 = _S390;
        view_1 = _S363;
        scale_2 = _S387;
    }
    else
    {
        sheen_component_1 = 0.0f;
        sheen_1 = _S368;
        view_1 = _S368;
        scale_2 = _S367;
    }
    float3  scale_3 = scale_2 * make_float3 (terms_0.toon_scale);
    bool _S391 = (F32_abs((material_3.toon.x))) > 0.0f;
    float toon_view_1;
    float3  toon_axis_1;
    if(_S391)
    {
        float _S392 = dot_0(_S365, _S363);
        float _S393 = (F32_acos(((F32_min((_S392), (1.0f))))));
        if(_S393 < (terms_0.toon_a))
        {
            toon_view_1 = 1.0f;
        }
        else
        {
            toon_view_1 = (F32_max((1.0f - (_S393 - terms_0.toon_a) / (F32_max((terms_0.toon_s), (0.0000152587890625f)))), (0.0f)));
        }
        if(terms_0.toon_glossy)
        {
            float3  _S394 = make_float3 (2.0f * _S392) * _S365 - _S363;
            float3  _S395 = ((((_S394)) * make_float3(rnorm3df(((_S394)).x, ((_S394)).y, ((_S394)).z))));
            scale_2 = _S395;
        }
        else
        {
            scale_2 = _S365;
        }
        toon_axis_1 = scale_2;
    }
    else
    {
        toon_view_1 = 0.0f;
        toon_axis_1 = _S365;
    }
    float _S396 = _S366.alphas.x;
    float _S397 = (F32_sqrt(((F32_min((_S396), (_S366.alphas.y))))));
    bool _S398 = _S396 > 0.0f;
    float _S399 = _slang_select(_S398, _S397,material_3.roughness);
    float _S400 = _S399 * _S399;
    float _S401 = (F32_pow((_S400), (1.81585001945495605f))) * (2.15371990203857422f - 0.73285001516342163f * _S400) / (1.0f + 1.28094995021820068f * _S400);
    bool _S402 = _S400 > 0.0f;
    float _S403 = _slang_select(_S402, _S401,0.0f);
    float _S404 = clamp_1(dot_0(_S365, _S363), 0.0f, 1.0f);
    float _S405 = _S400 * _S399;
    float _S406 = (F32_min((1.00064504146575928f - _S399 * (0.00375499995425344f + _S404 * (-0.04133399948477745f + _S404 * (-0.90938502550125122f + _S404 * 0.35275399684906006f))) - _S400 * (0.27602800726890564f + _S404 * (1.27023398876190186f + _S404 * 0.04740000143647194f)) - _S405 * (0.31452900171279907f - _S404 * 0.34830701351165771f) + _S405 * _S399 * 0.27229699492454529f), (1.0f)));
    float3  _S407 = min_1(make_float3 (1.0f) / (make_float3 (1.0f) - material_3.albedo * make_float3 (_S403)), make_float3 (1.0f / (F32_max((_S406), (0.0000152587890625f)))));
    AnisotropicFrame _S408 = _S366;
    ViewTerms _S409 = ViewTerms_x24init_0(_S363, _S365, &_S408, scale_3, sheen_component_1, sheen_1, view_1, _S407, toon_view_1, toon_axis_1);
    return _S409;
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

static __device__ HalfTerms HalfTerms_x24init_0(float v_dot_h_0, float n_dot_h_0, float3  refracted_1, float3  F_0, float F_greyscale_0, float reflect_weight_0, float3  diffuse_weight_0, float3  refract_weight_0, float p_diffuse_0, float p_reflect_0, float p_refract_0, float translucent_share_1, float3  sheen_2, float p_sheen_velvet_0, float3  view_2, float3  tangent_1, float2  alphas_1, float visible_0, float p_toon_0, float3  toon_2, float toon_a_3, float toon_s_3, float toon_b_2, bool toon_glossy_1, float toon_norm_2, float toon_view_2, float3  toon_axis_2)
{
    HalfTerms _S410;
    (&_S410)->v_dot_h = v_dot_h_0;
    (&_S410)->n_dot_h = n_dot_h_0;
    (&_S410)->refracted = refracted_1;
    (&_S410)->F = F_0;
    (&_S410)->F_greyscale = F_greyscale_0;
    (&_S410)->reflect_weight = reflect_weight_0;
    (&_S410)->diffuse_weight = diffuse_weight_0;
    (&_S410)->refract_weight = refract_weight_0;
    (&_S410)->p_diffuse = p_diffuse_0;
    (&_S410)->p_reflect = p_reflect_0;
    (&_S410)->p_refract = p_refract_0;
    (&_S410)->translucent_share = translucent_share_1;
    (&_S410)->sheen = sheen_2;
    (&_S410)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S410)->view = view_2;
    (&_S410)->tangent = tangent_1;
    (&_S410)->alphas = alphas_1;
    (&_S410)->visible = visible_0;
    (&_S410)->p_toon = p_toon_0;
    (&_S410)->toon = toon_2;
    (&_S410)->toon_a = toon_a_3;
    (&_S410)->toon_s = toon_s_3;
    (&_S410)->toon_b = toon_b_2;
    (&_S410)->toon_glossy = toon_glossy_1;
    (&_S410)->toon_norm = toon_norm_2;
    (&_S410)->toon_view = toon_view_2;
    (&_S410)->toon_axis = toon_axis_2;
    return _S410;
}

__device__ float3  anisotropicLocal(float3  w_0, float3  t_12, float3  n_3)
{
    return make_float3 (dot_0(w_0, t_12), dot_0(w_0, cross_0(n_3, t_12)), dot_0(w_0, n_3));
}

static __device__ float unshared_0(float x_15)
{
    return x_15;
}

__device__ float3  sampleGGXVNDF(float3  Ve_0, float alpha_0, float U1_0, float U2_0)
{
    float3  _S411 = make_float3 (alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z);
    float3  _S412 = ((((_S411)) * make_float3(rnorm3df(((_S411)).x, ((_S411)).y, ((_S411)).z))));
    float _S413 = _S412.x;
    float _S414 = _S412.y;
    float _S415 = _S413 * _S413 + _S414 * _S414;
    float3  _S416;
    if(_S415 > 0.0f)
    {
        float3  _S417 = make_float3 (- _S414, _S413, 0.0f);
        float _S418 = (rsqrtf((_S415)));
        _S416 = _S417 * make_float3 (_S418);
    }
    else
    {
        _S416 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S419 = cross_0(_S412, _S416);
    float _S420 = (F32_sqrt((U1_0)));
    float _S421 = 6.28318548202514648f * U2_0;
    float _S422 = _S420 * (F32_cos((_S421)));
    float t2_0 = _S420 * (F32_sin((_S421)));
    float _S423 = 0.5f * (1.0f + _S412.z);
    float t2_1 = (1.0f - _S423) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S422 * _S422)))))) + _S423 * t2_0;
    float3  _S424 = make_float3 (_S422) * _S416 + make_float3 (t2_1) * _S419;
    float _S425 = unshared_0(_S422);
    float _S426 = unshared_0(_S422);
    float3  _S427 = _S424 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S425 * _S426 - t2_1 * t2_1))))))) * _S412;
    float3  _S428 = make_float3 (alpha_0 * _S427.x, alpha_0 * _S427.y, (F32_max((0.0f), (_S427.z))));
    float3  _S429 = ((((_S428)) * make_float3(rnorm3df(((_S428)).x, ((_S428)).y, ((_S428)).z))));
    return _S429;
}

__device__ float3  worldToTangent(float3  v_2, float3  n_4)
{
    float3  a_5 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S430 = (F32_abs((dot_0(n_4, a_5)))) > 0.9999847412109375f;
    float3  a_6;
    if(_S430)
    {
        float3  _S431 = make_float3 (1.0f, 0.0f, 0.0f);
        a_6 = _S431;
    }
    else
    {
        a_6 = a_5;
    }
    float3  _S432 = cross_0(n_4, a_6);
    float3  _S433 = ((((_S432)) * make_float3(rnorm3df(((_S432)).x, ((_S432)).y, ((_S432)).z))));
    float3  _S434 = cross_0(n_4, _S433);
    return make_float3 (dot_0(v_2, _S433), dot_0(v_2, n_4), dot_0(v_2, _S434));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_3, float3  n_i_2, float alpha_1, AnisotropicFrame frame_1, uint * random_state_2)
{
    Random _S435 = pcg(*random_state_2);
    Random _S436 = pcg(_S435.state);
    *random_state_2 = _S436.state;
    float _S437 = frame_1.alphas.x;
    bool _S438 = _S437 > 0.0f;
    if(_S438)
    {
        float3  _S439 = anisotropicLocal(v_3, frame_1.tangent, n_i_2);
        float _S440 = frame_1.alphas.y;
        float3  _S441 = make_float3 (_S437 * _S439.x, _S440 * _S439.y, _S439.z);
        float3  _S442 = ((((_S441)) * make_float3(rnorm3df(((_S441)).x, ((_S441)).y, ((_S441)).z))));
        float3  _S443 = sampleGGXVNDF(_S442, 1.0f, _S435.value, _S436.value);
        float3  _S444 = make_float3 (_S437 * _S443.x, _S440 * _S443.y, _S443.z);
        float3  _S445 = ((((_S444)) * make_float3(rnorm3df(((_S444)).x, ((_S444)).y, ((_S444)).z))));
        return make_float3 (_S445.x) * frame_1.tangent + make_float3 (_S445.y) * cross_0(n_i_2, frame_1.tangent) + make_float3 (_S445.z) * n_i_2;
    }
    float3  _S446 = worldToTangent(v_3, n_i_2);
    float3  _S447 = sampleGGXVNDF(float3 {_S446.x, _S446.z, _S446.y}, alpha_1, _S435.value, _S436.value);
    float3  _S448 = float3 {_S447.x, _S447.z, _S447.y};
    float3  _S449 = tangentToWorld(_S448, n_i_2);
    return _S449;
}

__device__ float3  sampledHalf(float3  in_dir_1, float3  n_5, BSDFMaterial material_4, uint random_state_3, ViewTerms view_terms_0)
{
    uint state_3 = random_state_3;
    float3  _S450 = negate_0(in_dir_1);
    float _S451 = sign_0(dot_0(n_5, _S450));
    float _S452 = material_4.roughness;
    float3  _S453 = sampleHalfVector(_S450, n_5 * make_float3 (_S451), _S452 * _S452, view_terms_0.frame, &state_3);
    return _S453;
}

__device__ float3  refractedHalf(float3  in_dir_2, float3  out_dir_0, float3  n_6, float eta_i_1, float eta_o_1)
{
    float3  _S454 = negate_0(in_dir_2);
    float3  _S455 = negate_0(make_float3 (eta_i_1) * _S454 + make_float3 (eta_o_1) * out_dir_0);
    float3  _S456 = ((((_S455)) * make_float3(rnorm3df(((_S455)).x, ((_S455)).y, ((_S455)).z))));
    float _S457 = sign_0(dot_0(n_6, _S454));
    float _S458 = sign_0(dot_0(_S455, n_6 * make_float3 (_S457)));
    return _S456 * make_float3 (_S458);
}

__device__ float3  reflectedHalf(float3  in_dir_3, float3  out_dir_1)
{
    float3  _S459 = negate_0(in_dir_3);
    float3  _S460 = _S459 + out_dir_1;
    float3  _S461 = ((((_S460)) * make_float3(rnorm3df(((_S460)).x, ((_S460)).y, ((_S460)).z))));
    return _S461;
}

static __device__ float3  refract_0(float3  i_6, float3  n_7, float eta_0)
{
    float _S462 = dot_0(n_7, i_6);
    float _S463 = 1.0f - eta_0 * eta_0 * (1.0f - _S462 * _S462);
    if(_S463 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_6 - make_float3 (eta_0 * _S462 + (F32_sqrt((_S463)))) * n_7;
}

__device__ float fresnel(float cos_theta_0, float eta_i_2, float eta_o_2)
{
    float _S464 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S465 = eta_i_2 / eta_o_2 * _S464;
    bool _S466 = _S465 < 1.0f;
    float kr_0;
    if(_S466)
    {
        float _S467 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S465 * _S465))))));
        float _S468 = eta_o_2 * cos_theta_0;
        float _S469 = eta_i_2 * _S467;
        float _S470 = (_S468 - _S469) / (_S468 + _S469);
        float _S471 = eta_i_2 * cos_theta_0;
        float _S472 = eta_o_2 * _S467;
        float _S473 = (_S471 - _S472) / (_S471 + _S472);
        float _S474 = (_S470 * _S470 + _S473 * _S473) / 2.0f;
        kr_0 = _S474;
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
    float _S475 = (F32_max((w_1.z), (0.0f)));
    return 2.0f * _S475 / (_S475 + length_0(make_float3 (alphas_2.x * w_1.x, alphas_2.y * w_1.y, _S475)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_3)
{
    float _S476 = alphas_3.x;
    float _S477 = h_0.x / _S476;
    float _S478 = alphas_3.y;
    float _S479 = h_0.y / _S478;
    float _S480 = h_0.z;
    float _S481 = _S477 * _S477 + _S479 * _S479 + _S480 * _S480;
    return 1.0f / (F32_max((3.14159274101257324f * _S476 * _S478 * _S481 * _S481), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ HalfTerms precomputeHalf(float3  in_dir_4, float3  ggx_n_0, BSDFMaterial material_5, float eta_i_3, float eta_o_3, MaterialTerms terms_1, ViewTerms view_terms_1)
{
    float _S482 = dot_0(ggx_n_0, view_terms_1.v);
    float _S483 = dot_0(view_terms_1.n_i, ggx_n_0);
    float _S484 = eta_i_3 / eta_o_3;
    float3  _S485 = refract_0(in_dir_4, ggx_n_0, _S484);
    float3  _S486 = ((((_S485)) * make_float3(rnorm3df(((_S485)).x, ((_S485)).y, ((_S485)).z))));
    float _S487 = (F32_abs((_S482)));
    bool _S488 = eta_i_3 > eta_o_3;
    float visible_1;
    if(_S488)
    {
        visible_1 = terms_1.eta_level;
    }
    else
    {
        visible_1 = 1.0f;
    }
    float _S489;
    if(_S488)
    {
        _S489 = 1.0f;
    }
    else
    {
        _S489 = terms_1.eta_level;
    }
    float _S490 = fresnel(_S487, visible_1, _S489);
    bool _S491 = (eta_i_3 * eta_i_3 * (1.0f - _S482 * _S482)) >= (eta_o_3 * eta_o_3);
    float3  _S492;
    if(_S491)
    {
        _S492 = make_float3 (1.0f);
    }
    else
    {
        float3  _S493 = material_5.specular_tint * make_float3 (terms_1.f0);
        _S492 = _S493 + (make_float3 (1.0f) - _S493) * make_float3 (_S490 - terms_1.f0) / make_float3 (1.0f - terms_1.f0);
    }
    float3  _S494 = mix_0(_S492, material_5.albedo * view_terms_1.rebounce, material_5.metallic);
    float3  F_1 = _S494 * view_terms_1.scale;
    float _S495 = rgb_to_greyscale(F_1);
    float _S496 = 1.0f - material_5.metallic;
    float3  _S497 = make_float3 (1.0f) - _S492;
    float3  _S498 = make_float3 ((1.0f - material_5.transmission) * _S496) * _S497 * view_terms_1.scale;
    float3  _S499 = make_float3 (material_5.transmission * _S496) * _S497 * view_terms_1.scale;
    float _S500 = (F32_max((_S495), (0.0f)));
    float _S501 = rgb_to_greyscale(_S498);
    float _S502 = (F32_max((_S501), (0.0f)));
    float _S503 = rgb_to_greyscale(_S499);
    float _S504 = sign_0(length_0(_S486));
    float _S505 = (F32_max((_S503 * _S504), (0.0f)));
    float _S506 = _S500 + _S502 + _S505 + terms_1.toon_component;
    float _S507 = (F32_min((view_terms_1.sheen_component), (1.0f)));
    bool _S508 = (view_terms_1.sheen_component) > 0.0f;
    bool _S509;
    if(_S508)
    {
        _S509 = !(_S506 > 0.0f);
    }
    else
    {
        _S509 = false;
    }
    float _S510 = _slang_select(_S509, 1.0f,_S507);
    float _S511 = (1.0f - _S510) / (F32_max((_S506), (0.0000152587890625f)));
    float _S512 = _S502 * _S511;
    float _S513 = _S500 * _S511;
    float _S514 = _S505 * _S511;
    bool _S515 = (view_terms_1.frame.alphas.x) > 0.0f;
    if(_S515)
    {
        float3  _S516 = anisotropicLocal(view_terms_1.v, view_terms_1.frame.tangent, view_terms_1.n_i);
        float _S517 = anisotropicG1(_S516, view_terms_1.frame.alphas);
        float3  _S518 = anisotropicLocal(ggx_n_0, view_terms_1.frame.tangent, view_terms_1.n_i);
        float _S519 = anisotropicD(_S518, view_terms_1.frame.alphas);
        float _S520 = _S517 * _S519;
        visible_1 = _S520;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return HalfTerms_x24init_0(_S482, _S483, _S486, F_1, _S495, 1.0f, _S498, _S499, _S512, _S513, _S514, terms_1.translucent_share, view_terms_1.sheen, _S510, view_terms_1.view, view_terms_1.frame.tangent, view_terms_1.frame.alphas, visible_1, terms_1.toon_component * _S511, terms_1.toon, terms_1.toon_a, terms_1.toon_s, terms_1.toon_b, terms_1.toon_glossy, terms_1.toon_norm, view_terms_1.toon_view, view_terms_1.toon_axis);
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_2, HalfTerms lobes_0, float eta_i_4, float eta_o_4)
{
    float _S521 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S522 = lobes_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S523 = 1.0f - lobes_0.translucent_share;
    bool _S524 = n_i_dot_l_0 < 0.0f;
    float _S525 = _slang_select(_S524, lobes_0.translucent_share,_S523);
    float _S526 = _S522 * _S525;
    bool _S527 = (lobes_0.translucent_share) > 0.0f;
    float _S528 = _slang_select(_S527, _S526,_S521);
    bool _S529 = n_i_dot_v_0 > 0.0f;
    float _S530 = _slang_select(_S529, _S528,0.0f);
    return _S530;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_3, float alpha_3, BSDFMaterial material_6, HalfTerms lobes_1)
{
    bool _S531 = (dot_0(n_i_3, l_0)) < 0.0f;
    float3  _S532 = _slang_select(_S531, material_6.translucent,material_6.albedo);
    float _S533 = 1.0f - lobes_1.translucent_share;
    float _S534 = _slang_select(_S531, lobes_1.translucent_share,_S533);
    float3  _S535 = _S532 / make_float3 (_S534);
    bool _S536 = (lobes_1.translucent_share) > 0.0f;
    float3  _S537 = _slang_select(_S536, _S535,material_6.albedo);
    return lobes_1.diffuse_weight * _S537 / make_float3 (lobes_1.p_diffuse);
}

__device__ float smithG1(float alpha_4, float n_dot_x_0)
{
    float _S538 = alpha_4 * alpha_4;
    float _S539 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S538 + (1.0f - _S538) * n_dot_x_0 * n_dot_x_0))));
    bool _S540 = alpha_4 > 0.0f;
    float _S541 = _slang_select(_S540, _S539,1.0f);
    return _S541;
}

__device__ float trowbridgeReitz(float alpha_5, float n_dot_h_1)
{
    float _S542 = alpha_5 * alpha_5;
    float _S543 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S542 * n_dot_h_1 * n_dot_h_1;
    return _S542 / (F32_max((3.14159274101257324f * _S543 * _S543), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float n_i_dot_v_1, float alpha_6, HalfTerms lobes_2)
{
    float _S544 = smithG1(alpha_6, n_i_dot_v_1);
    float _S545 = _S544 * lobes_2.v_dot_h;
    float _S546 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    float _S547 = _S545 * _S546 / n_i_dot_v_1;
    bool _S548 = alpha_6 > 0.0f;
    bool _S549;
    if(_S548)
    {
        _S549 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S549 = false;
    }
    if(_S549)
    {
        _S549 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S549 = false;
    }
    if(_S549)
    {
        _S549 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S549 = false;
    }
    float _S550 = _slang_select(_S549, _S547,0.0f);
    bool _S551 = (lobes_2.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S551)
    {
        float _S552 = lobes_2.visible * lobes_2.v_dot_h / n_i_dot_v_1;
        bool _S553 = (lobes_2.v_dot_h) > 0.0f;
        if(_S553)
        {
            _S549 = (lobes_2.n_dot_h) > 0.0f;
        }
        else
        {
            _S549 = false;
        }
        if(_S549)
        {
            _S549 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S549 = false;
        }
        float _S554 = _slang_select(_S549, _S552,0.0f);
        pdf_h_0 = _S554;
    }
    else
    {
        pdf_h_0 = _S550;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float n_i_dot_l_1, float l_dot_h_1, float n_i_dot_v_2, float alpha_7, HalfTerms lobes_3, float eta_i_5, float eta_o_5)
{
    float _S555 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    float _S556 = eta_i_5 * lobes_3.v_dot_h + eta_o_5 * l_dot_h_1;
    float _S557 = lobes_3.p_refract * _S555 * eta_o_5 * eta_o_5 * (F32_abs((l_dot_h_1))) / (_S556 * _S556);
    bool _S558 = eta_i_5 != eta_o_5;
    bool _S559;
    if(_S558)
    {
        _S559 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S559 = false;
    }
    float _S560 = _slang_select(_S559, _S557,0.0f);
    return _S560;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_4, float alpha_8, BSDFMaterial material_7, HalfTerms lobes_4)
{
    float _S561 = - dot_0(n_i_4, l_1);
    float _S562 = smithG1(alpha_8, (F32_max((_S561), (0.0f))));
    bool _S563 = (lobes_4.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S563)
    {
        float3  _S564 = negate_0(n_i_4);
        float3  _S565 = anisotropicLocal(l_1, lobes_4.tangent, _S564);
        float _S566 = anisotropicG1(_S565, lobes_4.alphas);
        G1_l_0 = _S566;
    }
    else
    {
        G1_l_0 = _S562;
    }
    return lobes_4.refract_weight * make_float3 (G1_l_0) * material_7.albedo / make_float3 (lobes_4.p_refract);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_2, float l_dot_h_2, float n_i_dot_v_3, float alpha_9, HalfTerms lobes_5, float eta_i_6, float eta_o_6)
{
    float _S567 = lobes_5.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S568 = n_i_dot_l_2 > 0.0f;
    bool _S569;
    if(_S568)
    {
        _S569 = n_i_dot_v_3 > 0.0f;
    }
    else
    {
        _S569 = false;
    }
    float _S570 = _slang_select(_S569, _S567,0.0f);
    return _S570;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  n_i_5, float alpha_10, BSDFMaterial material_8, HalfTerms lobes_6)
{
    float3  _S571 = l_2 + lobes_6.view;
    float3  _S572 = ((((_S571)) * make_float3(rnorm3df(((_S571)).x, ((_S571)).y, ((_S571)).z))));
    float _S573 = dot_0(n_i_5, _S572);
    float _S574 = (F32_max((dot_0(n_i_5, l_2)), (0.0f)));
    float _S575 = (F32_max((dot_0(n_i_5, lobes_6.view)), (0.0f)));
    float _S576 = 1.0f / (F32_max((material_8.sheen_roughness), (0.05000000074505806f)));
    float _S577 = 1.0f - _S573 * _S573;
    float _S578 = (2.0f + _S576) * (F32_pow(((F32_max((_S577), (0.0f)))), (0.5f * _S576))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S574 + _S575 - _S574 * _S575)), (0.0000152587890625f)));
    bool _S579 = (material_8.velvet) > 0.0f;
    float f_1;
    if(_S579)
    {
        float _S580 = (F32_max((material_8.sheen_roughness), (0.00999999977648258f)));
        float _S581 = _S580 * _S580;
        float _S582 = (F32_max((_S577), (0.0000152587890625f)));
        float _S583 = (F32_exp((- _S573 * _S573 / (_S582 * _S581)))) / (3.14159274101257324f * _S581 * _S582 * _S582) * (F32_min((1.0f), (2.0f * _S573 * (F32_min((_S574), (_S575))) / (F32_max(((F32_abs((dot_0(_S572, lobes_6.view))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S574 * _S575), (0.0000152587890625f)));
        f_1 = _S583;
    }
    else
    {
        f_1 = _S578;
    }
    return lobes_6.sheen * make_float3 (f_1 * _S574 * 2.0f * 3.14159274101257324f / lobes_6.p_sheen_velvet);
}

__device__ __forceinline__ float toonPDF(float n_i_dot_l_3, float l_dot_h_3, float n_i_dot_v_4, float alpha_11, HalfTerms lobes_7, float eta_i_7, float eta_o_7)
{
    float _S584 = _slang_select(lobes_7.toon_glossy, l_dot_h_3,n_i_dot_l_3);
    float _S585 = (F32_acos((clamp_1(_S584, -1.0f, 1.0f))));
    float _S586;
    if(_S585 < (lobes_7.toon_a))
    {
        _S586 = 1.0f;
    }
    else
    {
        _S586 = (F32_max((1.0f - (_S585 - lobes_7.toon_a) / (F32_max((lobes_7.toon_s), (0.0000152587890625f)))), (0.0f)));
    }
    float _S587 = lobes_7.p_toon * _S586;
    float _S588 = _slang_select(lobes_7.toon_glossy, 1.0f,n_i_dot_l_3);
    float _S589 = _S587 * _S588 / lobes_7.toon_norm;
    bool _S590;
    if(lobes_7.toon_glossy)
    {
        _S590 = true;
    }
    else
    {
        _S590 = n_i_dot_l_3 > 0.0f;
    }
    float _S591 = _slang_select(_S590, _S589,0.0f);
    return _S591;
}

__device__ __forceinline__ float3  toonBSDF(float3  l_3, float3  n_i_6, float alpha_12, BSDFMaterial material_9, HalfTerms lobes_8)
{
    float _S592 = (F32_max((dot_0(n_i_6, l_3)), (0.0f)));
    float _S593 = _slang_select(lobes_8.toon_glossy, _S592,lobes_8.toon_view);
    return lobes_8.toon * make_float3 (_S593) / make_float3 (lobes_8.p_toon);
}

__device__ __forceinline__ float reflectPDF(float n_i_dot_l_4, float l_dot_h_4, float n_i_dot_v_5, float alpha_13, HalfTerms lobes_9, float eta_i_8, float eta_o_8)
{
    float _S594 = vndfPDF(n_i_dot_v_5, alpha_13, lobes_9);
    float _S595 = lobes_9.p_reflect * _S594 / (4.0f * lobes_9.v_dot_h);
    bool _S596 = _S594 > 0.0f;
    float _S597 = _slang_select(_S596, _S595,0.0f);
    return _S597;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_4, float3  n_i_7, float alpha_14, BSDFMaterial material_10, HalfTerms lobes_10)
{
    float _S598 = dot_0(n_i_7, l_4);
    float _S599 = smithG1(alpha_14, (F32_max((_S598), (0.0f))));
    bool _S600 = (lobes_10.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S600)
    {
        float3  _S601 = anisotropicLocal(l_4, lobes_10.tangent, n_i_7);
        float _S602 = anisotropicG1(_S601, lobes_10.alphas);
        G1_l_1 = _S602;
    }
    else
    {
        G1_l_1 = _S599;
    }
    return make_float3 (lobes_10.reflect_weight * G1_l_1) * lobes_10.F / make_float3 (lobes_10.p_reflect);
}

__device__ __forceinline__ float3  misWeighted(float3  throughput_0, float lobe_pdf_0, float pdf_0, bool power_0)
{
    if(power_0)
    {
        float _S603 = lobe_pdf_0 / pdf_0;
        return throughput_0 * make_float3 (lobe_pdf_0) / make_float3 (pdf_0 * (1.0f + _S603 * _S603));
    }
    return throughput_0 * make_float3 (lobe_pdf_0) / make_float3 (lobe_pdf_0 + pdf_0);
}

static __device__ float3  neeLobes_0(float3  in_dir_5, float3  dir_3, float3  n_8, BSDFMaterial * material_11, float eta_i_9, float eta_o_9, bool refracted_2, float pdf_1, bool power_1, uint random_state_4, MaterialTerms * terms_2, ViewTerms * view_terms_2, FixedArray<float3 , 5>  * each_0, uint * reached_0)
{
    float3  _S604 = negate_0(in_dir_5);
    float _S605 = dot_0(n_8, _S604);
    float _S606 = sign_0(_S605);
    float3  _S607 = n_8 * make_float3 (_S606);
    float _S608 = dot_0(_S607, dir_3);
    float _S609 = material_11->roughness * material_11->roughness;
    float3  _S610 = make_float3 (0.0f);
    *reached_0 = 0U;
    HalfTerms _S611 = HalfTerms_x24init_0(0.0f, 0.0f, _S610, _S610, 0.0f, 0.0f, _S610, _S610, 0.0f, 0.0f, 0.0f, 0.0f, _S610, 0.0f, _S610, _S610, make_float2 (0.0f), 0.0f, 0.0f, _S610, 0.0f, 0.0f, 0.0f, false, 1.0f, 0.0f, _S610);
    uint _S612;
    if((F32_abs((material_11->toon.x))) > 0.0f)
    {
        _S612 = 5U;
    }
    else
    {
        _S612 = 4U;
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
        (*each_0)[i_7] = _S610;
        uint i_8 = i_7 + 1U;
        i_7 = i_8;
    }
    uint half_of_0 = 4294967295U;
    HalfTerms lobe_terms_0 = _S611;
    float3  ggx_n_1 = _S610;
    i_7 = 0U;
    float3  f_2 = _S610;
    for(;;)
    {
        if(i_7 < _S612)
        {
        }
        else
        {
            break;
        }
        uint _S613;
        if(i_7 == 3U)
        {
            _S613 = 4U;
        }
        else
        {
            if(i_7 == 4U)
            {
                _S613 = 6U;
            }
            else
            {
                _S613 = i_7;
            }
        }
        bool _S614 = _S613 == 0U;
        if(_S614)
        {
        }
        bool _S615;
        if(_S614)
        {
            float _S616 = rgb_to_greyscale(material_11->translucent);
            _S615 = _S616 > 0.0f;
        }
        else
        {
            _S615 = false;
        }
        bool _S617;
        if(_S615)
        {
            float _S618 = dot_0(n_8, dir_3);
            float3  _S619 = negate_0(in_dir_5);
            _S617 = ((_S618 * dot_0(n_8, _S619)) < 0.0f) == refracted_2;
        }
        else
        {
            _S617 = (_S613 == 1U) == refracted_2;
        }
        float3  ggx_n_2;
        if(_S617)
        {
            uint _S620;
            if(_S613 == 6U)
            {
                _S620 = 0U;
            }
            else
            {
                if(_S613 == 4U)
                {
                    _S620 = 2U;
                }
                else
                {
                    _S620 = _S613;
                }
            }
            bool _S621 = _S620 != half_of_0;
            uint half_of_1;
            HalfTerms lobe_terms_1;
            if(_S621)
            {
                bool _S622 = _S620 == 0U;
                if(_S622)
                {
                    float3  _S623 = sampledHalf(in_dir_5, n_8, *material_11, random_state_4, *view_terms_2);
                    ggx_n_2 = _S623;
                }
                else
                {
                    bool _S624 = _S620 == 1U;
                    if(_S624)
                    {
                        float3  _S625 = refractedHalf(in_dir_5, dir_3, n_8, eta_i_9, eta_o_9);
                        ggx_n_2 = _S625;
                    }
                    else
                    {
                        float3  _S626 = reflectedHalf(in_dir_5, dir_3);
                        ggx_n_2 = _S626;
                    }
                }
                HalfTerms _S627 = precomputeHalf(in_dir_5, ggx_n_2, *material_11, eta_i_9, eta_o_9, *terms_2, *view_terms_2);
                lobe_terms_1 = _S627;
                half_of_1 = _S620;
            }
            else
            {
                lobe_terms_1 = lobe_terms_0;
                ggx_n_2 = ggx_n_1;
                half_of_1 = half_of_0;
            }
            float3  throughput_1;
            float lobe_pdf_1;
            switch(_S613)
            {
            case 0U:
                {
                    float _S628 = diffusePDF(_S608, 0.0f, (F32_abs((_S605))), _S609, lobe_terms_1, eta_i_9, eta_o_9);
                    float3  _S629 = diffuseBSDF(dir_3, _S607, _S609, *material_11, lobe_terms_1);
                    lobe_pdf_1 = _S628;
                    throughput_1 = _S629;
                    break;
                }
            case 1U:
                {
                    float _S630 = refractPDF(_S608, dot_0(dir_3, ggx_n_2), (F32_abs((_S605))), _S609, lobe_terms_1, eta_i_9, eta_o_9);
                    float3  _S631 = refractBSDF(dir_3, _S607, _S609, *material_11, lobe_terms_1);
                    lobe_pdf_1 = _S630;
                    throughput_1 = _S631;
                    break;
                }
            case 4U:
                {
                    float _S632 = sheenVelvetPDF(_S608, 0.0f, (F32_abs((_S605))), _S609, lobe_terms_1, eta_i_9, eta_o_9);
                    float3  _S633 = sheenVelvetBSDF(dir_3, _S607, _S609, *material_11, lobe_terms_1);
                    lobe_pdf_1 = _S632;
                    throughput_1 = _S633;
                    break;
                }
            case 6U:
                {
                    float _S634 = toonPDF(_S608, dot_0(dir_3, lobe_terms_1.toon_axis), (F32_abs((_S605))), _S609, lobe_terms_1, eta_i_9, eta_o_9);
                    float3  _S635 = toonBSDF(dir_3, _S607, _S609, *material_11, lobe_terms_1);
                    lobe_pdf_1 = _S634;
                    throughput_1 = _S635;
                    break;
                }
            default:
                {
                    float _S636 = reflectPDF(_S608, 0.0f, (F32_abs((_S605))), _S609, lobe_terms_1, eta_i_9, eta_o_9);
                    float3  _S637 = reflectBSDF(dir_3, _S607, _S609, *material_11, lobe_terms_1);
                    lobe_pdf_1 = _S636;
                    throughput_1 = _S637;
                    break;
                }
            }
            bool _S638 = lobe_pdf_1 > 0.0f;
            float3  f_3;
            if(_S638)
            {
                float3  _S639 = misWeighted(throughput_1, lobe_pdf_1, pdf_1, power_1);
                (*each_0)[i_7] = _S639;
                uint _S640 = (*reached_0) | (1U << i_7);
                *reached_0 = _S640;
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

__device__ __forceinline__ float3  neeBSDF(float3  in_dir_6, float3  dir_4, float3  n_9, BSDFMaterial material_12, float eta_i_10, float eta_o_10, bool refracted_3, float pdf_2, bool power_2, uint random_state_5, MaterialTerms terms_3, ViewTerms view_terms_3)
{
    uint reached_1 = 0U;
    BSDFMaterial _S641 = material_12;
    MaterialTerms _S642 = terms_3;
    ViewTerms _S643 = view_terms_3;
    FixedArray<float3 , 5>  each_1;
    float3  _S644 = neeLobes_0(in_dir_6, dir_4, n_9, &_S641, eta_i_10, eta_o_10, refracted_3, pdf_2, power_2, random_state_5, &_S642, &_S643, &each_1, &reached_1);
    return _S644;
}

__device__ float3  skyBSDF(float3  in_dir_7, float3  dir_5, FKSurface surface_1, float2  eta_1, bool is_inside_2, float pdf_3, uint random_state_6)
{
    bool _S645 = wrongSide_0(is_inside_2, false, dir_5, surface_1.geometry_n);
    float _S646 = eta_1.x;
    float _S647 = eta_1.y;
    MaterialTerms _S648 = precomputeMaterial(surface_1.material, _S646, _S647);
    ViewTerms _S649 = precomputeView(in_dir_7, surface_1.smooth_n, surface_1.material, _S648);
    float3  _S650 = neeBSDF(in_dir_7, dir_5, surface_1.smooth_n, surface_1.material, _S646, _S647, _S645, pdf_3, false, random_state_6, _S648, _S649);
    return _S650;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_6, float3  radiance_0, float3  color_0, uint random_state_7)
{
    SkySample _S651;
    (&_S651)->dir = dir_6;
    (&_S651)->radiance = radiance_0;
    (&_S651)->color = color_0;
    (&_S651)->random_state = random_state_7;
    return _S651;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_2, float2  eta_2, bool is_inside_3, uint init_random_state_0, uint lobe_state_0, ShadowContext * context_2)
{
    uint2  _S652 = (fcptEnvironmentCdfSize());
    uint2  _S653 = make_uint2 (1U, 0U);
    uint2  _S654 = _S652 - _S653;
    Random _S655 = pcg(init_random_state_0);
    Random _S656 = pcg(_S655.state);
    Random _S657 = pcg(_S656.state);
    Random _S658 = pcg(_S657.state);
    uint _S659 = _S654.x;
    uint _S660 = searchCDF_0(make_uint2 (_S659, 0U), make_uint2 (0U, 1U), _S654.y, _S655.value);
    uint _S661 = searchCDF_0(make_uint2 (0U, _S660), _S653, _S659, _S656.value);
    float2  _S662 = make_float2 ((float)_S654.x, (float)_S654.y);
    float2  _S663 = (make_float2 (float(_S661), float(_S660)) + make_float2 (_S657.value, _S658.value)) / _S662 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S664 = _S663.y;
    float _S665 = (F32_sin((_S664)));
    float _S666 = _S663.x;
    float3  _S667 = make_float3 (- _S665 * (F32_cos((_S666))), _S665 * (F32_sin((_S666))), (F32_cos((_S664))));
    float _S668 = environmentPdf_0(_S667);
    float3  _S669 = skyBSDF(ray_0->unit_direction, _S667, *surface_2, eta_2, is_inside_3, _S668, lobe_state_0);
    bool _S670 = !(_S668 > 0.0f);
    bool _S671;
    if(_S670)
    {
        _S671 = true;
    }
    else
    {
        _S671 = all_1(_S669 == make_float3 (0.0f));
    }
    if(_S671)
    {
        float3  _S672 = make_float3 (0.0f);
        return SkySample_x24init_0(_S667, _S672, _S672, _S658.state);
    }
    float3  _S673 = skyRadiance_0(ray_0->origin, surface_2, is_inside_3, _S667, context_2, _S658.state);
    return SkySample_x24init_0(_S667, _S673, _S669 * _S673, _S658.state);
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

static __device__ float3  hairLight_0(FKSurface * surface_3, float3  in_dir_8, TreeSample * light_1, bool competing_0)
{
    SampleBSDF _S674 = (fcptConnectHair((surface_3->hair), ((&surface_3->material)->albedo), ((&surface_3->material)->specular_tint), (in_dir_8), (light_1->dir)));
    float3  _S675 = _S674.throughput * make_float3 (_S674.pdf);
    float _S676 = light_1->density;
    float _S677 = 1.0f + _S674.pdf * _S674.pdf / (light_1->density * light_1->density);
    bool _S678;
    if(competing_0)
    {
        _S678 = _S676 > 0.0f;
    }
    else
    {
        _S678 = false;
    }
    float _S679 = _slang_select(_S678, _S677,1.0f);
    return _S675 / make_float3 (_S679) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_7, float3  radiance_1, float density_0, uint random_state_8)
{
    TreeSample _S680;
    (&_S680)->dir = dir_7;
    (&_S680)->radiance = radiance_1;
    (&_S680)->density = density_0;
    (&_S680)->random_state = random_state_8;
    return _S680;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_12, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S681 = importance(first_1, p_12, normal_3);
    float _S682 = importance(second_1, p_12, normal_3);
    float2  _S683 = make_float2 (_S681, _S682);
    bool _S684 = _S681 == 0.0f;
    bool _S685;
    if(_S684)
    {
        _S685 = _S682 == 0.0f;
    }
    else
    {
        _S685 = false;
    }
    if(_S685)
    {
        return 2U;
    }
    float _S686 = _S681 + _S682;
    bool _S687 = _S682 > 0.0f;
    if(_S687)
    {
        _S685 = (*pick_0 * _S686) >= _S681;
    }
    else
    {
        _S685 = false;
    }
    uint _S688 = uint(_S685);
    float _S689 = (F32_min(((*pick_0 * _S686 - float(_S688) * _S681) / _slang_vector_get_element(_S683, _S688)), (0.99999994039535522f)));
    *pick_0 = _S689;
    float _S690 = *probability_3 * (_slang_vector_get_element(_S683, _S688) / _S686);
    *probability_3 = _S690;
    return _S688;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_13, float u1_0, float u2_0)
{
    float3  _S691 = center_1 - p_13;
    float _S692 = radius_1 * radius_1 / dot_0(_S691, _S691);
    float _S693 = u1_0 * _S692 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S692), (0.0f)))))));
    float _S694 = 2.0f * u1_0;
    bool _S695 = _S692 >= 1.0f;
    float _S696 = _slang_select(_S695, _S694,_S693);
    float _S697 = (F32_sqrt(((F32_max((_S696 * (2.0f - _S696)), (0.0f))))));
    float _S698 = 6.28318548202514648f * u2_0;
    float3  _S699 = make_float3 (_S697 * (F32_cos((_S698))), 1.0f - _S696, _S697 * (F32_sin((_S698))));
    float3  _S700 = ((((_S691)) * make_float3(rnorm3df(((_S691)).x, ((_S691)).y, ((_S691)).z))));
    float3  _S701 = tangentToWorld(_S699, _S700);
    return _S701;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S702 = center_2 - ray_1->origin;
    float _S703 = dot_0(_S702, ray_1->unit_direction);
    float _S704 = dot_0(_S702, _S702) - _S703 * _S703;
    float _S705 = radius_3 * radius_3;
    bool _S706 = _S704 > _S705;
    if(_S706)
    {
        return 4.294967296e+09f;
    }
    float _S707 = (F32_sqrt((_S705 - _S704)));
    float _S708 = _S703 - _S707;
    float _S709 = _S703 + _S707;
    bool _S710 = _S708 > 0.0000152587890625f;
    bool _S711;
    if(_S710)
    {
        _S711 = _S708 < max_len_0;
    }
    else
    {
        _S711 = false;
    }
    if(_S711)
    {
        return _S708;
    }
    bool _S712 = _S709 > 0.0000152587890625f;
    if(_S712)
    {
        _S711 = _S709 < max_len_0;
    }
    else
    {
        _S711 = false;
    }
    if(_S711)
    {
        return _S709;
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
    Random _S713 = pcg(init_random_state_1);
    Random _S714 = pcg(_S713.state);
    Random _S715 = pcg(_S714.state);
    float3  _S716 = make_float3 (0.0f);
    TreeSample _S717 = TreeSample_x24init_0(_S716, _S716, 0.0f, _S715.state);
    TreeSample sample_0 = _S717;
    float3  _S718 = _slang_select(sided_0, _S716,smooth_n_2);
    float3  _S719 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S713.value;
    float probability_4 = 1.0f;
    uint n_10 = 0U;
    for(;;)
    {
        uint4  _S720 = (fcptLightNode((n_10)));
        if((_S720.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S721 = (fcptLightSecond((n_10)));
        uint _S722 = n_10 + 1U;
        LightNode _S723 = (fcptLightBounds((_S722)));
        LightNode _S724 = (fcptLightBounds((_S721)));
        uint _S725 = pickChild(_S723, _S724, origin_4, _S718, &pick_1, &probability_4);
        bool _S726 = _S725 > 1U;
        if(_S726)
        {
            return sample_0;
        }
        bool _S727 = _S725 == 1U;
        uint _S728 = _slang_select(_S727, _S721,_S722);
        n_10 = _S728;
    }
    bool _S729 = n_10 == 0U;
    bool _S730;
    if(_S729)
    {
        LightNode _S731 = (fcptLightBounds((0U)));
        float _S732 = importance(_S731, origin_4, _S718);
        _S730 = !(_S732 > 0.0f);
    }
    else
    {
        _S730 = false;
    }
    if(_S730)
    {
        return sample_0;
    }
    uint4  _S733 = (fcptLightNode((n_10)));
    FKHit _S734 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S735 = (_S733.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S735)
    {
        FKLight _S736 = (fcptLight((_S733.y)));
        if(sided_0)
        {
            float _S737 = sign_0(dot_0(geometry_n_1, _S736.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S737);
            float3  _S738 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S738;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S719;
            lift_n_0 = smooth_n_2;
        }
        bool _S739 = (_S736.variance) == 0.0f;
        if(_S739)
        {
            float3  _S740 = _S736.position - emitter_point_0;
            float3  _S741 = ((((_S740)) * make_float3(rnorm3df(((_S740)).x, ((_S740)).y, ((_S740)).z))));
            (&sample_0)->dir = _S741;
            float3  _S742 = _S736.color * make_float3 (_S736.intensity) / make_float3 (dot_0(_S740, _S740) * probability_4);
            (&sample_0)->radiance = _S742;
            shadow_1 = _S740;
        }
        else
        {
            float3  _S743 = sampleSphere(_S736.position, _S736.variance, emitter_point_0, _S714.value, _S715.value);
            (&sample_0)->dir = _S743;
            float _S744 = sphereDensity(_S736.position, _S736.variance, emitter_point_0);
            float _S745 = probability_4 * _S744;
            (&sample_0)->density = _S745;
            float3  _S746 = pointLightRadiance(_S736.color, _S736.intensity, _S736.variance);
            float3  _S747 = _S746 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S747;
            FKRay _S748 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S749 = raySphere_0(_S736.position, _S736.variance, &_S748, 4.294967296e+09f);
            float3  _S750 = (&sample_0)->dir * make_float3 (_S749);
            shadow_1 = _S750;
        }
        emitter_0 = _S734;
        emitter_point_0 = _S716;
    }
    else
    {
        uint _S751 = _S733.y;
        uint _S752 = (fcptTriangleOffset((_S751)));
        uint _S753 = _S752 + _S733.z;
        Matrix<float, 3, 3>  _S754 = (fcptWorldTriangle((_S751), (_S753)));
        float _S755 = (F32_sqrt((_S714.value)));
        float2  _S756 = make_float2 (_S755 * (1.0f - _S715.value), _S755 * _S715.value);
        float3  _S757 = mul_0(make_float3 (1.0f - _S755, _S756.x, _S756.y), _S754);
        if(sided_0)
        {
            float _S758 = sign_0(dot_0(geometry_n_1, _S757 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S758);
            float3  _S759 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S759;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S760 = !((dot_0(smooth_n_2, _S757 - origin_4)) > 0.0f);
            if(_S760)
            {
                return sample_0;
            }
            emitter_point_0 = _S719;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S756, _S751, _S753, 0U, 0.0f);
        float3  _S761 = _S757 - emitter_point_0;
        float3  _S762 = ((((_S761)) * make_float3(rnorm3df(((_S761)).x, ((_S761)).y, ((_S761)).z))));
        (&sample_0)->dir = _S762;
        float _S763 = solidAngle(probability_4, cross_0(_S754.rows[int(1)] - _S754.rows[int(0)], _S754.rows[int(2)] - _S754.rows[int(0)]), _S761);
        (&sample_0)->density = _S763;
        bool _S764 = (fcptShadowFirst());
        bool _S765 = !_S764;
        if(_S765)
        {
            FKSurface _S766 = (fcptLightSurfaceAt((emitter_1), (_S757), (_S715.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S757 - origin_4))));
            (&sample_0)->random_state = _S766.random_state;
            float3  _S767 = _slang_select(_S766.skip, _S716,_S766.material.emissive);
            float3  _S768 = _S767 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S768;
        }
        shadow_1 = _S761;
        emitter_0 = emitter_1;
        emitter_point_0 = _S757;
    }
    FKHit _S769 = emitter_0;
    float3  _S770 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S715.state, &_S769);
    bool _S771 = (fcptShadowFirst());
    if(_S771)
    {
        _S730 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S730 = false;
    }
    if(_S730)
    {
        _S730 = !all_1(_S770 == _S716);
    }
    else
    {
        _S730 = false;
    }
    if(_S730)
    {
        FKSurface _S772 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S715.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S772.random_state;
        float3  _S773 = _slang_select(_S772.skip, _S716,_S772.material.emissive);
        float3  _S774 = _S773 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S774;
    }
    float3  _S775 = (&sample_0)->radiance * _S770;
    bool _S776 = all_1(_S770 == _S716);
    float3  _S777 = _slang_select(_S776, _S716,_S775);
    (&sample_0)->radiance = _S777;
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
    float _S778 = 1.0f / (1.0f + b_3 / a_7 * (b_3 / a_7));
    bool _S779 = b_3 > 0.0f;
    float _S780 = _slang_select(_S779, _S778,1.0f);
    return _S780;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S781 = vertex_0->none;
    if(_S781)
    {
        return 1.0f;
    }
    uint _S782 = (fcptLightSlot((*hit_1)));
    float _S783 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S782, light_point_1);
    float _S784 = powerHeuristic(vertex_0->pdf, _S783);
    return _S784;
}

static __device__ float3  environment_0(float3  dir_8, uint depth_0, uint lobe_0)
{
    uint2  _S785 = (fcptEnvironmentMapSize());
    bool _S786 = (_S785.x) > 1U;
    bool _S787;
    if(_S786)
    {
        uint2  _S788 = (fcptEnvironmentMapSize());
        _S787 = (_S788.y) > 1U;
    }
    else
    {
        _S787 = false;
    }
    if(_S787)
    {
        float3  _S789 = (fcptEnvMapSample((dir_8), (depth_0), (lobe_0)));
        return _S789;
    }
    float3  _S790 = (fcptAmbient());
    return _S790;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S791 = (fcptEnvironmentCdfSize());
    bool _S792 = (_S791.x) > 1U;
    bool _S793;
    if(_S792)
    {
        uint2  _S794 = (fcptEnvironmentCdfSize());
        _S793 = (_S794.y) > 1U;
    }
    else
    {
        _S793 = false;
    }
    bool _S795 = !_S793;
    if(_S795)
    {
        return false;
    }
    uint2  _S796 = (fcptEnvironmentMapSize());
    bool _S797 = (_S796.x) > 1U;
    if(_S797)
    {
        uint2  _S798 = (fcptEnvironmentMapSize());
        _S793 = (_S798.y) > 1U;
    }
    else
    {
        _S793 = false;
    }
    return _S793;
}

static __device__ float escapeWeight_0(float pdf_4, float3  dir_9)
{
    bool _S799 = pdf_4 <= 0.0f;
    bool _S800;
    if(_S799)
    {
        _S800 = true;
    }
    else
    {
        bool _S801 = environmentMapped_0();
        _S800 = !_S801;
    }
    if(_S800)
    {
        return 1.0f;
    }
    float _S802 = environmentPdf_0(dir_9);
    return pdf_4 / (pdf_4 + _S802);
}

static __device__ void restir_duplicates_0(uint3  global_invocation_id_1, uint3  local_invocation_id_0, uint local_invocation_index_3)
{
    uint2  _S803 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S804 = make_int2 ((int)_S803.x, (int)_S803.y);
    uint _S805 = previousSeed_0(_S804);
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
            uint _S806 = previousSeed_0(_S804 + make_int2 (x_16, y_5));
            bool _S807 = _S806 == _S805;
            uint _S808 = _slang_select(_S807, 1U,0U);
            uint count_3 = count_2 + _S808;
            int x_17 = x_16 + int(1);
            x_16 = x_17;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S809 = float(count_2 - 1U) / 288.0f;
    bool _S810 = _S805 != 0U;
    float _S811 = _slang_select(_S810, _S809,0.0f);
    fcptStoreDuplication((_S804), (make_uint4 ((F32_asuint((_S811))), 0U, 0U, 0U)));
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
    float _S812 = rgb_to_greyscale(abs_0(f_5));
    return _S812;
}

__device__ uint stream(uint seed_3, uint index_0)
{
    uint _S813 = hash(index_0);
    uint _S814 = hash(seed_3 ^ _S813);
    return _S814;
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
    float _S815 = resamplingTarget(weight_0);
    bool _S816 = _S815 > 0.0f;
    bool _S817;
    if(_S816)
    {
        _S817 = _S815 < 3.00000000549775576e+38f;
    }
    else
    {
        _S817 = false;
    }
    bool _S818 = !_S817;
    if(_S818)
    {
        return;
    }
    bool _S819 = sel_2->sums;
    if(_S819)
    {
        float3  _S820 = sel_2->color + weight_0;
        sel_2->color = _S820;
        return;
    }
    float _S821 = sel_2->w_sum + _S815;
    sel_2->w_sum = _S821;
    float3  _S822 = sel_2->color + weight_0;
    sel_2->color = _S822;
    Random _S823 = pcg(sel_2->random_state);
    sel_2->random_state = _S823.state;
    bool _S824 = (_S823.value * sel_2->w_sum) <= _S815;
    if(_S824)
    {
        sel_2->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_3;
    float3  _S825 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S825;
    float _S826 = r_3.jac * shifted_0.jac;
    (&candidate_1)->jac = _S826;
    offer(sel_3, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S827 = resamplingTarget((&r_4)->f);
    float _S828 = sel_4.w_sum / _S827;
    bool _S829 = _S827 > 0.0f;
    float _S830 = _slang_select(_S829, _S828,0.0f);
    (&r_4)->w = _S830;
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
    uint2  _S831 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S832 = make_int2 ((int)_S831.x, (int)_S831.y);
    float3  _S833 = make_float3 (0.0f);
    FKHit _S834 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S835 = Domain_x24init_0(_S833, _S833, &_S834, 0.0f, 0.0f);
    Domain dom_4 = _S835;
    bool _S836 = (fcptCurrentDomain((_S832), (&dom_4)));
    bool _S837 = !_S836;
    if(_S837)
    {
        Reservoir _S838 = (Reservoir{});
        fcptStoreReservoirPrevious((_S832), (_S838), ((&dom_4)->hit));
        return;
    }
    Reservoir _S839 = (fcptLoadReservoirTemporal((_S832)));
    uint t_13 = 0U;
    float count_4 = 0.0f;
    float c_sum_1 = _S839.c;
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
        int2  _S841 = partner_0(_S832, t_13);
        Domain neighbor_0 = _S835;
        bool _S842 = (fcptCurrentDomain((_S841), (&neighbor_0)));
        if(_S842)
        {
            float count_5 = count_4 + 1.0f;
            uint4  _S843 = (fcptReservoirTemporal((_S841), (0U)));
            float c_sum_2 = c_sum_1 + (U32_asfloat((_S843.w)));
            count_4 = count_5;
            c_sum_1 = c_sum_2;
        }
        uint t_14 = t_13 + 1U;
        t_13 = t_14;
    }
    float _S844 = _S839.c / (F32_max((count_4), (1.0f)));
    float _S845 = resamplingTarget(_S839.f);
    bool _S846 = count_4 == 0.0f;
    float _S847 = _slang_select(_S846, 1.0f,0.0f);
    Selection _S848 = (Selection{});
    Selection sel_5 = _S848;
    uint _S849 = (fcptFrame());
    uint _S850 = hash(_S849);
    uint _S851 = global_invocation_id_2.x;
    uint2  _S852 = (fcptRenderSize());
    uint _S853 = stream(_S850, _S851 + _S852.x * global_invocation_id_2.y);
    uint _S854 = stream(_S853, 195U);
    (&sel_5)->random_state = _S854;
    t_13 = 0U;
    float canonical_mis_0 = _S847;
    for(;;)
    {
        uint _S855 = (fcptRestirNeighbours());
        if(t_13 < _S855)
        {
        }
        else
        {
            break;
        }
        int2  _S856 = partner_0(_S832, t_13);
        Domain neighbor_dom_0 = _S835;
        bool _S857 = (fcptCurrentDomain((_S856), (&neighbor_dom_0)));
        if(_S857)
        {
            Reservoir _S858 = (fcptLoadReservoirTemporal((_S856)));
            uint4  _S859 = (fcptShiftData((_S856), (t_13)));
            float4  _S860 = asfloat_0(_S859);
            uint4  _S861 = (fcptShiftData((_S832), (t_13)));
            float4  _S862 = asfloat_0(_S861);
            float _S863 = pairShare(_S858.c, _S844, c_sum_1);
            bool _S864 = _S845 > 0.0f;
            float canonical_mis_1;
            if(_S864)
            {
                float _S865 = resamplingTarget(float3 {_S862.x, _S862.y, _S862.z});
                float _S866 = canonicalWeight(_S863, _S844, _S845, _S858.c, _S865);
                float canonical_mis_2 = canonical_mis_0 + _S866;
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float3  _S867 = float3 {_S860.x, _S860.y, _S860.z};
            Shift _S868 = Shift_x24init_0(_S867, _S860.w);
            float _S869 = resamplingTarget(_S858.f);
            float _S870 = resamplingTarget(_S867);
            float _S871 = neighborWeight(_S863, _S858.c, _S869, _S844, _S870);
            offerShifted(&sel_5, _S858, _S868, _S871);
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_15 = t_13 + 1U;
        t_13 = t_15;
    }
    offerShifted(&sel_5, _S839, Shift_x24init_0(_S839.f, 1.0f), canonical_mis_0);
    Reservoir _S872 = finalize(sel_5, c_sum_1);
    fcptStoreReservoirPrevious((_S832), (_S872), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S832), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S832), (make_float4 ((&sel_5)->color.x, (&sel_5)->color.y, (&sel_5)->color.z, 0.0f)));
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
    uint _S873 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S874 = _S873 != 4294967295U;
    if(_S874)
    {
        uint2  _S875 = make_uint2 (_S873, _S873 >> 14U) & make_uint2 (16383U);
        int2  _S876 = make_int2 ((int)_S875.x, (int)_S875.y);
        ShiftJob _S877 = (ShiftJob{});
        ShiftJob shift_job_0 = _S877;
        Shift _S878 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S879 = _S873 >> 28U;
        bool _S880 = spatialJob_0(_S876, _S879, &shift_job_0, true);
        Shift shifted_1;
        if(_S880)
        {
            Domain _S881 = (&shift_job_0)->dom;
            Reservoir _S882 = (&shift_job_0)->r;
            Shift _S883 = passShift_0(&_S881, &_S882);
            shifted_1 = _S883;
        }
        else
        {
            shifted_1 = _S878;
        }
        fcptStoreShiftData((_S876), (_S879), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S884 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S885 = make_int2 ((int)_S884.x, (int)_S884.y);
    FixedArray<uint, 3>  _S886;
    spatialBins_0(_S885, &_S886);
    FixedArray<uint, 3>  _S887 = _S886;
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
        bool _S888 = (_S887[t_16]) == 40U;
        if(_S888)
        {
            fcptStoreShiftData((_S885), (t_16), (make_uint4 (0U)));
        }
        uint t_17 = t_16 + 1U;
        t_16 = t_17;
    }
    FixedArray<uint, 3>  _S889 = _S887;
    queueShifts_0(_S885, &_S889, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S890 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S891 = make_int2 ((int)_S890.x, (int)_S890.y);
    FixedArray<uint, 3>  _S892;
    spatialBins_0(_S891, &_S892);
    FixedArray<uint, 3>  _S893 = _S892;
    countShifts_0(&_S893, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S894 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S895 = _S894 != 4294967295U;
    if(_S895)
    {
        uint2  _S896 = make_uint2 (_S894, _S894 >> 14U) & make_uint2 (16383U);
        int2  _S897 = make_int2 ((int)_S896.x, (int)_S896.y);
        int2  _S898 = (fcptLoadTemporalNeighbor((_S897)));
        uint _S899 = _S894 >> 28U;
        Shift _S900 = temporalShiftAt_0(_S897, _S898, _S899);
        fcptStoreTemporalShift((_S897), (_S899), (make_uint4 (asuint_1(_S900.f).x, asuint_1(_S900.f).y, asuint_1(_S900.f).z, (F32_asuint((_S900.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S901 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S902 = make_int2 ((int)_S901.x, (int)_S901.y);
    FixedArray<uint, 3>  _S903;
    temporalBins_0(_S902, &_S903);
    FixedArray<uint, 3>  _S904 = _S903;
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
        bool _S905 = (_S904[t_18]) == 40U;
        if(_S905)
        {
            fcptStoreTemporalShift((_S902), (t_18), (make_uint4 (0U)));
        }
        uint t_19 = t_18 + 1U;
        t_18 = t_19;
    }
    FixedArray<uint, 3>  _S906 = _S904;
    queueShifts_0(_S902, &_S906, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S907 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S908 = make_int2 ((int)_S907.x, (int)_S907.y);
    bool _S909 = (fcptSceneUnchanged());
    bool _S910 = !_S909;
    bool _S911;
    if(_S910)
    {
        uint2  _S912 = (fcptRenderSize());
        int2  _S913 = make_int2 ((int)_S912.x, (int)_S912.y);
        _S911 = all_0(_S908 < _S913);
    }
    else
    {
        _S911 = false;
    }
    if(_S911)
    {
        Reservoir _S914 = (fcptLoadReservoirInitial((_S908)));
        int2  _S915 = sampleNeighbor_0(_S908, _S914.seed);
        fcptStoreTemporalNeighbor((_S908), (_S915));
    }
    FixedArray<uint, 3>  _S916;
    temporalBins_0(_S908, &_S916);
    FixedArray<uint, 3>  _S917 = _S916;
    countShifts_0(&_S917, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_8, float b_4, float t_20)
{
    return a_8 + (b_4 - a_8) * t_20;
}

__device__ float confidenceCap(float duplicated_0)
{
    float _S918 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S918;
}

__device__ float2  temporalWeights(float c_2, float p_c_1, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S919 = c_2 * p_c_1;
    float _S920 = c_t_0 * p_t_0;
    return make_float2 (_S919 / (_S919 + c_t_0 * g_previous_0), _S920 / (_S920 + c_2 * g_current_0));
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S921 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S922 = make_int2 ((int)_S921.x, (int)_S921.y);
    float3  _S923 = make_float3 (0.0f);
    FKHit _S924 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S925 = Domain_x24init_0(_S923, _S923, &_S924, 0.0f, 0.0f);
    Domain dom_5 = _S925;
    bool _S926 = (fcptCurrentDomain((_S922), (&dom_5)));
    bool _S927 = !_S926;
    if(_S927)
    {
        Reservoir _S928 = (Reservoir{});
        fcptStoreReservoirTemporal((_S922), (_S928), ((&dom_5)->hit));
        return;
    }
    Reservoir _S929 = (fcptLoadReservoirInitial((_S922)));
    bool _S930 = (fcptTemporalQueued());
    bool _S931 = (fcptSceneUnchanged());
    bool _S932;
    if(_S931)
    {
        _S932 = true;
    }
    else
    {
        _S932 = !_S930;
    }
    int2  _S933;
    if(_S932)
    {
        int2  _S934 = sampleNeighbor_0(_S922, _S929.seed);
        _S933 = _S934;
    }
    else
    {
        int2  _S935 = (fcptLoadTemporalNeighbor((_S922)));
        _S933 = _S935;
    }
    bool _S936 = (_S933.x) >= int(0);
    Reservoir r_5;
    if(_S936)
    {
        Reservoir _S937 = (fcptLoadReservoirPrevious((_S933)));
        uint4  _S938 = (fcptDuplication((_S933)));
        float _S939 = (U32_asfloat((_S938.x)));
        uint _S940 = (fcptRestirDecorrelation());
        bool _S941 = _S940 == 1U;
        float _S942 = _slang_select(_S941, _S939,0.0f);
        float _S943 = confidenceCap(_S942);
        float _S944 = (F32_min((_S937.c), (_S943)));
        bool _S945 = (fcptSceneUnchanged());
        float4  _S946 = make_float4 (_S937.f.x, _S937.f.y, _S937.f.z, 1.0f);
        bool _S947 = !_S945;
        if(_S947)
        {
            _S932 = _S930;
        }
        else
        {
            _S932 = false;
        }
        float4  to_current_0;
        if(_S932)
        {
            uint4  _S948 = (fcptTemporalShift((_S922), (0U)));
            float4  _S949 = asfloat_0(_S948);
            to_current_0 = _S949;
        }
        else
        {
            if(_S947)
            {
                Shift _S950 = temporalShiftAt_0(_S922, _S933, 0U);
                float4  _S951 = make_float4 (_S950.f.x, _S950.f.y, _S950.f.z, _S950.jac);
                to_current_0 = _S951;
            }
            else
            {
                to_current_0 = _S946;
            }
        }
        Domain own_1 = _S925;
        if(_S945)
        {
            _S932 = true;
        }
        else
        {
            bool _S952 = (fcptPreviousScenes());
            bool _S953 = !_S952;
            if(_S953)
            {
                _S932 = (_S929.w) > 0.0f;
            }
            else
            {
                _S932 = false;
            }
            if(_S932)
            {
                bool _S954 = (fcptStoredDomainInitial((_S922), (_S929.seed), (&own_1)));
                _S932 = _S954;
            }
            else
            {
                _S932 = false;
            }
            if(_S932)
            {
                Domain _S955 = (fcptPreviousDomain((_S933), (_S929.seed)));
                Domain _S956 = _S955;
                Domain _S957 = own_1;
                bool _S958 = sameDomain_0(&_S956, &_S957);
                _S932 = _S958;
            }
            else
            {
                _S932 = false;
            }
        }
        float4  _S959 = make_float4 (_S929.f.x, _S929.f.y, _S929.f.z, 1.0f);
        bool _S960 = !_S932;
        if(_S960)
        {
            _S932 = _S930;
        }
        else
        {
            _S932 = false;
        }
        float4  to_previous_0;
        if(_S932)
        {
            uint4  _S961 = (fcptTemporalShift((_S922), (1U)));
            float4  _S962 = asfloat_0(_S961);
            to_previous_0 = _S962;
        }
        else
        {
            if(_S960)
            {
                Shift _S963 = temporalShiftAt_0(_S922, _S933, 1U);
                float4  _S964 = make_float4 (_S963.f.x, _S963.f.y, _S963.f.z, _S963.jac);
                to_previous_0 = _S964;
            }
            else
            {
                to_previous_0 = _S959;
            }
        }
        float _S965 = resamplingTarget(_S929.f);
        float _S966 = resamplingTarget(_S937.f);
        Selection _S967 = (Selection{});
        Selection sel_6 = _S967;
        uint _S968 = (fcptFrame());
        uint _S969 = hash(_S968);
        uint _S970 = global_invocation_id_7.x;
        uint2  _S971 = (fcptRenderSize());
        uint _S972 = stream(_S969, _S970 + _S971.x * global_invocation_id_7.y);
        uint _S973 = stream(_S972, 194U);
        (&sel_6)->random_state = _S973;
        float4  _S974 = to_previous_0;
        float _S975 = resamplingTarget(float3 {_S974.x, _S974.y, _S974.z});
        float4  _S976 = to_current_0;
        float3  _S977 = float3 {_S976.x, _S976.y, _S976.z};
        float _S978 = resamplingTarget(_S977);
        float2  _S979 = temporalWeights(_S929.c, _S965, _S944, _S966, _S975, _S978);
        offerShifted(&sel_6, _S929, Shift_x24init_0(_S929.f, 1.0f), _S979.x);
        offerShifted(&sel_6, _S937, Shift_x24init_0(_S977, to_current_0.w), _S979.y);
        Reservoir _S980 = finalize(sel_6, _S929.c + _S944);
        r_5 = _S980;
    }
    else
    {
        r_5 = _S929;
    }
    fcptStoreReservoirTemporal((_S922), (r_5), ((&dom_5)->hit));
    return;
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S981 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S982 = make_int2 ((int)_S981.x, (int)_S981.y);
    float3  _S983 = make_float3 (0.0f);
    float2  _S984 = make_float2 (0.0f);
    FKHit _S985 = Hit_x24init_0(_S984, 0U, 0U, 0U, 0.0f);
    Domain _S986 = Domain_x24init_0(_S983, _S983, &_S985, 0.0f, 0.0f);
    Domain dom_6 = _S986;
    bool _S987 = (fcptCurrentDomain((_S982), (&dom_6)));
    bool _S988 = !_S987;
    if(_S988)
    {
        Reservoir _S989 = (Reservoir{});
        fcptStoreReservoirInitial((_S982), (_S989), ((&dom_6)->hit));
        return;
    }
    uint _S990 = (fcptFrame());
    uint _S991 = hash(_S990);
    uint _S992 = global_invocation_id_8.x;
    uint2  _S993 = (fcptRenderSize());
    uint _S994 = stream(_S991, _S992 + _S993.x * global_invocation_id_8.y);
    Selection _S995 = (Selection{});
    Selection initial_0 = _S995;
    uint _S996 = stream(_S994, 193U);
    (&initial_0)->random_state = _S996;
    bool _S997 = (fcptRestirUsed());
    bool _S998 = !_S997;
    (&initial_0)->sums = _S998;
    uint _S999 = stream(_S994, 0U);
    (&(&initial_0)->r)->seed = _S999;
    FKHit _S1000 = Hit_x24init_0(_S984, 4294967295U, 0U, 0U, 0.0f);
    uint _S1001 = (fcptSamples());
    float _S1002 = 1.0f / float(_S1001);
    FKHit hit_2 = _S1000;
    uint i_15 = 0U;
    float3  seen_0 = _S983;
    for(;;)
    {
        uint _S1003 = (fcptSamples());
        if(i_15 < _S1003)
        {
        }
        else
        {
            break;
        }
        Reservoir _S1004 = (Reservoir{});
        Reservoir r_6 = _S1004;
        uint _S1005 = stream(_S994, i_15);
        (&r_6)->seed = _S1005;
        Domain path_0 = _S986;
        bool _S1006 = (fcptStoredDomainInitial((_S982), ((&r_6)->seed), (&path_0)));
        bool _S1007 = !_S1006;
        if(_S1007)
        {
            float3  _S1008 = (fcptMissed((_S982), (path_0), (_S1002)));
            float3  seen_1 = seen_0 + _S1008;
            seen_0 = seen_1;
            uint i_16 = i_15 + 1U;
            i_15 = i_16;
            continue;
        }
        Domain _S1009 = path_0;
        Reservoir _S1010 = r_6;
        Shift _S1011 = passWalk_0(&_S1009, &_S1010, false, _S1002, &initial_0);
        bool _S1012 = ((&(&initial_0)->r)->seed) == ((&r_6)->seed);
        FKHit hit_3;
        if(_S1012)
        {
            FKHit _S1013 = (&path_0)->hit;
            hit_3 = _S1013;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_16 = i_15 + 1U;
        i_15 = i_16;
    }
    uint _S1014 = (fcptSamples());
    float3  seen_2 = seen_0 + (&initial_0)->glow / make_float3 (float(_S1014));
    if((&initial_0)->sums)
    {
        seen_0 = seen_2 + (&initial_0)->color;
    }
    else
    {
        seen_0 = seen_2;
    }
    fcptAddColor((_S982), (make_float4 (seen_0.x, seen_0.y, seen_0.z, 1.0f)));
    Reservoir _S1015 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S982), (_S1015), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_5, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S1016;
    (&_S1016)->none = none_0;
    (&_S1016)->pdf = pdf_5;
    (&_S1016)->origin = origin_5;
    (&_S1016)->smooth_n = smooth_n_3;
    (&_S1016)->start = start_6;
    return _S1016;
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
    Vertex _S1017;
    (&_S1017)->rough = rough_0;
    (&_S1017)->lobe = lobe_1;
    (&_S1017)->pdf = pdf_6;
    (&_S1017)->cos = cos_0;
    (&_S1017)->inside = inside_0;
    return _S1017;
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
    float3  _S1018 = exp_0((make_float3 (sigma_1) - extinction_0) * make_float3 (distance_2));
    float3  _S1019 = scatter_0 * _S1018 / make_float3 (sigma_1);
    float3  _S1020 = _slang_select(scatters_0, _S1019,_S1018);
    return _S1020;
}

static __device__ bool scatterSampled_0(bool replay_1, uint b_5, uint stop_0, bool varying_0)
{
    bool _S1021 = !replay_1;
    bool _S1022;
    if(_S1021)
    {
        _S1022 = true;
    }
    else
    {
        bool _S1023 = b_5 == stop_0;
        if(_S1023)
        {
            _S1022 = !varying_0;
        }
        else
        {
            _S1022 = false;
        }
    }
    return _S1022;
}

static __device__ uint arrivalLobe_0(uint b_6, uint prev_lobe_0)
{
    bool _S1024 = b_6 > 0U;
    uint _S1025 = _slang_select(_S1024, prev_lobe_0,3U);
    return _S1025;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_2, bool surface_4, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S1026;
    (&_S1026)->extinction_behind = extinction_behind_0;
    (&_S1026)->extinction_front = extinction_front_0;
    (&_S1026)->fillings = fillings_0;
    (&_S1026)->side = side_0;
    (&_S1026)->depth = depth_1;
    (&_S1026)->lobe = lobe_2;
    (&_S1026)->surface = surface_4;
    (&_S1026)->length = length_2;
    (&_S1026)->width = width_1;
    (&_S1026)->own = *own_2;
    (&_S1026)->fiber = fiber_0;
    return _S1026;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S1027 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S1027)
    {
        return 0.07957746833562851f;
    }
    float _S1028 = g_0 * g_0;
    return (1.0f - _S1028) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S1028 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_9, float3  b_7)
{
    float3  _S1029 = a_9 / b_7;
    float3  _S1030 = make_float3 (0.0f);
    bool3  _S1031 = b_7 == _S1030;
    float3  _S1032 = _slang_select(_S1031, _S1030,_S1029);
    return _S1032;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_6)
{
    uint _S1033 = (1U << count_6) - 1U;
    return (e_2 & (~(_S1033 << offset_1))) | ((newbits_0 & _S1033) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_7, uint end_type_0, uint end_0, float3  f_6)
{
    Reservoir candidate_2 = r_7;
    uint _S1034 = insertBits_0(r_7.path, end_0, 0U, 5U);
    uint _S1035 = insertBits_0(_S1034, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S1035;
    (&candidate_2)->f = f_6;
    return candidate_2;
}

__device__ float survivalProbability(float3  throughput_2, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_2.x), ((F32_max((throughput_2.y), (throughput_2.z)))))) / density_1), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_9)
{
    Random _S1036 = pcg(random_state_9);
    Random _S1037 = pcg(_S1036.state);
    float _S1038 = 1.0f - 2.0f * _S1036.value;
    float _S1039 = (F32_sqrt(((F32_max((1.0f - _S1038 * _S1038), (0.0f))))));
    float _S1040 = 6.28318548202514648f * _S1037.value;
    return make_float3 (_S1039 * (F32_cos((_S1040))), _S1039 * (F32_sin((_S1040))), _S1038);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_10, uint random_state_10, float * pdf_7)
{
    bool _S1041 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1041)
    {
        *pdf_7 = 0.07957746833562851f;
        float3  _S1042 = isotropic_0(random_state_10);
        return _S1042;
    }
    Random _S1043 = pcg(random_state_10);
    Random _S1044 = pcg(_S1043.state);
    float _S1045 = g_1 * g_1;
    float _S1046 = 2.0f * g_1;
    float _S1047 = (1.0f - _S1045) / (1.0f - g_1 + _S1046 * _S1043.value);
    float _S1048 = clamp_1((1.0f + _S1045 - _S1047 * _S1047) / _S1046, -1.0f, 1.0f);
    float _S1049 = (F32_sqrt(((F32_max((1.0f - _S1048 * _S1048), (0.0f))))));
    float _S1050 = 6.28318548202514648f * _S1044.value;
    float _S1051 = phaseHG_0(g_1, _S1048);
    *pdf_7 = _S1051;
    float3  _S1052 = tangentToWorld(make_float3 (_S1049 * (F32_cos((_S1050))), _S1048, _S1049 * (F32_sin((_S1050)))), dir_10);
    float3  _S1053 = ((((_S1052)) * make_float3(rnorm3df(((_S1052)).x, ((_S1052)).y, ((_S1052)).z))));
    return _S1053;
}

static __device__ Vertex scatteredVertex_0(bool is_inside_4)
{
    return Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_4);
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_0, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_3, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2, float velvet_0, float3  toon_3, float dispersion_0)
{
    BSDFMaterial _S1054;
    (&_S1054)->albedo = albedo_0;
    (&_S1054)->emissive = emissive_0;
    (&_S1054)->roughness = roughness_0;
    (&_S1054)->metallic = metallic_0;
    (&_S1054)->transmission = transmission_0;
    (&_S1054)->ior = ior_0;
    (&_S1054)->absorption = absorption_0;
    (&_S1054)->specular_tint = specular_tint_0;
    (&_S1054)->specular_level = specular_level_0;
    (&_S1054)->translucent = translucent_0;
    (&_S1054)->sheen = sheen_3;
    (&_S1054)->sheen_roughness = sheen_roughness_0;
    (&_S1054)->anisotropy = anisotropy_0;
    (&_S1054)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1054)->tangent = tangent_2;
    (&_S1054)->velvet = velvet_0;
    (&_S1054)->toon = toon_3;
    (&_S1054)->dispersion = dispersion_0;
    return _S1054;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1055;
    (&_S1055)->scatter = scatter_1;
    (&_S1055)->extinction = extinction_1;
    (&_S1055)->g = g_2;
    return _S1055;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_13, bool skip_0, uint random_state_11, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1056;
    (&_S1056)->smooth_n = smooth_n_4;
    (&_S1056)->geometry_n = geometry_n_2;
    (&_S1056)->geometry_offset = geometry_offset_2;
    (&_S1056)->material = *material_13;
    (&_S1056)->skip = skip_0;
    (&_S1056)->random_state = random_state_11;
    (&_S1056)->coverage = coverage_0;
    (&_S1056)->encloses = encloses_0;
    (&_S1056)->volume = *volume_0;
    (&_S1056)->fills = fills_0;
    (&_S1056)->hair = hair_0;
    return _S1056;
}

static __device__ FKSurface emitting_0(FKSurface * surface_5, bool top_0)
{
    FKSurface lower_0 = *surface_5;
    float3  _S1057 = (&surface_5->material)->emissive;
    float3  _S1058 = make_float3 (0.0f);
    bool _S1059 = !top_0;
    float3  _S1060 = _slang_select(_S1059, _S1058,_S1057);
    (&(&lower_0)->material)->emissive = _S1060;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_6, float u_2)
{
    float _S1061 = surface_6->coverage;
    bool _S1062 = u_2 < _S1061;
    if(_S1062)
    {
        return *surface_6;
    }
    float3  _S1063 = make_float3 (0.0f);
    float3  _S1064 = make_float3 (1.0f);
    BSDFMaterial _S1065 = Material_x24init_0(_S1063, _S1063, 0.0f, 0.0f, 0.0f, 0.0f, _S1063, _S1064, 1.0f, _S1063, _S1063, 0.5f, 0.0f, 0.0f, _S1063, 0.0f, _S1063, 0.0f);
    BSDFMaterial material_14 = _S1065;
    (&material_14)->albedo = _S1064;
    (&material_14)->emissive = (&surface_6->material)->emissive;
    (&material_14)->transmission = 1.0f;
    (&material_14)->ior = 1.0f;
    (&material_14)->absorption = (&surface_6->material)->absorption;
    FKSurface through_0 = *surface_6;
    (&through_0)->material = material_14;
    return through_0;
}

__device__ float facingSign(float transmission_1, float3  face_0, float3  direction_0)
{
    bool _S1066 = transmission_1 > 0.0f;
    bool _S1067;
    if(_S1066)
    {
        _S1067 = true;
    }
    else
    {
        _S1067 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1068;
    if(_S1067)
    {
        _S1068 = 1.0f;
    }
    else
    {
        _S1068 = -1.0f;
    }
    return _S1068;
}

static __device__ bool arrivesBehind_0(float3  dir_11, float3  n_11)
{
    return (dot_0(dir_11, n_11)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_7, float3  dir_12)
{
    float3  _S1069 = surface_7->geometry_n;
    float _S1070 = facingSign((&surface_7->material)->transmission, surface_7->geometry_n, dir_12);
    FKSurface faced_0 = *surface_7;
    float3  _S1071 = surface_7->smooth_n * make_float3 (_S1070);
    (&faced_0)->smooth_n = _S1071;
    float3  _S1072 = _S1069 * make_float3 (_S1070);
    (&faced_0)->geometry_n = _S1072;
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
    float3  _S1073 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1073));
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
    bool _S1074;
    if(open_0)
    {
        _S1074 = prev_rough_0;
    }
    else
    {
        _S1074 = false;
    }
    if(_S1074)
    {
        _S1074 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S1074 = false;
    }
    return _S1074;
}

__device__ bool dispersive(BSDFMaterial material_15)
{
    bool _S1075 = (material_15.dispersion) > 0.0f;
    bool _S1076;
    if(_S1075)
    {
        _S1076 = (material_15.ior) != 1.0f;
    }
    else
    {
        _S1076 = false;
    }
    return _S1076;
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
        uint _S1077 = (low_1 + high_1 + 1U) / 2U;
        bool _S1078 = (WAVELENGTH_CDF_0[_S1077]) <= u_3;
        if(_S1078)
        {
            low_1 = _S1077;
        }
        else
        {
            uint _S1079 = _S1077 - 1U;
            high_1 = _S1079;
        }
    }
    uint _S1080 = low_1;
    float _S1081 = WAVELENGTH_CDF_0[low_1 + 1U] - WAVELENGTH_CDF_0[low_1];
    return make_float2 (0.37999999523162842f + 0.00499999988824129f * (float(low_1) + (u_3 - WAVELENGTH_CDF_0[_S1080]) / _S1081), _S1081 / 0.00499999988824129f);
}

__device__ static const FixedArray<float, 243>  WAVELENGTH_WEIGHTS_0 = { {
    0.00547470012679696f, -0.00465690018609166f, 0.03257500007748604f, 0.00934640038758516f, -0.00796370021998882f, 0.05577300116419792f, 0.01846100017428398f, -0.01579399965703487f, 0.11072999984025955f, 0.0416410006582737f, -0.03577499836683273f, 0.2513900101184845f, 0.09349299967288971f, -0.08071800321340561f, 0.56742000579833984f, 0.1585099995136261f, -0.13764999806880951f, 0.97018998861312866f, 0.30943000316619873f, -0.27083000540733337f, 1.91740000247955322f, 0.55217999219894409f, -0.48754000663757324f, 3.46889996528625488f, 0.95016998052597046f, -0.84802001714706421f, 6.09439992904663086f, 1.42110002040863037f, -1.28929996490478516f, 9.45199966430664062f, 1.73409998416900635f, -1.6062999963760376f, 12.12800025939941406f, 2.08030009269714355f, -1.98810005187988281f, 15.68700027465820312f, 2.20600008964538574f, -2.20120000839233398f, 18.47699928283691406f, 2.03040003776550293f, -2.17700004577636719f, 19.92700004577636719f, 1.63429999351501465f, -2.00340008735656738f, 20.86899948120117188f, 0.99410998821258545f, -1.62629997730255127f, 20.57799911499023438f, 0.20011000335216522f, -1.11409997940063477f, 19.72100067138671875f, -0.67960000038146973f, -0.45403000712394714f, 17.77599906921386719f, -1.61679995059967041f, 0.37860000133514404f, 14.71500015258789062f, -2.53410005569458008f, 1.27540004253387451f, 11.86499977111816406f, -3.39079999923706055f, 2.2146000862121582f, 9.17669963836669922f, -4.03749990463256836f, 3.0522000789642334f, 6.59509992599487305f, -4.61299991607666016f, 3.89779996871948242f, 4.64589977264404297f, -5.43039989471435547f, 5.0121002197265625f, 3.3199000358581543f, -6.37769985198974609f, 6.33809995651245117f, 2.29699993133544922f, -7.44140005111694336f, 7.91739988327026367f, 1.45389997959136963f, -8.38580036163330078f, 9.60109996795654297f, 0.66465997695922852f, -9.0167999267578125f, 11.23999977111816406f, -0.04403600096702576f, -9.17749977111816406f, 12.63199996948242188f, -0.58126997947692871f, -8.97550010681152344f, 13.91499996185302734f, -0.95730000734329224f, -8.25290012359619141f, 14.86200046539306641f, -1.24430000782012939f, -6.92129993438720703f, 15.03899955749511719f, -1.43069994449615479f, -5.29169988632202148f, 14.90900039672851562f, -1.55149996280670166f, -3.43219995498657227f, 14.70499992370605469f, -1.63569998741149902f, -1.27190005779266357f, 14.24400043487548828f, -1.67030000686645508f, 1.15170001983642578f, 13.32199954986572266f, -1.636199951171875f, 3.73889994621276855f, 12.21199989318847656f, -1.56920003890991211f, 6.43590021133422852f, 10.94699954986572266f, -1.47730004787445068f, 9.16440010070800781f, 9.54769992828369141f, -1.36399996280670166f, 12.02000045776367188f, 8.18799972534179688f, -1.25450003147125244f, 14.78699970245361328f, 6.74429988861083984f, -1.13110005855560303f, 16.72299957275390625f, 5.08780002593994141f, -0.96561002731323242f, 18.14299964904785156f, 3.57019996643066406f, -0.80725997686386108f, 19.91900062561035156f, 2.36269998550415039f, -0.69273000955581665f, 21.05500030517578125f, 1.31369996070861816f, -0.58597999811172485f, 21.3899993896484375f, 0.42390000820159912f, -0.48298001289367676f, 20.99300003051757812f, -0.23857000470161438f, -0.39412000775337219f, 19.82200050354003906f, -0.6866300106048584f, -0.31501999497413635f, 18.12000083923339844f, -0.9412500262260437f, -0.24890999495983124f, 15.7089996337890625f, -1.02020001411437988f, -0.19076000154018402f, 13.19799995422363281f, -0.98919999599456787f, -0.14401000738143921f, 11.23999977111816406f, -0.93347001075744629f, -0.11133000254631042f, 9.36649990081787109f, -0.83820998668670654f, -0.08524099737405777f, 7.41249990463256836f, -0.70064002275466919f, -0.06283199787139893f, 5.71229982376098633f, -0.56079000234603882f, -0.04586699977517128f, 4.42280006408691406f, -0.44653001427650452f, -0.03396600112318993f, 3.34489989280700684f, -0.34457001090049744f, -0.02482499927282333f, 2.49309992790222168f, -0.26017999649047852f, -0.01808100007474422f, 1.82239997386932373f, -0.1921599954366684f, -0.01296999957412481f, 1.29499995708465576f, -0.13766999542713165f, -0.00907570030540228f, 0.92928999662399292f, -0.09956400096416473f, -0.00641620019450784f, 0.61835998296737671f, -0.06671299785375595f, -0.00421149982139468f, 0.40211999416351318f, -0.04354599863290787f, -0.00271830009296536f, 0.2844499945640564f, -0.03087200038135052f, -0.00191440002527088f, 0.20672999322414398f, -0.02246100082993507f, -0.00138829997740686f, 0.15044000744819641f, -0.01634499989449978f, -0.00101030000951141f, 0.10942000150680542f, -0.01188699994236231f, -0.0007347899954766f, 0.07099699974060059f, -0.00771349994465709f, -0.00047679000999779f, 0.04539500176906586f, -0.00493190018460155f, -0.00030484999297187f, 0.03424099832773209f, -0.00372010003775358f, -0.00022995000472292f, 0.02557599917054176f, -0.00277870008721948f, -0.00017175999528263f, 0.01842200011014938f, -0.00200140010565519f, -0.0001237099932041f, 0.01316899992525578f, -0.00143079995177686f, -0.00008843900286593f, 0.00838890019804239f, -0.00091141002485529f, -0.00005633700129692f, 0.00537079991772771f, -0.00058350997278467f, -0.00003606799873523f, 0.00328280008397996f, -0.00035665999166667f, -0.00002204600059486f, 0.00196009990759194f, -0.00021296000340953f, -0.00001316300040344f, 0.00168939994182438f, -0.00018354000349063f, -0.00001134499962063f, 0.00141050003003329f, -0.00015325000276789f, -0.00000947250009631f, 0.00097123999148607f, -0.00010551999730524f, -6.52239987175562419e-06f, 0.00066868000430986f, -0.00007264900341397f, -4.49060007667867467e-06f
} };
__device__ float3  wavelengthWeights(float wavelength_0)
{
    float _S1082 = clamp_1((wavelength_0 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    uint _S1083 = (U32_min((uint(_S1082)), (79U)));
    uint _S1084 = 3U * _S1083;
    float3  _S1085 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1084], WAVELENGTH_WEIGHTS_0[_S1084 + 1U], WAVELENGTH_WEIGHTS_0[_S1084 + 2U]);
    float3  _S1086 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1084 + 3U], WAVELENGTH_WEIGHTS_0[_S1084 + 4U], WAVELENGTH_WEIGHTS_0[_S1084 + 5U]);
    return _S1085 + (_S1086 - _S1085) * make_float3 (_S1082 - float(_S1083));
}

__device__ float dispersedIor(float ior_1, float dispersion_1, float wavelength_1)
{
    float _S1087 = (ior_1 - 1.0f) * dispersion_1 / 1.90962409973144531f;
    float _S1088 = _S1087 * (1.0f / (wavelength_1 * wavelength_1) - 2.89662933349609375f);
    bool _S1089 = dispersion_1 > 0.0f;
    float _S1090 = _slang_select(_S1089, _S1088,0.0f);
    return ior_1 + _S1090;
}

__device__ float2  vertexEta(BSDFMaterial material_16, float n_dot_v_0)
{
    bool _S1091 = n_dot_v_0 < 0.0f;
    float _S1092 = _slang_select(_S1091, material_16.ior,1.0f);
    float _S1093 = _slang_select(_S1091, 1.0f,material_16.ior);
    return make_float2 (_S1092, _S1093);
}

__device__ bool neeDecision(BSDFMaterial material_17, float n_dot_v_1, float eta_i_11, float eta_o_11)
{
    float _S1094 = fresnel((F32_abs((n_dot_v_1))), eta_i_11, eta_o_11);
    float3  _S1095 = mix_0(make_float3 (_S1094), material_17.albedo, material_17.metallic);
    float _S1096 = rgb_to_greyscale(_S1095);
    float _S1097 = (F32_max(((1.0f - _S1096) * (1.0f - material_17.metallic) * (1.0f - material_17.transmission)), (0.0f)));
    bool _S1098 = _S1097 > 0.03999999910593033f;
    bool _S1099;
    if(_S1098)
    {
        _S1099 = true;
    }
    else
    {
        _S1099 = (material_17.roughness) > 0.20000000298023224f;
    }
    return _S1099;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_18)
{
    float _S1100 = rgb_to_greyscale(material_18->translucent);
    return _S1100 > 0.0f;
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
    MediumSides _S1101;
    (&_S1101)->behind = *behind_0;
    (&_S1101)->front = *front_0;
    (&_S1101)->fillings = fillings_1;
    (&_S1101)->face = face_1;
    return _S1101;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_8, FKMedium * medium_0, uint filling_0, float3  dir_13, FKMedium * outside_0)
{
    float3  _S1102 = surface_8->geometry_n;
    MediumSides _S1103 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_8->geometry_n);
    MediumSides sides_0 = _S1103;
    bool _S1104 = surface_8->encloses;
    if(_S1104)
    {
        (&sides_0)->behind = surface_8->volume;
        *&((&(&sides_0)->fillings)->x) = surface_8->fills;
        bool _S1105 = (dot_0(dir_13, _S1102)) > 0.0f;
        if(_S1105)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_9, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_14, uint depth_2, uint lobe_3, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1106 = surface_9->geometry_n;
    ShadowContext _S1107 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_9->geometry_n, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
    bool _S1108 = surface_9->encloses;
    ShadowContext context_4;
    if(_S1108)
    {
        FKSurface faced_1 = *surface_9;
        float3  _S1109 = - _S1106;
        float3  _S1110 = _slang_select(turned_0, _S1109,_S1106);
        (&faced_1)->geometry_n = _S1110;
        FKMedium _S1111 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1112 = faced_1;
        FKMedium _S1113 = _S1111;
        MediumSides _S1114 = mediumSides_0(&_S1112, &_S1113, filling_1, dir_14, outside_1);
        ShadowContext _S1115 = ShadowContext_x24init_0(_S1114.behind.extinction, _S1114.front.extinction, _S1114.fillings, _S1106, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
        if(turned_0)
        {
            uint2  _S1116 = _S1114.fillings;
            ShadowContext _S1117 = ShadowContext_x24init_0(_S1114.front.extinction, _S1114.behind.extinction, uint2 {_S1116.y, _S1116.x}, _S1106, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
            context_4 = _S1117;
        }
        else
        {
            context_4 = _S1115;
        }
    }
    else
    {
        context_4 = _S1107;
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

__device__ __forceinline__ float3  BSDF(float3  in_dir_9, float3  out_dir_2, float3  n_12, float3  g_n_0, BSDFMaterial material_19, float eta_i_12, float eta_o_12, uint random_state_12, MaterialTerms terms_4, ViewTerms view_terms_4)
{
    float3  _S1118 = negate_0(in_dir_9);
    float _S1119 = dot_0(n_12, _S1118);
    float _S1120 = sign_0(_S1119);
    float3  _S1121 = n_12 * make_float3 (_S1120);
    float _S1122 = dot_0(_S1121, out_dir_2);
    float _S1123 = material_19.roughness;
    float _S1124 = _S1123 * _S1123;
    bool _S1125 = (dot_0(g_n_0, _S1118) * dot_0(g_n_0, out_dir_2)) > 0.0f;
    uint _S1126;
    if((F32_abs((material_19.toon.x))) > 0.0f)
    {
        _S1126 = 1U;
    }
    else
    {
        _S1126 = 0U;
    }
    if(_S1125)
    {
        _S1126 = 3U + _S1126;
    }
    else
    {
        _S1126 = 1U;
    }
    float3  _S1127 = make_float3 (0.0f);
    HalfTerms _S1128 = HalfTerms_x24init_0(0.0f, 0.0f, _S1127, _S1127, 0.0f, 0.0f, _S1127, _S1127, 0.0f, 0.0f, 0.0f, 0.0f, _S1127, 0.0f, _S1127, _S1127, make_float2 (0.0f), 0.0f, 0.0f, _S1127, 0.0f, 0.0f, 0.0f, false, 1.0f, 0.0f, _S1127);
    uint half_of_2 = 4294967295U;
    HalfTerms lobe_terms_2 = _S1128;
    float3  ggx_n_3 = _S1127;
    float3  f_7 = _S1127;
    uint i_21 = 0U;
    for(;;)
    {
        if(i_21 < _S1126)
        {
        }
        else
        {
            break;
        }
        uint _S1129;
        if(!_S1125)
        {
            _S1129 = 1U;
        }
        else
        {
            if(i_21 == 0U)
            {
                _S1129 = 0U;
            }
            else
            {
                if(i_21 == 1U)
                {
                    _S1129 = 2U;
                }
                else
                {
                    if(i_21 == 2U)
                    {
                        _S1129 = 4U;
                    }
                    else
                    {
                        _S1129 = 6U;
                    }
                }
            }
        }
        uint _S1130;
        if(_S1129 == 6U)
        {
            _S1130 = 0U;
        }
        else
        {
            if(_S1129 == 4U)
            {
                _S1130 = 2U;
            }
            else
            {
                _S1130 = _S1129;
            }
        }
        bool _S1131 = _S1130 != half_of_2;
        float3  ggx_n_4;
        if(_S1131)
        {
            bool _S1132 = _S1130 == 0U;
            if(_S1132)
            {
                float3  _S1133 = sampledHalf(in_dir_9, n_12, material_19, random_state_12, view_terms_4);
                ggx_n_4 = _S1133;
            }
            else
            {
                bool _S1134 = _S1130 == 1U;
                if(_S1134)
                {
                    float3  _S1135 = refractedHalf(in_dir_9, out_dir_2, n_12, eta_i_12, eta_o_12);
                    ggx_n_4 = _S1135;
                }
                else
                {
                    float3  _S1136 = reflectedHalf(in_dir_9, out_dir_2);
                    ggx_n_4 = _S1136;
                }
            }
            HalfTerms _S1137 = precomputeHalf(in_dir_9, ggx_n_4, material_19, eta_i_12, eta_o_12, terms_4, view_terms_4);
            lobe_terms_2 = _S1137;
            half_of_2 = _S1130;
        }
        else
        {
            ggx_n_4 = ggx_n_3;
        }
        float3  throughput_3;
        float pdf_8;
        switch(_S1129)
        {
        case 0U:
            {
                float _S1138 = diffusePDF(_S1122, 0.0f, (F32_abs((_S1119))), _S1124, lobe_terms_2, eta_i_12, eta_o_12);
                float3  _S1139 = diffuseBSDF(out_dir_2, _S1121, _S1124, material_19, lobe_terms_2);
                pdf_8 = _S1138;
                throughput_3 = _S1139;
                break;
            }
        case 1U:
            {
                float _S1140 = refractPDF(_S1122, dot_0(out_dir_2, ggx_n_4), (F32_abs((_S1119))), _S1124, lobe_terms_2, eta_i_12, eta_o_12);
                float3  _S1141 = refractBSDF(out_dir_2, _S1121, _S1124, material_19, lobe_terms_2);
                pdf_8 = _S1140;
                throughput_3 = _S1141;
                break;
            }
        case 4U:
            {
                float _S1142 = sheenVelvetPDF(_S1122, 0.0f, (F32_abs((_S1119))), _S1124, lobe_terms_2, eta_i_12, eta_o_12);
                float3  _S1143 = sheenVelvetBSDF(out_dir_2, _S1121, _S1124, material_19, lobe_terms_2);
                pdf_8 = _S1142;
                throughput_3 = _S1143;
                break;
            }
        case 6U:
            {
                float _S1144 = toonPDF(_S1122, dot_0(out_dir_2, lobe_terms_2.toon_axis), (F32_abs((_S1119))), _S1124, lobe_terms_2, eta_i_12, eta_o_12);
                float3  _S1145 = toonBSDF(out_dir_2, _S1121, _S1124, material_19, lobe_terms_2);
                pdf_8 = _S1144;
                throughput_3 = _S1145;
                break;
            }
        default:
            {
                float _S1146 = reflectPDF(_S1122, 0.0f, (F32_abs((_S1119))), _S1124, lobe_terms_2, eta_i_12, eta_o_12);
                float3  _S1147 = reflectBSDF(out_dir_2, _S1121, _S1124, material_19, lobe_terms_2);
                pdf_8 = _S1146;
                throughput_3 = _S1147;
                break;
            }
        }
        float3  _S1148;
        if(pdf_8 > 0.0f)
        {
            _S1148 = throughput_3 * make_float3 (pdf_8);
        }
        else
        {
            _S1148 = _S1127;
        }
        if(i_21 == 0U)
        {
            f_7 = _S1148;
        }
        else
        {
            f_7 = f_7 + _S1148;
        }
        uint i_22 = i_21 + 1U;
        ggx_n_3 = ggx_n_4;
        i_21 = i_22;
    }
    return f_7;
}

__device__ float3  translucentCorrection(float3  in_dir_10, float3  out_dir_3, float3  n_13, float3  g_n_1, BSDFMaterial material_20, float eta_i_13, float eta_o_13, uint random_state_13, MaterialTerms terms_5, ViewTerms view_terms_5)
{
    float _S1149 = dot_0(n_13, out_dir_3);
    float3  _S1150 = negate_0(in_dir_10);
    bool _S1151 = (_S1149 * dot_0(n_13, _S1150)) < 0.0f;
    float3  _S1152 = negate_0(in_dir_10);
    float _S1153 = dot_0(n_13, _S1152);
    float _S1154 = sign_0(_S1153);
    float3  _S1155 = n_13 * make_float3 (_S1154);
    float _S1156 = material_20.roughness;
    float _S1157 = _S1156 * _S1156;
    float3  _S1158 = sampledHalf(in_dir_10, n_13, material_20, random_state_13, view_terms_5);
    HalfTerms _S1159 = precomputeHalf(in_dir_10, _S1158, material_20, eta_i_13, eta_o_13, terms_5, view_terms_5);
    float _S1160 = diffusePDF(dot_0(_S1155, out_dir_3), 0.0f, (F32_abs((_S1153))), _S1157, _S1159, eta_i_13, eta_o_13);
    float3  _S1161;
    if(_S1160 > 0.0f)
    {
        float3  _S1162 = diffuseBSDF(out_dir_3, _S1155, _S1157, material_20, _S1159);
        _S1161 = _S1162 * make_float3 (_S1160);
    }
    else
    {
        _S1161 = make_float3 (0.0f);
    }
    float3  _S1163 = negate_0(in_dir_10);
    bool _S1164 = (dot_0(g_n_1, _S1163) * dot_0(g_n_1, out_dir_3)) > 0.0f;
    float3  _S1165 = make_float3 (0.0f);
    float _S1166 = _slang_select(_S1164, -1.0f,1.0f);
    float3  _S1167 = _S1161 * make_float3 (_S1166);
    float3  _S1168 = _slang_select(_S1151, _S1167,_S1165);
    return _S1168;
}

__device__ float3  translucentBSDF(float3  in_dir_11, float3  out_dir_4, float3  n_14, float3  g_n_2, BSDFMaterial material_21, float eta_i_14, float eta_o_14, uint random_state_14)
{
    MaterialTerms _S1169 = precomputeMaterial(material_21, eta_i_14, eta_o_14);
    ViewTerms _S1170 = precomputeView(in_dir_11, n_14, material_21, _S1169);
    float3  _S1171 = BSDF(in_dir_11, out_dir_4, n_14, g_n_2, material_21, eta_i_14, eta_o_14, random_state_14, _S1169, _S1170);
    float3  _S1172 = translucentCorrection(in_dir_11, out_dir_4, n_14, g_n_2, material_21, eta_i_14, eta_o_14, random_state_14, _S1169, _S1170);
    return _S1171 + _S1172;
}

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_12, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_4, BSDFMaterial * material_22, float eta_i_15, float eta_o_15, bool competing_1, uint random_state_15)
{
    bool _S1173 = !competing_1;
    bool _S1174;
    if(_S1173)
    {
        _S1174 = true;
    }
    else
    {
        _S1174 = (light_2->density) == 0.0f;
    }
    if(_S1174)
    {
        bool _S1175 = isTranslucent_0(material_22);
        _S1174 = _S1175;
    }
    else
    {
        _S1174 = false;
    }
    if(_S1174)
    {
        float3  _S1176 = translucentBSDF(in_dir_12, light_2->dir, smooth_n_5, geometry_n_4, *material_22, eta_i_15, eta_o_15, random_state_15);
        return _S1176 * light_2->radiance;
    }
    MaterialTerms _S1177 = precomputeMaterial(*material_22, eta_i_15, eta_o_15);
    ViewTerms _S1178 = precomputeView(in_dir_12, smooth_n_5, *material_22, _S1177);
    if(_S1173)
    {
        _S1174 = true;
    }
    else
    {
        _S1174 = (light_2->density) == 0.0f;
    }
    if(_S1174)
    {
        float3  _S1179 = BSDF(in_dir_12, light_2->dir, smooth_n_5, geometry_n_4, *material_22, eta_i_15, eta_o_15, random_state_15, _S1177, _S1178);
        return _S1179 * light_2->radiance;
    }
    float3  _S1180 = light_2->dir;
    bool _S1181 = (dot_0(geometry_n_4, - in_dir_12) * dot_0(geometry_n_4, light_2->dir)) <= 0.0f;
    float3  _S1182 = neeBSDF(in_dir_12, _S1180, smooth_n_5, *material_22, eta_i_15, eta_o_15, _S1181, light_2->density, true, random_state_15, _S1177, _S1178);
    return _S1182 * light_2->radiance * make_float3 (light_2->density);
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_4, uint random_state_16, bool refracted_4, uint lobe_4, float pdf_9)
{
    SampleBSDF _S1183;
    (&_S1183)->unit_direction = unit_direction_1;
    (&_S1183)->throughput = throughput_4;
    (&_S1183)->random_state = random_state_16;
    (&_S1183)->refracted = refracted_4;
    (&_S1183)->lobe = lobe_4;
    (&_S1183)->pdf = pdf_9;
    return _S1183;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  n_i_8, float n_i_dot_v_6, float alpha_15, BSDFMaterial material_23, HalfTerms lobes_11, float eta_i_16, float eta_o_16, uint random_state_17)
{
    float3  _S1184 = make_float3 (1.0f);
    SampleBSDF _S1185 = SampleBSDF_x24init_0(_S1184, _S1184, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S1185;
    Random _S1186 = pcg(random_state_17);
    Random _S1187 = pcg(_S1186.state);
    (&sample_1)->random_state = _S1187.state;
    float _S1188 = _S1186.value;
    float _S1189 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1188 * _S1188))))));
    float _S1190 = 6.28318548202514648f * _S1187.value;
    float3  _S1191 = tangentToWorld(make_float3 (_S1189 * (F32_cos((_S1190))), _S1186.value, _S1189 * (F32_sin((_S1190)))), n_i_8);
    (&sample_1)->unit_direction = _S1191;
    (&sample_1)->lobe = 4U;
    float3  _S1192 = sheenVelvetBSDF((&sample_1)->unit_direction, n_i_8, alpha_15, material_23, lobes_11);
    (&sample_1)->throughput = _S1192;
    float _S1193 = sheenVelvetPDF(_S1186.value, 0.0f, n_i_dot_v_6, alpha_15, lobes_11, eta_i_16, eta_o_16);
    (&sample_1)->pdf = _S1193;
    return sample_1;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1194 = (F32_sqrt((random_1_0)));
    float _S1195 = 6.28318548202514648f * random_2_0;
    float _S1196 = _S1194 * (F32_cos((_S1195)));
    float _S1197 = _S1194 * (F32_sin((_S1195)));
    float _S1198 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1196 * _S1196 - _S1197 * _S1197))))));
    return make_float3 (_S1196, _S1198, _S1197);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_4, float3  n_i_9, float n_i_dot_v_7, float alpha_16, BSDFMaterial material_24, HalfTerms lobes_12, float eta_i_17, float eta_o_17, uint random_state_18)
{
    float3  _S1199 = make_float3 (1.0f);
    SampleBSDF _S1200 = SampleBSDF_x24init_0(_S1199, _S1199, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S1200;
    Random _S1201 = pcg(random_state_18);
    Random _S1202 = pcg(_S1201.state);
    (&sample_2)->random_state = _S1202.state;
    float3  _S1203 = sampleCosWeightedHemisphere(_S1201.value, _S1202.value);
    bool _S1204 = u_4 < (lobes_12.p_diffuse * lobes_12.translucent_share);
    float _S1205 = _S1203.y;
    float _S1206 = - _S1205;
    float _S1207 = _slang_select(_S1204, _S1206,_S1205);
    float3  _S1208 = tangentToWorld(make_float3 (_S1203.x, _S1207, _S1203.z), n_i_9);
    (&sample_2)->unit_direction = _S1208;
    (&sample_2)->refracted = _S1204;
    (&sample_2)->lobe = 0U;
    float3  _S1209 = diffuseBSDF((&sample_2)->unit_direction, n_i_9, alpha_16, material_24, lobes_12);
    (&sample_2)->throughput = _S1209;
    float _S1210 = diffusePDF(_S1207, 0.0f, n_i_dot_v_7, alpha_16, lobes_12, eta_i_17, eta_o_17);
    (&sample_2)->pdf = _S1210;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF toonSample(float3  n_i_10, float n_i_dot_v_8, float alpha_17, BSDFMaterial material_25, HalfTerms lobes_13, float eta_i_18, float eta_o_18, uint random_state_19)
{
    float3  _S1211 = make_float3 (1.0f);
    SampleBSDF _S1212 = SampleBSDF_x24init_0(_S1211, _S1211, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S1212;
    Random _S1213 = pcg(random_state_19);
    Random _S1214 = pcg(_S1213.state);
    (&sample_3)->random_state = _S1214.state;
    float _S1215 = _S1213.value * lobes_13.toon_norm / 6.28318548202514648f;
    float t_21;
    if(lobes_13.toon_glossy)
    {
        t_21 = (F32_acos((clamp_1(1.0f - _S1215, -1.0f, 1.0f))));
    }
    else
    {
        t_21 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1215)))), (1.0f))))));
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
        float _S1216;
        if(t_21 < (lobes_13.toon_a))
        {
            _S1216 = 1.0f;
        }
        else
        {
            _S1216 = (F32_max((1.0f - (t_21 - lobes_13.toon_a) / (F32_max((lobes_13.toon_s), (0.0000152587890625f)))), (0.0f)));
        }
        float integral_1;
        if(lobes_13.toon_glossy)
        {
            integral_1 = 1.0f - (F32_cos(((F32_min((t_21), (lobes_13.toon_a))))));
        }
        else
        {
            float _S1217 = (F32_sin(((F32_min((t_21), (lobes_13.toon_a))))));
            integral_1 = _S1217 * _S1217 / 2.0f;
        }
        bool _S1218 = t_21 > (lobes_13.toon_a);
        bool _S1219;
        if(_S1218)
        {
            _S1219 = (lobes_13.toon_s) > 0.0f;
        }
        else
        {
            _S1219 = false;
        }
        float integral_2;
        if(_S1219)
        {
            if(lobes_13.toon_glossy)
            {
                float _S1220 = (F32_cos((lobes_13.toon_a)));
                float _S1221 = (F32_cos((t_21)));
                integral_2 = (1.0f + lobes_13.toon_a / lobes_13.toon_s) * (_S1220 - _S1221) - ((F32_sin((t_21))) - t_21 * _S1221 - ((F32_sin((lobes_13.toon_a))) - lobes_13.toon_a * _S1220)) / lobes_13.toon_s;
            }
            else
            {
                float _S1222 = 2.0f * lobes_13.toon_a;
                float _S1223 = (F32_cos((_S1222)));
                float _S1224 = 2.0f * t_21;
                float _S1225 = (F32_cos((_S1224)));
                integral_2 = (1.0f + lobes_13.toon_a / lobes_13.toon_s) * (_S1223 - _S1225) / 4.0f - ((F32_sin((_S1224))) / 8.0f - t_21 * _S1225 / 4.0f - ((F32_sin((_S1222))) / 8.0f - lobes_13.toon_a * _S1223 / 4.0f)) / lobes_13.toon_s;
            }
            float integral_3 = integral_1 + integral_2;
            integral_2 = integral_3;
        }
        else
        {
            integral_2 = integral_1;
        }
        float _S1226 = _S1216 * (F32_sin((t_21)));
        float _S1227;
        if(lobes_13.toon_glossy)
        {
            _S1227 = 1.0f;
        }
        else
        {
            _S1227 = (F32_cos((t_21)));
        }
        float _S1228 = _S1226 * _S1227;
        float _S1229 = (integral_2 - _S1215) / _S1228;
        bool _S1230 = _S1228 > 0.0f;
        float _S1231 = _slang_select(_S1230, _S1229,0.0f);
        float _S1232 = clamp_1(t_21 - _S1231, 0.0f, lobes_13.toon_b);
        int k_1 = k_0 + int(1);
        t_21 = _S1232;
        k_0 = k_1;
    }
    float _S1233 = 6.28318548202514648f * _S1214.value;
    float _S1234 = (F32_sin((t_21)));
    float3  _S1235 = tangentToWorld(make_float3 (_S1234 * (F32_cos((_S1233))), (F32_cos((t_21))), _S1234 * (F32_sin((_S1233)))), lobes_13.toon_axis);
    (&sample_3)->unit_direction = _S1235;
    bool _S1236 = (dot_0(n_i_10, (&sample_3)->unit_direction)) < 0.0f;
    (&sample_3)->refracted = _S1236;
    (&sample_3)->lobe = 6U;
    float3  _S1237 = toonBSDF((&sample_3)->unit_direction, n_i_10, alpha_17, material_25, lobes_13);
    (&sample_3)->throughput = _S1237;
    float _S1238 = toonPDF(dot_0(n_i_10, (&sample_3)->unit_direction), dot_0((&sample_3)->unit_direction, lobes_13.toon_axis), n_i_dot_v_8, alpha_17, lobes_13, eta_i_18, eta_o_18);
    (&sample_3)->pdf = _S1238;
    return sample_3;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_5, float3  n_i_11, float n_i_dot_v_9, float alpha_18, BSDFMaterial material_26, HalfTerms lobes_14, float eta_i_19, float eta_o_19, uint random_state_20)
{
    float3  _S1239 = make_float3 (1.0f);
    SampleBSDF _S1240 = SampleBSDF_x24init_0(_S1239, _S1239, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S1240;
    (&sample_4)->unit_direction = lobes_14.refracted;
    (&sample_4)->random_state = random_state_20;
    (&sample_4)->refracted = true;
    (&sample_4)->lobe = 1U;
    float3  _S1241 = refractBSDF((&sample_4)->unit_direction, n_i_11, alpha_18, material_26, lobes_14);
    (&sample_4)->throughput = _S1241;
    float _S1242 = refractPDF(0.0f, dot_0((&sample_4)->unit_direction, ggx_n_5), n_i_dot_v_9, alpha_18, lobes_14, eta_i_19, eta_o_19);
    (&sample_4)->pdf = _S1242;
    return sample_4;
}

static __device__ float3  reflect_0(float3  i_23, float3  n_15)
{
    return i_23 - make_float3 (2.0f * dot_0(n_15, i_23)) * n_15;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_13, float3  ggx_n_6, float3  n_i_12, float n_i_dot_v_10, float alpha_19, BSDFMaterial material_27, HalfTerms lobes_15, float eta_i_20, float eta_o_20, uint random_state_21)
{
    float3  _S1243 = make_float3 (1.0f);
    SampleBSDF _S1244 = SampleBSDF_x24init_0(_S1243, _S1243, 0U, false, 0U, 0.0f);
    SampleBSDF sample_5 = _S1244;
    float3  _S1245 = reflect_0(in_dir_13, ggx_n_6);
    float3  _S1246 = ((((_S1245)) * make_float3(rnorm3df(((_S1245)).x, ((_S1245)).y, ((_S1245)).z))));
    (&sample_5)->unit_direction = _S1246;
    (&sample_5)->random_state = random_state_21;
    (&sample_5)->lobe = 2U;
    float3  _S1247 = reflectBSDF((&sample_5)->unit_direction, n_i_12, alpha_19, material_27, lobes_15);
    (&sample_5)->throughput = _S1247;
    float _S1248 = reflectPDF(0.0f, 0.0f, n_i_dot_v_10, alpha_19, lobes_15, eta_i_20, eta_o_20);
    (&sample_5)->pdf = _S1248;
    return sample_5;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_14, float3  n_16, BSDFMaterial material_28, float eta_i_21, float eta_o_21, uint random_init_0, float2  screen_space_0, MaterialTerms terms_6, ViewTerms view_terms_6)
{
    uint random_state_22 = random_init_0;
    float3  _S1249 = negate_0(in_dir_14);
    float _S1250 = dot_0(n_16, _S1249);
    float _S1251 = sign_0(_S1250);
    float3  n_i_13 = n_16 * make_float3 (_S1251);
    float _S1252 = (F32_abs((_S1250)));
    float _S1253 = material_28.roughness;
    float _S1254 = _S1253 * _S1253;
    float3  _S1255 = sampleHalfVector(_S1249, n_i_13, _S1254, view_terms_6.frame, &random_state_22);
    HalfTerms _S1256 = precomputeHalf(in_dir_14, _S1255, material_28, eta_i_21, eta_o_21, terms_6, view_terms_6);
    Random _S1257 = pcg(random_state_22);
    random_state_22 = _S1257.state;
    bool _S1258 = (_S1257.value) < (_S1256.p_sheen_velvet);
    if(_S1258)
    {
        SampleBSDF _S1259 = sheenVelvetSample(n_i_13, _S1252, _S1254, material_28, _S1256, eta_i_21, eta_o_21, random_state_22);
        return _S1259;
    }
    float _S1260 = _S1257.value - _S1256.p_sheen_velvet;
    bool _S1261 = _S1260 < (_S1256.p_diffuse);
    if(_S1261)
    {
        SampleBSDF _S1262 = diffuseSample(_S1260, n_i_13, _S1252, _S1254, material_28, _S1256, eta_i_21, eta_o_21, random_state_22);
        return _S1262;
    }
    bool _S1263 = _S1260 < (_S1256.p_diffuse + _S1256.p_toon);
    if(_S1263)
    {
        SampleBSDF _S1264 = toonSample(n_i_13, _S1252, _S1254, material_28, _S1256, eta_i_21, eta_o_21, random_state_22);
        return _S1264;
    }
    bool _S1265 = (_S1260 - _S1256.p_toon) < (_S1256.p_diffuse + _S1256.p_refract);
    if(_S1265)
    {
        SampleBSDF _S1266 = refractSample(_S1255, n_i_13, _S1252, _S1254, material_28, _S1256, eta_i_21, eta_o_21, random_state_22);
        return _S1266;
    }
    SampleBSDF _S1267 = reflectSample(in_dir_14, _S1255, n_i_13, _S1252, _S1254, material_28, _S1256, eta_i_21, eta_o_21, random_state_22);
    return _S1267;
}

__device__ bool withinInverseFootprint(float pdf_10, bool diffuse_0, float prev_cos_0, float distance_5, float threshold_1)
{
    bool _S1268 = pdf_10 > 0.0f;
    bool _S1269;
    if(_S1268)
    {
        if(diffuse_0)
        {
            _S1269 = true;
        }
        else
        {
            _S1269 = (pdf_10 * prev_cos_0 / (distance_5 * distance_5) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S1269 = false;
    }
    return _S1269;
}

__device__ bool roughLobe(float pdf_11, bool diffuse_1, float roughness_1)
{
    bool _S1270 = pdf_11 > 0.0f;
    bool _S1271;
    if(_S1270)
    {
        if(diffuse_1)
        {
            _S1271 = true;
        }
        else
        {
            _S1271 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S1271 = false;
    }
    return _S1271;
}

static __device__ bool passesLayer_0(uint layers_0, bool refracting_0, bool passed_0)
{
    bool _S1272 = layers_0 > 1U;
    bool _S1273;
    if(_S1272)
    {
        _S1273 = refracting_0 != passed_0;
    }
    else
    {
        _S1273 = false;
    }
    return _S1273;
}

static __device__ float widened_0(float spread_1, float pdf_12, bool delta_0)
{
    float _S1274 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * pdf_12))))), (3.14159274101257324f)));
    bool _S1275 = !delta_0;
    float _S1276 = _slang_select(_S1275, _S1274,0.0f);
    return spread_1 + _S1276;
}

static __device__ bool boundsVolume_0(FKSurface * surface_10)
{
    return surface_10->encloses;
}

static __device__ bool leavesInFront_0(float3  face_2, float3  dir_15, float3  g_3)
{
    return ((dot_0(dir_15, g_3)) > 0.0f) == ((dot_0(g_3, face_2)) > 0.0f);
}

static __device__ Shift walk_0(Domain * dom_7, Reservoir * r_8, bool replay_2, float scale_4, Selection * sel_7)
{
    float spread_2;
    bool turned_1;
    bool is_inside_5;
    bool viewed_0;
    bool _S1277;
    float density_2;
    float threshold_2;
    float width_3;
    float sky_pdf_0;
    float wavelength_2;
    uint b_8;
    uint layer_0;
    float3  throughput_5;
    float3  chain_throughput_0;
    TreeSample light_3;
    int _S1278;
    Shift ended_0;
    float density_3;
    float spread_3;
    float width_4;
    float sky_pdf_1;
    float spread_4;
    float width_5;
    uint b_9;
    float3  _S1279 = make_float3 (0.0f);
    Shift _S1280 = Shift_x24init_0(_S1279, 0.0f);
    uint _S1281 = r_8->path;
    uint _S1282 = extractBits_0(r_8->path, 0U, 5U);
    uint _S1283 = extractBits_0(_S1281, 5U, 5U);
    uint _S1284 = extractBits_0(_S1281, 10U, 2U);
    uint _S1285 = extractBits_0(_S1281, 12U, 3U);
    bool passes_0;
    if(replay_2)
    {
        bool _S1286 = _S1285 >= 3U;
        uint _S1287 = _slang_select(_S1286, 1U,0U);
        uint _S1288 = _S1282 + _S1287;
        uint _S1289 = (fcptMaxBounces());
        passes_0 = _S1288 > _S1289;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1280;
    }
    uint _S1290 = _S1283 - 1U;
    bool _S1291 = _S1285 == 3U;
    uint _S1292 = _slang_select(_S1291, 1U,0U);
    uint _S1293 = _S1282 + _S1292;
    bool _S1294 = _S1284 == 0U;
    uint _S1295 = _slang_select(_S1294, _S1293,_S1290);
    FKHit _S1296 = (fcptReservoirHit((*r_8)));
    float3  _S1297 = dom_7->x0;
    float3  _S1298 = dom_7->x1 - dom_7->x0;
    float3  _S1299 = ((((_S1298)) * make_float3(rnorm3df(((_S1298)).x, ((_S1298)).y, ((_S1298)).z))));
    FKRay _S1300 = Ray_x24init_0(dom_7->x1, _S1299);
    FKRay ray_2 = _S1300;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1279;
    float3  throughput_6 = make_float3 (1.0f);
    float3  weight_1 = throughput_6;
    float3  glowed_0 = _S1279;
    float3  extinction_in_0 = _S1279;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1301 = dom_7->spread;
    float _S1302 = dom_7->width;
    float _S1303 = length_0(_S1298);
    NEEVertex _S1304 = NEEVertex_x24init_0(true, 0.0f, _S1279, _S1279, _S1279);
    NEEVertex nee_vertex_0 = _S1304;
    Vertex _S1305 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S1305;
    Reservoir _S1306 = (Reservoir{});
    Reservoir chain_0 = _S1306;
    uint _S1307 = r_8->seed;
    (&chain_0)->seed = r_8->seed;
    (&ray_2)->origin = _S1297;
    (&hit_4)->distance = _S1303;
    FKMedium _S1308 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1309 = filling_2;
    bool _S1310 = (fcptVaryingUsed());
    uint _S1311 = _slang_select(_S1310, _S1309,4294967295U);
    filling_2 = _S1311;
    scatter_in_0 = _S1308.scatter;
    extinction_in_0 = _S1308.extinction;
    g_in_0 = _S1308.g;
    Reservoir _S1312 = chain_0;
    uint _S1313 = filling_2;
    for(;;)
    {
        bool _S1314 = (fcptVaryingUsed());
        if(_S1314)
        {
            passes_0 = _S1313 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1315 = (fcptMajorant((_S1313)));
            spread_2 = _S1315;
        }
        else
        {
            spread_2 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_2)
        {
            turned_1 = 4294967295U == _S1295;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1284 == 1U;
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
            ended_0 = _S1280;
            sky_pdf_0 = 0.0f;
            spread_2 = _S1301;
            width_3 = _S1302;
            density_2 = 1.0f;
            throughput_5 = throughput_6;
            b_8 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1316 = (&prev_0)->rough;
        if(_S1316)
        {
            turned_1 = !(spread_2 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S1317 = stream(_S1307, 384U);
        uint tracking_0 = _S1317;
        weight_1 = throughput_6;
        glowed_0 = _S1279;
        b_8 = 4294967295U;
        throughput_5 = throughput_6;
        density_2 = 1.0f;
        threshold_2 = _S1301;
        width_3 = _S1302;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1278 = int(1);
                break;
            }
            uint _S1318 = b_8 + 320U;
            bool _S1319 = b_8 == 4294967295U;
            uint _S1320 = _slang_select(_S1319, 384U,_S1318);
            uint _S1321 = stream(_S1307, _S1320);
            Random _S1322 = pcg(_S1321);
            float _S1323 = freeFlight_0(_S1322.value, spread_2);
            if(passes_0)
            {
                float3  _S1324 = (&ray_2)->origin;
                float3  _S1325 = (&ray_2)->unit_direction;
                float _S1326 = (&hit_4)->distance;
                uint _S1327 = _slang_select(_S1319, 0U,b_8);
                uint _S1328 = (&prev_0)->lobe;
                uint _S1329 = _slang_select(_S1319, 3U,_S1328);
                float _S1330 = (fcptTrackMedium((_S1313), (_S1324), (_S1325), (_S1326), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1327), (_S1329), (_S1319)));
                wavelength_2 = _S1330;
            }
            else
            {
                wavelength_2 = _S1323;
            }
            bool _S1331 = !(wavelength_2 < ((&hit_4)->distance));
            if(_S1331)
            {
                _S1278 = int(1);
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
                float3  _S1332 = throughput_5 * glowed_0 / make_float3 (density_2);
                float3  _S1333 = sel_7->glow + _S1332;
                sel_7->glow = _S1333;
            }
            else
            {
            }
            glowed_0 = _S1279;
            uint b_10 = b_8 + 1U;
            float3  _S1334 = (&ray_2)->origin + make_float3 (wavelength_2) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1334;
            float3  _S1335 = flightWeight_0(scatter_in_0, extinction_in_0, spread_2, wavelength_2, true);
            float3  _S1336 = weight_1;
            float3  _S1337 = _slang_select(passes_0, _S1336,_S1335);
            float3  throughput_7 = throughput_5 * _S1337;
            uint _S1338 = stream(_S1307, b_10 + 320U);
            tracking_0 = _S1338;
            weight_1 = throughput_6;
            float width_6 = width_3 + threshold_2 * wavelength_2;
            float _S1339 = threshold_2 + 3.14159274101257324f;
            bool _S1340 = scatterSampled_0(replay_2, b_10, _S1295, passes_0);
            TreeSample _S1341 = TreeSample_x24init_0(_S1279, _S1279, 0.0f, 0U);
            if(_S1340)
            {
                float3  _S1342 = (&ray_2)->origin;
                float3  _S1343 = (&ray_2)->unit_direction;
                float3  _S1344 = (&ray_2)->unit_direction;
                uint _S1345 = stream(_S1307, b_10 + 64U);
                float3  _S1346 = extinction_in_0;
                float3  _S1347 = extinction_in_0;
                uint2  _S1348 = make_uint2 (_S1313);
                float3  _S1349 = (&ray_2)->unit_direction;
                uint _S1350 = arrivalLobe_0(b_10, (&prev_0)->lobe);
                FKHit _S1351 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1352 = _S1351;
                ShadowContext _S1353 = ShadowContext_x24init_0(_S1346, _S1347, _S1348, _S1349, b_10, _S1350, false, wavelength_2, width_6, &_S1352, false);
                ShadowContext _S1354 = _S1353;
                TreeSample _S1355 = sampleLightTree_0(_S1342, _S1343, _S1344, 0.0f, true, _S1345, &_S1354);
                light_3 = _S1355;
            }
            else
            {
                light_3 = _S1341;
            }
            float _S1356 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S1357 = (fcptMaxBounces());
            bool _S1358 = b_10 < _S1357;
            if(_S1358)
            {
                is_inside_5 = (light_3.density) > 0.0f;
            }
            else
            {
                is_inside_5 = false;
            }
            float _S1359 = _slang_select(is_inside_5, _S1356,0.0f);
            float3  _S1360 = throughput_7 * light_3.radiance;
            float _S1361 = powerHeuristic(light_3.density, _S1359);
            float3  _S1362 = _S1360 * make_float3 (_S1356 * _S1361);
            float3  _S1363 = _slang_select(_S1340, _S1362,_S1279);
            if(replay_2)
            {
                viewed_0 = b_10 == _S1295;
            }
            else
            {
                viewed_0 = false;
            }
            if(viewed_0)
            {
                bool _S1364 = _S1284 == 2U;
                if(_S1364)
                {
                    float _S1365 = resamplingTarget(_S1363);
                    passes_0 = _S1365 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1366 = Shift_x24init_0(_S1363, 1.0f);
                    _S1278 = int(0);
                    ended_0 = _S1366;
                    spread_2 = _S1339;
                    wavelength_2 = width_6;
                    chain_throughput_0 = throughput_7;
                    layer_0 = b_10;
                    break;
                }
                _S1278 = int(0);
                ended_0 = _S1280;
                spread_2 = _S1339;
                wavelength_2 = width_6;
                chain_throughput_0 = throughput_7;
                layer_0 = b_10;
                break;
            }
            bool _S1367 = !replay_2;
            if(_S1367)
            {
                Reservoir candidate_3 = _S1312;
                uint _S1368 = extractBits_0(_S1312.path, 10U, 2U);
                bool _S1369 = _S1368 == 1U;
                if(_S1369)
                {
                    float3  _S1370 = safeDivide(_S1363, _S1279);
                    (&candidate_3)->radiance = _S1370;
                }
                else
                {
                    uint _S1371 = insertBits_0(0U, b_10 + 1U, 5U, 5U);
                    uint _S1372 = insertBits_0(_S1371, 2U, 10U, 2U);
                    (&candidate_3)->path = _S1372;
                }
                Reservoir _S1373 = withEnd(candidate_3, 0U, b_10, _S1363);
                offer(sel_7, _S1373, _S1363 * make_float3 (scale_4) / make_float3 (density_2));
                float _S1374 = survivalProbability(abs_0(throughput_7), density_2);
                uint _S1375 = stream(_S1307, b_10 + 128U);
                Random _S1376 = pcg(_S1375);
                bool _S1377 = _S1374 < (_S1376.value);
                if(_S1377)
                {
                    _S1277 = true;
                }
                else
                {
                    uint _S1378 = (fcptMaxBounces());
                    _S1277 = b_10 >= _S1378;
                }
                if(_S1277)
                {
                    _S1278 = int(0);
                    ended_0 = _S1280;
                    spread_2 = _S1339;
                    wavelength_2 = width_6;
                    chain_throughput_0 = throughput_7;
                    layer_0 = b_10;
                    break;
                }
                float _S1379 = density_2 * _S1374;
                density_2 = _S1379;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1380 = stream(_S1307, b_10);
            float3  _S1381 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1380, &phase_pdf_0);
            (&ray_2)->unit_direction = _S1381;
            NEEVertex _S1382 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S1279, (&ray_2)->origin);
            nee_vertex_0 = _S1382;
            Vertex _S1383 = scatteredVertex_0(false);
            prev_0 = _S1383;
            float _S1384 = (&prev_0)->pdf;
            FKRay _S1385 = ray_2;
            FKHit _S1386 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1387 = (fcptTraverseInstanceBVH((_S1385), (true), (4.294967296e+09f), (false), (_S1386), (false)));
            hit_4 = _S1387;
            b_8 = b_10;
            throughput_5 = throughput_7;
            threshold_2 = _S1339;
            width_3 = width_6;
            sky_pdf_0 = _S1384;
        }
        if(_S1278 != int(1))
        {
            width_3 = wavelength_2;
            throughput_5 = chain_throughput_0;
            b_8 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1280;
        spread_2 = threshold_2;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1388 = b_8 == 4294967295U;
    bool _S1389 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1389)
    {
        bool _S1390 = !(&nee_vertex_0)->none;
        float _S1391 = _slang_select(_S1390, sky_pdf_0,0.0f);
        float _S1392 = escapeWeight_0(_S1391, (&ray_2)->unit_direction);
        float3  _S1393 = environment_0((&ray_2)->unit_direction, b_8, (&prev_0)->lobe);
        float3  _S1394 = throughput_5 * _S1393;
        if(replay_2)
        {
            bool _S1395 = b_8 == _S1295;
            if(_S1395)
            {
                passes_0 = _S1284 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S1394 * make_float3 (_S1392) / make_float3 (r_8->jac), density_2 / r_8->jac);
            }
            if(_S1294)
            {
                passes_0 = _S1291;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_8 == _S1282;
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
                return Shift_x24init_0(_S1394 * make_float3 (_S1392), 1.0f);
            }
            return _S1280;
        }
        Reservoir candidate_4 = chain_0;
        uint _S1396 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1397 = _S1396 == 1U;
        if(_S1397)
        {
            uint _S1398 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S1399 = _S1398 == b_8;
            float _S1400 = _slang_select(_S1399, 1.0f,_S1392);
            float3  _S1401 = safeDivide(_S1394 * make_float3 (_S1400), _S1279);
            (&candidate_4)->radiance = _S1401;
        }
        else
        {
            bool _S1402 = (&prev_0)->rough;
            if(_S1402)
            {
                uint _S1403 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                uint _S1404 = insertBits_0(_S1403, 3U, 10U, 2U);
                uint _S1405 = insertBits_0(_S1404, (&prev_0)->lobe, 15U, 3U);
                bool _S1406 = (&prev_0)->inside;
                uint _S1407 = _slang_select(_S1406, 1U,0U);
                uint _S1408 = insertBits_0(_S1405, _S1407, 22U, 1U);
                (&candidate_4)->path = _S1408;
                (&candidate_4)->jac = (&prev_0)->pdf;
                (&candidate_4)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S1409 = _S1394 * make_float3 (_S1392);
        Reservoir _S1410 = withEnd(candidate_4, 3U, b_8, _S1409);
        offer(sel_7, _S1410, _S1409 * make_float3 (scale_4) / make_float3 (density_2));
        return _S1280;
    }
    float3  _S1411 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S1411;
    bool _S1412 = (fcptVaryingUsed());
    if(_S1412)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1413 = !replay_2;
        if(_S1413)
        {
            float3  _S1414 = throughput_5 * glowed_0 / make_float3 (density_2);
            float3  _S1415 = sel_7->glow + _S1414;
            sel_7->glow = _S1415;
        }
        float3  _S1416 = throughput_5 * weight_1;
        throughput_5 = _S1416;
    }
    else
    {
        float3  _S1417 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
        float3  _S1418 = throughput_5 * _S1417;
        throughput_5 = _S1418;
    }
    float _S1419 = width_3 + spread_2 * (&hit_4)->distance;
    uint _S1420 = b_8 + 1U;
    b_8 = _S1420;
    layer_0 = 0U;
    width_3 = _S1419;
    passes_0 = false;
    threshold_2 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    wavelength_2 = 0.0f;
    chain_throughput_0 = _S1279;
    float3  reconnection_0 = _S1279;
    viewed_0 = _S1388;
    for(;;)
    {
        bool _S1421 = ((&hit_4)->is_point_light) == 1U;
        if(replay_2)
        {
            _S1277 = _S1284 == 1U;
        }
        else
        {
            _S1277 = false;
        }
        bool _S1422;
        if(_S1277)
        {
            _S1422 = b_8 == _S1283;
        }
        else
        {
            _S1422 = false;
        }
        bool _S1423;
        if(_S1422)
        {
            bool _S1424 = ((&hit_4)->instance_index) != (_S1296.instance_index);
            if(_S1424)
            {
                _S1423 = true;
            }
            else
            {
                _S1423 = ((&hit_4)->triangle_index) != (_S1296.triangle_index);
            }
        }
        else
        {
            _S1423 = false;
        }
        if(_S1423)
        {
            return _S1280;
        }
        FKMedium _S1425 = Medium_x24init_0(_S1279, _S1279, 0.0f);
        BSDFMaterial _S1426 = Material_x24init_0(_S1279, _S1279, 0.0f, 0.0f, 0.0f, 0.0f, _S1279, throughput_6, 1.0f, _S1279, _S1279, 0.5f, 0.0f, 0.0f, _S1279, 0.0f, _S1279, 0.0f);
        FKMedium _S1427 = _S1425;
        FKSurface _S1428 = Surface_x24init_0(_S1279, _S1279, 0.0f, &_S1426, false, 0U, 1.0f, false, &_S1427, 4294967295U, _S1279);
        bool _S1429 = !_S1421;
        bool scatter_2;
        bool is_inside_6;
        float geometry_density_2;
        float3  throughput_8;
        FKSurface surface_11;
        if(_S1429)
        {
            uint _S1430 = stream(_S1307, b_8);
            uint _S1431 = arrivalLobe_0(b_8, (&prev_0)->lobe);
            FKSurface _S1432 = (fcptSurfaceAtPath((hit_4), ((&ray_2)->origin), (_S1430), (width_3), (layer_0), (b_8), (_S1431), ((&ray_2)->unit_direction)));
            bool _S1433 = !passes_0;
            FKSurface _S1434 = _S1432;
            FKSurface _S1435 = emitting_0(&_S1434, _S1433);
            uint _S1436 = stream(_S1307, b_8 + 256U);
            Random _S1437 = pcg(_S1436);
            FKSurface _S1438 = _S1435;
            FKSurface _S1439 = uncovered_0(&_S1438, _S1437.value);
            float _S1440 = facingSign(_S1439.material.transmission, _S1439.geometry_n, (&ray_2)->unit_direction);
            bool _S1441 = _S1440 < 0.0f;
            bool _S1442 = (_S1439.material.transmission) > 0.0f;
            if(_S1442)
            {
                bool _S1443 = arrivesBehind_0((&ray_2)->unit_direction, _S1439.geometry_n);
                scatter_2 = _S1443;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1444 = _S1439;
            FKSurface _S1445 = facingRay_0(&_S1444, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S1446 = arrivesBehind_0((&ray_2)->unit_direction, _S1445.geometry_n);
                is_inside_6 = _S1446;
            }
            else
            {
                is_inside_6 = scatter_2;
            }
            if(is_inside_6)
            {
                float3  _S1447 = beerLambert((&hit_4)->distance, _S1445.material.absorption);
                float3  _S1448 = throughput_5 * _S1447;
                throughput_8 = _S1448;
            }
            else
            {
                throughput_8 = throughput_5;
            }
            bool _S1449 = !_S1445.skip;
            float geometry_density_3 = geometryDensity(_S1445.geometry_n, (&ray_2)->unit_direction, (&hit_4)->distance);
            bool _S1450 = b_8 == _S1420;
            if(_S1450)
            {
                float _S1451 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S1451;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            float _S1452 = geometry_density_2;
            scatter_2 = _S1449;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S1452;
            surface_11 = _S1445;
            turned_1 = _S1441;
        }
        else
        {
            scatter_2 = false;
            geometry_density_2 = 0.0f;
            surface_11 = _S1428;
            throughput_8 = throughput_5;
            is_inside_6 = is_inside_5;
        }
        bool _S1453 = withinFootprint(scatter_2, (&prev_0)->rough, (&prev_0)->pdf, geometry_density_2, threshold_2);
        FKSurface _S1454 = surface_11;
        FKSurface _S1455 = surface_11;
        float _S1456 = dot_0(surface_11.smooth_n, - (&ray_2)->unit_direction);
        bool _S1457 = (fcptDispersionUsed());
        bool _S1458;
        if(_S1457)
        {
            _S1458 = wavelength_2 == 0.0f;
        }
        else
        {
            _S1458 = false;
        }
        bool _S1459;
        if(_S1458)
        {
            _S1459 = scatter_2;
        }
        else
        {
            _S1459 = false;
        }
        bool _S1460;
        if(_S1459)
        {
            bool _S1461 = dispersive(_S1454.material);
            _S1460 = _S1461;
        }
        else
        {
            _S1460 = false;
        }
        float3  throughput_9;
        if(_S1460)
        {
            uint _S1462 = stream(_S1307, 512U);
            Random _S1463 = pcg(_S1462);
            float2  _S1464 = sampleWavelength(_S1463.value);
            float _S1465 = _S1464.x;
            float3  _S1466 = wavelengthWeights(_S1465);
            float3  _S1467 = throughput_8 * (_S1466 / make_float3 (_S1464.y));
            wavelength_2 = _S1465;
            throughput_9 = _S1467;
        }
        else
        {
            throughput_9 = throughput_8;
        }
        BSDFMaterial refractive_0 = _S1454.material;
        float _S1468 = dispersedIor(_S1454.material.ior, _S1454.material.dispersion, wavelength_2);
        bool _S1469 = wavelength_2 > 0.0f;
        float _S1470 = _slang_select(_S1469, _S1468,_S1454.material.ior);
        (&refractive_0)->ior = _S1470;
        float2  _S1471 = vertexEta(refractive_0, _S1456);
        bool _S1472;
        if(scatter_2)
        {
            bool _S1473 = neeDecision(_S1454.material, _S1456, _S1471.x, _S1471.y);
            _S1472 = _S1473;
        }
        else
        {
            _S1472 = false;
        }
        bool _S1474;
        if(passes_0)
        {
            _S1474 = true;
        }
        else
        {
            _S1474 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1474)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1472;
        }
        bool _S1475 = (fcptHairUsed());
        bool _S1476;
        if(_S1475)
        {
            float3  _S1477 = surface_11.hair;
            _S1476 = (dot_0(_S1477, _S1477)) > 0.0f;
        }
        else
        {
            _S1476 = false;
        }
        bool _S1478;
        if(_S1476)
        {
            _S1478 = true;
        }
        else
        {
            BSDFMaterial _S1479 = _S1454.material;
            bool _S1480 = isTranslucent_0(&_S1479);
            _S1478 = _S1480;
        }
        bool _S1481;
        if(_S1478)
        {
            _S1481 = true;
        }
        else
        {
            bool _S1482 = (_S1454.material.transmission) > 0.0f;
            if(_S1482)
            {
                uint _S1483 = (fcptLayers((hit_4)));
                _S1481 = _S1483 == 1U;
            }
            else
            {
                _S1481 = false;
            }
        }
        float3  emission_0;
        if(_S1421)
        {
            float3  _S1484 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1484;
        }
        else
        {
            emission_0 = _S1454.material.emissive;
        }
        float _S1485 = rgb_to_greyscale(emission_0);
        bool _S1486 = _S1485 > 0.0f;
        float3  emission_1;
        if(_S1486)
        {
            NEEVertex _S1487 = nee_vertex_0;
            FKHit _S1488 = hit_4;
            float _S1489 = emissionWeight_0(&_S1487, &_S1488, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1489);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1490;
        if(replay_2)
        {
            _S1490 = _S1284 == 1U;
        }
        else
        {
            _S1490 = false;
        }
        bool _S1491;
        if(_S1490)
        {
            _S1491 = b_8 > _S1283;
        }
        else
        {
            _S1491 = false;
        }
        bool _S1492;
        if(_S1491)
        {
            _S1492 = b_8 == _S1282;
        }
        else
        {
            _S1492 = false;
        }
        bool _S1493;
        if(_S1492)
        {
            bool _S1494 = _S1285 == 1U;
            if(_S1494)
            {
                _S1493 = true;
            }
            else
            {
                _S1493 = _S1285 == 2U;
            }
        }
        else
        {
            _S1493 = false;
        }
        if(_S1493)
        {
            bool _S1495 = _S1421 != (_S1285 == 2U);
            if(_S1495)
            {
                return _S1280;
            }
            return Shift_x24init_0(throughput_9 * emission_1 / make_float3 (r_8->jac), density_2 / r_8->jac);
        }
        uint _S1496 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1497 = _S1496 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1498 = insertBits_0(0U, b_8, 5U, 5U);
        uint _S1499 = insertBits_0(_S1498, 1U, 10U, 2U);
        uint _S1500 = insertBits_0(_S1499, (&prev_0)->lobe, 15U, 3U);
        bool _S1501 = (&prev_0)->inside;
        uint _S1502 = _slang_select(_S1501, 1U,0U);
        uint _S1503 = insertBits_0(_S1500, _S1502, 22U, 1U);
        (&here_0)->path = _S1503;
        uint _S1504 = (&here_0)->path;
        uint _S1505 = _slang_select(_S1469, 1U,0U);
        uint _S1506 = insertBits_0(_S1504, _S1505, 23U, 1U);
        (&here_0)->path = _S1506;
        float _S1507 = (&prev_0)->pdf * geometry_density_2;
        (&here_0)->jac = _S1507;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1508;
        if(replay_2)
        {
            _S1508 = _S1284 == 1U;
        }
        else
        {
            _S1508 = false;
        }
        bool _S1509;
        if(_S1508)
        {
            _S1509 = b_8 == _S1283;
        }
        else
        {
            _S1509 = false;
        }
        bool _S1510 = b_8 == _S1295;
        bool _S1511;
        if(_S1510)
        {
            bool _S1512 = !scatter_2;
            if(_S1512)
            {
                _S1511 = true;
            }
            else
            {
                bool _S1513 = _S1284 != 1U;
                if(_S1513)
                {
                    _S1511 = _S1284 != 3U;
                }
                else
                {
                    _S1511 = false;
                }
            }
        }
        else
        {
            _S1511 = false;
        }
        bool _S1514;
        if(_S1511)
        {
            _S1514 = _S1284 == 2U;
        }
        else
        {
            _S1514 = false;
        }
        bool _S1515;
        if(_S1514)
        {
            _S1515 = !_S1453;
        }
        else
        {
            _S1515 = false;
        }
        bool _S1516;
        if(_S1515)
        {
            _S1516 = _S1285 != 4U;
        }
        else
        {
            _S1516 = false;
        }
        bool _S1517 = _S1283 == _S1282;
        bool _S1518;
        if(_S1517)
        {
            _S1518 = _S1285 == 0U;
        }
        else
        {
            _S1518 = false;
        }
        bool _S1519;
        if(_S1518)
        {
            _S1519 = ((&hit_4)->instance_index) == (_S1296.instance_index);
        }
        else
        {
            _S1519 = false;
        }
        bool _S1520;
        if(_S1519)
        {
            _S1520 = ((&hit_4)->triangle_index) == (_S1296.triangle_index);
        }
        else
        {
            _S1520 = false;
        }
        bool _S1521;
        if(_S1520)
        {
            _S1521 = _S1453;
        }
        else
        {
            _S1521 = false;
        }
        bool _S1522 = _slang_select(_S1509, _S1521,_S1516);
        bool _S1523;
        if(nee_0)
        {
            _S1523 = _slang_select(replay_2, _S1522,scatter_2);
        }
        else
        {
            _S1523 = false;
        }
        TreeSample _S1524 = TreeSample_x24init_0(_S1279, _S1279, 0.0f, 0U);
        uint2  _S1525 = make_uint2 (0U);
        float2  _S1526 = make_float2 (0.0f);
        FKHit _S1527 = Hit_x24init_0(_S1526, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1528 = _S1527;
        ShadowContext _S1529 = ShadowContext_x24init_0(_S1279, _S1279, _S1525, _S1279, 0U, 0U, false, 0.0f, 0.0f, &_S1528, false);
        ShadowContext context_5;
        if(nee_0)
        {
            uint _S1530 = arrivalLobe_0(b_8, (&prev_0)->lobe);
            FKMedium _S1531 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1532 = surface_11;
            FKHit _S1533 = hit_4;
            FKMedium _S1534 = _S1531;
            ShadowContext _S1535 = shadowContext_0(&_S1532, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_8, _S1530, (&hit_4)->distance, width_3, &_S1533, _S1476, &_S1534);
            context_5 = _S1535;
        }
        else
        {
            context_5 = _S1529;
        }
        float3  throughput_10;
        float3  lit_0;
        if(_S1523)
        {
            float3  _S1536 = (&ray_2)->origin;
            if(_S1476)
            {
                throughput_10 = _S1279;
            }
            else
            {
                throughput_10 = _S1455.smooth_n;
            }
            FKSurface _S1537 = surface_11;
            uint _S1538 = stream(_S1307, b_8 + 64U);
            ShadowContext _S1539 = context_5;
            TreeSample _S1540 = sampleLightTree_0(_S1536, throughput_10, surface_11.geometry_n, surface_11.geometry_offset, _S1481, _S1538, &_S1539);
            bool _S1541 = any_1((_S1540.radiance) != _S1279);
            if(_S1541)
            {
                if(_S1476)
                {
                    uint _S1542 = (fcptMaxBounces());
                    bool _S1543 = b_8 < _S1542;
                    FKSurface _S1544 = surface_11;
                    TreeSample _S1545 = _S1540;
                    float3  _S1546 = hairLight_0(&_S1544, (&ray_2)->unit_direction, &_S1545, _S1543);
                    lit_0 = _S1546;
                }
                else
                {
                    float _S1547 = _S1471.x;
                    float _S1548 = _S1471.y;
                    uint _S1549 = (fcptMaxBounces());
                    bool _S1550 = b_8 < _S1549;
                    TreeSample _S1551 = _S1540;
                    BSDFMaterial _S1552 = _S1454.material;
                    float3  _S1553 = lightBSDF_0((&ray_2)->unit_direction, &_S1551, _S1455.smooth_n, _S1537.geometry_n, &_S1552, _S1547, _S1548, _S1550, surface_11.random_state);
                    lit_0 = _S1553;
                }
            }
            else
            {
                lit_0 = _S1279;
            }
            light_3 = _S1540;
        }
        else
        {
            light_3 = _S1524;
            lit_0 = _S1279;
        }
        bool viewed_1;
        bool refracted_5;
        bool wrong_side_0;
        bool _S1554;
        bool _S1555;
        float density_4;
        if(_S1509)
        {
            bool _S1556 = !_S1453;
            if(_S1556)
            {
                return _S1280;
            }
            uint _S1557 = extractBits_0(_S1281, 23U, 1U);
            bool _S1558 = _S1469 != (_S1557 == 1U);
            if(_S1558)
            {
                return _S1280;
            }
            float3  throughput_11 = throughput_9 * make_float3 (geometry_density_2);
            float density_5 = density_2 * geometry_density_2;
            if(_S1517)
            {
                viewed_1 = _S1285 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                return Shift_x24init_0(throughput_11 * emission_1 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1517)
            {
                refracted_5 = _S1285 == 0U;
            }
            else
            {
                refracted_5 = false;
            }
            if(refracted_5)
            {
                bool _S1559 = !nee_0;
                if(_S1559)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1560 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1560 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1280;
                }
                return Shift_x24init_0(throughput_11 * lit_0 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1517)
            {
                wrong_side_0 = _S1285 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1561 = !nee_0;
                if(_S1561)
                {
                    return _S1280;
                }
                float _S1562 = environmentPdf_0(r_8->dir);
                float3  _S1563 = skyBSDF((&ray_2)->unit_direction, r_8->dir, surface_11, _S1471, is_inside_6, _S1562, surface_11.random_state);
                return Shift_x24init_0(throughput_11 * _S1563 * r_8->radiance / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            uint _S1564 = extractBits_0(_S1281, 21U, 1U);
            bool _S1565 = nee_0 != (_S1564 == 1U);
            if(_S1565)
            {
                return _S1280;
            }
            throughput_10 = throughput_11;
            density_4 = density_5;
        }
        else
        {
            if(replay_2)
            {
                viewed_1 = _S1510;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1566 = !scatter_2;
                if(_S1566)
                {
                    refracted_5 = true;
                }
                else
                {
                    bool _S1567 = _S1284 != 1U;
                    if(_S1567)
                    {
                        refracted_5 = _S1284 != 3U;
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
                bool _S1568 = _S1284 == 2U;
                if(_S1568)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1453;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1285 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1476)
                    {
                        return _S1280;
                    }
                    uint _S1569 = stream(_S1307, b_8 + 448U);
                    FKRay _S1570 = ray_2;
                    FKSurface _S1571 = surface_11;
                    ShadowContext _S1572 = context_5;
                    SkySample _S1573 = sampleSky_0(&_S1570, &_S1571, _S1471, is_inside_6, _S1569, surface_11.random_state, &_S1572);
                    return Shift_x24init_0(throughput_9 * _S1573.color, 1.0f);
                }
                if(_S1568)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1453;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1574 = rgb_to_greyscale(light_3.radiance);
                    bool _S1575 = !(_S1574 > 0.0f);
                    if(_S1575)
                    {
                        return _S1280;
                    }
                    return Shift_x24init_0(throughput_9 * lit_0, 1.0f);
                }
                if(_S1294)
                {
                    passes_0 = _S1285 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1421;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_9 * emission_1, 1.0f);
                }
                if(_S1294)
                {
                    passes_0 = _S1285 == 1U;
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
                    passes_0 = !_S1453;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_9 * emission_1, 1.0f);
                }
                return _S1280;
            }
            else
            {
                bool _S1576 = !replay_2;
                if(_S1576)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1577 = b_8 > 0U;
                    if(_S1577)
                    {
                        Reservoir candidate_5 = chain_0;
                        if(_S1497)
                        {
                            float3  _S1578 = safeDivide(throughput_9 * emission_1, chain_throughput_0);
                            (&candidate_5)->radiance = _S1578;
                        }
                        else
                        {
                            if(_S1453)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1579 = throughput_9 * emission_1;
                        Reservoir _S1580 = withEnd(candidate_5, 1U, b_8, _S1579);
                        offer(sel_7, _S1580, _S1579 * make_float3 (scale_4) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1581 = throughput_9 * emission_1;
                        float3  _S1582 = sel_7->glow + _S1581;
                        sel_7->glow = _S1582;
                    }
                    if(nee_0)
                    {
                        float3  _S1583 = throughput_9 * lit_0;
                        Reservoir candidate_6 = chain_0;
                        if(_S1497)
                        {
                            float3  _S1584 = safeDivide(_S1583, chain_throughput_0);
                            (&candidate_6)->radiance = _S1584;
                        }
                        else
                        {
                            if(_S1453)
                            {
                                candidate_6 = here_0;
                                uint _S1585 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1585;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1586 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                                uint _S1587 = insertBits_0(_S1586, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1587;
                            }
                        }
                        Reservoir _S1588 = withEnd(candidate_6, 0U, b_8, _S1583);
                        offer(sel_7, _S1588, _S1583 * make_float3 (scale_4) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1476)
                        {
                            _S1554 = false;
                        }
                        else
                        {
                            bool _S1589 = environmentMapped_0();
                            _S1554 = _S1589;
                        }
                    }
                    else
                    {
                        _S1554 = false;
                    }
                    if(_S1554)
                    {
                        uint _S1590 = (fcptMaxBounces());
                        _S1555 = b_8 < _S1590;
                    }
                    else
                    {
                        _S1555 = false;
                    }
                    if(_S1555)
                    {
                        uint _S1591 = stream(_S1307, b_8 + 448U);
                        FKRay _S1592 = ray_2;
                        FKSurface _S1593 = surface_11;
                        ShadowContext _S1594 = context_5;
                        SkySample _S1595 = sampleSky_0(&_S1592, &_S1593, _S1471, is_inside_6, _S1591, surface_11.random_state, &_S1594);
                        float3  _S1596 = throughput_9 * _S1595.color;
                        Reservoir candidate_7 = chain_0;
                        if(_S1497)
                        {
                            float3  _S1597 = safeDivide(_S1596, chain_throughput_0);
                            (&candidate_7)->radiance = _S1597;
                        }
                        else
                        {
                            if(_S1453)
                            {
                                candidate_7 = here_0;
                                uint _S1598 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1598;
                                (&candidate_7)->dir = _S1595.dir;
                                (&candidate_7)->radiance = _S1595.radiance;
                            }
                            else
                            {
                                uint _S1599 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                                uint _S1600 = insertBits_0(_S1599, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1600;
                            }
                        }
                        Reservoir _S1601 = withEnd(candidate_7, 4U, b_8, _S1596);
                        offer(sel_7, _S1601, _S1596 * make_float3 (scale_4) / make_float3 (density_2));
                    }
                }
            }
            throughput_10 = throughput_9;
            density_4 = density_2;
        }
        bool _S1602;
        bool _S1603;
        bool _S1604;
        bool straight_0;
        bool _S1605;
        bool _S1606;
        bool _S1607;
        bool _S1608;
        bool _S1609;
        bool _S1610;
        bool _S1611;
        bool _S1612;
        bool _S1613;
        bool _S1614;
        bool _S1615;
        bool _S1616;
        float density_6;
        float sky_pdf_2;
        float spread_5;
        uint b_11;
        float3  throughput_12;
        float3  throughput_13;
        float3  throughput_14;
        if(scatter_2)
        {
            MaterialTerms _S1617 = MaterialTerms_x24init_0(0.0f, 0.0f, 0.0f, 0.0f, 0.0f, _S1279, 0.0f, 0.0f, 0.0f, false, 0.0f);
            AnisotropicFrame _S1618 = AnisotropicFrame_x24init_0(_S1279, _S1526);
            ViewTerms _S1619 = ViewTerms_x24init_0(_S1279, _S1279, &_S1618, _S1279, 0.0f, _S1279, _S1279, _S1279, 0.0f, _S1279);
            bool _S1620 = !_S1476;
            MaterialTerms terms_7;
            ViewTerms view_terms_7;
            if(_S1620)
            {
                MaterialTerms terms_8 = precomputeMaterial(_S1454.material, _S1471.x, _S1471.y);
                ViewTerms _S1621 = precomputeView((&ray_2)->unit_direction, _S1455.smooth_n, _S1454.material, terms_8);
                terms_7 = terms_8;
                view_terms_7 = _S1621;
            }
            else
            {
                terms_7 = _S1617;
                view_terms_7 = _S1619;
            }
            if(replay_2)
            {
                viewed_1 = _S1510;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1622 = extractBits_0(_S1281, 15U, 3U);
            uint _S1623 = extractBits_0(_S1281, 18U, 3U);
            uint _S1624 = _slang_select(_S1509, _S1623,_S1622);
            float3  _S1625 = r_8->dir;
            bool refracted_6 = _S1624 == 1U;
            SampleBSDF _S1626 = SampleBSDF_x24init_0(_S1279, _S1279, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1626;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1627 = extractBits_0(_S1281, 22U, 1U);
                bool _S1628 = is_inside_6 != (_S1627 == 1U);
                if(_S1628)
                {
                    return _S1280;
                }
                bool _S1629 = _S1284 == 1U;
                if(_S1629)
                {
                    float3  _S1630 = (fcptHitPosition((_S1296)));
                    throughput_12 = _S1630;
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
                    BSDFMaterial _S1631 = _S1454.material;
                    bool _S1632 = isTranslucent_0(&_S1631);
                    if(_S1632)
                    {
                        refracted_5 = _S1624 == 0U;
                    }
                    else
                    {
                        refracted_5 = false;
                    }
                    if(refracted_5)
                    {
                        float3  _S1633 = throughput_12 - (&ray_2)->origin;
                        float3  _S1634 = _slang_select(_S1629, _S1633,_S1625);
                        wrong_side_0 = (dot_0(_S1455.smooth_n, _S1634) * _S1456) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_5 = wrong_side_0;
                }
                if(_S1629)
                {
                    float3  _S1635 = (&ray_2)->origin;
                    FKSurface _S1636 = surface_11;
                    float3  _S1637 = - _S1455.smooth_n;
                    bool _S1638 = is_inside_6 != refracted_5;
                    float3  _S1639 = _slang_select(_S1638, _S1637,_S1455.smooth_n);
                    float3  _S1640 = throughput_12 - (_S1635 + make_float3 (_S1636.geometry_offset) * _S1639);
                    float3  _S1641 = ((((_S1640)) * make_float3(rnorm3df(((_S1640)).x, ((_S1640)).y, ((_S1640)).z))));
                    reconnection_1 = _S1641;
                }
                else
                {
                    reconnection_1 = _S1625;
                }
                if(_S1476)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1642 = wrongSide_0(is_inside_6, refracted_5, reconnection_1, surface_11.geometry_n);
                    wrong_side_0 = _S1642;
                }
                if(wrong_side_0)
                {
                    return _S1280;
                }
                float3  _S1643 = throughput_12;
                throughput_12 = reconnection_1;
                b_11 = _S1624;
                wrong_side_0 = false;
                reconnection_1 = _S1643;
            }
            else
            {
                bool _S1644 = !_S1509;
                if(_S1644)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1645;
                    if(_S1476)
                    {
                        SampleBSDF _S1646 = (fcptSampleHair((surface_11.hair), (_S1454.material.albedo), (_S1454.material.specular_tint), ((&ray_2)->unit_direction), (surface_11.random_state)));
                        _S1645 = _S1646;
                    }
                    else
                    {
                        SampleBSDF _S1647 = sampleBSDF((&ray_2)->unit_direction, _S1455.smooth_n, _S1454.material, _S1471.x, _S1471.y, surface_11.random_state, _S1526, terms_7, view_terms_7);
                        _S1645 = _S1647;
                    }
                    bsdf_sampled_0 = _S1645;
                    if(_S1476)
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
                            return _S1280;
                        }
                        break;
                    }
                    if(_S1476)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1648 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_11.geometry_n);
                        wrong_side_0 = _S1648;
                    }
                    if(wrong_side_0)
                    {
                        _S1554 = (_S1454.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1554 = false;
                    }
                    if(_S1554)
                    {
                        float _S1649 = _S1471.x;
                        float _S1650 = _S1471.y;
                        ViewTerms _S1651 = precomputeView((&bsdf_sampled_0)->unit_direction, surface_11.geometry_n, _S1454.material, terms_7);
                        SampleBSDF _S1652 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_11.geometry_n, _S1454.material, _S1649, _S1650, (&bsdf_sampled_0)->random_state, _S1526, terms_7, _S1651);
                        (&bsdf_sampled_0)->unit_direction = _S1652.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1652.refracted;
                        (&bsdf_sampled_0)->throughput = _S1652.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1653 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_11.geometry_n)) * surface_11.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1653;
                        }
                    }
                    uint _S1654 = (&bsdf_sampled_0)->lobe;
                    float3  _S1655 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1656 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1657 = (&bsdf_sampled_0)->pdf;
                    float _S1658 = _slang_select(wrong_side_0, 0.0f,_S1657);
                    (&lobe_5)->pdf = _S1658;
                    throughput_12 = _S1655;
                    b_11 = _S1654;
                    refracted_5 = _S1656;
                }
                else
                {
                    throughput_12 = _S1625;
                    b_11 = _S1624;
                    wrong_side_0 = false;
                    refracted_5 = refracted_6;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1554 = true;
            }
            else
            {
                _S1554 = _S1509;
            }
            float3  chain_throughput_1;
            if(_S1554)
            {
                if(_S1476)
                {
                    SampleBSDF _S1659 = (fcptConnectHair((surface_11.hair), (_S1454.material.albedo), (_S1454.material.specular_tint), ((&ray_2)->unit_direction), (throughput_12)));
                    lobe_5 = _S1659;
                }
                else
                {
                    float3  _S1660 = (&ray_2)->unit_direction;
                    float _S1661 = sign_0(_S1456);
                    float3  _S1662 = _S1455.smooth_n * make_float3 (_S1661);
                    float _S1663 = dot_0(_S1662, throughput_12);
                    float _S1664 = _S1454.material.roughness;
                    float _S1665 = _S1664 * _S1664;
                    float3  _S1666 = reflectedHalf(_S1660, throughput_12);
                    bool _S1667 = b_11 == 1U;
                    if(_S1667)
                    {
                        float3  _S1668 = refractedHalf(_S1660, throughput_12, _S1455.smooth_n, _S1471.x, _S1471.y);
                        throughput_13 = _S1668;
                    }
                    else
                    {
                        throughput_13 = _S1666;
                    }
                    bool _S1669 = b_11 == 0U;
                    if(_S1669)
                    {
                        _S1555 = true;
                    }
                    else
                    {
                        _S1555 = b_11 == 6U;
                    }
                    if(_S1555)
                    {
                        float3  _S1670 = sampledHalf(_S1660, _S1455.smooth_n, _S1454.material, surface_11.random_state, view_terms_7);
                        throughput_14 = _S1670;
                    }
                    else
                    {
                        throughput_14 = throughput_13;
                    }
                    float _S1671 = _S1471.x;
                    float _S1672 = _S1471.y;
                    HalfTerms _S1673 = precomputeHalf(_S1660, throughput_14, _S1454.material, _S1671, _S1672, terms_7, view_terms_7);
                    switch(b_11)
                    {
                    case 0U:
                        {
                            float _S1674 = diffusePDF(_S1663, 0.0f, (F32_abs((_S1456))), _S1665, _S1673, _S1671, _S1672);
                            float3  _S1675 = diffuseBSDF(throughput_12, _S1662, _S1665, _S1454.material, _S1673);
                            density_6 = _S1674;
                            chain_throughput_1 = _S1675;
                            break;
                        }
                    case 1U:
                        {
                            float _S1676 = refractPDF(_S1663, dot_0(throughput_12, throughput_14), (F32_abs((_S1456))), _S1665, _S1673, _S1671, _S1672);
                            float3  _S1677 = refractBSDF(throughput_12, _S1662, _S1665, _S1454.material, _S1673);
                            density_6 = _S1676;
                            chain_throughput_1 = _S1677;
                            break;
                        }
                    case 4U:
                        {
                            float _S1678 = sheenVelvetPDF(_S1663, 0.0f, (F32_abs((_S1456))), _S1665, _S1673, _S1671, _S1672);
                            float3  _S1679 = sheenVelvetBSDF(throughput_12, _S1662, _S1665, _S1454.material, _S1673);
                            density_6 = _S1678;
                            chain_throughput_1 = _S1679;
                            break;
                        }
                    case 6U:
                        {
                            float _S1680 = toonPDF(_S1663, dot_0(throughput_12, _S1673.toon_axis), (F32_abs((_S1456))), _S1665, _S1673, _S1671, _S1672);
                            float3  _S1681 = toonBSDF(throughput_12, _S1662, _S1665, _S1454.material, _S1673);
                            density_6 = _S1680;
                            chain_throughput_1 = _S1681;
                            break;
                        }
                    default:
                        {
                            float _S1682 = reflectPDF(_S1663, 0.0f, (F32_abs((_S1456))), _S1665, _S1673, _S1671, _S1672);
                            float3  _S1683 = reflectBSDF(throughput_12, _S1662, _S1665, _S1454.material, _S1673);
                            density_6 = _S1682;
                            chain_throughput_1 = _S1683;
                            break;
                        }
                    }
                    bool _S1684 = density_6 > 0.0f;
                    if(_S1684)
                    {
                        SampleBSDF _S1685 = SampleBSDF_x24init_0(throughput_12, chain_throughput_1, surface_11.random_state, _S1667, b_11, density_6);
                        lobe_5 = _S1685;
                    }
                }
            }
            bool _S1686 = b_11 == 0U;
            if(_S1686)
            {
                _S1555 = true;
            }
            else
            {
                _S1555 = b_11 == 4U;
            }
            if(_S1555)
            {
                _S1602 = true;
            }
            else
            {
                _S1602 = b_11 == 6U;
            }
            if(_S1476)
            {
                _S1603 = false;
            }
            else
            {
                bool _S1687 = !_S1602;
                if(_S1687)
                {
                    bool _S1688 = (_S1454.material.roughness) == 0.0f;
                    if(_S1688)
                    {
                        _S1603 = true;
                    }
                    else
                    {
                        bool _S1689 = b_11 == 1U;
                        if(_S1689)
                        {
                            _S1603 = (_S1471.x) == (_S1471.y);
                        }
                        else
                        {
                            _S1603 = false;
                        }
                    }
                }
                else
                {
                    _S1603 = false;
                }
            }
            if(_S1620)
            {
                _S1604 = b_11 == 1U;
            }
            else
            {
                _S1604 = false;
            }
            if(_S1604)
            {
                straight_0 = (_S1454.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1605 = _S1620;
            }
            else
            {
                _S1605 = false;
            }
            if(_S1605)
            {
                _S1606 = b_11 == 1U;
            }
            else
            {
                _S1606 = false;
            }
            if(_S1606)
            {
                _S1607 = (_S1471.x) == (_S1471.y);
            }
            else
            {
                _S1607 = false;
            }
            BSDFMaterial _S1690 = _S1454.material;
            bool _S1691 = isTranslucent_0(&_S1690);
            if(_S1691)
            {
                _S1608 = _S1686;
            }
            else
            {
                _S1608 = false;
            }
            if(_S1608)
            {
                _S1609 = (dot_0(throughput_12, surface_11.geometry_n)) < 0.0f;
            }
            else
            {
                _S1609 = false;
            }
            if(nee_0)
            {
                _S1610 = !_S1603;
            }
            else
            {
                _S1610 = false;
            }
            if(_S1610)
            {
                _S1611 = !wrong_side_0;
            }
            else
            {
                _S1611 = false;
            }
            if(_S1611)
            {
                float _S1692 = (&lobe_5)->pdf;
                float3  _S1693 = (&ray_2)->origin;
                float3  _S1694 = _slang_select(_S1481, _S1279,_S1455.smooth_n);
                float3  _S1695 = (&ray_2)->origin;
                FKSurface _S1696 = surface_11;
                float3  _S1697 = - _S1455.smooth_n;
                float3  _S1698 = _slang_select(_S1609, _S1697,_S1455.smooth_n);
                NEEVertex _S1699 = NEEVertex_x24init_0(false, _S1692, _S1693, _S1694, _S1695 + make_float3 (_S1696.geometry_offset) * _S1698);
                nee_vertex_0 = _S1699;
            }
            else
            {
                if(_S1476)
                {
                    _S1612 = true;
                }
                else
                {
                    bool _S1700 = b_11 != 1U;
                    if(_S1700)
                    {
                        _S1612 = true;
                    }
                    else
                    {
                        _S1612 = (_S1471.x) != (_S1471.y);
                    }
                }
                if(_S1612)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1701 = withinInverseFootprint((&lobe_5)->pdf, _S1602, (&prev_0)->cos, (&hit_4)->distance, threshold_2);
            bool _S1702 = roughLobe((&lobe_5)->pdf, _S1602, _S1454.material.roughness);
            if(_S1509)
            {
                bool _S1703 = !_S1701;
                if(_S1703)
                {
                    return _S1280;
                }
                bool _S1704 = _S1285 != 1U;
                if(_S1704)
                {
                    _S1612 = _S1285 != 2U;
                }
                else
                {
                    _S1612 = false;
                }
                if(_S1612)
                {
                    float _S1705 = (&lobe_5)->pdf;
                    float _S1706 = _slang_select(nee_0, _S1705,0.0f);
                    float _S1707 = escapeWeight_0(_S1706, _S1625);
                    if(_S1517)
                    {
                        passes_0 = _S1291;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1708 = _slang_select(passes_0, _S1707,1.0f);
                    return Shift_x24init_0(throughput_10 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_8->radiance * make_float3 (_S1708) / make_float3 (r_8->jac), density_4 * (&lobe_5)->pdf / r_8->jac);
                }
                float3  _S1709 = throughput_10 * make_float3 ((&lobe_5)->pdf);
                float _S1710 = density_4 * (&lobe_5)->pdf;
                throughput_13 = _S1709;
                density_6 = _S1710;
            }
            else
            {
                throughput_13 = throughput_10;
                density_6 = density_4;
            }
            uint _S1711 = (fcptLayers((hit_4)));
            bool _S1712 = b_11 == 1U;
            bool _S1713 = passesLayer_0(_S1711, _S1712, passes_0);
            if(viewed_1)
            {
                _S1612 = _S1713;
            }
            else
            {
                _S1612 = false;
            }
            if(_S1612)
            {
                return _S1280;
            }
            if(replay_2)
            {
                _S1613 = b_8 <= _S1295;
            }
            else
            {
                _S1613 = false;
            }
            if(_S1613)
            {
                _S1614 = _S1453;
            }
            else
            {
                _S1614 = false;
            }
            if(_S1614)
            {
                _S1615 = _S1701;
            }
            else
            {
                _S1615 = false;
            }
            if(_S1615)
            {
                _S1616 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1616 = !_S1702;
                }
                else
                {
                    _S1616 = false;
                }
            }
            if(_S1616)
            {
                return _S1280;
            }
            if(viewed_1)
            {
                float3  _S1714 = throughput_13 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1715 = (&lobe_5)->pdf;
                throughput_14 = _S1714;
                sky_pdf_2 = _S1715;
            }
            else
            {
                float3  _S1716 = throughput_13 * max_0((&lobe_5)->throughput, _S1279);
                throughput_14 = _S1716;
                sky_pdf_2 = density_6;
            }
            bool _S1717 = !replay_2;
            bool _S1718;
            if(_S1717)
            {
                _S1718 = !_S1497;
            }
            else
            {
                _S1718 = false;
            }
            bool _S1719;
            if(_S1718)
            {
                _S1719 = _S1453;
            }
            else
            {
                _S1719 = false;
            }
            bool _S1720;
            if(_S1719)
            {
                _S1720 = _S1701;
            }
            else
            {
                _S1720 = false;
            }
            if(_S1720)
            {
                chain_0 = here_0;
                uint _S1721 = insertBits_0((&chain_0)->path, b_11, 18U, 3U);
                uint _S1722 = _slang_select(nee_0, 1U,0U);
                uint _S1723 = insertBits_0(_S1721, _S1722, 21U, 1U);
                (&chain_0)->path = _S1723;
                float _S1724 = (&chain_0)->jac * (&lobe_5)->pdf;
                (&chain_0)->jac = _S1724;
                (&chain_0)->dir = throughput_12;
                chain_throughput_1 = throughput_14;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1725 = surface_11;
            Vertex _S1726 = Vertex_x24init_0(_S1702, b_11, (&lobe_5)->pdf, (F32_abs((dot_0(surface_11.geometry_n, throughput_12)))), is_inside_6);
            prev_0 = _S1726;
            float _S1727 = (&lobe_5)->pdf;
            bool _S1728;
            if(_S1712)
            {
                _S1728 = (_S1471.x) == (_S1471.y);
            }
            else
            {
                _S1728 = false;
            }
            float sky_pdf_3 = _slang_select(_S1728, sky_pdf_0,_S1727);
            float _S1729 = _slang_select(_S1476, 0.0f,sky_pdf_3);
            float _S1730 = widened_0(spread_2, (&lobe_5)->pdf, _S1603);
            bool _S1731;
            if(refracted_5)
            {
                _S1731 = !_S1609;
            }
            else
            {
                _S1731 = false;
            }
            bool is_inside_7;
            if(_S1731)
            {
                bool _S1732 = !is_inside_6;
                is_inside_7 = _S1732;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            FKSurface _S1733 = surface_11;
            bool _S1734 = boundsVolume_0(&_S1733);
            bool _S1735;
            if(_S1734)
            {
                _S1735 = !_S1713;
            }
            else
            {
                _S1735 = false;
            }
            if(_S1735)
            {
                FKSurface faced_2 = surface_11;
                float3  _S1736 = - _S1725.geometry_n;
                float3  _S1737 = _slang_select(turned_1, _S1736,_S1725.geometry_n);
                (&faced_2)->geometry_n = _S1737;
                FKMedium _S1738 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1739 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1740 = faced_2;
                FKMedium _S1741 = _S1738;
                FKMedium _S1742 = _S1739;
                MediumSides _S1743 = mediumSides_0(&_S1740, &_S1741, filling_2, (&ray_2)->unit_direction, &_S1742);
                bool _S1744 = leavesInFront_0((&faced_2)->geometry_n, throughput_12, _S1725.geometry_n);
                float3  _S1745 = _slang_select(_S1744, _S1743.front.scatter,_S1743.behind.scatter);
                scatter_in_0 = _S1745;
                float3  _S1746 = _slang_select(_S1744, _S1743.front.extinction,_S1743.behind.extinction);
                extinction_in_0 = _S1746;
                float _S1747 = _slang_select(_S1744, _S1743.front.g,_S1743.behind.g);
                g_in_0 = _S1747;
                uint _S1748 = _S1743.fillings.x;
                uint _S1749 = _S1743.fillings.y;
                uint _S1750 = _slang_select(_S1744, _S1749,_S1748);
                bool _S1751 = (fcptVaryingUsed());
                uint _S1752 = _slang_select(_S1751, _S1750,4294967295U);
                filling_2 = _S1752;
            }
            (&ray_2)->unit_direction = throughput_12;
            bool _S1753 = !_S1713;
            if(_S1753)
            {
                FKSurface _S1754 = surface_11;
                float _S1755 = _slang_select(straight_0, 0.0f,_S1754.geometry_offset);
                float3  _S1756 = - _S1455.smooth_n;
                bool _S1757 = is_inside_7 != _S1609;
                float3  _S1758 = _slang_select(_S1757, _S1756,_S1455.smooth_n);
                float3  _S1759 = (&ray_2)->origin + make_float3 (_S1755) * _S1758;
                (&ray_2)->origin = _S1759;
            }
            throughput_13 = throughput_14;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1713;
            viewed_1 = _S1607;
            sky_pdf_2 = _S1729;
            spread_5 = _S1730;
            reconnection_0 = reconnection_1;
            is_inside_5 = is_inside_7;
        }
        else
        {
            (&prev_0)->rough = false;
            (&prev_0)->pdf = 0.0f;
            throughput_13 = throughput_10;
            density_6 = density_4;
            passes_0 = false;
            viewed_1 = viewed_0;
            sky_pdf_2 = 0.0f;
            spread_5 = spread_2;
            straight_0 = false;
            is_inside_5 = is_inside_6;
        }
        bool _S1760 = !replay_2;
        float density_7;
        if(_S1760)
        {
            if(_S1421)
            {
                float3  _S1761 = throughput_13 * emission_1;
                Reservoir candidate_8 = chain_0;
                uint _S1762 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1763 = _S1762 == 1U;
                if(_S1763)
                {
                    float3  _S1764 = safeDivide(_S1761, chain_throughput_0);
                    (&candidate_8)->radiance = _S1764;
                }
                Reservoir _S1765 = withEnd(candidate_8, 2U, b_8, _S1761);
                offer(sel_7, _S1765, _S1761 * make_float3 (scale_4) / make_float3 (density_6));
            }
            if(_S1421)
            {
                refracted_5 = true;
            }
            else
            {
                refracted_5 = scatter_2;
            }
            if(refracted_5)
            {
                float _S1766 = survivalProbability(abs_0(throughput_13), density_6);
                density_7 = _S1766;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1767 = stream(_S1307, b_8 + 128U);
            Random _S1768 = pcg(_S1767);
            bool _S1769 = density_7 < (_S1768.value);
            if(_S1769)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1770 = (fcptMaxBounces());
                wrong_side_0 = b_8 >= _S1770;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1771 = density_6 * density_7;
            density_7 = _S1771;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1772 = layer_0 ^ 1U;
        uint _S1773 = _slang_select(passes_0, _S1772,0U);
        if(passes_0)
        {
            (&prev_0)->rough = false;
            (&hit_4)->distance = 0.0f;
            b_11 = b_8;
            viewed_0 = viewed_1;
            throughput_5 = throughput_13;
            density_2 = density_7;
            sky_pdf_0 = sky_pdf_2;
            spread_2 = spread_5;
            uint _S1774 = b_11 + 1U;
            b_8 = _S1774;
            layer_0 = _S1773;
            continue;
        }
        FKRay _S1775 = ray_2;
        float _S1776 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_2)
        {
            refracted_5 = _S1510;
        }
        else
        {
            refracted_5 = false;
        }
        if(refracted_5)
        {
            wrong_side_0 = _S1284 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1777 = _slang_select(wrong_side_0, _S1776,4.294967296e+09f);
        bool _S1778 = !_S1476;
        if(straight_0)
        {
            _S1554 = true;
        }
        else
        {
            _S1554 = _S1476;
        }
        FKHit _S1779;
        if(_S1554)
        {
            _S1779 = hit_4;
        }
        else
        {
            _S1779 = _S1527;
        }
        FKHit _S1780 = (fcptTraverseInstanceBVH((_S1775), (_S1429), (_S1777), (_S1778), (_S1779), (viewed_1)));
        hit_4 = _S1780;
        if(replay_2)
        {
            _S1555 = _S1510;
        }
        else
        {
            _S1555 = false;
        }
        if(_S1555)
        {
            _S1602 = _S1284 == 1U;
        }
        else
        {
            _S1602 = false;
        }
        if(_S1602)
        {
            _S1603 = ((&hit_4)->instance_index) == (_S1296.instance_index);
        }
        else
        {
            _S1603 = false;
        }
        if(_S1603)
        {
            _S1604 = ((&hit_4)->triangle_index) == (_S1296.triangle_index);
        }
        else
        {
            _S1604 = false;
        }
        if(_S1604)
        {
            (&hit_4)->uv = _S1296.uv;
            float _S1781 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S1781;
        }
        if(replay_2)
        {
            _S1605 = _S1510;
        }
        else
        {
            _S1605 = false;
        }
        if(_S1605)
        {
            _S1606 = _S1284 == 3U;
        }
        else
        {
            _S1606 = false;
        }
        if(_S1606)
        {
            _S1607 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1607 = false;
        }
        if(_S1607)
        {
            return _S1280;
        }
        Reservoir _S1782 = chain_0;
        uint _S1783 = filling_2;
        for(;;)
        {
            bool _S1784 = (fcptVaryingUsed());
            if(_S1784)
            {
                _S1608 = _S1783 != 4294967295U;
            }
            else
            {
                _S1608 = false;
            }
            float _S1785;
            if(_S1608)
            {
                float _S1786 = (fcptMajorant((_S1783)));
                _S1785 = _S1786;
            }
            else
            {
                _S1785 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_2)
            {
                _S1609 = _S1510;
            }
            else
            {
                _S1609 = false;
            }
            if(_S1609)
            {
                _S1610 = _S1284 == 1U;
            }
            else
            {
                _S1610 = false;
            }
            if(_S1610)
            {
                _S1611 = _S1785 > 0.0f;
            }
            else
            {
                _S1611 = false;
            }
            if(_S1611)
            {
                ended_0 = _S1280;
                sky_pdf_1 = sky_pdf_2;
                spread_3 = spread_5;
                width_4 = width_3;
                density_3 = density_7;
                throughput_14 = throughput_13;
                b_11 = b_8;
                _S1612 = true;
                break;
            }
            bool _S1787 = (&prev_0)->rough;
            if(_S1787)
            {
                _S1612 = !(_S1785 > 0.0f);
            }
            else
            {
                _S1612 = false;
            }
            (&prev_0)->rough = _S1612;
            uint _S1788 = b_8 + 320U;
            bool _S1789 = b_8 == 4294967295U;
            uint _S1790 = _slang_select(_S1789, 384U,_S1788);
            uint _S1791 = stream(_S1307, _S1790);
            uint tracking_1 = _S1791;
            weight_1 = throughput_6;
            glowed_0 = _S1279;
            b_11 = b_8;
            throughput_14 = throughput_13;
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
                    _S1278 = int(2);
                    break;
                }
                uint _S1792 = b_11 + 320U;
                bool _S1793 = b_11 == 4294967295U;
                uint _S1794 = _slang_select(_S1793, 384U,_S1792);
                uint _S1795 = stream(_S1307, _S1794);
                Random _S1796 = pcg(_S1795);
                float _S1797 = freeFlight_0(_S1796.value, _S1785);
                if(_S1608)
                {
                    float3  _S1798 = (&ray_2)->origin;
                    float3  _S1799 = (&ray_2)->unit_direction;
                    float _S1800 = (&hit_4)->distance;
                    uint _S1801 = _slang_select(_S1793, 0U,b_11);
                    uint _S1802 = (&prev_0)->lobe;
                    uint _S1803 = _slang_select(_S1793, 3U,_S1802);
                    float _S1804 = (fcptTrackMedium((_S1783), (_S1798), (_S1799), (_S1800), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1801), (_S1803), (_S1793)));
                    spread_4 = _S1804;
                }
                else
                {
                    spread_4 = _S1797;
                }
                bool _S1805 = !(spread_4 < ((&hit_4)->distance));
                if(_S1805)
                {
                    _S1278 = int(2);
                    break;
                }
                if(_S1608)
                {
                    _S1613 = _S1760;
                }
                else
                {
                    _S1613 = false;
                }
                if(_S1613)
                {
                    float3  _S1806 = throughput_14 * glowed_0 / make_float3 (density_3);
                    float3  _S1807 = sel_7->glow + _S1806;
                    sel_7->glow = _S1807;
                }
                else
                {
                }
                glowed_0 = _S1279;
                uint b_12 = b_11 + 1U;
                float3  _S1808 = (&ray_2)->origin + make_float3 (spread_4) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1808;
                float3  _S1809 = flightWeight_0(scatter_in_0, extinction_in_0, _S1785, spread_4, true);
                float3  _S1810 = weight_1;
                float3  _S1811 = _slang_select(_S1608, _S1810,_S1809);
                float3  throughput_15 = throughput_14 * _S1811;
                uint _S1812 = stream(_S1307, b_12 + 320U);
                tracking_1 = _S1812;
                weight_1 = throughput_6;
                float width_7 = width_4 + spread_3 * spread_4;
                float _S1813 = spread_3 + 3.14159274101257324f;
                bool _S1814 = scatterSampled_0(replay_2, b_12, _S1295, _S1608);
                TreeSample light_4;
                if(_S1814)
                {
                    float3  _S1815 = (&ray_2)->origin;
                    float3  _S1816 = (&ray_2)->unit_direction;
                    float3  _S1817 = (&ray_2)->unit_direction;
                    uint _S1818 = stream(_S1307, b_12 + 64U);
                    float3  _S1819 = extinction_in_0;
                    float3  _S1820 = extinction_in_0;
                    uint2  _S1821 = make_uint2 (_S1783);
                    float3  _S1822 = (&ray_2)->unit_direction;
                    uint _S1823 = arrivalLobe_0(b_12, (&prev_0)->lobe);
                    FKHit _S1824 = _S1527;
                    ShadowContext _S1825 = ShadowContext_x24init_0(_S1819, _S1820, _S1821, _S1822, b_12, _S1823, false, spread_4, width_7, &_S1824, false);
                    ShadowContext _S1826 = _S1825;
                    TreeSample _S1827 = sampleLightTree_0(_S1815, _S1816, _S1817, 0.0f, true, _S1818, &_S1826);
                    light_4 = _S1827;
                }
                else
                {
                    light_4 = _S1524;
                }
                float _S1828 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1829 = (fcptMaxBounces());
                bool _S1830 = b_12 < _S1829;
                if(_S1830)
                {
                    _S1614 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1614 = false;
                }
                float _S1831 = _slang_select(_S1614, _S1828,0.0f);
                float3  _S1832 = throughput_15 * light_4.radiance;
                float _S1833 = powerHeuristic(light_4.density, _S1831);
                float3  _S1834 = _S1832 * make_float3 (_S1828 * _S1833);
                float3  _S1835 = _slang_select(_S1814, _S1834,_S1279);
                if(replay_2)
                {
                    _S1615 = b_12 == _S1295;
                }
                else
                {
                    _S1615 = false;
                }
                if(_S1615)
                {
                    bool _S1836 = _S1284 == 2U;
                    if(_S1836)
                    {
                        float _S1837 = resamplingTarget(_S1835);
                        _S1616 = _S1837 > 0.0f;
                    }
                    else
                    {
                        _S1616 = false;
                    }
                    if(_S1616)
                    {
                        Shift _S1838 = Shift_x24init_0(_S1835, 1.0f);
                        _S1278 = int(1);
                        ended_0 = _S1838;
                        spread_4 = _S1813;
                        width_5 = width_7;
                        throughput_12 = throughput_15;
                        b_9 = b_12;
                        break;
                    }
                    _S1278 = int(1);
                    ended_0 = _S1280;
                    spread_4 = _S1813;
                    width_5 = width_7;
                    throughput_12 = throughput_15;
                    b_9 = b_12;
                    break;
                }
                if(_S1760)
                {
                    Reservoir candidate_9 = _S1782;
                    uint _S1839 = extractBits_0(_S1782.path, 10U, 2U);
                    bool _S1840 = _S1839 == 1U;
                    if(_S1840)
                    {
                        float3  _S1841 = safeDivide(_S1835, chain_throughput_0);
                        (&candidate_9)->radiance = _S1841;
                    }
                    else
                    {
                        uint _S1842 = insertBits_0(0U, b_12 + 1U, 5U, 5U);
                        uint _S1843 = insertBits_0(_S1842, 2U, 10U, 2U);
                        (&candidate_9)->path = _S1843;
                    }
                    Reservoir _S1844 = withEnd(candidate_9, 0U, b_12, _S1835);
                    offer(sel_7, _S1844, _S1835 * make_float3 (scale_4) / make_float3 (density_3));
                    float _S1845 = survivalProbability(abs_0(throughput_15), density_3);
                    uint _S1846 = stream(_S1307, b_12 + 128U);
                    Random _S1847 = pcg(_S1846);
                    bool _S1848 = _S1845 < (_S1847.value);
                    if(_S1848)
                    {
                        _S1616 = true;
                    }
                    else
                    {
                        uint _S1849 = (fcptMaxBounces());
                        _S1616 = b_12 >= _S1849;
                    }
                    if(_S1616)
                    {
                        _S1278 = int(1);
                        ended_0 = _S1280;
                        spread_4 = _S1813;
                        width_5 = width_7;
                        throughput_12 = throughput_15;
                        b_9 = b_12;
                        break;
                    }
                    float _S1850 = density_3 * _S1845;
                    density_3 = _S1850;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1851 = stream(_S1307, b_12);
                float3  _S1852 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1851, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1852;
                NEEVertex _S1853 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1279, (&ray_2)->origin);
                nee_vertex_0 = _S1853;
                Vertex _S1854 = scatteredVertex_0(is_inside_5);
                prev_0 = _S1854;
                float _S1855 = (&prev_0)->pdf;
                FKRay _S1856 = ray_2;
                FKHit _S1857 = (fcptTraverseInstanceBVH((_S1856), (true), (4.294967296e+09f), (false), (_S1527), (false)));
                hit_4 = _S1857;
                b_11 = b_12;
                throughput_14 = throughput_15;
                spread_3 = _S1813;
                width_4 = width_7;
                sky_pdf_1 = _S1855;
            }
            if(_S1278 != int(2))
            {
                spread_3 = spread_4;
                width_4 = width_5;
                throughput_14 = throughput_12;
                b_11 = b_9;
                _S1612 = true;
                break;
            }
            ended_0 = _S1280;
            _S1612 = false;
            break;
        }
        if(_S1612)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1613 = b_11 == b_8;
        }
        else
        {
            _S1613 = false;
        }
        bool _S1858 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S1858)
        {
            bool _S1859 = !(&nee_vertex_0)->none;
            float _S1860 = _slang_select(_S1859, sky_pdf_1,0.0f);
            float _S1861 = escapeWeight_0(_S1860, (&ray_2)->unit_direction);
            float3  _S1862 = environment_0((&ray_2)->unit_direction, b_11, (&prev_0)->lobe);
            float3  _S1863 = throughput_14 * _S1862;
            if(replay_2)
            {
                bool _S1864 = b_11 == _S1295;
                if(_S1864)
                {
                    passes_0 = _S1284 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1863 * make_float3 (_S1861) / make_float3 (r_8->jac), density_3 / r_8->jac);
                }
                if(_S1294)
                {
                    passes_0 = _S1291;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_11 == _S1282;
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
                    return Shift_x24init_0(_S1863 * make_float3 (_S1861), 1.0f);
                }
                return _S1280;
            }
            Reservoir candidate_10 = chain_0;
            uint _S1865 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1866 = _S1865 == 1U;
            if(_S1866)
            {
                uint _S1867 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1868 = _S1867 == b_11;
                float _S1869 = _slang_select(_S1868, 1.0f,_S1861);
                float3  _S1870 = safeDivide(_S1863 * make_float3 (_S1869), chain_throughput_0);
                (&candidate_10)->radiance = _S1870;
            }
            else
            {
                bool _S1871 = (&prev_0)->rough;
                if(_S1871)
                {
                    uint _S1872 = insertBits_0(0U, b_11 + 1U, 5U, 5U);
                    uint _S1873 = insertBits_0(_S1872, 3U, 10U, 2U);
                    uint _S1874 = insertBits_0(_S1873, (&prev_0)->lobe, 15U, 3U);
                    bool _S1875 = (&prev_0)->inside;
                    uint _S1876 = _slang_select(_S1875, 1U,0U);
                    uint _S1877 = insertBits_0(_S1874, _S1876, 22U, 1U);
                    (&candidate_10)->path = _S1877;
                    (&candidate_10)->jac = (&prev_0)->pdf;
                    (&candidate_10)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1878 = _S1863 * make_float3 (_S1861);
            Reservoir _S1879 = withEnd(candidate_10, 3U, b_11, _S1878);
            offer(sel_7, _S1879, _S1878 * make_float3 (scale_4) / make_float3 (density_3));
            break;
        }
        float3  _S1880 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1880;
        bool _S1881 = (fcptVaryingUsed());
        if(_S1881)
        {
            _S1614 = filling_2 != 4294967295U;
        }
        else
        {
            _S1614 = false;
        }
        if(_S1614)
        {
            if(_S1760)
            {
                float3  _S1882 = throughput_14 * glowed_0 / make_float3 (density_3);
                float3  _S1883 = sel_7->glow + _S1882;
                sel_7->glow = _S1883;
            }
            float3  _S1884 = throughput_14 * weight_1;
            throughput_12 = _S1884;
        }
        else
        {
            float3  _S1885 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S1886 = throughput_14 * _S1885;
            throughput_12 = _S1886;
        }
        float _S1887 = width_4 + spread_3 * (&hit_4)->distance;
        viewed_0 = _S1613;
        width_3 = _S1887;
        throughput_5 = throughput_12;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_2 = spread_3;
        uint _S1774 = b_11 + 1U;
        b_8 = _S1774;
        layer_0 = _S1773;
    }
    return _S1280;
}

static __device__ Shift shift_0(Domain * dom_8, Reservoir * r_9)
{
    Selection _S1888 = (Selection{});
    Selection sel_8 = _S1888;
    bool _S1889 = (r_9->w) <= 0.0f;
    if(_S1889)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S1890 = walk_0(dom_8, r_9, true, 0.0f, &sel_8);
    return _S1890;
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
    Random _S1891 = pcg(state_4);
    Random _S1892 = pcg(_S1891.state);
    float _S1893 = 6.28318548202514648f * _S1891.value;
    float _S1894 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S1892.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1892.state, _S1894 * (F32_cos((_S1893))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_5, float3  value_2)
{
    RandomSphere _S1895;
    (&_S1895)->state = state_5;
    (&_S1895)->value = value_2;
    return _S1895;
}

__device__ RandomSphere random_sphere(uint state_6)
{
    Random _S1896 = normal_distribution(state_6);
    Random _S1897 = normal_distribution(_S1896.state);
    Random _S1898 = normal_distribution(_S1897.state);
    float3  _S1899 = make_float3 (_S1896.value, _S1897.value, _S1898.value);
    float3  _S1900 = ((((_S1899)) * make_float3(rnorm3df(((_S1899)).x, ((_S1899)).y, ((_S1899)).z))));
    return RandomSphere_x24init_0(_S1898.state, _S1900);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_17)
{
    float3  _S1901 = p1_0 - p0_0;
    float3  _S1902 = p2_0 - p0_0;
    float2  _S1903 = uv1_0 - uv0_0;
    float2  _S1904 = uv2_0 - uv0_0;
    float _S1905 = _S1903.x;
    float _S1906 = _S1904.y;
    float _S1907 = _S1903.y;
    float _S1908 = _S1904.x;
    float _S1909 = _S1905 * _S1906 - _S1907 * _S1908;
    float _S1910 = 1.0f / _S1909;
    float3  t_22 = (_S1901 * make_float3 (_S1906) - _S1902 * make_float3 (_S1907)) * make_float3 (_S1910);
    float3  _S1911 = (_S1902 * make_float3 (_S1905) - _S1901 * make_float3 (_S1908)) * make_float3 (_S1910);
    float3  _S1912 = t_22 - n_17 * make_float3 (dot_0(n_17, t_22));
    float3  t_23 = ((((_S1912)) * make_float3(rnorm3df(((_S1912)).x, ((_S1912)).y, ((_S1912)).z))));
    bool _S1913 = (dot_0(cross_0(n_17, t_23), _S1911)) > 0.0f;
    float3  t_24;
    if(_S1913)
    {
        float3  _S1914 = negate_0(t_23);
        t_24 = _S1914;
    }
    else
    {
        t_24 = t_23;
    }
    float3  _S1915 = cross_0(n_17, t_24);
    return makeMatrix<float, 3, 3> (t_24, _S1915, n_17);
}

__device__ float3  tangentToWorldNormalMap(float3  v_4, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_4, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_5, float3  uvw_0, float3  position_0)
{
    float3  _S1916 = t1_0 - t0_0;
    float3  _S1917 = t2_2 - t0_0;
    float3  _S1918 = t2_2 - t1_0;
    float _S1919 = (F32_min((length_0(_S1916)), ((F32_min((length_0(_S1917)), (length_0(_S1918)))))));
    float3  _S1920 = make_float3 (distance_1(position_0, t0_0), distance_1(position_0, t1_0), distance_1(position_0, t2_2));
    float3  _S1921 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1922 = dot_0(geometry_n_5, _S1921);
    float3  _S1923 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1924 = dot_0(geometry_n_5, _S1923);
    float3  _S1925 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1926 = acos_0(abs_0(make_float3 (_S1922, _S1924, dot_0(geometry_n_5, _S1925))));
    float3  _S1927 = clamp_2(tan_0(_S1926), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S1920 * _S1927, uvw_0), 0.0f, _S1919 * 0.125f);
}

__device__ float3  straightThrough(float3  dir_16, float3  n_18, BSDFMaterial material_29)
{
    float3  _S1928 = negate_0(dir_16);
    float _S1929 = sign_0(dot_0(n_18, _S1928));
    float3  _S1930 = n_18 * make_float3 (_S1929);
    AnisotropicFrame _S1931 = anisotropicFrame(material_29, _S1930);
    bool _S1932 = (_S1931.alphas.x) > 0.0f;
    if(_S1932)
    {
        float _S1933 = material_29.transmission * (1.0f - material_29.metallic);
        float3  _S1934 = negate_0(_S1930);
        float3  _S1935 = anisotropicLocal(dir_16, _S1931.tangent, _S1934);
        float _S1936 = anisotropicG1(_S1935, _S1931.alphas);
        return make_float3 (_S1933 * _S1936) * material_29.albedo;
    }
    float _S1937 = material_29.transmission * (1.0f - material_29.metallic);
    float _S1938 = material_29.roughness;
    float _S1939 = smithG1(_S1938 * _S1938, (F32_abs((dot_0(n_18, dir_16)))));
    return make_float3 (_S1937 * _S1939) * material_29.albedo;
}

__device__ float hairRow(float3  in_dir_15, float3  t_25, float3  out_dir_5, uint p_14, float w_2, float alpha_20, uint nt_0)
{
    uint _S1940 = p_14 % 4U;
    float _S1941 = w_2 * HAIR_WIDTHS_0[_S1940];
    float _S1942 = (F32_asin((clamp_1(dot_0(out_dir_5, t_25), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_15, t_25), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1940] * alpha_20;
    return ((F32_asinh((_S1942 / _S1941))) / (F32_asinh((3.14159274101257324f / _S1941))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_16, float3  t_26, float3  out_dir_6, uint np_0)
{
    float3  _S1943 = worldToTangent(out_dir_6, t_26);
    float3  _S1944 = worldToTangent(in_dir_16, t_26);
    return (F32_frac((((F32_atan2((_S1943.z), (_S1943.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1944.z), (1.17549435082228751e-38f - _S1944.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_17, float3  t_27, uint p_15, float row_0, float column_0, float w_3, float alpha_21, uint nt_1, uint np_1)
{
    float3  _S1945 = worldToTangent(in_dir_17, t_27);
    uint _S1946 = p_15 % 4U;
    float _S1947 = w_3 * HAIR_WIDTHS_0[_S1946];
    float _S1948 = (F32_asin((clamp_1(dot_0(in_dir_17, t_27), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1946] * alpha_21 + _S1947 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1947))))));
    float _S1949 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1945.z), (1.17549435082228751e-38f - _S1945.x)));
    float _S1950 = (F32_cos((_S1948)));
    float3  _S1951 = tangentToWorld(make_float3 (_S1950 * (F32_cos((_S1949))), (F32_sin((_S1948))), _S1950 * (F32_sin((_S1949)))), t_27);
    return _S1951;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_19, BSDFMaterial material_30, float coverage_1)
{
    float3  _S1952;
    if((material_30.ior) == 1.0f)
    {
        float3  _S1953 = straightThrough(toward_1, n_19, material_30);
        _S1952 = _S1953;
    }
    else
    {
        _S1952 = make_float3 (0.0f);
    }
    return _S1952 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_9, Reservoir r_10, bool replay_3, float scale_5, Selection * sel_9)
{
    Domain _S1954 = dom_9;
    Reservoir _S1955 = r_10;
    Shift _S1956 = walk_0(&_S1954, &_S1955, replay_3, scale_5, sel_9);
    return _S1956;
}

__device__ Shift shift_hook(Domain dom_10, Reservoir r_11)
{
    Domain _S1957 = dom_10;
    Reservoir _S1958 = r_11;
    Shift _S1959 = shift_0(&_S1957, &_S1958);
    return _S1959;
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
