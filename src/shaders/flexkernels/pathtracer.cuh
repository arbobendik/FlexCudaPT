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

static __device__ int2  storedNeighbor_0(int2  p_4)
{
    int2  _S73 = (fcptLoadTemporalNeighbor((p_4)));
    return _S73;
}

static __device__ FKHit Hit_x24init_0(float2  uv_0, uint instance_index_0, uint triangle_index_0, uint is_point_light_0, float distance_0)
{
    FKHit _S74;
    (&_S74)->uv = uv_0;
    (&_S74)->instance_index = instance_index_0;
    (&_S74)->triangle_index = triangle_index_0;
    (&_S74)->is_point_light = is_point_light_0;
    (&_S74)->distance = distance_0;
    return _S74;
}

static __device__ Domain Domain_x24init_0(float3  x0_0, float3  x1_0, FKHit * hit_0, float width_0, float spread_0)
{
    Domain _S75;
    (&_S75)->x0 = x0_0;
    (&_S75)->x1 = x1_0;
    (&_S75)->hit = *hit_0;
    (&_S75)->width = width_0;
    (&_S75)->spread = spread_0;
    return _S75;
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
    bool _S76 = all_1((a_0->x0) == (b_0->x0));
    bool _S77;
    if(_S76)
    {
        _S77 = ((&a_0->hit)->instance_index) == ((&b_0->hit)->instance_index);
    }
    else
    {
        _S77 = false;
    }
    if(_S77)
    {
        _S77 = ((&a_0->hit)->triangle_index) == ((&b_0->hit)->triangle_index);
    }
    else
    {
        _S77 = false;
    }
    if(_S77)
    {
        _S77 = all_0(((&a_0->hit)->uv) == ((&b_0->hit)->uv));
    }
    else
    {
        _S77 = false;
    }
    return _S77;
}

static __device__ bool temporalJob_0(int2  p_5, int2  q_1, uint t_6, ShiftJob * job_2, bool target_1)
{
    bool _S78 = t_6 > 1U;
    bool _S79;
    if(_S78)
    {
        _S79 = true;
    }
    else
    {
        uint2  _S80 = (fcptRenderSize());
        int2  _S81 = make_int2 ((int)_S80.x, (int)_S80.y);
        _S79 = any_0(p_5 >= _S81);
    }
    if(_S79)
    {
        _S79 = true;
    }
    else
    {
        bool _S82 = (fcptSceneUnchanged());
        _S79 = _S82;
    }
    if(_S79)
    {
        _S79 = true;
    }
    else
    {
        _S79 = (q_1.x) < int(0);
    }
    if(_S79)
    {
        return false;
    }
    bool _S83 = t_6 == 0U;
    if(_S83)
    {
        Reservoir _S84 = (fcptLoadReservoirPrevious((q_1)));
        job_2->r = _S84;
        bool _S85 = ((&job_2->r)->w) > 0.0f;
        if(_S85)
        {
            bool _S86 = !target_1;
            if(_S86)
            {
                _S79 = true;
            }
            else
            {
                bool _S87 = (fcptStoredDomainInitial((p_5), ((&job_2->r)->seed), (&job_2->dom)));
                _S79 = _S87;
            }
        }
        else
        {
            _S79 = false;
        }
        return _S79;
    }
    Reservoir _S88 = (fcptLoadReservoirInitial((p_5)));
    job_2->r = _S88;
    bool _S89 = !target_1;
    if(_S89)
    {
        bool _S90 = (fcptPreviousScenes());
        _S79 = _S90;
    }
    else
    {
        _S79 = false;
    }
    if(_S79)
    {
        return ((&job_2->r)->w) > 0.0f;
    }
    Domain _S91 = (fcptPreviousDomain((q_1), ((&job_2->r)->seed)));
    job_2->dom = _S91;
    float3  _S92 = make_float3 (0.0f);
    FKHit _S93 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S94 = Domain_x24init_0(_S92, _S92, &_S93, 0.0f, 0.0f);
    Domain own_0 = _S94;
    bool _S95 = ((&job_2->r)->w) > 0.0f;
    if(_S95)
    {
        bool _S96 = (fcptPreviousScenes());
        if(_S96)
        {
            _S79 = true;
        }
        else
        {
            bool _S97 = (fcptStoredDomainInitial((p_5), ((&job_2->r)->seed), (&own_0)));
            if(_S97)
            {
                Domain _S98 = job_2->dom;
                Domain _S99 = own_0;
                bool _S100 = sameDomain_0(&_S98, &_S99);
                _S79 = _S100;
            }
            else
            {
                _S79 = false;
            }
            _S79 = !_S79;
        }
    }
    else
    {
        _S79 = false;
    }
    return _S79;
}

static __device__ void temporalBins_0(int2  p_6, FixedArray<uint, 3>  * _S101)
{
    FixedArray<uint, 3>  _S102 = { {
        40U, 40U, 40U
    } };
    FixedArray<uint, 3>  bins_2;
    bins_2[int(0)] = 40U;
    bins_2[int(1)] = 40U;
    bins_2[int(2)] = 40U;
    int2  _S103 = storedNeighbor_0(p_6);
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
        ShiftJob _S104 = (ShiftJob{});
        ShiftJob job_3 = _S104;
        bool _S105 = temporalJob_0(p_6, _S103, t_7, &job_3, false);
        if(_S105)
        {
            Reservoir _S106 = (&job_3)->r;
            uint _S107 = shiftBin_0(&_S106);
            bins_2[t_7] = _S107;
        }
        uint t_8 = t_7 + 1U;
        t_7 = t_8;
    }
    *_S101 = bins_2;
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
        uint _S108 = (*bins_3)[t_9];
        bool _S109 = ((*bins_3)[t_9]) < 40U;
        if(_S109)
        {
            uint _S110 = (fcptQueueCountAdd((_S108), (1U)));
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
    Shift _S111;
    (&_S111)->f = f_0;
    (&_S111)->jac = jac_0;
    return _S111;
}

static __device__ Shift passWalk_0(Domain * dom_0, Reservoir * r_1, bool replay_0, float scale_0, Selection * sel_0)
{
    Shift _S112 = (fcptWalk((*dom_0), (*r_1), (replay_0), (scale_0), (sel_0)));
    return _S112;
}

static __device__ Shift passShift_0(Domain * dom_1, Reservoir * r_2)
{
    Selection _S113 = (Selection{});
    Selection sel_1 = _S113;
    bool _S114 = (r_2->w) <= 0.0f;
    if(_S114)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S115 = passWalk_0(dom_1, r_2, true, 0.0f, &sel_1);
    return _S115;
}

static __device__ float2  pixelOf_0(float3  position_0, bool previous_0)
{
    float2  _S116 = (fcptPixelOf((position_0), (previous_0)));
    return _S116;
}

static __device__ bool previousValid_0(int2  q_2)
{
    bool _S117 = all_0(q_2 >= make_int2 (int(0)));
    bool _S118;
    if(_S117)
    {
        uint2  _S119 = (fcptRenderSize());
        int2  _S120 = make_int2 ((int)_S119.x, (int)_S119.y);
        _S118 = all_0(q_2 < _S120);
    }
    else
    {
        _S118 = false;
    }
    if(_S118)
    {
        uint4  _S121 = (fcptReservoirPrevious((q_2), (0U)));
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

static __device__ int2  temporalNeighbor_0(int2  p_7, Domain * dom_2, uint seed_1)
{
    bool _S122 = previousValid_0(p_7);
    bool _S123;
    if(_S122)
    {
        Domain _S124 = (fcptPreviousDomain((p_7), (seed_1)));
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
        return p_7;
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
    int2  _S141 = p_7 + _S132;
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

static __device__ Shift temporalShiftAt_0(int2  p_8, int2  q_3, uint t_11)
{
    ShiftJob _S150 = (ShiftJob{});
    ShiftJob job_4 = _S150;
    bool _S151 = temporalJob_0(p_8, q_3, t_11, &job_4, true);
    bool _S152 = !_S151;
    if(_S152)
    {
        return Shift_x24init_0(make_float3 (0.0f), 0.0f);
    }
    Shift _S153;
    if(t_11 == 1U)
    {
        Shift _S154 = (fcptShiftPrevious(((&job_4)->dom), ((&job_4)->r)));
        _S153 = _S154;
    }
    else
    {
        Domain _S155 = (&job_4)->dom;
        Reservoir _S156 = (&job_4)->r;
        Shift _S157 = passShift_0(&_S155, &_S156);
        _S153 = _S157;
    }
    return _S153;
}

static __device__ int2  sampleNeighbor_0(int2  p_9, uint seed_2)
{
    bool _S158 = (fcptSceneUnchanged());
    if(_S158)
    {
        int2  _S159 = make_int2 (int(-1));
        bool _S160 = previousValid_0(p_9);
        int2  _S161 = _slang_select(_S160, p_9,_S159);
        return _S161;
    }
    float3  _S162 = make_float3 (0.0f);
    FKHit _S163 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S164 = Domain_x24init_0(_S162, _S162, &_S163, 0.0f, 0.0f);
    Domain dom_3 = _S164;
    uint2  _S165 = (fcptRenderSize());
    int2  _S166 = make_int2 ((int)_S165.x, (int)_S165.y);
    bool _S167 = any_0(p_9 >= _S166);
    bool _S168;
    if(_S167)
    {
        _S168 = true;
    }
    else
    {
        bool _S169 = (fcptStoredDomainInitial((p_9), (seed_2), (&dom_3)));
        _S168 = !_S169;
    }
    if(_S168)
    {
        return make_int2 (int(-1));
    }
    Domain _S170 = dom_3;
    int2  _S171 = temporalNeighbor_0(p_9, &_S170, seed_2);
    return _S171;
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
    FKRay _S172;
    (&_S172)->origin = origin_0;
    (&_S172)->unit_direction = unit_direction_0;
    return _S172;
}

static __device__ float3  skyRadiance_0(float3  origin_1, FKSurface * surface_0, bool is_inside_1, float3  dir_1, ShadowContext * context_0, uint random_state_0)
{
    bool _S173 = wrongSide_0(is_inside_1, false, dir_1, surface_0->geometry_n);
    bool _S174 = is_inside_1 != _S173;
    float _S175 = surface_0->geometry_offset;
    float3  _S176 = surface_0->smooth_n;
    float3  _S177 = - surface_0->smooth_n;
    float3  _S178 = _slang_select(_S174, _S177,_S176);
    FKRay _S179 = Ray_x24init_0(origin_1 + make_float3 (_S175) * _S178, dir_1);
    bool _S180 = (dot_0(context_0->side, dir_1)) > 0.0f;
    bool _S181 = (fcptWorldReadsPath());
    float3  _S182;
    if(_S181)
    {
        _S182 = make_float3 (1.0f);
    }
    else
    {
        float3  _S183 = (fcptEnvMapSample((dir_1), (0U), (3U)));
        _S182 = _S183;
    }
    float3  _S184 = context_0->extinction_behind;
    float3  _S185 = context_0->extinction_front;
    float3  _S186 = _slang_select(_S180, _S185,_S184);
    uint _S187 = context_0->fillings.x;
    uint _S188 = context_0->fillings.y;
    uint _S189 = _slang_select(_S180, _S188,_S187);
    uint _S190 = context_0->depth;
    uint _S191 = context_0->lobe;
    bool _S192 = context_0->surface;
    bool _S193;
    if(_S192)
    {
        _S193 = !context_0->fiber;
    }
    else
    {
        _S193 = false;
    }
    float _S194 = context_0->length;
    float _S195 = context_0->width;
    FKHit _S196 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    float3  _S197 = (fcptShadowTransmittanceIn((_S179), (4.294967296e+09f), (_S186), (_S189), (random_state_0), (_S190), (_S191), (_S193), (_S194), (_S195), (_S196), (_S196)));
    return _S182 * _S197;
}

static __device__ uint searchCDF_0(uint2  start_4, uint2  step_0, uint count_1, float u_0)
{
    uint _S198 = count_1 - 1U;
    uint low_0 = 0U;
    uint high_0 = _S198;
    for(;;)
    {
        if(low_0 < high_0)
        {
        }
        else
        {
            break;
        }
        uint _S199 = (low_0 + high_0) / 2U;
        float4  _S200 = (fcptEnvironmentCdf((start_4 + step_0 * make_uint2 (_S199))));
        bool _S201 = (_S200.x) > u_0;
        if(_S201)
        {
            high_0 = _S199;
        }
        else
        {
            uint _S202 = _S199 + 1U;
            low_0 = _S202;
        }
    }
    return low_0;
}

static __device__ float3  skyFrame_0(float3  dir_2)
{
    float3  _S203 = make_float3 (- dir_2.x, dir_2.z, dir_2.y);
    bool _S204 = ((true));
    float3  _S205 = _slang_select(_S204, _S203,dir_2);
    return _S205;
}

__device__ float shadowLength(float3  shadow_0)
{
    return length_0(shadow_0) * 0.99989998340606689f;
}

static __device__ float3  lightTransmittance_0(float3  origin_2, float3  smooth_n_0, float geometry_offset_0, float3  light_dir_0, ShadowContext * context_1, uint random_state_1, FKHit * light_0)
{
    float3  _S206 = ((((light_dir_0)) * make_float3(rnorm3df(((light_dir_0)).x, ((light_dir_0)).y, ((light_dir_0)).z))));
    bool _S207 = (dot_0(smooth_n_0, _S206)) < 0.0f;
    if(_S207)
    {
        return make_float3 (0.0f);
    }
    float3  _S208 = make_float3 (geometry_offset_0) * smooth_n_0;
    float3  _S209 = origin_2 + _S208;
    FKRay _S210 = Ray_x24init_0(_S209, _S206);
    bool _S211 = (dot_0(context_1->side, light_dir_0 + _S208)) > 0.0f;
    float _S212 = shadowLength(light_dir_0);
    float3  _S213 = context_1->extinction_behind;
    float3  _S214 = context_1->extinction_front;
    float3  _S215 = _slang_select(_S211, _S214,_S213);
    uint _S216 = context_1->fillings.x;
    uint _S217 = context_1->fillings.y;
    uint _S218 = _slang_select(_S211, _S217,_S216);
    uint _S219 = context_1->depth;
    uint _S220 = context_1->lobe;
    bool _S221 = context_1->surface;
    bool _S222;
    if(_S221)
    {
        _S222 = !context_1->fiber;
    }
    else
    {
        _S222 = false;
    }
    float _S223 = context_1->length;
    float _S224 = context_1->width;
    FKHit _S225;
    if(context_1->fiber)
    {
        _S225 = context_1->own;
    }
    else
    {
        _S225 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    }
    float3  _S226 = (fcptShadowTransmittanceIn((_S210), (_S212), (_S215), (_S218), (random_state_1), (_S219), (_S220), (_S222), (_S223), (_S224), (_S225), (*light_0)));
    return _S226;
}

__device__ float sine(float c_0)
{
    return (F32_sqrt(((F32_max((1.0f - c_0 * c_0), (0.0f))))));
}

__device__ float cosSubClamped(float sin_a_0, float cos_a_0, float sin_b_0, float cos_b_0)
{
    float _S227 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    bool _S228 = cos_a_0 > cos_b_0;
    float _S229 = _slang_select(_S228, 1.0f,_S227);
    return _S229;
}

__device__ float importance(LightNode node_0, float3  p_10, float3  normal_0)
{
    float3  _S230 = (node_0.low + node_0.high) * make_float3 (0.5f);
    float3  _S231 = node_0.high - node_0.low;
    float3  _S232 = p_10 - _S230;
    float3  _S233 = ((((_S232)) * make_float3(rnorm3df(((_S232)).x, ((_S232)).y, ((_S232)).z))));
    float _S234 = dot_0(_S232, _S232);
    float _S235 = dot_0(_S231, _S231) / 4.0f;
    float _S236 = (F32_abs((dot_0(node_0.w, _S233))));
    float _S237 = sine(node_0.cos_theta_o);
    float _S238 = (F32_sqrt(((F32_max((1.0f - _S235 / _S234), (0.0f))))));
    bool _S239 = _S234 < _S235;
    float _S240 = _slang_select(_S239, -1.0f,_S238);
    float _S241 = sine(_S240);
    float _S242 = sine(_S236);
    float _S243 = cosSubClamped(_S242, _S236, _S237, node_0.cos_theta_o);
    float _S244 = sine(_S236);
    float _S245 = _S244 * node_0.cos_theta_o - _S236 * _S237;
    bool _S246 = _S236 > (node_0.cos_theta_o);
    float _S247 = _slang_select(_S246, 0.0f,_S245);
    float _S248 = cosSubClamped(_S247, _S243, _S241, _S240);
    bool _S249 = _S248 <= 0.0f;
    if(_S249)
    {
        return 0.0f;
    }
    float _S250 = - dot_0(_S233, normal_0);
    float _S251 = node_0.phi * _S248 / (F32_max((_S234), (length_0(_S231) / 2.0f)));
    float _S252 = sine(_S250);
    float _S253 = cosSubClamped(_S252, _S250, _S241, _S240);
    bool _S254 = (dot_0(normal_0, normal_0)) == 0.0f;
    float _S255 = _slang_select(_S254, 1.0f,_S253);
    return (F32_max((_S251 * _S255), (0.0f)));
}

__device__ __forceinline__ float childShare(LightNode first_0, LightNode second_0, float3  p_11, float3  normal_1, uint child_0)
{
    float _S256 = importance(first_0, p_11, normal_1);
    float _S257 = importance(second_0, p_11, normal_1);
    float2  _S258 = make_float2 (_S256, _S257);
    float _S259 = _slang_vector_get_element(_S258, child_0) / (_S256 + _S257);
    bool _S260 = _slang_vector_get_element(_S258, child_0) > 0.0f;
    float _S261 = _slang_select(_S260, _S259,0.0f);
    return _S261;
}

__device__ float sphereDensity(float3  center_0, float radius_0, float3  p_12)
{
    float3  _S262 = center_0 - p_12;
    float _S263 = radius_0 * radius_0 / dot_0(_S262, _S262);
    bool _S264 = _S263 >= 1.0f;
    if(_S264)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + (F32_sqrt((1.0f - _S263)))) / (6.28318548202514648f * _S263);
}

static __device__ float3  cross_0(float3  left_0, float3  right_0)
{
    float _S265 = left_0.y;
    float _S266 = right_0.z;
    float _S267 = left_0.z;
    float _S268 = right_0.y;
    float _S269 = right_0.x;
    float _S270 = left_0.x;
    return make_float3 (_S265 * _S266 - _S267 * _S268, _S267 * _S269 - _S270 * _S266, _S270 * _S268 - _S265 * _S269);
}

__device__ float solidAngle(float probability_0, float3  normal_2, float3  toward_0)
{
    return 2.0f * probability_0 * (F32_pow((length_0(toward_0)), (3.0f))) / (F32_abs((dot_0(normal_2, toward_0))));
}

static __device__ float lightPdf_0(float3  origin_3, float3  smooth_n_1, float3  start_5, uint j_0, float3  light_point_0)
{
    bool _S271 = j_0 == 4294967295U;
    if(_S271)
    {
        return 0.0f;
    }
    uint4  _S272 = (fcptLightTrail((j_0)));
    uint2  _S273 = uint2 {_S272.x, _S272.y};
    uint n_0 = 0U;
    uint2  trail_0 = _S273;
    float probability_1 = 1.0f;
    for(;;)
    {
        uint4  _S274 = (fcptLightNode((n_0)));
        if((_S274.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S275 = (fcptLightSecond((n_0)));
        uint _S276 = n_0 + 1U;
        LightNode _S277 = (fcptLightBounds((_S276)));
        LightNode _S278 = (fcptLightBounds((_S275)));
        uint _S279 = trail_0.x;
        uint _S280 = _S279 & 1U;
        float _S281 = childShare(_S277, _S278, origin_3, smooth_n_1, _S280);
        float probability_2 = probability_1 * _S281;
        bool _S282 = _S280 == 1U;
        uint _S283 = _slang_select(_S282, _S275,_S276);
        uint _S284 = trail_0.y;
        uint2  _S285 = make_uint2 ((_S279 >> 1U) | (_S284 << 31U), _S284 >> 1U);
        n_0 = _S283;
        trail_0 = _S285;
        probability_1 = probability_2;
    }
    bool _S286 = (fcptSlotLeaf((n_0), (j_0)));
    bool _S287 = !_S286;
    bool _S288;
    if(_S287)
    {
        _S288 = true;
    }
    else
    {
        LightNode _S289 = (fcptLightBounds((n_0)));
        float _S290 = importance(_S289, origin_3, smooth_n_1);
        _S288 = !(_S290 > 0.0f);
    }
    if(_S288)
    {
        _S288 = true;
    }
    else
    {
        bool _S291 = (dot_0(smooth_n_1, smooth_n_1)) > 0.0f;
        if(_S291)
        {
            _S288 = !((dot_0(smooth_n_1, light_point_0 - origin_3)) > 0.0f);
        }
        else
        {
            _S288 = false;
        }
    }
    if(_S288)
    {
        return 0.0f;
    }
    uint4  _S292 = (fcptLightNode((n_0)));
    bool _S293 = (_S292.x) == 2U;
    if(_S293)
    {
        FKLight _S294 = (fcptLight((_S292.y)));
        float _S295 = sphereDensity(_S294.position, _S294.variance, start_5);
        return probability_1 * _S295;
    }
    uint _S296 = _S292.y;
    uint _S297 = (fcptTriangleOffset((_S296)));
    Matrix<float, 3, 3>  _S298 = (fcptWorldTriangle((_S296), (_S297 + _S292.z)));
    float _S299 = solidAngle(probability_1, cross_0(_S298.rows[int(1)] - _S298.rows[int(0)], _S298.rows[int(2)] - _S298.rows[int(0)]), light_point_0 - start_5);
    return _S299;
}

static __device__ float3  environment_0(float3  dir_3, uint depth_0, uint lobe_0)
{
    uint2  _S300 = (fcptEnvironmentMapSize());
    bool _S301 = all_0(_S300 > make_uint2 (1U));
    if(_S301)
    {
        float3  _S302 = (fcptEnvMapSample((dir_3), (depth_0), (lobe_0)));
        return _S302;
    }
    float3  _S303 = (fcptAmbient());
    return _S303;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S304 = (fcptEnvironmentCdfSize());
    bool _S305 = !all_0(_S304 > make_uint2 (1U));
    if(_S305)
    {
        return false;
    }
    uint2  _S306 = (fcptEnvironmentMapSize());
    return all_0(_S306 > make_uint2 (1U));
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

static __device__ float environmentPdf_0(float3  dir_4)
{
    uint2  _S307 = (fcptEnvironmentCdfSize());
    uint2  _S308 = _S307 - make_uint2 (1U, 0U);
    float3  _S309 = skyFrame_0(dir_4);
    float2  _S310 = make_float2 ((F32_atan2((- _S309.z), (- _S309.x))) / 6.28318548202514648f + 0.5f, (F32_acos((clamp_1(_S309.y, -1.0f, 1.0f)))) / 3.14159274101257324f);
    float2  _S311 = make_float2 ((float)_S308.x, (float)_S308.y);
    float2  _S312 = _S310 * _S311;
    uint2  _S313 = make_uint2 ((uint)_S312.x, (uint)_S312.y);
    uint2  _S314 = min_0(_S313, _S308 - make_uint2 (1U));
    float4  _S315 = (fcptEnvironmentCdf((_S314)));
    float _S316 = _S315.y;
    uint _S317 = _S308.x;
    float4  _S318 = (fcptEnvironmentCdf((make_uint2 (_S317, _S314.y))));
    float _S319 = _S316 * _S318.y;
    return _S319 * float(_S317 * _S308.y) / (19.73921012878417969f * length_1(float2 {_S309.x, _S309.z}));
}

static __device__ float escapeWeight_0(float pdf_0, float3  dir_5)
{
    bool _S320 = pdf_0 <= 0.0f;
    bool _S321;
    if(_S320)
    {
        _S321 = true;
    }
    else
    {
        bool _S322 = environmentMapped_0();
        _S321 = !_S322;
    }
    if(_S321)
    {
        return 1.0f;
    }
    float _S323 = environmentPdf_0(dir_5);
    return pdf_0 / (pdf_0 + _S323);
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
    Random _S324;
    (&_S324)->state = state_0;
    (&_S324)->value = value_0;
    return _S324;
}

__device__ Random pcg(uint state_1)
{
    uint _S325 = hash(state_1);
    float value_1 = float(_S325 >> int(8)) * 5.9604644775390625e-08f;
    return Random_x24init_0(_S325, value_1);
}

__device__ static const FixedArray<float, 243>  SPECTRAL_PRIMARIES_0 = { {
    0.028201999142766f, 9.99999997475242708e-07f, 0.97179698944091797f, 0.02820000052452087f, 0.0f, 0.97180002927780151f, 0.02819300070405006f, 0.0f, 0.97180700302124023f, 0.0281750001013279f, 0.0f, 0.9718250036239624f, 0.02813299931585789f, 0.0f, 0.97186702489852905f, 0.02804199978709221f, 0.0f, 0.9719579815864563f, 0.02786399982869625f, 0.0f, 0.97213602066040039f, 0.0275299996137619f, 0.0f, 0.9724699854850769f, 0.02692800015211105f, 0.0f, 0.97307199239730835f, 0.02592499926686287f, 0.0f, 0.97407501935958862f, 0.02444599941372871f, 0.0f, 0.97555398941040039f, 0.02258899994194508f, 0.0f, 0.97741097211837769f, 0.02068600058555603f, 0.0f, 0.97931402921676636f, 0.01939599961042404f, 0.0f, 0.98060399293899536f, 0.01972600072622299f, 0.0f, 0.9802740216255188f, 0.02305700071156025f, 0.0f, 0.97694301605224609f, 0.0282990001142025f, 0.00548999989405274f, 0.96621102094650269f, 0.02276800014078617f, 0.04560500010848045f, 0.93162697553634644f, 0.0118180001154542f, 0.11352799832820892f, 0.87465399503707886f, 0.00192399998195469f, 0.20037899911403656f, 0.79769700765609741f, 0.0f, 0.29692500829696655f, 0.70307499170303345f, 0.0f, 0.40064999461174011f, 0.5993499755859375f, 0.0f, 0.50742298364639282f, 0.49257698655128479f, 0.0f, 0.61289197206497192f, 0.38710799813270569f, 0.0f, 0.71311402320861816f, 0.28688600659370422f, 0.0f, 0.8042140007019043f, 0.1957859992980957f, 0.0f, 0.88220900297164917f, 0.11779099702835083f, 0.0f, 0.94313102960586548f, 0.05686900019645691f, 0.0f, 0.98336499929428101f, 0.01663500070571899f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.99855601787567139f, 0.00144400005228817f, 0.0f, 0.97892600297927856f, 0.02107400074601173f, 0.03028500080108643f, 0.92923498153686523f, 0.04047999903559685f, 0.10447199642658234f, 0.84615302085876465f, 0.04937500134110451f, 0.21104000508785248f, 0.73897498846054077f, 0.04998499900102615f, 0.33820000290870667f, 0.61719298362731934f, 0.04460699856281281f, 0.47420701384544373f, 0.49019300937652588f, 0.03559999912977219f, 0.60847699642181396f, 0.3664110004901886f, 0.02511199936270714f, 0.73185497522354126f, 0.25317299365997314f, 0.01497200038284063f, 0.83687901496887207f, 0.15642799437046051f, 0.00669299997389317f, 0.91802400350570679f, 0.08053100109100342f, 0.00144499994348735f, 0.97194302082061768f, 0.02805699966847897f, 0.0f, 0.99879997968673706f, 0.00120000005699694f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.99999898672103882f, 0.0f, 9.99999997475242708e-07f, 0.99999898672103882f, 0.0f, 9.99999997475242708e-07f, 0.99999898672103882f, 0.0f, 9.99999997475242708e-07f, 0.99999797344207764f, 9.99999997475242708e-07f, 9.99999997475242708e-07f, 0.99999797344207764f, 9.99999997475242708e-07f, 9.99999997475242708e-07f, 0.99999701976776123f, 9.99999997475242708e-07f, 1.99999999495048542e-06f, 0.99999499320983887f, 1.99999999495048542e-06f, 3.00000010611256585e-06f, 0.99999302625656128f, 1.99999999495048542e-06f, 4.99999987368937582e-06f, 0.99998897314071655f, 3.99999998990097083e-06f, 7.00000009601353668e-06f, 0.9999840259552002f, 6.00000021222513169e-06f, 0.00000999999974738f, 0.99997901916503906f, 0.0000079999999798f, 0.00001299999985349f, 0.99997401237487793f, 0.00000999999974738f, 0.0000159999999596f, 0.99997299909591675f, 0.00001200000042445f, 0.00001499999962107f, 0.99996697902679443f, 0.00001499999962107f, 0.00001800000063668f, 0.9999690055847168f, 0.00001499999962107f, 0.0000159999999596f, 0.9999619722366333f, 0.00001700000029814f, 0.00002099999983329f
} };
__device__ float upsample(float3  rgb_0, float wavelength_0)
{
    float _S326 = clamp_1((wavelength_0 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    uint _S327 = (U32_min((uint(_S326)), (79U)));
    uint _S328 = 3U * _S327;
    float3  _S329 = make_float3 (SPECTRAL_PRIMARIES_0[_S328], SPECTRAL_PRIMARIES_0[_S328 + 1U], SPECTRAL_PRIMARIES_0[_S328 + 2U]);
    float3  _S330 = make_float3 (SPECTRAL_PRIMARIES_0[_S328 + 3U], SPECTRAL_PRIMARIES_0[_S328 + 4U], SPECTRAL_PRIMARIES_0[_S328 + 5U]);
    return dot_0(rgb_0, _S329 + (_S330 - _S329) * make_float3 (_S326 - float(_S327)));
}

__device__ BSDFMaterial atWavelength(BSDFMaterial material_0, float wavelength_1)
{
    BSDFMaterial at_0 = material_0;
    float _S331 = upsample(material_0.albedo, wavelength_1);
    float3  _S332 = make_float3 (_S331);
    (&at_0)->albedo = _S332;
    float _S333 = upsample(material_0.emissive, wavelength_1);
    float3  _S334 = make_float3 (_S333);
    (&at_0)->emissive = _S334;
    float _S335 = upsample(material_0.absorption, wavelength_1);
    float3  _S336 = make_float3 (_S335);
    (&at_0)->absorption = _S336;
    float _S337 = upsample(material_0.specular_tint, wavelength_1);
    float3  _S338 = make_float3 (_S337);
    (&at_0)->specular_tint = _S338;
    float _S339 = upsample(material_0.translucent, wavelength_1);
    float3  _S340 = make_float3 (_S339);
    (&at_0)->translucent = _S340;
    float _S341 = upsample(material_0.sheen, wavelength_1);
    float3  _S342 = make_float3 (_S341);
    (&at_0)->sheen = _S342;
    return at_0;
}

__device__ BSDFMaterial pathMaterial(BSDFMaterial material_1, float wavelength_2)
{
    BSDFMaterial _S343;
    if(wavelength_2 > 0.0f)
    {
        BSDFMaterial _S344 = atWavelength(material_1, wavelength_2);
        _S343 = _S344;
    }
    else
    {
        _S343 = material_1;
    }
    return _S343;
}

static __device__ float3  negate_0(float3  x_13)
{
    return - x_13;
}

static __device__ float sign_0(float e_1)
{
    bool _S345 = e_1 < 0.0f;
    float _S346 = _slang_select(_S345, -1.0f,0.0f);
    bool _S347 = e_1 > 0.0f;
    float _S348 = _slang_select(_S347, 1.0f,_S346);
    return _S348;
}

struct AnisotropicFrame
{
    float3  tangent;
    float2  alphas;
};

static __device__ AnisotropicFrame AnisotropicFrame_x24init_0(float3  tangent_0, float2  alphas_0)
{
    AnisotropicFrame _S349;
    (&_S349)->tangent = tangent_0;
    (&_S349)->alphas = alphas_0;
    return _S349;
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_1)
{
    float3  a_1 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S350 = (F32_abs((dot_0(n_1, a_1)))) > 0.9999847412109375f;
    float3  a_2;
    if(_S350)
    {
        float3  _S351 = make_float3 (1.0f, 0.0f, 0.0f);
        a_2 = _S351;
    }
    else
    {
        a_2 = a_1;
    }
    float3  _S352 = cross_0(n_1, a_2);
    float3  _S353 = ((((_S352)) * make_float3(rnorm3df(((_S352)).x, ((_S352)).y, ((_S352)).z))));
    float3  _S354 = cross_0(n_1, _S353);
    return make_float3 (v_0.x) * _S353 + make_float3 (v_0.y) * n_1 + make_float3 (v_0.z) * _S354;
}

__device__ AnisotropicFrame anisotropicFrame(BSDFMaterial material_2, float3  n_i_0)
{
    float _S355 = material_2.roughness;
    float _S356 = _S355 * _S355;
    bool _S357 = (material_2.anisotropy) == 0.0f;
    bool _S358;
    if(_S357)
    {
        _S358 = true;
    }
    else
    {
        _S358 = !(_S356 > 0.0f);
    }
    if(_S358)
    {
        return AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f));
    }
    float3  _S359 = material_2.tangent - n_i_0 * make_float3 (dot_0(n_i_0, material_2.tangent));
    float3  _S360 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_i_0);
    bool _S361 = (dot_0(_S359, _S359)) > 0.0f;
    float3  _S362 = _slang_select(_S361, _S359,_S360);
    float3  _S363 = ((((_S362)) * make_float3(rnorm3df(((_S362)).x, ((_S362)).y, ((_S362)).z))));
    float _S364 = 6.28318548202514648f * material_2.anisotropic_rotation;
    float _S365 = (F32_sqrt((1.0f - 0.89999997615814209f * (F32_abs((material_2.anisotropy))))));
    float _S366 = 1.0f / _S365;
    bool _S367 = (material_2.anisotropy) < 0.0f;
    float _S368 = _slang_select(_S367, _S366,_S365);
    return AnisotropicFrame_x24init_0(_S363 * make_float3 ((F32_cos((_S364)))) + cross_0(n_i_0, _S363) * make_float3 ((F32_sin((_S364)))), make_float2 (_S356 / _S368, _S356 * _S368));
}

struct SheenProfile
{
    bool on;
    float albedo;
};

static __device__ SheenProfile SheenProfile_x24init_0(bool on_0, float albedo_0)
{
    SheenProfile _S369;
    (&_S369)->on = on_0;
    (&_S369)->albedo = albedo_0;
    return _S369;
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
    SheenProfile _S370 = SheenProfile_x24init_0(false, 0.0f);
    float _S371 = rgb_to_greyscale(material_3.sheen);
    bool _S372 = _S371 > 0.0f;
    SheenProfile profile_0;
    if(_S372)
    {
        float _S373 = clamp_1((F32_sqrt(((F32_max((dot_0(n_i_1, v_1)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S374 = (U32_min((uint(_S373)), (22U)));
        float _S375 = (F32_sqrt((0.05000000074505806f)));
        float _S376 = (F32_sqrt((0.00999999977648258f)));
        bool _S377 = (material_3.velvet) > 0.0f;
        float _S378 = _slang_select(_S377, _S376,_S375);
        float _S379 = (clamp_1((F32_sqrt(((F32_max((material_3.sheen_roughness), (0.0f)))))), _S378, 1.0f) - _S378) / (1.0f - _S378) * 23.0f;
        uint _S380 = (U32_min((uint(_S379)), (22U)));
        uint _S381 = _S374 * 24U + _S380;
        float _S382 = _S373 - float(_S374);
        float _S383 = _S379 - float(_S380);
        if(_S377)
        {
            uint _S384 = _S381 + 24U;
            float _S385 = VELVET_ALBEDO_0[_S381] + (VELVET_ALBEDO_0[_S384] - VELVET_ALBEDO_0[_S381]) * _S382;
            uint _S386 = _S381 + 1U;
            float _S387 = VELVET_ALBEDO_0[_S386] + (VELVET_ALBEDO_0[_S384 + 1U] - VELVET_ALBEDO_0[_S386]) * _S382;
            SheenProfile _S388 = SheenProfile_x24init_0(true, _S385 + (_S387 - _S385) * _S383);
            profile_0 = _S388;
        }
        else
        {
            uint _S389 = _S381 + 24U;
            float _S390 = SHEEN_ALBEDO_0[_S381] + (SHEEN_ALBEDO_0[_S389] - SHEEN_ALBEDO_0[_S381]) * _S382;
            uint _S391 = _S381 + 1U;
            float _S392 = SHEEN_ALBEDO_0[_S391] + (SHEEN_ALBEDO_0[_S389 + 1U] - SHEEN_ALBEDO_0[_S391]) * _S382;
            SheenProfile _S393 = SheenProfile_x24init_0(true, (F32_exp((_S390 + (_S392 - _S390) * _S383))));
            profile_0 = _S393;
        }
    }
    else
    {
        profile_0 = _S370;
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
    Weights _S394;
    (&_S394)->v_dot_h = v_dot_h_0;
    (&_S394)->refracted = refracted_1;
    (&_S394)->F = F_0;
    (&_S394)->reflect_weight = reflect_weight_0;
    (&_S394)->diffuse_weight = diffuse_weight_0;
    (&_S394)->refract_weight = refract_weight_0;
    (&_S394)->p_diffuse = p_diffuse_0;
    (&_S394)->p_reflect = p_reflect_0;
    (&_S394)->p_refract = p_refract_0;
    (&_S394)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S394)->p_toon = p_toon_0;
    (&_S394)->sheen = sheen_0;
    (&_S394)->toon = toon_0;
    return _S394;
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
    float3  _S395 = make_float3 (alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z);
    float3  _S396 = ((((_S395)) * make_float3(rnorm3df(((_S395)).x, ((_S395)).y, ((_S395)).z))));
    float _S397 = _S396.x;
    float _S398 = _S396.y;
    float _S399 = _S397 * _S397 + _S398 * _S398;
    float3  _S400 = make_float3 (1.0f, 0.0f, 0.0f);
    float3  _S401 = make_float3 (- _S398, _S397, 0.0f);
    float _S402 = (rsqrtf((_S399)));
    float3  _S403 = _S401 * make_float3 (_S402);
    bool _S404 = _S399 > 0.0f;
    float3  _S405 = _slang_select(_S404, _S403,_S400);
    float3  _S406 = cross_0(_S396, _S405);
    float _S407 = (F32_sqrt((U1_0)));
    float _S408 = 6.28318548202514648f * U2_0;
    float _S409 = _S407 * (F32_cos((_S408)));
    float t2_0 = _S407 * (F32_sin((_S408)));
    float _S410 = 0.5f * (1.0f + _S396.z);
    float t2_1 = (1.0f - _S410) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S409 * _S409)))))) + _S410 * t2_0;
    float3  _S411 = make_float3 (_S409) * _S405 + make_float3 (t2_1) * _S406;
    float _S412 = unshared_0(_S409);
    float _S413 = unshared_0(_S409);
    float3  _S414 = _S411 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S412 * _S413 - t2_1 * t2_1))))))) * _S396;
    float3  _S415 = make_float3 (alpha_0 * _S414.x, alpha_0 * _S414.y, (F32_max((0.0f), (_S414.z))));
    float3  _S416 = ((((_S415)) * make_float3(rnorm3df(((_S415)).x, ((_S415)).y, ((_S415)).z))));
    return _S416;
}

