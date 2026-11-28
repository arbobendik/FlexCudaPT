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
    float _S246 = node_0.phi * _S243 / (F32_max((_S229), (_S230)));
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
    uint _S338 = _S334 & 65535U;
    uint _S339 = _S334 >> 16U;
    uint _S340 = _slang_select(_S335, _S339,_S338);
    float _S341 = (float(_S340) + 0.5f) / 6.5536e+04f;
    Random _S342 = pcg(_S337.state);
    float _S343 = _slang_select(_S335, _S342.value,_S337.value);
    bool _S344 = _S334 == 4294967295U;
    float _S345 = _slang_select(_S344, _S343,_S341);
    return Random_x24init_0(address_0, _S345);
}

__device__ static const FixedArray<float, 243>  SPECTRAL_PRIMARIES_0 = { {
    0.028201999142766f, 9.99999997475242708e-07f, 0.97179698944091797f, 0.02820000052452087f, 0.0f, 0.97180002927780151f, 0.02819300070405006f, 0.0f, 0.97180700302124023f, 0.0281750001013279f, 0.0f, 0.9718250036239624f, 0.02813299931585789f, 0.0f, 0.97186702489852905f, 0.02804199978709221f, 0.0f, 0.9719579815864563f, 0.02786399982869625f, 0.0f, 0.97213602066040039f, 0.0275299996137619f, 0.0f, 0.9724699854850769f, 0.02692800015211105f, 0.0f, 0.97307199239730835f, 0.02592499926686287f, 0.0f, 0.97407501935958862f, 0.02444599941372871f, 0.0f, 0.97555398941040039f, 0.02258899994194508f, 0.0f, 0.97741097211837769f, 0.02068600058555603f, 0.0f, 0.97931402921676636f, 0.01939599961042404f, 0.0f, 0.98060399293899536f, 0.01972600072622299f, 0.0f, 0.9802740216255188f, 0.02305700071156025f, 0.0f, 0.97694301605224609f, 0.0282990001142025f, 0.00548999989405274f, 0.96621102094650269f, 0.02276800014078617f, 0.04560500010848045f, 0.93162697553634644f, 0.0118180001154542f, 0.11352799832820892f, 0.87465399503707886f, 0.00192399998195469f, 0.20037899911403656f, 0.79769700765609741f, 0.0f, 0.29692500829696655f, 0.70307499170303345f, 0.0f, 0.40064999461174011f, 0.5993499755859375f, 0.0f, 0.50742298364639282f, 0.49257698655128479f, 0.0f, 0.61289197206497192f, 0.38710799813270569f, 0.0f, 0.71311402320861816f, 0.28688600659370422f, 0.0f, 0.8042140007019043f, 0.1957859992980957f, 0.0f, 0.88220900297164917f, 0.11779099702835083f, 0.0f, 0.94313102960586548f, 0.05686900019645691f, 0.0f, 0.98336499929428101f, 0.01663500070571899f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.99855601787567139f, 0.00144400005228817f, 0.0f, 0.97892600297927856f, 0.02107400074601173f, 0.03028500080108643f, 0.92923498153686523f, 0.04047999903559685f, 0.10447199642658234f, 0.84615302085876465f, 0.04937500134110451f, 0.21104000508785248f, 0.73897498846054077f, 0.04998499900102615f, 0.33820000290870667f, 0.61719298362731934f, 0.04460699856281281f, 0.47420701384544373f, 0.49019300937652588f, 0.03559999912977219f, 0.60847699642181396f, 0.3664110004901886f, 0.02511199936270714f, 0.73185497522354126f, 0.25317299365997314f, 0.01497200038284063f, 0.83687901496887207f, 0.15642799437046051f, 0.00669299997389317f, 0.91802400350570679f, 0.08053100109100342f, 0.00144499994348735f, 0.97194302082061768f, 0.02805699966847897f, 0.0f, 0.99879997968673706f, 0.00120000005699694f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.99999898672103882f, 0.0f, 9.99999997475242708e-07f, 0.99999898672103882f, 0.0f, 9.99999997475242708e-07f, 0.99999898672103882f, 0.0f, 9.99999997475242708e-07f, 0.99999797344207764f, 9.99999997475242708e-07f, 9.99999997475242708e-07f, 0.99999797344207764f, 9.99999997475242708e-07f, 9.99999997475242708e-07f, 0.99999701976776123f, 9.99999997475242708e-07f, 1.99999999495048542e-06f, 0.99999499320983887f, 1.99999999495048542e-06f, 3.00000010611256585e-06f, 0.99999302625656128f, 1.99999999495048542e-06f, 4.99999987368937582e-06f, 0.99998897314071655f, 3.99999998990097083e-06f, 7.00000009601353668e-06f, 0.9999840259552002f, 6.00000021222513169e-06f, 0.00000999999974738f, 0.99997901916503906f, 0.0000079999999798f, 0.00001299999985349f, 0.99997401237487793f, 0.00000999999974738f, 0.0000159999999596f, 0.99997299909591675f, 0.00001200000042445f, 0.00001499999962107f, 0.99996697902679443f, 0.00001499999962107f, 0.00001800000063668f, 0.9999690055847168f, 0.00001499999962107f, 0.0000159999999596f, 0.9999619722366333f, 0.00001700000029814f, 0.00002099999983329f
} };
__device__ float upsample(float3  rgb_0, float wavelength_0)
{
    float _S346 = clamp_1((wavelength_0 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    uint _S347 = (U32_min((uint(_S346)), (79U)));
    uint _S348 = 3U * _S347;
    float3  _S349 = make_float3 (SPECTRAL_PRIMARIES_0[_S348], SPECTRAL_PRIMARIES_0[_S348 + 1U], SPECTRAL_PRIMARIES_0[_S348 + 2U]);
    float3  _S350 = make_float3 (SPECTRAL_PRIMARIES_0[_S348 + 3U], SPECTRAL_PRIMARIES_0[_S348 + 4U], SPECTRAL_PRIMARIES_0[_S348 + 5U]);
    return dot_0(rgb_0, _S349 + (_S350 - _S349) * make_float3 (_S346 - float(_S347)));
}

__device__ BSDFMaterial atWavelength(BSDFMaterial material_0, float wavelength_1)
{
    BSDFMaterial at_0 = material_0;
    float _S351 = upsample(material_0.albedo, wavelength_1);
    float3  _S352 = make_float3 (_S351);
    (&at_0)->albedo = _S352;
    float _S353 = upsample(material_0.emissive, wavelength_1);
    float3  _S354 = make_float3 (_S353);
    (&at_0)->emissive = _S354;
    float _S355 = upsample(material_0.absorption, wavelength_1);
    float3  _S356 = make_float3 (_S355);
    (&at_0)->absorption = _S356;
    float _S357 = upsample(material_0.specular_tint, wavelength_1);
    float3  _S358 = make_float3 (_S357);
    (&at_0)->specular_tint = _S358;
    float _S359 = upsample(material_0.translucent, wavelength_1);
    float3  _S360 = make_float3 (_S359);
    (&at_0)->translucent = _S360;
    float _S361 = upsample(material_0.sheen, wavelength_1);
    float3  _S362 = make_float3 (_S361);
    (&at_0)->sheen = _S362;
    float _S363 = upsample(material_0.coat_tint, wavelength_1);
    float3  _S364 = make_float3 (_S363);
    (&at_0)->coat_tint = _S364;
    return at_0;
}

__device__ BSDFMaterial pathMaterial(BSDFMaterial material_1, float wavelength_2)
{
    BSDFMaterial _S365;
    if(wavelength_2 > 0.0f)
    {
        BSDFMaterial _S366 = atWavelength(material_1, wavelength_2);
        _S365 = _S366;
    }
    else
    {
        _S365 = material_1;
    }
    return _S365;
}

static __device__ float3  negate_0(float3  x_13)
{
    return - x_13;
}

static __device__ float sign_0(float e_1)
{
    bool _S367 = e_1 < 0.0f;
    float _S368 = _slang_select(_S367, -1.0f,0.0f);
    bool _S369 = e_1 > 0.0f;
    float _S370 = _slang_select(_S369, 1.0f,_S368);
    return _S370;
}

struct AnisotropicFrame
{
    float3  tangent;
    float2  alphas;
};

static __device__ AnisotropicFrame AnisotropicFrame_x24init_0(float3  tangent_0, float2  alphas_0)
{
    AnisotropicFrame _S371;
    (&_S371)->tangent = tangent_0;
    (&_S371)->alphas = alphas_0;
    return _S371;
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_1)
{
    float3  a_1 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S372 = (F32_abs((dot_0(n_1, a_1)))) > 0.9999847412109375f;
    float3  a_2;
    if(_S372)
    {
        float3  _S373 = make_float3 (1.0f, 0.0f, 0.0f);
        a_2 = _S373;
    }
    else
    {
        a_2 = a_1;
    }
    float3  _S374 = cross_0(n_1, a_2);
    float3  _S375 = ((((_S374)) * make_float3(rnorm3df(((_S374)).x, ((_S374)).y, ((_S374)).z))));
    float3  _S376 = cross_0(n_1, _S375);
    return make_float3 (v_0.x) * _S375 + make_float3 (v_0.y) * n_1 + make_float3 (v_0.z) * _S376;
}

__device__ AnisotropicFrame anisotropicFrame(BSDFMaterial material_2, float3  n_i_0)
{
    float _S377 = material_2.roughness;
    float _S378 = _S377 * _S377;
    bool _S379 = (material_2.anisotropy) == 0.0f;
    bool _S380;
    if(_S379)
    {
        _S380 = true;
    }
    else
    {
        _S380 = !(_S378 > 0.0f);
    }
    if(_S380)
    {
        return AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f));
    }
    float3  _S381 = material_2.tangent - n_i_0 * make_float3 (dot_0(n_i_0, material_2.tangent));
    float3  _S382 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_i_0);
    bool _S383 = (dot_0(_S381, _S381)) > 0.0f;
    float3  _S384 = _slang_select(_S383, _S381,_S382);
    float3  _S385 = ((((_S384)) * make_float3(rnorm3df(((_S384)).x, ((_S384)).y, ((_S384)).z))));
    float _S386 = 6.28318548202514648f * material_2.anisotropic_rotation;
    float _S387 = (F32_sqrt((1.0f - 0.89999997615814209f * (F32_abs((material_2.anisotropy))))));
    float _S388 = 1.0f / _S387;
    bool _S389 = (material_2.anisotropy) < 0.0f;
    float _S390 = _slang_select(_S389, _S388,_S387);
    return AnisotropicFrame_x24init_0(_S385 * make_float3 ((F32_cos((_S386)))) + cross_0(n_i_0, _S385) * make_float3 ((F32_sin((_S386)))), make_float2 (_S378 / _S390, _S378 * _S390));
}

struct SheenProfile
{
    bool on;
    float albedo;
};

static __device__ SheenProfile SheenProfile_x24init_0(bool on_0, float albedo_0)
{
    SheenProfile _S391;
    (&_S391)->on = on_0;
    (&_S391)->albedo = albedo_0;
    return _S391;
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
    SheenProfile _S392 = SheenProfile_x24init_0(false, 0.0f);
    float _S393 = rgb_to_greyscale(material_3.sheen);
    bool _S394 = _S393 > 0.0f;
    SheenProfile profile_0;
    if(_S394)
    {
        float _S395 = clamp_1((F32_sqrt(((F32_max((dot_0(n_i_1, v_1)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S396 = (U32_min((uint(_S395)), (22U)));
        float _S397 = (F32_sqrt((0.05000000074505806f)));
        float _S398 = (F32_sqrt((0.00999999977648258f)));
        bool _S399 = (material_3.velvet) > 0.0f;
        float _S400 = _slang_select(_S399, _S398,_S397);
        float _S401 = (clamp_1((F32_sqrt(((F32_max((material_3.sheen_roughness), (0.0f)))))), _S400, 1.0f) - _S400) / (1.0f - _S400) * 23.0f;
        uint _S402 = (U32_min((uint(_S401)), (22U)));
        uint _S403 = _S396 * 24U + _S402;
        float _S404 = _S395 - float(_S396);
        float _S405 = _S401 - float(_S402);
        if(_S399)
        {
            uint _S406 = _S403 + 24U;
            float _S407 = VELVET_ALBEDO_0[_S403] + (VELVET_ALBEDO_0[_S406] - VELVET_ALBEDO_0[_S403]) * _S404;
            uint _S408 = _S403 + 1U;
            float _S409 = VELVET_ALBEDO_0[_S408] + (VELVET_ALBEDO_0[_S406 + 1U] - VELVET_ALBEDO_0[_S408]) * _S404;
            SheenProfile _S410 = SheenProfile_x24init_0(true, _S407 + (_S409 - _S407) * _S405);
            profile_0 = _S410;
        }
        else
        {
            uint _S411 = _S403 + 24U;
            float _S412 = SHEEN_ALBEDO_0[_S403] + (SHEEN_ALBEDO_0[_S411] - SHEEN_ALBEDO_0[_S403]) * _S404;
            uint _S413 = _S403 + 1U;
            float _S414 = SHEEN_ALBEDO_0[_S413] + (SHEEN_ALBEDO_0[_S411 + 1U] - SHEEN_ALBEDO_0[_S413]) * _S404;
            SheenProfile _S415 = SheenProfile_x24init_0(true, (F32_exp((_S412 + (_S414 - _S412) * _S405))));
            profile_0 = _S415;
        }
    }
    else
    {
        profile_0 = _S392;
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
    CoatFrame _S416;
    (&_S416)->normal = normal_3;
    (&_S416)->alpha = alpha_0;
    (&_S416)->ior = ior_0;
    return _S416;
}

__device__ __forceinline__ CoatFrame coatFrame(BSDFMaterial material_4, float3  n_2)
{
    CoatFrame _S417 = CoatFrame_x24init_0(make_float3 (0.0f), 0.0f, 0.0f);
    bool _S418 = (material_4.coat) > 0.0f;
    CoatFrame frame_0;
    if(_S418)
    {
        float3  _S419 = material_4.coat_normal;
        bool _S420 = (dot_0(_S419, _S419)) > 0.0f;
        float3  _S421 = material_4.coat_normal;
        float3  _S422 = ((((_S421)) * make_float3(rnorm3df(((_S421)).x, ((_S421)).y, ((_S421)).z))));
        float3  _S423 = _slang_select(_S420, _S422,n_2);
        float _S424 = sign_0(dot_0(_S423, n_2));
        float _S425 = material_4.coat_roughness;
        CoatFrame _S426 = CoatFrame_x24init_0(_S423 * make_float3 (_S424), _S425 * _S425, (F32_max((material_4.coat_ior), (1.00999999046325684f))));
        frame_0 = _S426;
    }
    else
    {
        frame_0 = _S417;
    }
    return frame_0;
}

__device__ __forceinline__ float3  coatSeries(CoatFrame coat_frame_0, BSDFMaterial material_5)
{
    float3  _S427 = make_float3 (0.0f);
    bool _S428 = (coat_frame_0.ior) > 0.0f;
    float3  series_0;
    if(_S428)
    {
        float _S429 = coat_frame_0.ior * coat_frame_0.ior;
        float _S430 = _S429 * _S429;
        float _S431 = coat_frame_0.ior - 1.0f;
        float _S432 = coat_frame_0.ior + 1.0f;
        float _S433 = _S429 - 1.0f;
        float _S434 = _S429 + 1.0f;
        float _S435 = _S430 - 1.0f;
        float _S436 = _S434 * _S435;
        float _S437 = 0.5f + _S431 * (3.0f * coat_frame_0.ior + 1.0f) / (6.0f * _S432 * _S432) + _S429 * _S433 * _S433 / (_S434 * _S434 * _S434) * (F32_log((_S431 / _S432))) - 2.0f * _S429 * coat_frame_0.ior * (_S429 + 2.0f * coat_frame_0.ior - 1.0f) / _S436 + 8.0f * _S430 * (_S430 + 1.0f) / (_S436 * _S435) * (F32_log((coat_frame_0.ior)));
        float _S438 = 1.0f - (1.0f - _S437) / _S429;
        float3  _S439 = material_5.coat_tint;
        float3  _S440 = _S439 * _S439 * make_float3 (1.0f - _S438) / (make_float3 (1.0f) - material_5.albedo * make_float3 (_S438));
        series_0 = _S440;
    }
    else
    {
        series_0 = _S427;
    }
    return series_0;
}

__device__ __forceinline__ float3  reflectedHalf(float3  in_dir_0, float3  out_dir_0)
{
    float3  _S441 = negate_0(in_dir_0);
    float3  _S442 = _S441 + out_dir_0;
    float3  _S443 = ((((_S442)) * make_float3(rnorm3df(((_S442)).x, ((_S442)).y, ((_S442)).z))));
    return _S443;
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
    float _S444 = dot_0(n_3, i_6);
    float _S445 = 1.0f - eta_0 * eta_0 * (1.0f - _S444 * _S444);
    if(_S445 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_6 - make_float3 (eta_0 * _S444 + (F32_sqrt((_S445)))) * n_3;
}

__device__ float fresnel(float cos_theta_0, float eta_i_0, float eta_o_0)
{
    float _S446 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S447 = eta_i_0 / eta_o_0 * _S446;
    bool _S448 = _S447 < 1.0f;
    float kr_0;
    if(_S448)
    {
        float _S449 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S447 * _S447))))));
        bool _S450 = eta_i_0 == eta_o_0;
        float _S451 = _slang_select(_S450, cos_theta_0,_S449);
        float _S452 = eta_o_0 * cos_theta_0;
        float _S453 = eta_i_0 * _S451;
        float _S454 = (_S452 - _S453) / (_S452 + _S453);
        float _S455 = eta_i_0 * cos_theta_0;
        float _S456 = eta_o_0 * _S451;
        float _S457 = (_S455 - _S456) / (_S455 + _S456);
        float _S458 = (_S454 * _S454 + _S457 * _S457) / 2.0f;
        kr_0 = _S458;
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
    float _S459 = alpha_1 * alpha_1;
    float _S460 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S459 + (1.0f - _S459) * n_dot_x_0 * n_dot_x_0))));
    bool _S461 = alpha_1 > 0.0f;
    float _S462 = _slang_select(_S461, _S460,1.0f);
    return _S462;
}

__device__ __forceinline__ float coatFresnel(float3  in_dir_1, float3  v_2, float3  coat_h_0, CoatFrame coat_frame_1, float eta_i_1, bool behind_0)
{
    float _S463 = dot_0(coat_frame_1.normal, reflect_0(in_dir_1, coat_h_0));
    float _S464 = (F32_abs((dot_0(v_2, coat_h_0))));
    float _S465 = eta_i_1 / coat_frame_1.ior * (F32_sqrt(((F32_max((1.0f - _S464 * _S464), (0.0f))))));
    float _S466 = (F32_sqrt(((F32_max((1.0f - _S465 * _S465), (0.0f))))));
    float _S467 = _slang_select(behind_0, _S466,_S464);
    float _S468 = _slang_select(behind_0, coat_frame_1.ior,1.0f);
    float _S469 = _slang_select(behind_0, 1.0f,coat_frame_1.ior);
    float _S470 = fresnel(_S467, _S468, _S469);
    float _S471 = smithG1(coat_frame_1.alpha, _S463);
    float _S472 = _S470 * _S471;
    bool _S473 = _S463 > 0.0f;
    float _S474 = _slang_select(_S473, _S472,0.0f);
    return _S474;
}

static __device__ float3  mix_0(float3  e1_0, float3  e2_0, float e3_0)
{
    return e1_0 * make_float3 (1.0f - e3_0) + e2_0 * make_float3 (e3_0);
}

static __device__ Weights Weights_x24init_0(float v_dot_h_0, float3  refracted_1, float3  F_0, float reflect_weight_0, float3  diffuse_weight_0, float3  refract_weight_0, float p_diffuse_0, float p_reflect_0, float p_refract_0, float p_sheen_velvet_0, float p_toon_0, float3  sheen_0, float3  toon_0, float3  coat_0, float p_coat_0)
{
    Weights _S475;
    (&_S475)->v_dot_h = v_dot_h_0;
    (&_S475)->refracted = refracted_1;
    (&_S475)->F = F_0;
    (&_S475)->reflect_weight = reflect_weight_0;
    (&_S475)->diffuse_weight = diffuse_weight_0;
    (&_S475)->refract_weight = refract_weight_0;
    (&_S475)->p_diffuse = p_diffuse_0;
    (&_S475)->p_reflect = p_reflect_0;
    (&_S475)->p_refract = p_refract_0;
    (&_S475)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S475)->p_toon = p_toon_0;
    (&_S475)->sheen = sheen_0;
    (&_S475)->toon = toon_0;
    (&_S475)->coat = coat_0;
    (&_S475)->p_coat = p_coat_0;
    return _S475;
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
    float _S476 = (F32_min(((F32_sqrt((material_6.specular_level))) * (F32_abs((eta_i_2 - eta_o_1))) / (eta_i_2 + eta_o_1)), (0.9999847412109375f)));
    float _S477 = _S476 * _S476;
    float _S478 = (1.0f + _S476) / (1.0f - _S476);
    float3  _S479 = make_float3 (1.0f);
    float3  _S480 = make_float3 (0.0f);
    float sheen_component_0;
    float3  sheen_1;
    float3  scale_1;
    if(sheen_profile_0.on)
    {
        float _S481 = (F32_min((sheen_profile_0.albedo), (1.0f)));
        float3  _S482 = make_float3 (1.0f) - material_6.sheen * make_float3 (_S481);
        float _S483 = rgb_to_greyscale(material_6.sheen);
        float _S484 = _S483 * _S481;
        float3  _S485 = material_6.sheen / make_float3 ((F32_max((sheen_profile_0.albedo), (1.0f))));
        sheen_component_0 = _S484;
        sheen_1 = _S485;
        scale_1 = _S482;
    }
    else
    {
        sheen_component_0 = 0.0f;
        sheen_1 = _S480;
        scale_1 = _S479;
    }
    float _S486 = (F32_abs((material_6.toon.x)));
    bool _S487 = _S486 > 0.0f;
    float toon_component_0;
    float3  toon_1;
    if(_S487)
    {
        float _S488 = (F32_min((_S486), (1.0f)));
        float3  scale_2 = scale_1 * make_float3 (1.0f - _S488);
        float _S489 = rgb_to_greyscale(material_6.albedo);
        float _S490 = _S488 * _S489;
        float3  _S491 = make_float3 (_S488) * material_6.albedo;
        toon_component_0 = _S490;
        toon_1 = _S491;
        scale_1 = scale_2;
    }
    else
    {
        toon_component_0 = 0.0f;
        toon_1 = _S480;
    }
    bool _S492 = (material_6.metallic) > 0.0f;
    float3  rebounce_0;
    if(_S492)
    {
        float _S493 = frame_1.alphas.x;
        float _S494 = (F32_sqrt(((F32_min((_S493), (frame_1.alphas.y))))));
        bool _S495 = _S493 > 0.0f;
        float _S496 = _slang_select(_S495, _S494,material_6.roughness);
        float _S497 = _S496 * _S496;
        float _S498 = (F32_pow((_S497), (1.81585001945495605f))) * (2.15371990203857422f - 0.73285001516342163f * _S497) / (1.0f + 1.28094995021820068f * _S497);
        bool _S499 = _S497 > 0.0f;
        float _S500 = _slang_select(_S499, _S498,0.0f);
        float _S501 = clamp_1(dot_0(n_i_2, v_3), 0.0f, 1.0f);
        float _S502 = _S497 * _S496;
        float _S503 = (F32_min((1.00064504146575928f - _S496 * (0.00375499995425344f + _S501 * (-0.04133399948477745f + _S501 * (-0.90938502550125122f + _S501 * 0.35275399684906006f))) - _S497 * (0.27602800726890564f + _S501 * (1.27023398876190186f + _S501 * 0.04740000143647194f)) - _S502 * (0.31452900171279907f - _S501 * 0.34830701351165771f) + _S502 * _S496 * 0.27229699492454529f), (1.0f)));
        float3  _S504 = min_1(make_float3 (1.0f) / (make_float3 (1.0f) - material_6.albedo * make_float3 (_S500)), make_float3 (1.0f / (F32_max((_S503), (0.0000152587890625f)))));
        rebounce_0 = _S504;
    }
    else
    {
        rebounce_0 = _S479;
    }
    float _S505 = dot_0(h_0, v_3);
    float _S506 = eta_i_2 / eta_o_1;
    float3  _S507 = refract_0(in_dir_2, h_0, _S506);
    float3  _S508 = ((((_S507)) * make_float3(rnorm3df(((_S507)).x, ((_S507)).y, ((_S507)).z))));
    float _S509 = (F32_abs((_S505)));
    bool _S510 = eta_i_2 > eta_o_1;
    float _S511 = _slang_select(_S510, _S478,1.0f);
    float _S512 = _slang_select(_S510, 1.0f,_S478);
    float _S513 = fresnel(_S509, _S511, _S512);
    float _S514 = eta_i_2 * eta_i_2;
    float _S515 = eta_o_1 * eta_o_1;
    bool _S516 = (_S514 * (1.0f - _S505 * _S505)) >= _S515;
    float3  _S517 = material_6.specular_tint * make_float3 (_S477);
    float3  _S518 = make_float3 (1.0f) - _S517;
    float _S519 = 1.0f - _S477;
    float3  _S520 = _S517 + _S518 * make_float3 (_S513 - _S477) / make_float3 (_S519);
    float3  _S521 = _slang_select(_S516, _S479,_S520);
    bool _S522 = (dot_0(coat_h_1, coat_h_1)) > 0.0f;
    float3  coat_1;
    float3  up_0;
    float3  through_0;
    if(_S522)
    {
        float _S523 = coatFresnel(in_dir_2, v_3, coat_h_1, coat_frame_2, eta_i_2, _S510);
        float _S524 = material_6.coat * _S523;
        float3  _S525 = material_6.coat_tint;
        float3  _S526 = _S525 * _S525;
        float3  _S527 = _slang_select(_S510, _S526,_S479);
        float3  _S528 = make_float3 (_S524) * _S527;
        float _S529 = 1.0f - _S523;
        bool _S530 = !_S510;
        float3  _S531 = _slang_select(_S530, coat_series_0,_S479);
        float3  _S532 = mix_0(_S479, make_float3 (_S529) * _S531, material_6.coat);
        float3  _S533 = mix_0(_S479, make_float3 (_S529) * material_6.coat_tint, material_6.coat);
        coat_1 = _S528;
        up_0 = _S532;
        through_0 = _S533;
    }
    else
    {
        coat_1 = _S480;
        up_0 = _S479;
        through_0 = _S479;
    }
    float3  _S534 = scale_1 * coat_1;
    float _S535 = rgb_to_greyscale(_S534);
    float3  _S536 = material_6.albedo * rebounce_0;
    float3  _S537 = mix_0(_S521, _S536, material_6.metallic);
    float3  F_1 = _S537 * scale_1 * up_0;
    float _S538 = rgb_to_greyscale(F_1);
    float _S539 = 1.0f - material_6.metallic;
    float _S540 = (1.0f - material_6.transmission) * _S539;
    float3  _S541 = make_float3 (1.0f) - _S521;
    float3  _S542 = make_float3 (_S540) * _S541 * scale_1 * up_0;
    float _S543 = material_6.transmission * _S539;
    float3  _S544 = make_float3 (_S543) * _S541 * scale_1 * through_0;
    float _S545 = (F32_max((_S538), (0.0f)));
    float _S546 = rgb_to_greyscale(_S542);
    float _S547 = (F32_max((_S546), (0.0f)));
    float _S548 = rgb_to_greyscale(_S544);
    float _S549 = sign_0(length_0(_S508));
    float _S550 = (F32_max((_S548 * _S549), (0.0f)));
    float _S551 = _S545 + _S547 + _S550 + toon_component_0 + _S535;
    float _S552 = (F32_min((sheen_component_0), (1.0f)));
    bool _S553 = sheen_component_0 > 0.0f;
    bool _S554;
    if(_S553)
    {
        _S554 = !(_S551 > 0.0f);
    }
    else
    {
        _S554 = false;
    }
    float _S555 = _slang_select(_S554, 1.0f,_S552);
    float _S556 = (1.0f - _S555) / (F32_max((_S551), (0.0000152587890625f)));
    float _S557 = _S547 * _S556;
    float _S558 = _S545 * _S556;
    float _S559 = _S550 * _S556;
    Weights _S560 = Weights_x24init_0(_S505, _S508, F_1, 1.0f, _S542, _S544, _S557, _S558, _S559, _S555, toon_component_0 * _S556, sheen_1, toon_1, _S534, _S535 * _S556);
    bool _S561 = any_1(ggx_n_0 != h_0);
    Weights leaving_0;
    if(_S561)
    {
        float _S562 = dot_0(ggx_n_0, v_3);
        float _S563 = eta_i_2 / eta_o_1;
        float3  _S564 = refract_0(in_dir_2, ggx_n_0, _S563);
        float3  _S565 = ((((_S564)) * make_float3(rnorm3df(((_S564)).x, ((_S564)).y, ((_S564)).z))));
        float _S566 = (F32_abs((_S562)));
        float _S567 = _slang_select(_S510, _S478,1.0f);
        float _S568 = _slang_select(_S510, 1.0f,_S478);
        float _S569 = fresnel(_S566, _S567, _S568);
        bool _S570 = (_S514 * (1.0f - _S562 * _S562)) >= _S515;
        float3  _S571 = _S517 + _S518 * make_float3 (_S569 - _S477) / make_float3 (_S519);
        float3  _S572 = _slang_select(_S570, _S479,_S571);
        if(_S522)
        {
            float _S573 = coatFresnel(in_dir_2, v_3, coat_h_1, coat_frame_2, eta_i_2, _S510);
            float _S574 = material_6.coat * _S573;
            float3  _S575 = material_6.coat_tint;
            float3  _S576 = _S575 * _S575;
            float3  _S577 = _slang_select(_S510, _S576,_S479);
            float3  _S578 = make_float3 (_S574) * _S577;
            float _S579 = 1.0f - _S573;
            bool _S580 = !_S510;
            float3  _S581 = _slang_select(_S580, coat_series_0,_S479);
            float3  _S582 = mix_0(_S479, make_float3 (_S579) * _S581, material_6.coat);
            float3  _S583 = mix_0(_S479, make_float3 (_S579) * material_6.coat_tint, material_6.coat);
            coat_1 = _S578;
            up_0 = _S582;
            through_0 = _S583;
        }
        else
        {
            coat_1 = _S480;
            up_0 = _S479;
            through_0 = _S479;
        }
        float3  _S584 = scale_1 * coat_1;
        float _S585 = rgb_to_greyscale(_S584);
        float3  _S586 = mix_0(_S572, _S536, material_6.metallic);
        float3  F_2 = _S586 * scale_1 * up_0;
        float _S587 = rgb_to_greyscale(F_2);
        float3  _S588 = make_float3 (1.0f) - _S572;
        float3  _S589 = make_float3 (_S540) * _S588 * scale_1 * up_0;
        float3  _S590 = make_float3 (_S543) * _S588 * scale_1 * through_0;
        float _S591 = (F32_max((_S587), (0.0f)));
        float _S592 = rgb_to_greyscale(_S589);
        float _S593 = (F32_max((_S592), (0.0f)));
        float _S594 = rgb_to_greyscale(_S590);
        float _S595 = sign_0(length_0(_S565));
        float _S596 = (F32_max((_S594 * _S595), (0.0f)));
        float _S597 = _S591 + _S593 + _S596 + toon_component_0 + _S585;
        if(_S553)
        {
            _S554 = !(_S597 > 0.0f);
        }
        else
        {
            _S554 = false;
        }
        float _S598 = _slang_select(_S554, 1.0f,_S552);
        float _S599 = (1.0f - _S598) / (F32_max((_S597), (0.0000152587890625f)));
        float _S600 = _S593 * _S599;
        float _S601 = _S591 * _S599;
        float _S602 = _S596 * _S599;
        Weights _S603 = Weights_x24init_0(_S562, _S565, F_2, 1.0f, _S589, _S590, _S600, _S601, _S602, _S598, toon_component_0 * _S599, sheen_1, toon_1, _S584, _S585 * _S599);
        leaving_0 = _S603;
    }
    else
    {
        leaving_0 = _S560;
    }
    bool _S604 = any_1(coat_n_0 != coat_h_1);
    Weights coated_0;
    if(_S604)
    {
        float _S605 = eta_i_2 / eta_o_1;
        float3  _S606 = refract_0(in_dir_2, h_0, _S605);
        float3  _S607 = ((((_S606)) * make_float3(rnorm3df(((_S606)).x, ((_S606)).y, ((_S606)).z))));
        float _S608 = _slang_select(_S510, _S478,1.0f);
        float _S609 = _slang_select(_S510, 1.0f,_S478);
        float _S610 = fresnel(_S509, _S608, _S609);
        float3  _S611 = _S517 + _S518 * make_float3 (_S610 - _S477) / make_float3 (_S519);
        float3  _S612 = _slang_select(_S516, _S479,_S611);
        bool _S613 = (dot_0(coat_n_0, coat_n_0)) > 0.0f;
        if(_S613)
        {
            float _S614 = coatFresnel(in_dir_2, v_3, coat_n_0, coat_frame_2, eta_i_2, _S510);
            float _S615 = material_6.coat * _S614;
            float3  _S616 = material_6.coat_tint;
            float3  _S617 = _S616 * _S616;
            float3  _S618 = _slang_select(_S510, _S617,_S479);
            float3  _S619 = make_float3 (_S615) * _S618;
            float _S620 = 1.0f - _S614;
            bool _S621 = !_S510;
            float3  _S622 = _slang_select(_S621, coat_series_0,_S479);
            float3  _S623 = mix_0(_S479, make_float3 (_S620) * _S622, material_6.coat);
            float3  _S624 = mix_0(_S479, make_float3 (_S620) * material_6.coat_tint, material_6.coat);
            coat_1 = _S619;
            up_0 = _S623;
            through_0 = _S624;
        }
        else
        {
            coat_1 = _S480;
            up_0 = _S479;
            through_0 = _S479;
        }
        float3  _S625 = scale_1 * coat_1;
        float _S626 = rgb_to_greyscale(_S625);
        float3  _S627 = mix_0(_S612, _S536, material_6.metallic);
        float3  F_3 = _S627 * scale_1 * up_0;
        float _S628 = rgb_to_greyscale(F_3);
        float3  _S629 = make_float3 (1.0f) - _S612;
        float3  _S630 = make_float3 (_S540) * _S629 * scale_1 * up_0;
        float3  _S631 = make_float3 (_S543) * _S629 * scale_1 * through_0;
        float _S632 = (F32_max((_S628), (0.0f)));
        float _S633 = rgb_to_greyscale(_S630);
        float _S634 = (F32_max((_S633), (0.0f)));
        float _S635 = rgb_to_greyscale(_S631);
        float _S636 = sign_0(length_0(_S607));
        float _S637 = (F32_max((_S635 * _S636), (0.0f)));
        float _S638 = _S632 + _S634 + _S637 + toon_component_0 + _S626;
        if(_S553)
        {
            _S554 = !(_S638 > 0.0f);
        }
        else
        {
            _S554 = false;
        }
        float _S639 = _slang_select(_S554, 1.0f,_S552);
        float _S640 = (1.0f - _S639) / (F32_max((_S638), (0.0000152587890625f)));
        float _S641 = _S634 * _S640;
        float _S642 = _S632 * _S640;
        float _S643 = _S637 * _S640;
        Weights _S644 = Weights_x24init_0(_S505, _S607, F_3, 1.0f, _S630, _S631, _S641, _S642, _S643, _S639, toon_component_0 * _S640, sheen_1, toon_1, _S625, _S626 * _S640);
        coated_0 = _S644;
    }
    else
    {
        coated_0 = _S560;
    }
    return Weights_x24init_0(leaving_0.v_dot_h, leaving_0.refracted, leaving_0.F, leaving_0.reflect_weight, _S560.diffuse_weight, leaving_0.refract_weight, _S560.p_diffuse, leaving_0.p_reflect, leaving_0.p_refract, _S560.p_sheen_velvet, _S560.p_toon, sheen_1, toon_1, coated_0.coat, coated_0.p_coat);
}

