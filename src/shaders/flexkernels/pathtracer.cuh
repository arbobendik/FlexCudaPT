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

struct Facets
{
    float3  h;
    float3  coat_h;
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
    float _S338;
    if(_S334 == 4294967295U)
    {
        Random _S339 = pcg(_S337.state);
        _S338 = _slang_select(_S335, _S339.value,_S337.value);
    }
    else
    {
        uint _S340 = _S334 & 65535U;
        uint _S341 = _S334 >> 16U;
        _S338 = (float(_slang_select(_S335, _S341,_S340)) + 0.5f) / 6.5536e+04f;
    }
    return Random_x24init_0(address_0, _S338);
}

__device__ static const FixedArray<float, 243>  SPECTRAL_PRIMARIES_0 = { {
    0.028201999142766f, 9.99999997475242708e-07f, 0.97179698944091797f, 0.02820000052452087f, 0.0f, 0.97180002927780151f, 0.02819300070405006f, 0.0f, 0.97180700302124023f, 0.0281750001013279f, 0.0f, 0.9718250036239624f, 0.02813299931585789f, 0.0f, 0.97186702489852905f, 0.02804199978709221f, 0.0f, 0.9719579815864563f, 0.02786399982869625f, 0.0f, 0.97213602066040039f, 0.0275299996137619f, 0.0f, 0.9724699854850769f, 0.02692800015211105f, 0.0f, 0.97307199239730835f, 0.02592499926686287f, 0.0f, 0.97407501935958862f, 0.02444599941372871f, 0.0f, 0.97555398941040039f, 0.02258899994194508f, 0.0f, 0.97741097211837769f, 0.02068600058555603f, 0.0f, 0.97931402921676636f, 0.01939599961042404f, 0.0f, 0.98060399293899536f, 0.01972600072622299f, 0.0f, 0.9802740216255188f, 0.02305700071156025f, 0.0f, 0.97694301605224609f, 0.0282990001142025f, 0.00548999989405274f, 0.96621102094650269f, 0.02276800014078617f, 0.04560500010848045f, 0.93162697553634644f, 0.0118180001154542f, 0.11352799832820892f, 0.87465399503707886f, 0.00192399998195469f, 0.20037899911403656f, 0.79769700765609741f, 0.0f, 0.29692500829696655f, 0.70307499170303345f, 0.0f, 0.40064999461174011f, 0.5993499755859375f, 0.0f, 0.50742298364639282f, 0.49257698655128479f, 0.0f, 0.61289197206497192f, 0.38710799813270569f, 0.0f, 0.71311402320861816f, 0.28688600659370422f, 0.0f, 0.8042140007019043f, 0.1957859992980957f, 0.0f, 0.88220900297164917f, 0.11779099702835083f, 0.0f, 0.94313102960586548f, 0.05686900019645691f, 0.0f, 0.98336499929428101f, 0.01663500070571899f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.99855601787567139f, 0.00144400005228817f, 0.0f, 0.97892600297927856f, 0.02107400074601173f, 0.03028500080108643f, 0.92923498153686523f, 0.04047999903559685f, 0.10447199642658234f, 0.84615302085876465f, 0.04937500134110451f, 0.21104000508785248f, 0.73897498846054077f, 0.04998499900102615f, 0.33820000290870667f, 0.61719298362731934f, 0.04460699856281281f, 0.47420701384544373f, 0.49019300937652588f, 0.03559999912977219f, 0.60847699642181396f, 0.3664110004901886f, 0.02511199936270714f, 0.73185497522354126f, 0.25317299365997314f, 0.01497200038284063f, 0.83687901496887207f, 0.15642799437046051f, 0.00669299997389317f, 0.91802400350570679f, 0.08053100109100342f, 0.00144499994348735f, 0.97194302082061768f, 0.02805699966847897f, 0.0f, 0.99879997968673706f, 0.00120000005699694f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.99999898672103882f, 0.0f, 9.99999997475242708e-07f, 0.99999898672103882f, 0.0f, 9.99999997475242708e-07f, 0.99999898672103882f, 0.0f, 9.99999997475242708e-07f, 0.99999797344207764f, 9.99999997475242708e-07f, 9.99999997475242708e-07f, 0.99999797344207764f, 9.99999997475242708e-07f, 9.99999997475242708e-07f, 0.99999701976776123f, 9.99999997475242708e-07f, 1.99999999495048542e-06f, 0.99999499320983887f, 1.99999999495048542e-06f, 3.00000010611256585e-06f, 0.99999302625656128f, 1.99999999495048542e-06f, 4.99999987368937582e-06f, 0.99998897314071655f, 3.99999998990097083e-06f, 7.00000009601353668e-06f, 0.9999840259552002f, 6.00000021222513169e-06f, 0.00000999999974738f, 0.99997901916503906f, 0.0000079999999798f, 0.00001299999985349f, 0.99997401237487793f, 0.00000999999974738f, 0.0000159999999596f, 0.99997299909591675f, 0.00001200000042445f, 0.00001499999962107f, 0.99996697902679443f, 0.00001499999962107f, 0.00001800000063668f, 0.9999690055847168f, 0.00001499999962107f, 0.0000159999999596f, 0.9999619722366333f, 0.00001700000029814f, 0.00002099999983329f
} };
__device__ float upsample(float3  rgb_0, float wavelength_0)
{
    float _S342 = clamp_1((wavelength_0 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    uint _S343 = (U32_min((uint(_S342)), (79U)));
    uint _S344 = 3U * _S343;
    float3  _S345 = make_float3 (SPECTRAL_PRIMARIES_0[_S344], SPECTRAL_PRIMARIES_0[_S344 + 1U], SPECTRAL_PRIMARIES_0[_S344 + 2U]);
    float3  _S346 = make_float3 (SPECTRAL_PRIMARIES_0[_S344 + 3U], SPECTRAL_PRIMARIES_0[_S344 + 4U], SPECTRAL_PRIMARIES_0[_S344 + 5U]);
    return dot_0(rgb_0, _S345 + (_S346 - _S345) * make_float3 (_S342 - float(_S343)));
}

__device__ BSDFMaterial atWavelength(BSDFMaterial material_0, float wavelength_1)
{
    BSDFMaterial at_0 = material_0;
    float _S347 = upsample(material_0.albedo, wavelength_1);
    float3  _S348 = make_float3 (_S347);
    (&at_0)->albedo = _S348;
    float _S349 = upsample(material_0.emissive, wavelength_1);
    float3  _S350 = make_float3 (_S349);
    (&at_0)->emissive = _S350;
    float _S351 = upsample(material_0.absorption, wavelength_1);
    float3  _S352 = make_float3 (_S351);
    (&at_0)->absorption = _S352;
    float _S353 = upsample(material_0.specular_tint, wavelength_1);
    float3  _S354 = make_float3 (_S353);
    (&at_0)->specular_tint = _S354;
    float _S355 = upsample(material_0.translucent, wavelength_1);
    float3  _S356 = make_float3 (_S355);
    (&at_0)->translucent = _S356;
    float _S357 = upsample(material_0.sheen, wavelength_1);
    float3  _S358 = make_float3 (_S357);
    (&at_0)->sheen = _S358;
    float _S359 = upsample(material_0.coat_tint, wavelength_1);
    float3  _S360 = make_float3 (_S359);
    (&at_0)->coat_tint = _S360;
    return at_0;
}

__device__ BSDFMaterial pathMaterial(BSDFMaterial material_1, float wavelength_2)
{
    BSDFMaterial _S361;
    if(wavelength_2 > 0.0f)
    {
        BSDFMaterial _S362 = atWavelength(material_1, wavelength_2);
        _S361 = _S362;
    }
    else
    {
        _S361 = material_1;
    }
    return _S361;
}

static __device__ float3  negate_0(float3  x_13)
{
    return - x_13;
}

static __device__ float sign_0(float e_1)
{
    bool _S363 = e_1 < 0.0f;
    float _S364 = _slang_select(_S363, -1.0f,0.0f);
    bool _S365 = e_1 > 0.0f;
    float _S366 = _slang_select(_S365, 1.0f,_S364);
    return _S366;
}

struct AnisotropicFrame
{
    float3  tangent;
    float2  alphas;
};

static __device__ AnisotropicFrame AnisotropicFrame_x24init_0(float3  tangent_0, float2  alphas_0)
{
    AnisotropicFrame _S367;
    (&_S367)->tangent = tangent_0;
    (&_S367)->alphas = alphas_0;
    return _S367;
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_1)
{
    float3  a_1 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S368 = (F32_abs((dot_0(n_1, a_1)))) > 0.9999847412109375f;
    float3  a_2;
    if(_S368)
    {
        float3  _S369 = make_float3 (1.0f, 0.0f, 0.0f);
        a_2 = _S369;
    }
    else
    {
        a_2 = a_1;
    }
    float3  _S370 = cross_0(n_1, a_2);
    float3  _S371 = ((((_S370)) * make_float3(rnorm3df(((_S370)).x, ((_S370)).y, ((_S370)).z))));
    float3  _S372 = cross_0(n_1, _S371);
    return make_float3 (v_0.x) * _S371 + make_float3 (v_0.y) * n_1 + make_float3 (v_0.z) * _S372;
}

__device__ AnisotropicFrame anisotropicFrame(BSDFMaterial material_2, float3  n_i_0)
{
    float _S373 = material_2.roughness;
    float _S374 = _S373 * _S373;
    bool _S375 = (material_2.anisotropy) == 0.0f;
    bool _S376;
    if(_S375)
    {
        _S376 = true;
    }
    else
    {
        _S376 = !(_S374 > 0.0f);
    }
    if(_S376)
    {
        return AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f));
    }
    float3  _S377 = material_2.tangent - n_i_0 * make_float3 (dot_0(n_i_0, material_2.tangent));
    float3  _S378 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_i_0);
    bool _S379 = (dot_0(_S377, _S377)) > 0.0f;
    float3  _S380 = _slang_select(_S379, _S377,_S378);
    float3  _S381 = ((((_S380)) * make_float3(rnorm3df(((_S380)).x, ((_S380)).y, ((_S380)).z))));
    float _S382 = 6.28318548202514648f * material_2.anisotropic_rotation;
    float _S383 = (F32_sqrt((1.0f - 0.89999997615814209f * (F32_abs((material_2.anisotropy))))));
    float _S384 = 1.0f / _S383;
    bool _S385 = (material_2.anisotropy) < 0.0f;
    float _S386 = _slang_select(_S385, _S384,_S383);
    return AnisotropicFrame_x24init_0(_S381 * make_float3 ((F32_cos((_S382)))) + cross_0(n_i_0, _S381) * make_float3 ((F32_sin((_S382)))), make_float2 (_S374 / _S386, _S374 * _S386));
}

struct SheenProfile
{
    bool on;
    float albedo;
};

static __device__ SheenProfile SheenProfile_x24init_0(bool on_0, float albedo_0)
{
    SheenProfile _S387;
    (&_S387)->on = on_0;
    (&_S387)->albedo = albedo_0;
    return _S387;
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
    SheenProfile _S388 = SheenProfile_x24init_0(false, 0.0f);
    float _S389 = rgb_to_greyscale(material_3.sheen);
    bool _S390 = _S389 > 0.0f;
    SheenProfile profile_0;
    if(_S390)
    {
        float _S391 = clamp_1((F32_sqrt(((F32_max((dot_0(n_i_1, v_1)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S392 = (U32_min((uint(_S391)), (22U)));
        float _S393 = (F32_sqrt((0.05000000074505806f)));
        float _S394 = (F32_sqrt((0.00999999977648258f)));
        bool _S395 = (material_3.velvet) > 0.0f;
        float _S396 = _slang_select(_S395, _S394,_S393);
        float _S397 = (clamp_1((F32_sqrt(((F32_max((material_3.sheen_roughness), (0.0f)))))), _S396, 1.0f) - _S396) / (1.0f - _S396) * 23.0f;
        uint _S398 = (U32_min((uint(_S397)), (22U)));
        uint _S399 = _S392 * 24U + _S398;
        float _S400 = _S391 - float(_S392);
        float _S401 = _S397 - float(_S398);
        if(_S395)
        {
            uint _S402 = _S399 + 24U;
            float _S403 = VELVET_ALBEDO_0[_S399] + (VELVET_ALBEDO_0[_S402] - VELVET_ALBEDO_0[_S399]) * _S400;
            uint _S404 = _S399 + 1U;
            float _S405 = VELVET_ALBEDO_0[_S404] + (VELVET_ALBEDO_0[_S402 + 1U] - VELVET_ALBEDO_0[_S404]) * _S400;
            SheenProfile _S406 = SheenProfile_x24init_0(true, _S403 + (_S405 - _S403) * _S401);
            profile_0 = _S406;
        }
        else
        {
            uint _S407 = _S399 + 24U;
            float _S408 = SHEEN_ALBEDO_0[_S399] + (SHEEN_ALBEDO_0[_S407] - SHEEN_ALBEDO_0[_S399]) * _S400;
            uint _S409 = _S399 + 1U;
            float _S410 = SHEEN_ALBEDO_0[_S409] + (SHEEN_ALBEDO_0[_S407 + 1U] - SHEEN_ALBEDO_0[_S409]) * _S400;
            SheenProfile _S411 = SheenProfile_x24init_0(true, (F32_exp((_S408 + (_S410 - _S408) * _S401))));
            profile_0 = _S411;
        }
    }
    else
    {
        profile_0 = _S388;
    }
    return profile_0;
}

struct CoatFrame
{
    float3  normal;
    float alpha;
    float ior;
};

static __device__ CoatFrame CoatFrame_x24init_0(float3  normal_3, float alpha_0, float ior_0)
{
    CoatFrame _S412;
    (&_S412)->normal = normal_3;
    (&_S412)->alpha = alpha_0;
    (&_S412)->ior = ior_0;
    return _S412;
}

__device__ __forceinline__ CoatFrame coatFrame(BSDFMaterial material_4, float3  n_2)
{
    CoatFrame _S413 = CoatFrame_x24init_0(make_float3 (0.0f), 0.0f, 0.0f);
    bool _S414 = (material_4.coat) > 0.0f;
    CoatFrame frame_0;
    if(_S414)
    {
        float3  _S415 = material_4.coat_normal;
        bool _S416 = (dot_0(_S415, _S415)) > 0.0f;
        float3  _S417 = material_4.coat_normal;
        float3  _S418 = ((((_S417)) * make_float3(rnorm3df(((_S417)).x, ((_S417)).y, ((_S417)).z))));
        float3  _S419 = _slang_select(_S416, _S418,n_2);
        float _S420 = sign_0(dot_0(_S419, n_2));
        float _S421 = material_4.coat_roughness;
        CoatFrame _S422 = CoatFrame_x24init_0(_S419 * make_float3 (_S420), _S421 * _S421, (F32_max((material_4.coat_ior), (1.00999999046325684f))));
        frame_0 = _S422;
    }
    else
    {
        frame_0 = _S413;
    }
    return frame_0;
}

__device__ __forceinline__ float3  coatSeries(CoatFrame coat_frame_0, BSDFMaterial material_5)
{
    float3  _S423 = make_float3 (0.0f);
    bool _S424 = (coat_frame_0.ior) > 0.0f;
    float3  series_0;
    if(_S424)
    {
        float _S425 = coat_frame_0.ior * coat_frame_0.ior;
        float _S426 = _S425 * _S425;
        float _S427 = coat_frame_0.ior - 1.0f;
        float _S428 = coat_frame_0.ior + 1.0f;
        float _S429 = _S425 - 1.0f;
        float _S430 = _S425 + 1.0f;
        float _S431 = _S426 - 1.0f;
        float _S432 = _S430 * _S431;
        float _S433 = 0.5f + _S427 * (3.0f * coat_frame_0.ior + 1.0f) / (6.0f * _S428 * _S428) + _S425 * _S429 * _S429 / (_S430 * _S430 * _S430) * (F32_log((_S427 / _S428))) - 2.0f * _S425 * coat_frame_0.ior * (_S425 + 2.0f * coat_frame_0.ior - 1.0f) / _S432 + 8.0f * _S426 * (_S426 + 1.0f) / (_S432 * _S431) * (F32_log((coat_frame_0.ior)));
        float _S434 = 1.0f - (1.0f - _S433) / _S425;
        float3  _S435 = material_5.coat_tint;
        float3  _S436 = _S435 * _S435 * make_float3 (1.0f - _S434) / (make_float3 (1.0f) - material_5.albedo * make_float3 (_S434));
        series_0 = _S436;
    }
    else
    {
        series_0 = _S423;
    }
    return series_0;
}

__device__ __forceinline__ float3  reflectedHalf(float3  in_dir_0, float3  out_dir_0)
{
    float3  _S437 = negate_0(in_dir_0);
    float3  _S438 = _S437 + out_dir_0;
    float3  _S439 = ((((_S438)) * make_float3(rnorm3df(((_S438)).x, ((_S438)).y, ((_S438)).z))));
    return _S439;
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
    float3  coat;
    float p_coat;
};

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

static __device__ float3  refract_0(float3  i_6, float3  n_3, float eta_0)
{
    float _S440 = dot_0(n_3, i_6);
    float _S441 = 1.0f - eta_0 * eta_0 * (1.0f - _S440 * _S440);
    if(_S441 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_6 - make_float3 (eta_0 * _S440 + (F32_sqrt((_S441)))) * n_3;
}

__device__ float fresnel(float cos_theta_0, float eta_i_0, float eta_o_0)
{
    float _S442 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S443 = eta_i_0 / eta_o_0 * _S442;
    bool _S444 = _S443 < 1.0f;
    float kr_0;
    if(_S444)
    {
        float _S445 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S443 * _S443))))));
        bool _S446 = eta_i_0 == eta_o_0;
        float _S447 = _slang_select(_S446, cos_theta_0,_S445);
        float _S448 = eta_o_0 * cos_theta_0;
        float _S449 = eta_i_0 * _S447;
        float _S450 = (_S448 - _S449) / (_S448 + _S449);
        float _S451 = eta_i_0 * cos_theta_0;
        float _S452 = eta_o_0 * _S447;
        float _S453 = (_S451 - _S452) / (_S451 + _S452);
        float _S454 = (_S450 * _S450 + _S453 * _S453) / 2.0f;
        kr_0 = _S454;
    }
    else
    {
        kr_0 = 1.0f;
    }
    return kr_0;
}

static __device__ float3  reflect_0(float3  i_7, float3  n_4)
{
    return i_7 - make_float3 (2.0f * dot_0(n_4, i_7)) * n_4;
}

__device__ float smithG1(float alpha_1, float n_dot_x_0)
{
    float _S455 = alpha_1 * alpha_1;
    float _S456 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S455 + (1.0f - _S455) * n_dot_x_0 * n_dot_x_0))));
    bool _S457 = alpha_1 > 0.0f;
    float _S458 = _slang_select(_S457, _S456,1.0f);
    return _S458;
}

__device__ __forceinline__ float coatFresnel(float3  in_dir_1, float3  v_2, float3  coat_h_0, CoatFrame coat_frame_1, float eta_i_1, bool behind_0)
{
    float _S459 = dot_0(coat_frame_1.normal, reflect_0(in_dir_1, coat_h_0));
    float _S460 = (F32_abs((dot_0(v_2, coat_h_0))));
    float _S461 = eta_i_1 / coat_frame_1.ior * (F32_sqrt(((F32_max((1.0f - _S460 * _S460), (0.0f))))));
    float _S462 = (F32_sqrt(((F32_max((1.0f - _S461 * _S461), (0.0f))))));
    float _S463 = _slang_select(behind_0, _S462,_S460);
    float _S464 = _slang_select(behind_0, coat_frame_1.ior,1.0f);
    float _S465 = _slang_select(behind_0, 1.0f,coat_frame_1.ior);
    float _S466 = fresnel(_S463, _S464, _S465);
    float _S467 = smithG1(coat_frame_1.alpha, _S459);
    float _S468 = _S466 * _S467;
    bool _S469 = _S459 > 0.0f;
    float _S470 = _slang_select(_S469, _S468,0.0f);
    return _S470;
}

static __device__ float3  mix_0(float3  e1_0, float3  e2_0, float e3_0)
{
    return e1_0 * make_float3 (1.0f - e3_0) + e2_0 * make_float3 (e3_0);
}

static __device__ Weights Weights_x24init_0(float v_dot_h_0, float3  refracted_1, float3  F_0, float reflect_weight_0, float3  diffuse_weight_0, float3  refract_weight_0, float p_diffuse_0, float p_reflect_0, float p_refract_0, float p_sheen_velvet_0, float p_toon_0, float3  sheen_0, float3  toon_0, float3  coat_0, float p_coat_0)
{
    Weights _S471;
    (&_S471)->v_dot_h = v_dot_h_0;
    (&_S471)->refracted = refracted_1;
    (&_S471)->F = F_0;
    (&_S471)->reflect_weight = reflect_weight_0;
    (&_S471)->diffuse_weight = diffuse_weight_0;
    (&_S471)->refract_weight = refract_weight_0;
    (&_S471)->p_diffuse = p_diffuse_0;
    (&_S471)->p_reflect = p_reflect_0;
    (&_S471)->p_refract = p_refract_0;
    (&_S471)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S471)->p_toon = p_toon_0;
    (&_S471)->sheen = sheen_0;
    (&_S471)->toon = toon_0;
    (&_S471)->coat = coat_0;
    (&_S471)->p_coat = p_coat_0;
    return _S471;
}

static __device__ bool any_1(bool3  x_15)
{
    bool result_6 = false;
    int i_8 = int(0);
    for(;;)
    {
        if(i_8 < int(3))
        {
        }
        else
        {
            break;
        }
        if(result_6)
        {
            result_6 = true;
        }
        else
        {
            result_6 = (bool((_slang_vector_get_element(x_15, i_8))));
        }
        i_8 = i_8 + int(1);
    }
    return result_6;
}

__device__ __forceinline__ Weights lobeWeights(float3  in_dir_2, float3  v_3, float3  n_i_2, float3  h_0, float3  coat_h_1, float3  ggx_n_0, float3  coat_n_0, AnisotropicFrame frame_1, SheenProfile sheen_profile_0, CoatFrame coat_frame_2, float3  coat_series_0, BSDFMaterial material_6, float eta_i_2, float eta_o_1)
{
    float _S472 = (F32_min(((F32_sqrt((material_6.specular_level))) * (F32_abs((eta_i_2 - eta_o_1))) / (eta_i_2 + eta_o_1)), (0.9999847412109375f)));
    float _S473 = _S472 * _S472;
    float _S474 = (1.0f + _S472) / (1.0f - _S472);
    float3  _S475 = make_float3 (1.0f);
    float3  _S476 = make_float3 (0.0f);
    float sheen_component_0;
    float3  sheen_1;
    float3  scale_1;
    if(sheen_profile_0.on)
    {
        float _S477 = (F32_min((sheen_profile_0.albedo), (1.0f)));
        float3  _S478 = make_float3 (1.0f) - material_6.sheen * make_float3 (_S477);
        float _S479 = rgb_to_greyscale(material_6.sheen);
        float _S480 = _S479 * _S477;
        float3  _S481 = material_6.sheen / make_float3 ((F32_max((sheen_profile_0.albedo), (1.0f))));
        sheen_component_0 = _S480;
        sheen_1 = _S481;
        scale_1 = _S478;
    }
    else
    {
        sheen_component_0 = 0.0f;
        sheen_1 = _S476;
        scale_1 = _S475;
    }
    float _S482 = (F32_abs((material_6.toon.x)));
    bool _S483 = _S482 > 0.0f;
    float toon_component_0;
    float3  toon_1;
    if(_S483)
    {
        float _S484 = (F32_min((_S482), (1.0f)));
        float3  scale_2 = scale_1 * make_float3 (1.0f - _S484);
        float _S485 = rgb_to_greyscale(material_6.albedo);
        float _S486 = _S484 * _S485;
        float3  _S487 = make_float3 (_S484) * material_6.albedo;
        toon_component_0 = _S486;
        toon_1 = _S487;
        scale_1 = scale_2;
    }
    else
    {
        toon_component_0 = 0.0f;
        toon_1 = _S476;
    }
    bool _S488 = (material_6.metallic) > 0.0f;
    float3  rebounce_0;
    if(_S488)
    {
        float _S489 = frame_1.alphas.x;
        float _S490 = (F32_sqrt(((F32_min((_S489), (frame_1.alphas.y))))));
        bool _S491 = _S489 > 0.0f;
        float _S492 = _slang_select(_S491, _S490,material_6.roughness);
        float _S493 = _S492 * _S492;
        float _S494 = (F32_pow((_S493), (1.81585001945495605f))) * (2.15371990203857422f - 0.73285001516342163f * _S493) / (1.0f + 1.28094995021820068f * _S493);
        bool _S495 = _S493 > 0.0f;
        float _S496 = _slang_select(_S495, _S494,0.0f);
        float _S497 = clamp_1(dot_0(n_i_2, v_3), 0.0f, 1.0f);
        float _S498 = _S493 * _S492;
        float _S499 = (F32_min((1.00064504146575928f - _S492 * (0.00375499995425344f + _S497 * (-0.04133399948477745f + _S497 * (-0.90938502550125122f + _S497 * 0.35275399684906006f))) - _S493 * (0.27602800726890564f + _S497 * (1.27023398876190186f + _S497 * 0.04740000143647194f)) - _S498 * (0.31452900171279907f - _S497 * 0.34830701351165771f) + _S498 * _S492 * 0.27229699492454529f), (1.0f)));
        float3  _S500 = min_1(make_float3 (1.0f) / (make_float3 (1.0f) - material_6.albedo * make_float3 (_S496)), make_float3 (1.0f / (F32_max((_S499), (0.0000152587890625f)))));
        rebounce_0 = _S500;
    }
    else
    {
        rebounce_0 = _S475;
    }
    float _S501 = dot_0(h_0, v_3);
    float _S502 = eta_i_2 / eta_o_1;
    float3  _S503 = refract_0(in_dir_2, h_0, _S502);
    float3  _S504 = ((((_S503)) * make_float3(rnorm3df(((_S503)).x, ((_S503)).y, ((_S503)).z))));
    float _S505 = (F32_abs((_S501)));
    bool _S506 = eta_i_2 > eta_o_1;
    float _S507 = _slang_select(_S506, _S474,1.0f);
    float _S508 = _slang_select(_S506, 1.0f,_S474);
    float _S509 = fresnel(_S505, _S507, _S508);
    float _S510 = eta_i_2 * eta_i_2;
    float _S511 = eta_o_1 * eta_o_1;
    bool _S512 = (_S510 * (1.0f - _S501 * _S501)) >= _S511;
    float3  _S513 = material_6.specular_tint * make_float3 (_S473);
    float3  _S514 = make_float3 (1.0f) - _S513;
    float _S515 = 1.0f - _S473;
    float3  _S516 = _S513 + _S514 * make_float3 (_S509 - _S473) / make_float3 (_S515);
    float3  _S517 = _slang_select(_S512, _S475,_S516);
    bool _S518 = (dot_0(coat_h_1, coat_h_1)) > 0.0f;
    float3  coat_1;
    float3  up_0;
    float3  through_0;
    if(_S518)
    {
        float _S519 = coatFresnel(in_dir_2, v_3, coat_h_1, coat_frame_2, eta_i_2, _S506);
        float _S520 = material_6.coat * _S519;
        float3  _S521 = material_6.coat_tint;
        float3  _S522 = _S521 * _S521;
        float3  _S523 = _slang_select(_S506, _S522,_S475);
        float3  _S524 = make_float3 (_S520) * _S523;
        float _S525 = 1.0f - _S519;
        bool _S526 = !_S506;
        float3  _S527 = _slang_select(_S526, coat_series_0,_S475);
        float3  _S528 = mix_0(_S475, make_float3 (_S525) * _S527, material_6.coat);
        float3  _S529 = mix_0(_S475, make_float3 (_S525) * material_6.coat_tint, material_6.coat);
        coat_1 = _S524;
        up_0 = _S528;
        through_0 = _S529;
    }
    else
    {
        coat_1 = _S476;
        up_0 = _S475;
        through_0 = _S475;
    }
    float3  _S530 = scale_1 * coat_1;
    float _S531 = rgb_to_greyscale(_S530);
    float3  _S532 = material_6.albedo * rebounce_0;
    float3  _S533 = mix_0(_S517, _S532, material_6.metallic);
    float3  F_1 = _S533 * scale_1 * up_0;
    float _S534 = rgb_to_greyscale(F_1);
    float _S535 = 1.0f - material_6.metallic;
    float _S536 = (1.0f - material_6.transmission) * _S535;
    float3  _S537 = make_float3 (1.0f) - _S517;
    float3  _S538 = make_float3 (_S536) * _S537 * scale_1 * up_0;
    float _S539 = material_6.transmission * _S535;
    float3  _S540 = make_float3 (_S539) * _S537 * scale_1 * through_0;
    float _S541 = (F32_max((_S534), (0.0f)));
    float _S542 = rgb_to_greyscale(_S538);
    float _S543 = (F32_max((_S542), (0.0f)));
    float _S544 = rgb_to_greyscale(_S540);
    float _S545 = sign_0(length_0(_S504));
    float _S546 = (F32_max((_S544 * _S545), (0.0f)));
    float _S547 = _S541 + _S543 + _S546 + toon_component_0 + _S531;
    float _S548 = (F32_min((sheen_component_0), (1.0f)));
    bool _S549 = sheen_component_0 > 0.0f;
    bool _S550;
    if(_S549)
    {
        _S550 = !(_S547 > 0.0f);
    }
    else
    {
        _S550 = false;
    }
    float _S551 = _slang_select(_S550, 1.0f,_S548);
    float _S552 = (1.0f - _S551) / (F32_max((_S547), (0.0000152587890625f)));
    float _S553 = _S543 * _S552;
    float _S554 = _S541 * _S552;
    float _S555 = _S546 * _S552;
    Weights _S556 = Weights_x24init_0(_S501, _S504, F_1, 1.0f, _S538, _S540, _S553, _S554, _S555, _S551, toon_component_0 * _S552, sheen_1, toon_1, _S530, _S531 * _S552);
    bool _S557 = any_1(ggx_n_0 != h_0);
    Weights leaving_0;
    if(_S557)
    {
        float _S558 = dot_0(ggx_n_0, v_3);
        float _S559 = eta_i_2 / eta_o_1;
        float3  _S560 = refract_0(in_dir_2, ggx_n_0, _S559);
        float3  _S561 = ((((_S560)) * make_float3(rnorm3df(((_S560)).x, ((_S560)).y, ((_S560)).z))));
        float _S562 = (F32_abs((_S558)));
        float _S563 = _slang_select(_S506, _S474,1.0f);
        float _S564 = _slang_select(_S506, 1.0f,_S474);
        float _S565 = fresnel(_S562, _S563, _S564);
        bool _S566 = (_S510 * (1.0f - _S558 * _S558)) >= _S511;
        float3  _S567 = _S513 + _S514 * make_float3 (_S565 - _S473) / make_float3 (_S515);
        float3  _S568 = _slang_select(_S566, _S475,_S567);
        if(_S518)
        {
            float _S569 = coatFresnel(in_dir_2, v_3, coat_h_1, coat_frame_2, eta_i_2, _S506);
            float _S570 = material_6.coat * _S569;
            float3  _S571 = material_6.coat_tint;
            float3  _S572 = _S571 * _S571;
            float3  _S573 = _slang_select(_S506, _S572,_S475);
            float3  _S574 = make_float3 (_S570) * _S573;
            float _S575 = 1.0f - _S569;
            bool _S576 = !_S506;
            float3  _S577 = _slang_select(_S576, coat_series_0,_S475);
            float3  _S578 = mix_0(_S475, make_float3 (_S575) * _S577, material_6.coat);
            float3  _S579 = mix_0(_S475, make_float3 (_S575) * material_6.coat_tint, material_6.coat);
            coat_1 = _S574;
            up_0 = _S578;
            through_0 = _S579;
        }
        else
        {
            coat_1 = _S476;
            up_0 = _S475;
            through_0 = _S475;
        }
        float3  _S580 = scale_1 * coat_1;
        float _S581 = rgb_to_greyscale(_S580);
        float3  _S582 = mix_0(_S568, _S532, material_6.metallic);
        float3  F_2 = _S582 * scale_1 * up_0;
        float _S583 = rgb_to_greyscale(F_2);
        float3  _S584 = make_float3 (1.0f) - _S568;
        float3  _S585 = make_float3 (_S536) * _S584 * scale_1 * up_0;
        float3  _S586 = make_float3 (_S539) * _S584 * scale_1 * through_0;
        float _S587 = (F32_max((_S583), (0.0f)));
        float _S588 = rgb_to_greyscale(_S585);
        float _S589 = (F32_max((_S588), (0.0f)));
        float _S590 = rgb_to_greyscale(_S586);
        float _S591 = sign_0(length_0(_S561));
        float _S592 = (F32_max((_S590 * _S591), (0.0f)));
        float _S593 = _S587 + _S589 + _S592 + toon_component_0 + _S581;
        if(_S549)
        {
            _S550 = !(_S593 > 0.0f);
        }
        else
        {
            _S550 = false;
        }
        float _S594 = _slang_select(_S550, 1.0f,_S548);
        float _S595 = (1.0f - _S594) / (F32_max((_S593), (0.0000152587890625f)));
        float _S596 = _S589 * _S595;
        float _S597 = _S587 * _S595;
        float _S598 = _S592 * _S595;
        Weights _S599 = Weights_x24init_0(_S558, _S561, F_2, 1.0f, _S585, _S586, _S596, _S597, _S598, _S594, toon_component_0 * _S595, sheen_1, toon_1, _S580, _S581 * _S595);
        leaving_0 = _S599;
    }
    else
    {
        leaving_0 = _S556;
    }
    bool _S600 = any_1(coat_n_0 != coat_h_1);
    Weights coated_0;
    if(_S600)
    {
        float _S601 = eta_i_2 / eta_o_1;
        float3  _S602 = refract_0(in_dir_2, h_0, _S601);
        float3  _S603 = ((((_S602)) * make_float3(rnorm3df(((_S602)).x, ((_S602)).y, ((_S602)).z))));
        float _S604 = _slang_select(_S506, _S474,1.0f);
        float _S605 = _slang_select(_S506, 1.0f,_S474);
        float _S606 = fresnel(_S505, _S604, _S605);
        float3  _S607 = _S513 + _S514 * make_float3 (_S606 - _S473) / make_float3 (_S515);
        float3  _S608 = _slang_select(_S512, _S475,_S607);
        bool _S609 = (dot_0(coat_n_0, coat_n_0)) > 0.0f;
        if(_S609)
        {
            float _S610 = coatFresnel(in_dir_2, v_3, coat_n_0, coat_frame_2, eta_i_2, _S506);
            float _S611 = material_6.coat * _S610;
            float3  _S612 = material_6.coat_tint;
            float3  _S613 = _S612 * _S612;
            float3  _S614 = _slang_select(_S506, _S613,_S475);
            float3  _S615 = make_float3 (_S611) * _S614;
            float _S616 = 1.0f - _S610;
            bool _S617 = !_S506;
            float3  _S618 = _slang_select(_S617, coat_series_0,_S475);
            float3  _S619 = mix_0(_S475, make_float3 (_S616) * _S618, material_6.coat);
            float3  _S620 = mix_0(_S475, make_float3 (_S616) * material_6.coat_tint, material_6.coat);
            coat_1 = _S615;
            up_0 = _S619;
            through_0 = _S620;
        }
        else
        {
            coat_1 = _S476;
            up_0 = _S475;
            through_0 = _S475;
        }
        float3  _S621 = scale_1 * coat_1;
        float _S622 = rgb_to_greyscale(_S621);
        float3  _S623 = mix_0(_S608, _S532, material_6.metallic);
        float3  F_3 = _S623 * scale_1 * up_0;
        float _S624 = rgb_to_greyscale(F_3);
        float3  _S625 = make_float3 (1.0f) - _S608;
        float3  _S626 = make_float3 (_S536) * _S625 * scale_1 * up_0;
        float3  _S627 = make_float3 (_S539) * _S625 * scale_1 * through_0;
        float _S628 = (F32_max((_S624), (0.0f)));
        float _S629 = rgb_to_greyscale(_S626);
        float _S630 = (F32_max((_S629), (0.0f)));
        float _S631 = rgb_to_greyscale(_S627);
        float _S632 = sign_0(length_0(_S603));
        float _S633 = (F32_max((_S631 * _S632), (0.0f)));
        float _S634 = _S628 + _S630 + _S633 + toon_component_0 + _S622;
        if(_S549)
        {
            _S550 = !(_S634 > 0.0f);
        }
        else
        {
            _S550 = false;
        }
        float _S635 = _slang_select(_S550, 1.0f,_S548);
        float _S636 = (1.0f - _S635) / (F32_max((_S634), (0.0000152587890625f)));
        float _S637 = _S630 * _S636;
        float _S638 = _S628 * _S636;
        float _S639 = _S633 * _S636;
        Weights _S640 = Weights_x24init_0(_S501, _S603, F_3, 1.0f, _S626, _S627, _S637, _S638, _S639, _S635, toon_component_0 * _S636, sheen_1, toon_1, _S621, _S622 * _S636);
        coated_0 = _S640;
    }
    else
    {
        coated_0 = _S556;
    }
    return Weights_x24init_0(leaving_0.v_dot_h, leaving_0.refracted, leaving_0.F, leaving_0.reflect_weight, _S556.diffuse_weight, leaving_0.refract_weight, _S556.p_diffuse, leaving_0.p_reflect, leaving_0.p_refract, _S556.p_sheen_velvet, _S556.p_toon, sheen_1, toon_1, coated_0.coat, coated_0.p_coat);
}

