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

__device__ float importance(LightNode node_0, float3  p_9, float3  normal_0)
{
    float3  _S222 = (node_0.low + node_0.high) * make_float3 (0.5f);
    float3  _S223 = node_0.high - node_0.low;
    float3  _S224 = p_9 - _S222;
    float3  _S225 = ((((_S224)) * make_float3(rnorm3df(((_S224)).x, ((_S224)).y, ((_S224)).z))));
    float _S226 = dot_0(_S224, _S224);
    float _S227 = dot_0(_S223, _S223) / 4.0f;
    float _S228 = (F32_abs((dot_0(node_0.w, _S225))));
    float _S229 = sine(node_0.cos_theta_o);
    float _S230 = (F32_sqrt(((F32_max((1.0f - _S227 / _S226), (0.0f))))));
    bool _S231 = _S226 < _S227;
    float _S232 = _slang_select(_S231, -1.0f,_S230);
    float _S233 = sine(_S232);
    float _S234 = sine(_S228);
    float _S235 = cosSubClamped(_S234, _S228, _S229, node_0.cos_theta_o);
    float _S236 = sine(_S228);
    float _S237 = _S236 * node_0.cos_theta_o - _S228 * _S229;
    bool _S238 = _S228 > (node_0.cos_theta_o);
    float _S239 = _slang_select(_S238, 0.0f,_S237);
    float _S240 = cosSubClamped(_S239, _S235, _S233, _S232);
    bool _S241 = _S240 <= 0.0f;
    if(_S241)
    {
        return 0.0f;
    }
    float _S242 = - dot_0(_S225, normal_0);
    float _S243 = node_0.phi * _S240 / (F32_max((_S226), (length_0(_S223) / 2.0f)));
    float _S244 = sine(_S242);
    float _S245 = cosSubClamped(_S244, _S242, _S233, _S232);
    bool _S246 = (dot_0(normal_0, normal_0)) == 0.0f;
    float _S247 = _slang_select(_S246, 1.0f,_S245);
    return (F32_max((_S243 * _S247), (0.0f)));
}

__device__ __forceinline__ float childShare(LightNode first_0, LightNode second_0, float3  p_10, float3  normal_1, uint child_0)
{
    float _S248 = importance(first_0, p_10, normal_1);
    float _S249 = importance(second_0, p_10, normal_1);
    float2  _S250 = make_float2 (_S248, _S249);
    float _S251 = _slang_vector_get_element(_S250, child_0) / (_S248 + _S249);
    bool _S252 = _slang_vector_get_element(_S250, child_0) > 0.0f;
    float _S253 = _slang_select(_S252, _S251,0.0f);
    return _S253;
}

__device__ float sphereDensity(float3  center_0, float radius_0, float3  p_11)
{
    float3  _S254 = center_0 - p_11;
    float _S255 = radius_0 * radius_0 / dot_0(_S254, _S254);
    bool _S256 = _S255 >= 1.0f;
    if(_S256)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + (F32_sqrt((1.0f - _S255)))) / (6.28318548202514648f * _S255);
}

static __device__ float3  cross_0(float3  left_0, float3  right_0)
{
    float _S257 = left_0.y;
    float _S258 = right_0.z;
    float _S259 = left_0.z;
    float _S260 = right_0.y;
    float _S261 = right_0.x;
    float _S262 = left_0.x;
    return make_float3 (_S257 * _S258 - _S259 * _S260, _S259 * _S261 - _S262 * _S258, _S262 * _S260 - _S257 * _S261);
}

__device__ float solidAngle(float probability_0, float3  normal_2, float3  toward_0)
{
    return 2.0f * probability_0 * (F32_pow((length_0(toward_0)), (3.0f))) / (F32_abs((dot_0(normal_2, toward_0))));
}

static __device__ float lightPdf_0(float3  origin_3, float3  smooth_n_1, float3  start_5, uint j_0, float3  light_point_0)
{
    bool _S263 = j_0 == 4294967295U;
    if(_S263)
    {
        return 0.0f;
    }
    uint4  _S264 = (fcptLightTrail((j_0)));
    uint2  _S265 = uint2 {_S264.x, _S264.y};
    uint n_0 = 0U;
    uint2  trail_0 = _S265;
    float probability_1 = 1.0f;
    for(;;)
    {
        uint4  _S266 = (fcptLightNode((n_0)));
        if((_S266.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S267 = (fcptLightSecond((n_0)));
        uint _S268 = n_0 + 1U;
        LightNode _S269 = (fcptLightBounds((_S268)));
        LightNode _S270 = (fcptLightBounds((_S267)));
        uint _S271 = trail_0.x;
        uint _S272 = _S271 & 1U;
        float _S273 = childShare(_S269, _S270, origin_3, smooth_n_1, _S272);
        float probability_2 = probability_1 * _S273;
        bool _S274 = _S272 == 1U;
        uint _S275 = _slang_select(_S274, _S267,_S268);
        uint _S276 = trail_0.y;
        uint2  _S277 = make_uint2 ((_S271 >> 1U) | (_S276 << 31U), _S276 >> 1U);
        n_0 = _S275;
        trail_0 = _S277;
        probability_1 = probability_2;
    }
    bool _S278 = (fcptSlotLeaf((n_0), (j_0)));
    bool _S279 = !_S278;
    bool _S280;
    if(_S279)
    {
        _S280 = true;
    }
    else
    {
        LightNode _S281 = (fcptLightBounds((n_0)));
        float _S282 = importance(_S281, origin_3, smooth_n_1);
        _S280 = !(_S282 > 0.0f);
    }
    if(_S280)
    {
        _S280 = true;
    }
    else
    {
        bool _S283 = (dot_0(smooth_n_1, smooth_n_1)) > 0.0f;
        if(_S283)
        {
            _S280 = !((dot_0(smooth_n_1, light_point_0 - origin_3)) > 0.0f);
        }
        else
        {
            _S280 = false;
        }
    }
    if(_S280)
    {
        return 0.0f;
    }
    uint4  _S284 = (fcptLightNode((n_0)));
    bool _S285 = (_S284.x) == 2U;
    if(_S285)
    {
        uint _S286 = _S284.y;
        FKLight _S287 = (fcptLight((_S286)));
        FKLight _S288 = (fcptLight((_S286)));
        float _S289 = sphereDensity(_S287.position, _S288.variance, start_5);
        return probability_1 * _S289;
    }
    uint _S290 = _S284.y;
    uint _S291 = (fcptTriangleOffset((_S290)));
    Matrix<float, 3, 3>  _S292 = (fcptWorldTriangle((_S290), (_S291 + _S284.z)));
    float _S293 = solidAngle(probability_1, cross_0(_S292.rows[int(1)] - _S292.rows[int(0)], _S292.rows[int(2)] - _S292.rows[int(0)]), light_point_0 - start_5);
    return _S293;
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
    Random _S294;
    (&_S294)->state = state_0;
    (&_S294)->value = value_0;
    return _S294;
}

__device__ Random pcg(uint state_1)
{
    uint _S295 = hash(state_1);
    float value_1 = float(_S295 >> int(8)) * 5.9604644775390625e-08f;
    return Random_x24init_0(_S295, value_1);
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
    uint2  _S296 = (fcptEnvironmentCdfSize());
    uint2  _S297 = _S296 - make_uint2 (1U, 0U);
    float2  _S298 = make_float2 ((F32_atan2((- dir_2.y), (dir_2.x))) / 6.28318548202514648f + 0.5f, (F32_acos((clamp_1(dir_2.z, -1.0f, 1.0f)))) / 3.14159274101257324f);
    float2  _S299 = make_float2 ((float)_S297.x, (float)_S297.y);
    float2  _S300 = _S298 * _S299;
    uint2  _S301 = make_uint2 ((uint)_S300.x, (uint)_S300.y);
    uint2  _S302 = min_0(_S301, _S297 - make_uint2 (1U));
    float4  _S303 = (fcptEnvironmentCdf((_S302)));
    float _S304 = _S303.y;
    uint _S305 = _S297.x;
    float4  _S306 = (fcptEnvironmentCdf((make_uint2 (_S305, _S302.y))));
    float _S307 = _S304 * _S306.y;
    return _S307 * float(_S305 * _S297.y) / (19.73921012878417969f * length_1(float2 {dir_2.x, dir_2.y}));
}

static __device__ float3  negate_0(float3  x_13)
{
    return - x_13;
}

static __device__ float sign_0(float e_1)
{
    float _S308;
    if(e_1 > 0.0f)
    {
        _S308 = 1.0f;
    }
    else
    {
        if(e_1 < 0.0f)
        {
            _S308 = -1.0f;
        }
        else
        {
            _S308 = 0.0f;
        }
    }
    return _S308;
}

struct AnisotropicFrame
{
    float3  tangent;
    float2  alphas;
};

static __device__ AnisotropicFrame AnisotropicFrame_x24init_0(float3  tangent_0, float2  alphas_0)
{
    AnisotropicFrame _S309;
    (&_S309)->tangent = tangent_0;
    (&_S309)->alphas = alphas_0;
    return _S309;
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_1)
{
    float3  a_1 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S310 = (F32_abs((dot_0(n_1, a_1)))) > 0.9999847412109375f;
    float3  a_2;
    if(_S310)
    {
        float3  _S311 = make_float3 (1.0f, 0.0f, 0.0f);
        a_2 = _S311;
    }
    else
    {
        a_2 = a_1;
    }
    float3  _S312 = cross_0(n_1, a_2);
    float3  _S313 = ((((_S312)) * make_float3(rnorm3df(((_S312)).x, ((_S312)).y, ((_S312)).z))));
    float3  _S314 = cross_0(n_1, _S313);
    return make_float3 (v_0.x) * _S313 + make_float3 (v_0.y) * n_1 + make_float3 (v_0.z) * _S314;
}

__device__ AnisotropicFrame anisotropicFrame(BSDFMaterial material_0, float3  n_i_0)
{
    float _S315 = material_0.roughness;
    float _S316 = _S315 * _S315;
    bool _S317 = (material_0.anisotropy) == 0.0f;
    bool _S318;
    if(_S317)
    {
        _S318 = true;
    }
    else
    {
        _S318 = !(_S316 > 0.0f);
    }
    if(_S318)
    {
        return AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f));
    }
    float3  _S319 = material_0.tangent - n_i_0 * make_float3 (dot_0(n_i_0, material_0.tangent));
    float3  _S320 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_i_0);
    bool _S321 = (dot_0(_S319, _S319)) > 0.0f;
    float3  _S322 = _slang_select(_S321, _S319,_S320);
    float3  _S323 = ((((_S322)) * make_float3(rnorm3df(((_S322)).x, ((_S322)).y, ((_S322)).z))));
    float _S324 = 6.28318548202514648f * material_0.anisotropic_rotation;
    float _S325 = (F32_sqrt((1.0f - 0.89999997615814209f * (F32_abs((material_0.anisotropy))))));
    float _S326 = 1.0f / _S325;
    bool _S327 = (material_0.anisotropy) < 0.0f;
    float _S328 = _slang_select(_S327, _S326,_S325);
    return AnisotropicFrame_x24init_0(_S323 * make_float3 ((F32_cos((_S324)))) + cross_0(n_i_0, _S323) * make_float3 ((F32_sin((_S324)))), make_float2 (_S316 / _S328, _S316 * _S328));
}

struct SheenProfile
{
    bool on;
    float albedo;
};

static __device__ SheenProfile SheenProfile_x24init_0(bool on_0, float albedo_0)
{
    SheenProfile _S329;
    (&_S329)->on = on_0;
    (&_S329)->albedo = albedo_0;
    return _S329;
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
    SheenProfile _S330 = SheenProfile_x24init_0(false, 0.0f);
    float _S331 = rgb_to_greyscale(material_1.sheen);
    bool _S332 = _S331 > 0.0f;
    SheenProfile profile_0;
    if(_S332)
    {
        float _S333 = clamp_1((F32_sqrt(((F32_max((dot_0(n_i_1, v_1)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S334 = (U32_min((uint(_S333)), (22U)));
        float _S335 = (F32_sqrt((0.05000000074505806f)));
        float _S336 = (F32_sqrt((0.00999999977648258f)));
        bool _S337 = (material_1.velvet) > 0.0f;
        float _S338 = _slang_select(_S337, _S336,_S335);
        float _S339 = (clamp_1((F32_sqrt(((F32_max((material_1.sheen_roughness), (0.0f)))))), _S338, 1.0f) - _S338) / (1.0f - _S338) * 23.0f;
        uint _S340 = (U32_min((uint(_S339)), (22U)));
        uint _S341 = _S334 * 24U + _S340;
        float _S342 = _S333 - float(_S334);
        float _S343 = _S339 - float(_S340);
        if(_S337)
        {
            uint _S344 = _S341 + 24U;
            float _S345 = VELVET_ALBEDO_0[_S341] + (VELVET_ALBEDO_0[_S344] - VELVET_ALBEDO_0[_S341]) * _S342;
            uint _S346 = _S341 + 1U;
            float _S347 = VELVET_ALBEDO_0[_S346] + (VELVET_ALBEDO_0[_S344 + 1U] - VELVET_ALBEDO_0[_S346]) * _S342;
            SheenProfile _S348 = SheenProfile_x24init_0(true, _S345 + (_S347 - _S345) * _S343);
            profile_0 = _S348;
        }
        else
        {
            uint _S349 = _S341 + 24U;
            float _S350 = SHEEN_ALBEDO_0[_S341] + (SHEEN_ALBEDO_0[_S349] - SHEEN_ALBEDO_0[_S341]) * _S342;
            uint _S351 = _S341 + 1U;
            float _S352 = SHEEN_ALBEDO_0[_S351] + (SHEEN_ALBEDO_0[_S349 + 1U] - SHEEN_ALBEDO_0[_S351]) * _S342;
            SheenProfile _S353 = SheenProfile_x24init_0(true, (F32_exp((_S350 + (_S352 - _S350) * _S343))));
            profile_0 = _S353;
        }
    }
    else
    {
        profile_0 = _S330;
    }
    return profile_0;
}

struct BSDFLobes
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

static __device__ BSDFLobes BSDFLobes_x24init_0(float v_dot_h_0, float n_dot_h_0, float3  refracted_1, float3  F_0, float F_greyscale_0, float reflect_weight_0, float3  diffuse_weight_0, float3  refract_weight_0, float p_diffuse_0, float p_reflect_0, float p_refract_0, float translucent_share_0, float3  sheen_0, float p_sheen_velvet_0, float3  view_0, float3  tangent_1, float2  alphas_1, float visible_0, float p_toon_0, float3  toon_0, float toon_a_0, float toon_s_0, float toon_b_0, bool toon_glossy_0, float toon_norm_0, float toon_view_0, float3  toon_axis_0)
{
    BSDFLobes _S354;
    (&_S354)->v_dot_h = v_dot_h_0;
    (&_S354)->n_dot_h = n_dot_h_0;
    (&_S354)->refracted = refracted_1;
    (&_S354)->F = F_0;
    (&_S354)->F_greyscale = F_greyscale_0;
    (&_S354)->reflect_weight = reflect_weight_0;
    (&_S354)->diffuse_weight = diffuse_weight_0;
    (&_S354)->refract_weight = refract_weight_0;
    (&_S354)->p_diffuse = p_diffuse_0;
    (&_S354)->p_reflect = p_reflect_0;
    (&_S354)->p_refract = p_refract_0;
    (&_S354)->translucent_share = translucent_share_0;
    (&_S354)->sheen = sheen_0;
    (&_S354)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S354)->view = view_0;
    (&_S354)->tangent = tangent_1;
    (&_S354)->alphas = alphas_1;
    (&_S354)->visible = visible_0;
    (&_S354)->p_toon = p_toon_0;
    (&_S354)->toon = toon_0;
    (&_S354)->toon_a = toon_a_0;
    (&_S354)->toon_s = toon_s_0;
    (&_S354)->toon_b = toon_b_0;
    (&_S354)->toon_glossy = toon_glossy_0;
    (&_S354)->toon_norm = toon_norm_0;
    (&_S354)->toon_view = toon_view_0;
    (&_S354)->toon_axis = toon_axis_0;
    return _S354;
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
    float3  _S355 = make_float3 (alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z);
    float3  _S356 = ((((_S355)) * make_float3(rnorm3df(((_S355)).x, ((_S355)).y, ((_S355)).z))));
    float _S357 = _S356.x;
    float _S358 = _S356.y;
    float _S359 = _S357 * _S357 + _S358 * _S358;
    float3  _S360;
    if(_S359 > 0.0f)
    {
        float3  _S361 = make_float3 (- _S358, _S357, 0.0f);
        float _S362 = (rsqrtf((_S359)));
        _S360 = _S361 * make_float3 (_S362);
    }
    else
    {
        _S360 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S363 = cross_0(_S356, _S360);
    float _S364 = (F32_sqrt((U1_0)));
    float _S365 = 6.28318548202514648f * U2_0;
    float _S366 = _S364 * (F32_cos((_S365)));
    float t2_0 = _S364 * (F32_sin((_S365)));
    float _S367 = 0.5f * (1.0f + _S356.z);
    float t2_1 = (1.0f - _S367) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S366 * _S366)))))) + _S367 * t2_0;
    float3  _S368 = make_float3 (_S366) * _S360 + make_float3 (t2_1) * _S363;
    float _S369 = unshared_0(_S366);
    float _S370 = unshared_0(_S366);
    float3  _S371 = _S368 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S369 * _S370 - t2_1 * t2_1))))))) * _S356;
    float3  _S372 = make_float3 (alpha_0 * _S371.x, alpha_0 * _S371.y, (F32_max((0.0f), (_S371.z))));
    float3  _S373 = ((((_S372)) * make_float3(rnorm3df(((_S372)).x, ((_S372)).y, ((_S372)).z))));
    return _S373;
}

__device__ float3  worldToTangent(float3  v_2, float3  n_3)
{
    float3  a_3 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S374 = (F32_abs((dot_0(n_3, a_3)))) > 0.9999847412109375f;
    float3  a_4;
    if(_S374)
    {
        float3  _S375 = make_float3 (1.0f, 0.0f, 0.0f);
        a_4 = _S375;
    }
    else
    {
        a_4 = a_3;
    }
    float3  _S376 = cross_0(n_3, a_4);
    float3  _S377 = ((((_S376)) * make_float3(rnorm3df(((_S376)).x, ((_S376)).y, ((_S376)).z))));
    float3  _S378 = cross_0(n_3, _S377);
    return make_float3 (dot_0(v_2, _S377), dot_0(v_2, n_3), dot_0(v_2, _S378));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_3, float3  n_i_2, float alpha_1, AnisotropicFrame frame_0, uint * random_state_2)
{
    Random _S379 = pcg(*random_state_2);
    Random _S380 = pcg(_S379.state);
    *random_state_2 = _S380.state;
    float _S381 = frame_0.alphas.x;
    bool _S382 = _S381 > 0.0f;
    if(_S382)
    {
        float3  _S383 = anisotropicLocal(v_3, frame_0.tangent, n_i_2);
        float _S384 = frame_0.alphas.y;
        float3  _S385 = make_float3 (_S381 * _S383.x, _S384 * _S383.y, _S383.z);
        float3  _S386 = ((((_S385)) * make_float3(rnorm3df(((_S385)).x, ((_S385)).y, ((_S385)).z))));
        float3  _S387 = sampleGGXVNDF(_S386, 1.0f, _S379.value, _S380.value);
        float3  _S388 = make_float3 (_S381 * _S387.x, _S384 * _S387.y, _S387.z);
        float3  _S389 = ((((_S388)) * make_float3(rnorm3df(((_S388)).x, ((_S388)).y, ((_S388)).z))));
        return make_float3 (_S389.x) * frame_0.tangent + make_float3 (_S389.y) * cross_0(n_i_2, frame_0.tangent) + make_float3 (_S389.z) * n_i_2;
    }
    float3  _S390 = worldToTangent(v_3, n_i_2);
    float3  _S391 = sampleGGXVNDF(float3 {_S390.x, _S390.z, _S390.y}, alpha_1, _S379.value, _S380.value);
    float3  _S392 = float3 {_S391.x, _S391.z, _S391.y};
    float3  _S393 = tangentToWorld(_S392, n_i_2);
    return _S393;
}

__device__ float3  sampledHalf(float3  in_dir_0, float3  n_4, BSDFMaterial material_2, uint random_state_3, AnisotropicFrame frame_1)
{
    uint state_2 = random_state_3;
    float3  _S394 = negate_0(in_dir_0);
    float _S395 = sign_0(dot_0(n_4, _S394));
    float _S396 = material_2.roughness;
    float3  _S397 = sampleHalfVector(_S394, n_4 * make_float3 (_S395), _S396 * _S396, frame_1, &state_2);
    return _S397;
}

__device__ float3  refractedHalf(float3  in_dir_1, float3  out_dir_0, float3  n_5, float eta_i_0, float eta_o_0)
{
    float3  _S398 = negate_0(in_dir_1);
    float3  _S399 = negate_0(make_float3 (eta_i_0) * _S398 + make_float3 (eta_o_0) * out_dir_0);
    float3  _S400 = ((((_S399)) * make_float3(rnorm3df(((_S399)).x, ((_S399)).y, ((_S399)).z))));
    float _S401 = sign_0(dot_0(n_5, _S398));
    float _S402 = sign_0(dot_0(_S399, n_5 * make_float3 (_S401)));
    return _S400 * make_float3 (_S402);
}

__device__ float3  reflectedHalf(float3  in_dir_2, float3  out_dir_1)
{
    float3  _S403 = negate_0(in_dir_2);
    float3  _S404 = _S403 + out_dir_1;
    float3  _S405 = ((((_S404)) * make_float3(rnorm3df(((_S404)).x, ((_S404)).y, ((_S404)).z))));
    return _S405;
}

