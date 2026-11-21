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

__device__ float importance(LightNode node_0, float3  p_9, float3  normal_0)
{
    float3  _S224 = (node_0.low + node_0.high) * make_float3 (0.5f);
    float3  _S225 = node_0.high - node_0.low;
    float3  _S226 = p_9 - _S224;
    float3  _S227 = ((((_S226)) * make_float3(rnorm3df(((_S226)).x, ((_S226)).y, ((_S226)).z))));
    float _S228 = dot_0(_S226, _S226);
    float _S229 = dot_0(_S225, _S225) / 4.0f;
    float _S230 = (F32_abs((dot_0(node_0.w, _S227))));
    float _S231 = sine(node_0.cos_theta_o);
    float _S232 = (F32_sqrt(((F32_max((1.0f - _S229 / _S228), (0.0f))))));
    bool _S233 = _S228 < _S229;
    float _S234 = _slang_select(_S233, -1.0f,_S232);
    float _S235 = sine(_S234);
    float _S236 = sine(_S230);
    float _S237 = cosSubClamped(_S236, _S230, _S231, node_0.cos_theta_o);
    float _S238 = sine(_S230);
    float _S239 = _S238 * node_0.cos_theta_o - _S230 * _S231;
    bool _S240 = _S230 > (node_0.cos_theta_o);
    float _S241 = _slang_select(_S240, 0.0f,_S239);
    float _S242 = cosSubClamped(_S241, _S237, _S235, _S234);
    bool _S243 = _S242 <= 0.0f;
    if(_S243)
    {
        return 0.0f;
    }
    float _S244 = - dot_0(_S227, normal_0);
    float _S245 = node_0.phi * _S242 / (F32_max((_S228), (length_0(_S225) / 2.0f)));
    float _S246 = sine(_S244);
    float _S247 = cosSubClamped(_S246, _S244, _S235, _S234);
    bool _S248 = (dot_0(normal_0, normal_0)) == 0.0f;
    float _S249 = _slang_select(_S248, 1.0f,_S247);
    return (F32_max((_S245 * _S249), (0.0f)));
}

__device__ __forceinline__ float childShare(LightNode first_0, LightNode second_0, float3  p_10, float3  normal_1, uint child_0)
{
    float _S250 = importance(first_0, p_10, normal_1);
    float _S251 = importance(second_0, p_10, normal_1);
    float2  _S252 = make_float2 (_S250, _S251);
    float _S253 = _slang_vector_get_element(_S252, child_0) / (_S250 + _S251);
    bool _S254 = _slang_vector_get_element(_S252, child_0) > 0.0f;
    float _S255 = _slang_select(_S254, _S253,0.0f);
    return _S255;
}

__device__ float sphereDensity(float3  center_0, float radius_0, float3  p_11)
{
    float3  _S256 = center_0 - p_11;
    float _S257 = radius_0 * radius_0 / dot_0(_S256, _S256);
    bool _S258 = _S257 >= 1.0f;
    if(_S258)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + (F32_sqrt((1.0f - _S257)))) / (6.28318548202514648f * _S257);
}

static __device__ float3  cross_0(float3  left_0, float3  right_0)
{
    float _S259 = left_0.y;
    float _S260 = right_0.z;
    float _S261 = left_0.z;
    float _S262 = right_0.y;
    float _S263 = right_0.x;
    float _S264 = left_0.x;
    return make_float3 (_S259 * _S260 - _S261 * _S262, _S261 * _S263 - _S264 * _S260, _S264 * _S262 - _S259 * _S263);
}

__device__ float solidAngle(float probability_0, float3  normal_2, float3  toward_0)
{
    return 2.0f * probability_0 * (F32_pow((length_0(toward_0)), (3.0f))) / (F32_abs((dot_0(normal_2, toward_0))));
}

static __device__ float lightPdf_0(float3  origin_3, float3  smooth_n_1, float3  start_5, uint j_0, float3  light_point_0)
{
    bool _S265 = j_0 == 4294967295U;
    if(_S265)
    {
        return 0.0f;
    }
    uint4  _S266 = (fcptLightTrail((j_0)));
    uint2  _S267 = uint2 {_S266.x, _S266.y};
    uint n_0 = 0U;
    uint2  trail_0 = _S267;
    float probability_1 = 1.0f;
    for(;;)
    {
        uint4  _S268 = (fcptLightNode((n_0)));
        if((_S268.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S269 = (fcptLightSecond((n_0)));
        uint _S270 = n_0 + 1U;
        LightNode _S271 = (fcptLightBounds((_S270)));
        LightNode _S272 = (fcptLightBounds((_S269)));
        uint _S273 = trail_0.x;
        uint _S274 = _S273 & 1U;
        float _S275 = childShare(_S271, _S272, origin_3, smooth_n_1, _S274);
        float probability_2 = probability_1 * _S275;
        bool _S276 = _S274 == 1U;
        uint _S277 = _slang_select(_S276, _S269,_S270);
        uint _S278 = trail_0.y;
        uint2  _S279 = make_uint2 ((_S273 >> 1U) | (_S278 << 31U), _S278 >> 1U);
        n_0 = _S277;
        trail_0 = _S279;
        probability_1 = probability_2;
    }
    bool _S280 = (fcptSlotLeaf((n_0), (j_0)));
    bool _S281 = !_S280;
    bool _S282;
    if(_S281)
    {
        _S282 = true;
    }
    else
    {
        LightNode _S283 = (fcptLightBounds((n_0)));
        float _S284 = importance(_S283, origin_3, smooth_n_1);
        _S282 = !(_S284 > 0.0f);
    }
    if(_S282)
    {
        _S282 = true;
    }
    else
    {
        bool _S285 = (dot_0(smooth_n_1, smooth_n_1)) > 0.0f;
        if(_S285)
        {
            _S282 = !((dot_0(smooth_n_1, light_point_0 - origin_3)) > 0.0f);
        }
        else
        {
            _S282 = false;
        }
    }
    if(_S282)
    {
        return 0.0f;
    }
    uint4  _S286 = (fcptLightNode((n_0)));
    bool _S287 = (_S286.x) == 2U;
    if(_S287)
    {
        uint _S288 = _S286.y;
        FKLight _S289 = (fcptLight((_S288)));
        FKLight _S290 = (fcptLight((_S288)));
        float _S291 = sphereDensity(_S289.position, _S290.variance, start_5);
        return probability_1 * _S291;
    }
    uint _S292 = _S286.y;
    uint _S293 = (fcptTriangleOffset((_S292)));
    Matrix<float, 3, 3>  _S294 = (fcptWorldTriangle((_S292), (_S293 + _S286.z)));
    float _S295 = solidAngle(probability_1, cross_0(_S294.rows[int(1)] - _S294.rows[int(0)], _S294.rows[int(2)] - _S294.rows[int(0)]), light_point_0 - start_5);
    return _S295;
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
    Random _S296;
    (&_S296)->state = state_0;
    (&_S296)->value = value_0;
    return _S296;
}

__device__ Random pcg(uint state_1)
{
    uint _S297 = hash(state_1);
    float value_1 = float(_S297 >> int(8)) * 5.9604644775390625e-08f;
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

__device__ float upsample(float3  rgb_0, float wavelength_0)
{
    float _S310 = dot_0(make_float3 (-0.08011700212955475f, 1.08901798725128174f, -0.00889899954199791f), rgb_0);
    float _S311 = dot_0(make_float3 (0.12177000194787979f, -1.22903203964233398f, 1.10724997520446777f), rgb_0);
    float _S312 = dot_0(make_float3 (1.17252397537231445f, -1.21603405475616455f, 0.04350199922919273f), rgb_0);
    float3  _S313 = make_float3 (_S310, _S311, _S312);
    float _S314 = (wavelength_0 - 0.44999998807907104f) / 0.02999999932944775f;
    float _S315 = (wavelength_0 - 0.63999998569488525f) / 0.03999999910593033f;
    return _S310 + _S311 * (F32_exp((-0.5f * _S314 * _S314))) + _S312 * (F32_exp((-0.5f * _S315 * _S315)));
}

__device__ BSDFMaterial atWavelength(BSDFMaterial material_0, float wavelength_1)
{
    BSDFMaterial at_0 = material_0;
    float _S316 = upsample(material_0.albedo, wavelength_1);
    float3  _S317 = make_float3 (_S316);
    (&at_0)->albedo = _S317;
    float _S318 = upsample(material_0.emissive, wavelength_1);
    float3  _S319 = make_float3 (_S318);
    (&at_0)->emissive = _S319;
    float _S320 = upsample(material_0.absorption, wavelength_1);
    float3  _S321 = make_float3 (_S320);
    (&at_0)->absorption = _S321;
    float _S322 = upsample(material_0.specular_tint, wavelength_1);
    float3  _S323 = make_float3 (_S322);
    (&at_0)->specular_tint = _S323;
    float _S324 = upsample(material_0.translucent, wavelength_1);
    float3  _S325 = make_float3 (_S324);
    (&at_0)->translucent = _S325;
    float _S326 = upsample(material_0.sheen, wavelength_1);
    float3  _S327 = make_float3 (_S326);
    (&at_0)->sheen = _S327;
    return at_0;
}

__device__ BSDFMaterial pathMaterial(BSDFMaterial material_1, float wavelength_2)
{
    BSDFMaterial _S328;
    if(wavelength_2 > 0.0f)
    {
        BSDFMaterial _S329 = atWavelength(material_1, wavelength_2);
        _S328 = _S329;
    }
    else
    {
        _S328 = material_1;
    }
    return _S328;
}

static __device__ float3  negate_0(float3  x_13)
{
    return - x_13;
}

static __device__ float sign_0(float e_1)
{
    float _S330;
    if(e_1 > 0.0f)
    {
        _S330 = 1.0f;
    }
    else
    {
        if(e_1 < 0.0f)
        {
            _S330 = -1.0f;
        }
        else
        {
            _S330 = 0.0f;
        }
    }
    return _S330;
}

struct AnisotropicFrame
{
    float3  tangent;
    float2  alphas;
};

static __device__ AnisotropicFrame AnisotropicFrame_x24init_0(float3  tangent_0, float2  alphas_0)
{
    AnisotropicFrame _S331;
    (&_S331)->tangent = tangent_0;
    (&_S331)->alphas = alphas_0;
    return _S331;
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_1)
{
    float3  a_1 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S332 = (F32_abs((dot_0(n_1, a_1)))) > 0.9999847412109375f;
    float3  a_2;
    if(_S332)
    {
        float3  _S333 = make_float3 (1.0f, 0.0f, 0.0f);
        a_2 = _S333;
    }
    else
    {
        a_2 = a_1;
    }
    float3  _S334 = cross_0(n_1, a_2);
    float3  _S335 = ((((_S334)) * make_float3(rnorm3df(((_S334)).x, ((_S334)).y, ((_S334)).z))));
    float3  _S336 = cross_0(n_1, _S335);
    return make_float3 (v_0.x) * _S335 + make_float3 (v_0.y) * n_1 + make_float3 (v_0.z) * _S336;
}

__device__ AnisotropicFrame anisotropicFrame(BSDFMaterial material_2, float3  n_i_0)
{
    float _S337 = material_2.roughness;
    float _S338 = _S337 * _S337;
    bool _S339 = (material_2.anisotropy) == 0.0f;
    bool _S340;
    if(_S339)
    {
        _S340 = true;
    }
    else
    {
        _S340 = !(_S338 > 0.0f);
    }
    if(_S340)
    {
        return AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f));
    }
    float3  _S341 = material_2.tangent - n_i_0 * make_float3 (dot_0(n_i_0, material_2.tangent));
    float3  _S342 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_i_0);
    bool _S343 = (dot_0(_S341, _S341)) > 0.0f;
    float3  _S344 = _slang_select(_S343, _S341,_S342);
    float3  _S345 = ((((_S344)) * make_float3(rnorm3df(((_S344)).x, ((_S344)).y, ((_S344)).z))));
    float _S346 = 6.28318548202514648f * material_2.anisotropic_rotation;
    float _S347 = (F32_sqrt((1.0f - 0.89999997615814209f * (F32_abs((material_2.anisotropy))))));
    float _S348 = 1.0f / _S347;
    bool _S349 = (material_2.anisotropy) < 0.0f;
    float _S350 = _slang_select(_S349, _S348,_S347);
    return AnisotropicFrame_x24init_0(_S345 * make_float3 ((F32_cos((_S346)))) + cross_0(n_i_0, _S345) * make_float3 ((F32_sin((_S346)))), make_float2 (_S338 / _S350, _S338 * _S350));
}

struct SheenProfile
{
    bool on;
    float albedo;
};

static __device__ SheenProfile SheenProfile_x24init_0(bool on_0, float albedo_0)
{
    SheenProfile _S351;
    (&_S351)->on = on_0;
    (&_S351)->albedo = albedo_0;
    return _S351;
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
    SheenProfile _S352 = SheenProfile_x24init_0(false, 0.0f);
    float _S353 = rgb_to_greyscale(material_3.sheen);
    bool _S354 = _S353 > 0.0f;
    SheenProfile profile_0;
    if(_S354)
    {
        float _S355 = clamp_1((F32_sqrt(((F32_max((dot_0(n_i_1, v_1)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S356 = (U32_min((uint(_S355)), (22U)));
        float _S357 = (F32_sqrt((0.05000000074505806f)));
        float _S358 = (F32_sqrt((0.10000000149011612f)));
        bool _S359 = (material_3.velvet) > 0.0f;
        float _S360 = _slang_select(_S359, _S358,_S357);
        float _S361 = (clamp_1((F32_sqrt(((F32_max((material_3.sheen_roughness), (0.0f)))))), _S360, 1.0f) - _S360) / (1.0f - _S360) * 23.0f;
        uint _S362 = (U32_min((uint(_S361)), (22U)));
        uint _S363 = _S356 * 24U + _S362;
        float _S364 = _S355 - float(_S356);
        float _S365 = _S361 - float(_S362);
        if(_S359)
        {
            uint _S366 = _S363 + 24U;
            float _S367 = VELVET_ALBEDO_0[_S363] + (VELVET_ALBEDO_0[_S366] - VELVET_ALBEDO_0[_S363]) * _S364;
            uint _S368 = _S363 + 1U;
            float _S369 = VELVET_ALBEDO_0[_S368] + (VELVET_ALBEDO_0[_S366 + 1U] - VELVET_ALBEDO_0[_S368]) * _S364;
            SheenProfile _S370 = SheenProfile_x24init_0(true, _S367 + (_S369 - _S367) * _S365);
            profile_0 = _S370;
        }
        else
        {
            uint _S371 = _S363 + 24U;
            float _S372 = SHEEN_ALBEDO_0[_S363] + (SHEEN_ALBEDO_0[_S371] - SHEEN_ALBEDO_0[_S363]) * _S364;
            uint _S373 = _S363 + 1U;
            float _S374 = SHEEN_ALBEDO_0[_S373] + (SHEEN_ALBEDO_0[_S371 + 1U] - SHEEN_ALBEDO_0[_S373]) * _S364;
            SheenProfile _S375 = SheenProfile_x24init_0(true, (F32_exp((_S372 + (_S374 - _S372) * _S365))));
            profile_0 = _S375;
        }
    }
    else
    {
        profile_0 = _S352;
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
    Weights _S376;
    (&_S376)->v_dot_h = v_dot_h_0;
    (&_S376)->refracted = refracted_1;
    (&_S376)->F = F_0;
    (&_S376)->reflect_weight = reflect_weight_0;
    (&_S376)->diffuse_weight = diffuse_weight_0;
    (&_S376)->refract_weight = refract_weight_0;
    (&_S376)->p_diffuse = p_diffuse_0;
    (&_S376)->p_reflect = p_reflect_0;
    (&_S376)->p_refract = p_refract_0;
    (&_S376)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S376)->p_toon = p_toon_0;
    (&_S376)->sheen = sheen_0;
    (&_S376)->toon = toon_0;
    return _S376;
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
    float3  _S377 = make_float3 (alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z);
    float3  _S378 = ((((_S377)) * make_float3(rnorm3df(((_S377)).x, ((_S377)).y, ((_S377)).z))));
    float _S379 = _S378.x;
    float _S380 = _S378.y;
    float _S381 = _S379 * _S379 + _S380 * _S380;
    float3  _S382;
    if(_S381 > 0.0f)
    {
        float3  _S383 = make_float3 (- _S380, _S379, 0.0f);
        float _S384 = (rsqrtf((_S381)));
        _S382 = _S383 * make_float3 (_S384);
    }
    else
    {
        _S382 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S385 = cross_0(_S378, _S382);
    float _S386 = (F32_sqrt((U1_0)));
    float _S387 = 6.28318548202514648f * U2_0;
    float _S388 = _S386 * (F32_cos((_S387)));
    float t2_0 = _S386 * (F32_sin((_S387)));
    float _S389 = 0.5f * (1.0f + _S378.z);
    float t2_1 = (1.0f - _S389) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S388 * _S388)))))) + _S389 * t2_0;
    float3  _S390 = make_float3 (_S388) * _S382 + make_float3 (t2_1) * _S385;
    float _S391 = unshared_0(_S388);
    float _S392 = unshared_0(_S388);
    float3  _S393 = _S390 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S391 * _S392 - t2_1 * t2_1))))))) * _S378;
    float3  _S394 = make_float3 (alpha_0 * _S393.x, alpha_0 * _S393.y, (F32_max((0.0f), (_S393.z))));
    float3  _S395 = ((((_S394)) * make_float3(rnorm3df(((_S394)).x, ((_S394)).y, ((_S394)).z))));
    return _S395;
}

__device__ float3  worldToTangent(float3  v_2, float3  n_3)
{
    float3  a_3 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S396 = (F32_abs((dot_0(n_3, a_3)))) > 0.9999847412109375f;
    float3  a_4;
    if(_S396)
    {
        float3  _S397 = make_float3 (1.0f, 0.0f, 0.0f);
        a_4 = _S397;
    }
    else
    {
        a_4 = a_3;
    }
    float3  _S398 = cross_0(n_3, a_4);
    float3  _S399 = ((((_S398)) * make_float3(rnorm3df(((_S398)).x, ((_S398)).y, ((_S398)).z))));
    float3  _S400 = cross_0(n_3, _S399);
    return make_float3 (dot_0(v_2, _S399), dot_0(v_2, n_3), dot_0(v_2, _S400));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_3, float3  n_i_2, float alpha_1, AnisotropicFrame frame_0, uint * random_state_2)
{
    Random _S401 = pcg(*random_state_2);
    Random _S402 = pcg(_S401.state);
    *random_state_2 = _S402.state;
    float _S403 = frame_0.alphas.x;
    bool _S404 = _S403 > 0.0f;
    if(_S404)
    {
        float3  _S405 = anisotropicLocal(v_3, frame_0.tangent, n_i_2);
        float _S406 = frame_0.alphas.y;
        float3  _S407 = make_float3 (_S403 * _S405.x, _S406 * _S405.y, _S405.z);
        float3  _S408 = ((((_S407)) * make_float3(rnorm3df(((_S407)).x, ((_S407)).y, ((_S407)).z))));
        float3  _S409 = sampleGGXVNDF(_S408, 1.0f, _S401.value, _S402.value);
        float3  _S410 = make_float3 (_S403 * _S409.x, _S406 * _S409.y, _S409.z);
        float3  _S411 = ((((_S410)) * make_float3(rnorm3df(((_S410)).x, ((_S410)).y, ((_S410)).z))));
        return make_float3 (_S411.x) * frame_0.tangent + make_float3 (_S411.y) * cross_0(n_i_2, frame_0.tangent) + make_float3 (_S411.z) * n_i_2;
    }
    float3  _S412 = worldToTangent(v_3, n_i_2);
    float3  _S413 = sampleGGXVNDF(float3 {_S412.x, _S412.z, _S412.y}, alpha_1, _S401.value, _S402.value);
    float3  _S414 = float3 {_S413.x, _S413.z, _S413.y};
    float3  _S415 = tangentToWorld(_S414, n_i_2);
    return _S415;
}

__device__ __forceinline__ float3  sampledHalf(float3  v_4, float3  n_i_3, float alpha_2, AnisotropicFrame frame_1, uint random_state_3)
{
    uint state_2 = random_state_3;
    float3  _S416 = sampleHalfVector(v_4, n_i_3, alpha_2, frame_1, &state_2);
    return _S416;
}

__device__ __forceinline__ float3  refractedHalf(float3  in_dir_0, float3  out_dir_0, float3  n_4, float eta_i_0, float eta_o_0)
{
    float3  _S417 = negate_0(in_dir_0);
    float3  _S418 = negate_0(make_float3 (eta_i_0) * _S417 + make_float3 (eta_o_0) * out_dir_0);
    float3  _S419 = ((((_S418)) * make_float3(rnorm3df(((_S418)).x, ((_S418)).y, ((_S418)).z))));
    float _S420 = sign_0(dot_0(n_4, _S417));
    float _S421 = sign_0(dot_0(_S418, n_4 * make_float3 (_S420)));
    return _S419 * make_float3 (_S421);
}

__device__ __forceinline__ float3  reflectedHalf(float3  in_dir_1, float3  out_dir_1)
{
    float3  _S422 = negate_0(in_dir_1);
    float3  _S423 = _S422 + out_dir_1;
    float3  _S424 = ((((_S423)) * make_float3(rnorm3df(((_S423)).x, ((_S423)).y, ((_S423)).z))));
    return _S424;
}

static __device__ float3  refract_0(float3  i_5, float3  n_5, float eta_0)
{
    float _S425 = dot_0(n_5, i_5);
    float _S426 = 1.0f - eta_0 * eta_0 * (1.0f - _S425 * _S425);
    if(_S426 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_5 - make_float3 (eta_0 * _S425 + (F32_sqrt((_S426)))) * n_5;
}

__device__ float fresnel(float cos_theta_0, float eta_i_1, float eta_o_1)
{
    float _S427 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S428 = eta_i_1 / eta_o_1 * _S427;
    bool _S429 = _S428 < 1.0f;
    float kr_0;
    if(_S429)
    {
        float _S430 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S428 * _S428))))));
        bool _S431 = eta_i_1 == eta_o_1;
        float _S432 = _slang_select(_S431, cos_theta_0,_S430);
        float _S433 = eta_o_1 * cos_theta_0;
        float _S434 = eta_i_1 * _S432;
        float _S435 = (_S433 - _S434) / (_S433 + _S434);
        float _S436 = eta_i_1 * cos_theta_0;
        float _S437 = eta_o_1 * _S432;
        float _S438 = (_S436 - _S437) / (_S436 + _S437);
        float _S439 = (_S435 * _S435 + _S438 * _S438) / 2.0f;
        kr_0 = _S439;
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
    float _S440 = dot_0(ggx_n_0, v_5);
    float _S441 = eta_i_2 / eta_o_2;
    float3  _S442 = refract_0(in_dir_2, ggx_n_0, _S441);
    float3  _S443 = ((((_S442)) * make_float3(rnorm3df(((_S442)).x, ((_S442)).y, ((_S442)).z))));
    float _S444 = (F32_min(((F32_sqrt((material_4.specular_level))) * (F32_abs((eta_i_2 - eta_o_2))) / (eta_i_2 + eta_o_2)), (0.9999847412109375f)));
    float _S445 = _S444 * _S444;
    float _S446 = (1.0f + _S444) / (1.0f - _S444);
    float _S447 = (F32_abs((_S440)));
    bool _S448 = eta_i_2 > eta_o_2;
    float sheen_component_0;
    if(_S448)
    {
        sheen_component_0 = _S446;
    }
    else
    {
        sheen_component_0 = 1.0f;
    }
    float toon_component_0;
    if(_S448)
    {
        toon_component_0 = 1.0f;
    }
    else
    {
        toon_component_0 = _S446;
    }
    float _S449 = fresnel(_S447, sheen_component_0, toon_component_0);
    bool _S450 = (eta_i_2 * eta_i_2 * (1.0f - _S440 * _S440)) >= (eta_o_2 * eta_o_2);
    float3  _S451;
    if(_S450)
    {
        _S451 = make_float3 (1.0f);
    }
    else
    {
        float3  _S452 = material_4.specular_tint * make_float3 (_S445);
        _S451 = _S452 + (make_float3 (1.0f) - _S452) * make_float3 (_S449 - _S445) / make_float3 (1.0f - _S445);
    }
    float3  _S453 = make_float3 (1.0f);
    float3  _S454 = make_float3 (0.0f);
    float3  sheen_1;
    float3  scale_1;
    if(sheen_profile_0.on)
    {
        float _S455 = (F32_min((sheen_profile_0.albedo), (1.0f)));
        float3  _S456 = make_float3 (1.0f) - material_4.sheen * make_float3 (_S455);
        float _S457 = rgb_to_greyscale(material_4.sheen);
        float _S458 = _S457 * _S455;
        float3  _S459 = material_4.sheen / make_float3 ((F32_max((sheen_profile_0.albedo), (1.0f))));
        sheen_component_0 = _S458;
        sheen_1 = _S459;
        scale_1 = _S456;
    }
    else
    {
        sheen_component_0 = 0.0f;
        sheen_1 = _S454;
        scale_1 = _S453;
    }
    float _S460 = (F32_abs((material_4.toon.x)));
    bool _S461 = _S460 > 0.0f;
    float3  toon_1;
    if(_S461)
    {
        float _S462 = (F32_min((_S460), (1.0f)));
        float3  scale_2 = scale_1 * make_float3 (1.0f - _S462);
        float _S463 = rgb_to_greyscale(material_4.albedo);
        float _S464 = _S462 * _S463;
        float3  _S465 = make_float3 (_S462) * material_4.albedo;
        toon_component_0 = _S464;
        toon_1 = _S465;
        scale_1 = scale_2;
    }
    else
    {
        toon_component_0 = 0.0f;
        toon_1 = _S454;
    }
    bool _S466 = (material_4.metallic) > 0.0f;
    float3  rebounce_0;
    if(_S466)
    {
        float _S467 = frame_2.alphas.x;
        float _S468 = (F32_sqrt(((F32_min((_S467), (frame_2.alphas.y))))));
        bool _S469 = _S467 > 0.0f;
        float _S470 = _slang_select(_S469, _S468,material_4.roughness);
        float _S471 = _S470 * _S470;
        float _S472 = (F32_pow((_S471), (1.81585001945495605f))) * (2.15371990203857422f - 0.73285001516342163f * _S471) / (1.0f + 1.28094995021820068f * _S471);
        bool _S473 = _S471 > 0.0f;
        float _S474 = _slang_select(_S473, _S472,0.0f);
        float _S475 = clamp_1(dot_0(n_i_4, v_5), 0.0f, 1.0f);
        float _S476 = _S471 * _S470;
        float _S477 = (F32_min((1.00064504146575928f - _S470 * (0.00375499995425344f + _S475 * (-0.04133399948477745f + _S475 * (-0.90938502550125122f + _S475 * 0.35275399684906006f))) - _S471 * (0.27602800726890564f + _S475 * (1.27023398876190186f + _S475 * 0.04740000143647194f)) - _S476 * (0.31452900171279907f - _S475 * 0.34830701351165771f) + _S476 * _S470 * 0.27229699492454529f), (1.0f)));
        float3  _S478 = min_1(make_float3 (1.0f) / (make_float3 (1.0f) - material_4.albedo * make_float3 (_S474)), make_float3 (1.0f / (F32_max((_S477), (0.0000152587890625f)))));
        rebounce_0 = _S478;
    }
    else
    {
        rebounce_0 = _S453;
    }
    float3  _S479 = mix_0(_S451, material_4.albedo * rebounce_0, material_4.metallic);
    float3  F_1 = _S479 * scale_1;
    float _S480 = rgb_to_greyscale(F_1);
    float _S481 = 1.0f - material_4.metallic;
    float3  _S482 = make_float3 (1.0f) - _S451;
    float3  _S483 = make_float3 ((1.0f - material_4.transmission) * _S481) * _S482 * scale_1;
    float3  _S484 = make_float3 (material_4.transmission * _S481) * _S482 * scale_1;
    float _S485 = (F32_max((_S480), (0.0f)));
    float _S486 = rgb_to_greyscale(_S483);
    float _S487 = (F32_max((_S486), (0.0f)));
    float _S488 = rgb_to_greyscale(_S484);
    float _S489 = sign_0(length_0(_S443));
    float _S490 = (F32_max((_S488 * _S489), (0.0f)));
    float _S491 = _S485 + _S487 + _S490 + toon_component_0;
    float _S492 = (F32_min((sheen_component_0), (1.0f)));
    bool _S493 = sheen_component_0 > 0.0f;
    bool _S494;
    if(_S493)
    {
        _S494 = !(_S491 > 0.0f);
    }
    else
    {
        _S494 = false;
    }
    float _S495 = _slang_select(_S494, 1.0f,_S492);
    float _S496 = (1.0f - _S495) / (F32_max((_S491), (0.0000152587890625f)));
    float _S497 = _S487 * _S496;
    float _S498 = _S485 * _S496;
    float _S499 = _S490 * _S496;
    return Weights_x24init_0(_S440, _S443, F_1, 1.0f, _S483, _S484, _S497, _S498, _S499, _S495, toon_component_0 * _S496, sheen_1, toon_1);
}