__device__ float translucentShare(BSDFMaterial material_7)
{
    float _S641 = rgb_to_greyscale(material_7.translucent);
    float _S642 = rgb_to_greyscale(material_7.albedo);
    float _S643 = _S641 / (_S642 + _S641);
    bool _S644 = _S641 > 0.0f;
    float _S645 = _slang_select(_S644, _S643,0.0f);
    return _S645;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float n_i_dot_v_0, BSDFMaterial material_8, Weights w_0)
{
    float _S646 = translucentShare(material_8);
    float _S647 = w_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S648 = w_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S649 = 1.0f - _S646;
    bool _S650 = n_i_dot_l_0 < 0.0f;
    float _S651 = _slang_select(_S650, _S646,_S649);
    float _S652 = _S648 * _S651;
    bool _S653 = _S646 > 0.0f;
    float _S654 = _slang_select(_S653, _S652,_S647);
    bool _S655 = n_i_dot_v_0 > 0.0f;
    float _S656 = _slang_select(_S655, _S654,0.0f);
    return _S656;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_3, BSDFMaterial material_9, Weights w_1)
{
    float _S657 = translucentShare(material_9);
    bool _S658 = (dot_0(n_i_3, l_0)) < 0.0f;
    float3  _S659 = _slang_select(_S658, material_9.translucent,material_9.albedo);
    float _S660 = 1.0f - _S657;
    float _S661 = _slang_select(_S658, _S657,_S660);
    float3  _S662 = _S659 / make_float3 (_S661);
    bool _S663 = _S657 > 0.0f;
    float3  _S664 = _slang_select(_S663, _S662,material_9.albedo);
    return w_1.diffuse_weight * _S664 / make_float3 (w_1.p_diffuse);
}

__device__ float trowbridgeReitz(float alpha_2, float n_dot_h_0)
{
    float _S665 = alpha_2 * alpha_2;
    float _S666 = (1.0f - n_dot_h_0) * (1.0f + n_dot_h_0) + _S665 * n_dot_h_0 * n_dot_h_0;
    return _S665 / (F32_max((3.14159274101257324f * _S666 * _S666), (1.17549435082228751e-38f)));
}

__device__ float3  anisotropicLocal(float3  w_2, float3  t_12, float3  n_5)
{
    return make_float3 (dot_0(w_2, t_12), dot_0(w_2, cross_0(n_5, t_12)), dot_0(w_2, n_5));
}

__device__ float anisotropicG1(float3  w_3, float2  alphas_1)
{
    float _S667 = (F32_max((w_3.z), (0.0f)));
    return 2.0f * _S667 / (_S667 + length_0(make_float3 (alphas_1.x * w_3.x, alphas_1.y * w_3.y, _S667)));
}

