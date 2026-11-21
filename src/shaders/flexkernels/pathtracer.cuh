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
    float _S312 = rgb_to_greyscale(material_0.translucent);
    float _S313 = rgb_to_greyscale(material_0.albedo);
    float _S314 = _S312 / (_S313 + _S312);
    bool _S315 = _S312 > 0.0f;
    float _S316 = _slang_select(_S315, _S314,0.0f);
    return _S316;
}

static __device__ MaterialTerms MaterialTerms_x24init_0(float f0_0, float eta_level_0, float translucent_share_0, float toon_scale_0, float toon_component_0, float3  toon_0, float toon_a_0, float toon_s_0, float toon_b_0, bool toon_glossy_0, float toon_norm_0)
{
    MaterialTerms _S317;
    (&_S317)->f0 = f0_0;
    (&_S317)->eta_level = eta_level_0;
    (&_S317)->translucent_share = translucent_share_0;
    (&_S317)->toon_scale = toon_scale_0;
    (&_S317)->toon_component = toon_component_0;
    (&_S317)->toon = toon_0;
    (&_S317)->toon_a = toon_a_0;
    (&_S317)->toon_s = toon_s_0;
    (&_S317)->toon_b = toon_b_0;
    (&_S317)->toon_glossy = toon_glossy_0;
    (&_S317)->toon_norm = toon_norm_0;
    return _S317;
}

__device__ __forceinline__ MaterialTerms precomputeMaterial(BSDFMaterial material_1, float eta_i_0, float eta_o_0)
{
    float _S318 = (F32_min(((F32_sqrt((material_1.specular_level))) * (F32_abs((eta_i_0 - eta_o_0))) / (eta_i_0 + eta_o_0)), (0.9999847412109375f)));
    float _S319 = _S318 * _S318;
    float _S320 = (1.0f + _S318) / (1.0f - _S318);
    float3  _S321 = make_float3 (0.0f);
    float _S322 = material_1.toon.x;
    bool _S323 = _S322 < 0.0f;
    float _S324 = (F32_abs((_S322)));
    bool _S325 = _S324 > 0.0f;
    float toon_scale_1;
    float toon_component_1;
    float toon_a_1;
    float toon_s_1;
    float toon_b_1;
    float toon_norm_1;
    float3  toon_1;
    if(_S325)
    {
        float _S326 = (F32_min((_S324), (1.0f)));
        float _S327 = 1.0f - _S326;
        float _S328 = rgb_to_greyscale(material_1.albedo);
        float _S329 = _S326 * _S328;
        float3  _S330 = make_float3 (_S326) * material_1.albedo;
        float toon_a_2 = clamp_1(material_1.toon.y / _S322, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
        float toon_s_2 = clamp_1(material_1.toon.z / _S322, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
        float _S331 = (F32_min((toon_a_2 + toon_s_2), (1.57079637050628662f)));
        if(_S323)
        {
            toon_scale_1 = 1.0f - (F32_cos(((F32_min((_S331), (toon_a_2))))));
        }
        else
        {
            float _S332 = (F32_sin(((F32_min((_S331), (toon_a_2))))));
            toon_scale_1 = _S332 * _S332 / 2.0f;
        }
        bool _S333 = _S331 > toon_a_2;
        bool _S334;
        if(_S333)
        {
            _S334 = toon_s_2 > 0.0f;
        }
        else
        {
            _S334 = false;
        }
        if(_S334)
        {
            if(_S323)
            {
                float _S335 = (F32_cos((toon_a_2)));
                float _S336 = (F32_cos((_S331)));
                toon_component_1 = (1.0f + toon_a_2 / toon_s_2) * (_S335 - _S336) - ((F32_sin((_S331))) - _S331 * _S336 - ((F32_sin((toon_a_2))) - toon_a_2 * _S335)) / toon_s_2;
            }
            else
            {
                float _S337 = 2.0f * toon_a_2;
                float _S338 = (F32_cos((_S337)));
                float _S339 = 2.0f * _S331;
                float _S340 = (F32_cos((_S339)));
                toon_component_1 = (1.0f + toon_a_2 / toon_s_2) * (_S338 - _S340) / 4.0f - ((F32_sin((_S339))) / 8.0f - _S331 * _S340 / 4.0f - ((F32_sin((_S337))) / 8.0f - toon_a_2 * _S338 / 4.0f)) / toon_s_2;
            }
            float integral_0 = toon_scale_1 + toon_component_1;
            toon_scale_1 = integral_0;
        }
        float _S341 = 6.28318548202514648f * toon_scale_1;
        toon_scale_1 = _S327;
        toon_component_1 = _S329;
        toon_1 = _S330;
        toon_a_1 = toon_a_2;
        toon_s_1 = toon_s_2;
        toon_b_1 = _S331;
        toon_norm_1 = _S341;
    }
    else
    {
        toon_scale_1 = 1.0f;
        toon_component_1 = 0.0f;
        toon_1 = _S321;
        toon_a_1 = 0.0f;
        toon_s_1 = 0.0f;
        toon_b_1 = 0.0f;
        toon_norm_1 = 1.0f;
    }
    float _S342 = translucentShare(material_1);
    return MaterialTerms_x24init_0(_S319, _S320, _S342, toon_scale_1, toon_component_1, toon_1, toon_a_1, toon_s_1, toon_b_1, _S323, toon_norm_1);
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
    float _S343;
    if(e_1 > 0.0f)
    {
        _S343 = 1.0f;
    }
    else
    {
        if(e_1 < 0.0f)
        {
            _S343 = -1.0f;
        }
        else
        {
            _S343 = 0.0f;
        }
    }
    return _S343;
}

static __device__ AnisotropicFrame AnisotropicFrame_x24init_0(float3  tangent_0, float2  alphas_0)
{
    AnisotropicFrame _S344;
    (&_S344)->tangent = tangent_0;
    (&_S344)->alphas = alphas_0;
    return _S344;
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_1)
{
    float3  a_1 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S345 = (F32_abs((dot_0(n_1, a_1)))) > 0.9999847412109375f;
    float3  a_2;
    if(_S345)
    {
        float3  _S346 = make_float3 (1.0f, 0.0f, 0.0f);
        a_2 = _S346;
    }
    else
    {
        a_2 = a_1;
    }
    float3  _S347 = cross_0(n_1, a_2);
    float3  _S348 = ((((_S347)) * make_float3(rnorm3df(((_S347)).x, ((_S347)).y, ((_S347)).z))));
    float3  _S349 = cross_0(n_1, _S348);
    return make_float3 (v_0.x) * _S348 + make_float3 (v_0.y) * n_1 + make_float3 (v_0.z) * _S349;
}

__device__ AnisotropicFrame anisotropicFrame(BSDFMaterial material_2, float3  n_i_0)
{
    float _S350 = material_2.roughness;
    float _S351 = _S350 * _S350;
    bool _S352 = (material_2.anisotropy) == 0.0f;
    bool _S353;
    if(_S352)
    {
        _S353 = true;
    }
    else
    {
        _S353 = !(_S351 > 0.0f);
    }
    if(_S353)
    {
        return AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f));
    }
    float3  _S354 = material_2.tangent - n_i_0 * make_float3 (dot_0(n_i_0, material_2.tangent));
    float3  _S355 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_i_0);
    bool _S356 = (dot_0(_S354, _S354)) > 0.0f;
    float3  _S357 = _slang_select(_S356, _S354,_S355);
    float3  _S358 = ((((_S357)) * make_float3(rnorm3df(((_S357)).x, ((_S357)).y, ((_S357)).z))));
    float _S359 = 6.28318548202514648f * material_2.anisotropic_rotation;
    float _S360 = (F32_sqrt((1.0f - 0.89999997615814209f * (F32_abs((material_2.anisotropy))))));
    float _S361 = 1.0f / _S360;
    bool _S362 = (material_2.anisotropy) < 0.0f;
    float _S363 = _slang_select(_S362, _S361,_S360);
    return AnisotropicFrame_x24init_0(_S358 * make_float3 ((F32_cos((_S359)))) + cross_0(n_i_0, _S358) * make_float3 ((F32_sin((_S359)))), make_float2 (_S351 / _S363, _S351 * _S363));
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
    ViewTerms _S364;
    (&_S364)->v = v_1;
    (&_S364)->n_i = n_i_1;
    (&_S364)->frame = *frame_0;
    (&_S364)->scale = scale_1;
    (&_S364)->sheen_component = sheen_component_0;
    (&_S364)->sheen = sheen_0;
    (&_S364)->view = view_0;
    (&_S364)->rebounce = rebounce_0;
    (&_S364)->toon_view = toon_view_0;
    (&_S364)->toon_axis = toon_axis_0;
    return _S364;
}

__device__ __forceinline__ ViewTerms precomputeView(float3  in_dir_0, float3  n_2, BSDFMaterial material_3, MaterialTerms terms_0)
{
    float3  _S365 = negate_0(in_dir_0);
    float _S366 = sign_0(dot_0(n_2, _S365));
    float3  _S367 = n_2 * make_float3 (_S366);
    AnisotropicFrame _S368 = anisotropicFrame(material_3, _S367);
    float3  _S369 = make_float3 (1.0f);
    float3  _S370 = make_float3 (0.0f);
    float _S371 = rgb_to_greyscale(material_3.sheen);
    bool _S372 = _S371 > 0.0f;
    float sheen_component_1;
    float3  sheen_1;
    float3  view_1;
    float3  scale_2;
    if(_S372)
    {
        float _S373 = clamp_1((F32_sqrt(((F32_max((dot_0(_S367, _S365)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S374 = (U32_min((uint(_S373)), (22U)));
        float least_0 = (F32_sqrt((0.05000000074505806f)));
        float _S375 = (F32_sqrt((0.10000000149011612f)));
        bool _S376 = (material_3.velvet) > 0.0f;
        float _S377 = _slang_select(_S376, _S375,least_0);
        float _S378 = (clamp_1((F32_sqrt(((F32_max((material_3.sheen_roughness), (0.0f)))))), _S377, 1.0f) - _S377) / (1.0f - _S377) * 23.0f;
        uint _S379 = (U32_min((uint(_S378)), (22U)));
        uint _S380 = _S374 * 24U + _S379;
        float _S381 = _S373 - float(_S374);
        float _S382 = _S378 - float(_S379);
        uint _S383 = _S380 + 24U;
        float a_3 = SHEEN_ALBEDO_0[_S380] + (SHEEN_ALBEDO_0[_S383] - SHEEN_ALBEDO_0[_S380]) * _S381;
        uint _S384 = _S380 + 1U;
        uint _S385 = _S383 + 1U;
        float b_1 = SHEEN_ALBEDO_0[_S384] + (SHEEN_ALBEDO_0[_S385] - SHEEN_ALBEDO_0[_S384]) * _S381;
        float _S386 = (F32_exp((a_3 + (b_1 - a_3) * _S382)));
        if(_S376)
        {
            float a_4 = VELVET_ALBEDO_0[_S380] + (VELVET_ALBEDO_0[_S383] - VELVET_ALBEDO_0[_S380]) * _S381;
            float b_2 = VELVET_ALBEDO_0[_S384] + (VELVET_ALBEDO_0[_S385] - VELVET_ALBEDO_0[_S384]) * _S381;
            float _S387 = a_4 + (b_2 - a_4) * _S382;
            sheen_component_1 = _S387;
        }
        else
        {
            sheen_component_1 = _S386;
        }
        float _S388 = (F32_min((sheen_component_1), (1.0f)));
        float3  _S389 = make_float3 (1.0f) - material_3.sheen * make_float3 (_S388);
        float _S390 = rgb_to_greyscale(material_3.sheen);
        float _S391 = _S390 * _S388;
        float3  _S392 = material_3.sheen / make_float3 ((F32_max((sheen_component_1), (1.0f))));
        sheen_component_1 = _S391;
        sheen_1 = _S392;
        view_1 = _S365;
        scale_2 = _S389;
    }
    else
    {
        sheen_component_1 = 0.0f;
        sheen_1 = _S370;
        view_1 = _S370;
        scale_2 = _S369;
    }
    float3  scale_3 = scale_2 * make_float3 (terms_0.toon_scale);
    bool _S393 = (F32_abs((material_3.toon.x))) > 0.0f;
    float toon_view_1;
    float3  toon_axis_1;
    if(_S393)
    {
        float _S394 = dot_0(_S367, _S365);
        float _S395 = (F32_acos(((F32_min((_S394), (1.0f))))));
        if(_S395 < (terms_0.toon_a))
        {
            toon_view_1 = 1.0f;
        }
        else
        {
            toon_view_1 = (F32_max((1.0f - (_S395 - terms_0.toon_a) / (F32_max((terms_0.toon_s), (0.0000152587890625f)))), (0.0f)));
        }
        if(terms_0.toon_glossy)
        {
            float3  _S396 = make_float3 (2.0f * _S394) * _S367 - _S365;
            float3  _S397 = ((((_S396)) * make_float3(rnorm3df(((_S396)).x, ((_S396)).y, ((_S396)).z))));
            scale_2 = _S397;
        }
        else
        {
            scale_2 = _S367;
        }
        toon_axis_1 = scale_2;
    }
    else
    {
        toon_view_1 = 0.0f;
        toon_axis_1 = _S367;
    }
    float _S398 = _S368.alphas.x;
    float _S399 = (F32_sqrt(((F32_min((_S398), (_S368.alphas.y))))));
    bool _S400 = _S398 > 0.0f;
    float _S401 = _slang_select(_S400, _S399,material_3.roughness);
    float _S402 = _S401 * _S401;
    float _S403 = (F32_pow((_S402), (1.81585001945495605f))) * (2.15371990203857422f - 0.73285001516342163f * _S402) / (1.0f + 1.28094995021820068f * _S402);
    bool _S404 = _S402 > 0.0f;
    float _S405 = _slang_select(_S404, _S403,0.0f);
    float _S406 = clamp_1(dot_0(_S367, _S365), 0.0f, 1.0f);
    float _S407 = _S402 * _S401;
    float _S408 = (F32_min((1.00064504146575928f - _S401 * (0.00375499995425344f + _S406 * (-0.04133399948477745f + _S406 * (-0.90938502550125122f + _S406 * 0.35275399684906006f))) - _S402 * (0.27602800726890564f + _S406 * (1.27023398876190186f + _S406 * 0.04740000143647194f)) - _S407 * (0.31452900171279907f - _S406 * 0.34830701351165771f) + _S407 * _S401 * 0.27229699492454529f), (1.0f)));
    float3  _S409 = min_1(make_float3 (1.0f) / (make_float3 (1.0f) - material_3.albedo * make_float3 (_S405)), make_float3 (1.0f / (F32_max((_S408), (0.0000152587890625f)))));
    AnisotropicFrame _S410 = _S368;
    ViewTerms _S411 = ViewTerms_x24init_0(_S365, _S367, &_S410, scale_3, sheen_component_1, sheen_1, view_1, _S409, toon_view_1, toon_axis_1);
    return _S411;
}

struct SampleBSDF
{
    float3  unit_direction;
    float3  throughput;
    uint random_state;
    bool refracted;
    uint lobe;
    float pdf;
};

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
    float3  _S412 = make_float3 (alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z);
    float3  _S413 = ((((_S412)) * make_float3(rnorm3df(((_S412)).x, ((_S412)).y, ((_S412)).z))));
    float _S414 = _S413.x;
    float _S415 = _S413.y;
    float _S416 = _S414 * _S414 + _S415 * _S415;
    float3  _S417;
    if(_S416 > 0.0f)
    {
        float3  _S418 = make_float3 (- _S415, _S414, 0.0f);
        float _S419 = (rsqrtf((_S416)));
        _S417 = _S418 * make_float3 (_S419);
    }
    else
    {
        _S417 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S420 = cross_0(_S413, _S417);
    float _S421 = (F32_sqrt((U1_0)));
    float _S422 = 6.28318548202514648f * U2_0;
    float _S423 = _S421 * (F32_cos((_S422)));
    float t2_0 = _S421 * (F32_sin((_S422)));
    float _S424 = 0.5f * (1.0f + _S413.z);
    float t2_1 = (1.0f - _S424) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S423 * _S423)))))) + _S424 * t2_0;
    float3  _S425 = make_float3 (_S423) * _S417 + make_float3 (t2_1) * _S420;
    float _S426 = unshared_0(_S423);
    float _S427 = unshared_0(_S423);
    float3  _S428 = _S425 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S426 * _S427 - t2_1 * t2_1))))))) * _S413;
    float3  _S429 = make_float3 (alpha_0 * _S428.x, alpha_0 * _S428.y, (F32_max((0.0f), (_S428.z))));
    float3  _S430 = ((((_S429)) * make_float3(rnorm3df(((_S429)).x, ((_S429)).y, ((_S429)).z))));
    return _S430;
}

__device__ float3  worldToTangent(float3  v_2, float3  n_4)
{
    float3  a_5 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S431 = (F32_abs((dot_0(n_4, a_5)))) > 0.9999847412109375f;
    float3  a_6;
    if(_S431)
    {
        float3  _S432 = make_float3 (1.0f, 0.0f, 0.0f);
        a_6 = _S432;
    }
    else
    {
        a_6 = a_5;
    }
    float3  _S433 = cross_0(n_4, a_6);
    float3  _S434 = ((((_S433)) * make_float3(rnorm3df(((_S433)).x, ((_S433)).y, ((_S433)).z))));
    float3  _S435 = cross_0(n_4, _S434);
    return make_float3 (dot_0(v_2, _S434), dot_0(v_2, n_4), dot_0(v_2, _S435));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_3, float3  n_i_2, float alpha_1, AnisotropicFrame frame_1, uint * random_state_2)
{
    Random _S436 = pcg(*random_state_2);
    Random _S437 = pcg(_S436.state);
    *random_state_2 = _S437.state;
    float _S438 = frame_1.alphas.x;
    bool _S439 = _S438 > 0.0f;
    if(_S439)
    {
        float3  _S440 = anisotropicLocal(v_3, frame_1.tangent, n_i_2);
        float _S441 = frame_1.alphas.y;
        float3  _S442 = make_float3 (_S438 * _S440.x, _S441 * _S440.y, _S440.z);
        float3  _S443 = ((((_S442)) * make_float3(rnorm3df(((_S442)).x, ((_S442)).y, ((_S442)).z))));
        float3  _S444 = sampleGGXVNDF(_S443, 1.0f, _S436.value, _S437.value);
        float3  _S445 = make_float3 (_S438 * _S444.x, _S441 * _S444.y, _S444.z);
        float3  _S446 = ((((_S445)) * make_float3(rnorm3df(((_S445)).x, ((_S445)).y, ((_S445)).z))));
        return make_float3 (_S446.x) * frame_1.tangent + make_float3 (_S446.y) * cross_0(n_i_2, frame_1.tangent) + make_float3 (_S446.z) * n_i_2;
    }
    float3  _S447 = worldToTangent(v_3, n_i_2);
    float3  _S448 = sampleGGXVNDF(float3 {_S447.x, _S447.z, _S447.y}, alpha_1, _S436.value, _S437.value);
    float3  _S449 = float3 {_S448.x, _S448.z, _S448.y};
    float3  _S450 = tangentToWorld(_S449, n_i_2);
    return _S450;
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

static __device__ float3  refract_0(float3  i_6, float3  n_5, float eta_0)
{
    float _S451 = dot_0(n_5, i_6);
    float _S452 = 1.0f - eta_0 * eta_0 * (1.0f - _S451 * _S451);
    if(_S452 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_6 - make_float3 (eta_0 * _S451 + (F32_sqrt((_S452)))) * n_5;
}

__device__ float fresnel(float cos_theta_0, float eta_i_1, float eta_o_1)
{
    float _S453 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S454 = eta_i_1 / eta_o_1 * _S453;
    bool _S455 = _S454 < 1.0f;
    float kr_0;
    if(_S455)
    {
        float _S456 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S454 * _S454))))));
        float _S457 = eta_o_1 * cos_theta_0;
        float _S458 = eta_i_1 * _S456;
        float _S459 = (_S457 - _S458) / (_S457 + _S458);
        float _S460 = eta_i_1 * cos_theta_0;
        float _S461 = eta_o_1 * _S456;
        float _S462 = (_S460 - _S461) / (_S460 + _S461);
        float _S463 = (_S459 * _S459 + _S462 * _S462) / 2.0f;
        kr_0 = _S463;
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

__device__ float anisotropicG1(float3  w_1, float2  alphas_1)
{
    float _S464 = (F32_max((w_1.z), (0.0f)));
    return 2.0f * _S464 / (_S464 + length_0(make_float3 (alphas_1.x * w_1.x, alphas_1.y * w_1.y, _S464)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_2)
{
    float _S465 = alphas_2.x;
    float _S466 = h_0.x / _S465;
    float _S467 = alphas_2.y;
    float _S468 = h_0.y / _S467;
    float _S469 = h_0.z;
    float _S470 = _S466 * _S466 + _S468 * _S468 + _S469 * _S469;
    return 1.0f / (F32_max((3.14159274101257324f * _S465 * _S467 * _S470 * _S470), (1.17549435082228751e-38f)));
}

static __device__ HalfTerms HalfTerms_x24init_0(float v_dot_h_0, float n_dot_h_0, float3  refracted_1, float3  F_0, float F_greyscale_0, float reflect_weight_0, float3  diffuse_weight_0, float3  refract_weight_0, float p_diffuse_0, float p_reflect_0, float p_refract_0, float translucent_share_1, float3  sheen_2, float p_sheen_velvet_0, float3  view_2, float3  tangent_1, float2  alphas_3, float visible_0, float p_toon_0, float3  toon_2, float toon_a_3, float toon_s_3, float toon_b_2, bool toon_glossy_1, float toon_norm_2, float toon_view_2, float3  toon_axis_2)
{
    HalfTerms _S471;
    (&_S471)->v_dot_h = v_dot_h_0;
    (&_S471)->n_dot_h = n_dot_h_0;
    (&_S471)->refracted = refracted_1;
    (&_S471)->F = F_0;
    (&_S471)->F_greyscale = F_greyscale_0;
    (&_S471)->reflect_weight = reflect_weight_0;
    (&_S471)->diffuse_weight = diffuse_weight_0;
    (&_S471)->refract_weight = refract_weight_0;
    (&_S471)->p_diffuse = p_diffuse_0;
    (&_S471)->p_reflect = p_reflect_0;
    (&_S471)->p_refract = p_refract_0;
    (&_S471)->translucent_share = translucent_share_1;
    (&_S471)->sheen = sheen_2;
    (&_S471)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S471)->view = view_2;
    (&_S471)->tangent = tangent_1;
    (&_S471)->alphas = alphas_3;
    (&_S471)->visible = visible_0;
    (&_S471)->p_toon = p_toon_0;
    (&_S471)->toon = toon_2;
    (&_S471)->toon_a = toon_a_3;
    (&_S471)->toon_s = toon_s_3;
    (&_S471)->toon_b = toon_b_2;
    (&_S471)->toon_glossy = toon_glossy_1;
    (&_S471)->toon_norm = toon_norm_2;
    (&_S471)->toon_view = toon_view_2;
    (&_S471)->toon_axis = toon_axis_2;
    return _S471;
}

__device__ __forceinline__ HalfTerms precomputeHalf(float3  in_dir_1, float3  ggx_n_0, BSDFMaterial material_4, float eta_i_2, float eta_o_2, MaterialTerms terms_1, ViewTerms view_terms_0)
{
    float _S472 = dot_0(ggx_n_0, view_terms_0.v);
    float _S473 = dot_0(view_terms_0.n_i, ggx_n_0);
    float _S474 = eta_i_2 / eta_o_2;
    float3  _S475 = refract_0(in_dir_1, ggx_n_0, _S474);
    float3  _S476 = ((((_S475)) * make_float3(rnorm3df(((_S475)).x, ((_S475)).y, ((_S475)).z))));
    float _S477 = (F32_abs((_S472)));
    bool _S478 = eta_i_2 > eta_o_2;
    float visible_1;
    if(_S478)
    {
        visible_1 = terms_1.eta_level;
    }
    else
    {
        visible_1 = 1.0f;
    }
    float _S479;
    if(_S478)
    {
        _S479 = 1.0f;
    }
    else
    {
        _S479 = terms_1.eta_level;
    }
    float _S480 = fresnel(_S477, visible_1, _S479);
    bool _S481 = (eta_i_2 * eta_i_2 * (1.0f - _S472 * _S472)) >= (eta_o_2 * eta_o_2);
    float3  _S482;
    if(_S481)
    {
        _S482 = make_float3 (1.0f);
    }
    else
    {
        float3  _S483 = material_4.specular_tint * make_float3 (terms_1.f0);
        _S482 = _S483 + (make_float3 (1.0f) - _S483) * make_float3 (_S480 - terms_1.f0) / make_float3 (1.0f - terms_1.f0);
    }
    float3  _S484 = mix_0(_S482, material_4.albedo * view_terms_0.rebounce, material_4.metallic);
    float3  F_1 = _S484 * view_terms_0.scale;
    float _S485 = rgb_to_greyscale(F_1);
    float _S486 = 1.0f - material_4.metallic;
    float3  _S487 = make_float3 (1.0f) - _S482;
    float3  _S488 = make_float3 ((1.0f - material_4.transmission) * _S486) * _S487 * view_terms_0.scale;
    float3  _S489 = make_float3 (material_4.transmission * _S486) * _S487 * view_terms_0.scale;
    float _S490 = (F32_max((_S485), (0.0f)));
    float _S491 = rgb_to_greyscale(_S488);
    float _S492 = (F32_max((_S491), (0.0f)));
    float _S493 = rgb_to_greyscale(_S489);
    float _S494 = sign_0(length_0(_S476));
    float _S495 = (F32_max((_S493 * _S494), (0.0f)));
    float _S496 = _S490 + _S492 + _S495 + terms_1.toon_component;
    float _S497 = (F32_min((view_terms_0.sheen_component), (1.0f)));
    bool _S498 = (view_terms_0.sheen_component) > 0.0f;
    bool _S499;
    if(_S498)
    {
        _S499 = !(_S496 > 0.0f);
    }
    else
    {
        _S499 = false;
    }
    float _S500 = _slang_select(_S499, 1.0f,_S497);
    float _S501 = (1.0f - _S500) / (F32_max((_S496), (0.0000152587890625f)));
    float _S502 = _S492 * _S501;
    float _S503 = _S490 * _S501;
    float _S504 = _S495 * _S501;
    bool _S505 = (view_terms_0.frame.alphas.x) > 0.0f;
    if(_S505)
    {
        float3  _S506 = anisotropicLocal(view_terms_0.v, view_terms_0.frame.tangent, view_terms_0.n_i);
        float _S507 = anisotropicG1(_S506, view_terms_0.frame.alphas);
        float3  _S508 = anisotropicLocal(ggx_n_0, view_terms_0.frame.tangent, view_terms_0.n_i);
        float _S509 = anisotropicD(_S508, view_terms_0.frame.alphas);
        float _S510 = _S507 * _S509;
        visible_1 = _S510;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return HalfTerms_x24init_0(_S472, _S473, _S476, F_1, _S485, 1.0f, _S488, _S489, _S502, _S503, _S504, terms_1.translucent_share, view_terms_0.sheen, _S500, view_terms_0.view, view_terms_0.frame.tangent, view_terms_0.frame.alphas, visible_1, terms_1.toon_component * _S501, terms_1.toon, terms_1.toon_a, terms_1.toon_s, terms_1.toon_b, terms_1.toon_glossy, terms_1.toon_norm, view_terms_0.toon_view, view_terms_0.toon_axis);
}

__device__ float smithG1(float alpha_2, float n_dot_x_0)
{
    float _S511 = alpha_2 * alpha_2;
    float _S512 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S511 + (1.0f - _S511) * n_dot_x_0 * n_dot_x_0))));
    bool _S513 = alpha_2 > 0.0f;
    float _S514 = _slang_select(_S513, _S512,1.0f);
    return _S514;
}

