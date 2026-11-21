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
    HalfTerms _S412;
    (&_S412)->v_dot_h = v_dot_h_0;
    (&_S412)->n_dot_h = n_dot_h_0;
    (&_S412)->refracted = refracted_1;
    (&_S412)->F = F_0;
    (&_S412)->F_greyscale = F_greyscale_0;
    (&_S412)->reflect_weight = reflect_weight_0;
    (&_S412)->diffuse_weight = diffuse_weight_0;
    (&_S412)->refract_weight = refract_weight_0;
    (&_S412)->p_diffuse = p_diffuse_0;
    (&_S412)->p_reflect = p_reflect_0;
    (&_S412)->p_refract = p_refract_0;
    (&_S412)->translucent_share = translucent_share_1;
    (&_S412)->sheen = sheen_2;
    (&_S412)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S412)->view = view_2;
    (&_S412)->tangent = tangent_1;
    (&_S412)->alphas = alphas_1;
    (&_S412)->visible = visible_0;
    (&_S412)->p_toon = p_toon_0;
    (&_S412)->toon = toon_2;
    (&_S412)->toon_a = toon_a_3;
    (&_S412)->toon_s = toon_s_3;
    (&_S412)->toon_b = toon_b_2;
    (&_S412)->toon_glossy = toon_glossy_1;
    (&_S412)->toon_norm = toon_norm_2;
    (&_S412)->toon_view = toon_view_2;
    (&_S412)->toon_axis = toon_axis_2;
    return _S412;
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
    float3  _S413 = make_float3 (alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z);
    float3  _S414 = ((((_S413)) * make_float3(rnorm3df(((_S413)).x, ((_S413)).y, ((_S413)).z))));
    float _S415 = _S414.x;
    float _S416 = _S414.y;
    float _S417 = _S415 * _S415 + _S416 * _S416;
    float3  _S418;
    if(_S417 > 0.0f)
    {
        float3  _S419 = make_float3 (- _S416, _S415, 0.0f);
        float _S420 = (rsqrtf((_S417)));
        _S418 = _S419 * make_float3 (_S420);
    }
    else
    {
        _S418 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S421 = cross_0(_S414, _S418);
    float _S422 = (F32_sqrt((U1_0)));
    float _S423 = 6.28318548202514648f * U2_0;
    float _S424 = _S422 * (F32_cos((_S423)));
    float t2_0 = _S422 * (F32_sin((_S423)));
    float _S425 = 0.5f * (1.0f + _S414.z);
    float t2_1 = (1.0f - _S425) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S424 * _S424)))))) + _S425 * t2_0;
    float3  _S426 = make_float3 (_S424) * _S418 + make_float3 (t2_1) * _S421;
    float _S427 = unshared_0(_S424);
    float _S428 = unshared_0(_S424);
    float3  _S429 = _S426 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S427 * _S428 - t2_1 * t2_1))))))) * _S414;
    float3  _S430 = make_float3 (alpha_0 * _S429.x, alpha_0 * _S429.y, (F32_max((0.0f), (_S429.z))));
    float3  _S431 = ((((_S430)) * make_float3(rnorm3df(((_S430)).x, ((_S430)).y, ((_S430)).z))));
    return _S431;
}

__device__ float3  worldToTangent(float3  v_2, float3  n_4)
{
    float3  a_5 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S432 = (F32_abs((dot_0(n_4, a_5)))) > 0.9999847412109375f;
    float3  a_6;
    if(_S432)
    {
        float3  _S433 = make_float3 (1.0f, 0.0f, 0.0f);
        a_6 = _S433;
    }
    else
    {
        a_6 = a_5;
    }
    float3  _S434 = cross_0(n_4, a_6);
    float3  _S435 = ((((_S434)) * make_float3(rnorm3df(((_S434)).x, ((_S434)).y, ((_S434)).z))));
    float3  _S436 = cross_0(n_4, _S435);
    return make_float3 (dot_0(v_2, _S435), dot_0(v_2, n_4), dot_0(v_2, _S436));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_3, float3  n_i_2, float alpha_1, AnisotropicFrame frame_1, uint * random_state_2)
{
    Random _S437 = pcg(*random_state_2);
    Random _S438 = pcg(_S437.state);
    *random_state_2 = _S438.state;
    float _S439 = frame_1.alphas.x;
    bool _S440 = _S439 > 0.0f;
    if(_S440)
    {
        float3  _S441 = anisotropicLocal(v_3, frame_1.tangent, n_i_2);
        float _S442 = frame_1.alphas.y;
        float3  _S443 = make_float3 (_S439 * _S441.x, _S442 * _S441.y, _S441.z);
        float3  _S444 = ((((_S443)) * make_float3(rnorm3df(((_S443)).x, ((_S443)).y, ((_S443)).z))));
        float3  _S445 = sampleGGXVNDF(_S444, 1.0f, _S437.value, _S438.value);
        float3  _S446 = make_float3 (_S439 * _S445.x, _S442 * _S445.y, _S445.z);
        float3  _S447 = ((((_S446)) * make_float3(rnorm3df(((_S446)).x, ((_S446)).y, ((_S446)).z))));
        return make_float3 (_S447.x) * frame_1.tangent + make_float3 (_S447.y) * cross_0(n_i_2, frame_1.tangent) + make_float3 (_S447.z) * n_i_2;
    }
    float3  _S448 = worldToTangent(v_3, n_i_2);
    float3  _S449 = sampleGGXVNDF(float3 {_S448.x, _S448.z, _S448.y}, alpha_1, _S437.value, _S438.value);
    float3  _S450 = float3 {_S449.x, _S449.z, _S449.y};
    float3  _S451 = tangentToWorld(_S450, n_i_2);
    return _S451;
}

__device__ float3  sampledHalf(float3  in_dir_1, float3  n_5, BSDFMaterial material_4, uint random_state_3, ViewTerms view_terms_0)
{
    uint state_3 = random_state_3;
    float3  _S452 = negate_0(in_dir_1);
    float _S453 = sign_0(dot_0(n_5, _S452));
    float _S454 = material_4.roughness;
    float3  _S455 = sampleHalfVector(_S452, n_5 * make_float3 (_S453), _S454 * _S454, view_terms_0.frame, &state_3);
    return _S455;
}

__device__ float3  refractedHalf(float3  in_dir_2, float3  out_dir_0, float3  n_6, float eta_i_1, float eta_o_1)
{
    float3  _S456 = negate_0(in_dir_2);
    float3  _S457 = negate_0(make_float3 (eta_i_1) * _S456 + make_float3 (eta_o_1) * out_dir_0);
    float3  _S458 = ((((_S457)) * make_float3(rnorm3df(((_S457)).x, ((_S457)).y, ((_S457)).z))));
    float _S459 = sign_0(dot_0(n_6, _S456));
    float _S460 = sign_0(dot_0(_S457, n_6 * make_float3 (_S459)));
    return _S458 * make_float3 (_S460);
}

__device__ float3  reflectedHalf(float3  in_dir_3, float3  out_dir_1)
{
    float3  _S461 = negate_0(in_dir_3);
    float3  _S462 = _S461 + out_dir_1;
    float3  _S463 = ((((_S462)) * make_float3(rnorm3df(((_S462)).x, ((_S462)).y, ((_S462)).z))));
    return _S463;
}