static __device__ float3  refract_0(float3  i_5, float3  n_6, float eta_0)
{
    float _S406 = dot_0(n_6, i_5);
    float _S407 = 1.0f - eta_0 * eta_0 * (1.0f - _S406 * _S406);
    if(_S407 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_5 - make_float3 (eta_0 * _S406 + (F32_sqrt((_S407)))) * n_6;
}

__device__ float fresnel(float cos_theta_0, float eta_i_1, float eta_o_1)
{
    float _S408 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S409 = eta_i_1 / eta_o_1 * _S408;
    bool _S410 = _S409 < 1.0f;
    float kr_0;
    if(_S410)
    {
        float _S411 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S409 * _S409))))));
        bool _S412 = eta_i_1 == eta_o_1;
        float _S413 = _slang_select(_S412, cos_theta_0,_S411);
        float _S414 = eta_o_1 * cos_theta_0;
        float _S415 = eta_i_1 * _S413;
        float _S416 = (_S414 - _S415) / (_S414 + _S415);
        float _S417 = eta_i_1 * cos_theta_0;
        float _S418 = eta_o_1 * _S413;
        float _S419 = (_S417 - _S418) / (_S417 + _S418);
        float _S420 = (_S416 * _S416 + _S419 * _S419) / 2.0f;
        kr_0 = _S420;
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
    float _S421 = (F32_max((w_1.z), (0.0f)));
    return 2.0f * _S421 / (_S421 + length_0(make_float3 (alphas_2.x * w_1.x, alphas_2.y * w_1.y, _S421)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_3)
{
    float _S422 = alphas_3.x;
    float _S423 = h_0.x / _S422;
    float _S424 = alphas_3.y;
    float _S425 = h_0.y / _S424;
    float _S426 = h_0.z;
    float _S427 = _S423 * _S423 + _S425 * _S425 + _S426 * _S426;
    return 1.0f / (F32_max((3.14159274101257324f * _S422 * _S424 * _S427 * _S427), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ BSDFLobes bsdfLobes(float3  in_dir_3, float3  v_4, float3  n_i_3, float3  ggx_n_0, BSDFMaterial material_3, float eta_i_2, float eta_o_2, AnisotropicFrame frame_2, SheenProfile sheen_profile_0)
{
    float _S428 = dot_0(ggx_n_0, v_4);
    float _S429 = dot_0(n_i_3, ggx_n_0);
    float _S430 = eta_i_2 / eta_o_2;
    float3  _S431 = refract_0(in_dir_3, ggx_n_0, _S430);
    float3  _S432 = ((((_S431)) * make_float3(rnorm3df(((_S431)).x, ((_S431)).y, ((_S431)).z))));
    float _S433 = (F32_min(((F32_sqrt((material_3.specular_level))) * (F32_abs((eta_i_2 - eta_o_2))) / (eta_i_2 + eta_o_2)), (0.9999847412109375f)));
    float _S434 = _S433 * _S433;
    float _S435 = (1.0f + _S433) / (1.0f - _S433);
    float _S436 = (F32_abs((_S428)));
    bool _S437 = eta_i_2 > eta_o_2;
    float sheen_component_0;
    if(_S437)
    {
        sheen_component_0 = _S435;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    float toon_component_0;
    if(_S437)
    {
        toon_component_0 = 1.0f;
    }
    else
    {
        toon_component_0 = _S435;
    }
    float _S438 = fresnel(_S436, sheen_component_0, toon_component_0);
    bool _S439 = (eta_i_2 * eta_i_2 * (1.0f - _S428 * _S428)) >= (eta_o_2 * eta_o_2);
    float3  _S440;
    if(_S439)
    {
        _S440 = make_float3 (1.0f);
    }
    else
    {
        float3  _S441 = material_3.specular_tint * make_float3 (_S434);
        _S440 = _S441 + (make_float3 (1.0f) - _S441) * make_float3 (_S438 - _S434) / make_float3 (1.0f - _S434);
    }
    float3  _S442 = make_float3 (1.0f);
    float3  _S443 = make_float3 (0.0f);
    float3  sheen_1;
    float3  view_1;
    float3  scale_1;
    if(sheen_profile_0.on)
    {
        float _S444 = (F32_min((sheen_profile_0.albedo), (1.0f)));
        float3  _S445 = make_float3 (1.0f) - material_3.sheen * make_float3 (_S444);
        float _S446 = rgb_to_greyscale(material_3.sheen);
        float _S447 = _S446 * _S444;
        float3  _S448 = material_3.sheen / make_float3 ((F32_max((sheen_profile_0.albedo), (1.0f))));
        sheen_component_0 = _S447;
        sheen_1 = _S448;
        view_1 = v_4;
        scale_1 = _S445;
    }
    else
    {
        sheen_component_0 = 0.0f;
        sheen_1 = _S443;
        view_1 = _S443;
        scale_1 = _S442;
    }
    float _S449 = material_3.toon.x;
    bool _S450 = _S449 < 0.0f;
    float _S451 = (F32_abs((_S449)));
    bool _S452 = _S451 > 0.0f;
    float toon_a_1;
    float toon_s_1;
    float toon_b_1;
    float toon_norm_1;
    float toon_view_1;
    float3  toon_1;
    float3  toon_axis_1;
    bool _S453;
    if(_S452)
    {
        float _S454 = (F32_min((_S451), (1.0f)));
        float3  scale_2 = scale_1 * make_float3 (1.0f - _S454);
        float _S455 = rgb_to_greyscale(material_3.albedo);
        float _S456 = _S454 * _S455;
        float3  _S457 = make_float3 (_S454) * material_3.albedo;
        float toon_a_2 = clamp_1(material_3.toon.y / _S449, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
        float toon_s_2 = clamp_1(material_3.toon.z / _S449, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
        float _S458 = (F32_min((toon_a_2 + toon_s_2), (1.57079637050628662f)));
        if(_S450)
        {
            toon_component_0 = 1.0f - (F32_cos(((F32_min((_S458), (toon_a_2))))));
        }
        else
        {
            float _S459 = (F32_sin(((F32_min((_S458), (toon_a_2))))));
            toon_component_0 = _S459 * _S459 / 2.0f;
        }
        bool _S460 = _S458 > toon_a_2;
        if(_S460)
        {
            _S453 = toon_s_2 > 0.0f;
        }
        else
        {
            _S453 = false;
        }
        if(_S453)
        {
            if(_S450)
            {
                float _S461 = (F32_cos((toon_a_2)));
                float _S462 = (F32_cos((_S458)));
                toon_a_1 = (1.0f + toon_a_2 / toon_s_2) * (_S461 - _S462) - ((F32_sin((_S458))) - _S458 * _S462 - ((F32_sin((toon_a_2))) - toon_a_2 * _S461)) / toon_s_2;
            }
            else
            {
                float _S463 = 2.0f * toon_a_2;
                float _S464 = (F32_cos((_S463)));
                float _S465 = 2.0f * _S458;
                float _S466 = (F32_cos((_S465)));
                toon_a_1 = (1.0f + toon_a_2 / toon_s_2) * (_S464 - _S466) / 4.0f - ((F32_sin((_S465))) / 8.0f - _S458 * _S466 / 4.0f - ((F32_sin((_S463))) / 8.0f - toon_a_2 * _S464 / 4.0f)) / toon_s_2;
            }
            float integral_0 = toon_component_0 + toon_a_1;
            toon_component_0 = integral_0;
        }
        float _S467 = 6.28318548202514648f * toon_component_0;
        float _S468 = dot_0(n_i_3, v_4);
        float _S469 = (F32_acos(((F32_min((_S468), (1.0f))))));
        if(_S469 < toon_a_2)
        {
            toon_component_0 = 1.0f;
        }
        else
        {
            toon_component_0 = (F32_max((1.0f - (_S469 - toon_a_2) / (F32_max((toon_s_2), (0.0000152587890625f)))), (0.0f)));
        }
        if(_S450)
        {
            float3  _S470 = make_float3 (2.0f * _S468) * n_i_3 - v_4;
            float3  _S471 = ((((_S470)) * make_float3(rnorm3df(((_S470)).x, ((_S470)).y, ((_S470)).z))));
            scale_1 = _S471;
        }
        else
        {
            scale_1 = n_i_3;
        }
        float _S472 = toon_component_0;
        toon_component_0 = _S456;
        toon_1 = _S457;
        toon_a_1 = toon_a_2;
        toon_s_1 = toon_s_2;
        toon_b_1 = _S458;
        toon_norm_1 = _S467;
        toon_view_1 = _S472;
        toon_axis_1 = scale_1;
        scale_1 = scale_2;
    }
    else
    {
        toon_component_0 = 0.0f;
        toon_1 = _S443;
        toon_a_1 = 0.0f;
        toon_s_1 = 0.0f;
        toon_b_1 = 0.0f;
        toon_norm_1 = 1.0f;
        toon_view_1 = 0.0f;
        toon_axis_1 = n_i_3;
    }
    float3  _S473 = mix_0(_S440, material_3.albedo, material_3.metallic);
    float3  F_1 = _S473 * scale_1;
    float _S474 = rgb_to_greyscale(F_1);
    float _S475 = 1.0f - material_3.metallic;
    float3  _S476 = make_float3 (1.0f) - _S440;
    float3  _S477 = make_float3 ((1.0f - material_3.transmission) * _S475) * _S476 * scale_1;
    float3  _S478 = make_float3 (material_3.transmission * _S475) * _S476 * scale_1;
    float _S479 = (F32_max((_S474), (0.0f)));
    float _S480 = rgb_to_greyscale(_S477);
    float _S481 = (F32_max((_S480), (0.0f)));
    float _S482 = rgb_to_greyscale(_S478);
    float _S483 = sign_0(length_0(_S432));
    float _S484 = (F32_max((_S482 * _S483), (0.0f)));
    float _S485 = _S479 + _S481 + _S484 + toon_component_0;
    float _S486 = (F32_min((sheen_component_0), (1.0f)));
    bool _S487 = sheen_component_0 > 0.0f;
    if(_S487)
    {
        _S453 = !(_S485 > 0.0f);
    }
    else
    {
        _S453 = false;
    }
    float _S488 = _slang_select(_S453, 1.0f,_S486);
    float _S489 = (1.0f - _S488) / (F32_max((_S485), (0.0000152587890625f)));
    float _S490 = _S481 * _S489;
    float _S491 = _S479 * _S489;
    float _S492 = _S484 * _S489;
    bool _S493 = (frame_2.alphas.x) > 0.0f;
    float visible_1;
    if(_S493)
    {
        float3  _S494 = anisotropicLocal(v_4, frame_2.tangent, n_i_3);
        float _S495 = anisotropicG1(_S494, frame_2.alphas);
        float3  _S496 = anisotropicLocal(ggx_n_0, frame_2.tangent, n_i_3);
        float _S497 = anisotropicD(_S496, frame_2.alphas);
        float _S498 = _S495 * _S497;
        visible_1 = _S498;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S428, _S429, _S432, F_1, _S474, 1.0f, _S477, _S478, _S490, _S491, _S492, 0.0f, sheen_1, _S488, view_1, frame_2.tangent, frame_2.alphas, visible_1, toon_component_0 * _S489, toon_1, toon_a_1, toon_s_1, toon_b_1, _S450, toon_norm_1, toon_view_1, toon_axis_1);
}

__device__ float translucentShare(BSDFMaterial material_4)
{
    float _S499 = rgb_to_greyscale(material_4.translucent);
    float _S500 = rgb_to_greyscale(material_4.albedo);
    float _S501 = _S499 / (_S500 + _S499);
    bool _S502 = _S499 > 0.0f;
    float _S503 = _slang_select(_S502, _S501,0.0f);
    return _S503;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_2, BSDFLobes lobes_0, float eta_i_3, float eta_o_3)
{
    float _S504 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S505 = lobes_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S506 = 1.0f - lobes_0.translucent_share;
    bool _S507 = n_i_dot_l_0 < 0.0f;
    float _S508 = _slang_select(_S507, lobes_0.translucent_share,_S506);
    float _S509 = _S505 * _S508;
    bool _S510 = (lobes_0.translucent_share) > 0.0f;
    float _S511 = _slang_select(_S510, _S509,_S504);
    bool _S512 = n_i_dot_v_0 > 0.0f;
    float _S513 = _slang_select(_S512, _S511,0.0f);
    return _S513;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_4, float alpha_3, BSDFMaterial material_5, BSDFLobes lobes_1)
{
    bool _S514 = (dot_0(n_i_4, l_0)) < 0.0f;
    float3  _S515 = _slang_select(_S514, material_5.translucent,material_5.albedo);
    float _S516 = 1.0f - lobes_1.translucent_share;
    float _S517 = _slang_select(_S514, lobes_1.translucent_share,_S516);
    float3  _S518 = _S515 / make_float3 (_S517);
    bool _S519 = (lobes_1.translucent_share) > 0.0f;
    float3  _S520 = _slang_select(_S519, _S518,material_5.albedo);
    return lobes_1.diffuse_weight * _S520 / make_float3 (lobes_1.p_diffuse);
}

__device__ float smithG1(float alpha_4, float n_dot_x_0)
{
    float _S521 = alpha_4 * alpha_4;
    float _S522 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S521 + (1.0f - _S521) * n_dot_x_0 * n_dot_x_0))));
    bool _S523 = alpha_4 > 0.0f;
    float _S524 = _slang_select(_S523, _S522,1.0f);
    return _S524;
}

__device__ float trowbridgeReitz(float alpha_5, float n_dot_h_1)
{
    float _S525 = alpha_5 * alpha_5;
    float _S526 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S525 * n_dot_h_1 * n_dot_h_1;
    return _S525 / (F32_max((3.14159274101257324f * _S526 * _S526), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float n_i_dot_v_1, float alpha_6, BSDFLobes lobes_2)
{
    float _S527 = smithG1(alpha_6, n_i_dot_v_1);
    float _S528 = _S527 * lobes_2.v_dot_h;
    float _S529 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    float _S530 = _S528 * _S529 / n_i_dot_v_1;
    bool _S531 = alpha_6 > 0.0f;
    bool _S532;
    if(_S531)
    {
        _S532 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S532 = false;
    }
    if(_S532)
    {
        _S532 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S532 = false;
    }
    if(_S532)
    {
        _S532 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S532 = false;
    }
    float _S533 = _slang_select(_S532, _S530,0.0f);
    bool _S534 = (lobes_2.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S534)
    {
        float _S535 = lobes_2.visible * lobes_2.v_dot_h / n_i_dot_v_1;
        bool _S536 = (lobes_2.v_dot_h) > 0.0f;
        if(_S536)
        {
            _S532 = (lobes_2.n_dot_h) > 0.0f;
        }
        else
        {
            _S532 = false;
        }
        if(_S532)
        {
            _S532 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S532 = false;
        }
        float _S537 = _slang_select(_S532, _S535,0.0f);
        pdf_h_0 = _S537;
    }
    else
    {
        pdf_h_0 = _S533;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float n_i_dot_l_1, float l_dot_h_1, float n_i_dot_v_2, float alpha_7, BSDFLobes lobes_3, float eta_i_4, float eta_o_4)
{
    float _S538 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    float _S539 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    float _S540 = lobes_3.p_refract * _S538 * eta_o_4 * eta_o_4 * (F32_abs((l_dot_h_1))) / (_S539 * _S539);
    bool _S541 = eta_i_4 != eta_o_4;
    bool _S542;
    if(_S541)
    {
        _S542 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S542 = false;
    }
    float _S543 = _slang_select(_S542, _S540,0.0f);
    return _S543;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_5, float alpha_8, BSDFMaterial material_6, BSDFLobes lobes_4)
{
    float _S544 = - dot_0(n_i_5, l_1);
    float _S545 = smithG1(alpha_8, (F32_max((_S544), (0.0f))));
    bool _S546 = (lobes_4.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S546)
    {
        float3  _S547 = negate_0(n_i_5);
        float3  _S548 = anisotropicLocal(l_1, lobes_4.tangent, _S547);
        float _S549 = anisotropicG1(_S548, lobes_4.alphas);
        G1_l_0 = _S549;
    }
    else
    {
        G1_l_0 = _S545;
    }
    return lobes_4.refract_weight * make_float3 (G1_l_0) * material_6.albedo / make_float3 (lobes_4.p_refract);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_2, float l_dot_h_2, float n_i_dot_v_3, float alpha_9, BSDFLobes lobes_5, float eta_i_5, float eta_o_5)
{
    float _S550 = lobes_5.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S551 = n_i_dot_l_2 > 0.0f;
    bool _S552;
    if(_S551)
    {
        _S552 = n_i_dot_v_3 > 0.0f;
    }
    else
    {
        _S552 = false;
    }
    float _S553 = _slang_select(_S552, _S550,0.0f);
    return _S553;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  n_i_6, float alpha_10, BSDFMaterial material_7, BSDFLobes lobes_6)
{
    float3  _S554 = l_2 + lobes_6.view;
    float3  _S555 = ((((_S554)) * make_float3(rnorm3df(((_S554)).x, ((_S554)).y, ((_S554)).z))));
    float _S556 = dot_0(n_i_6, _S555);
    float _S557 = (F32_max((dot_0(n_i_6, l_2)), (0.0f)));
    float _S558 = (F32_max((dot_0(n_i_6, lobes_6.view)), (0.0f)));
    float _S559 = 1.0f / (F32_max((material_7.sheen_roughness), (0.05000000074505806f)));
    float _S560 = 1.0f - _S556 * _S556;
    float _S561 = (2.0f + _S559) * (F32_pow(((F32_max((_S560), (0.0f)))), (0.5f * _S559))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S557 + _S558 - _S557 * _S558)), (0.0000152587890625f)));
    bool _S562 = (material_7.velvet) > 0.0f;
    float f_1;
    if(_S562)
    {
        float _S563 = (F32_max((material_7.sheen_roughness), (0.00999999977648258f)));
        float _S564 = _S563 * _S563;
        float _S565 = (F32_max((_S560), (0.0000152587890625f)));
        float _S566 = (F32_exp((- _S556 * _S556 / (_S565 * _S564)))) / (3.14159274101257324f * _S564 * _S565 * _S565) * (F32_min((1.0f), (2.0f * _S556 * (F32_min((_S557), (_S558))) / (F32_max(((F32_abs((dot_0(_S555, lobes_6.view))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S557 * _S558), (0.0000152587890625f)));
        f_1 = _S566;
    }
    else
    {
        f_1 = _S561;
    }
    return lobes_6.sheen * make_float3 (f_1 * _S557 * 2.0f * 3.14159274101257324f / lobes_6.p_sheen_velvet);
}

__device__ __forceinline__ float toonPDF(float n_i_dot_l_3, float l_dot_h_3, float n_i_dot_v_4, float alpha_11, BSDFLobes lobes_7, float eta_i_6, float eta_o_6)
{
    float _S567 = _slang_select(lobes_7.toon_glossy, l_dot_h_3,n_i_dot_l_3);
    float _S568 = (F32_acos((clamp_1(_S567, -1.0f, 1.0f))));
    float _S569;
    if(_S568 < (lobes_7.toon_a))
    {
        _S569 = 1.0f;
    }
    else
    {
        _S569 = (F32_max((1.0f - (_S568 - lobes_7.toon_a) / (F32_max((lobes_7.toon_s), (0.0000152587890625f)))), (0.0f)));
    }
    float _S570 = lobes_7.p_toon * _S569;
    float _S571 = _slang_select(lobes_7.toon_glossy, 1.0f,n_i_dot_l_3);
    float _S572 = _S570 * _S571 / lobes_7.toon_norm;
    bool _S573;
    if(lobes_7.toon_glossy)
    {
        _S573 = true;
    }
    else
    {
        _S573 = n_i_dot_l_3 > 0.0f;
    }
    float _S574 = _slang_select(_S573, _S572,0.0f);
    return _S574;
}

__device__ __forceinline__ float3  toonBSDF(float3  l_3, float3  n_i_7, float alpha_12, BSDFMaterial material_8, BSDFLobes lobes_8)
{
    float _S575 = (F32_max((dot_0(n_i_7, l_3)), (0.0f)));
    float _S576 = _slang_select(lobes_8.toon_glossy, _S575,lobes_8.toon_view);
    return lobes_8.toon * make_float3 (_S576) / make_float3 (lobes_8.p_toon);
}

__device__ __forceinline__ float reflectPDF(float n_i_dot_l_4, float l_dot_h_4, float n_i_dot_v_5, float alpha_13, BSDFLobes lobes_9, float eta_i_7, float eta_o_7)
{
    float _S577 = vndfPDF(n_i_dot_v_5, alpha_13, lobes_9);
    float _S578 = lobes_9.p_reflect * _S577 / (4.0f * lobes_9.v_dot_h);
    bool _S579 = _S577 > 0.0f;
    float _S580 = _slang_select(_S579, _S578,0.0f);
    return _S580;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_4, float3  n_i_8, float alpha_14, BSDFMaterial material_9, BSDFLobes lobes_10)
{
    float _S581 = dot_0(n_i_8, l_4);
    float _S582 = smithG1(alpha_14, (F32_max((_S581), (0.0f))));
    bool _S583 = (lobes_10.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S583)
    {
        float3  _S584 = anisotropicLocal(l_4, lobes_10.tangent, n_i_8);
        float _S585 = anisotropicG1(_S584, lobes_10.alphas);
        G1_l_1 = _S585;
    }
    else
    {
        G1_l_1 = _S582;
    }
    return make_float3 (lobes_10.reflect_weight * G1_l_1) * lobes_10.F / make_float3 (lobes_10.p_reflect);
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_4, float3  out_dir_2, float3  n_7, BSDFMaterial material_10, float eta_i_8, float eta_o_8, bool refracted_2, uint random_state_4, FixedArray<float3 , 5>  * throughputs_0, FixedArray<float, 5>  * pdfs_0)
{
    float3  ggx_n_1;
    float3  _S586 = negate_0(in_dir_4);
    float _S587 = dot_0(n_7, _S586);
    float _S588 = sign_0(_S587);
    float3  _S589 = n_7 * make_float3 (_S588);
    AnisotropicFrame _S590 = anisotropicFrame(material_10, _S589);
    float _S591 = dot_0(_S589, out_dir_2);
    float _S592 = material_10.roughness;
    float _S593 = _S592 * _S592;
    SheenProfile _S594 = sheenProfile(_S586, _S589, material_10);
    float _S595 = rgb_to_greyscale(material_10.translucent);
    bool _S596 = _S595 > 0.0f;
    bool _S597 = (dot_0(n_7, out_dir_2) * _S587) < 0.0f;
    uint _S598;
    if((F32_abs((material_10.toon.x))) > 0.0f)
    {
        _S598 = 5U;
    }
    else
    {
        _S598 = 4U;
    }
    uint i_6 = 0U;
    for(;;)
    {
        if(i_6 < 5U)
        {
        }
        else
        {
            break;
        }
        float3  _S599 = make_float3 (0.0f);
        (*throughputs_0)[i_6] = _S599;
        (*pdfs_0)[i_6] = 0.0f;
        uint i_7 = i_6 + 1U;
        i_6 = i_7;
    }
    float3  _S600 = make_float3 (0.0f);
    BSDFLobes _S601 = BSDFLobes_x24init_0(0.0f, 0.0f, _S600, _S600, 0.0f, 0.0f, _S600, _S600, 0.0f, 0.0f, 0.0f, 0.0f, _S600, 0.0f, _S600, _S600, make_float2 (0.0f), 0.0f, 0.0f, _S600, 0.0f, 0.0f, 0.0f, false, 1.0f, 0.0f, _S600);
    BSDFLobes lobe_terms_0 = _S601;
    uint half_of_0 = 4294967295U;
    float3  ggx_n_2 = _S600;
    i_6 = 0U;
    for(;;)
    {
        if(i_6 < _S598)
        {
        }
        else
        {
            break;
        }
        uint _S602;
        if(i_6 == 3U)
        {
            _S602 = 4U;
        }
        else
        {
            if(i_6 == 4U)
            {
                _S602 = 6U;
            }
            else
            {
                _S602 = i_6;
            }
        }
        bool _S603 = _S602 == 0U;
        bool _S604;
        if(_S603)
        {
            _S604 = _S596;
        }
        else
        {
            _S604 = false;
        }
        bool _S605;
        if(_S604)
        {
            _S605 = _S597;
        }
        else
        {
            _S605 = _S602 == 1U;
        }
        bool _S606 = _S605 != refracted_2;
        if(_S606)
        {
            ggx_n_1 = ggx_n_2;
            uint i_8 = i_6 + 1U;
            ggx_n_2 = ggx_n_1;
            i_6 = i_8;
            continue;
        }
        uint _S607;
        if(_S602 == 6U)
        {
            _S607 = 0U;
        }
        else
        {
            if(_S602 == 4U)
            {
                _S607 = 2U;
            }
            else
            {
                _S607 = _S602;
            }
        }
        bool _S608 = _S607 != half_of_0;
        uint half_of_1;
        if(_S608)
        {
            bool _S609 = _S607 == 0U;
            if(_S609)
            {
                float3  _S610 = sampledHalf(in_dir_4, n_7, material_10, random_state_4, _S590);
                ggx_n_1 = _S610;
            }
            else
            {
                bool _S611 = _S607 == 1U;
                if(_S611)
                {
                    float3  _S612 = refractedHalf(in_dir_4, out_dir_2, n_7, eta_i_8, eta_o_8);
                    ggx_n_1 = _S612;
                }
                else
                {
                    float3  _S613 = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_1 = _S613;
                }
            }
            float3  _S614 = negate_0(in_dir_4);
            BSDFLobes _S615 = bsdfLobes(in_dir_4, _S614, _S589, ggx_n_1, material_10, eta_i_8, eta_o_8, _S590, _S594);
            lobe_terms_0 = _S615;
            float _S616 = translucentShare(material_10);
            (&lobe_terms_0)->translucent_share = _S616;
            half_of_1 = _S607;
        }
        else
        {
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S602)
        {
        case 0U:
            {
                float _S617 = diffusePDF(_S591, 0.0f, (F32_abs((_S587))), _S593, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(0)] = _S617;
                float3  _S618 = diffuseBSDF(out_dir_2, _S589, _S593, material_10, lobe_terms_0);
                (*throughputs_0)[int(0)] = _S618;
                break;
            }
        case 1U:
            {
                float _S619 = refractPDF(_S591, dot_0(out_dir_2, ggx_n_1), (F32_abs((_S587))), _S593, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(1)] = _S619;
                float3  _S620 = refractBSDF(out_dir_2, _S589, _S593, material_10, lobe_terms_0);
                (*throughputs_0)[int(1)] = _S620;
                break;
            }
        case 4U:
            {
                float _S621 = sheenVelvetPDF(_S591, 0.0f, (F32_abs((_S587))), _S593, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(3)] = _S621;
                float3  _S622 = sheenVelvetBSDF(out_dir_2, _S589, _S593, material_10, lobe_terms_0);
                (*throughputs_0)[int(3)] = _S622;
                break;
            }
        case 6U:
            {
                float _S623 = toonPDF(_S591, dot_0(out_dir_2, (&lobe_terms_0)->toon_axis), (F32_abs((_S587))), _S593, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(4)] = _S623;
                float3  _S624 = toonBSDF(out_dir_2, _S589, _S593, material_10, lobe_terms_0);
                (*throughputs_0)[int(4)] = _S624;
                break;
            }
        default:
            {
                float _S625 = reflectPDF(_S591, 0.0f, (F32_abs((_S587))), _S593, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(2)] = _S625;
                float3  _S626 = reflectBSDF(out_dir_2, _S589, _S593, material_10, lobe_terms_0);
                (*throughputs_0)[int(2)] = _S626;
                break;
            }
        }
        half_of_0 = half_of_1;
        uint i_8 = i_6 + 1U;
        ggx_n_2 = ggx_n_1;
        i_6 = i_8;
    }
    i_6 = 0U;
    ggx_n_1 = _S600;
    for(;;)
    {
        if(i_6 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S627 = ((*pdfs_0)[i_6]) > 0.0f;
        if(_S627)
        {
            float3  f_2 = ggx_n_1 + (*throughputs_0)[i_6] * make_float3 ((*pdfs_0)[i_6]);
            ggx_n_1 = f_2;
        }
        uint i_9 = i_6 + 1U;
        i_6 = i_9;
    }
    return ggx_n_1;
}

static __device__ __forceinline__ float3  skyLobes_0(float3  in_dir_5, float3  dir_3, FKSurface * surface_1, float2  eta_1, bool is_inside_2, float pdf_0, uint random_state_5, FixedArray<float3 , 5>  * terms_0, FixedArray<float, 5>  * pdfs_1)
{
    bool _S628 = wrongSide_0(is_inside_2, false, dir_3, surface_1->geometry_n);
    float3  _S629 = BSDF(in_dir_5, dir_3, surface_1->smooth_n, surface_1->material, eta_1.x, eta_1.y, _S628, random_state_5, terms_0, pdfs_1);
    float3  _S630 = make_float3 (0.0f);
    uint i_10 = 0U;
    float3  f_3 = _S630;
    for(;;)
    {
        if(i_10 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S631 = ((*pdfs_1)[i_10]) > 0.0f;
        if(_S631)
        {
            float3  _S632 = (*terms_0)[i_10] * make_float3 ((*pdfs_1)[i_10]) / make_float3 ((*pdfs_1)[i_10] + pdf_0);
            (*terms_0)[i_10] = _S632;
            float3  f_4 = f_3 + (*terms_0)[i_10];
            f_3 = f_4;
        }
        uint i_11 = i_10 + 1U;
        i_10 = i_11;
    }
    return f_3;
}

__device__ float3  skyBSDF(float3  in_dir_6, float3  dir_4, FKSurface surface_2, float2  eta_2, bool is_inside_3, float pdf_1, uint random_state_6)
{
    FKSurface _S633 = surface_2;
    FixedArray<float3 , 5>  terms_1;
    FixedArray<float, 5>  pdfs_2;
    float3  _S634 = skyLobes_0(in_dir_6, dir_4, &_S633, eta_2, is_inside_3, pdf_1, random_state_6, &terms_1, &pdfs_2);
    return _S634;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_5, float3  radiance_0, float3  color_0, uint random_state_7)
{
    SkySample _S635;
    (&_S635)->dir = dir_5;
    (&_S635)->radiance = radiance_0;
    (&_S635)->color = color_0;
    (&_S635)->random_state = random_state_7;
    return _S635;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_3, float2  eta_3, bool is_inside_4, uint init_random_state_0, uint lobe_state_0, ShadowContext * context_2)
{
    uint2  _S636 = (fcptEnvironmentCdfSize());
    uint2  _S637 = make_uint2 (1U, 0U);
    uint2  _S638 = _S636 - _S637;
    Random _S639 = pcg(init_random_state_0);
    Random _S640 = pcg(_S639.state);
    Random _S641 = pcg(_S640.state);
    Random _S642 = pcg(_S641.state);
    uint _S643 = _S638.x;
    uint _S644 = searchCDF_0(make_uint2 (_S643, 0U), make_uint2 (0U, 1U), _S638.y, _S639.value);
    uint _S645 = searchCDF_0(make_uint2 (0U, _S644), _S637, _S643, _S640.value);
    float2  _S646 = make_float2 ((float)_S638.x, (float)_S638.y);
    float2  _S647 = (make_float2 (float(_S645), float(_S644)) + make_float2 (_S641.value, _S642.value)) / _S646 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S648 = _S647.y;
    float _S649 = (F32_sin((_S648)));
    float _S650 = _S647.x;
    float3  _S651 = make_float3 (- _S649 * (F32_cos((_S650))), _S649 * (F32_sin((_S650))), (F32_cos((_S648))));
    float _S652 = environmentPdf_0(_S651);
    float3  _S653 = skyBSDF(ray_0->unit_direction, _S651, *surface_3, eta_3, is_inside_4, _S652, lobe_state_0);
    bool _S654 = !(_S652 > 0.0f);
    bool _S655;
    if(_S654)
    {
        _S655 = true;
    }
    else
    {
        _S655 = all_1(_S653 == make_float3 (0.0f));
    }
    if(_S655)
    {
        float3  _S656 = make_float3 (0.0f);
        return SkySample_x24init_0(_S651, _S656, _S656, _S642.state);
    }
    float3  _S657 = skyRadiance_0(ray_0->origin, surface_3, is_inside_4, _S651, context_2, _S642.state);
    return SkySample_x24init_0(_S651, _S657, _S653 * _S657, _S642.state);
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

static __device__ float3  hairLight_0(FKSurface * surface_4, float3  in_dir_7, TreeSample * light_1, bool competing_0)
{
    SampleBSDF _S658 = (fcptConnectHair((surface_4->hair), ((&surface_4->material)->albedo), ((&surface_4->material)->specular_tint), (in_dir_7), (light_1->dir)));
    float3  _S659 = _S658.throughput * make_float3 (_S658.pdf);
    float _S660 = light_1->density;
    float _S661 = 1.0f + _S658.pdf * _S658.pdf / (light_1->density * light_1->density);
    bool _S662;
    if(competing_0)
    {
        _S662 = _S660 > 0.0f;
    }
    else
    {
        _S662 = false;
    }
    float _S663 = _slang_select(_S662, _S661,1.0f);
    return _S659 / make_float3 (_S663) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_6, float3  radiance_1, float density_0, uint random_state_8)
{
    TreeSample _S664;
    (&_S664)->dir = dir_6;
    (&_S664)->radiance = radiance_1;
    (&_S664)->density = density_0;
    (&_S664)->random_state = random_state_8;
    return _S664;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_12, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S665 = importance(first_1, p_12, normal_3);
    float _S666 = importance(second_1, p_12, normal_3);
    float2  _S667 = make_float2 (_S665, _S666);
    bool _S668 = _S665 == 0.0f;
    bool _S669;
    if(_S668)
    {
        _S669 = _S666 == 0.0f;
    }
    else
    {
        _S669 = false;
    }
    if(_S669)
    {
        return 2U;
    }
    float _S670 = _S665 + _S666;
    bool _S671 = _S666 > 0.0f;
    if(_S671)
    {
        _S669 = (*pick_0 * _S670) >= _S665;
    }
    else
    {
        _S669 = false;
    }
    uint _S672 = uint(_S669);
    float _S673 = (F32_min(((*pick_0 * _S670 - float(_S672) * _S665) / _slang_vector_get_element(_S667, _S672)), (0.99999994039535522f)));
    *pick_0 = _S673;
    float _S674 = *probability_3 * (_slang_vector_get_element(_S667, _S672) / _S670);
    *probability_3 = _S674;
    return _S672;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_13, float u1_0, float u2_0)
{
    float3  _S675 = center_1 - p_13;
    float _S676 = radius_1 * radius_1 / dot_0(_S675, _S675);
    float _S677 = u1_0 * _S676 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S676), (0.0f)))))));
    float _S678 = 2.0f * u1_0;
    bool _S679 = _S676 >= 1.0f;
    float _S680 = _slang_select(_S679, _S678,_S677);
    float _S681 = (F32_sqrt(((F32_max((_S680 * (2.0f - _S680)), (0.0f))))));
    float _S682 = 6.28318548202514648f * u2_0;
    float3  _S683 = make_float3 (_S681 * (F32_cos((_S682))), 1.0f - _S680, _S681 * (F32_sin((_S682))));
    float3  _S684 = ((((_S675)) * make_float3(rnorm3df(((_S675)).x, ((_S675)).y, ((_S675)).z))));
    float3  _S685 = tangentToWorld(_S683, _S684);
    return _S685;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S686 = center_2 - ray_1->origin;
    float _S687 = dot_0(_S686, ray_1->unit_direction);
    float _S688 = dot_0(_S686, _S686) - _S687 * _S687;
    float _S689 = radius_3 * radius_3;
    bool _S690 = _S688 > _S689;
    if(_S690)
    {
        return 4.294967296e+09f;
    }
    float _S691 = (F32_sqrt((_S689 - _S688)));
    float _S692 = _S687 - _S691;
    float _S693 = _S687 + _S691;
    bool _S694 = _S692 > 0.0000152587890625f;
    bool _S695;
    if(_S694)
    {
        _S695 = _S692 < max_len_0;
    }
    else
    {
        _S695 = false;
    }
    if(_S695)
    {
        return _S692;
    }
    bool _S696 = _S693 > 0.0000152587890625f;
    if(_S696)
    {
        _S695 = _S693 < max_len_0;
    }
    else
    {
        _S695 = false;
    }
    if(_S695)
    {
        return _S693;
    }
    return 4.294967296e+09f;
}

static __device__ float3  mul_0(float3  left_1, Matrix<float, 3, 3>  right_1)
{
    float3  result_5;
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
        int i_12 = int(0);
        float sum_0 = 0.0f;
        for(;;)
        {
            if(i_12 < int(3))
            {
            }
            else
            {
                break;
            }
            float sum_1 = sum_0 + _slang_vector_get_element(left_1, i_12) * _slang_vector_get_element(right_1.rows[i_12], j_1);
            i_12 = i_12 + int(1);
            sum_0 = sum_1;
        }
        *_slang_vector_get_element_ptr(&result_5, j_1) = sum_0;
        j_1 = j_1 + int(1);
    }
    return result_5;
}

static __device__ __forceinline__ TreeSample sampleLightTree_0(float3  origin_4, float3  smooth_n_2, float3  geometry_n_1, float geometry_offset_1, bool sided_0, uint init_random_state_1, ShadowContext * context_3)
{
    Random _S697 = pcg(init_random_state_1);
    Random _S698 = pcg(_S697.state);
    Random _S699 = pcg(_S698.state);
    float3  _S700 = make_float3 (0.0f);
    TreeSample _S701 = TreeSample_x24init_0(_S700, _S700, 0.0f, _S699.state);
    TreeSample sample_0 = _S701;
    float3  _S702 = _slang_select(sided_0, _S700,smooth_n_2);
    float3  _S703 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S697.value;
    float probability_4 = 1.0f;
    uint n_8 = 0U;
    for(;;)
    {
        uint4  _S704 = (fcptLightNode((n_8)));
        if((_S704.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S705 = (fcptLightSecond((n_8)));
        uint _S706 = n_8 + 1U;
        LightNode _S707 = (fcptLightBounds((_S706)));
        LightNode _S708 = (fcptLightBounds((_S705)));
        uint _S709 = pickChild(_S707, _S708, origin_4, _S702, &pick_1, &probability_4);
        bool _S710 = _S709 > 1U;
        if(_S710)
        {
            return sample_0;
        }
        bool _S711 = _S709 == 1U;
        uint _S712 = _slang_select(_S711, _S705,_S706);
        n_8 = _S712;
    }
    bool _S713 = n_8 == 0U;
    bool _S714;
    if(_S713)
    {
        LightNode _S715 = (fcptLightBounds((0U)));
        float _S716 = importance(_S715, origin_4, _S702);
        _S714 = !(_S716 > 0.0f);
    }
    else
    {
        _S714 = false;
    }
    if(_S714)
    {
        return sample_0;
    }
    uint4  _S717 = (fcptLightNode((n_8)));
    FKHit _S718 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S719 = (_S717.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S719)
    {
        FKLight _S720 = (fcptLight((_S717.y)));
        if(sided_0)
        {
            float _S721 = sign_0(dot_0(geometry_n_1, _S720.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S721);
            float3  _S722 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S722;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S703;
            lift_n_0 = smooth_n_2;
        }
        bool _S723 = (_S720.variance) == 0.0f;
        if(_S723)
        {
            float3  _S724 = _S720.position - emitter_point_0;
            float3  _S725 = ((((_S724)) * make_float3(rnorm3df(((_S724)).x, ((_S724)).y, ((_S724)).z))));
            (&sample_0)->dir = _S725;
            float3  _S726 = _S720.color * make_float3 (_S720.intensity) / make_float3 (dot_0(_S724, _S724) * probability_4);
            (&sample_0)->radiance = _S726;
            shadow_1 = _S724;
        }
        else
        {
            float3  _S727 = sampleSphere(_S720.position, _S720.variance, emitter_point_0, _S698.value, _S699.value);
            (&sample_0)->dir = _S727;
            float _S728 = sphereDensity(_S720.position, _S720.variance, emitter_point_0);
            float _S729 = probability_4 * _S728;
            (&sample_0)->density = _S729;
            float3  _S730 = pointLightRadiance(_S720.color, _S720.intensity, _S720.variance);
            float3  _S731 = _S730 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S731;
            FKRay _S732 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S733 = raySphere_0(_S720.position, _S720.variance, &_S732, 4.294967296e+09f);
            float3  _S734 = (&sample_0)->dir * make_float3 (_S733);
            shadow_1 = _S734;
        }
        emitter_0 = _S718;
        emitter_point_0 = _S700;
    }
    else
    {
        uint _S735 = _S717.y;
        uint _S736 = (fcptTriangleOffset((_S735)));
        uint _S737 = _S736 + _S717.z;
        Matrix<float, 3, 3>  _S738 = (fcptWorldTriangle((_S735), (_S737)));
        float _S739 = (F32_sqrt((_S698.value)));
        float2  _S740 = make_float2 (_S739 * (1.0f - _S699.value), _S739 * _S699.value);
        float3  _S741 = mul_0(make_float3 (1.0f - _S739, _S740.x, _S740.y), _S738);
        if(sided_0)
        {
            float _S742 = sign_0(dot_0(geometry_n_1, _S741 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S742);
            float3  _S743 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S743;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S744 = !((dot_0(smooth_n_2, _S741 - origin_4)) > 0.0f);
            if(_S744)
            {
                return sample_0;
            }
            emitter_point_0 = _S703;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S740, _S735, _S737, 0U, 0.0f);
        float3  _S745 = _S741 - emitter_point_0;
        float3  _S746 = ((((_S745)) * make_float3(rnorm3df(((_S745)).x, ((_S745)).y, ((_S745)).z))));
        (&sample_0)->dir = _S746;
        float _S747 = solidAngle(probability_4, cross_0(_S738.rows[int(1)] - _S738.rows[int(0)], _S738.rows[int(2)] - _S738.rows[int(0)]), _S745);
        (&sample_0)->density = _S747;
        bool _S748 = (fcptShadowFirst());
        bool _S749 = !_S748;
        if(_S749)
        {
            FKSurface _S750 = (fcptLightSurfaceAt((emitter_1), (_S741), (_S699.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S741 - origin_4))));
            (&sample_0)->random_state = _S750.random_state;
            float3  _S751 = _slang_select(_S750.skip, _S700,_S750.material.emissive);
            float3  _S752 = _S751 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S752;
        }
        shadow_1 = _S745;
        emitter_0 = emitter_1;
        emitter_point_0 = _S741;
    }
    FKHit _S753 = emitter_0;
    float3  _S754 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S699.state, &_S753);
    bool _S755 = (fcptShadowFirst());
    if(_S755)
    {
        _S714 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S714 = false;
    }
    if(_S714)
    {
        _S714 = !all_1(_S754 == _S700);
    }
    else
    {
        _S714 = false;
    }
    if(_S714)
    {
        FKSurface _S756 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S699.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S756.random_state;
        float3  _S757 = _slang_select(_S756.skip, _S700,_S756.material.emissive);
        float3  _S758 = _S757 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S758;
    }
    float3  _S759 = (&sample_0)->radiance * _S754;
    bool _S760 = all_1(_S754 == _S700);
    float3  _S761 = _slang_select(_S760, _S700,_S759);
    (&sample_0)->radiance = _S761;
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

__device__ float powerHeuristic(float a_5, float b_1)
{
    float _S762 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    bool _S763 = b_1 > 0.0f;
    float _S764 = _slang_select(_S763, _S762,1.0f);
    return _S764;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S765 = vertex_0->none;
    if(_S765)
    {
        return 1.0f;
    }
    uint _S766 = (fcptLightSlot((*hit_1)));
    float _S767 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S766, light_point_1);
    float _S768 = powerHeuristic(vertex_0->pdf, _S767);
    return _S768;
}

static __device__ float3  environment_0(float3  dir_7, uint depth_0, uint lobe_0)
{
    uint2  _S769 = (fcptEnvironmentMapSize());
    bool _S770 = (_S769.x) > 1U;
    bool _S771;
    if(_S770)
    {
        uint2  _S772 = (fcptEnvironmentMapSize());
        _S771 = (_S772.y) > 1U;
    }
    else
    {
        _S771 = false;
    }
    if(_S771)
    {
        float3  _S773 = (fcptEnvMapSample((dir_7), (depth_0), (lobe_0)));
        return _S773;
    }
    float3  _S774 = (fcptAmbient());
    return _S774;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S775 = (fcptEnvironmentCdfSize());
    bool _S776 = (_S775.x) > 1U;
    bool _S777;
    if(_S776)
    {
        uint2  _S778 = (fcptEnvironmentCdfSize());
        _S777 = (_S778.y) > 1U;
    }
    else
    {
        _S777 = false;
    }
    bool _S779 = !_S777;
    if(_S779)
    {
        return false;
    }
    uint2  _S780 = (fcptEnvironmentMapSize());
    bool _S781 = (_S780.x) > 1U;
    if(_S781)
    {
        uint2  _S782 = (fcptEnvironmentMapSize());
        _S777 = (_S782.y) > 1U;
    }
    else
    {
        _S777 = false;
    }
    return _S777;
}

static __device__ float escapeWeight_0(float pdf_2, float3  dir_8)
{
    bool _S783 = pdf_2 <= 0.0f;
    bool _S784;
    if(_S783)
    {
        _S784 = true;
    }
    else
    {
        bool _S785 = environmentMapped_0();
        _S784 = !_S785;
    }
    if(_S784)
    {
        return 1.0f;
    }
    float _S786 = environmentPdf_0(dir_8);
    return pdf_2 / (pdf_2 + _S786);
}

static __device__ float3  min_1(float3  x_15, float3  y_4)
{
    float3  result_6;
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
        *_slang_vector_get_element_ptr(&result_6, i_13) = (F32_min((_slang_vector_get_element(x_15, i_13)), (_slang_vector_get_element(y_4, i_13))));
        i_13 = i_13 + int(1);
    }
    return result_6;
}

static __device__ void restir_duplicates_0(uint3  global_invocation_id_1, uint3  local_invocation_id_0, uint local_invocation_index_3)
{
    uint2  _S787 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S788 = make_int2 ((int)_S787.x, (int)_S787.y);
    uint _S789 = previousSeed_0(_S788);
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
            uint _S790 = previousSeed_0(_S788 + make_int2 (x_16, y_5));
            bool _S791 = _S790 == _S789;
            uint _S792 = _slang_select(_S791, 1U,0U);
            uint count_3 = count_2 + _S792;
            int x_17 = x_16 + int(1);
            x_16 = x_17;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S793 = float(count_2 - 1U) / 288.0f;
    bool _S794 = _S789 != 0U;
    float _S795 = _slang_select(_S794, _S793,0.0f);
    fcptStoreDuplication((_S788), (make_uint4 ((F32_asuint((_S795))), 0U, 0U, 0U)));
    return;
}

__device__ uint stream(uint seed_3, uint index_0)
{
    uint _S796 = hash(index_0);
    uint _S797 = hash(seed_3 ^ _S796);
    return _S797;
}

static __device__ float4  asfloat_0(uint4  x_18)
{
    float4  result_7;
    int i_14 = int(0);
    for(;;)
    {
        if(i_14 < int(4))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_7, i_14) = (U32_asfloat((_slang_vector_get_element(x_18, i_14))));
        i_14 = i_14 + int(1);
    }
    return result_7;
}

__device__ void offer(Selection * sel_2, Reservoir candidate_0, float3  weight_0)
{
    float _S798 = rgb_to_greyscale(weight_0);
    bool _S799 = _S798 > 0.0f;
    bool _S800;
    if(_S799)
    {
        _S800 = _S798 < 3.00000000549775576e+38f;
    }
    else
    {
        _S800 = false;
    }
    bool _S801 = !_S800;
    if(_S801)
    {
        return;
    }
    bool _S802 = sel_2->sums;
    if(_S802)
    {
        float3  _S803 = sel_2->color + weight_0;
        sel_2->color = _S803;
        return;
    }
    float _S804 = sel_2->w_sum + _S798;
    sel_2->w_sum = _S804;
    float3  _S805 = sel_2->color + weight_0;
    sel_2->color = _S805;
    Random _S806 = pcg(sel_2->random_state);
    sel_2->random_state = _S806.state;
    bool _S807 = (_S806.value * sel_2->w_sum) <= _S798;
    if(_S807)
    {
        sel_2->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_3;
    float3  _S808 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S808;
    float _S809 = r_3.jac * shifted_0.jac;
    (&candidate_1)->jac = _S809;
    offer(sel_3, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S810 = rgb_to_greyscale((&r_4)->f);
    float _S811 = sel_4.w_sum / _S810;
    bool _S812 = _S810 > 0.0f;
    float _S813 = _slang_select(_S812, _S811,0.0f);
    (&r_4)->w = _S813;
    (&r_4)->c = c_1;
    return r_4;
}

static __device__ uint2  asuint_0(float2  x_19)
{
    uint2  result_8;
    int i_15 = int(0);
    for(;;)
    {
        if(i_15 < int(2))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_8, i_15) = (F32_asuint((_slang_vector_get_element(x_19, i_15))));
        i_15 = i_15 + int(1);
    }
    return result_8;
}

static __device__ void restir_spatial_0(uint3  global_invocation_id_2)
{
    uint2  _S814 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S815 = make_int2 ((int)_S814.x, (int)_S814.y);
    float3  _S816 = make_float3 (0.0f);
    FKHit _S817 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S818 = Domain_x24init_0(_S816, _S816, &_S817, 0.0f, 0.0f);
    Domain dom_4 = _S818;
    bool _S819 = (fcptCurrentDomain((_S815), (&dom_4)));
    bool _S820 = !_S819;
    if(_S820)
    {
        Reservoir _S821 = (Reservoir{});
        fcptStoreReservoirPrevious((_S815), (_S821), ((&dom_4)->hit));
        return;
    }
    Reservoir _S822 = (fcptLoadReservoirTemporal((_S815)));
    uint t_13 = 0U;
    float count_4 = 0.0f;
    float c_sum_0 = _S822.c;
    for(;;)
    {
        uint _S823 = (fcptRestirNeighbours());
        if(t_13 < _S823)
        {
        }
        else
        {
            break;
        }
        int2  _S824 = partner_0(_S815, t_13);
        Domain neighbor_0 = _S818;
        bool _S825 = (fcptCurrentDomain((_S824), (&neighbor_0)));
        if(_S825)
        {
            float count_5 = count_4 + 1.0f;
            uint4  _S826 = (fcptReservoirTemporal((_S824), (0U)));
            float c_sum_1 = c_sum_0 + (U32_asfloat((_S826.w)));
            count_4 = count_5;
            c_sum_0 = c_sum_1;
        }
        uint t_14 = t_13 + 1U;
        t_13 = t_14;
    }
    float _S827 = _S822.c / (F32_max((count_4), (1.0f)));
    float _S828 = rgb_to_greyscale(_S822.f);
    bool _S829 = count_4 == 0.0f;
    float _S830 = _slang_select(_S829, 1.0f,0.0f);
    Selection _S831 = (Selection{});
    Selection sel_5 = _S831;
    uint _S832 = (fcptFrame());
    uint _S833 = hash(_S832);
    uint _S834 = global_invocation_id_2.x;
    uint2  _S835 = (fcptRenderSize());
    uint _S836 = stream(_S833, _S834 + _S835.x * global_invocation_id_2.y);
    uint _S837 = stream(_S836, 195U);
    (&sel_5)->random_state = _S837;
    t_13 = 0U;
    float canonical_mis_0 = _S830;
    for(;;)
    {
        uint _S838 = (fcptRestirNeighbours());
        if(t_13 < _S838)
        {
        }
        else
        {
            break;
        }
        int2  _S839 = partner_0(_S815, t_13);
        Domain neighbor_dom_0 = _S818;
        bool _S840 = (fcptCurrentDomain((_S839), (&neighbor_dom_0)));
        if(_S840)
        {
            Reservoir _S841 = (fcptLoadReservoirTemporal((_S839)));
            uint4  _S842 = (fcptShiftData((_S839), (t_13)));
            float4  _S843 = asfloat_0(_S842);
            uint4  _S844 = (fcptShiftData((_S815), (t_13)));
            float4  _S845 = asfloat_0(_S844);
            float _S846 = (_S841.c + _S827) / c_sum_0;
            bool _S847 = _S828 > 0.0f;
            float canonical_mis_1;
            if(_S847)
            {
                float _S848 = _S846 * _S827 * _S828;
                float _S849 = _S827 * _S828;
                float _S850 = rgb_to_greyscale(float3 {_S845.x, _S845.y, _S845.z});
                float canonical_mis_2 = canonical_mis_0 + _S848 / (_S849 + _S841.c * _S850);
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float _S851 = rgb_to_greyscale(_S841.f);
            float3  _S852 = float3 {_S843.x, _S843.y, _S843.z};
            Shift _S853 = Shift_x24init_0(_S852, _S843.w);
            float _S854 = _S846 * _S841.c * _S851;
            float _S855 = _S841.c * _S851;
            float _S856 = rgb_to_greyscale(_S852);
            offerShifted(&sel_5, _S841, _S853, _S854 / (_S855 + _S827 * _S856));
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_15 = t_13 + 1U;
        t_13 = t_15;
    }
    offerShifted(&sel_5, _S822, Shift_x24init_0(_S822.f, 1.0f), canonical_mis_0);
    Reservoir _S857 = finalize(sel_5, c_sum_0);
    fcptStoreReservoirPrevious((_S815), (_S857), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S815), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S815), (make_float4 ((&sel_5)->color.x, (&sel_5)->color.y, (&sel_5)->color.z, 0.0f)));
    return;
}

static __device__ uint3  asuint_1(float3  x_20)
{
    uint3  result_9;
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
        *_slang_vector_get_element_ptr(&result_9, i_16) = (F32_asuint((_slang_vector_get_element(x_20, i_16))));
        i_16 = i_16 + int(1);
    }
    return result_9;
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

static __device__ float interpolate_0(float a_6, float b_2, float t_20)
{
    return a_6 + (b_2 - a_6) * t_20;
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S903 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S904 = make_int2 ((int)_S903.x, (int)_S903.y);
    float3  _S905 = make_float3 (0.0f);
    FKHit _S906 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S907 = Domain_x24init_0(_S905, _S905, &_S906, 0.0f, 0.0f);
    Domain dom_5 = _S907;
    bool _S908 = (fcptCurrentDomain((_S904), (&dom_5)));
    bool _S909 = !_S908;
    if(_S909)
    {
        Reservoir _S910 = (Reservoir{});
        fcptStoreReservoirTemporal((_S904), (_S910), ((&dom_5)->hit));
        return;
    }
    Reservoir _S911 = (fcptLoadReservoirInitial((_S904)));
    bool _S912 = (fcptTemporalQueued());
    bool _S913 = (fcptSceneUnchanged());
    bool _S914;
    if(_S913)
    {
        _S914 = true;
    }
    else
    {
        _S914 = !_S912;
    }
    int2  _S915;
    if(_S914)
    {
        int2  _S916 = sampleNeighbor_0(_S904, _S911.seed);
        _S915 = _S916;
    }
    else
    {
        int2  _S917 = (fcptLoadTemporalNeighbor((_S904)));
        _S915 = _S917;
    }
    bool _S918 = (_S915.x) >= int(0);
    Reservoir r_5;
    if(_S918)
    {
        Reservoir _S919 = (fcptLoadReservoirPrevious((_S915)));
        uint4  _S920 = (fcptDuplication((_S915)));
        float _S921 = (U32_asfloat((_S920.x)));
        uint _S922 = (fcptRestirDecorrelation());
        bool _S923 = _S922 == 1U;
        float _S924 = _slang_select(_S923, _S921,0.0f);
        float _S925 = interpolate_0(20.0f, 1.0f, (F32_pow((_S924), (0.10000000149011612f))));
        float _S926 = (F32_min((_S919.c), (_S925)));
        bool _S927 = (fcptSceneUnchanged());
        float4  _S928 = make_float4 (_S919.f.x, _S919.f.y, _S919.f.z, 1.0f);
        bool _S929 = !_S927;
        if(_S929)
        {
            _S914 = _S912;
        }
        else
        {
            _S914 = false;
        }
        float4  to_current_0;
        if(_S914)
        {
            uint4  _S930 = (fcptTemporalShift((_S904), (0U)));
            float4  _S931 = asfloat_0(_S930);
            to_current_0 = _S931;
        }
        else
        {
            if(_S929)
            {
                Shift _S932 = temporalShiftAt_0(_S904, _S915, 0U);
                float4  _S933 = make_float4 (_S932.f.x, _S932.f.y, _S932.f.z, _S932.jac);
                to_current_0 = _S933;
            }
            else
            {
                to_current_0 = _S928;
            }
        }
        Domain own_1 = _S907;
        if(_S927)
        {
            _S914 = true;
        }
        else
        {
            bool _S934 = (fcptPreviousScenes());
            bool _S935 = !_S934;
            if(_S935)
            {
                _S914 = (_S911.w) > 0.0f;
            }
            else
            {
                _S914 = false;
            }
            if(_S914)
            {
                bool _S936 = (fcptStoredDomainInitial((_S904), (_S911.seed), (&own_1)));
                _S914 = _S936;
            }
            else
            {
                _S914 = false;
            }
            if(_S914)
            {
                Domain _S937 = (fcptPreviousDomain((_S915), (_S911.seed)));
                Domain _S938 = _S937;
                Domain _S939 = own_1;
                bool _S940 = sameDomain_0(&_S938, &_S939);
                _S914 = _S940;
            }
            else
            {
                _S914 = false;
            }
        }
        float4  _S941 = make_float4 (_S911.f.x, _S911.f.y, _S911.f.z, 1.0f);
        bool _S942 = !_S914;
        if(_S942)
        {
            _S914 = _S912;
        }
        else
        {
            _S914 = false;
        }
        float4  to_previous_0;
        if(_S914)
        {
            uint4  _S943 = (fcptTemporalShift((_S904), (1U)));
            float4  _S944 = asfloat_0(_S943);
            to_previous_0 = _S944;
        }
        else
        {
            if(_S942)
            {
                Shift _S945 = temporalShiftAt_0(_S904, _S915, 1U);
                float4  _S946 = make_float4 (_S945.f.x, _S945.f.y, _S945.f.z, _S945.jac);
                to_previous_0 = _S946;
            }
            else
            {
                to_previous_0 = _S941;
            }
        }
        float _S947 = rgb_to_greyscale(_S911.f);
        float _S948 = rgb_to_greyscale(_S919.f);
        Selection _S949 = (Selection{});
        Selection sel_6 = _S949;
        uint _S950 = (fcptFrame());
        uint _S951 = hash(_S950);
        uint _S952 = global_invocation_id_7.x;
        uint2  _S953 = (fcptRenderSize());
        uint _S954 = stream(_S951, _S952 + _S953.x * global_invocation_id_7.y);
        uint _S955 = stream(_S954, 194U);
        (&sel_6)->random_state = _S955;
        float _S956 = _S911.c * _S947;
        float4  _S957 = to_previous_0;
        float _S958 = rgb_to_greyscale(float3 {_S957.x, _S957.y, _S957.z});
        float _S959 = _S956 / (_S956 + _S926 * _S958);
        float _S960 = _S926 * _S948;
        float4  _S961 = to_current_0;
        float3  _S962 = float3 {_S961.x, _S961.y, _S961.z};
        float _S963 = rgb_to_greyscale(_S962);
        float _S964 = _S960 / (_S960 + _S911.c * _S963);
        float2  _S965 = make_float2 (_S959, _S964);
        offerShifted(&sel_6, _S911, Shift_x24init_0(_S911.f, 1.0f), _S959);
        offerShifted(&sel_6, _S919, Shift_x24init_0(_S962, to_current_0.w), _S964);
        Reservoir _S966 = finalize(sel_6, _S911.c + _S926);
        r_5 = _S966;
    }
    else
    {
        r_5 = _S911;
    }
    fcptStoreReservoirTemporal((_S904), (r_5), ((&dom_5)->hit));
    return;
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S967 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S968 = make_int2 ((int)_S967.x, (int)_S967.y);
    float3  _S969 = make_float3 (0.0f);
    float2  _S970 = make_float2 (0.0f);
    FKHit _S971 = Hit_x24init_0(_S970, 0U, 0U, 0U, 0.0f);
    Domain _S972 = Domain_x24init_0(_S969, _S969, &_S971, 0.0f, 0.0f);
    Domain dom_6 = _S972;
    bool _S973 = (fcptCurrentDomain((_S968), (&dom_6)));
    bool _S974 = !_S973;
    if(_S974)
    {
        Reservoir _S975 = (Reservoir{});
        fcptStoreReservoirInitial((_S968), (_S975), ((&dom_6)->hit));
        return;
    }
    uint _S976 = (fcptFrame());
    uint _S977 = hash(_S976);
    uint _S978 = global_invocation_id_8.x;
    uint2  _S979 = (fcptRenderSize());
    uint _S980 = stream(_S977, _S978 + _S979.x * global_invocation_id_8.y);
    Selection _S981 = (Selection{});
    Selection initial_0 = _S981;
    uint _S982 = stream(_S980, 193U);
    (&initial_0)->random_state = _S982;
    bool _S983 = (fcptRestirUsed());
    bool _S984 = !_S983;
    (&initial_0)->sums = _S984;
    uint _S985 = stream(_S980, 0U);
    (&(&initial_0)->r)->seed = _S985;
    FKHit _S986 = Hit_x24init_0(_S970, 4294967295U, 0U, 0U, 0.0f);
    uint _S987 = (fcptSamples());
    float _S988 = 1.0f / float(_S987);
    FKHit hit_2 = _S986;
    uint i_17 = 0U;
    for(;;)
    {
        uint _S989 = (fcptSamples());
        if(i_17 < _S989)
        {
        }
        else
        {
            break;
        }
        Reservoir _S990 = (Reservoir{});
        Reservoir r_6 = _S990;
        uint _S991 = stream(_S980, i_17);
        (&r_6)->seed = _S991;
        Domain path_0 = _S972;
        bool _S992 = (fcptStoredDomainInitial((_S968), ((&r_6)->seed), (&path_0)));
        bool _S993 = !_S992;
        if(_S993)
        {
            fcptMissed((_S968), (path_0), (_S988));
            uint i_18 = i_17 + 1U;
            i_17 = i_18;
            continue;
        }
        Domain _S994 = path_0;
        Reservoir _S995 = r_6;
        Shift _S996 = passWalk_0(&_S994, &_S995, false, _S988, &initial_0);
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
        uint i_18 = i_17 + 1U;
        i_17 = i_18;
    }
    float3  _S999 = (&initial_0)->glow;
    float3  _S1000 = (&initial_0)->color;
    bool _S1001 = (&initial_0)->sums;
    float3  _S1002 = _slang_select(_S1001, _S1000,_S969);
    fcptAddColor((_S968), (make_float4 ((_S999 + _S1002).x, (_S999 + _S1002).y, (_S999 + _S1002).z, 1.0f)));
    Reservoir _S1003 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S968), (_S1003), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_3, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S1004;
    (&_S1004)->none = none_0;
    (&_S1004)->pdf = pdf_3;
    (&_S1004)->origin = origin_5;
    (&_S1004)->smooth_n = smooth_n_3;
    (&_S1004)->start = start_6;
    return _S1004;
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
    Vertex _S1005;
    (&_S1005)->rough = rough_0;
    (&_S1005)->lobe = lobe_1;
    (&_S1005)->pdf = pdf_4;
    (&_S1005)->cos = cos_0;
    (&_S1005)->inside = inside_0;
    return _S1005;
}

static __device__ float3  exp_0(float3  x_21)
{
    float3  result_10;
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
        *_slang_vector_get_element_ptr(&result_10, i_19) = (F32_exp((_slang_vector_get_element(x_21, i_19))));
        i_19 = i_19 + int(1);
    }
    return result_10;
}

static __device__ float3  flightWeight_0(float3  scatter_0, float3  extinction_0, float sigma_0, float distance_2, bool scatters_0)
{
    float3  _S1006 = exp_0((make_float3 (sigma_0) - extinction_0) * make_float3 (distance_2));
    float3  _S1007 = scatter_0 * _S1006 / make_float3 (sigma_0);
    float3  _S1008 = _slang_select(scatters_0, _S1007,_S1006);
    return _S1008;
}

static __device__ uint arrivalLobe_0(uint b_3, uint prev_lobe_0)
{
    bool _S1009 = b_3 > 0U;
    uint _S1010 = _slang_select(_S1009, prev_lobe_0,3U);
    return _S1010;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_2, bool surface_5, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S1011;
    (&_S1011)->extinction_behind = extinction_behind_0;
    (&_S1011)->extinction_front = extinction_front_0;
    (&_S1011)->fillings = fillings_0;
    (&_S1011)->side = side_0;
    (&_S1011)->depth = depth_1;
    (&_S1011)->lobe = lobe_2;
    (&_S1011)->surface = surface_5;
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

__device__ float3  safeDivide(float3  a_7, float3  b_4)
{
    float3  _S1014 = a_7 / b_4;
    float3  _S1015 = make_float3 (0.0f);
    bool3  _S1016 = b_4 == _S1015;
    float3  _S1017 = _slang_select(_S1016, _S1015,_S1014);
    return _S1017;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_6)
{
    uint _S1018 = (1U << count_6) - 1U;
    return (e_2 & (~(_S1018 << offset_1))) | ((newbits_0 & _S1018) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_7, uint end_type_0, uint end_0, float3  f_5)
{
    Reservoir candidate_2 = r_7;
    uint _S1019 = insertBits_0(r_7.path, end_0, 0U, 5U);
    uint _S1020 = insertBits_0(_S1019, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S1020;
    (&candidate_2)->f = f_5;
    return candidate_2;
}

__device__ float survivalProbability(float3  throughput_0, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_0.x), ((F32_max((throughput_0.y), (throughput_0.z)))))) / density_1), (0.0f)))), (1.0f)));
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