__device__ float anisotropicD(float3  h_1, float2  alphas_2)
{
    float _S668 = alphas_2.x;
    float _S669 = h_1.x / _S668;
    float _S670 = alphas_2.y;
    float _S671 = h_1.y / _S670;
    float _S672 = h_1.z;
    float _S673 = _S669 * _S669 + _S671 * _S671 + _S672 * _S672;
    return 1.0f / (F32_max((3.14159274101257324f * _S668 * _S670 * _S673 * _S673), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float3  v_4, float3  h_2, float3  n_i_4, float n_i_dot_v_1, float alpha_3, AnisotropicFrame frame_2, float v_dot_h_1)
{
    float _S674 = dot_0(n_i_4, h_2);
    float _S675 = smithG1(alpha_3, n_i_dot_v_1);
    float _S676 = _S675 * v_dot_h_1;
    float _S677 = trowbridgeReitz(alpha_3, _S674);
    float _S678 = _S676 * _S677 / n_i_dot_v_1;
    bool _S679 = alpha_3 > 0.0f;
    bool _S680;
    if(_S679)
    {
        _S680 = v_dot_h_1 > 0.0f;
    }
    else
    {
        _S680 = false;
    }
    if(_S680)
    {
        _S680 = _S674 > 0.0f;
    }
    else
    {
        _S680 = false;
    }
    if(_S680)
    {
        _S680 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S680 = false;
    }
    float _S681 = _slang_select(_S680, _S678,0.0f);
    bool _S682 = (frame_2.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S682)
    {
        float3  _S683 = anisotropicLocal(v_4, frame_2.tangent, n_i_4);
        float _S684 = anisotropicG1(_S683, frame_2.alphas);
        float3  _S685 = anisotropicLocal(h_2, frame_2.tangent, n_i_4);
        float _S686 = anisotropicD(_S685, frame_2.alphas);
        float _S687 = _S684 * _S686;
        float _S688 = _S687 * v_dot_h_1 / n_i_dot_v_1;
        bool _S689 = v_dot_h_1 > 0.0f;
        if(_S689)
        {
            _S680 = _S674 > 0.0f;
        }
        else
        {
            _S680 = false;
        }
        if(_S680)
        {
            _S680 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S680 = false;
        }
        float _S690 = _slang_select(_S680, _S688,0.0f);
        pdf_h_0 = _S690;
    }
    else
    {
        pdf_h_0 = _S681;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float l_dot_h_0, float pdf_h_1, Weights w_4, float eta_i_3, float eta_o_2)
{
    float _S691 = eta_i_3 * w_4.v_dot_h + eta_o_2 * l_dot_h_0;
    float _S692 = w_4.p_refract * pdf_h_1 * eta_o_2 * eta_o_2 * (F32_abs((l_dot_h_0))) / (_S691 * _S691);
    bool _S693 = eta_i_3 != eta_o_2;
    bool _S694;
    if(_S693)
    {
        _S694 = l_dot_h_0 < 0.0f;
    }
    else
    {
        _S694 = false;
    }
    float _S695 = _slang_select(_S694, _S692,0.0f);
    return _S695;
}

__device__ float maskingG1(float3  l_1, float3  n_i_5, float side_0, float alpha_4, AnisotropicFrame frame_3)
{
    float _S696 = smithG1(alpha_4, (F32_max((side_0 * dot_0(n_i_5, l_1)), (0.0f))));
    bool _S697 = (frame_3.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S697)
    {
        float3  _S698 = anisotropicLocal(l_1, frame_3.tangent, n_i_5 * make_float3 (side_0));
        float _S699 = anisotropicG1(_S698, frame_3.alphas);
        G1_l_0 = _S699;
    }
    else
    {
        G1_l_0 = _S696;
    }
    return G1_l_0;
}

__device__ __forceinline__ float3  refractBSDF(float G1_l_1, BSDFMaterial material_10, Weights w_5)
{
    bool _S700 = (material_10.ior) == 1.0f;
    float _S701 = _slang_select(_S700, 1.0f,G1_l_1);
    return w_5.refract_weight * make_float3 (_S701) * material_10.albedo / make_float3 (w_5.p_refract);
}

__device__ __forceinline__ float reflectPDF(float pdf_h_2, Weights w_6)
{
    float _S702 = w_6.p_reflect * pdf_h_2 / (4.0f * w_6.v_dot_h);
    bool _S703 = pdf_h_2 > 0.0f;
    float _S704 = _slang_select(_S703, _S702,0.0f);
    return _S704;
}

__device__ __forceinline__ float3  reflectBSDF(float G1_l_2, Weights w_7)
{
    return make_float3 (w_7.reflect_weight * G1_l_2) * w_7.F / make_float3 (w_7.p_reflect);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_1, float n_i_dot_v_2, Weights w_8)
{
    float _S705 = w_8.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S706 = n_i_dot_l_1 > 0.0f;
    bool _S707;
    if(_S706)
    {
        _S707 = n_i_dot_v_2 > 0.0f;
    }
    else
    {
        _S707 = false;
    }
    float _S708 = _slang_select(_S707, _S705,0.0f);
    return _S708;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  v_5, float3  n_i_6, BSDFMaterial material_11, Weights w_9)
{
    float3  _S709 = l_2 + v_5;
    float3  _S710 = ((((_S709)) * make_float3(rnorm3df(((_S709)).x, ((_S709)).y, ((_S709)).z))));
    float _S711 = dot_0(n_i_6, _S710);
    float _S712 = (F32_max((dot_0(n_i_6, l_2)), (0.0f)));
    float _S713 = (F32_max((dot_0(n_i_6, v_5)), (0.0f)));
    float _S714 = 1.0f / (F32_max((material_11.sheen_roughness), (0.05000000074505806f)));
    float _S715 = 1.0f - _S711 * _S711;
    float _S716 = (2.0f + _S714) * (F32_pow(((F32_max((_S715), (0.0f)))), (0.5f * _S714))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S712 + _S713 - _S712 * _S713)), (0.0000152587890625f)));
    bool _S717 = (material_11.velvet) > 0.0f;
    float f_1;
    if(_S717)
    {
        float _S718 = (F32_max((material_11.sheen_roughness), (0.00999999977648258f)));
        float _S719 = _S718 * _S718;
        float _S720 = (F32_max((_S715), (0.0000152587890625f)));
        float _S721 = (F32_exp((- _S711 * _S711 / (_S720 * _S719)))) / (3.14159274101257324f * _S719 * _S720 * _S720) * (F32_min((1.0f), (2.0f * _S711 * (F32_min((_S712), (_S713))) / (F32_max(((F32_abs((dot_0(_S710, v_5))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S712 * _S713), (0.0000152587890625f)));
        f_1 = _S721;
    }
    else
    {
        f_1 = _S716;
    }
    return w_9.sheen * make_float3 (f_1 * _S712 * 2.0f * 3.14159274101257324f / w_9.p_sheen_velvet);
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

__device__ __forceinline__ float toonP(float t_13, float a_3, float s_0)
{
    float _S722 = (F32_max((1.0f - (t_13 - a_3) / (F32_max((s_0), (0.0000152587890625f)))), (0.0f)));
    bool _S723 = t_13 < a_3;
    float _S724 = _slang_select(_S723, 1.0f,_S722);
    return _S724;
}

__device__ __forceinline__ float toonIntegral(float t_14, float a_4, float s_1, bool glossy_0)
{
    float _S725 = (F32_min((t_14), (a_4)));
    float _S726 = (F32_sin((_S725)));
    float _S727 = _S726 * _S726 / 2.0f;
    float _S728 = 1.0f - (F32_cos((_S725)));
    float _S729 = _slang_select(glossy_0, _S728,_S727);
    bool _S730 = t_14 > a_4;
    bool _S731;
    if(_S730)
    {
        _S731 = s_1 > 0.0f;
    }
    else
    {
        _S731 = false;
    }
    float integral_0;
    if(_S731)
    {
        if(glossy_0)
        {
            float _S732 = (F32_cos((a_4)));
            float _S733 = (F32_cos((t_14)));
            integral_0 = (1.0f + a_4 / s_1) * (_S732 - _S733) - ((F32_sin((t_14))) - t_14 * _S733 - ((F32_sin((a_4))) - a_4 * _S732)) / s_1;
        }
        else
        {
            float _S734 = 2.0f * a_4;
            float _S735 = (F32_cos((_S734)));
            float _S736 = 2.0f * t_14;
            float _S737 = (F32_cos((_S736)));
            integral_0 = (1.0f + a_4 / s_1) * (_S735 - _S737) / 4.0f - ((F32_sin((_S736))) / 8.0f - t_14 * _S737 / 4.0f - ((F32_sin((_S734))) / 8.0f - a_4 * _S735 / 4.0f)) / s_1;
        }
        float integral_1 = _S729 + integral_0;
        integral_0 = integral_1;
    }
    else
    {
        integral_0 = _S729;
    }
    return integral_0;
}

static __device__ ToonProfile ToonProfile_x24init_0(bool glossy_1, float a_5, float s_2, float b_1, float norm_0, float view_0, float3  axis_0)
{
    ToonProfile _S738;
    (&_S738)->glossy = glossy_1;
    (&_S738)->a = a_5;
    (&_S738)->s = s_2;
    (&_S738)->b = b_1;
    (&_S738)->norm = norm_0;
    (&_S738)->view = view_0;
    (&_S738)->axis = axis_0;
    return _S738;
}

__device__ __forceinline__ ToonProfile toonProfile(float3  v_6, float3  n_i_7, BSDFMaterial material_12)
{
    float _S739 = material_12.toon.x;
    bool _S740 = _S739 < 0.0f;
    float _S741 = clamp_1(material_12.toon.y / _S739, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S742 = clamp_1(material_12.toon.z / _S739, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S743 = (F32_min((_S741 + _S742), (1.57079637050628662f)));
    float _S744 = dot_0(n_i_7, v_6);
    float _S745 = toonP((F32_acos(((F32_min((_S744), (1.0f)))))), _S741, _S742);
    float3  _S746 = make_float3 (2.0f * _S744) * n_i_7 - v_6;
    float3  _S747 = ((((_S746)) * make_float3(rnorm3df(((_S746)).x, ((_S746)).y, ((_S746)).z))));
    float3  _S748 = _slang_select(_S740, _S747,n_i_7);
    float _S749 = toonIntegral(_S743, _S741, _S742, _S740);
    return ToonProfile_x24init_0(_S740, _S741, _S742, _S743, 6.28318548202514648f * _S749, _S745, _S748);
}

__device__ __forceinline__ float toonPDF(float3  l_3, float3  n_i_8, ToonProfile profile_1, Weights w_10)
{
    float _S750 = dot_0(n_i_8, l_3);
    float _S751 = dot_0(l_3, profile_1.axis);
    float _S752 = _slang_select(profile_1.glossy, _S751,_S750);
    float _S753 = (F32_acos((clamp_1(_S752, -1.0f, 1.0f))));
    float _S754 = toonP(_S753, profile_1.a, profile_1.s);
    float _S755 = w_10.p_toon * _S754;
    float _S756 = _slang_select(profile_1.glossy, 1.0f,_S750);
    float _S757 = _S755 * _S756 / profile_1.norm;
    bool _S758;
    if(profile_1.glossy)
    {
        _S758 = true;
    }
    else
    {
        _S758 = _S750 > 0.0f;
    }
    float _S759 = _slang_select(_S758, _S757,0.0f);
    return _S759;
}

__device__ __forceinline__ float3  toonBSDF(float3  l_4, float3  n_i_9, ToonProfile profile_2, Weights w_11)
{
    float _S760 = (F32_max((dot_0(n_i_9, l_4)), (0.0f)));
    float _S761 = _slang_select(profile_2.glossy, _S760,profile_2.view);
    return w_11.toon * make_float3 (_S761) / make_float3 (w_11.p_toon);
}

__device__ __forceinline__ float coatPDF(float3  v_7, float3  coat_h_2, CoatFrame coat_frame_3, Weights w_12)
{
    float _S762 = dot_0(coat_frame_3.normal, v_7);
    float _S763 = smithG1(coat_frame_3.alpha, _S762);
    float _S764 = trowbridgeReitz(coat_frame_3.alpha, dot_0(coat_frame_3.normal, coat_h_2));
    float _S765 = _S763 * _S764 / (4.0f * _S762);
    bool _S766 = (coat_frame_3.alpha) > 0.0f;
    float _S767 = _slang_select(_S766, _S765,0.0f);
    return w_12.p_coat * _S767;
}

__device__ __forceinline__ float3  coatBSDF(Weights w_13)
{
    return w_13.coat / make_float3 (w_13.p_coat);
}

__device__ __forceinline__ void BSDF(float3  in_dir_3, float3  out_dir_1, float3  n_6, BSDFMaterial material_13, float eta_i_4, float eta_o_3, bool refracted_2, Facets facets_0, FixedArray<float3 , 6>  * throughputs_0, FixedArray<float, 6>  * pdfs_0)
{
    float3  _S768 = negate_0(in_dir_3);
    float _S769 = dot_0(n_6, _S768);
    float _S770 = sign_0(_S769);
    float3  _S771 = n_6 * make_float3 (_S770);
    float _S772 = dot_0(_S771, out_dir_1);
    float _S773 = material_13.roughness;
    float _S774 = _S773 * _S773;
    AnisotropicFrame _S775 = anisotropicFrame(material_13, _S771);
    SheenProfile _S776 = sheenProfile(_S768, _S771, material_13);
    CoatFrame _S777 = coatFrame(material_13, _S771);
    float3  _S778 = coatSeries(_S777, material_13);
    float _S779 = rgb_to_greyscale(material_13.translucent);
    bool _S780 = _S779 > 0.0f;
    bool _S781 = (dot_0(n_6, out_dir_1) * _S769) < 0.0f;
    bool _S782 = (F32_abs((material_13.toon.x))) > 0.0f;
    float3  _S783 = facets_0.coat_h;
    bool _S784 = (dot_0(_S783, _S783)) > 0.0f;
    bool _S785;
    if(_S780)
    {
        _S785 = _S781;
    }
    else
    {
        _S785 = false;
    }
    bool _S786 = _S785 == refracted_2;
    bool _S787 = !refracted_2;
    if(_S787)
    {
        _S785 = _S782;
    }
    else
    {
        _S785 = false;
    }
    bool _S788;
    if(_S787)
    {
        _S788 = _S784;
    }
    else
    {
        _S788 = false;
    }
    float3  _S789 = negate_0(make_float3 (eta_i_4) * _S768 + make_float3 (eta_o_3) * out_dir_1);
    float3  _S790 = ((((_S789)) * make_float3(rnorm3df(((_S789)).x, ((_S789)).y, ((_S789)).z))));
    float3  _S791 = reflectedHalf(in_dir_3, out_dir_1);
    float _S792 = sign_0(dot_0(_S790, _S771));
    float3  _S793 = _S790 * make_float3 (_S792);
    float3  _S794 = _slang_select(refracted_2, _S793,_S791);
    float3  _S795 = make_float3 (0.0f);
    float3  _S796 = _slang_select(_S788, _S791,_S795);
    Weights _S797 = lobeWeights(in_dir_3, _S768, _S771, facets_0.h, facets_0.coat_h, _S794, _S796, _S775, _S776, _S777, _S778, material_13, eta_i_4, eta_o_3);
    float _S798 = (F32_abs((_S769)));
    float _S799 = diffusePDF(_S772, _S798, material_13, _S797);
    float _S800 = _slang_select(_S786, _S799,0.0f);
    (*pdfs_0)[int(0)] = _S800;
    float3  _S801 = diffuseBSDF(out_dir_1, _S771, material_13, _S797);
    float3  _S802 = _slang_select(_S786, _S801,_S795);
    (*throughputs_0)[int(0)] = _S802;
    float _S803 = vndfPDF(_S768, _S794, _S771, _S798, _S774, _S775, _S797.v_dot_h);
    float _S804 = refractPDF(dot_0(out_dir_1, _S794), _S803, _S797, eta_i_4, eta_o_3);
    float _S805 = _slang_select(refracted_2, _S804,0.0f);
    (*pdfs_0)[int(1)] = _S805;
    float _S806 = maskingG1(out_dir_1, _S771, -1.0f, _S774, _S775);
    float3  _S807 = refractBSDF(_S806, material_13, _S797);
    float3  _S808 = _slang_select(refracted_2, _S807,_S795);
    (*throughputs_0)[int(1)] = _S808;
    float _S809 = reflectPDF(_S803, _S797);
    float _S810 = _slang_select(_S787, _S809,0.0f);
    (*pdfs_0)[int(2)] = _S810;
    float _S811 = maskingG1(out_dir_1, _S771, 1.0f, _S774, _S775);
    float3  _S812 = reflectBSDF(_S811, _S797);
    float3  _S813 = _slang_select(_S787, _S812,_S795);
    (*throughputs_0)[int(2)] = _S813;
    float _S814 = sheenVelvetPDF(_S772, _S798, _S797);
    float _S815 = _slang_select(_S787, _S814,0.0f);
    (*pdfs_0)[int(3)] = _S815;
    float3  _S816 = sheenVelvetBSDF(out_dir_1, _S768, _S771, material_13, _S797);
    float3  _S817 = _slang_select(_S787, _S816,_S795);
    (*throughputs_0)[int(3)] = _S817;
    ToonProfile _S818 = toonProfile(_S768, _S771, material_13);
    float _S819 = toonPDF(out_dir_1, _S771, _S818, _S797);
    float _S820 = _slang_select(_S785, _S819,0.0f);
    (*pdfs_0)[int(4)] = _S820;
    float3  _S821 = toonBSDF(out_dir_1, _S771, _S818, _S797);
    float3  _S822 = _slang_select(_S785, _S821,_S795);
    (*throughputs_0)[int(4)] = _S822;
    float _S823 = coatPDF(_S768, _S796, _S777, _S797);
    float _S824 = _slang_select(_S788, _S823,0.0f);
    (*pdfs_0)[int(5)] = _S824;
    float3  _S825 = coatBSDF(_S797);
    float3  _S826 = _slang_select(_S788, _S825,_S795);
    (*throughputs_0)[int(5)] = _S826;
    return;
}

static __device__ __forceinline__ float3  skyLobes_0(float3  in_dir_4, float3  dir_5, FKSurface * surface_1, BSDFMaterial * material_14, float2  eta_1, bool is_inside_2, Facets * facets_1, float pdf_1, FixedArray<float3 , 6>  * terms_0, FixedArray<float, 6>  * pdfs_1)
{
    bool _S827 = wrongSide_0(is_inside_2, false, dir_5, surface_1->geometry_n);
    BSDF(in_dir_4, dir_5, surface_1->smooth_n, *material_14, eta_1.x, eta_1.y, _S827, *facets_1, terms_0, pdfs_1);
    float3  _S828 = make_float3 (0.0f);
    uint i_9 = 0U;
    float3  f_2 = _S828;
    for(;;)
    {
        if(i_9 < 6U)
        {
        }
        else
        {
            break;
        }
        bool _S829 = ((*pdfs_1)[i_9]) > 0.0f;
        if(_S829)
        {
            float3  _S830 = (*terms_0)[i_9] * make_float3 ((*pdfs_1)[i_9]) / make_float3 ((*pdfs_1)[i_9] + pdf_1);
            (*terms_0)[i_9] = _S830;
            float3  f_3 = f_2 + (*terms_0)[i_9];
            f_2 = f_3;
        }
        uint i_10 = i_9 + 1U;
        i_9 = i_10;
    }
    return f_2;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_6, float3  radiance_0, float3  color_0, uint random_state_2)
{
    SkySample _S831;
    (&_S831)->dir = dir_6;
    (&_S831)->radiance = radiance_0;
    (&_S831)->color = color_0;
    (&_S831)->random_state = random_state_2;
    return _S831;
}

static __device__ __noinline__ float3  skyColor_0(float3  dir_7, FixedArray<float3 , 6>  * terms_1, FixedArray<float, 6>  * pdfs_2, uint depth_1)
{
    float3  _S832 = make_float3 (0.0f);
    bool shaded_0 = false;
    float3  world_0 = _S832;
    uint i_11 = 0U;
    float3  color_1 = _S832;
    for(;;)
    {
        if(i_11 < 6U)
        {
        }
        else
        {
            break;
        }
        bool _S833 = ((*pdfs_2)[i_11]) > 0.0f;
        if(_S833)
        {
            bool _S834 = (fcptWorldReadsPath());
            bool _S835;
            if(_S834)
            {
                _S835 = true;
            }
            else
            {
                _S835 = !shaded_0;
            }
            bool shaded_1;
            float3  world_1;
            if(_S835)
            {
                bool _S836 = i_11 == 5U;
                uint _S837 = _slang_select(_S836, 5U,i_11);
                bool _S838 = i_11 == 4U;
                uint _S839 = _slang_select(_S838, 6U,_S837);
                bool _S840 = i_11 == 3U;
                uint _S841 = _slang_select(_S840, 4U,_S839);
                float3  _S842 = (fcptEnvMapSample((dir_7), (depth_1), (_S841)));
                world_1 = _S842;
                shaded_1 = true;
            }
            else
            {
                world_1 = world_0;
                shaded_1 = shaded_0;
            }
            float3  color_2 = color_1 + (*terms_1)[i_11] * world_1;
            shaded_0 = shaded_1;
            world_0 = world_1;
            color_1 = color_2;
        }
        uint i_12 = i_11 + 1U;
        i_11 = i_12;
    }
    return color_1;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_2, float wavelength_3, float2  eta_2, bool is_inside_3, uint init_random_state_0, Facets * facets_2, ShadowContext * context_2)
{
    uint2  _S843 = (fcptEnvironmentCdfSize());
    uint2  _S844 = make_uint2 (1U, 0U);
    uint2  _S845 = _S843 - _S844;
    Random _S846 = draw(init_random_state_0, 6U);
    Random _S847 = draw(init_random_state_0, 2147483654U);
    Random _S848 = draw(init_random_state_0, 7U);
    Random _S849 = draw(init_random_state_0, 2147483655U);
    uint _S850 = _S845.x;
    uint _S851 = searchCDF_0(make_uint2 (_S850, 0U), make_uint2 (0U, 1U), _S845.y, _S846.value);
    uint _S852 = searchCDF_0(make_uint2 (0U, _S851), _S844, _S850, _S847.value);
    float2  _S853 = make_float2 ((float)_S845.x, (float)_S845.y);
    float2  _S854 = (make_float2 (float(_S852), float(_S851)) + make_float2 (_S848.value, _S849.value)) / _S853 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S855 = _S854.y;
    float _S856 = (F32_sin((_S855)));
    float _S857 = _S854.x;
    float3  _S858 = make_float3 (- _S856 * (F32_cos((_S857))), _S856 * (F32_sin((_S857))), (F32_cos((_S855))));
    float _S859 = environmentPdf_0(_S858);
    BSDFMaterial _S860 = pathMaterial(surface_2->material, wavelength_3);
    BSDFMaterial _S861 = _S860;
    FixedArray<float3 , 6>  terms_2;
    FixedArray<float, 6>  pdfs_3;
    float3  _S862 = skyLobes_0(ray_0->unit_direction, _S858, surface_2, &_S861, eta_2, is_inside_3, facets_2, _S859, &terms_2, &pdfs_3);
    bool _S863 = !(_S859 > 0.0f);
    bool _S864;
    if(_S863)
    {
        _S864 = true;
    }
    else
    {
        _S864 = all_1(_S862 == make_float3 (0.0f));
    }
    if(_S864)
    {
        float3  _S865 = make_float3 (0.0f);
        return SkySample_x24init_0(_S858, _S865, _S865, _S849.state);
    }
    bool _S866 = (fcptWorldReadsPath());
    float3  seen_0;
    if(_S866)
    {
        uint _S867 = context_2->depth + 1U;
        FixedArray<float3 , 6>  _S868 = terms_2;
        FixedArray<float, 6>  _S869 = pdfs_3;
        float3  _S870 = skyColor_0(_S858, &_S868, &_S869, _S867);
        seen_0 = _S870;
    }
    else
    {
        seen_0 = _S862;
    }
    float3  _S871 = skyRadiance_0(ray_0->origin, surface_2, is_inside_3, _S858, context_2, _S849.state);
    return SkySample_x24init_0(_S858, _S871, seen_0 * _S871, _S849.state);
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

static __device__ float3  hairLight_0(FKSurface * surface_3, float3  in_dir_5, TreeSample * light_1, bool competing_0)
{
    SampleBSDF _S872 = (fcptConnectHair((surface_3->hair), ((&surface_3->material)->albedo), ((&surface_3->material)->specular_tint), (in_dir_5), (light_1->dir)));
    float3  _S873 = _S872.throughput * make_float3 (_S872.pdf);
    float _S874 = light_1->density;
    float _S875 = 1.0f + _S872.pdf * _S872.pdf / (light_1->density * light_1->density);
    bool _S876;
    if(competing_0)
    {
        _S876 = _S874 > 0.0f;
    }
    else
    {
        _S876 = false;
    }
    float _S877 = _slang_select(_S876, _S875,1.0f);
    return _S873 / make_float3 (_S877) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_8, float3  radiance_1, float density_0, uint random_state_3)
{
    TreeSample _S878;
    (&_S878)->dir = dir_8;
    (&_S878)->radiance = radiance_1;
    (&_S878)->density = density_0;
    (&_S878)->random_state = random_state_3;
    return _S878;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_12, float3  normal_4, float * pick_0, float * probability_3)
{
    float _S879 = importance(first_1, p_12, normal_4);
    float _S880 = importance(second_1, p_12, normal_4);
    float2  _S881 = make_float2 (_S879, _S880);
    bool _S882 = _S879 == 0.0f;
    bool _S883;
    if(_S882)
    {
        _S883 = _S880 == 0.0f;
    }
    else
    {
        _S883 = false;
    }
    if(_S883)
    {
        return 2U;
    }
    float _S884 = _S879 + _S880;
    bool _S885 = _S880 > 0.0f;
    if(_S885)
    {
        _S883 = (*pick_0 * _S884) >= _S879;
    }
    else
    {
        _S883 = false;
    }
    uint _S886 = uint(_S883);
    float _S887 = (F32_min(((*pick_0 * _S884 - float(_S886) * _S879) / _slang_vector_get_element(_S881, _S886)), (0.99999994039535522f)));
    *pick_0 = _S887;
    float _S888 = *probability_3 * (_slang_vector_get_element(_S881, _S886) / _S884);
    *probability_3 = _S888;
    return _S886;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_13, float u1_0, float u2_0)
{
    float3  _S889 = center_1 - p_13;
    float _S890 = radius_1 * radius_1 / dot_0(_S889, _S889);
    float _S891 = u1_0 * _S890 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S890), (0.0f)))))));
    float _S892 = 2.0f * u1_0;
    bool _S893 = _S890 >= 1.0f;
    float _S894 = _slang_select(_S893, _S892,_S891);
    float _S895 = (F32_sqrt(((F32_max((_S894 * (2.0f - _S894)), (0.0f))))));
    float _S896 = 6.28318548202514648f * u2_0;
    float3  _S897 = make_float3 (_S895 * (F32_cos((_S896))), 1.0f - _S894, _S895 * (F32_sin((_S896))));
    float3  _S898 = ((((_S889)) * make_float3(rnorm3df(((_S889)).x, ((_S889)).y, ((_S889)).z))));
    float3  _S899 = tangentToWorld(_S897, _S898);
    return _S899;
}

__device__ float3  pointLightRadiance(float3  color_3, float intensity_0, float radius_2)
{
    return color_3 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S900 = center_2 - ray_1->origin;
    float _S901 = dot_0(_S900, ray_1->unit_direction);
    float _S902 = dot_0(_S900, _S900) - _S901 * _S901;
    float _S903 = radius_3 * radius_3;
    bool _S904 = _S902 > _S903;
    if(_S904)
    {
        return 4.294967296e+09f;
    }
    float _S905 = (F32_sqrt((_S903 - _S902)));
    float _S906 = _S901 - _S905;
    float _S907 = _S901 + _S905;
    bool _S908 = _S906 > 0.0000152587890625f;
    bool _S909;
    if(_S908)
    {
        _S909 = _S906 < max_len_0;
    }
    else
    {
        _S909 = false;
    }
    if(_S909)
    {
        return _S906;
    }
    bool _S910 = _S907 > 0.0000152587890625f;
    if(_S910)
    {
        _S909 = _S907 < max_len_0;
    }
    else
    {
        _S909 = false;
    }
    if(_S909)
    {
        return _S907;
    }
    return 4.294967296e+09f;
}

static __device__ float3  mul_0(float3  left_1, Matrix<float, 3, 3>  right_1)
{
    float3  result_7;
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
        *_slang_vector_get_element_ptr(&result_7, j_1) = sum_0;
        j_1 = j_1 + int(1);
    }
    return result_7;
}

static __device__ __forceinline__ TreeSample sampleLightTree_0(float3  origin_4, float3  smooth_n_2, float3  geometry_n_1, float geometry_offset_1, bool sided_0, uint init_random_state_1, ShadowContext * context_3)
{
    Random _S911 = draw(init_random_state_1, 4U);
    Random _S912 = draw(init_random_state_1, 5U);
    Random _S913 = draw(init_random_state_1, 2147483653U);
    float3  _S914 = make_float3 (0.0f);
    TreeSample _S915 = TreeSample_x24init_0(_S914, _S914, 0.0f, _S913.state);
    TreeSample sample_0 = _S915;
    float3  _S916 = _slang_select(sided_0, _S914,smooth_n_2);
    float3  _S917 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S911.value;
    float probability_4 = 1.0f;
    uint n_7 = 0U;
    for(;;)
    {
        uint4  _S918 = (fcptLightNode((n_7)));
        if((_S918.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S919 = (fcptLightSecond((n_7)));
        uint _S920 = n_7 + 1U;
        LightNode _S921 = (fcptLightBounds((_S920)));
        LightNode _S922 = (fcptLightBounds((_S919)));
        uint _S923 = pickChild(_S921, _S922, origin_4, _S916, &pick_1, &probability_4);
        bool _S924 = _S923 > 1U;
        if(_S924)
        {
            return sample_0;
        }
        bool _S925 = _S923 == 1U;
        uint _S926 = _slang_select(_S925, _S919,_S920);
        n_7 = _S926;
    }
    bool _S927 = n_7 == 0U;
    bool _S928;
    if(_S927)
    {
        LightNode _S929 = (fcptLightBounds((0U)));
        float _S930 = importance(_S929, origin_4, _S916);
        _S928 = !(_S930 > 0.0f);
    }
    else
    {
        _S928 = false;
    }
    if(_S928)
    {
        return sample_0;
    }
    uint4  _S931 = (fcptLightNode((n_7)));
    FKHit _S932 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S933 = (_S931.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S933)
    {
        FKLight _S934 = (fcptLight((_S931.y)));
        if(sided_0)
        {
            float _S935 = sign_0(dot_0(geometry_n_1, _S934.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S935);
            float3  _S936 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S936;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S917;
            lift_n_0 = smooth_n_2;
        }
        bool _S937 = (_S934.variance) == 0.0f;
        if(_S937)
        {
            float3  _S938 = _S934.position - emitter_point_0;
            float3  _S939 = ((((_S938)) * make_float3(rnorm3df(((_S938)).x, ((_S938)).y, ((_S938)).z))));
            (&sample_0)->dir = _S939;
            float3  _S940 = _S934.color * make_float3 (_S934.intensity) / make_float3 (dot_0(_S938, _S938) * probability_4);
            (&sample_0)->radiance = _S940;
            shadow_1 = _S938;
        }
        else
        {
            float3  _S941 = sampleSphere(_S934.position, _S934.variance, emitter_point_0, _S912.value, _S913.value);
            (&sample_0)->dir = _S941;
            float _S942 = sphereDensity(_S934.position, _S934.variance, emitter_point_0);
            float _S943 = probability_4 * _S942;
            (&sample_0)->density = _S943;
            float3  _S944 = pointLightRadiance(_S934.color, _S934.intensity, _S934.variance);
            float3  _S945 = _S944 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S945;
            FKRay _S946 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S947 = raySphere_0(_S934.position, _S934.variance, &_S946, 4.294967296e+09f);
            float3  _S948 = (&sample_0)->dir * make_float3 (_S947);
            shadow_1 = _S948;
        }
        emitter_0 = _S932;
        emitter_point_0 = _S914;
    }
    else
    {
        uint _S949 = _S931.y;
        uint _S950 = (fcptTriangleOffset((_S949)));
        uint _S951 = _S950 + _S931.z;
        Matrix<float, 3, 3>  _S952 = (fcptWorldTriangle((_S949), (_S951)));
        float _S953 = (F32_sqrt((_S912.value)));
        float2  _S954 = make_float2 (_S953 * (1.0f - _S913.value), _S953 * _S913.value);
        float3  _S955 = mul_0(make_float3 (1.0f - _S953, _S954.x, _S954.y), _S952);
        if(sided_0)
        {
            float _S956 = sign_0(dot_0(geometry_n_1, _S955 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S956);
            float3  _S957 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S957;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S958 = !((dot_0(smooth_n_2, _S955 - origin_4)) > 0.0f);
            if(_S958)
            {
                return sample_0;
            }
            emitter_point_0 = _S917;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S954, _S949, _S951, 0U, 0.0f);
        float3  _S959 = _S955 - emitter_point_0;
        float3  _S960 = ((((_S959)) * make_float3(rnorm3df(((_S959)).x, ((_S959)).y, ((_S959)).z))));
        (&sample_0)->dir = _S960;
        float _S961 = solidAngle(probability_4, cross_0(_S952.rows[int(1)] - _S952.rows[int(0)], _S952.rows[int(2)] - _S952.rows[int(0)]), _S959);
        (&sample_0)->density = _S961;
        bool _S962 = (fcptShadowFirst());
        bool _S963 = !_S962;
        if(_S963)
        {
            FKSurface _S964 = (fcptLightSurfaceAt((emitter_1), (_S955), (_S913.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S955 - origin_4))));
            (&sample_0)->random_state = _S964.random_state;
            float3  _S965 = _slang_select(_S964.skip, _S914,_S964.material.emissive);
            float3  _S966 = _S965 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S966;
        }
        shadow_1 = _S959;
        emitter_0 = emitter_1;
        emitter_point_0 = _S955;
    }
    FKHit _S967 = emitter_0;
    float3  _S968 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S913.state, &_S967);
    bool _S969 = (fcptShadowFirst());
    if(_S969)
    {
        _S928 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S928 = false;
    }
    if(_S928)
    {
        _S928 = !all_1(_S968 == _S914);
    }
    else
    {
        _S928 = false;
    }
    if(_S928)
    {
        FKSurface _S970 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S913.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S970.random_state;
        float3  _S971 = _slang_select(_S970.skip, _S914,_S970.material.emissive);
        float3  _S972 = _S971 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S972;
    }
    float3  _S973 = (&sample_0)->radiance * _S968;
    bool _S974 = all_1(_S968 == _S914);
    float3  _S975 = _slang_select(_S974, _S914,_S973);
    (&sample_0)->radiance = _S975;
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

__device__ float powerHeuristic(float a_6, float b_2)
{
    float _S976 = 1.0f / (1.0f + b_2 / a_6 * (b_2 / a_6));
    bool _S977 = b_2 > 0.0f;
    float _S978 = _slang_select(_S977, _S976,1.0f);
    return _S978;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S979 = vertex_0->none;
    if(_S979)
    {
        return 1.0f;
    }
    uint _S980 = (fcptLightSlot((*hit_1)));
    float _S981 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S980, light_point_1);
    float _S982 = powerHeuristic(vertex_0->pdf, _S981);
    return _S982;
}

struct Vertex
{
    bool rough;
    uint lobe;
    float pdf;
    float cos;
    bool inside;
};

__device__ float3  pathColor(float3  f_4, float3  weight_0, float wavelength_4)
{
    float _S983 = upsample(f_4, wavelength_4);
    float3  _S984 = weight_0 * make_float3 (_S983);
    bool _S985 = wavelength_4 > 0.0f;
    float3  _S986 = _slang_select(_S985, _S984,f_4);
    return _S986;
}

__device__ float3  safeDivide(float3  a_7, float3  b_3)
{
    float3  _S987 = a_7 / b_3;
    float3  _S988 = make_float3 (0.0f);
    bool3  _S989 = b_3 == _S988;
    float3  _S990 = _slang_select(_S989, _S988,_S987);
    return _S990;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_2)
{
    uint _S991 = (1U << count_2) - 1U;
    return (e_2 & (~(_S991 << offset_1))) | ((newbits_0 & _S991) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_3, uint end_type_0, uint end_0, float3  f_5)
{
    Reservoir candidate_0 = r_3;
    uint _S992 = insertBits_0(r_3.path, end_0, 0U, 5U);
    uint _S993 = insertBits_0(_S992, end_type_0, 12U, 3U);
    (&candidate_0)->path = _S993;
    (&candidate_0)->f = f_5;
    return candidate_0;
}

static __device__ float3  abs_0(float3  x_16)
{
    float3  result_8;
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
        *_slang_vector_get_element_ptr(&result_8, i_14) = (F32_abs((_slang_vector_get_element(x_16, i_14))));
        i_14 = i_14 + int(1);
    }
    return result_8;
}

__device__ float resamplingTarget(float3  f_6)
{
    float _S994 = rgb_to_greyscale(abs_0(f_6));
    return _S994;
}

__device__ void offer(Selection * sel_2, Reservoir candidate_1, float3  weight_1)
{
    float _S995 = resamplingTarget(weight_1);
    bool _S996 = _S995 > 0.0f;
    bool _S997;
    if(_S996)
    {
        _S997 = _S995 < 3.00000000549775576e+38f;
    }
    else
    {
        _S997 = false;
    }
    bool _S998 = !_S997;
    if(_S998)
    {
        return;
    }
    bool _S999 = sel_2->sums;
    if(_S999)
    {
        float3  _S1000 = sel_2->color + weight_1;
        sel_2->color = _S1000;
        return;
    }
    float _S1001 = sel_2->w_sum + _S995;
    sel_2->w_sum = _S1001;
    float3  _S1002 = sel_2->color + weight_1;
    sel_2->color = _S1002;
    Random _S1003 = pcg(sel_2->random_state);
    sel_2->random_state = _S1003.state;
    bool _S1004 = (_S1003.value * sel_2->w_sum) <= _S995;
    if(_S1004)
    {
        sel_2->r = candidate_1;
    }
    return;
}

static __device__ Shift escape_0(Reservoir * r_4, bool replay_1, uint stop_0, uint rc_0, uint end_1, uint end_type_1, float scale_3, uint strata_0, Reservoir * chain_0, float3  chain_throughput_0, uint b_4, FKRay * ray_2, float3  throughput_0, float density_1, Vertex * prev_0, NEEVertex * nee_vertex_0, float sky_pdf_0, float3  spectral_weight_0, float wavelength_5, Selection * sel_3)
{
    Shift _S1005 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
    bool _S1006 = !nee_vertex_0->none;
    float _S1007 = _slang_select(_S1006, sky_pdf_0,0.0f);
    float3  _S1008 = ray_2->unit_direction;
    float _S1009 = escapeWeight_0(_S1007, ray_2->unit_direction);
    uint _S1010 = prev_0->lobe;
    float3  _S1011 = environment_0(_S1008, b_4, prev_0->lobe);
    float3  _S1012 = pathColor(throughput_0 * _S1011, spectral_weight_0, wavelength_5);
    if(replay_1)
    {
        bool _S1013 = b_4 == stop_0;
        bool _S1014;
        if(_S1013)
        {
            _S1014 = rc_0 == 3U;
        }
        else
        {
            _S1014 = false;
        }
        if(_S1014)
        {
            return Shift_x24init_0(_S1012 * make_float3 (_S1009) / make_float3 (r_4->jac), density_1 / r_4->jac);
        }
        bool _S1015 = rc_0 == 0U;
        if(_S1015)
        {
            _S1014 = end_type_1 == 3U;
        }
        else
        {
            _S1014 = false;
        }
        if(_S1014)
        {
            _S1014 = b_4 == end_1;
        }
        else
        {
            _S1014 = false;
        }
        if(_S1014)
        {
            _S1014 = !prev_0->rough;
        }
        else
        {
            _S1014 = false;
        }
        if(_S1014)
        {
            return Shift_x24init_0(_S1012 * make_float3 (_S1009), 1.0f);
        }
        return _S1005;
    }
    Reservoir candidate_2 = *chain_0;
    uint _S1016 = chain_0->path;
    uint _S1017 = extractBits_0(chain_0->path, 10U, 2U);
    bool _S1018 = _S1017 == 1U;
    if(_S1018)
    {
        uint _S1019 = extractBits_0(_S1016, 5U, 5U);
        bool _S1020 = _S1019 == b_4;
        float _S1021 = _slang_select(_S1020, 1.0f,_S1009);
        float3  _S1022 = safeDivide(_S1012 * make_float3 (_S1021), chain_throughput_0);
        (&candidate_2)->radiance = _S1022;
    }
    else
    {
        bool _S1023 = prev_0->rough;
        if(_S1023)
        {
            uint _S1024 = insertBits_0(strata_0, b_4 + 1U, 5U, 5U);
            uint _S1025 = insertBits_0(_S1024, 3U, 10U, 2U);
            uint _S1026 = insertBits_0(_S1025, _S1010, 15U, 3U);
            bool _S1027 = prev_0->inside;
            uint _S1028 = _slang_select(_S1027, 1U,0U);
            uint _S1029 = insertBits_0(_S1026, _S1028, 22U, 1U);
            (&candidate_2)->path = _S1029;
            (&candidate_2)->jac = prev_0->pdf;
            (&candidate_2)->dir = _S1008;
        }
    }
    float3  _S1030 = _S1012 * make_float3 (_S1009);
    Reservoir _S1031 = withEnd(candidate_2, 3U, b_4, _S1030);
    offer(sel_3, _S1031, _S1030 * make_float3 (scale_3) / make_float3 (density_1));
    return _S1005;
}

static __device__ void restir_duplicates_0(uint3  global_invocation_id_1, uint3  local_invocation_id_0, uint local_invocation_index_3)
{
    uint2  _S1032 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S1033 = make_int2 ((int)_S1032.x, (int)_S1032.y);
    uint _S1034 = previousSeed_0(_S1033);
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
            uint _S1035 = previousSeed_0(_S1033 + make_int2 (x_17, y_5));
            bool _S1036 = _S1035 == _S1034;
            uint _S1037 = _slang_select(_S1036, 1U,0U);
            uint count_4 = count_3 + _S1037;
            int x_18 = x_17 + int(1);
            x_17 = x_18;
            count_3 = count_4;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S1038 = float(count_3 - 1U) / 288.0f;
    bool _S1039 = _S1034 != 0U;
    float _S1040 = _slang_select(_S1039, _S1038,0.0f);
    fcptStoreDuplication((_S1033), (make_uint4 ((F32_asuint((_S1040))), 0U, 0U, 0U)));
    return;
}

static __device__ float4  asfloat_0(uint4  x_19)
{
    float4  result_9;
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
        *_slang_vector_get_element_ptr(&result_9, i_15) = (U32_asfloat((_slang_vector_get_element(x_19, i_15))));
        i_15 = i_15 + int(1);
    }
    return result_9;
}

__device__ void offerShifted(Selection * sel_4, Reservoir r_5, Shift shifted_0, float mis_0)
{
    Reservoir candidate_3 = r_5;
    float3  _S1041 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_3)->f = _S1041;
    float _S1042 = r_5.jac * shifted_0.jac;
    (&candidate_3)->jac = _S1042;
    offer(sel_4, candidate_3, make_float3 (mis_0) * shifted_0.f * make_float3 (r_5.w));
    return;
}

__device__ Reservoir finalize(Selection sel_5, float c_1)
{
    Reservoir r_6 = sel_5.r;
    float _S1043 = resamplingTarget((&r_6)->f);
    float _S1044 = sel_5.w_sum / _S1043;
    bool _S1045 = _S1043 > 0.0f;
    float _S1046 = _slang_select(_S1045, _S1044,0.0f);
    (&r_6)->w = _S1046;
    (&r_6)->c = c_1;
    return r_6;
}

static __device__ uint2  asuint_0(float2  x_20)
{
    uint2  result_10;
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
        *_slang_vector_get_element_ptr(&result_10, i_16) = (F32_asuint((_slang_vector_get_element(x_20, i_16))));
        i_16 = i_16 + int(1);
    }
    return result_10;
}

static __device__ void restir_spatial_0(uint3  global_invocation_id_2)
{
    uint2  _S1047 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S1048 = make_int2 ((int)_S1047.x, (int)_S1047.y);
    float3  _S1049 = make_float3 (0.0f);
    FKHit _S1050 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S1051 = Domain_x24init_0(_S1049, _S1049, &_S1050, 0.0f, 0.0f);
    Domain dom_4 = _S1051;
    bool _S1052 = (fcptCurrentDomain((_S1048), (&dom_4)));
    bool _S1053 = !_S1052;
    if(_S1053)
    {
        Reservoir _S1054 = (Reservoir{});
        fcptStoreReservoirPrevious((_S1048), (_S1054), ((&dom_4)->hit));
        return;
    }
    Reservoir _S1055 = (fcptLoadReservoirTemporal((_S1048)));
    uint t_15 = 0U;
    float count_5 = 0.0f;
    float c_sum_0 = _S1055.c;
    for(;;)
    {
        uint _S1056 = (fcptRestirNeighbours());
        if(t_15 < _S1056)
        {
        }
        else
        {
            break;
        }
        int2  _S1057 = partner_0(_S1048, t_15);
        Domain neighbor_0 = _S1051;
        bool _S1058 = (fcptCurrentDomain((_S1057), (&neighbor_0)));
        if(_S1058)
        {
            float count_6 = count_5 + 1.0f;
            uint4  _S1059 = (fcptReservoirTemporal((_S1057), (0U)));
            float c_sum_1 = c_sum_0 + (U32_asfloat((_S1059.w)));
            count_5 = count_6;
            c_sum_0 = c_sum_1;
        }
        uint t_16 = t_15 + 1U;
        t_15 = t_16;
    }
    float _S1060 = _S1055.c / (F32_max((count_5), (1.0f)));
    float _S1061 = resamplingTarget(_S1055.f);
    bool _S1062 = count_5 == 0.0f;
    float _S1063 = _slang_select(_S1062, 1.0f,0.0f);
    Selection _S1064 = (Selection{});
    Selection sel_6 = _S1064;
    uint _S1065 = (fcptFrame());
    uint _S1066 = hash(_S1065);
    uint _S1067 = global_invocation_id_2.x;
    uint2  _S1068 = (fcptRenderSize());
    uint _S1069 = stream(_S1066, _S1067 + _S1068.x * global_invocation_id_2.y);
    uint _S1070 = stream(_S1069, 195U);
    (&sel_6)->random_state = _S1070;
    t_15 = 0U;
    float canonical_mis_0 = _S1063;
    for(;;)
    {
        uint _S1071 = (fcptRestirNeighbours());
        if(t_15 < _S1071)
        {
        }
        else
        {
            break;
        }
        int2  _S1072 = partner_0(_S1048, t_15);
        Domain neighbor_dom_0 = _S1051;
        bool _S1073 = (fcptCurrentDomain((_S1072), (&neighbor_dom_0)));
        if(_S1073)
        {
            Reservoir _S1074 = (fcptLoadReservoirTemporal((_S1072)));
            uint4  _S1075 = (fcptShiftData((_S1072), (t_15)));
            float4  _S1076 = asfloat_0(_S1075);
            uint4  _S1077 = (fcptShiftData((_S1048), (t_15)));
            float4  _S1078 = asfloat_0(_S1077);
            float _S1079 = (_S1074.c + _S1060) / c_sum_0;
            bool _S1080 = _S1061 > 0.0f;
            float canonical_mis_1;
            if(_S1080)
            {
                float _S1081 = _S1079 * _S1060 * _S1061;
                float _S1082 = _S1060 * _S1061;
                float _S1083 = resamplingTarget(float3 {_S1078.x, _S1078.y, _S1078.z});
                float canonical_mis_2 = canonical_mis_0 + _S1081 / (_S1082 + _S1074.c * _S1083);
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float _S1084 = resamplingTarget(_S1074.f);
            float3  _S1085 = float3 {_S1076.x, _S1076.y, _S1076.z};
            Shift _S1086 = Shift_x24init_0(_S1085, _S1076.w);
            float _S1087 = _S1079 * _S1074.c * _S1084;
            float _S1088 = _S1074.c * _S1084;
            float _S1089 = resamplingTarget(_S1085);
            offerShifted(&sel_6, _S1074, _S1086, _S1087 / (_S1088 + _S1060 * _S1089));
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_17 = t_15 + 1U;
        t_15 = t_17;
    }
    offerShifted(&sel_6, _S1055, Shift_x24init_0(_S1055.f, 1.0f), canonical_mis_0);
    Reservoir _S1090 = finalize(sel_6, c_sum_0);
    fcptStoreReservoirPrevious((_S1048), (_S1090), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S1048), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S1048), (make_float4 ((&sel_6)->color.x, (&sel_6)->color.y, (&sel_6)->color.z, 0.0f)));
    return;
}

static __device__ uint3  asuint_1(float3  x_21)
{
    uint3  result_11;
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
        *_slang_vector_get_element_ptr(&result_11, i_17) = (F32_asuint((_slang_vector_get_element(x_21, i_17))));
        i_17 = i_17 + int(1);
    }
    return result_11;
}

