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

__device__ float upsample(float3  rgb_0, float wavelength_0)
{
    float _S333 = dot_0(make_float3 (-0.08011700212955475f, 1.08901798725128174f, -0.00889899954199791f), rgb_0);
    float _S334 = dot_0(make_float3 (0.12177000194787979f, -1.22903203964233398f, 1.10724997520446777f), rgb_0);
    float _S335 = dot_0(make_float3 (1.17252397537231445f, -1.21603405475616455f, 0.04350199922919273f), rgb_0);
    float3  _S336 = make_float3 (_S333, _S334, _S335);
    float _S337 = (wavelength_0 - 0.44999998807907104f) / 0.02999999932944775f;
    float _S338 = (wavelength_0 - 0.63999998569488525f) / 0.03999999910593033f;
    return _S333 + _S334 * (F32_exp((-0.5f * _S337 * _S337))) + _S335 * (F32_exp((-0.5f * _S338 * _S338)));
}

__device__ BSDFMaterial atWavelength(BSDFMaterial material_0, float wavelength_1)
{
    BSDFMaterial at_0 = material_0;
    float _S339 = upsample(material_0.albedo, wavelength_1);
    float3  _S340 = make_float3 (_S339);
    (&at_0)->albedo = _S340;
    float _S341 = upsample(material_0.emissive, wavelength_1);
    float3  _S342 = make_float3 (_S341);
    (&at_0)->emissive = _S342;
    float _S343 = upsample(material_0.absorption, wavelength_1);
    float3  _S344 = make_float3 (_S343);
    (&at_0)->absorption = _S344;
    float _S345 = upsample(material_0.specular_tint, wavelength_1);
    float3  _S346 = make_float3 (_S345);
    (&at_0)->specular_tint = _S346;
    float _S347 = upsample(material_0.translucent, wavelength_1);
    float3  _S348 = make_float3 (_S347);
    (&at_0)->translucent = _S348;
    float _S349 = upsample(material_0.sheen, wavelength_1);
    float3  _S350 = make_float3 (_S349);
    (&at_0)->sheen = _S350;
    return at_0;
}

__device__ BSDFMaterial pathMaterial(BSDFMaterial material_1, float wavelength_2)
{
    BSDFMaterial _S351;
    if(wavelength_2 > 0.0f)
    {
        BSDFMaterial _S352 = atWavelength(material_1, wavelength_2);
        _S351 = _S352;
    }
    else
    {
        _S351 = material_1;
    }
    return _S351;
}

static __device__ float3  negate_0(float3  x_13)
{
    return - x_13;
}

static __device__ float sign_0(float e_1)
{
    float _S353;
    if(e_1 > 0.0f)
    {
        _S353 = 1.0f;
    }
    else
    {
        if(e_1 < 0.0f)
        {
            _S353 = -1.0f;
        }
        else
        {
            _S353 = 0.0f;
        }
    }
    return _S353;
}

struct AnisotropicFrame
{
    float3  tangent;
    float2  alphas;
};

static __device__ AnisotropicFrame AnisotropicFrame_x24init_0(float3  tangent_0, float2  alphas_0)
{
    AnisotropicFrame _S354;
    (&_S354)->tangent = tangent_0;
    (&_S354)->alphas = alphas_0;
    return _S354;
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_1)
{
    float3  a_1 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S355 = (F32_abs((dot_0(n_1, a_1)))) > 0.9999847412109375f;
    float3  a_2;
    if(_S355)
    {
        float3  _S356 = make_float3 (1.0f, 0.0f, 0.0f);
        a_2 = _S356;
    }
    else
    {
        a_2 = a_1;
    }
    float3  _S357 = cross_0(n_1, a_2);
    float3  _S358 = ((((_S357)) * make_float3(rnorm3df(((_S357)).x, ((_S357)).y, ((_S357)).z))));
    float3  _S359 = cross_0(n_1, _S358);
    return make_float3 (v_0.x) * _S358 + make_float3 (v_0.y) * n_1 + make_float3 (v_0.z) * _S359;
}

__device__ AnisotropicFrame anisotropicFrame(BSDFMaterial material_2, float3  n_i_0)
{
    float _S360 = material_2.roughness;
    float _S361 = _S360 * _S360;
    bool _S362 = (material_2.anisotropy) == 0.0f;
    bool _S363;
    if(_S362)
    {
        _S363 = true;
    }
    else
    {
        _S363 = !(_S361 > 0.0f);
    }
    if(_S363)
    {
        return AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f));
    }
    float3  _S364 = material_2.tangent - n_i_0 * make_float3 (dot_0(n_i_0, material_2.tangent));
    float3  _S365 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_i_0);
    bool _S366 = (dot_0(_S364, _S364)) > 0.0f;
    float3  _S367 = _slang_select(_S366, _S364,_S365);
    float3  _S368 = ((((_S367)) * make_float3(rnorm3df(((_S367)).x, ((_S367)).y, ((_S367)).z))));
    float _S369 = 6.28318548202514648f * material_2.anisotropic_rotation;
    float _S370 = (F32_sqrt((1.0f - 0.89999997615814209f * (F32_abs((material_2.anisotropy))))));
    float _S371 = 1.0f / _S370;
    bool _S372 = (material_2.anisotropy) < 0.0f;
    float _S373 = _slang_select(_S372, _S371,_S370);
    return AnisotropicFrame_x24init_0(_S368 * make_float3 ((F32_cos((_S369)))) + cross_0(n_i_0, _S368) * make_float3 ((F32_sin((_S369)))), make_float2 (_S361 / _S373, _S361 * _S373));
}

struct SheenProfile
{
    bool on;
    float albedo;
};

static __device__ SheenProfile SheenProfile_x24init_0(bool on_0, float albedo_0)
{
    SheenProfile _S374;
    (&_S374)->on = on_0;
    (&_S374)->albedo = albedo_0;
    return _S374;
}

__device__ float rgb_to_greyscale(float3  rgb_1)
{
    return dot_0(rgb_1, make_float3 (0.29899999499320984f, 0.58700001239776611f, 0.11400000005960464f));
}

__device__ static const FixedArray<float, 576>  VELVET_ALBEDO_0 = { {
    1.00383996963500977f, 1.00428998470306396f, 1.00356996059417725f, 1.00303995609283447f, 1.00261998176574707f, 1.00229001045227051f, 1.00198996067047119f, 1.00171005725860596f, 1.00144004821777344f, 1.00120997428894043f, 1.00102996826171875f, 1.00092005729675293f, 1.00088000297546387f, 1.0009000301361084f, 1.00095999240875244f, 1.00106000900268555f, 1.00115001201629639f, 1.00124001502990723f, 1.001289963722229f, 1.0013200044631958f, 1.00133001804351807f, 1.00133001804351807f, 1.0013200044631958f, 1.00129997730255127f, 0.99086397886276245f, 0.9934689998626709f, 0.99439799785614014f, 0.99513500928878784f, 0.99574202299118042f, 0.9962649941444397f, 0.99671798944473267f, 0.99709898233413696f, 0.997406005859375f, 0.99764800071716309f, 0.99783498048782349f, 0.99798601865768433f, 0.99811899662017822f, 0.99825501441955566f, 0.99840497970581055f, 0.99857097864151001f, 0.99874699115753174f, 0.99892902374267578f, 0.9990919828414917f, 0.99923902750015259f, 0.99936902523040771f, 0.99948000907897949f, 0.99957501888275146f, 0.99965798854827881f, 0.94088798761367798f, 0.95128101110458374f, 0.95866602659225464f, 0.96450901031494141f, 0.96921002864837646f, 0.973052978515625f, 0.97623497247695923f, 0.97890102863311768f, 0.98115700483322144f, 0.98308497667312622f, 0.98474901914596558f, 0.98619699478149414f, 0.98746699094772339f, 0.98858797550201416f, 0.98958402872085571f, 0.99047297239303589f, 0.99127000570297241f, 0.99198299646377563f, 0.99262100458145142f, 0.99318897724151611f, 0.99372398853302002f, 0.99426800012588501f, 0.99475300312042236f, 0.99514400959014893f, 0.86131101846694946f, 0.88463401794433594f, 0.90212702751159668f, 0.91595500707626343f, 0.92708200216293335f, 0.93617302179336548f, 0.94370102882385254f, 0.95000702142715454f, 0.95534700155258179f, 0.9599120020866394f, 0.96384698152542114f, 0.96726799011230469f, 0.97026199102401733f, 0.97289901971817017f, 0.97523599863052368f, 0.97731602191925049f, 0.97917401790618896f, 0.98083901405334473f, 0.98233497142791748f, 0.98368102312088013f, 0.98489302396774292f, 0.98598498106002808f, 0.98697298765182495f, 0.98787301778793335f, 0.75306302309036255f, 0.79328000545501709f, 0.82418698072433472f, 0.84881901741027832f, 0.86874997615814209f, 0.88506197929382324f, 0.89858502149581909f, 0.9099239706993103f, 0.91952997446060181f, 0.9277459979057312f, 0.93483197689056396f, 0.94099199771881104f, 0.9463840126991272f, 0.95113497972488403f, 0.95534402132034302f, 0.95908999443054199f, 0.9624369740486145f, 0.96543699502944946f, 0.96813201904296875f, 0.97055697441101074f, 0.97274202108383179f, 0.97471201419830322f, 0.97649002075195312f, 0.97809398174285889f, 0.62183499336242676f, 0.68052101135253906f, 0.72705197334289551f, 0.76452702283859253f, 0.79505598545074463f, 0.82021200656890869f, 0.84120297431945801f, 0.85885602235794067f, 0.87384098768234253f, 0.88667500019073486f, 0.89775800704956055f, 0.90739899873733521f, 0.91584599018096924f, 0.92329102754592896f, 0.929889976978302f, 0.93576502799987793f, 0.94101500511169434f, 0.94572198390960693f, 0.94994997978210449f, 0.95375597476959229f, 0.95718497037887573f, 0.9602770209312439f, 0.96306699514389038f, 0.96558600664138794f, 0.47742500901222229f, 0.5522189736366272f, 0.61415499448776245f, 0.66520899534225464f, 0.70744901895523071f, 0.74262100458145142f, 0.77213901281356812f, 0.7971159815788269f, 0.81841897964477539f, 0.83673000335693359f, 0.85258400440216064f, 0.86640900373458862f, 0.87854301929473877f, 0.88924998044967651f, 0.89874798059463501f, 0.90721100568771362f, 0.91477799415588379f, 0.92156499624252319f, 0.92766499519348145f, 0.93315702676773071f, 0.9381060004234314f, 0.94257098436355591f, 0.94660097360610962f, 0.95023900270462036f, 0.33539599180221558f, 0.41908100247383118f, 0.49247598648071289f, 0.55531197786331177f, 0.60879099369049072f, 0.65415602922439575f, 0.69274699687957764f, 0.72571200132369995f, 0.75402498245239258f, 0.77849102020263672f, 0.79976201057434082f, 0.81836599111557007f, 0.83474302291870117f, 0.84922301769256592f, 0.86208897829055786f, 0.87356698513031006f, 0.88384199142456055f, 0.89306402206420898f, 0.90135800838470459f, 0.9088289737701416f, 0.91556602716445923f, 0.92164498567581177f, 0.92713397741317749f, 0.93208998441696167f, 0.21194499731063843f, 0.29365798830986023f, 0.37110498547554016f, 0.44143900275230408f, 0.5036969780921936f, 0.55801302194595337f, 0.60521197319030762f, 0.64614301919937134f, 0.68169897794723511f, 0.71268302202224731f, 0.73979401588439941f, 0.76362699270248413f, 0.78467601537704468f, 0.80335497856140137f, 0.82000100612640381f, 0.83488202095031738f, 0.8482239842414856f, 0.86021500825881958f, 0.87101101875305176f, 0.88074499368667603f, 0.88952797651290894f, 0.89745801687240601f, 0.90461999177932739f, 0.91109001636505127f, 0.11949499696493149f, 0.18745699524879456f, 0.25997200608253479f, 0.33120998740196228f, 0.39773499965667725f, 0.45832300186157227f, 0.51248997449874878f, 0.56048798561096191f, 0.6028980016708374f, 0.64032697677612305f, 0.67339599132537842f, 0.70268499851226807f, 0.72870397567749023f, 0.75189602375030518f, 0.77263599634170532f, 0.7912449836730957f, 0.80796998739242554f, 0.82303100824356079f, 0.8366129994392395f, 0.84887397289276123f, 0.85994899272918701f, 0.86995697021484375f, 0.87900298833847046f, 0.88717901706695557f, 0.05942929908633232f, 0.10839699953794479f, 0.16785700619220734f, 0.23236599564552307f, 0.29767501354217529f, 0.36022999882698059f, 0.41842898726463318f, 0.47170799970626831f, 0.5198180079460144f, 0.56301301717758179f, 0.60171198844909668f, 0.63635998964309692f, 0.66739702224731445f, 0.69524997472763062f, 0.720287024974823f, 0.74283498525619507f, 0.76317602396011353f, 0.78155702352523804f, 0.79817098379135132f, 0.81319701671600342f, 0.8267899751663208f, 0.83908802270889282f, 0.85021400451660156f, 0.86027902364730835f, 0.02584660053253174f, 0.05619670078158379f, 0.09917669743299484f, 0.15162299573421478f, 0.20941600203514099f, 0.26902499794960022f, 0.32757499814033508f, 0.38318398594856262f, 0.43501600623130798f, 0.48271399736404419f, 0.52620798349380493f, 0.56570100784301758f, 0.60149699449539185f, 0.63392102718353271f, 0.66328197717666626f, 0.68988502025604248f, 0.7139970064163208f, 0.7358660101890564f, 0.75570398569107056f, 0.77369099855422974f, 0.78999698162078857f, 0.80477499961853027f, 0.81816202402114868f, 0.83028298616409302f, 0.00968609005212784f, 0.02591750025749207f, 0.05318830162286758f, 0.09121809899806976f, 0.13777700066566467f, 0.18976299464702606f, 0.244159996509552f, 0.29880800843238831f, 0.35169300436973572f, 0.40180501341819763f, 0.44872200489044189f, 0.49213200807571411f, 0.53206497430801392f, 0.5686650276184082f, 0.60214298963546753f, 0.63272500038146973f, 0.66062301397323608f, 0.68605399131774902f, 0.70922297239303589f, 0.73031198978424072f, 0.74948400259017944f, 0.76689702272415161f, 0.78270000219345093f, 0.79702901840209961f, 0.00303822988644242f, 0.01048239972442389f, 0.02568300068378448f, 0.05025380104780197f, 0.08408640325069427f, 0.12561400234699249f, 0.17249999940395355f, 0.22232000529766083f, 0.27309399843215942f, 0.32321798801422119f, 0.37149098515510559f, 0.4173240065574646f, 0.4603630006313324f, 0.50043797492980957f, 0.53755801916122437f, 0.57181298732757568f, 0.60333001613616943f, 0.63226902484893799f, 0.65877401828765869f, 0.68301999568939209f, 0.70514601469039917f, 0.7253040075302124f, 0.74363899230957031f, 0.76029098033905029f, 0.00076204299693927f, 0.00361976004205644f, 0.0110037000849843f, 0.02512970007956028f, 0.04727460071444511f, 0.07745999842882156f, 0.11460299789905548f, 0.1569570004940033f, 0.20258499681949615f, 0.24971699714660645f, 0.29707801342010498f, 0.34340900182723999f, 0.38799500465393066f, 0.43043500185012817f, 0.47039699554443359f, 0.50777101516723633f, 0.54253697395324707f, 0.57473397254943848f, 0.60444700717926025f, 0.63179397583007812f, 0.65686798095703125f, 0.67979699373245239f, 0.70071202516555786f, 0.71974599361419678f, 0.00014345299859997f, 0.00102306995540857f, 0.00407376000657678f, 0.01122699957340956f, 0.02423799969255924f, 0.04415180161595345f, 0.07109060138463974f, 0.10433399677276611f, 0.14259399473667145f, 0.184347003698349f, 0.2281080037355423f, 0.27265200018882751f, 0.31696400046348572f, 0.36016398668289185f, 0.40178799629211426f, 0.44139501452445984f, 0.47875601053237915f, 0.51375597715377808f, 0.54635101556777954f, 0.57658302783966064f, 0.60447400808334351f, 0.63009101152420044f, 0.65352898836135864f, 0.67488902807235718f, 0.00001858420000644f, 0.0002227969962405f, 0.00124967005103827f, 0.00435766018927097f, 0.01113030035048723f, 0.0229835007339716f, 0.04079980030655861f, 0.06477940082550049f, 0.09447769820690155f, 0.12897300720214844f, 0.16708999872207642f, 0.20760199427604675f, 0.24936899542808533f, 0.29154899716377258f, 0.3332040011882782f, 0.37377101182937622f, 0.41274300217628479f, 0.44977998733520508f, 0.4846780002117157f, 0.51733100414276123f, 0.54769200086593628f, 0.57572799921035767f, 0.6014779806137085f, 0.62501102685928345f, 1.46482000218384201e-06f, 0.00003429050047998f, 0.0002985020109918f, 0.00140504003502429f, 0.00443577999249101f, 0.01069260016083717f, 0.02133879996836185f, 0.0371410995721817f, 0.05836030095815659f, 0.08476380258798599f, 0.11572299897670746f, 0.1503559947013855f, 0.18766500055789948f, 0.22665500640869141f, 0.26647698879241943f, 0.30632400512695312f, 0.34550899267196655f, 0.38344401121139526f, 0.41970700025558472f, 0.45401400327682495f, 0.48618701100349426f, 0.51614201068878174f, 0.54384201765060425f, 0.56930899620056152f, 5.83937982412408019e-08f, 3.2765999549155822e-06f, 0.00005055400106357f, 0.00035111699253321f, 0.00145683996379375f, 0.00427943980321288f, 0.0098936902359128f, 0.01927389949560165f, 0.03310279920697212f, 0.05168719962239265f, 0.07495570182800293f, 0.10250899940729141f, 0.13370099663734436f, 0.1677280068397522f, 0.20372100174427032f, 0.24084299802780151f, 0.27840098738670349f, 0.31564199924468994f, 0.35190799832344055f, 0.38674798607826233f, 0.41985601186752319f, 0.45104199647903442f, 0.48021000623703003f, 0.50734001398086548f, 8.73966010672688753e-10f, 1.57741993689342053e-07f, 5.21975016454234719e-06f, 0.00006079579907237f, 0.00036219600588083f, 0.00138045998755842f, 0.00386844994500279f, 0.00871635042130947f, 0.01675550080835819f, 0.02860799990594387f, 0.04461279883980751f, 0.06480839848518372f, 0.08895269781351089f, 0.11656700074672699f, 0.1470009982585907f, 0.17950700223445892f, 0.21331800520420074f, 0.24785000085830688f, 0.28237700462341309f, 0.31631898880004883f, 0.34923198819160461f, 0.38083100318908691f, 0.41094100475311279f, 0.43946701288223267f, 2.8866399288257627e-12f, 2.63671995348602195e-09f, 2.51094007808205788e-07f, 5.97520011069718748e-06f, 0.00005859580051037f, 0.0003192939911969f, 0.00116373994387686f, 0.00319523992948234f, 0.00714873988181353f, 0.0137449000030756f, 0.0235638003796339f, 0.03696820139884949f, 0.05407309904694557f, 0.0747511014342308f, 0.09866459667682648f, 0.12531900405883789f, 0.15412400662899017f, 0.18446199595928192f, 0.21573600172996521f, 0.24741099774837494f, 0.27903899550437927f, 0.310263991355896f, 0.34082499146461487f, 0.37054198980331421f, 6.94488983838260476e-16f, 7.04290011727115584e-12f, 3.21448001550095341e-09f, 2.20180993437679717e-07f, 4.50593006462440826e-06f, 0.00004154839916737f, 0.00022262999846134f, 0.00081575999502093f, 0.00227530999109149f, 0.00519366981461644f, 0.01020010001957417f, 0.0178545992821455f, 0.02856850065290928f, 0.04256030172109604f, 0.05984469875693321f, 0.08025020360946655f, 0.10345599800348282f, 0.12904399633407593f, 0.15654699504375458f, 0.1854960024356842f, 0.21545499563217163f, 0.24603499472141266f, 0.27690801024436951f, 0.3078019917011261f, 5.46278023199234311e-22f, 3.43167987041791307e-16f, 2.29294990113093622e-12f, 9.57796952860689998e-10f, 6.87986982939037262e-08f, 1.5533599935224629e-06f, 0.00001600819996384f, 0.00009555240103509f, 0.00038631301140413f, 0.00117554003372788f, 0.00289549003355205f, 0.00607588002458215f, 0.01126710046082735f, 0.01896269991993904f, 0.02954130060970783f, 0.04323289915919304f, 0.06011129915714264f, 0.0801049992442131f, 0.10301999747753143f, 0.12857000529766083f, 0.15640300512313843f, 0.18612800538539886f, 0.21734000742435455f, 0.24963200092315674f, 0.0f, 0.0f, 3.09890004335006815e-24f, 2.21276004416278673e-18f, 2.67358004631774657e-14f, 2.24439997836833882e-11f, 3.13075010360819306e-09f, 1.26480998119404831e-07f, 2.12951999856159091e-06f, 0.00001907769910758f, 0.00010753999958979f, 0.00042892698547803f, 0.00131604995112866f, 0.00330013991333544f, 0.00707077002152801f, 0.01337909977883101f, 0.02291939966380596f, 0.03622379899024963f, 0.05359359830617905f, 0.07507230341434479f, 0.10045900195837021f, 0.12935000658035278f, 0.16119599342346191f, 0.19536399841308594f
} };
__device__ static const FixedArray<float, 576>  SHEEN_ALBEDO_0 = { {
    0.62089997529983521f, 0.49450001120567322f, 0.38080000877380371f, 0.28439998626708984f, 0.20010000467300415f, 0.1257999986410141f, 0.05990000069141388f, 0.00109999999403954f, -0.05160000175237656f, -0.09889999777078629f, -0.14159999787807465f, -0.18009999394416809f, -0.2151000052690506f, -0.24690000712871552f, -0.27590000629425049f, -0.30230000615119934f, -0.32649999856948853f, -0.34860000014305115f, -0.36890000104904175f, -0.38760000467300415f, -0.40479999780654907f, -0.42070001363754272f, -0.43439999222755432f, -0.44929999113082886f, 0.59240001440048218f, 0.47049999237060547f, 0.35899999737739563f, 0.26440000534057617f, 0.18150000274181366f, 0.10830000042915344f, 0.04329999908804893f, -0.01470000017434359f, -0.066600002348423f, -0.11339999735355377f, -0.15549999475479126f, -0.19370000064373016f, -0.22820000350475311f, -0.25970000028610229f, -0.28830000758171082f, -0.31450000405311584f, -0.33840000629425049f, -0.36039999127388f, -0.38049998879432678f, -0.39899998903274536f, -0.41609999537467957f, -0.43180000782012939f, -0.44539999961853027f, -0.46070000529289246f, 0.5228000283241272f, 0.40599998831748962f, 0.30259999632835388f, 0.21250000596046448f, 0.13330000638961792f, 0.06319999694824219f, 0.00069999997504056f, -0.05510000139474869f, -0.10520000010728836f, -0.15039999783039093f, -0.19120000302791595f, -0.2281000018119812f, -0.26170000433921814f, -0.2921999990940094f, -0.31999999284744263f, -0.34549999237060547f, -0.36869999766349792f, -0.39010000228881836f, -0.40970000624656677f, -0.42770001292228699f, -0.44440001249313354f, -0.45969998836517334f, -0.47389999032020569f, -0.48800000548362732f, 0.43569999933242798f, 0.32769998908042908f, 0.23160000145435333f, 0.14730000495910645f, 0.07280000299215317f, 0.00659999996423721f, -0.05260000005364418f, -0.10559999942779541f, -0.1534000039100647f, -0.19650000333786011f, -0.23549999296665192f, -0.27090001106262207f, -0.30309998989105225f, -0.33239999413490295f, -0.35920000076293945f, -0.38359999656677246f, -0.40599998831748962f, -0.42660000920295715f, -0.44549998641014099f, -0.46290001273155212f, -0.47900000214576721f, -0.49380001425743103f, -0.50749999284744263f, -0.52090001106262207f, 0.33129999041557312f, 0.23459999263286591f, 0.14740000665187836f, 0.07010000199079514f, 0.00139999995008111f, -0.0601000003516674f, -0.11519999802112579f, -0.16490000486373901f, -0.20970000326633453f, -0.25029999017715454f, -0.28720000386238098f, -0.3206000030040741f, -0.35109999775886536f, -0.37900000810623169f, -0.40439999103546143f, -0.42770001292228699f, -0.44900000095367432f, -0.46869999170303345f, -0.48669999837875366f, -0.5033000111579895f, -0.5187000036239624f, -0.53289997577667236f, -0.54600000381469727f, -0.55860000848770142f, 0.21109999716281891f, 0.12790000438690186f, 0.0511000007390976f, -0.01769999973475933f, -0.07970000058412552f, -0.13549999892711639f, -0.18600000441074371f, -0.23160000145435333f, -0.27300000190734863f, -0.31069999933242798f, -0.34490001201629639f, -0.37619999051094055f, -0.40470001101493835f, -0.43070000410079956f, -0.4546000063419342f, -0.476500004529953f, -0.49660000205039978f, -0.51510000228881836f, -0.53210002183914185f, -0.54780000448226929f, -0.56230002641677856f, -0.57580000162124634f, -0.58819997310638428f, -0.60009998083114624f, 0.0754999965429306f, 0.00800000037997961f, -0.05649999901652336f, -0.11569999903440475f, -0.16979999840259552f, -0.21920000016689301f, -0.26420000195503235f, -0.3052000105381012f, -0.34270000457763672f, -0.37689998745918274f, -0.40819999575614929f, -0.43680000305175781f, -0.46299999952316284f, -0.48710000514984131f, -0.50910001993179321f, -0.52939999103546143f, -0.54809999465942383f, -0.56529998779296875f, -0.5810999870300293f, -0.59570002555847168f, -0.60930001735687256f, -0.6218000054359436f, -0.63340002298355103f, -0.6445000171661377f, -0.07569999992847443f, -0.12489999830722809f, -0.17569999396800995f, -0.22380000352859497f, -0.26890000700950623f, -0.3107999861240387f, -0.34959998726844788f, -0.38539999723434448f, -0.41839998960494995f, -0.44870001077651978f, -0.47659999132156372f, -0.50230002403259277f, -0.52590000629425049f, -0.54759997129440308f, -0.56760001182556152f, -0.58600002527236938f, -0.6029999852180481f, -0.61870002746582031f, -0.63330000638961792f, -0.64670002460479736f, -0.6590999960899353f, -0.67059999704360962f, -0.68129998445510864f, -0.69160002470016479f, -0.24320000410079956f, -0.27120000123977661f, -0.30640000104904175f, -0.34209999442100525f, -0.37700000405311584f, -0.41060000658035278f, -0.44229999184608459f, -0.47220000624656677f, -0.50010001659393311f, -0.52600002288818359f, -0.55010002851486206f, -0.57239997386932373f, -0.59310001134872437f, -0.61220002174377441f, -0.62989997863769531f, -0.64620000123977661f, -0.66140002012252808f, -0.6754000186920166f, -0.68839997053146362f, -0.70039999485015869f, -0.71160000562667847f, -0.72200000286102295f, -0.73159998655319214f, -0.74089998006820679f, -0.42809998989105225f, -0.43149998784065247f, -0.44920000433921814f, -0.47099998593330383f, -0.49459999799728394f, -0.51880002021789551f, -0.54269999265670776f, -0.5658000111579895f, -0.58799999952316284f, -0.60900002717971802f, -0.62870001792907715f, -0.64730000495910645f, -0.6646999716758728f, -0.68080002069473267f, -0.69590002298355103f, -0.70999997854232788f, -0.72299998998641968f, -0.73509997129440308f, -0.74639999866485596f, -0.75690001249313354f, -0.76670002937316895f, -0.77579998970031738f, -0.78430002927780151f, -0.79250001907348633f, -0.63230001926422119f, -0.60759997367858887f, -0.60519999265670776f, -0.61119997501373291f, -0.62209999561309814f, -0.63580000400543213f, -0.65090000629425049f, -0.66659998893737793f, -0.68239998817443848f, -0.69789999723434448f, -0.71289998292922974f, -0.7271999716758728f, -0.74089998006820679f, -0.75379997491836548f, -0.76590001583099365f, -0.77740001678466797f, -0.78810000419616699f, -0.79809999465942383f, -0.80750000476837158f, -0.81629997491836548f, -0.82450002431869507f, -0.83209997415542603f, -0.83929997682571411f, -0.84630000591278076f, -0.85790002346038818f, -0.80119997262954712f, -0.77600002288818359f, -0.76410001516342163f, -0.76059997081756592f, -0.76239997148513794f, -0.76770001649856567f, -0.7750999927520752f, -0.78380000591278076f, -0.79309999942779541f, -0.80279999971389771f, -0.8125f, -0.82200002670288086f, -0.8312000036239624f, -0.8400999903678894f, -0.84859997034072876f, -0.85670000314712524f, -0.86440002918243408f, -0.8716999888420105f, -0.87849998474121094f, -0.88499999046325684f, -0.89099997282028198f, -0.89670002460479736f, -0.90240001678466797f, -1.10769999027252197f, -1.01429998874664307f, -0.96329998970031738f, -0.93110001087188721f, -0.91140002012252808f, -0.89990001916885376f, -0.89410001039505005f, -0.89219999313354492f, -0.89289999008178711f, -0.89539998769760132f, -0.89910000562667847f, -0.9035000205039978f, -0.90850001573562622f, -0.91360002756118774f, -0.9189000129699707f, -0.92419999837875366f, -0.92940002679824829f, -0.93440002202987671f, -0.93930000066757202f, -0.9440000057220459f, -0.94849997758865356f, -0.95270001888275146f, -0.95679998397827148f, -0.96100002527236938f, -1.38499999046325684f, -1.24950003623962402f, -1.16919994354248047f, -1.11409997940063477f, -1.07599997520446777f, -1.0494999885559082f, -1.03129994869232178f, -1.01880002021789551f, -1.01059997081756592f, -1.00539994239807129f, -1.00240004062652588f, -1.00109994411468506f, -1.0009000301361084f, -1.00150001049041748f, -1.00279998779296875f, -1.00440001487731934f, -1.00639998912811279f, -1.00849997997283936f, -1.01069998741149902f, -1.0130000114440918f, -1.01530003547668457f, -1.01750004291534424f, -1.01979994773864746f, -1.02230000495910645f, -1.69420003890991211f, -1.51020002365112305f, -1.39649999141693115f, -1.31540000438690186f, -1.2565000057220459f, -1.21309995651245117f, -1.18079996109008789f, -1.15649998188018799f, -1.13820004463195801f, -1.12440001964569092f, -1.11389994621276855f, -1.10599994659423828f, -1.10010004043579102f, -1.09560000896453857f, -1.09230005741119385f, -1.09000003337860107f, -1.08829998970031738f, -1.08710002899169922f, -1.08640003204345703f, -1.08599996566772461f, -1.08580005168914795f, -1.08580005168914795f, -1.08599996566772461f, -1.0866999626159668f, -2.04089999198913574f, -1.80079996585845947f, -1.64869999885559082f, -1.53789997100830078f, -1.45539999008178711f, -1.392799973487854f, -1.34459996223449707f, -1.30700004100799561f, -1.27730000019073486f, -1.25380003452301025f, -1.23489999771118164f, -1.21959996223449707f, -1.20720005035400391f, -1.19700002670288086f, -1.18859994411468506f, -1.18169999122619629f, -1.17589998245239258f, -1.17100000381469727f, -1.16690003871917725f, -1.16349995136260986f, -1.16059994697570801f, -1.15810000896453857f, -1.15600001811981201f, -1.15470004081726074f, -2.43269991874694824f, -2.12700009346008301f, -1.93060004711151123f, -1.78569996356964111f, -1.67610001564025879f, -1.59159994125366211f, -1.52530002593994141f, -1.47249996662139893f, -1.4299999475479126f, -1.39540004730224609f, -1.36689996719360352f, -1.3432999849319458f, -1.32350003719329834f, -1.30680000782012939f, -1.29270005226135254f, -1.28059995174407959f, -1.27009999752044678f, -1.26110005378723145f, -1.25329995155334473f, -1.24639999866485596f, -1.24039995670318604f, -1.23500001430511475f, -1.23029994964599609f, -1.22669994831085205f, -2.87989997863769531f, -2.49659991264343262f, -2.24860000610351562f, -2.06410002708435059f, -1.92330002784729004f, -1.8135000467300415f, -1.72640001773834229f, -1.65620005130767822f, -1.59899997711181641f, -1.55169999599456787f, -1.51230001449584961f, -1.47909998893737793f, -1.45099997520446777f, -1.42690002918243408f, -1.40610003471374512f, -1.3881000280380249f, -1.37240004539489746f, -1.35860002040863037f, -1.34640002250671387f, -1.33570003509521484f, -1.32609999179840088f, -1.31749999523162842f, -1.30980002880096436f, -1.30359995365142822f, -3.39750003814697266f, -2.92090010643005371f, -2.6119999885559082f, -2.38100004196166992f, -2.20359992980957031f, -2.0643000602722168f, -1.95290005207061768f, -1.86249995231628418f, -1.7882000207901001f, -1.72619998455047607f, -1.67410004138946533f, -1.62989997863769531f, -1.59200000762939453f, -1.55929994583129883f, -1.53090000152587891f, -1.50610005855560303f, -1.48430001735687256f, -1.46500003337860107f, -1.44790005683898926f, -1.43260002136230469f, -1.4189000129699707f, -1.40649998188018799f, -1.39540004730224609f, -1.38629996776580811f, -4.00810003280639648f, -3.41639995574951172f, -3.03419995307922363f, -2.74749994277954102f, -2.52649998664855957f, -2.35209989547729492f, -2.21210002899169922f, -2.09780001640319824f, -2.00309991836547852f, -1.92390000820159912f, -1.85679996013641357f, -1.7994999885559082f, -1.75020003318786621f, -1.70739996433258057f, -1.66999995708465576f, -1.6371999979019165f, -1.60819995403289795f, -1.58239996433258057f, -1.55949997901916504f, -1.53890001773834229f, -1.52040004730224609f, -1.50370001792907715f, -1.48860001564025879f, -1.47609996795654297f, -4.7491002082824707f, -4.00920009613037109f, -3.53640007972717285f, -3.18140006065368652f, -2.90700006484985352f, -2.69000005722045898f, -2.5150001049041748f, -2.37150001525878906f, -2.25230002403259277f, -2.15199995040893555f, -2.06680011749267578f, -1.99370002746582031f, -1.93060004711151123f, -1.87559998035430908f, -1.82739996910095215f, -1.78489995002746582f, -1.74730002880096436f, -1.71379995346069336f, -1.68389999866485596f, -1.65699994564056396f, -1.63279998302459717f, -1.6109999418258667f, -1.59109997749328613f, -1.5746999979019165f, -5.68760013580322266f, -4.74030017852783203f, -4.15259981155395508f, -3.71110010147094727f, -3.36949992179870605f, -3.09859991073608398f, -2.87960004806518555f, -2.69939994812011719f, -2.54920005798339844f, -2.42239999771118164f, -2.31439995765686035f, -2.22140002250671387f, -2.1408998966217041f, -2.07069993019104004f, -2.00900006294250488f, -1.95459997653961182f, -1.90629994869232178f, -1.86329996585845947f, -1.82480001449584961f, -1.79030001163482666f, -1.75919997692108154f, -1.73099994659423828f, -1.70550000667572021f, -1.68429994583129883f, -6.68940019607543945f, -5.34350013732910156f, -4.86259984970092773f, -4.34409999847412109f, -3.93390011787414551f, -3.60269999504089355f, -3.33100008964538574f, -3.10509991645812988f, -2.91510009765625f, -2.75390005111694336f, -2.61590003967285156f, -2.49690008163452148f, -2.3935999870300293f, -2.30340003967285156f, -2.22420001029968262f, -2.15440011024475098f, -2.09240007400512695f, -2.03730010986328125f, -1.98800003528594971f, -1.94369995594024658f, -1.90390002727508545f, -1.86790001392364502f, -1.83480000495910645f, -1.8078000545501709f, -9.69550037384033203f, -7.62489986419677734f, -6.61070013046264648f, -5.72329998016357422f, -5.04829978942871094f, -4.52129983901977539f, -4.10120010375976562f, -3.76049995422363281f, -3.48009991645812988f, -3.24640011787414551f, -3.04959988594055176f, -2.88229990005493164f, -2.738800048828125f, -2.61479997634887695f, -2.50699996948242188f, -2.41269993782043457f, -2.32960009574890137f, -2.25620007514953613f, -2.19090008735656738f, -2.13269996643066406f, -2.08049988746643066f, -2.03349995613098145f, -1.99049997329711914f, -1.95369994640350342f
} };
__device__ __forceinline__ SheenProfile sheenProfile(float3  v_1, float3  n_i_1, BSDFMaterial material_3)
{
    SheenProfile _S375 = SheenProfile_x24init_0(false, 0.0f);
    float _S376 = rgb_to_greyscale(material_3.sheen);
    bool _S377 = _S376 > 0.0f;
    SheenProfile profile_0;
    if(_S377)
    {
        float _S378 = clamp_1((F32_sqrt(((F32_max((dot_0(n_i_1, v_1)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S379 = (U32_min((uint(_S378)), (22U)));
        float _S380 = (F32_sqrt((0.05000000074505806f)));
        float _S381 = (F32_sqrt((0.10000000149011612f)));
        bool _S382 = (material_3.velvet) > 0.0f;
        float _S383 = _slang_select(_S382, _S381,_S380);
        float _S384 = (clamp_1((F32_sqrt(((F32_max((material_3.sheen_roughness), (0.0f)))))), _S383, 1.0f) - _S383) / (1.0f - _S383) * 23.0f;
        uint _S385 = (U32_min((uint(_S384)), (22U)));
        uint _S386 = _S379 * 24U + _S385;
        float _S387 = _S378 - float(_S379);
        float _S388 = _S384 - float(_S385);
        if(_S382)
        {
            uint _S389 = _S386 + 24U;
            float _S390 = VELVET_ALBEDO_0[_S386] + (VELVET_ALBEDO_0[_S389] - VELVET_ALBEDO_0[_S386]) * _S387;
            uint _S391 = _S386 + 1U;
            float _S392 = VELVET_ALBEDO_0[_S391] + (VELVET_ALBEDO_0[_S389 + 1U] - VELVET_ALBEDO_0[_S391]) * _S387;
            SheenProfile _S393 = SheenProfile_x24init_0(true, _S390 + (_S392 - _S390) * _S388);
            profile_0 = _S393;
        }
        else
        {
            uint _S394 = _S386 + 24U;
            float _S395 = SHEEN_ALBEDO_0[_S386] + (SHEEN_ALBEDO_0[_S394] - SHEEN_ALBEDO_0[_S386]) * _S387;
            uint _S396 = _S386 + 1U;
            float _S397 = SHEEN_ALBEDO_0[_S396] + (SHEEN_ALBEDO_0[_S394 + 1U] - SHEEN_ALBEDO_0[_S396]) * _S387;
            SheenProfile _S398 = SheenProfile_x24init_0(true, (F32_exp((_S395 + (_S397 - _S395) * _S388))));
            profile_0 = _S398;
        }
    }
    else
    {
        profile_0 = _S375;
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
    Weights _S399;
    (&_S399)->v_dot_h = v_dot_h_0;
    (&_S399)->refracted = refracted_1;
    (&_S399)->F = F_0;
    (&_S399)->reflect_weight = reflect_weight_0;
    (&_S399)->diffuse_weight = diffuse_weight_0;
    (&_S399)->refract_weight = refract_weight_0;
    (&_S399)->p_diffuse = p_diffuse_0;
    (&_S399)->p_reflect = p_reflect_0;
    (&_S399)->p_refract = p_refract_0;
    (&_S399)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S399)->p_toon = p_toon_0;
    (&_S399)->sheen = sheen_0;
    (&_S399)->toon = toon_0;
    return _S399;
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
    float3  _S400 = make_float3 (alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z);
    float3  _S401 = ((((_S400)) * make_float3(rnorm3df(((_S400)).x, ((_S400)).y, ((_S400)).z))));
    float _S402 = _S401.x;
    float _S403 = _S401.y;
    float _S404 = _S402 * _S402 + _S403 * _S403;
    float3  _S405;
    if(_S404 > 0.0f)
    {
        float3  _S406 = make_float3 (- _S403, _S402, 0.0f);
        float _S407 = (rsqrtf((_S404)));
        _S405 = _S406 * make_float3 (_S407);
    }
    else
    {
        _S405 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S408 = cross_0(_S401, _S405);
    float _S409 = (F32_sqrt((U1_0)));
    float _S410 = 6.28318548202514648f * U2_0;
    float _S411 = _S409 * (F32_cos((_S410)));
    float t2_0 = _S409 * (F32_sin((_S410)));
    float _S412 = 0.5f * (1.0f + _S401.z);
    float t2_1 = (1.0f - _S412) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S411 * _S411)))))) + _S412 * t2_0;
    float3  _S413 = make_float3 (_S411) * _S405 + make_float3 (t2_1) * _S408;
    float _S414 = unshared_0(_S411);
    float _S415 = unshared_0(_S411);
    float3  _S416 = _S413 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S414 * _S415 - t2_1 * t2_1))))))) * _S401;
    float3  _S417 = make_float3 (alpha_0 * _S416.x, alpha_0 * _S416.y, (F32_max((0.0f), (_S416.z))));
    float3  _S418 = ((((_S417)) * make_float3(rnorm3df(((_S417)).x, ((_S417)).y, ((_S417)).z))));
    return _S418;
}

