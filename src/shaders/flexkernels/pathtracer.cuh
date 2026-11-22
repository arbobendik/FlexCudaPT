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

static __device__ bool seedDomain_0(int2  p_10, uint seed_3, Domain * dom_4)
{
    bool _S172 = (fcptStoredDomainInitial((p_10), (seed_3), (dom_4)));
    return _S172;
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
    FKRay _S173;
    (&_S173)->origin = origin_0;
    (&_S173)->unit_direction = unit_direction_0;
    return _S173;
}

static __device__ float3  skyRadiance_0(float3  origin_1, FKSurface * surface_0, bool is_inside_1, float3  dir_1, ShadowContext * context_0, uint random_state_0)
{
    bool _S174 = wrongSide_0(is_inside_1, false, dir_1, surface_0->geometry_n);
    bool _S175 = is_inside_1 != _S174;
    float _S176 = surface_0->geometry_offset;
    float3  _S177 = surface_0->smooth_n;
    float3  _S178 = - surface_0->smooth_n;
    float3  _S179 = _slang_select(_S175, _S178,_S177);
    FKRay _S180 = Ray_x24init_0(origin_1 + make_float3 (_S176) * _S179, dir_1);
    bool _S181 = (dot_0(context_0->side, dir_1)) > 0.0f;
    bool _S182 = (fcptWorldReadsPath());
    float3  _S183;
    if(_S182)
    {
        _S183 = make_float3 (1.0f);
    }
    else
    {
        float3  _S184 = (fcptEnvMapSample((dir_1), (0U), (3U)));
        _S183 = _S184;
    }
    float3  _S185 = context_0->extinction_behind;
    float3  _S186 = context_0->extinction_front;
    float3  _S187 = _slang_select(_S181, _S186,_S185);
    uint _S188 = context_0->fillings.x;
    uint _S189 = context_0->fillings.y;
    uint _S190 = _slang_select(_S181, _S189,_S188);
    uint _S191 = context_0->depth;
    uint _S192 = context_0->lobe;
    bool _S193 = context_0->surface;
    bool _S194;
    if(_S193)
    {
        _S194 = !context_0->fiber;
    }
    else
    {
        _S194 = false;
    }
    float _S195 = context_0->length;
    float _S196 = context_0->width;
    FKHit _S197 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    float3  _S198 = (fcptShadowTransmittanceIn((_S180), (4.294967296e+09f), (_S187), (_S190), (random_state_0), (_S191), (_S192), (_S194), (_S195), (_S196), (_S197), (_S197)));
    return _S183 * _S198;
}

static __device__ uint searchCDF_0(uint2  start_4, uint2  step_0, uint count_1, float u_0)
{
    uint _S199 = count_1 - 1U;
    uint low_0 = 0U;
    uint high_0 = _S199;
    for(;;)
    {
        if(low_0 < high_0)
        {
        }
        else
        {
            break;
        }
        uint _S200 = (low_0 + high_0) / 2U;
        float4  _S201 = (fcptEnvironmentCdf((start_4 + step_0 * make_uint2 (_S200))));
        bool _S202 = (_S201.x) > u_0;
        if(_S202)
        {
            high_0 = _S200;
        }
        else
        {
            uint _S203 = _S200 + 1U;
            low_0 = _S203;
        }
    }
    return low_0;
}

static __device__ float3  skyFrame_0(float3  dir_2)
{
    float3  _S204 = make_float3 (- dir_2.x, dir_2.z, dir_2.y);
    bool _S205 = ((true));
    float3  _S206 = _slang_select(_S205, _S204,dir_2);
    return _S206;
}

__device__ float shadowLength(float3  shadow_0)
{
    return length_0(shadow_0) * 0.99989998340606689f;
}

static __device__ float3  lightTransmittance_0(float3  origin_2, float3  smooth_n_0, float geometry_offset_0, float3  light_dir_0, ShadowContext * context_1, uint random_state_1, FKHit * light_0)
{
    float3  _S207 = ((((light_dir_0)) * make_float3(rnorm3df(((light_dir_0)).x, ((light_dir_0)).y, ((light_dir_0)).z))));
    bool _S208 = (dot_0(smooth_n_0, _S207)) < 0.0f;
    if(_S208)
    {
        return make_float3 (0.0f);
    }
    float3  _S209 = make_float3 (geometry_offset_0) * smooth_n_0;
    float3  _S210 = origin_2 + _S209;
    FKRay _S211 = Ray_x24init_0(_S210, _S207);
    bool _S212 = (dot_0(context_1->side, light_dir_0 + _S209)) > 0.0f;
    float _S213 = shadowLength(light_dir_0);
    float3  _S214 = context_1->extinction_behind;
    float3  _S215 = context_1->extinction_front;
    float3  _S216 = _slang_select(_S212, _S215,_S214);
    uint _S217 = context_1->fillings.x;
    uint _S218 = context_1->fillings.y;
    uint _S219 = _slang_select(_S212, _S218,_S217);
    uint _S220 = context_1->depth;
    uint _S221 = context_1->lobe;
    bool _S222 = context_1->surface;
    bool _S223;
    if(_S222)
    {
        _S223 = !context_1->fiber;
    }
    else
    {
        _S223 = false;
    }
    float _S224 = context_1->length;
    float _S225 = context_1->width;
    FKHit _S226;
    if(context_1->fiber)
    {
        _S226 = context_1->own;
    }
    else
    {
        _S226 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    }
    float3  _S227 = (fcptShadowTransmittanceIn((_S211), (_S213), (_S216), (_S219), (random_state_1), (_S220), (_S221), (_S223), (_S224), (_S225), (_S226), (*light_0)));
    return _S227;
}

__device__ float sine(float c_0)
{
    return (F32_sqrt(((F32_max((1.0f - c_0 * c_0), (0.0f))))));
}

__device__ float cosSubClamped(float sin_a_0, float cos_a_0, float sin_b_0, float cos_b_0)
{
    float _S228 = cos_a_0 * cos_b_0 + sin_a_0 * sin_b_0;
    bool _S229 = cos_a_0 > cos_b_0;
    float _S230 = _slang_select(_S229, 1.0f,_S228);
    return _S230;
}

__device__ float importance(LightNode node_0, float3  p_11, float3  normal_0)
{
    float3  _S231 = (node_0.low + node_0.high) * make_float3 (0.5f);
    float3  _S232 = node_0.high - node_0.low;
    float3  _S233 = p_11 - _S231;
    float3  _S234 = ((((_S233)) * make_float3(rnorm3df(((_S233)).x, ((_S233)).y, ((_S233)).z))));
    float _S235 = dot_0(_S233, _S233);
    float _S236 = dot_0(_S232, _S232) / 4.0f;
    float _S237 = (F32_abs((dot_0(node_0.w, _S234))));
    float _S238 = sine(node_0.cos_theta_o);
    float _S239 = (F32_sqrt(((F32_max((1.0f - _S236 / _S235), (0.0f))))));
    bool _S240 = _S235 < _S236;
    float _S241 = _slang_select(_S240, -1.0f,_S239);
    float _S242 = sine(_S241);
    float _S243 = sine(_S237);
    float _S244 = cosSubClamped(_S243, _S237, _S238, node_0.cos_theta_o);
    float _S245 = sine(_S237);
    float _S246 = _S245 * node_0.cos_theta_o - _S237 * _S238;
    bool _S247 = _S237 > (node_0.cos_theta_o);
    float _S248 = _slang_select(_S247, 0.0f,_S246);
    float _S249 = cosSubClamped(_S248, _S244, _S242, _S241);
    bool _S250 = _S249 <= 0.0f;
    if(_S250)
    {
        return 0.0f;
    }
    float _S251 = - dot_0(_S234, normal_0);
    float _S252 = node_0.phi * _S249 / (F32_max((_S235), (length_0(_S232) / 2.0f)));
    float _S253 = sine(_S251);
    float _S254 = cosSubClamped(_S253, _S251, _S242, _S241);
    bool _S255 = (dot_0(normal_0, normal_0)) == 0.0f;
    float _S256 = _slang_select(_S255, 1.0f,_S254);
    return (F32_max((_S252 * _S256), (0.0f)));
}

__device__ __forceinline__ float childShare(LightNode first_0, LightNode second_0, float3  p_12, float3  normal_1, uint child_0)
{
    float _S257 = importance(first_0, p_12, normal_1);
    float _S258 = importance(second_0, p_12, normal_1);
    float2  _S259 = make_float2 (_S257, _S258);
    float _S260 = _slang_vector_get_element(_S259, child_0) / (_S257 + _S258);
    bool _S261 = _slang_vector_get_element(_S259, child_0) > 0.0f;
    float _S262 = _slang_select(_S261, _S260,0.0f);
    return _S262;
}

__device__ float sphereDensity(float3  center_0, float radius_0, float3  p_13)
{
    float3  _S263 = center_0 - p_13;
    float _S264 = radius_0 * radius_0 / dot_0(_S263, _S263);
    bool _S265 = _S264 >= 1.0f;
    if(_S265)
    {
        return 0.07957746833562851f;
    }
    return (1.0f + (F32_sqrt((1.0f - _S264)))) / (6.28318548202514648f * _S264);
}

static __device__ float3  cross_0(float3  left_0, float3  right_0)
{
    float _S266 = left_0.y;
    float _S267 = right_0.z;
    float _S268 = left_0.z;
    float _S269 = right_0.y;
    float _S270 = right_0.x;
    float _S271 = left_0.x;
    return make_float3 (_S266 * _S267 - _S268 * _S269, _S268 * _S270 - _S271 * _S267, _S271 * _S269 - _S266 * _S270);
}

__device__ float solidAngle(float probability_0, float3  normal_2, float3  toward_0)
{
    return 2.0f * probability_0 * (F32_pow((length_0(toward_0)), (3.0f))) / (F32_abs((dot_0(normal_2, toward_0))));
}

static __device__ float lightPdf_0(float3  origin_3, float3  smooth_n_1, float3  start_5, uint j_0, float3  light_point_0)
{
    bool _S272 = j_0 == 4294967295U;
    if(_S272)
    {
        return 0.0f;
    }
    uint4  _S273 = (fcptLightTrail((j_0)));
    uint2  _S274 = uint2 {_S273.x, _S273.y};
    uint n_0 = 0U;
    uint2  trail_0 = _S274;
    float probability_1 = 1.0f;
    for(;;)
    {
        uint4  _S275 = (fcptLightNode((n_0)));
        if((_S275.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S276 = (fcptLightSecond((n_0)));
        uint _S277 = n_0 + 1U;
        LightNode _S278 = (fcptLightBounds((_S277)));
        LightNode _S279 = (fcptLightBounds((_S276)));
        uint _S280 = trail_0.x;
        uint _S281 = _S280 & 1U;
        float _S282 = childShare(_S278, _S279, origin_3, smooth_n_1, _S281);
        float probability_2 = probability_1 * _S282;
        bool _S283 = _S281 == 1U;
        uint _S284 = _slang_select(_S283, _S276,_S277);
        uint _S285 = trail_0.y;
        uint2  _S286 = make_uint2 ((_S280 >> 1U) | (_S285 << 31U), _S285 >> 1U);
        n_0 = _S284;
        trail_0 = _S286;
        probability_1 = probability_2;
    }
    bool _S287 = (fcptSlotLeaf((n_0), (j_0)));
    bool _S288 = !_S287;
    bool _S289;
    if(_S288)
    {
        _S289 = true;
    }
    else
    {
        LightNode _S290 = (fcptLightBounds((n_0)));
        float _S291 = importance(_S290, origin_3, smooth_n_1);
        _S289 = !(_S291 > 0.0f);
    }
    if(_S289)
    {
        _S289 = true;
    }
    else
    {
        bool _S292 = (dot_0(smooth_n_1, smooth_n_1)) > 0.0f;
        if(_S292)
        {
            _S289 = !((dot_0(smooth_n_1, light_point_0 - origin_3)) > 0.0f);
        }
        else
        {
            _S289 = false;
        }
    }
    if(_S289)
    {
        return 0.0f;
    }
    uint4  _S293 = (fcptLightNode((n_0)));
    bool _S294 = (_S293.x) == 2U;
    if(_S294)
    {
        FKLight _S295 = (fcptLight((_S293.y)));
        float _S296 = sphereDensity(_S295.position, _S295.variance, start_5);
        return probability_1 * _S296;
    }
    uint _S297 = _S293.y;
    uint _S298 = (fcptTriangleOffset((_S297)));
    Matrix<float, 3, 3>  _S299 = (fcptWorldTriangle((_S297), (_S298 + _S293.z)));
    float _S300 = solidAngle(probability_1, cross_0(_S299.rows[int(1)] - _S299.rows[int(0)], _S299.rows[int(2)] - _S299.rows[int(0)]), light_point_0 - start_5);
    return _S300;
}

static __device__ float3  environment_0(float3  dir_3, uint depth_0, uint lobe_0)
{
    uint2  _S301 = (fcptEnvironmentMapSize());
    bool _S302 = all_0(_S301 > make_uint2 (1U));
    if(_S302)
    {
        float3  _S303 = (fcptEnvMapSample((dir_3), (depth_0), (lobe_0)));
        return _S303;
    }
    float3  _S304 = (fcptAmbient());
    return _S304;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S305 = (fcptEnvironmentCdfSize());
    bool _S306 = !all_0(_S305 > make_uint2 (1U));
    if(_S306)
    {
        return false;
    }
    uint2  _S307 = (fcptEnvironmentMapSize());
    return all_0(_S307 > make_uint2 (1U));
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
    uint2  _S308 = (fcptEnvironmentCdfSize());
    uint2  _S309 = _S308 - make_uint2 (1U, 0U);
    float3  _S310 = skyFrame_0(dir_4);
    float2  _S311 = make_float2 ((F32_atan2((- _S310.z), (- _S310.x))) / 6.28318548202514648f + 0.5f, (F32_acos((clamp_1(_S310.y, -1.0f, 1.0f)))) / 3.14159274101257324f);
    float2  _S312 = make_float2 ((float)_S309.x, (float)_S309.y);
    float2  _S313 = _S311 * _S312;
    uint2  _S314 = make_uint2 ((uint)_S313.x, (uint)_S313.y);
    uint2  _S315 = min_0(_S314, _S309 - make_uint2 (1U));
    float4  _S316 = (fcptEnvironmentCdf((_S315)));
    float _S317 = _S316.y;
    uint _S318 = _S309.x;
    float4  _S319 = (fcptEnvironmentCdf((make_uint2 (_S318, _S315.y))));
    float _S320 = _S317 * _S319.y;
    return _S320 * float(_S318 * _S309.y) / (19.73921012878417969f * length_1(float2 {_S310.x, _S310.z}));
}

static __device__ float escapeWeight_0(float pdf_0, float3  dir_5)
{
    bool _S321 = pdf_0 <= 0.0f;
    bool _S322;
    if(_S321)
    {
        _S322 = true;
    }
    else
    {
        bool _S323 = environmentMapped_0();
        _S322 = !_S323;
    }
    if(_S322)
    {
        return 1.0f;
    }
    float _S324 = environmentPdf_0(dir_5);
    return pdf_0 / (pdf_0 + _S324);
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
    uint2  _S325 = make_uint2 (k_0 * 3242174889U, k_0 * 2447445414U) >> make_uint2 (16U);
    uint _S326 = (fkBlueNoiseSize());
    return (_S325 * make_uint2 (_S326)) >> make_uint2 (16U);
}

__device__ uint stream(uint seed_4, uint index_0)
{
    uint _S327 = hash(index_0);
    uint _S328 = hash(seed_4 ^ _S327);
    return _S328;
}

static __device__ Random Random_x24init_0(uint state_0, float value_0)
{
    Random _S329;
    (&_S329)->state = state_0;
    (&_S329)->value = value_0;
    return _S329;
}

__device__ Random pcg(uint state_1)
{
    uint _S330 = hash(state_1);
    float value_1 = float(_S330 >> int(8)) * 5.9604644775390625e-08f;
    return Random_x24init_0(_S330, value_1);
}

__device__ __noinline__ Random draw(uint address_0, uint variable_0)
{
    uint _S331 = address_0 >> 22U;
    uint _S332 = _S331 / 32U;
    uint2  _S333 = make_uint2 (address_0 & 2047U, (address_0 >> 11U) & 2047U);
    uint _S334 = variable_0 & 2147483647U;
    uint2  _S335 = noiseOffset(_S334);
    uint2  _S336 = _S333 + _S335;
    uint2  _S337 = noiseOffset(4096U + _S332);
    uint2  _S338 = _S336 + _S337;
    uint _S339 = (fkBlueNoiseSize());
    uint2  _S340 = _S338 & make_uint2 (_S339 - 1U);
    uint _S341 = (fkBlueNoise((_S340.x), (_S340.y), ((_S331 + ((_S332 * 2654435769U) >> 27U)) % 32U)));
    bool _S342 = (variable_0 & 2147483648U) != 0U;
    uint _S343 = stream(address_0, _S334);
    Random _S344 = pcg(_S343);
    uint _S345 = _S341 & 65535U;
    uint _S346 = _S341 >> 16U;
    uint _S347 = _slang_select(_S342, _S346,_S345);
    float _S348 = (float(_S347) + 0.5f) / 6.5536e+04f;
    Random _S349 = pcg(_S344.state);
    float _S350 = _slang_select(_S342, _S349.value,_S344.value);
    bool _S351 = _S341 == 4294967295U;
    float _S352 = _slang_select(_S351, _S350,_S348);
    return Random_x24init_0(address_0, _S352);
}

__device__ static const FixedArray<float, 243>  SPECTRAL_PRIMARIES_0 = { {
    0.028201999142766f, 9.99999997475242708e-07f, 0.97179698944091797f, 0.02820000052452087f, 0.0f, 0.97180002927780151f, 0.02819300070405006f, 0.0f, 0.97180700302124023f, 0.0281750001013279f, 0.0f, 0.9718250036239624f, 0.02813299931585789f, 0.0f, 0.97186702489852905f, 0.02804199978709221f, 0.0f, 0.9719579815864563f, 0.02786399982869625f, 0.0f, 0.97213602066040039f, 0.0275299996137619f, 0.0f, 0.9724699854850769f, 0.02692800015211105f, 0.0f, 0.97307199239730835f, 0.02592499926686287f, 0.0f, 0.97407501935958862f, 0.02444599941372871f, 0.0f, 0.97555398941040039f, 0.02258899994194508f, 0.0f, 0.97741097211837769f, 0.02068600058555603f, 0.0f, 0.97931402921676636f, 0.01939599961042404f, 0.0f, 0.98060399293899536f, 0.01972600072622299f, 0.0f, 0.9802740216255188f, 0.02305700071156025f, 0.0f, 0.97694301605224609f, 0.0282990001142025f, 0.00548999989405274f, 0.96621102094650269f, 0.02276800014078617f, 0.04560500010848045f, 0.93162697553634644f, 0.0118180001154542f, 0.11352799832820892f, 0.87465399503707886f, 0.00192399998195469f, 0.20037899911403656f, 0.79769700765609741f, 0.0f, 0.29692500829696655f, 0.70307499170303345f, 0.0f, 0.40064999461174011f, 0.5993499755859375f, 0.0f, 0.50742298364639282f, 0.49257698655128479f, 0.0f, 0.61289197206497192f, 0.38710799813270569f, 0.0f, 0.71311402320861816f, 0.28688600659370422f, 0.0f, 0.8042140007019043f, 0.1957859992980957f, 0.0f, 0.88220900297164917f, 0.11779099702835083f, 0.0f, 0.94313102960586548f, 0.05686900019645691f, 0.0f, 0.98336499929428101f, 0.01663500070571899f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.99855601787567139f, 0.00144400005228817f, 0.0f, 0.97892600297927856f, 0.02107400074601173f, 0.03028500080108643f, 0.92923498153686523f, 0.04047999903559685f, 0.10447199642658234f, 0.84615302085876465f, 0.04937500134110451f, 0.21104000508785248f, 0.73897498846054077f, 0.04998499900102615f, 0.33820000290870667f, 0.61719298362731934f, 0.04460699856281281f, 0.47420701384544373f, 0.49019300937652588f, 0.03559999912977219f, 0.60847699642181396f, 0.3664110004901886f, 0.02511199936270714f, 0.73185497522354126f, 0.25317299365997314f, 0.01497200038284063f, 0.83687901496887207f, 0.15642799437046051f, 0.00669299997389317f, 0.91802400350570679f, 0.08053100109100342f, 0.00144499994348735f, 0.97194302082061768f, 0.02805699966847897f, 0.0f, 0.99879997968673706f, 0.00120000005699694f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.99999898672103882f, 0.0f, 9.99999997475242708e-07f, 0.99999898672103882f, 0.0f, 9.99999997475242708e-07f, 0.99999898672103882f, 0.0f, 9.99999997475242708e-07f, 0.99999797344207764f, 9.99999997475242708e-07f, 9.99999997475242708e-07f, 0.99999797344207764f, 9.99999997475242708e-07f, 9.99999997475242708e-07f, 0.99999701976776123f, 9.99999997475242708e-07f, 1.99999999495048542e-06f, 0.99999499320983887f, 1.99999999495048542e-06f, 3.00000010611256585e-06f, 0.99999302625656128f, 1.99999999495048542e-06f, 4.99999987368937582e-06f, 0.99998897314071655f, 3.99999998990097083e-06f, 7.00000009601353668e-06f, 0.9999840259552002f, 6.00000021222513169e-06f, 0.00000999999974738f, 0.99997901916503906f, 0.0000079999999798f, 0.00001299999985349f, 0.99997401237487793f, 0.00000999999974738f, 0.0000159999999596f, 0.99997299909591675f, 0.00001200000042445f, 0.00001499999962107f, 0.99996697902679443f, 0.00001499999962107f, 0.00001800000063668f, 0.9999690055847168f, 0.00001499999962107f, 0.0000159999999596f, 0.9999619722366333f, 0.00001700000029814f, 0.00002099999983329f
} };
__device__ float upsample(float3  rgb_0, float wavelength_0)
{
    float _S353 = clamp_1((wavelength_0 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    uint _S354 = (U32_min((uint(_S353)), (79U)));
    uint _S355 = 3U * _S354;
    float3  _S356 = make_float3 (SPECTRAL_PRIMARIES_0[_S355], SPECTRAL_PRIMARIES_0[_S355 + 1U], SPECTRAL_PRIMARIES_0[_S355 + 2U]);
    float3  _S357 = make_float3 (SPECTRAL_PRIMARIES_0[_S355 + 3U], SPECTRAL_PRIMARIES_0[_S355 + 4U], SPECTRAL_PRIMARIES_0[_S355 + 5U]);
    return dot_0(rgb_0, _S356 + (_S357 - _S356) * make_float3 (_S353 - float(_S354)));
}

__device__ BSDFMaterial atWavelength(BSDFMaterial material_0, float wavelength_1)
{
    BSDFMaterial at_0 = material_0;
    float _S358 = upsample(material_0.albedo, wavelength_1);
    float3  _S359 = make_float3 (_S358);
    (&at_0)->albedo = _S359;
    float _S360 = upsample(material_0.emissive, wavelength_1);
    float3  _S361 = make_float3 (_S360);
    (&at_0)->emissive = _S361;
    float _S362 = upsample(material_0.absorption, wavelength_1);
    float3  _S363 = make_float3 (_S362);
    (&at_0)->absorption = _S363;
    float _S364 = upsample(material_0.specular_tint, wavelength_1);
    float3  _S365 = make_float3 (_S364);
    (&at_0)->specular_tint = _S365;
    float _S366 = upsample(material_0.translucent, wavelength_1);
    float3  _S367 = make_float3 (_S366);
    (&at_0)->translucent = _S367;
    float _S368 = upsample(material_0.sheen, wavelength_1);
    float3  _S369 = make_float3 (_S368);
    (&at_0)->sheen = _S369;
    return at_0;
}

__device__ BSDFMaterial pathMaterial(BSDFMaterial material_1, float wavelength_2)
{
    BSDFMaterial _S370;
    if(wavelength_2 > 0.0f)
    {
        BSDFMaterial _S371 = atWavelength(material_1, wavelength_2);
        _S370 = _S371;
    }
    else
    {
        _S370 = material_1;
    }
    return _S370;
}

static __device__ float3  negate_0(float3  x_13)
{
    return - x_13;
}

static __device__ float sign_0(float e_1)
{
    bool _S372 = e_1 < 0.0f;
    float _S373 = _slang_select(_S372, -1.0f,0.0f);
    bool _S374 = e_1 > 0.0f;
    float _S375 = _slang_select(_S374, 1.0f,_S373);
    return _S375;
}

struct AnisotropicFrame
{
    float3  tangent;
    float2  alphas;
};

static __device__ AnisotropicFrame AnisotropicFrame_x24init_0(float3  tangent_0, float2  alphas_0)
{
    AnisotropicFrame _S376;
    (&_S376)->tangent = tangent_0;
    (&_S376)->alphas = alphas_0;
    return _S376;
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_1)
{
    float3  a_1 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S377 = (F32_abs((dot_0(n_1, a_1)))) > 0.9999847412109375f;
    float3  a_2;
    if(_S377)
    {
        float3  _S378 = make_float3 (1.0f, 0.0f, 0.0f);
        a_2 = _S378;
    }
    else
    {
        a_2 = a_1;
    }
    float3  _S379 = cross_0(n_1, a_2);
    float3  _S380 = ((((_S379)) * make_float3(rnorm3df(((_S379)).x, ((_S379)).y, ((_S379)).z))));
    float3  _S381 = cross_0(n_1, _S380);
    return make_float3 (v_0.x) * _S380 + make_float3 (v_0.y) * n_1 + make_float3 (v_0.z) * _S381;
}

__device__ AnisotropicFrame anisotropicFrame(BSDFMaterial material_2, float3  n_i_0)
{
    float _S382 = material_2.roughness;
    float _S383 = _S382 * _S382;
    bool _S384 = (material_2.anisotropy) == 0.0f;
    bool _S385;
    if(_S384)
    {
        _S385 = true;
    }
    else
    {
        _S385 = !(_S383 > 0.0f);
    }
    if(_S385)
    {
        return AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f));
    }
    float3  _S386 = material_2.tangent - n_i_0 * make_float3 (dot_0(n_i_0, material_2.tangent));
    float3  _S387 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_i_0);
    bool _S388 = (dot_0(_S386, _S386)) > 0.0f;
    float3  _S389 = _slang_select(_S388, _S386,_S387);
    float3  _S390 = ((((_S389)) * make_float3(rnorm3df(((_S389)).x, ((_S389)).y, ((_S389)).z))));
    float _S391 = 6.28318548202514648f * material_2.anisotropic_rotation;
    float _S392 = (F32_sqrt((1.0f - 0.89999997615814209f * (F32_abs((material_2.anisotropy))))));
    float _S393 = 1.0f / _S392;
    bool _S394 = (material_2.anisotropy) < 0.0f;
    float _S395 = _slang_select(_S394, _S393,_S392);
    return AnisotropicFrame_x24init_0(_S390 * make_float3 ((F32_cos((_S391)))) + cross_0(n_i_0, _S390) * make_float3 ((F32_sin((_S391)))), make_float2 (_S383 / _S395, _S383 * _S395));
}

struct SheenProfile
{
    bool on;
    float albedo;
};

static __device__ SheenProfile SheenProfile_x24init_0(bool on_0, float albedo_0)
{
    SheenProfile _S396;
    (&_S396)->on = on_0;
    (&_S396)->albedo = albedo_0;
    return _S396;
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
    SheenProfile _S397 = SheenProfile_x24init_0(false, 0.0f);
    float _S398 = rgb_to_greyscale(material_3.sheen);
    bool _S399 = _S398 > 0.0f;
    SheenProfile profile_0;
    if(_S399)
    {
        float _S400 = clamp_1((F32_sqrt(((F32_max((dot_0(n_i_1, v_1)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S401 = (U32_min((uint(_S400)), (22U)));
        float _S402 = (F32_sqrt((0.05000000074505806f)));
        float _S403 = (F32_sqrt((0.00999999977648258f)));
        bool _S404 = (material_3.velvet) > 0.0f;
        float _S405 = _slang_select(_S404, _S403,_S402);
        float _S406 = (clamp_1((F32_sqrt(((F32_max((material_3.sheen_roughness), (0.0f)))))), _S405, 1.0f) - _S405) / (1.0f - _S405) * 23.0f;
        uint _S407 = (U32_min((uint(_S406)), (22U)));
        uint _S408 = _S401 * 24U + _S407;
        float _S409 = _S400 - float(_S401);
        float _S410 = _S406 - float(_S407);
        if(_S404)
        {
            uint _S411 = _S408 + 24U;
            float _S412 = VELVET_ALBEDO_0[_S408] + (VELVET_ALBEDO_0[_S411] - VELVET_ALBEDO_0[_S408]) * _S409;
            uint _S413 = _S408 + 1U;
            float _S414 = VELVET_ALBEDO_0[_S413] + (VELVET_ALBEDO_0[_S411 + 1U] - VELVET_ALBEDO_0[_S413]) * _S409;
            SheenProfile _S415 = SheenProfile_x24init_0(true, _S412 + (_S414 - _S412) * _S410);
            profile_0 = _S415;
        }
        else
        {
            uint _S416 = _S408 + 24U;
            float _S417 = SHEEN_ALBEDO_0[_S408] + (SHEEN_ALBEDO_0[_S416] - SHEEN_ALBEDO_0[_S408]) * _S409;
            uint _S418 = _S408 + 1U;
            float _S419 = SHEEN_ALBEDO_0[_S418] + (SHEEN_ALBEDO_0[_S416 + 1U] - SHEEN_ALBEDO_0[_S418]) * _S409;
            SheenProfile _S420 = SheenProfile_x24init_0(true, (F32_exp((_S417 + (_S419 - _S417) * _S410))));
            profile_0 = _S420;
        }
    }
    else
    {
        profile_0 = _S397;
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
    Weights _S421;
    (&_S421)->v_dot_h = v_dot_h_0;
    (&_S421)->refracted = refracted_1;
    (&_S421)->F = F_0;
    (&_S421)->reflect_weight = reflect_weight_0;
    (&_S421)->diffuse_weight = diffuse_weight_0;
    (&_S421)->refract_weight = refract_weight_0;
    (&_S421)->p_diffuse = p_diffuse_0;
    (&_S421)->p_reflect = p_reflect_0;
    (&_S421)->p_refract = p_refract_0;
    (&_S421)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S421)->p_toon = p_toon_0;
    (&_S421)->sheen = sheen_0;
    (&_S421)->toon = toon_0;
    return _S421;
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
    float3  _S422 = make_float3 (alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z);
    float3  _S423 = ((((_S422)) * make_float3(rnorm3df(((_S422)).x, ((_S422)).y, ((_S422)).z))));
    float _S424 = _S423.x;
    float _S425 = _S423.y;
    float _S426 = _S424 * _S424 + _S425 * _S425;
    float3  _S427 = make_float3 (1.0f, 0.0f, 0.0f);
    float3  _S428 = make_float3 (- _S425, _S424, 0.0f);
    float _S429 = (rsqrtf((_S426)));
    float3  _S430 = _S428 * make_float3 (_S429);
    bool _S431 = _S426 > 0.0f;
    float3  _S432 = _slang_select(_S431, _S430,_S427);
    float3  _S433 = cross_0(_S423, _S432);
    float _S434 = (F32_sqrt((U1_0)));
    float _S435 = 6.28318548202514648f * U2_0;
    float _S436 = _S434 * (F32_cos((_S435)));
    float t2_0 = _S434 * (F32_sin((_S435)));
    float _S437 = 0.5f * (1.0f + _S423.z);
    float t2_1 = (1.0f - _S437) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S436 * _S436)))))) + _S437 * t2_0;
    float3  _S438 = make_float3 (_S436) * _S432 + make_float3 (t2_1) * _S433;
    float _S439 = unshared_0(_S436);
    float _S440 = unshared_0(_S436);
    float3  _S441 = _S438 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S439 * _S440 - t2_1 * t2_1))))))) * _S423;
    float3  _S442 = make_float3 (alpha_0 * _S441.x, alpha_0 * _S441.y, (F32_max((0.0f), (_S441.z))));
    float3  _S443 = ((((_S442)) * make_float3(rnorm3df(((_S442)).x, ((_S442)).y, ((_S442)).z))));
    return _S443;
}