__device__ float translucentShare(BSDFMaterial material_7)
{
    float _S645 = rgb_to_greyscale(material_7.translucent);
    float _S646 = rgb_to_greyscale(material_7.albedo);
    float _S647 = _S645 / (_S646 + _S645);
    bool _S648 = _S645 > 0.0f;
    float _S649 = _slang_select(_S648, _S647,0.0f);
    return _S649;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float n_i_dot_v_0, BSDFMaterial material_8, Weights w_0)
{
    float _S650 = translucentShare(material_8);
    float _S651 = w_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S652 = w_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S653 = 1.0f - _S650;
    bool _S654 = n_i_dot_l_0 < 0.0f;
    float _S655 = _slang_select(_S654, _S650,_S653);
    float _S656 = _S652 * _S655;
    bool _S657 = _S650 > 0.0f;
    float _S658 = _slang_select(_S657, _S656,_S651);
    bool _S659 = n_i_dot_v_0 > 0.0f;
    float _S660 = _slang_select(_S659, _S658,0.0f);
    return _S660;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_3, BSDFMaterial material_9, Weights w_1)
{
    float _S661 = translucentShare(material_9);
    bool _S662 = (dot_0(n_i_3, l_0)) < 0.0f;
    float3  _S663 = _slang_select(_S662, material_9.translucent,material_9.albedo);
    float _S664 = 1.0f - _S661;
    float _S665 = _slang_select(_S662, _S661,_S664);
    float3  _S666 = _S663 / make_float3 (_S665);
    bool _S667 = _S661 > 0.0f;
    float3  _S668 = _slang_select(_S667, _S666,material_9.albedo);
    return w_1.diffuse_weight * _S668 / make_float3 (w_1.p_diffuse);
}

__device__ float trowbridgeReitz(float alpha_2, float n_dot_h_0)
{
    float _S669 = alpha_2 * alpha_2;
    float _S670 = (1.0f - n_dot_h_0) * (1.0f + n_dot_h_0) + _S669 * n_dot_h_0 * n_dot_h_0;
    return _S669 / (F32_max((3.14159274101257324f * _S670 * _S670), (1.17549435082228751e-38f)));
}

__device__ float3  anisotropicLocal(float3  w_2, float3  t_12, float3  n_5)
{
    return make_float3 (dot_0(w_2, t_12), dot_0(w_2, cross_0(n_5, t_12)), dot_0(w_2, n_5));
}

__device__ float anisotropicG1(float3  w_3, float2  alphas_1)
{
    float _S671 = (F32_max((w_3.z), (0.0f)));
    return 2.0f * _S671 / (_S671 + length_0(make_float3 (alphas_1.x * w_3.x, alphas_1.y * w_3.y, _S671)));
}

