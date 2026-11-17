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
    Shift _S60;
    (&_S60)->f = f_0;
    (&_S60)->jac = jac_0;
    return _S60;
}

static __device__ Shift passWalk_0(Domain * dom_0, Reservoir * r_1, bool replay_0, float scale_0, Selection * sel_0)
{
    Shift _S61 = (fcptWalk((*dom_0), (*r_1), (replay_0), (scale_0), (sel_0)));
    return _S61;
}

static __device__ Shift passShift_0(Domain * dom_1, Reservoir * r_2)
{
    Selection _S62 = (Selection{});
    Selection sel_1 = _S62;
    bool _S63 = (r_2->w) <= 0.0f;
    if(_S63)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S64 = passWalk_0(dom_1, r_2, true, 0.0f, &sel_1);
    return _S64;
}

static __device__ uint queuedShift_0(uint3  workgroup_id_0, uint local_invocation_index_0)
{
    uint _S65 = workgroup_id_0.y * 65535U + workgroup_id_0.x;
    uint bin_0 = 0U;
    uint group_0 = _S65;
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
        uint _S66 = (fcptQueuedShifts((3U + bin_0)));
        uint _S67 = (_S66 + 63U) / 64U;
        bool _S68 = group_0 < _S67;
        if(_S68)
        {
            uint _S69 = group_0 * 64U + local_invocation_index_0;
            bool _S70 = _S69 < _S66;
            if(_S70)
            {
                uint _S71 = (fcptQueuedShifts((83U + start_0 + _S69)));
                return _S71;
            }
            return 4294967295U;
        }
        uint group_1 = group_0 - _S67;
        uint start_1 = start_0 + _S66;
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
        uint _S72 = (*bins_1)[t_4];
        bool _S73 = ((*bins_1)[t_4]) < 40U;
        if(_S73)
        {
            bin_2 = 0U;
            start_2 = 0U;
            for(;;)
            {
                if(bin_2 < _S72)
                {
                }
                else
                {
                    break;
                }
                uint _S74 = (fcptQueueCountLoad((bin_2)));
                uint start_3 = start_2 + _S74;
                uint bin_3 = bin_2 + 1U;
                bin_2 = bin_3;
                start_2 = start_3;
            }
            uint _S75 = (fcptQueueCursorAdd((_S72), (1U)));
            fcptQueueJobStore((start_2 + _S75), ((uint(p_3.x) | (uint(p_3.y) << 14U)) | (t_4 << 28U)));
        }
        uint t_5 = t_4 + 1U;
        t_4 = t_5;
    }
    bool _S76 = all_0(uint2 {global_invocation_id_0.x, global_invocation_id_0.y} == make_uint2 (0U));
    if(_S76)
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
            uint _S77 = (fcptQueueCountLoad((bin_2)));
            uint groups_0 = start_2 + (_S77 + 63U) / 64U;
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
    FKHit _S78;
    (&_S78)->uv = uv_0;
    (&_S78)->instance_index = instance_index_0;
    (&_S78)->triangle_index = triangle_index_0;
    (&_S78)->is_point_light = is_point_light_0;
    (&_S78)->distance = distance_0;
    return _S78;
}

static __device__ Domain Domain_x24init_0(float3  x0_0, float3  x1_0, FKHit * hit_0, float width_0, float spread_0)
{
    Domain _S79;
    (&_S79)->x0 = x0_0;
    (&_S79)->x1 = x1_0;
    (&_S79)->hit = *hit_0;
    (&_S79)->width = width_0;
    (&_S79)->spread = spread_0;
    return _S79;
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
    bool _S80 = all_1((a_0->x0) == (b_0->x0));
    bool _S81;
    if(_S80)
    {
        _S81 = ((&a_0->hit)->instance_index) == ((&b_0->hit)->instance_index);
    }
    else
    {
        _S81 = false;
    }
    if(_S81)
    {
        _S81 = ((&a_0->hit)->triangle_index) == ((&b_0->hit)->triangle_index);
    }
    else
    {
        _S81 = false;
    }
    if(_S81)
    {
        _S81 = all_0(((&a_0->hit)->uv) == ((&b_0->hit)->uv));
    }
    else
    {
        _S81 = false;
    }
    return _S81;
}

static __device__ bool temporalJob_0(int2  p_4, uint t_6, ShiftJob * job_2, bool target_1)
{
    bool _S82 = t_6 > 1U;
    bool _S83;
    if(_S82)
    {
        _S83 = true;
    }
    else
    {
        uint2  _S84 = (fcptRenderSize());
        int2  _S85 = make_int2 ((int)_S84.x, (int)_S84.y);
        _S83 = any_0(p_4 >= _S85);
    }
    if(_S83)
    {
        _S83 = true;
    }
    else
    {
        bool _S86 = (fcptSceneUnchanged());
        _S83 = _S86;
    }
    if(_S83)
    {
        return false;
    }
    int2  _S87 = (fcptLoadTemporalNeighbor((p_4)));
    bool _S88 = (_S87.x) < int(0);
    if(_S88)
    {
        return false;
    }
    bool _S89 = t_6 == 0U;
    if(_S89)
    {
        Reservoir _S90 = (fcptLoadReservoirPrevious((_S87)));
        job_2->r = _S90;
        bool _S91 = ((&job_2->r)->w) > 0.0f;
        if(_S91)
        {
            bool _S92 = !target_1;
            if(_S92)
            {
                _S83 = true;
            }
            else
            {
                bool _S93 = (fcptStoredDomainInitial((p_4), ((&job_2->r)->seed), (&job_2->dom)));
                _S83 = _S93;
            }
        }
        else
        {
            _S83 = false;
        }
        return _S83;
    }
    Reservoir _S94 = (fcptLoadReservoirInitial((p_4)));
    job_2->r = _S94;
    bool _S95 = !target_1;
    if(_S95)
    {
        bool _S96 = (fcptPreviousScenes());
        _S83 = _S96;
    }
    else
    {
        _S83 = false;
    }
    if(_S83)
    {
        return ((&job_2->r)->w) > 0.0f;
    }
    Domain _S97 = (fcptPreviousDomain((_S87), ((&job_2->r)->seed)));
    job_2->dom = _S97;
    float3  _S98 = make_float3 (0.0f);
    FKHit _S99 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S100 = Domain_x24init_0(_S98, _S98, &_S99, 0.0f, 0.0f);
    Domain own_0 = _S100;
    bool _S101 = ((&job_2->r)->w) > 0.0f;
    if(_S101)
    {
        bool _S102 = (fcptPreviousScenes());
        if(_S102)
        {
            _S83 = true;
        }
        else
        {
            bool _S103 = (fcptStoredDomainInitial((p_4), ((&job_2->r)->seed), (&own_0)));
            if(_S103)
            {
                Domain _S104 = job_2->dom;
                Domain _S105 = own_0;
                bool _S106 = sameDomain_0(&_S104, &_S105);
                _S83 = _S106;
            }
            else
            {
                _S83 = false;
            }
            _S83 = !_S83;
        }
    }
    else
    {
        _S83 = false;
    }
    return _S83;
}

static __device__ void temporalBins_0(int2  p_5, FixedArray<uint, 3>  * _S107)
{
    FixedArray<uint, 3>  _S108 = { {
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
        ShiftJob _S109 = (ShiftJob{});
        ShiftJob job_3 = _S109;
        bool _S110 = temporalJob_0(p_5, t_7, &job_3, false);
        if(_S110)
        {
            Reservoir _S111 = (&job_3)->r;
            uint _S112 = shiftBin_0(&_S111);
            bins_2[t_7] = _S112;
        }
        uint t_8 = t_7 + 1U;
        t_7 = t_8;
    }
    *_S107 = bins_2;
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
        uint _S113 = (*bins_3)[t_9];
        bool _S114 = ((*bins_3)[t_9]) < 40U;
        if(_S114)
        {
            uint _S115 = (fcptQueueCountAdd((_S113), (1U)));
        }
        uint t_10 = t_9 + 1U;
        t_9 = t_10;
    }
    return;
}

static __device__ float2  pixelOf_0(float3  position_0, bool previous_0)
{
    float2  _S116 = (fcptPixelOf((position_0), (previous_0)));
    return _S116;
}

static __device__ bool previousValid_0(int2  q_1)
{
    bool _S117 = all_0(q_1 >= make_int2 (int(0)));
    bool _S118;
    if(_S117)
    {
        uint2  _S119 = (fcptRenderSize());
        int2  _S120 = make_int2 ((int)_S119.x, (int)_S119.y);
        _S118 = all_0(q_1 < _S120);
    }
    else
    {
        _S118 = false;
    }
    if(_S118)
    {
        uint4  _S121 = (fcptReservoirPrevious((q_1), (0U)));
        _S118 = (U32_asfloat((_S121.w))) > 0.0f;
    }
    else
    {
        _S118 = false;
    }
    return _S118;
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
    bool _S122 = previousValid_0(p_6);
    bool _S123;
    if(_S122)
    {
        Domain _S124 = (fcptPreviousDomain((p_6), (seed_1)));
        Domain _S125 = _S124;
        bool _S126 = sameDomain_0(&_S125, dom_2);
        _S123 = _S126;
    }
    else
    {
        _S123 = false;
    }
    if(_S123)
    {
        return p_6;
    }
    uint _S127 = (&dom_2->hit)->instance_index;
    bool _S128 = ((&dom_2->hit)->instance_index) == 4294967295U;
    if(_S128)
    {
        return make_int2 (int(-1));
    }
    float3  _S129 = dom_2->x1;
    float2  _S130 = pixelOf_0(dom_2->x1, true);
    float2  _S131 = floor_0(_S130);
    int2  _S132 = make_int2 ((int)_S131.x, (int)_S131.y);
    bool _S133 = previousValid_0(_S132);
    bool _S134 = !_S133;
    if(_S134)
    {
        return make_int2 (int(-1));
    }
    uint4  _S135 = (fcptReservoirPrevious((_S132), (0U)));
    Domain _S136 = (fcptPreviousDomain((_S132), (_S135.x)));
    bool _S137 = (_S136.hit.instance_index) == _S127;
    if(_S137)
    {
        float _S138 = distance_1(_S136.x1, _S129);
        float _S139 = (&dom_2->hit)->distance * 8.0f;
        uint2  _S140 = (fcptRenderSize());
        _S123 = _S138 <= (_S139 / float(_S140.x));
    }
    else
    {
        _S123 = false;
    }
    if(_S123)
    {
        return _S132;
    }
    int2  _S141 = p_6 + _S132;
    float2  _S142 = make_float2 ((float)_S141.x, (float)_S141.y);
    float2  _S143 = _S142 + make_float2 (1.0f);
    float2  _S144 = pixelOf_0(_S136.x1, false);
    float2  _S145 = floor_0(_S143 - _S144);
    int2  _S146 = make_int2 ((int)_S145.x, (int)_S145.y);
    int2  _S147 = make_int2 (int(-1));
    bool _S148 = previousValid_0(_S146);
    int2  _S149 = _slang_select(_S148, _S146,_S147);
    return _S149;
}

static __device__ int2  sampleNeighbor_0(int2  p_7, uint seed_2)
{
    bool _S150 = (fcptSceneUnchanged());
    if(_S150)
    {
        int2  _S151 = make_int2 (int(-1));
        bool _S152 = previousValid_0(p_7);
        int2  _S153 = _slang_select(_S152, p_7,_S151);
        return _S153;
    }
    float3  _S154 = make_float3 (0.0f);
    FKHit _S155 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S156 = Domain_x24init_0(_S154, _S154, &_S155, 0.0f, 0.0f);
    Domain dom_3 = _S156;
    uint2  _S157 = (fcptRenderSize());
    int2  _S158 = make_int2 ((int)_S157.x, (int)_S157.y);
    bool _S159 = any_0(p_7 >= _S158);
    bool _S160;
    if(_S159)
    {
        _S160 = true;
    }
    else
    {
        bool _S161 = (fcptStoredDomainInitial((p_7), (seed_2), (&dom_3)));
        _S160 = !_S161;
    }
    if(_S160)
    {
        return make_int2 (int(-1));
    }
    Domain _S162 = dom_3;
    int2  _S163 = temporalNeighbor_0(p_7, &_S162, seed_2);
    return _S163;
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
    FKRay _S164;
    (&_S164)->origin = origin_0;
    (&_S164)->unit_direction = unit_direction_0;
    return _S164;
}

static __device__ float3  skyRadiance_0(float3  origin_1, FKSurface * surface_0, bool is_inside_1, float3  dir_1, ShadowContext * context_0, uint random_state_0)
{
    bool _S165 = wrongSide_0(is_inside_1, false, dir_1, surface_0->geometry_n);
    bool _S166 = is_inside_1 != _S165;
    float _S167 = surface_0->geometry_offset;
    float3  _S168 = surface_0->smooth_n;
    float3  _S169 = - surface_0->smooth_n;
    float3  _S170 = _slang_select(_S166, _S169,_S168);
    FKRay _S171 = Ray_x24init_0(origin_1 + make_float3 (_S167) * _S170, dir_1);
    bool _S172 = (dot_0(context_0->side, dir_1)) > 0.0f;
    float3  _S173 = (fcptEnvMapSample((dir_1), (0U), (3U)));
    float3  _S174 = context_0->extinction_behind;
    float3  _S175 = context_0->extinction_front;
    float3  _S176 = _slang_select(_S172, _S175,_S174);
    uint _S177 = context_0->fillings.x;
    uint _S178 = context_0->fillings.y;
    uint _S179 = _slang_select(_S172, _S178,_S177);
    uint _S180 = context_0->depth;
    uint _S181 = context_0->lobe;
    bool _S182 = context_0->surface;
    bool _S183;
    if(_S182)
    {
        _S183 = !context_0->fiber;
    }
    else
    {
        _S183 = false;
    }
    float _S184 = context_0->length;
    float _S185 = context_0->width;
    FKHit _S186 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    float3  _S187 = (fcptShadowTransmittanceIn((_S171), (4.294967296e+09f), (_S176), (_S179), (random_state_0), (_S180), (_S181), (_S183), (_S184), (_S185), (_S186), (_S186)));
    return _S173 * _S187;
}

static __device__ uint searchCDF_0(uint2  start_4, uint2  step_0, uint count_1, float u_0)
{
    uint _S188 = count_1 - 1U;
    uint low_0 = 0U;
    uint high_0 = _S188;
    for(;;)
    {
        if(low_0 < high_0)
        {
        }
        else
        {
            break;
        }
        uint _S189 = (low_0 + high_0) / 2U;
        float4  _S190 = (fcptEnvironmentCdf((start_4 + step_0 * make_uint2 (_S189))));
        bool _S191 = (_S190.x) > u_0;
        if(_S191)
        {
            high_0 = _S189;
        }
        else
        {
            uint _S192 = _S189 + 1U;
            low_0 = _S192;
        }
    }
    return low_0;
}

static __device__ float3  skyFrame_0(float3  dir_2)
{
    float3  _S193 = make_float3 (- dir_2.x, dir_2.z, dir_2.y);
    bool _S194 = ((true));
    float3  _S195 = _slang_select(_S194, _S193,dir_2);
    return _S195;
}

__device__ float shadowLength(float3  shadow_0)
{
    return length_0(shadow_0) * 0.99989998340606689f;
}

static __device__ float3  lightTransmittance_0(float3  origin_2, float3  smooth_n_0, float geometry_offset_0, float3  light_dir_0, ShadowContext * context_1, uint random_state_1, FKHit * light_0)
{
    float3  _S196 = ((((light_dir_0)) * make_float3(rnorm3df(((light_dir_0)).x, ((light_dir_0)).y, ((light_dir_0)).z))));
    bool _S197 = (dot_0(smooth_n_0, _S196)) < 0.0f;
    if(_S197)
    {
        return make_float3 (0.0f);
    }
    float3  _S198 = make_float3 (geometry_offset_0) * smooth_n_0;
    float3  _S199 = origin_2 + _S198;
    FKRay _S200 = Ray_x24init_0(_S199, _S196);
    bool _S201 = (dot_0(context_1->side, light_dir_0 + _S198)) > 0.0f;
    float _S202 = shadowLength(light_dir_0);
    float3  _S203 = context_1->extinction_behind;
    float3  _S204 = context_1->extinction_front;
    float3  _S205 = _slang_select(_S201, _S204,_S203);
    uint _S206 = context_1->fillings.x;
    uint _S207 = context_1->fillings.y;
    uint _S208 = _slang_select(_S201, _S207,_S206);
    uint _S209 = context_1->depth;
    uint _S210 = context_1->lobe;
    bool _S211 = context_1->surface;
    bool _S212;
    if(_S211)
    {
        _S212 = !context_1->fiber;
    }
    else
    {
        _S212 = false;
    }
    float _S213 = context_1->length;
    float _S214 = context_1->width;
    FKHit _S215;
    if(context_1->fiber)
    {
        _S215 = context_1->own;
    }
    else
    {
        _S215 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    }
    float3  _S216 = (fcptShadowTransmittanceIn((_S200), (_S202), (_S205), (_S208), (random_state_1), (_S209), (_S210), (_S212), (_S213), (_S214), (_S215), (*light_0)));
    return _S216;
}

__device__ float sine(float c_0)
{
    return (F32_sqrt(((F32_max((1.0f - c_0 * c_0), (0.0f))))));
}

__device__ float cosSubClamped(float sin_a_0, float cos_a_0, float sin_b_0, float cos_b_0)
{
    float _S217 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    bool _S218 = cos_a_0 > cos_b_0;
    float _S219 = _slang_select(_S218, 1.0f,_S217);
    return _S219;
}

__device__ float importance(LightNode node_0, float3  p_8, float3  normal_0)
{
    float3  _S220 = (node_0.low + node_0.high) * make_float3 (0.5f);
    float3  _S221 = node_0.high - node_0.low;
    float3  _S222 = p_8 - _S220;
    float3  _S223 = ((((_S222)) * make_float3(rnorm3df(((_S222)).x, ((_S222)).y, ((_S222)).z))));
    float _S224 = dot_0(_S222, _S222);
    float _S225 = dot_0(_S221, _S221) / 4.0f;
    float _S226 = (F32_abs((dot_0(node_0.w, _S223))));
    float _S227 = sine(node_0.cos_theta_o);
    float _S228 = (F32_sqrt(((F32_max((1.0f - _S225 / _S224), (0.0f))))));
    bool _S229 = _S224 < _S225;
    float _S230 = _slang_select(_S229, -1.0f,_S228);
    float _S231 = sine(_S230);
    float _S232 = sine(_S226);
    float _S233 = cosSubClamped(_S232, _S226, _S227, node_0.cos_theta_o);
    float _S234 = sine(_S226);
    float _S235 = _S234 * node_0.cos_theta_o - _S226 * _S227;
    bool _S236 = _S226 > (node_0.cos_theta_o);
    float _S237 = _slang_select(_S236, 0.0f,_S235);
    float _S238 = cosSubClamped(_S237, _S233, _S231, _S230);
    bool _S239 = _S238 <= 0.0f;
    if(_S239)
    {
        return 0.0f;
    }
    float _S240 = - dot_0(_S223, normal_0);
    float _S241 = node_0.phi * _S238 / (F32_max((_S224), (length_0(_S221) / 2.0f)));
    float _S242 = sine(_S240);
    float _S243 = cosSubClamped(_S242, _S240, _S231, _S230);
    bool _S244 = (dot_0(normal_0, normal_0)) == 0.0f;
    float _S245 = _slang_select(_S244, 1.0f,_S243);
    return (F32_max((_S241 * _S245), (0.0f)));
}

__device__ __forceinline__ float childShare(LightNode first_0, LightNode second_0, float3  p_9, float3  normal_1, uint child_0)
{
    float _S246 = importance(first_0, p_9, normal_1);
    float _S247 = importance(second_0, p_9, normal_1);
    float2  _S248 = make_float2 (_S246, _S247);
    float _S249 = _slang_vector_get_element(_S248, child_0) / (_S246 + _S247);
    bool _S250 = _slang_vector_get_element(_S248, child_0) > 0.0f;
    float _S251 = _slang_select(_S250, _S249,0.0f);
    return _S251;
}

__device__ float sphereDensity(float3  center_0, float radius_0, float3  p_10)
{
    float3  _S252 = center_0 - p_10;
    float _S253 = radius_0 * radius_0 / dot_0(_S252, _S252);
    bool _S254 = _S253 >= 1.0f;
    if(_S254)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + (F32_sqrt((1.0f - _S253)))) / (6.28318548202514648f * _S253);
}

static __device__ float3  cross_0(float3  left_0, float3  right_0)
{
    float _S255 = left_0.y;
    float _S256 = right_0.z;
    float _S257 = left_0.z;
    float _S258 = right_0.y;
    float _S259 = right_0.x;
    float _S260 = left_0.x;
    return make_float3 (_S255 * _S256 - _S257 * _S258, _S257 * _S259 - _S260 * _S256, _S260 * _S258 - _S255 * _S259);
}

__device__ float solidAngle(float probability_0, float3  normal_2, float3  toward_0)
{
    return 2.0f * probability_0 * (F32_pow((length_0(toward_0)), (3.0f))) / (F32_abs((dot_0(normal_2, toward_0))));
}

static __device__ float lightPdf_0(float3  origin_3, float3  smooth_n_1, float3  start_5, uint j_0, float3  light_point_0)
{
    bool _S261 = j_0 == 4294967295U;
    if(_S261)
    {
        return 0.0f;
    }
    uint4  _S262 = (fcptLightTrail((j_0)));
    uint2  _S263 = uint2 {_S262.x, _S262.y};
    uint n_0 = 0U;
    uint2  trail_0 = _S263;
    float probability_1 = 1.0f;
    for(;;)
    {
        uint4  _S264 = (fcptLightNode((n_0)));
        if((_S264.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S265 = (fcptLightSecond((n_0)));
        uint _S266 = n_0 + 1U;
        LightNode _S267 = (fcptLightBounds((_S266)));
        LightNode _S268 = (fcptLightBounds((_S265)));
        uint _S269 = trail_0.x;
        uint _S270 = _S269 & 1U;
        float _S271 = childShare(_S267, _S268, origin_3, smooth_n_1, _S270);
        float probability_2 = probability_1 * _S271;
        bool _S272 = _S270 == 1U;
        uint _S273 = _slang_select(_S272, _S265,_S266);
        uint _S274 = trail_0.y;
        uint2  _S275 = make_uint2 ((_S269 >> 1U) | (_S274 << 31U), _S274 >> 1U);
        n_0 = _S273;
        trail_0 = _S275;
        probability_1 = probability_2;
    }
    bool _S276 = (fcptSlotLeaf((n_0), (j_0)));
    bool _S277 = !_S276;
    bool _S278;
    if(_S277)
    {
        _S278 = true;
    }
    else
    {
        LightNode _S279 = (fcptLightBounds((n_0)));
        float _S280 = importance(_S279, origin_3, smooth_n_1);
        _S278 = !(_S280 > 0.0f);
    }
    if(_S278)
    {
        _S278 = true;
    }
    else
    {
        bool _S281 = (dot_0(smooth_n_1, smooth_n_1)) > 0.0f;
        if(_S281)
        {
            _S278 = !((dot_0(smooth_n_1, light_point_0 - origin_3)) > 0.0f);
        }
        else
        {
            _S278 = false;
        }
    }
    if(_S278)
    {
        return 0.0f;
    }
    uint4  _S282 = (fcptLightNode((n_0)));
    bool _S283 = (_S282.x) == 2U;
    if(_S283)
    {
        FKLight _S284 = (fcptLight((_S282.y)));
        float _S285 = sphereDensity(_S284.position, _S284.variance, start_5);
        return probability_1 * _S285;
    }
    uint _S286 = _S282.y;
    uint _S287 = (fcptTriangleOffset((_S286)));
    Matrix<float, 3, 3>  _S288 = (fcptWorldTriangle((_S286), (_S287 + _S282.z)));
    float _S289 = solidAngle(probability_1, cross_0(_S288.rows[int(1)] - _S288.rows[int(0)], _S288.rows[int(2)] - _S288.rows[int(0)]), light_point_0 - start_5);
    return _S289;
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
    Random _S290;
    (&_S290)->state = state_0;
    (&_S290)->value = value_0;
    return _S290;
}

__device__ Random pcg(uint state_1)
{
    uint _S291 = hash(state_1);
    float value_1 = float(_S291 >> int(8)) * 5.9604644775390625e-08f;
    return Random_x24init_0(_S291, value_1);
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
    uint2  _S292 = (fcptEnvironmentCdfSize());
    uint2  _S293 = _S292 - make_uint2 (1U, 0U);
    float3  _S294 = skyFrame_0(dir_3);
    float2  _S295 = make_float2 ((F32_atan2((- _S294.z), (- _S294.x))) / 6.28318548202514648f + 0.5f, (F32_acos((clamp_1(_S294.y, -1.0f, 1.0f)))) / 3.14159274101257324f);
    float2  _S296 = make_float2 ((float)_S293.x, (float)_S293.y);
    float2  _S297 = _S295 * _S296;
    uint2  _S298 = make_uint2 ((uint)_S297.x, (uint)_S297.y);
    uint2  _S299 = min_0(_S298, _S293 - make_uint2 (1U));
    float4  _S300 = (fcptEnvironmentCdf((_S299)));
    float _S301 = _S300.y;
    uint _S302 = _S293.x;
    float4  _S303 = (fcptEnvironmentCdf((make_uint2 (_S302, _S299.y))));
    float _S304 = _S301 * _S303.y;
    return _S304 * float(_S302 * _S293.y) / (19.73921012878417969f * length_1(float2 {_S294.x, _S294.z}));
}

static __device__ float3  negate_0(float3  x_13)
{
    return - x_13;
}

static __device__ float sign_0(float e_1)
{
    bool _S305 = e_1 < 0.0f;
    float _S306 = _slang_select(_S305, -1.0f,0.0f);
    bool _S307 = e_1 > 0.0f;
    float _S308 = _slang_select(_S307, 1.0f,_S306);
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

__device__ float3  anisotropicLocal(float3  w_0, float3  t_11, float3  n_2)
{
    return make_float3 (dot_0(w_0, t_11), dot_0(w_0, cross_0(n_2, t_11)), dot_0(w_0, n_2));
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
    float3  _S360 = make_float3 (1.0f, 0.0f, 0.0f);
    float3  _S361 = make_float3 (- _S358, _S357, 0.0f);
    float _S362 = (rsqrtf((_S359)));
    float3  _S363 = _S361 * make_float3 (_S362);
    bool _S364 = _S359 > 0.0f;
    float3  _S365 = _slang_select(_S364, _S363,_S360);
    float3  _S366 = cross_0(_S356, _S365);
    float _S367 = (F32_sqrt((U1_0)));
    float _S368 = 6.28318548202514648f * U2_0;
    float _S369 = _S367 * (F32_cos((_S368)));
    float t2_0 = _S367 * (F32_sin((_S368)));
    float _S370 = 0.5f * (1.0f + _S356.z);
    float t2_1 = (1.0f - _S370) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S369 * _S369)))))) + _S370 * t2_0;
    float3  _S371 = make_float3 (_S369) * _S365 + make_float3 (t2_1) * _S366;
    float _S372 = unshared_0(_S369);
    float _S373 = unshared_0(_S369);
    float3  _S374 = _S371 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S372 * _S373 - t2_1 * t2_1))))))) * _S356;
    float3  _S375 = make_float3 (alpha_0 * _S374.x, alpha_0 * _S374.y, (F32_max((0.0f), (_S374.z))));
    float3  _S376 = ((((_S375)) * make_float3(rnorm3df(((_S375)).x, ((_S375)).y, ((_S375)).z))));
    return _S376;
}

