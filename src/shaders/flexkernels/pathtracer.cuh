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
    Weights _S354;
    (&_S354)->v_dot_h = v_dot_h_0;
    (&_S354)->refracted = refracted_1;
    (&_S354)->F = F_0;
    (&_S354)->reflect_weight = reflect_weight_0;
    (&_S354)->diffuse_weight = diffuse_weight_0;
    (&_S354)->refract_weight = refract_weight_0;
    (&_S354)->p_diffuse = p_diffuse_0;
    (&_S354)->p_reflect = p_reflect_0;
    (&_S354)->p_refract = p_refract_0;
    (&_S354)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S354)->p_toon = p_toon_0;
    (&_S354)->sheen = sheen_0;
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

__device__ float3  worldToTangent(float3  v_1, float3  n_3)
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
    return make_float3 (dot_0(v_1, _S377), dot_0(v_1, n_3), dot_0(v_1, _S378));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_2, float3  n_i_1, float alpha_1, AnisotropicFrame frame_0, uint * random_state_2)
{
    Random _S379 = draw(*random_state_2, 0U);
    Random _S380 = draw(*random_state_2, 2147483648U);
    *random_state_2 = _S380.state;
    float _S381 = frame_0.alphas.x;
    bool _S382 = _S381 > 0.0f;
    if(_S382)
    {
        float3  _S383 = anisotropicLocal(v_2, frame_0.tangent, n_i_1);
        float _S384 = frame_0.alphas.y;
        float3  _S385 = make_float3 (_S381 * _S383.x, _S384 * _S383.y, _S383.z);
        float3  _S386 = ((((_S385)) * make_float3(rnorm3df(((_S385)).x, ((_S385)).y, ((_S385)).z))));
        float3  _S387 = sampleGGXVNDF(_S386, 1.0f, _S379.value, _S380.value);
        float3  _S388 = make_float3 (_S381 * _S387.x, _S384 * _S387.y, _S387.z);
        float3  _S389 = ((((_S388)) * make_float3(rnorm3df(((_S388)).x, ((_S388)).y, ((_S388)).z))));
        return make_float3 (_S389.x) * frame_0.tangent + make_float3 (_S389.y) * cross_0(n_i_1, frame_0.tangent) + make_float3 (_S389.z) * n_i_1;
    }
    float3  _S390 = worldToTangent(v_2, n_i_1);
    float3  _S391 = sampleGGXVNDF(float3 {_S390.x, _S390.z, _S390.y}, alpha_1, _S379.value, _S380.value);
    float3  _S392 = float3 {_S391.x, _S391.z, _S391.y};
    float3  _S393 = tangentToWorld(_S392, n_i_1);
    return _S393;
}

__device__ __forceinline__ float3  sampledHalf(float3  v_3, float3  n_i_2, float alpha_2, AnisotropicFrame frame_1, uint random_state_3)
{
    uint state_3 = random_state_3;
    float3  _S394 = sampleHalfVector(v_3, n_i_2, alpha_2, frame_1, &state_3);
    return _S394;
}

__device__ __forceinline__ float3  refractedHalf(float3  in_dir_0, float3  out_dir_0, float3  n_4, float eta_i_0, float eta_o_0)
{
    float3  _S395 = negate_0(in_dir_0);
    float3  _S396 = negate_0(make_float3 (eta_i_0) * _S395 + make_float3 (eta_o_0) * out_dir_0);
    float3  _S397 = ((((_S396)) * make_float3(rnorm3df(((_S396)).x, ((_S396)).y, ((_S396)).z))));
    float _S398 = sign_0(dot_0(n_4, _S395));
    float _S399 = sign_0(dot_0(_S396, n_4 * make_float3 (_S398)));
    return _S397 * make_float3 (_S399);
}

__device__ __forceinline__ float3  reflectedHalf(float3  in_dir_1, float3  out_dir_1)
{
    float3  _S400 = negate_0(in_dir_1);
    float3  _S401 = _S400 + out_dir_1;
    float3  _S402 = ((((_S401)) * make_float3(rnorm3df(((_S401)).x, ((_S401)).y, ((_S401)).z))));
    return _S402;
}