__device__ float3  worldToTangent(float3  v_2, float3  n_3)
{
    float3  a_3 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S444 = (F32_abs((dot_0(n_3, a_3)))) > 0.9999847412109375f;
    float3  a_4;
    if(_S444)
    {
        float3  _S445 = make_float3 (1.0f, 0.0f, 0.0f);
        a_4 = _S445;
    }
    else
    {
        a_4 = a_3;
    }
    float3  _S446 = cross_0(n_3, a_4);
    float3  _S447 = ((((_S446)) * make_float3(rnorm3df(((_S446)).x, ((_S446)).y, ((_S446)).z))));
    float3  _S448 = cross_0(n_3, _S447);
    return make_float3 (dot_0(v_2, _S447), dot_0(v_2, n_3), dot_0(v_2, _S448));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_3, float3  n_i_2, float alpha_1, AnisotropicFrame frame_0, uint * random_state_2)
{
    Random _S449 = draw(*random_state_2, 0U);
    Random _S450 = draw(*random_state_2, 2147483648U);
    *random_state_2 = _S450.state;
    float _S451 = frame_0.alphas.x;
    bool _S452 = _S451 > 0.0f;
    if(_S452)
    {
        float3  _S453 = anisotropicLocal(v_3, frame_0.tangent, n_i_2);
        float _S454 = frame_0.alphas.y;
        float3  _S455 = make_float3 (_S451 * _S453.x, _S454 * _S453.y, _S453.z);
        float3  _S456 = ((((_S455)) * make_float3(rnorm3df(((_S455)).x, ((_S455)).y, ((_S455)).z))));
        float3  _S457 = sampleGGXVNDF(_S456, 1.0f, _S449.value, _S450.value);
        float3  _S458 = make_float3 (_S451 * _S457.x, _S454 * _S457.y, _S457.z);
        float3  _S459 = ((((_S458)) * make_float3(rnorm3df(((_S458)).x, ((_S458)).y, ((_S458)).z))));
        return make_float3 (_S459.x) * frame_0.tangent + make_float3 (_S459.y) * cross_0(n_i_2, frame_0.tangent) + make_float3 (_S459.z) * n_i_2;
    }
    float3  _S460 = worldToTangent(v_3, n_i_2);
    float3  _S461 = sampleGGXVNDF(float3 {_S460.x, _S460.z, _S460.y}, alpha_1, _S449.value, _S450.value);
    float3  _S462 = float3 {_S461.x, _S461.z, _S461.y};
    float3  _S463 = tangentToWorld(_S462, n_i_2);
    return _S463;
}

__device__ __forceinline__ float3  sampledHalf(float3  v_4, float3  n_i_3, float alpha_2, AnisotropicFrame frame_1, uint random_state_3)
{
    uint state_2 = random_state_3;
    float3  _S464 = sampleHalfVector(v_4, n_i_3, alpha_2, frame_1, &state_2);
    return _S464;
}

__device__ __forceinline__ float3  refractedHalf(float3  in_dir_0, float3  out_dir_0, float3  n_4, float eta_i_0, float eta_o_0)
{
    float3  _S465 = negate_0(in_dir_0);
    float3  _S466 = negate_0(make_float3 (eta_i_0) * _S465 + make_float3 (eta_o_0) * out_dir_0);
    float3  _S467 = ((((_S466)) * make_float3(rnorm3df(((_S466)).x, ((_S466)).y, ((_S466)).z))));
    float _S468 = sign_0(dot_0(n_4, _S465));
    float _S469 = sign_0(dot_0(_S466, n_4 * make_float3 (_S468)));
    return _S467 * make_float3 (_S469);
}

__device__ __forceinline__ float3  reflectedHalf(float3  in_dir_1, float3  out_dir_1)
{
    float3  _S470 = negate_0(in_dir_1);
    float3  _S471 = _S470 + out_dir_1;
    float3  _S472 = ((((_S471)) * make_float3(rnorm3df(((_S471)).x, ((_S471)).y, ((_S471)).z))));
    return _S472;
}

static __device__ float3  refract_0(float3  i_5, float3  n_5, float eta_0)
{
    float _S473 = dot_0(n_5, i_5);
    float _S474 = 1.0f - eta_0 * eta_0 * (1.0f - _S473 * _S473);
    if(_S474 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_5 - make_float3 (eta_0 * _S473 + (F32_sqrt((_S474)))) * n_5;
}

__device__ float fresnel(float cos_theta_0, float eta_i_1, float eta_o_1)
{
    float _S475 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S476 = eta_i_1 / eta_o_1 * _S475;
    bool _S477 = _S476 < 1.0f;
    float kr_0;
    if(_S477)
    {
        float _S478 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S476 * _S476))))));
        bool _S479 = eta_i_1 == eta_o_1;
        float _S480 = _slang_select(_S479, cos_theta_0,_S478);
        float _S481 = eta_o_1 * cos_theta_0;
        float _S482 = eta_i_1 * _S480;
        float _S483 = (_S481 - _S482) / (_S481 + _S482);
        float _S484 = eta_i_1 * cos_theta_0;
        float _S485 = eta_o_1 * _S480;
        float _S486 = (_S484 - _S485) / (_S484 + _S485);
        float _S487 = (_S483 * _S483 + _S486 * _S486) / 2.0f;
        kr_0 = _S487;
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
    float _S488 = dot_0(ggx_n_0, v_5);
    float _S489 = eta_i_2 / eta_o_2;
    float3  _S490 = refract_0(in_dir_2, ggx_n_0, _S489);
    float3  _S491 = ((((_S490)) * make_float3(rnorm3df(((_S490)).x, ((_S490)).y, ((_S490)).z))));
    float _S492 = (F32_min(((F32_sqrt((material_4.specular_level))) * (F32_abs((eta_i_2 - eta_o_2))) / (eta_i_2 + eta_o_2)), (0.9999847412109375f)));
    float _S493 = _S492 * _S492;
    float _S494 = (1.0f + _S492) / (1.0f - _S492);
    float _S495 = (F32_abs((_S488)));
    bool _S496 = eta_i_2 > eta_o_2;
    float _S497 = _slang_select(_S496, _S494,1.0f);
    float _S498 = _slang_select(_S496, 1.0f,_S494);
    float _S499 = fresnel(_S495, _S497, _S498);
    bool _S500 = (eta_i_2 * eta_i_2 * (1.0f - _S488 * _S488)) >= (eta_o_2 * eta_o_2);
    float3  _S501 = material_4.specular_tint * make_float3 (_S493);
    float3  _S502 = _S501 + (make_float3 (1.0f) - _S501) * make_float3 (_S499 - _S493) / make_float3 (1.0f - _S493);
    float3  _S503 = make_float3 (1.0f);
    float3  _S504 = _slang_select(_S500, _S503,_S502);
    float3  _S505 = make_float3 (0.0f);
    float sheen_component_0;
    float3  sheen_1;
    float3  scale_1;
    if(sheen_profile_0.on)
    {
        float _S506 = (F32_min((sheen_profile_0.albedo), (1.0f)));
        float3  _S507 = make_float3 (1.0f) - material_4.sheen * make_float3 (_S506);
        float _S508 = rgb_to_greyscale(material_4.sheen);
        float _S509 = _S508 * _S506;
        float3  _S510 = material_4.sheen / make_float3 ((F32_max((sheen_profile_0.albedo), (1.0f))));
        sheen_component_0 = _S509;
        sheen_1 = _S510;
        scale_1 = _S507;
    }
    else
    {
        sheen_component_0 = 0.0f;
        sheen_1 = _S505;
        scale_1 = _S503;
    }
    float _S511 = (F32_abs((material_4.toon.x)));
    bool _S512 = _S511 > 0.0f;
    float toon_component_0;
    float3  toon_1;
    if(_S512)
    {
        float _S513 = (F32_min((_S511), (1.0f)));
        float3  scale_2 = scale_1 * make_float3 (1.0f - _S513);
        float _S514 = rgb_to_greyscale(material_4.albedo);
        float _S515 = _S513 * _S514;
        float3  _S516 = make_float3 (_S513) * material_4.albedo;
        toon_component_0 = _S515;
        toon_1 = _S516;
        scale_1 = scale_2;
    }
    else
    {
        toon_component_0 = 0.0f;
        toon_1 = _S505;
    }
    bool _S517 = (material_4.metallic) > 0.0f;
    float3  rebounce_0;
    if(_S517)
    {
        float _S518 = frame_2.alphas.x;
        float _S519 = (F32_sqrt(((F32_min((_S518), (frame_2.alphas.y))))));
        bool _S520 = _S518 > 0.0f;
        float _S521 = _slang_select(_S520, _S519,material_4.roughness);
        float _S522 = _S521 * _S521;
        float _S523 = (F32_pow((_S522), (1.81585001945495605f))) * (2.15371990203857422f - 0.73285001516342163f * _S522) / (1.0f + 1.28094995021820068f * _S522);
        bool _S524 = _S522 > 0.0f;
        float _S525 = _slang_select(_S524, _S523,0.0f);
        float _S526 = clamp_1(dot_0(n_i_4, v_5), 0.0f, 1.0f);
        float _S527 = _S522 * _S521;
        float _S528 = (F32_min((1.00064504146575928f - _S521 * (0.00375499995425344f + _S526 * (-0.04133399948477745f + _S526 * (-0.90938502550125122f + _S526 * 0.35275399684906006f))) - _S522 * (0.27602800726890564f + _S526 * (1.27023398876190186f + _S526 * 0.04740000143647194f)) - _S527 * (0.31452900171279907f - _S526 * 0.34830701351165771f) + _S527 * _S521 * 0.27229699492454529f), (1.0f)));
        float3  _S529 = min_1(make_float3 (1.0f) / (make_float3 (1.0f) - material_4.albedo * make_float3 (_S525)), make_float3 (1.0f / (F32_max((_S528), (0.0000152587890625f)))));
        rebounce_0 = _S529;
    }
    else
    {
        rebounce_0 = _S503;
    }
    float3  _S530 = mix_0(_S504, material_4.albedo * rebounce_0, material_4.metallic);
    float3  F_1 = _S530 * scale_1;
    float _S531 = rgb_to_greyscale(F_1);
    float _S532 = 1.0f - material_4.metallic;
    float3  _S533 = make_float3 (1.0f) - _S504;
    float3  _S534 = make_float3 ((1.0f - material_4.transmission) * _S532) * _S533 * scale_1;
    float3  _S535 = make_float3 (material_4.transmission * _S532) * _S533 * scale_1;
    float _S536 = (F32_max((_S531), (0.0f)));
    float _S537 = rgb_to_greyscale(_S534);
    float _S538 = (F32_max((_S537), (0.0f)));
    float _S539 = rgb_to_greyscale(_S535);
    float _S540 = sign_0(length_0(_S491));
    float _S541 = (F32_max((_S539 * _S540), (0.0f)));
    float _S542 = _S536 + _S538 + _S541 + toon_component_0;
    float _S543 = (F32_min((sheen_component_0), (1.0f)));
    bool _S544 = sheen_component_0 > 0.0f;
    bool _S545;
    if(_S544)
    {
        _S545 = !(_S542 > 0.0f);
    }
    else
    {
        _S545 = false;
    }
    float _S546 = _slang_select(_S545, 1.0f,_S543);
    float _S547 = (1.0f - _S546) / (F32_max((_S542), (0.0000152587890625f)));
    float _S548 = _S538 * _S547;
    float _S549 = _S536 * _S547;
    float _S550 = _S541 * _S547;
    return Weights_x24init_0(_S488, _S491, F_1, 1.0f, _S534, _S535, _S548, _S549, _S550, _S546, toon_component_0 * _S547, sheen_1, toon_1);
}

__device__ float translucentShare(BSDFMaterial material_5)
{
    float _S551 = rgb_to_greyscale(material_5.translucent);
    float _S552 = rgb_to_greyscale(material_5.albedo);
    float _S553 = _S551 / (_S552 + _S551);
    bool _S554 = _S551 > 0.0f;
    float _S555 = _slang_select(_S554, _S553,0.0f);
    return _S555;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float n_i_dot_v_0, BSDFMaterial material_6, Weights w_1)
{
    float _S556 = translucentShare(material_6);
    float _S557 = w_1.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S558 = w_1.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S559 = 1.0f - _S556;
    bool _S560 = n_i_dot_l_0 < 0.0f;
    float _S561 = _slang_select(_S560, _S556,_S559);
    float _S562 = _S558 * _S561;
    bool _S563 = _S556 > 0.0f;
    float _S564 = _slang_select(_S563, _S562,_S557);
    bool _S565 = n_i_dot_v_0 > 0.0f;
    float _S566 = _slang_select(_S565, _S564,0.0f);
    return _S566;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_5, BSDFMaterial material_7, Weights w_2)
{
    float _S567 = translucentShare(material_7);
    bool _S568 = (dot_0(n_i_5, l_0)) < 0.0f;
    float3  _S569 = _slang_select(_S568, material_7.translucent,material_7.albedo);
    float _S570 = 1.0f - _S567;
    float _S571 = _slang_select(_S568, _S567,_S570);
    float3  _S572 = _S569 / make_float3 (_S571);
    bool _S573 = _S567 > 0.0f;
    float3  _S574 = _slang_select(_S573, _S572,material_7.albedo);
    return w_2.diffuse_weight * _S574 / make_float3 (w_2.p_diffuse);
}

__device__ float smithG1(float alpha_3, float n_dot_x_0)
{
    float _S575 = alpha_3 * alpha_3;
    float _S576 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S575 + (1.0f - _S575) * n_dot_x_0 * n_dot_x_0))));
    bool _S577 = alpha_3 > 0.0f;
    float _S578 = _slang_select(_S577, _S576,1.0f);
    return _S578;
}

__device__ float trowbridgeReitz(float alpha_4, float n_dot_h_0)
{
    float _S579 = alpha_4 * alpha_4;
    float _S580 = (1.0f - n_dot_h_0) * (1.0f + n_dot_h_0) + _S579 * n_dot_h_0 * n_dot_h_0;
    return _S579 / (F32_max((3.14159274101257324f * _S580 * _S580), (1.17549435082228751e-38f)));
}