__device__ float anisotropicD(float3  h_1, float2  alphas_2)
{
    float _S672 = alphas_2.x;
    float _S673 = h_1.x / _S672;
    float _S674 = alphas_2.y;
    float _S675 = h_1.y / _S674;
    float _S676 = h_1.z;
    float _S677 = _S673 * _S673 + _S675 * _S675 + _S676 * _S676;
    return 1.0f / (F32_max((3.14159274101257324f * _S672 * _S674 * _S677 * _S677), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float3  v_4, float3  h_2, float3  n_i_4, float n_i_dot_v_1, float alpha_3, AnisotropicFrame frame_2, float v_dot_h_1)
{
    float _S678 = dot_0(n_i_4, h_2);
    float _S679 = smithG1(alpha_3, n_i_dot_v_1);
    float _S680 = _S679 * v_dot_h_1;
    float _S681 = trowbridgeReitz(alpha_3, _S678);
    float _S682 = _S680 * _S681 / n_i_dot_v_1;
    bool _S683 = alpha_3 > 0.0f;
    bool _S684;
    if(_S683)
    {
        _S684 = v_dot_h_1 > 0.0f;
    }
    else
    {
        _S684 = false;
    }
    if(_S684)
    {
        _S684 = _S678 > 0.0f;
    }
    else
    {
        _S684 = false;
    }
    if(_S684)
    {
        _S684 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S684 = false;
    }
    float _S685 = _slang_select(_S684, _S682,0.0f);
    bool _S686 = (frame_2.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S686)
    {
        float3  _S687 = anisotropicLocal(v_4, frame_2.tangent, n_i_4);
        float _S688 = anisotropicG1(_S687, frame_2.alphas);
        float3  _S689 = anisotropicLocal(h_2, frame_2.tangent, n_i_4);
        float _S690 = anisotropicD(_S689, frame_2.alphas);
        float _S691 = _S688 * _S690;
        float _S692 = _S691 * v_dot_h_1 / n_i_dot_v_1;
        bool _S693 = v_dot_h_1 > 0.0f;
        if(_S693)
        {
            _S684 = _S678 > 0.0f;
        }
        else
        {
            _S684 = false;
        }
        if(_S684)
        {
            _S684 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S684 = false;
        }
        float _S694 = _slang_select(_S684, _S692,0.0f);
        pdf_h_0 = _S694;
    }
    else
    {
        pdf_h_0 = _S685;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float l_dot_h_0, float pdf_h_1, Weights w_4, float eta_i_3, float eta_o_2)
{
    float _S695 = eta_i_3 * w_4.v_dot_h + eta_o_2 * l_dot_h_0;
    float _S696 = w_4.p_refract * pdf_h_1 * eta_o_2 * eta_o_2 * (F32_abs((l_dot_h_0))) / (_S695 * _S695);
    bool _S697 = eta_i_3 != eta_o_2;
    bool _S698;
    if(_S697)
    {
        _S698 = l_dot_h_0 < 0.0f;
    }
    else
    {
        _S698 = false;
    }
    float _S699 = _slang_select(_S698, _S696,0.0f);
    return _S699;
}

__device__ float maskingG1(float3  l_1, float3  n_i_5, float side_0, float alpha_4, AnisotropicFrame frame_3)
{
    float _S700 = smithG1(alpha_4, (F32_max((side_0 * dot_0(n_i_5, l_1)), (0.0f))));
    bool _S701 = (frame_3.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S701)
    {
        float3  _S702 = anisotropicLocal(l_1, frame_3.tangent, n_i_5 * make_float3 (side_0));
        float _S703 = anisotropicG1(_S702, frame_3.alphas);
        G1_l_0 = _S703;
    }
    else
    {
        G1_l_0 = _S700;
    }
    return G1_l_0;
}

__device__ __forceinline__ float3  refractBSDF(float G1_l_1, BSDFMaterial material_10, Weights w_5)
{
    bool _S704 = (material_10.ior) == 1.0f;
    float _S705 = _slang_select(_S704, 1.0f,G1_l_1);
    return w_5.refract_weight * make_float3 (_S705) * material_10.albedo / make_float3 (w_5.p_refract);
}

__device__ __forceinline__ float reflectPDF(float pdf_h_2, Weights w_6)
{
    float _S706 = w_6.p_reflect * pdf_h_2 / (4.0f * w_6.v_dot_h);
    bool _S707 = pdf_h_2 > 0.0f;
    float _S708 = _slang_select(_S707, _S706,0.0f);
    return _S708;
}

__device__ __forceinline__ float3  reflectBSDF(float G1_l_2, Weights w_7)
{
    return make_float3 (w_7.reflect_weight * G1_l_2) * w_7.F / make_float3 (w_7.p_reflect);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_1, float n_i_dot_v_2, Weights w_8)
{
    float _S709 = w_8.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S710 = n_i_dot_l_1 > 0.0f;
    bool _S711;
    if(_S710)
    {
        _S711 = n_i_dot_v_2 > 0.0f;
    }
    else
    {
        _S711 = false;
    }
    float _S712 = _slang_select(_S711, _S709,0.0f);
    return _S712;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  v_5, float3  n_i_6, BSDFMaterial material_11, Weights w_9)
{
    float3  _S713 = l_2 + v_5;
    float3  _S714 = ((((_S713)) * make_float3(rnorm3df(((_S713)).x, ((_S713)).y, ((_S713)).z))));
    float _S715 = dot_0(n_i_6, _S714);
    float _S716 = (F32_max((dot_0(n_i_6, l_2)), (0.0f)));
    float _S717 = (F32_max((dot_0(n_i_6, v_5)), (0.0f)));
    float _S718 = 1.0f / (F32_max((material_11.sheen_roughness), (0.05000000074505806f)));
    float _S719 = 1.0f - _S715 * _S715;
    float _S720 = (2.0f + _S718) * (F32_pow(((F32_max((_S719), (0.0f)))), (0.5f * _S718))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S716 + _S717 - _S716 * _S717)), (0.0000152587890625f)));
    bool _S721 = (material_11.velvet) > 0.0f;
    float f_1;
    if(_S721)
    {
        float _S722 = (F32_max((material_11.sheen_roughness), (0.00999999977648258f)));
        float _S723 = _S722 * _S722;
        float _S724 = (F32_max((_S719), (0.0000152587890625f)));
        float _S725 = (F32_exp((- _S715 * _S715 / (_S724 * _S723)))) / (3.14159274101257324f * _S723 * _S724 * _S724) * (F32_min((1.0f), (2.0f * _S715 * (F32_min((_S716), (_S717))) / (F32_max(((F32_abs((dot_0(_S714, v_5))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S716 * _S717), (0.0000152587890625f)));
        f_1 = _S725;
    }
    else
    {
        f_1 = _S720;
    }
    return w_9.sheen * make_float3 (f_1 * _S716 * 2.0f * 3.14159274101257324f / w_9.p_sheen_velvet);
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
    float _S726 = (F32_max((1.0f - (t_13 - a_3) / (F32_max((s_0), (0.0000152587890625f)))), (0.0f)));
    bool _S727 = t_13 < a_3;
    float _S728 = _slang_select(_S727, 1.0f,_S726);
    return _S728;
}

__device__ __forceinline__ float toonIntegral(float t_14, float a_4, float s_1, bool glossy_0)
{
    float _S729 = (F32_min((t_14), (a_4)));
    float _S730 = (F32_sin((_S729)));
    float _S731 = _S730 * _S730 / 2.0f;
    float _S732 = 1.0f - (F32_cos((_S729)));
    float _S733 = _slang_select(glossy_0, _S732,_S731);
    bool _S734 = t_14 > a_4;
    bool _S735;
    if(_S734)
    {
        _S735 = s_1 > 0.0f;
    }
    else
    {
        _S735 = false;
    }
    float integral_0;
    if(_S735)
    {
        if(glossy_0)
        {
            float _S736 = (F32_cos((a_4)));
            float _S737 = (F32_cos((t_14)));
            integral_0 = (1.0f + a_4 / s_1) * (_S736 - _S737) - ((F32_sin((t_14))) - t_14 * _S737 - ((F32_sin((a_4))) - a_4 * _S736)) / s_1;
        }
        else
        {
            float _S738 = 2.0f * a_4;
            float _S739 = (F32_cos((_S738)));
            float _S740 = 2.0f * t_14;
            float _S741 = (F32_cos((_S740)));
            integral_0 = (1.0f + a_4 / s_1) * (_S739 - _S741) / 4.0f - ((F32_sin((_S740))) / 8.0f - t_14 * _S741 / 4.0f - ((F32_sin((_S738))) / 8.0f - a_4 * _S739 / 4.0f)) / s_1;
        }
        float integral_1 = _S733 + integral_0;
        integral_0 = integral_1;
    }
    else
    {
        integral_0 = _S733;
    }
    return integral_0;
}

static __device__ ToonProfile ToonProfile_x24init_0(bool glossy_1, float a_5, float s_2, float b_1, float norm_0, float view_0, float3  axis_0)
{
    ToonProfile _S742;
    (&_S742)->glossy = glossy_1;
    (&_S742)->a = a_5;
    (&_S742)->s = s_2;
    (&_S742)->b = b_1;
    (&_S742)->norm = norm_0;
    (&_S742)->view = view_0;
    (&_S742)->axis = axis_0;
    return _S742;
}

__device__ __forceinline__ ToonProfile toonProfile(float3  v_6, float3  n_i_7, BSDFMaterial material_12)
{
    float _S743 = material_12.toon.x;
    bool _S744 = _S743 < 0.0f;
    float _S745 = clamp_1(material_12.toon.y / _S743, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S746 = clamp_1(material_12.toon.z / _S743, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S747 = (F32_min((_S745 + _S746), (1.57079637050628662f)));
    float _S748 = dot_0(n_i_7, v_6);
    float _S749 = toonP((F32_acos(((F32_min((_S748), (1.0f)))))), _S745, _S746);
    float3  _S750 = make_float3 (2.0f * _S748) * n_i_7 - v_6;
    float3  _S751 = ((((_S750)) * make_float3(rnorm3df(((_S750)).x, ((_S750)).y, ((_S750)).z))));
    float3  _S752 = _slang_select(_S744, _S751,n_i_7);
    float _S753 = toonIntegral(_S747, _S745, _S746, _S744);
    return ToonProfile_x24init_0(_S744, _S745, _S746, _S747, 6.28318548202514648f * _S753, _S749, _S752);
}

__device__ __forceinline__ float toonPDF(float3  l_3, float3  n_i_8, ToonProfile profile_1, Weights w_10)
{
    float _S754 = dot_0(n_i_8, l_3);
    float _S755 = dot_0(l_3, profile_1.axis);
    float _S756 = _slang_select(profile_1.glossy, _S755,_S754);
    float _S757 = (F32_acos((clamp_1(_S756, -1.0f, 1.0f))));
    float _S758 = toonP(_S757, profile_1.a, profile_1.s);
    float _S759 = w_10.p_toon * _S758;
    float _S760 = _slang_select(profile_1.glossy, 1.0f,_S754);
    float _S761 = _S759 * _S760 / profile_1.norm;
    bool _S762;
    if(profile_1.glossy)
    {
        _S762 = true;
    }
    else
    {
        _S762 = _S754 > 0.0f;
    }
    float _S763 = _slang_select(_S762, _S761,0.0f);
    return _S763;
}

__device__ __forceinline__ float3  toonBSDF(float3  l_4, float3  n_i_9, ToonProfile profile_2, Weights w_11)
{
    float _S764 = (F32_max((dot_0(n_i_9, l_4)), (0.0f)));
    float _S765 = _slang_select(profile_2.glossy, _S764,profile_2.view);
    return w_11.toon * make_float3 (_S765) / make_float3 (w_11.p_toon);
}

__device__ __forceinline__ float coatPDF(float3  v_7, float3  coat_h_2, CoatFrame coat_frame_3, Weights w_12)
{
    float _S766 = dot_0(coat_frame_3.normal, v_7);
    float _S767 = smithG1(coat_frame_3.alpha, _S766);
    float _S768 = trowbridgeReitz(coat_frame_3.alpha, dot_0(coat_frame_3.normal, coat_h_2));
    float _S769 = _S767 * _S768 / (4.0f * _S766);
    bool _S770 = (coat_frame_3.alpha) > 0.0f;
    float _S771 = _slang_select(_S770, _S769,0.0f);
    return w_12.p_coat * _S771;
}

__device__ __forceinline__ float3  coatBSDF(Weights w_13)
{
    return w_13.coat / make_float3 (w_13.p_coat);
}

__device__ __forceinline__ void BSDF(float3  in_dir_3, float3  out_dir_1, float3  n_6, BSDFMaterial material_13, float eta_i_4, float eta_o_3, bool refracted_2, Facets facets_0, FixedArray<float3 , 6>  * throughputs_0, FixedArray<float, 6>  * pdfs_0)
{
    float3  _S772 = negate_0(in_dir_3);
    float _S773 = dot_0(n_6, _S772);
    float _S774 = sign_0(_S773);
    float3  _S775 = n_6 * make_float3 (_S774);
    float _S776 = dot_0(_S775, out_dir_1);
    float _S777 = material_13.roughness;
    float _S778 = _S777 * _S777;
    AnisotropicFrame _S779 = anisotropicFrame(material_13, _S775);
    SheenProfile _S780 = sheenProfile(_S772, _S775, material_13);
    CoatFrame _S781 = coatFrame(material_13, _S775);
    float3  _S782 = coatSeries(_S781, material_13);
    float _S783 = rgb_to_greyscale(material_13.translucent);
    bool _S784 = _S783 > 0.0f;
    bool _S785 = (dot_0(n_6, out_dir_1) * _S773) < 0.0f;
    bool _S786 = (F32_abs((material_13.toon.x))) > 0.0f;
    float3  _S787 = facets_0.coat_h;
    bool _S788 = (dot_0(_S787, _S787)) > 0.0f;
    bool _S789;
    if(_S784)
    {
        _S789 = _S785;
    }
    else
    {
        _S789 = false;
    }
    bool _S790 = _S789 == refracted_2;
    bool _S791 = !refracted_2;
    if(_S791)
    {
        _S789 = _S786;
    }
    else
    {
        _S789 = false;
    }
    bool _S792;
    if(_S791)
    {
        _S792 = _S788;
    }
    else
    {
        _S792 = false;
    }
    float3  _S793 = negate_0(make_float3 (eta_i_4) * _S772 + make_float3 (eta_o_3) * out_dir_1);
    float3  _S794 = ((((_S793)) * make_float3(rnorm3df(((_S793)).x, ((_S793)).y, ((_S793)).z))));
    float3  _S795 = reflectedHalf(in_dir_3, out_dir_1);
    float _S796 = sign_0(dot_0(_S794, _S775));
    float3  _S797 = _S794 * make_float3 (_S796);
    float3  _S798 = _slang_select(refracted_2, _S797,_S795);
    float3  _S799 = make_float3 (0.0f);
    float3  _S800 = _slang_select(_S792, _S795,_S799);
    Weights _S801 = lobeWeights(in_dir_3, _S772, _S775, facets_0.h, facets_0.coat_h, _S798, _S800, _S779, _S780, _S781, _S782, material_13, eta_i_4, eta_o_3);
    float _S802 = (F32_abs((_S773)));
    float _S803 = diffusePDF(_S776, _S802, material_13, _S801);
    float _S804 = _slang_select(_S790, _S803,0.0f);
    (*pdfs_0)[int(0)] = _S804;
    float3  _S805 = diffuseBSDF(out_dir_1, _S775, material_13, _S801);
    float3  _S806 = _slang_select(_S790, _S805,_S799);
    (*throughputs_0)[int(0)] = _S806;
    float _S807 = vndfPDF(_S772, _S798, _S775, _S802, _S778, _S779, _S801.v_dot_h);
    float _S808 = refractPDF(dot_0(out_dir_1, _S798), _S807, _S801, eta_i_4, eta_o_3);
    float _S809 = _slang_select(refracted_2, _S808,0.0f);
    (*pdfs_0)[int(1)] = _S809;
    float _S810 = maskingG1(out_dir_1, _S775, -1.0f, _S778, _S779);
    float3  _S811 = refractBSDF(_S810, material_13, _S801);
    float3  _S812 = _slang_select(refracted_2, _S811,_S799);
    (*throughputs_0)[int(1)] = _S812;
    float _S813 = reflectPDF(_S807, _S801);
    float _S814 = _slang_select(_S791, _S813,0.0f);
    (*pdfs_0)[int(2)] = _S814;
    float _S815 = maskingG1(out_dir_1, _S775, 1.0f, _S778, _S779);
    float3  _S816 = reflectBSDF(_S815, _S801);
    float3  _S817 = _slang_select(_S791, _S816,_S799);
    (*throughputs_0)[int(2)] = _S817;
    float _S818 = sheenVelvetPDF(_S776, _S802, _S801);
    float _S819 = _slang_select(_S791, _S818,0.0f);
    (*pdfs_0)[int(3)] = _S819;
    float3  _S820 = sheenVelvetBSDF(out_dir_1, _S772, _S775, material_13, _S801);
    float3  _S821 = _slang_select(_S791, _S820,_S799);
    (*throughputs_0)[int(3)] = _S821;
    ToonProfile _S822 = toonProfile(_S772, _S775, material_13);
    float _S823 = toonPDF(out_dir_1, _S775, _S822, _S801);
    float _S824 = _slang_select(_S789, _S823,0.0f);
    (*pdfs_0)[int(4)] = _S824;
    float3  _S825 = toonBSDF(out_dir_1, _S775, _S822, _S801);
    float3  _S826 = _slang_select(_S789, _S825,_S799);
    (*throughputs_0)[int(4)] = _S826;
    float _S827 = coatPDF(_S772, _S800, _S781, _S801);
    float _S828 = _slang_select(_S792, _S827,0.0f);
    (*pdfs_0)[int(5)] = _S828;
    float3  _S829 = coatBSDF(_S801);
    float3  _S830 = _slang_select(_S792, _S829,_S799);
    (*throughputs_0)[int(5)] = _S830;
    return;
}

static __device__ __forceinline__ float3  skyLobes_0(float3  in_dir_4, float3  dir_5, FKSurface * surface_1, BSDFMaterial * material_14, float2  eta_1, bool is_inside_2, Facets * facets_1, float pdf_1, FixedArray<float3 , 6>  * terms_0, FixedArray<float, 6>  * pdfs_1)
{
    bool _S831 = wrongSide_0(is_inside_2, false, dir_5, surface_1->geometry_n);
    BSDF(in_dir_4, dir_5, surface_1->smooth_n, *material_14, eta_1.x, eta_1.y, _S831, *facets_1, terms_0, pdfs_1);
    float3  _S832 = make_float3 (0.0f);
    uint i_9 = 0U;
    float3  f_2 = _S832;
    for(;;)
    {
        if(i_9 < 6U)
        {
        }
        else
        {
            break;
        }
        bool _S833 = ((*pdfs_1)[i_9]) > 0.0f;
        if(_S833)
        {
            float3  _S834 = (*terms_0)[i_9] * make_float3 ((*pdfs_1)[i_9]) / make_float3 ((*pdfs_1)[i_9] + pdf_1);
            (*terms_0)[i_9] = _S834;
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
    SkySample _S835;
    (&_S835)->dir = dir_6;
    (&_S835)->radiance = radiance_0;
    (&_S835)->color = color_0;
    (&_S835)->random_state = random_state_2;
    return _S835;
}

static __device__ __noinline__ float3  skyColor_0(float3  dir_7, FixedArray<float3 , 6>  * terms_1, FixedArray<float, 6>  * pdfs_2, uint depth_1)
{
    float3  _S836 = make_float3 (0.0f);
    bool shaded_0 = false;
    float3  world_0 = _S836;
    uint i_11 = 0U;
    float3  color_1 = _S836;
    for(;;)
    {
        if(i_11 < 6U)
        {
        }
        else
        {
            break;
        }
        bool _S837 = ((*pdfs_2)[i_11]) > 0.0f;
        if(_S837)
        {
            bool _S838 = (fcptWorldReadsPath());
            bool _S839;
            if(_S838)
            {
                _S839 = true;
            }
            else
            {
                _S839 = !shaded_0;
            }
            bool shaded_1;
            float3  world_1;
            if(_S839)
            {
                bool _S840 = i_11 == 5U;
                uint _S841 = _slang_select(_S840, 5U,i_11);
                bool _S842 = i_11 == 4U;
                uint _S843 = _slang_select(_S842, 6U,_S841);
                bool _S844 = i_11 == 3U;
                uint _S845 = _slang_select(_S844, 4U,_S843);
                float3  _S846 = (fcptEnvMapSample((dir_7), (depth_1), (_S845)));
                world_1 = _S846;
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
    uint2  _S847 = (fcptEnvironmentCdfSize());
    uint2  _S848 = make_uint2 (1U, 0U);
    uint2  _S849 = _S847 - _S848;
    Random _S850 = draw(init_random_state_0, 6U);
    Random _S851 = draw(init_random_state_0, 2147483654U);
    Random _S852 = draw(init_random_state_0, 7U);
    Random _S853 = draw(init_random_state_0, 2147483655U);
    uint _S854 = _S849.x;
    uint _S855 = searchCDF_0(make_uint2 (_S854, 0U), make_uint2 (0U, 1U), _S849.y, _S850.value);
    uint _S856 = searchCDF_0(make_uint2 (0U, _S855), _S848, _S854, _S851.value);
    float2  _S857 = make_float2 ((float)_S849.x, (float)_S849.y);
    float2  _S858 = (make_float2 (float(_S856), float(_S855)) + make_float2 (_S852.value, _S853.value)) / _S857 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S859 = _S858.y;
    float _S860 = (F32_sin((_S859)));
    float _S861 = _S858.x;
    float3  _S862 = make_float3 (- _S860 * (F32_cos((_S861))), _S860 * (F32_sin((_S861))), (F32_cos((_S859))));
    float _S863 = environmentPdf_0(_S862);
    BSDFMaterial _S864 = pathMaterial(surface_2->material, wavelength_3);
    BSDFMaterial _S865 = _S864;
    FixedArray<float3 , 6>  terms_2;
    FixedArray<float, 6>  pdfs_3;
    float3  _S866 = skyLobes_0(ray_0->unit_direction, _S862, surface_2, &_S865, eta_2, is_inside_3, facets_2, _S863, &terms_2, &pdfs_3);
    bool _S867 = !(_S863 > 0.0f);
    bool _S868;
    if(_S867)
    {
        _S868 = true;
    }
    else
    {
        _S868 = all_1(_S866 == make_float3 (0.0f));
    }
    if(_S868)
    {
        float3  _S869 = make_float3 (0.0f);
        return SkySample_x24init_0(_S862, _S869, _S869, _S853.state);
    }
    bool _S870 = (fcptWorldReadsPath());
    float3  seen_0;
    if(_S870)
    {
        uint _S871 = context_2->depth + 1U;
        FixedArray<float3 , 6>  _S872 = terms_2;
        FixedArray<float, 6>  _S873 = pdfs_3;
        float3  _S874 = skyColor_0(_S862, &_S872, &_S873, _S871);
        seen_0 = _S874;
    }
    else
    {
        seen_0 = _S866;
    }
    float3  _S875 = skyRadiance_0(ray_0->origin, surface_2, is_inside_3, _S862, context_2, _S853.state);
    return SkySample_x24init_0(_S862, _S875, seen_0 * _S875, _S853.state);
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
    SampleBSDF _S876 = (fcptConnectHair((surface_3->hair), ((&surface_3->material)->albedo), ((&surface_3->material)->specular_tint), (in_dir_5), (light_1->dir)));
    float3  _S877 = _S876.throughput * make_float3 (_S876.pdf);
    float _S878 = light_1->density;
    float _S879 = 1.0f + _S876.pdf * _S876.pdf / (light_1->density * light_1->density);
    bool _S880;
    if(competing_0)
    {
        _S880 = _S878 > 0.0f;
    }
    else
    {
        _S880 = false;
    }
    float _S881 = _slang_select(_S880, _S879,1.0f);
    return _S877 / make_float3 (_S881) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_8, float3  radiance_1, float density_0, uint random_state_3)
{
    TreeSample _S882;
    (&_S882)->dir = dir_8;
    (&_S882)->radiance = radiance_1;
    (&_S882)->density = density_0;
    (&_S882)->random_state = random_state_3;
    return _S882;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_12, float3  normal_4, float * pick_0, float * probability_3)
{
    float _S883 = importance(first_1, p_12, normal_4);
    float _S884 = importance(second_1, p_12, normal_4);
    float2  _S885 = make_float2 (_S883, _S884);
    bool _S886 = _S883 == 0.0f;
    bool _S887;
    if(_S886)
    {
        _S887 = _S884 == 0.0f;
    }
    else
    {
        _S887 = false;
    }
    if(_S887)
    {
        return 2U;
    }
    float _S888 = _S883 + _S884;
    bool _S889 = _S884 > 0.0f;
    if(_S889)
    {
        _S887 = (*pick_0 * _S888) >= _S883;
    }
    else
    {
        _S887 = false;
    }
    uint _S890 = uint(_S887);
    float _S891 = (F32_min(((*pick_0 * _S888 - float(_S890) * _S883) / _slang_vector_get_element(_S885, _S890)), (0.99999994039535522f)));
    *pick_0 = _S891;
    float _S892 = *probability_3 * (_slang_vector_get_element(_S885, _S890) / _S888);
    *probability_3 = _S892;
    return _S890;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_13, float u1_0, float u2_0)
{
    float3  _S893 = center_1 - p_13;
    float _S894 = radius_1 * radius_1 / dot_0(_S893, _S893);
    float _S895 = u1_0 * _S894 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S894), (0.0f)))))));
    float _S896 = 2.0f * u1_0;
    bool _S897 = _S894 >= 1.0f;
    float _S898 = _slang_select(_S897, _S896,_S895);
    float _S899 = (F32_sqrt(((F32_max((_S898 * (2.0f - _S898)), (0.0f))))));
    float _S900 = 6.28318548202514648f * u2_0;
    float3  _S901 = make_float3 (_S899 * (F32_cos((_S900))), 1.0f - _S898, _S899 * (F32_sin((_S900))));
    float3  _S902 = ((((_S893)) * make_float3(rnorm3df(((_S893)).x, ((_S893)).y, ((_S893)).z))));
    float3  _S903 = tangentToWorld(_S901, _S902);
    return _S903;
}

__device__ float3  pointLightRadiance(float3  color_3, float intensity_0, float radius_2)
{
    return color_3 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S904 = center_2 - ray_1->origin;
    float _S905 = dot_0(_S904, ray_1->unit_direction);
    float _S906 = dot_0(_S904, _S904) - _S905 * _S905;
    float _S907 = radius_3 * radius_3;
    bool _S908 = _S906 > _S907;
    if(_S908)
    {
        return 4.294967296e+09f;
    }
    float _S909 = (F32_sqrt((_S907 - _S906)));
    float _S910 = _S905 - _S909;
    float _S911 = _S905 + _S909;
    bool _S912 = _S910 > 0.0000152587890625f;
    bool _S913;
    if(_S912)
    {
        _S913 = _S910 < max_len_0;
    }
    else
    {
        _S913 = false;
    }
    if(_S913)
    {
        return _S910;
    }
    bool _S914 = _S911 > 0.0000152587890625f;
    if(_S914)
    {
        _S913 = _S911 < max_len_0;
    }
    else
    {
        _S913 = false;
    }
    if(_S913)
    {
        return _S911;
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
    Random _S915 = draw(init_random_state_1, 4U);
    Random _S916 = draw(init_random_state_1, 5U);
    Random _S917 = draw(init_random_state_1, 2147483653U);
    float3  _S918 = make_float3 (0.0f);
    TreeSample _S919 = TreeSample_x24init_0(_S918, _S918, 0.0f, _S917.state);
    TreeSample sample_0 = _S919;
    float3  _S920 = _slang_select(sided_0, _S918,smooth_n_2);
    float3  _S921 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S915.value;
    float probability_4 = 1.0f;
    uint n_7 = 0U;
    for(;;)
    {
        uint4  _S922 = (fcptLightNode((n_7)));
        if((_S922.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S923 = (fcptLightSecond((n_7)));
        uint _S924 = n_7 + 1U;
        LightNode _S925 = (fcptLightBounds((_S924)));
        LightNode _S926 = (fcptLightBounds((_S923)));
        uint _S927 = pickChild(_S925, _S926, origin_4, _S920, &pick_1, &probability_4);
        bool _S928 = _S927 > 1U;
        if(_S928)
        {
            return sample_0;
        }
        bool _S929 = _S927 == 1U;
        uint _S930 = _slang_select(_S929, _S923,_S924);
        n_7 = _S930;
    }
    bool _S931 = n_7 == 0U;
    bool _S932;
    if(_S931)
    {
        LightNode _S933 = (fcptLightBounds((0U)));
        float _S934 = importance(_S933, origin_4, _S920);
        _S932 = !(_S934 > 0.0f);
    }
    else
    {
        _S932 = false;
    }
    if(_S932)
    {
        return sample_0;
    }
    uint4  _S935 = (fcptLightNode((n_7)));
    FKHit _S936 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S937 = (_S935.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S937)
    {
        FKLight _S938 = (fcptLight((_S935.y)));
        if(sided_0)
        {
            float _S939 = sign_0(dot_0(geometry_n_1, _S938.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S939);
            float3  _S940 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S940;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S921;
            lift_n_0 = smooth_n_2;
        }
        bool _S941 = (_S938.variance) == 0.0f;
        if(_S941)
        {
            float3  _S942 = _S938.position - emitter_point_0;
            float3  _S943 = ((((_S942)) * make_float3(rnorm3df(((_S942)).x, ((_S942)).y, ((_S942)).z))));
            (&sample_0)->dir = _S943;
            float3  _S944 = _S938.color * make_float3 (_S938.intensity) / make_float3 (dot_0(_S942, _S942) * probability_4);
            (&sample_0)->radiance = _S944;
            shadow_1 = _S942;
        }
        else
        {
            float3  _S945 = sampleSphere(_S938.position, _S938.variance, emitter_point_0, _S916.value, _S917.value);
            (&sample_0)->dir = _S945;
            float _S946 = sphereDensity(_S938.position, _S938.variance, emitter_point_0);
            float _S947 = probability_4 * _S946;
            (&sample_0)->density = _S947;
            float3  _S948 = pointLightRadiance(_S938.color, _S938.intensity, _S938.variance);
            float3  _S949 = _S948 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S949;
            FKRay _S950 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S951 = raySphere_0(_S938.position, _S938.variance, &_S950, 4.294967296e+09f);
            float3  _S952 = (&sample_0)->dir * make_float3 (_S951);
            shadow_1 = _S952;
        }
        emitter_0 = _S936;
        emitter_point_0 = _S918;
    }
    else
    {
        uint _S953 = _S935.y;
        uint _S954 = (fcptTriangleOffset((_S953)));
        uint _S955 = _S954 + _S935.z;
        Matrix<float, 3, 3>  _S956 = (fcptWorldTriangle((_S953), (_S955)));
        float _S957 = (F32_sqrt((_S916.value)));
        float2  _S958 = make_float2 (_S957 * (1.0f - _S917.value), _S957 * _S917.value);
        float3  _S959 = mul_0(make_float3 (1.0f - _S957, _S958.x, _S958.y), _S956);
        if(sided_0)
        {
            float _S960 = sign_0(dot_0(geometry_n_1, _S959 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S960);
            float3  _S961 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S961;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S962 = !((dot_0(smooth_n_2, _S959 - origin_4)) > 0.0f);
            if(_S962)
            {
                return sample_0;
            }
            emitter_point_0 = _S921;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S958, _S953, _S955, 0U, 0.0f);
        float3  _S963 = _S959 - emitter_point_0;
        float3  _S964 = ((((_S963)) * make_float3(rnorm3df(((_S963)).x, ((_S963)).y, ((_S963)).z))));
        (&sample_0)->dir = _S964;
        float _S965 = solidAngle(probability_4, cross_0(_S956.rows[int(1)] - _S956.rows[int(0)], _S956.rows[int(2)] - _S956.rows[int(0)]), _S963);
        (&sample_0)->density = _S965;
        bool _S966 = (fcptShadowFirst());
        bool _S967 = !_S966;
        if(_S967)
        {
            FKSurface _S968 = (fcptLightSurfaceAt((emitter_1), (_S959), (_S917.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S959 - origin_4))));
            (&sample_0)->random_state = _S968.random_state;
            float3  _S969 = _slang_select(_S968.skip, _S918,_S968.material.emissive);
            float3  _S970 = _S969 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S970;
        }
        shadow_1 = _S963;
        emitter_0 = emitter_1;
        emitter_point_0 = _S959;
    }
    FKHit _S971 = emitter_0;
    float3  _S972 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S917.state, &_S971);
    bool _S973 = (fcptShadowFirst());
    if(_S973)
    {
        _S932 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S932 = false;
    }
    if(_S932)
    {
        _S932 = !all_1(_S972 == _S918);
    }
    else
    {
        _S932 = false;
    }
    if(_S932)
    {
        FKSurface _S974 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S917.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S974.random_state;
        float3  _S975 = _slang_select(_S974.skip, _S918,_S974.material.emissive);
        float3  _S976 = _S975 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S976;
    }
    float3  _S977 = (&sample_0)->radiance * _S972;
    bool _S978 = all_1(_S972 == _S918);
    float3  _S979 = _slang_select(_S978, _S918,_S977);
    (&sample_0)->radiance = _S979;
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
    float _S980 = 1.0f / (1.0f + b_2 / a_6 * (b_2 / a_6));
    bool _S981 = b_2 > 0.0f;
    float _S982 = _slang_select(_S981, _S980,1.0f);
    return _S982;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S983 = vertex_0->none;
    if(_S983)
    {
        return 1.0f;
    }
    uint _S984 = (fcptLightSlot((*hit_1)));
    float _S985 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S984, light_point_1);
    float _S986 = powerHeuristic(vertex_0->pdf, _S985);
    return _S986;
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
    float _S987 = upsample(f_4, wavelength_4);
    float3  _S988 = weight_0 * make_float3 (_S987);
    bool _S989 = wavelength_4 > 0.0f;
    float3  _S990 = _slang_select(_S989, _S988,f_4);
    return _S990;
}

__device__ float3  safeDivide(float3  a_7, float3  b_3)
{
    float3  _S991 = a_7 / b_3;
    float3  _S992 = make_float3 (0.0f);
    bool3  _S993 = b_3 == _S992;
    float3  _S994 = _slang_select(_S993, _S992,_S991);
    return _S994;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_2)
{
    uint _S995 = (1U << count_2) - 1U;
    return (e_2 & (~(_S995 << offset_1))) | ((newbits_0 & _S995) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_3, uint end_type_0, uint end_0, float3  f_5)
{
    Reservoir candidate_0 = r_3;
    uint _S996 = insertBits_0(r_3.path, end_0, 0U, 5U);
    uint _S997 = insertBits_0(_S996, end_type_0, 12U, 3U);
    (&candidate_0)->path = _S997;
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
    float _S998 = rgb_to_greyscale(abs_0(f_6));
    return _S998;
}

__device__ void offer(Selection * sel_2, Reservoir candidate_1, float3  weight_1)
{
    float _S999 = resamplingTarget(weight_1);
    bool _S1000 = _S999 > 0.0f;
    bool _S1001;
    if(_S1000)
    {
        _S1001 = _S999 < 3.00000000549775576e+38f;
    }
    else
    {
        _S1001 = false;
    }
    bool _S1002 = !_S1001;
    if(_S1002)
    {
        return;
    }
    bool _S1003 = sel_2->sums;
    if(_S1003)
    {
        float3  _S1004 = sel_2->color + weight_1;
        sel_2->color = _S1004;
        return;
    }
    float _S1005 = sel_2->w_sum + _S999;
    sel_2->w_sum = _S1005;
    float3  _S1006 = sel_2->color + weight_1;
    sel_2->color = _S1006;
    Random _S1007 = pcg(sel_2->random_state);
    sel_2->random_state = _S1007.state;
    bool _S1008 = (_S1007.value * sel_2->w_sum) <= _S999;
    if(_S1008)
    {
        sel_2->r = candidate_1;
    }
    return;
}

static __device__ Shift escape_0(Reservoir * r_4, bool replay_1, uint stop_0, uint rc_0, uint end_1, uint end_type_1, float scale_3, uint strata_0, Reservoir * chain_0, float3  chain_throughput_0, uint b_4, FKRay * ray_2, float3  throughput_0, float density_1, Vertex * prev_0, NEEVertex * nee_vertex_0, float sky_pdf_0, float3  spectral_weight_0, float wavelength_5, Selection * sel_3)
{
    Shift _S1009 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
    bool _S1010 = !nee_vertex_0->none;
    float _S1011 = _slang_select(_S1010, sky_pdf_0,0.0f);
    float3  _S1012 = ray_2->unit_direction;
    float _S1013 = escapeWeight_0(_S1011, ray_2->unit_direction);
    uint _S1014 = prev_0->lobe;
    float3  _S1015 = environment_0(_S1012, b_4, prev_0->lobe);
    float3  _S1016 = pathColor(throughput_0 * _S1015, spectral_weight_0, wavelength_5);
    if(replay_1)
    {
        bool _S1017 = b_4 == stop_0;
        bool _S1018;
        if(_S1017)
        {
            _S1018 = rc_0 == 3U;
        }
        else
        {
            _S1018 = false;
        }
        if(_S1018)
        {
            return Shift_x24init_0(_S1016 * make_float3 (_S1013) / make_float3 (r_4->jac), density_1 / r_4->jac);
        }
        bool _S1019 = rc_0 == 0U;
        if(_S1019)
        {
            _S1018 = end_type_1 == 3U;
        }
        else
        {
            _S1018 = false;
        }
        if(_S1018)
        {
            _S1018 = b_4 == end_1;
        }
        else
        {
            _S1018 = false;
        }
        if(_S1018)
        {
            _S1018 = !prev_0->rough;
        }
        else
        {
            _S1018 = false;
        }
        if(_S1018)
        {
            return Shift_x24init_0(_S1016 * make_float3 (_S1013), 1.0f);
        }
        return _S1009;
    }
    Reservoir candidate_2 = *chain_0;
    uint _S1020 = chain_0->path;
    uint _S1021 = extractBits_0(chain_0->path, 10U, 2U);
    bool _S1022 = _S1021 == 1U;
    if(_S1022)
    {
        uint _S1023 = extractBits_0(_S1020, 5U, 5U);
        bool _S1024 = _S1023 == b_4;
        float _S1025 = _slang_select(_S1024, 1.0f,_S1013);
        float3  _S1026 = safeDivide(_S1016 * make_float3 (_S1025), chain_throughput_0);
        (&candidate_2)->radiance = _S1026;
    }
    else
    {
        bool _S1027 = prev_0->rough;
        if(_S1027)
        {
            uint _S1028 = insertBits_0(strata_0, b_4 + 1U, 5U, 5U);
            uint _S1029 = insertBits_0(_S1028, 3U, 10U, 2U);
            uint _S1030 = insertBits_0(_S1029, _S1014, 15U, 3U);
            bool _S1031 = prev_0->inside;
            uint _S1032 = _slang_select(_S1031, 1U,0U);
            uint _S1033 = insertBits_0(_S1030, _S1032, 22U, 1U);
            (&candidate_2)->path = _S1033;
            (&candidate_2)->jac = prev_0->pdf;
            (&candidate_2)->dir = _S1012;
        }
    }
    float3  _S1034 = _S1016 * make_float3 (_S1013);
    Reservoir _S1035 = withEnd(candidate_2, 3U, b_4, _S1034);
    offer(sel_3, _S1035, _S1034 * make_float3 (scale_3) / make_float3 (density_1));
    return _S1009;
}

static __device__ void restir_duplicates_0(uint3  global_invocation_id_1, uint3  local_invocation_id_0, uint local_invocation_index_3)
{
    uint2  _S1036 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S1037 = make_int2 ((int)_S1036.x, (int)_S1036.y);
    uint _S1038 = previousSeed_0(_S1037);
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
            uint _S1039 = previousSeed_0(_S1037 + make_int2 (x_17, y_5));
            bool _S1040 = _S1039 == _S1038;
            uint _S1041 = _slang_select(_S1040, 1U,0U);
            uint count_4 = count_3 + _S1041;
            int x_18 = x_17 + int(1);
            x_17 = x_18;
            count_3 = count_4;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S1042 = float(count_3 - 1U) / 288.0f;
    bool _S1043 = _S1038 != 0U;
    float _S1044 = _slang_select(_S1043, _S1042,0.0f);
    fcptStoreDuplication((_S1037), (make_uint4 ((F32_asuint((_S1044))), 0U, 0U, 0U)));
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
    float3  _S1045 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_3)->f = _S1045;
    float _S1046 = r_5.jac * shifted_0.jac;
    (&candidate_3)->jac = _S1046;
    offer(sel_4, candidate_3, make_float3 (mis_0) * shifted_0.f * make_float3 (r_5.w));
    return;
}

__device__ Reservoir finalize(Selection sel_5, float c_1)
{
    Reservoir r_6 = sel_5.r;
    float _S1047 = resamplingTarget((&r_6)->f);
    float _S1048 = sel_5.w_sum / _S1047;
    bool _S1049 = _S1047 > 0.0f;
    float _S1050 = _slang_select(_S1049, _S1048,0.0f);
    (&r_6)->w = _S1050;
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
    uint2  _S1051 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S1052 = make_int2 ((int)_S1051.x, (int)_S1051.y);
    float3  _S1053 = make_float3 (0.0f);
    FKHit _S1054 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S1055 = Domain_x24init_0(_S1053, _S1053, &_S1054, 0.0f, 0.0f);
    Domain dom_4 = _S1055;
    bool _S1056 = (fcptCurrentDomain((_S1052), (&dom_4)));
    bool _S1057 = !_S1056;
    if(_S1057)
    {
        Reservoir _S1058 = (Reservoir{});
        fcptStoreReservoirPrevious((_S1052), (_S1058), ((&dom_4)->hit));
        return;
    }
    Reservoir _S1059 = (fcptLoadReservoirTemporal((_S1052)));
    uint t_15 = 0U;
    float count_5 = 0.0f;
    float c_sum_0 = _S1059.c;
    for(;;)
    {
        uint _S1060 = (fcptRestirNeighbours());
        if(t_15 < _S1060)
        {
        }
        else
        {
            break;
        }
        int2  _S1061 = partner_0(_S1052, t_15);
        Domain neighbor_0 = _S1055;
        bool _S1062 = (fcptCurrentDomain((_S1061), (&neighbor_0)));
        if(_S1062)
        {
            float count_6 = count_5 + 1.0f;
            uint4  _S1063 = (fcptReservoirTemporal((_S1061), (0U)));
            float c_sum_1 = c_sum_0 + (U32_asfloat((_S1063.w)));
            count_5 = count_6;
            c_sum_0 = c_sum_1;
        }
        uint t_16 = t_15 + 1U;
        t_15 = t_16;
    }
    float _S1064 = _S1059.c / (F32_max((count_5), (1.0f)));
    float _S1065 = resamplingTarget(_S1059.f);
    bool _S1066 = count_5 == 0.0f;
    float _S1067 = _slang_select(_S1066, 1.0f,0.0f);
    Selection _S1068 = (Selection{});
    Selection sel_6 = _S1068;
    uint _S1069 = (fcptFrame());
    uint _S1070 = hash(_S1069);
    uint _S1071 = global_invocation_id_2.x;
    uint2  _S1072 = (fcptRenderSize());
    uint _S1073 = stream(_S1070, _S1071 + _S1072.x * global_invocation_id_2.y);
    uint _S1074 = stream(_S1073, 195U);
    (&sel_6)->random_state = _S1074;
    t_15 = 0U;
    float canonical_mis_0 = _S1067;
    for(;;)
    {
        uint _S1075 = (fcptRestirNeighbours());
        if(t_15 < _S1075)
        {
        }
        else
        {
            break;
        }
        int2  _S1076 = partner_0(_S1052, t_15);
        Domain neighbor_dom_0 = _S1055;
        bool _S1077 = (fcptCurrentDomain((_S1076), (&neighbor_dom_0)));
        if(_S1077)
        {
            Reservoir _S1078 = (fcptLoadReservoirTemporal((_S1076)));
            uint4  _S1079 = (fcptShiftData((_S1076), (t_15)));
            float4  _S1080 = asfloat_0(_S1079);
            uint4  _S1081 = (fcptShiftData((_S1052), (t_15)));
            float4  _S1082 = asfloat_0(_S1081);
            float _S1083 = (_S1078.c + _S1064) / c_sum_0;
            bool _S1084 = _S1065 > 0.0f;
            float canonical_mis_1;
            if(_S1084)
            {
                float _S1085 = _S1083 * _S1064 * _S1065;
                float _S1086 = _S1064 * _S1065;
                float _S1087 = resamplingTarget(float3 {_S1082.x, _S1082.y, _S1082.z});
                float canonical_mis_2 = canonical_mis_0 + _S1085 / (_S1086 + _S1078.c * _S1087);
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float _S1088 = resamplingTarget(_S1078.f);
            float3  _S1089 = float3 {_S1080.x, _S1080.y, _S1080.z};
            Shift _S1090 = Shift_x24init_0(_S1089, _S1080.w);
            float _S1091 = _S1083 * _S1078.c * _S1088;
            float _S1092 = _S1078.c * _S1088;
            float _S1093 = resamplingTarget(_S1089);
            offerShifted(&sel_6, _S1078, _S1090, _S1091 / (_S1092 + _S1064 * _S1093));
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_17 = t_15 + 1U;
        t_15 = t_17;
    }
    offerShifted(&sel_6, _S1059, Shift_x24init_0(_S1059.f, 1.0f), canonical_mis_0);
    Reservoir _S1094 = finalize(sel_6, c_sum_0);
    fcptStoreReservoirPrevious((_S1052), (_S1094), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S1052), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S1052), (make_float4 ((&sel_6)->color.x, (&sel_6)->color.y, (&sel_6)->color.z, 0.0f)));
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
    uint _S1095 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S1096 = _S1095 != 4294967295U;
    if(_S1096)
    {
        uint2  _S1097 = make_uint2 (_S1095, _S1095 >> 14U) & make_uint2 (16383U);
        int2  _S1098 = make_int2 ((int)_S1097.x, (int)_S1097.y);
        ShiftJob _S1099 = (ShiftJob{});
        ShiftJob shift_job_0 = _S1099;
        Shift _S1100 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S1101 = _S1095 >> 28U;
        bool _S1102 = spatialJob_0(_S1098, _S1101, &shift_job_0, true);
        Shift shifted_1;
        if(_S1102)
        {
            Domain _S1103 = (&shift_job_0)->dom;
            Reservoir _S1104 = (&shift_job_0)->r;
            Shift _S1105 = passShift_0(&_S1103, &_S1104);
            shifted_1 = _S1105;
        }
        else
        {
            shifted_1 = _S1100;
        }
        fcptStoreShiftData((_S1098), (_S1101), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S1106 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S1107 = make_int2 ((int)_S1106.x, (int)_S1106.y);
    FixedArray<uint, 3>  _S1108;
    spatialBins_0(_S1107, &_S1108);
    FixedArray<uint, 3>  _S1109 = _S1108;
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
        bool _S1110 = (_S1109[t_18]) == 40U;
        if(_S1110)
        {
            fcptStoreShiftData((_S1107), (t_18), (make_uint4 (0U)));
        }
        uint t_19 = t_18 + 1U;
        t_18 = t_19;
    }
    FixedArray<uint, 3>  _S1111 = _S1109;
    queueShifts_0(_S1107, &_S1111, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S1112 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S1113 = make_int2 ((int)_S1112.x, (int)_S1112.y);
    FixedArray<uint, 3>  _S1114;
    spatialBins_0(_S1113, &_S1114);
    FixedArray<uint, 3>  _S1115 = _S1114;
    countShifts_0(&_S1115, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S1116 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S1117 = _S1116 != 4294967295U;
    if(_S1117)
    {
        uint2  _S1118 = make_uint2 (_S1116, _S1116 >> 14U) & make_uint2 (16383U);
        int2  _S1119 = make_int2 ((int)_S1118.x, (int)_S1118.y);
        int2  _S1120 = (fcptLoadTemporalNeighbor((_S1119)));
        uint _S1121 = _S1116 >> 28U;
        Shift _S1122 = temporalShiftAt_0(_S1119, _S1120, _S1121);
        fcptStoreTemporalShift((_S1119), (_S1121), (make_uint4 (asuint_1(_S1122.f).x, asuint_1(_S1122.f).y, asuint_1(_S1122.f).z, (F32_asuint((_S1122.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S1123 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S1124 = make_int2 ((int)_S1123.x, (int)_S1123.y);
    FixedArray<uint, 3>  _S1125;
    temporalBins_0(_S1124, &_S1125);
    FixedArray<uint, 3>  _S1126 = _S1125;
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
        bool _S1127 = (_S1126[t_20]) == 40U;
        if(_S1127)
        {
            fcptStoreTemporalShift((_S1124), (t_20), (make_uint4 (0U)));
        }
        uint t_21 = t_20 + 1U;
        t_20 = t_21;
    }
    FixedArray<uint, 3>  _S1128 = _S1126;
    queueShifts_0(_S1124, &_S1128, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S1129 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S1130 = make_int2 ((int)_S1129.x, (int)_S1129.y);
    bool _S1131 = (fcptSceneUnchanged());
    bool _S1132 = !_S1131;
    bool _S1133;
    if(_S1132)
    {
        uint2  _S1134 = (fcptRenderSize());
        int2  _S1135 = make_int2 ((int)_S1134.x, (int)_S1134.y);
        _S1133 = all_0(_S1130 < _S1135);
    }
    else
    {
        _S1133 = false;
    }
    if(_S1133)
    {
        Reservoir _S1136 = (fcptLoadReservoirInitial((_S1130)));
        int2  _S1137 = sampleNeighbor_0(_S1130, _S1136.seed);
        fcptStoreTemporalNeighbor((_S1130), (_S1137));
    }
    FixedArray<uint, 3>  _S1138;
    temporalBins_0(_S1130, &_S1138);
    FixedArray<uint, 3>  _S1139 = _S1138;
    countShifts_0(&_S1139, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_8, float b_5, float t_22)
{
    return a_8 + (b_5 - a_8) * t_22;
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S1140 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S1141 = make_int2 ((int)_S1140.x, (int)_S1140.y);
    float3  _S1142 = make_float3 (0.0f);
    FKHit _S1143 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S1144 = Domain_x24init_0(_S1142, _S1142, &_S1143, 0.0f, 0.0f);
    Domain dom_5 = _S1144;
    bool _S1145 = (fcptCurrentDomain((_S1141), (&dom_5)));
    bool _S1146 = !_S1145;
    if(_S1146)
    {
        Reservoir _S1147 = (Reservoir{});
        fcptStoreReservoirTemporal((_S1141), (_S1147), ((&dom_5)->hit));
        return;
    }
    Reservoir _S1148 = (fcptLoadReservoirInitial((_S1141)));
    bool _S1149 = (fcptTemporalQueued());
    bool _S1150 = (fcptSceneUnchanged());
    bool _S1151;
    if(_S1150)
    {
        _S1151 = true;
    }
    else
    {
        _S1151 = !_S1149;
    }
    int2  _S1152;
    if(_S1151)
    {
        int2  _S1153 = sampleNeighbor_0(_S1141, _S1148.seed);
        _S1152 = _S1153;
    }
    else
    {
        int2  _S1154 = (fcptLoadTemporalNeighbor((_S1141)));
        _S1152 = _S1154;
    }
    bool _S1155 = (_S1152.x) >= int(0);
    Reservoir r_7;
    if(_S1155)
    {
        Reservoir _S1156 = (fcptLoadReservoirPrevious((_S1152)));
        uint4  _S1157 = (fcptDuplication((_S1152)));
        float _S1158 = (U32_asfloat((_S1157.x)));
        uint _S1159 = (fcptRestirDecorrelation());
        bool _S1160 = _S1159 == 1U;
        float _S1161 = _slang_select(_S1160, _S1158,0.0f);
        float _S1162 = interpolate_0(20.0f, 1.0f, (F32_pow((_S1161), (0.10000000149011612f))));
        float _S1163 = (F32_min((_S1156.c), (_S1162)));
        bool _S1164 = (fcptSceneUnchanged());
        float4  _S1165 = make_float4 (_S1156.f.x, _S1156.f.y, _S1156.f.z, 1.0f);
        bool _S1166 = !_S1164;
        if(_S1166)
        {
            _S1151 = _S1149;
        }
        else
        {
            _S1151 = false;
        }
        float4  to_current_0;
        if(_S1151)
        {
            uint4  _S1167 = (fcptTemporalShift((_S1141), (0U)));
            float4  _S1168 = asfloat_0(_S1167);
            to_current_0 = _S1168;
        }
        else
        {
            if(_S1166)
            {
                Shift _S1169 = temporalShiftAt_0(_S1141, _S1152, 0U);
                float4  _S1170 = make_float4 (_S1169.f.x, _S1169.f.y, _S1169.f.z, _S1169.jac);
                to_current_0 = _S1170;
            }
            else
            {
                to_current_0 = _S1165;
            }
        }
        Domain own_1 = _S1144;
        if(_S1164)
        {
            _S1151 = true;
        }
        else
        {
            bool _S1171 = (fcptPreviousScenes());
            bool _S1172 = !_S1171;
            if(_S1172)
            {
                _S1151 = (_S1148.w) > 0.0f;
            }
            else
            {
                _S1151 = false;
            }
            if(_S1151)
            {
                bool _S1173 = (fcptStoredDomainInitial((_S1141), (_S1148.seed), (&own_1)));
                _S1151 = _S1173;
            }
            else
            {
                _S1151 = false;
            }
            if(_S1151)
            {
                Domain _S1174 = (fcptPreviousDomain((_S1152), (_S1148.seed)));
                Domain _S1175 = _S1174;
                Domain _S1176 = own_1;
                bool _S1177 = sameDomain_0(&_S1175, &_S1176);
                _S1151 = _S1177;
            }
            else
            {
                _S1151 = false;
            }
        }
        float4  _S1178 = make_float4 (_S1148.f.x, _S1148.f.y, _S1148.f.z, 1.0f);
        bool _S1179 = !_S1151;
        if(_S1179)
        {
            _S1151 = _S1149;
        }
        else
        {
            _S1151 = false;
        }
        float4  to_previous_0;
        if(_S1151)
        {
            uint4  _S1180 = (fcptTemporalShift((_S1141), (1U)));
            float4  _S1181 = asfloat_0(_S1180);
            to_previous_0 = _S1181;
        }
        else
        {
            if(_S1179)
            {
                Shift _S1182 = temporalShiftAt_0(_S1141, _S1152, 1U);
                float4  _S1183 = make_float4 (_S1182.f.x, _S1182.f.y, _S1182.f.z, _S1182.jac);
                to_previous_0 = _S1183;
            }
            else
            {
                to_previous_0 = _S1178;
            }
        }
        float _S1184 = resamplingTarget(_S1148.f);
        float _S1185 = resamplingTarget(_S1156.f);
        Selection _S1186 = (Selection{});
        Selection sel_7 = _S1186;
        uint _S1187 = (fcptFrame());
        uint _S1188 = hash(_S1187);
        uint _S1189 = global_invocation_id_7.x;
        uint2  _S1190 = (fcptRenderSize());
        uint _S1191 = stream(_S1188, _S1189 + _S1190.x * global_invocation_id_7.y);
        uint _S1192 = stream(_S1191, 194U);
        (&sel_7)->random_state = _S1192;
        float _S1193 = _S1148.c * _S1184;
        float4  _S1194 = to_previous_0;
        float _S1195 = resamplingTarget(float3 {_S1194.x, _S1194.y, _S1194.z});
        float _S1196 = _S1193 / (_S1193 + _S1163 * _S1195);
        float _S1197 = _S1163 * _S1185;
        float4  _S1198 = to_current_0;
        float3  _S1199 = float3 {_S1198.x, _S1198.y, _S1198.z};
        float _S1200 = resamplingTarget(_S1199);
        float _S1201 = _S1197 / (_S1197 + _S1148.c * _S1200);
        float2  _S1202 = make_float2 (_S1196, _S1201);
        offerShifted(&sel_7, _S1148, Shift_x24init_0(_S1148.f, 1.0f), _S1196);
        offerShifted(&sel_7, _S1156, Shift_x24init_0(_S1199, to_current_0.w), _S1201);
        Reservoir _S1203 = finalize(sel_7, _S1148.c + _S1163);
        r_7 = _S1203;
    }
    else
    {
        r_7 = _S1148;
    }
    fcptStoreReservoirTemporal((_S1141), (r_7), ((&dom_5)->hit));
    return;
}

__device__ uint noiseOrigin(uint2  p_14, uint k_1)
{
    uint _S1204 = ((p_14.x) >> 11U) | (((p_14.y) >> 11U) << 4U);
    uint2  _S1205 = noiseOffset(8192U + (k_1 >> 10U) + (_S1204 << 20U));
    uint2  _S1206 = (p_14 + _S1205) & make_uint2 (2047U);
    return ((_S1206.x) | ((_S1206.y) << 11U)) | ((k_1 & 1023U) << 22U);
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S1207 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S1208 = make_int2 ((int)_S1207.x, (int)_S1207.y);
    float3  _S1209 = make_float3 (0.0f);
    float2  _S1210 = make_float2 (0.0f);
    FKHit _S1211 = Hit_x24init_0(_S1210, 0U, 0U, 0U, 0.0f);
    Domain _S1212 = Domain_x24init_0(_S1209, _S1209, &_S1211, 0.0f, 0.0f);
    Domain dom_6 = _S1212;
    bool _S1213 = (fcptCurrentDomain((_S1208), (&dom_6)));
    bool _S1214 = !_S1213;
    if(_S1214)
    {
        Reservoir _S1215 = (Reservoir{});
        fcptStoreReservoirInitial((_S1208), (_S1215), ((&dom_6)->hit));
        return;
    }
    uint _S1216 = (fcptFrame());
    uint _S1217 = hash(_S1216);
    uint _S1218 = global_invocation_id_8.x;
    uint2  _S1219 = (fcptRenderSize());
    uint _S1220 = global_invocation_id_8.y;
    uint _S1221 = stream(_S1217, _S1218 + _S1219.x * _S1220);
    uint2  _S1222 = (fcptRenderSize());
    uint _S1223 = stream(_S1218 + _S1222.x * _S1220, 512U);
    Selection _S1224 = (Selection{});
    Selection initial_0 = _S1224;
    uint _S1225 = stream(_S1221, 193U);
    (&initial_0)->random_state = _S1225;
    bool _S1226 = (fcptRestirUsed());
    bool _S1227 = !_S1226;
    (&initial_0)->sums = _S1227;
    uint _S1228 = stream(_S1221, 0U);
    (&(&initial_0)->r)->seed = _S1228;
    FKHit _S1229 = Hit_x24init_0(_S1210, 4294967295U, 0U, 0U, 0.0f);
    uint _S1230 = (fcptSamples());
    float _S1231 = 1.0f / float(_S1230);
    FKHit hit_2 = _S1229;
    uint i_18 = 0U;
    float3  seen_1 = _S1209;
    for(;;)
    {
        uint _S1232 = (fcptSamples());
        if(i_18 < _S1232)
        {
        }
        else
        {
            break;
        }
        Reservoir _S1233 = (Reservoir{});
        Reservoir r_8 = _S1233;
        uint _S1234 = (fcptFrame());
        uint _S1235 = (fcptSamples());
        uint _S1236 = _S1234 * _S1235 + i_18;
        uint _S1237 = noiseOrigin(_S1207, _S1236);
        (&r_8)->seed = _S1237;
        uint _S1238 = insertBits_0(0U, 1U, 24U, 1U);
        uint _S1239 = insertBits_0(_S1238, (_S1223 + _S1236 * 2654435769U) >> 25U, 25U, 7U);
        (&r_8)->path = _S1239;
        Domain path_0 = _S1212;
        bool _S1240 = (fcptStoredDomainInitial((_S1208), ((&r_8)->seed), (&path_0)));
        bool _S1241 = !_S1240;
        if(_S1241)
        {
            float3  _S1242 = (fcptMissed((_S1208), (path_0), (_S1231)));
            float3  seen_2 = seen_1 + _S1242;
            seen_1 = seen_2;
            uint i_19 = i_18 + 1U;
            i_18 = i_19;
            continue;
        }
        Domain _S1243 = path_0;
        Reservoir _S1244 = r_8;
        Shift _S1245 = passWalk_0(&_S1243, &_S1244, false, _S1231, &initial_0);
        bool _S1246 = ((&(&initial_0)->r)->seed) == ((&r_8)->seed);
        FKHit hit_3;
        if(_S1246)
        {
            FKHit _S1247 = (&path_0)->hit;
            hit_3 = _S1247;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_19 = i_18 + 1U;
        i_18 = i_19;
    }
    uint _S1248 = (fcptSamples());
    float3  seen_3 = seen_1 + (&initial_0)->glow / make_float3 (float(_S1248));
    float3  _S1249 = seen_3 + (&initial_0)->color;
    bool _S1250 = (&initial_0)->sums;
    float3  _S1251 = _slang_select(_S1250, _S1249,seen_3);
    fcptAddColor((_S1208), (make_float4 (_S1251.x, _S1251.y, _S1251.z, 1.0f)));
    Reservoir _S1252 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S1208), (_S1252), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_2, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S1253;
    (&_S1253)->none = none_0;
    (&_S1253)->pdf = pdf_2;
    (&_S1253)->origin = origin_5;
    (&_S1253)->smooth_n = smooth_n_3;
    (&_S1253)->start = start_6;
    return _S1253;
}

static __device__ Vertex Vertex_x24init_0(bool rough_0, uint lobe_1, float pdf_3, float cos_0, bool inside_0)
{
    Vertex _S1254;
    (&_S1254)->rough = rough_0;
    (&_S1254)->lobe = lobe_1;
    (&_S1254)->pdf = pdf_3;
    (&_S1254)->cos = cos_0;
    (&_S1254)->inside = inside_0;
    return _S1254;
}

__device__ uint noiseAddress(uint origin_6, uint bounce_0)
{
    uint2  _S1255 = make_uint2 (origin_6 & 2047U, (origin_6 >> 11U) & 2047U);
    uint2  _S1256 = noiseOffset(64U + bounce_0 * 17U);
    uint2  _S1257 = (_S1255 + _S1256) & make_uint2 (2047U);
    return ((_S1257.x) | ((_S1257.y) << 11U)) | ((origin_6 >> 22U) << 22U);
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
    float3  _S1258 = exp_0(- scatter_0 * make_float3 (distance_2));
    float3  _S1259 = make_float3 (3.0f) * exp_0(- extinction_0 * make_float3 (distance_2));
    float3  _S1260 = _S1259 / make_float3 (_S1258.x + _S1258.y + _S1258.z);
    float3  _S1261 = scatter_0 * _S1259 / make_float3 (dot_0(scatter_0, _S1258));
    float3  _S1262 = _slang_select(scatters_0, _S1261,_S1260);
    return _S1262;
}

static __device__ uint arrivalLobe_0(uint b_6, uint prev_lobe_0)
{
    bool _S1263 = b_6 > 0U;
    uint _S1264 = _slang_select(_S1263, prev_lobe_0,3U);
    return _S1264;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_1, uint depth_2, uint lobe_2, bool surface_4, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S1265;
    (&_S1265)->extinction_behind = extinction_behind_0;
    (&_S1265)->extinction_front = extinction_front_0;
    (&_S1265)->fillings = fillings_0;
    (&_S1265)->side = side_1;
    (&_S1265)->depth = depth_2;
    (&_S1265)->lobe = lobe_2;
    (&_S1265)->surface = surface_4;
    (&_S1265)->length = length_2;
    (&_S1265)->width = width_1;
    (&_S1265)->own = *own_2;
    (&_S1265)->fiber = fiber_0;
    return _S1265;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S1266 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S1266)
    {
        return 0.07957746833562851f;
    }
    float _S1267 = g_0 * g_0;
    return (1.0f - _S1267) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S1267 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float survivalProbability(float3  throughput_1, float density_2)
{
    return (F32_min(((F32_max(((F32_max((throughput_1.x), ((F32_max((throughput_1.y), (throughput_1.z)))))) / density_2), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_4)
{
    Random _S1268 = draw(random_state_4, 11U);
    Random _S1269 = draw(random_state_4, 2147483659U);
    float _S1270 = 1.0f - 2.0f * _S1268.value;
    float _S1271 = (F32_sqrt(((F32_max((1.0f - _S1270 * _S1270), (0.0f))))));
    float _S1272 = 6.28318548202514648f * _S1269.value;
    return make_float3 (_S1271 * (F32_cos((_S1272))), _S1271 * (F32_sin((_S1272))), _S1270);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_9, uint random_state_5, float * pdf_4)
{
    bool _S1273 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1273)
    {
        *pdf_4 = 0.07957746833562851f;
        float3  _S1274 = isotropic_0(random_state_5);
        return _S1274;
    }
    Random _S1275 = draw(random_state_5, 11U);
    Random _S1276 = draw(random_state_5, 2147483659U);
    float _S1277 = g_1 * g_1;
    float _S1278 = 2.0f * g_1;
    float _S1279 = (1.0f - _S1277) / (1.0f - g_1 + _S1278 * _S1275.value);
    float _S1280 = clamp_1((1.0f + _S1277 - _S1279 * _S1279) / _S1278, -1.0f, 1.0f);
    float _S1281 = (F32_sqrt(((F32_max((1.0f - _S1280 * _S1280), (0.0f))))));
    float _S1282 = 6.28318548202514648f * _S1276.value;
    float _S1283 = phaseHG_0(g_1, _S1280);
    *pdf_4 = _S1283;
    float3  _S1284 = tangentToWorld(make_float3 (_S1281 * (F32_cos((_S1282))), _S1280, _S1281 * (F32_sin((_S1282)))), dir_9);
    float3  _S1285 = ((((_S1284)) * make_float3(rnorm3df(((_S1284)).x, ((_S1284)).y, ((_S1284)).z))));
    return _S1285;
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_1, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_1, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_1, float velvet_0, float3  toon_2, float dispersion_0, float coat_2, float coat_roughness_0, float coat_ior_0, float3  coat_tint_0, float3  coat_normal_0)
{
    BSDFMaterial _S1286;
    (&_S1286)->albedo = albedo_1;
    (&_S1286)->emissive = emissive_0;
    (&_S1286)->roughness = roughness_0;
    (&_S1286)->metallic = metallic_0;
    (&_S1286)->transmission = transmission_0;
    (&_S1286)->ior = ior_1;
    (&_S1286)->absorption = absorption_0;
    (&_S1286)->specular_tint = specular_tint_0;
    (&_S1286)->specular_level = specular_level_0;
    (&_S1286)->translucent = translucent_0;
    (&_S1286)->sheen = sheen_2;
    (&_S1286)->sheen_roughness = sheen_roughness_0;
    (&_S1286)->anisotropy = anisotropy_0;
    (&_S1286)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1286)->tangent = tangent_1;
    (&_S1286)->velvet = velvet_0;
    (&_S1286)->toon = toon_2;
    (&_S1286)->dispersion = dispersion_0;
    (&_S1286)->coat = coat_2;
    (&_S1286)->coat_roughness = coat_roughness_0;
    (&_S1286)->coat_ior = coat_ior_0;
    (&_S1286)->coat_tint = coat_tint_0;
    (&_S1286)->coat_normal = coat_normal_0;
    return _S1286;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1287;
    (&_S1287)->scatter = scatter_1;
    (&_S1287)->extinction = extinction_1;
    (&_S1287)->g = g_2;
    return _S1287;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_15, bool skip_0, uint random_state_6, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1288;
    (&_S1288)->smooth_n = smooth_n_4;
    (&_S1288)->geometry_n = geometry_n_2;
    (&_S1288)->geometry_offset = geometry_offset_2;
    (&_S1288)->material = *material_15;
    (&_S1288)->skip = skip_0;
    (&_S1288)->random_state = random_state_6;
    (&_S1288)->coverage = coverage_0;
    (&_S1288)->encloses = encloses_0;
    (&_S1288)->volume = *volume_0;
    (&_S1288)->fills = fills_0;
    (&_S1288)->hair = hair_0;
    return _S1288;
}

static __device__ FKSurface emitting_0(FKSurface * surface_5, bool top_0)
{
    FKSurface lower_0 = *surface_5;
    float3  _S1289 = (&surface_5->material)->emissive;
    float3  _S1290 = make_float3 (0.0f);
    bool _S1291 = !top_0;
    float3  _S1292 = _slang_select(_S1291, _S1290,_S1289);
    (&(&lower_0)->material)->emissive = _S1292;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_6, float u_1)
{
    float _S1293 = surface_6->coverage;
    bool _S1294 = u_1 < _S1293;
    if(_S1294)
    {
        return *surface_6;
    }
    float3  _S1295 = make_float3 (0.0f);
    float3  _S1296 = make_float3 (1.0f);
    BSDFMaterial _S1297 = Material_x24init_0(_S1295, _S1295, 0.0f, 0.0f, 0.0f, 0.0f, _S1295, _S1296, 1.0f, _S1295, _S1295, 0.5f, 0.0f, 0.0f, _S1295, 0.0f, _S1295, 0.0f, 0.0f, 0.02999999932944775f, 1.5f, _S1296, _S1295);
    BSDFMaterial material_16 = _S1297;
    (&material_16)->albedo = _S1296;
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
    bool _S1298 = transmission_1 > 0.0f;
    bool _S1299;
    if(_S1298)
    {
        _S1299 = true;
    }
    else
    {
        _S1299 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1300 = _slang_select(_S1299, 1.0f,-1.0f);
    return _S1300;
}

static __device__ bool arrivesBehind_0(float3  dir_10, float3  n_8)
{
    return (dot_0(dir_10, n_8)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_7, float3  dir_11)
{
    float3  _S1301 = surface_7->geometry_n;
    float _S1302 = facingSign((&surface_7->material)->transmission, surface_7->geometry_n, dir_11);
    FKSurface faced_0 = *surface_7;
    float3  _S1303 = surface_7->smooth_n * make_float3 (_S1302);
    (&faced_0)->smooth_n = _S1303;
    float3  _S1304 = _S1301 * make_float3 (_S1302);
    (&faced_0)->geometry_n = _S1304;
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
    float3  _S1305 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1305));
}

__device__ bool dispersive(BSDFMaterial material_17)
{
    bool _S1306 = (material_17.dispersion) > 0.0f;
    bool _S1307;
    if(_S1306)
    {
        _S1307 = (material_17.ior) != 1.0f;
    }
    else
    {
        _S1307 = false;
    }
    return _S1307;
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
        uint _S1308 = (low_1 + high_1 + 1U) / 2U;
        bool _S1309 = (WAVELENGTH_CDF_0[_S1308]) <= u_2;
        if(_S1309)
        {
            low_1 = _S1308;
        }
        else
        {
            uint _S1310 = _S1308 - 1U;
            high_1 = _S1310;
        }
    }
    uint _S1311 = low_1;
    float _S1312 = WAVELENGTH_CDF_0[low_1 + 1U] - WAVELENGTH_CDF_0[low_1];
    return make_float2 (0.37999999523162842f + 0.00499999988824129f * (float(low_1) + (u_2 - WAVELENGTH_CDF_0[_S1311]) / _S1312), _S1312 / 0.00499999988824129f);
}

__device__ static const FixedArray<float, 243>  WAVELENGTH_WEIGHTS_0 = { {
    0.00547470012679696f, -0.00465690018609166f, 0.03257500007748604f, 0.00934640038758516f, -0.00796370021998882f, 0.05577300116419792f, 0.01846100017428398f, -0.01579399965703487f, 0.11072999984025955f, 0.0416410006582737f, -0.03577499836683273f, 0.2513900101184845f, 0.09349299967288971f, -0.08071800321340561f, 0.56742000579833984f, 0.1585099995136261f, -0.13764999806880951f, 0.97018998861312866f, 0.30943000316619873f, -0.27083000540733337f, 1.91740000247955322f, 0.55217999219894409f, -0.48754000663757324f, 3.46889996528625488f, 0.95016998052597046f, -0.84802001714706421f, 6.09439992904663086f, 1.42110002040863037f, -1.28929996490478516f, 9.45199966430664062f, 1.73409998416900635f, -1.6062999963760376f, 12.12800025939941406f, 2.08030009269714355f, -1.98810005187988281f, 15.68700027465820312f, 2.20600008964538574f, -2.20120000839233398f, 18.47699928283691406f, 2.03040003776550293f, -2.17700004577636719f, 19.92700004577636719f, 1.63429999351501465f, -2.00340008735656738f, 20.86899948120117188f, 0.99410998821258545f, -1.62629997730255127f, 20.57799911499023438f, 0.20011000335216522f, -1.11409997940063477f, 19.72100067138671875f, -0.67960000038146973f, -0.45403000712394714f, 17.77599906921386719f, -1.61679995059967041f, 0.37860000133514404f, 14.71500015258789062f, -2.53410005569458008f, 1.27540004253387451f, 11.86499977111816406f, -3.39079999923706055f, 2.2146000862121582f, 9.17669963836669922f, -4.03749990463256836f, 3.0522000789642334f, 6.59509992599487305f, -4.61299991607666016f, 3.89779996871948242f, 4.64589977264404297f, -5.43039989471435547f, 5.0121002197265625f, 3.3199000358581543f, -6.37769985198974609f, 6.33809995651245117f, 2.29699993133544922f, -7.44140005111694336f, 7.91739988327026367f, 1.45389997959136963f, -8.38580036163330078f, 9.60109996795654297f, 0.66465997695922852f, -9.0167999267578125f, 11.23999977111816406f, -0.04403600096702576f, -9.17749977111816406f, 12.63199996948242188f, -0.58126997947692871f, -8.97550010681152344f, 13.91499996185302734f, -0.95730000734329224f, -8.25290012359619141f, 14.86200046539306641f, -1.24430000782012939f, -6.92129993438720703f, 15.03899955749511719f, -1.43069994449615479f, -5.29169988632202148f, 14.90900039672851562f, -1.55149996280670166f, -3.43219995498657227f, 14.70499992370605469f, -1.63569998741149902f, -1.27190005779266357f, 14.24400043487548828f, -1.67030000686645508f, 1.15170001983642578f, 13.32199954986572266f, -1.636199951171875f, 3.73889994621276855f, 12.21199989318847656f, -1.56920003890991211f, 6.43590021133422852f, 10.94699954986572266f, -1.47730004787445068f, 9.16440010070800781f, 9.54769992828369141f, -1.36399996280670166f, 12.02000045776367188f, 8.18799972534179688f, -1.25450003147125244f, 14.78699970245361328f, 6.74429988861083984f, -1.13110005855560303f, 16.72299957275390625f, 5.08780002593994141f, -0.96561002731323242f, 18.14299964904785156f, 3.57019996643066406f, -0.80725997686386108f, 19.91900062561035156f, 2.36269998550415039f, -0.69273000955581665f, 21.05500030517578125f, 1.31369996070861816f, -0.58597999811172485f, 21.3899993896484375f, 0.42390000820159912f, -0.48298001289367676f, 20.99300003051757812f, -0.23857000470161438f, -0.39412000775337219f, 19.82200050354003906f, -0.6866300106048584f, -0.31501999497413635f, 18.12000083923339844f, -0.9412500262260437f, -0.24890999495983124f, 15.7089996337890625f, -1.02020001411437988f, -0.19076000154018402f, 13.19799995422363281f, -0.98919999599456787f, -0.14401000738143921f, 11.23999977111816406f, -0.93347001075744629f, -0.11133000254631042f, 9.36649990081787109f, -0.83820998668670654f, -0.08524099737405777f, 7.41249990463256836f, -0.70064002275466919f, -0.06283199787139893f, 5.71229982376098633f, -0.56079000234603882f, -0.04586699977517128f, 4.42280006408691406f, -0.44653001427650452f, -0.03396600112318993f, 3.34489989280700684f, -0.34457001090049744f, -0.02482499927282333f, 2.49309992790222168f, -0.26017999649047852f, -0.01808100007474422f, 1.82239997386932373f, -0.1921599954366684f, -0.01296999957412481f, 1.29499995708465576f, -0.13766999542713165f, -0.00907570030540228f, 0.92928999662399292f, -0.09956400096416473f, -0.00641620019450784f, 0.61835998296737671f, -0.06671299785375595f, -0.00421149982139468f, 0.40211999416351318f, -0.04354599863290787f, -0.00271830009296536f, 0.2844499945640564f, -0.03087200038135052f, -0.00191440002527088f, 0.20672999322414398f, -0.02246100082993507f, -0.00138829997740686f, 0.15044000744819641f, -0.01634499989449978f, -0.00101030000951141f, 0.10942000150680542f, -0.01188699994236231f, -0.0007347899954766f, 0.07099699974060059f, -0.00771349994465709f, -0.00047679000999779f, 0.04539500176906586f, -0.00493190018460155f, -0.00030484999297187f, 0.03424099832773209f, -0.00372010003775358f, -0.00022995000472292f, 0.02557599917054176f, -0.00277870008721948f, -0.00017175999528263f, 0.01842200011014938f, -0.00200140010565519f, -0.0001237099932041f, 0.01316899992525578f, -0.00143079995177686f, -0.00008843900286593f, 0.00838890019804239f, -0.00091141002485529f, -0.00005633700129692f, 0.00537079991772771f, -0.00058350997278467f, -0.00003606799873523f, 0.00328280008397996f, -0.00035665999166667f, -0.00002204600059486f, 0.00196009990759194f, -0.00021296000340953f, -0.00001316300040344f, 0.00168939994182438f, -0.00018354000349063f, -0.00001134499962063f, 0.00141050003003329f, -0.00015325000276789f, -0.00000947250009631f, 0.00097123999148607f, -0.00010551999730524f, -6.52239987175562419e-06f, 0.00066868000430986f, -0.00007264900341397f, -4.49060007667867467e-06f
} };
__device__ float3  wavelengthWeights(float wavelength_6)
{
    float _S1313 = clamp_1((wavelength_6 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    uint _S1314 = (U32_min((uint(_S1313)), (79U)));
    uint _S1315 = 3U * _S1314;
    float3  _S1316 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1315], WAVELENGTH_WEIGHTS_0[_S1315 + 1U], WAVELENGTH_WEIGHTS_0[_S1315 + 2U]);
    float3  _S1317 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1315 + 3U], WAVELENGTH_WEIGHTS_0[_S1315 + 4U], WAVELENGTH_WEIGHTS_0[_S1315 + 5U]);
    return _S1316 + (_S1317 - _S1316) * make_float3 (_S1313 - float(_S1314));
}

__device__ float dispersedIor(float ior_2, float dispersion_1, float wavelength_7)
{
    float _S1318 = (ior_2 - 1.0f) * dispersion_1 / 1.90962409973144531f;
    float _S1319 = _S1318 * (1.0f / (wavelength_7 * wavelength_7) - 2.89662933349609375f);
    bool _S1320 = dispersion_1 > 0.0f;
    float _S1321 = _slang_select(_S1320, _S1319,0.0f);
    return ior_2 + _S1321;
}

__device__ float2  vertexEta(BSDFMaterial material_18, float n_dot_v_0)
{
    bool _S1322 = n_dot_v_0 < 0.0f;
    float _S1323 = _slang_select(_S1322, material_18.ior,1.0f);
    float _S1324 = _slang_select(_S1322, 1.0f,material_18.ior);
    return make_float2 (_S1323, _S1324);
}

__device__ float2  wavelengthEta(BSDFMaterial material_19, float n_dot_v_1, float wavelength_8)
{
    BSDFMaterial refractive_0 = material_19;
    float _S1325 = dispersedIor(material_19.ior, material_19.dispersion, wavelength_8);
    bool _S1326 = wavelength_8 > 0.0f;
    float _S1327 = _slang_select(_S1326, _S1325,material_19.ior);
    (&refractive_0)->ior = _S1327;
    float2  _S1328 = vertexEta(refractive_0, n_dot_v_1);
    return _S1328;
}

static __device__ float unshared_0(float x_25)
{
    return x_25;
}

__device__ float3  sampleGGXVNDF(float3  Ve_0, float alpha_5, float U1_0, float U2_0)
{
    float3  _S1329 = make_float3 (alpha_5 * Ve_0.x, alpha_5 * Ve_0.y, Ve_0.z);
    float3  _S1330 = ((((_S1329)) * make_float3(rnorm3df(((_S1329)).x, ((_S1329)).y, ((_S1329)).z))));
    float _S1331 = _S1330.x;
    float _S1332 = _S1330.y;
    float _S1333 = _S1331 * _S1331 + _S1332 * _S1332;
    float3  _S1334 = make_float3 (1.0f, 0.0f, 0.0f);
    float3  _S1335 = make_float3 (- _S1332, _S1331, 0.0f);
    float _S1336 = (rsqrtf((_S1333)));
    float3  _S1337 = _S1335 * make_float3 (_S1336);
    bool _S1338 = _S1333 > 0.0f;
    float3  _S1339 = _slang_select(_S1338, _S1337,_S1334);
    float3  _S1340 = cross_0(_S1330, _S1339);
    float _S1341 = (F32_sqrt((U1_0)));
    float _S1342 = 6.28318548202514648f * U2_0;
    float _S1343 = _S1341 * (F32_cos((_S1342)));
    float t2_0 = _S1341 * (F32_sin((_S1342)));
    float _S1344 = 0.5f * (1.0f + _S1330.z);
    float t2_1 = (1.0f - _S1344) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S1343 * _S1343)))))) + _S1344 * t2_0;
    float3  _S1345 = make_float3 (_S1343) * _S1339 + make_float3 (t2_1) * _S1340;
    float _S1346 = unshared_0(_S1343);
    float _S1347 = unshared_0(_S1343);
    float3  _S1348 = _S1345 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S1346 * _S1347 - t2_1 * t2_1))))))) * _S1330;
    float3  _S1349 = make_float3 (alpha_5 * _S1348.x, alpha_5 * _S1348.y, (F32_max((0.0f), (_S1348.z))));
    float3  _S1350 = ((((_S1349)) * make_float3(rnorm3df(((_S1349)).x, ((_S1349)).y, ((_S1349)).z))));
    return _S1350;
}

__device__ float3  worldToTangent(float3  v_8, float3  n_9)
{
    float3  a_9 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S1351 = (F32_abs((dot_0(n_9, a_9)))) > 0.9999847412109375f;
    float3  a_10;
    if(_S1351)
    {
        float3  _S1352 = make_float3 (1.0f, 0.0f, 0.0f);
        a_10 = _S1352;
    }
    else
    {
        a_10 = a_9;
    }
    float3  _S1353 = cross_0(n_9, a_10);
    float3  _S1354 = ((((_S1353)) * make_float3(rnorm3df(((_S1353)).x, ((_S1353)).y, ((_S1353)).z))));
    float3  _S1355 = cross_0(n_9, _S1354);
    return make_float3 (dot_0(v_8, _S1354), dot_0(v_8, n_9), dot_0(v_8, _S1355));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_9, float3  n_i_10, float alpha_6, AnisotropicFrame frame_4, uint * random_state_7, uint first_2)
{
    Random _S1356 = draw(*random_state_7, first_2);
    Random _S1357 = draw(*random_state_7, first_2 | 2147483648U);
    *random_state_7 = _S1357.state;
    float _S1358 = frame_4.alphas.x;
    bool _S1359 = _S1358 > 0.0f;
    if(_S1359)
    {
        float3  _S1360 = anisotropicLocal(v_9, frame_4.tangent, n_i_10);
        float _S1361 = frame_4.alphas.y;
        float3  _S1362 = make_float3 (_S1358 * _S1360.x, _S1361 * _S1360.y, _S1360.z);
        float3  _S1363 = ((((_S1362)) * make_float3(rnorm3df(((_S1362)).x, ((_S1362)).y, ((_S1362)).z))));
        float3  _S1364 = sampleGGXVNDF(_S1363, 1.0f, _S1356.value, _S1357.value);
        float3  _S1365 = make_float3 (_S1358 * _S1364.x, _S1361 * _S1364.y, _S1364.z);
        float3  _S1366 = ((((_S1365)) * make_float3(rnorm3df(((_S1365)).x, ((_S1365)).y, ((_S1365)).z))));
        return make_float3 (_S1366.x) * frame_4.tangent + make_float3 (_S1366.y) * cross_0(n_i_10, frame_4.tangent) + make_float3 (_S1366.z) * n_i_10;
    }
    float3  _S1367 = worldToTangent(v_9, n_i_10);
    float3  _S1368 = sampleGGXVNDF(float3 {_S1367.x, _S1367.z, _S1367.y}, alpha_6, _S1356.value, _S1357.value);
    float3  _S1369 = float3 {_S1368.x, _S1368.z, _S1368.y};
    float3  _S1370 = tangentToWorld(_S1369, n_i_10);
    return _S1370;
}

__device__ __forceinline__ float3  coatHalf(float3  v_10, CoatFrame coat_frame_4, uint random_state_8)
{
    bool _S1371 = !((dot_0(coat_frame_4.normal, v_10)) > 0.0f);
    if(_S1371)
    {
        return make_float3 (0.0f);
    }
    uint state_2 = random_state_8;
    float3  _S1372 = sampleHalfVector(v_10, coat_frame_4.normal, coat_frame_4.alpha, AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f)), &state_2, 1U);
    return _S1372;
}

static __device__ Facets Facets_x24init_0(float3  h_3, float3  coat_h_3)
{
    Facets _S1373;
    (&_S1373)->h = h_3;
    (&_S1373)->coat_h = coat_h_3;
    return _S1373;
}

__device__ Facets drawFacets(float3  in_dir_6, float3  n_10, BSDFMaterial material_20, uint random_state_9)
{
    float3  _S1374 = negate_0(in_dir_6);
    float _S1375 = sign_0(dot_0(n_10, _S1374));
    float3  _S1376 = n_10 * make_float3 (_S1375);
    uint state_3 = random_state_9;
    float _S1377 = material_20.roughness;
    float _S1378 = _S1377 * _S1377;
    AnisotropicFrame _S1379 = anisotropicFrame(material_20, _S1376);
    float3  _S1380 = sampleHalfVector(_S1374, _S1376, _S1378, _S1379, &state_3, 0U);
    CoatFrame _S1381 = coatFrame(material_20, _S1376);
    float3  _S1382 = coatHalf(_S1374, _S1381, random_state_9);
    return Facets_x24init_0(_S1380, _S1382);
}

__device__ bool neeDecision(BSDFMaterial material_21, float n_dot_v_2, float eta_i_5, float eta_o_4)
{
    float _S1383 = fresnel((F32_abs((n_dot_v_2))), eta_i_5, eta_o_4);
    float3  _S1384 = mix_0(make_float3 (_S1383), material_21.albedo, material_21.metallic);
    float _S1385 = rgb_to_greyscale(_S1384);
    float _S1386 = (F32_max(((1.0f - _S1385) * (1.0f - material_21.metallic) * (1.0f - material_21.transmission)), (0.0f)));
    bool _S1387 = _S1386 > 0.03999999910593033f;
    bool _S1388;
    if(_S1387)
    {
        _S1388 = true;
    }
    else
    {
        _S1388 = (material_21.roughness) > 0.20000000298023224f;
    }
    return _S1388;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_22)
{
    float _S1389 = rgb_to_greyscale(material_22->translucent);
    return _S1389 > 0.0f;
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
    MediumSides _S1390;
    (&_S1390)->behind = *behind_1;
    (&_S1390)->front = *front_0;
    (&_S1390)->fillings = fillings_1;
    (&_S1390)->face = face_1;
    return _S1390;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_8, FKMedium * medium_0, uint filling_0, float3  dir_12, FKMedium * outside_0)
{
    float3  _S1391 = surface_8->geometry_n;
    MediumSides _S1392 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_8->geometry_n);
    MediumSides sides_0 = _S1392;
    bool _S1393 = surface_8->encloses;
    if(_S1393)
    {
        (&sides_0)->behind = surface_8->volume;
        *&((&(&sides_0)->fillings)->x) = surface_8->fills;
        bool _S1394 = (dot_0(dir_12, _S1391)) > 0.0f;
        if(_S1394)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_9, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_13, uint depth_3, uint lobe_3, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1395 = surface_9->geometry_n;
    ShadowContext _S1396 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_9->geometry_n, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
    bool _S1397 = surface_9->encloses;
    ShadowContext context_4;
    if(_S1397)
    {
        FKSurface faced_1 = *surface_9;
        float3  _S1398 = - _S1395;
        float3  _S1399 = _slang_select(turned_0, _S1398,_S1395);
        (&faced_1)->geometry_n = _S1399;
        FKMedium _S1400 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1401 = faced_1;
        FKMedium _S1402 = _S1400;
        MediumSides _S1403 = mediumSides_0(&_S1401, &_S1402, filling_1, dir_13, outside_1);
        ShadowContext _S1404 = ShadowContext_x24init_0(_S1403.behind.extinction, _S1403.front.extinction, _S1403.fillings, _S1395, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
        if(turned_0)
        {
            uint2  _S1405 = _S1403.fillings;
            ShadowContext _S1406 = ShadowContext_x24init_0(_S1403.front.extinction, _S1403.behind.extinction, uint2 {_S1405.y, _S1405.x}, _S1395, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
            context_4 = _S1406;
        }
        else
        {
            context_4 = _S1404;
        }
    }
    else
    {
        context_4 = _S1396;
    }
    return context_4;
}

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_7, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_3, BSDFMaterial * material_23, float eta_i_6, float eta_o_5, bool competing_1, Facets * facets_3)
{
    float3  _S1407 = light_2->dir;
    bool _S1408 = (dot_0(geometry_n_3, - in_dir_7) * dot_0(geometry_n_3, light_2->dir)) <= 0.0f;
    FixedArray<float3 , 6>  throughputs_1;
    FixedArray<float, 6>  pdfs_4;
    BSDF(in_dir_7, _S1407, smooth_n_5, *material_23, eta_i_6, eta_o_5, _S1408, *facets_3, &throughputs_1, &pdfs_4);
    bool _S1409;
    if(competing_1)
    {
        _S1409 = (light_2->density) != 0.0f;
    }
    else
    {
        _S1409 = false;
    }
    float3  _S1410 = make_float3 (0.0f);
    uint i_23 = 0U;
    float3  f_7 = _S1410;
    for(;;)
    {
        if(i_23 < 6U)
        {
        }
        else
        {
            break;
        }
        bool _S1411 = (pdfs_4[i_23]) > 0.0f;
        if(_S1411)
        {
            float3  f_8;
            if(_S1409)
            {
                float _S1412 = light_2->density;
                float _S1413 = pdfs_4[i_23] / light_2->density;
                float3  f_9 = f_7 + throughputs_1[i_23] * make_float3 (pdfs_4[i_23]) / make_float3 (_S1412 * (1.0f + _S1413 * _S1413));
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
    float3  _S1414 = f_7 * light_2->radiance;
    float3  _S1415 = _S1414 * make_float3 (light_2->density);
    float3  _S1416 = _slang_select(_S1409, _S1415,_S1414);
    return _S1416;
}

__device__ float3  skyBSDF(float3  in_dir_8, float3  dir_14, FKSurface surface_10, BSDFMaterial material_24, float2  eta_3, bool is_inside_4, Facets facets_4, float pdf_5)
{
    FKSurface _S1417 = surface_10;
    BSDFMaterial _S1418 = material_24;
    Facets _S1419 = facets_4;
    FixedArray<float3 , 6>  terms_3;
    FixedArray<float, 6>  pdfs_5;
    float3  _S1420 = skyLobes_0(in_dir_8, dir_14, &_S1417, &_S1418, eta_3, is_inside_4, &_S1419, pdf_5, &terms_3, &pdfs_5);
    return _S1420;
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_2, uint random_state_10, bool refracted_3, uint lobe_4, float pdf_6)
{
    SampleBSDF _S1421;
    (&_S1421)->unit_direction = unit_direction_1;
    (&_S1421)->throughput = throughput_2;
    (&_S1421)->random_state = random_state_10;
    (&_S1421)->refracted = refracted_3;
    (&_S1421)->lobe = lobe_4;
    (&_S1421)->pdf = pdf_6;
    return _S1421;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  v_11, float3  n_i_11, float n_i_dot_v_3, BSDFMaterial material_25, Weights w_14, uint random_state_11)
{
    Random _S1422 = draw(random_state_11, 3U);
    Random _S1423 = draw(random_state_11, 2147483651U);
    float _S1424 = _S1422.value;
    float _S1425 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1424 * _S1424))))));
    float _S1426 = 6.28318548202514648f * _S1423.value;
    float3  _S1427 = tangentToWorld(make_float3 (_S1425 * (F32_cos((_S1426))), _S1422.value, _S1425 * (F32_sin((_S1426)))), n_i_11);
    float3  _S1428 = sheenVelvetBSDF(_S1427, v_11, n_i_11, material_25, w_14);
    float _S1429 = sheenVelvetPDF(_S1422.value, n_i_dot_v_3, w_14);
    return SampleBSDF_x24init_0(_S1427, _S1428, _S1423.state, false, 4U, _S1429);
}

__device__ __forceinline__ SampleBSDF coatSample(float3  in_dir_9, float3  v_12, float3  coat_h_4, CoatFrame coat_frame_5, Weights w_15, uint random_state_12)
{
    float3  _S1430 = reflect_0(in_dir_9, coat_h_4);
    float3  _S1431 = ((((_S1430)) * make_float3(rnorm3df(((_S1430)).x, ((_S1430)).y, ((_S1430)).z))));
    float3  _S1432 = coatBSDF(w_15);
    float _S1433 = coatPDF(v_12, coat_h_4, coat_frame_5, w_15);
    return SampleBSDF_x24init_0(_S1431, _S1432, random_state_12, false, 5U, _S1433);
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1434 = (F32_sqrt((random_1_0)));
    float _S1435 = 6.28318548202514648f * random_2_0;
    float _S1436 = _S1434 * (F32_cos((_S1435)));
    float _S1437 = _S1434 * (F32_sin((_S1435)));
    float _S1438 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1436 * _S1436 - _S1437 * _S1437))))));
    return make_float3 (_S1436, _S1438, _S1437);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_3, float3  n_i_12, float n_i_dot_v_4, BSDFMaterial material_26, Weights w_16, uint random_state_13)
{
    Random _S1439 = draw(random_state_13, 3U);
    Random _S1440 = draw(random_state_13, 2147483651U);
    float3  _S1441 = sampleCosWeightedHemisphere(_S1439.value, _S1440.value);
    float _S1442 = translucentShare(material_26);
    bool _S1443 = u_3 < (w_16.p_diffuse * _S1442);
    float _S1444 = _S1441.y;
    float _S1445 = - _S1444;
    float _S1446 = _slang_select(_S1443, _S1445,_S1444);
    float3  _S1447 = tangentToWorld(make_float3 (_S1441.x, _S1446, _S1441.z), n_i_12);
    float3  _S1448 = diffuseBSDF(_S1447, n_i_12, material_26, w_16);
    float _S1449 = diffusePDF(_S1446, n_i_dot_v_4, material_26, w_16);
    return SampleBSDF_x24init_0(_S1447, _S1448, _S1440.state, _S1443, 0U, _S1449);
}