static __device__ void restir_shift_0(uint3  workgroup_id_1, uint local_invocation_index_4)
{
    uint _S1091 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S1092 = _S1091 != 4294967295U;
    if(_S1092)
    {
        uint2  _S1093 = make_uint2 (_S1091, _S1091 >> 14U) & make_uint2 (16383U);
        int2  _S1094 = make_int2 ((int)_S1093.x, (int)_S1093.y);
        ShiftJob _S1095 = (ShiftJob{});
        ShiftJob shift_job_0 = _S1095;
        Shift _S1096 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S1097 = _S1091 >> 28U;
        bool _S1098 = spatialJob_0(_S1094, _S1097, &shift_job_0, true);
        Shift shifted_1;
        if(_S1098)
        {
            Domain _S1099 = (&shift_job_0)->dom;
            Reservoir _S1100 = (&shift_job_0)->r;
            Shift _S1101 = passShift_0(&_S1099, &_S1100);
            shifted_1 = _S1101;
        }
        else
        {
            shifted_1 = _S1096;
        }
        fcptStoreShiftData((_S1094), (_S1097), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S1102 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S1103 = make_int2 ((int)_S1102.x, (int)_S1102.y);
    FixedArray<uint, 3>  _S1104;
    spatialBins_0(_S1103, &_S1104);
    FixedArray<uint, 3>  _S1105 = _S1104;
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
        bool _S1106 = (_S1105[t_18]) == 40U;
        if(_S1106)
        {
            fcptStoreShiftData((_S1103), (t_18), (make_uint4 (0U)));
        }
        uint t_19 = t_18 + 1U;
        t_18 = t_19;
    }
    FixedArray<uint, 3>  _S1107 = _S1105;
    queueShifts_0(_S1103, &_S1107, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S1108 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S1109 = make_int2 ((int)_S1108.x, (int)_S1108.y);
    FixedArray<uint, 3>  _S1110;
    spatialBins_0(_S1109, &_S1110);
    FixedArray<uint, 3>  _S1111 = _S1110;
    countShifts_0(&_S1111, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S1112 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S1113 = _S1112 != 4294967295U;
    if(_S1113)
    {
        uint2  _S1114 = make_uint2 (_S1112, _S1112 >> 14U) & make_uint2 (16383U);
        int2  _S1115 = make_int2 ((int)_S1114.x, (int)_S1114.y);
        int2  _S1116 = (fcptLoadTemporalNeighbor((_S1115)));
        uint _S1117 = _S1112 >> 28U;
        Shift _S1118 = temporalShiftAt_0(_S1115, _S1116, _S1117);
        fcptStoreTemporalShift((_S1115), (_S1117), (make_uint4 (asuint_1(_S1118.f).x, asuint_1(_S1118.f).y, asuint_1(_S1118.f).z, (F32_asuint((_S1118.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S1119 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S1120 = make_int2 ((int)_S1119.x, (int)_S1119.y);
    FixedArray<uint, 3>  _S1121;
    temporalBins_0(_S1120, &_S1121);
    FixedArray<uint, 3>  _S1122 = _S1121;
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
        bool _S1123 = (_S1122[t_20]) == 40U;
        if(_S1123)
        {
            fcptStoreTemporalShift((_S1120), (t_20), (make_uint4 (0U)));
        }
        uint t_21 = t_20 + 1U;
        t_20 = t_21;
    }
    FixedArray<uint, 3>  _S1124 = _S1122;
    queueShifts_0(_S1120, &_S1124, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S1125 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S1126 = make_int2 ((int)_S1125.x, (int)_S1125.y);
    bool _S1127 = (fcptSceneUnchanged());
    bool _S1128 = !_S1127;
    bool _S1129;
    if(_S1128)
    {
        uint2  _S1130 = (fcptRenderSize());
        int2  _S1131 = make_int2 ((int)_S1130.x, (int)_S1130.y);
        _S1129 = all_0(_S1126 < _S1131);
    }
    else
    {
        _S1129 = false;
    }
    if(_S1129)
    {
        Reservoir _S1132 = (fcptLoadReservoirInitial((_S1126)));
        int2  _S1133 = sampleNeighbor_0(_S1126, _S1132.seed);
        fcptStoreTemporalNeighbor((_S1126), (_S1133));
    }
    FixedArray<uint, 3>  _S1134;
    temporalBins_0(_S1126, &_S1134);
    FixedArray<uint, 3>  _S1135 = _S1134;
    countShifts_0(&_S1135, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_8, float b_5, float t_22)
{
    return a_8 + (b_5 - a_8) * t_22;
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S1136 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S1137 = make_int2 ((int)_S1136.x, (int)_S1136.y);
    float3  _S1138 = make_float3 (0.0f);
    FKHit _S1139 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S1140 = Domain_x24init_0(_S1138, _S1138, &_S1139, 0.0f, 0.0f);
    Domain dom_5 = _S1140;
    bool _S1141 = (fcptCurrentDomain((_S1137), (&dom_5)));
    bool _S1142 = !_S1141;
    if(_S1142)
    {
        Reservoir _S1143 = (Reservoir{});
        fcptStoreReservoirTemporal((_S1137), (_S1143), ((&dom_5)->hit));
        return;
    }
    Reservoir _S1144 = (fcptLoadReservoirInitial((_S1137)));
    bool _S1145 = (fcptTemporalQueued());
    bool _S1146 = (fcptSceneUnchanged());
    bool _S1147;
    if(_S1146)
    {
        _S1147 = true;
    }
    else
    {
        _S1147 = !_S1145;
    }
    int2  _S1148;
    if(_S1147)
    {
        int2  _S1149 = sampleNeighbor_0(_S1137, _S1144.seed);
        _S1148 = _S1149;
    }
    else
    {
        int2  _S1150 = (fcptLoadTemporalNeighbor((_S1137)));
        _S1148 = _S1150;
    }
    bool _S1151 = (_S1148.x) >= int(0);
    Reservoir r_7;
    if(_S1151)
    {
        Reservoir _S1152 = (fcptLoadReservoirPrevious((_S1148)));
        uint4  _S1153 = (fcptDuplication((_S1148)));
        float _S1154 = (U32_asfloat((_S1153.x)));
        uint _S1155 = (fcptRestirDecorrelation());
        bool _S1156 = _S1155 == 1U;
        float _S1157 = _slang_select(_S1156, _S1154,0.0f);
        float _S1158 = interpolate_0(20.0f, 1.0f, (F32_pow((_S1157), (0.10000000149011612f))));
        float _S1159 = (F32_min((_S1152.c), (_S1158)));
        bool _S1160 = (fcptSceneUnchanged());
        float4  _S1161 = make_float4 (_S1152.f.x, _S1152.f.y, _S1152.f.z, 1.0f);
        bool _S1162 = !_S1160;
        if(_S1162)
        {
            _S1147 = _S1145;
        }
        else
        {
            _S1147 = false;
        }
        float4  to_current_0;
        if(_S1147)
        {
            uint4  _S1163 = (fcptTemporalShift((_S1137), (0U)));
            float4  _S1164 = asfloat_0(_S1163);
            to_current_0 = _S1164;
        }
        else
        {
            if(_S1162)
            {
                Shift _S1165 = temporalShiftAt_0(_S1137, _S1148, 0U);
                float4  _S1166 = make_float4 (_S1165.f.x, _S1165.f.y, _S1165.f.z, _S1165.jac);
                to_current_0 = _S1166;
            }
            else
            {
                to_current_0 = _S1161;
            }
        }
        Domain own_1 = _S1140;
        if(_S1160)
        {
            _S1147 = true;
        }
        else
        {
            bool _S1167 = (fcptPreviousScenes());
            bool _S1168 = !_S1167;
            if(_S1168)
            {
                _S1147 = (_S1144.w) > 0.0f;
            }
            else
            {
                _S1147 = false;
            }
            if(_S1147)
            {
                bool _S1169 = (fcptStoredDomainInitial((_S1137), (_S1144.seed), (&own_1)));
                _S1147 = _S1169;
            }
            else
            {
                _S1147 = false;
            }
            if(_S1147)
            {
                Domain _S1170 = (fcptPreviousDomain((_S1148), (_S1144.seed)));
                Domain _S1171 = _S1170;
                Domain _S1172 = own_1;
                bool _S1173 = sameDomain_0(&_S1171, &_S1172);
                _S1147 = _S1173;
            }
            else
            {
                _S1147 = false;
            }
        }
        float4  _S1174 = make_float4 (_S1144.f.x, _S1144.f.y, _S1144.f.z, 1.0f);
        bool _S1175 = !_S1147;
        if(_S1175)
        {
            _S1147 = _S1145;
        }
        else
        {
            _S1147 = false;
        }
        float4  to_previous_0;
        if(_S1147)
        {
            uint4  _S1176 = (fcptTemporalShift((_S1137), (1U)));
            float4  _S1177 = asfloat_0(_S1176);
            to_previous_0 = _S1177;
        }
        else
        {
            if(_S1175)
            {
                Shift _S1178 = temporalShiftAt_0(_S1137, _S1148, 1U);
                float4  _S1179 = make_float4 (_S1178.f.x, _S1178.f.y, _S1178.f.z, _S1178.jac);
                to_previous_0 = _S1179;
            }
            else
            {
                to_previous_0 = _S1174;
            }
        }
        float _S1180 = resamplingTarget(_S1144.f);
        float _S1181 = resamplingTarget(_S1152.f);
        Selection _S1182 = (Selection{});
        Selection sel_7 = _S1182;
        uint _S1183 = (fcptFrame());
        uint _S1184 = hash(_S1183);
        uint _S1185 = global_invocation_id_7.x;
        uint2  _S1186 = (fcptRenderSize());
        uint _S1187 = stream(_S1184, _S1185 + _S1186.x * global_invocation_id_7.y);
        uint _S1188 = stream(_S1187, 194U);
        (&sel_7)->random_state = _S1188;
        float _S1189 = _S1144.c * _S1180;
        float4  _S1190 = to_previous_0;
        float _S1191 = resamplingTarget(float3 {_S1190.x, _S1190.y, _S1190.z});
        float _S1192 = _S1189 / (_S1189 + _S1159 * _S1191);
        float _S1193 = _S1159 * _S1181;
        float4  _S1194 = to_current_0;
        float3  _S1195 = float3 {_S1194.x, _S1194.y, _S1194.z};
        float _S1196 = resamplingTarget(_S1195);
        float _S1197 = _S1193 / (_S1193 + _S1144.c * _S1196);
        float2  _S1198 = make_float2 (_S1192, _S1197);
        offerShifted(&sel_7, _S1144, Shift_x24init_0(_S1144.f, 1.0f), _S1192);
        offerShifted(&sel_7, _S1152, Shift_x24init_0(_S1195, to_current_0.w), _S1197);
        Reservoir _S1199 = finalize(sel_7, _S1144.c + _S1159);
        r_7 = _S1199;
    }
    else
    {
        r_7 = _S1144;
    }
    fcptStoreReservoirTemporal((_S1137), (r_7), ((&dom_5)->hit));
    return;
}

__device__ uint noiseOrigin(uint2  p_14, uint k_1)
{
    uint _S1200 = ((p_14.x) >> 11U) | (((p_14.y) >> 11U) << 4U);
    uint2  _S1201 = noiseOffset(8192U + (k_1 >> 10U) + (_S1200 << 20U));
    uint2  _S1202 = (p_14 + _S1201) & make_uint2 (2047U);
    return ((_S1202.x) | ((_S1202.y) << 11U)) | ((k_1 & 1023U) << 22U);
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S1203 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S1204 = make_int2 ((int)_S1203.x, (int)_S1203.y);
    float3  _S1205 = make_float3 (0.0f);
    float2  _S1206 = make_float2 (0.0f);
    FKHit _S1207 = Hit_x24init_0(_S1206, 0U, 0U, 0U, 0.0f);
    Domain _S1208 = Domain_x24init_0(_S1205, _S1205, &_S1207, 0.0f, 0.0f);
    Domain dom_6 = _S1208;
    bool _S1209 = (fcptCurrentDomain((_S1204), (&dom_6)));
    bool _S1210 = !_S1209;
    if(_S1210)
    {
        Reservoir _S1211 = (Reservoir{});
        fcptStoreReservoirInitial((_S1204), (_S1211), ((&dom_6)->hit));
        return;
    }
    uint _S1212 = (fcptFrame());
    uint _S1213 = hash(_S1212);
    uint _S1214 = global_invocation_id_8.x;
    uint2  _S1215 = (fcptRenderSize());
    uint _S1216 = global_invocation_id_8.y;
    uint _S1217 = stream(_S1213, _S1214 + _S1215.x * _S1216);
    uint2  _S1218 = (fcptRenderSize());
    uint _S1219 = stream(_S1214 + _S1218.x * _S1216, 512U);
    Selection _S1220 = (Selection{});
    Selection initial_0 = _S1220;
    uint _S1221 = stream(_S1217, 193U);
    (&initial_0)->random_state = _S1221;
    bool _S1222 = (fcptRestirUsed());
    bool _S1223 = !_S1222;
    (&initial_0)->sums = _S1223;
    uint _S1224 = stream(_S1217, 0U);
    (&(&initial_0)->r)->seed = _S1224;
    FKHit _S1225 = Hit_x24init_0(_S1206, 4294967295U, 0U, 0U, 0.0f);
    uint _S1226 = (fcptSamples());
    float _S1227 = 1.0f / float(_S1226);
    FKHit hit_2 = _S1225;
    uint i_18 = 0U;
    float3  seen_1 = _S1205;
    for(;;)
    {
        uint _S1228 = (fcptSamples());
        if(i_18 < _S1228)
        {
        }
        else
        {
            break;
        }
        Reservoir _S1229 = (Reservoir{});
        Reservoir r_8 = _S1229;
        uint _S1230 = (fcptFrame());
        uint _S1231 = (fcptSamples());
        uint _S1232 = _S1230 * _S1231 + i_18;
        uint _S1233 = noiseOrigin(_S1203, _S1232);
        (&r_8)->seed = _S1233;
        uint _S1234 = insertBits_0(0U, 1U, 24U, 1U);
        uint _S1235 = insertBits_0(_S1234, (_S1219 + _S1232 * 2654435769U) >> 25U, 25U, 7U);
        (&r_8)->path = _S1235;
        Domain path_0 = _S1208;
        bool _S1236 = (fcptStoredDomainInitial((_S1204), ((&r_8)->seed), (&path_0)));
        bool _S1237 = !_S1236;
        if(_S1237)
        {
            float3  _S1238 = (fcptMissed((_S1204), (path_0), (_S1227)));
            float3  seen_2 = seen_1 + _S1238;
            seen_1 = seen_2;
            uint i_19 = i_18 + 1U;
            i_18 = i_19;
            continue;
        }
        Domain _S1239 = path_0;
        Reservoir _S1240 = r_8;
        Shift _S1241 = passWalk_0(&_S1239, &_S1240, false, _S1227, &initial_0);
        bool _S1242 = ((&(&initial_0)->r)->seed) == ((&r_8)->seed);
        FKHit hit_3;
        if(_S1242)
        {
            FKHit _S1243 = (&path_0)->hit;
            hit_3 = _S1243;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_19 = i_18 + 1U;
        i_18 = i_19;
    }
    uint _S1244 = (fcptSamples());
    float3  seen_3 = seen_1 + (&initial_0)->glow / make_float3 (float(_S1244));
    float3  _S1245 = seen_3 + (&initial_0)->color;
    bool _S1246 = (&initial_0)->sums;
    float3  _S1247 = _slang_select(_S1246, _S1245,seen_3);
    fcptAddColor((_S1204), (make_float4 (_S1247.x, _S1247.y, _S1247.z, 1.0f)));
    Reservoir _S1248 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S1204), (_S1248), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_2, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S1249;
    (&_S1249)->none = none_0;
    (&_S1249)->pdf = pdf_2;
    (&_S1249)->origin = origin_5;
    (&_S1249)->smooth_n = smooth_n_3;
    (&_S1249)->start = start_6;
    return _S1249;
}

static __device__ Vertex Vertex_x24init_0(bool rough_0, uint lobe_1, float pdf_3, float cos_0, bool inside_0)
{
    Vertex _S1250;
    (&_S1250)->rough = rough_0;
    (&_S1250)->lobe = lobe_1;
    (&_S1250)->pdf = pdf_3;
    (&_S1250)->cos = cos_0;
    (&_S1250)->inside = inside_0;
    return _S1250;
}

__device__ uint noiseAddress(uint origin_6, uint bounce_0)
{
    uint2  _S1251 = make_uint2 (origin_6 & 2047U, (origin_6 >> 11U) & 2047U);
    uint2  _S1252 = noiseOffset(64U + bounce_0 * 17U);
    uint2  _S1253 = (_S1251 + _S1252) & make_uint2 (2047U);
    return ((_S1253.x) | ((_S1253.y) << 11U)) | ((origin_6 >> 22U) << 22U);
}

static __device__ float3  exp_0(float3  x_22)
{
    float3  result_12;
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
        *_slang_vector_get_element_ptr(&result_12, i_20) = (F32_exp((_slang_vector_get_element(x_22, i_20))));
        i_20 = i_20 + int(1);
    }
    return result_12;
}

static __device__ float3  flightWeight_0(float3  scatter_0, float3  extinction_0, float distance_2, bool scatters_0)
{
    float3  _S1254 = exp_0(- scatter_0 * make_float3 (distance_2));
    float3  _S1255 = make_float3 (3.0f) * exp_0(- extinction_0 * make_float3 (distance_2));
    float3  _S1256 = _S1255 / make_float3 (_S1254.x + _S1254.y + _S1254.z);
    float3  _S1257 = scatter_0 * _S1255 / make_float3 (dot_0(scatter_0, _S1254));
    float3  _S1258 = _slang_select(scatters_0, _S1257,_S1256);
    return _S1258;
}

static __device__ uint arrivalLobe_0(uint b_6, uint prev_lobe_0)
{
    bool _S1259 = b_6 > 0U;
    uint _S1260 = _slang_select(_S1259, prev_lobe_0,3U);
    return _S1260;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_1, uint depth_2, uint lobe_2, bool surface_4, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S1261;
    (&_S1261)->extinction_behind = extinction_behind_0;
    (&_S1261)->extinction_front = extinction_front_0;
    (&_S1261)->fillings = fillings_0;
    (&_S1261)->side = side_1;
    (&_S1261)->depth = depth_2;
    (&_S1261)->lobe = lobe_2;
    (&_S1261)->surface = surface_4;
    (&_S1261)->length = length_2;
    (&_S1261)->width = width_1;
    (&_S1261)->own = *own_2;
    (&_S1261)->fiber = fiber_0;
    return _S1261;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S1262 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S1262)
    {
        return 0.07957746833562851f;
    }
    float _S1263 = g_0 * g_0;
    return (1.0f - _S1263) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S1263 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float survivalProbability(float3  throughput_1, float density_2)
{
    return (F32_min(((F32_max(((F32_max((throughput_1.x), ((F32_max((throughput_1.y), (throughput_1.z)))))) / density_2), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_4)
{
    Random _S1264 = draw(random_state_4, 11U);
    Random _S1265 = draw(random_state_4, 2147483659U);
    float _S1266 = 1.0f - 2.0f * _S1264.value;
    float _S1267 = (F32_sqrt(((F32_max((1.0f - _S1266 * _S1266), (0.0f))))));
    float _S1268 = 6.28318548202514648f * _S1265.value;
    return make_float3 (_S1267 * (F32_cos((_S1268))), _S1267 * (F32_sin((_S1268))), _S1266);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_9, uint random_state_5, float * pdf_4)
{
    bool _S1269 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1269)
    {
        *pdf_4 = 0.07957746833562851f;
        float3  _S1270 = isotropic_0(random_state_5);
        return _S1270;
    }
    Random _S1271 = draw(random_state_5, 11U);
    Random _S1272 = draw(random_state_5, 2147483659U);
    float _S1273 = g_1 * g_1;
    float _S1274 = 2.0f * g_1;
    float _S1275 = (1.0f - _S1273) / (1.0f - g_1 + _S1274 * _S1271.value);
    float _S1276 = clamp_1((1.0f + _S1273 - _S1275 * _S1275) / _S1274, -1.0f, 1.0f);
    float _S1277 = (F32_sqrt(((F32_max((1.0f - _S1276 * _S1276), (0.0f))))));
    float _S1278 = 6.28318548202514648f * _S1272.value;
    float _S1279 = phaseHG_0(g_1, _S1276);
    *pdf_4 = _S1279;
    float3  _S1280 = tangentToWorld(make_float3 (_S1277 * (F32_cos((_S1278))), _S1276, _S1277 * (F32_sin((_S1278)))), dir_9);
    float3  _S1281 = ((((_S1280)) * make_float3(rnorm3df(((_S1280)).x, ((_S1280)).y, ((_S1280)).z))));
    return _S1281;
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_1, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_1, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_1, float velvet_0, float3  toon_2, float dispersion_0, float coat_2, float coat_roughness_0, float coat_ior_0, float3  coat_tint_0, float3  coat_normal_0)
{
    BSDFMaterial _S1282;
    (&_S1282)->albedo = albedo_1;
    (&_S1282)->emissive = emissive_0;
    (&_S1282)->roughness = roughness_0;
    (&_S1282)->metallic = metallic_0;
    (&_S1282)->transmission = transmission_0;
    (&_S1282)->ior = ior_1;
    (&_S1282)->absorption = absorption_0;
    (&_S1282)->specular_tint = specular_tint_0;
    (&_S1282)->specular_level = specular_level_0;
    (&_S1282)->translucent = translucent_0;
    (&_S1282)->sheen = sheen_2;
    (&_S1282)->sheen_roughness = sheen_roughness_0;
    (&_S1282)->anisotropy = anisotropy_0;
    (&_S1282)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1282)->tangent = tangent_1;
    (&_S1282)->velvet = velvet_0;
    (&_S1282)->toon = toon_2;
    (&_S1282)->dispersion = dispersion_0;
    (&_S1282)->coat = coat_2;
    (&_S1282)->coat_roughness = coat_roughness_0;
    (&_S1282)->coat_ior = coat_ior_0;
    (&_S1282)->coat_tint = coat_tint_0;
    (&_S1282)->coat_normal = coat_normal_0;
    return _S1282;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1283;
    (&_S1283)->scatter = scatter_1;
    (&_S1283)->extinction = extinction_1;
    (&_S1283)->g = g_2;
    return _S1283;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_15, bool skip_0, uint random_state_6, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1284;
    (&_S1284)->smooth_n = smooth_n_4;
    (&_S1284)->geometry_n = geometry_n_2;
    (&_S1284)->geometry_offset = geometry_offset_2;
    (&_S1284)->material = *material_15;
    (&_S1284)->skip = skip_0;
    (&_S1284)->random_state = random_state_6;
    (&_S1284)->coverage = coverage_0;
    (&_S1284)->encloses = encloses_0;
    (&_S1284)->volume = *volume_0;
    (&_S1284)->fills = fills_0;
    (&_S1284)->hair = hair_0;
    return _S1284;
}

static __device__ FKSurface emitting_0(FKSurface * surface_5, bool top_0)
{
    FKSurface lower_0 = *surface_5;
    float3  _S1285 = (&surface_5->material)->emissive;
    float3  _S1286 = make_float3 (0.0f);
    bool _S1287 = !top_0;
    float3  _S1288 = _slang_select(_S1287, _S1286,_S1285);
    (&(&lower_0)->material)->emissive = _S1288;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_6, float u_1)
{
    float _S1289 = surface_6->coverage;
    bool _S1290 = u_1 < _S1289;
    if(_S1290)
    {
        return *surface_6;
    }
    float3  _S1291 = make_float3 (0.0f);
    float3  _S1292 = make_float3 (1.0f);
    BSDFMaterial _S1293 = Material_x24init_0(_S1291, _S1291, 0.0f, 0.0f, 0.0f, 0.0f, _S1291, _S1292, 1.0f, _S1291, _S1291, 0.5f, 0.0f, 0.0f, _S1291, 0.0f, _S1291, 0.0f, 0.0f, 0.02999999932944775f, 1.5f, _S1292, _S1291);
    BSDFMaterial material_16 = _S1293;
    (&material_16)->albedo = _S1292;
    (&material_16)->emissive = (&surface_6->material)->emissive;
    (&material_16)->transmission = 1.0f;
    (&material_16)->ior = 1.0f;
    (&material_16)->absorption = (&surface_6->material)->absorption;
    FKSurface through_1 = *surface_6;
    (&through_1)->material = material_16;
    return through_1;
}

__device__ float facingSign(float transmission_1, float3  face_0, float3  direction_0)
{
    bool _S1294 = transmission_1 > 0.0f;
    bool _S1295;
    if(_S1294)
    {
        _S1295 = true;
    }
    else
    {
        _S1295 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1296 = _slang_select(_S1295, 1.0f,-1.0f);
    return _S1296;
}

static __device__ bool arrivesBehind_0(float3  dir_10, float3  n_8)
{
    return (dot_0(dir_10, n_8)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_7, float3  dir_11)
{
    float3  _S1297 = surface_7->geometry_n;
    float _S1298 = facingSign((&surface_7->material)->transmission, surface_7->geometry_n, dir_11);
    FKSurface faced_0 = *surface_7;
    float3  _S1299 = surface_7->smooth_n * make_float3 (_S1298);
    (&faced_0)->smooth_n = _S1299;
    float3  _S1300 = _S1297 * make_float3 (_S1298);
    (&faced_0)->geometry_n = _S1300;
    return faced_0;
}

static __device__ float3  max_0(float3  x_23, float3  y_7)
{
    float3  result_13;
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
        *_slang_vector_get_element_ptr(&result_13, i_21) = (F32_max((_slang_vector_get_element(x_23, i_21)), (_slang_vector_get_element(y_7, i_21))));
        i_21 = i_21 + int(1);
    }
    return result_13;
}

static __device__ float3  log_0(float3  x_24)
{
    float3  result_14;
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
        *_slang_vector_get_element_ptr(&result_14, i_22) = (F32_log((_slang_vector_get_element(x_24, i_22))));
        i_22 = i_22 + int(1);
    }
    return result_14;
}

__device__ float3  beerLambert(float distance_3, float3  absorption_1)
{
    float3  _S1301 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1301));
}

__device__ bool dispersive(BSDFMaterial material_17)
{
    bool _S1302 = (material_17.dispersion) > 0.0f;
    bool _S1303;
    if(_S1302)
    {
        _S1303 = (material_17.ior) != 1.0f;
    }
    else
    {
        _S1303 = false;
    }
    return _S1303;
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
        uint _S1304 = (low_1 + high_1 + 1U) / 2U;
        bool _S1305 = (WAVELENGTH_CDF_0[_S1304]) <= u_2;
        if(_S1305)
        {
            low_1 = _S1304;
        }
        else
        {
            uint _S1306 = _S1304 - 1U;
            high_1 = _S1306;
        }
    }
    uint _S1307 = low_1;
    float _S1308 = WAVELENGTH_CDF_0[low_1 + 1U] - WAVELENGTH_CDF_0[low_1];
    return make_float2 (0.37999999523162842f + 0.00499999988824129f * (float(low_1) + (u_2 - WAVELENGTH_CDF_0[_S1307]) / _S1308), _S1308 / 0.00499999988824129f);
}

__device__ static const FixedArray<float, 243>  WAVELENGTH_WEIGHTS_0 = { {
    0.00547470012679696f, -0.00465690018609166f, 0.03257500007748604f, 0.00934640038758516f, -0.00796370021998882f, 0.05577300116419792f, 0.01846100017428398f, -0.01579399965703487f, 0.11072999984025955f, 0.0416410006582737f, -0.03577499836683273f, 0.2513900101184845f, 0.09349299967288971f, -0.08071800321340561f, 0.56742000579833984f, 0.1585099995136261f, -0.13764999806880951f, 0.97018998861312866f, 0.30943000316619873f, -0.27083000540733337f, 1.91740000247955322f, 0.55217999219894409f, -0.48754000663757324f, 3.46889996528625488f, 0.95016998052597046f, -0.84802001714706421f, 6.09439992904663086f, 1.42110002040863037f, -1.28929996490478516f, 9.45199966430664062f, 1.73409998416900635f, -1.6062999963760376f, 12.12800025939941406f, 2.08030009269714355f, -1.98810005187988281f, 15.68700027465820312f, 2.20600008964538574f, -2.20120000839233398f, 18.47699928283691406f, 2.03040003776550293f, -2.17700004577636719f, 19.92700004577636719f, 1.63429999351501465f, -2.00340008735656738f, 20.86899948120117188f, 0.99410998821258545f, -1.62629997730255127f, 20.57799911499023438f, 0.20011000335216522f, -1.11409997940063477f, 19.72100067138671875f, -0.67960000038146973f, -0.45403000712394714f, 17.77599906921386719f, -1.61679995059967041f, 0.37860000133514404f, 14.71500015258789062f, -2.53410005569458008f, 1.27540004253387451f, 11.86499977111816406f, -3.39079999923706055f, 2.2146000862121582f, 9.17669963836669922f, -4.03749990463256836f, 3.0522000789642334f, 6.59509992599487305f, -4.61299991607666016f, 3.89779996871948242f, 4.64589977264404297f, -5.43039989471435547f, 5.0121002197265625f, 3.3199000358581543f, -6.37769985198974609f, 6.33809995651245117f, 2.29699993133544922f, -7.44140005111694336f, 7.91739988327026367f, 1.45389997959136963f, -8.38580036163330078f, 9.60109996795654297f, 0.66465997695922852f, -9.0167999267578125f, 11.23999977111816406f, -0.04403600096702576f, -9.17749977111816406f, 12.63199996948242188f, -0.58126997947692871f, -8.97550010681152344f, 13.91499996185302734f, -0.95730000734329224f, -8.25290012359619141f, 14.86200046539306641f, -1.24430000782012939f, -6.92129993438720703f, 15.03899955749511719f, -1.43069994449615479f, -5.29169988632202148f, 14.90900039672851562f, -1.55149996280670166f, -3.43219995498657227f, 14.70499992370605469f, -1.63569998741149902f, -1.27190005779266357f, 14.24400043487548828f, -1.67030000686645508f, 1.15170001983642578f, 13.32199954986572266f, -1.636199951171875f, 3.73889994621276855f, 12.21199989318847656f, -1.56920003890991211f, 6.43590021133422852f, 10.94699954986572266f, -1.47730004787445068f, 9.16440010070800781f, 9.54769992828369141f, -1.36399996280670166f, 12.02000045776367188f, 8.18799972534179688f, -1.25450003147125244f, 14.78699970245361328f, 6.74429988861083984f, -1.13110005855560303f, 16.72299957275390625f, 5.08780002593994141f, -0.96561002731323242f, 18.14299964904785156f, 3.57019996643066406f, -0.80725997686386108f, 19.91900062561035156f, 2.36269998550415039f, -0.69273000955581665f, 21.05500030517578125f, 1.31369996070861816f, -0.58597999811172485f, 21.3899993896484375f, 0.42390000820159912f, -0.48298001289367676f, 20.99300003051757812f, -0.23857000470161438f, -0.39412000775337219f, 19.82200050354003906f, -0.6866300106048584f, -0.31501999497413635f, 18.12000083923339844f, -0.9412500262260437f, -0.24890999495983124f, 15.7089996337890625f, -1.02020001411437988f, -0.19076000154018402f, 13.19799995422363281f, -0.98919999599456787f, -0.14401000738143921f, 11.23999977111816406f, -0.93347001075744629f, -0.11133000254631042f, 9.36649990081787109f, -0.83820998668670654f, -0.08524099737405777f, 7.41249990463256836f, -0.70064002275466919f, -0.06283199787139893f, 5.71229982376098633f, -0.56079000234603882f, -0.04586699977517128f, 4.42280006408691406f, -0.44653001427650452f, -0.03396600112318993f, 3.34489989280700684f, -0.34457001090049744f, -0.02482499927282333f, 2.49309992790222168f, -0.26017999649047852f, -0.01808100007474422f, 1.82239997386932373f, -0.1921599954366684f, -0.01296999957412481f, 1.29499995708465576f, -0.13766999542713165f, -0.00907570030540228f, 0.92928999662399292f, -0.09956400096416473f, -0.00641620019450784f, 0.61835998296737671f, -0.06671299785375595f, -0.00421149982139468f, 0.40211999416351318f, -0.04354599863290787f, -0.00271830009296536f, 0.2844499945640564f, -0.03087200038135052f, -0.00191440002527088f, 0.20672999322414398f, -0.02246100082993507f, -0.00138829997740686f, 0.15044000744819641f, -0.01634499989449978f, -0.00101030000951141f, 0.10942000150680542f, -0.01188699994236231f, -0.0007347899954766f, 0.07099699974060059f, -0.00771349994465709f, -0.00047679000999779f, 0.04539500176906586f, -0.00493190018460155f, -0.00030484999297187f, 0.03424099832773209f, -0.00372010003775358f, -0.00022995000472292f, 0.02557599917054176f, -0.00277870008721948f, -0.00017175999528263f, 0.01842200011014938f, -0.00200140010565519f, -0.0001237099932041f, 0.01316899992525578f, -0.00143079995177686f, -0.00008843900286593f, 0.00838890019804239f, -0.00091141002485529f, -0.00005633700129692f, 0.00537079991772771f, -0.00058350997278467f, -0.00003606799873523f, 0.00328280008397996f, -0.00035665999166667f, -0.00002204600059486f, 0.00196009990759194f, -0.00021296000340953f, -0.00001316300040344f, 0.00168939994182438f, -0.00018354000349063f, -0.00001134499962063f, 0.00141050003003329f, -0.00015325000276789f, -0.00000947250009631f, 0.00097123999148607f, -0.00010551999730524f, -6.52239987175562419e-06f, 0.00066868000430986f, -0.00007264900341397f, -4.49060007667867467e-06f
} };
__device__ float3  wavelengthWeights(float wavelength_6)
{
    float _S1309 = clamp_1((wavelength_6 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    uint _S1310 = (U32_min((uint(_S1309)), (79U)));
    uint _S1311 = 3U * _S1310;
    float3  _S1312 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1311], WAVELENGTH_WEIGHTS_0[_S1311 + 1U], WAVELENGTH_WEIGHTS_0[_S1311 + 2U]);
    float3  _S1313 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1311 + 3U], WAVELENGTH_WEIGHTS_0[_S1311 + 4U], WAVELENGTH_WEIGHTS_0[_S1311 + 5U]);
    return _S1312 + (_S1313 - _S1312) * make_float3 (_S1309 - float(_S1310));
}

__device__ float dispersedIor(float ior_2, float dispersion_1, float wavelength_7)
{
    float _S1314 = (ior_2 - 1.0f) * dispersion_1 / 1.90962409973144531f;
    float _S1315 = _S1314 * (1.0f / (wavelength_7 * wavelength_7) - 2.89662933349609375f);
    bool _S1316 = dispersion_1 > 0.0f;
    float _S1317 = _slang_select(_S1316, _S1315,0.0f);
    return ior_2 + _S1317;
}

__device__ float2  vertexEta(BSDFMaterial material_18, float n_dot_v_0)
{
    bool _S1318 = n_dot_v_0 < 0.0f;
    float _S1319 = _slang_select(_S1318, material_18.ior,1.0f);
    float _S1320 = _slang_select(_S1318, 1.0f,material_18.ior);
    return make_float2 (_S1319, _S1320);
}

__device__ float2  wavelengthEta(BSDFMaterial material_19, float n_dot_v_1, float wavelength_8)
{
    BSDFMaterial refractive_0 = material_19;
    float _S1321 = dispersedIor(material_19.ior, material_19.dispersion, wavelength_8);
    bool _S1322 = wavelength_8 > 0.0f;
    float _S1323 = _slang_select(_S1322, _S1321,material_19.ior);
    (&refractive_0)->ior = _S1323;
    float2  _S1324 = vertexEta(refractive_0, n_dot_v_1);
    return _S1324;
}

static __device__ float unshared_0(float x_25)
{
    return x_25;
}

__device__ float3  sampleGGXVNDF(float3  Ve_0, float alpha_5, float U1_0, float U2_0)
{
    float3  _S1325 = make_float3 (alpha_5 * Ve_0.x, alpha_5 * Ve_0.y, Ve_0.z);
    float3  _S1326 = ((((_S1325)) * make_float3(rnorm3df(((_S1325)).x, ((_S1325)).y, ((_S1325)).z))));
    float _S1327 = _S1326.x;
    float _S1328 = _S1326.y;
    float _S1329 = _S1327 * _S1327 + _S1328 * _S1328;
    float3  _S1330 = make_float3 (1.0f, 0.0f, 0.0f);
    float3  _S1331 = make_float3 (- _S1328, _S1327, 0.0f);
    float _S1332 = (rsqrtf((_S1329)));
    float3  _S1333 = _S1331 * make_float3 (_S1332);
    bool _S1334 = _S1329 > 0.0f;
    float3  _S1335 = _slang_select(_S1334, _S1333,_S1330);
    float3  _S1336 = cross_0(_S1326, _S1335);
    float _S1337 = (F32_sqrt((U1_0)));
    float _S1338 = 6.28318548202514648f * U2_0;
    float _S1339 = _S1337 * (F32_cos((_S1338)));
    float t2_0 = _S1337 * (F32_sin((_S1338)));
    float _S1340 = 0.5f * (1.0f + _S1326.z);
    float t2_1 = (1.0f - _S1340) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S1339 * _S1339)))))) + _S1340 * t2_0;
    float3  _S1341 = make_float3 (_S1339) * _S1335 + make_float3 (t2_1) * _S1336;
    float _S1342 = unshared_0(_S1339);
    float _S1343 = unshared_0(_S1339);
    float3  _S1344 = _S1341 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S1342 * _S1343 - t2_1 * t2_1))))))) * _S1326;
    float3  _S1345 = make_float3 (alpha_5 * _S1344.x, alpha_5 * _S1344.y, (F32_max((0.0f), (_S1344.z))));
    float3  _S1346 = ((((_S1345)) * make_float3(rnorm3df(((_S1345)).x, ((_S1345)).y, ((_S1345)).z))));
    return _S1346;
}