__device__ float anisotropicG1(float3  w_3, float2  alphas_1)
{
    float _S581 = (F32_max((w_3.z), (0.0f)));
    return 2.0f * _S581 / (_S581 + length_0(make_float3 (alphas_1.x * w_3.x, alphas_1.y * w_3.y, _S581)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_2)
{
    float _S582 = alphas_2.x;
    float _S583 = h_0.x / _S582;
    float _S584 = alphas_2.y;
    float _S585 = h_0.y / _S584;
    float _S586 = h_0.z;
    float _S587 = _S583 * _S583 + _S585 * _S585 + _S586 * _S586;
    return 1.0f / (F32_max((3.14159274101257324f * _S582 * _S584 * _S587 * _S587), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float3  v_6, float3  h_1, float3  n_i_6, float n_i_dot_v_1, float alpha_5, AnisotropicFrame frame_3, float v_dot_h_1)
{
    float _S588 = dot_0(n_i_6, h_1);
    float _S589 = smithG1(alpha_5, n_i_dot_v_1);
    float _S590 = _S589 * v_dot_h_1;
    float _S591 = trowbridgeReitz(alpha_5, _S588);
    float _S592 = _S590 * _S591 / n_i_dot_v_1;
    bool _S593 = alpha_5 > 0.0f;
    bool _S594;
    if(_S593)
    {
        _S594 = v_dot_h_1 > 0.0f;
    }
    else
    {
        _S594 = false;
    }
    if(_S594)
    {
        _S594 = _S588 > 0.0f;
    }
    else
    {
        _S594 = false;
    }
    if(_S594)
    {
        _S594 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S594 = false;
    }
    float _S595 = _slang_select(_S594, _S592,0.0f);
    bool _S596 = (frame_3.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S596)
    {
        float3  _S597 = anisotropicLocal(v_6, frame_3.tangent, n_i_6);
        float _S598 = anisotropicG1(_S597, frame_3.alphas);
        float3  _S599 = anisotropicLocal(h_1, frame_3.tangent, n_i_6);
        float _S600 = anisotropicD(_S599, frame_3.alphas);
        float _S601 = _S598 * _S600;
        float _S602 = _S601 * v_dot_h_1 / n_i_dot_v_1;
        bool _S603 = v_dot_h_1 > 0.0f;
        if(_S603)
        {
            _S594 = _S588 > 0.0f;
        }
        else
        {
            _S594 = false;
        }
        if(_S594)
        {
            _S594 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S594 = false;
        }
        float _S604 = _slang_select(_S594, _S602,0.0f);
        pdf_h_0 = _S604;
    }
    else
    {
        pdf_h_0 = _S595;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float l_dot_h_0, float pdf_h_1, Weights w_4, float eta_i_3, float eta_o_3)
{
    float _S605 = eta_i_3 * w_4.v_dot_h + eta_o_3 * l_dot_h_0;
    float _S606 = w_4.p_refract * pdf_h_1 * eta_o_3 * eta_o_3 * (F32_abs((l_dot_h_0))) / (_S605 * _S605);
    bool _S607 = eta_i_3 != eta_o_3;
    bool _S608;
    if(_S607)
    {
        _S608 = l_dot_h_0 < 0.0f;
    }
    else
    {
        _S608 = false;
    }
    float _S609 = _slang_select(_S608, _S606,0.0f);
    return _S609;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_7, float alpha_6, AnisotropicFrame frame_4, BSDFMaterial material_8, Weights w_5)
{
    float _S610 = - dot_0(n_i_7, l_1);
    float _S611 = smithG1(alpha_6, (F32_max((_S610), (0.0f))));
    bool _S612 = (frame_4.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S612)
    {
        float3  _S613 = negate_0(n_i_7);
        float3  _S614 = anisotropicLocal(l_1, frame_4.tangent, _S613);
        float _S615 = anisotropicG1(_S614, frame_4.alphas);
        G1_l_0 = _S615;
    }
    else
    {
        G1_l_0 = _S611;
    }
    bool _S616 = (material_8.ior) == 1.0f;
    float _S617 = _slang_select(_S616, 1.0f,G1_l_0);
    return w_5.refract_weight * make_float3 (_S617) * material_8.albedo / make_float3 (w_5.p_refract);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_1, float n_i_dot_v_2, Weights w_6)
{
    float _S618 = w_6.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S619 = n_i_dot_l_1 > 0.0f;
    bool _S620;
    if(_S619)
    {
        _S620 = n_i_dot_v_2 > 0.0f;
    }
    else
    {
        _S620 = false;
    }
    float _S621 = _slang_select(_S620, _S618,0.0f);
    return _S621;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  v_7, float3  n_i_8, BSDFMaterial material_9, Weights w_7)
{
    float3  _S622 = l_2 + v_7;
    float3  _S623 = ((((_S622)) * make_float3(rnorm3df(((_S622)).x, ((_S622)).y, ((_S622)).z))));
    float _S624 = dot_0(n_i_8, _S623);
    float _S625 = (F32_max((dot_0(n_i_8, l_2)), (0.0f)));
    float _S626 = (F32_max((dot_0(n_i_8, v_7)), (0.0f)));
    float _S627 = 1.0f / (F32_max((material_9.sheen_roughness), (0.05000000074505806f)));
    float _S628 = 1.0f - _S624 * _S624;
    float _S629 = (2.0f + _S627) * (F32_pow(((F32_max((_S628), (0.0f)))), (0.5f * _S627))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S625 + _S626 - _S625 * _S626)), (0.0000152587890625f)));
    bool _S630 = (material_9.velvet) > 0.0f;
    float f_1;
    if(_S630)
    {
        float _S631 = (F32_max((material_9.sheen_roughness), (0.00999999977648258f)));
        float _S632 = _S631 * _S631;
        float _S633 = (F32_max((_S628), (0.0000152587890625f)));
        float _S634 = (F32_exp((- _S624 * _S624 / (_S633 * _S632)))) / (3.14159274101257324f * _S632 * _S633 * _S633) * (F32_min((1.0f), (2.0f * _S624 * (F32_min((_S625), (_S626))) / (F32_max(((F32_abs((dot_0(_S623, v_7))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S625 * _S626), (0.0000152587890625f)));
        f_1 = _S634;
    }
    else
    {
        f_1 = _S629;
    }
    return w_7.sheen * make_float3 (f_1 * _S625 * 2.0f * 3.14159274101257324f / w_7.p_sheen_velvet);
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
    float _S635 = (F32_max((1.0f - (t_13 - a_5) / (F32_max((s_0), (0.0000152587890625f)))), (0.0f)));
    bool _S636 = t_13 < a_5;
    float _S637 = _slang_select(_S636, 1.0f,_S635);
    return _S637;
}

__device__ __forceinline__ float toonIntegral(float t_14, float a_6, float s_1, bool glossy_0)
{
    float _S638 = (F32_min((t_14), (a_6)));
    float _S639 = (F32_sin((_S638)));
    float _S640 = _S639 * _S639 / 2.0f;
    float _S641 = 1.0f - (F32_cos((_S638)));
    float _S642 = _slang_select(glossy_0, _S641,_S640);
    bool _S643 = t_14 > a_6;
    bool _S644;
    if(_S643)
    {
        _S644 = s_1 > 0.0f;
    }
    else
    {
        _S644 = false;
    }
    float integral_0;
    if(_S644)
    {
        if(glossy_0)
        {
            float _S645 = (F32_cos((a_6)));
            float _S646 = (F32_cos((t_14)));
            integral_0 = (1.0f + a_6 / s_1) * (_S645 - _S646) - ((F32_sin((t_14))) - t_14 * _S646 - ((F32_sin((a_6))) - a_6 * _S645)) / s_1;
        }
        else
        {
            float _S647 = 2.0f * a_6;
            float _S648 = (F32_cos((_S647)));
            float _S649 = 2.0f * t_14;
            float _S650 = (F32_cos((_S649)));
            integral_0 = (1.0f + a_6 / s_1) * (_S648 - _S650) / 4.0f - ((F32_sin((_S649))) / 8.0f - t_14 * _S650 / 4.0f - ((F32_sin((_S647))) / 8.0f - a_6 * _S648 / 4.0f)) / s_1;
        }
        float integral_1 = _S642 + integral_0;
        integral_0 = integral_1;
    }
    else
    {
        integral_0 = _S642;
    }
    return integral_0;
}

static __device__ ToonProfile ToonProfile_x24init_0(bool glossy_1, float a_7, float s_2, float b_1, float norm_0, float view_0, float3  axis_0)
{
    ToonProfile _S651;
    (&_S651)->glossy = glossy_1;
    (&_S651)->a = a_7;
    (&_S651)->s = s_2;
    (&_S651)->b = b_1;
    (&_S651)->norm = norm_0;
    (&_S651)->view = view_0;
    (&_S651)->axis = axis_0;
    return _S651;
}

__device__ __forceinline__ ToonProfile toonProfile(float3  v_8, float3  n_i_9, BSDFMaterial material_10)
{
    float _S652 = material_10.toon.x;
    bool _S653 = _S652 < 0.0f;
    float _S654 = clamp_1(material_10.toon.y / _S652, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S655 = clamp_1(material_10.toon.z / _S652, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S656 = (F32_min((_S654 + _S655), (1.57079637050628662f)));
    float _S657 = dot_0(n_i_9, v_8);
    float _S658 = toonP((F32_acos(((F32_min((_S657), (1.0f)))))), _S654, _S655);
    float3  _S659 = make_float3 (2.0f * _S657) * n_i_9 - v_8;
    float3  _S660 = ((((_S659)) * make_float3(rnorm3df(((_S659)).x, ((_S659)).y, ((_S659)).z))));
    float3  _S661 = _slang_select(_S653, _S660,n_i_9);
    float _S662 = toonIntegral(_S656, _S654, _S655, _S653);
    return ToonProfile_x24init_0(_S653, _S654, _S655, _S656, 6.28318548202514648f * _S662, _S658, _S661);
}

__device__ __forceinline__ float toonPDF(float3  l_3, float3  n_i_10, ToonProfile profile_1, Weights w_8)
{
    float _S663 = dot_0(n_i_10, l_3);
    float _S664 = dot_0(l_3, profile_1.axis);
    float _S665 = _slang_select(profile_1.glossy, _S664,_S663);
    float _S666 = (F32_acos((clamp_1(_S665, -1.0f, 1.0f))));
    float _S667 = toonP(_S666, profile_1.a, profile_1.s);
    float _S668 = w_8.p_toon * _S667;
    float _S669 = _slang_select(profile_1.glossy, 1.0f,_S663);
    float _S670 = _S668 * _S669 / profile_1.norm;
    bool _S671;
    if(profile_1.glossy)
    {
        _S671 = true;
    }
    else
    {
        _S671 = _S663 > 0.0f;
    }
    float _S672 = _slang_select(_S671, _S670,0.0f);
    return _S672;
}

__device__ __forceinline__ float3  toonBSDF(float3  l_4, float3  n_i_11, ToonProfile profile_2, Weights w_9)
{
    float _S673 = (F32_max((dot_0(n_i_11, l_4)), (0.0f)));
    float _S674 = _slang_select(profile_2.glossy, _S673,profile_2.view);
    return w_9.toon * make_float3 (_S674) / make_float3 (w_9.p_toon);
}

__device__ __forceinline__ float reflectPDF(float pdf_h_2, Weights w_10)
{
    float _S675 = w_10.p_reflect * pdf_h_2 / (4.0f * w_10.v_dot_h);
    bool _S676 = pdf_h_2 > 0.0f;
    float _S677 = _slang_select(_S676, _S675,0.0f);
    return _S677;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_5, float3  n_i_12, float alpha_7, AnisotropicFrame frame_5, Weights w_11)
{
    float _S678 = dot_0(n_i_12, l_5);
    float _S679 = smithG1(alpha_7, (F32_max((_S678), (0.0f))));
    bool _S680 = (frame_5.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S680)
    {
        float3  _S681 = anisotropicLocal(l_5, frame_5.tangent, n_i_12);
        float _S682 = anisotropicG1(_S681, frame_5.alphas);
        G1_l_1 = _S682;
    }
    else
    {
        G1_l_1 = _S679;
    }
    return make_float3 (w_11.reflect_weight * G1_l_1) * w_11.F / make_float3 (w_11.p_reflect);
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_3, float3  out_dir_2, float3  n_6, BSDFMaterial material_11, float eta_i_4, float eta_o_4, bool refracted_2, uint random_state_4, FixedArray<float3 , 5>  * throughputs_0, FixedArray<float, 5>  * pdfs_0)
{
    float3  ggx_n_1;
    float3  _S683 = negate_0(in_dir_3);
    float _S684 = dot_0(n_6, _S683);
    float _S685 = sign_0(_S684);
    float3  _S686 = n_6 * make_float3 (_S685);
    float _S687 = dot_0(_S686, out_dir_2);
    float _S688 = material_11.roughness;
    float _S689 = _S688 * _S688;
    AnisotropicFrame _S690 = anisotropicFrame(material_11, _S686);
    SheenProfile _S691 = sheenProfile(_S683, _S686, material_11);
    float _S692 = rgb_to_greyscale(material_11.translucent);
    bool _S693 = _S692 > 0.0f;
    bool _S694 = (dot_0(n_6, out_dir_2) * _S684) < 0.0f;
    bool _S695 = (F32_abs((material_11.toon.x))) > 0.0f;
    uint _S696;
    if(_S695)
    {
        _S696 = 5U;
    }
    else
    {
        _S696 = 4U;
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
        float3  _S697 = make_float3 (0.0f);
        (*throughputs_0)[i_7] = _S697;
        (*pdfs_0)[i_7] = 0.0f;
        uint i_8 = i_7 + 1U;
        i_7 = i_8;
    }
    float3  _S698 = make_float3 (0.0f);
    Weights _S699 = Weights_x24init_0(0.0f, _S698, _S698, 0.0f, _S698, _S698, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, _S698, _S698);
    uint half_of_0 = 4294967295U;
    Weights w_12 = _S699;
    float3  ggx_n_2 = _S698;
    i_7 = 0U;
    for(;;)
    {
        if(i_7 < _S696)
        {
        }
        else
        {
            break;
        }
        uint _S700;
        if(i_7 == 3U)
        {
            _S700 = 4U;
        }
        else
        {
            if(i_7 == 4U)
            {
                _S700 = 6U;
            }
            else
            {
                _S700 = i_7;
            }
        }
        bool _S701 = _S700 == 0U;
        bool _S702;
        if(_S701)
        {
            _S702 = _S693;
        }
        else
        {
            _S702 = false;
        }
        bool _S703;
        if(_S702)
        {
            _S703 = _S694;
        }
        else
        {
            _S703 = _S700 == 1U;
        }
        bool _S704 = _S703 != refracted_2;
        if(_S704)
        {
            ggx_n_1 = ggx_n_2;
            uint i_9 = i_7 + 1U;
            ggx_n_2 = ggx_n_1;
            i_7 = i_9;
            continue;
        }
        uint _S705;
        if(_S700 == 6U)
        {
            _S705 = 0U;
        }
        else
        {
            if(_S700 == 4U)
            {
                _S705 = 2U;
            }
            else
            {
                _S705 = _S700;
            }
        }
        bool _S706 = _S705 != half_of_0;
        uint half_of_1;
        Weights w_13;
        if(_S706)
        {
            bool _S707 = _S705 == 0U;
            if(_S707)
            {
                float3  _S708 = sampledHalf(_S683, _S686, _S689, _S690, random_state_4);
                ggx_n_1 = _S708;
            }
            else
            {
                bool _S709 = _S705 == 1U;
                if(_S709)
                {
                    float3  _S710 = refractedHalf(in_dir_3, out_dir_2, n_6, eta_i_4, eta_o_4);
                    ggx_n_1 = _S710;
                }
                else
                {
                    float3  _S711 = reflectedHalf(in_dir_3, out_dir_2);
                    ggx_n_1 = _S711;
                }
            }
            Weights _S712 = lobeWeights(in_dir_3, _S683, _S686, ggx_n_1, _S690, _S691, material_11, eta_i_4, eta_o_4);
            w_13 = _S712;
            half_of_1 = _S705;
        }
        else
        {
            w_13 = w_12;
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S700)
        {
        case 0U:
            {
                float _S713 = diffusePDF(_S687, (F32_abs((_S684))), material_11, w_13);
                (*pdfs_0)[int(0)] = _S713;
                float3  _S714 = diffuseBSDF(out_dir_2, _S686, material_11, w_13);
                (*throughputs_0)[int(0)] = _S714;
                break;
            }
        case 1U:
            {
                float _S715 = dot_0(out_dir_2, ggx_n_1);
                float _S716 = vndfPDF(_S683, ggx_n_1, _S686, (F32_abs((_S684))), _S689, _S690, w_13.v_dot_h);
                float _S717 = refractPDF(_S715, _S716, w_13, eta_i_4, eta_o_4);
                (*pdfs_0)[int(1)] = _S717;
                float3  _S718 = refractBSDF(out_dir_2, _S686, _S689, _S690, material_11, w_13);
                (*throughputs_0)[int(1)] = _S718;
                break;
            }
        case 4U:
            {
                float _S719 = sheenVelvetPDF(_S687, (F32_abs((_S684))), w_13);
                (*pdfs_0)[int(3)] = _S719;
                float3  _S720 = sheenVelvetBSDF(out_dir_2, _S683, _S686, material_11, w_13);
                (*throughputs_0)[int(3)] = _S720;
                break;
            }
        case 6U:
            {
                ToonProfile _S721 = toonProfile(_S683, _S686, material_11);
                float _S722 = toonPDF(out_dir_2, _S686, _S721, w_13);
                (*pdfs_0)[int(4)] = _S722;
                float3  _S723 = toonBSDF(out_dir_2, _S686, _S721, w_13);
                (*throughputs_0)[int(4)] = _S723;
                break;
            }
        default:
            {
                float _S724 = vndfPDF(_S683, ggx_n_1, _S686, (F32_abs((_S684))), _S689, _S690, w_13.v_dot_h);
                float _S725 = reflectPDF(_S724, w_13);
                (*pdfs_0)[int(2)] = _S725;
                float3  _S726 = reflectBSDF(out_dir_2, _S686, _S689, _S690, w_13);
                (*throughputs_0)[int(2)] = _S726;
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
    ggx_n_1 = _S698;
    for(;;)
    {
        if(i_7 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S727 = ((*pdfs_0)[i_7]) > 0.0f;
        if(_S727)
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
    bool _S728 = wrongSide_0(is_inside_2, false, dir_6, surface_1->geometry_n);
    float3  _S729 = BSDF(in_dir_4, dir_6, surface_1->smooth_n, *material_12, eta_1.x, eta_1.y, _S728, random_state_5, terms_0, pdfs_1);
    float3  _S730 = make_float3 (0.0f);
    uint i_11 = 0U;
    float3  f_3 = _S730;
    for(;;)
    {
        if(i_11 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S731 = ((*pdfs_1)[i_11]) > 0.0f;
        if(_S731)
        {
            float3  _S732 = (*terms_0)[i_11] * make_float3 ((*pdfs_1)[i_11]) / make_float3 ((*pdfs_1)[i_11] + pdf_1);
            (*terms_0)[i_11] = _S732;
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
    FKSurface _S733 = surface_2;
    BSDFMaterial _S734 = material_13;
    FixedArray<float3 , 5>  terms_1;
    FixedArray<float, 5>  pdfs_2;
    float3  _S735 = skyLobes_0(in_dir_5, dir_7, &_S733, &_S734, eta_2, is_inside_3, pdf_2, random_state_6, &terms_1, &pdfs_2);
    return _S735;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_8, float3  radiance_0, float3  color_0, uint random_state_7)
{
    SkySample _S736;
    (&_S736)->dir = dir_8;
    (&_S736)->radiance = radiance_0;
    (&_S736)->color = color_0;
    (&_S736)->random_state = random_state_7;
    return _S736;
}

static __device__ __noinline__ float3  skyColor_0(float3  in_dir_6, float3  dir_9, FKSurface * surface_3, float wavelength_3, float2  eta_3, bool is_inside_4, float pdf_3, uint random_state_8, uint depth_1)
{
    BSDFMaterial _S737 = pathMaterial(surface_3->material, wavelength_3);
    BSDFMaterial _S738 = _S737;
    FixedArray<float3 , 5>  terms_2;
    FixedArray<float, 5>  pdfs_3;
    float3  _S739 = skyLobes_0(in_dir_6, dir_9, surface_3, &_S738, eta_3, is_inside_4, pdf_3, random_state_8, &terms_2, &pdfs_3);
    float3  _S740 = make_float3 (0.0f);
    bool shaded_0 = false;
    float3  world_0 = _S740;
    uint i_13 = 0U;
    float3  color_1 = _S740;
    for(;;)
    {
        if(i_13 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S741 = (pdfs_3[i_13]) > 0.0f;
        if(_S741)
        {
            bool _S742 = (fcptWorldReadsPath());
            bool _S743;
            if(_S742)
            {
                _S743 = true;
            }
            else
            {
                _S743 = !shaded_0;
            }
            bool shaded_1;
            float3  world_1;
            if(_S743)
            {
                uint _S744;
                if(i_13 == 3U)
                {
                    _S744 = 4U;
                }
                else
                {
                    if(i_13 == 4U)
                    {
                        _S744 = 6U;
                    }
                    else
                    {
                        _S744 = i_13;
                    }
                }
                float3  _S745 = (fcptEnvMapSample((dir_9), (depth_1), (_S744)));
                world_1 = _S745;
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
    uint2  _S746 = (fcptEnvironmentCdfSize());
    uint2  _S747 = make_uint2 (1U, 0U);
    uint2  _S748 = _S746 - _S747;
    Random _S749 = draw(init_random_state_0, 6U);
    Random _S750 = draw(init_random_state_0, 2147483654U);
    Random _S751 = draw(init_random_state_0, 7U);
    Random _S752 = draw(init_random_state_0, 2147483655U);
    uint _S753 = _S748.x;
    uint _S754 = searchCDF_0(make_uint2 (_S753, 0U), make_uint2 (0U, 1U), _S748.y, _S749.value);
    uint _S755 = searchCDF_0(make_uint2 (0U, _S754), _S747, _S753, _S750.value);
    float2  _S756 = make_float2 ((float)_S748.x, (float)_S748.y);
    float2  _S757 = (make_float2 (float(_S755), float(_S754)) + make_float2 (_S751.value, _S752.value)) / _S756 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S758 = _S757.y;
    float _S759 = (F32_sin((_S758)));
    float _S760 = _S757.x;
    float3  _S761 = skyFrame_0(make_float3 (_S759 * (F32_cos((_S760))), (F32_cos((_S758))), _S759 * (F32_sin((_S760)))));
    float _S762 = environmentPdf_0(_S761);
    BSDFMaterial _S763 = pathMaterial(surface_4->material, wavelength_4);
    float3  _S764 = ray_0->unit_direction;
    float3  _S765 = skyBSDF(ray_0->unit_direction, _S761, *surface_4, _S763, eta_4, is_inside_5, _S762, lobe_state_0);
    bool _S766 = !(_S762 > 0.0f);
    bool _S767;
    if(_S766)
    {
        _S767 = true;
    }
    else
    {
        _S767 = all_1(_S765 == make_float3 (0.0f));
    }
    if(_S767)
    {
        float3  _S768 = make_float3 (0.0f);
        return SkySample_x24init_0(_S761, _S768, _S768, _S752.state);
    }
    bool _S769 = (fcptWorldReadsPath());
    float3  seen_0;
    if(_S769)
    {
        float3  _S770 = skyColor_0(_S764, _S761, surface_4, wavelength_4, eta_4, is_inside_5, _S762, lobe_state_0, context_2->depth + 1U);
        seen_0 = _S770;
    }
    else
    {
        seen_0 = _S765;
    }
    float3  _S771 = skyRadiance_0(ray_0->origin, surface_4, is_inside_5, _S761, context_2, _S752.state);
    return SkySample_x24init_0(_S761, _S771, seen_0 * _S771, _S752.state);
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
    SampleBSDF _S772 = (fcptConnectHair((surface_5->hair), ((&surface_5->material)->albedo), ((&surface_5->material)->specular_tint), (in_dir_7), (light_1->dir)));
    float3  _S773 = _S772.throughput * make_float3 (_S772.pdf);
    float _S774 = light_1->density;
    float _S775 = 1.0f + _S772.pdf * _S772.pdf / (light_1->density * light_1->density);
    bool _S776;
    if(competing_0)
    {
        _S776 = _S774 > 0.0f;
    }
    else
    {
        _S776 = false;
    }
    float _S777 = _slang_select(_S776, _S775,1.0f);
    return _S773 / make_float3 (_S777) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_10, float3  radiance_1, float density_0, uint random_state_9)
{
    TreeSample _S778;
    (&_S778)->dir = dir_10;
    (&_S778)->radiance = radiance_1;
    (&_S778)->density = density_0;
    (&_S778)->random_state = random_state_9;
    return _S778;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_14, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S779 = importance(first_1, p_14, normal_3);
    float _S780 = importance(second_1, p_14, normal_3);
    float2  _S781 = make_float2 (_S779, _S780);
    bool _S782 = _S779 == 0.0f;
    bool _S783;
    if(_S782)
    {
        _S783 = _S780 == 0.0f;
    }
    else
    {
        _S783 = false;
    }
    if(_S783)
    {
        return 2U;
    }
    float _S784 = _S779 + _S780;
    bool _S785 = _S780 > 0.0f;
    if(_S785)
    {
        _S783 = (*pick_0 * _S784) >= _S779;
    }
    else
    {
        _S783 = false;
    }
    uint _S786 = uint(_S783);
    float _S787 = (F32_min(((*pick_0 * _S784 - float(_S786) * _S779) / _slang_vector_get_element(_S781, _S786)), (0.99999994039535522f)));
    *pick_0 = _S787;
    float _S788 = *probability_3 * (_slang_vector_get_element(_S781, _S786) / _S784);
    *probability_3 = _S788;
    return _S786;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_15, float u1_0, float u2_0)
{
    float3  _S789 = center_1 - p_15;
    float _S790 = radius_1 * radius_1 / dot_0(_S789, _S789);
    float _S791 = u1_0 * _S790 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S790), (0.0f)))))));
    float _S792 = 2.0f * u1_0;
    bool _S793 = _S790 >= 1.0f;
    float _S794 = _slang_select(_S793, _S792,_S791);
    float _S795 = (F32_sqrt(((F32_max((_S794 * (2.0f - _S794)), (0.0f))))));
    float _S796 = 6.28318548202514648f * u2_0;
    float3  _S797 = make_float3 (_S795 * (F32_cos((_S796))), 1.0f - _S794, _S795 * (F32_sin((_S796))));
    float3  _S798 = ((((_S789)) * make_float3(rnorm3df(((_S789)).x, ((_S789)).y, ((_S789)).z))));
    float3  _S799 = tangentToWorld(_S797, _S798);
    return _S799;
}

__device__ float3  pointLightRadiance(float3  color_3, float intensity_0, float radius_2)
{
    return color_3 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S800 = center_2 - ray_1->origin;
    float _S801 = dot_0(_S800, ray_1->unit_direction);
    float _S802 = dot_0(_S800, _S800) - _S801 * _S801;
    float _S803 = radius_3 * radius_3;
    bool _S804 = _S802 > _S803;
    if(_S804)
    {
        return 4.294967296e+09f;
    }
    float _S805 = (F32_sqrt((_S803 - _S802)));
    float _S806 = _S801 - _S805;
    float _S807 = _S801 + _S805;
    bool _S808 = _S806 > 0.0000152587890625f;
    bool _S809;
    if(_S808)
    {
        _S809 = _S806 < max_len_0;
    }
    else
    {
        _S809 = false;
    }
    if(_S809)
    {
        return _S806;
    }
    bool _S810 = _S807 > 0.0000152587890625f;
    if(_S810)
    {
        _S809 = _S807 < max_len_0;
    }
    else
    {
        _S809 = false;
    }
    if(_S809)
    {
        return _S807;
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
    float _S811 = sign_0(dot_0(- dir_11, n_7));
    float3  _S812 = emissive_0 * make_float3 ((F32_max((_S811), (0.0f))));
    bool _S813 = ((true));
    float3  _S814 = _slang_select(_S813, emissive_0,_S812);
    return _S814;
}

static __device__ __forceinline__ TreeSample sampleLightTree_0(float3  origin_4, float3  smooth_n_2, float3  geometry_n_1, float geometry_offset_1, bool sided_0, uint init_random_state_1, ShadowContext * context_3)
{
    Random _S815 = draw(init_random_state_1, 4U);
    Random _S816 = draw(init_random_state_1, 5U);
    Random _S817 = draw(init_random_state_1, 2147483653U);
    float3  _S818 = make_float3 (0.0f);
    TreeSample _S819 = TreeSample_x24init_0(_S818, _S818, 0.0f, _S817.state);
    TreeSample sample_0 = _S819;
    float3  _S820 = _slang_select(sided_0, _S818,smooth_n_2);
    float3  _S821 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S815.value;
    float probability_4 = 1.0f;
    uint n_8 = 0U;
    for(;;)
    {
        uint4  _S822 = (fcptLightNode((n_8)));
        if((_S822.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S823 = (fcptLightSecond((n_8)));
        uint _S824 = n_8 + 1U;
        LightNode _S825 = (fcptLightBounds((_S824)));
        LightNode _S826 = (fcptLightBounds((_S823)));
        uint _S827 = pickChild(_S825, _S826, origin_4, _S820, &pick_1, &probability_4);
        bool _S828 = _S827 > 1U;
        if(_S828)
        {
            return sample_0;
        }
        bool _S829 = _S827 == 1U;
        uint _S830 = _slang_select(_S829, _S823,_S824);
        n_8 = _S830;
    }
    bool _S831 = n_8 == 0U;
    bool _S832;
    if(_S831)
    {
        LightNode _S833 = (fcptLightBounds((0U)));
        float _S834 = importance(_S833, origin_4, _S820);
        _S832 = !(_S834 > 0.0f);
    }
    else
    {
        _S832 = false;
    }
    if(_S832)
    {
        return sample_0;
    }
    uint4  _S835 = (fcptLightNode((n_8)));
    FKHit _S836 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S837 = (_S835.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S837)
    {
        FKLight _S838 = (fcptLight((_S835.y)));
        if(sided_0)
        {
            float _S839 = sign_0(dot_0(geometry_n_1, _S838.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S839);
            float3  _S840 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S840;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S821;
            lift_n_0 = smooth_n_2;
        }
        bool _S841 = (_S838.variance) == 0.0f;
        if(_S841)
        {
            float3  _S842 = _S838.position - emitter_point_0;
            float3  _S843 = ((((_S842)) * make_float3(rnorm3df(((_S842)).x, ((_S842)).y, ((_S842)).z))));
            (&sample_0)->dir = _S843;
            float3  _S844 = _S838.color * make_float3 (_S838.intensity) / make_float3 (dot_0(_S842, _S842) * probability_4);
            (&sample_0)->radiance = _S844;
            shadow_1 = _S842;
        }
        else
        {
            float3  _S845 = sampleSphere(_S838.position, _S838.variance, emitter_point_0, _S816.value, _S817.value);
            (&sample_0)->dir = _S845;
            float _S846 = sphereDensity(_S838.position, _S838.variance, emitter_point_0);
            float _S847 = probability_4 * _S846;
            (&sample_0)->density = _S847;
            float3  _S848 = pointLightRadiance(_S838.color, _S838.intensity, _S838.variance);
            float3  _S849 = _S848 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S849;
            FKRay _S850 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S851 = raySphere_0(_S838.position, _S838.variance, &_S850, 4.294967296e+09f);
            float3  _S852 = (&sample_0)->dir * make_float3 (_S851);
            shadow_1 = _S852;
        }
        emitter_0 = _S836;
        emitter_point_0 = _S818;
    }
    else
    {
        uint _S853 = _S835.y;
        uint _S854 = (fcptTriangleOffset((_S853)));
        uint _S855 = _S854 + _S835.z;
        Matrix<float, 3, 3>  _S856 = (fcptWorldTriangle((_S853), (_S855)));
        float _S857 = (F32_sqrt((_S816.value)));
        float2  _S858 = make_float2 (_S857 * (1.0f - _S817.value), _S857 * _S817.value);
        float3  _S859 = mul_0(make_float3 (1.0f - _S857, _S858.x, _S858.y), _S856);
        if(sided_0)
        {
            float _S860 = sign_0(dot_0(geometry_n_1, _S859 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S860);
            float3  _S861 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S861;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S862 = !((dot_0(smooth_n_2, _S859 - origin_4)) > 0.0f);
            if(_S862)
            {
                return sample_0;
            }
            emitter_point_0 = _S821;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S858, _S853, _S855, 0U, 0.0f);
        float3  _S863 = _S859 - emitter_point_0;
        float3  _S864 = ((((_S863)) * make_float3(rnorm3df(((_S863)).x, ((_S863)).y, ((_S863)).z))));
        (&sample_0)->dir = _S864;
        float _S865 = solidAngle(probability_4, cross_0(_S856.rows[int(1)] - _S856.rows[int(0)], _S856.rows[int(2)] - _S856.rows[int(0)]), _S863);
        (&sample_0)->density = _S865;
        bool _S866 = (fcptShadowFirst());
        bool _S867 = !_S866;
        if(_S867)
        {
            FKSurface _S868 = (fcptLightSurfaceAt((emitter_1), (_S859), (_S817.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S859 - origin_4))));
            (&sample_0)->random_state = _S868.random_state;
            float3  _S869 = emitted_0(_S868.material.emissive, (&sample_0)->dir, _S868.smooth_n);
            float3  _S870 = _slang_select(_S868.skip, _S818,_S869);
            float3  _S871 = _S870 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S871;
        }
        shadow_1 = _S863;
        emitter_0 = emitter_1;
        emitter_point_0 = _S859;
    }
    FKHit _S872 = emitter_0;
    float3  _S873 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S817.state, &_S872);
    bool _S874 = (fcptShadowFirst());
    if(_S874)
    {
        _S832 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S832 = false;
    }
    if(_S832)
    {
        _S832 = !all_1(_S873 == _S818);
    }
    else
    {
        _S832 = false;
    }
    if(_S832)
    {
        FKSurface _S875 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S817.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S875.random_state;
        float3  _S876 = emitted_0(_S875.material.emissive, (&sample_0)->dir, _S875.smooth_n);
        float3  _S877 = _slang_select(_S875.skip, _S818,_S876);
        float3  _S878 = _S877 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S878;
    }
    float3  _S879 = (&sample_0)->radiance * _S873;
    bool _S880 = all_1(_S873 == _S818);
    float3  _S881 = _slang_select(_S880, _S818,_S879);
    (&sample_0)->radiance = _S881;
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
    float _S882 = 1.0f / (1.0f + b_2 / a_8 * (b_2 / a_8));
    bool _S883 = b_2 > 0.0f;
    float _S884 = _slang_select(_S883, _S882,1.0f);
    return _S884;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S885 = vertex_0->none;
    if(_S885)
    {
        return 1.0f;
    }
    uint _S886 = (fcptLightSlot((*hit_1)));
    float _S887 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S886, light_point_1);
    float _S888 = powerHeuristic(vertex_0->pdf, _S887);
    return _S888;
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
    float _S889 = upsample(f_5, wavelength_5);
    float3  _S890 = weight_0 * make_float3 (_S889);
    bool _S891 = wavelength_5 > 0.0f;
    float3  _S892 = _slang_select(_S891, _S890,f_5);
    return _S892;
}

__device__ float3  safeDivide(float3  a_9, float3  b_3)
{
    float3  _S893 = a_9 / b_3;
    float3  _S894 = make_float3 (0.0f);
    bool3  _S895 = b_3 == _S894;
    float3  _S896 = _slang_select(_S895, _S894,_S893);
    return _S896;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_2)
{
    uint _S897 = (1U << count_2) - 1U;
    return (e_2 & (~(_S897 << offset_1))) | ((newbits_0 & _S897) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_3, uint end_type_0, uint end_0, float3  f_6)
{
    Reservoir candidate_0 = r_3;
    uint _S898 = insertBits_0(r_3.path, end_0, 0U, 5U);
    uint _S899 = insertBits_0(_S898, end_type_0, 12U, 3U);
    (&candidate_0)->path = _S899;
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
    float _S900 = rgb_to_greyscale(abs_0(f_7));
    return _S900;
}

__device__ void offer(Selection * sel_2, Reservoir candidate_1, float3  weight_1)
{
    float _S901 = resamplingTarget(weight_1);
    bool _S902 = _S901 > 0.0f;
    bool _S903;
    if(_S902)
    {
        _S903 = _S901 < 3.00000000549775576e+38f;
    }
    else
    {
        _S903 = false;
    }
    bool _S904 = !_S903;
    if(_S904)
    {
        return;
    }
    bool _S905 = sel_2->sums;
    if(_S905)
    {
        float3  _S906 = sel_2->color + weight_1;
        sel_2->color = _S906;
        return;
    }
    float _S907 = sel_2->w_sum + _S901;
    sel_2->w_sum = _S907;
    float3  _S908 = sel_2->color + weight_1;
    sel_2->color = _S908;
    Random _S909 = pcg(sel_2->random_state);
    sel_2->random_state = _S909.state;
    bool _S910 = (_S909.value * sel_2->w_sum) <= _S901;
    if(_S910)
    {
        sel_2->r = candidate_1;
    }
    return;
}

static __device__ Shift escape_0(Reservoir * r_4, bool replay_1, uint stop_0, uint rc_0, uint end_1, uint end_type_1, float scale_3, uint strata_0, Reservoir * chain_0, float3  chain_throughput_0, uint b_4, FKRay * ray_2, float3  throughput_0, float density_1, Vertex * prev_0, NEEVertex * nee_vertex_0, float sky_pdf_0, float3  spectral_weight_0, float wavelength_6, Selection * sel_3)
{
    Shift _S911 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
    bool _S912 = !nee_vertex_0->none;
    float _S913 = _slang_select(_S912, sky_pdf_0,0.0f);
    float3  _S914 = ray_2->unit_direction;
    float _S915 = escapeWeight_0(_S913, ray_2->unit_direction);
    uint _S916 = prev_0->lobe;
    float3  _S917 = environment_0(_S914, b_4, prev_0->lobe);
    float3  _S918 = pathColor(throughput_0 * _S917, spectral_weight_0, wavelength_6);
    if(replay_1)
    {
        bool _S919 = b_4 == stop_0;
        bool _S920;
        if(_S919)
        {
            _S920 = rc_0 == 3U;
        }
        else
        {
            _S920 = false;
        }
        if(_S920)
        {
            return Shift_x24init_0(_S918 * make_float3 (_S915) / make_float3 (r_4->jac), density_1 / r_4->jac);
        }
        bool _S921 = rc_0 == 0U;
        if(_S921)
        {
            _S920 = end_type_1 == 3U;
        }
        else
        {
            _S920 = false;
        }
        if(_S920)
        {
            _S920 = b_4 == end_1;
        }
        else
        {
            _S920 = false;
        }
        if(_S920)
        {
            _S920 = !prev_0->rough;
        }
        else
        {
            _S920 = false;
        }
        if(_S920)
        {
            return Shift_x24init_0(_S918 * make_float3 (_S915), 1.0f);
        }
        return _S911;
    }
    Reservoir candidate_2 = *chain_0;
    uint _S922 = chain_0->path;
    uint _S923 = extractBits_0(chain_0->path, 10U, 2U);
    bool _S924 = _S923 == 1U;
    if(_S924)
    {
        uint _S925 = extractBits_0(_S922, 5U, 5U);
        bool _S926 = _S925 == b_4;
        float _S927 = _slang_select(_S926, 1.0f,_S915);
        float3  _S928 = safeDivide(_S918 * make_float3 (_S927), chain_throughput_0);
        (&candidate_2)->radiance = _S928;
    }
    else
    {
        bool _S929 = prev_0->rough;
        if(_S929)
        {
            uint _S930 = insertBits_0(strata_0, b_4 + 1U, 5U, 5U);
            uint _S931 = insertBits_0(_S930, 3U, 10U, 2U);
            uint _S932 = insertBits_0(_S931, _S916, 15U, 3U);
            bool _S933 = prev_0->inside;
            uint _S934 = _slang_select(_S933, 1U,0U);
            uint _S935 = insertBits_0(_S932, _S934, 22U, 1U);
            (&candidate_2)->path = _S935;
            (&candidate_2)->jac = prev_0->pdf;
            (&candidate_2)->dir = _S914;
        }
    }
    float3  _S936 = _S918 * make_float3 (_S915);
    Reservoir _S937 = withEnd(candidate_2, 3U, b_4, _S936);
    offer(sel_3, _S937, _S936 * make_float3 (scale_3) / make_float3 (density_1));
    return _S911;
}

static __device__ void restir_duplicates_0(uint3  global_invocation_id_1, uint3  local_invocation_id_0, uint local_invocation_index_3)
{
    uint2  _S938 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S939 = make_int2 ((int)_S938.x, (int)_S938.y);
    uint _S940 = previousSeed_0(_S939);
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
            uint _S941 = previousSeed_0(_S939 + make_int2 (x_17, y_5));
            bool _S942 = _S941 == _S940;
            uint _S943 = _slang_select(_S942, 1U,0U);
            uint count_4 = count_3 + _S943;
            int x_18 = x_17 + int(1);
            x_17 = x_18;
            count_3 = count_4;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S944 = float(count_3 - 1U) / 288.0f;
    bool _S945 = _S940 != 0U;
    float _S946 = _slang_select(_S945, _S944,0.0f);
    fcptStoreDuplication((_S939), (make_uint4 ((F32_asuint((_S946))), 0U, 0U, 0U)));
    return;
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
    float3  _S947 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_3)->f = _S947;
    float _S948 = r_5.jac * shifted_0.jac;
    (&candidate_3)->jac = _S948;
    offer(sel_4, candidate_3, make_float3 (mis_0) * shifted_0.f * make_float3 (r_5.w));
    return;
}

__device__ Reservoir finalize(Selection sel_5, float c_1)
{
    Reservoir r_6 = sel_5.r;
    float _S949 = resamplingTarget((&r_6)->f);
    float _S950 = sel_5.w_sum / _S949;
    bool _S951 = _S949 > 0.0f;
    float _S952 = _slang_select(_S951, _S950,0.0f);
    (&r_6)->w = _S952;
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
    uint2  _S953 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S954 = make_int2 ((int)_S953.x, (int)_S953.y);
    float3  _S955 = make_float3 (0.0f);
    FKHit _S956 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S957 = Domain_x24init_0(_S955, _S955, &_S956, 0.0f, 0.0f);
    Domain dom_5 = _S957;
    bool _S958 = (fcptCurrentDomain((_S954), (&dom_5)));
    bool _S959 = !_S958;
    if(_S959)
    {
        Reservoir _S960 = (Reservoir{});
        fcptStoreReservoirPrevious((_S954), (_S960), ((&dom_5)->hit));
        return;
    }
    Reservoir _S961 = (fcptLoadReservoirTemporal((_S954)));
    uint t_15 = 0U;
    float count_5 = 0.0f;
    float c_sum_0 = _S961.c;
    for(;;)
    {
        uint _S962 = (fcptRestirNeighbours());
        if(t_15 < _S962)
        {
        }
        else
        {
            break;
        }
        int2  _S963 = partner_0(_S954, t_15);
        Domain neighbor_0 = _S957;
        bool _S964 = (fcptCurrentDomain((_S963), (&neighbor_0)));
        if(_S964)
        {
            float count_6 = count_5 + 1.0f;
            uint4  _S965 = (fcptReservoirTemporal((_S963), (0U)));
            float c_sum_1 = c_sum_0 + (U32_asfloat((_S965.w)));
            count_5 = count_6;
            c_sum_0 = c_sum_1;
        }
        uint t_16 = t_15 + 1U;
        t_15 = t_16;
    }
    float _S966 = _S961.c / (F32_max((count_5), (1.0f)));
    float _S967 = resamplingTarget(_S961.f);
    bool _S968 = count_5 == 0.0f;
    float _S969 = _slang_select(_S968, 1.0f,0.0f);
    Selection _S970 = (Selection{});
    Selection sel_6 = _S970;
    uint _S971 = (fcptFrame());
    uint _S972 = hash(_S971);
    uint _S973 = global_invocation_id_2.x;
    uint2  _S974 = (fcptRenderSize());
    uint _S975 = stream(_S972, _S973 + _S974.x * global_invocation_id_2.y);
    uint _S976 = stream(_S975, 195U);
    (&sel_6)->random_state = _S976;
    t_15 = 0U;
    float canonical_mis_0 = _S969;
    for(;;)
    {
        uint _S977 = (fcptRestirNeighbours());
        if(t_15 < _S977)
        {
        }
        else
        {
            break;
        }
        int2  _S978 = partner_0(_S954, t_15);
        Domain neighbor_dom_0 = _S957;
        bool _S979 = (fcptCurrentDomain((_S978), (&neighbor_dom_0)));
        if(_S979)
        {
            Reservoir _S980 = (fcptLoadReservoirTemporal((_S978)));
            uint4  _S981 = (fcptShiftData((_S978), (t_15)));
            float4  _S982 = asfloat_0(_S981);
            uint4  _S983 = (fcptShiftData((_S954), (t_15)));
            float4  _S984 = asfloat_0(_S983);
            float _S985 = (_S980.c + _S966) / c_sum_0;
            bool _S986 = _S967 > 0.0f;
            float canonical_mis_1;
            if(_S986)
            {
                float _S987 = _S985 * _S966 * _S967;
                float _S988 = _S966 * _S967;
                float _S989 = resamplingTarget(float3 {_S984.x, _S984.y, _S984.z});
                float canonical_mis_2 = canonical_mis_0 + _S987 / (_S988 + _S980.c * _S989);
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float _S990 = resamplingTarget(_S980.f);
            float3  _S991 = float3 {_S982.x, _S982.y, _S982.z};
            Shift _S992 = Shift_x24init_0(_S991, _S982.w);
            float _S993 = _S985 * _S980.c * _S990;
            float _S994 = _S980.c * _S990;
            float _S995 = resamplingTarget(_S991);
            offerShifted(&sel_6, _S980, _S992, _S993 / (_S994 + _S966 * _S995));
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_17 = t_15 + 1U;
        t_15 = t_17;
    }
    offerShifted(&sel_6, _S961, Shift_x24init_0(_S961.f, 1.0f), canonical_mis_0);
    Reservoir _S996 = finalize(sel_6, c_sum_0);
    fcptStoreReservoirPrevious((_S954), (_S996), ((&dom_5)->hit));
    fcptStorePreviousLayer((_S954), (5U), (make_uint4 (asuint_0((&(&dom_5)->hit)->uv).x, asuint_0((&(&dom_5)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S954), (make_float4 ((&sel_6)->color.x, (&sel_6)->color.y, (&sel_6)->color.z, 0.0f)));
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
    uint _S997 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S998 = _S997 != 4294967295U;
    if(_S998)
    {
        uint2  _S999 = make_uint2 (_S997, _S997 >> 14U) & make_uint2 (16383U);
        int2  _S1000 = make_int2 ((int)_S999.x, (int)_S999.y);
        ShiftJob _S1001 = (ShiftJob{});
        ShiftJob shift_job_0 = _S1001;
        Shift _S1002 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S1003 = _S997 >> 28U;
        bool _S1004 = spatialJob_0(_S1000, _S1003, &shift_job_0, true);
        Shift shifted_1;
        if(_S1004)
        {
            Domain _S1005 = (&shift_job_0)->dom;
            Reservoir _S1006 = (&shift_job_0)->r;
            Shift _S1007 = passShift_0(&_S1005, &_S1006);
            shifted_1 = _S1007;
        }
        else
        {
            shifted_1 = _S1002;
        }
        fcptStoreShiftData((_S1000), (_S1003), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S1008 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S1009 = make_int2 ((int)_S1008.x, (int)_S1008.y);
    FixedArray<uint, 3>  _S1010;
    spatialBins_0(_S1009, &_S1010);
    FixedArray<uint, 3>  _S1011 = _S1010;
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
        bool _S1012 = (_S1011[t_18]) == 40U;
        if(_S1012)
        {
            fcptStoreShiftData((_S1009), (t_18), (make_uint4 (0U)));
        }
        uint t_19 = t_18 + 1U;
        t_18 = t_19;
    }
    FixedArray<uint, 3>  _S1013 = _S1011;
    queueShifts_0(_S1009, &_S1013, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S1014 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S1015 = make_int2 ((int)_S1014.x, (int)_S1014.y);
    FixedArray<uint, 3>  _S1016;
    spatialBins_0(_S1015, &_S1016);
    FixedArray<uint, 3>  _S1017 = _S1016;
    countShifts_0(&_S1017, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S1018 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S1019 = _S1018 != 4294967295U;
    if(_S1019)
    {
        uint2  _S1020 = make_uint2 (_S1018, _S1018 >> 14U) & make_uint2 (16383U);
        int2  _S1021 = make_int2 ((int)_S1020.x, (int)_S1020.y);
        int2  _S1022 = storedNeighbor_0(_S1021);
        uint _S1023 = _S1018 >> 28U;
        Shift _S1024 = temporalShiftAt_0(_S1021, _S1022, _S1023);
        fcptStoreTemporalShift((_S1021), (_S1023), (make_uint4 (asuint_1(_S1024.f).x, asuint_1(_S1024.f).y, asuint_1(_S1024.f).z, (F32_asuint((_S1024.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S1025 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S1026 = make_int2 ((int)_S1025.x, (int)_S1025.y);
    FixedArray<uint, 3>  _S1027;
    temporalBins_0(_S1026, &_S1027);
    FixedArray<uint, 3>  _S1028 = _S1027;
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
        bool _S1029 = (_S1028[t_20]) == 40U;
        if(_S1029)
        {
            fcptStoreTemporalShift((_S1026), (t_20), (make_uint4 (0U)));
        }
        uint t_21 = t_20 + 1U;
        t_20 = t_21;
    }
    FixedArray<uint, 3>  _S1030 = _S1028;
    queueShifts_0(_S1026, &_S1030, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S1031 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S1032 = make_int2 ((int)_S1031.x, (int)_S1031.y);
    bool _S1033 = (fcptSceneUnchanged());
    bool _S1034 = !_S1033;
    bool _S1035;
    if(_S1034)
    {
        uint2  _S1036 = (fcptRenderSize());
        int2  _S1037 = make_int2 ((int)_S1036.x, (int)_S1036.y);
        _S1035 = all_0(_S1032 < _S1037);
    }
    else
    {
        _S1035 = false;
    }
    if(_S1035)
    {
        Reservoir _S1038 = (fcptLoadReservoirInitial((_S1032)));
        int2  _S1039 = sampleNeighbor_0(_S1032, _S1038.seed);
        fcptStoreTemporalNeighbor((_S1032), (_S1039));
    }
    FixedArray<uint, 3>  _S1040;
    temporalBins_0(_S1032, &_S1040);
    FixedArray<uint, 3>  _S1041 = _S1040;
    countShifts_0(&_S1041, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_10, float b_5, float t_22)
{
    return a_10 + (b_5 - a_10) * t_22;
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S1042 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S1043 = make_int2 ((int)_S1042.x, (int)_S1042.y);
    float3  _S1044 = make_float3 (0.0f);
    FKHit _S1045 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S1046 = Domain_x24init_0(_S1044, _S1044, &_S1045, 0.0f, 0.0f);
    Domain dom_6 = _S1046;
    bool _S1047 = (fcptCurrentDomain((_S1043), (&dom_6)));
    bool _S1048 = !_S1047;
    if(_S1048)
    {
        Reservoir _S1049 = (Reservoir{});
        fcptStoreReservoirTemporal((_S1043), (_S1049), ((&dom_6)->hit));
        return;
    }
    Reservoir _S1050 = (fcptLoadReservoirInitial((_S1043)));
    bool _S1051 = (fcptTemporalQueued());
    bool _S1052 = (fcptSceneUnchanged());
    bool _S1053;
    if(_S1052)
    {
        _S1053 = true;
    }
    else
    {
        _S1053 = !_S1051;
    }
    int2  _S1054;
    if(_S1053)
    {
        int2  _S1055 = sampleNeighbor_0(_S1043, _S1050.seed);
        _S1054 = _S1055;
    }
    else
    {
        int2  _S1056 = storedNeighbor_0(_S1043);
        _S1054 = _S1056;
    }
    bool _S1057 = (_S1054.x) >= int(0);
    Reservoir r_7;
    if(_S1057)
    {
        Reservoir _S1058 = (fcptLoadReservoirPrevious((_S1054)));
        uint4  _S1059 = (fcptDuplication((_S1054)));
        float _S1060 = (U32_asfloat((_S1059.x)));
        uint _S1061 = (fcptRestirDecorrelation());
        bool _S1062 = _S1061 == 1U;
        float _S1063 = _slang_select(_S1062, _S1060,0.0f);
        float _S1064 = interpolate_0(20.0f, 1.0f, (F32_pow((_S1063), (0.10000000149011612f))));
        float _S1065 = (F32_min((_S1058.c), (_S1064)));
        bool _S1066 = (fcptSceneUnchanged());
        float4  _S1067 = make_float4 (_S1058.f.x, _S1058.f.y, _S1058.f.z, 1.0f);
        bool _S1068 = !_S1066;
        if(_S1068)
        {
            _S1053 = _S1051;
        }
        else
        {
            _S1053 = false;
        }
        float4  to_current_0;
        if(_S1053)
        {
            uint4  _S1069 = (fcptTemporalShift((_S1043), (0U)));
            float4  _S1070 = asfloat_0(_S1069);
            to_current_0 = _S1070;
        }
        else
        {
            if(_S1068)
            {
                Shift _S1071 = temporalShiftAt_0(_S1043, _S1054, 0U);
                float4  _S1072 = make_float4 (_S1071.f.x, _S1071.f.y, _S1071.f.z, _S1071.jac);
                to_current_0 = _S1072;
            }
            else
            {
                to_current_0 = _S1067;
            }
        }
        Domain own_1 = _S1046;
        if(_S1066)
        {
            _S1053 = true;
        }
        else
        {
            bool _S1073 = (fcptPreviousScenes());
            bool _S1074 = !_S1073;
            if(_S1074)
            {
                _S1053 = (_S1050.w) > 0.0f;
            }
            else
            {
                _S1053 = false;
            }
            if(_S1053)
            {
                bool _S1075 = (fcptStoredDomainInitial((_S1043), (_S1050.seed), (&own_1)));
                _S1053 = _S1075;
            }
            else
            {
                _S1053 = false;
            }
            if(_S1053)
            {
                Domain _S1076 = (fcptPreviousDomain((_S1054), (_S1050.seed)));
                Domain _S1077 = _S1076;
                Domain _S1078 = own_1;
                bool _S1079 = sameDomain_0(&_S1077, &_S1078);
                _S1053 = _S1079;
            }
            else
            {
                _S1053 = false;
            }
        }
        float4  _S1080 = make_float4 (_S1050.f.x, _S1050.f.y, _S1050.f.z, 1.0f);
        bool _S1081 = !_S1053;
        if(_S1081)
        {
            _S1053 = _S1051;
        }
        else
        {
            _S1053 = false;
        }
        float4  to_previous_0;
        if(_S1053)
        {
            uint4  _S1082 = (fcptTemporalShift((_S1043), (1U)));
            float4  _S1083 = asfloat_0(_S1082);
            to_previous_0 = _S1083;
        }
        else
        {
            if(_S1081)
            {
                Shift _S1084 = temporalShiftAt_0(_S1043, _S1054, 1U);
                float4  _S1085 = make_float4 (_S1084.f.x, _S1084.f.y, _S1084.f.z, _S1084.jac);
                to_previous_0 = _S1085;
            }
            else
            {
                to_previous_0 = _S1080;
            }
        }
        float _S1086 = resamplingTarget(_S1050.f);
        float _S1087 = resamplingTarget(_S1058.f);
        Selection _S1088 = (Selection{});
        Selection sel_7 = _S1088;
        uint _S1089 = (fcptFrame());
        uint _S1090 = hash(_S1089);
        uint _S1091 = global_invocation_id_7.x;
        uint2  _S1092 = (fcptRenderSize());
        uint _S1093 = stream(_S1090, _S1091 + _S1092.x * global_invocation_id_7.y);
        uint _S1094 = stream(_S1093, 194U);
        (&sel_7)->random_state = _S1094;
        float _S1095 = _S1050.c * _S1086;
        float4  _S1096 = to_previous_0;
        float _S1097 = resamplingTarget(float3 {_S1096.x, _S1096.y, _S1096.z});
        float _S1098 = _S1095 / (_S1095 + _S1065 * _S1097);
        float _S1099 = _S1065 * _S1087;
        float4  _S1100 = to_current_0;
        float3  _S1101 = float3 {_S1100.x, _S1100.y, _S1100.z};
        float _S1102 = resamplingTarget(_S1101);
        float _S1103 = _S1099 / (_S1099 + _S1050.c * _S1102);
        float2  _S1104 = make_float2 (_S1098, _S1103);
        offerShifted(&sel_7, _S1050, Shift_x24init_0(_S1050.f, 1.0f), _S1098);
        offerShifted(&sel_7, _S1058, Shift_x24init_0(_S1101, to_current_0.w), _S1103);
        Reservoir _S1105 = finalize(sel_7, _S1050.c + _S1065);
        r_7 = _S1105;
    }
    else
    {
        r_7 = _S1050;
    }
    fcptStoreReservoirTemporal((_S1043), (r_7), ((&dom_6)->hit));
    return;
}

__device__ uint noiseOrigin(uint2  p_16, uint k_1)
{
    uint _S1106 = ((p_16.x) >> 11U) | (((p_16.y) >> 11U) << 4U);
    uint2  _S1107 = noiseOffset(8192U + (k_1 >> 10U) + (_S1106 << 20U));
    uint2  _S1108 = (p_16 + _S1107) & make_uint2 (2047U);
    return ((_S1108.x) | ((_S1108.y) << 11U)) | ((k_1 & 1023U) << 22U);
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S1109 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S1110 = make_int2 ((int)_S1109.x, (int)_S1109.y);
    float3  _S1111 = make_float3 (0.0f);
    FKHit _S1112 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S1113 = Domain_x24init_0(_S1111, _S1111, &_S1112, 0.0f, 0.0f);
    Domain dom_7 = _S1113;
    bool _S1114 = (fcptCurrentDomain((_S1110), (&dom_7)));
    bool _S1115 = !_S1114;
    if(_S1115)
    {
        Reservoir _S1116 = (Reservoir{});
        fcptStoreReservoirInitial((_S1110), (_S1116), ((&dom_7)->hit));
        return;
    }
    uint _S1117 = (fcptFrame());
    uint _S1118 = hash(_S1117);
    uint _S1119 = global_invocation_id_8.x;
    uint2  _S1120 = (fcptRenderSize());
    uint _S1121 = global_invocation_id_8.y;
    uint _S1122 = stream(_S1118, _S1119 + _S1120.x * _S1121);
    uint2  _S1123 = (fcptRenderSize());
    uint _S1124 = stream(_S1119 + _S1123.x * _S1121, 512U);
    Selection _S1125 = (Selection{});
    Selection initial_0 = _S1125;
    uint _S1126 = stream(_S1122, 193U);
    (&initial_0)->random_state = _S1126;
    bool _S1127 = (fcptRestirUsed());
    bool _S1128 = !_S1127;
    (&initial_0)->sums = _S1128;
    uint _S1129 = stream(_S1122, 0U);
    (&(&initial_0)->r)->seed = _S1129;
    FKHit _S1130 = (&dom_7)->hit;
    uint _S1131 = (fcptSamples());
    float _S1132 = 1.0f / float(_S1131);
    FKHit hit_2 = _S1130;
    uint i_20 = 0U;
    float3  seen_1 = _S1111;
    for(;;)
    {
        uint _S1133 = (fcptSamples());
        if(i_20 < _S1133)
        {
        }
        else
        {
            break;
        }
        Reservoir _S1134 = (Reservoir{});
        Reservoir r_8 = _S1134;
        uint _S1135 = (fcptFrame());
        uint _S1136 = (fcptSamples());
        uint _S1137 = _S1135 * _S1136 + i_20;
        uint _S1138 = noiseOrigin(_S1109, _S1137);
        (&r_8)->seed = _S1138;
        uint _S1139 = insertBits_0(0U, 1U, 24U, 1U);
        uint _S1140 = insertBits_0(_S1139, (_S1124 + _S1137 * 2654435769U) >> 25U, 25U, 7U);
        (&r_8)->path = _S1140;
        Domain path_0 = dom_7;
        bool _S1141 = seedDomain_0(_S1110, (&r_8)->seed, &path_0);
        bool _S1142 = !_S1141;
        if(_S1142)
        {
            float3  _S1143 = (fcptMissed((_S1110), (path_0), (_S1132)));
            float3  seen_2 = seen_1 + _S1143;
            seen_1 = seen_2;
            uint i_21 = i_20 + 1U;
            i_20 = i_21;
            continue;
        }
        Domain _S1144 = path_0;
        Reservoir _S1145 = r_8;
        Shift _S1146 = passWalk_0(&_S1144, &_S1145, false, _S1132, &initial_0);
        bool _S1147 = ((&(&initial_0)->r)->seed) == ((&r_8)->seed);
        FKHit hit_3;
        if(_S1147)
        {
            FKHit _S1148 = (&path_0)->hit;
            hit_3 = _S1148;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_21 = i_20 + 1U;
        i_20 = i_21;
    }
    uint _S1149 = (fcptSamples());
    float3  seen_3 = seen_1 + (&initial_0)->glow / make_float3 (float(_S1149));
    float3  _S1150 = seen_3 + (&initial_0)->color;
    bool _S1151 = (&initial_0)->sums;
    float3  _S1152 = _slang_select(_S1151, _S1150,seen_3);
    fcptAddColor((_S1110), (make_float4 (_S1152.x, _S1152.y, _S1152.z, 1.0f)));
    Reservoir _S1153 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S1110), (_S1153), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_4, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S1154;
    (&_S1154)->none = none_0;
    (&_S1154)->pdf = pdf_4;
    (&_S1154)->origin = origin_5;
    (&_S1154)->smooth_n = smooth_n_3;
    (&_S1154)->start = start_6;
    return _S1154;
}

static __device__ Vertex Vertex_x24init_0(bool rough_0, uint lobe_1, float pdf_5, float cos_0, bool inside_0)
{
    Vertex _S1155;
    (&_S1155)->rough = rough_0;
    (&_S1155)->lobe = lobe_1;
    (&_S1155)->pdf = pdf_5;
    (&_S1155)->cos = cos_0;
    (&_S1155)->inside = inside_0;
    return _S1155;
}

static __device__ bool any_1(bool3  x_22)
{
    bool result_11 = false;
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
        if(result_11)
        {
            result_11 = true;
        }
        else
        {
            result_11 = (bool((_slang_vector_get_element(x_22, i_22))));
        }
        i_22 = i_22 + int(1);
    }
    return result_11;
}

__device__ uint noiseAddress(uint origin_6, uint bounce_0)
{
    uint2  _S1156 = make_uint2 (origin_6 & 2047U, (origin_6 >> 11U) & 2047U);
    uint2  _S1157 = noiseOffset(64U + bounce_0 * 17U);
    uint2  _S1158 = (_S1156 + _S1157) & make_uint2 (2047U);
    return ((_S1158.x) | ((_S1158.y) << 11U)) | ((origin_6 >> 22U) << 22U);
}

static __device__ float3  exp_0(float3  x_23)
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
        *_slang_vector_get_element_ptr(&result_12, i_23) = (F32_exp((_slang_vector_get_element(x_23, i_23))));
        i_23 = i_23 + int(1);
    }
    return result_12;
}

static __device__ float3  flightWeight_0(float3  scatter_0, float3  extinction_0, float distance_2, bool scatters_0)
{
    float3  _S1159 = exp_0(- scatter_0 * make_float3 (distance_2));
    float3  _S1160 = make_float3 (3.0f) * exp_0(- extinction_0 * make_float3 (distance_2));
    float3  _S1161 = _S1160 / make_float3 (_S1159.x + _S1159.y + _S1159.z);
    float3  _S1162 = scatter_0 * _S1160 / make_float3 (dot_0(scatter_0, _S1159));
    float3  _S1163 = _slang_select(scatters_0, _S1162,_S1161);
    return _S1163;
}

static __device__ uint arrivalLobe_0(uint b_6, uint prev_lobe_0)
{
    bool _S1164 = b_6 > 0U;
    uint _S1165 = _slang_select(_S1164, prev_lobe_0,3U);
    return _S1165;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_2, uint lobe_2, bool surface_6, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S1166;
    (&_S1166)->extinction_behind = extinction_behind_0;
    (&_S1166)->extinction_front = extinction_front_0;
    (&_S1166)->fillings = fillings_0;
    (&_S1166)->side = side_0;
    (&_S1166)->depth = depth_2;
    (&_S1166)->lobe = lobe_2;
    (&_S1166)->surface = surface_6;
    (&_S1166)->length = length_2;
    (&_S1166)->width = width_1;
    (&_S1166)->own = *own_2;
    (&_S1166)->fiber = fiber_0;
    return _S1166;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S1167 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S1167)
    {
        return 0.07957746833562851f;
    }
    float _S1168 = g_0 * g_0;
    return (1.0f - _S1168) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S1168 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float survivalProbability(float3  throughput_1, float density_2)
{
    return (F32_min(((F32_max(((F32_max((throughput_1.x), ((F32_max((throughput_1.y), (throughput_1.z)))))) / density_2), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_10)
{
    Random _S1169 = draw(random_state_10, 11U);
    Random _S1170 = draw(random_state_10, 2147483659U);
    float _S1171 = 1.0f - 2.0f * _S1169.value;
    float _S1172 = (F32_sqrt(((F32_max((1.0f - _S1171 * _S1171), (0.0f))))));
    float _S1173 = 6.28318548202514648f * _S1170.value;
    return make_float3 (_S1172 * (F32_cos((_S1173))), _S1172 * (F32_sin((_S1173))), _S1171);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_12, uint random_state_11, float * pdf_6)
{
    bool _S1174 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1174)
    {
        *pdf_6 = 0.07957746833562851f;
        float3  _S1175 = isotropic_0(random_state_11);
        return _S1175;
    }
    Random _S1176 = draw(random_state_11, 11U);
    Random _S1177 = draw(random_state_11, 2147483659U);
    float _S1178 = g_1 * g_1;
    float _S1179 = 2.0f * g_1;
    float _S1180 = (1.0f - _S1178) / (1.0f - g_1 + _S1179 * _S1176.value);
    float _S1181 = clamp_1((1.0f + _S1178 - _S1180 * _S1180) / _S1179, -1.0f, 1.0f);
    float _S1182 = (F32_sqrt(((F32_max((1.0f - _S1181 * _S1181), (0.0f))))));
    float _S1183 = 6.28318548202514648f * _S1177.value;
    float _S1184 = phaseHG_0(g_1, _S1181);
    *pdf_6 = _S1184;
    float3  _S1185 = tangentToWorld(make_float3 (_S1182 * (F32_cos((_S1183))), _S1181, _S1182 * (F32_sin((_S1183)))), dir_12);
    float3  _S1186 = ((((_S1185)) * make_float3(rnorm3df(((_S1185)).x, ((_S1185)).y, ((_S1185)).z))));
    return _S1186;
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_1, float3  emissive_1, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_1, float velvet_0, float3  toon_2, float dispersion_0)
{
    BSDFMaterial _S1187;
    (&_S1187)->albedo = albedo_1;
    (&_S1187)->emissive = emissive_1;
    (&_S1187)->roughness = roughness_0;
    (&_S1187)->metallic = metallic_0;
    (&_S1187)->transmission = transmission_0;
    (&_S1187)->ior = ior_0;
    (&_S1187)->absorption = absorption_0;
    (&_S1187)->specular_tint = specular_tint_0;
    (&_S1187)->specular_level = specular_level_0;
    (&_S1187)->translucent = translucent_0;
    (&_S1187)->sheen = sheen_2;
    (&_S1187)->sheen_roughness = sheen_roughness_0;
    (&_S1187)->anisotropy = anisotropy_0;
    (&_S1187)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1187)->tangent = tangent_1;
    (&_S1187)->velvet = velvet_0;
    (&_S1187)->toon = toon_2;
    (&_S1187)->dispersion = dispersion_0;
    return _S1187;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1188;
    (&_S1188)->scatter = scatter_1;
    (&_S1188)->extinction = extinction_1;
    (&_S1188)->g = g_2;
    return _S1188;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_14, bool skip_0, uint random_state_12, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1189;
    (&_S1189)->smooth_n = smooth_n_4;
    (&_S1189)->geometry_n = geometry_n_2;
    (&_S1189)->geometry_offset = geometry_offset_2;
    (&_S1189)->material = *material_14;
    (&_S1189)->skip = skip_0;
    (&_S1189)->random_state = random_state_12;
    (&_S1189)->coverage = coverage_0;
    (&_S1189)->encloses = encloses_0;
    (&_S1189)->volume = *volume_0;
    (&_S1189)->fills = fills_0;
    (&_S1189)->hair = hair_0;
    return _S1189;
}

static __device__ FKSurface emitting_0(FKSurface * surface_7, bool top_0)
{
    FKSurface lower_0 = *surface_7;
    float3  _S1190 = (&surface_7->material)->emissive;
    float3  _S1191 = make_float3 (0.0f);
    bool _S1192 = !top_0;
    float3  _S1193 = _slang_select(_S1192, _S1191,_S1190);
    (&(&lower_0)->material)->emissive = _S1193;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_8, float u_1)
{
    float _S1194 = surface_8->coverage;
    bool _S1195 = u_1 < _S1194;
    if(_S1195)
    {
        return *surface_8;
    }
    float3  _S1196 = make_float3 (0.0f);
    float3  _S1197 = make_float3 (1.0f);
    BSDFMaterial _S1198 = Material_x24init_0(_S1196, _S1196, 0.0f, 0.0f, 0.0f, 0.0f, _S1196, _S1197, 1.0f, _S1196, _S1196, 0.5f, 0.0f, 0.0f, _S1196, 0.0f, _S1196, 0.0f);
    BSDFMaterial material_15 = _S1198;
    (&material_15)->albedo = _S1197;
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
    bool _S1199 = transmission_1 > 0.0f;
    bool _S1200;
    if(_S1199)
    {
        _S1200 = true;
    }
    else
    {
        _S1200 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1201 = _slang_select(_S1200, 1.0f,-1.0f);
    return _S1201;
}

static __device__ bool arrivesBehind_0(float3  dir_13, float3  n_9)
{
    return (dot_0(dir_13, n_9)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_9, float3  dir_14)
{
    float3  _S1202 = surface_9->geometry_n;
    float _S1203 = facingSign((&surface_9->material)->transmission, surface_9->geometry_n, dir_14);
    FKSurface faced_0 = *surface_9;
    float3  _S1204 = surface_9->smooth_n * make_float3 (_S1203);
    (&faced_0)->smooth_n = _S1204;
    float3  _S1205 = _S1202 * make_float3 (_S1203);
    (&faced_0)->geometry_n = _S1205;
    return faced_0;
}

static __device__ float3  max_0(float3  x_24, float3  y_7)
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
        *_slang_vector_get_element_ptr(&result_13, i_24) = (F32_max((_slang_vector_get_element(x_24, i_24)), (_slang_vector_get_element(y_7, i_24))));
        i_24 = i_24 + int(1);
    }
    return result_13;
}

static __device__ float3  log_0(float3  x_25)
{
    float3  result_14;
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
        *_slang_vector_get_element_ptr(&result_14, i_25) = (F32_log((_slang_vector_get_element(x_25, i_25))));
        i_25 = i_25 + int(1);
    }
    return result_14;
}

__device__ float3  beerLambert(float distance_3, float3  absorption_1)
{
    float3  _S1206 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1206));
}

__device__ bool dispersive(BSDFMaterial material_16)
{
    bool _S1207 = (material_16.dispersion) > 0.0f;
    bool _S1208;
    if(_S1207)
    {
        _S1208 = (material_16.ior) != 1.0f;
    }
    else
    {
        _S1208 = false;
    }
    return _S1208;
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
        uint _S1209 = (low_1 + high_1 + 1U) / 2U;
        bool _S1210 = (WAVELENGTH_CDF_0[_S1209]) <= u_2;
        if(_S1210)
        {
            low_1 = _S1209;
        }
        else
        {
            uint _S1211 = _S1209 - 1U;
            high_1 = _S1211;
        }
    }
    uint _S1212 = low_1;
    float _S1213 = WAVELENGTH_CDF_0[low_1 + 1U] - WAVELENGTH_CDF_0[low_1];
    return make_float2 (0.37999999523162842f + 0.00499999988824129f * (float(low_1) + (u_2 - WAVELENGTH_CDF_0[_S1212]) / _S1213), _S1213 / 0.00499999988824129f);
}

__device__ static const FixedArray<float, 243>  WAVELENGTH_WEIGHTS_0 = { {
    0.00547470012679696f, -0.00465690018609166f, 0.03257500007748604f, 0.00934640038758516f, -0.00796370021998882f, 0.05577300116419792f, 0.01846100017428398f, -0.01579399965703487f, 0.11072999984025955f, 0.0416410006582737f, -0.03577499836683273f, 0.2513900101184845f, 0.09349299967288971f, -0.08071800321340561f, 0.56742000579833984f, 0.1585099995136261f, -0.13764999806880951f, 0.97018998861312866f, 0.30943000316619873f, -0.27083000540733337f, 1.91740000247955322f, 0.55217999219894409f, -0.48754000663757324f, 3.46889996528625488f, 0.95016998052597046f, -0.84802001714706421f, 6.09439992904663086f, 1.42110002040863037f, -1.28929996490478516f, 9.45199966430664062f, 1.73409998416900635f, -1.6062999963760376f, 12.12800025939941406f, 2.08030009269714355f, -1.98810005187988281f, 15.68700027465820312f, 2.20600008964538574f, -2.20120000839233398f, 18.47699928283691406f, 2.03040003776550293f, -2.17700004577636719f, 19.92700004577636719f, 1.63429999351501465f, -2.00340008735656738f, 20.86899948120117188f, 0.99410998821258545f, -1.62629997730255127f, 20.57799911499023438f, 0.20011000335216522f, -1.11409997940063477f, 19.72100067138671875f, -0.67960000038146973f, -0.45403000712394714f, 17.77599906921386719f, -1.61679995059967041f, 0.37860000133514404f, 14.71500015258789062f, -2.53410005569458008f, 1.27540004253387451f, 11.86499977111816406f, -3.39079999923706055f, 2.2146000862121582f, 9.17669963836669922f, -4.03749990463256836f, 3.0522000789642334f, 6.59509992599487305f, -4.61299991607666016f, 3.89779996871948242f, 4.64589977264404297f, -5.43039989471435547f, 5.0121002197265625f, 3.3199000358581543f, -6.37769985198974609f, 6.33809995651245117f, 2.29699993133544922f, -7.44140005111694336f, 7.91739988327026367f, 1.45389997959136963f, -8.38580036163330078f, 9.60109996795654297f, 0.66465997695922852f, -9.0167999267578125f, 11.23999977111816406f, -0.04403600096702576f, -9.17749977111816406f, 12.63199996948242188f, -0.58126997947692871f, -8.97550010681152344f, 13.91499996185302734f, -0.95730000734329224f, -8.25290012359619141f, 14.86200046539306641f, -1.24430000782012939f, -6.92129993438720703f, 15.03899955749511719f, -1.43069994449615479f, -5.29169988632202148f, 14.90900039672851562f, -1.55149996280670166f, -3.43219995498657227f, 14.70499992370605469f, -1.63569998741149902f, -1.27190005779266357f, 14.24400043487548828f, -1.67030000686645508f, 1.15170001983642578f, 13.32199954986572266f, -1.636199951171875f, 3.73889994621276855f, 12.21199989318847656f, -1.56920003890991211f, 6.43590021133422852f, 10.94699954986572266f, -1.47730004787445068f, 9.16440010070800781f, 9.54769992828369141f, -1.36399996280670166f, 12.02000045776367188f, 8.18799972534179688f, -1.25450003147125244f, 14.78699970245361328f, 6.74429988861083984f, -1.13110005855560303f, 16.72299957275390625f, 5.08780002593994141f, -0.96561002731323242f, 18.14299964904785156f, 3.57019996643066406f, -0.80725997686386108f, 19.91900062561035156f, 2.36269998550415039f, -0.69273000955581665f, 21.05500030517578125f, 1.31369996070861816f, -0.58597999811172485f, 21.3899993896484375f, 0.42390000820159912f, -0.48298001289367676f, 20.99300003051757812f, -0.23857000470161438f, -0.39412000775337219f, 19.82200050354003906f, -0.6866300106048584f, -0.31501999497413635f, 18.12000083923339844f, -0.9412500262260437f, -0.24890999495983124f, 15.7089996337890625f, -1.02020001411437988f, -0.19076000154018402f, 13.19799995422363281f, -0.98919999599456787f, -0.14401000738143921f, 11.23999977111816406f, -0.93347001075744629f, -0.11133000254631042f, 9.36649990081787109f, -0.83820998668670654f, -0.08524099737405777f, 7.41249990463256836f, -0.70064002275466919f, -0.06283199787139893f, 5.71229982376098633f, -0.56079000234603882f, -0.04586699977517128f, 4.42280006408691406f, -0.44653001427650452f, -0.03396600112318993f, 3.34489989280700684f, -0.34457001090049744f, -0.02482499927282333f, 2.49309992790222168f, -0.26017999649047852f, -0.01808100007474422f, 1.82239997386932373f, -0.1921599954366684f, -0.01296999957412481f, 1.29499995708465576f, -0.13766999542713165f, -0.00907570030540228f, 0.92928999662399292f, -0.09956400096416473f, -0.00641620019450784f, 0.61835998296737671f, -0.06671299785375595f, -0.00421149982139468f, 0.40211999416351318f, -0.04354599863290787f, -0.00271830009296536f, 0.2844499945640564f, -0.03087200038135052f, -0.00191440002527088f, 0.20672999322414398f, -0.02246100082993507f, -0.00138829997740686f, 0.15044000744819641f, -0.01634499989449978f, -0.00101030000951141f, 0.10942000150680542f, -0.01188699994236231f, -0.0007347899954766f, 0.07099699974060059f, -0.00771349994465709f, -0.00047679000999779f, 0.04539500176906586f, -0.00493190018460155f, -0.00030484999297187f, 0.03424099832773209f, -0.00372010003775358f, -0.00022995000472292f, 0.02557599917054176f, -0.00277870008721948f, -0.00017175999528263f, 0.01842200011014938f, -0.00200140010565519f, -0.0001237099932041f, 0.01316899992525578f, -0.00143079995177686f, -0.00008843900286593f, 0.00838890019804239f, -0.00091141002485529f, -0.00005633700129692f, 0.00537079991772771f, -0.00058350997278467f, -0.00003606799873523f, 0.00328280008397996f, -0.00035665999166667f, -0.00002204600059486f, 0.00196009990759194f, -0.00021296000340953f, -0.00001316300040344f, 0.00168939994182438f, -0.00018354000349063f, -0.00001134499962063f, 0.00141050003003329f, -0.00015325000276789f, -0.00000947250009631f, 0.00097123999148607f, -0.00010551999730524f, -6.52239987175562419e-06f, 0.00066868000430986f, -0.00007264900341397f, -4.49060007667867467e-06f
} };
__device__ float3  wavelengthWeights(float wavelength_7)
{
    float _S1214 = clamp_1((wavelength_7 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    uint _S1215 = (U32_min((uint(_S1214)), (79U)));
    uint _S1216 = 3U * _S1215;
    float3  _S1217 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1216], WAVELENGTH_WEIGHTS_0[_S1216 + 1U], WAVELENGTH_WEIGHTS_0[_S1216 + 2U]);
    float3  _S1218 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1216 + 3U], WAVELENGTH_WEIGHTS_0[_S1216 + 4U], WAVELENGTH_WEIGHTS_0[_S1216 + 5U]);
    return _S1217 + (_S1218 - _S1217) * make_float3 (_S1214 - float(_S1215));
}

__device__ float dispersedIor(float ior_1, float dispersion_1, float wavelength_8)
{
    float _S1219 = (ior_1 - 1.0f) * dispersion_1 / 1.90962409973144531f;
    float _S1220 = _S1219 * (1.0f / (wavelength_8 * wavelength_8) - 2.89662933349609375f);
    bool _S1221 = dispersion_1 > 0.0f;
    float _S1222 = _slang_select(_S1221, _S1220,0.0f);
    return ior_1 + _S1222;
}

__device__ float2  vertexEta(BSDFMaterial material_17, float n_dot_v_0)
{
    bool _S1223 = n_dot_v_0 < 0.0f;
    float _S1224 = _slang_select(_S1223, material_17.ior,1.0f);
    float _S1225 = _slang_select(_S1223, 1.0f,material_17.ior);
    return make_float2 (_S1224, _S1225);
}

__device__ float2  wavelengthEta(BSDFMaterial material_18, float n_dot_v_1, float wavelength_9)
{
    BSDFMaterial refractive_0 = material_18;
    float _S1226 = dispersedIor(material_18.ior, material_18.dispersion, wavelength_9);
    bool _S1227 = wavelength_9 > 0.0f;
    float _S1228 = _slang_select(_S1227, _S1226,material_18.ior);
    (&refractive_0)->ior = _S1228;
    float2  _S1229 = vertexEta(refractive_0, n_dot_v_1);
    return _S1229;
}

__device__ bool neeDecision(BSDFMaterial material_19, float n_dot_v_2, float eta_i_5, float eta_o_5)
{
    float _S1230 = fresnel((F32_abs((n_dot_v_2))), eta_i_5, eta_o_5);
    float3  _S1231 = mix_0(make_float3 (_S1230), material_19.albedo, material_19.metallic);
    float _S1232 = rgb_to_greyscale(_S1231);
    float _S1233 = (F32_max(((1.0f - _S1232) * (1.0f - material_19.metallic) * (1.0f - material_19.transmission)), (0.0f)));
    bool _S1234 = _S1233 > 0.03999999910593033f;
    bool _S1235;
    if(_S1234)
    {
        _S1235 = true;
    }
    else
    {
        _S1235 = (material_19.roughness) > 0.20000000298023224f;
    }
    return _S1235;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_20)
{
    float _S1236 = rgb_to_greyscale(material_20->translucent);
    return _S1236 > 0.0f;
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
    MediumSides _S1237;
    (&_S1237)->behind = *behind_0;
    (&_S1237)->front = *front_0;
    (&_S1237)->fillings = fillings_1;
    (&_S1237)->face = face_1;
    return _S1237;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_10, FKMedium * medium_0, uint filling_0, float3  dir_15, FKMedium * outside_0)
{
    float3  _S1238 = surface_10->geometry_n;
    MediumSides _S1239 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_10->geometry_n);
    MediumSides sides_0 = _S1239;
    bool _S1240 = surface_10->encloses;
    if(_S1240)
    {
        (&sides_0)->behind = surface_10->volume;
        *&((&(&sides_0)->fillings)->x) = surface_10->fills;
        bool _S1241 = (dot_0(dir_15, _S1238)) > 0.0f;
        if(_S1241)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_11, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_16, uint depth_3, uint lobe_3, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1242 = surface_11->geometry_n;
    ShadowContext _S1243 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_11->geometry_n, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
    bool _S1244 = surface_11->encloses;
    ShadowContext context_4;
    if(_S1244)
    {
        FKSurface faced_1 = *surface_11;
        float3  _S1245 = - _S1242;
        float3  _S1246 = _slang_select(turned_0, _S1245,_S1242);
        (&faced_1)->geometry_n = _S1246;
        FKMedium _S1247 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1248 = faced_1;
        FKMedium _S1249 = _S1247;
        MediumSides _S1250 = mediumSides_0(&_S1248, &_S1249, filling_1, dir_16, outside_1);
        ShadowContext _S1251 = ShadowContext_x24init_0(_S1250.behind.extinction, _S1250.front.extinction, _S1250.fillings, _S1242, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
        if(turned_0)
        {
            uint2  _S1252 = _S1250.fillings;
            ShadowContext _S1253 = ShadowContext_x24init_0(_S1250.front.extinction, _S1250.behind.extinction, uint2 {_S1252.y, _S1252.x}, _S1242, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
            context_4 = _S1253;
        }
        else
        {
            context_4 = _S1251;
        }
    }
    else
    {
        context_4 = _S1243;
    }
    return context_4;
}

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_8, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_3, BSDFMaterial * material_21, float eta_i_6, float eta_o_6, bool competing_1, uint random_state_13)
{
    float3  _S1254 = light_2->dir;
    bool _S1255 = (dot_0(geometry_n_3, - in_dir_8) * dot_0(geometry_n_3, light_2->dir)) <= 0.0f;
    FixedArray<float3 , 5>  throughputs_1;
    FixedArray<float, 5>  pdfs_4;
    float3  _S1256 = BSDF(in_dir_8, _S1254, smooth_n_5, *material_21, eta_i_6, eta_o_6, _S1255, random_state_13, &throughputs_1, &pdfs_4);
    bool _S1257 = !competing_1;
    bool _S1258;
    if(_S1257)
    {
        _S1258 = true;
    }
    else
    {
        _S1258 = (light_2->density) == 0.0f;
    }
    if(_S1258)
    {
        return _S1256 * light_2->radiance;
    }
    float3  _S1259 = make_float3 (0.0f);
    uint i_26 = 0U;
    float3  weighted_0 = _S1259;
    for(;;)
    {
        if(i_26 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S1260 = (pdfs_4[i_26]) > 0.0f;
        if(_S1260)
        {
            float _S1261 = light_2->density;
            float _S1262 = pdfs_4[i_26] / light_2->density;
            float3  weighted_1 = weighted_0 + throughputs_1[i_26] * make_float3 (pdfs_4[i_26]) / make_float3 (_S1261 * (1.0f + _S1262 * _S1262));
            weighted_0 = weighted_1;
        }
        uint i_27 = i_26 + 1U;
        i_26 = i_27;
    }
    return weighted_0 * light_2->radiance * make_float3 (light_2->density);
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_2, uint random_state_14, bool refracted_3, uint lobe_4, float pdf_7)
{
    SampleBSDF _S1263;
    (&_S1263)->unit_direction = unit_direction_1;
    (&_S1263)->throughput = throughput_2;
    (&_S1263)->random_state = random_state_14;
    (&_S1263)->refracted = refracted_3;
    (&_S1263)->lobe = lobe_4;
    (&_S1263)->pdf = pdf_7;
    return _S1263;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  v_9, float3  n_i_13, float n_i_dot_v_3, BSDFMaterial material_22, Weights w_14, uint random_state_15)
{
    Random _S1264 = draw(random_state_15, 3U);
    Random _S1265 = draw(random_state_15, 2147483651U);
    float _S1266 = _S1264.value;
    float _S1267 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1266 * _S1266))))));
    float _S1268 = 6.28318548202514648f * _S1265.value;
    float3  _S1269 = tangentToWorld(make_float3 (_S1267 * (F32_cos((_S1268))), _S1264.value, _S1267 * (F32_sin((_S1268)))), n_i_13);
    float3  _S1270 = sheenVelvetBSDF(_S1269, v_9, n_i_13, material_22, w_14);
    float _S1271 = sheenVelvetPDF(_S1264.value, n_i_dot_v_3, w_14);
    return SampleBSDF_x24init_0(_S1269, _S1270, _S1265.state, false, 4U, _S1271);
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1272 = (F32_sqrt((random_1_0)));
    float _S1273 = 6.28318548202514648f * random_2_0;
    float _S1274 = _S1272 * (F32_cos((_S1273)));
    float _S1275 = _S1272 * (F32_sin((_S1273)));
    float _S1276 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1274 * _S1274 - _S1275 * _S1275))))));
    return make_float3 (_S1274, _S1276, _S1275);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_3, float3  n_i_14, float n_i_dot_v_4, BSDFMaterial material_23, Weights w_15, uint random_state_16)
{
    Random _S1277 = draw(random_state_16, 3U);
    Random _S1278 = draw(random_state_16, 2147483651U);
    float3  _S1279 = sampleCosWeightedHemisphere(_S1277.value, _S1278.value);
    float _S1280 = translucentShare(material_23);
    bool _S1281 = u_3 < (w_15.p_diffuse * _S1280);
    float _S1282 = _S1279.y;
    float _S1283 = - _S1282;
    float _S1284 = _slang_select(_S1281, _S1283,_S1282);
    float3  _S1285 = tangentToWorld(make_float3 (_S1279.x, _S1284, _S1279.z), n_i_14);
    float3  _S1286 = diffuseBSDF(_S1285, n_i_14, material_23, w_15);
    float _S1287 = diffusePDF(_S1284, n_i_dot_v_4, material_23, w_15);
    return SampleBSDF_x24init_0(_S1285, _S1286, _S1278.state, _S1281, 0U, _S1287);
}

__device__ __forceinline__ SampleBSDF toonSample(float3  n_i_15, ToonProfile profile_3, Weights w_16, uint random_state_17)
{
    Random _S1288 = draw(random_state_17, 3U);
    Random _S1289 = draw(random_state_17, 2147483651U);
    float _S1290 = _S1288.value * profile_3.norm / 6.28318548202514648f;
    float _S1291 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1290)))), (1.0f))))));
    float _S1292 = (F32_acos((clamp_1(1.0f - _S1290, -1.0f, 1.0f))));
    float _S1293 = _slang_select(profile_3.glossy, _S1292,_S1291);
    float _S1294 = (profile_3.a + profile_3.b) / 2.0f;
    bool _S1295 = _S1293 < (profile_3.a);
    float _S1296 = _slang_select(_S1295, _S1293,_S1294);
    float t_23 = _S1296;
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
        float _S1297 = toonP(t_23, profile_3.a, profile_3.s);
        float _S1298 = _S1297 * (F32_sin((t_23)));
        float _S1299 = (F32_cos((t_23)));
        float _S1300 = _slang_select(profile_3.glossy, 1.0f,_S1299);
        float _S1301 = _S1298 * _S1300;
        float _S1302 = toonIntegral(t_23, profile_3.a, profile_3.s, profile_3.glossy);
        float _S1303 = (_S1302 - _S1290) / _S1301;
        bool _S1304 = _S1301 > 0.0f;
        float _S1305 = _slang_select(_S1304, _S1303,0.0f);
        float _S1306 = clamp_1(t_23 - _S1305, 0.0f, profile_3.b);
        int k_3 = k_2 + int(1);
        t_23 = _S1306;
        k_2 = k_3;
    }
    float _S1307 = 6.28318548202514648f * _S1289.value;
    float _S1308 = (F32_sin((t_23)));
    float3  _S1309 = tangentToWorld(make_float3 (_S1308 * (F32_cos((_S1307))), (F32_cos((t_23))), _S1308 * (F32_sin((_S1307)))), profile_3.axis);
    float3  _S1310 = toonBSDF(_S1309, n_i_15, profile_3, w_16);
    bool _S1311 = (dot_0(n_i_15, _S1309)) < 0.0f;
    float _S1312 = toonPDF(_S1309, n_i_15, profile_3, w_16);
    return SampleBSDF_x24init_0(_S1309, _S1310, _S1289.state, _S1311, 6U, _S1312);
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_16, float alpha_8, AnisotropicFrame frame_6, BSDFMaterial material_24, Weights w_17, float pdf_h_3, float eta_i_7, float eta_o_7, uint random_state_18)
{
    float3  _S1313 = make_float3 (1.0f);
    SampleBSDF _S1314 = SampleBSDF_x24init_0(_S1313, _S1313, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S1314;
    (&sample_1)->unit_direction = w_17.refracted;
    (&sample_1)->random_state = random_state_18;
    (&sample_1)->refracted = true;
    (&sample_1)->lobe = 1U;
    float3  _S1315 = refractBSDF((&sample_1)->unit_direction, n_i_16, alpha_8, frame_6, material_24, w_17);
    (&sample_1)->throughput = _S1315;
    float _S1316 = refractPDF(dot_0((&sample_1)->unit_direction, ggx_n_3), pdf_h_3, w_17, eta_i_7, eta_o_7);
    (&sample_1)->pdf = _S1316;
    return sample_1;
}

static __device__ float3  reflect_0(float3  i_28, float3  n_10)
{
    return i_28 - make_float3 (2.0f * dot_0(n_10, i_28)) * n_10;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_9, float3  ggx_n_4, float3  n_i_17, float alpha_9, AnisotropicFrame frame_7, Weights w_18, float pdf_h_4, uint random_state_19)
{
    float3  _S1317 = make_float3 (1.0f);
    SampleBSDF _S1318 = SampleBSDF_x24init_0(_S1317, _S1317, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S1318;
    float3  _S1319 = reflect_0(in_dir_9, ggx_n_4);
    float3  _S1320 = ((((_S1319)) * make_float3(rnorm3df(((_S1319)).x, ((_S1319)).y, ((_S1319)).z))));
    (&sample_2)->unit_direction = _S1320;
    (&sample_2)->random_state = random_state_19;
    (&sample_2)->lobe = 2U;
    float3  _S1321 = reflectBSDF((&sample_2)->unit_direction, n_i_17, alpha_9, frame_7, w_18);
    (&sample_2)->throughput = _S1321;
    float _S1322 = reflectPDF(pdf_h_4, w_18);
    (&sample_2)->pdf = _S1322;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_10, float3  n_11, BSDFMaterial material_25, float eta_i_8, float eta_o_8, uint random_init_0, float2  screen_space_0)
{
    uint random_state_20 = random_init_0;
    float3  _S1323 = negate_0(in_dir_10);
    float _S1324 = dot_0(n_11, _S1323);
    float _S1325 = sign_0(_S1324);
    float3  n_i_18 = n_11 * make_float3 (_S1325);
    float _S1326 = (F32_abs((_S1324)));
    float _S1327 = material_25.roughness;
    float _S1328 = _S1327 * _S1327;
    AnisotropicFrame _S1329 = anisotropicFrame(material_25, n_i_18);
    SheenProfile _S1330 = sheenProfile(_S1323, n_i_18, material_25);
    float3  _S1331 = sampleHalfVector(_S1323, n_i_18, _S1328, _S1329, &random_state_20);
    Weights _S1332 = lobeWeights(in_dir_10, _S1323, n_i_18, _S1331, _S1329, _S1330, material_25, eta_i_8, eta_o_8);
    Random _S1333 = draw(random_state_20, 2U);
    random_state_20 = _S1333.state;
    bool _S1334 = (_S1333.value) < (_S1332.p_sheen_velvet);
    if(_S1334)
    {
        SampleBSDF _S1335 = sheenVelvetSample(_S1323, n_i_18, _S1326, material_25, _S1332, random_state_20);
        return _S1335;
    }
    float _S1336 = _S1333.value - _S1332.p_sheen_velvet;
    bool _S1337 = _S1336 < (_S1332.p_diffuse);
    if(_S1337)
    {
        SampleBSDF _S1338 = diffuseSample(_S1336, n_i_18, _S1326, material_25, _S1332, random_state_20);
        return _S1338;
    }
    bool _S1339 = _S1336 < (_S1332.p_diffuse + _S1332.p_toon);
    if(_S1339)
    {
        ToonProfile _S1340 = toonProfile(_S1323, n_i_18, material_25);
        SampleBSDF _S1341 = toonSample(n_i_18, _S1340, _S1332, random_state_20);
        return _S1341;
    }
    float _S1342 = vndfPDF(_S1323, _S1331, n_i_18, _S1326, _S1328, _S1329, _S1332.v_dot_h);
    bool _S1343 = (_S1336 - _S1332.p_toon) < (_S1332.p_diffuse + _S1332.p_refract);
    if(_S1343)
    {
        SampleBSDF _S1344 = refractSample(_S1331, n_i_18, _S1328, _S1329, material_25, _S1332, _S1342, eta_i_8, eta_o_8, random_state_20);
        return _S1344;
    }
    SampleBSDF _S1345 = reflectSample(in_dir_10, _S1331, n_i_18, _S1328, _S1329, _S1332, _S1342, random_state_20);
    return _S1345;
}

static __device__ bool boundsVolume_0(FKSurface * surface_12)
{
    return surface_12->encloses;
}

static __device__ Shift walk_0(Domain * dom_8, Reservoir * r_9, bool replay_2, float scale_4, Selection * sel_8)
{
    bool turned_1;
    bool is_inside_6;
    bool viewed_0;
    bool _S1346;
    bool _S1347;
    bool _S1348;
    uint b_7;
    uint layer_0;
    float3  throughput_3;
    float3  spectral_weight_1;
    float density_3;
    float spread_1;
    float width_3;
    float sky_pdf_1;
    float wavelength_10;
    float threshold_0;
    TreeSample light_3;
    int _S1349;
    Shift ended_0;
    float density_4;
    float spread_2;
    float width_4;
    float sky_pdf_2;
    uint b_8;
    float spread_3;
    float width_5;
    float3  _S1350 = make_float3 (0.0f);
    Shift _S1351 = Shift_x24init_0(_S1350, 0.0f);
    uint _S1352 = r_9->path;
    uint _S1353 = extractBits_0(r_9->path, 0U, 5U);
    uint _S1354 = extractBits_0(_S1352, 5U, 5U);
    uint _S1355 = extractBits_0(_S1352, 10U, 2U);
    uint _S1356 = extractBits_0(_S1352, 12U, 3U);
    bool passes_0;
    if(replay_2)
    {
        bool _S1357 = _S1356 >= 3U;
        uint _S1358 = _slang_select(_S1357, 1U,0U);
        uint _S1359 = _S1353 + _S1358;
        uint _S1360 = (fcptMaxBounces());
        passes_0 = _S1359 > _S1360;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1351;
    }
    uint _S1361 = _S1354 - 1U;
    bool _S1362 = _S1356 == 3U;
    uint _S1363 = _slang_select(_S1362, 1U,0U);
    uint _S1364 = _S1353 + _S1363;
    bool _S1365 = _S1355 == 0U;
    uint _S1366 = _slang_select(_S1365, _S1364,_S1361);
    FKHit _S1367 = (fcptReservoirHit((*r_9)));
    float3  _S1368 = dom_8->x0;
    float3  _S1369 = dom_8->x1 - dom_8->x0;
    float3  _S1370 = ((((_S1369)) * make_float3(rnorm3df(((_S1369)).x, ((_S1369)).y, ((_S1369)).z))));
    FKRay _S1371 = Ray_x24init_0(dom_8->x1, _S1370);
    FKRay ray_3 = _S1371;
    FKHit hit_4 = dom_8->hit;
    float3  scatter_in_0 = _S1350;
    float3  throughput_4 = make_float3 (1.0f);
    float3  weight_2 = throughput_4;
    float3  glowed_0 = _S1350;
    float3  extinction_in_0 = _S1350;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1372 = dom_8->spread;
    float _S1373 = dom_8->width;
    float _S1374 = length_0(_S1369);
    NEEVertex _S1375 = NEEVertex_x24init_0(true, 0.0f, _S1350, _S1350, _S1350);
    NEEVertex nee_vertex_1 = _S1375;
    Vertex _S1376 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_1 = _S1376;
    Reservoir _S1377 = (Reservoir{});
    Reservoir chain_1 = _S1377;
    uint _S1378 = r_9->seed;
    (&chain_1)->seed = r_9->seed;
    uint _S1379 = extractBits_0(_S1352, 24U, 8U);
    uint _S1380 = insertBits_0(0U, _S1379, 24U, 8U);
    (&chain_1)->path = _S1380;
    (&ray_3)->origin = _S1368;
    (&hit_4)->distance = _S1374;
    FKMedium _S1381 = (fcptCameraMedium(((&ray_3)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1382 = filling_2;
    bool _S1383 = (fcptVaryingUsed());
    uint _S1384 = _slang_select(_S1383, _S1382,4294967295U);
    filling_2 = _S1384;
    scatter_in_0 = _S1381.scatter;
    extinction_in_0 = _S1381.extinction;
    g_in_0 = _S1381.g;
    Reservoir _S1385 = chain_1;
    uint _S1386 = filling_2;
    for(;;)
    {
        bool _S1387 = (fcptVaryingUsed());
        if(_S1387)
        {
            passes_0 = _S1386 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1388 = (fcptMajorant((_S1386)));
            turned_1 = _S1388 > 0.0f;
        }
        else
        {
            turned_1 = any_1(scatter_in_0 > make_float3 (0.0f));
        }
        if(replay_2)
        {
            is_inside_6 = 4294967295U == _S1366;
        }
        else
        {
            is_inside_6 = false;
        }
        if(is_inside_6)
        {
            is_inside_6 = _S1355 == 1U;
        }
        else
        {
            is_inside_6 = false;
        }
        if(is_inside_6)
        {
            is_inside_6 = turned_1;
        }
        else
        {
            is_inside_6 = false;
        }
        if(is_inside_6)
        {
            ended_0 = _S1351;
            sky_pdf_1 = 0.0f;
            spread_1 = _S1372;
            width_3 = _S1373;
            density_3 = 1.0f;
            throughput_3 = throughput_4;
            b_7 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1389 = (&prev_1)->rough;
        if(_S1389)
        {
            is_inside_6 = !turned_1;
        }
        else
        {
            is_inside_6 = false;
        }
        (&prev_1)->rough = is_inside_6;
        uint _S1390 = stream(_S1378, 384U);
        uint tracking_0 = _S1390;
        weight_2 = throughput_4;
        glowed_0 = _S1350;
        b_7 = 4294967295U;
        throughput_3 = throughput_4;
        density_3 = 1.0f;
        spread_1 = _S1372;
        width_3 = _S1373;
        sky_pdf_1 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1349 = int(1);
                break;
            }
            float _S1391 = (&hit_4)->distance;
            if(passes_0)
            {
                float3  _S1392 = (&ray_3)->origin;
                float3  _S1393 = (&ray_3)->unit_direction;
                float _S1394 = (&hit_4)->distance;
                bool _S1395 = b_7 == 4294967295U;
                uint _S1396 = _slang_select(_S1395, 0U,b_7);
                uint _S1397 = (&prev_1)->lobe;
                uint _S1398 = _slang_select(_S1395, 3U,_S1397);
                float _S1399 = (fcptTrackMedium((_S1386), (_S1392), (_S1393), (_S1394), (&tracking_0), (&weight_2), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1396), (_S1398), (_S1395)));
                wavelength_10 = _S1399;
            }
            else
            {
                if(turned_1)
                {
                    uint _S1400 = noiseAddress(_S1378, b_7);
                    Random _S1401 = draw(_S1400, 10U);
                    float _S1402 = 3.0f * _S1401.value;
                    uint _S1403 = (U32_min((uint(_S1402)), (2U)));
                    float _S1404 = - (F32_log((1.0f - (_S1402 - float(_S1403))))) / *_slang_vector_get_element_ptr(&scatter_in_0, _S1403);
                    wavelength_10 = _S1404;
                }
                else
                {
                    wavelength_10 = _S1391;
                }
            }
            bool _S1405 = !(wavelength_10 < ((&hit_4)->distance));
            if(_S1405)
            {
                _S1349 = int(1);
                break;
            }
            if(passes_0)
            {
                is_inside_6 = !replay_2;
            }
            else
            {
                is_inside_6 = false;
            }
            if(is_inside_6)
            {
                float3  _S1406 = pathColor(throughput_3 * glowed_0, throughput_4, 0.0f);
                float3  _S1407 = _S1406 / make_float3 (density_3);
                float3  _S1408 = sel_8->glow + _S1407;
                sel_8->glow = _S1408;
            }
            else
            {
            }
            glowed_0 = _S1350;
            uint b_9 = b_7 + 1U;
            float3  _S1409 = (&ray_3)->origin + make_float3 (wavelength_10) * (&ray_3)->unit_direction;
            (&ray_3)->origin = _S1409;
            float3  _S1410 = flightWeight_0(scatter_in_0, extinction_in_0, wavelength_10, true);
            float3  _S1411 = weight_2;
            float _S1412 = upsample(weight_2, 0.0f);
            float3  _S1413 = make_float3 (_S1412);
            float3  _S1414 = _slang_select(false, _S1413,_S1411);
            float3  _S1415 = _slang_select(passes_0, _S1414,_S1410);
            float3  throughput_5 = throughput_3 * _S1415;
            uint _S1416 = stream(_S1378, b_9 + 320U);
            tracking_0 = _S1416;
            weight_2 = throughput_4;
            float width_6 = width_3 + spread_1 * wavelength_10;
            float _S1417 = spread_1 + 3.14159274101257324f;
            bool _S1418 = !replay_2;
            if(_S1418)
            {
                viewed_0 = true;
            }
            else
            {
                bool _S1419 = b_9 == _S1366;
                if(_S1419)
                {
                    viewed_0 = !passes_0;
                }
                else
                {
                    viewed_0 = false;
                }
            }
            TreeSample _S1420 = TreeSample_x24init_0(_S1350, _S1350, 0.0f, 0U);
            if(viewed_0)
            {
                float3  _S1421 = (&ray_3)->origin;
                float3  _S1422 = (&ray_3)->unit_direction;
                float3  _S1423 = (&ray_3)->unit_direction;
                uint _S1424 = noiseAddress(_S1378, b_9);
                float3  _S1425 = extinction_in_0;
                float3  _S1426 = extinction_in_0;
                uint2  _S1427 = make_uint2 (_S1386);
                float3  _S1428 = (&ray_3)->unit_direction;
                uint _S1429 = arrivalLobe_0(b_9, (&prev_1)->lobe);
                FKHit _S1430 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1431 = _S1430;
                ShadowContext _S1432 = ShadowContext_x24init_0(_S1425, _S1426, _S1427, _S1428, b_9, _S1429, false, wavelength_10, width_6, &_S1431, false);
                ShadowContext _S1433 = _S1432;
                TreeSample _S1434 = sampleLightTree_0(_S1421, _S1422, _S1423, 0.0f, true, _S1424, &_S1433);
                light_3 = _S1434;
            }
            else
            {
                light_3 = _S1420;
            }
            float _S1435 = phaseHG_0(g_in_0, dot_0((&ray_3)->unit_direction, light_3.dir));
            uint _S1436 = (fcptMaxBounces());
            bool _S1437 = b_9 < _S1436;
            if(_S1437)
            {
                _S1346 = (light_3.density) > 0.0f;
            }
            else
            {
                _S1346 = false;
            }
            float _S1438 = _slang_select(_S1346, _S1435,0.0f);
            float3  _S1439 = throughput_5 * light_3.radiance;
            float _S1440 = powerHeuristic(light_3.density, _S1438);
            float3  _S1441 = pathColor(_S1439 * make_float3 (_S1435 * _S1440), throughput_4, 0.0f);
            float3  _S1442 = _slang_select(viewed_0, _S1441,_S1350);
            if(replay_2)
            {
                _S1347 = b_9 == _S1366;
            }
            else
            {
                _S1347 = false;
            }
            if(_S1347)
            {
                bool _S1443 = _S1355 == 2U;
                if(_S1443)
                {
                    float _S1444 = resamplingTarget(_S1442);
                    passes_0 = _S1444 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1445 = Shift_x24init_0(_S1442, 1.0f);
                    _S1349 = int(0);
                    ended_0 = _S1445;
                    wavelength_10 = _S1417;
                    threshold_0 = width_6;
                    spectral_weight_1 = throughput_5;
                    layer_0 = b_9;
                    break;
                }
                _S1349 = int(0);
                ended_0 = _S1351;
                wavelength_10 = _S1417;
                threshold_0 = width_6;
                spectral_weight_1 = throughput_5;
                layer_0 = b_9;
                break;
            }
            if(_S1418)
            {
                Reservoir candidate_4 = _S1385;
                uint _S1446 = extractBits_0(_S1385.path, 24U, 8U);
                uint _S1447 = insertBits_0(0U, _S1446, 24U, 8U);
                uint _S1448 = extractBits_0(_S1385.path, 10U, 2U);
                bool _S1449 = _S1448 == 1U;
                if(_S1449)
                {
                    float3  _S1450 = safeDivide(_S1442, _S1350);
                    (&candidate_4)->radiance = _S1450;
                }
                else
                {
                    uint _S1451 = insertBits_0(_S1447, b_9 + 1U, 5U, 5U);
                    uint _S1452 = insertBits_0(_S1451, 2U, 10U, 2U);
                    (&candidate_4)->path = _S1452;
                }
                Reservoir _S1453 = withEnd(candidate_4, 0U, b_9, _S1442);
                offer(sel_8, _S1453, _S1442 * make_float3 (scale_4) / make_float3 (density_3));
                float _S1454 = survivalProbability(abs_0(throughput_5), density_3);
                uint _S1455 = (fcptMaxBounces());
                bool _S1456 = b_9 >= _S1455;
                if(_S1456)
                {
                    _S1348 = true;
                }
                else
                {
                    bool _S1457 = _S1454 < 1.0f;
                    if(_S1457)
                    {
                        uint _S1458 = noiseAddress(_S1378, b_9);
                        Random _S1459 = draw(_S1458, 8U);
                        _S1348 = _S1454 < (_S1459.value);
                    }
                    else
                    {
                        _S1348 = false;
                    }
                }
                if(_S1348)
                {
                    _S1349 = int(0);
                    ended_0 = _S1351;
                    wavelength_10 = _S1417;
                    threshold_0 = width_6;
                    spectral_weight_1 = throughput_5;
                    layer_0 = b_9;
                    break;
                }
                float _S1460 = density_3 * _S1454;
                density_3 = _S1460;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1461 = noiseAddress(_S1378, b_9);
            float3  _S1462 = samplePhase_0(g_in_0, (&ray_3)->unit_direction, _S1461, &phase_pdf_0);
            (&ray_3)->unit_direction = _S1462;
            NEEVertex _S1463 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_3)->origin, _S1350, (&ray_3)->origin);
            nee_vertex_1 = _S1463;
            Vertex _S1464 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, false);
            prev_1 = _S1464;
            float _S1465 = (&prev_1)->pdf;
            FKRay _S1466 = ray_3;
            FKHit _S1467 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1468 = (fcptTraverseInstanceBVH((_S1466), (true), (4.294967296e+09f), (false), (_S1467), (false)));
            hit_4 = _S1468;
            b_7 = b_9;
            throughput_3 = throughput_5;
            spread_1 = _S1417;
            width_3 = width_6;
            sky_pdf_1 = _S1465;
        }
        if(_S1349 != int(1))
        {
            spread_1 = wavelength_10;
            width_3 = threshold_0;
            throughput_3 = spectral_weight_1;
            b_7 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1351;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1469 = b_7 == 4294967295U;
    bool _S1470 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1470)
    {
        Reservoir _S1471 = chain_1;
        FKRay _S1472 = ray_3;
        Vertex _S1473 = prev_1;
        NEEVertex _S1474 = nee_vertex_1;
        Shift _S1475 = escape_0(r_9, replay_2, _S1366, _S1355, _S1353, _S1356, scale_4, _S1380, &_S1471, _S1350, b_7, &_S1472, throughput_3, density_3, &_S1473, &_S1474, sky_pdf_1, throughput_4, 0.0f, sel_8);
        return _S1475;
    }
    FKHit _S1476 = hit_4;
    uint _S1477 = filling_2;
    float3  _S1478 = scatter_in_0;
    float3  _S1479 = extinction_in_0;
    float3  _S1480 = weight_2;
    float3  _S1481 = glowed_0;
    float3  _S1482 = (&ray_3)->origin + make_float3 (_S1476.distance) * (&ray_3)->unit_direction;
    (&ray_3)->origin = _S1482;
    bool _S1483 = (fcptVaryingUsed());
    if(_S1483)
    {
        passes_0 = _S1477 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1484 = !replay_2;
        if(_S1484)
        {
            float3  _S1485 = pathColor(throughput_3 * _S1481, throughput_4, 0.0f);
            float3  _S1486 = _S1485 / make_float3 (density_3);
            float3  _S1487 = sel_8->glow + _S1486;
            sel_8->glow = _S1487;
        }
        else
        {
        }
        float3  _S1488 = throughput_3 * _S1480;
        throughput_3 = _S1488;
    }
    else
    {
        float3  _S1489 = flightWeight_0(_S1478, _S1479, _S1476.distance, false);
        float3  _S1490 = throughput_3 * _S1489;
        throughput_3 = _S1490;
    }
    float width_7 = width_3 + spread_1 * _S1476.distance;
    uint _S1491 = b_7 + 1U;
    b_7 = _S1491;
    layer_0 = 0U;
    width_3 = width_7;
    passes_0 = false;
    wavelength_10 = 0.0f;
    threshold_0 = 0.0f;
    turned_1 = false;
    is_inside_6 = false;
    spectral_weight_1 = throughput_4;
    float3  chain_throughput_1 = _S1350;
    float3  reconnection_0 = _S1350;
    viewed_0 = _S1469;
    for(;;)
    {
        bool _S1492 = ((&hit_4)->is_point_light) == 1U;
        if(replay_2)
        {
            _S1346 = _S1355 == 1U;
        }
        else
        {
            _S1346 = false;
        }
        if(_S1346)
        {
            _S1347 = b_7 == _S1354;
        }
        else
        {
            _S1347 = false;
        }
        if(_S1347)
        {
            bool _S1493 = ((&hit_4)->instance_index) != (_S1367.instance_index);
            if(_S1493)
            {
                _S1348 = true;
            }
            else
            {
                _S1348 = ((&hit_4)->triangle_index) != (_S1367.triangle_index);
            }
        }
        else
        {
            _S1348 = false;
        }
        if(_S1348)
        {
            return _S1351;
        }
        FKMedium _S1494 = Medium_x24init_0(_S1350, _S1350, 0.0f);
        BSDFMaterial _S1495 = Material_x24init_0(_S1350, _S1350, 0.0f, 0.0f, 0.0f, 0.0f, _S1350, throughput_4, 1.0f, _S1350, _S1350, 0.5f, 0.0f, 0.0f, _S1350, 0.0f, _S1350, 0.0f);
        FKMedium _S1496 = _S1494;
        FKSurface _S1497 = Surface_x24init_0(_S1350, _S1350, 0.0f, &_S1495, false, 0U, 1.0f, false, &_S1496, 4294967295U, _S1350);
        bool _S1498 = !_S1492;
        bool scatter_2;
        bool is_inside_7;
        float3  throughput_6;
        float3  front_n_0;
        float geometry_density_0;
        FKSurface surface_13;
        if(_S1498)
        {
            uint _S1499 = noiseAddress(_S1378, b_7);
            uint _S1500 = arrivalLobe_0(b_7, (&prev_1)->lobe);
            FKSurface _S1501 = (fcptSurfaceAtPath((hit_4), ((&ray_3)->origin), (_S1499), (width_3), (layer_0), (b_7), (_S1500), ((&ray_3)->unit_direction)));
            bool _S1502 = !passes_0;
            FKSurface _S1503 = _S1501;
            FKSurface _S1504 = emitting_0(&_S1503, _S1502);
            uint _S1505 = noiseAddress(_S1378, b_7);
            Random _S1506 = draw(_S1505, 9U);
            FKSurface _S1507 = _S1504;
            FKSurface _S1508 = uncovered_0(&_S1507, _S1506.value);
            float _S1509 = facingSign(_S1508.material.transmission, _S1508.geometry_n, (&ray_3)->unit_direction);
            bool _S1510 = _S1509 < 0.0f;
            bool _S1511 = (_S1508.material.transmission) > 0.0f;
            if(_S1511)
            {
                bool _S1512 = arrivesBehind_0((&ray_3)->unit_direction, _S1508.geometry_n);
                scatter_2 = _S1512;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1513 = _S1508;
            FKSurface _S1514 = facingRay_0(&_S1513, (&ray_3)->unit_direction);
            if(passes_0)
            {
                bool _S1515 = arrivesBehind_0((&ray_3)->unit_direction, _S1514.geometry_n);
                is_inside_7 = _S1515;
            }
            else
            {
                is_inside_7 = scatter_2;
            }
            if(is_inside_7)
            {
                float _S1516 = (&hit_4)->distance;
                float _S1517 = upsample(_S1514.material.absorption, wavelength_10);
                float3  _S1518 = make_float3 (_S1517);
                bool _S1519 = wavelength_10 > 0.0f;
                float3  _S1520 = _slang_select(_S1519, _S1518,_S1514.material.absorption);
                float3  _S1521 = beerLambert(_S1516, _S1520);
                float3  _S1522 = throughput_3 * _S1521;
                throughput_6 = _S1522;
            }
            else
            {
                throughput_6 = throughput_3;
            }
            bool _S1523 = !_S1514.skip;
            float geometry_density_1 = (F32_abs((dot_0(_S1514.geometry_n, (&ray_3)->unit_direction)))) / ((&hit_4)->distance * (&hit_4)->distance);
            bool _S1524 = b_7 == _S1491;
            if(_S1524)
            {
                float _S1525 = 0.00251327408477664f / geometry_density_1;
                geometry_density_0 = _S1525;
            }
            else
            {
                geometry_density_0 = threshold_0;
            }
            float _S1526 = geometry_density_0;
            scatter_2 = _S1523;
            geometry_density_0 = geometry_density_1;
            threshold_0 = _S1526;
            surface_13 = _S1514;
            front_n_0 = _S1508.smooth_n;
            turned_1 = _S1510;
        }
        else
        {
            scatter_2 = false;
            geometry_density_0 = 0.0f;
            surface_13 = _S1497;
            throughput_6 = throughput_3;
            front_n_0 = _S1350;
            is_inside_7 = is_inside_6;
        }
        bool _S1527;
        if(scatter_2)
        {
            _S1527 = (&prev_1)->rough;
        }
        else
        {
            _S1527 = false;
        }
        bool _S1528;
        if(_S1527)
        {
            _S1528 = ((&prev_1)->pdf * geometry_density_0 * threshold_0) <= 1.0f;
        }
        else
        {
            _S1528 = false;
        }
        FKSurface _S1529 = surface_13;
        float _S1530 = dot_0(surface_13.smooth_n, - (&ray_3)->unit_direction);
        bool _S1531 = (fcptDispersionUsed());
        bool _S1532;
        if(_S1531)
        {
            _S1532 = wavelength_10 == 0.0f;
        }
        else
        {
            _S1532 = false;
        }
        bool _S1533;
        if(_S1532)
        {
            _S1533 = scatter_2;
        }
        else
        {
            _S1533 = false;
        }
        bool _S1534;
        if(_S1533)
        {
            bool _S1535 = dispersive(surface_13.material);
            _S1534 = _S1535;
        }
        else
        {
            _S1534 = false;
        }
        float3  throughput_7;
        if(_S1534)
        {
            uint _S1536 = stream(_S1378, 512U);
            Random _S1537 = pcg(_S1536);
            uint _S1538 = extractBits_0(_S1352, 25U, 7U);
            float _S1539 = (float(_S1538) + _S1537.value) / 128.0f;
            uint _S1540 = extractBits_0(_S1352, 24U, 1U);
            bool _S1541 = _S1540 == 1U;
            float _S1542 = _slang_select(_S1541, _S1539,_S1537.value);
            float2  _S1543 = sampleWavelength(_S1542);
            float wavelength_11 = _S1543.x;
            float3  _S1544 = wavelengthWeights(wavelength_11);
            float3  _S1545 = _S1544 / make_float3 (_S1543.y);
            float _S1546 = upsample(throughput_6, wavelength_11);
            float3  _S1547 = make_float3 (_S1546);
            float _S1548 = upsample(scatter_in_0, wavelength_11);
            float3  _S1549 = make_float3 (_S1548);
            scatter_in_0 = _S1549;
            float _S1550 = upsample(extinction_in_0, wavelength_11);
            float3  _S1551 = make_float3 (_S1550);
            extinction_in_0 = _S1551;
            wavelength_10 = wavelength_11;
            throughput_7 = _S1547;
            spectral_weight_1 = _S1545;
        }
        else
        {
            throughput_7 = throughput_6;
        }
        BSDFMaterial _S1552 = pathMaterial(surface_13.material, wavelength_10);
        float2  _S1553 = wavelengthEta(_S1552, _S1530, wavelength_10);
        bool _S1554;
        if(scatter_2)
        {
            uint _S1555 = (fcptMaxBounces());
            bool _S1556 = b_7 >= _S1555;
            if(_S1556)
            {
                _S1554 = true;
            }
            else
            {
                bool _S1557 = neeDecision(_S1552, _S1530, _S1553.x, _S1553.y);
                _S1554 = _S1557;
            }
        }
        else
        {
            _S1554 = false;
        }
        bool _S1558;
        if(passes_0)
        {
            _S1558 = true;
        }
        else
        {
            _S1558 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1558)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1554;
        }
        bool _S1559 = (fcptHairUsed());
        bool _S1560;
        if(_S1559)
        {
            float3  _S1561 = surface_13.hair;
            _S1560 = (dot_0(_S1561, _S1561)) > 0.0f;
        }
        else
        {
            _S1560 = false;
        }
        bool _S1562;
        if(_S1560)
        {
            _S1562 = true;
        }
        else
        {
            BSDFMaterial _S1563 = _S1552;
            bool _S1564 = isTranslucent_0(&_S1563);
            _S1562 = _S1564;
        }
        bool _S1565;
        if(_S1562)
        {
            _S1565 = true;
        }
        else
        {
            bool _S1566 = (_S1552.transmission) > 0.0f;
            if(_S1566)
            {
                uint _S1567 = (fcptLayers((hit_4)));
                _S1565 = _S1567 == 1U;
            }
            else
            {
                _S1565 = false;
            }
        }
        float3  _S1568 = emitted_0(_S1552.emissive, (&ray_3)->unit_direction, front_n_0);
        float3  emission_0;
        if(_S1492)
        {
            float3  _S1569 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1569;
        }
        else
        {
            emission_0 = _S1568;
        }
        bool _S1570 = !replay_2;
        bool _S1571;
        if(_S1570)
        {
            _S1571 = true;
        }
        else
        {
            _S1571 = b_7 >= _S1366;
        }
        bool _S1572;
        if(_S1571)
        {
            float _S1573 = rgb_to_greyscale(emission_0);
            _S1572 = _S1573 > 0.0f;
        }
        else
        {
            _S1572 = false;
        }
        float3  emission_1;
        if(_S1572)
        {
            NEEVertex _S1574 = nee_vertex_1;
            FKHit _S1575 = hit_4;
            float _S1576 = emissionWeight_0(&_S1574, &_S1575, (&ray_3)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1576);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1577;
        if(replay_2)
        {
            _S1577 = _S1355 == 1U;
        }
        else
        {
            _S1577 = false;
        }
        bool _S1578;
        if(_S1577)
        {
            _S1578 = b_7 > _S1354;
        }
        else
        {
            _S1578 = false;
        }
        bool _S1579;
        if(_S1578)
        {
            _S1579 = b_7 == _S1353;
        }
        else
        {
            _S1579 = false;
        }
        bool _S1580;
        if(_S1579)
        {
            bool _S1581 = _S1356 == 1U;
            if(_S1581)
            {
                _S1580 = true;
            }
            else
            {
                _S1580 = _S1356 == 2U;
            }
        }
        else
        {
            _S1580 = false;
        }
        if(_S1580)
        {
            bool _S1582 = _S1492 != (_S1356 == 2U);
            if(_S1582)
            {
                return _S1351;
            }
            float3  _S1583 = pathColor(throughput_7 * emission_1, spectral_weight_1, wavelength_10);
            return Shift_x24init_0(_S1583 / make_float3 (r_9->jac), density_3 / r_9->jac);
        }
        uint _S1584 = extractBits_0((&chain_1)->path, 10U, 2U);
        bool _S1585 = _S1584 == 1U;
        Reservoir here_0 = chain_1;
        uint _S1586 = insertBits_0(_S1380, b_7, 5U, 5U);
        uint _S1587 = insertBits_0(_S1586, 1U, 10U, 2U);
        uint _S1588 = insertBits_0(_S1587, (&prev_1)->lobe, 15U, 3U);
        bool _S1589 = (&prev_1)->inside;
        uint _S1590 = _slang_select(_S1589, 1U,0U);
        uint _S1591 = insertBits_0(_S1588, _S1590, 22U, 1U);
        (&here_0)->path = _S1591;
        uint _S1592 = (&here_0)->path;
        bool _S1593 = wavelength_10 > 0.0f;
        uint _S1594 = _slang_select(_S1593, 1U,0U);
        uint _S1595 = insertBits_0(_S1592, _S1594, 23U, 1U);
        (&here_0)->path = _S1595;
        float _S1596 = (&prev_1)->pdf * geometry_density_0;
        (&here_0)->jac = _S1596;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1597;
        if(replay_2)
        {
            _S1597 = _S1355 == 1U;
        }
        else
        {
            _S1597 = false;
        }
        bool _S1598;
        if(_S1597)
        {
            _S1598 = b_7 == _S1354;
        }
        else
        {
            _S1598 = false;
        }
        bool _S1599 = b_7 == _S1366;
        bool _S1600;
        if(_S1599)
        {
            bool _S1601 = !scatter_2;
            if(_S1601)
            {
                _S1600 = true;
            }
            else
            {
                bool _S1602 = _S1355 != 1U;
                if(_S1602)
                {
                    _S1600 = _S1355 != 3U;
                }
                else
                {
                    _S1600 = false;
                }
            }
        }
        else
        {
            _S1600 = false;
        }
        bool _S1603;
        if(_S1600)
        {
            _S1603 = _S1355 == 2U;
        }
        else
        {
            _S1603 = false;
        }
        bool _S1604;
        if(_S1603)
        {
            _S1604 = !_S1528;
        }
        else
        {
            _S1604 = false;
        }
        bool _S1605;
        if(_S1604)
        {
            _S1605 = _S1356 != 4U;
        }
        else
        {
            _S1605 = false;
        }
        bool _S1606 = _S1354 == _S1353;
        bool _S1607;
        if(_S1606)
        {
            _S1607 = _S1356 == 0U;
        }
        else
        {
            _S1607 = false;
        }
        bool _S1608;
        if(_S1607)
        {
            _S1608 = ((&hit_4)->instance_index) == (_S1367.instance_index);
        }
        else
        {
            _S1608 = false;
        }
        bool _S1609;
        if(_S1608)
        {
            _S1609 = ((&hit_4)->triangle_index) == (_S1367.triangle_index);
        }
        else
        {
            _S1609 = false;
        }
        bool _S1610;
        if(_S1609)
        {
            _S1610 = _S1528;
        }
        else
        {
            _S1610 = false;
        }
        bool _S1611 = _slang_select(_S1598, _S1610,_S1605);
        bool _S1612;
        if(nee_0)
        {
            _S1612 = _slang_select(replay_2, _S1611,scatter_2);
        }
        else
        {
            _S1612 = false;
        }
        TreeSample _S1613 = TreeSample_x24init_0(_S1350, _S1350, 0.0f, 0U);
        uint2  _S1614 = make_uint2 (0U);
        float2  _S1615 = make_float2 (0.0f);
        FKHit _S1616 = Hit_x24init_0(_S1615, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1617 = _S1616;
        ShadowContext _S1618 = ShadowContext_x24init_0(_S1350, _S1350, _S1614, _S1350, 0U, 0U, false, 0.0f, 0.0f, &_S1617, false);
        bool _S1619;
        if(nee_0)
        {
            _S1619 = _S1571;
        }
        else
        {
            _S1619 = false;
        }
        ShadowContext context_5;
        if(_S1619)
        {
            uint _S1620 = arrivalLobe_0(b_7, (&prev_1)->lobe);
            FKMedium _S1621 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1622 = surface_13;
            FKHit _S1623 = hit_4;
            FKMedium _S1624 = _S1621;
            ShadowContext _S1625 = shadowContext_0(&_S1622, turned_1, extinction_in_0, filling_2, (&ray_3)->unit_direction, b_7, _S1620, (&hit_4)->distance, width_3, &_S1623, _S1560, &_S1624);
            context_5 = _S1625;
        }
        else
        {
            context_5 = _S1618;
        }
        float3  throughput_8;
        float3  lit_0;
        if(_S1612)
        {
            float3  _S1626 = (&ray_3)->origin;
            if(_S1560)
            {
                throughput_8 = _S1350;
            }
            else
            {
                throughput_8 = _S1529.smooth_n;
            }
            FKSurface _S1627 = surface_13;
            uint _S1628 = noiseAddress(_S1378, b_7);
            ShadowContext _S1629 = context_5;
            TreeSample _S1630 = sampleLightTree_0(_S1626, throughput_8, surface_13.geometry_n, surface_13.geometry_offset, _S1565, _S1628, &_S1629);
            bool _S1631 = any_1((_S1630.radiance) != _S1350);
            if(_S1631)
            {
                if(_S1560)
                {
                    uint _S1632 = (fcptMaxBounces());
                    bool _S1633 = b_7 < _S1632;
                    FKSurface _S1634 = surface_13;
                    TreeSample _S1635 = _S1630;
                    float3  _S1636 = hairLight_0(&_S1634, (&ray_3)->unit_direction, &_S1635, _S1633);
                    lit_0 = _S1636;
                }
                else
                {
                    float _S1637 = _S1553.x;
                    float _S1638 = _S1553.y;
                    uint _S1639 = (fcptMaxBounces());
                    bool _S1640 = b_7 < _S1639;
                    TreeSample _S1641 = _S1630;
                    BSDFMaterial _S1642 = _S1552;
                    float3  _S1643 = lightBSDF_0((&ray_3)->unit_direction, &_S1641, _S1529.smooth_n, _S1627.geometry_n, &_S1642, _S1637, _S1638, _S1640, surface_13.random_state);
                    lit_0 = _S1643;
                }
            }
            else
            {
                lit_0 = _S1350;
            }
            light_3 = _S1630;
        }
        else
        {
            light_3 = _S1613;
            lit_0 = _S1350;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1644;
        bool _S1645;
        float density_5;
        if(_S1598)
        {
            bool _S1646 = !_S1528;
            if(_S1646)
            {
                return _S1351;
            }
            uint _S1647 = extractBits_0(_S1352, 23U, 1U);
            bool _S1648 = _S1593 != (_S1647 == 1U);
            if(_S1648)
            {
                return _S1351;
            }
            float3  throughput_9 = throughput_7 * make_float3 (geometry_density_0);
            float density_6 = density_3 * geometry_density_0;
            if(_S1606)
            {
                viewed_1 = _S1356 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                float3  _S1649 = pathColor(throughput_9 * emission_1, spectral_weight_1, wavelength_10);
                return Shift_x24init_0(_S1649 / make_float3 (r_9->jac), density_6 / r_9->jac);
            }
            if(_S1606)
            {
                refracted_4 = _S1356 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S1650 = !nee_0;
                if(_S1650)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1651 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1651 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1351;
                }
                float3  _S1652 = pathColor(throughput_9 * lit_0, spectral_weight_1, wavelength_10);
                return Shift_x24init_0(_S1652 / make_float3 (r_9->jac), density_6 / r_9->jac);
            }
            if(_S1606)
            {
                wrong_side_0 = _S1356 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1653 = !nee_0;
                if(_S1653)
                {
                    return _S1351;
                }
                bool _S1654 = (fcptWorldReadsPath());
                if(_S1654)
                {
                    float _S1655 = environmentPdf_0(r_9->dir);
                    uint _S1656 = b_7 + 1U;
                    FKSurface _S1657 = surface_13;
                    float3  _S1658 = skyColor_0((&ray_3)->unit_direction, r_9->dir, &_S1657, wavelength_10, _S1553, is_inside_7, _S1655, surface_13.random_state, _S1656);
                    float3  _S1659 = pathColor(throughput_9 * (_S1658 * r_9->radiance), spectral_weight_1, wavelength_10);
                    return Shift_x24init_0(_S1659 / make_float3 (r_9->jac), density_6 / r_9->jac);
                }
                float _S1660 = environmentPdf_0(r_9->dir);
                float3  _S1661 = skyBSDF((&ray_3)->unit_direction, r_9->dir, surface_13, _S1552, _S1553, is_inside_7, _S1660, surface_13.random_state);
                float3  _S1662 = pathColor(throughput_9 * _S1661 * r_9->radiance, spectral_weight_1, wavelength_10);
                return Shift_x24init_0(_S1662 / make_float3 (r_9->jac), density_6 / r_9->jac);
            }
            uint _S1663 = extractBits_0(_S1352, 21U, 1U);
            bool _S1664 = nee_0 != (_S1663 == 1U);
            if(_S1664)
            {
                return _S1351;
            }
            throughput_8 = throughput_9;
            density_5 = density_6;
        }
        else
        {
            if(replay_2)
            {
                viewed_1 = _S1599;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1665 = !scatter_2;
                if(_S1665)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1666 = _S1355 != 1U;
                    if(_S1666)
                    {
                        refracted_4 = _S1355 != 3U;
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
                bool _S1667 = _S1355 == 2U;
                if(_S1667)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1528;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1356 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1560)
                    {
                        return _S1351;
                    }
                    uint _S1668 = noiseAddress(_S1378, b_7);
                    FKRay _S1669 = ray_3;
                    FKSurface _S1670 = surface_13;
                    ShadowContext _S1671 = context_5;
                    SkySample _S1672 = sampleSky_0(&_S1669, &_S1670, wavelength_10, _S1553, is_inside_7, _S1668, surface_13.random_state, &_S1671);
                    float3  _S1673 = pathColor(throughput_7 * _S1672.color, spectral_weight_1, wavelength_10);
                    return Shift_x24init_0(_S1673, 1.0f);
                }
                if(_S1667)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1528;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1674 = rgb_to_greyscale(light_3.radiance);
                    bool _S1675 = !(_S1674 > 0.0f);
                    if(_S1675)
                    {
                        return _S1351;
                    }
                    float3  _S1676 = pathColor(throughput_7 * lit_0, spectral_weight_1, wavelength_10);
                    return Shift_x24init_0(_S1676, 1.0f);
                }
                if(_S1365)
                {
                    passes_0 = _S1356 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1492;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float3  _S1677 = pathColor(throughput_7 * emission_1, spectral_weight_1, wavelength_10);
                    return Shift_x24init_0(_S1677, 1.0f);
                }
                if(_S1365)
                {
                    passes_0 = _S1356 == 1U;
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
                    passes_0 = !_S1528;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float3  _S1678 = pathColor(throughput_7 * emission_1, spectral_weight_1, wavelength_10);
                    return Shift_x24init_0(_S1678, 1.0f);
                }
                return _S1351;
            }
            else
            {
                if(_S1570)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1679 = b_7 > 0U;
                    if(_S1679)
                    {
                        Reservoir candidate_5 = chain_1;
                        if(_S1585)
                        {
                            float3  _S1680 = safeDivide(throughput_7 * emission_1, chain_throughput_1);
                            (&candidate_5)->radiance = _S1680;
                        }
                        else
                        {
                            if(_S1528)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1681 = pathColor(throughput_7 * emission_1, spectral_weight_1, wavelength_10);
                        Reservoir _S1682 = withEnd(candidate_5, 1U, b_7, _S1681);
                        offer(sel_8, _S1682, _S1681 * make_float3 (scale_4) / make_float3 (density_3));
                    }
                    else
                    {
                        float3  _S1683 = pathColor(throughput_7 * emission_1, spectral_weight_1, wavelength_10);
                        float3  _S1684 = sel_8->glow + _S1683;
                        sel_8->glow = _S1684;
                    }
                    if(nee_0)
                    {
                        float3  _S1685 = pathColor(throughput_7 * lit_0, spectral_weight_1, wavelength_10);
                        Reservoir candidate_6 = chain_1;
                        if(_S1585)
                        {
                            float3  _S1686 = safeDivide(_S1685, chain_throughput_1);
                            (&candidate_6)->radiance = _S1686;
                        }
                        else
                        {
                            if(_S1528)
                            {
                                candidate_6 = here_0;
                                uint _S1687 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1687;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1688 = insertBits_0(_S1380, b_7 + 1U, 5U, 5U);
                                uint _S1689 = insertBits_0(_S1688, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1689;
                            }
                        }
                        Reservoir _S1690 = withEnd(candidate_6, 0U, b_7, _S1685);
                        offer(sel_8, _S1690, _S1685 * make_float3 (scale_4) / make_float3 (density_3));
                    }
                    if(nee_0)
                    {
                        if(_S1560)
                        {
                            _S1644 = false;
                        }
                        else
                        {
                            bool _S1691 = environmentMapped_0();
                            _S1644 = _S1691;
                        }
                    }
                    else
                    {
                        _S1644 = false;
                    }
                    if(_S1644)
                    {
                        uint _S1692 = (fcptMaxBounces());
                        _S1645 = b_7 < _S1692;
                    }
                    else
                    {
                        _S1645 = false;
                    }
                    if(_S1645)
                    {
                        uint _S1693 = noiseAddress(_S1378, b_7);
                        FKRay _S1694 = ray_3;
                        FKSurface _S1695 = surface_13;
                        ShadowContext _S1696 = context_5;
                        SkySample _S1697 = sampleSky_0(&_S1694, &_S1695, wavelength_10, _S1553, is_inside_7, _S1693, surface_13.random_state, &_S1696);
                        float3  _S1698 = pathColor(throughput_7 * _S1697.color, spectral_weight_1, wavelength_10);
                        Reservoir candidate_7 = chain_1;
                        if(_S1585)
                        {
                            float3  _S1699 = safeDivide(_S1698, chain_throughput_1);
                            (&candidate_7)->radiance = _S1699;
                        }
                        else
                        {
                            if(_S1528)
                            {
                                candidate_7 = here_0;
                                uint _S1700 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1700;
                                (&candidate_7)->dir = _S1697.dir;
                                (&candidate_7)->radiance = _S1697.radiance;
                            }
                            else
                            {
                                uint _S1701 = insertBits_0(_S1380, b_7 + 1U, 5U, 5U);
                                uint _S1702 = insertBits_0(_S1701, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1702;
                            }
                        }
                        Reservoir _S1703 = withEnd(candidate_7, 4U, b_7, _S1698);
                        offer(sel_8, _S1703, _S1698 * make_float3 (scale_4) / make_float3 (density_3));
                    }
                }
            }
            throughput_8 = throughput_7;
            density_5 = density_3;
        }
        bool _S1704;
        bool _S1705;
        bool _S1706;
        bool straight_0;
        bool _S1707;
        bool _S1708;
        bool _S1709;
        bool _S1710;
        bool _S1711;
        bool _S1712;
        bool _S1713;
        bool _S1714;
        bool _S1715;
        bool _S1716;
        bool _S1717;
        bool _S1718;
        bool _S1719;
        bool _S1720;
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
                viewed_1 = _S1599;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1721 = extractBits_0(_S1352, 15U, 3U);
            uint _S1722 = extractBits_0(_S1352, 18U, 3U);
            uint _S1723 = _slang_select(_S1598, _S1722,_S1721);
            float3  _S1724 = r_9->dir;
            bool refracted_5 = _S1723 == 1U;
            SampleBSDF _S1725 = SampleBSDF_x24init_0(_S1350, _S1350, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1725;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1726 = extractBits_0(_S1352, 22U, 1U);
                bool _S1727 = is_inside_7 != (_S1726 == 1U);
                if(_S1727)
                {
                    return _S1351;
                }
                bool _S1728 = _S1355 == 1U;
                if(_S1728)
                {
                    float3  _S1729 = (fcptHitPosition((_S1367)));
                    throughput_10 = _S1729;
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
                    BSDFMaterial _S1730 = _S1552;
                    bool _S1731 = isTranslucent_0(&_S1730);
                    if(_S1731)
                    {
                        refracted_4 = _S1723 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1732 = throughput_10 - (&ray_3)->origin;
                        float3  _S1733 = _slang_select(_S1728, _S1732,_S1724);
                        wrong_side_0 = (dot_0(_S1529.smooth_n, _S1733) * _S1530) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1728)
                {
                    float3  _S1734 = (&ray_3)->origin;
                    FKSurface _S1735 = surface_13;
                    float3  _S1736 = - _S1529.smooth_n;
                    bool _S1737 = is_inside_7 != refracted_4;
                    float3  _S1738 = _slang_select(_S1737, _S1736,_S1529.smooth_n);
                    float3  _S1739 = throughput_10 - (_S1734 + make_float3 (_S1735.geometry_offset) * _S1738);
                    float3  _S1740 = ((((_S1739)) * make_float3(rnorm3df(((_S1739)).x, ((_S1739)).y, ((_S1739)).z))));
                    reconnection_1 = _S1740;
                }
                else
                {
                    reconnection_1 = _S1724;
                }
                if(_S1560)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1741 = wrongSide_0(is_inside_7, refracted_4, reconnection_1, surface_13.geometry_n);
                    wrong_side_0 = _S1741;
                }
                if(wrong_side_0)
                {
                    return _S1351;
                }
                float3  _S1742 = throughput_10;
                throughput_10 = reconnection_1;
                b_10 = _S1723;
                wrong_side_0 = false;
                reconnection_1 = _S1742;
            }
            else
            {
                bool _S1743 = !_S1598;
                if(_S1743)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1744;
                    if(_S1560)
                    {
                        SampleBSDF _S1745 = (fcptSampleHair((surface_13.hair), (_S1552.albedo), (_S1552.specular_tint), ((&ray_3)->unit_direction), (surface_13.random_state)));
                        _S1744 = _S1745;
                    }
                    else
                    {
                        SampleBSDF _S1746 = sampleBSDF((&ray_3)->unit_direction, _S1529.smooth_n, _S1552, _S1553.x, _S1553.y, surface_13.random_state, _S1615);
                        _S1744 = _S1746;
                    }
                    bsdf_sampled_0 = _S1744;
                    if(_S1560)
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
                            return _S1351;
                        }
                        break;
                    }
                    if(_S1560)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1747 = wrongSide_0(is_inside_7, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_13.geometry_n);
                        wrong_side_0 = _S1747;
                    }
                    if(wrong_side_0)
                    {
                        _S1644 = (_S1552.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1644 = false;
                    }
                    if(_S1644)
                    {
                        SampleBSDF _S1748 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_13.geometry_n, _S1552, _S1553.x, _S1553.y, (&bsdf_sampled_0)->random_state, _S1615);
                        (&bsdf_sampled_0)->unit_direction = _S1748.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1748.refracted;
                        (&bsdf_sampled_0)->throughput = _S1748.throughput;
                        (&bsdf_sampled_0)->lobe = _S1748.lobe;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1749 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_13.geometry_n)) * surface_13.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1749;
                        }
                    }
                    uint _S1750 = (&bsdf_sampled_0)->lobe;
                    float3  _S1751 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1752 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1753 = (&bsdf_sampled_0)->pdf;
                    float _S1754 = _slang_select(wrong_side_0, 0.0f,_S1753);
                    (&lobe_5)->pdf = _S1754;
                    throughput_10 = _S1751;
                    b_10 = _S1750;
                    refracted_4 = _S1752;
                }
                else
                {
                    throughput_10 = _S1724;
                    b_10 = _S1723;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1644 = true;
            }
            else
            {
                _S1644 = _S1598;
            }
            float3  chain_throughput_2;
            if(_S1644)
            {
                if(_S1560)
                {
                    SampleBSDF _S1755 = (fcptConnectHair((surface_13.hair), (_S1552.albedo), (_S1552.specular_tint), ((&ray_3)->unit_direction), (throughput_10)));
                    lobe_5 = _S1755;
                }
                else
                {
                    float3  _S1756 = (&ray_3)->unit_direction;
                    float3  _S1757 = negate_0(_S1756);
                    float _S1758 = sign_0(_S1530);
                    float3  _S1759 = _S1529.smooth_n * make_float3 (_S1758);
                    float _S1760 = dot_0(_S1759, throughput_10);
                    float _S1761 = _S1552.roughness;
                    float _S1762 = _S1761 * _S1761;
                    AnisotropicFrame _S1763 = anisotropicFrame(_S1552, _S1759);
                    SheenProfile _S1764 = sheenProfile(_S1757, _S1759, _S1552);
                    float3  _S1765 = reflectedHalf(_S1756, throughput_10);
                    bool _S1766 = b_10 == 1U;
                    if(_S1766)
                    {
                        float3  _S1767 = refractedHalf(_S1756, throughput_10, _S1529.smooth_n, _S1553.x, _S1553.y);
                        throughput_11 = _S1767;
                    }
                    else
                    {
                        throughput_11 = _S1765;
                    }
                    bool _S1768 = b_10 == 0U;
                    if(_S1768)
                    {
                        _S1645 = true;
                    }
                    else
                    {
                        _S1645 = b_10 == 6U;
                    }
                    if(_S1645)
                    {
                        float3  _S1769 = sampledHalf(_S1757, _S1759, _S1762, _S1763, surface_13.random_state);
                        throughput_12 = _S1769;
                    }
                    else
                    {
                        throughput_12 = throughput_11;
                    }
                    float _S1770 = _S1553.x;
                    float _S1771 = _S1553.y;
                    Weights _S1772 = lobeWeights(_S1756, _S1757, _S1759, throughput_12, _S1763, _S1764, _S1552, _S1770, _S1771);
                    float _S1773 = (F32_abs((_S1530)));
                    float _S1774 = vndfPDF(_S1757, throughput_12, _S1759, _S1773, _S1762, _S1763, _S1772.v_dot_h);
                    switch(b_10)
                    {
                    case 0U:
                        {
                            float _S1775 = diffusePDF(_S1760, _S1773, _S1552, _S1772);
                            float3  _S1776 = diffuseBSDF(throughput_10, _S1759, _S1552, _S1772);
                            density_7 = _S1775;
                            chain_throughput_2 = _S1776;
                            break;
                        }
                    case 1U:
                        {
                            float _S1777 = refractPDF(dot_0(throughput_10, throughput_12), _S1774, _S1772, _S1770, _S1771);
                            float3  _S1778 = refractBSDF(throughput_10, _S1759, _S1762, _S1763, _S1552, _S1772);
                            density_7 = _S1777;
                            chain_throughput_2 = _S1778;
                            break;
                        }
                    case 4U:
                        {
                            float _S1779 = sheenVelvetPDF(_S1760, _S1773, _S1772);
                            float3  _S1780 = sheenVelvetBSDF(throughput_10, _S1757, _S1759, _S1552, _S1772);
                            density_7 = _S1779;
                            chain_throughput_2 = _S1780;
                            break;
                        }
                    case 6U:
                        {
                            ToonProfile _S1781 = toonProfile(_S1757, _S1759, _S1552);
                            float _S1782 = toonPDF(throughput_10, _S1759, _S1781, _S1772);
                            float3  _S1783 = toonBSDF(throughput_10, _S1759, _S1781, _S1772);
                            density_7 = _S1782;
                            chain_throughput_2 = _S1783;
                            break;
                        }
                    default:
                        {
                            float _S1784 = reflectPDF(_S1774, _S1772);
                            float3  _S1785 = reflectBSDF(throughput_10, _S1759, _S1762, _S1763, _S1772);
                            density_7 = _S1784;
                            chain_throughput_2 = _S1785;
                            break;
                        }
                    }
                    bool _S1786 = density_7 > 0.0f;
                    if(_S1786)
                    {
                        SampleBSDF _S1787 = SampleBSDF_x24init_0(throughput_10, chain_throughput_2, surface_13.random_state, _S1766, b_10, density_7);
                        lobe_5 = _S1787;
                    }
                }
            }
            bool _S1788 = b_10 == 0U;
            if(_S1788)
            {
                _S1645 = true;
            }
            else
            {
                _S1645 = b_10 == 4U;
            }
            if(_S1645)
            {
                _S1704 = true;
            }
            else
            {
                _S1704 = b_10 == 6U;
            }
            if(_S1560)
            {
                _S1705 = false;
            }
            else
            {
                bool _S1789 = !_S1704;
                if(_S1789)
                {
                    bool _S1790 = (_S1552.roughness) == 0.0f;
                    if(_S1790)
                    {
                        _S1705 = true;
                    }
                    else
                    {
                        bool _S1791 = b_10 == 1U;
                        if(_S1791)
                        {
                            _S1705 = (_S1553.x) == (_S1553.y);
                        }
                        else
                        {
                            _S1705 = false;
                        }
                    }
                }
                else
                {
                    _S1705 = false;
                }
            }
            bool _S1792 = !_S1560;
            if(_S1792)
            {
                _S1706 = b_10 == 1U;
            }
            else
            {
                _S1706 = false;
            }
            if(_S1706)
            {
                straight_0 = (_S1552.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1707 = _S1792;
            }
            else
            {
                _S1707 = false;
            }
            if(_S1707)
            {
                _S1708 = b_10 == 1U;
            }
            else
            {
                _S1708 = false;
            }
            if(_S1708)
            {
                _S1709 = (_S1553.x) == (_S1553.y);
            }
            else
            {
                _S1709 = false;
            }
            BSDFMaterial _S1793 = _S1552;
            bool _S1794 = isTranslucent_0(&_S1793);
            if(_S1794)
            {
                _S1710 = _S1788;
            }
            else
            {
                _S1710 = false;
            }
            if(_S1710)
            {
                _S1711 = (dot_0(throughput_10, surface_13.geometry_n)) < 0.0f;
            }
            else
            {
                _S1711 = false;
            }
            if(nee_0)
            {
                _S1712 = !_S1705;
            }
            else
            {
                _S1712 = false;
            }
            if(_S1712)
            {
                _S1713 = !wrong_side_0;
            }
            else
            {
                _S1713 = false;
            }
            if(_S1713)
            {
                float _S1795 = (&lobe_5)->pdf;
                float3  _S1796 = (&ray_3)->origin;
                float3  _S1797 = _slang_select(_S1565, _S1350,_S1529.smooth_n);
                float3  _S1798 = (&ray_3)->origin;
                FKSurface _S1799 = surface_13;
                float3  _S1800 = - _S1529.smooth_n;
                float3  _S1801 = _slang_select(_S1711, _S1800,_S1529.smooth_n);
                NEEVertex _S1802 = NEEVertex_x24init_0(false, _S1795, _S1796, _S1797, _S1798 + make_float3 (_S1799.geometry_offset) * _S1801);
                nee_vertex_1 = _S1802;
            }
            else
            {
                if(_S1560)
                {
                    _S1714 = true;
                }
                else
                {
                    bool _S1803 = b_10 != 1U;
                    if(_S1803)
                    {
                        _S1714 = true;
                    }
                    else
                    {
                        _S1714 = (_S1553.x) != (_S1553.y);
                    }
                }
                if(_S1714)
                {
                    (&nee_vertex_1)->none = true;
                }
            }
            bool _S1804 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1804)
            {
                if(_S1704)
                {
                    _S1714 = true;
                }
                else
                {
                    _S1714 = ((&lobe_5)->pdf * (&prev_1)->cos / ((&hit_4)->distance * (&hit_4)->distance) * threshold_0) <= 1.0f;
                }
            }
            else
            {
                _S1714 = false;
            }
            bool _S1805 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1805)
            {
                if(_S1704)
                {
                    _S1715 = true;
                }
                else
                {
                    _S1715 = (_S1552.roughness) >= 0.20000000298023224f;
                }
            }
            else
            {
                _S1715 = false;
            }
            if(_S1598)
            {
                bool _S1806 = !_S1714;
                if(_S1806)
                {
                    return _S1351;
                }
                bool _S1807 = _S1356 != 1U;
                if(_S1807)
                {
                    _S1716 = _S1356 != 2U;
                }
                else
                {
                    _S1716 = false;
                }
                if(_S1716)
                {
                    float _S1808 = (&lobe_5)->pdf;
                    float _S1809 = _slang_select(nee_0, _S1808,0.0f);
                    float _S1810 = escapeWeight_0(_S1809, _S1724);
                    if(_S1606)
                    {
                        passes_0 = _S1362;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1811 = _slang_select(passes_0, _S1810,1.0f);
                    return Shift_x24init_0(throughput_8 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_9->radiance * make_float3 (_S1811) / make_float3 (r_9->jac), density_5 * (&lobe_5)->pdf / r_9->jac);
                }
                float3  _S1812 = throughput_8 * make_float3 ((&lobe_5)->pdf);
                float _S1813 = density_5 * (&lobe_5)->pdf;
                throughput_11 = _S1812;
                density_7 = _S1813;
            }
            else
            {
                throughput_11 = throughput_8;
                density_7 = density_5;
            }
            uint _S1814 = (fcptLayers((hit_4)));
            bool _S1815 = _S1814 > 1U;
            if(_S1815)
            {
                _S1716 = (b_10 == 1U) != passes_0;
            }
            else
            {
                _S1716 = false;
            }
            if(viewed_1)
            {
                _S1717 = _S1716;
            }
            else
            {
                _S1717 = false;
            }
            if(_S1717)
            {
                return _S1351;
            }
            if(replay_2)
            {
                _S1718 = b_7 <= _S1366;
            }
            else
            {
                _S1718 = false;
            }
            if(_S1718)
            {
                _S1719 = _S1528;
            }
            else
            {
                _S1719 = false;
            }
            if(_S1719)
            {
                _S1720 = _S1714;
            }
            else
            {
                _S1720 = false;
            }
            bool _S1816;
            if(_S1720)
            {
                _S1816 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1816 = !_S1715;
                }
                else
                {
                    _S1816 = false;
                }
            }
            if(_S1816)
            {
                return _S1351;
            }
            if(viewed_1)
            {
                float3  _S1817 = throughput_11 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1818 = (&lobe_5)->pdf;
                throughput_12 = _S1817;
                sky_pdf_3 = _S1818;
            }
            else
            {
                float3  _S1819 = throughput_11 * max_0((&lobe_5)->throughput, _S1350);
                throughput_12 = _S1819;
                sky_pdf_3 = density_7;
            }
            bool _S1820;
            if(_S1570)
            {
                _S1820 = !_S1585;
            }
            else
            {
                _S1820 = false;
            }
            bool _S1821;
            if(_S1820)
            {
                _S1821 = _S1528;
            }
            else
            {
                _S1821 = false;
            }
            bool _S1822;
            if(_S1821)
            {
                _S1822 = _S1714;
            }
            else
            {
                _S1822 = false;
            }
            if(_S1822)
            {
                chain_1 = here_0;
                uint _S1823 = insertBits_0((&chain_1)->path, b_10, 18U, 3U);
                uint _S1824 = _slang_select(nee_0, 1U,0U);
                uint _S1825 = insertBits_0(_S1823, _S1824, 21U, 1U);
                (&chain_1)->path = _S1825;
                float _S1826 = (&chain_1)->jac * (&lobe_5)->pdf;
                (&chain_1)->jac = _S1826;
                (&chain_1)->dir = throughput_10;
                chain_throughput_2 = throughput_12;
            }
            else
            {
                chain_throughput_2 = chain_throughput_1;
            }
            FKSurface _S1827 = surface_13;
            Vertex _S1828 = Vertex_x24init_0(_S1715, b_10, (&lobe_5)->pdf, (F32_abs((dot_0(surface_13.geometry_n, throughput_10)))), is_inside_7);
            prev_1 = _S1828;
            float _S1829 = (&lobe_5)->pdf;
            bool _S1830 = b_10 == 1U;
            bool _S1831;
            if(_S1830)
            {
                _S1831 = (_S1553.x) == (_S1553.y);
            }
            else
            {
                _S1831 = false;
            }
            float sky_pdf_4 = _slang_select(_S1831, sky_pdf_1,_S1829);
            float _S1832 = _slang_select(_S1560, 0.0f,sky_pdf_4);
            float _S1833 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * (&lobe_5)->pdf))))), (3.14159274101257324f)));
            bool _S1834 = !_S1705;
            float _S1835 = _slang_select(_S1834, _S1833,0.0f);
            float _S1836 = spread_1 + _S1835;
            bool _S1837;
            if(refracted_4)
            {
                _S1837 = !_S1711;
            }
            else
            {
                _S1837 = false;
            }
            bool is_inside_8;
            if(_S1837)
            {
                bool _S1838 = !is_inside_7;
                is_inside_8 = _S1838;
            }
            else
            {
                is_inside_8 = is_inside_7;
            }
            FKSurface _S1839 = surface_13;
            bool _S1840 = boundsVolume_0(&_S1839);
            bool _S1841;
            if(_S1840)
            {
                _S1841 = !_S1716;
            }
            else
            {
                _S1841 = false;
            }
            if(_S1841)
            {
                FKSurface faced_2 = surface_13;
                float3  _S1842 = - _S1827.geometry_n;
                float3  _S1843 = _slang_select(turned_1, _S1842,_S1827.geometry_n);
                (&faced_2)->geometry_n = _S1843;
                FKMedium _S1844 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1845 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1846 = faced_2;
                FKMedium _S1847 = _S1844;
                FKMedium _S1848 = _S1845;
                MediumSides _S1849 = mediumSides_0(&_S1846, &_S1847, filling_2, (&ray_3)->unit_direction, &_S1848);
                bool _S1850 = ((dot_0(throughput_10, _S1827.geometry_n)) > 0.0f) == ((dot_0(_S1827.geometry_n, (&faced_2)->geometry_n)) > 0.0f);
                float3  _S1851 = _slang_select(_S1850, _S1849.front.scatter,_S1849.behind.scatter);
                scatter_in_0 = _S1851;
                float3  _S1852 = scatter_in_0;
                float _S1853 = upsample(scatter_in_0, wavelength_10);
                float3  _S1854 = make_float3 (_S1853);
                float3  _S1855 = _slang_select(_S1593, _S1854,_S1852);
                scatter_in_0 = _S1855;
                float3  _S1856 = _slang_select(_S1850, _S1849.front.extinction,_S1849.behind.extinction);
                extinction_in_0 = _S1856;
                float3  _S1857 = extinction_in_0;
                float _S1858 = upsample(extinction_in_0, wavelength_10);
                float3  _S1859 = make_float3 (_S1858);
                float3  _S1860 = _slang_select(_S1593, _S1859,_S1857);
                extinction_in_0 = _S1860;
                float _S1861 = _slang_select(_S1850, _S1849.front.g,_S1849.behind.g);
                g_in_0 = _S1861;
                uint _S1862 = _S1849.fillings.x;
                uint _S1863 = _S1849.fillings.y;
                uint _S1864 = _slang_select(_S1850, _S1863,_S1862);
                bool _S1865 = (fcptVaryingUsed());
                uint _S1866 = _slang_select(_S1865, _S1864,4294967295U);
                filling_2 = _S1866;
            }
            (&ray_3)->unit_direction = throughput_10;
            bool _S1867 = !_S1716;
            if(_S1867)
            {
                FKSurface _S1868 = surface_13;
                float _S1869 = _slang_select(straight_0, 0.0f,_S1868.geometry_offset);
                float3  _S1870 = - _S1529.smooth_n;
                bool _S1871 = is_inside_8 != _S1711;
                float3  _S1872 = _slang_select(_S1871, _S1870,_S1529.smooth_n);
                float3  _S1873 = (&ray_3)->origin + make_float3 (_S1869) * _S1872;
                (&ray_3)->origin = _S1873;
            }
            throughput_11 = throughput_12;
            chain_throughput_1 = chain_throughput_2;
            density_7 = sky_pdf_3;
            passes_0 = _S1716;
            viewed_1 = _S1709;
            sky_pdf_3 = _S1832;
            spread_4 = _S1836;
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
        if(_S1570)
        {
            if(_S1492)
            {
                float3  _S1874 = pathColor(throughput_11 * emission_1, spectral_weight_1, wavelength_10);
                Reservoir candidate_8 = chain_1;
                uint _S1875 = extractBits_0((&chain_1)->path, 10U, 2U);
                bool _S1876 = _S1875 == 1U;
                if(_S1876)
                {
                    float3  _S1877 = safeDivide(_S1874, chain_throughput_1);
                    (&candidate_8)->radiance = _S1877;
                }
                Reservoir _S1878 = withEnd(candidate_8, 2U, b_7, _S1874);
                offer(sel_8, _S1878, _S1874 * make_float3 (scale_4) / make_float3 (density_7));
            }
            if(_S1492)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1879 = survivalProbability(abs_0(throughput_11), density_7);
                density_8 = _S1879;
            }
            else
            {
                density_8 = 1.0f;
            }
            uint _S1880 = (fcptMaxBounces());
            bool _S1881 = b_7 >= _S1880;
            if(_S1881)
            {
                wrong_side_0 = true;
            }
            else
            {
                bool _S1882 = density_8 < 1.0f;
                if(_S1882)
                {
                    uint _S1883 = noiseAddress(_S1378, b_7);
                    Random _S1884 = draw(_S1883, 8U);
                    wrong_side_0 = density_8 < (_S1884.value);
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
            float _S1885 = density_7 * density_8;
            density_8 = _S1885;
        }
        else
        {
            density_8 = density_7;
        }
        uint _S1886 = layer_0 ^ 1U;
        uint _S1887 = _slang_select(passes_0, _S1886,0U);
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
            uint _S1888 = b_10 + 1U;
            b_7 = _S1888;
            layer_0 = _S1887;
            continue;
        }
        FKRay _S1889 = ray_3;
        float _S1890 = distance_1(reconnection_0, (&ray_3)->origin) * 1.0010000467300415f;
        if(replay_2)
        {
            refracted_4 = _S1599;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S1355 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1891 = _slang_select(wrong_side_0, _S1890,4.294967296e+09f);
        bool _S1892 = !_S1560;
        if(straight_0)
        {
            _S1644 = true;
        }
        else
        {
            _S1644 = _S1560;
        }
        FKHit _S1893;
        if(_S1644)
        {
            _S1893 = hit_4;
        }
        else
        {
            _S1893 = _S1616;
        }
        FKHit _S1894 = (fcptTraverseInstanceBVH((_S1889), (_S1498), (_S1891), (_S1892), (_S1893), (viewed_1)));
        hit_4 = _S1894;
        if(replay_2)
        {
            _S1645 = _S1599;
        }
        else
        {
            _S1645 = false;
        }
        if(_S1645)
        {
            _S1704 = _S1355 == 1U;
        }
        else
        {
            _S1704 = false;
        }
        if(_S1704)
        {
            _S1705 = ((&hit_4)->instance_index) == (_S1367.instance_index);
        }
        else
        {
            _S1705 = false;
        }
        if(_S1705)
        {
            _S1706 = ((&hit_4)->triangle_index) == (_S1367.triangle_index);
        }
        else
        {
            _S1706 = false;
        }
        if(_S1706)
        {
            (&hit_4)->uv = _S1367.uv;
            float _S1895 = distance_1(reconnection_0, (&ray_3)->origin);
            (&hit_4)->distance = _S1895;
        }
        if(replay_2)
        {
            _S1707 = _S1599;
        }
        else
        {
            _S1707 = false;
        }
        if(_S1707)
        {
            _S1708 = _S1355 == 3U;
        }
        else
        {
            _S1708 = false;
        }
        if(_S1708)
        {
            _S1709 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1709 = false;
        }
        if(_S1709)
        {
            return _S1351;
        }
        Reservoir _S1896 = chain_1;
        uint _S1897 = filling_2;
        for(;;)
        {
            bool _S1898 = (fcptVaryingUsed());
            if(_S1898)
            {
                _S1710 = _S1897 != 4294967295U;
            }
            else
            {
                _S1710 = false;
            }
            if(_S1710)
            {
                float _S1899 = (fcptMajorant((_S1897)));
                _S1711 = _S1899 > 0.0f;
            }
            else
            {
                _S1711 = any_1(scatter_in_0 > make_float3 (0.0f));
            }
            if(replay_2)
            {
                _S1712 = _S1599;
            }
            else
            {
                _S1712 = false;
            }
            if(_S1712)
            {
                _S1713 = _S1355 == 1U;
            }
            else
            {
                _S1713 = false;
            }
            if(_S1713)
            {
                _S1714 = _S1711;
            }
            else
            {
                _S1714 = false;
            }
            if(_S1714)
            {
                ended_0 = _S1351;
                sky_pdf_2 = sky_pdf_3;
                spread_2 = spread_4;
                width_4 = width_3;
                density_4 = density_8;
                throughput_12 = throughput_11;
                b_10 = b_7;
                _S1715 = true;
                break;
            }
            bool _S1900 = (&prev_1)->rough;
            if(_S1900)
            {
                _S1715 = !_S1711;
            }
            else
            {
                _S1715 = false;
            }
            (&prev_1)->rough = _S1715;
            uint _S1901 = b_7 + 320U;
            bool _S1902 = b_7 == 4294967295U;
            uint _S1903 = _slang_select(_S1902, 384U,_S1901);
            uint _S1904 = stream(_S1378, _S1903);
            uint tracking_1 = _S1904;
            weight_2 = throughput_4;
            glowed_0 = _S1350;
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
                    _S1349 = int(2);
                    break;
                }
                float _S1905 = (&hit_4)->distance;
                if(_S1710)
                {
                    float3  _S1906 = (&ray_3)->origin;
                    float3  _S1907 = (&ray_3)->unit_direction;
                    float _S1908 = (&hit_4)->distance;
                    bool _S1909 = b_10 == 4294967295U;
                    uint _S1910 = _slang_select(_S1909, 0U,b_10);
                    uint _S1911 = (&prev_1)->lobe;
                    uint _S1912 = _slang_select(_S1909, 3U,_S1911);
                    float _S1913 = (fcptTrackMedium((_S1897), (_S1906), (_S1907), (_S1908), (&tracking_1), (&weight_2), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1910), (_S1912), (_S1909)));
                    spread_3 = _S1913;
                }
                else
                {
                    if(_S1711)
                    {
                        uint _S1914 = noiseAddress(_S1378, b_10);
                        Random _S1915 = draw(_S1914, 10U);
                        float _S1916 = 3.0f * _S1915.value;
                        uint _S1917 = (U32_min((uint(_S1916)), (2U)));
                        float _S1918 = - (F32_log((1.0f - (_S1916 - float(_S1917))))) / *_slang_vector_get_element_ptr(&scatter_in_0, _S1917);
                        spread_3 = _S1918;
                    }
                    else
                    {
                        spread_3 = _S1905;
                    }
                }
                bool _S1919 = !(spread_3 < ((&hit_4)->distance));
                if(_S1919)
                {
                    _S1349 = int(2);
                    break;
                }
                if(_S1710)
                {
                    _S1716 = _S1570;
                }
                else
                {
                    _S1716 = false;
                }
                if(_S1716)
                {
                    float3  _S1920 = pathColor(throughput_12 * glowed_0, spectral_weight_1, wavelength_10);
                    float3  _S1921 = _S1920 / make_float3 (density_4);
                    float3  _S1922 = sel_8->glow + _S1921;
                    sel_8->glow = _S1922;
                }
                else
                {
                }
                glowed_0 = _S1350;
                uint b_11 = b_10 + 1U;
                float3  _S1923 = (&ray_3)->origin + make_float3 (spread_3) * (&ray_3)->unit_direction;
                (&ray_3)->origin = _S1923;
                float3  _S1924 = flightWeight_0(scatter_in_0, extinction_in_0, spread_3, true);
                float3  _S1925 = weight_2;
                float _S1926 = upsample(weight_2, wavelength_10);
                float3  _S1927 = make_float3 (_S1926);
                float3  _S1928 = _slang_select(_S1593, _S1927,_S1925);
                float3  _S1929 = _slang_select(_S1710, _S1928,_S1924);
                float3  throughput_13 = throughput_12 * _S1929;
                uint _S1930 = stream(_S1378, b_11 + 320U);
                tracking_1 = _S1930;
                weight_2 = throughput_4;
                float width_8 = width_4 + spread_2 * spread_3;
                float _S1931 = spread_2 + 3.14159274101257324f;
                if(_S1570)
                {
                    _S1717 = true;
                }
                else
                {
                    bool _S1932 = b_11 == _S1366;
                    if(_S1932)
                    {
                        _S1717 = !_S1710;
                    }
                    else
                    {
                        _S1717 = false;
                    }
                }
                TreeSample light_4;
                if(_S1717)
                {
                    float3  _S1933 = (&ray_3)->origin;
                    float3  _S1934 = (&ray_3)->unit_direction;
                    float3  _S1935 = (&ray_3)->unit_direction;
                    uint _S1936 = noiseAddress(_S1378, b_11);
                    float3  _S1937 = extinction_in_0;
                    float3  _S1938 = extinction_in_0;
                    uint2  _S1939 = make_uint2 (_S1897);
                    float3  _S1940 = (&ray_3)->unit_direction;
                    uint _S1941 = arrivalLobe_0(b_11, (&prev_1)->lobe);
                    FKHit _S1942 = _S1616;
                    ShadowContext _S1943 = ShadowContext_x24init_0(_S1937, _S1938, _S1939, _S1940, b_11, _S1941, false, spread_3, width_8, &_S1942, false);
                    ShadowContext _S1944 = _S1943;
                    TreeSample _S1945 = sampleLightTree_0(_S1933, _S1934, _S1935, 0.0f, true, _S1936, &_S1944);
                    light_4 = _S1945;
                }
                else
                {
                    light_4 = _S1613;
                }
                float _S1946 = phaseHG_0(g_in_0, dot_0((&ray_3)->unit_direction, light_4.dir));
                uint _S1947 = (fcptMaxBounces());
                bool _S1948 = b_11 < _S1947;
                if(_S1948)
                {
                    _S1718 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1718 = false;
                }
                float _S1949 = _slang_select(_S1718, _S1946,0.0f);
                float3  _S1950 = throughput_13 * light_4.radiance;
                float _S1951 = powerHeuristic(light_4.density, _S1949);
                float3  _S1952 = pathColor(_S1950 * make_float3 (_S1946 * _S1951), spectral_weight_1, wavelength_10);
                float3  _S1953 = _slang_select(_S1717, _S1952,_S1350);
                if(replay_2)
                {
                    _S1719 = b_11 == _S1366;
                }
                else
                {
                    _S1719 = false;
                }
                if(_S1719)
                {
                    bool _S1954 = _S1355 == 2U;
                    if(_S1954)
                    {
                        float _S1955 = resamplingTarget(_S1953);
                        _S1720 = _S1955 > 0.0f;
                    }
                    else
                    {
                        _S1720 = false;
                    }
                    if(_S1720)
                    {
                        Shift _S1956 = Shift_x24init_0(_S1953, 1.0f);
                        _S1349 = int(1);
                        ended_0 = _S1956;
                        spread_3 = _S1931;
                        width_5 = width_8;
                        throughput_10 = throughput_13;
                        b_8 = b_11;
                        break;
                    }
                    _S1349 = int(1);
                    ended_0 = _S1351;
                    spread_3 = _S1931;
                    width_5 = width_8;
                    throughput_10 = throughput_13;
                    b_8 = b_11;
                    break;
                }
                if(_S1570)
                {
                    Reservoir candidate_9 = _S1896;
                    uint _S1957 = extractBits_0(_S1896.path, 24U, 8U);
                    uint _S1958 = insertBits_0(0U, _S1957, 24U, 8U);
                    uint _S1959 = extractBits_0(_S1896.path, 10U, 2U);
                    bool _S1960 = _S1959 == 1U;
                    if(_S1960)
                    {
                        float3  _S1961 = safeDivide(_S1953, chain_throughput_1);
                        (&candidate_9)->radiance = _S1961;
                    }
                    else
                    {
                        uint _S1962 = insertBits_0(_S1958, b_11 + 1U, 5U, 5U);
                        uint _S1963 = insertBits_0(_S1962, 2U, 10U, 2U);
                        (&candidate_9)->path = _S1963;
                    }
                    Reservoir _S1964 = withEnd(candidate_9, 0U, b_11, _S1953);
                    offer(sel_8, _S1964, _S1953 * make_float3 (scale_4) / make_float3 (density_4));
                    float _S1965 = survivalProbability(abs_0(throughput_13), density_4);
                    uint _S1966 = (fcptMaxBounces());
                    bool _S1967 = b_11 >= _S1966;
                    if(_S1967)
                    {
                        _S1720 = true;
                    }
                    else
                    {
                        bool _S1968 = _S1965 < 1.0f;
                        if(_S1968)
                        {
                            uint _S1969 = noiseAddress(_S1378, b_11);
                            Random _S1970 = draw(_S1969, 8U);
                            _S1720 = _S1965 < (_S1970.value);
                        }
                        else
                        {
                            _S1720 = false;
                        }
                    }
                    if(_S1720)
                    {
                        _S1349 = int(1);
                        ended_0 = _S1351;
                        spread_3 = _S1931;
                        width_5 = width_8;
                        throughput_10 = throughput_13;
                        b_8 = b_11;
                        break;
                    }
                    float _S1971 = density_4 * _S1965;
                    density_4 = _S1971;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1972 = noiseAddress(_S1378, b_11);
                float3  _S1973 = samplePhase_0(g_in_0, (&ray_3)->unit_direction, _S1972, &phase_pdf_1);
                (&ray_3)->unit_direction = _S1973;
                NEEVertex _S1974 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_3)->origin, _S1350, (&ray_3)->origin);
                nee_vertex_1 = _S1974;
                Vertex _S1975 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_6);
                prev_1 = _S1975;
                float _S1976 = (&prev_1)->pdf;
                FKRay _S1977 = ray_3;
                FKHit _S1978 = (fcptTraverseInstanceBVH((_S1977), (true), (4.294967296e+09f), (false), (_S1616), (false)));
                hit_4 = _S1978;
                b_10 = b_11;
                throughput_12 = throughput_13;
                spread_2 = _S1931;
                width_4 = width_8;
                sky_pdf_2 = _S1976;
            }
            if(_S1349 != int(2))
            {
                spread_2 = spread_3;
                width_4 = width_5;
                throughput_12 = throughput_10;
                b_10 = b_8;
                _S1715 = true;
                break;
            }
            ended_0 = _S1351;
            _S1715 = false;
            break;
        }
        if(_S1715)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1716 = b_10 == b_7;
        }
        else
        {
            _S1716 = false;
        }
        bool _S1979 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S1979)
        {
            Reservoir _S1980 = chain_1;
            FKRay _S1981 = ray_3;
            Vertex _S1982 = prev_1;
            NEEVertex _S1983 = nee_vertex_1;
            Shift _S1984 = escape_0(r_9, replay_2, _S1366, _S1355, _S1353, _S1356, scale_4, _S1380, &_S1980, chain_throughput_1, b_10, &_S1981, throughput_12, density_4, &_S1982, &_S1983, sky_pdf_2, spectral_weight_1, wavelength_10, sel_8);
            return _S1984;
        }
        FKHit _S1985 = hit_4;
        uint _S1986 = filling_2;
        float3  _S1987 = scatter_in_0;
        float3  _S1988 = extinction_in_0;
        float3  _S1989 = weight_2;
        float3  _S1990 = glowed_0;
        float3  _S1991 = (&ray_3)->origin + make_float3 (_S1985.distance) * (&ray_3)->unit_direction;
        (&ray_3)->origin = _S1991;
        bool _S1992 = (fcptVaryingUsed());
        if(_S1992)
        {
            _S1717 = _S1986 != 4294967295U;
        }
        else
        {
            _S1717 = false;
        }
        if(_S1717)
        {
            if(_S1570)
            {
                float3  _S1993 = pathColor(throughput_12 * _S1990, spectral_weight_1, wavelength_10);
                float3  _S1994 = _S1993 / make_float3 (density_4);
                float3  _S1995 = sel_8->glow + _S1994;
                sel_8->glow = _S1995;
            }
            else
            {
            }
            float3  _S1996 = throughput_12 * _S1989;
            throughput_10 = _S1996;
        }
        else
        {
            float3  _S1997 = flightWeight_0(_S1987, _S1988, _S1985.distance, false);
            float3  _S1998 = throughput_12 * _S1997;
            throughput_10 = _S1998;
        }
        float width_9 = width_4 + spread_2 * _S1985.distance;
        viewed_0 = _S1716;
        width_3 = width_9;
        throughput_3 = throughput_10;
        density_3 = density_4;
        sky_pdf_1 = sky_pdf_2;
        spread_1 = spread_2;
        uint _S1888 = b_10 + 1U;
        b_7 = _S1888;
        layer_0 = _S1887;
    }
    return _S1351;
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
    Random _S1999 = pcg(state_3);
    Random _S2000 = pcg(_S1999.state);
    float _S2001 = 6.28318548202514648f * _S1999.value;
    float _S2002 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S2000.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S2000.state, _S2002 * (F32_cos((_S2001))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_4, float3  value_2)
{
    RandomSphere _S2003;
    (&_S2003)->state = state_4;
    (&_S2003)->value = value_2;
    return _S2003;
}