static __device__ float3  refract_0(float3  i_6, float3  n_7, float eta_0)
{
    float _S464 = dot_0(n_7, i_6);
    float _S465 = 1.0f - eta_0 * eta_0 * (1.0f - _S464 * _S464);
    if(_S465 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_6 - make_float3 (eta_0 * _S464 + (F32_sqrt((_S465)))) * n_7;
}

__device__ float fresnel(float cos_theta_0, float eta_i_2, float eta_o_2)
{
    float _S466 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S467 = eta_i_2 / eta_o_2 * _S466;
    bool _S468 = _S467 < 1.0f;
    float kr_0;
    if(_S468)
    {
        float _S469 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S467 * _S467))))));
        float _S470 = eta_o_2 * cos_theta_0;
        float _S471 = eta_i_2 * _S469;
        float _S472 = (_S470 - _S471) / (_S470 + _S471);
        float _S473 = eta_i_2 * cos_theta_0;
        float _S474 = eta_o_2 * _S469;
        float _S475 = (_S473 - _S474) / (_S473 + _S474);
        float _S476 = (_S472 * _S472 + _S475 * _S475) / 2.0f;
        kr_0 = _S476;
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
    float _S477 = (F32_max((w_1.z), (0.0f)));
    return 2.0f * _S477 / (_S477 + length_0(make_float3 (alphas_2.x * w_1.x, alphas_2.y * w_1.y, _S477)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_3)
{
    float _S478 = alphas_3.x;
    float _S479 = h_0.x / _S478;
    float _S480 = alphas_3.y;
    float _S481 = h_0.y / _S480;
    float _S482 = h_0.z;
    float _S483 = _S479 * _S479 + _S481 * _S481 + _S482 * _S482;
    return 1.0f / (F32_max((3.14159274101257324f * _S478 * _S480 * _S483 * _S483), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ HalfTerms precomputeHalf(float3  in_dir_4, float3  ggx_n_0, BSDFMaterial material_5, float eta_i_3, float eta_o_3, MaterialTerms terms_1, ViewTerms view_terms_1)
{
    float _S484 = dot_0(ggx_n_0, view_terms_1.v);
    float _S485 = dot_0(view_terms_1.n_i, ggx_n_0);
    float _S486 = eta_i_3 / eta_o_3;
    float3  _S487 = refract_0(in_dir_4, ggx_n_0, _S486);
    float3  _S488 = ((((_S487)) * make_float3(rnorm3df(((_S487)).x, ((_S487)).y, ((_S487)).z))));
    float _S489 = (F32_abs((_S484)));
    bool _S490 = eta_i_3 > eta_o_3;
    float visible_1;
    if(_S490)
    {
        visible_1 = terms_1.eta_level;
    }
    else
    {
        visible_1 = 1.0f;
    }
    float _S491;
    if(_S490)
    {
        _S491 = 1.0f;
    }
    else
    {
        _S491 = terms_1.eta_level;
    }
    float _S492 = fresnel(_S489, visible_1, _S491);
    bool _S493 = (eta_i_3 * eta_i_3 * (1.0f - _S484 * _S484)) >= (eta_o_3 * eta_o_3);
    float3  _S494;
    if(_S493)
    {
        _S494 = make_float3 (1.0f);
    }
    else
    {
        float3  _S495 = material_5.specular_tint * make_float3 (terms_1.f0);
        _S494 = _S495 + (make_float3 (1.0f) - _S495) * make_float3 (_S492 - terms_1.f0) / make_float3 (1.0f - terms_1.f0);
    }
    float3  _S496 = mix_0(_S494, material_5.albedo * view_terms_1.rebounce, material_5.metallic);
    float3  F_1 = _S496 * view_terms_1.scale;
    float _S497 = rgb_to_greyscale(F_1);
    float _S498 = 1.0f - material_5.metallic;
    float3  _S499 = make_float3 (1.0f) - _S494;
    float3  _S500 = make_float3 ((1.0f - material_5.transmission) * _S498) * _S499 * view_terms_1.scale;
    float3  _S501 = make_float3 (material_5.transmission * _S498) * _S499 * view_terms_1.scale;
    float _S502 = (F32_max((_S497), (0.0f)));
    float _S503 = rgb_to_greyscale(_S500);
    float _S504 = (F32_max((_S503), (0.0f)));
    float _S505 = rgb_to_greyscale(_S501);
    float _S506 = sign_0(length_0(_S488));
    float _S507 = (F32_max((_S505 * _S506), (0.0f)));
    float _S508 = _S502 + _S504 + _S507 + terms_1.toon_component;
    float _S509 = (F32_min((view_terms_1.sheen_component), (1.0f)));
    bool _S510 = (view_terms_1.sheen_component) > 0.0f;
    bool _S511;
    if(_S510)
    {
        _S511 = !(_S508 > 0.0f);
    }
    else
    {
        _S511 = false;
    }
    float _S512 = _slang_select(_S511, 1.0f,_S509);
    float _S513 = (1.0f - _S512) / (F32_max((_S508), (0.0000152587890625f)));
    float _S514 = _S504 * _S513;
    float _S515 = _S502 * _S513;
    float _S516 = _S507 * _S513;
    bool _S517 = (view_terms_1.frame.alphas.x) > 0.0f;
    if(_S517)
    {
        float3  _S518 = anisotropicLocal(view_terms_1.v, view_terms_1.frame.tangent, view_terms_1.n_i);
        float _S519 = anisotropicG1(_S518, view_terms_1.frame.alphas);
        float3  _S520 = anisotropicLocal(ggx_n_0, view_terms_1.frame.tangent, view_terms_1.n_i);
        float _S521 = anisotropicD(_S520, view_terms_1.frame.alphas);
        float _S522 = _S519 * _S521;
        visible_1 = _S522;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return HalfTerms_x24init_0(_S484, _S485, _S488, F_1, _S497, 1.0f, _S500, _S501, _S514, _S515, _S516, terms_1.translucent_share, view_terms_1.sheen, _S512, view_terms_1.view, view_terms_1.frame.tangent, view_terms_1.frame.alphas, visible_1, terms_1.toon_component * _S513, terms_1.toon, terms_1.toon_a, terms_1.toon_s, terms_1.toon_b, terms_1.toon_glossy, terms_1.toon_norm, view_terms_1.toon_view, view_terms_1.toon_axis);
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_2, HalfTerms lobes_0, float eta_i_4, float eta_o_4)
{
    float _S523 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S524 = lobes_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S525 = 1.0f - lobes_0.translucent_share;
    bool _S526 = n_i_dot_l_0 < 0.0f;
    float _S527 = _slang_select(_S526, lobes_0.translucent_share,_S525);
    float _S528 = _S524 * _S527;
    bool _S529 = (lobes_0.translucent_share) > 0.0f;
    float _S530 = _slang_select(_S529, _S528,_S523);
    bool _S531 = n_i_dot_v_0 > 0.0f;
    float _S532 = _slang_select(_S531, _S530,0.0f);
    return _S532;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_3, float alpha_3, BSDFMaterial material_6, HalfTerms lobes_1)
{
    bool _S533 = (dot_0(n_i_3, l_0)) < 0.0f;
    float3  _S534 = _slang_select(_S533, material_6.translucent,material_6.albedo);
    float _S535 = 1.0f - lobes_1.translucent_share;
    float _S536 = _slang_select(_S533, lobes_1.translucent_share,_S535);
    float3  _S537 = _S534 / make_float3 (_S536);
    bool _S538 = (lobes_1.translucent_share) > 0.0f;
    float3  _S539 = _slang_select(_S538, _S537,material_6.albedo);
    return lobes_1.diffuse_weight * _S539 / make_float3 (lobes_1.p_diffuse);
}

__device__ float smithG1(float alpha_4, float n_dot_x_0)
{
    float _S540 = alpha_4 * alpha_4;
    float _S541 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S540 + (1.0f - _S540) * n_dot_x_0 * n_dot_x_0))));
    bool _S542 = alpha_4 > 0.0f;
    float _S543 = _slang_select(_S542, _S541,1.0f);
    return _S543;
}

__device__ float trowbridgeReitz(float alpha_5, float n_dot_h_1)
{
    float _S544 = alpha_5 * alpha_5;
    float _S545 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S544 * n_dot_h_1 * n_dot_h_1;
    return _S544 / (F32_max((3.14159274101257324f * _S545 * _S545), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float n_i_dot_v_1, float alpha_6, HalfTerms lobes_2)
{
    float _S546 = smithG1(alpha_6, n_i_dot_v_1);
    float _S547 = _S546 * lobes_2.v_dot_h;
    float _S548 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    float _S549 = _S547 * _S548 / n_i_dot_v_1;
    bool _S550 = alpha_6 > 0.0f;
    bool _S551;
    if(_S550)
    {
        _S551 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S551 = false;
    }
    if(_S551)
    {
        _S551 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S551 = false;
    }
    if(_S551)
    {
        _S551 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S551 = false;
    }
    float _S552 = _slang_select(_S551, _S549,0.0f);
    bool _S553 = (lobes_2.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S553)
    {
        float _S554 = lobes_2.visible * lobes_2.v_dot_h / n_i_dot_v_1;
        bool _S555 = (lobes_2.v_dot_h) > 0.0f;
        if(_S555)
        {
            _S551 = (lobes_2.n_dot_h) > 0.0f;
        }
        else
        {
            _S551 = false;
        }
        if(_S551)
        {
            _S551 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S551 = false;
        }
        float _S556 = _slang_select(_S551, _S554,0.0f);
        pdf_h_0 = _S556;
    }
    else
    {
        pdf_h_0 = _S552;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float n_i_dot_l_1, float l_dot_h_1, float n_i_dot_v_2, float alpha_7, HalfTerms lobes_3, float eta_i_5, float eta_o_5)
{
    float _S557 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    float _S558 = eta_i_5 * lobes_3.v_dot_h + eta_o_5 * l_dot_h_1;
    float _S559 = lobes_3.p_refract * _S557 * eta_o_5 * eta_o_5 * (F32_abs((l_dot_h_1))) / (_S558 * _S558);
    bool _S560 = eta_i_5 != eta_o_5;
    bool _S561;
    if(_S560)
    {
        _S561 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S561 = false;
    }
    float _S562 = _slang_select(_S561, _S559,0.0f);
    return _S562;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_4, float alpha_8, BSDFMaterial material_7, HalfTerms lobes_4)
{
    float _S563 = - dot_0(n_i_4, l_1);
    float _S564 = smithG1(alpha_8, (F32_max((_S563), (0.0f))));
    bool _S565 = (lobes_4.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S565)
    {
        float3  _S566 = negate_0(n_i_4);
        float3  _S567 = anisotropicLocal(l_1, lobes_4.tangent, _S566);
        float _S568 = anisotropicG1(_S567, lobes_4.alphas);
        G1_l_0 = _S568;
    }
    else
    {
        G1_l_0 = _S564;
    }
    return lobes_4.refract_weight * make_float3 (G1_l_0) * material_7.albedo / make_float3 (lobes_4.p_refract);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_2, float l_dot_h_2, float n_i_dot_v_3, float alpha_9, HalfTerms lobes_5, float eta_i_6, float eta_o_6)
{
    float _S569 = lobes_5.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S570 = n_i_dot_l_2 > 0.0f;
    bool _S571;
    if(_S570)
    {
        _S571 = n_i_dot_v_3 > 0.0f;
    }
    else
    {
        _S571 = false;
    }
    float _S572 = _slang_select(_S571, _S569,0.0f);
    return _S572;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  n_i_5, float alpha_10, BSDFMaterial material_8, HalfTerms lobes_6)
{
    float3  _S573 = l_2 + lobes_6.view;
    float3  _S574 = ((((_S573)) * make_float3(rnorm3df(((_S573)).x, ((_S573)).y, ((_S573)).z))));
    float _S575 = dot_0(n_i_5, _S574);
    float _S576 = (F32_max((dot_0(n_i_5, l_2)), (0.0f)));
    float _S577 = (F32_max((dot_0(n_i_5, lobes_6.view)), (0.0f)));
    float _S578 = 1.0f / (F32_max((material_8.sheen_roughness), (0.05000000074505806f)));
    float _S579 = 1.0f - _S575 * _S575;
    float _S580 = (2.0f + _S578) * (F32_pow(((F32_max((_S579), (0.0f)))), (0.5f * _S578))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S576 + _S577 - _S576 * _S577)), (0.0000152587890625f)));
    bool _S581 = (material_8.velvet) > 0.0f;
    float f_1;
    if(_S581)
    {
        float _S582 = (F32_max((material_8.sheen_roughness), (0.00999999977648258f)));
        float _S583 = _S582 * _S582;
        float _S584 = (F32_max((_S579), (0.0000152587890625f)));
        float _S585 = (F32_exp((- _S575 * _S575 / (_S584 * _S583)))) / (3.14159274101257324f * _S583 * _S584 * _S584) * (F32_min((1.0f), (2.0f * _S575 * (F32_min((_S576), (_S577))) / (F32_max(((F32_abs((dot_0(_S574, lobes_6.view))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S576 * _S577), (0.0000152587890625f)));
        f_1 = _S585;
    }
    else
    {
        f_1 = _S580;
    }
    return lobes_6.sheen * make_float3 (f_1 * _S576 * 2.0f * 3.14159274101257324f / lobes_6.p_sheen_velvet);
}

__device__ __forceinline__ float toonPDF(float n_i_dot_l_3, float l_dot_h_3, float n_i_dot_v_4, float alpha_11, HalfTerms lobes_7, float eta_i_7, float eta_o_7)
{
    float _S586 = _slang_select(lobes_7.toon_glossy, l_dot_h_3,n_i_dot_l_3);
    float _S587 = (F32_acos((clamp_1(_S586, -1.0f, 1.0f))));
    float _S588;
    if(_S587 < (lobes_7.toon_a))
    {
        _S588 = 1.0f;
    }
    else
    {
        _S588 = (F32_max((1.0f - (_S587 - lobes_7.toon_a) / (F32_max((lobes_7.toon_s), (0.0000152587890625f)))), (0.0f)));
    }
    float _S589 = lobes_7.p_toon * _S588;
    float _S590 = _slang_select(lobes_7.toon_glossy, 1.0f,n_i_dot_l_3);
    float _S591 = _S589 * _S590 / lobes_7.toon_norm;
    bool _S592;
    if(lobes_7.toon_glossy)
    {
        _S592 = true;
    }
    else
    {
        _S592 = n_i_dot_l_3 > 0.0f;
    }
    float _S593 = _slang_select(_S592, _S591,0.0f);
    return _S593;
}

__device__ __forceinline__ float3  toonBSDF(float3  l_3, float3  n_i_6, float alpha_12, BSDFMaterial material_9, HalfTerms lobes_8)
{
    float _S594 = (F32_max((dot_0(n_i_6, l_3)), (0.0f)));
    float _S595 = _slang_select(lobes_8.toon_glossy, _S594,lobes_8.toon_view);
    return lobes_8.toon * make_float3 (_S595) / make_float3 (lobes_8.p_toon);
}

__device__ __forceinline__ float reflectPDF(float n_i_dot_l_4, float l_dot_h_4, float n_i_dot_v_5, float alpha_13, HalfTerms lobes_9, float eta_i_8, float eta_o_8)
{
    float _S596 = vndfPDF(n_i_dot_v_5, alpha_13, lobes_9);
    float _S597 = lobes_9.p_reflect * _S596 / (4.0f * lobes_9.v_dot_h);
    bool _S598 = _S596 > 0.0f;
    float _S599 = _slang_select(_S598, _S597,0.0f);
    return _S599;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_4, float3  n_i_7, float alpha_14, BSDFMaterial material_10, HalfTerms lobes_10)
{
    float _S600 = dot_0(n_i_7, l_4);
    float _S601 = smithG1(alpha_14, (F32_max((_S600), (0.0f))));
    bool _S602 = (lobes_10.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S602)
    {
        float3  _S603 = anisotropicLocal(l_4, lobes_10.tangent, n_i_7);
        float _S604 = anisotropicG1(_S603, lobes_10.alphas);
        G1_l_1 = _S604;
    }
    else
    {
        G1_l_1 = _S601;
    }
    return make_float3 (lobes_10.reflect_weight * G1_l_1) * lobes_10.F / make_float3 (lobes_10.p_reflect);
}

__device__ __forceinline__ float3  misWeighted(float3  throughput_0, float lobe_pdf_0, float pdf_0, bool power_0)
{
    if(power_0)
    {
        float _S605 = lobe_pdf_0 / pdf_0;
        return throughput_0 * make_float3 (lobe_pdf_0) / make_float3 (pdf_0 * (1.0f + _S605 * _S605));
    }
    return throughput_0 * make_float3 (lobe_pdf_0) / make_float3 (lobe_pdf_0 + pdf_0);
}

static __device__ float3  neeLobes_0(float3  in_dir_5, float3  dir_3, float3  n_8, BSDFMaterial * material_11, float eta_i_9, float eta_o_9, bool refracted_2, float pdf_1, bool power_1, uint random_state_4, MaterialTerms * terms_2, ViewTerms * view_terms_2, FixedArray<float3 , 5>  * each_0, uint * reached_0)
{
    float3  _S606 = negate_0(in_dir_5);
    float _S607 = dot_0(n_8, _S606);
    float _S608 = sign_0(_S607);
    float3  _S609 = n_8 * make_float3 (_S608);
    float _S610 = dot_0(_S609, dir_3);
    float _S611 = material_11->roughness * material_11->roughness;
    float3  _S612 = make_float3 (0.0f);
    *reached_0 = 0U;
    HalfTerms _S613 = HalfTerms_x24init_0(0.0f, 0.0f, _S612, _S612, 0.0f, 0.0f, _S612, _S612, 0.0f, 0.0f, 0.0f, 0.0f, _S612, 0.0f, _S612, _S612, make_float2 (0.0f), 0.0f, 0.0f, _S612, 0.0f, 0.0f, 0.0f, false, 1.0f, 0.0f, _S612);
    uint _S614;
    if((F32_abs((material_11->toon.x))) > 0.0f)
    {
        _S614 = 5U;
    }
    else
    {
        _S614 = 4U;
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
        (*each_0)[i_7] = _S612;
        uint i_8 = i_7 + 1U;
        i_7 = i_8;
    }
    uint half_of_0 = 4294967295U;
    HalfTerms lobe_terms_0 = _S613;
    float3  ggx_n_1 = _S612;
    i_7 = 0U;
    float3  f_2 = _S612;
    for(;;)
    {
        if(i_7 < _S614)
        {
        }
        else
        {
            break;
        }
        uint _S615;
        if(i_7 == 3U)
        {
            _S615 = 4U;
        }
        else
        {
            if(i_7 == 4U)
            {
                _S615 = 6U;
            }
            else
            {
                _S615 = i_7;
            }
        }
        bool _S616 = _S615 == 0U;
        if(_S616)
        {
        }
        bool _S617;
        if(_S616)
        {
            float _S618 = rgb_to_greyscale(material_11->translucent);
            _S617 = _S618 > 0.0f;
        }
        else
        {
            _S617 = false;
        }
        bool _S619;
        if(_S617)
        {
            float _S620 = dot_0(n_8, dir_3);
            float3  _S621 = negate_0(in_dir_5);
            _S619 = ((_S620 * dot_0(n_8, _S621)) < 0.0f) == refracted_2;
        }
        else
        {
            _S619 = (_S615 == 1U) == refracted_2;
        }
        float3  ggx_n_2;
        if(_S619)
        {
            uint _S622;
            if(_S615 == 6U)
            {
                _S622 = 0U;
            }
            else
            {
                if(_S615 == 4U)
                {
                    _S622 = 2U;
                }
                else
                {
                    _S622 = _S615;
                }
            }
            bool _S623 = _S622 != half_of_0;
            uint half_of_1;
            HalfTerms lobe_terms_1;
            if(_S623)
            {
                bool _S624 = _S622 == 0U;
                if(_S624)
                {
                    float3  _S625 = sampledHalf(in_dir_5, n_8, *material_11, random_state_4, *view_terms_2);
                    ggx_n_2 = _S625;
                }
                else
                {
                    bool _S626 = _S622 == 1U;
                    if(_S626)
                    {
                        float3  _S627 = refractedHalf(in_dir_5, dir_3, n_8, eta_i_9, eta_o_9);
                        ggx_n_2 = _S627;
                    }
                    else
                    {
                        float3  _S628 = reflectedHalf(in_dir_5, dir_3);
                        ggx_n_2 = _S628;
                    }
                }
                HalfTerms _S629 = precomputeHalf(in_dir_5, ggx_n_2, *material_11, eta_i_9, eta_o_9, *terms_2, *view_terms_2);
                lobe_terms_1 = _S629;
                half_of_1 = _S622;
            }
            else
            {
                lobe_terms_1 = lobe_terms_0;
                ggx_n_2 = ggx_n_1;
                half_of_1 = half_of_0;
            }
            float3  throughput_1;
            float lobe_pdf_1;
            switch(_S615)
            {
            case 0U:
                {
                    float _S630 = diffusePDF(_S610, 0.0f, (F32_abs((_S607))), _S611, lobe_terms_1, eta_i_9, eta_o_9);
                    float3  _S631 = diffuseBSDF(dir_3, _S609, _S611, *material_11, lobe_terms_1);
                    lobe_pdf_1 = _S630;
                    throughput_1 = _S631;
                    break;
                }
            case 1U:
                {
                    float _S632 = refractPDF(_S610, dot_0(dir_3, ggx_n_2), (F32_abs((_S607))), _S611, lobe_terms_1, eta_i_9, eta_o_9);
                    float3  _S633 = refractBSDF(dir_3, _S609, _S611, *material_11, lobe_terms_1);
                    lobe_pdf_1 = _S632;
                    throughput_1 = _S633;
                    break;
                }
            case 4U:
                {
                    float _S634 = sheenVelvetPDF(_S610, 0.0f, (F32_abs((_S607))), _S611, lobe_terms_1, eta_i_9, eta_o_9);
                    float3  _S635 = sheenVelvetBSDF(dir_3, _S609, _S611, *material_11, lobe_terms_1);
                    lobe_pdf_1 = _S634;
                    throughput_1 = _S635;
                    break;
                }
            case 6U:
                {
                    float _S636 = toonPDF(_S610, dot_0(dir_3, lobe_terms_1.toon_axis), (F32_abs((_S607))), _S611, lobe_terms_1, eta_i_9, eta_o_9);
                    float3  _S637 = toonBSDF(dir_3, _S609, _S611, *material_11, lobe_terms_1);
                    lobe_pdf_1 = _S636;
                    throughput_1 = _S637;
                    break;
                }
            default:
                {
                    float _S638 = reflectPDF(_S610, 0.0f, (F32_abs((_S607))), _S611, lobe_terms_1, eta_i_9, eta_o_9);
                    float3  _S639 = reflectBSDF(dir_3, _S609, _S611, *material_11, lobe_terms_1);
                    lobe_pdf_1 = _S638;
                    throughput_1 = _S639;
                    break;
                }
            }
            bool _S640 = lobe_pdf_1 > 0.0f;
            float3  f_3;
            if(_S640)
            {
                float3  _S641 = misWeighted(throughput_1, lobe_pdf_1, pdf_1, power_1);
                (*each_0)[i_7] = _S641;
                uint _S642 = (*reached_0) | (1U << i_7);
                *reached_0 = _S642;
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
    BSDFMaterial _S643 = material_12;
    MaterialTerms _S644 = terms_3;
    ViewTerms _S645 = view_terms_3;
    FixedArray<float3 , 5>  each_1;
    float3  _S646 = neeLobes_0(in_dir_6, dir_4, n_9, &_S643, eta_i_10, eta_o_10, refracted_3, pdf_2, power_2, random_state_5, &_S644, &_S645, &each_1, &reached_1);
    return _S646;
}

__device__ float3  skyBSDF(float3  in_dir_7, float3  dir_5, FKSurface surface_1, float2  eta_1, bool is_inside_2, float pdf_3, uint random_state_6)
{
    bool _S647 = wrongSide_0(is_inside_2, false, dir_5, surface_1.geometry_n);
    float _S648 = eta_1.x;
    float _S649 = eta_1.y;
    MaterialTerms _S650 = precomputeMaterial(surface_1.material, _S648, _S649);
    ViewTerms _S651 = precomputeView(in_dir_7, surface_1.smooth_n, surface_1.material, _S650);
    float3  _S652 = neeBSDF(in_dir_7, dir_5, surface_1.smooth_n, surface_1.material, _S648, _S649, _S647, pdf_3, false, random_state_6, _S650, _S651);
    return _S652;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_6, float3  radiance_0, float3  color_0, uint random_state_7)
{
    SkySample _S653;
    (&_S653)->dir = dir_6;
    (&_S653)->radiance = radiance_0;
    (&_S653)->color = color_0;
    (&_S653)->random_state = random_state_7;
    return _S653;
}

static __device__ __noinline__ float3  skyColor_0(float3  in_dir_8, float3  dir_7, FKSurface * surface_2, float2  eta_2, bool is_inside_3, float pdf_4, uint random_state_8, uint depth_0)
{
    bool _S654 = wrongSide_0(is_inside_3, false, dir_7, surface_2->geometry_n);
    float3  _S655 = surface_2->smooth_n;
    BSDFMaterial _S656 = surface_2->material;
    float _S657 = eta_2.x;
    float _S658 = eta_2.y;
    MaterialTerms _S659 = precomputeMaterial(surface_2->material, _S657, _S658);
    ViewTerms _S660 = precomputeView(in_dir_8, _S655, _S656, _S659);
    uint reached_2 = 0U;
    MaterialTerms _S661 = _S659;
    ViewTerms _S662 = _S660;
    FixedArray<float3 , 5>  each_2;
    float3  _S663 = neeLobes_0(in_dir_8, dir_7, _S655, &surface_2->material, _S657, _S658, _S654, pdf_4, false, random_state_8, &_S661, &_S662, &each_2, &reached_2);
    float3  _S664 = make_float3 (0.0f);
    bool shaded_0 = false;
    float3  world_0 = _S664;
    uint i_10 = 0U;
    float3  color_1 = _S664;
    for(;;)
    {
        if(i_10 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S665 = (reached_2 & (1U << i_10)) != 0U;
        if(_S665)
        {
            bool _S666 = (fcptWorldReadsPath());
            bool _S667;
            if(_S666)
            {
                _S667 = true;
            }
            else
            {
                _S667 = !shaded_0;
            }
            bool shaded_1;
            float3  world_1;
            if(_S667)
            {
                uint _S668;
                if(i_10 == 3U)
                {
                    _S668 = 4U;
                }
                else
                {
                    if(i_10 == 4U)
                    {
                        _S668 = 6U;
                    }
                    else
                    {
                        _S668 = i_10;
                    }
                }
                float3  _S669 = (fcptEnvMapSample((dir_7), (depth_0), (_S668)));
                world_1 = _S669;
                shaded_1 = true;
            }
            else
            {
                world_1 = world_0;
                shaded_1 = shaded_0;
            }
            float3  color_2 = color_1 + each_2[i_10] * world_1;
            shaded_0 = shaded_1;
            world_0 = world_1;
            color_1 = color_2;
        }
        uint i_11 = i_10 + 1U;
        i_10 = i_11;
    }
    return color_1;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_3, float2  eta_3, bool is_inside_4, uint init_random_state_0, uint lobe_state_0, ShadowContext * context_2)
{
    uint2  _S670 = (fcptEnvironmentCdfSize());
    uint2  _S671 = make_uint2 (1U, 0U);
    uint2  _S672 = _S670 - _S671;
    Random _S673 = pcg(init_random_state_0);
    Random _S674 = pcg(_S673.state);
    Random _S675 = pcg(_S674.state);
    Random _S676 = pcg(_S675.state);
    uint _S677 = _S672.x;
    uint _S678 = searchCDF_0(make_uint2 (_S677, 0U), make_uint2 (0U, 1U), _S672.y, _S673.value);
    uint _S679 = searchCDF_0(make_uint2 (0U, _S678), _S671, _S677, _S674.value);
    float2  _S680 = make_float2 ((float)_S672.x, (float)_S672.y);
    float2  _S681 = (make_float2 (float(_S679), float(_S678)) + make_float2 (_S675.value, _S676.value)) / _S680 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S682 = _S681.y;
    float _S683 = (F32_sin((_S682)));
    float _S684 = _S681.x;
    float3  _S685 = make_float3 (- _S683 * (F32_cos((_S684))), _S683 * (F32_sin((_S684))), (F32_cos((_S682))));
    float _S686 = environmentPdf_0(_S685);
    float3  _S687 = ray_0->unit_direction;
    float3  _S688 = skyBSDF(ray_0->unit_direction, _S685, *surface_3, eta_3, is_inside_4, _S686, lobe_state_0);
    bool _S689 = !(_S686 > 0.0f);
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
        return SkySample_x24init_0(_S685, _S691, _S691, _S676.state);
    }
    bool _S692 = (fcptWorldReadsPath());
    float3  seen_0;
    if(_S692)
    {
        float3  _S693 = skyColor_0(_S687, _S685, surface_3, eta_3, is_inside_4, _S686, lobe_state_0, context_2->depth + 1U);
        seen_0 = _S693;
    }
    else
    {
        seen_0 = _S688;
    }
    float3  _S694 = skyRadiance_0(ray_0->origin, surface_3, is_inside_4, _S685, context_2, _S676.state);
    return SkySample_x24init_0(_S685, _S694, seen_0 * _S694, _S676.state);
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

static __device__ float3  hairLight_0(FKSurface * surface_4, float3  in_dir_9, TreeSample * light_1, bool competing_0)
{
    SampleBSDF _S695 = (fcptConnectHair((surface_4->hair), ((&surface_4->material)->albedo), ((&surface_4->material)->specular_tint), (in_dir_9), (light_1->dir)));
    float3  _S696 = _S695.throughput * make_float3 (_S695.pdf);
    float _S697 = light_1->density;
    float _S698 = 1.0f + _S695.pdf * _S695.pdf / (light_1->density * light_1->density);
    bool _S699;
    if(competing_0)
    {
        _S699 = _S697 > 0.0f;
    }
    else
    {
        _S699 = false;
    }
    float _S700 = _slang_select(_S699, _S698,1.0f);
    return _S696 / make_float3 (_S700) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_8, float3  radiance_1, float density_0, uint random_state_9)
{
    TreeSample _S701;
    (&_S701)->dir = dir_8;
    (&_S701)->radiance = radiance_1;
    (&_S701)->density = density_0;
    (&_S701)->random_state = random_state_9;
    return _S701;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_12, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S702 = importance(first_1, p_12, normal_3);
    float _S703 = importance(second_1, p_12, normal_3);
    float2  _S704 = make_float2 (_S702, _S703);
    bool _S705 = _S702 == 0.0f;
    bool _S706;
    if(_S705)
    {
        _S706 = _S703 == 0.0f;
    }
    else
    {
        _S706 = false;
    }
    if(_S706)
    {
        return 2U;
    }
    float _S707 = _S702 + _S703;
    bool _S708 = _S703 > 0.0f;
    if(_S708)
    {
        _S706 = (*pick_0 * _S707) >= _S702;
    }
    else
    {
        _S706 = false;
    }
    uint _S709 = uint(_S706);
    float _S710 = (F32_min(((*pick_0 * _S707 - float(_S709) * _S702) / _slang_vector_get_element(_S704, _S709)), (0.99999994039535522f)));
    *pick_0 = _S710;
    float _S711 = *probability_3 * (_slang_vector_get_element(_S704, _S709) / _S707);
    *probability_3 = _S711;
    return _S709;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_13, float u1_0, float u2_0)
{
    float3  _S712 = center_1 - p_13;
    float _S713 = radius_1 * radius_1 / dot_0(_S712, _S712);
    float _S714 = u1_0 * _S713 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S713), (0.0f)))))));
    float _S715 = 2.0f * u1_0;
    bool _S716 = _S713 >= 1.0f;
    float _S717 = _slang_select(_S716, _S715,_S714);
    float _S718 = (F32_sqrt(((F32_max((_S717 * (2.0f - _S717)), (0.0f))))));
    float _S719 = 6.28318548202514648f * u2_0;
    float3  _S720 = make_float3 (_S718 * (F32_cos((_S719))), 1.0f - _S717, _S718 * (F32_sin((_S719))));
    float3  _S721 = ((((_S712)) * make_float3(rnorm3df(((_S712)).x, ((_S712)).y, ((_S712)).z))));
    float3  _S722 = tangentToWorld(_S720, _S721);
    return _S722;
}

__device__ float3  pointLightRadiance(float3  color_3, float intensity_0, float radius_2)
{
    return color_3 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S723 = center_2 - ray_1->origin;
    float _S724 = dot_0(_S723, ray_1->unit_direction);
    float _S725 = dot_0(_S723, _S723) - _S724 * _S724;
    float _S726 = radius_3 * radius_3;
    bool _S727 = _S725 > _S726;
    if(_S727)
    {
        return 4.294967296e+09f;
    }
    float _S728 = (F32_sqrt((_S726 - _S725)));
    float _S729 = _S724 - _S728;
    float _S730 = _S724 + _S728;
    bool _S731 = _S729 > 0.0000152587890625f;
    bool _S732;
    if(_S731)
    {
        _S732 = _S729 < max_len_0;
    }
    else
    {
        _S732 = false;
    }
    if(_S732)
    {
        return _S729;
    }
    bool _S733 = _S730 > 0.0000152587890625f;
    if(_S733)
    {
        _S732 = _S730 < max_len_0;
    }
    else
    {
        _S732 = false;
    }
    if(_S732)
    {
        return _S730;
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
        *_slang_vector_get_element_ptr(&result_6, j_1) = sum_0;
        j_1 = j_1 + int(1);
    }
    return result_6;
}

static __device__ __forceinline__ TreeSample sampleLightTree_0(float3  origin_4, float3  smooth_n_2, float3  geometry_n_1, float geometry_offset_1, bool sided_0, uint init_random_state_1, ShadowContext * context_3)
{
    Random _S734 = pcg(init_random_state_1);
    Random _S735 = pcg(_S734.state);
    Random _S736 = pcg(_S735.state);
    float3  _S737 = make_float3 (0.0f);
    TreeSample _S738 = TreeSample_x24init_0(_S737, _S737, 0.0f, _S736.state);
    TreeSample sample_0 = _S738;
    float3  _S739 = _slang_select(sided_0, _S737,smooth_n_2);
    float3  _S740 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S734.value;
    float probability_4 = 1.0f;
    uint n_10 = 0U;
    for(;;)
    {
        uint4  _S741 = (fcptLightNode((n_10)));
        if((_S741.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S742 = (fcptLightSecond((n_10)));
        uint _S743 = n_10 + 1U;
        LightNode _S744 = (fcptLightBounds((_S743)));
        LightNode _S745 = (fcptLightBounds((_S742)));
        uint _S746 = pickChild(_S744, _S745, origin_4, _S739, &pick_1, &probability_4);
        bool _S747 = _S746 > 1U;
        if(_S747)
        {
            return sample_0;
        }
        bool _S748 = _S746 == 1U;
        uint _S749 = _slang_select(_S748, _S742,_S743);
        n_10 = _S749;
    }
    bool _S750 = n_10 == 0U;
    bool _S751;
    if(_S750)
    {
        LightNode _S752 = (fcptLightBounds((0U)));
        float _S753 = importance(_S752, origin_4, _S739);
        _S751 = !(_S753 > 0.0f);
    }
    else
    {
        _S751 = false;
    }
    if(_S751)
    {
        return sample_0;
    }
    uint4  _S754 = (fcptLightNode((n_10)));
    FKHit _S755 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S756 = (_S754.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S756)
    {
        FKLight _S757 = (fcptLight((_S754.y)));
        if(sided_0)
        {
            float _S758 = sign_0(dot_0(geometry_n_1, _S757.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S758);
            float3  _S759 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S759;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S740;
            lift_n_0 = smooth_n_2;
        }
        bool _S760 = (_S757.variance) == 0.0f;
        if(_S760)
        {
            float3  _S761 = _S757.position - emitter_point_0;
            float3  _S762 = ((((_S761)) * make_float3(rnorm3df(((_S761)).x, ((_S761)).y, ((_S761)).z))));
            (&sample_0)->dir = _S762;
            float3  _S763 = _S757.color * make_float3 (_S757.intensity) / make_float3 (dot_0(_S761, _S761) * probability_4);
            (&sample_0)->radiance = _S763;
            shadow_1 = _S761;
        }
        else
        {
            float3  _S764 = sampleSphere(_S757.position, _S757.variance, emitter_point_0, _S735.value, _S736.value);
            (&sample_0)->dir = _S764;
            float _S765 = sphereDensity(_S757.position, _S757.variance, emitter_point_0);
            float _S766 = probability_4 * _S765;
            (&sample_0)->density = _S766;
            float3  _S767 = pointLightRadiance(_S757.color, _S757.intensity, _S757.variance);
            float3  _S768 = _S767 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S768;
            FKRay _S769 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S770 = raySphere_0(_S757.position, _S757.variance, &_S769, 4.294967296e+09f);
            float3  _S771 = (&sample_0)->dir * make_float3 (_S770);
            shadow_1 = _S771;
        }
        emitter_0 = _S755;
        emitter_point_0 = _S737;
    }
    else
    {
        uint _S772 = _S754.y;
        uint _S773 = (fcptTriangleOffset((_S772)));
        uint _S774 = _S773 + _S754.z;
        Matrix<float, 3, 3>  _S775 = (fcptWorldTriangle((_S772), (_S774)));
        float _S776 = (F32_sqrt((_S735.value)));
        float2  _S777 = make_float2 (_S776 * (1.0f - _S736.value), _S776 * _S736.value);
        float3  _S778 = mul_0(make_float3 (1.0f - _S776, _S777.x, _S777.y), _S775);
        if(sided_0)
        {
            float _S779 = sign_0(dot_0(geometry_n_1, _S778 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S779);
            float3  _S780 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S780;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S781 = !((dot_0(smooth_n_2, _S778 - origin_4)) > 0.0f);
            if(_S781)
            {
                return sample_0;
            }
            emitter_point_0 = _S740;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S777, _S772, _S774, 0U, 0.0f);
        float3  _S782 = _S778 - emitter_point_0;
        float3  _S783 = ((((_S782)) * make_float3(rnorm3df(((_S782)).x, ((_S782)).y, ((_S782)).z))));
        (&sample_0)->dir = _S783;
        float _S784 = solidAngle(probability_4, cross_0(_S775.rows[int(1)] - _S775.rows[int(0)], _S775.rows[int(2)] - _S775.rows[int(0)]), _S782);
        (&sample_0)->density = _S784;
        bool _S785 = (fcptShadowFirst());
        bool _S786 = !_S785;
        if(_S786)
        {
            FKSurface _S787 = (fcptLightSurfaceAt((emitter_1), (_S778), (_S736.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S778 - origin_4))));
            (&sample_0)->random_state = _S787.random_state;
            float3  _S788 = _slang_select(_S787.skip, _S737,_S787.material.emissive);
            float3  _S789 = _S788 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S789;
        }
        shadow_1 = _S782;
        emitter_0 = emitter_1;
        emitter_point_0 = _S778;
    }
    FKHit _S790 = emitter_0;
    float3  _S791 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S736.state, &_S790);
    bool _S792 = (fcptShadowFirst());
    if(_S792)
    {
        _S751 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S751 = false;
    }
    if(_S751)
    {
        _S751 = !all_1(_S791 == _S737);
    }
    else
    {
        _S751 = false;
    }
    if(_S751)
    {
        FKSurface _S793 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S736.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S793.random_state;
        float3  _S794 = _slang_select(_S793.skip, _S737,_S793.material.emissive);
        float3  _S795 = _S794 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S795;
    }
    float3  _S796 = (&sample_0)->radiance * _S791;
    bool _S797 = all_1(_S791 == _S737);
    float3  _S798 = _slang_select(_S797, _S737,_S796);
    (&sample_0)->radiance = _S798;
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
    float _S799 = 1.0f / (1.0f + b_3 / a_7 * (b_3 / a_7));
    bool _S800 = b_3 > 0.0f;
    float _S801 = _slang_select(_S800, _S799,1.0f);
    return _S801;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S802 = vertex_0->none;
    if(_S802)
    {
        return 1.0f;
    }
    uint _S803 = (fcptLightSlot((*hit_1)));
    float _S804 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S803, light_point_1);
    float _S805 = powerHeuristic(vertex_0->pdf, _S804);
    return _S805;
}

static __device__ float3  environment_0(float3  dir_9, uint depth_1, uint lobe_0)
{
    uint2  _S806 = (fcptEnvironmentMapSize());
    bool _S807 = (_S806.x) > 1U;
    bool _S808;
    if(_S807)
    {
        uint2  _S809 = (fcptEnvironmentMapSize());
        _S808 = (_S809.y) > 1U;
    }
    else
    {
        _S808 = false;
    }
    if(_S808)
    {
        float3  _S810 = (fcptEnvMapSample((dir_9), (depth_1), (lobe_0)));
        return _S810;
    }
    float3  _S811 = (fcptAmbient());
    return _S811;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S812 = (fcptEnvironmentCdfSize());
    bool _S813 = (_S812.x) > 1U;
    bool _S814;
    if(_S813)
    {
        uint2  _S815 = (fcptEnvironmentCdfSize());
        _S814 = (_S815.y) > 1U;
    }
    else
    {
        _S814 = false;
    }
    bool _S816 = !_S814;
    if(_S816)
    {
        return false;
    }
    uint2  _S817 = (fcptEnvironmentMapSize());
    bool _S818 = (_S817.x) > 1U;
    if(_S818)
    {
        uint2  _S819 = (fcptEnvironmentMapSize());
        _S814 = (_S819.y) > 1U;
    }
    else
    {
        _S814 = false;
    }
    return _S814;
}

static __device__ float escapeWeight_0(float pdf_5, float3  dir_10)
{
    bool _S820 = pdf_5 <= 0.0f;
    bool _S821;
    if(_S820)
    {
        _S821 = true;
    }
    else
    {
        bool _S822 = environmentMapped_0();
        _S821 = !_S822;
    }
    if(_S821)
    {
        return 1.0f;
    }
    float _S823 = environmentPdf_0(dir_10);
    return pdf_5 / (pdf_5 + _S823);
}

static __device__ void restir_duplicates_0(uint3  global_invocation_id_1, uint3  local_invocation_id_0, uint local_invocation_index_3)
{
    uint2  _S824 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S825 = make_int2 ((int)_S824.x, (int)_S824.y);
    uint _S826 = previousSeed_0(_S825);
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
            uint _S827 = previousSeed_0(_S825 + make_int2 (x_16, y_5));
            bool _S828 = _S827 == _S826;
            uint _S829 = _slang_select(_S828, 1U,0U);
            uint count_3 = count_2 + _S829;
            int x_17 = x_16 + int(1);
            x_16 = x_17;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S830 = float(count_2 - 1U) / 288.0f;
    bool _S831 = _S826 != 0U;
    float _S832 = _slang_select(_S831, _S830,0.0f);
    fcptStoreDuplication((_S825), (make_uint4 ((F32_asuint((_S832))), 0U, 0U, 0U)));
    return;
}

static __device__ float3  abs_0(float3  x_18)
{
    float3  result_7;
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
        *_slang_vector_get_element_ptr(&result_7, i_13) = (F32_abs((_slang_vector_get_element(x_18, i_13))));
        i_13 = i_13 + int(1);
    }
    return result_7;
}

__device__ float resamplingTarget(float3  f_5)
{
    float _S833 = rgb_to_greyscale(abs_0(f_5));
    return _S833;
}

__device__ uint stream(uint seed_3, uint index_0)
{
    uint _S834 = hash(index_0);
    uint _S835 = hash(seed_3 ^ _S834);
    return _S835;
}

static __device__ float4  asfloat_0(uint4  x_19)
{
    float4  result_8;
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
        *_slang_vector_get_element_ptr(&result_8, i_14) = (U32_asfloat((_slang_vector_get_element(x_19, i_14))));
        i_14 = i_14 + int(1);
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
        *_slang_vector_get_element_ptr(&result_9, i_15) = (F32_asuint((_slang_vector_get_element(x_20, i_15))));
        i_15 = i_15 + int(1);
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
        *_slang_vector_get_element_ptr(&result_10, i_16) = (F32_asuint((_slang_vector_get_element(x_21, i_16))));
        i_16 = i_16 + int(1);
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

static __device__ float interpolate_0(float a_8, float b_4, float t_20)
{
    return a_8 + (b_4 - a_8) * t_20;
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

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_6)
{
    uint _S1002 = (1U << count_6) - 1U;
    return (e_2 & (~(_S1002 << offset_1))) | ((newbits_0 & _S1002) << offset_1);
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S1003 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S1004 = make_int2 ((int)_S1003.x, (int)_S1003.y);
    float3  _S1005 = make_float3 (0.0f);
    float2  _S1006 = make_float2 (0.0f);
    FKHit _S1007 = Hit_x24init_0(_S1006, 0U, 0U, 0U, 0.0f);
    Domain _S1008 = Domain_x24init_0(_S1005, _S1005, &_S1007, 0.0f, 0.0f);
    Domain dom_6 = _S1008;
    bool _S1009 = (fcptCurrentDomain((_S1004), (&dom_6)));
    bool _S1010 = !_S1009;
    if(_S1010)
    {
        Reservoir _S1011 = (Reservoir{});
        fcptStoreReservoirInitial((_S1004), (_S1011), ((&dom_6)->hit));
        return;
    }
    uint _S1012 = (fcptFrame());
    uint _S1013 = hash(_S1012);
    uint _S1014 = global_invocation_id_8.x;
    uint2  _S1015 = (fcptRenderSize());
    uint _S1016 = global_invocation_id_8.y;
    uint _S1017 = stream(_S1013, _S1014 + _S1015.x * _S1016);
    uint2  _S1018 = (fcptRenderSize());
    uint _S1019 = stream(_S1014 + _S1018.x * _S1016, 512U);
    Selection _S1020 = (Selection{});
    Selection initial_0 = _S1020;
    uint _S1021 = stream(_S1017, 193U);
    (&initial_0)->random_state = _S1021;
    bool _S1022 = (fcptRestirUsed());
    bool _S1023 = !_S1022;
    (&initial_0)->sums = _S1023;
    uint _S1024 = stream(_S1017, 0U);
    (&(&initial_0)->r)->seed = _S1024;
    FKHit _S1025 = Hit_x24init_0(_S1006, 4294967295U, 0U, 0U, 0.0f);
    uint _S1026 = (fcptSamples());
    float _S1027 = 1.0f / float(_S1026);
    FKHit hit_2 = _S1025;
    uint i_17 = 0U;
    float3  seen_1 = _S1005;
    for(;;)
    {
        uint _S1028 = (fcptSamples());
        if(i_17 < _S1028)
        {
        }
        else
        {
            break;
        }
        Reservoir _S1029 = (Reservoir{});
        Reservoir r_6 = _S1029;
        uint _S1030 = stream(_S1017, i_17);
        (&r_6)->seed = _S1030;
        uint _S1031 = (fcptFrame());
        uint _S1032 = (fcptSamples());
        uint _S1033 = _S1031 * _S1032 + i_17;
        uint _S1034 = insertBits_0(0U, 1U, 24U, 1U);
        uint _S1035 = insertBits_0(_S1034, (_S1019 + _S1033 * 2654435769U) >> 25U, 25U, 7U);
        (&r_6)->path = _S1035;
        Domain path_0 = _S1008;
        bool _S1036 = (fcptStoredDomainInitial((_S1004), ((&r_6)->seed), (&path_0)));
        bool _S1037 = !_S1036;
        if(_S1037)
        {
            float3  _S1038 = (fcptMissed((_S1004), (path_0), (_S1027)));
            float3  seen_2 = seen_1 + _S1038;
            seen_1 = seen_2;
            uint i_18 = i_17 + 1U;
            i_17 = i_18;
            continue;
        }
        Domain _S1039 = path_0;
        Reservoir _S1040 = r_6;
        Shift _S1041 = passWalk_0(&_S1039, &_S1040, false, _S1027, &initial_0);
        bool _S1042 = ((&(&initial_0)->r)->seed) == ((&r_6)->seed);
        FKHit hit_3;
        if(_S1042)
        {
            FKHit _S1043 = (&path_0)->hit;
            hit_3 = _S1043;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_18 = i_17 + 1U;
        i_17 = i_18;
    }
    uint _S1044 = (fcptSamples());
    float3  seen_3 = seen_1 + (&initial_0)->glow / make_float3 (float(_S1044));
    if((&initial_0)->sums)
    {
        seen_1 = seen_3 + (&initial_0)->color;
    }
    else
    {
        seen_1 = seen_3;
    }
    fcptAddColor((_S1004), (make_float4 (seen_1.x, seen_1.y, seen_1.z, 1.0f)));
    Reservoir _S1045 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S1004), (_S1045), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_6, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S1046;
    (&_S1046)->none = none_0;
    (&_S1046)->pdf = pdf_6;
    (&_S1046)->origin = origin_5;
    (&_S1046)->smooth_n = smooth_n_3;
    (&_S1046)->start = start_6;
    return _S1046;
}

struct Vertex
{
    bool rough;
    uint lobe;
    float pdf;
    float cos;
    bool inside;
};

static __device__ Vertex Vertex_x24init_0(bool rough_0, uint lobe_1, float pdf_7, float cos_0, bool inside_0)
{
    Vertex _S1047;
    (&_S1047)->rough = rough_0;
    (&_S1047)->lobe = lobe_1;
    (&_S1047)->pdf = pdf_7;
    (&_S1047)->cos = cos_0;
    (&_S1047)->inside = inside_0;
    return _S1047;
}

static __device__ float freeFlight_0(float u_1, float sigma_0)
{
    return - (F32_log((1.0f - u_1))) / sigma_0;
}

__device__ float upsample(float3  rgb_1, float wavelength_0)
{
    float _S1048 = dot_0(make_float3 (-0.08011700212955475f, 1.08901798725128174f, -0.00889899954199791f), rgb_1);
    float _S1049 = dot_0(make_float3 (0.12177000194787979f, -1.22903203964233398f, 1.10724997520446777f), rgb_1);
    float _S1050 = dot_0(make_float3 (1.17252397537231445f, -1.21603405475616455f, 0.04350199922919273f), rgb_1);
    float3  _S1051 = make_float3 (_S1048, _S1049, _S1050);
    float _S1052 = (wavelength_0 - 0.44999998807907104f) / 0.02999999932944775f;
    float _S1053 = (wavelength_0 - 0.63999998569488525f) / 0.03999999910593033f;
    return _S1048 + _S1049 * (F32_exp((-0.5f * _S1052 * _S1052))) + _S1050 * (F32_exp((-0.5f * _S1053 * _S1053)));
}

__device__ float3  pathColor(float3  f_6, float3  weight_1, float wavelength_1)
{
    float3  _S1054;
    if(wavelength_1 > 0.0f)
    {
        float _S1055 = upsample(f_6, wavelength_1);
        _S1054 = weight_1 * make_float3 (_S1055);
    }
    else
    {
        _S1054 = f_6;
    }
    return _S1054;
}

static __device__ float3  exp_0(float3  x_22)
{
    float3  result_11;
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
        *_slang_vector_get_element_ptr(&result_11, i_19) = (F32_exp((_slang_vector_get_element(x_22, i_19))));
        i_19 = i_19 + int(1);
    }
    return result_11;
}

static __device__ float3  flightWeight_0(float3  scatter_0, float3  extinction_0, float sigma_1, float distance_2, bool scatters_0)
{
    float3  _S1056 = exp_0((make_float3 (sigma_1) - extinction_0) * make_float3 (distance_2));
    float3  _S1057 = scatter_0 * _S1056 / make_float3 (sigma_1);
    float3  _S1058 = _slang_select(scatters_0, _S1057,_S1056);
    return _S1058;
}

static __device__ bool scatterSampled_0(bool replay_1, uint b_5, uint stop_0, bool varying_0)
{
    bool _S1059 = !replay_1;
    bool _S1060;
    if(_S1059)
    {
        _S1060 = true;
    }
    else
    {
        bool _S1061 = b_5 == stop_0;
        if(_S1061)
        {
            _S1060 = !varying_0;
        }
        else
        {
            _S1060 = false;
        }
    }
    return _S1060;
}

static __device__ uint arrivalLobe_0(uint b_6, uint prev_lobe_0)
{
    bool _S1062 = b_6 > 0U;
    uint _S1063 = _slang_select(_S1062, prev_lobe_0,3U);
    return _S1063;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_2, uint lobe_2, bool surface_5, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S1064;
    (&_S1064)->extinction_behind = extinction_behind_0;
    (&_S1064)->extinction_front = extinction_front_0;
    (&_S1064)->fillings = fillings_0;
    (&_S1064)->side = side_0;
    (&_S1064)->depth = depth_2;
    (&_S1064)->lobe = lobe_2;
    (&_S1064)->surface = surface_5;
    (&_S1064)->length = length_2;
    (&_S1064)->width = width_1;
    (&_S1064)->own = *own_2;
    (&_S1064)->fiber = fiber_0;
    return _S1064;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S1065 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S1065)
    {
        return 0.07957746833562851f;
    }
    float _S1066 = g_0 * g_0;
    return (1.0f - _S1066) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S1066 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_9, float3  b_7)
{
    float3  _S1067 = a_9 / b_7;
    float3  _S1068 = make_float3 (0.0f);
    bool3  _S1069 = b_7 == _S1068;
    float3  _S1070 = _slang_select(_S1069, _S1068,_S1067);
    return _S1070;
}

__device__ Reservoir withEnd(Reservoir r_7, uint end_type_0, uint end_0, float3  f_7)
{
    Reservoir candidate_2 = r_7;
    uint _S1071 = insertBits_0(r_7.path, end_0, 0U, 5U);
    uint _S1072 = insertBits_0(_S1071, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S1072;
    (&candidate_2)->f = f_7;
    return candidate_2;
}

__device__ float survivalProbability(float3  throughput_2, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_2.x), ((F32_max((throughput_2.y), (throughput_2.z)))))) / density_1), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_10)
{
    Random _S1073 = pcg(random_state_10);
    Random _S1074 = pcg(_S1073.state);
    float _S1075 = 1.0f - 2.0f * _S1073.value;
    float _S1076 = (F32_sqrt(((F32_max((1.0f - _S1075 * _S1075), (0.0f))))));
    float _S1077 = 6.28318548202514648f * _S1074.value;
    return make_float3 (_S1076 * (F32_cos((_S1077))), _S1076 * (F32_sin((_S1077))), _S1075);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_11, uint random_state_11, float * pdf_8)
{
    bool _S1078 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1078)
    {
        *pdf_8 = 0.07957746833562851f;
        float3  _S1079 = isotropic_0(random_state_11);
        return _S1079;
    }
    Random _S1080 = pcg(random_state_11);
    Random _S1081 = pcg(_S1080.state);
    float _S1082 = g_1 * g_1;
    float _S1083 = 2.0f * g_1;
    float _S1084 = (1.0f - _S1082) / (1.0f - g_1 + _S1083 * _S1080.value);
    float _S1085 = clamp_1((1.0f + _S1082 - _S1084 * _S1084) / _S1083, -1.0f, 1.0f);
    float _S1086 = (F32_sqrt(((F32_max((1.0f - _S1085 * _S1085), (0.0f))))));
    float _S1087 = 6.28318548202514648f * _S1081.value;
    float _S1088 = phaseHG_0(g_1, _S1085);
    *pdf_8 = _S1088;
    float3  _S1089 = tangentToWorld(make_float3 (_S1086 * (F32_cos((_S1087))), _S1085, _S1086 * (F32_sin((_S1087)))), dir_11);
    float3  _S1090 = ((((_S1089)) * make_float3(rnorm3df(((_S1089)).x, ((_S1089)).y, ((_S1089)).z))));
    return _S1090;
}