__device__ float trowbridgeReitz(float alpha_3, float n_dot_h_1)
{
    float _S515 = alpha_3 * alpha_3;
    float _S516 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S515 * n_dot_h_1 * n_dot_h_1;
    return _S515 / (F32_max((3.14159274101257324f * _S516 * _S516), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float lobeDensity(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_4, HalfTerms lobes_0, float eta_i_3, float eta_o_3, uint lobe_0)
{
    bool _S517 = lobe_0 == 0U;
    if(_S517)
    {
        float _S518 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
        float _S519 = lobes_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
        float _S520 = 1.0f - lobes_0.translucent_share;
        bool _S521 = n_i_dot_l_0 < 0.0f;
        float _S522 = _slang_select(_S521, lobes_0.translucent_share,_S520);
        float _S523 = _S519 * _S522;
        bool _S524 = (lobes_0.translucent_share) > 0.0f;
        float _S525 = _slang_select(_S524, _S523,_S518);
        bool _S526 = n_i_dot_v_0 > 0.0f;
        float _S527 = _slang_select(_S526, _S525,0.0f);
        return _S527;
    }
    bool _S528 = lobe_0 == 4U;
    bool _S529;
    if(_S528)
    {
        float _S530 = lobes_0.p_sheen_velvet * 0.5f * 0.31830987334251404f;
        bool _S531 = n_i_dot_l_0 > 0.0f;
        if(_S531)
        {
            _S529 = n_i_dot_v_0 > 0.0f;
        }
        else
        {
            _S529 = false;
        }
        float _S532 = _slang_select(_S529, _S530,0.0f);
        return _S532;
    }
    bool _S533 = lobe_0 == 6U;
    float pdf_h_0;
    if(_S533)
    {
        float _S534 = _slang_select(lobes_0.toon_glossy, l_dot_h_0,n_i_dot_l_0);
        float _S535 = (F32_acos((clamp_1(_S534, -1.0f, 1.0f))));
        if(_S535 < (lobes_0.toon_a))
        {
            pdf_h_0 = 1.0f;
        }
        else
        {
            pdf_h_0 = (F32_max((1.0f - (_S535 - lobes_0.toon_a) / (F32_max((lobes_0.toon_s), (0.0000152587890625f)))), (0.0f)));
        }
        float _S536 = lobes_0.p_toon * pdf_h_0;
        float _S537 = _slang_select(lobes_0.toon_glossy, 1.0f,n_i_dot_l_0);
        float _S538 = _S536 * _S537 / lobes_0.toon_norm;
        if(lobes_0.toon_glossy)
        {
            _S529 = true;
        }
        else
        {
            _S529 = n_i_dot_l_0 > 0.0f;
        }
        float _S539 = _slang_select(_S529, _S538,0.0f);
        return _S539;
    }
    float _S540 = smithG1(alpha_4, n_i_dot_v_0);
    float _S541 = _S540 * lobes_0.v_dot_h;
    float _S542 = trowbridgeReitz(alpha_4, lobes_0.n_dot_h);
    float _S543 = _S541 * _S542 / n_i_dot_v_0;
    bool _S544 = alpha_4 > 0.0f;
    if(_S544)
    {
        _S529 = (lobes_0.v_dot_h) > 0.0f;
    }
    else
    {
        _S529 = false;
    }
    if(_S529)
    {
        _S529 = (lobes_0.n_dot_h) > 0.0f;
    }
    else
    {
        _S529 = false;
    }
    if(_S529)
    {
        _S529 = n_i_dot_v_0 > 0.0f;
    }
    else
    {
        _S529 = false;
    }
    float _S545 = _slang_select(_S529, _S543,0.0f);
    bool _S546 = (lobes_0.alphas.x) > 0.0f;
    if(_S546)
    {
        float _S547 = lobes_0.visible * lobes_0.v_dot_h / n_i_dot_v_0;
        bool _S548 = (lobes_0.v_dot_h) > 0.0f;
        if(_S548)
        {
            _S529 = (lobes_0.n_dot_h) > 0.0f;
        }
        else
        {
            _S529 = false;
        }
        if(_S529)
        {
            _S529 = n_i_dot_v_0 > 0.0f;
        }
        else
        {
            _S529 = false;
        }
        float _S549 = _slang_select(_S529, _S547,0.0f);
        pdf_h_0 = _S549;
    }
    else
    {
        pdf_h_0 = _S545;
    }
    bool _S550 = lobe_0 == 1U;
    if(_S550)
    {
        float _S551 = eta_i_3 * lobes_0.v_dot_h + eta_o_3 * l_dot_h_0;
        float _S552 = lobes_0.p_refract * pdf_h_0 * eta_o_3 * eta_o_3 * (F32_abs((l_dot_h_0))) / (_S551 * _S551);
        bool _S553 = eta_i_3 != eta_o_3;
        if(_S553)
        {
            _S529 = l_dot_h_0 < 0.0f;
        }
        else
        {
            _S529 = false;
        }
        float _S554 = _slang_select(_S529, _S552,0.0f);
        return _S554;
    }
    float _S555 = lobes_0.p_reflect * pdf_h_0 / (4.0f * lobes_0.v_dot_h);
    bool _S556 = pdf_h_0 > 0.0f;
    float _S557 = _slang_select(_S556, _S555,0.0f);
    return _S557;
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_0, uint random_state_3, bool refracted_2, uint lobe_1, float pdf_0)
{
    SampleBSDF _S558;
    (&_S558)->unit_direction = unit_direction_1;
    (&_S558)->throughput = throughput_0;
    (&_S558)->random_state = random_state_3;
    (&_S558)->refracted = refracted_2;
    (&_S558)->lobe = lobe_1;
    (&_S558)->pdf = pdf_0;
    return _S558;
}

__device__ __forceinline__ float3  lobeThroughput(float3  l_0, float3  n_i_3, float alpha_5, BSDFMaterial material_5, HalfTerms lobes_1, uint lobe_2)
{
    bool _S559 = lobe_2 == 0U;
    if(_S559)
    {
        bool _S560 = (dot_0(n_i_3, l_0)) < 0.0f;
        float3  _S561 = _slang_select(_S560, material_5.translucent,material_5.albedo);
        float _S562 = 1.0f - lobes_1.translucent_share;
        float _S563 = _slang_select(_S560, lobes_1.translucent_share,_S562);
        float3  _S564 = _S561 / make_float3 (_S563);
        bool _S565 = (lobes_1.translucent_share) > 0.0f;
        float3  _S566 = _slang_select(_S565, _S564,material_5.albedo);
        return lobes_1.diffuse_weight * _S566 / make_float3 (lobes_1.p_diffuse);
    }
    bool _S567 = lobe_2 == 4U;
    float f_1;
    if(_S567)
    {
        float3  _S568 = l_0 + lobes_1.view;
        float3  _S569 = ((((_S568)) * make_float3(rnorm3df(((_S568)).x, ((_S568)).y, ((_S568)).z))));
        float _S570 = dot_0(n_i_3, _S569);
        float _S571 = (F32_max((dot_0(n_i_3, l_0)), (0.0f)));
        float _S572 = (F32_max((dot_0(n_i_3, lobes_1.view)), (0.0f)));
        float _S573 = 1.0f / (F32_max((material_5.sheen_roughness), (0.05000000074505806f)));
        float _S574 = 1.0f - _S570 * _S570;
        float _S575 = (2.0f + _S573) * (F32_pow(((F32_max((_S574), (0.0f)))), (0.5f * _S573))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S571 + _S572 - _S571 * _S572)), (0.0000152587890625f)));
        bool _S576 = (material_5.velvet) > 0.0f;
        if(_S576)
        {
            float _S577 = (F32_max((material_5.sheen_roughness), (0.00999999977648258f)));
            float _S578 = _S577 * _S577;
            float _S579 = (F32_max((_S574), (0.0000152587890625f)));
            float _S580 = (F32_exp((- _S570 * _S570 / (_S579 * _S578)))) / (3.14159274101257324f * _S578 * _S579 * _S579) * (F32_min((1.0f), (2.0f * _S570 * (F32_min((_S571), (_S572))) / (F32_max(((F32_abs((dot_0(_S569, lobes_1.view))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S571 * _S572), (0.0000152587890625f)));
            f_1 = _S580;
        }
        else
        {
            f_1 = _S575;
        }
        return lobes_1.sheen * make_float3 (f_1 * _S571 * 2.0f * 3.14159274101257324f / lobes_1.p_sheen_velvet);
    }
    bool _S581 = lobe_2 == 6U;
    if(_S581)
    {
        float _S582 = (F32_max((dot_0(n_i_3, l_0)), (0.0f)));
        float _S583 = _slang_select(lobes_1.toon_glossy, _S582,lobes_1.toon_view);
        return lobes_1.toon * make_float3 (_S583) / make_float3 (lobes_1.p_toon);
    }
    bool _S584 = lobe_2 == 1U;
    if(_S584)
    {
        float _S585 = - dot_0(n_i_3, l_0);
        float _S586 = smithG1(alpha_5, (F32_max((_S585), (0.0f))));
        bool _S587 = (lobes_1.alphas.x) > 0.0f;
        if(_S587)
        {
            float3  _S588 = negate_0(n_i_3);
            float3  _S589 = anisotropicLocal(l_0, lobes_1.tangent, _S588);
            float _S590 = anisotropicG1(_S589, lobes_1.alphas);
            f_1 = _S590;
        }
        else
        {
            f_1 = _S586;
        }
        return lobes_1.refract_weight * make_float3 (f_1) * material_5.albedo / make_float3 (lobes_1.p_refract);
    }
    float _S591 = dot_0(n_i_3, l_0);
    float _S592 = smithG1(alpha_5, (F32_max((_S591), (0.0f))));
    bool _S593 = (lobes_1.alphas.x) > 0.0f;
    if(_S593)
    {
        float3  _S594 = anisotropicLocal(l_0, lobes_1.tangent, n_i_3);
        float _S595 = anisotropicG1(_S594, lobes_1.alphas);
        f_1 = _S595;
    }
    else
    {
        f_1 = _S592;
    }
    return make_float3 (lobes_1.reflect_weight * f_1) * lobes_1.F / make_float3 (lobes_1.p_reflect);
}

__device__ __forceinline__ SampleBSDF lobeBSDF(float3  in_dir_2, float3  out_dir_0, float3  n_6, BSDFMaterial material_6, float eta_i_4, float eta_o_4, uint lobe_3, uint random_init_0, MaterialTerms terms_2, ViewTerms view_terms_1)
{
    uint random_state_4 = random_init_0;
    float3  _S596 = negate_0(in_dir_2);
    float _S597 = dot_0(n_6, _S596);
    float _S598 = sign_0(_S597);
    float3  _S599 = n_6 * make_float3 (_S598);
    float _S600 = material_6.roughness;
    float _S601 = _S600 * _S600;
    float3  _S602 = _S596 + out_dir_0;
    float3  ggx_n_1 = ((((_S602)) * make_float3(rnorm3df(((_S602)).x, ((_S602)).y, ((_S602)).z))));
    float _S603 = dot_0(out_dir_0, ggx_n_1);
    bool _S604 = lobe_3 == 0U;
    float3  ggx_n_2;
    if(_S604)
    {
        float3  _S605 = sampleHalfVector(_S596, _S599, _S601, view_terms_1.frame, &random_state_4);
        ggx_n_2 = _S605;
    }
    else
    {
        ggx_n_2 = ggx_n_1;
    }
    bool _S606 = lobe_3 == 1U;
    float l_dot_h_1;
    if(_S606)
    {
        float3  _S607 = negate_0(make_float3 (eta_i_4) * _S596 + make_float3 (eta_o_4) * out_dir_0);
        float3  _S608 = ((((_S607)) * make_float3(rnorm3df(((_S607)).x, ((_S607)).y, ((_S607)).z))));
        float _S609 = sign_0(dot_0(_S607, _S599));
        float3  ggx_n_3 = _S608 * make_float3 (_S609);
        float _S610 = dot_0(out_dir_0, ggx_n_3);
        ggx_n_2 = ggx_n_3;
        l_dot_h_1 = _S610;
    }
    else
    {
        l_dot_h_1 = _S603;
    }
    bool _S611 = lobe_3 == 2U;
    if(_S611)
    {
        float3  _S612 = ((((_S602)) * make_float3(rnorm3df(((_S602)).x, ((_S602)).y, ((_S602)).z))));
        ggx_n_2 = _S612;
    }
    bool _S613 = lobe_3 == 4U;
    if(_S613)
    {
        float3  _S614 = ((((_S602)) * make_float3(rnorm3df(((_S602)).x, ((_S602)).y, ((_S602)).z))));
        ggx_n_2 = _S614;
    }
    bool _S615 = lobe_3 == 6U;
    if(_S615)
    {
        float3  _S616 = sampleHalfVector(_S596, _S599, _S601, view_terms_1.frame, &random_state_4);
        float _S617 = dot_0(out_dir_0, view_terms_1.toon_axis);
        ggx_n_2 = _S616;
        l_dot_h_1 = _S617;
    }
    HalfTerms _S618 = precomputeHalf(in_dir_2, ggx_n_2, material_6, eta_i_4, eta_o_4, terms_2, view_terms_1);
    float _S619 = lobeDensity(dot_0(_S599, out_dir_0), l_dot_h_1, (F32_abs((_S597))), _S601, _S618, eta_i_4, eta_o_4, lobe_3);
    bool _S620 = !(_S619 > 0.0f);
    if(_S620)
    {
        float3  _S621 = make_float3 (0.0f);
        return SampleBSDF_x24init_0(_S621, _S621, 0U, false, 0U, 0.0f);
    }
    float3  _S622 = lobeThroughput(out_dir_0, _S599, _S601, material_6, _S618, lobe_3);
    return SampleBSDF_x24init_0(out_dir_0, _S622, random_state_4, _S606, lobe_3, _S619);
}

__device__ __forceinline__ float3  neeBSDF(float3  in_dir_3, float3  dir_3, float3  n_7, BSDFMaterial material_7, float eta_i_5, float eta_o_5, bool refracted_3, float pdf_1, bool power_0, uint random_state_5, MaterialTerms terms_3, ViewTerms view_terms_2)
{
    float3  _S623 = make_float3 (0.0f);
    uint _S624;
    if((F32_abs((material_7.toon.x))) > 0.0f)
    {
        _S624 = 5U;
    }
    else
    {
        _S624 = 4U;
    }
    uint i_7 = 0U;
    float3  f_2 = _S623;
    for(;;)
    {
        if(i_7 < _S624)
        {
        }
        else
        {
            break;
        }
        uint _S625;
        if(i_7 == 3U)
        {
            _S625 = 4U;
        }
        else
        {
            if(i_7 == 4U)
            {
                _S625 = 6U;
            }
            else
            {
                _S625 = i_7;
            }
        }
        bool _S626 = _S625 == 0U;
        if(_S626)
        {
        }
        bool _S627;
        if(_S626)
        {
            float _S628 = rgb_to_greyscale(material_7.translucent);
            _S627 = _S628 > 0.0f;
        }
        else
        {
            _S627 = false;
        }
        bool _S629;
        if(_S627)
        {
            float _S630 = dot_0(n_7, dir_3);
            float3  _S631 = negate_0(in_dir_3);
            _S629 = ((_S630 * dot_0(n_7, _S631)) < 0.0f) == refracted_3;
        }
        else
        {
            _S629 = (_S625 == 1U) == refracted_3;
        }
        float3  f_3;
        if(_S629)
        {
            SampleBSDF _S632 = lobeBSDF(in_dir_3, dir_3, n_7, material_7, eta_i_5, eta_o_5, _S625, random_state_5, terms_3, view_terms_2);
            bool _S633 = (_S632.pdf) > 0.0f;
            if(_S633)
            {
                if(power_0)
                {
                    float _S634 = _S632.pdf / pdf_1;
                    float3  f_4 = f_2 + _S632.throughput * make_float3 (_S632.pdf) / make_float3 (pdf_1 * (1.0f + _S634 * _S634));
                    f_3 = f_4;
                }
                else
                {
                    float3  f_5 = f_2 + _S632.throughput * make_float3 (_S632.pdf) / make_float3 (_S632.pdf + pdf_1);
                    f_3 = f_5;
                }
            }
            else
            {
                f_3 = f_2;
            }
        }
        else
        {
            f_3 = f_2;
        }
        uint i_8 = i_7 + 1U;
        i_7 = i_8;
        f_2 = f_3;
    }
    return f_2;
}

__device__ float3  skyBSDF(float3  in_dir_4, float3  dir_4, FKSurface surface_1, float2  eta_1, bool is_inside_2, float pdf_2, uint random_state_6)
{
    bool _S635 = wrongSide_0(is_inside_2, false, dir_4, surface_1.geometry_n);
    float _S636 = eta_1.x;
    float _S637 = eta_1.y;
    MaterialTerms _S638 = precomputeMaterial(surface_1.material, _S636, _S637);
    ViewTerms _S639 = precomputeView(in_dir_4, surface_1.smooth_n, surface_1.material, _S638);
    float3  _S640 = neeBSDF(in_dir_4, dir_4, surface_1.smooth_n, surface_1.material, _S636, _S637, _S635, pdf_2, false, random_state_6, _S638, _S639);
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

static __device__ __noinline__ float3  skyColor_0(float3  in_dir_5, float3  dir_6, FKSurface * surface_2, float2  eta_2, bool is_inside_3, float pdf_3, uint random_state_8, uint depth_0)
{
    bool _S642 = wrongSide_0(is_inside_3, false, dir_6, surface_2->geometry_n);
    float3  _S643 = surface_2->smooth_n;
    BSDFMaterial _S644 = surface_2->material;
    float _S645 = eta_2.x;
    float _S646 = eta_2.y;
    MaterialTerms _S647 = precomputeMaterial(surface_2->material, _S645, _S646);
    ViewTerms _S648 = precomputeView(in_dir_5, _S643, _S644, _S647);
    float3  _S649 = make_float3 (0.0f);
    uint _S650;
    if((F32_abs(((&surface_2->material)->toon.x))) > 0.0f)
    {
        _S650 = 5U;
    }
    else
    {
        _S650 = 4U;
    }
    uint i_9 = 0U;
    float3  color_1 = _S649;
    for(;;)
    {
        if(i_9 < _S650)
        {
        }
        else
        {
            break;
        }
        uint _S651;
        if(i_9 == 3U)
        {
            _S651 = 4U;
        }
        else
        {
            if(i_9 == 4U)
            {
                _S651 = 6U;
            }
            else
            {
                _S651 = i_9;
            }
        }
        bool _S652 = _S651 == 0U;
        if(_S652)
        {
        }
        bool _S653;
        if(_S652)
        {
            float _S654 = rgb_to_greyscale((&surface_2->material)->translucent);
            _S653 = _S654 > 0.0f;
        }
        else
        {
            _S653 = false;
        }
        bool _S655;
        if(_S653)
        {
            float _S656 = dot_0(_S643, dir_6);
            float3  _S657 = negate_0(in_dir_5);
            _S655 = ((_S656 * dot_0(_S643, _S657)) < 0.0f) == _S642;
        }
        else
        {
            _S655 = (_S651 == 1U) == _S642;
        }
        if(_S655)
        {
            SampleBSDF _S658 = lobeBSDF(in_dir_5, dir_6, _S643, _S644, _S645, _S646, _S651, random_state_8, _S647, _S648);
            bool _S659 = (_S658.pdf) > 0.0f;
            float3  color_2;
            if(_S659)
            {
                float3  _S660 = _S658.throughput * make_float3 (_S658.pdf) / make_float3 (_S658.pdf + pdf_3);
                float3  _S661 = (fcptEnvMapSample((dir_6), (depth_0), (_S651)));
                float3  color_3 = color_1 + _S660 * _S661;
                color_2 = color_3;
            }
            else
            {
                color_2 = color_1;
            }
            color_1 = color_2;
        }
        uint i_10 = i_9 + 1U;
        i_9 = i_10;
    }
    return color_1;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_3, float2  eta_3, bool is_inside_4, uint init_random_state_0, uint lobe_state_0, ShadowContext * context_2)
{
    uint2  _S662 = (fcptEnvironmentCdfSize());
    uint2  _S663 = make_uint2 (1U, 0U);
    uint2  _S664 = _S662 - _S663;
    Random _S665 = pcg(init_random_state_0);
    Random _S666 = pcg(_S665.state);
    Random _S667 = pcg(_S666.state);
    Random _S668 = pcg(_S667.state);
    uint _S669 = _S664.x;
    uint _S670 = searchCDF_0(make_uint2 (_S669, 0U), make_uint2 (0U, 1U), _S664.y, _S665.value);
    uint _S671 = searchCDF_0(make_uint2 (0U, _S670), _S663, _S669, _S666.value);
    float2  _S672 = make_float2 ((float)_S664.x, (float)_S664.y);
    float2  _S673 = (make_float2 (float(_S671), float(_S670)) + make_float2 (_S667.value, _S668.value)) / _S672 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S674 = _S673.y;
    float _S675 = (F32_sin((_S674)));
    float _S676 = _S673.x;
    float3  _S677 = make_float3 (- _S675 * (F32_cos((_S676))), _S675 * (F32_sin((_S676))), (F32_cos((_S674))));
    float _S678 = environmentPdf_0(_S677);
    float3  _S679 = ray_0->unit_direction;
    float3  _S680 = skyBSDF(ray_0->unit_direction, _S677, *surface_3, eta_3, is_inside_4, _S678, lobe_state_0);
    bool _S681 = !(_S678 > 0.0f);
    bool _S682;
    if(_S681)
    {
        _S682 = true;
    }
    else
    {
        _S682 = all_1(_S680 == make_float3 (0.0f));
    }
    if(_S682)
    {
        float3  _S683 = make_float3 (0.0f);
        return SkySample_x24init_0(_S677, _S683, _S683, _S668.state);
    }
    bool _S684 = (fcptWorldReadsPath());
    float3  seen_0;
    if(_S684)
    {
        float3  _S685 = skyColor_0(_S679, _S677, surface_3, eta_3, is_inside_4, _S678, lobe_state_0, context_2->depth + 1U);
        seen_0 = _S685;
    }
    else
    {
        seen_0 = _S680;
    }
    float3  _S686 = skyRadiance_0(ray_0->origin, surface_3, is_inside_4, _S677, context_2, _S668.state);
    return SkySample_x24init_0(_S677, _S686, seen_0 * _S686, _S668.state);
}

struct TreeSample
{
    float3  dir;
    float3  radiance;
    float density;
    uint random_state;
};

static __device__ float3  hairLight_0(FKSurface * surface_4, float3  in_dir_6, TreeSample * light_1, bool competing_0)
{
    SampleBSDF _S687 = (fcptConnectHair((surface_4->hair), ((&surface_4->material)->albedo), ((&surface_4->material)->specular_tint), (in_dir_6), (light_1->dir)));
    float3  _S688 = _S687.throughput * make_float3 (_S687.pdf);
    float _S689 = light_1->density;
    float _S690 = 1.0f + _S687.pdf * _S687.pdf / (light_1->density * light_1->density);
    bool _S691;
    if(competing_0)
    {
        _S691 = _S689 > 0.0f;
    }
    else
    {
        _S691 = false;
    }
    float _S692 = _slang_select(_S691, _S690,1.0f);
    return _S688 / make_float3 (_S692) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_7, float3  radiance_1, float density_0, uint random_state_9)
{
    TreeSample _S693;
    (&_S693)->dir = dir_7;
    (&_S693)->radiance = radiance_1;
    (&_S693)->density = density_0;
    (&_S693)->random_state = random_state_9;
    return _S693;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_12, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S694 = importance(first_1, p_12, normal_3);
    float _S695 = importance(second_1, p_12, normal_3);
    float2  _S696 = make_float2 (_S694, _S695);
    bool _S697 = _S694 == 0.0f;
    bool _S698;
    if(_S697)
    {
        _S698 = _S695 == 0.0f;
    }
    else
    {
        _S698 = false;
    }
    if(_S698)
    {
        return 2U;
    }
    float _S699 = _S694 + _S695;
    bool _S700 = _S695 > 0.0f;
    if(_S700)
    {
        _S698 = (*pick_0 * _S699) >= _S694;
    }
    else
    {
        _S698 = false;
    }
    uint _S701 = uint(_S698);
    float _S702 = (F32_min(((*pick_0 * _S699 - float(_S701) * _S694) / _slang_vector_get_element(_S696, _S701)), (0.99999994039535522f)));
    *pick_0 = _S702;
    float _S703 = *probability_3 * (_slang_vector_get_element(_S696, _S701) / _S699);
    *probability_3 = _S703;
    return _S701;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_13, float u1_0, float u2_0)
{
    float3  _S704 = center_1 - p_13;
    float _S705 = radius_1 * radius_1 / dot_0(_S704, _S704);
    float _S706 = u1_0 * _S705 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S705), (0.0f)))))));
    float _S707 = 2.0f * u1_0;
    bool _S708 = _S705 >= 1.0f;
    float _S709 = _slang_select(_S708, _S707,_S706);
    float _S710 = (F32_sqrt(((F32_max((_S709 * (2.0f - _S709)), (0.0f))))));
    float _S711 = 6.28318548202514648f * u2_0;
    float3  _S712 = make_float3 (_S710 * (F32_cos((_S711))), 1.0f - _S709, _S710 * (F32_sin((_S711))));
    float3  _S713 = ((((_S704)) * make_float3(rnorm3df(((_S704)).x, ((_S704)).y, ((_S704)).z))));
    float3  _S714 = tangentToWorld(_S712, _S713);
    return _S714;
}