__device__ float3  worldToTangent(float3  v_2, float3  n_3)
{
    float3  a_3 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S377 = (F32_abs((dot_0(n_3, a_3)))) > 0.9999847412109375f;
    float3  a_4;
    if(_S377)
    {
        float3  _S378 = make_float3 (1.0f, 0.0f, 0.0f);
        a_4 = _S378;
    }
    else
    {
        a_4 = a_3;
    }
    float3  _S379 = cross_0(n_3, a_4);
    float3  _S380 = ((((_S379)) * make_float3(rnorm3df(((_S379)).x, ((_S379)).y, ((_S379)).z))));
    float3  _S381 = cross_0(n_3, _S380);
    return make_float3 (dot_0(v_2, _S380), dot_0(v_2, n_3), dot_0(v_2, _S381));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_3, float3  n_i_2, float alpha_1, AnisotropicFrame frame_0, uint * random_state_2)
{
    Random _S382 = pcg(*random_state_2);
    Random _S383 = pcg(_S382.state);
    *random_state_2 = _S383.state;
    float _S384 = frame_0.alphas.x;
    bool _S385 = _S384 > 0.0f;
    if(_S385)
    {
        float3  _S386 = anisotropicLocal(v_3, frame_0.tangent, n_i_2);
        float _S387 = frame_0.alphas.y;
        float3  _S388 = make_float3 (_S384 * _S386.x, _S387 * _S386.y, _S386.z);
        float3  _S389 = ((((_S388)) * make_float3(rnorm3df(((_S388)).x, ((_S388)).y, ((_S388)).z))));
        float3  _S390 = sampleGGXVNDF(_S389, 1.0f, _S382.value, _S383.value);
        float3  _S391 = make_float3 (_S384 * _S390.x, _S387 * _S390.y, _S390.z);
        float3  _S392 = ((((_S391)) * make_float3(rnorm3df(((_S391)).x, ((_S391)).y, ((_S391)).z))));
        return make_float3 (_S392.x) * frame_0.tangent + make_float3 (_S392.y) * cross_0(n_i_2, frame_0.tangent) + make_float3 (_S392.z) * n_i_2;
    }
    float3  _S393 = worldToTangent(v_3, n_i_2);
    float3  _S394 = sampleGGXVNDF(float3 {_S393.x, _S393.z, _S393.y}, alpha_1, _S382.value, _S383.value);
    float3  _S395 = float3 {_S394.x, _S394.z, _S394.y};
    float3  _S396 = tangentToWorld(_S395, n_i_2);
    return _S396;
}

__device__ float3  sampledHalf(float3  in_dir_0, float3  n_4, BSDFMaterial material_2, uint random_state_3, AnisotropicFrame frame_1)
{
    uint state_2 = random_state_3;
    float3  _S397 = negate_0(in_dir_0);
    float _S398 = sign_0(dot_0(n_4, _S397));
    float _S399 = material_2.roughness;
    float3  _S400 = sampleHalfVector(_S397, n_4 * make_float3 (_S398), _S399 * _S399, frame_1, &state_2);
    return _S400;
}

__device__ float3  refractedHalf(float3  in_dir_1, float3  out_dir_0, float3  n_5, float eta_i_0, float eta_o_0)
{
    float3  _S401 = negate_0(in_dir_1);
    float3  _S402 = negate_0(make_float3 (eta_i_0) * _S401 + make_float3 (eta_o_0) * out_dir_0);
    float3  _S403 = ((((_S402)) * make_float3(rnorm3df(((_S402)).x, ((_S402)).y, ((_S402)).z))));
    float _S404 = sign_0(dot_0(n_5, _S401));
    float _S405 = sign_0(dot_0(_S402, n_5 * make_float3 (_S404)));
    return _S403 * make_float3 (_S405);
}

__device__ float3  reflectedHalf(float3  in_dir_2, float3  out_dir_1)
{
    float3  _S406 = negate_0(in_dir_2);
    float3  _S407 = _S406 + out_dir_1;
    float3  _S408 = ((((_S407)) * make_float3(rnorm3df(((_S407)).x, ((_S407)).y, ((_S407)).z))));
    return _S408;
}