static __device__ Vertex scatteredVertex_0(bool is_inside_5)
{
    return Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_5);
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_0, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_3, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2, float velvet_0, float3  toon_3, float dispersion_0)
{
    BSDFMaterial _S1091;
    (&_S1091)->albedo = albedo_0;
    (&_S1091)->emissive = emissive_0;
    (&_S1091)->roughness = roughness_0;
    (&_S1091)->metallic = metallic_0;
    (&_S1091)->transmission = transmission_0;
    (&_S1091)->ior = ior_0;
    (&_S1091)->absorption = absorption_0;
    (&_S1091)->specular_tint = specular_tint_0;
    (&_S1091)->specular_level = specular_level_0;
    (&_S1091)->translucent = translucent_0;
    (&_S1091)->sheen = sheen_3;
    (&_S1091)->sheen_roughness = sheen_roughness_0;
    (&_S1091)->anisotropy = anisotropy_0;
    (&_S1091)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1091)->tangent = tangent_2;
    (&_S1091)->velvet = velvet_0;
    (&_S1091)->toon = toon_3;
    (&_S1091)->dispersion = dispersion_0;
    return _S1091;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1092;
    (&_S1092)->scatter = scatter_1;
    (&_S1092)->extinction = extinction_1;
    (&_S1092)->g = g_2;
    return _S1092;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_13, bool skip_0, uint random_state_12, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1093;
    (&_S1093)->smooth_n = smooth_n_4;
    (&_S1093)->geometry_n = geometry_n_2;
    (&_S1093)->geometry_offset = geometry_offset_2;
    (&_S1093)->material = *material_13;
    (&_S1093)->skip = skip_0;
    (&_S1093)->random_state = random_state_12;
    (&_S1093)->coverage = coverage_0;
    (&_S1093)->encloses = encloses_0;
    (&_S1093)->volume = *volume_0;
    (&_S1093)->fills = fills_0;
    (&_S1093)->hair = hair_0;
    return _S1093;
}

static __device__ FKSurface emitting_0(FKSurface * surface_6, bool top_0)
{
    FKSurface lower_0 = *surface_6;
    float3  _S1094 = (&surface_6->material)->emissive;
    float3  _S1095 = make_float3 (0.0f);
    bool _S1096 = !top_0;
    float3  _S1097 = _slang_select(_S1096, _S1095,_S1094);
    (&(&lower_0)->material)->emissive = _S1097;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_7, float u_2)
{
    float _S1098 = surface_7->coverage;
    bool _S1099 = u_2 < _S1098;
    if(_S1099)
    {
        return *surface_7;
    }
    float3  _S1100 = make_float3 (0.0f);
    float3  _S1101 = make_float3 (1.0f);
    BSDFMaterial _S1102 = Material_x24init_0(_S1100, _S1100, 0.0f, 0.0f, 0.0f, 0.0f, _S1100, _S1101, 1.0f, _S1100, _S1100, 0.5f, 0.0f, 0.0f, _S1100, 0.0f, _S1100, 0.0f);
    BSDFMaterial material_14 = _S1102;
    (&material_14)->albedo = _S1101;
    (&material_14)->emissive = (&surface_7->material)->emissive;
    (&material_14)->transmission = 1.0f;
    (&material_14)->ior = 1.0f;
    (&material_14)->absorption = (&surface_7->material)->absorption;
    FKSurface through_0 = *surface_7;
    (&through_0)->material = material_14;
    return through_0;
}

__device__ float facingSign(float transmission_1, float3  face_0, float3  direction_0)
{
    bool _S1103 = transmission_1 > 0.0f;
    bool _S1104;
    if(_S1103)
    {
        _S1104 = true;
    }
    else
    {
        _S1104 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1105;
    if(_S1104)
    {
        _S1105 = 1.0f;
    }
    else
    {
        _S1105 = -1.0f;
    }
    return _S1105;
}

static __device__ bool arrivesBehind_0(float3  dir_12, float3  n_11)
{
    return (dot_0(dir_12, n_11)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_8, float3  dir_13)
{
    float3  _S1106 = surface_8->geometry_n;
    float _S1107 = facingSign((&surface_8->material)->transmission, surface_8->geometry_n, dir_13);
    FKSurface faced_0 = *surface_8;
    float3  _S1108 = surface_8->smooth_n * make_float3 (_S1107);
    (&faced_0)->smooth_n = _S1108;
    float3  _S1109 = _S1106 * make_float3 (_S1107);
    (&faced_0)->geometry_n = _S1109;
    return faced_0;
}

static __device__ float3  max_0(float3  x_23, float3  y_7)
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
        *_slang_vector_get_element_ptr(&result_12, i_20) = (F32_max((_slang_vector_get_element(x_23, i_20)), (_slang_vector_get_element(y_7, i_20))));
        i_20 = i_20 + int(1);
    }
    return result_12;
}

static __device__ float3  log_0(float3  x_24)
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
        *_slang_vector_get_element_ptr(&result_13, i_21) = (F32_log((_slang_vector_get_element(x_24, i_21))));
        i_21 = i_21 + int(1);
    }
    return result_13;
}

__device__ float3  beerLambert(float distance_3, float3  absorption_1)
{
    float3  _S1110 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1110));
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
    bool _S1111;
    if(open_0)
    {
        _S1111 = prev_rough_0;
    }
    else
    {
        _S1111 = false;
    }
    if(_S1111)
    {
        _S1111 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S1111 = false;
    }
    return _S1111;
}

__device__ bool dispersive(BSDFMaterial material_15)
{
    bool _S1112 = (material_15.dispersion) > 0.0f;
    bool _S1113;
    if(_S1112)
    {
        _S1113 = (material_15.ior) != 1.0f;
    }
    else
    {
        _S1113 = false;
    }
    return _S1113;
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
        uint _S1114 = (low_1 + high_1 + 1U) / 2U;
        bool _S1115 = (WAVELENGTH_CDF_0[_S1114]) <= u_3;
        if(_S1115)
        {
            low_1 = _S1114;
        }
        else
        {
            uint _S1116 = _S1114 - 1U;
            high_1 = _S1116;
        }
    }
    uint _S1117 = low_1;
    float _S1118 = WAVELENGTH_CDF_0[low_1 + 1U] - WAVELENGTH_CDF_0[low_1];
    return make_float2 (0.37999999523162842f + 0.00499999988824129f * (float(low_1) + (u_3 - WAVELENGTH_CDF_0[_S1117]) / _S1118), _S1118 / 0.00499999988824129f);
}

__device__ static const FixedArray<float, 243>  WAVELENGTH_WEIGHTS_0 = { {
    0.00547470012679696f, -0.00465690018609166f, 0.03257500007748604f, 0.00934640038758516f, -0.00796370021998882f, 0.05577300116419792f, 0.01846100017428398f, -0.01579399965703487f, 0.11072999984025955f, 0.0416410006582737f, -0.03577499836683273f, 0.2513900101184845f, 0.09349299967288971f, -0.08071800321340561f, 0.56742000579833984f, 0.1585099995136261f, -0.13764999806880951f, 0.97018998861312866f, 0.30943000316619873f, -0.27083000540733337f, 1.91740000247955322f, 0.55217999219894409f, -0.48754000663757324f, 3.46889996528625488f, 0.95016998052597046f, -0.84802001714706421f, 6.09439992904663086f, 1.42110002040863037f, -1.28929996490478516f, 9.45199966430664062f, 1.73409998416900635f, -1.6062999963760376f, 12.12800025939941406f, 2.08030009269714355f, -1.98810005187988281f, 15.68700027465820312f, 2.20600008964538574f, -2.20120000839233398f, 18.47699928283691406f, 2.03040003776550293f, -2.17700004577636719f, 19.92700004577636719f, 1.63429999351501465f, -2.00340008735656738f, 20.86899948120117188f, 0.99410998821258545f, -1.62629997730255127f, 20.57799911499023438f, 0.20011000335216522f, -1.11409997940063477f, 19.72100067138671875f, -0.67960000038146973f, -0.45403000712394714f, 17.77599906921386719f, -1.61679995059967041f, 0.37860000133514404f, 14.71500015258789062f, -2.53410005569458008f, 1.27540004253387451f, 11.86499977111816406f, -3.39079999923706055f, 2.2146000862121582f, 9.17669963836669922f, -4.03749990463256836f, 3.0522000789642334f, 6.59509992599487305f, -4.61299991607666016f, 3.89779996871948242f, 4.64589977264404297f, -5.43039989471435547f, 5.0121002197265625f, 3.3199000358581543f, -6.37769985198974609f, 6.33809995651245117f, 2.29699993133544922f, -7.44140005111694336f, 7.91739988327026367f, 1.45389997959136963f, -8.38580036163330078f, 9.60109996795654297f, 0.66465997695922852f, -9.0167999267578125f, 11.23999977111816406f, -0.04403600096702576f, -9.17749977111816406f, 12.63199996948242188f, -0.58126997947692871f, -8.97550010681152344f, 13.91499996185302734f, -0.95730000734329224f, -8.25290012359619141f, 14.86200046539306641f, -1.24430000782012939f, -6.92129993438720703f, 15.03899955749511719f, -1.43069994449615479f, -5.29169988632202148f, 14.90900039672851562f, -1.55149996280670166f, -3.43219995498657227f, 14.70499992370605469f, -1.63569998741149902f, -1.27190005779266357f, 14.24400043487548828f, -1.67030000686645508f, 1.15170001983642578f, 13.32199954986572266f, -1.636199951171875f, 3.73889994621276855f, 12.21199989318847656f, -1.56920003890991211f, 6.43590021133422852f, 10.94699954986572266f, -1.47730004787445068f, 9.16440010070800781f, 9.54769992828369141f, -1.36399996280670166f, 12.02000045776367188f, 8.18799972534179688f, -1.25450003147125244f, 14.78699970245361328f, 6.74429988861083984f, -1.13110005855560303f, 16.72299957275390625f, 5.08780002593994141f, -0.96561002731323242f, 18.14299964904785156f, 3.57019996643066406f, -0.80725997686386108f, 19.91900062561035156f, 2.36269998550415039f, -0.69273000955581665f, 21.05500030517578125f, 1.31369996070861816f, -0.58597999811172485f, 21.3899993896484375f, 0.42390000820159912f, -0.48298001289367676f, 20.99300003051757812f, -0.23857000470161438f, -0.39412000775337219f, 19.82200050354003906f, -0.6866300106048584f, -0.31501999497413635f, 18.12000083923339844f, -0.9412500262260437f, -0.24890999495983124f, 15.7089996337890625f, -1.02020001411437988f, -0.19076000154018402f, 13.19799995422363281f, -0.98919999599456787f, -0.14401000738143921f, 11.23999977111816406f, -0.93347001075744629f, -0.11133000254631042f, 9.36649990081787109f, -0.83820998668670654f, -0.08524099737405777f, 7.41249990463256836f, -0.70064002275466919f, -0.06283199787139893f, 5.71229982376098633f, -0.56079000234603882f, -0.04586699977517128f, 4.42280006408691406f, -0.44653001427650452f, -0.03396600112318993f, 3.34489989280700684f, -0.34457001090049744f, -0.02482499927282333f, 2.49309992790222168f, -0.26017999649047852f, -0.01808100007474422f, 1.82239997386932373f, -0.1921599954366684f, -0.01296999957412481f, 1.29499995708465576f, -0.13766999542713165f, -0.00907570030540228f, 0.92928999662399292f, -0.09956400096416473f, -0.00641620019450784f, 0.61835998296737671f, -0.06671299785375595f, -0.00421149982139468f, 0.40211999416351318f, -0.04354599863290787f, -0.00271830009296536f, 0.2844499945640564f, -0.03087200038135052f, -0.00191440002527088f, 0.20672999322414398f, -0.02246100082993507f, -0.00138829997740686f, 0.15044000744819641f, -0.01634499989449978f, -0.00101030000951141f, 0.10942000150680542f, -0.01188699994236231f, -0.0007347899954766f, 0.07099699974060059f, -0.00771349994465709f, -0.00047679000999779f, 0.04539500176906586f, -0.00493190018460155f, -0.00030484999297187f, 0.03424099832773209f, -0.00372010003775358f, -0.00022995000472292f, 0.02557599917054176f, -0.00277870008721948f, -0.00017175999528263f, 0.01842200011014938f, -0.00200140010565519f, -0.0001237099932041f, 0.01316899992525578f, -0.00143079995177686f, -0.00008843900286593f, 0.00838890019804239f, -0.00091141002485529f, -0.00005633700129692f, 0.00537079991772771f, -0.00058350997278467f, -0.00003606799873523f, 0.00328280008397996f, -0.00035665999166667f, -0.00002204600059486f, 0.00196009990759194f, -0.00021296000340953f, -0.00001316300040344f, 0.00168939994182438f, -0.00018354000349063f, -0.00001134499962063f, 0.00141050003003329f, -0.00015325000276789f, -0.00000947250009631f, 0.00097123999148607f, -0.00010551999730524f, -6.52239987175562419e-06f, 0.00066868000430986f, -0.00007264900341397f, -4.49060007667867467e-06f
} };
__device__ float3  wavelengthWeights(float wavelength_2)
{
    float _S1119 = clamp_1((wavelength_2 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    uint _S1120 = (U32_min((uint(_S1119)), (79U)));
    uint _S1121 = 3U * _S1120;
    float3  _S1122 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1121], WAVELENGTH_WEIGHTS_0[_S1121 + 1U], WAVELENGTH_WEIGHTS_0[_S1121 + 2U]);
    float3  _S1123 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1121 + 3U], WAVELENGTH_WEIGHTS_0[_S1121 + 4U], WAVELENGTH_WEIGHTS_0[_S1121 + 5U]);
    return _S1122 + (_S1123 - _S1122) * make_float3 (_S1119 - float(_S1120));
}