__device__ float translucentShare(BSDFMaterial material_5)
{
    float _S500 = rgb_to_greyscale(material_5.translucent);
    float _S501 = rgb_to_greyscale(material_5.albedo);
    float _S502 = _S500 / (_S501 + _S500);
    bool _S503 = _S500 > 0.0f;
    float _S504 = _slang_select(_S503, _S502,0.0f);
    return _S504;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float n_i_dot_v_0, BSDFMaterial material_6, Weights w_1)
{
    float _S505 = translucentShare(material_6);
    float _S506 = w_1.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S507 = w_1.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S508 = 1.0f - _S505;
    bool _S509 = n_i_dot_l_0 < 0.0f;
    float _S510 = _slang_select(_S509, _S505,_S508);
    float _S511 = _S507 * _S510;
    bool _S512 = _S505 > 0.0f;
    float _S513 = _slang_select(_S512, _S511,_S506);
    bool _S514 = n_i_dot_v_0 > 0.0f;
    float _S515 = _slang_select(_S514, _S513,0.0f);
    return _S515;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_5, BSDFMaterial material_7, Weights w_2)
{
    float _S516 = translucentShare(material_7);
    bool _S517 = (dot_0(n_i_5, l_0)) < 0.0f;
    float3  _S518 = _slang_select(_S517, material_7.translucent,material_7.albedo);
    float _S519 = 1.0f - _S516;
    float _S520 = _slang_select(_S517, _S516,_S519);
    float3  _S521 = _S518 / make_float3 (_S520);
    bool _S522 = _S516 > 0.0f;
    float3  _S523 = _slang_select(_S522, _S521,material_7.albedo);
    return w_2.diffuse_weight * _S523 / make_float3 (w_2.p_diffuse);
}

__device__ float smithG1(float alpha_3, float n_dot_x_0)
{
    float _S524 = alpha_3 * alpha_3;
    float _S525 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S524 + (1.0f - _S524) * n_dot_x_0 * n_dot_x_0))));
    bool _S526 = alpha_3 > 0.0f;
    float _S527 = _slang_select(_S526, _S525,1.0f);
    return _S527;
}

__device__ float trowbridgeReitz(float alpha_4, float n_dot_h_0)
{
    float _S528 = alpha_4 * alpha_4;
    float _S529 = (1.0f - n_dot_h_0) * (1.0f + n_dot_h_0) + _S528 * n_dot_h_0 * n_dot_h_0;
    return _S528 / (F32_max((3.14159274101257324f * _S529 * _S529), (1.17549435082228751e-38f)));
}