__device__ float3  worldToTangent(float3  v_2, float3  n_3)
{
    float3  a_3 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S417 = (F32_abs((dot_0(n_3, a_3)))) > 0.9999847412109375f;
    float3  a_4;
    if(_S417)
    {
        float3  _S418 = make_float3 (1.0f, 0.0f, 0.0f);
        a_4 = _S418;
    }
    else
    {
        a_4 = a_3;
    }
    float3  _S419 = cross_0(n_3, a_4);
    float3  _S420 = ((((_S419)) * make_float3(rnorm3df(((_S419)).x, ((_S419)).y, ((_S419)).z))));
    float3  _S421 = cross_0(n_3, _S420);
    return make_float3 (dot_0(v_2, _S420), dot_0(v_2, n_3), dot_0(v_2, _S421));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_3, float3  n_i_2, float alpha_1, AnisotropicFrame frame_0, uint * random_state_2)
{
    Random _S422 = pcg(*random_state_2);
    Random _S423 = pcg(_S422.state);
    *random_state_2 = _S423.state;
    float _S424 = frame_0.alphas.x;
    bool _S425 = _S424 > 0.0f;
    if(_S425)
    {
        float3  _S426 = anisotropicLocal(v_3, frame_0.tangent, n_i_2);
        float _S427 = frame_0.alphas.y;
        float3  _S428 = make_float3 (_S424 * _S426.x, _S427 * _S426.y, _S426.z);
        float3  _S429 = ((((_S428)) * make_float3(rnorm3df(((_S428)).x, ((_S428)).y, ((_S428)).z))));
        float3  _S430 = sampleGGXVNDF(_S429, 1.0f, _S422.value, _S423.value);
        float3  _S431 = make_float3 (_S424 * _S430.x, _S427 * _S430.y, _S430.z);
        float3  _S432 = ((((_S431)) * make_float3(rnorm3df(((_S431)).x, ((_S431)).y, ((_S431)).z))));
        return make_float3 (_S432.x) * frame_0.tangent + make_float3 (_S432.y) * cross_0(n_i_2, frame_0.tangent) + make_float3 (_S432.z) * n_i_2;
    }
    float3  _S433 = worldToTangent(v_3, n_i_2);
    float3  _S434 = sampleGGXVNDF(float3 {_S433.x, _S433.z, _S433.y}, alpha_1, _S422.value, _S423.value);
    float3  _S435 = float3 {_S434.x, _S434.z, _S434.y};
    float3  _S436 = tangentToWorld(_S435, n_i_2);
    return _S436;
}

__device__ __forceinline__ float3  sampledHalf(float3  v_4, float3  n_i_3, float alpha_2, AnisotropicFrame frame_1, uint random_state_3)
{
    uint state_2 = random_state_3;
    float3  _S437 = sampleHalfVector(v_4, n_i_3, alpha_2, frame_1, &state_2);
    return _S437;
}

__device__ __forceinline__ float3  refractedHalf(float3  in_dir_0, float3  out_dir_0, float3  n_4, float eta_i_0, float eta_o_0)
{
    float3  _S438 = negate_0(in_dir_0);
    float3  _S439 = negate_0(make_float3 (eta_i_0) * _S438 + make_float3 (eta_o_0) * out_dir_0);
    float3  _S440 = ((((_S439)) * make_float3(rnorm3df(((_S439)).x, ((_S439)).y, ((_S439)).z))));
    float _S441 = sign_0(dot_0(n_4, _S438));
    float _S442 = sign_0(dot_0(_S439, n_4 * make_float3 (_S441)));
    return _S440 * make_float3 (_S442);
}

__device__ __forceinline__ float3  reflectedHalf(float3  in_dir_1, float3  out_dir_1)
{
    float3  _S443 = negate_0(in_dir_1);
    float3  _S444 = _S443 + out_dir_1;
    float3  _S445 = ((((_S444)) * make_float3(rnorm3df(((_S444)).x, ((_S444)).y, ((_S444)).z))));
    return _S445;
}

static __device__ float3  refract_0(float3  i_5, float3  n_5, float eta_0)
{
    float _S446 = dot_0(n_5, i_5);
    float _S447 = 1.0f - eta_0 * eta_0 * (1.0f - _S446 * _S446);
    if(_S447 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_5 - make_float3 (eta_0 * _S446 + (F32_sqrt((_S447)))) * n_5;
}

__device__ float fresnel(float cos_theta_0, float eta_i_1, float eta_o_1)
{
    float _S448 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S449 = eta_i_1 / eta_o_1 * _S448;
    bool _S450 = _S449 < 1.0f;
    float kr_0;
    if(_S450)
    {
        float _S451 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S449 * _S449))))));
        bool _S452 = eta_i_1 == eta_o_1;
        float _S453 = _slang_select(_S452, cos_theta_0,_S451);
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
    float _S470 = _slang_select(_S469, _S467,1.0f);
    float _S471 = _slang_select(_S469, 1.0f,_S467);
    float _S472 = fresnel(_S468, _S470, _S471);
    bool _S473 = (eta_i_2 * eta_i_2 * (1.0f - _S461 * _S461)) >= (eta_o_2 * eta_o_2);
    float3  _S474 = material_4.specular_tint * make_float3 (_S466);
    float3  _S475 = _S474 + (make_float3 (1.0f) - _S474) * make_float3 (_S472 - _S466) / make_float3 (1.0f - _S466);
    float3  _S476 = make_float3 (1.0f);
    float3  _S477 = _slang_select(_S473, _S476,_S475);
    float3  _S478 = make_float3 (0.0f);
    float sheen_component_0;
    float3  sheen_1;
    float3  scale_1;
    if(sheen_profile_0.on)
    {
        float _S479 = (F32_min((sheen_profile_0.albedo), (1.0f)));
        float3  _S480 = make_float3 (1.0f) - material_4.sheen * make_float3 (_S479);
        float _S481 = rgb_to_greyscale(material_4.sheen);
        float _S482 = _S481 * _S479;
        float3  _S483 = material_4.sheen / make_float3 ((F32_max((sheen_profile_0.albedo), (1.0f))));
        sheen_component_0 = _S482;
        sheen_1 = _S483;
        scale_1 = _S480;
    }
    else
    {
        sheen_component_0 = 0.0f;
        sheen_1 = _S478;
        scale_1 = _S476;
    }
    float _S484 = (F32_abs((material_4.toon.x)));
    bool _S485 = _S484 > 0.0f;
    float toon_component_0;
    float3  toon_1;
    if(_S485)
    {
        float _S486 = (F32_min((_S484), (1.0f)));
        float3  scale_2 = scale_1 * make_float3 (1.0f - _S486);
        float _S487 = rgb_to_greyscale(material_4.albedo);
        float _S488 = _S486 * _S487;
        float3  _S489 = make_float3 (_S486) * material_4.albedo;
        toon_component_0 = _S488;
        toon_1 = _S489;
        scale_1 = scale_2;
    }
    else
    {
        toon_component_0 = 0.0f;
        toon_1 = _S478;
    }
    bool _S490 = (material_4.metallic) > 0.0f;
    float3  rebounce_0;
    if(_S490)
    {
        float _S491 = frame_2.alphas.x;
        float _S492 = (F32_sqrt(((F32_min((_S491), (frame_2.alphas.y))))));
        bool _S493 = _S491 > 0.0f;
        float _S494 = _slang_select(_S493, _S492,material_4.roughness);
        float _S495 = _S494 * _S494;
        float _S496 = (F32_pow((_S495), (1.81585001945495605f))) * (2.15371990203857422f - 0.73285001516342163f * _S495) / (1.0f + 1.28094995021820068f * _S495);
        bool _S497 = _S495 > 0.0f;
        float _S498 = _slang_select(_S497, _S496,0.0f);
        float _S499 = clamp_1(dot_0(n_i_4, v_5), 0.0f, 1.0f);
        float _S500 = _S495 * _S494;
        float _S501 = (F32_min((1.00064504146575928f - _S494 * (0.00375499995425344f + _S499 * (-0.04133399948477745f + _S499 * (-0.90938502550125122f + _S499 * 0.35275399684906006f))) - _S495 * (0.27602800726890564f + _S499 * (1.27023398876190186f + _S499 * 0.04740000143647194f)) - _S500 * (0.31452900171279907f - _S499 * 0.34830701351165771f) + _S500 * _S494 * 0.27229699492454529f), (1.0f)));
        float3  _S502 = min_1(make_float3 (1.0f) / (make_float3 (1.0f) - material_4.albedo * make_float3 (_S498)), make_float3 (1.0f / (F32_max((_S501), (0.0000152587890625f)))));
        rebounce_0 = _S502;
    }
    else
    {
        rebounce_0 = _S476;
    }
    float3  _S503 = mix_0(_S477, material_4.albedo * rebounce_0, material_4.metallic);
    float3  F_1 = _S503 * scale_1;
    float _S504 = rgb_to_greyscale(F_1);
    float _S505 = 1.0f - material_4.metallic;
    float3  _S506 = make_float3 (1.0f) - _S477;
    float3  _S507 = make_float3 ((1.0f - material_4.transmission) * _S505) * _S506 * scale_1;
    float3  _S508 = make_float3 (material_4.transmission * _S505) * _S506 * scale_1;
    float _S509 = (F32_max((_S504), (0.0f)));
    float _S510 = rgb_to_greyscale(_S507);
    float _S511 = (F32_max((_S510), (0.0f)));
    float _S512 = rgb_to_greyscale(_S508);
    float _S513 = sign_0(length_0(_S464));
    float _S514 = (F32_max((_S512 * _S513), (0.0f)));
    float _S515 = _S509 + _S511 + _S514 + toon_component_0;
    float _S516 = (F32_min((sheen_component_0), (1.0f)));
    bool _S517 = sheen_component_0 > 0.0f;
    bool _S518;
    if(_S517)
    {
        _S518 = !(_S515 > 0.0f);
    }
    else
    {
        _S518 = false;
    }
    float _S519 = _slang_select(_S518, 1.0f,_S516);
    float _S520 = (1.0f - _S519) / (F32_max((_S515), (0.0000152587890625f)));
    float _S521 = _S511 * _S520;
    float _S522 = _S509 * _S520;
    float _S523 = _S514 * _S520;
    return Weights_x24init_0(_S461, _S464, F_1, 1.0f, _S507, _S508, _S521, _S522, _S523, _S519, toon_component_0 * _S520, sheen_1, toon_1);
}

__device__ float translucentShare(BSDFMaterial material_5)
{
    float _S524 = rgb_to_greyscale(material_5.translucent);
    float _S525 = rgb_to_greyscale(material_5.albedo);
    float _S526 = _S524 / (_S525 + _S524);
    bool _S527 = _S524 > 0.0f;
    float _S528 = _slang_select(_S527, _S526,0.0f);
    return _S528;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float n_i_dot_v_0, BSDFMaterial material_6, Weights w_1)
{
    float _S529 = translucentShare(material_6);
    float _S530 = w_1.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S531 = w_1.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S532 = 1.0f - _S529;
    bool _S533 = n_i_dot_l_0 < 0.0f;
    float _S534 = _slang_select(_S533, _S529,_S532);
    float _S535 = _S531 * _S534;
    bool _S536 = _S529 > 0.0f;
    float _S537 = _slang_select(_S536, _S535,_S530);
    bool _S538 = n_i_dot_v_0 > 0.0f;
    float _S539 = _slang_select(_S538, _S537,0.0f);
    return _S539;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_5, BSDFMaterial material_7, Weights w_2)
{
    float _S540 = translucentShare(material_7);
    bool _S541 = (dot_0(n_i_5, l_0)) < 0.0f;
    float3  _S542 = _slang_select(_S541, material_7.translucent,material_7.albedo);
    float _S543 = 1.0f - _S540;
    float _S544 = _slang_select(_S541, _S540,_S543);
    float3  _S545 = _S542 / make_float3 (_S544);
    bool _S546 = _S540 > 0.0f;
    float3  _S547 = _slang_select(_S546, _S545,material_7.albedo);
    return w_2.diffuse_weight * _S547 / make_float3 (w_2.p_diffuse);
}

__device__ float smithG1(float alpha_3, float n_dot_x_0)
{
    float _S548 = alpha_3 * alpha_3;
    float _S549 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S548 + (1.0f - _S548) * n_dot_x_0 * n_dot_x_0))));
    bool _S550 = alpha_3 > 0.0f;
    float _S551 = _slang_select(_S550, _S549,1.0f);
    return _S551;
}

__device__ float trowbridgeReitz(float alpha_4, float n_dot_h_0)
{
    float _S552 = alpha_4 * alpha_4;
    float _S553 = (1.0f - n_dot_h_0) * (1.0f + n_dot_h_0) + _S552 * n_dot_h_0 * n_dot_h_0;
    return _S552 / (F32_max((3.14159274101257324f * _S553 * _S553), (1.17549435082228751e-38f)));
}