__device__ BSDFMaterial atWavelength(BSDFMaterial material_16, float wavelength_3)
{
    BSDFMaterial at_0 = material_16;
    float _S1124 = upsample(material_16.albedo, wavelength_3);
    float3  _S1125 = make_float3 (_S1124);
    (&at_0)->albedo = _S1125;
    float _S1126 = upsample(material_16.emissive, wavelength_3);
    float3  _S1127 = make_float3 (_S1126);
    (&at_0)->emissive = _S1127;
    float _S1128 = upsample(material_16.absorption, wavelength_3);
    float3  _S1129 = make_float3 (_S1128);
    (&at_0)->absorption = _S1129;
    float _S1130 = upsample(material_16.specular_tint, wavelength_3);
    float3  _S1131 = make_float3 (_S1130);
    (&at_0)->specular_tint = _S1131;
    float _S1132 = upsample(material_16.translucent, wavelength_3);
    float3  _S1133 = make_float3 (_S1132);
    (&at_0)->translucent = _S1133;
    float _S1134 = upsample(material_16.sheen, wavelength_3);
    float3  _S1135 = make_float3 (_S1134);
    (&at_0)->sheen = _S1135;
    return at_0;
}

__device__ float dispersedIor(float ior_1, float dispersion_1, float wavelength_4)
{
    float _S1136 = (ior_1 - 1.0f) * dispersion_1 / 1.90962409973144531f;
    float _S1137 = _S1136 * (1.0f / (wavelength_4 * wavelength_4) - 2.89662933349609375f);
    bool _S1138 = dispersion_1 > 0.0f;
    float _S1139 = _slang_select(_S1138, _S1137,0.0f);
    return ior_1 + _S1139;
}

__device__ float2  vertexEta(BSDFMaterial material_17, float n_dot_v_0)
{
    bool _S1140 = n_dot_v_0 < 0.0f;
    float _S1141 = _slang_select(_S1140, material_17.ior,1.0f);
    float _S1142 = _slang_select(_S1140, 1.0f,material_17.ior);
    return make_float2 (_S1141, _S1142);
}

__device__ float2  wavelengthEta(BSDFMaterial material_18, float n_dot_v_1, float wavelength_5)
{
    BSDFMaterial refractive_0 = material_18;
    float _S1143 = dispersedIor(material_18.ior, material_18.dispersion, wavelength_5);
    bool _S1144 = wavelength_5 > 0.0f;
    float _S1145 = _slang_select(_S1144, _S1143,material_18.ior);
    (&refractive_0)->ior = _S1145;
    float2  _S1146 = vertexEta(refractive_0, n_dot_v_1);
    return _S1146;
}

__device__ bool neeDecision(BSDFMaterial material_19, float n_dot_v_2, float eta_i_11, float eta_o_11)
{
    float _S1147 = fresnel((F32_abs((n_dot_v_2))), eta_i_11, eta_o_11);
    float3  _S1148 = mix_0(make_float3 (_S1147), material_19.albedo, material_19.metallic);
    float _S1149 = rgb_to_greyscale(_S1148);
    float _S1150 = (F32_max(((1.0f - _S1149) * (1.0f - material_19.metallic) * (1.0f - material_19.transmission)), (0.0f)));
    bool _S1151 = _S1150 > 0.03999999910593033f;
    bool _S1152;
    if(_S1151)
    {
        _S1152 = true;
    }
    else
    {
        _S1152 = (material_19.roughness) > 0.20000000298023224f;
    }
    return _S1152;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_20)
{
    float _S1153 = rgb_to_greyscale(material_20->translucent);
    return _S1153 > 0.0f;
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
    MediumSides _S1154;
    (&_S1154)->behind = *behind_0;
    (&_S1154)->front = *front_0;
    (&_S1154)->fillings = fillings_1;
    (&_S1154)->face = face_1;
    return _S1154;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_9, FKMedium * medium_0, uint filling_0, float3  dir_14, FKMedium * outside_0)
{
    float3  _S1155 = surface_9->geometry_n;
    MediumSides _S1156 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_9->geometry_n);
    MediumSides sides_0 = _S1156;
    bool _S1157 = surface_9->encloses;
    if(_S1157)
    {
        (&sides_0)->behind = surface_9->volume;
        *&((&(&sides_0)->fillings)->x) = surface_9->fills;
        bool _S1158 = (dot_0(dir_14, _S1155)) > 0.0f;
        if(_S1158)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_10, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_15, uint depth_3, uint lobe_3, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1159 = surface_10->geometry_n;
    ShadowContext _S1160 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_10->geometry_n, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
    bool _S1161 = surface_10->encloses;
    ShadowContext context_4;
    if(_S1161)
    {
        FKSurface faced_1 = *surface_10;
        float3  _S1162 = - _S1159;
        float3  _S1163 = _slang_select(turned_0, _S1162,_S1159);
        (&faced_1)->geometry_n = _S1163;
        FKMedium _S1164 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1165 = faced_1;
        FKMedium _S1166 = _S1164;
        MediumSides _S1167 = mediumSides_0(&_S1165, &_S1166, filling_1, dir_15, outside_1);
        ShadowContext _S1168 = ShadowContext_x24init_0(_S1167.behind.extinction, _S1167.front.extinction, _S1167.fillings, _S1159, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
        if(turned_0)
        {
            uint2  _S1169 = _S1167.fillings;
            ShadowContext _S1170 = ShadowContext_x24init_0(_S1167.front.extinction, _S1167.behind.extinction, uint2 {_S1169.y, _S1169.x}, _S1159, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
            context_4 = _S1170;
        }
        else
        {
            context_4 = _S1168;
        }
    }
    else
    {
        context_4 = _S1160;
    }
    return context_4;
}

static __device__ bool any_1(bool3  x_25)
{
    bool result_14 = false;
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
        if(result_14)
        {
            result_14 = true;
        }
        else
        {
            result_14 = (bool((_slang_vector_get_element(x_25, i_22))));
        }
        i_22 = i_22 + int(1);
    }
    return result_14;
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_10, float3  out_dir_2, float3  n_12, float3  g_n_0, BSDFMaterial material_21, float eta_i_12, float eta_o_12, uint random_state_13, MaterialTerms terms_4, ViewTerms view_terms_4)
{
    float3  _S1171 = negate_0(in_dir_10);
    float _S1172 = dot_0(n_12, _S1171);
    float _S1173 = sign_0(_S1172);
    float3  _S1174 = n_12 * make_float3 (_S1173);
    float _S1175 = dot_0(_S1174, out_dir_2);
    float _S1176 = material_21.roughness;
    float _S1177 = _S1176 * _S1176;
    bool _S1178 = (dot_0(g_n_0, _S1171) * dot_0(g_n_0, out_dir_2)) > 0.0f;
    uint _S1179;
    if((F32_abs((material_21.toon.x))) > 0.0f)
    {
        _S1179 = 1U;
    }
    else
    {
        _S1179 = 0U;
    }
    if(_S1178)
    {
        _S1179 = 3U + _S1179;
    }
    else
    {
        _S1179 = 1U;
    }
    float3  _S1180 = make_float3 (0.0f);
    HalfTerms _S1181 = HalfTerms_x24init_0(0.0f, 0.0f, _S1180, _S1180, 0.0f, 0.0f, _S1180, _S1180, 0.0f, 0.0f, 0.0f, 0.0f, _S1180, 0.0f, _S1180, _S1180, make_float2 (0.0f), 0.0f, 0.0f, _S1180, 0.0f, 0.0f, 0.0f, false, 1.0f, 0.0f, _S1180);
    uint half_of_2 = 4294967295U;
    HalfTerms lobe_terms_2 = _S1181;
    float3  ggx_n_3 = _S1180;
    float3  f_8 = _S1180;
    uint i_23 = 0U;
    for(;;)
    {
        if(i_23 < _S1179)
        {
        }
        else
        {
            break;
        }
        uint _S1182;
        if(!_S1178)
        {
            _S1182 = 1U;
        }
        else
        {
            if(i_23 == 0U)
            {
                _S1182 = 0U;
            }
            else
            {
                if(i_23 == 1U)
                {
                    _S1182 = 2U;
                }
                else
                {
                    if(i_23 == 2U)
                    {
                        _S1182 = 4U;
                    }
                    else
                    {
                        _S1182 = 6U;
                    }
                }
            }
        }
        uint _S1183;
        if(_S1182 == 6U)
        {
            _S1183 = 0U;
        }
        else
        {
            if(_S1182 == 4U)
            {
                _S1183 = 2U;
            }
            else
            {
                _S1183 = _S1182;
            }
        }
        bool _S1184 = _S1183 != half_of_2;
        float3  ggx_n_4;
        if(_S1184)
        {
            bool _S1185 = _S1183 == 0U;
            if(_S1185)
            {
                float3  _S1186 = sampledHalf(in_dir_10, n_12, material_21, random_state_13, view_terms_4);
                ggx_n_4 = _S1186;
            }
            else
            {
                bool _S1187 = _S1183 == 1U;
                if(_S1187)
                {
                    float3  _S1188 = refractedHalf(in_dir_10, out_dir_2, n_12, eta_i_12, eta_o_12);
                    ggx_n_4 = _S1188;
                }
                else
                {
                    float3  _S1189 = reflectedHalf(in_dir_10, out_dir_2);
                    ggx_n_4 = _S1189;
                }
            }
            HalfTerms _S1190 = precomputeHalf(in_dir_10, ggx_n_4, material_21, eta_i_12, eta_o_12, terms_4, view_terms_4);
            lobe_terms_2 = _S1190;
            half_of_2 = _S1183;
        }
        else
        {
            ggx_n_4 = ggx_n_3;
        }
        float3  throughput_3;
        float pdf_9;
        switch(_S1182)
        {
        case 0U:
            {
                float _S1191 = diffusePDF(_S1175, 0.0f, (F32_abs((_S1172))), _S1177, lobe_terms_2, eta_i_12, eta_o_12);
                float3  _S1192 = diffuseBSDF(out_dir_2, _S1174, _S1177, material_21, lobe_terms_2);
                pdf_9 = _S1191;
                throughput_3 = _S1192;
                break;
            }
        case 1U:
            {
                float _S1193 = refractPDF(_S1175, dot_0(out_dir_2, ggx_n_4), (F32_abs((_S1172))), _S1177, lobe_terms_2, eta_i_12, eta_o_12);
                float3  _S1194 = refractBSDF(out_dir_2, _S1174, _S1177, material_21, lobe_terms_2);
                pdf_9 = _S1193;
                throughput_3 = _S1194;
                break;
            }
        case 4U:
            {
                float _S1195 = sheenVelvetPDF(_S1175, 0.0f, (F32_abs((_S1172))), _S1177, lobe_terms_2, eta_i_12, eta_o_12);
                float3  _S1196 = sheenVelvetBSDF(out_dir_2, _S1174, _S1177, material_21, lobe_terms_2);
                pdf_9 = _S1195;
                throughput_3 = _S1196;
                break;
            }
        case 6U:
            {
                float _S1197 = toonPDF(_S1175, dot_0(out_dir_2, lobe_terms_2.toon_axis), (F32_abs((_S1172))), _S1177, lobe_terms_2, eta_i_12, eta_o_12);
                float3  _S1198 = toonBSDF(out_dir_2, _S1174, _S1177, material_21, lobe_terms_2);
                pdf_9 = _S1197;
                throughput_3 = _S1198;
                break;
            }
        default:
            {
                float _S1199 = reflectPDF(_S1175, 0.0f, (F32_abs((_S1172))), _S1177, lobe_terms_2, eta_i_12, eta_o_12);
                float3  _S1200 = reflectBSDF(out_dir_2, _S1174, _S1177, material_21, lobe_terms_2);
                pdf_9 = _S1199;
                throughput_3 = _S1200;
                break;
            }
        }
        float3  _S1201;
        if(pdf_9 > 0.0f)
        {
            _S1201 = throughput_3 * make_float3 (pdf_9);
        }
        else
        {
            _S1201 = _S1180;
        }
        if(i_23 == 0U)
        {
            f_8 = _S1201;
        }
        else
        {
            f_8 = f_8 + _S1201;
        }
        uint i_24 = i_23 + 1U;
        ggx_n_3 = ggx_n_4;
        i_23 = i_24;
    }
    return f_8;
}

__device__ float3  translucentCorrection(float3  in_dir_11, float3  out_dir_3, float3  n_13, float3  g_n_1, BSDFMaterial material_22, float eta_i_13, float eta_o_13, uint random_state_14, MaterialTerms terms_5, ViewTerms view_terms_5)
{
    float _S1202 = dot_0(n_13, out_dir_3);
    float3  _S1203 = negate_0(in_dir_11);
    bool _S1204 = (_S1202 * dot_0(n_13, _S1203)) < 0.0f;
    float3  _S1205 = negate_0(in_dir_11);
    float _S1206 = dot_0(n_13, _S1205);
    float _S1207 = sign_0(_S1206);
    float3  _S1208 = n_13 * make_float3 (_S1207);
    float _S1209 = material_22.roughness;
    float _S1210 = _S1209 * _S1209;
    float3  _S1211 = sampledHalf(in_dir_11, n_13, material_22, random_state_14, view_terms_5);
    HalfTerms _S1212 = precomputeHalf(in_dir_11, _S1211, material_22, eta_i_13, eta_o_13, terms_5, view_terms_5);
    float _S1213 = diffusePDF(dot_0(_S1208, out_dir_3), 0.0f, (F32_abs((_S1206))), _S1210, _S1212, eta_i_13, eta_o_13);
    float3  _S1214;
    if(_S1213 > 0.0f)
    {
        float3  _S1215 = diffuseBSDF(out_dir_3, _S1208, _S1210, material_22, _S1212);
        _S1214 = _S1215 * make_float3 (_S1213);
    }
    else
    {
        _S1214 = make_float3 (0.0f);
    }
    float3  _S1216 = negate_0(in_dir_11);
    bool _S1217 = (dot_0(g_n_1, _S1216) * dot_0(g_n_1, out_dir_3)) > 0.0f;
    float3  _S1218 = make_float3 (0.0f);
    float _S1219 = _slang_select(_S1217, -1.0f,1.0f);
    float3  _S1220 = _S1214 * make_float3 (_S1219);
    float3  _S1221 = _slang_select(_S1204, _S1220,_S1218);
    return _S1221;
}

__device__ float3  translucentBSDF(float3  in_dir_12, float3  out_dir_4, float3  n_14, float3  g_n_2, BSDFMaterial material_23, float eta_i_14, float eta_o_14, uint random_state_15)
{
    MaterialTerms _S1222 = precomputeMaterial(material_23, eta_i_14, eta_o_14);
    ViewTerms _S1223 = precomputeView(in_dir_12, n_14, material_23, _S1222);
    float3  _S1224 = BSDF(in_dir_12, out_dir_4, n_14, g_n_2, material_23, eta_i_14, eta_o_14, random_state_15, _S1222, _S1223);
    float3  _S1225 = translucentCorrection(in_dir_12, out_dir_4, n_14, g_n_2, material_23, eta_i_14, eta_o_14, random_state_15, _S1222, _S1223);
    return _S1224 + _S1225;
}

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_13, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_4, BSDFMaterial * material_24, float eta_i_15, float eta_o_15, bool competing_1, uint random_state_16)
{
    bool _S1226 = !competing_1;
    bool _S1227;
    if(_S1226)
    {
        _S1227 = true;
    }
    else
    {
        _S1227 = (light_2->density) == 0.0f;
    }
    if(_S1227)
    {
        bool _S1228 = isTranslucent_0(material_24);
        _S1227 = _S1228;
    }
    else
    {
        _S1227 = false;
    }
    if(_S1227)
    {
        float3  _S1229 = translucentBSDF(in_dir_13, light_2->dir, smooth_n_5, geometry_n_4, *material_24, eta_i_15, eta_o_15, random_state_16);
        return _S1229 * light_2->radiance;
    }
    MaterialTerms _S1230 = precomputeMaterial(*material_24, eta_i_15, eta_o_15);
    ViewTerms _S1231 = precomputeView(in_dir_13, smooth_n_5, *material_24, _S1230);
    if(_S1226)
    {
        _S1227 = true;
    }
    else
    {
        _S1227 = (light_2->density) == 0.0f;
    }
    if(_S1227)
    {
        float3  _S1232 = BSDF(in_dir_13, light_2->dir, smooth_n_5, geometry_n_4, *material_24, eta_i_15, eta_o_15, random_state_16, _S1230, _S1231);
        return _S1232 * light_2->radiance;
    }
    float3  _S1233 = light_2->dir;
    bool _S1234 = (dot_0(geometry_n_4, - in_dir_13) * dot_0(geometry_n_4, light_2->dir)) <= 0.0f;
    float3  _S1235 = neeBSDF(in_dir_13, _S1233, smooth_n_5, *material_24, eta_i_15, eta_o_15, _S1234, light_2->density, true, random_state_16, _S1230, _S1231);
    return _S1235 * light_2->radiance * make_float3 (light_2->density);
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_4, uint random_state_17, bool refracted_4, uint lobe_4, float pdf_10)
{
    SampleBSDF _S1236;
    (&_S1236)->unit_direction = unit_direction_1;
    (&_S1236)->throughput = throughput_4;
    (&_S1236)->random_state = random_state_17;
    (&_S1236)->refracted = refracted_4;
    (&_S1236)->lobe = lobe_4;
    (&_S1236)->pdf = pdf_10;
    return _S1236;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  n_i_8, float n_i_dot_v_6, float alpha_15, BSDFMaterial material_25, HalfTerms lobes_11, float eta_i_16, float eta_o_16, uint random_state_18)
{
    float3  _S1237 = make_float3 (1.0f);
    SampleBSDF _S1238 = SampleBSDF_x24init_0(_S1237, _S1237, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S1238;
    Random _S1239 = pcg(random_state_18);
    Random _S1240 = pcg(_S1239.state);
    (&sample_1)->random_state = _S1240.state;
    float _S1241 = _S1239.value;
    float _S1242 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1241 * _S1241))))));
    float _S1243 = 6.28318548202514648f * _S1240.value;
    float3  _S1244 = tangentToWorld(make_float3 (_S1242 * (F32_cos((_S1243))), _S1239.value, _S1242 * (F32_sin((_S1243)))), n_i_8);
    (&sample_1)->unit_direction = _S1244;
    (&sample_1)->lobe = 4U;
    float3  _S1245 = sheenVelvetBSDF((&sample_1)->unit_direction, n_i_8, alpha_15, material_25, lobes_11);
    (&sample_1)->throughput = _S1245;
    float _S1246 = sheenVelvetPDF(_S1239.value, 0.0f, n_i_dot_v_6, alpha_15, lobes_11, eta_i_16, eta_o_16);
    (&sample_1)->pdf = _S1246;
    return sample_1;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1247 = (F32_sqrt((random_1_0)));
    float _S1248 = 6.28318548202514648f * random_2_0;
    float _S1249 = _S1247 * (F32_cos((_S1248)));
    float _S1250 = _S1247 * (F32_sin((_S1248)));
    float _S1251 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1249 * _S1249 - _S1250 * _S1250))))));
    return make_float3 (_S1249, _S1251, _S1250);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_4, float3  n_i_9, float n_i_dot_v_7, float alpha_16, BSDFMaterial material_26, HalfTerms lobes_12, float eta_i_17, float eta_o_17, uint random_state_19)
{
    float3  _S1252 = make_float3 (1.0f);
    SampleBSDF _S1253 = SampleBSDF_x24init_0(_S1252, _S1252, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S1253;
    Random _S1254 = pcg(random_state_19);
    Random _S1255 = pcg(_S1254.state);
    (&sample_2)->random_state = _S1255.state;
    float3  _S1256 = sampleCosWeightedHemisphere(_S1254.value, _S1255.value);
    bool _S1257 = u_4 < (lobes_12.p_diffuse * lobes_12.translucent_share);
    float _S1258 = _S1256.y;
    float _S1259 = - _S1258;
    float _S1260 = _slang_select(_S1257, _S1259,_S1258);
    float3  _S1261 = tangentToWorld(make_float3 (_S1256.x, _S1260, _S1256.z), n_i_9);
    (&sample_2)->unit_direction = _S1261;
    (&sample_2)->refracted = _S1257;
    (&sample_2)->lobe = 0U;
    float3  _S1262 = diffuseBSDF((&sample_2)->unit_direction, n_i_9, alpha_16, material_26, lobes_12);
    (&sample_2)->throughput = _S1262;
    float _S1263 = diffusePDF(_S1260, 0.0f, n_i_dot_v_7, alpha_16, lobes_12, eta_i_17, eta_o_17);
    (&sample_2)->pdf = _S1263;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF toonSample(float3  n_i_10, float n_i_dot_v_8, float alpha_17, BSDFMaterial material_27, HalfTerms lobes_13, float eta_i_18, float eta_o_18, uint random_state_20)
{
    float3  _S1264 = make_float3 (1.0f);
    SampleBSDF _S1265 = SampleBSDF_x24init_0(_S1264, _S1264, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S1265;
    Random _S1266 = pcg(random_state_20);
    Random _S1267 = pcg(_S1266.state);
    (&sample_3)->random_state = _S1267.state;
    float _S1268 = _S1266.value * lobes_13.toon_norm / 6.28318548202514648f;
    float t_21;
    if(lobes_13.toon_glossy)
    {
        t_21 = (F32_acos((clamp_1(1.0f - _S1268, -1.0f, 1.0f))));
    }
    else
    {
        t_21 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1268)))), (1.0f))))));
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
        float _S1269;
        if(t_21 < (lobes_13.toon_a))
        {
            _S1269 = 1.0f;
        }
        else
        {
            _S1269 = (F32_max((1.0f - (t_21 - lobes_13.toon_a) / (F32_max((lobes_13.toon_s), (0.0000152587890625f)))), (0.0f)));
        }
        float integral_1;
        if(lobes_13.toon_glossy)
        {
            integral_1 = 1.0f - (F32_cos(((F32_min((t_21), (lobes_13.toon_a))))));
        }
        else
        {
            float _S1270 = (F32_sin(((F32_min((t_21), (lobes_13.toon_a))))));
            integral_1 = _S1270 * _S1270 / 2.0f;
        }
        bool _S1271 = t_21 > (lobes_13.toon_a);
        bool _S1272;
        if(_S1271)
        {
            _S1272 = (lobes_13.toon_s) > 0.0f;
        }
        else
        {
            _S1272 = false;
        }
        float integral_2;
        if(_S1272)
        {
            if(lobes_13.toon_glossy)
            {
                float _S1273 = (F32_cos((lobes_13.toon_a)));
                float _S1274 = (F32_cos((t_21)));
                integral_2 = (1.0f + lobes_13.toon_a / lobes_13.toon_s) * (_S1273 - _S1274) - ((F32_sin((t_21))) - t_21 * _S1274 - ((F32_sin((lobes_13.toon_a))) - lobes_13.toon_a * _S1273)) / lobes_13.toon_s;
            }
            else
            {
                float _S1275 = 2.0f * lobes_13.toon_a;
                float _S1276 = (F32_cos((_S1275)));
                float _S1277 = 2.0f * t_21;
                float _S1278 = (F32_cos((_S1277)));
                integral_2 = (1.0f + lobes_13.toon_a / lobes_13.toon_s) * (_S1276 - _S1278) / 4.0f - ((F32_sin((_S1277))) / 8.0f - t_21 * _S1278 / 4.0f - ((F32_sin((_S1275))) / 8.0f - lobes_13.toon_a * _S1276 / 4.0f)) / lobes_13.toon_s;
            }
            float integral_3 = integral_1 + integral_2;
            integral_2 = integral_3;
        }
        else
        {
            integral_2 = integral_1;
        }
        float _S1279 = _S1269 * (F32_sin((t_21)));
        float _S1280;
        if(lobes_13.toon_glossy)
        {
            _S1280 = 1.0f;
        }
        else
        {
            _S1280 = (F32_cos((t_21)));
        }
        float _S1281 = _S1279 * _S1280;
        float _S1282 = (integral_2 - _S1268) / _S1281;
        bool _S1283 = _S1281 > 0.0f;
        float _S1284 = _slang_select(_S1283, _S1282,0.0f);
        float _S1285 = clamp_1(t_21 - _S1284, 0.0f, lobes_13.toon_b);
        int k_1 = k_0 + int(1);
        t_21 = _S1285;
        k_0 = k_1;
    }
    float _S1286 = 6.28318548202514648f * _S1267.value;
    float _S1287 = (F32_sin((t_21)));
    float3  _S1288 = tangentToWorld(make_float3 (_S1287 * (F32_cos((_S1286))), (F32_cos((t_21))), _S1287 * (F32_sin((_S1286)))), lobes_13.toon_axis);
    (&sample_3)->unit_direction = _S1288;
    bool _S1289 = (dot_0(n_i_10, (&sample_3)->unit_direction)) < 0.0f;
    (&sample_3)->refracted = _S1289;
    (&sample_3)->lobe = 6U;
    float3  _S1290 = toonBSDF((&sample_3)->unit_direction, n_i_10, alpha_17, material_27, lobes_13);
    (&sample_3)->throughput = _S1290;
    float _S1291 = toonPDF(dot_0(n_i_10, (&sample_3)->unit_direction), dot_0((&sample_3)->unit_direction, lobes_13.toon_axis), n_i_dot_v_8, alpha_17, lobes_13, eta_i_18, eta_o_18);
    (&sample_3)->pdf = _S1291;
    return sample_3;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_5, float3  n_i_11, float n_i_dot_v_9, float alpha_18, BSDFMaterial material_28, HalfTerms lobes_14, float eta_i_19, float eta_o_19, uint random_state_21)
{
    float3  _S1292 = make_float3 (1.0f);
    SampleBSDF _S1293 = SampleBSDF_x24init_0(_S1292, _S1292, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S1293;
    (&sample_4)->unit_direction = lobes_14.refracted;
    (&sample_4)->random_state = random_state_21;
    (&sample_4)->refracted = true;
    (&sample_4)->lobe = 1U;
    float3  _S1294 = refractBSDF((&sample_4)->unit_direction, n_i_11, alpha_18, material_28, lobes_14);
    (&sample_4)->throughput = _S1294;
    float _S1295 = refractPDF(0.0f, dot_0((&sample_4)->unit_direction, ggx_n_5), n_i_dot_v_9, alpha_18, lobes_14, eta_i_19, eta_o_19);
    (&sample_4)->pdf = _S1295;
    return sample_4;
}

static __device__ float3  reflect_0(float3  i_25, float3  n_15)
{
    return i_25 - make_float3 (2.0f * dot_0(n_15, i_25)) * n_15;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_14, float3  ggx_n_6, float3  n_i_12, float n_i_dot_v_10, float alpha_19, BSDFMaterial material_29, HalfTerms lobes_15, float eta_i_20, float eta_o_20, uint random_state_22)
{
    float3  _S1296 = make_float3 (1.0f);
    SampleBSDF _S1297 = SampleBSDF_x24init_0(_S1296, _S1296, 0U, false, 0U, 0.0f);
    SampleBSDF sample_5 = _S1297;
    float3  _S1298 = reflect_0(in_dir_14, ggx_n_6);
    float3  _S1299 = ((((_S1298)) * make_float3(rnorm3df(((_S1298)).x, ((_S1298)).y, ((_S1298)).z))));
    (&sample_5)->unit_direction = _S1299;
    (&sample_5)->random_state = random_state_22;
    (&sample_5)->lobe = 2U;
    float3  _S1300 = reflectBSDF((&sample_5)->unit_direction, n_i_12, alpha_19, material_29, lobes_15);
    (&sample_5)->throughput = _S1300;
    float _S1301 = reflectPDF(0.0f, 0.0f, n_i_dot_v_10, alpha_19, lobes_15, eta_i_20, eta_o_20);
    (&sample_5)->pdf = _S1301;
    return sample_5;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_15, float3  n_16, BSDFMaterial material_30, float eta_i_21, float eta_o_21, uint random_init_0, float2  screen_space_0, MaterialTerms terms_6, ViewTerms view_terms_6)
{
    uint random_state_23 = random_init_0;
    float3  _S1302 = negate_0(in_dir_15);
    float _S1303 = dot_0(n_16, _S1302);
    float _S1304 = sign_0(_S1303);
    float3  n_i_13 = n_16 * make_float3 (_S1304);
    float _S1305 = (F32_abs((_S1303)));
    float _S1306 = material_30.roughness;
    float _S1307 = _S1306 * _S1306;
    float3  _S1308 = sampleHalfVector(_S1302, n_i_13, _S1307, view_terms_6.frame, &random_state_23);
    HalfTerms _S1309 = precomputeHalf(in_dir_15, _S1308, material_30, eta_i_21, eta_o_21, terms_6, view_terms_6);
    Random _S1310 = pcg(random_state_23);
    random_state_23 = _S1310.state;
    bool _S1311 = (_S1310.value) < (_S1309.p_sheen_velvet);
    if(_S1311)
    {
        SampleBSDF _S1312 = sheenVelvetSample(n_i_13, _S1305, _S1307, material_30, _S1309, eta_i_21, eta_o_21, random_state_23);
        return _S1312;
    }
    float _S1313 = _S1310.value - _S1309.p_sheen_velvet;
    bool _S1314 = _S1313 < (_S1309.p_diffuse);
    if(_S1314)
    {
        SampleBSDF _S1315 = diffuseSample(_S1313, n_i_13, _S1305, _S1307, material_30, _S1309, eta_i_21, eta_o_21, random_state_23);
        return _S1315;
    }
    bool _S1316 = _S1313 < (_S1309.p_diffuse + _S1309.p_toon);
    if(_S1316)
    {
        SampleBSDF _S1317 = toonSample(n_i_13, _S1305, _S1307, material_30, _S1309, eta_i_21, eta_o_21, random_state_23);
        return _S1317;
    }
    bool _S1318 = (_S1313 - _S1309.p_toon) < (_S1309.p_diffuse + _S1309.p_refract);
    if(_S1318)
    {
        SampleBSDF _S1319 = refractSample(_S1308, n_i_13, _S1305, _S1307, material_30, _S1309, eta_i_21, eta_o_21, random_state_23);
        return _S1319;
    }
    SampleBSDF _S1320 = reflectSample(in_dir_15, _S1308, n_i_13, _S1305, _S1307, material_30, _S1309, eta_i_21, eta_o_21, random_state_23);
    return _S1320;
}

__device__ bool withinInverseFootprint(float pdf_11, bool diffuse_0, float prev_cos_0, float distance_5, float threshold_1)
{
    bool _S1321 = pdf_11 > 0.0f;
    bool _S1322;
    if(_S1321)
    {
        if(diffuse_0)
        {
            _S1322 = true;
        }
        else
        {
            _S1322 = (pdf_11 * prev_cos_0 / (distance_5 * distance_5) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S1322 = false;
    }
    return _S1322;
}

__device__ bool roughLobe(float pdf_12, bool diffuse_1, float roughness_1)
{
    bool _S1323 = pdf_12 > 0.0f;
    bool _S1324;
    if(_S1323)
    {
        if(diffuse_1)
        {
            _S1324 = true;
        }
        else
        {
            _S1324 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S1324 = false;
    }
    return _S1324;
}

static __device__ bool passesLayer_0(uint layers_0, bool refracting_0, bool passed_0)
{
    bool _S1325 = layers_0 > 1U;
    bool _S1326;
    if(_S1325)
    {
        _S1326 = refracting_0 != passed_0;
    }
    else
    {
        _S1326 = false;
    }
    return _S1326;
}

static __device__ float widened_0(float spread_1, float pdf_13, bool delta_0)
{
    float _S1327 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * pdf_13))))), (3.14159274101257324f)));
    bool _S1328 = !delta_0;
    float _S1329 = _slang_select(_S1328, _S1327,0.0f);
    return spread_1 + _S1329;
}

