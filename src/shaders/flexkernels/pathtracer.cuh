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
    float3  _S181 = (fcptEnvMapSample((dir_1), (0U), (3U)));
    float3  _S182 = context_0->extinction_behind;
    float3  _S183 = context_0->extinction_front;
    float3  _S184 = _slang_select(_S180, _S183,_S182);
    uint _S185 = context_0->fillings.x;
    uint _S186 = context_0->fillings.y;
    uint _S187 = _slang_select(_S180, _S186,_S185);
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
    float3  _S195 = (fcptShadowTransmittanceIn((_S179), (4.294967296e+09f), (_S184), (_S187), (random_state_0), (_S188), (_S189), (_S191), (_S192), (_S193), (_S194), (_S194)));
    return _S181 * _S195;
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

static __device__ float3  skyFrame_0(float3  dir_2)
{
    float3  _S201 = make_float3 (- dir_2.x, dir_2.z, dir_2.y);
    bool _S202 = ((true));
    float3  _S203 = _slang_select(_S202, _S201,dir_2);
    return _S203;
}

__device__ float shadowLength(float3  shadow_0)
{
    return length_0(shadow_0) * 0.99989998340606689f;
}

static __device__ float3  lightTransmittance_0(float3  origin_2, float3  smooth_n_0, float geometry_offset_0, float3  light_dir_0, ShadowContext * context_1, uint random_state_1, FKHit * light_0)
{
    float3  _S204 = ((((light_dir_0)) * make_float3(rnorm3df(((light_dir_0)).x, ((light_dir_0)).y, ((light_dir_0)).z))));
    bool _S205 = (dot_0(smooth_n_0, _S204)) < 0.0f;
    if(_S205)
    {
        return make_float3 (0.0f);
    }
    float3  _S206 = make_float3 (geometry_offset_0) * smooth_n_0;
    float3  _S207 = origin_2 + _S206;
    FKRay _S208 = Ray_x24init_0(_S207, _S204);
    bool _S209 = (dot_0(context_1->side, light_dir_0 + _S206)) > 0.0f;
    float _S210 = shadowLength(light_dir_0);
    float3  _S211 = context_1->extinction_behind;
    float3  _S212 = context_1->extinction_front;
    float3  _S213 = _slang_select(_S209, _S212,_S211);
    uint _S214 = context_1->fillings.x;
    uint _S215 = context_1->fillings.y;
    uint _S216 = _slang_select(_S209, _S215,_S214);
    uint _S217 = context_1->depth;
    uint _S218 = context_1->lobe;
    bool _S219 = context_1->surface;
    bool _S220;
    if(_S219)
    {
        _S220 = !context_1->fiber;
    }
    else
    {
        _S220 = false;
    }
    float _S221 = context_1->length;
    float _S222 = context_1->width;
    FKHit _S223;
    if(context_1->fiber)
    {
        _S223 = context_1->own;
    }
    else
    {
        _S223 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    }
    float3  _S224 = (fcptShadowTransmittanceIn((_S208), (_S210), (_S213), (_S216), (random_state_1), (_S217), (_S218), (_S220), (_S221), (_S222), (_S223), (*light_0)));
    return _S224;
}

__device__ float sine(float c_0)
{
    return (F32_sqrt(((F32_max((1.0f - c_0 * c_0), (0.0f))))));
}

__device__ float cosSubClamped(float sin_a_0, float cos_a_0, float sin_b_0, float cos_b_0)
{
    float _S225 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    bool _S226 = cos_a_0 > cos_b_0;
    float _S227 = _slang_select(_S226, 1.0f,_S225);
    return _S227;
}

__device__ float importance(LightNode node_0, float3  p_10, float3  normal_0)
{
    float3  _S228 = (node_0.low + node_0.high) * make_float3 (0.5f);
    float3  _S229 = node_0.high - node_0.low;
    float3  _S230 = p_10 - _S228;
    float3  _S231 = ((((_S230)) * make_float3(rnorm3df(((_S230)).x, ((_S230)).y, ((_S230)).z))));
    float _S232 = dot_0(_S230, _S230);
    float _S233 = dot_0(_S229, _S229) / 4.0f;
    float _S234 = (F32_abs((dot_0(node_0.w, _S231))));
    float _S235 = sine(node_0.cos_theta_o);
    float _S236 = (F32_sqrt(((F32_max((1.0f - _S233 / _S232), (0.0f))))));
    bool _S237 = _S232 < _S233;
    float _S238 = _slang_select(_S237, -1.0f,_S236);
    float _S239 = sine(_S238);
    float _S240 = sine(_S234);
    float _S241 = cosSubClamped(_S240, _S234, _S235, node_0.cos_theta_o);
    float _S242 = sine(_S234);
    float _S243 = _S242 * node_0.cos_theta_o - _S234 * _S235;
    bool _S244 = _S234 > (node_0.cos_theta_o);
    float _S245 = _slang_select(_S244, 0.0f,_S243);
    float _S246 = cosSubClamped(_S245, _S241, _S239, _S238);
    bool _S247 = _S246 <= 0.0f;
    if(_S247)
    {
        return 0.0f;
    }
    float _S248 = - dot_0(_S231, normal_0);
    float _S249 = node_0.phi * _S246 / (F32_max((_S232), (length_0(_S229) / 2.0f)));
    float _S250 = sine(_S248);
    float _S251 = cosSubClamped(_S250, _S248, _S239, _S238);
    bool _S252 = (dot_0(normal_0, normal_0)) == 0.0f;
    float _S253 = _slang_select(_S252, 1.0f,_S251);
    return (F32_max((_S249 * _S253), (0.0f)));
}

__device__ __forceinline__ float childShare(LightNode first_0, LightNode second_0, float3  p_11, float3  normal_1, uint child_0)
{
    float _S254 = importance(first_0, p_11, normal_1);
    float _S255 = importance(second_0, p_11, normal_1);
    float2  _S256 = make_float2 (_S254, _S255);
    float _S257 = _slang_vector_get_element(_S256, child_0) / (_S254 + _S255);
    bool _S258 = _slang_vector_get_element(_S256, child_0) > 0.0f;
    float _S259 = _slang_select(_S258, _S257,0.0f);
    return _S259;
}

__device__ float sphereDensity(float3  center_0, float radius_0, float3  p_12)
{
    float3  _S260 = center_0 - p_12;
    float _S261 = radius_0 * radius_0 / dot_0(_S260, _S260);
    bool _S262 = _S261 >= 1.0f;
    if(_S262)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + (F32_sqrt((1.0f - _S261)))) / (6.28318548202514648f * _S261);
}

static __device__ float3  cross_0(float3  left_0, float3  right_0)
{
    float _S263 = left_0.y;
    float _S264 = right_0.z;
    float _S265 = left_0.z;
    float _S266 = right_0.y;
    float _S267 = right_0.x;
    float _S268 = left_0.x;
    return make_float3 (_S263 * _S264 - _S265 * _S266, _S265 * _S267 - _S268 * _S264, _S268 * _S266 - _S263 * _S267);
}

__device__ float solidAngle(float probability_0, float3  normal_2, float3  toward_0)
{
    return 2.0f * probability_0 * (F32_pow((length_0(toward_0)), (3.0f))) / (F32_abs((dot_0(normal_2, toward_0))));
}

static __device__ float lightPdf_0(float3  origin_3, float3  smooth_n_1, float3  start_5, uint j_0, float3  light_point_0)
{
    bool _S269 = j_0 == 4294967295U;
    if(_S269)
    {
        return 0.0f;
    }
    uint4  _S270 = (fcptLightTrail((j_0)));
    uint2  _S271 = uint2 {_S270.x, _S270.y};
    uint n_0 = 0U;
    uint2  trail_0 = _S271;
    float probability_1 = 1.0f;
    for(;;)
    {
        uint4  _S272 = (fcptLightNode((n_0)));
        if((_S272.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S273 = (fcptLightSecond((n_0)));
        uint _S274 = n_0 + 1U;
        LightNode _S275 = (fcptLightBounds((_S274)));
        LightNode _S276 = (fcptLightBounds((_S273)));
        uint _S277 = trail_0.x;
        uint _S278 = _S277 & 1U;
        float _S279 = childShare(_S275, _S276, origin_3, smooth_n_1, _S278);
        float probability_2 = probability_1 * _S279;
        bool _S280 = _S278 == 1U;
        uint _S281 = _slang_select(_S280, _S273,_S274);
        uint _S282 = trail_0.y;
        uint2  _S283 = make_uint2 ((_S277 >> 1U) | (_S282 << 31U), _S282 >> 1U);
        n_0 = _S281;
        trail_0 = _S283;
        probability_1 = probability_2;
    }
    bool _S284 = (fcptSlotLeaf((n_0), (j_0)));
    bool _S285 = !_S284;
    bool _S286;
    if(_S285)
    {
        _S286 = true;
    }
    else
    {
        LightNode _S287 = (fcptLightBounds((n_0)));
        float _S288 = importance(_S287, origin_3, smooth_n_1);
        _S286 = !(_S288 > 0.0f);
    }
    if(_S286)
    {
        _S286 = true;
    }
    else
    {
        bool _S289 = (dot_0(smooth_n_1, smooth_n_1)) > 0.0f;
        if(_S289)
        {
            _S286 = !((dot_0(smooth_n_1, light_point_0 - origin_3)) > 0.0f);
        }
        else
        {
            _S286 = false;
        }
    }
    if(_S286)
    {
        return 0.0f;
    }
    uint4  _S290 = (fcptLightNode((n_0)));
    bool _S291 = (_S290.x) == 2U;
    if(_S291)
    {
        FKLight _S292 = (fcptLight((_S290.y)));
        float _S293 = sphereDensity(_S292.position, _S292.variance, start_5);
        return probability_1 * _S293;
    }
    uint _S294 = _S290.y;
    uint _S295 = (fcptTriangleOffset((_S294)));
    Matrix<float, 3, 3>  _S296 = (fcptWorldTriangle((_S294), (_S295 + _S290.z)));
    float _S297 = solidAngle(probability_1, cross_0(_S296.rows[int(1)] - _S296.rows[int(0)], _S296.rows[int(2)] - _S296.rows[int(0)]), light_point_0 - start_5);
    return _S297;
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
    Random _S298;
    (&_S298)->state = state_0;
    (&_S298)->value = value_0;
    return _S298;
}

__device__ Random pcg(uint state_1)
{
    uint _S299 = hash(state_1);
    float value_1 = float(_S299 >> int(8)) * 5.9604644775390625e-08f;
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

static __device__ float environmentPdf_0(float3  dir_3)
{
    uint2  _S300 = (fcptEnvironmentCdfSize());
    uint2  _S301 = _S300 - make_uint2 (1U, 0U);
    float3  _S302 = skyFrame_0(dir_3);
    float2  _S303 = make_float2 ((F32_atan2((- _S302.z), (- _S302.x))) / 6.28318548202514648f + 0.5f, (F32_acos((clamp_1(_S302.y, -1.0f, 1.0f)))) / 3.14159274101257324f);
    float2  _S304 = make_float2 ((float)_S301.x, (float)_S301.y);
    float2  _S305 = _S303 * _S304;
    uint2  _S306 = make_uint2 ((uint)_S305.x, (uint)_S305.y);
    uint2  _S307 = min_0(_S306, _S301 - make_uint2 (1U));
    float4  _S308 = (fcptEnvironmentCdf((_S307)));
    float _S309 = _S308.y;
    uint _S310 = _S301.x;
    float4  _S311 = (fcptEnvironmentCdf((make_uint2 (_S310, _S307.y))));
    float _S312 = _S309 * _S311.y;
    return _S312 * float(_S310 * _S301.y) / (19.73921012878417969f * length_1(float2 {_S302.x, _S302.z}));
}

static __device__ float3  negate_0(float3  x_13)
{
    return - x_13;
}

static __device__ float sign_0(float e_1)
{
    bool _S313 = e_1 < 0.0f;
    float _S314 = _slang_select(_S313, -1.0f,0.0f);
    bool _S315 = e_1 > 0.0f;
    float _S316 = _slang_select(_S315, 1.0f,_S314);
    return _S316;
}

struct AnisotropicFrame
{
    float3  tangent;
    float2  alphas;
};

static __device__ AnisotropicFrame AnisotropicFrame_x24init_0(float3  tangent_0, float2  alphas_0)
{
    AnisotropicFrame _S317;
    (&_S317)->tangent = tangent_0;
    (&_S317)->alphas = alphas_0;
    return _S317;
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_1)
{
    float3  a_1 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S318 = (F32_abs((dot_0(n_1, a_1)))) > 0.9999847412109375f;
    float3  a_2;
    if(_S318)
    {
        float3  _S319 = make_float3 (1.0f, 0.0f, 0.0f);
        a_2 = _S319;
    }
    else
    {
        a_2 = a_1;
    }
    float3  _S320 = cross_0(n_1, a_2);
    float3  _S321 = ((((_S320)) * make_float3(rnorm3df(((_S320)).x, ((_S320)).y, ((_S320)).z))));
    float3  _S322 = cross_0(n_1, _S321);
    return make_float3 (v_0.x) * _S321 + make_float3 (v_0.y) * n_1 + make_float3 (v_0.z) * _S322;
}

__device__ AnisotropicFrame anisotropicFrame(BSDFMaterial material_0, float3  n_i_0)
{
    float _S323 = material_0.roughness;
    float _S324 = _S323 * _S323;
    bool _S325 = (material_0.anisotropy) == 0.0f;
    bool _S326;
    if(_S325)
    {
        _S326 = true;
    }
    else
    {
        _S326 = !(_S324 > 0.0f);
    }
    if(_S326)
    {
        return AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f));
    }
    float3  _S327 = material_0.tangent - n_i_0 * make_float3 (dot_0(n_i_0, material_0.tangent));
    float3  _S328 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_i_0);
    bool _S329 = (dot_0(_S327, _S327)) > 0.0f;
    float3  _S330 = _slang_select(_S329, _S327,_S328);
    float3  _S331 = ((((_S330)) * make_float3(rnorm3df(((_S330)).x, ((_S330)).y, ((_S330)).z))));
    float _S332 = 6.28318548202514648f * material_0.anisotropic_rotation;
    float _S333 = (F32_sqrt((1.0f - 0.89999997615814209f * (F32_abs((material_0.anisotropy))))));
    float _S334 = 1.0f / _S333;
    bool _S335 = (material_0.anisotropy) < 0.0f;
    float _S336 = _slang_select(_S335, _S334,_S333);
    return AnisotropicFrame_x24init_0(_S331 * make_float3 ((F32_cos((_S332)))) + cross_0(n_i_0, _S331) * make_float3 ((F32_sin((_S332)))), make_float2 (_S324 / _S336, _S324 * _S336));
}

struct SheenProfile
{
    bool on;
    float albedo;
};

static __device__ SheenProfile SheenProfile_x24init_0(bool on_0, float albedo_0)
{
    SheenProfile _S337;
    (&_S337)->on = on_0;
    (&_S337)->albedo = albedo_0;
    return _S337;
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
    SheenProfile _S338 = SheenProfile_x24init_0(false, 0.0f);
    float _S339 = rgb_to_greyscale(material_1.sheen);
    bool _S340 = _S339 > 0.0f;
    SheenProfile profile_0;
    if(_S340)
    {
        float _S341 = clamp_1((F32_sqrt(((F32_max((dot_0(n_i_1, v_1)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S342 = (U32_min((uint(_S341)), (22U)));
        float _S343 = (F32_sqrt((0.05000000074505806f)));
        float _S344 = (F32_sqrt((0.00999999977648258f)));
        bool _S345 = (material_1.velvet) > 0.0f;
        float _S346 = _slang_select(_S345, _S344,_S343);
        float _S347 = (clamp_1((F32_sqrt(((F32_max((material_1.sheen_roughness), (0.0f)))))), _S346, 1.0f) - _S346) / (1.0f - _S346) * 23.0f;
        uint _S348 = (U32_min((uint(_S347)), (22U)));
        uint _S349 = _S342 * 24U + _S348;
        float _S350 = _S341 - float(_S342);
        float _S351 = _S347 - float(_S348);
        if(_S345)
        {
            uint _S352 = _S349 + 24U;
            float _S353 = VELVET_ALBEDO_0[_S349] + (VELVET_ALBEDO_0[_S352] - VELVET_ALBEDO_0[_S349]) * _S350;
            uint _S354 = _S349 + 1U;
            float _S355 = VELVET_ALBEDO_0[_S354] + (VELVET_ALBEDO_0[_S352 + 1U] - VELVET_ALBEDO_0[_S354]) * _S350;
            SheenProfile _S356 = SheenProfile_x24init_0(true, _S353 + (_S355 - _S353) * _S351);
            profile_0 = _S356;
        }
        else
        {
            uint _S357 = _S349 + 24U;
            float _S358 = SHEEN_ALBEDO_0[_S349] + (SHEEN_ALBEDO_0[_S357] - SHEEN_ALBEDO_0[_S349]) * _S350;
            uint _S359 = _S349 + 1U;
            float _S360 = SHEEN_ALBEDO_0[_S359] + (SHEEN_ALBEDO_0[_S357 + 1U] - SHEEN_ALBEDO_0[_S359]) * _S350;
            SheenProfile _S361 = SheenProfile_x24init_0(true, (F32_exp((_S358 + (_S360 - _S358) * _S351))));
            profile_0 = _S361;
        }
    }
    else
    {
        profile_0 = _S338;
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
    BSDFLobes _S362;
    (&_S362)->v_dot_h = v_dot_h_0;
    (&_S362)->n_dot_h = n_dot_h_0;
    (&_S362)->refracted = refracted_1;
    (&_S362)->F = F_0;
    (&_S362)->F_greyscale = F_greyscale_0;
    (&_S362)->reflect_weight = reflect_weight_0;
    (&_S362)->diffuse_weight = diffuse_weight_0;
    (&_S362)->refract_weight = refract_weight_0;
    (&_S362)->p_diffuse = p_diffuse_0;
    (&_S362)->p_reflect = p_reflect_0;
    (&_S362)->p_refract = p_refract_0;
    (&_S362)->translucent_share = translucent_share_0;
    (&_S362)->sheen = sheen_0;
    (&_S362)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S362)->view = view_0;
    (&_S362)->tangent = tangent_1;
    (&_S362)->alphas = alphas_1;
    (&_S362)->visible = visible_0;
    (&_S362)->p_toon = p_toon_0;
    (&_S362)->toon = toon_0;
    (&_S362)->toon_a = toon_a_0;
    (&_S362)->toon_s = toon_s_0;
    (&_S362)->toon_b = toon_b_0;
    (&_S362)->toon_glossy = toon_glossy_0;
    (&_S362)->toon_norm = toon_norm_0;
    (&_S362)->toon_view = toon_view_0;
    (&_S362)->toon_axis = toon_axis_0;
    return _S362;
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
    float3  _S363 = make_float3 (alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z);
    float3  _S364 = ((((_S363)) * make_float3(rnorm3df(((_S363)).x, ((_S363)).y, ((_S363)).z))));
    float _S365 = _S364.x;
    float _S366 = _S364.y;
    float _S367 = _S365 * _S365 + _S366 * _S366;
    float3  _S368 = make_float3 (1.0f, 0.0f, 0.0f);
    float3  _S369 = make_float3 (- _S366, _S365, 0.0f);
    float _S370 = (rsqrtf((_S367)));
    float3  _S371 = _S369 * make_float3 (_S370);
    bool _S372 = _S367 > 0.0f;
    float3  _S373 = _slang_select(_S372, _S371,_S368);
    float3  _S374 = cross_0(_S364, _S373);
    float _S375 = (F32_sqrt((U1_0)));
    float _S376 = 6.28318548202514648f * U2_0;
    float _S377 = _S375 * (F32_cos((_S376)));
    float t2_0 = _S375 * (F32_sin((_S376)));
    float _S378 = 0.5f * (1.0f + _S364.z);
    float t2_1 = (1.0f - _S378) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S377 * _S377)))))) + _S378 * t2_0;
    float3  _S379 = make_float3 (_S377) * _S373 + make_float3 (t2_1) * _S374;
    float _S380 = unshared_0(_S377);
    float _S381 = unshared_0(_S377);
    float3  _S382 = _S379 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S380 * _S381 - t2_1 * t2_1))))))) * _S364;
    float3  _S383 = make_float3 (alpha_0 * _S382.x, alpha_0 * _S382.y, (F32_max((0.0f), (_S382.z))));
    float3  _S384 = ((((_S383)) * make_float3(rnorm3df(((_S383)).x, ((_S383)).y, ((_S383)).z))));
    return _S384;
}

__device__ float3  worldToTangent(float3  v_2, float3  n_3)
{
    float3  a_3 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S385 = (F32_abs((dot_0(n_3, a_3)))) > 0.9999847412109375f;
    float3  a_4;
    if(_S385)
    {
        float3  _S386 = make_float3 (1.0f, 0.0f, 0.0f);
        a_4 = _S386;
    }
    else
    {
        a_4 = a_3;
    }
    float3  _S387 = cross_0(n_3, a_4);
    float3  _S388 = ((((_S387)) * make_float3(rnorm3df(((_S387)).x, ((_S387)).y, ((_S387)).z))));
    float3  _S389 = cross_0(n_3, _S388);
    return make_float3 (dot_0(v_2, _S388), dot_0(v_2, n_3), dot_0(v_2, _S389));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_3, float3  n_i_2, float alpha_1, AnisotropicFrame frame_0, uint * random_state_2)
{
    Random _S390 = pcg(*random_state_2);
    Random _S391 = pcg(_S390.state);
    *random_state_2 = _S391.state;
    float _S392 = frame_0.alphas.x;
    bool _S393 = _S392 > 0.0f;
    if(_S393)
    {
        float3  _S394 = anisotropicLocal(v_3, frame_0.tangent, n_i_2);
        float _S395 = frame_0.alphas.y;
        float3  _S396 = make_float3 (_S392 * _S394.x, _S395 * _S394.y, _S394.z);
        float3  _S397 = ((((_S396)) * make_float3(rnorm3df(((_S396)).x, ((_S396)).y, ((_S396)).z))));
        float3  _S398 = sampleGGXVNDF(_S397, 1.0f, _S390.value, _S391.value);
        float3  _S399 = make_float3 (_S392 * _S398.x, _S395 * _S398.y, _S398.z);
        float3  _S400 = ((((_S399)) * make_float3(rnorm3df(((_S399)).x, ((_S399)).y, ((_S399)).z))));
        return make_float3 (_S400.x) * frame_0.tangent + make_float3 (_S400.y) * cross_0(n_i_2, frame_0.tangent) + make_float3 (_S400.z) * n_i_2;
    }
    float3  _S401 = worldToTangent(v_3, n_i_2);
    float3  _S402 = sampleGGXVNDF(float3 {_S401.x, _S401.z, _S401.y}, alpha_1, _S390.value, _S391.value);
    float3  _S403 = float3 {_S402.x, _S402.z, _S402.y};
    float3  _S404 = tangentToWorld(_S403, n_i_2);
    return _S404;
}

__device__ float3  sampledHalf(float3  in_dir_0, float3  n_4, BSDFMaterial material_2, uint random_state_3, AnisotropicFrame frame_1)
{
    uint state_2 = random_state_3;
    float3  _S405 = negate_0(in_dir_0);
    float _S406 = sign_0(dot_0(n_4, _S405));
    float _S407 = material_2.roughness;
    float3  _S408 = sampleHalfVector(_S405, n_4 * make_float3 (_S406), _S407 * _S407, frame_1, &state_2);
    return _S408;
}