__device__ RandomSphere random_sphere(uint state_5)
{
    Random _S2004 = normal_distribution(state_5);
    Random _S2005 = normal_distribution(_S2004.state);
    Random _S2006 = normal_distribution(_S2005.state);
    float3  _S2007 = make_float3 (_S2004.value, _S2005.value, _S2006.value);
    float3  _S2008 = ((((_S2007)) * make_float3(rnorm3df(((_S2007)).x, ((_S2007)).y, ((_S2007)).z))));
    return RandomSphere_x24init_0(_S2006.state, _S2008);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_12)
{
    float3  _S2009 = p1_0 - p0_0;
    float3  _S2010 = p2_0 - p0_0;
    float2  _S2011 = uv1_0 - uv0_0;
    float2  _S2012 = uv2_0 - uv0_0;
    float _S2013 = _S2011.x;
    float _S2014 = _S2012.y;
    float _S2015 = _S2011.y;
    float _S2016 = _S2012.x;
    float _S2017 = _S2013 * _S2014 - _S2015 * _S2016;
    float _S2018 = 1.0f / _S2017;
    float3  t_24 = (_S2009 * make_float3 (_S2014) - _S2010 * make_float3 (_S2015)) * make_float3 (_S2018);
    float3  _S2019 = (_S2010 * make_float3 (_S2013) - _S2009 * make_float3 (_S2016)) * make_float3 (_S2018);
    float3  _S2020 = t_24 - n_12 * make_float3 (dot_0(n_12, t_24));
    float3  _S2021 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_12);
    bool _S2022 = (dot_0(_S2020, _S2020)) > 0.0f;
    float3  _S2023 = _slang_select(_S2022, _S2020,_S2021);
    float3  _S2024 = ((((_S2023)) * make_float3(rnorm3df(((_S2023)).x, ((_S2023)).y, ((_S2023)).z))));
    bool _S2025 = (dot_0(cross_0(n_12, _S2024), _S2019)) > 0.0f;
    float3  t_25;
    if(_S2025)
    {
        float3  _S2026 = negate_0(_S2024);
        t_25 = _S2026;
    }
    else
    {
        t_25 = _S2024;
    }
    float3  _S2027 = cross_0(n_12, t_25);
    return makeMatrix<float, 3, 3> (t_25, _S2027, n_12);
}