__device__ float3  worldToTangent(float3  v_2, float3  n_3)
{
    float3  a_3 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S419 = (F32_abs((dot_0(n_3, a_3)))) > 0.9999847412109375f;
    float3  a_4;
    if(_S419)
    {
        float3  _S420 = make_float3 (1.0f, 0.0f, 0.0f);
        a_4 = _S420;
    }
    else
    {
        a_4 = a_3;
    }
    float3  _S421 = cross_0(n_3, a_4);
    float3  _S422 = ((((_S421)) * make_float3(rnorm3df(((_S421)).x, ((_S421)).y, ((_S421)).z))));
    float3  _S423 = cross_0(n_3, _S422);
    return make_float3 (dot_0(v_2, _S422), dot_0(v_2, n_3), dot_0(v_2, _S423));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_3, float3  n_i_2, float alpha_1, AnisotropicFrame frame_0, uint * random_state_2)
{
    Random _S424 = draw(*random_state_2, 0U);
    Random _S425 = draw(*random_state_2, 2147483648U);
    *random_state_2 = _S425.state;
    float _S426 = frame_0.alphas.x;
    bool _S427 = _S426 > 0.0f;
    if(_S427)
    {
        float3  _S428 = anisotropicLocal(v_3, frame_0.tangent, n_i_2);
        float _S429 = frame_0.alphas.y;
        float3  _S430 = make_float3 (_S426 * _S428.x, _S429 * _S428.y, _S428.z);
        float3  _S431 = ((((_S430)) * make_float3(rnorm3df(((_S430)).x, ((_S430)).y, ((_S430)).z))));
        float3  _S432 = sampleGGXVNDF(_S431, 1.0f, _S424.value, _S425.value);
        float3  _S433 = make_float3 (_S426 * _S432.x, _S429 * _S432.y, _S432.z);
        float3  _S434 = ((((_S433)) * make_float3(rnorm3df(((_S433)).x, ((_S433)).y, ((_S433)).z))));
        return make_float3 (_S434.x) * frame_0.tangent + make_float3 (_S434.y) * cross_0(n_i_2, frame_0.tangent) + make_float3 (_S434.z) * n_i_2;
    }
    float3  _S435 = worldToTangent(v_3, n_i_2);
    float3  _S436 = sampleGGXVNDF(float3 {_S435.x, _S435.z, _S435.y}, alpha_1, _S424.value, _S425.value);
    float3  _S437 = float3 {_S436.x, _S436.z, _S436.y};
    float3  _S438 = tangentToWorld(_S437, n_i_2);
    return _S438;
}

__device__ __forceinline__ float3  sampledHalf(float3  v_4, float3  n_i_3, float alpha_2, AnisotropicFrame frame_1, uint random_state_3)
{
    uint state_3 = random_state_3;
    float3  _S439 = sampleHalfVector(v_4, n_i_3, alpha_2, frame_1, &state_3);
    return _S439;
}

__device__ __forceinline__ float3  refractedHalf(float3  in_dir_0, float3  out_dir_0, float3  n_4, float eta_i_0, float eta_o_0)
{
    float3  _S440 = negate_0(in_dir_0);
    float3  _S441 = negate_0(make_float3 (eta_i_0) * _S440 + make_float3 (eta_o_0) * out_dir_0);
    float3  _S442 = ((((_S441)) * make_float3(rnorm3df(((_S441)).x, ((_S441)).y, ((_S441)).z))));
    float _S443 = sign_0(dot_0(n_4, _S440));
    float _S444 = sign_0(dot_0(_S441, n_4 * make_float3 (_S443)));
    return _S442 * make_float3 (_S444);
}

__device__ __forceinline__ float3  reflectedHalf(float3  in_dir_1, float3  out_dir_1)
{
    float3  _S445 = negate_0(in_dir_1);
    float3  _S446 = _S445 + out_dir_1;
    float3  _S447 = ((((_S446)) * make_float3(rnorm3df(((_S446)).x, ((_S446)).y, ((_S446)).z))));
    return _S447;
}

static __device__ float3  refract_0(float3  i_5, float3  n_5, float eta_0)
{
    float _S448 = dot_0(n_5, i_5);
    float _S449 = 1.0f - eta_0 * eta_0 * (1.0f - _S448 * _S448);
    if(_S449 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_5 - make_float3 (eta_0 * _S448 + (F32_sqrt((_S449)))) * n_5;
}

__device__ float fresnel(float cos_theta_0, float eta_i_1, float eta_o_1)
{
    float _S450 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S451 = eta_i_1 / eta_o_1 * _S450;
    bool _S452 = _S451 < 1.0f;
    float kr_0;
    if(_S452)
    {
        float _S453 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S451 * _S451))))));
        float _S454 = eta_o_1 * cos_theta_0;
        float _S455 = eta_i_1 * _S453;
        float _S456 = (_S454 - _S455) / (_S454 + _S455);
        float _S457 = eta_i_1 * cos_theta_0;
        float _S458 = eta_o_1 * _S453;
        float _S459 = (_S457 - _S458) / (_S457 + _S458);
        float _S460 = (_S456 * _S456 + _S459 * _S459) / 2.0f;
        kr_0 = _S460;
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

__device__ __forceinline__ Weights lobeWeights(float3  in_dir_2, float3  v_5, float3  n_i_4, float3  ggx_n_0, AnisotropicFrame frame_2, SheenProfile sheen_profile_0, BSDFMaterial material_4, float eta_i_2, float eta_o_2)
{
    float _S461 = dot_0(ggx_n_0, v_5);
    float _S462 = eta_i_2 / eta_o_2;
    float3  _S463 = refract_0(in_dir_2, ggx_n_0, _S462);
    float3  _S464 = ((((_S463)) * make_float3(rnorm3df(((_S463)).x, ((_S463)).y, ((_S463)).z))));
    float _S465 = (F32_min(((F32_sqrt((material_4.specular_level))) * (F32_abs((eta_i_2 - eta_o_2))) / (eta_i_2 + eta_o_2)), (0.9999847412109375f)));
    float _S466 = _S465 * _S465;
    float _S467 = (1.0f + _S465) / (1.0f - _S465);
    float _S468 = (F32_abs((_S461)));
    bool _S469 = eta_i_2 > eta_o_2;
    float sheen_component_0;
    if(_S469)
    {
        sheen_component_0 = _S467;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    float toon_component_0;
    if(_S469)
    {
        toon_component_0 = 1.0f;
    }
    else
    {
        toon_component_0 = _S467;
    }
    float _S470 = fresnel(_S468, sheen_component_0, toon_component_0);
    bool _S471 = (eta_i_2 * eta_i_2 * (1.0f - _S461 * _S461)) >= (eta_o_2 * eta_o_2);
    float3  _S472;
    if(_S471)
    {
        _S472 = make_float3 (1.0f);
    }
    else
    {
        float3  _S473 = material_4.specular_tint * make_float3 (_S466);
        _S472 = _S473 + (make_float3 (1.0f) - _S473) * make_float3 (_S470 - _S466) / make_float3 (1.0f - _S466);
    }
    float3  _S474 = make_float3 (1.0f);
    float3  _S475 = make_float3 (0.0f);
    float3  sheen_1;
    float3  scale_1;
    if(sheen_profile_0.on)
    {
        float _S476 = (F32_min((sheen_profile_0.albedo), (1.0f)));
        float3  _S477 = make_float3 (1.0f) - material_4.sheen * make_float3 (_S476);
        float _S478 = rgb_to_greyscale(material_4.sheen);
        float _S479 = _S478 * _S476;
        float3  _S480 = material_4.sheen / make_float3 ((F32_max((sheen_profile_0.albedo), (1.0f))));
        sheen_component_0 = _S479;
        sheen_1 = _S480;
        scale_1 = _S477;
    }
    else
    {
        sheen_component_0 = 0.0f;
        sheen_1 = _S475;
        scale_1 = _S474;
    }
    float _S481 = (F32_abs((material_4.toon.x)));
    bool _S482 = _S481 > 0.0f;
    float3  toon_1;
    if(_S482)
    {
        float _S483 = (F32_min((_S481), (1.0f)));
        float3  scale_2 = scale_1 * make_float3 (1.0f - _S483);
        float _S484 = rgb_to_greyscale(material_4.albedo);
        float _S485 = _S483 * _S484;
        float3  _S486 = make_float3 (_S483) * material_4.albedo;
        toon_component_0 = _S485;
        toon_1 = _S486;
        scale_1 = scale_2;
    }
    else
    {
        toon_component_0 = 0.0f;
        toon_1 = _S475;
    }
    bool _S487 = (material_4.metallic) > 0.0f;
    float3  rebounce_0;
    if(_S487)
    {
        float _S488 = frame_2.alphas.x;
        float _S489 = (F32_sqrt(((F32_min((_S488), (frame_2.alphas.y))))));
        bool _S490 = _S488 > 0.0f;
        float _S491 = _slang_select(_S490, _S489,material_4.roughness);
        float _S492 = _S491 * _S491;
        float _S493 = (F32_pow((_S492), (1.81585001945495605f))) * (2.15371990203857422f - 0.73285001516342163f * _S492) / (1.0f + 1.28094995021820068f * _S492);
        bool _S494 = _S492 > 0.0f;
        float _S495 = _slang_select(_S494, _S493,0.0f);
        float _S496 = clamp_1(dot_0(n_i_4, v_5), 0.0f, 1.0f);
        float _S497 = _S492 * _S491;
        float _S498 = (F32_min((1.00064504146575928f - _S491 * (0.00375499995425344f + _S496 * (-0.04133399948477745f + _S496 * (-0.90938502550125122f + _S496 * 0.35275399684906006f))) - _S492 * (0.27602800726890564f + _S496 * (1.27023398876190186f + _S496 * 0.04740000143647194f)) - _S497 * (0.31452900171279907f - _S496 * 0.34830701351165771f) + _S497 * _S491 * 0.27229699492454529f), (1.0f)));
        float3  _S499 = min_1(make_float3 (1.0f) / (make_float3 (1.0f) - material_4.albedo * make_float3 (_S495)), make_float3 (1.0f / (F32_max((_S498), (0.0000152587890625f)))));
        rebounce_0 = _S499;
    }
    else
    {
        rebounce_0 = _S474;
    }
    float3  _S500 = mix_0(_S472, material_4.albedo * rebounce_0, material_4.metallic);
    float3  F_1 = _S500 * scale_1;
    float _S501 = rgb_to_greyscale(F_1);
    float _S502 = 1.0f - material_4.metallic;
    float3  _S503 = make_float3 (1.0f) - _S472;
    float3  _S504 = make_float3 ((1.0f - material_4.transmission) * _S502) * _S503 * scale_1;
    float3  _S505 = make_float3 (material_4.transmission * _S502) * _S503 * scale_1;
    float _S506 = (F32_max((_S501), (0.0f)));
    float _S507 = rgb_to_greyscale(_S504);
    float _S508 = (F32_max((_S507), (0.0f)));
    float _S509 = rgb_to_greyscale(_S505);
    float _S510 = sign_0(length_0(_S464));
    float _S511 = (F32_max((_S509 * _S510), (0.0f)));
    float _S512 = _S506 + _S508 + _S511 + toon_component_0;
    float _S513 = (F32_min((sheen_component_0), (1.0f)));
    bool _S514 = sheen_component_0 > 0.0f;
    bool _S515;
    if(_S514)
    {
        _S515 = !(_S512 > 0.0f);
    }
    else
    {
        _S515 = false;
    }
    float _S516 = _slang_select(_S515, 1.0f,_S513);
    float _S517 = (1.0f - _S516) / (F32_max((_S512), (0.0000152587890625f)));
    float _S518 = _S508 * _S517;
    float _S519 = _S506 * _S517;
    float _S520 = _S511 * _S517;
    return Weights_x24init_0(_S461, _S464, F_1, 1.0f, _S504, _S505, _S518, _S519, _S520, _S516, toon_component_0 * _S517, sheen_1, toon_1);
}

__device__ float translucentShare(BSDFMaterial material_5)
{
    float _S521 = rgb_to_greyscale(material_5.translucent);
    float _S522 = rgb_to_greyscale(material_5.albedo);
    float _S523 = _S521 / (_S522 + _S521);
    bool _S524 = _S521 > 0.0f;
    float _S525 = _slang_select(_S524, _S523,0.0f);
    return _S525;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float n_i_dot_v_0, BSDFMaterial material_6, Weights w_1)
{
    float _S526 = translucentShare(material_6);
    float _S527 = w_1.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S528 = w_1.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S529 = 1.0f - _S526;
    bool _S530 = n_i_dot_l_0 < 0.0f;
    float _S531 = _slang_select(_S530, _S526,_S529);
    float _S532 = _S528 * _S531;
    bool _S533 = _S526 > 0.0f;
    float _S534 = _slang_select(_S533, _S532,_S527);
    bool _S535 = n_i_dot_v_0 > 0.0f;
    float _S536 = _slang_select(_S535, _S534,0.0f);
    return _S536;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_5, BSDFMaterial material_7, Weights w_2)
{
    float _S537 = translucentShare(material_7);
    bool _S538 = (dot_0(n_i_5, l_0)) < 0.0f;
    float3  _S539 = _slang_select(_S538, material_7.translucent,material_7.albedo);
    float _S540 = 1.0f - _S537;
    float _S541 = _slang_select(_S538, _S537,_S540);
    float3  _S542 = _S539 / make_float3 (_S541);
    bool _S543 = _S537 > 0.0f;
    float3  _S544 = _slang_select(_S543, _S542,material_7.albedo);
    return w_2.diffuse_weight * _S544 / make_float3 (w_2.p_diffuse);
}

__device__ float smithG1(float alpha_3, float n_dot_x_0)
{
    float _S545 = alpha_3 * alpha_3;
    float _S546 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S545 + (1.0f - _S545) * n_dot_x_0 * n_dot_x_0))));
    bool _S547 = alpha_3 > 0.0f;
    float _S548 = _slang_select(_S547, _S546,1.0f);
    return _S548;
}

__device__ float trowbridgeReitz(float alpha_4, float n_dot_h_0)
{
    float _S549 = alpha_4 * alpha_4;
    float _S550 = (1.0f - n_dot_h_0) * (1.0f + n_dot_h_0) + _S549 * n_dot_h_0 * n_dot_h_0;
    return _S549 / (F32_max((3.14159274101257324f * _S550 * _S550), (1.17549435082228751e-38f)));
}