__device__ float3  refractedHalf(float3  in_dir_1, float3  out_dir_0, float3  n_5, float eta_i_0, float eta_o_0)
{
    float3  _S409 = negate_0(in_dir_1);
    float3  _S410 = negate_0(make_float3 (eta_i_0) * _S409 + make_float3 (eta_o_0) * out_dir_0);
    float3  _S411 = ((((_S410)) * make_float3(rnorm3df(((_S410)).x, ((_S410)).y, ((_S410)).z))));
    float _S412 = sign_0(dot_0(n_5, _S409));
    float _S413 = sign_0(dot_0(_S410, n_5 * make_float3 (_S412)));
    return _S411 * make_float3 (_S413);
}

__device__ float3  reflectedHalf(float3  in_dir_2, float3  out_dir_1)
{
    float3  _S414 = negate_0(in_dir_2);
    float3  _S415 = _S414 + out_dir_1;
    float3  _S416 = ((((_S415)) * make_float3(rnorm3df(((_S415)).x, ((_S415)).y, ((_S415)).z))));
    return _S416;
}

static __device__ float3  refract_0(float3  i_5, float3  n_6, float eta_0)
{
    float _S417 = dot_0(n_6, i_5);
    float _S418 = 1.0f - eta_0 * eta_0 * (1.0f - _S417 * _S417);
    if(_S418 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_5 - make_float3 (eta_0 * _S417 + (F32_sqrt((_S418)))) * n_6;
}

__device__ float fresnel(float cos_theta_0, float eta_i_1, float eta_o_1)
{
    float _S419 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S420 = eta_i_1 / eta_o_1 * _S419;
    bool _S421 = _S420 < 1.0f;
    float kr_0;
    if(_S421)
    {
        float _S422 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S420 * _S420))))));
        bool _S423 = eta_i_1 == eta_o_1;
        float _S424 = _slang_select(_S423, cos_theta_0,_S422);
        float _S425 = eta_o_1 * cos_theta_0;
        float _S426 = eta_i_1 * _S424;
        float _S427 = (_S425 - _S426) / (_S425 + _S426);
        float _S428 = eta_i_1 * cos_theta_0;
        float _S429 = eta_o_1 * _S424;
        float _S430 = (_S428 - _S429) / (_S428 + _S429);
        float _S431 = (_S427 * _S427 + _S430 * _S430) / 2.0f;
        kr_0 = _S431;
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