static __device__ float3  samplePhase_0(float g_1, float3  dir_9, uint random_state_10, float * pdf_5)
{
    bool _S1026 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1026)
    {
        *pdf_5 = 0.07957746833562851f;
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
    *pdf_5 = _S1036;
    float3  _S1037 = tangentToWorld(make_float3 (_S1034 * (F32_cos((_S1035))), _S1033, _S1034 * (F32_sin((_S1035)))), dir_9);
    float3  _S1038 = ((((_S1037)) * make_float3(rnorm3df(((_S1037)).x, ((_S1037)).y, ((_S1037)).z))));
    return _S1038;
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_1, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2, float velvet_0, float3  toon_2)
{
    BSDFMaterial _S1039;
    (&_S1039)->albedo = albedo_1;
    (&_S1039)->emissive = emissive_0;
    (&_S1039)->roughness = roughness_0;
    (&_S1039)->metallic = metallic_0;
    (&_S1039)->transmission = transmission_0;
    (&_S1039)->ior = ior_0;
    (&_S1039)->absorption = absorption_0;
    (&_S1039)->specular_tint = specular_tint_0;
    (&_S1039)->specular_level = specular_level_0;
    (&_S1039)->translucent = translucent_0;
    (&_S1039)->sheen = sheen_2;
    (&_S1039)->sheen_roughness = sheen_roughness_0;
    (&_S1039)->anisotropy = anisotropy_0;
    (&_S1039)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1039)->tangent = tangent_2;
    (&_S1039)->velvet = velvet_0;
    (&_S1039)->toon = toon_2;
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

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_11, bool skip_0, uint random_state_11, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1041;
    (&_S1041)->smooth_n = smooth_n_4;
    (&_S1041)->geometry_n = geometry_n_2;
    (&_S1041)->geometry_offset = geometry_offset_2;
    (&_S1041)->material = *material_11;
    (&_S1041)->skip = skip_0;
    (&_S1041)->random_state = random_state_11;
    (&_S1041)->coverage = coverage_0;
    (&_S1041)->encloses = encloses_0;
    (&_S1041)->volume = *volume_0;
    (&_S1041)->fills = fills_0;
    (&_S1041)->hair = hair_0;
    return _S1041;
}