__device__ float anisotropicG1(float3  w_3, float2  alphas_1)
{
    float _S554 = (F32_max((w_3.z), (0.0f)));
    return 2.0f * _S554 / (_S554 + length_0(make_float3 (alphas_1.x * w_3.x, alphas_1.y * w_3.y, _S554)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_2)
{
    float _S555 = alphas_2.x;
    float _S556 = h_0.x / _S555;
    float _S557 = alphas_2.y;
    float _S558 = h_0.y / _S557;
    float _S559 = h_0.z;
    float _S560 = _S556 * _S556 + _S558 * _S558 + _S559 * _S559;
    return 1.0f / (F32_max((3.14159274101257324f * _S555 * _S557 * _S560 * _S560), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float3  v_6, float3  h_1, float3  n_i_6, float n_i_dot_v_1, float alpha_5, AnisotropicFrame frame_3, float v_dot_h_1)
{
    float _S561 = dot_0(n_i_6, h_1);
    float _S562 = smithG1(alpha_5, n_i_dot_v_1);
    float _S563 = _S562 * v_dot_h_1;
    float _S564 = trowbridgeReitz(alpha_5, _S561);
    float _S565 = _S563 * _S564 / n_i_dot_v_1;
    bool _S566 = alpha_5 > 0.0f;
    bool _S567;
    if(_S566)
    {
        _S567 = v_dot_h_1 > 0.0f;
    }
    else
    {
        _S567 = false;
    }
    if(_S567)
    {
        _S567 = _S561 > 0.0f;
    }
    else
    {
        _S567 = false;
    }
    if(_S567)
    {
        _S567 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S567 = false;
    }
    float _S568 = _slang_select(_S567, _S565,0.0f);
    bool _S569 = (frame_3.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S569)
    {
        float3  _S570 = anisotropicLocal(v_6, frame_3.tangent, n_i_6);
        float _S571 = anisotropicG1(_S570, frame_3.alphas);
        float3  _S572 = anisotropicLocal(h_1, frame_3.tangent, n_i_6);
        float _S573 = anisotropicD(_S572, frame_3.alphas);
        float _S574 = _S571 * _S573;
        float _S575 = _S574 * v_dot_h_1 / n_i_dot_v_1;
        bool _S576 = v_dot_h_1 > 0.0f;
        if(_S576)
        {
            _S567 = _S561 > 0.0f;
        }
        else
        {
            _S567 = false;
        }
        if(_S567)
        {
            _S567 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S567 = false;
        }
        float _S577 = _slang_select(_S567, _S575,0.0f);
        pdf_h_0 = _S577;
    }
    else
    {
        pdf_h_0 = _S568;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float l_dot_h_0, float pdf_h_1, Weights w_4, float eta_i_3, float eta_o_3)
{
    float _S578 = eta_i_3 * w_4.v_dot_h + eta_o_3 * l_dot_h_0;
    float _S579 = w_4.p_refract * pdf_h_1 * eta_o_3 * eta_o_3 * (F32_abs((l_dot_h_0))) / (_S578 * _S578);
    bool _S580 = eta_i_3 != eta_o_3;
    bool _S581;
    if(_S580)
    {
        _S581 = l_dot_h_0 < 0.0f;
    }
    else
    {
        _S581 = false;
    }
    float _S582 = _slang_select(_S581, _S579,0.0f);
    return _S582;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_7, float alpha_6, AnisotropicFrame frame_4, BSDFMaterial material_8, Weights w_5)
{
    float _S583 = - dot_0(n_i_7, l_1);
    float _S584 = smithG1(alpha_6, (F32_max((_S583), (0.0f))));
    bool _S585 = (frame_4.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S585)
    {
        float3  _S586 = negate_0(n_i_7);
        float3  _S587 = anisotropicLocal(l_1, frame_4.tangent, _S586);
        float _S588 = anisotropicG1(_S587, frame_4.alphas);
        G1_l_0 = _S588;
    }
    else
    {
        G1_l_0 = _S584;
    }
    bool _S589 = (material_8.ior) == 1.0f;
    float _S590 = _slang_select(_S589, 1.0f,G1_l_0);
    return w_5.refract_weight * make_float3 (_S590) * material_8.albedo / make_float3 (w_5.p_refract);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_1, float n_i_dot_v_2, Weights w_6)
{
    float _S591 = w_6.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S592 = n_i_dot_l_1 > 0.0f;
    bool _S593;
    if(_S592)
    {
        _S593 = n_i_dot_v_2 > 0.0f;
    }
    else
    {
        _S593 = false;
    }
    float _S594 = _slang_select(_S593, _S591,0.0f);
    return _S594;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  v_7, float3  n_i_8, BSDFMaterial material_9, Weights w_7)
{
    float3  _S595 = l_2 + v_7;
    float3  _S596 = ((((_S595)) * make_float3(rnorm3df(((_S595)).x, ((_S595)).y, ((_S595)).z))));
    float _S597 = dot_0(n_i_8, _S596);
    float _S598 = (F32_max((dot_0(n_i_8, l_2)), (0.0f)));
    float _S599 = (F32_max((dot_0(n_i_8, v_7)), (0.0f)));
    float _S600 = 1.0f / (F32_max((material_9.sheen_roughness), (0.05000000074505806f)));
    float _S601 = 1.0f - _S597 * _S597;
    float _S602 = (2.0f + _S600) * (F32_pow(((F32_max((_S601), (0.0f)))), (0.5f * _S600))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S598 + _S599 - _S598 * _S599)), (0.0000152587890625f)));
    bool _S603 = (material_9.velvet) > 0.0f;
    float f_1;
    if(_S603)
    {
        float _S604 = (F32_max((material_9.sheen_roughness), (0.00999999977648258f)));
        float _S605 = _S604 * _S604;
        float _S606 = (F32_max((_S601), (0.0000152587890625f)));
        float _S607 = (F32_exp((- _S597 * _S597 / (_S606 * _S605)))) / (3.14159274101257324f * _S605 * _S606 * _S606) * (F32_min((1.0f), (2.0f * _S597 * (F32_min((_S598), (_S599))) / (F32_max(((F32_abs((dot_0(_S596, v_7))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S598 * _S599), (0.0000152587890625f)));
        f_1 = _S607;
    }
    else
    {
        f_1 = _S602;
    }
    return w_7.sheen * make_float3 (f_1 * _S598 * 2.0f * 3.14159274101257324f / w_7.p_sheen_velvet);
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
    float _S608 = (F32_max((1.0f - (t_13 - a_5) / (F32_max((s_0), (0.0000152587890625f)))), (0.0f)));
    bool _S609 = t_13 < a_5;
    float _S610 = _slang_select(_S609, 1.0f,_S608);
    return _S610;
}

__device__ __forceinline__ float toonIntegral(float t_14, float a_6, float s_1, bool glossy_0)
{
    float _S611 = (F32_min((t_14), (a_6)));
    float _S612 = (F32_sin((_S611)));
    float _S613 = _S612 * _S612 / 2.0f;
    float _S614 = 1.0f - (F32_cos((_S611)));
    float _S615 = _slang_select(glossy_0, _S614,_S613);
    bool _S616 = t_14 > a_6;
    bool _S617;
    if(_S616)
    {
        _S617 = s_1 > 0.0f;
    }
    else
    {
        _S617 = false;
    }
    float integral_0;
    if(_S617)
    {
        if(glossy_0)
        {
            float _S618 = (F32_cos((a_6)));
            float _S619 = (F32_cos((t_14)));
            integral_0 = (1.0f + a_6 / s_1) * (_S618 - _S619) - ((F32_sin((t_14))) - t_14 * _S619 - ((F32_sin((a_6))) - a_6 * _S618)) / s_1;
        }
        else
        {
            float _S620 = 2.0f * a_6;
            float _S621 = (F32_cos((_S620)));
            float _S622 = 2.0f * t_14;
            float _S623 = (F32_cos((_S622)));
            integral_0 = (1.0f + a_6 / s_1) * (_S621 - _S623) / 4.0f - ((F32_sin((_S622))) / 8.0f - t_14 * _S623 / 4.0f - ((F32_sin((_S620))) / 8.0f - a_6 * _S621 / 4.0f)) / s_1;
        }
        float integral_1 = _S615 + integral_0;
        integral_0 = integral_1;
    }
    else
    {
        integral_0 = _S615;
    }
    return integral_0;
}

static __device__ ToonProfile ToonProfile_x24init_0(bool glossy_1, float a_7, float s_2, float b_1, float norm_0, float view_0, float3  axis_0)
{
    ToonProfile _S624;
    (&_S624)->glossy = glossy_1;
    (&_S624)->a = a_7;
    (&_S624)->s = s_2;
    (&_S624)->b = b_1;
    (&_S624)->norm = norm_0;
    (&_S624)->view = view_0;
    (&_S624)->axis = axis_0;
    return _S624;
}

__device__ __forceinline__ ToonProfile toonProfile(float3  v_8, float3  n_i_9, BSDFMaterial material_10)
{
    float _S625 = material_10.toon.x;
    bool _S626 = _S625 < 0.0f;
    float _S627 = clamp_1(material_10.toon.y / _S625, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S628 = clamp_1(material_10.toon.z / _S625, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S629 = (F32_min((_S627 + _S628), (1.57079637050628662f)));
    float _S630 = dot_0(n_i_9, v_8);
    float _S631 = toonP((F32_acos(((F32_min((_S630), (1.0f)))))), _S627, _S628);
    float3  _S632 = make_float3 (2.0f * _S630) * n_i_9 - v_8;
    float3  _S633 = ((((_S632)) * make_float3(rnorm3df(((_S632)).x, ((_S632)).y, ((_S632)).z))));
    float3  _S634 = _slang_select(_S626, _S633,n_i_9);
    float _S635 = toonIntegral(_S629, _S627, _S628, _S626);
    return ToonProfile_x24init_0(_S626, _S627, _S628, _S629, 6.28318548202514648f * _S635, _S631, _S634);
}

__device__ __forceinline__ float toonPDF(float3  l_3, float3  n_i_10, ToonProfile profile_1, Weights w_8)
{
    float _S636 = dot_0(n_i_10, l_3);
    float _S637 = dot_0(l_3, profile_1.axis);
    float _S638 = _slang_select(profile_1.glossy, _S637,_S636);
    float _S639 = (F32_acos((clamp_1(_S638, -1.0f, 1.0f))));
    float _S640 = toonP(_S639, profile_1.a, profile_1.s);
    float _S641 = w_8.p_toon * _S640;
    float _S642 = _slang_select(profile_1.glossy, 1.0f,_S636);
    float _S643 = _S641 * _S642 / profile_1.norm;
    bool _S644;
    if(profile_1.glossy)
    {
        _S644 = true;
    }
    else
    {
        _S644 = _S636 > 0.0f;
    }
    float _S645 = _slang_select(_S644, _S643,0.0f);
    return _S645;
}

__device__ __forceinline__ float3  toonBSDF(float3  l_4, float3  n_i_11, ToonProfile profile_2, Weights w_9)
{
    float _S646 = (F32_max((dot_0(n_i_11, l_4)), (0.0f)));
    float _S647 = _slang_select(profile_2.glossy, _S646,profile_2.view);
    return w_9.toon * make_float3 (_S647) / make_float3 (w_9.p_toon);
}

__device__ __forceinline__ float reflectPDF(float pdf_h_2, Weights w_10)
{
    float _S648 = w_10.p_reflect * pdf_h_2 / (4.0f * w_10.v_dot_h);
    bool _S649 = pdf_h_2 > 0.0f;
    float _S650 = _slang_select(_S649, _S648,0.0f);
    return _S650;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_5, float3  n_i_12, float alpha_7, AnisotropicFrame frame_5, Weights w_11)
{
    float _S651 = dot_0(n_i_12, l_5);
    float _S652 = smithG1(alpha_7, (F32_max((_S651), (0.0f))));
    bool _S653 = (frame_5.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S653)
    {
        float3  _S654 = anisotropicLocal(l_5, frame_5.tangent, n_i_12);
        float _S655 = anisotropicG1(_S654, frame_5.alphas);
        G1_l_1 = _S655;
    }
    else
    {
        G1_l_1 = _S652;
    }
    return make_float3 (w_11.reflect_weight * G1_l_1) * w_11.F / make_float3 (w_11.p_reflect);
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_3, float3  out_dir_2, float3  n_6, BSDFMaterial material_11, float eta_i_4, float eta_o_4, bool refracted_2, uint random_state_4, FixedArray<float3 , 5>  * throughputs_0, FixedArray<float, 5>  * pdfs_0)
{
    float3  ggx_n_1;
    float3  _S656 = negate_0(in_dir_3);
    float _S657 = dot_0(n_6, _S656);
    float _S658 = sign_0(_S657);
    float3  _S659 = n_6 * make_float3 (_S658);
    float _S660 = dot_0(_S659, out_dir_2);
    float _S661 = material_11.roughness;
    float _S662 = _S661 * _S661;
    AnisotropicFrame _S663 = anisotropicFrame(material_11, _S659);
    SheenProfile _S664 = sheenProfile(_S656, _S659, material_11);
    float _S665 = rgb_to_greyscale(material_11.translucent);
    bool _S666 = _S665 > 0.0f;
    bool _S667 = (dot_0(n_6, out_dir_2) * _S657) < 0.0f;
    bool _S668 = (F32_abs((material_11.toon.x))) > 0.0f;
    uint _S669;
    if(_S668)
    {
        _S669 = 5U;
    }
    else
    {
        _S669 = 4U;
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
        float3  _S670 = make_float3 (0.0f);
        (*throughputs_0)[i_7] = _S670;
        (*pdfs_0)[i_7] = 0.0f;
        uint i_8 = i_7 + 1U;
        i_7 = i_8;
    }
    float3  _S671 = make_float3 (0.0f);
    Weights _S672 = Weights_x24init_0(0.0f, _S671, _S671, 0.0f, _S671, _S671, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, _S671, _S671);
    uint half_of_0 = 4294967295U;
    Weights w_12 = _S672;
    float3  ggx_n_2 = _S671;
    i_7 = 0U;
    for(;;)
    {
        if(i_7 < _S669)
        {
        }
        else
        {
            break;
        }
        uint _S673;
        if(i_7 == 3U)
        {
            _S673 = 4U;
        }
        else
        {
            if(i_7 == 4U)
            {
                _S673 = 6U;
            }
            else
            {
                _S673 = i_7;
            }
        }
        bool _S674 = _S673 == 0U;
        bool _S675;
        if(_S674)
        {
            _S675 = _S666;
        }
        else
        {
            _S675 = false;
        }
        bool _S676;
        if(_S675)
        {
            _S676 = _S667;
        }
        else
        {
            _S676 = _S673 == 1U;
        }
        bool _S677 = _S676 != refracted_2;
        if(_S677)
        {
            ggx_n_1 = ggx_n_2;
            uint i_9 = i_7 + 1U;
            ggx_n_2 = ggx_n_1;
            i_7 = i_9;
            continue;
        }
        uint _S678;
        if(_S673 == 6U)
        {
            _S678 = 0U;
        }
        else
        {
            if(_S673 == 4U)
            {
                _S678 = 2U;
            }
            else
            {
                _S678 = _S673;
            }
        }
        bool _S679 = _S678 != half_of_0;
        uint half_of_1;
        Weights w_13;
        if(_S679)
        {
            bool _S680 = _S678 == 0U;
            if(_S680)
            {
                float3  _S681 = sampledHalf(_S656, _S659, _S662, _S663, random_state_4);
                ggx_n_1 = _S681;
            }
            else
            {
                bool _S682 = _S678 == 1U;
                if(_S682)
                {
                    float3  _S683 = refractedHalf(in_dir_3, out_dir_2, n_6, eta_i_4, eta_o_4);
                    ggx_n_1 = _S683;
                }
                else
                {
                    float3  _S684 = reflectedHalf(in_dir_3, out_dir_2);
                    ggx_n_1 = _S684;
                }
            }
            Weights _S685 = lobeWeights(in_dir_3, _S656, _S659, ggx_n_1, _S663, _S664, material_11, eta_i_4, eta_o_4);
            w_13 = _S685;
            half_of_1 = _S678;
        }
        else
        {
            w_13 = w_12;
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S673)
        {
        case 0U:
            {
                float _S686 = diffusePDF(_S660, (F32_abs((_S657))), material_11, w_13);
                (*pdfs_0)[int(0)] = _S686;
                float3  _S687 = diffuseBSDF(out_dir_2, _S659, material_11, w_13);
                (*throughputs_0)[int(0)] = _S687;
                break;
            }
        case 1U:
            {
                float _S688 = dot_0(out_dir_2, ggx_n_1);
                float _S689 = vndfPDF(_S656, ggx_n_1, _S659, (F32_abs((_S657))), _S662, _S663, w_13.v_dot_h);
                float _S690 = refractPDF(_S688, _S689, w_13, eta_i_4, eta_o_4);
                (*pdfs_0)[int(1)] = _S690;
                float3  _S691 = refractBSDF(out_dir_2, _S659, _S662, _S663, material_11, w_13);
                (*throughputs_0)[int(1)] = _S691;
                break;
            }
        case 4U:
            {
                float _S692 = sheenVelvetPDF(_S660, (F32_abs((_S657))), w_13);
                (*pdfs_0)[int(3)] = _S692;
                float3  _S693 = sheenVelvetBSDF(out_dir_2, _S656, _S659, material_11, w_13);
                (*throughputs_0)[int(3)] = _S693;
                break;
            }
        case 6U:
            {
                ToonProfile _S694 = toonProfile(_S656, _S659, material_11);
                float _S695 = toonPDF(out_dir_2, _S659, _S694, w_13);
                (*pdfs_0)[int(4)] = _S695;
                float3  _S696 = toonBSDF(out_dir_2, _S659, _S694, w_13);
                (*throughputs_0)[int(4)] = _S696;
                break;
            }
        default:
            {
                float _S697 = vndfPDF(_S656, ggx_n_1, _S659, (F32_abs((_S657))), _S662, _S663, w_13.v_dot_h);
                float _S698 = reflectPDF(_S697, w_13);
                (*pdfs_0)[int(2)] = _S698;
                float3  _S699 = reflectBSDF(out_dir_2, _S659, _S662, _S663, w_13);
                (*throughputs_0)[int(2)] = _S699;
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
    ggx_n_1 = _S671;
    for(;;)
    {
        if(i_7 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S700 = ((*pdfs_0)[i_7]) > 0.0f;
        if(_S700)
        {
            float3  f_2 = ggx_n_1 + (*throughputs_0)[i_7] * make_float3 ((*pdfs_0)[i_7]);
            ggx_n_1 = f_2;
        }
        uint i_10 = i_7 + 1U;
        i_7 = i_10;
    }
    return ggx_n_1;
}

static __device__ __forceinline__ float3  skyLobes_0(float3  in_dir_4, float3  dir_6, FKSurface * surface_1, BSDFMaterial * material_12, float2  eta_1, bool is_inside_2, float pdf_1, uint random_state_5, FixedArray<float3 , 5>  * terms_0, FixedArray<float, 5>  * pdfs_1)
{
    bool _S701 = wrongSide_0(is_inside_2, false, dir_6, surface_1->geometry_n);
    float3  _S702 = BSDF(in_dir_4, dir_6, surface_1->smooth_n, *material_12, eta_1.x, eta_1.y, _S701, random_state_5, terms_0, pdfs_1);
    float3  _S703 = make_float3 (0.0f);
    uint i_11 = 0U;
    float3  f_3 = _S703;
    for(;;)
    {
        if(i_11 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S704 = ((*pdfs_1)[i_11]) > 0.0f;
        if(_S704)
        {
            float3  _S705 = (*terms_0)[i_11] * make_float3 ((*pdfs_1)[i_11]) / make_float3 ((*pdfs_1)[i_11] + pdf_1);
            (*terms_0)[i_11] = _S705;
            float3  f_4 = f_3 + (*terms_0)[i_11];
            f_3 = f_4;
        }
        uint i_12 = i_11 + 1U;
        i_11 = i_12;
    }
    return f_3;
}

__device__ float3  skyBSDF(float3  in_dir_5, float3  dir_7, FKSurface surface_2, BSDFMaterial material_13, float2  eta_2, bool is_inside_3, float pdf_2, uint random_state_6)
{
    FKSurface _S706 = surface_2;
    BSDFMaterial _S707 = material_13;
    FixedArray<float3 , 5>  terms_1;
    FixedArray<float, 5>  pdfs_2;
    float3  _S708 = skyLobes_0(in_dir_5, dir_7, &_S706, &_S707, eta_2, is_inside_3, pdf_2, random_state_6, &terms_1, &pdfs_2);
    return _S708;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_8, float3  radiance_0, float3  color_0, uint random_state_7)
{
    SkySample _S709;
    (&_S709)->dir = dir_8;
    (&_S709)->radiance = radiance_0;
    (&_S709)->color = color_0;
    (&_S709)->random_state = random_state_7;
    return _S709;
}

static __device__ __noinline__ float3  skyColor_0(float3  in_dir_6, float3  dir_9, FKSurface * surface_3, float wavelength_3, float2  eta_3, bool is_inside_4, float pdf_3, uint random_state_8, uint depth_1)
{
    BSDFMaterial _S710 = pathMaterial(surface_3->material, wavelength_3);
    BSDFMaterial _S711 = _S710;
    FixedArray<float3 , 5>  terms_2;
    FixedArray<float, 5>  pdfs_3;
    float3  _S712 = skyLobes_0(in_dir_6, dir_9, surface_3, &_S711, eta_3, is_inside_4, pdf_3, random_state_8, &terms_2, &pdfs_3);
    float3  _S713 = make_float3 (0.0f);
    bool shaded_0 = false;
    float3  world_0 = _S713;
    uint i_13 = 0U;
    float3  color_1 = _S713;
    for(;;)
    {
        if(i_13 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S714 = (pdfs_3[i_13]) > 0.0f;
        if(_S714)
        {
            bool _S715 = (fcptWorldReadsPath());
            bool _S716;
            if(_S715)
            {
                _S716 = true;
            }
            else
            {
                _S716 = !shaded_0;
            }
            bool shaded_1;
            float3  world_1;
            if(_S716)
            {
                uint _S717;
                if(i_13 == 3U)
                {
                    _S717 = 4U;
                }
                else
                {
                    if(i_13 == 4U)
                    {
                        _S717 = 6U;
                    }
                    else
                    {
                        _S717 = i_13;
                    }
                }
                float3  _S718 = (fcptEnvMapSample((dir_9), (depth_1), (_S717)));
                world_1 = _S718;
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
    uint2  _S719 = (fcptEnvironmentCdfSize());
    uint2  _S720 = make_uint2 (1U, 0U);
    uint2  _S721 = _S719 - _S720;
    Random _S722 = pcg(init_random_state_0);
    Random _S723 = pcg(_S722.state);
    Random _S724 = pcg(_S723.state);
    Random _S725 = pcg(_S724.state);
    uint _S726 = _S721.x;
    uint _S727 = searchCDF_0(make_uint2 (_S726, 0U), make_uint2 (0U, 1U), _S721.y, _S722.value);
    uint _S728 = searchCDF_0(make_uint2 (0U, _S727), _S720, _S726, _S723.value);
    float2  _S729 = make_float2 ((float)_S721.x, (float)_S721.y);
    float2  _S730 = (make_float2 (float(_S728), float(_S727)) + make_float2 (_S724.value, _S725.value)) / _S729 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S731 = _S730.y;
    float _S732 = (F32_sin((_S731)));
    float _S733 = _S730.x;
    float3  _S734 = skyFrame_0(make_float3 (_S732 * (F32_cos((_S733))), (F32_cos((_S731))), _S732 * (F32_sin((_S733)))));
    float _S735 = environmentPdf_0(_S734);
    BSDFMaterial _S736 = pathMaterial(surface_4->material, wavelength_4);
    float3  _S737 = ray_0->unit_direction;
    float3  _S738 = skyBSDF(ray_0->unit_direction, _S734, *surface_4, _S736, eta_4, is_inside_5, _S735, lobe_state_0);
    bool _S739 = !(_S735 > 0.0f);
    bool _S740;
    if(_S739)
    {
        _S740 = true;
    }
    else
    {
        _S740 = all_1(_S738 == make_float3 (0.0f));
    }
    if(_S740)
    {
        float3  _S741 = make_float3 (0.0f);
        return SkySample_x24init_0(_S734, _S741, _S741, _S725.state);
    }
    bool _S742 = (fcptWorldReadsPath());
    float3  seen_0;
    if(_S742)
    {
        float3  _S743 = skyColor_0(_S737, _S734, surface_4, wavelength_4, eta_4, is_inside_5, _S735, lobe_state_0, context_2->depth + 1U);
        seen_0 = _S743;
    }
    else
    {
        seen_0 = _S738;
    }
    float3  _S744 = skyRadiance_0(ray_0->origin, surface_4, is_inside_5, _S734, context_2, _S725.state);
    return SkySample_x24init_0(_S734, _S744, seen_0 * _S744, _S725.state);
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
    SampleBSDF _S745 = (fcptConnectHair((surface_5->hair), ((&surface_5->material)->albedo), ((&surface_5->material)->specular_tint), (in_dir_7), (light_1->dir)));
    float3  _S746 = _S745.throughput * make_float3 (_S745.pdf);
    float _S747 = light_1->density;
    float _S748 = 1.0f + _S745.pdf * _S745.pdf / (light_1->density * light_1->density);
    bool _S749;
    if(competing_0)
    {
        _S749 = _S747 > 0.0f;
    }
    else
    {
        _S749 = false;
    }
    float _S750 = _slang_select(_S749, _S748,1.0f);
    return _S746 / make_float3 (_S750) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_10, float3  radiance_1, float density_0, uint random_state_9)
{
    TreeSample _S751;
    (&_S751)->dir = dir_10;
    (&_S751)->radiance = radiance_1;
    (&_S751)->density = density_0;
    (&_S751)->random_state = random_state_9;
    return _S751;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_13, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S752 = importance(first_1, p_13, normal_3);
    float _S753 = importance(second_1, p_13, normal_3);
    float2  _S754 = make_float2 (_S752, _S753);
    bool _S755 = _S752 == 0.0f;
    bool _S756;
    if(_S755)
    {
        _S756 = _S753 == 0.0f;
    }
    else
    {
        _S756 = false;
    }
    if(_S756)
    {
        return 2U;
    }
    float _S757 = _S752 + _S753;
    bool _S758 = _S753 > 0.0f;
    if(_S758)
    {
        _S756 = (*pick_0 * _S757) >= _S752;
    }
    else
    {
        _S756 = false;
    }
    uint _S759 = uint(_S756);
    float _S760 = (F32_min(((*pick_0 * _S757 - float(_S759) * _S752) / _slang_vector_get_element(_S754, _S759)), (0.99999994039535522f)));
    *pick_0 = _S760;
    float _S761 = *probability_3 * (_slang_vector_get_element(_S754, _S759) / _S757);
    *probability_3 = _S761;
    return _S759;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_14, float u1_0, float u2_0)
{
    float3  _S762 = center_1 - p_14;
    float _S763 = radius_1 * radius_1 / dot_0(_S762, _S762);
    float _S764 = u1_0 * _S763 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S763), (0.0f)))))));
    float _S765 = 2.0f * u1_0;
    bool _S766 = _S763 >= 1.0f;
    float _S767 = _slang_select(_S766, _S765,_S764);
    float _S768 = (F32_sqrt(((F32_max((_S767 * (2.0f - _S767)), (0.0f))))));
    float _S769 = 6.28318548202514648f * u2_0;
    float3  _S770 = make_float3 (_S768 * (F32_cos((_S769))), 1.0f - _S767, _S768 * (F32_sin((_S769))));
    float3  _S771 = ((((_S762)) * make_float3(rnorm3df(((_S762)).x, ((_S762)).y, ((_S762)).z))));
    float3  _S772 = tangentToWorld(_S770, _S771);
    return _S772;
}

__device__ float3  pointLightRadiance(float3  color_3, float intensity_0, float radius_2)
{
    return color_3 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S773 = center_2 - ray_1->origin;
    float _S774 = dot_0(_S773, ray_1->unit_direction);
    float _S775 = dot_0(_S773, _S773) - _S774 * _S774;
    float _S776 = radius_3 * radius_3;
    bool _S777 = _S775 > _S776;
    if(_S777)
    {
        return 4.294967296e+09f;
    }
    float _S778 = (F32_sqrt((_S776 - _S775)));
    float _S779 = _S774 - _S778;
    float _S780 = _S774 + _S778;
    bool _S781 = _S779 > 0.0000152587890625f;
    bool _S782;
    if(_S781)
    {
        _S782 = _S779 < max_len_0;
    }
    else
    {
        _S782 = false;
    }
    if(_S782)
    {
        return _S779;
    }
    bool _S783 = _S780 > 0.0000152587890625f;
    if(_S783)
    {
        _S782 = _S780 < max_len_0;
    }
    else
    {
        _S782 = false;
    }
    if(_S782)
    {
        return _S780;
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

static __device__ float3  emitted_0(float3  emissive_0, float3  dir_11, float3  n_7)
{
    float _S784 = sign_0(dot_0(- dir_11, n_7));
    float3  _S785 = emissive_0 * make_float3 ((F32_max((_S784), (0.0f))));
    bool _S786 = ((true));
    float3  _S787 = _slang_select(_S786, emissive_0,_S785);
    return _S787;
}

static __device__ __forceinline__ TreeSample sampleLightTree_0(float3  origin_4, float3  smooth_n_2, float3  geometry_n_1, float geometry_offset_1, bool sided_0, uint init_random_state_1, ShadowContext * context_3)
{
    Random _S788 = pcg(init_random_state_1);
    Random _S789 = pcg(_S788.state);
    Random _S790 = pcg(_S789.state);
    float3  _S791 = make_float3 (0.0f);
    TreeSample _S792 = TreeSample_x24init_0(_S791, _S791, 0.0f, _S790.state);
    TreeSample sample_0 = _S792;
    float3  _S793 = _slang_select(sided_0, _S791,smooth_n_2);
    float3  _S794 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S788.value;
    float probability_4 = 1.0f;
    uint n_8 = 0U;
    for(;;)
    {
        uint4  _S795 = (fcptLightNode((n_8)));
        if((_S795.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S796 = (fcptLightSecond((n_8)));
        uint _S797 = n_8 + 1U;
        LightNode _S798 = (fcptLightBounds((_S797)));
        LightNode _S799 = (fcptLightBounds((_S796)));
        uint _S800 = pickChild(_S798, _S799, origin_4, _S793, &pick_1, &probability_4);
        bool _S801 = _S800 > 1U;
        if(_S801)
        {
            return sample_0;
        }
        bool _S802 = _S800 == 1U;
        uint _S803 = _slang_select(_S802, _S796,_S797);
        n_8 = _S803;
    }
    bool _S804 = n_8 == 0U;
    bool _S805;
    if(_S804)
    {
        LightNode _S806 = (fcptLightBounds((0U)));
        float _S807 = importance(_S806, origin_4, _S793);
        _S805 = !(_S807 > 0.0f);
    }
    else
    {
        _S805 = false;
    }
    if(_S805)
    {
        return sample_0;
    }
    uint4  _S808 = (fcptLightNode((n_8)));
    FKHit _S809 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S810 = (_S808.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S810)
    {
        FKLight _S811 = (fcptLight((_S808.y)));
        if(sided_0)
        {
            float _S812 = sign_0(dot_0(geometry_n_1, _S811.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S812);
            float3  _S813 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S813;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S794;
            lift_n_0 = smooth_n_2;
        }
        bool _S814 = (_S811.variance) == 0.0f;
        if(_S814)
        {
            float3  _S815 = _S811.position - emitter_point_0;
            float3  _S816 = ((((_S815)) * make_float3(rnorm3df(((_S815)).x, ((_S815)).y, ((_S815)).z))));
            (&sample_0)->dir = _S816;
            float3  _S817 = _S811.color * make_float3 (_S811.intensity) / make_float3 (dot_0(_S815, _S815) * probability_4);
            (&sample_0)->radiance = _S817;
            shadow_1 = _S815;
        }
        else
        {
            float3  _S818 = sampleSphere(_S811.position, _S811.variance, emitter_point_0, _S789.value, _S790.value);
            (&sample_0)->dir = _S818;
            float _S819 = sphereDensity(_S811.position, _S811.variance, emitter_point_0);
            float _S820 = probability_4 * _S819;
            (&sample_0)->density = _S820;
            float3  _S821 = pointLightRadiance(_S811.color, _S811.intensity, _S811.variance);
            float3  _S822 = _S821 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S822;
            FKRay _S823 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S824 = raySphere_0(_S811.position, _S811.variance, &_S823, 4.294967296e+09f);
            float3  _S825 = (&sample_0)->dir * make_float3 (_S824);
            shadow_1 = _S825;
        }
        emitter_0 = _S809;
        emitter_point_0 = _S791;
    }
    else
    {
        uint _S826 = _S808.y;
        uint _S827 = (fcptTriangleOffset((_S826)));
        uint _S828 = _S827 + _S808.z;
        Matrix<float, 3, 3>  _S829 = (fcptWorldTriangle((_S826), (_S828)));
        float _S830 = (F32_sqrt((_S789.value)));
        float2  _S831 = make_float2 (_S830 * (1.0f - _S790.value), _S830 * _S790.value);
        float3  _S832 = mul_0(make_float3 (1.0f - _S830, _S831.x, _S831.y), _S829);
        if(sided_0)
        {
            float _S833 = sign_0(dot_0(geometry_n_1, _S832 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S833);
            float3  _S834 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S834;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S835 = !((dot_0(smooth_n_2, _S832 - origin_4)) > 0.0f);
            if(_S835)
            {
                return sample_0;
            }
            emitter_point_0 = _S794;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S831, _S826, _S828, 0U, 0.0f);
        float3  _S836 = _S832 - emitter_point_0;
        float3  _S837 = ((((_S836)) * make_float3(rnorm3df(((_S836)).x, ((_S836)).y, ((_S836)).z))));
        (&sample_0)->dir = _S837;
        float _S838 = solidAngle(probability_4, cross_0(_S829.rows[int(1)] - _S829.rows[int(0)], _S829.rows[int(2)] - _S829.rows[int(0)]), _S836);
        (&sample_0)->density = _S838;
        bool _S839 = (fcptShadowFirst());
        bool _S840 = !_S839;
        if(_S840)
        {
            FKSurface _S841 = (fcptLightSurfaceAt((emitter_1), (_S832), (_S790.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S832 - origin_4))));
            (&sample_0)->random_state = _S841.random_state;
            float3  _S842 = emitted_0(_S841.material.emissive, (&sample_0)->dir, _S841.smooth_n);
            float3  _S843 = _slang_select(_S841.skip, _S791,_S842);
            float3  _S844 = _S843 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S844;
        }
        shadow_1 = _S836;
        emitter_0 = emitter_1;
        emitter_point_0 = _S832;
    }
    FKHit _S845 = emitter_0;
    float3  _S846 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S790.state, &_S845);
    bool _S847 = (fcptShadowFirst());
    if(_S847)
    {
        _S805 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S805 = false;
    }
    if(_S805)
    {
        _S805 = !all_1(_S846 == _S791);
    }
    else
    {
        _S805 = false;
    }
    if(_S805)
    {
        FKSurface _S848 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S790.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S848.random_state;
        float3  _S849 = emitted_0(_S848.material.emissive, (&sample_0)->dir, _S848.smooth_n);
        float3  _S850 = _slang_select(_S848.skip, _S791,_S849);
        float3  _S851 = _S850 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S851;
    }
    float3  _S852 = (&sample_0)->radiance * _S846;
    bool _S853 = all_1(_S846 == _S791);
    float3  _S854 = _slang_select(_S853, _S791,_S852);
    (&sample_0)->radiance = _S854;
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
    float _S855 = 1.0f / (1.0f + b_2 / a_8 * (b_2 / a_8));
    bool _S856 = b_2 > 0.0f;
    float _S857 = _slang_select(_S856, _S855,1.0f);
    return _S857;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S858 = vertex_0->none;
    if(_S858)
    {
        return 1.0f;
    }
    uint _S859 = (fcptLightSlot((*hit_1)));
    float _S860 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S859, light_point_1);
    float _S861 = powerHeuristic(vertex_0->pdf, _S860);
    return _S861;
}

struct Vertex
{
    bool rough;
    uint lobe;
    float pdf;
    float cos;
    bool inside;
};

__device__ float3  pathColor(float3  f_5, float3  weight_0, float wavelength_5)
{
    float _S862 = upsample(f_5, wavelength_5);
    float3  _S863 = weight_0 * make_float3 (_S862);
    bool _S864 = wavelength_5 > 0.0f;
    float3  _S865 = _slang_select(_S864, _S863,f_5);
    return _S865;
}

__device__ float3  safeDivide(float3  a_9, float3  b_3)
{
    float3  _S866 = a_9 / b_3;
    float3  _S867 = make_float3 (0.0f);
    bool3  _S868 = b_3 == _S867;
    float3  _S869 = _slang_select(_S868, _S867,_S866);
    return _S869;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_2)
{
    uint _S870 = (1U << count_2) - 1U;
    return (e_2 & (~(_S870 << offset_1))) | ((newbits_0 & _S870) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_3, uint end_type_0, uint end_0, float3  f_6)
{
    Reservoir candidate_0 = r_3;
    uint _S871 = insertBits_0(r_3.path, end_0, 0U, 5U);
    uint _S872 = insertBits_0(_S871, end_type_0, 12U, 3U);
    (&candidate_0)->path = _S872;
    (&candidate_0)->f = f_6;
    return candidate_0;
}

static __device__ float3  abs_0(float3  x_16)
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
        *_slang_vector_get_element_ptr(&result_7, i_16) = (F32_abs((_slang_vector_get_element(x_16, i_16))));
        i_16 = i_16 + int(1);
    }
    return result_7;
}

__device__ float resamplingTarget(float3  f_7)
{
    float _S873 = rgb_to_greyscale(abs_0(f_7));
    return _S873;
}

__device__ void offer(Selection * sel_2, Reservoir candidate_1, float3  weight_1)
{
    float _S874 = resamplingTarget(weight_1);
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
        float3  _S879 = sel_2->color + weight_1;
        sel_2->color = _S879;
        return;
    }
    float _S880 = sel_2->w_sum + _S874;
    sel_2->w_sum = _S880;
    float3  _S881 = sel_2->color + weight_1;
    sel_2->color = _S881;
    Random _S882 = pcg(sel_2->random_state);
    sel_2->random_state = _S882.state;
    bool _S883 = (_S882.value * sel_2->w_sum) <= _S874;
    if(_S883)
    {
        sel_2->r = candidate_1;
    }
    return;
}

static __device__ Shift escape_0(Reservoir * r_4, bool replay_1, uint stop_0, uint rc_0, uint end_1, uint end_type_1, float scale_3, uint strata_0, Reservoir * chain_0, float3  chain_throughput_0, uint b_4, FKRay * ray_2, float3  throughput_0, float density_1, Vertex * prev_0, NEEVertex * nee_vertex_0, float sky_pdf_0, float3  spectral_weight_0, float wavelength_6, Selection * sel_3)
{
    Shift _S884 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
    bool _S885 = !nee_vertex_0->none;
    float _S886 = _slang_select(_S885, sky_pdf_0,0.0f);
    float3  _S887 = ray_2->unit_direction;
    float _S888 = escapeWeight_0(_S886, ray_2->unit_direction);
    uint _S889 = prev_0->lobe;
    float3  _S890 = environment_0(_S887, b_4, prev_0->lobe);
    float3  _S891 = pathColor(throughput_0 * _S890, spectral_weight_0, wavelength_6);
    if(replay_1)
    {
        bool _S892 = b_4 == stop_0;
        bool _S893;
        if(_S892)
        {
            _S893 = rc_0 == 3U;
        }
        else
        {
            _S893 = false;
        }
        if(_S893)
        {
            return Shift_x24init_0(_S891 * make_float3 (_S888) / make_float3 (r_4->jac), density_1 / r_4->jac);
        }
        bool _S894 = rc_0 == 0U;
        if(_S894)
        {
            _S893 = end_type_1 == 3U;
        }
        else
        {
            _S893 = false;
        }
        if(_S893)
        {
            _S893 = b_4 == end_1;
        }
        else
        {
            _S893 = false;
        }
        if(_S893)
        {
            _S893 = !prev_0->rough;
        }
        else
        {
            _S893 = false;
        }
        if(_S893)
        {
            return Shift_x24init_0(_S891 * make_float3 (_S888), 1.0f);
        }
        return _S884;
    }
    Reservoir candidate_2 = *chain_0;
    uint _S895 = chain_0->path;
    uint _S896 = extractBits_0(chain_0->path, 10U, 2U);
    bool _S897 = _S896 == 1U;
    if(_S897)
    {
        uint _S898 = extractBits_0(_S895, 5U, 5U);
        bool _S899 = _S898 == b_4;
        float _S900 = _slang_select(_S899, 1.0f,_S888);
        float3  _S901 = safeDivide(_S891 * make_float3 (_S900), chain_throughput_0);
        (&candidate_2)->radiance = _S901;
    }
    else
    {
        bool _S902 = prev_0->rough;
        if(_S902)
        {
            uint _S903 = insertBits_0(strata_0, b_4 + 1U, 5U, 5U);
            uint _S904 = insertBits_0(_S903, 3U, 10U, 2U);
            uint _S905 = insertBits_0(_S904, _S889, 15U, 3U);
            bool _S906 = prev_0->inside;
            uint _S907 = _slang_select(_S906, 1U,0U);
            uint _S908 = insertBits_0(_S905, _S907, 22U, 1U);
            (&candidate_2)->path = _S908;
            (&candidate_2)->jac = prev_0->pdf;
            (&candidate_2)->dir = _S887;
        }
    }
    float3  _S909 = _S891 * make_float3 (_S888);
    Reservoir _S910 = withEnd(candidate_2, 3U, b_4, _S909);
    offer(sel_3, _S910, _S909 * make_float3 (scale_3) / make_float3 (density_1));
    return _S884;
}

static __device__ void restir_duplicates_0(uint3  global_invocation_id_1, uint3  local_invocation_id_0, uint local_invocation_index_3)
{
    uint2  _S911 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S912 = make_int2 ((int)_S911.x, (int)_S911.y);
    uint _S913 = previousSeed_0(_S912);
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
            uint _S914 = previousSeed_0(_S912 + make_int2 (x_17, y_5));
            bool _S915 = _S914 == _S913;
            uint _S916 = _slang_select(_S915, 1U,0U);
            uint count_4 = count_3 + _S916;
            int x_18 = x_17 + int(1);
            x_17 = x_18;
            count_3 = count_4;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S917 = float(count_3 - 1U) / 288.0f;
    bool _S918 = _S913 != 0U;
    float _S919 = _slang_select(_S918, _S917,0.0f);
    fcptStoreDuplication((_S912), (make_uint4 ((F32_asuint((_S919))), 0U, 0U, 0U)));
    return;
}

__device__ uint stream(uint seed_3, uint index_0)
{
    uint _S920 = hash(index_0);
    uint _S921 = hash(seed_3 ^ _S920);
    return _S921;
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

__device__ void offerShifted(Selection * sel_4, Reservoir r_5, Shift shifted_0, float mis_0)
{
    Reservoir candidate_3 = r_5;
    float3  _S922 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_3)->f = _S922;
    float _S923 = r_5.jac * shifted_0.jac;
    (&candidate_3)->jac = _S923;
    offer(sel_4, candidate_3, make_float3 (mis_0) * shifted_0.f * make_float3 (r_5.w));
    return;
}

__device__ Reservoir finalize(Selection sel_5, float c_1)
{
    Reservoir r_6 = sel_5.r;
    float _S924 = resamplingTarget((&r_6)->f);
    float _S925 = sel_5.w_sum / _S924;
    bool _S926 = _S924 > 0.0f;
    float _S927 = _slang_select(_S926, _S925,0.0f);
    (&r_6)->w = _S927;
    (&r_6)->c = c_1;
    return r_6;
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
    uint2  _S928 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S929 = make_int2 ((int)_S928.x, (int)_S928.y);
    float3  _S930 = make_float3 (0.0f);
    FKHit _S931 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S932 = Domain_x24init_0(_S930, _S930, &_S931, 0.0f, 0.0f);
    Domain dom_4 = _S932;
    bool _S933 = (fcptCurrentDomain((_S929), (&dom_4)));
    bool _S934 = !_S933;
    if(_S934)
    {
        Reservoir _S935 = (Reservoir{});
        fcptStoreReservoirPrevious((_S929), (_S935), ((&dom_4)->hit));
        return;
    }
    Reservoir _S936 = (fcptLoadReservoirTemporal((_S929)));
    uint t_15 = 0U;
    float count_5 = 0.0f;
    float c_sum_0 = _S936.c;
    for(;;)
    {
        uint _S937 = (fcptRestirNeighbours());
        if(t_15 < _S937)
        {
        }
        else
        {
            break;
        }
        int2  _S938 = partner_0(_S929, t_15);
        Domain neighbor_0 = _S932;
        bool _S939 = (fcptCurrentDomain((_S938), (&neighbor_0)));
        if(_S939)
        {
            float count_6 = count_5 + 1.0f;
            uint4  _S940 = (fcptReservoirTemporal((_S938), (0U)));
            float c_sum_1 = c_sum_0 + (U32_asfloat((_S940.w)));
            count_5 = count_6;
            c_sum_0 = c_sum_1;
        }
        uint t_16 = t_15 + 1U;
        t_15 = t_16;
    }
    float _S941 = _S936.c / (F32_max((count_5), (1.0f)));
    float _S942 = resamplingTarget(_S936.f);
    bool _S943 = count_5 == 0.0f;
    float _S944 = _slang_select(_S943, 1.0f,0.0f);
    Selection _S945 = (Selection{});
    Selection sel_6 = _S945;
    uint _S946 = (fcptFrame());
    uint _S947 = hash(_S946);
    uint _S948 = global_invocation_id_2.x;
    uint2  _S949 = (fcptRenderSize());
    uint _S950 = stream(_S947, _S948 + _S949.x * global_invocation_id_2.y);
    uint _S951 = stream(_S950, 195U);
    (&sel_6)->random_state = _S951;
    t_15 = 0U;
    float canonical_mis_0 = _S944;
    for(;;)
    {
        uint _S952 = (fcptRestirNeighbours());
        if(t_15 < _S952)
        {
        }
        else
        {
            break;
        }
        int2  _S953 = partner_0(_S929, t_15);
        Domain neighbor_dom_0 = _S932;
        bool _S954 = (fcptCurrentDomain((_S953), (&neighbor_dom_0)));
        if(_S954)
        {
            Reservoir _S955 = (fcptLoadReservoirTemporal((_S953)));
            uint4  _S956 = (fcptShiftData((_S953), (t_15)));
            float4  _S957 = asfloat_0(_S956);
            uint4  _S958 = (fcptShiftData((_S929), (t_15)));
            float4  _S959 = asfloat_0(_S958);
            float _S960 = (_S955.c + _S941) / c_sum_0;
            bool _S961 = _S942 > 0.0f;
            float canonical_mis_1;
            if(_S961)
            {
                float _S962 = _S960 * _S941 * _S942;
                float _S963 = _S941 * _S942;
                float _S964 = resamplingTarget(float3 {_S959.x, _S959.y, _S959.z});
                float canonical_mis_2 = canonical_mis_0 + _S962 / (_S963 + _S955.c * _S964);
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float _S965 = resamplingTarget(_S955.f);
            float3  _S966 = float3 {_S957.x, _S957.y, _S957.z};
            Shift _S967 = Shift_x24init_0(_S966, _S957.w);
            float _S968 = _S960 * _S955.c * _S965;
            float _S969 = _S955.c * _S965;
            float _S970 = resamplingTarget(_S966);
            offerShifted(&sel_6, _S955, _S967, _S968 / (_S969 + _S941 * _S970));
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_17 = t_15 + 1U;
        t_15 = t_17;
    }
    offerShifted(&sel_6, _S936, Shift_x24init_0(_S936.f, 1.0f), canonical_mis_0);
    Reservoir _S971 = finalize(sel_6, c_sum_0);
    fcptStoreReservoirPrevious((_S929), (_S971), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S929), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S929), (make_float4 ((&sel_6)->color.x, (&sel_6)->color.y, (&sel_6)->color.z, 0.0f)));
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
    uint _S972 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S973 = _S972 != 4294967295U;
    if(_S973)
    {
        uint2  _S974 = make_uint2 (_S972, _S972 >> 14U) & make_uint2 (16383U);
        int2  _S975 = make_int2 ((int)_S974.x, (int)_S974.y);
        ShiftJob _S976 = (ShiftJob{});
        ShiftJob shift_job_0 = _S976;
        Shift _S977 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S978 = _S972 >> 28U;
        bool _S979 = spatialJob_0(_S975, _S978, &shift_job_0, true);
        Shift shifted_1;
        if(_S979)
        {
            Domain _S980 = (&shift_job_0)->dom;
            Reservoir _S981 = (&shift_job_0)->r;
            Shift _S982 = passShift_0(&_S980, &_S981);
            shifted_1 = _S982;
        }
        else
        {
            shifted_1 = _S977;
        }
        fcptStoreShiftData((_S975), (_S978), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S983 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S984 = make_int2 ((int)_S983.x, (int)_S983.y);
    FixedArray<uint, 3>  _S985;
    spatialBins_0(_S984, &_S985);
    FixedArray<uint, 3>  _S986 = _S985;
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
        bool _S987 = (_S986[t_18]) == 40U;
        if(_S987)
        {
            fcptStoreShiftData((_S984), (t_18), (make_uint4 (0U)));
        }
        uint t_19 = t_18 + 1U;
        t_18 = t_19;
    }
    FixedArray<uint, 3>  _S988 = _S986;
    queueShifts_0(_S984, &_S988, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S989 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S990 = make_int2 ((int)_S989.x, (int)_S989.y);
    FixedArray<uint, 3>  _S991;
    spatialBins_0(_S990, &_S991);
    FixedArray<uint, 3>  _S992 = _S991;
    countShifts_0(&_S992, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S993 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S994 = _S993 != 4294967295U;
    if(_S994)
    {
        uint2  _S995 = make_uint2 (_S993, _S993 >> 14U) & make_uint2 (16383U);
        int2  _S996 = make_int2 ((int)_S995.x, (int)_S995.y);
        int2  _S997 = storedNeighbor_0(_S996);
        uint _S998 = _S993 >> 28U;
        Shift _S999 = temporalShiftAt_0(_S996, _S997, _S998);
        fcptStoreTemporalShift((_S996), (_S998), (make_uint4 (asuint_1(_S999.f).x, asuint_1(_S999.f).y, asuint_1(_S999.f).z, (F32_asuint((_S999.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S1000 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S1001 = make_int2 ((int)_S1000.x, (int)_S1000.y);
    FixedArray<uint, 3>  _S1002;
    temporalBins_0(_S1001, &_S1002);
    FixedArray<uint, 3>  _S1003 = _S1002;
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
        bool _S1004 = (_S1003[t_20]) == 40U;
        if(_S1004)
        {
            fcptStoreTemporalShift((_S1001), (t_20), (make_uint4 (0U)));
        }
        uint t_21 = t_20 + 1U;
        t_20 = t_21;
    }
    FixedArray<uint, 3>  _S1005 = _S1003;
    queueShifts_0(_S1001, &_S1005, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S1006 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S1007 = make_int2 ((int)_S1006.x, (int)_S1006.y);
    bool _S1008 = (fcptSceneUnchanged());
    bool _S1009 = !_S1008;
    bool _S1010;
    if(_S1009)
    {
        uint2  _S1011 = (fcptRenderSize());
        int2  _S1012 = make_int2 ((int)_S1011.x, (int)_S1011.y);
        _S1010 = all_0(_S1007 < _S1012);
    }
    else
    {
        _S1010 = false;
    }
    if(_S1010)
    {
        Reservoir _S1013 = (fcptLoadReservoirInitial((_S1007)));
        int2  _S1014 = sampleNeighbor_0(_S1007, _S1013.seed);
        fcptStoreTemporalNeighbor((_S1007), (_S1014));
    }
    FixedArray<uint, 3>  _S1015;
    temporalBins_0(_S1007, &_S1015);
    FixedArray<uint, 3>  _S1016 = _S1015;
    countShifts_0(&_S1016, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_10, float b_5, float t_22)
{
    return a_10 + (b_5 - a_10) * t_22;
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S1017 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S1018 = make_int2 ((int)_S1017.x, (int)_S1017.y);
    float3  _S1019 = make_float3 (0.0f);
    FKHit _S1020 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S1021 = Domain_x24init_0(_S1019, _S1019, &_S1020, 0.0f, 0.0f);
    Domain dom_5 = _S1021;
    bool _S1022 = (fcptCurrentDomain((_S1018), (&dom_5)));
    bool _S1023 = !_S1022;
    if(_S1023)
    {
        Reservoir _S1024 = (Reservoir{});
        fcptStoreReservoirTemporal((_S1018), (_S1024), ((&dom_5)->hit));
        return;
    }
    Reservoir _S1025 = (fcptLoadReservoirInitial((_S1018)));
    bool _S1026 = (fcptTemporalQueued());
    bool _S1027 = (fcptSceneUnchanged());
    bool _S1028;
    if(_S1027)
    {
        _S1028 = true;
    }
    else
    {
        _S1028 = !_S1026;
    }
    int2  _S1029;
    if(_S1028)
    {
        int2  _S1030 = sampleNeighbor_0(_S1018, _S1025.seed);
        _S1029 = _S1030;
    }
    else
    {
        int2  _S1031 = storedNeighbor_0(_S1018);
        _S1029 = _S1031;
    }
    bool _S1032 = (_S1029.x) >= int(0);
    Reservoir r_7;
    if(_S1032)
    {
        Reservoir _S1033 = (fcptLoadReservoirPrevious((_S1029)));
        uint4  _S1034 = (fcptDuplication((_S1029)));
        float _S1035 = (U32_asfloat((_S1034.x)));
        uint _S1036 = (fcptRestirDecorrelation());
        bool _S1037 = _S1036 == 1U;
        float _S1038 = _slang_select(_S1037, _S1035,0.0f);
        float _S1039 = interpolate_0(20.0f, 1.0f, (F32_pow((_S1038), (0.10000000149011612f))));
        float _S1040 = (F32_min((_S1033.c), (_S1039)));
        bool _S1041 = (fcptSceneUnchanged());
        float4  _S1042 = make_float4 (_S1033.f.x, _S1033.f.y, _S1033.f.z, 1.0f);
        bool _S1043 = !_S1041;
        if(_S1043)
        {
            _S1028 = _S1026;
        }
        else
        {
            _S1028 = false;
        }
        float4  to_current_0;
        if(_S1028)
        {
            uint4  _S1044 = (fcptTemporalShift((_S1018), (0U)));
            float4  _S1045 = asfloat_0(_S1044);
            to_current_0 = _S1045;
        }
        else
        {
            if(_S1043)
            {
                Shift _S1046 = temporalShiftAt_0(_S1018, _S1029, 0U);
                float4  _S1047 = make_float4 (_S1046.f.x, _S1046.f.y, _S1046.f.z, _S1046.jac);
                to_current_0 = _S1047;
            }
            else
            {
                to_current_0 = _S1042;
            }
        }
        Domain own_1 = _S1021;
        if(_S1041)
        {
            _S1028 = true;
        }
        else
        {
            bool _S1048 = (fcptPreviousScenes());
            bool _S1049 = !_S1048;
            if(_S1049)
            {
                _S1028 = (_S1025.w) > 0.0f;
            }
            else
            {
                _S1028 = false;
            }
            if(_S1028)
            {
                bool _S1050 = (fcptStoredDomainInitial((_S1018), (_S1025.seed), (&own_1)));
                _S1028 = _S1050;
            }
            else
            {
                _S1028 = false;
            }
            if(_S1028)
            {
                Domain _S1051 = (fcptPreviousDomain((_S1029), (_S1025.seed)));
                Domain _S1052 = _S1051;
                Domain _S1053 = own_1;
                bool _S1054 = sameDomain_0(&_S1052, &_S1053);
                _S1028 = _S1054;
            }
            else
            {
                _S1028 = false;
            }
        }
        float4  _S1055 = make_float4 (_S1025.f.x, _S1025.f.y, _S1025.f.z, 1.0f);
        bool _S1056 = !_S1028;
        if(_S1056)
        {
            _S1028 = _S1026;
        }
        else
        {
            _S1028 = false;
        }
        float4  to_previous_0;
        if(_S1028)
        {
            uint4  _S1057 = (fcptTemporalShift((_S1018), (1U)));
            float4  _S1058 = asfloat_0(_S1057);
            to_previous_0 = _S1058;
        }
        else
        {
            if(_S1056)
            {
                Shift _S1059 = temporalShiftAt_0(_S1018, _S1029, 1U);
                float4  _S1060 = make_float4 (_S1059.f.x, _S1059.f.y, _S1059.f.z, _S1059.jac);
                to_previous_0 = _S1060;
            }
            else
            {
                to_previous_0 = _S1055;
            }
        }
        float _S1061 = resamplingTarget(_S1025.f);
        float _S1062 = resamplingTarget(_S1033.f);
        Selection _S1063 = (Selection{});
        Selection sel_7 = _S1063;
        uint _S1064 = (fcptFrame());
        uint _S1065 = hash(_S1064);
        uint _S1066 = global_invocation_id_7.x;
        uint2  _S1067 = (fcptRenderSize());
        uint _S1068 = stream(_S1065, _S1066 + _S1067.x * global_invocation_id_7.y);
        uint _S1069 = stream(_S1068, 194U);
        (&sel_7)->random_state = _S1069;
        float _S1070 = _S1025.c * _S1061;
        float4  _S1071 = to_previous_0;
        float _S1072 = resamplingTarget(float3 {_S1071.x, _S1071.y, _S1071.z});
        float _S1073 = _S1070 / (_S1070 + _S1040 * _S1072);
        float _S1074 = _S1040 * _S1062;
        float4  _S1075 = to_current_0;
        float3  _S1076 = float3 {_S1075.x, _S1075.y, _S1075.z};
        float _S1077 = resamplingTarget(_S1076);
        float _S1078 = _S1074 / (_S1074 + _S1025.c * _S1077);
        float2  _S1079 = make_float2 (_S1073, _S1078);
        offerShifted(&sel_7, _S1025, Shift_x24init_0(_S1025.f, 1.0f), _S1073);
        offerShifted(&sel_7, _S1033, Shift_x24init_0(_S1076, to_current_0.w), _S1078);
        Reservoir _S1080 = finalize(sel_7, _S1025.c + _S1040);
        r_7 = _S1080;
    }
    else
    {
        r_7 = _S1025;
    }
    fcptStoreReservoirTemporal((_S1018), (r_7), ((&dom_5)->hit));
    return;
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S1081 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S1082 = make_int2 ((int)_S1081.x, (int)_S1081.y);
    float3  _S1083 = make_float3 (0.0f);
    float2  _S1084 = make_float2 (0.0f);
    FKHit _S1085 = Hit_x24init_0(_S1084, 0U, 0U, 0U, 0.0f);
    Domain _S1086 = Domain_x24init_0(_S1083, _S1083, &_S1085, 0.0f, 0.0f);
    Domain dom_6 = _S1086;
    bool _S1087 = (fcptCurrentDomain((_S1082), (&dom_6)));
    bool _S1088 = !_S1087;
    if(_S1088)
    {
        Reservoir _S1089 = (Reservoir{});
        fcptStoreReservoirInitial((_S1082), (_S1089), ((&dom_6)->hit));
        return;
    }
    uint _S1090 = (fcptFrame());
    uint _S1091 = hash(_S1090);
    uint _S1092 = global_invocation_id_8.x;
    uint2  _S1093 = (fcptRenderSize());
    uint _S1094 = global_invocation_id_8.y;
    uint _S1095 = stream(_S1091, _S1092 + _S1093.x * _S1094);
    uint2  _S1096 = (fcptRenderSize());
    uint _S1097 = stream(_S1092 + _S1096.x * _S1094, 512U);
    Selection _S1098 = (Selection{});
    Selection initial_0 = _S1098;
    uint _S1099 = stream(_S1095, 193U);
    (&initial_0)->random_state = _S1099;
    bool _S1100 = (fcptRestirUsed());
    bool _S1101 = !_S1100;
    (&initial_0)->sums = _S1101;
    uint _S1102 = stream(_S1095, 0U);
    (&(&initial_0)->r)->seed = _S1102;
    FKHit _S1103 = Hit_x24init_0(_S1084, 4294967295U, 0U, 0U, 0.0f);
    uint _S1104 = (fcptSamples());
    float _S1105 = 1.0f / float(_S1104);
    FKHit hit_2 = _S1103;
    uint i_20 = 0U;
    float3  seen_1 = _S1083;
    for(;;)
    {
        uint _S1106 = (fcptSamples());
        if(i_20 < _S1106)
        {
        }
        else
        {
            break;
        }
        Reservoir _S1107 = (Reservoir{});
        Reservoir r_8 = _S1107;
        uint _S1108 = stream(_S1095, i_20);
        (&r_8)->seed = _S1108;
        uint _S1109 = (fcptFrame());
        uint _S1110 = (fcptSamples());
        uint _S1111 = _S1109 * _S1110 + i_20;
        uint _S1112 = insertBits_0(0U, 1U, 24U, 1U);
        uint _S1113 = insertBits_0(_S1112, (_S1097 + _S1111 * 2654435769U) >> 25U, 25U, 7U);
        (&r_8)->path = _S1113;
        Domain path_0 = _S1086;
        bool _S1114 = (fcptStoredDomainInitial((_S1082), ((&r_8)->seed), (&path_0)));
        bool _S1115 = !_S1114;
        if(_S1115)
        {
            float3  _S1116 = (fcptMissed((_S1082), (path_0), (_S1105)));
            float3  seen_2 = seen_1 + _S1116;
            seen_1 = seen_2;
            uint i_21 = i_20 + 1U;
            i_20 = i_21;
            continue;
        }
        Domain _S1117 = path_0;
        Reservoir _S1118 = r_8;
        Shift _S1119 = passWalk_0(&_S1117, &_S1118, false, _S1105, &initial_0);
        bool _S1120 = ((&(&initial_0)->r)->seed) == ((&r_8)->seed);
        FKHit hit_3;
        if(_S1120)
        {
            FKHit _S1121 = (&path_0)->hit;
            hit_3 = _S1121;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_21 = i_20 + 1U;
        i_20 = i_21;
    }
    uint _S1122 = (fcptSamples());
    float3  seen_3 = seen_1 + (&initial_0)->glow / make_float3 (float(_S1122));
    float3  _S1123 = seen_3 + (&initial_0)->color;
    bool _S1124 = (&initial_0)->sums;
    float3  _S1125 = _slang_select(_S1124, _S1123,seen_3);
    fcptAddColor((_S1082), (make_float4 (_S1125.x, _S1125.y, _S1125.z, 1.0f)));
    Reservoir _S1126 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S1082), (_S1126), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_4, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S1127;
    (&_S1127)->none = none_0;
    (&_S1127)->pdf = pdf_4;
    (&_S1127)->origin = origin_5;
    (&_S1127)->smooth_n = smooth_n_3;
    (&_S1127)->start = start_6;
    return _S1127;
}

static __device__ Vertex Vertex_x24init_0(bool rough_0, uint lobe_1, float pdf_5, float cos_0, bool inside_0)
{
    Vertex _S1128;
    (&_S1128)->rough = rough_0;
    (&_S1128)->lobe = lobe_1;
    (&_S1128)->pdf = pdf_5;
    (&_S1128)->cos = cos_0;
    (&_S1128)->inside = inside_0;
    return _S1128;
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
    float3  _S1129 = exp_0((make_float3 (sigma_0) - extinction_0) * make_float3 (distance_2));
    float3  _S1130 = scatter_0 * _S1129 / make_float3 (sigma_0);
    float3  _S1131 = _slang_select(scatters_0, _S1130,_S1129);
    return _S1131;
}

static __device__ uint arrivalLobe_0(uint b_6, uint prev_lobe_0)
{
    bool _S1132 = b_6 > 0U;
    uint _S1133 = _slang_select(_S1132, prev_lobe_0,3U);
    return _S1133;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_2, uint lobe_2, bool surface_6, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S1134;
    (&_S1134)->extinction_behind = extinction_behind_0;
    (&_S1134)->extinction_front = extinction_front_0;
    (&_S1134)->fillings = fillings_0;
    (&_S1134)->side = side_0;
    (&_S1134)->depth = depth_2;
    (&_S1134)->lobe = lobe_2;
    (&_S1134)->surface = surface_6;
    (&_S1134)->length = length_2;
    (&_S1134)->width = width_1;
    (&_S1134)->own = *own_2;
    (&_S1134)->fiber = fiber_0;
    return _S1134;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S1135 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S1135)
    {
        return 0.07957746833562851f;
    }
    float _S1136 = g_0 * g_0;
    return (1.0f - _S1136) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S1136 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float survivalProbability(float3  throughput_1, float density_2)
{
    return (F32_min(((F32_max(((F32_max((throughput_1.x), ((F32_max((throughput_1.y), (throughput_1.z)))))) / density_2), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_10)
{
    Random _S1137 = pcg(random_state_10);
    Random _S1138 = pcg(_S1137.state);
    float _S1139 = 1.0f - 2.0f * _S1137.value;
    float _S1140 = (F32_sqrt(((F32_max((1.0f - _S1139 * _S1139), (0.0f))))));
    float _S1141 = 6.28318548202514648f * _S1138.value;
    return make_float3 (_S1140 * (F32_cos((_S1141))), _S1140 * (F32_sin((_S1141))), _S1139);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_12, uint random_state_11, float * pdf_6)
{
    bool _S1142 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1142)
    {
        *pdf_6 = 0.07957746833562851f;
        float3  _S1143 = isotropic_0(random_state_11);
        return _S1143;
    }
    Random _S1144 = pcg(random_state_11);
    Random _S1145 = pcg(_S1144.state);
    float _S1146 = g_1 * g_1;
    float _S1147 = 2.0f * g_1;
    float _S1148 = (1.0f - _S1146) / (1.0f - g_1 + _S1147 * _S1144.value);
    float _S1149 = clamp_1((1.0f + _S1146 - _S1148 * _S1148) / _S1147, -1.0f, 1.0f);
    float _S1150 = (F32_sqrt(((F32_max((1.0f - _S1149 * _S1149), (0.0f))))));
    float _S1151 = 6.28318548202514648f * _S1145.value;
    float _S1152 = phaseHG_0(g_1, _S1149);
    *pdf_6 = _S1152;
    float3  _S1153 = tangentToWorld(make_float3 (_S1150 * (F32_cos((_S1151))), _S1149, _S1150 * (F32_sin((_S1151)))), dir_12);
    float3  _S1154 = ((((_S1153)) * make_float3(rnorm3df(((_S1153)).x, ((_S1153)).y, ((_S1153)).z))));
    return _S1154;
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_1, float3  emissive_1, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_1, float velvet_0, float3  toon_2, float dispersion_0)
{
    BSDFMaterial _S1155;
    (&_S1155)->albedo = albedo_1;
    (&_S1155)->emissive = emissive_1;
    (&_S1155)->roughness = roughness_0;
    (&_S1155)->metallic = metallic_0;
    (&_S1155)->transmission = transmission_0;
    (&_S1155)->ior = ior_0;
    (&_S1155)->absorption = absorption_0;
    (&_S1155)->specular_tint = specular_tint_0;
    (&_S1155)->specular_level = specular_level_0;
    (&_S1155)->translucent = translucent_0;
    (&_S1155)->sheen = sheen_2;
    (&_S1155)->sheen_roughness = sheen_roughness_0;
    (&_S1155)->anisotropy = anisotropy_0;
    (&_S1155)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1155)->tangent = tangent_1;
    (&_S1155)->velvet = velvet_0;
    (&_S1155)->toon = toon_2;
    (&_S1155)->dispersion = dispersion_0;
    return _S1155;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1156;
    (&_S1156)->scatter = scatter_1;
    (&_S1156)->extinction = extinction_1;
    (&_S1156)->g = g_2;
    return _S1156;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_14, bool skip_0, uint random_state_12, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1157;
    (&_S1157)->smooth_n = smooth_n_4;
    (&_S1157)->geometry_n = geometry_n_2;
    (&_S1157)->geometry_offset = geometry_offset_2;
    (&_S1157)->material = *material_14;
    (&_S1157)->skip = skip_0;
    (&_S1157)->random_state = random_state_12;
    (&_S1157)->coverage = coverage_0;
    (&_S1157)->encloses = encloses_0;
    (&_S1157)->volume = *volume_0;
    (&_S1157)->fills = fills_0;
    (&_S1157)->hair = hair_0;
    return _S1157;
}

static __device__ FKSurface emitting_0(FKSurface * surface_7, bool top_0)
{
    FKSurface lower_0 = *surface_7;
    float3  _S1158 = (&surface_7->material)->emissive;
    float3  _S1159 = make_float3 (0.0f);
    bool _S1160 = !top_0;
    float3  _S1161 = _slang_select(_S1160, _S1159,_S1158);
    (&(&lower_0)->material)->emissive = _S1161;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_8, float u_1)
{
    float _S1162 = surface_8->coverage;
    bool _S1163 = u_1 < _S1162;
    if(_S1163)
    {
        return *surface_8;
    }
    float3  _S1164 = make_float3 (0.0f);
    float3  _S1165 = make_float3 (1.0f);
    BSDFMaterial _S1166 = Material_x24init_0(_S1164, _S1164, 0.0f, 0.0f, 0.0f, 0.0f, _S1164, _S1165, 1.0f, _S1164, _S1164, 0.5f, 0.0f, 0.0f, _S1164, 0.0f, _S1164, 0.0f);
    BSDFMaterial material_15 = _S1166;
    (&material_15)->albedo = _S1165;
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
    bool _S1167 = transmission_1 > 0.0f;
    bool _S1168;
    if(_S1167)
    {
        _S1168 = true;
    }
    else
    {
        _S1168 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1169 = _slang_select(_S1168, 1.0f,-1.0f);
    return _S1169;
}

static __device__ bool arrivesBehind_0(float3  dir_13, float3  n_9)
{
    return (dot_0(dir_13, n_9)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_9, float3  dir_14)
{
    float3  _S1170 = surface_9->geometry_n;
    float _S1171 = facingSign((&surface_9->material)->transmission, surface_9->geometry_n, dir_14);
    FKSurface faced_0 = *surface_9;
    float3  _S1172 = surface_9->smooth_n * make_float3 (_S1171);
    (&faced_0)->smooth_n = _S1172;
    float3  _S1173 = _S1170 * make_float3 (_S1171);
    (&faced_0)->geometry_n = _S1173;
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
    float3  _S1174 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1174));
}

__device__ bool dispersive(BSDFMaterial material_16)
{
    bool _S1175 = (material_16.dispersion) > 0.0f;
    bool _S1176;
    if(_S1175)
    {
        _S1176 = (material_16.ior) != 1.0f;
    }
    else
    {
        _S1176 = false;
    }
    return _S1176;
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
        uint _S1177 = (low_1 + high_1 + 1U) / 2U;
        bool _S1178 = (WAVELENGTH_CDF_0[_S1177]) <= u_2;
        if(_S1178)
        {
            low_1 = _S1177;
        }
        else
        {
            uint _S1179 = _S1177 - 1U;
            high_1 = _S1179;
        }
    }
    uint _S1180 = low_1;
    float _S1181 = WAVELENGTH_CDF_0[low_1 + 1U] - WAVELENGTH_CDF_0[low_1];
    return make_float2 (0.37999999523162842f + 0.00499999988824129f * (float(low_1) + (u_2 - WAVELENGTH_CDF_0[_S1180]) / _S1181), _S1181 / 0.00499999988824129f);
}

__device__ static const FixedArray<float, 243>  WAVELENGTH_WEIGHTS_0 = { {
    0.00547470012679696f, -0.00465690018609166f, 0.03257500007748604f, 0.00934640038758516f, -0.00796370021998882f, 0.05577300116419792f, 0.01846100017428398f, -0.01579399965703487f, 0.11072999984025955f, 0.0416410006582737f, -0.03577499836683273f, 0.2513900101184845f, 0.09349299967288971f, -0.08071800321340561f, 0.56742000579833984f, 0.1585099995136261f, -0.13764999806880951f, 0.97018998861312866f, 0.30943000316619873f, -0.27083000540733337f, 1.91740000247955322f, 0.55217999219894409f, -0.48754000663757324f, 3.46889996528625488f, 0.95016998052597046f, -0.84802001714706421f, 6.09439992904663086f, 1.42110002040863037f, -1.28929996490478516f, 9.45199966430664062f, 1.73409998416900635f, -1.6062999963760376f, 12.12800025939941406f, 2.08030009269714355f, -1.98810005187988281f, 15.68700027465820312f, 2.20600008964538574f, -2.20120000839233398f, 18.47699928283691406f, 2.03040003776550293f, -2.17700004577636719f, 19.92700004577636719f, 1.63429999351501465f, -2.00340008735656738f, 20.86899948120117188f, 0.99410998821258545f, -1.62629997730255127f, 20.57799911499023438f, 0.20011000335216522f, -1.11409997940063477f, 19.72100067138671875f, -0.67960000038146973f, -0.45403000712394714f, 17.77599906921386719f, -1.61679995059967041f, 0.37860000133514404f, 14.71500015258789062f, -2.53410005569458008f, 1.27540004253387451f, 11.86499977111816406f, -3.39079999923706055f, 2.2146000862121582f, 9.17669963836669922f, -4.03749990463256836f, 3.0522000789642334f, 6.59509992599487305f, -4.61299991607666016f, 3.89779996871948242f, 4.64589977264404297f, -5.43039989471435547f, 5.0121002197265625f, 3.3199000358581543f, -6.37769985198974609f, 6.33809995651245117f, 2.29699993133544922f, -7.44140005111694336f, 7.91739988327026367f, 1.45389997959136963f, -8.38580036163330078f, 9.60109996795654297f, 0.66465997695922852f, -9.0167999267578125f, 11.23999977111816406f, -0.04403600096702576f, -9.17749977111816406f, 12.63199996948242188f, -0.58126997947692871f, -8.97550010681152344f, 13.91499996185302734f, -0.95730000734329224f, -8.25290012359619141f, 14.86200046539306641f, -1.24430000782012939f, -6.92129993438720703f, 15.03899955749511719f, -1.43069994449615479f, -5.29169988632202148f, 14.90900039672851562f, -1.55149996280670166f, -3.43219995498657227f, 14.70499992370605469f, -1.63569998741149902f, -1.27190005779266357f, 14.24400043487548828f, -1.67030000686645508f, 1.15170001983642578f, 13.32199954986572266f, -1.636199951171875f, 3.73889994621276855f, 12.21199989318847656f, -1.56920003890991211f, 6.43590021133422852f, 10.94699954986572266f, -1.47730004787445068f, 9.16440010070800781f, 9.54769992828369141f, -1.36399996280670166f, 12.02000045776367188f, 8.18799972534179688f, -1.25450003147125244f, 14.78699970245361328f, 6.74429988861083984f, -1.13110005855560303f, 16.72299957275390625f, 5.08780002593994141f, -0.96561002731323242f, 18.14299964904785156f, 3.57019996643066406f, -0.80725997686386108f, 19.91900062561035156f, 2.36269998550415039f, -0.69273000955581665f, 21.05500030517578125f, 1.31369996070861816f, -0.58597999811172485f, 21.3899993896484375f, 0.42390000820159912f, -0.48298001289367676f, 20.99300003051757812f, -0.23857000470161438f, -0.39412000775337219f, 19.82200050354003906f, -0.6866300106048584f, -0.31501999497413635f, 18.12000083923339844f, -0.9412500262260437f, -0.24890999495983124f, 15.7089996337890625f, -1.02020001411437988f, -0.19076000154018402f, 13.19799995422363281f, -0.98919999599456787f, -0.14401000738143921f, 11.23999977111816406f, -0.93347001075744629f, -0.11133000254631042f, 9.36649990081787109f, -0.83820998668670654f, -0.08524099737405777f, 7.41249990463256836f, -0.70064002275466919f, -0.06283199787139893f, 5.71229982376098633f, -0.56079000234603882f, -0.04586699977517128f, 4.42280006408691406f, -0.44653001427650452f, -0.03396600112318993f, 3.34489989280700684f, -0.34457001090049744f, -0.02482499927282333f, 2.49309992790222168f, -0.26017999649047852f, -0.01808100007474422f, 1.82239997386932373f, -0.1921599954366684f, -0.01296999957412481f, 1.29499995708465576f, -0.13766999542713165f, -0.00907570030540228f, 0.92928999662399292f, -0.09956400096416473f, -0.00641620019450784f, 0.61835998296737671f, -0.06671299785375595f, -0.00421149982139468f, 0.40211999416351318f, -0.04354599863290787f, -0.00271830009296536f, 0.2844499945640564f, -0.03087200038135052f, -0.00191440002527088f, 0.20672999322414398f, -0.02246100082993507f, -0.00138829997740686f, 0.15044000744819641f, -0.01634499989449978f, -0.00101030000951141f, 0.10942000150680542f, -0.01188699994236231f, -0.0007347899954766f, 0.07099699974060059f, -0.00771349994465709f, -0.00047679000999779f, 0.04539500176906586f, -0.00493190018460155f, -0.00030484999297187f, 0.03424099832773209f, -0.00372010003775358f, -0.00022995000472292f, 0.02557599917054176f, -0.00277870008721948f, -0.00017175999528263f, 0.01842200011014938f, -0.00200140010565519f, -0.0001237099932041f, 0.01316899992525578f, -0.00143079995177686f, -0.00008843900286593f, 0.00838890019804239f, -0.00091141002485529f, -0.00005633700129692f, 0.00537079991772771f, -0.00058350997278467f, -0.00003606799873523f, 0.00328280008397996f, -0.00035665999166667f, -0.00002204600059486f, 0.00196009990759194f, -0.00021296000340953f, -0.00001316300040344f, 0.00168939994182438f, -0.00018354000349063f, -0.00001134499962063f, 0.00141050003003329f, -0.00015325000276789f, -0.00000947250009631f, 0.00097123999148607f, -0.00010551999730524f, -6.52239987175562419e-06f, 0.00066868000430986f, -0.00007264900341397f, -4.49060007667867467e-06f
} };
__device__ float3  wavelengthWeights(float wavelength_7)
{
    float _S1182 = clamp_1((wavelength_7 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    uint _S1183 = (U32_min((uint(_S1182)), (79U)));
    uint _S1184 = 3U * _S1183;
    float3  _S1185 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1184], WAVELENGTH_WEIGHTS_0[_S1184 + 1U], WAVELENGTH_WEIGHTS_0[_S1184 + 2U]);
    float3  _S1186 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1184 + 3U], WAVELENGTH_WEIGHTS_0[_S1184 + 4U], WAVELENGTH_WEIGHTS_0[_S1184 + 5U]);
    return _S1185 + (_S1186 - _S1185) * make_float3 (_S1182 - float(_S1183));
}

__device__ float dispersedIor(float ior_1, float dispersion_1, float wavelength_8)
{
    float _S1187 = (ior_1 - 1.0f) * dispersion_1 / 1.90962409973144531f;
    float _S1188 = _S1187 * (1.0f / (wavelength_8 * wavelength_8) - 2.89662933349609375f);
    bool _S1189 = dispersion_1 > 0.0f;
    float _S1190 = _slang_select(_S1189, _S1188,0.0f);
    return ior_1 + _S1190;
}

__device__ float2  vertexEta(BSDFMaterial material_17, float n_dot_v_0)
{
    bool _S1191 = n_dot_v_0 < 0.0f;
    float _S1192 = _slang_select(_S1191, material_17.ior,1.0f);
    float _S1193 = _slang_select(_S1191, 1.0f,material_17.ior);
    return make_float2 (_S1192, _S1193);
}

__device__ float2  wavelengthEta(BSDFMaterial material_18, float n_dot_v_1, float wavelength_9)
{
    BSDFMaterial refractive_0 = material_18;
    float _S1194 = dispersedIor(material_18.ior, material_18.dispersion, wavelength_9);
    bool _S1195 = wavelength_9 > 0.0f;
    float _S1196 = _slang_select(_S1195, _S1194,material_18.ior);
    (&refractive_0)->ior = _S1196;
    float2  _S1197 = vertexEta(refractive_0, n_dot_v_1);
    return _S1197;
}

__device__ bool neeDecision(BSDFMaterial material_19, float n_dot_v_2, float eta_i_5, float eta_o_5)
{
    float _S1198 = fresnel((F32_abs((n_dot_v_2))), eta_i_5, eta_o_5);
    float3  _S1199 = mix_0(make_float3 (_S1198), material_19.albedo, material_19.metallic);
    float _S1200 = rgb_to_greyscale(_S1199);
    float _S1201 = (F32_max(((1.0f - _S1200) * (1.0f - material_19.metallic) * (1.0f - material_19.transmission)), (0.0f)));
    bool _S1202 = _S1201 > 0.03999999910593033f;
    bool _S1203;
    if(_S1202)
    {
        _S1203 = true;
    }
    else
    {
        _S1203 = (material_19.roughness) > 0.20000000298023224f;
    }
    return _S1203;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_20)
{
    float _S1204 = rgb_to_greyscale(material_20->translucent);
    return _S1204 > 0.0f;
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
    MediumSides _S1205;
    (&_S1205)->behind = *behind_0;
    (&_S1205)->front = *front_0;
    (&_S1205)->fillings = fillings_1;
    (&_S1205)->face = face_1;
    return _S1205;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_10, FKMedium * medium_0, uint filling_0, float3  dir_15, FKMedium * outside_0)
{
    float3  _S1206 = surface_10->geometry_n;
    MediumSides _S1207 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_10->geometry_n);
    MediumSides sides_0 = _S1207;
    bool _S1208 = surface_10->encloses;
    if(_S1208)
    {
        (&sides_0)->behind = surface_10->volume;
        *&((&(&sides_0)->fillings)->x) = surface_10->fills;
        bool _S1209 = (dot_0(dir_15, _S1206)) > 0.0f;
        if(_S1209)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_11, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_16, uint depth_3, uint lobe_3, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1210 = surface_11->geometry_n;
    ShadowContext _S1211 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_11->geometry_n, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
    bool _S1212 = surface_11->encloses;
    ShadowContext context_4;
    if(_S1212)
    {
        FKSurface faced_1 = *surface_11;
        float3  _S1213 = - _S1210;
        float3  _S1214 = _slang_select(turned_0, _S1213,_S1210);
        (&faced_1)->geometry_n = _S1214;
        FKMedium _S1215 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1216 = faced_1;
        FKMedium _S1217 = _S1215;
        MediumSides _S1218 = mediumSides_0(&_S1216, &_S1217, filling_1, dir_16, outside_1);
        ShadowContext _S1219 = ShadowContext_x24init_0(_S1218.behind.extinction, _S1218.front.extinction, _S1218.fillings, _S1210, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
        if(turned_0)
        {
            uint2  _S1220 = _S1218.fillings;
            ShadowContext _S1221 = ShadowContext_x24init_0(_S1218.front.extinction, _S1218.behind.extinction, uint2 {_S1220.y, _S1220.x}, _S1210, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
            context_4 = _S1221;
        }
        else
        {
            context_4 = _S1219;
        }
    }
    else
    {
        context_4 = _S1211;
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
    float3  _S1222 = light_2->dir;
    bool _S1223 = (dot_0(geometry_n_3, - in_dir_8) * dot_0(geometry_n_3, light_2->dir)) <= 0.0f;
    FixedArray<float3 , 5>  throughputs_1;
    FixedArray<float, 5>  pdfs_4;
    float3  _S1224 = BSDF(in_dir_8, _S1222, smooth_n_5, *material_21, eta_i_6, eta_o_6, _S1223, random_state_13, &throughputs_1, &pdfs_4);
    bool _S1225 = !competing_1;
    bool _S1226;
    if(_S1225)
    {
        _S1226 = true;
    }
    else
    {
        _S1226 = (light_2->density) == 0.0f;
    }
    if(_S1226)
    {
        return _S1224 * light_2->radiance;
    }
    float3  _S1227 = make_float3 (0.0f);
    uint i_26 = 0U;
    float3  weighted_0 = _S1227;
    for(;;)
    {
        if(i_26 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S1228 = (pdfs_4[i_26]) > 0.0f;
        if(_S1228)
        {
            float _S1229 = light_2->density;
            float _S1230 = pdfs_4[i_26] / light_2->density;
            float3  weighted_1 = weighted_0 + throughputs_1[i_26] * make_float3 (pdfs_4[i_26]) / make_float3 (_S1229 * (1.0f + _S1230 * _S1230));
            weighted_0 = weighted_1;
        }
        uint i_27 = i_26 + 1U;
        i_26 = i_27;
    }
    return weighted_0 * light_2->radiance * make_float3 (light_2->density);
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_2, uint random_state_14, bool refracted_3, uint lobe_4, float pdf_7)
{
    SampleBSDF _S1231;
    (&_S1231)->unit_direction = unit_direction_1;
    (&_S1231)->throughput = throughput_2;
    (&_S1231)->random_state = random_state_14;
    (&_S1231)->refracted = refracted_3;
    (&_S1231)->lobe = lobe_4;
    (&_S1231)->pdf = pdf_7;
    return _S1231;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  v_9, float3  n_i_13, float n_i_dot_v_3, BSDFMaterial material_22, Weights w_14, uint random_state_15)
{
    float3  _S1232 = make_float3 (1.0f);
    SampleBSDF _S1233 = SampleBSDF_x24init_0(_S1232, _S1232, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S1233;
    Random _S1234 = pcg(random_state_15);
    Random _S1235 = pcg(_S1234.state);
    (&sample_1)->random_state = _S1235.state;
    float _S1236 = _S1234.value;
    float _S1237 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1236 * _S1236))))));
    float _S1238 = 6.28318548202514648f * _S1235.value;
    float3  _S1239 = tangentToWorld(make_float3 (_S1237 * (F32_cos((_S1238))), _S1234.value, _S1237 * (F32_sin((_S1238)))), n_i_13);
    (&sample_1)->unit_direction = _S1239;
    (&sample_1)->lobe = 4U;
    float3  _S1240 = sheenVelvetBSDF((&sample_1)->unit_direction, v_9, n_i_13, material_22, w_14);
    (&sample_1)->throughput = _S1240;
    float _S1241 = sheenVelvetPDF(_S1234.value, n_i_dot_v_3, w_14);
    (&sample_1)->pdf = _S1241;
    return sample_1;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1242 = (F32_sqrt((random_1_0)));
    float _S1243 = 6.28318548202514648f * random_2_0;
    float _S1244 = _S1242 * (F32_cos((_S1243)));
    float _S1245 = _S1242 * (F32_sin((_S1243)));
    float _S1246 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1244 * _S1244 - _S1245 * _S1245))))));
    return make_float3 (_S1244, _S1246, _S1245);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_3, float3  n_i_14, float n_i_dot_v_4, BSDFMaterial material_23, Weights w_15, uint random_state_16)
{
    float3  _S1247 = make_float3 (1.0f);
    SampleBSDF _S1248 = SampleBSDF_x24init_0(_S1247, _S1247, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S1248;
    Random _S1249 = pcg(random_state_16);
    Random _S1250 = pcg(_S1249.state);
    (&sample_2)->random_state = _S1250.state;
    float3  _S1251 = sampleCosWeightedHemisphere(_S1249.value, _S1250.value);
    float _S1252 = translucentShare(material_23);
    bool _S1253 = u_3 < (w_15.p_diffuse * _S1252);
    float _S1254 = _S1251.y;
    float _S1255 = - _S1254;
    float _S1256 = _slang_select(_S1253, _S1255,_S1254);
    float3  _S1257 = tangentToWorld(make_float3 (_S1251.x, _S1256, _S1251.z), n_i_14);
    (&sample_2)->unit_direction = _S1257;
    (&sample_2)->refracted = _S1253;
    (&sample_2)->lobe = 0U;
    float3  _S1258 = diffuseBSDF((&sample_2)->unit_direction, n_i_14, material_23, w_15);
    (&sample_2)->throughput = _S1258;
    float _S1259 = diffusePDF(_S1256, n_i_dot_v_4, material_23, w_15);
    (&sample_2)->pdf = _S1259;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF toonSample(float3  n_i_15, ToonProfile profile_3, Weights w_16, uint random_state_17)
{
    float3  _S1260 = make_float3 (1.0f);
    Random _S1261 = pcg(random_state_17);
    Random _S1262 = pcg(_S1261.state);
    float _S1263 = _S1261.value * profile_3.norm / 6.28318548202514648f;
    float _S1264 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1263)))), (1.0f))))));
    float _S1265 = (F32_acos((clamp_1(1.0f - _S1263, -1.0f, 1.0f))));
    float _S1266 = _slang_select(profile_3.glossy, _S1265,_S1264);
    float _S1267 = (profile_3.a + profile_3.b) / 2.0f;
    bool _S1268 = _S1266 < (profile_3.a);
    float _S1269 = _slang_select(_S1268, _S1266,_S1267);
    float t_23 = _S1269;
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
        float _S1270 = toonP(t_23, profile_3.a, profile_3.s);
        float _S1271 = _S1270 * (F32_sin((t_23)));
        float _S1272 = (F32_cos((t_23)));
        float _S1273 = _slang_select(profile_3.glossy, 1.0f,_S1272);
        float _S1274 = _S1271 * _S1273;
        float _S1275 = toonIntegral(t_23, profile_3.a, profile_3.s, profile_3.glossy);
        float _S1276 = (_S1275 - _S1263) / _S1274;
        bool _S1277 = _S1274 > 0.0f;
        float _S1278 = _slang_select(_S1277, _S1276,0.0f);
        float _S1279 = clamp_1(t_23 - _S1278, 0.0f, profile_3.b);
        int k_1 = k_0 + int(1);
        t_23 = _S1279;
        k_0 = k_1;
    }
    float _S1280 = 6.28318548202514648f * _S1262.value;
    float _S1281 = (F32_sin((t_23)));
    float3  _S1282 = tangentToWorld(make_float3 (_S1281 * (F32_cos((_S1280))), (F32_cos((t_23))), _S1281 * (F32_sin((_S1280)))), profile_3.axis);
    float3  _S1283 = toonBSDF(_S1282, n_i_15, profile_3, w_16);
    bool _S1284 = (dot_0(n_i_15, _S1282)) < 0.0f;
    float _S1285 = toonPDF(_S1282, n_i_15, profile_3, w_16);
    return SampleBSDF_x24init_0(_S1282, _S1283, _S1262.state, _S1284, 6U, _S1285);
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_16, float alpha_8, AnisotropicFrame frame_6, BSDFMaterial material_24, Weights w_17, float pdf_h_3, float eta_i_7, float eta_o_7, uint random_state_18)
{
    float3  _S1286 = make_float3 (1.0f);
    SampleBSDF _S1287 = SampleBSDF_x24init_0(_S1286, _S1286, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S1287;
    (&sample_3)->unit_direction = w_17.refracted;
    (&sample_3)->random_state = random_state_18;
    (&sample_3)->refracted = true;
    (&sample_3)->lobe = 1U;
    float3  _S1288 = refractBSDF((&sample_3)->unit_direction, n_i_16, alpha_8, frame_6, material_24, w_17);
    (&sample_3)->throughput = _S1288;
    float _S1289 = refractPDF(dot_0((&sample_3)->unit_direction, ggx_n_3), pdf_h_3, w_17, eta_i_7, eta_o_7);
    (&sample_3)->pdf = _S1289;
    return sample_3;
}

static __device__ float3  reflect_0(float3  i_28, float3  n_10)
{
    return i_28 - make_float3 (2.0f * dot_0(n_10, i_28)) * n_10;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_9, float3  ggx_n_4, float3  n_i_17, float alpha_9, AnisotropicFrame frame_7, Weights w_18, float pdf_h_4, uint random_state_19)
{
    float3  _S1290 = make_float3 (1.0f);
    SampleBSDF _S1291 = SampleBSDF_x24init_0(_S1290, _S1290, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S1291;
    float3  _S1292 = reflect_0(in_dir_9, ggx_n_4);
    float3  _S1293 = ((((_S1292)) * make_float3(rnorm3df(((_S1292)).x, ((_S1292)).y, ((_S1292)).z))));
    (&sample_4)->unit_direction = _S1293;
    (&sample_4)->random_state = random_state_19;
    (&sample_4)->lobe = 2U;
    float3  _S1294 = reflectBSDF((&sample_4)->unit_direction, n_i_17, alpha_9, frame_7, w_18);
    (&sample_4)->throughput = _S1294;
    float _S1295 = reflectPDF(pdf_h_4, w_18);
    (&sample_4)->pdf = _S1295;
    return sample_4;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_10, float3  n_11, BSDFMaterial material_25, float eta_i_8, float eta_o_8, uint random_init_0, float2  screen_space_0)
{
    uint random_state_20 = random_init_0;
    float3  _S1296 = negate_0(in_dir_10);
    float _S1297 = dot_0(n_11, _S1296);
    float _S1298 = sign_0(_S1297);
    float3  n_i_18 = n_11 * make_float3 (_S1298);
    float _S1299 = (F32_abs((_S1297)));
    float _S1300 = material_25.roughness;
    float _S1301 = _S1300 * _S1300;
    AnisotropicFrame _S1302 = anisotropicFrame(material_25, n_i_18);
    SheenProfile _S1303 = sheenProfile(_S1296, n_i_18, material_25);
    float3  _S1304 = sampleHalfVector(_S1296, n_i_18, _S1301, _S1302, &random_state_20);
    Weights _S1305 = lobeWeights(in_dir_10, _S1296, n_i_18, _S1304, _S1302, _S1303, material_25, eta_i_8, eta_o_8);
    Random _S1306 = pcg(random_state_20);
    random_state_20 = _S1306.state;
    bool _S1307 = (_S1306.value) < (_S1305.p_sheen_velvet);
    if(_S1307)
    {
        SampleBSDF _S1308 = sheenVelvetSample(_S1296, n_i_18, _S1299, material_25, _S1305, random_state_20);
        return _S1308;
    }
    float _S1309 = _S1306.value - _S1305.p_sheen_velvet;
    bool _S1310 = _S1309 < (_S1305.p_diffuse);
    if(_S1310)
    {
        SampleBSDF _S1311 = diffuseSample(_S1309, n_i_18, _S1299, material_25, _S1305, random_state_20);
        return _S1311;
    }
    bool _S1312 = _S1309 < (_S1305.p_diffuse + _S1305.p_toon);
    if(_S1312)
    {
        ToonProfile _S1313 = toonProfile(_S1296, n_i_18, material_25);
        SampleBSDF _S1314 = toonSample(n_i_18, _S1313, _S1305, random_state_20);
        return _S1314;
    }
    float _S1315 = vndfPDF(_S1296, _S1304, n_i_18, _S1299, _S1301, _S1302, _S1305.v_dot_h);
    bool _S1316 = (_S1309 - _S1305.p_toon) < (_S1305.p_diffuse + _S1305.p_refract);
    if(_S1316)
    {
        SampleBSDF _S1317 = refractSample(_S1304, n_i_18, _S1301, _S1302, material_25, _S1305, _S1315, eta_i_8, eta_o_8, random_state_20);
        return _S1317;
    }
    SampleBSDF _S1318 = reflectSample(in_dir_10, _S1304, n_i_18, _S1301, _S1302, _S1305, _S1315, random_state_20);
    return _S1318;
}

static __device__ bool boundsVolume_0(FKSurface * surface_12)
{
    return surface_12->encloses;
}

static __device__ Shift walk_0(Domain * dom_7, Reservoir * r_9, bool replay_2, float scale_4, Selection * sel_8)
{
    float spread_1;
    bool turned_1;
    bool is_inside_6;
    bool viewed_0;
    bool _S1319;
    bool _S1320;
    float density_3;
    float wavelength_10;
    float width_3;
    float sky_pdf_1;
    float threshold_0;
    uint b_7;
    uint layer_0;
    float3  throughput_3;
    float3  spectral_weight_1;
    TreeSample light_3;
    int _S1321;
    Shift ended_0;
    float density_4;
    float spread_2;
    float width_4;
    float sky_pdf_2;
    float spread_3;
    float width_5;
    uint b_8;
    float3  _S1322 = make_float3 (0.0f);
    Shift _S1323 = Shift_x24init_0(_S1322, 0.0f);
    uint _S1324 = r_9->path;
    uint _S1325 = extractBits_0(r_9->path, 0U, 5U);
    uint _S1326 = extractBits_0(_S1324, 5U, 5U);
    uint _S1327 = extractBits_0(_S1324, 10U, 2U);
    uint _S1328 = extractBits_0(_S1324, 12U, 3U);
    bool passes_0;
    if(replay_2)
    {
        bool _S1329 = _S1328 >= 3U;
        uint _S1330 = _slang_select(_S1329, 1U,0U);
        uint _S1331 = _S1325 + _S1330;
        uint _S1332 = (fcptMaxBounces());
        passes_0 = _S1331 > _S1332;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1323;
    }
    uint _S1333 = _S1326 - 1U;
    bool _S1334 = _S1328 == 3U;
    uint _S1335 = _slang_select(_S1334, 1U,0U);
    uint _S1336 = _S1325 + _S1335;
    bool _S1337 = _S1327 == 0U;
    uint _S1338 = _slang_select(_S1337, _S1336,_S1333);
    FKHit _S1339 = (fcptReservoirHit((*r_9)));
    float3  _S1340 = dom_7->x0;
    float3  _S1341 = dom_7->x1 - dom_7->x0;
    float3  _S1342 = ((((_S1341)) * make_float3(rnorm3df(((_S1341)).x, ((_S1341)).y, ((_S1341)).z))));
    FKRay _S1343 = Ray_x24init_0(dom_7->x1, _S1342);
    FKRay ray_3 = _S1343;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1322;
    float3  throughput_4 = make_float3 (1.0f);
    float3  weight_2 = throughput_4;
    float3  glowed_0 = _S1322;
    float3  extinction_in_0 = _S1322;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1344 = dom_7->spread;
    float _S1345 = dom_7->width;
    float _S1346 = length_0(_S1341);
    NEEVertex _S1347 = NEEVertex_x24init_0(true, 0.0f, _S1322, _S1322, _S1322);
    NEEVertex nee_vertex_1 = _S1347;
    Vertex _S1348 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_1 = _S1348;
    Reservoir _S1349 = (Reservoir{});
    Reservoir chain_1 = _S1349;
    uint _S1350 = r_9->seed;
    (&chain_1)->seed = r_9->seed;
    uint _S1351 = extractBits_0(_S1324, 24U, 8U);
    uint _S1352 = insertBits_0(0U, _S1351, 24U, 8U);
    (&chain_1)->path = _S1352;
    (&ray_3)->origin = _S1340;
    (&hit_4)->distance = _S1346;
    FKMedium _S1353 = (fcptCameraMedium(((&ray_3)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1354 = filling_2;
    bool _S1355 = (fcptVaryingUsed());
    uint _S1356 = _slang_select(_S1355, _S1354,4294967295U);
    filling_2 = _S1356;
    scatter_in_0 = _S1353.scatter;
    extinction_in_0 = _S1353.extinction;
    g_in_0 = _S1353.g;
    Reservoir _S1357 = chain_1;
    uint _S1358 = filling_2;
    for(;;)
    {
        bool _S1359 = (fcptVaryingUsed());
        if(_S1359)
        {
            passes_0 = _S1358 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1360 = (fcptMajorant((_S1358)));
            spread_1 = _S1360;
        }
        else
        {
            spread_1 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_2)
        {
            turned_1 = 4294967295U == _S1338;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1327 == 1U;
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
            ended_0 = _S1323;
            sky_pdf_1 = 0.0f;
            spread_1 = _S1344;
            width_3 = _S1345;
            density_3 = 1.0f;
            throughput_3 = throughput_4;
            b_7 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1361 = (&prev_1)->rough;
        if(_S1361)
        {
            turned_1 = !(spread_1 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_1)->rough = turned_1;
        uint _S1362 = stream(_S1350, 384U);
        uint tracking_0 = _S1362;
        weight_2 = throughput_4;
        glowed_0 = _S1322;
        b_7 = 4294967295U;
        throughput_3 = throughput_4;
        density_3 = 1.0f;
        wavelength_10 = _S1344;
        width_3 = _S1345;
        sky_pdf_1 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1321 = int(1);
                break;
            }
            uint _S1363 = b_7 + 320U;
            bool _S1364 = b_7 == 4294967295U;
            uint _S1365 = _slang_select(_S1364, 384U,_S1363);
            uint _S1366 = stream(_S1350, _S1365);
            Random _S1367 = pcg(_S1366);
            float _S1368 = - (F32_log((1.0f - _S1367.value))) / spread_1;
            if(passes_0)
            {
                float3  _S1369 = (&ray_3)->origin;
                float3  _S1370 = (&ray_3)->unit_direction;
                float _S1371 = (&hit_4)->distance;
                uint _S1372 = _slang_select(_S1364, 0U,b_7);
                uint _S1373 = (&prev_1)->lobe;
                uint _S1374 = _slang_select(_S1364, 3U,_S1373);
                float _S1375 = (fcptTrackMedium((_S1358), (_S1369), (_S1370), (_S1371), (&tracking_0), (&weight_2), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1372), (_S1374), (_S1364)));
                threshold_0 = _S1375;
            }
            else
            {
                threshold_0 = _S1368;
            }
            bool _S1376 = !(threshold_0 < ((&hit_4)->distance));
            if(_S1376)
            {
                _S1321 = int(1);
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
                float3  _S1377 = pathColor(throughput_3 * glowed_0, throughput_4, 0.0f);
                float3  _S1378 = _S1377 / make_float3 (density_3);
                float3  _S1379 = sel_8->glow + _S1378;
                sel_8->glow = _S1379;
            }
            else
            {
            }
            glowed_0 = _S1322;
            uint b_9 = b_7 + 1U;
            float3  _S1380 = (&ray_3)->origin + make_float3 (threshold_0) * (&ray_3)->unit_direction;
            (&ray_3)->origin = _S1380;
            float3  _S1381 = flightWeight_0(scatter_in_0, extinction_in_0, spread_1, threshold_0, true);
            float3  _S1382 = weight_2;
            float _S1383 = upsample(weight_2, 0.0f);
            float3  _S1384 = make_float3 (_S1383);
            float3  _S1385 = _slang_select(false, _S1384,_S1382);
            float3  _S1386 = _slang_select(passes_0, _S1385,_S1381);
            float3  throughput_5 = throughput_3 * _S1386;
            uint _S1387 = stream(_S1350, b_9 + 320U);
            tracking_0 = _S1387;
            weight_2 = throughput_4;
            float width_6 = width_3 + wavelength_10 * threshold_0;
            float _S1388 = wavelength_10 + 3.14159274101257324f;
            bool _S1389 = !replay_2;
            if(_S1389)
            {
                is_inside_6 = true;
            }
            else
            {
                bool _S1390 = b_9 == _S1338;
                if(_S1390)
                {
                    is_inside_6 = !passes_0;
                }
                else
                {
                    is_inside_6 = false;
                }
            }
            TreeSample _S1391 = TreeSample_x24init_0(_S1322, _S1322, 0.0f, 0U);
            if(is_inside_6)
            {
                float3  _S1392 = (&ray_3)->origin;
                float3  _S1393 = (&ray_3)->unit_direction;
                float3  _S1394 = (&ray_3)->unit_direction;
                uint _S1395 = stream(_S1350, b_9 + 64U);
                float3  _S1396 = extinction_in_0;
                float3  _S1397 = extinction_in_0;
                uint2  _S1398 = make_uint2 (_S1358);
                float3  _S1399 = (&ray_3)->unit_direction;
                uint _S1400 = arrivalLobe_0(b_9, (&prev_1)->lobe);
                FKHit _S1401 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1402 = _S1401;
                ShadowContext _S1403 = ShadowContext_x24init_0(_S1396, _S1397, _S1398, _S1399, b_9, _S1400, false, threshold_0, width_6, &_S1402, false);
                ShadowContext _S1404 = _S1403;
                TreeSample _S1405 = sampleLightTree_0(_S1392, _S1393, _S1394, 0.0f, true, _S1395, &_S1404);
                light_3 = _S1405;
            }
            else
            {
                light_3 = _S1391;
            }
            float _S1406 = phaseHG_0(g_in_0, dot_0((&ray_3)->unit_direction, light_3.dir));
            uint _S1407 = (fcptMaxBounces());
            bool _S1408 = b_9 < _S1407;
            if(_S1408)
            {
                viewed_0 = (light_3.density) > 0.0f;
            }
            else
            {
                viewed_0 = false;
            }
            float _S1409 = _slang_select(viewed_0, _S1406,0.0f);
            float3  _S1410 = throughput_5 * light_3.radiance;
            float _S1411 = powerHeuristic(light_3.density, _S1409);
            float3  _S1412 = pathColor(_S1410 * make_float3 (_S1406 * _S1411), throughput_4, 0.0f);
            float3  _S1413 = _slang_select(is_inside_6, _S1412,_S1322);
            if(replay_2)
            {
                _S1319 = b_9 == _S1338;
            }
            else
            {
                _S1319 = false;
            }
            if(_S1319)
            {
                bool _S1414 = _S1327 == 2U;
                if(_S1414)
                {
                    float _S1415 = resamplingTarget(_S1413);
                    passes_0 = _S1415 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1416 = Shift_x24init_0(_S1413, 1.0f);
                    _S1321 = int(0);
                    ended_0 = _S1416;
                    spread_1 = _S1388;
                    threshold_0 = width_6;
                    spectral_weight_1 = throughput_5;
                    layer_0 = b_9;
                    break;
                }
                _S1321 = int(0);
                ended_0 = _S1323;
                spread_1 = _S1388;
                threshold_0 = width_6;
                spectral_weight_1 = throughput_5;
                layer_0 = b_9;
                break;
            }
            if(_S1389)
            {
                Reservoir candidate_4 = _S1357;
                uint _S1417 = extractBits_0(_S1357.path, 24U, 8U);
                uint _S1418 = insertBits_0(0U, _S1417, 24U, 8U);
                uint _S1419 = extractBits_0(_S1357.path, 10U, 2U);
                bool _S1420 = _S1419 == 1U;
                if(_S1420)
                {
                    float3  _S1421 = safeDivide(_S1413, _S1322);
                    (&candidate_4)->radiance = _S1421;
                }
                else
                {
                    uint _S1422 = insertBits_0(_S1418, b_9 + 1U, 5U, 5U);
                    uint _S1423 = insertBits_0(_S1422, 2U, 10U, 2U);
                    (&candidate_4)->path = _S1423;
                }
                Reservoir _S1424 = withEnd(candidate_4, 0U, b_9, _S1413);
                offer(sel_8, _S1424, _S1413 * make_float3 (scale_4) / make_float3 (density_3));
                float _S1425 = survivalProbability(abs_0(throughput_5), density_3);
                uint _S1426 = stream(_S1350, b_9 + 128U);
                Random _S1427 = pcg(_S1426);
                bool _S1428 = _S1425 < (_S1427.value);
                if(_S1428)
                {
                    _S1320 = true;
                }
                else
                {
                    uint _S1429 = (fcptMaxBounces());
                    _S1320 = b_9 >= _S1429;
                }
                if(_S1320)
                {
                    _S1321 = int(0);
                    ended_0 = _S1323;
                    spread_1 = _S1388;
                    threshold_0 = width_6;
                    spectral_weight_1 = throughput_5;
                    layer_0 = b_9;
                    break;
                }
                float _S1430 = density_3 * _S1425;
                density_3 = _S1430;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1431 = stream(_S1350, b_9);
            float3  _S1432 = samplePhase_0(g_in_0, (&ray_3)->unit_direction, _S1431, &phase_pdf_0);
            (&ray_3)->unit_direction = _S1432;
            NEEVertex _S1433 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_3)->origin, _S1322, (&ray_3)->origin);
            nee_vertex_1 = _S1433;
            Vertex _S1434 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, false);
            prev_1 = _S1434;
            float _S1435 = (&prev_1)->pdf;
            FKRay _S1436 = ray_3;
            FKHit _S1437 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1438 = (fcptTraverseInstanceBVH((_S1436), (true), (4.294967296e+09f), (false), (_S1437), (false)));
            hit_4 = _S1438;
            b_7 = b_9;
            throughput_3 = throughput_5;
            wavelength_10 = _S1388;
            width_3 = width_6;
            sky_pdf_1 = _S1435;
        }
        if(_S1321 != int(1))
        {
            width_3 = threshold_0;
            throughput_3 = spectral_weight_1;
            b_7 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1323;
        spread_1 = wavelength_10;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1439 = b_7 == 4294967295U;
    bool _S1440 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1440)
    {
        Reservoir _S1441 = chain_1;
        FKRay _S1442 = ray_3;
        Vertex _S1443 = prev_1;
        NEEVertex _S1444 = nee_vertex_1;
        Shift _S1445 = escape_0(r_9, replay_2, _S1338, _S1327, _S1325, _S1328, scale_4, _S1352, &_S1441, _S1322, b_7, &_S1442, throughput_3, density_3, &_S1443, &_S1444, sky_pdf_1, throughput_4, 0.0f, sel_8);
        return _S1445;
    }
    float3  _S1446 = (&ray_3)->origin + make_float3 ((&hit_4)->distance) * (&ray_3)->unit_direction;
    (&ray_3)->origin = _S1446;
    bool _S1447 = (fcptVaryingUsed());
    if(_S1447)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1448 = !replay_2;
        if(_S1448)
        {
            float3  _S1449 = pathColor(throughput_3 * glowed_0, throughput_4, 0.0f);
            float3  _S1450 = _S1449 / make_float3 (density_3);
            float3  _S1451 = sel_8->glow + _S1450;
            sel_8->glow = _S1451;
        }
        float3  _S1452 = throughput_3 * weight_2;
        throughput_3 = _S1452;
    }
    else
    {
        float3  _S1453 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
        float3  _S1454 = throughput_3 * _S1453;
        throughput_3 = _S1454;
    }
    float _S1455 = width_3 + spread_1 * (&hit_4)->distance;
    uint _S1456 = b_7 + 1U;
    b_7 = _S1456;
    layer_0 = 0U;
    width_3 = _S1455;
    passes_0 = false;
    wavelength_10 = 0.0f;
    threshold_0 = 0.0f;
    turned_1 = false;
    is_inside_6 = false;
    spectral_weight_1 = throughput_4;
    float3  chain_throughput_1 = _S1322;
    float3  reconnection_0 = _S1322;
    viewed_0 = _S1439;
    for(;;)
    {
        bool _S1457 = ((&hit_4)->is_point_light) == 1U;
        if(replay_2)
        {
            _S1319 = _S1327 == 1U;
        }
        else
        {
            _S1319 = false;
        }
        if(_S1319)
        {
            _S1320 = b_7 == _S1326;
        }
        else
        {
            _S1320 = false;
        }
        bool _S1458;
        if(_S1320)
        {
            bool _S1459 = ((&hit_4)->instance_index) != (_S1339.instance_index);
            if(_S1459)
            {
                _S1458 = true;
            }
            else
            {
                _S1458 = ((&hit_4)->triangle_index) != (_S1339.triangle_index);
            }
        }
        else
        {
            _S1458 = false;
        }
        if(_S1458)
        {
            return _S1323;
        }
        FKMedium _S1460 = Medium_x24init_0(_S1322, _S1322, 0.0f);
        BSDFMaterial _S1461 = Material_x24init_0(_S1322, _S1322, 0.0f, 0.0f, 0.0f, 0.0f, _S1322, throughput_4, 1.0f, _S1322, _S1322, 0.5f, 0.0f, 0.0f, _S1322, 0.0f, _S1322, 0.0f);
        FKMedium _S1462 = _S1460;
        FKSurface _S1463 = Surface_x24init_0(_S1322, _S1322, 0.0f, &_S1461, false, 0U, 1.0f, false, &_S1462, 4294967295U, _S1322);
        bool _S1464 = !_S1457;
        bool scatter_2;
        bool is_inside_7;
        float geometry_density_0;
        float3  throughput_6;
        float3  front_n_0;
        FKSurface surface_13;
        if(_S1464)
        {
            uint _S1465 = stream(_S1350, b_7);
            uint _S1466 = arrivalLobe_0(b_7, (&prev_1)->lobe);
            FKSurface _S1467 = (fcptSurfaceAtPath((hit_4), ((&ray_3)->origin), (_S1465), (width_3), (layer_0), (b_7), (_S1466), ((&ray_3)->unit_direction)));
            bool _S1468 = !passes_0;
            FKSurface _S1469 = _S1467;
            FKSurface _S1470 = emitting_0(&_S1469, _S1468);
            uint _S1471 = stream(_S1350, b_7 + 256U);
            Random _S1472 = pcg(_S1471);
            FKSurface _S1473 = _S1470;
            FKSurface _S1474 = uncovered_0(&_S1473, _S1472.value);
            float _S1475 = facingSign(_S1474.material.transmission, _S1474.geometry_n, (&ray_3)->unit_direction);
            bool _S1476 = _S1475 < 0.0f;
            bool _S1477 = (_S1474.material.transmission) > 0.0f;
            if(_S1477)
            {
                bool _S1478 = arrivesBehind_0((&ray_3)->unit_direction, _S1474.geometry_n);
                scatter_2 = _S1478;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1479 = _S1474;
            FKSurface _S1480 = facingRay_0(&_S1479, (&ray_3)->unit_direction);
            if(passes_0)
            {
                bool _S1481 = arrivesBehind_0((&ray_3)->unit_direction, _S1480.geometry_n);
                is_inside_7 = _S1481;
            }
            else
            {
                is_inside_7 = scatter_2;
            }
            if(is_inside_7)
            {
                float _S1482 = (&hit_4)->distance;
                float _S1483 = upsample(_S1480.material.absorption, wavelength_10);
                float3  _S1484 = make_float3 (_S1483);
                bool _S1485 = wavelength_10 > 0.0f;
                float3  _S1486 = _slang_select(_S1485, _S1484,_S1480.material.absorption);
                float3  _S1487 = beerLambert(_S1482, _S1486);
                float3  _S1488 = throughput_3 * _S1487;
                throughput_6 = _S1488;
            }
            else
            {
                throughput_6 = throughput_3;
            }
            bool _S1489 = !_S1480.skip;
            float geometry_density_1 = (F32_abs((dot_0(_S1480.geometry_n, (&ray_3)->unit_direction)))) / ((&hit_4)->distance * (&hit_4)->distance);
            bool _S1490 = b_7 == _S1456;
            if(_S1490)
            {
                float _S1491 = 0.00251327408477664f / geometry_density_1;
                geometry_density_0 = _S1491;
            }
            else
            {
                geometry_density_0 = threshold_0;
            }
            float _S1492 = geometry_density_0;
            scatter_2 = _S1489;
            geometry_density_0 = geometry_density_1;
            threshold_0 = _S1492;
            surface_13 = _S1480;
            front_n_0 = _S1474.smooth_n;
            turned_1 = _S1476;
        }
        else
        {
            scatter_2 = false;
            geometry_density_0 = 0.0f;
            surface_13 = _S1463;
            throughput_6 = throughput_3;
            front_n_0 = _S1322;
            is_inside_7 = is_inside_6;
        }
        bool _S1493;
        if(scatter_2)
        {
            _S1493 = (&prev_1)->rough;
        }
        else
        {
            _S1493 = false;
        }
        bool _S1494;
        if(_S1493)
        {
            _S1494 = ((&prev_1)->pdf * geometry_density_0 * threshold_0) <= 1.0f;
        }
        else
        {
            _S1494 = false;
        }
        FKSurface _S1495 = surface_13;
        float _S1496 = dot_0(surface_13.smooth_n, - (&ray_3)->unit_direction);
        bool _S1497 = (fcptDispersionUsed());
        bool _S1498;
        if(_S1497)
        {
            _S1498 = wavelength_10 == 0.0f;
        }
        else
        {
            _S1498 = false;
        }
        bool _S1499;
        if(_S1498)
        {
            _S1499 = scatter_2;
        }
        else
        {
            _S1499 = false;
        }
        bool _S1500;
        if(_S1499)
        {
            bool _S1501 = dispersive(surface_13.material);
            _S1500 = _S1501;
        }
        else
        {
            _S1500 = false;
        }
        float3  throughput_7;
        if(_S1500)
        {
            uint _S1502 = stream(_S1350, 512U);
            Random _S1503 = pcg(_S1502);
            uint _S1504 = extractBits_0(_S1324, 25U, 7U);
            float _S1505 = (float(_S1504) + _S1503.value) / 128.0f;
            uint _S1506 = extractBits_0(_S1324, 24U, 1U);
            bool _S1507 = _S1506 == 1U;
            float _S1508 = _slang_select(_S1507, _S1505,_S1503.value);
            float2  _S1509 = sampleWavelength(_S1508);
            float wavelength_11 = _S1509.x;
            float3  _S1510 = wavelengthWeights(wavelength_11);
            float3  _S1511 = _S1510 / make_float3 (_S1509.y);
            float _S1512 = upsample(throughput_6, wavelength_11);
            float3  _S1513 = make_float3 (_S1512);
            float _S1514 = upsample(scatter_in_0, wavelength_11);
            float3  _S1515 = make_float3 (_S1514);
            scatter_in_0 = _S1515;
            float _S1516 = upsample(extinction_in_0, wavelength_11);
            float3  _S1517 = make_float3 (_S1516);
            extinction_in_0 = _S1517;
            wavelength_10 = wavelength_11;
            throughput_7 = _S1513;
            spectral_weight_1 = _S1511;
        }
        else
        {
            throughput_7 = throughput_6;
        }
        BSDFMaterial _S1518 = pathMaterial(surface_13.material, wavelength_10);
        float2  _S1519 = wavelengthEta(_S1518, _S1496, wavelength_10);
        bool _S1520;
        if(scatter_2)
        {
            uint _S1521 = (fcptMaxBounces());
            bool _S1522 = b_7 >= _S1521;
            if(_S1522)
            {
                _S1520 = true;
            }
            else
            {
                bool _S1523 = neeDecision(_S1518, _S1496, _S1519.x, _S1519.y);
                _S1520 = _S1523;
            }
        }
        else
        {
            _S1520 = false;
        }
        bool _S1524;
        if(passes_0)
        {
            _S1524 = true;
        }
        else
        {
            _S1524 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1524)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1520;
        }
        bool _S1525 = (fcptHairUsed());
        bool _S1526;
        if(_S1525)
        {
            float3  _S1527 = surface_13.hair;
            _S1526 = (dot_0(_S1527, _S1527)) > 0.0f;
        }
        else
        {
            _S1526 = false;
        }
        bool _S1528;
        if(_S1526)
        {
            _S1528 = true;
        }
        else
        {
            BSDFMaterial _S1529 = _S1518;
            bool _S1530 = isTranslucent_0(&_S1529);
            _S1528 = _S1530;
        }
        bool _S1531;
        if(_S1528)
        {
            _S1531 = true;
        }
        else
        {
            bool _S1532 = (_S1518.transmission) > 0.0f;
            if(_S1532)
            {
                uint _S1533 = (fcptLayers((hit_4)));
                _S1531 = _S1533 == 1U;
            }
            else
            {
                _S1531 = false;
            }
        }
        float3  _S1534 = emitted_0(_S1518.emissive, (&ray_3)->unit_direction, front_n_0);
        float3  emission_0;
        if(_S1457)
        {
            float3  _S1535 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1535;
        }
        else
        {
            emission_0 = _S1534;
        }
        bool _S1536 = !replay_2;
        bool _S1537;
        if(_S1536)
        {
            _S1537 = true;
        }
        else
        {
            _S1537 = b_7 >= _S1338;
        }
        bool _S1538;
        if(_S1537)
        {
            float _S1539 = rgb_to_greyscale(emission_0);
            _S1538 = _S1539 > 0.0f;
        }
        else
        {
            _S1538 = false;
        }
        float3  emission_1;
        if(_S1538)
        {
            NEEVertex _S1540 = nee_vertex_1;
            FKHit _S1541 = hit_4;
            float _S1542 = emissionWeight_0(&_S1540, &_S1541, (&ray_3)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1542);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1543;
        if(replay_2)
        {
            _S1543 = _S1327 == 1U;
        }
        else
        {
            _S1543 = false;
        }
        bool _S1544;
        if(_S1543)
        {
            _S1544 = b_7 > _S1326;
        }
        else
        {
            _S1544 = false;
        }
        bool _S1545;
        if(_S1544)
        {
            _S1545 = b_7 == _S1325;
        }
        else
        {
            _S1545 = false;
        }
        bool _S1546;
        if(_S1545)
        {
            bool _S1547 = _S1328 == 1U;
            if(_S1547)
            {
                _S1546 = true;
            }
            else
            {
                _S1546 = _S1328 == 2U;
            }
        }
        else
        {
            _S1546 = false;
        }
        if(_S1546)
        {
            bool _S1548 = _S1457 != (_S1328 == 2U);
            if(_S1548)
            {
                return _S1323;
            }
            float3  _S1549 = pathColor(throughput_7 * emission_1, spectral_weight_1, wavelength_10);
            return Shift_x24init_0(_S1549 / make_float3 (r_9->jac), density_3 / r_9->jac);
        }
        uint _S1550 = extractBits_0((&chain_1)->path, 10U, 2U);
        bool _S1551 = _S1550 == 1U;
        Reservoir here_0 = chain_1;
        uint _S1552 = insertBits_0(_S1352, b_7, 5U, 5U);
        uint _S1553 = insertBits_0(_S1552, 1U, 10U, 2U);
        uint _S1554 = insertBits_0(_S1553, (&prev_1)->lobe, 15U, 3U);
        bool _S1555 = (&prev_1)->inside;
        uint _S1556 = _slang_select(_S1555, 1U,0U);
        uint _S1557 = insertBits_0(_S1554, _S1556, 22U, 1U);
        (&here_0)->path = _S1557;
        uint _S1558 = (&here_0)->path;
        bool _S1559 = wavelength_10 > 0.0f;
        uint _S1560 = _slang_select(_S1559, 1U,0U);
        uint _S1561 = insertBits_0(_S1558, _S1560, 23U, 1U);
        (&here_0)->path = _S1561;
        float _S1562 = (&prev_1)->pdf * geometry_density_0;
        (&here_0)->jac = _S1562;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1563;
        if(replay_2)
        {
            _S1563 = _S1327 == 1U;
        }
        else
        {
            _S1563 = false;
        }
        bool _S1564;
        if(_S1563)
        {
            _S1564 = b_7 == _S1326;
        }
        else
        {
            _S1564 = false;
        }
        bool _S1565 = b_7 == _S1338;
        bool _S1566;
        if(_S1565)
        {
            bool _S1567 = !scatter_2;
            if(_S1567)
            {
                _S1566 = true;
            }
            else
            {
                bool _S1568 = _S1327 != 1U;
                if(_S1568)
                {
                    _S1566 = _S1327 != 3U;
                }
                else
                {
                    _S1566 = false;
                }
            }
        }
        else
        {
            _S1566 = false;
        }
        bool _S1569;
        if(_S1566)
        {
            _S1569 = _S1327 == 2U;
        }
        else
        {
            _S1569 = false;
        }
        bool _S1570;
        if(_S1569)
        {
            _S1570 = !_S1494;
        }
        else
        {
            _S1570 = false;
        }
        bool _S1571;
        if(_S1570)
        {
            _S1571 = _S1328 != 4U;
        }
        else
        {
            _S1571 = false;
        }
        bool _S1572 = _S1326 == _S1325;
        bool _S1573;
        if(_S1572)
        {
            _S1573 = _S1328 == 0U;
        }
        else
        {
            _S1573 = false;
        }
        bool _S1574;
        if(_S1573)
        {
            _S1574 = ((&hit_4)->instance_index) == (_S1339.instance_index);
        }
        else
        {
            _S1574 = false;
        }
        bool _S1575;
        if(_S1574)
        {
            _S1575 = ((&hit_4)->triangle_index) == (_S1339.triangle_index);
        }
        else
        {
            _S1575 = false;
        }
        bool _S1576;
        if(_S1575)
        {
            _S1576 = _S1494;
        }
        else
        {
            _S1576 = false;
        }
        bool _S1577 = _slang_select(_S1564, _S1576,_S1571);
        bool _S1578;
        if(nee_0)
        {
            _S1578 = _slang_select(replay_2, _S1577,scatter_2);
        }
        else
        {
            _S1578 = false;
        }
        TreeSample _S1579 = TreeSample_x24init_0(_S1322, _S1322, 0.0f, 0U);
        uint2  _S1580 = make_uint2 (0U);
        float2  _S1581 = make_float2 (0.0f);
        FKHit _S1582 = Hit_x24init_0(_S1581, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1583 = _S1582;
        ShadowContext _S1584 = ShadowContext_x24init_0(_S1322, _S1322, _S1580, _S1322, 0U, 0U, false, 0.0f, 0.0f, &_S1583, false);
        bool _S1585;
        if(nee_0)
        {
            _S1585 = _S1537;
        }
        else
        {
            _S1585 = false;
        }
        ShadowContext context_5;
        if(_S1585)
        {
            uint _S1586 = arrivalLobe_0(b_7, (&prev_1)->lobe);
            FKMedium _S1587 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1588 = surface_13;
            FKHit _S1589 = hit_4;
            FKMedium _S1590 = _S1587;
            ShadowContext _S1591 = shadowContext_0(&_S1588, turned_1, extinction_in_0, filling_2, (&ray_3)->unit_direction, b_7, _S1586, (&hit_4)->distance, width_3, &_S1589, _S1526, &_S1590);
            context_5 = _S1591;
        }
        else
        {
            context_5 = _S1584;
        }
        float3  throughput_8;
        float3  lit_0;
        if(_S1578)
        {
            float3  _S1592 = (&ray_3)->origin;
            if(_S1526)
            {
                throughput_8 = _S1322;
            }
            else
            {
                throughput_8 = _S1495.smooth_n;
            }
            FKSurface _S1593 = surface_13;
            uint _S1594 = stream(_S1350, b_7 + 64U);
            ShadowContext _S1595 = context_5;
            TreeSample _S1596 = sampleLightTree_0(_S1592, throughput_8, surface_13.geometry_n, surface_13.geometry_offset, _S1531, _S1594, &_S1595);
            bool _S1597 = any_1((_S1596.radiance) != _S1322);
            if(_S1597)
            {
                if(_S1526)
                {
                    uint _S1598 = (fcptMaxBounces());
                    bool _S1599 = b_7 < _S1598;
                    FKSurface _S1600 = surface_13;
                    TreeSample _S1601 = _S1596;
                    float3  _S1602 = hairLight_0(&_S1600, (&ray_3)->unit_direction, &_S1601, _S1599);
                    lit_0 = _S1602;
                }
                else
                {
                    float _S1603 = _S1519.x;
                    float _S1604 = _S1519.y;
                    uint _S1605 = (fcptMaxBounces());
                    bool _S1606 = b_7 < _S1605;
                    TreeSample _S1607 = _S1596;
                    BSDFMaterial _S1608 = _S1518;
                    float3  _S1609 = lightBSDF_0((&ray_3)->unit_direction, &_S1607, _S1495.smooth_n, _S1593.geometry_n, &_S1608, _S1603, _S1604, _S1606, surface_13.random_state);
                    lit_0 = _S1609;
                }
            }
            else
            {
                lit_0 = _S1322;
            }
            light_3 = _S1596;
        }
        else
        {
            light_3 = _S1579;
            lit_0 = _S1322;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1610;
        bool _S1611;
        float density_5;
        if(_S1564)
        {
            bool _S1612 = !_S1494;
            if(_S1612)
            {
                return _S1323;
            }
            uint _S1613 = extractBits_0(_S1324, 23U, 1U);
            bool _S1614 = _S1559 != (_S1613 == 1U);
            if(_S1614)
            {
                return _S1323;
            }
            float3  throughput_9 = throughput_7 * make_float3 (geometry_density_0);
            float density_6 = density_3 * geometry_density_0;
            if(_S1572)
            {
                viewed_1 = _S1328 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                float3  _S1615 = pathColor(throughput_9 * emission_1, spectral_weight_1, wavelength_10);
                return Shift_x24init_0(_S1615 / make_float3 (r_9->jac), density_6 / r_9->jac);
            }
            if(_S1572)
            {
                refracted_4 = _S1328 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S1616 = !nee_0;
                if(_S1616)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1617 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1617 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1323;
                }
                float3  _S1618 = pathColor(throughput_9 * lit_0, spectral_weight_1, wavelength_10);
                return Shift_x24init_0(_S1618 / make_float3 (r_9->jac), density_6 / r_9->jac);
            }
            if(_S1572)
            {
                wrong_side_0 = _S1328 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1619 = !nee_0;
                if(_S1619)
                {
                    return _S1323;
                }
                bool _S1620 = (fcptWorldReadsPath());
                if(_S1620)
                {
                    float _S1621 = environmentPdf_0(r_9->dir);
                    uint _S1622 = b_7 + 1U;
                    FKSurface _S1623 = surface_13;
                    float3  _S1624 = skyColor_0((&ray_3)->unit_direction, r_9->dir, &_S1623, wavelength_10, _S1519, is_inside_7, _S1621, surface_13.random_state, _S1622);
                    float3  _S1625 = pathColor(throughput_9 * (_S1624 * r_9->radiance), spectral_weight_1, wavelength_10);
                    return Shift_x24init_0(_S1625 / make_float3 (r_9->jac), density_6 / r_9->jac);
                }
                float _S1626 = environmentPdf_0(r_9->dir);
                float3  _S1627 = skyBSDF((&ray_3)->unit_direction, r_9->dir, surface_13, _S1518, _S1519, is_inside_7, _S1626, surface_13.random_state);
                float3  _S1628 = pathColor(throughput_9 * _S1627 * r_9->radiance, spectral_weight_1, wavelength_10);
                return Shift_x24init_0(_S1628 / make_float3 (r_9->jac), density_6 / r_9->jac);
            }
            uint _S1629 = extractBits_0(_S1324, 21U, 1U);
            bool _S1630 = nee_0 != (_S1629 == 1U);
            if(_S1630)
            {
                return _S1323;
            }
            throughput_8 = throughput_9;
            density_5 = density_6;
        }
        else
        {
            if(replay_2)
            {
                viewed_1 = _S1565;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1631 = !scatter_2;
                if(_S1631)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1632 = _S1327 != 1U;
                    if(_S1632)
                    {
                        refracted_4 = _S1327 != 3U;
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
                bool _S1633 = _S1327 == 2U;
                if(_S1633)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1494;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1328 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1526)
                    {
                        return _S1323;
                    }
                    uint _S1634 = stream(_S1350, b_7 + 448U);
                    FKRay _S1635 = ray_3;
                    FKSurface _S1636 = surface_13;
                    ShadowContext _S1637 = context_5;
                    SkySample _S1638 = sampleSky_0(&_S1635, &_S1636, wavelength_10, _S1519, is_inside_7, _S1634, surface_13.random_state, &_S1637);
                    float3  _S1639 = pathColor(throughput_7 * _S1638.color, spectral_weight_1, wavelength_10);
                    return Shift_x24init_0(_S1639, 1.0f);
                }
                if(_S1633)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1494;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1640 = rgb_to_greyscale(light_3.radiance);
                    bool _S1641 = !(_S1640 > 0.0f);
                    if(_S1641)
                    {
                        return _S1323;
                    }
                    float3  _S1642 = pathColor(throughput_7 * lit_0, spectral_weight_1, wavelength_10);
                    return Shift_x24init_0(_S1642, 1.0f);
                }
                if(_S1337)
                {
                    passes_0 = _S1328 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1457;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float3  _S1643 = pathColor(throughput_7 * emission_1, spectral_weight_1, wavelength_10);
                    return Shift_x24init_0(_S1643, 1.0f);
                }
                if(_S1337)
                {
                    passes_0 = _S1328 == 1U;
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
                    passes_0 = !_S1494;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float3  _S1644 = pathColor(throughput_7 * emission_1, spectral_weight_1, wavelength_10);
                    return Shift_x24init_0(_S1644, 1.0f);
                }
                return _S1323;
            }
            else
            {
                if(_S1536)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1645 = b_7 > 0U;
                    if(_S1645)
                    {
                        Reservoir candidate_5 = chain_1;
                        if(_S1551)
                        {
                            float3  _S1646 = safeDivide(throughput_7 * emission_1, chain_throughput_1);
                            (&candidate_5)->radiance = _S1646;
                        }
                        else
                        {
                            if(_S1494)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1647 = pathColor(throughput_7 * emission_1, spectral_weight_1, wavelength_10);
                        Reservoir _S1648 = withEnd(candidate_5, 1U, b_7, _S1647);
                        offer(sel_8, _S1648, _S1647 * make_float3 (scale_4) / make_float3 (density_3));
                    }
                    else
                    {
                        float3  _S1649 = pathColor(throughput_7 * emission_1, spectral_weight_1, wavelength_10);
                        float3  _S1650 = sel_8->glow + _S1649;
                        sel_8->glow = _S1650;
                    }
                    if(nee_0)
                    {
                        float3  _S1651 = pathColor(throughput_7 * lit_0, spectral_weight_1, wavelength_10);
                        Reservoir candidate_6 = chain_1;
                        if(_S1551)
                        {
                            float3  _S1652 = safeDivide(_S1651, chain_throughput_1);
                            (&candidate_6)->radiance = _S1652;
                        }
                        else
                        {
                            if(_S1494)
                            {
                                candidate_6 = here_0;
                                uint _S1653 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1653;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1654 = insertBits_0(_S1352, b_7 + 1U, 5U, 5U);
                                uint _S1655 = insertBits_0(_S1654, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1655;
                            }
                        }
                        Reservoir _S1656 = withEnd(candidate_6, 0U, b_7, _S1651);
                        offer(sel_8, _S1656, _S1651 * make_float3 (scale_4) / make_float3 (density_3));
                    }
                    if(nee_0)
                    {
                        if(_S1526)
                        {
                            _S1610 = false;
                        }
                        else
                        {
                            bool _S1657 = environmentMapped_0();
                            _S1610 = _S1657;
                        }
                    }
                    else
                    {
                        _S1610 = false;
                    }
                    if(_S1610)
                    {
                        uint _S1658 = (fcptMaxBounces());
                        _S1611 = b_7 < _S1658;
                    }
                    else
                    {
                        _S1611 = false;
                    }
                    if(_S1611)
                    {
                        uint _S1659 = stream(_S1350, b_7 + 448U);
                        FKRay _S1660 = ray_3;
                        FKSurface _S1661 = surface_13;
                        ShadowContext _S1662 = context_5;
                        SkySample _S1663 = sampleSky_0(&_S1660, &_S1661, wavelength_10, _S1519, is_inside_7, _S1659, surface_13.random_state, &_S1662);
                        float3  _S1664 = pathColor(throughput_7 * _S1663.color, spectral_weight_1, wavelength_10);
                        Reservoir candidate_7 = chain_1;
                        if(_S1551)
                        {
                            float3  _S1665 = safeDivide(_S1664, chain_throughput_1);
                            (&candidate_7)->radiance = _S1665;
                        }
                        else
                        {
                            if(_S1494)
                            {
                                candidate_7 = here_0;
                                uint _S1666 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1666;
                                (&candidate_7)->dir = _S1663.dir;
                                (&candidate_7)->radiance = _S1663.radiance;
                            }
                            else
                            {
                                uint _S1667 = insertBits_0(_S1352, b_7 + 1U, 5U, 5U);
                                uint _S1668 = insertBits_0(_S1667, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1668;
                            }
                        }
                        Reservoir _S1669 = withEnd(candidate_7, 4U, b_7, _S1664);
                        offer(sel_8, _S1669, _S1664 * make_float3 (scale_4) / make_float3 (density_3));
                    }
                }
            }
            throughput_8 = throughput_7;
            density_5 = density_3;
        }
        bool _S1670;
        bool _S1671;
        bool _S1672;
        bool straight_0;
        bool _S1673;
        bool _S1674;
        bool _S1675;
        bool _S1676;
        bool _S1677;
        bool _S1678;
        bool _S1679;
        bool _S1680;
        bool _S1681;
        bool _S1682;
        bool _S1683;
        bool _S1684;
        bool _S1685;
        float density_7;
        float sky_pdf_3;
        float spread_4;
        uint b_10;
        float3  throughput_10;
        float3  throughput_11;
        float3  throughput_12;
        if(scatter_2)
        {
            if(replay_2)
            {
                viewed_1 = _S1565;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1686 = extractBits_0(_S1324, 15U, 3U);
            uint _S1687 = extractBits_0(_S1324, 18U, 3U);
            uint _S1688 = _slang_select(_S1564, _S1687,_S1686);
            float3  _S1689 = r_9->dir;
            bool refracted_5 = _S1688 == 1U;
            SampleBSDF _S1690 = SampleBSDF_x24init_0(_S1322, _S1322, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1690;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1691 = extractBits_0(_S1324, 22U, 1U);
                bool _S1692 = is_inside_7 != (_S1691 == 1U);
                if(_S1692)
                {
                    return _S1323;
                }
                bool _S1693 = _S1327 == 1U;
                if(_S1693)
                {
                    float3  _S1694 = (fcptHitPosition((_S1339)));
                    throughput_10 = _S1694;
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
                    BSDFMaterial _S1695 = _S1518;
                    bool _S1696 = isTranslucent_0(&_S1695);
                    if(_S1696)
                    {
                        refracted_4 = _S1688 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1697 = throughput_10 - (&ray_3)->origin;
                        float3  _S1698 = _slang_select(_S1693, _S1697,_S1689);
                        wrong_side_0 = (dot_0(_S1495.smooth_n, _S1698) * _S1496) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1693)
                {
                    float3  _S1699 = (&ray_3)->origin;
                    FKSurface _S1700 = surface_13;
                    float3  _S1701 = - _S1495.smooth_n;
                    bool _S1702 = is_inside_7 != refracted_4;
                    float3  _S1703 = _slang_select(_S1702, _S1701,_S1495.smooth_n);
                    float3  _S1704 = throughput_10 - (_S1699 + make_float3 (_S1700.geometry_offset) * _S1703);
                    float3  _S1705 = ((((_S1704)) * make_float3(rnorm3df(((_S1704)).x, ((_S1704)).y, ((_S1704)).z))));
                    reconnection_1 = _S1705;
                }
                else
                {
                    reconnection_1 = _S1689;
                }
                if(_S1526)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1706 = wrongSide_0(is_inside_7, refracted_4, reconnection_1, surface_13.geometry_n);
                    wrong_side_0 = _S1706;
                }
                if(wrong_side_0)
                {
                    return _S1323;
                }
                float3  _S1707 = throughput_10;
                throughput_10 = reconnection_1;
                b_10 = _S1688;
                wrong_side_0 = false;
                reconnection_1 = _S1707;
            }
            else
            {
                bool _S1708 = !_S1564;
                if(_S1708)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1709;
                    if(_S1526)
                    {
                        SampleBSDF _S1710 = (fcptSampleHair((surface_13.hair), (_S1518.albedo), (_S1518.specular_tint), ((&ray_3)->unit_direction), (surface_13.random_state)));
                        _S1709 = _S1710;
                    }
                    else
                    {
                        SampleBSDF _S1711 = sampleBSDF((&ray_3)->unit_direction, _S1495.smooth_n, _S1518, _S1519.x, _S1519.y, surface_13.random_state, _S1581);
                        _S1709 = _S1711;
                    }
                    bsdf_sampled_0 = _S1709;
                    if(_S1526)
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
                            return _S1323;
                        }
                        break;
                    }
                    if(_S1526)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1712 = wrongSide_0(is_inside_7, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_13.geometry_n);
                        wrong_side_0 = _S1712;
                    }
                    if(wrong_side_0)
                    {
                        _S1610 = (_S1518.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1610 = false;
                    }
                    if(_S1610)
                    {
                        SampleBSDF _S1713 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_13.geometry_n, _S1518, _S1519.x, _S1519.y, (&bsdf_sampled_0)->random_state, _S1581);
                        (&bsdf_sampled_0)->unit_direction = _S1713.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1713.refracted;
                        (&bsdf_sampled_0)->throughput = _S1713.throughput;
                        (&bsdf_sampled_0)->lobe = _S1713.lobe;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1714 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_13.geometry_n)) * surface_13.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1714;
                        }
                    }
                    uint _S1715 = (&bsdf_sampled_0)->lobe;
                    float3  _S1716 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1717 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1718 = (&bsdf_sampled_0)->pdf;
                    float _S1719 = _slang_select(wrong_side_0, 0.0f,_S1718);
                    (&lobe_5)->pdf = _S1719;
                    throughput_10 = _S1716;
                    b_10 = _S1715;
                    refracted_4 = _S1717;
                }
                else
                {
                    throughput_10 = _S1689;
                    b_10 = _S1688;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1610 = true;
            }
            else
            {
                _S1610 = _S1564;
            }
            float3  chain_throughput_2;
            if(_S1610)
            {
                if(_S1526)
                {
                    SampleBSDF _S1720 = (fcptConnectHair((surface_13.hair), (_S1518.albedo), (_S1518.specular_tint), ((&ray_3)->unit_direction), (throughput_10)));
                    lobe_5 = _S1720;
                }
                else
                {
                    float3  _S1721 = (&ray_3)->unit_direction;
                    float3  _S1722 = negate_0(_S1721);
                    float _S1723 = sign_0(_S1496);
                    float3  _S1724 = _S1495.smooth_n * make_float3 (_S1723);
                    float _S1725 = dot_0(_S1724, throughput_10);
                    float _S1726 = _S1518.roughness;
                    float _S1727 = _S1726 * _S1726;
                    AnisotropicFrame _S1728 = anisotropicFrame(_S1518, _S1724);
                    SheenProfile _S1729 = sheenProfile(_S1722, _S1724, _S1518);
                    float3  _S1730 = reflectedHalf(_S1721, throughput_10);
                    bool _S1731 = b_10 == 1U;
                    if(_S1731)
                    {
                        float3  _S1732 = refractedHalf(_S1721, throughput_10, _S1495.smooth_n, _S1519.x, _S1519.y);
                        throughput_11 = _S1732;
                    }
                    else
                    {
                        throughput_11 = _S1730;
                    }
                    bool _S1733 = b_10 == 0U;
                    if(_S1733)
                    {
                        _S1611 = true;
                    }
                    else
                    {
                        _S1611 = b_10 == 6U;
                    }
                    if(_S1611)
                    {
                        float3  _S1734 = sampledHalf(_S1722, _S1724, _S1727, _S1728, surface_13.random_state);
                        throughput_12 = _S1734;
                    }
                    else
                    {
                        throughput_12 = throughput_11;
                    }
                    float _S1735 = _S1519.x;
                    float _S1736 = _S1519.y;
                    Weights _S1737 = lobeWeights(_S1721, _S1722, _S1724, throughput_12, _S1728, _S1729, _S1518, _S1735, _S1736);
                    float _S1738 = (F32_abs((_S1496)));
                    float _S1739 = vndfPDF(_S1722, throughput_12, _S1724, _S1738, _S1727, _S1728, _S1737.v_dot_h);
                    switch(b_10)
                    {
                    case 0U:
                        {
                            float _S1740 = diffusePDF(_S1725, _S1738, _S1518, _S1737);
                            float3  _S1741 = diffuseBSDF(throughput_10, _S1724, _S1518, _S1737);
                            density_7 = _S1740;
                            chain_throughput_2 = _S1741;
                            break;
                        }
                    case 1U:
                        {
                            float _S1742 = refractPDF(dot_0(throughput_10, throughput_12), _S1739, _S1737, _S1735, _S1736);
                            float3  _S1743 = refractBSDF(throughput_10, _S1724, _S1727, _S1728, _S1518, _S1737);
                            density_7 = _S1742;
                            chain_throughput_2 = _S1743;
                            break;
                        }
                    case 4U:
                        {
                            float _S1744 = sheenVelvetPDF(_S1725, _S1738, _S1737);
                            float3  _S1745 = sheenVelvetBSDF(throughput_10, _S1722, _S1724, _S1518, _S1737);
                            density_7 = _S1744;
                            chain_throughput_2 = _S1745;
                            break;
                        }
                    case 6U:
                        {
                            ToonProfile _S1746 = toonProfile(_S1722, _S1724, _S1518);
                            float _S1747 = toonPDF(throughput_10, _S1724, _S1746, _S1737);
                            float3  _S1748 = toonBSDF(throughput_10, _S1724, _S1746, _S1737);
                            density_7 = _S1747;
                            chain_throughput_2 = _S1748;
                            break;
                        }
                    default:
                        {
                            float _S1749 = reflectPDF(_S1739, _S1737);
                            float3  _S1750 = reflectBSDF(throughput_10, _S1724, _S1727, _S1728, _S1737);
                            density_7 = _S1749;
                            chain_throughput_2 = _S1750;
                            break;
                        }
                    }
                    bool _S1751 = density_7 > 0.0f;
                    if(_S1751)
                    {
                        SampleBSDF _S1752 = SampleBSDF_x24init_0(throughput_10, chain_throughput_2, surface_13.random_state, _S1731, b_10, density_7);
                        lobe_5 = _S1752;
                    }
                }
            }
            bool _S1753 = b_10 == 0U;
            if(_S1753)
            {
                _S1611 = true;
            }
            else
            {
                _S1611 = b_10 == 4U;
            }
            if(_S1611)
            {
                _S1670 = true;
            }
            else
            {
                _S1670 = b_10 == 6U;
            }
            if(_S1526)
            {
                _S1671 = false;
            }
            else
            {
                bool _S1754 = !_S1670;
                if(_S1754)
                {
                    bool _S1755 = (_S1518.roughness) == 0.0f;
                    if(_S1755)
                    {
                        _S1671 = true;
                    }
                    else
                    {
                        bool _S1756 = b_10 == 1U;
                        if(_S1756)
                        {
                            _S1671 = (_S1519.x) == (_S1519.y);
                        }
                        else
                        {
                            _S1671 = false;
                        }
                    }
                }
                else
                {
                    _S1671 = false;
                }
            }
            bool _S1757 = !_S1526;
            if(_S1757)
            {
                _S1672 = b_10 == 1U;
            }
            else
            {
                _S1672 = false;
            }
            if(_S1672)
            {
                straight_0 = (_S1518.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1673 = _S1757;
            }
            else
            {
                _S1673 = false;
            }
            if(_S1673)
            {
                _S1674 = b_10 == 1U;
            }
            else
            {
                _S1674 = false;
            }
            if(_S1674)
            {
                _S1675 = (_S1519.x) == (_S1519.y);
            }
            else
            {
                _S1675 = false;
            }
            BSDFMaterial _S1758 = _S1518;
            bool _S1759 = isTranslucent_0(&_S1758);
            if(_S1759)
            {
                _S1676 = _S1753;
            }
            else
            {
                _S1676 = false;
            }
            if(_S1676)
            {
                _S1677 = (dot_0(throughput_10, surface_13.geometry_n)) < 0.0f;
            }
            else
            {
                _S1677 = false;
            }
            if(nee_0)
            {
                _S1678 = !_S1671;
            }
            else
            {
                _S1678 = false;
            }
            if(_S1678)
            {
                _S1679 = !wrong_side_0;
            }
            else
            {
                _S1679 = false;
            }
            if(_S1679)
            {
                float _S1760 = (&lobe_5)->pdf;
                float3  _S1761 = (&ray_3)->origin;
                float3  _S1762 = _slang_select(_S1531, _S1322,_S1495.smooth_n);
                float3  _S1763 = (&ray_3)->origin;
                FKSurface _S1764 = surface_13;
                float3  _S1765 = - _S1495.smooth_n;
                float3  _S1766 = _slang_select(_S1677, _S1765,_S1495.smooth_n);
                NEEVertex _S1767 = NEEVertex_x24init_0(false, _S1760, _S1761, _S1762, _S1763 + make_float3 (_S1764.geometry_offset) * _S1766);
                nee_vertex_1 = _S1767;
            }
            else
            {
                if(_S1526)
                {
                    _S1680 = true;
                }
                else
                {
                    bool _S1768 = b_10 != 1U;
                    if(_S1768)
                    {
                        _S1680 = true;
                    }
                    else
                    {
                        _S1680 = (_S1519.x) != (_S1519.y);
                    }
                }
                if(_S1680)
                {
                    (&nee_vertex_1)->none = true;
                }
            }
            bool _S1769 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1769)
            {
                if(_S1670)
                {
                    _S1680 = true;
                }
                else
                {
                    _S1680 = ((&lobe_5)->pdf * (&prev_1)->cos / ((&hit_4)->distance * (&hit_4)->distance) * threshold_0) <= 1.0f;
                }
            }
            else
            {
                _S1680 = false;
            }
            bool _S1770 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1770)
            {
                if(_S1670)
                {
                    _S1681 = true;
                }
                else
                {
                    _S1681 = (_S1518.roughness) >= 0.20000000298023224f;
                }
            }
            else
            {
                _S1681 = false;
            }
            if(_S1564)
            {
                bool _S1771 = !_S1680;
                if(_S1771)
                {
                    return _S1323;
                }
                bool _S1772 = _S1328 != 1U;
                if(_S1772)
                {
                    _S1682 = _S1328 != 2U;
                }
                else
                {
                    _S1682 = false;
                }
                if(_S1682)
                {
                    float _S1773 = (&lobe_5)->pdf;
                    float _S1774 = _slang_select(nee_0, _S1773,0.0f);
                    float _S1775 = escapeWeight_0(_S1774, _S1689);
                    if(_S1572)
                    {
                        passes_0 = _S1334;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1776 = _slang_select(passes_0, _S1775,1.0f);
                    return Shift_x24init_0(throughput_8 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_9->radiance * make_float3 (_S1776) / make_float3 (r_9->jac), density_5 * (&lobe_5)->pdf / r_9->jac);
                }
                float3  _S1777 = throughput_8 * make_float3 ((&lobe_5)->pdf);
                float _S1778 = density_5 * (&lobe_5)->pdf;
                throughput_11 = _S1777;
                density_7 = _S1778;
            }
            else
            {
                throughput_11 = throughput_8;
                density_7 = density_5;
            }
            uint _S1779 = (fcptLayers((hit_4)));
            bool _S1780 = _S1779 > 1U;
            if(_S1780)
            {
                _S1682 = (b_10 == 1U) != passes_0;
            }
            else
            {
                _S1682 = false;
            }
            if(viewed_1)
            {
                _S1683 = _S1682;
            }
            else
            {
                _S1683 = false;
            }
            if(_S1683)
            {
                return _S1323;
            }
            if(replay_2)
            {
                _S1684 = b_7 <= _S1338;
            }
            else
            {
                _S1684 = false;
            }
            if(_S1684)
            {
                _S1685 = _S1494;
            }
            else
            {
                _S1685 = false;
            }
            bool _S1781;
            if(_S1685)
            {
                _S1781 = _S1680;
            }
            else
            {
                _S1781 = false;
            }
            bool _S1782;
            if(_S1781)
            {
                _S1782 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1782 = !_S1681;
                }
                else
                {
                    _S1782 = false;
                }
            }
            if(_S1782)
            {
                return _S1323;
            }
            if(viewed_1)
            {
                float3  _S1783 = throughput_11 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1784 = (&lobe_5)->pdf;
                throughput_12 = _S1783;
                sky_pdf_3 = _S1784;
            }
            else
            {
                float3  _S1785 = throughput_11 * max_0((&lobe_5)->throughput, _S1322);
                throughput_12 = _S1785;
                sky_pdf_3 = density_7;
            }
            bool _S1786;
            if(_S1536)
            {
                _S1786 = !_S1551;
            }
            else
            {
                _S1786 = false;
            }
            bool _S1787;
            if(_S1786)
            {
                _S1787 = _S1494;
            }
            else
            {
                _S1787 = false;
            }
            bool _S1788;
            if(_S1787)
            {
                _S1788 = _S1680;
            }
            else
            {
                _S1788 = false;
            }
            if(_S1788)
            {
                chain_1 = here_0;
                uint _S1789 = insertBits_0((&chain_1)->path, b_10, 18U, 3U);
                uint _S1790 = _slang_select(nee_0, 1U,0U);
                uint _S1791 = insertBits_0(_S1789, _S1790, 21U, 1U);
                (&chain_1)->path = _S1791;
                float _S1792 = (&chain_1)->jac * (&lobe_5)->pdf;
                (&chain_1)->jac = _S1792;
                (&chain_1)->dir = throughput_10;
                chain_throughput_2 = throughput_12;
            }
            else
            {
                chain_throughput_2 = chain_throughput_1;
            }
            FKSurface _S1793 = surface_13;
            Vertex _S1794 = Vertex_x24init_0(_S1681, b_10, (&lobe_5)->pdf, (F32_abs((dot_0(surface_13.geometry_n, throughput_10)))), is_inside_7);
            prev_1 = _S1794;
            float _S1795 = (&lobe_5)->pdf;
            bool _S1796 = b_10 == 1U;
            bool _S1797;
            if(_S1796)
            {
                _S1797 = (_S1519.x) == (_S1519.y);
            }
            else
            {
                _S1797 = false;
            }
            float sky_pdf_4 = _slang_select(_S1797, sky_pdf_1,_S1795);
            float _S1798 = _slang_select(_S1526, 0.0f,sky_pdf_4);
            float _S1799 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * (&lobe_5)->pdf))))), (3.14159274101257324f)));
            bool _S1800 = !_S1671;
            float _S1801 = _slang_select(_S1800, _S1799,0.0f);
            float _S1802 = spread_1 + _S1801;
            bool _S1803;
            if(refracted_4)
            {
                _S1803 = !_S1677;
            }
            else
            {
                _S1803 = false;
            }
            bool is_inside_8;
            if(_S1803)
            {
                bool _S1804 = !is_inside_7;
                is_inside_8 = _S1804;
            }
            else
            {
                is_inside_8 = is_inside_7;
            }
            FKSurface _S1805 = surface_13;
            bool _S1806 = boundsVolume_0(&_S1805);
            bool _S1807;
            if(_S1806)
            {
                _S1807 = !_S1682;
            }
            else
            {
                _S1807 = false;
            }
            if(_S1807)
            {
                FKSurface faced_2 = surface_13;
                float3  _S1808 = - _S1793.geometry_n;
                float3  _S1809 = _slang_select(turned_1, _S1808,_S1793.geometry_n);
                (&faced_2)->geometry_n = _S1809;
                FKMedium _S1810 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1811 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1812 = faced_2;
                FKMedium _S1813 = _S1810;
                FKMedium _S1814 = _S1811;
                MediumSides _S1815 = mediumSides_0(&_S1812, &_S1813, filling_2, (&ray_3)->unit_direction, &_S1814);
                bool _S1816 = ((dot_0(throughput_10, _S1793.geometry_n)) > 0.0f) == ((dot_0(_S1793.geometry_n, (&faced_2)->geometry_n)) > 0.0f);
                float3  _S1817 = _slang_select(_S1816, _S1815.front.scatter,_S1815.behind.scatter);
                scatter_in_0 = _S1817;
                float3  _S1818 = scatter_in_0;
                float _S1819 = upsample(scatter_in_0, wavelength_10);
                float3  _S1820 = make_float3 (_S1819);
                float3  _S1821 = _slang_select(_S1559, _S1820,_S1818);
                scatter_in_0 = _S1821;
                float3  _S1822 = _slang_select(_S1816, _S1815.front.extinction,_S1815.behind.extinction);
                extinction_in_0 = _S1822;
                float3  _S1823 = extinction_in_0;
                float _S1824 = upsample(extinction_in_0, wavelength_10);
                float3  _S1825 = make_float3 (_S1824);
                float3  _S1826 = _slang_select(_S1559, _S1825,_S1823);
                extinction_in_0 = _S1826;
                float _S1827 = _slang_select(_S1816, _S1815.front.g,_S1815.behind.g);
                g_in_0 = _S1827;
                uint _S1828 = _S1815.fillings.x;
                uint _S1829 = _S1815.fillings.y;
                uint _S1830 = _slang_select(_S1816, _S1829,_S1828);
                bool _S1831 = (fcptVaryingUsed());
                uint _S1832 = _slang_select(_S1831, _S1830,4294967295U);
                filling_2 = _S1832;
            }
            (&ray_3)->unit_direction = throughput_10;
            bool _S1833 = !_S1682;
            if(_S1833)
            {
                FKSurface _S1834 = surface_13;
                float _S1835 = _slang_select(straight_0, 0.0f,_S1834.geometry_offset);
                float3  _S1836 = - _S1495.smooth_n;
                bool _S1837 = is_inside_8 != _S1677;
                float3  _S1838 = _slang_select(_S1837, _S1836,_S1495.smooth_n);
                float3  _S1839 = (&ray_3)->origin + make_float3 (_S1835) * _S1838;
                (&ray_3)->origin = _S1839;
            }
            throughput_11 = throughput_12;
            chain_throughput_1 = chain_throughput_2;
            density_7 = sky_pdf_3;
            passes_0 = _S1682;
            viewed_1 = _S1675;
            sky_pdf_3 = _S1798;
            spread_4 = _S1802;
            reconnection_0 = reconnection_1;
            is_inside_6 = is_inside_8;
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
            is_inside_6 = is_inside_7;
        }
        float density_8;
        if(_S1536)
        {
            if(_S1457)
            {
                float3  _S1840 = pathColor(throughput_11 * emission_1, spectral_weight_1, wavelength_10);
                Reservoir candidate_8 = chain_1;
                uint _S1841 = extractBits_0((&chain_1)->path, 10U, 2U);
                bool _S1842 = _S1841 == 1U;
                if(_S1842)
                {
                    float3  _S1843 = safeDivide(_S1840, chain_throughput_1);
                    (&candidate_8)->radiance = _S1843;
                }
                Reservoir _S1844 = withEnd(candidate_8, 2U, b_7, _S1840);
                offer(sel_8, _S1844, _S1840 * make_float3 (scale_4) / make_float3 (density_7));
            }
            if(_S1457)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1845 = survivalProbability(abs_0(throughput_11), density_7);
                density_8 = _S1845;
            }
            else
            {
                density_8 = 1.0f;
            }
            uint _S1846 = stream(_S1350, b_7 + 128U);
            Random _S1847 = pcg(_S1846);
            bool _S1848 = density_8 < (_S1847.value);
            if(_S1848)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1849 = (fcptMaxBounces());
                wrong_side_0 = b_7 >= _S1849;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1850 = density_7 * density_8;
            density_8 = _S1850;
        }
        else
        {
            density_8 = density_7;
        }
        uint _S1851 = layer_0 ^ 1U;
        uint _S1852 = _slang_select(passes_0, _S1851,0U);
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
            uint _S1853 = b_10 + 1U;
            b_7 = _S1853;
            layer_0 = _S1852;
            continue;
        }
        FKRay _S1854 = ray_3;
        float _S1855 = distance_1(reconnection_0, (&ray_3)->origin) * 1.0010000467300415f;
        if(replay_2)
        {
            refracted_4 = _S1565;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S1327 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1856 = _slang_select(wrong_side_0, _S1855,4.294967296e+09f);
        bool _S1857 = !_S1526;
        if(straight_0)
        {
            _S1610 = true;
        }
        else
        {
            _S1610 = _S1526;
        }
        FKHit _S1858;
        if(_S1610)
        {
            _S1858 = hit_4;
        }
        else
        {
            _S1858 = _S1582;
        }
        FKHit _S1859 = (fcptTraverseInstanceBVH((_S1854), (_S1464), (_S1856), (_S1857), (_S1858), (viewed_1)));
        hit_4 = _S1859;
        if(replay_2)
        {
            _S1611 = _S1565;
        }
        else
        {
            _S1611 = false;
        }
        if(_S1611)
        {
            _S1670 = _S1327 == 1U;
        }
        else
        {
            _S1670 = false;
        }
        if(_S1670)
        {
            _S1671 = ((&hit_4)->instance_index) == (_S1339.instance_index);
        }
        else
        {
            _S1671 = false;
        }
        if(_S1671)
        {
            _S1672 = ((&hit_4)->triangle_index) == (_S1339.triangle_index);
        }
        else
        {
            _S1672 = false;
        }
        if(_S1672)
        {
            (&hit_4)->uv = _S1339.uv;
            float _S1860 = distance_1(reconnection_0, (&ray_3)->origin);
            (&hit_4)->distance = _S1860;
        }
        if(replay_2)
        {
            _S1673 = _S1565;
        }
        else
        {
            _S1673 = false;
        }
        if(_S1673)
        {
            _S1674 = _S1327 == 3U;
        }
        else
        {
            _S1674 = false;
        }
        if(_S1674)
        {
            _S1675 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1675 = false;
        }
        if(_S1675)
        {
            return _S1323;
        }
        Reservoir _S1861 = chain_1;
        uint _S1862 = filling_2;
        for(;;)
        {
            bool _S1863 = (fcptVaryingUsed());
            if(_S1863)
            {
                _S1676 = _S1862 != 4294967295U;
            }
            else
            {
                _S1676 = false;
            }
            float _S1864;
            if(_S1676)
            {
                float _S1865 = (fcptMajorant((_S1862)));
                _S1864 = _S1865;
            }
            else
            {
                _S1864 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_2)
            {
                _S1677 = _S1565;
            }
            else
            {
                _S1677 = false;
            }
            if(_S1677)
            {
                _S1678 = _S1327 == 1U;
            }
            else
            {
                _S1678 = false;
            }
            if(_S1678)
            {
                _S1679 = _S1864 > 0.0f;
            }
            else
            {
                _S1679 = false;
            }
            if(_S1679)
            {
                ended_0 = _S1323;
                sky_pdf_2 = sky_pdf_3;
                spread_2 = spread_4;
                width_4 = width_3;
                density_4 = density_8;
                throughput_12 = throughput_11;
                b_10 = b_7;
                _S1680 = true;
                break;
            }
            bool _S1866 = (&prev_1)->rough;
            if(_S1866)
            {
                _S1680 = !(_S1864 > 0.0f);
            }
            else
            {
                _S1680 = false;
            }
            (&prev_1)->rough = _S1680;
            uint _S1867 = b_7 + 320U;
            bool _S1868 = b_7 == 4294967295U;
            uint _S1869 = _slang_select(_S1868, 384U,_S1867);
            uint _S1870 = stream(_S1350, _S1869);
            uint tracking_1 = _S1870;
            weight_2 = throughput_4;
            glowed_0 = _S1322;
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
                    _S1321 = int(2);
                    break;
                }
                uint _S1871 = b_10 + 320U;
                bool _S1872 = b_10 == 4294967295U;
                uint _S1873 = _slang_select(_S1872, 384U,_S1871);
                uint _S1874 = stream(_S1350, _S1873);
                Random _S1875 = pcg(_S1874);
                float _S1876 = - (F32_log((1.0f - _S1875.value))) / _S1864;
                if(_S1676)
                {
                    float3  _S1877 = (&ray_3)->origin;
                    float3  _S1878 = (&ray_3)->unit_direction;
                    float _S1879 = (&hit_4)->distance;
                    uint _S1880 = _slang_select(_S1872, 0U,b_10);
                    uint _S1881 = (&prev_1)->lobe;
                    uint _S1882 = _slang_select(_S1872, 3U,_S1881);
                    float _S1883 = (fcptTrackMedium((_S1862), (_S1877), (_S1878), (_S1879), (&tracking_1), (&weight_2), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1880), (_S1882), (_S1872)));
                    spread_3 = _S1883;
                }
                else
                {
                    spread_3 = _S1876;
                }
                bool _S1884 = !(spread_3 < ((&hit_4)->distance));
                if(_S1884)
                {
                    _S1321 = int(2);
                    break;
                }
                if(_S1676)
                {
                    _S1681 = _S1536;
                }
                else
                {
                    _S1681 = false;
                }
                if(_S1681)
                {
                    float3  _S1885 = pathColor(throughput_12 * glowed_0, spectral_weight_1, wavelength_10);
                    float3  _S1886 = _S1885 / make_float3 (density_4);
                    float3  _S1887 = sel_8->glow + _S1886;
                    sel_8->glow = _S1887;
                }
                else
                {
                }
                glowed_0 = _S1322;
                uint b_11 = b_10 + 1U;
                float3  _S1888 = (&ray_3)->origin + make_float3 (spread_3) * (&ray_3)->unit_direction;
                (&ray_3)->origin = _S1888;
                float3  _S1889 = flightWeight_0(scatter_in_0, extinction_in_0, _S1864, spread_3, true);
                float3  _S1890 = weight_2;
                float _S1891 = upsample(weight_2, wavelength_10);
                float3  _S1892 = make_float3 (_S1891);
                float3  _S1893 = _slang_select(_S1559, _S1892,_S1890);
                float3  _S1894 = _slang_select(_S1676, _S1893,_S1889);
                float3  throughput_13 = throughput_12 * _S1894;
                uint _S1895 = stream(_S1350, b_11 + 320U);
                tracking_1 = _S1895;
                weight_2 = throughput_4;
                float width_7 = width_4 + spread_2 * spread_3;
                float _S1896 = spread_2 + 3.14159274101257324f;
                if(_S1536)
                {
                    _S1682 = true;
                }
                else
                {
                    bool _S1897 = b_11 == _S1338;
                    if(_S1897)
                    {
                        _S1682 = !_S1676;
                    }
                    else
                    {
                        _S1682 = false;
                    }
                }
                TreeSample light_4;
                if(_S1682)
                {
                    float3  _S1898 = (&ray_3)->origin;
                    float3  _S1899 = (&ray_3)->unit_direction;
                    float3  _S1900 = (&ray_3)->unit_direction;
                    uint _S1901 = stream(_S1350, b_11 + 64U);
                    float3  _S1902 = extinction_in_0;
                    float3  _S1903 = extinction_in_0;
                    uint2  _S1904 = make_uint2 (_S1862);
                    float3  _S1905 = (&ray_3)->unit_direction;
                    uint _S1906 = arrivalLobe_0(b_11, (&prev_1)->lobe);
                    FKHit _S1907 = _S1582;
                    ShadowContext _S1908 = ShadowContext_x24init_0(_S1902, _S1903, _S1904, _S1905, b_11, _S1906, false, spread_3, width_7, &_S1907, false);
                    ShadowContext _S1909 = _S1908;
                    TreeSample _S1910 = sampleLightTree_0(_S1898, _S1899, _S1900, 0.0f, true, _S1901, &_S1909);
                    light_4 = _S1910;
                }
                else
                {
                    light_4 = _S1579;
                }
                float _S1911 = phaseHG_0(g_in_0, dot_0((&ray_3)->unit_direction, light_4.dir));
                uint _S1912 = (fcptMaxBounces());
                bool _S1913 = b_11 < _S1912;
                if(_S1913)
                {
                    _S1683 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1683 = false;
                }
                float _S1914 = _slang_select(_S1683, _S1911,0.0f);
                float3  _S1915 = throughput_13 * light_4.radiance;
                float _S1916 = powerHeuristic(light_4.density, _S1914);
                float3  _S1917 = pathColor(_S1915 * make_float3 (_S1911 * _S1916), spectral_weight_1, wavelength_10);
                float3  _S1918 = _slang_select(_S1682, _S1917,_S1322);
                if(replay_2)
                {
                    _S1684 = b_11 == _S1338;
                }
                else
                {
                    _S1684 = false;
                }
                if(_S1684)
                {
                    bool _S1919 = _S1327 == 2U;
                    if(_S1919)
                    {
                        float _S1920 = resamplingTarget(_S1918);
                        _S1685 = _S1920 > 0.0f;
                    }
                    else
                    {
                        _S1685 = false;
                    }
                    if(_S1685)
                    {
                        Shift _S1921 = Shift_x24init_0(_S1918, 1.0f);
                        _S1321 = int(1);
                        ended_0 = _S1921;
                        spread_3 = _S1896;
                        width_5 = width_7;
                        throughput_10 = throughput_13;
                        b_8 = b_11;
                        break;
                    }
                    _S1321 = int(1);
                    ended_0 = _S1323;
                    spread_3 = _S1896;
                    width_5 = width_7;
                    throughput_10 = throughput_13;
                    b_8 = b_11;
                    break;
                }
                if(_S1536)
                {
                    Reservoir candidate_9 = _S1861;
                    uint _S1922 = extractBits_0(_S1861.path, 24U, 8U);
                    uint _S1923 = insertBits_0(0U, _S1922, 24U, 8U);
                    uint _S1924 = extractBits_0(_S1861.path, 10U, 2U);
                    bool _S1925 = _S1924 == 1U;
                    if(_S1925)
                    {
                        float3  _S1926 = safeDivide(_S1918, chain_throughput_1);
                        (&candidate_9)->radiance = _S1926;
                    }
                    else
                    {
                        uint _S1927 = insertBits_0(_S1923, b_11 + 1U, 5U, 5U);
                        uint _S1928 = insertBits_0(_S1927, 2U, 10U, 2U);
                        (&candidate_9)->path = _S1928;
                    }
                    Reservoir _S1929 = withEnd(candidate_9, 0U, b_11, _S1918);
                    offer(sel_8, _S1929, _S1918 * make_float3 (scale_4) / make_float3 (density_4));
                    float _S1930 = survivalProbability(abs_0(throughput_13), density_4);
                    uint _S1931 = stream(_S1350, b_11 + 128U);
                    Random _S1932 = pcg(_S1931);
                    bool _S1933 = _S1930 < (_S1932.value);
                    if(_S1933)
                    {
                        _S1685 = true;
                    }
                    else
                    {
                        uint _S1934 = (fcptMaxBounces());
                        _S1685 = b_11 >= _S1934;
                    }
                    if(_S1685)
                    {
                        _S1321 = int(1);
                        ended_0 = _S1323;
                        spread_3 = _S1896;
                        width_5 = width_7;
                        throughput_10 = throughput_13;
                        b_8 = b_11;
                        break;
                    }
                    float _S1935 = density_4 * _S1930;
                    density_4 = _S1935;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1936 = stream(_S1350, b_11);
                float3  _S1937 = samplePhase_0(g_in_0, (&ray_3)->unit_direction, _S1936, &phase_pdf_1);
                (&ray_3)->unit_direction = _S1937;
                NEEVertex _S1938 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_3)->origin, _S1322, (&ray_3)->origin);
                nee_vertex_1 = _S1938;
                Vertex _S1939 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_6);
                prev_1 = _S1939;
                float _S1940 = (&prev_1)->pdf;
                FKRay _S1941 = ray_3;
                FKHit _S1942 = (fcptTraverseInstanceBVH((_S1941), (true), (4.294967296e+09f), (false), (_S1582), (false)));
                hit_4 = _S1942;
                b_10 = b_11;
                throughput_12 = throughput_13;
                spread_2 = _S1896;
                width_4 = width_7;
                sky_pdf_2 = _S1940;
            }
            if(_S1321 != int(2))
            {
                spread_2 = spread_3;
                width_4 = width_5;
                throughput_12 = throughput_10;
                b_10 = b_8;
                _S1680 = true;
                break;
            }
            ended_0 = _S1323;
            _S1680 = false;
            break;
        }
        if(_S1680)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1681 = b_10 == b_7;
        }
        else
        {
            _S1681 = false;
        }
        bool _S1943 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S1943)
        {
            Reservoir _S1944 = chain_1;
            FKRay _S1945 = ray_3;
            Vertex _S1946 = prev_1;
            NEEVertex _S1947 = nee_vertex_1;
            Shift _S1948 = escape_0(r_9, replay_2, _S1338, _S1327, _S1325, _S1328, scale_4, _S1352, &_S1944, chain_throughput_1, b_10, &_S1945, throughput_12, density_4, &_S1946, &_S1947, sky_pdf_2, spectral_weight_1, wavelength_10, sel_8);
            return _S1948;
        }
        float3  _S1949 = (&ray_3)->origin + make_float3 ((&hit_4)->distance) * (&ray_3)->unit_direction;
        (&ray_3)->origin = _S1949;
        bool _S1950 = (fcptVaryingUsed());
        if(_S1950)
        {
            _S1682 = filling_2 != 4294967295U;
        }
        else
        {
            _S1682 = false;
        }
        if(_S1682)
        {
            if(_S1536)
            {
                float3  _S1951 = pathColor(throughput_12 * glowed_0, spectral_weight_1, wavelength_10);
                float3  _S1952 = _S1951 / make_float3 (density_4);
                float3  _S1953 = sel_8->glow + _S1952;
                sel_8->glow = _S1953;
            }
            float3  _S1954 = throughput_12 * weight_2;
            throughput_10 = _S1954;
        }
        else
        {
            float3  _S1955 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S1956 = throughput_12 * _S1955;
            throughput_10 = _S1956;
        }
        float _S1957 = width_4 + spread_2 * (&hit_4)->distance;
        viewed_0 = _S1681;
        width_3 = _S1957;
        throughput_3 = throughput_10;
        density_3 = density_4;
        sky_pdf_1 = sky_pdf_2;
        spread_1 = spread_2;
        uint _S1853 = b_10 + 1U;
        b_7 = _S1853;
        layer_0 = _S1852;
    }
    return _S1323;
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
    Random _S1958 = pcg(state_3);
    Random _S1959 = pcg(_S1958.state);
    float _S1960 = 6.28318548202514648f * _S1958.value;
    float _S1961 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S1959.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1959.state, _S1961 * (F32_cos((_S1960))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_4, float3  value_2)
{
    RandomSphere _S1962;
    (&_S1962)->state = state_4;
    (&_S1962)->value = value_2;
    return _S1962;
}