__device__ float anisotropicG1(float3  w_1, float2  alphas_2)
{
    float _S432 = (F32_max((w_1.z), (0.0f)));
    return 2.0f * _S432 / (_S432 + length_0(make_float3 (alphas_2.x * w_1.x, alphas_2.y * w_1.y, _S432)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_3)
{
    float _S433 = alphas_3.x;
    float _S434 = h_0.x / _S433;
    float _S435 = alphas_3.y;
    float _S436 = h_0.y / _S435;
    float _S437 = h_0.z;
    float _S438 = _S434 * _S434 + _S436 * _S436 + _S437 * _S437;
    return 1.0f / (F32_max((3.14159274101257324f * _S433 * _S435 * _S438 * _S438), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ BSDFLobes bsdfLobes(float3  in_dir_3, float3  v_4, float3  n_i_3, float3  ggx_n_0, BSDFMaterial material_3, float eta_i_2, float eta_o_2, AnisotropicFrame frame_2, SheenProfile sheen_profile_0)
{
    float _S439 = dot_0(ggx_n_0, v_4);
    float _S440 = dot_0(n_i_3, ggx_n_0);
    float _S441 = eta_i_2 / eta_o_2;
    float3  _S442 = refract_0(in_dir_3, ggx_n_0, _S441);
    float3  _S443 = ((((_S442)) * make_float3(rnorm3df(((_S442)).x, ((_S442)).y, ((_S442)).z))));
    float _S444 = (F32_min(((F32_sqrt((material_3.specular_level))) * (F32_abs((eta_i_2 - eta_o_2))) / (eta_i_2 + eta_o_2)), (0.9999847412109375f)));
    float _S445 = _S444 * _S444;
    float _S446 = (1.0f + _S444) / (1.0f - _S444);
    float _S447 = (F32_abs((_S439)));
    bool _S448 = eta_i_2 > eta_o_2;
    float _S449 = _slang_select(_S448, _S446,1.0f);
    float _S450 = _slang_select(_S448, 1.0f,_S446);
    float _S451 = fresnel(_S447, _S449, _S450);
    bool _S452 = (eta_i_2 * eta_i_2 * (1.0f - _S439 * _S439)) >= (eta_o_2 * eta_o_2);
    float3  _S453 = material_3.specular_tint * make_float3 (_S445);
    float3  _S454 = _S453 + (make_float3 (1.0f) - _S453) * make_float3 (_S451 - _S445) / make_float3 (1.0f - _S445);
    float3  _S455 = make_float3 (1.0f);
    float3  _S456 = _slang_select(_S452, _S455,_S454);
    float3  _S457 = make_float3 (0.0f);
    float sheen_component_0;
    float3  sheen_1;
    float3  view_1;
    float3  scale_1;
    if(sheen_profile_0.on)
    {
        float _S458 = (F32_min((sheen_profile_0.albedo), (1.0f)));
        float3  _S459 = make_float3 (1.0f) - material_3.sheen * make_float3 (_S458);
        float _S460 = rgb_to_greyscale(material_3.sheen);
        float _S461 = _S460 * _S458;
        float3  _S462 = material_3.sheen / make_float3 ((F32_max((sheen_profile_0.albedo), (1.0f))));
        sheen_component_0 = _S461;
        sheen_1 = _S462;
        view_1 = v_4;
        scale_1 = _S459;
    }
    else
    {
        sheen_component_0 = 0.0f;
        sheen_1 = _S457;
        view_1 = _S457;
        scale_1 = _S455;
    }
    float _S463 = material_3.toon.x;
    bool _S464 = _S463 < 0.0f;
    float _S465 = (F32_abs((_S463)));
    bool _S466 = _S465 > 0.0f;
    float toon_component_0;
    float toon_a_1;
    float toon_s_1;
    float toon_b_1;
    float toon_norm_1;
    float toon_view_1;
    float3  toon_1;
    float3  toon_axis_1;
    bool _S467;
    if(_S466)
    {
        float _S468 = (F32_min((_S465), (1.0f)));
        float3  scale_2 = scale_1 * make_float3 (1.0f - _S468);
        float _S469 = rgb_to_greyscale(material_3.albedo);
        float _S470 = _S468 * _S469;
        float3  _S471 = make_float3 (_S468) * material_3.albedo;
        float toon_a_2 = clamp_1(material_3.toon.y / _S463, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
        float toon_s_2 = clamp_1(material_3.toon.z / _S463, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
        float _S472 = (F32_min((toon_a_2 + toon_s_2), (1.57079637050628662f)));
        if(_S464)
        {
            toon_component_0 = 1.0f - (F32_cos(((F32_min((_S472), (toon_a_2))))));
        }
        else
        {
            float _S473 = (F32_sin(((F32_min((_S472), (toon_a_2))))));
            toon_component_0 = _S473 * _S473 / 2.0f;
        }
        bool _S474 = _S472 > toon_a_2;
        if(_S474)
        {
            _S467 = toon_s_2 > 0.0f;
        }
        else
        {
            _S467 = false;
        }
        if(_S467)
        {
            if(_S464)
            {
                float _S475 = (F32_cos((toon_a_2)));
                float _S476 = (F32_cos((_S472)));
                toon_a_1 = (1.0f + toon_a_2 / toon_s_2) * (_S475 - _S476) - ((F32_sin((_S472))) - _S472 * _S476 - ((F32_sin((toon_a_2))) - toon_a_2 * _S475)) / toon_s_2;
            }
            else
            {
                float _S477 = 2.0f * toon_a_2;
                float _S478 = (F32_cos((_S477)));
                float _S479 = 2.0f * _S472;
                float _S480 = (F32_cos((_S479)));
                toon_a_1 = (1.0f + toon_a_2 / toon_s_2) * (_S478 - _S480) / 4.0f - ((F32_sin((_S479))) / 8.0f - _S472 * _S480 / 4.0f - ((F32_sin((_S477))) / 8.0f - toon_a_2 * _S478 / 4.0f)) / toon_s_2;
            }
            float integral_0 = toon_component_0 + toon_a_1;
            toon_component_0 = integral_0;
        }
        float _S481 = 6.28318548202514648f * toon_component_0;
        float _S482 = dot_0(n_i_3, v_4);
        float _S483 = (F32_acos(((F32_min((_S482), (1.0f))))));
        if(_S483 < toon_a_2)
        {
            toon_component_0 = 1.0f;
        }
        else
        {
            toon_component_0 = (F32_max((1.0f - (_S483 - toon_a_2) / (F32_max((toon_s_2), (0.0000152587890625f)))), (0.0f)));
        }
        if(_S464)
        {
            float3  _S484 = make_float3 (2.0f * _S482) * n_i_3 - v_4;
            float3  _S485 = ((((_S484)) * make_float3(rnorm3df(((_S484)).x, ((_S484)).y, ((_S484)).z))));
            scale_1 = _S485;
        }
        else
        {
            scale_1 = n_i_3;
        }
        float _S486 = toon_component_0;
        toon_component_0 = _S470;
        toon_1 = _S471;
        toon_a_1 = toon_a_2;
        toon_s_1 = toon_s_2;
        toon_b_1 = _S472;
        toon_norm_1 = _S481;
        toon_view_1 = _S486;
        toon_axis_1 = scale_1;
        scale_1 = scale_2;
    }
    else
    {
        toon_component_0 = 0.0f;
        toon_1 = _S457;
        toon_a_1 = 0.0f;
        toon_s_1 = 0.0f;
        toon_b_1 = 0.0f;
        toon_norm_1 = 1.0f;
        toon_view_1 = 0.0f;
        toon_axis_1 = n_i_3;
    }
    float _S487 = frame_2.alphas.x;
    float _S488 = (F32_sqrt(((F32_min((_S487), (frame_2.alphas.y))))));
    bool _S489 = _S487 > 0.0f;
    float _S490 = _slang_select(_S489, _S488,material_3.roughness);
    float _S491 = _S490 * _S490;
    float _S492 = (F32_pow((_S491), (1.81585001945495605f))) * (2.15371990203857422f - 0.73285001516342163f * _S491) / (1.0f + 1.28094995021820068f * _S491);
    bool _S493 = _S491 > 0.0f;
    float _S494 = _slang_select(_S493, _S492,0.0f);
    float _S495 = clamp_1(dot_0(n_i_3, v_4), 0.0f, 1.0f);
    float _S496 = _S491 * _S490;
    float _S497 = (F32_min((1.00064504146575928f - _S490 * (0.00375499995425344f + _S495 * (-0.04133399948477745f + _S495 * (-0.90938502550125122f + _S495 * 0.35275399684906006f))) - _S491 * (0.27602800726890564f + _S495 * (1.27023398876190186f + _S495 * 0.04740000143647194f)) - _S496 * (0.31452900171279907f - _S495 * 0.34830701351165771f) + _S496 * _S490 * 0.27229699492454529f), (1.0f)));
    float3  _S498 = min_1(make_float3 (1.0f) / (make_float3 (1.0f) - material_3.albedo * make_float3 (_S494)), make_float3 (1.0f / (F32_max((_S497), (0.0000152587890625f)))));
    float3  _S499 = mix_0(_S456, material_3.albedo * _S498, material_3.metallic);
    float3  F_1 = _S499 * scale_1;
    float _S500 = rgb_to_greyscale(F_1);
    float _S501 = 1.0f - material_3.metallic;
    float3  _S502 = make_float3 (1.0f) - _S456;
    float3  _S503 = make_float3 ((1.0f - material_3.transmission) * _S501) * _S502 * scale_1;
    float3  _S504 = make_float3 (material_3.transmission * _S501) * _S502 * scale_1;
    float _S505 = (F32_max((_S500), (0.0f)));
    float _S506 = rgb_to_greyscale(_S503);
    float _S507 = (F32_max((_S506), (0.0f)));
    float _S508 = rgb_to_greyscale(_S504);
    float _S509 = sign_0(length_0(_S443));
    float _S510 = (F32_max((_S508 * _S509), (0.0f)));
    float _S511 = _S505 + _S507 + _S510 + toon_component_0;
    float _S512 = (F32_min((sheen_component_0), (1.0f)));
    bool _S513 = sheen_component_0 > 0.0f;
    if(_S513)
    {
        _S467 = !(_S511 > 0.0f);
    }
    else
    {
        _S467 = false;
    }
    float _S514 = _slang_select(_S467, 1.0f,_S512);
    float _S515 = (1.0f - _S514) / (F32_max((_S511), (0.0000152587890625f)));
    float _S516 = _S507 * _S515;
    float _S517 = _S505 * _S515;
    float _S518 = _S510 * _S515;
    float visible_1;
    if(_S489)
    {
        float3  _S519 = anisotropicLocal(v_4, frame_2.tangent, n_i_3);
        float _S520 = anisotropicG1(_S519, frame_2.alphas);
        float3  _S521 = anisotropicLocal(ggx_n_0, frame_2.tangent, n_i_3);
        float _S522 = anisotropicD(_S521, frame_2.alphas);
        float _S523 = _S520 * _S522;
        visible_1 = _S523;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S439, _S440, _S443, F_1, _S500, 1.0f, _S503, _S504, _S516, _S517, _S518, 0.0f, sheen_1, _S514, view_1, frame_2.tangent, frame_2.alphas, visible_1, toon_component_0 * _S515, toon_1, toon_a_1, toon_s_1, toon_b_1, _S464, toon_norm_1, toon_view_1, toon_axis_1);
}

__device__ float translucentShare(BSDFMaterial material_4)
{
    float _S524 = rgb_to_greyscale(material_4.translucent);
    float _S525 = rgb_to_greyscale(material_4.albedo);
    float _S526 = _S524 / (_S525 + _S524);
    bool _S527 = _S524 > 0.0f;
    float _S528 = _slang_select(_S527, _S526,0.0f);
    return _S528;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_2, BSDFLobes lobes_0, float eta_i_3, float eta_o_3)
{
    float _S529 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S530 = lobes_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S531 = 1.0f - lobes_0.translucent_share;
    bool _S532 = n_i_dot_l_0 < 0.0f;
    float _S533 = _slang_select(_S532, lobes_0.translucent_share,_S531);
    float _S534 = _S530 * _S533;
    bool _S535 = (lobes_0.translucent_share) > 0.0f;
    float _S536 = _slang_select(_S535, _S534,_S529);
    bool _S537 = n_i_dot_v_0 > 0.0f;
    float _S538 = _slang_select(_S537, _S536,0.0f);
    return _S538;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_4, float alpha_3, BSDFMaterial material_5, BSDFLobes lobes_1)
{
    bool _S539 = (dot_0(n_i_4, l_0)) < 0.0f;
    float3  _S540 = _slang_select(_S539, material_5.translucent,material_5.albedo);
    float _S541 = 1.0f - lobes_1.translucent_share;
    float _S542 = _slang_select(_S539, lobes_1.translucent_share,_S541);
    float3  _S543 = _S540 / make_float3 (_S542);
    bool _S544 = (lobes_1.translucent_share) > 0.0f;
    float3  _S545 = _slang_select(_S544, _S543,material_5.albedo);
    return lobes_1.diffuse_weight * _S545 / make_float3 (lobes_1.p_diffuse);
}

__device__ float smithG1(float alpha_4, float n_dot_x_0)
{
    float _S546 = alpha_4 * alpha_4;
    float _S547 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S546 + (1.0f - _S546) * n_dot_x_0 * n_dot_x_0))));
    bool _S548 = alpha_4 > 0.0f;
    float _S549 = _slang_select(_S548, _S547,1.0f);
    return _S549;
}

__device__ float trowbridgeReitz(float alpha_5, float n_dot_h_1)
{
    float _S550 = alpha_5 * alpha_5;
    float _S551 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S550 * n_dot_h_1 * n_dot_h_1;
    return _S550 / (F32_max((3.14159274101257324f * _S551 * _S551), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float n_i_dot_v_1, float alpha_6, BSDFLobes lobes_2)
{
    float _S552 = smithG1(alpha_6, n_i_dot_v_1);
    float _S553 = _S552 * lobes_2.v_dot_h;
    float _S554 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    float _S555 = _S553 * _S554 / n_i_dot_v_1;
    bool _S556 = alpha_6 > 0.0f;
    bool _S557;
    if(_S556)
    {
        _S557 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S557 = false;
    }
    if(_S557)
    {
        _S557 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S557 = false;
    }
    if(_S557)
    {
        _S557 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S557 = false;
    }
    float _S558 = _slang_select(_S557, _S555,0.0f);
    bool _S559 = (lobes_2.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S559)
    {
        float _S560 = lobes_2.visible * lobes_2.v_dot_h / n_i_dot_v_1;
        bool _S561 = (lobes_2.v_dot_h) > 0.0f;
        if(_S561)
        {
            _S557 = (lobes_2.n_dot_h) > 0.0f;
        }
        else
        {
            _S557 = false;
        }
        if(_S557)
        {
            _S557 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S557 = false;
        }
        float _S562 = _slang_select(_S557, _S560,0.0f);
        pdf_h_0 = _S562;
    }
    else
    {
        pdf_h_0 = _S558;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float n_i_dot_l_1, float l_dot_h_1, float n_i_dot_v_2, float alpha_7, BSDFLobes lobes_3, float eta_i_4, float eta_o_4)
{
    float _S563 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    float _S564 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    float _S565 = lobes_3.p_refract * _S563 * eta_o_4 * eta_o_4 * (F32_abs((l_dot_h_1))) / (_S564 * _S564);
    bool _S566 = eta_i_4 != eta_o_4;
    bool _S567;
    if(_S566)
    {
        _S567 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S567 = false;
    }
    float _S568 = _slang_select(_S567, _S565,0.0f);
    return _S568;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_5, float alpha_8, BSDFMaterial material_6, BSDFLobes lobes_4)
{
    float _S569 = - dot_0(n_i_5, l_1);
    float _S570 = smithG1(alpha_8, (F32_max((_S569), (0.0f))));
    bool _S571 = (lobes_4.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S571)
    {
        float3  _S572 = negate_0(n_i_5);
        float3  _S573 = anisotropicLocal(l_1, lobes_4.tangent, _S572);
        float _S574 = anisotropicG1(_S573, lobes_4.alphas);
        G1_l_0 = _S574;
    }
    else
    {
        G1_l_0 = _S570;
    }
    return lobes_4.refract_weight * make_float3 (G1_l_0) * material_6.albedo / make_float3 (lobes_4.p_refract);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_2, float l_dot_h_2, float n_i_dot_v_3, float alpha_9, BSDFLobes lobes_5, float eta_i_5, float eta_o_5)
{
    float _S575 = lobes_5.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S576 = n_i_dot_l_2 > 0.0f;
    bool _S577;
    if(_S576)
    {
        _S577 = n_i_dot_v_3 > 0.0f;
    }
    else
    {
        _S577 = false;
    }
    float _S578 = _slang_select(_S577, _S575,0.0f);
    return _S578;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  n_i_6, float alpha_10, BSDFMaterial material_7, BSDFLobes lobes_6)
{
    float3  _S579 = l_2 + lobes_6.view;
    float3  _S580 = ((((_S579)) * make_float3(rnorm3df(((_S579)).x, ((_S579)).y, ((_S579)).z))));
    float _S581 = dot_0(n_i_6, _S580);
    float _S582 = (F32_max((dot_0(n_i_6, l_2)), (0.0f)));
    float _S583 = (F32_max((dot_0(n_i_6, lobes_6.view)), (0.0f)));
    float _S584 = 1.0f / (F32_max((material_7.sheen_roughness), (0.05000000074505806f)));
    float _S585 = 1.0f - _S581 * _S581;
    float _S586 = (2.0f + _S584) * (F32_pow(((F32_max((_S585), (0.0f)))), (0.5f * _S584))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S582 + _S583 - _S582 * _S583)), (0.0000152587890625f)));
    bool _S587 = (material_7.velvet) > 0.0f;
    float f_1;
    if(_S587)
    {
        float _S588 = (F32_max((material_7.sheen_roughness), (0.00999999977648258f)));
        float _S589 = _S588 * _S588;
        float _S590 = (F32_max((_S585), (0.0000152587890625f)));
        float _S591 = (F32_exp((- _S581 * _S581 / (_S590 * _S589)))) / (3.14159274101257324f * _S589 * _S590 * _S590) * (F32_min((1.0f), (2.0f * _S581 * (F32_min((_S582), (_S583))) / (F32_max(((F32_abs((dot_0(_S580, lobes_6.view))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S582 * _S583), (0.0000152587890625f)));
        f_1 = _S591;
    }
    else
    {
        f_1 = _S586;
    }
    return lobes_6.sheen * make_float3 (f_1 * _S582 * 2.0f * 3.14159274101257324f / lobes_6.p_sheen_velvet);
}

__device__ __forceinline__ float toonPDF(float n_i_dot_l_3, float l_dot_h_3, float n_i_dot_v_4, float alpha_11, BSDFLobes lobes_7, float eta_i_6, float eta_o_6)
{
    float _S592 = _slang_select(lobes_7.toon_glossy, l_dot_h_3,n_i_dot_l_3);
    float _S593 = (F32_acos((clamp_1(_S592, -1.0f, 1.0f))));
    float _S594;
    if(_S593 < (lobes_7.toon_a))
    {
        _S594 = 1.0f;
    }
    else
    {
        _S594 = (F32_max((1.0f - (_S593 - lobes_7.toon_a) / (F32_max((lobes_7.toon_s), (0.0000152587890625f)))), (0.0f)));
    }
    float _S595 = lobes_7.p_toon * _S594;
    float _S596 = _slang_select(lobes_7.toon_glossy, 1.0f,n_i_dot_l_3);
    float _S597 = _S595 * _S596 / lobes_7.toon_norm;
    bool _S598;
    if(lobes_7.toon_glossy)
    {
        _S598 = true;
    }
    else
    {
        _S598 = n_i_dot_l_3 > 0.0f;
    }
    float _S599 = _slang_select(_S598, _S597,0.0f);
    return _S599;
}

__device__ __forceinline__ float3  toonBSDF(float3  l_3, float3  n_i_7, float alpha_12, BSDFMaterial material_8, BSDFLobes lobes_8)
{
    float _S600 = (F32_max((dot_0(n_i_7, l_3)), (0.0f)));
    float _S601 = _slang_select(lobes_8.toon_glossy, _S600,lobes_8.toon_view);
    return lobes_8.toon * make_float3 (_S601) / make_float3 (lobes_8.p_toon);
}

__device__ __forceinline__ float reflectPDF(float n_i_dot_l_4, float l_dot_h_4, float n_i_dot_v_5, float alpha_13, BSDFLobes lobes_9, float eta_i_7, float eta_o_7)
{
    float _S602 = vndfPDF(n_i_dot_v_5, alpha_13, lobes_9);
    float _S603 = lobes_9.p_reflect * _S602 / (4.0f * lobes_9.v_dot_h);
    bool _S604 = _S602 > 0.0f;
    float _S605 = _slang_select(_S604, _S603,0.0f);
    return _S605;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_4, float3  n_i_8, float alpha_14, BSDFMaterial material_9, BSDFLobes lobes_10)
{
    float _S606 = dot_0(n_i_8, l_4);
    float _S607 = smithG1(alpha_14, (F32_max((_S606), (0.0f))));
    bool _S608 = (lobes_10.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S608)
    {
        float3  _S609 = anisotropicLocal(l_4, lobes_10.tangent, n_i_8);
        float _S610 = anisotropicG1(_S609, lobes_10.alphas);
        G1_l_1 = _S610;
    }
    else
    {
        G1_l_1 = _S607;
    }
    return make_float3 (lobes_10.reflect_weight * G1_l_1) * lobes_10.F / make_float3 (lobes_10.p_reflect);
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_4, float3  out_dir_2, float3  n_7, BSDFMaterial material_10, float eta_i_8, float eta_o_8, bool refracted_2, uint random_state_4, FixedArray<float3 , 5>  * throughputs_0, FixedArray<float, 5>  * pdfs_0)
{
    float3  ggx_n_1;
    float3  _S611 = negate_0(in_dir_4);
    float _S612 = dot_0(n_7, _S611);
    float _S613 = sign_0(_S612);
    float3  _S614 = n_7 * make_float3 (_S613);
    AnisotropicFrame _S615 = anisotropicFrame(material_10, _S614);
    float _S616 = dot_0(_S614, out_dir_2);
    float _S617 = material_10.roughness;
    float _S618 = _S617 * _S617;
    SheenProfile _S619 = sheenProfile(_S611, _S614, material_10);
    float _S620 = rgb_to_greyscale(material_10.translucent);
    bool _S621 = _S620 > 0.0f;
    bool _S622 = (dot_0(n_7, out_dir_2) * _S612) < 0.0f;
    uint _S623;
    if((F32_abs((material_10.toon.x))) > 0.0f)
    {
        _S623 = 5U;
    }
    else
    {
        _S623 = 4U;
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
        float3  _S624 = make_float3 (0.0f);
        (*throughputs_0)[i_7] = _S624;
        (*pdfs_0)[i_7] = 0.0f;
        uint i_8 = i_7 + 1U;
        i_7 = i_8;
    }
    float3  _S625 = make_float3 (0.0f);
    BSDFLobes _S626 = BSDFLobes_x24init_0(0.0f, 0.0f, _S625, _S625, 0.0f, 0.0f, _S625, _S625, 0.0f, 0.0f, 0.0f, 0.0f, _S625, 0.0f, _S625, _S625, make_float2 (0.0f), 0.0f, 0.0f, _S625, 0.0f, 0.0f, 0.0f, false, 1.0f, 0.0f, _S625);
    BSDFLobes lobe_terms_0 = _S626;
    uint half_of_0 = 4294967295U;
    float3  ggx_n_2 = _S625;
    i_7 = 0U;
    for(;;)
    {
        if(i_7 < _S623)
        {
        }
        else
        {
            break;
        }
        uint _S627;
        if(i_7 == 3U)
        {
            _S627 = 4U;
        }
        else
        {
            if(i_7 == 4U)
            {
                _S627 = 6U;
            }
            else
            {
                _S627 = i_7;
            }
        }
        bool _S628 = _S627 == 0U;
        bool _S629;
        if(_S628)
        {
            _S629 = _S621;
        }
        else
        {
            _S629 = false;
        }
        bool _S630;
        if(_S629)
        {
            _S630 = _S622;
        }
        else
        {
            _S630 = _S627 == 1U;
        }
        bool _S631 = _S630 != refracted_2;
        if(_S631)
        {
            ggx_n_1 = ggx_n_2;
            uint i_9 = i_7 + 1U;
            ggx_n_2 = ggx_n_1;
            i_7 = i_9;
            continue;
        }
        uint _S632;
        if(_S627 == 6U)
        {
            _S632 = 0U;
        }
        else
        {
            if(_S627 == 4U)
            {
                _S632 = 2U;
            }
            else
            {
                _S632 = _S627;
            }
        }
        bool _S633 = _S632 != half_of_0;
        uint half_of_1;
        if(_S633)
        {
            bool _S634 = _S632 == 0U;
            if(_S634)
            {
                float3  _S635 = sampledHalf(in_dir_4, n_7, material_10, random_state_4, _S615);
                ggx_n_1 = _S635;
            }
            else
            {
                bool _S636 = _S632 == 1U;
                if(_S636)
                {
                    float3  _S637 = refractedHalf(in_dir_4, out_dir_2, n_7, eta_i_8, eta_o_8);
                    ggx_n_1 = _S637;
                }
                else
                {
                    float3  _S638 = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_1 = _S638;
                }
            }
            float3  _S639 = negate_0(in_dir_4);
            BSDFLobes _S640 = bsdfLobes(in_dir_4, _S639, _S614, ggx_n_1, material_10, eta_i_8, eta_o_8, _S615, _S619);
            lobe_terms_0 = _S640;
            float _S641 = translucentShare(material_10);
            (&lobe_terms_0)->translucent_share = _S641;
            half_of_1 = _S632;
        }
        else
        {
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S627)
        {
        case 0U:
            {
                float _S642 = diffusePDF(_S616, 0.0f, (F32_abs((_S612))), _S618, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(0)] = _S642;
                float3  _S643 = diffuseBSDF(out_dir_2, _S614, _S618, material_10, lobe_terms_0);
                (*throughputs_0)[int(0)] = _S643;
                break;
            }
        case 1U:
            {
                float _S644 = refractPDF(_S616, dot_0(out_dir_2, ggx_n_1), (F32_abs((_S612))), _S618, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(1)] = _S644;
                float3  _S645 = refractBSDF(out_dir_2, _S614, _S618, material_10, lobe_terms_0);
                (*throughputs_0)[int(1)] = _S645;
                break;
            }
        case 4U:
            {
                float _S646 = sheenVelvetPDF(_S616, 0.0f, (F32_abs((_S612))), _S618, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(3)] = _S646;
                float3  _S647 = sheenVelvetBSDF(out_dir_2, _S614, _S618, material_10, lobe_terms_0);
                (*throughputs_0)[int(3)] = _S647;
                break;
            }
        case 6U:
            {
                float _S648 = toonPDF(_S616, dot_0(out_dir_2, (&lobe_terms_0)->toon_axis), (F32_abs((_S612))), _S618, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(4)] = _S648;
                float3  _S649 = toonBSDF(out_dir_2, _S614, _S618, material_10, lobe_terms_0);
                (*throughputs_0)[int(4)] = _S649;
                break;
            }
        default:
            {
                float _S650 = reflectPDF(_S616, 0.0f, (F32_abs((_S612))), _S618, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(2)] = _S650;
                float3  _S651 = reflectBSDF(out_dir_2, _S614, _S618, material_10, lobe_terms_0);
                (*throughputs_0)[int(2)] = _S651;
                break;
            }
        }
        half_of_0 = half_of_1;
        uint i_9 = i_7 + 1U;
        ggx_n_2 = ggx_n_1;
        i_7 = i_9;
    }
    i_7 = 0U;
    ggx_n_1 = _S625;
    for(;;)
    {
        if(i_7 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S652 = ((*pdfs_0)[i_7]) > 0.0f;
        if(_S652)
        {
            float3  f_2 = ggx_n_1 + (*throughputs_0)[i_7] * make_float3 ((*pdfs_0)[i_7]);
            ggx_n_1 = f_2;
        }
        uint i_10 = i_7 + 1U;
        i_7 = i_10;
    }
    return ggx_n_1;
}

static __device__ __forceinline__ float3  skyLobes_0(float3  in_dir_5, float3  dir_4, FKSurface * surface_1, float2  eta_1, bool is_inside_2, float pdf_0, uint random_state_5, FixedArray<float3 , 5>  * terms_0, FixedArray<float, 5>  * pdfs_1)
{
    bool _S653 = wrongSide_0(is_inside_2, false, dir_4, surface_1->geometry_n);
    float3  _S654 = BSDF(in_dir_5, dir_4, surface_1->smooth_n, surface_1->material, eta_1.x, eta_1.y, _S653, random_state_5, terms_0, pdfs_1);
    float3  _S655 = make_float3 (0.0f);
    uint i_11 = 0U;
    float3  f_3 = _S655;
    for(;;)
    {
        if(i_11 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S656 = ((*pdfs_1)[i_11]) > 0.0f;
        if(_S656)
        {
            float3  _S657 = (*terms_0)[i_11] * make_float3 ((*pdfs_1)[i_11]) / make_float3 ((*pdfs_1)[i_11] + pdf_0);
            (*terms_0)[i_11] = _S657;
            float3  f_4 = f_3 + (*terms_0)[i_11];
            f_3 = f_4;
        }
        uint i_12 = i_11 + 1U;
        i_11 = i_12;
    }
    return f_3;
}

__device__ float3  skyBSDF(float3  in_dir_6, float3  dir_5, FKSurface surface_2, float2  eta_2, bool is_inside_3, float pdf_1, uint random_state_6)
{
    FKSurface _S658 = surface_2;
    FixedArray<float3 , 5>  terms_1;
    FixedArray<float, 5>  pdfs_2;
    float3  _S659 = skyLobes_0(in_dir_6, dir_5, &_S658, eta_2, is_inside_3, pdf_1, random_state_6, &terms_1, &pdfs_2);
    return _S659;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_6, float3  radiance_0, float3  color_0, uint random_state_7)
{
    SkySample _S660;
    (&_S660)->dir = dir_6;
    (&_S660)->radiance = radiance_0;
    (&_S660)->color = color_0;
    (&_S660)->random_state = random_state_7;
    return _S660;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_3, float2  eta_3, bool is_inside_4, uint init_random_state_0, uint lobe_state_0, ShadowContext * context_2)
{
    uint2  _S661 = (fcptEnvironmentCdfSize());
    uint2  _S662 = make_uint2 (1U, 0U);
    uint2  _S663 = _S661 - _S662;
    Random _S664 = pcg(init_random_state_0);
    Random _S665 = pcg(_S664.state);
    Random _S666 = pcg(_S665.state);
    Random _S667 = pcg(_S666.state);
    uint _S668 = _S663.x;
    uint _S669 = searchCDF_0(make_uint2 (_S668, 0U), make_uint2 (0U, 1U), _S663.y, _S664.value);
    uint _S670 = searchCDF_0(make_uint2 (0U, _S669), _S662, _S668, _S665.value);
    float2  _S671 = make_float2 ((float)_S663.x, (float)_S663.y);
    float2  _S672 = (make_float2 (float(_S670), float(_S669)) + make_float2 (_S666.value, _S667.value)) / _S671 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S673 = _S672.y;
    float _S674 = (F32_sin((_S673)));
    float _S675 = _S672.x;
    float3  _S676 = skyFrame_0(make_float3 (_S674 * (F32_cos((_S675))), (F32_cos((_S673))), _S674 * (F32_sin((_S675)))));
    float _S677 = environmentPdf_0(_S676);
    float3  _S678 = skyBSDF(ray_0->unit_direction, _S676, *surface_3, eta_3, is_inside_4, _S677, lobe_state_0);
    bool _S679 = !(_S677 > 0.0f);
    bool _S680;
    if(_S679)
    {
        _S680 = true;
    }
    else
    {
        _S680 = all_1(_S678 == make_float3 (0.0f));
    }
    if(_S680)
    {
        float3  _S681 = make_float3 (0.0f);
        return SkySample_x24init_0(_S676, _S681, _S681, _S667.state);
    }
    float3  _S682 = skyRadiance_0(ray_0->origin, surface_3, is_inside_4, _S676, context_2, _S667.state);
    return SkySample_x24init_0(_S676, _S682, _S678 * _S682, _S667.state);
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
    SampleBSDF _S683 = (fcptConnectHair((surface_4->hair), ((&surface_4->material)->albedo), ((&surface_4->material)->specular_tint), (in_dir_7), (light_1->dir)));
    float3  _S684 = _S683.throughput * make_float3 (_S683.pdf);
    float _S685 = light_1->density;
    float _S686 = 1.0f + _S683.pdf * _S683.pdf / (light_1->density * light_1->density);
    bool _S687;
    if(competing_0)
    {
        _S687 = _S685 > 0.0f;
    }
    else
    {
        _S687 = false;
    }
    float _S688 = _slang_select(_S687, _S686,1.0f);
    return _S684 / make_float3 (_S688) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_7, float3  radiance_1, float density_0, uint random_state_8)
{
    TreeSample _S689;
    (&_S689)->dir = dir_7;
    (&_S689)->radiance = radiance_1;
    (&_S689)->density = density_0;
    (&_S689)->random_state = random_state_8;
    return _S689;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_13, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S690 = importance(first_1, p_13, normal_3);
    float _S691 = importance(second_1, p_13, normal_3);
    float2  _S692 = make_float2 (_S690, _S691);
    bool _S693 = _S690 == 0.0f;
    bool _S694;
    if(_S693)
    {
        _S694 = _S691 == 0.0f;
    }
    else
    {
        _S694 = false;
    }
    if(_S694)
    {
        return 2U;
    }
    float _S695 = _S690 + _S691;
    bool _S696 = _S691 > 0.0f;
    if(_S696)
    {
        _S694 = (*pick_0 * _S695) >= _S690;
    }
    else
    {
        _S694 = false;
    }
    uint _S697 = uint(_S694);
    float _S698 = (F32_min(((*pick_0 * _S695 - float(_S697) * _S690) / _slang_vector_get_element(_S692, _S697)), (0.99999994039535522f)));
    *pick_0 = _S698;
    float _S699 = *probability_3 * (_slang_vector_get_element(_S692, _S697) / _S695);
    *probability_3 = _S699;
    return _S697;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_14, float u1_0, float u2_0)
{
    float3  _S700 = center_1 - p_14;
    float _S701 = radius_1 * radius_1 / dot_0(_S700, _S700);
    float _S702 = u1_0 * _S701 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S701), (0.0f)))))));
    float _S703 = 2.0f * u1_0;
    bool _S704 = _S701 >= 1.0f;
    float _S705 = _slang_select(_S704, _S703,_S702);
    float _S706 = (F32_sqrt(((F32_max((_S705 * (2.0f - _S705)), (0.0f))))));
    float _S707 = 6.28318548202514648f * u2_0;
    float3  _S708 = make_float3 (_S706 * (F32_cos((_S707))), 1.0f - _S705, _S706 * (F32_sin((_S707))));
    float3  _S709 = ((((_S700)) * make_float3(rnorm3df(((_S700)).x, ((_S700)).y, ((_S700)).z))));
    float3  _S710 = tangentToWorld(_S708, _S709);
    return _S710;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S711 = center_2 - ray_1->origin;
    float _S712 = dot_0(_S711, ray_1->unit_direction);
    float _S713 = dot_0(_S711, _S711) - _S712 * _S712;
    float _S714 = radius_3 * radius_3;
    bool _S715 = _S713 > _S714;
    if(_S715)
    {
        return 4.294967296e+09f;
    }
    float _S716 = (F32_sqrt((_S714 - _S713)));
    float _S717 = _S712 - _S716;
    float _S718 = _S712 + _S716;
    bool _S719 = _S717 > 0.0000152587890625f;
    bool _S720;
    if(_S719)
    {
        _S720 = _S717 < max_len_0;
    }
    else
    {
        _S720 = false;
    }
    if(_S720)
    {
        return _S717;
    }
    bool _S721 = _S718 > 0.0000152587890625f;
    if(_S721)
    {
        _S720 = _S718 < max_len_0;
    }
    else
    {
        _S720 = false;
    }
    if(_S720)
    {
        return _S718;
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
        *_slang_vector_get_element_ptr(&result_6, j_1) = sum_0;
        j_1 = j_1 + int(1);
    }
    return result_6;
}

static __device__ float3  emitted_0(float3  emissive_0, float3  dir_8, float3  n_8)
{
    float _S722 = sign_0(dot_0(- dir_8, n_8));
    float3  _S723 = emissive_0 * make_float3 ((F32_max((_S722), (0.0f))));
    bool _S724 = ((true));
    float3  _S725 = _slang_select(_S724, emissive_0,_S723);
    return _S725;
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
    uint n_9 = 0U;
    for(;;)
    {
        uint4  _S733 = (fcptLightNode((n_9)));
        if((_S733.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S734 = (fcptLightSecond((n_9)));
        uint _S735 = n_9 + 1U;
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
        n_9 = _S741;
    }
    bool _S742 = n_9 == 0U;
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
    uint4  _S746 = (fcptLightNode((n_9)));
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
            float3  _S780 = emitted_0(_S779.material.emissive, (&sample_0)->dir, _S779.smooth_n);
            float3  _S781 = _slang_select(_S779.skip, _S729,_S780);
            float3  _S782 = _S781 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S782;
        }
        shadow_1 = _S774;
        emitter_0 = emitter_1;
        emitter_point_0 = _S770;
    }
    FKHit _S783 = emitter_0;
    float3  _S784 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S728.state, &_S783);
    bool _S785 = (fcptShadowFirst());
    if(_S785)
    {
        _S743 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S743 = false;
    }
    if(_S743)
    {
        _S743 = !all_1(_S784 == _S729);
    }
    else
    {
        _S743 = false;
    }
    if(_S743)
    {
        FKSurface _S786 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S728.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S786.random_state;
        float3  _S787 = emitted_0(_S786.material.emissive, (&sample_0)->dir, _S786.smooth_n);
        float3  _S788 = _slang_select(_S786.skip, _S729,_S787);
        float3  _S789 = _S788 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S789;
    }
    float3  _S790 = (&sample_0)->radiance * _S784;
    bool _S791 = all_1(_S784 == _S729);
    float3  _S792 = _slang_select(_S791, _S729,_S790);
    (&sample_0)->radiance = _S792;
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
    float _S793 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    bool _S794 = b_1 > 0.0f;
    float _S795 = _slang_select(_S794, _S793,1.0f);
    return _S795;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S796 = vertex_0->none;
    if(_S796)
    {
        return 1.0f;
    }
    uint _S797 = (fcptLightSlot((*hit_1)));
    float _S798 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S797, light_point_1);
    float _S799 = powerHeuristic(vertex_0->pdf, _S798);
    return _S799;
}

static __device__ float3  environment_0(float3  dir_9, uint depth_0, uint lobe_0)
{
    uint2  _S800 = (fcptEnvironmentMapSize());
    bool _S801 = all_0(_S800 > make_uint2 (1U));
    if(_S801)
    {
        float3  _S802 = (fcptEnvMapSample((dir_9), (depth_0), (lobe_0)));
        return _S802;
    }
    float3  _S803 = (fcptAmbient());
    return _S803;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S804 = (fcptEnvironmentCdfSize());
    bool _S805 = !all_0(_S804 > make_uint2 (1U));
    if(_S805)
    {
        return false;
    }
    uint2  _S806 = (fcptEnvironmentMapSize());
    return all_0(_S806 > make_uint2 (1U));
}

static __device__ float escapeWeight_0(float pdf_2, float3  dir_10)
{
    bool _S807 = pdf_2 <= 0.0f;
    bool _S808;
    if(_S807)
    {
        _S808 = true;
    }
    else
    {
        bool _S809 = environmentMapped_0();
        _S808 = !_S809;
    }
    if(_S808)
    {
        return 1.0f;
    }
    float _S810 = environmentPdf_0(dir_10);
    return pdf_2 / (pdf_2 + _S810);
}

static __device__ void restir_duplicates_0(uint3  global_invocation_id_1, uint3  local_invocation_id_0, uint local_invocation_index_3)
{
    uint2  _S811 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S812 = make_int2 ((int)_S811.x, (int)_S811.y);
    uint _S813 = previousSeed_0(_S812);
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
            uint _S814 = previousSeed_0(_S812 + make_int2 (x_16, y_5));
            bool _S815 = _S814 == _S813;
            uint _S816 = _slang_select(_S815, 1U,0U);
            uint count_3 = count_2 + _S816;
            int x_17 = x_16 + int(1);
            x_16 = x_17;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S817 = float(count_2 - 1U) / 288.0f;
    bool _S818 = _S813 != 0U;
    float _S819 = _slang_select(_S818, _S817,0.0f);
    fcptStoreDuplication((_S812), (make_uint4 ((F32_asuint((_S819))), 0U, 0U, 0U)));
    return;
}

__device__ uint stream(uint seed_3, uint index_0)
{
    uint _S820 = hash(index_0);
    uint _S821 = hash(seed_3 ^ _S820);
    return _S821;
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
    float _S822 = rgb_to_greyscale(weight_0);
    bool _S823 = _S822 > 0.0f;
    bool _S824;
    if(_S823)
    {
        _S824 = _S822 < 3.00000000549775576e+38f;
    }
    else
    {
        _S824 = false;
    }
    bool _S825 = !_S824;
    if(_S825)
    {
        return;
    }
    bool _S826 = sel_2->sums;
    if(_S826)
    {
        float3  _S827 = sel_2->color + weight_0;
        sel_2->color = _S827;
        return;
    }
    float _S828 = sel_2->w_sum + _S822;
    sel_2->w_sum = _S828;
    float3  _S829 = sel_2->color + weight_0;
    sel_2->color = _S829;
    Random _S830 = pcg(sel_2->random_state);
    sel_2->random_state = _S830.state;
    bool _S831 = (_S830.value * sel_2->w_sum) <= _S822;
    if(_S831)
    {
        sel_2->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_3;
    float3  _S832 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S832;
    float _S833 = r_3.jac * shifted_0.jac;
    (&candidate_1)->jac = _S833;
    offer(sel_3, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S834 = rgb_to_greyscale((&r_4)->f);
    float _S835 = sel_4.w_sum / _S834;
    bool _S836 = _S834 > 0.0f;
    float _S837 = _slang_select(_S836, _S835,0.0f);
    (&r_4)->w = _S837;
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
    uint2  _S838 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S839 = make_int2 ((int)_S838.x, (int)_S838.y);
    float3  _S840 = make_float3 (0.0f);
    FKHit _S841 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S842 = Domain_x24init_0(_S840, _S840, &_S841, 0.0f, 0.0f);
    Domain dom_4 = _S842;
    bool _S843 = (fcptCurrentDomain((_S839), (&dom_4)));
    bool _S844 = !_S843;
    if(_S844)
    {
        Reservoir _S845 = (Reservoir{});
        fcptStoreReservoirPrevious((_S839), (_S845), ((&dom_4)->hit));
        return;
    }
    Reservoir _S846 = (fcptLoadReservoirTemporal((_S839)));
    uint t_13 = 0U;
    float count_4 = 0.0f;
    float c_sum_0 = _S846.c;
    for(;;)
    {
        uint _S847 = (fcptRestirNeighbours());
        if(t_13 < _S847)
        {
        }
        else
        {
            break;
        }
        int2  _S848 = partner_0(_S839, t_13);
        Domain neighbor_0 = _S842;
        bool _S849 = (fcptCurrentDomain((_S848), (&neighbor_0)));
        if(_S849)
        {
            float count_5 = count_4 + 1.0f;
            uint4  _S850 = (fcptReservoirTemporal((_S848), (0U)));
            float c_sum_1 = c_sum_0 + (U32_asfloat((_S850.w)));
            count_4 = count_5;
            c_sum_0 = c_sum_1;
        }
        uint t_14 = t_13 + 1U;
        t_13 = t_14;
    }
    float _S851 = _S846.c / (F32_max((count_4), (1.0f)));
    float _S852 = rgb_to_greyscale(_S846.f);
    bool _S853 = count_4 == 0.0f;
    float _S854 = _slang_select(_S853, 1.0f,0.0f);
    Selection _S855 = (Selection{});
    Selection sel_5 = _S855;
    uint _S856 = (fcptFrame());
    uint _S857 = hash(_S856);
    uint _S858 = global_invocation_id_2.x;
    uint2  _S859 = (fcptRenderSize());
    uint _S860 = stream(_S857, _S858 + _S859.x * global_invocation_id_2.y);
    uint _S861 = stream(_S860, 195U);
    (&sel_5)->random_state = _S861;
    t_13 = 0U;
    float canonical_mis_0 = _S854;
    for(;;)
    {
        uint _S862 = (fcptRestirNeighbours());
        if(t_13 < _S862)
        {
        }
        else
        {
            break;
        }
        int2  _S863 = partner_0(_S839, t_13);
        Domain neighbor_dom_0 = _S842;
        bool _S864 = (fcptCurrentDomain((_S863), (&neighbor_dom_0)));
        if(_S864)
        {
            Reservoir _S865 = (fcptLoadReservoirTemporal((_S863)));
            uint4  _S866 = (fcptShiftData((_S863), (t_13)));
            float4  _S867 = asfloat_0(_S866);
            uint4  _S868 = (fcptShiftData((_S839), (t_13)));
            float4  _S869 = asfloat_0(_S868);
            float _S870 = (_S865.c + _S851) / c_sum_0;
            bool _S871 = _S852 > 0.0f;
            float canonical_mis_1;
            if(_S871)
            {
                float _S872 = _S870 * _S851 * _S852;
                float _S873 = _S851 * _S852;
                float _S874 = rgb_to_greyscale(float3 {_S869.x, _S869.y, _S869.z});
                float canonical_mis_2 = canonical_mis_0 + _S872 / (_S873 + _S865.c * _S874);
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float _S875 = rgb_to_greyscale(_S865.f);
            float3  _S876 = float3 {_S867.x, _S867.y, _S867.z};
            Shift _S877 = Shift_x24init_0(_S876, _S867.w);
            float _S878 = _S870 * _S865.c * _S875;
            float _S879 = _S865.c * _S875;
            float _S880 = rgb_to_greyscale(_S876);
            offerShifted(&sel_5, _S865, _S877, _S878 / (_S879 + _S851 * _S880));
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_15 = t_13 + 1U;
        t_13 = t_15;
    }
    offerShifted(&sel_5, _S846, Shift_x24init_0(_S846.f, 1.0f), canonical_mis_0);
    Reservoir _S881 = finalize(sel_5, c_sum_0);
    fcptStoreReservoirPrevious((_S839), (_S881), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S839), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S839), (make_float4 ((&sel_5)->color.x, (&sel_5)->color.y, (&sel_5)->color.z, 0.0f)));
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
    uint _S882 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S883 = _S882 != 4294967295U;
    if(_S883)
    {
        uint2  _S884 = make_uint2 (_S882, _S882 >> 14U) & make_uint2 (16383U);
        int2  _S885 = make_int2 ((int)_S884.x, (int)_S884.y);
        ShiftJob _S886 = (ShiftJob{});
        ShiftJob shift_job_0 = _S886;
        Shift _S887 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S888 = _S882 >> 28U;
        bool _S889 = spatialJob_0(_S885, _S888, &shift_job_0, true);
        Shift shifted_1;
        if(_S889)
        {
            Domain _S890 = (&shift_job_0)->dom;
            Reservoir _S891 = (&shift_job_0)->r;
            Shift _S892 = passShift_0(&_S890, &_S891);
            shifted_1 = _S892;
        }
        else
        {
            shifted_1 = _S887;
        }
        fcptStoreShiftData((_S885), (_S888), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S893 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S894 = make_int2 ((int)_S893.x, (int)_S893.y);
    FixedArray<uint, 3>  _S895;
    spatialBins_0(_S894, &_S895);
    FixedArray<uint, 3>  _S896 = _S895;
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
        bool _S897 = (_S896[t_16]) == 40U;
        if(_S897)
        {
            fcptStoreShiftData((_S894), (t_16), (make_uint4 (0U)));
        }
        uint t_17 = t_16 + 1U;
        t_16 = t_17;
    }
    FixedArray<uint, 3>  _S898 = _S896;
    queueShifts_0(_S894, &_S898, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S899 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S900 = make_int2 ((int)_S899.x, (int)_S899.y);
    FixedArray<uint, 3>  _S901;
    spatialBins_0(_S900, &_S901);
    FixedArray<uint, 3>  _S902 = _S901;
    countShifts_0(&_S902, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S903 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S904 = _S903 != 4294967295U;
    if(_S904)
    {
        uint2  _S905 = make_uint2 (_S903, _S903 >> 14U) & make_uint2 (16383U);
        int2  _S906 = make_int2 ((int)_S905.x, (int)_S905.y);
        int2  _S907 = storedNeighbor_0(_S906);
        uint _S908 = _S903 >> 28U;
        Shift _S909 = temporalShiftAt_0(_S906, _S907, _S908);
        fcptStoreTemporalShift((_S906), (_S908), (make_uint4 (asuint_1(_S909.f).x, asuint_1(_S909.f).y, asuint_1(_S909.f).z, (F32_asuint((_S909.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S910 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S911 = make_int2 ((int)_S910.x, (int)_S910.y);
    FixedArray<uint, 3>  _S912;
    temporalBins_0(_S911, &_S912);
    FixedArray<uint, 3>  _S913 = _S912;
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
        bool _S914 = (_S913[t_18]) == 40U;
        if(_S914)
        {
            fcptStoreTemporalShift((_S911), (t_18), (make_uint4 (0U)));
        }
        uint t_19 = t_18 + 1U;
        t_18 = t_19;
    }
    FixedArray<uint, 3>  _S915 = _S913;
    queueShifts_0(_S911, &_S915, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S916 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S917 = make_int2 ((int)_S916.x, (int)_S916.y);
    bool _S918 = (fcptSceneUnchanged());
    bool _S919 = !_S918;
    bool _S920;
    if(_S919)
    {
        uint2  _S921 = (fcptRenderSize());
        int2  _S922 = make_int2 ((int)_S921.x, (int)_S921.y);
        _S920 = all_0(_S917 < _S922);
    }
    else
    {
        _S920 = false;
    }
    if(_S920)
    {
        Reservoir _S923 = (fcptLoadReservoirInitial((_S917)));
        int2  _S924 = sampleNeighbor_0(_S917, _S923.seed);
        fcptStoreTemporalNeighbor((_S917), (_S924));
    }
    FixedArray<uint, 3>  _S925;
    temporalBins_0(_S917, &_S925);
    FixedArray<uint, 3>  _S926 = _S925;
    countShifts_0(&_S926, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_6, float b_2, float t_20)
{
    return a_6 + (b_2 - a_6) * t_20;
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S927 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S928 = make_int2 ((int)_S927.x, (int)_S927.y);
    float3  _S929 = make_float3 (0.0f);
    FKHit _S930 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S931 = Domain_x24init_0(_S929, _S929, &_S930, 0.0f, 0.0f);
    Domain dom_5 = _S931;
    bool _S932 = (fcptCurrentDomain((_S928), (&dom_5)));
    bool _S933 = !_S932;
    if(_S933)
    {
        Reservoir _S934 = (Reservoir{});
        fcptStoreReservoirTemporal((_S928), (_S934), ((&dom_5)->hit));
        return;
    }
    Reservoir _S935 = (fcptLoadReservoirInitial((_S928)));
    bool _S936 = (fcptTemporalQueued());
    bool _S937 = (fcptSceneUnchanged());
    bool _S938;
    if(_S937)
    {
        _S938 = true;
    }
    else
    {
        _S938 = !_S936;
    }
    int2  _S939;
    if(_S938)
    {
        int2  _S940 = sampleNeighbor_0(_S928, _S935.seed);
        _S939 = _S940;
    }
    else
    {
        int2  _S941 = (fcptLoadTemporalNeighbor((_S928)));
        _S939 = _S941;
    }
    bool _S942 = (_S939.x) >= int(0);
    Reservoir r_5;
    if(_S942)
    {
        Reservoir _S943 = (fcptLoadReservoirPrevious((_S939)));
        uint4  _S944 = (fcptDuplication((_S939)));
        float _S945 = (U32_asfloat((_S944.x)));
        uint _S946 = (fcptRestirDecorrelation());
        bool _S947 = _S946 == 1U;
        float _S948 = _slang_select(_S947, _S945,0.0f);
        float _S949 = interpolate_0(20.0f, 1.0f, (F32_pow((_S948), (0.10000000149011612f))));
        float _S950 = (F32_min((_S943.c), (_S949)));
        bool _S951 = (fcptSceneUnchanged());
        float4  _S952 = make_float4 (_S943.f.x, _S943.f.y, _S943.f.z, 1.0f);
        bool _S953 = !_S951;
        if(_S953)
        {
            _S938 = _S936;
        }
        else
        {
            _S938 = false;
        }
        float4  to_current_0;
        if(_S938)
        {
            uint4  _S954 = (fcptTemporalShift((_S928), (0U)));
            float4  _S955 = asfloat_0(_S954);
            to_current_0 = _S955;
        }
        else
        {
            if(_S953)
            {
                Shift _S956 = temporalShiftAt_0(_S928, _S939, 0U);
                float4  _S957 = make_float4 (_S956.f.x, _S956.f.y, _S956.f.z, _S956.jac);
                to_current_0 = _S957;
            }
            else
            {
                to_current_0 = _S952;
            }
        }
        Domain own_1 = _S931;
        if(_S951)
        {
            _S938 = true;
        }
        else
        {
            bool _S958 = (fcptPreviousScenes());
            bool _S959 = !_S958;
            if(_S959)
            {
                _S938 = (_S935.w) > 0.0f;
            }
            else
            {
                _S938 = false;
            }
            if(_S938)
            {
                bool _S960 = (fcptStoredDomainInitial((_S928), (_S935.seed), (&own_1)));
                _S938 = _S960;
            }
            else
            {
                _S938 = false;
            }
            if(_S938)
            {
                Domain _S961 = (fcptPreviousDomain((_S939), (_S935.seed)));
                Domain _S962 = _S961;
                Domain _S963 = own_1;
                bool _S964 = sameDomain_0(&_S962, &_S963);
                _S938 = _S964;
            }
            else
            {
                _S938 = false;
            }
        }
        float4  _S965 = make_float4 (_S935.f.x, _S935.f.y, _S935.f.z, 1.0f);
        bool _S966 = !_S938;
        if(_S966)
        {
            _S938 = _S936;
        }
        else
        {
            _S938 = false;
        }
        float4  to_previous_0;
        if(_S938)
        {
            uint4  _S967 = (fcptTemporalShift((_S928), (1U)));
            float4  _S968 = asfloat_0(_S967);
            to_previous_0 = _S968;
        }
        else
        {
            if(_S966)
            {
                Shift _S969 = temporalShiftAt_0(_S928, _S939, 1U);
                float4  _S970 = make_float4 (_S969.f.x, _S969.f.y, _S969.f.z, _S969.jac);
                to_previous_0 = _S970;
            }
            else
            {
                to_previous_0 = _S965;
            }
        }
        float _S971 = rgb_to_greyscale(_S935.f);
        float _S972 = rgb_to_greyscale(_S943.f);
        Selection _S973 = (Selection{});
        Selection sel_6 = _S973;
        uint _S974 = (fcptFrame());
        uint _S975 = hash(_S974);
        uint _S976 = global_invocation_id_7.x;
        uint2  _S977 = (fcptRenderSize());
        uint _S978 = stream(_S975, _S976 + _S977.x * global_invocation_id_7.y);
        uint _S979 = stream(_S978, 194U);
        (&sel_6)->random_state = _S979;
        float _S980 = _S935.c * _S971;
        float4  _S981 = to_previous_0;
        float _S982 = rgb_to_greyscale(float3 {_S981.x, _S981.y, _S981.z});
        float _S983 = _S980 / (_S980 + _S950 * _S982);
        float _S984 = _S950 * _S972;
        float4  _S985 = to_current_0;
        float3  _S986 = float3 {_S985.x, _S985.y, _S985.z};
        float _S987 = rgb_to_greyscale(_S986);
        float _S988 = _S984 / (_S984 + _S935.c * _S987);
        float2  _S989 = make_float2 (_S983, _S988);
        offerShifted(&sel_6, _S935, Shift_x24init_0(_S935.f, 1.0f), _S983);
        offerShifted(&sel_6, _S943, Shift_x24init_0(_S986, to_current_0.w), _S988);
        Reservoir _S990 = finalize(sel_6, _S935.c + _S950);
        r_5 = _S990;
    }
    else
    {
        r_5 = _S935;
    }
    fcptStoreReservoirTemporal((_S928), (r_5), ((&dom_5)->hit));
    return;
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S991 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S992 = make_int2 ((int)_S991.x, (int)_S991.y);
    float3  _S993 = make_float3 (0.0f);
    float2  _S994 = make_float2 (0.0f);
    FKHit _S995 = Hit_x24init_0(_S994, 0U, 0U, 0U, 0.0f);
    Domain _S996 = Domain_x24init_0(_S993, _S993, &_S995, 0.0f, 0.0f);
    Domain dom_6 = _S996;
    bool _S997 = (fcptCurrentDomain((_S992), (&dom_6)));
    bool _S998 = !_S997;
    if(_S998)
    {
        Reservoir _S999 = (Reservoir{});
        fcptStoreReservoirInitial((_S992), (_S999), ((&dom_6)->hit));
        return;
    }
    uint _S1000 = (fcptFrame());
    uint _S1001 = hash(_S1000);
    uint _S1002 = global_invocation_id_8.x;
    uint2  _S1003 = (fcptRenderSize());
    uint _S1004 = stream(_S1001, _S1002 + _S1003.x * global_invocation_id_8.y);
    Selection _S1005 = (Selection{});
    Selection initial_0 = _S1005;
    uint _S1006 = stream(_S1004, 193U);
    (&initial_0)->random_state = _S1006;
    bool _S1007 = (fcptRestirUsed());
    bool _S1008 = !_S1007;
    (&initial_0)->sums = _S1008;
    uint _S1009 = stream(_S1004, 0U);
    (&(&initial_0)->r)->seed = _S1009;
    FKHit _S1010 = Hit_x24init_0(_S994, 4294967295U, 0U, 0U, 0.0f);
    uint _S1011 = (fcptSamples());
    float _S1012 = 1.0f / float(_S1011);
    FKHit hit_2 = _S1010;
    uint i_17 = 0U;
    float3  seen_0 = _S993;
    for(;;)
    {
        uint _S1013 = (fcptSamples());
        if(i_17 < _S1013)
        {
        }
        else
        {
            break;
        }
        Reservoir _S1014 = (Reservoir{});
        Reservoir r_6 = _S1014;
        uint _S1015 = stream(_S1004, i_17);
        (&r_6)->seed = _S1015;
        Domain path_0 = _S996;
        bool _S1016 = (fcptStoredDomainInitial((_S992), ((&r_6)->seed), (&path_0)));
        bool _S1017 = !_S1016;
        if(_S1017)
        {
            float3  _S1018 = (fcptMissed((_S992), (path_0), (_S1012)));
            float3  seen_1 = seen_0 + _S1018;
            seen_0 = seen_1;
            uint i_18 = i_17 + 1U;
            i_17 = i_18;
            continue;
        }
        Domain _S1019 = path_0;
        Reservoir _S1020 = r_6;
        Shift _S1021 = passWalk_0(&_S1019, &_S1020, false, _S1012, &initial_0);
        bool _S1022 = ((&(&initial_0)->r)->seed) == ((&r_6)->seed);
        FKHit hit_3;
        if(_S1022)
        {
            FKHit _S1023 = (&path_0)->hit;
            hit_3 = _S1023;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_18 = i_17 + 1U;
        i_17 = i_18;
    }
    uint _S1024 = (fcptSamples());
    float3  seen_2 = seen_0 + (&initial_0)->glow / make_float3 (float(_S1024));
    float3  _S1025 = seen_2 + (&initial_0)->color;
    bool _S1026 = (&initial_0)->sums;
    float3  _S1027 = _slang_select(_S1026, _S1025,seen_2);
    fcptAddColor((_S992), (make_float4 (_S1027.x, _S1027.y, _S1027.z, 1.0f)));
    Reservoir _S1028 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S992), (_S1028), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_3, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S1029;
    (&_S1029)->none = none_0;
    (&_S1029)->pdf = pdf_3;
    (&_S1029)->origin = origin_5;
    (&_S1029)->smooth_n = smooth_n_3;
    (&_S1029)->start = start_6;
    return _S1029;
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
    Vertex _S1030;
    (&_S1030)->rough = rough_0;
    (&_S1030)->lobe = lobe_1;
    (&_S1030)->pdf = pdf_4;
    (&_S1030)->cos = cos_0;
    (&_S1030)->inside = inside_0;
    return _S1030;
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
    float3  _S1031 = exp_0((make_float3 (sigma_0) - extinction_0) * make_float3 (distance_2));
    float3  _S1032 = scatter_0 * _S1031 / make_float3 (sigma_0);
    float3  _S1033 = _slang_select(scatters_0, _S1032,_S1031);
    return _S1033;
}

static __device__ uint arrivalLobe_0(uint b_3, uint prev_lobe_0)
{
    bool _S1034 = b_3 > 0U;
    uint _S1035 = _slang_select(_S1034, prev_lobe_0,3U);
    return _S1035;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_2, bool surface_5, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S1036;
    (&_S1036)->extinction_behind = extinction_behind_0;
    (&_S1036)->extinction_front = extinction_front_0;
    (&_S1036)->fillings = fillings_0;
    (&_S1036)->side = side_0;
    (&_S1036)->depth = depth_1;
    (&_S1036)->lobe = lobe_2;
    (&_S1036)->surface = surface_5;
    (&_S1036)->length = length_2;
    (&_S1036)->width = width_1;
    (&_S1036)->own = *own_2;
    (&_S1036)->fiber = fiber_0;
    return _S1036;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S1037 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S1037)
    {
        return 0.07957746833562851f;
    }
    float _S1038 = g_0 * g_0;
    return (1.0f - _S1038) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S1038 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_7, float3  b_4)
{
    float3  _S1039 = a_7 / b_4;
    float3  _S1040 = make_float3 (0.0f);
    bool3  _S1041 = b_4 == _S1040;
    float3  _S1042 = _slang_select(_S1041, _S1040,_S1039);
    return _S1042;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_6)
{
    uint _S1043 = (1U << count_6) - 1U;
    return (e_2 & (~(_S1043 << offset_1))) | ((newbits_0 & _S1043) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_7, uint end_type_0, uint end_0, float3  f_5)
{
    Reservoir candidate_2 = r_7;
    uint _S1044 = insertBits_0(r_7.path, end_0, 0U, 5U);
    uint _S1045 = insertBits_0(_S1044, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S1045;
    (&candidate_2)->f = f_5;
    return candidate_2;
}

__device__ float survivalProbability(float3  throughput_0, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_0.x), ((F32_max((throughput_0.y), (throughput_0.z)))))) / density_1), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_9)
{
    Random _S1046 = pcg(random_state_9);
    Random _S1047 = pcg(_S1046.state);
    float _S1048 = 1.0f - 2.0f * _S1046.value;
    float _S1049 = (F32_sqrt(((F32_max((1.0f - _S1048 * _S1048), (0.0f))))));
    float _S1050 = 6.28318548202514648f * _S1047.value;
    return make_float3 (_S1049 * (F32_cos((_S1050))), _S1049 * (F32_sin((_S1050))), _S1048);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_11, uint random_state_10, float * pdf_5)
{
    bool _S1051 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1051)
    {
        *pdf_5 = 0.07957746833562851f;
        float3  _S1052 = isotropic_0(random_state_10);
        return _S1052;
    }
    Random _S1053 = pcg(random_state_10);
    Random _S1054 = pcg(_S1053.state);
    float _S1055 = g_1 * g_1;
    float _S1056 = 2.0f * g_1;
    float _S1057 = (1.0f - _S1055) / (1.0f - g_1 + _S1056 * _S1053.value);
    float _S1058 = clamp_1((1.0f + _S1055 - _S1057 * _S1057) / _S1056, -1.0f, 1.0f);
    float _S1059 = (F32_sqrt(((F32_max((1.0f - _S1058 * _S1058), (0.0f))))));
    float _S1060 = 6.28318548202514648f * _S1054.value;
    float _S1061 = phaseHG_0(g_1, _S1058);
    *pdf_5 = _S1061;
    float3  _S1062 = tangentToWorld(make_float3 (_S1059 * (F32_cos((_S1060))), _S1058, _S1059 * (F32_sin((_S1060)))), dir_11);
    float3  _S1063 = ((((_S1062)) * make_float3(rnorm3df(((_S1062)).x, ((_S1062)).y, ((_S1062)).z))));
    return _S1063;
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_1, float3  emissive_1, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2, float velvet_0, float3  toon_2)
{
    BSDFMaterial _S1064;
    (&_S1064)->albedo = albedo_1;
    (&_S1064)->emissive = emissive_1;
    (&_S1064)->roughness = roughness_0;
    (&_S1064)->metallic = metallic_0;
    (&_S1064)->transmission = transmission_0;
    (&_S1064)->ior = ior_0;
    (&_S1064)->absorption = absorption_0;
    (&_S1064)->specular_tint = specular_tint_0;
    (&_S1064)->specular_level = specular_level_0;
    (&_S1064)->translucent = translucent_0;
    (&_S1064)->sheen = sheen_2;
    (&_S1064)->sheen_roughness = sheen_roughness_0;
    (&_S1064)->anisotropy = anisotropy_0;
    (&_S1064)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1064)->tangent = tangent_2;
    (&_S1064)->velvet = velvet_0;
    (&_S1064)->toon = toon_2;
    return _S1064;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1065;
    (&_S1065)->scatter = scatter_1;
    (&_S1065)->extinction = extinction_1;
    (&_S1065)->g = g_2;
    return _S1065;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_11, bool skip_0, uint random_state_11, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1066;
    (&_S1066)->smooth_n = smooth_n_4;
    (&_S1066)->geometry_n = geometry_n_2;
    (&_S1066)->geometry_offset = geometry_offset_2;
    (&_S1066)->material = *material_11;
    (&_S1066)->skip = skip_0;
    (&_S1066)->random_state = random_state_11;
    (&_S1066)->coverage = coverage_0;
    (&_S1066)->encloses = encloses_0;
    (&_S1066)->volume = *volume_0;
    (&_S1066)->fills = fills_0;
    (&_S1066)->hair = hair_0;
    return _S1066;
}

static __device__ FKSurface emitting_0(FKSurface * surface_6, bool top_0)
{
    FKSurface lower_0 = *surface_6;
    float3  _S1067 = (&surface_6->material)->emissive;
    float3  _S1068 = make_float3 (0.0f);
    bool _S1069 = !top_0;
    float3  _S1070 = _slang_select(_S1069, _S1068,_S1067);
    (&(&lower_0)->material)->emissive = _S1070;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_7, float u_1)
{
    float _S1071 = surface_7->coverage;
    bool _S1072 = u_1 < _S1071;
    if(_S1072)
    {
        return *surface_7;
    }
    float3  _S1073 = make_float3 (0.0f);
    float3  _S1074 = make_float3 (1.0f);
    BSDFMaterial _S1075 = Material_x24init_0(_S1073, _S1073, 0.0f, 0.0f, 0.0f, 0.0f, _S1073, _S1074, 1.0f, _S1073, _S1073, 0.5f, 0.0f, 0.0f, _S1073, 0.0f, _S1073);
    BSDFMaterial material_12 = _S1075;
    (&material_12)->albedo = _S1074;
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
    bool _S1076 = transmission_1 > 0.0f;
    bool _S1077;
    if(_S1076)
    {
        _S1077 = true;
    }
    else
    {
        _S1077 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1078 = _slang_select(_S1077, 1.0f,-1.0f);
    return _S1078;
}

static __device__ bool arrivesBehind_0(float3  dir_12, float3  n_10)
{
    return (dot_0(dir_12, n_10)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_8, float3  dir_13)
{
    float3  _S1079 = surface_8->geometry_n;
    float _S1080 = facingSign((&surface_8->material)->transmission, surface_8->geometry_n, dir_13);
    FKSurface faced_0 = *surface_8;
    float3  _S1081 = surface_8->smooth_n * make_float3 (_S1080);
    (&faced_0)->smooth_n = _S1081;
    float3  _S1082 = _S1079 * make_float3 (_S1080);
    (&faced_0)->geometry_n = _S1082;
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
    float3  _S1083 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1083));
}

__device__ float2  vertexEta(BSDFMaterial material_13, float n_dot_v_0)
{
    bool _S1084 = n_dot_v_0 < 0.0f;
    float _S1085 = _slang_select(_S1084, material_13.ior,1.0f);
    float _S1086 = _slang_select(_S1084, 1.0f,material_13.ior);
    return make_float2 (_S1085, _S1086);
}

__device__ bool neeDecision(BSDFMaterial material_14, float n_dot_v_1, float eta_i_9, float eta_o_9)
{
    float _S1087 = fresnel((F32_abs((n_dot_v_1))), eta_i_9, eta_o_9);
    float3  _S1088 = mix_0(make_float3 (_S1087), material_14.albedo, material_14.metallic);
    float _S1089 = rgb_to_greyscale(_S1088);
    float _S1090 = (F32_max(((1.0f - _S1089) * (1.0f - material_14.metallic) * (1.0f - material_14.transmission)), (0.0f)));
    bool _S1091 = _S1090 > 0.03999999910593033f;
    bool _S1092;
    if(_S1091)
    {
        _S1092 = true;
    }
    else
    {
        _S1092 = (material_14.roughness) > 0.20000000298023224f;
    }
    return _S1092;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_15)
{
    float _S1093 = rgb_to_greyscale(material_15->translucent);
    return _S1093 > 0.0f;
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
    MediumSides _S1094;
    (&_S1094)->behind = *behind_0;
    (&_S1094)->front = *front_0;
    (&_S1094)->fillings = fillings_1;
    (&_S1094)->face = face_1;
    return _S1094;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_9, FKMedium * medium_0, uint filling_0, float3  dir_14, FKMedium * outside_0)
{
    float3  _S1095 = surface_9->geometry_n;
    MediumSides _S1096 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_9->geometry_n);
    MediumSides sides_0 = _S1096;
    bool _S1097 = surface_9->encloses;
    if(_S1097)
    {
        (&sides_0)->behind = surface_9->volume;
        *&((&(&sides_0)->fillings)->x) = surface_9->fills;
        bool _S1098 = (dot_0(dir_14, _S1095)) > 0.0f;
        if(_S1098)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_10, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_15, uint depth_2, uint lobe_3, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1099 = surface_10->geometry_n;
    ShadowContext _S1100 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_10->geometry_n, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
    bool _S1101 = surface_10->encloses;
    ShadowContext context_4;
    if(_S1101)
    {
        FKSurface faced_1 = *surface_10;
        float3  _S1102 = - _S1099;
        float3  _S1103 = _slang_select(turned_0, _S1102,_S1099);
        (&faced_1)->geometry_n = _S1103;
        FKMedium _S1104 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1105 = faced_1;
        FKMedium _S1106 = _S1104;
        MediumSides _S1107 = mediumSides_0(&_S1105, &_S1106, filling_1, dir_15, outside_1);
        ShadowContext _S1108 = ShadowContext_x24init_0(_S1107.behind.extinction, _S1107.front.extinction, _S1107.fillings, _S1099, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
        if(turned_0)
        {
            uint2  _S1109 = _S1107.fillings;
            ShadowContext _S1110 = ShadowContext_x24init_0(_S1107.front.extinction, _S1107.behind.extinction, uint2 {_S1109.y, _S1109.x}, _S1099, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
            context_4 = _S1110;
        }
        else
        {
            context_4 = _S1108;
        }
    }
    else
    {
        context_4 = _S1100;
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
    float3  _S1111 = light_2->dir;
    bool _S1112 = (dot_0(geometry_n_3, - in_dir_8) * dot_0(geometry_n_3, light_2->dir)) <= 0.0f;
    FixedArray<float3 , 5>  throughputs_1;
    FixedArray<float, 5>  pdfs_3;
    float3  _S1113 = BSDF(in_dir_8, _S1111, smooth_n_5, *material_16, eta_i_10, eta_o_10, _S1112, random_state_12, &throughputs_1, &pdfs_3);
    bool _S1114 = !competing_1;
    bool _S1115;
    if(_S1114)
    {
        _S1115 = true;
    }
    else
    {
        _S1115 = (light_2->density) == 0.0f;
    }
    if(_S1115)
    {
        return _S1113 * light_2->radiance;
    }
    float3  _S1116 = make_float3 (0.0f);
    uint i_23 = 0U;
    float3  weighted_0 = _S1116;
    for(;;)
    {
        if(i_23 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S1117 = (pdfs_3[i_23]) > 0.0f;
        if(_S1117)
        {
            float _S1118 = light_2->density;
            float _S1119 = pdfs_3[i_23] / light_2->density;
            float3  weighted_1 = weighted_0 + throughputs_1[i_23] * make_float3 (pdfs_3[i_23]) / make_float3 (_S1118 * (1.0f + _S1119 * _S1119));
            weighted_0 = weighted_1;
        }
        uint i_24 = i_23 + 1U;
        i_23 = i_24;
    }
    return weighted_0 * light_2->radiance * make_float3 (light_2->density);
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_1, uint random_state_13, bool refracted_3, uint lobe_4, float pdf_6)
{
    SampleBSDF _S1120;
    (&_S1120)->unit_direction = unit_direction_1;
    (&_S1120)->throughput = throughput_1;
    (&_S1120)->random_state = random_state_13;
    (&_S1120)->refracted = refracted_3;
    (&_S1120)->lobe = lobe_4;
    (&_S1120)->pdf = pdf_6;
    return _S1120;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  n_i_9, float n_i_dot_v_6, float alpha_15, BSDFMaterial material_17, BSDFLobes lobes_11, float eta_i_11, float eta_o_11, uint random_state_14)
{
    float3  _S1121 = make_float3 (1.0f);
    SampleBSDF _S1122 = SampleBSDF_x24init_0(_S1121, _S1121, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S1122;
    Random _S1123 = pcg(random_state_14);
    Random _S1124 = pcg(_S1123.state);
    (&sample_1)->random_state = _S1124.state;
    float _S1125 = _S1123.value;
    float _S1126 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1125 * _S1125))))));
    float _S1127 = 6.28318548202514648f * _S1124.value;
    float3  _S1128 = tangentToWorld(make_float3 (_S1126 * (F32_cos((_S1127))), _S1123.value, _S1126 * (F32_sin((_S1127)))), n_i_9);
    (&sample_1)->unit_direction = _S1128;
    (&sample_1)->lobe = 4U;
    float3  _S1129 = sheenVelvetBSDF((&sample_1)->unit_direction, n_i_9, alpha_15, material_17, lobes_11);
    (&sample_1)->throughput = _S1129;
    float _S1130 = sheenVelvetPDF(_S1123.value, 0.0f, n_i_dot_v_6, alpha_15, lobes_11, eta_i_11, eta_o_11);
    (&sample_1)->pdf = _S1130;
    return sample_1;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1131 = (F32_sqrt((random_1_0)));
    float _S1132 = 6.28318548202514648f * random_2_0;
    float _S1133 = _S1131 * (F32_cos((_S1132)));
    float _S1134 = _S1131 * (F32_sin((_S1132)));
    float _S1135 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1133 * _S1133 - _S1134 * _S1134))))));
    return make_float3 (_S1133, _S1135, _S1134);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_2, float3  n_i_10, float n_i_dot_v_7, float alpha_16, BSDFMaterial material_18, BSDFLobes lobes_12, float eta_i_12, float eta_o_12, uint random_state_15)
{
    float3  _S1136 = make_float3 (1.0f);
    SampleBSDF _S1137 = SampleBSDF_x24init_0(_S1136, _S1136, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S1137;
    Random _S1138 = pcg(random_state_15);
    Random _S1139 = pcg(_S1138.state);
    (&sample_2)->random_state = _S1139.state;
    float3  _S1140 = sampleCosWeightedHemisphere(_S1138.value, _S1139.value);
    bool _S1141 = u_2 < (lobes_12.p_diffuse * lobes_12.translucent_share);
    float _S1142 = _S1140.y;
    float _S1143 = - _S1142;
    float _S1144 = _slang_select(_S1141, _S1143,_S1142);
    float3  _S1145 = tangentToWorld(make_float3 (_S1140.x, _S1144, _S1140.z), n_i_10);
    (&sample_2)->unit_direction = _S1145;
    (&sample_2)->refracted = _S1141;
    (&sample_2)->lobe = 0U;
    float3  _S1146 = diffuseBSDF((&sample_2)->unit_direction, n_i_10, alpha_16, material_18, lobes_12);
    (&sample_2)->throughput = _S1146;
    float _S1147 = diffusePDF(_S1144, 0.0f, n_i_dot_v_7, alpha_16, lobes_12, eta_i_12, eta_o_12);
    (&sample_2)->pdf = _S1147;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF toonSample(float3  n_i_11, float n_i_dot_v_8, float alpha_17, BSDFMaterial material_19, BSDFLobes lobes_13, float eta_i_13, float eta_o_13, uint random_state_16)
{
    float3  _S1148 = make_float3 (1.0f);
    SampleBSDF _S1149 = SampleBSDF_x24init_0(_S1148, _S1148, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S1149;
    Random _S1150 = pcg(random_state_16);
    Random _S1151 = pcg(_S1150.state);
    (&sample_3)->random_state = _S1151.state;
    float _S1152 = _S1150.value * lobes_13.toon_norm / 6.28318548202514648f;
    float t_21;
    if(lobes_13.toon_glossy)
    {
        t_21 = (F32_acos((clamp_1(1.0f - _S1152, -1.0f, 1.0f))));
    }
    else
    {
        t_21 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1152)))), (1.0f))))));
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
        float _S1153;
        if(t_21 < (lobes_13.toon_a))
        {
            _S1153 = 1.0f;
        }
        else
        {
            _S1153 = (F32_max((1.0f - (t_21 - lobes_13.toon_a) / (F32_max((lobes_13.toon_s), (0.0000152587890625f)))), (0.0f)));
        }
        float integral_1;
        if(lobes_13.toon_glossy)
        {
            integral_1 = 1.0f - (F32_cos(((F32_min((t_21), (lobes_13.toon_a))))));
        }
        else
        {
            float _S1154 = (F32_sin(((F32_min((t_21), (lobes_13.toon_a))))));
            integral_1 = _S1154 * _S1154 / 2.0f;
        }
        bool _S1155 = t_21 > (lobes_13.toon_a);
        bool _S1156;
        if(_S1155)
        {
            _S1156 = (lobes_13.toon_s) > 0.0f;
        }
        else
        {
            _S1156 = false;
        }
        float integral_2;
        if(_S1156)
        {
            if(lobes_13.toon_glossy)
            {
                float _S1157 = (F32_cos((lobes_13.toon_a)));
                float _S1158 = (F32_cos((t_21)));
                integral_2 = (1.0f + lobes_13.toon_a / lobes_13.toon_s) * (_S1157 - _S1158) - ((F32_sin((t_21))) - t_21 * _S1158 - ((F32_sin((lobes_13.toon_a))) - lobes_13.toon_a * _S1157)) / lobes_13.toon_s;
            }
            else
            {
                float _S1159 = 2.0f * lobes_13.toon_a;
                float _S1160 = (F32_cos((_S1159)));
                float _S1161 = 2.0f * t_21;
                float _S1162 = (F32_cos((_S1161)));
                integral_2 = (1.0f + lobes_13.toon_a / lobes_13.toon_s) * (_S1160 - _S1162) / 4.0f - ((F32_sin((_S1161))) / 8.0f - t_21 * _S1162 / 4.0f - ((F32_sin((_S1159))) / 8.0f - lobes_13.toon_a * _S1160 / 4.0f)) / lobes_13.toon_s;
            }
            float integral_3 = integral_1 + integral_2;
            integral_2 = integral_3;
        }
        else
        {
            integral_2 = integral_1;
        }
        float _S1163 = _S1153 * (F32_sin((t_21)));
        float _S1164;
        if(lobes_13.toon_glossy)
        {
            _S1164 = 1.0f;
        }
        else
        {
            _S1164 = (F32_cos((t_21)));
        }
        float _S1165 = _S1163 * _S1164;
        float _S1166 = (integral_2 - _S1152) / _S1165;
        bool _S1167 = _S1165 > 0.0f;
        float _S1168 = _slang_select(_S1167, _S1166,0.0f);
        float _S1169 = clamp_1(t_21 - _S1168, 0.0f, lobes_13.toon_b);
        int k_1 = k_0 + int(1);
        t_21 = _S1169;
        k_0 = k_1;
    }
    float _S1170 = 6.28318548202514648f * _S1151.value;
    float _S1171 = (F32_sin((t_21)));
    float3  _S1172 = tangentToWorld(make_float3 (_S1171 * (F32_cos((_S1170))), (F32_cos((t_21))), _S1171 * (F32_sin((_S1170)))), lobes_13.toon_axis);
    (&sample_3)->unit_direction = _S1172;
    bool _S1173 = (dot_0(n_i_11, (&sample_3)->unit_direction)) < 0.0f;
    (&sample_3)->refracted = _S1173;
    (&sample_3)->lobe = 6U;
    float3  _S1174 = toonBSDF((&sample_3)->unit_direction, n_i_11, alpha_17, material_19, lobes_13);
    (&sample_3)->throughput = _S1174;
    float _S1175 = toonPDF(dot_0(n_i_11, (&sample_3)->unit_direction), dot_0((&sample_3)->unit_direction, lobes_13.toon_axis), n_i_dot_v_8, alpha_17, lobes_13, eta_i_13, eta_o_13);
    (&sample_3)->pdf = _S1175;
    return sample_3;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_12, float n_i_dot_v_9, float alpha_18, BSDFMaterial material_20, BSDFLobes lobes_14, float eta_i_14, float eta_o_14, uint random_state_17)
{
    float3  _S1176 = make_float3 (1.0f);
    SampleBSDF _S1177 = SampleBSDF_x24init_0(_S1176, _S1176, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S1177;
    (&sample_4)->unit_direction = lobes_14.refracted;
    (&sample_4)->random_state = random_state_17;
    (&sample_4)->refracted = true;
    (&sample_4)->lobe = 1U;
    float3  _S1178 = refractBSDF((&sample_4)->unit_direction, n_i_12, alpha_18, material_20, lobes_14);
    (&sample_4)->throughput = _S1178;
    float _S1179 = refractPDF(0.0f, dot_0((&sample_4)->unit_direction, ggx_n_3), n_i_dot_v_9, alpha_18, lobes_14, eta_i_14, eta_o_14);
    (&sample_4)->pdf = _S1179;
    return sample_4;
}

static __device__ float3  reflect_0(float3  i_25, float3  n_11)
{
    return i_25 - make_float3 (2.0f * dot_0(n_11, i_25)) * n_11;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_9, float3  ggx_n_4, float3  n_i_13, float n_i_dot_v_10, float alpha_19, BSDFMaterial material_21, BSDFLobes lobes_15, float eta_i_15, float eta_o_15, uint random_state_18)
{
    float3  _S1180 = make_float3 (1.0f);
    SampleBSDF _S1181 = SampleBSDF_x24init_0(_S1180, _S1180, 0U, false, 0U, 0.0f);
    SampleBSDF sample_5 = _S1181;
    float3  _S1182 = reflect_0(in_dir_9, ggx_n_4);
    float3  _S1183 = ((((_S1182)) * make_float3(rnorm3df(((_S1182)).x, ((_S1182)).y, ((_S1182)).z))));
    (&sample_5)->unit_direction = _S1183;
    (&sample_5)->random_state = random_state_18;
    (&sample_5)->lobe = 2U;
    float3  _S1184 = reflectBSDF((&sample_5)->unit_direction, n_i_13, alpha_19, material_21, lobes_15);
    (&sample_5)->throughput = _S1184;
    float _S1185 = reflectPDF(0.0f, 0.0f, n_i_dot_v_10, alpha_19, lobes_15, eta_i_15, eta_o_15);
    (&sample_5)->pdf = _S1185;
    return sample_5;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_10, float3  n_12, BSDFMaterial material_22, float eta_i_16, float eta_o_16, uint random_init_0, float2  screen_space_0)
{
    uint random_state_19 = random_init_0;
    float3  _S1186 = negate_0(in_dir_10);
    float _S1187 = dot_0(n_12, _S1186);
    float _S1188 = sign_0(_S1187);
    float3  n_i_14 = n_12 * make_float3 (_S1188);
    float _S1189 = (F32_abs((_S1187)));
    float _S1190 = material_22.roughness;
    float _S1191 = _S1190 * _S1190;
    AnisotropicFrame _S1192 = anisotropicFrame(material_22, n_i_14);
    SheenProfile _S1193 = sheenProfile(_S1186, n_i_14, material_22);
    float3  _S1194 = sampleHalfVector(_S1186, n_i_14, _S1191, _S1192, &random_state_19);
    BSDFLobes _S1195 = bsdfLobes(in_dir_10, _S1186, n_i_14, _S1194, material_22, eta_i_16, eta_o_16, _S1192, _S1193);
    BSDFLobes lobes_16 = _S1195;
    float _S1196 = translucentShare(material_22);
    (&lobes_16)->translucent_share = _S1196;
    Random _S1197 = pcg(random_state_19);
    random_state_19 = _S1197.state;
    bool _S1198 = (_S1197.value) < ((&lobes_16)->p_sheen_velvet);
    if(_S1198)
    {
        SampleBSDF _S1199 = sheenVelvetSample(n_i_14, _S1189, _S1191, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1199;
    }
    float _S1200 = _S1197.value - (&lobes_16)->p_sheen_velvet;
    bool _S1201 = _S1200 < ((&lobes_16)->p_diffuse);
    if(_S1201)
    {
        SampleBSDF _S1202 = diffuseSample(_S1200, n_i_14, _S1189, _S1191, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1202;
    }
    bool _S1203 = _S1200 < ((&lobes_16)->p_diffuse + (&lobes_16)->p_toon);
    if(_S1203)
    {
        SampleBSDF _S1204 = toonSample(n_i_14, _S1189, _S1191, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1204;
    }
    float _S1205 = (&lobes_16)->p_toon;
    bool _S1206 = (_S1200 - _S1205) < ((&lobes_16)->p_diffuse + (&lobes_16)->p_refract);
    if(_S1206)
    {
        SampleBSDF _S1207 = refractSample(_S1194, n_i_14, _S1189, _S1191, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1207;
    }
    SampleBSDF _S1208 = reflectSample(in_dir_10, _S1194, n_i_14, _S1189, _S1191, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
    return _S1208;
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
    bool _S1209;
    bool _S1210;
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
    int _S1211;
    Shift ended_0;
    float density_3;
    float spread_2;
    float width_4;
    float sky_pdf_1;
    float spread_3;
    float width_5;
    uint b_6;
    float3  _S1212 = make_float3 (0.0f);
    Shift _S1213 = Shift_x24init_0(_S1212, 0.0f);
    uint _S1214 = r_8->path;
    uint _S1215 = extractBits_0(r_8->path, 0U, 5U);
    uint _S1216 = extractBits_0(_S1214, 5U, 5U);
    uint _S1217 = extractBits_0(_S1214, 10U, 2U);
    uint _S1218 = extractBits_0(_S1214, 12U, 3U);
    bool passes_0;
    if(replay_1)
    {
        bool _S1219 = _S1218 >= 3U;
        uint _S1220 = _slang_select(_S1219, 1U,0U);
        uint _S1221 = _S1215 + _S1220;
        uint _S1222 = (fcptMaxBounces());
        passes_0 = _S1221 > _S1222;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1213;
    }
    uint _S1223 = _S1216 - 1U;
    bool _S1224 = _S1218 == 3U;
    uint _S1225 = _slang_select(_S1224, 1U,0U);
    uint _S1226 = _S1215 + _S1225;
    bool _S1227 = _S1217 == 0U;
    uint _S1228 = _slang_select(_S1227, _S1226,_S1223);
    FKHit _S1229 = (fcptReservoirHit((*r_8)));
    float3  _S1230 = dom_7->x0;
    float3  _S1231 = dom_7->x1 - dom_7->x0;
    float3  _S1232 = ((((_S1231)) * make_float3(rnorm3df(((_S1231)).x, ((_S1231)).y, ((_S1231)).z))));
    FKRay _S1233 = Ray_x24init_0(dom_7->x1, _S1232);
    FKRay ray_2 = _S1233;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1212;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_1 = throughput_3;
    float3  glowed_0 = _S1212;
    float3  extinction_in_0 = _S1212;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1234 = dom_7->spread;
    float _S1235 = dom_7->width;
    float _S1236 = length_0(_S1231);
    NEEVertex _S1237 = NEEVertex_x24init_0(true, 0.0f, _S1212, _S1212, _S1212);
    NEEVertex nee_vertex_0 = _S1237;
    Vertex _S1238 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S1238;
    Reservoir _S1239 = (Reservoir{});
    Reservoir chain_0 = _S1239;
    uint _S1240 = r_8->seed;
    (&chain_0)->seed = r_8->seed;
    (&ray_2)->origin = _S1230;
    (&hit_4)->distance = _S1236;
    FKMedium _S1241 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1242 = filling_2;
    bool _S1243 = (fcptVaryingUsed());
    uint _S1244 = _slang_select(_S1243, _S1242,4294967295U);
    filling_2 = _S1244;
    scatter_in_0 = _S1241.scatter;
    extinction_in_0 = _S1241.extinction;
    g_in_0 = _S1241.g;
    Reservoir _S1245 = chain_0;
    uint _S1246 = filling_2;
    for(;;)
    {
        bool _S1247 = (fcptVaryingUsed());
        if(_S1247)
        {
            passes_0 = _S1246 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1248 = (fcptMajorant((_S1246)));
            spread_1 = _S1248;
        }
        else
        {
            spread_1 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_1)
        {
            turned_1 = 4294967295U == _S1228;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1217 == 1U;
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
            ended_0 = _S1213;
            sky_pdf_0 = 0.0f;
            spread_1 = _S1234;
            width_3 = _S1235;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_5 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1249 = (&prev_0)->rough;
        if(_S1249)
        {
            turned_1 = !(spread_1 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S1250 = stream(_S1240, 384U);
        uint tracking_0 = _S1250;
        weight_1 = throughput_3;
        glowed_0 = _S1212;
        b_5 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        threshold_0 = _S1234;
        width_3 = _S1235;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1211 = int(1);
                break;
            }
            uint _S1251 = b_5 + 320U;
            bool _S1252 = b_5 == 4294967295U;
            uint _S1253 = _slang_select(_S1252, 384U,_S1251);
            uint _S1254 = stream(_S1240, _S1253);
            Random _S1255 = pcg(_S1254);
            float _S1256 = - (F32_log((1.0f - _S1255.value))) / spread_1;
            if(passes_0)
            {
                float3  _S1257 = (&ray_2)->origin;
                float3  _S1258 = (&ray_2)->unit_direction;
                float _S1259 = (&hit_4)->distance;
                uint _S1260 = _slang_select(_S1252, 0U,b_5);
                uint _S1261 = (&prev_0)->lobe;
                uint _S1262 = _slang_select(_S1252, 3U,_S1261);
                float _S1263 = (fcptTrackMedium((_S1246), (_S1257), (_S1258), (_S1259), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1260), (_S1262), (_S1252)));
                geometry_density_0 = _S1263;
            }
            else
            {
                geometry_density_0 = _S1256;
            }
            bool _S1264 = !(geometry_density_0 < ((&hit_4)->distance));
            if(_S1264)
            {
                _S1211 = int(1);
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
                float3  _S1265 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S1266 = sel_7->glow + _S1265;
                sel_7->glow = _S1266;
            }
            else
            {
            }
            glowed_0 = _S1212;
            uint b_7 = b_5 + 1U;
            float3  _S1267 = (&ray_2)->origin + make_float3 (geometry_density_0) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1267;
            float3  _S1268 = flightWeight_0(scatter_in_0, extinction_in_0, spread_1, geometry_density_0, true);
            float3  _S1269 = weight_1;
            float3  _S1270 = _slang_select(passes_0, _S1269,_S1268);
            float3  throughput_4 = throughput_2 * _S1270;
            uint _S1271 = stream(_S1240, b_7 + 320U);
            tracking_0 = _S1271;
            weight_1 = throughput_3;
            float width_6 = width_3 + threshold_0 * geometry_density_0;
            float _S1272 = threshold_0 + 3.14159274101257324f;
            bool _S1273 = !replay_1;
            if(_S1273)
            {
                is_inside_5 = true;
            }
            else
            {
                bool _S1274 = b_7 == _S1228;
                if(_S1274)
                {
                    is_inside_5 = !passes_0;
                }
                else
                {
                    is_inside_5 = false;
                }
            }
            TreeSample _S1275 = TreeSample_x24init_0(_S1212, _S1212, 0.0f, 0U);
            if(is_inside_5)
            {
                float3  _S1276 = (&ray_2)->origin;
                float3  _S1277 = (&ray_2)->unit_direction;
                float3  _S1278 = (&ray_2)->unit_direction;
                uint _S1279 = stream(_S1240, b_7 + 64U);
                float3  _S1280 = extinction_in_0;
                float3  _S1281 = extinction_in_0;
                uint2  _S1282 = make_uint2 (_S1246);
                float3  _S1283 = (&ray_2)->unit_direction;
                uint _S1284 = arrivalLobe_0(b_7, (&prev_0)->lobe);
                FKHit _S1285 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1286 = _S1285;
                ShadowContext _S1287 = ShadowContext_x24init_0(_S1280, _S1281, _S1282, _S1283, b_7, _S1284, false, geometry_density_0, width_6, &_S1286, false);
                ShadowContext _S1288 = _S1287;
                TreeSample _S1289 = sampleLightTree_0(_S1276, _S1277, _S1278, 0.0f, true, _S1279, &_S1288);
                light_3 = _S1289;
            }
            else
            {
                light_3 = _S1275;
            }
            float _S1290 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S1291 = (fcptMaxBounces());
            bool _S1292 = b_7 < _S1291;
            if(_S1292)
            {
                viewed_0 = (light_3.density) > 0.0f;
            }
            else
            {
                viewed_0 = false;
            }
            float _S1293 = _slang_select(viewed_0, _S1290,0.0f);
            float3  _S1294 = throughput_4 * light_3.radiance;
            float _S1295 = powerHeuristic(light_3.density, _S1293);
            float3  _S1296 = _S1294 * make_float3 (_S1290 * _S1295);
            float3  _S1297 = _slang_select(is_inside_5, _S1296,_S1212);
            if(replay_1)
            {
                _S1209 = b_7 == _S1228;
            }
            else
            {
                _S1209 = false;
            }
            if(_S1209)
            {
                bool _S1298 = _S1217 == 2U;
                if(_S1298)
                {
                    float _S1299 = rgb_to_greyscale(_S1297);
                    passes_0 = _S1299 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1300 = Shift_x24init_0(_S1297, 1.0f);
                    _S1211 = int(0);
                    ended_0 = _S1300;
                    spread_1 = _S1272;
                    geometry_density_0 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_7;
                    break;
                }
                _S1211 = int(0);
                ended_0 = _S1213;
                spread_1 = _S1272;
                geometry_density_0 = width_6;
                chain_throughput_0 = throughput_4;
                layer_0 = b_7;
                break;
            }
            if(_S1273)
            {
                Reservoir candidate_3 = _S1245;
                uint _S1301 = extractBits_0(_S1245.path, 10U, 2U);
                bool _S1302 = _S1301 == 1U;
                if(_S1302)
                {
                    float3  _S1303 = safeDivide(_S1297, _S1212);
                    (&candidate_3)->radiance = _S1303;
                }
                else
                {
                    uint _S1304 = insertBits_0(0U, b_7 + 1U, 5U, 5U);
                    uint _S1305 = insertBits_0(_S1304, 2U, 10U, 2U);
                    (&candidate_3)->path = _S1305;
                }
                Reservoir _S1306 = withEnd(candidate_3, 0U, b_7, _S1297);
                offer(sel_7, _S1306, _S1297 * make_float3 (scale_3) / make_float3 (density_2));
                float _S1307 = survivalProbability(throughput_4, density_2);
                uint _S1308 = stream(_S1240, b_7 + 128U);
                Random _S1309 = pcg(_S1308);
                bool _S1310 = _S1307 < (_S1309.value);
                if(_S1310)
                {
                    _S1210 = true;
                }
                else
                {
                    uint _S1311 = (fcptMaxBounces());
                    _S1210 = b_7 >= _S1311;
                }
                if(_S1210)
                {
                    _S1211 = int(0);
                    ended_0 = _S1213;
                    spread_1 = _S1272;
                    geometry_density_0 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_7;
                    break;
                }
                float _S1312 = density_2 * _S1307;
                density_2 = _S1312;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1313 = stream(_S1240, b_7);
            float3  _S1314 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1313, &phase_pdf_0);
            (&ray_2)->unit_direction = _S1314;
            NEEVertex _S1315 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S1212, (&ray_2)->origin);
            nee_vertex_0 = _S1315;
            Vertex _S1316 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, false);
            prev_0 = _S1316;
            float _S1317 = (&prev_0)->pdf;
            FKRay _S1318 = ray_2;
            FKHit _S1319 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1320 = (fcptTraverseInstanceBVH((_S1318), (true), (4.294967296e+09f), (false), (_S1319), (false)));
            hit_4 = _S1320;
            b_5 = b_7;
            throughput_2 = throughput_4;
            threshold_0 = _S1272;
            width_3 = width_6;
            sky_pdf_0 = _S1317;
        }
        if(_S1211 != int(1))
        {
            width_3 = geometry_density_0;
            throughput_2 = chain_throughput_0;
            b_5 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1213;
        spread_1 = threshold_0;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1321 = b_5 == 4294967295U;
    bool _S1322 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1322)
    {
        bool _S1323 = !(&nee_vertex_0)->none;
        float _S1324 = _slang_select(_S1323, sky_pdf_0,0.0f);
        float _S1325 = escapeWeight_0(_S1324, (&ray_2)->unit_direction);
        float3  _S1326 = environment_0((&ray_2)->unit_direction, b_5, (&prev_0)->lobe);
        float3  _S1327 = throughput_2 * _S1326;
        if(replay_1)
        {
            bool _S1328 = b_5 == _S1228;
            if(_S1328)
            {
                passes_0 = _S1217 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S1327 * make_float3 (_S1325) / make_float3 (r_8->jac), density_2 / r_8->jac);
            }
            if(_S1227)
            {
                passes_0 = _S1224;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_5 == _S1215;
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
                return Shift_x24init_0(_S1327 * make_float3 (_S1325), 1.0f);
            }
            return _S1213;
        }
        Reservoir candidate_4 = chain_0;
        uint _S1329 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1330 = _S1329 == 1U;
        if(_S1330)
        {
            uint _S1331 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S1332 = _S1331 == b_5;
            float _S1333 = _slang_select(_S1332, 1.0f,_S1325);
            float3  _S1334 = safeDivide(_S1327 * make_float3 (_S1333), _S1212);
            (&candidate_4)->radiance = _S1334;
        }
        else
        {
            bool _S1335 = (&prev_0)->rough;
            if(_S1335)
            {
                uint _S1336 = insertBits_0(0U, b_5 + 1U, 5U, 5U);
                uint _S1337 = insertBits_0(_S1336, 3U, 10U, 2U);
                uint _S1338 = insertBits_0(_S1337, (&prev_0)->lobe, 15U, 3U);
                bool _S1339 = (&prev_0)->inside;
                uint _S1340 = _slang_select(_S1339, 1U,0U);
                uint _S1341 = insertBits_0(_S1338, _S1340, 22U, 1U);
                (&candidate_4)->path = _S1341;
                (&candidate_4)->jac = (&prev_0)->pdf;
                (&candidate_4)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S1342 = _S1327 * make_float3 (_S1325);
        Reservoir _S1343 = withEnd(candidate_4, 3U, b_5, _S1342);
        offer(sel_7, _S1343, _S1342 * make_float3 (scale_3) / make_float3 (density_2));
        return _S1213;
    }
    float3  _S1344 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S1344;
    bool _S1345 = (fcptVaryingUsed());
    if(_S1345)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1346 = !replay_1;
        if(_S1346)
        {
            float3  _S1347 = throughput_2 * glowed_0 / make_float3 (density_2);
            float3  _S1348 = sel_7->glow + _S1347;
            sel_7->glow = _S1348;
        }
        float3  _S1349 = throughput_2 * weight_1;
        throughput_2 = _S1349;
    }
    else
    {
        float3  _S1350 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
        float3  _S1351 = throughput_2 * _S1350;
        throughput_2 = _S1351;
    }
    float _S1352 = width_3 + spread_1 * (&hit_4)->distance;
    uint _S1353 = b_5 + 1U;
    b_5 = _S1353;
    layer_0 = 0U;
    width_3 = _S1352;
    passes_0 = false;
    threshold_0 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    chain_throughput_0 = _S1212;
    float3  reconnection_0 = _S1212;
    viewed_0 = _S1321;
    for(;;)
    {
        bool _S1354 = ((&hit_4)->is_point_light) == 1U;
        if(replay_1)
        {
            _S1209 = _S1217 == 1U;
        }
        else
        {
            _S1209 = false;
        }
        if(_S1209)
        {
            _S1210 = b_5 == _S1216;
        }
        else
        {
            _S1210 = false;
        }
        bool _S1355;
        if(_S1210)
        {
            bool _S1356 = ((&hit_4)->instance_index) != (_S1229.instance_index);
            if(_S1356)
            {
                _S1355 = true;
            }
            else
            {
                _S1355 = ((&hit_4)->triangle_index) != (_S1229.triangle_index);
            }
        }
        else
        {
            _S1355 = false;
        }
        if(_S1355)
        {
            return _S1213;
        }
        FKMedium _S1357 = Medium_x24init_0(_S1212, _S1212, 0.0f);
        BSDFMaterial _S1358 = Material_x24init_0(_S1212, _S1212, 0.0f, 0.0f, 0.0f, 0.0f, _S1212, throughput_3, 1.0f, _S1212, _S1212, 0.5f, 0.0f, 0.0f, _S1212, 0.0f, _S1212);
        FKMedium _S1359 = _S1357;
        FKSurface _S1360 = Surface_x24init_0(_S1212, _S1212, 0.0f, &_S1358, false, 0U, 1.0f, false, &_S1359, 4294967295U, _S1212);
        bool _S1361 = !_S1354;
        bool scatter_2;
        bool is_inside_6;
        float3  front_n_0;
        float3  throughput_5;
        FKSurface surface_12;
        if(_S1361)
        {
            uint _S1362 = stream(_S1240, b_5);
            uint _S1363 = arrivalLobe_0(b_5, (&prev_0)->lobe);
            FKSurface _S1364 = (fcptSurfaceAtPath((hit_4), ((&ray_2)->origin), (_S1362), (width_3), (layer_0), (b_5), (_S1363), ((&ray_2)->unit_direction)));
            bool _S1365 = !passes_0;
            FKSurface _S1366 = _S1364;
            FKSurface _S1367 = emitting_0(&_S1366, _S1365);
            uint _S1368 = stream(_S1240, b_5 + 256U);
            Random _S1369 = pcg(_S1368);
            FKSurface _S1370 = _S1367;
            FKSurface _S1371 = uncovered_0(&_S1370, _S1369.value);
            float _S1372 = facingSign(_S1371.material.transmission, _S1371.geometry_n, (&ray_2)->unit_direction);
            bool _S1373 = _S1372 < 0.0f;
            bool _S1374 = (_S1371.material.transmission) > 0.0f;
            if(_S1374)
            {
                bool _S1375 = arrivesBehind_0((&ray_2)->unit_direction, _S1371.geometry_n);
                scatter_2 = _S1375;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1376 = _S1371;
            FKSurface _S1377 = facingRay_0(&_S1376, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S1378 = arrivesBehind_0((&ray_2)->unit_direction, _S1377.geometry_n);
                is_inside_6 = _S1378;
            }
            else
            {
                is_inside_6 = scatter_2;
            }
            if(is_inside_6)
            {
                float3  _S1379 = beerLambert((&hit_4)->distance, _S1377.material.absorption);
                float3  _S1380 = throughput_2 * _S1379;
                front_n_0 = _S1380;
            }
            else
            {
                front_n_0 = throughput_2;
            }
            bool _S1381 = !_S1377.skip;
            float geometry_density_1 = (F32_abs((dot_0(_S1377.geometry_n, (&ray_2)->unit_direction)))) / ((&hit_4)->distance * (&hit_4)->distance);
            bool _S1382 = b_5 == _S1353;
            if(_S1382)
            {
                float _S1383 = 0.00251327408477664f / geometry_density_1;
                geometry_density_0 = _S1383;
            }
            else
            {
                geometry_density_0 = threshold_0;
            }
            float3  _S1384 = front_n_0;
            float _S1385 = geometry_density_0;
            scatter_2 = _S1381;
            geometry_density_0 = geometry_density_1;
            threshold_0 = _S1385;
            surface_12 = _S1377;
            front_n_0 = _S1371.smooth_n;
            throughput_5 = _S1384;
            turned_1 = _S1373;
        }
        else
        {
            scatter_2 = false;
            geometry_density_0 = 0.0f;
            surface_12 = _S1360;
            front_n_0 = _S1212;
            throughput_5 = throughput_2;
            is_inside_6 = is_inside_5;
        }
        bool _S1386;
        if(scatter_2)
        {
            _S1386 = (&prev_0)->rough;
        }
        else
        {
            _S1386 = false;
        }
        bool _S1387;
        if(_S1386)
        {
            _S1387 = ((&prev_0)->pdf * geometry_density_0 * threshold_0) <= 1.0f;
        }
        else
        {
            _S1387 = false;
        }
        FKSurface _S1388 = surface_12;
        FKSurface _S1389 = surface_12;
        float _S1390 = dot_0(surface_12.smooth_n, - (&ray_2)->unit_direction);
        float2  _S1391 = vertexEta(_S1388.material, _S1390);
        bool _S1392;
        if(scatter_2)
        {
            uint _S1393 = (fcptMaxBounces());
            bool _S1394 = b_5 >= _S1393;
            if(_S1394)
            {
                _S1392 = true;
            }
            else
            {
                bool _S1395 = neeDecision(_S1388.material, _S1390, _S1391.x, _S1391.y);
                _S1392 = _S1395;
            }
        }
        else
        {
            _S1392 = false;
        }
        bool _S1396;
        if(passes_0)
        {
            _S1396 = true;
        }
        else
        {
            _S1396 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1396)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1392;
        }
        bool _S1397 = (fcptHairUsed());
        bool _S1398;
        if(_S1397)
        {
            float3  _S1399 = surface_12.hair;
            _S1398 = (dot_0(_S1399, _S1399)) > 0.0f;
        }
        else
        {
            _S1398 = false;
        }
        bool _S1400;
        if(_S1398)
        {
            _S1400 = true;
        }
        else
        {
            BSDFMaterial _S1401 = _S1388.material;
            bool _S1402 = isTranslucent_0(&_S1401);
            _S1400 = _S1402;
        }
        bool _S1403;
        if(_S1400)
        {
            _S1403 = true;
        }
        else
        {
            bool _S1404 = (_S1388.material.transmission) > 0.0f;
            if(_S1404)
            {
                uint _S1405 = (fcptLayers((hit_4)));
                _S1403 = _S1405 == 1U;
            }
            else
            {
                _S1403 = false;
            }
        }
        float3  _S1406 = emitted_0(_S1388.material.emissive, (&ray_2)->unit_direction, front_n_0);
        float3  emission_0;
        if(_S1354)
        {
            float3  _S1407 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1407;
        }
        else
        {
            emission_0 = _S1406;
        }
        bool _S1408 = !replay_1;
        bool _S1409;
        if(_S1408)
        {
            _S1409 = true;
        }
        else
        {
            _S1409 = b_5 >= _S1228;
        }
        bool _S1410;
        if(_S1409)
        {
            float _S1411 = rgb_to_greyscale(emission_0);
            _S1410 = _S1411 > 0.0f;
        }
        else
        {
            _S1410 = false;
        }
        float3  emission_1;
        if(_S1410)
        {
            NEEVertex _S1412 = nee_vertex_0;
            FKHit _S1413 = hit_4;
            float _S1414 = emissionWeight_0(&_S1412, &_S1413, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1414);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1415;
        if(replay_1)
        {
            _S1415 = _S1217 == 1U;
        }
        else
        {
            _S1415 = false;
        }
        bool _S1416;
        if(_S1415)
        {
            _S1416 = b_5 > _S1216;
        }
        else
        {
            _S1416 = false;
        }
        bool _S1417;
        if(_S1416)
        {
            _S1417 = b_5 == _S1215;
        }
        else
        {
            _S1417 = false;
        }
        bool _S1418;
        if(_S1417)
        {
            bool _S1419 = _S1218 == 1U;
            if(_S1419)
            {
                _S1418 = true;
            }
            else
            {
                _S1418 = _S1218 == 2U;
            }
        }
        else
        {
            _S1418 = false;
        }
        if(_S1418)
        {
            bool _S1420 = _S1354 != (_S1218 == 2U);
            if(_S1420)
            {
                return _S1213;
            }
            return Shift_x24init_0(throughput_5 * emission_1 / make_float3 (r_8->jac), density_2 / r_8->jac);
        }
        uint _S1421 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1422 = _S1421 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1423 = insertBits_0(0U, b_5, 5U, 5U);
        uint _S1424 = insertBits_0(_S1423, 1U, 10U, 2U);
        uint _S1425 = insertBits_0(_S1424, (&prev_0)->lobe, 15U, 3U);
        bool _S1426 = (&prev_0)->inside;
        uint _S1427 = _slang_select(_S1426, 1U,0U);
        uint _S1428 = insertBits_0(_S1425, _S1427, 22U, 1U);
        (&here_0)->path = _S1428;
        float _S1429 = (&prev_0)->pdf * geometry_density_0;
        (&here_0)->jac = _S1429;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1430;
        if(replay_1)
        {
            _S1430 = _S1217 == 1U;
        }
        else
        {
            _S1430 = false;
        }
        bool _S1431;
        if(_S1430)
        {
            _S1431 = b_5 == _S1216;
        }
        else
        {
            _S1431 = false;
        }
        bool _S1432 = b_5 == _S1228;
        bool _S1433;
        if(_S1432)
        {
            bool _S1434 = !scatter_2;
            if(_S1434)
            {
                _S1433 = true;
            }
            else
            {
                bool _S1435 = _S1217 != 1U;
                if(_S1435)
                {
                    _S1433 = _S1217 != 3U;
                }
                else
                {
                    _S1433 = false;
                }
            }
        }
        else
        {
            _S1433 = false;
        }
        bool _S1436;
        if(_S1433)
        {
            _S1436 = _S1217 == 2U;
        }
        else
        {
            _S1436 = false;
        }
        bool _S1437;
        if(_S1436)
        {
            _S1437 = !_S1387;
        }
        else
        {
            _S1437 = false;
        }
        bool _S1438;
        if(_S1437)
        {
            _S1438 = _S1218 != 4U;
        }
        else
        {
            _S1438 = false;
        }
        bool _S1439 = _S1216 == _S1215;
        bool _S1440;
        if(_S1439)
        {
            _S1440 = _S1218 == 0U;
        }
        else
        {
            _S1440 = false;
        }
        bool _S1441;
        if(_S1440)
        {
            _S1441 = ((&hit_4)->instance_index) == (_S1229.instance_index);
        }
        else
        {
            _S1441 = false;
        }
        bool _S1442;
        if(_S1441)
        {
            _S1442 = ((&hit_4)->triangle_index) == (_S1229.triangle_index);
        }
        else
        {
            _S1442 = false;
        }
        bool _S1443;
        if(_S1442)
        {
            _S1443 = _S1387;
        }
        else
        {
            _S1443 = false;
        }
        bool _S1444 = _slang_select(_S1431, _S1443,_S1438);
        bool _S1445;
        if(nee_0)
        {
            _S1445 = _slang_select(replay_1, _S1444,scatter_2);
        }
        else
        {
            _S1445 = false;
        }
        TreeSample _S1446 = TreeSample_x24init_0(_S1212, _S1212, 0.0f, 0U);
        uint2  _S1447 = make_uint2 (0U);
        float2  _S1448 = make_float2 (0.0f);
        FKHit _S1449 = Hit_x24init_0(_S1448, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1450 = _S1449;
        ShadowContext _S1451 = ShadowContext_x24init_0(_S1212, _S1212, _S1447, _S1212, 0U, 0U, false, 0.0f, 0.0f, &_S1450, false);
        bool _S1452;
        if(nee_0)
        {
            _S1452 = _S1409;
        }
        else
        {
            _S1452 = false;
        }
        ShadowContext context_5;
        if(_S1452)
        {
            uint _S1453 = arrivalLobe_0(b_5, (&prev_0)->lobe);
            FKMedium _S1454 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1455 = surface_12;
            FKHit _S1456 = hit_4;
            FKMedium _S1457 = _S1454;
            ShadowContext _S1458 = shadowContext_0(&_S1455, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_5, _S1453, (&hit_4)->distance, width_3, &_S1456, _S1398, &_S1457);
            context_5 = _S1458;
        }
        else
        {
            context_5 = _S1451;
        }
        float3  throughput_6;
        float3  lit_0;
        if(_S1445)
        {
            float3  _S1459 = (&ray_2)->origin;
            if(_S1398)
            {
                throughput_6 = _S1212;
            }
            else
            {
                throughput_6 = _S1389.smooth_n;
            }
            FKSurface _S1460 = surface_12;
            uint _S1461 = stream(_S1240, b_5 + 64U);
            ShadowContext _S1462 = context_5;
            TreeSample _S1463 = sampleLightTree_0(_S1459, throughput_6, surface_12.geometry_n, surface_12.geometry_offset, _S1403, _S1461, &_S1462);
            bool _S1464 = any_1((_S1463.radiance) != _S1212);
            if(_S1464)
            {
                if(_S1398)
                {
                    uint _S1465 = (fcptMaxBounces());
                    bool _S1466 = b_5 < _S1465;
                    FKSurface _S1467 = surface_12;
                    TreeSample _S1468 = _S1463;
                    float3  _S1469 = hairLight_0(&_S1467, (&ray_2)->unit_direction, &_S1468, _S1466);
                    lit_0 = _S1469;
                }
                else
                {
                    float _S1470 = _S1391.x;
                    float _S1471 = _S1391.y;
                    uint _S1472 = (fcptMaxBounces());
                    bool _S1473 = b_5 < _S1472;
                    TreeSample _S1474 = _S1463;
                    BSDFMaterial _S1475 = _S1388.material;
                    float3  _S1476 = lightBSDF_0((&ray_2)->unit_direction, &_S1474, _S1389.smooth_n, _S1460.geometry_n, &_S1475, _S1470, _S1471, _S1473, surface_12.random_state);
                    lit_0 = _S1476;
                }
            }
            else
            {
                lit_0 = _S1212;
            }
            light_3 = _S1463;
        }
        else
        {
            light_3 = _S1446;
            lit_0 = _S1212;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1477;
        bool _S1478;
        float density_4;
        if(_S1431)
        {
            bool _S1479 = !_S1387;
            if(_S1479)
            {
                return _S1213;
            }
            float3  throughput_7 = throughput_5 * make_float3 (geometry_density_0);
            float density_5 = density_2 * geometry_density_0;
            if(_S1439)
            {
                viewed_1 = _S1218 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                return Shift_x24init_0(throughput_7 * emission_1 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1439)
            {
                refracted_4 = _S1218 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S1480 = !nee_0;
                if(_S1480)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1481 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1481 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1213;
                }
                return Shift_x24init_0(throughput_7 * lit_0 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1439)
            {
                wrong_side_0 = _S1218 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1482 = !nee_0;
                if(_S1482)
                {
                    return _S1213;
                }
                float _S1483 = environmentPdf_0(r_8->dir);
                float3  _S1484 = skyBSDF((&ray_2)->unit_direction, r_8->dir, surface_12, _S1391, is_inside_6, _S1483, surface_12.random_state);
                return Shift_x24init_0(throughput_7 * _S1484 * r_8->radiance / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            uint _S1485 = extractBits_0(_S1214, 21U, 1U);
            bool _S1486 = nee_0 != (_S1485 == 1U);
            if(_S1486)
            {
                return _S1213;
            }
            throughput_6 = throughput_7;
            density_4 = density_5;
        }
        else
        {
            if(replay_1)
            {
                viewed_1 = _S1432;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1487 = !scatter_2;
                if(_S1487)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1488 = _S1217 != 1U;
                    if(_S1488)
                    {
                        refracted_4 = _S1217 != 3U;
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
                bool _S1489 = _S1217 == 2U;
                if(_S1489)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1387;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1218 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1398)
                    {
                        return _S1213;
                    }
                    uint _S1490 = stream(_S1240, b_5 + 448U);
                    FKRay _S1491 = ray_2;
                    FKSurface _S1492 = surface_12;
                    ShadowContext _S1493 = context_5;
                    SkySample _S1494 = sampleSky_0(&_S1491, &_S1492, _S1391, is_inside_6, _S1490, surface_12.random_state, &_S1493);
                    return Shift_x24init_0(throughput_5 * _S1494.color, 1.0f);
                }
                if(_S1489)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1387;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1495 = rgb_to_greyscale(light_3.radiance);
                    bool _S1496 = !(_S1495 > 0.0f);
                    if(_S1496)
                    {
                        return _S1213;
                    }
                    return Shift_x24init_0(throughput_5 * lit_0, 1.0f);
                }
                if(_S1227)
                {
                    passes_0 = _S1218 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1354;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                if(_S1227)
                {
                    passes_0 = _S1218 == 1U;
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
                    passes_0 = !_S1387;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                return _S1213;
            }
            else
            {
                if(_S1408)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1497 = b_5 > 0U;
                    if(_S1497)
                    {
                        Reservoir candidate_5 = chain_0;
                        if(_S1422)
                        {
                            float3  _S1498 = safeDivide(throughput_5 * emission_1, chain_throughput_0);
                            (&candidate_5)->radiance = _S1498;
                        }
                        else
                        {
                            if(_S1387)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1499 = throughput_5 * emission_1;
                        Reservoir _S1500 = withEnd(candidate_5, 1U, b_5, _S1499);
                        offer(sel_7, _S1500, _S1499 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1501 = throughput_5 * emission_1;
                        float3  _S1502 = sel_7->glow + _S1501;
                        sel_7->glow = _S1502;
                    }
                    if(nee_0)
                    {
                        float3  _S1503 = throughput_5 * lit_0;
                        Reservoir candidate_6 = chain_0;
                        if(_S1422)
                        {
                            float3  _S1504 = safeDivide(_S1503, chain_throughput_0);
                            (&candidate_6)->radiance = _S1504;
                        }
                        else
                        {
                            if(_S1387)
                            {
                                candidate_6 = here_0;
                                uint _S1505 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1505;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1506 = insertBits_0(0U, b_5 + 1U, 5U, 5U);
                                uint _S1507 = insertBits_0(_S1506, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1507;
                            }
                        }
                        Reservoir _S1508 = withEnd(candidate_6, 0U, b_5, _S1503);
                        offer(sel_7, _S1508, _S1503 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1398)
                        {
                            _S1477 = false;
                        }
                        else
                        {
                            bool _S1509 = environmentMapped_0();
                            _S1477 = _S1509;
                        }
                    }
                    else
                    {
                        _S1477 = false;
                    }
                    if(_S1477)
                    {
                        uint _S1510 = (fcptMaxBounces());
                        _S1478 = b_5 < _S1510;
                    }
                    else
                    {
                        _S1478 = false;
                    }
                    if(_S1478)
                    {
                        uint _S1511 = stream(_S1240, b_5 + 448U);
                        FKRay _S1512 = ray_2;
                        FKSurface _S1513 = surface_12;
                        ShadowContext _S1514 = context_5;
                        SkySample _S1515 = sampleSky_0(&_S1512, &_S1513, _S1391, is_inside_6, _S1511, surface_12.random_state, &_S1514);
                        float3  _S1516 = throughput_5 * _S1515.color;
                        Reservoir candidate_7 = chain_0;
                        if(_S1422)
                        {
                            float3  _S1517 = safeDivide(_S1516, chain_throughput_0);
                            (&candidate_7)->radiance = _S1517;
                        }
                        else
                        {
                            if(_S1387)
                            {
                                candidate_7 = here_0;
                                uint _S1518 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1518;
                                (&candidate_7)->dir = _S1515.dir;
                                (&candidate_7)->radiance = _S1515.radiance;
                            }
                            else
                            {
                                uint _S1519 = insertBits_0(0U, b_5 + 1U, 5U, 5U);
                                uint _S1520 = insertBits_0(_S1519, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1520;
                            }
                        }
                        Reservoir _S1521 = withEnd(candidate_7, 4U, b_5, _S1516);
                        offer(sel_7, _S1521, _S1516 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                }
            }
            throughput_6 = throughput_5;
            density_4 = density_2;
        }
        bool _S1522;
        bool _S1523;
        bool _S1524;
        bool straight_0;
        bool _S1525;
        bool _S1526;
        bool _S1527;
        bool _S1528;
        bool _S1529;
        bool _S1530;
        bool _S1531;
        bool _S1532;
        bool _S1533;
        bool _S1534;
        bool _S1535;
        bool _S1536;
        bool _S1537;
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
                viewed_1 = _S1432;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1538 = extractBits_0(_S1214, 15U, 3U);
            uint _S1539 = extractBits_0(_S1214, 18U, 3U);
            uint _S1540 = _slang_select(_S1431, _S1539,_S1538);
            float3  _S1541 = r_8->dir;
            bool refracted_5 = _S1540 == 1U;
            SampleBSDF _S1542 = SampleBSDF_x24init_0(_S1212, _S1212, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1542;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1543 = extractBits_0(_S1214, 22U, 1U);
                bool _S1544 = is_inside_6 != (_S1543 == 1U);
                if(_S1544)
                {
                    return _S1213;
                }
                bool _S1545 = _S1217 == 1U;
                if(_S1545)
                {
                    float3  _S1546 = (fcptHitPosition((_S1229)));
                    throughput_8 = _S1546;
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
                    BSDFMaterial _S1547 = _S1388.material;
                    bool _S1548 = isTranslucent_0(&_S1547);
                    if(_S1548)
                    {
                        refracted_4 = _S1540 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1549 = throughput_8 - (&ray_2)->origin;
                        float3  _S1550 = _slang_select(_S1545, _S1549,_S1541);
                        wrong_side_0 = (dot_0(_S1389.smooth_n, _S1550) * _S1390) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1545)
                {
                    float3  _S1551 = (&ray_2)->origin;
                    FKSurface _S1552 = surface_12;
                    float3  _S1553 = - _S1389.smooth_n;
                    bool _S1554 = is_inside_6 != refracted_4;
                    float3  _S1555 = _slang_select(_S1554, _S1553,_S1389.smooth_n);
                    float3  _S1556 = throughput_8 - (_S1551 + make_float3 (_S1552.geometry_offset) * _S1555);
                    float3  _S1557 = ((((_S1556)) * make_float3(rnorm3df(((_S1556)).x, ((_S1556)).y, ((_S1556)).z))));
                    reconnection_1 = _S1557;
                }
                else
                {
                    reconnection_1 = _S1541;
                }
                if(_S1398)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1558 = wrongSide_0(is_inside_6, refracted_4, reconnection_1, surface_12.geometry_n);
                    wrong_side_0 = _S1558;
                }
                if(wrong_side_0)
                {
                    return _S1213;
                }
                float3  _S1559 = throughput_8;
                throughput_8 = reconnection_1;
                b_8 = _S1540;
                wrong_side_0 = false;
                reconnection_1 = _S1559;
            }
            else
            {
                bool _S1560 = !_S1431;
                if(_S1560)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1561;
                    if(_S1398)
                    {
                        SampleBSDF _S1562 = (fcptSampleHair((surface_12.hair), (_S1388.material.albedo), (_S1388.material.specular_tint), ((&ray_2)->unit_direction), (surface_12.random_state)));
                        _S1561 = _S1562;
                    }
                    else
                    {
                        SampleBSDF _S1563 = sampleBSDF((&ray_2)->unit_direction, _S1389.smooth_n, _S1388.material, _S1391.x, _S1391.y, surface_12.random_state, _S1448);
                        _S1561 = _S1563;
                    }
                    bsdf_sampled_0 = _S1561;
                    if(_S1398)
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
                            return _S1213;
                        }
                        break;
                    }
                    if(_S1398)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1564 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_12.geometry_n);
                        wrong_side_0 = _S1564;
                    }
                    if(wrong_side_0)
                    {
                        _S1477 = (_S1388.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1477 = false;
                    }
                    if(_S1477)
                    {
                        SampleBSDF _S1565 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S1388.material, _S1391.x, _S1391.y, (&bsdf_sampled_0)->random_state, _S1448);
                        (&bsdf_sampled_0)->unit_direction = _S1565.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1565.refracted;
                        (&bsdf_sampled_0)->throughput = _S1565.throughput;
                        (&bsdf_sampled_0)->lobe = _S1565.lobe;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1566 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n)) * surface_12.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1566;
                        }
                    }
                    uint _S1567 = (&bsdf_sampled_0)->lobe;
                    float3  _S1568 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1569 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1570 = (&bsdf_sampled_0)->pdf;
                    float _S1571 = _slang_select(wrong_side_0, 0.0f,_S1570);
                    (&lobe_5)->pdf = _S1571;
                    throughput_8 = _S1568;
                    b_8 = _S1567;
                    refracted_4 = _S1569;
                }
                else
                {
                    throughput_8 = _S1541;
                    b_8 = _S1540;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1477 = true;
            }
            else
            {
                _S1477 = _S1431;
            }
            float3  chain_throughput_1;
            if(_S1477)
            {
                if(_S1398)
                {
                    SampleBSDF _S1572 = (fcptConnectHair((surface_12.hair), (_S1388.material.albedo), (_S1388.material.specular_tint), ((&ray_2)->unit_direction), (throughput_8)));
                    lobe_5 = _S1572;
                }
                else
                {
                    float3  _S1573 = (&ray_2)->unit_direction;
                    float _S1574 = sign_0(_S1390);
                    float3  _S1575 = _S1389.smooth_n * make_float3 (_S1574);
                    float _S1576 = dot_0(_S1575, throughput_8);
                    float _S1577 = _S1388.material.roughness;
                    float _S1578 = _S1577 * _S1577;
                    AnisotropicFrame _S1579 = anisotropicFrame(_S1388.material, _S1575);
                    float3  _S1580 = negate_0(_S1573);
                    SheenProfile _S1581 = sheenProfile(_S1580, _S1575, _S1388.material);
                    float3  _S1582 = reflectedHalf(_S1573, throughput_8);
                    bool _S1583 = b_8 == 1U;
                    if(_S1583)
                    {
                        float3  _S1584 = refractedHalf(_S1573, throughput_8, _S1389.smooth_n, _S1391.x, _S1391.y);
                        throughput_9 = _S1584;
                    }
                    else
                    {
                        throughput_9 = _S1582;
                    }
                    bool _S1585 = b_8 == 0U;
                    if(_S1585)
                    {
                        _S1478 = true;
                    }
                    else
                    {
                        _S1478 = b_8 == 6U;
                    }
                    if(_S1478)
                    {
                        float3  _S1586 = sampledHalf(_S1573, _S1389.smooth_n, _S1388.material, surface_12.random_state, _S1579);
                        throughput_10 = _S1586;
                    }
                    else
                    {
                        throughput_10 = throughput_9;
                    }
                    float3  _S1587 = negate_0(_S1573);
                    float _S1588 = _S1391.x;
                    float _S1589 = _S1391.y;
                    BSDFLobes _S1590 = bsdfLobes(_S1573, _S1587, _S1575, throughput_10, _S1388.material, _S1588, _S1589, _S1579, _S1581);
                    BSDFLobes lobe_terms_1 = _S1590;
                    float _S1591 = translucentShare(_S1388.material);
                    (&lobe_terms_1)->translucent_share = _S1591;
                    switch(b_8)
                    {
                    case 0U:
                        {
                            float _S1592 = diffusePDF(_S1576, 0.0f, (F32_abs((_S1390))), _S1578, lobe_terms_1, _S1588, _S1589);
                            float3  _S1593 = diffuseBSDF(throughput_8, _S1575, _S1578, _S1388.material, lobe_terms_1);
                            density_6 = _S1592;
                            chain_throughput_1 = _S1593;
                            break;
                        }
                    case 1U:
                        {
                            float _S1594 = refractPDF(_S1576, dot_0(throughput_8, throughput_10), (F32_abs((_S1390))), _S1578, lobe_terms_1, _S1588, _S1589);
                            float3  _S1595 = refractBSDF(throughput_8, _S1575, _S1578, _S1388.material, lobe_terms_1);
                            density_6 = _S1594;
                            chain_throughput_1 = _S1595;
                            break;
                        }
                    case 4U:
                        {
                            float _S1596 = sheenVelvetPDF(_S1576, 0.0f, (F32_abs((_S1390))), _S1578, lobe_terms_1, _S1588, _S1589);
                            float3  _S1597 = sheenVelvetBSDF(throughput_8, _S1575, _S1578, _S1388.material, lobe_terms_1);
                            density_6 = _S1596;
                            chain_throughput_1 = _S1597;
                            break;
                        }
                    case 6U:
                        {
                            float _S1598 = toonPDF(_S1576, dot_0(throughput_8, (&lobe_terms_1)->toon_axis), (F32_abs((_S1390))), _S1578, lobe_terms_1, _S1588, _S1589);
                            float3  _S1599 = toonBSDF(throughput_8, _S1575, _S1578, _S1388.material, lobe_terms_1);
                            density_6 = _S1598;
                            chain_throughput_1 = _S1599;
                            break;
                        }
                    default:
                        {
                            float _S1600 = reflectPDF(_S1576, 0.0f, (F32_abs((_S1390))), _S1578, lobe_terms_1, _S1588, _S1589);
                            float3  _S1601 = reflectBSDF(throughput_8, _S1575, _S1578, _S1388.material, lobe_terms_1);
                            density_6 = _S1600;
                            chain_throughput_1 = _S1601;
                            break;
                        }
                    }
                    bool _S1602 = density_6 > 0.0f;
                    if(_S1602)
                    {
                        SampleBSDF _S1603 = SampleBSDF_x24init_0(throughput_8, chain_throughput_1, surface_12.random_state, _S1583, b_8, density_6);
                        lobe_5 = _S1603;
                    }
                }
            }
            bool _S1604 = b_8 == 0U;
            if(_S1604)
            {
                _S1478 = true;
            }
            else
            {
                _S1478 = b_8 == 4U;
            }
            if(_S1478)
            {
                _S1522 = true;
            }
            else
            {
                _S1522 = b_8 == 6U;
            }
            if(_S1398)
            {
                _S1523 = false;
            }
            else
            {
                bool _S1605 = !_S1522;
                if(_S1605)
                {
                    bool _S1606 = (_S1388.material.roughness) == 0.0f;
                    if(_S1606)
                    {
                        _S1523 = true;
                    }
                    else
                    {
                        bool _S1607 = b_8 == 1U;
                        if(_S1607)
                        {
                            _S1523 = (_S1391.x) == (_S1391.y);
                        }
                        else
                        {
                            _S1523 = false;
                        }
                    }
                }
                else
                {
                    _S1523 = false;
                }
            }
            bool _S1608 = !_S1398;
            if(_S1608)
            {
                _S1524 = b_8 == 1U;
            }
            else
            {
                _S1524 = false;
            }
            if(_S1524)
            {
                straight_0 = (_S1388.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1525 = _S1608;
            }
            else
            {
                _S1525 = false;
            }
            if(_S1525)
            {
                _S1526 = b_8 == 1U;
            }
            else
            {
                _S1526 = false;
            }
            if(_S1526)
            {
                _S1527 = (_S1391.x) == (_S1391.y);
            }
            else
            {
                _S1527 = false;
            }
            BSDFMaterial _S1609 = _S1388.material;
            bool _S1610 = isTranslucent_0(&_S1609);
            if(_S1610)
            {
                _S1528 = _S1604;
            }
            else
            {
                _S1528 = false;
            }
            if(_S1528)
            {
                _S1529 = (dot_0(throughput_8, surface_12.geometry_n)) < 0.0f;
            }
            else
            {
                _S1529 = false;
            }
            if(nee_0)
            {
                _S1530 = !_S1523;
            }
            else
            {
                _S1530 = false;
            }
            if(_S1530)
            {
                _S1531 = !wrong_side_0;
            }
            else
            {
                _S1531 = false;
            }
            if(_S1531)
            {
                float _S1611 = (&lobe_5)->pdf;
                float3  _S1612 = (&ray_2)->origin;
                float3  _S1613 = _slang_select(_S1403, _S1212,_S1389.smooth_n);
                float3  _S1614 = (&ray_2)->origin;
                FKSurface _S1615 = surface_12;
                float3  _S1616 = - _S1389.smooth_n;
                float3  _S1617 = _slang_select(_S1529, _S1616,_S1389.smooth_n);
                NEEVertex _S1618 = NEEVertex_x24init_0(false, _S1611, _S1612, _S1613, _S1614 + make_float3 (_S1615.geometry_offset) * _S1617);
                nee_vertex_0 = _S1618;
            }
            else
            {
                if(_S1398)
                {
                    _S1532 = true;
                }
                else
                {
                    bool _S1619 = b_8 != 1U;
                    if(_S1619)
                    {
                        _S1532 = true;
                    }
                    else
                    {
                        _S1532 = (_S1391.x) != (_S1391.y);
                    }
                }
                if(_S1532)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1620 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1620)
            {
                if(_S1522)
                {
                    _S1532 = true;
                }
                else
                {
                    _S1532 = ((&lobe_5)->pdf * (&prev_0)->cos / ((&hit_4)->distance * (&hit_4)->distance) * threshold_0) <= 1.0f;
                }
            }
            else
            {
                _S1532 = false;
            }
            bool _S1621 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1621)
            {
                if(_S1522)
                {
                    _S1533 = true;
                }
                else
                {
                    _S1533 = (_S1388.material.roughness) >= 0.20000000298023224f;
                }
            }
            else
            {
                _S1533 = false;
            }
            if(_S1431)
            {
                bool _S1622 = !_S1532;
                if(_S1622)
                {
                    return _S1213;
                }
                bool _S1623 = _S1218 != 1U;
                if(_S1623)
                {
                    _S1534 = _S1218 != 2U;
                }
                else
                {
                    _S1534 = false;
                }
                if(_S1534)
                {
                    float _S1624 = (&lobe_5)->pdf;
                    float _S1625 = _slang_select(nee_0, _S1624,0.0f);
                    float _S1626 = escapeWeight_0(_S1625, _S1541);
                    if(_S1439)
                    {
                        passes_0 = _S1224;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1627 = _slang_select(passes_0, _S1626,1.0f);
                    return Shift_x24init_0(throughput_6 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_8->radiance * make_float3 (_S1627) / make_float3 (r_8->jac), density_4 * (&lobe_5)->pdf / r_8->jac);
                }
                float3  _S1628 = throughput_6 * make_float3 ((&lobe_5)->pdf);
                float _S1629 = density_4 * (&lobe_5)->pdf;
                throughput_9 = _S1628;
                density_6 = _S1629;
            }
            else
            {
                throughput_9 = throughput_6;
                density_6 = density_4;
            }
            uint _S1630 = (fcptLayers((hit_4)));
            bool _S1631 = _S1630 > 1U;
            if(_S1631)
            {
                _S1534 = (b_8 == 1U) != passes_0;
            }
            else
            {
                _S1534 = false;
            }
            if(viewed_1)
            {
                _S1535 = _S1534;
            }
            else
            {
                _S1535 = false;
            }
            if(_S1535)
            {
                return _S1213;
            }
            if(replay_1)
            {
                _S1536 = b_5 <= _S1228;
            }
            else
            {
                _S1536 = false;
            }
            if(_S1536)
            {
                _S1537 = _S1387;
            }
            else
            {
                _S1537 = false;
            }
            bool _S1632;
            if(_S1537)
            {
                _S1632 = _S1532;
            }
            else
            {
                _S1632 = false;
            }
            bool _S1633;
            if(_S1632)
            {
                _S1633 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1633 = !_S1533;
                }
                else
                {
                    _S1633 = false;
                }
            }
            if(_S1633)
            {
                return _S1213;
            }
            if(viewed_1)
            {
                float3  _S1634 = throughput_9 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1635 = (&lobe_5)->pdf;
                throughput_10 = _S1634;
                sky_pdf_2 = _S1635;
            }
            else
            {
                float3  _S1636 = throughput_9 * max_0((&lobe_5)->throughput, _S1212);
                throughput_10 = _S1636;
                sky_pdf_2 = density_6;
            }
            bool _S1637;
            if(_S1408)
            {
                _S1637 = !_S1422;
            }
            else
            {
                _S1637 = false;
            }
            bool _S1638;
            if(_S1637)
            {
                _S1638 = _S1387;
            }
            else
            {
                _S1638 = false;
            }
            bool _S1639;
            if(_S1638)
            {
                _S1639 = _S1532;
            }
            else
            {
                _S1639 = false;
            }
            if(_S1639)
            {
                chain_0 = here_0;
                uint _S1640 = insertBits_0((&chain_0)->path, b_8, 18U, 3U);
                uint _S1641 = _slang_select(nee_0, 1U,0U);
                uint _S1642 = insertBits_0(_S1640, _S1641, 21U, 1U);
                (&chain_0)->path = _S1642;
                float _S1643 = (&chain_0)->jac * (&lobe_5)->pdf;
                (&chain_0)->jac = _S1643;
                (&chain_0)->dir = throughput_8;
                chain_throughput_1 = throughput_10;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1644 = surface_12;
            Vertex _S1645 = Vertex_x24init_0(_S1533, b_8, (&lobe_5)->pdf, (F32_abs((dot_0(surface_12.geometry_n, throughput_8)))), is_inside_6);
            prev_0 = _S1645;
            float _S1646 = (&lobe_5)->pdf;
            bool _S1647 = b_8 == 1U;
            bool _S1648;
            if(_S1647)
            {
                _S1648 = (_S1391.x) == (_S1391.y);
            }
            else
            {
                _S1648 = false;
            }
            float sky_pdf_3 = _slang_select(_S1648, sky_pdf_0,_S1646);
            float _S1649 = _slang_select(_S1398, 0.0f,sky_pdf_3);
            float _S1650 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * (&lobe_5)->pdf))))), (3.14159274101257324f)));
            bool _S1651 = !_S1523;
            float _S1652 = _slang_select(_S1651, _S1650,0.0f);
            float _S1653 = spread_1 + _S1652;
            bool _S1654;
            if(refracted_4)
            {
                _S1654 = !_S1529;
            }
            else
            {
                _S1654 = false;
            }
            bool is_inside_7;
            if(_S1654)
            {
                bool _S1655 = !is_inside_6;
                is_inside_7 = _S1655;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            FKSurface _S1656 = surface_12;
            bool _S1657 = boundsVolume_0(&_S1656);
            bool _S1658;
            if(_S1657)
            {
                _S1658 = !_S1534;
            }
            else
            {
                _S1658 = false;
            }
            if(_S1658)
            {
                FKSurface faced_2 = surface_12;
                float3  _S1659 = - _S1644.geometry_n;
                float3  _S1660 = _slang_select(turned_1, _S1659,_S1644.geometry_n);
                (&faced_2)->geometry_n = _S1660;
                FKMedium _S1661 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1662 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1663 = faced_2;
                FKMedium _S1664 = _S1661;
                FKMedium _S1665 = _S1662;
                MediumSides _S1666 = mediumSides_0(&_S1663, &_S1664, filling_2, (&ray_2)->unit_direction, &_S1665);
                bool _S1667 = ((dot_0(throughput_8, _S1644.geometry_n)) > 0.0f) == ((dot_0(_S1644.geometry_n, (&faced_2)->geometry_n)) > 0.0f);
                float3  _S1668 = _slang_select(_S1667, _S1666.front.scatter,_S1666.behind.scatter);
                scatter_in_0 = _S1668;
                float3  _S1669 = _slang_select(_S1667, _S1666.front.extinction,_S1666.behind.extinction);
                extinction_in_0 = _S1669;
                float _S1670 = _slang_select(_S1667, _S1666.front.g,_S1666.behind.g);
                g_in_0 = _S1670;
                uint _S1671 = _S1666.fillings.x;
                uint _S1672 = _S1666.fillings.y;
                uint _S1673 = _slang_select(_S1667, _S1672,_S1671);
                bool _S1674 = (fcptVaryingUsed());
                uint _S1675 = _slang_select(_S1674, _S1673,4294967295U);
                filling_2 = _S1675;
            }
            (&ray_2)->unit_direction = throughput_8;
            bool _S1676 = !_S1534;
            if(_S1676)
            {
                FKSurface _S1677 = surface_12;
                float _S1678 = _slang_select(straight_0, 0.0f,_S1677.geometry_offset);
                float3  _S1679 = - _S1389.smooth_n;
                bool _S1680 = is_inside_7 != _S1529;
                float3  _S1681 = _slang_select(_S1680, _S1679,_S1389.smooth_n);
                float3  _S1682 = (&ray_2)->origin + make_float3 (_S1678) * _S1681;
                (&ray_2)->origin = _S1682;
            }
            throughput_9 = throughput_10;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1534;
            viewed_1 = _S1527;
            sky_pdf_2 = _S1649;
            spread_4 = _S1653;
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
        if(_S1408)
        {
            if(_S1354)
            {
                float3  _S1683 = throughput_9 * emission_1;
                Reservoir candidate_8 = chain_0;
                uint _S1684 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1685 = _S1684 == 1U;
                if(_S1685)
                {
                    float3  _S1686 = safeDivide(_S1683, chain_throughput_0);
                    (&candidate_8)->radiance = _S1686;
                }
                Reservoir _S1687 = withEnd(candidate_8, 2U, b_5, _S1683);
                offer(sel_7, _S1687, _S1683 * make_float3 (scale_3) / make_float3 (density_6));
            }
            if(_S1354)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1688 = survivalProbability(throughput_9, density_6);
                density_7 = _S1688;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1689 = stream(_S1240, b_5 + 128U);
            Random _S1690 = pcg(_S1689);
            bool _S1691 = density_7 < (_S1690.value);
            if(_S1691)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1692 = (fcptMaxBounces());
                wrong_side_0 = b_5 >= _S1692;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1693 = density_6 * density_7;
            density_7 = _S1693;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1694 = layer_0 ^ 1U;
        uint _S1695 = _slang_select(passes_0, _S1694,0U);
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
            uint _S1696 = b_8 + 1U;
            b_5 = _S1696;
            layer_0 = _S1695;
            continue;
        }
        FKRay _S1697 = ray_2;
        float _S1698 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_1)
        {
            refracted_4 = _S1432;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S1217 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1699 = _slang_select(wrong_side_0, _S1698,4.294967296e+09f);
        bool _S1700 = !_S1398;
        if(straight_0)
        {
            _S1477 = true;
        }
        else
        {
            _S1477 = _S1398;
        }
        FKHit _S1701;
        if(_S1477)
        {
            _S1701 = hit_4;
        }
        else
        {
            _S1701 = _S1449;
        }
        FKHit _S1702 = (fcptTraverseInstanceBVH((_S1697), (_S1361), (_S1699), (_S1700), (_S1701), (viewed_1)));
        hit_4 = _S1702;
        if(replay_1)
        {
            _S1478 = _S1432;
        }
        else
        {
            _S1478 = false;
        }
        if(_S1478)
        {
            _S1522 = _S1217 == 1U;
        }
        else
        {
            _S1522 = false;
        }
        if(_S1522)
        {
            _S1523 = ((&hit_4)->instance_index) == (_S1229.instance_index);
        }
        else
        {
            _S1523 = false;
        }
        if(_S1523)
        {
            _S1524 = ((&hit_4)->triangle_index) == (_S1229.triangle_index);
        }
        else
        {
            _S1524 = false;
        }
        if(_S1524)
        {
            (&hit_4)->uv = _S1229.uv;
            float _S1703 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S1703;
        }
        if(replay_1)
        {
            _S1525 = _S1432;
        }
        else
        {
            _S1525 = false;
        }
        if(_S1525)
        {
            _S1526 = _S1217 == 3U;
        }
        else
        {
            _S1526 = false;
        }
        if(_S1526)
        {
            _S1527 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1527 = false;
        }
        if(_S1527)
        {
            return _S1213;
        }
        Reservoir _S1704 = chain_0;
        uint _S1705 = filling_2;
        for(;;)
        {
            bool _S1706 = (fcptVaryingUsed());
            if(_S1706)
            {
                _S1528 = _S1705 != 4294967295U;
            }
            else
            {
                _S1528 = false;
            }
            float _S1707;
            if(_S1528)
            {
                float _S1708 = (fcptMajorant((_S1705)));
                _S1707 = _S1708;
            }
            else
            {
                _S1707 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_1)
            {
                _S1529 = _S1432;
            }
            else
            {
                _S1529 = false;
            }
            if(_S1529)
            {
                _S1530 = _S1217 == 1U;
            }
            else
            {
                _S1530 = false;
            }
            if(_S1530)
            {
                _S1531 = _S1707 > 0.0f;
            }
            else
            {
                _S1531 = false;
            }
            if(_S1531)
            {
                ended_0 = _S1213;
                sky_pdf_1 = sky_pdf_2;
                spread_2 = spread_4;
                width_4 = width_3;
                density_3 = density_7;
                throughput_10 = throughput_9;
                b_8 = b_5;
                _S1532 = true;
                break;
            }
            bool _S1709 = (&prev_0)->rough;
            if(_S1709)
            {
                _S1532 = !(_S1707 > 0.0f);
            }
            else
            {
                _S1532 = false;
            }
            (&prev_0)->rough = _S1532;
            uint _S1710 = b_5 + 320U;
            bool _S1711 = b_5 == 4294967295U;
            uint _S1712 = _slang_select(_S1711, 384U,_S1710);
            uint _S1713 = stream(_S1240, _S1712);
            uint tracking_1 = _S1713;
            weight_1 = throughput_3;
            glowed_0 = _S1212;
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
                    _S1211 = int(2);
                    break;
                }
                uint _S1714 = b_8 + 320U;
                bool _S1715 = b_8 == 4294967295U;
                uint _S1716 = _slang_select(_S1715, 384U,_S1714);
                uint _S1717 = stream(_S1240, _S1716);
                Random _S1718 = pcg(_S1717);
                float _S1719 = - (F32_log((1.0f - _S1718.value))) / _S1707;
                if(_S1528)
                {
                    float3  _S1720 = (&ray_2)->origin;
                    float3  _S1721 = (&ray_2)->unit_direction;
                    float _S1722 = (&hit_4)->distance;
                    uint _S1723 = _slang_select(_S1715, 0U,b_8);
                    uint _S1724 = (&prev_0)->lobe;
                    uint _S1725 = _slang_select(_S1715, 3U,_S1724);
                    float _S1726 = (fcptTrackMedium((_S1705), (_S1720), (_S1721), (_S1722), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1723), (_S1725), (_S1715)));
                    spread_3 = _S1726;
                }
                else
                {
                    spread_3 = _S1719;
                }
                bool _S1727 = !(spread_3 < ((&hit_4)->distance));
                if(_S1727)
                {
                    _S1211 = int(2);
                    break;
                }
                if(_S1528)
                {
                    _S1533 = _S1408;
                }
                else
                {
                    _S1533 = false;
                }
                if(_S1533)
                {
                    float3  _S1728 = throughput_10 * glowed_0 / make_float3 (density_3);
                    float3  _S1729 = sel_7->glow + _S1728;
                    sel_7->glow = _S1729;
                }
                else
                {
                }
                glowed_0 = _S1212;
                uint b_9 = b_8 + 1U;
                float3  _S1730 = (&ray_2)->origin + make_float3 (spread_3) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1730;
                float3  _S1731 = flightWeight_0(scatter_in_0, extinction_in_0, _S1707, spread_3, true);
                float3  _S1732 = weight_1;
                float3  _S1733 = _slang_select(_S1528, _S1732,_S1731);
                float3  throughput_11 = throughput_10 * _S1733;
                uint _S1734 = stream(_S1240, b_9 + 320U);
                tracking_1 = _S1734;
                weight_1 = throughput_3;
                float width_7 = width_4 + spread_2 * spread_3;
                float _S1735 = spread_2 + 3.14159274101257324f;
                if(_S1408)
                {
                    _S1534 = true;
                }
                else
                {
                    bool _S1736 = b_9 == _S1228;
                    if(_S1736)
                    {
                        _S1534 = !_S1528;
                    }
                    else
                    {
                        _S1534 = false;
                    }
                }
                TreeSample light_4;
                if(_S1534)
                {
                    float3  _S1737 = (&ray_2)->origin;
                    float3  _S1738 = (&ray_2)->unit_direction;
                    float3  _S1739 = (&ray_2)->unit_direction;
                    uint _S1740 = stream(_S1240, b_9 + 64U);
                    float3  _S1741 = extinction_in_0;
                    float3  _S1742 = extinction_in_0;
                    uint2  _S1743 = make_uint2 (_S1705);
                    float3  _S1744 = (&ray_2)->unit_direction;
                    uint _S1745 = arrivalLobe_0(b_9, (&prev_0)->lobe);
                    FKHit _S1746 = _S1449;
                    ShadowContext _S1747 = ShadowContext_x24init_0(_S1741, _S1742, _S1743, _S1744, b_9, _S1745, false, spread_3, width_7, &_S1746, false);
                    ShadowContext _S1748 = _S1747;
                    TreeSample _S1749 = sampleLightTree_0(_S1737, _S1738, _S1739, 0.0f, true, _S1740, &_S1748);
                    light_4 = _S1749;
                }
                else
                {
                    light_4 = _S1446;
                }
                float _S1750 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1751 = (fcptMaxBounces());
                bool _S1752 = b_9 < _S1751;
                if(_S1752)
                {
                    _S1535 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1535 = false;
                }
                float _S1753 = _slang_select(_S1535, _S1750,0.0f);
                float3  _S1754 = throughput_11 * light_4.radiance;
                float _S1755 = powerHeuristic(light_4.density, _S1753);
                float3  _S1756 = _S1754 * make_float3 (_S1750 * _S1755);
                float3  _S1757 = _slang_select(_S1534, _S1756,_S1212);
                if(replay_1)
                {
                    _S1536 = b_9 == _S1228;
                }
                else
                {
                    _S1536 = false;
                }
                if(_S1536)
                {
                    bool _S1758 = _S1217 == 2U;
                    if(_S1758)
                    {
                        float _S1759 = rgb_to_greyscale(_S1757);
                        _S1537 = _S1759 > 0.0f;
                    }
                    else
                    {
                        _S1537 = false;
                    }
                    if(_S1537)
                    {
                        Shift _S1760 = Shift_x24init_0(_S1757, 1.0f);
                        _S1211 = int(1);
                        ended_0 = _S1760;
                        spread_3 = _S1735;
                        width_5 = width_7;
                        throughput_8 = throughput_11;
                        b_6 = b_9;
                        break;
                    }
                    _S1211 = int(1);
                    ended_0 = _S1213;
                    spread_3 = _S1735;
                    width_5 = width_7;
                    throughput_8 = throughput_11;
                    b_6 = b_9;
                    break;
                }
                if(_S1408)
                {
                    Reservoir candidate_9 = _S1704;
                    uint _S1761 = extractBits_0(_S1704.path, 10U, 2U);
                    bool _S1762 = _S1761 == 1U;
                    if(_S1762)
                    {
                        float3  _S1763 = safeDivide(_S1757, chain_throughput_0);
                        (&candidate_9)->radiance = _S1763;
                    }
                    else
                    {
                        uint _S1764 = insertBits_0(0U, b_9 + 1U, 5U, 5U);
                        uint _S1765 = insertBits_0(_S1764, 2U, 10U, 2U);
                        (&candidate_9)->path = _S1765;
                    }
                    Reservoir _S1766 = withEnd(candidate_9, 0U, b_9, _S1757);
                    offer(sel_7, _S1766, _S1757 * make_float3 (scale_3) / make_float3 (density_3));
                    float _S1767 = survivalProbability(throughput_11, density_3);
                    uint _S1768 = stream(_S1240, b_9 + 128U);
                    Random _S1769 = pcg(_S1768);
                    bool _S1770 = _S1767 < (_S1769.value);
                    if(_S1770)
                    {
                        _S1537 = true;
                    }
                    else
                    {
                        uint _S1771 = (fcptMaxBounces());
                        _S1537 = b_9 >= _S1771;
                    }
                    if(_S1537)
                    {
                        _S1211 = int(1);
                        ended_0 = _S1213;
                        spread_3 = _S1735;
                        width_5 = width_7;
                        throughput_8 = throughput_11;
                        b_6 = b_9;
                        break;
                    }
                    float _S1772 = density_3 * _S1767;
                    density_3 = _S1772;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1773 = stream(_S1240, b_9);
                float3  _S1774 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1773, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1774;
                NEEVertex _S1775 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1212, (&ray_2)->origin);
                nee_vertex_0 = _S1775;
                Vertex _S1776 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_5);
                prev_0 = _S1776;
                float _S1777 = (&prev_0)->pdf;
                FKRay _S1778 = ray_2;
                FKHit _S1779 = (fcptTraverseInstanceBVH((_S1778), (true), (4.294967296e+09f), (false), (_S1449), (false)));
                hit_4 = _S1779;
                b_8 = b_9;
                throughput_10 = throughput_11;
                spread_2 = _S1735;
                width_4 = width_7;
                sky_pdf_1 = _S1777;
            }
            if(_S1211 != int(2))
            {
                spread_2 = spread_3;
                width_4 = width_5;
                throughput_10 = throughput_8;
                b_8 = b_6;
                _S1532 = true;
                break;
            }
            ended_0 = _S1213;
            _S1532 = false;
            break;
        }
        if(_S1532)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1533 = b_8 == b_5;
        }
        else
        {
            _S1533 = false;
        }
        bool _S1780 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S1780)
        {
            bool _S1781 = !(&nee_vertex_0)->none;
            float _S1782 = _slang_select(_S1781, sky_pdf_1,0.0f);
            float _S1783 = escapeWeight_0(_S1782, (&ray_2)->unit_direction);
            float3  _S1784 = environment_0((&ray_2)->unit_direction, b_8, (&prev_0)->lobe);
            float3  _S1785 = throughput_10 * _S1784;
            if(replay_1)
            {
                bool _S1786 = b_8 == _S1228;
                if(_S1786)
                {
                    passes_0 = _S1217 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1785 * make_float3 (_S1783) / make_float3 (r_8->jac), density_3 / r_8->jac);
                }
                if(_S1227)
                {
                    passes_0 = _S1224;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_8 == _S1215;
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
                    return Shift_x24init_0(_S1785 * make_float3 (_S1783), 1.0f);
                }
                return _S1213;
            }
            Reservoir candidate_10 = chain_0;
            uint _S1787 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1788 = _S1787 == 1U;
            if(_S1788)
            {
                uint _S1789 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1790 = _S1789 == b_8;
                float _S1791 = _slang_select(_S1790, 1.0f,_S1783);
                float3  _S1792 = safeDivide(_S1785 * make_float3 (_S1791), chain_throughput_0);
                (&candidate_10)->radiance = _S1792;
            }
            else
            {
                bool _S1793 = (&prev_0)->rough;
                if(_S1793)
                {
                    uint _S1794 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                    uint _S1795 = insertBits_0(_S1794, 3U, 10U, 2U);
                    uint _S1796 = insertBits_0(_S1795, (&prev_0)->lobe, 15U, 3U);
                    bool _S1797 = (&prev_0)->inside;
                    uint _S1798 = _slang_select(_S1797, 1U,0U);
                    uint _S1799 = insertBits_0(_S1796, _S1798, 22U, 1U);
                    (&candidate_10)->path = _S1799;
                    (&candidate_10)->jac = (&prev_0)->pdf;
                    (&candidate_10)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1800 = _S1785 * make_float3 (_S1783);
            Reservoir _S1801 = withEnd(candidate_10, 3U, b_8, _S1800);
            offer(sel_7, _S1801, _S1800 * make_float3 (scale_3) / make_float3 (density_3));
            break;
        }
        float3  _S1802 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1802;
        bool _S1803 = (fcptVaryingUsed());
        if(_S1803)
        {
            _S1534 = filling_2 != 4294967295U;
        }
        else
        {
            _S1534 = false;
        }
        if(_S1534)
        {
            if(_S1408)
            {
                float3  _S1804 = throughput_10 * glowed_0 / make_float3 (density_3);
                float3  _S1805 = sel_7->glow + _S1804;
                sel_7->glow = _S1805;
            }
            float3  _S1806 = throughput_10 * weight_1;
            throughput_8 = _S1806;
        }
        else
        {
            float3  _S1807 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S1808 = throughput_10 * _S1807;
            throughput_8 = _S1808;
        }
        float _S1809 = width_4 + spread_2 * (&hit_4)->distance;
        viewed_0 = _S1533;
        width_3 = _S1809;
        throughput_2 = throughput_8;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_1 = spread_2;
        uint _S1696 = b_8 + 1U;
        b_5 = _S1696;
        layer_0 = _S1695;
    }
    return _S1213;
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
    Random _S1810 = pcg(state_3);
    Random _S1811 = pcg(_S1810.state);
    float _S1812 = 6.28318548202514648f * _S1810.value;
    float _S1813 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S1811.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1811.state, _S1813 * (F32_cos((_S1812))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_4, float3  value_2)
{
    RandomSphere _S1814;
    (&_S1814)->state = state_4;
    (&_S1814)->value = value_2;
    return _S1814;
}