__device__ float anisotropicG1(float3  w_3, float2  alphas_1)
{
    float _S530 = (F32_max((w_3.z), (0.0f)));
    return 2.0f * _S530 / (_S530 + length_0(make_float3 (alphas_1.x * w_3.x, alphas_1.y * w_3.y, _S530)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_2)
{
    float _S531 = alphas_2.x;
    float _S532 = h_0.x / _S531;
    float _S533 = alphas_2.y;
    float _S534 = h_0.y / _S533;
    float _S535 = h_0.z;
    float _S536 = _S532 * _S532 + _S534 * _S534 + _S535 * _S535;
    return 1.0f / (F32_max((3.14159274101257324f * _S531 * _S533 * _S536 * _S536), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float3  v_6, float3  h_1, float3  n_i_6, float n_i_dot_v_1, float alpha_5, AnisotropicFrame frame_3, float v_dot_h_1)
{
    float _S537 = dot_0(n_i_6, h_1);
    float _S538 = smithG1(alpha_5, n_i_dot_v_1);
    float _S539 = _S538 * v_dot_h_1;
    float _S540 = trowbridgeReitz(alpha_5, _S537);
    float _S541 = _S539 * _S540 / n_i_dot_v_1;
    bool _S542 = alpha_5 > 0.0f;
    bool _S543;
    if(_S542)
    {
        _S543 = v_dot_h_1 > 0.0f;
    }
    else
    {
        _S543 = false;
    }
    if(_S543)
    {
        _S543 = _S537 > 0.0f;
    }
    else
    {
        _S543 = false;
    }
    if(_S543)
    {
        _S543 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S543 = false;
    }
    float _S544 = _slang_select(_S543, _S541,0.0f);
    bool _S545 = (frame_3.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S545)
    {
        float3  _S546 = anisotropicLocal(v_6, frame_3.tangent, n_i_6);
        float _S547 = anisotropicG1(_S546, frame_3.alphas);
        float3  _S548 = anisotropicLocal(h_1, frame_3.tangent, n_i_6);
        float _S549 = anisotropicD(_S548, frame_3.alphas);
        float _S550 = _S547 * _S549;
        float _S551 = _S550 * v_dot_h_1 / n_i_dot_v_1;
        bool _S552 = v_dot_h_1 > 0.0f;
        if(_S552)
        {
            _S543 = _S537 > 0.0f;
        }
        else
        {
            _S543 = false;
        }
        if(_S543)
        {
            _S543 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S543 = false;
        }
        float _S553 = _slang_select(_S543, _S551,0.0f);
        pdf_h_0 = _S553;
    }
    else
    {
        pdf_h_0 = _S544;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float l_dot_h_0, float pdf_h_1, Weights w_4, float eta_i_3, float eta_o_3)
{
    float _S554 = eta_i_3 * w_4.v_dot_h + eta_o_3 * l_dot_h_0;
    float _S555 = w_4.p_refract * pdf_h_1 * eta_o_3 * eta_o_3 * (F32_abs((l_dot_h_0))) / (_S554 * _S554);
    bool _S556 = eta_i_3 != eta_o_3;
    bool _S557;
    if(_S556)
    {
        _S557 = l_dot_h_0 < 0.0f;
    }
    else
    {
        _S557 = false;
    }
    float _S558 = _slang_select(_S557, _S555,0.0f);
    return _S558;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_7, float alpha_6, AnisotropicFrame frame_4, BSDFMaterial material_8, Weights w_5)
{
    float _S559 = - dot_0(n_i_7, l_1);
    float _S560 = smithG1(alpha_6, (F32_max((_S559), (0.0f))));
    bool _S561 = (frame_4.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S561)
    {
        float3  _S562 = negate_0(n_i_7);
        float3  _S563 = anisotropicLocal(l_1, frame_4.tangent, _S562);
        float _S564 = anisotropicG1(_S563, frame_4.alphas);
        G1_l_0 = _S564;
    }
    else
    {
        G1_l_0 = _S560;
    }
    return w_5.refract_weight * make_float3 (G1_l_0) * material_8.albedo / make_float3 (w_5.p_refract);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_1, float n_i_dot_v_2, Weights w_6)
{
    float _S565 = w_6.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S566 = n_i_dot_l_1 > 0.0f;
    bool _S567;
    if(_S566)
    {
        _S567 = n_i_dot_v_2 > 0.0f;
    }
    else
    {
        _S567 = false;
    }
    float _S568 = _slang_select(_S567, _S565,0.0f);
    return _S568;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  v_7, float3  n_i_8, BSDFMaterial material_9, Weights w_7)
{
    float3  _S569 = l_2 + v_7;
    float3  _S570 = ((((_S569)) * make_float3(rnorm3df(((_S569)).x, ((_S569)).y, ((_S569)).z))));
    float _S571 = dot_0(n_i_8, _S570);
    float _S572 = (F32_max((dot_0(n_i_8, l_2)), (0.0f)));
    float _S573 = (F32_max((dot_0(n_i_8, v_7)), (0.0f)));
    float _S574 = 1.0f / (F32_max((material_9.sheen_roughness), (0.05000000074505806f)));
    float _S575 = 1.0f - _S571 * _S571;
    float _S576 = (2.0f + _S574) * (F32_pow(((F32_max((_S575), (0.0f)))), (0.5f * _S574))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S572 + _S573 - _S572 * _S573)), (0.0000152587890625f)));
    bool _S577 = (material_9.velvet) > 0.0f;
    float f_1;
    if(_S577)
    {
        float _S578 = (F32_max((material_9.sheen_roughness), (0.00999999977648258f)));
        float _S579 = _S578 * _S578;
        float _S580 = (F32_max((_S575), (0.0000152587890625f)));
        float _S581 = (F32_exp((- _S571 * _S571 / (_S580 * _S579)))) / (3.14159274101257324f * _S579 * _S580 * _S580) * (F32_min((1.0f), (2.0f * _S571 * (F32_min((_S572), (_S573))) / (F32_max(((F32_abs((dot_0(_S570, v_7))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S572 * _S573), (0.0000152587890625f)));
        f_1 = _S581;
    }
    else
    {
        f_1 = _S576;
    }
    return w_7.sheen * make_float3 (f_1 * _S572 * 2.0f * 3.14159274101257324f / w_7.p_sheen_velvet);
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
    float _S582;
    if(t_13 < a_5)
    {
        _S582 = 1.0f;
    }
    else
    {
        _S582 = (F32_max((1.0f - (t_13 - a_5) / (F32_max((s_0), (0.0000152587890625f)))), (0.0f)));
    }
    return _S582;
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
        float _S583 = (F32_sin(((F32_min((t_14), (a_6))))));
        integral_0 = _S583 * _S583 / 2.0f;
    }
    bool _S584 = t_14 > a_6;
    bool _S585;
    if(_S584)
    {
        _S585 = s_1 > 0.0f;
    }
    else
    {
        _S585 = false;
    }
    if(_S585)
    {
        float _S586;
        if(glossy_0)
        {
            float _S587 = (F32_cos((a_6)));
            float _S588 = (F32_cos((t_14)));
            _S586 = (1.0f + a_6 / s_1) * (_S587 - _S588) - ((F32_sin((t_14))) - t_14 * _S588 - ((F32_sin((a_6))) - a_6 * _S587)) / s_1;
        }
        else
        {
            float _S589 = 2.0f * a_6;
            float _S590 = (F32_cos((_S589)));
            float _S591 = 2.0f * t_14;
            float _S592 = (F32_cos((_S591)));
            _S586 = (1.0f + a_6 / s_1) * (_S590 - _S592) / 4.0f - ((F32_sin((_S591))) / 8.0f - t_14 * _S592 / 4.0f - ((F32_sin((_S589))) / 8.0f - a_6 * _S590 / 4.0f)) / s_1;
        }
        float integral_1 = integral_0 + _S586;
        integral_0 = integral_1;
    }
    return integral_0;
}

static __device__ ToonProfile ToonProfile_x24init_0(bool glossy_1, float a_7, float s_2, float b_1, float norm_0, float view_0, float3  axis_0)
{
    ToonProfile _S593;
    (&_S593)->glossy = glossy_1;
    (&_S593)->a = a_7;
    (&_S593)->s = s_2;
    (&_S593)->b = b_1;
    (&_S593)->norm = norm_0;
    (&_S593)->view = view_0;
    (&_S593)->axis = axis_0;
    return _S593;
}

__device__ __forceinline__ ToonProfile toonProfile(float3  v_8, float3  n_i_9, BSDFMaterial material_10)
{
    float _S594 = material_10.toon.x;
    bool _S595 = _S594 < 0.0f;
    float _S596 = clamp_1(material_10.toon.y / _S594, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S597 = clamp_1(material_10.toon.z / _S594, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S598 = (F32_min((_S596 + _S597), (1.57079637050628662f)));
    float _S599 = dot_0(n_i_9, v_8);
    float _S600 = toonP((F32_acos(((F32_min((_S599), (1.0f)))))), _S596, _S597);
    float3  _S601;
    if(_S595)
    {
        float3  _S602 = make_float3 (2.0f * _S599) * n_i_9 - v_8;
        float3  _S603 = ((((_S602)) * make_float3(rnorm3df(((_S602)).x, ((_S602)).y, ((_S602)).z))));
        _S601 = _S603;
    }
    else
    {
        _S601 = n_i_9;
    }
    float _S604 = toonIntegral(_S598, _S596, _S597, _S595);
    return ToonProfile_x24init_0(_S595, _S596, _S597, _S598, 6.28318548202514648f * _S604, _S600, _S601);
}

__device__ __forceinline__ float toonPDF(float3  l_3, float3  n_i_10, ToonProfile profile_1, Weights w_8)
{
    float _S605 = dot_0(n_i_10, l_3);
    float _S606 = dot_0(l_3, profile_1.axis);
    float _S607 = _slang_select(profile_1.glossy, _S606,_S605);
    float _S608 = (F32_acos((clamp_1(_S607, -1.0f, 1.0f))));
    float _S609 = toonP(_S608, profile_1.a, profile_1.s);
    float _S610 = w_8.p_toon * _S609;
    float _S611 = _slang_select(profile_1.glossy, 1.0f,_S605);
    float _S612 = _S610 * _S611 / profile_1.norm;
    bool _S613;
    if(profile_1.glossy)
    {
        _S613 = true;
    }
    else
    {
        _S613 = _S605 > 0.0f;
    }
    float _S614 = _slang_select(_S613, _S612,0.0f);
    return _S614;
}

__device__ __forceinline__ float3  toonBSDF(float3  l_4, float3  n_i_11, ToonProfile profile_2, Weights w_9)
{
    float _S615 = (F32_max((dot_0(n_i_11, l_4)), (0.0f)));
    float _S616 = _slang_select(profile_2.glossy, _S615,profile_2.view);
    return w_9.toon * make_float3 (_S616) / make_float3 (w_9.p_toon);
}

__device__ __forceinline__ float reflectPDF(float pdf_h_2, Weights w_10)
{
    float _S617 = w_10.p_reflect * pdf_h_2 / (4.0f * w_10.v_dot_h);
    bool _S618 = pdf_h_2 > 0.0f;
    float _S619 = _slang_select(_S618, _S617,0.0f);
    return _S619;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_5, float3  n_i_12, float alpha_7, AnisotropicFrame frame_5, Weights w_11)
{
    float _S620 = dot_0(n_i_12, l_5);
    float _S621 = smithG1(alpha_7, (F32_max((_S620), (0.0f))));
    bool _S622 = (frame_5.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S622)
    {
        float3  _S623 = anisotropicLocal(l_5, frame_5.tangent, n_i_12);
        float _S624 = anisotropicG1(_S623, frame_5.alphas);
        G1_l_1 = _S624;
    }
    else
    {
        G1_l_1 = _S621;
    }
    return make_float3 (w_11.reflect_weight * G1_l_1) * w_11.F / make_float3 (w_11.p_reflect);
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_3, float3  out_dir_2, float3  n_6, BSDFMaterial material_11, float eta_i_4, float eta_o_4, bool refracted_2, uint random_state_4, FixedArray<float3 , 5>  * throughputs_0, FixedArray<float, 5>  * pdfs_0)
{
    float3  ggx_n_1;
    float3  _S625 = negate_0(in_dir_3);
    float _S626 = dot_0(n_6, _S625);
    float _S627 = sign_0(_S626);
    float3  _S628 = n_6 * make_float3 (_S627);
    float _S629 = dot_0(_S628, out_dir_2);
    float _S630 = material_11.roughness;
    float _S631 = _S630 * _S630;
    AnisotropicFrame _S632 = anisotropicFrame(material_11, _S628);
    SheenProfile _S633 = sheenProfile(_S625, _S628, material_11);
    float _S634 = rgb_to_greyscale(material_11.translucent);
    bool _S635 = _S634 > 0.0f;
    bool _S636 = (dot_0(n_6, out_dir_2) * _S626) < 0.0f;
    bool _S637 = (F32_abs((material_11.toon.x))) > 0.0f;
    uint _S638;
    if(_S637)
    {
        _S638 = 5U;
    }
    else
    {
        _S638 = 4U;
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
        float3  _S639 = make_float3 (0.0f);
        (*throughputs_0)[i_7] = _S639;
        (*pdfs_0)[i_7] = 0.0f;
        uint i_8 = i_7 + 1U;
        i_7 = i_8;
    }
    float3  _S640 = make_float3 (0.0f);
    Weights _S641 = Weights_x24init_0(0.0f, _S640, _S640, 0.0f, _S640, _S640, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, _S640, _S640);
    uint half_of_0 = 4294967295U;
    Weights w_12 = _S641;
    float3  ggx_n_2 = _S640;
    i_7 = 0U;
    for(;;)
    {
        if(i_7 < _S638)
        {
        }
        else
        {
            break;
        }
        uint _S642;
        if(i_7 == 3U)
        {
            _S642 = 4U;
        }
        else
        {
            if(i_7 == 4U)
            {
                _S642 = 6U;
            }
            else
            {
                _S642 = i_7;
            }
        }
        bool _S643 = _S642 == 0U;
        bool _S644;
        if(_S643)
        {
            _S644 = _S635;
        }
        else
        {
            _S644 = false;
        }
        bool _S645;
        if(_S644)
        {
            _S645 = _S636;
        }
        else
        {
            _S645 = _S642 == 1U;
        }
        bool _S646 = _S645 != refracted_2;
        if(_S646)
        {
            ggx_n_1 = ggx_n_2;
            uint i_9 = i_7 + 1U;
            ggx_n_2 = ggx_n_1;
            i_7 = i_9;
            continue;
        }
        uint _S647;
        if(_S642 == 6U)
        {
            _S647 = 0U;
        }
        else
        {
            if(_S642 == 4U)
            {
                _S647 = 2U;
            }
            else
            {
                _S647 = _S642;
            }
        }
        bool _S648 = _S647 != half_of_0;
        uint half_of_1;
        Weights w_13;
        if(_S648)
        {
            bool _S649 = _S647 == 0U;
            if(_S649)
            {
                float3  _S650 = sampledHalf(_S625, _S628, _S631, _S632, random_state_4);
                ggx_n_1 = _S650;
            }
            else
            {
                bool _S651 = _S647 == 1U;
                if(_S651)
                {
                    float3  _S652 = refractedHalf(in_dir_3, out_dir_2, n_6, eta_i_4, eta_o_4);
                    ggx_n_1 = _S652;
                }
                else
                {
                    float3  _S653 = reflectedHalf(in_dir_3, out_dir_2);
                    ggx_n_1 = _S653;
                }
            }
            Weights _S654 = lobeWeights(in_dir_3, _S625, _S628, ggx_n_1, _S632, _S633, material_11, eta_i_4, eta_o_4);
            w_13 = _S654;
            half_of_1 = _S647;
        }
        else
        {
            w_13 = w_12;
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S642)
        {
        case 0U:
            {
                float _S655 = diffusePDF(_S629, (F32_abs((_S626))), material_11, w_13);
                (*pdfs_0)[int(0)] = _S655;
                float3  _S656 = diffuseBSDF(out_dir_2, _S628, material_11, w_13);
                (*throughputs_0)[int(0)] = _S656;
                break;
            }
        case 1U:
            {
                float _S657 = dot_0(out_dir_2, ggx_n_1);
                float _S658 = vndfPDF(_S625, ggx_n_1, _S628, (F32_abs((_S626))), _S631, _S632, w_13.v_dot_h);
                float _S659 = refractPDF(_S657, _S658, w_13, eta_i_4, eta_o_4);
                (*pdfs_0)[int(1)] = _S659;
                float3  _S660 = refractBSDF(out_dir_2, _S628, _S631, _S632, material_11, w_13);
                (*throughputs_0)[int(1)] = _S660;
                break;
            }
        case 4U:
            {
                float _S661 = sheenVelvetPDF(_S629, (F32_abs((_S626))), w_13);
                (*pdfs_0)[int(3)] = _S661;
                float3  _S662 = sheenVelvetBSDF(out_dir_2, _S625, _S628, material_11, w_13);
                (*throughputs_0)[int(3)] = _S662;
                break;
            }
        case 6U:
            {
                ToonProfile _S663 = toonProfile(_S625, _S628, material_11);
                float _S664 = toonPDF(out_dir_2, _S628, _S663, w_13);
                (*pdfs_0)[int(4)] = _S664;
                float3  _S665 = toonBSDF(out_dir_2, _S628, _S663, w_13);
                (*throughputs_0)[int(4)] = _S665;
                break;
            }
        default:
            {
                float _S666 = vndfPDF(_S625, ggx_n_1, _S628, (F32_abs((_S626))), _S631, _S632, w_13.v_dot_h);
                float _S667 = reflectPDF(_S666, w_13);
                (*pdfs_0)[int(2)] = _S667;
                float3  _S668 = reflectBSDF(out_dir_2, _S628, _S631, _S632, w_13);
                (*throughputs_0)[int(2)] = _S668;
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
    ggx_n_1 = _S640;
    for(;;)
    {
        if(i_7 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S669 = ((*pdfs_0)[i_7]) > 0.0f;
        if(_S669)
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
    bool _S670 = wrongSide_0(is_inside_2, false, dir_3, surface_1->geometry_n);
    float3  _S671 = BSDF(in_dir_4, dir_3, surface_1->smooth_n, *material_12, eta_1.x, eta_1.y, _S670, random_state_5, terms_0, pdfs_1);
    float3  _S672 = make_float3 (0.0f);
    uint i_11 = 0U;
    float3  f_3 = _S672;
    for(;;)
    {
        if(i_11 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S673 = ((*pdfs_1)[i_11]) > 0.0f;
        if(_S673)
        {
            float3  _S674 = (*terms_0)[i_11] * make_float3 ((*pdfs_1)[i_11]) / make_float3 ((*pdfs_1)[i_11] + pdf_0);
            (*terms_0)[i_11] = _S674;
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
    FKSurface _S675 = surface_2;
    BSDFMaterial _S676 = material_13;
    FixedArray<float3 , 5>  terms_1;
    FixedArray<float, 5>  pdfs_2;
    float3  _S677 = skyLobes_0(in_dir_5, dir_4, &_S675, &_S676, eta_2, is_inside_3, pdf_1, random_state_6, &terms_1, &pdfs_2);
    return _S677;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_5, float3  radiance_0, float3  color_0, uint random_state_7)
{
    SkySample _S678;
    (&_S678)->dir = dir_5;
    (&_S678)->radiance = radiance_0;
    (&_S678)->color = color_0;
    (&_S678)->random_state = random_state_7;
    return _S678;
}

static __device__ __noinline__ float3  skyColor_0(float3  in_dir_6, float3  dir_6, FKSurface * surface_3, float wavelength_3, float2  eta_3, bool is_inside_4, float pdf_2, uint random_state_8, uint depth_0)
{
    BSDFMaterial _S679 = pathMaterial(surface_3->material, wavelength_3);
    BSDFMaterial _S680 = _S679;
    FixedArray<float3 , 5>  terms_2;
    FixedArray<float, 5>  pdfs_3;
    float3  _S681 = skyLobes_0(in_dir_6, dir_6, surface_3, &_S680, eta_3, is_inside_4, pdf_2, random_state_8, &terms_2, &pdfs_3);
    float3  _S682 = make_float3 (0.0f);
    bool shaded_0 = false;
    float3  world_0 = _S682;
    uint i_13 = 0U;
    float3  color_1 = _S682;
    for(;;)
    {
        if(i_13 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S683 = (pdfs_3[i_13]) > 0.0f;
        if(_S683)
        {
            bool _S684 = (fcptWorldReadsPath());
            bool _S685;
            if(_S684)
            {
                _S685 = true;
            }
            else
            {
                _S685 = !shaded_0;
            }
            bool shaded_1;
            float3  world_1;
            if(_S685)
            {
                uint _S686;
                if(i_13 == 3U)
                {
                    _S686 = 4U;
                }
                else
                {
                    if(i_13 == 4U)
                    {
                        _S686 = 6U;
                    }
                    else
                    {
                        _S686 = i_13;
                    }
                }
                float3  _S687 = (fcptEnvMapSample((dir_6), (depth_0), (_S686)));
                world_1 = _S687;
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
    uint2  _S688 = (fcptEnvironmentCdfSize());
    uint2  _S689 = make_uint2 (1U, 0U);
    uint2  _S690 = _S688 - _S689;
    Random _S691 = pcg(init_random_state_0);
    Random _S692 = pcg(_S691.state);
    Random _S693 = pcg(_S692.state);
    Random _S694 = pcg(_S693.state);
    uint _S695 = _S690.x;
    uint _S696 = searchCDF_0(make_uint2 (_S695, 0U), make_uint2 (0U, 1U), _S690.y, _S691.value);
    uint _S697 = searchCDF_0(make_uint2 (0U, _S696), _S689, _S695, _S692.value);
    float2  _S698 = make_float2 ((float)_S690.x, (float)_S690.y);
    float2  _S699 = (make_float2 (float(_S697), float(_S696)) + make_float2 (_S693.value, _S694.value)) / _S698 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S700 = _S699.y;
    float _S701 = (F32_sin((_S700)));
    float _S702 = _S699.x;
    float3  _S703 = make_float3 (- _S701 * (F32_cos((_S702))), _S701 * (F32_sin((_S702))), (F32_cos((_S700))));
    float _S704 = environmentPdf_0(_S703);
    BSDFMaterial _S705 = pathMaterial(surface_4->material, wavelength_4);
    float3  _S706 = ray_0->unit_direction;
    float3  _S707 = skyBSDF(ray_0->unit_direction, _S703, *surface_4, _S705, eta_4, is_inside_5, _S704, lobe_state_0);
    bool _S708 = !(_S704 > 0.0f);
    bool _S709;
    if(_S708)
    {
        _S709 = true;
    }
    else
    {
        _S709 = all_1(_S707 == make_float3 (0.0f));
    }
    if(_S709)
    {
        float3  _S710 = make_float3 (0.0f);
        return SkySample_x24init_0(_S703, _S710, _S710, _S694.state);
    }
    bool _S711 = (fcptWorldReadsPath());
    float3  seen_0;
    if(_S711)
    {
        float3  _S712 = skyColor_0(_S706, _S703, surface_4, wavelength_4, eta_4, is_inside_5, _S704, lobe_state_0, context_2->depth + 1U);
        seen_0 = _S712;
    }
    else
    {
        seen_0 = _S707;
    }
    float3  _S713 = skyRadiance_0(ray_0->origin, surface_4, is_inside_5, _S703, context_2, _S694.state);
    return SkySample_x24init_0(_S703, _S713, seen_0 * _S713, _S694.state);
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
    SampleBSDF _S714 = (fcptConnectHair((surface_5->hair), ((&surface_5->material)->albedo), ((&surface_5->material)->specular_tint), (in_dir_7), (light_1->dir)));
    float3  _S715 = _S714.throughput * make_float3 (_S714.pdf);
    float _S716 = light_1->density;
    float _S717 = 1.0f + _S714.pdf * _S714.pdf / (light_1->density * light_1->density);
    bool _S718;
    if(competing_0)
    {
        _S718 = _S716 > 0.0f;
    }
    else
    {
        _S718 = false;
    }
    float _S719 = _slang_select(_S718, _S717,1.0f);
    return _S715 / make_float3 (_S719) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_7, float3  radiance_1, float density_0, uint random_state_9)
{
    TreeSample _S720;
    (&_S720)->dir = dir_7;
    (&_S720)->radiance = radiance_1;
    (&_S720)->density = density_0;
    (&_S720)->random_state = random_state_9;
    return _S720;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_12, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S721 = importance(first_1, p_12, normal_3);
    float _S722 = importance(second_1, p_12, normal_3);
    float2  _S723 = make_float2 (_S721, _S722);
    bool _S724 = _S721 == 0.0f;
    bool _S725;
    if(_S724)
    {
        _S725 = _S722 == 0.0f;
    }
    else
    {
        _S725 = false;
    }
    if(_S725)
    {
        return 2U;
    }
    float _S726 = _S721 + _S722;
    bool _S727 = _S722 > 0.0f;
    if(_S727)
    {
        _S725 = (*pick_0 * _S726) >= _S721;
    }
    else
    {
        _S725 = false;
    }
    uint _S728 = uint(_S725);
    float _S729 = (F32_min(((*pick_0 * _S726 - float(_S728) * _S721) / _slang_vector_get_element(_S723, _S728)), (0.99999994039535522f)));
    *pick_0 = _S729;
    float _S730 = *probability_3 * (_slang_vector_get_element(_S723, _S728) / _S726);
    *probability_3 = _S730;
    return _S728;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_13, float u1_0, float u2_0)
{
    float3  _S731 = center_1 - p_13;
    float _S732 = radius_1 * radius_1 / dot_0(_S731, _S731);
    float _S733 = u1_0 * _S732 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S732), (0.0f)))))));
    float _S734 = 2.0f * u1_0;
    bool _S735 = _S732 >= 1.0f;
    float _S736 = _slang_select(_S735, _S734,_S733);
    float _S737 = (F32_sqrt(((F32_max((_S736 * (2.0f - _S736)), (0.0f))))));
    float _S738 = 6.28318548202514648f * u2_0;
    float3  _S739 = make_float3 (_S737 * (F32_cos((_S738))), 1.0f - _S736, _S737 * (F32_sin((_S738))));
    float3  _S740 = ((((_S731)) * make_float3(rnorm3df(((_S731)).x, ((_S731)).y, ((_S731)).z))));
    float3  _S741 = tangentToWorld(_S739, _S740);
    return _S741;
}

__device__ float3  pointLightRadiance(float3  color_3, float intensity_0, float radius_2)
{
    return color_3 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S742 = center_2 - ray_1->origin;
    float _S743 = dot_0(_S742, ray_1->unit_direction);
    float _S744 = dot_0(_S742, _S742) - _S743 * _S743;
    float _S745 = radius_3 * radius_3;
    bool _S746 = _S744 > _S745;
    if(_S746)
    {
        return 4.294967296e+09f;
    }
    float _S747 = (F32_sqrt((_S745 - _S744)));
    float _S748 = _S743 - _S747;
    float _S749 = _S743 + _S747;
    bool _S750 = _S748 > 0.0000152587890625f;
    bool _S751;
    if(_S750)
    {
        _S751 = _S748 < max_len_0;
    }
    else
    {
        _S751 = false;
    }
    if(_S751)
    {
        return _S748;
    }
    bool _S752 = _S749 > 0.0000152587890625f;
    if(_S752)
    {
        _S751 = _S749 < max_len_0;
    }
    else
    {
        _S751 = false;
    }
    if(_S751)
    {
        return _S749;
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
    Random _S753 = pcg(init_random_state_1);
    Random _S754 = pcg(_S753.state);
    Random _S755 = pcg(_S754.state);
    float3  _S756 = make_float3 (0.0f);
    TreeSample _S757 = TreeSample_x24init_0(_S756, _S756, 0.0f, _S755.state);
    TreeSample sample_0 = _S757;
    float3  _S758 = _slang_select(sided_0, _S756,smooth_n_2);
    float3  _S759 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S753.value;
    float probability_4 = 1.0f;
    uint n_7 = 0U;
    for(;;)
    {
        uint4  _S760 = (fcptLightNode((n_7)));
        if((_S760.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S761 = (fcptLightSecond((n_7)));
        uint _S762 = n_7 + 1U;
        LightNode _S763 = (fcptLightBounds((_S762)));
        LightNode _S764 = (fcptLightBounds((_S761)));
        uint _S765 = pickChild(_S763, _S764, origin_4, _S758, &pick_1, &probability_4);
        bool _S766 = _S765 > 1U;
        if(_S766)
        {
            return sample_0;
        }
        bool _S767 = _S765 == 1U;
        uint _S768 = _slang_select(_S767, _S761,_S762);
        n_7 = _S768;
    }
    bool _S769 = n_7 == 0U;
    bool _S770;
    if(_S769)
    {
        LightNode _S771 = (fcptLightBounds((0U)));
        float _S772 = importance(_S771, origin_4, _S758);
        _S770 = !(_S772 > 0.0f);
    }
    else
    {
        _S770 = false;
    }
    if(_S770)
    {
        return sample_0;
    }
    uint4  _S773 = (fcptLightNode((n_7)));
    FKHit _S774 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S775 = (_S773.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S775)
    {
        FKLight _S776 = (fcptLight((_S773.y)));
        if(sided_0)
        {
            float _S777 = sign_0(dot_0(geometry_n_1, _S776.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S777);
            float3  _S778 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S778;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S759;
            lift_n_0 = smooth_n_2;
        }
        bool _S779 = (_S776.variance) == 0.0f;
        if(_S779)
        {
            float3  _S780 = _S776.position - emitter_point_0;
            float3  _S781 = ((((_S780)) * make_float3(rnorm3df(((_S780)).x, ((_S780)).y, ((_S780)).z))));
            (&sample_0)->dir = _S781;
            float3  _S782 = _S776.color * make_float3 (_S776.intensity) / make_float3 (dot_0(_S780, _S780) * probability_4);
            (&sample_0)->radiance = _S782;
            shadow_1 = _S780;
        }
        else
        {
            float3  _S783 = sampleSphere(_S776.position, _S776.variance, emitter_point_0, _S754.value, _S755.value);
            (&sample_0)->dir = _S783;
            float _S784 = sphereDensity(_S776.position, _S776.variance, emitter_point_0);
            float _S785 = probability_4 * _S784;
            (&sample_0)->density = _S785;
            float3  _S786 = pointLightRadiance(_S776.color, _S776.intensity, _S776.variance);
            float3  _S787 = _S786 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S787;
            FKRay _S788 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S789 = raySphere_0(_S776.position, _S776.variance, &_S788, 4.294967296e+09f);
            float3  _S790 = (&sample_0)->dir * make_float3 (_S789);
            shadow_1 = _S790;
        }
        emitter_0 = _S774;
        emitter_point_0 = _S756;
    }
    else
    {
        uint _S791 = _S773.y;
        uint _S792 = (fcptTriangleOffset((_S791)));
        uint _S793 = _S792 + _S773.z;
        Matrix<float, 3, 3>  _S794 = (fcptWorldTriangle((_S791), (_S793)));
        float _S795 = (F32_sqrt((_S754.value)));
        float2  _S796 = make_float2 (_S795 * (1.0f - _S755.value), _S795 * _S755.value);
        float3  _S797 = mul_0(make_float3 (1.0f - _S795, _S796.x, _S796.y), _S794);
        if(sided_0)
        {
            float _S798 = sign_0(dot_0(geometry_n_1, _S797 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S798);
            float3  _S799 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S799;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S800 = !((dot_0(smooth_n_2, _S797 - origin_4)) > 0.0f);
            if(_S800)
            {
                return sample_0;
            }
            emitter_point_0 = _S759;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S796, _S791, _S793, 0U, 0.0f);
        float3  _S801 = _S797 - emitter_point_0;
        float3  _S802 = ((((_S801)) * make_float3(rnorm3df(((_S801)).x, ((_S801)).y, ((_S801)).z))));
        (&sample_0)->dir = _S802;
        float _S803 = solidAngle(probability_4, cross_0(_S794.rows[int(1)] - _S794.rows[int(0)], _S794.rows[int(2)] - _S794.rows[int(0)]), _S801);
        (&sample_0)->density = _S803;
        bool _S804 = (fcptShadowFirst());
        bool _S805 = !_S804;
        if(_S805)
        {
            FKSurface _S806 = (fcptLightSurfaceAt((emitter_1), (_S797), (_S755.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S797 - origin_4))));
            (&sample_0)->random_state = _S806.random_state;
            float3  _S807 = _slang_select(_S806.skip, _S756,_S806.material.emissive);
            float3  _S808 = _S807 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S808;
        }
        shadow_1 = _S801;
        emitter_0 = emitter_1;
        emitter_point_0 = _S797;
    }
    FKHit _S809 = emitter_0;
    float3  _S810 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S755.state, &_S809);
    bool _S811 = (fcptShadowFirst());
    if(_S811)
    {
        _S770 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S770 = false;
    }
    if(_S770)
    {
        _S770 = !all_1(_S810 == _S756);
    }
    else
    {
        _S770 = false;
    }
    if(_S770)
    {
        FKSurface _S812 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S755.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S812.random_state;
        float3  _S813 = _slang_select(_S812.skip, _S756,_S812.material.emissive);
        float3  _S814 = _S813 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S814;
    }
    float3  _S815 = (&sample_0)->radiance * _S810;
    bool _S816 = all_1(_S810 == _S756);
    float3  _S817 = _slang_select(_S816, _S756,_S815);
    (&sample_0)->radiance = _S817;
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
    float _S818 = 1.0f / (1.0f + b_2 / a_8 * (b_2 / a_8));
    bool _S819 = b_2 > 0.0f;
    float _S820 = _slang_select(_S819, _S818,1.0f);
    return _S820;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S821 = vertex_0->none;
    if(_S821)
    {
        return 1.0f;
    }
    uint _S822 = (fcptLightSlot((*hit_1)));
    float _S823 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S822, light_point_1);
    float _S824 = powerHeuristic(vertex_0->pdf, _S823);
    return _S824;
}

static __device__ float3  environment_0(float3  dir_8, uint depth_1, uint lobe_0)
{
    uint2  _S825 = (fcptEnvironmentMapSize());
    bool _S826 = (_S825.x) > 1U;
    bool _S827;
    if(_S826)
    {
        uint2  _S828 = (fcptEnvironmentMapSize());
        _S827 = (_S828.y) > 1U;
    }
    else
    {
        _S827 = false;
    }
    if(_S827)
    {
        float3  _S829 = (fcptEnvMapSample((dir_8), (depth_1), (lobe_0)));
        return _S829;
    }
    float3  _S830 = (fcptAmbient());
    return _S830;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S831 = (fcptEnvironmentCdfSize());
    bool _S832 = (_S831.x) > 1U;
    bool _S833;
    if(_S832)
    {
        uint2  _S834 = (fcptEnvironmentCdfSize());
        _S833 = (_S834.y) > 1U;
    }
    else
    {
        _S833 = false;
    }
    bool _S835 = !_S833;
    if(_S835)
    {
        return false;
    }
    uint2  _S836 = (fcptEnvironmentMapSize());
    bool _S837 = (_S836.x) > 1U;
    if(_S837)
    {
        uint2  _S838 = (fcptEnvironmentMapSize());
        _S833 = (_S838.y) > 1U;
    }
    else
    {
        _S833 = false;
    }
    return _S833;
}

static __device__ float escapeWeight_0(float pdf_3, float3  dir_9)
{
    bool _S839 = pdf_3 <= 0.0f;
    bool _S840;
    if(_S839)
    {
        _S840 = true;
    }
    else
    {
        bool _S841 = environmentMapped_0();
        _S840 = !_S841;
    }
    if(_S840)
    {
        return 1.0f;
    }
    float _S842 = environmentPdf_0(dir_9);
    return pdf_3 / (pdf_3 + _S842);
}

static __device__ void restir_duplicates_0(uint3  global_invocation_id_1, uint3  local_invocation_id_0, uint local_invocation_index_3)
{
    uint2  _S843 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S844 = make_int2 ((int)_S843.x, (int)_S843.y);
    uint _S845 = previousSeed_0(_S844);
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
            uint _S846 = previousSeed_0(_S844 + make_int2 (x_16, y_5));
            bool _S847 = _S846 == _S845;
            uint _S848 = _slang_select(_S847, 1U,0U);
            uint count_3 = count_2 + _S848;
            int x_17 = x_16 + int(1);
            x_16 = x_17;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S849 = float(count_2 - 1U) / 288.0f;
    bool _S850 = _S845 != 0U;
    float _S851 = _slang_select(_S850, _S849,0.0f);
    fcptStoreDuplication((_S844), (make_uint4 ((F32_asuint((_S851))), 0U, 0U, 0U)));
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
    float _S852 = rgb_to_greyscale(abs_0(f_5));
    return _S852;
}

__device__ uint stream(uint seed_3, uint index_0)
{
    uint _S853 = hash(index_0);
    uint _S854 = hash(seed_3 ^ _S853);
    return _S854;
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

__device__ void offer(Selection * sel_2, Reservoir candidate_0, float3  weight_0)
{
    float _S855 = resamplingTarget(weight_0);
    bool _S856 = _S855 > 0.0f;
    bool _S857;
    if(_S856)
    {
        _S857 = _S855 < 3.00000000549775576e+38f;
    }
    else
    {
        _S857 = false;
    }
    bool _S858 = !_S857;
    if(_S858)
    {
        return;
    }
    bool _S859 = sel_2->sums;
    if(_S859)
    {
        float3  _S860 = sel_2->color + weight_0;
        sel_2->color = _S860;
        return;
    }
    float _S861 = sel_2->w_sum + _S855;
    sel_2->w_sum = _S861;
    float3  _S862 = sel_2->color + weight_0;
    sel_2->color = _S862;
    Random _S863 = pcg(sel_2->random_state);
    sel_2->random_state = _S863.state;
    bool _S864 = (_S863.value * sel_2->w_sum) <= _S855;
    if(_S864)
    {
        sel_2->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_3;
    float3  _S865 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S865;
    float _S866 = r_3.jac * shifted_0.jac;
    (&candidate_1)->jac = _S866;
    offer(sel_3, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S867 = resamplingTarget((&r_4)->f);
    float _S868 = sel_4.w_sum / _S867;
    bool _S869 = _S867 > 0.0f;
    float _S870 = _slang_select(_S869, _S868,0.0f);
    (&r_4)->w = _S870;
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
    uint2  _S871 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S872 = make_int2 ((int)_S871.x, (int)_S871.y);
    float3  _S873 = make_float3 (0.0f);
    FKHit _S874 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S875 = Domain_x24init_0(_S873, _S873, &_S874, 0.0f, 0.0f);
    Domain dom_4 = _S875;
    bool _S876 = (fcptCurrentDomain((_S872), (&dom_4)));
    bool _S877 = !_S876;
    if(_S877)
    {
        Reservoir _S878 = (Reservoir{});
        fcptStoreReservoirPrevious((_S872), (_S878), ((&dom_4)->hit));
        return;
    }
    Reservoir _S879 = (fcptLoadReservoirTemporal((_S872)));
    uint t_15 = 0U;
    float count_4 = 0.0f;
    float c_sum_0 = _S879.c;
    for(;;)
    {
        uint _S880 = (fcptRestirNeighbours());
        if(t_15 < _S880)
        {
        }
        else
        {
            break;
        }
        int2  _S881 = partner_0(_S872, t_15);
        Domain neighbor_0 = _S875;
        bool _S882 = (fcptCurrentDomain((_S881), (&neighbor_0)));
        if(_S882)
        {
            float count_5 = count_4 + 1.0f;
            uint4  _S883 = (fcptReservoirTemporal((_S881), (0U)));
            float c_sum_1 = c_sum_0 + (U32_asfloat((_S883.w)));
            count_4 = count_5;
            c_sum_0 = c_sum_1;
        }
        uint t_16 = t_15 + 1U;
        t_15 = t_16;
    }
    float _S884 = _S879.c / (F32_max((count_4), (1.0f)));
    float _S885 = resamplingTarget(_S879.f);
    bool _S886 = count_4 == 0.0f;
    float _S887 = _slang_select(_S886, 1.0f,0.0f);
    Selection _S888 = (Selection{});
    Selection sel_5 = _S888;
    uint _S889 = (fcptFrame());
    uint _S890 = hash(_S889);
    uint _S891 = global_invocation_id_2.x;
    uint2  _S892 = (fcptRenderSize());
    uint _S893 = stream(_S890, _S891 + _S892.x * global_invocation_id_2.y);
    uint _S894 = stream(_S893, 195U);
    (&sel_5)->random_state = _S894;
    t_15 = 0U;
    float canonical_mis_0 = _S887;
    for(;;)
    {
        uint _S895 = (fcptRestirNeighbours());
        if(t_15 < _S895)
        {
        }
        else
        {
            break;
        }
        int2  _S896 = partner_0(_S872, t_15);
        Domain neighbor_dom_0 = _S875;
        bool _S897 = (fcptCurrentDomain((_S896), (&neighbor_dom_0)));
        if(_S897)
        {
            Reservoir _S898 = (fcptLoadReservoirTemporal((_S896)));
            uint4  _S899 = (fcptShiftData((_S896), (t_15)));
            float4  _S900 = asfloat_0(_S899);
            uint4  _S901 = (fcptShiftData((_S872), (t_15)));
            float4  _S902 = asfloat_0(_S901);
            float _S903 = (_S898.c + _S884) / c_sum_0;
            bool _S904 = _S885 > 0.0f;
            float canonical_mis_1;
            if(_S904)
            {
                float _S905 = _S903 * _S884 * _S885;
                float _S906 = _S884 * _S885;
                float _S907 = resamplingTarget(float3 {_S902.x, _S902.y, _S902.z});
                float canonical_mis_2 = canonical_mis_0 + _S905 / (_S906 + _S898.c * _S907);
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float _S908 = resamplingTarget(_S898.f);
            float3  _S909 = float3 {_S900.x, _S900.y, _S900.z};
            Shift _S910 = Shift_x24init_0(_S909, _S900.w);
            float _S911 = _S903 * _S898.c * _S908;
            float _S912 = _S898.c * _S908;
            float _S913 = resamplingTarget(_S909);
            offerShifted(&sel_5, _S898, _S910, _S911 / (_S912 + _S884 * _S913));
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_17 = t_15 + 1U;
        t_15 = t_17;
    }
    offerShifted(&sel_5, _S879, Shift_x24init_0(_S879.f, 1.0f), canonical_mis_0);
    Reservoir _S914 = finalize(sel_5, c_sum_0);
    fcptStoreReservoirPrevious((_S872), (_S914), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S872), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S872), (make_float4 ((&sel_5)->color.x, (&sel_5)->color.y, (&sel_5)->color.z, 0.0f)));
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
    uint _S915 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S916 = _S915 != 4294967295U;
    if(_S916)
    {
        uint2  _S917 = make_uint2 (_S915, _S915 >> 14U) & make_uint2 (16383U);
        int2  _S918 = make_int2 ((int)_S917.x, (int)_S917.y);
        ShiftJob _S919 = (ShiftJob{});
        ShiftJob shift_job_0 = _S919;
        Shift _S920 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S921 = _S915 >> 28U;
        bool _S922 = spatialJob_0(_S918, _S921, &shift_job_0, true);
        Shift shifted_1;
        if(_S922)
        {
            Domain _S923 = (&shift_job_0)->dom;
            Reservoir _S924 = (&shift_job_0)->r;
            Shift _S925 = passShift_0(&_S923, &_S924);
            shifted_1 = _S925;
        }
        else
        {
            shifted_1 = _S920;
        }
        fcptStoreShiftData((_S918), (_S921), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S926 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S927 = make_int2 ((int)_S926.x, (int)_S926.y);
    FixedArray<uint, 3>  _S928;
    spatialBins_0(_S927, &_S928);
    FixedArray<uint, 3>  _S929 = _S928;
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
        bool _S930 = (_S929[t_18]) == 40U;
        if(_S930)
        {
            fcptStoreShiftData((_S927), (t_18), (make_uint4 (0U)));
        }
        uint t_19 = t_18 + 1U;
        t_18 = t_19;
    }
    FixedArray<uint, 3>  _S931 = _S929;
    queueShifts_0(_S927, &_S931, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S932 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S933 = make_int2 ((int)_S932.x, (int)_S932.y);
    FixedArray<uint, 3>  _S934;
    spatialBins_0(_S933, &_S934);
    FixedArray<uint, 3>  _S935 = _S934;
    countShifts_0(&_S935, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S936 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S937 = _S936 != 4294967295U;
    if(_S937)
    {
        uint2  _S938 = make_uint2 (_S936, _S936 >> 14U) & make_uint2 (16383U);
        int2  _S939 = make_int2 ((int)_S938.x, (int)_S938.y);
        int2  _S940 = (fcptLoadTemporalNeighbor((_S939)));
        uint _S941 = _S936 >> 28U;
        Shift _S942 = temporalShiftAt_0(_S939, _S940, _S941);
        fcptStoreTemporalShift((_S939), (_S941), (make_uint4 (asuint_1(_S942.f).x, asuint_1(_S942.f).y, asuint_1(_S942.f).z, (F32_asuint((_S942.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S943 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S944 = make_int2 ((int)_S943.x, (int)_S943.y);
    FixedArray<uint, 3>  _S945;
    temporalBins_0(_S944, &_S945);
    FixedArray<uint, 3>  _S946 = _S945;
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
        bool _S947 = (_S946[t_20]) == 40U;
        if(_S947)
        {
            fcptStoreTemporalShift((_S944), (t_20), (make_uint4 (0U)));
        }
        uint t_21 = t_20 + 1U;
        t_20 = t_21;
    }
    FixedArray<uint, 3>  _S948 = _S946;
    queueShifts_0(_S944, &_S948, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S949 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S950 = make_int2 ((int)_S949.x, (int)_S949.y);
    bool _S951 = (fcptSceneUnchanged());
    bool _S952 = !_S951;
    bool _S953;
    if(_S952)
    {
        uint2  _S954 = (fcptRenderSize());
        int2  _S955 = make_int2 ((int)_S954.x, (int)_S954.y);
        _S953 = all_0(_S950 < _S955);
    }
    else
    {
        _S953 = false;
    }
    if(_S953)
    {
        Reservoir _S956 = (fcptLoadReservoirInitial((_S950)));
        int2  _S957 = sampleNeighbor_0(_S950, _S956.seed);
        fcptStoreTemporalNeighbor((_S950), (_S957));
    }
    FixedArray<uint, 3>  _S958;
    temporalBins_0(_S950, &_S958);
    FixedArray<uint, 3>  _S959 = _S958;
    countShifts_0(&_S959, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_9, float b_3, float t_22)
{
    return a_9 + (b_3 - a_9) * t_22;
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S960 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S961 = make_int2 ((int)_S960.x, (int)_S960.y);
    float3  _S962 = make_float3 (0.0f);
    FKHit _S963 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S964 = Domain_x24init_0(_S962, _S962, &_S963, 0.0f, 0.0f);
    Domain dom_5 = _S964;
    bool _S965 = (fcptCurrentDomain((_S961), (&dom_5)));
    bool _S966 = !_S965;
    if(_S966)
    {
        Reservoir _S967 = (Reservoir{});
        fcptStoreReservoirTemporal((_S961), (_S967), ((&dom_5)->hit));
        return;
    }
    Reservoir _S968 = (fcptLoadReservoirInitial((_S961)));
    bool _S969 = (fcptTemporalQueued());
    bool _S970 = (fcptSceneUnchanged());
    bool _S971;
    if(_S970)
    {
        _S971 = true;
    }
    else
    {
        _S971 = !_S969;
    }
    int2  _S972;
    if(_S971)
    {
        int2  _S973 = sampleNeighbor_0(_S961, _S968.seed);
        _S972 = _S973;
    }
    else
    {
        int2  _S974 = (fcptLoadTemporalNeighbor((_S961)));
        _S972 = _S974;
    }
    bool _S975 = (_S972.x) >= int(0);
    Reservoir r_5;
    if(_S975)
    {
        Reservoir _S976 = (fcptLoadReservoirPrevious((_S972)));
        uint4  _S977 = (fcptDuplication((_S972)));
        float _S978 = (U32_asfloat((_S977.x)));
        uint _S979 = (fcptRestirDecorrelation());
        bool _S980 = _S979 == 1U;
        float _S981 = _slang_select(_S980, _S978,0.0f);
        float _S982 = interpolate_0(20.0f, 1.0f, (F32_pow((_S981), (0.10000000149011612f))));
        float _S983 = (F32_min((_S976.c), (_S982)));
        bool _S984 = (fcptSceneUnchanged());
        float4  _S985 = make_float4 (_S976.f.x, _S976.f.y, _S976.f.z, 1.0f);
        bool _S986 = !_S984;
        if(_S986)
        {
            _S971 = _S969;
        }
        else
        {
            _S971 = false;
        }
        float4  to_current_0;
        if(_S971)
        {
            uint4  _S987 = (fcptTemporalShift((_S961), (0U)));
            float4  _S988 = asfloat_0(_S987);
            to_current_0 = _S988;
        }
        else
        {
            if(_S986)
            {
                Shift _S989 = temporalShiftAt_0(_S961, _S972, 0U);
                float4  _S990 = make_float4 (_S989.f.x, _S989.f.y, _S989.f.z, _S989.jac);
                to_current_0 = _S990;
            }
            else
            {
                to_current_0 = _S985;
            }
        }
        Domain own_1 = _S964;
        if(_S984)
        {
            _S971 = true;
        }
        else
        {
            bool _S991 = (fcptPreviousScenes());
            bool _S992 = !_S991;
            if(_S992)
            {
                _S971 = (_S968.w) > 0.0f;
            }
            else
            {
                _S971 = false;
            }
            if(_S971)
            {
                bool _S993 = (fcptStoredDomainInitial((_S961), (_S968.seed), (&own_1)));
                _S971 = _S993;
            }
            else
            {
                _S971 = false;
            }
            if(_S971)
            {
                Domain _S994 = (fcptPreviousDomain((_S972), (_S968.seed)));
                Domain _S995 = _S994;
                Domain _S996 = own_1;
                bool _S997 = sameDomain_0(&_S995, &_S996);
                _S971 = _S997;
            }
            else
            {
                _S971 = false;
            }
        }
        float4  _S998 = make_float4 (_S968.f.x, _S968.f.y, _S968.f.z, 1.0f);
        bool _S999 = !_S971;
        if(_S999)
        {
            _S971 = _S969;
        }
        else
        {
            _S971 = false;
        }
        float4  to_previous_0;
        if(_S971)
        {
            uint4  _S1000 = (fcptTemporalShift((_S961), (1U)));
            float4  _S1001 = asfloat_0(_S1000);
            to_previous_0 = _S1001;
        }
        else
        {
            if(_S999)
            {
                Shift _S1002 = temporalShiftAt_0(_S961, _S972, 1U);
                float4  _S1003 = make_float4 (_S1002.f.x, _S1002.f.y, _S1002.f.z, _S1002.jac);
                to_previous_0 = _S1003;
            }
            else
            {
                to_previous_0 = _S998;
            }
        }
        float _S1004 = resamplingTarget(_S968.f);
        float _S1005 = resamplingTarget(_S976.f);
        Selection _S1006 = (Selection{});
        Selection sel_6 = _S1006;
        uint _S1007 = (fcptFrame());
        uint _S1008 = hash(_S1007);
        uint _S1009 = global_invocation_id_7.x;
        uint2  _S1010 = (fcptRenderSize());
        uint _S1011 = stream(_S1008, _S1009 + _S1010.x * global_invocation_id_7.y);
        uint _S1012 = stream(_S1011, 194U);
        (&sel_6)->random_state = _S1012;
        float _S1013 = _S968.c * _S1004;
        float4  _S1014 = to_previous_0;
        float _S1015 = resamplingTarget(float3 {_S1014.x, _S1014.y, _S1014.z});
        float _S1016 = _S1013 / (_S1013 + _S983 * _S1015);
        float _S1017 = _S983 * _S1005;
        float4  _S1018 = to_current_0;
        float3  _S1019 = float3 {_S1018.x, _S1018.y, _S1018.z};
        float _S1020 = resamplingTarget(_S1019);
        float _S1021 = _S1017 / (_S1017 + _S968.c * _S1020);
        float2  _S1022 = make_float2 (_S1016, _S1021);
        offerShifted(&sel_6, _S968, Shift_x24init_0(_S968.f, 1.0f), _S1016);
        offerShifted(&sel_6, _S976, Shift_x24init_0(_S1019, to_current_0.w), _S1021);
        Reservoir _S1023 = finalize(sel_6, _S968.c + _S983);
        r_5 = _S1023;
    }
    else
    {
        r_5 = _S968;
    }
    fcptStoreReservoirTemporal((_S961), (r_5), ((&dom_5)->hit));
    return;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_6)
{
    uint _S1024 = (1U << count_6) - 1U;
    return (e_2 & (~(_S1024 << offset_1))) | ((newbits_0 & _S1024) << offset_1);
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S1025 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S1026 = make_int2 ((int)_S1025.x, (int)_S1025.y);
    float3  _S1027 = make_float3 (0.0f);
    float2  _S1028 = make_float2 (0.0f);
    FKHit _S1029 = Hit_x24init_0(_S1028, 0U, 0U, 0U, 0.0f);
    Domain _S1030 = Domain_x24init_0(_S1027, _S1027, &_S1029, 0.0f, 0.0f);
    Domain dom_6 = _S1030;
    bool _S1031 = (fcptCurrentDomain((_S1026), (&dom_6)));
    bool _S1032 = !_S1031;
    if(_S1032)
    {
        Reservoir _S1033 = (Reservoir{});
        fcptStoreReservoirInitial((_S1026), (_S1033), ((&dom_6)->hit));
        return;
    }
    uint _S1034 = (fcptFrame());
    uint _S1035 = hash(_S1034);
    uint _S1036 = global_invocation_id_8.x;
    uint2  _S1037 = (fcptRenderSize());
    uint _S1038 = global_invocation_id_8.y;
    uint _S1039 = stream(_S1035, _S1036 + _S1037.x * _S1038);
    uint2  _S1040 = (fcptRenderSize());
    uint _S1041 = stream(_S1036 + _S1040.x * _S1038, 512U);
    Selection _S1042 = (Selection{});
    Selection initial_0 = _S1042;
    uint _S1043 = stream(_S1039, 193U);
    (&initial_0)->random_state = _S1043;
    bool _S1044 = (fcptRestirUsed());
    bool _S1045 = !_S1044;
    (&initial_0)->sums = _S1045;
    uint _S1046 = stream(_S1039, 0U);
    (&(&initial_0)->r)->seed = _S1046;
    FKHit _S1047 = Hit_x24init_0(_S1028, 4294967295U, 0U, 0U, 0.0f);
    uint _S1048 = (fcptSamples());
    float _S1049 = 1.0f / float(_S1048);
    FKHit hit_2 = _S1047;
    uint i_20 = 0U;
    float3  seen_1 = _S1027;
    for(;;)
    {
        uint _S1050 = (fcptSamples());
        if(i_20 < _S1050)
        {
        }
        else
        {
            break;
        }
        Reservoir _S1051 = (Reservoir{});
        Reservoir r_6 = _S1051;
        uint _S1052 = stream(_S1039, i_20);
        (&r_6)->seed = _S1052;
        uint _S1053 = (fcptFrame());
        uint _S1054 = (fcptSamples());
        uint _S1055 = _S1053 * _S1054 + i_20;
        uint _S1056 = insertBits_0(0U, 1U, 24U, 1U);
        uint _S1057 = insertBits_0(_S1056, (_S1041 + _S1055 * 2654435769U) >> 25U, 25U, 7U);
        (&r_6)->path = _S1057;
        Domain path_0 = _S1030;
        bool _S1058 = (fcptStoredDomainInitial((_S1026), ((&r_6)->seed), (&path_0)));
        bool _S1059 = !_S1058;
        if(_S1059)
        {
            float3  _S1060 = (fcptMissed((_S1026), (path_0), (_S1049)));
            float3  seen_2 = seen_1 + _S1060;
            seen_1 = seen_2;
            uint i_21 = i_20 + 1U;
            i_20 = i_21;
            continue;
        }
        Domain _S1061 = path_0;
        Reservoir _S1062 = r_6;
        Shift _S1063 = passWalk_0(&_S1061, &_S1062, false, _S1049, &initial_0);
        bool _S1064 = ((&(&initial_0)->r)->seed) == ((&r_6)->seed);
        FKHit hit_3;
        if(_S1064)
        {
            FKHit _S1065 = (&path_0)->hit;
            hit_3 = _S1065;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_21 = i_20 + 1U;
        i_20 = i_21;
    }
    uint _S1066 = (fcptSamples());
    float3  seen_3 = seen_1 + (&initial_0)->glow / make_float3 (float(_S1066));
    if((&initial_0)->sums)
    {
        seen_1 = seen_3 + (&initial_0)->color;
    }
    else
    {
        seen_1 = seen_3;
    }
    fcptAddColor((_S1026), (make_float4 (seen_1.x, seen_1.y, seen_1.z, 1.0f)));
    Reservoir _S1067 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S1026), (_S1067), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_4, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S1068;
    (&_S1068)->none = none_0;
    (&_S1068)->pdf = pdf_4;
    (&_S1068)->origin = origin_5;
    (&_S1068)->smooth_n = smooth_n_3;
    (&_S1068)->start = start_6;
    return _S1068;
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
    Vertex _S1069;
    (&_S1069)->rough = rough_0;
    (&_S1069)->lobe = lobe_1;
    (&_S1069)->pdf = pdf_5;
    (&_S1069)->cos = cos_0;
    (&_S1069)->inside = inside_0;
    return _S1069;
}

__device__ float3  pathColor(float3  f_6, float3  weight_1, float wavelength_5)
{
    float3  _S1070;
    if(wavelength_5 > 0.0f)
    {
        float _S1071 = upsample(f_6, wavelength_5);
        _S1070 = weight_1 * make_float3 (_S1071);
    }
    else
    {
        _S1070 = f_6;
    }
    return _S1070;
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

static __device__ float3  flightWeight_0(float3  scatter_0, float3  extinction_0, float sigma_0, float distance_2, bool scatters_0)
{
    float3  _S1072 = exp_0((make_float3 (sigma_0) - extinction_0) * make_float3 (distance_2));
    float3  _S1073 = scatter_0 * _S1072 / make_float3 (sigma_0);
    float3  _S1074 = _slang_select(scatters_0, _S1073,_S1072);
    return _S1074;
}

static __device__ uint arrivalLobe_0(uint b_4, uint prev_lobe_0)
{
    bool _S1075 = b_4 > 0U;
    uint _S1076 = _slang_select(_S1075, prev_lobe_0,3U);
    return _S1076;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_2, uint lobe_2, bool surface_6, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S1077;
    (&_S1077)->extinction_behind = extinction_behind_0;
    (&_S1077)->extinction_front = extinction_front_0;
    (&_S1077)->fillings = fillings_0;
    (&_S1077)->side = side_0;
    (&_S1077)->depth = depth_2;
    (&_S1077)->lobe = lobe_2;
    (&_S1077)->surface = surface_6;
    (&_S1077)->length = length_2;
    (&_S1077)->width = width_1;
    (&_S1077)->own = *own_2;
    (&_S1077)->fiber = fiber_0;
    return _S1077;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S1078 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S1078)
    {
        return 0.07957746833562851f;
    }
    float _S1079 = g_0 * g_0;
    return (1.0f - _S1079) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S1079 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_10, float3  b_5)
{
    float3  _S1080 = a_10 / b_5;
    float3  _S1081 = make_float3 (0.0f);
    bool3  _S1082 = b_5 == _S1081;
    float3  _S1083 = _slang_select(_S1082, _S1081,_S1080);
    return _S1083;
}

__device__ Reservoir withEnd(Reservoir r_7, uint end_type_0, uint end_0, float3  f_7)
{
    Reservoir candidate_2 = r_7;
    uint _S1084 = insertBits_0(r_7.path, end_0, 0U, 5U);
    uint _S1085 = insertBits_0(_S1084, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S1085;
    (&candidate_2)->f = f_7;
    return candidate_2;
}

__device__ float survivalProbability(float3  throughput_0, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_0.x), ((F32_max((throughput_0.y), (throughput_0.z)))))) / density_1), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_10)
{
    Random _S1086 = pcg(random_state_10);
    Random _S1087 = pcg(_S1086.state);
    float _S1088 = 1.0f - 2.0f * _S1086.value;
    float _S1089 = (F32_sqrt(((F32_max((1.0f - _S1088 * _S1088), (0.0f))))));
    float _S1090 = 6.28318548202514648f * _S1087.value;
    return make_float3 (_S1089 * (F32_cos((_S1090))), _S1089 * (F32_sin((_S1090))), _S1088);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_10, uint random_state_11, float * pdf_6)
{
    bool _S1091 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1091)
    {
        *pdf_6 = 0.07957746833562851f;
        float3  _S1092 = isotropic_0(random_state_11);
        return _S1092;
    }
    Random _S1093 = pcg(random_state_11);
    Random _S1094 = pcg(_S1093.state);
    float _S1095 = g_1 * g_1;
    float _S1096 = 2.0f * g_1;
    float _S1097 = (1.0f - _S1095) / (1.0f - g_1 + _S1096 * _S1093.value);
    float _S1098 = clamp_1((1.0f + _S1095 - _S1097 * _S1097) / _S1096, -1.0f, 1.0f);
    float _S1099 = (F32_sqrt(((F32_max((1.0f - _S1098 * _S1098), (0.0f))))));
    float _S1100 = 6.28318548202514648f * _S1094.value;
    float _S1101 = phaseHG_0(g_1, _S1098);
    *pdf_6 = _S1101;
    float3  _S1102 = tangentToWorld(make_float3 (_S1099 * (F32_cos((_S1100))), _S1098, _S1099 * (F32_sin((_S1100)))), dir_10);
    float3  _S1103 = ((((_S1102)) * make_float3(rnorm3df(((_S1102)).x, ((_S1102)).y, ((_S1102)).z))));
    return _S1103;
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_1, float3  emissive_0, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_1, float velvet_0, float3  toon_2, float dispersion_0)
{
    BSDFMaterial _S1104;
    (&_S1104)->albedo = albedo_1;
    (&_S1104)->emissive = emissive_0;
    (&_S1104)->roughness = roughness_0;
    (&_S1104)->metallic = metallic_0;
    (&_S1104)->transmission = transmission_0;
    (&_S1104)->ior = ior_0;
    (&_S1104)->absorption = absorption_0;
    (&_S1104)->specular_tint = specular_tint_0;
    (&_S1104)->specular_level = specular_level_0;
    (&_S1104)->translucent = translucent_0;
    (&_S1104)->sheen = sheen_2;
    (&_S1104)->sheen_roughness = sheen_roughness_0;
    (&_S1104)->anisotropy = anisotropy_0;
    (&_S1104)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1104)->tangent = tangent_1;
    (&_S1104)->velvet = velvet_0;
    (&_S1104)->toon = toon_2;
    (&_S1104)->dispersion = dispersion_0;
    return _S1104;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1105;
    (&_S1105)->scatter = scatter_1;
    (&_S1105)->extinction = extinction_1;
    (&_S1105)->g = g_2;
    return _S1105;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_14, bool skip_0, uint random_state_12, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1106;
    (&_S1106)->smooth_n = smooth_n_4;
    (&_S1106)->geometry_n = geometry_n_2;
    (&_S1106)->geometry_offset = geometry_offset_2;
    (&_S1106)->material = *material_14;
    (&_S1106)->skip = skip_0;
    (&_S1106)->random_state = random_state_12;
    (&_S1106)->coverage = coverage_0;
    (&_S1106)->encloses = encloses_0;
    (&_S1106)->volume = *volume_0;
    (&_S1106)->fills = fills_0;
    (&_S1106)->hair = hair_0;
    return _S1106;
}

static __device__ FKSurface emitting_0(FKSurface * surface_7, bool top_0)
{
    FKSurface lower_0 = *surface_7;
    float3  _S1107 = (&surface_7->material)->emissive;
    float3  _S1108 = make_float3 (0.0f);
    bool _S1109 = !top_0;
    float3  _S1110 = _slang_select(_S1109, _S1108,_S1107);
    (&(&lower_0)->material)->emissive = _S1110;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_8, float u_1)
{
    float _S1111 = surface_8->coverage;
    bool _S1112 = u_1 < _S1111;
    if(_S1112)
    {
        return *surface_8;
    }
    float3  _S1113 = make_float3 (0.0f);
    float3  _S1114 = make_float3 (1.0f);
    BSDFMaterial _S1115 = Material_x24init_0(_S1113, _S1113, 0.0f, 0.0f, 0.0f, 0.0f, _S1113, _S1114, 1.0f, _S1113, _S1113, 0.5f, 0.0f, 0.0f, _S1113, 0.0f, _S1113, 0.0f);
    BSDFMaterial material_15 = _S1115;
    (&material_15)->albedo = _S1114;
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
    bool _S1116 = transmission_1 > 0.0f;
    bool _S1117;
    if(_S1116)
    {
        _S1117 = true;
    }
    else
    {
        _S1117 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1118;
    if(_S1117)
    {
        _S1118 = 1.0f;
    }
    else
    {
        _S1118 = -1.0f;
    }
    return _S1118;
}

static __device__ bool arrivesBehind_0(float3  dir_11, float3  n_8)
{
    return (dot_0(dir_11, n_8)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_9, float3  dir_12)
{
    float3  _S1119 = surface_9->geometry_n;
    float _S1120 = facingSign((&surface_9->material)->transmission, surface_9->geometry_n, dir_12);
    FKSurface faced_0 = *surface_9;
    float3  _S1121 = surface_9->smooth_n * make_float3 (_S1120);
    (&faced_0)->smooth_n = _S1121;
    float3  _S1122 = _S1119 * make_float3 (_S1120);
    (&faced_0)->geometry_n = _S1122;
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
    float3  _S1123 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1123));
}

__device__ bool dispersive(BSDFMaterial material_16)
{
    bool _S1124 = (material_16.dispersion) > 0.0f;
    bool _S1125;
    if(_S1124)
    {
        _S1125 = (material_16.ior) != 1.0f;
    }
    else
    {
        _S1125 = false;
    }
    return _S1125;
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
        uint _S1126 = (low_1 + high_1 + 1U) / 2U;
        bool _S1127 = (WAVELENGTH_CDF_0[_S1126]) <= u_2;
        if(_S1127)
        {
            low_1 = _S1126;
        }
        else
        {
            uint _S1128 = _S1126 - 1U;
            high_1 = _S1128;
        }
    }
    uint _S1129 = low_1;
    float _S1130 = WAVELENGTH_CDF_0[low_1 + 1U] - WAVELENGTH_CDF_0[low_1];
    return make_float2 (0.37999999523162842f + 0.00499999988824129f * (float(low_1) + (u_2 - WAVELENGTH_CDF_0[_S1129]) / _S1130), _S1130 / 0.00499999988824129f);
}

__device__ static const FixedArray<float, 243>  WAVELENGTH_WEIGHTS_0 = { {
    0.00547470012679696f, -0.00465690018609166f, 0.03257500007748604f, 0.00934640038758516f, -0.00796370021998882f, 0.05577300116419792f, 0.01846100017428398f, -0.01579399965703487f, 0.11072999984025955f, 0.0416410006582737f, -0.03577499836683273f, 0.2513900101184845f, 0.09349299967288971f, -0.08071800321340561f, 0.56742000579833984f, 0.1585099995136261f, -0.13764999806880951f, 0.97018998861312866f, 0.30943000316619873f, -0.27083000540733337f, 1.91740000247955322f, 0.55217999219894409f, -0.48754000663757324f, 3.46889996528625488f, 0.95016998052597046f, -0.84802001714706421f, 6.09439992904663086f, 1.42110002040863037f, -1.28929996490478516f, 9.45199966430664062f, 1.73409998416900635f, -1.6062999963760376f, 12.12800025939941406f, 2.08030009269714355f, -1.98810005187988281f, 15.68700027465820312f, 2.20600008964538574f, -2.20120000839233398f, 18.47699928283691406f, 2.03040003776550293f, -2.17700004577636719f, 19.92700004577636719f, 1.63429999351501465f, -2.00340008735656738f, 20.86899948120117188f, 0.99410998821258545f, -1.62629997730255127f, 20.57799911499023438f, 0.20011000335216522f, -1.11409997940063477f, 19.72100067138671875f, -0.67960000038146973f, -0.45403000712394714f, 17.77599906921386719f, -1.61679995059967041f, 0.37860000133514404f, 14.71500015258789062f, -2.53410005569458008f, 1.27540004253387451f, 11.86499977111816406f, -3.39079999923706055f, 2.2146000862121582f, 9.17669963836669922f, -4.03749990463256836f, 3.0522000789642334f, 6.59509992599487305f, -4.61299991607666016f, 3.89779996871948242f, 4.64589977264404297f, -5.43039989471435547f, 5.0121002197265625f, 3.3199000358581543f, -6.37769985198974609f, 6.33809995651245117f, 2.29699993133544922f, -7.44140005111694336f, 7.91739988327026367f, 1.45389997959136963f, -8.38580036163330078f, 9.60109996795654297f, 0.66465997695922852f, -9.0167999267578125f, 11.23999977111816406f, -0.04403600096702576f, -9.17749977111816406f, 12.63199996948242188f, -0.58126997947692871f, -8.97550010681152344f, 13.91499996185302734f, -0.95730000734329224f, -8.25290012359619141f, 14.86200046539306641f, -1.24430000782012939f, -6.92129993438720703f, 15.03899955749511719f, -1.43069994449615479f, -5.29169988632202148f, 14.90900039672851562f, -1.55149996280670166f, -3.43219995498657227f, 14.70499992370605469f, -1.63569998741149902f, -1.27190005779266357f, 14.24400043487548828f, -1.67030000686645508f, 1.15170001983642578f, 13.32199954986572266f, -1.636199951171875f, 3.73889994621276855f, 12.21199989318847656f, -1.56920003890991211f, 6.43590021133422852f, 10.94699954986572266f, -1.47730004787445068f, 9.16440010070800781f, 9.54769992828369141f, -1.36399996280670166f, 12.02000045776367188f, 8.18799972534179688f, -1.25450003147125244f, 14.78699970245361328f, 6.74429988861083984f, -1.13110005855560303f, 16.72299957275390625f, 5.08780002593994141f, -0.96561002731323242f, 18.14299964904785156f, 3.57019996643066406f, -0.80725997686386108f, 19.91900062561035156f, 2.36269998550415039f, -0.69273000955581665f, 21.05500030517578125f, 1.31369996070861816f, -0.58597999811172485f, 21.3899993896484375f, 0.42390000820159912f, -0.48298001289367676f, 20.99300003051757812f, -0.23857000470161438f, -0.39412000775337219f, 19.82200050354003906f, -0.6866300106048584f, -0.31501999497413635f, 18.12000083923339844f, -0.9412500262260437f, -0.24890999495983124f, 15.7089996337890625f, -1.02020001411437988f, -0.19076000154018402f, 13.19799995422363281f, -0.98919999599456787f, -0.14401000738143921f, 11.23999977111816406f, -0.93347001075744629f, -0.11133000254631042f, 9.36649990081787109f, -0.83820998668670654f, -0.08524099737405777f, 7.41249990463256836f, -0.70064002275466919f, -0.06283199787139893f, 5.71229982376098633f, -0.56079000234603882f, -0.04586699977517128f, 4.42280006408691406f, -0.44653001427650452f, -0.03396600112318993f, 3.34489989280700684f, -0.34457001090049744f, -0.02482499927282333f, 2.49309992790222168f, -0.26017999649047852f, -0.01808100007474422f, 1.82239997386932373f, -0.1921599954366684f, -0.01296999957412481f, 1.29499995708465576f, -0.13766999542713165f, -0.00907570030540228f, 0.92928999662399292f, -0.09956400096416473f, -0.00641620019450784f, 0.61835998296737671f, -0.06671299785375595f, -0.00421149982139468f, 0.40211999416351318f, -0.04354599863290787f, -0.00271830009296536f, 0.2844499945640564f, -0.03087200038135052f, -0.00191440002527088f, 0.20672999322414398f, -0.02246100082993507f, -0.00138829997740686f, 0.15044000744819641f, -0.01634499989449978f, -0.00101030000951141f, 0.10942000150680542f, -0.01188699994236231f, -0.0007347899954766f, 0.07099699974060059f, -0.00771349994465709f, -0.00047679000999779f, 0.04539500176906586f, -0.00493190018460155f, -0.00030484999297187f, 0.03424099832773209f, -0.00372010003775358f, -0.00022995000472292f, 0.02557599917054176f, -0.00277870008721948f, -0.00017175999528263f, 0.01842200011014938f, -0.00200140010565519f, -0.0001237099932041f, 0.01316899992525578f, -0.00143079995177686f, -0.00008843900286593f, 0.00838890019804239f, -0.00091141002485529f, -0.00005633700129692f, 0.00537079991772771f, -0.00058350997278467f, -0.00003606799873523f, 0.00328280008397996f, -0.00035665999166667f, -0.00002204600059486f, 0.00196009990759194f, -0.00021296000340953f, -0.00001316300040344f, 0.00168939994182438f, -0.00018354000349063f, -0.00001134499962063f, 0.00141050003003329f, -0.00015325000276789f, -0.00000947250009631f, 0.00097123999148607f, -0.00010551999730524f, -6.52239987175562419e-06f, 0.00066868000430986f, -0.00007264900341397f, -4.49060007667867467e-06f
} };
__device__ float3  wavelengthWeights(float wavelength_6)
{
    float _S1131 = clamp_1((wavelength_6 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    uint _S1132 = (U32_min((uint(_S1131)), (79U)));
    uint _S1133 = 3U * _S1132;
    float3  _S1134 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1133], WAVELENGTH_WEIGHTS_0[_S1133 + 1U], WAVELENGTH_WEIGHTS_0[_S1133 + 2U]);
    float3  _S1135 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1133 + 3U], WAVELENGTH_WEIGHTS_0[_S1133 + 4U], WAVELENGTH_WEIGHTS_0[_S1133 + 5U]);
    return _S1134 + (_S1135 - _S1134) * make_float3 (_S1131 - float(_S1132));
}

__device__ float dispersedIor(float ior_1, float dispersion_1, float wavelength_7)
{
    float _S1136 = (ior_1 - 1.0f) * dispersion_1 / 1.90962409973144531f;
    float _S1137 = _S1136 * (1.0f / (wavelength_7 * wavelength_7) - 2.89662933349609375f);
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

__device__ float2  wavelengthEta(BSDFMaterial material_18, float n_dot_v_1, float wavelength_8)
{
    BSDFMaterial refractive_0 = material_18;
    float _S1143 = dispersedIor(material_18.ior, material_18.dispersion, wavelength_8);
    bool _S1144 = wavelength_8 > 0.0f;
    float _S1145 = _slang_select(_S1144, _S1143,material_18.ior);
    (&refractive_0)->ior = _S1145;
    float2  _S1146 = vertexEta(refractive_0, n_dot_v_1);
    return _S1146;
}

__device__ bool neeDecision(BSDFMaterial material_19, float n_dot_v_2, float eta_i_5, float eta_o_5)
{
    float _S1147 = fresnel((F32_abs((n_dot_v_2))), eta_i_5, eta_o_5);
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

static __device__ MediumSides mediumSides_0(FKSurface * surface_10, FKMedium * medium_0, uint filling_0, float3  dir_13, FKMedium * outside_0)
{
    float3  _S1155 = surface_10->geometry_n;
    MediumSides _S1156 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_10->geometry_n);
    MediumSides sides_0 = _S1156;
    bool _S1157 = surface_10->encloses;
    if(_S1157)
    {
        (&sides_0)->behind = surface_10->volume;
        *&((&(&sides_0)->fillings)->x) = surface_10->fills;
        bool _S1158 = (dot_0(dir_13, _S1155)) > 0.0f;
        if(_S1158)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_11, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_14, uint depth_3, uint lobe_3, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1159 = surface_11->geometry_n;
    ShadowContext _S1160 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_11->geometry_n, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
    bool _S1161 = surface_11->encloses;
    ShadowContext context_4;
    if(_S1161)
    {
        FKSurface faced_1 = *surface_11;
        float3  _S1162 = - _S1159;
        float3  _S1163 = _slang_select(turned_0, _S1162,_S1159);
        (&faced_1)->geometry_n = _S1163;
        FKMedium _S1164 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1165 = faced_1;
        FKMedium _S1166 = _S1164;
        MediumSides _S1167 = mediumSides_0(&_S1165, &_S1166, filling_1, dir_14, outside_1);
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

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_8, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_3, BSDFMaterial * material_21, float eta_i_6, float eta_o_6, bool competing_1, uint random_state_13)
{
    float3  _S1171 = light_2->dir;
    bool _S1172 = (dot_0(geometry_n_3, - in_dir_8) * dot_0(geometry_n_3, light_2->dir)) <= 0.0f;
    FixedArray<float3 , 5>  throughputs_1;
    FixedArray<float, 5>  pdfs_4;
    float3  _S1173 = BSDF(in_dir_8, _S1171, smooth_n_5, *material_21, eta_i_6, eta_o_6, _S1172, random_state_13, &throughputs_1, &pdfs_4);
    bool _S1174 = !competing_1;
    bool _S1175;
    if(_S1174)
    {
        _S1175 = true;
    }
    else
    {
        _S1175 = (light_2->density) == 0.0f;
    }
    if(_S1175)
    {
        return _S1173 * light_2->radiance;
    }
    float3  _S1176 = make_float3 (0.0f);
    uint i_26 = 0U;
    float3  weighted_0 = _S1176;
    for(;;)
    {
        if(i_26 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S1177 = (pdfs_4[i_26]) > 0.0f;
        if(_S1177)
        {
            float _S1178 = light_2->density;
            float _S1179 = pdfs_4[i_26] / light_2->density;
            float3  weighted_1 = weighted_0 + throughputs_1[i_26] * make_float3 (pdfs_4[i_26]) / make_float3 (_S1178 * (1.0f + _S1179 * _S1179));
            weighted_0 = weighted_1;
        }
        uint i_27 = i_26 + 1U;
        i_26 = i_27;
    }
    return weighted_0 * light_2->radiance * make_float3 (light_2->density);
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_1, uint random_state_14, bool refracted_3, uint lobe_4, float pdf_7)
{
    SampleBSDF _S1180;
    (&_S1180)->unit_direction = unit_direction_1;
    (&_S1180)->throughput = throughput_1;
    (&_S1180)->random_state = random_state_14;
    (&_S1180)->refracted = refracted_3;
    (&_S1180)->lobe = lobe_4;
    (&_S1180)->pdf = pdf_7;
    return _S1180;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  v_9, float3  n_i_13, float n_i_dot_v_3, BSDFMaterial material_22, Weights w_14, uint random_state_15)
{
    float3  _S1181 = make_float3 (1.0f);
    SampleBSDF _S1182 = SampleBSDF_x24init_0(_S1181, _S1181, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S1182;
    Random _S1183 = pcg(random_state_15);
    Random _S1184 = pcg(_S1183.state);
    (&sample_1)->random_state = _S1184.state;
    float _S1185 = _S1183.value;
    float _S1186 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1185 * _S1185))))));
    float _S1187 = 6.28318548202514648f * _S1184.value;
    float3  _S1188 = tangentToWorld(make_float3 (_S1186 * (F32_cos((_S1187))), _S1183.value, _S1186 * (F32_sin((_S1187)))), n_i_13);
    (&sample_1)->unit_direction = _S1188;
    (&sample_1)->lobe = 4U;
    float3  _S1189 = sheenVelvetBSDF((&sample_1)->unit_direction, v_9, n_i_13, material_22, w_14);
    (&sample_1)->throughput = _S1189;
    float _S1190 = sheenVelvetPDF(_S1183.value, n_i_dot_v_3, w_14);
    (&sample_1)->pdf = _S1190;
    return sample_1;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1191 = (F32_sqrt((random_1_0)));
    float _S1192 = 6.28318548202514648f * random_2_0;
    float _S1193 = _S1191 * (F32_cos((_S1192)));
    float _S1194 = _S1191 * (F32_sin((_S1192)));
    float _S1195 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1193 * _S1193 - _S1194 * _S1194))))));
    return make_float3 (_S1193, _S1195, _S1194);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_3, float3  n_i_14, float n_i_dot_v_4, BSDFMaterial material_23, Weights w_15, uint random_state_16)
{
    float3  _S1196 = make_float3 (1.0f);
    SampleBSDF _S1197 = SampleBSDF_x24init_0(_S1196, _S1196, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S1197;
    Random _S1198 = pcg(random_state_16);
    Random _S1199 = pcg(_S1198.state);
    (&sample_2)->random_state = _S1199.state;
    float3  _S1200 = sampleCosWeightedHemisphere(_S1198.value, _S1199.value);
    float _S1201 = translucentShare(material_23);
    bool _S1202 = u_3 < (w_15.p_diffuse * _S1201);
    float _S1203 = _S1200.y;
    float _S1204 = - _S1203;
    float _S1205 = _slang_select(_S1202, _S1204,_S1203);
    float3  _S1206 = tangentToWorld(make_float3 (_S1200.x, _S1205, _S1200.z), n_i_14);
    (&sample_2)->unit_direction = _S1206;
    (&sample_2)->refracted = _S1202;
    (&sample_2)->lobe = 0U;
    float3  _S1207 = diffuseBSDF((&sample_2)->unit_direction, n_i_14, material_23, w_15);
    (&sample_2)->throughput = _S1207;
    float _S1208 = diffusePDF(_S1205, n_i_dot_v_4, material_23, w_15);
    (&sample_2)->pdf = _S1208;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF toonSample(float3  n_i_15, ToonProfile profile_3, Weights w_16, uint random_state_17)
{
    float3  _S1209 = make_float3 (1.0f);
    SampleBSDF _S1210 = SampleBSDF_x24init_0(_S1209, _S1209, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S1210;
    Random _S1211 = pcg(random_state_17);
    Random _S1212 = pcg(_S1211.state);
    (&sample_3)->random_state = _S1212.state;
    float _S1213 = _S1211.value * profile_3.norm / 6.28318548202514648f;
    float t_23;
    if(profile_3.glossy)
    {
        t_23 = (F32_acos((clamp_1(1.0f - _S1213, -1.0f, 1.0f))));
    }
    else
    {
        t_23 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1213)))), (1.0f))))));
    }
    if(t_23 < (profile_3.a))
    {
    }
    else
    {
        t_23 = (profile_3.a + profile_3.b) / 2.0f;
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
        float _S1214 = toonP(t_23, profile_3.a, profile_3.s);
        float _S1215 = _S1214 * (F32_sin((t_23)));
        float _S1216;
        if(profile_3.glossy)
        {
            _S1216 = 1.0f;
        }
        else
        {
            _S1216 = (F32_cos((t_23)));
        }
        float _S1217 = _S1215 * _S1216;
        float _S1218 = toonIntegral(t_23, profile_3.a, profile_3.s, profile_3.glossy);
        float _S1219 = (_S1218 - _S1213) / _S1217;
        bool _S1220 = _S1217 > 0.0f;
        float _S1221 = _slang_select(_S1220, _S1219,0.0f);
        float _S1222 = clamp_1(t_23 - _S1221, 0.0f, profile_3.b);
        int k_1 = k_0 + int(1);
        t_23 = _S1222;
        k_0 = k_1;
    }
    float _S1223 = 6.28318548202514648f * _S1212.value;
    float _S1224 = (F32_sin((t_23)));
    float3  _S1225 = tangentToWorld(make_float3 (_S1224 * (F32_cos((_S1223))), (F32_cos((t_23))), _S1224 * (F32_sin((_S1223)))), profile_3.axis);
    (&sample_3)->unit_direction = _S1225;
    bool _S1226 = (dot_0(n_i_15, (&sample_3)->unit_direction)) < 0.0f;
    (&sample_3)->refracted = _S1226;
    (&sample_3)->lobe = 6U;
    float3  _S1227 = toonBSDF((&sample_3)->unit_direction, n_i_15, profile_3, w_16);
    (&sample_3)->throughput = _S1227;
    float _S1228 = toonPDF((&sample_3)->unit_direction, n_i_15, profile_3, w_16);
    (&sample_3)->pdf = _S1228;
    return sample_3;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_16, float alpha_8, AnisotropicFrame frame_6, BSDFMaterial material_24, Weights w_17, float pdf_h_3, float eta_i_7, float eta_o_7, uint random_state_18)
{
    float3  _S1229 = make_float3 (1.0f);
    SampleBSDF _S1230 = SampleBSDF_x24init_0(_S1229, _S1229, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S1230;
    (&sample_4)->unit_direction = w_17.refracted;
    (&sample_4)->random_state = random_state_18;
    (&sample_4)->refracted = true;
    (&sample_4)->lobe = 1U;
    float3  _S1231 = refractBSDF((&sample_4)->unit_direction, n_i_16, alpha_8, frame_6, material_24, w_17);
    (&sample_4)->throughput = _S1231;
    float _S1232 = refractPDF(dot_0((&sample_4)->unit_direction, ggx_n_3), pdf_h_3, w_17, eta_i_7, eta_o_7);
    (&sample_4)->pdf = _S1232;
    return sample_4;
}

static __device__ float3  reflect_0(float3  i_28, float3  n_9)
{
    return i_28 - make_float3 (2.0f * dot_0(n_9, i_28)) * n_9;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_9, float3  ggx_n_4, float3  n_i_17, float alpha_9, AnisotropicFrame frame_7, Weights w_18, float pdf_h_4, uint random_state_19)
{
    float3  _S1233 = make_float3 (1.0f);
    SampleBSDF _S1234 = SampleBSDF_x24init_0(_S1233, _S1233, 0U, false, 0U, 0.0f);
    SampleBSDF sample_5 = _S1234;
    float3  _S1235 = reflect_0(in_dir_9, ggx_n_4);
    float3  _S1236 = ((((_S1235)) * make_float3(rnorm3df(((_S1235)).x, ((_S1235)).y, ((_S1235)).z))));
    (&sample_5)->unit_direction = _S1236;
    (&sample_5)->random_state = random_state_19;
    (&sample_5)->lobe = 2U;
    float3  _S1237 = reflectBSDF((&sample_5)->unit_direction, n_i_17, alpha_9, frame_7, w_18);
    (&sample_5)->throughput = _S1237;
    float _S1238 = reflectPDF(pdf_h_4, w_18);
    (&sample_5)->pdf = _S1238;
    return sample_5;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_10, float3  n_10, BSDFMaterial material_25, float eta_i_8, float eta_o_8, uint random_init_0, float2  screen_space_0)
{
    uint random_state_20 = random_init_0;
    float3  _S1239 = negate_0(in_dir_10);
    float _S1240 = dot_0(n_10, _S1239);
    float _S1241 = sign_0(_S1240);
    float3  n_i_18 = n_10 * make_float3 (_S1241);
    float _S1242 = (F32_abs((_S1240)));
    float _S1243 = material_25.roughness;
    float _S1244 = _S1243 * _S1243;
    AnisotropicFrame _S1245 = anisotropicFrame(material_25, n_i_18);
    SheenProfile _S1246 = sheenProfile(_S1239, n_i_18, material_25);
    float3  _S1247 = sampleHalfVector(_S1239, n_i_18, _S1244, _S1245, &random_state_20);
    Weights _S1248 = lobeWeights(in_dir_10, _S1239, n_i_18, _S1247, _S1245, _S1246, material_25, eta_i_8, eta_o_8);
    Random _S1249 = pcg(random_state_20);
    random_state_20 = _S1249.state;
    bool _S1250 = (_S1249.value) < (_S1248.p_sheen_velvet);
    if(_S1250)
    {
        SampleBSDF _S1251 = sheenVelvetSample(_S1239, n_i_18, _S1242, material_25, _S1248, random_state_20);
        return _S1251;
    }
    float _S1252 = _S1249.value - _S1248.p_sheen_velvet;
    bool _S1253 = _S1252 < (_S1248.p_diffuse);
    if(_S1253)
    {
        SampleBSDF _S1254 = diffuseSample(_S1252, n_i_18, _S1242, material_25, _S1248, random_state_20);
        return _S1254;
    }
    bool _S1255 = _S1252 < (_S1248.p_diffuse + _S1248.p_toon);
    if(_S1255)
    {
        ToonProfile _S1256 = toonProfile(_S1239, n_i_18, material_25);
        SampleBSDF _S1257 = toonSample(n_i_18, _S1256, _S1248, random_state_20);
        return _S1257;
    }
    float _S1258 = vndfPDF(_S1239, _S1247, n_i_18, _S1242, _S1244, _S1245, _S1248.v_dot_h);
    bool _S1259 = (_S1252 - _S1248.p_toon) < (_S1248.p_diffuse + _S1248.p_refract);
    if(_S1259)
    {
        SampleBSDF _S1260 = refractSample(_S1247, n_i_18, _S1244, _S1245, material_25, _S1248, _S1258, eta_i_8, eta_o_8, random_state_20);
        return _S1260;
    }
    SampleBSDF _S1261 = reflectSample(in_dir_10, _S1247, n_i_18, _S1244, _S1245, _S1248, _S1258, random_state_20);
    return _S1261;
}

static __device__ bool boundsVolume_0(FKSurface * surface_12)
{
    return surface_12->encloses;
}

static __device__ Shift walk_0(Domain * dom_7, Reservoir * r_8, bool replay_1, float scale_3, Selection * sel_7)
{
    float spread_1;
    bool turned_1;
    bool is_inside_6;
    bool viewed_0;
    bool _S1262;
    bool _S1263;
    float density_2;
    float wavelength_9;
    float width_3;
    float sky_pdf_0;
    float threshold_0;
    uint b_6;
    uint layer_0;
    float3  throughput_2;
    float3  spectral_weight_0;
    TreeSample light_3;
    int _S1264;
    Shift ended_0;
    float density_3;
    float spread_2;
    float width_4;
    float sky_pdf_1;
    float spread_3;
    float width_5;
    uint b_7;
    float3  _S1265 = make_float3 (0.0f);
    Shift _S1266 = Shift_x24init_0(_S1265, 0.0f);
    uint _S1267 = r_8->path;
    uint _S1268 = extractBits_0(r_8->path, 0U, 5U);
    uint _S1269 = extractBits_0(_S1267, 5U, 5U);
    uint _S1270 = extractBits_0(_S1267, 10U, 2U);
    uint _S1271 = extractBits_0(_S1267, 12U, 3U);
    bool passes_0;
    if(replay_1)
    {
        bool _S1272 = _S1271 >= 3U;
        uint _S1273 = _slang_select(_S1272, 1U,0U);
        uint _S1274 = _S1268 + _S1273;
        uint _S1275 = (fcptMaxBounces());
        passes_0 = _S1274 > _S1275;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1266;
    }
    uint _S1276 = _S1269 - 1U;
    bool _S1277 = _S1271 == 3U;
    uint _S1278 = _slang_select(_S1277, 1U,0U);
    uint _S1279 = _S1268 + _S1278;
    bool _S1280 = _S1270 == 0U;
    uint _S1281 = _slang_select(_S1280, _S1279,_S1276);
    FKHit _S1282 = (fcptReservoirHit((*r_8)));
    float3  _S1283 = dom_7->x0;
    float3  _S1284 = dom_7->x1 - dom_7->x0;
    float3  _S1285 = ((((_S1284)) * make_float3(rnorm3df(((_S1284)).x, ((_S1284)).y, ((_S1284)).z))));
    FKRay _S1286 = Ray_x24init_0(dom_7->x1, _S1285);
    FKRay ray_2 = _S1286;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1265;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_2 = throughput_3;
    float3  glowed_0 = _S1265;
    float3  extinction_in_0 = _S1265;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1287 = dom_7->spread;
    float _S1288 = dom_7->width;
    float _S1289 = length_0(_S1284);
    NEEVertex _S1290 = NEEVertex_x24init_0(true, 0.0f, _S1265, _S1265, _S1265);
    NEEVertex nee_vertex_0 = _S1290;
    Vertex _S1291 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S1291;
    Reservoir _S1292 = (Reservoir{});
    Reservoir chain_0 = _S1292;
    uint _S1293 = r_8->seed;
    (&chain_0)->seed = r_8->seed;
    uint _S1294 = extractBits_0(_S1267, 24U, 8U);
    uint _S1295 = insertBits_0(0U, _S1294, 24U, 8U);
    (&chain_0)->path = _S1295;
    (&ray_2)->origin = _S1283;
    (&hit_4)->distance = _S1289;
    FKMedium _S1296 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1297 = filling_2;
    bool _S1298 = (fcptVaryingUsed());
    uint _S1299 = _slang_select(_S1298, _S1297,4294967295U);
    filling_2 = _S1299;
    scatter_in_0 = _S1296.scatter;
    extinction_in_0 = _S1296.extinction;
    g_in_0 = _S1296.g;
    Reservoir _S1300 = chain_0;
    uint _S1301 = filling_2;
    for(;;)
    {
        bool _S1302 = (fcptVaryingUsed());
        if(_S1302)
        {
            passes_0 = _S1301 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1303 = (fcptMajorant((_S1301)));
            spread_1 = _S1303;
        }
        else
        {
            spread_1 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_1)
        {
            turned_1 = 4294967295U == _S1281;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1270 == 1U;
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
            ended_0 = _S1266;
            sky_pdf_0 = 0.0f;
            spread_1 = _S1287;
            width_3 = _S1288;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_6 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1304 = (&prev_0)->rough;
        if(_S1304)
        {
            turned_1 = !(spread_1 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S1305 = stream(_S1293, 384U);
        uint tracking_0 = _S1305;
        weight_2 = throughput_3;
        glowed_0 = _S1265;
        b_6 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        wavelength_9 = _S1287;
        width_3 = _S1288;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1264 = int(1);
                break;
            }
            uint _S1306 = b_6 + 320U;
            bool _S1307 = b_6 == 4294967295U;
            uint _S1308 = _slang_select(_S1307, 384U,_S1306);
            uint _S1309 = stream(_S1293, _S1308);
            Random _S1310 = pcg(_S1309);
            float _S1311 = - (F32_log((1.0f - _S1310.value))) / spread_1;
            if(passes_0)
            {
                float3  _S1312 = (&ray_2)->origin;
                float3  _S1313 = (&ray_2)->unit_direction;
                float _S1314 = (&hit_4)->distance;
                uint _S1315 = _slang_select(_S1307, 0U,b_6);
                uint _S1316 = (&prev_0)->lobe;
                uint _S1317 = _slang_select(_S1307, 3U,_S1316);
                float _S1318 = (fcptTrackMedium((_S1301), (_S1312), (_S1313), (_S1314), (&tracking_0), (&weight_2), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1315), (_S1317), (_S1307)));
                threshold_0 = _S1318;
            }
            else
            {
                threshold_0 = _S1311;
            }
            bool _S1319 = !(threshold_0 < ((&hit_4)->distance));
            if(_S1319)
            {
                _S1264 = int(1);
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
                float3  _S1320 = pathColor(throughput_2 * glowed_0, throughput_3, 0.0f);
                float3  _S1321 = _S1320 / make_float3 (density_2);
                float3  _S1322 = sel_7->glow + _S1321;
                sel_7->glow = _S1322;
            }
            else
            {
            }
            glowed_0 = _S1265;
            uint b_8 = b_6 + 1U;
            float3  _S1323 = (&ray_2)->origin + make_float3 (threshold_0) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1323;
            float3  _S1324 = flightWeight_0(scatter_in_0, extinction_in_0, spread_1, threshold_0, true);
            float3  _S1325 = weight_2;
            float _S1326 = upsample(weight_2, 0.0f);
            float3  _S1327 = make_float3 (_S1326);
            float3  _S1328 = _slang_select(false, _S1327,_S1325);
            float3  _S1329 = _slang_select(passes_0, _S1328,_S1324);
            float3  throughput_4 = throughput_2 * _S1329;
            uint _S1330 = stream(_S1293, b_8 + 320U);
            tracking_0 = _S1330;
            weight_2 = throughput_3;
            float width_6 = width_3 + wavelength_9 * threshold_0;
            float _S1331 = wavelength_9 + 3.14159274101257324f;
            bool _S1332 = !replay_1;
            if(_S1332)
            {
                is_inside_6 = true;
            }
            else
            {
                bool _S1333 = b_8 == _S1281;
                if(_S1333)
                {
                    is_inside_6 = !passes_0;
                }
                else
                {
                    is_inside_6 = false;
                }
            }
            TreeSample _S1334 = TreeSample_x24init_0(_S1265, _S1265, 0.0f, 0U);
            if(is_inside_6)
            {
                float3  _S1335 = (&ray_2)->origin;
                float3  _S1336 = (&ray_2)->unit_direction;
                float3  _S1337 = (&ray_2)->unit_direction;
                uint _S1338 = stream(_S1293, b_8 + 64U);
                float3  _S1339 = extinction_in_0;
                float3  _S1340 = extinction_in_0;
                uint2  _S1341 = make_uint2 (_S1301);
                float3  _S1342 = (&ray_2)->unit_direction;
                uint _S1343 = arrivalLobe_0(b_8, (&prev_0)->lobe);
                FKHit _S1344 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1345 = _S1344;
                ShadowContext _S1346 = ShadowContext_x24init_0(_S1339, _S1340, _S1341, _S1342, b_8, _S1343, false, threshold_0, width_6, &_S1345, false);
                ShadowContext _S1347 = _S1346;
                TreeSample _S1348 = sampleLightTree_0(_S1335, _S1336, _S1337, 0.0f, true, _S1338, &_S1347);
                light_3 = _S1348;
            }
            else
            {
                light_3 = _S1334;
            }
            float _S1349 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S1350 = (fcptMaxBounces());
            bool _S1351 = b_8 < _S1350;
            if(_S1351)
            {
                viewed_0 = (light_3.density) > 0.0f;
            }
            else
            {
                viewed_0 = false;
            }
            float _S1352 = _slang_select(viewed_0, _S1349,0.0f);
            float3  _S1353 = throughput_4 * light_3.radiance;
            float _S1354 = powerHeuristic(light_3.density, _S1352);
            float3  _S1355 = pathColor(_S1353 * make_float3 (_S1349 * _S1354), throughput_3, 0.0f);
            float3  _S1356 = _slang_select(is_inside_6, _S1355,_S1265);
            if(replay_1)
            {
                _S1262 = b_8 == _S1281;
            }
            else
            {
                _S1262 = false;
            }
            if(_S1262)
            {
                bool _S1357 = _S1270 == 2U;
                if(_S1357)
                {
                    float _S1358 = resamplingTarget(_S1356);
                    passes_0 = _S1358 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1359 = Shift_x24init_0(_S1356, 1.0f);
                    _S1264 = int(0);
                    ended_0 = _S1359;
                    spread_1 = _S1331;
                    threshold_0 = width_6;
                    spectral_weight_0 = throughput_4;
                    layer_0 = b_8;
                    break;
                }
                _S1264 = int(0);
                ended_0 = _S1266;
                spread_1 = _S1331;
                threshold_0 = width_6;
                spectral_weight_0 = throughput_4;
                layer_0 = b_8;
                break;
            }
            if(_S1332)
            {
                Reservoir candidate_3 = _S1300;
                uint _S1360 = extractBits_0(_S1300.path, 24U, 8U);
                uint _S1361 = insertBits_0(0U, _S1360, 24U, 8U);
                uint _S1362 = extractBits_0(_S1300.path, 10U, 2U);
                bool _S1363 = _S1362 == 1U;
                if(_S1363)
                {
                    float3  _S1364 = safeDivide(_S1356, _S1265);
                    (&candidate_3)->radiance = _S1364;
                }
                else
                {
                    uint _S1365 = insertBits_0(_S1361, b_8 + 1U, 5U, 5U);
                    uint _S1366 = insertBits_0(_S1365, 2U, 10U, 2U);
                    (&candidate_3)->path = _S1366;
                }
                Reservoir _S1367 = withEnd(candidate_3, 0U, b_8, _S1356);
                offer(sel_7, _S1367, _S1356 * make_float3 (scale_3) / make_float3 (density_2));
                float _S1368 = survivalProbability(abs_0(throughput_4), density_2);
                uint _S1369 = stream(_S1293, b_8 + 128U);
                Random _S1370 = pcg(_S1369);
                bool _S1371 = _S1368 < (_S1370.value);
                if(_S1371)
                {
                    _S1263 = true;
                }
                else
                {
                    uint _S1372 = (fcptMaxBounces());
                    _S1263 = b_8 >= _S1372;
                }
                if(_S1263)
                {
                    _S1264 = int(0);
                    ended_0 = _S1266;
                    spread_1 = _S1331;
                    threshold_0 = width_6;
                    spectral_weight_0 = throughput_4;
                    layer_0 = b_8;
                    break;
                }
                float _S1373 = density_2 * _S1368;
                density_2 = _S1373;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1374 = stream(_S1293, b_8);
            float3  _S1375 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1374, &phase_pdf_0);
            (&ray_2)->unit_direction = _S1375;
            NEEVertex _S1376 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S1265, (&ray_2)->origin);
            nee_vertex_0 = _S1376;
            Vertex _S1377 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, false);
            prev_0 = _S1377;
            float _S1378 = (&prev_0)->pdf;
            FKRay _S1379 = ray_2;
            FKHit _S1380 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1381 = (fcptTraverseInstanceBVH((_S1379), (true), (4.294967296e+09f), (false), (_S1380), (false)));
            hit_4 = _S1381;
            b_6 = b_8;
            throughput_2 = throughput_4;
            wavelength_9 = _S1331;
            width_3 = width_6;
            sky_pdf_0 = _S1378;
        }
        if(_S1264 != int(1))
        {
            width_3 = threshold_0;
            throughput_2 = spectral_weight_0;
            b_6 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1266;
        spread_1 = wavelength_9;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1382 = b_6 == 4294967295U;
    bool _S1383 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1383)
    {
        bool _S1384 = !(&nee_vertex_0)->none;
        float _S1385 = _slang_select(_S1384, sky_pdf_0,0.0f);
        float _S1386 = escapeWeight_0(_S1385, (&ray_2)->unit_direction);
        float3  _S1387 = environment_0((&ray_2)->unit_direction, b_6, (&prev_0)->lobe);
        float3  _S1388 = pathColor(throughput_2 * _S1387, throughput_3, 0.0f);
        if(replay_1)
        {
            bool _S1389 = b_6 == _S1281;
            if(_S1389)
            {
                passes_0 = _S1270 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S1388 * make_float3 (_S1386) / make_float3 (r_8->jac), density_2 / r_8->jac);
            }
            if(_S1280)
            {
                passes_0 = _S1277;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_6 == _S1268;
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
                return Shift_x24init_0(_S1388 * make_float3 (_S1386), 1.0f);
            }
            return _S1266;
        }
        Reservoir candidate_4 = chain_0;
        uint _S1390 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1391 = _S1390 == 1U;
        if(_S1391)
        {
            uint _S1392 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S1393 = _S1392 == b_6;
            float _S1394 = _slang_select(_S1393, 1.0f,_S1386);
            float3  _S1395 = safeDivide(_S1388 * make_float3 (_S1394), _S1265);
            (&candidate_4)->radiance = _S1395;
        }
        else
        {
            bool _S1396 = (&prev_0)->rough;
            if(_S1396)
            {
                uint _S1397 = insertBits_0(_S1295, b_6 + 1U, 5U, 5U);
                uint _S1398 = insertBits_0(_S1397, 3U, 10U, 2U);
                uint _S1399 = insertBits_0(_S1398, (&prev_0)->lobe, 15U, 3U);
                bool _S1400 = (&prev_0)->inside;
                uint _S1401 = _slang_select(_S1400, 1U,0U);
                uint _S1402 = insertBits_0(_S1399, _S1401, 22U, 1U);
                (&candidate_4)->path = _S1402;
                (&candidate_4)->jac = (&prev_0)->pdf;
                (&candidate_4)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S1403 = _S1388 * make_float3 (_S1386);
        Reservoir _S1404 = withEnd(candidate_4, 3U, b_6, _S1403);
        offer(sel_7, _S1404, _S1403 * make_float3 (scale_3) / make_float3 (density_2));
        return _S1266;
    }
    float3  _S1405 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S1405;
    bool _S1406 = (fcptVaryingUsed());
    if(_S1406)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1407 = !replay_1;
        if(_S1407)
        {
            float3  _S1408 = pathColor(throughput_2 * glowed_0, throughput_3, 0.0f);
            float3  _S1409 = _S1408 / make_float3 (density_2);
            float3  _S1410 = sel_7->glow + _S1409;
            sel_7->glow = _S1410;
        }
        float3  _S1411 = throughput_2 * weight_2;
        throughput_2 = _S1411;
    }
    else
    {
        float3  _S1412 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
        float3  _S1413 = throughput_2 * _S1412;
        throughput_2 = _S1413;
    }
    float _S1414 = width_3 + spread_1 * (&hit_4)->distance;
    uint _S1415 = b_6 + 1U;
    b_6 = _S1415;
    layer_0 = 0U;
    width_3 = _S1414;
    passes_0 = false;
    wavelength_9 = 0.0f;
    threshold_0 = 0.0f;
    turned_1 = false;
    is_inside_6 = false;
    spectral_weight_0 = throughput_3;
    float3  chain_throughput_0 = _S1265;
    float3  reconnection_0 = _S1265;
    viewed_0 = _S1382;
    for(;;)
    {
        bool _S1416 = ((&hit_4)->is_point_light) == 1U;
        if(replay_1)
        {
            _S1262 = _S1270 == 1U;
        }
        else
        {
            _S1262 = false;
        }
        if(_S1262)
        {
            _S1263 = b_6 == _S1269;
        }
        else
        {
            _S1263 = false;
        }
        bool _S1417;
        if(_S1263)
        {
            bool _S1418 = ((&hit_4)->instance_index) != (_S1282.instance_index);
            if(_S1418)
            {
                _S1417 = true;
            }
            else
            {
                _S1417 = ((&hit_4)->triangle_index) != (_S1282.triangle_index);
            }
        }
        else
        {
            _S1417 = false;
        }
        if(_S1417)
        {
            return _S1266;
        }
        FKMedium _S1419 = Medium_x24init_0(_S1265, _S1265, 0.0f);
        BSDFMaterial _S1420 = Material_x24init_0(_S1265, _S1265, 0.0f, 0.0f, 0.0f, 0.0f, _S1265, throughput_3, 1.0f, _S1265, _S1265, 0.5f, 0.0f, 0.0f, _S1265, 0.0f, _S1265, 0.0f);
        FKMedium _S1421 = _S1419;
        FKSurface _S1422 = Surface_x24init_0(_S1265, _S1265, 0.0f, &_S1420, false, 0U, 1.0f, false, &_S1421, 4294967295U, _S1265);
        bool _S1423 = !_S1416;
        bool scatter_2;
        bool is_inside_7;
        float geometry_density_0;
        float3  throughput_5;
        FKSurface surface_13;
        if(_S1423)
        {
            uint _S1424 = stream(_S1293, b_6);
            uint _S1425 = arrivalLobe_0(b_6, (&prev_0)->lobe);
            FKSurface _S1426 = (fcptSurfaceAtPath((hit_4), ((&ray_2)->origin), (_S1424), (width_3), (layer_0), (b_6), (_S1425), ((&ray_2)->unit_direction)));
            bool _S1427 = !passes_0;
            FKSurface _S1428 = _S1426;
            FKSurface _S1429 = emitting_0(&_S1428, _S1427);
            uint _S1430 = stream(_S1293, b_6 + 256U);
            Random _S1431 = pcg(_S1430);
            FKSurface _S1432 = _S1429;
            FKSurface _S1433 = uncovered_0(&_S1432, _S1431.value);
            float _S1434 = facingSign(_S1433.material.transmission, _S1433.geometry_n, (&ray_2)->unit_direction);
            bool _S1435 = _S1434 < 0.0f;
            bool _S1436 = (_S1433.material.transmission) > 0.0f;
            if(_S1436)
            {
                bool _S1437 = arrivesBehind_0((&ray_2)->unit_direction, _S1433.geometry_n);
                scatter_2 = _S1437;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1438 = _S1433;
            FKSurface _S1439 = facingRay_0(&_S1438, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S1440 = arrivesBehind_0((&ray_2)->unit_direction, _S1439.geometry_n);
                is_inside_7 = _S1440;
            }
            else
            {
                is_inside_7 = scatter_2;
            }
            if(is_inside_7)
            {
                float _S1441 = (&hit_4)->distance;
                float _S1442 = upsample(_S1439.material.absorption, wavelength_9);
                float3  _S1443 = make_float3 (_S1442);
                bool _S1444 = wavelength_9 > 0.0f;
                float3  _S1445 = _slang_select(_S1444, _S1443,_S1439.material.absorption);
                float3  _S1446 = beerLambert(_S1441, _S1445);
                float3  _S1447 = throughput_2 * _S1446;
                throughput_5 = _S1447;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S1448 = !_S1439.skip;
            float geometry_density_1 = (F32_abs((dot_0(_S1439.geometry_n, (&ray_2)->unit_direction)))) / ((&hit_4)->distance * (&hit_4)->distance);
            bool _S1449 = b_6 == _S1415;
            if(_S1449)
            {
                float _S1450 = 0.00251327408477664f / geometry_density_1;
                geometry_density_0 = _S1450;
            }
            else
            {
                geometry_density_0 = threshold_0;
            }
            float _S1451 = geometry_density_0;
            scatter_2 = _S1448;
            geometry_density_0 = geometry_density_1;
            threshold_0 = _S1451;
            surface_13 = _S1439;
            turned_1 = _S1435;
        }
        else
        {
            scatter_2 = false;
            geometry_density_0 = 0.0f;
            surface_13 = _S1422;
            throughput_5 = throughput_2;
            is_inside_7 = is_inside_6;
        }
        bool _S1452;
        if(scatter_2)
        {
            _S1452 = (&prev_0)->rough;
        }
        else
        {
            _S1452 = false;
        }
        bool _S1453;
        if(_S1452)
        {
            _S1453 = ((&prev_0)->pdf * geometry_density_0 * threshold_0) <= 1.0f;
        }
        else
        {
            _S1453 = false;
        }
        FKSurface _S1454 = surface_13;
        float _S1455 = dot_0(surface_13.smooth_n, - (&ray_2)->unit_direction);
        bool _S1456 = (fcptDispersionUsed());
        bool _S1457;
        if(_S1456)
        {
            _S1457 = wavelength_9 == 0.0f;
        }
        else
        {
            _S1457 = false;
        }
        bool _S1458;
        if(_S1457)
        {
            _S1458 = scatter_2;
        }
        else
        {
            _S1458 = false;
        }
        bool _S1459;
        if(_S1458)
        {
            bool _S1460 = dispersive(surface_13.material);
            _S1459 = _S1460;
        }
        else
        {
            _S1459 = false;
        }
        float3  throughput_6;
        if(_S1459)
        {
            uint _S1461 = stream(_S1293, 512U);
            Random _S1462 = pcg(_S1461);
            uint _S1463 = extractBits_0(_S1267, 25U, 7U);
            float _S1464 = (float(_S1463) + _S1462.value) / 128.0f;
            uint _S1465 = extractBits_0(_S1267, 24U, 1U);
            bool _S1466 = _S1465 == 1U;
            float _S1467 = _slang_select(_S1466, _S1464,_S1462.value);
            float2  _S1468 = sampleWavelength(_S1467);
            float wavelength_10 = _S1468.x;
            float3  _S1469 = wavelengthWeights(wavelength_10);
            float3  _S1470 = _S1469 / make_float3 (_S1468.y);
            float _S1471 = upsample(throughput_5, wavelength_10);
            float3  _S1472 = make_float3 (_S1471);
            float _S1473 = upsample(scatter_in_0, wavelength_10);
            float3  _S1474 = make_float3 (_S1473);
            scatter_in_0 = _S1474;
            float _S1475 = upsample(extinction_in_0, wavelength_10);
            float3  _S1476 = make_float3 (_S1475);
            extinction_in_0 = _S1476;
            wavelength_9 = wavelength_10;
            throughput_6 = _S1472;
            spectral_weight_0 = _S1470;
        }
        else
        {
            throughput_6 = throughput_5;
        }
        BSDFMaterial _S1477 = pathMaterial(surface_13.material, wavelength_9);
        float2  _S1478 = wavelengthEta(_S1477, _S1455, wavelength_9);
        bool _S1479;
        if(scatter_2)
        {
            bool _S1480 = neeDecision(_S1477, _S1455, _S1478.x, _S1478.y);
            _S1479 = _S1480;
        }
        else
        {
            _S1479 = false;
        }
        bool _S1481;
        if(passes_0)
        {
            _S1481 = true;
        }
        else
        {
            _S1481 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1481)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1479;
        }
        bool _S1482 = (fcptHairUsed());
        bool _S1483;
        if(_S1482)
        {
            float3  _S1484 = surface_13.hair;
            _S1483 = (dot_0(_S1484, _S1484)) > 0.0f;
        }
        else
        {
            _S1483 = false;
        }
        bool _S1485;
        if(_S1483)
        {
            _S1485 = true;
        }
        else
        {
            BSDFMaterial _S1486 = _S1477;
            bool _S1487 = isTranslucent_0(&_S1486);
            _S1485 = _S1487;
        }
        bool _S1488;
        if(_S1485)
        {
            _S1488 = true;
        }
        else
        {
            bool _S1489 = (_S1477.transmission) > 0.0f;
            if(_S1489)
            {
                uint _S1490 = (fcptLayers((hit_4)));
                _S1488 = _S1490 == 1U;
            }
            else
            {
                _S1488 = false;
            }
        }
        float3  emission_0;
        if(_S1416)
        {
            float3  _S1491 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1491;
        }
        else
        {
            emission_0 = _S1477.emissive;
        }
        bool _S1492 = !replay_1;
        bool _S1493;
        if(_S1492)
        {
            _S1493 = true;
        }
        else
        {
            _S1493 = b_6 >= _S1281;
        }
        bool _S1494;
        if(_S1493)
        {
            float _S1495 = rgb_to_greyscale(emission_0);
            _S1494 = _S1495 > 0.0f;
        }
        else
        {
            _S1494 = false;
        }
        float3  emission_1;
        if(_S1494)
        {
            NEEVertex _S1496 = nee_vertex_0;
            FKHit _S1497 = hit_4;
            float _S1498 = emissionWeight_0(&_S1496, &_S1497, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1498);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1499;
        if(replay_1)
        {
            _S1499 = _S1270 == 1U;
        }
        else
        {
            _S1499 = false;
        }
        bool _S1500;
        if(_S1499)
        {
            _S1500 = b_6 > _S1269;
        }
        else
        {
            _S1500 = false;
        }
        bool _S1501;
        if(_S1500)
        {
            _S1501 = b_6 == _S1268;
        }
        else
        {
            _S1501 = false;
        }
        bool _S1502;
        if(_S1501)
        {
            bool _S1503 = _S1271 == 1U;
            if(_S1503)
            {
                _S1502 = true;
            }
            else
            {
                _S1502 = _S1271 == 2U;
            }
        }
        else
        {
            _S1502 = false;
        }
        if(_S1502)
        {
            bool _S1504 = _S1416 != (_S1271 == 2U);
            if(_S1504)
            {
                return _S1266;
            }
            float3  _S1505 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_9);
            return Shift_x24init_0(_S1505 / make_float3 (r_8->jac), density_2 / r_8->jac);
        }
        uint _S1506 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1507 = _S1506 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1508 = insertBits_0(_S1295, b_6, 5U, 5U);
        uint _S1509 = insertBits_0(_S1508, 1U, 10U, 2U);
        uint _S1510 = insertBits_0(_S1509, (&prev_0)->lobe, 15U, 3U);
        bool _S1511 = (&prev_0)->inside;
        uint _S1512 = _slang_select(_S1511, 1U,0U);
        uint _S1513 = insertBits_0(_S1510, _S1512, 22U, 1U);
        (&here_0)->path = _S1513;
        uint _S1514 = (&here_0)->path;
        bool _S1515 = wavelength_9 > 0.0f;
        uint _S1516 = _slang_select(_S1515, 1U,0U);
        uint _S1517 = insertBits_0(_S1514, _S1516, 23U, 1U);
        (&here_0)->path = _S1517;
        float _S1518 = (&prev_0)->pdf * geometry_density_0;
        (&here_0)->jac = _S1518;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1519;
        if(replay_1)
        {
            _S1519 = _S1270 == 1U;
        }
        else
        {
            _S1519 = false;
        }
        bool _S1520;
        if(_S1519)
        {
            _S1520 = b_6 == _S1269;
        }
        else
        {
            _S1520 = false;
        }
        bool _S1521 = b_6 == _S1281;
        bool _S1522;
        if(_S1521)
        {
            bool _S1523 = !scatter_2;
            if(_S1523)
            {
                _S1522 = true;
            }
            else
            {
                bool _S1524 = _S1270 != 1U;
                if(_S1524)
                {
                    _S1522 = _S1270 != 3U;
                }
                else
                {
                    _S1522 = false;
                }
            }
        }
        else
        {
            _S1522 = false;
        }
        bool _S1525;
        if(_S1522)
        {
            _S1525 = _S1270 == 2U;
        }
        else
        {
            _S1525 = false;
        }
        bool _S1526;
        if(_S1525)
        {
            _S1526 = !_S1453;
        }
        else
        {
            _S1526 = false;
        }
        bool _S1527;
        if(_S1526)
        {
            _S1527 = _S1271 != 4U;
        }
        else
        {
            _S1527 = false;
        }
        bool _S1528 = _S1269 == _S1268;
        bool _S1529;
        if(_S1528)
        {
            _S1529 = _S1271 == 0U;
        }
        else
        {
            _S1529 = false;
        }
        bool _S1530;
        if(_S1529)
        {
            _S1530 = ((&hit_4)->instance_index) == (_S1282.instance_index);
        }
        else
        {
            _S1530 = false;
        }
        bool _S1531;
        if(_S1530)
        {
            _S1531 = ((&hit_4)->triangle_index) == (_S1282.triangle_index);
        }
        else
        {
            _S1531 = false;
        }
        bool _S1532;
        if(_S1531)
        {
            _S1532 = _S1453;
        }
        else
        {
            _S1532 = false;
        }
        bool _S1533 = _slang_select(_S1520, _S1532,_S1527);
        bool _S1534;
        if(nee_0)
        {
            _S1534 = _slang_select(replay_1, _S1533,scatter_2);
        }
        else
        {
            _S1534 = false;
        }
        TreeSample _S1535 = TreeSample_x24init_0(_S1265, _S1265, 0.0f, 0U);
        uint2  _S1536 = make_uint2 (0U);
        float2  _S1537 = make_float2 (0.0f);
        FKHit _S1538 = Hit_x24init_0(_S1537, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1539 = _S1538;
        ShadowContext _S1540 = ShadowContext_x24init_0(_S1265, _S1265, _S1536, _S1265, 0U, 0U, false, 0.0f, 0.0f, &_S1539, false);
        bool _S1541;
        if(nee_0)
        {
            _S1541 = _S1493;
        }
        else
        {
            _S1541 = false;
        }
        ShadowContext context_5;
        if(_S1541)
        {
            uint _S1542 = arrivalLobe_0(b_6, (&prev_0)->lobe);
            FKMedium _S1543 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1544 = surface_13;
            FKHit _S1545 = hit_4;
            FKMedium _S1546 = _S1543;
            ShadowContext _S1547 = shadowContext_0(&_S1544, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_6, _S1542, (&hit_4)->distance, width_3, &_S1545, _S1483, &_S1546);
            context_5 = _S1547;
        }
        else
        {
            context_5 = _S1540;
        }
        float3  throughput_7;
        float3  lit_0;
        if(_S1534)
        {
            float3  _S1548 = (&ray_2)->origin;
            if(_S1483)
            {
                throughput_7 = _S1265;
            }
            else
            {
                throughput_7 = _S1454.smooth_n;
            }
            FKSurface _S1549 = surface_13;
            uint _S1550 = stream(_S1293, b_6 + 64U);
            ShadowContext _S1551 = context_5;
            TreeSample _S1552 = sampleLightTree_0(_S1548, throughput_7, surface_13.geometry_n, surface_13.geometry_offset, _S1488, _S1550, &_S1551);
            bool _S1553 = any_1((_S1552.radiance) != _S1265);
            if(_S1553)
            {
                if(_S1483)
                {
                    uint _S1554 = (fcptMaxBounces());
                    bool _S1555 = b_6 < _S1554;
                    FKSurface _S1556 = surface_13;
                    TreeSample _S1557 = _S1552;
                    float3  _S1558 = hairLight_0(&_S1556, (&ray_2)->unit_direction, &_S1557, _S1555);
                    lit_0 = _S1558;
                }
                else
                {
                    float _S1559 = _S1478.x;
                    float _S1560 = _S1478.y;
                    uint _S1561 = (fcptMaxBounces());
                    bool _S1562 = b_6 < _S1561;
                    TreeSample _S1563 = _S1552;
                    BSDFMaterial _S1564 = _S1477;
                    float3  _S1565 = lightBSDF_0((&ray_2)->unit_direction, &_S1563, _S1454.smooth_n, _S1549.geometry_n, &_S1564, _S1559, _S1560, _S1562, surface_13.random_state);
                    lit_0 = _S1565;
                }
            }
            else
            {
                lit_0 = _S1265;
            }
            light_3 = _S1552;
        }
        else
        {
            light_3 = _S1535;
            lit_0 = _S1265;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1566;
        bool _S1567;
        float density_4;
        if(_S1520)
        {
            bool _S1568 = !_S1453;
            if(_S1568)
            {
                return _S1266;
            }
            uint _S1569 = extractBits_0(_S1267, 23U, 1U);
            bool _S1570 = _S1515 != (_S1569 == 1U);
            if(_S1570)
            {
                return _S1266;
            }
            float3  throughput_8 = throughput_6 * make_float3 (geometry_density_0);
            float density_5 = density_2 * geometry_density_0;
            if(_S1528)
            {
                viewed_1 = _S1271 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                float3  _S1571 = pathColor(throughput_8 * emission_1, spectral_weight_0, wavelength_9);
                return Shift_x24init_0(_S1571 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1528)
            {
                refracted_4 = _S1271 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S1572 = !nee_0;
                if(_S1572)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1573 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1573 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1266;
                }
                float3  _S1574 = pathColor(throughput_8 * lit_0, spectral_weight_0, wavelength_9);
                return Shift_x24init_0(_S1574 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1528)
            {
                wrong_side_0 = _S1271 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1575 = !nee_0;
                if(_S1575)
                {
                    return _S1266;
                }
                bool _S1576 = (fcptWorldReadsPath());
                if(_S1576)
                {
                    float _S1577 = environmentPdf_0(r_8->dir);
                    uint _S1578 = b_6 + 1U;
                    FKSurface _S1579 = surface_13;
                    float3  _S1580 = skyColor_0((&ray_2)->unit_direction, r_8->dir, &_S1579, wavelength_9, _S1478, is_inside_7, _S1577, surface_13.random_state, _S1578);
                    float3  _S1581 = pathColor(throughput_8 * (_S1580 * r_8->radiance), spectral_weight_0, wavelength_9);
                    return Shift_x24init_0(_S1581 / make_float3 (r_8->jac), density_5 / r_8->jac);
                }
                float _S1582 = environmentPdf_0(r_8->dir);
                float3  _S1583 = skyBSDF((&ray_2)->unit_direction, r_8->dir, surface_13, _S1477, _S1478, is_inside_7, _S1582, surface_13.random_state);
                float3  _S1584 = pathColor(throughput_8 * _S1583 * r_8->radiance, spectral_weight_0, wavelength_9);
                return Shift_x24init_0(_S1584 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            uint _S1585 = extractBits_0(_S1267, 21U, 1U);
            bool _S1586 = nee_0 != (_S1585 == 1U);
            if(_S1586)
            {
                return _S1266;
            }
            throughput_7 = throughput_8;
            density_4 = density_5;
        }
        else
        {
            if(replay_1)
            {
                viewed_1 = _S1521;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1587 = !scatter_2;
                if(_S1587)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1588 = _S1270 != 1U;
                    if(_S1588)
                    {
                        refracted_4 = _S1270 != 3U;
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
                bool _S1589 = _S1270 == 2U;
                if(_S1589)
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
                    passes_0 = _S1271 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1483)
                    {
                        return _S1266;
                    }
                    uint _S1590 = stream(_S1293, b_6 + 448U);
                    FKRay _S1591 = ray_2;
                    FKSurface _S1592 = surface_13;
                    ShadowContext _S1593 = context_5;
                    SkySample _S1594 = sampleSky_0(&_S1591, &_S1592, wavelength_9, _S1478, is_inside_7, _S1590, surface_13.random_state, &_S1593);
                    float3  _S1595 = pathColor(throughput_6 * _S1594.color, spectral_weight_0, wavelength_9);
                    return Shift_x24init_0(_S1595, 1.0f);
                }
                if(_S1589)
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
                    float _S1596 = rgb_to_greyscale(light_3.radiance);
                    bool _S1597 = !(_S1596 > 0.0f);
                    if(_S1597)
                    {
                        return _S1266;
                    }
                    float3  _S1598 = pathColor(throughput_6 * lit_0, spectral_weight_0, wavelength_9);
                    return Shift_x24init_0(_S1598, 1.0f);
                }
                if(_S1280)
                {
                    passes_0 = _S1271 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1416;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float3  _S1599 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_9);
                    return Shift_x24init_0(_S1599, 1.0f);
                }
                if(_S1280)
                {
                    passes_0 = _S1271 == 1U;
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
                    float3  _S1600 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_9);
                    return Shift_x24init_0(_S1600, 1.0f);
                }
                return _S1266;
            }
            else
            {
                if(_S1492)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1601 = b_6 > 0U;
                    if(_S1601)
                    {
                        Reservoir candidate_5 = chain_0;
                        if(_S1507)
                        {
                            float3  _S1602 = safeDivide(throughput_6 * emission_1, chain_throughput_0);
                            (&candidate_5)->radiance = _S1602;
                        }
                        else
                        {
                            if(_S1453)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1603 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_9);
                        Reservoir _S1604 = withEnd(candidate_5, 1U, b_6, _S1603);
                        offer(sel_7, _S1604, _S1603 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1605 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_9);
                        float3  _S1606 = sel_7->glow + _S1605;
                        sel_7->glow = _S1606;
                    }
                    if(nee_0)
                    {
                        float3  _S1607 = pathColor(throughput_6 * lit_0, spectral_weight_0, wavelength_9);
                        Reservoir candidate_6 = chain_0;
                        if(_S1507)
                        {
                            float3  _S1608 = safeDivide(_S1607, chain_throughput_0);
                            (&candidate_6)->radiance = _S1608;
                        }
                        else
                        {
                            if(_S1453)
                            {
                                candidate_6 = here_0;
                                uint _S1609 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1609;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1610 = insertBits_0(_S1295, b_6 + 1U, 5U, 5U);
                                uint _S1611 = insertBits_0(_S1610, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1611;
                            }
                        }
                        Reservoir _S1612 = withEnd(candidate_6, 0U, b_6, _S1607);
                        offer(sel_7, _S1612, _S1607 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1483)
                        {
                            _S1566 = false;
                        }
                        else
                        {
                            bool _S1613 = environmentMapped_0();
                            _S1566 = _S1613;
                        }
                    }
                    else
                    {
                        _S1566 = false;
                    }
                    if(_S1566)
                    {
                        uint _S1614 = (fcptMaxBounces());
                        _S1567 = b_6 < _S1614;
                    }
                    else
                    {
                        _S1567 = false;
                    }
                    if(_S1567)
                    {
                        uint _S1615 = stream(_S1293, b_6 + 448U);
                        FKRay _S1616 = ray_2;
                        FKSurface _S1617 = surface_13;
                        ShadowContext _S1618 = context_5;
                        SkySample _S1619 = sampleSky_0(&_S1616, &_S1617, wavelength_9, _S1478, is_inside_7, _S1615, surface_13.random_state, &_S1618);
                        float3  _S1620 = pathColor(throughput_6 * _S1619.color, spectral_weight_0, wavelength_9);
                        Reservoir candidate_7 = chain_0;
                        if(_S1507)
                        {
                            float3  _S1621 = safeDivide(_S1620, chain_throughput_0);
                            (&candidate_7)->radiance = _S1621;
                        }
                        else
                        {
                            if(_S1453)
                            {
                                candidate_7 = here_0;
                                uint _S1622 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1622;
                                (&candidate_7)->dir = _S1619.dir;
                                (&candidate_7)->radiance = _S1619.radiance;
                            }
                            else
                            {
                                uint _S1623 = insertBits_0(_S1295, b_6 + 1U, 5U, 5U);
                                uint _S1624 = insertBits_0(_S1623, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1624;
                            }
                        }
                        Reservoir _S1625 = withEnd(candidate_7, 4U, b_6, _S1620);
                        offer(sel_7, _S1625, _S1620 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                }
            }
            throughput_7 = throughput_6;
            density_4 = density_2;
        }
        bool _S1626;
        bool _S1627;
        bool _S1628;
        bool straight_0;
        bool _S1629;
        bool _S1630;
        bool _S1631;
        bool _S1632;
        bool _S1633;
        bool _S1634;
        bool _S1635;
        bool _S1636;
        bool _S1637;
        bool _S1638;
        bool _S1639;
        bool _S1640;
        bool _S1641;
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
                viewed_1 = _S1521;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1642 = extractBits_0(_S1267, 15U, 3U);
            uint _S1643 = extractBits_0(_S1267, 18U, 3U);
            uint _S1644 = _slang_select(_S1520, _S1643,_S1642);
            float3  _S1645 = r_8->dir;
            bool refracted_5 = _S1644 == 1U;
            SampleBSDF _S1646 = SampleBSDF_x24init_0(_S1265, _S1265, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1646;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1647 = extractBits_0(_S1267, 22U, 1U);
                bool _S1648 = is_inside_7 != (_S1647 == 1U);
                if(_S1648)
                {
                    return _S1266;
                }
                bool _S1649 = _S1270 == 1U;
                if(_S1649)
                {
                    float3  _S1650 = (fcptHitPosition((_S1282)));
                    throughput_9 = _S1650;
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
                    BSDFMaterial _S1651 = _S1477;
                    bool _S1652 = isTranslucent_0(&_S1651);
                    if(_S1652)
                    {
                        refracted_4 = _S1644 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1653 = throughput_9 - (&ray_2)->origin;
                        float3  _S1654 = _slang_select(_S1649, _S1653,_S1645);
                        wrong_side_0 = (dot_0(_S1454.smooth_n, _S1654) * _S1455) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1649)
                {
                    float3  _S1655 = (&ray_2)->origin;
                    FKSurface _S1656 = surface_13;
                    float3  _S1657 = - _S1454.smooth_n;
                    bool _S1658 = is_inside_7 != refracted_4;
                    float3  _S1659 = _slang_select(_S1658, _S1657,_S1454.smooth_n);
                    float3  _S1660 = throughput_9 - (_S1655 + make_float3 (_S1656.geometry_offset) * _S1659);
                    float3  _S1661 = ((((_S1660)) * make_float3(rnorm3df(((_S1660)).x, ((_S1660)).y, ((_S1660)).z))));
                    reconnection_1 = _S1661;
                }
                else
                {
                    reconnection_1 = _S1645;
                }
                if(_S1483)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1662 = wrongSide_0(is_inside_7, refracted_4, reconnection_1, surface_13.geometry_n);
                    wrong_side_0 = _S1662;
                }
                if(wrong_side_0)
                {
                    return _S1266;
                }
                float3  _S1663 = throughput_9;
                throughput_9 = reconnection_1;
                b_9 = _S1644;
                wrong_side_0 = false;
                reconnection_1 = _S1663;
            }
            else
            {
                bool _S1664 = !_S1520;
                if(_S1664)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1665;
                    if(_S1483)
                    {
                        SampleBSDF _S1666 = (fcptSampleHair((surface_13.hair), (_S1477.albedo), (_S1477.specular_tint), ((&ray_2)->unit_direction), (surface_13.random_state)));
                        _S1665 = _S1666;
                    }
                    else
                    {
                        SampleBSDF _S1667 = sampleBSDF((&ray_2)->unit_direction, _S1454.smooth_n, _S1477, _S1478.x, _S1478.y, surface_13.random_state, _S1537);
                        _S1665 = _S1667;
                    }
                    bsdf_sampled_0 = _S1665;
                    if(_S1483)
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
                            return _S1266;
                        }
                        break;
                    }
                    if(_S1483)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1668 = wrongSide_0(is_inside_7, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_13.geometry_n);
                        wrong_side_0 = _S1668;
                    }
                    if(wrong_side_0)
                    {
                        _S1566 = (_S1477.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1566 = false;
                    }
                    if(_S1566)
                    {
                        SampleBSDF _S1669 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_13.geometry_n, _S1477, _S1478.x, _S1478.y, (&bsdf_sampled_0)->random_state, _S1537);
                        (&bsdf_sampled_0)->unit_direction = _S1669.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1669.refracted;
                        (&bsdf_sampled_0)->throughput = _S1669.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1670 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_13.geometry_n)) * surface_13.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1670;
                        }
                    }
                    uint _S1671 = (&bsdf_sampled_0)->lobe;
                    float3  _S1672 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1673 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1674 = (&bsdf_sampled_0)->pdf;
                    float _S1675 = _slang_select(wrong_side_0, 0.0f,_S1674);
                    (&lobe_5)->pdf = _S1675;
                    throughput_9 = _S1672;
                    b_9 = _S1671;
                    refracted_4 = _S1673;
                }
                else
                {
                    throughput_9 = _S1645;
                    b_9 = _S1644;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1566 = true;
            }
            else
            {
                _S1566 = _S1520;
            }
            float3  chain_throughput_1;
            if(_S1566)
            {
                if(_S1483)
                {
                    SampleBSDF _S1676 = (fcptConnectHair((surface_13.hair), (_S1477.albedo), (_S1477.specular_tint), ((&ray_2)->unit_direction), (throughput_9)));
                    lobe_5 = _S1676;
                }
                else
                {
                    float3  _S1677 = (&ray_2)->unit_direction;
                    float3  _S1678 = negate_0(_S1677);
                    float _S1679 = sign_0(_S1455);
                    float3  _S1680 = _S1454.smooth_n * make_float3 (_S1679);
                    float _S1681 = dot_0(_S1680, throughput_9);
                    float _S1682 = _S1477.roughness;
                    float _S1683 = _S1682 * _S1682;
                    AnisotropicFrame _S1684 = anisotropicFrame(_S1477, _S1680);
                    SheenProfile _S1685 = sheenProfile(_S1678, _S1680, _S1477);
                    float3  _S1686 = reflectedHalf(_S1677, throughput_9);
                    bool _S1687 = b_9 == 1U;
                    if(_S1687)
                    {
                        float3  _S1688 = refractedHalf(_S1677, throughput_9, _S1454.smooth_n, _S1478.x, _S1478.y);
                        throughput_10 = _S1688;
                    }
                    else
                    {
                        throughput_10 = _S1686;
                    }
                    bool _S1689 = b_9 == 0U;
                    if(_S1689)
                    {
                        _S1567 = true;
                    }
                    else
                    {
                        _S1567 = b_9 == 6U;
                    }
                    if(_S1567)
                    {
                        float3  _S1690 = sampledHalf(_S1678, _S1680, _S1683, _S1684, surface_13.random_state);
                        throughput_11 = _S1690;
                    }
                    else
                    {
                        throughput_11 = throughput_10;
                    }
                    float _S1691 = _S1478.x;
                    float _S1692 = _S1478.y;
                    Weights _S1693 = lobeWeights(_S1677, _S1678, _S1680, throughput_11, _S1684, _S1685, _S1477, _S1691, _S1692);
                    float _S1694 = (F32_abs((_S1455)));
                    float _S1695 = vndfPDF(_S1678, throughput_11, _S1680, _S1694, _S1683, _S1684, _S1693.v_dot_h);
                    switch(b_9)
                    {
                    case 0U:
                        {
                            float _S1696 = diffusePDF(_S1681, _S1694, _S1477, _S1693);
                            float3  _S1697 = diffuseBSDF(throughput_9, _S1680, _S1477, _S1693);
                            density_6 = _S1696;
                            chain_throughput_1 = _S1697;
                            break;
                        }
                    case 1U:
                        {
                            float _S1698 = refractPDF(dot_0(throughput_9, throughput_11), _S1695, _S1693, _S1691, _S1692);
                            float3  _S1699 = refractBSDF(throughput_9, _S1680, _S1683, _S1684, _S1477, _S1693);
                            density_6 = _S1698;
                            chain_throughput_1 = _S1699;
                            break;
                        }
                    case 4U:
                        {
                            float _S1700 = sheenVelvetPDF(_S1681, _S1694, _S1693);
                            float3  _S1701 = sheenVelvetBSDF(throughput_9, _S1678, _S1680, _S1477, _S1693);
                            density_6 = _S1700;
                            chain_throughput_1 = _S1701;
                            break;
                        }
                    case 6U:
                        {
                            ToonProfile _S1702 = toonProfile(_S1678, _S1680, _S1477);
                            float _S1703 = toonPDF(throughput_9, _S1680, _S1702, _S1693);
                            float3  _S1704 = toonBSDF(throughput_9, _S1680, _S1702, _S1693);
                            density_6 = _S1703;
                            chain_throughput_1 = _S1704;
                            break;
                        }
                    default:
                        {
                            float _S1705 = reflectPDF(_S1695, _S1693);
                            float3  _S1706 = reflectBSDF(throughput_9, _S1680, _S1683, _S1684, _S1693);
                            density_6 = _S1705;
                            chain_throughput_1 = _S1706;
                            break;
                        }
                    }
                    bool _S1707 = density_6 > 0.0f;
                    if(_S1707)
                    {
                        SampleBSDF _S1708 = SampleBSDF_x24init_0(throughput_9, chain_throughput_1, surface_13.random_state, _S1687, b_9, density_6);
                        lobe_5 = _S1708;
                    }
                }
            }
            bool _S1709 = b_9 == 0U;
            if(_S1709)
            {
                _S1567 = true;
            }
            else
            {
                _S1567 = b_9 == 4U;
            }
            if(_S1567)
            {
                _S1626 = true;
            }
            else
            {
                _S1626 = b_9 == 6U;
            }
            if(_S1483)
            {
                _S1627 = false;
            }
            else
            {
                bool _S1710 = !_S1626;
                if(_S1710)
                {
                    bool _S1711 = (_S1477.roughness) == 0.0f;
                    if(_S1711)
                    {
                        _S1627 = true;
                    }
                    else
                    {
                        bool _S1712 = b_9 == 1U;
                        if(_S1712)
                        {
                            _S1627 = (_S1478.x) == (_S1478.y);
                        }
                        else
                        {
                            _S1627 = false;
                        }
                    }
                }
                else
                {
                    _S1627 = false;
                }
            }
            bool _S1713 = !_S1483;
            if(_S1713)
            {
                _S1628 = b_9 == 1U;
            }
            else
            {
                _S1628 = false;
            }
            if(_S1628)
            {
                straight_0 = (_S1477.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1629 = _S1713;
            }
            else
            {
                _S1629 = false;
            }
            if(_S1629)
            {
                _S1630 = b_9 == 1U;
            }
            else
            {
                _S1630 = false;
            }
            if(_S1630)
            {
                _S1631 = (_S1478.x) == (_S1478.y);
            }
            else
            {
                _S1631 = false;
            }
            BSDFMaterial _S1714 = _S1477;
            bool _S1715 = isTranslucent_0(&_S1714);
            if(_S1715)
            {
                _S1632 = _S1709;
            }
            else
            {
                _S1632 = false;
            }
            if(_S1632)
            {
                _S1633 = (dot_0(throughput_9, surface_13.geometry_n)) < 0.0f;
            }
            else
            {
                _S1633 = false;
            }
            if(nee_0)
            {
                _S1634 = !_S1627;
            }
            else
            {
                _S1634 = false;
            }
            if(_S1634)
            {
                _S1635 = !wrong_side_0;
            }
            else
            {
                _S1635 = false;
            }
            if(_S1635)
            {
                float _S1716 = (&lobe_5)->pdf;
                float3  _S1717 = (&ray_2)->origin;
                float3  _S1718 = _slang_select(_S1488, _S1265,_S1454.smooth_n);
                float3  _S1719 = (&ray_2)->origin;
                FKSurface _S1720 = surface_13;
                float3  _S1721 = - _S1454.smooth_n;
                float3  _S1722 = _slang_select(_S1633, _S1721,_S1454.smooth_n);
                NEEVertex _S1723 = NEEVertex_x24init_0(false, _S1716, _S1717, _S1718, _S1719 + make_float3 (_S1720.geometry_offset) * _S1722);
                nee_vertex_0 = _S1723;
            }
            else
            {
                if(_S1483)
                {
                    _S1636 = true;
                }
                else
                {
                    bool _S1724 = b_9 != 1U;
                    if(_S1724)
                    {
                        _S1636 = true;
                    }
                    else
                    {
                        _S1636 = (_S1478.x) != (_S1478.y);
                    }
                }
                if(_S1636)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1725 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1725)
            {
                if(_S1626)
                {
                    _S1636 = true;
                }
                else
                {
                    _S1636 = ((&lobe_5)->pdf * (&prev_0)->cos / ((&hit_4)->distance * (&hit_4)->distance) * threshold_0) <= 1.0f;
                }
            }
            else
            {
                _S1636 = false;
            }
            bool _S1726 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1726)
            {
                if(_S1626)
                {
                    _S1637 = true;
                }
                else
                {
                    _S1637 = (_S1477.roughness) >= 0.20000000298023224f;
                }
            }
            else
            {
                _S1637 = false;
            }
            if(_S1520)
            {
                bool _S1727 = !_S1636;
                if(_S1727)
                {
                    return _S1266;
                }
                bool _S1728 = _S1271 != 1U;
                if(_S1728)
                {
                    _S1638 = _S1271 != 2U;
                }
                else
                {
                    _S1638 = false;
                }
                if(_S1638)
                {
                    float _S1729 = (&lobe_5)->pdf;
                    float _S1730 = _slang_select(nee_0, _S1729,0.0f);
                    float _S1731 = escapeWeight_0(_S1730, _S1645);
                    if(_S1528)
                    {
                        passes_0 = _S1277;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1732 = _slang_select(passes_0, _S1731,1.0f);
                    return Shift_x24init_0(throughput_7 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_8->radiance * make_float3 (_S1732) / make_float3 (r_8->jac), density_4 * (&lobe_5)->pdf / r_8->jac);
                }
                float3  _S1733 = throughput_7 * make_float3 ((&lobe_5)->pdf);
                float _S1734 = density_4 * (&lobe_5)->pdf;
                throughput_10 = _S1733;
                density_6 = _S1734;
            }
            else
            {
                throughput_10 = throughput_7;
                density_6 = density_4;
            }
            uint _S1735 = (fcptLayers((hit_4)));
            bool _S1736 = _S1735 > 1U;
            if(_S1736)
            {
                _S1638 = (b_9 == 1U) != passes_0;
            }
            else
            {
                _S1638 = false;
            }
            if(viewed_1)
            {
                _S1639 = _S1638;
            }
            else
            {
                _S1639 = false;
            }
            if(_S1639)
            {
                return _S1266;
            }
            if(replay_1)
            {
                _S1640 = b_6 <= _S1281;
            }
            else
            {
                _S1640 = false;
            }
            if(_S1640)
            {
                _S1641 = _S1453;
            }
            else
            {
                _S1641 = false;
            }
            bool _S1737;
            if(_S1641)
            {
                _S1737 = _S1636;
            }
            else
            {
                _S1737 = false;
            }
            bool _S1738;
            if(_S1737)
            {
                _S1738 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1738 = !_S1637;
                }
                else
                {
                    _S1738 = false;
                }
            }
            if(_S1738)
            {
                return _S1266;
            }
            if(viewed_1)
            {
                float3  _S1739 = throughput_10 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1740 = (&lobe_5)->pdf;
                throughput_11 = _S1739;
                sky_pdf_2 = _S1740;
            }
            else
            {
                float3  _S1741 = throughput_10 * max_0((&lobe_5)->throughput, _S1265);
                throughput_11 = _S1741;
                sky_pdf_2 = density_6;
            }
            bool _S1742;
            if(_S1492)
            {
                _S1742 = !_S1507;
            }
            else
            {
                _S1742 = false;
            }
            bool _S1743;
            if(_S1742)
            {
                _S1743 = _S1453;
            }
            else
            {
                _S1743 = false;
            }
            bool _S1744;
            if(_S1743)
            {
                _S1744 = _S1636;
            }
            else
            {
                _S1744 = false;
            }
            if(_S1744)
            {
                chain_0 = here_0;
                uint _S1745 = insertBits_0((&chain_0)->path, b_9, 18U, 3U);
                uint _S1746 = _slang_select(nee_0, 1U,0U);
                uint _S1747 = insertBits_0(_S1745, _S1746, 21U, 1U);
                (&chain_0)->path = _S1747;
                float _S1748 = (&chain_0)->jac * (&lobe_5)->pdf;
                (&chain_0)->jac = _S1748;
                (&chain_0)->dir = throughput_9;
                chain_throughput_1 = throughput_11;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1749 = surface_13;
            Vertex _S1750 = Vertex_x24init_0(_S1637, b_9, (&lobe_5)->pdf, (F32_abs((dot_0(surface_13.geometry_n, throughput_9)))), is_inside_7);
            prev_0 = _S1750;
            float _S1751 = (&lobe_5)->pdf;
            bool _S1752 = b_9 == 1U;
            bool _S1753;
            if(_S1752)
            {
                _S1753 = (_S1478.x) == (_S1478.y);
            }
            else
            {
                _S1753 = false;
            }
            float sky_pdf_3 = _slang_select(_S1753, sky_pdf_0,_S1751);
            float _S1754 = _slang_select(_S1483, 0.0f,sky_pdf_3);
            float _S1755 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * (&lobe_5)->pdf))))), (3.14159274101257324f)));
            bool _S1756 = !_S1627;
            float _S1757 = _slang_select(_S1756, _S1755,0.0f);
            float _S1758 = spread_1 + _S1757;
            bool _S1759;
            if(refracted_4)
            {
                _S1759 = !_S1633;
            }
            else
            {
                _S1759 = false;
            }
            bool is_inside_8;
            if(_S1759)
            {
                bool _S1760 = !is_inside_7;
                is_inside_8 = _S1760;
            }
            else
            {
                is_inside_8 = is_inside_7;
            }
            FKSurface _S1761 = surface_13;
            bool _S1762 = boundsVolume_0(&_S1761);
            bool _S1763;
            if(_S1762)
            {
                _S1763 = !_S1638;
            }
            else
            {
                _S1763 = false;
            }
            if(_S1763)
            {
                FKSurface faced_2 = surface_13;
                float3  _S1764 = - _S1749.geometry_n;
                float3  _S1765 = _slang_select(turned_1, _S1764,_S1749.geometry_n);
                (&faced_2)->geometry_n = _S1765;
                FKMedium _S1766 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1767 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1768 = faced_2;
                FKMedium _S1769 = _S1766;
                FKMedium _S1770 = _S1767;
                MediumSides _S1771 = mediumSides_0(&_S1768, &_S1769, filling_2, (&ray_2)->unit_direction, &_S1770);
                bool _S1772 = ((dot_0(throughput_9, _S1749.geometry_n)) > 0.0f) == ((dot_0(_S1749.geometry_n, (&faced_2)->geometry_n)) > 0.0f);
                float3  _S1773 = _slang_select(_S1772, _S1771.front.scatter,_S1771.behind.scatter);
                scatter_in_0 = _S1773;
                float3  _S1774 = scatter_in_0;
                float _S1775 = upsample(scatter_in_0, wavelength_9);
                float3  _S1776 = make_float3 (_S1775);
                float3  _S1777 = _slang_select(_S1515, _S1776,_S1774);
                scatter_in_0 = _S1777;
                float3  _S1778 = _slang_select(_S1772, _S1771.front.extinction,_S1771.behind.extinction);
                extinction_in_0 = _S1778;
                float3  _S1779 = extinction_in_0;
                float _S1780 = upsample(extinction_in_0, wavelength_9);
                float3  _S1781 = make_float3 (_S1780);
                float3  _S1782 = _slang_select(_S1515, _S1781,_S1779);
                extinction_in_0 = _S1782;
                float _S1783 = _slang_select(_S1772, _S1771.front.g,_S1771.behind.g);
                g_in_0 = _S1783;
                uint _S1784 = _S1771.fillings.x;
                uint _S1785 = _S1771.fillings.y;
                uint _S1786 = _slang_select(_S1772, _S1785,_S1784);
                bool _S1787 = (fcptVaryingUsed());
                uint _S1788 = _slang_select(_S1787, _S1786,4294967295U);
                filling_2 = _S1788;
            }
            (&ray_2)->unit_direction = throughput_9;
            bool _S1789 = !_S1638;
            if(_S1789)
            {
                FKSurface _S1790 = surface_13;
                float _S1791 = _slang_select(straight_0, 0.0f,_S1790.geometry_offset);
                float3  _S1792 = - _S1454.smooth_n;
                bool _S1793 = is_inside_8 != _S1633;
                float3  _S1794 = _slang_select(_S1793, _S1792,_S1454.smooth_n);
                float3  _S1795 = (&ray_2)->origin + make_float3 (_S1791) * _S1794;
                (&ray_2)->origin = _S1795;
            }
            throughput_10 = throughput_11;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1638;
            viewed_1 = _S1631;
            sky_pdf_2 = _S1754;
            spread_4 = _S1758;
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
            spread_4 = spread_1;
            straight_0 = false;
            is_inside_6 = is_inside_7;
        }
        float density_7;
        if(_S1492)
        {
            if(_S1416)
            {
                float3  _S1796 = pathColor(throughput_10 * emission_1, spectral_weight_0, wavelength_9);
                Reservoir candidate_8 = chain_0;
                uint _S1797 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1798 = _S1797 == 1U;
                if(_S1798)
                {
                    float3  _S1799 = safeDivide(_S1796, chain_throughput_0);
                    (&candidate_8)->radiance = _S1799;
                }
                Reservoir _S1800 = withEnd(candidate_8, 2U, b_6, _S1796);
                offer(sel_7, _S1800, _S1796 * make_float3 (scale_3) / make_float3 (density_6));
            }
            if(_S1416)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1801 = survivalProbability(abs_0(throughput_10), density_6);
                density_7 = _S1801;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1802 = stream(_S1293, b_6 + 128U);
            Random _S1803 = pcg(_S1802);
            bool _S1804 = density_7 < (_S1803.value);
            if(_S1804)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1805 = (fcptMaxBounces());
                wrong_side_0 = b_6 >= _S1805;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1806 = density_6 * density_7;
            density_7 = _S1806;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1807 = layer_0 ^ 1U;
        uint _S1808 = _slang_select(passes_0, _S1807,0U);
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
            uint _S1809 = b_9 + 1U;
            b_6 = _S1809;
            layer_0 = _S1808;
            continue;
        }
        FKRay _S1810 = ray_2;
        float _S1811 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_1)
        {
            refracted_4 = _S1521;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S1270 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1812 = _slang_select(wrong_side_0, _S1811,4.294967296e+09f);
        bool _S1813 = !_S1483;
        if(straight_0)
        {
            _S1566 = true;
        }
        else
        {
            _S1566 = _S1483;
        }
        FKHit _S1814;
        if(_S1566)
        {
            _S1814 = hit_4;
        }
        else
        {
            _S1814 = _S1538;
        }
        FKHit _S1815 = (fcptTraverseInstanceBVH((_S1810), (_S1423), (_S1812), (_S1813), (_S1814), (viewed_1)));
        hit_4 = _S1815;
        if(replay_1)
        {
            _S1567 = _S1521;
        }
        else
        {
            _S1567 = false;
        }
        if(_S1567)
        {
            _S1626 = _S1270 == 1U;
        }
        else
        {
            _S1626 = false;
        }
        if(_S1626)
        {
            _S1627 = ((&hit_4)->instance_index) == (_S1282.instance_index);
        }
        else
        {
            _S1627 = false;
        }
        if(_S1627)
        {
            _S1628 = ((&hit_4)->triangle_index) == (_S1282.triangle_index);
        }
        else
        {
            _S1628 = false;
        }
        if(_S1628)
        {
            (&hit_4)->uv = _S1282.uv;
            float _S1816 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S1816;
        }
        if(replay_1)
        {
            _S1629 = _S1521;
        }
        else
        {
            _S1629 = false;
        }
        if(_S1629)
        {
            _S1630 = _S1270 == 3U;
        }
        else
        {
            _S1630 = false;
        }
        if(_S1630)
        {
            _S1631 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1631 = false;
        }
        if(_S1631)
        {
            return _S1266;
        }
        Reservoir _S1817 = chain_0;
        uint _S1818 = filling_2;
        for(;;)
        {
            bool _S1819 = (fcptVaryingUsed());
            if(_S1819)
            {
                _S1632 = _S1818 != 4294967295U;
            }
            else
            {
                _S1632 = false;
            }
            float _S1820;
            if(_S1632)
            {
                float _S1821 = (fcptMajorant((_S1818)));
                _S1820 = _S1821;
            }
            else
            {
                _S1820 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_1)
            {
                _S1633 = _S1521;
            }
            else
            {
                _S1633 = false;
            }
            if(_S1633)
            {
                _S1634 = _S1270 == 1U;
            }
            else
            {
                _S1634 = false;
            }
            if(_S1634)
            {
                _S1635 = _S1820 > 0.0f;
            }
            else
            {
                _S1635 = false;
            }
            if(_S1635)
            {
                ended_0 = _S1266;
                sky_pdf_1 = sky_pdf_2;
                spread_2 = spread_4;
                width_4 = width_3;
                density_3 = density_7;
                throughput_11 = throughput_10;
                b_9 = b_6;
                _S1636 = true;
                break;
            }
            bool _S1822 = (&prev_0)->rough;
            if(_S1822)
            {
                _S1636 = !(_S1820 > 0.0f);
            }
            else
            {
                _S1636 = false;
            }
            (&prev_0)->rough = _S1636;
            uint _S1823 = b_6 + 320U;
            bool _S1824 = b_6 == 4294967295U;
            uint _S1825 = _slang_select(_S1824, 384U,_S1823);
            uint _S1826 = stream(_S1293, _S1825);
            uint tracking_1 = _S1826;
            weight_2 = throughput_3;
            glowed_0 = _S1265;
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
                    _S1264 = int(2);
                    break;
                }
                uint _S1827 = b_9 + 320U;
                bool _S1828 = b_9 == 4294967295U;
                uint _S1829 = _slang_select(_S1828, 384U,_S1827);
                uint _S1830 = stream(_S1293, _S1829);
                Random _S1831 = pcg(_S1830);
                float _S1832 = - (F32_log((1.0f - _S1831.value))) / _S1820;
                if(_S1632)
                {
                    float3  _S1833 = (&ray_2)->origin;
                    float3  _S1834 = (&ray_2)->unit_direction;
                    float _S1835 = (&hit_4)->distance;
                    uint _S1836 = _slang_select(_S1828, 0U,b_9);
                    uint _S1837 = (&prev_0)->lobe;
                    uint _S1838 = _slang_select(_S1828, 3U,_S1837);
                    float _S1839 = (fcptTrackMedium((_S1818), (_S1833), (_S1834), (_S1835), (&tracking_1), (&weight_2), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1836), (_S1838), (_S1828)));
                    spread_3 = _S1839;
                }
                else
                {
                    spread_3 = _S1832;
                }
                bool _S1840 = !(spread_3 < ((&hit_4)->distance));
                if(_S1840)
                {
                    _S1264 = int(2);
                    break;
                }
                if(_S1632)
                {
                    _S1637 = _S1492;
                }
                else
                {
                    _S1637 = false;
                }
                if(_S1637)
                {
                    float3  _S1841 = pathColor(throughput_11 * glowed_0, spectral_weight_0, wavelength_9);
                    float3  _S1842 = _S1841 / make_float3 (density_3);
                    float3  _S1843 = sel_7->glow + _S1842;
                    sel_7->glow = _S1843;
                }
                else
                {
                }
                glowed_0 = _S1265;
                uint b_10 = b_9 + 1U;
                float3  _S1844 = (&ray_2)->origin + make_float3 (spread_3) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1844;
                float3  _S1845 = flightWeight_0(scatter_in_0, extinction_in_0, _S1820, spread_3, true);
                float3  _S1846 = weight_2;
                float _S1847 = upsample(weight_2, wavelength_9);
                float3  _S1848 = make_float3 (_S1847);
                float3  _S1849 = _slang_select(_S1515, _S1848,_S1846);
                float3  _S1850 = _slang_select(_S1632, _S1849,_S1845);
                float3  throughput_12 = throughput_11 * _S1850;
                uint _S1851 = stream(_S1293, b_10 + 320U);
                tracking_1 = _S1851;
                weight_2 = throughput_3;
                float width_7 = width_4 + spread_2 * spread_3;
                float _S1852 = spread_2 + 3.14159274101257324f;
                if(_S1492)
                {
                    _S1638 = true;
                }
                else
                {
                    bool _S1853 = b_10 == _S1281;
                    if(_S1853)
                    {
                        _S1638 = !_S1632;
                    }
                    else
                    {
                        _S1638 = false;
                    }
                }
                TreeSample light_4;
                if(_S1638)
                {
                    float3  _S1854 = (&ray_2)->origin;
                    float3  _S1855 = (&ray_2)->unit_direction;
                    float3  _S1856 = (&ray_2)->unit_direction;
                    uint _S1857 = stream(_S1293, b_10 + 64U);
                    float3  _S1858 = extinction_in_0;
                    float3  _S1859 = extinction_in_0;
                    uint2  _S1860 = make_uint2 (_S1818);
                    float3  _S1861 = (&ray_2)->unit_direction;
                    uint _S1862 = arrivalLobe_0(b_10, (&prev_0)->lobe);
                    FKHit _S1863 = _S1538;
                    ShadowContext _S1864 = ShadowContext_x24init_0(_S1858, _S1859, _S1860, _S1861, b_10, _S1862, false, spread_3, width_7, &_S1863, false);
                    ShadowContext _S1865 = _S1864;
                    TreeSample _S1866 = sampleLightTree_0(_S1854, _S1855, _S1856, 0.0f, true, _S1857, &_S1865);
                    light_4 = _S1866;
                }
                else
                {
                    light_4 = _S1535;
                }
                float _S1867 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1868 = (fcptMaxBounces());
                bool _S1869 = b_10 < _S1868;
                if(_S1869)
                {
                    _S1639 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1639 = false;
                }
                float _S1870 = _slang_select(_S1639, _S1867,0.0f);
                float3  _S1871 = throughput_12 * light_4.radiance;
                float _S1872 = powerHeuristic(light_4.density, _S1870);
                float3  _S1873 = pathColor(_S1871 * make_float3 (_S1867 * _S1872), spectral_weight_0, wavelength_9);
                float3  _S1874 = _slang_select(_S1638, _S1873,_S1265);
                if(replay_1)
                {
                    _S1640 = b_10 == _S1281;
                }
                else
                {
                    _S1640 = false;
                }
                if(_S1640)
                {
                    bool _S1875 = _S1270 == 2U;
                    if(_S1875)
                    {
                        float _S1876 = resamplingTarget(_S1874);
                        _S1641 = _S1876 > 0.0f;
                    }
                    else
                    {
                        _S1641 = false;
                    }
                    if(_S1641)
                    {
                        Shift _S1877 = Shift_x24init_0(_S1874, 1.0f);
                        _S1264 = int(1);
                        ended_0 = _S1877;
                        spread_3 = _S1852;
                        width_5 = width_7;
                        throughput_9 = throughput_12;
                        b_7 = b_10;
                        break;
                    }
                    _S1264 = int(1);
                    ended_0 = _S1266;
                    spread_3 = _S1852;
                    width_5 = width_7;
                    throughput_9 = throughput_12;
                    b_7 = b_10;
                    break;
                }
                if(_S1492)
                {
                    Reservoir candidate_9 = _S1817;
                    uint _S1878 = extractBits_0(_S1817.path, 24U, 8U);
                    uint _S1879 = insertBits_0(0U, _S1878, 24U, 8U);
                    uint _S1880 = extractBits_0(_S1817.path, 10U, 2U);
                    bool _S1881 = _S1880 == 1U;
                    if(_S1881)
                    {
                        float3  _S1882 = safeDivide(_S1874, chain_throughput_0);
                        (&candidate_9)->radiance = _S1882;
                    }
                    else
                    {
                        uint _S1883 = insertBits_0(_S1879, b_10 + 1U, 5U, 5U);
                        uint _S1884 = insertBits_0(_S1883, 2U, 10U, 2U);
                        (&candidate_9)->path = _S1884;
                    }
                    Reservoir _S1885 = withEnd(candidate_9, 0U, b_10, _S1874);
                    offer(sel_7, _S1885, _S1874 * make_float3 (scale_3) / make_float3 (density_3));
                    float _S1886 = survivalProbability(abs_0(throughput_12), density_3);
                    uint _S1887 = stream(_S1293, b_10 + 128U);
                    Random _S1888 = pcg(_S1887);
                    bool _S1889 = _S1886 < (_S1888.value);
                    if(_S1889)
                    {
                        _S1641 = true;
                    }
                    else
                    {
                        uint _S1890 = (fcptMaxBounces());
                        _S1641 = b_10 >= _S1890;
                    }
                    if(_S1641)
                    {
                        _S1264 = int(1);
                        ended_0 = _S1266;
                        spread_3 = _S1852;
                        width_5 = width_7;
                        throughput_9 = throughput_12;
                        b_7 = b_10;
                        break;
                    }
                    float _S1891 = density_3 * _S1886;
                    density_3 = _S1891;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1892 = stream(_S1293, b_10);
                float3  _S1893 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1892, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1893;
                NEEVertex _S1894 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1265, (&ray_2)->origin);
                nee_vertex_0 = _S1894;
                Vertex _S1895 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_6);
                prev_0 = _S1895;
                float _S1896 = (&prev_0)->pdf;
                FKRay _S1897 = ray_2;
                FKHit _S1898 = (fcptTraverseInstanceBVH((_S1897), (true), (4.294967296e+09f), (false), (_S1538), (false)));
                hit_4 = _S1898;
                b_9 = b_10;
                throughput_11 = throughput_12;
                spread_2 = _S1852;
                width_4 = width_7;
                sky_pdf_1 = _S1896;
            }
            if(_S1264 != int(2))
            {
                spread_2 = spread_3;
                width_4 = width_5;
                throughput_11 = throughput_9;
                b_9 = b_7;
                _S1636 = true;
                break;
            }
            ended_0 = _S1266;
            _S1636 = false;
            break;
        }
        if(_S1636)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1637 = b_9 == b_6;
        }
        else
        {
            _S1637 = false;
        }
        bool _S1899 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S1899)
        {
            bool _S1900 = !(&nee_vertex_0)->none;
            float _S1901 = _slang_select(_S1900, sky_pdf_1,0.0f);
            float _S1902 = escapeWeight_0(_S1901, (&ray_2)->unit_direction);
            float3  _S1903 = environment_0((&ray_2)->unit_direction, b_9, (&prev_0)->lobe);
            float3  _S1904 = pathColor(throughput_11 * _S1903, spectral_weight_0, wavelength_9);
            if(replay_1)
            {
                bool _S1905 = b_9 == _S1281;
                if(_S1905)
                {
                    passes_0 = _S1270 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1904 * make_float3 (_S1902) / make_float3 (r_8->jac), density_3 / r_8->jac);
                }
                if(_S1280)
                {
                    passes_0 = _S1277;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_9 == _S1268;
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
                    return Shift_x24init_0(_S1904 * make_float3 (_S1902), 1.0f);
                }
                return _S1266;
            }
            Reservoir candidate_10 = chain_0;
            uint _S1906 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1907 = _S1906 == 1U;
            if(_S1907)
            {
                uint _S1908 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1909 = _S1908 == b_9;
                float _S1910 = _slang_select(_S1909, 1.0f,_S1902);
                float3  _S1911 = safeDivide(_S1904 * make_float3 (_S1910), chain_throughput_0);
                (&candidate_10)->radiance = _S1911;
            }
            else
            {
                bool _S1912 = (&prev_0)->rough;
                if(_S1912)
                {
                    uint _S1913 = insertBits_0(_S1295, b_9 + 1U, 5U, 5U);
                    uint _S1914 = insertBits_0(_S1913, 3U, 10U, 2U);
                    uint _S1915 = insertBits_0(_S1914, (&prev_0)->lobe, 15U, 3U);
                    bool _S1916 = (&prev_0)->inside;
                    uint _S1917 = _slang_select(_S1916, 1U,0U);
                    uint _S1918 = insertBits_0(_S1915, _S1917, 22U, 1U);
                    (&candidate_10)->path = _S1918;
                    (&candidate_10)->jac = (&prev_0)->pdf;
                    (&candidate_10)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1919 = _S1904 * make_float3 (_S1902);
            Reservoir _S1920 = withEnd(candidate_10, 3U, b_9, _S1919);
            offer(sel_7, _S1920, _S1919 * make_float3 (scale_3) / make_float3 (density_3));
            break;
        }
        float3  _S1921 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1921;
        bool _S1922 = (fcptVaryingUsed());
        if(_S1922)
        {
            _S1638 = filling_2 != 4294967295U;
        }
        else
        {
            _S1638 = false;
        }
        if(_S1638)
        {
            if(_S1492)
            {
                float3  _S1923 = pathColor(throughput_11 * glowed_0, spectral_weight_0, wavelength_9);
                float3  _S1924 = _S1923 / make_float3 (density_3);
                float3  _S1925 = sel_7->glow + _S1924;
                sel_7->glow = _S1925;
            }
            float3  _S1926 = throughput_11 * weight_2;
            throughput_9 = _S1926;
        }
        else
        {
            float3  _S1927 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S1928 = throughput_11 * _S1927;
            throughput_9 = _S1928;
        }
        float _S1929 = width_4 + spread_2 * (&hit_4)->distance;
        viewed_0 = _S1637;
        width_3 = _S1929;
        throughput_2 = throughput_9;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_1 = spread_2;
        uint _S1809 = b_9 + 1U;
        b_6 = _S1809;
        layer_0 = _S1808;
    }
    return _S1266;
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