__device__ float anisotropicG1(float3  w_3, float2  alphas_1)
{
    float _S551 = (F32_max((w_3.z), (0.0f)));
    return 2.0f * _S551 / (_S551 + length_0(make_float3 (alphas_1.x * w_3.x, alphas_1.y * w_3.y, _S551)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_2)
{
    float _S552 = alphas_2.x;
    float _S553 = h_0.x / _S552;
    float _S554 = alphas_2.y;
    float _S555 = h_0.y / _S554;
    float _S556 = h_0.z;
    float _S557 = _S553 * _S553 + _S555 * _S555 + _S556 * _S556;
    return 1.0f / (F32_max((3.14159274101257324f * _S552 * _S554 * _S557 * _S557), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float3  v_6, float3  h_1, float3  n_i_6, float n_i_dot_v_1, float alpha_5, AnisotropicFrame frame_3, float v_dot_h_1)
{
    float _S558 = dot_0(n_i_6, h_1);
    float _S559 = smithG1(alpha_5, n_i_dot_v_1);
    float _S560 = _S559 * v_dot_h_1;
    float _S561 = trowbridgeReitz(alpha_5, _S558);
    float _S562 = _S560 * _S561 / n_i_dot_v_1;
    bool _S563 = alpha_5 > 0.0f;
    bool _S564;
    if(_S563)
    {
        _S564 = v_dot_h_1 > 0.0f;
    }
    else
    {
        _S564 = false;
    }
    if(_S564)
    {
        _S564 = _S558 > 0.0f;
    }
    else
    {
        _S564 = false;
    }
    if(_S564)
    {
        _S564 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S564 = false;
    }
    float _S565 = _slang_select(_S564, _S562,0.0f);
    bool _S566 = (frame_3.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S566)
    {
        float3  _S567 = anisotropicLocal(v_6, frame_3.tangent, n_i_6);
        float _S568 = anisotropicG1(_S567, frame_3.alphas);
        float3  _S569 = anisotropicLocal(h_1, frame_3.tangent, n_i_6);
        float _S570 = anisotropicD(_S569, frame_3.alphas);
        float _S571 = _S568 * _S570;
        float _S572 = _S571 * v_dot_h_1 / n_i_dot_v_1;
        bool _S573 = v_dot_h_1 > 0.0f;
        if(_S573)
        {
            _S564 = _S558 > 0.0f;
        }
        else
        {
            _S564 = false;
        }
        if(_S564)
        {
            _S564 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S564 = false;
        }
        float _S574 = _slang_select(_S564, _S572,0.0f);
        pdf_h_0 = _S574;
    }
    else
    {
        pdf_h_0 = _S565;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float l_dot_h_0, float pdf_h_1, Weights w_4, float eta_i_3, float eta_o_3)
{
    float _S575 = eta_i_3 * w_4.v_dot_h + eta_o_3 * l_dot_h_0;
    float _S576 = w_4.p_refract * pdf_h_1 * eta_o_3 * eta_o_3 * (F32_abs((l_dot_h_0))) / (_S575 * _S575);
    bool _S577 = eta_i_3 != eta_o_3;
    bool _S578;
    if(_S577)
    {
        _S578 = l_dot_h_0 < 0.0f;
    }
    else
    {
        _S578 = false;
    }
    float _S579 = _slang_select(_S578, _S576,0.0f);
    return _S579;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_7, float alpha_6, AnisotropicFrame frame_4, BSDFMaterial material_8, Weights w_5)
{
    float _S580 = - dot_0(n_i_7, l_1);
    float _S581 = smithG1(alpha_6, (F32_max((_S580), (0.0f))));
    bool _S582 = (frame_4.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S582)
    {
        float3  _S583 = negate_0(n_i_7);
        float3  _S584 = anisotropicLocal(l_1, frame_4.tangent, _S583);
        float _S585 = anisotropicG1(_S584, frame_4.alphas);
        G1_l_0 = _S585;
    }
    else
    {
        G1_l_0 = _S581;
    }
    return w_5.refract_weight * make_float3 (G1_l_0) * material_8.albedo / make_float3 (w_5.p_refract);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_1, float n_i_dot_v_2, Weights w_6)
{
    float _S586 = w_6.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S587 = n_i_dot_l_1 > 0.0f;
    bool _S588;
    if(_S587)
    {
        _S588 = n_i_dot_v_2 > 0.0f;
    }
    else
    {
        _S588 = false;
    }
    float _S589 = _slang_select(_S588, _S586,0.0f);
    return _S589;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  v_7, float3  n_i_8, BSDFMaterial material_9, Weights w_7)
{
    float3  _S590 = l_2 + v_7;
    float3  _S591 = ((((_S590)) * make_float3(rnorm3df(((_S590)).x, ((_S590)).y, ((_S590)).z))));
    float _S592 = dot_0(n_i_8, _S591);
    float _S593 = (F32_max((dot_0(n_i_8, l_2)), (0.0f)));
    float _S594 = (F32_max((dot_0(n_i_8, v_7)), (0.0f)));
    float _S595 = 1.0f / (F32_max((material_9.sheen_roughness), (0.05000000074505806f)));
    float _S596 = 1.0f - _S592 * _S592;
    float _S597 = (2.0f + _S595) * (F32_pow(((F32_max((_S596), (0.0f)))), (0.5f * _S595))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S593 + _S594 - _S593 * _S594)), (0.0000152587890625f)));
    bool _S598 = (material_9.velvet) > 0.0f;
    float f_1;
    if(_S598)
    {
        float _S599 = (F32_max((material_9.sheen_roughness), (0.00999999977648258f)));
        float _S600 = _S599 * _S599;
        float _S601 = (F32_max((_S596), (0.0000152587890625f)));
        float _S602 = (F32_exp((- _S592 * _S592 / (_S601 * _S600)))) / (3.14159274101257324f * _S600 * _S601 * _S601) * (F32_min((1.0f), (2.0f * _S592 * (F32_min((_S593), (_S594))) / (F32_max(((F32_abs((dot_0(_S591, v_7))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S593 * _S594), (0.0000152587890625f)));
        f_1 = _S602;
    }
    else
    {
        f_1 = _S597;
    }
    return w_7.sheen * make_float3 (f_1 * _S593 * 2.0f * 3.14159274101257324f / w_7.p_sheen_velvet);
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
    float _S603;
    if(t_13 < a_5)
    {
        _S603 = 1.0f;
    }
    else
    {
        _S603 = (F32_max((1.0f - (t_13 - a_5) / (F32_max((s_0), (0.0000152587890625f)))), (0.0f)));
    }
    return _S603;
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
        float _S604 = (F32_sin(((F32_min((t_14), (a_6))))));
        integral_0 = _S604 * _S604 / 2.0f;
    }
    bool _S605 = t_14 > a_6;
    bool _S606;
    if(_S605)
    {
        _S606 = s_1 > 0.0f;
    }
    else
    {
        _S606 = false;
    }
    if(_S606)
    {
        float _S607;
        if(glossy_0)
        {
            float _S608 = (F32_cos((a_6)));
            float _S609 = (F32_cos((t_14)));
            _S607 = (1.0f + a_6 / s_1) * (_S608 - _S609) - ((F32_sin((t_14))) - t_14 * _S609 - ((F32_sin((a_6))) - a_6 * _S608)) / s_1;
        }
        else
        {
            float _S610 = 2.0f * a_6;
            float _S611 = (F32_cos((_S610)));
            float _S612 = 2.0f * t_14;
            float _S613 = (F32_cos((_S612)));
            _S607 = (1.0f + a_6 / s_1) * (_S611 - _S613) / 4.0f - ((F32_sin((_S612))) / 8.0f - t_14 * _S613 / 4.0f - ((F32_sin((_S610))) / 8.0f - a_6 * _S611 / 4.0f)) / s_1;
        }
        float integral_1 = integral_0 + _S607;
        integral_0 = integral_1;
    }
    return integral_0;
}

static __device__ ToonProfile ToonProfile_x24init_0(bool glossy_1, float a_7, float s_2, float b_1, float norm_0, float view_0, float3  axis_0)
{
    ToonProfile _S614;
    (&_S614)->glossy = glossy_1;
    (&_S614)->a = a_7;
    (&_S614)->s = s_2;
    (&_S614)->b = b_1;
    (&_S614)->norm = norm_0;
    (&_S614)->view = view_0;
    (&_S614)->axis = axis_0;
    return _S614;
}

__device__ __forceinline__ ToonProfile toonProfile(float3  v_8, float3  n_i_9, BSDFMaterial material_10)
{
    float _S615 = material_10.toon.x;
    bool _S616 = _S615 < 0.0f;
    float _S617 = clamp_1(material_10.toon.y / _S615, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S618 = clamp_1(material_10.toon.z / _S615, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S619 = (F32_min((_S617 + _S618), (1.57079637050628662f)));
    float _S620 = dot_0(n_i_9, v_8);
    float _S621 = toonP((F32_acos(((F32_min((_S620), (1.0f)))))), _S617, _S618);
    float3  _S622;
    if(_S616)
    {
        float3  _S623 = make_float3 (2.0f * _S620) * n_i_9 - v_8;
        float3  _S624 = ((((_S623)) * make_float3(rnorm3df(((_S623)).x, ((_S623)).y, ((_S623)).z))));
        _S622 = _S624;
    }
    else
    {
        _S622 = n_i_9;
    }
    float _S625 = toonIntegral(_S619, _S617, _S618, _S616);
    return ToonProfile_x24init_0(_S616, _S617, _S618, _S619, 6.28318548202514648f * _S625, _S621, _S622);
}

__device__ __forceinline__ float toonPDF(float3  l_3, float3  n_i_10, ToonProfile profile_1, Weights w_8)
{
    float _S626 = dot_0(n_i_10, l_3);
    float _S627 = dot_0(l_3, profile_1.axis);
    float _S628 = _slang_select(profile_1.glossy, _S627,_S626);
    float _S629 = (F32_acos((clamp_1(_S628, -1.0f, 1.0f))));
    float _S630 = toonP(_S629, profile_1.a, profile_1.s);
    float _S631 = w_8.p_toon * _S630;
    float _S632 = _slang_select(profile_1.glossy, 1.0f,_S626);
    float _S633 = _S631 * _S632 / profile_1.norm;
    bool _S634;
    if(profile_1.glossy)
    {
        _S634 = true;
    }
    else
    {
        _S634 = _S626 > 0.0f;
    }
    float _S635 = _slang_select(_S634, _S633,0.0f);
    return _S635;
}

__device__ __forceinline__ float3  toonBSDF(float3  l_4, float3  n_i_11, ToonProfile profile_2, Weights w_9)
{
    float _S636 = (F32_max((dot_0(n_i_11, l_4)), (0.0f)));
    float _S637 = _slang_select(profile_2.glossy, _S636,profile_2.view);
    return w_9.toon * make_float3 (_S637) / make_float3 (w_9.p_toon);
}

__device__ __forceinline__ float reflectPDF(float pdf_h_2, Weights w_10)
{
    float _S638 = w_10.p_reflect * pdf_h_2 / (4.0f * w_10.v_dot_h);
    bool _S639 = pdf_h_2 > 0.0f;
    float _S640 = _slang_select(_S639, _S638,0.0f);
    return _S640;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_5, float3  n_i_12, float alpha_7, AnisotropicFrame frame_5, Weights w_11)
{
    float _S641 = dot_0(n_i_12, l_5);
    float _S642 = smithG1(alpha_7, (F32_max((_S641), (0.0f))));
    bool _S643 = (frame_5.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S643)
    {
        float3  _S644 = anisotropicLocal(l_5, frame_5.tangent, n_i_12);
        float _S645 = anisotropicG1(_S644, frame_5.alphas);
        G1_l_1 = _S645;
    }
    else
    {
        G1_l_1 = _S642;
    }
    return make_float3 (w_11.reflect_weight * G1_l_1) * w_11.F / make_float3 (w_11.p_reflect);
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_3, float3  out_dir_2, float3  n_6, BSDFMaterial material_11, float eta_i_4, float eta_o_4, bool refracted_2, uint random_state_4, FixedArray<float3 , 5>  * throughputs_0, FixedArray<float, 5>  * pdfs_0)
{
    float3  ggx_n_1;
    float3  _S646 = negate_0(in_dir_3);
    float _S647 = dot_0(n_6, _S646);
    float _S648 = sign_0(_S647);
    float3  _S649 = n_6 * make_float3 (_S648);
    float _S650 = dot_0(_S649, out_dir_2);
    float _S651 = material_11.roughness;
    float _S652 = _S651 * _S651;
    AnisotropicFrame _S653 = anisotropicFrame(material_11, _S649);
    SheenProfile _S654 = sheenProfile(_S646, _S649, material_11);
    float _S655 = rgb_to_greyscale(material_11.translucent);
    bool _S656 = _S655 > 0.0f;
    bool _S657 = (dot_0(n_6, out_dir_2) * _S647) < 0.0f;
    bool _S658 = (F32_abs((material_11.toon.x))) > 0.0f;
    uint _S659;
    if(_S658)
    {
        _S659 = 5U;
    }
    else
    {
        _S659 = 4U;
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
        float3  _S660 = make_float3 (0.0f);
        (*throughputs_0)[i_7] = _S660;
        (*pdfs_0)[i_7] = 0.0f;
        uint i_8 = i_7 + 1U;
        i_7 = i_8;
    }
    float3  _S661 = make_float3 (0.0f);
    Weights _S662 = Weights_x24init_0(0.0f, _S661, _S661, 0.0f, _S661, _S661, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, _S661, _S661);
    uint half_of_0 = 4294967295U;
    Weights w_12 = _S662;
    float3  ggx_n_2 = _S661;
    i_7 = 0U;
    for(;;)
    {
        if(i_7 < _S659)
        {
        }
        else
        {
            break;
        }
        uint _S663;
        if(i_7 == 3U)
        {
            _S663 = 4U;
        }
        else
        {
            if(i_7 == 4U)
            {
                _S663 = 6U;
            }
            else
            {
                _S663 = i_7;
            }
        }
        bool _S664 = _S663 == 0U;
        bool _S665;
        if(_S664)
        {
            _S665 = _S656;
        }
        else
        {
            _S665 = false;
        }
        bool _S666;
        if(_S665)
        {
            _S666 = _S657;
        }
        else
        {
            _S666 = _S663 == 1U;
        }
        bool _S667 = _S666 != refracted_2;
        if(_S667)
        {
            ggx_n_1 = ggx_n_2;
            uint i_9 = i_7 + 1U;
            ggx_n_2 = ggx_n_1;
            i_7 = i_9;
            continue;
        }
        uint _S668;
        if(_S663 == 6U)
        {
            _S668 = 0U;
        }
        else
        {
            if(_S663 == 4U)
            {
                _S668 = 2U;
            }
            else
            {
                _S668 = _S663;
            }
        }
        bool _S669 = _S668 != half_of_0;
        uint half_of_1;
        Weights w_13;
        if(_S669)
        {
            bool _S670 = _S668 == 0U;
            if(_S670)
            {
                float3  _S671 = sampledHalf(_S646, _S649, _S652, _S653, random_state_4);
                ggx_n_1 = _S671;
            }
            else
            {
                bool _S672 = _S668 == 1U;
                if(_S672)
                {
                    float3  _S673 = refractedHalf(in_dir_3, out_dir_2, n_6, eta_i_4, eta_o_4);
                    ggx_n_1 = _S673;
                }
                else
                {
                    float3  _S674 = reflectedHalf(in_dir_3, out_dir_2);
                    ggx_n_1 = _S674;
                }
            }
            Weights _S675 = lobeWeights(in_dir_3, _S646, _S649, ggx_n_1, _S653, _S654, material_11, eta_i_4, eta_o_4);
            w_13 = _S675;
            half_of_1 = _S668;
        }
        else
        {
            w_13 = w_12;
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S663)
        {
        case 0U:
            {
                float _S676 = diffusePDF(_S650, (F32_abs((_S647))), material_11, w_13);
                (*pdfs_0)[int(0)] = _S676;
                float3  _S677 = diffuseBSDF(out_dir_2, _S649, material_11, w_13);
                (*throughputs_0)[int(0)] = _S677;
                break;
            }
        case 1U:
            {
                float _S678 = dot_0(out_dir_2, ggx_n_1);
                float _S679 = vndfPDF(_S646, ggx_n_1, _S649, (F32_abs((_S647))), _S652, _S653, w_13.v_dot_h);
                float _S680 = refractPDF(_S678, _S679, w_13, eta_i_4, eta_o_4);
                (*pdfs_0)[int(1)] = _S680;
                float3  _S681 = refractBSDF(out_dir_2, _S649, _S652, _S653, material_11, w_13);
                (*throughputs_0)[int(1)] = _S681;
                break;
            }
        case 4U:
            {
                float _S682 = sheenVelvetPDF(_S650, (F32_abs((_S647))), w_13);
                (*pdfs_0)[int(3)] = _S682;
                float3  _S683 = sheenVelvetBSDF(out_dir_2, _S646, _S649, material_11, w_13);
                (*throughputs_0)[int(3)] = _S683;
                break;
            }
        case 6U:
            {
                ToonProfile _S684 = toonProfile(_S646, _S649, material_11);
                float _S685 = toonPDF(out_dir_2, _S649, _S684, w_13);
                (*pdfs_0)[int(4)] = _S685;
                float3  _S686 = toonBSDF(out_dir_2, _S649, _S684, w_13);
                (*throughputs_0)[int(4)] = _S686;
                break;
            }
        default:
            {
                float _S687 = vndfPDF(_S646, ggx_n_1, _S649, (F32_abs((_S647))), _S652, _S653, w_13.v_dot_h);
                float _S688 = reflectPDF(_S687, w_13);
                (*pdfs_0)[int(2)] = _S688;
                float3  _S689 = reflectBSDF(out_dir_2, _S649, _S652, _S653, w_13);
                (*throughputs_0)[int(2)] = _S689;
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
    ggx_n_1 = _S661;
    for(;;)
    {
        if(i_7 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S690 = ((*pdfs_0)[i_7]) > 0.0f;
        if(_S690)
        {
            float3  f_2 = ggx_n_1 + (*throughputs_0)[i_7] * make_float3 ((*pdfs_0)[i_7]);
            ggx_n_1 = f_2;
        }
        uint i_10 = i_7 + 1U;
        i_7 = i_10;
    }
    return ggx_n_1;
}

static __device__ __forceinline__ float3  skyLobes_0(float3  in_dir_4, float3  dir_3, FKSurface * surface_1, BSDFMaterial * material_12, float2  eta_1, bool is_inside_2, float pdf_0, uint random_state_5, FixedArray<float3 , 5>  * terms_0, FixedArray<float, 5>  * pdfs_1)
{
    bool _S691 = wrongSide_0(is_inside_2, false, dir_3, surface_1->geometry_n);
    float3  _S692 = BSDF(in_dir_4, dir_3, surface_1->smooth_n, *material_12, eta_1.x, eta_1.y, _S691, random_state_5, terms_0, pdfs_1);
    float3  _S693 = make_float3 (0.0f);
    uint i_11 = 0U;
    float3  f_3 = _S693;
    for(;;)
    {
        if(i_11 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S694 = ((*pdfs_1)[i_11]) > 0.0f;
        if(_S694)
        {
            float3  _S695 = (*terms_0)[i_11] * make_float3 ((*pdfs_1)[i_11]) / make_float3 ((*pdfs_1)[i_11] + pdf_0);
            (*terms_0)[i_11] = _S695;
            float3  f_4 = f_3 + (*terms_0)[i_11];
            f_3 = f_4;
        }
        uint i_12 = i_11 + 1U;
        i_11 = i_12;
    }
    return f_3;
}

__device__ float3  skyBSDF(float3  in_dir_5, float3  dir_4, FKSurface surface_2, BSDFMaterial material_13, float2  eta_2, bool is_inside_3, float pdf_1, uint random_state_6)
{
    FKSurface _S696 = surface_2;
    BSDFMaterial _S697 = material_13;
    FixedArray<float3 , 5>  terms_1;
    FixedArray<float, 5>  pdfs_2;
    float3  _S698 = skyLobes_0(in_dir_5, dir_4, &_S696, &_S697, eta_2, is_inside_3, pdf_1, random_state_6, &terms_1, &pdfs_2);
    return _S698;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_5, float3  radiance_0, float3  color_0, uint random_state_7)
{
    SkySample _S699;
    (&_S699)->dir = dir_5;
    (&_S699)->radiance = radiance_0;
    (&_S699)->color = color_0;
    (&_S699)->random_state = random_state_7;
    return _S699;
}

static __device__ __noinline__ float3  skyColor_0(float3  in_dir_6, float3  dir_6, FKSurface * surface_3, float wavelength_3, float2  eta_3, bool is_inside_4, float pdf_2, uint random_state_8, uint depth_0)
{
    BSDFMaterial _S700 = pathMaterial(surface_3->material, wavelength_3);
    BSDFMaterial _S701 = _S700;
    FixedArray<float3 , 5>  terms_2;
    FixedArray<float, 5>  pdfs_3;
    float3  _S702 = skyLobes_0(in_dir_6, dir_6, surface_3, &_S701, eta_3, is_inside_4, pdf_2, random_state_8, &terms_2, &pdfs_3);
    float3  _S703 = make_float3 (0.0f);
    bool shaded_0 = false;
    float3  world_0 = _S703;
    uint i_13 = 0U;
    float3  color_1 = _S703;
    for(;;)
    {
        if(i_13 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S704 = (pdfs_3[i_13]) > 0.0f;
        if(_S704)
        {
            bool _S705 = (fcptWorldReadsPath());
            bool _S706;
            if(_S705)
            {
                _S706 = true;
            }
            else
            {
                _S706 = !shaded_0;
            }
            bool shaded_1;
            float3  world_1;
            if(_S706)
            {
                uint _S707;
                if(i_13 == 3U)
                {
                    _S707 = 4U;
                }
                else
                {
                    if(i_13 == 4U)
                    {
                        _S707 = 6U;
                    }
                    else
                    {
                        _S707 = i_13;
                    }
                }
                float3  _S708 = (fcptEnvMapSample((dir_6), (depth_0), (_S707)));
                world_1 = _S708;
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

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_4, float wavelength_4, float2  eta_4, bool is_inside_5, uint init_random_state_0, uint lobe_state_0, ShadowContext * context_2)
{
    uint2  _S709 = (fcptEnvironmentCdfSize());
    uint2  _S710 = make_uint2 (1U, 0U);
    uint2  _S711 = _S709 - _S710;
    Random _S712 = draw(init_random_state_0, 6U);
    Random _S713 = draw(init_random_state_0, 2147483654U);
    Random _S714 = draw(init_random_state_0, 7U);
    Random _S715 = draw(init_random_state_0, 2147483655U);
    uint _S716 = _S711.x;
    uint _S717 = searchCDF_0(make_uint2 (_S716, 0U), make_uint2 (0U, 1U), _S711.y, _S712.value);
    uint _S718 = searchCDF_0(make_uint2 (0U, _S717), _S710, _S716, _S713.value);
    float2  _S719 = make_float2 ((float)_S711.x, (float)_S711.y);
    float2  _S720 = (make_float2 (float(_S718), float(_S717)) + make_float2 (_S714.value, _S715.value)) / _S719 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S721 = _S720.y;
    float _S722 = (F32_sin((_S721)));
    float _S723 = _S720.x;
    float3  _S724 = make_float3 (- _S722 * (F32_cos((_S723))), _S722 * (F32_sin((_S723))), (F32_cos((_S721))));
    float _S725 = environmentPdf_0(_S724);
    BSDFMaterial _S726 = pathMaterial(surface_4->material, wavelength_4);
    float3  _S727 = ray_0->unit_direction;
    float3  _S728 = skyBSDF(ray_0->unit_direction, _S724, *surface_4, _S726, eta_4, is_inside_5, _S725, lobe_state_0);
    bool _S729 = !(_S725 > 0.0f);
    bool _S730;
    if(_S729)
    {
        _S730 = true;
    }
    else
    {
        _S730 = all_1(_S728 == make_float3 (0.0f));
    }
    if(_S730)
    {
        float3  _S731 = make_float3 (0.0f);
        return SkySample_x24init_0(_S724, _S731, _S731, _S715.state);
    }
    bool _S732 = (fcptWorldReadsPath());
    float3  seen_0;
    if(_S732)
    {
        float3  _S733 = skyColor_0(_S727, _S724, surface_4, wavelength_4, eta_4, is_inside_5, _S725, lobe_state_0, context_2->depth + 1U);
        seen_0 = _S733;
    }
    else
    {
        seen_0 = _S728;
    }
    float3  _S734 = skyRadiance_0(ray_0->origin, surface_4, is_inside_5, _S724, context_2, _S715.state);
    return SkySample_x24init_0(_S724, _S734, seen_0 * _S734, _S715.state);
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
    SampleBSDF _S735 = (fcptConnectHair((surface_5->hair), ((&surface_5->material)->albedo), ((&surface_5->material)->specular_tint), (in_dir_7), (light_1->dir)));
    float3  _S736 = _S735.throughput * make_float3 (_S735.pdf);
    float _S737 = light_1->density;
    float _S738 = 1.0f + _S735.pdf * _S735.pdf / (light_1->density * light_1->density);
    bool _S739;
    if(competing_0)
    {
        _S739 = _S737 > 0.0f;
    }
    else
    {
        _S739 = false;
    }
    float _S740 = _slang_select(_S739, _S738,1.0f);
    return _S736 / make_float3 (_S740) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_7, float3  radiance_1, float density_0, uint random_state_9)
{
    TreeSample _S741;
    (&_S741)->dir = dir_7;
    (&_S741)->radiance = radiance_1;
    (&_S741)->density = density_0;
    (&_S741)->random_state = random_state_9;
    return _S741;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_12, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S742 = importance(first_1, p_12, normal_3);
    float _S743 = importance(second_1, p_12, normal_3);
    float2  _S744 = make_float2 (_S742, _S743);
    bool _S745 = _S742 == 0.0f;
    bool _S746;
    if(_S745)
    {
        _S746 = _S743 == 0.0f;
    }
    else
    {
        _S746 = false;
    }
    if(_S746)
    {
        return 2U;
    }
    float _S747 = _S742 + _S743;
    bool _S748 = _S743 > 0.0f;
    if(_S748)
    {
        _S746 = (*pick_0 * _S747) >= _S742;
    }
    else
    {
        _S746 = false;
    }
    uint _S749 = uint(_S746);
    float _S750 = (F32_min(((*pick_0 * _S747 - float(_S749) * _S742) / _slang_vector_get_element(_S744, _S749)), (0.99999994039535522f)));
    *pick_0 = _S750;
    float _S751 = *probability_3 * (_slang_vector_get_element(_S744, _S749) / _S747);
    *probability_3 = _S751;
    return _S749;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_13, float u1_0, float u2_0)
{
    float3  _S752 = center_1 - p_13;
    float _S753 = radius_1 * radius_1 / dot_0(_S752, _S752);
    float _S754 = u1_0 * _S753 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S753), (0.0f)))))));
    float _S755 = 2.0f * u1_0;
    bool _S756 = _S753 >= 1.0f;
    float _S757 = _slang_select(_S756, _S755,_S754);
    float _S758 = (F32_sqrt(((F32_max((_S757 * (2.0f - _S757)), (0.0f))))));
    float _S759 = 6.28318548202514648f * u2_0;
    float3  _S760 = make_float3 (_S758 * (F32_cos((_S759))), 1.0f - _S757, _S758 * (F32_sin((_S759))));
    float3  _S761 = ((((_S752)) * make_float3(rnorm3df(((_S752)).x, ((_S752)).y, ((_S752)).z))));
    float3  _S762 = tangentToWorld(_S760, _S761);
    return _S762;
}

__device__ float3  pointLightRadiance(float3  color_3, float intensity_0, float radius_2)
{
    return color_3 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S763 = center_2 - ray_1->origin;
    float _S764 = dot_0(_S763, ray_1->unit_direction);
    float _S765 = dot_0(_S763, _S763) - _S764 * _S764;
    float _S766 = radius_3 * radius_3;
    bool _S767 = _S765 > _S766;
    if(_S767)
    {
        return 4.294967296e+09f;
    }
    float _S768 = (F32_sqrt((_S766 - _S765)));
    float _S769 = _S764 - _S768;
    float _S770 = _S764 + _S768;
    bool _S771 = _S769 > 0.0000152587890625f;
    bool _S772;
    if(_S771)
    {
        _S772 = _S769 < max_len_0;
    }
    else
    {
        _S772 = false;
    }
    if(_S772)
    {
        return _S769;
    }
    bool _S773 = _S770 > 0.0000152587890625f;
    if(_S773)
    {
        _S772 = _S770 < max_len_0;
    }
    else
    {
        _S772 = false;
    }
    if(_S772)
    {
        return _S770;
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
    Random _S774 = draw(init_random_state_1, 4U);
    Random _S775 = draw(init_random_state_1, 5U);
    Random _S776 = draw(init_random_state_1, 2147483653U);
    float3  _S777 = make_float3 (0.0f);
    TreeSample _S778 = TreeSample_x24init_0(_S777, _S777, 0.0f, _S776.state);
    TreeSample sample_0 = _S778;
    float3  _S779 = _slang_select(sided_0, _S777,smooth_n_2);
    float3  _S780 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S774.value;
    float probability_4 = 1.0f;
    uint n_7 = 0U;
    for(;;)
    {
        uint4  _S781 = (fcptLightNode((n_7)));
        if((_S781.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S782 = (fcptLightSecond((n_7)));
        uint _S783 = n_7 + 1U;
        LightNode _S784 = (fcptLightBounds((_S783)));
        LightNode _S785 = (fcptLightBounds((_S782)));
        uint _S786 = pickChild(_S784, _S785, origin_4, _S779, &pick_1, &probability_4);
        bool _S787 = _S786 > 1U;
        if(_S787)
        {
            return sample_0;
        }
        bool _S788 = _S786 == 1U;
        uint _S789 = _slang_select(_S788, _S782,_S783);
        n_7 = _S789;
    }
    bool _S790 = n_7 == 0U;
    bool _S791;
    if(_S790)
    {
        LightNode _S792 = (fcptLightBounds((0U)));
        float _S793 = importance(_S792, origin_4, _S779);
        _S791 = !(_S793 > 0.0f);
    }
    else
    {
        _S791 = false;
    }
    if(_S791)
    {
        return sample_0;
    }
    uint4  _S794 = (fcptLightNode((n_7)));
    FKHit _S795 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S796 = (_S794.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S796)
    {
        FKLight _S797 = (fcptLight((_S794.y)));
        if(sided_0)
        {
            float _S798 = sign_0(dot_0(geometry_n_1, _S797.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S798);
            float3  _S799 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S799;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S780;
            lift_n_0 = smooth_n_2;
        }
        bool _S800 = (_S797.variance) == 0.0f;
        if(_S800)
        {
            float3  _S801 = _S797.position - emitter_point_0;
            float3  _S802 = ((((_S801)) * make_float3(rnorm3df(((_S801)).x, ((_S801)).y, ((_S801)).z))));
            (&sample_0)->dir = _S802;
            float3  _S803 = _S797.color * make_float3 (_S797.intensity) / make_float3 (dot_0(_S801, _S801) * probability_4);
            (&sample_0)->radiance = _S803;
            shadow_1 = _S801;
        }
        else
        {
            float3  _S804 = sampleSphere(_S797.position, _S797.variance, emitter_point_0, _S775.value, _S776.value);
            (&sample_0)->dir = _S804;
            float _S805 = sphereDensity(_S797.position, _S797.variance, emitter_point_0);
            float _S806 = probability_4 * _S805;
            (&sample_0)->density = _S806;
            float3  _S807 = pointLightRadiance(_S797.color, _S797.intensity, _S797.variance);
            float3  _S808 = _S807 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S808;
            FKRay _S809 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S810 = raySphere_0(_S797.position, _S797.variance, &_S809, 4.294967296e+09f);
            float3  _S811 = (&sample_0)->dir * make_float3 (_S810);
            shadow_1 = _S811;
        }
        emitter_0 = _S795;
        emitter_point_0 = _S777;
    }
    else
    {
        uint _S812 = _S794.y;
        uint _S813 = (fcptTriangleOffset((_S812)));
        uint _S814 = _S813 + _S794.z;
        Matrix<float, 3, 3>  _S815 = (fcptWorldTriangle((_S812), (_S814)));
        float _S816 = (F32_sqrt((_S775.value)));
        float2  _S817 = make_float2 (_S816 * (1.0f - _S776.value), _S816 * _S776.value);
        float3  _S818 = mul_0(make_float3 (1.0f - _S816, _S817.x, _S817.y), _S815);
        if(sided_0)
        {
            float _S819 = sign_0(dot_0(geometry_n_1, _S818 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S819);
            float3  _S820 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S820;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S821 = !((dot_0(smooth_n_2, _S818 - origin_4)) > 0.0f);
            if(_S821)
            {
                return sample_0;
            }
            emitter_point_0 = _S780;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S817, _S812, _S814, 0U, 0.0f);
        float3  _S822 = _S818 - emitter_point_0;
        float3  _S823 = ((((_S822)) * make_float3(rnorm3df(((_S822)).x, ((_S822)).y, ((_S822)).z))));
        (&sample_0)->dir = _S823;
        float _S824 = solidAngle(probability_4, cross_0(_S815.rows[int(1)] - _S815.rows[int(0)], _S815.rows[int(2)] - _S815.rows[int(0)]), _S822);
        (&sample_0)->density = _S824;
        bool _S825 = (fcptShadowFirst());
        bool _S826 = !_S825;
        if(_S826)
        {
            FKSurface _S827 = (fcptLightSurfaceAt((emitter_1), (_S818), (_S776.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S818 - origin_4))));
            (&sample_0)->random_state = _S827.random_state;
            float3  _S828 = _slang_select(_S827.skip, _S777,_S827.material.emissive);
            float3  _S829 = _S828 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S829;
        }
        shadow_1 = _S822;
        emitter_0 = emitter_1;
        emitter_point_0 = _S818;
    }
    FKHit _S830 = emitter_0;
    float3  _S831 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S776.state, &_S830);
    bool _S832 = (fcptShadowFirst());
    if(_S832)
    {
        _S791 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S791 = false;
    }
    if(_S791)
    {
        _S791 = !all_1(_S831 == _S777);
    }
    else
    {
        _S791 = false;
    }
    if(_S791)
    {
        FKSurface _S833 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S776.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S833.random_state;
        float3  _S834 = _slang_select(_S833.skip, _S777,_S833.material.emissive);
        float3  _S835 = _S834 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S835;
    }
    float3  _S836 = (&sample_0)->radiance * _S831;
    bool _S837 = all_1(_S831 == _S777);
    float3  _S838 = _slang_select(_S837, _S777,_S836);
    (&sample_0)->radiance = _S838;
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
    float _S839 = 1.0f / (1.0f + b_2 / a_8 * (b_2 / a_8));
    bool _S840 = b_2 > 0.0f;
    float _S841 = _slang_select(_S840, _S839,1.0f);
    return _S841;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S842 = vertex_0->none;
    if(_S842)
    {
        return 1.0f;
    }
    uint _S843 = (fcptLightSlot((*hit_1)));
    float _S844 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S843, light_point_1);
    float _S845 = powerHeuristic(vertex_0->pdf, _S844);
    return _S845;
}

static __device__ float3  environment_0(float3  dir_8, uint depth_1, uint lobe_0)
{
    uint2  _S846 = (fcptEnvironmentMapSize());
    bool _S847 = (_S846.x) > 1U;
    bool _S848;
    if(_S847)
    {
        uint2  _S849 = (fcptEnvironmentMapSize());
        _S848 = (_S849.y) > 1U;
    }
    else
    {
        _S848 = false;
    }
    if(_S848)
    {
        float3  _S850 = (fcptEnvMapSample((dir_8), (depth_1), (lobe_0)));
        return _S850;
    }
    float3  _S851 = (fcptAmbient());
    return _S851;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S852 = (fcptEnvironmentCdfSize());
    bool _S853 = (_S852.x) > 1U;
    bool _S854;
    if(_S853)
    {
        uint2  _S855 = (fcptEnvironmentCdfSize());
        _S854 = (_S855.y) > 1U;
    }
    else
    {
        _S854 = false;
    }
    bool _S856 = !_S854;
    if(_S856)
    {
        return false;
    }
    uint2  _S857 = (fcptEnvironmentMapSize());
    bool _S858 = (_S857.x) > 1U;
    if(_S858)
    {
        uint2  _S859 = (fcptEnvironmentMapSize());
        _S854 = (_S859.y) > 1U;
    }
    else
    {
        _S854 = false;
    }
    return _S854;
}

static __device__ float escapeWeight_0(float pdf_3, float3  dir_9)
{
    bool _S860 = pdf_3 <= 0.0f;
    bool _S861;
    if(_S860)
    {
        _S861 = true;
    }
    else
    {
        bool _S862 = environmentMapped_0();
        _S861 = !_S862;
    }
    if(_S861)
    {
        return 1.0f;
    }
    float _S863 = environmentPdf_0(dir_9);
    return pdf_3 / (pdf_3 + _S863);
}

static __device__ void restir_duplicates_0(uint3  global_invocation_id_1, uint3  local_invocation_id_0, uint local_invocation_index_3)
{
    uint2  _S864 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S865 = make_int2 ((int)_S864.x, (int)_S864.y);
    uint _S866 = previousSeed_0(_S865);
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
            uint _S867 = previousSeed_0(_S865 + make_int2 (x_16, y_5));
            bool _S868 = _S867 == _S866;
            uint _S869 = _slang_select(_S868, 1U,0U);
            uint count_3 = count_2 + _S869;
            int x_17 = x_16 + int(1);
            x_16 = x_17;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S870 = float(count_2 - 1U) / 288.0f;
    bool _S871 = _S866 != 0U;
    float _S872 = _slang_select(_S871, _S870,0.0f);
    fcptStoreDuplication((_S865), (make_uint4 ((F32_asuint((_S872))), 0U, 0U, 0U)));
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
    float _S873 = rgb_to_greyscale(abs_0(f_5));
    return _S873;
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
    float _S874 = resamplingTarget(weight_0);
    bool _S875 = _S874 > 0.0f;
    bool _S876;
    if(_S875)
    {
        _S876 = _S874 < 3.00000000549775576e+38f;
    }
    else
    {
        _S876 = false;
    }
    bool _S877 = !_S876;
    if(_S877)
    {
        return;
    }
    bool _S878 = sel_2->sums;
    if(_S878)
    {
        float3  _S879 = sel_2->color + weight_0;
        sel_2->color = _S879;
        return;
    }
    float _S880 = sel_2->w_sum + _S874;
    sel_2->w_sum = _S880;
    float3  _S881 = sel_2->color + weight_0;
    sel_2->color = _S881;
    Random _S882 = pcg(sel_2->random_state);
    sel_2->random_state = _S882.state;
    bool _S883 = (_S882.value * sel_2->w_sum) <= _S874;
    if(_S883)
    {
        sel_2->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_3;
    float3  _S884 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S884;
    float _S885 = r_3.jac * shifted_0.jac;
    (&candidate_1)->jac = _S885;
    offer(sel_3, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S886 = resamplingTarget((&r_4)->f);
    float _S887 = sel_4.w_sum / _S886;
    bool _S888 = _S886 > 0.0f;
    float _S889 = _slang_select(_S888, _S887,0.0f);
    (&r_4)->w = _S889;
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
    uint2  _S890 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S891 = make_int2 ((int)_S890.x, (int)_S890.y);
    float3  _S892 = make_float3 (0.0f);
    FKHit _S893 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S894 = Domain_x24init_0(_S892, _S892, &_S893, 0.0f, 0.0f);
    Domain dom_4 = _S894;
    bool _S895 = (fcptCurrentDomain((_S891), (&dom_4)));
    bool _S896 = !_S895;
    if(_S896)
    {
        Reservoir _S897 = (Reservoir{});
        fcptStoreReservoirPrevious((_S891), (_S897), ((&dom_4)->hit));
        return;
    }
    Reservoir _S898 = (fcptLoadReservoirTemporal((_S891)));
    uint t_15 = 0U;
    float count_4 = 0.0f;
    float c_sum_1 = _S898.c;
    for(;;)
    {
        uint _S899 = (fcptRestirNeighbours());
        if(t_15 < _S899)
        {
        }
        else
        {
            break;
        }
        int2  _S900 = partner_0(_S891, t_15);
        Domain neighbor_0 = _S894;
        bool _S901 = (fcptCurrentDomain((_S900), (&neighbor_0)));
        if(_S901)
        {
            float count_5 = count_4 + 1.0f;
            uint4  _S902 = (fcptReservoirTemporal((_S900), (0U)));
            float c_sum_2 = c_sum_1 + (U32_asfloat((_S902.w)));
            count_4 = count_5;
            c_sum_1 = c_sum_2;
        }
        uint t_16 = t_15 + 1U;
        t_15 = t_16;
    }
    float _S903 = _S898.c / (F32_max((count_4), (1.0f)));
    float _S904 = resamplingTarget(_S898.f);
    bool _S905 = count_4 == 0.0f;
    float _S906 = _slang_select(_S905, 1.0f,0.0f);
    Selection _S907 = (Selection{});
    Selection sel_5 = _S907;
    uint _S908 = (fcptFrame());
    uint _S909 = hash(_S908);
    uint _S910 = global_invocation_id_2.x;
    uint2  _S911 = (fcptRenderSize());
    uint _S912 = stream(_S909, _S910 + _S911.x * global_invocation_id_2.y);
    uint _S913 = stream(_S912, 195U);
    (&sel_5)->random_state = _S913;
    t_15 = 0U;
    float canonical_mis_0 = _S906;
    for(;;)
    {
        uint _S914 = (fcptRestirNeighbours());
        if(t_15 < _S914)
        {
        }
        else
        {
            break;
        }
        int2  _S915 = partner_0(_S891, t_15);
        Domain neighbor_dom_0 = _S894;
        bool _S916 = (fcptCurrentDomain((_S915), (&neighbor_dom_0)));
        if(_S916)
        {
            Reservoir _S917 = (fcptLoadReservoirTemporal((_S915)));
            uint4  _S918 = (fcptShiftData((_S915), (t_15)));
            float4  _S919 = asfloat_0(_S918);
            uint4  _S920 = (fcptShiftData((_S891), (t_15)));
            float4  _S921 = asfloat_0(_S920);
            float _S922 = pairShare(_S917.c, _S903, c_sum_1);
            bool _S923 = _S904 > 0.0f;
            float canonical_mis_1;
            if(_S923)
            {
                float _S924 = resamplingTarget(float3 {_S921.x, _S921.y, _S921.z});
                float _S925 = canonicalWeight(_S922, _S903, _S904, _S917.c, _S924);
                float canonical_mis_2 = canonical_mis_0 + _S925;
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float3  _S926 = float3 {_S919.x, _S919.y, _S919.z};
            Shift _S927 = Shift_x24init_0(_S926, _S919.w);
            float _S928 = resamplingTarget(_S917.f);
            float _S929 = resamplingTarget(_S926);
            float _S930 = neighborWeight(_S922, _S917.c, _S928, _S903, _S929);
            offerShifted(&sel_5, _S917, _S927, _S930);
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_17 = t_15 + 1U;
        t_15 = t_17;
    }
    offerShifted(&sel_5, _S898, Shift_x24init_0(_S898.f, 1.0f), canonical_mis_0);
    Reservoir _S931 = finalize(sel_5, c_sum_1);
    fcptStoreReservoirPrevious((_S891), (_S931), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S891), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S891), (make_float4 ((&sel_5)->color.x, (&sel_5)->color.y, (&sel_5)->color.z, 0.0f)));
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
    uint _S932 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S933 = _S932 != 4294967295U;
    if(_S933)
    {
        uint2  _S934 = make_uint2 (_S932, _S932 >> 14U) & make_uint2 (16383U);
        int2  _S935 = make_int2 ((int)_S934.x, (int)_S934.y);
        ShiftJob _S936 = (ShiftJob{});
        ShiftJob shift_job_0 = _S936;
        Shift _S937 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S938 = _S932 >> 28U;
        bool _S939 = spatialJob_0(_S935, _S938, &shift_job_0, true);
        Shift shifted_1;
        if(_S939)
        {
            Domain _S940 = (&shift_job_0)->dom;
            Reservoir _S941 = (&shift_job_0)->r;
            Shift _S942 = passShift_0(&_S940, &_S941);
            shifted_1 = _S942;
        }
        else
        {
            shifted_1 = _S937;
        }
        fcptStoreShiftData((_S935), (_S938), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S943 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S944 = make_int2 ((int)_S943.x, (int)_S943.y);
    FixedArray<uint, 3>  _S945;
    spatialBins_0(_S944, &_S945);
    FixedArray<uint, 3>  _S946 = _S945;
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
        bool _S947 = (_S946[t_18]) == 40U;
        if(_S947)
        {
            fcptStoreShiftData((_S944), (t_18), (make_uint4 (0U)));
        }
        uint t_19 = t_18 + 1U;
        t_18 = t_19;
    }
    FixedArray<uint, 3>  _S948 = _S946;
    queueShifts_0(_S944, &_S948, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S949 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S950 = make_int2 ((int)_S949.x, (int)_S949.y);
    FixedArray<uint, 3>  _S951;
    spatialBins_0(_S950, &_S951);
    FixedArray<uint, 3>  _S952 = _S951;
    countShifts_0(&_S952, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S953 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S954 = _S953 != 4294967295U;
    if(_S954)
    {
        uint2  _S955 = make_uint2 (_S953, _S953 >> 14U) & make_uint2 (16383U);
        int2  _S956 = make_int2 ((int)_S955.x, (int)_S955.y);
        int2  _S957 = (fcptLoadTemporalNeighbor((_S956)));
        uint _S958 = _S953 >> 28U;
        Shift _S959 = temporalShiftAt_0(_S956, _S957, _S958);
        fcptStoreTemporalShift((_S956), (_S958), (make_uint4 (asuint_1(_S959.f).x, asuint_1(_S959.f).y, asuint_1(_S959.f).z, (F32_asuint((_S959.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S960 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S961 = make_int2 ((int)_S960.x, (int)_S960.y);
    FixedArray<uint, 3>  _S962;
    temporalBins_0(_S961, &_S962);
    FixedArray<uint, 3>  _S963 = _S962;
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
        bool _S964 = (_S963[t_20]) == 40U;
        if(_S964)
        {
            fcptStoreTemporalShift((_S961), (t_20), (make_uint4 (0U)));
        }
        uint t_21 = t_20 + 1U;
        t_20 = t_21;
    }
    FixedArray<uint, 3>  _S965 = _S963;
    queueShifts_0(_S961, &_S965, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S966 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S967 = make_int2 ((int)_S966.x, (int)_S966.y);
    bool _S968 = (fcptSceneUnchanged());
    bool _S969 = !_S968;
    bool _S970;
    if(_S969)
    {
        uint2  _S971 = (fcptRenderSize());
        int2  _S972 = make_int2 ((int)_S971.x, (int)_S971.y);
        _S970 = all_0(_S967 < _S972);
    }
    else
    {
        _S970 = false;
    }
    if(_S970)
    {
        Reservoir _S973 = (fcptLoadReservoirInitial((_S967)));
        int2  _S974 = sampleNeighbor_0(_S967, _S973.seed);
        fcptStoreTemporalNeighbor((_S967), (_S974));
    }
    FixedArray<uint, 3>  _S975;
    temporalBins_0(_S967, &_S975);
    FixedArray<uint, 3>  _S976 = _S975;
    countShifts_0(&_S976, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_9, float b_3, float t_22)
{
    return a_9 + (b_3 - a_9) * t_22;
}

__device__ float confidenceCap(float duplicated_0)
{
    float _S977 = interpolate_0(20.0f, 1.0f, (F32_pow((duplicated_0), (0.10000000149011612f))));
    return _S977;
}

__device__ float2  temporalWeights(float c_2, float p_c_1, float c_t_0, float p_t_0, float g_previous_0, float g_current_0)
{
    float _S978 = c_2 * p_c_1;
    float _S979 = c_t_0 * p_t_0;
    return make_float2 (_S978 / (_S978 + c_t_0 * g_previous_0), _S979 / (_S979 + c_2 * g_current_0));
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S980 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S981 = make_int2 ((int)_S980.x, (int)_S980.y);
    float3  _S982 = make_float3 (0.0f);
    FKHit _S983 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S984 = Domain_x24init_0(_S982, _S982, &_S983, 0.0f, 0.0f);
    Domain dom_5 = _S984;
    bool _S985 = (fcptCurrentDomain((_S981), (&dom_5)));
    bool _S986 = !_S985;
    if(_S986)
    {
        Reservoir _S987 = (Reservoir{});
        fcptStoreReservoirTemporal((_S981), (_S987), ((&dom_5)->hit));
        return;
    }
    Reservoir _S988 = (fcptLoadReservoirInitial((_S981)));
    bool _S989 = (fcptTemporalQueued());
    bool _S990 = (fcptSceneUnchanged());
    bool _S991;
    if(_S990)
    {
        _S991 = true;
    }
    else
    {
        _S991 = !_S989;
    }
    int2  _S992;
    if(_S991)
    {
        int2  _S993 = sampleNeighbor_0(_S981, _S988.seed);
        _S992 = _S993;
    }
    else
    {
        int2  _S994 = (fcptLoadTemporalNeighbor((_S981)));
        _S992 = _S994;
    }
    bool _S995 = (_S992.x) >= int(0);
    Reservoir r_5;
    if(_S995)
    {
        Reservoir _S996 = (fcptLoadReservoirPrevious((_S992)));
        uint4  _S997 = (fcptDuplication((_S992)));
        float _S998 = (U32_asfloat((_S997.x)));
        uint _S999 = (fcptRestirDecorrelation());
        bool _S1000 = _S999 == 1U;
        float _S1001 = _slang_select(_S1000, _S998,0.0f);
        float _S1002 = confidenceCap(_S1001);
        float _S1003 = (F32_min((_S996.c), (_S1002)));
        bool _S1004 = (fcptSceneUnchanged());
        float4  _S1005 = make_float4 (_S996.f.x, _S996.f.y, _S996.f.z, 1.0f);
        bool _S1006 = !_S1004;
        if(_S1006)
        {
            _S991 = _S989;
        }
        else
        {
            _S991 = false;
        }
        float4  to_current_0;
        if(_S991)
        {
            uint4  _S1007 = (fcptTemporalShift((_S981), (0U)));
            float4  _S1008 = asfloat_0(_S1007);
            to_current_0 = _S1008;
        }
        else
        {
            if(_S1006)
            {
                Shift _S1009 = temporalShiftAt_0(_S981, _S992, 0U);
                float4  _S1010 = make_float4 (_S1009.f.x, _S1009.f.y, _S1009.f.z, _S1009.jac);
                to_current_0 = _S1010;
            }
            else
            {
                to_current_0 = _S1005;
            }
        }
        Domain own_1 = _S984;
        if(_S1004)
        {
            _S991 = true;
        }
        else
        {
            bool _S1011 = (fcptPreviousScenes());
            bool _S1012 = !_S1011;
            if(_S1012)
            {
                _S991 = (_S988.w) > 0.0f;
            }
            else
            {
                _S991 = false;
            }
            if(_S991)
            {
                bool _S1013 = (fcptStoredDomainInitial((_S981), (_S988.seed), (&own_1)));
                _S991 = _S1013;
            }
            else
            {
                _S991 = false;
            }
            if(_S991)
            {
                Domain _S1014 = (fcptPreviousDomain((_S992), (_S988.seed)));
                Domain _S1015 = _S1014;
                Domain _S1016 = own_1;
                bool _S1017 = sameDomain_0(&_S1015, &_S1016);
                _S991 = _S1017;
            }
            else
            {
                _S991 = false;
            }
        }
        float4  _S1018 = make_float4 (_S988.f.x, _S988.f.y, _S988.f.z, 1.0f);
        bool _S1019 = !_S991;
        if(_S1019)
        {
            _S991 = _S989;
        }
        else
        {
            _S991 = false;
        }
        float4  to_previous_0;
        if(_S991)
        {
            uint4  _S1020 = (fcptTemporalShift((_S981), (1U)));
            float4  _S1021 = asfloat_0(_S1020);
            to_previous_0 = _S1021;
        }
        else
        {
            if(_S1019)
            {
                Shift _S1022 = temporalShiftAt_0(_S981, _S992, 1U);
                float4  _S1023 = make_float4 (_S1022.f.x, _S1022.f.y, _S1022.f.z, _S1022.jac);
                to_previous_0 = _S1023;
            }
            else
            {
                to_previous_0 = _S1018;
            }
        }
        float _S1024 = resamplingTarget(_S988.f);
        float _S1025 = resamplingTarget(_S996.f);
        Selection _S1026 = (Selection{});
        Selection sel_6 = _S1026;
        uint _S1027 = (fcptFrame());
        uint _S1028 = hash(_S1027);
        uint _S1029 = global_invocation_id_7.x;
        uint2  _S1030 = (fcptRenderSize());
        uint _S1031 = stream(_S1028, _S1029 + _S1030.x * global_invocation_id_7.y);
        uint _S1032 = stream(_S1031, 194U);
        (&sel_6)->random_state = _S1032;
        float4  _S1033 = to_previous_0;
        float _S1034 = resamplingTarget(float3 {_S1033.x, _S1033.y, _S1033.z});
        float4  _S1035 = to_current_0;
        float3  _S1036 = float3 {_S1035.x, _S1035.y, _S1035.z};
        float _S1037 = resamplingTarget(_S1036);
        float2  _S1038 = temporalWeights(_S988.c, _S1024, _S1003, _S1025, _S1034, _S1037);
        offerShifted(&sel_6, _S988, Shift_x24init_0(_S988.f, 1.0f), _S1038.x);
        offerShifted(&sel_6, _S996, Shift_x24init_0(_S1036, to_current_0.w), _S1038.y);
        Reservoir _S1039 = finalize(sel_6, _S988.c + _S1003);
        r_5 = _S1039;
    }
    else
    {
        r_5 = _S988;
    }
    fcptStoreReservoirTemporal((_S981), (r_5), ((&dom_5)->hit));
    return;
}

__device__ uint noiseOrigin(uint2  p_14, uint k_1)
{
    uint _S1040 = ((p_14.x) >> 11U) | (((p_14.y) >> 11U) << 4U);
    uint2  _S1041 = noiseOffset(8192U + (k_1 >> 10U) + (_S1040 << 20U));
    uint2  _S1042 = (p_14 + _S1041) & make_uint2 (2047U);
    return ((_S1042.x) | ((_S1042.y) << 11U)) | ((k_1 & 1023U) << 22U);
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_6)
{
    uint _S1043 = (1U << count_6) - 1U;
    return (e_2 & (~(_S1043 << offset_1))) | ((newbits_0 & _S1043) << offset_1);
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S1044 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S1045 = make_int2 ((int)_S1044.x, (int)_S1044.y);
    float3  _S1046 = make_float3 (0.0f);
    float2  _S1047 = make_float2 (0.0f);
    FKHit _S1048 = Hit_x24init_0(_S1047, 0U, 0U, 0U, 0.0f);
    Domain _S1049 = Domain_x24init_0(_S1046, _S1046, &_S1048, 0.0f, 0.0f);
    Domain dom_6 = _S1049;
    bool _S1050 = (fcptCurrentDomain((_S1045), (&dom_6)));
    bool _S1051 = !_S1050;
    if(_S1051)
    {
        Reservoir _S1052 = (Reservoir{});
        fcptStoreReservoirInitial((_S1045), (_S1052), ((&dom_6)->hit));
        return;
    }
    uint _S1053 = (fcptFrame());
    uint _S1054 = hash(_S1053);
    uint _S1055 = global_invocation_id_8.x;
    uint2  _S1056 = (fcptRenderSize());
    uint _S1057 = global_invocation_id_8.y;
    uint _S1058 = stream(_S1054, _S1055 + _S1056.x * _S1057);
    uint2  _S1059 = (fcptRenderSize());
    uint _S1060 = stream(_S1055 + _S1059.x * _S1057, 512U);
    Selection _S1061 = (Selection{});
    Selection initial_0 = _S1061;
    uint _S1062 = stream(_S1058, 193U);
    (&initial_0)->random_state = _S1062;
    bool _S1063 = (fcptRestirUsed());
    bool _S1064 = !_S1063;
    (&initial_0)->sums = _S1064;
    uint _S1065 = stream(_S1058, 0U);
    (&(&initial_0)->r)->seed = _S1065;
    FKHit _S1066 = Hit_x24init_0(_S1047, 4294967295U, 0U, 0U, 0.0f);
    uint _S1067 = (fcptSamples());
    float _S1068 = 1.0f / float(_S1067);
    FKHit hit_2 = _S1066;
    uint i_20 = 0U;
    float3  seen_1 = _S1046;
    for(;;)
    {
        uint _S1069 = (fcptSamples());
        if(i_20 < _S1069)
        {
        }
        else
        {
            break;
        }
        Reservoir _S1070 = (Reservoir{});
        Reservoir r_6 = _S1070;
        uint _S1071 = (fcptFrame());
        uint _S1072 = (fcptSamples());
        uint _S1073 = _S1071 * _S1072 + i_20;
        uint _S1074 = noiseOrigin(_S1044, _S1073);
        (&r_6)->seed = _S1074;
        uint _S1075 = insertBits_0(0U, 1U, 24U, 1U);
        uint _S1076 = insertBits_0(_S1075, (_S1060 + _S1073 * 2654435769U) >> 25U, 25U, 7U);
        (&r_6)->path = _S1076;
        Domain path_0 = _S1049;
        bool _S1077 = (fcptStoredDomainInitial((_S1045), ((&r_6)->seed), (&path_0)));
        bool _S1078 = !_S1077;
        if(_S1078)
        {
            float3  _S1079 = (fcptMissed((_S1045), (path_0), (_S1068)));
            float3  seen_2 = seen_1 + _S1079;
            seen_1 = seen_2;
            uint i_21 = i_20 + 1U;
            i_20 = i_21;
            continue;
        }
        Domain _S1080 = path_0;
        Reservoir _S1081 = r_6;
        Shift _S1082 = passWalk_0(&_S1080, &_S1081, false, _S1068, &initial_0);
        bool _S1083 = ((&(&initial_0)->r)->seed) == ((&r_6)->seed);
        FKHit hit_3;
        if(_S1083)
        {
            FKHit _S1084 = (&path_0)->hit;
            hit_3 = _S1084;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_21 = i_20 + 1U;
        i_20 = i_21;
    }
    uint _S1085 = (fcptSamples());
    float3  seen_3 = seen_1 + (&initial_0)->glow / make_float3 (float(_S1085));
    if((&initial_0)->sums)
    {
        seen_1 = seen_3 + (&initial_0)->color;
    }
    else
    {
        seen_1 = seen_3;
    }
    fcptAddColor((_S1045), (make_float4 (seen_1.x, seen_1.y, seen_1.z, 1.0f)));
    Reservoir _S1086 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S1045), (_S1086), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_4, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S1087;
    (&_S1087)->none = none_0;
    (&_S1087)->pdf = pdf_4;
    (&_S1087)->origin = origin_5;
    (&_S1087)->smooth_n = smooth_n_3;
    (&_S1087)->start = start_6;
    return _S1087;
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
    Vertex _S1088;
    (&_S1088)->rough = rough_0;
    (&_S1088)->lobe = lobe_1;
    (&_S1088)->pdf = pdf_5;
    (&_S1088)->cos = cos_0;
    (&_S1088)->inside = inside_0;
    return _S1088;
}

__device__ uint noiseAddress(uint origin_6, uint bounce_0)
{
    uint2  _S1089 = make_uint2 (origin_6 & 2047U, (origin_6 >> 11U) & 2047U);
    uint2  _S1090 = noiseOffset(64U + bounce_0 * 17U);
    uint2  _S1091 = (_S1089 + _S1090) & make_uint2 (2047U);
    return ((_S1091.x) | ((_S1091.y) << 11U)) | ((origin_6 >> 22U) << 22U);
}

static __device__ float freeFlight_0(float u_1, float sigma_0)
{
    return - (F32_log((1.0f - u_1))) / sigma_0;
}

__device__ float3  pathColor(float3  f_6, float3  weight_1, float wavelength_5)
{
    float3  _S1092;
    if(wavelength_5 > 0.0f)
    {
        float _S1093 = upsample(f_6, wavelength_5);
        _S1092 = weight_1 * make_float3 (_S1093);
    }
    else
    {
        _S1092 = f_6;
    }
    return _S1092;
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
    float3  _S1094 = exp_0((make_float3 (sigma_1) - extinction_0) * make_float3 (distance_2));
    float3  _S1095 = scatter_0 * _S1094 / make_float3 (sigma_1);
    float3  _S1096 = _slang_select(scatters_0, _S1095,_S1094);
    return _S1096;
}

static __device__ bool scatterSampled_0(bool replay_1, uint b_4, uint stop_0, bool varying_0)
{
    bool _S1097 = !replay_1;
    bool _S1098;
    if(_S1097)
    {
        _S1098 = true;
    }
    else
    {
        bool _S1099 = b_4 == stop_0;
        if(_S1099)
        {
            _S1098 = !varying_0;
        }
        else
        {
            _S1098 = false;
        }
    }
    return _S1098;
}

static __device__ uint arrivalLobe_0(uint b_5, uint prev_lobe_0)
{
    bool _S1100 = b_5 > 0U;
    uint _S1101 = _slang_select(_S1100, prev_lobe_0,3U);
    return _S1101;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_2, uint lobe_2, bool surface_6, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S1102;
    (&_S1102)->extinction_behind = extinction_behind_0;
    (&_S1102)->extinction_front = extinction_front_0;
    (&_S1102)->fillings = fillings_0;
    (&_S1102)->side = side_0;
    (&_S1102)->depth = depth_2;
    (&_S1102)->lobe = lobe_2;
    (&_S1102)->surface = surface_6;
    (&_S1102)->length = length_2;
    (&_S1102)->width = width_1;
    (&_S1102)->own = *own_2;
    (&_S1102)->fiber = fiber_0;
    return _S1102;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S1103 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S1103)
    {
        return 0.07957746833562851f;
    }
    float _S1104 = g_0 * g_0;
    return (1.0f - _S1104) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S1104 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_10, float3  b_6)
{
    float3  _S1105 = a_10 / b_6;
    float3  _S1106 = make_float3 (0.0f);
    bool3  _S1107 = b_6 == _S1106;
    float3  _S1108 = _slang_select(_S1107, _S1106,_S1105);
    return _S1108;
}

__device__ Reservoir withEnd(Reservoir r_7, uint end_type_0, uint end_0, float3  f_7)
{
    Reservoir candidate_2 = r_7;
    uint _S1109 = insertBits_0(r_7.path, end_0, 0U, 5U);
    uint _S1110 = insertBits_0(_S1109, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S1110;
    (&candidate_2)->f = f_7;
    return candidate_2;
}

__device__ float survivalProbability(float3  throughput_0, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_0.x), ((F32_max((throughput_0.y), (throughput_0.z)))))) / density_1), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_10)
{
    Random _S1111 = draw(random_state_10, 11U);
    Random _S1112 = draw(random_state_10, 2147483659U);
    float _S1113 = 1.0f - 2.0f * _S1111.value;
    float _S1114 = (F32_sqrt(((F32_max((1.0f - _S1113 * _S1113), (0.0f))))));
    float _S1115 = 6.28318548202514648f * _S1112.value;
    return make_float3 (_S1114 * (F32_cos((_S1115))), _S1114 * (F32_sin((_S1115))), _S1113);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_10, uint random_state_11, float * pdf_6)
{
    bool _S1116 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1116)
    {
        *pdf_6 = 0.07957746833562851f;
        float3  _S1117 = isotropic_0(random_state_11);
        return _S1117;
    }
    Random _S1118 = draw(random_state_11, 11U);
    Random _S1119 = draw(random_state_11, 2147483659U);
    float _S1120 = g_1 * g_1;
    float _S1121 = 2.0f * g_1;
    float _S1122 = (1.0f - _S1120) / (1.0f - g_1 + _S1121 * _S1118.value);
    float _S1123 = clamp_1((1.0f + _S1120 - _S1122 * _S1122) / _S1121, -1.0f, 1.0f);
    float _S1124 = (F32_sqrt(((F32_max((1.0f - _S1123 * _S1123), (0.0f))))));
    float _S1125 = 6.28318548202514648f * _S1119.value;
    float _S1126 = phaseHG_0(g_1, _S1123);
    *pdf_6 = _S1126;
    float3  _S1127 = tangentToWorld(make_float3 (_S1124 * (F32_cos((_S1125))), _S1123, _S1124 * (F32_sin((_S1125)))), dir_10);
    float3  _S1128 = ((((_S1127)) * make_float3(rnorm3df(((_S1127)).x, ((_S1127)).y, ((_S1127)).z))));
    return _S1128;
}

static __device__ Vertex scatteredVertex_0(bool is_inside_6)
{
    return Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_6);
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_1, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_1, float velvet_0, float3  toon_2, float dispersion_0)
{
    BSDFMaterial _S1129;
    (&_S1129)->albedo = albedo_1;
    (&_S1129)->emissive = emissive_0;
    (&_S1129)->roughness = roughness_0;
    (&_S1129)->metallic = metallic_0;
    (&_S1129)->transmission = transmission_0;
    (&_S1129)->ior = ior_0;
    (&_S1129)->absorption = absorption_0;
    (&_S1129)->specular_tint = specular_tint_0;
    (&_S1129)->specular_level = specular_level_0;
    (&_S1129)->translucent = translucent_0;
    (&_S1129)->sheen = sheen_2;
    (&_S1129)->sheen_roughness = sheen_roughness_0;
    (&_S1129)->anisotropy = anisotropy_0;
    (&_S1129)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1129)->tangent = tangent_1;
    (&_S1129)->velvet = velvet_0;
    (&_S1129)->toon = toon_2;
    (&_S1129)->dispersion = dispersion_0;
    return _S1129;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1130;
    (&_S1130)->scatter = scatter_1;
    (&_S1130)->extinction = extinction_1;
    (&_S1130)->g = g_2;
    return _S1130;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_14, bool skip_0, uint random_state_12, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1131;
    (&_S1131)->smooth_n = smooth_n_4;
    (&_S1131)->geometry_n = geometry_n_2;
    (&_S1131)->geometry_offset = geometry_offset_2;
    (&_S1131)->material = *material_14;
    (&_S1131)->skip = skip_0;
    (&_S1131)->random_state = random_state_12;
    (&_S1131)->coverage = coverage_0;
    (&_S1131)->encloses = encloses_0;
    (&_S1131)->volume = *volume_0;
    (&_S1131)->fills = fills_0;
    (&_S1131)->hair = hair_0;
    return _S1131;
}

static __device__ FKSurface emitting_0(FKSurface * surface_7, bool top_0)
{
    FKSurface lower_0 = *surface_7;
    float3  _S1132 = (&surface_7->material)->emissive;
    float3  _S1133 = make_float3 (0.0f);
    bool _S1134 = !top_0;
    float3  _S1135 = _slang_select(_S1134, _S1133,_S1132);
    (&(&lower_0)->material)->emissive = _S1135;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_8, float u_2)
{
    float _S1136 = surface_8->coverage;
    bool _S1137 = u_2 < _S1136;
    if(_S1137)
    {
        return *surface_8;
    }
    float3  _S1138 = make_float3 (0.0f);
    float3  _S1139 = make_float3 (1.0f);
    BSDFMaterial _S1140 = Material_x24init_0(_S1138, _S1138, 0.0f, 0.0f, 0.0f, 0.0f, _S1138, _S1139, 1.0f, _S1138, _S1138, 0.5f, 0.0f, 0.0f, _S1138, 0.0f, _S1138, 0.0f);
    BSDFMaterial material_15 = _S1140;
    (&material_15)->albedo = _S1139;
    (&material_15)->emissive = (&surface_8->material)->emissive;
    (&material_15)->transmission = 1.0f;
    (&material_15)->ior = 1.0f;
    (&material_15)->absorption = (&surface_8->material)->absorption;
    FKSurface through_0 = *surface_8;
    (&through_0)->material = material_15;
    return through_0;
}

__device__ float facingSign(float transmission_1, float3  face_0, float3  direction_0)
{
    bool _S1141 = transmission_1 > 0.0f;
    bool _S1142;
    if(_S1141)
    {
        _S1142 = true;
    }
    else
    {
        _S1142 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1143;
    if(_S1142)
    {
        _S1143 = 1.0f;
    }
    else
    {
        _S1143 = -1.0f;
    }
    return _S1143;
}

static __device__ bool arrivesBehind_0(float3  dir_11, float3  n_8)
{
    return (dot_0(dir_11, n_8)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_9, float3  dir_12)
{
    float3  _S1144 = surface_9->geometry_n;
    float _S1145 = facingSign((&surface_9->material)->transmission, surface_9->geometry_n, dir_12);
    FKSurface faced_0 = *surface_9;
    float3  _S1146 = surface_9->smooth_n * make_float3 (_S1145);
    (&faced_0)->smooth_n = _S1146;
    float3  _S1147 = _S1144 * make_float3 (_S1145);
    (&faced_0)->geometry_n = _S1147;
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
    float3  _S1148 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1148));
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
    bool _S1149;
    if(open_0)
    {
        _S1149 = prev_rough_0;
    }
    else
    {
        _S1149 = false;
    }
    if(_S1149)
    {
        _S1149 = (prev_pdf_0 * geometry_density_1 * threshold_0) <= 1.0f;
    }
    else
    {
        _S1149 = false;
    }
    return _S1149;
}

__device__ bool dispersive(BSDFMaterial material_16)
{
    bool _S1150 = (material_16.dispersion) > 0.0f;
    bool _S1151;
    if(_S1150)
    {
        _S1151 = (material_16.ior) != 1.0f;
    }
    else
    {
        _S1151 = false;
    }
    return _S1151;
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
        uint _S1152 = (low_1 + high_1 + 1U) / 2U;
        bool _S1153 = (WAVELENGTH_CDF_0[_S1152]) <= u_3;
        if(_S1153)
        {
            low_1 = _S1152;
        }
        else
        {
            uint _S1154 = _S1152 - 1U;
            high_1 = _S1154;
        }
    }
    uint _S1155 = low_1;
    float _S1156 = WAVELENGTH_CDF_0[low_1 + 1U] - WAVELENGTH_CDF_0[low_1];
    return make_float2 (0.37999999523162842f + 0.00499999988824129f * (float(low_1) + (u_3 - WAVELENGTH_CDF_0[_S1155]) / _S1156), _S1156 / 0.00499999988824129f);
}

__device__ static const FixedArray<float, 243>  WAVELENGTH_WEIGHTS_0 = { {
    0.00547470012679696f, -0.00465690018609166f, 0.03257500007748604f, 0.00934640038758516f, -0.00796370021998882f, 0.05577300116419792f, 0.01846100017428398f, -0.01579399965703487f, 0.11072999984025955f, 0.0416410006582737f, -0.03577499836683273f, 0.2513900101184845f, 0.09349299967288971f, -0.08071800321340561f, 0.56742000579833984f, 0.1585099995136261f, -0.13764999806880951f, 0.97018998861312866f, 0.30943000316619873f, -0.27083000540733337f, 1.91740000247955322f, 0.55217999219894409f, -0.48754000663757324f, 3.46889996528625488f, 0.95016998052597046f, -0.84802001714706421f, 6.09439992904663086f, 1.42110002040863037f, -1.28929996490478516f, 9.45199966430664062f, 1.73409998416900635f, -1.6062999963760376f, 12.12800025939941406f, 2.08030009269714355f, -1.98810005187988281f, 15.68700027465820312f, 2.20600008964538574f, -2.20120000839233398f, 18.47699928283691406f, 2.03040003776550293f, -2.17700004577636719f, 19.92700004577636719f, 1.63429999351501465f, -2.00340008735656738f, 20.86899948120117188f, 0.99410998821258545f, -1.62629997730255127f, 20.57799911499023438f, 0.20011000335216522f, -1.11409997940063477f, 19.72100067138671875f, -0.67960000038146973f, -0.45403000712394714f, 17.77599906921386719f, -1.61679995059967041f, 0.37860000133514404f, 14.71500015258789062f, -2.53410005569458008f, 1.27540004253387451f, 11.86499977111816406f, -3.39079999923706055f, 2.2146000862121582f, 9.17669963836669922f, -4.03749990463256836f, 3.0522000789642334f, 6.59509992599487305f, -4.61299991607666016f, 3.89779996871948242f, 4.64589977264404297f, -5.43039989471435547f, 5.0121002197265625f, 3.3199000358581543f, -6.37769985198974609f, 6.33809995651245117f, 2.29699993133544922f, -7.44140005111694336f, 7.91739988327026367f, 1.45389997959136963f, -8.38580036163330078f, 9.60109996795654297f, 0.66465997695922852f, -9.0167999267578125f, 11.23999977111816406f, -0.04403600096702576f, -9.17749977111816406f, 12.63199996948242188f, -0.58126997947692871f, -8.97550010681152344f, 13.91499996185302734f, -0.95730000734329224f, -8.25290012359619141f, 14.86200046539306641f, -1.24430000782012939f, -6.92129993438720703f, 15.03899955749511719f, -1.43069994449615479f, -5.29169988632202148f, 14.90900039672851562f, -1.55149996280670166f, -3.43219995498657227f, 14.70499992370605469f, -1.63569998741149902f, -1.27190005779266357f, 14.24400043487548828f, -1.67030000686645508f, 1.15170001983642578f, 13.32199954986572266f, -1.636199951171875f, 3.73889994621276855f, 12.21199989318847656f, -1.56920003890991211f, 6.43590021133422852f, 10.94699954986572266f, -1.47730004787445068f, 9.16440010070800781f, 9.54769992828369141f, -1.36399996280670166f, 12.02000045776367188f, 8.18799972534179688f, -1.25450003147125244f, 14.78699970245361328f, 6.74429988861083984f, -1.13110005855560303f, 16.72299957275390625f, 5.08780002593994141f, -0.96561002731323242f, 18.14299964904785156f, 3.57019996643066406f, -0.80725997686386108f, 19.91900062561035156f, 2.36269998550415039f, -0.69273000955581665f, 21.05500030517578125f, 1.31369996070861816f, -0.58597999811172485f, 21.3899993896484375f, 0.42390000820159912f, -0.48298001289367676f, 20.99300003051757812f, -0.23857000470161438f, -0.39412000775337219f, 19.82200050354003906f, -0.6866300106048584f, -0.31501999497413635f, 18.12000083923339844f, -0.9412500262260437f, -0.24890999495983124f, 15.7089996337890625f, -1.02020001411437988f, -0.19076000154018402f, 13.19799995422363281f, -0.98919999599456787f, -0.14401000738143921f, 11.23999977111816406f, -0.93347001075744629f, -0.11133000254631042f, 9.36649990081787109f, -0.83820998668670654f, -0.08524099737405777f, 7.41249990463256836f, -0.70064002275466919f, -0.06283199787139893f, 5.71229982376098633f, -0.56079000234603882f, -0.04586699977517128f, 4.42280006408691406f, -0.44653001427650452f, -0.03396600112318993f, 3.34489989280700684f, -0.34457001090049744f, -0.02482499927282333f, 2.49309992790222168f, -0.26017999649047852f, -0.01808100007474422f, 1.82239997386932373f, -0.1921599954366684f, -0.01296999957412481f, 1.29499995708465576f, -0.13766999542713165f, -0.00907570030540228f, 0.92928999662399292f, -0.09956400096416473f, -0.00641620019450784f, 0.61835998296737671f, -0.06671299785375595f, -0.00421149982139468f, 0.40211999416351318f, -0.04354599863290787f, -0.00271830009296536f, 0.2844499945640564f, -0.03087200038135052f, -0.00191440002527088f, 0.20672999322414398f, -0.02246100082993507f, -0.00138829997740686f, 0.15044000744819641f, -0.01634499989449978f, -0.00101030000951141f, 0.10942000150680542f, -0.01188699994236231f, -0.0007347899954766f, 0.07099699974060059f, -0.00771349994465709f, -0.00047679000999779f, 0.04539500176906586f, -0.00493190018460155f, -0.00030484999297187f, 0.03424099832773209f, -0.00372010003775358f, -0.00022995000472292f, 0.02557599917054176f, -0.00277870008721948f, -0.00017175999528263f, 0.01842200011014938f, -0.00200140010565519f, -0.0001237099932041f, 0.01316899992525578f, -0.00143079995177686f, -0.00008843900286593f, 0.00838890019804239f, -0.00091141002485529f, -0.00005633700129692f, 0.00537079991772771f, -0.00058350997278467f, -0.00003606799873523f, 0.00328280008397996f, -0.00035665999166667f, -0.00002204600059486f, 0.00196009990759194f, -0.00021296000340953f, -0.00001316300040344f, 0.00168939994182438f, -0.00018354000349063f, -0.00001134499962063f, 0.00141050003003329f, -0.00015325000276789f, -0.00000947250009631f, 0.00097123999148607f, -0.00010551999730524f, -6.52239987175562419e-06f, 0.00066868000430986f, -0.00007264900341397f, -4.49060007667867467e-06f
} };
__device__ float3  wavelengthWeights(float wavelength_6)
{
    float _S1157 = clamp_1((wavelength_6 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    uint _S1158 = (U32_min((uint(_S1157)), (79U)));
    uint _S1159 = 3U * _S1158;
    float3  _S1160 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1159], WAVELENGTH_WEIGHTS_0[_S1159 + 1U], WAVELENGTH_WEIGHTS_0[_S1159 + 2U]);
    float3  _S1161 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1159 + 3U], WAVELENGTH_WEIGHTS_0[_S1159 + 4U], WAVELENGTH_WEIGHTS_0[_S1159 + 5U]);
    return _S1160 + (_S1161 - _S1160) * make_float3 (_S1157 - float(_S1158));
}

__device__ float dispersedIor(float ior_1, float dispersion_1, float wavelength_7)
{
    float _S1162 = (ior_1 - 1.0f) * dispersion_1 / 1.90962409973144531f;
    float _S1163 = _S1162 * (1.0f / (wavelength_7 * wavelength_7) - 2.89662933349609375f);
    bool _S1164 = dispersion_1 > 0.0f;
    float _S1165 = _slang_select(_S1164, _S1163,0.0f);
    return ior_1 + _S1165;
}

__device__ float2  vertexEta(BSDFMaterial material_17, float n_dot_v_0)
{
    bool _S1166 = n_dot_v_0 < 0.0f;
    float _S1167 = _slang_select(_S1166, material_17.ior,1.0f);
    float _S1168 = _slang_select(_S1166, 1.0f,material_17.ior);
    return make_float2 (_S1167, _S1168);
}

__device__ float2  wavelengthEta(BSDFMaterial material_18, float n_dot_v_1, float wavelength_8)
{
    BSDFMaterial refractive_0 = material_18;
    float _S1169 = dispersedIor(material_18.ior, material_18.dispersion, wavelength_8);
    bool _S1170 = wavelength_8 > 0.0f;
    float _S1171 = _slang_select(_S1170, _S1169,material_18.ior);
    (&refractive_0)->ior = _S1171;
    float2  _S1172 = vertexEta(refractive_0, n_dot_v_1);
    return _S1172;
}

__device__ bool neeDecision(BSDFMaterial material_19, float n_dot_v_2, float eta_i_5, float eta_o_5)
{
    float _S1173 = fresnel((F32_abs((n_dot_v_2))), eta_i_5, eta_o_5);
    float3  _S1174 = mix_0(make_float3 (_S1173), material_19.albedo, material_19.metallic);
    float _S1175 = rgb_to_greyscale(_S1174);
    float _S1176 = (F32_max(((1.0f - _S1175) * (1.0f - material_19.metallic) * (1.0f - material_19.transmission)), (0.0f)));
    bool _S1177 = _S1176 > 0.03999999910593033f;
    bool _S1178;
    if(_S1177)
    {
        _S1178 = true;
    }
    else
    {
        _S1178 = (material_19.roughness) > 0.20000000298023224f;
    }
    return _S1178;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_20)
{
    float _S1179 = rgb_to_greyscale(material_20->translucent);
    return _S1179 > 0.0f;
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
    MediumSides _S1180;
    (&_S1180)->behind = *behind_0;
    (&_S1180)->front = *front_0;
    (&_S1180)->fillings = fillings_1;
    (&_S1180)->face = face_1;
    return _S1180;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_10, FKMedium * medium_0, uint filling_0, float3  dir_13, FKMedium * outside_0)
{
    float3  _S1181 = surface_10->geometry_n;
    MediumSides _S1182 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_10->geometry_n);
    MediumSides sides_0 = _S1182;
    bool _S1183 = surface_10->encloses;
    if(_S1183)
    {
        (&sides_0)->behind = surface_10->volume;
        *&((&(&sides_0)->fillings)->x) = surface_10->fills;
        bool _S1184 = (dot_0(dir_13, _S1181)) > 0.0f;
        if(_S1184)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_11, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_14, uint depth_3, uint lobe_3, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1185 = surface_11->geometry_n;
    ShadowContext _S1186 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_11->geometry_n, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
    bool _S1187 = surface_11->encloses;
    ShadowContext context_4;
    if(_S1187)
    {
        FKSurface faced_1 = *surface_11;
        float3  _S1188 = - _S1185;
        float3  _S1189 = _slang_select(turned_0, _S1188,_S1185);
        (&faced_1)->geometry_n = _S1189;
        FKMedium _S1190 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1191 = faced_1;
        FKMedium _S1192 = _S1190;
        MediumSides _S1193 = mediumSides_0(&_S1191, &_S1192, filling_1, dir_14, outside_1);
        ShadowContext _S1194 = ShadowContext_x24init_0(_S1193.behind.extinction, _S1193.front.extinction, _S1193.fillings, _S1185, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
        if(turned_0)
        {
            uint2  _S1195 = _S1193.fillings;
            ShadowContext _S1196 = ShadowContext_x24init_0(_S1193.front.extinction, _S1193.behind.extinction, uint2 {_S1195.y, _S1195.x}, _S1185, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
            context_4 = _S1196;
        }
        else
        {
            context_4 = _S1194;
        }
    }
    else
    {
        context_4 = _S1186;
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

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_8, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_4, BSDFMaterial * material_21, float eta_i_6, float eta_o_6, bool competing_1, uint random_state_13)
{
    float3  _S1197 = light_2->dir;
    bool _S1198 = (dot_0(geometry_n_4, - in_dir_8) * dot_0(geometry_n_4, light_2->dir)) <= 0.0f;
    FixedArray<float3 , 5>  throughputs_1;
    FixedArray<float, 5>  pdfs_4;
    float3  _S1199 = BSDF(in_dir_8, _S1197, smooth_n_5, *material_21, eta_i_6, eta_o_6, _S1198, random_state_13, &throughputs_1, &pdfs_4);
    bool _S1200 = !competing_1;
    bool _S1201;
    if(_S1200)
    {
        _S1201 = true;
    }
    else
    {
        _S1201 = (light_2->density) == 0.0f;
    }
    if(_S1201)
    {
        return _S1199 * light_2->radiance;
    }
    float3  _S1202 = make_float3 (0.0f);
    uint i_26 = 0U;
    float3  weighted_0 = _S1202;
    for(;;)
    {
        if(i_26 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S1203 = (pdfs_4[i_26]) > 0.0f;
        if(_S1203)
        {
            float _S1204 = light_2->density;
            float _S1205 = pdfs_4[i_26] / light_2->density;
            float3  weighted_1 = weighted_0 + throughputs_1[i_26] * make_float3 (pdfs_4[i_26]) / make_float3 (_S1204 * (1.0f + _S1205 * _S1205));
            weighted_0 = weighted_1;
        }
        uint i_27 = i_26 + 1U;
        i_26 = i_27;
    }
    return weighted_0 * light_2->radiance * make_float3 (light_2->density);
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_1, uint random_state_14, bool refracted_3, uint lobe_4, float pdf_7)
{
    SampleBSDF _S1206;
    (&_S1206)->unit_direction = unit_direction_1;
    (&_S1206)->throughput = throughput_1;
    (&_S1206)->random_state = random_state_14;
    (&_S1206)->refracted = refracted_3;
    (&_S1206)->lobe = lobe_4;
    (&_S1206)->pdf = pdf_7;
    return _S1206;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  v_9, float3  n_i_13, float n_i_dot_v_3, BSDFMaterial material_22, Weights w_14, uint random_state_15)
{
    float3  _S1207 = make_float3 (1.0f);
    SampleBSDF _S1208 = SampleBSDF_x24init_0(_S1207, _S1207, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S1208;
    Random _S1209 = draw(random_state_15, 3U);
    Random _S1210 = draw(random_state_15, 2147483651U);
    (&sample_1)->random_state = _S1210.state;
    float _S1211 = _S1209.value;
    float _S1212 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1211 * _S1211))))));
    float _S1213 = 6.28318548202514648f * _S1210.value;
    float3  _S1214 = tangentToWorld(make_float3 (_S1212 * (F32_cos((_S1213))), _S1209.value, _S1212 * (F32_sin((_S1213)))), n_i_13);
    (&sample_1)->unit_direction = _S1214;
    (&sample_1)->lobe = 4U;
    float3  _S1215 = sheenVelvetBSDF((&sample_1)->unit_direction, v_9, n_i_13, material_22, w_14);
    (&sample_1)->throughput = _S1215;
    float _S1216 = sheenVelvetPDF(_S1209.value, n_i_dot_v_3, w_14);
    (&sample_1)->pdf = _S1216;
    return sample_1;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1217 = (F32_sqrt((random_1_0)));
    float _S1218 = 6.28318548202514648f * random_2_0;
    float _S1219 = _S1217 * (F32_cos((_S1218)));
    float _S1220 = _S1217 * (F32_sin((_S1218)));
    float _S1221 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1219 * _S1219 - _S1220 * _S1220))))));
    return make_float3 (_S1219, _S1221, _S1220);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_4, float3  n_i_14, float n_i_dot_v_4, BSDFMaterial material_23, Weights w_15, uint random_state_16)
{
    float3  _S1222 = make_float3 (1.0f);
    SampleBSDF _S1223 = SampleBSDF_x24init_0(_S1222, _S1222, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S1223;
    Random _S1224 = draw(random_state_16, 3U);
    Random _S1225 = draw(random_state_16, 2147483651U);
    (&sample_2)->random_state = _S1225.state;
    float3  _S1226 = sampleCosWeightedHemisphere(_S1224.value, _S1225.value);
    float _S1227 = translucentShare(material_23);
    bool _S1228 = u_4 < (w_15.p_diffuse * _S1227);
    float _S1229 = _S1226.y;
    float _S1230 = - _S1229;
    float _S1231 = _slang_select(_S1228, _S1230,_S1229);
    float3  _S1232 = tangentToWorld(make_float3 (_S1226.x, _S1231, _S1226.z), n_i_14);
    (&sample_2)->unit_direction = _S1232;
    (&sample_2)->refracted = _S1228;
    (&sample_2)->lobe = 0U;
    float3  _S1233 = diffuseBSDF((&sample_2)->unit_direction, n_i_14, material_23, w_15);
    (&sample_2)->throughput = _S1233;
    float _S1234 = diffusePDF(_S1231, n_i_dot_v_4, material_23, w_15);
    (&sample_2)->pdf = _S1234;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF toonSample(float3  n_i_15, ToonProfile profile_3, Weights w_16, uint random_state_17)
{
    float3  _S1235 = make_float3 (1.0f);
    SampleBSDF _S1236 = SampleBSDF_x24init_0(_S1235, _S1235, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S1236;
    Random _S1237 = draw(random_state_17, 3U);
    Random _S1238 = draw(random_state_17, 2147483651U);
    (&sample_3)->random_state = _S1238.state;
    float _S1239 = _S1237.value * profile_3.norm / 6.28318548202514648f;
    float t_23;
    if(profile_3.glossy)
    {
        t_23 = (F32_acos((clamp_1(1.0f - _S1239, -1.0f, 1.0f))));
    }
    else
    {
        t_23 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1239)))), (1.0f))))));
    }
    if(t_23 < (profile_3.a))
    {
    }
    else
    {
        t_23 = (profile_3.a + profile_3.b) / 2.0f;
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
        float _S1240 = toonP(t_23, profile_3.a, profile_3.s);
        float _S1241 = _S1240 * (F32_sin((t_23)));
        float _S1242;
        if(profile_3.glossy)
        {
            _S1242 = 1.0f;
        }
        else
        {
            _S1242 = (F32_cos((t_23)));
        }
        float _S1243 = _S1241 * _S1242;
        float _S1244 = toonIntegral(t_23, profile_3.a, profile_3.s, profile_3.glossy);
        float _S1245 = (_S1244 - _S1239) / _S1243;
        bool _S1246 = _S1243 > 0.0f;
        float _S1247 = _slang_select(_S1246, _S1245,0.0f);
        float _S1248 = clamp_1(t_23 - _S1247, 0.0f, profile_3.b);
        int k_3 = k_2 + int(1);
        t_23 = _S1248;
        k_2 = k_3;
    }
    float _S1249 = 6.28318548202514648f * _S1238.value;
    float _S1250 = (F32_sin((t_23)));
    float3  _S1251 = tangentToWorld(make_float3 (_S1250 * (F32_cos((_S1249))), (F32_cos((t_23))), _S1250 * (F32_sin((_S1249)))), profile_3.axis);
    (&sample_3)->unit_direction = _S1251;
    bool _S1252 = (dot_0(n_i_15, (&sample_3)->unit_direction)) < 0.0f;
    (&sample_3)->refracted = _S1252;
    (&sample_3)->lobe = 6U;
    float3  _S1253 = toonBSDF((&sample_3)->unit_direction, n_i_15, profile_3, w_16);
    (&sample_3)->throughput = _S1253;
    float _S1254 = toonPDF((&sample_3)->unit_direction, n_i_15, profile_3, w_16);
    (&sample_3)->pdf = _S1254;
    return sample_3;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_16, float alpha_8, AnisotropicFrame frame_6, BSDFMaterial material_24, Weights w_17, float pdf_h_3, float eta_i_7, float eta_o_7, uint random_state_18)
{
    float3  _S1255 = make_float3 (1.0f);
    SampleBSDF _S1256 = SampleBSDF_x24init_0(_S1255, _S1255, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S1256;
    (&sample_4)->unit_direction = w_17.refracted;
    (&sample_4)->random_state = random_state_18;
    (&sample_4)->refracted = true;
    (&sample_4)->lobe = 1U;
    float3  _S1257 = refractBSDF((&sample_4)->unit_direction, n_i_16, alpha_8, frame_6, material_24, w_17);
    (&sample_4)->throughput = _S1257;
    float _S1258 = refractPDF(dot_0((&sample_4)->unit_direction, ggx_n_3), pdf_h_3, w_17, eta_i_7, eta_o_7);
    (&sample_4)->pdf = _S1258;
    return sample_4;
}

static __device__ float3  reflect_0(float3  i_28, float3  n_9)
{
    return i_28 - make_float3 (2.0f * dot_0(n_9, i_28)) * n_9;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_9, float3  ggx_n_4, float3  n_i_17, float alpha_9, AnisotropicFrame frame_7, Weights w_18, float pdf_h_4, uint random_state_19)
{
    float3  _S1259 = make_float3 (1.0f);
    SampleBSDF _S1260 = SampleBSDF_x24init_0(_S1259, _S1259, 0U, false, 0U, 0.0f);
    SampleBSDF sample_5 = _S1260;
    float3  _S1261 = reflect_0(in_dir_9, ggx_n_4);
    float3  _S1262 = ((((_S1261)) * make_float3(rnorm3df(((_S1261)).x, ((_S1261)).y, ((_S1261)).z))));
    (&sample_5)->unit_direction = _S1262;
    (&sample_5)->random_state = random_state_19;
    (&sample_5)->lobe = 2U;
    float3  _S1263 = reflectBSDF((&sample_5)->unit_direction, n_i_17, alpha_9, frame_7, w_18);
    (&sample_5)->throughput = _S1263;
    float _S1264 = reflectPDF(pdf_h_4, w_18);
    (&sample_5)->pdf = _S1264;
    return sample_5;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_10, float3  n_10, BSDFMaterial material_25, float eta_i_8, float eta_o_8, uint random_init_0, float2  screen_space_0)
{
    uint random_state_20 = random_init_0;
    float3  _S1265 = negate_0(in_dir_10);
    float _S1266 = dot_0(n_10, _S1265);
    float _S1267 = sign_0(_S1266);
    float3  n_i_18 = n_10 * make_float3 (_S1267);
    float _S1268 = (F32_abs((_S1266)));
    float _S1269 = material_25.roughness;
    float _S1270 = _S1269 * _S1269;
    AnisotropicFrame _S1271 = anisotropicFrame(material_25, n_i_18);
    SheenProfile _S1272 = sheenProfile(_S1265, n_i_18, material_25);
    float3  _S1273 = sampleHalfVector(_S1265, n_i_18, _S1270, _S1271, &random_state_20);
    Weights _S1274 = lobeWeights(in_dir_10, _S1265, n_i_18, _S1273, _S1271, _S1272, material_25, eta_i_8, eta_o_8);
    Random _S1275 = draw(random_state_20, 2U);
    random_state_20 = _S1275.state;
    bool _S1276 = (_S1275.value) < (_S1274.p_sheen_velvet);
    if(_S1276)
    {
        SampleBSDF _S1277 = sheenVelvetSample(_S1265, n_i_18, _S1268, material_25, _S1274, random_state_20);
        return _S1277;
    }
    float _S1278 = _S1275.value - _S1274.p_sheen_velvet;
    bool _S1279 = _S1278 < (_S1274.p_diffuse);
    if(_S1279)
    {
        SampleBSDF _S1280 = diffuseSample(_S1278, n_i_18, _S1268, material_25, _S1274, random_state_20);
        return _S1280;
    }
    bool _S1281 = _S1278 < (_S1274.p_diffuse + _S1274.p_toon);
    if(_S1281)
    {
        ToonProfile _S1282 = toonProfile(_S1265, n_i_18, material_25);
        SampleBSDF _S1283 = toonSample(n_i_18, _S1282, _S1274, random_state_20);
        return _S1283;
    }
    float _S1284 = vndfPDF(_S1265, _S1273, n_i_18, _S1268, _S1270, _S1271, _S1274.v_dot_h);
    bool _S1285 = (_S1278 - _S1274.p_toon) < (_S1274.p_diffuse + _S1274.p_refract);
    if(_S1285)
    {
        SampleBSDF _S1286 = refractSample(_S1273, n_i_18, _S1270, _S1271, material_25, _S1274, _S1284, eta_i_8, eta_o_8, random_state_20);
        return _S1286;
    }
    SampleBSDF _S1287 = reflectSample(in_dir_10, _S1273, n_i_18, _S1270, _S1271, _S1274, _S1284, random_state_20);
    return _S1287;
}

__device__ bool withinInverseFootprint(float pdf_8, bool diffuse_0, float prev_cos_0, float distance_5, float threshold_1)
{
    bool _S1288 = pdf_8 > 0.0f;
    bool _S1289;
    if(_S1288)
    {
        if(diffuse_0)
        {
            _S1289 = true;
        }
        else
        {
            _S1289 = (pdf_8 * prev_cos_0 / (distance_5 * distance_5) * threshold_1) <= 1.0f;
        }
    }
    else
    {
        _S1289 = false;
    }
    return _S1289;
}

__device__ bool roughLobe(float pdf_9, bool diffuse_1, float roughness_1)
{
    bool _S1290 = pdf_9 > 0.0f;
    bool _S1291;
    if(_S1290)
    {
        if(diffuse_1)
        {
            _S1291 = true;
        }
        else
        {
            _S1291 = roughness_1 >= 0.20000000298023224f;
        }
    }
    else
    {
        _S1291 = false;
    }
    return _S1291;
}

static __device__ bool passesLayer_0(uint layers_0, bool refracting_0, bool passed_0)
{
    bool _S1292 = layers_0 > 1U;
    bool _S1293;
    if(_S1292)
    {
        _S1293 = refracting_0 != passed_0;
    }
    else
    {
        _S1293 = false;
    }
    return _S1293;
}

static __device__ float widened_0(float spread_1, float pdf_10, bool delta_0)
{
    float _S1294 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * pdf_10))))), (3.14159274101257324f)));
    bool _S1295 = !delta_0;
    float _S1296 = _slang_select(_S1295, _S1294,0.0f);
    return spread_1 + _S1296;
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
    bool _S1297;
    float density_2;
    float wavelength_9;
    float width_3;
    float sky_pdf_0;
    float threshold_2;
    uint b_7;
    uint layer_0;
    float3  throughput_2;
    float3  spectral_weight_0;
    TreeSample light_3;
    int _S1298;
    Shift ended_0;
    float density_3;
    float spread_3;
    float width_4;
    float sky_pdf_1;
    float spread_4;
    float width_5;
    uint b_8;
    float3  _S1299 = make_float3 (0.0f);
    Shift _S1300 = Shift_x24init_0(_S1299, 0.0f);
    uint _S1301 = r_8->path;
    uint _S1302 = extractBits_0(r_8->path, 0U, 5U);
    uint _S1303 = extractBits_0(_S1301, 5U, 5U);
    uint _S1304 = extractBits_0(_S1301, 10U, 2U);
    uint _S1305 = extractBits_0(_S1301, 12U, 3U);
    bool passes_0;
    if(replay_2)
    {
        bool _S1306 = _S1305 >= 3U;
        uint _S1307 = _slang_select(_S1306, 1U,0U);
        uint _S1308 = _S1302 + _S1307;
        uint _S1309 = (fcptMaxBounces());
        passes_0 = _S1308 > _S1309;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1300;
    }
    uint _S1310 = _S1303 - 1U;
    bool _S1311 = _S1305 == 3U;
    uint _S1312 = _slang_select(_S1311, 1U,0U);
    uint _S1313 = _S1302 + _S1312;
    bool _S1314 = _S1304 == 0U;
    uint _S1315 = _slang_select(_S1314, _S1313,_S1310);
    FKHit _S1316 = (fcptReservoirHit((*r_8)));
    float3  _S1317 = dom_7->x0;
    float3  _S1318 = dom_7->x1 - dom_7->x0;
    float3  _S1319 = ((((_S1318)) * make_float3(rnorm3df(((_S1318)).x, ((_S1318)).y, ((_S1318)).z))));
    FKRay _S1320 = Ray_x24init_0(dom_7->x1, _S1319);
    FKRay ray_2 = _S1320;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1299;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_2 = throughput_3;
    float3  glowed_0 = _S1299;
    float3  extinction_in_0 = _S1299;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1321 = dom_7->spread;
    float _S1322 = dom_7->width;
    float _S1323 = length_0(_S1318);
    NEEVertex _S1324 = NEEVertex_x24init_0(true, 0.0f, _S1299, _S1299, _S1299);
    NEEVertex nee_vertex_0 = _S1324;
    Vertex _S1325 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S1325;
    Reservoir _S1326 = (Reservoir{});
    Reservoir chain_0 = _S1326;
    uint _S1327 = r_8->seed;
    (&chain_0)->seed = r_8->seed;
    uint _S1328 = extractBits_0(_S1301, 24U, 8U);
    uint _S1329 = insertBits_0(0U, _S1328, 24U, 8U);
    (&chain_0)->path = _S1329;
    (&ray_2)->origin = _S1317;
    (&hit_4)->distance = _S1323;
    FKMedium _S1330 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1331 = filling_2;
    bool _S1332 = (fcptVaryingUsed());
    uint _S1333 = _slang_select(_S1332, _S1331,4294967295U);
    filling_2 = _S1333;
    scatter_in_0 = _S1330.scatter;
    extinction_in_0 = _S1330.extinction;
    g_in_0 = _S1330.g;
    Reservoir _S1334 = chain_0;
    uint _S1335 = filling_2;
    for(;;)
    {
        bool _S1336 = (fcptVaryingUsed());
        if(_S1336)
        {
            passes_0 = _S1335 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1337 = (fcptMajorant((_S1335)));
            spread_2 = _S1337;
        }
        else
        {
            spread_2 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_2)
        {
            turned_1 = 4294967295U == _S1315;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1304 == 1U;
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
            ended_0 = _S1300;
            sky_pdf_0 = 0.0f;
            spread_2 = _S1321;
            width_3 = _S1322;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_7 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1338 = (&prev_0)->rough;
        if(_S1338)
        {
            turned_1 = !(spread_2 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S1339 = stream(_S1327, 384U);
        uint tracking_0 = _S1339;
        weight_2 = throughput_3;
        glowed_0 = _S1299;
        b_7 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        wavelength_9 = _S1321;
        width_3 = _S1322;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1298 = int(1);
                break;
            }
            uint _S1340 = noiseAddress(_S1327, b_7);
            Random _S1341 = draw(_S1340, 10U);
            float _S1342 = freeFlight_0(_S1341.value, spread_2);
            if(passes_0)
            {
                float3  _S1343 = (&ray_2)->origin;
                float3  _S1344 = (&ray_2)->unit_direction;
                float _S1345 = (&hit_4)->distance;
                bool _S1346 = b_7 == 4294967295U;
                uint _S1347 = _slang_select(_S1346, 0U,b_7);
                uint _S1348 = (&prev_0)->lobe;
                uint _S1349 = _slang_select(_S1346, 3U,_S1348);
                float _S1350 = (fcptTrackMedium((_S1335), (_S1343), (_S1344), (_S1345), (&tracking_0), (&weight_2), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1347), (_S1349), (_S1346)));
                threshold_2 = _S1350;
            }
            else
            {
                threshold_2 = _S1342;
            }
            bool _S1351 = !(threshold_2 < ((&hit_4)->distance));
            if(_S1351)
            {
                _S1298 = int(1);
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
                float3  _S1352 = pathColor(throughput_2 * glowed_0, throughput_3, 0.0f);
                float3  _S1353 = _S1352 / make_float3 (density_2);
                float3  _S1354 = sel_7->glow + _S1353;
                sel_7->glow = _S1354;
            }
            else
            {
            }
            glowed_0 = _S1299;
            uint b_9 = b_7 + 1U;
            float3  _S1355 = (&ray_2)->origin + make_float3 (threshold_2) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1355;
            float3  _S1356 = flightWeight_0(scatter_in_0, extinction_in_0, spread_2, threshold_2, true);
            float3  _S1357 = weight_2;
            float _S1358 = upsample(weight_2, 0.0f);
            float3  _S1359 = make_float3 (_S1358);
            float3  _S1360 = _slang_select(false, _S1359,_S1357);
            float3  _S1361 = _slang_select(passes_0, _S1360,_S1356);
            float3  throughput_4 = throughput_2 * _S1361;
            uint _S1362 = stream(_S1327, b_9 + 320U);
            tracking_0 = _S1362;
            weight_2 = throughput_3;
            float width_6 = width_3 + wavelength_9 * threshold_2;
            float _S1363 = wavelength_9 + 3.14159274101257324f;
            bool _S1364 = scatterSampled_0(replay_2, b_9, _S1315, passes_0);
            TreeSample _S1365 = TreeSample_x24init_0(_S1299, _S1299, 0.0f, 0U);
            if(_S1364)
            {
                float3  _S1366 = (&ray_2)->origin;
                float3  _S1367 = (&ray_2)->unit_direction;
                float3  _S1368 = (&ray_2)->unit_direction;
                uint _S1369 = noiseAddress(_S1327, b_9);
                float3  _S1370 = extinction_in_0;
                float3  _S1371 = extinction_in_0;
                uint2  _S1372 = make_uint2 (_S1335);
                float3  _S1373 = (&ray_2)->unit_direction;
                uint _S1374 = arrivalLobe_0(b_9, (&prev_0)->lobe);
                FKHit _S1375 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1376 = _S1375;
                ShadowContext _S1377 = ShadowContext_x24init_0(_S1370, _S1371, _S1372, _S1373, b_9, _S1374, false, threshold_2, width_6, &_S1376, false);
                ShadowContext _S1378 = _S1377;
                TreeSample _S1379 = sampleLightTree_0(_S1366, _S1367, _S1368, 0.0f, true, _S1369, &_S1378);
                light_3 = _S1379;
            }
            else
            {
                light_3 = _S1365;
            }
            float _S1380 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S1381 = (fcptMaxBounces());
            bool _S1382 = b_9 < _S1381;
            if(_S1382)
            {
                is_inside_7 = (light_3.density) > 0.0f;
            }
            else
            {
                is_inside_7 = false;
            }
            float _S1383 = _slang_select(is_inside_7, _S1380,0.0f);
            float3  _S1384 = throughput_4 * light_3.radiance;
            float _S1385 = powerHeuristic(light_3.density, _S1383);
            float3  _S1386 = pathColor(_S1384 * make_float3 (_S1380 * _S1385), throughput_3, 0.0f);
            float3  _S1387 = _slang_select(_S1364, _S1386,_S1299);
            if(replay_2)
            {
                viewed_0 = b_9 == _S1315;
            }
            else
            {
                viewed_0 = false;
            }
            if(viewed_0)
            {
                bool _S1388 = _S1304 == 2U;
                if(_S1388)
                {
                    float _S1389 = resamplingTarget(_S1387);
                    passes_0 = _S1389 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1390 = Shift_x24init_0(_S1387, 1.0f);
                    _S1298 = int(0);
                    ended_0 = _S1390;
                    spread_2 = _S1363;
                    threshold_2 = width_6;
                    spectral_weight_0 = throughput_4;
                    layer_0 = b_9;
                    break;
                }
                _S1298 = int(0);
                ended_0 = _S1300;
                spread_2 = _S1363;
                threshold_2 = width_6;
                spectral_weight_0 = throughput_4;
                layer_0 = b_9;
                break;
            }
            bool _S1391 = !replay_2;
            if(_S1391)
            {
                Reservoir candidate_3 = _S1334;
                uint _S1392 = extractBits_0(_S1334.path, 24U, 8U);
                uint _S1393 = insertBits_0(0U, _S1392, 24U, 8U);
                uint _S1394 = extractBits_0(_S1334.path, 10U, 2U);
                bool _S1395 = _S1394 == 1U;
                if(_S1395)
                {
                    float3  _S1396 = safeDivide(_S1387, _S1299);
                    (&candidate_3)->radiance = _S1396;
                }
                else
                {
                    uint _S1397 = insertBits_0(_S1393, b_9 + 1U, 5U, 5U);
                    uint _S1398 = insertBits_0(_S1397, 2U, 10U, 2U);
                    (&candidate_3)->path = _S1398;
                }
                Reservoir _S1399 = withEnd(candidate_3, 0U, b_9, _S1387);
                offer(sel_7, _S1399, _S1387 * make_float3 (scale_3) / make_float3 (density_2));
                float _S1400 = survivalProbability(abs_0(throughput_4), density_2);
                uint _S1401 = noiseAddress(_S1327, b_9);
                Random _S1402 = draw(_S1401, 8U);
                bool _S1403 = _S1400 < (_S1402.value);
                if(_S1403)
                {
                    _S1297 = true;
                }
                else
                {
                    uint _S1404 = (fcptMaxBounces());
                    _S1297 = b_9 >= _S1404;
                }
                if(_S1297)
                {
                    _S1298 = int(0);
                    ended_0 = _S1300;
                    spread_2 = _S1363;
                    threshold_2 = width_6;
                    spectral_weight_0 = throughput_4;
                    layer_0 = b_9;
                    break;
                }
                float _S1405 = density_2 * _S1400;
                density_2 = _S1405;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1406 = noiseAddress(_S1327, b_9);
            float3  _S1407 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1406, &phase_pdf_0);
            (&ray_2)->unit_direction = _S1407;
            NEEVertex _S1408 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S1299, (&ray_2)->origin);
            nee_vertex_0 = _S1408;
            Vertex _S1409 = scatteredVertex_0(false);
            prev_0 = _S1409;
            float _S1410 = (&prev_0)->pdf;
            FKRay _S1411 = ray_2;
            FKHit _S1412 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1413 = (fcptTraverseInstanceBVH((_S1411), (true), (4.294967296e+09f), (false), (_S1412), (false)));
            hit_4 = _S1413;
            b_7 = b_9;
            throughput_2 = throughput_4;
            wavelength_9 = _S1363;
            width_3 = width_6;
            sky_pdf_0 = _S1410;
        }
        if(_S1298 != int(1))
        {
            width_3 = threshold_2;
            throughput_2 = spectral_weight_0;
            b_7 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1300;
        spread_2 = wavelength_9;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1414 = b_7 == 4294967295U;
    bool _S1415 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1415)
    {
        bool _S1416 = !(&nee_vertex_0)->none;
        float _S1417 = _slang_select(_S1416, sky_pdf_0,0.0f);
        float _S1418 = escapeWeight_0(_S1417, (&ray_2)->unit_direction);
        float3  _S1419 = environment_0((&ray_2)->unit_direction, b_7, (&prev_0)->lobe);
        float3  _S1420 = pathColor(throughput_2 * _S1419, throughput_3, 0.0f);
        if(replay_2)
        {
            bool _S1421 = b_7 == _S1315;
            if(_S1421)
            {
                passes_0 = _S1304 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S1420 * make_float3 (_S1418) / make_float3 (r_8->jac), density_2 / r_8->jac);
            }
            if(_S1314)
            {
                passes_0 = _S1311;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_7 == _S1302;
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
                return Shift_x24init_0(_S1420 * make_float3 (_S1418), 1.0f);
            }
            return _S1300;
        }
        Reservoir candidate_4 = chain_0;
        uint _S1422 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1423 = _S1422 == 1U;
        if(_S1423)
        {
            uint _S1424 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S1425 = _S1424 == b_7;
            float _S1426 = _slang_select(_S1425, 1.0f,_S1418);
            float3  _S1427 = safeDivide(_S1420 * make_float3 (_S1426), _S1299);
            (&candidate_4)->radiance = _S1427;
        }
        else
        {
            bool _S1428 = (&prev_0)->rough;
            if(_S1428)
            {
                uint _S1429 = insertBits_0(_S1329, b_7 + 1U, 5U, 5U);
                uint _S1430 = insertBits_0(_S1429, 3U, 10U, 2U);
                uint _S1431 = insertBits_0(_S1430, (&prev_0)->lobe, 15U, 3U);
                bool _S1432 = (&prev_0)->inside;
                uint _S1433 = _slang_select(_S1432, 1U,0U);
                uint _S1434 = insertBits_0(_S1431, _S1433, 22U, 1U);
                (&candidate_4)->path = _S1434;
                (&candidate_4)->jac = (&prev_0)->pdf;
                (&candidate_4)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S1435 = _S1420 * make_float3 (_S1418);
        Reservoir _S1436 = withEnd(candidate_4, 3U, b_7, _S1435);
        offer(sel_7, _S1436, _S1435 * make_float3 (scale_3) / make_float3 (density_2));
        return _S1300;
    }
    float3  _S1437 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S1437;
    bool _S1438 = (fcptVaryingUsed());
    if(_S1438)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1439 = !replay_2;
        if(_S1439)
        {
            float3  _S1440 = pathColor(throughput_2 * glowed_0, throughput_3, 0.0f);
            float3  _S1441 = _S1440 / make_float3 (density_2);
            float3  _S1442 = sel_7->glow + _S1441;
            sel_7->glow = _S1442;
        }
        float3  _S1443 = throughput_2 * weight_2;
        throughput_2 = _S1443;
    }
    else
    {
        float3  _S1444 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
        float3  _S1445 = throughput_2 * _S1444;
        throughput_2 = _S1445;
    }
    float _S1446 = width_3 + spread_2 * (&hit_4)->distance;
    uint _S1447 = b_7 + 1U;
    b_7 = _S1447;
    layer_0 = 0U;
    width_3 = _S1446;
    passes_0 = false;
    wavelength_9 = 0.0f;
    threshold_2 = 0.0f;
    turned_1 = false;
    is_inside_7 = false;
    spectral_weight_0 = throughput_3;
    float3  chain_throughput_0 = _S1299;
    float3  reconnection_0 = _S1299;
    viewed_0 = _S1414;
    for(;;)
    {
        bool _S1448 = ((&hit_4)->is_point_light) == 1U;
        if(replay_2)
        {
            _S1297 = _S1304 == 1U;
        }
        else
        {
            _S1297 = false;
        }
        bool _S1449;
        if(_S1297)
        {
            _S1449 = b_7 == _S1303;
        }
        else
        {
            _S1449 = false;
        }
        bool _S1450;
        if(_S1449)
        {
            bool _S1451 = ((&hit_4)->instance_index) != (_S1316.instance_index);
            if(_S1451)
            {
                _S1450 = true;
            }
            else
            {
                _S1450 = ((&hit_4)->triangle_index) != (_S1316.triangle_index);
            }
        }
        else
        {
            _S1450 = false;
        }
        if(_S1450)
        {
            return _S1300;
        }
        FKMedium _S1452 = Medium_x24init_0(_S1299, _S1299, 0.0f);
        BSDFMaterial _S1453 = Material_x24init_0(_S1299, _S1299, 0.0f, 0.0f, 0.0f, 0.0f, _S1299, throughput_3, 1.0f, _S1299, _S1299, 0.5f, 0.0f, 0.0f, _S1299, 0.0f, _S1299, 0.0f);
        FKMedium _S1454 = _S1452;
        FKSurface _S1455 = Surface_x24init_0(_S1299, _S1299, 0.0f, &_S1453, false, 0U, 1.0f, false, &_S1454, 4294967295U, _S1299);
        bool _S1456 = !_S1448;
        bool scatter_2;
        bool is_inside_8;
        float geometry_density_2;
        float3  throughput_5;
        FKSurface surface_13;
        if(_S1456)
        {
            uint _S1457 = noiseAddress(_S1327, b_7);
            uint _S1458 = arrivalLobe_0(b_7, (&prev_0)->lobe);
            FKSurface _S1459 = (fcptSurfaceAtPath((hit_4), ((&ray_2)->origin), (_S1457), (width_3), (layer_0), (b_7), (_S1458), ((&ray_2)->unit_direction)));
            bool _S1460 = !passes_0;
            FKSurface _S1461 = _S1459;
            FKSurface _S1462 = emitting_0(&_S1461, _S1460);
            uint _S1463 = noiseAddress(_S1327, b_7);
            Random _S1464 = draw(_S1463, 9U);
            FKSurface _S1465 = _S1462;
            FKSurface _S1466 = uncovered_0(&_S1465, _S1464.value);
            float _S1467 = facingSign(_S1466.material.transmission, _S1466.geometry_n, (&ray_2)->unit_direction);
            bool _S1468 = _S1467 < 0.0f;
            bool _S1469 = (_S1466.material.transmission) > 0.0f;
            if(_S1469)
            {
                bool _S1470 = arrivesBehind_0((&ray_2)->unit_direction, _S1466.geometry_n);
                scatter_2 = _S1470;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1471 = _S1466;
            FKSurface _S1472 = facingRay_0(&_S1471, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S1473 = arrivesBehind_0((&ray_2)->unit_direction, _S1472.geometry_n);
                is_inside_8 = _S1473;
            }
            else
            {
                is_inside_8 = scatter_2;
            }
            if(is_inside_8)
            {
                float _S1474 = (&hit_4)->distance;
                float _S1475 = upsample(_S1472.material.absorption, wavelength_9);
                float3  _S1476 = make_float3 (_S1475);
                bool _S1477 = wavelength_9 > 0.0f;
                float3  _S1478 = _slang_select(_S1477, _S1476,_S1472.material.absorption);
                float3  _S1479 = beerLambert(_S1474, _S1478);
                float3  _S1480 = throughput_2 * _S1479;
                throughput_5 = _S1480;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S1481 = !_S1472.skip;
            float geometry_density_3 = geometryDensity(_S1472.geometry_n, (&ray_2)->unit_direction, (&hit_4)->distance);
            bool _S1482 = b_7 == _S1447;
            if(_S1482)
            {
                float _S1483 = footprintThreshold(geometry_density_3);
                geometry_density_2 = _S1483;
            }
            else
            {
                geometry_density_2 = threshold_2;
            }
            float _S1484 = geometry_density_2;
            scatter_2 = _S1481;
            geometry_density_2 = geometry_density_3;
            threshold_2 = _S1484;
            surface_13 = _S1472;
            turned_1 = _S1468;
        }
        else
        {
            scatter_2 = false;
            geometry_density_2 = 0.0f;
            surface_13 = _S1455;
            throughput_5 = throughput_2;
            is_inside_8 = is_inside_7;
        }
        bool _S1485 = withinFootprint(scatter_2, (&prev_0)->rough, (&prev_0)->pdf, geometry_density_2, threshold_2);
        FKSurface _S1486 = surface_13;
        float _S1487 = dot_0(surface_13.smooth_n, - (&ray_2)->unit_direction);
        bool _S1488 = (fcptDispersionUsed());
        bool _S1489;
        if(_S1488)
        {
            _S1489 = wavelength_9 == 0.0f;
        }
        else
        {
            _S1489 = false;
        }
        bool _S1490;
        if(_S1489)
        {
            _S1490 = scatter_2;
        }
        else
        {
            _S1490 = false;
        }
        bool _S1491;
        if(_S1490)
        {
            bool _S1492 = dispersive(surface_13.material);
            _S1491 = _S1492;
        }
        else
        {
            _S1491 = false;
        }
        float3  throughput_6;
        if(_S1491)
        {
            uint _S1493 = stream(_S1327, 512U);
            Random _S1494 = pcg(_S1493);
            uint _S1495 = extractBits_0(_S1301, 25U, 7U);
            float _S1496 = (float(_S1495) + _S1494.value) / 128.0f;
            uint _S1497 = extractBits_0(_S1301, 24U, 1U);
            bool _S1498 = _S1497 == 1U;
            float _S1499 = _slang_select(_S1498, _S1496,_S1494.value);
            float2  _S1500 = sampleWavelength(_S1499);
            float wavelength_10 = _S1500.x;
            float3  _S1501 = wavelengthWeights(wavelength_10);
            float3  _S1502 = _S1501 / make_float3 (_S1500.y);
            float _S1503 = upsample(throughput_5, wavelength_10);
            float3  _S1504 = make_float3 (_S1503);
            float _S1505 = upsample(scatter_in_0, wavelength_10);
            float3  _S1506 = make_float3 (_S1505);
            scatter_in_0 = _S1506;
            float _S1507 = upsample(extinction_in_0, wavelength_10);
            float3  _S1508 = make_float3 (_S1507);
            extinction_in_0 = _S1508;
            wavelength_9 = wavelength_10;
            throughput_6 = _S1504;
            spectral_weight_0 = _S1502;
        }
        else
        {
            throughput_6 = throughput_5;
        }
        BSDFMaterial _S1509 = pathMaterial(surface_13.material, wavelength_9);
        float2  _S1510 = wavelengthEta(_S1509, _S1487, wavelength_9);
        bool _S1511;
        if(scatter_2)
        {
            bool _S1512 = neeDecision(_S1509, _S1487, _S1510.x, _S1510.y);
            _S1511 = _S1512;
        }
        else
        {
            _S1511 = false;
        }
        bool _S1513;
        if(passes_0)
        {
            _S1513 = true;
        }
        else
        {
            _S1513 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1513)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1511;
        }
        bool _S1514 = (fcptHairUsed());
        bool _S1515;
        if(_S1514)
        {
            float3  _S1516 = surface_13.hair;
            _S1515 = (dot_0(_S1516, _S1516)) > 0.0f;
        }
        else
        {
            _S1515 = false;
        }
        bool _S1517;
        if(_S1515)
        {
            _S1517 = true;
        }
        else
        {
            BSDFMaterial _S1518 = _S1509;
            bool _S1519 = isTranslucent_0(&_S1518);
            _S1517 = _S1519;
        }
        bool _S1520;
        if(_S1517)
        {
            _S1520 = true;
        }
        else
        {
            bool _S1521 = (_S1509.transmission) > 0.0f;
            if(_S1521)
            {
                uint _S1522 = (fcptLayers((hit_4)));
                _S1520 = _S1522 == 1U;
            }
            else
            {
                _S1520 = false;
            }
        }
        float3  emission_0;
        if(_S1448)
        {
            float3  _S1523 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1523;
        }
        else
        {
            emission_0 = _S1509.emissive;
        }
        bool _S1524 = !replay_2;
        bool _S1525;
        if(_S1524)
        {
            _S1525 = true;
        }
        else
        {
            _S1525 = b_7 >= _S1315;
        }
        bool _S1526;
        if(_S1525)
        {
            float _S1527 = rgb_to_greyscale(emission_0);
            _S1526 = _S1527 > 0.0f;
        }
        else
        {
            _S1526 = false;
        }
        float3  emission_1;
        if(_S1526)
        {
            NEEVertex _S1528 = nee_vertex_0;
            FKHit _S1529 = hit_4;
            float _S1530 = emissionWeight_0(&_S1528, &_S1529, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1530);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1531;
        if(replay_2)
        {
            _S1531 = _S1304 == 1U;
        }
        else
        {
            _S1531 = false;
        }
        bool _S1532;
        if(_S1531)
        {
            _S1532 = b_7 > _S1303;
        }
        else
        {
            _S1532 = false;
        }
        bool _S1533;
        if(_S1532)
        {
            _S1533 = b_7 == _S1302;
        }
        else
        {
            _S1533 = false;
        }
        bool _S1534;
        if(_S1533)
        {
            bool _S1535 = _S1305 == 1U;
            if(_S1535)
            {
                _S1534 = true;
            }
            else
            {
                _S1534 = _S1305 == 2U;
            }
        }
        else
        {
            _S1534 = false;
        }
        if(_S1534)
        {
            bool _S1536 = _S1448 != (_S1305 == 2U);
            if(_S1536)
            {
                return _S1300;
            }
            float3  _S1537 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_9);
            return Shift_x24init_0(_S1537 / make_float3 (r_8->jac), density_2 / r_8->jac);
        }
        uint _S1538 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1539 = _S1538 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1540 = insertBits_0(_S1329, b_7, 5U, 5U);
        uint _S1541 = insertBits_0(_S1540, 1U, 10U, 2U);
        uint _S1542 = insertBits_0(_S1541, (&prev_0)->lobe, 15U, 3U);
        bool _S1543 = (&prev_0)->inside;
        uint _S1544 = _slang_select(_S1543, 1U,0U);
        uint _S1545 = insertBits_0(_S1542, _S1544, 22U, 1U);
        (&here_0)->path = _S1545;
        uint _S1546 = (&here_0)->path;
        bool _S1547 = wavelength_9 > 0.0f;
        uint _S1548 = _slang_select(_S1547, 1U,0U);
        uint _S1549 = insertBits_0(_S1546, _S1548, 23U, 1U);
        (&here_0)->path = _S1549;
        float _S1550 = (&prev_0)->pdf * geometry_density_2;
        (&here_0)->jac = _S1550;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1551;
        if(replay_2)
        {
            _S1551 = _S1304 == 1U;
        }
        else
        {
            _S1551 = false;
        }
        bool _S1552;
        if(_S1551)
        {
            _S1552 = b_7 == _S1303;
        }
        else
        {
            _S1552 = false;
        }
        bool _S1553 = b_7 == _S1315;
        bool _S1554;
        if(_S1553)
        {
            bool _S1555 = !scatter_2;
            if(_S1555)
            {
                _S1554 = true;
            }
            else
            {
                bool _S1556 = _S1304 != 1U;
                if(_S1556)
                {
                    _S1554 = _S1304 != 3U;
                }
                else
                {
                    _S1554 = false;
                }
            }
        }
        else
        {
            _S1554 = false;
        }
        bool _S1557;
        if(_S1554)
        {
            _S1557 = _S1304 == 2U;
        }
        else
        {
            _S1557 = false;
        }
        bool _S1558;
        if(_S1557)
        {
            _S1558 = !_S1485;
        }
        else
        {
            _S1558 = false;
        }
        bool _S1559;
        if(_S1558)
        {
            _S1559 = _S1305 != 4U;
        }
        else
        {
            _S1559 = false;
        }
        bool _S1560 = _S1303 == _S1302;
        bool _S1561;
        if(_S1560)
        {
            _S1561 = _S1305 == 0U;
        }
        else
        {
            _S1561 = false;
        }
        bool _S1562;
        if(_S1561)
        {
            _S1562 = ((&hit_4)->instance_index) == (_S1316.instance_index);
        }
        else
        {
            _S1562 = false;
        }
        bool _S1563;
        if(_S1562)
        {
            _S1563 = ((&hit_4)->triangle_index) == (_S1316.triangle_index);
        }
        else
        {
            _S1563 = false;
        }
        bool _S1564;
        if(_S1563)
        {
            _S1564 = _S1485;
        }
        else
        {
            _S1564 = false;
        }
        bool _S1565 = _slang_select(_S1552, _S1564,_S1559);
        bool _S1566;
        if(nee_0)
        {
            _S1566 = _slang_select(replay_2, _S1565,scatter_2);
        }
        else
        {
            _S1566 = false;
        }
        TreeSample _S1567 = TreeSample_x24init_0(_S1299, _S1299, 0.0f, 0U);
        uint2  _S1568 = make_uint2 (0U);
        float2  _S1569 = make_float2 (0.0f);
        FKHit _S1570 = Hit_x24init_0(_S1569, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1571 = _S1570;
        ShadowContext _S1572 = ShadowContext_x24init_0(_S1299, _S1299, _S1568, _S1299, 0U, 0U, false, 0.0f, 0.0f, &_S1571, false);
        bool _S1573;
        if(nee_0)
        {
            _S1573 = _S1525;
        }
        else
        {
            _S1573 = false;
        }
        ShadowContext context_5;
        if(_S1573)
        {
            uint _S1574 = arrivalLobe_0(b_7, (&prev_0)->lobe);
            FKMedium _S1575 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1576 = surface_13;
            FKHit _S1577 = hit_4;
            FKMedium _S1578 = _S1575;
            ShadowContext _S1579 = shadowContext_0(&_S1576, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_7, _S1574, (&hit_4)->distance, width_3, &_S1577, _S1515, &_S1578);
            context_5 = _S1579;
        }
        else
        {
            context_5 = _S1572;
        }
        float3  throughput_7;
        float3  lit_0;
        if(_S1566)
        {
            float3  _S1580 = (&ray_2)->origin;
            if(_S1515)
            {
                throughput_7 = _S1299;
            }
            else
            {
                throughput_7 = _S1486.smooth_n;
            }
            FKSurface _S1581 = surface_13;
            uint _S1582 = noiseAddress(_S1327, b_7);
            ShadowContext _S1583 = context_5;
            TreeSample _S1584 = sampleLightTree_0(_S1580, throughput_7, surface_13.geometry_n, surface_13.geometry_offset, _S1520, _S1582, &_S1583);
            bool _S1585 = any_1((_S1584.radiance) != _S1299);
            if(_S1585)
            {
                if(_S1515)
                {
                    uint _S1586 = (fcptMaxBounces());
                    bool _S1587 = b_7 < _S1586;
                    FKSurface _S1588 = surface_13;
                    TreeSample _S1589 = _S1584;
                    float3  _S1590 = hairLight_0(&_S1588, (&ray_2)->unit_direction, &_S1589, _S1587);
                    lit_0 = _S1590;
                }
                else
                {
                    float _S1591 = _S1510.x;
                    float _S1592 = _S1510.y;
                    uint _S1593 = (fcptMaxBounces());
                    bool _S1594 = b_7 < _S1593;
                    TreeSample _S1595 = _S1584;
                    BSDFMaterial _S1596 = _S1509;
                    float3  _S1597 = lightBSDF_0((&ray_2)->unit_direction, &_S1595, _S1486.smooth_n, _S1581.geometry_n, &_S1596, _S1591, _S1592, _S1594, surface_13.random_state);
                    lit_0 = _S1597;
                }
            }
            else
            {
                lit_0 = _S1299;
            }
            light_3 = _S1584;
        }
        else
        {
            light_3 = _S1567;
            lit_0 = _S1299;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1598;
        bool _S1599;
        float density_4;
        if(_S1552)
        {
            bool _S1600 = !_S1485;
            if(_S1600)
            {
                return _S1300;
            }
            uint _S1601 = extractBits_0(_S1301, 23U, 1U);
            bool _S1602 = _S1547 != (_S1601 == 1U);
            if(_S1602)
            {
                return _S1300;
            }
            float3  throughput_8 = throughput_6 * make_float3 (geometry_density_2);
            float density_5 = density_2 * geometry_density_2;
            if(_S1560)
            {
                viewed_1 = _S1305 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                float3  _S1603 = pathColor(throughput_8 * emission_1, spectral_weight_0, wavelength_9);
                return Shift_x24init_0(_S1603 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1560)
            {
                refracted_4 = _S1305 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S1604 = !nee_0;
                if(_S1604)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1605 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1605 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1300;
                }
                float3  _S1606 = pathColor(throughput_8 * lit_0, spectral_weight_0, wavelength_9);
                return Shift_x24init_0(_S1606 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1560)
            {
                wrong_side_0 = _S1305 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1607 = !nee_0;
                if(_S1607)
                {
                    return _S1300;
                }
                bool _S1608 = (fcptWorldReadsPath());
                if(_S1608)
                {
                    float _S1609 = environmentPdf_0(r_8->dir);
                    uint _S1610 = b_7 + 1U;
                    FKSurface _S1611 = surface_13;
                    float3  _S1612 = skyColor_0((&ray_2)->unit_direction, r_8->dir, &_S1611, wavelength_9, _S1510, is_inside_8, _S1609, surface_13.random_state, _S1610);
                    float3  _S1613 = pathColor(throughput_8 * (_S1612 * r_8->radiance), spectral_weight_0, wavelength_9);
                    return Shift_x24init_0(_S1613 / make_float3 (r_8->jac), density_5 / r_8->jac);
                }
                float _S1614 = environmentPdf_0(r_8->dir);
                float3  _S1615 = skyBSDF((&ray_2)->unit_direction, r_8->dir, surface_13, _S1509, _S1510, is_inside_8, _S1614, surface_13.random_state);
                float3  _S1616 = pathColor(throughput_8 * _S1615 * r_8->radiance, spectral_weight_0, wavelength_9);
                return Shift_x24init_0(_S1616 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            uint _S1617 = extractBits_0(_S1301, 21U, 1U);
            bool _S1618 = nee_0 != (_S1617 == 1U);
            if(_S1618)
            {
                return _S1300;
            }
            throughput_7 = throughput_8;
            density_4 = density_5;
        }
        else
        {
            if(replay_2)
            {
                viewed_1 = _S1553;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1619 = !scatter_2;
                if(_S1619)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1620 = _S1304 != 1U;
                    if(_S1620)
                    {
                        refracted_4 = _S1304 != 3U;
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
                bool _S1621 = _S1304 == 2U;
                if(_S1621)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1485;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1305 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1515)
                    {
                        return _S1300;
                    }
                    uint _S1622 = noiseAddress(_S1327, b_7);
                    FKRay _S1623 = ray_2;
                    FKSurface _S1624 = surface_13;
                    ShadowContext _S1625 = context_5;
                    SkySample _S1626 = sampleSky_0(&_S1623, &_S1624, wavelength_9, _S1510, is_inside_8, _S1622, surface_13.random_state, &_S1625);
                    float3  _S1627 = pathColor(throughput_6 * _S1626.color, spectral_weight_0, wavelength_9);
                    return Shift_x24init_0(_S1627, 1.0f);
                }
                if(_S1621)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1485;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1628 = rgb_to_greyscale(light_3.radiance);
                    bool _S1629 = !(_S1628 > 0.0f);
                    if(_S1629)
                    {
                        return _S1300;
                    }
                    float3  _S1630 = pathColor(throughput_6 * lit_0, spectral_weight_0, wavelength_9);
                    return Shift_x24init_0(_S1630, 1.0f);
                }
                if(_S1314)
                {
                    passes_0 = _S1305 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1448;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float3  _S1631 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_9);
                    return Shift_x24init_0(_S1631, 1.0f);
                }
                if(_S1314)
                {
                    passes_0 = _S1305 == 1U;
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
                    passes_0 = !_S1485;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float3  _S1632 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_9);
                    return Shift_x24init_0(_S1632, 1.0f);
                }
                return _S1300;
            }
            else
            {
                if(_S1524)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1633 = b_7 > 0U;
                    if(_S1633)
                    {
                        Reservoir candidate_5 = chain_0;
                        if(_S1539)
                        {
                            float3  _S1634 = safeDivide(throughput_6 * emission_1, chain_throughput_0);
                            (&candidate_5)->radiance = _S1634;
                        }
                        else
                        {
                            if(_S1485)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1635 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_9);
                        Reservoir _S1636 = withEnd(candidate_5, 1U, b_7, _S1635);
                        offer(sel_7, _S1636, _S1635 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1637 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_9);
                        float3  _S1638 = sel_7->glow + _S1637;
                        sel_7->glow = _S1638;
                    }
                    if(nee_0)
                    {
                        float3  _S1639 = pathColor(throughput_6 * lit_0, spectral_weight_0, wavelength_9);
                        Reservoir candidate_6 = chain_0;
                        if(_S1539)
                        {
                            float3  _S1640 = safeDivide(_S1639, chain_throughput_0);
                            (&candidate_6)->radiance = _S1640;
                        }
                        else
                        {
                            if(_S1485)
                            {
                                candidate_6 = here_0;
                                uint _S1641 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1641;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1642 = insertBits_0(_S1329, b_7 + 1U, 5U, 5U);
                                uint _S1643 = insertBits_0(_S1642, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1643;
                            }
                        }
                        Reservoir _S1644 = withEnd(candidate_6, 0U, b_7, _S1639);
                        offer(sel_7, _S1644, _S1639 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1515)
                        {
                            _S1598 = false;
                        }
                        else
                        {
                            bool _S1645 = environmentMapped_0();
                            _S1598 = _S1645;
                        }
                    }
                    else
                    {
                        _S1598 = false;
                    }
                    if(_S1598)
                    {
                        uint _S1646 = (fcptMaxBounces());
                        _S1599 = b_7 < _S1646;
                    }
                    else
                    {
                        _S1599 = false;
                    }
                    if(_S1599)
                    {
                        uint _S1647 = noiseAddress(_S1327, b_7);
                        FKRay _S1648 = ray_2;
                        FKSurface _S1649 = surface_13;
                        ShadowContext _S1650 = context_5;
                        SkySample _S1651 = sampleSky_0(&_S1648, &_S1649, wavelength_9, _S1510, is_inside_8, _S1647, surface_13.random_state, &_S1650);
                        float3  _S1652 = pathColor(throughput_6 * _S1651.color, spectral_weight_0, wavelength_9);
                        Reservoir candidate_7 = chain_0;
                        if(_S1539)
                        {
                            float3  _S1653 = safeDivide(_S1652, chain_throughput_0);
                            (&candidate_7)->radiance = _S1653;
                        }
                        else
                        {
                            if(_S1485)
                            {
                                candidate_7 = here_0;
                                uint _S1654 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1654;
                                (&candidate_7)->dir = _S1651.dir;
                                (&candidate_7)->radiance = _S1651.radiance;
                            }
                            else
                            {
                                uint _S1655 = insertBits_0(_S1329, b_7 + 1U, 5U, 5U);
                                uint _S1656 = insertBits_0(_S1655, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1656;
                            }
                        }
                        Reservoir _S1657 = withEnd(candidate_7, 4U, b_7, _S1652);
                        offer(sel_7, _S1657, _S1652 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                }
            }
            throughput_7 = throughput_6;
            density_4 = density_2;
        }
        bool _S1658;
        bool _S1659;
        bool _S1660;
        bool straight_0;
        bool _S1661;
        bool _S1662;
        bool _S1663;
        bool _S1664;
        bool _S1665;
        bool _S1666;
        bool _S1667;
        bool _S1668;
        bool _S1669;
        bool _S1670;
        bool _S1671;
        bool _S1672;
        float density_6;
        float sky_pdf_2;
        float spread_5;
        uint b_10;
        float3  throughput_9;
        float3  throughput_10;
        float3  throughput_11;
        if(scatter_2)
        {
            if(replay_2)
            {
                viewed_1 = _S1553;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1673 = extractBits_0(_S1301, 15U, 3U);
            uint _S1674 = extractBits_0(_S1301, 18U, 3U);
            uint _S1675 = _slang_select(_S1552, _S1674,_S1673);
            float3  _S1676 = r_8->dir;
            bool refracted_5 = _S1675 == 1U;
            SampleBSDF _S1677 = SampleBSDF_x24init_0(_S1299, _S1299, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1677;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1678 = extractBits_0(_S1301, 22U, 1U);
                bool _S1679 = is_inside_8 != (_S1678 == 1U);
                if(_S1679)
                {
                    return _S1300;
                }
                bool _S1680 = _S1304 == 1U;
                if(_S1680)
                {
                    float3  _S1681 = (fcptHitPosition((_S1316)));
                    throughput_9 = _S1681;
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
                    BSDFMaterial _S1682 = _S1509;
                    bool _S1683 = isTranslucent_0(&_S1682);
                    if(_S1683)
                    {
                        refracted_4 = _S1675 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1684 = throughput_9 - (&ray_2)->origin;
                        float3  _S1685 = _slang_select(_S1680, _S1684,_S1676);
                        wrong_side_0 = (dot_0(_S1486.smooth_n, _S1685) * _S1487) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1680)
                {
                    float3  _S1686 = (&ray_2)->origin;
                    FKSurface _S1687 = surface_13;
                    float3  _S1688 = - _S1486.smooth_n;
                    bool _S1689 = is_inside_8 != refracted_4;
                    float3  _S1690 = _slang_select(_S1689, _S1688,_S1486.smooth_n);
                    float3  _S1691 = throughput_9 - (_S1686 + make_float3 (_S1687.geometry_offset) * _S1690);
                    float3  _S1692 = ((((_S1691)) * make_float3(rnorm3df(((_S1691)).x, ((_S1691)).y, ((_S1691)).z))));
                    reconnection_1 = _S1692;
                }
                else
                {
                    reconnection_1 = _S1676;
                }
                if(_S1515)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1693 = wrongSide_0(is_inside_8, refracted_4, reconnection_1, surface_13.geometry_n);
                    wrong_side_0 = _S1693;
                }
                if(wrong_side_0)
                {
                    return _S1300;
                }
                float3  _S1694 = throughput_9;
                throughput_9 = reconnection_1;
                b_10 = _S1675;
                wrong_side_0 = false;
                reconnection_1 = _S1694;
            }
            else
            {
                bool _S1695 = !_S1552;
                if(_S1695)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1696;
                    if(_S1515)
                    {
                        SampleBSDF _S1697 = (fcptSampleHair((surface_13.hair), (_S1509.albedo), (_S1509.specular_tint), ((&ray_2)->unit_direction), (surface_13.random_state)));
                        _S1696 = _S1697;
                    }
                    else
                    {
                        SampleBSDF _S1698 = sampleBSDF((&ray_2)->unit_direction, _S1486.smooth_n, _S1509, _S1510.x, _S1510.y, surface_13.random_state, _S1569);
                        _S1696 = _S1698;
                    }
                    bsdf_sampled_0 = _S1696;
                    if(_S1515)
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
                            return _S1300;
                        }
                        break;
                    }
                    if(_S1515)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1699 = wrongSide_0(is_inside_8, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_13.geometry_n);
                        wrong_side_0 = _S1699;
                    }
                    if(wrong_side_0)
                    {
                        _S1598 = (_S1509.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1598 = false;
                    }
                    if(_S1598)
                    {
                        SampleBSDF _S1700 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_13.geometry_n, _S1509, _S1510.x, _S1510.y, (&bsdf_sampled_0)->random_state, _S1569);
                        (&bsdf_sampled_0)->unit_direction = _S1700.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1700.refracted;
                        (&bsdf_sampled_0)->throughput = _S1700.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1701 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_13.geometry_n)) * surface_13.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1701;
                        }
                    }
                    uint _S1702 = (&bsdf_sampled_0)->lobe;
                    float3  _S1703 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1704 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1705 = (&bsdf_sampled_0)->pdf;
                    float _S1706 = _slang_select(wrong_side_0, 0.0f,_S1705);
                    (&lobe_5)->pdf = _S1706;
                    throughput_9 = _S1703;
                    b_10 = _S1702;
                    refracted_4 = _S1704;
                }
                else
                {
                    throughput_9 = _S1676;
                    b_10 = _S1675;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1598 = true;
            }
            else
            {
                _S1598 = _S1552;
            }
            float3  chain_throughput_1;
            if(_S1598)
            {
                if(_S1515)
                {
                    SampleBSDF _S1707 = (fcptConnectHair((surface_13.hair), (_S1509.albedo), (_S1509.specular_tint), ((&ray_2)->unit_direction), (throughput_9)));
                    lobe_5 = _S1707;
                }
                else
                {
                    float3  _S1708 = (&ray_2)->unit_direction;
                    float3  _S1709 = negate_0(_S1708);
                    float _S1710 = sign_0(_S1487);
                    float3  _S1711 = _S1486.smooth_n * make_float3 (_S1710);
                    float _S1712 = dot_0(_S1711, throughput_9);
                    float _S1713 = _S1509.roughness;
                    float _S1714 = _S1713 * _S1713;
                    AnisotropicFrame _S1715 = anisotropicFrame(_S1509, _S1711);
                    SheenProfile _S1716 = sheenProfile(_S1709, _S1711, _S1509);
                    float3  _S1717 = reflectedHalf(_S1708, throughput_9);
                    bool _S1718 = b_10 == 1U;
                    if(_S1718)
                    {
                        float3  _S1719 = refractedHalf(_S1708, throughput_9, _S1486.smooth_n, _S1510.x, _S1510.y);
                        throughput_10 = _S1719;
                    }
                    else
                    {
                        throughput_10 = _S1717;
                    }
                    bool _S1720 = b_10 == 0U;
                    if(_S1720)
                    {
                        _S1599 = true;
                    }
                    else
                    {
                        _S1599 = b_10 == 6U;
                    }
                    if(_S1599)
                    {
                        float3  _S1721 = sampledHalf(_S1709, _S1711, _S1714, _S1715, surface_13.random_state);
                        throughput_11 = _S1721;
                    }
                    else
                    {
                        throughput_11 = throughput_10;
                    }
                    float _S1722 = _S1510.x;
                    float _S1723 = _S1510.y;
                    Weights _S1724 = lobeWeights(_S1708, _S1709, _S1711, throughput_11, _S1715, _S1716, _S1509, _S1722, _S1723);
                    float _S1725 = (F32_abs((_S1487)));
                    float _S1726 = vndfPDF(_S1709, throughput_11, _S1711, _S1725, _S1714, _S1715, _S1724.v_dot_h);
                    switch(b_10)
                    {
                    case 0U:
                        {
                            float _S1727 = diffusePDF(_S1712, _S1725, _S1509, _S1724);
                            float3  _S1728 = diffuseBSDF(throughput_9, _S1711, _S1509, _S1724);
                            density_6 = _S1727;
                            chain_throughput_1 = _S1728;
                            break;
                        }
                    case 1U:
                        {
                            float _S1729 = refractPDF(dot_0(throughput_9, throughput_11), _S1726, _S1724, _S1722, _S1723);
                            float3  _S1730 = refractBSDF(throughput_9, _S1711, _S1714, _S1715, _S1509, _S1724);
                            density_6 = _S1729;
                            chain_throughput_1 = _S1730;
                            break;
                        }
                    case 4U:
                        {
                            float _S1731 = sheenVelvetPDF(_S1712, _S1725, _S1724);
                            float3  _S1732 = sheenVelvetBSDF(throughput_9, _S1709, _S1711, _S1509, _S1724);
                            density_6 = _S1731;
                            chain_throughput_1 = _S1732;
                            break;
                        }
                    case 6U:
                        {
                            ToonProfile _S1733 = toonProfile(_S1709, _S1711, _S1509);
                            float _S1734 = toonPDF(throughput_9, _S1711, _S1733, _S1724);
                            float3  _S1735 = toonBSDF(throughput_9, _S1711, _S1733, _S1724);
                            density_6 = _S1734;
                            chain_throughput_1 = _S1735;
                            break;
                        }
                    default:
                        {
                            float _S1736 = reflectPDF(_S1726, _S1724);
                            float3  _S1737 = reflectBSDF(throughput_9, _S1711, _S1714, _S1715, _S1724);
                            density_6 = _S1736;
                            chain_throughput_1 = _S1737;
                            break;
                        }
                    }
                    bool _S1738 = density_6 > 0.0f;
                    if(_S1738)
                    {
                        SampleBSDF _S1739 = SampleBSDF_x24init_0(throughput_9, chain_throughput_1, surface_13.random_state, _S1718, b_10, density_6);
                        lobe_5 = _S1739;
                    }
                }
            }
            bool _S1740 = b_10 == 0U;
            if(_S1740)
            {
                _S1599 = true;
            }
            else
            {
                _S1599 = b_10 == 4U;
            }
            if(_S1599)
            {
                _S1658 = true;
            }
            else
            {
                _S1658 = b_10 == 6U;
            }
            if(_S1515)
            {
                _S1659 = false;
            }
            else
            {
                bool _S1741 = !_S1658;
                if(_S1741)
                {
                    bool _S1742 = (_S1509.roughness) == 0.0f;
                    if(_S1742)
                    {
                        _S1659 = true;
                    }
                    else
                    {
                        bool _S1743 = b_10 == 1U;
                        if(_S1743)
                        {
                            _S1659 = (_S1510.x) == (_S1510.y);
                        }
                        else
                        {
                            _S1659 = false;
                        }
                    }
                }
                else
                {
                    _S1659 = false;
                }
            }
            bool _S1744 = !_S1515;
            if(_S1744)
            {
                _S1660 = b_10 == 1U;
            }
            else
            {
                _S1660 = false;
            }
            if(_S1660)
            {
                straight_0 = (_S1509.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1661 = _S1744;
            }
            else
            {
                _S1661 = false;
            }
            if(_S1661)
            {
                _S1662 = b_10 == 1U;
            }
            else
            {
                _S1662 = false;
            }
            if(_S1662)
            {
                _S1663 = (_S1510.x) == (_S1510.y);
            }
            else
            {
                _S1663 = false;
            }
            BSDFMaterial _S1745 = _S1509;
            bool _S1746 = isTranslucent_0(&_S1745);
            if(_S1746)
            {
                _S1664 = _S1740;
            }
            else
            {
                _S1664 = false;
            }
            if(_S1664)
            {
                _S1665 = (dot_0(throughput_9, surface_13.geometry_n)) < 0.0f;
            }
            else
            {
                _S1665 = false;
            }
            if(nee_0)
            {
                _S1666 = !_S1659;
            }
            else
            {
                _S1666 = false;
            }
            if(_S1666)
            {
                _S1667 = !wrong_side_0;
            }
            else
            {
                _S1667 = false;
            }
            if(_S1667)
            {
                float _S1747 = (&lobe_5)->pdf;
                float3  _S1748 = (&ray_2)->origin;
                float3  _S1749 = _slang_select(_S1520, _S1299,_S1486.smooth_n);
                float3  _S1750 = (&ray_2)->origin;
                FKSurface _S1751 = surface_13;
                float3  _S1752 = - _S1486.smooth_n;
                float3  _S1753 = _slang_select(_S1665, _S1752,_S1486.smooth_n);
                NEEVertex _S1754 = NEEVertex_x24init_0(false, _S1747, _S1748, _S1749, _S1750 + make_float3 (_S1751.geometry_offset) * _S1753);
                nee_vertex_0 = _S1754;
            }
            else
            {
                if(_S1515)
                {
                    _S1668 = true;
                }
                else
                {
                    bool _S1755 = b_10 != 1U;
                    if(_S1755)
                    {
                        _S1668 = true;
                    }
                    else
                    {
                        _S1668 = (_S1510.x) != (_S1510.y);
                    }
                }
                if(_S1668)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1756 = withinInverseFootprint((&lobe_5)->pdf, _S1658, (&prev_0)->cos, (&hit_4)->distance, threshold_2);
            bool _S1757 = roughLobe((&lobe_5)->pdf, _S1658, _S1509.roughness);
            if(_S1552)
            {
                bool _S1758 = !_S1756;
                if(_S1758)
                {
                    return _S1300;
                }
                bool _S1759 = _S1305 != 1U;
                if(_S1759)
                {
                    _S1668 = _S1305 != 2U;
                }
                else
                {
                    _S1668 = false;
                }
                if(_S1668)
                {
                    float _S1760 = (&lobe_5)->pdf;
                    float _S1761 = _slang_select(nee_0, _S1760,0.0f);
                    float _S1762 = escapeWeight_0(_S1761, _S1676);
                    if(_S1560)
                    {
                        passes_0 = _S1311;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1763 = _slang_select(passes_0, _S1762,1.0f);
                    return Shift_x24init_0(throughput_7 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_8->radiance * make_float3 (_S1763) / make_float3 (r_8->jac), density_4 * (&lobe_5)->pdf / r_8->jac);
                }
                float3  _S1764 = throughput_7 * make_float3 ((&lobe_5)->pdf);
                float _S1765 = density_4 * (&lobe_5)->pdf;
                throughput_10 = _S1764;
                density_6 = _S1765;
            }
            else
            {
                throughput_10 = throughput_7;
                density_6 = density_4;
            }
            uint _S1766 = (fcptLayers((hit_4)));
            bool _S1767 = b_10 == 1U;
            bool _S1768 = passesLayer_0(_S1766, _S1767, passes_0);
            if(viewed_1)
            {
                _S1668 = _S1768;
            }
            else
            {
                _S1668 = false;
            }
            if(_S1668)
            {
                return _S1300;
            }
            if(replay_2)
            {
                _S1669 = b_7 <= _S1315;
            }
            else
            {
                _S1669 = false;
            }
            if(_S1669)
            {
                _S1670 = _S1485;
            }
            else
            {
                _S1670 = false;
            }
            if(_S1670)
            {
                _S1671 = _S1756;
            }
            else
            {
                _S1671 = false;
            }
            if(_S1671)
            {
                _S1672 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1672 = !_S1757;
                }
                else
                {
                    _S1672 = false;
                }
            }
            if(_S1672)
            {
                return _S1300;
            }
            if(viewed_1)
            {
                float3  _S1769 = throughput_10 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1770 = (&lobe_5)->pdf;
                throughput_11 = _S1769;
                sky_pdf_2 = _S1770;
            }
            else
            {
                float3  _S1771 = throughput_10 * max_0((&lobe_5)->throughput, _S1299);
                throughput_11 = _S1771;
                sky_pdf_2 = density_6;
            }
            bool _S1772;
            if(_S1524)
            {
                _S1772 = !_S1539;
            }
            else
            {
                _S1772 = false;
            }
            bool _S1773;
            if(_S1772)
            {
                _S1773 = _S1485;
            }
            else
            {
                _S1773 = false;
            }
            bool _S1774;
            if(_S1773)
            {
                _S1774 = _S1756;
            }
            else
            {
                _S1774 = false;
            }
            if(_S1774)
            {
                chain_0 = here_0;
                uint _S1775 = insertBits_0((&chain_0)->path, b_10, 18U, 3U);
                uint _S1776 = _slang_select(nee_0, 1U,0U);
                uint _S1777 = insertBits_0(_S1775, _S1776, 21U, 1U);
                (&chain_0)->path = _S1777;
                float _S1778 = (&chain_0)->jac * (&lobe_5)->pdf;
                (&chain_0)->jac = _S1778;
                (&chain_0)->dir = throughput_9;
                chain_throughput_1 = throughput_11;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1779 = surface_13;
            Vertex _S1780 = Vertex_x24init_0(_S1757, b_10, (&lobe_5)->pdf, (F32_abs((dot_0(surface_13.geometry_n, throughput_9)))), is_inside_8);
            prev_0 = _S1780;
            float _S1781 = (&lobe_5)->pdf;
            bool _S1782;
            if(_S1767)
            {
                _S1782 = (_S1510.x) == (_S1510.y);
            }
            else
            {
                _S1782 = false;
            }
            float sky_pdf_3 = _slang_select(_S1782, sky_pdf_0,_S1781);
            float _S1783 = _slang_select(_S1515, 0.0f,sky_pdf_3);
            float _S1784 = widened_0(spread_2, (&lobe_5)->pdf, _S1659);
            bool _S1785;
            if(refracted_4)
            {
                _S1785 = !_S1665;
            }
            else
            {
                _S1785 = false;
            }
            bool is_inside_9;
            if(_S1785)
            {
                bool _S1786 = !is_inside_8;
                is_inside_9 = _S1786;
            }
            else
            {
                is_inside_9 = is_inside_8;
            }
            FKSurface _S1787 = surface_13;
            bool _S1788 = boundsVolume_0(&_S1787);
            bool _S1789;
            if(_S1788)
            {
                _S1789 = !_S1768;
            }
            else
            {
                _S1789 = false;
            }
            if(_S1789)
            {
                FKSurface faced_2 = surface_13;
                float3  _S1790 = - _S1779.geometry_n;
                float3  _S1791 = _slang_select(turned_1, _S1790,_S1779.geometry_n);
                (&faced_2)->geometry_n = _S1791;
                FKMedium _S1792 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1793 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1794 = faced_2;
                FKMedium _S1795 = _S1792;
                FKMedium _S1796 = _S1793;
                MediumSides _S1797 = mediumSides_0(&_S1794, &_S1795, filling_2, (&ray_2)->unit_direction, &_S1796);
                bool _S1798 = leavesInFront_0((&faced_2)->geometry_n, throughput_9, _S1779.geometry_n);
                float3  _S1799 = _slang_select(_S1798, _S1797.front.scatter,_S1797.behind.scatter);
                scatter_in_0 = _S1799;
                float3  _S1800 = scatter_in_0;
                float _S1801 = upsample(scatter_in_0, wavelength_9);
                float3  _S1802 = make_float3 (_S1801);
                float3  _S1803 = _slang_select(_S1547, _S1802,_S1800);
                scatter_in_0 = _S1803;
                float3  _S1804 = _slang_select(_S1798, _S1797.front.extinction,_S1797.behind.extinction);
                extinction_in_0 = _S1804;
                float3  _S1805 = extinction_in_0;
                float _S1806 = upsample(extinction_in_0, wavelength_9);
                float3  _S1807 = make_float3 (_S1806);
                float3  _S1808 = _slang_select(_S1547, _S1807,_S1805);
                extinction_in_0 = _S1808;
                float _S1809 = _slang_select(_S1798, _S1797.front.g,_S1797.behind.g);
                g_in_0 = _S1809;
                uint _S1810 = _S1797.fillings.x;
                uint _S1811 = _S1797.fillings.y;
                uint _S1812 = _slang_select(_S1798, _S1811,_S1810);
                bool _S1813 = (fcptVaryingUsed());
                uint _S1814 = _slang_select(_S1813, _S1812,4294967295U);
                filling_2 = _S1814;
            }
            (&ray_2)->unit_direction = throughput_9;
            bool _S1815 = !_S1768;
            if(_S1815)
            {
                FKSurface _S1816 = surface_13;
                float _S1817 = _slang_select(straight_0, 0.0f,_S1816.geometry_offset);
                float3  _S1818 = - _S1486.smooth_n;
                bool _S1819 = is_inside_9 != _S1665;
                float3  _S1820 = _slang_select(_S1819, _S1818,_S1486.smooth_n);
                float3  _S1821 = (&ray_2)->origin + make_float3 (_S1817) * _S1820;
                (&ray_2)->origin = _S1821;
            }
            throughput_10 = throughput_11;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1768;
            viewed_1 = _S1663;
            sky_pdf_2 = _S1783;
            spread_5 = _S1784;
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
        float density_7;
        if(_S1524)
        {
            if(_S1448)
            {
                float3  _S1822 = pathColor(throughput_10 * emission_1, spectral_weight_0, wavelength_9);
                Reservoir candidate_8 = chain_0;
                uint _S1823 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1824 = _S1823 == 1U;
                if(_S1824)
                {
                    float3  _S1825 = safeDivide(_S1822, chain_throughput_0);
                    (&candidate_8)->radiance = _S1825;
                }
                Reservoir _S1826 = withEnd(candidate_8, 2U, b_7, _S1822);
                offer(sel_7, _S1826, _S1822 * make_float3 (scale_3) / make_float3 (density_6));
            }
            if(_S1448)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1827 = survivalProbability(abs_0(throughput_10), density_6);
                density_7 = _S1827;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1828 = noiseAddress(_S1327, b_7);
            Random _S1829 = draw(_S1828, 8U);
            bool _S1830 = density_7 < (_S1829.value);
            if(_S1830)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1831 = (fcptMaxBounces());
                wrong_side_0 = b_7 >= _S1831;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1832 = density_6 * density_7;
            density_7 = _S1832;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1833 = layer_0 ^ 1U;
        uint _S1834 = _slang_select(passes_0, _S1833,0U);
        if(passes_0)
        {
            (&prev_0)->rough = false;
            (&hit_4)->distance = 0.0f;
            b_10 = b_7;
            viewed_0 = viewed_1;
            throughput_2 = throughput_10;
            density_2 = density_7;
            sky_pdf_0 = sky_pdf_2;
            spread_2 = spread_5;
            uint _S1835 = b_10 + 1U;
            b_7 = _S1835;
            layer_0 = _S1834;
            continue;
        }
        FKRay _S1836 = ray_2;
        float _S1837 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_2)
        {
            refracted_4 = _S1553;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S1304 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1838 = _slang_select(wrong_side_0, _S1837,4.294967296e+09f);
        bool _S1839 = !_S1515;
        if(straight_0)
        {
            _S1598 = true;
        }
        else
        {
            _S1598 = _S1515;
        }
        FKHit _S1840;
        if(_S1598)
        {
            _S1840 = hit_4;
        }
        else
        {
            _S1840 = _S1570;
        }
        FKHit _S1841 = (fcptTraverseInstanceBVH((_S1836), (_S1456), (_S1838), (_S1839), (_S1840), (viewed_1)));
        hit_4 = _S1841;
        if(replay_2)
        {
            _S1599 = _S1553;
        }
        else
        {
            _S1599 = false;
        }
        if(_S1599)
        {
            _S1658 = _S1304 == 1U;
        }
        else
        {
            _S1658 = false;
        }
        if(_S1658)
        {
            _S1659 = ((&hit_4)->instance_index) == (_S1316.instance_index);
        }
        else
        {
            _S1659 = false;
        }
        if(_S1659)
        {
            _S1660 = ((&hit_4)->triangle_index) == (_S1316.triangle_index);
        }
        else
        {
            _S1660 = false;
        }
        if(_S1660)
        {
            (&hit_4)->uv = _S1316.uv;
            float _S1842 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S1842;
        }
        if(replay_2)
        {
            _S1661 = _S1553;
        }
        else
        {
            _S1661 = false;
        }
        if(_S1661)
        {
            _S1662 = _S1304 == 3U;
        }
        else
        {
            _S1662 = false;
        }
        if(_S1662)
        {
            _S1663 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1663 = false;
        }
        if(_S1663)
        {
            return _S1300;
        }
        Reservoir _S1843 = chain_0;
        uint _S1844 = filling_2;
        for(;;)
        {
            bool _S1845 = (fcptVaryingUsed());
            if(_S1845)
            {
                _S1664 = _S1844 != 4294967295U;
            }
            else
            {
                _S1664 = false;
            }
            float _S1846;
            if(_S1664)
            {
                float _S1847 = (fcptMajorant((_S1844)));
                _S1846 = _S1847;
            }
            else
            {
                _S1846 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_2)
            {
                _S1665 = _S1553;
            }
            else
            {
                _S1665 = false;
            }
            if(_S1665)
            {
                _S1666 = _S1304 == 1U;
            }
            else
            {
                _S1666 = false;
            }
            if(_S1666)
            {
                _S1667 = _S1846 > 0.0f;
            }
            else
            {
                _S1667 = false;
            }
            if(_S1667)
            {
                ended_0 = _S1300;
                sky_pdf_1 = sky_pdf_2;
                spread_3 = spread_5;
                width_4 = width_3;
                density_3 = density_7;
                throughput_11 = throughput_10;
                b_10 = b_7;
                _S1668 = true;
                break;
            }
            bool _S1848 = (&prev_0)->rough;
            if(_S1848)
            {
                _S1668 = !(_S1846 > 0.0f);
            }
            else
            {
                _S1668 = false;
            }
            (&prev_0)->rough = _S1668;
            uint _S1849 = b_7 + 320U;
            bool _S1850 = b_7 == 4294967295U;
            uint _S1851 = _slang_select(_S1850, 384U,_S1849);
            uint _S1852 = stream(_S1327, _S1851);
            uint tracking_1 = _S1852;
            weight_2 = throughput_3;
            glowed_0 = _S1299;
            b_10 = b_7;
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
                    _S1298 = int(2);
                    break;
                }
                uint _S1853 = noiseAddress(_S1327, b_10);
                Random _S1854 = draw(_S1853, 10U);
                float _S1855 = freeFlight_0(_S1854.value, _S1846);
                if(_S1664)
                {
                    float3  _S1856 = (&ray_2)->origin;
                    float3  _S1857 = (&ray_2)->unit_direction;
                    float _S1858 = (&hit_4)->distance;
                    bool _S1859 = b_10 == 4294967295U;
                    uint _S1860 = _slang_select(_S1859, 0U,b_10);
                    uint _S1861 = (&prev_0)->lobe;
                    uint _S1862 = _slang_select(_S1859, 3U,_S1861);
                    float _S1863 = (fcptTrackMedium((_S1844), (_S1856), (_S1857), (_S1858), (&tracking_1), (&weight_2), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1860), (_S1862), (_S1859)));
                    spread_4 = _S1863;
                }
                else
                {
                    spread_4 = _S1855;
                }
                bool _S1864 = !(spread_4 < ((&hit_4)->distance));
                if(_S1864)
                {
                    _S1298 = int(2);
                    break;
                }
                if(_S1664)
                {
                    _S1669 = _S1524;
                }
                else
                {
                    _S1669 = false;
                }
                if(_S1669)
                {
                    float3  _S1865 = pathColor(throughput_11 * glowed_0, spectral_weight_0, wavelength_9);
                    float3  _S1866 = _S1865 / make_float3 (density_3);
                    float3  _S1867 = sel_7->glow + _S1866;
                    sel_7->glow = _S1867;
                }
                else
                {
                }
                glowed_0 = _S1299;
                uint b_11 = b_10 + 1U;
                float3  _S1868 = (&ray_2)->origin + make_float3 (spread_4) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1868;
                float3  _S1869 = flightWeight_0(scatter_in_0, extinction_in_0, _S1846, spread_4, true);
                float3  _S1870 = weight_2;
                float _S1871 = upsample(weight_2, wavelength_9);
                float3  _S1872 = make_float3 (_S1871);
                float3  _S1873 = _slang_select(_S1547, _S1872,_S1870);
                float3  _S1874 = _slang_select(_S1664, _S1873,_S1869);
                float3  throughput_12 = throughput_11 * _S1874;
                uint _S1875 = stream(_S1327, b_11 + 320U);
                tracking_1 = _S1875;
                weight_2 = throughput_3;
                float width_7 = width_4 + spread_3 * spread_4;
                float _S1876 = spread_3 + 3.14159274101257324f;
                bool _S1877 = scatterSampled_0(replay_2, b_11, _S1315, _S1664);
                TreeSample light_4;
                if(_S1877)
                {
                    float3  _S1878 = (&ray_2)->origin;
                    float3  _S1879 = (&ray_2)->unit_direction;
                    float3  _S1880 = (&ray_2)->unit_direction;
                    uint _S1881 = noiseAddress(_S1327, b_11);
                    float3  _S1882 = extinction_in_0;
                    float3  _S1883 = extinction_in_0;
                    uint2  _S1884 = make_uint2 (_S1844);
                    float3  _S1885 = (&ray_2)->unit_direction;
                    uint _S1886 = arrivalLobe_0(b_11, (&prev_0)->lobe);
                    FKHit _S1887 = _S1570;
                    ShadowContext _S1888 = ShadowContext_x24init_0(_S1882, _S1883, _S1884, _S1885, b_11, _S1886, false, spread_4, width_7, &_S1887, false);
                    ShadowContext _S1889 = _S1888;
                    TreeSample _S1890 = sampleLightTree_0(_S1878, _S1879, _S1880, 0.0f, true, _S1881, &_S1889);
                    light_4 = _S1890;
                }
                else
                {
                    light_4 = _S1567;
                }
                float _S1891 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1892 = (fcptMaxBounces());
                bool _S1893 = b_11 < _S1892;
                if(_S1893)
                {
                    _S1670 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1670 = false;
                }
                float _S1894 = _slang_select(_S1670, _S1891,0.0f);
                float3  _S1895 = throughput_12 * light_4.radiance;
                float _S1896 = powerHeuristic(light_4.density, _S1894);
                float3  _S1897 = pathColor(_S1895 * make_float3 (_S1891 * _S1896), spectral_weight_0, wavelength_9);
                float3  _S1898 = _slang_select(_S1877, _S1897,_S1299);
                if(replay_2)
                {
                    _S1671 = b_11 == _S1315;
                }
                else
                {
                    _S1671 = false;
                }
                if(_S1671)
                {
                    bool _S1899 = _S1304 == 2U;
                    if(_S1899)
                    {
                        float _S1900 = resamplingTarget(_S1898);
                        _S1672 = _S1900 > 0.0f;
                    }
                    else
                    {
                        _S1672 = false;
                    }
                    if(_S1672)
                    {
                        Shift _S1901 = Shift_x24init_0(_S1898, 1.0f);
                        _S1298 = int(1);
                        ended_0 = _S1901;
                        spread_4 = _S1876;
                        width_5 = width_7;
                        throughput_9 = throughput_12;
                        b_8 = b_11;
                        break;
                    }
                    _S1298 = int(1);
                    ended_0 = _S1300;
                    spread_4 = _S1876;
                    width_5 = width_7;
                    throughput_9 = throughput_12;
                    b_8 = b_11;
                    break;
                }
                if(_S1524)
                {
                    Reservoir candidate_9 = _S1843;
                    uint _S1902 = extractBits_0(_S1843.path, 24U, 8U);
                    uint _S1903 = insertBits_0(0U, _S1902, 24U, 8U);
                    uint _S1904 = extractBits_0(_S1843.path, 10U, 2U);
                    bool _S1905 = _S1904 == 1U;
                    if(_S1905)
                    {
                        float3  _S1906 = safeDivide(_S1898, chain_throughput_0);
                        (&candidate_9)->radiance = _S1906;
                    }
                    else
                    {
                        uint _S1907 = insertBits_0(_S1903, b_11 + 1U, 5U, 5U);
                        uint _S1908 = insertBits_0(_S1907, 2U, 10U, 2U);
                        (&candidate_9)->path = _S1908;
                    }
                    Reservoir _S1909 = withEnd(candidate_9, 0U, b_11, _S1898);
                    offer(sel_7, _S1909, _S1898 * make_float3 (scale_3) / make_float3 (density_3));
                    float _S1910 = survivalProbability(abs_0(throughput_12), density_3);
                    uint _S1911 = noiseAddress(_S1327, b_11);
                    Random _S1912 = draw(_S1911, 8U);
                    bool _S1913 = _S1910 < (_S1912.value);
                    if(_S1913)
                    {
                        _S1672 = true;
                    }
                    else
                    {
                        uint _S1914 = (fcptMaxBounces());
                        _S1672 = b_11 >= _S1914;
                    }
                    if(_S1672)
                    {
                        _S1298 = int(1);
                        ended_0 = _S1300;
                        spread_4 = _S1876;
                        width_5 = width_7;
                        throughput_9 = throughput_12;
                        b_8 = b_11;
                        break;
                    }
                    float _S1915 = density_3 * _S1910;
                    density_3 = _S1915;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1916 = noiseAddress(_S1327, b_11);
                float3  _S1917 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1916, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1917;
                NEEVertex _S1918 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1299, (&ray_2)->origin);
                nee_vertex_0 = _S1918;
                Vertex _S1919 = scatteredVertex_0(is_inside_7);
                prev_0 = _S1919;
                float _S1920 = (&prev_0)->pdf;
                FKRay _S1921 = ray_2;
                FKHit _S1922 = (fcptTraverseInstanceBVH((_S1921), (true), (4.294967296e+09f), (false), (_S1570), (false)));
                hit_4 = _S1922;
                b_10 = b_11;
                throughput_11 = throughput_12;
                spread_3 = _S1876;
                width_4 = width_7;
                sky_pdf_1 = _S1920;
            }
            if(_S1298 != int(2))
            {
                spread_3 = spread_4;
                width_4 = width_5;
                throughput_11 = throughput_9;
                b_10 = b_8;
                _S1668 = true;
                break;
            }
            ended_0 = _S1300;
            _S1668 = false;
            break;
        }
        if(_S1668)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1669 = b_10 == b_7;
        }
        else
        {
            _S1669 = false;
        }
        bool _S1923 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S1923)
        {
            bool _S1924 = !(&nee_vertex_0)->none;
            float _S1925 = _slang_select(_S1924, sky_pdf_1,0.0f);
            float _S1926 = escapeWeight_0(_S1925, (&ray_2)->unit_direction);
            float3  _S1927 = environment_0((&ray_2)->unit_direction, b_10, (&prev_0)->lobe);
            float3  _S1928 = pathColor(throughput_11 * _S1927, spectral_weight_0, wavelength_9);
            if(replay_2)
            {
                bool _S1929 = b_10 == _S1315;
                if(_S1929)
                {
                    passes_0 = _S1304 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1928 * make_float3 (_S1926) / make_float3 (r_8->jac), density_3 / r_8->jac);
                }
                if(_S1314)
                {
                    passes_0 = _S1311;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_10 == _S1302;
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
                    return Shift_x24init_0(_S1928 * make_float3 (_S1926), 1.0f);
                }
                return _S1300;
            }
            Reservoir candidate_10 = chain_0;
            uint _S1930 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1931 = _S1930 == 1U;
            if(_S1931)
            {
                uint _S1932 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1933 = _S1932 == b_10;
                float _S1934 = _slang_select(_S1933, 1.0f,_S1926);
                float3  _S1935 = safeDivide(_S1928 * make_float3 (_S1934), chain_throughput_0);
                (&candidate_10)->radiance = _S1935;
            }
            else
            {
                bool _S1936 = (&prev_0)->rough;
                if(_S1936)
                {
                    uint _S1937 = insertBits_0(_S1329, b_10 + 1U, 5U, 5U);
                    uint _S1938 = insertBits_0(_S1937, 3U, 10U, 2U);
                    uint _S1939 = insertBits_0(_S1938, (&prev_0)->lobe, 15U, 3U);
                    bool _S1940 = (&prev_0)->inside;
                    uint _S1941 = _slang_select(_S1940, 1U,0U);
                    uint _S1942 = insertBits_0(_S1939, _S1941, 22U, 1U);
                    (&candidate_10)->path = _S1942;
                    (&candidate_10)->jac = (&prev_0)->pdf;
                    (&candidate_10)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1943 = _S1928 * make_float3 (_S1926);
            Reservoir _S1944 = withEnd(candidate_10, 3U, b_10, _S1943);
            offer(sel_7, _S1944, _S1943 * make_float3 (scale_3) / make_float3 (density_3));
            break;
        }
        float3  _S1945 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1945;
        bool _S1946 = (fcptVaryingUsed());
        if(_S1946)
        {
            _S1670 = filling_2 != 4294967295U;
        }
        else
        {
            _S1670 = false;
        }
        if(_S1670)
        {
            if(_S1524)
            {
                float3  _S1947 = pathColor(throughput_11 * glowed_0, spectral_weight_0, wavelength_9);
                float3  _S1948 = _S1947 / make_float3 (density_3);
                float3  _S1949 = sel_7->glow + _S1948;
                sel_7->glow = _S1949;
            }
            float3  _S1950 = throughput_11 * weight_2;
            throughput_9 = _S1950;
        }
        else
        {
            float3  _S1951 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S1952 = throughput_11 * _S1951;
            throughput_9 = _S1952;
        }
        float _S1953 = width_4 + spread_3 * (&hit_4)->distance;
        viewed_0 = _S1669;
        width_3 = _S1953;
        throughput_2 = throughput_9;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_2 = spread_3;
        uint _S1835 = b_10 + 1U;
        b_7 = _S1835;
        layer_0 = _S1834;
    }
    return _S1300;
}