__device__ __forceinline__ SampleBSDF toonSample(float3  n_i_13, ToonProfile profile_3, Weights w_17, uint random_state_14)
{
    Random _S1450 = draw(random_state_14, 3U);
    Random _S1451 = draw(random_state_14, 2147483651U);
    float _S1452 = _S1450.value * profile_3.norm / 6.28318548202514648f;
    float _S1453 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1452)))), (1.0f))))));
    float _S1454 = (F32_acos((clamp_1(1.0f - _S1452, -1.0f, 1.0f))));
    float _S1455 = _slang_select(profile_3.glossy, _S1454,_S1453);
    float _S1456 = (profile_3.a + profile_3.b) / 2.0f;
    bool _S1457 = _S1455 < (profile_3.a);
    float _S1458 = _slang_select(_S1457, _S1455,_S1456);
    float t_23 = _S1458;
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
        float _S1459 = toonP(t_23, profile_3.a, profile_3.s);
        float _S1460 = _S1459 * (F32_sin((t_23)));
        float _S1461 = (F32_cos((t_23)));
        float _S1462 = _slang_select(profile_3.glossy, 1.0f,_S1461);
        float _S1463 = _S1460 * _S1462;
        float _S1464 = toonIntegral(t_23, profile_3.a, profile_3.s, profile_3.glossy);
        float _S1465 = (_S1464 - _S1452) / _S1463;
        bool _S1466 = _S1463 > 0.0f;
        float _S1467 = _slang_select(_S1466, _S1465,0.0f);
        float _S1468 = clamp_1(t_23 - _S1467, 0.0f, profile_3.b);
        int k_3 = k_2 + int(1);
        t_23 = _S1468;
        k_2 = k_3;
    }
    float _S1469 = 6.28318548202514648f * _S1451.value;
    float _S1470 = (F32_sin((t_23)));
    float3  _S1471 = tangentToWorld(make_float3 (_S1470 * (F32_cos((_S1469))), (F32_cos((t_23))), _S1470 * (F32_sin((_S1469)))), profile_3.axis);
    float3  _S1472 = toonBSDF(_S1471, n_i_13, profile_3, w_17);
    bool _S1473 = (dot_0(n_i_13, _S1471)) < 0.0f;
    float _S1474 = toonPDF(_S1471, n_i_13, profile_3, w_17);
    return SampleBSDF_x24init_0(_S1471, _S1472, _S1451.state, _S1473, 6U, _S1474);
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_1, float3  n_i_14, float alpha_7, AnisotropicFrame frame_5, BSDFMaterial material_27, Weights w_18, float pdf_h_3, float eta_i_7, float eta_o_6, uint random_state_15)
{
    float _S1475 = maskingG1(w_18.refracted, n_i_14, -1.0f, alpha_7, frame_5);
    float3  _S1476 = refractBSDF(_S1475, material_27, w_18);
    float _S1477 = refractPDF(dot_0(w_18.refracted, ggx_n_1), pdf_h_3, w_18, eta_i_7, eta_o_6);
    return SampleBSDF_x24init_0(w_18.refracted, _S1476, random_state_15, true, 1U, _S1477);
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_10, float3  ggx_n_2, float3  n_i_15, float alpha_8, AnisotropicFrame frame_6, Weights w_19, float pdf_h_4, uint random_state_16)
{
    float3  _S1478 = reflect_0(in_dir_10, ggx_n_2);
    float3  _S1479 = ((((_S1478)) * make_float3(rnorm3df(((_S1478)).x, ((_S1478)).y, ((_S1478)).z))));
    float _S1480 = maskingG1(_S1479, n_i_15, 1.0f, alpha_8, frame_6);
    float3  _S1481 = reflectBSDF(_S1480, w_19);
    float _S1482 = reflectPDF(pdf_h_4, w_19);
    return SampleBSDF_x24init_0(_S1479, _S1481, random_state_16, false, 2U, _S1482);
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_11, float3  n_11, BSDFMaterial material_28, float eta_i_8, float eta_o_7, Facets facets_5, uint random_init_0, float2  screen_space_0)
{
    float3  _S1483 = negate_0(in_dir_11);
    float _S1484 = dot_0(n_11, _S1483);
    float _S1485 = sign_0(_S1484);
    float3  n_i_16 = n_11 * make_float3 (_S1485);
    float _S1486 = (F32_abs((_S1484)));
    float _S1487 = material_28.roughness;
    float _S1488 = _S1487 * _S1487;
    AnisotropicFrame _S1489 = anisotropicFrame(material_28, n_i_16);
    SheenProfile _S1490 = sheenProfile(_S1483, n_i_16, material_28);
    CoatFrame _S1491 = coatFrame(material_28, n_i_16);
    float3  _S1492 = coatSeries(_S1491, material_28);
    Weights _S1493 = lobeWeights(in_dir_11, _S1483, n_i_16, facets_5.h, facets_5.coat_h, facets_5.h, facets_5.coat_h, _S1489, _S1490, _S1491, _S1492, material_28, eta_i_8, eta_o_7);
    Random _S1494 = draw(random_init_0, 2U);
    bool _S1495 = (_S1494.value) < (_S1493.p_sheen_velvet);
    if(_S1495)
    {
        SampleBSDF _S1496 = sheenVelvetSample(_S1483, n_i_16, _S1486, material_28, _S1493, _S1494.state);
        return _S1496;
    }
    float _S1497 = _S1494.value - _S1493.p_sheen_velvet;
    bool _S1498 = _S1497 < (_S1493.p_coat);
    if(_S1498)
    {
        SampleBSDF _S1499 = coatSample(in_dir_11, _S1483, facets_5.coat_h, _S1491, _S1493, _S1494.state);
        return _S1499;
    }
    float _S1500 = _S1497 - _S1493.p_coat;
    bool _S1501 = _S1500 < (_S1493.p_diffuse);
    if(_S1501)
    {
        SampleBSDF _S1502 = diffuseSample(_S1500, n_i_16, _S1486, material_28, _S1493, _S1494.state);
        return _S1502;
    }
    bool _S1503 = _S1500 < (_S1493.p_diffuse + _S1493.p_toon);
    if(_S1503)
    {
        ToonProfile _S1504 = toonProfile(_S1483, n_i_16, material_28);
        SampleBSDF _S1505 = toonSample(n_i_16, _S1504, _S1493, _S1494.state);
        return _S1505;
    }
    float _S1506 = vndfPDF(_S1483, facets_5.h, n_i_16, _S1486, _S1488, _S1489, _S1493.v_dot_h);
    bool _S1507 = (_S1500 - _S1493.p_toon) < (_S1493.p_diffuse + _S1493.p_refract);
    if(_S1507)
    {
        SampleBSDF _S1508 = refractSample(facets_5.h, n_i_16, _S1488, _S1489, material_28, _S1493, _S1506, eta_i_8, eta_o_7, _S1494.state);
        return _S1508;
    }
    SampleBSDF _S1509 = reflectSample(in_dir_11, facets_5.h, n_i_16, _S1488, _S1489, _S1493, _S1506, _S1494.state);
    return _S1509;
}