__device__ Random normal_distribution(uint state_3)
{
    Random _S1930 = pcg(state_3);
    Random _S1931 = pcg(_S1930.state);
    float _S1932 = 6.28318548202514648f * _S1930.value;
    float _S1933 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S1931.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1931.state, _S1933 * (F32_cos((_S1932))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_4, float3  value_2)
{
    RandomSphere _S1934;
    (&_S1934)->state = state_4;
    (&_S1934)->value = value_2;
    return _S1934;
}

__device__ RandomSphere random_sphere(uint state_5)
{
    Random _S1935 = normal_distribution(state_5);
    Random _S1936 = normal_distribution(_S1935.state);
    Random _S1937 = normal_distribution(_S1936.state);
    float3  _S1938 = make_float3 (_S1935.value, _S1936.value, _S1937.value);
    float3  _S1939 = ((((_S1938)) * make_float3(rnorm3df(((_S1938)).x, ((_S1938)).y, ((_S1938)).z))));
    return RandomSphere_x24init_0(_S1937.state, _S1939);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_11)
{
    float3  _S1940 = p1_0 - p0_0;
    float3  _S1941 = p2_0 - p0_0;
    float2  _S1942 = uv1_0 - uv0_0;
    float2  _S1943 = uv2_0 - uv0_0;
    float _S1944 = _S1942.x;
    float _S1945 = _S1943.y;
    float _S1946 = _S1942.y;
    float _S1947 = _S1943.x;
    float _S1948 = _S1944 * _S1945 - _S1946 * _S1947;
    float _S1949 = 1.0f / _S1948;
    float3  t_24 = (_S1940 * make_float3 (_S1945) - _S1941 * make_float3 (_S1946)) * make_float3 (_S1949);
    float3  _S1950 = (_S1941 * make_float3 (_S1944) - _S1940 * make_float3 (_S1947)) * make_float3 (_S1949);
    float3  _S1951 = t_24 - n_11 * make_float3 (dot_0(n_11, t_24));
    float3  t_25 = ((((_S1951)) * make_float3(rnorm3df(((_S1951)).x, ((_S1951)).y, ((_S1951)).z))));
    bool _S1952 = (dot_0(cross_0(n_11, t_25), _S1950)) > 0.0f;
    float3  t_26;
    if(_S1952)
    {
        float3  _S1953 = negate_0(t_25);
        t_26 = _S1953;
    }
    else
    {
        t_26 = t_25;
    }
    float3  _S1954 = cross_0(n_11, t_26);
    return makeMatrix<float, 3, 3> (t_26, _S1954, n_11);
}

__device__ float3  tangentToWorldNormalMap(float3  v_10, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_10, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_4, float3  uvw_0, float3  position_0)
{
    float3  _S1955 = t1_0 - t0_0;
    float3  _S1956 = t2_2 - t0_0;
    float3  _S1957 = t2_2 - t1_0;
    float _S1958 = (F32_min((length_0(_S1955)), ((F32_min((length_0(_S1956)), (length_0(_S1957)))))));
    float3  _S1959 = make_float3 (distance_1(position_0, t0_0), distance_1(position_0, t1_0), distance_1(position_0, t2_2));
    float3  _S1960 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1961 = dot_0(geometry_n_4, _S1960);
    float3  _S1962 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1963 = dot_0(geometry_n_4, _S1962);
    float3  _S1964 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1965 = acos_0(abs_0(make_float3 (_S1961, _S1963, dot_0(geometry_n_4, _S1964))));
    float3  _S1966 = clamp_2(tan_0(_S1965), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S1959 * _S1966, uvw_0), 0.0f, _S1958 * 0.125f);
}