__device__ RandomSphere random_sphere(uint state_5)
{
    Random _S1815 = normal_distribution(state_5);
    Random _S1816 = normal_distribution(_S1815.state);
    Random _S1817 = normal_distribution(_S1816.state);
    float3  _S1818 = make_float3 (_S1815.value, _S1816.value, _S1817.value);
    float3  _S1819 = ((((_S1818)) * make_float3(rnorm3df(((_S1818)).x, ((_S1818)).y, ((_S1818)).z))));
    return RandomSphere_x24init_0(_S1817.state, _S1819);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_13)
{
    float3  _S1820 = p1_0 - p0_0;
    float3  _S1821 = p2_0 - p0_0;
    float2  _S1822 = uv1_0 - uv0_0;
    float2  _S1823 = uv2_0 - uv0_0;
    float _S1824 = _S1822.x;
    float _S1825 = _S1823.y;
    float _S1826 = _S1822.y;
    float _S1827 = _S1823.x;
    float _S1828 = _S1824 * _S1825 - _S1826 * _S1827;
    float _S1829 = 1.0f / _S1828;
    float3  t_22 = (_S1820 * make_float3 (_S1825) - _S1821 * make_float3 (_S1826)) * make_float3 (_S1829);
    float3  _S1830 = (_S1821 * make_float3 (_S1824) - _S1820 * make_float3 (_S1827)) * make_float3 (_S1829);
    float3  _S1831 = t_22 - n_13 * make_float3 (dot_0(n_13, t_22));
    float3  _S1832 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_13);
    bool _S1833 = (dot_0(_S1831, _S1831)) > 0.0f;
    float3  _S1834 = _slang_select(_S1833, _S1831,_S1832);
    float3  _S1835 = ((((_S1834)) * make_float3(rnorm3df(((_S1834)).x, ((_S1834)).y, ((_S1834)).z))));
    bool _S1836 = (dot_0(cross_0(n_13, _S1835), _S1830)) > 0.0f;
    float3  t_23;
    if(_S1836)
    {
        float3  _S1837 = negate_0(_S1835);
        t_23 = _S1837;
    }
    else
    {
        t_23 = _S1835;
    }
    float3  _S1838 = cross_0(n_13, t_23);
    return makeMatrix<float, 3, 3> (t_23, _S1838, n_13);
}