static __device__ float3  refract_0(float3  i_5, float3  n_6, float eta_0)
{
    float _S409 = dot_0(n_6, i_5);
    float _S410 = 1.0f - eta_0 * eta_0 * (1.0f - _S409 * _S409);
    if(_S410 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_5 - make_float3 (eta_0 * _S409 + (F32_sqrt((_S410)))) * n_6;
}

__device__ float fresnel(float cos_theta_0, float eta_i_1, float eta_o_1)
{
    float _S411 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S412 = eta_i_1 / eta_o_1 * _S411;
    bool _S413 = _S412 < 1.0f;
    float kr_0;
    if(_S413)
    {
        float _S414 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S412 * _S412))))));
        bool _S415 = eta_i_1 == eta_o_1;
        float _S416 = _slang_select(_S415, cos_theta_0,_S414);
        float _S417 = eta_o_1 * cos_theta_0;
        float _S418 = eta_i_1 * _S416;
        float _S419 = (_S417 - _S418) / (_S417 + _S418);
        float _S420 = eta_i_1 * cos_theta_0;
        float _S421 = eta_o_1 * _S416;
        float _S422 = (_S420 - _S421) / (_S420 + _S421);
        float _S423 = (_S419 * _S419 + _S422 * _S422) / 2.0f;
        kr_0 = _S423;
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
    float _S424 = (F32_max((w_1.z), (0.0f)));
    return 2.0f * _S424 / (_S424 + length_0(make_float3 (alphas_2.x * w_1.x, alphas_2.y * w_1.y, _S424)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_3)
{
    float _S425 = alphas_3.x;
    float _S426 = h_0.x / _S425;
    float _S427 = alphas_3.y;
    float _S428 = h_0.y / _S427;
    float _S429 = h_0.z;
    float _S430 = _S426 * _S426 + _S428 * _S428 + _S429 * _S429;
    return 1.0f / (F32_max((3.14159274101257324f * _S425 * _S427 * _S430 * _S430), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ BSDFLobes bsdfLobes(float3  in_dir_3, float3  v_4, float3  n_i_3, float3  ggx_n_0, BSDFMaterial material_3, float eta_i_2, float eta_o_2, AnisotropicFrame frame_2, SheenProfile sheen_profile_0)
{
    float _S431 = dot_0(ggx_n_0, v_4);
    float _S432 = dot_0(n_i_3, ggx_n_0);
    float _S433 = eta_i_2 / eta_o_2;
    float3  _S434 = refract_0(in_dir_3, ggx_n_0, _S433);
    float3  _S435 = ((((_S434)) * make_float3(rnorm3df(((_S434)).x, ((_S434)).y, ((_S434)).z))));
    float _S436 = (F32_min(((F32_sqrt((material_3.specular_level))) * (F32_abs((eta_i_2 - eta_o_2))) / (eta_i_2 + eta_o_2)), (0.9999847412109375f)));
    float _S437 = _S436 * _S436;
    float _S438 = (1.0f + _S436) / (1.0f - _S436);
    float _S439 = (F32_abs((_S431)));
    bool _S440 = eta_i_2 > eta_o_2;
    float _S441 = _slang_select(_S440, _S438,1.0f);
    float _S442 = _slang_select(_S440, 1.0f,_S438);
    float _S443 = fresnel(_S439, _S441, _S442);
    bool _S444 = (eta_i_2 * eta_i_2 * (1.0f - _S431 * _S431)) >= (eta_o_2 * eta_o_2);
    float3  _S445 = material_3.specular_tint * make_float3 (_S437);
    float3  _S446 = _S445 + (make_float3 (1.0f) - _S445) * make_float3 (_S443 - _S437) / make_float3 (1.0f - _S437);
    float3  _S447 = make_float3 (1.0f);
    float3  _S448 = _slang_select(_S444, _S447,_S446);
    float3  _S449 = make_float3 (0.0f);
    float sheen_component_0;
    float3  sheen_1;
    float3  view_1;
    float3  scale_1;
    if(sheen_profile_0.on)
    {
        float _S450 = (F32_min((sheen_profile_0.albedo), (1.0f)));
        float3  _S451 = make_float3 (1.0f) - material_3.sheen * make_float3 (_S450);
        float _S452 = rgb_to_greyscale(material_3.sheen);
        float _S453 = _S452 * _S450;
        float3  _S454 = material_3.sheen / make_float3 ((F32_max((sheen_profile_0.albedo), (1.0f))));
        sheen_component_0 = _S453;
        sheen_1 = _S454;
        view_1 = v_4;
        scale_1 = _S451;
    }
    else
    {
        sheen_component_0 = 0.0f;
        sheen_1 = _S449;
        view_1 = _S449;
        scale_1 = _S447;
    }
    float _S455 = material_3.toon.x;
    bool _S456 = _S455 < 0.0f;
    float _S457 = (F32_abs((_S455)));
    bool _S458 = _S457 > 0.0f;
    float toon_component_0;
    float toon_a_1;
    float toon_s_1;
    float toon_b_1;
    float toon_norm_1;
    float toon_view_1;
    float3  toon_1;
    float3  toon_axis_1;
    bool _S459;
    if(_S458)
    {
        float _S460 = (F32_min((_S457), (1.0f)));
        float3  scale_2 = scale_1 * make_float3 (1.0f - _S460);
        float _S461 = rgb_to_greyscale(material_3.albedo);
        float _S462 = _S460 * _S461;
        float3  _S463 = make_float3 (_S460) * material_3.albedo;
        float toon_a_2 = clamp_1(material_3.toon.y / _S455, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
        float toon_s_2 = clamp_1(material_3.toon.z / _S455, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
        float _S464 = (F32_min((toon_a_2 + toon_s_2), (1.57079637050628662f)));
        if(_S456)
        {
            toon_component_0 = 1.0f - (F32_cos(((F32_min((_S464), (toon_a_2))))));
        }
        else
        {
            float _S465 = (F32_sin(((F32_min((_S464), (toon_a_2))))));
            toon_component_0 = _S465 * _S465 / 2.0f;
        }
        bool _S466 = _S464 > toon_a_2;
        if(_S466)
        {
            _S459 = toon_s_2 > 0.0f;
        }
        else
        {
            _S459 = false;
        }
        if(_S459)
        {
            if(_S456)
            {
                float _S467 = (F32_cos((toon_a_2)));
                float _S468 = (F32_cos((_S464)));
                toon_a_1 = (1.0f + toon_a_2 / toon_s_2) * (_S467 - _S468) - ((F32_sin((_S464))) - _S464 * _S468 - ((F32_sin((toon_a_2))) - toon_a_2 * _S467)) / toon_s_2;
            }
            else
            {
                float _S469 = 2.0f * toon_a_2;
                float _S470 = (F32_cos((_S469)));
                float _S471 = 2.0f * _S464;
                float _S472 = (F32_cos((_S471)));
                toon_a_1 = (1.0f + toon_a_2 / toon_s_2) * (_S470 - _S472) / 4.0f - ((F32_sin((_S471))) / 8.0f - _S464 * _S472 / 4.0f - ((F32_sin((_S469))) / 8.0f - toon_a_2 * _S470 / 4.0f)) / toon_s_2;
            }
            float integral_0 = toon_component_0 + toon_a_1;
            toon_component_0 = integral_0;
        }
        float _S473 = 6.28318548202514648f * toon_component_0;
        float _S474 = dot_0(n_i_3, v_4);
        float _S475 = (F32_acos(((F32_min((_S474), (1.0f))))));
        if(_S475 < toon_a_2)
        {
            toon_component_0 = 1.0f;
        }
        else
        {
            toon_component_0 = (F32_max((1.0f - (_S475 - toon_a_2) / (F32_max((toon_s_2), (0.0000152587890625f)))), (0.0f)));
        }
        if(_S456)
        {
            float3  _S476 = make_float3 (2.0f * _S474) * n_i_3 - v_4;
            float3  _S477 = ((((_S476)) * make_float3(rnorm3df(((_S476)).x, ((_S476)).y, ((_S476)).z))));
            scale_1 = _S477;
        }
        else
        {
            scale_1 = n_i_3;
        }
        float _S478 = toon_component_0;
        toon_component_0 = _S462;
        toon_1 = _S463;
        toon_a_1 = toon_a_2;
        toon_s_1 = toon_s_2;
        toon_b_1 = _S464;
        toon_norm_1 = _S473;
        toon_view_1 = _S478;
        toon_axis_1 = scale_1;
        scale_1 = scale_2;
    }
    else
    {
        toon_component_0 = 0.0f;
        toon_1 = _S449;
        toon_a_1 = 0.0f;
        toon_s_1 = 0.0f;
        toon_b_1 = 0.0f;
        toon_norm_1 = 1.0f;
        toon_view_1 = 0.0f;
        toon_axis_1 = n_i_3;
    }
    float3  _S479 = mix_0(_S448, material_3.albedo, material_3.metallic);
    float3  F_1 = _S479 * scale_1;
    float _S480 = rgb_to_greyscale(F_1);
    float _S481 = 1.0f - material_3.metallic;
    float3  _S482 = make_float3 (1.0f) - _S448;
    float3  _S483 = make_float3 ((1.0f - material_3.transmission) * _S481) * _S482 * scale_1;
    float3  _S484 = make_float3 (material_3.transmission * _S481) * _S482 * scale_1;
    float _S485 = (F32_max((_S480), (0.0f)));
    float _S486 = rgb_to_greyscale(_S483);
    float _S487 = (F32_max((_S486), (0.0f)));
    float _S488 = rgb_to_greyscale(_S484);
    float _S489 = sign_0(length_0(_S435));
    float _S490 = (F32_max((_S488 * _S489), (0.0f)));
    float _S491 = _S485 + _S487 + _S490 + toon_component_0;
    float _S492 = (F32_min((sheen_component_0), (1.0f)));
    bool _S493 = sheen_component_0 > 0.0f;
    if(_S493)
    {
        _S459 = !(_S491 > 0.0f);
    }
    else
    {
        _S459 = false;
    }
    float _S494 = _slang_select(_S459, 1.0f,_S492);
    float _S495 = (1.0f - _S494) / (F32_max((_S491), (0.0000152587890625f)));
    float _S496 = _S487 * _S495;
    float _S497 = _S485 * _S495;
    float _S498 = _S490 * _S495;
    bool _S499 = (frame_2.alphas.x) > 0.0f;
    float visible_1;
    if(_S499)
    {
        float3  _S500 = anisotropicLocal(v_4, frame_2.tangent, n_i_3);
        float _S501 = anisotropicG1(_S500, frame_2.alphas);
        float3  _S502 = anisotropicLocal(ggx_n_0, frame_2.tangent, n_i_3);
        float _S503 = anisotropicD(_S502, frame_2.alphas);
        float _S504 = _S501 * _S503;
        visible_1 = _S504;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S431, _S432, _S435, F_1, _S480, 1.0f, _S483, _S484, _S496, _S497, _S498, 0.0f, sheen_1, _S494, view_1, frame_2.tangent, frame_2.alphas, visible_1, toon_component_0 * _S495, toon_1, toon_a_1, toon_s_1, toon_b_1, _S456, toon_norm_1, toon_view_1, toon_axis_1);
}

__device__ float translucentShare(BSDFMaterial material_4)
{
    float _S505 = rgb_to_greyscale(material_4.translucent);
    float _S506 = rgb_to_greyscale(material_4.albedo);
    float _S507 = _S505 / (_S506 + _S505);
    bool _S508 = _S505 > 0.0f;
    float _S509 = _slang_select(_S508, _S507,0.0f);
    return _S509;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_2, BSDFLobes lobes_0, float eta_i_3, float eta_o_3)
{
    float _S510 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S511 = lobes_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S512 = 1.0f - lobes_0.translucent_share;
    bool _S513 = n_i_dot_l_0 < 0.0f;
    float _S514 = _slang_select(_S513, lobes_0.translucent_share,_S512);
    float _S515 = _S511 * _S514;
    bool _S516 = (lobes_0.translucent_share) > 0.0f;
    float _S517 = _slang_select(_S516, _S515,_S510);
    bool _S518 = n_i_dot_v_0 > 0.0f;
    float _S519 = _slang_select(_S518, _S517,0.0f);
    return _S519;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_4, float alpha_3, BSDFMaterial material_5, BSDFLobes lobes_1)
{
    bool _S520 = (dot_0(n_i_4, l_0)) < 0.0f;
    float3  _S521 = _slang_select(_S520, material_5.translucent,material_5.albedo);
    float _S522 = 1.0f - lobes_1.translucent_share;
    float _S523 = _slang_select(_S520, lobes_1.translucent_share,_S522);
    float3  _S524 = _S521 / make_float3 (_S523);
    bool _S525 = (lobes_1.translucent_share) > 0.0f;
    float3  _S526 = _slang_select(_S525, _S524,material_5.albedo);
    return lobes_1.diffuse_weight * _S526 / make_float3 (lobes_1.p_diffuse);
}

__device__ float smithG1(float alpha_4, float n_dot_x_0)
{
    float _S527 = alpha_4 * alpha_4;
    float _S528 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S527 + (1.0f - _S527) * n_dot_x_0 * n_dot_x_0))));
    bool _S529 = alpha_4 > 0.0f;
    float _S530 = _slang_select(_S529, _S528,1.0f);
    return _S530;
}

__device__ float trowbridgeReitz(float alpha_5, float n_dot_h_1)
{
    float _S531 = alpha_5 * alpha_5;
    float _S532 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S531 * n_dot_h_1 * n_dot_h_1;
    return _S531 / (F32_max((3.14159274101257324f * _S532 * _S532), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float n_i_dot_v_1, float alpha_6, BSDFLobes lobes_2)
{
    float _S533 = smithG1(alpha_6, n_i_dot_v_1);
    float _S534 = _S533 * lobes_2.v_dot_h;
    float _S535 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    float _S536 = _S534 * _S535 / n_i_dot_v_1;
    bool _S537 = alpha_6 > 0.0f;
    bool _S538;
    if(_S537)
    {
        _S538 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S538 = false;
    }
    if(_S538)
    {
        _S538 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S538 = false;
    }
    if(_S538)
    {
        _S538 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S538 = false;
    }
    float _S539 = _slang_select(_S538, _S536,0.0f);
    bool _S540 = (lobes_2.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S540)
    {
        float _S541 = lobes_2.visible * lobes_2.v_dot_h / n_i_dot_v_1;
        bool _S542 = (lobes_2.v_dot_h) > 0.0f;
        if(_S542)
        {
            _S538 = (lobes_2.n_dot_h) > 0.0f;
        }
        else
        {
            _S538 = false;
        }
        if(_S538)
        {
            _S538 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S538 = false;
        }
        float _S543 = _slang_select(_S538, _S541,0.0f);
        pdf_h_0 = _S543;
    }
    else
    {
        pdf_h_0 = _S539;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float n_i_dot_l_1, float l_dot_h_1, float n_i_dot_v_2, float alpha_7, BSDFLobes lobes_3, float eta_i_4, float eta_o_4)
{
    float _S544 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    float _S545 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    float _S546 = lobes_3.p_refract * _S544 * eta_o_4 * eta_o_4 * (F32_abs((l_dot_h_1))) / (_S545 * _S545);
    bool _S547 = eta_i_4 != eta_o_4;
    bool _S548;
    if(_S547)
    {
        _S548 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S548 = false;
    }
    float _S549 = _slang_select(_S548, _S546,0.0f);
    return _S549;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_5, float alpha_8, BSDFMaterial material_6, BSDFLobes lobes_4)
{
    float _S550 = - dot_0(n_i_5, l_1);
    float _S551 = smithG1(alpha_8, (F32_max((_S550), (0.0f))));
    bool _S552 = (lobes_4.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S552)
    {
        float3  _S553 = negate_0(n_i_5);
        float3  _S554 = anisotropicLocal(l_1, lobes_4.tangent, _S553);
        float _S555 = anisotropicG1(_S554, lobes_4.alphas);
        G1_l_0 = _S555;
    }
    else
    {
        G1_l_0 = _S551;
    }
    return lobes_4.refract_weight * make_float3 (G1_l_0) * material_6.albedo / make_float3 (lobes_4.p_refract);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_2, float l_dot_h_2, float n_i_dot_v_3, float alpha_9, BSDFLobes lobes_5, float eta_i_5, float eta_o_5)
{
    float _S556 = lobes_5.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S557 = n_i_dot_l_2 > 0.0f;
    bool _S558;
    if(_S557)
    {
        _S558 = n_i_dot_v_3 > 0.0f;
    }
    else
    {
        _S558 = false;
    }
    float _S559 = _slang_select(_S558, _S556,0.0f);
    return _S559;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  n_i_6, float alpha_10, BSDFMaterial material_7, BSDFLobes lobes_6)
{
    float3  _S560 = l_2 + lobes_6.view;
    float3  _S561 = ((((_S560)) * make_float3(rnorm3df(((_S560)).x, ((_S560)).y, ((_S560)).z))));
    float _S562 = dot_0(n_i_6, _S561);
    float _S563 = (F32_max((dot_0(n_i_6, l_2)), (0.0f)));
    float _S564 = (F32_max((dot_0(n_i_6, lobes_6.view)), (0.0f)));
    float _S565 = 1.0f / (F32_max((material_7.sheen_roughness), (0.05000000074505806f)));
    float _S566 = 1.0f - _S562 * _S562;
    float _S567 = (2.0f + _S565) * (F32_pow(((F32_max((_S566), (0.0f)))), (0.5f * _S565))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S563 + _S564 - _S563 * _S564)), (0.0000152587890625f)));
    bool _S568 = (material_7.velvet) > 0.0f;
    float f_1;
    if(_S568)
    {
        float _S569 = (F32_max((material_7.sheen_roughness), (0.00999999977648258f)));
        float _S570 = _S569 * _S569;
        float _S571 = (F32_max((_S566), (0.0000152587890625f)));
        float _S572 = (F32_exp((- _S562 * _S562 / (_S571 * _S570)))) / (3.14159274101257324f * _S570 * _S571 * _S571) * (F32_min((1.0f), (2.0f * _S562 * (F32_min((_S563), (_S564))) / (F32_max(((F32_abs((dot_0(_S561, lobes_6.view))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S563 * _S564), (0.0000152587890625f)));
        f_1 = _S572;
    }
    else
    {
        f_1 = _S567;
    }
    return lobes_6.sheen * make_float3 (f_1 * _S563 * 2.0f * 3.14159274101257324f / lobes_6.p_sheen_velvet);
}

__device__ __forceinline__ float toonPDF(float n_i_dot_l_3, float l_dot_h_3, float n_i_dot_v_4, float alpha_11, BSDFLobes lobes_7, float eta_i_6, float eta_o_6)
{
    float _S573 = _slang_select(lobes_7.toon_glossy, l_dot_h_3,n_i_dot_l_3);
    float _S574 = (F32_acos((clamp_1(_S573, -1.0f, 1.0f))));
    float _S575;
    if(_S574 < (lobes_7.toon_a))
    {
        _S575 = 1.0f;
    }
    else
    {
        _S575 = (F32_max((1.0f - (_S574 - lobes_7.toon_a) / (F32_max((lobes_7.toon_s), (0.0000152587890625f)))), (0.0f)));
    }
    float _S576 = lobes_7.p_toon * _S575;
    float _S577 = _slang_select(lobes_7.toon_glossy, 1.0f,n_i_dot_l_3);
    float _S578 = _S576 * _S577 / lobes_7.toon_norm;
    bool _S579;
    if(lobes_7.toon_glossy)
    {
        _S579 = true;
    }
    else
    {
        _S579 = n_i_dot_l_3 > 0.0f;
    }
    float _S580 = _slang_select(_S579, _S578,0.0f);
    return _S580;
}

__device__ __forceinline__ float3  toonBSDF(float3  l_3, float3  n_i_7, float alpha_12, BSDFMaterial material_8, BSDFLobes lobes_8)
{
    float _S581 = (F32_max((dot_0(n_i_7, l_3)), (0.0f)));
    float _S582 = _slang_select(lobes_8.toon_glossy, _S581,lobes_8.toon_view);
    return lobes_8.toon * make_float3 (_S582) / make_float3 (lobes_8.p_toon);
}

__device__ __forceinline__ float reflectPDF(float n_i_dot_l_4, float l_dot_h_4, float n_i_dot_v_5, float alpha_13, BSDFLobes lobes_9, float eta_i_7, float eta_o_7)
{
    float _S583 = vndfPDF(n_i_dot_v_5, alpha_13, lobes_9);
    float _S584 = lobes_9.p_reflect * _S583 / (4.0f * lobes_9.v_dot_h);
    bool _S585 = _S583 > 0.0f;
    float _S586 = _slang_select(_S585, _S584,0.0f);
    return _S586;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_4, float3  n_i_8, float alpha_14, BSDFMaterial material_9, BSDFLobes lobes_10)
{
    float _S587 = dot_0(n_i_8, l_4);
    float _S588 = smithG1(alpha_14, (F32_max((_S587), (0.0f))));
    bool _S589 = (lobes_10.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S589)
    {
        float3  _S590 = anisotropicLocal(l_4, lobes_10.tangent, n_i_8);
        float _S591 = anisotropicG1(_S590, lobes_10.alphas);
        G1_l_1 = _S591;
    }
    else
    {
        G1_l_1 = _S588;
    }
    return make_float3 (lobes_10.reflect_weight * G1_l_1) * lobes_10.F / make_float3 (lobes_10.p_reflect);
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_4, float3  out_dir_2, float3  n_7, BSDFMaterial material_10, float eta_i_8, float eta_o_8, bool refracted_2, uint random_state_4, FixedArray<float3 , 5>  * throughputs_0, FixedArray<float, 5>  * pdfs_0)
{
    float3  ggx_n_1;
    float3  _S592 = negate_0(in_dir_4);
    float _S593 = dot_0(n_7, _S592);
    float _S594 = sign_0(_S593);
    float3  _S595 = n_7 * make_float3 (_S594);
    AnisotropicFrame _S596 = anisotropicFrame(material_10, _S595);
    float _S597 = dot_0(_S595, out_dir_2);
    float _S598 = material_10.roughness;
    float _S599 = _S598 * _S598;
    SheenProfile _S600 = sheenProfile(_S592, _S595, material_10);
    float _S601 = rgb_to_greyscale(material_10.translucent);
    bool _S602 = _S601 > 0.0f;
    bool _S603 = (dot_0(n_7, out_dir_2) * _S593) < 0.0f;
    uint _S604;
    if((F32_abs((material_10.toon.x))) > 0.0f)
    {
        _S604 = 5U;
    }
    else
    {
        _S604 = 4U;
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
        float3  _S605 = make_float3 (0.0f);
        (*throughputs_0)[i_6] = _S605;
        (*pdfs_0)[i_6] = 0.0f;
        uint i_7 = i_6 + 1U;
        i_6 = i_7;
    }
    float3  _S606 = make_float3 (0.0f);
    BSDFLobes _S607 = BSDFLobes_x24init_0(0.0f, 0.0f, _S606, _S606, 0.0f, 0.0f, _S606, _S606, 0.0f, 0.0f, 0.0f, 0.0f, _S606, 0.0f, _S606, _S606, make_float2 (0.0f), 0.0f, 0.0f, _S606, 0.0f, 0.0f, 0.0f, false, 1.0f, 0.0f, _S606);
    BSDFLobes lobe_terms_0 = _S607;
    uint half_of_0 = 4294967295U;
    float3  ggx_n_2 = _S606;
    i_6 = 0U;
    for(;;)
    {
        if(i_6 < _S604)
        {
        }
        else
        {
            break;
        }
        uint _S608;
        if(i_6 == 3U)
        {
            _S608 = 4U;
        }
        else
        {
            if(i_6 == 4U)
            {
                _S608 = 6U;
            }
            else
            {
                _S608 = i_6;
            }
        }
        bool _S609 = _S608 == 0U;
        bool _S610;
        if(_S609)
        {
            _S610 = _S602;
        }
        else
        {
            _S610 = false;
        }
        bool _S611;
        if(_S610)
        {
            _S611 = _S603;
        }
        else
        {
            _S611 = _S608 == 1U;
        }
        bool _S612 = _S611 != refracted_2;
        if(_S612)
        {
            ggx_n_1 = ggx_n_2;
            uint i_8 = i_6 + 1U;
            ggx_n_2 = ggx_n_1;
            i_6 = i_8;
            continue;
        }
        uint _S613;
        if(_S608 == 6U)
        {
            _S613 = 0U;
        }
        else
        {
            if(_S608 == 4U)
            {
                _S613 = 2U;
            }
            else
            {
                _S613 = _S608;
            }
        }
        bool _S614 = _S613 != half_of_0;
        uint half_of_1;
        if(_S614)
        {
            bool _S615 = _S613 == 0U;
            if(_S615)
            {
                float3  _S616 = sampledHalf(in_dir_4, n_7, material_10, random_state_4, _S596);
                ggx_n_1 = _S616;
            }
            else
            {
                bool _S617 = _S613 == 1U;
                if(_S617)
                {
                    float3  _S618 = refractedHalf(in_dir_4, out_dir_2, n_7, eta_i_8, eta_o_8);
                    ggx_n_1 = _S618;
                }
                else
                {
                    float3  _S619 = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_1 = _S619;
                }
            }
            float3  _S620 = negate_0(in_dir_4);
            BSDFLobes _S621 = bsdfLobes(in_dir_4, _S620, _S595, ggx_n_1, material_10, eta_i_8, eta_o_8, _S596, _S600);
            lobe_terms_0 = _S621;
            float _S622 = translucentShare(material_10);
            (&lobe_terms_0)->translucent_share = _S622;
            half_of_1 = _S613;
        }
        else
        {
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S608)
        {
        case 0U:
            {
                float _S623 = diffusePDF(_S597, 0.0f, (F32_abs((_S593))), _S599, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(0)] = _S623;
                float3  _S624 = diffuseBSDF(out_dir_2, _S595, _S599, material_10, lobe_terms_0);
                (*throughputs_0)[int(0)] = _S624;
                break;
            }
        case 1U:
            {
                float _S625 = refractPDF(_S597, dot_0(out_dir_2, ggx_n_1), (F32_abs((_S593))), _S599, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(1)] = _S625;
                float3  _S626 = refractBSDF(out_dir_2, _S595, _S599, material_10, lobe_terms_0);
                (*throughputs_0)[int(1)] = _S626;
                break;
            }
        case 4U:
            {
                float _S627 = sheenVelvetPDF(_S597, 0.0f, (F32_abs((_S593))), _S599, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(3)] = _S627;
                float3  _S628 = sheenVelvetBSDF(out_dir_2, _S595, _S599, material_10, lobe_terms_0);
                (*throughputs_0)[int(3)] = _S628;
                break;
            }
        case 6U:
            {
                float _S629 = toonPDF(_S597, dot_0(out_dir_2, (&lobe_terms_0)->toon_axis), (F32_abs((_S593))), _S599, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(4)] = _S629;
                float3  _S630 = toonBSDF(out_dir_2, _S595, _S599, material_10, lobe_terms_0);
                (*throughputs_0)[int(4)] = _S630;
                break;
            }
        default:
            {
                float _S631 = reflectPDF(_S597, 0.0f, (F32_abs((_S593))), _S599, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(2)] = _S631;
                float3  _S632 = reflectBSDF(out_dir_2, _S595, _S599, material_10, lobe_terms_0);
                (*throughputs_0)[int(2)] = _S632;
                break;
            }
        }
        half_of_0 = half_of_1;
        uint i_8 = i_6 + 1U;
        ggx_n_2 = ggx_n_1;
        i_6 = i_8;
    }
    i_6 = 0U;
    ggx_n_1 = _S606;
    for(;;)
    {
        if(i_6 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S633 = ((*pdfs_0)[i_6]) > 0.0f;
        if(_S633)
        {
            float3  f_2 = ggx_n_1 + (*throughputs_0)[i_6] * make_float3 ((*pdfs_0)[i_6]);
            ggx_n_1 = f_2;
        }
        uint i_9 = i_6 + 1U;
        i_6 = i_9;
    }
    return ggx_n_1;
}

static __device__ __forceinline__ float3  skyLobes_0(float3  in_dir_5, float3  dir_4, FKSurface * surface_1, float2  eta_1, bool is_inside_2, float pdf_0, uint random_state_5, FixedArray<float3 , 5>  * terms_0, FixedArray<float, 5>  * pdfs_1)
{
    bool _S634 = wrongSide_0(is_inside_2, false, dir_4, surface_1->geometry_n);
    float3  _S635 = BSDF(in_dir_5, dir_4, surface_1->smooth_n, surface_1->material, eta_1.x, eta_1.y, _S634, random_state_5, terms_0, pdfs_1);
    float3  _S636 = make_float3 (0.0f);
    uint i_10 = 0U;
    float3  f_3 = _S636;
    for(;;)
    {
        if(i_10 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S637 = ((*pdfs_1)[i_10]) > 0.0f;
        if(_S637)
        {
            float3  _S638 = (*terms_0)[i_10] * make_float3 ((*pdfs_1)[i_10]) / make_float3 ((*pdfs_1)[i_10] + pdf_0);
            (*terms_0)[i_10] = _S638;
            float3  f_4 = f_3 + (*terms_0)[i_10];
            f_3 = f_4;
        }
        uint i_11 = i_10 + 1U;
        i_10 = i_11;
    }
    return f_3;
}

__device__ float3  skyBSDF(float3  in_dir_6, float3  dir_5, FKSurface surface_2, float2  eta_2, bool is_inside_3, float pdf_1, uint random_state_6)
{
    FKSurface _S639 = surface_2;
    FixedArray<float3 , 5>  terms_1;
    FixedArray<float, 5>  pdfs_2;
    float3  _S640 = skyLobes_0(in_dir_6, dir_5, &_S639, eta_2, is_inside_3, pdf_1, random_state_6, &terms_1, &pdfs_2);
    return _S640;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_6, float3  radiance_0, float3  color_0, uint random_state_7)
{
    SkySample _S641;
    (&_S641)->dir = dir_6;
    (&_S641)->radiance = radiance_0;
    (&_S641)->color = color_0;
    (&_S641)->random_state = random_state_7;
    return _S641;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_3, float2  eta_3, bool is_inside_4, uint init_random_state_0, uint lobe_state_0, ShadowContext * context_2)
{
    uint2  _S642 = (fcptEnvironmentCdfSize());
    uint2  _S643 = make_uint2 (1U, 0U);
    uint2  _S644 = _S642 - _S643;
    Random _S645 = pcg(init_random_state_0);
    Random _S646 = pcg(_S645.state);
    Random _S647 = pcg(_S646.state);
    Random _S648 = pcg(_S647.state);
    uint _S649 = _S644.x;
    uint _S650 = searchCDF_0(make_uint2 (_S649, 0U), make_uint2 (0U, 1U), _S644.y, _S645.value);
    uint _S651 = searchCDF_0(make_uint2 (0U, _S650), _S643, _S649, _S646.value);
    float2  _S652 = make_float2 ((float)_S644.x, (float)_S644.y);
    float2  _S653 = (make_float2 (float(_S651), float(_S650)) + make_float2 (_S647.value, _S648.value)) / _S652 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S654 = _S653.y;
    float _S655 = (F32_sin((_S654)));
    float _S656 = _S653.x;
    float3  _S657 = skyFrame_0(make_float3 (_S655 * (F32_cos((_S656))), (F32_cos((_S654))), _S655 * (F32_sin((_S656)))));
    float _S658 = environmentPdf_0(_S657);
    float3  _S659 = skyBSDF(ray_0->unit_direction, _S657, *surface_3, eta_3, is_inside_4, _S658, lobe_state_0);
    bool _S660 = !(_S658 > 0.0f);
    bool _S661;
    if(_S660)
    {
        _S661 = true;
    }
    else
    {
        _S661 = all_1(_S659 == make_float3 (0.0f));
    }
    if(_S661)
    {
        float3  _S662 = make_float3 (0.0f);
        return SkySample_x24init_0(_S657, _S662, _S662, _S648.state);
    }
    float3  _S663 = skyRadiance_0(ray_0->origin, surface_3, is_inside_4, _S657, context_2, _S648.state);
    return SkySample_x24init_0(_S657, _S663, _S659 * _S663, _S648.state);
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
    SampleBSDF _S664 = (fcptConnectHair((surface_4->hair), ((&surface_4->material)->albedo), ((&surface_4->material)->specular_tint), (in_dir_7), (light_1->dir)));
    float3  _S665 = _S664.throughput * make_float3 (_S664.pdf);
    float _S666 = light_1->density;
    float _S667 = 1.0f + _S664.pdf * _S664.pdf / (light_1->density * light_1->density);
    bool _S668;
    if(competing_0)
    {
        _S668 = _S666 > 0.0f;
    }
    else
    {
        _S668 = false;
    }
    float _S669 = _slang_select(_S668, _S667,1.0f);
    return _S665 / make_float3 (_S669) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_7, float3  radiance_1, float density_0, uint random_state_8)
{
    TreeSample _S670;
    (&_S670)->dir = dir_7;
    (&_S670)->radiance = radiance_1;
    (&_S670)->density = density_0;
    (&_S670)->random_state = random_state_8;
    return _S670;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_11, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S671 = importance(first_1, p_11, normal_3);
    float _S672 = importance(second_1, p_11, normal_3);
    float2  _S673 = make_float2 (_S671, _S672);
    bool _S674 = _S671 == 0.0f;
    bool _S675;
    if(_S674)
    {
        _S675 = _S672 == 0.0f;
    }
    else
    {
        _S675 = false;
    }
    if(_S675)
    {
        return 2U;
    }
    float _S676 = _S671 + _S672;
    bool _S677 = _S672 > 0.0f;
    if(_S677)
    {
        _S675 = (*pick_0 * _S676) >= _S671;
    }
    else
    {
        _S675 = false;
    }
    uint _S678 = uint(_S675);
    float _S679 = (F32_min(((*pick_0 * _S676 - float(_S678) * _S671) / _slang_vector_get_element(_S673, _S678)), (0.99999994039535522f)));
    *pick_0 = _S679;
    float _S680 = *probability_3 * (_slang_vector_get_element(_S673, _S678) / _S676);
    *probability_3 = _S680;
    return _S678;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_12, float u1_0, float u2_0)
{
    float3  _S681 = center_1 - p_12;
    float _S682 = radius_1 * radius_1 / dot_0(_S681, _S681);
    float _S683 = u1_0 * _S682 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S682), (0.0f)))))));
    float _S684 = 2.0f * u1_0;
    bool _S685 = _S682 >= 1.0f;
    float _S686 = _slang_select(_S685, _S684,_S683);
    float _S687 = (F32_sqrt(((F32_max((_S686 * (2.0f - _S686)), (0.0f))))));
    float _S688 = 6.28318548202514648f * u2_0;
    float3  _S689 = make_float3 (_S687 * (F32_cos((_S688))), 1.0f - _S686, _S687 * (F32_sin((_S688))));
    float3  _S690 = ((((_S681)) * make_float3(rnorm3df(((_S681)).x, ((_S681)).y, ((_S681)).z))));
    float3  _S691 = tangentToWorld(_S689, _S690);
    return _S691;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S692 = center_2 - ray_1->origin;
    float _S693 = dot_0(_S692, ray_1->unit_direction);
    float _S694 = dot_0(_S692, _S692) - _S693 * _S693;
    float _S695 = radius_3 * radius_3;
    bool _S696 = _S694 > _S695;
    if(_S696)
    {
        return 4.294967296e+09f;
    }
    float _S697 = (F32_sqrt((_S695 - _S694)));
    float _S698 = _S693 - _S697;
    float _S699 = _S693 + _S697;
    bool _S700 = _S698 > 0.0000152587890625f;
    bool _S701;
    if(_S700)
    {
        _S701 = _S698 < max_len_0;
    }
    else
    {
        _S701 = false;
    }
    if(_S701)
    {
        return _S698;
    }
    bool _S702 = _S699 > 0.0000152587890625f;
    if(_S702)
    {
        _S701 = _S699 < max_len_0;
    }
    else
    {
        _S701 = false;
    }
    if(_S701)
    {
        return _S699;
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

static __device__ float3  emitted_0(float3  emissive_0, float3  dir_8, float3  n_8)
{
    float _S703 = sign_0(dot_0(- dir_8, n_8));
    float3  _S704 = emissive_0 * make_float3 ((F32_max((_S703), (0.0f))));
    bool _S705 = ((true));
    float3  _S706 = _slang_select(_S705, emissive_0,_S704);
    return _S706;
}

static __device__ __forceinline__ TreeSample sampleLightTree_0(float3  origin_4, float3  smooth_n_2, float3  geometry_n_1, float geometry_offset_1, bool sided_0, uint init_random_state_1, ShadowContext * context_3)
{
    Random _S707 = pcg(init_random_state_1);
    Random _S708 = pcg(_S707.state);
    Random _S709 = pcg(_S708.state);
    float3  _S710 = make_float3 (0.0f);
    TreeSample _S711 = TreeSample_x24init_0(_S710, _S710, 0.0f, _S709.state);
    TreeSample sample_0 = _S711;
    float3  _S712 = _slang_select(sided_0, _S710,smooth_n_2);
    float3  _S713 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S707.value;
    float probability_4 = 1.0f;
    uint n_9 = 0U;
    for(;;)
    {
        uint4  _S714 = (fcptLightNode((n_9)));
        if((_S714.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S715 = (fcptLightSecond((n_9)));
        uint _S716 = n_9 + 1U;
        LightNode _S717 = (fcptLightBounds((_S716)));
        LightNode _S718 = (fcptLightBounds((_S715)));
        uint _S719 = pickChild(_S717, _S718, origin_4, _S712, &pick_1, &probability_4);
        bool _S720 = _S719 > 1U;
        if(_S720)
        {
            return sample_0;
        }
        bool _S721 = _S719 == 1U;
        uint _S722 = _slang_select(_S721, _S715,_S716);
        n_9 = _S722;
    }
    bool _S723 = n_9 == 0U;
    bool _S724;
    if(_S723)
    {
        LightNode _S725 = (fcptLightBounds((0U)));
        float _S726 = importance(_S725, origin_4, _S712);
        _S724 = !(_S726 > 0.0f);
    }
    else
    {
        _S724 = false;
    }
    if(_S724)
    {
        return sample_0;
    }
    uint4  _S727 = (fcptLightNode((n_9)));
    FKHit _S728 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S729 = (_S727.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S729)
    {
        FKLight _S730 = (fcptLight((_S727.y)));
        if(sided_0)
        {
            float _S731 = sign_0(dot_0(geometry_n_1, _S730.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S731);
            float3  _S732 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S732;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S713;
            lift_n_0 = smooth_n_2;
        }
        bool _S733 = (_S730.variance) == 0.0f;
        if(_S733)
        {
            float3  _S734 = _S730.position - emitter_point_0;
            float3  _S735 = ((((_S734)) * make_float3(rnorm3df(((_S734)).x, ((_S734)).y, ((_S734)).z))));
            (&sample_0)->dir = _S735;
            float3  _S736 = _S730.color * make_float3 (_S730.intensity) / make_float3 (dot_0(_S734, _S734) * probability_4);
            (&sample_0)->radiance = _S736;
            shadow_1 = _S734;
        }
        else
        {
            float3  _S737 = sampleSphere(_S730.position, _S730.variance, emitter_point_0, _S708.value, _S709.value);
            (&sample_0)->dir = _S737;
            float _S738 = sphereDensity(_S730.position, _S730.variance, emitter_point_0);
            float _S739 = probability_4 * _S738;
            (&sample_0)->density = _S739;
            float3  _S740 = pointLightRadiance(_S730.color, _S730.intensity, _S730.variance);
            float3  _S741 = _S740 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S741;
            FKRay _S742 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S743 = raySphere_0(_S730.position, _S730.variance, &_S742, 4.294967296e+09f);
            float3  _S744 = (&sample_0)->dir * make_float3 (_S743);
            shadow_1 = _S744;
        }
        emitter_0 = _S728;
        emitter_point_0 = _S710;
    }
    else
    {
        uint _S745 = _S727.y;
        uint _S746 = (fcptTriangleOffset((_S745)));
        uint _S747 = _S746 + _S727.z;
        Matrix<float, 3, 3>  _S748 = (fcptWorldTriangle((_S745), (_S747)));
        float _S749 = (F32_sqrt((_S708.value)));
        float2  _S750 = make_float2 (_S749 * (1.0f - _S709.value), _S749 * _S709.value);
        float3  _S751 = mul_0(make_float3 (1.0f - _S749, _S750.x, _S750.y), _S748);
        if(sided_0)
        {
            float _S752 = sign_0(dot_0(geometry_n_1, _S751 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S752);
            float3  _S753 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S753;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S754 = !((dot_0(smooth_n_2, _S751 - origin_4)) > 0.0f);
            if(_S754)
            {
                return sample_0;
            }
            emitter_point_0 = _S713;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S750, _S745, _S747, 0U, 0.0f);
        float3  _S755 = _S751 - emitter_point_0;
        float3  _S756 = ((((_S755)) * make_float3(rnorm3df(((_S755)).x, ((_S755)).y, ((_S755)).z))));
        (&sample_0)->dir = _S756;
        float _S757 = solidAngle(probability_4, cross_0(_S748.rows[int(1)] - _S748.rows[int(0)], _S748.rows[int(2)] - _S748.rows[int(0)]), _S755);
        (&sample_0)->density = _S757;
        bool _S758 = (fcptShadowFirst());
        bool _S759 = !_S758;
        if(_S759)
        {
            FKSurface _S760 = (fcptLightSurfaceAt((emitter_1), (_S751), (_S709.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S751 - origin_4))));
            (&sample_0)->random_state = _S760.random_state;
            float3  _S761 = emitted_0(_S760.material.emissive, (&sample_0)->dir, _S760.smooth_n);
            float3  _S762 = _slang_select(_S760.skip, _S710,_S761);
            float3  _S763 = _S762 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S763;
        }
        shadow_1 = _S755;
        emitter_0 = emitter_1;
        emitter_point_0 = _S751;
    }
    FKHit _S764 = emitter_0;
    float3  _S765 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S709.state, &_S764);
    bool _S766 = (fcptShadowFirst());
    if(_S766)
    {
        _S724 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S724 = false;
    }
    if(_S724)
    {
        _S724 = !all_1(_S765 == _S710);
    }
    else
    {
        _S724 = false;
    }
    if(_S724)
    {
        FKSurface _S767 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S709.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S767.random_state;
        float3  _S768 = emitted_0(_S767.material.emissive, (&sample_0)->dir, _S767.smooth_n);
        float3  _S769 = _slang_select(_S767.skip, _S710,_S768);
        float3  _S770 = _S769 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S770;
    }
    float3  _S771 = (&sample_0)->radiance * _S765;
    bool _S772 = all_1(_S765 == _S710);
    float3  _S773 = _slang_select(_S772, _S710,_S771);
    (&sample_0)->radiance = _S773;
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
    float _S774 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    bool _S775 = b_1 > 0.0f;
    float _S776 = _slang_select(_S775, _S774,1.0f);
    return _S776;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S777 = vertex_0->none;
    if(_S777)
    {
        return 1.0f;
    }
    uint _S778 = (fcptLightSlot((*hit_1)));
    float _S779 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S778, light_point_1);
    float _S780 = powerHeuristic(vertex_0->pdf, _S779);
    return _S780;
}

static __device__ float3  environment_0(float3  dir_9, uint depth_0, uint lobe_0)
{
    uint2  _S781 = (fcptEnvironmentMapSize());
    bool _S782 = all_0(_S781 > make_uint2 (1U));
    if(_S782)
    {
        float3  _S783 = (fcptEnvMapSample((dir_9), (depth_0), (lobe_0)));
        return _S783;
    }
    float3  _S784 = (fcptAmbient());
    return _S784;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S785 = (fcptEnvironmentCdfSize());
    bool _S786 = !all_0(_S785 > make_uint2 (1U));
    if(_S786)
    {
        return false;
    }
    uint2  _S787 = (fcptEnvironmentMapSize());
    return all_0(_S787 > make_uint2 (1U));
}

static __device__ float escapeWeight_0(float pdf_2, float3  dir_10)
{
    bool _S788 = pdf_2 <= 0.0f;
    bool _S789;
    if(_S788)
    {
        _S789 = true;
    }
    else
    {
        bool _S790 = environmentMapped_0();
        _S789 = !_S790;
    }
    if(_S789)
    {
        return 1.0f;
    }
    float _S791 = environmentPdf_0(dir_10);
    return pdf_2 / (pdf_2 + _S791);
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
    uint2  _S792 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S793 = make_int2 ((int)_S792.x, (int)_S792.y);
    uint _S794 = previousSeed_0(_S793);
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
            uint _S795 = previousSeed_0(_S793 + make_int2 (x_16, y_5));
            bool _S796 = _S795 == _S794;
            uint _S797 = _slang_select(_S796, 1U,0U);
            uint count_3 = count_2 + _S797;
            int x_17 = x_16 + int(1);
            x_16 = x_17;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S798 = float(count_2 - 1U) / 288.0f;
    bool _S799 = _S794 != 0U;
    float _S800 = _slang_select(_S799, _S798,0.0f);
    fcptStoreDuplication((_S793), (make_uint4 ((F32_asuint((_S800))), 0U, 0U, 0U)));
    return;
}

__device__ uint stream(uint seed_3, uint index_0)
{
    uint _S801 = hash(index_0);
    uint _S802 = hash(seed_3 ^ _S801);
    return _S802;
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
    float _S803 = rgb_to_greyscale(weight_0);
    bool _S804 = _S803 > 0.0f;
    bool _S805;
    if(_S804)
    {
        _S805 = _S803 < 3.00000000549775576e+38f;
    }
    else
    {
        _S805 = false;
    }
    bool _S806 = !_S805;
    if(_S806)
    {
        return;
    }
    bool _S807 = sel_2->sums;
    if(_S807)
    {
        float3  _S808 = sel_2->color + weight_0;
        sel_2->color = _S808;
        return;
    }
    float _S809 = sel_2->w_sum + _S803;
    sel_2->w_sum = _S809;
    float3  _S810 = sel_2->color + weight_0;
    sel_2->color = _S810;
    Random _S811 = pcg(sel_2->random_state);
    sel_2->random_state = _S811.state;
    bool _S812 = (_S811.value * sel_2->w_sum) <= _S803;
    if(_S812)
    {
        sel_2->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_3;
    float3  _S813 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S813;
    float _S814 = r_3.jac * shifted_0.jac;
    (&candidate_1)->jac = _S814;
    offer(sel_3, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S815 = rgb_to_greyscale((&r_4)->f);
    float _S816 = sel_4.w_sum / _S815;
    bool _S817 = _S815 > 0.0f;
    float _S818 = _slang_select(_S817, _S816,0.0f);
    (&r_4)->w = _S818;
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
    uint2  _S819 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S820 = make_int2 ((int)_S819.x, (int)_S819.y);
    float3  _S821 = make_float3 (0.0f);
    FKHit _S822 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S823 = Domain_x24init_0(_S821, _S821, &_S822, 0.0f, 0.0f);
    Domain dom_4 = _S823;
    bool _S824 = (fcptCurrentDomain((_S820), (&dom_4)));
    bool _S825 = !_S824;
    if(_S825)
    {
        Reservoir _S826 = (Reservoir{});
        fcptStoreReservoirPrevious((_S820), (_S826), ((&dom_4)->hit));
        return;
    }
    Reservoir _S827 = (fcptLoadReservoirTemporal((_S820)));
    uint t_12 = 0U;
    float count_4 = 0.0f;
    float c_sum_0 = _S827.c;
    for(;;)
    {
        uint _S828 = (fcptRestirNeighbours());
        if(t_12 < _S828)
        {
        }
        else
        {
            break;
        }
        int2  _S829 = partner_0(_S820, t_12);
        Domain neighbor_0 = _S823;
        bool _S830 = (fcptCurrentDomain((_S829), (&neighbor_0)));
        if(_S830)
        {
            float count_5 = count_4 + 1.0f;
            uint4  _S831 = (fcptReservoirTemporal((_S829), (0U)));
            float c_sum_1 = c_sum_0 + (U32_asfloat((_S831.w)));
            count_4 = count_5;
            c_sum_0 = c_sum_1;
        }
        uint t_13 = t_12 + 1U;
        t_12 = t_13;
    }
    float _S832 = _S827.c / (F32_max((count_4), (1.0f)));
    float _S833 = rgb_to_greyscale(_S827.f);
    bool _S834 = count_4 == 0.0f;
    float _S835 = _slang_select(_S834, 1.0f,0.0f);
    Selection _S836 = (Selection{});
    Selection sel_5 = _S836;
    uint _S837 = (fcptFrame());
    uint _S838 = hash(_S837);
    uint _S839 = global_invocation_id_2.x;
    uint2  _S840 = (fcptRenderSize());
    uint _S841 = stream(_S838, _S839 + _S840.x * global_invocation_id_2.y);
    uint _S842 = stream(_S841, 195U);
    (&sel_5)->random_state = _S842;
    t_12 = 0U;
    float canonical_mis_0 = _S835;
    for(;;)
    {
        uint _S843 = (fcptRestirNeighbours());
        if(t_12 < _S843)
        {
        }
        else
        {
            break;
        }
        int2  _S844 = partner_0(_S820, t_12);
        Domain neighbor_dom_0 = _S823;
        bool _S845 = (fcptCurrentDomain((_S844), (&neighbor_dom_0)));
        if(_S845)
        {
            Reservoir _S846 = (fcptLoadReservoirTemporal((_S844)));
            uint4  _S847 = (fcptShiftData((_S844), (t_12)));
            float4  _S848 = asfloat_0(_S847);
            uint4  _S849 = (fcptShiftData((_S820), (t_12)));
            float4  _S850 = asfloat_0(_S849);
            float _S851 = (_S846.c + _S832) / c_sum_0;
            bool _S852 = _S833 > 0.0f;
            float canonical_mis_1;
            if(_S852)
            {
                float _S853 = _S851 * _S832 * _S833;
                float _S854 = _S832 * _S833;
                float _S855 = rgb_to_greyscale(float3 {_S850.x, _S850.y, _S850.z});
                float canonical_mis_2 = canonical_mis_0 + _S853 / (_S854 + _S846.c * _S855);
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float _S856 = rgb_to_greyscale(_S846.f);
            float3  _S857 = float3 {_S848.x, _S848.y, _S848.z};
            Shift _S858 = Shift_x24init_0(_S857, _S848.w);
            float _S859 = _S851 * _S846.c * _S856;
            float _S860 = _S846.c * _S856;
            float _S861 = rgb_to_greyscale(_S857);
            offerShifted(&sel_5, _S846, _S858, _S859 / (_S860 + _S832 * _S861));
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_14 = t_12 + 1U;
        t_12 = t_14;
    }
    offerShifted(&sel_5, _S827, Shift_x24init_0(_S827.f, 1.0f), canonical_mis_0);
    Reservoir _S862 = finalize(sel_5, c_sum_0);
    fcptStoreReservoirPrevious((_S820), (_S862), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S820), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S820), (make_float4 ((&sel_5)->color.x, (&sel_5)->color.y, (&sel_5)->color.z, 0.0f)));
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
    uint _S863 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S864 = _S863 != 4294967295U;
    if(_S864)
    {
        uint2  _S865 = make_uint2 (_S863, _S863 >> 14U) & make_uint2 (16383U);
        int2  _S866 = make_int2 ((int)_S865.x, (int)_S865.y);
        ShiftJob _S867 = (ShiftJob{});
        ShiftJob shift_job_0 = _S867;
        Shift _S868 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S869 = _S863 >> 28U;
        bool _S870 = spatialJob_0(_S866, _S869, &shift_job_0, true);
        Shift shifted_1;
        if(_S870)
        {
            Domain _S871 = (&shift_job_0)->dom;
            Reservoir _S872 = (&shift_job_0)->r;
            Shift _S873 = passShift_0(&_S871, &_S872);
            shifted_1 = _S873;
        }
        else
        {
            shifted_1 = _S868;
        }
        fcptStoreShiftData((_S866), (_S869), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S874 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S875 = make_int2 ((int)_S874.x, (int)_S874.y);
    FixedArray<uint, 3>  _S876;
    spatialBins_0(_S875, &_S876);
    FixedArray<uint, 3>  _S877 = _S876;
    uint t_15 = 0U;
    for(;;)
    {
        if(t_15 < 3U)
        {
        }
        else
        {
            break;
        }
        bool _S878 = (_S877[t_15]) == 40U;
        if(_S878)
        {
            fcptStoreShiftData((_S875), (t_15), (make_uint4 (0U)));
        }
        uint t_16 = t_15 + 1U;
        t_15 = t_16;
    }
    FixedArray<uint, 3>  _S879 = _S877;
    queueShifts_0(_S875, &_S879, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S880 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S881 = make_int2 ((int)_S880.x, (int)_S880.y);
    FixedArray<uint, 3>  _S882;
    spatialBins_0(_S881, &_S882);
    FixedArray<uint, 3>  _S883 = _S882;
    countShifts_0(&_S883, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S884 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S885 = _S884 != 4294967295U;
    if(_S885)
    {
        uint2  _S886 = make_uint2 (_S884, _S884 >> 14U) & make_uint2 (16383U);
        int2  _S887 = make_int2 ((int)_S886.x, (int)_S886.y);
        ShiftJob _S888 = (ShiftJob{});
        ShiftJob shift_job_1 = _S888;
        Shift _S889 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S890 = _S884 >> 28U;
        bool _S891 = temporalJob_0(_S887, _S890, &shift_job_1, true);
        Shift shifted_2;
        if(_S891)
        {
            if(_S890 == 1U)
            {
                Shift _S892 = (fcptShiftPrevious(((&shift_job_1)->dom), ((&shift_job_1)->r)));
                shifted_2 = _S892;
            }
            else
            {
                Domain _S893 = (&shift_job_1)->dom;
                Reservoir _S894 = (&shift_job_1)->r;
                Shift _S895 = passShift_0(&_S893, &_S894);
                shifted_2 = _S895;
            }
        }
        else
        {
            shifted_2 = _S889;
        }
        fcptStoreTemporalShift((_S887), (_S890), (make_uint4 (asuint_1(shifted_2.f).x, asuint_1(shifted_2.f).y, asuint_1(shifted_2.f).z, (F32_asuint((shifted_2.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S896 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S897 = make_int2 ((int)_S896.x, (int)_S896.y);
    FixedArray<uint, 3>  _S898;
    temporalBins_0(_S897, &_S898);
    FixedArray<uint, 3>  _S899 = _S898;
    uint t_17 = 0U;
    for(;;)
    {
        if(t_17 < 2U)
        {
        }
        else
        {
            break;
        }
        bool _S900 = (_S899[t_17]) == 40U;
        if(_S900)
        {
            fcptStoreTemporalShift((_S897), (t_17), (make_uint4 (0U)));
        }
        uint t_18 = t_17 + 1U;
        t_17 = t_18;
    }
    FixedArray<uint, 3>  _S901 = _S899;
    queueShifts_0(_S897, &_S901, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S902 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S903 = make_int2 ((int)_S902.x, (int)_S902.y);
    bool _S904 = (fcptSceneUnchanged());
    bool _S905 = !_S904;
    bool _S906;
    if(_S905)
    {
        uint2  _S907 = (fcptRenderSize());
        int2  _S908 = make_int2 ((int)_S907.x, (int)_S907.y);
        _S906 = all_0(_S903 < _S908);
    }
    else
    {
        _S906 = false;
    }
    if(_S906)
    {
        Reservoir _S909 = (fcptLoadReservoirInitial((_S903)));
        int2  _S910 = sampleNeighbor_0(_S903, _S909.seed);
        fcptStoreTemporalNeighbor((_S903), (_S910));
    }
    FixedArray<uint, 3>  _S911;
    temporalBins_0(_S903, &_S911);
    FixedArray<uint, 3>  _S912 = _S911;
    countShifts_0(&_S912, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_6, float b_2, float t_19)
{
    return a_6 + (b_2 - a_6) * t_19;
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S913 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S914 = make_int2 ((int)_S913.x, (int)_S913.y);
    float3  _S915 = make_float3 (0.0f);
    FKHit _S916 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S917 = Domain_x24init_0(_S915, _S915, &_S916, 0.0f, 0.0f);
    Domain dom_5 = _S917;
    bool _S918 = (fcptCurrentDomain((_S914), (&dom_5)));
    bool _S919 = !_S918;
    if(_S919)
    {
        Reservoir _S920 = (Reservoir{});
        fcptStoreReservoirTemporal((_S914), (_S920), ((&dom_5)->hit));
        return;
    }
    Reservoir _S921 = (fcptLoadReservoirInitial((_S914)));
    bool _S922 = (fcptSceneUnchanged());
    int2  _S923;
    if(_S922)
    {
        int2  _S924 = sampleNeighbor_0(_S914, _S921.seed);
        _S923 = _S924;
    }
    else
    {
        int2  _S925 = (fcptLoadTemporalNeighbor((_S914)));
        _S923 = _S925;
    }
    bool _S926 = (_S923.x) >= int(0);
    Reservoir r_5;
    if(_S926)
    {
        Reservoir _S927 = (fcptLoadReservoirPrevious((_S923)));
        uint4  _S928 = (fcptDuplication((_S923)));
        float _S929 = (U32_asfloat((_S928.x)));
        uint _S930 = (fcptRestirDecorrelation());
        bool _S931 = _S930 == 1U;
        float _S932 = _slang_select(_S931, _S929,0.0f);
        float _S933 = interpolate_0(20.0f, 1.0f, (F32_pow((_S932), (0.10000000149011612f))));
        float _S934 = (F32_min((_S927.c), (_S933)));
        bool _S935 = (fcptSceneUnchanged());
        float4  _S936;
        if(_S935)
        {
            _S936 = make_float4 (_S927.f.x, _S927.f.y, _S927.f.z, 1.0f);
        }
        else
        {
            uint4  _S937 = (fcptTemporalShift((_S914), (0U)));
            _S936 = asfloat_0(_S937);
        }
        Domain own_1 = _S917;
        bool _S938;
        if(_S935)
        {
            _S938 = true;
        }
        else
        {
            bool _S939 = (fcptPreviousScenes());
            bool _S940 = !_S939;
            if(_S940)
            {
                _S938 = (_S921.w) > 0.0f;
            }
            else
            {
                _S938 = false;
            }
            if(_S938)
            {
                bool _S941 = (fcptStoredDomainInitial((_S914), (_S921.seed), (&own_1)));
                _S938 = _S941;
            }
            else
            {
                _S938 = false;
            }
            if(_S938)
            {
                Domain _S942 = (fcptPreviousDomain((_S923), (_S921.seed)));
                Domain _S943 = _S942;
                Domain _S944 = own_1;
                bool _S945 = sameDomain_0(&_S943, &_S944);
                _S938 = _S945;
            }
            else
            {
                _S938 = false;
            }
        }
        float4  _S946;
        if(_S938)
        {
            _S946 = make_float4 (_S921.f.x, _S921.f.y, _S921.f.z, 1.0f);
        }
        else
        {
            uint4  _S947 = (fcptTemporalShift((_S914), (1U)));
            _S946 = asfloat_0(_S947);
        }
        float _S948 = rgb_to_greyscale(_S921.f);
        float _S949 = rgb_to_greyscale(_S927.f);
        Selection _S950 = (Selection{});
        Selection sel_6 = _S950;
        uint _S951 = (fcptFrame());
        uint _S952 = hash(_S951);
        uint _S953 = global_invocation_id_7.x;
        uint2  _S954 = (fcptRenderSize());
        uint _S955 = stream(_S952, _S953 + _S954.x * global_invocation_id_7.y);
        uint _S956 = stream(_S955, 194U);
        (&sel_6)->random_state = _S956;
        float _S957 = _S921.c * _S948;
        float4  _S958 = _S946;
        float _S959 = rgb_to_greyscale(float3 {_S958.x, _S958.y, _S958.z});
        float _S960 = _S957 / (_S957 + _S934 * _S959);
        float _S961 = _S934 * _S949;
        float4  _S962 = _S936;
        float3  _S963 = float3 {_S962.x, _S962.y, _S962.z};
        float _S964 = rgb_to_greyscale(_S963);
        float _S965 = _S961 / (_S961 + _S921.c * _S964);
        float2  _S966 = make_float2 (_S960, _S965);
        offerShifted(&sel_6, _S921, Shift_x24init_0(_S921.f, 1.0f), _S960);
        offerShifted(&sel_6, _S927, Shift_x24init_0(_S963, _S936.w), _S965);
        Reservoir _S967 = finalize(sel_6, _S921.c + _S934);
        r_5 = _S967;
    }
    else
    {
        r_5 = _S921;
    }
    fcptStoreReservoirTemporal((_S914), (r_5), ((&dom_5)->hit));
    return;
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S968 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S969 = make_int2 ((int)_S968.x, (int)_S968.y);
    float3  _S970 = make_float3 (0.0f);
    float2  _S971 = make_float2 (0.0f);
    FKHit _S972 = Hit_x24init_0(_S971, 0U, 0U, 0U, 0.0f);
    Domain _S973 = Domain_x24init_0(_S970, _S970, &_S972, 0.0f, 0.0f);
    Domain dom_6 = _S973;
    bool _S974 = (fcptCurrentDomain((_S969), (&dom_6)));
    bool _S975 = !_S974;
    if(_S975)
    {
        Reservoir _S976 = (Reservoir{});
        fcptStoreReservoirInitial((_S969), (_S976), ((&dom_6)->hit));
        return;
    }
    uint _S977 = (fcptFrame());
    uint _S978 = hash(_S977);
    uint _S979 = global_invocation_id_8.x;
    uint2  _S980 = (fcptRenderSize());
    uint _S981 = stream(_S978, _S979 + _S980.x * global_invocation_id_8.y);
    Selection _S982 = (Selection{});
    Selection initial_0 = _S982;
    uint _S983 = stream(_S981, 193U);
    (&initial_0)->random_state = _S983;
    bool _S984 = (fcptRestirUsed());
    bool _S985 = !_S984;
    (&initial_0)->sums = _S985;
    uint _S986 = stream(_S981, 0U);
    (&(&initial_0)->r)->seed = _S986;
    FKHit _S987 = Hit_x24init_0(_S971, 4294967295U, 0U, 0U, 0.0f);
    uint _S988 = (fcptSamples());
    float _S989 = 1.0f / float(_S988);
    FKHit hit_2 = _S987;
    uint i_17 = 0U;
    for(;;)
    {
        uint _S990 = (fcptSamples());
        if(i_17 < _S990)
        {
        }
        else
        {
            break;
        }
        Reservoir _S991 = (Reservoir{});
        Reservoir r_6 = _S991;
        uint _S992 = stream(_S981, i_17);
        (&r_6)->seed = _S992;
        Domain path_0 = _S973;
        bool _S993 = (fcptStoredDomainInitial((_S969), ((&r_6)->seed), (&path_0)));
        bool _S994 = !_S993;
        if(_S994)
        {
            fcptMissed((_S969), (path_0), (_S989));
            uint i_18 = i_17 + 1U;
            i_17 = i_18;
            continue;
        }
        Domain _S995 = path_0;
        Reservoir _S996 = r_6;
        Shift _S997 = passWalk_0(&_S995, &_S996, false, _S989, &initial_0);
        bool _S998 = ((&(&initial_0)->r)->seed) == ((&r_6)->seed);
        FKHit hit_3;
        if(_S998)
        {
            FKHit _S999 = (&path_0)->hit;
            hit_3 = _S999;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_18 = i_17 + 1U;
        i_17 = i_18;
    }
    float3  _S1000 = (&initial_0)->glow;
    float3  _S1001 = (&initial_0)->color;
    bool _S1002 = (&initial_0)->sums;
    float3  _S1003 = _slang_select(_S1002, _S1001,_S970);
    fcptAddColor((_S969), (make_float4 ((_S1000 + _S1003).x, (_S1000 + _S1003).y, (_S1000 + _S1003).z, 1.0f)));
    Reservoir _S1004 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S969), (_S1004), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_3, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S1005;
    (&_S1005)->none = none_0;
    (&_S1005)->pdf = pdf_3;
    (&_S1005)->origin = origin_5;
    (&_S1005)->smooth_n = smooth_n_3;
    (&_S1005)->start = start_6;
    return _S1005;
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
    Vertex _S1006;
    (&_S1006)->rough = rough_0;
    (&_S1006)->lobe = lobe_1;
    (&_S1006)->pdf = pdf_4;
    (&_S1006)->cos = cos_0;
    (&_S1006)->inside = inside_0;
    return _S1006;
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
    float3  _S1007 = exp_0((make_float3 (sigma_0) - extinction_0) * make_float3 (distance_2));
    float3  _S1008 = scatter_0 * _S1007 / make_float3 (sigma_0);
    float3  _S1009 = _slang_select(scatters_0, _S1008,_S1007);
    return _S1009;
}

static __device__ uint arrivalLobe_0(uint b_3, uint prev_lobe_0)
{
    bool _S1010 = b_3 > 0U;
    uint _S1011 = _slang_select(_S1010, prev_lobe_0,3U);
    return _S1011;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_2, bool surface_5, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S1012;
    (&_S1012)->extinction_behind = extinction_behind_0;
    (&_S1012)->extinction_front = extinction_front_0;
    (&_S1012)->fillings = fillings_0;
    (&_S1012)->side = side_0;
    (&_S1012)->depth = depth_1;
    (&_S1012)->lobe = lobe_2;
    (&_S1012)->surface = surface_5;
    (&_S1012)->length = length_2;
    (&_S1012)->width = width_1;
    (&_S1012)->own = *own_2;
    (&_S1012)->fiber = fiber_0;
    return _S1012;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S1013 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S1013)
    {
        return 0.07957746833562851f;
    }
    float _S1014 = g_0 * g_0;
    return (1.0f - _S1014) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S1014 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_7, float3  b_4)
{
    float3  _S1015 = a_7 / b_4;
    float3  _S1016 = make_float3 (0.0f);
    bool3  _S1017 = b_4 == _S1016;
    float3  _S1018 = _slang_select(_S1017, _S1016,_S1015);
    return _S1018;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_6)
{
    uint _S1019 = (1U << count_6) - 1U;
    return (e_2 & (~(_S1019 << offset_1))) | ((newbits_0 & _S1019) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_7, uint end_type_0, uint end_0, float3  f_5)
{
    Reservoir candidate_2 = r_7;
    uint _S1020 = insertBits_0(r_7.path, end_0, 0U, 5U);
    uint _S1021 = insertBits_0(_S1020, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S1021;
    (&candidate_2)->f = f_5;
    return candidate_2;
}

__device__ float survivalProbability(float3  throughput_0, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_0.x), ((F32_max((throughput_0.y), (throughput_0.z)))))) / density_1), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_9)
{
    Random _S1022 = pcg(random_state_9);
    Random _S1023 = pcg(_S1022.state);
    float _S1024 = 1.0f - 2.0f * _S1022.value;
    float _S1025 = (F32_sqrt(((F32_max((1.0f - _S1024 * _S1024), (0.0f))))));
    float _S1026 = 6.28318548202514648f * _S1023.value;
    return make_float3 (_S1025 * (F32_cos((_S1026))), _S1025 * (F32_sin((_S1026))), _S1024);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_11, uint random_state_10, float * pdf_5)
{
    bool _S1027 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1027)
    {
        *pdf_5 = 0.07957746833562851f;
        float3  _S1028 = isotropic_0(random_state_10);
        return _S1028;
    }
    Random _S1029 = pcg(random_state_10);
    Random _S1030 = pcg(_S1029.state);
    float _S1031 = g_1 * g_1;
    float _S1032 = 2.0f * g_1;
    float _S1033 = (1.0f - _S1031) / (1.0f - g_1 + _S1032 * _S1029.value);
    float _S1034 = clamp_1((1.0f + _S1031 - _S1033 * _S1033) / _S1032, -1.0f, 1.0f);
    float _S1035 = (F32_sqrt(((F32_max((1.0f - _S1034 * _S1034), (0.0f))))));
    float _S1036 = 6.28318548202514648f * _S1030.value;
    float _S1037 = phaseHG_0(g_1, _S1034);
    *pdf_5 = _S1037;
    float3  _S1038 = tangentToWorld(make_float3 (_S1035 * (F32_cos((_S1036))), _S1034, _S1035 * (F32_sin((_S1036)))), dir_11);
    float3  _S1039 = ((((_S1038)) * make_float3(rnorm3df(((_S1038)).x, ((_S1038)).y, ((_S1038)).z))));
    return _S1039;
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_1, float3  emissive_1, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2, float velvet_0, float3  toon_2)
{
    BSDFMaterial _S1040;
    (&_S1040)->albedo = albedo_1;
    (&_S1040)->emissive = emissive_1;
    (&_S1040)->roughness = roughness_0;
    (&_S1040)->metallic = metallic_0;
    (&_S1040)->transmission = transmission_0;
    (&_S1040)->ior = ior_0;
    (&_S1040)->absorption = absorption_0;
    (&_S1040)->specular_tint = specular_tint_0;
    (&_S1040)->specular_level = specular_level_0;
    (&_S1040)->translucent = translucent_0;
    (&_S1040)->sheen = sheen_2;
    (&_S1040)->sheen_roughness = sheen_roughness_0;
    (&_S1040)->anisotropy = anisotropy_0;
    (&_S1040)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1040)->tangent = tangent_2;
    (&_S1040)->velvet = velvet_0;
    (&_S1040)->toon = toon_2;
    return _S1040;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1041;
    (&_S1041)->scatter = scatter_1;
    (&_S1041)->extinction = extinction_1;
    (&_S1041)->g = g_2;
    return _S1041;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_11, bool skip_0, uint random_state_11, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1042;
    (&_S1042)->smooth_n = smooth_n_4;
    (&_S1042)->geometry_n = geometry_n_2;
    (&_S1042)->geometry_offset = geometry_offset_2;
    (&_S1042)->material = *material_11;
    (&_S1042)->skip = skip_0;
    (&_S1042)->random_state = random_state_11;
    (&_S1042)->coverage = coverage_0;
    (&_S1042)->encloses = encloses_0;
    (&_S1042)->volume = *volume_0;
    (&_S1042)->fills = fills_0;
    (&_S1042)->hair = hair_0;
    return _S1042;
}

static __device__ FKSurface emitting_0(FKSurface * surface_6, bool top_0)
{
    FKSurface lower_0 = *surface_6;
    float3  _S1043 = (&surface_6->material)->emissive;
    float3  _S1044 = make_float3 (0.0f);
    bool _S1045 = !top_0;
    float3  _S1046 = _slang_select(_S1045, _S1044,_S1043);
    (&(&lower_0)->material)->emissive = _S1046;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_7, float u_1)
{
    float _S1047 = surface_7->coverage;
    bool _S1048 = u_1 < _S1047;
    if(_S1048)
    {
        return *surface_7;
    }
    float3  _S1049 = make_float3 (0.0f);
    float3  _S1050 = make_float3 (1.0f);
    BSDFMaterial _S1051 = Material_x24init_0(_S1049, _S1049, 0.0f, 0.0f, 0.0f, 0.0f, _S1049, _S1050, 1.0f, _S1049, _S1049, 0.5f, 0.0f, 0.0f, _S1049, 0.0f, _S1049);
    BSDFMaterial material_12 = _S1051;
    (&material_12)->albedo = _S1050;
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
    bool _S1052 = transmission_1 > 0.0f;
    bool _S1053;
    if(_S1052)
    {
        _S1053 = true;
    }
    else
    {
        _S1053 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1054 = _slang_select(_S1053, 1.0f,-1.0f);
    return _S1054;
}

static __device__ bool arrivesBehind_0(float3  dir_12, float3  n_10)
{
    return (dot_0(dir_12, n_10)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_8, float3  dir_13)
{
    float3  _S1055 = surface_8->geometry_n;
    float _S1056 = facingSign((&surface_8->material)->transmission, surface_8->geometry_n, dir_13);
    FKSurface faced_0 = *surface_8;
    float3  _S1057 = surface_8->smooth_n * make_float3 (_S1056);
    (&faced_0)->smooth_n = _S1057;
    float3  _S1058 = _S1055 * make_float3 (_S1056);
    (&faced_0)->geometry_n = _S1058;
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
    float3  _S1059 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1059));
}

__device__ float2  vertexEta(BSDFMaterial material_13, float n_dot_v_0)
{
    bool _S1060 = n_dot_v_0 < 0.0f;
    float _S1061 = _slang_select(_S1060, material_13.ior,1.0f);
    float _S1062 = _slang_select(_S1060, 1.0f,material_13.ior);
    return make_float2 (_S1061, _S1062);
}

__device__ bool neeDecision(BSDFMaterial material_14, float n_dot_v_1, float eta_i_9, float eta_o_9)
{
    float _S1063 = fresnel((F32_abs((n_dot_v_1))), eta_i_9, eta_o_9);
    float3  _S1064 = mix_0(make_float3 (_S1063), material_14.albedo, material_14.metallic);
    float _S1065 = rgb_to_greyscale(_S1064);
    float _S1066 = (F32_max(((1.0f - _S1065) * (1.0f - material_14.metallic) * (1.0f - material_14.transmission)), (0.0f)));
    bool _S1067 = _S1066 > 0.03999999910593033f;
    bool _S1068;
    if(_S1067)
    {
        _S1068 = true;
    }
    else
    {
        _S1068 = (material_14.roughness) > 0.20000000298023224f;
    }
    return _S1068;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_15)
{
    float _S1069 = rgb_to_greyscale(material_15->translucent);
    return _S1069 > 0.0f;
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
    MediumSides _S1070;
    (&_S1070)->behind = *behind_0;
    (&_S1070)->front = *front_0;
    (&_S1070)->fillings = fillings_1;
    (&_S1070)->face = face_1;
    return _S1070;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_9, FKMedium * medium_0, uint filling_0, float3  dir_14, FKMedium * outside_0)
{
    float3  _S1071 = surface_9->geometry_n;
    MediumSides _S1072 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_9->geometry_n);
    MediumSides sides_0 = _S1072;
    bool _S1073 = surface_9->encloses;
    if(_S1073)
    {
        (&sides_0)->behind = surface_9->volume;
        *&((&(&sides_0)->fillings)->x) = surface_9->fills;
        bool _S1074 = (dot_0(dir_14, _S1071)) > 0.0f;
        if(_S1074)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_10, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_15, uint depth_2, uint lobe_3, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1075 = surface_10->geometry_n;
    ShadowContext _S1076 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_10->geometry_n, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
    bool _S1077 = surface_10->encloses;
    ShadowContext context_4;
    if(_S1077)
    {
        FKSurface faced_1 = *surface_10;
        float3  _S1078 = - _S1075;
        float3  _S1079 = _slang_select(turned_0, _S1078,_S1075);
        (&faced_1)->geometry_n = _S1079;
        FKMedium _S1080 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1081 = faced_1;
        FKMedium _S1082 = _S1080;
        MediumSides _S1083 = mediumSides_0(&_S1081, &_S1082, filling_1, dir_15, outside_1);
        ShadowContext _S1084 = ShadowContext_x24init_0(_S1083.behind.extinction, _S1083.front.extinction, _S1083.fillings, _S1075, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
        if(turned_0)
        {
            uint2  _S1085 = _S1083.fillings;
            ShadowContext _S1086 = ShadowContext_x24init_0(_S1083.front.extinction, _S1083.behind.extinction, uint2 {_S1085.y, _S1085.x}, _S1075, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
            context_4 = _S1086;
        }
        else
        {
            context_4 = _S1084;
        }
    }
    else
    {
        context_4 = _S1076;
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
    float3  _S1087 = light_2->dir;
    bool _S1088 = (dot_0(geometry_n_3, - in_dir_8) * dot_0(geometry_n_3, light_2->dir)) <= 0.0f;
    FixedArray<float3 , 5>  throughputs_1;
    FixedArray<float, 5>  pdfs_3;
    float3  _S1089 = BSDF(in_dir_8, _S1087, smooth_n_5, *material_16, eta_i_10, eta_o_10, _S1088, random_state_12, &throughputs_1, &pdfs_3);
    bool _S1090 = !competing_1;
    bool _S1091;
    if(_S1090)
    {
        _S1091 = true;
    }
    else
    {
        _S1091 = (light_2->density) == 0.0f;
    }
    if(_S1091)
    {
        return _S1089 * light_2->radiance;
    }
    float3  _S1092 = make_float3 (0.0f);
    uint i_23 = 0U;
    float3  weighted_0 = _S1092;
    for(;;)
    {
        if(i_23 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S1093 = (pdfs_3[i_23]) > 0.0f;
        if(_S1093)
        {
            float _S1094 = light_2->density;
            float _S1095 = pdfs_3[i_23] / light_2->density;
            float3  weighted_1 = weighted_0 + throughputs_1[i_23] * make_float3 (pdfs_3[i_23]) / make_float3 (_S1094 * (1.0f + _S1095 * _S1095));
            weighted_0 = weighted_1;
        }
        uint i_24 = i_23 + 1U;
        i_23 = i_24;
    }
    return weighted_0 * light_2->radiance * make_float3 (light_2->density);
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_1, uint random_state_13, bool refracted_3, uint lobe_4, float pdf_6)
{
    SampleBSDF _S1096;
    (&_S1096)->unit_direction = unit_direction_1;
    (&_S1096)->throughput = throughput_1;
    (&_S1096)->random_state = random_state_13;
    (&_S1096)->refracted = refracted_3;
    (&_S1096)->lobe = lobe_4;
    (&_S1096)->pdf = pdf_6;
    return _S1096;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  n_i_9, float n_i_dot_v_6, float alpha_15, BSDFMaterial material_17, BSDFLobes lobes_11, float eta_i_11, float eta_o_11, uint random_state_14)
{
    float3  _S1097 = make_float3 (1.0f);
    SampleBSDF _S1098 = SampleBSDF_x24init_0(_S1097, _S1097, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S1098;
    Random _S1099 = pcg(random_state_14);
    Random _S1100 = pcg(_S1099.state);
    (&sample_1)->random_state = _S1100.state;
    float _S1101 = _S1099.value;
    float _S1102 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1101 * _S1101))))));
    float _S1103 = 6.28318548202514648f * _S1100.value;
    float3  _S1104 = tangentToWorld(make_float3 (_S1102 * (F32_cos((_S1103))), _S1099.value, _S1102 * (F32_sin((_S1103)))), n_i_9);
    (&sample_1)->unit_direction = _S1104;
    (&sample_1)->lobe = 4U;
    float3  _S1105 = sheenVelvetBSDF((&sample_1)->unit_direction, n_i_9, alpha_15, material_17, lobes_11);
    (&sample_1)->throughput = _S1105;
    float _S1106 = sheenVelvetPDF(_S1099.value, 0.0f, n_i_dot_v_6, alpha_15, lobes_11, eta_i_11, eta_o_11);
    (&sample_1)->pdf = _S1106;
    return sample_1;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1107 = (F32_sqrt((random_1_0)));
    float _S1108 = 6.28318548202514648f * random_2_0;
    float _S1109 = _S1107 * (F32_cos((_S1108)));
    float _S1110 = _S1107 * (F32_sin((_S1108)));
    float _S1111 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1109 * _S1109 - _S1110 * _S1110))))));
    return make_float3 (_S1109, _S1111, _S1110);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_2, float3  n_i_10, float n_i_dot_v_7, float alpha_16, BSDFMaterial material_18, BSDFLobes lobes_12, float eta_i_12, float eta_o_12, uint random_state_15)
{
    float3  _S1112 = make_float3 (1.0f);
    SampleBSDF _S1113 = SampleBSDF_x24init_0(_S1112, _S1112, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S1113;
    Random _S1114 = pcg(random_state_15);
    Random _S1115 = pcg(_S1114.state);
    (&sample_2)->random_state = _S1115.state;
    float3  _S1116 = sampleCosWeightedHemisphere(_S1114.value, _S1115.value);
    bool _S1117 = u_2 < (lobes_12.p_diffuse * lobes_12.translucent_share);
    float _S1118 = _S1116.y;
    float _S1119 = - _S1118;
    float _S1120 = _slang_select(_S1117, _S1119,_S1118);
    float3  _S1121 = tangentToWorld(make_float3 (_S1116.x, _S1120, _S1116.z), n_i_10);
    (&sample_2)->unit_direction = _S1121;
    (&sample_2)->refracted = _S1117;
    (&sample_2)->lobe = 0U;
    float3  _S1122 = diffuseBSDF((&sample_2)->unit_direction, n_i_10, alpha_16, material_18, lobes_12);
    (&sample_2)->throughput = _S1122;
    float _S1123 = diffusePDF(_S1120, 0.0f, n_i_dot_v_7, alpha_16, lobes_12, eta_i_12, eta_o_12);
    (&sample_2)->pdf = _S1123;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF toonSample(float3  n_i_11, float n_i_dot_v_8, float alpha_17, BSDFMaterial material_19, BSDFLobes lobes_13, float eta_i_13, float eta_o_13, uint random_state_16)
{
    float3  _S1124 = make_float3 (1.0f);
    SampleBSDF _S1125 = SampleBSDF_x24init_0(_S1124, _S1124, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S1125;
    Random _S1126 = pcg(random_state_16);
    Random _S1127 = pcg(_S1126.state);
    (&sample_3)->random_state = _S1127.state;
    float _S1128 = _S1126.value * lobes_13.toon_norm / 6.28318548202514648f;
    float t_20;
    if(lobes_13.toon_glossy)
    {
        t_20 = (F32_acos((clamp_1(1.0f - _S1128, -1.0f, 1.0f))));
    }
    else
    {
        t_20 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1128)))), (1.0f))))));
    }
    if(t_20 < (lobes_13.toon_a))
    {
    }
    else
    {
        t_20 = (lobes_13.toon_a + lobes_13.toon_b) / 2.0f;
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
        float _S1129;
        if(t_20 < (lobes_13.toon_a))
        {
            _S1129 = 1.0f;
        }
        else
        {
            _S1129 = (F32_max((1.0f - (t_20 - lobes_13.toon_a) / (F32_max((lobes_13.toon_s), (0.0000152587890625f)))), (0.0f)));
        }
        float integral_1;
        if(lobes_13.toon_glossy)
        {
            integral_1 = 1.0f - (F32_cos(((F32_min((t_20), (lobes_13.toon_a))))));
        }
        else
        {
            float _S1130 = (F32_sin(((F32_min((t_20), (lobes_13.toon_a))))));
            integral_1 = _S1130 * _S1130 / 2.0f;
        }
        bool _S1131 = t_20 > (lobes_13.toon_a);
        bool _S1132;
        if(_S1131)
        {
            _S1132 = (lobes_13.toon_s) > 0.0f;
        }
        else
        {
            _S1132 = false;
        }
        float integral_2;
        if(_S1132)
        {
            if(lobes_13.toon_glossy)
            {
                float _S1133 = (F32_cos((lobes_13.toon_a)));
                float _S1134 = (F32_cos((t_20)));
                integral_2 = (1.0f + lobes_13.toon_a / lobes_13.toon_s) * (_S1133 - _S1134) - ((F32_sin((t_20))) - t_20 * _S1134 - ((F32_sin((lobes_13.toon_a))) - lobes_13.toon_a * _S1133)) / lobes_13.toon_s;
            }
            else
            {
                float _S1135 = 2.0f * lobes_13.toon_a;
                float _S1136 = (F32_cos((_S1135)));
                float _S1137 = 2.0f * t_20;
                float _S1138 = (F32_cos((_S1137)));
                integral_2 = (1.0f + lobes_13.toon_a / lobes_13.toon_s) * (_S1136 - _S1138) / 4.0f - ((F32_sin((_S1137))) / 8.0f - t_20 * _S1138 / 4.0f - ((F32_sin((_S1135))) / 8.0f - lobes_13.toon_a * _S1136 / 4.0f)) / lobes_13.toon_s;
            }
            float integral_3 = integral_1 + integral_2;
            integral_2 = integral_3;
        }
        else
        {
            integral_2 = integral_1;
        }
        float _S1139 = _S1129 * (F32_sin((t_20)));
        float _S1140;
        if(lobes_13.toon_glossy)
        {
            _S1140 = 1.0f;
        }
        else
        {
            _S1140 = (F32_cos((t_20)));
        }
        float _S1141 = _S1139 * _S1140;
        float _S1142 = (integral_2 - _S1128) / _S1141;
        bool _S1143 = _S1141 > 0.0f;
        float _S1144 = _slang_select(_S1143, _S1142,0.0f);
        float _S1145 = clamp_1(t_20 - _S1144, 0.0f, lobes_13.toon_b);
        int k_1 = k_0 + int(1);
        t_20 = _S1145;
        k_0 = k_1;
    }
    float _S1146 = 6.28318548202514648f * _S1127.value;
    float _S1147 = (F32_sin((t_20)));
    float3  _S1148 = tangentToWorld(make_float3 (_S1147 * (F32_cos((_S1146))), (F32_cos((t_20))), _S1147 * (F32_sin((_S1146)))), lobes_13.toon_axis);
    (&sample_3)->unit_direction = _S1148;
    bool _S1149 = (dot_0(n_i_11, (&sample_3)->unit_direction)) < 0.0f;
    (&sample_3)->refracted = _S1149;
    (&sample_3)->lobe = 6U;
    float3  _S1150 = toonBSDF((&sample_3)->unit_direction, n_i_11, alpha_17, material_19, lobes_13);
    (&sample_3)->throughput = _S1150;
    float _S1151 = toonPDF(dot_0(n_i_11, (&sample_3)->unit_direction), dot_0((&sample_3)->unit_direction, lobes_13.toon_axis), n_i_dot_v_8, alpha_17, lobes_13, eta_i_13, eta_o_13);
    (&sample_3)->pdf = _S1151;
    return sample_3;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_12, float n_i_dot_v_9, float alpha_18, BSDFMaterial material_20, BSDFLobes lobes_14, float eta_i_14, float eta_o_14, uint random_state_17)
{
    float3  _S1152 = make_float3 (1.0f);
    SampleBSDF _S1153 = SampleBSDF_x24init_0(_S1152, _S1152, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S1153;
    (&sample_4)->unit_direction = lobes_14.refracted;
    (&sample_4)->random_state = random_state_17;
    (&sample_4)->refracted = true;
    (&sample_4)->lobe = 1U;
    float3  _S1154 = refractBSDF((&sample_4)->unit_direction, n_i_12, alpha_18, material_20, lobes_14);
    (&sample_4)->throughput = _S1154;
    float _S1155 = refractPDF(0.0f, dot_0((&sample_4)->unit_direction, ggx_n_3), n_i_dot_v_9, alpha_18, lobes_14, eta_i_14, eta_o_14);
    (&sample_4)->pdf = _S1155;
    return sample_4;
}

static __device__ float3  reflect_0(float3  i_25, float3  n_11)
{
    return i_25 - make_float3 (2.0f * dot_0(n_11, i_25)) * n_11;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_9, float3  ggx_n_4, float3  n_i_13, float n_i_dot_v_10, float alpha_19, BSDFMaterial material_21, BSDFLobes lobes_15, float eta_i_15, float eta_o_15, uint random_state_18)
{
    float3  _S1156 = make_float3 (1.0f);
    SampleBSDF _S1157 = SampleBSDF_x24init_0(_S1156, _S1156, 0U, false, 0U, 0.0f);
    SampleBSDF sample_5 = _S1157;
    float3  _S1158 = reflect_0(in_dir_9, ggx_n_4);
    float3  _S1159 = ((((_S1158)) * make_float3(rnorm3df(((_S1158)).x, ((_S1158)).y, ((_S1158)).z))));
    (&sample_5)->unit_direction = _S1159;
    (&sample_5)->random_state = random_state_18;
    (&sample_5)->lobe = 2U;
    float3  _S1160 = reflectBSDF((&sample_5)->unit_direction, n_i_13, alpha_19, material_21, lobes_15);
    (&sample_5)->throughput = _S1160;
    float _S1161 = reflectPDF(0.0f, 0.0f, n_i_dot_v_10, alpha_19, lobes_15, eta_i_15, eta_o_15);
    (&sample_5)->pdf = _S1161;
    return sample_5;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_10, float3  n_12, BSDFMaterial material_22, float eta_i_16, float eta_o_16, uint random_init_0, float2  screen_space_0)
{
    uint random_state_19 = random_init_0;
    float3  _S1162 = negate_0(in_dir_10);
    float _S1163 = dot_0(n_12, _S1162);
    float _S1164 = sign_0(_S1163);
    float3  n_i_14 = n_12 * make_float3 (_S1164);
    float _S1165 = (F32_abs((_S1163)));
    float _S1166 = material_22.roughness;
    float _S1167 = _S1166 * _S1166;
    AnisotropicFrame _S1168 = anisotropicFrame(material_22, n_i_14);
    SheenProfile _S1169 = sheenProfile(_S1162, n_i_14, material_22);
    float3  _S1170 = sampleHalfVector(_S1162, n_i_14, _S1167, _S1168, &random_state_19);
    BSDFLobes _S1171 = bsdfLobes(in_dir_10, _S1162, n_i_14, _S1170, material_22, eta_i_16, eta_o_16, _S1168, _S1169);
    BSDFLobes lobes_16 = _S1171;
    float _S1172 = translucentShare(material_22);
    (&lobes_16)->translucent_share = _S1172;
    Random _S1173 = pcg(random_state_19);
    random_state_19 = _S1173.state;
    bool _S1174 = (_S1173.value) < ((&lobes_16)->p_sheen_velvet);
    if(_S1174)
    {
        SampleBSDF _S1175 = sheenVelvetSample(n_i_14, _S1165, _S1167, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1175;
    }
    float _S1176 = _S1173.value - (&lobes_16)->p_sheen_velvet;
    bool _S1177 = _S1176 < ((&lobes_16)->p_diffuse);
    if(_S1177)
    {
        SampleBSDF _S1178 = diffuseSample(_S1176, n_i_14, _S1165, _S1167, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1178;
    }
    bool _S1179 = _S1176 < ((&lobes_16)->p_diffuse + (&lobes_16)->p_toon);
    if(_S1179)
    {
        SampleBSDF _S1180 = toonSample(n_i_14, _S1165, _S1167, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1180;
    }
    float _S1181 = (&lobes_16)->p_toon;
    bool _S1182 = (_S1176 - _S1181) < ((&lobes_16)->p_diffuse + (&lobes_16)->p_refract);
    if(_S1182)
    {
        SampleBSDF _S1183 = refractSample(_S1170, n_i_14, _S1165, _S1167, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1183;
    }
    SampleBSDF _S1184 = reflectSample(in_dir_10, _S1170, n_i_14, _S1165, _S1167, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
    return _S1184;
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
    bool _S1185;
    bool _S1186;
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
    int _S1187;
    Shift ended_0;
    float density_3;
    float spread_2;
    float width_4;
    float sky_pdf_1;
    float spread_3;
    float width_5;
    uint b_6;
    float3  _S1188 = make_float3 (0.0f);
    Shift _S1189 = Shift_x24init_0(_S1188, 0.0f);
    uint _S1190 = r_8->path;
    uint _S1191 = extractBits_0(r_8->path, 0U, 5U);
    uint _S1192 = extractBits_0(_S1190, 5U, 5U);
    uint _S1193 = extractBits_0(_S1190, 10U, 2U);
    uint _S1194 = extractBits_0(_S1190, 12U, 3U);
    bool passes_0;
    if(replay_1)
    {
        bool _S1195 = _S1194 >= 3U;
        uint _S1196 = _slang_select(_S1195, 1U,0U);
        uint _S1197 = _S1191 + _S1196;
        uint _S1198 = (fcptMaxBounces());
        passes_0 = _S1197 > _S1198;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1189;
    }
    uint _S1199 = _S1192 - 1U;
    bool _S1200 = _S1194 == 3U;
    uint _S1201 = _slang_select(_S1200, 1U,0U);
    uint _S1202 = _S1191 + _S1201;
    bool _S1203 = _S1193 == 0U;
    uint _S1204 = _slang_select(_S1203, _S1202,_S1199);
    FKHit _S1205 = (fcptReservoirHit((*r_8)));
    float3  _S1206 = dom_7->x0;
    float3  _S1207 = dom_7->x1 - dom_7->x0;
    float3  _S1208 = ((((_S1207)) * make_float3(rnorm3df(((_S1207)).x, ((_S1207)).y, ((_S1207)).z))));
    FKRay _S1209 = Ray_x24init_0(dom_7->x1, _S1208);
    FKRay ray_2 = _S1209;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1188;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_1 = throughput_3;
    float3  glowed_0 = _S1188;
    float3  extinction_in_0 = _S1188;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1210 = dom_7->spread;
    float _S1211 = dom_7->width;
    float _S1212 = length_0(_S1207);
    NEEVertex _S1213 = NEEVertex_x24init_0(true, 0.0f, _S1188, _S1188, _S1188);
    NEEVertex nee_vertex_0 = _S1213;
    Vertex _S1214 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S1214;
    Reservoir _S1215 = (Reservoir{});
    Reservoir chain_0 = _S1215;
    uint _S1216 = r_8->seed;
    (&chain_0)->seed = r_8->seed;
    (&ray_2)->origin = _S1206;
    (&hit_4)->distance = _S1212;
    FKMedium _S1217 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1218 = filling_2;
    bool _S1219 = (fcptVaryingUsed());
    uint _S1220 = _slang_select(_S1219, _S1218,4294967295U);
    filling_2 = _S1220;
    scatter_in_0 = _S1217.scatter;
    extinction_in_0 = _S1217.extinction;
    g_in_0 = _S1217.g;
    Reservoir _S1221 = chain_0;
    uint _S1222 = filling_2;
    for(;;)
    {
        bool _S1223 = (fcptVaryingUsed());
        if(_S1223)
        {
            passes_0 = _S1222 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1224 = (fcptMajorant((_S1222)));
            spread_1 = _S1224;
        }
        else
        {
            spread_1 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_1)
        {
            turned_1 = 4294967295U == _S1204;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1193 == 1U;
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
            ended_0 = _S1189;
            sky_pdf_0 = 0.0f;
            spread_1 = _S1210;
            width_3 = _S1211;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_5 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1225 = (&prev_0)->rough;
        if(_S1225)
        {
            turned_1 = !(spread_1 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S1226 = stream(_S1216, 384U);
        uint tracking_0 = _S1226;
        weight_1 = throughput_3;
        glowed_0 = _S1188;
        b_5 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        threshold_0 = _S1210;
        width_3 = _S1211;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1187 = int(1);
                break;
            }
            uint _S1227 = b_5 + 320U;
            bool _S1228 = b_5 == 4294967295U;
            uint _S1229 = _slang_select(_S1228, 384U,_S1227);
            uint _S1230 = stream(_S1216, _S1229);
            Random _S1231 = pcg(_S1230);
            float _S1232 = - (F32_log((1.0f - _S1231.value))) / spread_1;
            if(passes_0)
            {
                float3  _S1233 = (&ray_2)->origin;
                float3  _S1234 = (&ray_2)->unit_direction;
                float _S1235 = (&hit_4)->distance;
                uint _S1236 = _slang_select(_S1228, 0U,b_5);
                uint _S1237 = (&prev_0)->lobe;
                uint _S1238 = _slang_select(_S1228, 3U,_S1237);
                float _S1239 = (fcptTrackMedium((_S1222), (_S1233), (_S1234), (_S1235), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1236), (_S1238), (_S1228)));
                geometry_density_0 = _S1239;
            }
            else
            {
                geometry_density_0 = _S1232;
            }
            bool _S1240 = !(geometry_density_0 < ((&hit_4)->distance));
            if(_S1240)
            {
                _S1187 = int(1);
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
                float3  _S1241 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S1242 = sel_7->glow + _S1241;
                sel_7->glow = _S1242;
            }
            else
            {
            }
            glowed_0 = _S1188;
            uint b_7 = b_5 + 1U;
            float3  _S1243 = (&ray_2)->origin + make_float3 (geometry_density_0) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1243;
            float3  _S1244 = flightWeight_0(scatter_in_0, extinction_in_0, spread_1, geometry_density_0, true);
            float3  _S1245 = weight_1;
            float3  _S1246 = _slang_select(passes_0, _S1245,_S1244);
            float3  throughput_4 = throughput_2 * _S1246;
            uint _S1247 = stream(_S1216, b_7 + 320U);
            tracking_0 = _S1247;
            weight_1 = throughput_3;
            float width_6 = width_3 + threshold_0 * geometry_density_0;
            float _S1248 = threshold_0 + 3.14159274101257324f;
            bool _S1249 = !replay_1;
            if(_S1249)
            {
                is_inside_5 = true;
            }
            else
            {
                bool _S1250 = b_7 == _S1204;
                if(_S1250)
                {
                    is_inside_5 = !passes_0;
                }
                else
                {
                    is_inside_5 = false;
                }
            }
            TreeSample _S1251 = TreeSample_x24init_0(_S1188, _S1188, 0.0f, 0U);
            if(is_inside_5)
            {
                float3  _S1252 = (&ray_2)->origin;
                float3  _S1253 = (&ray_2)->unit_direction;
                float3  _S1254 = (&ray_2)->unit_direction;
                uint _S1255 = stream(_S1216, b_7 + 64U);
                float3  _S1256 = extinction_in_0;
                float3  _S1257 = extinction_in_0;
                uint2  _S1258 = make_uint2 (_S1222);
                float3  _S1259 = (&ray_2)->unit_direction;
                uint _S1260 = arrivalLobe_0(b_7, (&prev_0)->lobe);
                FKHit _S1261 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1262 = _S1261;
                ShadowContext _S1263 = ShadowContext_x24init_0(_S1256, _S1257, _S1258, _S1259, b_7, _S1260, false, geometry_density_0, width_6, &_S1262, false);
                ShadowContext _S1264 = _S1263;
                TreeSample _S1265 = sampleLightTree_0(_S1252, _S1253, _S1254, 0.0f, true, _S1255, &_S1264);
                light_3 = _S1265;
            }
            else
            {
                light_3 = _S1251;
            }
            float _S1266 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S1267 = (fcptMaxBounces());
            bool _S1268 = b_7 < _S1267;
            if(_S1268)
            {
                viewed_0 = (light_3.density) > 0.0f;
            }
            else
            {
                viewed_0 = false;
            }
            float _S1269 = _slang_select(viewed_0, _S1266,0.0f);
            float3  _S1270 = throughput_4 * light_3.radiance;
            float _S1271 = powerHeuristic(light_3.density, _S1269);
            float3  _S1272 = _S1270 * make_float3 (_S1266 * _S1271);
            float3  _S1273 = _slang_select(is_inside_5, _S1272,_S1188);
            if(replay_1)
            {
                _S1185 = b_7 == _S1204;
            }
            else
            {
                _S1185 = false;
            }
            if(_S1185)
            {
                bool _S1274 = _S1193 == 2U;
                if(_S1274)
                {
                    float _S1275 = rgb_to_greyscale(_S1273);
                    passes_0 = _S1275 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1276 = Shift_x24init_0(_S1273, 1.0f);
                    _S1187 = int(0);
                    ended_0 = _S1276;
                    spread_1 = _S1248;
                    geometry_density_0 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_7;
                    break;
                }
                _S1187 = int(0);
                ended_0 = _S1189;
                spread_1 = _S1248;
                geometry_density_0 = width_6;
                chain_throughput_0 = throughput_4;
                layer_0 = b_7;
                break;
            }
            if(_S1249)
            {
                Reservoir candidate_3 = _S1221;
                uint _S1277 = extractBits_0(_S1221.path, 10U, 2U);
                bool _S1278 = _S1277 == 1U;
                if(_S1278)
                {
                    float3  _S1279 = safeDivide(_S1273, _S1188);
                    (&candidate_3)->radiance = _S1279;
                }
                else
                {
                    uint _S1280 = insertBits_0(0U, b_7 + 1U, 5U, 5U);
                    uint _S1281 = insertBits_0(_S1280, 2U, 10U, 2U);
                    (&candidate_3)->path = _S1281;
                }
                Reservoir _S1282 = withEnd(candidate_3, 0U, b_7, _S1273);
                offer(sel_7, _S1282, _S1273 * make_float3 (scale_3) / make_float3 (density_2));
                float _S1283 = survivalProbability(throughput_4, density_2);
                uint _S1284 = stream(_S1216, b_7 + 128U);
                Random _S1285 = pcg(_S1284);
                bool _S1286 = _S1283 < (_S1285.value);
                if(_S1286)
                {
                    _S1186 = true;
                }
                else
                {
                    uint _S1287 = (fcptMaxBounces());
                    _S1186 = b_7 >= _S1287;
                }
                if(_S1186)
                {
                    _S1187 = int(0);
                    ended_0 = _S1189;
                    spread_1 = _S1248;
                    geometry_density_0 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_7;
                    break;
                }
                float _S1288 = density_2 * _S1283;
                density_2 = _S1288;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1289 = stream(_S1216, b_7);
            float3  _S1290 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1289, &phase_pdf_0);
            (&ray_2)->unit_direction = _S1290;
            NEEVertex _S1291 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S1188, (&ray_2)->origin);
            nee_vertex_0 = _S1291;
            Vertex _S1292 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, false);
            prev_0 = _S1292;
            float _S1293 = (&prev_0)->pdf;
            FKRay _S1294 = ray_2;
            FKHit _S1295 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1296 = (fcptTraverseInstanceBVH((_S1294), (true), (4.294967296e+09f), (false), (_S1295), (false)));
            hit_4 = _S1296;
            b_5 = b_7;
            throughput_2 = throughput_4;
            threshold_0 = _S1248;
            width_3 = width_6;
            sky_pdf_0 = _S1293;
        }
        if(_S1187 != int(1))
        {
            width_3 = geometry_density_0;
            throughput_2 = chain_throughput_0;
            b_5 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1189;
        spread_1 = threshold_0;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1297 = b_5 == 4294967295U;
    bool _S1298 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1298)
    {
        bool _S1299 = !(&nee_vertex_0)->none;
        float _S1300 = _slang_select(_S1299, sky_pdf_0,0.0f);
        float _S1301 = escapeWeight_0(_S1300, (&ray_2)->unit_direction);
        float3  _S1302 = environment_0((&ray_2)->unit_direction, b_5, (&prev_0)->lobe);
        float3  _S1303 = throughput_2 * _S1302;
        if(replay_1)
        {
            bool _S1304 = b_5 == _S1204;
            if(_S1304)
            {
                passes_0 = _S1193 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S1303 * make_float3 (_S1301) / make_float3 (r_8->jac), density_2 / r_8->jac);
            }
            if(_S1203)
            {
                passes_0 = _S1200;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_5 == _S1191;
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
                return Shift_x24init_0(_S1303 * make_float3 (_S1301), 1.0f);
            }
            return _S1189;
        }
        Reservoir candidate_4 = chain_0;
        uint _S1305 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1306 = _S1305 == 1U;
        if(_S1306)
        {
            uint _S1307 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S1308 = _S1307 == b_5;
            float _S1309 = _slang_select(_S1308, 1.0f,_S1301);
            float3  _S1310 = safeDivide(_S1303 * make_float3 (_S1309), _S1188);
            (&candidate_4)->radiance = _S1310;
        }
        else
        {
            bool _S1311 = (&prev_0)->rough;
            if(_S1311)
            {
                uint _S1312 = insertBits_0(0U, b_5 + 1U, 5U, 5U);
                uint _S1313 = insertBits_0(_S1312, 3U, 10U, 2U);
                uint _S1314 = insertBits_0(_S1313, (&prev_0)->lobe, 15U, 3U);
                bool _S1315 = (&prev_0)->inside;
                uint _S1316 = _slang_select(_S1315, 1U,0U);
                uint _S1317 = insertBits_0(_S1314, _S1316, 22U, 1U);
                (&candidate_4)->path = _S1317;
                (&candidate_4)->jac = (&prev_0)->pdf;
                (&candidate_4)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S1318 = _S1303 * make_float3 (_S1301);
        Reservoir _S1319 = withEnd(candidate_4, 3U, b_5, _S1318);
        offer(sel_7, _S1319, _S1318 * make_float3 (scale_3) / make_float3 (density_2));
        return _S1189;
    }
    float3  _S1320 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S1320;
    bool _S1321 = (fcptVaryingUsed());
    if(_S1321)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1322 = !replay_1;
        if(_S1322)
        {
            float3  _S1323 = throughput_2 * glowed_0 / make_float3 (density_2);
            float3  _S1324 = sel_7->glow + _S1323;
            sel_7->glow = _S1324;
        }
        float3  _S1325 = throughput_2 * weight_1;
        throughput_2 = _S1325;
    }
    else
    {
        float3  _S1326 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
        float3  _S1327 = throughput_2 * _S1326;
        throughput_2 = _S1327;
    }
    float _S1328 = width_3 + spread_1 * (&hit_4)->distance;
    uint _S1329 = b_5 + 1U;
    b_5 = _S1329;
    layer_0 = 0U;
    width_3 = _S1328;
    passes_0 = false;
    threshold_0 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    chain_throughput_0 = _S1188;
    float3  reconnection_0 = _S1188;
    viewed_0 = _S1297;
    for(;;)
    {
        bool _S1330 = ((&hit_4)->is_point_light) == 1U;
        if(replay_1)
        {
            _S1185 = _S1193 == 1U;
        }
        else
        {
            _S1185 = false;
        }
        if(_S1185)
        {
            _S1186 = b_5 == _S1192;
        }
        else
        {
            _S1186 = false;
        }
        bool _S1331;
        if(_S1186)
        {
            bool _S1332 = ((&hit_4)->instance_index) != (_S1205.instance_index);
            if(_S1332)
            {
                _S1331 = true;
            }
            else
            {
                _S1331 = ((&hit_4)->triangle_index) != (_S1205.triangle_index);
            }
        }
        else
        {
            _S1331 = false;
        }
        if(_S1331)
        {
            return _S1189;
        }
        FKMedium _S1333 = Medium_x24init_0(_S1188, _S1188, 0.0f);
        BSDFMaterial _S1334 = Material_x24init_0(_S1188, _S1188, 0.0f, 0.0f, 0.0f, 0.0f, _S1188, throughput_3, 1.0f, _S1188, _S1188, 0.5f, 0.0f, 0.0f, _S1188, 0.0f, _S1188);
        FKMedium _S1335 = _S1333;
        FKSurface _S1336 = Surface_x24init_0(_S1188, _S1188, 0.0f, &_S1334, false, 0U, 1.0f, false, &_S1335, 4294967295U, _S1188);
        bool _S1337 = !_S1330;
        bool scatter_2;
        bool is_inside_6;
        float3  front_n_0;
        float3  throughput_5;
        FKSurface surface_12;
        if(_S1337)
        {
            uint _S1338 = stream(_S1216, b_5);
            uint _S1339 = arrivalLobe_0(b_5, (&prev_0)->lobe);
            FKSurface _S1340 = (fcptSurfaceAtPath((hit_4), ((&ray_2)->origin), (_S1338), (width_3), (layer_0), (b_5), (_S1339), ((&ray_2)->unit_direction)));
            bool _S1341 = !passes_0;
            FKSurface _S1342 = _S1340;
            FKSurface _S1343 = emitting_0(&_S1342, _S1341);
            uint _S1344 = stream(_S1216, b_5 + 256U);
            Random _S1345 = pcg(_S1344);
            FKSurface _S1346 = _S1343;
            FKSurface _S1347 = uncovered_0(&_S1346, _S1345.value);
            float _S1348 = facingSign(_S1347.material.transmission, _S1347.geometry_n, (&ray_2)->unit_direction);
            bool _S1349 = _S1348 < 0.0f;
            bool _S1350 = (_S1347.material.transmission) > 0.0f;
            if(_S1350)
            {
                bool _S1351 = arrivesBehind_0((&ray_2)->unit_direction, _S1347.geometry_n);
                scatter_2 = _S1351;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1352 = _S1347;
            FKSurface _S1353 = facingRay_0(&_S1352, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S1354 = arrivesBehind_0((&ray_2)->unit_direction, _S1353.geometry_n);
                is_inside_6 = _S1354;
            }
            else
            {
                is_inside_6 = scatter_2;
            }
            if(is_inside_6)
            {
                float3  _S1355 = beerLambert((&hit_4)->distance, _S1353.material.absorption);
                float3  _S1356 = throughput_2 * _S1355;
                front_n_0 = _S1356;
            }
            else
            {
                front_n_0 = throughput_2;
            }
            bool _S1357 = !_S1353.skip;
            float geometry_density_1 = (F32_abs((dot_0(_S1353.geometry_n, (&ray_2)->unit_direction)))) / ((&hit_4)->distance * (&hit_4)->distance);
            bool _S1358 = b_5 == _S1329;
            if(_S1358)
            {
                float _S1359 = 0.00251327408477664f / geometry_density_1;
                geometry_density_0 = _S1359;
            }
            else
            {
                geometry_density_0 = threshold_0;
            }
            float3  _S1360 = front_n_0;
            float _S1361 = geometry_density_0;
            scatter_2 = _S1357;
            geometry_density_0 = geometry_density_1;
            threshold_0 = _S1361;
            surface_12 = _S1353;
            front_n_0 = _S1347.smooth_n;
            throughput_5 = _S1360;
            turned_1 = _S1349;
        }
        else
        {
            scatter_2 = false;
            geometry_density_0 = 0.0f;
            surface_12 = _S1336;
            front_n_0 = _S1188;
            throughput_5 = throughput_2;
            is_inside_6 = is_inside_5;
        }
        bool _S1362;
        if(scatter_2)
        {
            _S1362 = (&prev_0)->rough;
        }
        else
        {
            _S1362 = false;
        }
        bool _S1363;
        if(_S1362)
        {
            _S1363 = ((&prev_0)->pdf * geometry_density_0 * threshold_0) <= 1.0f;
        }
        else
        {
            _S1363 = false;
        }
        FKSurface _S1364 = surface_12;
        FKSurface _S1365 = surface_12;
        float _S1366 = dot_0(surface_12.smooth_n, - (&ray_2)->unit_direction);
        float2  _S1367 = vertexEta(_S1364.material, _S1366);
        bool _S1368;
        if(scatter_2)
        {
            uint _S1369 = (fcptMaxBounces());
            bool _S1370 = b_5 >= _S1369;
            if(_S1370)
            {
                _S1368 = true;
            }
            else
            {
                bool _S1371 = neeDecision(_S1364.material, _S1366, _S1367.x, _S1367.y);
                _S1368 = _S1371;
            }
        }
        else
        {
            _S1368 = false;
        }
        bool _S1372;
        if(passes_0)
        {
            _S1372 = true;
        }
        else
        {
            _S1372 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1372)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1368;
        }
        bool _S1373 = (fcptHairUsed());
        bool _S1374;
        if(_S1373)
        {
            float3  _S1375 = surface_12.hair;
            _S1374 = (dot_0(_S1375, _S1375)) > 0.0f;
        }
        else
        {
            _S1374 = false;
        }
        bool _S1376;
        if(_S1374)
        {
            _S1376 = true;
        }
        else
        {
            BSDFMaterial _S1377 = _S1364.material;
            bool _S1378 = isTranslucent_0(&_S1377);
            _S1376 = _S1378;
        }
        bool _S1379;
        if(_S1376)
        {
            _S1379 = true;
        }
        else
        {
            bool _S1380 = (_S1364.material.transmission) > 0.0f;
            if(_S1380)
            {
                uint _S1381 = (fcptLayers((hit_4)));
                _S1379 = _S1381 == 1U;
            }
            else
            {
                _S1379 = false;
            }
        }
        float3  _S1382 = emitted_0(_S1364.material.emissive, (&ray_2)->unit_direction, front_n_0);
        float3  emission_0;
        if(_S1330)
        {
            float3  _S1383 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1383;
        }
        else
        {
            emission_0 = _S1382;
        }
        bool _S1384 = !replay_1;
        bool _S1385;
        if(_S1384)
        {
            _S1385 = true;
        }
        else
        {
            _S1385 = b_5 >= _S1204;
        }
        bool _S1386;
        if(_S1385)
        {
            float _S1387 = rgb_to_greyscale(emission_0);
            _S1386 = _S1387 > 0.0f;
        }
        else
        {
            _S1386 = false;
        }
        float3  emission_1;
        if(_S1386)
        {
            NEEVertex _S1388 = nee_vertex_0;
            FKHit _S1389 = hit_4;
            float _S1390 = emissionWeight_0(&_S1388, &_S1389, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1390);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1391;
        if(replay_1)
        {
            _S1391 = _S1193 == 1U;
        }
        else
        {
            _S1391 = false;
        }
        bool _S1392;
        if(_S1391)
        {
            _S1392 = b_5 > _S1192;
        }
        else
        {
            _S1392 = false;
        }
        bool _S1393;
        if(_S1392)
        {
            _S1393 = b_5 == _S1191;
        }
        else
        {
            _S1393 = false;
        }
        bool _S1394;
        if(_S1393)
        {
            bool _S1395 = _S1194 == 1U;
            if(_S1395)
            {
                _S1394 = true;
            }
            else
            {
                _S1394 = _S1194 == 2U;
            }
        }
        else
        {
            _S1394 = false;
        }
        if(_S1394)
        {
            bool _S1396 = _S1330 != (_S1194 == 2U);
            if(_S1396)
            {
                return _S1189;
            }
            return Shift_x24init_0(throughput_5 * emission_1 / make_float3 (r_8->jac), density_2 / r_8->jac);
        }
        uint _S1397 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1398 = _S1397 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1399 = insertBits_0(0U, b_5, 5U, 5U);
        uint _S1400 = insertBits_0(_S1399, 1U, 10U, 2U);
        uint _S1401 = insertBits_0(_S1400, (&prev_0)->lobe, 15U, 3U);
        bool _S1402 = (&prev_0)->inside;
        uint _S1403 = _slang_select(_S1402, 1U,0U);
        uint _S1404 = insertBits_0(_S1401, _S1403, 22U, 1U);
        (&here_0)->path = _S1404;
        float _S1405 = (&prev_0)->pdf * geometry_density_0;
        (&here_0)->jac = _S1405;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1406;
        if(replay_1)
        {
            _S1406 = _S1193 == 1U;
        }
        else
        {
            _S1406 = false;
        }
        bool _S1407;
        if(_S1406)
        {
            _S1407 = b_5 == _S1192;
        }
        else
        {
            _S1407 = false;
        }
        bool _S1408 = b_5 == _S1204;
        bool _S1409;
        if(_S1408)
        {
            bool _S1410 = !scatter_2;
            if(_S1410)
            {
                _S1409 = true;
            }
            else
            {
                bool _S1411 = _S1193 != 1U;
                if(_S1411)
                {
                    _S1409 = _S1193 != 3U;
                }
                else
                {
                    _S1409 = false;
                }
            }
        }
        else
        {
            _S1409 = false;
        }
        bool _S1412;
        if(_S1409)
        {
            _S1412 = _S1193 == 2U;
        }
        else
        {
            _S1412 = false;
        }
        bool _S1413;
        if(_S1412)
        {
            _S1413 = !_S1363;
        }
        else
        {
            _S1413 = false;
        }
        bool _S1414;
        if(_S1413)
        {
            _S1414 = _S1194 != 4U;
        }
        else
        {
            _S1414 = false;
        }
        bool _S1415 = _S1192 == _S1191;
        bool _S1416;
        if(_S1415)
        {
            _S1416 = _S1194 == 0U;
        }
        else
        {
            _S1416 = false;
        }
        bool _S1417;
        if(_S1416)
        {
            _S1417 = ((&hit_4)->instance_index) == (_S1205.instance_index);
        }
        else
        {
            _S1417 = false;
        }
        bool _S1418;
        if(_S1417)
        {
            _S1418 = ((&hit_4)->triangle_index) == (_S1205.triangle_index);
        }
        else
        {
            _S1418 = false;
        }
        bool _S1419;
        if(_S1418)
        {
            _S1419 = _S1363;
        }
        else
        {
            _S1419 = false;
        }
        bool _S1420 = _slang_select(_S1407, _S1419,_S1414);
        bool _S1421;
        if(nee_0)
        {
            _S1421 = _slang_select(replay_1, _S1420,scatter_2);
        }
        else
        {
            _S1421 = false;
        }
        TreeSample _S1422 = TreeSample_x24init_0(_S1188, _S1188, 0.0f, 0U);
        uint2  _S1423 = make_uint2 (0U);
        float2  _S1424 = make_float2 (0.0f);
        FKHit _S1425 = Hit_x24init_0(_S1424, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1426 = _S1425;
        ShadowContext _S1427 = ShadowContext_x24init_0(_S1188, _S1188, _S1423, _S1188, 0U, 0U, false, 0.0f, 0.0f, &_S1426, false);
        bool _S1428;
        if(nee_0)
        {
            _S1428 = _S1385;
        }
        else
        {
            _S1428 = false;
        }
        ShadowContext context_5;
        if(_S1428)
        {
            uint _S1429 = arrivalLobe_0(b_5, (&prev_0)->lobe);
            FKMedium _S1430 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1431 = surface_12;
            FKHit _S1432 = hit_4;
            FKMedium _S1433 = _S1430;
            ShadowContext _S1434 = shadowContext_0(&_S1431, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_5, _S1429, (&hit_4)->distance, width_3, &_S1432, _S1374, &_S1433);
            context_5 = _S1434;
        }
        else
        {
            context_5 = _S1427;
        }
        float3  throughput_6;
        float3  lit_0;
        if(_S1421)
        {
            float3  _S1435 = (&ray_2)->origin;
            if(_S1374)
            {
                throughput_6 = _S1188;
            }
            else
            {
                throughput_6 = _S1365.smooth_n;
            }
            FKSurface _S1436 = surface_12;
            uint _S1437 = stream(_S1216, b_5 + 64U);
            ShadowContext _S1438 = context_5;
            TreeSample _S1439 = sampleLightTree_0(_S1435, throughput_6, surface_12.geometry_n, surface_12.geometry_offset, _S1379, _S1437, &_S1438);
            bool _S1440 = any_1((_S1439.radiance) != _S1188);
            if(_S1440)
            {
                if(_S1374)
                {
                    uint _S1441 = (fcptMaxBounces());
                    bool _S1442 = b_5 < _S1441;
                    FKSurface _S1443 = surface_12;
                    TreeSample _S1444 = _S1439;
                    float3  _S1445 = hairLight_0(&_S1443, (&ray_2)->unit_direction, &_S1444, _S1442);
                    lit_0 = _S1445;
                }
                else
                {
                    float _S1446 = _S1367.x;
                    float _S1447 = _S1367.y;
                    uint _S1448 = (fcptMaxBounces());
                    bool _S1449 = b_5 < _S1448;
                    TreeSample _S1450 = _S1439;
                    BSDFMaterial _S1451 = _S1364.material;
                    float3  _S1452 = lightBSDF_0((&ray_2)->unit_direction, &_S1450, _S1365.smooth_n, _S1436.geometry_n, &_S1451, _S1446, _S1447, _S1449, surface_12.random_state);
                    lit_0 = _S1452;
                }
            }
            else
            {
                lit_0 = _S1188;
            }
            light_3 = _S1439;
        }
        else
        {
            light_3 = _S1422;
            lit_0 = _S1188;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1453;
        bool _S1454;
        float density_4;
        if(_S1407)
        {
            bool _S1455 = !_S1363;
            if(_S1455)
            {
                return _S1189;
            }
            float3  throughput_7 = throughput_5 * make_float3 (geometry_density_0);
            float density_5 = density_2 * geometry_density_0;
            if(_S1415)
            {
                viewed_1 = _S1194 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                return Shift_x24init_0(throughput_7 * emission_1 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1415)
            {
                refracted_4 = _S1194 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S1456 = !nee_0;
                if(_S1456)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1457 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1457 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1189;
                }
                return Shift_x24init_0(throughput_7 * lit_0 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1415)
            {
                wrong_side_0 = _S1194 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1458 = !nee_0;
                if(_S1458)
                {
                    return _S1189;
                }
                float _S1459 = environmentPdf_0(r_8->dir);
                float3  _S1460 = skyBSDF((&ray_2)->unit_direction, r_8->dir, surface_12, _S1367, is_inside_6, _S1459, surface_12.random_state);
                return Shift_x24init_0(throughput_7 * _S1460 * r_8->radiance / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            uint _S1461 = extractBits_0(_S1190, 21U, 1U);
            bool _S1462 = nee_0 != (_S1461 == 1U);
            if(_S1462)
            {
                return _S1189;
            }
            throughput_6 = throughput_7;
            density_4 = density_5;
        }
        else
        {
            if(replay_1)
            {
                viewed_1 = _S1408;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1463 = !scatter_2;
                if(_S1463)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1464 = _S1193 != 1U;
                    if(_S1464)
                    {
                        refracted_4 = _S1193 != 3U;
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
                bool _S1465 = _S1193 == 2U;
                if(_S1465)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1363;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1194 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1374)
                    {
                        return _S1189;
                    }
                    uint _S1466 = stream(_S1216, b_5 + 448U);
                    FKRay _S1467 = ray_2;
                    FKSurface _S1468 = surface_12;
                    ShadowContext _S1469 = context_5;
                    SkySample _S1470 = sampleSky_0(&_S1467, &_S1468, _S1367, is_inside_6, _S1466, surface_12.random_state, &_S1469);
                    return Shift_x24init_0(throughput_5 * _S1470.color, 1.0f);
                }
                if(_S1465)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1363;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1471 = rgb_to_greyscale(light_3.radiance);
                    bool _S1472 = !(_S1471 > 0.0f);
                    if(_S1472)
                    {
                        return _S1189;
                    }
                    return Shift_x24init_0(throughput_5 * lit_0, 1.0f);
                }
                if(_S1203)
                {
                    passes_0 = _S1194 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1330;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                if(_S1203)
                {
                    passes_0 = _S1194 == 1U;
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
                    passes_0 = !_S1363;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                return _S1189;
            }
            else
            {
                if(_S1384)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1473 = b_5 > 0U;
                    if(_S1473)
                    {
                        Reservoir candidate_5 = chain_0;
                        if(_S1398)
                        {
                            float3  _S1474 = safeDivide(throughput_5 * emission_1, chain_throughput_0);
                            (&candidate_5)->radiance = _S1474;
                        }
                        else
                        {
                            if(_S1363)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1475 = throughput_5 * emission_1;
                        Reservoir _S1476 = withEnd(candidate_5, 1U, b_5, _S1475);
                        offer(sel_7, _S1476, _S1475 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1477 = throughput_5 * emission_1;
                        float3  _S1478 = sel_7->glow + _S1477;
                        sel_7->glow = _S1478;
                    }
                    if(nee_0)
                    {
                        float3  _S1479 = throughput_5 * lit_0;
                        Reservoir candidate_6 = chain_0;
                        if(_S1398)
                        {
                            float3  _S1480 = safeDivide(_S1479, chain_throughput_0);
                            (&candidate_6)->radiance = _S1480;
                        }
                        else
                        {
                            if(_S1363)
                            {
                                candidate_6 = here_0;
                                uint _S1481 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1481;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1482 = insertBits_0(0U, b_5 + 1U, 5U, 5U);
                                uint _S1483 = insertBits_0(_S1482, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1483;
                            }
                        }
                        Reservoir _S1484 = withEnd(candidate_6, 0U, b_5, _S1479);
                        offer(sel_7, _S1484, _S1479 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1374)
                        {
                            _S1453 = false;
                        }
                        else
                        {
                            bool _S1485 = environmentMapped_0();
                            _S1453 = _S1485;
                        }
                    }
                    else
                    {
                        _S1453 = false;
                    }
                    if(_S1453)
                    {
                        uint _S1486 = (fcptMaxBounces());
                        _S1454 = b_5 < _S1486;
                    }
                    else
                    {
                        _S1454 = false;
                    }
                    if(_S1454)
                    {
                        uint _S1487 = stream(_S1216, b_5 + 448U);
                        FKRay _S1488 = ray_2;
                        FKSurface _S1489 = surface_12;
                        ShadowContext _S1490 = context_5;
                        SkySample _S1491 = sampleSky_0(&_S1488, &_S1489, _S1367, is_inside_6, _S1487, surface_12.random_state, &_S1490);
                        float3  _S1492 = throughput_5 * _S1491.color;
                        Reservoir candidate_7 = chain_0;
                        if(_S1398)
                        {
                            float3  _S1493 = safeDivide(_S1492, chain_throughput_0);
                            (&candidate_7)->radiance = _S1493;
                        }
                        else
                        {
                            if(_S1363)
                            {
                                candidate_7 = here_0;
                                uint _S1494 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1494;
                                (&candidate_7)->dir = _S1491.dir;
                                (&candidate_7)->radiance = _S1491.radiance;
                            }
                            else
                            {
                                uint _S1495 = insertBits_0(0U, b_5 + 1U, 5U, 5U);
                                uint _S1496 = insertBits_0(_S1495, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1496;
                            }
                        }
                        Reservoir _S1497 = withEnd(candidate_7, 4U, b_5, _S1492);
                        offer(sel_7, _S1497, _S1492 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                }
            }
            throughput_6 = throughput_5;
            density_4 = density_2;
        }
        bool _S1498;
        bool _S1499;
        bool _S1500;
        bool straight_0;
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
        bool _S1511;
        bool _S1512;
        bool _S1513;
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
                viewed_1 = _S1408;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1514 = extractBits_0(_S1190, 15U, 3U);
            uint _S1515 = extractBits_0(_S1190, 18U, 3U);
            uint _S1516 = _slang_select(_S1407, _S1515,_S1514);
            float3  _S1517 = r_8->dir;
            bool refracted_5 = _S1516 == 1U;
            SampleBSDF _S1518 = SampleBSDF_x24init_0(_S1188, _S1188, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1518;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1519 = extractBits_0(_S1190, 22U, 1U);
                bool _S1520 = is_inside_6 != (_S1519 == 1U);
                if(_S1520)
                {
                    return _S1189;
                }
                bool _S1521 = _S1193 == 1U;
                if(_S1521)
                {
                    float3  _S1522 = (fcptHitPosition((_S1205)));
                    throughput_8 = _S1522;
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
                    BSDFMaterial _S1523 = _S1364.material;
                    bool _S1524 = isTranslucent_0(&_S1523);
                    if(_S1524)
                    {
                        refracted_4 = _S1516 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1525 = throughput_8 - (&ray_2)->origin;
                        float3  _S1526 = _slang_select(_S1521, _S1525,_S1517);
                        wrong_side_0 = (dot_0(_S1365.smooth_n, _S1526) * _S1366) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1521)
                {
                    float3  _S1527 = (&ray_2)->origin;
                    FKSurface _S1528 = surface_12;
                    float3  _S1529 = - _S1365.smooth_n;
                    bool _S1530 = is_inside_6 != refracted_4;
                    float3  _S1531 = _slang_select(_S1530, _S1529,_S1365.smooth_n);
                    float3  _S1532 = throughput_8 - (_S1527 + make_float3 (_S1528.geometry_offset) * _S1531);
                    float3  _S1533 = ((((_S1532)) * make_float3(rnorm3df(((_S1532)).x, ((_S1532)).y, ((_S1532)).z))));
                    reconnection_1 = _S1533;
                }
                else
                {
                    reconnection_1 = _S1517;
                }
                if(_S1374)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1534 = wrongSide_0(is_inside_6, refracted_4, reconnection_1, surface_12.geometry_n);
                    wrong_side_0 = _S1534;
                }
                if(wrong_side_0)
                {
                    return _S1189;
                }
                float3  _S1535 = throughput_8;
                throughput_8 = reconnection_1;
                b_8 = _S1516;
                wrong_side_0 = false;
                reconnection_1 = _S1535;
            }
            else
            {
                bool _S1536 = !_S1407;
                if(_S1536)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1537;
                    if(_S1374)
                    {
                        SampleBSDF _S1538 = (fcptSampleHair((surface_12.hair), (_S1364.material.albedo), (_S1364.material.specular_tint), ((&ray_2)->unit_direction), (surface_12.random_state)));
                        _S1537 = _S1538;
                    }
                    else
                    {
                        SampleBSDF _S1539 = sampleBSDF((&ray_2)->unit_direction, _S1365.smooth_n, _S1364.material, _S1367.x, _S1367.y, surface_12.random_state, _S1424);
                        _S1537 = _S1539;
                    }
                    bsdf_sampled_0 = _S1537;
                    if(_S1374)
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
                            return _S1189;
                        }
                        break;
                    }
                    if(_S1374)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1540 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_12.geometry_n);
                        wrong_side_0 = _S1540;
                    }
                    if(wrong_side_0)
                    {
                        _S1453 = (_S1364.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1453 = false;
                    }
                    if(_S1453)
                    {
                        SampleBSDF _S1541 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S1364.material, _S1367.x, _S1367.y, (&bsdf_sampled_0)->random_state, _S1424);
                        (&bsdf_sampled_0)->unit_direction = _S1541.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1541.refracted;
                        (&bsdf_sampled_0)->throughput = _S1541.throughput;
                        (&bsdf_sampled_0)->lobe = _S1541.lobe;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1542 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n)) * surface_12.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1542;
                        }
                    }
                    uint _S1543 = (&bsdf_sampled_0)->lobe;
                    float3  _S1544 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1545 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1546 = (&bsdf_sampled_0)->pdf;
                    float _S1547 = _slang_select(wrong_side_0, 0.0f,_S1546);
                    (&lobe_5)->pdf = _S1547;
                    throughput_8 = _S1544;
                    b_8 = _S1543;
                    refracted_4 = _S1545;
                }
                else
                {
                    throughput_8 = _S1517;
                    b_8 = _S1516;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1453 = true;
            }
            else
            {
                _S1453 = _S1407;
            }
            float3  chain_throughput_1;
            if(_S1453)
            {
                if(_S1374)
                {
                    SampleBSDF _S1548 = (fcptConnectHair((surface_12.hair), (_S1364.material.albedo), (_S1364.material.specular_tint), ((&ray_2)->unit_direction), (throughput_8)));
                    lobe_5 = _S1548;
                }
                else
                {
                    float3  _S1549 = (&ray_2)->unit_direction;
                    float _S1550 = sign_0(_S1366);
                    float3  _S1551 = _S1365.smooth_n * make_float3 (_S1550);
                    float _S1552 = dot_0(_S1551, throughput_8);
                    float _S1553 = _S1364.material.roughness;
                    float _S1554 = _S1553 * _S1553;
                    AnisotropicFrame _S1555 = anisotropicFrame(_S1364.material, _S1551);
                    float3  _S1556 = negate_0(_S1549);
                    SheenProfile _S1557 = sheenProfile(_S1556, _S1551, _S1364.material);
                    float3  _S1558 = reflectedHalf(_S1549, throughput_8);
                    bool _S1559 = b_8 == 1U;
                    if(_S1559)
                    {
                        float3  _S1560 = refractedHalf(_S1549, throughput_8, _S1365.smooth_n, _S1367.x, _S1367.y);
                        throughput_9 = _S1560;
                    }
                    else
                    {
                        throughput_9 = _S1558;
                    }
                    bool _S1561 = b_8 == 0U;
                    if(_S1561)
                    {
                        _S1454 = true;
                    }
                    else
                    {
                        _S1454 = b_8 == 6U;
                    }
                    if(_S1454)
                    {
                        float3  _S1562 = sampledHalf(_S1549, _S1365.smooth_n, _S1364.material, surface_12.random_state, _S1555);
                        throughput_10 = _S1562;
                    }
                    else
                    {
                        throughput_10 = throughput_9;
                    }
                    float3  _S1563 = negate_0(_S1549);
                    float _S1564 = _S1367.x;
                    float _S1565 = _S1367.y;
                    BSDFLobes _S1566 = bsdfLobes(_S1549, _S1563, _S1551, throughput_10, _S1364.material, _S1564, _S1565, _S1555, _S1557);
                    BSDFLobes lobe_terms_1 = _S1566;
                    float _S1567 = translucentShare(_S1364.material);
                    (&lobe_terms_1)->translucent_share = _S1567;
                    switch(b_8)
                    {
                    case 0U:
                        {
                            float _S1568 = diffusePDF(_S1552, 0.0f, (F32_abs((_S1366))), _S1554, lobe_terms_1, _S1564, _S1565);
                            float3  _S1569 = diffuseBSDF(throughput_8, _S1551, _S1554, _S1364.material, lobe_terms_1);
                            density_6 = _S1568;
                            chain_throughput_1 = _S1569;
                            break;
                        }
                    case 1U:
                        {
                            float _S1570 = refractPDF(_S1552, dot_0(throughput_8, throughput_10), (F32_abs((_S1366))), _S1554, lobe_terms_1, _S1564, _S1565);
                            float3  _S1571 = refractBSDF(throughput_8, _S1551, _S1554, _S1364.material, lobe_terms_1);
                            density_6 = _S1570;
                            chain_throughput_1 = _S1571;
                            break;
                        }
                    case 4U:
                        {
                            float _S1572 = sheenVelvetPDF(_S1552, 0.0f, (F32_abs((_S1366))), _S1554, lobe_terms_1, _S1564, _S1565);
                            float3  _S1573 = sheenVelvetBSDF(throughput_8, _S1551, _S1554, _S1364.material, lobe_terms_1);
                            density_6 = _S1572;
                            chain_throughput_1 = _S1573;
                            break;
                        }
                    case 6U:
                        {
                            float _S1574 = toonPDF(_S1552, dot_0(throughput_8, (&lobe_terms_1)->toon_axis), (F32_abs((_S1366))), _S1554, lobe_terms_1, _S1564, _S1565);
                            float3  _S1575 = toonBSDF(throughput_8, _S1551, _S1554, _S1364.material, lobe_terms_1);
                            density_6 = _S1574;
                            chain_throughput_1 = _S1575;
                            break;
                        }
                    default:
                        {
                            float _S1576 = reflectPDF(_S1552, 0.0f, (F32_abs((_S1366))), _S1554, lobe_terms_1, _S1564, _S1565);
                            float3  _S1577 = reflectBSDF(throughput_8, _S1551, _S1554, _S1364.material, lobe_terms_1);
                            density_6 = _S1576;
                            chain_throughput_1 = _S1577;
                            break;
                        }
                    }
                    bool _S1578 = density_6 > 0.0f;
                    if(_S1578)
                    {
                        SampleBSDF _S1579 = SampleBSDF_x24init_0(throughput_8, chain_throughput_1, surface_12.random_state, _S1559, b_8, density_6);
                        lobe_5 = _S1579;
                    }
                }
            }
            bool _S1580 = b_8 == 0U;
            if(_S1580)
            {
                _S1454 = true;
            }
            else
            {
                _S1454 = b_8 == 4U;
            }
            if(_S1454)
            {
                _S1498 = true;
            }
            else
            {
                _S1498 = b_8 == 6U;
            }
            if(_S1374)
            {
                _S1499 = false;
            }
            else
            {
                bool _S1581 = !_S1498;
                if(_S1581)
                {
                    bool _S1582 = (_S1364.material.roughness) == 0.0f;
                    if(_S1582)
                    {
                        _S1499 = true;
                    }
                    else
                    {
                        bool _S1583 = b_8 == 1U;
                        if(_S1583)
                        {
                            _S1499 = (_S1367.x) == (_S1367.y);
                        }
                        else
                        {
                            _S1499 = false;
                        }
                    }
                }
                else
                {
                    _S1499 = false;
                }
            }
            bool _S1584 = !_S1374;
            if(_S1584)
            {
                _S1500 = b_8 == 1U;
            }
            else
            {
                _S1500 = false;
            }
            if(_S1500)
            {
                straight_0 = (_S1364.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1501 = _S1584;
            }
            else
            {
                _S1501 = false;
            }
            if(_S1501)
            {
                _S1502 = b_8 == 1U;
            }
            else
            {
                _S1502 = false;
            }
            if(_S1502)
            {
                _S1503 = (_S1367.x) == (_S1367.y);
            }
            else
            {
                _S1503 = false;
            }
            BSDFMaterial _S1585 = _S1364.material;
            bool _S1586 = isTranslucent_0(&_S1585);
            if(_S1586)
            {
                _S1504 = _S1580;
            }
            else
            {
                _S1504 = false;
            }
            if(_S1504)
            {
                _S1505 = (dot_0(throughput_8, surface_12.geometry_n)) < 0.0f;
            }
            else
            {
                _S1505 = false;
            }
            if(nee_0)
            {
                _S1506 = !_S1499;
            }
            else
            {
                _S1506 = false;
            }
            if(_S1506)
            {
                _S1507 = !wrong_side_0;
            }
            else
            {
                _S1507 = false;
            }
            if(_S1507)
            {
                float _S1587 = (&lobe_5)->pdf;
                float3  _S1588 = (&ray_2)->origin;
                float3  _S1589 = _slang_select(_S1379, _S1188,_S1365.smooth_n);
                float3  _S1590 = (&ray_2)->origin;
                FKSurface _S1591 = surface_12;
                float3  _S1592 = - _S1365.smooth_n;
                float3  _S1593 = _slang_select(_S1505, _S1592,_S1365.smooth_n);
                NEEVertex _S1594 = NEEVertex_x24init_0(false, _S1587, _S1588, _S1589, _S1590 + make_float3 (_S1591.geometry_offset) * _S1593);
                nee_vertex_0 = _S1594;
            }
            else
            {
                if(_S1374)
                {
                    _S1508 = true;
                }
                else
                {
                    bool _S1595 = b_8 != 1U;
                    if(_S1595)
                    {
                        _S1508 = true;
                    }
                    else
                    {
                        _S1508 = (_S1367.x) != (_S1367.y);
                    }
                }
                if(_S1508)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1596 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1596)
            {
                if(_S1498)
                {
                    _S1508 = true;
                }
                else
                {
                    _S1508 = ((&lobe_5)->pdf * (&prev_0)->cos / ((&hit_4)->distance * (&hit_4)->distance) * threshold_0) <= 1.0f;
                }
            }
            else
            {
                _S1508 = false;
            }
            bool _S1597 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1597)
            {
                if(_S1498)
                {
                    _S1509 = true;
                }
                else
                {
                    _S1509 = (_S1364.material.roughness) >= 0.20000000298023224f;
                }
            }
            else
            {
                _S1509 = false;
            }
            if(_S1407)
            {
                bool _S1598 = !_S1508;
                if(_S1598)
                {
                    return _S1189;
                }
                bool _S1599 = _S1194 != 1U;
                if(_S1599)
                {
                    _S1510 = _S1194 != 2U;
                }
                else
                {
                    _S1510 = false;
                }
                if(_S1510)
                {
                    float _S1600 = (&lobe_5)->pdf;
                    float _S1601 = _slang_select(nee_0, _S1600,0.0f);
                    float _S1602 = escapeWeight_0(_S1601, _S1517);
                    if(_S1415)
                    {
                        passes_0 = _S1200;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1603 = _slang_select(passes_0, _S1602,1.0f);
                    return Shift_x24init_0(throughput_6 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_8->radiance * make_float3 (_S1603) / make_float3 (r_8->jac), density_4 * (&lobe_5)->pdf / r_8->jac);
                }
                float3  _S1604 = throughput_6 * make_float3 ((&lobe_5)->pdf);
                float _S1605 = density_4 * (&lobe_5)->pdf;
                throughput_9 = _S1604;
                density_6 = _S1605;
            }
            else
            {
                throughput_9 = throughput_6;
                density_6 = density_4;
            }
            uint _S1606 = (fcptLayers((hit_4)));
            bool _S1607 = _S1606 > 1U;
            if(_S1607)
            {
                _S1510 = (b_8 == 1U) != passes_0;
            }
            else
            {
                _S1510 = false;
            }
            if(viewed_1)
            {
                _S1511 = _S1510;
            }
            else
            {
                _S1511 = false;
            }
            if(_S1511)
            {
                return _S1189;
            }
            if(replay_1)
            {
                _S1512 = b_5 <= _S1204;
            }
            else
            {
                _S1512 = false;
            }
            if(_S1512)
            {
                _S1513 = _S1363;
            }
            else
            {
                _S1513 = false;
            }
            bool _S1608;
            if(_S1513)
            {
                _S1608 = _S1508;
            }
            else
            {
                _S1608 = false;
            }
            bool _S1609;
            if(_S1608)
            {
                _S1609 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1609 = !_S1509;
                }
                else
                {
                    _S1609 = false;
                }
            }
            if(_S1609)
            {
                return _S1189;
            }
            if(viewed_1)
            {
                float3  _S1610 = throughput_9 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1611 = (&lobe_5)->pdf;
                throughput_10 = _S1610;
                sky_pdf_2 = _S1611;
            }
            else
            {
                float3  _S1612 = throughput_9 * max_0((&lobe_5)->throughput, _S1188);
                throughput_10 = _S1612;
                sky_pdf_2 = density_6;
            }
            bool _S1613;
            if(_S1384)
            {
                _S1613 = !_S1398;
            }
            else
            {
                _S1613 = false;
            }
            bool _S1614;
            if(_S1613)
            {
                _S1614 = _S1363;
            }
            else
            {
                _S1614 = false;
            }
            bool _S1615;
            if(_S1614)
            {
                _S1615 = _S1508;
            }
            else
            {
                _S1615 = false;
            }
            if(_S1615)
            {
                chain_0 = here_0;
                uint _S1616 = insertBits_0((&chain_0)->path, b_8, 18U, 3U);
                uint _S1617 = _slang_select(nee_0, 1U,0U);
                uint _S1618 = insertBits_0(_S1616, _S1617, 21U, 1U);
                (&chain_0)->path = _S1618;
                float _S1619 = (&chain_0)->jac * (&lobe_5)->pdf;
                (&chain_0)->jac = _S1619;
                (&chain_0)->dir = throughput_8;
                chain_throughput_1 = throughput_10;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1620 = surface_12;
            Vertex _S1621 = Vertex_x24init_0(_S1509, b_8, (&lobe_5)->pdf, (F32_abs((dot_0(surface_12.geometry_n, throughput_8)))), is_inside_6);
            prev_0 = _S1621;
            float _S1622 = (&lobe_5)->pdf;
            bool _S1623 = b_8 == 1U;
            bool _S1624;
            if(_S1623)
            {
                _S1624 = (_S1367.x) == (_S1367.y);
            }
            else
            {
                _S1624 = false;
            }
            float sky_pdf_3 = _slang_select(_S1624, sky_pdf_0,_S1622);
            float _S1625 = _slang_select(_S1374, 0.0f,sky_pdf_3);
            float _S1626 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * (&lobe_5)->pdf))))), (3.14159274101257324f)));
            bool _S1627 = !_S1499;
            float _S1628 = _slang_select(_S1627, _S1626,0.0f);
            float _S1629 = spread_1 + _S1628;
            bool _S1630;
            if(refracted_4)
            {
                _S1630 = !_S1505;
            }
            else
            {
                _S1630 = false;
            }
            bool is_inside_7;
            if(_S1630)
            {
                bool _S1631 = !is_inside_6;
                is_inside_7 = _S1631;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            FKSurface _S1632 = surface_12;
            bool _S1633 = boundsVolume_0(&_S1632);
            bool _S1634;
            if(_S1633)
            {
                _S1634 = !_S1510;
            }
            else
            {
                _S1634 = false;
            }
            if(_S1634)
            {
                FKSurface faced_2 = surface_12;
                float3  _S1635 = - _S1620.geometry_n;
                float3  _S1636 = _slang_select(turned_1, _S1635,_S1620.geometry_n);
                (&faced_2)->geometry_n = _S1636;
                FKMedium _S1637 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1638 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1639 = faced_2;
                FKMedium _S1640 = _S1637;
                FKMedium _S1641 = _S1638;
                MediumSides _S1642 = mediumSides_0(&_S1639, &_S1640, filling_2, (&ray_2)->unit_direction, &_S1641);
                bool _S1643 = ((dot_0(throughput_8, _S1620.geometry_n)) > 0.0f) == ((dot_0(_S1620.geometry_n, (&faced_2)->geometry_n)) > 0.0f);
                float3  _S1644 = _slang_select(_S1643, _S1642.front.scatter,_S1642.behind.scatter);
                scatter_in_0 = _S1644;
                float3  _S1645 = _slang_select(_S1643, _S1642.front.extinction,_S1642.behind.extinction);
                extinction_in_0 = _S1645;
                float _S1646 = _slang_select(_S1643, _S1642.front.g,_S1642.behind.g);
                g_in_0 = _S1646;
                uint _S1647 = _S1642.fillings.x;
                uint _S1648 = _S1642.fillings.y;
                uint _S1649 = _slang_select(_S1643, _S1648,_S1647);
                bool _S1650 = (fcptVaryingUsed());
                uint _S1651 = _slang_select(_S1650, _S1649,4294967295U);
                filling_2 = _S1651;
            }
            (&ray_2)->unit_direction = throughput_8;
            bool _S1652 = !_S1510;
            if(_S1652)
            {
                FKSurface _S1653 = surface_12;
                float _S1654 = _slang_select(straight_0, 0.0f,_S1653.geometry_offset);
                float3  _S1655 = - _S1365.smooth_n;
                bool _S1656 = is_inside_7 != _S1505;
                float3  _S1657 = _slang_select(_S1656, _S1655,_S1365.smooth_n);
                float3  _S1658 = (&ray_2)->origin + make_float3 (_S1654) * _S1657;
                (&ray_2)->origin = _S1658;
            }
            throughput_9 = throughput_10;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1510;
            viewed_1 = _S1503;
            sky_pdf_2 = _S1625;
            spread_4 = _S1629;
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
        if(_S1384)
        {
            if(_S1330)
            {
                float3  _S1659 = throughput_9 * emission_1;
                Reservoir candidate_8 = chain_0;
                uint _S1660 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1661 = _S1660 == 1U;
                if(_S1661)
                {
                    float3  _S1662 = safeDivide(_S1659, chain_throughput_0);
                    (&candidate_8)->radiance = _S1662;
                }
                Reservoir _S1663 = withEnd(candidate_8, 2U, b_5, _S1659);
                offer(sel_7, _S1663, _S1659 * make_float3 (scale_3) / make_float3 (density_6));
            }
            if(_S1330)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1664 = survivalProbability(throughput_9, density_6);
                density_7 = _S1664;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1665 = stream(_S1216, b_5 + 128U);
            Random _S1666 = pcg(_S1665);
            bool _S1667 = density_7 < (_S1666.value);
            if(_S1667)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1668 = (fcptMaxBounces());
                wrong_side_0 = b_5 >= _S1668;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1669 = density_6 * density_7;
            density_7 = _S1669;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1670 = layer_0 ^ 1U;
        uint _S1671 = _slang_select(passes_0, _S1670,0U);
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
            uint _S1672 = b_8 + 1U;
            b_5 = _S1672;
            layer_0 = _S1671;
            continue;
        }
        FKRay _S1673 = ray_2;
        float _S1674 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_1)
        {
            refracted_4 = _S1408;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S1193 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1675 = _slang_select(wrong_side_0, _S1674,4.294967296e+09f);
        bool _S1676 = !_S1374;
        if(straight_0)
        {
            _S1453 = true;
        }
        else
        {
            _S1453 = _S1374;
        }
        FKHit _S1677;
        if(_S1453)
        {
            _S1677 = hit_4;
        }
        else
        {
            _S1677 = _S1425;
        }
        FKHit _S1678 = (fcptTraverseInstanceBVH((_S1673), (_S1337), (_S1675), (_S1676), (_S1677), (viewed_1)));
        hit_4 = _S1678;
        if(replay_1)
        {
            _S1454 = _S1408;
        }
        else
        {
            _S1454 = false;
        }
        if(_S1454)
        {
            _S1498 = _S1193 == 1U;
        }
        else
        {
            _S1498 = false;
        }
        if(_S1498)
        {
            _S1499 = ((&hit_4)->instance_index) == (_S1205.instance_index);
        }
        else
        {
            _S1499 = false;
        }
        if(_S1499)
        {
            _S1500 = ((&hit_4)->triangle_index) == (_S1205.triangle_index);
        }
        else
        {
            _S1500 = false;
        }
        if(_S1500)
        {
            (&hit_4)->uv = _S1205.uv;
            float _S1679 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S1679;
        }
        if(replay_1)
        {
            _S1501 = _S1408;
        }
        else
        {
            _S1501 = false;
        }
        if(_S1501)
        {
            _S1502 = _S1193 == 3U;
        }
        else
        {
            _S1502 = false;
        }
        if(_S1502)
        {
            _S1503 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1503 = false;
        }
        if(_S1503)
        {
            return _S1189;
        }
        Reservoir _S1680 = chain_0;
        uint _S1681 = filling_2;
        for(;;)
        {
            bool _S1682 = (fcptVaryingUsed());
            if(_S1682)
            {
                _S1504 = _S1681 != 4294967295U;
            }
            else
            {
                _S1504 = false;
            }
            float _S1683;
            if(_S1504)
            {
                float _S1684 = (fcptMajorant((_S1681)));
                _S1683 = _S1684;
            }
            else
            {
                _S1683 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_1)
            {
                _S1505 = _S1408;
            }
            else
            {
                _S1505 = false;
            }
            if(_S1505)
            {
                _S1506 = _S1193 == 1U;
            }
            else
            {
                _S1506 = false;
            }
            if(_S1506)
            {
                _S1507 = _S1683 > 0.0f;
            }
            else
            {
                _S1507 = false;
            }
            if(_S1507)
            {
                ended_0 = _S1189;
                sky_pdf_1 = sky_pdf_2;
                spread_2 = spread_4;
                width_4 = width_3;
                density_3 = density_7;
                throughput_10 = throughput_9;
                b_8 = b_5;
                _S1508 = true;
                break;
            }
            bool _S1685 = (&prev_0)->rough;
            if(_S1685)
            {
                _S1508 = !(_S1683 > 0.0f);
            }
            else
            {
                _S1508 = false;
            }
            (&prev_0)->rough = _S1508;
            uint _S1686 = b_5 + 320U;
            bool _S1687 = b_5 == 4294967295U;
            uint _S1688 = _slang_select(_S1687, 384U,_S1686);
            uint _S1689 = stream(_S1216, _S1688);
            uint tracking_1 = _S1689;
            weight_1 = throughput_3;
            glowed_0 = _S1188;
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
                    _S1187 = int(2);
                    break;
                }
                uint _S1690 = b_8 + 320U;
                bool _S1691 = b_8 == 4294967295U;
                uint _S1692 = _slang_select(_S1691, 384U,_S1690);
                uint _S1693 = stream(_S1216, _S1692);
                Random _S1694 = pcg(_S1693);
                float _S1695 = - (F32_log((1.0f - _S1694.value))) / _S1683;
                if(_S1504)
                {
                    float3  _S1696 = (&ray_2)->origin;
                    float3  _S1697 = (&ray_2)->unit_direction;
                    float _S1698 = (&hit_4)->distance;
                    uint _S1699 = _slang_select(_S1691, 0U,b_8);
                    uint _S1700 = (&prev_0)->lobe;
                    uint _S1701 = _slang_select(_S1691, 3U,_S1700);
                    float _S1702 = (fcptTrackMedium((_S1681), (_S1696), (_S1697), (_S1698), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1699), (_S1701), (_S1691)));
                    spread_3 = _S1702;
                }
                else
                {
                    spread_3 = _S1695;
                }
                bool _S1703 = !(spread_3 < ((&hit_4)->distance));
                if(_S1703)
                {
                    _S1187 = int(2);
                    break;
                }
                if(_S1504)
                {
                    _S1509 = _S1384;
                }
                else
                {
                    _S1509 = false;
                }
                if(_S1509)
                {
                    float3  _S1704 = throughput_10 * glowed_0 / make_float3 (density_3);
                    float3  _S1705 = sel_7->glow + _S1704;
                    sel_7->glow = _S1705;
                }
                else
                {
                }
                glowed_0 = _S1188;
                uint b_9 = b_8 + 1U;
                float3  _S1706 = (&ray_2)->origin + make_float3 (spread_3) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1706;
                float3  _S1707 = flightWeight_0(scatter_in_0, extinction_in_0, _S1683, spread_3, true);
                float3  _S1708 = weight_1;
                float3  _S1709 = _slang_select(_S1504, _S1708,_S1707);
                float3  throughput_11 = throughput_10 * _S1709;
                uint _S1710 = stream(_S1216, b_9 + 320U);
                tracking_1 = _S1710;
                weight_1 = throughput_3;
                float width_7 = width_4 + spread_2 * spread_3;
                float _S1711 = spread_2 + 3.14159274101257324f;
                if(_S1384)
                {
                    _S1510 = true;
                }
                else
                {
                    bool _S1712 = b_9 == _S1204;
                    if(_S1712)
                    {
                        _S1510 = !_S1504;
                    }
                    else
                    {
                        _S1510 = false;
                    }
                }
                TreeSample light_4;
                if(_S1510)
                {
                    float3  _S1713 = (&ray_2)->origin;
                    float3  _S1714 = (&ray_2)->unit_direction;
                    float3  _S1715 = (&ray_2)->unit_direction;
                    uint _S1716 = stream(_S1216, b_9 + 64U);
                    float3  _S1717 = extinction_in_0;
                    float3  _S1718 = extinction_in_0;
                    uint2  _S1719 = make_uint2 (_S1681);
                    float3  _S1720 = (&ray_2)->unit_direction;
                    uint _S1721 = arrivalLobe_0(b_9, (&prev_0)->lobe);
                    FKHit _S1722 = _S1425;
                    ShadowContext _S1723 = ShadowContext_x24init_0(_S1717, _S1718, _S1719, _S1720, b_9, _S1721, false, spread_3, width_7, &_S1722, false);
                    ShadowContext _S1724 = _S1723;
                    TreeSample _S1725 = sampleLightTree_0(_S1713, _S1714, _S1715, 0.0f, true, _S1716, &_S1724);
                    light_4 = _S1725;
                }
                else
                {
                    light_4 = _S1422;
                }
                float _S1726 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1727 = (fcptMaxBounces());
                bool _S1728 = b_9 < _S1727;
                if(_S1728)
                {
                    _S1511 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1511 = false;
                }
                float _S1729 = _slang_select(_S1511, _S1726,0.0f);
                float3  _S1730 = throughput_11 * light_4.radiance;
                float _S1731 = powerHeuristic(light_4.density, _S1729);
                float3  _S1732 = _S1730 * make_float3 (_S1726 * _S1731);
                float3  _S1733 = _slang_select(_S1510, _S1732,_S1188);
                if(replay_1)
                {
                    _S1512 = b_9 == _S1204;
                }
                else
                {
                    _S1512 = false;
                }
                if(_S1512)
                {
                    bool _S1734 = _S1193 == 2U;
                    if(_S1734)
                    {
                        float _S1735 = rgb_to_greyscale(_S1733);
                        _S1513 = _S1735 > 0.0f;
                    }
                    else
                    {
                        _S1513 = false;
                    }
                    if(_S1513)
                    {
                        Shift _S1736 = Shift_x24init_0(_S1733, 1.0f);
                        _S1187 = int(1);
                        ended_0 = _S1736;
                        spread_3 = _S1711;
                        width_5 = width_7;
                        throughput_8 = throughput_11;
                        b_6 = b_9;
                        break;
                    }
                    _S1187 = int(1);
                    ended_0 = _S1189;
                    spread_3 = _S1711;
                    width_5 = width_7;
                    throughput_8 = throughput_11;
                    b_6 = b_9;
                    break;
                }
                if(_S1384)
                {
                    Reservoir candidate_9 = _S1680;
                    uint _S1737 = extractBits_0(_S1680.path, 10U, 2U);
                    bool _S1738 = _S1737 == 1U;
                    if(_S1738)
                    {
                        float3  _S1739 = safeDivide(_S1733, chain_throughput_0);
                        (&candidate_9)->radiance = _S1739;
                    }
                    else
                    {
                        uint _S1740 = insertBits_0(0U, b_9 + 1U, 5U, 5U);
                        uint _S1741 = insertBits_0(_S1740, 2U, 10U, 2U);
                        (&candidate_9)->path = _S1741;
                    }
                    Reservoir _S1742 = withEnd(candidate_9, 0U, b_9, _S1733);
                    offer(sel_7, _S1742, _S1733 * make_float3 (scale_3) / make_float3 (density_3));
                    float _S1743 = survivalProbability(throughput_11, density_3);
                    uint _S1744 = stream(_S1216, b_9 + 128U);
                    Random _S1745 = pcg(_S1744);
                    bool _S1746 = _S1743 < (_S1745.value);
                    if(_S1746)
                    {
                        _S1513 = true;
                    }
                    else
                    {
                        uint _S1747 = (fcptMaxBounces());
                        _S1513 = b_9 >= _S1747;
                    }
                    if(_S1513)
                    {
                        _S1187 = int(1);
                        ended_0 = _S1189;
                        spread_3 = _S1711;
                        width_5 = width_7;
                        throughput_8 = throughput_11;
                        b_6 = b_9;
                        break;
                    }
                    float _S1748 = density_3 * _S1743;
                    density_3 = _S1748;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1749 = stream(_S1216, b_9);
                float3  _S1750 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1749, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1750;
                NEEVertex _S1751 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1188, (&ray_2)->origin);
                nee_vertex_0 = _S1751;
                Vertex _S1752 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_5);
                prev_0 = _S1752;
                float _S1753 = (&prev_0)->pdf;
                FKRay _S1754 = ray_2;
                FKHit _S1755 = (fcptTraverseInstanceBVH((_S1754), (true), (4.294967296e+09f), (false), (_S1425), (false)));
                hit_4 = _S1755;
                b_8 = b_9;
                throughput_10 = throughput_11;
                spread_2 = _S1711;
                width_4 = width_7;
                sky_pdf_1 = _S1753;
            }
            if(_S1187 != int(2))
            {
                spread_2 = spread_3;
                width_4 = width_5;
                throughput_10 = throughput_8;
                b_8 = b_6;
                _S1508 = true;
                break;
            }
            ended_0 = _S1189;
            _S1508 = false;
            break;
        }
        if(_S1508)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1509 = b_8 == b_5;
        }
        else
        {
            _S1509 = false;
        }
        bool _S1756 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S1756)
        {
            bool _S1757 = !(&nee_vertex_0)->none;
            float _S1758 = _slang_select(_S1757, sky_pdf_1,0.0f);
            float _S1759 = escapeWeight_0(_S1758, (&ray_2)->unit_direction);
            float3  _S1760 = environment_0((&ray_2)->unit_direction, b_8, (&prev_0)->lobe);
            float3  _S1761 = throughput_10 * _S1760;
            if(replay_1)
            {
                bool _S1762 = b_8 == _S1204;
                if(_S1762)
                {
                    passes_0 = _S1193 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1761 * make_float3 (_S1759) / make_float3 (r_8->jac), density_3 / r_8->jac);
                }
                if(_S1203)
                {
                    passes_0 = _S1200;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_8 == _S1191;
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
                    return Shift_x24init_0(_S1761 * make_float3 (_S1759), 1.0f);
                }
                return _S1189;
            }
            Reservoir candidate_10 = chain_0;
            uint _S1763 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1764 = _S1763 == 1U;
            if(_S1764)
            {
                uint _S1765 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1766 = _S1765 == b_8;
                float _S1767 = _slang_select(_S1766, 1.0f,_S1759);
                float3  _S1768 = safeDivide(_S1761 * make_float3 (_S1767), chain_throughput_0);
                (&candidate_10)->radiance = _S1768;
            }
            else
            {
                bool _S1769 = (&prev_0)->rough;
                if(_S1769)
                {
                    uint _S1770 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                    uint _S1771 = insertBits_0(_S1770, 3U, 10U, 2U);
                    uint _S1772 = insertBits_0(_S1771, (&prev_0)->lobe, 15U, 3U);
                    bool _S1773 = (&prev_0)->inside;
                    uint _S1774 = _slang_select(_S1773, 1U,0U);
                    uint _S1775 = insertBits_0(_S1772, _S1774, 22U, 1U);
                    (&candidate_10)->path = _S1775;
                    (&candidate_10)->jac = (&prev_0)->pdf;
                    (&candidate_10)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1776 = _S1761 * make_float3 (_S1759);
            Reservoir _S1777 = withEnd(candidate_10, 3U, b_8, _S1776);
            offer(sel_7, _S1777, _S1776 * make_float3 (scale_3) / make_float3 (density_3));
            break;
        }
        float3  _S1778 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1778;
        bool _S1779 = (fcptVaryingUsed());
        if(_S1779)
        {
            _S1510 = filling_2 != 4294967295U;
        }
        else
        {
            _S1510 = false;
        }
        if(_S1510)
        {
            if(_S1384)
            {
                float3  _S1780 = throughput_10 * glowed_0 / make_float3 (density_3);
                float3  _S1781 = sel_7->glow + _S1780;
                sel_7->glow = _S1781;
            }
            float3  _S1782 = throughput_10 * weight_1;
            throughput_8 = _S1782;
        }
        else
        {
            float3  _S1783 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S1784 = throughput_10 * _S1783;
            throughput_8 = _S1784;
        }
        float _S1785 = width_4 + spread_2 * (&hit_4)->distance;
        viewed_0 = _S1509;
        width_3 = _S1785;
        throughput_2 = throughput_8;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_1 = spread_2;
        uint _S1672 = b_8 + 1U;
        b_5 = _S1672;
        layer_0 = _S1671;
    }
    return _S1189;
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
    Random _S1786 = pcg(state_3);
    Random _S1787 = pcg(_S1786.state);
    float _S1788 = 6.28318548202514648f * _S1786.value;
    float _S1789 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S1787.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1787.state, _S1789 * (F32_cos((_S1788))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_4, float3  value_2)
{
    RandomSphere _S1790;
    (&_S1790)->state = state_4;
    (&_S1790)->value = value_2;
    return _S1790;
}

__device__ RandomSphere random_sphere(uint state_5)
{
    Random _S1791 = normal_distribution(state_5);
    Random _S1792 = normal_distribution(_S1791.state);
    Random _S1793 = normal_distribution(_S1792.state);
    float3  _S1794 = make_float3 (_S1791.value, _S1792.value, _S1793.value);
    float3  _S1795 = ((((_S1794)) * make_float3(rnorm3df(((_S1794)).x, ((_S1794)).y, ((_S1794)).z))));
    return RandomSphere_x24init_0(_S1793.state, _S1795);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_13)
{
    float3  _S1796 = p1_0 - p0_0;
    float3  _S1797 = p2_0 - p0_0;
    float2  _S1798 = uv1_0 - uv0_0;
    float2  _S1799 = uv2_0 - uv0_0;
    float _S1800 = _S1798.x;
    float _S1801 = _S1799.y;
    float _S1802 = _S1798.y;
    float _S1803 = _S1799.x;
    float _S1804 = _S1800 * _S1801 - _S1802 * _S1803;
    float _S1805 = 1.0f / _S1804;
    float3  t_21 = (_S1796 * make_float3 (_S1801) - _S1797 * make_float3 (_S1802)) * make_float3 (_S1805);
    float3  _S1806 = (_S1797 * make_float3 (_S1800) - _S1796 * make_float3 (_S1803)) * make_float3 (_S1805);
    float3  _S1807 = t_21 - n_13 * make_float3 (dot_0(n_13, t_21));
    float3  _S1808 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_13);
    bool _S1809 = (dot_0(_S1807, _S1807)) > 0.0f;
    float3  _S1810 = _slang_select(_S1809, _S1807,_S1808);
    float3  _S1811 = ((((_S1810)) * make_float3(rnorm3df(((_S1810)).x, ((_S1810)).y, ((_S1810)).z))));
    bool _S1812 = (dot_0(cross_0(n_13, _S1811), _S1806)) > 0.0f;
    float3  t_22;
    if(_S1812)
    {
        float3  _S1813 = negate_0(_S1811);
        t_22 = _S1813;
    }
    else
    {
        t_22 = _S1811;
    }
    float3  _S1814 = cross_0(n_13, t_22);
    return makeMatrix<float, 3, 3> (t_22, _S1814, n_13);
}

__device__ float3  tangentToWorldNormalMap(float3  v_5, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_5, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_4, float3  uvw_0, float3  position_1)
{
    float3  _S1815 = t1_0 - t0_0;
    float3  _S1816 = t2_2 - t0_0;
    float3  _S1817 = t2_2 - t1_0;
    float _S1818 = (F32_min((length_0(_S1815)), ((F32_min((length_0(_S1816)), (length_0(_S1817)))))));
    float3  _S1819 = make_float3 (distance_1(position_1, t0_0), distance_1(position_1, t1_0), distance_1(position_1, t2_2));
    float3  _S1820 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1821 = dot_0(geometry_n_4, _S1820);
    float3  _S1822 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1823 = dot_0(geometry_n_4, _S1822);
    float3  _S1824 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1825 = acos_0(abs_0(make_float3 (_S1821, _S1823, dot_0(geometry_n_4, _S1824))));
    float3  _S1826 = clamp_2(tan_0(_S1825), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S1819 * _S1826, uvw_0), 0.0f, _S1818 * 0.125f);
}