__device__ float3  pointLightRadiance(float3  color_4, float intensity_0, float radius_2)
{
    return color_4 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S715 = center_2 - ray_1->origin;
    float _S716 = dot_0(_S715, ray_1->unit_direction);
    float _S717 = dot_0(_S715, _S715) - _S716 * _S716;
    float _S718 = radius_3 * radius_3;
    bool _S719 = _S717 > _S718;
    if(_S719)
    {
        return 4.294967296e+09f;
    }
    float _S720 = (F32_sqrt((_S718 - _S717)));
    float _S721 = _S716 - _S720;
    float _S722 = _S716 + _S720;
    bool _S723 = _S721 > 0.0000152587890625f;
    bool _S724;
    if(_S723)
    {
        _S724 = _S721 < max_len_0;
    }
    else
    {
        _S724 = false;
    }
    if(_S724)
    {
        return _S721;
    }
    bool _S725 = _S722 > 0.0000152587890625f;
    if(_S725)
    {
        _S724 = _S722 < max_len_0;
    }
    else
    {
        _S724 = false;
    }
    if(_S724)
    {
        return _S722;
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
        int i_11 = int(0);
        float sum_0 = 0.0f;
        for(;;)
        {
            if(i_11 < int(3))
            {
            }
            else
            {
                break;
            }
            float sum_1 = sum_0 + _slang_vector_get_element(left_1, i_11) * _slang_vector_get_element(right_1.rows[i_11], j_1);
            i_11 = i_11 + int(1);
            sum_0 = sum_1;
        }
        *_slang_vector_get_element_ptr(&result_6, j_1) = sum_0;
        j_1 = j_1 + int(1);
    }
    return result_6;
}