__device__ __forceinline__ float3  refractedHalf(float3  in_dir_12, float3  out_dir_2, float3  n_12, float eta_i_9, float eta_o_8)
{
    float3  _S1510 = negate_0(in_dir_12);
    float3  _S1511 = negate_0(make_float3 (eta_i_9) * _S1510 + make_float3 (eta_o_8) * out_dir_2);
    float3  _S1512 = ((((_S1511)) * make_float3(rnorm3df(((_S1511)).x, ((_S1511)).y, ((_S1511)).z))));
    float _S1513 = sign_0(dot_0(n_12, _S1510));
    float _S1514 = sign_0(dot_0(_S1511, n_12 * make_float3 (_S1513)));
    return _S1512 * make_float3 (_S1514);
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
    bool _S1515;
    bool _S1516;
    bool _S1517;
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
    int _S1518;
    Shift ended_0;
    float density_4;
    float spread_2;
    float width_4;
    float sky_pdf_2;
    uint b_8;
    float spread_3;
    float width_5;
    float3  _S1519 = make_float3 (0.0f);
    Shift _S1520 = Shift_x24init_0(_S1519, 0.0f);
    uint _S1521 = r_9->path;
    uint _S1522 = extractBits_0(r_9->path, 0U, 5U);
    uint _S1523 = extractBits_0(_S1521, 5U, 5U);
    uint _S1524 = extractBits_0(_S1521, 10U, 2U);
    uint _S1525 = extractBits_0(_S1521, 12U, 3U);
    bool passes_0;
    if(replay_2)
    {
        bool _S1526 = _S1525 >= 3U;
        uint _S1527 = _slang_select(_S1526, 1U,0U);
        uint _S1528 = _S1522 + _S1527;
        uint _S1529 = (fcptMaxBounces());
        passes_0 = _S1528 > _S1529;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1520;
    }
    uint _S1530 = _S1523 - 1U;
    bool _S1531 = _S1525 == 3U;
    uint _S1532 = _slang_select(_S1531, 1U,0U);
    uint _S1533 = _S1522 + _S1532;
    bool _S1534 = _S1524 == 0U;
    uint _S1535 = _slang_select(_S1534, _S1533,_S1530);
    FKHit _S1536 = (fcptReservoirHit((*r_9)));
    float3  _S1537 = dom_7->x0;
    float3  _S1538 = dom_7->x1 - dom_7->x0;
    float3  _S1539 = ((((_S1538)) * make_float3(rnorm3df(((_S1538)).x, ((_S1538)).y, ((_S1538)).z))));
    FKRay _S1540 = Ray_x24init_0(dom_7->x1, _S1539);
    FKRay ray_3 = _S1540;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1519;
    float3  throughput_4 = make_float3 (1.0f);
    float3  weight_2 = throughput_4;
    float3  glowed_0 = _S1519;
    float3  extinction_in_0 = _S1519;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1541 = dom_7->spread;
    float _S1542 = dom_7->width;
    float _S1543 = length_0(_S1538);
    NEEVertex _S1544 = NEEVertex_x24init_0(true, 0.0f, _S1519, _S1519, _S1519);
    NEEVertex nee_vertex_1 = _S1544;
    Vertex _S1545 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_1 = _S1545;
    Reservoir _S1546 = (Reservoir{});
    Reservoir chain_1 = _S1546;
    uint _S1547 = r_9->seed;
    (&chain_1)->seed = r_9->seed;
    uint _S1548 = extractBits_0(_S1521, 24U, 8U);
    uint _S1549 = insertBits_0(0U, _S1548, 24U, 8U);
    (&chain_1)->path = _S1549;
    (&ray_3)->origin = _S1537;
    (&hit_4)->distance = _S1543;
    FKMedium _S1550 = (fcptCameraMedium(((&ray_3)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1551 = filling_2;
    bool _S1552 = (fcptVaryingUsed());
    uint _S1553 = _slang_select(_S1552, _S1551,4294967295U);
    filling_2 = _S1553;
    scatter_in_0 = _S1550.scatter;
    extinction_in_0 = _S1550.extinction;
    g_in_0 = _S1550.g;
    Reservoir _S1554 = chain_1;
    uint _S1555 = filling_2;
    for(;;)
    {
        bool _S1556 = (fcptVaryingUsed());
        if(_S1556)
        {
            passes_0 = _S1555 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1557 = (fcptMajorant((_S1555)));
            turned_1 = _S1557 > 0.0f;
        }
        else
        {
            turned_1 = any_1(scatter_in_0 > make_float3 (0.0f));
        }
        if(replay_2)
        {
            is_inside_5 = 4294967295U == _S1535;
        }
        else
        {
            is_inside_5 = false;
        }
        if(is_inside_5)
        {
            is_inside_5 = _S1524 == 1U;
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
            ended_0 = _S1520;
            sky_pdf_1 = 0.0f;
            spread_1 = _S1541;
            width_3 = _S1542;
            density_3 = 1.0f;
            throughput_3 = throughput_4;
            b_7 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1558 = (&prev_1)->rough;
        if(_S1558)
        {
            is_inside_5 = !turned_1;
        }
        else
        {
            is_inside_5 = false;
        }
        (&prev_1)->rough = is_inside_5;
        uint _S1559 = stream(_S1547, 384U);
        uint tracking_0 = _S1559;
        weight_2 = throughput_4;
        glowed_0 = _S1519;
        b_7 = 4294967295U;
        throughput_3 = throughput_4;
        density_3 = 1.0f;
        spread_1 = _S1541;
        width_3 = _S1542;
        sky_pdf_1 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1518 = int(1);
                break;
            }
            float _S1560 = (&hit_4)->distance;
            if(passes_0)
            {
                float3  _S1561 = (&ray_3)->origin;
                float3  _S1562 = (&ray_3)->unit_direction;
                float _S1563 = (&hit_4)->distance;
                bool _S1564 = b_7 == 4294967295U;
                uint _S1565 = _slang_select(_S1564, 0U,b_7);
                uint _S1566 = (&prev_1)->lobe;
                uint _S1567 = _slang_select(_S1564, 3U,_S1566);
                float _S1568 = (fcptTrackMedium((_S1555), (_S1561), (_S1562), (_S1563), (&tracking_0), (&weight_2), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1565), (_S1567), (_S1564)));
                wavelength_9 = _S1568;
            }
            else
            {
                if(turned_1)
                {
                    uint _S1569 = noiseAddress(_S1547, b_7);
                    Random _S1570 = draw(_S1569, 10U);
                    float _S1571 = 3.0f * _S1570.value;
                    uint _S1572 = (U32_min((uint(_S1571)), (2U)));
                    float _S1573 = - (F32_log((1.0f - (_S1571 - float(_S1572))))) / *_slang_vector_get_element_ptr(&scatter_in_0, _S1572);
                    wavelength_9 = _S1573;
                }
                else
                {
                    wavelength_9 = _S1560;
                }
            }
            bool _S1574 = !(wavelength_9 < ((&hit_4)->distance));
            if(_S1574)
            {
                _S1518 = int(1);
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
                float3  _S1575 = pathColor(throughput_3 * glowed_0, throughput_4, 0.0f);
                float3  _S1576 = _S1575 / make_float3 (density_3);
                float3  _S1577 = sel_8->glow + _S1576;
                sel_8->glow = _S1577;
            }
            else
            {
            }
            glowed_0 = _S1519;
            uint b_9 = b_7 + 1U;
            float3  _S1578 = (&ray_3)->origin + make_float3 (wavelength_9) * (&ray_3)->unit_direction;
            (&ray_3)->origin = _S1578;
            float3  _S1579 = flightWeight_0(scatter_in_0, extinction_in_0, wavelength_9, true);
            float3  _S1580 = weight_2;
            float _S1581 = upsample(weight_2, 0.0f);
            float3  _S1582 = make_float3 (_S1581);
            float3  _S1583 = _slang_select(false, _S1582,_S1580);
            float3  _S1584 = _slang_select(passes_0, _S1583,_S1579);
            float3  throughput_5 = throughput_3 * _S1584;
            uint _S1585 = stream(_S1547, b_9 + 320U);
            tracking_0 = _S1585;
            weight_2 = throughput_4;
            float width_6 = width_3 + spread_1 * wavelength_9;
            float _S1586 = spread_1 + 3.14159274101257324f;
            bool _S1587 = !replay_2;
            if(_S1587)
            {
                viewed_0 = true;
            }
            else
            {
                bool _S1588 = b_9 == _S1535;
                if(_S1588)
                {
                    viewed_0 = !passes_0;
                }
                else
                {
                    viewed_0 = false;
                }
            }
            TreeSample _S1589 = TreeSample_x24init_0(_S1519, _S1519, 0.0f, 0U);
            if(viewed_0)
            {
                float3  _S1590 = (&ray_3)->origin;
                float3  _S1591 = (&ray_3)->unit_direction;
                float3  _S1592 = (&ray_3)->unit_direction;
                uint _S1593 = noiseAddress(_S1547, b_9);
                float3  _S1594 = extinction_in_0;
                float3  _S1595 = extinction_in_0;
                uint2  _S1596 = make_uint2 (_S1555);
                float3  _S1597 = (&ray_3)->unit_direction;
                uint _S1598 = arrivalLobe_0(b_9, (&prev_1)->lobe);
                FKHit _S1599 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1600 = _S1599;
                ShadowContext _S1601 = ShadowContext_x24init_0(_S1594, _S1595, _S1596, _S1597, b_9, _S1598, false, wavelength_9, width_6, &_S1600, false);
                ShadowContext _S1602 = _S1601;
                TreeSample _S1603 = sampleLightTree_0(_S1590, _S1591, _S1592, 0.0f, true, _S1593, &_S1602);
                light_3 = _S1603;
            }
            else
            {
                light_3 = _S1589;
            }
            float _S1604 = phaseHG_0(g_in_0, dot_0((&ray_3)->unit_direction, light_3.dir));
            uint _S1605 = (fcptMaxBounces());
            bool _S1606 = b_9 < _S1605;
            if(_S1606)
            {
                _S1515 = (light_3.density) > 0.0f;
            }
            else
            {
                _S1515 = false;
            }
            float _S1607 = _slang_select(_S1515, _S1604,0.0f);
            float3  _S1608 = throughput_5 * light_3.radiance;
            float _S1609 = powerHeuristic(light_3.density, _S1607);
            float3  _S1610 = pathColor(_S1608 * make_float3 (_S1604 * _S1609), throughput_4, 0.0f);
            float3  _S1611 = _slang_select(viewed_0, _S1610,_S1519);
            if(replay_2)
            {
                _S1516 = b_9 == _S1535;
            }
            else
            {
                _S1516 = false;
            }
            if(_S1516)
            {
                bool _S1612 = _S1524 == 2U;
                if(_S1612)
                {
                    float _S1613 = resamplingTarget(_S1611);
                    passes_0 = _S1613 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1614 = Shift_x24init_0(_S1611, 1.0f);
                    _S1518 = int(0);
                    ended_0 = _S1614;
                    wavelength_9 = _S1586;
                    threshold_0 = width_6;
                    spectral_weight_1 = throughput_5;
                    layer_0 = b_9;
                    break;
                }
                _S1518 = int(0);
                ended_0 = _S1520;
                wavelength_9 = _S1586;
                threshold_0 = width_6;
                spectral_weight_1 = throughput_5;
                layer_0 = b_9;
                break;
            }
            if(_S1587)
            {
                Reservoir candidate_4 = _S1554;
                uint _S1615 = extractBits_0(_S1554.path, 24U, 8U);
                uint _S1616 = insertBits_0(0U, _S1615, 24U, 8U);
                uint _S1617 = extractBits_0(_S1554.path, 10U, 2U);
                bool _S1618 = _S1617 == 1U;
                if(_S1618)
                {
                    float3  _S1619 = safeDivide(_S1611, _S1519);
                    (&candidate_4)->radiance = _S1619;
                }
                else
                {
                    uint _S1620 = insertBits_0(_S1616, b_9 + 1U, 5U, 5U);
                    uint _S1621 = insertBits_0(_S1620, 2U, 10U, 2U);
                    (&candidate_4)->path = _S1621;
                }
                Reservoir _S1622 = withEnd(candidate_4, 0U, b_9, _S1611);
                offer(sel_8, _S1622, _S1611 * make_float3 (scale_4) / make_float3 (density_3));
                float _S1623 = survivalProbability(abs_0(throughput_5), density_3);
                uint _S1624 = (fcptMaxBounces());
                bool _S1625 = b_9 >= _S1624;
                if(_S1625)
                {
                    _S1517 = true;
                }
                else
                {
                    bool _S1626 = _S1623 < 1.0f;
                    if(_S1626)
                    {
                        uint _S1627 = noiseAddress(_S1547, b_9);
                        Random _S1628 = draw(_S1627, 8U);
                        _S1517 = _S1623 < (_S1628.value);
                    }
                    else
                    {
                        _S1517 = false;
                    }
                }
                if(_S1517)
                {
                    _S1518 = int(0);
                    ended_0 = _S1520;
                    wavelength_9 = _S1586;
                    threshold_0 = width_6;
                    spectral_weight_1 = throughput_5;
                    layer_0 = b_9;
                    break;
                }
                float _S1629 = density_3 * _S1623;
                density_3 = _S1629;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1630 = noiseAddress(_S1547, b_9);
            float3  _S1631 = samplePhase_0(g_in_0, (&ray_3)->unit_direction, _S1630, &phase_pdf_0);
            (&ray_3)->unit_direction = _S1631;
            NEEVertex _S1632 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_3)->origin, _S1519, (&ray_3)->origin);
            nee_vertex_1 = _S1632;
            Vertex _S1633 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, false);
            prev_1 = _S1633;
            float _S1634 = (&prev_1)->pdf;
            FKRay _S1635 = ray_3;
            FKHit _S1636 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1637 = (fcptTraverseInstanceBVH((_S1635), (true), (4.294967296e+09f), (false), (_S1636), (false)));
            hit_4 = _S1637;
            b_7 = b_9;
            throughput_3 = throughput_5;
            spread_1 = _S1586;
            width_3 = width_6;
            sky_pdf_1 = _S1634;
        }
        if(_S1518 != int(1))
        {
            spread_1 = wavelength_9;
            width_3 = threshold_0;
            throughput_3 = spectral_weight_1;
            b_7 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1520;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1638 = b_7 == 4294967295U;
    bool _S1639 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1639)
    {
        Reservoir _S1640 = chain_1;
        FKRay _S1641 = ray_3;
        Vertex _S1642 = prev_1;
        NEEVertex _S1643 = nee_vertex_1;
        Shift _S1644 = escape_0(r_9, replay_2, _S1535, _S1524, _S1522, _S1525, scale_4, _S1549, &_S1640, _S1519, b_7, &_S1641, throughput_3, density_3, &_S1642, &_S1643, sky_pdf_1, throughput_4, 0.0f, sel_8);
        return _S1644;
    }
    FKHit _S1645 = hit_4;
    uint _S1646 = filling_2;
    float3  _S1647 = scatter_in_0;
    float3  _S1648 = extinction_in_0;
    float3  _S1649 = weight_2;
    float3  _S1650 = glowed_0;
    float3  _S1651 = (&ray_3)->origin + make_float3 (_S1645.distance) * (&ray_3)->unit_direction;
    (&ray_3)->origin = _S1651;
    bool _S1652 = (fcptVaryingUsed());
    if(_S1652)
    {
        passes_0 = _S1646 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1653 = !replay_2;
        if(_S1653)
        {
            float3  _S1654 = pathColor(throughput_3 * _S1650, throughput_4, 0.0f);
            float3  _S1655 = _S1654 / make_float3 (density_3);
            float3  _S1656 = sel_8->glow + _S1655;
            sel_8->glow = _S1656;
        }
        else
        {
        }
        float3  _S1657 = throughput_3 * _S1649;
        throughput_3 = _S1657;
    }
    else
    {
        float3  _S1658 = flightWeight_0(_S1647, _S1648, _S1645.distance, false);
        float3  _S1659 = throughput_3 * _S1658;
        throughput_3 = _S1659;
    }
    float width_7 = width_3 + spread_1 * _S1645.distance;
    uint _S1660 = b_7 + 1U;
    b_7 = _S1660;
    layer_0 = 0U;
    width_3 = width_7;
    passes_0 = false;
    wavelength_9 = 0.0f;
    threshold_0 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    spectral_weight_1 = throughput_4;
    float3  chain_throughput_1 = _S1519;
    float3  reconnection_0 = _S1519;
    viewed_0 = _S1638;
    for(;;)
    {
        bool _S1661 = ((&hit_4)->is_point_light) == 1U;
        if(replay_2)
        {
            _S1515 = _S1524 == 1U;
        }
        else
        {
            _S1515 = false;
        }
        if(_S1515)
        {
            _S1516 = b_7 == _S1523;
        }
        else
        {
            _S1516 = false;
        }
        if(_S1516)
        {
            bool _S1662 = ((&hit_4)->instance_index) != (_S1536.instance_index);
            if(_S1662)
            {
                _S1517 = true;
            }
            else
            {
                _S1517 = ((&hit_4)->triangle_index) != (_S1536.triangle_index);
            }
        }
        else
        {
            _S1517 = false;
        }
        if(_S1517)
        {
            return _S1520;
        }
        FKMedium _S1663 = Medium_x24init_0(_S1519, _S1519, 0.0f);
        BSDFMaterial _S1664 = Material_x24init_0(_S1519, _S1519, 0.0f, 0.0f, 0.0f, 0.0f, _S1519, throughput_4, 1.0f, _S1519, _S1519, 0.5f, 0.0f, 0.0f, _S1519, 0.0f, _S1519, 0.0f, 0.0f, 0.02999999932944775f, 1.5f, throughput_4, _S1519);
        FKMedium _S1665 = _S1663;
        FKSurface _S1666 = Surface_x24init_0(_S1519, _S1519, 0.0f, &_S1664, false, 0U, 1.0f, false, &_S1665, 4294967295U, _S1519);
        bool _S1667 = !_S1661;
        bool scatter_2;
        bool is_inside_6;
        float3  throughput_6;
        float geometry_density_0;
        FKSurface surface_12;
        if(_S1667)
        {
            uint _S1668 = noiseAddress(_S1547, b_7);
            uint _S1669 = arrivalLobe_0(b_7, (&prev_1)->lobe);
            FKSurface _S1670 = (fcptSurfaceAtPath((hit_4), ((&ray_3)->origin), (_S1668), (width_3), (layer_0), (b_7), (_S1669), ((&ray_3)->unit_direction)));
            bool _S1671 = !passes_0;
            FKSurface _S1672 = _S1670;
            FKSurface _S1673 = emitting_0(&_S1672, _S1671);
            uint _S1674 = noiseAddress(_S1547, b_7);
            Random _S1675 = draw(_S1674, 9U);
            FKSurface _S1676 = _S1673;
            FKSurface _S1677 = uncovered_0(&_S1676, _S1675.value);
            float _S1678 = facingSign(_S1677.material.transmission, _S1677.geometry_n, (&ray_3)->unit_direction);
            bool _S1679 = _S1678 < 0.0f;
            bool _S1680 = (_S1677.material.transmission) > 0.0f;
            if(_S1680)
            {
                bool _S1681 = arrivesBehind_0((&ray_3)->unit_direction, _S1677.geometry_n);
                scatter_2 = _S1681;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1682 = _S1677;
            FKSurface _S1683 = facingRay_0(&_S1682, (&ray_3)->unit_direction);
            if(passes_0)
            {
                bool _S1684 = arrivesBehind_0((&ray_3)->unit_direction, _S1683.geometry_n);
                is_inside_6 = _S1684;
            }
            else
            {
                is_inside_6 = scatter_2;
            }
            if(is_inside_6)
            {
                float _S1685 = (&hit_4)->distance;
                float _S1686 = upsample(_S1683.material.absorption, wavelength_9);
                float3  _S1687 = make_float3 (_S1686);
                bool _S1688 = wavelength_9 > 0.0f;
                float3  _S1689 = _slang_select(_S1688, _S1687,_S1683.material.absorption);
                float3  _S1690 = beerLambert(_S1685, _S1689);
                float3  _S1691 = throughput_3 * _S1690;
                throughput_6 = _S1691;
            }
            else
            {
                throughput_6 = throughput_3;
            }
            bool _S1692 = !_S1683.skip;
            float geometry_density_1 = (F32_abs((dot_0(_S1683.geometry_n, (&ray_3)->unit_direction)))) / ((&hit_4)->distance * (&hit_4)->distance);
            bool _S1693 = b_7 == _S1660;
            if(_S1693)
            {
                float _S1694 = 0.00251327408477664f / geometry_density_1;
                geometry_density_0 = _S1694;
            }
            else
            {
                geometry_density_0 = threshold_0;
            }
            float _S1695 = geometry_density_0;
            scatter_2 = _S1692;
            geometry_density_0 = geometry_density_1;
            threshold_0 = _S1695;
            surface_12 = _S1683;
            turned_1 = _S1679;
        }
        else
        {
            scatter_2 = false;
            geometry_density_0 = 0.0f;
            surface_12 = _S1666;
            throughput_6 = throughput_3;
            is_inside_6 = is_inside_5;
        }
        bool _S1696;
        if(scatter_2)
        {
            _S1696 = (&prev_1)->rough;
        }
        else
        {
            _S1696 = false;
        }
        bool _S1697;
        if(_S1696)
        {
            _S1697 = ((&prev_1)->pdf * geometry_density_0 * threshold_0) <= 1.0f;
        }
        else
        {
            _S1697 = false;
        }
        FKSurface _S1698 = surface_12;
        float _S1699 = dot_0(surface_12.smooth_n, - (&ray_3)->unit_direction);
        bool _S1700 = (fcptDispersionUsed());
        bool _S1701;
        if(_S1700)
        {
            _S1701 = wavelength_9 == 0.0f;
        }
        else
        {
            _S1701 = false;
        }
        bool _S1702;
        if(_S1701)
        {
            _S1702 = scatter_2;
        }
        else
        {
            _S1702 = false;
        }
        bool _S1703;
        if(_S1702)
        {
            bool _S1704 = dispersive(surface_12.material);
            _S1703 = _S1704;
        }
        else
        {
            _S1703 = false;
        }
        float3  throughput_7;
        if(_S1703)
        {
            uint _S1705 = stream(_S1547, 512U);
            Random _S1706 = pcg(_S1705);
            uint _S1707 = extractBits_0(_S1521, 25U, 7U);
            float _S1708 = (float(_S1707) + _S1706.value) / 128.0f;
            uint _S1709 = extractBits_0(_S1521, 24U, 1U);
            bool _S1710 = _S1709 == 1U;
            float _S1711 = _slang_select(_S1710, _S1708,_S1706.value);
            float2  _S1712 = sampleWavelength(_S1711);
            float wavelength_10 = _S1712.x;
            float3  _S1713 = wavelengthWeights(wavelength_10);
            float3  _S1714 = _S1713 / make_float3 (_S1712.y);
            float _S1715 = upsample(throughput_6, wavelength_10);
            float3  _S1716 = make_float3 (_S1715);
            float _S1717 = upsample(scatter_in_0, wavelength_10);
            float3  _S1718 = make_float3 (_S1717);
            scatter_in_0 = _S1718;
            float _S1719 = upsample(extinction_in_0, wavelength_10);
            float3  _S1720 = make_float3 (_S1719);
            extinction_in_0 = _S1720;
            wavelength_9 = wavelength_10;
            throughput_7 = _S1716;
            spectral_weight_1 = _S1714;
        }
        else
        {
            throughput_7 = throughput_6;
        }
        BSDFMaterial _S1721 = pathMaterial(surface_12.material, wavelength_9);
        float2  _S1722 = wavelengthEta(_S1721, _S1699, wavelength_9);
        FKSurface _S1723 = surface_12;
        Facets _S1724 = drawFacets((&ray_3)->unit_direction, _S1698.smooth_n, _S1721, surface_12.random_state);
        bool _S1725;
        if(scatter_2)
        {
            uint _S1726 = (fcptMaxBounces());
            bool _S1727 = b_7 >= _S1726;
            if(_S1727)
            {
                _S1725 = true;
            }
            else
            {
                bool _S1728 = neeDecision(_S1721, _S1699, _S1722.x, _S1722.y);
                _S1725 = _S1728;
            }
        }
        else
        {
            _S1725 = false;
        }
        bool _S1729;
        if(passes_0)
        {
            _S1729 = true;
        }
        else
        {
            _S1729 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1729)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1725;
        }
        bool _S1730 = (fcptHairUsed());
        bool _S1731;
        if(_S1730)
        {
            float3  _S1732 = surface_12.hair;
            _S1731 = (dot_0(_S1732, _S1732)) > 0.0f;
        }
        else
        {
            _S1731 = false;
        }
        bool _S1733;
        if(_S1731)
        {
            _S1733 = true;
        }
        else
        {
            BSDFMaterial _S1734 = _S1721;
            bool _S1735 = isTranslucent_0(&_S1734);
            _S1733 = _S1735;
        }
        bool _S1736;
        if(_S1733)
        {
            _S1736 = true;
        }
        else
        {
            bool _S1737 = (_S1721.transmission) > 0.0f;
            if(_S1737)
            {
                uint _S1738 = (fcptLayers((hit_4)));
                _S1736 = _S1738 == 1U;
            }
            else
            {
                _S1736 = false;
            }
        }
        float3  emission_0;
        if(_S1661)
        {
            float3  _S1739 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1739;
        }
        else
        {
            emission_0 = _S1721.emissive;
        }
        bool _S1740 = !replay_2;
        bool _S1741;
        if(_S1740)
        {
            _S1741 = true;
        }
        else
        {
            _S1741 = b_7 >= _S1535;
        }
        bool _S1742;
        if(_S1741)
        {
            float _S1743 = rgb_to_greyscale(emission_0);
            _S1742 = _S1743 > 0.0f;
        }
        else
        {
            _S1742 = false;
        }
        float3  emission_1;
        if(_S1742)
        {
            NEEVertex _S1744 = nee_vertex_1;
            FKHit _S1745 = hit_4;
            float _S1746 = emissionWeight_0(&_S1744, &_S1745, (&ray_3)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1746);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1747;
        if(replay_2)
        {
            _S1747 = _S1524 == 1U;
        }
        else
        {
            _S1747 = false;
        }
        bool _S1748;
        if(_S1747)
        {
            _S1748 = b_7 > _S1523;
        }
        else
        {
            _S1748 = false;
        }
        bool _S1749;
        if(_S1748)
        {
            _S1749 = b_7 == _S1522;
        }
        else
        {
            _S1749 = false;
        }
        bool _S1750;
        if(_S1749)
        {
            bool _S1751 = _S1525 == 1U;
            if(_S1751)
            {
                _S1750 = true;
            }
            else
            {
                _S1750 = _S1525 == 2U;
            }
        }
        else
        {
            _S1750 = false;
        }
        if(_S1750)
        {
            bool _S1752 = _S1661 != (_S1525 == 2U);
            if(_S1752)
            {
                return _S1520;
            }
            float3  _S1753 = pathColor(throughput_7 * emission_1, spectral_weight_1, wavelength_9);
            return Shift_x24init_0(_S1753 / make_float3 (r_9->jac), density_3 / r_9->jac);
        }
        uint _S1754 = extractBits_0((&chain_1)->path, 10U, 2U);
        bool _S1755 = _S1754 == 1U;
        Reservoir here_0 = chain_1;
        uint _S1756 = insertBits_0(_S1549, b_7, 5U, 5U);
        uint _S1757 = insertBits_0(_S1756, 1U, 10U, 2U);
        uint _S1758 = insertBits_0(_S1757, (&prev_1)->lobe, 15U, 3U);
        bool _S1759 = (&prev_1)->inside;
        uint _S1760 = _slang_select(_S1759, 1U,0U);
        uint _S1761 = insertBits_0(_S1758, _S1760, 22U, 1U);
        (&here_0)->path = _S1761;
        uint _S1762 = (&here_0)->path;
        bool _S1763 = wavelength_9 > 0.0f;
        uint _S1764 = _slang_select(_S1763, 1U,0U);
        uint _S1765 = insertBits_0(_S1762, _S1764, 23U, 1U);
        (&here_0)->path = _S1765;
        float _S1766 = (&prev_1)->pdf * geometry_density_0;
        (&here_0)->jac = _S1766;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1767;
        if(replay_2)
        {
            _S1767 = _S1524 == 1U;
        }
        else
        {
            _S1767 = false;
        }
        bool _S1768;
        if(_S1767)
        {
            _S1768 = b_7 == _S1523;
        }
        else
        {
            _S1768 = false;
        }
        bool _S1769 = b_7 == _S1535;
        bool _S1770;
        if(_S1769)
        {
            bool _S1771 = !scatter_2;
            if(_S1771)
            {
                _S1770 = true;
            }
            else
            {
                bool _S1772 = _S1524 != 1U;
                if(_S1772)
                {
                    _S1770 = _S1524 != 3U;
                }
                else
                {
                    _S1770 = false;
                }
            }
        }
        else
        {
            _S1770 = false;
        }
        bool _S1773;
        if(_S1770)
        {
            _S1773 = _S1524 == 2U;
        }
        else
        {
            _S1773 = false;
        }
        bool _S1774;
        if(_S1773)
        {
            _S1774 = !_S1697;
        }
        else
        {
            _S1774 = false;
        }
        bool _S1775;
        if(_S1774)
        {
            _S1775 = _S1525 != 4U;
        }
        else
        {
            _S1775 = false;
        }
        bool _S1776 = _S1523 == _S1522;
        bool _S1777;
        if(_S1776)
        {
            _S1777 = _S1525 == 0U;
        }
        else
        {
            _S1777 = false;
        }
        bool _S1778;
        if(_S1777)
        {
            _S1778 = ((&hit_4)->instance_index) == (_S1536.instance_index);
        }
        else
        {
            _S1778 = false;
        }
        bool _S1779;
        if(_S1778)
        {
            _S1779 = ((&hit_4)->triangle_index) == (_S1536.triangle_index);
        }
        else
        {
            _S1779 = false;
        }
        bool _S1780;
        if(_S1779)
        {
            _S1780 = _S1697;
        }
        else
        {
            _S1780 = false;
        }
        bool _S1781 = _slang_select(_S1768, _S1780,_S1775);
        bool _S1782;
        if(nee_0)
        {
            _S1782 = _slang_select(replay_2, _S1781,scatter_2);
        }
        else
        {
            _S1782 = false;
        }
        TreeSample _S1783 = TreeSample_x24init_0(_S1519, _S1519, 0.0f, 0U);
        uint2  _S1784 = make_uint2 (0U);
        float2  _S1785 = make_float2 (0.0f);
        FKHit _S1786 = Hit_x24init_0(_S1785, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1787 = _S1786;
        ShadowContext _S1788 = ShadowContext_x24init_0(_S1519, _S1519, _S1784, _S1519, 0U, 0U, false, 0.0f, 0.0f, &_S1787, false);
        bool _S1789;
        if(nee_0)
        {
            _S1789 = _S1741;
        }
        else
        {
            _S1789 = false;
        }
        ShadowContext context_5;
        if(_S1789)
        {
            uint _S1790 = arrivalLobe_0(b_7, (&prev_1)->lobe);
            FKMedium _S1791 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1792 = surface_12;
            FKHit _S1793 = hit_4;
            FKMedium _S1794 = _S1791;
            ShadowContext _S1795 = shadowContext_0(&_S1792, turned_1, extinction_in_0, filling_2, (&ray_3)->unit_direction, b_7, _S1790, (&hit_4)->distance, width_3, &_S1793, _S1731, &_S1794);
            context_5 = _S1795;
        }
        else
        {
            context_5 = _S1788;
        }
        float3  throughput_8;
        float3  lit_0;
        if(_S1782)
        {
            float3  _S1796 = (&ray_3)->origin;
            if(_S1731)
            {
                throughput_8 = _S1519;
            }
            else
            {
                throughput_8 = _S1698.smooth_n;
            }
            FKSurface _S1797 = surface_12;
            uint _S1798 = noiseAddress(_S1547, b_7);
            ShadowContext _S1799 = context_5;
            TreeSample _S1800 = sampleLightTree_0(_S1796, throughput_8, surface_12.geometry_n, surface_12.geometry_offset, _S1736, _S1798, &_S1799);
            bool _S1801 = any_1((_S1800.radiance) != _S1519);
            if(_S1801)
            {
                if(_S1731)
                {
                    uint _S1802 = (fcptMaxBounces());
                    bool _S1803 = b_7 < _S1802;
                    FKSurface _S1804 = surface_12;
                    TreeSample _S1805 = _S1800;
                    float3  _S1806 = hairLight_0(&_S1804, (&ray_3)->unit_direction, &_S1805, _S1803);
                    lit_0 = _S1806;
                }
                else
                {
                    float _S1807 = _S1722.x;
                    float _S1808 = _S1722.y;
                    uint _S1809 = (fcptMaxBounces());
                    bool _S1810 = b_7 < _S1809;
                    TreeSample _S1811 = _S1800;
                    BSDFMaterial _S1812 = _S1721;
                    Facets _S1813 = _S1724;
                    float3  _S1814 = lightBSDF_0((&ray_3)->unit_direction, &_S1811, _S1698.smooth_n, _S1797.geometry_n, &_S1812, _S1807, _S1808, _S1810, &_S1813);
                    lit_0 = _S1814;
                }
            }
            else
            {
                lit_0 = _S1519;
            }
            light_3 = _S1800;
        }
        else
        {
            light_3 = _S1783;
            lit_0 = _S1519;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1815;
        bool _S1816;
        float density_5;
        if(_S1768)
        {
            bool _S1817 = !_S1697;
            if(_S1817)
            {
                return _S1520;
            }
            uint _S1818 = extractBits_0(_S1521, 23U, 1U);
            bool _S1819 = _S1763 != (_S1818 == 1U);
            if(_S1819)
            {
                return _S1520;
            }
            float3  throughput_9 = throughput_7 * make_float3 (geometry_density_0);
            float density_6 = density_3 * geometry_density_0;
            if(_S1776)
            {
                viewed_1 = _S1525 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                float3  _S1820 = pathColor(throughput_9 * emission_1, spectral_weight_1, wavelength_9);
                return Shift_x24init_0(_S1820 / make_float3 (r_9->jac), density_6 / r_9->jac);
            }
            if(_S1776)
            {
                refracted_4 = _S1525 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S1821 = !nee_0;
                if(_S1821)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1822 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1822 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1520;
                }
                float3  _S1823 = pathColor(throughput_9 * lit_0, spectral_weight_1, wavelength_9);
                return Shift_x24init_0(_S1823 / make_float3 (r_9->jac), density_6 / r_9->jac);
            }
            if(_S1776)
            {
                wrong_side_0 = _S1525 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1824 = !nee_0;
                if(_S1824)
                {
                    return _S1520;
                }
                bool _S1825 = (fcptWorldReadsPath());
                if(_S1825)
                {
                    float3  _S1826 = r_9->dir;
                    float _S1827 = environmentPdf_0(r_9->dir);
                    FKSurface _S1828 = surface_12;
                    BSDFMaterial _S1829 = _S1721;
                    Facets _S1830 = _S1724;
                    FixedArray<float3 , 6>  terms_4;
                    FixedArray<float, 6>  pdfs_6;
                    float3  _S1831 = skyLobes_0((&ray_3)->unit_direction, _S1826, &_S1828, &_S1829, _S1722, is_inside_6, &_S1830, _S1827, &terms_4, &pdfs_6);
                    uint _S1832 = b_7 + 1U;
                    FixedArray<float3 , 6>  _S1833 = terms_4;
                    FixedArray<float, 6>  _S1834 = pdfs_6;
                    float3  _S1835 = skyColor_0(_S1826, &_S1833, &_S1834, _S1832);
                    float3  _S1836 = pathColor(throughput_9 * (_S1835 * r_9->radiance), spectral_weight_1, wavelength_9);
                    return Shift_x24init_0(_S1836 / make_float3 (r_9->jac), density_6 / r_9->jac);
                }
                float _S1837 = environmentPdf_0(r_9->dir);
                float3  _S1838 = skyBSDF((&ray_3)->unit_direction, r_9->dir, surface_12, _S1721, _S1722, is_inside_6, _S1724, _S1837);
                float3  _S1839 = pathColor(throughput_9 * _S1838 * r_9->radiance, spectral_weight_1, wavelength_9);
                return Shift_x24init_0(_S1839 / make_float3 (r_9->jac), density_6 / r_9->jac);
            }
            uint _S1840 = extractBits_0(_S1521, 21U, 1U);
            bool _S1841 = nee_0 != (_S1840 == 1U);
            if(_S1841)
            {
                return _S1520;
            }
            throughput_8 = throughput_9;
            density_5 = density_6;
        }
        else
        {
            if(replay_2)
            {
                viewed_1 = _S1769;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1842 = !scatter_2;
                if(_S1842)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1843 = _S1524 != 1U;
                    if(_S1843)
                    {
                        refracted_4 = _S1524 != 3U;
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
                bool _S1844 = _S1524 == 2U;
                if(_S1844)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1697;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1525 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1731)
                    {
                        return _S1520;
                    }
                    uint _S1845 = noiseAddress(_S1547, b_7);
                    FKRay _S1846 = ray_3;
                    FKSurface _S1847 = surface_12;
                    Facets _S1848 = _S1724;
                    ShadowContext _S1849 = context_5;
                    SkySample _S1850 = sampleSky_0(&_S1846, &_S1847, wavelength_9, _S1722, is_inside_6, _S1845, &_S1848, &_S1849);
                    float3  _S1851 = pathColor(throughput_7 * _S1850.color, spectral_weight_1, wavelength_9);
                    return Shift_x24init_0(_S1851, 1.0f);
                }
                if(_S1844)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1697;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1852 = rgb_to_greyscale(light_3.radiance);
                    bool _S1853 = !(_S1852 > 0.0f);
                    if(_S1853)
                    {
                        return _S1520;
                    }
                    float3  _S1854 = pathColor(throughput_7 * lit_0, spectral_weight_1, wavelength_9);
                    return Shift_x24init_0(_S1854, 1.0f);
                }
                if(_S1534)
                {
                    passes_0 = _S1525 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1661;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float3  _S1855 = pathColor(throughput_7 * emission_1, spectral_weight_1, wavelength_9);
                    return Shift_x24init_0(_S1855, 1.0f);
                }
                if(_S1534)
                {
                    passes_0 = _S1525 == 1U;
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
                    passes_0 = !_S1697;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float3  _S1856 = pathColor(throughput_7 * emission_1, spectral_weight_1, wavelength_9);
                    return Shift_x24init_0(_S1856, 1.0f);
                }
                return _S1520;
            }
            else
            {
                if(_S1740)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1857 = b_7 > 0U;
                    if(_S1857)
                    {
                        Reservoir candidate_5 = chain_1;
                        if(_S1755)
                        {
                            float3  _S1858 = safeDivide(throughput_7 * emission_1, chain_throughput_1);
                            (&candidate_5)->radiance = _S1858;
                        }
                        else
                        {
                            if(_S1697)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1859 = pathColor(throughput_7 * emission_1, spectral_weight_1, wavelength_9);
                        Reservoir _S1860 = withEnd(candidate_5, 1U, b_7, _S1859);
                        offer(sel_8, _S1860, _S1859 * make_float3 (scale_4) / make_float3 (density_3));
                    }
                    else
                    {
                        float3  _S1861 = pathColor(throughput_7 * emission_1, spectral_weight_1, wavelength_9);
                        float3  _S1862 = sel_8->glow + _S1861;
                        sel_8->glow = _S1862;
                    }
                    if(nee_0)
                    {
                        float3  _S1863 = pathColor(throughput_7 * lit_0, spectral_weight_1, wavelength_9);
                        Reservoir candidate_6 = chain_1;
                        if(_S1755)
                        {
                            float3  _S1864 = safeDivide(_S1863, chain_throughput_1);
                            (&candidate_6)->radiance = _S1864;
                        }
                        else
                        {
                            if(_S1697)
                            {
                                candidate_6 = here_0;
                                uint _S1865 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1865;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1866 = insertBits_0(_S1549, b_7 + 1U, 5U, 5U);
                                uint _S1867 = insertBits_0(_S1866, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1867;
                            }
                        }
                        Reservoir _S1868 = withEnd(candidate_6, 0U, b_7, _S1863);
                        offer(sel_8, _S1868, _S1863 * make_float3 (scale_4) / make_float3 (density_3));
                    }
                    if(nee_0)
                    {
                        if(_S1731)
                        {
                            _S1815 = false;
                        }
                        else
                        {
                            bool _S1869 = environmentMapped_0();
                            _S1815 = _S1869;
                        }
                    }
                    else
                    {
                        _S1815 = false;
                    }
                    if(_S1815)
                    {
                        uint _S1870 = (fcptMaxBounces());
                        _S1816 = b_7 < _S1870;
                    }
                    else
                    {
                        _S1816 = false;
                    }
                    if(_S1816)
                    {
                        uint _S1871 = noiseAddress(_S1547, b_7);
                        FKRay _S1872 = ray_3;
                        FKSurface _S1873 = surface_12;
                        Facets _S1874 = _S1724;
                        ShadowContext _S1875 = context_5;
                        SkySample _S1876 = sampleSky_0(&_S1872, &_S1873, wavelength_9, _S1722, is_inside_6, _S1871, &_S1874, &_S1875);
                        float3  _S1877 = pathColor(throughput_7 * _S1876.color, spectral_weight_1, wavelength_9);
                        Reservoir candidate_7 = chain_1;
                        if(_S1755)
                        {
                            float3  _S1878 = safeDivide(_S1877, chain_throughput_1);
                            (&candidate_7)->radiance = _S1878;
                        }
                        else
                        {
                            if(_S1697)
                            {
                                candidate_7 = here_0;
                                uint _S1879 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1879;
                                (&candidate_7)->dir = _S1876.dir;
                                (&candidate_7)->radiance = _S1876.radiance;
                            }
                            else
                            {
                                uint _S1880 = insertBits_0(_S1549, b_7 + 1U, 5U, 5U);
                                uint _S1881 = insertBits_0(_S1880, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1881;
                            }
                        }
                        Reservoir _S1882 = withEnd(candidate_7, 4U, b_7, _S1877);
                        offer(sel_8, _S1882, _S1877 * make_float3 (scale_4) / make_float3 (density_3));
                    }
                }
            }
            throughput_8 = throughput_7;
            density_5 = density_3;
        }
        bool _S1883;
        bool _S1884;
        bool _S1885;
        bool straight_0;
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
        bool _S1896;
        bool _S1897;
        bool _S1898;
        bool _S1899;
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
                viewed_1 = _S1769;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1900 = extractBits_0(_S1521, 15U, 3U);
            uint _S1901 = extractBits_0(_S1521, 18U, 3U);
            uint _S1902 = _slang_select(_S1768, _S1901,_S1900);
            float3  _S1903 = r_9->dir;
            bool refracted_5 = _S1902 == 1U;
            SampleBSDF _S1904 = SampleBSDF_x24init_0(_S1519, _S1519, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1904;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1905 = extractBits_0(_S1521, 22U, 1U);
                bool _S1906 = is_inside_6 != (_S1905 == 1U);
                if(_S1906)
                {
                    return _S1520;
                }
                bool _S1907 = _S1524 == 1U;
                if(_S1907)
                {
                    float3  _S1908 = (fcptHitPosition((_S1536)));
                    throughput_10 = _S1908;
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
                    BSDFMaterial _S1909 = _S1721;
                    bool _S1910 = isTranslucent_0(&_S1909);
                    if(_S1910)
                    {
                        refracted_4 = _S1902 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1911 = throughput_10 - (&ray_3)->origin;
                        float3  _S1912 = _slang_select(_S1907, _S1911,_S1903);
                        wrong_side_0 = (dot_0(_S1698.smooth_n, _S1912) * _S1699) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1907)
                {
                    float3  _S1913 = (&ray_3)->origin;
                    FKSurface _S1914 = surface_12;
                    float3  _S1915 = - _S1698.smooth_n;
                    bool _S1916 = is_inside_6 != refracted_4;
                    float3  _S1917 = _slang_select(_S1916, _S1915,_S1698.smooth_n);
                    float3  _S1918 = throughput_10 - (_S1913 + make_float3 (_S1914.geometry_offset) * _S1917);
                    float3  _S1919 = ((((_S1918)) * make_float3(rnorm3df(((_S1918)).x, ((_S1918)).y, ((_S1918)).z))));
                    reconnection_1 = _S1919;
                }
                else
                {
                    reconnection_1 = _S1903;
                }
                if(_S1731)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1920 = wrongSide_0(is_inside_6, refracted_4, reconnection_1, surface_12.geometry_n);
                    wrong_side_0 = _S1920;
                }
                if(wrong_side_0)
                {
                    return _S1520;
                }
                float3  _S1921 = throughput_10;
                throughput_10 = reconnection_1;
                b_10 = _S1902;
                wrong_side_0 = false;
                reconnection_1 = _S1921;
            }
            else
            {
                bool _S1922 = !_S1768;
                if(_S1922)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1923;
                    if(_S1731)
                    {
                        SampleBSDF _S1924 = (fcptSampleHair((surface_12.hair), (_S1721.albedo), (_S1721.specular_tint), ((&ray_3)->unit_direction), (_S1723.random_state)));
                        _S1923 = _S1924;
                    }
                    else
                    {
                        SampleBSDF _S1925 = sampleBSDF((&ray_3)->unit_direction, _S1698.smooth_n, _S1721, _S1722.x, _S1722.y, _S1724, _S1723.random_state, _S1785);
                        _S1923 = _S1925;
                    }
                    bsdf_sampled_0 = _S1923;
                    if(_S1731)
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
                            return _S1520;
                        }
                        break;
                    }
                    if(_S1731)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1926 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_12.geometry_n);
                        wrong_side_0 = _S1926;
                    }
                    if(wrong_side_0)
                    {
                        _S1815 = (_S1721.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1815 = false;
                    }
                    if(_S1815)
                    {
                        float _S1927 = _S1722.x;
                        float _S1928 = _S1722.y;
                        Facets _S1929 = drawFacets((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S1721, (&bsdf_sampled_0)->random_state);
                        SampleBSDF _S1930 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S1721, _S1927, _S1928, _S1929, (&bsdf_sampled_0)->random_state, _S1785);
                        (&bsdf_sampled_0)->unit_direction = _S1930.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1930.refracted;
                        (&bsdf_sampled_0)->throughput = _S1930.throughput;
                        (&bsdf_sampled_0)->lobe = _S1930.lobe;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1931 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n)) * surface_12.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1931;
                        }
                    }
                    uint _S1932 = (&bsdf_sampled_0)->lobe;
                    float3  _S1933 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1934 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1935 = (&bsdf_sampled_0)->pdf;
                    float _S1936 = _slang_select(wrong_side_0, 0.0f,_S1935);
                    (&lobe_5)->pdf = _S1936;
                    throughput_10 = _S1933;
                    b_10 = _S1932;
                    refracted_4 = _S1934;
                }
                else
                {
                    throughput_10 = _S1903;
                    b_10 = _S1902;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1815 = true;
            }
            else
            {
                _S1815 = _S1768;
            }
            if(_S1815)
            {
                if(_S1731)
                {
                    SampleBSDF _S1937 = (fcptConnectHair((surface_12.hair), (_S1721.albedo), (_S1721.specular_tint), ((&ray_3)->unit_direction), (throughput_10)));
                    lobe_5 = _S1937;
                }
                else
                {
                    float3  _S1938 = (&ray_3)->unit_direction;
                    float3  _S1939 = negate_0(_S1938);
                    float _S1940 = sign_0(_S1699);
                    float3  _S1941 = _S1698.smooth_n * make_float3 (_S1940);
                    float _S1942 = dot_0(_S1941, throughput_10);
                    float _S1943 = _S1721.roughness;
                    float _S1944 = _S1943 * _S1943;
                    AnisotropicFrame _S1945 = anisotropicFrame(_S1721, _S1941);
                    SheenProfile _S1946 = sheenProfile(_S1939, _S1941, _S1721);
                    CoatFrame _S1947 = coatFrame(_S1721, _S1941);
                    float3  _S1948 = coatSeries(_S1947, _S1721);
                    float3  _S1949 = reflectedHalf(_S1938, throughput_10);
                    bool _S1950 = b_10 == 1U;
                    if(_S1950)
                    {
                        float3  _S1951 = refractedHalf(_S1938, throughput_10, _S1698.smooth_n, _S1722.x, _S1722.y);
                        throughput_11 = _S1951;
                    }
                    else
                    {
                        throughput_11 = _S1949;
                    }
                    float3  _S1952 = _S1724.coat_h;
                    bool _S1953 = (dot_0(_S1952, _S1952)) > 0.0f;
                    float3  _S1954 = _slang_select(_S1953, _S1949,_S1519);
                    float _S1955 = _S1722.x;
                    float _S1956 = _S1722.y;
                    Weights _S1957 = lobeWeights(_S1938, _S1939, _S1941, _S1724.h, _S1724.coat_h, throughput_11, _S1954, _S1945, _S1946, _S1947, _S1948, _S1721, _S1955, _S1956);
                    float _S1958 = (F32_abs((_S1699)));
                    float _S1959 = vndfPDF(_S1939, throughput_11, _S1941, _S1958, _S1944, _S1945, _S1957.v_dot_h);
                    switch(b_10)
                    {
                    case 0U:
                        {
                            float _S1960 = diffusePDF(_S1942, _S1958, _S1721, _S1957);
                            float3  _S1961 = diffuseBSDF(throughput_10, _S1941, _S1721, _S1957);
                            density_7 = _S1960;
                            throughput_12 = _S1961;
                            break;
                        }
                    case 1U:
                        {
                            float _S1962 = refractPDF(dot_0(throughput_10, throughput_11), _S1959, _S1957, _S1955, _S1956);
                            float _S1963 = maskingG1(throughput_10, _S1941, -1.0f, _S1944, _S1945);
                            float3  _S1964 = refractBSDF(_S1963, _S1721, _S1957);
                            density_7 = _S1962;
                            throughput_12 = _S1964;
                            break;
                        }
                    case 4U:
                        {
                            float _S1965 = sheenVelvetPDF(_S1942, _S1958, _S1957);
                            float3  _S1966 = sheenVelvetBSDF(throughput_10, _S1939, _S1941, _S1721, _S1957);
                            density_7 = _S1965;
                            throughput_12 = _S1966;
                            break;
                        }
                    case 5U:
                        {
                            float _S1967 = coatPDF(_S1939, _S1954, _S1947, _S1957);
                            float3  _S1968 = coatBSDF(_S1957);
                            density_7 = _S1967;
                            throughput_12 = _S1968;
                            break;
                        }
                    case 6U:
                        {
                            ToonProfile _S1969 = toonProfile(_S1939, _S1941, _S1721);
                            float _S1970 = toonPDF(throughput_10, _S1941, _S1969, _S1957);
                            float3  _S1971 = toonBSDF(throughput_10, _S1941, _S1969, _S1957);
                            density_7 = _S1970;
                            throughput_12 = _S1971;
                            break;
                        }
                    default:
                        {
                            float _S1972 = reflectPDF(_S1959, _S1957);
                            float _S1973 = maskingG1(throughput_10, _S1941, 1.0f, _S1944, _S1945);
                            float3  _S1974 = reflectBSDF(_S1973, _S1957);
                            density_7 = _S1972;
                            throughput_12 = _S1974;
                            break;
                        }
                    }
                    bool _S1975 = density_7 > 0.0f;
                    if(_S1975)
                    {
                        SampleBSDF _S1976 = SampleBSDF_x24init_0(throughput_10, throughput_12, _S1723.random_state, _S1950, b_10, density_7);
                        lobe_5 = _S1976;
                    }
                }
            }
            bool _S1977 = b_10 == 0U;
            if(_S1977)
            {
                _S1816 = true;
            }
            else
            {
                _S1816 = b_10 == 4U;
            }
            if(_S1816)
            {
                _S1883 = true;
            }
            else
            {
                _S1883 = b_10 == 6U;
            }
            bool _S1978 = b_10 == 5U;
            float _S1979 = _slang_select(_S1978, _S1721.coat_roughness,_S1721.roughness);
            if(_S1731)
            {
                _S1884 = false;
            }
            else
            {
                bool _S1980 = !_S1883;
                if(_S1980)
                {
                    bool _S1981 = _S1979 == 0.0f;
                    if(_S1981)
                    {
                        _S1884 = true;
                    }
                    else
                    {
                        bool _S1982 = b_10 == 1U;
                        if(_S1982)
                        {
                            _S1884 = (_S1722.x) == (_S1722.y);
                        }
                        else
                        {
                            _S1884 = false;
                        }
                    }
                }
                else
                {
                    _S1884 = false;
                }
            }
            bool _S1983 = !_S1731;
            if(_S1983)
            {
                _S1885 = b_10 == 1U;
            }
            else
            {
                _S1885 = false;
            }
            if(_S1885)
            {
                straight_0 = (_S1721.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1886 = _S1983;
            }
            else
            {
                _S1886 = false;
            }
            if(_S1886)
            {
                _S1887 = b_10 == 1U;
            }
            else
            {
                _S1887 = false;
            }
            if(_S1887)
            {
                _S1888 = (_S1722.x) == (_S1722.y);
            }
            else
            {
                _S1888 = false;
            }
            BSDFMaterial _S1984 = _S1721;
            bool _S1985 = isTranslucent_0(&_S1984);
            if(_S1985)
            {
                _S1889 = _S1977;
            }
            else
            {
                _S1889 = false;
            }
            if(_S1889)
            {
                _S1890 = (dot_0(throughput_10, surface_12.geometry_n)) < 0.0f;
            }
            else
            {
                _S1890 = false;
            }
            if(nee_0)
            {
                _S1891 = !_S1884;
            }
            else
            {
                _S1891 = false;
            }
            if(_S1891)
            {
                _S1892 = !wrong_side_0;
            }
            else
            {
                _S1892 = false;
            }
            if(_S1892)
            {
                float _S1986 = (&lobe_5)->pdf;
                float3  _S1987 = (&ray_3)->origin;
                float3  _S1988 = _slang_select(_S1736, _S1519,_S1698.smooth_n);
                float3  _S1989 = (&ray_3)->origin;
                FKSurface _S1990 = surface_12;
                float3  _S1991 = - _S1698.smooth_n;
                float3  _S1992 = _slang_select(_S1890, _S1991,_S1698.smooth_n);
                NEEVertex _S1993 = NEEVertex_x24init_0(false, _S1986, _S1987, _S1988, _S1989 + make_float3 (_S1990.geometry_offset) * _S1992);
                nee_vertex_1 = _S1993;
            }
            else
            {
                if(_S1731)
                {
                    _S1893 = true;
                }
                else
                {
                    bool _S1994 = b_10 != 1U;
                    if(_S1994)
                    {
                        _S1893 = true;
                    }
                    else
                    {
                        _S1893 = (_S1722.x) != (_S1722.y);
                    }
                }
                if(_S1893)
                {
                    (&nee_vertex_1)->none = true;
                }
            }
            bool _S1995 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1995)
            {
                if(_S1883)
                {
                    _S1893 = true;
                }
                else
                {
                    _S1893 = ((&lobe_5)->pdf * (&prev_1)->cos / ((&hit_4)->distance * (&hit_4)->distance) * threshold_0) <= 1.0f;
                }
            }
            else
            {
                _S1893 = false;
            }
            bool _S1996 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1996)
            {
                if(_S1883)
                {
                    _S1894 = true;
                }
                else
                {
                    _S1894 = _S1979 >= 0.20000000298023224f;
                }
            }
            else
            {
                _S1894 = false;
            }
            if(_S1768)
            {
                bool _S1997 = !_S1893;
                if(_S1997)
                {
                    return _S1520;
                }
                bool _S1998 = _S1525 != 1U;
                if(_S1998)
                {
                    _S1895 = _S1525 != 2U;
                }
                else
                {
                    _S1895 = false;
                }
                if(_S1895)
                {
                    float _S1999 = (&lobe_5)->pdf;
                    float _S2000 = _slang_select(nee_0, _S1999,0.0f);
                    float _S2001 = escapeWeight_0(_S2000, _S1903);
                    if(_S1776)
                    {
                        passes_0 = _S1531;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S2002 = _slang_select(passes_0, _S2001,1.0f);
                    return Shift_x24init_0(throughput_8 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_9->radiance * make_float3 (_S2002) / make_float3 (r_9->jac), density_5 * (&lobe_5)->pdf / r_9->jac);
                }
                float3  _S2003 = throughput_8 * make_float3 ((&lobe_5)->pdf);
                float _S2004 = density_5 * (&lobe_5)->pdf;
                throughput_11 = _S2003;
                density_7 = _S2004;
            }
            else
            {
                throughput_11 = throughput_8;
                density_7 = density_5;
            }
            uint _S2005 = (fcptLayers((hit_4)));
            bool _S2006 = _S2005 > 1U;
            if(_S2006)
            {
                _S1895 = (b_10 == 1U) != passes_0;
            }
            else
            {
                _S1895 = false;
            }
            if(viewed_1)
            {
                _S1896 = _S1895;
            }
            else
            {
                _S1896 = false;
            }
            if(_S1896)
            {
                return _S1520;
            }
            if(replay_2)
            {
                _S1897 = b_7 <= _S1535;
            }
            else
            {
                _S1897 = false;
            }
            if(_S1897)
            {
                _S1898 = _S1697;
            }
            else
            {
                _S1898 = false;
            }
            if(_S1898)
            {
                _S1899 = _S1893;
            }
            else
            {
                _S1899 = false;
            }
            bool _S2007;
            if(_S1899)
            {
                _S2007 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S2007 = !_S1894;
                }
                else
                {
                    _S2007 = false;
                }
            }
            if(_S2007)
            {
                return _S1520;
            }
            if(viewed_1)
            {
                float3  _S2008 = throughput_11 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S2009 = (&lobe_5)->pdf;
                throughput_12 = _S2008;
                sky_pdf_3 = _S2009;
            }
            else
            {
                float3  _S2010 = throughput_11 * max_0((&lobe_5)->throughput, _S1519);
                throughput_12 = _S2010;
                sky_pdf_3 = density_7;
            }
            bool _S2011;
            if(_S1740)
            {
                _S2011 = !_S1755;
            }
            else
            {
                _S2011 = false;
            }
            bool _S2012;
            if(_S2011)
            {
                _S2012 = _S1697;
            }
            else
            {
                _S2012 = false;
            }
            bool _S2013;
            if(_S2012)
            {
                _S2013 = _S1893;
            }
            else
            {
                _S2013 = false;
            }
            float3  chain_throughput_2;
            if(_S2013)
            {
                chain_1 = here_0;
                uint _S2014 = insertBits_0((&chain_1)->path, b_10, 18U, 3U);
                uint _S2015 = _slang_select(nee_0, 1U,0U);
                uint _S2016 = insertBits_0(_S2014, _S2015, 21U, 1U);
                (&chain_1)->path = _S2016;
                float _S2017 = (&chain_1)->jac * (&lobe_5)->pdf;
                (&chain_1)->jac = _S2017;
                (&chain_1)->dir = throughput_10;
                chain_throughput_2 = throughput_12;
            }
            else
            {
                chain_throughput_2 = chain_throughput_1;
            }
            FKSurface _S2018 = surface_12;
            Vertex _S2019 = Vertex_x24init_0(_S1894, b_10, (&lobe_5)->pdf, (F32_abs((dot_0(surface_12.geometry_n, throughput_10)))), is_inside_6);
            prev_1 = _S2019;
            float _S2020 = (&lobe_5)->pdf;
            bool _S2021 = b_10 == 1U;
            bool _S2022;
            if(_S2021)
            {
                _S2022 = (_S1722.x) == (_S1722.y);
            }
            else
            {
                _S2022 = false;
            }
            float sky_pdf_4 = _slang_select(_S2022, sky_pdf_1,_S2020);
            float _S2023 = _slang_select(_S1731, 0.0f,sky_pdf_4);
            float _S2024 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * (&lobe_5)->pdf))))), (3.14159274101257324f)));
            bool _S2025 = !_S1884;
            float _S2026 = _slang_select(_S2025, _S2024,0.0f);
            float _S2027 = spread_1 + _S2026;
            bool _S2028;
            if(refracted_4)
            {
                _S2028 = !_S1890;
            }
            else
            {
                _S2028 = false;
            }
            bool is_inside_7;
            if(_S2028)
            {
                bool _S2029 = !is_inside_6;
                is_inside_7 = _S2029;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            FKSurface _S2030 = surface_12;
            bool _S2031 = boundsVolume_0(&_S2030);
            bool _S2032;
            if(_S2031)
            {
                _S2032 = !_S1895;
            }
            else
            {
                _S2032 = false;
            }
            if(_S2032)
            {
                FKSurface faced_2 = surface_12;
                float3  _S2033 = - _S2018.geometry_n;
                float3  _S2034 = _slang_select(turned_1, _S2033,_S2018.geometry_n);
                (&faced_2)->geometry_n = _S2034;
                FKMedium _S2035 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S2036 = (fcptOutsideMedium((hit_4)));
                FKSurface _S2037 = faced_2;
                FKMedium _S2038 = _S2035;
                FKMedium _S2039 = _S2036;
                MediumSides _S2040 = mediumSides_0(&_S2037, &_S2038, filling_2, (&ray_3)->unit_direction, &_S2039);
                bool _S2041 = ((dot_0(throughput_10, _S2018.geometry_n)) > 0.0f) == ((dot_0(_S2018.geometry_n, (&faced_2)->geometry_n)) > 0.0f);
                float3  _S2042 = _slang_select(_S2041, _S2040.front.scatter,_S2040.behind.scatter);
                scatter_in_0 = _S2042;
                float3  _S2043 = scatter_in_0;
                float _S2044 = upsample(scatter_in_0, wavelength_9);
                float3  _S2045 = make_float3 (_S2044);
                float3  _S2046 = _slang_select(_S1763, _S2045,_S2043);
                scatter_in_0 = _S2046;
                float3  _S2047 = _slang_select(_S2041, _S2040.front.extinction,_S2040.behind.extinction);
                extinction_in_0 = _S2047;
                float3  _S2048 = extinction_in_0;
                float _S2049 = upsample(extinction_in_0, wavelength_9);
                float3  _S2050 = make_float3 (_S2049);
                float3  _S2051 = _slang_select(_S1763, _S2050,_S2048);
                extinction_in_0 = _S2051;
                float _S2052 = _slang_select(_S2041, _S2040.front.g,_S2040.behind.g);
                g_in_0 = _S2052;
                uint _S2053 = _S2040.fillings.x;
                uint _S2054 = _S2040.fillings.y;
                uint _S2055 = _slang_select(_S2041, _S2054,_S2053);
                bool _S2056 = (fcptVaryingUsed());
                uint _S2057 = _slang_select(_S2056, _S2055,4294967295U);
                filling_2 = _S2057;
            }
            (&ray_3)->unit_direction = throughput_10;
            bool _S2058 = !_S1895;
            if(_S2058)
            {
                FKSurface _S2059 = surface_12;
                float _S2060 = _slang_select(straight_0, 0.0f,_S2059.geometry_offset);
                float3  _S2061 = - _S1698.smooth_n;
                bool _S2062 = is_inside_7 != _S1890;
                float3  _S2063 = _slang_select(_S2062, _S2061,_S1698.smooth_n);
                float3  _S2064 = (&ray_3)->origin + make_float3 (_S2060) * _S2063;
                (&ray_3)->origin = _S2064;
            }
            throughput_11 = throughput_12;
            chain_throughput_1 = chain_throughput_2;
            density_7 = sky_pdf_3;
            passes_0 = _S1895;
            viewed_1 = _S1888;
            sky_pdf_3 = _S2023;
            spread_4 = _S2027;
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
        if(_S1740)
        {
            if(_S1661)
            {
                float3  _S2065 = pathColor(throughput_11 * emission_1, spectral_weight_1, wavelength_9);
                Reservoir candidate_8 = chain_1;
                uint _S2066 = extractBits_0((&chain_1)->path, 10U, 2U);
                bool _S2067 = _S2066 == 1U;
                if(_S2067)
                {
                    float3  _S2068 = safeDivide(_S2065, chain_throughput_1);
                    (&candidate_8)->radiance = _S2068;
                }
                Reservoir _S2069 = withEnd(candidate_8, 2U, b_7, _S2065);
                offer(sel_8, _S2069, _S2065 * make_float3 (scale_4) / make_float3 (density_7));
            }
            if(_S1661)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S2070 = survivalProbability(abs_0(throughput_11), density_7);
                density_8 = _S2070;
            }
            else
            {
                density_8 = 1.0f;
            }
            uint _S2071 = (fcptMaxBounces());
            bool _S2072 = b_7 >= _S2071;
            if(_S2072)
            {
                wrong_side_0 = true;
            }
            else
            {
                bool _S2073 = density_8 < 1.0f;
                if(_S2073)
                {
                    uint _S2074 = noiseAddress(_S1547, b_7);
                    Random _S2075 = draw(_S2074, 8U);
                    wrong_side_0 = density_8 < (_S2075.value);
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
            float _S2076 = density_7 * density_8;
            density_8 = _S2076;
        }
        else
        {
            density_8 = density_7;
        }
        uint _S2077 = layer_0 ^ 1U;
        uint _S2078 = _slang_select(passes_0, _S2077,0U);
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
            uint _S2079 = b_10 + 1U;
            b_7 = _S2079;
            layer_0 = _S2078;
            continue;
        }
        FKRay _S2080 = ray_3;
        float _S2081 = distance_1(reconnection_0, (&ray_3)->origin) * 1.0010000467300415f;
        if(replay_2)
        {
            refracted_4 = _S1769;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S1524 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S2082 = _slang_select(wrong_side_0, _S2081,4.294967296e+09f);
        bool _S2083 = !_S1731;
        if(straight_0)
        {
            _S1815 = true;
        }
        else
        {
            _S1815 = _S1731;
        }
        FKHit _S2084;
        if(_S1815)
        {
            _S2084 = hit_4;
        }
        else
        {
            _S2084 = _S1786;
        }
        FKHit _S2085 = (fcptTraverseInstanceBVH((_S2080), (_S1667), (_S2082), (_S2083), (_S2084), (viewed_1)));
        hit_4 = _S2085;
        if(replay_2)
        {
            _S1816 = _S1769;
        }
        else
        {
            _S1816 = false;
        }
        if(_S1816)
        {
            _S1883 = _S1524 == 1U;
        }
        else
        {
            _S1883 = false;
        }
        if(_S1883)
        {
            _S1884 = ((&hit_4)->instance_index) == (_S1536.instance_index);
        }
        else
        {
            _S1884 = false;
        }
        if(_S1884)
        {
            _S1885 = ((&hit_4)->triangle_index) == (_S1536.triangle_index);
        }
        else
        {
            _S1885 = false;
        }
        if(_S1885)
        {
            (&hit_4)->uv = _S1536.uv;
            float _S2086 = distance_1(reconnection_0, (&ray_3)->origin);
            (&hit_4)->distance = _S2086;
        }
        if(replay_2)
        {
            _S1886 = _S1769;
        }
        else
        {
            _S1886 = false;
        }
        if(_S1886)
        {
            _S1887 = _S1524 == 3U;
        }
        else
        {
            _S1887 = false;
        }
        if(_S1887)
        {
            _S1888 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1888 = false;
        }
        if(_S1888)
        {
            return _S1520;
        }
        Reservoir _S2087 = chain_1;
        uint _S2088 = filling_2;
        for(;;)
        {
            bool _S2089 = (fcptVaryingUsed());
            if(_S2089)
            {
                _S1889 = _S2088 != 4294967295U;
            }
            else
            {
                _S1889 = false;
            }
            if(_S1889)
            {
                float _S2090 = (fcptMajorant((_S2088)));
                _S1890 = _S2090 > 0.0f;
            }
            else
            {
                _S1890 = any_1(scatter_in_0 > make_float3 (0.0f));
            }
            if(replay_2)
            {
                _S1891 = _S1769;
            }
            else
            {
                _S1891 = false;
            }
            if(_S1891)
            {
                _S1892 = _S1524 == 1U;
            }
            else
            {
                _S1892 = false;
            }
            if(_S1892)
            {
                _S1893 = _S1890;
            }
            else
            {
                _S1893 = false;
            }
            if(_S1893)
            {
                ended_0 = _S1520;
                sky_pdf_2 = sky_pdf_3;
                spread_2 = spread_4;
                width_4 = width_3;
                density_4 = density_8;
                throughput_12 = throughput_11;
                b_10 = b_7;
                _S1894 = true;
                break;
            }
            bool _S2091 = (&prev_1)->rough;
            if(_S2091)
            {
                _S1894 = !_S1890;
            }
            else
            {
                _S1894 = false;
            }
            (&prev_1)->rough = _S1894;
            uint _S2092 = b_7 + 320U;
            bool _S2093 = b_7 == 4294967295U;
            uint _S2094 = _slang_select(_S2093, 384U,_S2092);
            uint _S2095 = stream(_S1547, _S2094);
            uint tracking_1 = _S2095;
            weight_2 = throughput_4;
            glowed_0 = _S1519;
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
                    _S1518 = int(2);
                    break;
                }
                float _S2096 = (&hit_4)->distance;
                if(_S1889)
                {
                    float3  _S2097 = (&ray_3)->origin;
                    float3  _S2098 = (&ray_3)->unit_direction;
                    float _S2099 = (&hit_4)->distance;
                    bool _S2100 = b_10 == 4294967295U;
                    uint _S2101 = _slang_select(_S2100, 0U,b_10);
                    uint _S2102 = (&prev_1)->lobe;
                    uint _S2103 = _slang_select(_S2100, 3U,_S2102);
                    float _S2104 = (fcptTrackMedium((_S2088), (_S2097), (_S2098), (_S2099), (&tracking_1), (&weight_2), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S2101), (_S2103), (_S2100)));
                    spread_3 = _S2104;
                }
                else
                {
                    if(_S1890)
                    {
                        uint _S2105 = noiseAddress(_S1547, b_10);
                        Random _S2106 = draw(_S2105, 10U);
                        float _S2107 = 3.0f * _S2106.value;
                        uint _S2108 = (U32_min((uint(_S2107)), (2U)));
                        float _S2109 = - (F32_log((1.0f - (_S2107 - float(_S2108))))) / *_slang_vector_get_element_ptr(&scatter_in_0, _S2108);
                        spread_3 = _S2109;
                    }
                    else
                    {
                        spread_3 = _S2096;
                    }
                }
                bool _S2110 = !(spread_3 < ((&hit_4)->distance));
                if(_S2110)
                {
                    _S1518 = int(2);
                    break;
                }
                if(_S1889)
                {
                    _S1895 = _S1740;
                }
                else
                {
                    _S1895 = false;
                }
                if(_S1895)
                {
                    float3  _S2111 = pathColor(throughput_12 * glowed_0, spectral_weight_1, wavelength_9);
                    float3  _S2112 = _S2111 / make_float3 (density_4);
                    float3  _S2113 = sel_8->glow + _S2112;
                    sel_8->glow = _S2113;
                }
                else
                {
                }
                glowed_0 = _S1519;
                uint b_11 = b_10 + 1U;
                float3  _S2114 = (&ray_3)->origin + make_float3 (spread_3) * (&ray_3)->unit_direction;
                (&ray_3)->origin = _S2114;
                float3  _S2115 = flightWeight_0(scatter_in_0, extinction_in_0, spread_3, true);
                float3  _S2116 = weight_2;
                float _S2117 = upsample(weight_2, wavelength_9);
                float3  _S2118 = make_float3 (_S2117);
                float3  _S2119 = _slang_select(_S1763, _S2118,_S2116);
                float3  _S2120 = _slang_select(_S1889, _S2119,_S2115);
                float3  throughput_13 = throughput_12 * _S2120;
                uint _S2121 = stream(_S1547, b_11 + 320U);
                tracking_1 = _S2121;
                weight_2 = throughput_4;
                float width_8 = width_4 + spread_2 * spread_3;
                float _S2122 = spread_2 + 3.14159274101257324f;
                if(_S1740)
                {
                    _S1896 = true;
                }
                else
                {
                    bool _S2123 = b_11 == _S1535;
                    if(_S2123)
                    {
                        _S1896 = !_S1889;
                    }
                    else
                    {
                        _S1896 = false;
                    }
                }
                TreeSample light_4;
                if(_S1896)
                {
                    float3  _S2124 = (&ray_3)->origin;
                    float3  _S2125 = (&ray_3)->unit_direction;
                    float3  _S2126 = (&ray_3)->unit_direction;
                    uint _S2127 = noiseAddress(_S1547, b_11);
                    float3  _S2128 = extinction_in_0;
                    float3  _S2129 = extinction_in_0;
                    uint2  _S2130 = make_uint2 (_S2088);
                    float3  _S2131 = (&ray_3)->unit_direction;
                    uint _S2132 = arrivalLobe_0(b_11, (&prev_1)->lobe);
                    FKHit _S2133 = _S1786;
                    ShadowContext _S2134 = ShadowContext_x24init_0(_S2128, _S2129, _S2130, _S2131, b_11, _S2132, false, spread_3, width_8, &_S2133, false);
                    ShadowContext _S2135 = _S2134;
                    TreeSample _S2136 = sampleLightTree_0(_S2124, _S2125, _S2126, 0.0f, true, _S2127, &_S2135);
                    light_4 = _S2136;
                }
                else
                {
                    light_4 = _S1783;
                }
                float _S2137 = phaseHG_0(g_in_0, dot_0((&ray_3)->unit_direction, light_4.dir));
                uint _S2138 = (fcptMaxBounces());
                bool _S2139 = b_11 < _S2138;
                if(_S2139)
                {
                    _S1897 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1897 = false;
                }
                float _S2140 = _slang_select(_S1897, _S2137,0.0f);
                float3  _S2141 = throughput_13 * light_4.radiance;
                float _S2142 = powerHeuristic(light_4.density, _S2140);
                float3  _S2143 = pathColor(_S2141 * make_float3 (_S2137 * _S2142), spectral_weight_1, wavelength_9);
                float3  _S2144 = _slang_select(_S1896, _S2143,_S1519);
                if(replay_2)
                {
                    _S1898 = b_11 == _S1535;
                }
                else
                {
                    _S1898 = false;
                }
                if(_S1898)
                {
                    bool _S2145 = _S1524 == 2U;
                    if(_S2145)
                    {
                        float _S2146 = resamplingTarget(_S2144);
                        _S1899 = _S2146 > 0.0f;
                    }
                    else
                    {
                        _S1899 = false;
                    }
                    if(_S1899)
                    {
                        Shift _S2147 = Shift_x24init_0(_S2144, 1.0f);
                        _S1518 = int(1);
                        ended_0 = _S2147;
                        spread_3 = _S2122;
                        width_5 = width_8;
                        throughput_10 = throughput_13;
                        b_8 = b_11;
                        break;
                    }
                    _S1518 = int(1);
                    ended_0 = _S1520;
                    spread_3 = _S2122;
                    width_5 = width_8;
                    throughput_10 = throughput_13;
                    b_8 = b_11;
                    break;
                }
                if(_S1740)
                {
                    Reservoir candidate_9 = _S2087;
                    uint _S2148 = extractBits_0(_S2087.path, 24U, 8U);
                    uint _S2149 = insertBits_0(0U, _S2148, 24U, 8U);
                    uint _S2150 = extractBits_0(_S2087.path, 10U, 2U);
                    bool _S2151 = _S2150 == 1U;
                    if(_S2151)
                    {
                        float3  _S2152 = safeDivide(_S2144, chain_throughput_1);
                        (&candidate_9)->radiance = _S2152;
                    }
                    else
                    {
                        uint _S2153 = insertBits_0(_S2149, b_11 + 1U, 5U, 5U);
                        uint _S2154 = insertBits_0(_S2153, 2U, 10U, 2U);
                        (&candidate_9)->path = _S2154;
                    }
                    Reservoir _S2155 = withEnd(candidate_9, 0U, b_11, _S2144);
                    offer(sel_8, _S2155, _S2144 * make_float3 (scale_4) / make_float3 (density_4));
                    float _S2156 = survivalProbability(abs_0(throughput_13), density_4);
                    uint _S2157 = (fcptMaxBounces());
                    bool _S2158 = b_11 >= _S2157;
                    if(_S2158)
                    {
                        _S1899 = true;
                    }
                    else
                    {
                        bool _S2159 = _S2156 < 1.0f;
                        if(_S2159)
                        {
                            uint _S2160 = noiseAddress(_S1547, b_11);
                            Random _S2161 = draw(_S2160, 8U);
                            _S1899 = _S2156 < (_S2161.value);
                        }
                        else
                        {
                            _S1899 = false;
                        }
                    }
                    if(_S1899)
                    {
                        _S1518 = int(1);
                        ended_0 = _S1520;
                        spread_3 = _S2122;
                        width_5 = width_8;
                        throughput_10 = throughput_13;
                        b_8 = b_11;
                        break;
                    }
                    float _S2162 = density_4 * _S2156;
                    density_4 = _S2162;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S2163 = noiseAddress(_S1547, b_11);
                float3  _S2164 = samplePhase_0(g_in_0, (&ray_3)->unit_direction, _S2163, &phase_pdf_1);
                (&ray_3)->unit_direction = _S2164;
                NEEVertex _S2165 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_3)->origin, _S1519, (&ray_3)->origin);
                nee_vertex_1 = _S2165;
                Vertex _S2166 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_5);
                prev_1 = _S2166;
                float _S2167 = (&prev_1)->pdf;
                FKRay _S2168 = ray_3;
                FKHit _S2169 = (fcptTraverseInstanceBVH((_S2168), (true), (4.294967296e+09f), (false), (_S1786), (false)));
                hit_4 = _S2169;
                b_10 = b_11;
                throughput_12 = throughput_13;
                spread_2 = _S2122;
                width_4 = width_8;
                sky_pdf_2 = _S2167;
            }
            if(_S1518 != int(2))
            {
                spread_2 = spread_3;
                width_4 = width_5;
                throughput_12 = throughput_10;
                b_10 = b_8;
                _S1894 = true;
                break;
            }
            ended_0 = _S1520;
            _S1894 = false;
            break;
        }
        if(_S1894)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1895 = b_10 == b_7;
        }
        else
        {
            _S1895 = false;
        }
        bool _S2170 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S2170)
        {
            Reservoir _S2171 = chain_1;
            FKRay _S2172 = ray_3;
            Vertex _S2173 = prev_1;
            NEEVertex _S2174 = nee_vertex_1;
            Shift _S2175 = escape_0(r_9, replay_2, _S1535, _S1524, _S1522, _S1525, scale_4, _S1549, &_S2171, chain_throughput_1, b_10, &_S2172, throughput_12, density_4, &_S2173, &_S2174, sky_pdf_2, spectral_weight_1, wavelength_9, sel_8);
            return _S2175;
        }
        FKHit _S2176 = hit_4;
        uint _S2177 = filling_2;
        float3  _S2178 = scatter_in_0;
        float3  _S2179 = extinction_in_0;
        float3  _S2180 = weight_2;
        float3  _S2181 = glowed_0;
        float3  _S2182 = (&ray_3)->origin + make_float3 (_S2176.distance) * (&ray_3)->unit_direction;
        (&ray_3)->origin = _S2182;
        bool _S2183 = (fcptVaryingUsed());
        if(_S2183)
        {
            _S1896 = _S2177 != 4294967295U;
        }
        else
        {
            _S1896 = false;
        }
        if(_S1896)
        {
            if(_S1740)
            {
                float3  _S2184 = pathColor(throughput_12 * _S2181, spectral_weight_1, wavelength_9);
                float3  _S2185 = _S2184 / make_float3 (density_4);
                float3  _S2186 = sel_8->glow + _S2185;
                sel_8->glow = _S2186;
            }
            else
            {
            }
            float3  _S2187 = throughput_12 * _S2180;
            throughput_10 = _S2187;
        }
        else
        {
            float3  _S2188 = flightWeight_0(_S2178, _S2179, _S2176.distance, false);
            float3  _S2189 = throughput_12 * _S2188;
            throughput_10 = _S2189;
        }
        float width_9 = width_4 + spread_2 * _S2176.distance;
        viewed_0 = _S1895;
        width_3 = width_9;
        throughput_3 = throughput_10;
        density_3 = density_4;
        sky_pdf_1 = sky_pdf_2;
        spread_1 = spread_2;
        uint _S2079 = b_10 + 1U;
        b_7 = _S2079;
        layer_0 = _S2078;
    }
    return _S1520;
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
    Random _S2190 = pcg(state_4);
    Random _S2191 = pcg(_S2190.state);
    float _S2192 = 6.28318548202514648f * _S2190.value;
    float _S2193 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S2191.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S2191.state, _S2193 * (F32_cos((_S2192))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_5, float3  value_2)
{
    RandomSphere _S2194;
    (&_S2194)->state = state_5;
    (&_S2194)->value = value_2;
    return _S2194;
}