static __device__ Shift shift_0(Domain * dom_8, Reservoir * r_9)
{
    Selection _S1954 = (Selection{});
    Selection sel_8 = _S1954;
    bool _S1955 = (r_9->w) <= 0.0f;
    if(_S1955)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S1956 = walk_0(dom_8, r_9, true, 0.0f, &sel_8);
    return _S1956;
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
    Random _S1957 = pcg(state_4);
    Random _S1958 = pcg(_S1957.state);
    float _S1959 = 6.28318548202514648f * _S1957.value;
    float _S1960 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S1958.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1958.state, _S1960 * (F32_cos((_S1959))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_5, float3  value_2)
{
    RandomSphere _S1961;
    (&_S1961)->state = state_5;
    (&_S1961)->value = value_2;
    return _S1961;
}

__device__ RandomSphere random_sphere(uint state_6)
{
    Random _S1962 = normal_distribution(state_6);
    Random _S1963 = normal_distribution(_S1962.state);
    Random _S1964 = normal_distribution(_S1963.state);
    float3  _S1965 = make_float3 (_S1962.value, _S1963.value, _S1964.value);
    float3  _S1966 = ((((_S1965)) * make_float3(rnorm3df(((_S1965)).x, ((_S1965)).y, ((_S1965)).z))));
    return RandomSphere_x24init_0(_S1964.state, _S1966);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_11)
{
    float3  _S1967 = p1_0 - p0_0;
    float3  _S1968 = p2_0 - p0_0;
    float2  _S1969 = uv1_0 - uv0_0;
    float2  _S1970 = uv2_0 - uv0_0;
    float _S1971 = _S1969.x;
    float _S1972 = _S1970.y;
    float _S1973 = _S1969.y;
    float _S1974 = _S1970.x;
    float _S1975 = _S1971 * _S1972 - _S1973 * _S1974;
    float _S1976 = 1.0f / _S1975;
    float3  t_24 = (_S1967 * make_float3 (_S1972) - _S1968 * make_float3 (_S1973)) * make_float3 (_S1976);
    float3  _S1977 = (_S1968 * make_float3 (_S1971) - _S1967 * make_float3 (_S1974)) * make_float3 (_S1976);
    float3  _S1978 = t_24 - n_11 * make_float3 (dot_0(n_11, t_24));
    float3  t_25 = ((((_S1978)) * make_float3(rnorm3df(((_S1978)).x, ((_S1978)).y, ((_S1978)).z))));
    bool _S1979 = (dot_0(cross_0(n_11, t_25), _S1977)) > 0.0f;
    float3  t_26;
    if(_S1979)
    {
        float3  _S1980 = negate_0(t_25);
        t_26 = _S1980;
    }
    else
    {
        t_26 = t_25;
    }
    float3  _S1981 = cross_0(n_11, t_26);
    return makeMatrix<float, 3, 3> (t_26, _S1981, n_11);
}

__device__ float3  tangentToWorldNormalMap(float3  v_10, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_10, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_5, float3  uvw_0, float3  position_0)
{
    float3  _S1982 = t1_0 - t0_0;
    float3  _S1983 = t2_2 - t0_0;
    float3  _S1984 = t2_2 - t1_0;
    float _S1985 = (F32_min((length_0(_S1982)), ((F32_min((length_0(_S1983)), (length_0(_S1984)))))));
    float3  _S1986 = make_float3 (distance_1(position_0, t0_0), distance_1(position_0, t1_0), distance_1(position_0, t2_2));
    float3  _S1987 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1988 = dot_0(geometry_n_5, _S1987);
    float3  _S1989 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1990 = dot_0(geometry_n_5, _S1989);
    float3  _S1991 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1992 = acos_0(abs_0(make_float3 (_S1988, _S1990, dot_0(geometry_n_5, _S1991))));
    float3  _S1993 = clamp_2(tan_0(_S1992), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S1986 * _S1993, uvw_0), 0.0f, _S1985 * 0.125f);
}