static __device__ __forceinline__ TreeSample sampleLightTree_0(float3  origin_4, float3  smooth_n_2, float3  geometry_n_1, float geometry_offset_1, bool sided_0, uint init_random_state_1, ShadowContext * context_3)
{
    Random _S726 = pcg(init_random_state_1);
    Random _S727 = pcg(_S726.state);
    Random _S728 = pcg(_S727.state);
    float3  _S729 = make_float3 (0.0f);
    TreeSample _S730 = TreeSample_x24init_0(_S729, _S729, 0.0f, _S728.state);
    TreeSample sample_0 = _S730;
    float3  _S731 = _slang_select(sided_0, _S729,smooth_n_2);
    float3  _S732 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S726.value;
    float probability_4 = 1.0f;
    uint n_8 = 0U;
    for(;;)
    {
        uint4  _S733 = (fcptLightNode((n_8)));
        if((_S733.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S734 = (fcptLightSecond((n_8)));
        uint _S735 = n_8 + 1U;
        LightNode _S736 = (fcptLightBounds((_S735)));
        LightNode _S737 = (fcptLightBounds((_S734)));
        uint _S738 = pickChild(_S736, _S737, origin_4, _S731, &pick_1, &probability_4);
        bool _S739 = _S738 > 1U;
        if(_S739)
        {
            return sample_0;
        }
        bool _S740 = _S738 == 1U;
        uint _S741 = _slang_select(_S740, _S734,_S735);
        n_8 = _S741;
    }
    bool _S742 = n_8 == 0U;
    bool _S743;
    if(_S742)
    {
        LightNode _S744 = (fcptLightBounds((0U)));
        float _S745 = importance(_S744, origin_4, _S731);
        _S743 = !(_S745 > 0.0f);
    }
    else
    {
        _S743 = false;
    }
    if(_S743)
    {
        return sample_0;
    }
    uint4  _S746 = (fcptLightNode((n_8)));
    FKHit _S747 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S748 = (_S746.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S748)
    {
        FKLight _S749 = (fcptLight((_S746.y)));
        if(sided_0)
        {
            float _S750 = sign_0(dot_0(geometry_n_1, _S749.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S750);
            float3  _S751 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S751;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S732;
            lift_n_0 = smooth_n_2;
        }
        bool _S752 = (_S749.variance) == 0.0f;
        if(_S752)
        {
            float3  _S753 = _S749.position - emitter_point_0;
            float3  _S754 = ((((_S753)) * make_float3(rnorm3df(((_S753)).x, ((_S753)).y, ((_S753)).z))));
            (&sample_0)->dir = _S754;
            float3  _S755 = _S749.color * make_float3 (_S749.intensity) / make_float3 (dot_0(_S753, _S753) * probability_4);
            (&sample_0)->radiance = _S755;
            shadow_1 = _S753;
        }
        else
        {
            float3  _S756 = sampleSphere(_S749.position, _S749.variance, emitter_point_0, _S727.value, _S728.value);
            (&sample_0)->dir = _S756;
            float _S757 = sphereDensity(_S749.position, _S749.variance, emitter_point_0);
            float _S758 = probability_4 * _S757;
            (&sample_0)->density = _S758;
            float3  _S759 = pointLightRadiance(_S749.color, _S749.intensity, _S749.variance);
            float3  _S760 = _S759 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S760;
            FKRay _S761 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S762 = raySphere_0(_S749.position, _S749.variance, &_S761, 4.294967296e+09f);
            float3  _S763 = (&sample_0)->dir * make_float3 (_S762);
            shadow_1 = _S763;
        }
        emitter_0 = _S747;
        emitter_point_0 = _S729;
    }
    else
    {
        uint _S764 = _S746.y;
        uint _S765 = (fcptTriangleOffset((_S764)));
        uint _S766 = _S765 + _S746.z;
        Matrix<float, 3, 3>  _S767 = (fcptWorldTriangle((_S764), (_S766)));
        float _S768 = (F32_sqrt((_S727.value)));
        float2  _S769 = make_float2 (_S768 * (1.0f - _S728.value), _S768 * _S728.value);
        float3  _S770 = mul_0(make_float3 (1.0f - _S768, _S769.x, _S769.y), _S767);
        if(sided_0)
        {
            float _S771 = sign_0(dot_0(geometry_n_1, _S770 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S771);
            float3  _S772 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S772;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S773 = !((dot_0(smooth_n_2, _S770 - origin_4)) > 0.0f);
            if(_S773)
            {
                return sample_0;
            }
            emitter_point_0 = _S732;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S769, _S764, _S766, 0U, 0.0f);
        float3  _S774 = _S770 - emitter_point_0;
        float3  _S775 = ((((_S774)) * make_float3(rnorm3df(((_S774)).x, ((_S774)).y, ((_S774)).z))));
        (&sample_0)->dir = _S775;
        float _S776 = solidAngle(probability_4, cross_0(_S767.rows[int(1)] - _S767.rows[int(0)], _S767.rows[int(2)] - _S767.rows[int(0)]), _S774);
        (&sample_0)->density = _S776;
        bool _S777 = (fcptShadowFirst());
        bool _S778 = !_S777;
        if(_S778)
        {
            FKSurface _S779 = (fcptLightSurfaceAt((emitter_1), (_S770), (_S728.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S770 - origin_4))));
            (&sample_0)->random_state = _S779.random_state;
            float3  _S780 = _slang_select(_S779.skip, _S729,_S779.material.emissive);
            float3  _S781 = _S780 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S781;
        }
        shadow_1 = _S774;
        emitter_0 = emitter_1;
        emitter_point_0 = _S770;
    }
    FKHit _S782 = emitter_0;
    float3  _S783 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S728.state, &_S782);
    bool _S784 = (fcptShadowFirst());
    if(_S784)
    {
        _S743 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S743 = false;
    }
    if(_S743)
    {
        _S743 = !all_1(_S783 == _S729);
    }
    else
    {
        _S743 = false;
    }
    if(_S743)
    {
        FKSurface _S785 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S728.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S785.random_state;
        float3  _S786 = _slang_select(_S785.skip, _S729,_S785.material.emissive);
        float3  _S787 = _S786 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S787;
    }
    float3  _S788 = (&sample_0)->radiance * _S783;
    bool _S789 = all_1(_S783 == _S729);
    float3  _S790 = _slang_select(_S789, _S729,_S788);
    (&sample_0)->radiance = _S790;
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
    float _S791 = 1.0f / (1.0f + b_3 / a_7 * (b_3 / a_7));
    bool _S792 = b_3 > 0.0f;
    float _S793 = _slang_select(_S792, _S791,1.0f);
    return _S793;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S794 = vertex_0->none;
    if(_S794)
    {
        return 1.0f;
    }
    uint _S795 = (fcptLightSlot((*hit_1)));
    float _S796 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S795, light_point_1);
    float _S797 = powerHeuristic(vertex_0->pdf, _S796);
    return _S797;
}

static __device__ float3  environment_0(float3  dir_8, uint depth_1, uint lobe_4)
{
    uint2  _S798 = (fcptEnvironmentMapSize());
    bool _S799 = (_S798.x) > 1U;
    bool _S800;
    if(_S799)
    {
        uint2  _S801 = (fcptEnvironmentMapSize());
        _S800 = (_S801.y) > 1U;
    }
    else
    {
        _S800 = false;
    }
    if(_S800)
    {
        float3  _S802 = (fcptEnvMapSample((dir_8), (depth_1), (lobe_4)));
        return _S802;
    }
    float3  _S803 = (fcptAmbient());
    return _S803;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S804 = (fcptEnvironmentCdfSize());
    bool _S805 = (_S804.x) > 1U;
    bool _S806;
    if(_S805)
    {
        uint2  _S807 = (fcptEnvironmentCdfSize());
        _S806 = (_S807.y) > 1U;
    }
    else
    {
        _S806 = false;
    }
    bool _S808 = !_S806;
    if(_S808)
    {
        return false;
    }
    uint2  _S809 = (fcptEnvironmentMapSize());
    bool _S810 = (_S809.x) > 1U;
    if(_S810)
    {
        uint2  _S811 = (fcptEnvironmentMapSize());
        _S806 = (_S811.y) > 1U;
    }
    else
    {
        _S806 = false;
    }
    return _S806;
}

static __device__ float escapeWeight_0(float pdf_4, float3  dir_9)
{
    bool _S812 = pdf_4 <= 0.0f;
    bool _S813;
    if(_S812)
    {
        _S813 = true;
    }
    else
    {
        bool _S814 = environmentMapped_0();
        _S813 = !_S814;
    }
    if(_S813)
    {
        return 1.0f;
    }
    float _S815 = environmentPdf_0(dir_9);
    return pdf_4 / (pdf_4 + _S815);
}

static __device__ void restir_duplicates_0(uint3  global_invocation_id_1, uint3  local_invocation_id_0, uint local_invocation_index_3)
{
    uint2  _S816 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S817 = make_int2 ((int)_S816.x, (int)_S816.y);
    uint _S818 = previousSeed_0(_S817);
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
            uint _S819 = previousSeed_0(_S817 + make_int2 (x_16, y_5));
            bool _S820 = _S819 == _S818;
            uint _S821 = _slang_select(_S820, 1U,0U);
            uint count_3 = count_2 + _S821;
            int x_17 = x_16 + int(1);
            x_16 = x_17;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S822 = float(count_2 - 1U) / 288.0f;
    bool _S823 = _S818 != 0U;
    float _S824 = _slang_select(_S823, _S822,0.0f);
    fcptStoreDuplication((_S817), (make_uint4 ((F32_asuint((_S824))), 0U, 0U, 0U)));
    return;
}

static __device__ float3  abs_0(float3  x_18)
{
    float3  result_7;
    int i_12 = int(0);
    for(;;)
    {
        if(i_12 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_7, i_12) = (F32_abs((_slang_vector_get_element(x_18, i_12))));
        i_12 = i_12 + int(1);
    }
    return result_7;
}

__device__ float resamplingTarget(float3  f_6)
{
    float _S825 = rgb_to_greyscale(abs_0(f_6));
    return _S825;
}

__device__ uint stream(uint seed_3, uint index_0)
{
    uint _S826 = hash(index_0);
    uint _S827 = hash(seed_3 ^ _S826);
    return _S827;
}

static __device__ float4  asfloat_0(uint4  x_19)
{
    float4  result_8;
    int i_13 = int(0);
    for(;;)
    {
        if(i_13 < int(4))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_8, i_13) = (U32_asfloat((_slang_vector_get_element(x_19, i_13))));
        i_13 = i_13 + int(1);
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
    float _S828 = resamplingTarget(weight_0);
    bool _S829 = _S828 > 0.0f;
    bool _S830;
    if(_S829)
    {
        _S830 = _S828 < 3.00000000549775576e+38f;
    }
    else
    {
        _S830 = false;
    }
    bool _S831 = !_S830;
    if(_S831)
    {
        return;
    }
    bool _S832 = sel_2->sums;
    if(_S832)
    {
        float3  _S833 = sel_2->color + weight_0;
        sel_2->color = _S833;
        return;
    }
    float _S834 = sel_2->w_sum + _S828;
    sel_2->w_sum = _S834;
    float3  _S835 = sel_2->color + weight_0;
    sel_2->color = _S835;
    Random _S836 = pcg(sel_2->random_state);
    sel_2->random_state = _S836.state;
    bool _S837 = (_S836.value * sel_2->w_sum) <= _S828;
    if(_S837)
    {
        sel_2->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_3;
    float3  _S838 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S838;
    float _S839 = r_3.jac * shifted_0.jac;
    (&candidate_1)->jac = _S839;
    offer(sel_3, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S840 = resamplingTarget((&r_4)->f);
    float _S841 = sel_4.w_sum / _S840;
    bool _S842 = _S840 > 0.0f;
    float _S843 = _slang_select(_S842, _S841,0.0f);
    (&r_4)->w = _S843;
    (&r_4)->c = c_1;
    return r_4;
}

static __device__ uint2  asuint_0(float2  x_20)
{
    uint2  result_9;
    int i_14 = int(0);
    for(;;)
    {
        if(i_14 < int(2))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_9, i_14) = (F32_asuint((_slang_vector_get_element(x_20, i_14))));
        i_14 = i_14 + int(1);
    }
    return result_9;
}

static __device__ void restir_spatial_0(uint3  global_invocation_id_2)
{
    uint2  _S844 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S845 = make_int2 ((int)_S844.x, (int)_S844.y);
    float3  _S846 = make_float3 (0.0f);
    FKHit _S847 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S848 = Domain_x24init_0(_S846, _S846, &_S847, 0.0f, 0.0f);
    Domain dom_4 = _S848;
    bool _S849 = (fcptCurrentDomain((_S845), (&dom_4)));
    bool _S850 = !_S849;
    if(_S850)
    {
        Reservoir _S851 = (Reservoir{});
        fcptStoreReservoirPrevious((_S845), (_S851), ((&dom_4)->hit));
        return;
    }
    Reservoir _S852 = (fcptLoadReservoirTemporal((_S845)));
    uint t_13 = 0U;
    float count_4 = 0.0f;
    float c_sum_1 = _S852.c;
    for(;;)
    {
        uint _S853 = (fcptRestirNeighbours());
        if(t_13 < _S853)
        {
        }
        else
        {
            break;
        }
        int2  _S854 = partner_0(_S845, t_13);
        Domain neighbor_0 = _S848;
        bool _S855 = (fcptCurrentDomain((_S854), (&neighbor_0)));
        if(_S855)
        {
            float count_5 = count_4 + 1.0f;
            uint4  _S856 = (fcptReservoirTemporal((_S854), (0U)));
            float c_sum_2 = c_sum_1 + (U32_asfloat((_S856.w)));
            count_4 = count_5;
            c_sum_1 = c_sum_2;
        }
        uint t_14 = t_13 + 1U;
        t_13 = t_14;
    }
    float _S857 = _S852.c / (F32_max((count_4), (1.0f)));
    float _S858 = resamplingTarget(_S852.f);
    bool _S859 = count_4 == 0.0f;
    float _S860 = _slang_select(_S859, 1.0f,0.0f);
    Selection _S861 = (Selection{});
    Selection sel_5 = _S861;
    uint _S862 = (fcptFrame());
    uint _S863 = hash(_S862);
    uint _S864 = global_invocation_id_2.x;
    uint2  _S865 = (fcptRenderSize());
    uint _S866 = stream(_S863, _S864 + _S865.x * global_invocation_id_2.y);
    uint _S867 = stream(_S866, 195U);
    (&sel_5)->random_state = _S867;
    t_13 = 0U;
    float canonical_mis_0 = _S860;
    for(;;)
    {
        uint _S868 = (fcptRestirNeighbours());
        if(t_13 < _S868)
        {
        }
        else
        {
            break;
        }
        int2  _S869 = partner_0(_S845, t_13);
        Domain neighbor_dom_0 = _S848;
        bool _S870 = (fcptCurrentDomain((_S869), (&neighbor_dom_0)));
        if(_S870)
        {
            Reservoir _S871 = (fcptLoadReservoirTemporal((_S869)));
            uint4  _S872 = (fcptShiftData((_S869), (t_13)));
            float4  _S873 = asfloat_0(_S872);
            uint4  _S874 = (fcptShiftData((_S845), (t_13)));
            float4  _S875 = asfloat_0(_S874);
            float _S876 = pairShare(_S871.c, _S857, c_sum_1);
            bool _S877 = _S858 > 0.0f;
            float canonical_mis_1;
            if(_S877)
            {
                float _S878 = resamplingTarget(float3 {_S875.x, _S875.y, _S875.z});
                float _S879 = canonicalWeight(_S876, _S857, _S858, _S871.c, _S878);
                float canonical_mis_2 = canonical_mis_0 + _S879;
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float3  _S880 = float3 {_S873.x, _S873.y, _S873.z};
            Shift _S881 = Shift_x24init_0(_S880, _S873.w);
            float _S882 = resamplingTarget(_S871.f);
            float _S883 = resamplingTarget(_S880);
            float _S884 = neighborWeight(_S876, _S871.c, _S882, _S857, _S883);
            offerShifted(&sel_5, _S871, _S881, _S884);
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_15 = t_13 + 1U;
        t_13 = t_15;
    }
    offerShifted(&sel_5, _S852, Shift_x24init_0(_S852.f, 1.0f), canonical_mis_0);
    Reservoir _S885 = finalize(sel_5, c_sum_1);
    fcptStoreReservoirPrevious((_S845), (_S885), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S845), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S845), (make_float4 ((&sel_5)->color.x, (&sel_5)->color.y, (&sel_5)->color.z, 0.0f)));
    return;
}

static __device__ uint3  asuint_1(float3  x_21)
{
    uint3  result_10;
    int i_15 = int(0);
    for(;;)
    {
        if(i_15 < int(3))
        {
        }
        else
        {
            break;
        }
        *_slang_vector_get_element_ptr(&result_10, i_15) = (F32_asuint((_slang_vector_get_element(x_21, i_15))));
        i_15 = i_15 + int(1);
    }
    return result_10;
}

static __device__ void restir_shift_0(uint3  workgroup_id_1, uint local_invocation_index_4)
{
    uint _S886 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S887 = _S886 != 4294967295U;
    if(_S887)
    {
        uint2  _S888 = make_uint2 (_S886, _S886 >> 14U) & make_uint2 (16383U);
        int2  _S889 = make_int2 ((int)_S888.x, (int)_S888.y);
        ShiftJob _S890 = (ShiftJob{});
        ShiftJob shift_job_0 = _S890;
        Shift _S891 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S892 = _S886 >> 28U;
        bool _S893 = spatialJob_0(_S889, _S892, &shift_job_0, true);
        Shift shifted_1;
        if(_S893)
        {
            Domain _S894 = (&shift_job_0)->dom;
            Reservoir _S895 = (&shift_job_0)->r;
            Shift _S896 = passShift_0(&_S894, &_S895);
            shifted_1 = _S896;
        }
        else
        {
            shifted_1 = _S891;
        }
        fcptStoreShiftData((_S889), (_S892), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S897 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S898 = make_int2 ((int)_S897.x, (int)_S897.y);
    FixedArray<uint, 3>  _S899;
    spatialBins_0(_S898, &_S899);
    FixedArray<uint, 3>  _S900 = _S899;
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
        bool _S901 = (_S900[t_16]) == 40U;
        if(_S901)
        {
            fcptStoreShiftData((_S898), (t_16), (make_uint4 (0U)));
        }
        uint t_17 = t_16 + 1U;
        t_16 = t_17;
    }
    FixedArray<uint, 3>  _S902 = _S900;
    queueShifts_0(_S898, &_S902, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S903 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S904 = make_int2 ((int)_S903.x, (int)_S903.y);
    FixedArray<uint, 3>  _S905;
    spatialBins_0(_S904, &_S905);
    FixedArray<uint, 3>  _S906 = _S905;
    countShifts_0(&_S906, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S907 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S908 = _S907 != 4294967295U;
    if(_S908)
    {
        uint2  _S909 = make_uint2 (_S907, _S907 >> 14U) & make_uint2 (16383U);
        int2  _S910 = make_int2 ((int)_S909.x, (int)_S909.y);
        int2  _S911 = (fcptLoadTemporalNeighbor((_S910)));
        uint _S912 = _S907 >> 28U;
        Shift _S913 = temporalShiftAt_0(_S910, _S911, _S912);
        fcptStoreTemporalShift((_S910), (_S912), (make_uint4 (asuint_1(_S913.f).x, asuint_1(_S913.f).y, asuint_1(_S913.f).z, (F32_asuint((_S913.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S914 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S915 = make_int2 ((int)_S914.x, (int)_S914.y);
    FixedArray<uint, 3>  _S916;
    temporalBins_0(_S915, &_S916);
    FixedArray<uint, 3>  _S917 = _S916;
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
        bool _S918 = (_S917[t_18]) == 40U;
        if(_S918)
        {
            fcptStoreTemporalShift((_S915), (t_18), (make_uint4 (0U)));
        }
        uint t_19 = t_18 + 1U;
        t_18 = t_19;
    }
    FixedArray<uint, 3>  _S919 = _S917;
    queueShifts_0(_S915, &_S919, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S920 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S921 = make_int2 ((int)_S920.x, (int)_S920.y);
    bool _S922 = (fcptSceneUnchanged());
    bool _S923 = !_S922;
    bool _S924;
    if(_S923)
    {
        uint2  _S925 = (fcptRenderSize());
        int2  _S926 = make_int2 ((int)_S925.x, (int)_S925.y);
        _S924 = all_0(_S921 < _S926);
    }
    else
    {
        _S924 = false;
    }
    if(_S924)
    {
        Reservoir _S927 = (fcptLoadReservoirInitial((_S921)));
        int2  _S928 = sampleNeighbor_0(_S921, _S927.seed);
        fcptStoreTemporalNeighbor((_S921), (_S928));
    }
    FixedArray<uint, 3>  _S929;
    temporalBins_0(_S921, &_S929);
    FixedArray<uint, 3>  _S930 = _S929;
    countShifts_0(&_S930, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_8, float b_4, float t_20)
{
    return a_8 + (b_4 - a_8) * t_20;
}

__device__ float confidenceCap(float duplicated_0)
{
    float _S931 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S931;
}

__device__ float2  temporalWeights(float c_2, float p_c_1, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S932 = c_2 * p_c_1;
    float _S933 = c_t_0 * p_t_0;
    return make_float2 (_S932 / (_S932 + c_t_0 * g_previous_0), _S933 / (_S933 + c_2 * g_current_0));
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S934 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S935 = make_int2 ((int)_S934.x, (int)_S934.y);
    float3  _S936 = make_float3 (0.0f);
    FKHit _S937 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S938 = Domain_x24init_0(_S936, _S936, &_S937, 0.0f, 0.0f);
    Domain dom_5 = _S938;
    bool _S939 = (fcptCurrentDomain((_S935), (&dom_5)));
    bool _S940 = !_S939;
    if(_S940)
    {
        Reservoir _S941 = (Reservoir{});
        fcptStoreReservoirTemporal((_S935), (_S941), ((&dom_5)->hit));
        return;
    }
    Reservoir _S942 = (fcptLoadReservoirInitial((_S935)));
    bool _S943 = (fcptTemporalQueued());
    bool _S944 = (fcptSceneUnchanged());
    bool _S945;
    if(_S944)
    {
        _S945 = true;
    }
    else
    {
        _S945 = !_S943;
    }
    int2  _S946;
    if(_S945)
    {
        int2  _S947 = sampleNeighbor_0(_S935, _S942.seed);
        _S946 = _S947;
    }
    else
    {
        int2  _S948 = (fcptLoadTemporalNeighbor((_S935)));
        _S946 = _S948;
    }
    bool _S949 = (_S946.x) >= int(0);
    Reservoir r_5;
    if(_S949)
    {
        Reservoir _S950 = (fcptLoadReservoirPrevious((_S946)));
        uint4  _S951 = (fcptDuplication((_S946)));
        float _S952 = (U32_asfloat((_S951.x)));
        uint _S953 = (fcptRestirDecorrelation());
        bool _S954 = _S953 == 1U;
        float _S955 = _slang_select(_S954, _S952,0.0f);
        float _S956 = confidenceCap(_S955);
        float _S957 = (F32_min((_S950.c), (_S956)));
        bool _S958 = (fcptSceneUnchanged());
        float4  _S959 = make_float4 (_S950.f.x, _S950.f.y, _S950.f.z, 1.0f);
        bool _S960 = !_S958;
        if(_S960)
        {
            _S945 = _S943;
        }
        else
        {
            _S945 = false;
        }
        float4  to_current_0;
        if(_S945)
        {
            uint4  _S961 = (fcptTemporalShift((_S935), (0U)));
            float4  _S962 = asfloat_0(_S961);
            to_current_0 = _S962;
        }
        else
        {
            if(_S960)
            {
                Shift _S963 = temporalShiftAt_0(_S935, _S946, 0U);
                float4  _S964 = make_float4 (_S963.f.x, _S963.f.y, _S963.f.z, _S963.jac);
                to_current_0 = _S964;
            }
            else
            {
                to_current_0 = _S959;
            }
        }
        Domain own_1 = _S938;
        if(_S958)
        {
            _S945 = true;
        }
        else
        {
            bool _S965 = (fcptPreviousScenes());
            bool _S966 = !_S965;
            if(_S966)
            {
                _S945 = (_S942.w) > 0.0f;
            }
            else
            {
                _S945 = false;
            }
            if(_S945)
            {
                bool _S967 = (fcptStoredDomainInitial((_S935), (_S942.seed), (&own_1)));
                _S945 = _S967;
            }
            else
            {
                _S945 = false;
            }
            if(_S945)
            {
                Domain _S968 = (fcptPreviousDomain((_S946), (_S942.seed)));
                Domain _S969 = _S968;
                Domain _S970 = own_1;
                bool _S971 = sameDomain_0(&_S969, &_S970);
                _S945 = _S971;
            }
            else
            {
                _S945 = false;
            }
        }
        float4  _S972 = make_float4 (_S942.f.x, _S942.f.y, _S942.f.z, 1.0f);
        bool _S973 = !_S945;
        if(_S973)
        {
            _S945 = _S943;
        }
        else
        {
            _S945 = false;
        }
        float4  to_previous_0;
        if(_S945)
        {
            uint4  _S974 = (fcptTemporalShift((_S935), (1U)));
            float4  _S975 = asfloat_0(_S974);
            to_previous_0 = _S975;
        }
        else
        {
            if(_S973)
            {
                Shift _S976 = temporalShiftAt_0(_S935, _S946, 1U);
                float4  _S977 = make_float4 (_S976.f.x, _S976.f.y, _S976.f.z, _S976.jac);
                to_previous_0 = _S977;
            }
            else
            {
                to_previous_0 = _S972;
            }
        }
        float _S978 = resamplingTarget(_S942.f);
        float _S979 = resamplingTarget(_S950.f);
        Selection _S980 = (Selection{});
        Selection sel_6 = _S980;
        uint _S981 = (fcptFrame());
        uint _S982 = hash(_S981);
        uint _S983 = global_invocation_id_7.x;
        uint2  _S984 = (fcptRenderSize());
        uint _S985 = stream(_S982, _S983 + _S984.x * global_invocation_id_7.y);
        uint _S986 = stream(_S985, 194U);
        (&sel_6)->random_state = _S986;
        float4  _S987 = to_previous_0;
        float _S988 = resamplingTarget(float3 {_S987.x, _S987.y, _S987.z});
        float4  _S989 = to_current_0;
        float3  _S990 = float3 {_S989.x, _S989.y, _S989.z};
        float _S991 = resamplingTarget(_S990);
        float2  _S992 = temporalWeights(_S942.c, _S978, _S957, _S979, _S988, _S991);
        offerShifted(&sel_6, _S942, Shift_x24init_0(_S942.f, 1.0f), _S992.x);
        offerShifted(&sel_6, _S950, Shift_x24init_0(_S990, to_current_0.w), _S992.y);
        Reservoir _S993 = finalize(sel_6, _S942.c + _S957);
        r_5 = _S993;
    }
    else
    {
        r_5 = _S942;
    }
    fcptStoreReservoirTemporal((_S935), (r_5), ((&dom_5)->hit));
    return;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_6)
{
    uint _S994 = (1U << count_6) - 1U;
    return (e_2 & (~(_S994 << offset_1))) | ((newbits_0 & _S994) << offset_1);
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S995 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S996 = make_int2 ((int)_S995.x, (int)_S995.y);
    float3  _S997 = make_float3 (0.0f);
    float2  _S998 = make_float2 (0.0f);
    FKHit _S999 = Hit_x24init_0(_S998, 0U, 0U, 0U, 0.0f);
    Domain _S1000 = Domain_x24init_0(_S997, _S997, &_S999, 0.0f, 0.0f);
    Domain dom_6 = _S1000;
    bool _S1001 = (fcptCurrentDomain((_S996), (&dom_6)));
    bool _S1002 = !_S1001;
    if(_S1002)
    {
        Reservoir _S1003 = (Reservoir{});
        fcptStoreReservoirInitial((_S996), (_S1003), ((&dom_6)->hit));
        return;
    }
    uint _S1004 = (fcptFrame());
    uint _S1005 = hash(_S1004);
    uint _S1006 = global_invocation_id_8.x;
    uint2  _S1007 = (fcptRenderSize());
    uint _S1008 = global_invocation_id_8.y;
    uint _S1009 = stream(_S1005, _S1006 + _S1007.x * _S1008);
    uint2  _S1010 = (fcptRenderSize());
    uint _S1011 = stream(_S1006 + _S1010.x * _S1008, 512U);
    Selection _S1012 = (Selection{});
    Selection initial_0 = _S1012;
    uint _S1013 = stream(_S1009, 193U);
    (&initial_0)->random_state = _S1013;
    bool _S1014 = (fcptRestirUsed());
    bool _S1015 = !_S1014;
    (&initial_0)->sums = _S1015;
    uint _S1016 = stream(_S1009, 0U);
    (&(&initial_0)->r)->seed = _S1016;
    FKHit _S1017 = Hit_x24init_0(_S998, 4294967295U, 0U, 0U, 0.0f);
    uint _S1018 = (fcptSamples());
    float _S1019 = 1.0f / float(_S1018);
    FKHit hit_2 = _S1017;
    uint i_16 = 0U;
    float3  seen_1 = _S997;
    for(;;)
    {
        uint _S1020 = (fcptSamples());
        if(i_16 < _S1020)
        {
        }
        else
        {
            break;
        }
        Reservoir _S1021 = (Reservoir{});
        Reservoir r_6 = _S1021;
        uint _S1022 = stream(_S1009, i_16);
        (&r_6)->seed = _S1022;
        uint _S1023 = (fcptFrame());
        uint _S1024 = (fcptSamples());
        uint _S1025 = _S1023 * _S1024 + i_16;
        uint _S1026 = insertBits_0(0U, 1U, 24U, 1U);
        uint _S1027 = insertBits_0(_S1026, (_S1011 + _S1025 * 2654435769U) >> 25U, 25U, 7U);
        (&r_6)->path = _S1027;
        Domain path_0 = _S1000;
        bool _S1028 = (fcptStoredDomainInitial((_S996), ((&r_6)->seed), (&path_0)));
        bool _S1029 = !_S1028;
        if(_S1029)
        {
            float3  _S1030 = (fcptMissed((_S996), (path_0), (_S1019)));
            float3  seen_2 = seen_1 + _S1030;
            seen_1 = seen_2;
            uint i_17 = i_16 + 1U;
            i_16 = i_17;
            continue;
        }
        Domain _S1031 = path_0;
        Reservoir _S1032 = r_6;
        Shift _S1033 = passWalk_0(&_S1031, &_S1032, false, _S1019, &initial_0);
        bool _S1034 = ((&(&initial_0)->r)->seed) == ((&r_6)->seed);
        FKHit hit_3;
        if(_S1034)
        {
            FKHit _S1035 = (&path_0)->hit;
            hit_3 = _S1035;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_17 = i_16 + 1U;
        i_16 = i_17;
    }
    uint _S1036 = (fcptSamples());
    float3  seen_3 = seen_1 + (&initial_0)->glow / make_float3 (float(_S1036));
    if((&initial_0)->sums)
    {
        seen_1 = seen_3 + (&initial_0)->color;
    }
    else
    {
        seen_1 = seen_3;
    }
    fcptAddColor((_S996), (make_float4 (seen_1.x, seen_1.y, seen_1.z, 1.0f)));
    Reservoir _S1037 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S996), (_S1037), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_5, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S1038;
    (&_S1038)->none = none_0;
    (&_S1038)->pdf = pdf_5;
    (&_S1038)->origin = origin_5;
    (&_S1038)->smooth_n = smooth_n_3;
    (&_S1038)->start = start_6;
    return _S1038;
}

struct Vertex
{
    bool rough;
    uint lobe;
    float pdf;
    float cos;
    bool inside;
};

static __device__ Vertex Vertex_x24init_0(bool rough_0, uint lobe_5, float pdf_6, float cos_0, bool inside_0)
{
    Vertex _S1039;
    (&_S1039)->rough = rough_0;
    (&_S1039)->lobe = lobe_5;
    (&_S1039)->pdf = pdf_6;
    (&_S1039)->cos = cos_0;
    (&_S1039)->inside = inside_0;
    return _S1039;
}

static __device__ float freeFlight_0(float u_1, float sigma_0)
{
    return - (F32_log((1.0f - u_1))) / sigma_0;
}

__device__ float upsample(float3  rgb_1, float wavelength_0)
{
    float _S1040 = dot_0(make_float3 (-0.08011700212955475f, 1.08901798725128174f, -0.00889899954199791f), rgb_1);
    float _S1041 = dot_0(make_float3 (0.12177000194787979f, -1.22903203964233398f, 1.10724997520446777f), rgb_1);
    float _S1042 = dot_0(make_float3 (1.17252397537231445f, -1.21603405475616455f, 0.04350199922919273f), rgb_1);
    float3  _S1043 = make_float3 (_S1040, _S1041, _S1042);
    float _S1044 = (wavelength_0 - 0.44999998807907104f) / 0.02999999932944775f;
    float _S1045 = (wavelength_0 - 0.63999998569488525f) / 0.03999999910593033f;
    return _S1040 + _S1041 * (F32_exp((-0.5f * _S1044 * _S1044))) + _S1042 * (F32_exp((-0.5f * _S1045 * _S1045)));
}

__device__ float3  pathColor(float3  f_7, float3  weight_1, float wavelength_1)
{
    float3  _S1046;
    if(wavelength_1 > 0.0f)
    {
        float _S1047 = upsample(f_7, wavelength_1);
        _S1046 = weight_1 * make_float3 (_S1047);
    }
    else
    {
        _S1046 = f_7;
    }
    return _S1046;
}

static __device__ float3  exp_0(float3  x_22)
{
    float3  result_11;
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
        *_slang_vector_get_element_ptr(&result_11, i_18) = (F32_exp((_slang_vector_get_element(x_22, i_18))));
        i_18 = i_18 + int(1);
    }
    return result_11;
}

static __device__ float3  flightWeight_0(float3  scatter_0, float3  extinction_0, float sigma_1, float distance_2, bool scatters_0)
{
    float3  _S1048 = exp_0((make_float3 (sigma_1) - extinction_0) * make_float3 (distance_2));
    float3  _S1049 = scatter_0 * _S1048 / make_float3 (sigma_1);
    float3  _S1050 = _slang_select(scatters_0, _S1049,_S1048);
    return _S1050;
}

static __device__ bool scatterSampled_0(bool replay_1, uint b_5, uint stop_0, bool varying_0)
{
    bool _S1051 = !replay_1;
    bool _S1052;
    if(_S1051)
    {
        _S1052 = true;
    }
    else
    {
        bool _S1053 = b_5 == stop_0;
        if(_S1053)
        {
            _S1052 = !varying_0;
        }
        else
        {
            _S1052 = false;
        }
    }
    return _S1052;
}

static __device__ uint arrivalLobe_0(uint b_6, uint prev_lobe_0)
{
    bool _S1054 = b_6 > 0U;
    uint _S1055 = _slang_select(_S1054, prev_lobe_0,3U);
    return _S1055;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_2, uint lobe_6, bool surface_5, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S1056;
    (&_S1056)->extinction_behind = extinction_behind_0;
    (&_S1056)->extinction_front = extinction_front_0;
    (&_S1056)->fillings = fillings_0;
    (&_S1056)->side = side_0;
    (&_S1056)->depth = depth_2;
    (&_S1056)->lobe = lobe_6;
    (&_S1056)->surface = surface_5;
    (&_S1056)->length = length_2;
    (&_S1056)->width = width_1;
    (&_S1056)->own = *own_2;
    (&_S1056)->fiber = fiber_0;
    return _S1056;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S1057 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S1057)
    {
        return 0.07957746833562851f;
    }
    float _S1058 = g_0 * g_0;
    return (1.0f - _S1058) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S1058 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_9, float3  b_7)
{
    float3  _S1059 = a_9 / b_7;
    float3  _S1060 = make_float3 (0.0f);
    bool3  _S1061 = b_7 == _S1060;
    float3  _S1062 = _slang_select(_S1061, _S1060,_S1059);
    return _S1062;
}

__device__ Reservoir withEnd(Reservoir r_7, uint end_type_0, uint end_0, float3  f_8)
{
    Reservoir candidate_2 = r_7;
    uint _S1063 = insertBits_0(r_7.path, end_0, 0U, 5U);
    uint _S1064 = insertBits_0(_S1063, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S1064;
    (&candidate_2)->f = f_8;
    return candidate_2;
}

__device__ float survivalProbability(float3  throughput_1, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_1.x), ((F32_max((throughput_1.y), (throughput_1.z)))))) / density_1), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_10)
{
    Random _S1065 = pcg(random_state_10);
    Random _S1066 = pcg(_S1065.state);
    float _S1067 = 1.0f - 2.0f * _S1065.value;
    float _S1068 = (F32_sqrt(((F32_max((1.0f - _S1067 * _S1067), (0.0f))))));
    float _S1069 = 6.28318548202514648f * _S1066.value;
    return make_float3 (_S1068 * (F32_cos((_S1069))), _S1068 * (F32_sin((_S1069))), _S1067);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_10, uint random_state_11, float * pdf_7)
{
    bool _S1070 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1070)
    {
        *pdf_7 = 0.07957746833562851f;
        float3  _S1071 = isotropic_0(random_state_11);
        return _S1071;
    }
    Random _S1072 = pcg(random_state_11);
    Random _S1073 = pcg(_S1072.state);
    float _S1074 = g_1 * g_1;
    float _S1075 = 2.0f * g_1;
    float _S1076 = (1.0f - _S1074) / (1.0f - g_1 + _S1075 * _S1072.value);
    float _S1077 = clamp_1((1.0f + _S1074 - _S1076 * _S1076) / _S1075, -1.0f, 1.0f);
    float _S1078 = (F32_sqrt(((F32_max((1.0f - _S1077 * _S1077), (0.0f))))));
    float _S1079 = 6.28318548202514648f * _S1073.value;
    float _S1080 = phaseHG_0(g_1, _S1077);
    *pdf_7 = _S1080;
    float3  _S1081 = tangentToWorld(make_float3 (_S1078 * (F32_cos((_S1079))), _S1077, _S1078 * (F32_sin((_S1079)))), dir_10);
    float3  _S1082 = ((((_S1081)) * make_float3(rnorm3df(((_S1081)).x, ((_S1081)).y, ((_S1081)).z))));
    return _S1082;
}

static __device__ Vertex scatteredVertex_0(bool is_inside_5)
{
    return Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_5);
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_0, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_3, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2, float velvet_0, float3  toon_3, float dispersion_0)
{
    BSDFMaterial _S1083;
    (&_S1083)->albedo = albedo_0;
    (&_S1083)->emissive = emissive_0;
    (&_S1083)->roughness = roughness_0;
    (&_S1083)->metallic = metallic_0;
    (&_S1083)->transmission = transmission_0;
    (&_S1083)->ior = ior_0;
    (&_S1083)->absorption = absorption_0;
    (&_S1083)->specular_tint = specular_tint_0;
    (&_S1083)->specular_level = specular_level_0;
    (&_S1083)->translucent = translucent_0;
    (&_S1083)->sheen = sheen_3;
    (&_S1083)->sheen_roughness = sheen_roughness_0;
    (&_S1083)->anisotropy = anisotropy_0;
    (&_S1083)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1083)->tangent = tangent_2;
    (&_S1083)->velvet = velvet_0;
    (&_S1083)->toon = toon_3;
    (&_S1083)->dispersion = dispersion_0;
    return _S1083;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1084;
    (&_S1084)->scatter = scatter_1;
    (&_S1084)->extinction = extinction_1;
    (&_S1084)->g = g_2;
    return _S1084;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_8, bool skip_0, uint random_state_12, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1085;
    (&_S1085)->smooth_n = smooth_n_4;
    (&_S1085)->geometry_n = geometry_n_2;
    (&_S1085)->geometry_offset = geometry_offset_2;
    (&_S1085)->material = *material_8;
    (&_S1085)->skip = skip_0;
    (&_S1085)->random_state = random_state_12;
    (&_S1085)->coverage = coverage_0;
    (&_S1085)->encloses = encloses_0;
    (&_S1085)->volume = *volume_0;
    (&_S1085)->fills = fills_0;
    (&_S1085)->hair = hair_0;
    return _S1085;
}

static __device__ FKSurface emitting_0(FKSurface * surface_6, bool top_0)
{
    FKSurface lower_0 = *surface_6;
    float3  _S1086 = (&surface_6->material)->emissive;
    float3  _S1087 = make_float3 (0.0f);
    bool _S1088 = !top_0;
    float3  _S1089 = _slang_select(_S1088, _S1087,_S1086);
    (&(&lower_0)->material)->emissive = _S1089;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_7, float u_2)
{
    float _S1090 = surface_7->coverage;
    bool _S1091 = u_2 < _S1090;
    if(_S1091)
    {
        return *surface_7;
    }
    float3  _S1092 = make_float3 (0.0f);
    float3  _S1093 = make_float3 (1.0f);
    BSDFMaterial _S1094 = Material_x24init_0(_S1092, _S1092, 0.0f, 0.0f, 0.0f, 0.0f, _S1092, _S1093, 1.0f, _S1092, _S1092, 0.5f, 0.0f, 0.0f, _S1092, 0.0f, _S1092, 0.0f);
    BSDFMaterial material_9 = _S1094;
    (&material_9)->albedo = _S1093;
    (&material_9)->emissive = (&surface_7->material)->emissive;
    (&material_9)->transmission = 1.0f;
    (&material_9)->ior = 1.0f;
    (&material_9)->absorption = (&surface_7->material)->absorption;
    FKSurface through_0 = *surface_7;
    (&through_0)->material = material_9;
    return through_0;
}

__device__ float facingSign(float transmission_1, float3  face_0, float3  direction_0)
{
    bool _S1095 = transmission_1 > 0.0f;
    bool _S1096;
    if(_S1095)
    {
        _S1096 = true;
    }
    else
    {
        _S1096 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1097;
    if(_S1096)
    {
        _S1097 = 1.0f;
    }
    else
    {
        _S1097 = -1.0f;
    }
    return _S1097;
}

static __device__ bool arrivesBehind_0(float3  dir_11, float3  n_9)
{
    return (dot_0(dir_11, n_9)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_8, float3  dir_12)
{
    float3  _S1098 = surface_8->geometry_n;
    float _S1099 = facingSign((&surface_8->material)->transmission, surface_8->geometry_n, dir_12);
    FKSurface faced_0 = *surface_8;
    float3  _S1100 = surface_8->smooth_n * make_float3 (_S1099);
    (&faced_0)->smooth_n = _S1100;
    float3  _S1101 = _S1098 * make_float3 (_S1099);
    (&faced_0)->geometry_n = _S1101;
    return faced_0;
}

static __device__ float3  max_0(float3  x_23, float3  y_7)
{
    float3  result_12;
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
        *_slang_vector_get_element_ptr(&result_12, i_19) = (F32_max((_slang_vector_get_element(x_23, i_19)), (_slang_vector_get_element(y_7, i_19))));
        i_19 = i_19 + int(1);
    }
    return result_12;
}

static __device__ float3  log_0(float3  x_24)
{
    float3  result_13;
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
        *_slang_vector_get_element_ptr(&result_13, i_20) = (F32_log((_slang_vector_get_element(x_24, i_20))));
        i_20 = i_20 + int(1);
    }
    return result_13;
}

__device__ float3  beerLambert(float distance_3, float3  absorption_1)
{
    float3  _S1102 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1102));
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
    bool _S1103;
    if(open_0)
    {
        _S1103 = prev_rough_0;
    }
    else
    {
        _S1103 = false;
    }
    if(_S1103)
    {
        _S1103 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S1103 = false;
    }
    return _S1103;
}

__device__ bool dispersive(BSDFMaterial material_10)
{
    bool _S1104 = (material_10.dispersion) > 0.0f;
    bool _S1105;
    if(_S1104)
    {
        _S1105 = (material_10.ior) != 1.0f;
    }
    else
    {
        _S1105 = false;
    }
    return _S1105;
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
        uint _S1106 = (low_1 + high_1 + 1U) / 2U;
        bool _S1107 = (WAVELENGTH_CDF_0[_S1106]) <= u_3;
        if(_S1107)
        {
            low_1 = _S1106;
        }
        else
        {
            uint _S1108 = _S1106 - 1U;
            high_1 = _S1108;
        }
    }
    uint _S1109 = low_1;
    float _S1110 = WAVELENGTH_CDF_0[low_1 + 1U] - WAVELENGTH_CDF_0[low_1];
    return make_float2 (0.37999999523162842f + 0.00499999988824129f * (float(low_1) + (u_3 - WAVELENGTH_CDF_0[_S1109]) / _S1110), _S1110 / 0.00499999988824129f);
}

__device__ static const FixedArray<float, 243>  WAVELENGTH_WEIGHTS_0 = { {
    0.00547470012679696f, -0.00465690018609166f, 0.03257500007748604f, 0.00934640038758516f, -0.00796370021998882f, 0.05577300116419792f, 0.01846100017428398f, -0.01579399965703487f, 0.11072999984025955f, 0.0416410006582737f, -0.03577499836683273f, 0.2513900101184845f, 0.09349299967288971f, -0.08071800321340561f, 0.56742000579833984f, 0.1585099995136261f, -0.13764999806880951f, 0.97018998861312866f, 0.30943000316619873f, -0.27083000540733337f, 1.91740000247955322f, 0.55217999219894409f, -0.48754000663757324f, 3.46889996528625488f, 0.95016998052597046f, -0.84802001714706421f, 6.09439992904663086f, 1.42110002040863037f, -1.28929996490478516f, 9.45199966430664062f, 1.73409998416900635f, -1.6062999963760376f, 12.12800025939941406f, 2.08030009269714355f, -1.98810005187988281f, 15.68700027465820312f, 2.20600008964538574f, -2.20120000839233398f, 18.47699928283691406f, 2.03040003776550293f, -2.17700004577636719f, 19.92700004577636719f, 1.63429999351501465f, -2.00340008735656738f, 20.86899948120117188f, 0.99410998821258545f, -1.62629997730255127f, 20.57799911499023438f, 0.20011000335216522f, -1.11409997940063477f, 19.72100067138671875f, -0.67960000038146973f, -0.45403000712394714f, 17.77599906921386719f, -1.61679995059967041f, 0.37860000133514404f, 14.71500015258789062f, -2.53410005569458008f, 1.27540004253387451f, 11.86499977111816406f, -3.39079999923706055f, 2.2146000862121582f, 9.17669963836669922f, -4.03749990463256836f, 3.0522000789642334f, 6.59509992599487305f, -4.61299991607666016f, 3.89779996871948242f, 4.64589977264404297f, -5.43039989471435547f, 5.0121002197265625f, 3.3199000358581543f, -6.37769985198974609f, 6.33809995651245117f, 2.29699993133544922f, -7.44140005111694336f, 7.91739988327026367f, 1.45389997959136963f, -8.38580036163330078f, 9.60109996795654297f, 0.66465997695922852f, -9.0167999267578125f, 11.23999977111816406f, -0.04403600096702576f, -9.17749977111816406f, 12.63199996948242188f, -0.58126997947692871f, -8.97550010681152344f, 13.91499996185302734f, -0.95730000734329224f, -8.25290012359619141f, 14.86200046539306641f, -1.24430000782012939f, -6.92129993438720703f, 15.03899955749511719f, -1.43069994449615479f, -5.29169988632202148f, 14.90900039672851562f, -1.55149996280670166f, -3.43219995498657227f, 14.70499992370605469f, -1.63569998741149902f, -1.27190005779266357f, 14.24400043487548828f, -1.67030000686645508f, 1.15170001983642578f, 13.32199954986572266f, -1.636199951171875f, 3.73889994621276855f, 12.21199989318847656f, -1.56920003890991211f, 6.43590021133422852f, 10.94699954986572266f, -1.47730004787445068f, 9.16440010070800781f, 9.54769992828369141f, -1.36399996280670166f, 12.02000045776367188f, 8.18799972534179688f, -1.25450003147125244f, 14.78699970245361328f, 6.74429988861083984f, -1.13110005855560303f, 16.72299957275390625f, 5.08780002593994141f, -0.96561002731323242f, 18.14299964904785156f, 3.57019996643066406f, -0.80725997686386108f, 19.91900062561035156f, 2.36269998550415039f, -0.69273000955581665f, 21.05500030517578125f, 1.31369996070861816f, -0.58597999811172485f, 21.3899993896484375f, 0.42390000820159912f, -0.48298001289367676f, 20.99300003051757812f, -0.23857000470161438f, -0.39412000775337219f, 19.82200050354003906f, -0.6866300106048584f, -0.31501999497413635f, 18.12000083923339844f, -0.9412500262260437f, -0.24890999495983124f, 15.7089996337890625f, -1.02020001411437988f, -0.19076000154018402f, 13.19799995422363281f, -0.98919999599456787f, -0.14401000738143921f, 11.23999977111816406f, -0.93347001075744629f, -0.11133000254631042f, 9.36649990081787109f, -0.83820998668670654f, -0.08524099737405777f, 7.41249990463256836f, -0.70064002275466919f, -0.06283199787139893f, 5.71229982376098633f, -0.56079000234603882f, -0.04586699977517128f, 4.42280006408691406f, -0.44653001427650452f, -0.03396600112318993f, 3.34489989280700684f, -0.34457001090049744f, -0.02482499927282333f, 2.49309992790222168f, -0.26017999649047852f, -0.01808100007474422f, 1.82239997386932373f, -0.1921599954366684f, -0.01296999957412481f, 1.29499995708465576f, -0.13766999542713165f, -0.00907570030540228f, 0.92928999662399292f, -0.09956400096416473f, -0.00641620019450784f, 0.61835998296737671f, -0.06671299785375595f, -0.00421149982139468f, 0.40211999416351318f, -0.04354599863290787f, -0.00271830009296536f, 0.2844499945640564f, -0.03087200038135052f, -0.00191440002527088f, 0.20672999322414398f, -0.02246100082993507f, -0.00138829997740686f, 0.15044000744819641f, -0.01634499989449978f, -0.00101030000951141f, 0.10942000150680542f, -0.01188699994236231f, -0.0007347899954766f, 0.07099699974060059f, -0.00771349994465709f, -0.00047679000999779f, 0.04539500176906586f, -0.00493190018460155f, -0.00030484999297187f, 0.03424099832773209f, -0.00372010003775358f, -0.00022995000472292f, 0.02557599917054176f, -0.00277870008721948f, -0.00017175999528263f, 0.01842200011014938f, -0.00200140010565519f, -0.0001237099932041f, 0.01316899992525578f, -0.00143079995177686f, -0.00008843900286593f, 0.00838890019804239f, -0.00091141002485529f, -0.00005633700129692f, 0.00537079991772771f, -0.00058350997278467f, -0.00003606799873523f, 0.00328280008397996f, -0.00035665999166667f, -0.00002204600059486f, 0.00196009990759194f, -0.00021296000340953f, -0.00001316300040344f, 0.00168939994182438f, -0.00018354000349063f, -0.00001134499962063f, 0.00141050003003329f, -0.00015325000276789f, -0.00000947250009631f, 0.00097123999148607f, -0.00010551999730524f, -6.52239987175562419e-06f, 0.00066868000430986f, -0.00007264900341397f, -4.49060007667867467e-06f
} };
__device__ float3  wavelengthWeights(float wavelength_2)
{
    float _S1111 = clamp_1((wavelength_2 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    uint _S1112 = (U32_min((uint(_S1111)), (79U)));
    uint _S1113 = 3U * _S1112;
    float3  _S1114 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1113], WAVELENGTH_WEIGHTS_0[_S1113 + 1U], WAVELENGTH_WEIGHTS_0[_S1113 + 2U]);
    float3  _S1115 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1113 + 3U], WAVELENGTH_WEIGHTS_0[_S1113 + 4U], WAVELENGTH_WEIGHTS_0[_S1113 + 5U]);
    return _S1114 + (_S1115 - _S1114) * make_float3 (_S1111 - float(_S1112));
}