__device__ RandomSphere random_sphere(uint state_6)
{
    Random _S2195 = normal_distribution(state_6);
    Random _S2196 = normal_distribution(_S2195.state);
    Random _S2197 = normal_distribution(_S2196.state);
    float3  _S2198 = make_float3 (_S2195.value, _S2196.value, _S2197.value);
    float3  _S2199 = ((((_S2198)) * make_float3(rnorm3df(((_S2198)).x, ((_S2198)).y, ((_S2198)).z))));
    return RandomSphere_x24init_0(_S2197.state, _S2199);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_13)
{
    float3  _S2200 = p1_0 - p0_0;
    float3  _S2201 = p2_0 - p0_0;
    float2  _S2202 = uv1_0 - uv0_0;
    float2  _S2203 = uv2_0 - uv0_0;
    float _S2204 = _S2202.x;
    float _S2205 = _S2203.y;
    float _S2206 = _S2202.y;
    float _S2207 = _S2203.x;
    float _S2208 = _S2204 * _S2205 - _S2206 * _S2207;
    float _S2209 = 1.0f / _S2208;
    float3  t_24 = (_S2200 * make_float3 (_S2205) - _S2201 * make_float3 (_S2206)) * make_float3 (_S2209);
    float3  _S2210 = (_S2201 * make_float3 (_S2204) - _S2200 * make_float3 (_S2207)) * make_float3 (_S2209);
    float3  _S2211 = t_24 - n_13 * make_float3 (dot_0(n_13, t_24));
    float3  _S2212 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_13);
    bool _S2213 = (dot_0(_S2211, _S2211)) > 0.0f;
    float3  _S2214 = _slang_select(_S2213, _S2211,_S2212);
    float3  _S2215 = ((((_S2214)) * make_float3(rnorm3df(((_S2214)).x, ((_S2214)).y, ((_S2214)).z))));
    bool _S2216 = (dot_0(cross_0(n_13, _S2215), _S2210)) > 0.0f;
    float3  t_25;
    if(_S2216)
    {
        float3  _S2217 = negate_0(_S2215);
        t_25 = _S2217;
    }
    else
    {
        t_25 = _S2215;
    }
    float3  _S2218 = cross_0(n_13, t_25);
    return makeMatrix<float, 3, 3> (t_25, _S2218, n_13);
}