__device__ float3  straightThrough(float3  dir_15, float3  n_12, BSDFMaterial material_26)
{
    float3  _S1967 = negate_0(dir_15);
    float _S1968 = sign_0(dot_0(n_12, _S1967));
    float3  _S1969 = n_12 * make_float3 (_S1968);
    AnisotropicFrame _S1970 = anisotropicFrame(material_26, _S1969);
    bool _S1971 = (_S1970.alphas.x) > 0.0f;
    if(_S1971)
    {
        float _S1972 = material_26.transmission * (1.0f - material_26.metallic);
        float3  _S1973 = negate_0(_S1969);
        float3  _S1974 = anisotropicLocal(dir_15, _S1970.tangent, _S1973);
        float _S1975 = anisotropicG1(_S1974, _S1970.alphas);
        return make_float3 (_S1972 * _S1975) * material_26.albedo;
    }
    float _S1976 = material_26.transmission * (1.0f - material_26.metallic);
    float _S1977 = material_26.roughness;
    float _S1978 = smithG1(_S1977 * _S1977, (F32_abs((dot_0(n_12, dir_15)))));
    return make_float3 (_S1976 * _S1978) * material_26.albedo;
}

__device__ float hairRow(float3  in_dir_11, float3  t_27, float3  out_dir_3, uint p_14, float w_19, float alpha_10, uint nt_0)
{
    uint _S1979 = p_14 % 4U;
    float _S1980 = w_19 * HAIR_WIDTHS_0[_S1979];
    float _S1981 = (F32_asin((clamp_1(dot_0(out_dir_3, t_27), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_11, t_27), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1979] * alpha_10;
    return ((F32_asinh((_S1981 / _S1980))) / (F32_asinh((3.14159274101257324f / _S1980))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_12, float3  t_28, float3  out_dir_4, uint np_0)
{
    float3  _S1982 = worldToTangent(out_dir_4, t_28);
    float3  _S1983 = worldToTangent(in_dir_12, t_28);
    return (F32_frac((((F32_atan2((_S1982.z), (_S1982.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1983.z), (1.17549435082228751e-38f - _S1983.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_13, float3  t_29, uint p_15, float row_0, float column_0, float w_20, float alpha_11, uint nt_1, uint np_1)
{
    float3  _S1984 = worldToTangent(in_dir_13, t_29);
    uint _S1985 = p_15 % 4U;
    float _S1986 = w_20 * HAIR_WIDTHS_0[_S1985];
    float _S1987 = (F32_asin((clamp_1(dot_0(in_dir_13, t_29), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1985] * alpha_11 + _S1986 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1986))))));
    float _S1988 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1984.z), (1.17549435082228751e-38f - _S1984.x)));
    float _S1989 = (F32_cos((_S1987)));
    float3  _S1990 = tangentToWorld(make_float3 (_S1989 * (F32_cos((_S1988))), (F32_sin((_S1987))), _S1989 * (F32_sin((_S1988)))), t_29);
    return _S1990;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_13, BSDFMaterial material_27, float coverage_1)
{
    float3  _S1991;
    if((material_27.ior) == 1.0f)
    {
        float3  _S1992 = straightThrough(toward_1, n_13, material_27);
        _S1991 = _S1992;
    }
    else
    {
        _S1991 = make_float3 (0.0f);
    }
    return _S1991 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_8, Reservoir r_9, bool replay_2, float scale_4, Selection * sel_8)
{
    Domain _S1993 = dom_8;
    Reservoir _S1994 = r_9;
    Shift _S1995 = walk_0(&_S1993, &_S1994, replay_2, scale_4, sel_8);
    return _S1995;
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