__device__ float3  tangentToWorldNormalMap(float3  v_10, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_10, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_4, float3  uvw_0, float3  position_1)
{
    float3  _S2028 = t1_0 - t0_0;
    float3  _S2029 = t2_2 - t0_0;
    float3  _S2030 = t2_2 - t1_0;
    float _S2031 = (F32_min((length_0(_S2028)), ((F32_min((length_0(_S2029)), (length_0(_S2030)))))));
    float3  _S2032 = make_float3 (distance_1(position_1, t0_0), distance_1(position_1, t1_0), distance_1(position_1, t2_2));
    float3  _S2033 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S2034 = dot_0(geometry_n_4, _S2033);
    float3  _S2035 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S2036 = dot_0(geometry_n_4, _S2035);
    float3  _S2037 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S2038 = acos_0(abs_0(make_float3 (_S2034, _S2036, dot_0(geometry_n_4, _S2037))));
    float3  _S2039 = clamp_2(tan_0(_S2038), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S2032 * _S2039, uvw_0), 0.0f, _S2031 * 0.125f);
}

__device__ float3  straightThrough(BSDFMaterial material_26)
{
    return make_float3 (material_26.transmission * (1.0f - material_26.metallic)) * material_26.albedo;
}

__device__ float hairRow(float3  in_dir_11, float3  t_26, float3  out_dir_3, uint p_17, float w_19, float alpha_10, uint nt_0)
{
    uint _S2040 = p_17 % 4U;
    float _S2041 = w_19 * HAIR_WIDTHS_0[_S2040];
    float _S2042 = (F32_asin((clamp_1(dot_0(out_dir_3, t_26), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_11, t_26), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S2040] * alpha_10;
    return ((F32_asinh((_S2042 / _S2041))) / (F32_asinh((3.14159274101257324f / _S2041))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_12, float3  t_27, float3  out_dir_4, uint np_0)
{
    float3  _S2043 = worldToTangent(out_dir_4, t_27);
    float3  _S2044 = worldToTangent(in_dir_12, t_27);
    return (F32_frac((((F32_atan2((_S2043.z), (_S2043.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S2044.z), (1.17549435082228751e-38f - _S2044.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_13, float3  t_28, uint p_18, float row_0, float column_0, float w_20, float alpha_11, uint nt_1, uint np_1)
{
    float3  _S2045 = worldToTangent(in_dir_13, t_28);
    uint _S2046 = p_18 % 4U;
    float _S2047 = w_20 * HAIR_WIDTHS_0[_S2046];
    float _S2048 = (F32_asin((clamp_1(dot_0(in_dir_13, t_28), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S2046] * alpha_11 + _S2047 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S2047))))));
    float _S2049 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S2045.z), (1.17549435082228751e-38f - _S2045.x)));
    float _S2050 = (F32_cos((_S2048)));
    float3  _S2051 = tangentToWorld(make_float3 (_S2050 * (F32_cos((_S2049))), (F32_sin((_S2048))), _S2050 * (F32_sin((_S2049)))), t_28);
    return _S2051;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_13, BSDFMaterial material_27, float coverage_1)
{
    float3  _S2052;
    if((material_27.ior) == 1.0f)
    {
        float3  _S2053 = straightThrough(material_27);
        _S2052 = _S2053;
    }
    else
    {
        _S2052 = make_float3 (0.0f);
    }
    return _S2052 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_9, Reservoir r_10, bool replay_3, float scale_5, Selection * sel_9)
{
    Domain _S2054 = dom_9;
    Reservoir _S2055 = r_10;
    Shift _S2056 = walk_0(&_S2054, &_S2055, replay_3, scale_5, sel_9);
    return _S2056;
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
        uint _S2057 = size_0 - 1U;
        uint _S2058 = (x_29 + size_0 / 2U) & _S2057;
        bool _S2059 = i_31 < 2U;
        uint _S2060 = _slang_select(_S2059, x_29,_S2058);
        uint l_6 = _S2060;
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
            uint _S2061 = hash(((r_11 ^ (t_29 << 16U)) ^ (k_4 << 28U)) ^ ((i_31 & 1U) << 31U));
            uint _S2062 = l_6 ^ (_S2061 & _S2057);
            uint k_5 = k_4 + 1U;
            l_6 = r_11;
            r_11 = _S2062;
            k_4 = k_5;
        }
        uint _S2063 = l_6 + r_11 * size_0;
        uint _S2064 = size_0 * size_0;
        uint _S2065;
        if(_S2064 >= 65536U)
        {
            uint _S2066 = _S2063 / (_S2064 / 65536U);
            _S2065 = _S2066;
        }
        else
        {
            uint _S2067 = 65536U / _S2064;
            _S2065 = _S2063 * _S2067;
        }
        ranks_0[i_31] = _S2065;
        uint i_32 = i_31 + 1U;
        i_31 = i_32;
    }
    bool _S2068 = (ranks_0[int(0)]) == 65535U;
    bool _S2069;
    if(_S2068)
    {
        _S2069 = (ranks_0[int(1)]) == 65535U;
    }
    else
    {
        _S2069 = false;
    }
    bool _S2070 = (ranks_0[int(2)]) == 65535U;
    bool _S2071;
    if(_S2070)
    {
        _S2071 = (ranks_0[int(3)]) == 65535U;
    }
    else
    {
        _S2071 = false;
    }
    if(_S2069)
    {
        _S2069 = (ranks_0[int(3)]) != 65535U;
    }
    else
    {
        _S2069 = false;
    }
    if(_S2069)
    {
        _S2069 = true;
    }
    else
    {
        if(_S2071)
        {
            _S2069 = (ranks_0[int(1)]) != 65535U;
        }
        else
        {
            _S2069 = false;
        }
    }
    uint _S2072 = ranks_0[int(0)];
    uint _S2073 = ranks_0[int(1)];
    uint _S2074 = ranks_0[int(3)];
    uint _S2075 = _slang_select(_S2069, _S2074,_S2073);
    return _S2072 | (_S2075 << 16U);
}

__device__ uint3  noiseBlock(uint sweep_0, uint colour_0, uint block_0, uint size_1)
{
    uint _S2076 = hash(sweep_0 * 7919U + 1U);
    uint _S2077 = size_1 / 16U;
    uint _S2078 = block_0 % _S2077;
    uint _S2079 = block_0 / _S2077;
    uint _S2080 = _S2079 % _S2077;
    uint _S2081 = block_0 / (_S2077 * _S2077);
    uint3  _S2082 = make_uint3 (_S2078, _S2080, _S2081);
    uint3  _S2083 = make_uint3 (colour_0 & 1U, (colour_0 >> 1U) & 1U, colour_0 >> 2U);
    return _S2082 * make_uint3 (16U) + _S2083 * make_uint3 (8U) + make_uint3 (_S2076 & 7U, (_S2076 >> 3U) & 7U, (_S2076 >> 6U) & 7U);
}

#undef Matrix