__device__ float3  worldToTangent(float3  v_8, float3  n_9)
{
    float3  a_9 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S1347 = (F32_abs((dot_0(n_9, a_9)))) > 0.9999847412109375f;
    float3  a_10;
    if(_S1347)
    {
        float3  _S1348 = make_float3 (1.0f, 0.0f, 0.0f);
        a_10 = _S1348;
    }
    else
    {
        a_10 = a_9;
    }
    float3  _S1349 = cross_0(n_9, a_10);
    float3  _S1350 = ((((_S1349)) * make_float3(rnorm3df(((_S1349)).x, ((_S1349)).y, ((_S1349)).z))));
    float3  _S1351 = cross_0(n_9, _S1350);
    return make_float3 (dot_0(v_8, _S1350), dot_0(v_8, n_9), dot_0(v_8, _S1351));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_9, float3  n_i_10, float alpha_6, AnisotropicFrame frame_4, uint * random_state_7, uint first_2)
{
    Random _S1352 = draw(*random_state_7, first_2);
    Random _S1353 = draw(*random_state_7, first_2 | 2147483648U);
    *random_state_7 = _S1353.state;
    float _S1354 = frame_4.alphas.x;
    bool _S1355 = _S1354 > 0.0f;
    if(_S1355)
    {
        float3  _S1356 = anisotropicLocal(v_9, frame_4.tangent, n_i_10);
        float _S1357 = frame_4.alphas.y;
        float3  _S1358 = make_float3 (_S1354 * _S1356.x, _S1357 * _S1356.y, _S1356.z);
        float3  _S1359 = ((((_S1358)) * make_float3(rnorm3df(((_S1358)).x, ((_S1358)).y, ((_S1358)).z))));
        float3  _S1360 = sampleGGXVNDF(_S1359, 1.0f, _S1352.value, _S1353.value);
        float3  _S1361 = make_float3 (_S1354 * _S1360.x, _S1357 * _S1360.y, _S1360.z);
        float3  _S1362 = ((((_S1361)) * make_float3(rnorm3df(((_S1361)).x, ((_S1361)).y, ((_S1361)).z))));
        return make_float3 (_S1362.x) * frame_4.tangent + make_float3 (_S1362.y) * cross_0(n_i_10, frame_4.tangent) + make_float3 (_S1362.z) * n_i_10;
    }
    float3  _S1363 = worldToTangent(v_9, n_i_10);
    float3  _S1364 = sampleGGXVNDF(float3 {_S1363.x, _S1363.z, _S1363.y}, alpha_6, _S1352.value, _S1353.value);
    float3  _S1365 = float3 {_S1364.x, _S1364.z, _S1364.y};
    float3  _S1366 = tangentToWorld(_S1365, n_i_10);
    return _S1366;
}

__device__ __forceinline__ float3  coatHalf(float3  v_10, CoatFrame coat_frame_4, uint random_state_8)
{
    bool _S1367 = !((dot_0(coat_frame_4.normal, v_10)) > 0.0f);
    if(_S1367)
    {
        return make_float3 (0.0f);
    }
    uint state_2 = random_state_8;
    float3  _S1368 = sampleHalfVector(v_10, coat_frame_4.normal, coat_frame_4.alpha, AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f)), &state_2, 1U);
    return _S1368;
}

static __device__ Facets Facets_x24init_0(float3  h_3, float3  coat_h_3)
{
    Facets _S1369;
    (&_S1369)->h = h_3;
    (&_S1369)->coat_h = coat_h_3;
    return _S1369;
}

__device__ Facets drawFacets(float3  in_dir_6, float3  n_10, BSDFMaterial material_20, uint random_state_9)
{
    float3  _S1370 = negate_0(in_dir_6);
    float _S1371 = sign_0(dot_0(n_10, _S1370));
    float3  _S1372 = n_10 * make_float3 (_S1371);
    uint state_3 = random_state_9;
    float _S1373 = material_20.roughness;
    float _S1374 = _S1373 * _S1373;
    AnisotropicFrame _S1375 = anisotropicFrame(material_20, _S1372);
    float3  _S1376 = sampleHalfVector(_S1370, _S1372, _S1374, _S1375, &state_3, 0U);
    CoatFrame _S1377 = coatFrame(material_20, _S1372);
    float3  _S1378 = coatHalf(_S1370, _S1377, random_state_9);
    return Facets_x24init_0(_S1376, _S1378);
}

__device__ bool neeDecision(BSDFMaterial material_21, float n_dot_v_2, float eta_i_5, float eta_o_4)
{
    float _S1379 = fresnel((F32_abs((n_dot_v_2))), eta_i_5, eta_o_4);
    float3  _S1380 = mix_0(make_float3 (_S1379), material_21.albedo, material_21.metallic);
    float _S1381 = rgb_to_greyscale(_S1380);
    float _S1382 = (F32_max(((1.0f - _S1381) * (1.0f - material_21.metallic) * (1.0f - material_21.transmission)), (0.0f)));
    bool _S1383 = _S1382 > 0.03999999910593033f;
    bool _S1384;
    if(_S1383)
    {
        _S1384 = true;
    }
    else
    {
        _S1384 = (material_21.roughness) > 0.20000000298023224f;
    }
    return _S1384;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_22)
{
    float _S1385 = rgb_to_greyscale(material_22->translucent);
    return _S1385 > 0.0f;
}

struct MediumSides
{
    FKMedium behind;
    FKMedium front;
    uint2  fillings;
    float3  face;
};

static __device__ MediumSides MediumSides_x24init_0(FKMedium * behind_1, FKMedium * front_0, uint2  fillings_1, float3  face_1)
{
    MediumSides _S1386;
    (&_S1386)->behind = *behind_1;
    (&_S1386)->front = *front_0;
    (&_S1386)->fillings = fillings_1;
    (&_S1386)->face = face_1;
    return _S1386;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_8, FKMedium * medium_0, uint filling_0, float3  dir_12, FKMedium * outside_0)
{
    float3  _S1387 = surface_8->geometry_n;
    MediumSides _S1388 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_8->geometry_n);
    MediumSides sides_0 = _S1388;
    bool _S1389 = surface_8->encloses;
    if(_S1389)
    {
        (&sides_0)->behind = surface_8->volume;
        *&((&(&sides_0)->fillings)->x) = surface_8->fills;
        bool _S1390 = (dot_0(dir_12, _S1387)) > 0.0f;
        if(_S1390)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_9, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_13, uint depth_3, uint lobe_3, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1391 = surface_9->geometry_n;
    ShadowContext _S1392 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_9->geometry_n, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
    bool _S1393 = surface_9->encloses;
    ShadowContext context_4;
    if(_S1393)
    {
        FKSurface faced_1 = *surface_9;
        float3  _S1394 = - _S1391;
        float3  _S1395 = _slang_select(turned_0, _S1394,_S1391);
        (&faced_1)->geometry_n = _S1395;
        FKMedium _S1396 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1397 = faced_1;
        FKMedium _S1398 = _S1396;
        MediumSides _S1399 = mediumSides_0(&_S1397, &_S1398, filling_1, dir_13, outside_1);
        ShadowContext _S1400 = ShadowContext_x24init_0(_S1399.behind.extinction, _S1399.front.extinction, _S1399.fillings, _S1391, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
        if(turned_0)
        {
            uint2  _S1401 = _S1399.fillings;
            ShadowContext _S1402 = ShadowContext_x24init_0(_S1399.front.extinction, _S1399.behind.extinction, uint2 {_S1401.y, _S1401.x}, _S1391, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
            context_4 = _S1402;
        }
        else
        {
            context_4 = _S1400;
        }
    }
    else
    {
        context_4 = _S1392;
    }
    return context_4;
}

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_7, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_3, BSDFMaterial * material_23, float eta_i_6, float eta_o_5, bool competing_1, Facets * facets_3)
{
    float3  _S1403 = light_2->dir;
    bool _S1404 = (dot_0(geometry_n_3, - in_dir_7) * dot_0(geometry_n_3, light_2->dir)) <= 0.0f;
    FixedArray<float3 , 6>  throughputs_1;
    FixedArray<float, 6>  pdfs_4;
    BSDF(in_dir_7, _S1403, smooth_n_5, *material_23, eta_i_6, eta_o_5, _S1404, *facets_3, &throughputs_1, &pdfs_4);
    bool _S1405;
    if(competing_1)
    {
        _S1405 = (light_2->density) != 0.0f;
    }
    else
    {
        _S1405 = false;
    }
    float3  _S1406 = make_float3 (0.0f);
    uint i_23 = 0U;
    float3  f_7 = _S1406;
    for(;;)
    {
        if(i_23 < 6U)
        {
        }
        else
        {
            break;
        }
        bool _S1407 = (pdfs_4[i_23]) > 0.0f;
        if(_S1407)
        {
            float3  f_8;
            if(_S1405)
            {
                float _S1408 = light_2->density;
                float _S1409 = pdfs_4[i_23] / light_2->density;
                float3  f_9 = f_7 + throughputs_1[i_23] * make_float3 (pdfs_4[i_23]) / make_float3 (_S1408 * (1.0f + _S1409 * _S1409));
                f_8 = f_9;
            }
            else
            {
                float3  f_10 = f_7 + throughputs_1[i_23] * make_float3 (pdfs_4[i_23]);
                f_8 = f_10;
            }
            f_7 = f_8;
        }
        uint i_24 = i_23 + 1U;
        i_23 = i_24;
    }
    float3  _S1410 = f_7 * light_2->radiance;
    float3  _S1411 = _S1410 * make_float3 (light_2->density);
    float3  _S1412 = _slang_select(_S1405, _S1411,_S1410);
    return _S1412;
}

__device__ float3  skyBSDF(float3  in_dir_8, float3  dir_14, FKSurface surface_10, BSDFMaterial material_24, float2  eta_3, bool is_inside_4, Facets facets_4, float pdf_5)
{
    FKSurface _S1413 = surface_10;
    BSDFMaterial _S1414 = material_24;
    Facets _S1415 = facets_4;
    FixedArray<float3 , 6>  terms_3;
    FixedArray<float, 6>  pdfs_5;
    float3  _S1416 = skyLobes_0(in_dir_8, dir_14, &_S1413, &_S1414, eta_3, is_inside_4, &_S1415, pdf_5, &terms_3, &pdfs_5);
    return _S1416;
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_2, uint random_state_10, bool refracted_3, uint lobe_4, float pdf_6)
{
    SampleBSDF _S1417;
    (&_S1417)->unit_direction = unit_direction_1;
    (&_S1417)->throughput = throughput_2;
    (&_S1417)->random_state = random_state_10;
    (&_S1417)->refracted = refracted_3;
    (&_S1417)->lobe = lobe_4;
    (&_S1417)->pdf = pdf_6;
    return _S1417;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  v_11, float3  n_i_11, float n_i_dot_v_3, BSDFMaterial material_25, Weights w_14, uint random_state_11)
{
    Random _S1418 = draw(random_state_11, 3U);
    Random _S1419 = draw(random_state_11, 2147483651U);
    float _S1420 = _S1418.value;
    float _S1421 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1420 * _S1420))))));
    float _S1422 = 6.28318548202514648f * _S1419.value;
    float3  _S1423 = tangentToWorld(make_float3 (_S1421 * (F32_cos((_S1422))), _S1418.value, _S1421 * (F32_sin((_S1422)))), n_i_11);
    float3  _S1424 = sheenVelvetBSDF(_S1423, v_11, n_i_11, material_25, w_14);
    float _S1425 = sheenVelvetPDF(_S1418.value, n_i_dot_v_3, w_14);
    return SampleBSDF_x24init_0(_S1423, _S1424, _S1419.state, false, 4U, _S1425);
}

__device__ __forceinline__ SampleBSDF coatSample(float3  in_dir_9, float3  v_12, float3  coat_h_4, CoatFrame coat_frame_5, Weights w_15, uint random_state_12)
{
    float3  _S1426 = reflect_0(in_dir_9, coat_h_4);
    float3  _S1427 = ((((_S1426)) * make_float3(rnorm3df(((_S1426)).x, ((_S1426)).y, ((_S1426)).z))));
    float3  _S1428 = coatBSDF(w_15);
    float _S1429 = coatPDF(v_12, coat_h_4, coat_frame_5, w_15);
    return SampleBSDF_x24init_0(_S1427, _S1428, random_state_12, false, 5U, _S1429);
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1430 = (F32_sqrt((random_1_0)));
    float _S1431 = 6.28318548202514648f * random_2_0;
    float _S1432 = _S1430 * (F32_cos((_S1431)));
    float _S1433 = _S1430 * (F32_sin((_S1431)));
    float _S1434 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1432 * _S1432 - _S1433 * _S1433))))));
    return make_float3 (_S1432, _S1434, _S1433);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_3, float3  n_i_12, float n_i_dot_v_4, BSDFMaterial material_26, Weights w_16, uint random_state_13)
{
    Random _S1435 = draw(random_state_13, 3U);
    Random _S1436 = draw(random_state_13, 2147483651U);
    float3  _S1437 = sampleCosWeightedHemisphere(_S1435.value, _S1436.value);
    float _S1438 = translucentShare(material_26);
    bool _S1439 = u_3 < (w_16.p_diffuse * _S1438);
    float _S1440 = _S1437.y;
    float _S1441 = - _S1440;
    float _S1442 = _slang_select(_S1439, _S1441,_S1440);
    float3  _S1443 = tangentToWorld(make_float3 (_S1437.x, _S1442, _S1437.z), n_i_12);
    float3  _S1444 = diffuseBSDF(_S1443, n_i_12, material_26, w_16);
    float _S1445 = diffusePDF(_S1442, n_i_dot_v_4, material_26, w_16);
    return SampleBSDF_x24init_0(_S1443, _S1444, _S1436.state, _S1439, 0U, _S1445);
}

__device__ __forceinline__ SampleBSDF toonSample(float3  n_i_13, ToonProfile profile_3, Weights w_17, uint random_state_14)
{
    Random _S1446 = draw(random_state_14, 3U);
    Random _S1447 = draw(random_state_14, 2147483651U);
    float _S1448 = _S1446.value * profile_3.norm / 6.28318548202514648f;
    float _S1449 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1448)))), (1.0f))))));
    float _S1450 = (F32_acos((clamp_1(1.0f - _S1448, -1.0f, 1.0f))));
    float _S1451 = _slang_select(profile_3.glossy, _S1450,_S1449);
    float _S1452 = (profile_3.a + profile_3.b) / 2.0f;
    bool _S1453 = _S1451 < (profile_3.a);
    float _S1454 = _slang_select(_S1453, _S1451,_S1452);
    float t_23 = _S1454;
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
        float _S1455 = toonP(t_23, profile_3.a, profile_3.s);
        float _S1456 = _S1455 * (F32_sin((t_23)));
        float _S1457 = (F32_cos((t_23)));
        float _S1458 = _slang_select(profile_3.glossy, 1.0f,_S1457);
        float _S1459 = _S1456 * _S1458;
        float _S1460 = toonIntegral(t_23, profile_3.a, profile_3.s, profile_3.glossy);
        float _S1461 = (_S1460 - _S1448) / _S1459;
        bool _S1462 = _S1459 > 0.0f;
        float _S1463 = _slang_select(_S1462, _S1461,0.0f);
        float _S1464 = clamp_1(t_23 - _S1463, 0.0f, profile_3.b);
        int k_3 = k_2 + int(1);
        t_23 = _S1464;
        k_2 = k_3;
    }
    float _S1465 = 6.28318548202514648f * _S1447.value;
    float _S1466 = (F32_sin((t_23)));
    float3  _S1467 = tangentToWorld(make_float3 (_S1466 * (F32_cos((_S1465))), (F32_cos((t_23))), _S1466 * (F32_sin((_S1465)))), profile_3.axis);
    float3  _S1468 = toonBSDF(_S1467, n_i_13, profile_3, w_17);
    bool _S1469 = (dot_0(n_i_13, _S1467)) < 0.0f;
    float _S1470 = toonPDF(_S1467, n_i_13, profile_3, w_17);
    return SampleBSDF_x24init_0(_S1467, _S1468, _S1447.state, _S1469, 6U, _S1470);
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_1, float3  n_i_14, float alpha_7, AnisotropicFrame frame_5, BSDFMaterial material_27, Weights w_18, float pdf_h_3, float eta_i_7, float eta_o_6, uint random_state_15)
{
    float _S1471 = maskingG1(w_18.refracted, n_i_14, -1.0f, alpha_7, frame_5);
    float3  _S1472 = refractBSDF(_S1471, material_27, w_18);
    float _S1473 = refractPDF(dot_0(w_18.refracted, ggx_n_1), pdf_h_3, w_18, eta_i_7, eta_o_6);
    return SampleBSDF_x24init_0(w_18.refracted, _S1472, random_state_15, true, 1U, _S1473);
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_10, float3  ggx_n_2, float3  n_i_15, float alpha_8, AnisotropicFrame frame_6, Weights w_19, float pdf_h_4, uint random_state_16)
{
    float3  _S1474 = reflect_0(in_dir_10, ggx_n_2);
    float3  _S1475 = ((((_S1474)) * make_float3(rnorm3df(((_S1474)).x, ((_S1474)).y, ((_S1474)).z))));
    float _S1476 = maskingG1(_S1475, n_i_15, 1.0f, alpha_8, frame_6);
    float3  _S1477 = reflectBSDF(_S1476, w_19);
    float _S1478 = reflectPDF(pdf_h_4, w_19);
    return SampleBSDF_x24init_0(_S1475, _S1477, random_state_16, false, 2U, _S1478);
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_11, float3  n_11, BSDFMaterial material_28, float eta_i_8, float eta_o_7, Facets facets_5, uint random_init_0, float2  screen_space_0)
{
    float3  _S1479 = negate_0(in_dir_11);
    float _S1480 = dot_0(n_11, _S1479);
    float _S1481 = sign_0(_S1480);
    float3  n_i_16 = n_11 * make_float3 (_S1481);
    float _S1482 = (F32_abs((_S1480)));
    float _S1483 = material_28.roughness;
    float _S1484 = _S1483 * _S1483;
    AnisotropicFrame _S1485 = anisotropicFrame(material_28, n_i_16);
    SheenProfile _S1486 = sheenProfile(_S1479, n_i_16, material_28);
    CoatFrame _S1487 = coatFrame(material_28, n_i_16);
    float3  _S1488 = coatSeries(_S1487, material_28);
    Weights _S1489 = lobeWeights(in_dir_11, _S1479, n_i_16, facets_5.h, facets_5.coat_h, facets_5.h, facets_5.coat_h, _S1485, _S1486, _S1487, _S1488, material_28, eta_i_8, eta_o_7);
    Random _S1490 = draw(random_init_0, 2U);
    bool _S1491 = (_S1490.value) < (_S1489.p_sheen_velvet);
    if(_S1491)
    {
        SampleBSDF _S1492 = sheenVelvetSample(_S1479, n_i_16, _S1482, material_28, _S1489, _S1490.state);
        return _S1492;
    }
    float _S1493 = _S1490.value - _S1489.p_sheen_velvet;
    bool _S1494 = _S1493 < (_S1489.p_coat);
    if(_S1494)
    {
        SampleBSDF _S1495 = coatSample(in_dir_11, _S1479, facets_5.coat_h, _S1487, _S1489, _S1490.state);
        return _S1495;
    }
    float _S1496 = _S1493 - _S1489.p_coat;
    bool _S1497 = _S1496 < (_S1489.p_diffuse);
    if(_S1497)
    {
        SampleBSDF _S1498 = diffuseSample(_S1496, n_i_16, _S1482, material_28, _S1489, _S1490.state);
        return _S1498;
    }
    bool _S1499 = _S1496 < (_S1489.p_diffuse + _S1489.p_toon);
    if(_S1499)
    {
        ToonProfile _S1500 = toonProfile(_S1479, n_i_16, material_28);
        SampleBSDF _S1501 = toonSample(n_i_16, _S1500, _S1489, _S1490.state);
        return _S1501;
    }
    float _S1502 = vndfPDF(_S1479, facets_5.h, n_i_16, _S1482, _S1484, _S1485, _S1489.v_dot_h);
    bool _S1503 = (_S1496 - _S1489.p_toon) < (_S1489.p_diffuse + _S1489.p_refract);
    if(_S1503)
    {
        SampleBSDF _S1504 = refractSample(facets_5.h, n_i_16, _S1484, _S1485, material_28, _S1489, _S1502, eta_i_8, eta_o_7, _S1490.state);
        return _S1504;
    }
    SampleBSDF _S1505 = reflectSample(in_dir_11, facets_5.h, n_i_16, _S1484, _S1485, _S1489, _S1502, _S1490.state);
    return _S1505;
}

__device__ __forceinline__ float3  refractedHalf(float3  in_dir_12, float3  out_dir_2, float3  n_12, float eta_i_9, float eta_o_8)
{
    float3  _S1506 = negate_0(in_dir_12);
    float3  _S1507 = negate_0(make_float3 (eta_i_9) * _S1506 + make_float3 (eta_o_8) * out_dir_2);
    float3  _S1508 = ((((_S1507)) * make_float3(rnorm3df(((_S1507)).x, ((_S1507)).y, ((_S1507)).z))));
    float _S1509 = sign_0(dot_0(n_12, _S1506));
    float _S1510 = sign_0(dot_0(_S1507, n_12 * make_float3 (_S1509)));
    return _S1508 * make_float3 (_S1510);
}

static __device__ bool boundsVolume_0(FKSurface * surface_11)
{
    return surface_11->encloses;
}