static __device__ bool boundsVolume_0(FKSurface * surface_11)
{
    return surface_11->encloses;
}

static __device__ bool leavesInFront_0(float3  face_2, float3  dir_16, float3  g_3)
{
    return ((dot_0(dir_16, g_3)) > 0.0f) == ((dot_0(g_3, face_2)) > 0.0f);
}

static __device__ Shift walk_0(Domain * dom_7, Reservoir * r_8, bool replay_2, float scale_4, Selection * sel_7)
{
    float spread_2;
    bool turned_1;
    bool is_inside_6;
    bool viewed_0;
    bool _S1330;
    float density_2;
    float wavelength_6;
    float width_3;
    float sky_pdf_0;
    float threshold_2;
    uint b_8;
    uint layer_0;
    float3  throughput_5;
    float3  spectral_weight_0;
    TreeSample light_3;
    int _S1331;
    Shift ended_0;
    float density_3;
    float spread_3;
    float width_4;
    float sky_pdf_1;
    float spread_4;
    float width_5;
    uint b_9;
    float3  _S1332 = make_float3 (0.0f);
    Shift _S1333 = Shift_x24init_0(_S1332, 0.0f);
    uint _S1334 = r_8->path;
    uint _S1335 = extractBits_0(r_8->path, 0U, 5U);
    uint _S1336 = extractBits_0(_S1334, 5U, 5U);
    uint _S1337 = extractBits_0(_S1334, 10U, 2U);
    uint _S1338 = extractBits_0(_S1334, 12U, 3U);
    bool passes_0;
    if(replay_2)
    {
        bool _S1339 = _S1338 >= 3U;
        uint _S1340 = _slang_select(_S1339, 1U,0U);
        uint _S1341 = _S1335 + _S1340;
        uint _S1342 = (fcptMaxBounces());
        passes_0 = _S1341 > _S1342;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1333;
    }
    uint _S1343 = _S1336 - 1U;
    bool _S1344 = _S1338 == 3U;
    uint _S1345 = _slang_select(_S1344, 1U,0U);
    uint _S1346 = _S1335 + _S1345;
    bool _S1347 = _S1337 == 0U;
    uint _S1348 = _slang_select(_S1347, _S1346,_S1343);
    FKHit _S1349 = (fcptReservoirHit((*r_8)));
    float3  _S1350 = dom_7->x0;
    float3  _S1351 = dom_7->x1 - dom_7->x0;
    float3  _S1352 = ((((_S1351)) * make_float3(rnorm3df(((_S1351)).x, ((_S1351)).y, ((_S1351)).z))));
    FKRay _S1353 = Ray_x24init_0(dom_7->x1, _S1352);
    FKRay ray_2 = _S1353;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1332;
    float3  throughput_6 = make_float3 (1.0f);
    float3  weight_2 = throughput_6;
    float3  glowed_0 = _S1332;
    float3  extinction_in_0 = _S1332;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1354 = dom_7->spread;
    float _S1355 = dom_7->width;
    float _S1356 = length_0(_S1351);
    NEEVertex _S1357 = NEEVertex_x24init_0(true, 0.0f, _S1332, _S1332, _S1332);
    NEEVertex nee_vertex_0 = _S1357;
    Vertex _S1358 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S1358;
    Reservoir _S1359 = (Reservoir{});
    Reservoir chain_0 = _S1359;
    uint _S1360 = r_8->seed;
    (&chain_0)->seed = r_8->seed;
    uint _S1361 = extractBits_0(_S1334, 24U, 8U);
    uint _S1362 = insertBits_0(0U, _S1361, 24U, 8U);
    (&chain_0)->path = _S1362;
    (&ray_2)->origin = _S1350;
    (&hit_4)->distance = _S1356;
    FKMedium _S1363 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1364 = filling_2;
    bool _S1365 = (fcptVaryingUsed());
    uint _S1366 = _slang_select(_S1365, _S1364,4294967295U);
    filling_2 = _S1366;
    scatter_in_0 = _S1363.scatter;
    extinction_in_0 = _S1363.extinction;
    g_in_0 = _S1363.g;
    Reservoir _S1367 = chain_0;
    uint _S1368 = filling_2;
    for(;;)
    {
        bool _S1369 = (fcptVaryingUsed());
        if(_S1369)
        {
            passes_0 = _S1368 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1370 = (fcptMajorant((_S1368)));
            spread_2 = _S1370;
        }
        else
        {
            spread_2 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_2)
        {
            turned_1 = 4294967295U == _S1348;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1337 == 1U;
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
            ended_0 = _S1333;
            sky_pdf_0 = 0.0f;
            spread_2 = _S1354;
            width_3 = _S1355;
            density_2 = 1.0f;
            throughput_5 = throughput_6;
            b_8 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1371 = (&prev_0)->rough;
        if(_S1371)
        {
            turned_1 = !(spread_2 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S1372 = stream(_S1360, 384U);
        uint tracking_0 = _S1372;
        weight_2 = throughput_6;
        glowed_0 = _S1332;
        b_8 = 4294967295U;
        throughput_5 = throughput_6;
        density_2 = 1.0f;
        wavelength_6 = _S1354;
        width_3 = _S1355;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1331 = int(1);
                break;
            }
            uint _S1373 = b_8 + 320U;
            bool _S1374 = b_8 == 4294967295U;
            uint _S1375 = _slang_select(_S1374, 384U,_S1373);
            uint _S1376 = stream(_S1360, _S1375);
            Random _S1377 = pcg(_S1376);
            float _S1378 = freeFlight_0(_S1377.value, spread_2);
            if(passes_0)
            {
                float3  _S1379 = (&ray_2)->origin;
                float3  _S1380 = (&ray_2)->unit_direction;
                float _S1381 = (&hit_4)->distance;
                uint _S1382 = _slang_select(_S1374, 0U,b_8);
                uint _S1383 = (&prev_0)->lobe;
                uint _S1384 = _slang_select(_S1374, 3U,_S1383);
                float _S1385 = (fcptTrackMedium((_S1368), (_S1379), (_S1380), (_S1381), (&tracking_0), (&weight_2), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1382), (_S1384), (_S1374)));
                threshold_2 = _S1385;
            }
            else
            {
                threshold_2 = _S1378;
            }
            bool _S1386 = !(threshold_2 < ((&hit_4)->distance));
            if(_S1386)
            {
                _S1331 = int(1);
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
                float3  _S1387 = pathColor(throughput_5 * glowed_0, throughput_6, 0.0f);
                float3  _S1388 = _S1387 / make_float3 (density_2);
                float3  _S1389 = sel_7->glow + _S1388;
                sel_7->glow = _S1389;
            }
            else
            {
            }
            glowed_0 = _S1332;
            uint b_10 = b_8 + 1U;
            float3  _S1390 = (&ray_2)->origin + make_float3 (threshold_2) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1390;
            float3  _S1391 = flightWeight_0(scatter_in_0, extinction_in_0, spread_2, threshold_2, true);
            float3  _S1392 = weight_2;
            float _S1393 = upsample(weight_2, 0.0f);
            float3  _S1394 = make_float3 (_S1393);
            float3  _S1395 = _slang_select(false, _S1394,_S1392);
            float3  _S1396 = _slang_select(passes_0, _S1395,_S1391);
            float3  throughput_7 = throughput_5 * _S1396;
            uint _S1397 = stream(_S1360, b_10 + 320U);
            tracking_0 = _S1397;
            weight_2 = throughput_6;
            float width_6 = width_3 + wavelength_6 * threshold_2;
            float _S1398 = wavelength_6 + 3.14159274101257324f;
            bool _S1399 = scatterSampled_0(replay_2, b_10, _S1348, passes_0);
            TreeSample _S1400 = TreeSample_x24init_0(_S1332, _S1332, 0.0f, 0U);
            if(_S1399)
            {
                float3  _S1401 = (&ray_2)->origin;
                float3  _S1402 = (&ray_2)->unit_direction;
                float3  _S1403 = (&ray_2)->unit_direction;
                uint _S1404 = stream(_S1360, b_10 + 64U);
                float3  _S1405 = extinction_in_0;
                float3  _S1406 = extinction_in_0;
                uint2  _S1407 = make_uint2 (_S1368);
                float3  _S1408 = (&ray_2)->unit_direction;
                uint _S1409 = arrivalLobe_0(b_10, (&prev_0)->lobe);
                FKHit _S1410 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1411 = _S1410;
                ShadowContext _S1412 = ShadowContext_x24init_0(_S1405, _S1406, _S1407, _S1408, b_10, _S1409, false, threshold_2, width_6, &_S1411, false);
                ShadowContext _S1413 = _S1412;
                TreeSample _S1414 = sampleLightTree_0(_S1401, _S1402, _S1403, 0.0f, true, _S1404, &_S1413);
                light_3 = _S1414;
            }
            else
            {
                light_3 = _S1400;
            }
            float _S1415 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S1416 = (fcptMaxBounces());
            bool _S1417 = b_10 < _S1416;
            if(_S1417)
            {
                is_inside_6 = (light_3.density) > 0.0f;
            }
            else
            {
                is_inside_6 = false;
            }
            float _S1418 = _slang_select(is_inside_6, _S1415,0.0f);
            float3  _S1419 = throughput_7 * light_3.radiance;
            float _S1420 = powerHeuristic(light_3.density, _S1418);
            float3  _S1421 = pathColor(_S1419 * make_float3 (_S1415 * _S1420), throughput_6, 0.0f);
            float3  _S1422 = _slang_select(_S1399, _S1421,_S1332);
            if(replay_2)
            {
                viewed_0 = b_10 == _S1348;
            }
            else
            {
                viewed_0 = false;
            }
            if(viewed_0)
            {
                bool _S1423 = _S1337 == 2U;
                if(_S1423)
                {
                    float _S1424 = resamplingTarget(_S1422);
                    passes_0 = _S1424 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1425 = Shift_x24init_0(_S1422, 1.0f);
                    _S1331 = int(0);
                    ended_0 = _S1425;
                    spread_2 = _S1398;
                    threshold_2 = width_6;
                    spectral_weight_0 = throughput_7;
                    layer_0 = b_10;
                    break;
                }
                _S1331 = int(0);
                ended_0 = _S1333;
                spread_2 = _S1398;
                threshold_2 = width_6;
                spectral_weight_0 = throughput_7;
                layer_0 = b_10;
                break;
            }
            bool _S1426 = !replay_2;
            if(_S1426)
            {
                Reservoir candidate_3 = _S1367;
                uint _S1427 = extractBits_0(_S1367.path, 24U, 8U);
                uint _S1428 = insertBits_0(0U, _S1427, 24U, 8U);
                uint _S1429 = extractBits_0(_S1367.path, 10U, 2U);
                bool _S1430 = _S1429 == 1U;
                if(_S1430)
                {
                    float3  _S1431 = safeDivide(_S1422, _S1332);
                    (&candidate_3)->radiance = _S1431;
                }
                else
                {
                    uint _S1432 = insertBits_0(_S1428, b_10 + 1U, 5U, 5U);
                    uint _S1433 = insertBits_0(_S1432, 2U, 10U, 2U);
                    (&candidate_3)->path = _S1433;
                }
                Reservoir _S1434 = withEnd(candidate_3, 0U, b_10, _S1422);
                offer(sel_7, _S1434, _S1422 * make_float3 (scale_4) / make_float3 (density_2));
                float _S1435 = survivalProbability(abs_0(throughput_7), density_2);
                uint _S1436 = stream(_S1360, b_10 + 128U);
                Random _S1437 = pcg(_S1436);
                bool _S1438 = _S1435 < (_S1437.value);
                if(_S1438)
                {
                    _S1330 = true;
                }
                else
                {
                    uint _S1439 = (fcptMaxBounces());
                    _S1330 = b_10 >= _S1439;
                }
                if(_S1330)
                {
                    _S1331 = int(0);
                    ended_0 = _S1333;
                    spread_2 = _S1398;
                    threshold_2 = width_6;
                    spectral_weight_0 = throughput_7;
                    layer_0 = b_10;
                    break;
                }
                float _S1440 = density_2 * _S1435;
                density_2 = _S1440;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1441 = stream(_S1360, b_10);
            float3  _S1442 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1441, &phase_pdf_0);
            (&ray_2)->unit_direction = _S1442;
            NEEVertex _S1443 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S1332, (&ray_2)->origin);
            nee_vertex_0 = _S1443;
            Vertex _S1444 = scatteredVertex_0(false);
            prev_0 = _S1444;
            float _S1445 = (&prev_0)->pdf;
            FKRay _S1446 = ray_2;
            FKHit _S1447 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1448 = (fcptTraverseInstanceBVH((_S1446), (true), (4.294967296e+09f), (false), (_S1447), (false)));
            hit_4 = _S1448;
            b_8 = b_10;
            throughput_5 = throughput_7;
            wavelength_6 = _S1398;
            width_3 = width_6;
            sky_pdf_0 = _S1445;
        }
        if(_S1331 != int(1))
        {
            width_3 = threshold_2;
            throughput_5 = spectral_weight_0;
            b_8 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1333;
        spread_2 = wavelength_6;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1449 = b_8 == 4294967295U;
    bool _S1450 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1450)
    {
        bool _S1451 = !(&nee_vertex_0)->none;
        float _S1452 = _slang_select(_S1451, sky_pdf_0,0.0f);
        float _S1453 = escapeWeight_0(_S1452, (&ray_2)->unit_direction);
        float3  _S1454 = environment_0((&ray_2)->unit_direction, b_8, (&prev_0)->lobe);
        float3  _S1455 = pathColor(throughput_5 * _S1454, throughput_6, 0.0f);
        if(replay_2)
        {
            bool _S1456 = b_8 == _S1348;
            if(_S1456)
            {
                passes_0 = _S1337 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S1455 * make_float3 (_S1453) / make_float3 (r_8->jac), density_2 / r_8->jac);
            }
            if(_S1347)
            {
                passes_0 = _S1344;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_8 == _S1335;
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
                return Shift_x24init_0(_S1455 * make_float3 (_S1453), 1.0f);
            }
            return _S1333;
        }
        Reservoir candidate_4 = chain_0;
        uint _S1457 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1458 = _S1457 == 1U;
        if(_S1458)
        {
            uint _S1459 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S1460 = _S1459 == b_8;
            float _S1461 = _slang_select(_S1460, 1.0f,_S1453);
            float3  _S1462 = safeDivide(_S1455 * make_float3 (_S1461), _S1332);
            (&candidate_4)->radiance = _S1462;
        }
        else
        {
            bool _S1463 = (&prev_0)->rough;
            if(_S1463)
            {
                uint _S1464 = insertBits_0(_S1362, b_8 + 1U, 5U, 5U);
                uint _S1465 = insertBits_0(_S1464, 3U, 10U, 2U);
                uint _S1466 = insertBits_0(_S1465, (&prev_0)->lobe, 15U, 3U);
                bool _S1467 = (&prev_0)->inside;
                uint _S1468 = _slang_select(_S1467, 1U,0U);
                uint _S1469 = insertBits_0(_S1466, _S1468, 22U, 1U);
                (&candidate_4)->path = _S1469;
                (&candidate_4)->jac = (&prev_0)->pdf;
                (&candidate_4)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S1470 = _S1455 * make_float3 (_S1453);
        Reservoir _S1471 = withEnd(candidate_4, 3U, b_8, _S1470);
        offer(sel_7, _S1471, _S1470 * make_float3 (scale_4) / make_float3 (density_2));
        return _S1333;
    }
    float3  _S1472 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S1472;
    bool _S1473 = (fcptVaryingUsed());
    if(_S1473)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1474 = !replay_2;
        if(_S1474)
        {
            float3  _S1475 = pathColor(throughput_5 * glowed_0, throughput_6, 0.0f);
            float3  _S1476 = _S1475 / make_float3 (density_2);
            float3  _S1477 = sel_7->glow + _S1476;
            sel_7->glow = _S1477;
        }
        float3  _S1478 = throughput_5 * weight_2;
        throughput_5 = _S1478;
    }
    else
    {
        float3  _S1479 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
        float3  _S1480 = throughput_5 * _S1479;
        throughput_5 = _S1480;
    }
    float _S1481 = width_3 + spread_2 * (&hit_4)->distance;
    uint _S1482 = b_8 + 1U;
    b_8 = _S1482;
    layer_0 = 0U;
    width_3 = _S1481;
    passes_0 = false;
    wavelength_6 = 0.0f;
    threshold_2 = 0.0f;
    turned_1 = false;
    is_inside_6 = false;
    spectral_weight_0 = throughput_6;
    float3  chain_throughput_0 = _S1332;
    float3  reconnection_0 = _S1332;
    viewed_0 = _S1449;
    for(;;)
    {
        bool _S1483 = ((&hit_4)->is_point_light) == 1U;
        if(replay_2)
        {
            _S1330 = _S1337 == 1U;
        }
        else
        {
            _S1330 = false;
        }
        bool _S1484;
        if(_S1330)
        {
            _S1484 = b_8 == _S1336;
        }
        else
        {
            _S1484 = false;
        }
        bool _S1485;
        if(_S1484)
        {
            bool _S1486 = ((&hit_4)->instance_index) != (_S1349.instance_index);
            if(_S1486)
            {
                _S1485 = true;
            }
            else
            {
                _S1485 = ((&hit_4)->triangle_index) != (_S1349.triangle_index);
            }
        }
        else
        {
            _S1485 = false;
        }
        if(_S1485)
        {
            return _S1333;
        }
        FKMedium _S1487 = Medium_x24init_0(_S1332, _S1332, 0.0f);
        BSDFMaterial _S1488 = Material_x24init_0(_S1332, _S1332, 0.0f, 0.0f, 0.0f, 0.0f, _S1332, throughput_6, 1.0f, _S1332, _S1332, 0.5f, 0.0f, 0.0f, _S1332, 0.0f, _S1332, 0.0f);
        FKMedium _S1489 = _S1487;
        FKSurface _S1490 = Surface_x24init_0(_S1332, _S1332, 0.0f, &_S1488, false, 0U, 1.0f, false, &_S1489, 4294967295U, _S1332);
        bool _S1491 = !_S1483;
        bool scatter_2;
        bool is_inside_7;
        float geometry_density_2;
        float3  throughput_8;
        FKSurface surface_12;
        if(_S1491)
        {
            uint _S1492 = stream(_S1360, b_8);
            uint _S1493 = arrivalLobe_0(b_8, (&prev_0)->lobe);
            FKSurface _S1494 = (fcptSurfaceAtPath((hit_4), ((&ray_2)->origin), (_S1492), (width_3), (layer_0), (b_8), (_S1493), ((&ray_2)->unit_direction)));
            bool _S1495 = !passes_0;
            FKSurface _S1496 = _S1494;
            FKSurface _S1497 = emitting_0(&_S1496, _S1495);
            uint _S1498 = stream(_S1360, b_8 + 256U);
            Random _S1499 = pcg(_S1498);
            FKSurface _S1500 = _S1497;
            FKSurface _S1501 = uncovered_0(&_S1500, _S1499.value);
            float _S1502 = facingSign(_S1501.material.transmission, _S1501.geometry_n, (&ray_2)->unit_direction);
            bool _S1503 = _S1502 < 0.0f;
            bool _S1504 = (_S1501.material.transmission) > 0.0f;
            if(_S1504)
            {
                bool _S1505 = arrivesBehind_0((&ray_2)->unit_direction, _S1501.geometry_n);
                scatter_2 = _S1505;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1506 = _S1501;
            FKSurface _S1507 = facingRay_0(&_S1506, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S1508 = arrivesBehind_0((&ray_2)->unit_direction, _S1507.geometry_n);
                is_inside_7 = _S1508;
            }
            else
            {
                is_inside_7 = scatter_2;
            }
            if(is_inside_7)
            {
                float _S1509 = (&hit_4)->distance;
                float _S1510 = upsample(_S1507.material.absorption, wavelength_6);
                float3  _S1511 = make_float3 (_S1510);
                bool _S1512 = wavelength_6 > 0.0f;
                float3  _S1513 = _slang_select(_S1512, _S1511,_S1507.material.absorption);
                float3  _S1514 = beerLambert(_S1509, _S1513);
                float3  _S1515 = throughput_5 * _S1514;
                throughput_8 = _S1515;
            }
            else
            {
                throughput_8 = throughput_5;
            }
            bool _S1516 = !_S1507.skip;
            float geometry_density_3 = geometryDensity(_S1507.geometry_n, (&ray_2)->unit_direction, (&hit_4)->distance);
            bool _S1517 = b_8 == _S1482;
            if(_S1517)
            {
                float _S1518 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S1518;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            float _S1519 = geometry_density_2;
            scatter_2 = _S1516;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S1519;
            surface_12 = _S1507;
            turned_1 = _S1503;
        }
        else
        {
            scatter_2 = false;
            geometry_density_2 = 0.0f;
            surface_12 = _S1490;
            throughput_8 = throughput_5;
            is_inside_7 = is_inside_6;
        }
        bool _S1520 = withinFootprint(scatter_2, (&prev_0)->rough, (&prev_0)->pdf, geometry_density_2, threshold_2);
        FKSurface _S1521 = surface_12;
        float _S1522 = dot_0(surface_12.smooth_n, - (&ray_2)->unit_direction);
        bool _S1523 = (fcptDispersionUsed());
        bool _S1524;
        if(_S1523)
        {
            _S1524 = wavelength_6 == 0.0f;
        }
        else
        {
            _S1524 = false;
        }
        bool _S1525;
        if(_S1524)
        {
            _S1525 = scatter_2;
        }
        else
        {
            _S1525 = false;
        }
        bool _S1526;
        if(_S1525)
        {
            bool _S1527 = dispersive(surface_12.material);
            _S1526 = _S1527;
        }
        else
        {
            _S1526 = false;
        }
        float3  throughput_9;
        if(_S1526)
        {
            uint _S1528 = stream(_S1360, 512U);
            Random _S1529 = pcg(_S1528);
            uint _S1530 = extractBits_0(_S1334, 25U, 7U);
            float _S1531 = (float(_S1530) + _S1529.value) / 128.0f;
            uint _S1532 = extractBits_0(_S1334, 24U, 1U);
            bool _S1533 = _S1532 == 1U;
            float _S1534 = _slang_select(_S1533, _S1531,_S1529.value);
            float2  _S1535 = sampleWavelength(_S1534);
            float wavelength_7 = _S1535.x;
            float3  _S1536 = wavelengthWeights(wavelength_7);
            float3  _S1537 = _S1536 / make_float3 (_S1535.y);
            float _S1538 = upsample(throughput_8, wavelength_7);
            float3  _S1539 = make_float3 (_S1538);
            float _S1540 = upsample(scatter_in_0, wavelength_7);
            float3  _S1541 = make_float3 (_S1540);
            scatter_in_0 = _S1541;
            float _S1542 = upsample(extinction_in_0, wavelength_7);
            float3  _S1543 = make_float3 (_S1542);
            extinction_in_0 = _S1543;
            wavelength_6 = wavelength_7;
            throughput_9 = _S1539;
            spectral_weight_0 = _S1537;
        }
        else
        {
            throughput_9 = throughput_8;
        }
        bool _S1544 = wavelength_6 > 0.0f;
        BSDFMaterial _S1545;
        if(_S1544)
        {
            BSDFMaterial _S1546 = atWavelength(surface_12.material, wavelength_6);
            _S1545 = _S1546;
        }
        else
        {
            _S1545 = surface_12.material;
        }
        float2  _S1547 = wavelengthEta(_S1545, _S1522, wavelength_6);
        bool _S1548;
        if(scatter_2)
        {
            bool _S1549 = neeDecision(_S1545, _S1522, _S1547.x, _S1547.y);
            _S1548 = _S1549;
        }
        else
        {
            _S1548 = false;
        }
        bool _S1550;
        if(passes_0)
        {
            _S1550 = true;
        }
        else
        {
            _S1550 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1550)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1548;
        }
        bool _S1551 = (fcptHairUsed());
        bool _S1552;
        if(_S1551)
        {
            float3  _S1553 = surface_12.hair;
            _S1552 = (dot_0(_S1553, _S1553)) > 0.0f;
        }
        else
        {
            _S1552 = false;
        }
        bool _S1554;
        if(_S1552)
        {
            _S1554 = true;
        }
        else
        {
            BSDFMaterial _S1555 = _S1545;
            bool _S1556 = isTranslucent_0(&_S1555);
            _S1554 = _S1556;
        }
        bool _S1557;
        if(_S1554)
        {
            _S1557 = true;
        }
        else
        {
            bool _S1558 = (_S1545.transmission) > 0.0f;
            if(_S1558)
            {
                uint _S1559 = (fcptLayers((hit_4)));
                _S1557 = _S1559 == 1U;
            }
            else
            {
                _S1557 = false;
            }
        }
        BSDFMaterial _S1560 = _S1545;
        float3  emission_0;
        if(_S1483)
        {
            float3  _S1561 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1561;
        }
        else
        {
            emission_0 = _S1560.emissive;
        }
        float _S1562 = rgb_to_greyscale(emission_0);
        bool _S1563 = _S1562 > 0.0f;
        float3  emission_1;
        if(_S1563)
        {
            NEEVertex _S1564 = nee_vertex_0;
            FKHit _S1565 = hit_4;
            float _S1566 = emissionWeight_0(&_S1564, &_S1565, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1566);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1567;
        if(replay_2)
        {
            _S1567 = _S1337 == 1U;
        }
        else
        {
            _S1567 = false;
        }
        bool _S1568;
        if(_S1567)
        {
            _S1568 = b_8 > _S1336;
        }
        else
        {
            _S1568 = false;
        }
        bool _S1569;
        if(_S1568)
        {
            _S1569 = b_8 == _S1335;
        }
        else
        {
            _S1569 = false;
        }
        bool _S1570;
        if(_S1569)
        {
            bool _S1571 = _S1338 == 1U;
            if(_S1571)
            {
                _S1570 = true;
            }
            else
            {
                _S1570 = _S1338 == 2U;
            }
        }
        else
        {
            _S1570 = false;
        }
        if(_S1570)
        {
            bool _S1572 = _S1483 != (_S1338 == 2U);
            if(_S1572)
            {
                return _S1333;
            }
            float3  _S1573 = pathColor(throughput_9 * emission_1, spectral_weight_0, wavelength_6);
            return Shift_x24init_0(_S1573 / make_float3 (r_8->jac), density_2 / r_8->jac);
        }
        uint _S1574 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1575 = _S1574 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1576 = insertBits_0(_S1362, b_8, 5U, 5U);
        uint _S1577 = insertBits_0(_S1576, 1U, 10U, 2U);
        uint _S1578 = insertBits_0(_S1577, (&prev_0)->lobe, 15U, 3U);
        bool _S1579 = (&prev_0)->inside;
        uint _S1580 = _slang_select(_S1579, 1U,0U);
        uint _S1581 = insertBits_0(_S1578, _S1580, 22U, 1U);
        (&here_0)->path = _S1581;
        uint _S1582 = (&here_0)->path;
        uint _S1583 = _slang_select(_S1544, 1U,0U);
        uint _S1584 = insertBits_0(_S1582, _S1583, 23U, 1U);
        (&here_0)->path = _S1584;
        float _S1585 = (&prev_0)->pdf * geometry_density_2;
        (&here_0)->jac = _S1585;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1586;
        if(replay_2)
        {
            _S1586 = _S1337 == 1U;
        }
        else
        {
            _S1586 = false;
        }
        bool _S1587;
        if(_S1586)
        {
            _S1587 = b_8 == _S1336;
        }
        else
        {
            _S1587 = false;
        }
        bool _S1588 = b_8 == _S1348;
        bool _S1589;
        if(_S1588)
        {
            bool _S1590 = !scatter_2;
            if(_S1590)
            {
                _S1589 = true;
            }
            else
            {
                bool _S1591 = _S1337 != 1U;
                if(_S1591)
                {
                    _S1589 = _S1337 != 3U;
                }
                else
                {
                    _S1589 = false;
                }
            }
        }
        else
        {
            _S1589 = false;
        }
        bool _S1592;
        if(_S1589)
        {
            _S1592 = _S1337 == 2U;
        }
        else
        {
            _S1592 = false;
        }
        bool _S1593;
        if(_S1592)
        {
            _S1593 = !_S1520;
        }
        else
        {
            _S1593 = false;
        }
        bool _S1594;
        if(_S1593)
        {
            _S1594 = _S1338 != 4U;
        }
        else
        {
            _S1594 = false;
        }
        bool _S1595 = _S1336 == _S1335;
        bool _S1596;
        if(_S1595)
        {
            _S1596 = _S1338 == 0U;
        }
        else
        {
            _S1596 = false;
        }
        bool _S1597;
        if(_S1596)
        {
            _S1597 = ((&hit_4)->instance_index) == (_S1349.instance_index);
        }
        else
        {
            _S1597 = false;
        }
        bool _S1598;
        if(_S1597)
        {
            _S1598 = ((&hit_4)->triangle_index) == (_S1349.triangle_index);
        }
        else
        {
            _S1598 = false;
        }
        bool _S1599;
        if(_S1598)
        {
            _S1599 = _S1520;
        }
        else
        {
            _S1599 = false;
        }
        bool _S1600 = _slang_select(_S1587, _S1599,_S1594);
        bool _S1601;
        if(nee_0)
        {
            _S1601 = _slang_select(replay_2, _S1600,scatter_2);
        }
        else
        {
            _S1601 = false;
        }
        TreeSample _S1602 = TreeSample_x24init_0(_S1332, _S1332, 0.0f, 0U);
        uint2  _S1603 = make_uint2 (0U);
        float2  _S1604 = make_float2 (0.0f);
        FKHit _S1605 = Hit_x24init_0(_S1604, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1606 = _S1605;
        ShadowContext _S1607 = ShadowContext_x24init_0(_S1332, _S1332, _S1603, _S1332, 0U, 0U, false, 0.0f, 0.0f, &_S1606, false);
        ShadowContext context_5;
        if(nee_0)
        {
            uint _S1608 = arrivalLobe_0(b_8, (&prev_0)->lobe);
            FKMedium _S1609 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1610 = surface_12;
            FKHit _S1611 = hit_4;
            FKMedium _S1612 = _S1609;
            ShadowContext _S1613 = shadowContext_0(&_S1610, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_8, _S1608, (&hit_4)->distance, width_3, &_S1611, _S1552, &_S1612);
            context_5 = _S1613;
        }
        else
        {
            context_5 = _S1607;
        }
        float3  throughput_10;
        float3  lit_0;
        if(_S1601)
        {
            float3  _S1614 = (&ray_2)->origin;
            if(_S1552)
            {
                throughput_10 = _S1332;
            }
            else
            {
                throughput_10 = _S1521.smooth_n;
            }
            FKSurface _S1615 = surface_12;
            uint _S1616 = stream(_S1360, b_8 + 64U);
            ShadowContext _S1617 = context_5;
            TreeSample _S1618 = sampleLightTree_0(_S1614, throughput_10, surface_12.geometry_n, surface_12.geometry_offset, _S1557, _S1616, &_S1617);
            bool _S1619 = any_1((_S1618.radiance) != _S1332);
            if(_S1619)
            {
                if(_S1552)
                {
                    uint _S1620 = (fcptMaxBounces());
                    bool _S1621 = b_8 < _S1620;
                    FKSurface _S1622 = surface_12;
                    TreeSample _S1623 = _S1618;
                    float3  _S1624 = hairLight_0(&_S1622, (&ray_2)->unit_direction, &_S1623, _S1621);
                    lit_0 = _S1624;
                }
                else
                {
                    float _S1625 = _S1547.x;
                    float _S1626 = _S1547.y;
                    uint _S1627 = (fcptMaxBounces());
                    bool _S1628 = b_8 < _S1627;
                    TreeSample _S1629 = _S1618;
                    BSDFMaterial _S1630 = _S1545;
                    float3  _S1631 = lightBSDF_0((&ray_2)->unit_direction, &_S1629, _S1521.smooth_n, _S1615.geometry_n, &_S1630, _S1625, _S1626, _S1628, surface_12.random_state);
                    lit_0 = _S1631;
                }
            }
            else
            {
                lit_0 = _S1332;
            }
            light_3 = _S1618;
        }
        else
        {
            light_3 = _S1602;
            lit_0 = _S1332;
        }
        bool viewed_1;
        bool refracted_5;
        bool wrong_side_0;
        bool _S1632;
        bool _S1633;
        float density_4;
        if(_S1587)
        {
            bool _S1634 = !_S1520;
            if(_S1634)
            {
                return _S1333;
            }
            uint _S1635 = extractBits_0(_S1334, 23U, 1U);
            bool _S1636 = _S1544 != (_S1635 == 1U);
            if(_S1636)
            {
                return _S1333;
            }
            float3  throughput_11 = throughput_9 * make_float3 (geometry_density_2);
            float density_5 = density_2 * geometry_density_2;
            if(_S1595)
            {
                viewed_1 = _S1338 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                float3  _S1637 = pathColor(throughput_11 * emission_1, spectral_weight_0, wavelength_6);
                return Shift_x24init_0(_S1637 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1595)
            {
                refracted_5 = _S1338 == 0U;
            }
            else
            {
                refracted_5 = false;
            }
            if(refracted_5)
            {
                bool _S1638 = !nee_0;
                if(_S1638)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1639 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1639 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1333;
                }
                float3  _S1640 = pathColor(throughput_11 * lit_0, spectral_weight_0, wavelength_6);
                return Shift_x24init_0(_S1640 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1595)
            {
                wrong_side_0 = _S1338 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1641 = !nee_0;
                if(_S1641)
                {
                    return _S1333;
                }
                bool _S1642 = (fcptWorldReadsPath());
                if(_S1642)
                {
                    float _S1643 = environmentPdf_0(r_8->dir);
                    uint _S1644 = b_8 + 1U;
                    FKSurface _S1645 = surface_12;
                    float3  _S1646 = skyColor_0((&ray_2)->unit_direction, r_8->dir, &_S1645, _S1547, is_inside_7, _S1643, surface_12.random_state, _S1644);
                    float3  _S1647 = pathColor(throughput_11 * (_S1646 * r_8->radiance), spectral_weight_0, wavelength_6);
                    return Shift_x24init_0(_S1647 / make_float3 (r_8->jac), density_5 / r_8->jac);
                }
                float _S1648 = environmentPdf_0(r_8->dir);
                float3  _S1649 = skyBSDF((&ray_2)->unit_direction, r_8->dir, surface_12, _S1547, is_inside_7, _S1648, surface_12.random_state);
                float3  _S1650 = pathColor(throughput_11 * _S1649 * r_8->radiance, spectral_weight_0, wavelength_6);
                return Shift_x24init_0(_S1650 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            uint _S1651 = extractBits_0(_S1334, 21U, 1U);
            bool _S1652 = nee_0 != (_S1651 == 1U);
            if(_S1652)
            {
                return _S1333;
            }
            throughput_10 = throughput_11;
            density_4 = density_5;
        }
        else
        {
            if(replay_2)
            {
                viewed_1 = _S1588;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1653 = !scatter_2;
                if(_S1653)
                {
                    refracted_5 = true;
                }
                else
                {
                    bool _S1654 = _S1337 != 1U;
                    if(_S1654)
                    {
                        refracted_5 = _S1337 != 3U;
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
                bool _S1655 = _S1337 == 2U;
                if(_S1655)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1520;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1338 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1552)
                    {
                        return _S1333;
                    }
                    uint _S1656 = stream(_S1360, b_8 + 448U);
                    FKRay _S1657 = ray_2;
                    FKSurface _S1658 = surface_12;
                    ShadowContext _S1659 = context_5;
                    SkySample _S1660 = sampleSky_0(&_S1657, &_S1658, _S1547, is_inside_7, _S1656, surface_12.random_state, &_S1659);
                    float3  _S1661 = pathColor(throughput_9 * _S1660.color, spectral_weight_0, wavelength_6);
                    return Shift_x24init_0(_S1661, 1.0f);
                }
                if(_S1655)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1520;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1662 = rgb_to_greyscale(light_3.radiance);
                    bool _S1663 = !(_S1662 > 0.0f);
                    if(_S1663)
                    {
                        return _S1333;
                    }
                    float3  _S1664 = pathColor(throughput_9 * lit_0, spectral_weight_0, wavelength_6);
                    return Shift_x24init_0(_S1664, 1.0f);
                }
                if(_S1347)
                {
                    passes_0 = _S1338 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1483;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float3  _S1665 = pathColor(throughput_9 * emission_1, spectral_weight_0, wavelength_6);
                    return Shift_x24init_0(_S1665, 1.0f);
                }
                if(_S1347)
                {
                    passes_0 = _S1338 == 1U;
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
                    passes_0 = !_S1520;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float3  _S1666 = pathColor(throughput_9 * emission_1, spectral_weight_0, wavelength_6);
                    return Shift_x24init_0(_S1666, 1.0f);
                }
                return _S1333;
            }
            else
            {
                bool _S1667 = !replay_2;
                if(_S1667)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1668 = b_8 > 0U;
                    if(_S1668)
                    {
                        Reservoir candidate_5 = chain_0;
                        if(_S1575)
                        {
                            float3  _S1669 = safeDivide(throughput_9 * emission_1, chain_throughput_0);
                            (&candidate_5)->radiance = _S1669;
                        }
                        else
                        {
                            if(_S1520)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1670 = pathColor(throughput_9 * emission_1, spectral_weight_0, wavelength_6);
                        Reservoir _S1671 = withEnd(candidate_5, 1U, b_8, _S1670);
                        offer(sel_7, _S1671, _S1670 * make_float3 (scale_4) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1672 = pathColor(throughput_9 * emission_1, spectral_weight_0, wavelength_6);
                        float3  _S1673 = sel_7->glow + _S1672;
                        sel_7->glow = _S1673;
                    }
                    if(nee_0)
                    {
                        float3  _S1674 = pathColor(throughput_9 * lit_0, spectral_weight_0, wavelength_6);
                        Reservoir candidate_6 = chain_0;
                        if(_S1575)
                        {
                            float3  _S1675 = safeDivide(_S1674, chain_throughput_0);
                            (&candidate_6)->radiance = _S1675;
                        }
                        else
                        {
                            if(_S1520)
                            {
                                candidate_6 = here_0;
                                uint _S1676 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1676;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1677 = insertBits_0(_S1362, b_8 + 1U, 5U, 5U);
                                uint _S1678 = insertBits_0(_S1677, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1678;
                            }
                        }
                        Reservoir _S1679 = withEnd(candidate_6, 0U, b_8, _S1674);
                        offer(sel_7, _S1679, _S1674 * make_float3 (scale_4) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1552)
                        {
                            _S1632 = false;
                        }
                        else
                        {
                            bool _S1680 = environmentMapped_0();
                            _S1632 = _S1680;
                        }
                    }
                    else
                    {
                        _S1632 = false;
                    }
                    if(_S1632)
                    {
                        uint _S1681 = (fcptMaxBounces());
                        _S1633 = b_8 < _S1681;
                    }
                    else
                    {
                        _S1633 = false;
                    }
                    if(_S1633)
                    {
                        uint _S1682 = stream(_S1360, b_8 + 448U);
                        FKRay _S1683 = ray_2;
                        FKSurface _S1684 = surface_12;
                        ShadowContext _S1685 = context_5;
                        SkySample _S1686 = sampleSky_0(&_S1683, &_S1684, _S1547, is_inside_7, _S1682, surface_12.random_state, &_S1685);
                        float3  _S1687 = pathColor(throughput_9 * _S1686.color, spectral_weight_0, wavelength_6);
                        Reservoir candidate_7 = chain_0;
                        if(_S1575)
                        {
                            float3  _S1688 = safeDivide(_S1687, chain_throughput_0);
                            (&candidate_7)->radiance = _S1688;
                        }
                        else
                        {
                            if(_S1520)
                            {
                                candidate_7 = here_0;
                                uint _S1689 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1689;
                                (&candidate_7)->dir = _S1686.dir;
                                (&candidate_7)->radiance = _S1686.radiance;
                            }
                            else
                            {
                                uint _S1690 = insertBits_0(_S1362, b_8 + 1U, 5U, 5U);
                                uint _S1691 = insertBits_0(_S1690, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1691;
                            }
                        }
                        Reservoir _S1692 = withEnd(candidate_7, 4U, b_8, _S1687);
                        offer(sel_7, _S1692, _S1687 * make_float3 (scale_4) / make_float3 (density_2));
                    }
                }
            }
            throughput_10 = throughput_9;
            density_4 = density_2;
        }
        bool _S1693;
        bool _S1694;
        bool _S1695;
        bool straight_0;
        bool _S1696;
        bool _S1697;
        bool _S1698;
        bool _S1699;
        bool _S1700;
        bool _S1701;
        bool _S1702;
        bool _S1703;
        bool _S1704;
        bool _S1705;
        bool _S1706;
        bool _S1707;
        float density_6;
        float sky_pdf_2;
        float spread_5;
        uint b_11;
        float3  throughput_12;
        float3  throughput_13;
        float3  throughput_14;
        if(scatter_2)
        {
            MaterialTerms _S1708 = MaterialTerms_x24init_0(0.0f, 0.0f, 0.0f, 0.0f, 0.0f, _S1332, 0.0f, 0.0f, 0.0f, false, 0.0f);
            AnisotropicFrame _S1709 = AnisotropicFrame_x24init_0(_S1332, _S1604);
            ViewTerms _S1710 = ViewTerms_x24init_0(_S1332, _S1332, &_S1709, _S1332, 0.0f, _S1332, _S1332, _S1332, 0.0f, _S1332);
            bool _S1711 = !_S1552;
            MaterialTerms terms_7;
            ViewTerms view_terms_7;
            if(_S1711)
            {
                MaterialTerms terms_8 = precomputeMaterial(_S1545, _S1547.x, _S1547.y);
                ViewTerms _S1712 = precomputeView((&ray_2)->unit_direction, _S1521.smooth_n, _S1545, terms_8);
                terms_7 = terms_8;
                view_terms_7 = _S1712;
            }
            else
            {
                terms_7 = _S1708;
                view_terms_7 = _S1710;
            }
            if(replay_2)
            {
                viewed_1 = _S1588;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1713 = extractBits_0(_S1334, 15U, 3U);
            uint _S1714 = extractBits_0(_S1334, 18U, 3U);
            uint _S1715 = _slang_select(_S1587, _S1714,_S1713);
            float3  _S1716 = r_8->dir;
            bool refracted_6 = _S1715 == 1U;
            SampleBSDF _S1717 = SampleBSDF_x24init_0(_S1332, _S1332, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1717;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1718 = extractBits_0(_S1334, 22U, 1U);
                bool _S1719 = is_inside_7 != (_S1718 == 1U);
                if(_S1719)
                {
                    return _S1333;
                }
                bool _S1720 = _S1337 == 1U;
                if(_S1720)
                {
                    float3  _S1721 = (fcptHitPosition((_S1349)));
                    throughput_12 = _S1721;
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
                    BSDFMaterial _S1722 = _S1545;
                    bool _S1723 = isTranslucent_0(&_S1722);
                    if(_S1723)
                    {
                        refracted_5 = _S1715 == 0U;
                    }
                    else
                    {
                        refracted_5 = false;
                    }
                    if(refracted_5)
                    {
                        float3  _S1724 = throughput_12 - (&ray_2)->origin;
                        float3  _S1725 = _slang_select(_S1720, _S1724,_S1716);
                        wrong_side_0 = (dot_0(_S1521.smooth_n, _S1725) * _S1522) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_5 = wrong_side_0;
                }
                if(_S1720)
                {
                    float3  _S1726 = (&ray_2)->origin;
                    FKSurface _S1727 = surface_12;
                    float3  _S1728 = - _S1521.smooth_n;
                    bool _S1729 = is_inside_7 != refracted_5;
                    float3  _S1730 = _slang_select(_S1729, _S1728,_S1521.smooth_n);
                    float3  _S1731 = throughput_12 - (_S1726 + make_float3 (_S1727.geometry_offset) * _S1730);
                    float3  _S1732 = ((((_S1731)) * make_float3(rnorm3df(((_S1731)).x, ((_S1731)).y, ((_S1731)).z))));
                    reconnection_1 = _S1732;
                }
                else
                {
                    reconnection_1 = _S1716;
                }
                if(_S1552)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1733 = wrongSide_0(is_inside_7, refracted_5, reconnection_1, surface_12.geometry_n);
                    wrong_side_0 = _S1733;
                }
                if(wrong_side_0)
                {
                    return _S1333;
                }
                float3  _S1734 = throughput_12;
                throughput_12 = reconnection_1;
                b_11 = _S1715;
                wrong_side_0 = false;
                reconnection_1 = _S1734;
            }
            else
            {
                bool _S1735 = !_S1587;
                if(_S1735)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1736;
                    if(_S1552)
                    {
                        SampleBSDF _S1737 = (fcptSampleHair((surface_12.hair), (_S1545.albedo), (_S1545.specular_tint), ((&ray_2)->unit_direction), (surface_12.random_state)));
                        _S1736 = _S1737;
                    }
                    else
                    {
                        SampleBSDF _S1738 = sampleBSDF((&ray_2)->unit_direction, _S1521.smooth_n, _S1545, _S1547.x, _S1547.y, surface_12.random_state, _S1604, terms_7, view_terms_7);
                        _S1736 = _S1738;
                    }
                    bsdf_sampled_0 = _S1736;
                    if(_S1552)
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
                            return _S1333;
                        }
                        break;
                    }
                    if(_S1552)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1739 = wrongSide_0(is_inside_7, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_12.geometry_n);
                        wrong_side_0 = _S1739;
                    }
                    if(wrong_side_0)
                    {
                        _S1632 = (_S1545.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1632 = false;
                    }
                    if(_S1632)
                    {
                        float _S1740 = _S1547.x;
                        float _S1741 = _S1547.y;
                        ViewTerms _S1742 = precomputeView((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S1545, terms_7);
                        SampleBSDF _S1743 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S1545, _S1740, _S1741, (&bsdf_sampled_0)->random_state, _S1604, terms_7, _S1742);
                        (&bsdf_sampled_0)->unit_direction = _S1743.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1743.refracted;
                        (&bsdf_sampled_0)->throughput = _S1743.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1744 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n)) * surface_12.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1744;
                        }
                    }
                    uint _S1745 = (&bsdf_sampled_0)->lobe;
                    float3  _S1746 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1747 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1748 = (&bsdf_sampled_0)->pdf;
                    float _S1749 = _slang_select(wrong_side_0, 0.0f,_S1748);
                    (&lobe_5)->pdf = _S1749;
                    throughput_12 = _S1746;
                    b_11 = _S1745;
                    refracted_5 = _S1747;
                }
                else
                {
                    throughput_12 = _S1716;
                    b_11 = _S1715;
                    wrong_side_0 = false;
                    refracted_5 = refracted_6;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1632 = true;
            }
            else
            {
                _S1632 = _S1587;
            }
            float3  chain_throughput_1;
            if(_S1632)
            {
                if(_S1552)
                {
                    SampleBSDF _S1750 = (fcptConnectHair((surface_12.hair), (_S1545.albedo), (_S1545.specular_tint), ((&ray_2)->unit_direction), (throughput_12)));
                    lobe_5 = _S1750;
                }
                else
                {
                    float3  _S1751 = (&ray_2)->unit_direction;
                    float _S1752 = sign_0(_S1522);
                    float3  _S1753 = _S1521.smooth_n * make_float3 (_S1752);
                    float _S1754 = dot_0(_S1753, throughput_12);
                    float _S1755 = _S1545.roughness;
                    float _S1756 = _S1755 * _S1755;
                    float3  _S1757 = reflectedHalf(_S1751, throughput_12);
                    bool _S1758 = b_11 == 1U;
                    if(_S1758)
                    {
                        float3  _S1759 = refractedHalf(_S1751, throughput_12, _S1521.smooth_n, _S1547.x, _S1547.y);
                        throughput_13 = _S1759;
                    }
                    else
                    {
                        throughput_13 = _S1757;
                    }
                    bool _S1760 = b_11 == 0U;
                    if(_S1760)
                    {
                        _S1633 = true;
                    }
                    else
                    {
                        _S1633 = b_11 == 6U;
                    }
                    if(_S1633)
                    {
                        float3  _S1761 = sampledHalf(_S1751, _S1521.smooth_n, _S1545, surface_12.random_state, view_terms_7);
                        throughput_14 = _S1761;
                    }
                    else
                    {
                        throughput_14 = throughput_13;
                    }
                    float _S1762 = _S1547.x;
                    float _S1763 = _S1547.y;
                    HalfTerms _S1764 = precomputeHalf(_S1751, throughput_14, _S1545, _S1762, _S1763, terms_7, view_terms_7);
                    switch(b_11)
                    {
                    case 0U:
                        {
                            float _S1765 = diffusePDF(_S1754, 0.0f, (F32_abs((_S1522))), _S1756, _S1764, _S1762, _S1763);
                            float3  _S1766 = diffuseBSDF(throughput_12, _S1753, _S1756, _S1545, _S1764);
                            density_6 = _S1765;
                            chain_throughput_1 = _S1766;
                            break;
                        }
                    case 1U:
                        {
                            float _S1767 = refractPDF(_S1754, dot_0(throughput_12, throughput_14), (F32_abs((_S1522))), _S1756, _S1764, _S1762, _S1763);
                            float3  _S1768 = refractBSDF(throughput_12, _S1753, _S1756, _S1545, _S1764);
                            density_6 = _S1767;
                            chain_throughput_1 = _S1768;
                            break;
                        }
                    case 4U:
                        {
                            float _S1769 = sheenVelvetPDF(_S1754, 0.0f, (F32_abs((_S1522))), _S1756, _S1764, _S1762, _S1763);
                            float3  _S1770 = sheenVelvetBSDF(throughput_12, _S1753, _S1756, _S1545, _S1764);
                            density_6 = _S1769;
                            chain_throughput_1 = _S1770;
                            break;
                        }
                    case 6U:
                        {
                            float _S1771 = toonPDF(_S1754, dot_0(throughput_12, _S1764.toon_axis), (F32_abs((_S1522))), _S1756, _S1764, _S1762, _S1763);
                            float3  _S1772 = toonBSDF(throughput_12, _S1753, _S1756, _S1545, _S1764);
                            density_6 = _S1771;
                            chain_throughput_1 = _S1772;
                            break;
                        }
                    default:
                        {
                            float _S1773 = reflectPDF(_S1754, 0.0f, (F32_abs((_S1522))), _S1756, _S1764, _S1762, _S1763);
                            float3  _S1774 = reflectBSDF(throughput_12, _S1753, _S1756, _S1545, _S1764);
                            density_6 = _S1773;
                            chain_throughput_1 = _S1774;
                            break;
                        }
                    }
                    bool _S1775 = density_6 > 0.0f;
                    if(_S1775)
                    {
                        SampleBSDF _S1776 = SampleBSDF_x24init_0(throughput_12, chain_throughput_1, surface_12.random_state, _S1758, b_11, density_6);
                        lobe_5 = _S1776;
                    }
                }
            }
            bool _S1777 = b_11 == 0U;
            if(_S1777)
            {
                _S1633 = true;
            }
            else
            {
                _S1633 = b_11 == 4U;
            }
            if(_S1633)
            {
                _S1693 = true;
            }
            else
            {
                _S1693 = b_11 == 6U;
            }
            if(_S1552)
            {
                _S1694 = false;
            }
            else
            {
                bool _S1778 = !_S1693;
                if(_S1778)
                {
                    bool _S1779 = (_S1545.roughness) == 0.0f;
                    if(_S1779)
                    {
                        _S1694 = true;
                    }
                    else
                    {
                        bool _S1780 = b_11 == 1U;
                        if(_S1780)
                        {
                            _S1694 = (_S1547.x) == (_S1547.y);
                        }
                        else
                        {
                            _S1694 = false;
                        }
                    }
                }
                else
                {
                    _S1694 = false;
                }
            }
            if(_S1711)
            {
                _S1695 = b_11 == 1U;
            }
            else
            {
                _S1695 = false;
            }
            if(_S1695)
            {
                straight_0 = (_S1545.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1696 = _S1711;
            }
            else
            {
                _S1696 = false;
            }
            if(_S1696)
            {
                _S1697 = b_11 == 1U;
            }
            else
            {
                _S1697 = false;
            }
            if(_S1697)
            {
                _S1698 = (_S1547.x) == (_S1547.y);
            }
            else
            {
                _S1698 = false;
            }
            BSDFMaterial _S1781 = _S1545;
            bool _S1782 = isTranslucent_0(&_S1781);
            if(_S1782)
            {
                _S1699 = _S1777;
            }
            else
            {
                _S1699 = false;
            }
            if(_S1699)
            {
                _S1700 = (dot_0(throughput_12, surface_12.geometry_n)) < 0.0f;
            }
            else
            {
                _S1700 = false;
            }
            if(nee_0)
            {
                _S1701 = !_S1694;
            }
            else
            {
                _S1701 = false;
            }
            if(_S1701)
            {
                _S1702 = !wrong_side_0;
            }
            else
            {
                _S1702 = false;
            }
            if(_S1702)
            {
                float _S1783 = (&lobe_5)->pdf;
                float3  _S1784 = (&ray_2)->origin;
                float3  _S1785 = _slang_select(_S1557, _S1332,_S1521.smooth_n);
                float3  _S1786 = (&ray_2)->origin;
                FKSurface _S1787 = surface_12;
                float3  _S1788 = - _S1521.smooth_n;
                float3  _S1789 = _slang_select(_S1700, _S1788,_S1521.smooth_n);
                NEEVertex _S1790 = NEEVertex_x24init_0(false, _S1783, _S1784, _S1785, _S1786 + make_float3 (_S1787.geometry_offset) * _S1789);
                nee_vertex_0 = _S1790;
            }
            else
            {
                if(_S1552)
                {
                    _S1703 = true;
                }
                else
                {
                    bool _S1791 = b_11 != 1U;
                    if(_S1791)
                    {
                        _S1703 = true;
                    }
                    else
                    {
                        _S1703 = (_S1547.x) != (_S1547.y);
                    }
                }
                if(_S1703)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1792 = withinInverseFootprint((&lobe_5)->pdf, _S1693, (&prev_0)->cos, (&hit_4)->distance, threshold_2);
            bool _S1793 = roughLobe((&lobe_5)->pdf, _S1693, _S1545.roughness);
            if(_S1587)
            {
                bool _S1794 = !_S1792;
                if(_S1794)
                {
                    return _S1333;
                }
                bool _S1795 = _S1338 != 1U;
                if(_S1795)
                {
                    _S1703 = _S1338 != 2U;
                }
                else
                {
                    _S1703 = false;
                }
                if(_S1703)
                {
                    float _S1796 = (&lobe_5)->pdf;
                    float _S1797 = _slang_select(nee_0, _S1796,0.0f);
                    float _S1798 = escapeWeight_0(_S1797, _S1716);
                    if(_S1595)
                    {
                        passes_0 = _S1344;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1799 = _slang_select(passes_0, _S1798,1.0f);
                    return Shift_x24init_0(throughput_10 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_8->radiance * make_float3 (_S1799) / make_float3 (r_8->jac), density_4 * (&lobe_5)->pdf / r_8->jac);
                }
                float3  _S1800 = throughput_10 * make_float3 ((&lobe_5)->pdf);
                float _S1801 = density_4 * (&lobe_5)->pdf;
                throughput_13 = _S1800;
                density_6 = _S1801;
            }
            else
            {
                throughput_13 = throughput_10;
                density_6 = density_4;
            }
            uint _S1802 = (fcptLayers((hit_4)));
            bool _S1803 = b_11 == 1U;
            bool _S1804 = passesLayer_0(_S1802, _S1803, passes_0);
            if(viewed_1)
            {
                _S1703 = _S1804;
            }
            else
            {
                _S1703 = false;
            }
            if(_S1703)
            {
                return _S1333;
            }
            if(replay_2)
            {
                _S1704 = b_8 <= _S1348;
            }
            else
            {
                _S1704 = false;
            }
            if(_S1704)
            {
                _S1705 = _S1520;
            }
            else
            {
                _S1705 = false;
            }
            if(_S1705)
            {
                _S1706 = _S1792;
            }
            else
            {
                _S1706 = false;
            }
            if(_S1706)
            {
                _S1707 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1707 = !_S1793;
                }
                else
                {
                    _S1707 = false;
                }
            }
            if(_S1707)
            {
                return _S1333;
            }
            if(viewed_1)
            {
                float3  _S1805 = throughput_13 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1806 = (&lobe_5)->pdf;
                throughput_14 = _S1805;
                sky_pdf_2 = _S1806;
            }
            else
            {
                float3  _S1807 = throughput_13 * max_0((&lobe_5)->throughput, _S1332);
                throughput_14 = _S1807;
                sky_pdf_2 = density_6;
            }
            bool _S1808 = !replay_2;
            bool _S1809;
            if(_S1808)
            {
                _S1809 = !_S1575;
            }
            else
            {
                _S1809 = false;
            }
            bool _S1810;
            if(_S1809)
            {
                _S1810 = _S1520;
            }
            else
            {
                _S1810 = false;
            }
            bool _S1811;
            if(_S1810)
            {
                _S1811 = _S1792;
            }
            else
            {
                _S1811 = false;
            }
            if(_S1811)
            {
                chain_0 = here_0;
                uint _S1812 = insertBits_0((&chain_0)->path, b_11, 18U, 3U);
                uint _S1813 = _slang_select(nee_0, 1U,0U);
                uint _S1814 = insertBits_0(_S1812, _S1813, 21U, 1U);
                (&chain_0)->path = _S1814;
                float _S1815 = (&chain_0)->jac * (&lobe_5)->pdf;
                (&chain_0)->jac = _S1815;
                (&chain_0)->dir = throughput_12;
                chain_throughput_1 = throughput_14;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1816 = surface_12;
            Vertex _S1817 = Vertex_x24init_0(_S1793, b_11, (&lobe_5)->pdf, (F32_abs((dot_0(surface_12.geometry_n, throughput_12)))), is_inside_7);
            prev_0 = _S1817;
            float _S1818 = (&lobe_5)->pdf;
            bool _S1819;
            if(_S1803)
            {
                _S1819 = (_S1547.x) == (_S1547.y);
            }
            else
            {
                _S1819 = false;
            }
            float sky_pdf_3 = _slang_select(_S1819, sky_pdf_0,_S1818);
            float _S1820 = _slang_select(_S1552, 0.0f,sky_pdf_3);
            float _S1821 = widened_0(spread_2, (&lobe_5)->pdf, _S1694);
            bool _S1822;
            if(refracted_5)
            {
                _S1822 = !_S1700;
            }
            else
            {
                _S1822 = false;
            }
            bool is_inside_8;
            if(_S1822)
            {
                bool _S1823 = !is_inside_7;
                is_inside_8 = _S1823;
            }
            else
            {
                is_inside_8 = is_inside_7;
            }
            FKSurface _S1824 = surface_12;
            bool _S1825 = boundsVolume_0(&_S1824);
            bool _S1826;
            if(_S1825)
            {
                _S1826 = !_S1804;
            }
            else
            {
                _S1826 = false;
            }
            if(_S1826)
            {
                FKSurface faced_2 = surface_12;
                float3  _S1827 = - _S1816.geometry_n;
                float3  _S1828 = _slang_select(turned_1, _S1827,_S1816.geometry_n);
                (&faced_2)->geometry_n = _S1828;
                FKMedium _S1829 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1830 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1831 = faced_2;
                FKMedium _S1832 = _S1829;
                FKMedium _S1833 = _S1830;
                MediumSides _S1834 = mediumSides_0(&_S1831, &_S1832, filling_2, (&ray_2)->unit_direction, &_S1833);
                bool _S1835 = leavesInFront_0((&faced_2)->geometry_n, throughput_12, _S1816.geometry_n);
                float3  _S1836 = _slang_select(_S1835, _S1834.front.scatter,_S1834.behind.scatter);
                scatter_in_0 = _S1836;
                float3  _S1837 = scatter_in_0;
                float _S1838 = upsample(scatter_in_0, wavelength_6);
                float3  _S1839 = make_float3 (_S1838);
                float3  _S1840 = _slang_select(_S1544, _S1839,_S1837);
                scatter_in_0 = _S1840;
                float3  _S1841 = _slang_select(_S1835, _S1834.front.extinction,_S1834.behind.extinction);
                extinction_in_0 = _S1841;
                float3  _S1842 = extinction_in_0;
                float _S1843 = upsample(extinction_in_0, wavelength_6);
                float3  _S1844 = make_float3 (_S1843);
                float3  _S1845 = _slang_select(_S1544, _S1844,_S1842);
                extinction_in_0 = _S1845;
                float _S1846 = _slang_select(_S1835, _S1834.front.g,_S1834.behind.g);
                g_in_0 = _S1846;
                uint _S1847 = _S1834.fillings.x;
                uint _S1848 = _S1834.fillings.y;
                uint _S1849 = _slang_select(_S1835, _S1848,_S1847);
                bool _S1850 = (fcptVaryingUsed());
                uint _S1851 = _slang_select(_S1850, _S1849,4294967295U);
                filling_2 = _S1851;
            }
            (&ray_2)->unit_direction = throughput_12;
            bool _S1852 = !_S1804;
            if(_S1852)
            {
                FKSurface _S1853 = surface_12;
                float _S1854 = _slang_select(straight_0, 0.0f,_S1853.geometry_offset);
                float3  _S1855 = - _S1521.smooth_n;
                bool _S1856 = is_inside_8 != _S1700;
                float3  _S1857 = _slang_select(_S1856, _S1855,_S1521.smooth_n);
                float3  _S1858 = (&ray_2)->origin + make_float3 (_S1854) * _S1857;
                (&ray_2)->origin = _S1858;
            }
            throughput_13 = throughput_14;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1804;
            viewed_1 = _S1698;
            sky_pdf_2 = _S1820;
            spread_5 = _S1821;
            reconnection_0 = reconnection_1;
            is_inside_6 = is_inside_8;
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
            is_inside_6 = is_inside_7;
        }
        bool _S1859 = !replay_2;
        float density_7;
        if(_S1859)
        {
            if(_S1483)
            {
                float3  _S1860 = pathColor(throughput_13 * emission_1, spectral_weight_0, wavelength_6);
                Reservoir candidate_8 = chain_0;
                uint _S1861 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1862 = _S1861 == 1U;
                if(_S1862)
                {
                    float3  _S1863 = safeDivide(_S1860, chain_throughput_0);
                    (&candidate_8)->radiance = _S1863;
                }
                Reservoir _S1864 = withEnd(candidate_8, 2U, b_8, _S1860);
                offer(sel_7, _S1864, _S1860 * make_float3 (scale_4) / make_float3 (density_6));
            }
            if(_S1483)
            {
                refracted_5 = true;
            }
            else
            {
                refracted_5 = scatter_2;
            }
            if(refracted_5)
            {
                float _S1865 = survivalProbability(abs_0(throughput_13), density_6);
                density_7 = _S1865;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1866 = stream(_S1360, b_8 + 128U);
            Random _S1867 = pcg(_S1866);
            bool _S1868 = density_7 < (_S1867.value);
            if(_S1868)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1869 = (fcptMaxBounces());
                wrong_side_0 = b_8 >= _S1869;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1870 = density_6 * density_7;
            density_7 = _S1870;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1871 = layer_0 ^ 1U;
        uint _S1872 = _slang_select(passes_0, _S1871,0U);
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
            uint _S1873 = b_11 + 1U;
            b_8 = _S1873;
            layer_0 = _S1872;
            continue;
        }
        FKRay _S1874 = ray_2;
        float _S1875 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_2)
        {
            refracted_5 = _S1588;
        }
        else
        {
            refracted_5 = false;
        }
        if(refracted_5)
        {
            wrong_side_0 = _S1337 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1876 = _slang_select(wrong_side_0, _S1875,4.294967296e+09f);
        bool _S1877 = !_S1552;
        if(straight_0)
        {
            _S1632 = true;
        }
        else
        {
            _S1632 = _S1552;
        }
        FKHit _S1878;
        if(_S1632)
        {
            _S1878 = hit_4;
        }
        else
        {
            _S1878 = _S1605;
        }
        FKHit _S1879 = (fcptTraverseInstanceBVH((_S1874), (_S1491), (_S1876), (_S1877), (_S1878), (viewed_1)));
        hit_4 = _S1879;
        if(replay_2)
        {
            _S1633 = _S1588;
        }
        else
        {
            _S1633 = false;
        }
        if(_S1633)
        {
            _S1693 = _S1337 == 1U;
        }
        else
        {
            _S1693 = false;
        }
        if(_S1693)
        {
            _S1694 = ((&hit_4)->instance_index) == (_S1349.instance_index);
        }
        else
        {
            _S1694 = false;
        }
        if(_S1694)
        {
            _S1695 = ((&hit_4)->triangle_index) == (_S1349.triangle_index);
        }
        else
        {
            _S1695 = false;
        }
        if(_S1695)
        {
            (&hit_4)->uv = _S1349.uv;
            float _S1880 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S1880;
        }
        if(replay_2)
        {
            _S1696 = _S1588;
        }
        else
        {
            _S1696 = false;
        }
        if(_S1696)
        {
            _S1697 = _S1337 == 3U;
        }
        else
        {
            _S1697 = false;
        }
        if(_S1697)
        {
            _S1698 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1698 = false;
        }
        if(_S1698)
        {
            return _S1333;
        }
        Reservoir _S1881 = chain_0;
        uint _S1882 = filling_2;
        for(;;)
        {
            bool _S1883 = (fcptVaryingUsed());
            if(_S1883)
            {
                _S1699 = _S1882 != 4294967295U;
            }
            else
            {
                _S1699 = false;
            }
            float _S1884;
            if(_S1699)
            {
                float _S1885 = (fcptMajorant((_S1882)));
                _S1884 = _S1885;
            }
            else
            {
                _S1884 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_2)
            {
                _S1700 = _S1588;
            }
            else
            {
                _S1700 = false;
            }
            if(_S1700)
            {
                _S1701 = _S1337 == 1U;
            }
            else
            {
                _S1701 = false;
            }
            if(_S1701)
            {
                _S1702 = _S1884 > 0.0f;
            }
            else
            {
                _S1702 = false;
            }
            if(_S1702)
            {
                ended_0 = _S1333;
                sky_pdf_1 = sky_pdf_2;
                spread_3 = spread_5;
                width_4 = width_3;
                density_3 = density_7;
                throughput_14 = throughput_13;
                b_11 = b_8;
                _S1703 = true;
                break;
            }
            bool _S1886 = (&prev_0)->rough;
            if(_S1886)
            {
                _S1703 = !(_S1884 > 0.0f);
            }
            else
            {
                _S1703 = false;
            }
            (&prev_0)->rough = _S1703;
            uint _S1887 = b_8 + 320U;
            bool _S1888 = b_8 == 4294967295U;
            uint _S1889 = _slang_select(_S1888, 384U,_S1887);
            uint _S1890 = stream(_S1360, _S1889);
            uint tracking_1 = _S1890;
            weight_2 = throughput_6;
            glowed_0 = _S1332;
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
                    _S1331 = int(2);
                    break;
                }
                uint _S1891 = b_11 + 320U;
                bool _S1892 = b_11 == 4294967295U;
                uint _S1893 = _slang_select(_S1892, 384U,_S1891);
                uint _S1894 = stream(_S1360, _S1893);
                Random _S1895 = pcg(_S1894);
                float _S1896 = freeFlight_0(_S1895.value, _S1884);
                if(_S1699)
                {
                    float3  _S1897 = (&ray_2)->origin;
                    float3  _S1898 = (&ray_2)->unit_direction;
                    float _S1899 = (&hit_4)->distance;
                    uint _S1900 = _slang_select(_S1892, 0U,b_11);
                    uint _S1901 = (&prev_0)->lobe;
                    uint _S1902 = _slang_select(_S1892, 3U,_S1901);
                    float _S1903 = (fcptTrackMedium((_S1882), (_S1897), (_S1898), (_S1899), (&tracking_1), (&weight_2), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1900), (_S1902), (_S1892)));
                    spread_4 = _S1903;
                }
                else
                {
                    spread_4 = _S1896;
                }
                bool _S1904 = !(spread_4 < ((&hit_4)->distance));
                if(_S1904)
                {
                    _S1331 = int(2);
                    break;
                }
                if(_S1699)
                {
                    _S1704 = _S1859;
                }
                else
                {
                    _S1704 = false;
                }
                if(_S1704)
                {
                    float3  _S1905 = pathColor(throughput_14 * glowed_0, spectral_weight_0, wavelength_6);
                    float3  _S1906 = _S1905 / make_float3 (density_3);
                    float3  _S1907 = sel_7->glow + _S1906;
                    sel_7->glow = _S1907;
                }
                else
                {
                }
                glowed_0 = _S1332;
                uint b_12 = b_11 + 1U;
                float3  _S1908 = (&ray_2)->origin + make_float3 (spread_4) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1908;
                float3  _S1909 = flightWeight_0(scatter_in_0, extinction_in_0, _S1884, spread_4, true);
                float3  _S1910 = weight_2;
                float _S1911 = upsample(weight_2, wavelength_6);
                float3  _S1912 = make_float3 (_S1911);
                float3  _S1913 = _slang_select(_S1544, _S1912,_S1910);
                float3  _S1914 = _slang_select(_S1699, _S1913,_S1909);
                float3  throughput_15 = throughput_14 * _S1914;
                uint _S1915 = stream(_S1360, b_12 + 320U);
                tracking_1 = _S1915;
                weight_2 = throughput_6;
                float width_7 = width_4 + spread_3 * spread_4;
                float _S1916 = spread_3 + 3.14159274101257324f;
                bool _S1917 = scatterSampled_0(replay_2, b_12, _S1348, _S1699);
                TreeSample light_4;
                if(_S1917)
                {
                    float3  _S1918 = (&ray_2)->origin;
                    float3  _S1919 = (&ray_2)->unit_direction;
                    float3  _S1920 = (&ray_2)->unit_direction;
                    uint _S1921 = stream(_S1360, b_12 + 64U);
                    float3  _S1922 = extinction_in_0;
                    float3  _S1923 = extinction_in_0;
                    uint2  _S1924 = make_uint2 (_S1882);
                    float3  _S1925 = (&ray_2)->unit_direction;
                    uint _S1926 = arrivalLobe_0(b_12, (&prev_0)->lobe);
                    FKHit _S1927 = _S1605;
                    ShadowContext _S1928 = ShadowContext_x24init_0(_S1922, _S1923, _S1924, _S1925, b_12, _S1926, false, spread_4, width_7, &_S1927, false);
                    ShadowContext _S1929 = _S1928;
                    TreeSample _S1930 = sampleLightTree_0(_S1918, _S1919, _S1920, 0.0f, true, _S1921, &_S1929);
                    light_4 = _S1930;
                }
                else
                {
                    light_4 = _S1602;
                }
                float _S1931 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1932 = (fcptMaxBounces());
                bool _S1933 = b_12 < _S1932;
                if(_S1933)
                {
                    _S1705 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1705 = false;
                }
                float _S1934 = _slang_select(_S1705, _S1931,0.0f);
                float3  _S1935 = throughput_15 * light_4.radiance;
                float _S1936 = powerHeuristic(light_4.density, _S1934);
                float3  _S1937 = pathColor(_S1935 * make_float3 (_S1931 * _S1936), spectral_weight_0, wavelength_6);
                float3  _S1938 = _slang_select(_S1917, _S1937,_S1332);
                if(replay_2)
                {
                    _S1706 = b_12 == _S1348;
                }
                else
                {
                    _S1706 = false;
                }
                if(_S1706)
                {
                    bool _S1939 = _S1337 == 2U;
                    if(_S1939)
                    {
                        float _S1940 = resamplingTarget(_S1938);
                        _S1707 = _S1940 > 0.0f;
                    }
                    else
                    {
                        _S1707 = false;
                    }
                    if(_S1707)
                    {
                        Shift _S1941 = Shift_x24init_0(_S1938, 1.0f);
                        _S1331 = int(1);
                        ended_0 = _S1941;
                        spread_4 = _S1916;
                        width_5 = width_7;
                        throughput_12 = throughput_15;
                        b_9 = b_12;
                        break;
                    }
                    _S1331 = int(1);
                    ended_0 = _S1333;
                    spread_4 = _S1916;
                    width_5 = width_7;
                    throughput_12 = throughput_15;
                    b_9 = b_12;
                    break;
                }
                if(_S1859)
                {
                    Reservoir candidate_9 = _S1881;
                    uint _S1942 = extractBits_0(_S1881.path, 24U, 8U);
                    uint _S1943 = insertBits_0(0U, _S1942, 24U, 8U);
                    uint _S1944 = extractBits_0(_S1881.path, 10U, 2U);
                    bool _S1945 = _S1944 == 1U;
                    if(_S1945)
                    {
                        float3  _S1946 = safeDivide(_S1938, chain_throughput_0);
                        (&candidate_9)->radiance = _S1946;
                    }
                    else
                    {
                        uint _S1947 = insertBits_0(_S1943, b_12 + 1U, 5U, 5U);
                        uint _S1948 = insertBits_0(_S1947, 2U, 10U, 2U);
                        (&candidate_9)->path = _S1948;
                    }
                    Reservoir _S1949 = withEnd(candidate_9, 0U, b_12, _S1938);
                    offer(sel_7, _S1949, _S1938 * make_float3 (scale_4) / make_float3 (density_3));
                    float _S1950 = survivalProbability(abs_0(throughput_15), density_3);
                    uint _S1951 = stream(_S1360, b_12 + 128U);
                    Random _S1952 = pcg(_S1951);
                    bool _S1953 = _S1950 < (_S1952.value);
                    if(_S1953)
                    {
                        _S1707 = true;
                    }
                    else
                    {
                        uint _S1954 = (fcptMaxBounces());
                        _S1707 = b_12 >= _S1954;
                    }
                    if(_S1707)
                    {
                        _S1331 = int(1);
                        ended_0 = _S1333;
                        spread_4 = _S1916;
                        width_5 = width_7;
                        throughput_12 = throughput_15;
                        b_9 = b_12;
                        break;
                    }
                    float _S1955 = density_3 * _S1950;
                    density_3 = _S1955;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1956 = stream(_S1360, b_12);
                float3  _S1957 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1956, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1957;
                NEEVertex _S1958 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1332, (&ray_2)->origin);
                nee_vertex_0 = _S1958;
                Vertex _S1959 = scatteredVertex_0(is_inside_6);
                prev_0 = _S1959;
                float _S1960 = (&prev_0)->pdf;
                FKRay _S1961 = ray_2;
                FKHit _S1962 = (fcptTraverseInstanceBVH((_S1961), (true), (4.294967296e+09f), (false), (_S1605), (false)));
                hit_4 = _S1962;
                b_11 = b_12;
                throughput_14 = throughput_15;
                spread_3 = _S1916;
                width_4 = width_7;
                sky_pdf_1 = _S1960;
            }
            if(_S1331 != int(2))
            {
                spread_3 = spread_4;
                width_4 = width_5;
                throughput_14 = throughput_12;
                b_11 = b_9;
                _S1703 = true;
                break;
            }
            ended_0 = _S1333;
            _S1703 = false;
            break;
        }
        if(_S1703)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1704 = b_11 == b_8;
        }
        else
        {
            _S1704 = false;
        }
        bool _S1963 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S1963)
        {
            bool _S1964 = !(&nee_vertex_0)->none;
            float _S1965 = _slang_select(_S1964, sky_pdf_1,0.0f);
            float _S1966 = escapeWeight_0(_S1965, (&ray_2)->unit_direction);
            float3  _S1967 = environment_0((&ray_2)->unit_direction, b_11, (&prev_0)->lobe);
            float3  _S1968 = pathColor(throughput_14 * _S1967, spectral_weight_0, wavelength_6);
            if(replay_2)
            {
                bool _S1969 = b_11 == _S1348;
                if(_S1969)
                {
                    passes_0 = _S1337 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1968 * make_float3 (_S1966) / make_float3 (r_8->jac), density_3 / r_8->jac);
                }
                if(_S1347)
                {
                    passes_0 = _S1344;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_11 == _S1335;
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
                    return Shift_x24init_0(_S1968 * make_float3 (_S1966), 1.0f);
                }
                return _S1333;
            }
            Reservoir candidate_10 = chain_0;
            uint _S1970 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1971 = _S1970 == 1U;
            if(_S1971)
            {
                uint _S1972 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1973 = _S1972 == b_11;
                float _S1974 = _slang_select(_S1973, 1.0f,_S1966);
                float3  _S1975 = safeDivide(_S1968 * make_float3 (_S1974), chain_throughput_0);
                (&candidate_10)->radiance = _S1975;
            }
            else
            {
                bool _S1976 = (&prev_0)->rough;
                if(_S1976)
                {
                    uint _S1977 = insertBits_0(_S1362, b_11 + 1U, 5U, 5U);
                    uint _S1978 = insertBits_0(_S1977, 3U, 10U, 2U);
                    uint _S1979 = insertBits_0(_S1978, (&prev_0)->lobe, 15U, 3U);
                    bool _S1980 = (&prev_0)->inside;
                    uint _S1981 = _slang_select(_S1980, 1U,0U);
                    uint _S1982 = insertBits_0(_S1979, _S1981, 22U, 1U);
                    (&candidate_10)->path = _S1982;
                    (&candidate_10)->jac = (&prev_0)->pdf;
                    (&candidate_10)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1983 = _S1968 * make_float3 (_S1966);
            Reservoir _S1984 = withEnd(candidate_10, 3U, b_11, _S1983);
            offer(sel_7, _S1984, _S1983 * make_float3 (scale_4) / make_float3 (density_3));
            break;
        }
        float3  _S1985 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1985;
        bool _S1986 = (fcptVaryingUsed());
        if(_S1986)
        {
            _S1705 = filling_2 != 4294967295U;
        }
        else
        {
            _S1705 = false;
        }
        if(_S1705)
        {
            if(_S1859)
            {
                float3  _S1987 = pathColor(throughput_14 * glowed_0, spectral_weight_0, wavelength_6);
                float3  _S1988 = _S1987 / make_float3 (density_3);
                float3  _S1989 = sel_7->glow + _S1988;
                sel_7->glow = _S1989;
            }
            float3  _S1990 = throughput_14 * weight_2;
            throughput_12 = _S1990;
        }
        else
        {
            float3  _S1991 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S1992 = throughput_14 * _S1991;
            throughput_12 = _S1992;
        }
        float _S1993 = width_4 + spread_3 * (&hit_4)->distance;
        viewed_0 = _S1704;
        width_3 = _S1993;
        throughput_5 = throughput_12;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_2 = spread_3;
        uint _S1873 = b_11 + 1U;
        b_8 = _S1873;
        layer_0 = _S1872;
    }
    return _S1333;
}

static __device__ Shift shift_0(Domain * dom_8, Reservoir * r_9)
{
    Selection _S1994 = (Selection{});
    Selection sel_8 = _S1994;
    bool _S1995 = (r_9->w) <= 0.0f;
    if(_S1995)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S1996 = walk_0(dom_8, r_9, true, 0.0f, &sel_8);
    return _S1996;
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
        *_slang_vector_get_element_ptr(&result_15, i_26) = (F32_tan((_slang_vector_get_element(x_27, i_26))));
        i_26 = i_26 + int(1);
    }
    return result_15;
}

static __device__ float3  acos_0(float3  x_28)
{
    float3  result_16;
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
        *_slang_vector_get_element_ptr(&result_16, i_27) = (F32_acos((_slang_vector_get_element(x_28, i_27))));
        i_27 = i_27 + int(1);
    }
    return result_16;
}

__device__ Random normal_distribution(uint state_4)
{
    Random _S1997 = pcg(state_4);
    Random _S1998 = pcg(_S1997.state);
    float _S1999 = 6.28318548202514648f * _S1997.value;
    float _S2000 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S1998.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1998.state, _S2000 * (F32_cos((_S1999))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_5, float3  value_2)
{
    RandomSphere _S2001;
    (&_S2001)->state = state_5;
    (&_S2001)->value = value_2;
    return _S2001;
}

__device__ RandomSphere random_sphere(uint state_6)
{
    Random _S2002 = normal_distribution(state_6);
    Random _S2003 = normal_distribution(_S2002.state);
    Random _S2004 = normal_distribution(_S2003.state);
    float3  _S2005 = make_float3 (_S2002.value, _S2003.value, _S2004.value);
    float3  _S2006 = ((((_S2005)) * make_float3(rnorm3df(((_S2005)).x, ((_S2005)).y, ((_S2005)).z))));
    return RandomSphere_x24init_0(_S2004.state, _S2006);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_17)
{
    float3  _S2007 = p1_0 - p0_0;
    float3  _S2008 = p2_0 - p0_0;
    float2  _S2009 = uv1_0 - uv0_0;
    float2  _S2010 = uv2_0 - uv0_0;
    float _S2011 = _S2009.x;
    float _S2012 = _S2010.y;
    float _S2013 = _S2009.y;
    float _S2014 = _S2010.x;
    float _S2015 = _S2011 * _S2012 - _S2013 * _S2014;
    float _S2016 = 1.0f / _S2015;
    float3  t_22 = (_S2007 * make_float3 (_S2012) - _S2008 * make_float3 (_S2013)) * make_float3 (_S2016);
    float3  _S2017 = (_S2008 * make_float3 (_S2011) - _S2007 * make_float3 (_S2014)) * make_float3 (_S2016);
    float3  _S2018 = t_22 - n_17 * make_float3 (dot_0(n_17, t_22));
    float3  t_23 = ((((_S2018)) * make_float3(rnorm3df(((_S2018)).x, ((_S2018)).y, ((_S2018)).z))));
    bool _S2019 = (dot_0(cross_0(n_17, t_23), _S2017)) > 0.0f;
    float3  t_24;
    if(_S2019)
    {
        float3  _S2020 = negate_0(t_23);
        t_24 = _S2020;
    }
    else
    {
        t_24 = t_23;
    }
    float3  _S2021 = cross_0(n_17, t_24);
    return makeMatrix<float, 3, 3> (t_24, _S2021, n_17);
}

__device__ float3  tangentToWorldNormalMap(float3  v_4, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_4, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_5, float3  uvw_0, float3  position_0)
{
    float3  _S2022 = t1_0 - t0_0;
    float3  _S2023 = t2_2 - t0_0;
    float3  _S2024 = t2_2 - t1_0;
    float _S2025 = (F32_min((length_0(_S2022)), ((F32_min((length_0(_S2023)), (length_0(_S2024)))))));
    float3  _S2026 = make_float3 (distance_1(position_0, t0_0), distance_1(position_0, t1_0), distance_1(position_0, t2_2));
    float3  _S2027 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S2028 = dot_0(geometry_n_5, _S2027);
    float3  _S2029 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S2030 = dot_0(geometry_n_5, _S2029);
    float3  _S2031 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S2032 = acos_0(abs_0(make_float3 (_S2028, _S2030, dot_0(geometry_n_5, _S2031))));
    float3  _S2033 = clamp_2(tan_0(_S2032), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S2026 * _S2033, uvw_0), 0.0f, _S2025 * 0.125f);
}

__device__ float3  straightThrough(float3  dir_17, float3  n_18, BSDFMaterial material_31)
{
    float3  _S2034 = negate_0(dir_17);
    float _S2035 = sign_0(dot_0(n_18, _S2034));
    float3  _S2036 = n_18 * make_float3 (_S2035);
    AnisotropicFrame _S2037 = anisotropicFrame(material_31, _S2036);
    bool _S2038 = (_S2037.alphas.x) > 0.0f;
    if(_S2038)
    {
        float _S2039 = material_31.transmission * (1.0f - material_31.metallic);
        float3  _S2040 = negate_0(_S2036);
        float3  _S2041 = anisotropicLocal(dir_17, _S2037.tangent, _S2040);
        float _S2042 = anisotropicG1(_S2041, _S2037.alphas);
        return make_float3 (_S2039 * _S2042) * material_31.albedo;
    }
    float _S2043 = material_31.transmission * (1.0f - material_31.metallic);
    float _S2044 = material_31.roughness;
    float _S2045 = smithG1(_S2044 * _S2044, (F32_abs((dot_0(n_18, dir_17)))));
    return make_float3 (_S2043 * _S2045) * material_31.albedo;
}

__device__ float hairRow(float3  in_dir_16, float3  t_25, float3  out_dir_5, uint p_14, float w_2, float alpha_20, uint nt_0)
{
    uint _S2046 = p_14 % 4U;
    float _S2047 = w_2 * HAIR_WIDTHS_0[_S2046];
    float _S2048 = (F32_asin((clamp_1(dot_0(out_dir_5, t_25), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_16, t_25), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S2046] * alpha_20;
    return ((F32_asinh((_S2048 / _S2047))) / (F32_asinh((3.14159274101257324f / _S2047))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_17, float3  t_26, float3  out_dir_6, uint np_0)
{
    float3  _S2049 = worldToTangent(out_dir_6, t_26);
    float3  _S2050 = worldToTangent(in_dir_17, t_26);
    return (F32_frac((((F32_atan2((_S2049.z), (_S2049.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S2050.z), (1.17549435082228751e-38f - _S2050.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_18, float3  t_27, uint p_15, float row_0, float column_0, float w_3, float alpha_21, uint nt_1, uint np_1)
{
    float3  _S2051 = worldToTangent(in_dir_18, t_27);
    uint _S2052 = p_15 % 4U;
    float _S2053 = w_3 * HAIR_WIDTHS_0[_S2052];
    float _S2054 = (F32_asin((clamp_1(dot_0(in_dir_18, t_27), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S2052] * alpha_21 + _S2053 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S2053))))));
    float _S2055 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S2051.z), (1.17549435082228751e-38f - _S2051.x)));
    float _S2056 = (F32_cos((_S2054)));
    float3  _S2057 = tangentToWorld(make_float3 (_S2056 * (F32_cos((_S2055))), (F32_sin((_S2054))), _S2056 * (F32_sin((_S2055)))), t_27);
    return _S2057;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_19, BSDFMaterial material_32, float coverage_1)
{
    float3  _S2058;
    if((material_32.ior) == 1.0f)
    {
        float3  _S2059 = straightThrough(toward_1, n_19, material_32);
        _S2058 = _S2059;
    }
    else
    {
        _S2058 = make_float3 (0.0f);
    }
    return _S2058 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_9, Reservoir r_10, bool replay_3, float scale_5, Selection * sel_9)
{
    Domain _S2060 = dom_9;
    Reservoir _S2061 = r_10;
    Shift _S2062 = walk_0(&_S2060, &_S2061, replay_3, scale_5, sel_9);
    return _S2062;
}

__device__ Shift shift_hook(Domain dom_10, Reservoir r_11)
{
    Domain _S2063 = dom_10;
    Reservoir _S2064 = r_11;
    Shift _S2065 = shift_0(&_S2063, &_S2064);
    return _S2065;
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