__device__ float3  straightThrough(BSDFMaterial material_23)
{
    return make_float3 (material_23.transmission * (1.0f - material_23.metallic)) * material_23.albedo;
}

__device__ float hairRow(float3  in_dir_11, float3  t_23, float3  out_dir_3, uint p_13, float w_2, float alpha_20, uint nt_0)
{
    uint _S1827 = p_13 % 4U;
    float _S1828 = w_2 * HAIR_WIDTHS_0[_S1827];
    float _S1829 = (F32_asin((clamp_1(dot_0(out_dir_3, t_23), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_11, t_23), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1827] * alpha_20;
    return ((F32_asinh((_S1829 / _S1828))) / (F32_asinh((3.14159274101257324f / _S1828))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_12, float3  t_24, float3  out_dir_4, uint np_0)
{
    float3  _S1830 = worldToTangent(out_dir_4, t_24);
    float3  _S1831 = worldToTangent(in_dir_12, t_24);
    return (F32_frac((((F32_atan2((_S1830.z), (_S1830.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1831.z), (1.17549435082228751e-38f - _S1831.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_13, float3  t_25, uint p_14, float row_0, float column_0, float w_3, float alpha_21, uint nt_1, uint np_1)
{
    float3  _S1832 = worldToTangent(in_dir_13, t_25);
    uint _S1833 = p_14 % 4U;
    float _S1834 = w_3 * HAIR_WIDTHS_0[_S1833];
    float _S1835 = (F32_asin((clamp_1(dot_0(in_dir_13, t_25), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1833] * alpha_21 + _S1834 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1834))))));
    float _S1836 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1832.z), (1.17549435082228751e-38f - _S1832.x)));
    float _S1837 = (F32_cos((_S1835)));
    float3  _S1838 = tangentToWorld(make_float3 (_S1837 * (F32_cos((_S1836))), (F32_sin((_S1835))), _S1837 * (F32_sin((_S1836)))), t_25);
    return _S1838;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_14, BSDFMaterial material_24, float coverage_1)
{
    float3  _S1839;
    if((material_24.ior) == 1.0f)
    {
        float3  _S1840 = straightThrough(material_24);
        _S1839 = _S1840;
    }
    else
    {
        _S1839 = make_float3 (0.0f);
    }
    return _S1839 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_8, Reservoir r_9, bool replay_2, float scale_4, Selection * sel_8)
{
    Domain _S1841 = dom_8;
    Reservoir _S1842 = r_9;
    Shift _S1843 = walk_0(&_S1841, &_S1842, replay_2, scale_4, sel_8);
    return _S1843;
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