static __device__ FKSurface emitting_0(FKSurface * surface_6, bool top_0)
{
    FKSurface lower_0 = *surface_6;
    float3  _S1042 = (&surface_6->material)->emissive;
    float3  _S1043 = make_float3 (0.0f);
    bool _S1044 = !top_0;
    float3  _S1045 = _slang_select(_S1044, _S1043,_S1042);
    (&(&lower_0)->material)->emissive = _S1045;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_7, float u_1)
{
    float _S1046 = surface_7->coverage;
    bool _S1047 = u_1 < _S1046;
    if(_S1047)
    {
        return *surface_7;
    }
    float3  _S1048 = make_float3 (0.0f);
    float3  _S1049 = make_float3 (1.0f);
    BSDFMaterial _S1050 = Material_x24init_0(_S1048, _S1048, 0.0f, 0.0f, 0.0f, 0.0f, _S1048, _S1049, 1.0f, _S1048, _S1048, 0.5f, 0.0f, 0.0f, _S1048, 0.0f, _S1048);
    BSDFMaterial material_12 = _S1050;
    (&material_12)->albedo = _S1049;
    (&material_12)->emissive = (&surface_7->material)->emissive;
    (&material_12)->transmission = 1.0f;
    (&material_12)->ior = 1.0f;
    (&material_12)->absorption = (&surface_7->material)->absorption;
    FKSurface through_0 = *surface_7;
    (&through_0)->material = material_12;
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

static __device__ bool arrivesBehind_0(float3  dir_10, float3  n_9)
{
    return (dot_0(dir_10, n_9)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_8, float3  dir_11)
{
    float3  _S1054 = surface_8->geometry_n;
    float _S1055 = facingSign((&surface_8->material)->transmission, surface_8->geometry_n, dir_11);
    FKSurface faced_0 = *surface_8;
    float3  _S1056 = surface_8->smooth_n * make_float3 (_S1055);
    (&faced_0)->smooth_n = _S1056;
    float3  _S1057 = _S1054 * make_float3 (_S1055);
    (&faced_0)->geometry_n = _S1057;
    return faced_0;
}

static __device__ float3  max_0(float3  x_22, float3  y_7)
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
        *_slang_vector_get_element_ptr(&result_11, i_20) = (F32_max((_slang_vector_get_element(x_22, i_20)), (_slang_vector_get_element(y_7, i_20))));
        i_20 = i_20 + int(1);
    }
    return result_11;
}

static __device__ float3  log_0(float3  x_23)
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
        *_slang_vector_get_element_ptr(&result_12, i_21) = (F32_log((_slang_vector_get_element(x_23, i_21))));
        i_21 = i_21 + int(1);
    }
    return result_12;
}

__device__ float3  beerLambert(float distance_3, float3  absorption_1)
{
    float3  _S1058 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1058));
}

__device__ float2  vertexEta(BSDFMaterial material_13, float n_dot_v_0)
{
    bool _S1059 = n_dot_v_0 < 0.0f;
    float _S1060 = _slang_select(_S1059, material_13.ior,1.0f);
    float _S1061 = _slang_select(_S1059, 1.0f,material_13.ior);
    return make_float2 (_S1060, _S1061);
}