__device__ float3  straightThrough(float3  dir_16, float3  n_12, BSDFMaterial material_26)
{
    float3  _S1994 = negate_0(dir_16);
    float _S1995 = sign_0(dot_0(n_12, _S1994));
    float3  _S1996 = n_12 * make_float3 (_S1995);
    AnisotropicFrame _S1997 = anisotropicFrame(material_26, _S1996);
    bool _S1998 = (_S1997.alphas.x) > 0.0f;
    if(_S1998)
    {
        float _S1999 = material_26.transmission * (1.0f - material_26.metallic);
        float3  _S2000 = negate_0(_S1996);
        float3  _S2001 = anisotropicLocal(dir_16, _S1997.tangent, _S2000);
        float _S2002 = anisotropicG1(_S2001, _S1997.alphas);
        return make_float3 (_S1999 * _S2002) * material_26.albedo;
    }
    float _S2003 = material_26.transmission * (1.0f - material_26.metallic);
    float _S2004 = material_26.roughness;
    float _S2005 = smithG1(_S2004 * _S2004, (F32_abs((dot_0(n_12, dir_16)))));
    return make_float3 (_S2003 * _S2005) * material_26.albedo;
}

__device__ float hairRow(float3  in_dir_11, float3  t_27, float3  out_dir_3, uint p_15, float w_19, float alpha_10, uint nt_0)
{
    uint _S2006 = p_15 % 4U;
    float _S2007 = w_19 * HAIR_WIDTHS_0[_S2006];
    float _S2008 = (F32_asin((clamp_1(dot_0(out_dir_3, t_27), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_11, t_27), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S2006] * alpha_10;
    return ((F32_asinh((_S2008 / _S2007))) / (F32_asinh((3.14159274101257324f / _S2007))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_12, float3  t_28, float3  out_dir_4, uint np_0)
{
    float3  _S2009 = worldToTangent(out_dir_4, t_28);
    float3  _S2010 = worldToTangent(in_dir_12, t_28);
    return (F32_frac((((F32_atan2((_S2009.z), (_S2009.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S2010.z), (1.17549435082228751e-38f - _S2010.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_13, float3  t_29, uint p_16, float row_0, float column_0, float w_20, float alpha_11, uint nt_1, uint np_1)
{
    float3  _S2011 = worldToTangent(in_dir_13, t_29);
    uint _S2012 = p_16 % 4U;
    float _S2013 = w_20 * HAIR_WIDTHS_0[_S2012];
    float _S2014 = (F32_asin((clamp_1(dot_0(in_dir_13, t_29), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S2012] * alpha_11 + _S2013 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S2013))))));
    float _S2015 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S2011.z), (1.17549435082228751e-38f - _S2011.x)));
    float _S2016 = (F32_cos((_S2014)));
    float3  _S2017 = tangentToWorld(make_float3 (_S2016 * (F32_cos((_S2015))), (F32_sin((_S2014))), _S2016 * (F32_sin((_S2015)))), t_29);
    return _S2017;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_13, BSDFMaterial material_27, float coverage_1)
{
    float3  _S2018;
    if((material_27.ior) == 1.0f)
    {
        float3  _S2019 = straightThrough(toward_1, n_13, material_27);
        _S2018 = _S2019;
    }
    else
    {
        _S2018 = make_float3 (0.0f);
    }
    return _S2018 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_9, Reservoir r_10, bool replay_3, float scale_4, Selection * sel_9)
{
    Domain _S2020 = dom_9;
    Reservoir _S2021 = r_10;
    Shift _S2022 = walk_0(&_S2020, &_S2021, replay_3, scale_4, sel_9);
    return _S2022;
}

__device__ Shift shift_hook(Domain dom_10, Reservoir r_11)
{
    Domain _S2023 = dom_10;
    Reservoir _S2024 = r_11;
    Shift _S2025 = shift_0(&_S2023, &_S2024);
    return _S2025;
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

__device__ uint noiseWhite(uint x_29, uint y_8, uint t_30, uint size_0)
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
        uint _S2026;
        if(i_31 < 2U)
        {
            _S2026 = x_29;
        }
        else
        {
            _S2026 = (x_29 + size_0 / 2U) & (size_0 - 1U);
        }
        uint l_6 = _S2026;
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
            uint _S2027 = hash(((r_12 ^ (t_30 << 16U)) ^ (k_4 << 28U)) ^ ((i_31 & 1U) << 31U));
            uint _S2028 = l_6 ^ (_S2027 & (size_0 - 1U));
            uint k_5 = k_4 + 1U;
            l_6 = r_12;
            r_12 = _S2028;
            k_4 = k_5;
        }
        uint _S2029 = l_6 + r_12 * size_0;
        uint _S2030 = size_0 * size_0;
        uint _S2031;
        if(_S2030 >= 65536U)
        {
            uint _S2032 = _S2029 / (_S2030 / 65536U);
            _S2031 = _S2032;
        }
        else
        {
            uint _S2033 = 65536U / _S2030;
            _S2031 = _S2029 * _S2033;
        }
        ranks_0[i_31] = _S2031;
        uint i_32 = i_31 + 1U;
        i_31 = i_32;
    }
    bool _S2034 = (ranks_0[int(0)]) == 65535U;
    bool _S2035;
    if(_S2034)
    {
        _S2035 = (ranks_0[int(1)]) == 65535U;
    }
    else
    {
        _S2035 = false;
    }
    bool _S2036 = (ranks_0[int(2)]) == 65535U;
    bool _S2037;
    if(_S2036)
    {
        _S2037 = (ranks_0[int(3)]) == 65535U;
    }
    else
    {
        _S2037 = false;
    }
    if(_S2035)
    {
        _S2035 = (ranks_0[int(3)]) != 65535U;
    }
    else
    {
        _S2035 = false;
    }
    if(_S2035)
    {
        _S2035 = true;
    }
    else
    {
        if(_S2037)
        {
            _S2035 = (ranks_0[int(1)]) != 65535U;
        }
        else
        {
            _S2035 = false;
        }
    }
    uint _S2038 = ranks_0[int(0)];
    if(_S2035)
    {
        i_31 = ranks_0[int(3)];
    }
    else
    {
        i_31 = ranks_0[int(1)];
    }
    return _S2038 | (i_31 << 16U);
}

__device__ uint3  noiseBlock(uint sweep_0, uint colour_0, uint block_0, uint size_1)
{
    uint _S2039 = hash(sweep_0 * 7919U + 1U);
    uint _S2040 = size_1 / 16U;
    uint _S2041 = block_0 % _S2040;
    uint _S2042 = block_0 / _S2040;
    uint _S2043 = _S2042 % _S2040;
    uint _S2044 = block_0 / (_S2040 * _S2040);
    uint3  _S2045 = make_uint3 (_S2041, _S2043, _S2044);
    uint3  _S2046 = make_uint3 (colour_0 & 1U, (colour_0 >> 1U) & 1U, colour_0 >> 2U);
    return _S2045 * make_uint3 (16U) + _S2046 * make_uint3 (8U) + make_uint3 (_S2039 & 7U, (_S2039 >> 3U) & 7U, (_S2039 >> 6U) & 7U);
}

#undef Matrix