static __device__ Shift walk_0(Domain * dom_7, Reservoir * r_9, bool replay_2, float scale_4, Selection * sel_8)
{
    bool turned_1;
    bool is_inside_5;
    bool viewed_0;
    bool _S1511;
    bool _S1512;
    bool _S1513;
    uint b_7;
    uint layer_0;
    float3  throughput_3;
    float3  spectral_weight_1;
    float density_3;
    float spread_1;
    float width_3;
    float sky_pdf_1;
    float wavelength_9;
    float threshold_0;
    TreeSample light_3;
    int _S1514;
    Shift ended_0;
    float density_4;
    float spread_2;
    float width_4;
    float sky_pdf_2;
    uint b_8;
    float spread_3;
    float width_5;
    float3  _S1515 = make_float3 (0.0f);
    Shift _S1516 = Shift_x24init_0(_S1515, 0.0f);
    uint _S1517 = r_9->path;
    uint _S1518 = extractBits_0(r_9->path, 0U, 5U);
    uint _S1519 = extractBits_0(_S1517, 5U, 5U);
    uint _S1520 = extractBits_0(_S1517, 10U, 2U);
    uint _S1521 = extractBits_0(_S1517, 12U, 3U);
    bool passes_0;
    if(replay_2)
    {
        bool _S1522 = _S1521 >= 3U;
        uint _S1523 = _slang_select(_S1522, 1U,0U);
        uint _S1524 = _S1518 + _S1523;
        uint _S1525 = (fcptMaxBounces());
        passes_0 = _S1524 > _S1525;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1516;
    }
    uint _S1526 = _S1519 - 1U;
    bool _S1527 = _S1521 == 3U;
    uint _S1528 = _slang_select(_S1527, 1U,0U);
    uint _S1529 = _S1518 + _S1528;
    bool _S1530 = _S1520 == 0U;
    uint _S1531 = _slang_select(_S1530, _S1529,_S1526);
    FKHit _S1532 = (fcptReservoirHit((*r_9)));
    float3  _S1533 = dom_7->x0;
    float3  _S1534 = dom_7->x1 - dom_7->x0;
    float3  _S1535 = ((((_S1534)) * make_float3(rnorm3df(((_S1534)).x, ((_S1534)).y, ((_S1534)).z))));
    FKRay _S1536 = Ray_x24init_0(dom_7->x1, _S1535);
    FKRay ray_3 = _S1536;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1515;
    float3  throughput_4 = make_float3 (1.0f);
    float3  weight_2 = throughput_4;
    float3  glowed_0 = _S1515;
    float3  extinction_in_0 = _S1515;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1537 = dom_7->spread;
    float _S1538 = dom_7->width;
    float _S1539 = length_0(_S1534);
    NEEVertex _S1540 = NEEVertex_x24init_0(true, 0.0f, _S1515, _S1515, _S1515);
    NEEVertex nee_vertex_1 = _S1540;
    Vertex _S1541 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_1 = _S1541;
    Reservoir _S1542 = (Reservoir{});
    Reservoir chain_1 = _S1542;
    uint _S1543 = r_9->seed;
    (&chain_1)->seed = r_9->seed;
    uint _S1544 = extractBits_0(_S1517, 24U, 8U);
    uint _S1545 = insertBits_0(0U, _S1544, 24U, 8U);
    (&chain_1)->path = _S1545;
    (&ray_3)->origin = _S1533;
    (&hit_4)->distance = _S1539;
    FKMedium _S1546 = (fcptCameraMedium(((&ray_3)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1547 = filling_2;
    bool _S1548 = (fcptVaryingUsed());
    uint _S1549 = _slang_select(_S1548, _S1547,4294967295U);
    filling_2 = _S1549;
    scatter_in_0 = _S1546.scatter;
    extinction_in_0 = _S1546.extinction;
    g_in_0 = _S1546.g;
    Reservoir _S1550 = chain_1;
    uint _S1551 = filling_2;
    for(;;)
    {
        bool _S1552 = (fcptVaryingUsed());
        if(_S1552)
        {
            passes_0 = _S1551 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1553 = (fcptMajorant((_S1551)));
            turned_1 = _S1553 > 0.0f;
        }
        else
        {
            turned_1 = any_1(scatter_in_0 > make_float3 (0.0f));
        }
        if(replay_2)
        {
            is_inside_5 = 4294967295U == _S1531;
        }
        else
        {
            is_inside_5 = false;
        }
        if(is_inside_5)
        {
            is_inside_5 = _S1520 == 1U;
        }
        else
        {
            is_inside_5 = false;
        }
        if(is_inside_5)
        {
            is_inside_5 = turned_1;
        }
        else
        {
            is_inside_5 = false;
        }
        if(is_inside_5)
        {
            ended_0 = _S1516;
            sky_pdf_1 = 0.0f;
            spread_1 = _S1537;
            width_3 = _S1538;
            density_3 = 1.0f;
            throughput_3 = throughput_4;
            b_7 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1554 = (&prev_1)->rough;
        if(_S1554)
        {
            is_inside_5 = !turned_1;
        }
        else
        {
            is_inside_5 = false;
        }
        (&prev_1)->rough = is_inside_5;
        uint _S1555 = stream(_S1543, 384U);
        uint tracking_0 = _S1555;
        weight_2 = throughput_4;
        glowed_0 = _S1515;
        b_7 = 4294967295U;
        throughput_3 = throughput_4;
        density_3 = 1.0f;
        spread_1 = _S1537;
        width_3 = _S1538;
        sky_pdf_1 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1514 = int(1);
                break;
            }
            float _S1556 = (&hit_4)->distance;
            if(passes_0)
            {
                float3  _S1557 = (&ray_3)->origin;
                float3  _S1558 = (&ray_3)->unit_direction;
                float _S1559 = (&hit_4)->distance;
                bool _S1560 = b_7 == 4294967295U;
                uint _S1561 = _slang_select(_S1560, 0U,b_7);
                uint _S1562 = (&prev_1)->lobe;
                uint _S1563 = _slang_select(_S1560, 3U,_S1562);
                float _S1564 = (fcptTrackMedium((_S1551), (_S1557), (_S1558), (_S1559), (&tracking_0), (&weight_2), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1561), (_S1563), (_S1560)));
                wavelength_9 = _S1564;
            }
            else
            {
                if(turned_1)
                {
                    uint _S1565 = noiseAddress(_S1543, b_7);
                    Random _S1566 = draw(_S1565, 10U);
                    float _S1567 = 3.0f * _S1566.value;
                    uint _S1568 = (U32_min((uint(_S1567)), (2U)));
                    float _S1569 = - (F32_log((1.0f - (_S1567 - float(_S1568))))) / *_slang_vector_get_element_ptr(&scatter_in_0, _S1568);
                    wavelength_9 = _S1569;
                }
                else
                {
                    wavelength_9 = _S1556;
                }
            }
            bool _S1570 = !(wavelength_9 < ((&hit_4)->distance));
            if(_S1570)
            {
                _S1514 = int(1);
                break;
            }
            if(passes_0)
            {
                is_inside_5 = !replay_2;
            }
            else
            {
                is_inside_5 = false;
            }
            if(is_inside_5)
            {
                float3  _S1571 = pathColor(throughput_3 * glowed_0, throughput_4, 0.0f);
                float3  _S1572 = _S1571 / make_float3 (density_3);
                float3  _S1573 = sel_8->glow + _S1572;
                sel_8->glow = _S1573;
            }
            else
            {
            }
            glowed_0 = _S1515;
            uint b_9 = b_7 + 1U;
            float3  _S1574 = (&ray_3)->origin + make_float3 (wavelength_9) * (&ray_3)->unit_direction;
            (&ray_3)->origin = _S1574;
            float3  _S1575 = flightWeight_0(scatter_in_0, extinction_in_0, wavelength_9, true);
            float3  _S1576 = weight_2;
            float _S1577 = upsample(weight_2, 0.0f);
            float3  _S1578 = make_float3 (_S1577);
            float3  _S1579 = _slang_select(false, _S1578,_S1576);
            float3  _S1580 = _slang_select(passes_0, _S1579,_S1575);
            float3  throughput_5 = throughput_3 * _S1580;
            uint _S1581 = stream(_S1543, b_9 + 320U);
            tracking_0 = _S1581;
            weight_2 = throughput_4;
            float width_6 = width_3 + spread_1 * wavelength_9;
            float _S1582 = spread_1 + 3.14159274101257324f;
            bool _S1583 = !replay_2;
            if(_S1583)
            {
                viewed_0 = true;
            }
            else
            {
                bool _S1584 = b_9 == _S1531;
                if(_S1584)
                {
                    viewed_0 = !passes_0;
                }
                else
                {
                    viewed_0 = false;
                }
            }
            TreeSample _S1585 = TreeSample_x24init_0(_S1515, _S1515, 0.0f, 0U);
            if(viewed_0)
            {
                float3  _S1586 = (&ray_3)->origin;
                float3  _S1587 = (&ray_3)->unit_direction;
                float3  _S1588 = (&ray_3)->unit_direction;
                uint _S1589 = noiseAddress(_S1543, b_9);
                float3  _S1590 = extinction_in_0;
                float3  _S1591 = extinction_in_0;
                uint2  _S1592 = make_uint2 (_S1551);
                float3  _S1593 = (&ray_3)->unit_direction;
                uint _S1594 = arrivalLobe_0(b_9, (&prev_1)->lobe);
                FKHit _S1595 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1596 = _S1595;
                ShadowContext _S1597 = ShadowContext_x24init_0(_S1590, _S1591, _S1592, _S1593, b_9, _S1594, false, wavelength_9, width_6, &_S1596, false);
                ShadowContext _S1598 = _S1597;
                TreeSample _S1599 = sampleLightTree_0(_S1586, _S1587, _S1588, 0.0f, true, _S1589, &_S1598);
                light_3 = _S1599;
            }
            else
            {
                light_3 = _S1585;
            }
            float _S1600 = phaseHG_0(g_in_0, dot_0((&ray_3)->unit_direction, light_3.dir));
            uint _S1601 = (fcptMaxBounces());
            bool _S1602 = b_9 < _S1601;
            if(_S1602)
            {
                _S1511 = (light_3.density) > 0.0f;
            }
            else
            {
                _S1511 = false;
            }
            float _S1603 = _slang_select(_S1511, _S1600,0.0f);
            float3  _S1604 = throughput_5 * light_3.radiance;
            float _S1605 = powerHeuristic(light_3.density, _S1603);
            float3  _S1606 = pathColor(_S1604 * make_float3 (_S1600 * _S1605), throughput_4, 0.0f);
            float3  _S1607 = _slang_select(viewed_0, _S1606,_S1515);
            if(replay_2)
            {
                _S1512 = b_9 == _S1531;
            }
            else
            {
                _S1512 = false;
            }
            if(_S1512)
            {
                bool _S1608 = _S1520 == 2U;
                if(_S1608)
                {
                    float _S1609 = resamplingTarget(_S1607);
                    passes_0 = _S1609 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1610 = Shift_x24init_0(_S1607, 1.0f);
                    _S1514 = int(0);
                    ended_0 = _S1610;
                    wavelength_9 = _S1582;
                    threshold_0 = width_6;
                    spectral_weight_1 = throughput_5;
                    layer_0 = b_9;
                    break;
                }
                _S1514 = int(0);
                ended_0 = _S1516;
                wavelength_9 = _S1582;
                threshold_0 = width_6;
                spectral_weight_1 = throughput_5;
                layer_0 = b_9;
                break;
            }
            if(_S1583)
            {
                Reservoir candidate_4 = _S1550;
                uint _S1611 = extractBits_0(_S1550.path, 24U, 8U);
                uint _S1612 = insertBits_0(0U, _S1611, 24U, 8U);
                uint _S1613 = extractBits_0(_S1550.path, 10U, 2U);
                bool _S1614 = _S1613 == 1U;
                if(_S1614)
                {
                    float3  _S1615 = safeDivide(_S1607, _S1515);
                    (&candidate_4)->radiance = _S1615;
                }
                else
                {
                    uint _S1616 = insertBits_0(_S1612, b_9 + 1U, 5U, 5U);
                    uint _S1617 = insertBits_0(_S1616, 2U, 10U, 2U);
                    (&candidate_4)->path = _S1617;
                }
                Reservoir _S1618 = withEnd(candidate_4, 0U, b_9, _S1607);
                offer(sel_8, _S1618, _S1607 * make_float3 (scale_4) / make_float3 (density_3));
                float _S1619 = survivalProbability(abs_0(throughput_5), density_3);
                uint _S1620 = (fcptMaxBounces());
                bool _S1621 = b_9 >= _S1620;
                if(_S1621)
                {
                    _S1513 = true;
                }
                else
                {
                    bool _S1622 = _S1619 < 1.0f;
                    if(_S1622)
                    {
                        uint _S1623 = noiseAddress(_S1543, b_9);
                        Random _S1624 = draw(_S1623, 8U);
                        _S1513 = _S1619 < (_S1624.value);
                    }
                    else
                    {
                        _S1513 = false;
                    }
                }
                if(_S1513)
                {
                    _S1514 = int(0);
                    ended_0 = _S1516;
                    wavelength_9 = _S1582;
                    threshold_0 = width_6;
                    spectral_weight_1 = throughput_5;
                    layer_0 = b_9;
                    break;
                }
                float _S1625 = density_3 * _S1619;
                density_3 = _S1625;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1626 = noiseAddress(_S1543, b_9);
            float3  _S1627 = samplePhase_0(g_in_0, (&ray_3)->unit_direction, _S1626, &phase_pdf_0);
            (&ray_3)->unit_direction = _S1627;
            NEEVertex _S1628 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_3)->origin, _S1515, (&ray_3)->origin);
            nee_vertex_1 = _S1628;
            Vertex _S1629 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, false);
            prev_1 = _S1629;
            float _S1630 = (&prev_1)->pdf;
            FKRay _S1631 = ray_3;
            FKHit _S1632 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1633 = (fcptTraverseInstanceBVH((_S1631), (true), (4.294967296e+09f), (false), (_S1632), (false)));
            hit_4 = _S1633;
            b_7 = b_9;
            throughput_3 = throughput_5;
            spread_1 = _S1582;
            width_3 = width_6;
            sky_pdf_1 = _S1630;
        }
        if(_S1514 != int(1))
        {
            spread_1 = wavelength_9;
            width_3 = threshold_0;
            throughput_3 = spectral_weight_1;
            b_7 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1516;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1634 = b_7 == 4294967295U;
    bool _S1635 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1635)
    {
        Reservoir _S1636 = chain_1;
        FKRay _S1637 = ray_3;
        Vertex _S1638 = prev_1;
        NEEVertex _S1639 = nee_vertex_1;
        Shift _S1640 = escape_0(r_9, replay_2, _S1531, _S1520, _S1518, _S1521, scale_4, _S1545, &_S1636, _S1515, b_7, &_S1637, throughput_3, density_3, &_S1638, &_S1639, sky_pdf_1, throughput_4, 0.0f, sel_8);
        return _S1640;
    }
    FKHit _S1641 = hit_4;
    uint _S1642 = filling_2;
    float3  _S1643 = scatter_in_0;
    float3  _S1644 = extinction_in_0;
    float3  _S1645 = weight_2;
    float3  _S1646 = glowed_0;
    float3  _S1647 = (&ray_3)->origin + make_float3 (_S1641.distance) * (&ray_3)->unit_direction;
    (&ray_3)->origin = _S1647;
    bool _S1648 = (fcptVaryingUsed());
    if(_S1648)
    {
        passes_0 = _S1642 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1649 = !replay_2;
        if(_S1649)
        {
            float3  _S1650 = pathColor(throughput_3 * _S1646, throughput_4, 0.0f);
            float3  _S1651 = _S1650 / make_float3 (density_3);
            float3  _S1652 = sel_8->glow + _S1651;
            sel_8->glow = _S1652;
        }
        else
        {
        }
        float3  _S1653 = throughput_3 * _S1645;
        throughput_3 = _S1653;
    }
    else
    {
        float3  _S1654 = flightWeight_0(_S1643, _S1644, _S1641.distance, false);
        float3  _S1655 = throughput_3 * _S1654;
        throughput_3 = _S1655;
    }
    float width_7 = width_3 + spread_1 * _S1641.distance;
    uint _S1656 = b_7 + 1U;
    b_7 = _S1656;
    layer_0 = 0U;
    width_3 = width_7;
    passes_0 = false;
    wavelength_9 = 0.0f;
    threshold_0 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    spectral_weight_1 = throughput_4;
    float3  chain_throughput_1 = _S1515;
    float3  reconnection_0 = _S1515;
    viewed_0 = _S1634;
    for(;;)
    {
        bool _S1657 = ((&hit_4)->is_point_light) == 1U;
        if(replay_2)
        {
            _S1511 = _S1520 == 1U;
        }
        else
        {
            _S1511 = false;
        }
        if(_S1511)
        {
            _S1512 = b_7 == _S1519;
        }
        else
        {
            _S1512 = false;
        }
        if(_S1512)
        {
            bool _S1658 = ((&hit_4)->instance_index) != (_S1532.instance_index);
            if(_S1658)
            {
                _S1513 = true;
            }
            else
            {
                _S1513 = ((&hit_4)->triangle_index) != (_S1532.triangle_index);
            }
        }
        else
        {
            _S1513 = false;
        }
        if(_S1513)
        {
            return _S1516;
        }
        FKMedium _S1659 = Medium_x24init_0(_S1515, _S1515, 0.0f);
        BSDFMaterial _S1660 = Material_x24init_0(_S1515, _S1515, 0.0f, 0.0f, 0.0f, 0.0f, _S1515, throughput_4, 1.0f, _S1515, _S1515, 0.5f, 0.0f, 0.0f, _S1515, 0.0f, _S1515, 0.0f, 0.0f, 0.02999999932944775f, 1.5f, throughput_4, _S1515);
        FKMedium _S1661 = _S1659;
        FKSurface _S1662 = Surface_x24init_0(_S1515, _S1515, 0.0f, &_S1660, false, 0U, 1.0f, false, &_S1661, 4294967295U, _S1515);
        bool _S1663 = !_S1657;
        bool scatter_2;
        bool is_inside_6;
        float3  throughput_6;
        float geometry_density_0;
        FKSurface surface_12;
        if(_S1663)
        {
            uint _S1664 = noiseAddress(_S1543, b_7);
            uint _S1665 = arrivalLobe_0(b_7, (&prev_1)->lobe);
            FKSurface _S1666 = (fcptSurfaceAtPath((hit_4), ((&ray_3)->origin), (_S1664), (width_3), (layer_0), (b_7), (_S1665), ((&ray_3)->unit_direction)));
            bool _S1667 = !passes_0;
            FKSurface _S1668 = _S1666;
            FKSurface _S1669 = emitting_0(&_S1668, _S1667);
            uint _S1670 = noiseAddress(_S1543, b_7);
            Random _S1671 = draw(_S1670, 9U);
            FKSurface _S1672 = _S1669;
            FKSurface _S1673 = uncovered_0(&_S1672, _S1671.value);
            float _S1674 = facingSign(_S1673.material.transmission, _S1673.geometry_n, (&ray_3)->unit_direction);
            bool _S1675 = _S1674 < 0.0f;
            bool _S1676 = (_S1673.material.transmission) > 0.0f;
            if(_S1676)
            {
                bool _S1677 = arrivesBehind_0((&ray_3)->unit_direction, _S1673.geometry_n);
                scatter_2 = _S1677;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1678 = _S1673;
            FKSurface _S1679 = facingRay_0(&_S1678, (&ray_3)->unit_direction);
            if(passes_0)
            {
                bool _S1680 = arrivesBehind_0((&ray_3)->unit_direction, _S1679.geometry_n);
                is_inside_6 = _S1680;
            }
            else
            {
                is_inside_6 = scatter_2;
            }
            if(is_inside_6)
            {
                float _S1681 = (&hit_4)->distance;
                float _S1682 = upsample(_S1679.material.absorption, wavelength_9);
                float3  _S1683 = make_float3 (_S1682);
                bool _S1684 = wavelength_9 > 0.0f;
                float3  _S1685 = _slang_select(_S1684, _S1683,_S1679.material.absorption);
                float3  _S1686 = beerLambert(_S1681, _S1685);
                float3  _S1687 = throughput_3 * _S1686;
                throughput_6 = _S1687;
            }
            else
            {
                throughput_6 = throughput_3;
            }
            bool _S1688 = !_S1679.skip;
            float geometry_density_1 = (F32_abs((dot_0(_S1679.geometry_n, (&ray_3)->unit_direction)))) / ((&hit_4)->distance * (&hit_4)->distance);
            bool _S1689 = b_7 == _S1656;
            if(_S1689)
            {
                float _S1690 = 0.00251327408477664f / geometry_density_1;
                geometry_density_0 = _S1690;
            }
            else
            {
                geometry_density_0 = threshold_0;
            }
            float _S1691 = geometry_density_0;
            scatter_2 = _S1688;
            geometry_density_0 = geometry_density_1;
            threshold_0 = _S1691;
            surface_12 = _S1679;
            turned_1 = _S1675;
        }
        else
        {
            scatter_2 = false;
            geometry_density_0 = 0.0f;
            surface_12 = _S1662;
            throughput_6 = throughput_3;
            is_inside_6 = is_inside_5;
        }
        bool _S1692;
        if(scatter_2)
        {
            _S1692 = (&prev_1)->rough;
        }
        else
        {
            _S1692 = false;
        }
        bool _S1693;
        if(_S1692)
        {
            _S1693 = ((&prev_1)->pdf * geometry_density_0 * threshold_0) <= 1.0f;
        }
        else
        {
            _S1693 = false;
        }
        FKSurface _S1694 = surface_12;
        float _S1695 = dot_0(surface_12.smooth_n, - (&ray_3)->unit_direction);
        bool _S1696 = (fcptDispersionUsed());
        bool _S1697;
        if(_S1696)
        {
            _S1697 = wavelength_9 == 0.0f;
        }
        else
        {
            _S1697 = false;
        }
        bool _S1698;
        if(_S1697)
        {
            _S1698 = scatter_2;
        }
        else
        {
            _S1698 = false;
        }
        bool _S1699;
        if(_S1698)
        {
            bool _S1700 = dispersive(surface_12.material);
            _S1699 = _S1700;
        }
        else
        {
            _S1699 = false;
        }
        float3  throughput_7;
        if(_S1699)
        {
            uint _S1701 = stream(_S1543, 512U);
            Random _S1702 = pcg(_S1701);
            uint _S1703 = extractBits_0(_S1517, 25U, 7U);
            float _S1704 = (float(_S1703) + _S1702.value) / 128.0f;
            uint _S1705 = extractBits_0(_S1517, 24U, 1U);
            bool _S1706 = _S1705 == 1U;
            float _S1707 = _slang_select(_S1706, _S1704,_S1702.value);
            float2  _S1708 = sampleWavelength(_S1707);
            float wavelength_10 = _S1708.x;
            float3  _S1709 = wavelengthWeights(wavelength_10);
            float3  _S1710 = _S1709 / make_float3 (_S1708.y);
            float _S1711 = upsample(throughput_6, wavelength_10);
            float3  _S1712 = make_float3 (_S1711);
            float _S1713 = upsample(scatter_in_0, wavelength_10);
            float3  _S1714 = make_float3 (_S1713);
            scatter_in_0 = _S1714;
            float _S1715 = upsample(extinction_in_0, wavelength_10);
            float3  _S1716 = make_float3 (_S1715);
            extinction_in_0 = _S1716;
            wavelength_9 = wavelength_10;
            throughput_7 = _S1712;
            spectral_weight_1 = _S1710;
        }
        else
        {
            throughput_7 = throughput_6;
        }
        BSDFMaterial _S1717 = pathMaterial(surface_12.material, wavelength_9);
        float2  _S1718 = wavelengthEta(_S1717, _S1695, wavelength_9);
        FKSurface _S1719 = surface_12;
        Facets _S1720 = drawFacets((&ray_3)->unit_direction, _S1694.smooth_n, _S1717, surface_12.random_state);
        bool _S1721;
        if(scatter_2)
        {
            uint _S1722 = (fcptMaxBounces());
            bool _S1723 = b_7 >= _S1722;
            if(_S1723)
            {
                _S1721 = true;
            }
            else
            {
                bool _S1724 = neeDecision(_S1717, _S1695, _S1718.x, _S1718.y);
                _S1721 = _S1724;
            }
        }
        else
        {
            _S1721 = false;
        }
        bool _S1725;
        if(passes_0)
        {
            _S1725 = true;
        }
        else
        {
            _S1725 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1725)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1721;
        }
        bool _S1726 = (fcptHairUsed());
        bool _S1727;
        if(_S1726)
        {
            float3  _S1728 = surface_12.hair;
            _S1727 = (dot_0(_S1728, _S1728)) > 0.0f;
        }
        else
        {
            _S1727 = false;
        }
        bool _S1729;
        if(_S1727)
        {
            _S1729 = true;
        }
        else
        {
            BSDFMaterial _S1730 = _S1717;
            bool _S1731 = isTranslucent_0(&_S1730);
            _S1729 = _S1731;
        }
        bool _S1732;
        if(_S1729)
        {
            _S1732 = true;
        }
        else
        {
            bool _S1733 = (_S1717.transmission) > 0.0f;
            if(_S1733)
            {
                uint _S1734 = (fcptLayers((hit_4)));
                _S1732 = _S1734 == 1U;
            }
            else
            {
                _S1732 = false;
            }
        }
        float3  emission_0;
        if(_S1657)
        {
            float3  _S1735 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1735;
        }
        else
        {
            emission_0 = _S1717.emissive;
        }
        bool _S1736 = !replay_2;
        bool _S1737;
        if(_S1736)
        {
            _S1737 = true;
        }
        else
        {
            _S1737 = b_7 >= _S1531;
        }
        bool _S1738;
        if(_S1737)
        {
            float _S1739 = rgb_to_greyscale(emission_0);
            _S1738 = _S1739 > 0.0f;
        }
        else
        {
            _S1738 = false;
        }
        float3  emission_1;
        if(_S1738)
        {
            NEEVertex _S1740 = nee_vertex_1;
            FKHit _S1741 = hit_4;
            float _S1742 = emissionWeight_0(&_S1740, &_S1741, (&ray_3)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1742);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1743;
        if(replay_2)
        {
            _S1743 = _S1520 == 1U;
        }
        else
        {
            _S1743 = false;
        }
        bool _S1744;
        if(_S1743)
        {
            _S1744 = b_7 > _S1519;
        }
        else
        {
            _S1744 = false;
        }
        bool _S1745;
        if(_S1744)
        {
            _S1745 = b_7 == _S1518;
        }
        else
        {
            _S1745 = false;
        }
        bool _S1746;
        if(_S1745)
        {
            bool _S1747 = _S1521 == 1U;
            if(_S1747)
            {
                _S1746 = true;
            }
            else
            {
                _S1746 = _S1521 == 2U;
            }
        }
        else
        {
            _S1746 = false;
        }
        if(_S1746)
        {
            bool _S1748 = _S1657 != (_S1521 == 2U);
            if(_S1748)
            {
                return _S1516;
            }
            float3  _S1749 = pathColor(throughput_7 * emission_1, spectral_weight_1, wavelength_9);
            return Shift_x24init_0(_S1749 / make_float3 (r_9->jac), density_3 / r_9->jac);
        }
        uint _S1750 = extractBits_0((&chain_1)->path, 10U, 2U);
        bool _S1751 = _S1750 == 1U;
        Reservoir here_0 = chain_1;
        uint _S1752 = insertBits_0(_S1545, b_7, 5U, 5U);
        uint _S1753 = insertBits_0(_S1752, 1U, 10U, 2U);
        uint _S1754 = insertBits_0(_S1753, (&prev_1)->lobe, 15U, 3U);
        bool _S1755 = (&prev_1)->inside;
        uint _S1756 = _slang_select(_S1755, 1U,0U);
        uint _S1757 = insertBits_0(_S1754, _S1756, 22U, 1U);
        (&here_0)->path = _S1757;
        uint _S1758 = (&here_0)->path;
        bool _S1759 = wavelength_9 > 0.0f;
        uint _S1760 = _slang_select(_S1759, 1U,0U);
        uint _S1761 = insertBits_0(_S1758, _S1760, 23U, 1U);
        (&here_0)->path = _S1761;
        float _S1762 = (&prev_1)->pdf * geometry_density_0;
        (&here_0)->jac = _S1762;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1763;
        if(replay_2)
        {
            _S1763 = _S1520 == 1U;
        }
        else
        {
            _S1763 = false;
        }
        bool _S1764;
        if(_S1763)
        {
            _S1764 = b_7 == _S1519;
        }
        else
        {
            _S1764 = false;
        }
        bool _S1765 = b_7 == _S1531;
        bool _S1766;
        if(_S1765)
        {
            bool _S1767 = !scatter_2;
            if(_S1767)
            {
                _S1766 = true;
            }
            else
            {
                bool _S1768 = _S1520 != 1U;
                if(_S1768)
                {
                    _S1766 = _S1520 != 3U;
                }
                else
                {
                    _S1766 = false;
                }
            }
        }
        else
        {
            _S1766 = false;
        }
        bool _S1769;
        if(_S1766)
        {
            _S1769 = _S1520 == 2U;
        }
        else
        {
            _S1769 = false;
        }
        bool _S1770;
        if(_S1769)
        {
            _S1770 = !_S1693;
        }
        else
        {
            _S1770 = false;
        }
        bool _S1771;
        if(_S1770)
        {
            _S1771 = _S1521 != 4U;
        }
        else
        {
            _S1771 = false;
        }
        bool _S1772 = _S1519 == _S1518;
        bool _S1773;
        if(_S1772)
        {
            _S1773 = _S1521 == 0U;
        }
        else
        {
            _S1773 = false;
        }
        bool _S1774;
        if(_S1773)
        {
            _S1774 = ((&hit_4)->instance_index) == (_S1532.instance_index);
        }
        else
        {
            _S1774 = false;
        }
        bool _S1775;
        if(_S1774)
        {
            _S1775 = ((&hit_4)->triangle_index) == (_S1532.triangle_index);
        }
        else
        {
            _S1775 = false;
        }
        bool _S1776;
        if(_S1775)
        {
            _S1776 = _S1693;
        }
        else
        {
            _S1776 = false;
        }
        bool _S1777 = _slang_select(_S1764, _S1776,_S1771);
        bool _S1778;
        if(nee_0)
        {
            _S1778 = _slang_select(replay_2, _S1777,scatter_2);
        }
        else
        {
            _S1778 = false;
        }
        TreeSample _S1779 = TreeSample_x24init_0(_S1515, _S1515, 0.0f, 0U);
        uint2  _S1780 = make_uint2 (0U);
        float2  _S1781 = make_float2 (0.0f);
        FKHit _S1782 = Hit_x24init_0(_S1781, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1783 = _S1782;
        ShadowContext _S1784 = ShadowContext_x24init_0(_S1515, _S1515, _S1780, _S1515, 0U, 0U, false, 0.0f, 0.0f, &_S1783, false);
        bool _S1785;
        if(nee_0)
        {
            _S1785 = _S1737;
        }
        else
        {
            _S1785 = false;
        }
        ShadowContext context_5;
        if(_S1785)
        {
            uint _S1786 = arrivalLobe_0(b_7, (&prev_1)->lobe);
            FKMedium _S1787 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1788 = surface_12;
            FKHit _S1789 = hit_4;
            FKMedium _S1790 = _S1787;
            ShadowContext _S1791 = shadowContext_0(&_S1788, turned_1, extinction_in_0, filling_2, (&ray_3)->unit_direction, b_7, _S1786, (&hit_4)->distance, width_3, &_S1789, _S1727, &_S1790);
            context_5 = _S1791;
        }
        else
        {
            context_5 = _S1784;
        }
        float3  throughput_8;
        float3  lit_0;
        if(_S1778)
        {
            float3  _S1792 = (&ray_3)->origin;
            if(_S1727)
            {
                throughput_8 = _S1515;
            }
            else
            {
                throughput_8 = _S1694.smooth_n;
            }
            FKSurface _S1793 = surface_12;
            uint _S1794 = noiseAddress(_S1543, b_7);
            ShadowContext _S1795 = context_5;
            TreeSample _S1796 = sampleLightTree_0(_S1792, throughput_8, surface_12.geometry_n, surface_12.geometry_offset, _S1732, _S1794, &_S1795);
            bool _S1797 = any_1((_S1796.radiance) != _S1515);
            if(_S1797)
            {
                if(_S1727)
                {
                    uint _S1798 = (fcptMaxBounces());
                    bool _S1799 = b_7 < _S1798;
                    FKSurface _S1800 = surface_12;
                    TreeSample _S1801 = _S1796;
                    float3  _S1802 = hairLight_0(&_S1800, (&ray_3)->unit_direction, &_S1801, _S1799);
                    lit_0 = _S1802;
                }
                else
                {
                    float _S1803 = _S1718.x;
                    float _S1804 = _S1718.y;
                    uint _S1805 = (fcptMaxBounces());
                    bool _S1806 = b_7 < _S1805;
                    TreeSample _S1807 = _S1796;
                    BSDFMaterial _S1808 = _S1717;
                    Facets _S1809 = _S1720;
                    float3  _S1810 = lightBSDF_0((&ray_3)->unit_direction, &_S1807, _S1694.smooth_n, _S1793.geometry_n, &_S1808, _S1803, _S1804, _S1806, &_S1809);
                    lit_0 = _S1810;
                }
            }
            else
            {
                lit_0 = _S1515;
            }
            light_3 = _S1796;
        }
        else
        {
            light_3 = _S1779;
            lit_0 = _S1515;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1811;
        bool _S1812;
        float density_5;
        if(_S1764)
        {
            bool _S1813 = !_S1693;
            if(_S1813)
            {
                return _S1516;
            }
            uint _S1814 = extractBits_0(_S1517, 23U, 1U);
            bool _S1815 = _S1759 != (_S1814 == 1U);
            if(_S1815)
            {
                return _S1516;
            }
            float3  throughput_9 = throughput_7 * make_float3 (geometry_density_0);
            float density_6 = density_3 * geometry_density_0;
            if(_S1772)
            {
                viewed_1 = _S1521 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                float3  _S1816 = pathColor(throughput_9 * emission_1, spectral_weight_1, wavelength_9);
                return Shift_x24init_0(_S1816 / make_float3 (r_9->jac), density_6 / r_9->jac);
            }
            if(_S1772)
            {
                refracted_4 = _S1521 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S1817 = !nee_0;
                if(_S1817)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1818 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1818 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1516;
                }
                float3  _S1819 = pathColor(throughput_9 * lit_0, spectral_weight_1, wavelength_9);
                return Shift_x24init_0(_S1819 / make_float3 (r_9->jac), density_6 / r_9->jac);
            }
            if(_S1772)
            {
                wrong_side_0 = _S1521 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1820 = !nee_0;
                if(_S1820)
                {
                    return _S1516;
                }
                bool _S1821 = (fcptWorldReadsPath());
                if(_S1821)
                {
                    float3  _S1822 = r_9->dir;
                    float _S1823 = environmentPdf_0(r_9->dir);
                    FKSurface _S1824 = surface_12;
                    BSDFMaterial _S1825 = _S1717;
                    Facets _S1826 = _S1720;
                    FixedArray<float3 , 6>  terms_4;
                    FixedArray<float, 6>  pdfs_6;
                    float3  _S1827 = skyLobes_0((&ray_3)->unit_direction, _S1822, &_S1824, &_S1825, _S1718, is_inside_6, &_S1826, _S1823, &terms_4, &pdfs_6);
                    uint _S1828 = b_7 + 1U;
                    FixedArray<float3 , 6>  _S1829 = terms_4;
                    FixedArray<float, 6>  _S1830 = pdfs_6;
                    float3  _S1831 = skyColor_0(_S1822, &_S1829, &_S1830, _S1828);
                    float3  _S1832 = pathColor(throughput_9 * (_S1831 * r_9->radiance), spectral_weight_1, wavelength_9);
                    return Shift_x24init_0(_S1832 / make_float3 (r_9->jac), density_6 / r_9->jac);
                }
                float _S1833 = environmentPdf_0(r_9->dir);
                float3  _S1834 = skyBSDF((&ray_3)->unit_direction, r_9->dir, surface_12, _S1717, _S1718, is_inside_6, _S1720, _S1833);
                float3  _S1835 = pathColor(throughput_9 * _S1834 * r_9->radiance, spectral_weight_1, wavelength_9);
                return Shift_x24init_0(_S1835 / make_float3 (r_9->jac), density_6 / r_9->jac);
            }
            uint _S1836 = extractBits_0(_S1517, 21U, 1U);
            bool _S1837 = nee_0 != (_S1836 == 1U);
            if(_S1837)
            {
                return _S1516;
            }
            throughput_8 = throughput_9;
            density_5 = density_6;
        }
        else
        {
            if(replay_2)
            {
                viewed_1 = _S1765;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1838 = !scatter_2;
                if(_S1838)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1839 = _S1520 != 1U;
                    if(_S1839)
                    {
                        refracted_4 = _S1520 != 3U;
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
                bool _S1840 = _S1520 == 2U;
                if(_S1840)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1693;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1521 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1727)
                    {
                        return _S1516;
                    }
                    uint _S1841 = noiseAddress(_S1543, b_7);
                    FKRay _S1842 = ray_3;
                    FKSurface _S1843 = surface_12;
                    Facets _S1844 = _S1720;
                    ShadowContext _S1845 = context_5;
                    SkySample _S1846 = sampleSky_0(&_S1842, &_S1843, wavelength_9, _S1718, is_inside_6, _S1841, &_S1844, &_S1845);
                    float3  _S1847 = pathColor(throughput_7 * _S1846.color, spectral_weight_1, wavelength_9);
                    return Shift_x24init_0(_S1847, 1.0f);
                }
                if(_S1840)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1693;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1848 = rgb_to_greyscale(light_3.radiance);
                    bool _S1849 = !(_S1848 > 0.0f);
                    if(_S1849)
                    {
                        return _S1516;
                    }
                    float3  _S1850 = pathColor(throughput_7 * lit_0, spectral_weight_1, wavelength_9);
                    return Shift_x24init_0(_S1850, 1.0f);
                }
                if(_S1530)
                {
                    passes_0 = _S1521 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1657;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float3  _S1851 = pathColor(throughput_7 * emission_1, spectral_weight_1, wavelength_9);
                    return Shift_x24init_0(_S1851, 1.0f);
                }
                if(_S1530)
                {
                    passes_0 = _S1521 == 1U;
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
                    passes_0 = !_S1693;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float3  _S1852 = pathColor(throughput_7 * emission_1, spectral_weight_1, wavelength_9);
                    return Shift_x24init_0(_S1852, 1.0f);
                }
                return _S1516;
            }
            else
            {
                if(_S1736)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1853 = b_7 > 0U;
                    if(_S1853)
                    {
                        Reservoir candidate_5 = chain_1;
                        if(_S1751)
                        {
                            float3  _S1854 = safeDivide(throughput_7 * emission_1, chain_throughput_1);
                            (&candidate_5)->radiance = _S1854;
                        }
                        else
                        {
                            if(_S1693)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1855 = pathColor(throughput_7 * emission_1, spectral_weight_1, wavelength_9);
                        Reservoir _S1856 = withEnd(candidate_5, 1U, b_7, _S1855);
                        offer(sel_8, _S1856, _S1855 * make_float3 (scale_4) / make_float3 (density_3));
                    }
                    else
                    {
                        float3  _S1857 = pathColor(throughput_7 * emission_1, spectral_weight_1, wavelength_9);
                        float3  _S1858 = sel_8->glow + _S1857;
                        sel_8->glow = _S1858;
                    }
                    if(nee_0)
                    {
                        float3  _S1859 = pathColor(throughput_7 * lit_0, spectral_weight_1, wavelength_9);
                        Reservoir candidate_6 = chain_1;
                        if(_S1751)
                        {
                            float3  _S1860 = safeDivide(_S1859, chain_throughput_1);
                            (&candidate_6)->radiance = _S1860;
                        }
                        else
                        {
                            if(_S1693)
                            {
                                candidate_6 = here_0;
                                uint _S1861 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1861;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1862 = insertBits_0(_S1545, b_7 + 1U, 5U, 5U);
                                uint _S1863 = insertBits_0(_S1862, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1863;
                            }
                        }
                        Reservoir _S1864 = withEnd(candidate_6, 0U, b_7, _S1859);
                        offer(sel_8, _S1864, _S1859 * make_float3 (scale_4) / make_float3 (density_3));
                    }
                    if(nee_0)
                    {
                        if(_S1727)
                        {
                            _S1811 = false;
                        }
                        else
                        {
                            bool _S1865 = environmentMapped_0();
                            _S1811 = _S1865;
                        }
                    }
                    else
                    {
                        _S1811 = false;
                    }
                    if(_S1811)
                    {
                        uint _S1866 = (fcptMaxBounces());
                        _S1812 = b_7 < _S1866;
                    }
                    else
                    {
                        _S1812 = false;
                    }
                    if(_S1812)
                    {
                        uint _S1867 = noiseAddress(_S1543, b_7);
                        FKRay _S1868 = ray_3;
                        FKSurface _S1869 = surface_12;
                        Facets _S1870 = _S1720;
                        ShadowContext _S1871 = context_5;
                        SkySample _S1872 = sampleSky_0(&_S1868, &_S1869, wavelength_9, _S1718, is_inside_6, _S1867, &_S1870, &_S1871);
                        float3  _S1873 = pathColor(throughput_7 * _S1872.color, spectral_weight_1, wavelength_9);
                        Reservoir candidate_7 = chain_1;
                        if(_S1751)
                        {
                            float3  _S1874 = safeDivide(_S1873, chain_throughput_1);
                            (&candidate_7)->radiance = _S1874;
                        }
                        else
                        {
                            if(_S1693)
                            {
                                candidate_7 = here_0;
                                uint _S1875 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1875;
                                (&candidate_7)->dir = _S1872.dir;
                                (&candidate_7)->radiance = _S1872.radiance;
                            }
                            else
                            {
                                uint _S1876 = insertBits_0(_S1545, b_7 + 1U, 5U, 5U);
                                uint _S1877 = insertBits_0(_S1876, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1877;
                            }
                        }
                        Reservoir _S1878 = withEnd(candidate_7, 4U, b_7, _S1873);
                        offer(sel_8, _S1878, _S1873 * make_float3 (scale_4) / make_float3 (density_3));
                    }
                }
            }
            throughput_8 = throughput_7;
            density_5 = density_3;
        }
        bool _S1879;
        bool _S1880;
        bool _S1881;
        bool straight_0;
        bool _S1882;
        bool _S1883;
        bool _S1884;
        bool _S1885;
        bool _S1886;
        bool _S1887;
        bool _S1888;
        bool _S1889;
        bool _S1890;
        bool _S1891;
        bool _S1892;
        bool _S1893;
        bool _S1894;
        bool _S1895;
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
                viewed_1 = _S1765;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1896 = extractBits_0(_S1517, 15U, 3U);
            uint _S1897 = extractBits_0(_S1517, 18U, 3U);
            uint _S1898 = _slang_select(_S1764, _S1897,_S1896);
            float3  _S1899 = r_9->dir;
            bool refracted_5 = _S1898 == 1U;
            SampleBSDF _S1900 = SampleBSDF_x24init_0(_S1515, _S1515, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1900;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1901 = extractBits_0(_S1517, 22U, 1U);
                bool _S1902 = is_inside_6 != (_S1901 == 1U);
                if(_S1902)
                {
                    return _S1516;
                }
                bool _S1903 = _S1520 == 1U;
                if(_S1903)
                {
                    float3  _S1904 = (fcptHitPosition((_S1532)));
                    throughput_10 = _S1904;
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
                    BSDFMaterial _S1905 = _S1717;
                    bool _S1906 = isTranslucent_0(&_S1905);
                    if(_S1906)
                    {
                        refracted_4 = _S1898 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1907 = throughput_10 - (&ray_3)->origin;
                        float3  _S1908 = _slang_select(_S1903, _S1907,_S1899);
                        wrong_side_0 = (dot_0(_S1694.smooth_n, _S1908) * _S1695) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1903)
                {
                    float3  _S1909 = (&ray_3)->origin;
                    FKSurface _S1910 = surface_12;
                    float3  _S1911 = - _S1694.smooth_n;
                    bool _S1912 = is_inside_6 != refracted_4;
                    float3  _S1913 = _slang_select(_S1912, _S1911,_S1694.smooth_n);
                    float3  _S1914 = throughput_10 - (_S1909 + make_float3 (_S1910.geometry_offset) * _S1913);
                    float3  _S1915 = ((((_S1914)) * make_float3(rnorm3df(((_S1914)).x, ((_S1914)).y, ((_S1914)).z))));
                    reconnection_1 = _S1915;
                }
                else
                {
                    reconnection_1 = _S1899;
                }
                if(_S1727)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1916 = wrongSide_0(is_inside_6, refracted_4, reconnection_1, surface_12.geometry_n);
                    wrong_side_0 = _S1916;
                }
                if(wrong_side_0)
                {
                    return _S1516;
                }
                float3  _S1917 = throughput_10;
                throughput_10 = reconnection_1;
                b_10 = _S1898;
                wrong_side_0 = false;
                reconnection_1 = _S1917;
            }
            else
            {
                bool _S1918 = !_S1764;
                if(_S1918)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1919;
                    if(_S1727)
                    {
                        SampleBSDF _S1920 = (fcptSampleHair((surface_12.hair), (_S1717.albedo), (_S1717.specular_tint), ((&ray_3)->unit_direction), (_S1719.random_state)));
                        _S1919 = _S1920;
                    }
                    else
                    {
                        SampleBSDF _S1921 = sampleBSDF((&ray_3)->unit_direction, _S1694.smooth_n, _S1717, _S1718.x, _S1718.y, _S1720, _S1719.random_state, _S1781);
                        _S1919 = _S1921;
                    }
                    bsdf_sampled_0 = _S1919;
                    if(_S1727)
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
                            return _S1516;
                        }
                        break;
                    }
                    if(_S1727)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1922 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_12.geometry_n);
                        wrong_side_0 = _S1922;
                    }
                    if(wrong_side_0)
                    {
                        _S1811 = (_S1717.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1811 = false;
                    }
                    if(_S1811)
                    {
                        float _S1923 = _S1718.x;
                        float _S1924 = _S1718.y;
                        Facets _S1925 = drawFacets((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S1717, (&bsdf_sampled_0)->random_state);
                        SampleBSDF _S1926 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S1717, _S1923, _S1924, _S1925, (&bsdf_sampled_0)->random_state, _S1781);
                        (&bsdf_sampled_0)->unit_direction = _S1926.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1926.refracted;
                        (&bsdf_sampled_0)->throughput = _S1926.throughput;
                        (&bsdf_sampled_0)->lobe = _S1926.lobe;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1927 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n)) * surface_12.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1927;
                        }
                    }
                    uint _S1928 = (&bsdf_sampled_0)->lobe;
                    float3  _S1929 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1930 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1931 = (&bsdf_sampled_0)->pdf;
                    float _S1932 = _slang_select(wrong_side_0, 0.0f,_S1931);
                    (&lobe_5)->pdf = _S1932;
                    throughput_10 = _S1929;
                    b_10 = _S1928;
                    refracted_4 = _S1930;
                }
                else
                {
                    throughput_10 = _S1899;
                    b_10 = _S1898;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1811 = true;
            }
            else
            {
                _S1811 = _S1764;
            }
            if(_S1811)
            {
                if(_S1727)
                {
                    SampleBSDF _S1933 = (fcptConnectHair((surface_12.hair), (_S1717.albedo), (_S1717.specular_tint), ((&ray_3)->unit_direction), (throughput_10)));
                    lobe_5 = _S1933;
                }
                else
                {
                    float3  _S1934 = (&ray_3)->unit_direction;
                    float3  _S1935 = negate_0(_S1934);
                    float _S1936 = sign_0(_S1695);
                    float3  _S1937 = _S1694.smooth_n * make_float3 (_S1936);
                    float _S1938 = dot_0(_S1937, throughput_10);
                    float _S1939 = _S1717.roughness;
                    float _S1940 = _S1939 * _S1939;
                    AnisotropicFrame _S1941 = anisotropicFrame(_S1717, _S1937);
                    SheenProfile _S1942 = sheenProfile(_S1935, _S1937, _S1717);
                    CoatFrame _S1943 = coatFrame(_S1717, _S1937);
                    float3  _S1944 = coatSeries(_S1943, _S1717);
                    float3  _S1945 = reflectedHalf(_S1934, throughput_10);
                    bool _S1946 = b_10 == 1U;
                    if(_S1946)
                    {
                        float3  _S1947 = refractedHalf(_S1934, throughput_10, _S1694.smooth_n, _S1718.x, _S1718.y);
                        throughput_11 = _S1947;
                    }
                    else
                    {
                        throughput_11 = _S1945;
                    }
                    float3  _S1948 = _S1720.coat_h;
                    bool _S1949 = (dot_0(_S1948, _S1948)) > 0.0f;
                    float3  _S1950 = _slang_select(_S1949, _S1945,_S1515);
                    float _S1951 = _S1718.x;
                    float _S1952 = _S1718.y;
                    Weights _S1953 = lobeWeights(_S1934, _S1935, _S1937, _S1720.h, _S1720.coat_h, throughput_11, _S1950, _S1941, _S1942, _S1943, _S1944, _S1717, _S1951, _S1952);
                    float _S1954 = (F32_abs((_S1695)));
                    float _S1955 = vndfPDF(_S1935, throughput_11, _S1937, _S1954, _S1940, _S1941, _S1953.v_dot_h);
                    switch(b_10)
                    {
                    case 0U:
                        {
                            float _S1956 = diffusePDF(_S1938, _S1954, _S1717, _S1953);
                            float3  _S1957 = diffuseBSDF(throughput_10, _S1937, _S1717, _S1953);
                            density_7 = _S1956;
                            throughput_12 = _S1957;
                            break;
                        }
                    case 1U:
                        {
                            float _S1958 = refractPDF(dot_0(throughput_10, throughput_11), _S1955, _S1953, _S1951, _S1952);
                            float _S1959 = maskingG1(throughput_10, _S1937, -1.0f, _S1940, _S1941);
                            float3  _S1960 = refractBSDF(_S1959, _S1717, _S1953);
                            density_7 = _S1958;
                            throughput_12 = _S1960;
                            break;
                        }
                    case 4U:
                        {
                            float _S1961 = sheenVelvetPDF(_S1938, _S1954, _S1953);
                            float3  _S1962 = sheenVelvetBSDF(throughput_10, _S1935, _S1937, _S1717, _S1953);
                            density_7 = _S1961;
                            throughput_12 = _S1962;
                            break;
                        }
                    case 5U:
                        {
                            float _S1963 = coatPDF(_S1935, _S1950, _S1943, _S1953);
                            float3  _S1964 = coatBSDF(_S1953);
                            density_7 = _S1963;
                            throughput_12 = _S1964;
                            break;
                        }
                    case 6U:
                        {
                            ToonProfile _S1965 = toonProfile(_S1935, _S1937, _S1717);
                            float _S1966 = toonPDF(throughput_10, _S1937, _S1965, _S1953);
                            float3  _S1967 = toonBSDF(throughput_10, _S1937, _S1965, _S1953);
                            density_7 = _S1966;
                            throughput_12 = _S1967;
                            break;
                        }
                    default:
                        {
                            float _S1968 = reflectPDF(_S1955, _S1953);
                            float _S1969 = maskingG1(throughput_10, _S1937, 1.0f, _S1940, _S1941);
                            float3  _S1970 = reflectBSDF(_S1969, _S1953);
                            density_7 = _S1968;
                            throughput_12 = _S1970;
                            break;
                        }
                    }
                    bool _S1971 = density_7 > 0.0f;
                    if(_S1971)
                    {
                        SampleBSDF _S1972 = SampleBSDF_x24init_0(throughput_10, throughput_12, _S1719.random_state, _S1946, b_10, density_7);
                        lobe_5 = _S1972;
                    }
                }
            }
            bool _S1973 = b_10 == 0U;
            if(_S1973)
            {
                _S1812 = true;
            }
            else
            {
                _S1812 = b_10 == 4U;
            }
            if(_S1812)
            {
                _S1879 = true;
            }
            else
            {
                _S1879 = b_10 == 6U;
            }
            bool _S1974 = b_10 == 5U;
            float _S1975 = _slang_select(_S1974, _S1717.coat_roughness,_S1717.roughness);
            if(_S1727)
            {
                _S1880 = false;
            }
            else
            {
                bool _S1976 = !_S1879;
                if(_S1976)
                {
                    bool _S1977 = _S1975 == 0.0f;
                    if(_S1977)
                    {
                        _S1880 = true;
                    }
                    else
                    {
                        bool _S1978 = b_10 == 1U;
                        if(_S1978)
                        {
                            _S1880 = (_S1718.x) == (_S1718.y);
                        }
                        else
                        {
                            _S1880 = false;
                        }
                    }
                }
                else
                {
                    _S1880 = false;
                }
            }
            bool _S1979 = !_S1727;
            if(_S1979)
            {
                _S1881 = b_10 == 1U;
            }
            else
            {
                _S1881 = false;
            }
            if(_S1881)
            {
                straight_0 = (_S1717.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1882 = _S1979;
            }
            else
            {
                _S1882 = false;
            }
            if(_S1882)
            {
                _S1883 = b_10 == 1U;
            }
            else
            {
                _S1883 = false;
            }
            if(_S1883)
            {
                _S1884 = (_S1718.x) == (_S1718.y);
            }
            else
            {
                _S1884 = false;
            }
            BSDFMaterial _S1980 = _S1717;
            bool _S1981 = isTranslucent_0(&_S1980);
            if(_S1981)
            {
                _S1885 = _S1973;
            }
            else
            {
                _S1885 = false;
            }
            if(_S1885)
            {
                _S1886 = (dot_0(throughput_10, surface_12.geometry_n)) < 0.0f;
            }
            else
            {
                _S1886 = false;
            }
            if(nee_0)
            {
                _S1887 = !_S1880;
            }
            else
            {
                _S1887 = false;
            }
            if(_S1887)
            {
                _S1888 = !wrong_side_0;
            }
            else
            {
                _S1888 = false;
            }
            if(_S1888)
            {
                float _S1982 = (&lobe_5)->pdf;
                float3  _S1983 = (&ray_3)->origin;
                float3  _S1984 = _slang_select(_S1732, _S1515,_S1694.smooth_n);
                float3  _S1985 = (&ray_3)->origin;
                FKSurface _S1986 = surface_12;
                float3  _S1987 = - _S1694.smooth_n;
                float3  _S1988 = _slang_select(_S1886, _S1987,_S1694.smooth_n);
                NEEVertex _S1989 = NEEVertex_x24init_0(false, _S1982, _S1983, _S1984, _S1985 + make_float3 (_S1986.geometry_offset) * _S1988);
                nee_vertex_1 = _S1989;
            }
            else
            {
                if(_S1727)
                {
                    _S1889 = true;
                }
                else
                {
                    bool _S1990 = b_10 != 1U;
                    if(_S1990)
                    {
                        _S1889 = true;
                    }
                    else
                    {
                        _S1889 = (_S1718.x) != (_S1718.y);
                    }
                }
                if(_S1889)
                {
                    (&nee_vertex_1)->none = true;
                }
            }
            bool _S1991 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1991)
            {
                if(_S1879)
                {
                    _S1889 = true;
                }
                else
                {
                    _S1889 = ((&lobe_5)->pdf * (&prev_1)->cos / ((&hit_4)->distance * (&hit_4)->distance) * threshold_0) <= 1.0f;
                }
            }
            else
            {
                _S1889 = false;
            }
            bool _S1992 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1992)
            {
                if(_S1879)
                {
                    _S1890 = true;
                }
                else
                {
                    _S1890 = _S1975 >= 0.20000000298023224f;
                }
            }
            else
            {
                _S1890 = false;
            }
            if(_S1764)
            {
                bool _S1993 = !_S1889;
                if(_S1993)
                {
                    return _S1516;
                }
                bool _S1994 = _S1521 != 1U;
                if(_S1994)
                {
                    _S1891 = _S1521 != 2U;
                }
                else
                {
                    _S1891 = false;
                }
                if(_S1891)
                {
                    float _S1995 = (&lobe_5)->pdf;
                    float _S1996 = _slang_select(nee_0, _S1995,0.0f);
                    float _S1997 = escapeWeight_0(_S1996, _S1899);
                    if(_S1772)
                    {
                        passes_0 = _S1527;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1998 = _slang_select(passes_0, _S1997,1.0f);
                    return Shift_x24init_0(throughput_8 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_9->radiance * make_float3 (_S1998) / make_float3 (r_9->jac), density_5 * (&lobe_5)->pdf / r_9->jac);
                }
                float3  _S1999 = throughput_8 * make_float3 ((&lobe_5)->pdf);
                float _S2000 = density_5 * (&lobe_5)->pdf;
                throughput_11 = _S1999;
                density_7 = _S2000;
            }
            else
            {
                throughput_11 = throughput_8;
                density_7 = density_5;
            }
            uint _S2001 = (fcptLayers((hit_4)));
            bool _S2002 = _S2001 > 1U;
            if(_S2002)
            {
                _S1891 = (b_10 == 1U) != passes_0;
            }
            else
            {
                _S1891 = false;
            }
            if(viewed_1)
            {
                _S1892 = _S1891;
            }
            else
            {
                _S1892 = false;
            }
            if(_S1892)
            {
                return _S1516;
            }
            if(replay_2)
            {
                _S1893 = b_7 <= _S1531;
            }
            else
            {
                _S1893 = false;
            }
            if(_S1893)
            {
                _S1894 = _S1693;
            }
            else
            {
                _S1894 = false;
            }
            if(_S1894)
            {
                _S1895 = _S1889;
            }
            else
            {
                _S1895 = false;
            }
            bool _S2003;
            if(_S1895)
            {
                _S2003 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S2003 = !_S1890;
                }
                else
                {
                    _S2003 = false;
                }
            }
            if(_S2003)
            {
                return _S1516;
            }
            if(viewed_1)
            {
                float3  _S2004 = throughput_11 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S2005 = (&lobe_5)->pdf;
                throughput_12 = _S2004;
                sky_pdf_3 = _S2005;
            }
            else
            {
                float3  _S2006 = throughput_11 * max_0((&lobe_5)->throughput, _S1515);
                throughput_12 = _S2006;
                sky_pdf_3 = density_7;
            }
            bool _S2007;
            if(_S1736)
            {
                _S2007 = !_S1751;
            }
            else
            {
                _S2007 = false;
            }
            bool _S2008;
            if(_S2007)
            {
                _S2008 = _S1693;
            }
            else
            {
                _S2008 = false;
            }
            bool _S2009;
            if(_S2008)
            {
                _S2009 = _S1889;
            }
            else
            {
                _S2009 = false;
            }
            float3  chain_throughput_2;
            if(_S2009)
            {
                chain_1 = here_0;
                uint _S2010 = insertBits_0((&chain_1)->path, b_10, 18U, 3U);
                uint _S2011 = _slang_select(nee_0, 1U,0U);
                uint _S2012 = insertBits_0(_S2010, _S2011, 21U, 1U);
                (&chain_1)->path = _S2012;
                float _S2013 = (&chain_1)->jac * (&lobe_5)->pdf;
                (&chain_1)->jac = _S2013;
                (&chain_1)->dir = throughput_10;
                chain_throughput_2 = throughput_12;
            }
            else
            {
                chain_throughput_2 = chain_throughput_1;
            }
            FKSurface _S2014 = surface_12;
            Vertex _S2015 = Vertex_x24init_0(_S1890, b_10, (&lobe_5)->pdf, (F32_abs((dot_0(surface_12.geometry_n, throughput_10)))), is_inside_6);
            prev_1 = _S2015;
            float _S2016 = (&lobe_5)->pdf;
            bool _S2017 = b_10 == 1U;
            bool _S2018;
            if(_S2017)
            {
                _S2018 = (_S1718.x) == (_S1718.y);
            }
            else
            {
                _S2018 = false;
            }
            float sky_pdf_4 = _slang_select(_S2018, sky_pdf_1,_S2016);
            float _S2019 = _slang_select(_S1727, 0.0f,sky_pdf_4);
            float _S2020 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * (&lobe_5)->pdf))))), (3.14159274101257324f)));
            bool _S2021 = !_S1880;
            float _S2022 = _slang_select(_S2021, _S2020,0.0f);
            float _S2023 = spread_1 + _S2022;
            bool _S2024;
            if(refracted_4)
            {
                _S2024 = !_S1886;
            }
            else
            {
                _S2024 = false;
            }
            bool is_inside_7;
            if(_S2024)
            {
                bool _S2025 = !is_inside_6;
                is_inside_7 = _S2025;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            FKSurface _S2026 = surface_12;
            bool _S2027 = boundsVolume_0(&_S2026);
            bool _S2028;
            if(_S2027)
            {
                _S2028 = !_S1891;
            }
            else
            {
                _S2028 = false;
            }
            if(_S2028)
            {
                FKSurface faced_2 = surface_12;
                float3  _S2029 = - _S2014.geometry_n;
                float3  _S2030 = _slang_select(turned_1, _S2029,_S2014.geometry_n);
                (&faced_2)->geometry_n = _S2030;
                FKMedium _S2031 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S2032 = (fcptOutsideMedium((hit_4)));
                FKSurface _S2033 = faced_2;
                FKMedium _S2034 = _S2031;
                FKMedium _S2035 = _S2032;
                MediumSides _S2036 = mediumSides_0(&_S2033, &_S2034, filling_2, (&ray_3)->unit_direction, &_S2035);
                bool _S2037 = ((dot_0(throughput_10, _S2014.geometry_n)) > 0.0f) == ((dot_0(_S2014.geometry_n, (&faced_2)->geometry_n)) > 0.0f);
                float3  _S2038 = _slang_select(_S2037, _S2036.front.scatter,_S2036.behind.scatter);
                scatter_in_0 = _S2038;
                float3  _S2039 = scatter_in_0;
                float _S2040 = upsample(scatter_in_0, wavelength_9);
                float3  _S2041 = make_float3 (_S2040);
                float3  _S2042 = _slang_select(_S1759, _S2041,_S2039);
                scatter_in_0 = _S2042;
                float3  _S2043 = _slang_select(_S2037, _S2036.front.extinction,_S2036.behind.extinction);
                extinction_in_0 = _S2043;
                float3  _S2044 = extinction_in_0;
                float _S2045 = upsample(extinction_in_0, wavelength_9);
                float3  _S2046 = make_float3 (_S2045);
                float3  _S2047 = _slang_select(_S1759, _S2046,_S2044);
                extinction_in_0 = _S2047;
                float _S2048 = _slang_select(_S2037, _S2036.front.g,_S2036.behind.g);
                g_in_0 = _S2048;
                uint _S2049 = _S2036.fillings.x;
                uint _S2050 = _S2036.fillings.y;
                uint _S2051 = _slang_select(_S2037, _S2050,_S2049);
                bool _S2052 = (fcptVaryingUsed());
                uint _S2053 = _slang_select(_S2052, _S2051,4294967295U);
                filling_2 = _S2053;
            }
            (&ray_3)->unit_direction = throughput_10;
            bool _S2054 = !_S1891;
            if(_S2054)
            {
                FKSurface _S2055 = surface_12;
                float _S2056 = _slang_select(straight_0, 0.0f,_S2055.geometry_offset);
                float3  _S2057 = - _S1694.smooth_n;
                bool _S2058 = is_inside_7 != _S1886;
                float3  _S2059 = _slang_select(_S2058, _S2057,_S1694.smooth_n);
                float3  _S2060 = (&ray_3)->origin + make_float3 (_S2056) * _S2059;
                (&ray_3)->origin = _S2060;
            }
            throughput_11 = throughput_12;
            chain_throughput_1 = chain_throughput_2;
            density_7 = sky_pdf_3;
            passes_0 = _S1891;
            viewed_1 = _S1884;
            sky_pdf_3 = _S2019;
            spread_4 = _S2023;
            reconnection_0 = reconnection_1;
            is_inside_5 = is_inside_7;
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
            is_inside_5 = is_inside_6;
        }
        float density_8;
        if(_S1736)
        {
            if(_S1657)
            {
                float3  _S2061 = pathColor(throughput_11 * emission_1, spectral_weight_1, wavelength_9);
                Reservoir candidate_8 = chain_1;
                uint _S2062 = extractBits_0((&chain_1)->path, 10U, 2U);
                bool _S2063 = _S2062 == 1U;
                if(_S2063)
                {
                    float3  _S2064 = safeDivide(_S2061, chain_throughput_1);
                    (&candidate_8)->radiance = _S2064;
                }
                Reservoir _S2065 = withEnd(candidate_8, 2U, b_7, _S2061);
                offer(sel_8, _S2065, _S2061 * make_float3 (scale_4) / make_float3 (density_7));
            }
            if(_S1657)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S2066 = survivalProbability(abs_0(throughput_11), density_7);
                density_8 = _S2066;
            }
            else
            {
                density_8 = 1.0f;
            }
            uint _S2067 = (fcptMaxBounces());
            bool _S2068 = b_7 >= _S2067;
            if(_S2068)
            {
                wrong_side_0 = true;
            }
            else
            {
                bool _S2069 = density_8 < 1.0f;
                if(_S2069)
                {
                    uint _S2070 = noiseAddress(_S1543, b_7);
                    Random _S2071 = draw(_S2070, 8U);
                    wrong_side_0 = density_8 < (_S2071.value);
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
            float _S2072 = density_7 * density_8;
            density_8 = _S2072;
        }
        else
        {
            density_8 = density_7;
        }
        uint _S2073 = layer_0 ^ 1U;
        uint _S2074 = _slang_select(passes_0, _S2073,0U);
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
            uint _S2075 = b_10 + 1U;
            b_7 = _S2075;
            layer_0 = _S2074;
            continue;
        }
        FKRay _S2076 = ray_3;
        float _S2077 = distance_1(reconnection_0, (&ray_3)->origin) * 1.0010000467300415f;
        if(replay_2)
        {
            refracted_4 = _S1765;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S1520 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S2078 = _slang_select(wrong_side_0, _S2077,4.294967296e+09f);
        bool _S2079 = !_S1727;
        if(straight_0)
        {
            _S1811 = true;
        }
        else
        {
            _S1811 = _S1727;
        }
        FKHit _S2080;
        if(_S1811)
        {
            _S2080 = hit_4;
        }
        else
        {
            _S2080 = _S1782;
        }
        FKHit _S2081 = (fcptTraverseInstanceBVH((_S2076), (_S1663), (_S2078), (_S2079), (_S2080), (viewed_1)));
        hit_4 = _S2081;
        if(replay_2)
        {
            _S1812 = _S1765;
        }
        else
        {
            _S1812 = false;
        }
        if(_S1812)
        {
            _S1879 = _S1520 == 1U;
        }
        else
        {
            _S1879 = false;
        }
        if(_S1879)
        {
            _S1880 = ((&hit_4)->instance_index) == (_S1532.instance_index);
        }
        else
        {
            _S1880 = false;
        }
        if(_S1880)
        {
            _S1881 = ((&hit_4)->triangle_index) == (_S1532.triangle_index);
        }
        else
        {
            _S1881 = false;
        }
        if(_S1881)
        {
            (&hit_4)->uv = _S1532.uv;
            float _S2082 = distance_1(reconnection_0, (&ray_3)->origin);
            (&hit_4)->distance = _S2082;
        }
        if(replay_2)
        {
            _S1882 = _S1765;
        }
        else
        {
            _S1882 = false;
        }
        if(_S1882)
        {
            _S1883 = _S1520 == 3U;
        }
        else
        {
            _S1883 = false;
        }
        if(_S1883)
        {
            _S1884 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1884 = false;
        }
        if(_S1884)
        {
            return _S1516;
        }
        Reservoir _S2083 = chain_1;
        uint _S2084 = filling_2;
        for(;;)
        {
            bool _S2085 = (fcptVaryingUsed());
            if(_S2085)
            {
                _S1885 = _S2084 != 4294967295U;
            }
            else
            {
                _S1885 = false;
            }
            if(_S1885)
            {
                float _S2086 = (fcptMajorant((_S2084)));
                _S1886 = _S2086 > 0.0f;
            }
            else
            {
                _S1886 = any_1(scatter_in_0 > make_float3 (0.0f));
            }
            if(replay_2)
            {
                _S1887 = _S1765;
            }
            else
            {
                _S1887 = false;
            }
            if(_S1887)
            {
                _S1888 = _S1520 == 1U;
            }
            else
            {
                _S1888 = false;
            }
            if(_S1888)
            {
                _S1889 = _S1886;
            }
            else
            {
                _S1889 = false;
            }
            if(_S1889)
            {
                ended_0 = _S1516;
                sky_pdf_2 = sky_pdf_3;
                spread_2 = spread_4;
                width_4 = width_3;
                density_4 = density_8;
                throughput_12 = throughput_11;
                b_10 = b_7;
                _S1890 = true;
                break;
            }
            bool _S2087 = (&prev_1)->rough;
            if(_S2087)
            {
                _S1890 = !_S1886;
            }
            else
            {
                _S1890 = false;
            }
            (&prev_1)->rough = _S1890;
            uint _S2088 = b_7 + 320U;
            bool _S2089 = b_7 == 4294967295U;
            uint _S2090 = _slang_select(_S2089, 384U,_S2088);
            uint _S2091 = stream(_S1543, _S2090);
            uint tracking_1 = _S2091;
            weight_2 = throughput_4;
            glowed_0 = _S1515;
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
                    _S1514 = int(2);
                    break;
                }
                float _S2092 = (&hit_4)->distance;
                if(_S1885)
                {
                    float3  _S2093 = (&ray_3)->origin;
                    float3  _S2094 = (&ray_3)->unit_direction;
                    float _S2095 = (&hit_4)->distance;
                    bool _S2096 = b_10 == 4294967295U;
                    uint _S2097 = _slang_select(_S2096, 0U,b_10);
                    uint _S2098 = (&prev_1)->lobe;
                    uint _S2099 = _slang_select(_S2096, 3U,_S2098);
                    float _S2100 = (fcptTrackMedium((_S2084), (_S2093), (_S2094), (_S2095), (&tracking_1), (&weight_2), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S2097), (_S2099), (_S2096)));
                    spread_3 = _S2100;
                }
                else
                {
                    if(_S1886)
                    {
                        uint _S2101 = noiseAddress(_S1543, b_10);
                        Random _S2102 = draw(_S2101, 10U);
                        float _S2103 = 3.0f * _S2102.value;
                        uint _S2104 = (U32_min((uint(_S2103)), (2U)));
                        float _S2105 = - (F32_log((1.0f - (_S2103 - float(_S2104))))) / *_slang_vector_get_element_ptr(&scatter_in_0, _S2104);
                        spread_3 = _S2105;
                    }
                    else
                    {
                        spread_3 = _S2092;
                    }
                }
                bool _S2106 = !(spread_3 < ((&hit_4)->distance));
                if(_S2106)
                {
                    _S1514 = int(2);
                    break;
                }
                if(_S1885)
                {
                    _S1891 = _S1736;
                }
                else
                {
                    _S1891 = false;
                }
                if(_S1891)
                {
                    float3  _S2107 = pathColor(throughput_12 * glowed_0, spectral_weight_1, wavelength_9);
                    float3  _S2108 = _S2107 / make_float3 (density_4);
                    float3  _S2109 = sel_8->glow + _S2108;
                    sel_8->glow = _S2109;
                }
                else
                {
                }
                glowed_0 = _S1515;
                uint b_11 = b_10 + 1U;
                float3  _S2110 = (&ray_3)->origin + make_float3 (spread_3) * (&ray_3)->unit_direction;
                (&ray_3)->origin = _S2110;
                float3  _S2111 = flightWeight_0(scatter_in_0, extinction_in_0, spread_3, true);
                float3  _S2112 = weight_2;
                float _S2113 = upsample(weight_2, wavelength_9);
                float3  _S2114 = make_float3 (_S2113);
                float3  _S2115 = _slang_select(_S1759, _S2114,_S2112);
                float3  _S2116 = _slang_select(_S1885, _S2115,_S2111);
                float3  throughput_13 = throughput_12 * _S2116;
                uint _S2117 = stream(_S1543, b_11 + 320U);
                tracking_1 = _S2117;
                weight_2 = throughput_4;
                float width_8 = width_4 + spread_2 * spread_3;
                float _S2118 = spread_2 + 3.14159274101257324f;
                if(_S1736)
                {
                    _S1892 = true;
                }
                else
                {
                    bool _S2119 = b_11 == _S1531;
                    if(_S2119)
                    {
                        _S1892 = !_S1885;
                    }
                    else
                    {
                        _S1892 = false;
                    }
                }
                TreeSample light_4;
                if(_S1892)
                {
                    float3  _S2120 = (&ray_3)->origin;
                    float3  _S2121 = (&ray_3)->unit_direction;
                    float3  _S2122 = (&ray_3)->unit_direction;
                    uint _S2123 = noiseAddress(_S1543, b_11);
                    float3  _S2124 = extinction_in_0;
                    float3  _S2125 = extinction_in_0;
                    uint2  _S2126 = make_uint2 (_S2084);
                    float3  _S2127 = (&ray_3)->unit_direction;
                    uint _S2128 = arrivalLobe_0(b_11, (&prev_1)->lobe);
                    FKHit _S2129 = _S1782;
                    ShadowContext _S2130 = ShadowContext_x24init_0(_S2124, _S2125, _S2126, _S2127, b_11, _S2128, false, spread_3, width_8, &_S2129, false);
                    ShadowContext _S2131 = _S2130;
                    TreeSample _S2132 = sampleLightTree_0(_S2120, _S2121, _S2122, 0.0f, true, _S2123, &_S2131);
                    light_4 = _S2132;
                }
                else
                {
                    light_4 = _S1779;
                }
                float _S2133 = phaseHG_0(g_in_0, dot_0((&ray_3)->unit_direction, light_4.dir));
                uint _S2134 = (fcptMaxBounces());
                bool _S2135 = b_11 < _S2134;
                if(_S2135)
                {
                    _S1893 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1893 = false;
                }
                float _S2136 = _slang_select(_S1893, _S2133,0.0f);
                float3  _S2137 = throughput_13 * light_4.radiance;
                float _S2138 = powerHeuristic(light_4.density, _S2136);
                float3  _S2139 = pathColor(_S2137 * make_float3 (_S2133 * _S2138), spectral_weight_1, wavelength_9);
                float3  _S2140 = _slang_select(_S1892, _S2139,_S1515);
                if(replay_2)
                {
                    _S1894 = b_11 == _S1531;
                }
                else
                {
                    _S1894 = false;
                }
                if(_S1894)
                {
                    bool _S2141 = _S1520 == 2U;
                    if(_S2141)
                    {
                        float _S2142 = resamplingTarget(_S2140);
                        _S1895 = _S2142 > 0.0f;
                    }
                    else
                    {
                        _S1895 = false;
                    }
                    if(_S1895)
                    {
                        Shift _S2143 = Shift_x24init_0(_S2140, 1.0f);
                        _S1514 = int(1);
                        ended_0 = _S2143;
                        spread_3 = _S2118;
                        width_5 = width_8;
                        throughput_10 = throughput_13;
                        b_8 = b_11;
                        break;
                    }
                    _S1514 = int(1);
                    ended_0 = _S1516;
                    spread_3 = _S2118;
                    width_5 = width_8;
                    throughput_10 = throughput_13;
                    b_8 = b_11;
                    break;
                }
                if(_S1736)
                {
                    Reservoir candidate_9 = _S2083;
                    uint _S2144 = extractBits_0(_S2083.path, 24U, 8U);
                    uint _S2145 = insertBits_0(0U, _S2144, 24U, 8U);
                    uint _S2146 = extractBits_0(_S2083.path, 10U, 2U);
                    bool _S2147 = _S2146 == 1U;
                    if(_S2147)
                    {
                        float3  _S2148 = safeDivide(_S2140, chain_throughput_1);
                        (&candidate_9)->radiance = _S2148;
                    }
                    else
                    {
                        uint _S2149 = insertBits_0(_S2145, b_11 + 1U, 5U, 5U);
                        uint _S2150 = insertBits_0(_S2149, 2U, 10U, 2U);
                        (&candidate_9)->path = _S2150;
                    }
                    Reservoir _S2151 = withEnd(candidate_9, 0U, b_11, _S2140);
                    offer(sel_8, _S2151, _S2140 * make_float3 (scale_4) / make_float3 (density_4));
                    float _S2152 = survivalProbability(abs_0(throughput_13), density_4);
                    uint _S2153 = (fcptMaxBounces());
                    bool _S2154 = b_11 >= _S2153;
                    if(_S2154)
                    {
                        _S1895 = true;
                    }
                    else
                    {
                        bool _S2155 = _S2152 < 1.0f;
                        if(_S2155)
                        {
                            uint _S2156 = noiseAddress(_S1543, b_11);
                            Random _S2157 = draw(_S2156, 8U);
                            _S1895 = _S2152 < (_S2157.value);
                        }
                        else
                        {
                            _S1895 = false;
                        }
                    }
                    if(_S1895)
                    {
                        _S1514 = int(1);
                        ended_0 = _S1516;
                        spread_3 = _S2118;
                        width_5 = width_8;
                        throughput_10 = throughput_13;
                        b_8 = b_11;
                        break;
                    }
                    float _S2158 = density_4 * _S2152;
                    density_4 = _S2158;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S2159 = noiseAddress(_S1543, b_11);
                float3  _S2160 = samplePhase_0(g_in_0, (&ray_3)->unit_direction, _S2159, &phase_pdf_1);
                (&ray_3)->unit_direction = _S2160;
                NEEVertex _S2161 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_3)->origin, _S1515, (&ray_3)->origin);
                nee_vertex_1 = _S2161;
                Vertex _S2162 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_5);
                prev_1 = _S2162;
                float _S2163 = (&prev_1)->pdf;
                FKRay _S2164 = ray_3;
                FKHit _S2165 = (fcptTraverseInstanceBVH((_S2164), (true), (4.294967296e+09f), (false), (_S1782), (false)));
                hit_4 = _S2165;
                b_10 = b_11;
                throughput_12 = throughput_13;
                spread_2 = _S2118;
                width_4 = width_8;
                sky_pdf_2 = _S2163;
            }
            if(_S1514 != int(2))
            {
                spread_2 = spread_3;
                width_4 = width_5;
                throughput_12 = throughput_10;
                b_10 = b_8;
                _S1890 = true;
                break;
            }
            ended_0 = _S1516;
            _S1890 = false;
            break;
        }
        if(_S1890)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1891 = b_10 == b_7;
        }
        else
        {
            _S1891 = false;
        }
        bool _S2166 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S2166)
        {
            Reservoir _S2167 = chain_1;
            FKRay _S2168 = ray_3;
            Vertex _S2169 = prev_1;
            NEEVertex _S2170 = nee_vertex_1;
            Shift _S2171 = escape_0(r_9, replay_2, _S1531, _S1520, _S1518, _S1521, scale_4, _S1545, &_S2167, chain_throughput_1, b_10, &_S2168, throughput_12, density_4, &_S2169, &_S2170, sky_pdf_2, spectral_weight_1, wavelength_9, sel_8);
            return _S2171;
        }
        FKHit _S2172 = hit_4;
        uint _S2173 = filling_2;
        float3  _S2174 = scatter_in_0;
        float3  _S2175 = extinction_in_0;
        float3  _S2176 = weight_2;
        float3  _S2177 = glowed_0;
        float3  _S2178 = (&ray_3)->origin + make_float3 (_S2172.distance) * (&ray_3)->unit_direction;
        (&ray_3)->origin = _S2178;
        bool _S2179 = (fcptVaryingUsed());
        if(_S2179)
        {
            _S1892 = _S2173 != 4294967295U;
        }
        else
        {
            _S1892 = false;
        }
        if(_S1892)
        {
            if(_S1736)
            {
                float3  _S2180 = pathColor(throughput_12 * _S2177, spectral_weight_1, wavelength_9);
                float3  _S2181 = _S2180 / make_float3 (density_4);
                float3  _S2182 = sel_8->glow + _S2181;
                sel_8->glow = _S2182;
            }
            else
            {
            }
            float3  _S2183 = throughput_12 * _S2176;
            throughput_10 = _S2183;
        }
        else
        {
            float3  _S2184 = flightWeight_0(_S2174, _S2175, _S2172.distance, false);
            float3  _S2185 = throughput_12 * _S2184;
            throughput_10 = _S2185;
        }
        float width_9 = width_4 + spread_2 * _S2172.distance;
        viewed_0 = _S1891;
        width_3 = width_9;
        throughput_3 = throughput_10;
        density_3 = density_4;
        sky_pdf_1 = sky_pdf_2;
        spread_1 = spread_2;
        uint _S2075 = b_10 + 1U;
        b_7 = _S2075;
        layer_0 = _S2074;
    }
    return _S1516;
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