__device__ float3  tangentToWorldNormalMap(float3  v_5, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_5, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_4, float3  uvw_0, float3  position_1)
{
    float3  _S1839 = t1_0 - t0_0;
    float3  _S1840 = t2_2 - t0_0;
    float3  _S1841 = t2_2 - t1_0;
    float _S1842 = (F32_min((length_0(_S1839)), ((F32_min((length_0(_S1840)), (length_0(_S1841)))))));
    float3  _S1843 = make_float3 (distance_1(position_1, t0_0), distance_1(position_1, t1_0), distance_1(position_1, t2_2));
    float3  _S1844 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1845 = dot_0(geometry_n_4, _S1844);
    float3  _S1846 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1847 = dot_0(geometry_n_4, _S1846);
    float3  _S1848 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1849 = acos_0(abs_0(make_float3 (_S1845, _S1847, dot_0(geometry_n_4, _S1848))));
    float3  _S1850 = clamp_2(tan_0(_S1849), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S1843 * _S1850, uvw_0), 0.0f, _S1842 * 0.125f);
}

__device__ float3  straightThrough(BSDFMaterial material_23)
{
    return make_float3 (material_23.transmission * (1.0f - material_23.metallic)) * material_23.albedo;
}

__device__ float hairRow(float3  in_dir_11, float3  t_24, float3  out_dir_3, uint p_15, float w_2, float alpha_20, uint nt_0)
{
    uint _S1851 = p_15 % 4U;
    float _S1852 = w_2 * HAIR_WIDTHS_0[_S1851];
    float _S1853 = (F32_asin((clamp_1(dot_0(out_dir_3, t_24), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_11, t_24), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1851] * alpha_20;
    return ((F32_asinh((_S1853 / _S1852))) / (F32_asinh((3.14159274101257324f / _S1852))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_12, float3  t_25, float3  out_dir_4, uint np_0)
{
    float3  _S1854 = worldToTangent(out_dir_4, t_25);
    float3  _S1855 = worldToTangent(in_dir_12, t_25);
    return (F32_frac((((F32_atan2((_S1854.z), (_S1854.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1855.z), (1.17549435082228751e-38f - _S1855.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_13, float3  t_26, uint p_16, float row_0, float column_0, float w_3, float alpha_21, uint nt_1, uint np_1)
{
    float3  _S1856 = worldToTangent(in_dir_13, t_26);
    uint _S1857 = p_16 % 4U;
    float _S1858 = w_3 * HAIR_WIDTHS_0[_S1857];
    float _S1859 = (F32_asin((clamp_1(dot_0(in_dir_13, t_26), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1857] * alpha_21 + _S1858 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1858))))));
    float _S1860 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1856.z), (1.17549435082228751e-38f - _S1856.x)));
    float _S1861 = (F32_cos((_S1859)));
    float3  _S1862 = tangentToWorld(make_float3 (_S1861 * (F32_cos((_S1860))), (F32_sin((_S1859))), _S1861 * (F32_sin((_S1860)))), t_26);
    return _S1862;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_14, BSDFMaterial material_24, float coverage_1)
{
    float3  _S1863;
    if((material_24.ior) == 1.0f)
    {
        float3  _S1864 = straightThrough(material_24);
        _S1863 = _S1864;
    }
    else
    {
        _S1863 = make_float3 (0.0f);
    }
    return _S1863 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_8, Reservoir r_9, bool replay_2, float scale_4, Selection * sel_8)
{
    Domain _S1865 = dom_8;
    Reservoir _S1866 = r_9;
    Shift _S1867 = walk_0(&_S1865, &_S1866, replay_2, scale_4, sel_8);
    return _S1867;
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