__device__ RandomSphere random_sphere(uint state_5)
{
    Random _S1963 = normal_distribution(state_5);
    Random _S1964 = normal_distribution(_S1963.state);
    Random _S1965 = normal_distribution(_S1964.state);
    float3  _S1966 = make_float3 (_S1963.value, _S1964.value, _S1965.value);
    float3  _S1967 = ((((_S1966)) * make_float3(rnorm3df(((_S1966)).x, ((_S1966)).y, ((_S1966)).z))));
    return RandomSphere_x24init_0(_S1965.state, _S1967);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_12)
{
    float3  _S1968 = p1_0 - p0_0;
    float3  _S1969 = p2_0 - p0_0;
    float2  _S1970 = uv1_0 - uv0_0;
    float2  _S1971 = uv2_0 - uv0_0;
    float _S1972 = _S1970.x;
    float _S1973 = _S1971.y;
    float _S1974 = _S1970.y;
    float _S1975 = _S1971.x;
    float _S1976 = _S1972 * _S1973 - _S1974 * _S1975;
    float _S1977 = 1.0f / _S1976;
    float3  t_24 = (_S1968 * make_float3 (_S1973) - _S1969 * make_float3 (_S1974)) * make_float3 (_S1977);
    float3  _S1978 = (_S1969 * make_float3 (_S1972) - _S1968 * make_float3 (_S1975)) * make_float3 (_S1977);
    float3  _S1979 = t_24 - n_12 * make_float3 (dot_0(n_12, t_24));
    float3  _S1980 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_12);
    bool _S1981 = (dot_0(_S1979, _S1979)) > 0.0f;
    float3  _S1982 = _slang_select(_S1981, _S1979,_S1980);
    float3  _S1983 = ((((_S1982)) * make_float3(rnorm3df(((_S1982)).x, ((_S1982)).y, ((_S1982)).z))));
    bool _S1984 = (dot_0(cross_0(n_12, _S1983), _S1978)) > 0.0f;
    float3  t_25;
    if(_S1984)
    {
        float3  _S1985 = negate_0(_S1983);
        t_25 = _S1985;
    }
    else
    {
        t_25 = _S1983;
    }
    float3  _S1986 = cross_0(n_12, t_25);
    return makeMatrix<float, 3, 3> (t_25, _S1986, n_12);
}