__device__ Random normal_distribution(uint state_4)
{
    Random _S2186 = pcg(state_4);
    Random _S2187 = pcg(_S2186.state);
    float _S2188 = 6.28318548202514648f * _S2186.value;
    float _S2189 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S2187.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S2187.state, _S2189 * (F32_cos((_S2188))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_5, float3  value_2)
{
    RandomSphere _S2190;
    (&_S2190)->state = state_5;
    (&_S2190)->value = value_2;
    return _S2190;
}

__device__ RandomSphere random_sphere(uint state_6)
{
    Random _S2191 = normal_distribution(state_6);
    Random _S2192 = normal_distribution(_S2191.state);
    Random _S2193 = normal_distribution(_S2192.state);
    float3  _S2194 = make_float3 (_S2191.value, _S2192.value, _S2193.value);
    float3  _S2195 = ((((_S2194)) * make_float3(rnorm3df(((_S2194)).x, ((_S2194)).y, ((_S2194)).z))));
    return RandomSphere_x24init_0(_S2193.state, _S2195);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_13)
{
    float3  _S2196 = p1_0 - p0_0;
    float3  _S2197 = p2_0 - p0_0;
    float2  _S2198 = uv1_0 - uv0_0;
    float2  _S2199 = uv2_0 - uv0_0;
    float _S2200 = _S2198.x;
    float _S2201 = _S2199.y;
    float _S2202 = _S2198.y;
    float _S2203 = _S2199.x;
    float _S2204 = _S2200 * _S2201 - _S2202 * _S2203;
    float _S2205 = 1.0f / _S2204;
    float3  t_24 = (_S2196 * make_float3 (_S2201) - _S2197 * make_float3 (_S2202)) * make_float3 (_S2205);
    float3  _S2206 = (_S2197 * make_float3 (_S2200) - _S2196 * make_float3 (_S2203)) * make_float3 (_S2205);
    float3  _S2207 = t_24 - n_13 * make_float3 (dot_0(n_13, t_24));
    float3  _S2208 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_13);
    bool _S2209 = (dot_0(_S2207, _S2207)) > 0.0f;
    float3  _S2210 = _slang_select(_S2209, _S2207,_S2208);
    float3  _S2211 = ((((_S2210)) * make_float3(rnorm3df(((_S2210)).x, ((_S2210)).y, ((_S2210)).z))));
    bool _S2212 = (dot_0(cross_0(n_13, _S2211), _S2206)) > 0.0f;
    float3  t_25;
    if(_S2212)
    {
        float3  _S2213 = negate_0(_S2211);
        t_25 = _S2213;
    }
    else
    {
        t_25 = _S2211;
    }
    float3  _S2214 = cross_0(n_13, t_25);
    return makeMatrix<float, 3, 3> (t_25, _S2214, n_13);
}