static __device__ float3  refract_0(float3  i_5, float3  n_5, float eta_0)
{
    float _S403 = dot_0(n_5, i_5);
    float _S404 = 1.0f - eta_0 * eta_0 * (1.0f - _S403 * _S403);
    if(_S404 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_5 - make_float3 (eta_0 * _S403 + (F32_sqrt((_S404)))) * n_5;
}

__device__ float fresnel(float cos_theta_0, float eta_i_1, float eta_o_1)
{
    float _S405 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S406 = eta_i_1 / eta_o_1 * _S405;
    bool _S407 = _S406 < 1.0f;
    float kr_0;
    if(_S407)
    {
        float _S408 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S406 * _S406))))));
        float _S409 = eta_o_1 * cos_theta_0;
        float _S410 = eta_i_1 * _S408;
        float _S411 = (_S409 - _S410) / (_S409 + _S410);
        float _S412 = eta_i_1 * cos_theta_0;
        float _S413 = eta_o_1 * _S408;
        float _S414 = (_S412 - _S413) / (_S412 + _S413);
        float _S415 = (_S411 * _S411 + _S414 * _S414) / 2.0f;
        kr_0 = _S415;
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
    float _S416 = dot_0(ggx_n_0, v_4);
    float _S417 = eta_i_2 / eta_o_2;
    float3  _S418 = refract_0(in_dir_2, ggx_n_0, _S417);
    float3  _S419 = ((((_S418)) * make_float3(rnorm3df(((_S418)).x, ((_S418)).y, ((_S418)).z))));
    float _S420 = (F32_min(((F32_sqrt((material_1.specular_level))) * (F32_abs((eta_i_2 - eta_o_2))) / (eta_i_2 + eta_o_2)), (0.9999847412109375f)));
    float _S421 = _S420 * _S420;
    float _S422 = (1.0f + _S420) / (1.0f - _S420);
    float _S423 = (F32_abs((_S416)));
    bool _S424 = eta_i_2 > eta_o_2;
    float sheen_component_0;
    if(_S424)
    {
        sheen_component_0 = _S422;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    float toon_component_0;
    if(_S424)
    {
        toon_component_0 = 1.0f;
    }
    else
    {
        toon_component_0 = _S422;
    }
    float _S425 = fresnel(_S423, sheen_component_0, toon_component_0);
    bool _S426 = (eta_i_2 * eta_i_2 * (1.0f - _S416 * _S416)) >= (eta_o_2 * eta_o_2);
    float3  _S427;
    if(_S426)
    {
        _S427 = make_float3 (1.0f);
    }
    else
    {
        float3  _S428 = material_1.specular_tint * make_float3 (_S421);
        _S427 = _S428 + (make_float3 (1.0f) - _S428) * make_float3 (_S425 - _S421) / make_float3 (1.0f - _S421);
    }
    float3  _S429 = make_float3 (1.0f);
    float3  _S430 = make_float3 (0.0f);
    float _S431 = rgb_to_greyscale(material_1.sheen);
    bool _S432 = _S431 > 0.0f;
    float3  sheen_1;
    float3  scale_1;
    if(_S432)
    {
        float _S433 = clamp_1((F32_sqrt(((F32_max((dot_0(n_i_3, v_4)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S434 = (U32_min((uint(_S433)), (22U)));
        float least_0 = (F32_sqrt((0.05000000074505806f)));
        float _S435 = (F32_sqrt((0.10000000149011612f)));
        bool _S436 = (material_1.velvet) > 0.0f;
        float _S437 = _slang_select(_S436, _S435,least_0);
        float _S438 = (clamp_1((F32_sqrt(((F32_max((material_1.sheen_roughness), (0.0f)))))), _S437, 1.0f) - _S437) / (1.0f - _S437) * 23.0f;
        uint _S439 = (U32_min((uint(_S438)), (22U)));
        uint _S440 = _S434 * 24U + _S439;
        float _S441 = _S433 - float(_S434);
        float _S442 = _S438 - float(_S439);
        uint _S443 = _S440 + 24U;
        float a_5 = SHEEN_ALBEDO_0[_S440] + (SHEEN_ALBEDO_0[_S443] - SHEEN_ALBEDO_0[_S440]) * _S441;
        uint _S444 = _S440 + 1U;
        uint _S445 = _S443 + 1U;
        float b_1 = SHEEN_ALBEDO_0[_S444] + (SHEEN_ALBEDO_0[_S445] - SHEEN_ALBEDO_0[_S444]) * _S441;
        float _S446 = (F32_exp((a_5 + (b_1 - a_5) * _S442)));
        if(_S436)
        {
            float a_6 = VELVET_ALBEDO_0[_S440] + (VELVET_ALBEDO_0[_S443] - VELVET_ALBEDO_0[_S440]) * _S441;
            float b_2 = VELVET_ALBEDO_0[_S444] + (VELVET_ALBEDO_0[_S445] - VELVET_ALBEDO_0[_S444]) * _S441;
            float _S447 = a_6 + (b_2 - a_6) * _S442;
            sheen_component_0 = _S447;
        }
        else
        {
            sheen_component_0 = _S446;
        }
        float _S448 = (F32_min((sheen_component_0), (1.0f)));
        float3  _S449 = make_float3 (1.0f) - material_1.sheen * make_float3 (_S448);
        float _S450 = rgb_to_greyscale(material_1.sheen);
        float _S451 = _S450 * _S448;
        float3  _S452 = material_1.sheen / make_float3 ((F32_max((sheen_component_0), (1.0f))));
        sheen_component_0 = _S451;
        sheen_1 = _S452;
        scale_1 = _S449;
    }
    else
    {
        sheen_component_0 = 0.0f;
        sheen_1 = _S430;
        scale_1 = _S429;
    }
    float _S453 = (F32_abs((material_1.toon.x)));
    bool _S454 = _S453 > 0.0f;
    if(_S454)
    {
        float _S455 = (F32_min((_S453), (1.0f)));
        float3  scale_2 = scale_1 * make_float3 (1.0f - _S455);
        float _S456 = rgb_to_greyscale(material_1.albedo);
        float _S457 = _S455 * _S456;
        toon_component_0 = _S457;
        scale_1 = scale_2;
    }
    else
    {
        toon_component_0 = 0.0f;
    }
    bool _S458 = (material_1.metallic) > 0.0f;
    float3  rebounce_0;
    if(_S458)
    {
        float _S459 = frame_2.alphas.x;
        float _S460 = (F32_sqrt(((F32_min((_S459), (frame_2.alphas.y))))));
        bool _S461 = _S459 > 0.0f;
        float _S462 = _slang_select(_S461, _S460,material_1.roughness);
        float _S463 = _S462 * _S462;
        float _S464 = (F32_pow((_S463), (1.81585001945495605f))) * (2.15371990203857422f - 0.73285001516342163f * _S463) / (1.0f + 1.28094995021820068f * _S463);
        bool _S465 = _S463 > 0.0f;
        float _S466 = _slang_select(_S465, _S464,0.0f);
        float _S467 = clamp_1(dot_0(n_i_3, v_4), 0.0f, 1.0f);
        float _S468 = _S463 * _S462;
        float _S469 = (F32_min((1.00064504146575928f - _S462 * (0.00375499995425344f + _S467 * (-0.04133399948477745f + _S467 * (-0.90938502550125122f + _S467 * 0.35275399684906006f))) - _S463 * (0.27602800726890564f + _S467 * (1.27023398876190186f + _S467 * 0.04740000143647194f)) - _S468 * (0.31452900171279907f - _S467 * 0.34830701351165771f) + _S468 * _S462 * 0.27229699492454529f), (1.0f)));
        float3  _S470 = min_1(make_float3 (1.0f) / (make_float3 (1.0f) - material_1.albedo * make_float3 (_S466)), make_float3 (1.0f / (F32_max((_S469), (0.0000152587890625f)))));
        rebounce_0 = _S470;
    }
    else
    {
        rebounce_0 = _S429;
    }
    float3  _S471 = mix_0(_S427, material_1.albedo * rebounce_0, material_1.metallic);
    float3  F_1 = _S471 * scale_1;
    float _S472 = rgb_to_greyscale(F_1);
    float _S473 = 1.0f - material_1.metallic;
    float3  _S474 = make_float3 (1.0f) - _S427;
    float3  _S475 = make_float3 ((1.0f - material_1.transmission) * _S473) * _S474 * scale_1;
    float3  _S476 = make_float3 (material_1.transmission * _S473) * _S474 * scale_1;
    float _S477 = (F32_max((_S472), (0.0f)));
    float _S478 = rgb_to_greyscale(_S475);
    float _S479 = (F32_max((_S478), (0.0f)));
    float _S480 = rgb_to_greyscale(_S476);
    float _S481 = sign_0(length_0(_S419));
    float _S482 = (F32_max((_S480 * _S481), (0.0f)));
    float _S483 = _S477 + _S479 + _S482 + toon_component_0;
    float _S484 = (F32_min((sheen_component_0), (1.0f)));
    bool _S485 = sheen_component_0 > 0.0f;
    bool _S486;
    if(_S485)
    {
        _S486 = !(_S483 > 0.0f);
    }
    else
    {
        _S486 = false;
    }
    float _S487 = _slang_select(_S486, 1.0f,_S484);
    float _S488 = (1.0f - _S487) / (F32_max((_S483), (0.0000152587890625f)));
    float _S489 = _S479 * _S488;
    float _S490 = _S477 * _S488;
    float _S491 = _S482 * _S488;
    return Weights_x24init_0(_S416, _S419, F_1, 1.0f, _S475, _S476, _S489, _S490, _S491, _S487, toon_component_0 * _S488, sheen_1);
}

__device__ float translucentShare(BSDFMaterial material_2)
{
    float _S492 = rgb_to_greyscale(material_2.translucent);
    float _S493 = rgb_to_greyscale(material_2.albedo);
    float _S494 = _S492 / (_S493 + _S492);
    bool _S495 = _S492 > 0.0f;
    float _S496 = _slang_select(_S495, _S494,0.0f);
    return _S496;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float n_i_dot_v_0, BSDFMaterial material_3, Weights w_1)
{
    float _S497 = translucentShare(material_3);
    float _S498 = w_1.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S499 = w_1.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S500 = 1.0f - _S497;
    bool _S501 = n_i_dot_l_0 < 0.0f;
    float _S502 = _slang_select(_S501, _S497,_S500);
    float _S503 = _S499 * _S502;
    bool _S504 = _S497 > 0.0f;
    float _S505 = _slang_select(_S504, _S503,_S498);
    bool _S506 = n_i_dot_v_0 > 0.0f;
    float _S507 = _slang_select(_S506, _S505,0.0f);
    return _S507;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_4, BSDFMaterial material_4, Weights w_2)
{
    float _S508 = translucentShare(material_4);
    bool _S509 = (dot_0(n_i_4, l_0)) < 0.0f;
    float3  _S510 = _slang_select(_S509, material_4.translucent,material_4.albedo);
    float _S511 = 1.0f - _S508;
    float _S512 = _slang_select(_S509, _S508,_S511);
    float3  _S513 = _S510 / make_float3 (_S512);
    bool _S514 = _S508 > 0.0f;
    float3  _S515 = _slang_select(_S514, _S513,material_4.albedo);
    return w_2.diffuse_weight * _S515 / make_float3 (w_2.p_diffuse);
}

__device__ float smithG1(float alpha_3, float n_dot_x_0)
{
    float _S516 = alpha_3 * alpha_3;
    float _S517 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S516 + (1.0f - _S516) * n_dot_x_0 * n_dot_x_0))));
    bool _S518 = alpha_3 > 0.0f;
    float _S519 = _slang_select(_S518, _S517,1.0f);
    return _S519;
}

__device__ float trowbridgeReitz(float alpha_4, float n_dot_h_0)
{
    float _S520 = alpha_4 * alpha_4;
    float _S521 = (1.0f - n_dot_h_0) * (1.0f + n_dot_h_0) + _S520 * n_dot_h_0 * n_dot_h_0;
    return _S520 / (F32_max((3.14159274101257324f * _S521 * _S521), (1.17549435082228751e-38f)));
}

__device__ float anisotropicG1(float3  w_3, float2  alphas_1)
{
    float _S522 = (F32_max((w_3.z), (0.0f)));
    return 2.0f * _S522 / (_S522 + length_0(make_float3 (alphas_1.x * w_3.x, alphas_1.y * w_3.y, _S522)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_2)
{
    float _S523 = alphas_2.x;
    float _S524 = h_0.x / _S523;
    float _S525 = alphas_2.y;
    float _S526 = h_0.y / _S525;
    float _S527 = h_0.z;
    float _S528 = _S524 * _S524 + _S526 * _S526 + _S527 * _S527;
    return 1.0f / (F32_max((3.14159274101257324f * _S523 * _S525 * _S528 * _S528), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float3  v_5, float3  h_1, float3  n_i_5, float n_i_dot_v_1, float alpha_5, AnisotropicFrame frame_3, float v_dot_h_1)
{
    float _S529 = dot_0(n_i_5, h_1);
    float _S530 = smithG1(alpha_5, n_i_dot_v_1);
    float _S531 = _S530 * v_dot_h_1;
    float _S532 = trowbridgeReitz(alpha_5, _S529);
    float _S533 = _S531 * _S532 / n_i_dot_v_1;
    bool _S534 = alpha_5 > 0.0f;
    bool _S535;
    if(_S534)
    {
        _S535 = v_dot_h_1 > 0.0f;
    }
    else
    {
        _S535 = false;
    }
    if(_S535)
    {
        _S535 = _S529 > 0.0f;
    }
    else
    {
        _S535 = false;
    }
    if(_S535)
    {
        _S535 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S535 = false;
    }
    float _S536 = _slang_select(_S535, _S533,0.0f);
    bool _S537 = (frame_3.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S537)
    {
        float3  _S538 = anisotropicLocal(v_5, frame_3.tangent, n_i_5);
        float _S539 = anisotropicG1(_S538, frame_3.alphas);
        float3  _S540 = anisotropicLocal(h_1, frame_3.tangent, n_i_5);
        float _S541 = anisotropicD(_S540, frame_3.alphas);
        float _S542 = _S539 * _S541;
        float _S543 = _S542 * v_dot_h_1 / n_i_dot_v_1;
        bool _S544 = v_dot_h_1 > 0.0f;
        if(_S544)
        {
            _S535 = _S529 > 0.0f;
        }
        else
        {
            _S535 = false;
        }
        if(_S535)
        {
            _S535 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S535 = false;
        }
        float _S545 = _slang_select(_S535, _S543,0.0f);
        pdf_h_0 = _S545;
    }
    else
    {
        pdf_h_0 = _S536;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float l_dot_h_0, float pdf_h_1, Weights w_4, float eta_i_3, float eta_o_3)
{
    float _S546 = eta_i_3 * w_4.v_dot_h + eta_o_3 * l_dot_h_0;
    float _S547 = w_4.p_refract * pdf_h_1 * eta_o_3 * eta_o_3 * (F32_abs((l_dot_h_0))) / (_S546 * _S546);
    bool _S548 = eta_i_3 != eta_o_3;
    bool _S549;
    if(_S548)
    {
        _S549 = l_dot_h_0 < 0.0f;
    }
    else
    {
        _S549 = false;
    }
    float _S550 = _slang_select(_S549, _S547,0.0f);
    return _S550;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_6, float alpha_6, AnisotropicFrame frame_4, BSDFMaterial material_5, Weights w_5)
{
    float _S551 = - dot_0(n_i_6, l_1);
    float _S552 = smithG1(alpha_6, (F32_max((_S551), (0.0f))));
    bool _S553 = (frame_4.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S553)
    {
        float3  _S554 = negate_0(n_i_6);
        float3  _S555 = anisotropicLocal(l_1, frame_4.tangent, _S554);
        float _S556 = anisotropicG1(_S555, frame_4.alphas);
        G1_l_0 = _S556;
    }
    else
    {
        G1_l_0 = _S552;
    }
    return w_5.refract_weight * make_float3 (G1_l_0) * material_5.albedo / make_float3 (w_5.p_refract);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_1, float n_i_dot_v_2, Weights w_6)
{
    float _S557 = w_6.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S558 = n_i_dot_l_1 > 0.0f;
    bool _S559;
    if(_S558)
    {
        _S559 = n_i_dot_v_2 > 0.0f;
    }
    else
    {
        _S559 = false;
    }
    float _S560 = _slang_select(_S559, _S557,0.0f);
    return _S560;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  v_6, float3  n_i_7, BSDFMaterial material_6, Weights w_7)
{
    float3  _S561 = l_2 + v_6;
    float3  _S562 = ((((_S561)) * make_float3(rnorm3df(((_S561)).x, ((_S561)).y, ((_S561)).z))));
    float _S563 = dot_0(n_i_7, _S562);
    float _S564 = (F32_max((dot_0(n_i_7, l_2)), (0.0f)));
    float _S565 = (F32_max((dot_0(n_i_7, v_6)), (0.0f)));
    float _S566 = 1.0f / (F32_max((material_6.sheen_roughness), (0.05000000074505806f)));
    float _S567 = 1.0f - _S563 * _S563;
    float _S568 = (2.0f + _S566) * (F32_pow(((F32_max((_S567), (0.0f)))), (0.5f * _S566))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S564 + _S565 - _S564 * _S565)), (0.0000152587890625f)));
    bool _S569 = (material_6.velvet) > 0.0f;
    float f_1;
    if(_S569)
    {
        float _S570 = (F32_max((material_6.sheen_roughness), (0.00999999977648258f)));
        float _S571 = _S570 * _S570;
        float _S572 = (F32_max((_S567), (0.0000152587890625f)));
        float _S573 = (F32_exp((- _S563 * _S563 / (_S572 * _S571)))) / (3.14159274101257324f * _S571 * _S572 * _S572) * (F32_min((1.0f), (2.0f * _S563 * (F32_min((_S564), (_S565))) / (F32_max(((F32_abs((dot_0(_S562, v_6))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S564 * _S565), (0.0000152587890625f)));
        f_1 = _S573;
    }
    else
    {
        f_1 = _S568;
    }
    return w_7.sheen * make_float3 (f_1 * _S564 * 2.0f * 3.14159274101257324f / w_7.p_sheen_velvet);
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
    ToonShape _S574;
    (&_S574)->toon = toon_0;
    (&_S574)->a = a_7;
    (&_S574)->s = s_0;
    (&_S574)->b = b_3;
    (&_S574)->glossy = glossy_0;
    (&_S574)->norm = norm_0;
    (&_S574)->view = view_0;
    (&_S574)->axis = axis_0;
    return _S574;
}

__device__ __forceinline__ ToonShape toonShape(float3  v_7, float3  n_i_8, BSDFMaterial material_7)
{
    float _S575 = material_7.toon.x;
    bool _S576 = _S575 < 0.0f;
    float3  _S577 = make_float3 ((F32_min(((F32_abs((_S575)))), (1.0f)))) * material_7.albedo;
    float _S578 = clamp_1(material_7.toon.y / _S575, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S579 = clamp_1(material_7.toon.z / _S575, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S580 = (F32_min((_S578 + _S579), (1.57079637050628662f)));
    float integral_0;
    if(_S576)
    {
        integral_0 = 1.0f - (F32_cos(((F32_min((_S580), (_S578))))));
    }
    else
    {
        float _S581 = (F32_sin(((F32_min((_S580), (_S578))))));
        integral_0 = _S581 * _S581 / 2.0f;
    }
    bool _S582 = _S580 > _S578;
    bool _S583;
    if(_S582)
    {
        _S583 = _S579 > 0.0f;
    }
    else
    {
        _S583 = false;
    }
    float _S584;
    if(_S583)
    {
        if(_S576)
        {
            float _S585 = (F32_cos((_S578)));
            float _S586 = (F32_cos((_S580)));
            _S584 = (1.0f + _S578 / _S579) * (_S585 - _S586) - ((F32_sin((_S580))) - _S580 * _S586 - ((F32_sin((_S578))) - _S578 * _S585)) / _S579;
        }
        else
        {
            float _S587 = 2.0f * _S578;
            float _S588 = (F32_cos((_S587)));
            float _S589 = 2.0f * _S580;
            float _S590 = (F32_cos((_S589)));
            _S584 = (1.0f + _S578 / _S579) * (_S588 - _S590) / 4.0f - ((F32_sin((_S589))) / 8.0f - _S580 * _S590 / 4.0f - ((F32_sin((_S587))) / 8.0f - _S578 * _S588 / 4.0f)) / _S579;
        }
        float integral_1 = integral_0 + _S584;
        integral_0 = integral_1;
    }
    float _S591 = dot_0(n_i_8, v_7);
    float _S592 = (F32_acos(((F32_min((_S591), (1.0f))))));
    if(_S592 < _S578)
    {
        _S584 = 1.0f;
    }
    else
    {
        _S584 = (F32_max((1.0f - (_S592 - _S578) / (F32_max((_S579), (0.0000152587890625f)))), (0.0f)));
    }
    float3  _S593;
    if(_S576)
    {
        float3  _S594 = make_float3 (2.0f * _S591) * n_i_8 - v_7;
        float3  _S595 = ((((_S594)) * make_float3(rnorm3df(((_S594)).x, ((_S594)).y, ((_S594)).z))));
        _S593 = _S595;
    }
    else
    {
        _S593 = n_i_8;
    }
    return ToonShape_x24init_0(_S577, _S578, _S579, _S580, _S576, 6.28318548202514648f * integral_0, _S584, _S593);
}

__device__ __forceinline__ float toonPDF(float n_i_dot_l_2, float l_dot_h_1, ToonShape shape_0, Weights w_8)
{
    float _S596 = _slang_select(shape_0.glossy, l_dot_h_1,n_i_dot_l_2);
    float _S597 = (F32_acos((clamp_1(_S596, -1.0f, 1.0f))));
    float _S598;
    if(_S597 < (shape_0.a))
    {
        _S598 = 1.0f;
    }
    else
    {
        _S598 = (F32_max((1.0f - (_S597 - shape_0.a) / (F32_max((shape_0.s), (0.0000152587890625f)))), (0.0f)));
    }
    float _S599 = w_8.p_toon * _S598;
    float _S600 = _slang_select(shape_0.glossy, 1.0f,n_i_dot_l_2);
    float _S601 = _S599 * _S600 / shape_0.norm;
    bool _S602;
    if(shape_0.glossy)
    {
        _S602 = true;
    }
    else
    {
        _S602 = n_i_dot_l_2 > 0.0f;
    }
    float _S603 = _slang_select(_S602, _S601,0.0f);
    return _S603;
}

__device__ __forceinline__ float3  toonBSDF(float3  l_3, float3  n_i_9, ToonShape shape_1, Weights w_9)
{
    float _S604 = (F32_max((dot_0(n_i_9, l_3)), (0.0f)));
    float _S605 = _slang_select(shape_1.glossy, _S604,shape_1.view);
    return shape_1.toon * make_float3 (_S605) / make_float3 (w_9.p_toon);
}

__device__ __forceinline__ float reflectPDF(float pdf_h_2, Weights w_10)
{
    float _S606 = w_10.p_reflect * pdf_h_2 / (4.0f * w_10.v_dot_h);
    bool _S607 = pdf_h_2 > 0.0f;
    float _S608 = _slang_select(_S607, _S606,0.0f);
    return _S608;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_4, float3  n_i_10, float alpha_7, AnisotropicFrame frame_5, Weights w_11)
{
    float _S609 = dot_0(n_i_10, l_4);
    float _S610 = smithG1(alpha_7, (F32_max((_S609), (0.0f))));
    bool _S611 = (frame_5.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S611)
    {
        float3  _S612 = anisotropicLocal(l_4, frame_5.tangent, n_i_10);
        float _S613 = anisotropicG1(_S612, frame_5.alphas);
        G1_l_1 = _S613;
    }
    else
    {
        G1_l_1 = _S610;
    }
    return make_float3 (w_11.reflect_weight * G1_l_1) * w_11.F / make_float3 (w_11.p_reflect);
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_3, float3  out_dir_2, float3  n_6, BSDFMaterial material_8, float eta_i_4, float eta_o_4, bool refracted_2, uint random_state_4, FixedArray<float3 , 5>  * throughputs_0, FixedArray<float, 5>  * pdfs_0)
{
    float3  ggx_n_1;
    float3  _S614 = negate_0(in_dir_3);
    float _S615 = dot_0(n_6, _S614);
    float _S616 = sign_0(_S615);
    float3  _S617 = n_6 * make_float3 (_S616);
    float _S618 = dot_0(_S617, out_dir_2);
    float _S619 = material_8.roughness;
    float _S620 = _S619 * _S619;
    AnisotropicFrame _S621 = anisotropicFrame(material_8, _S617);
    float _S622 = rgb_to_greyscale(material_8.translucent);
    bool _S623 = _S622 > 0.0f;
    bool _S624 = (dot_0(n_6, out_dir_2) * _S615) < 0.0f;
    uint _S625;
    if((F32_abs((material_8.toon.x))) > 0.0f)
    {
        _S625 = 5U;
    }
    else
    {
        _S625 = 4U;
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
        float3  _S626 = make_float3 (0.0f);
        (*throughputs_0)[i_7] = _S626;
        (*pdfs_0)[i_7] = 0.0f;
        uint i_8 = i_7 + 1U;
        i_7 = i_8;
    }
    float3  _S627 = make_float3 (0.0f);
    Weights _S628 = Weights_x24init_0(0.0f, _S627, _S627, 0.0f, _S627, _S627, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, _S627);
    uint half_of_0 = 4294967295U;
    Weights w_12 = _S628;
    float3  ggx_n_2 = _S627;
    i_7 = 0U;
    for(;;)
    {
        if(i_7 < _S625)
        {
        }
        else
        {
            break;
        }
        uint _S629;
        if(i_7 == 3U)
        {
            _S629 = 4U;
        }
        else
        {
            if(i_7 == 4U)
            {
                _S629 = 6U;
            }
            else
            {
                _S629 = i_7;
            }
        }
        bool _S630 = _S629 == 0U;
        bool _S631;
        if(_S630)
        {
            _S631 = _S623;
        }
        else
        {
            _S631 = false;
        }
        bool _S632;
        if(_S631)
        {
            _S632 = _S624;
        }
        else
        {
            _S632 = _S629 == 1U;
        }
        bool _S633 = _S632 != refracted_2;
        if(_S633)
        {
            ggx_n_1 = ggx_n_2;
            uint i_9 = i_7 + 1U;
            ggx_n_2 = ggx_n_1;
            i_7 = i_9;
            continue;
        }
        uint _S634;
        if(_S629 == 6U)
        {
            _S634 = 0U;
        }
        else
        {
            if(_S629 == 4U)
            {
                _S634 = 2U;
            }
            else
            {
                _S634 = _S629;
            }
        }
        bool _S635 = _S634 != half_of_0;
        uint half_of_1;
        Weights w_13;
        if(_S635)
        {
            bool _S636 = _S634 == 0U;
            if(_S636)
            {
                float3  _S637 = sampledHalf(_S614, _S617, _S620, _S621, random_state_4);
                ggx_n_1 = _S637;
            }
            else
            {
                bool _S638 = _S634 == 1U;
                if(_S638)
                {
                    float3  _S639 = refractedHalf(in_dir_3, out_dir_2, n_6, eta_i_4, eta_o_4);
                    ggx_n_1 = _S639;
                }
                else
                {
                    float3  _S640 = reflectedHalf(in_dir_3, out_dir_2);
                    ggx_n_1 = _S640;
                }
            }
            Weights _S641 = lobeWeights(in_dir_3, _S614, _S617, ggx_n_1, _S621, material_8, eta_i_4, eta_o_4);
            w_13 = _S641;
            half_of_1 = _S634;
        }
        else
        {
            w_13 = w_12;
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S629)
        {
        case 0U:
            {
                float _S642 = diffusePDF(_S618, (F32_abs((_S615))), material_8, w_13);
                (*pdfs_0)[int(0)] = _S642;
                float3  _S643 = diffuseBSDF(out_dir_2, _S617, material_8, w_13);
                (*throughputs_0)[int(0)] = _S643;
                break;
            }
        case 1U:
            {
                float _S644 = dot_0(out_dir_2, ggx_n_1);
                float _S645 = vndfPDF(_S614, ggx_n_1, _S617, (F32_abs((_S615))), _S620, _S621, w_13.v_dot_h);
                float _S646 = refractPDF(_S644, _S645, w_13, eta_i_4, eta_o_4);
                (*pdfs_0)[int(1)] = _S646;
                float3  _S647 = refractBSDF(out_dir_2, _S617, _S620, _S621, material_8, w_13);
                (*throughputs_0)[int(1)] = _S647;
                break;
            }
        case 4U:
            {
                float _S648 = sheenVelvetPDF(_S618, (F32_abs((_S615))), w_13);
                (*pdfs_0)[int(3)] = _S648;
                float3  _S649 = sheenVelvetBSDF(out_dir_2, _S614, _S617, material_8, w_13);
                (*throughputs_0)[int(3)] = _S649;
                break;
            }
        case 6U:
            {
                ToonShape _S650 = toonShape(_S614, _S617, material_8);
                float _S651 = toonPDF(_S618, dot_0(out_dir_2, _S650.axis), _S650, w_13);
                (*pdfs_0)[int(4)] = _S651;
                float3  _S652 = toonBSDF(out_dir_2, _S617, _S650, w_13);
                (*throughputs_0)[int(4)] = _S652;
                break;
            }
        default:
            {
                float _S653 = vndfPDF(_S614, ggx_n_1, _S617, (F32_abs((_S615))), _S620, _S621, w_13.v_dot_h);
                float _S654 = reflectPDF(_S653, w_13);
                (*pdfs_0)[int(2)] = _S654;
                float3  _S655 = reflectBSDF(out_dir_2, _S617, _S620, _S621, w_13);
                (*throughputs_0)[int(2)] = _S655;
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
    ggx_n_1 = _S627;
    for(;;)
    {
        if(i_7 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S656 = ((*pdfs_0)[i_7]) > 0.0f;
        if(_S656)
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
    bool _S657 = wrongSide_0(is_inside_2, false, dir_3, surface_1->geometry_n);
    float3  _S658 = BSDF(in_dir_4, dir_3, surface_1->smooth_n, surface_1->material, eta_1.x, eta_1.y, _S657, random_state_5, terms_0, pdfs_1);
    float3  _S659 = make_float3 (0.0f);
    uint i_11 = 0U;
    float3  f_3 = _S659;
    for(;;)
    {
        if(i_11 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S660 = ((*pdfs_1)[i_11]) > 0.0f;
        if(_S660)
        {
            float3  _S661 = (*terms_0)[i_11] * make_float3 ((*pdfs_1)[i_11]) / make_float3 ((*pdfs_1)[i_11] + pdf_0);
            (*terms_0)[i_11] = _S661;
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
    FKSurface _S662 = surface_2;
    FixedArray<float3 , 5>  terms_1;
    FixedArray<float, 5>  pdfs_2;
    float3  _S663 = skyLobes_0(in_dir_5, dir_4, &_S662, eta_2, is_inside_3, pdf_1, random_state_6, &terms_1, &pdfs_2);
    return _S663;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_5, float3  radiance_0, float3  color_0, uint random_state_7)
{
    SkySample _S664;
    (&_S664)->dir = dir_5;
    (&_S664)->radiance = radiance_0;
    (&_S664)->color = color_0;
    (&_S664)->random_state = random_state_7;
    return _S664;
}

static __device__ __noinline__ float3  skyColor_0(float3  in_dir_6, float3  dir_6, FKSurface * surface_3, float2  eta_3, bool is_inside_4, float pdf_2, uint random_state_8, uint depth_0)
{
    FixedArray<float3 , 5>  terms_2;
    FixedArray<float, 5>  pdfs_3;
    float3  _S665 = skyLobes_0(in_dir_6, dir_6, surface_3, eta_3, is_inside_4, pdf_2, random_state_8, &terms_2, &pdfs_3);
    float3  _S666 = make_float3 (0.0f);
    bool shaded_0 = false;
    float3  world_0 = _S666;
    uint i_13 = 0U;
    float3  color_1 = _S666;
    for(;;)
    {
        if(i_13 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S667 = (pdfs_3[i_13]) > 0.0f;
        if(_S667)
        {
            bool _S668 = (fcptWorldReadsPath());
            bool _S669;
            if(_S668)
            {
                _S669 = true;
            }
            else
            {
                _S669 = !shaded_0;
            }
            bool shaded_1;
            float3  world_1;
            if(_S669)
            {
                uint _S670;
                if(i_13 == 3U)
                {
                    _S670 = 4U;
                }
                else
                {
                    if(i_13 == 4U)
                    {
                        _S670 = 6U;
                    }
                    else
                    {
                        _S670 = i_13;
                    }
                }
                float3  _S671 = (fcptEnvMapSample((dir_6), (depth_0), (_S670)));
                world_1 = _S671;
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
    uint2  _S672 = (fcptEnvironmentCdfSize());
    uint2  _S673 = make_uint2 (1U, 0U);
    uint2  _S674 = _S672 - _S673;
    Random _S675 = draw(init_random_state_0, 6U);
    Random _S676 = draw(init_random_state_0, 2147483654U);
    Random _S677 = draw(init_random_state_0, 7U);
    Random _S678 = draw(init_random_state_0, 2147483655U);
    uint _S679 = _S674.x;
    uint _S680 = searchCDF_0(make_uint2 (_S679, 0U), make_uint2 (0U, 1U), _S674.y, _S675.value);
    uint _S681 = searchCDF_0(make_uint2 (0U, _S680), _S673, _S679, _S676.value);
    float2  _S682 = make_float2 ((float)_S674.x, (float)_S674.y);
    float2  _S683 = (make_float2 (float(_S681), float(_S680)) + make_float2 (_S677.value, _S678.value)) / _S682 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S684 = _S683.y;
    float _S685 = (F32_sin((_S684)));
    float _S686 = _S683.x;
    float3  _S687 = make_float3 (- _S685 * (F32_cos((_S686))), _S685 * (F32_sin((_S686))), (F32_cos((_S684))));
    float _S688 = environmentPdf_0(_S687);
    float3  _S689 = ray_0->unit_direction;
    float3  _S690 = skyBSDF(ray_0->unit_direction, _S687, *surface_4, eta_4, is_inside_5, _S688, lobe_state_0);
    bool _S691 = !(_S688 > 0.0f);
    bool _S692;
    if(_S691)
    {
        _S692 = true;
    }
    else
    {
        _S692 = all_1(_S690 == make_float3 (0.0f));
    }
    if(_S692)
    {
        float3  _S693 = make_float3 (0.0f);
        return SkySample_x24init_0(_S687, _S693, _S693, _S678.state);
    }
    bool _S694 = (fcptWorldReadsPath());
    float3  seen_0;
    if(_S694)
    {
        float3  _S695 = skyColor_0(_S689, _S687, surface_4, eta_4, is_inside_5, _S688, lobe_state_0, context_2->depth + 1U);
        seen_0 = _S695;
    }
    else
    {
        seen_0 = _S690;
    }
    float3  _S696 = skyRadiance_0(ray_0->origin, surface_4, is_inside_5, _S687, context_2, _S678.state);
    return SkySample_x24init_0(_S687, _S696, seen_0 * _S696, _S678.state);
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
    SampleBSDF _S697 = (fcptConnectHair((surface_5->hair), ((&surface_5->material)->albedo), ((&surface_5->material)->specular_tint), (in_dir_7), (light_1->dir)));
    float3  _S698 = _S697.throughput * make_float3 (_S697.pdf);
    float _S699 = light_1->density;
    float _S700 = 1.0f + _S697.pdf * _S697.pdf / (light_1->density * light_1->density);
    bool _S701;
    if(competing_0)
    {
        _S701 = _S699 > 0.0f;
    }
    else
    {
        _S701 = false;
    }
    float _S702 = _slang_select(_S701, _S700,1.0f);
    return _S698 / make_float3 (_S702) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_7, float3  radiance_1, float density_0, uint random_state_9)
{
    TreeSample _S703;
    (&_S703)->dir = dir_7;
    (&_S703)->radiance = radiance_1;
    (&_S703)->density = density_0;
    (&_S703)->random_state = random_state_9;
    return _S703;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_12, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S704 = importance(first_1, p_12, normal_3);
    float _S705 = importance(second_1, p_12, normal_3);
    float2  _S706 = make_float2 (_S704, _S705);
    bool _S707 = _S704 == 0.0f;
    bool _S708;
    if(_S707)
    {
        _S708 = _S705 == 0.0f;
    }
    else
    {
        _S708 = false;
    }
    if(_S708)
    {
        return 2U;
    }
    float _S709 = _S704 + _S705;
    bool _S710 = _S705 > 0.0f;
    if(_S710)
    {
        _S708 = (*pick_0 * _S709) >= _S704;
    }
    else
    {
        _S708 = false;
    }
    uint _S711 = uint(_S708);
    float _S712 = (F32_min(((*pick_0 * _S709 - float(_S711) * _S704) / _slang_vector_get_element(_S706, _S711)), (0.99999994039535522f)));
    *pick_0 = _S712;
    float _S713 = *probability_3 * (_slang_vector_get_element(_S706, _S711) / _S709);
    *probability_3 = _S713;
    return _S711;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_13, float u1_0, float u2_0)
{
    float3  _S714 = center_1 - p_13;
    float _S715 = radius_1 * radius_1 / dot_0(_S714, _S714);
    float _S716 = u1_0 * _S715 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S715), (0.0f)))))));
    float _S717 = 2.0f * u1_0;
    bool _S718 = _S715 >= 1.0f;
    float _S719 = _slang_select(_S718, _S717,_S716);
    float _S720 = (F32_sqrt(((F32_max((_S719 * (2.0f - _S719)), (0.0f))))));
    float _S721 = 6.28318548202514648f * u2_0;
    float3  _S722 = make_float3 (_S720 * (F32_cos((_S721))), 1.0f - _S719, _S720 * (F32_sin((_S721))));
    float3  _S723 = ((((_S714)) * make_float3(rnorm3df(((_S714)).x, ((_S714)).y, ((_S714)).z))));
    float3  _S724 = tangentToWorld(_S722, _S723);
    return _S724;
}

__device__ float3  pointLightRadiance(float3  color_3, float intensity_0, float radius_2)
{
    return color_3 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S725 = center_2 - ray_1->origin;
    float _S726 = dot_0(_S725, ray_1->unit_direction);
    float _S727 = dot_0(_S725, _S725) - _S726 * _S726;
    float _S728 = radius_3 * radius_3;
    bool _S729 = _S727 > _S728;
    if(_S729)
    {
        return 4.294967296e+09f;
    }
    float _S730 = (F32_sqrt((_S728 - _S727)));
    float _S731 = _S726 - _S730;
    float _S732 = _S726 + _S730;
    bool _S733 = _S731 > 0.0000152587890625f;
    bool _S734;
    if(_S733)
    {
        _S734 = _S731 < max_len_0;
    }
    else
    {
        _S734 = false;
    }
    if(_S734)
    {
        return _S731;
    }
    bool _S735 = _S732 > 0.0000152587890625f;
    if(_S735)
    {
        _S734 = _S732 < max_len_0;
    }
    else
    {
        _S734 = false;
    }
    if(_S734)
    {
        return _S732;
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
    Random _S736 = draw(init_random_state_1, 4U);
    Random _S737 = draw(init_random_state_1, 5U);
    Random _S738 = draw(init_random_state_1, 2147483653U);
    float3  _S739 = make_float3 (0.0f);
    TreeSample _S740 = TreeSample_x24init_0(_S739, _S739, 0.0f, _S738.state);
    TreeSample sample_0 = _S740;
    float3  _S741 = _slang_select(sided_0, _S739,smooth_n_2);
    float3  _S742 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S736.value;
    float probability_4 = 1.0f;
    uint n_7 = 0U;
    for(;;)
    {
        uint4  _S743 = (fcptLightNode((n_7)));
        if((_S743.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S744 = (fcptLightSecond((n_7)));
        uint _S745 = n_7 + 1U;
        LightNode _S746 = (fcptLightBounds((_S745)));
        LightNode _S747 = (fcptLightBounds((_S744)));
        uint _S748 = pickChild(_S746, _S747, origin_4, _S741, &pick_1, &probability_4);
        bool _S749 = _S748 > 1U;
        if(_S749)
        {
            return sample_0;
        }
        bool _S750 = _S748 == 1U;
        uint _S751 = _slang_select(_S750, _S744,_S745);
        n_7 = _S751;
    }
    bool _S752 = n_7 == 0U;
    bool _S753;
    if(_S752)
    {
        LightNode _S754 = (fcptLightBounds((0U)));
        float _S755 = importance(_S754, origin_4, _S741);
        _S753 = !(_S755 > 0.0f);
    }
    else
    {
        _S753 = false;
    }
    if(_S753)
    {
        return sample_0;
    }
    uint4  _S756 = (fcptLightNode((n_7)));
    FKHit _S757 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S758 = (_S756.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S758)
    {
        FKLight _S759 = (fcptLight((_S756.y)));
        if(sided_0)
        {
            float _S760 = sign_0(dot_0(geometry_n_1, _S759.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S760);
            float3  _S761 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S761;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S742;
            lift_n_0 = smooth_n_2;
        }
        bool _S762 = (_S759.variance) == 0.0f;
        if(_S762)
        {
            float3  _S763 = _S759.position - emitter_point_0;
            float3  _S764 = ((((_S763)) * make_float3(rnorm3df(((_S763)).x, ((_S763)).y, ((_S763)).z))));
            (&sample_0)->dir = _S764;
            float3  _S765 = _S759.color * make_float3 (_S759.intensity) / make_float3 (dot_0(_S763, _S763) * probability_4);
            (&sample_0)->radiance = _S765;
            shadow_1 = _S763;
        }
        else
        {
            float3  _S766 = sampleSphere(_S759.position, _S759.variance, emitter_point_0, _S737.value, _S738.value);
            (&sample_0)->dir = _S766;
            float _S767 = sphereDensity(_S759.position, _S759.variance, emitter_point_0);
            float _S768 = probability_4 * _S767;
            (&sample_0)->density = _S768;
            float3  _S769 = pointLightRadiance(_S759.color, _S759.intensity, _S759.variance);
            float3  _S770 = _S769 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S770;
            FKRay _S771 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S772 = raySphere_0(_S759.position, _S759.variance, &_S771, 4.294967296e+09f);
            float3  _S773 = (&sample_0)->dir * make_float3 (_S772);
            shadow_1 = _S773;
        }
        emitter_0 = _S757;
        emitter_point_0 = _S739;
    }
    else
    {
        uint _S774 = _S756.y;
        uint _S775 = (fcptTriangleOffset((_S774)));
        uint _S776 = _S775 + _S756.z;
        Matrix<float, 3, 3>  _S777 = (fcptWorldTriangle((_S774), (_S776)));
        float _S778 = (F32_sqrt((_S737.value)));
        float2  _S779 = make_float2 (_S778 * (1.0f - _S738.value), _S778 * _S738.value);
        float3  _S780 = mul_0(make_float3 (1.0f - _S778, _S779.x, _S779.y), _S777);
        if(sided_0)
        {
            float _S781 = sign_0(dot_0(geometry_n_1, _S780 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S781);
            float3  _S782 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S782;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S783 = !((dot_0(smooth_n_2, _S780 - origin_4)) > 0.0f);
            if(_S783)
            {
                return sample_0;
            }
            emitter_point_0 = _S742;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S779, _S774, _S776, 0U, 0.0f);
        float3  _S784 = _S780 - emitter_point_0;
        float3  _S785 = ((((_S784)) * make_float3(rnorm3df(((_S784)).x, ((_S784)).y, ((_S784)).z))));
        (&sample_0)->dir = _S785;
        float _S786 = solidAngle(probability_4, cross_0(_S777.rows[int(1)] - _S777.rows[int(0)], _S777.rows[int(2)] - _S777.rows[int(0)]), _S784);
        (&sample_0)->density = _S786;
        bool _S787 = (fcptShadowFirst());
        bool _S788 = !_S787;
        if(_S788)
        {
            FKSurface _S789 = (fcptLightSurfaceAt((emitter_1), (_S780), (_S738.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S780 - origin_4))));
            (&sample_0)->random_state = _S789.random_state;
            float3  _S790 = _slang_select(_S789.skip, _S739,_S789.material.emissive);
            float3  _S791 = _S790 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S791;
        }
        shadow_1 = _S784;
        emitter_0 = emitter_1;
        emitter_point_0 = _S780;
    }
    FKHit _S792 = emitter_0;
    float3  _S793 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S738.state, &_S792);
    bool _S794 = (fcptShadowFirst());
    if(_S794)
    {
        _S753 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S753 = false;
    }
    if(_S753)
    {
        _S753 = !all_1(_S793 == _S739);
    }
    else
    {
        _S753 = false;
    }
    if(_S753)
    {
        FKSurface _S795 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S738.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S795.random_state;
        float3  _S796 = _slang_select(_S795.skip, _S739,_S795.material.emissive);
        float3  _S797 = _S796 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S797;
    }
    float3  _S798 = (&sample_0)->radiance * _S793;
    bool _S799 = all_1(_S793 == _S739);
    float3  _S800 = _slang_select(_S799, _S739,_S798);
    (&sample_0)->radiance = _S800;
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
    float _S801 = 1.0f / (1.0f + b_4 / a_8 * (b_4 / a_8));
    bool _S802 = b_4 > 0.0f;
    float _S803 = _slang_select(_S802, _S801,1.0f);
    return _S803;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S804 = vertex_0->none;
    if(_S804)
    {
        return 1.0f;
    }
    uint _S805 = (fcptLightSlot((*hit_1)));
    float _S806 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S805, light_point_1);
    float _S807 = powerHeuristic(vertex_0->pdf, _S806);
    return _S807;
}

static __device__ float3  environment_0(float3  dir_8, uint depth_1, uint lobe_0)
{
    uint2  _S808 = (fcptEnvironmentMapSize());
    bool _S809 = (_S808.x) > 1U;
    bool _S810;
    if(_S809)
    {
        uint2  _S811 = (fcptEnvironmentMapSize());
        _S810 = (_S811.y) > 1U;
    }
    else
    {
        _S810 = false;
    }
    if(_S810)
    {
        float3  _S812 = (fcptEnvMapSample((dir_8), (depth_1), (lobe_0)));
        return _S812;
    }
    float3  _S813 = (fcptAmbient());
    return _S813;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S814 = (fcptEnvironmentCdfSize());
    bool _S815 = (_S814.x) > 1U;
    bool _S816;
    if(_S815)
    {
        uint2  _S817 = (fcptEnvironmentCdfSize());
        _S816 = (_S817.y) > 1U;
    }
    else
    {
        _S816 = false;
    }
    bool _S818 = !_S816;
    if(_S818)
    {
        return false;
    }
    uint2  _S819 = (fcptEnvironmentMapSize());
    bool _S820 = (_S819.x) > 1U;
    if(_S820)
    {
        uint2  _S821 = (fcptEnvironmentMapSize());
        _S816 = (_S821.y) > 1U;
    }
    else
    {
        _S816 = false;
    }
    return _S816;
}

static __device__ float escapeWeight_0(float pdf_3, float3  dir_9)
{
    bool _S822 = pdf_3 <= 0.0f;
    bool _S823;
    if(_S822)
    {
        _S823 = true;
    }
    else
    {
        bool _S824 = environmentMapped_0();
        _S823 = !_S824;
    }
    if(_S823)
    {
        return 1.0f;
    }
    float _S825 = environmentPdf_0(dir_9);
    return pdf_3 / (pdf_3 + _S825);
}

static __device__ void restir_duplicates_0(uint3  global_invocation_id_1, uint3  local_invocation_id_0, uint local_invocation_index_3)
{
    uint2  _S826 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S827 = make_int2 ((int)_S826.x, (int)_S826.y);
    uint _S828 = previousSeed_0(_S827);
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
            uint _S829 = previousSeed_0(_S827 + make_int2 (x_16, y_5));
            bool _S830 = _S829 == _S828;
            uint _S831 = _slang_select(_S830, 1U,0U);
            uint count_3 = count_2 + _S831;
            int x_17 = x_16 + int(1);
            x_16 = x_17;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S832 = float(count_2 - 1U) / 288.0f;
    bool _S833 = _S828 != 0U;
    float _S834 = _slang_select(_S833, _S832,0.0f);
    fcptStoreDuplication((_S827), (make_uint4 ((F32_asuint((_S834))), 0U, 0U, 0U)));
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
    float _S835 = rgb_to_greyscale(abs_0(f_5));
    return _S835;
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
    float _S836 = resamplingTarget(weight_0);
    bool _S837 = _S836 > 0.0f;
    bool _S838;
    if(_S837)
    {
        _S838 = _S836 < 3.00000000549775576e+38f;
    }
    else
    {
        _S838 = false;
    }
    bool _S839 = !_S838;
    if(_S839)
    {
        return;
    }
    bool _S840 = sel_2->sums;
    if(_S840)
    {
        float3  _S841 = sel_2->color + weight_0;
        sel_2->color = _S841;
        return;
    }
    float _S842 = sel_2->w_sum + _S836;
    sel_2->w_sum = _S842;
    float3  _S843 = sel_2->color + weight_0;
    sel_2->color = _S843;
    Random _S844 = pcg(sel_2->random_state);
    sel_2->random_state = _S844.state;
    bool _S845 = (_S844.value * sel_2->w_sum) <= _S836;
    if(_S845)
    {
        sel_2->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_3;
    float3  _S846 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S846;
    float _S847 = r_3.jac * shifted_0.jac;
    (&candidate_1)->jac = _S847;
    offer(sel_3, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S848 = resamplingTarget((&r_4)->f);
    float _S849 = sel_4.w_sum / _S848;
    bool _S850 = _S848 > 0.0f;
    float _S851 = _slang_select(_S850, _S849,0.0f);
    (&r_4)->w = _S851;
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
    uint2  _S852 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S853 = make_int2 ((int)_S852.x, (int)_S852.y);
    float3  _S854 = make_float3 (0.0f);
    FKHit _S855 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S856 = Domain_x24init_0(_S854, _S854, &_S855, 0.0f, 0.0f);
    Domain dom_4 = _S856;
    bool _S857 = (fcptCurrentDomain((_S853), (&dom_4)));
    bool _S858 = !_S857;
    if(_S858)
    {
        Reservoir _S859 = (Reservoir{});
        fcptStoreReservoirPrevious((_S853), (_S859), ((&dom_4)->hit));
        return;
    }
    Reservoir _S860 = (fcptLoadReservoirTemporal((_S853)));
    uint t_13 = 0U;
    float count_4 = 0.0f;
    float c_sum_1 = _S860.c;
    for(;;)
    {
        uint _S861 = (fcptRestirNeighbours());
        if(t_13 < _S861)
        {
        }
        else
        {
            break;
        }
        int2  _S862 = partner_0(_S853, t_13);
        Domain neighbor_0 = _S856;
        bool _S863 = (fcptCurrentDomain((_S862), (&neighbor_0)));
        if(_S863)
        {
            float count_5 = count_4 + 1.0f;
            uint4  _S864 = (fcptReservoirTemporal((_S862), (0U)));
            float c_sum_2 = c_sum_1 + (U32_asfloat((_S864.w)));
            count_4 = count_5;
            c_sum_1 = c_sum_2;
        }
        uint t_14 = t_13 + 1U;
        t_13 = t_14;
    }
    float _S865 = _S860.c / (F32_max((count_4), (1.0f)));
    float _S866 = resamplingTarget(_S860.f);
    bool _S867 = count_4 == 0.0f;
    float _S868 = _slang_select(_S867, 1.0f,0.0f);
    Selection _S869 = (Selection{});
    Selection sel_5 = _S869;
    uint _S870 = (fcptFrame());
    uint _S871 = hash(_S870);
    uint _S872 = global_invocation_id_2.x;
    uint2  _S873 = (fcptRenderSize());
    uint _S874 = stream(_S871, _S872 + _S873.x * global_invocation_id_2.y);
    uint _S875 = stream(_S874, 195U);
    (&sel_5)->random_state = _S875;
    t_13 = 0U;
    float canonical_mis_0 = _S868;
    for(;;)
    {
        uint _S876 = (fcptRestirNeighbours());
        if(t_13 < _S876)
        {
        }
        else
        {
            break;
        }
        int2  _S877 = partner_0(_S853, t_13);
        Domain neighbor_dom_0 = _S856;
        bool _S878 = (fcptCurrentDomain((_S877), (&neighbor_dom_0)));
        if(_S878)
        {
            Reservoir _S879 = (fcptLoadReservoirTemporal((_S877)));
            uint4  _S880 = (fcptShiftData((_S877), (t_13)));
            float4  _S881 = asfloat_0(_S880);
            uint4  _S882 = (fcptShiftData((_S853), (t_13)));
            float4  _S883 = asfloat_0(_S882);
            float _S884 = pairShare(_S879.c, _S865, c_sum_1);
            bool _S885 = _S866 > 0.0f;
            float canonical_mis_1;
            if(_S885)
            {
                float _S886 = resamplingTarget(float3 {_S883.x, _S883.y, _S883.z});
                float _S887 = canonicalWeight(_S884, _S865, _S866, _S879.c, _S886);
                float canonical_mis_2 = canonical_mis_0 + _S887;
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float3  _S888 = float3 {_S881.x, _S881.y, _S881.z};
            Shift _S889 = Shift_x24init_0(_S888, _S881.w);
            float _S890 = resamplingTarget(_S879.f);
            float _S891 = resamplingTarget(_S888);
            float _S892 = neighborWeight(_S884, _S879.c, _S890, _S865, _S891);
            offerShifted(&sel_5, _S879, _S889, _S892);
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_15 = t_13 + 1U;
        t_13 = t_15;
    }
    offerShifted(&sel_5, _S860, Shift_x24init_0(_S860.f, 1.0f), canonical_mis_0);
    Reservoir _S893 = finalize(sel_5, c_sum_1);
    fcptStoreReservoirPrevious((_S853), (_S893), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S853), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S853), (make_float4 ((&sel_5)->color.x, (&sel_5)->color.y, (&sel_5)->color.z, 0.0f)));
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
    uint _S894 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S895 = _S894 != 4294967295U;
    if(_S895)
    {
        uint2  _S896 = make_uint2 (_S894, _S894 >> 14U) & make_uint2 (16383U);
        int2  _S897 = make_int2 ((int)_S896.x, (int)_S896.y);
        ShiftJob _S898 = (ShiftJob{});
        ShiftJob shift_job_0 = _S898;
        Shift _S899 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S900 = _S894 >> 28U;
        bool _S901 = spatialJob_0(_S897, _S900, &shift_job_0, true);
        Shift shifted_1;
        if(_S901)
        {
            Domain _S902 = (&shift_job_0)->dom;
            Reservoir _S903 = (&shift_job_0)->r;
            Shift _S904 = passShift_0(&_S902, &_S903);
            shifted_1 = _S904;
        }
        else
        {
            shifted_1 = _S899;
        }
        fcptStoreShiftData((_S897), (_S900), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S905 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S906 = make_int2 ((int)_S905.x, (int)_S905.y);
    FixedArray<uint, 3>  _S907;
    spatialBins_0(_S906, &_S907);
    FixedArray<uint, 3>  _S908 = _S907;
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
        bool _S909 = (_S908[t_16]) == 40U;
        if(_S909)
        {
            fcptStoreShiftData((_S906), (t_16), (make_uint4 (0U)));
        }
        uint t_17 = t_16 + 1U;
        t_16 = t_17;
    }
    FixedArray<uint, 3>  _S910 = _S908;
    queueShifts_0(_S906, &_S910, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S911 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S912 = make_int2 ((int)_S911.x, (int)_S911.y);
    FixedArray<uint, 3>  _S913;
    spatialBins_0(_S912, &_S913);
    FixedArray<uint, 3>  _S914 = _S913;
    countShifts_0(&_S914, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S915 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S916 = _S915 != 4294967295U;
    if(_S916)
    {
        uint2  _S917 = make_uint2 (_S915, _S915 >> 14U) & make_uint2 (16383U);
        int2  _S918 = make_int2 ((int)_S917.x, (int)_S917.y);
        int2  _S919 = (fcptLoadTemporalNeighbor((_S918)));
        uint _S920 = _S915 >> 28U;
        Shift _S921 = temporalShiftAt_0(_S918, _S919, _S920);
        fcptStoreTemporalShift((_S918), (_S920), (make_uint4 (asuint_1(_S921.f).x, asuint_1(_S921.f).y, asuint_1(_S921.f).z, (F32_asuint((_S921.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S922 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S923 = make_int2 ((int)_S922.x, (int)_S922.y);
    FixedArray<uint, 3>  _S924;
    temporalBins_0(_S923, &_S924);
    FixedArray<uint, 3>  _S925 = _S924;
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
        bool _S926 = (_S925[t_18]) == 40U;
        if(_S926)
        {
            fcptStoreTemporalShift((_S923), (t_18), (make_uint4 (0U)));
        }
        uint t_19 = t_18 + 1U;
        t_18 = t_19;
    }
    FixedArray<uint, 3>  _S927 = _S925;
    queueShifts_0(_S923, &_S927, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S928 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S929 = make_int2 ((int)_S928.x, (int)_S928.y);
    bool _S930 = (fcptSceneUnchanged());
    bool _S931 = !_S930;
    bool _S932;
    if(_S931)
    {
        uint2  _S933 = (fcptRenderSize());
        int2  _S934 = make_int2 ((int)_S933.x, (int)_S933.y);
        _S932 = all_0(_S929 < _S934);
    }
    else
    {
        _S932 = false;
    }
    if(_S932)
    {
        Reservoir _S935 = (fcptLoadReservoirInitial((_S929)));
        int2  _S936 = sampleNeighbor_0(_S929, _S935.seed);
        fcptStoreTemporalNeighbor((_S929), (_S936));
    }
    FixedArray<uint, 3>  _S937;
    temporalBins_0(_S929, &_S937);
    FixedArray<uint, 3>  _S938 = _S937;
    countShifts_0(&_S938, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_9, float b_5, float t_20)
{
    return a_9 + (b_5 - a_9) * t_20;
}

__device__ float confidenceCap(float duplicated_0)
{
    float _S939 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S939;
}

__device__ float2  temporalWeights(float c_2, float p_c_1, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S940 = c_2 * p_c_1;
    float _S941 = c_t_0 * p_t_0;
    return make_float2 (_S940 / (_S940 + c_t_0 * g_previous_0), _S941 / (_S941 + c_2 * g_current_0));
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S942 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S943 = make_int2 ((int)_S942.x, (int)_S942.y);
    float3  _S944 = make_float3 (0.0f);
    FKHit _S945 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S946 = Domain_x24init_0(_S944, _S944, &_S945, 0.0f, 0.0f);
    Domain dom_5 = _S946;
    bool _S947 = (fcptCurrentDomain((_S943), (&dom_5)));
    bool _S948 = !_S947;
    if(_S948)
    {
        Reservoir _S949 = (Reservoir{});
        fcptStoreReservoirTemporal((_S943), (_S949), ((&dom_5)->hit));
        return;
    }
    Reservoir _S950 = (fcptLoadReservoirInitial((_S943)));
    bool _S951 = (fcptTemporalQueued());
    bool _S952 = (fcptSceneUnchanged());
    bool _S953;
    if(_S952)
    {
        _S953 = true;
    }
    else
    {
        _S953 = !_S951;
    }
    int2  _S954;
    if(_S953)
    {
        int2  _S955 = sampleNeighbor_0(_S943, _S950.seed);
        _S954 = _S955;
    }
    else
    {
        int2  _S956 = (fcptLoadTemporalNeighbor((_S943)));
        _S954 = _S956;
    }
    bool _S957 = (_S954.x) >= int(0);
    Reservoir r_5;
    if(_S957)
    {
        Reservoir _S958 = (fcptLoadReservoirPrevious((_S954)));
        uint4  _S959 = (fcptDuplication((_S954)));
        float _S960 = (U32_asfloat((_S959.x)));
        uint _S961 = (fcptRestirDecorrelation());
        bool _S962 = _S961 == 1U;
        float _S963 = _slang_select(_S962, _S960,0.0f);
        float _S964 = confidenceCap(_S963);
        float _S965 = (F32_min((_S958.c), (_S964)));
        bool _S966 = (fcptSceneUnchanged());
        float4  _S967 = make_float4 (_S958.f.x, _S958.f.y, _S958.f.z, 1.0f);
        bool _S968 = !_S966;
        if(_S968)
        {
            _S953 = _S951;
        }
        else
        {
            _S953 = false;
        }
        float4  to_current_0;
        if(_S953)
        {
            uint4  _S969 = (fcptTemporalShift((_S943), (0U)));
            float4  _S970 = asfloat_0(_S969);
            to_current_0 = _S970;
        }
        else
        {
            if(_S968)
            {
                Shift _S971 = temporalShiftAt_0(_S943, _S954, 0U);
                float4  _S972 = make_float4 (_S971.f.x, _S971.f.y, _S971.f.z, _S971.jac);
                to_current_0 = _S972;
            }
            else
            {
                to_current_0 = _S967;
            }
        }
        Domain own_1 = _S946;
        if(_S966)
        {
            _S953 = true;
        }
        else
        {
            bool _S973 = (fcptPreviousScenes());
            bool _S974 = !_S973;
            if(_S974)
            {
                _S953 = (_S950.w) > 0.0f;
            }
            else
            {
                _S953 = false;
            }
            if(_S953)
            {
                bool _S975 = (fcptStoredDomainInitial((_S943), (_S950.seed), (&own_1)));
                _S953 = _S975;
            }
            else
            {
                _S953 = false;
            }
            if(_S953)
            {
                Domain _S976 = (fcptPreviousDomain((_S954), (_S950.seed)));
                Domain _S977 = _S976;
                Domain _S978 = own_1;
                bool _S979 = sameDomain_0(&_S977, &_S978);
                _S953 = _S979;
            }
            else
            {
                _S953 = false;
            }
        }
        float4  _S980 = make_float4 (_S950.f.x, _S950.f.y, _S950.f.z, 1.0f);
        bool _S981 = !_S953;
        if(_S981)
        {
            _S953 = _S951;
        }
        else
        {
            _S953 = false;
        }
        float4  to_previous_0;
        if(_S953)
        {
            uint4  _S982 = (fcptTemporalShift((_S943), (1U)));
            float4  _S983 = asfloat_0(_S982);
            to_previous_0 = _S983;
        }
        else
        {
            if(_S981)
            {
                Shift _S984 = temporalShiftAt_0(_S943, _S954, 1U);
                float4  _S985 = make_float4 (_S984.f.x, _S984.f.y, _S984.f.z, _S984.jac);
                to_previous_0 = _S985;
            }
            else
            {
                to_previous_0 = _S980;
            }
        }
        float _S986 = resamplingTarget(_S950.f);
        float _S987 = resamplingTarget(_S958.f);
        Selection _S988 = (Selection{});
        Selection sel_6 = _S988;
        uint _S989 = (fcptFrame());
        uint _S990 = hash(_S989);
        uint _S991 = global_invocation_id_7.x;
        uint2  _S992 = (fcptRenderSize());
        uint _S993 = stream(_S990, _S991 + _S992.x * global_invocation_id_7.y);
        uint _S994 = stream(_S993, 194U);
        (&sel_6)->random_state = _S994;
        float4  _S995 = to_previous_0;
        float _S996 = resamplingTarget(float3 {_S995.x, _S995.y, _S995.z});
        float4  _S997 = to_current_0;
        float3  _S998 = float3 {_S997.x, _S997.y, _S997.z};
        float _S999 = resamplingTarget(_S998);
        float2  _S1000 = temporalWeights(_S950.c, _S986, _S965, _S987, _S996, _S999);
        offerShifted(&sel_6, _S950, Shift_x24init_0(_S950.f, 1.0f), _S1000.x);
        offerShifted(&sel_6, _S958, Shift_x24init_0(_S998, to_current_0.w), _S1000.y);
        Reservoir _S1001 = finalize(sel_6, _S950.c + _S965);
        r_5 = _S1001;
    }
    else
    {
        r_5 = _S950;
    }
    fcptStoreReservoirTemporal((_S943), (r_5), ((&dom_5)->hit));
    return;
}

__device__ uint noiseOrigin(uint2  p_14, uint k_1)
{
    uint _S1002 = ((p_14.x) >> 11U) | (((p_14.y) >> 11U) << 4U);
    uint2  _S1003 = noiseOffset(8192U + (k_1 >> 10U) + (_S1002 << 20U));
    uint2  _S1004 = (p_14 + _S1003) & make_uint2 (2047U);
    return ((_S1004.x) | ((_S1004.y) << 11U)) | ((k_1 & 1023U) << 22U);
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_6)
{
    uint _S1005 = (1U << count_6) - 1U;
    return (e_2 & (~(_S1005 << offset_1))) | ((newbits_0 & _S1005) << offset_1);
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S1006 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S1007 = make_int2 ((int)_S1006.x, (int)_S1006.y);
    float3  _S1008 = make_float3 (0.0f);
    float2  _S1009 = make_float2 (0.0f);
    FKHit _S1010 = Hit_x24init_0(_S1009, 0U, 0U, 0U, 0.0f);
    Domain _S1011 = Domain_x24init_0(_S1008, _S1008, &_S1010, 0.0f, 0.0f);
    Domain dom_6 = _S1011;
    bool _S1012 = (fcptCurrentDomain((_S1007), (&dom_6)));
    bool _S1013 = !_S1012;
    if(_S1013)
    {
        Reservoir _S1014 = (Reservoir{});
        fcptStoreReservoirInitial((_S1007), (_S1014), ((&dom_6)->hit));
        return;
    }
    uint _S1015 = (fcptFrame());
    uint _S1016 = hash(_S1015);
    uint _S1017 = global_invocation_id_8.x;
    uint2  _S1018 = (fcptRenderSize());
    uint _S1019 = global_invocation_id_8.y;
    uint _S1020 = stream(_S1016, _S1017 + _S1018.x * _S1019);
    uint2  _S1021 = (fcptRenderSize());
    uint _S1022 = stream(_S1017 + _S1021.x * _S1019, 512U);
    Selection _S1023 = (Selection{});
    Selection initial_0 = _S1023;
    uint _S1024 = stream(_S1020, 193U);
    (&initial_0)->random_state = _S1024;
    bool _S1025 = (fcptRestirUsed());
    bool _S1026 = !_S1025;
    (&initial_0)->sums = _S1026;
    uint _S1027 = stream(_S1020, 0U);
    (&(&initial_0)->r)->seed = _S1027;
    FKHit _S1028 = Hit_x24init_0(_S1009, 4294967295U, 0U, 0U, 0.0f);
    uint _S1029 = (fcptSamples());
    float _S1030 = 1.0f / float(_S1029);
    FKHit hit_2 = _S1028;
    uint i_20 = 0U;
    float3  seen_1 = _S1008;
    for(;;)
    {
        uint _S1031 = (fcptSamples());
        if(i_20 < _S1031)
        {
        }
        else
        {
            break;
        }
        Reservoir _S1032 = (Reservoir{});
        Reservoir r_6 = _S1032;
        uint _S1033 = (fcptFrame());
        uint _S1034 = (fcptSamples());
        uint _S1035 = _S1033 * _S1034 + i_20;
        uint _S1036 = noiseOrigin(_S1006, _S1035);
        (&r_6)->seed = _S1036;
        uint _S1037 = insertBits_0(0U, 1U, 24U, 1U);
        uint _S1038 = insertBits_0(_S1037, (_S1022 + _S1035 * 2654435769U) >> 25U, 25U, 7U);
        (&r_6)->path = _S1038;
        Domain path_0 = _S1011;
        bool _S1039 = (fcptStoredDomainInitial((_S1007), ((&r_6)->seed), (&path_0)));
        bool _S1040 = !_S1039;
        if(_S1040)
        {
            float3  _S1041 = (fcptMissed((_S1007), (path_0), (_S1030)));
            float3  seen_2 = seen_1 + _S1041;
            seen_1 = seen_2;
            uint i_21 = i_20 + 1U;
            i_20 = i_21;
            continue;
        }
        Domain _S1042 = path_0;
        Reservoir _S1043 = r_6;
        Shift _S1044 = passWalk_0(&_S1042, &_S1043, false, _S1030, &initial_0);
        bool _S1045 = ((&(&initial_0)->r)->seed) == ((&r_6)->seed);
        FKHit hit_3;
        if(_S1045)
        {
            FKHit _S1046 = (&path_0)->hit;
            hit_3 = _S1046;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_21 = i_20 + 1U;
        i_20 = i_21;
    }
    uint _S1047 = (fcptSamples());
    float3  seen_3 = seen_1 + (&initial_0)->glow / make_float3 (float(_S1047));
    if((&initial_0)->sums)
    {
        seen_1 = seen_3 + (&initial_0)->color;
    }
    else
    {
        seen_1 = seen_3;
    }
    fcptAddColor((_S1007), (make_float4 (seen_1.x, seen_1.y, seen_1.z, 1.0f)));
    Reservoir _S1048 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S1007), (_S1048), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_4, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S1049;
    (&_S1049)->none = none_0;
    (&_S1049)->pdf = pdf_4;
    (&_S1049)->origin = origin_5;
    (&_S1049)->smooth_n = smooth_n_3;
    (&_S1049)->start = start_6;
    return _S1049;
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
    Vertex _S1050;
    (&_S1050)->rough = rough_0;
    (&_S1050)->lobe = lobe_1;
    (&_S1050)->pdf = pdf_5;
    (&_S1050)->cos = cos_0;
    (&_S1050)->inside = inside_0;
    return _S1050;
}

__device__ uint noiseAddress(uint origin_6, uint bounce_0)
{
    uint2  _S1051 = make_uint2 (origin_6 & 2047U, (origin_6 >> 11U) & 2047U);
    uint2  _S1052 = noiseOffset(64U + bounce_0 * 17U);
    uint2  _S1053 = (_S1051 + _S1052) & make_uint2 (2047U);
    return ((_S1053.x) | ((_S1053.y) << 11U)) | ((origin_6 >> 22U) << 22U);
}

static __device__ float freeFlight_0(float u_1, float sigma_0)
{
    return - (F32_log((1.0f - u_1))) / sigma_0;
}

__device__ float upsample(float3  rgb_1, float wavelength_0)
{
    float _S1054 = dot_0(make_float3 (-0.08011700212955475f, 1.08901798725128174f, -0.00889899954199791f), rgb_1);
    float _S1055 = dot_0(make_float3 (0.12177000194787979f, -1.22903203964233398f, 1.10724997520446777f), rgb_1);
    float _S1056 = dot_0(make_float3 (1.17252397537231445f, -1.21603405475616455f, 0.04350199922919273f), rgb_1);
    float3  _S1057 = make_float3 (_S1054, _S1055, _S1056);
    float _S1058 = (wavelength_0 - 0.44999998807907104f) / 0.02999999932944775f;
    float _S1059 = (wavelength_0 - 0.63999998569488525f) / 0.03999999910593033f;
    return _S1054 + _S1055 * (F32_exp((-0.5f * _S1058 * _S1058))) + _S1056 * (F32_exp((-0.5f * _S1059 * _S1059)));
}

__device__ float3  pathColor(float3  f_6, float3  weight_1, float wavelength_1)
{
    float3  _S1060;
    if(wavelength_1 > 0.0f)
    {
        float _S1061 = upsample(f_6, wavelength_1);
        _S1060 = weight_1 * make_float3 (_S1061);
    }
    else
    {
        _S1060 = f_6;
    }
    return _S1060;
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
    float3  _S1062 = exp_0((make_float3 (sigma_1) - extinction_0) * make_float3 (distance_2));
    float3  _S1063 = scatter_0 * _S1062 / make_float3 (sigma_1);
    float3  _S1064 = _slang_select(scatters_0, _S1063,_S1062);
    return _S1064;
}

static __device__ bool scatterSampled_0(bool replay_1, uint b_6, uint stop_0, bool varying_0)
{
    bool _S1065 = !replay_1;
    bool _S1066;
    if(_S1065)
    {
        _S1066 = true;
    }
    else
    {
        bool _S1067 = b_6 == stop_0;
        if(_S1067)
        {
            _S1066 = !varying_0;
        }
        else
        {
            _S1066 = false;
        }
    }
    return _S1066;
}

static __device__ uint arrivalLobe_0(uint b_7, uint prev_lobe_0)
{
    bool _S1068 = b_7 > 0U;
    uint _S1069 = _slang_select(_S1068, prev_lobe_0,3U);
    return _S1069;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_2, uint lobe_2, bool surface_6, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S1070;
    (&_S1070)->extinction_behind = extinction_behind_0;
    (&_S1070)->extinction_front = extinction_front_0;
    (&_S1070)->fillings = fillings_0;
    (&_S1070)->side = side_0;
    (&_S1070)->depth = depth_2;
    (&_S1070)->lobe = lobe_2;
    (&_S1070)->surface = surface_6;
    (&_S1070)->length = length_2;
    (&_S1070)->width = width_1;
    (&_S1070)->own = *own_2;
    (&_S1070)->fiber = fiber_0;
    return _S1070;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S1071 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S1071)
    {
        return 0.07957746833562851f;
    }
    float _S1072 = g_0 * g_0;
    return (1.0f - _S1072) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S1072 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_10, float3  b_8)
{
    float3  _S1073 = a_10 / b_8;
    float3  _S1074 = make_float3 (0.0f);
    bool3  _S1075 = b_8 == _S1074;
    float3  _S1076 = _slang_select(_S1075, _S1074,_S1073);
    return _S1076;
}

__device__ Reservoir withEnd(Reservoir r_7, uint end_type_0, uint end_0, float3  f_7)
{
    Reservoir candidate_2 = r_7;
    uint _S1077 = insertBits_0(r_7.path, end_0, 0U, 5U);
    uint _S1078 = insertBits_0(_S1077, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S1078;
    (&candidate_2)->f = f_7;
    return candidate_2;
}

__device__ float survivalProbability(float3  throughput_0, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_0.x), ((F32_max((throughput_0.y), (throughput_0.z)))))) / density_1), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_10)
{
    Random _S1079 = draw(random_state_10, 11U);
    Random _S1080 = draw(random_state_10, 2147483659U);
    float _S1081 = 1.0f - 2.0f * _S1079.value;
    float _S1082 = (F32_sqrt(((F32_max((1.0f - _S1081 * _S1081), (0.0f))))));
    float _S1083 = 6.28318548202514648f * _S1080.value;
    return make_float3 (_S1082 * (F32_cos((_S1083))), _S1082 * (F32_sin((_S1083))), _S1081);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_10, uint random_state_11, float * pdf_6)
{
    bool _S1084 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1084)
    {
        *pdf_6 = 0.07957746833562851f;
        float3  _S1085 = isotropic_0(random_state_11);
        return _S1085;
    }
    Random _S1086 = draw(random_state_11, 11U);
    Random _S1087 = draw(random_state_11, 2147483659U);
    float _S1088 = g_1 * g_1;
    float _S1089 = 2.0f * g_1;
    float _S1090 = (1.0f - _S1088) / (1.0f - g_1 + _S1089 * _S1086.value);
    float _S1091 = clamp_1((1.0f + _S1088 - _S1090 * _S1090) / _S1089, -1.0f, 1.0f);
    float _S1092 = (F32_sqrt(((F32_max((1.0f - _S1091 * _S1091), (0.0f))))));
    float _S1093 = 6.28318548202514648f * _S1087.value;
    float _S1094 = phaseHG_0(g_1, _S1091);
    *pdf_6 = _S1094;
    float3  _S1095 = tangentToWorld(make_float3 (_S1092 * (F32_cos((_S1093))), _S1091, _S1092 * (F32_sin((_S1093)))), dir_10);
    float3  _S1096 = ((((_S1095)) * make_float3(rnorm3df(((_S1095)).x, ((_S1095)).y, ((_S1095)).z))));
    return _S1096;
}

static __device__ Vertex scatteredVertex_0(bool is_inside_6)
{
    return Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_6);
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_0, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_1, float velvet_0, float3  toon_1, float dispersion_0)
{
    BSDFMaterial _S1097;
    (&_S1097)->albedo = albedo_0;
    (&_S1097)->emissive = emissive_0;
    (&_S1097)->roughness = roughness_0;
    (&_S1097)->metallic = metallic_0;
    (&_S1097)->transmission = transmission_0;
    (&_S1097)->ior = ior_0;
    (&_S1097)->absorption = absorption_0;
    (&_S1097)->specular_tint = specular_tint_0;
    (&_S1097)->specular_level = specular_level_0;
    (&_S1097)->translucent = translucent_0;
    (&_S1097)->sheen = sheen_2;
    (&_S1097)->sheen_roughness = sheen_roughness_0;
    (&_S1097)->anisotropy = anisotropy_0;
    (&_S1097)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1097)->tangent = tangent_1;
    (&_S1097)->velvet = velvet_0;
    (&_S1097)->toon = toon_1;
    (&_S1097)->dispersion = dispersion_0;
    return _S1097;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1098;
    (&_S1098)->scatter = scatter_1;
    (&_S1098)->extinction = extinction_1;
    (&_S1098)->g = g_2;
    return _S1098;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_9, bool skip_0, uint random_state_12, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1099;
    (&_S1099)->smooth_n = smooth_n_4;
    (&_S1099)->geometry_n = geometry_n_2;
    (&_S1099)->geometry_offset = geometry_offset_2;
    (&_S1099)->material = *material_9;
    (&_S1099)->skip = skip_0;
    (&_S1099)->random_state = random_state_12;
    (&_S1099)->coverage = coverage_0;
    (&_S1099)->encloses = encloses_0;
    (&_S1099)->volume = *volume_0;
    (&_S1099)->fills = fills_0;
    (&_S1099)->hair = hair_0;
    return _S1099;
}

static __device__ FKSurface emitting_0(FKSurface * surface_7, bool top_0)
{
    FKSurface lower_0 = *surface_7;
    float3  _S1100 = (&surface_7->material)->emissive;
    float3  _S1101 = make_float3 (0.0f);
    bool _S1102 = !top_0;
    float3  _S1103 = _slang_select(_S1102, _S1101,_S1100);
    (&(&lower_0)->material)->emissive = _S1103;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_8, float u_2)
{
    float _S1104 = surface_8->coverage;
    bool _S1105 = u_2 < _S1104;
    if(_S1105)
    {
        return *surface_8;
    }
    float3  _S1106 = make_float3 (0.0f);
    float3  _S1107 = make_float3 (1.0f);
    BSDFMaterial _S1108 = Material_x24init_0(_S1106, _S1106, 0.0f, 0.0f, 0.0f, 0.0f, _S1106, _S1107, 1.0f, _S1106, _S1106, 0.5f, 0.0f, 0.0f, _S1106, 0.0f, _S1106, 0.0f);
    BSDFMaterial material_10 = _S1108;
    (&material_10)->albedo = _S1107;
    (&material_10)->emissive = (&surface_8->material)->emissive;
    (&material_10)->transmission = 1.0f;
    (&material_10)->ior = 1.0f;
    (&material_10)->absorption = (&surface_8->material)->absorption;
    FKSurface through_0 = *surface_8;
    (&through_0)->material = material_10;
    return through_0;
}

__device__ float facingSign(float transmission_1, float3  face_0, float3  direction_0)
{
    bool _S1109 = transmission_1 > 0.0f;
    bool _S1110;
    if(_S1109)
    {
        _S1110 = true;
    }
    else
    {
        _S1110 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1111;
    if(_S1110)
    {
        _S1111 = 1.0f;
    }
    else
    {
        _S1111 = -1.0f;
    }
    return _S1111;
}

static __device__ bool arrivesBehind_0(float3  dir_11, float3  n_8)
{
    return (dot_0(dir_11, n_8)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_9, float3  dir_12)
{
    float3  _S1112 = surface_9->geometry_n;
    float _S1113 = facingSign((&surface_9->material)->transmission, surface_9->geometry_n, dir_12);
    FKSurface faced_0 = *surface_9;
    float3  _S1114 = surface_9->smooth_n * make_float3 (_S1113);
    (&faced_0)->smooth_n = _S1114;
    float3  _S1115 = _S1112 * make_float3 (_S1113);
    (&faced_0)->geometry_n = _S1115;
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
    float3  _S1116 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1116));
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
    bool _S1117;
    if(open_0)
    {
        _S1117 = prev_rough_0;
    }
    else
    {
        _S1117 = false;
    }
    if(_S1117)
    {
        _S1117 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S1117 = false;
    }
    return _S1117;
}

__device__ bool dispersive(BSDFMaterial material_11)
{
    bool _S1118 = (material_11.dispersion) > 0.0f;
    bool _S1119;
    if(_S1118)
    {
        _S1119 = (material_11.ior) != 1.0f;
    }
    else
    {
        _S1119 = false;
    }
    return _S1119;
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
        uint _S1120 = (low_1 + high_1 + 1U) / 2U;
        bool _S1121 = (WAVELENGTH_CDF_0[_S1120]) <= u_3;
        if(_S1121)
        {
            low_1 = _S1120;
        }
        else
        {
            uint _S1122 = _S1120 - 1U;
            high_1 = _S1122;
        }
    }
    uint _S1123 = low_1;
    float _S1124 = WAVELENGTH_CDF_0[low_1 + 1U] - WAVELENGTH_CDF_0[low_1];
    return make_float2 (0.37999999523162842f + 0.00499999988824129f * (float(low_1) + (u_3 - WAVELENGTH_CDF_0[_S1123]) / _S1124), _S1124 / 0.00499999988824129f);
}

__device__ static const FixedArray<float, 243>  WAVELENGTH_WEIGHTS_0 = { {
    0.00547470012679696f, -0.00465690018609166f, 0.03257500007748604f, 0.00934640038758516f, -0.00796370021998882f, 0.05577300116419792f, 0.01846100017428398f, -0.01579399965703487f, 0.11072999984025955f, 0.0416410006582737f, -0.03577499836683273f, 0.2513900101184845f, 0.09349299967288971f, -0.08071800321340561f, 0.56742000579833984f, 0.1585099995136261f, -0.13764999806880951f, 0.97018998861312866f, 0.30943000316619873f, -0.27083000540733337f, 1.91740000247955322f, 0.55217999219894409f, -0.48754000663757324f, 3.46889996528625488f, 0.95016998052597046f, -0.84802001714706421f, 6.09439992904663086f, 1.42110002040863037f, -1.28929996490478516f, 9.45199966430664062f, 1.73409998416900635f, -1.6062999963760376f, 12.12800025939941406f, 2.08030009269714355f, -1.98810005187988281f, 15.68700027465820312f, 2.20600008964538574f, -2.20120000839233398f, 18.47699928283691406f, 2.03040003776550293f, -2.17700004577636719f, 19.92700004577636719f, 1.63429999351501465f, -2.00340008735656738f, 20.86899948120117188f, 0.99410998821258545f, -1.62629997730255127f, 20.57799911499023438f, 0.20011000335216522f, -1.11409997940063477f, 19.72100067138671875f, -0.67960000038146973f, -0.45403000712394714f, 17.77599906921386719f, -1.61679995059967041f, 0.37860000133514404f, 14.71500015258789062f, -2.53410005569458008f, 1.27540004253387451f, 11.86499977111816406f, -3.39079999923706055f, 2.2146000862121582f, 9.17669963836669922f, -4.03749990463256836f, 3.0522000789642334f, 6.59509992599487305f, -4.61299991607666016f, 3.89779996871948242f, 4.64589977264404297f, -5.43039989471435547f, 5.0121002197265625f, 3.3199000358581543f, -6.37769985198974609f, 6.33809995651245117f, 2.29699993133544922f, -7.44140005111694336f, 7.91739988327026367f, 1.45389997959136963f, -8.38580036163330078f, 9.60109996795654297f, 0.66465997695922852f, -9.0167999267578125f, 11.23999977111816406f, -0.04403600096702576f, -9.17749977111816406f, 12.63199996948242188f, -0.58126997947692871f, -8.97550010681152344f, 13.91499996185302734f, -0.95730000734329224f, -8.25290012359619141f, 14.86200046539306641f, -1.24430000782012939f, -6.92129993438720703f, 15.03899955749511719f, -1.43069994449615479f, -5.29169988632202148f, 14.90900039672851562f, -1.55149996280670166f, -3.43219995498657227f, 14.70499992370605469f, -1.63569998741149902f, -1.27190005779266357f, 14.24400043487548828f, -1.67030000686645508f, 1.15170001983642578f, 13.32199954986572266f, -1.636199951171875f, 3.73889994621276855f, 12.21199989318847656f, -1.56920003890991211f, 6.43590021133422852f, 10.94699954986572266f, -1.47730004787445068f, 9.16440010070800781f, 9.54769992828369141f, -1.36399996280670166f, 12.02000045776367188f, 8.18799972534179688f, -1.25450003147125244f, 14.78699970245361328f, 6.74429988861083984f, -1.13110005855560303f, 16.72299957275390625f, 5.08780002593994141f, -0.96561002731323242f, 18.14299964904785156f, 3.57019996643066406f, -0.80725997686386108f, 19.91900062561035156f, 2.36269998550415039f, -0.69273000955581665f, 21.05500030517578125f, 1.31369996070861816f, -0.58597999811172485f, 21.3899993896484375f, 0.42390000820159912f, -0.48298001289367676f, 20.99300003051757812f, -0.23857000470161438f, -0.39412000775337219f, 19.82200050354003906f, -0.6866300106048584f, -0.31501999497413635f, 18.12000083923339844f, -0.9412500262260437f, -0.24890999495983124f, 15.7089996337890625f, -1.02020001411437988f, -0.19076000154018402f, 13.19799995422363281f, -0.98919999599456787f, -0.14401000738143921f, 11.23999977111816406f, -0.93347001075744629f, -0.11133000254631042f, 9.36649990081787109f, -0.83820998668670654f, -0.08524099737405777f, 7.41249990463256836f, -0.70064002275466919f, -0.06283199787139893f, 5.71229982376098633f, -0.56079000234603882f, -0.04586699977517128f, 4.42280006408691406f, -0.44653001427650452f, -0.03396600112318993f, 3.34489989280700684f, -0.34457001090049744f, -0.02482499927282333f, 2.49309992790222168f, -0.26017999649047852f, -0.01808100007474422f, 1.82239997386932373f, -0.1921599954366684f, -0.01296999957412481f, 1.29499995708465576f, -0.13766999542713165f, -0.00907570030540228f, 0.92928999662399292f, -0.09956400096416473f, -0.00641620019450784f, 0.61835998296737671f, -0.06671299785375595f, -0.00421149982139468f, 0.40211999416351318f, -0.04354599863290787f, -0.00271830009296536f, 0.2844499945640564f, -0.03087200038135052f, -0.00191440002527088f, 0.20672999322414398f, -0.02246100082993507f, -0.00138829997740686f, 0.15044000744819641f, -0.01634499989449978f, -0.00101030000951141f, 0.10942000150680542f, -0.01188699994236231f, -0.0007347899954766f, 0.07099699974060059f, -0.00771349994465709f, -0.00047679000999779f, 0.04539500176906586f, -0.00493190018460155f, -0.00030484999297187f, 0.03424099832773209f, -0.00372010003775358f, -0.00022995000472292f, 0.02557599917054176f, -0.00277870008721948f, -0.00017175999528263f, 0.01842200011014938f, -0.00200140010565519f, -0.0001237099932041f, 0.01316899992525578f, -0.00143079995177686f, -0.00008843900286593f, 0.00838890019804239f, -0.00091141002485529f, -0.00005633700129692f, 0.00537079991772771f, -0.00058350997278467f, -0.00003606799873523f, 0.00328280008397996f, -0.00035665999166667f, -0.00002204600059486f, 0.00196009990759194f, -0.00021296000340953f, -0.00001316300040344f, 0.00168939994182438f, -0.00018354000349063f, -0.00001134499962063f, 0.00141050003003329f, -0.00015325000276789f, -0.00000947250009631f, 0.00097123999148607f, -0.00010551999730524f, -6.52239987175562419e-06f, 0.00066868000430986f, -0.00007264900341397f, -4.49060007667867467e-06f
} };
__device__ float3  wavelengthWeights(float wavelength_2)
{
    float _S1125 = clamp_1((wavelength_2 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    uint _S1126 = (U32_min((uint(_S1125)), (79U)));
    uint _S1127 = 3U * _S1126;
    float3  _S1128 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1127], WAVELENGTH_WEIGHTS_0[_S1127 + 1U], WAVELENGTH_WEIGHTS_0[_S1127 + 2U]);
    float3  _S1129 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1127 + 3U], WAVELENGTH_WEIGHTS_0[_S1127 + 4U], WAVELENGTH_WEIGHTS_0[_S1127 + 5U]);
    return _S1128 + (_S1129 - _S1128) * make_float3 (_S1125 - float(_S1126));
}

__device__ BSDFMaterial atWavelength(BSDFMaterial material_12, float wavelength_3)
{
    BSDFMaterial at_0 = material_12;
    float _S1130 = upsample(material_12.albedo, wavelength_3);
    float3  _S1131 = make_float3 (_S1130);
    (&at_0)->albedo = _S1131;
    float _S1132 = upsample(material_12.emissive, wavelength_3);
    float3  _S1133 = make_float3 (_S1132);
    (&at_0)->emissive = _S1133;
    float _S1134 = upsample(material_12.absorption, wavelength_3);
    float3  _S1135 = make_float3 (_S1134);
    (&at_0)->absorption = _S1135;
    float _S1136 = upsample(material_12.specular_tint, wavelength_3);
    float3  _S1137 = make_float3 (_S1136);
    (&at_0)->specular_tint = _S1137;
    float _S1138 = upsample(material_12.translucent, wavelength_3);
    float3  _S1139 = make_float3 (_S1138);
    (&at_0)->translucent = _S1139;
    float _S1140 = upsample(material_12.sheen, wavelength_3);
    float3  _S1141 = make_float3 (_S1140);
    (&at_0)->sheen = _S1141;
    return at_0;
}

__device__ float dispersedIor(float ior_1, float dispersion_1, float wavelength_4)
{
    float _S1142 = (ior_1 - 1.0f) * dispersion_1 / 1.90962409973144531f;
    float _S1143 = _S1142 * (1.0f / (wavelength_4 * wavelength_4) - 2.89662933349609375f);
    bool _S1144 = dispersion_1 > 0.0f;
    float _S1145 = _slang_select(_S1144, _S1143,0.0f);
    return ior_1 + _S1145;
}

__device__ float2  vertexEta(BSDFMaterial material_13, float n_dot_v_0)
{
    bool _S1146 = n_dot_v_0 < 0.0f;
    float _S1147 = _slang_select(_S1146, material_13.ior,1.0f);
    float _S1148 = _slang_select(_S1146, 1.0f,material_13.ior);
    return make_float2 (_S1147, _S1148);
}

__device__ float2  wavelengthEta(BSDFMaterial material_14, float n_dot_v_1, float wavelength_5)
{
    BSDFMaterial refractive_0 = material_14;
    float _S1149 = dispersedIor(material_14.ior, material_14.dispersion, wavelength_5);
    bool _S1150 = wavelength_5 > 0.0f;
    float _S1151 = _slang_select(_S1150, _S1149,material_14.ior);
    (&refractive_0)->ior = _S1151;
    float2  _S1152 = vertexEta(refractive_0, n_dot_v_1);
    return _S1152;
}

__device__ bool neeDecision(BSDFMaterial material_15, float n_dot_v_2, float eta_i_5, float eta_o_5)
{
    float _S1153 = fresnel((F32_abs((n_dot_v_2))), eta_i_5, eta_o_5);
    float3  _S1154 = mix_0(make_float3 (_S1153), material_15.albedo, material_15.metallic);
    float _S1155 = rgb_to_greyscale(_S1154);
    float _S1156 = (F32_max(((1.0f - _S1155) * (1.0f - material_15.metallic) * (1.0f - material_15.transmission)), (0.0f)));
    bool _S1157 = _S1156 > 0.03999999910593033f;
    bool _S1158;
    if(_S1157)
    {
        _S1158 = true;
    }
    else
    {
        _S1158 = (material_15.roughness) > 0.20000000298023224f;
    }
    return _S1158;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_16)
{
    float _S1159 = rgb_to_greyscale(material_16->translucent);
    return _S1159 > 0.0f;
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
    MediumSides _S1160;
    (&_S1160)->behind = *behind_0;
    (&_S1160)->front = *front_0;
    (&_S1160)->fillings = fillings_1;
    (&_S1160)->face = face_1;
    return _S1160;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_10, FKMedium * medium_0, uint filling_0, float3  dir_13, FKMedium * outside_0)
{
    float3  _S1161 = surface_10->geometry_n;
    MediumSides _S1162 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_10->geometry_n);
    MediumSides sides_0 = _S1162;
    bool _S1163 = surface_10->encloses;
    if(_S1163)
    {
        (&sides_0)->behind = surface_10->volume;
        *&((&(&sides_0)->fillings)->x) = surface_10->fills;
        bool _S1164 = (dot_0(dir_13, _S1161)) > 0.0f;
        if(_S1164)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_11, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_14, uint depth_3, uint lobe_3, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1165 = surface_11->geometry_n;
    ShadowContext _S1166 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_11->geometry_n, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
    bool _S1167 = surface_11->encloses;
    ShadowContext context_4;
    if(_S1167)
    {
        FKSurface faced_1 = *surface_11;
        float3  _S1168 = - _S1165;
        float3  _S1169 = _slang_select(turned_0, _S1168,_S1165);
        (&faced_1)->geometry_n = _S1169;
        FKMedium _S1170 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1171 = faced_1;
        FKMedium _S1172 = _S1170;
        MediumSides _S1173 = mediumSides_0(&_S1171, &_S1172, filling_1, dir_14, outside_1);
        ShadowContext _S1174 = ShadowContext_x24init_0(_S1173.behind.extinction, _S1173.front.extinction, _S1173.fillings, _S1165, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
        if(turned_0)
        {
            uint2  _S1175 = _S1173.fillings;
            ShadowContext _S1176 = ShadowContext_x24init_0(_S1173.front.extinction, _S1173.behind.extinction, uint2 {_S1175.y, _S1175.x}, _S1165, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
            context_4 = _S1176;
        }
        else
        {
            context_4 = _S1174;
        }
    }
    else
    {
        context_4 = _S1166;
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

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_8, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_4, BSDFMaterial * material_17, float eta_i_6, float eta_o_6, bool competing_1, uint random_state_13)
{
    float3  _S1177 = light_2->dir;
    bool _S1178 = (dot_0(geometry_n_4, - in_dir_8) * dot_0(geometry_n_4, light_2->dir)) <= 0.0f;
    FixedArray<float3 , 5>  throughputs_1;
    FixedArray<float, 5>  pdfs_4;
    float3  _S1179 = BSDF(in_dir_8, _S1177, smooth_n_5, *material_17, eta_i_6, eta_o_6, _S1178, random_state_13, &throughputs_1, &pdfs_4);
    bool _S1180 = !competing_1;
    bool _S1181;
    if(_S1180)
    {
        _S1181 = true;
    }
    else
    {
        _S1181 = (light_2->density) == 0.0f;
    }
    if(_S1181)
    {
        return _S1179 * light_2->radiance;
    }
    float3  _S1182 = make_float3 (0.0f);
    uint i_26 = 0U;
    float3  weighted_0 = _S1182;
    for(;;)
    {
        if(i_26 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S1183 = (pdfs_4[i_26]) > 0.0f;
        if(_S1183)
        {
            float _S1184 = light_2->density;
            float _S1185 = pdfs_4[i_26] / light_2->density;
            float3  weighted_1 = weighted_0 + throughputs_1[i_26] * make_float3 (pdfs_4[i_26]) / make_float3 (_S1184 * (1.0f + _S1185 * _S1185));
            weighted_0 = weighted_1;
        }
        uint i_27 = i_26 + 1U;
        i_26 = i_27;
    }
    return weighted_0 * light_2->radiance * make_float3 (light_2->density);
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_1, uint random_state_14, bool refracted_3, uint lobe_4, float pdf_7)
{
    SampleBSDF _S1186;
    (&_S1186)->unit_direction = unit_direction_1;
    (&_S1186)->throughput = throughput_1;
    (&_S1186)->random_state = random_state_14;
    (&_S1186)->refracted = refracted_3;
    (&_S1186)->lobe = lobe_4;
    (&_S1186)->pdf = pdf_7;
    return _S1186;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  v_8, float3  n_i_11, float n_i_dot_v_3, BSDFMaterial material_18, Weights w_14, uint random_state_15)
{
    float3  _S1187 = make_float3 (1.0f);
    SampleBSDF _S1188 = SampleBSDF_x24init_0(_S1187, _S1187, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S1188;
    Random _S1189 = draw(random_state_15, 3U);
    Random _S1190 = draw(random_state_15, 2147483651U);
    (&sample_1)->random_state = _S1190.state;
    float _S1191 = _S1189.value;
    float _S1192 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1191 * _S1191))))));
    float _S1193 = 6.28318548202514648f * _S1190.value;
    float3  _S1194 = tangentToWorld(make_float3 (_S1192 * (F32_cos((_S1193))), _S1189.value, _S1192 * (F32_sin((_S1193)))), n_i_11);
    (&sample_1)->unit_direction = _S1194;
    (&sample_1)->lobe = 4U;
    float3  _S1195 = sheenVelvetBSDF((&sample_1)->unit_direction, v_8, n_i_11, material_18, w_14);
    (&sample_1)->throughput = _S1195;
    float _S1196 = sheenVelvetPDF(_S1189.value, n_i_dot_v_3, w_14);
    (&sample_1)->pdf = _S1196;
    return sample_1;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1197 = (F32_sqrt((random_1_0)));
    float _S1198 = 6.28318548202514648f * random_2_0;
    float _S1199 = _S1197 * (F32_cos((_S1198)));
    float _S1200 = _S1197 * (F32_sin((_S1198)));
    float _S1201 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1199 * _S1199 - _S1200 * _S1200))))));
    return make_float3 (_S1199, _S1201, _S1200);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_4, float3  n_i_12, float n_i_dot_v_4, BSDFMaterial material_19, Weights w_15, uint random_state_16)
{
    float3  _S1202 = make_float3 (1.0f);
    SampleBSDF _S1203 = SampleBSDF_x24init_0(_S1202, _S1202, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S1203;
    Random _S1204 = draw(random_state_16, 3U);
    Random _S1205 = draw(random_state_16, 2147483651U);
    (&sample_2)->random_state = _S1205.state;
    float3  _S1206 = sampleCosWeightedHemisphere(_S1204.value, _S1205.value);
    float _S1207 = translucentShare(material_19);
    bool _S1208 = u_4 < (w_15.p_diffuse * _S1207);
    float _S1209 = _S1206.y;
    float _S1210 = - _S1209;
    float _S1211 = _slang_select(_S1208, _S1210,_S1209);
    float3  _S1212 = tangentToWorld(make_float3 (_S1206.x, _S1211, _S1206.z), n_i_12);
    (&sample_2)->unit_direction = _S1212;
    (&sample_2)->refracted = _S1208;
    (&sample_2)->lobe = 0U;
    float3  _S1213 = diffuseBSDF((&sample_2)->unit_direction, n_i_12, material_19, w_15);
    (&sample_2)->throughput = _S1213;
    float _S1214 = diffusePDF(_S1211, n_i_dot_v_4, material_19, w_15);
    (&sample_2)->pdf = _S1214;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF toonSample(float3  n_i_13, ToonShape shape_2, Weights w_16, uint random_state_17)
{
    float3  _S1215 = make_float3 (1.0f);
    SampleBSDF _S1216 = SampleBSDF_x24init_0(_S1215, _S1215, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S1216;
    Random _S1217 = draw(random_state_17, 3U);
    Random _S1218 = draw(random_state_17, 2147483651U);
    (&sample_3)->random_state = _S1218.state;
    float _S1219 = _S1217.value * shape_2.norm / 6.28318548202514648f;
    float t_21;
    if(shape_2.glossy)
    {
        t_21 = (F32_acos((clamp_1(1.0f - _S1219, -1.0f, 1.0f))));
    }
    else
    {
        t_21 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1219)))), (1.0f))))));
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
        float _S1220;
        if(t_21 < (shape_2.a))
        {
            _S1220 = 1.0f;
        }
        else
        {
            _S1220 = (F32_max((1.0f - (t_21 - shape_2.a) / (F32_max((shape_2.s), (0.0000152587890625f)))), (0.0f)));
        }
        float integral_2;
        if(shape_2.glossy)
        {
            integral_2 = 1.0f - (F32_cos(((F32_min((t_21), (shape_2.a))))));
        }
        else
        {
            float _S1221 = (F32_sin(((F32_min((t_21), (shape_2.a))))));
            integral_2 = _S1221 * _S1221 / 2.0f;
        }
        bool _S1222 = t_21 > (shape_2.a);
        bool _S1223;
        if(_S1222)
        {
            _S1223 = (shape_2.s) > 0.0f;
        }
        else
        {
            _S1223 = false;
        }
        float integral_3;
        if(_S1223)
        {
            if(shape_2.glossy)
            {
                float _S1224 = (F32_cos((shape_2.a)));
                float _S1225 = (F32_cos((t_21)));
                integral_3 = (1.0f + shape_2.a / shape_2.s) * (_S1224 - _S1225) - ((F32_sin((t_21))) - t_21 * _S1225 - ((F32_sin((shape_2.a))) - shape_2.a * _S1224)) / shape_2.s;
            }
            else
            {
                float _S1226 = 2.0f * shape_2.a;
                float _S1227 = (F32_cos((_S1226)));
                float _S1228 = 2.0f * t_21;
                float _S1229 = (F32_cos((_S1228)));
                integral_3 = (1.0f + shape_2.a / shape_2.s) * (_S1227 - _S1229) / 4.0f - ((F32_sin((_S1228))) / 8.0f - t_21 * _S1229 / 4.0f - ((F32_sin((_S1226))) / 8.0f - shape_2.a * _S1227 / 4.0f)) / shape_2.s;
            }
            float integral_4 = integral_2 + integral_3;
            integral_3 = integral_4;
        }
        else
        {
            integral_3 = integral_2;
        }
        float _S1230 = _S1220 * (F32_sin((t_21)));
        float _S1231;
        if(shape_2.glossy)
        {
            _S1231 = 1.0f;
        }
        else
        {
            _S1231 = (F32_cos((t_21)));
        }
        float _S1232 = _S1230 * _S1231;
        float _S1233 = (integral_3 - _S1219) / _S1232;
        bool _S1234 = _S1232 > 0.0f;
        float _S1235 = _slang_select(_S1234, _S1233,0.0f);
        float _S1236 = clamp_1(t_21 - _S1235, 0.0f, shape_2.b);
        int k_3 = k_2 + int(1);
        t_21 = _S1236;
        k_2 = k_3;
    }
    float _S1237 = 6.28318548202514648f * _S1218.value;
    float _S1238 = (F32_sin((t_21)));
    float3  _S1239 = tangentToWorld(make_float3 (_S1238 * (F32_cos((_S1237))), (F32_cos((t_21))), _S1238 * (F32_sin((_S1237)))), shape_2.axis);
    (&sample_3)->unit_direction = _S1239;
    bool _S1240 = (dot_0(n_i_13, (&sample_3)->unit_direction)) < 0.0f;
    (&sample_3)->refracted = _S1240;
    (&sample_3)->lobe = 6U;
    float3  _S1241 = toonBSDF((&sample_3)->unit_direction, n_i_13, shape_2, w_16);
    (&sample_3)->throughput = _S1241;
    float _S1242 = toonPDF(dot_0(n_i_13, (&sample_3)->unit_direction), dot_0((&sample_3)->unit_direction, shape_2.axis), shape_2, w_16);
    (&sample_3)->pdf = _S1242;
    return sample_3;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_14, float alpha_8, AnisotropicFrame frame_6, BSDFMaterial material_20, Weights w_17, float pdf_h_3, float eta_i_7, float eta_o_7, uint random_state_18)
{
    float3  _S1243 = make_float3 (1.0f);
    SampleBSDF _S1244 = SampleBSDF_x24init_0(_S1243, _S1243, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S1244;
    (&sample_4)->unit_direction = w_17.refracted;
    (&sample_4)->random_state = random_state_18;
    (&sample_4)->refracted = true;
    (&sample_4)->lobe = 1U;
    float3  _S1245 = refractBSDF((&sample_4)->unit_direction, n_i_14, alpha_8, frame_6, material_20, w_17);
    (&sample_4)->throughput = _S1245;
    float _S1246 = refractPDF(dot_0((&sample_4)->unit_direction, ggx_n_3), pdf_h_3, w_17, eta_i_7, eta_o_7);
    (&sample_4)->pdf = _S1246;
    return sample_4;
}

static __device__ float3  reflect_0(float3  i_28, float3  n_9)
{
    return i_28 - make_float3 (2.0f * dot_0(n_9, i_28)) * n_9;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_9, float3  ggx_n_4, float3  n_i_15, float alpha_9, AnisotropicFrame frame_7, Weights w_18, float pdf_h_4, uint random_state_19)
{
    float3  _S1247 = make_float3 (1.0f);
    SampleBSDF _S1248 = SampleBSDF_x24init_0(_S1247, _S1247, 0U, false, 0U, 0.0f);
    SampleBSDF sample_5 = _S1248;
    float3  _S1249 = reflect_0(in_dir_9, ggx_n_4);
    float3  _S1250 = ((((_S1249)) * make_float3(rnorm3df(((_S1249)).x, ((_S1249)).y, ((_S1249)).z))));
    (&sample_5)->unit_direction = _S1250;
    (&sample_5)->random_state = random_state_19;
    (&sample_5)->lobe = 2U;
    float3  _S1251 = reflectBSDF((&sample_5)->unit_direction, n_i_15, alpha_9, frame_7, w_18);
    (&sample_5)->throughput = _S1251;
    float _S1252 = reflectPDF(pdf_h_4, w_18);
    (&sample_5)->pdf = _S1252;
    return sample_5;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_10, float3  n_10, BSDFMaterial material_21, float eta_i_8, float eta_o_8, uint random_init_0, float2  screen_space_0)
{
    uint random_state_20 = random_init_0;
    float3  _S1253 = negate_0(in_dir_10);
    float _S1254 = dot_0(n_10, _S1253);
    float _S1255 = sign_0(_S1254);
    float3  n_i_16 = n_10 * make_float3 (_S1255);
    float _S1256 = (F32_abs((_S1254)));
    float _S1257 = material_21.roughness;
    float _S1258 = _S1257 * _S1257;
    AnisotropicFrame _S1259 = anisotropicFrame(material_21, n_i_16);
    float3  _S1260 = sampleHalfVector(_S1253, n_i_16, _S1258, _S1259, &random_state_20);
    Weights _S1261 = lobeWeights(in_dir_10, _S1253, n_i_16, _S1260, _S1259, material_21, eta_i_8, eta_o_8);
    Random _S1262 = draw(random_state_20, 2U);
    random_state_20 = _S1262.state;
    bool _S1263 = (_S1262.value) < (_S1261.p_sheen_velvet);
    if(_S1263)
    {
        SampleBSDF _S1264 = sheenVelvetSample(_S1253, n_i_16, _S1256, material_21, _S1261, random_state_20);
        return _S1264;
    }
    float _S1265 = _S1262.value - _S1261.p_sheen_velvet;
    bool _S1266 = _S1265 < (_S1261.p_diffuse);
    if(_S1266)
    {
        SampleBSDF _S1267 = diffuseSample(_S1265, n_i_16, _S1256, material_21, _S1261, random_state_20);
        return _S1267;
    }
    bool _S1268 = _S1265 < (_S1261.p_diffuse + _S1261.p_toon);
    if(_S1268)
    {
        ToonShape _S1269 = toonShape(_S1253, n_i_16, material_21);
        SampleBSDF _S1270 = toonSample(n_i_16, _S1269, _S1261, random_state_20);
        return _S1270;
    }
    float _S1271 = vndfPDF(_S1253, _S1260, n_i_16, _S1256, _S1258, _S1259, _S1261.v_dot_h);
    bool _S1272 = (_S1265 - _S1261.p_toon) < (_S1261.p_diffuse + _S1261.p_refract);
    if(_S1272)
    {
        SampleBSDF _S1273 = refractSample(_S1260, n_i_16, _S1258, _S1259, material_21, _S1261, _S1271, eta_i_8, eta_o_8, random_state_20);
        return _S1273;
    }
    SampleBSDF _S1274 = reflectSample(in_dir_10, _S1260, n_i_16, _S1258, _S1259, _S1261, _S1271, random_state_20);
    return _S1274;
}

__device__ bool withinInverseFootprint(float pdf_8, bool diffuse_0, float prev_cos_0, float distance_5, float threshold_1)
{
    bool _S1275 = pdf_8 > 0.0f;
    bool _S1276;
    if(_S1275)
    {
        if(diffuse_0)
        {
            _S1276 = true;
        }
        else
        {
            _S1276 = (pdf_8 * prev_cos_0 / (distance_5 * distance_5) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S1276 = false;
    }
    return _S1276;
}

__device__ bool roughLobe(float pdf_9, bool diffuse_1, float roughness_1)
{
    bool _S1277 = pdf_9 > 0.0f;
    bool _S1278;
    if(_S1277)
    {
        if(diffuse_1)
        {
            _S1278 = true;
        }
        else
        {
            _S1278 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S1278 = false;
    }
    return _S1278;
}

static __device__ bool passesLayer_0(uint layers_0, bool refracting_0, bool passed_0)
{
    bool _S1279 = layers_0 > 1U;
    bool _S1280;
    if(_S1279)
    {
        _S1280 = refracting_0 != passed_0;
    }
    else
    {
        _S1280 = false;
    }
    return _S1280;
}

static __device__ float widened_0(float spread_1, float pdf_10, bool delta_0)
{
    float _S1281 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * pdf_10))))), (3.14159274101257324f)));
    bool _S1282 = !delta_0;
    float _S1283 = _slang_select(_S1282, _S1281,0.0f);
    return spread_1 + _S1283;
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
    bool _S1284;
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
    int _S1285;
    Shift ended_0;
    float density_3;
    float spread_3;
    float width_4;
    float sky_pdf_1;
    float spread_4;
    float width_5;
    uint b_10;
    float3  _S1286 = make_float3 (0.0f);
    Shift _S1287 = Shift_x24init_0(_S1286, 0.0f);
    uint _S1288 = r_8->path;
    uint _S1289 = extractBits_0(r_8->path, 0U, 5U);
    uint _S1290 = extractBits_0(_S1288, 5U, 5U);
    uint _S1291 = extractBits_0(_S1288, 10U, 2U);
    uint _S1292 = extractBits_0(_S1288, 12U, 3U);
    bool passes_0;
    if(replay_2)
    {
        bool _S1293 = _S1292 >= 3U;
        uint _S1294 = _slang_select(_S1293, 1U,0U);
        uint _S1295 = _S1289 + _S1294;
        uint _S1296 = (fcptMaxBounces());
        passes_0 = _S1295 > _S1296;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1287;
    }
    uint _S1297 = _S1290 - 1U;
    bool _S1298 = _S1292 == 3U;
    uint _S1299 = _slang_select(_S1298, 1U,0U);
    uint _S1300 = _S1289 + _S1299;
    bool _S1301 = _S1291 == 0U;
    uint _S1302 = _slang_select(_S1301, _S1300,_S1297);
    FKHit _S1303 = (fcptReservoirHit((*r_8)));
    float3  _S1304 = dom_7->x0;
    float3  _S1305 = dom_7->x1 - dom_7->x0;
    float3  _S1306 = ((((_S1305)) * make_float3(rnorm3df(((_S1305)).x, ((_S1305)).y, ((_S1305)).z))));
    FKRay _S1307 = Ray_x24init_0(dom_7->x1, _S1306);
    FKRay ray_2 = _S1307;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1286;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_2 = throughput_3;
    float3  glowed_0 = _S1286;
    float3  extinction_in_0 = _S1286;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1308 = dom_7->spread;
    float _S1309 = dom_7->width;
    float _S1310 = length_0(_S1305);
    NEEVertex _S1311 = NEEVertex_x24init_0(true, 0.0f, _S1286, _S1286, _S1286);
    NEEVertex nee_vertex_0 = _S1311;
    Vertex _S1312 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S1312;
    Reservoir _S1313 = (Reservoir{});
    Reservoir chain_0 = _S1313;
    uint _S1314 = r_8->seed;
    (&chain_0)->seed = r_8->seed;
    uint _S1315 = extractBits_0(_S1288, 24U, 8U);
    uint _S1316 = insertBits_0(0U, _S1315, 24U, 8U);
    (&chain_0)->path = _S1316;
    (&ray_2)->origin = _S1304;
    (&hit_4)->distance = _S1310;
    FKMedium _S1317 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1318 = filling_2;
    bool _S1319 = (fcptVaryingUsed());
    uint _S1320 = _slang_select(_S1319, _S1318,4294967295U);
    filling_2 = _S1320;
    scatter_in_0 = _S1317.scatter;
    extinction_in_0 = _S1317.extinction;
    g_in_0 = _S1317.g;
    Reservoir _S1321 = chain_0;
    uint _S1322 = filling_2;
    for(;;)
    {
        bool _S1323 = (fcptVaryingUsed());
        if(_S1323)
        {
            passes_0 = _S1322 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1324 = (fcptMajorant((_S1322)));
            spread_2 = _S1324;
        }
        else
        {
            spread_2 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_2)
        {
            turned_1 = 4294967295U == _S1302;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1291 == 1U;
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
            ended_0 = _S1287;
            sky_pdf_0 = 0.0f;
            spread_2 = _S1308;
            width_3 = _S1309;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_9 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1325 = (&prev_0)->rough;
        if(_S1325)
        {
            turned_1 = !(spread_2 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S1326 = stream(_S1314, 384U);
        uint tracking_0 = _S1326;
        weight_2 = throughput_3;
        glowed_0 = _S1286;
        b_9 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        wavelength_6 = _S1308;
        width_3 = _S1309;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1285 = int(1);
                break;
            }
            uint _S1327 = noiseAddress(_S1314, b_9);
            Random _S1328 = draw(_S1327, 10U);
            float _S1329 = freeFlight_0(_S1328.value, spread_2);
            if(passes_0)
            {
                float3  _S1330 = (&ray_2)->origin;
                float3  _S1331 = (&ray_2)->unit_direction;
                float _S1332 = (&hit_4)->distance;
                bool _S1333 = b_9 == 4294967295U;
                uint _S1334 = _slang_select(_S1333, 0U,b_9);
                uint _S1335 = (&prev_0)->lobe;
                uint _S1336 = _slang_select(_S1333, 3U,_S1335);
                float _S1337 = (fcptTrackMedium((_S1322), (_S1330), (_S1331), (_S1332), (&tracking_0), (&weight_2), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1334), (_S1336), (_S1333)));
                threshold_2 = _S1337;
            }
            else
            {
                threshold_2 = _S1329;
            }
            bool _S1338 = !(threshold_2 < ((&hit_4)->distance));
            if(_S1338)
            {
                _S1285 = int(1);
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
                float3  _S1339 = pathColor(throughput_2 * glowed_0, throughput_3, 0.0f);
                float3  _S1340 = _S1339 / make_float3 (density_2);
                float3  _S1341 = sel_7->glow + _S1340;
                sel_7->glow = _S1341;
            }
            else
            {
            }
            glowed_0 = _S1286;
            uint b_11 = b_9 + 1U;
            float3  _S1342 = (&ray_2)->origin + make_float3 (threshold_2) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1342;
            float3  _S1343 = flightWeight_0(scatter_in_0, extinction_in_0, spread_2, threshold_2, true);
            float3  _S1344 = weight_2;
            float _S1345 = upsample(weight_2, 0.0f);
            float3  _S1346 = make_float3 (_S1345);
            float3  _S1347 = _slang_select(false, _S1346,_S1344);
            float3  _S1348 = _slang_select(passes_0, _S1347,_S1343);
            float3  throughput_4 = throughput_2 * _S1348;
            uint _S1349 = stream(_S1314, b_11 + 320U);
            tracking_0 = _S1349;
            weight_2 = throughput_3;
            float width_6 = width_3 + wavelength_6 * threshold_2;
            float _S1350 = wavelength_6 + 3.14159274101257324f;
            bool _S1351 = scatterSampled_0(replay_2, b_11, _S1302, passes_0);
            TreeSample _S1352 = TreeSample_x24init_0(_S1286, _S1286, 0.0f, 0U);
            if(_S1351)
            {
                float3  _S1353 = (&ray_2)->origin;
                float3  _S1354 = (&ray_2)->unit_direction;
                float3  _S1355 = (&ray_2)->unit_direction;
                uint _S1356 = noiseAddress(_S1314, b_11);
                float3  _S1357 = extinction_in_0;
                float3  _S1358 = extinction_in_0;
                uint2  _S1359 = make_uint2 (_S1322);
                float3  _S1360 = (&ray_2)->unit_direction;
                uint _S1361 = arrivalLobe_0(b_11, (&prev_0)->lobe);
                FKHit _S1362 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1363 = _S1362;
                ShadowContext _S1364 = ShadowContext_x24init_0(_S1357, _S1358, _S1359, _S1360, b_11, _S1361, false, threshold_2, width_6, &_S1363, false);
                ShadowContext _S1365 = _S1364;
                TreeSample _S1366 = sampleLightTree_0(_S1353, _S1354, _S1355, 0.0f, true, _S1356, &_S1365);
                light_3 = _S1366;
            }
            else
            {
                light_3 = _S1352;
            }
            float _S1367 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S1368 = (fcptMaxBounces());
            bool _S1369 = b_11 < _S1368;
            if(_S1369)
            {
                is_inside_7 = (light_3.density) > 0.0f;
            }
            else
            {
                is_inside_7 = false;
            }
            float _S1370 = _slang_select(is_inside_7, _S1367,0.0f);
            float3  _S1371 = throughput_4 * light_3.radiance;
            float _S1372 = powerHeuristic(light_3.density, _S1370);
            float3  _S1373 = pathColor(_S1371 * make_float3 (_S1367 * _S1372), throughput_3, 0.0f);
            float3  _S1374 = _slang_select(_S1351, _S1373,_S1286);
            if(replay_2)
            {
                viewed_0 = b_11 == _S1302;
            }
            else
            {
                viewed_0 = false;
            }
            if(viewed_0)
            {
                bool _S1375 = _S1291 == 2U;
                if(_S1375)
                {
                    float _S1376 = resamplingTarget(_S1374);
                    passes_0 = _S1376 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1377 = Shift_x24init_0(_S1374, 1.0f);
                    _S1285 = int(0);
                    ended_0 = _S1377;
                    spread_2 = _S1350;
                    threshold_2 = width_6;
                    spectral_weight_0 = throughput_4;
                    layer_0 = b_11;
                    break;
                }
                _S1285 = int(0);
                ended_0 = _S1287;
                spread_2 = _S1350;
                threshold_2 = width_6;
                spectral_weight_0 = throughput_4;
                layer_0 = b_11;
                break;
            }
            bool _S1378 = !replay_2;
            if(_S1378)
            {
                Reservoir candidate_3 = _S1321;
                uint _S1379 = extractBits_0(_S1321.path, 24U, 8U);
                uint _S1380 = insertBits_0(0U, _S1379, 24U, 8U);
                uint _S1381 = extractBits_0(_S1321.path, 10U, 2U);
                bool _S1382 = _S1381 == 1U;
                if(_S1382)
                {
                    float3  _S1383 = safeDivide(_S1374, _S1286);
                    (&candidate_3)->radiance = _S1383;
                }
                else
                {
                    uint _S1384 = insertBits_0(_S1380, b_11 + 1U, 5U, 5U);
                    uint _S1385 = insertBits_0(_S1384, 2U, 10U, 2U);
                    (&candidate_3)->path = _S1385;
                }
                Reservoir _S1386 = withEnd(candidate_3, 0U, b_11, _S1374);
                offer(sel_7, _S1386, _S1374 * make_float3 (scale_3) / make_float3 (density_2));
                float _S1387 = survivalProbability(abs_0(throughput_4), density_2);
                uint _S1388 = noiseAddress(_S1314, b_11);
                Random _S1389 = draw(_S1388, 8U);
                bool _S1390 = _S1387 < (_S1389.value);
                if(_S1390)
                {
                    _S1284 = true;
                }
                else
                {
                    uint _S1391 = (fcptMaxBounces());
                    _S1284 = b_11 >= _S1391;
                }
                if(_S1284)
                {
                    _S1285 = int(0);
                    ended_0 = _S1287;
                    spread_2 = _S1350;
                    threshold_2 = width_6;
                    spectral_weight_0 = throughput_4;
                    layer_0 = b_11;
                    break;
                }
                float _S1392 = density_2 * _S1387;
                density_2 = _S1392;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1393 = noiseAddress(_S1314, b_11);
            float3  _S1394 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1393, &phase_pdf_0);
            (&ray_2)->unit_direction = _S1394;
            NEEVertex _S1395 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S1286, (&ray_2)->origin);
            nee_vertex_0 = _S1395;
            Vertex _S1396 = scatteredVertex_0(false);
            prev_0 = _S1396;
            float _S1397 = (&prev_0)->pdf;
            FKRay _S1398 = ray_2;
            FKHit _S1399 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1400 = (fcptTraverseInstanceBVH((_S1398), (true), (4.294967296e+09f), (false), (_S1399), (false)));
            hit_4 = _S1400;
            b_9 = b_11;
            throughput_2 = throughput_4;
            wavelength_6 = _S1350;
            width_3 = width_6;
            sky_pdf_0 = _S1397;
        }
        if(_S1285 != int(1))
        {
            width_3 = threshold_2;
            throughput_2 = spectral_weight_0;
            b_9 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1287;
        spread_2 = wavelength_6;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1401 = b_9 == 4294967295U;
    bool _S1402 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1402)
    {
        bool _S1403 = !(&nee_vertex_0)->none;
        float _S1404 = _slang_select(_S1403, sky_pdf_0,0.0f);
        float _S1405 = escapeWeight_0(_S1404, (&ray_2)->unit_direction);
        float3  _S1406 = environment_0((&ray_2)->unit_direction, b_9, (&prev_0)->lobe);
        float3  _S1407 = pathColor(throughput_2 * _S1406, throughput_3, 0.0f);
        if(replay_2)
        {
            bool _S1408 = b_9 == _S1302;
            if(_S1408)
            {
                passes_0 = _S1291 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S1407 * make_float3 (_S1405) / make_float3 (r_8->jac), density_2 / r_8->jac);
            }
            if(_S1301)
            {
                passes_0 = _S1298;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_9 == _S1289;
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
                return Shift_x24init_0(_S1407 * make_float3 (_S1405), 1.0f);
            }
            return _S1287;
        }
        Reservoir candidate_4 = chain_0;
        uint _S1409 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1410 = _S1409 == 1U;
        if(_S1410)
        {
            uint _S1411 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S1412 = _S1411 == b_9;
            float _S1413 = _slang_select(_S1412, 1.0f,_S1405);
            float3  _S1414 = safeDivide(_S1407 * make_float3 (_S1413), _S1286);
            (&candidate_4)->radiance = _S1414;
        }
        else
        {
            bool _S1415 = (&prev_0)->rough;
            if(_S1415)
            {
                uint _S1416 = insertBits_0(_S1316, b_9 + 1U, 5U, 5U);
                uint _S1417 = insertBits_0(_S1416, 3U, 10U, 2U);
                uint _S1418 = insertBits_0(_S1417, (&prev_0)->lobe, 15U, 3U);
                bool _S1419 = (&prev_0)->inside;
                uint _S1420 = _slang_select(_S1419, 1U,0U);
                uint _S1421 = insertBits_0(_S1418, _S1420, 22U, 1U);
                (&candidate_4)->path = _S1421;
                (&candidate_4)->jac = (&prev_0)->pdf;
                (&candidate_4)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S1422 = _S1407 * make_float3 (_S1405);
        Reservoir _S1423 = withEnd(candidate_4, 3U, b_9, _S1422);
        offer(sel_7, _S1423, _S1422 * make_float3 (scale_3) / make_float3 (density_2));
        return _S1287;
    }
    float3  _S1424 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S1424;
    bool _S1425 = (fcptVaryingUsed());
    if(_S1425)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1426 = !replay_2;
        if(_S1426)
        {
            float3  _S1427 = pathColor(throughput_2 * glowed_0, throughput_3, 0.0f);
            float3  _S1428 = _S1427 / make_float3 (density_2);
            float3  _S1429 = sel_7->glow + _S1428;
            sel_7->glow = _S1429;
        }
        float3  _S1430 = throughput_2 * weight_2;
        throughput_2 = _S1430;
    }
    else
    {
        float3  _S1431 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
        float3  _S1432 = throughput_2 * _S1431;
        throughput_2 = _S1432;
    }
    float _S1433 = width_3 + spread_2 * (&hit_4)->distance;
    uint _S1434 = b_9 + 1U;
    b_9 = _S1434;
    layer_0 = 0U;
    width_3 = _S1433;
    passes_0 = false;
    wavelength_6 = 0.0f;
    threshold_2 = 0.0f;
    turned_1 = false;
    is_inside_7 = false;
    spectral_weight_0 = throughput_3;
    float3  chain_throughput_0 = _S1286;
    float3  reconnection_0 = _S1286;
    viewed_0 = _S1401;
    for(;;)
    {
        bool _S1435 = ((&hit_4)->is_point_light) == 1U;
        if(replay_2)
        {
            _S1284 = _S1291 == 1U;
        }
        else
        {
            _S1284 = false;
        }
        bool _S1436;
        if(_S1284)
        {
            _S1436 = b_9 == _S1290;
        }
        else
        {
            _S1436 = false;
        }
        bool _S1437;
        if(_S1436)
        {
            bool _S1438 = ((&hit_4)->instance_index) != (_S1303.instance_index);
            if(_S1438)
            {
                _S1437 = true;
            }
            else
            {
                _S1437 = ((&hit_4)->triangle_index) != (_S1303.triangle_index);
            }
        }
        else
        {
            _S1437 = false;
        }
        if(_S1437)
        {
            return _S1287;
        }
        FKMedium _S1439 = Medium_x24init_0(_S1286, _S1286, 0.0f);
        BSDFMaterial _S1440 = Material_x24init_0(_S1286, _S1286, 0.0f, 0.0f, 0.0f, 0.0f, _S1286, throughput_3, 1.0f, _S1286, _S1286, 0.5f, 0.0f, 0.0f, _S1286, 0.0f, _S1286, 0.0f);
        FKMedium _S1441 = _S1439;
        FKSurface _S1442 = Surface_x24init_0(_S1286, _S1286, 0.0f, &_S1440, false, 0U, 1.0f, false, &_S1441, 4294967295U, _S1286);
        bool _S1443 = !_S1435;
        bool scatter_2;
        bool is_inside_8;
        float geometry_density_2;
        float3  throughput_5;
        FKSurface surface_13;
        if(_S1443)
        {
            uint _S1444 = noiseAddress(_S1314, b_9);
            uint _S1445 = arrivalLobe_0(b_9, (&prev_0)->lobe);
            FKSurface _S1446 = (fcptSurfaceAtPath((hit_4), ((&ray_2)->origin), (_S1444), (width_3), (layer_0), (b_9), (_S1445), ((&ray_2)->unit_direction)));
            bool _S1447 = !passes_0;
            FKSurface _S1448 = _S1446;
            FKSurface _S1449 = emitting_0(&_S1448, _S1447);
            uint _S1450 = noiseAddress(_S1314, b_9);
            Random _S1451 = draw(_S1450, 9U);
            FKSurface _S1452 = _S1449;
            FKSurface _S1453 = uncovered_0(&_S1452, _S1451.value);
            float _S1454 = facingSign(_S1453.material.transmission, _S1453.geometry_n, (&ray_2)->unit_direction);
            bool _S1455 = _S1454 < 0.0f;
            bool _S1456 = (_S1453.material.transmission) > 0.0f;
            if(_S1456)
            {
                bool _S1457 = arrivesBehind_0((&ray_2)->unit_direction, _S1453.geometry_n);
                scatter_2 = _S1457;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1458 = _S1453;
            FKSurface _S1459 = facingRay_0(&_S1458, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S1460 = arrivesBehind_0((&ray_2)->unit_direction, _S1459.geometry_n);
                is_inside_8 = _S1460;
            }
            else
            {
                is_inside_8 = scatter_2;
            }
            if(is_inside_8)
            {
                float _S1461 = (&hit_4)->distance;
                float _S1462 = upsample(_S1459.material.absorption, wavelength_6);
                float3  _S1463 = make_float3 (_S1462);
                bool _S1464 = wavelength_6 > 0.0f;
                float3  _S1465 = _slang_select(_S1464, _S1463,_S1459.material.absorption);
                float3  _S1466 = beerLambert(_S1461, _S1465);
                float3  _S1467 = throughput_2 * _S1466;
                throughput_5 = _S1467;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S1468 = !_S1459.skip;
            float geometry_density_3 = geometryDensity(_S1459.geometry_n, (&ray_2)->unit_direction, (&hit_4)->distance);
            bool _S1469 = b_9 == _S1434;
            if(_S1469)
            {
                float _S1470 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S1470;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            float _S1471 = geometry_density_2;
            scatter_2 = _S1468;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S1471;
            surface_13 = _S1459;
            turned_1 = _S1455;
        }
        else
        {
            scatter_2 = false;
            geometry_density_2 = 0.0f;
            surface_13 = _S1442;
            throughput_5 = throughput_2;
            is_inside_8 = is_inside_7;
        }
        bool _S1472 = withinFootprint(scatter_2, (&prev_0)->rough, (&prev_0)->pdf, geometry_density_2, threshold_2);
        FKSurface _S1473 = surface_13;
        float _S1474 = dot_0(surface_13.smooth_n, - (&ray_2)->unit_direction);
        bool _S1475 = (fcptDispersionUsed());
        bool _S1476;
        if(_S1475)
        {
            _S1476 = wavelength_6 == 0.0f;
        }
        else
        {
            _S1476 = false;
        }
        bool _S1477;
        if(_S1476)
        {
            _S1477 = scatter_2;
        }
        else
        {
            _S1477 = false;
        }
        bool _S1478;
        if(_S1477)
        {
            bool _S1479 = dispersive(surface_13.material);
            _S1478 = _S1479;
        }
        else
        {
            _S1478 = false;
        }
        float3  throughput_6;
        if(_S1478)
        {
            uint _S1480 = stream(_S1314, 512U);
            Random _S1481 = pcg(_S1480);
            uint _S1482 = extractBits_0(_S1288, 25U, 7U);
            float _S1483 = (float(_S1482) + _S1481.value) / 128.0f;
            uint _S1484 = extractBits_0(_S1288, 24U, 1U);
            bool _S1485 = _S1484 == 1U;
            float _S1486 = _slang_select(_S1485, _S1483,_S1481.value);
            float2  _S1487 = sampleWavelength(_S1486);
            float wavelength_7 = _S1487.x;
            float3  _S1488 = wavelengthWeights(wavelength_7);
            float3  _S1489 = _S1488 / make_float3 (_S1487.y);
            float _S1490 = upsample(throughput_5, wavelength_7);
            float3  _S1491 = make_float3 (_S1490);
            float _S1492 = upsample(scatter_in_0, wavelength_7);
            float3  _S1493 = make_float3 (_S1492);
            scatter_in_0 = _S1493;
            float _S1494 = upsample(extinction_in_0, wavelength_7);
            float3  _S1495 = make_float3 (_S1494);
            extinction_in_0 = _S1495;
            wavelength_6 = wavelength_7;
            throughput_6 = _S1491;
            spectral_weight_0 = _S1489;
        }
        else
        {
            throughput_6 = throughput_5;
        }
        bool _S1496 = wavelength_6 > 0.0f;
        BSDFMaterial _S1497;
        if(_S1496)
        {
            BSDFMaterial _S1498 = atWavelength(surface_13.material, wavelength_6);
            _S1497 = _S1498;
        }
        else
        {
            _S1497 = surface_13.material;
        }
        float2  _S1499 = wavelengthEta(_S1497, _S1474, wavelength_6);
        bool _S1500;
        if(scatter_2)
        {
            bool _S1501 = neeDecision(_S1497, _S1474, _S1499.x, _S1499.y);
            _S1500 = _S1501;
        }
        else
        {
            _S1500 = false;
        }
        bool _S1502;
        if(passes_0)
        {
            _S1502 = true;
        }
        else
        {
            _S1502 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1502)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1500;
        }
        bool _S1503 = (fcptHairUsed());
        bool _S1504;
        if(_S1503)
        {
            float3  _S1505 = surface_13.hair;
            _S1504 = (dot_0(_S1505, _S1505)) > 0.0f;
        }
        else
        {
            _S1504 = false;
        }
        bool _S1506;
        if(_S1504)
        {
            _S1506 = true;
        }
        else
        {
            BSDFMaterial _S1507 = _S1497;
            bool _S1508 = isTranslucent_0(&_S1507);
            _S1506 = _S1508;
        }
        bool _S1509;
        if(_S1506)
        {
            _S1509 = true;
        }
        else
        {
            bool _S1510 = (_S1497.transmission) > 0.0f;
            if(_S1510)
            {
                uint _S1511 = (fcptLayers((hit_4)));
                _S1509 = _S1511 == 1U;
            }
            else
            {
                _S1509 = false;
            }
        }
        BSDFMaterial _S1512 = _S1497;
        float3  emission_0;
        if(_S1435)
        {
            float3  _S1513 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1513;
        }
        else
        {
            emission_0 = _S1512.emissive;
        }
        float _S1514 = rgb_to_greyscale(emission_0);
        bool _S1515 = _S1514 > 0.0f;
        float3  emission_1;
        if(_S1515)
        {
            NEEVertex _S1516 = nee_vertex_0;
            FKHit _S1517 = hit_4;
            float _S1518 = emissionWeight_0(&_S1516, &_S1517, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1518);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1519;
        if(replay_2)
        {
            _S1519 = _S1291 == 1U;
        }
        else
        {
            _S1519 = false;
        }
        bool _S1520;
        if(_S1519)
        {
            _S1520 = b_9 > _S1290;
        }
        else
        {
            _S1520 = false;
        }
        bool _S1521;
        if(_S1520)
        {
            _S1521 = b_9 == _S1289;
        }
        else
        {
            _S1521 = false;
        }
        bool _S1522;
        if(_S1521)
        {
            bool _S1523 = _S1292 == 1U;
            if(_S1523)
            {
                _S1522 = true;
            }
            else
            {
                _S1522 = _S1292 == 2U;
            }
        }
        else
        {
            _S1522 = false;
        }
        if(_S1522)
        {
            bool _S1524 = _S1435 != (_S1292 == 2U);
            if(_S1524)
            {
                return _S1287;
            }
            float3  _S1525 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_6);
            return Shift_x24init_0(_S1525 / make_float3 (r_8->jac), density_2 / r_8->jac);
        }
        uint _S1526 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1527 = _S1526 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1528 = insertBits_0(_S1316, b_9, 5U, 5U);
        uint _S1529 = insertBits_0(_S1528, 1U, 10U, 2U);
        uint _S1530 = insertBits_0(_S1529, (&prev_0)->lobe, 15U, 3U);
        bool _S1531 = (&prev_0)->inside;
        uint _S1532 = _slang_select(_S1531, 1U,0U);
        uint _S1533 = insertBits_0(_S1530, _S1532, 22U, 1U);
        (&here_0)->path = _S1533;
        uint _S1534 = (&here_0)->path;
        uint _S1535 = _slang_select(_S1496, 1U,0U);
        uint _S1536 = insertBits_0(_S1534, _S1535, 23U, 1U);
        (&here_0)->path = _S1536;
        float _S1537 = (&prev_0)->pdf * geometry_density_2;
        (&here_0)->jac = _S1537;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1538;
        if(replay_2)
        {
            _S1538 = _S1291 == 1U;
        }
        else
        {
            _S1538 = false;
        }
        bool _S1539;
        if(_S1538)
        {
            _S1539 = b_9 == _S1290;
        }
        else
        {
            _S1539 = false;
        }
        bool _S1540 = b_9 == _S1302;
        bool _S1541;
        if(_S1540)
        {
            bool _S1542 = !scatter_2;
            if(_S1542)
            {
                _S1541 = true;
            }
            else
            {
                bool _S1543 = _S1291 != 1U;
                if(_S1543)
                {
                    _S1541 = _S1291 != 3U;
                }
                else
                {
                    _S1541 = false;
                }
            }
        }
        else
        {
            _S1541 = false;
        }
        bool _S1544;
        if(_S1541)
        {
            _S1544 = _S1291 == 2U;
        }
        else
        {
            _S1544 = false;
        }
        bool _S1545;
        if(_S1544)
        {
            _S1545 = !_S1472;
        }
        else
        {
            _S1545 = false;
        }
        bool _S1546;
        if(_S1545)
        {
            _S1546 = _S1292 != 4U;
        }
        else
        {
            _S1546 = false;
        }
        bool _S1547 = _S1290 == _S1289;
        bool _S1548;
        if(_S1547)
        {
            _S1548 = _S1292 == 0U;
        }
        else
        {
            _S1548 = false;
        }
        bool _S1549;
        if(_S1548)
        {
            _S1549 = ((&hit_4)->instance_index) == (_S1303.instance_index);
        }
        else
        {
            _S1549 = false;
        }
        bool _S1550;
        if(_S1549)
        {
            _S1550 = ((&hit_4)->triangle_index) == (_S1303.triangle_index);
        }
        else
        {
            _S1550 = false;
        }
        bool _S1551;
        if(_S1550)
        {
            _S1551 = _S1472;
        }
        else
        {
            _S1551 = false;
        }
        bool _S1552 = _slang_select(_S1539, _S1551,_S1546);
        bool _S1553;
        if(nee_0)
        {
            _S1553 = _slang_select(replay_2, _S1552,scatter_2);
        }
        else
        {
            _S1553 = false;
        }
        TreeSample _S1554 = TreeSample_x24init_0(_S1286, _S1286, 0.0f, 0U);
        uint2  _S1555 = make_uint2 (0U);
        float2  _S1556 = make_float2 (0.0f);
        FKHit _S1557 = Hit_x24init_0(_S1556, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1558 = _S1557;
        ShadowContext _S1559 = ShadowContext_x24init_0(_S1286, _S1286, _S1555, _S1286, 0U, 0U, false, 0.0f, 0.0f, &_S1558, false);
        ShadowContext context_5;
        if(nee_0)
        {
            uint _S1560 = arrivalLobe_0(b_9, (&prev_0)->lobe);
            FKMedium _S1561 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1562 = surface_13;
            FKHit _S1563 = hit_4;
            FKMedium _S1564 = _S1561;
            ShadowContext _S1565 = shadowContext_0(&_S1562, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_9, _S1560, (&hit_4)->distance, width_3, &_S1563, _S1504, &_S1564);
            context_5 = _S1565;
        }
        else
        {
            context_5 = _S1559;
        }
        float3  throughput_7;
        float3  lit_0;
        if(_S1553)
        {
            float3  _S1566 = (&ray_2)->origin;
            if(_S1504)
            {
                throughput_7 = _S1286;
            }
            else
            {
                throughput_7 = _S1473.smooth_n;
            }
            FKSurface _S1567 = surface_13;
            uint _S1568 = noiseAddress(_S1314, b_9);
            ShadowContext _S1569 = context_5;
            TreeSample _S1570 = sampleLightTree_0(_S1566, throughput_7, surface_13.geometry_n, surface_13.geometry_offset, _S1509, _S1568, &_S1569);
            bool _S1571 = any_1((_S1570.radiance) != _S1286);
            if(_S1571)
            {
                if(_S1504)
                {
                    uint _S1572 = (fcptMaxBounces());
                    bool _S1573 = b_9 < _S1572;
                    FKSurface _S1574 = surface_13;
                    TreeSample _S1575 = _S1570;
                    float3  _S1576 = hairLight_0(&_S1574, (&ray_2)->unit_direction, &_S1575, _S1573);
                    lit_0 = _S1576;
                }
                else
                {
                    float _S1577 = _S1499.x;
                    float _S1578 = _S1499.y;
                    uint _S1579 = (fcptMaxBounces());
                    bool _S1580 = b_9 < _S1579;
                    TreeSample _S1581 = _S1570;
                    BSDFMaterial _S1582 = _S1497;
                    float3  _S1583 = lightBSDF_0((&ray_2)->unit_direction, &_S1581, _S1473.smooth_n, _S1567.geometry_n, &_S1582, _S1577, _S1578, _S1580, surface_13.random_state);
                    lit_0 = _S1583;
                }
            }
            else
            {
                lit_0 = _S1286;
            }
            light_3 = _S1570;
        }
        else
        {
            light_3 = _S1554;
            lit_0 = _S1286;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1584;
        bool _S1585;
        float density_4;
        if(_S1539)
        {
            bool _S1586 = !_S1472;
            if(_S1586)
            {
                return _S1287;
            }
            uint _S1587 = extractBits_0(_S1288, 23U, 1U);
            bool _S1588 = _S1496 != (_S1587 == 1U);
            if(_S1588)
            {
                return _S1287;
            }
            float3  throughput_8 = throughput_6 * make_float3 (geometry_density_2);
            float density_5 = density_2 * geometry_density_2;
            if(_S1547)
            {
                viewed_1 = _S1292 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                float3  _S1589 = pathColor(throughput_8 * emission_1, spectral_weight_0, wavelength_6);
                return Shift_x24init_0(_S1589 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1547)
            {
                refracted_4 = _S1292 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S1590 = !nee_0;
                if(_S1590)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1591 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1591 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1287;
                }
                float3  _S1592 = pathColor(throughput_8 * lit_0, spectral_weight_0, wavelength_6);
                return Shift_x24init_0(_S1592 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1547)
            {
                wrong_side_0 = _S1292 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1593 = !nee_0;
                if(_S1593)
                {
                    return _S1287;
                }
                bool _S1594 = (fcptWorldReadsPath());
                if(_S1594)
                {
                    float _S1595 = environmentPdf_0(r_8->dir);
                    uint _S1596 = b_9 + 1U;
                    FKSurface _S1597 = surface_13;
                    float3  _S1598 = skyColor_0((&ray_2)->unit_direction, r_8->dir, &_S1597, _S1499, is_inside_8, _S1595, surface_13.random_state, _S1596);
                    float3  _S1599 = pathColor(throughput_8 * (_S1598 * r_8->radiance), spectral_weight_0, wavelength_6);
                    return Shift_x24init_0(_S1599 / make_float3 (r_8->jac), density_5 / r_8->jac);
                }
                float _S1600 = environmentPdf_0(r_8->dir);
                float3  _S1601 = skyBSDF((&ray_2)->unit_direction, r_8->dir, surface_13, _S1499, is_inside_8, _S1600, surface_13.random_state);
                float3  _S1602 = pathColor(throughput_8 * _S1601 * r_8->radiance, spectral_weight_0, wavelength_6);
                return Shift_x24init_0(_S1602 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            uint _S1603 = extractBits_0(_S1288, 21U, 1U);
            bool _S1604 = nee_0 != (_S1603 == 1U);
            if(_S1604)
            {
                return _S1287;
            }
            throughput_7 = throughput_8;
            density_4 = density_5;
        }
        else
        {
            if(replay_2)
            {
                viewed_1 = _S1540;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1605 = !scatter_2;
                if(_S1605)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1606 = _S1291 != 1U;
                    if(_S1606)
                    {
                        refracted_4 = _S1291 != 3U;
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
                bool _S1607 = _S1291 == 2U;
                if(_S1607)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1472;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1292 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1504)
                    {
                        return _S1287;
                    }
                    uint _S1608 = noiseAddress(_S1314, b_9);
                    FKRay _S1609 = ray_2;
                    FKSurface _S1610 = surface_13;
                    ShadowContext _S1611 = context_5;
                    SkySample _S1612 = sampleSky_0(&_S1609, &_S1610, _S1499, is_inside_8, _S1608, surface_13.random_state, &_S1611);
                    float3  _S1613 = pathColor(throughput_6 * _S1612.color, spectral_weight_0, wavelength_6);
                    return Shift_x24init_0(_S1613, 1.0f);
                }
                if(_S1607)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1472;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1614 = rgb_to_greyscale(light_3.radiance);
                    bool _S1615 = !(_S1614 > 0.0f);
                    if(_S1615)
                    {
                        return _S1287;
                    }
                    float3  _S1616 = pathColor(throughput_6 * lit_0, spectral_weight_0, wavelength_6);
                    return Shift_x24init_0(_S1616, 1.0f);
                }
                if(_S1301)
                {
                    passes_0 = _S1292 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1435;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float3  _S1617 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_6);
                    return Shift_x24init_0(_S1617, 1.0f);
                }
                if(_S1301)
                {
                    passes_0 = _S1292 == 1U;
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
                    passes_0 = !_S1472;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float3  _S1618 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_6);
                    return Shift_x24init_0(_S1618, 1.0f);
                }
                return _S1287;
            }
            else
            {
                bool _S1619 = !replay_2;
                if(_S1619)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1620 = b_9 > 0U;
                    if(_S1620)
                    {
                        Reservoir candidate_5 = chain_0;
                        if(_S1527)
                        {
                            float3  _S1621 = safeDivide(throughput_6 * emission_1, chain_throughput_0);
                            (&candidate_5)->radiance = _S1621;
                        }
                        else
                        {
                            if(_S1472)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1622 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_6);
                        Reservoir _S1623 = withEnd(candidate_5, 1U, b_9, _S1622);
                        offer(sel_7, _S1623, _S1622 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1624 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_6);
                        float3  _S1625 = sel_7->glow + _S1624;
                        sel_7->glow = _S1625;
                    }
                    if(nee_0)
                    {
                        float3  _S1626 = pathColor(throughput_6 * lit_0, spectral_weight_0, wavelength_6);
                        Reservoir candidate_6 = chain_0;
                        if(_S1527)
                        {
                            float3  _S1627 = safeDivide(_S1626, chain_throughput_0);
                            (&candidate_6)->radiance = _S1627;
                        }
                        else
                        {
                            if(_S1472)
                            {
                                candidate_6 = here_0;
                                uint _S1628 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1628;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1629 = insertBits_0(_S1316, b_9 + 1U, 5U, 5U);
                                uint _S1630 = insertBits_0(_S1629, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1630;
                            }
                        }
                        Reservoir _S1631 = withEnd(candidate_6, 0U, b_9, _S1626);
                        offer(sel_7, _S1631, _S1626 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1504)
                        {
                            _S1584 = false;
                        }
                        else
                        {
                            bool _S1632 = environmentMapped_0();
                            _S1584 = _S1632;
                        }
                    }
                    else
                    {
                        _S1584 = false;
                    }
                    if(_S1584)
                    {
                        uint _S1633 = (fcptMaxBounces());
                        _S1585 = b_9 < _S1633;
                    }
                    else
                    {
                        _S1585 = false;
                    }
                    if(_S1585)
                    {
                        uint _S1634 = noiseAddress(_S1314, b_9);
                        FKRay _S1635 = ray_2;
                        FKSurface _S1636 = surface_13;
                        ShadowContext _S1637 = context_5;
                        SkySample _S1638 = sampleSky_0(&_S1635, &_S1636, _S1499, is_inside_8, _S1634, surface_13.random_state, &_S1637);
                        float3  _S1639 = pathColor(throughput_6 * _S1638.color, spectral_weight_0, wavelength_6);
                        Reservoir candidate_7 = chain_0;
                        if(_S1527)
                        {
                            float3  _S1640 = safeDivide(_S1639, chain_throughput_0);
                            (&candidate_7)->radiance = _S1640;
                        }
                        else
                        {
                            if(_S1472)
                            {
                                candidate_7 = here_0;
                                uint _S1641 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1641;
                                (&candidate_7)->dir = _S1638.dir;
                                (&candidate_7)->radiance = _S1638.radiance;
                            }
                            else
                            {
                                uint _S1642 = insertBits_0(_S1316, b_9 + 1U, 5U, 5U);
                                uint _S1643 = insertBits_0(_S1642, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1643;
                            }
                        }
                        Reservoir _S1644 = withEnd(candidate_7, 4U, b_9, _S1639);
                        offer(sel_7, _S1644, _S1639 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                }
            }
            throughput_7 = throughput_6;
            density_4 = density_2;
        }
        bool _S1645;
        bool _S1646;
        bool _S1647;
        bool straight_0;
        bool _S1648;
        bool _S1649;
        bool _S1650;
        bool _S1651;
        bool _S1652;
        bool _S1653;
        bool _S1654;
        bool _S1655;
        bool _S1656;
        bool _S1657;
        bool _S1658;
        bool _S1659;
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
                viewed_1 = _S1540;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1660 = extractBits_0(_S1288, 15U, 3U);
            uint _S1661 = extractBits_0(_S1288, 18U, 3U);
            uint _S1662 = _slang_select(_S1539, _S1661,_S1660);
            float3  _S1663 = r_8->dir;
            bool refracted_5 = _S1662 == 1U;
            SampleBSDF _S1664 = SampleBSDF_x24init_0(_S1286, _S1286, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1664;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1665 = extractBits_0(_S1288, 22U, 1U);
                bool _S1666 = is_inside_8 != (_S1665 == 1U);
                if(_S1666)
                {
                    return _S1287;
                }
                bool _S1667 = _S1291 == 1U;
                if(_S1667)
                {
                    float3  _S1668 = (fcptHitPosition((_S1303)));
                    throughput_9 = _S1668;
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
                    BSDFMaterial _S1669 = _S1497;
                    bool _S1670 = isTranslucent_0(&_S1669);
                    if(_S1670)
                    {
                        refracted_4 = _S1662 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1671 = throughput_9 - (&ray_2)->origin;
                        float3  _S1672 = _slang_select(_S1667, _S1671,_S1663);
                        wrong_side_0 = (dot_0(_S1473.smooth_n, _S1672) * _S1474) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1667)
                {
                    float3  _S1673 = (&ray_2)->origin;
                    FKSurface _S1674 = surface_13;
                    float3  _S1675 = - _S1473.smooth_n;
                    bool _S1676 = is_inside_8 != refracted_4;
                    float3  _S1677 = _slang_select(_S1676, _S1675,_S1473.smooth_n);
                    float3  _S1678 = throughput_9 - (_S1673 + make_float3 (_S1674.geometry_offset) * _S1677);
                    float3  _S1679 = ((((_S1678)) * make_float3(rnorm3df(((_S1678)).x, ((_S1678)).y, ((_S1678)).z))));
                    reconnection_1 = _S1679;
                }
                else
                {
                    reconnection_1 = _S1663;
                }
                if(_S1504)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1680 = wrongSide_0(is_inside_8, refracted_4, reconnection_1, surface_13.geometry_n);
                    wrong_side_0 = _S1680;
                }
                if(wrong_side_0)
                {
                    return _S1287;
                }
                float3  _S1681 = throughput_9;
                throughput_9 = reconnection_1;
                b_12 = _S1662;
                wrong_side_0 = false;
                reconnection_1 = _S1681;
            }
            else
            {
                bool _S1682 = !_S1539;
                if(_S1682)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1683;
                    if(_S1504)
                    {
                        SampleBSDF _S1684 = (fcptSampleHair((surface_13.hair), (_S1497.albedo), (_S1497.specular_tint), ((&ray_2)->unit_direction), (surface_13.random_state)));
                        _S1683 = _S1684;
                    }
                    else
                    {
                        SampleBSDF _S1685 = sampleBSDF((&ray_2)->unit_direction, _S1473.smooth_n, _S1497, _S1499.x, _S1499.y, surface_13.random_state, _S1556);
                        _S1683 = _S1685;
                    }
                    bsdf_sampled_0 = _S1683;
                    if(_S1504)
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
                            return _S1287;
                        }
                        break;
                    }
                    if(_S1504)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1686 = wrongSide_0(is_inside_8, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_13.geometry_n);
                        wrong_side_0 = _S1686;
                    }
                    if(wrong_side_0)
                    {
                        _S1584 = (_S1497.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1584 = false;
                    }
                    if(_S1584)
                    {
                        SampleBSDF _S1687 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_13.geometry_n, _S1497, _S1499.x, _S1499.y, (&bsdf_sampled_0)->random_state, _S1556);
                        (&bsdf_sampled_0)->unit_direction = _S1687.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1687.refracted;
                        (&bsdf_sampled_0)->throughput = _S1687.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1688 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_13.geometry_n)) * surface_13.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1688;
                        }
                    }
                    uint _S1689 = (&bsdf_sampled_0)->lobe;
                    float3  _S1690 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1691 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1692 = (&bsdf_sampled_0)->pdf;
                    float _S1693 = _slang_select(wrong_side_0, 0.0f,_S1692);
                    (&lobe_5)->pdf = _S1693;
                    throughput_9 = _S1690;
                    b_12 = _S1689;
                    refracted_4 = _S1691;
                }
                else
                {
                    throughput_9 = _S1663;
                    b_12 = _S1662;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1584 = true;
            }
            else
            {
                _S1584 = _S1539;
            }
            float3  chain_throughput_1;
            if(_S1584)
            {
                if(_S1504)
                {
                    SampleBSDF _S1694 = (fcptConnectHair((surface_13.hair), (_S1497.albedo), (_S1497.specular_tint), ((&ray_2)->unit_direction), (throughput_9)));
                    lobe_5 = _S1694;
                }
                else
                {
                    float3  _S1695 = (&ray_2)->unit_direction;
                    float3  _S1696 = negate_0(_S1695);
                    float _S1697 = sign_0(_S1474);
                    float3  _S1698 = _S1473.smooth_n * make_float3 (_S1697);
                    float _S1699 = dot_0(_S1698, throughput_9);
                    float _S1700 = _S1497.roughness;
                    float _S1701 = _S1700 * _S1700;
                    AnisotropicFrame _S1702 = anisotropicFrame(_S1497, _S1698);
                    float3  _S1703 = reflectedHalf(_S1695, throughput_9);
                    bool _S1704 = b_12 == 1U;
                    if(_S1704)
                    {
                        float3  _S1705 = refractedHalf(_S1695, throughput_9, _S1473.smooth_n, _S1499.x, _S1499.y);
                        throughput_10 = _S1705;
                    }
                    else
                    {
                        throughput_10 = _S1703;
                    }
                    bool _S1706 = b_12 == 0U;
                    if(_S1706)
                    {
                        _S1585 = true;
                    }
                    else
                    {
                        _S1585 = b_12 == 6U;
                    }
                    if(_S1585)
                    {
                        float3  _S1707 = sampledHalf(_S1696, _S1698, _S1701, _S1702, surface_13.random_state);
                        throughput_11 = _S1707;
                    }
                    else
                    {
                        throughput_11 = throughput_10;
                    }
                    float _S1708 = _S1499.x;
                    float _S1709 = _S1499.y;
                    Weights _S1710 = lobeWeights(_S1695, _S1696, _S1698, throughput_11, _S1702, _S1497, _S1708, _S1709);
                    float _S1711 = (F32_abs((_S1474)));
                    float _S1712 = vndfPDF(_S1696, throughput_11, _S1698, _S1711, _S1701, _S1702, _S1710.v_dot_h);
                    switch(b_12)
                    {
                    case 0U:
                        {
                            float _S1713 = diffusePDF(_S1699, _S1711, _S1497, _S1710);
                            float3  _S1714 = diffuseBSDF(throughput_9, _S1698, _S1497, _S1710);
                            density_6 = _S1713;
                            chain_throughput_1 = _S1714;
                            break;
                        }
                    case 1U:
                        {
                            float _S1715 = refractPDF(dot_0(throughput_9, throughput_11), _S1712, _S1710, _S1708, _S1709);
                            float3  _S1716 = refractBSDF(throughput_9, _S1698, _S1701, _S1702, _S1497, _S1710);
                            density_6 = _S1715;
                            chain_throughput_1 = _S1716;
                            break;
                        }
                    case 4U:
                        {
                            float _S1717 = sheenVelvetPDF(_S1699, _S1711, _S1710);
                            float3  _S1718 = sheenVelvetBSDF(throughput_9, _S1696, _S1698, _S1497, _S1710);
                            density_6 = _S1717;
                            chain_throughput_1 = _S1718;
                            break;
                        }
                    case 6U:
                        {
                            ToonShape _S1719 = toonShape(_S1696, _S1698, _S1497);
                            float _S1720 = toonPDF(_S1699, dot_0(throughput_9, _S1719.axis), _S1719, _S1710);
                            float3  _S1721 = toonBSDF(throughput_9, _S1698, _S1719, _S1710);
                            density_6 = _S1720;
                            chain_throughput_1 = _S1721;
                            break;
                        }
                    default:
                        {
                            float _S1722 = reflectPDF(_S1712, _S1710);
                            float3  _S1723 = reflectBSDF(throughput_9, _S1698, _S1701, _S1702, _S1710);
                            density_6 = _S1722;
                            chain_throughput_1 = _S1723;
                            break;
                        }
                    }
                    bool _S1724 = density_6 > 0.0f;
                    if(_S1724)
                    {
                        SampleBSDF _S1725 = SampleBSDF_x24init_0(throughput_9, chain_throughput_1, surface_13.random_state, _S1704, b_12, density_6);
                        lobe_5 = _S1725;
                    }
                }
            }
            bool _S1726 = b_12 == 0U;
            if(_S1726)
            {
                _S1585 = true;
            }
            else
            {
                _S1585 = b_12 == 4U;
            }
            if(_S1585)
            {
                _S1645 = true;
            }
            else
            {
                _S1645 = b_12 == 6U;
            }
            if(_S1504)
            {
                _S1646 = false;
            }
            else
            {
                bool _S1727 = !_S1645;
                if(_S1727)
                {
                    bool _S1728 = (_S1497.roughness) == 0.0f;
                    if(_S1728)
                    {
                        _S1646 = true;
                    }
                    else
                    {
                        bool _S1729 = b_12 == 1U;
                        if(_S1729)
                        {
                            _S1646 = (_S1499.x) == (_S1499.y);
                        }
                        else
                        {
                            _S1646 = false;
                        }
                    }
                }
                else
                {
                    _S1646 = false;
                }
            }
            bool _S1730 = !_S1504;
            if(_S1730)
            {
                _S1647 = b_12 == 1U;
            }
            else
            {
                _S1647 = false;
            }
            if(_S1647)
            {
                straight_0 = (_S1497.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1648 = _S1730;
            }
            else
            {
                _S1648 = false;
            }
            if(_S1648)
            {
                _S1649 = b_12 == 1U;
            }
            else
            {
                _S1649 = false;
            }
            if(_S1649)
            {
                _S1650 = (_S1499.x) == (_S1499.y);
            }
            else
            {
                _S1650 = false;
            }
            BSDFMaterial _S1731 = _S1497;
            bool _S1732 = isTranslucent_0(&_S1731);
            if(_S1732)
            {
                _S1651 = _S1726;
            }
            else
            {
                _S1651 = false;
            }
            if(_S1651)
            {
                _S1652 = (dot_0(throughput_9, surface_13.geometry_n)) < 0.0f;
            }
            else
            {
                _S1652 = false;
            }
            if(nee_0)
            {
                _S1653 = !_S1646;
            }
            else
            {
                _S1653 = false;
            }
            if(_S1653)
            {
                _S1654 = !wrong_side_0;
            }
            else
            {
                _S1654 = false;
            }
            if(_S1654)
            {
                float _S1733 = (&lobe_5)->pdf;
                float3  _S1734 = (&ray_2)->origin;
                float3  _S1735 = _slang_select(_S1509, _S1286,_S1473.smooth_n);
                float3  _S1736 = (&ray_2)->origin;
                FKSurface _S1737 = surface_13;
                float3  _S1738 = - _S1473.smooth_n;
                float3  _S1739 = _slang_select(_S1652, _S1738,_S1473.smooth_n);
                NEEVertex _S1740 = NEEVertex_x24init_0(false, _S1733, _S1734, _S1735, _S1736 + make_float3 (_S1737.geometry_offset) * _S1739);
                nee_vertex_0 = _S1740;
            }
            else
            {
                if(_S1504)
                {
                    _S1655 = true;
                }
                else
                {
                    bool _S1741 = b_12 != 1U;
                    if(_S1741)
                    {
                        _S1655 = true;
                    }
                    else
                    {
                        _S1655 = (_S1499.x) != (_S1499.y);
                    }
                }
                if(_S1655)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1742 = withinInverseFootprint((&lobe_5)->pdf, _S1645, (&prev_0)->cos, (&hit_4)->distance, threshold_2);
            bool _S1743 = roughLobe((&lobe_5)->pdf, _S1645, _S1497.roughness);
            if(_S1539)
            {
                bool _S1744 = !_S1742;
                if(_S1744)
                {
                    return _S1287;
                }
                bool _S1745 = _S1292 != 1U;
                if(_S1745)
                {
                    _S1655 = _S1292 != 2U;
                }
                else
                {
                    _S1655 = false;
                }
                if(_S1655)
                {
                    float _S1746 = (&lobe_5)->pdf;
                    float _S1747 = _slang_select(nee_0, _S1746,0.0f);
                    float _S1748 = escapeWeight_0(_S1747, _S1663);
                    if(_S1547)
                    {
                        passes_0 = _S1298;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1749 = _slang_select(passes_0, _S1748,1.0f);
                    return Shift_x24init_0(throughput_7 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_8->radiance * make_float3 (_S1749) / make_float3 (r_8->jac), density_4 * (&lobe_5)->pdf / r_8->jac);
                }
                float3  _S1750 = throughput_7 * make_float3 ((&lobe_5)->pdf);
                float _S1751 = density_4 * (&lobe_5)->pdf;
                throughput_10 = _S1750;
                density_6 = _S1751;
            }
            else
            {
                throughput_10 = throughput_7;
                density_6 = density_4;
            }
            uint _S1752 = (fcptLayers((hit_4)));
            bool _S1753 = b_12 == 1U;
            bool _S1754 = passesLayer_0(_S1752, _S1753, passes_0);
            if(viewed_1)
            {
                _S1655 = _S1754;
            }
            else
            {
                _S1655 = false;
            }
            if(_S1655)
            {
                return _S1287;
            }
            if(replay_2)
            {
                _S1656 = b_9 <= _S1302;
            }
            else
            {
                _S1656 = false;
            }
            if(_S1656)
            {
                _S1657 = _S1472;
            }
            else
            {
                _S1657 = false;
            }
            if(_S1657)
            {
                _S1658 = _S1742;
            }
            else
            {
                _S1658 = false;
            }
            if(_S1658)
            {
                _S1659 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1659 = !_S1743;
                }
                else
                {
                    _S1659 = false;
                }
            }
            if(_S1659)
            {
                return _S1287;
            }
            if(viewed_1)
            {
                float3  _S1755 = throughput_10 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1756 = (&lobe_5)->pdf;
                throughput_11 = _S1755;
                sky_pdf_2 = _S1756;
            }
            else
            {
                float3  _S1757 = throughput_10 * max_0((&lobe_5)->throughput, _S1286);
                throughput_11 = _S1757;
                sky_pdf_2 = density_6;
            }
            bool _S1758 = !replay_2;
            bool _S1759;
            if(_S1758)
            {
                _S1759 = !_S1527;
            }
            else
            {
                _S1759 = false;
            }
            bool _S1760;
            if(_S1759)
            {
                _S1760 = _S1472;
            }
            else
            {
                _S1760 = false;
            }
            bool _S1761;
            if(_S1760)
            {
                _S1761 = _S1742;
            }
            else
            {
                _S1761 = false;
            }
            if(_S1761)
            {
                chain_0 = here_0;
                uint _S1762 = insertBits_0((&chain_0)->path, b_12, 18U, 3U);
                uint _S1763 = _slang_select(nee_0, 1U,0U);
                uint _S1764 = insertBits_0(_S1762, _S1763, 21U, 1U);
                (&chain_0)->path = _S1764;
                float _S1765 = (&chain_0)->jac * (&lobe_5)->pdf;
                (&chain_0)->jac = _S1765;
                (&chain_0)->dir = throughput_9;
                chain_throughput_1 = throughput_11;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1766 = surface_13;
            Vertex _S1767 = Vertex_x24init_0(_S1743, b_12, (&lobe_5)->pdf, (F32_abs((dot_0(surface_13.geometry_n, throughput_9)))), is_inside_8);
            prev_0 = _S1767;
            float _S1768 = (&lobe_5)->pdf;
            bool _S1769;
            if(_S1753)
            {
                _S1769 = (_S1499.x) == (_S1499.y);
            }
            else
            {
                _S1769 = false;
            }
            float sky_pdf_3 = _slang_select(_S1769, sky_pdf_0,_S1768);
            float _S1770 = _slang_select(_S1504, 0.0f,sky_pdf_3);
            float _S1771 = widened_0(spread_2, (&lobe_5)->pdf, _S1646);
            bool _S1772;
            if(refracted_4)
            {
                _S1772 = !_S1652;
            }
            else
            {
                _S1772 = false;
            }
            bool is_inside_9;
            if(_S1772)
            {
                bool _S1773 = !is_inside_8;
                is_inside_9 = _S1773;
            }
            else
            {
                is_inside_9 = is_inside_8;
            }
            FKSurface _S1774 = surface_13;
            bool _S1775 = boundsVolume_0(&_S1774);
            bool _S1776;
            if(_S1775)
            {
                _S1776 = !_S1754;
            }
            else
            {
                _S1776 = false;
            }
            if(_S1776)
            {
                FKSurface faced_2 = surface_13;
                float3  _S1777 = - _S1766.geometry_n;
                float3  _S1778 = _slang_select(turned_1, _S1777,_S1766.geometry_n);
                (&faced_2)->geometry_n = _S1778;
                FKMedium _S1779 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1780 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1781 = faced_2;
                FKMedium _S1782 = _S1779;
                FKMedium _S1783 = _S1780;
                MediumSides _S1784 = mediumSides_0(&_S1781, &_S1782, filling_2, (&ray_2)->unit_direction, &_S1783);
                bool _S1785 = leavesInFront_0((&faced_2)->geometry_n, throughput_9, _S1766.geometry_n);
                float3  _S1786 = _slang_select(_S1785, _S1784.front.scatter,_S1784.behind.scatter);
                scatter_in_0 = _S1786;
                float3  _S1787 = scatter_in_0;
                float _S1788 = upsample(scatter_in_0, wavelength_6);
                float3  _S1789 = make_float3 (_S1788);
                float3  _S1790 = _slang_select(_S1496, _S1789,_S1787);
                scatter_in_0 = _S1790;
                float3  _S1791 = _slang_select(_S1785, _S1784.front.extinction,_S1784.behind.extinction);
                extinction_in_0 = _S1791;
                float3  _S1792 = extinction_in_0;
                float _S1793 = upsample(extinction_in_0, wavelength_6);
                float3  _S1794 = make_float3 (_S1793);
                float3  _S1795 = _slang_select(_S1496, _S1794,_S1792);
                extinction_in_0 = _S1795;
                float _S1796 = _slang_select(_S1785, _S1784.front.g,_S1784.behind.g);
                g_in_0 = _S1796;
                uint _S1797 = _S1784.fillings.x;
                uint _S1798 = _S1784.fillings.y;
                uint _S1799 = _slang_select(_S1785, _S1798,_S1797);
                bool _S1800 = (fcptVaryingUsed());
                uint _S1801 = _slang_select(_S1800, _S1799,4294967295U);
                filling_2 = _S1801;
            }
            (&ray_2)->unit_direction = throughput_9;
            bool _S1802 = !_S1754;
            if(_S1802)
            {
                FKSurface _S1803 = surface_13;
                float _S1804 = _slang_select(straight_0, 0.0f,_S1803.geometry_offset);
                float3  _S1805 = - _S1473.smooth_n;
                bool _S1806 = is_inside_9 != _S1652;
                float3  _S1807 = _slang_select(_S1806, _S1805,_S1473.smooth_n);
                float3  _S1808 = (&ray_2)->origin + make_float3 (_S1804) * _S1807;
                (&ray_2)->origin = _S1808;
            }
            throughput_10 = throughput_11;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1754;
            viewed_1 = _S1650;
            sky_pdf_2 = _S1770;
            spread_5 = _S1771;
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
        bool _S1809 = !replay_2;
        float density_7;
        if(_S1809)
        {
            if(_S1435)
            {
                float3  _S1810 = pathColor(throughput_10 * emission_1, spectral_weight_0, wavelength_6);
                Reservoir candidate_8 = chain_0;
                uint _S1811 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1812 = _S1811 == 1U;
                if(_S1812)
                {
                    float3  _S1813 = safeDivide(_S1810, chain_throughput_0);
                    (&candidate_8)->radiance = _S1813;
                }
                Reservoir _S1814 = withEnd(candidate_8, 2U, b_9, _S1810);
                offer(sel_7, _S1814, _S1810 * make_float3 (scale_3) / make_float3 (density_6));
            }
            if(_S1435)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1815 = survivalProbability(abs_0(throughput_10), density_6);
                density_7 = _S1815;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1816 = noiseAddress(_S1314, b_9);
            Random _S1817 = draw(_S1816, 8U);
            bool _S1818 = density_7 < (_S1817.value);
            if(_S1818)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1819 = (fcptMaxBounces());
                wrong_side_0 = b_9 >= _S1819;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1820 = density_6 * density_7;
            density_7 = _S1820;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1821 = layer_0 ^ 1U;
        uint _S1822 = _slang_select(passes_0, _S1821,0U);
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
            uint _S1823 = b_12 + 1U;
            b_9 = _S1823;
            layer_0 = _S1822;
            continue;
        }
        FKRay _S1824 = ray_2;
        float _S1825 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_2)
        {
            refracted_4 = _S1540;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S1291 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1826 = _slang_select(wrong_side_0, _S1825,4.294967296e+09f);
        bool _S1827 = !_S1504;
        if(straight_0)
        {
            _S1584 = true;
        }
        else
        {
            _S1584 = _S1504;
        }
        FKHit _S1828;
        if(_S1584)
        {
            _S1828 = hit_4;
        }
        else
        {
            _S1828 = _S1557;
        }
        FKHit _S1829 = (fcptTraverseInstanceBVH((_S1824), (_S1443), (_S1826), (_S1827), (_S1828), (viewed_1)));
        hit_4 = _S1829;
        if(replay_2)
        {
            _S1585 = _S1540;
        }
        else
        {
            _S1585 = false;
        }
        if(_S1585)
        {
            _S1645 = _S1291 == 1U;
        }
        else
        {
            _S1645 = false;
        }
        if(_S1645)
        {
            _S1646 = ((&hit_4)->instance_index) == (_S1303.instance_index);
        }
        else
        {
            _S1646 = false;
        }
        if(_S1646)
        {
            _S1647 = ((&hit_4)->triangle_index) == (_S1303.triangle_index);
        }
        else
        {
            _S1647 = false;
        }
        if(_S1647)
        {
            (&hit_4)->uv = _S1303.uv;
            float _S1830 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S1830;
        }
        if(replay_2)
        {
            _S1648 = _S1540;
        }
        else
        {
            _S1648 = false;
        }
        if(_S1648)
        {
            _S1649 = _S1291 == 3U;
        }
        else
        {
            _S1649 = false;
        }
        if(_S1649)
        {
            _S1650 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1650 = false;
        }
        if(_S1650)
        {
            return _S1287;
        }
        Reservoir _S1831 = chain_0;
        uint _S1832 = filling_2;
        for(;;)
        {
            bool _S1833 = (fcptVaryingUsed());
            if(_S1833)
            {
                _S1651 = _S1832 != 4294967295U;
            }
            else
            {
                _S1651 = false;
            }
            float _S1834;
            if(_S1651)
            {
                float _S1835 = (fcptMajorant((_S1832)));
                _S1834 = _S1835;
            }
            else
            {
                _S1834 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_2)
            {
                _S1652 = _S1540;
            }
            else
            {
                _S1652 = false;
            }
            if(_S1652)
            {
                _S1653 = _S1291 == 1U;
            }
            else
            {
                _S1653 = false;
            }
            if(_S1653)
            {
                _S1654 = _S1834 > 0.0f;
            }
            else
            {
                _S1654 = false;
            }
            if(_S1654)
            {
                ended_0 = _S1287;
                sky_pdf_1 = sky_pdf_2;
                spread_3 = spread_5;
                width_4 = width_3;
                density_3 = density_7;
                throughput_11 = throughput_10;
                b_12 = b_9;
                _S1655 = true;
                break;
            }
            bool _S1836 = (&prev_0)->rough;
            if(_S1836)
            {
                _S1655 = !(_S1834 > 0.0f);
            }
            else
            {
                _S1655 = false;
            }
            (&prev_0)->rough = _S1655;
            uint _S1837 = b_9 + 320U;
            bool _S1838 = b_9 == 4294967295U;
            uint _S1839 = _slang_select(_S1838, 384U,_S1837);
            uint _S1840 = stream(_S1314, _S1839);
            uint tracking_1 = _S1840;
            weight_2 = throughput_3;
            glowed_0 = _S1286;
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
                    _S1285 = int(2);
                    break;
                }
                uint _S1841 = noiseAddress(_S1314, b_12);
                Random _S1842 = draw(_S1841, 10U);
                float _S1843 = freeFlight_0(_S1842.value, _S1834);
                if(_S1651)
                {
                    float3  _S1844 = (&ray_2)->origin;
                    float3  _S1845 = (&ray_2)->unit_direction;
                    float _S1846 = (&hit_4)->distance;
                    bool _S1847 = b_12 == 4294967295U;
                    uint _S1848 = _slang_select(_S1847, 0U,b_12);
                    uint _S1849 = (&prev_0)->lobe;
                    uint _S1850 = _slang_select(_S1847, 3U,_S1849);
                    float _S1851 = (fcptTrackMedium((_S1832), (_S1844), (_S1845), (_S1846), (&tracking_1), (&weight_2), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1848), (_S1850), (_S1847)));
                    spread_4 = _S1851;
                }
                else
                {
                    spread_4 = _S1843;
                }
                bool _S1852 = !(spread_4 < ((&hit_4)->distance));
                if(_S1852)
                {
                    _S1285 = int(2);
                    break;
                }
                if(_S1651)
                {
                    _S1656 = _S1809;
                }
                else
                {
                    _S1656 = false;
                }
                if(_S1656)
                {
                    float3  _S1853 = pathColor(throughput_11 * glowed_0, spectral_weight_0, wavelength_6);
                    float3  _S1854 = _S1853 / make_float3 (density_3);
                    float3  _S1855 = sel_7->glow + _S1854;
                    sel_7->glow = _S1855;
                }
                else
                {
                }
                glowed_0 = _S1286;
                uint b_13 = b_12 + 1U;
                float3  _S1856 = (&ray_2)->origin + make_float3 (spread_4) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1856;
                float3  _S1857 = flightWeight_0(scatter_in_0, extinction_in_0, _S1834, spread_4, true);
                float3  _S1858 = weight_2;
                float _S1859 = upsample(weight_2, wavelength_6);
                float3  _S1860 = make_float3 (_S1859);
                float3  _S1861 = _slang_select(_S1496, _S1860,_S1858);
                float3  _S1862 = _slang_select(_S1651, _S1861,_S1857);
                float3  throughput_12 = throughput_11 * _S1862;
                uint _S1863 = stream(_S1314, b_13 + 320U);
                tracking_1 = _S1863;
                weight_2 = throughput_3;
                float width_7 = width_4 + spread_3 * spread_4;
                float _S1864 = spread_3 + 3.14159274101257324f;
                bool _S1865 = scatterSampled_0(replay_2, b_13, _S1302, _S1651);
                TreeSample light_4;
                if(_S1865)
                {
                    float3  _S1866 = (&ray_2)->origin;
                    float3  _S1867 = (&ray_2)->unit_direction;
                    float3  _S1868 = (&ray_2)->unit_direction;
                    uint _S1869 = noiseAddress(_S1314, b_13);
                    float3  _S1870 = extinction_in_0;
                    float3  _S1871 = extinction_in_0;
                    uint2  _S1872 = make_uint2 (_S1832);
                    float3  _S1873 = (&ray_2)->unit_direction;
                    uint _S1874 = arrivalLobe_0(b_13, (&prev_0)->lobe);
                    FKHit _S1875 = _S1557;
                    ShadowContext _S1876 = ShadowContext_x24init_0(_S1870, _S1871, _S1872, _S1873, b_13, _S1874, false, spread_4, width_7, &_S1875, false);
                    ShadowContext _S1877 = _S1876;
                    TreeSample _S1878 = sampleLightTree_0(_S1866, _S1867, _S1868, 0.0f, true, _S1869, &_S1877);
                    light_4 = _S1878;
                }
                else
                {
                    light_4 = _S1554;
                }
                float _S1879 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1880 = (fcptMaxBounces());
                bool _S1881 = b_13 < _S1880;
                if(_S1881)
                {
                    _S1657 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1657 = false;
                }
                float _S1882 = _slang_select(_S1657, _S1879,0.0f);
                float3  _S1883 = throughput_12 * light_4.radiance;
                float _S1884 = powerHeuristic(light_4.density, _S1882);
                float3  _S1885 = pathColor(_S1883 * make_float3 (_S1879 * _S1884), spectral_weight_0, wavelength_6);
                float3  _S1886 = _slang_select(_S1865, _S1885,_S1286);
                if(replay_2)
                {
                    _S1658 = b_13 == _S1302;
                }
                else
                {
                    _S1658 = false;
                }
                if(_S1658)
                {
                    bool _S1887 = _S1291 == 2U;
                    if(_S1887)
                    {
                        float _S1888 = resamplingTarget(_S1886);
                        _S1659 = _S1888 > 0.0f;
                    }
                    else
                    {
                        _S1659 = false;
                    }
                    if(_S1659)
                    {
                        Shift _S1889 = Shift_x24init_0(_S1886, 1.0f);
                        _S1285 = int(1);
                        ended_0 = _S1889;
                        spread_4 = _S1864;
                        width_5 = width_7;
                        throughput_9 = throughput_12;
                        b_10 = b_13;
                        break;
                    }
                    _S1285 = int(1);
                    ended_0 = _S1287;
                    spread_4 = _S1864;
                    width_5 = width_7;
                    throughput_9 = throughput_12;
                    b_10 = b_13;
                    break;
                }
                if(_S1809)
                {
                    Reservoir candidate_9 = _S1831;
                    uint _S1890 = extractBits_0(_S1831.path, 24U, 8U);
                    uint _S1891 = insertBits_0(0U, _S1890, 24U, 8U);
                    uint _S1892 = extractBits_0(_S1831.path, 10U, 2U);
                    bool _S1893 = _S1892 == 1U;
                    if(_S1893)
                    {
                        float3  _S1894 = safeDivide(_S1886, chain_throughput_0);
                        (&candidate_9)->radiance = _S1894;
                    }
                    else
                    {
                        uint _S1895 = insertBits_0(_S1891, b_13 + 1U, 5U, 5U);
                        uint _S1896 = insertBits_0(_S1895, 2U, 10U, 2U);
                        (&candidate_9)->path = _S1896;
                    }
                    Reservoir _S1897 = withEnd(candidate_9, 0U, b_13, _S1886);
                    offer(sel_7, _S1897, _S1886 * make_float3 (scale_3) / make_float3 (density_3));
                    float _S1898 = survivalProbability(abs_0(throughput_12), density_3);
                    uint _S1899 = noiseAddress(_S1314, b_13);
                    Random _S1900 = draw(_S1899, 8U);
                    bool _S1901 = _S1898 < (_S1900.value);
                    if(_S1901)
                    {
                        _S1659 = true;
                    }
                    else
                    {
                        uint _S1902 = (fcptMaxBounces());
                        _S1659 = b_13 >= _S1902;
                    }
                    if(_S1659)
                    {
                        _S1285 = int(1);
                        ended_0 = _S1287;
                        spread_4 = _S1864;
                        width_5 = width_7;
                        throughput_9 = throughput_12;
                        b_10 = b_13;
                        break;
                    }
                    float _S1903 = density_3 * _S1898;
                    density_3 = _S1903;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1904 = noiseAddress(_S1314, b_13);
                float3  _S1905 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1904, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1905;
                NEEVertex _S1906 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1286, (&ray_2)->origin);
                nee_vertex_0 = _S1906;
                Vertex _S1907 = scatteredVertex_0(is_inside_7);
                prev_0 = _S1907;
                float _S1908 = (&prev_0)->pdf;
                FKRay _S1909 = ray_2;
                FKHit _S1910 = (fcptTraverseInstanceBVH((_S1909), (true), (4.294967296e+09f), (false), (_S1557), (false)));
                hit_4 = _S1910;
                b_12 = b_13;
                throughput_11 = throughput_12;
                spread_3 = _S1864;
                width_4 = width_7;
                sky_pdf_1 = _S1908;
            }
            if(_S1285 != int(2))
            {
                spread_3 = spread_4;
                width_4 = width_5;
                throughput_11 = throughput_9;
                b_12 = b_10;
                _S1655 = true;
                break;
            }
            ended_0 = _S1287;
            _S1655 = false;
            break;
        }
        if(_S1655)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1656 = b_12 == b_9;
        }
        else
        {
            _S1656 = false;
        }
        bool _S1911 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S1911)
        {
            bool _S1912 = !(&nee_vertex_0)->none;
            float _S1913 = _slang_select(_S1912, sky_pdf_1,0.0f);
            float _S1914 = escapeWeight_0(_S1913, (&ray_2)->unit_direction);
            float3  _S1915 = environment_0((&ray_2)->unit_direction, b_12, (&prev_0)->lobe);
            float3  _S1916 = pathColor(throughput_11 * _S1915, spectral_weight_0, wavelength_6);
            if(replay_2)
            {
                bool _S1917 = b_12 == _S1302;
                if(_S1917)
                {
                    passes_0 = _S1291 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1916 * make_float3 (_S1914) / make_float3 (r_8->jac), density_3 / r_8->jac);
                }
                if(_S1301)
                {
                    passes_0 = _S1298;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_12 == _S1289;
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
                    return Shift_x24init_0(_S1916 * make_float3 (_S1914), 1.0f);
                }
                return _S1287;
            }
            Reservoir candidate_10 = chain_0;
            uint _S1918 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1919 = _S1918 == 1U;
            if(_S1919)
            {
                uint _S1920 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1921 = _S1920 == b_12;
                float _S1922 = _slang_select(_S1921, 1.0f,_S1914);
                float3  _S1923 = safeDivide(_S1916 * make_float3 (_S1922), chain_throughput_0);
                (&candidate_10)->radiance = _S1923;
            }
            else
            {
                bool _S1924 = (&prev_0)->rough;
                if(_S1924)
                {
                    uint _S1925 = insertBits_0(_S1316, b_12 + 1U, 5U, 5U);
                    uint _S1926 = insertBits_0(_S1925, 3U, 10U, 2U);
                    uint _S1927 = insertBits_0(_S1926, (&prev_0)->lobe, 15U, 3U);
                    bool _S1928 = (&prev_0)->inside;
                    uint _S1929 = _slang_select(_S1928, 1U,0U);
                    uint _S1930 = insertBits_0(_S1927, _S1929, 22U, 1U);
                    (&candidate_10)->path = _S1930;
                    (&candidate_10)->jac = (&prev_0)->pdf;
                    (&candidate_10)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1931 = _S1916 * make_float3 (_S1914);
            Reservoir _S1932 = withEnd(candidate_10, 3U, b_12, _S1931);
            offer(sel_7, _S1932, _S1931 * make_float3 (scale_3) / make_float3 (density_3));
            break;
        }
        float3  _S1933 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1933;
        bool _S1934 = (fcptVaryingUsed());
        if(_S1934)
        {
            _S1657 = filling_2 != 4294967295U;
        }
        else
        {
            _S1657 = false;
        }
        if(_S1657)
        {
            if(_S1809)
            {
                float3  _S1935 = pathColor(throughput_11 * glowed_0, spectral_weight_0, wavelength_6);
                float3  _S1936 = _S1935 / make_float3 (density_3);
                float3  _S1937 = sel_7->glow + _S1936;
                sel_7->glow = _S1937;
            }
            float3  _S1938 = throughput_11 * weight_2;
            throughput_9 = _S1938;
        }
        else
        {
            float3  _S1939 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S1940 = throughput_11 * _S1939;
            throughput_9 = _S1940;
        }
        float _S1941 = width_4 + spread_3 * (&hit_4)->distance;
        viewed_0 = _S1656;
        width_3 = _S1941;
        throughput_2 = throughput_9;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_2 = spread_3;
        uint _S1823 = b_12 + 1U;
        b_9 = _S1823;
        layer_0 = _S1822;
    }
    return _S1287;
}

static __device__ Shift shift_0(Domain * dom_8, Reservoir * r_9)
{
    Selection _S1942 = (Selection{});
    Selection sel_8 = _S1942;
    bool _S1943 = (r_9->w) <= 0.0f;
    if(_S1943)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S1944 = walk_0(dom_8, r_9, true, 0.0f, &sel_8);
    return _S1944;
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
    Random _S1945 = pcg(state_4);
    Random _S1946 = pcg(_S1945.state);
    float _S1947 = 6.28318548202514648f * _S1945.value;
    float _S1948 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S1946.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1946.state, _S1948 * (F32_cos((_S1947))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_5, float3  value_2)
{
    RandomSphere _S1949;
    (&_S1949)->state = state_5;
    (&_S1949)->value = value_2;
    return _S1949;
}

__device__ RandomSphere random_sphere(uint state_6)
{
    Random _S1950 = normal_distribution(state_6);
    Random _S1951 = normal_distribution(_S1950.state);
    Random _S1952 = normal_distribution(_S1951.state);
    float3  _S1953 = make_float3 (_S1950.value, _S1951.value, _S1952.value);
    float3  _S1954 = ((((_S1953)) * make_float3(rnorm3df(((_S1953)).x, ((_S1953)).y, ((_S1953)).z))));
    return RandomSphere_x24init_0(_S1952.state, _S1954);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_11)
{
    float3  _S1955 = p1_0 - p0_0;
    float3  _S1956 = p2_0 - p0_0;
    float2  _S1957 = uv1_0 - uv0_0;
    float2  _S1958 = uv2_0 - uv0_0;
    float _S1959 = _S1957.x;
    float _S1960 = _S1958.y;
    float _S1961 = _S1957.y;
    float _S1962 = _S1958.x;
    float _S1963 = _S1959 * _S1960 - _S1961 * _S1962;
    float _S1964 = 1.0f / _S1963;
    float3  t_22 = (_S1955 * make_float3 (_S1960) - _S1956 * make_float3 (_S1961)) * make_float3 (_S1964);
    float3  _S1965 = (_S1956 * make_float3 (_S1959) - _S1955 * make_float3 (_S1962)) * make_float3 (_S1964);
    float3  _S1966 = t_22 - n_11 * make_float3 (dot_0(n_11, t_22));
    float3  t_23 = ((((_S1966)) * make_float3(rnorm3df(((_S1966)).x, ((_S1966)).y, ((_S1966)).z))));
    bool _S1967 = (dot_0(cross_0(n_11, t_23), _S1965)) > 0.0f;
    float3  t_24;
    if(_S1967)
    {
        float3  _S1968 = negate_0(t_23);
        t_24 = _S1968;
    }
    else
    {
        t_24 = t_23;
    }
    float3  _S1969 = cross_0(n_11, t_24);
    return makeMatrix<float, 3, 3> (t_24, _S1969, n_11);
}

__device__ float3  tangentToWorldNormalMap(float3  v_9, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_9, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_5, float3  uvw_0, float3  position_0)
{
    float3  _S1970 = t1_0 - t0_0;
    float3  _S1971 = t2_2 - t0_0;
    float3  _S1972 = t2_2 - t1_0;
    float _S1973 = (F32_min((length_0(_S1970)), ((F32_min((length_0(_S1971)), (length_0(_S1972)))))));
    float3  _S1974 = make_float3 (distance_1(position_0, t0_0), distance_1(position_0, t1_0), distance_1(position_0, t2_2));
    float3  _S1975 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1976 = dot_0(geometry_n_5, _S1975);
    float3  _S1977 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1978 = dot_0(geometry_n_5, _S1977);
    float3  _S1979 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1980 = acos_0(abs_0(make_float3 (_S1976, _S1978, dot_0(geometry_n_5, _S1979))));
    float3  _S1981 = clamp_2(tan_0(_S1980), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S1974 * _S1981, uvw_0), 0.0f, _S1973 * 0.125f);
}

__device__ float3  straightThrough(float3  dir_16, float3  n_12, BSDFMaterial material_22)
{
    float3  _S1982 = negate_0(dir_16);
    float _S1983 = sign_0(dot_0(n_12, _S1982));
    float3  _S1984 = n_12 * make_float3 (_S1983);
    AnisotropicFrame _S1985 = anisotropicFrame(material_22, _S1984);
    bool _S1986 = (_S1985.alphas.x) > 0.0f;
    if(_S1986)
    {
        float _S1987 = material_22.transmission * (1.0f - material_22.metallic);
        float3  _S1988 = negate_0(_S1984);
        float3  _S1989 = anisotropicLocal(dir_16, _S1985.tangent, _S1988);
        float _S1990 = anisotropicG1(_S1989, _S1985.alphas);
        return make_float3 (_S1987 * _S1990) * material_22.albedo;
    }
    float _S1991 = material_22.transmission * (1.0f - material_22.metallic);
    float _S1992 = material_22.roughness;
    float _S1993 = smithG1(_S1992 * _S1992, (F32_abs((dot_0(n_12, dir_16)))));
    return make_float3 (_S1991 * _S1993) * material_22.albedo;
}

__device__ float hairRow(float3  in_dir_11, float3  t_25, float3  out_dir_3, uint p_15, float w_19, float alpha_10, uint nt_0)
{
    uint _S1994 = p_15 % 4U;
    float _S1995 = w_19 * HAIR_WIDTHS_0[_S1994];
    float _S1996 = (F32_asin((clamp_1(dot_0(out_dir_3, t_25), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_11, t_25), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1994] * alpha_10;
    return ((F32_asinh((_S1996 / _S1995))) / (F32_asinh((3.14159274101257324f / _S1995))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_12, float3  t_26, float3  out_dir_4, uint np_0)
{
    float3  _S1997 = worldToTangent(out_dir_4, t_26);
    float3  _S1998 = worldToTangent(in_dir_12, t_26);
    return (F32_frac((((F32_atan2((_S1997.z), (_S1997.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1998.z), (1.17549435082228751e-38f - _S1998.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_13, float3  t_27, uint p_16, float row_0, float column_0, float w_20, float alpha_11, uint nt_1, uint np_1)
{
    float3  _S1999 = worldToTangent(in_dir_13, t_27);
    uint _S2000 = p_16 % 4U;
    float _S2001 = w_20 * HAIR_WIDTHS_0[_S2000];
    float _S2002 = (F32_asin((clamp_1(dot_0(in_dir_13, t_27), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S2000] * alpha_11 + _S2001 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S2001))))));
    float _S2003 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1999.z), (1.17549435082228751e-38f - _S1999.x)));
    float _S2004 = (F32_cos((_S2002)));
    float3  _S2005 = tangentToWorld(make_float3 (_S2004 * (F32_cos((_S2003))), (F32_sin((_S2002))), _S2004 * (F32_sin((_S2003)))), t_27);
    return _S2005;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_13, BSDFMaterial material_23, float coverage_1)
{
    float3  _S2006;
    if((material_23.ior) == 1.0f)
    {
        float3  _S2007 = straightThrough(toward_1, n_13, material_23);
        _S2006 = _S2007;
    }
    else
    {
        _S2006 = make_float3 (0.0f);
    }
    return _S2006 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_9, Reservoir r_10, bool replay_3, float scale_4, Selection * sel_9)
{
    Domain _S2008 = dom_9;
    Reservoir _S2009 = r_10;
    Shift _S2010 = walk_0(&_S2008, &_S2009, replay_3, scale_4, sel_9);
    return _S2010;
}

__device__ Shift shift_hook(Domain dom_10, Reservoir r_11)
{
    Domain _S2011 = dom_10;
    Reservoir _S2012 = r_11;
    Shift _S2013 = shift_0(&_S2011, &_S2012);
    return _S2013;
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
        uint _S2014;
        if(i_31 < 2U)
        {
            _S2014 = x_29;
        }
        else
        {
            _S2014 = (x_29 + size_0 / 2U) & (size_0 - 1U);
        }
        uint l_5 = _S2014;
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
            uint _S2015 = hash(((r_12 ^ (t_28 << 16U)) ^ (k_4 << 28U)) ^ ((i_31 & 1U) << 31U));
            uint _S2016 = l_5 ^ (_S2015 & (size_0 - 1U));
            uint k_5 = k_4 + 1U;
            l_5 = r_12;
            r_12 = _S2016;
            k_4 = k_5;
        }
        uint _S2017 = l_5 + r_12 * size_0;
        uint _S2018 = size_0 * size_0;
        uint _S2019;
        if(_S2018 >= 65536U)
        {
            uint _S2020 = _S2017 / (_S2018 / 65536U);
            _S2019 = _S2020;
        }
        else
        {
            uint _S2021 = 65536U / _S2018;
            _S2019 = _S2017 * _S2021;
        }
        ranks_0[i_31] = _S2019;
        uint i_32 = i_31 + 1U;
        i_31 = i_32;
    }
    bool _S2022 = (ranks_0[int(0)]) == 65535U;
    bool _S2023;
    if(_S2022)
    {
        _S2023 = (ranks_0[int(1)]) == 65535U;
    }
    else
    {
        _S2023 = false;
    }
    bool _S2024 = (ranks_0[int(2)]) == 65535U;
    bool _S2025;
    if(_S2024)
    {
        _S2025 = (ranks_0[int(3)]) == 65535U;
    }
    else
    {
        _S2025 = false;
    }
    if(_S2023)
    {
        _S2023 = (ranks_0[int(3)]) != 65535U;
    }
    else
    {
        _S2023 = false;
    }
    if(_S2023)
    {
        _S2023 = true;
    }
    else
    {
        if(_S2025)
        {
            _S2023 = (ranks_0[int(1)]) != 65535U;
        }
        else
        {
            _S2023 = false;
        }
    }
    uint _S2026 = ranks_0[int(0)];
    if(_S2023)
    {
        i_31 = ranks_0[int(3)];
    }
    else
    {
        i_31 = ranks_0[int(1)];
    }
    return _S2026 | (i_31 << 16U);
}

__device__ uint3  noiseBlock(uint sweep_0, uint colour_0, uint block_0, uint size_1)
{
    uint _S2027 = hash(sweep_0 * 7919U + 1U);
    uint _S2028 = size_1 / 16U;
    uint _S2029 = block_0 % _S2028;
    uint _S2030 = block_0 / _S2028;
    uint _S2031 = _S2030 % _S2028;
    uint _S2032 = block_0 / (_S2028 * _S2028);
    uint3  _S2033 = make_uint3 (_S2029, _S2031, _S2032);
    uint3  _S2034 = make_uint3 (colour_0 & 1U, (colour_0 >> 1U) & 1U, colour_0 >> 2U);
    return _S2033 * make_uint3 (16U) + _S2034 * make_uint3 (8U) + make_uint3 (_S2027 & 7U, (_S2027 >> 3U) & 7U, (_S2027 >> 6U) & 7U);
}

#undef Matrix