__device__ bool neeDecision(BSDFMaterial material_14, float n_dot_v_1, float eta_i_9, float eta_o_9)
{
    float _S1062 = fresnel((F32_abs((n_dot_v_1))), eta_i_9, eta_o_9);
    float3  _S1063 = mix_0(make_float3 (_S1062), material_14.albedo, material_14.metallic);
    float _S1064 = rgb_to_greyscale(_S1063);
    float _S1065 = (F32_max(((1.0f - _S1064) * (1.0f - material_14.metallic) * (1.0f - material_14.transmission)), (0.0f)));
    bool _S1066 = _S1065 > 0.03999999910593033f;
    bool _S1067;
    if(_S1066)
    {
        _S1067 = true;
    }
    else
    {
        _S1067 = (material_14.roughness) > 0.20000000298023224f;
    }
    return _S1067;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_15)
{
    float _S1068 = rgb_to_greyscale(material_15->translucent);
    return _S1068 > 0.0f;
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
    MediumSides _S1069;
    (&_S1069)->behind = *behind_0;
    (&_S1069)->front = *front_0;
    (&_S1069)->fillings = fillings_1;
    (&_S1069)->face = face_1;
    return _S1069;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_9, FKMedium * medium_0, uint filling_0, float3  dir_12, FKMedium * outside_0)
{
    float3  _S1070 = surface_9->geometry_n;
    MediumSides _S1071 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_9->geometry_n);
    MediumSides sides_0 = _S1071;
    bool _S1072 = surface_9->encloses;
    if(_S1072)
    {
        (&sides_0)->behind = surface_9->volume;
        *&((&(&sides_0)->fillings)->x) = surface_9->fills;
        bool _S1073 = (dot_0(dir_12, _S1070)) > 0.0f;
        if(_S1073)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_10, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_13, uint depth_2, uint lobe_3, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1074 = surface_10->geometry_n;
    ShadowContext _S1075 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_10->geometry_n, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
    bool _S1076 = surface_10->encloses;
    ShadowContext context_4;
    if(_S1076)
    {
        FKSurface faced_1 = *surface_10;
        float3  _S1077 = - _S1074;
        float3  _S1078 = _slang_select(turned_0, _S1077,_S1074);
        (&faced_1)->geometry_n = _S1078;
        FKMedium _S1079 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1080 = faced_1;
        FKMedium _S1081 = _S1079;
        MediumSides _S1082 = mediumSides_0(&_S1080, &_S1081, filling_1, dir_13, outside_1);
        ShadowContext _S1083 = ShadowContext_x24init_0(_S1082.behind.extinction, _S1082.front.extinction, _S1082.fillings, _S1074, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
        if(turned_0)
        {
            uint2  _S1084 = _S1082.fillings;
            ShadowContext _S1085 = ShadowContext_x24init_0(_S1082.front.extinction, _S1082.behind.extinction, uint2 {_S1084.y, _S1084.x}, _S1074, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
            context_4 = _S1085;
        }
        else
        {
            context_4 = _S1083;
        }
    }
    else
    {
        context_4 = _S1075;
    }
    return context_4;
}

static __device__ bool any_1(bool3  x_24)
{
    bool result_13 = false;
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
        if(result_13)
        {
            result_13 = true;
        }
        else
        {
            result_13 = (bool((_slang_vector_get_element(x_24, i_22))));
        }
        i_22 = i_22 + int(1);
    }
    return result_13;
}

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_8, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_3, BSDFMaterial * material_16, float eta_i_10, float eta_o_10, bool competing_1, uint random_state_12)
{
    float3  _S1086 = light_2->dir;
    bool _S1087 = (dot_0(geometry_n_3, - in_dir_8) * dot_0(geometry_n_3, light_2->dir)) <= 0.0f;
    FixedArray<float3 , 5>  throughputs_1;
    FixedArray<float, 5>  pdfs_3;
    float3  _S1088 = BSDF(in_dir_8, _S1086, smooth_n_5, *material_16, eta_i_10, eta_o_10, _S1087, random_state_12, &throughputs_1, &pdfs_3);
    bool _S1089 = !competing_1;
    bool _S1090;
    if(_S1089)
    {
        _S1090 = true;
    }
    else
    {
        _S1090 = (light_2->density) == 0.0f;
    }
    if(_S1090)
    {
        return _S1088 * light_2->radiance;
    }
    float3  _S1091 = make_float3 (0.0f);
    uint i_23 = 0U;
    float3  weighted_0 = _S1091;
    for(;;)
    {
        if(i_23 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S1092 = (pdfs_3[i_23]) > 0.0f;
        if(_S1092)
        {
            float _S1093 = light_2->density;
            float _S1094 = pdfs_3[i_23] / light_2->density;
            float3  weighted_1 = weighted_0 + throughputs_1[i_23] * make_float3 (pdfs_3[i_23]) / make_float3 (_S1093 * (1.0f + _S1094 * _S1094));
            weighted_0 = weighted_1;
        }
        uint i_24 = i_23 + 1U;
        i_23 = i_24;
    }
    return weighted_0 * light_2->radiance * make_float3 (light_2->density);
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_1, uint random_state_13, bool refracted_3, uint lobe_4, float pdf_6)
{
    SampleBSDF _S1095;
    (&_S1095)->unit_direction = unit_direction_1;
    (&_S1095)->throughput = throughput_1;
    (&_S1095)->random_state = random_state_13;
    (&_S1095)->refracted = refracted_3;
    (&_S1095)->lobe = lobe_4;
    (&_S1095)->pdf = pdf_6;
    return _S1095;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  n_i_9, float n_i_dot_v_6, float alpha_15, BSDFMaterial material_17, BSDFLobes lobes_11, float eta_i_11, float eta_o_11, uint random_state_14)
{
    float3  _S1096 = make_float3 (1.0f);
    SampleBSDF _S1097 = SampleBSDF_x24init_0(_S1096, _S1096, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S1097;
    Random _S1098 = pcg(random_state_14);
    Random _S1099 = pcg(_S1098.state);
    (&sample_1)->random_state = _S1099.state;
    float _S1100 = _S1098.value;
    float _S1101 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1100 * _S1100))))));
    float _S1102 = 6.28318548202514648f * _S1099.value;
    float3  _S1103 = tangentToWorld(make_float3 (_S1101 * (F32_cos((_S1102))), _S1098.value, _S1101 * (F32_sin((_S1102)))), n_i_9);
    (&sample_1)->unit_direction = _S1103;
    (&sample_1)->lobe = 4U;
    float3  _S1104 = sheenVelvetBSDF((&sample_1)->unit_direction, n_i_9, alpha_15, material_17, lobes_11);
    (&sample_1)->throughput = _S1104;
    float _S1105 = sheenVelvetPDF(_S1098.value, 0.0f, n_i_dot_v_6, alpha_15, lobes_11, eta_i_11, eta_o_11);
    (&sample_1)->pdf = _S1105;
    return sample_1;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1106 = (F32_sqrt((random_1_0)));
    float _S1107 = 6.28318548202514648f * random_2_0;
    float _S1108 = _S1106 * (F32_cos((_S1107)));
    float _S1109 = _S1106 * (F32_sin((_S1107)));
    float _S1110 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1108 * _S1108 - _S1109 * _S1109))))));
    return make_float3 (_S1108, _S1110, _S1109);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_2, float3  n_i_10, float n_i_dot_v_7, float alpha_16, BSDFMaterial material_18, BSDFLobes lobes_12, float eta_i_12, float eta_o_12, uint random_state_15)
{
    float3  _S1111 = make_float3 (1.0f);
    SampleBSDF _S1112 = SampleBSDF_x24init_0(_S1111, _S1111, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S1112;
    Random _S1113 = pcg(random_state_15);
    Random _S1114 = pcg(_S1113.state);
    (&sample_2)->random_state = _S1114.state;
    float3  _S1115 = sampleCosWeightedHemisphere(_S1113.value, _S1114.value);
    bool _S1116 = u_2 < (lobes_12.p_diffuse * lobes_12.translucent_share);
    float _S1117 = _S1115.y;
    float _S1118 = - _S1117;
    float _S1119 = _slang_select(_S1116, _S1118,_S1117);
    float3  _S1120 = tangentToWorld(make_float3 (_S1115.x, _S1119, _S1115.z), n_i_10);
    (&sample_2)->unit_direction = _S1120;
    (&sample_2)->refracted = _S1116;
    (&sample_2)->lobe = 0U;
    float3  _S1121 = diffuseBSDF((&sample_2)->unit_direction, n_i_10, alpha_16, material_18, lobes_12);
    (&sample_2)->throughput = _S1121;
    float _S1122 = diffusePDF(_S1119, 0.0f, n_i_dot_v_7, alpha_16, lobes_12, eta_i_12, eta_o_12);
    (&sample_2)->pdf = _S1122;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF toonSample(float3  n_i_11, float n_i_dot_v_8, float alpha_17, BSDFMaterial material_19, BSDFLobes lobes_13, float eta_i_13, float eta_o_13, uint random_state_16)
{
    float3  _S1123 = make_float3 (1.0f);
    SampleBSDF _S1124 = SampleBSDF_x24init_0(_S1123, _S1123, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S1124;
    Random _S1125 = pcg(random_state_16);
    Random _S1126 = pcg(_S1125.state);
    (&sample_3)->random_state = _S1126.state;
    float _S1127 = _S1125.value * lobes_13.toon_norm / 6.28318548202514648f;
    float t_21;
    if(lobes_13.toon_glossy)
    {
        t_21 = (F32_acos((clamp_1(1.0f - _S1127, -1.0f, 1.0f))));
    }
    else
    {
        t_21 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1127)))), (1.0f))))));
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
        float _S1128;
        if(t_21 < (lobes_13.toon_a))
        {
            _S1128 = 1.0f;
        }
        else
        {
            _S1128 = (F32_max((1.0f - (t_21 - lobes_13.toon_a) / (F32_max((lobes_13.toon_s), (0.0000152587890625f)))), (0.0f)));
        }
        float integral_1;
        if(lobes_13.toon_glossy)
        {
            integral_1 = 1.0f - (F32_cos(((F32_min((t_21), (lobes_13.toon_a))))));
        }
        else
        {
            float _S1129 = (F32_sin(((F32_min((t_21), (lobes_13.toon_a))))));
            integral_1 = _S1129 * _S1129 / 2.0f;
        }
        bool _S1130 = t_21 > (lobes_13.toon_a);
        bool _S1131;
        if(_S1130)
        {
            _S1131 = (lobes_13.toon_s) > 0.0f;
        }
        else
        {
            _S1131 = false;
        }
        float integral_2;
        if(_S1131)
        {
            if(lobes_13.toon_glossy)
            {
                float _S1132 = (F32_cos((lobes_13.toon_a)));
                float _S1133 = (F32_cos((t_21)));
                integral_2 = (1.0f + lobes_13.toon_a / lobes_13.toon_s) * (_S1132 - _S1133) - ((F32_sin((t_21))) - t_21 * _S1133 - ((F32_sin((lobes_13.toon_a))) - lobes_13.toon_a * _S1132)) / lobes_13.toon_s;
            }
            else
            {
                float _S1134 = 2.0f * lobes_13.toon_a;
                float _S1135 = (F32_cos((_S1134)));
                float _S1136 = 2.0f * t_21;
                float _S1137 = (F32_cos((_S1136)));
                integral_2 = (1.0f + lobes_13.toon_a / lobes_13.toon_s) * (_S1135 - _S1137) / 4.0f - ((F32_sin((_S1136))) / 8.0f - t_21 * _S1137 / 4.0f - ((F32_sin((_S1134))) / 8.0f - lobes_13.toon_a * _S1135 / 4.0f)) / lobes_13.toon_s;
            }
            float integral_3 = integral_1 + integral_2;
            integral_2 = integral_3;
        }
        else
        {
            integral_2 = integral_1;
        }
        float _S1138 = _S1128 * (F32_sin((t_21)));
        float _S1139;
        if(lobes_13.toon_glossy)
        {
            _S1139 = 1.0f;
        }
        else
        {
            _S1139 = (F32_cos((t_21)));
        }
        float _S1140 = _S1138 * _S1139;
        float _S1141 = (integral_2 - _S1127) / _S1140;
        bool _S1142 = _S1140 > 0.0f;
        float _S1143 = _slang_select(_S1142, _S1141,0.0f);
        float _S1144 = clamp_1(t_21 - _S1143, 0.0f, lobes_13.toon_b);
        int k_1 = k_0 + int(1);
        t_21 = _S1144;
        k_0 = k_1;
    }
    float _S1145 = 6.28318548202514648f * _S1126.value;
    float _S1146 = (F32_sin((t_21)));
    float3  _S1147 = tangentToWorld(make_float3 (_S1146 * (F32_cos((_S1145))), (F32_cos((t_21))), _S1146 * (F32_sin((_S1145)))), lobes_13.toon_axis);
    (&sample_3)->unit_direction = _S1147;
    bool _S1148 = (dot_0(n_i_11, (&sample_3)->unit_direction)) < 0.0f;
    (&sample_3)->refracted = _S1148;
    (&sample_3)->lobe = 6U;
    float3  _S1149 = toonBSDF((&sample_3)->unit_direction, n_i_11, alpha_17, material_19, lobes_13);
    (&sample_3)->throughput = _S1149;
    float _S1150 = toonPDF(dot_0(n_i_11, (&sample_3)->unit_direction), dot_0((&sample_3)->unit_direction, lobes_13.toon_axis), n_i_dot_v_8, alpha_17, lobes_13, eta_i_13, eta_o_13);
    (&sample_3)->pdf = _S1150;
    return sample_3;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_12, float n_i_dot_v_9, float alpha_18, BSDFMaterial material_20, BSDFLobes lobes_14, float eta_i_14, float eta_o_14, uint random_state_17)
{
    float3  _S1151 = make_float3 (1.0f);
    SampleBSDF _S1152 = SampleBSDF_x24init_0(_S1151, _S1151, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S1152;
    (&sample_4)->unit_direction = lobes_14.refracted;
    (&sample_4)->random_state = random_state_17;
    (&sample_4)->refracted = true;
    (&sample_4)->lobe = 1U;
    float3  _S1153 = refractBSDF((&sample_4)->unit_direction, n_i_12, alpha_18, material_20, lobes_14);
    (&sample_4)->throughput = _S1153;
    float _S1154 = refractPDF(0.0f, dot_0((&sample_4)->unit_direction, ggx_n_3), n_i_dot_v_9, alpha_18, lobes_14, eta_i_14, eta_o_14);
    (&sample_4)->pdf = _S1154;
    return sample_4;
}

static __device__ float3  reflect_0(float3  i_25, float3  n_10)
{
    return i_25 - make_float3 (2.0f * dot_0(n_10, i_25)) * n_10;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_9, float3  ggx_n_4, float3  n_i_13, float n_i_dot_v_10, float alpha_19, BSDFMaterial material_21, BSDFLobes lobes_15, float eta_i_15, float eta_o_15, uint random_state_18)
{
    float3  _S1155 = make_float3 (1.0f);
    SampleBSDF _S1156 = SampleBSDF_x24init_0(_S1155, _S1155, 0U, false, 0U, 0.0f);
    SampleBSDF sample_5 = _S1156;
    float3  _S1157 = reflect_0(in_dir_9, ggx_n_4);
    float3  _S1158 = ((((_S1157)) * make_float3(rnorm3df(((_S1157)).x, ((_S1157)).y, ((_S1157)).z))));
    (&sample_5)->unit_direction = _S1158;
    (&sample_5)->random_state = random_state_18;
    (&sample_5)->lobe = 2U;
    float3  _S1159 = reflectBSDF((&sample_5)->unit_direction, n_i_13, alpha_19, material_21, lobes_15);
    (&sample_5)->throughput = _S1159;
    float _S1160 = reflectPDF(0.0f, 0.0f, n_i_dot_v_10, alpha_19, lobes_15, eta_i_15, eta_o_15);
    (&sample_5)->pdf = _S1160;
    return sample_5;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_10, float3  n_11, BSDFMaterial material_22, float eta_i_16, float eta_o_16, uint random_init_0, float2  screen_space_0)
{
    uint random_state_19 = random_init_0;
    float3  _S1161 = negate_0(in_dir_10);
    float _S1162 = dot_0(n_11, _S1161);
    float _S1163 = sign_0(_S1162);
    float3  n_i_14 = n_11 * make_float3 (_S1163);
    float _S1164 = (F32_abs((_S1162)));
    float _S1165 = material_22.roughness;
    float _S1166 = _S1165 * _S1165;
    AnisotropicFrame _S1167 = anisotropicFrame(material_22, n_i_14);
    SheenProfile _S1168 = sheenProfile(_S1161, n_i_14, material_22);
    float3  _S1169 = sampleHalfVector(_S1161, n_i_14, _S1166, _S1167, &random_state_19);
    BSDFLobes _S1170 = bsdfLobes(in_dir_10, _S1161, n_i_14, _S1169, material_22, eta_i_16, eta_o_16, _S1167, _S1168);
    BSDFLobes lobes_16 = _S1170;
    float _S1171 = translucentShare(material_22);
    (&lobes_16)->translucent_share = _S1171;
    Random _S1172 = pcg(random_state_19);
    random_state_19 = _S1172.state;
    bool _S1173 = (_S1172.value) < ((&lobes_16)->p_sheen_velvet);
    if(_S1173)
    {
        SampleBSDF _S1174 = sheenVelvetSample(n_i_14, _S1164, _S1166, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1174;
    }
    float _S1175 = _S1172.value - (&lobes_16)->p_sheen_velvet;
    bool _S1176 = _S1175 < ((&lobes_16)->p_diffuse);
    if(_S1176)
    {
        SampleBSDF _S1177 = diffuseSample(_S1175, n_i_14, _S1164, _S1166, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1177;
    }
    bool _S1178 = _S1175 < ((&lobes_16)->p_diffuse + (&lobes_16)->p_toon);
    if(_S1178)
    {
        SampleBSDF _S1179 = toonSample(n_i_14, _S1164, _S1166, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1179;
    }
    float _S1180 = (&lobes_16)->p_toon;
    bool _S1181 = (_S1175 - _S1180) < ((&lobes_16)->p_diffuse + (&lobes_16)->p_refract);
    if(_S1181)
    {
        SampleBSDF _S1182 = refractSample(_S1169, n_i_14, _S1164, _S1166, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1182;
    }
    SampleBSDF _S1183 = reflectSample(in_dir_10, _S1169, n_i_14, _S1164, _S1166, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
    return _S1183;
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
    bool _S1184;
    bool _S1185;
    float density_2;
    float threshold_0;
    float width_3;
    float sky_pdf_0;
    float geometry_density_0;
    uint b_5;
    uint layer_0;
    float3  throughput_2;
    float3  chain_throughput_0;
    TreeSample light_3;
    int _S1186;
    Shift ended_0;
    float density_3;
    float spread_2;
    float width_4;
    float sky_pdf_1;
    float spread_3;
    float width_5;
    uint b_6;
    float3  _S1187 = make_float3 (0.0f);
    Shift _S1188 = Shift_x24init_0(_S1187, 0.0f);
    uint _S1189 = r_8->path;
    uint _S1190 = extractBits_0(r_8->path, 0U, 5U);
    uint _S1191 = extractBits_0(_S1189, 5U, 5U);
    uint _S1192 = extractBits_0(_S1189, 10U, 2U);
    uint _S1193 = extractBits_0(_S1189, 12U, 3U);
    bool passes_0;
    if(replay_1)
    {
        bool _S1194 = _S1193 >= 3U;
        uint _S1195 = _slang_select(_S1194, 1U,0U);
        uint _S1196 = _S1190 + _S1195;
        uint _S1197 = (fcptMaxBounces());
        passes_0 = _S1196 > _S1197;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1188;
    }
    uint _S1198 = _S1191 - 1U;
    bool _S1199 = _S1193 == 3U;
    uint _S1200 = _slang_select(_S1199, 1U,0U);
    uint _S1201 = _S1190 + _S1200;
    bool _S1202 = _S1192 == 0U;
    uint _S1203 = _slang_select(_S1202, _S1201,_S1198);
    FKHit _S1204 = (fcptReservoirHit((*r_8)));
    float3  _S1205 = dom_7->x0;
    float3  _S1206 = dom_7->x1 - dom_7->x0;
    float3  _S1207 = ((((_S1206)) * make_float3(rnorm3df(((_S1206)).x, ((_S1206)).y, ((_S1206)).z))));
    FKRay _S1208 = Ray_x24init_0(dom_7->x1, _S1207);
    FKRay ray_2 = _S1208;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1187;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_1 = throughput_3;
    float3  glowed_0 = _S1187;
    float3  extinction_in_0 = _S1187;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1209 = dom_7->spread;
    float _S1210 = dom_7->width;
    float _S1211 = length_0(_S1206);
    NEEVertex _S1212 = NEEVertex_x24init_0(true, 0.0f, _S1187, _S1187, _S1187);
    NEEVertex nee_vertex_0 = _S1212;
    Vertex _S1213 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S1213;
    Reservoir _S1214 = (Reservoir{});
    Reservoir chain_0 = _S1214;
    uint _S1215 = r_8->seed;
    (&chain_0)->seed = r_8->seed;
    (&ray_2)->origin = _S1205;
    (&hit_4)->distance = _S1211;
    FKMedium _S1216 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1217 = filling_2;
    bool _S1218 = (fcptVaryingUsed());
    uint _S1219 = _slang_select(_S1218, _S1217,4294967295U);
    filling_2 = _S1219;
    scatter_in_0 = _S1216.scatter;
    extinction_in_0 = _S1216.extinction;
    g_in_0 = _S1216.g;
    Reservoir _S1220 = chain_0;
    uint _S1221 = filling_2;
    for(;;)
    {
        bool _S1222 = (fcptVaryingUsed());
        if(_S1222)
        {
            passes_0 = _S1221 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1223 = (fcptMajorant((_S1221)));
            spread_1 = _S1223;
        }
        else
        {
            spread_1 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_1)
        {
            turned_1 = 4294967295U == _S1203;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1192 == 1U;
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
            ended_0 = _S1188;
            sky_pdf_0 = 0.0f;
            spread_1 = _S1209;
            width_3 = _S1210;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_5 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1224 = (&prev_0)->rough;
        if(_S1224)
        {
            turned_1 = !(spread_1 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S1225 = stream(_S1215, 384U);
        uint tracking_0 = _S1225;
        weight_1 = throughput_3;
        glowed_0 = _S1187;
        b_5 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        threshold_0 = _S1209;
        width_3 = _S1210;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1186 = int(1);
                break;
            }
            uint _S1226 = b_5 + 320U;
            bool _S1227 = b_5 == 4294967295U;
            uint _S1228 = _slang_select(_S1227, 384U,_S1226);
            uint _S1229 = stream(_S1215, _S1228);
            Random _S1230 = pcg(_S1229);
            float _S1231 = - (F32_log((1.0f - _S1230.value))) / spread_1;
            if(passes_0)
            {
                float3  _S1232 = (&ray_2)->origin;
                float3  _S1233 = (&ray_2)->unit_direction;
                float _S1234 = (&hit_4)->distance;
                uint _S1235 = _slang_select(_S1227, 0U,b_5);
                uint _S1236 = (&prev_0)->lobe;
                uint _S1237 = _slang_select(_S1227, 3U,_S1236);
                float _S1238 = (fcptTrackMedium((_S1221), (_S1232), (_S1233), (_S1234), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1235), (_S1237), (_S1227)));
                geometry_density_0 = _S1238;
            }
            else
            {
                geometry_density_0 = _S1231;
            }
            bool _S1239 = !(geometry_density_0 < ((&hit_4)->distance));
            if(_S1239)
            {
                _S1186 = int(1);
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
                float3  _S1240 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S1241 = sel_7->glow + _S1240;
                sel_7->glow = _S1241;
            }
            else
            {
            }
            glowed_0 = _S1187;
            uint b_7 = b_5 + 1U;
            float3  _S1242 = (&ray_2)->origin + make_float3 (geometry_density_0) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1242;
            float3  _S1243 = flightWeight_0(scatter_in_0, extinction_in_0, spread_1, geometry_density_0, true);
            float3  _S1244 = weight_1;
            float3  _S1245 = _slang_select(passes_0, _S1244,_S1243);
            float3  throughput_4 = throughput_2 * _S1245;
            uint _S1246 = stream(_S1215, b_7 + 320U);
            tracking_0 = _S1246;
            weight_1 = throughput_3;
            float width_6 = width_3 + threshold_0 * geometry_density_0;
            float _S1247 = threshold_0 + 3.14159274101257324f;
            bool _S1248 = !replay_1;
            if(_S1248)
            {
                is_inside_5 = true;
            }
            else
            {
                bool _S1249 = b_7 == _S1203;
                if(_S1249)
                {
                    is_inside_5 = !passes_0;
                }
                else
                {
                    is_inside_5 = false;
                }
            }
            TreeSample _S1250 = TreeSample_x24init_0(_S1187, _S1187, 0.0f, 0U);
            if(is_inside_5)
            {
                float3  _S1251 = (&ray_2)->origin;
                float3  _S1252 = (&ray_2)->unit_direction;
                float3  _S1253 = (&ray_2)->unit_direction;
                uint _S1254 = stream(_S1215, b_7 + 64U);
                float3  _S1255 = extinction_in_0;
                float3  _S1256 = extinction_in_0;
                uint2  _S1257 = make_uint2 (_S1221);
                float3  _S1258 = (&ray_2)->unit_direction;
                uint _S1259 = arrivalLobe_0(b_7, (&prev_0)->lobe);
                FKHit _S1260 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1261 = _S1260;
                ShadowContext _S1262 = ShadowContext_x24init_0(_S1255, _S1256, _S1257, _S1258, b_7, _S1259, false, geometry_density_0, width_6, &_S1261, false);
                ShadowContext _S1263 = _S1262;
                TreeSample _S1264 = sampleLightTree_0(_S1251, _S1252, _S1253, 0.0f, true, _S1254, &_S1263);
                light_3 = _S1264;
            }
            else
            {
                light_3 = _S1250;
            }
            float _S1265 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S1266 = (fcptMaxBounces());
            bool _S1267 = b_7 < _S1266;
            if(_S1267)
            {
                viewed_0 = (light_3.density) > 0.0f;
            }
            else
            {
                viewed_0 = false;
            }
            float _S1268 = _slang_select(viewed_0, _S1265,0.0f);
            float3  _S1269 = throughput_4 * light_3.radiance;
            float _S1270 = powerHeuristic(light_3.density, _S1268);
            float3  _S1271 = _S1269 * make_float3 (_S1265 * _S1270);
            float3  _S1272 = _slang_select(is_inside_5, _S1271,_S1187);
            if(replay_1)
            {
                _S1184 = b_7 == _S1203;
            }
            else
            {
                _S1184 = false;
            }
            if(_S1184)
            {
                bool _S1273 = _S1192 == 2U;
                if(_S1273)
                {
                    float _S1274 = rgb_to_greyscale(_S1272);
                    passes_0 = _S1274 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1275 = Shift_x24init_0(_S1272, 1.0f);
                    _S1186 = int(0);
                    ended_0 = _S1275;
                    spread_1 = _S1247;
                    geometry_density_0 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_7;
                    break;
                }
                _S1186 = int(0);
                ended_0 = _S1188;
                spread_1 = _S1247;
                geometry_density_0 = width_6;
                chain_throughput_0 = throughput_4;
                layer_0 = b_7;
                break;
            }
            if(_S1248)
            {
                Reservoir candidate_3 = _S1220;
                uint _S1276 = extractBits_0(_S1220.path, 10U, 2U);
                bool _S1277 = _S1276 == 1U;
                if(_S1277)
                {
                    float3  _S1278 = safeDivide(_S1272, _S1187);
                    (&candidate_3)->radiance = _S1278;
                }
                else
                {
                    uint _S1279 = insertBits_0(0U, b_7 + 1U, 5U, 5U);
                    uint _S1280 = insertBits_0(_S1279, 2U, 10U, 2U);
                    (&candidate_3)->path = _S1280;
                }
                Reservoir _S1281 = withEnd(candidate_3, 0U, b_7, _S1272);
                offer(sel_7, _S1281, _S1272 * make_float3 (scale_3) / make_float3 (density_2));
                float _S1282 = survivalProbability(throughput_4, density_2);
                uint _S1283 = stream(_S1215, b_7 + 128U);
                Random _S1284 = pcg(_S1283);
                bool _S1285 = _S1282 < (_S1284.value);
                if(_S1285)
                {
                    _S1185 = true;
                }
                else
                {
                    uint _S1286 = (fcptMaxBounces());
                    _S1185 = b_7 >= _S1286;
                }
                if(_S1185)
                {
                    _S1186 = int(0);
                    ended_0 = _S1188;
                    spread_1 = _S1247;
                    geometry_density_0 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_7;
                    break;
                }
                float _S1287 = density_2 * _S1282;
                density_2 = _S1287;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1288 = stream(_S1215, b_7);
            float3  _S1289 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1288, &phase_pdf_0);
            (&ray_2)->unit_direction = _S1289;
            NEEVertex _S1290 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S1187, (&ray_2)->origin);
            nee_vertex_0 = _S1290;
            Vertex _S1291 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, false);
            prev_0 = _S1291;
            float _S1292 = (&prev_0)->pdf;
            FKRay _S1293 = ray_2;
            FKHit _S1294 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1295 = (fcptTraverseInstanceBVH((_S1293), (true), (4.294967296e+09f), (false), (_S1294), (false)));
            hit_4 = _S1295;
            b_5 = b_7;
            throughput_2 = throughput_4;
            threshold_0 = _S1247;
            width_3 = width_6;
            sky_pdf_0 = _S1292;
        }
        if(_S1186 != int(1))
        {
            width_3 = geometry_density_0;
            throughput_2 = chain_throughput_0;
            b_5 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1188;
        spread_1 = threshold_0;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1296 = b_5 == 4294967295U;
    bool _S1297 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1297)
    {
        bool _S1298 = !(&nee_vertex_0)->none;
        float _S1299 = _slang_select(_S1298, sky_pdf_0,0.0f);
        float _S1300 = escapeWeight_0(_S1299, (&ray_2)->unit_direction);
        float3  _S1301 = environment_0((&ray_2)->unit_direction, b_5, (&prev_0)->lobe);
        float3  _S1302 = throughput_2 * _S1301;
        if(replay_1)
        {
            bool _S1303 = b_5 == _S1203;
            if(_S1303)
            {
                passes_0 = _S1192 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S1302 * make_float3 (_S1300) / make_float3 (r_8->jac), density_2 / r_8->jac);
            }
            if(_S1202)
            {
                passes_0 = _S1199;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_5 == _S1190;
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
                return Shift_x24init_0(_S1302 * make_float3 (_S1300), 1.0f);
            }
            return _S1188;
        }
        Reservoir candidate_4 = chain_0;
        uint _S1304 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1305 = _S1304 == 1U;
        if(_S1305)
        {
            uint _S1306 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S1307 = _S1306 == b_5;
            float _S1308 = _slang_select(_S1307, 1.0f,_S1300);
            float3  _S1309 = safeDivide(_S1302 * make_float3 (_S1308), _S1187);
            (&candidate_4)->radiance = _S1309;
        }
        else
        {
            bool _S1310 = (&prev_0)->rough;
            if(_S1310)
            {
                uint _S1311 = insertBits_0(0U, b_5 + 1U, 5U, 5U);
                uint _S1312 = insertBits_0(_S1311, 3U, 10U, 2U);
                uint _S1313 = insertBits_0(_S1312, (&prev_0)->lobe, 15U, 3U);
                bool _S1314 = (&prev_0)->inside;
                uint _S1315 = _slang_select(_S1314, 1U,0U);
                uint _S1316 = insertBits_0(_S1313, _S1315, 22U, 1U);
                (&candidate_4)->path = _S1316;
                (&candidate_4)->jac = (&prev_0)->pdf;
                (&candidate_4)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S1317 = _S1302 * make_float3 (_S1300);
        Reservoir _S1318 = withEnd(candidate_4, 3U, b_5, _S1317);
        offer(sel_7, _S1318, _S1317 * make_float3 (scale_3) / make_float3 (density_2));
        return _S1188;
    }
    float3  _S1319 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S1319;
    bool _S1320 = (fcptVaryingUsed());
    if(_S1320)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1321 = !replay_1;
        if(_S1321)
        {
            float3  _S1322 = throughput_2 * glowed_0 / make_float3 (density_2);
            float3  _S1323 = sel_7->glow + _S1322;
            sel_7->glow = _S1323;
        }
        float3  _S1324 = throughput_2 * weight_1;
        throughput_2 = _S1324;
    }
    else
    {
        float3  _S1325 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
        float3  _S1326 = throughput_2 * _S1325;
        throughput_2 = _S1326;
    }
    float _S1327 = width_3 + spread_1 * (&hit_4)->distance;
    uint _S1328 = b_5 + 1U;
    b_5 = _S1328;
    layer_0 = 0U;
    width_3 = _S1327;
    passes_0 = false;
    threshold_0 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    chain_throughput_0 = _S1187;
    float3  reconnection_0 = _S1187;
    viewed_0 = _S1296;
    for(;;)
    {
        bool _S1329 = ((&hit_4)->is_point_light) == 1U;
        if(replay_1)
        {
            _S1184 = _S1192 == 1U;
        }
        else
        {
            _S1184 = false;
        }
        if(_S1184)
        {
            _S1185 = b_5 == _S1191;
        }
        else
        {
            _S1185 = false;
        }
        bool _S1330;
        if(_S1185)
        {
            bool _S1331 = ((&hit_4)->instance_index) != (_S1204.instance_index);
            if(_S1331)
            {
                _S1330 = true;
            }
            else
            {
                _S1330 = ((&hit_4)->triangle_index) != (_S1204.triangle_index);
            }
        }
        else
        {
            _S1330 = false;
        }
        if(_S1330)
        {
            return _S1188;
        }
        FKMedium _S1332 = Medium_x24init_0(_S1187, _S1187, 0.0f);
        BSDFMaterial _S1333 = Material_x24init_0(_S1187, _S1187, 0.0f, 0.0f, 0.0f, 0.0f, _S1187, throughput_3, 1.0f, _S1187, _S1187, 0.5f, 0.0f, 0.0f, _S1187, 0.0f, _S1187);
        FKMedium _S1334 = _S1332;
        FKSurface _S1335 = Surface_x24init_0(_S1187, _S1187, 0.0f, &_S1333, false, 0U, 1.0f, false, &_S1334, 4294967295U, _S1187);
        bool _S1336 = !_S1329;
        bool scatter_2;
        bool is_inside_6;
        float3  throughput_5;
        FKSurface surface_12;
        if(_S1336)
        {
            uint _S1337 = stream(_S1215, b_5);
            uint _S1338 = arrivalLobe_0(b_5, (&prev_0)->lobe);
            FKSurface _S1339 = (fcptSurfaceAtPath((hit_4), ((&ray_2)->origin), (_S1337), (width_3), (layer_0), (b_5), (_S1338), ((&ray_2)->unit_direction)));
            bool _S1340 = !passes_0;
            FKSurface _S1341 = _S1339;
            FKSurface _S1342 = emitting_0(&_S1341, _S1340);
            uint _S1343 = stream(_S1215, b_5 + 256U);
            Random _S1344 = pcg(_S1343);
            FKSurface _S1345 = _S1342;
            FKSurface _S1346 = uncovered_0(&_S1345, _S1344.value);
            float _S1347 = facingSign(_S1346.material.transmission, _S1346.geometry_n, (&ray_2)->unit_direction);
            bool _S1348 = _S1347 < 0.0f;
            bool _S1349 = (_S1346.material.transmission) > 0.0f;
            if(_S1349)
            {
                bool _S1350 = arrivesBehind_0((&ray_2)->unit_direction, _S1346.geometry_n);
                scatter_2 = _S1350;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1351 = _S1346;
            FKSurface _S1352 = facingRay_0(&_S1351, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S1353 = arrivesBehind_0((&ray_2)->unit_direction, _S1352.geometry_n);
                is_inside_6 = _S1353;
            }
            else
            {
                is_inside_6 = scatter_2;
            }
            if(is_inside_6)
            {
                float3  _S1354 = beerLambert((&hit_4)->distance, _S1352.material.absorption);
                float3  _S1355 = throughput_2 * _S1354;
                throughput_5 = _S1355;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S1356 = !_S1352.skip;
            float geometry_density_1 = (F32_abs((dot_0(_S1352.geometry_n, (&ray_2)->unit_direction)))) / ((&hit_4)->distance * (&hit_4)->distance);
            bool _S1357 = b_5 == _S1328;
            if(_S1357)
            {
                float _S1358 = 0.00251327408477664f / geometry_density_1;
                geometry_density_0 = _S1358;
            }
            else
            {
                geometry_density_0 = threshold_0;
            }
            float _S1359 = geometry_density_0;
            scatter_2 = _S1356;
            geometry_density_0 = geometry_density_1;
            threshold_0 = _S1359;
            surface_12 = _S1352;
            turned_1 = _S1348;
        }
        else
        {
            scatter_2 = false;
            geometry_density_0 = 0.0f;
            surface_12 = _S1335;
            throughput_5 = throughput_2;
            is_inside_6 = is_inside_5;
        }
        bool _S1360;
        if(scatter_2)
        {
            _S1360 = (&prev_0)->rough;
        }
        else
        {
            _S1360 = false;
        }
        bool _S1361;
        if(_S1360)
        {
            _S1361 = ((&prev_0)->pdf * geometry_density_0 * threshold_0) <= 1.0f;
        }
        else
        {
            _S1361 = false;
        }
        FKSurface _S1362 = surface_12;
        FKSurface _S1363 = surface_12;
        float _S1364 = dot_0(surface_12.smooth_n, - (&ray_2)->unit_direction);
        float2  _S1365 = vertexEta(_S1362.material, _S1364);
        bool _S1366;
        if(scatter_2)
        {
            uint _S1367 = (fcptMaxBounces());
            bool _S1368 = b_5 >= _S1367;
            if(_S1368)
            {
                _S1366 = true;
            }
            else
            {
                bool _S1369 = neeDecision(_S1362.material, _S1364, _S1365.x, _S1365.y);
                _S1366 = _S1369;
            }
        }
        else
        {
            _S1366 = false;
        }
        bool _S1370;
        if(passes_0)
        {
            _S1370 = true;
        }
        else
        {
            _S1370 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1370)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1366;
        }
        bool _S1371 = (fcptHairUsed());
        bool _S1372;
        if(_S1371)
        {
            float3  _S1373 = surface_12.hair;
            _S1372 = (dot_0(_S1373, _S1373)) > 0.0f;
        }
        else
        {
            _S1372 = false;
        }
        bool _S1374;
        if(_S1372)
        {
            _S1374 = true;
        }
        else
        {
            BSDFMaterial _S1375 = _S1362.material;
            bool _S1376 = isTranslucent_0(&_S1375);
            _S1374 = _S1376;
        }
        bool _S1377;
        if(_S1374)
        {
            _S1377 = true;
        }
        else
        {
            bool _S1378 = (_S1362.material.transmission) > 0.0f;
            if(_S1378)
            {
                uint _S1379 = (fcptLayers((hit_4)));
                _S1377 = _S1379 == 1U;
            }
            else
            {
                _S1377 = false;
            }
        }
        float3  emission_0;
        if(_S1329)
        {
            float3  _S1380 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1380;
        }
        else
        {
            emission_0 = _S1362.material.emissive;
        }
        bool _S1381 = !replay_1;
        bool _S1382;
        if(_S1381)
        {
            _S1382 = true;
        }
        else
        {
            _S1382 = b_5 >= _S1203;
        }
        bool _S1383;
        if(_S1382)
        {
            float _S1384 = rgb_to_greyscale(emission_0);
            _S1383 = _S1384 > 0.0f;
        }
        else
        {
            _S1383 = false;
        }
        float3  emission_1;
        if(_S1383)
        {
            NEEVertex _S1385 = nee_vertex_0;
            FKHit _S1386 = hit_4;
            float _S1387 = emissionWeight_0(&_S1385, &_S1386, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1387);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1388;
        if(replay_1)
        {
            _S1388 = _S1192 == 1U;
        }
        else
        {
            _S1388 = false;
        }
        bool _S1389;
        if(_S1388)
        {
            _S1389 = b_5 > _S1191;
        }
        else
        {
            _S1389 = false;
        }
        bool _S1390;
        if(_S1389)
        {
            _S1390 = b_5 == _S1190;
        }
        else
        {
            _S1390 = false;
        }
        bool _S1391;
        if(_S1390)
        {
            bool _S1392 = _S1193 == 1U;
            if(_S1392)
            {
                _S1391 = true;
            }
            else
            {
                _S1391 = _S1193 == 2U;
            }
        }
        else
        {
            _S1391 = false;
        }
        if(_S1391)
        {
            bool _S1393 = _S1329 != (_S1193 == 2U);
            if(_S1393)
            {
                return _S1188;
            }
            return Shift_x24init_0(throughput_5 * emission_1 / make_float3 (r_8->jac), density_2 / r_8->jac);
        }
        uint _S1394 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1395 = _S1394 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1396 = insertBits_0(0U, b_5, 5U, 5U);
        uint _S1397 = insertBits_0(_S1396, 1U, 10U, 2U);
        uint _S1398 = insertBits_0(_S1397, (&prev_0)->lobe, 15U, 3U);
        bool _S1399 = (&prev_0)->inside;
        uint _S1400 = _slang_select(_S1399, 1U,0U);
        uint _S1401 = insertBits_0(_S1398, _S1400, 22U, 1U);
        (&here_0)->path = _S1401;
        float _S1402 = (&prev_0)->pdf * geometry_density_0;
        (&here_0)->jac = _S1402;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1403;
        if(replay_1)
        {
            _S1403 = _S1192 == 1U;
        }
        else
        {
            _S1403 = false;
        }
        bool _S1404;
        if(_S1403)
        {
            _S1404 = b_5 == _S1191;
        }
        else
        {
            _S1404 = false;
        }
        bool _S1405 = b_5 == _S1203;
        bool _S1406;
        if(_S1405)
        {
            bool _S1407 = !scatter_2;
            if(_S1407)
            {
                _S1406 = true;
            }
            else
            {
                bool _S1408 = _S1192 != 1U;
                if(_S1408)
                {
                    _S1406 = _S1192 != 3U;
                }
                else
                {
                    _S1406 = false;
                }
            }
        }
        else
        {
            _S1406 = false;
        }
        bool _S1409;
        if(_S1406)
        {
            _S1409 = _S1192 == 2U;
        }
        else
        {
            _S1409 = false;
        }
        bool _S1410;
        if(_S1409)
        {
            _S1410 = !_S1361;
        }
        else
        {
            _S1410 = false;
        }
        bool _S1411;
        if(_S1410)
        {
            _S1411 = _S1193 != 4U;
        }
        else
        {
            _S1411 = false;
        }
        bool _S1412 = _S1191 == _S1190;
        bool _S1413;
        if(_S1412)
        {
            _S1413 = _S1193 == 0U;
        }
        else
        {
            _S1413 = false;
        }
        bool _S1414;
        if(_S1413)
        {
            _S1414 = ((&hit_4)->instance_index) == (_S1204.instance_index);
        }
        else
        {
            _S1414 = false;
        }
        bool _S1415;
        if(_S1414)
        {
            _S1415 = ((&hit_4)->triangle_index) == (_S1204.triangle_index);
        }
        else
        {
            _S1415 = false;
        }
        bool _S1416;
        if(_S1415)
        {
            _S1416 = _S1361;
        }
        else
        {
            _S1416 = false;
        }
        bool _S1417 = _slang_select(_S1404, _S1416,_S1411);
        bool _S1418;
        if(nee_0)
        {
            _S1418 = _slang_select(replay_1, _S1417,scatter_2);
        }
        else
        {
            _S1418 = false;
        }
        TreeSample _S1419 = TreeSample_x24init_0(_S1187, _S1187, 0.0f, 0U);
        uint2  _S1420 = make_uint2 (0U);
        float2  _S1421 = make_float2 (0.0f);
        FKHit _S1422 = Hit_x24init_0(_S1421, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1423 = _S1422;
        ShadowContext _S1424 = ShadowContext_x24init_0(_S1187, _S1187, _S1420, _S1187, 0U, 0U, false, 0.0f, 0.0f, &_S1423, false);
        bool _S1425;
        if(nee_0)
        {
            _S1425 = _S1382;
        }
        else
        {
            _S1425 = false;
        }
        ShadowContext context_5;
        if(_S1425)
        {
            uint _S1426 = arrivalLobe_0(b_5, (&prev_0)->lobe);
            FKMedium _S1427 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1428 = surface_12;
            FKHit _S1429 = hit_4;
            FKMedium _S1430 = _S1427;
            ShadowContext _S1431 = shadowContext_0(&_S1428, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_5, _S1426, (&hit_4)->distance, width_3, &_S1429, _S1372, &_S1430);
            context_5 = _S1431;
        }
        else
        {
            context_5 = _S1424;
        }
        float3  throughput_6;
        float3  lit_0;
        if(_S1418)
        {
            float3  _S1432 = (&ray_2)->origin;
            if(_S1372)
            {
                throughput_6 = _S1187;
            }
            else
            {
                throughput_6 = _S1363.smooth_n;
            }
            FKSurface _S1433 = surface_12;
            uint _S1434 = stream(_S1215, b_5 + 64U);
            ShadowContext _S1435 = context_5;
            TreeSample _S1436 = sampleLightTree_0(_S1432, throughput_6, surface_12.geometry_n, surface_12.geometry_offset, _S1377, _S1434, &_S1435);
            bool _S1437 = any_1((_S1436.radiance) != _S1187);
            if(_S1437)
            {
                if(_S1372)
                {
                    uint _S1438 = (fcptMaxBounces());
                    bool _S1439 = b_5 < _S1438;
                    FKSurface _S1440 = surface_12;
                    TreeSample _S1441 = _S1436;
                    float3  _S1442 = hairLight_0(&_S1440, (&ray_2)->unit_direction, &_S1441, _S1439);
                    lit_0 = _S1442;
                }
                else
                {
                    float _S1443 = _S1365.x;
                    float _S1444 = _S1365.y;
                    uint _S1445 = (fcptMaxBounces());
                    bool _S1446 = b_5 < _S1445;
                    TreeSample _S1447 = _S1436;
                    BSDFMaterial _S1448 = _S1362.material;
                    float3  _S1449 = lightBSDF_0((&ray_2)->unit_direction, &_S1447, _S1363.smooth_n, _S1433.geometry_n, &_S1448, _S1443, _S1444, _S1446, surface_12.random_state);
                    lit_0 = _S1449;
                }
            }
            else
            {
                lit_0 = _S1187;
            }
            light_3 = _S1436;
        }
        else
        {
            light_3 = _S1419;
            lit_0 = _S1187;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1450;
        bool _S1451;
        float density_4;
        if(_S1404)
        {
            bool _S1452 = !_S1361;
            if(_S1452)
            {
                return _S1188;
            }
            float3  throughput_7 = throughput_5 * make_float3 (geometry_density_0);
            float density_5 = density_2 * geometry_density_0;
            if(_S1412)
            {
                viewed_1 = _S1193 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                return Shift_x24init_0(throughput_7 * emission_1 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1412)
            {
                refracted_4 = _S1193 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S1453 = !nee_0;
                if(_S1453)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1454 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1454 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1188;
                }
                return Shift_x24init_0(throughput_7 * lit_0 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1412)
            {
                wrong_side_0 = _S1193 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1455 = !nee_0;
                if(_S1455)
                {
                    return _S1188;
                }
                float _S1456 = environmentPdf_0(r_8->dir);
                float3  _S1457 = skyBSDF((&ray_2)->unit_direction, r_8->dir, surface_12, _S1365, is_inside_6, _S1456, surface_12.random_state);
                return Shift_x24init_0(throughput_7 * _S1457 * r_8->radiance / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            uint _S1458 = extractBits_0(_S1189, 21U, 1U);
            bool _S1459 = nee_0 != (_S1458 == 1U);
            if(_S1459)
            {
                return _S1188;
            }
            throughput_6 = throughput_7;
            density_4 = density_5;
        }
        else
        {
            if(replay_1)
            {
                viewed_1 = _S1405;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1460 = !scatter_2;
                if(_S1460)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1461 = _S1192 != 1U;
                    if(_S1461)
                    {
                        refracted_4 = _S1192 != 3U;
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
                bool _S1462 = _S1192 == 2U;
                if(_S1462)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1361;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1193 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1372)
                    {
                        return _S1188;
                    }
                    uint _S1463 = stream(_S1215, b_5 + 448U);
                    FKRay _S1464 = ray_2;
                    FKSurface _S1465 = surface_12;
                    ShadowContext _S1466 = context_5;
                    SkySample _S1467 = sampleSky_0(&_S1464, &_S1465, _S1365, is_inside_6, _S1463, surface_12.random_state, &_S1466);
                    return Shift_x24init_0(throughput_5 * _S1467.color, 1.0f);
                }
                if(_S1462)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1361;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1468 = rgb_to_greyscale(light_3.radiance);
                    bool _S1469 = !(_S1468 > 0.0f);
                    if(_S1469)
                    {
                        return _S1188;
                    }
                    return Shift_x24init_0(throughput_5 * lit_0, 1.0f);
                }
                if(_S1202)
                {
                    passes_0 = _S1193 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1329;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                if(_S1202)
                {
                    passes_0 = _S1193 == 1U;
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
                    passes_0 = !_S1361;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                return _S1188;
            }
            else
            {
                if(_S1381)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1470 = b_5 > 0U;
                    if(_S1470)
                    {
                        Reservoir candidate_5 = chain_0;
                        if(_S1395)
                        {
                            float3  _S1471 = safeDivide(throughput_5 * emission_1, chain_throughput_0);
                            (&candidate_5)->radiance = _S1471;
                        }
                        else
                        {
                            if(_S1361)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1472 = throughput_5 * emission_1;
                        Reservoir _S1473 = withEnd(candidate_5, 1U, b_5, _S1472);
                        offer(sel_7, _S1473, _S1472 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1474 = throughput_5 * emission_1;
                        float3  _S1475 = sel_7->glow + _S1474;
                        sel_7->glow = _S1475;
                    }
                    if(nee_0)
                    {
                        float3  _S1476 = throughput_5 * lit_0;
                        Reservoir candidate_6 = chain_0;
                        if(_S1395)
                        {
                            float3  _S1477 = safeDivide(_S1476, chain_throughput_0);
                            (&candidate_6)->radiance = _S1477;
                        }
                        else
                        {
                            if(_S1361)
                            {
                                candidate_6 = here_0;
                                uint _S1478 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1478;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1479 = insertBits_0(0U, b_5 + 1U, 5U, 5U);
                                uint _S1480 = insertBits_0(_S1479, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1480;
                            }
                        }
                        Reservoir _S1481 = withEnd(candidate_6, 0U, b_5, _S1476);
                        offer(sel_7, _S1481, _S1476 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1372)
                        {
                            _S1450 = false;
                        }
                        else
                        {
                            bool _S1482 = environmentMapped_0();
                            _S1450 = _S1482;
                        }
                    }
                    else
                    {
                        _S1450 = false;
                    }
                    if(_S1450)
                    {
                        uint _S1483 = (fcptMaxBounces());
                        _S1451 = b_5 < _S1483;
                    }
                    else
                    {
                        _S1451 = false;
                    }
                    if(_S1451)
                    {
                        uint _S1484 = stream(_S1215, b_5 + 448U);
                        FKRay _S1485 = ray_2;
                        FKSurface _S1486 = surface_12;
                        ShadowContext _S1487 = context_5;
                        SkySample _S1488 = sampleSky_0(&_S1485, &_S1486, _S1365, is_inside_6, _S1484, surface_12.random_state, &_S1487);
                        float3  _S1489 = throughput_5 * _S1488.color;
                        Reservoir candidate_7 = chain_0;
                        if(_S1395)
                        {
                            float3  _S1490 = safeDivide(_S1489, chain_throughput_0);
                            (&candidate_7)->radiance = _S1490;
                        }
                        else
                        {
                            if(_S1361)
                            {
                                candidate_7 = here_0;
                                uint _S1491 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1491;
                                (&candidate_7)->dir = _S1488.dir;
                                (&candidate_7)->radiance = _S1488.radiance;
                            }
                            else
                            {
                                uint _S1492 = insertBits_0(0U, b_5 + 1U, 5U, 5U);
                                uint _S1493 = insertBits_0(_S1492, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1493;
                            }
                        }
                        Reservoir _S1494 = withEnd(candidate_7, 4U, b_5, _S1489);
                        offer(sel_7, _S1494, _S1489 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                }
            }
            throughput_6 = throughput_5;
            density_4 = density_2;
        }
        bool _S1495;
        bool _S1496;
        bool _S1497;
        bool straight_0;
        bool _S1498;
        bool _S1499;
        bool _S1500;
        bool _S1501;
        bool _S1502;
        bool _S1503;
        bool _S1504;
        bool _S1505;
        bool _S1506;
        bool _S1507;
        bool _S1508;
        bool _S1509;
        bool _S1510;
        float density_6;
        float sky_pdf_2;
        float spread_4;
        uint b_8;
        float3  throughput_8;
        float3  throughput_9;
        float3  throughput_10;
        if(scatter_2)
        {
            if(replay_1)
            {
                viewed_1 = _S1405;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1511 = extractBits_0(_S1189, 15U, 3U);
            uint _S1512 = extractBits_0(_S1189, 18U, 3U);
            uint _S1513 = _slang_select(_S1404, _S1512,_S1511);
            float3  _S1514 = r_8->dir;
            bool refracted_5 = _S1513 == 1U;
            SampleBSDF _S1515 = SampleBSDF_x24init_0(_S1187, _S1187, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1515;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1516 = extractBits_0(_S1189, 22U, 1U);
                bool _S1517 = is_inside_6 != (_S1516 == 1U);
                if(_S1517)
                {
                    return _S1188;
                }
                bool _S1518 = _S1192 == 1U;
                if(_S1518)
                {
                    float3  _S1519 = (fcptHitPosition((_S1204)));
                    throughput_8 = _S1519;
                }
                else
                {
                    throughput_8 = reconnection_0;
                }
                if(refracted_5)
                {
                    refracted_4 = true;
                }
                else
                {
                    BSDFMaterial _S1520 = _S1362.material;
                    bool _S1521 = isTranslucent_0(&_S1520);
                    if(_S1521)
                    {
                        refracted_4 = _S1513 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1522 = throughput_8 - (&ray_2)->origin;
                        float3  _S1523 = _slang_select(_S1518, _S1522,_S1514);
                        wrong_side_0 = (dot_0(_S1363.smooth_n, _S1523) * _S1364) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1518)
                {
                    float3  _S1524 = (&ray_2)->origin;
                    FKSurface _S1525 = surface_12;
                    float3  _S1526 = - _S1363.smooth_n;
                    bool _S1527 = is_inside_6 != refracted_4;
                    float3  _S1528 = _slang_select(_S1527, _S1526,_S1363.smooth_n);
                    float3  _S1529 = throughput_8 - (_S1524 + make_float3 (_S1525.geometry_offset) * _S1528);
                    float3  _S1530 = ((((_S1529)) * make_float3(rnorm3df(((_S1529)).x, ((_S1529)).y, ((_S1529)).z))));
                    reconnection_1 = _S1530;
                }
                else
                {
                    reconnection_1 = _S1514;
                }
                if(_S1372)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1531 = wrongSide_0(is_inside_6, refracted_4, reconnection_1, surface_12.geometry_n);
                    wrong_side_0 = _S1531;
                }
                if(wrong_side_0)
                {
                    return _S1188;
                }
                float3  _S1532 = throughput_8;
                throughput_8 = reconnection_1;
                b_8 = _S1513;
                wrong_side_0 = false;
                reconnection_1 = _S1532;
            }
            else
            {
                bool _S1533 = !_S1404;
                if(_S1533)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1534;
                    if(_S1372)
                    {
                        SampleBSDF _S1535 = (fcptSampleHair((surface_12.hair), (_S1362.material.albedo), (_S1362.material.specular_tint), ((&ray_2)->unit_direction), (surface_12.random_state)));
                        _S1534 = _S1535;
                    }
                    else
                    {
                        SampleBSDF _S1536 = sampleBSDF((&ray_2)->unit_direction, _S1363.smooth_n, _S1362.material, _S1365.x, _S1365.y, surface_12.random_state, _S1421);
                        _S1534 = _S1536;
                    }
                    bsdf_sampled_0 = _S1534;
                    if(_S1372)
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
                            return _S1188;
                        }
                        break;
                    }
                    if(_S1372)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1537 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_12.geometry_n);
                        wrong_side_0 = _S1537;
                    }
                    if(wrong_side_0)
                    {
                        _S1450 = (_S1362.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1450 = false;
                    }
                    if(_S1450)
                    {
                        SampleBSDF _S1538 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S1362.material, _S1365.x, _S1365.y, (&bsdf_sampled_0)->random_state, _S1421);
                        (&bsdf_sampled_0)->unit_direction = _S1538.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1538.refracted;
                        (&bsdf_sampled_0)->throughput = _S1538.throughput;
                        (&bsdf_sampled_0)->lobe = _S1538.lobe;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1539 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n)) * surface_12.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1539;
                        }
                    }
                    uint _S1540 = (&bsdf_sampled_0)->lobe;
                    float3  _S1541 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1542 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1543 = (&bsdf_sampled_0)->pdf;
                    float _S1544 = _slang_select(wrong_side_0, 0.0f,_S1543);
                    (&lobe_5)->pdf = _S1544;
                    throughput_8 = _S1541;
                    b_8 = _S1540;
                    refracted_4 = _S1542;
                }
                else
                {
                    throughput_8 = _S1514;
                    b_8 = _S1513;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1450 = true;
            }
            else
            {
                _S1450 = _S1404;
            }
            float3  chain_throughput_1;
            if(_S1450)
            {
                if(_S1372)
                {
                    SampleBSDF _S1545 = (fcptConnectHair((surface_12.hair), (_S1362.material.albedo), (_S1362.material.specular_tint), ((&ray_2)->unit_direction), (throughput_8)));
                    lobe_5 = _S1545;
                }
                else
                {
                    float3  _S1546 = (&ray_2)->unit_direction;
                    float _S1547 = sign_0(_S1364);
                    float3  _S1548 = _S1363.smooth_n * make_float3 (_S1547);
                    float _S1549 = dot_0(_S1548, throughput_8);
                    float _S1550 = _S1362.material.roughness;
                    float _S1551 = _S1550 * _S1550;
                    AnisotropicFrame _S1552 = anisotropicFrame(_S1362.material, _S1548);
                    float3  _S1553 = negate_0(_S1546);
                    SheenProfile _S1554 = sheenProfile(_S1553, _S1548, _S1362.material);
                    float3  _S1555 = reflectedHalf(_S1546, throughput_8);
                    bool _S1556 = b_8 == 1U;
                    if(_S1556)
                    {
                        float3  _S1557 = refractedHalf(_S1546, throughput_8, _S1363.smooth_n, _S1365.x, _S1365.y);
                        throughput_9 = _S1557;
                    }
                    else
                    {
                        throughput_9 = _S1555;
                    }
                    bool _S1558 = b_8 == 0U;
                    if(_S1558)
                    {
                        _S1451 = true;
                    }
                    else
                    {
                        _S1451 = b_8 == 6U;
                    }
                    if(_S1451)
                    {
                        float3  _S1559 = sampledHalf(_S1546, _S1363.smooth_n, _S1362.material, surface_12.random_state, _S1552);
                        throughput_10 = _S1559;
                    }
                    else
                    {
                        throughput_10 = throughput_9;
                    }
                    float3  _S1560 = negate_0(_S1546);
                    float _S1561 = _S1365.x;
                    float _S1562 = _S1365.y;
                    BSDFLobes _S1563 = bsdfLobes(_S1546, _S1560, _S1548, throughput_10, _S1362.material, _S1561, _S1562, _S1552, _S1554);
                    BSDFLobes lobe_terms_1 = _S1563;
                    float _S1564 = translucentShare(_S1362.material);
                    (&lobe_terms_1)->translucent_share = _S1564;
                    switch(b_8)
                    {
                    case 0U:
                        {
                            float _S1565 = diffusePDF(_S1549, 0.0f, (F32_abs((_S1364))), _S1551, lobe_terms_1, _S1561, _S1562);
                            float3  _S1566 = diffuseBSDF(throughput_8, _S1548, _S1551, _S1362.material, lobe_terms_1);
                            density_6 = _S1565;
                            chain_throughput_1 = _S1566;
                            break;
                        }
                    case 1U:
                        {
                            float _S1567 = refractPDF(_S1549, dot_0(throughput_8, throughput_10), (F32_abs((_S1364))), _S1551, lobe_terms_1, _S1561, _S1562);
                            float3  _S1568 = refractBSDF(throughput_8, _S1548, _S1551, _S1362.material, lobe_terms_1);
                            density_6 = _S1567;
                            chain_throughput_1 = _S1568;
                            break;
                        }
                    case 4U:
                        {
                            float _S1569 = sheenVelvetPDF(_S1549, 0.0f, (F32_abs((_S1364))), _S1551, lobe_terms_1, _S1561, _S1562);
                            float3  _S1570 = sheenVelvetBSDF(throughput_8, _S1548, _S1551, _S1362.material, lobe_terms_1);
                            density_6 = _S1569;
                            chain_throughput_1 = _S1570;
                            break;
                        }
                    case 6U:
                        {
                            float _S1571 = toonPDF(_S1549, dot_0(throughput_8, (&lobe_terms_1)->toon_axis), (F32_abs((_S1364))), _S1551, lobe_terms_1, _S1561, _S1562);
                            float3  _S1572 = toonBSDF(throughput_8, _S1548, _S1551, _S1362.material, lobe_terms_1);
                            density_6 = _S1571;
                            chain_throughput_1 = _S1572;
                            break;
                        }
                    default:
                        {
                            float _S1573 = reflectPDF(_S1549, 0.0f, (F32_abs((_S1364))), _S1551, lobe_terms_1, _S1561, _S1562);
                            float3  _S1574 = reflectBSDF(throughput_8, _S1548, _S1551, _S1362.material, lobe_terms_1);
                            density_6 = _S1573;
                            chain_throughput_1 = _S1574;
                            break;
                        }
                    }
                    bool _S1575 = density_6 > 0.0f;
                    if(_S1575)
                    {
                        SampleBSDF _S1576 = SampleBSDF_x24init_0(throughput_8, chain_throughput_1, surface_12.random_state, _S1556, b_8, density_6);
                        lobe_5 = _S1576;
                    }
                }
            }
            bool _S1577 = b_8 == 0U;
            if(_S1577)
            {
                _S1451 = true;
            }
            else
            {
                _S1451 = b_8 == 4U;
            }
            if(_S1451)
            {
                _S1495 = true;
            }
            else
            {
                _S1495 = b_8 == 6U;
            }
            if(_S1372)
            {
                _S1496 = false;
            }
            else
            {
                bool _S1578 = !_S1495;
                if(_S1578)
                {
                    bool _S1579 = (_S1362.material.roughness) == 0.0f;
                    if(_S1579)
                    {
                        _S1496 = true;
                    }
                    else
                    {
                        bool _S1580 = b_8 == 1U;
                        if(_S1580)
                        {
                            _S1496 = (_S1365.x) == (_S1365.y);
                        }
                        else
                        {
                            _S1496 = false;
                        }
                    }
                }
                else
                {
                    _S1496 = false;
                }
            }
            bool _S1581 = !_S1372;
            if(_S1581)
            {
                _S1497 = b_8 == 1U;
            }
            else
            {
                _S1497 = false;
            }
            if(_S1497)
            {
                straight_0 = (_S1362.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1498 = _S1581;
            }
            else
            {
                _S1498 = false;
            }
            if(_S1498)
            {
                _S1499 = b_8 == 1U;
            }
            else
            {
                _S1499 = false;
            }
            if(_S1499)
            {
                _S1500 = (_S1365.x) == (_S1365.y);
            }
            else
            {
                _S1500 = false;
            }
            BSDFMaterial _S1582 = _S1362.material;
            bool _S1583 = isTranslucent_0(&_S1582);
            if(_S1583)
            {
                _S1501 = _S1577;
            }
            else
            {
                _S1501 = false;
            }
            if(_S1501)
            {
                _S1502 = (dot_0(throughput_8, surface_12.geometry_n)) < 0.0f;
            }
            else
            {
                _S1502 = false;
            }
            if(nee_0)
            {
                _S1503 = !_S1496;
            }
            else
            {
                _S1503 = false;
            }
            if(_S1503)
            {
                _S1504 = !wrong_side_0;
            }
            else
            {
                _S1504 = false;
            }
            if(_S1504)
            {
                float _S1584 = (&lobe_5)->pdf;
                float3  _S1585 = (&ray_2)->origin;
                float3  _S1586 = _slang_select(_S1377, _S1187,_S1363.smooth_n);
                float3  _S1587 = (&ray_2)->origin;
                FKSurface _S1588 = surface_12;
                float3  _S1589 = - _S1363.smooth_n;
                float3  _S1590 = _slang_select(_S1502, _S1589,_S1363.smooth_n);
                NEEVertex _S1591 = NEEVertex_x24init_0(false, _S1584, _S1585, _S1586, _S1587 + make_float3 (_S1588.geometry_offset) * _S1590);
                nee_vertex_0 = _S1591;
            }
            else
            {
                if(_S1372)
                {
                    _S1505 = true;
                }
                else
                {
                    bool _S1592 = b_8 != 1U;
                    if(_S1592)
                    {
                        _S1505 = true;
                    }
                    else
                    {
                        _S1505 = (_S1365.x) != (_S1365.y);
                    }
                }
                if(_S1505)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1593 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1593)
            {
                if(_S1495)
                {
                    _S1505 = true;
                }
                else
                {
                    _S1505 = ((&lobe_5)->pdf * (&prev_0)->cos / ((&hit_4)->distance * (&hit_4)->distance) * threshold_0) <= 1.0f;
                }
            }
            else
            {
                _S1505 = false;
            }
            bool _S1594 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1594)
            {
                if(_S1495)
                {
                    _S1506 = true;
                }
                else
                {
                    _S1506 = (_S1362.material.roughness) >= 0.20000000298023224f;
                }
            }
            else
            {
                _S1506 = false;
            }
            if(_S1404)
            {
                bool _S1595 = !_S1505;
                if(_S1595)
                {
                    return _S1188;
                }
                bool _S1596 = _S1193 != 1U;
                if(_S1596)
                {
                    _S1507 = _S1193 != 2U;
                }
                else
                {
                    _S1507 = false;
                }
                if(_S1507)
                {
                    float _S1597 = (&lobe_5)->pdf;
                    float _S1598 = _slang_select(nee_0, _S1597,0.0f);
                    float _S1599 = escapeWeight_0(_S1598, _S1514);
                    if(_S1412)
                    {
                        passes_0 = _S1199;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1600 = _slang_select(passes_0, _S1599,1.0f);
                    return Shift_x24init_0(throughput_6 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_8->radiance * make_float3 (_S1600) / make_float3 (r_8->jac), density_4 * (&lobe_5)->pdf / r_8->jac);
                }
                float3  _S1601 = throughput_6 * make_float3 ((&lobe_5)->pdf);
                float _S1602 = density_4 * (&lobe_5)->pdf;
                throughput_9 = _S1601;
                density_6 = _S1602;
            }
            else
            {
                throughput_9 = throughput_6;
                density_6 = density_4;
            }
            uint _S1603 = (fcptLayers((hit_4)));
            bool _S1604 = _S1603 > 1U;
            if(_S1604)
            {
                _S1507 = (b_8 == 1U) != passes_0;
            }
            else
            {
                _S1507 = false;
            }
            if(viewed_1)
            {
                _S1508 = _S1507;
            }
            else
            {
                _S1508 = false;
            }
            if(_S1508)
            {
                return _S1188;
            }
            if(replay_1)
            {
                _S1509 = b_5 <= _S1203;
            }
            else
            {
                _S1509 = false;
            }
            if(_S1509)
            {
                _S1510 = _S1361;
            }
            else
            {
                _S1510 = false;
            }
            bool _S1605;
            if(_S1510)
            {
                _S1605 = _S1505;
            }
            else
            {
                _S1605 = false;
            }
            bool _S1606;
            if(_S1605)
            {
                _S1606 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1606 = !_S1506;
                }
                else
                {
                    _S1606 = false;
                }
            }
            if(_S1606)
            {
                return _S1188;
            }
            if(viewed_1)
            {
                float3  _S1607 = throughput_9 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1608 = (&lobe_5)->pdf;
                throughput_10 = _S1607;
                sky_pdf_2 = _S1608;
            }
            else
            {
                float3  _S1609 = throughput_9 * max_0((&lobe_5)->throughput, _S1187);
                throughput_10 = _S1609;
                sky_pdf_2 = density_6;
            }
            bool _S1610;
            if(_S1381)
            {
                _S1610 = !_S1395;
            }
            else
            {
                _S1610 = false;
            }
            bool _S1611;
            if(_S1610)
            {
                _S1611 = _S1361;
            }
            else
            {
                _S1611 = false;
            }
            bool _S1612;
            if(_S1611)
            {
                _S1612 = _S1505;
            }
            else
            {
                _S1612 = false;
            }
            if(_S1612)
            {
                chain_0 = here_0;
                uint _S1613 = insertBits_0((&chain_0)->path, b_8, 18U, 3U);
                uint _S1614 = _slang_select(nee_0, 1U,0U);
                uint _S1615 = insertBits_0(_S1613, _S1614, 21U, 1U);
                (&chain_0)->path = _S1615;
                float _S1616 = (&chain_0)->jac * (&lobe_5)->pdf;
                (&chain_0)->jac = _S1616;
                (&chain_0)->dir = throughput_8;
                chain_throughput_1 = throughput_10;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1617 = surface_12;
            Vertex _S1618 = Vertex_x24init_0(_S1506, b_8, (&lobe_5)->pdf, (F32_abs((dot_0(surface_12.geometry_n, throughput_8)))), is_inside_6);
            prev_0 = _S1618;
            float _S1619 = (&lobe_5)->pdf;
            bool _S1620 = b_8 == 1U;
            bool _S1621;
            if(_S1620)
            {
                _S1621 = (_S1365.x) == (_S1365.y);
            }
            else
            {
                _S1621 = false;
            }
            float sky_pdf_3 = _slang_select(_S1621, sky_pdf_0,_S1619);
            float _S1622 = _slang_select(_S1372, 0.0f,sky_pdf_3);
            float _S1623 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * (&lobe_5)->pdf))))), (3.14159274101257324f)));
            bool _S1624 = !_S1496;
            float _S1625 = _slang_select(_S1624, _S1623,0.0f);
            float _S1626 = spread_1 + _S1625;
            bool _S1627;
            if(refracted_4)
            {
                _S1627 = !_S1502;
            }
            else
            {
                _S1627 = false;
            }
            bool is_inside_7;
            if(_S1627)
            {
                bool _S1628 = !is_inside_6;
                is_inside_7 = _S1628;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            FKSurface _S1629 = surface_12;
            bool _S1630 = boundsVolume_0(&_S1629);
            bool _S1631;
            if(_S1630)
            {
                _S1631 = !_S1507;
            }
            else
            {
                _S1631 = false;
            }
            if(_S1631)
            {
                FKSurface faced_2 = surface_12;
                float3  _S1632 = - _S1617.geometry_n;
                float3  _S1633 = _slang_select(turned_1, _S1632,_S1617.geometry_n);
                (&faced_2)->geometry_n = _S1633;
                FKMedium _S1634 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1635 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1636 = faced_2;
                FKMedium _S1637 = _S1634;
                FKMedium _S1638 = _S1635;
                MediumSides _S1639 = mediumSides_0(&_S1636, &_S1637, filling_2, (&ray_2)->unit_direction, &_S1638);
                bool _S1640 = ((dot_0(throughput_8, _S1617.geometry_n)) > 0.0f) == ((dot_0(_S1617.geometry_n, (&faced_2)->geometry_n)) > 0.0f);
                float3  _S1641 = _slang_select(_S1640, _S1639.front.scatter,_S1639.behind.scatter);
                scatter_in_0 = _S1641;
                float3  _S1642 = _slang_select(_S1640, _S1639.front.extinction,_S1639.behind.extinction);
                extinction_in_0 = _S1642;
                float _S1643 = _slang_select(_S1640, _S1639.front.g,_S1639.behind.g);
                g_in_0 = _S1643;
                uint _S1644 = _S1639.fillings.x;
                uint _S1645 = _S1639.fillings.y;
                uint _S1646 = _slang_select(_S1640, _S1645,_S1644);
                bool _S1647 = (fcptVaryingUsed());
                uint _S1648 = _slang_select(_S1647, _S1646,4294967295U);
                filling_2 = _S1648;
            }
            (&ray_2)->unit_direction = throughput_8;
            bool _S1649 = !_S1507;
            if(_S1649)
            {
                FKSurface _S1650 = surface_12;
                float _S1651 = _slang_select(straight_0, 0.0f,_S1650.geometry_offset);
                float3  _S1652 = - _S1363.smooth_n;
                bool _S1653 = is_inside_7 != _S1502;
                float3  _S1654 = _slang_select(_S1653, _S1652,_S1363.smooth_n);
                float3  _S1655 = (&ray_2)->origin + make_float3 (_S1651) * _S1654;
                (&ray_2)->origin = _S1655;
            }
            throughput_9 = throughput_10;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1507;
            viewed_1 = _S1500;
            sky_pdf_2 = _S1622;
            spread_4 = _S1626;
            reconnection_0 = reconnection_1;
            is_inside_5 = is_inside_7;
        }
        else
        {
            (&prev_0)->rough = false;
            (&prev_0)->pdf = 0.0f;
            throughput_9 = throughput_6;
            density_6 = density_4;
            passes_0 = false;
            viewed_1 = viewed_0;
            sky_pdf_2 = 0.0f;
            spread_4 = spread_1;
            straight_0 = false;
            is_inside_5 = is_inside_6;
        }
        float density_7;
        if(_S1381)
        {
            if(_S1329)
            {
                float3  _S1656 = throughput_9 * emission_1;
                Reservoir candidate_8 = chain_0;
                uint _S1657 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1658 = _S1657 == 1U;
                if(_S1658)
                {
                    float3  _S1659 = safeDivide(_S1656, chain_throughput_0);
                    (&candidate_8)->radiance = _S1659;
                }
                Reservoir _S1660 = withEnd(candidate_8, 2U, b_5, _S1656);
                offer(sel_7, _S1660, _S1656 * make_float3 (scale_3) / make_float3 (density_6));
            }
            if(_S1329)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1661 = survivalProbability(throughput_9, density_6);
                density_7 = _S1661;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1662 = stream(_S1215, b_5 + 128U);
            Random _S1663 = pcg(_S1662);
            bool _S1664 = density_7 < (_S1663.value);
            if(_S1664)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1665 = (fcptMaxBounces());
                wrong_side_0 = b_5 >= _S1665;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1666 = density_6 * density_7;
            density_7 = _S1666;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1667 = layer_0 ^ 1U;
        uint _S1668 = _slang_select(passes_0, _S1667,0U);
        if(passes_0)
        {
            (&prev_0)->rough = false;
            (&hit_4)->distance = 0.0f;
            b_8 = b_5;
            viewed_0 = viewed_1;
            throughput_2 = throughput_9;
            density_2 = density_7;
            sky_pdf_0 = sky_pdf_2;
            spread_1 = spread_4;
            uint _S1669 = b_8 + 1U;
            b_5 = _S1669;
            layer_0 = _S1668;
            continue;
        }
        FKRay _S1670 = ray_2;
        float _S1671 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_1)
        {
            refracted_4 = _S1405;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S1192 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1672 = _slang_select(wrong_side_0, _S1671,4.294967296e+09f);
        bool _S1673 = !_S1372;
        if(straight_0)
        {
            _S1450 = true;
        }
        else
        {
            _S1450 = _S1372;
        }
        FKHit _S1674;
        if(_S1450)
        {
            _S1674 = hit_4;
        }
        else
        {
            _S1674 = _S1422;
        }
        FKHit _S1675 = (fcptTraverseInstanceBVH((_S1670), (_S1336), (_S1672), (_S1673), (_S1674), (viewed_1)));
        hit_4 = _S1675;
        if(replay_1)
        {
            _S1451 = _S1405;
        }
        else
        {
            _S1451 = false;
        }
        if(_S1451)
        {
            _S1495 = _S1192 == 1U;
        }
        else
        {
            _S1495 = false;
        }
        if(_S1495)
        {
            _S1496 = ((&hit_4)->instance_index) == (_S1204.instance_index);
        }
        else
        {
            _S1496 = false;
        }
        if(_S1496)
        {
            _S1497 = ((&hit_4)->triangle_index) == (_S1204.triangle_index);
        }
        else
        {
            _S1497 = false;
        }
        if(_S1497)
        {
            (&hit_4)->uv = _S1204.uv;
            float _S1676 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S1676;
        }
        if(replay_1)
        {
            _S1498 = _S1405;
        }
        else
        {
            _S1498 = false;
        }
        if(_S1498)
        {
            _S1499 = _S1192 == 3U;
        }
        else
        {
            _S1499 = false;
        }
        if(_S1499)
        {
            _S1500 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1500 = false;
        }
        if(_S1500)
        {
            return _S1188;
        }
        Reservoir _S1677 = chain_0;
        uint _S1678 = filling_2;
        for(;;)
        {
            bool _S1679 = (fcptVaryingUsed());
            if(_S1679)
            {
                _S1501 = _S1678 != 4294967295U;
            }
            else
            {
                _S1501 = false;
            }
            float _S1680;
            if(_S1501)
            {
                float _S1681 = (fcptMajorant((_S1678)));
                _S1680 = _S1681;
            }
            else
            {
                _S1680 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_1)
            {
                _S1502 = _S1405;
            }
            else
            {
                _S1502 = false;
            }
            if(_S1502)
            {
                _S1503 = _S1192 == 1U;
            }
            else
            {
                _S1503 = false;
            }
            if(_S1503)
            {
                _S1504 = _S1680 > 0.0f;
            }
            else
            {
                _S1504 = false;
            }
            if(_S1504)
            {
                ended_0 = _S1188;
                sky_pdf_1 = sky_pdf_2;
                spread_2 = spread_4;
                width_4 = width_3;
                density_3 = density_7;
                throughput_10 = throughput_9;
                b_8 = b_5;
                _S1505 = true;
                break;
            }
            bool _S1682 = (&prev_0)->rough;
            if(_S1682)
            {
                _S1505 = !(_S1680 > 0.0f);
            }
            else
            {
                _S1505 = false;
            }
            (&prev_0)->rough = _S1505;
            uint _S1683 = b_5 + 320U;
            bool _S1684 = b_5 == 4294967295U;
            uint _S1685 = _slang_select(_S1684, 384U,_S1683);
            uint _S1686 = stream(_S1215, _S1685);
            uint tracking_1 = _S1686;
            weight_1 = throughput_3;
            glowed_0 = _S1187;
            b_8 = b_5;
            throughput_10 = throughput_9;
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
                    _S1186 = int(2);
                    break;
                }
                uint _S1687 = b_8 + 320U;
                bool _S1688 = b_8 == 4294967295U;
                uint _S1689 = _slang_select(_S1688, 384U,_S1687);
                uint _S1690 = stream(_S1215, _S1689);
                Random _S1691 = pcg(_S1690);
                float _S1692 = - (F32_log((1.0f - _S1691.value))) / _S1680;
                if(_S1501)
                {
                    float3  _S1693 = (&ray_2)->origin;
                    float3  _S1694 = (&ray_2)->unit_direction;
                    float _S1695 = (&hit_4)->distance;
                    uint _S1696 = _slang_select(_S1688, 0U,b_8);
                    uint _S1697 = (&prev_0)->lobe;
                    uint _S1698 = _slang_select(_S1688, 3U,_S1697);
                    float _S1699 = (fcptTrackMedium((_S1678), (_S1693), (_S1694), (_S1695), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1696), (_S1698), (_S1688)));
                    spread_3 = _S1699;
                }
                else
                {
                    spread_3 = _S1692;
                }
                bool _S1700 = !(spread_3 < ((&hit_4)->distance));
                if(_S1700)
                {
                    _S1186 = int(2);
                    break;
                }
                if(_S1501)
                {
                    _S1506 = _S1381;
                }
                else
                {
                    _S1506 = false;
                }
                if(_S1506)
                {
                    float3  _S1701 = throughput_10 * glowed_0 / make_float3 (density_3);
                    float3  _S1702 = sel_7->glow + _S1701;
                    sel_7->glow = _S1702;
                }
                else
                {
                }
                glowed_0 = _S1187;
                uint b_9 = b_8 + 1U;
                float3  _S1703 = (&ray_2)->origin + make_float3 (spread_3) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1703;
                float3  _S1704 = flightWeight_0(scatter_in_0, extinction_in_0, _S1680, spread_3, true);
                float3  _S1705 = weight_1;
                float3  _S1706 = _slang_select(_S1501, _S1705,_S1704);
                float3  throughput_11 = throughput_10 * _S1706;
                uint _S1707 = stream(_S1215, b_9 + 320U);
                tracking_1 = _S1707;
                weight_1 = throughput_3;
                float width_7 = width_4 + spread_2 * spread_3;
                float _S1708 = spread_2 + 3.14159274101257324f;
                if(_S1381)
                {
                    _S1507 = true;
                }
                else
                {
                    bool _S1709 = b_9 == _S1203;
                    if(_S1709)
                    {
                        _S1507 = !_S1501;
                    }
                    else
                    {
                        _S1507 = false;
                    }
                }
                TreeSample light_4;
                if(_S1507)
                {
                    float3  _S1710 = (&ray_2)->origin;
                    float3  _S1711 = (&ray_2)->unit_direction;
                    float3  _S1712 = (&ray_2)->unit_direction;
                    uint _S1713 = stream(_S1215, b_9 + 64U);
                    float3  _S1714 = extinction_in_0;
                    float3  _S1715 = extinction_in_0;
                    uint2  _S1716 = make_uint2 (_S1678);
                    float3  _S1717 = (&ray_2)->unit_direction;
                    uint _S1718 = arrivalLobe_0(b_9, (&prev_0)->lobe);
                    FKHit _S1719 = _S1422;
                    ShadowContext _S1720 = ShadowContext_x24init_0(_S1714, _S1715, _S1716, _S1717, b_9, _S1718, false, spread_3, width_7, &_S1719, false);
                    ShadowContext _S1721 = _S1720;
                    TreeSample _S1722 = sampleLightTree_0(_S1710, _S1711, _S1712, 0.0f, true, _S1713, &_S1721);
                    light_4 = _S1722;
                }
                else
                {
                    light_4 = _S1419;
                }
                float _S1723 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1724 = (fcptMaxBounces());
                bool _S1725 = b_9 < _S1724;
                if(_S1725)
                {
                    _S1508 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1508 = false;
                }
                float _S1726 = _slang_select(_S1508, _S1723,0.0f);
                float3  _S1727 = throughput_11 * light_4.radiance;
                float _S1728 = powerHeuristic(light_4.density, _S1726);
                float3  _S1729 = _S1727 * make_float3 (_S1723 * _S1728);
                float3  _S1730 = _slang_select(_S1507, _S1729,_S1187);
                if(replay_1)
                {
                    _S1509 = b_9 == _S1203;
                }
                else
                {
                    _S1509 = false;
                }
                if(_S1509)
                {
                    bool _S1731 = _S1192 == 2U;
                    if(_S1731)
                    {
                        float _S1732 = rgb_to_greyscale(_S1730);
                        _S1510 = _S1732 > 0.0f;
                    }
                    else
                    {
                        _S1510 = false;
                    }
                    if(_S1510)
                    {
                        Shift _S1733 = Shift_x24init_0(_S1730, 1.0f);
                        _S1186 = int(1);
                        ended_0 = _S1733;
                        spread_3 = _S1708;
                        width_5 = width_7;
                        throughput_8 = throughput_11;
                        b_6 = b_9;
                        break;
                    }
                    _S1186 = int(1);
                    ended_0 = _S1188;
                    spread_3 = _S1708;
                    width_5 = width_7;
                    throughput_8 = throughput_11;
                    b_6 = b_9;
                    break;
                }
                if(_S1381)
                {
                    Reservoir candidate_9 = _S1677;
                    uint _S1734 = extractBits_0(_S1677.path, 10U, 2U);
                    bool _S1735 = _S1734 == 1U;
                    if(_S1735)
                    {
                        float3  _S1736 = safeDivide(_S1730, chain_throughput_0);
                        (&candidate_9)->radiance = _S1736;
                    }
                    else
                    {
                        uint _S1737 = insertBits_0(0U, b_9 + 1U, 5U, 5U);
                        uint _S1738 = insertBits_0(_S1737, 2U, 10U, 2U);
                        (&candidate_9)->path = _S1738;
                    }
                    Reservoir _S1739 = withEnd(candidate_9, 0U, b_9, _S1730);
                    offer(sel_7, _S1739, _S1730 * make_float3 (scale_3) / make_float3 (density_3));
                    float _S1740 = survivalProbability(throughput_11, density_3);
                    uint _S1741 = stream(_S1215, b_9 + 128U);
                    Random _S1742 = pcg(_S1741);
                    bool _S1743 = _S1740 < (_S1742.value);
                    if(_S1743)
                    {
                        _S1510 = true;
                    }
                    else
                    {
                        uint _S1744 = (fcptMaxBounces());
                        _S1510 = b_9 >= _S1744;
                    }
                    if(_S1510)
                    {
                        _S1186 = int(1);
                        ended_0 = _S1188;
                        spread_3 = _S1708;
                        width_5 = width_7;
                        throughput_8 = throughput_11;
                        b_6 = b_9;
                        break;
                    }
                    float _S1745 = density_3 * _S1740;
                    density_3 = _S1745;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1746 = stream(_S1215, b_9);
                float3  _S1747 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1746, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1747;
                NEEVertex _S1748 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1187, (&ray_2)->origin);
                nee_vertex_0 = _S1748;
                Vertex _S1749 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_5);
                prev_0 = _S1749;
                float _S1750 = (&prev_0)->pdf;
                FKRay _S1751 = ray_2;
                FKHit _S1752 = (fcptTraverseInstanceBVH((_S1751), (true), (4.294967296e+09f), (false), (_S1422), (false)));
                hit_4 = _S1752;
                b_8 = b_9;
                throughput_10 = throughput_11;
                spread_2 = _S1708;
                width_4 = width_7;
                sky_pdf_1 = _S1750;
            }
            if(_S1186 != int(2))
            {
                spread_2 = spread_3;
                width_4 = width_5;
                throughput_10 = throughput_8;
                b_8 = b_6;
                _S1505 = true;
                break;
            }
            ended_0 = _S1188;
            _S1505 = false;
            break;
        }
        if(_S1505)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1506 = b_8 == b_5;
        }
        else
        {
            _S1506 = false;
        }
        bool _S1753 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S1753)
        {
            bool _S1754 = !(&nee_vertex_0)->none;
            float _S1755 = _slang_select(_S1754, sky_pdf_1,0.0f);
            float _S1756 = escapeWeight_0(_S1755, (&ray_2)->unit_direction);
            float3  _S1757 = environment_0((&ray_2)->unit_direction, b_8, (&prev_0)->lobe);
            float3  _S1758 = throughput_10 * _S1757;
            if(replay_1)
            {
                bool _S1759 = b_8 == _S1203;
                if(_S1759)
                {
                    passes_0 = _S1192 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1758 * make_float3 (_S1756) / make_float3 (r_8->jac), density_3 / r_8->jac);
                }
                if(_S1202)
                {
                    passes_0 = _S1199;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_8 == _S1190;
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
                    return Shift_x24init_0(_S1758 * make_float3 (_S1756), 1.0f);
                }
                return _S1188;
            }
            Reservoir candidate_10 = chain_0;
            uint _S1760 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1761 = _S1760 == 1U;
            if(_S1761)
            {
                uint _S1762 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1763 = _S1762 == b_8;
                float _S1764 = _slang_select(_S1763, 1.0f,_S1756);
                float3  _S1765 = safeDivide(_S1758 * make_float3 (_S1764), chain_throughput_0);
                (&candidate_10)->radiance = _S1765;
            }
            else
            {
                bool _S1766 = (&prev_0)->rough;
                if(_S1766)
                {
                    uint _S1767 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                    uint _S1768 = insertBits_0(_S1767, 3U, 10U, 2U);
                    uint _S1769 = insertBits_0(_S1768, (&prev_0)->lobe, 15U, 3U);
                    bool _S1770 = (&prev_0)->inside;
                    uint _S1771 = _slang_select(_S1770, 1U,0U);
                    uint _S1772 = insertBits_0(_S1769, _S1771, 22U, 1U);
                    (&candidate_10)->path = _S1772;
                    (&candidate_10)->jac = (&prev_0)->pdf;
                    (&candidate_10)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1773 = _S1758 * make_float3 (_S1756);
            Reservoir _S1774 = withEnd(candidate_10, 3U, b_8, _S1773);
            offer(sel_7, _S1774, _S1773 * make_float3 (scale_3) / make_float3 (density_3));
            break;
        }
        float3  _S1775 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1775;
        bool _S1776 = (fcptVaryingUsed());
        if(_S1776)
        {
            _S1507 = filling_2 != 4294967295U;
        }
        else
        {
            _S1507 = false;
        }
        if(_S1507)
        {
            if(_S1381)
            {
                float3  _S1777 = throughput_10 * glowed_0 / make_float3 (density_3);
                float3  _S1778 = sel_7->glow + _S1777;
                sel_7->glow = _S1778;
            }
            float3  _S1779 = throughput_10 * weight_1;
            throughput_8 = _S1779;
        }
        else
        {
            float3  _S1780 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S1781 = throughput_10 * _S1780;
            throughput_8 = _S1781;
        }
        float _S1782 = width_4 + spread_2 * (&hit_4)->distance;
        viewed_0 = _S1506;
        width_3 = _S1782;
        throughput_2 = throughput_8;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_1 = spread_2;
        uint _S1669 = b_8 + 1U;
        b_5 = _S1669;
        layer_0 = _S1668;
    }
    return _S1188;
}

__device__ static const FixedArray<float, 4>  HAIR_TILTS_0 = { {
    -2.0f, 1.0f, 4.0f, 0.0f
} };
__device__ static const FixedArray<float, 4>  HAIR_WIDTHS_0 = { {
    1.0f, 0.5f, 2.0f, 2.0f
} };
static __device__ float3  clamp_2(float3  x_25, float3  minBound_2, float3  maxBound_2)
{
    return min_1(max_0(x_25, minBound_2), maxBound_2);
}

static __device__ float3  tan_0(float3  x_26)
{
    float3  result_14;
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
        *_slang_vector_get_element_ptr(&result_14, i_26) = (F32_tan((_slang_vector_get_element(x_26, i_26))));
        i_26 = i_26 + int(1);
    }
    return result_14;
}

static __device__ float3  acos_0(float3  x_27)
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
        *_slang_vector_get_element_ptr(&result_15, i_27) = (F32_acos((_slang_vector_get_element(x_27, i_27))));
        i_27 = i_27 + int(1);
    }
    return result_15;
}