__device__ float3  tangentToWorldNormalMap(float3  v_13, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_13, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_4, float3  uvw_0, float3  position_0)
{
    float3  _S2215 = t1_0 - t0_0;
    float3  _S2216 = t2_2 - t0_0;
    float3  _S2217 = t2_2 - t1_0;
    float _S2218 = (F32_min((length_0(_S2215)), ((F32_min((length_0(_S2216)), (length_0(_S2217)))))));
    float3  _S2219 = make_float3 (distance_1(position_0, t0_0), distance_1(position_0, t1_0), distance_1(position_0, t2_2));
    float3  _S2220 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S2221 = dot_0(geometry_n_4, _S2220);
    float3  _S2222 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S2223 = dot_0(geometry_n_4, _S2222);
    float3  _S2224 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S2225 = acos_0(abs_0(make_float3 (_S2221, _S2223, dot_0(geometry_n_4, _S2224))));
    float3  _S2226 = clamp_2(tan_0(_S2225), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S2219 * _S2226, uvw_0), 0.0f, _S2218 * 0.125f);
}

__device__ float3  straightThrough(BSDFMaterial material_29)
{
    return make_float3 (material_29.transmission * (1.0f - material_29.metallic)) * material_29.albedo;
}

__device__ float hairRow(float3  in_dir_13, float3  t_26, float3  out_dir_3, uint p_15, float w_20, float alpha_9, uint nt_0)
{
    uint _S2227 = p_15 % 4U;
    float _S2228 = w_20 * HAIR_WIDTHS_0[_S2227];
    float _S2229 = (F32_asin((clamp_1(dot_0(out_dir_3, t_26), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_13, t_26), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S2227] * alpha_9;
    return ((F32_asinh((_S2229 / _S2228))) / (F32_asinh((3.14159274101257324f / _S2228))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_14, float3  t_27, float3  out_dir_4, uint np_0)
{
    float3  _S2230 = worldToTangent(out_dir_4, t_27);
    float3  _S2231 = worldToTangent(in_dir_14, t_27);
    return (F32_frac((((F32_atan2((_S2230.z), (_S2230.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S2231.z), (1.17549435082228751e-38f - _S2231.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_15, float3  t_28, uint p_16, float row_0, float column_0, float w_21, float alpha_10, uint nt_1, uint np_1)
{
    float3  _S2232 = worldToTangent(in_dir_15, t_28);
    uint _S2233 = p_16 % 4U;
    float _S2234 = w_21 * HAIR_WIDTHS_0[_S2233];
    float _S2235 = (F32_asin((clamp_1(dot_0(in_dir_15, t_28), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S2233] * alpha_10 + _S2234 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S2234))))));
    float _S2236 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S2232.z), (1.17549435082228751e-38f - _S2232.x)));
    float _S2237 = (F32_cos((_S2235)));
    float3  _S2238 = tangentToWorld(make_float3 (_S2237 * (F32_cos((_S2236))), (F32_sin((_S2235))), _S2237 * (F32_sin((_S2236)))), t_28);
    return _S2238;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_14, BSDFMaterial material_30, float coverage_1)
{
    float3  through_2;
    if((material_30.ior) == 1.0f)
    {
        float3  _S2239 = straightThrough(material_30);
        through_2 = _S2239;
    }
    else
    {
        through_2 = make_float3 (0.0f);
    }
    CoatFrame _S2240 = coatFrame(material_30, n_14);
    bool _S2241 = (_S2240.ior) > 0.0f;
    if(_S2241)
    {
        float _S2242 = fresnel((F32_abs((dot_0(_S2240.normal, toward_1)))), 1.0f, _S2240.ior);
        float3  _S2243 = mix_0(make_float3 (1.0f), make_float3 (1.0f - _S2242) * material_30.coat_tint, material_30.coat);
        float3  through_3 = through_2 * _S2243;
        through_2 = through_3;
    }
    return through_2 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_8, Reservoir r_10, bool replay_3, float scale_5, Selection * sel_9)
{
    Domain _S2244 = dom_8;
    Reservoir _S2245 = r_10;
    Shift _S2246 = walk_0(&_S2244, &_S2245, replay_3, scale_5, sel_9);
    return _S2246;
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
    uint i_27 = 0U;
    for(;;)
    {
        if(i_27 < 4U)
        {
        }
        else
        {
            break;
        }
        uint _S2247 = size_0 - 1U;
        uint _S2248 = (x_29 + size_0 / 2U) & _S2247;
        bool _S2249 = i_27 < 2U;
        uint _S2250 = _slang_select(_S2249, x_29,_S2248);
        uint l_5 = _S2250;
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
            uint _S2251 = hash(((r_11 ^ (t_29 << 16U)) ^ (k_4 << 28U)) ^ ((i_27 & 1U) << 31U));
            uint _S2252 = l_5 ^ (_S2251 & _S2247);
            uint k_5 = k_4 + 1U;
            l_5 = r_11;
            r_11 = _S2252;
            k_4 = k_5;
        }
        uint _S2253 = l_5 + r_11 * size_0;
        uint _S2254 = size_0 * size_0;
        uint _S2255;
        if(_S2254 >= 65536U)
        {
            uint _S2256 = _S2253 / (_S2254 / 65536U);
            _S2255 = _S2256;
        }
        else
        {
            uint _S2257 = 65536U / _S2254;
            _S2255 = _S2253 * _S2257;
        }
        ranks_0[i_27] = _S2255;
        uint i_28 = i_27 + 1U;
        i_27 = i_28;
    }
    bool _S2258 = (ranks_0[int(0)]) == 65535U;
    bool _S2259;
    if(_S2258)
    {
        _S2259 = (ranks_0[int(1)]) == 65535U;
    }
    else
    {
        _S2259 = false;
    }
    bool _S2260 = (ranks_0[int(2)]) == 65535U;
    bool _S2261;
    if(_S2260)
    {
        _S2261 = (ranks_0[int(3)]) == 65535U;
    }
    else
    {
        _S2261 = false;
    }
    if(_S2259)
    {
        _S2259 = (ranks_0[int(3)]) != 65535U;
    }
    else
    {
        _S2259 = false;
    }
    if(_S2259)
    {
        _S2259 = true;
    }
    else
    {
        if(_S2261)
        {
            _S2259 = (ranks_0[int(1)]) != 65535U;
        }
        else
        {
            _S2259 = false;
        }
    }
    uint _S2262 = ranks_0[int(0)];
    uint _S2263 = ranks_0[int(1)];
    uint _S2264 = ranks_0[int(3)];
    uint _S2265 = _slang_select(_S2259, _S2264,_S2263);
    return _S2262 | (_S2265 << 16U);
}

__device__ uint3  noiseBlock(uint sweep_0, uint colour_0, uint block_0, uint size_1)
{
    uint _S2266 = hash(sweep_0 * 7919U + 1U);
    uint _S2267 = size_1 / 16U;
    uint _S2268 = block_0 % _S2267;
    uint _S2269 = block_0 / _S2267;
    uint _S2270 = _S2269 % _S2267;
    uint _S2271 = block_0 / (_S2267 * _S2267);
    uint3  _S2272 = make_uint3 (_S2268, _S2270, _S2271);
    uint3  _S2273 = make_uint3 (colour_0 & 1U, (colour_0 >> 1U) & 1U, colour_0 >> 2U);
    return _S2272 * make_uint3 (16U) + _S2273 * make_uint3 (8U) + make_uint3 (_S2266 & 7U, (_S2266 >> 3U) & 7U, (_S2266 >> 6U) & 7U);
}

#undef Matrix