__device__ BSDFMaterial atWavelength(BSDFMaterial material_11, float wavelength_3)
{
    BSDFMaterial at_0 = material_11;
    float _S1116 = upsample(material_11.albedo, wavelength_3);
    float3  _S1117 = make_float3 (_S1116);
    (&at_0)->albedo = _S1117;
    float _S1118 = upsample(material_11.emissive, wavelength_3);
    float3  _S1119 = make_float3 (_S1118);
    (&at_0)->emissive = _S1119;
    float _S1120 = upsample(material_11.absorption, wavelength_3);
    float3  _S1121 = make_float3 (_S1120);
    (&at_0)->absorption = _S1121;
    float _S1122 = upsample(material_11.specular_tint, wavelength_3);
    float3  _S1123 = make_float3 (_S1122);
    (&at_0)->specular_tint = _S1123;
    float _S1124 = upsample(material_11.translucent, wavelength_3);
    float3  _S1125 = make_float3 (_S1124);
    (&at_0)->translucent = _S1125;
    float _S1126 = upsample(material_11.sheen, wavelength_3);
    float3  _S1127 = make_float3 (_S1126);
    (&at_0)->sheen = _S1127;
    return at_0;
}

__device__ float dispersedIor(float ior_1, float dispersion_1, float wavelength_4)
{
    float _S1128 = (ior_1 - 1.0f) * dispersion_1 / 1.90962409973144531f;
    float _S1129 = _S1128 * (1.0f / (wavelength_4 * wavelength_4) - 2.89662933349609375f);
    bool _S1130 = dispersion_1 > 0.0f;
    float _S1131 = _slang_select(_S1130, _S1129,0.0f);
    return ior_1 + _S1131;
}

__device__ float2  vertexEta(BSDFMaterial material_12, float n_dot_v_0)
{
    bool _S1132 = n_dot_v_0 < 0.0f;
    float _S1133 = _slang_select(_S1132, material_12.ior,1.0f);
    float _S1134 = _slang_select(_S1132, 1.0f,material_12.ior);
    return make_float2 (_S1133, _S1134);
}

__device__ float2  wavelengthEta(BSDFMaterial material_13, float n_dot_v_1, float wavelength_5)
{
    BSDFMaterial refractive_0 = material_13;
    float _S1135 = dispersedIor(material_13.ior, material_13.dispersion, wavelength_5);
    bool _S1136 = wavelength_5 > 0.0f;
    float _S1137 = _slang_select(_S1136, _S1135,material_13.ior);
    (&refractive_0)->ior = _S1137;
    float2  _S1138 = vertexEta(refractive_0, n_dot_v_1);
    return _S1138;
}

__device__ bool neeDecision(BSDFMaterial material_14, float n_dot_v_2, float eta_i_6, float eta_o_6)
{
    float _S1139 = fresnel((F32_abs((n_dot_v_2))), eta_i_6, eta_o_6);
    float3  _S1140 = mix_0(make_float3 (_S1139), material_14.albedo, material_14.metallic);
    float _S1141 = rgb_to_greyscale(_S1140);
    float _S1142 = (F32_max(((1.0f - _S1141) * (1.0f - material_14.metallic) * (1.0f - material_14.transmission)), (0.0f)));
    bool _S1143 = _S1142 > 0.03999999910593033f;
    bool _S1144;
    if(_S1143)
    {
        _S1144 = true;
    }
    else
    {
        _S1144 = (material_14.roughness) > 0.20000000298023224f;
    }
    return _S1144;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_15)
{
    float _S1145 = rgb_to_greyscale(material_15->translucent);
    return _S1145 > 0.0f;
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
    MediumSides _S1146;
    (&_S1146)->behind = *behind_0;
    (&_S1146)->front = *front_0;
    (&_S1146)->fillings = fillings_1;
    (&_S1146)->face = face_1;
    return _S1146;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_9, FKMedium * medium_0, uint filling_0, float3  dir_13, FKMedium * outside_0)
{
    float3  _S1147 = surface_9->geometry_n;
    MediumSides _S1148 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_9->geometry_n);
    MediumSides sides_0 = _S1148;
    bool _S1149 = surface_9->encloses;
    if(_S1149)
    {
        (&sides_0)->behind = surface_9->volume;
        *&((&(&sides_0)->fillings)->x) = surface_9->fills;
        bool _S1150 = (dot_0(dir_13, _S1147)) > 0.0f;
        if(_S1150)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_10, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_14, uint depth_3, uint lobe_7, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1151 = surface_10->geometry_n;
    ShadowContext _S1152 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_10->geometry_n, depth_3, lobe_7, true, length_3, width_2, own_3, fiber_1);
    bool _S1153 = surface_10->encloses;
    ShadowContext context_4;
    if(_S1153)
    {
        FKSurface faced_1 = *surface_10;
        float3  _S1154 = - _S1151;
        float3  _S1155 = _slang_select(turned_0, _S1154,_S1151);
        (&faced_1)->geometry_n = _S1155;
        FKMedium _S1156 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1157 = faced_1;
        FKMedium _S1158 = _S1156;
        MediumSides _S1159 = mediumSides_0(&_S1157, &_S1158, filling_1, dir_14, outside_1);
        ShadowContext _S1160 = ShadowContext_x24init_0(_S1159.behind.extinction, _S1159.front.extinction, _S1159.fillings, _S1151, depth_3, lobe_7, true, length_3, width_2, own_3, fiber_1);
        if(turned_0)
        {
            uint2  _S1161 = _S1159.fillings;
            ShadowContext _S1162 = ShadowContext_x24init_0(_S1159.front.extinction, _S1159.behind.extinction, uint2 {_S1161.y, _S1161.x}, _S1151, depth_3, lobe_7, true, length_3, width_2, own_3, fiber_1);
            context_4 = _S1162;
        }
        else
        {
            context_4 = _S1160;
        }
    }
    else
    {
        context_4 = _S1152;
    }
    return context_4;
}

static __device__ bool any_1(bool3  x_25)
{
    bool result_14 = false;
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
        if(result_14)
        {
            result_14 = true;
        }
        else
        {
            result_14 = (bool((_slang_vector_get_element(x_25, i_21))));
        }
        i_21 = i_21 + int(1);
    }
    return result_14;
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_7, float3  out_dir_1, float3  n_10, float3  g_n_0, BSDFMaterial material_16, float eta_i_7, float eta_o_7, uint random_state_13, MaterialTerms terms_4, ViewTerms view_terms_3)
{
    float3  _S1163 = negate_0(in_dir_7);
    bool _S1164 = (dot_0(g_n_0, _S1163) * dot_0(g_n_0, out_dir_1)) > 0.0f;
    uint _S1165;
    if((F32_abs((material_16.toon.x))) > 0.0f)
    {
        _S1165 = 1U;
    }
    else
    {
        _S1165 = 0U;
    }
    if(_S1164)
    {
        _S1165 = 3U + _S1165;
    }
    else
    {
        _S1165 = 1U;
    }
    float3  _S1166 = make_float3 (0.0f);
    float3  f_9 = _S1166;
    uint i_22 = 0U;
    for(;;)
    {
        if(i_22 < _S1165)
        {
        }
        else
        {
            break;
        }
        uint _S1167;
        if(!_S1164)
        {
            _S1167 = 1U;
        }
        else
        {
            if(i_22 == 0U)
            {
                _S1167 = 0U;
            }
            else
            {
                if(i_22 == 1U)
                {
                    _S1167 = 2U;
                }
                else
                {
                    if(i_22 == 2U)
                    {
                        _S1167 = 4U;
                    }
                    else
                    {
                        _S1167 = 6U;
                    }
                }
            }
        }
        SampleBSDF _S1168 = lobeBSDF(in_dir_7, out_dir_1, n_10, material_16, eta_i_7, eta_o_7, _S1167, random_state_13, terms_4, view_terms_3);
        if(i_22 == 0U)
        {
            f_9 = _S1168.throughput * make_float3 (_S1168.pdf);
        }
        else
        {
            f_9 = f_9 + _S1168.throughput * make_float3 (_S1168.pdf);
        }
        uint i_23 = i_22 + 1U;
        i_22 = i_23;
    }
    return f_9;
}

__device__ float3  translucentCorrection(float3  in_dir_8, float3  out_dir_2, float3  n_11, float3  g_n_1, BSDFMaterial material_17, float eta_i_8, float eta_o_8, uint random_state_14, MaterialTerms terms_5, ViewTerms view_terms_4)
{
    float _S1169 = dot_0(n_11, out_dir_2);
    float3  _S1170 = negate_0(in_dir_8);
    bool _S1171 = (_S1169 * dot_0(n_11, _S1170)) < 0.0f;
    SampleBSDF _S1172 = lobeBSDF(in_dir_8, out_dir_2, n_11, material_17, eta_i_8, eta_o_8, 0U, random_state_14, terms_5, view_terms_4);
    float3  _S1173 = negate_0(in_dir_8);
    bool _S1174 = (dot_0(g_n_1, _S1173) * dot_0(g_n_1, out_dir_2)) > 0.0f;
    float3  _S1175 = make_float3 (0.0f);
    float3  _S1176 = _S1172.throughput * make_float3 (_S1172.pdf);
    float _S1177 = _slang_select(_S1174, -1.0f,1.0f);
    float3  _S1178 = _S1176 * make_float3 (_S1177);
    float3  _S1179 = _slang_select(_S1171, _S1178,_S1175);
    return _S1179;
}

__device__ float3  translucentBSDF(float3  in_dir_9, float3  out_dir_3, float3  n_12, float3  g_n_2, BSDFMaterial material_18, float eta_i_9, float eta_o_9, uint random_state_15)
{
    MaterialTerms _S1180 = precomputeMaterial(material_18, eta_i_9, eta_o_9);
    ViewTerms _S1181 = precomputeView(in_dir_9, n_12, material_18, _S1180);
    float3  _S1182 = BSDF(in_dir_9, out_dir_3, n_12, g_n_2, material_18, eta_i_9, eta_o_9, random_state_15, _S1180, _S1181);
    float3  _S1183 = translucentCorrection(in_dir_9, out_dir_3, n_12, g_n_2, material_18, eta_i_9, eta_o_9, random_state_15, _S1180, _S1181);
    return _S1182 + _S1183;
}

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_10, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_4, BSDFMaterial * material_19, float eta_i_10, float eta_o_10, bool competing_1, uint random_state_16)
{
    bool _S1184 = !competing_1;
    bool _S1185;
    if(_S1184)
    {
        _S1185 = true;
    }
    else
    {
        _S1185 = (light_2->density) == 0.0f;
    }
    if(_S1185)
    {
        bool _S1186 = isTranslucent_0(material_19);
        _S1185 = _S1186;
    }
    else
    {
        _S1185 = false;
    }
    if(_S1185)
    {
        float3  _S1187 = translucentBSDF(in_dir_10, light_2->dir, smooth_n_5, geometry_n_4, *material_19, eta_i_10, eta_o_10, random_state_16);
        return _S1187 * light_2->radiance;
    }
    MaterialTerms _S1188 = precomputeMaterial(*material_19, eta_i_10, eta_o_10);
    ViewTerms _S1189 = precomputeView(in_dir_10, smooth_n_5, *material_19, _S1188);
    if(_S1184)
    {
        _S1185 = true;
    }
    else
    {
        _S1185 = (light_2->density) == 0.0f;
    }
    if(_S1185)
    {
        float3  _S1190 = BSDF(in_dir_10, light_2->dir, smooth_n_5, geometry_n_4, *material_19, eta_i_10, eta_o_10, random_state_16, _S1188, _S1189);
        return _S1190 * light_2->radiance;
    }
    float3  _S1191 = light_2->dir;
    bool _S1192 = (dot_0(geometry_n_4, - in_dir_10) * dot_0(geometry_n_4, light_2->dir)) <= 0.0f;
    float3  _S1193 = neeBSDF(in_dir_10, _S1191, smooth_n_5, *material_19, eta_i_10, eta_o_10, _S1192, light_2->density, true, random_state_16, _S1188, _S1189);
    return _S1193 * light_2->radiance * make_float3 (light_2->density);
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

static __device__ float3  reflect_0(float3  i_24, float3  n_13)
{
    return i_24 - make_float3 (2.0f * dot_0(n_13, i_24)) * n_13;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_11, float3  n_14, BSDFMaterial material_20, float eta_i_11, float eta_o_11, uint random_init_1, float2  screen_space_0, MaterialTerms terms_6, ViewTerms view_terms_5)
{
    uint random_state_17 = random_init_1;
    float3  _S1199 = negate_0(in_dir_11);
    float _S1200 = dot_0(n_14, _S1199);
    float _S1201 = sign_0(_S1200);
    float3  n_i_4 = n_14 * make_float3 (_S1201);
    float _S1202 = (F32_abs((_S1200)));
    float _S1203 = material_20.roughness;
    float _S1204 = _S1203 * _S1203;
    float3  _S1205 = sampleHalfVector(_S1199, n_i_4, _S1204, view_terms_5.frame, &random_state_17);
    HalfTerms _S1206 = precomputeHalf(in_dir_11, _S1205, material_20, eta_i_11, eta_o_11, terms_6, view_terms_5);
    float3  _S1207 = make_float3 (1.0f);
    SampleBSDF _S1208 = SampleBSDF_x24init_0(_S1207, _S1207, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S1208;
    Random _S1209 = pcg(random_state_17);
    random_state_17 = _S1209.state;
    float _S1210 = _S1209.value - _S1206.p_sheen_velvet;
    bool _S1211 = (_S1209.value) < (_S1206.p_sheen_velvet);
    float density_n_i_dot_l_0;
    float density_l_dot_h_0;
    if(_S1211)
    {
        Random _S1212 = pcg(random_state_17);
        Random _S1213 = pcg(_S1212.state);
        (&sample_1)->random_state = _S1213.state;
        float _S1214 = _S1212.value;
        float _S1215 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1214 * _S1214))))));
        float _S1216 = 6.28318548202514648f * _S1213.value;
        float3  _S1217 = tangentToWorld(make_float3 (_S1215 * (F32_cos((_S1216))), _S1212.value, _S1215 * (F32_sin((_S1216)))), n_i_4);
        (&sample_1)->unit_direction = _S1217;
        (&sample_1)->lobe = 4U;
        density_n_i_dot_l_0 = _S1212.value;
        density_l_dot_h_0 = 0.0f;
    }
    else
    {
        bool _S1218 = _S1210 < (_S1206.p_diffuse);
        if(_S1218)
        {
            Random _S1219 = pcg(random_state_17);
            Random _S1220 = pcg(_S1219.state);
            (&sample_1)->random_state = _S1220.state;
            float3  _S1221 = sampleCosWeightedHemisphere(_S1219.value, _S1220.value);
            bool _S1222 = _S1210 < (_S1206.p_diffuse * _S1206.translucent_share);
            float _S1223 = _S1221.y;
            float _S1224 = - _S1223;
            float _S1225 = _slang_select(_S1222, _S1224,_S1223);
            float3  _S1226 = tangentToWorld(make_float3 (_S1221.x, _S1225, _S1221.z), n_i_4);
            (&sample_1)->unit_direction = _S1226;
            (&sample_1)->refracted = _S1222;
            density_n_i_dot_l_0 = _S1225;
            density_l_dot_h_0 = 0.0f;
        }
        else
        {
            bool _S1227 = _S1210 < (_S1206.p_diffuse + _S1206.p_toon);
            if(_S1227)
            {
                Random _S1228 = pcg(random_state_17);
                Random _S1229 = pcg(_S1228.state);
                (&sample_1)->random_state = _S1229.state;
                float _S1230 = _S1228.value * _S1206.toon_norm / 6.28318548202514648f;
                if(_S1206.toon_glossy)
                {
                    density_n_i_dot_l_0 = (F32_acos((clamp_1(1.0f - _S1230, -1.0f, 1.0f))));
                }
                else
                {
                    density_n_i_dot_l_0 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1230)))), (1.0f))))));
                }
                if(density_n_i_dot_l_0 < (_S1206.toon_a))
                {
                }
                else
                {
                    density_n_i_dot_l_0 = (_S1206.toon_a + _S1206.toon_b) / 2.0f;
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
                    if(density_n_i_dot_l_0 < (_S1206.toon_a))
                    {
                        density_l_dot_h_0 = 1.0f;
                    }
                    else
                    {
                        density_l_dot_h_0 = (F32_max((1.0f - (density_n_i_dot_l_0 - _S1206.toon_a) / (F32_max((_S1206.toon_s), (0.0000152587890625f)))), (0.0f)));
                    }
                    float integral_1;
                    if(_S1206.toon_glossy)
                    {
                        integral_1 = 1.0f - (F32_cos(((F32_min((density_n_i_dot_l_0), (_S1206.toon_a))))));
                    }
                    else
                    {
                        float _S1231 = (F32_sin(((F32_min((density_n_i_dot_l_0), (_S1206.toon_a))))));
                        integral_1 = _S1231 * _S1231 / 2.0f;
                    }
                    bool _S1232 = density_n_i_dot_l_0 > (_S1206.toon_a);
                    bool _S1233;
                    if(_S1232)
                    {
                        _S1233 = (_S1206.toon_s) > 0.0f;
                    }
                    else
                    {
                        _S1233 = false;
                    }
                    float integral_2;
                    if(_S1233)
                    {
                        if(_S1206.toon_glossy)
                        {
                            float _S1234 = (F32_cos((_S1206.toon_a)));
                            float _S1235 = (F32_cos((density_n_i_dot_l_0)));
                            integral_2 = (1.0f + _S1206.toon_a / _S1206.toon_s) * (_S1234 - _S1235) - ((F32_sin((density_n_i_dot_l_0))) - density_n_i_dot_l_0 * _S1235 - ((F32_sin((_S1206.toon_a))) - _S1206.toon_a * _S1234)) / _S1206.toon_s;
                        }
                        else
                        {
                            float _S1236 = 2.0f * _S1206.toon_a;
                            float _S1237 = (F32_cos((_S1236)));
                            float _S1238 = 2.0f * density_n_i_dot_l_0;
                            float _S1239 = (F32_cos((_S1238)));
                            integral_2 = (1.0f + _S1206.toon_a / _S1206.toon_s) * (_S1237 - _S1239) / 4.0f - ((F32_sin((_S1238))) / 8.0f - density_n_i_dot_l_0 * _S1239 / 4.0f - ((F32_sin((_S1236))) / 8.0f - _S1206.toon_a * _S1237 / 4.0f)) / _S1206.toon_s;
                        }
                        float integral_3 = integral_1 + integral_2;
                        integral_2 = integral_3;
                    }
                    else
                    {
                        integral_2 = integral_1;
                    }
                    float _S1240 = density_l_dot_h_0 * (F32_sin((density_n_i_dot_l_0)));
                    float _S1241;
                    if(_S1206.toon_glossy)
                    {
                        _S1241 = 1.0f;
                    }
                    else
                    {
                        _S1241 = (F32_cos((density_n_i_dot_l_0)));
                    }
                    float _S1242 = _S1240 * _S1241;
                    float _S1243 = (integral_2 - _S1230) / _S1242;
                    bool _S1244 = _S1242 > 0.0f;
                    float _S1245 = _slang_select(_S1244, _S1243,0.0f);
                    float _S1246 = clamp_1(density_n_i_dot_l_0 - _S1245, 0.0f, _S1206.toon_b);
                    int k_1 = k_0 + int(1);
                    density_n_i_dot_l_0 = _S1246;
                    k_0 = k_1;
                }
                float _S1247 = 6.28318548202514648f * _S1229.value;
                float _S1248 = (F32_sin((density_n_i_dot_l_0)));
                float3  _S1249 = tangentToWorld(make_float3 (_S1248 * (F32_cos((_S1247))), (F32_cos((density_n_i_dot_l_0))), _S1248 * (F32_sin((_S1247)))), _S1206.toon_axis);
                (&sample_1)->unit_direction = _S1249;
                float _S1250 = dot_0(n_i_4, (&sample_1)->unit_direction);
                float _S1251 = dot_0((&sample_1)->unit_direction, _S1206.toon_axis);
                bool _S1252 = (dot_0(n_i_4, (&sample_1)->unit_direction)) < 0.0f;
                (&sample_1)->refracted = _S1252;
                (&sample_1)->lobe = 6U;
                density_n_i_dot_l_0 = _S1250;
                density_l_dot_h_0 = _S1251;
            }
            else
            {
                bool _S1253 = (_S1210 - _S1206.p_toon) < (_S1206.p_diffuse + _S1206.p_refract);
                if(_S1253)
                {
                    (&sample_1)->unit_direction = _S1206.refracted;
                    float _S1254 = dot_0((&sample_1)->unit_direction, _S1205);
                    (&sample_1)->random_state = random_state_17;
                    (&sample_1)->refracted = true;
                    (&sample_1)->lobe = 1U;
                    density_n_i_dot_l_0 = _S1254;
                }
                else
                {
                    float3  _S1255 = reflect_0(in_dir_11, _S1205);
                    float3  _S1256 = ((((_S1255)) * make_float3(rnorm3df(((_S1255)).x, ((_S1255)).y, ((_S1255)).z))));
                    (&sample_1)->unit_direction = _S1256;
                    (&sample_1)->random_state = random_state_17;
                    (&sample_1)->lobe = 2U;
                    density_n_i_dot_l_0 = 0.0f;
                }
                float _S1257 = density_n_i_dot_l_0;
                density_n_i_dot_l_0 = 0.0f;
                density_l_dot_h_0 = _S1257;
            }
        }
    }
    float3  _S1258 = lobeThroughput((&sample_1)->unit_direction, n_i_4, _S1204, material_20, _S1206, (&sample_1)->lobe);
    (&sample_1)->throughput = _S1258;
    float _S1259 = lobeDensity(density_n_i_dot_l_0, density_l_dot_h_0, _S1202, _S1204, _S1206, eta_i_11, eta_o_11, (&sample_1)->lobe);
    (&sample_1)->pdf = _S1259;
    return sample_1;
}

__device__ bool withinInverseFootprint(float pdf_8, bool diffuse_0, float prev_cos_0, float distance_5, float threshold_1)
{
    bool _S1260 = pdf_8 > 0.0f;
    bool _S1261;
    if(_S1260)
    {
        if(diffuse_0)
        {
            _S1261 = true;
        }
        else
        {
            _S1261 = (pdf_8 * prev_cos_0 / (distance_5 * distance_5) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S1261 = false;
    }
    return _S1261;
}

__device__ bool roughLobe(float pdf_9, bool diffuse_1, float roughness_1)
{
    bool _S1262 = pdf_9 > 0.0f;
    bool _S1263;
    if(_S1262)
    {
        if(diffuse_1)
        {
            _S1263 = true;
        }
        else
        {
            _S1263 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S1263 = false;
    }
    return _S1263;
}

static __device__ bool passesLayer_0(uint layers_0, bool refracting_0, bool passed_0)
{
    bool _S1264 = layers_0 > 1U;
    bool _S1265;
    if(_S1264)
    {
        _S1265 = refracting_0 != passed_0;
    }
    else
    {
        _S1265 = false;
    }
    return _S1265;
}

static __device__ float widened_0(float spread_1, float pdf_10, bool delta_0)
{
    float _S1266 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * pdf_10))))), (3.14159274101257324f)));
    bool _S1267 = !delta_0;
    float _S1268 = _slang_select(_S1267, _S1266,0.0f);
    return spread_1 + _S1268;
}

static __device__ bool boundsVolume_0(FKSurface * surface_11)
{
    return surface_11->encloses;
}

static __device__ bool leavesInFront_0(float3  face_2, float3  dir_15, float3  g_3)
{
    return ((dot_0(dir_15, g_3)) > 0.0f) == ((dot_0(g_3, face_2)) > 0.0f);
}