__device__ float3  tangentToWorldNormalMap(float3  v_13, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_13, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_4, float3  uvw_0, float3  position_0)
{
    float3  _S2219 = t1_0 - t0_0;
    float3  _S2220 = t2_2 - t0_0;
    float3  _S2221 = t2_2 - t1_0;
    float _S2222 = (F32_min((length_0(_S2219)), ((F32_min((length_0(_S2220)), (length_0(_S2221)))))));
    float3  _S2223 = make_float3 (distance_1(position_0, t0_0), distance_1(position_0, t1_0), distance_1(position_0, t2_2));
    float3  _S2224 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S2225 = dot_0(geometry_n_4, _S2224);
    float3  _S2226 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S2227 = dot_0(geometry_n_4, _S2226);
    float3  _S2228 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S2229 = acos_0(abs_0(make_float3 (_S2225, _S2227, dot_0(geometry_n_4, _S2228))));
    float3  _S2230 = clamp_2(tan_0(_S2229), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S2223 * _S2230, uvw_0), 0.0f, _S2222 * 0.125f);
}

__device__ float3  straightThrough(BSDFMaterial material_29)
{
    return make_float3 (material_29.transmission * (1.0f - material_29.metallic)) * material_29.albedo;
}

__device__ float hairRow(float3  in_dir_13, float3  t_26, float3  out_dir_3, uint p_15, float w_20, float alpha_9, uint nt_0)
{
    uint _S2231 = p_15 % 4U;
    float _S2232 = w_20 * HAIR_WIDTHS_0[_S2231];
    float _S2233 = (F32_asin((clamp_1(dot_0(out_dir_3, t_26), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_13, t_26), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S2231] * alpha_9;
    return ((F32_asinh((_S2233 / _S2232))) / (F32_asinh((3.14159274101257324f / _S2232))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_14, float3  t_27, float3  out_dir_4, uint np_0)
{
    float3  _S2234 = worldToTangent(out_dir_4, t_27);
    float3  _S2235 = worldToTangent(in_dir_14, t_27);
    return (F32_frac((((F32_atan2((_S2234.z), (_S2234.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S2235.z), (1.17549435082228751e-38f - _S2235.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_15, float3  t_28, uint p_16, float row_0, float column_0, float w_21, float alpha_10, uint nt_1, uint np_1)
{
    float3  _S2236 = worldToTangent(in_dir_15, t_28);
    uint _S2237 = p_16 % 4U;
    float _S2238 = w_21 * HAIR_WIDTHS_0[_S2237];
    float _S2239 = (F32_asin((clamp_1(dot_0(in_dir_15, t_28), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S2237] * alpha_10 + _S2238 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S2238))))));
    float _S2240 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S2236.z), (1.17549435082228751e-38f - _S2236.x)));
    float _S2241 = (F32_cos((_S2239)));
    float3  _S2242 = tangentToWorld(make_float3 (_S2241 * (F32_cos((_S2240))), (F32_sin((_S2239))), _S2241 * (F32_sin((_S2240)))), t_28);
    return _S2242;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_14, BSDFMaterial material_30, float coverage_1)
{
    float3  through_2;
    if((material_30.ior) == 1.0f)
    {
        float3  _S2243 = straightThrough(material_30);
        through_2 = _S2243;
    }
    else
    {
        through_2 = make_float3 (0.0f);
    }
    CoatFrame _S2244 = coatFrame(material_30, n_14);
    bool _S2245 = (_S2244.ior) > 0.0f;
    if(_S2245)
    {
        float _S2246 = fresnel((F32_abs((dot_0(_S2244.normal, toward_1)))), 1.0f, _S2244.ior);
        float3  _S2247 = mix_0(make_float3 (1.0f), make_float3 (1.0f - _S2246) * material_30.coat_tint, material_30.coat);
        float3  through_3 = through_2 * _S2247;
        through_2 = through_3;
    }
    return through_2 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_8, Reservoir r_10, bool replay_3, float scale_5, Selection * sel_9)
{
    Domain _S2248 = dom_8;
    Reservoir _S2249 = r_10;
    Shift _S2250 = walk_0(&_S2248, &_S2249, replay_3, scale_5, sel_9);
    return _S2250;
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
        uint _S2251 = size_0 - 1U;
        uint _S2252 = (x_29 + size_0 / 2U) & _S2251;
        bool _S2253 = i_27 < 2U;
        uint _S2254 = _slang_select(_S2253, x_29,_S2252);
        uint l_5 = _S2254;
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
            uint _S2255 = hash(((r_11 ^ (t_29 << 16U)) ^ (k_4 << 28U)) ^ ((i_27 & 1U) << 31U));
            uint _S2256 = l_5 ^ (_S2255 & _S2251);
            uint k_5 = k_4 + 1U;
            l_5 = r_11;
            r_11 = _S2256;
            k_4 = k_5;
        }
        uint _S2257 = l_5 + r_11 * size_0;
        uint _S2258 = size_0 * size_0;
        uint _S2259;
        if(_S2258 >= 65536U)
        {
            uint _S2260 = _S2257 / (_S2258 / 65536U);
            _S2259 = _S2260;
        }
        else
        {
            uint _S2261 = 65536U / _S2258;
            _S2259 = _S2257 * _S2261;
        }
        ranks_0[i_27] = _S2259;
        uint i_28 = i_27 + 1U;
        i_27 = i_28;
    }
    bool _S2262 = (ranks_0[int(0)]) == 65535U;
    bool _S2263;
    if(_S2262)
    {
        _S2263 = (ranks_0[int(1)]) == 65535U;
    }
    else
    {
        _S2263 = false;
    }
    bool _S2264 = (ranks_0[int(2)]) == 65535U;
    bool _S2265;
    if(_S2264)
    {
        _S2265 = (ranks_0[int(3)]) == 65535U;
    }
    else
    {
        _S2265 = false;
    }
    if(_S2263)
    {
        _S2263 = (ranks_0[int(3)]) != 65535U;
    }
    else
    {
        _S2263 = false;
    }
    if(_S2263)
    {
        _S2263 = true;
    }
    else
    {
        if(_S2265)
        {
            _S2263 = (ranks_0[int(1)]) != 65535U;
        }
        else
        {
            _S2263 = false;
        }
    }
    uint _S2266 = ranks_0[int(0)];
    uint _S2267 = ranks_0[int(1)];
    uint _S2268 = ranks_0[int(3)];
    uint _S2269 = _slang_select(_S2263, _S2268,_S2267);
    return _S2266 | (_S2269 << 16U);
}

__device__ uint3  noiseBlock(uint sweep_0, uint colour_0, uint block_0, uint size_1)
{
    uint _S2270 = hash(sweep_0 * 7919U + 1U);
    uint _S2271 = size_1 / 16U;
    uint _S2272 = block_0 % _S2271;
    uint _S2273 = block_0 / _S2271;
    uint _S2274 = _S2273 % _S2271;
    uint _S2275 = block_0 / (_S2271 * _S2271);
    uint3  _S2276 = make_uint3 (_S2272, _S2274, _S2275);
    uint3  _S2277 = make_uint3 (colour_0 & 1U, (colour_0 >> 1U) & 1U, colour_0 >> 2U);
    return _S2276 * make_uint3 (16U) + _S2277 * make_uint3 (8U) + make_uint3 (_S2270 & 7U, (_S2270 >> 3U) & 7U, (_S2270 >> 6U) & 7U);
}

#undef Matrix