static __device__ float3  abs_0(float3  x_28)
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
        *_slang_vector_get_element_ptr(&result_16, i_28) = (F32_abs((_slang_vector_get_element(x_28, i_28))));
        i_28 = i_28 + int(1);
    }
    return result_16;
}

__device__ Random normal_distribution(uint state_3)
{
    Random _S1783 = pcg(state_3);
    Random _S1784 = pcg(_S1783.state);
    float _S1785 = 6.28318548202514648f * _S1783.value;
    float _S1786 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S1784.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1784.state, _S1786 * (F32_cos((_S1785))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_4, float3  value_2)
{
    RandomSphere _S1787;
    (&_S1787)->state = state_4;
    (&_S1787)->value = value_2;
    return _S1787;
}

__device__ RandomSphere random_sphere(uint state_5)
{
    Random _S1788 = normal_distribution(state_5);
    Random _S1789 = normal_distribution(_S1788.state);
    Random _S1790 = normal_distribution(_S1789.state);
    float3  _S1791 = make_float3 (_S1788.value, _S1789.value, _S1790.value);
    float3  _S1792 = ((((_S1791)) * make_float3(rnorm3df(((_S1791)).x, ((_S1791)).y, ((_S1791)).z))));
    return RandomSphere_x24init_0(_S1790.state, _S1792);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_12)
{
    float3  _S1793 = p1_0 - p0_0;
    float3  _S1794 = p2_0 - p0_0;
    float2  _S1795 = uv1_0 - uv0_0;
    float2  _S1796 = uv2_0 - uv0_0;
    float _S1797 = _S1795.x;
    float _S1798 = _S1796.y;
    float _S1799 = _S1795.y;
    float _S1800 = _S1796.x;
    float _S1801 = _S1797 * _S1798 - _S1799 * _S1800;
    float _S1802 = 1.0f / _S1801;
    float3  t_22 = (_S1793 * make_float3 (_S1798) - _S1794 * make_float3 (_S1799)) * make_float3 (_S1802);
    float3  _S1803 = (_S1794 * make_float3 (_S1797) - _S1793 * make_float3 (_S1800)) * make_float3 (_S1802);
    float3  _S1804 = t_22 - n_12 * make_float3 (dot_0(n_12, t_22));
    float3  _S1805 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_12);
    bool _S1806 = (dot_0(_S1804, _S1804)) > 0.0f;
    float3  _S1807 = _slang_select(_S1806, _S1804,_S1805);
    float3  _S1808 = ((((_S1807)) * make_float3(rnorm3df(((_S1807)).x, ((_S1807)).y, ((_S1807)).z))));
    bool _S1809 = (dot_0(cross_0(n_12, _S1808), _S1803)) > 0.0f;
    float3  t_23;
    if(_S1809)
    {
        float3  _S1810 = negate_0(_S1808);
        t_23 = _S1810;
    }
    else
    {
        t_23 = _S1808;
    }
    float3  _S1811 = cross_0(n_12, t_23);
    return makeMatrix<float, 3, 3> (t_23, _S1811, n_12);
}