static __device__ Shift walk_0(Domain * dom_7, Reservoir * r_8, bool replay_2, float scale_4, Selection * sel_7)
{
    float spread_2;
    bool turned_1;
    bool is_inside_6;
    bool viewed_0;
    bool _S1269;
    float density_2;
    float wavelength_6;
    float width_3;
    float sky_pdf_0;
    float threshold_2;
    uint b_8;
    uint layer_0;
    float3  throughput_2;
    float3  spectral_weight_0;
    TreeSample light_3;
    int _S1270;
    Shift ended_0;
    float density_3;
    float spread_3;
    float width_4;
    float sky_pdf_1;
    float spread_4;
    float width_5;
    uint b_9;
    float3  _S1271 = make_float3 (0.0f);
    Shift _S1272 = Shift_x24init_0(_S1271, 0.0f);
    uint _S1273 = r_8->path;
    uint _S1274 = extractBits_0(r_8->path, 0U, 5U);
    uint _S1275 = extractBits_0(_S1273, 5U, 5U);
    uint _S1276 = extractBits_0(_S1273, 10U, 2U);
    uint _S1277 = extractBits_0(_S1273, 12U, 3U);
    bool passes_0;
    if(replay_2)
    {
        bool _S1278 = _S1277 >= 3U;
        uint _S1279 = _slang_select(_S1278, 1U,0U);
        uint _S1280 = _S1274 + _S1279;
        uint _S1281 = (fcptMaxBounces());
        passes_0 = _S1280 > _S1281;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1272;
    }
    uint _S1282 = _S1275 - 1U;
    bool _S1283 = _S1277 == 3U;
    uint _S1284 = _slang_select(_S1283, 1U,0U);
    uint _S1285 = _S1274 + _S1284;
    bool _S1286 = _S1276 == 0U;
    uint _S1287 = _slang_select(_S1286, _S1285,_S1282);
    FKHit _S1288 = (fcptReservoirHit((*r_8)));
    float3  _S1289 = dom_7->x0;
    float3  _S1290 = dom_7->x1 - dom_7->x0;
    float3  _S1291 = ((((_S1290)) * make_float3(rnorm3df(((_S1290)).x, ((_S1290)).y, ((_S1290)).z))));
    FKRay _S1292 = Ray_x24init_0(dom_7->x1, _S1291);
    FKRay ray_2 = _S1292;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1271;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_2 = throughput_3;
    float3  glowed_0 = _S1271;
    float3  extinction_in_0 = _S1271;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1293 = dom_7->spread;
    float _S1294 = dom_7->width;
    float _S1295 = length_0(_S1290);
    NEEVertex _S1296 = NEEVertex_x24init_0(true, 0.0f, _S1271, _S1271, _S1271);
    NEEVertex nee_vertex_0 = _S1296;
    Vertex _S1297 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S1297;
    Reservoir _S1298 = (Reservoir{});
    Reservoir chain_0 = _S1298;
    uint _S1299 = r_8->seed;
    (&chain_0)->seed = r_8->seed;
    uint _S1300 = extractBits_0(_S1273, 24U, 8U);
    uint _S1301 = insertBits_0(0U, _S1300, 24U, 8U);
    (&chain_0)->path = _S1301;
    (&ray_2)->origin = _S1289;
    (&hit_4)->distance = _S1295;
    FKMedium _S1302 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1303 = filling_2;
    bool _S1304 = (fcptVaryingUsed());
    uint _S1305 = _slang_select(_S1304, _S1303,4294967295U);
    filling_2 = _S1305;
    scatter_in_0 = _S1302.scatter;
    extinction_in_0 = _S1302.extinction;
    g_in_0 = _S1302.g;
    Reservoir _S1306 = chain_0;
    uint _S1307 = filling_2;
    for(;;)
    {
        bool _S1308 = (fcptVaryingUsed());
        if(_S1308)
        {
            passes_0 = _S1307 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1309 = (fcptMajorant((_S1307)));
            spread_2 = _S1309;
        }
        else
        {
            spread_2 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_2)
        {
            turned_1 = 4294967295U == _S1287;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1276 == 1U;
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
            ended_0 = _S1272;
            sky_pdf_0 = 0.0f;
            spread_2 = _S1293;
            width_3 = _S1294;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_8 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1310 = (&prev_0)->rough;
        if(_S1310)
        {
            turned_1 = !(spread_2 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S1311 = stream(_S1299, 384U);
        uint tracking_0 = _S1311;
        weight_2 = throughput_3;
        glowed_0 = _S1271;
        b_8 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        wavelength_6 = _S1293;
        width_3 = _S1294;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1270 = int(1);
                break;
            }
            uint _S1312 = b_8 + 320U;
            bool _S1313 = b_8 == 4294967295U;
            uint _S1314 = _slang_select(_S1313, 384U,_S1312);
            uint _S1315 = stream(_S1299, _S1314);
            Random _S1316 = pcg(_S1315);
            float _S1317 = freeFlight_0(_S1316.value, spread_2);
            if(passes_0)
            {
                float3  _S1318 = (&ray_2)->origin;
                float3  _S1319 = (&ray_2)->unit_direction;
                float _S1320 = (&hit_4)->distance;
                uint _S1321 = _slang_select(_S1313, 0U,b_8);
                uint _S1322 = (&prev_0)->lobe;
                uint _S1323 = _slang_select(_S1313, 3U,_S1322);
                float _S1324 = (fcptTrackMedium((_S1307), (_S1318), (_S1319), (_S1320), (&tracking_0), (&weight_2), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1321), (_S1323), (_S1313)));
                threshold_2 = _S1324;
            }
            else
            {
                threshold_2 = _S1317;
            }
            bool _S1325 = !(threshold_2 < ((&hit_4)->distance));
            if(_S1325)
            {
                _S1270 = int(1);
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
                float3  _S1326 = pathColor(throughput_2 * glowed_0, throughput_3, 0.0f);
                float3  _S1327 = _S1326 / make_float3 (density_2);
                float3  _S1328 = sel_7->glow + _S1327;
                sel_7->glow = _S1328;
            }
            else
            {
            }
            glowed_0 = _S1271;
            uint b_10 = b_8 + 1U;
            float3  _S1329 = (&ray_2)->origin + make_float3 (threshold_2) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1329;
            float3  _S1330 = flightWeight_0(scatter_in_0, extinction_in_0, spread_2, threshold_2, true);
            float3  _S1331 = weight_2;
            float _S1332 = upsample(weight_2, 0.0f);
            float3  _S1333 = make_float3 (_S1332);
            float3  _S1334 = _slang_select(false, _S1333,_S1331);
            float3  _S1335 = _slang_select(passes_0, _S1334,_S1330);
            float3  throughput_4 = throughput_2 * _S1335;
            uint _S1336 = stream(_S1299, b_10 + 320U);
            tracking_0 = _S1336;
            weight_2 = throughput_3;
            float width_6 = width_3 + wavelength_6 * threshold_2;
            float _S1337 = wavelength_6 + 3.14159274101257324f;
            bool _S1338 = scatterSampled_0(replay_2, b_10, _S1287, passes_0);
            TreeSample _S1339 = TreeSample_x24init_0(_S1271, _S1271, 0.0f, 0U);
            if(_S1338)
            {
                float3  _S1340 = (&ray_2)->origin;
                float3  _S1341 = (&ray_2)->unit_direction;
                float3  _S1342 = (&ray_2)->unit_direction;
                uint _S1343 = stream(_S1299, b_10 + 64U);
                float3  _S1344 = extinction_in_0;
                float3  _S1345 = extinction_in_0;
                uint2  _S1346 = make_uint2 (_S1307);
                float3  _S1347 = (&ray_2)->unit_direction;
                uint _S1348 = arrivalLobe_0(b_10, (&prev_0)->lobe);
                FKHit _S1349 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1350 = _S1349;
                ShadowContext _S1351 = ShadowContext_x24init_0(_S1344, _S1345, _S1346, _S1347, b_10, _S1348, false, threshold_2, width_6, &_S1350, false);
                ShadowContext _S1352 = _S1351;
                TreeSample _S1353 = sampleLightTree_0(_S1340, _S1341, _S1342, 0.0f, true, _S1343, &_S1352);
                light_3 = _S1353;
            }
            else
            {
                light_3 = _S1339;
            }
            float _S1354 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S1355 = (fcptMaxBounces());
            bool _S1356 = b_10 < _S1355;
            if(_S1356)
            {
                is_inside_6 = (light_3.density) > 0.0f;
            }
            else
            {
                is_inside_6 = false;
            }
            float _S1357 = _slang_select(is_inside_6, _S1354,0.0f);
            float3  _S1358 = throughput_4 * light_3.radiance;
            float _S1359 = powerHeuristic(light_3.density, _S1357);
            float3  _S1360 = pathColor(_S1358 * make_float3 (_S1354 * _S1359), throughput_3, 0.0f);
            float3  _S1361 = _slang_select(_S1338, _S1360,_S1271);
            if(replay_2)
            {
                viewed_0 = b_10 == _S1287;
            }
            else
            {
                viewed_0 = false;
            }
            if(viewed_0)
            {
                bool _S1362 = _S1276 == 2U;
                if(_S1362)
                {
                    float _S1363 = resamplingTarget(_S1361);
                    passes_0 = _S1363 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1364 = Shift_x24init_0(_S1361, 1.0f);
                    _S1270 = int(0);
                    ended_0 = _S1364;
                    spread_2 = _S1337;
                    threshold_2 = width_6;
                    spectral_weight_0 = throughput_4;
                    layer_0 = b_10;
                    break;
                }
                _S1270 = int(0);
                ended_0 = _S1272;
                spread_2 = _S1337;
                threshold_2 = width_6;
                spectral_weight_0 = throughput_4;
                layer_0 = b_10;
                break;
            }
            bool _S1365 = !replay_2;
            if(_S1365)
            {
                Reservoir candidate_3 = _S1306;
                uint _S1366 = extractBits_0(_S1306.path, 24U, 8U);
                uint _S1367 = insertBits_0(0U, _S1366, 24U, 8U);
                uint _S1368 = extractBits_0(_S1306.path, 10U, 2U);
                bool _S1369 = _S1368 == 1U;
                if(_S1369)
                {
                    float3  _S1370 = safeDivide(_S1361, _S1271);
                    (&candidate_3)->radiance = _S1370;
                }
                else
                {
                    uint _S1371 = insertBits_0(_S1367, b_10 + 1U, 5U, 5U);
                    uint _S1372 = insertBits_0(_S1371, 2U, 10U, 2U);
                    (&candidate_3)->path = _S1372;
                }
                Reservoir _S1373 = withEnd(candidate_3, 0U, b_10, _S1361);
                offer(sel_7, _S1373, _S1361 * make_float3 (scale_4) / make_float3 (density_2));
                float _S1374 = survivalProbability(abs_0(throughput_4), density_2);
                uint _S1375 = stream(_S1299, b_10 + 128U);
                Random _S1376 = pcg(_S1375);
                bool _S1377 = _S1374 < (_S1376.value);
                if(_S1377)
                {
                    _S1269 = true;
                }
                else
                {
                    uint _S1378 = (fcptMaxBounces());
                    _S1269 = b_10 >= _S1378;
                }
                if(_S1269)
                {
                    _S1270 = int(0);
                    ended_0 = _S1272;
                    spread_2 = _S1337;
                    threshold_2 = width_6;
                    spectral_weight_0 = throughput_4;
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
            uint _S1380 = stream(_S1299, b_10);
            float3  _S1381 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1380, &phase_pdf_0);
            (&ray_2)->unit_direction = _S1381;
            NEEVertex _S1382 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S1271, (&ray_2)->origin);
            nee_vertex_0 = _S1382;
            Vertex _S1383 = scatteredVertex_0(false);
            prev_0 = _S1383;
            float _S1384 = (&prev_0)->pdf;
            FKRay _S1385 = ray_2;
            FKHit _S1386 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1387 = (fcptTraverseInstanceBVH((_S1385), (true), (4.294967296e+09f), (false), (_S1386), (false)));
            hit_4 = _S1387;
            b_8 = b_10;
            throughput_2 = throughput_4;
            wavelength_6 = _S1337;
            width_3 = width_6;
            sky_pdf_0 = _S1384;
        }
        if(_S1270 != int(1))
        {
            width_3 = threshold_2;
            throughput_2 = spectral_weight_0;
            b_8 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1272;
        spread_2 = wavelength_6;
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
        float3  _S1394 = pathColor(throughput_2 * _S1393, throughput_3, 0.0f);
        if(replay_2)
        {
            bool _S1395 = b_8 == _S1287;
            if(_S1395)
            {
                passes_0 = _S1276 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S1394 * make_float3 (_S1392) / make_float3 (r_8->jac), density_2 / r_8->jac);
            }
            if(_S1286)
            {
                passes_0 = _S1283;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_8 == _S1274;
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
            return _S1272;
        }
        Reservoir candidate_4 = chain_0;
        uint _S1396 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1397 = _S1396 == 1U;
        if(_S1397)
        {
            uint _S1398 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S1399 = _S1398 == b_8;
            float _S1400 = _slang_select(_S1399, 1.0f,_S1392);
            float3  _S1401 = safeDivide(_S1394 * make_float3 (_S1400), _S1271);
            (&candidate_4)->radiance = _S1401;
        }
        else
        {
            bool _S1402 = (&prev_0)->rough;
            if(_S1402)
            {
                uint _S1403 = insertBits_0(_S1301, b_8 + 1U, 5U, 5U);
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
        return _S1272;
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
            float3  _S1414 = pathColor(throughput_2 * glowed_0, throughput_3, 0.0f);
            float3  _S1415 = _S1414 / make_float3 (density_2);
            float3  _S1416 = sel_7->glow + _S1415;
            sel_7->glow = _S1416;
        }
        float3  _S1417 = throughput_2 * weight_2;
        throughput_2 = _S1417;
    }
    else
    {
        float3  _S1418 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
        float3  _S1419 = throughput_2 * _S1418;
        throughput_2 = _S1419;
    }
    float _S1420 = width_3 + spread_2 * (&hit_4)->distance;
    uint _S1421 = b_8 + 1U;
    b_8 = _S1421;
    layer_0 = 0U;
    width_3 = _S1420;
    passes_0 = false;
    wavelength_6 = 0.0f;
    threshold_2 = 0.0f;
    turned_1 = false;
    is_inside_6 = false;
    spectral_weight_0 = throughput_3;
    float3  chain_throughput_0 = _S1271;
    float3  reconnection_0 = _S1271;
    viewed_0 = _S1388;
    for(;;)
    {
        bool _S1422 = ((&hit_4)->is_point_light) == 1U;
        if(replay_2)
        {
            _S1269 = _S1276 == 1U;
        }
        else
        {
            _S1269 = false;
        }
        bool _S1423;
        if(_S1269)
        {
            _S1423 = b_8 == _S1275;
        }
        else
        {
            _S1423 = false;
        }
        bool _S1424;
        if(_S1423)
        {
            bool _S1425 = ((&hit_4)->instance_index) != (_S1288.instance_index);
            if(_S1425)
            {
                _S1424 = true;
            }
            else
            {
                _S1424 = ((&hit_4)->triangle_index) != (_S1288.triangle_index);
            }
        }
        else
        {
            _S1424 = false;
        }
        if(_S1424)
        {
            return _S1272;
        }
        FKMedium _S1426 = Medium_x24init_0(_S1271, _S1271, 0.0f);
        BSDFMaterial _S1427 = Material_x24init_0(_S1271, _S1271, 0.0f, 0.0f, 0.0f, 0.0f, _S1271, throughput_3, 1.0f, _S1271, _S1271, 0.5f, 0.0f, 0.0f, _S1271, 0.0f, _S1271, 0.0f);
        FKMedium _S1428 = _S1426;
        FKSurface _S1429 = Surface_x24init_0(_S1271, _S1271, 0.0f, &_S1427, false, 0U, 1.0f, false, &_S1428, 4294967295U, _S1271);
        bool _S1430 = !_S1422;
        bool scatter_2;
        bool is_inside_7;
        float geometry_density_2;
        float3  throughput_5;
        FKSurface surface_12;
        if(_S1430)
        {
            uint _S1431 = stream(_S1299, b_8);
            uint _S1432 = arrivalLobe_0(b_8, (&prev_0)->lobe);
            FKSurface _S1433 = (fcptSurfaceAtPath((hit_4), ((&ray_2)->origin), (_S1431), (width_3), (layer_0), (b_8), (_S1432), ((&ray_2)->unit_direction)));
            bool _S1434 = !passes_0;
            FKSurface _S1435 = _S1433;
            FKSurface _S1436 = emitting_0(&_S1435, _S1434);
            uint _S1437 = stream(_S1299, b_8 + 256U);
            Random _S1438 = pcg(_S1437);
            FKSurface _S1439 = _S1436;
            FKSurface _S1440 = uncovered_0(&_S1439, _S1438.value);
            float _S1441 = facingSign(_S1440.material.transmission, _S1440.geometry_n, (&ray_2)->unit_direction);
            bool _S1442 = _S1441 < 0.0f;
            bool _S1443 = (_S1440.material.transmission) > 0.0f;
            if(_S1443)
            {
                bool _S1444 = arrivesBehind_0((&ray_2)->unit_direction, _S1440.geometry_n);
                scatter_2 = _S1444;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1445 = _S1440;
            FKSurface _S1446 = facingRay_0(&_S1445, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S1447 = arrivesBehind_0((&ray_2)->unit_direction, _S1446.geometry_n);
                is_inside_7 = _S1447;
            }
            else
            {
                is_inside_7 = scatter_2;
            }
            if(is_inside_7)
            {
                float _S1448 = (&hit_4)->distance;
                float _S1449 = upsample(_S1446.material.absorption, wavelength_6);
                float3  _S1450 = make_float3 (_S1449);
                bool _S1451 = wavelength_6 > 0.0f;
                float3  _S1452 = _slang_select(_S1451, _S1450,_S1446.material.absorption);
                float3  _S1453 = beerLambert(_S1448, _S1452);
                float3  _S1454 = throughput_2 * _S1453;
                throughput_5 = _S1454;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S1455 = !_S1446.skip;
            float geometry_density_3 = geometryDensity(_S1446.geometry_n, (&ray_2)->unit_direction, (&hit_4)->distance);
            bool _S1456 = b_8 == _S1421;
            if(_S1456)
            {
                float _S1457 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S1457;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            float _S1458 = geometry_density_2;
            scatter_2 = _S1455;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S1458;
            surface_12 = _S1446;
            turned_1 = _S1442;
        }
        else
        {
            scatter_2 = false;
            geometry_density_2 = 0.0f;
            surface_12 = _S1429;
            throughput_5 = throughput_2;
            is_inside_7 = is_inside_6;
        }
        bool _S1459 = withinFootprint(scatter_2, (&prev_0)->rough, (&prev_0)->pdf, geometry_density_2, threshold_2);
        FKSurface _S1460 = surface_12;
        float _S1461 = dot_0(surface_12.smooth_n, - (&ray_2)->unit_direction);
        bool _S1462 = (fcptDispersionUsed());
        bool _S1463;
        if(_S1462)
        {
            _S1463 = wavelength_6 == 0.0f;
        }
        else
        {
            _S1463 = false;
        }
        bool _S1464;
        if(_S1463)
        {
            _S1464 = scatter_2;
        }
        else
        {
            _S1464 = false;
        }
        bool _S1465;
        if(_S1464)
        {
            bool _S1466 = dispersive(surface_12.material);
            _S1465 = _S1466;
        }
        else
        {
            _S1465 = false;
        }
        float3  throughput_6;
        if(_S1465)
        {
            uint _S1467 = stream(_S1299, 512U);
            Random _S1468 = pcg(_S1467);
            uint _S1469 = extractBits_0(_S1273, 25U, 7U);
            float _S1470 = (float(_S1469) + _S1468.value) / 128.0f;
            uint _S1471 = extractBits_0(_S1273, 24U, 1U);
            bool _S1472 = _S1471 == 1U;
            float _S1473 = _slang_select(_S1472, _S1470,_S1468.value);
            float2  _S1474 = sampleWavelength(_S1473);
            float wavelength_7 = _S1474.x;
            float3  _S1475 = wavelengthWeights(wavelength_7);
            float3  _S1476 = _S1475 / make_float3 (_S1474.y);
            float _S1477 = upsample(throughput_5, wavelength_7);
            float3  _S1478 = make_float3 (_S1477);
            float _S1479 = upsample(scatter_in_0, wavelength_7);
            float3  _S1480 = make_float3 (_S1479);
            scatter_in_0 = _S1480;
            float _S1481 = upsample(extinction_in_0, wavelength_7);
            float3  _S1482 = make_float3 (_S1481);
            extinction_in_0 = _S1482;
            wavelength_6 = wavelength_7;
            throughput_6 = _S1478;
            spectral_weight_0 = _S1476;
        }
        else
        {
            throughput_6 = throughput_5;
        }
        bool _S1483 = wavelength_6 > 0.0f;
        BSDFMaterial _S1484;
        if(_S1483)
        {
            BSDFMaterial _S1485 = atWavelength(surface_12.material, wavelength_6);
            _S1484 = _S1485;
        }
        else
        {
            _S1484 = surface_12.material;
        }
        float2  _S1486 = wavelengthEta(_S1484, _S1461, wavelength_6);
        bool _S1487;
        if(scatter_2)
        {
            bool _S1488 = neeDecision(_S1484, _S1461, _S1486.x, _S1486.y);
            _S1487 = _S1488;
        }
        else
        {
            _S1487 = false;
        }
        bool _S1489;
        if(passes_0)
        {
            _S1489 = true;
        }
        else
        {
            _S1489 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1489)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1487;
        }
        bool _S1490 = (fcptHairUsed());
        bool _S1491;
        if(_S1490)
        {
            float3  _S1492 = surface_12.hair;
            _S1491 = (dot_0(_S1492, _S1492)) > 0.0f;
        }
        else
        {
            _S1491 = false;
        }
        bool _S1493;
        if(_S1491)
        {
            _S1493 = true;
        }
        else
        {
            BSDFMaterial _S1494 = _S1484;
            bool _S1495 = isTranslucent_0(&_S1494);
            _S1493 = _S1495;
        }
        bool _S1496;
        if(_S1493)
        {
            _S1496 = true;
        }
        else
        {
            bool _S1497 = (_S1484.transmission) > 0.0f;
            if(_S1497)
            {
                uint _S1498 = (fcptLayers((hit_4)));
                _S1496 = _S1498 == 1U;
            }
            else
            {
                _S1496 = false;
            }
        }
        BSDFMaterial _S1499 = _S1484;
        float3  emission_0;
        if(_S1422)
        {
            float3  _S1500 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1500;
        }
        else
        {
            emission_0 = _S1499.emissive;
        }
        float _S1501 = rgb_to_greyscale(emission_0);
        bool _S1502 = _S1501 > 0.0f;
        float3  emission_1;
        if(_S1502)
        {
            NEEVertex _S1503 = nee_vertex_0;
            FKHit _S1504 = hit_4;
            float _S1505 = emissionWeight_0(&_S1503, &_S1504, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1505);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1506;
        if(replay_2)
        {
            _S1506 = _S1276 == 1U;
        }
        else
        {
            _S1506 = false;
        }
        bool _S1507;
        if(_S1506)
        {
            _S1507 = b_8 > _S1275;
        }
        else
        {
            _S1507 = false;
        }
        bool _S1508;
        if(_S1507)
        {
            _S1508 = b_8 == _S1274;
        }
        else
        {
            _S1508 = false;
        }
        bool _S1509;
        if(_S1508)
        {
            bool _S1510 = _S1277 == 1U;
            if(_S1510)
            {
                _S1509 = true;
            }
            else
            {
                _S1509 = _S1277 == 2U;
            }
        }
        else
        {
            _S1509 = false;
        }
        if(_S1509)
        {
            bool _S1511 = _S1422 != (_S1277 == 2U);
            if(_S1511)
            {
                return _S1272;
            }
            float3  _S1512 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_6);
            return Shift_x24init_0(_S1512 / make_float3 (r_8->jac), density_2 / r_8->jac);
        }
        uint _S1513 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1514 = _S1513 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1515 = insertBits_0(_S1301, b_8, 5U, 5U);
        uint _S1516 = insertBits_0(_S1515, 1U, 10U, 2U);
        uint _S1517 = insertBits_0(_S1516, (&prev_0)->lobe, 15U, 3U);
        bool _S1518 = (&prev_0)->inside;
        uint _S1519 = _slang_select(_S1518, 1U,0U);
        uint _S1520 = insertBits_0(_S1517, _S1519, 22U, 1U);
        (&here_0)->path = _S1520;
        uint _S1521 = (&here_0)->path;
        uint _S1522 = _slang_select(_S1483, 1U,0U);
        uint _S1523 = insertBits_0(_S1521, _S1522, 23U, 1U);
        (&here_0)->path = _S1523;
        float _S1524 = (&prev_0)->pdf * geometry_density_2;
        (&here_0)->jac = _S1524;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1525;
        if(replay_2)
        {
            _S1525 = _S1276 == 1U;
        }
        else
        {
            _S1525 = false;
        }
        bool _S1526;
        if(_S1525)
        {
            _S1526 = b_8 == _S1275;
        }
        else
        {
            _S1526 = false;
        }
        bool _S1527 = b_8 == _S1287;
        bool _S1528;
        if(_S1527)
        {
            bool _S1529 = !scatter_2;
            if(_S1529)
            {
                _S1528 = true;
            }
            else
            {
                bool _S1530 = _S1276 != 1U;
                if(_S1530)
                {
                    _S1528 = _S1276 != 3U;
                }
                else
                {
                    _S1528 = false;
                }
            }
        }
        else
        {
            _S1528 = false;
        }
        bool _S1531;
        if(_S1528)
        {
            _S1531 = _S1276 == 2U;
        }
        else
        {
            _S1531 = false;
        }
        bool _S1532;
        if(_S1531)
        {
            _S1532 = !_S1459;
        }
        else
        {
            _S1532 = false;
        }
        bool _S1533;
        if(_S1532)
        {
            _S1533 = _S1277 != 4U;
        }
        else
        {
            _S1533 = false;
        }
        bool _S1534 = _S1275 == _S1274;
        bool _S1535;
        if(_S1534)
        {
            _S1535 = _S1277 == 0U;
        }
        else
        {
            _S1535 = false;
        }
        bool _S1536;
        if(_S1535)
        {
            _S1536 = ((&hit_4)->instance_index) == (_S1288.instance_index);
        }
        else
        {
            _S1536 = false;
        }
        bool _S1537;
        if(_S1536)
        {
            _S1537 = ((&hit_4)->triangle_index) == (_S1288.triangle_index);
        }
        else
        {
            _S1537 = false;
        }
        bool _S1538;
        if(_S1537)
        {
            _S1538 = _S1459;
        }
        else
        {
            _S1538 = false;
        }
        bool _S1539 = _slang_select(_S1526, _S1538,_S1533);
        bool _S1540;
        if(nee_0)
        {
            _S1540 = _slang_select(replay_2, _S1539,scatter_2);
        }
        else
        {
            _S1540 = false;
        }
        TreeSample _S1541 = TreeSample_x24init_0(_S1271, _S1271, 0.0f, 0U);
        uint2  _S1542 = make_uint2 (0U);
        float2  _S1543 = make_float2 (0.0f);
        FKHit _S1544 = Hit_x24init_0(_S1543, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1545 = _S1544;
        ShadowContext _S1546 = ShadowContext_x24init_0(_S1271, _S1271, _S1542, _S1271, 0U, 0U, false, 0.0f, 0.0f, &_S1545, false);
        ShadowContext context_5;
        if(nee_0)
        {
            uint _S1547 = arrivalLobe_0(b_8, (&prev_0)->lobe);
            FKMedium _S1548 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1549 = surface_12;
            FKHit _S1550 = hit_4;
            FKMedium _S1551 = _S1548;
            ShadowContext _S1552 = shadowContext_0(&_S1549, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_8, _S1547, (&hit_4)->distance, width_3, &_S1550, _S1491, &_S1551);
            context_5 = _S1552;
        }
        else
        {
            context_5 = _S1546;
        }
        float3  throughput_7;
        float3  lit_0;
        if(_S1540)
        {
            float3  _S1553 = (&ray_2)->origin;
            if(_S1491)
            {
                throughput_7 = _S1271;
            }
            else
            {
                throughput_7 = _S1460.smooth_n;
            }
            FKSurface _S1554 = surface_12;
            uint _S1555 = stream(_S1299, b_8 + 64U);
            ShadowContext _S1556 = context_5;
            TreeSample _S1557 = sampleLightTree_0(_S1553, throughput_7, surface_12.geometry_n, surface_12.geometry_offset, _S1496, _S1555, &_S1556);
            bool _S1558 = any_1((_S1557.radiance) != _S1271);
            if(_S1558)
            {
                if(_S1491)
                {
                    uint _S1559 = (fcptMaxBounces());
                    bool _S1560 = b_8 < _S1559;
                    FKSurface _S1561 = surface_12;
                    TreeSample _S1562 = _S1557;
                    float3  _S1563 = hairLight_0(&_S1561, (&ray_2)->unit_direction, &_S1562, _S1560);
                    lit_0 = _S1563;
                }
                else
                {
                    float _S1564 = _S1486.x;
                    float _S1565 = _S1486.y;
                    uint _S1566 = (fcptMaxBounces());
                    bool _S1567 = b_8 < _S1566;
                    TreeSample _S1568 = _S1557;
                    BSDFMaterial _S1569 = _S1484;
                    float3  _S1570 = lightBSDF_0((&ray_2)->unit_direction, &_S1568, _S1460.smooth_n, _S1554.geometry_n, &_S1569, _S1564, _S1565, _S1567, surface_12.random_state);
                    lit_0 = _S1570;
                }
            }
            else
            {
                lit_0 = _S1271;
            }
            light_3 = _S1557;
        }
        else
        {
            light_3 = _S1541;
            lit_0 = _S1271;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1571;
        bool _S1572;
        float density_4;
        if(_S1526)
        {
            bool _S1573 = !_S1459;
            if(_S1573)
            {
                return _S1272;
            }
            uint _S1574 = extractBits_0(_S1273, 23U, 1U);
            bool _S1575 = _S1483 != (_S1574 == 1U);
            if(_S1575)
            {
                return _S1272;
            }
            float3  throughput_8 = throughput_6 * make_float3 (geometry_density_2);
            float density_5 = density_2 * geometry_density_2;
            if(_S1534)
            {
                viewed_1 = _S1277 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                float3  _S1576 = pathColor(throughput_8 * emission_1, spectral_weight_0, wavelength_6);
                return Shift_x24init_0(_S1576 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1534)
            {
                refracted_4 = _S1277 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S1577 = !nee_0;
                if(_S1577)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1578 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1578 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1272;
                }
                float3  _S1579 = pathColor(throughput_8 * lit_0, spectral_weight_0, wavelength_6);
                return Shift_x24init_0(_S1579 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1534)
            {
                wrong_side_0 = _S1277 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1580 = !nee_0;
                if(_S1580)
                {
                    return _S1272;
                }
                bool _S1581 = (fcptWorldReadsPath());
                if(_S1581)
                {
                    float _S1582 = environmentPdf_0(r_8->dir);
                    uint _S1583 = b_8 + 1U;
                    FKSurface _S1584 = surface_12;
                    float3  _S1585 = skyColor_0((&ray_2)->unit_direction, r_8->dir, &_S1584, _S1486, is_inside_7, _S1582, surface_12.random_state, _S1583);
                    float3  _S1586 = pathColor(throughput_8 * (_S1585 * r_8->radiance), spectral_weight_0, wavelength_6);
                    return Shift_x24init_0(_S1586 / make_float3 (r_8->jac), density_5 / r_8->jac);
                }
                float _S1587 = environmentPdf_0(r_8->dir);
                float3  _S1588 = skyBSDF((&ray_2)->unit_direction, r_8->dir, surface_12, _S1486, is_inside_7, _S1587, surface_12.random_state);
                float3  _S1589 = pathColor(throughput_8 * _S1588 * r_8->radiance, spectral_weight_0, wavelength_6);
                return Shift_x24init_0(_S1589 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            uint _S1590 = extractBits_0(_S1273, 21U, 1U);
            bool _S1591 = nee_0 != (_S1590 == 1U);
            if(_S1591)
            {
                return _S1272;
            }
            throughput_7 = throughput_8;
            density_4 = density_5;
        }
        else
        {
            if(replay_2)
            {
                viewed_1 = _S1527;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1592 = !scatter_2;
                if(_S1592)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1593 = _S1276 != 1U;
                    if(_S1593)
                    {
                        refracted_4 = _S1276 != 3U;
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
                bool _S1594 = _S1276 == 2U;
                if(_S1594)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1459;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1277 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1491)
                    {
                        return _S1272;
                    }
                    uint _S1595 = stream(_S1299, b_8 + 448U);
                    FKRay _S1596 = ray_2;
                    FKSurface _S1597 = surface_12;
                    ShadowContext _S1598 = context_5;
                    SkySample _S1599 = sampleSky_0(&_S1596, &_S1597, _S1486, is_inside_7, _S1595, surface_12.random_state, &_S1598);
                    float3  _S1600 = pathColor(throughput_6 * _S1599.color, spectral_weight_0, wavelength_6);
                    return Shift_x24init_0(_S1600, 1.0f);
                }
                if(_S1594)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1459;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1601 = rgb_to_greyscale(light_3.radiance);
                    bool _S1602 = !(_S1601 > 0.0f);
                    if(_S1602)
                    {
                        return _S1272;
                    }
                    float3  _S1603 = pathColor(throughput_6 * lit_0, spectral_weight_0, wavelength_6);
                    return Shift_x24init_0(_S1603, 1.0f);
                }
                if(_S1286)
                {
                    passes_0 = _S1277 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1422;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float3  _S1604 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_6);
                    return Shift_x24init_0(_S1604, 1.0f);
                }
                if(_S1286)
                {
                    passes_0 = _S1277 == 1U;
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
                    passes_0 = !_S1459;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float3  _S1605 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_6);
                    return Shift_x24init_0(_S1605, 1.0f);
                }
                return _S1272;
            }
            else
            {
                bool _S1606 = !replay_2;
                if(_S1606)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1607 = b_8 > 0U;
                    if(_S1607)
                    {
                        Reservoir candidate_5 = chain_0;
                        if(_S1514)
                        {
                            float3  _S1608 = safeDivide(throughput_6 * emission_1, chain_throughput_0);
                            (&candidate_5)->radiance = _S1608;
                        }
                        else
                        {
                            if(_S1459)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1609 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_6);
                        Reservoir _S1610 = withEnd(candidate_5, 1U, b_8, _S1609);
                        offer(sel_7, _S1610, _S1609 * make_float3 (scale_4) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1611 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_6);
                        float3  _S1612 = sel_7->glow + _S1611;
                        sel_7->glow = _S1612;
                    }
                    if(nee_0)
                    {
                        float3  _S1613 = pathColor(throughput_6 * lit_0, spectral_weight_0, wavelength_6);
                        Reservoir candidate_6 = chain_0;
                        if(_S1514)
                        {
                            float3  _S1614 = safeDivide(_S1613, chain_throughput_0);
                            (&candidate_6)->radiance = _S1614;
                        }
                        else
                        {
                            if(_S1459)
                            {
                                candidate_6 = here_0;
                                uint _S1615 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1615;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1616 = insertBits_0(_S1301, b_8 + 1U, 5U, 5U);
                                uint _S1617 = insertBits_0(_S1616, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1617;
                            }
                        }
                        Reservoir _S1618 = withEnd(candidate_6, 0U, b_8, _S1613);
                        offer(sel_7, _S1618, _S1613 * make_float3 (scale_4) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1491)
                        {
                            _S1571 = false;
                        }
                        else
                        {
                            bool _S1619 = environmentMapped_0();
                            _S1571 = _S1619;
                        }
                    }
                    else
                    {
                        _S1571 = false;
                    }
                    if(_S1571)
                    {
                        uint _S1620 = (fcptMaxBounces());
                        _S1572 = b_8 < _S1620;
                    }
                    else
                    {
                        _S1572 = false;
                    }
                    if(_S1572)
                    {
                        uint _S1621 = stream(_S1299, b_8 + 448U);
                        FKRay _S1622 = ray_2;
                        FKSurface _S1623 = surface_12;
                        ShadowContext _S1624 = context_5;
                        SkySample _S1625 = sampleSky_0(&_S1622, &_S1623, _S1486, is_inside_7, _S1621, surface_12.random_state, &_S1624);
                        float3  _S1626 = pathColor(throughput_6 * _S1625.color, spectral_weight_0, wavelength_6);
                        Reservoir candidate_7 = chain_0;
                        if(_S1514)
                        {
                            float3  _S1627 = safeDivide(_S1626, chain_throughput_0);
                            (&candidate_7)->radiance = _S1627;
                        }
                        else
                        {
                            if(_S1459)
                            {
                                candidate_7 = here_0;
                                uint _S1628 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1628;
                                (&candidate_7)->dir = _S1625.dir;
                                (&candidate_7)->radiance = _S1625.radiance;
                            }
                            else
                            {
                                uint _S1629 = insertBits_0(_S1301, b_8 + 1U, 5U, 5U);
                                uint _S1630 = insertBits_0(_S1629, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1630;
                            }
                        }
                        Reservoir _S1631 = withEnd(candidate_7, 4U, b_8, _S1626);
                        offer(sel_7, _S1631, _S1626 * make_float3 (scale_4) / make_float3 (density_2));
                    }
                }
            }
            throughput_7 = throughput_6;
            density_4 = density_2;
        }
        bool _S1632;
        bool _S1633;
        bool _S1634;
        bool straight_0;
        bool _S1635;
        bool _S1636;
        bool _S1637;
        bool _S1638;
        bool _S1639;
        bool _S1640;
        bool _S1641;
        bool _S1642;
        bool _S1643;
        bool _S1644;
        bool _S1645;
        bool _S1646;
        float density_6;
        float sky_pdf_2;
        float spread_5;
        uint b_11;
        float3  throughput_9;
        float3  throughput_10;
        float3  throughput_11;
        if(scatter_2)
        {
            MaterialTerms _S1647 = MaterialTerms_x24init_0(0.0f, 0.0f, 0.0f, 0.0f, 0.0f, _S1271, 0.0f, 0.0f, 0.0f, false, 0.0f);
            AnisotropicFrame _S1648 = AnisotropicFrame_x24init_0(_S1271, _S1543);
            ViewTerms _S1649 = ViewTerms_x24init_0(_S1271, _S1271, &_S1648, _S1271, 0.0f, _S1271, _S1271, _S1271, 0.0f, _S1271);
            bool _S1650 = !_S1491;
            MaterialTerms terms_7;
            ViewTerms view_terms_6;
            if(_S1650)
            {
                MaterialTerms terms_8 = precomputeMaterial(_S1484, _S1486.x, _S1486.y);
                ViewTerms _S1651 = precomputeView((&ray_2)->unit_direction, _S1460.smooth_n, _S1484, terms_8);
                terms_7 = terms_8;
                view_terms_6 = _S1651;
            }
            else
            {
                terms_7 = _S1647;
                view_terms_6 = _S1649;
            }
            if(replay_2)
            {
                viewed_1 = _S1527;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1652 = extractBits_0(_S1273, 15U, 3U);
            uint _S1653 = extractBits_0(_S1273, 18U, 3U);
            uint _S1654 = _slang_select(_S1526, _S1653,_S1652);
            float3  _S1655 = r_8->dir;
            bool refracted_5 = _S1654 == 1U;
            SampleBSDF _S1656 = SampleBSDF_x24init_0(_S1271, _S1271, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_8 = _S1656;
            float3  reconnection_1;
            SampleBSDF _S1657;
            if(viewed_1)
            {
                uint _S1658 = extractBits_0(_S1273, 22U, 1U);
                bool _S1659 = is_inside_7 != (_S1658 == 1U);
                if(_S1659)
                {
                    return _S1272;
                }
                bool _S1660 = _S1276 == 1U;
                if(_S1660)
                {
                    float3  _S1661 = (fcptHitPosition((_S1288)));
                    throughput_9 = _S1661;
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
                    BSDFMaterial _S1662 = _S1484;
                    bool _S1663 = isTranslucent_0(&_S1662);
                    if(_S1663)
                    {
                        refracted_4 = _S1654 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1664 = throughput_9 - (&ray_2)->origin;
                        float3  _S1665 = _slang_select(_S1660, _S1664,_S1655);
                        wrong_side_0 = (dot_0(_S1460.smooth_n, _S1665) * _S1461) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1660)
                {
                    float3  _S1666 = (&ray_2)->origin;
                    FKSurface _S1667 = surface_12;
                    float3  _S1668 = - _S1460.smooth_n;
                    bool _S1669 = is_inside_7 != refracted_4;
                    float3  _S1670 = _slang_select(_S1669, _S1668,_S1460.smooth_n);
                    float3  _S1671 = throughput_9 - (_S1666 + make_float3 (_S1667.geometry_offset) * _S1670);
                    float3  _S1672 = ((((_S1671)) * make_float3(rnorm3df(((_S1671)).x, ((_S1671)).y, ((_S1671)).z))));
                    reconnection_1 = _S1672;
                }
                else
                {
                    reconnection_1 = _S1655;
                }
                if(_S1491)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1673 = wrongSide_0(is_inside_7, refracted_4, reconnection_1, surface_12.geometry_n);
                    wrong_side_0 = _S1673;
                }
                if(wrong_side_0)
                {
                    return _S1272;
                }
                float3  _S1674 = throughput_9;
                throughput_9 = reconnection_1;
                b_11 = _S1654;
                wrong_side_0 = false;
                reconnection_1 = _S1674;
            }
            else
            {
                bool _S1675 = !_S1526;
                if(_S1675)
                {
                    SampleBSDF bsdf_sampled_0;
                    if(_S1491)
                    {
                        SampleBSDF _S1676 = (fcptSampleHair((surface_12.hair), (_S1484.albedo), (_S1484.specular_tint), ((&ray_2)->unit_direction), (surface_12.random_state)));
                        _S1657 = _S1676;
                    }
                    else
                    {
                        SampleBSDF _S1677 = sampleBSDF((&ray_2)->unit_direction, _S1460.smooth_n, _S1484, _S1486.x, _S1486.y, surface_12.random_state, _S1543, terms_7, view_terms_6);
                        _S1657 = _S1677;
                    }
                    bsdf_sampled_0 = _S1657;
                    if(_S1491)
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
                            return _S1272;
                        }
                        break;
                    }
                    if(_S1491)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1678 = wrongSide_0(is_inside_7, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_12.geometry_n);
                        wrong_side_0 = _S1678;
                    }
                    if(wrong_side_0)
                    {
                        _S1571 = (_S1484.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1571 = false;
                    }
                    if(_S1571)
                    {
                        float _S1679 = _S1486.x;
                        float _S1680 = _S1486.y;
                        ViewTerms _S1681 = precomputeView((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S1484, terms_7);
                        SampleBSDF _S1682 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S1484, _S1679, _S1680, (&bsdf_sampled_0)->random_state, _S1543, terms_7, _S1681);
                        (&bsdf_sampled_0)->unit_direction = _S1682.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1682.refracted;
                        (&bsdf_sampled_0)->throughput = _S1682.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1683 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n)) * surface_12.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1683;
                        }
                    }
                    uint _S1684 = (&bsdf_sampled_0)->lobe;
                    float3  _S1685 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1686 = (&bsdf_sampled_0)->refracted;
                    lobe_8 = bsdf_sampled_0;
                    float _S1687 = (&bsdf_sampled_0)->pdf;
                    float _S1688 = _slang_select(wrong_side_0, 0.0f,_S1687);
                    (&lobe_8)->pdf = _S1688;
                    throughput_9 = _S1685;
                    b_11 = _S1684;
                    refracted_4 = _S1686;
                }
                else
                {
                    throughput_9 = _S1655;
                    b_11 = _S1654;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1571 = true;
            }
            else
            {
                _S1571 = _S1526;
            }
            if(_S1571)
            {
                if(_S1491)
                {
                    SampleBSDF _S1689 = (fcptConnectHair((surface_12.hair), (_S1484.albedo), (_S1484.specular_tint), ((&ray_2)->unit_direction), (throughput_9)));
                    _S1657 = _S1689;
                }
                else
                {
                    SampleBSDF _S1690 = lobeBSDF((&ray_2)->unit_direction, throughput_9, _S1460.smooth_n, _S1484, _S1486.x, _S1486.y, b_11, surface_12.random_state, terms_7, view_terms_6);
                    _S1657 = _S1690;
                }
                lobe_8 = _S1657;
            }
            bool _S1691 = b_11 == 0U;
            if(_S1691)
            {
                _S1572 = true;
            }
            else
            {
                _S1572 = b_11 == 4U;
            }
            if(_S1572)
            {
                _S1632 = true;
            }
            else
            {
                _S1632 = b_11 == 6U;
            }
            if(_S1491)
            {
                _S1633 = false;
            }
            else
            {
                bool _S1692 = !_S1632;
                if(_S1692)
                {
                    bool _S1693 = (_S1484.roughness) == 0.0f;
                    if(_S1693)
                    {
                        _S1633 = true;
                    }
                    else
                    {
                        bool _S1694 = b_11 == 1U;
                        if(_S1694)
                        {
                            _S1633 = (_S1486.x) == (_S1486.y);
                        }
                        else
                        {
                            _S1633 = false;
                        }
                    }
                }
                else
                {
                    _S1633 = false;
                }
            }
            if(_S1650)
            {
                _S1634 = b_11 == 1U;
            }
            else
            {
                _S1634 = false;
            }
            if(_S1634)
            {
                straight_0 = (_S1484.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1635 = _S1650;
            }
            else
            {
                _S1635 = false;
            }
            if(_S1635)
            {
                _S1636 = b_11 == 1U;
            }
            else
            {
                _S1636 = false;
            }
            if(_S1636)
            {
                _S1637 = (_S1486.x) == (_S1486.y);
            }
            else
            {
                _S1637 = false;
            }
            BSDFMaterial _S1695 = _S1484;
            bool _S1696 = isTranslucent_0(&_S1695);
            if(_S1696)
            {
                _S1638 = _S1691;
            }
            else
            {
                _S1638 = false;
            }
            if(_S1638)
            {
                _S1639 = (dot_0(throughput_9, surface_12.geometry_n)) < 0.0f;
            }
            else
            {
                _S1639 = false;
            }
            if(nee_0)
            {
                _S1640 = !_S1633;
            }
            else
            {
                _S1640 = false;
            }
            if(_S1640)
            {
                _S1641 = !wrong_side_0;
            }
            else
            {
                _S1641 = false;
            }
            if(_S1641)
            {
                float _S1697 = (&lobe_8)->pdf;
                float3  _S1698 = (&ray_2)->origin;
                float3  _S1699 = _slang_select(_S1496, _S1271,_S1460.smooth_n);
                float3  _S1700 = (&ray_2)->origin;
                FKSurface _S1701 = surface_12;
                float3  _S1702 = - _S1460.smooth_n;
                float3  _S1703 = _slang_select(_S1639, _S1702,_S1460.smooth_n);
                NEEVertex _S1704 = NEEVertex_x24init_0(false, _S1697, _S1698, _S1699, _S1700 + make_float3 (_S1701.geometry_offset) * _S1703);
                nee_vertex_0 = _S1704;
            }
            else
            {
                if(_S1491)
                {
                    _S1642 = true;
                }
                else
                {
                    bool _S1705 = b_11 != 1U;
                    if(_S1705)
                    {
                        _S1642 = true;
                    }
                    else
                    {
                        _S1642 = (_S1486.x) != (_S1486.y);
                    }
                }
                if(_S1642)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1706 = withinInverseFootprint((&lobe_8)->pdf, _S1632, (&prev_0)->cos, (&hit_4)->distance, threshold_2);
            bool _S1707 = roughLobe((&lobe_8)->pdf, _S1632, _S1484.roughness);
            if(_S1526)
            {
                bool _S1708 = !_S1706;
                if(_S1708)
                {
                    return _S1272;
                }
                bool _S1709 = _S1277 != 1U;
                if(_S1709)
                {
                    _S1642 = _S1277 != 2U;
                }
                else
                {
                    _S1642 = false;
                }
                if(_S1642)
                {
                    float _S1710 = (&lobe_8)->pdf;
                    float _S1711 = _slang_select(nee_0, _S1710,0.0f);
                    float _S1712 = escapeWeight_0(_S1711, _S1655);
                    if(_S1534)
                    {
                        passes_0 = _S1283;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1713 = _slang_select(passes_0, _S1712,1.0f);
                    return Shift_x24init_0(throughput_7 * ((&lobe_8)->throughput * make_float3 ((&lobe_8)->pdf)) * r_8->radiance * make_float3 (_S1713) / make_float3 (r_8->jac), density_4 * (&lobe_8)->pdf / r_8->jac);
                }
                float3  _S1714 = throughput_7 * make_float3 ((&lobe_8)->pdf);
                float _S1715 = density_4 * (&lobe_8)->pdf;
                throughput_10 = _S1714;
                density_6 = _S1715;
            }
            else
            {
                throughput_10 = throughput_7;
                density_6 = density_4;
            }
            uint _S1716 = (fcptLayers((hit_4)));
            bool _S1717 = b_11 == 1U;
            bool _S1718 = passesLayer_0(_S1716, _S1717, passes_0);
            if(viewed_1)
            {
                _S1642 = _S1718;
            }
            else
            {
                _S1642 = false;
            }
            if(_S1642)
            {
                return _S1272;
            }
            if(replay_2)
            {
                _S1643 = b_8 <= _S1287;
            }
            else
            {
                _S1643 = false;
            }
            if(_S1643)
            {
                _S1644 = _S1459;
            }
            else
            {
                _S1644 = false;
            }
            if(_S1644)
            {
                _S1645 = _S1706;
            }
            else
            {
                _S1645 = false;
            }
            if(_S1645)
            {
                _S1646 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1646 = !_S1707;
                }
                else
                {
                    _S1646 = false;
                }
            }
            if(_S1646)
            {
                return _S1272;
            }
            if(viewed_1)
            {
                float3  _S1719 = throughput_10 * ((&lobe_8)->throughput * make_float3 ((&lobe_8)->pdf));
                float _S1720 = (&lobe_8)->pdf;
                throughput_11 = _S1719;
                sky_pdf_2 = _S1720;
            }
            else
            {
                float3  _S1721 = throughput_10 * max_0((&lobe_8)->throughput, _S1271);
                throughput_11 = _S1721;
                sky_pdf_2 = density_6;
            }
            bool _S1722 = !replay_2;
            bool _S1723;
            if(_S1722)
            {
                _S1723 = !_S1514;
            }
            else
            {
                _S1723 = false;
            }
            bool _S1724;
            if(_S1723)
            {
                _S1724 = _S1459;
            }
            else
            {
                _S1724 = false;
            }
            bool _S1725;
            if(_S1724)
            {
                _S1725 = _S1706;
            }
            else
            {
                _S1725 = false;
            }
            float3  chain_throughput_1;
            if(_S1725)
            {
                chain_0 = here_0;
                uint _S1726 = insertBits_0((&chain_0)->path, b_11, 18U, 3U);
                uint _S1727 = _slang_select(nee_0, 1U,0U);
                uint _S1728 = insertBits_0(_S1726, _S1727, 21U, 1U);
                (&chain_0)->path = _S1728;
                float _S1729 = (&chain_0)->jac * (&lobe_8)->pdf;
                (&chain_0)->jac = _S1729;
                (&chain_0)->dir = throughput_9;
                chain_throughput_1 = throughput_11;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1730 = surface_12;
            Vertex _S1731 = Vertex_x24init_0(_S1707, b_11, (&lobe_8)->pdf, (F32_abs((dot_0(surface_12.geometry_n, throughput_9)))), is_inside_7);
            prev_0 = _S1731;
            float _S1732 = (&lobe_8)->pdf;
            bool _S1733;
            if(_S1717)
            {
                _S1733 = (_S1486.x) == (_S1486.y);
            }
            else
            {
                _S1733 = false;
            }
            float sky_pdf_3 = _slang_select(_S1733, sky_pdf_0,_S1732);
            float _S1734 = _slang_select(_S1491, 0.0f,sky_pdf_3);
            float _S1735 = widened_0(spread_2, (&lobe_8)->pdf, _S1633);
            bool _S1736;
            if(refracted_4)
            {
                _S1736 = !_S1639;
            }
            else
            {
                _S1736 = false;
            }
            bool is_inside_8;
            if(_S1736)
            {
                bool _S1737 = !is_inside_7;
                is_inside_8 = _S1737;
            }
            else
            {
                is_inside_8 = is_inside_7;
            }
            FKSurface _S1738 = surface_12;
            bool _S1739 = boundsVolume_0(&_S1738);
            bool _S1740;
            if(_S1739)
            {
                _S1740 = !_S1718;
            }
            else
            {
                _S1740 = false;
            }
            if(_S1740)
            {
                FKSurface faced_2 = surface_12;
                float3  _S1741 = - _S1730.geometry_n;
                float3  _S1742 = _slang_select(turned_1, _S1741,_S1730.geometry_n);
                (&faced_2)->geometry_n = _S1742;
                FKMedium _S1743 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1744 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1745 = faced_2;
                FKMedium _S1746 = _S1743;
                FKMedium _S1747 = _S1744;
                MediumSides _S1748 = mediumSides_0(&_S1745, &_S1746, filling_2, (&ray_2)->unit_direction, &_S1747);
                bool _S1749 = leavesInFront_0((&faced_2)->geometry_n, throughput_9, _S1730.geometry_n);
                float3  _S1750 = _slang_select(_S1749, _S1748.front.scatter,_S1748.behind.scatter);
                scatter_in_0 = _S1750;
                float3  _S1751 = scatter_in_0;
                float _S1752 = upsample(scatter_in_0, wavelength_6);
                float3  _S1753 = make_float3 (_S1752);
                float3  _S1754 = _slang_select(_S1483, _S1753,_S1751);
                scatter_in_0 = _S1754;
                float3  _S1755 = _slang_select(_S1749, _S1748.front.extinction,_S1748.behind.extinction);
                extinction_in_0 = _S1755;
                float3  _S1756 = extinction_in_0;
                float _S1757 = upsample(extinction_in_0, wavelength_6);
                float3  _S1758 = make_float3 (_S1757);
                float3  _S1759 = _slang_select(_S1483, _S1758,_S1756);
                extinction_in_0 = _S1759;
                float _S1760 = _slang_select(_S1749, _S1748.front.g,_S1748.behind.g);
                g_in_0 = _S1760;
                uint _S1761 = _S1748.fillings.x;
                uint _S1762 = _S1748.fillings.y;
                uint _S1763 = _slang_select(_S1749, _S1762,_S1761);
                bool _S1764 = (fcptVaryingUsed());
                uint _S1765 = _slang_select(_S1764, _S1763,4294967295U);
                filling_2 = _S1765;
            }
            (&ray_2)->unit_direction = throughput_9;
            bool _S1766 = !_S1718;
            if(_S1766)
            {
                FKSurface _S1767 = surface_12;
                float _S1768 = _slang_select(straight_0, 0.0f,_S1767.geometry_offset);
                float3  _S1769 = - _S1460.smooth_n;
                bool _S1770 = is_inside_8 != _S1639;
                float3  _S1771 = _slang_select(_S1770, _S1769,_S1460.smooth_n);
                float3  _S1772 = (&ray_2)->origin + make_float3 (_S1768) * _S1771;
                (&ray_2)->origin = _S1772;
            }
            throughput_10 = throughput_11;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1718;
            viewed_1 = _S1637;
            sky_pdf_2 = _S1734;
            spread_5 = _S1735;
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
        bool _S1773 = !replay_2;
        float density_7;
        if(_S1773)
        {
            if(_S1422)
            {
                float3  _S1774 = pathColor(throughput_10 * emission_1, spectral_weight_0, wavelength_6);
                Reservoir candidate_8 = chain_0;
                uint _S1775 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1776 = _S1775 == 1U;
                if(_S1776)
                {
                    float3  _S1777 = safeDivide(_S1774, chain_throughput_0);
                    (&candidate_8)->radiance = _S1777;
                }
                Reservoir _S1778 = withEnd(candidate_8, 2U, b_8, _S1774);
                offer(sel_7, _S1778, _S1774 * make_float3 (scale_4) / make_float3 (density_6));
            }
            if(_S1422)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1779 = survivalProbability(abs_0(throughput_10), density_6);
                density_7 = _S1779;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1780 = stream(_S1299, b_8 + 128U);
            Random _S1781 = pcg(_S1780);
            bool _S1782 = density_7 < (_S1781.value);
            if(_S1782)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1783 = (fcptMaxBounces());
                wrong_side_0 = b_8 >= _S1783;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1784 = density_6 * density_7;
            density_7 = _S1784;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1785 = layer_0 ^ 1U;
        uint _S1786 = _slang_select(passes_0, _S1785,0U);
        if(passes_0)
        {
            (&prev_0)->rough = false;
            (&hit_4)->distance = 0.0f;
            b_11 = b_8;
            viewed_0 = viewed_1;
            throughput_2 = throughput_10;
            density_2 = density_7;
            sky_pdf_0 = sky_pdf_2;
            spread_2 = spread_5;
            uint _S1787 = b_11 + 1U;
            b_8 = _S1787;
            layer_0 = _S1786;
            continue;
        }
        FKRay _S1788 = ray_2;
        float _S1789 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_2)
        {
            refracted_4 = _S1527;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S1276 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1790 = _slang_select(wrong_side_0, _S1789,4.294967296e+09f);
        bool _S1791 = !_S1491;
        if(straight_0)
        {
            _S1571 = true;
        }
        else
        {
            _S1571 = _S1491;
        }
        FKHit _S1792;
        if(_S1571)
        {
            _S1792 = hit_4;
        }
        else
        {
            _S1792 = _S1544;
        }
        FKHit _S1793 = (fcptTraverseInstanceBVH((_S1788), (_S1430), (_S1790), (_S1791), (_S1792), (viewed_1)));
        hit_4 = _S1793;
        if(replay_2)
        {
            _S1572 = _S1527;
        }
        else
        {
            _S1572 = false;
        }
        if(_S1572)
        {
            _S1632 = _S1276 == 1U;
        }
        else
        {
            _S1632 = false;
        }
        if(_S1632)
        {
            _S1633 = ((&hit_4)->instance_index) == (_S1288.instance_index);
        }
        else
        {
            _S1633 = false;
        }
        if(_S1633)
        {
            _S1634 = ((&hit_4)->triangle_index) == (_S1288.triangle_index);
        }
        else
        {
            _S1634 = false;
        }
        if(_S1634)
        {
            (&hit_4)->uv = _S1288.uv;
            float _S1794 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S1794;
        }
        if(replay_2)
        {
            _S1635 = _S1527;
        }
        else
        {
            _S1635 = false;
        }
        if(_S1635)
        {
            _S1636 = _S1276 == 3U;
        }
        else
        {
            _S1636 = false;
        }
        if(_S1636)
        {
            _S1637 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1637 = false;
        }
        if(_S1637)
        {
            return _S1272;
        }
        Reservoir _S1795 = chain_0;
        uint _S1796 = filling_2;
        for(;;)
        {
            bool _S1797 = (fcptVaryingUsed());
            if(_S1797)
            {
                _S1638 = _S1796 != 4294967295U;
            }
            else
            {
                _S1638 = false;
            }
            float _S1798;
            if(_S1638)
            {
                float _S1799 = (fcptMajorant((_S1796)));
                _S1798 = _S1799;
            }
            else
            {
                _S1798 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_2)
            {
                _S1639 = _S1527;
            }
            else
            {
                _S1639 = false;
            }
            if(_S1639)
            {
                _S1640 = _S1276 == 1U;
            }
            else
            {
                _S1640 = false;
            }
            if(_S1640)
            {
                _S1641 = _S1798 > 0.0f;
            }
            else
            {
                _S1641 = false;
            }
            if(_S1641)
            {
                ended_0 = _S1272;
                sky_pdf_1 = sky_pdf_2;
                spread_3 = spread_5;
                width_4 = width_3;
                density_3 = density_7;
                throughput_11 = throughput_10;
                b_11 = b_8;
                _S1642 = true;
                break;
            }
            bool _S1800 = (&prev_0)->rough;
            if(_S1800)
            {
                _S1642 = !(_S1798 > 0.0f);
            }
            else
            {
                _S1642 = false;
            }
            (&prev_0)->rough = _S1642;
            uint _S1801 = b_8 + 320U;
            bool _S1802 = b_8 == 4294967295U;
            uint _S1803 = _slang_select(_S1802, 384U,_S1801);
            uint _S1804 = stream(_S1299, _S1803);
            uint tracking_1 = _S1804;
            weight_2 = throughput_3;
            glowed_0 = _S1271;
            b_11 = b_8;
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
                    _S1270 = int(2);
                    break;
                }
                uint _S1805 = b_11 + 320U;
                bool _S1806 = b_11 == 4294967295U;
                uint _S1807 = _slang_select(_S1806, 384U,_S1805);
                uint _S1808 = stream(_S1299, _S1807);
                Random _S1809 = pcg(_S1808);
                float _S1810 = freeFlight_0(_S1809.value, _S1798);
                if(_S1638)
                {
                    float3  _S1811 = (&ray_2)->origin;
                    float3  _S1812 = (&ray_2)->unit_direction;
                    float _S1813 = (&hit_4)->distance;
                    uint _S1814 = _slang_select(_S1806, 0U,b_11);
                    uint _S1815 = (&prev_0)->lobe;
                    uint _S1816 = _slang_select(_S1806, 3U,_S1815);
                    float _S1817 = (fcptTrackMedium((_S1796), (_S1811), (_S1812), (_S1813), (&tracking_1), (&weight_2), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1814), (_S1816), (_S1806)));
                    spread_4 = _S1817;
                }
                else
                {
                    spread_4 = _S1810;
                }
                bool _S1818 = !(spread_4 < ((&hit_4)->distance));
                if(_S1818)
                {
                    _S1270 = int(2);
                    break;
                }
                if(_S1638)
                {
                    _S1643 = _S1773;
                }
                else
                {
                    _S1643 = false;
                }
                if(_S1643)
                {
                    float3  _S1819 = pathColor(throughput_11 * glowed_0, spectral_weight_0, wavelength_6);
                    float3  _S1820 = _S1819 / make_float3 (density_3);
                    float3  _S1821 = sel_7->glow + _S1820;
                    sel_7->glow = _S1821;
                }
                else
                {
                }
                glowed_0 = _S1271;
                uint b_12 = b_11 + 1U;
                float3  _S1822 = (&ray_2)->origin + make_float3 (spread_4) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1822;
                float3  _S1823 = flightWeight_0(scatter_in_0, extinction_in_0, _S1798, spread_4, true);
                float3  _S1824 = weight_2;
                float _S1825 = upsample(weight_2, wavelength_6);
                float3  _S1826 = make_float3 (_S1825);
                float3  _S1827 = _slang_select(_S1483, _S1826,_S1824);
                float3  _S1828 = _slang_select(_S1638, _S1827,_S1823);
                float3  throughput_12 = throughput_11 * _S1828;
                uint _S1829 = stream(_S1299, b_12 + 320U);
                tracking_1 = _S1829;
                weight_2 = throughput_3;
                float width_7 = width_4 + spread_3 * spread_4;
                float _S1830 = spread_3 + 3.14159274101257324f;
                bool _S1831 = scatterSampled_0(replay_2, b_12, _S1287, _S1638);
                TreeSample light_4;
                if(_S1831)
                {
                    float3  _S1832 = (&ray_2)->origin;
                    float3  _S1833 = (&ray_2)->unit_direction;
                    float3  _S1834 = (&ray_2)->unit_direction;
                    uint _S1835 = stream(_S1299, b_12 + 64U);
                    float3  _S1836 = extinction_in_0;
                    float3  _S1837 = extinction_in_0;
                    uint2  _S1838 = make_uint2 (_S1796);
                    float3  _S1839 = (&ray_2)->unit_direction;
                    uint _S1840 = arrivalLobe_0(b_12, (&prev_0)->lobe);
                    FKHit _S1841 = _S1544;
                    ShadowContext _S1842 = ShadowContext_x24init_0(_S1836, _S1837, _S1838, _S1839, b_12, _S1840, false, spread_4, width_7, &_S1841, false);
                    ShadowContext _S1843 = _S1842;
                    TreeSample _S1844 = sampleLightTree_0(_S1832, _S1833, _S1834, 0.0f, true, _S1835, &_S1843);
                    light_4 = _S1844;
                }
                else
                {
                    light_4 = _S1541;
                }
                float _S1845 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1846 = (fcptMaxBounces());
                bool _S1847 = b_12 < _S1846;
                if(_S1847)
                {
                    _S1644 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1644 = false;
                }
                float _S1848 = _slang_select(_S1644, _S1845,0.0f);
                float3  _S1849 = throughput_12 * light_4.radiance;
                float _S1850 = powerHeuristic(light_4.density, _S1848);
                float3  _S1851 = pathColor(_S1849 * make_float3 (_S1845 * _S1850), spectral_weight_0, wavelength_6);
                float3  _S1852 = _slang_select(_S1831, _S1851,_S1271);
                if(replay_2)
                {
                    _S1645 = b_12 == _S1287;
                }
                else
                {
                    _S1645 = false;
                }
                if(_S1645)
                {
                    bool _S1853 = _S1276 == 2U;
                    if(_S1853)
                    {
                        float _S1854 = resamplingTarget(_S1852);
                        _S1646 = _S1854 > 0.0f;
                    }
                    else
                    {
                        _S1646 = false;
                    }
                    if(_S1646)
                    {
                        Shift _S1855 = Shift_x24init_0(_S1852, 1.0f);
                        _S1270 = int(1);
                        ended_0 = _S1855;
                        spread_4 = _S1830;
                        width_5 = width_7;
                        throughput_9 = throughput_12;
                        b_9 = b_12;
                        break;
                    }
                    _S1270 = int(1);
                    ended_0 = _S1272;
                    spread_4 = _S1830;
                    width_5 = width_7;
                    throughput_9 = throughput_12;
                    b_9 = b_12;
                    break;
                }
                if(_S1773)
                {
                    Reservoir candidate_9 = _S1795;
                    uint _S1856 = extractBits_0(_S1795.path, 24U, 8U);
                    uint _S1857 = insertBits_0(0U, _S1856, 24U, 8U);
                    uint _S1858 = extractBits_0(_S1795.path, 10U, 2U);
                    bool _S1859 = _S1858 == 1U;
                    if(_S1859)
                    {
                        float3  _S1860 = safeDivide(_S1852, chain_throughput_0);
                        (&candidate_9)->radiance = _S1860;
                    }
                    else
                    {
                        uint _S1861 = insertBits_0(_S1857, b_12 + 1U, 5U, 5U);
                        uint _S1862 = insertBits_0(_S1861, 2U, 10U, 2U);
                        (&candidate_9)->path = _S1862;
                    }
                    Reservoir _S1863 = withEnd(candidate_9, 0U, b_12, _S1852);
                    offer(sel_7, _S1863, _S1852 * make_float3 (scale_4) / make_float3 (density_3));
                    float _S1864 = survivalProbability(abs_0(throughput_12), density_3);
                    uint _S1865 = stream(_S1299, b_12 + 128U);
                    Random _S1866 = pcg(_S1865);
                    bool _S1867 = _S1864 < (_S1866.value);
                    if(_S1867)
                    {
                        _S1646 = true;
                    }
                    else
                    {
                        uint _S1868 = (fcptMaxBounces());
                        _S1646 = b_12 >= _S1868;
                    }
                    if(_S1646)
                    {
                        _S1270 = int(1);
                        ended_0 = _S1272;
                        spread_4 = _S1830;
                        width_5 = width_7;
                        throughput_9 = throughput_12;
                        b_9 = b_12;
                        break;
                    }
                    float _S1869 = density_3 * _S1864;
                    density_3 = _S1869;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1870 = stream(_S1299, b_12);
                float3  _S1871 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1870, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1871;
                NEEVertex _S1872 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1271, (&ray_2)->origin);
                nee_vertex_0 = _S1872;
                Vertex _S1873 = scatteredVertex_0(is_inside_6);
                prev_0 = _S1873;
                float _S1874 = (&prev_0)->pdf;
                FKRay _S1875 = ray_2;
                FKHit _S1876 = (fcptTraverseInstanceBVH((_S1875), (true), (4.294967296e+09f), (false), (_S1544), (false)));
                hit_4 = _S1876;
                b_11 = b_12;
                throughput_11 = throughput_12;
                spread_3 = _S1830;
                width_4 = width_7;
                sky_pdf_1 = _S1874;
            }
            if(_S1270 != int(2))
            {
                spread_3 = spread_4;
                width_4 = width_5;
                throughput_11 = throughput_9;
                b_11 = b_9;
                _S1642 = true;
                break;
            }
            ended_0 = _S1272;
            _S1642 = false;
            break;
        }
        if(_S1642)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1643 = b_11 == b_8;
        }
        else
        {
            _S1643 = false;
        }
        bool _S1877 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S1877)
        {
            bool _S1878 = !(&nee_vertex_0)->none;
            float _S1879 = _slang_select(_S1878, sky_pdf_1,0.0f);
            float _S1880 = escapeWeight_0(_S1879, (&ray_2)->unit_direction);
            float3  _S1881 = environment_0((&ray_2)->unit_direction, b_11, (&prev_0)->lobe);
            float3  _S1882 = pathColor(throughput_11 * _S1881, spectral_weight_0, wavelength_6);
            if(replay_2)
            {
                bool _S1883 = b_11 == _S1287;
                if(_S1883)
                {
                    passes_0 = _S1276 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1882 * make_float3 (_S1880) / make_float3 (r_8->jac), density_3 / r_8->jac);
                }
                if(_S1286)
                {
                    passes_0 = _S1283;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_11 == _S1274;
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
                    return Shift_x24init_0(_S1882 * make_float3 (_S1880), 1.0f);
                }
                return _S1272;
            }
            Reservoir candidate_10 = chain_0;
            uint _S1884 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1885 = _S1884 == 1U;
            if(_S1885)
            {
                uint _S1886 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1887 = _S1886 == b_11;
                float _S1888 = _slang_select(_S1887, 1.0f,_S1880);
                float3  _S1889 = safeDivide(_S1882 * make_float3 (_S1888), chain_throughput_0);
                (&candidate_10)->radiance = _S1889;
            }
            else
            {
                bool _S1890 = (&prev_0)->rough;
                if(_S1890)
                {
                    uint _S1891 = insertBits_0(_S1301, b_11 + 1U, 5U, 5U);
                    uint _S1892 = insertBits_0(_S1891, 3U, 10U, 2U);
                    uint _S1893 = insertBits_0(_S1892, (&prev_0)->lobe, 15U, 3U);
                    bool _S1894 = (&prev_0)->inside;
                    uint _S1895 = _slang_select(_S1894, 1U,0U);
                    uint _S1896 = insertBits_0(_S1893, _S1895, 22U, 1U);
                    (&candidate_10)->path = _S1896;
                    (&candidate_10)->jac = (&prev_0)->pdf;
                    (&candidate_10)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1897 = _S1882 * make_float3 (_S1880);
            Reservoir _S1898 = withEnd(candidate_10, 3U, b_11, _S1897);
            offer(sel_7, _S1898, _S1897 * make_float3 (scale_4) / make_float3 (density_3));
            break;
        }
        float3  _S1899 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1899;
        bool _S1900 = (fcptVaryingUsed());
        if(_S1900)
        {
            _S1644 = filling_2 != 4294967295U;
        }
        else
        {
            _S1644 = false;
        }
        if(_S1644)
        {
            if(_S1773)
            {
                float3  _S1901 = pathColor(throughput_11 * glowed_0, spectral_weight_0, wavelength_6);
                float3  _S1902 = _S1901 / make_float3 (density_3);
                float3  _S1903 = sel_7->glow + _S1902;
                sel_7->glow = _S1903;
            }
            float3  _S1904 = throughput_11 * weight_2;
            throughput_9 = _S1904;
        }
        else
        {
            float3  _S1905 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S1906 = throughput_11 * _S1905;
            throughput_9 = _S1906;
        }
        float _S1907 = width_4 + spread_3 * (&hit_4)->distance;
        viewed_0 = _S1643;
        width_3 = _S1907;
        throughput_2 = throughput_9;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_2 = spread_3;
        uint _S1787 = b_11 + 1U;
        b_8 = _S1787;
        layer_0 = _S1786;
    }
    return _S1272;
}

static __device__ Shift shift_0(Domain * dom_8, Reservoir * r_9)
{
    Selection _S1908 = (Selection{});
    Selection sel_8 = _S1908;
    bool _S1909 = (r_9->w) <= 0.0f;
    if(_S1909)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S1910 = walk_0(dom_8, r_9, true, 0.0f, &sel_8);
    return _S1910;
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
        *_slang_vector_get_element_ptr(&result_15, i_25) = (F32_tan((_slang_vector_get_element(x_27, i_25))));
        i_25 = i_25 + int(1);
    }
    return result_15;
}

static __device__ float3  acos_0(float3  x_28)
{
    float3  result_16;
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
        *_slang_vector_get_element_ptr(&result_16, i_26) = (F32_acos((_slang_vector_get_element(x_28, i_26))));
        i_26 = i_26 + int(1);
    }
    return result_16;
}

__device__ Random normal_distribution(uint state_3)
{
    Random _S1911 = pcg(state_3);
    Random _S1912 = pcg(_S1911.state);
    float _S1913 = 6.28318548202514648f * _S1911.value;
    float _S1914 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S1912.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1912.state, _S1914 * (F32_cos((_S1913))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_4, float3  value_2)
{
    RandomSphere _S1915;
    (&_S1915)->state = state_4;
    (&_S1915)->value = value_2;
    return _S1915;
}

__device__ RandomSphere random_sphere(uint state_5)
{
    Random _S1916 = normal_distribution(state_5);
    Random _S1917 = normal_distribution(_S1916.state);
    Random _S1918 = normal_distribution(_S1917.state);
    float3  _S1919 = make_float3 (_S1916.value, _S1917.value, _S1918.value);
    float3  _S1920 = ((((_S1919)) * make_float3(rnorm3df(((_S1919)).x, ((_S1919)).y, ((_S1919)).z))));
    return RandomSphere_x24init_0(_S1918.state, _S1920);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_15)
{
    float3  _S1921 = p1_0 - p0_0;
    float3  _S1922 = p2_0 - p0_0;
    float2  _S1923 = uv1_0 - uv0_0;
    float2  _S1924 = uv2_0 - uv0_0;
    float _S1925 = _S1923.x;
    float _S1926 = _S1924.y;
    float _S1927 = _S1923.y;
    float _S1928 = _S1924.x;
    float _S1929 = _S1925 * _S1926 - _S1927 * _S1928;
    float _S1930 = 1.0f / _S1929;
    float3  t_21 = (_S1921 * make_float3 (_S1926) - _S1922 * make_float3 (_S1927)) * make_float3 (_S1930);
    float3  _S1931 = (_S1922 * make_float3 (_S1925) - _S1921 * make_float3 (_S1928)) * make_float3 (_S1930);
    float3  _S1932 = t_21 - n_15 * make_float3 (dot_0(n_15, t_21));
    float3  t_22 = ((((_S1932)) * make_float3(rnorm3df(((_S1932)).x, ((_S1932)).y, ((_S1932)).z))));
    bool _S1933 = (dot_0(cross_0(n_15, t_22), _S1931)) > 0.0f;
    float3  t_23;
    if(_S1933)
    {
        float3  _S1934 = negate_0(t_22);
        t_23 = _S1934;
    }
    else
    {
        t_23 = t_22;
    }
    float3  _S1935 = cross_0(n_15, t_23);
    return makeMatrix<float, 3, 3> (t_23, _S1935, n_15);
}

__device__ float3  tangentToWorldNormalMap(float3  v_4, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_4, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_5, float3  uvw_0, float3  position_0)
{
    float3  _S1936 = t1_0 - t0_0;
    float3  _S1937 = t2_2 - t0_0;
    float3  _S1938 = t2_2 - t1_0;
    float _S1939 = (F32_min((length_0(_S1936)), ((F32_min((length_0(_S1937)), (length_0(_S1938)))))));
    float3  _S1940 = make_float3 (distance_1(position_0, t0_0), distance_1(position_0, t1_0), distance_1(position_0, t2_2));
    float3  _S1941 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1942 = dot_0(geometry_n_5, _S1941);
    float3  _S1943 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1944 = dot_0(geometry_n_5, _S1943);
    float3  _S1945 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1946 = acos_0(abs_0(make_float3 (_S1942, _S1944, dot_0(geometry_n_5, _S1945))));
    float3  _S1947 = clamp_2(tan_0(_S1946), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S1940 * _S1947, uvw_0), 0.0f, _S1939 * 0.125f);
}

__device__ float3  straightThrough(float3  dir_16, float3  n_16, BSDFMaterial material_21)
{
    float3  _S1948 = negate_0(dir_16);
    float _S1949 = sign_0(dot_0(n_16, _S1948));
    float3  _S1950 = n_16 * make_float3 (_S1949);
    AnisotropicFrame _S1951 = anisotropicFrame(material_21, _S1950);
    bool _S1952 = (_S1951.alphas.x) > 0.0f;
    if(_S1952)
    {
        float _S1953 = material_21.transmission * (1.0f - material_21.metallic);
        float3  _S1954 = negate_0(_S1950);
        float3  _S1955 = anisotropicLocal(dir_16, _S1951.tangent, _S1954);
        float _S1956 = anisotropicG1(_S1955, _S1951.alphas);
        return make_float3 (_S1953 * _S1956) * material_21.albedo;
    }
    float _S1957 = material_21.transmission * (1.0f - material_21.metallic);
    float _S1958 = material_21.roughness;
    float _S1959 = smithG1(_S1958 * _S1958, (F32_abs((dot_0(n_16, dir_16)))));
    return make_float3 (_S1957 * _S1959) * material_21.albedo;
}

__device__ float hairRow(float3  in_dir_12, float3  t_24, float3  out_dir_4, uint p_14, float w_2, float alpha_6, uint nt_0)
{
    uint _S1960 = p_14 % 4U;
    float _S1961 = w_2 * HAIR_WIDTHS_0[_S1960];
    float _S1962 = (F32_asin((clamp_1(dot_0(out_dir_4, t_24), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_12, t_24), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1960] * alpha_6;
    return ((F32_asinh((_S1962 / _S1961))) / (F32_asinh((3.14159274101257324f / _S1961))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_13, float3  t_25, float3  out_dir_5, uint np_0)
{
    float3  _S1963 = worldToTangent(out_dir_5, t_25);
    float3  _S1964 = worldToTangent(in_dir_13, t_25);
    return (F32_frac((((F32_atan2((_S1963.z), (_S1963.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1964.z), (1.17549435082228751e-38f - _S1964.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_14, float3  t_26, uint p_15, float row_0, float column_0, float w_3, float alpha_7, uint nt_1, uint np_1)
{
    float3  _S1965 = worldToTangent(in_dir_14, t_26);
    uint _S1966 = p_15 % 4U;
    float _S1967 = w_3 * HAIR_WIDTHS_0[_S1966];
    float _S1968 = (F32_asin((clamp_1(dot_0(in_dir_14, t_26), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1966] * alpha_7 + _S1967 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1967))))));
    float _S1969 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1965.z), (1.17549435082228751e-38f - _S1965.x)));
    float _S1970 = (F32_cos((_S1968)));
    float3  _S1971 = tangentToWorld(make_float3 (_S1970 * (F32_cos((_S1969))), (F32_sin((_S1968))), _S1970 * (F32_sin((_S1969)))), t_26);
    return _S1971;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_17, BSDFMaterial material_22, float coverage_1)
{
    float3  _S1972;
    if((material_22.ior) == 1.0f)
    {
        float3  _S1973 = straightThrough(toward_1, n_17, material_22);
        _S1972 = _S1973;
    }
    else
    {
        _S1972 = make_float3 (0.0f);
    }
    return _S1972 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_9, Reservoir r_10, bool replay_3, float scale_5, Selection * sel_9)
{
    Domain _S1974 = dom_9;
    Reservoir _S1975 = r_10;
    Shift _S1976 = walk_0(&_S1974, &_S1975, replay_3, scale_5, sel_9);
    return _S1976;
}

__device__ Shift shift_hook(Domain dom_10, Reservoir r_11)
{
    Domain _S1977 = dom_10;
    Reservoir _S1978 = r_11;
    Shift _S1979 = shift_0(&_S1977, &_S1978);
    return _S1979;
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