__device__ float3  tangentToWorldNormalMap(float3  v_10, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_10, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_4, float3  uvw_0, float3  position_1)
{
    float3  _S1987 = t1_0 - t0_0;
    float3  _S1988 = t2_2 - t0_0;
    float3  _S1989 = t2_2 - t1_0;
    float _S1990 = (F32_min((length_0(_S1987)), ((F32_min((length_0(_S1988)), (length_0(_S1989)))))));
    float3  _S1991 = make_float3 (distance_1(position_1, t0_0), distance_1(position_1, t1_0), distance_1(position_1, t2_2));
    float3  _S1992 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1993 = dot_0(geometry_n_4, _S1992);
    float3  _S1994 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1995 = dot_0(geometry_n_4, _S1994);
    float3  _S1996 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1997 = acos_0(abs_0(make_float3 (_S1993, _S1995, dot_0(geometry_n_4, _S1996))));
    float3  _S1998 = clamp_2(tan_0(_S1997), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S1991 * _S1998, uvw_0), 0.0f, _S1990 * 0.125f);
}

__device__ float3  straightThrough(BSDFMaterial material_26)
{
    return make_float3 (material_26.transmission * (1.0f - material_26.metallic)) * material_26.albedo;
}

__device__ float hairRow(float3  in_dir_11, float3  t_26, float3  out_dir_3, uint p_15, float w_19, float alpha_10, uint nt_0)
{
    uint _S1999 = p_15 % 4U;
    float _S2000 = w_19 * HAIR_WIDTHS_0[_S1999];
    float _S2001 = (F32_asin((clamp_1(dot_0(out_dir_3, t_26), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_11, t_26), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1999] * alpha_10;
    return ((F32_asinh((_S2001 / _S2000))) / (F32_asinh((3.14159274101257324f / _S2000))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_12, float3  t_27, float3  out_dir_4, uint np_0)
{
    float3  _S2002 = worldToTangent(out_dir_4, t_27);
    float3  _S2003 = worldToTangent(in_dir_12, t_27);
    return (F32_frac((((F32_atan2((_S2002.z), (_S2002.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S2003.z), (1.17549435082228751e-38f - _S2003.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_13, float3  t_28, uint p_16, float row_0, float column_0, float w_20, float alpha_11, uint nt_1, uint np_1)
{
    float3  _S2004 = worldToTangent(in_dir_13, t_28);
    uint _S2005 = p_16 % 4U;
    float _S2006 = w_20 * HAIR_WIDTHS_0[_S2005];
    float _S2007 = (F32_asin((clamp_1(dot_0(in_dir_13, t_28), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S2005] * alpha_11 + _S2006 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S2006))))));
    float _S2008 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S2004.z), (1.17549435082228751e-38f - _S2004.x)));
    float _S2009 = (F32_cos((_S2007)));
    float3  _S2010 = tangentToWorld(make_float3 (_S2009 * (F32_cos((_S2008))), (F32_sin((_S2007))), _S2009 * (F32_sin((_S2008)))), t_28);
    return _S2010;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_13, BSDFMaterial material_27, float coverage_1)
{
    float3  _S2011;
    if((material_27.ior) == 1.0f)
    {
        float3  _S2012 = straightThrough(material_27);
        _S2011 = _S2012;
    }
    else
    {
        _S2011 = make_float3 (0.0f);
    }
    return _S2011 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_8, Reservoir r_10, bool replay_3, float scale_5, Selection * sel_9)
{
    Domain _S2013 = dom_8;
    Reservoir _S2014 = r_10;
    Shift _S2015 = walk_0(&_S2013, &_S2014, replay_3, scale_5, sel_9);
    return _S2015;
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