__device__ float3  tangentToWorldNormalMap(float3  v_5, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_5, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_4, float3  uvw_0, float3  position_0)
{
    float3  _S1812 = t1_0 - t0_0;
    float3  _S1813 = t2_2 - t0_0;
    float3  _S1814 = t2_2 - t1_0;
    float _S1815 = (F32_min((length_0(_S1812)), ((F32_min((length_0(_S1813)), (length_0(_S1814)))))));
    float3  _S1816 = make_float3 (distance_1(position_0, t0_0), distance_1(position_0, t1_0), distance_1(position_0, t2_2));
    float3  _S1817 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1818 = dot_0(geometry_n_4, _S1817);
    float3  _S1819 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1820 = dot_0(geometry_n_4, _S1819);
    float3  _S1821 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1822 = acos_0(abs_0(make_float3 (_S1818, _S1820, dot_0(geometry_n_4, _S1821))));
    float3  _S1823 = clamp_2(tan_0(_S1822), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S1816 * _S1823, uvw_0), 0.0f, _S1815 * 0.125f);
}

__device__ float3  straightThrough(BSDFMaterial material_23)
{
    return make_float3 (material_23.transmission * (1.0f - material_23.metallic)) * material_23.albedo;
}

__device__ float hairRow(float3  in_dir_11, float3  t_24, float3  out_dir_3, uint p_14, float w_2, float alpha_20, uint nt_0)
{
    uint _S1824 = p_14 % 4U;
    float _S1825 = w_2 * HAIR_WIDTHS_0[_S1824];
    float _S1826 = (F32_asin((clamp_1(dot_0(out_dir_3, t_24), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_11, t_24), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1824] * alpha_20;
    return ((F32_asinh((_S1826 / _S1825))) / (F32_asinh((3.14159274101257324f / _S1825))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_12, float3  t_25, float3  out_dir_4, uint np_0)
{
    float3  _S1827 = worldToTangent(out_dir_4, t_25);
    float3  _S1828 = worldToTangent(in_dir_12, t_25);
    return (F32_frac((((F32_atan2((_S1827.z), (_S1827.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1828.z), (1.17549435082228751e-38f - _S1828.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_13, float3  t_26, uint p_15, float row_0, float column_0, float w_3, float alpha_21, uint nt_1, uint np_1)
{
    float3  _S1829 = worldToTangent(in_dir_13, t_26);
    uint _S1830 = p_15 % 4U;
    float _S1831 = w_3 * HAIR_WIDTHS_0[_S1830];
    float _S1832 = (F32_asin((clamp_1(dot_0(in_dir_13, t_26), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1830] * alpha_21 + _S1831 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1831))))));
    float _S1833 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1829.z), (1.17549435082228751e-38f - _S1829.x)));
    float _S1834 = (F32_cos((_S1832)));
    float3  _S1835 = tangentToWorld(make_float3 (_S1834 * (F32_cos((_S1833))), (F32_sin((_S1832))), _S1834 * (F32_sin((_S1833)))), t_26);
    return _S1835;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_13, BSDFMaterial material_24, float coverage_1)
{
    float3  _S1836;
    if((material_24.ior) == 1.0f)
    {
        float3  _S1837 = straightThrough(material_24);
        _S1836 = _S1837;
    }
    else
    {
        _S1836 = make_float3 (0.0f);
    }
    return _S1836 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_8, Reservoir r_9, bool replay_2, float scale_4, Selection * sel_8)
{
    Domain _S1838 = dom_8;
    Reservoir _S1839 = r_9;
    Shift _S1840 = walk_0(&_S1838, &_S1839, replay_2, scale_4, sel_8);
    return _S1840;
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
