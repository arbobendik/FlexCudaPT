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
    Random _S300;
    (&_S300)->state = state_0;
    (&_S300)->value = value_0;
    return _S300;
}

__device__ Random pcg(uint state_1)
{
    uint _S301 = hash(state_1);
    float value_1 = float(_S301 >> int(8)) * 5.9604644775390625e-08f;
    return Random_x24init_0(_S301, value_1);
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
    float3  _S304 = skyFrame_0(dir_3);
    float2  _S305 = make_float2 ((F32_atan2((- _S304.z), (- _S304.x))) / 6.28318548202514648f + 0.5f, (F32_acos((clamp_1(_S304.y, -1.0f, 1.0f)))) / 3.14159274101257324f);
    float2  _S306 = make_float2 ((float)_S303.x, (float)_S303.y);
    float2  _S307 = _S305 * _S306;
    uint2  _S308 = make_uint2 ((uint)_S307.x, (uint)_S307.y);
    uint2  _S309 = min_0(_S308, _S303 - make_uint2 (1U));
    float4  _S310 = (fcptEnvironmentCdf((_S309)));
    float _S311 = _S310.y;
    uint _S312 = _S303.x;
    float4  _S313 = (fcptEnvironmentCdf((make_uint2 (_S312, _S309.y))));
    float _S314 = _S311 * _S313.y;
    return _S314 * float(_S312 * _S303.y) / (19.73921012878417969f * length_1(float2 {_S304.x, _S304.z}));
}

static __device__ float3  negate_0(float3  x_13)
{
    return - x_13;
}

static __device__ float sign_0(float e_1)
{
    bool _S315 = e_1 < 0.0f;
    float _S316 = _slang_select(_S315, -1.0f,0.0f);
    bool _S317 = e_1 > 0.0f;
    float _S318 = _slang_select(_S317, 1.0f,_S316);
    return _S318;
}

struct AnisotropicFrame
{
    float3  tangent;
    float2  alphas;
};

static __device__ AnisotropicFrame AnisotropicFrame_x24init_0(float3  tangent_0, float2  alphas_0)
{
    AnisotropicFrame _S319;
    (&_S319)->tangent = tangent_0;
    (&_S319)->alphas = alphas_0;
    return _S319;
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_1)
{
    float3  a_1 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S320 = (F32_abs((dot_0(n_1, a_1)))) > 0.9999847412109375f;
    float3  a_2;
    if(_S320)
    {
        float3  _S321 = make_float3 (1.0f, 0.0f, 0.0f);
        a_2 = _S321;
    }
    else
    {
        a_2 = a_1;
    }
    float3  _S322 = cross_0(n_1, a_2);
    float3  _S323 = ((((_S322)) * make_float3(rnorm3df(((_S322)).x, ((_S322)).y, ((_S322)).z))));
    float3  _S324 = cross_0(n_1, _S323);
    return make_float3 (v_0.x) * _S323 + make_float3 (v_0.y) * n_1 + make_float3 (v_0.z) * _S324;
}

__device__ AnisotropicFrame anisotropicFrame(BSDFMaterial material_0, float3  n_i_0)
{
    float _S325 = material_0.roughness;
    float _S326 = _S325 * _S325;
    bool _S327 = (material_0.anisotropy) == 0.0f;
    bool _S328;
    if(_S327)
    {
        _S328 = true;
    }
    else
    {
        _S328 = !(_S326 > 0.0f);
    }
    if(_S328)
    {
        return AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f));
    }
    float3  _S329 = material_0.tangent - n_i_0 * make_float3 (dot_0(n_i_0, material_0.tangent));
    float3  _S330 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_i_0);
    bool _S331 = (dot_0(_S329, _S329)) > 0.0f;
    float3  _S332 = _slang_select(_S331, _S329,_S330);
    float3  _S333 = ((((_S332)) * make_float3(rnorm3df(((_S332)).x, ((_S332)).y, ((_S332)).z))));
    float _S334 = 6.28318548202514648f * material_0.anisotropic_rotation;
    float _S335 = (F32_sqrt((1.0f - 0.89999997615814209f * (F32_abs((material_0.anisotropy))))));
    float _S336 = 1.0f / _S335;
    bool _S337 = (material_0.anisotropy) < 0.0f;
    float _S338 = _slang_select(_S337, _S336,_S335);
    return AnisotropicFrame_x24init_0(_S333 * make_float3 ((F32_cos((_S334)))) + cross_0(n_i_0, _S333) * make_float3 ((F32_sin((_S334)))), make_float2 (_S326 / _S338, _S326 * _S338));
}

struct SheenProfile
{
    bool on;
    float albedo;
};

static __device__ SheenProfile SheenProfile_x24init_0(bool on_0, float albedo_0)
{
    SheenProfile _S339;
    (&_S339)->on = on_0;
    (&_S339)->albedo = albedo_0;
    return _S339;
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
    SheenProfile _S340 = SheenProfile_x24init_0(false, 0.0f);
    float _S341 = rgb_to_greyscale(material_1.sheen);
    bool _S342 = _S341 > 0.0f;
    SheenProfile profile_0;
    if(_S342)
    {
        float _S343 = clamp_1((F32_sqrt(((F32_max((dot_0(n_i_1, v_1)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S344 = (U32_min((uint(_S343)), (22U)));
        float _S345 = (F32_sqrt((0.05000000074505806f)));
        float _S346 = (F32_sqrt((0.00999999977648258f)));
        bool _S347 = (material_1.velvet) > 0.0f;
        float _S348 = _slang_select(_S347, _S346,_S345);
        float _S349 = (clamp_1((F32_sqrt(((F32_max((material_1.sheen_roughness), (0.0f)))))), _S348, 1.0f) - _S348) / (1.0f - _S348) * 23.0f;
        uint _S350 = (U32_min((uint(_S349)), (22U)));
        uint _S351 = _S344 * 24U + _S350;
        float _S352 = _S343 - float(_S344);
        float _S353 = _S349 - float(_S350);
        if(_S347)
        {
            uint _S354 = _S351 + 24U;
            float _S355 = VELVET_ALBEDO_0[_S351] + (VELVET_ALBEDO_0[_S354] - VELVET_ALBEDO_0[_S351]) * _S352;
            uint _S356 = _S351 + 1U;
            float _S357 = VELVET_ALBEDO_0[_S356] + (VELVET_ALBEDO_0[_S354 + 1U] - VELVET_ALBEDO_0[_S356]) * _S352;
            SheenProfile _S358 = SheenProfile_x24init_0(true, _S355 + (_S357 - _S355) * _S353);
            profile_0 = _S358;
        }
        else
        {
            uint _S359 = _S351 + 24U;
            float _S360 = SHEEN_ALBEDO_0[_S351] + (SHEEN_ALBEDO_0[_S359] - SHEEN_ALBEDO_0[_S351]) * _S352;
            uint _S361 = _S351 + 1U;
            float _S362 = SHEEN_ALBEDO_0[_S361] + (SHEEN_ALBEDO_0[_S359 + 1U] - SHEEN_ALBEDO_0[_S361]) * _S352;
            SheenProfile _S363 = SheenProfile_x24init_0(true, (F32_exp((_S360 + (_S362 - _S360) * _S353))));
            profile_0 = _S363;
        }
    }
    else
    {
        profile_0 = _S340;
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
    Weights _S364;
    (&_S364)->v_dot_h = v_dot_h_0;
    (&_S364)->refracted = refracted_1;
    (&_S364)->F = F_0;
    (&_S364)->reflect_weight = reflect_weight_0;
    (&_S364)->diffuse_weight = diffuse_weight_0;
    (&_S364)->refract_weight = refract_weight_0;
    (&_S364)->p_diffuse = p_diffuse_0;
    (&_S364)->p_reflect = p_reflect_0;
    (&_S364)->p_refract = p_refract_0;
    (&_S364)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S364)->p_toon = p_toon_0;
    (&_S364)->sheen = sheen_0;
    (&_S364)->toon = toon_0;
    return _S364;
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
    float3  _S365 = make_float3 (alpha_0 * Ve_0.x, alpha_0 * Ve_0.y, Ve_0.z);
    float3  _S366 = ((((_S365)) * make_float3(rnorm3df(((_S365)).x, ((_S365)).y, ((_S365)).z))));
    float _S367 = _S366.x;
    float _S368 = _S366.y;
    float _S369 = _S367 * _S367 + _S368 * _S368;
    float3  _S370 = make_float3 (1.0f, 0.0f, 0.0f);
    float3  _S371 = make_float3 (- _S368, _S367, 0.0f);
    float _S372 = (rsqrtf((_S369)));
    float3  _S373 = _S371 * make_float3 (_S372);
    bool _S374 = _S369 > 0.0f;
    float3  _S375 = _slang_select(_S374, _S373,_S370);
    float3  _S376 = cross_0(_S366, _S375);
    float _S377 = (F32_sqrt((U1_0)));
    float _S378 = 6.28318548202514648f * U2_0;
    float _S379 = _S377 * (F32_cos((_S378)));
    float t2_0 = _S377 * (F32_sin((_S378)));
    float _S380 = 0.5f * (1.0f + _S366.z);
    float t2_1 = (1.0f - _S380) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S379 * _S379)))))) + _S380 * t2_0;
    float3  _S381 = make_float3 (_S379) * _S375 + make_float3 (t2_1) * _S376;
    float _S382 = unshared_0(_S379);
    float _S383 = unshared_0(_S379);
    float3  _S384 = _S381 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S382 * _S383 - t2_1 * t2_1))))))) * _S366;
    float3  _S385 = make_float3 (alpha_0 * _S384.x, alpha_0 * _S384.y, (F32_max((0.0f), (_S384.z))));
    float3  _S386 = ((((_S385)) * make_float3(rnorm3df(((_S385)).x, ((_S385)).y, ((_S385)).z))));
    return _S386;
}

__device__ float3  worldToTangent(float3  v_2, float3  n_3)
{
    float3  a_3 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S387 = (F32_abs((dot_0(n_3, a_3)))) > 0.9999847412109375f;
    float3  a_4;
    if(_S387)
    {
        float3  _S388 = make_float3 (1.0f, 0.0f, 0.0f);
        a_4 = _S388;
    }
    else
    {
        a_4 = a_3;
    }
    float3  _S389 = cross_0(n_3, a_4);
    float3  _S390 = ((((_S389)) * make_float3(rnorm3df(((_S389)).x, ((_S389)).y, ((_S389)).z))));
    float3  _S391 = cross_0(n_3, _S390);
    return make_float3 (dot_0(v_2, _S390), dot_0(v_2, n_3), dot_0(v_2, _S391));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_3, float3  n_i_2, float alpha_1, AnisotropicFrame frame_0, uint * random_state_2)
{
    Random _S392 = pcg(*random_state_2);
    Random _S393 = pcg(_S392.state);
    *random_state_2 = _S393.state;
    float _S394 = frame_0.alphas.x;
    bool _S395 = _S394 > 0.0f;
    if(_S395)
    {
        float3  _S396 = anisotropicLocal(v_3, frame_0.tangent, n_i_2);
        float _S397 = frame_0.alphas.y;
        float3  _S398 = make_float3 (_S394 * _S396.x, _S397 * _S396.y, _S396.z);
        float3  _S399 = ((((_S398)) * make_float3(rnorm3df(((_S398)).x, ((_S398)).y, ((_S398)).z))));
        float3  _S400 = sampleGGXVNDF(_S399, 1.0f, _S392.value, _S393.value);
        float3  _S401 = make_float3 (_S394 * _S400.x, _S397 * _S400.y, _S400.z);
        float3  _S402 = ((((_S401)) * make_float3(rnorm3df(((_S401)).x, ((_S401)).y, ((_S401)).z))));
        return make_float3 (_S402.x) * frame_0.tangent + make_float3 (_S402.y) * cross_0(n_i_2, frame_0.tangent) + make_float3 (_S402.z) * n_i_2;
    }
    float3  _S403 = worldToTangent(v_3, n_i_2);
    float3  _S404 = sampleGGXVNDF(float3 {_S403.x, _S403.z, _S403.y}, alpha_1, _S392.value, _S393.value);
    float3  _S405 = float3 {_S404.x, _S404.z, _S404.y};
    float3  _S406 = tangentToWorld(_S405, n_i_2);
    return _S406;
}

__device__ __forceinline__ float3  sampledHalf(float3  v_4, float3  n_i_3, float alpha_2, AnisotropicFrame frame_1, uint random_state_3)
{
    uint state_2 = random_state_3;
    float3  _S407 = sampleHalfVector(v_4, n_i_3, alpha_2, frame_1, &state_2);
    return _S407;
}

__device__ __forceinline__ float3  refractedHalf(float3  in_dir_0, float3  out_dir_0, float3  n_4, float eta_i_0, float eta_o_0)
{
    float3  _S408 = negate_0(in_dir_0);
    float3  _S409 = negate_0(make_float3 (eta_i_0) * _S408 + make_float3 (eta_o_0) * out_dir_0);
    float3  _S410 = ((((_S409)) * make_float3(rnorm3df(((_S409)).x, ((_S409)).y, ((_S409)).z))));
    float _S411 = sign_0(dot_0(n_4, _S408));
    float _S412 = sign_0(dot_0(_S409, n_4 * make_float3 (_S411)));
    return _S410 * make_float3 (_S412);
}

__device__ __forceinline__ float3  reflectedHalf(float3  in_dir_1, float3  out_dir_1)
{
    float3  _S413 = negate_0(in_dir_1);
    float3  _S414 = _S413 + out_dir_1;
    float3  _S415 = ((((_S414)) * make_float3(rnorm3df(((_S414)).x, ((_S414)).y, ((_S414)).z))));
    return _S415;
}

static __device__ float3  refract_0(float3  i_5, float3  n_5, float eta_0)
{
    float _S416 = dot_0(n_5, i_5);
    float _S417 = 1.0f - eta_0 * eta_0 * (1.0f - _S416 * _S416);
    if(_S417 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_5 - make_float3 (eta_0 * _S416 + (F32_sqrt((_S417)))) * n_5;
}

__device__ float fresnel(float cos_theta_0, float eta_i_1, float eta_o_1)
{
    float _S418 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S419 = eta_i_1 / eta_o_1 * _S418;
    bool _S420 = _S419 < 1.0f;
    float kr_0;
    if(_S420)
    {
        float _S421 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S419 * _S419))))));
        bool _S422 = eta_i_1 == eta_o_1;
        float _S423 = _slang_select(_S422, cos_theta_0,_S421);
        float _S424 = eta_o_1 * cos_theta_0;
        float _S425 = eta_i_1 * _S423;
        float _S426 = (_S424 - _S425) / (_S424 + _S425);
        float _S427 = eta_i_1 * cos_theta_0;
        float _S428 = eta_o_1 * _S423;
        float _S429 = (_S427 - _S428) / (_S427 + _S428);
        float _S430 = (_S426 * _S426 + _S429 * _S429) / 2.0f;
        kr_0 = _S430;
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

__device__ __forceinline__ Weights lobeWeights(float3  in_dir_2, float3  v_5, float3  n_i_4, float3  ggx_n_0, AnisotropicFrame frame_2, SheenProfile sheen_profile_0, BSDFMaterial material_2, float eta_i_2, float eta_o_2)
{
    float _S431 = dot_0(ggx_n_0, v_5);
    float _S432 = eta_i_2 / eta_o_2;
    float3  _S433 = refract_0(in_dir_2, ggx_n_0, _S432);
    float3  _S434 = ((((_S433)) * make_float3(rnorm3df(((_S433)).x, ((_S433)).y, ((_S433)).z))));
    float _S435 = (F32_min(((F32_sqrt((material_2.specular_level))) * (F32_abs((eta_i_2 - eta_o_2))) / (eta_i_2 + eta_o_2)), (0.9999847412109375f)));
    float _S436 = _S435 * _S435;
    float _S437 = (1.0f + _S435) / (1.0f - _S435);
    float _S438 = (F32_abs((_S431)));
    bool _S439 = eta_i_2 > eta_o_2;
    float _S440 = _slang_select(_S439, _S437,1.0f);
    float _S441 = _slang_select(_S439, 1.0f,_S437);
    float _S442 = fresnel(_S438, _S440, _S441);
    bool _S443 = (eta_i_2 * eta_i_2 * (1.0f - _S431 * _S431)) >= (eta_o_2 * eta_o_2);
    float3  _S444 = material_2.specular_tint * make_float3 (_S436);
    float3  _S445 = _S444 + (make_float3 (1.0f) - _S444) * make_float3 (_S442 - _S436) / make_float3 (1.0f - _S436);
    float3  _S446 = make_float3 (1.0f);
    float3  _S447 = _slang_select(_S443, _S446,_S445);
    float3  _S448 = make_float3 (0.0f);
    float sheen_component_0;
    float3  sheen_1;
    float3  scale_1;
    if(sheen_profile_0.on)
    {
        float _S449 = (F32_min((sheen_profile_0.albedo), (1.0f)));
        float3  _S450 = make_float3 (1.0f) - material_2.sheen * make_float3 (_S449);
        float _S451 = rgb_to_greyscale(material_2.sheen);
        float _S452 = _S451 * _S449;
        float3  _S453 = material_2.sheen / make_float3 ((F32_max((sheen_profile_0.albedo), (1.0f))));
        sheen_component_0 = _S452;
        sheen_1 = _S453;
        scale_1 = _S450;
    }
    else
    {
        sheen_component_0 = 0.0f;
        sheen_1 = _S448;
        scale_1 = _S446;
    }
    float _S454 = (F32_abs((material_2.toon.x)));
    bool _S455 = _S454 > 0.0f;
    float toon_component_0;
    float3  toon_1;
    if(_S455)
    {
        float _S456 = (F32_min((_S454), (1.0f)));
        float3  scale_2 = scale_1 * make_float3 (1.0f - _S456);
        float _S457 = rgb_to_greyscale(material_2.albedo);
        float _S458 = _S456 * _S457;
        float3  _S459 = make_float3 (_S456) * material_2.albedo;
        toon_component_0 = _S458;
        toon_1 = _S459;
        scale_1 = scale_2;
    }
    else
    {
        toon_component_0 = 0.0f;
        toon_1 = _S448;
    }
    bool _S460 = (material_2.metallic) > 0.0f;
    float3  rebounce_0;
    if(_S460)
    {
        float _S461 = frame_2.alphas.x;
        float _S462 = (F32_sqrt(((F32_min((_S461), (frame_2.alphas.y))))));
        bool _S463 = _S461 > 0.0f;
        float _S464 = _slang_select(_S463, _S462,material_2.roughness);
        float _S465 = _S464 * _S464;
        float _S466 = (F32_pow((_S465), (1.81585001945495605f))) * (2.15371990203857422f - 0.73285001516342163f * _S465) / (1.0f + 1.28094995021820068f * _S465);
        bool _S467 = _S465 > 0.0f;
        float _S468 = _slang_select(_S467, _S466,0.0f);
        float _S469 = clamp_1(dot_0(n_i_4, v_5), 0.0f, 1.0f);
        float _S470 = _S465 * _S464;
        float _S471 = (F32_min((1.00064504146575928f - _S464 * (0.00375499995425344f + _S469 * (-0.04133399948477745f + _S469 * (-0.90938502550125122f + _S469 * 0.35275399684906006f))) - _S465 * (0.27602800726890564f + _S469 * (1.27023398876190186f + _S469 * 0.04740000143647194f)) - _S470 * (0.31452900171279907f - _S469 * 0.34830701351165771f) + _S470 * _S464 * 0.27229699492454529f), (1.0f)));
        float3  _S472 = min_1(make_float3 (1.0f) / (make_float3 (1.0f) - material_2.albedo * make_float3 (_S468)), make_float3 (1.0f / (F32_max((_S471), (0.0000152587890625f)))));
        rebounce_0 = _S472;
    }
    else
    {
        rebounce_0 = _S446;
    }
    float3  _S473 = mix_0(_S447, material_2.albedo * rebounce_0, material_2.metallic);
    float3  F_1 = _S473 * scale_1;
    float _S474 = rgb_to_greyscale(F_1);
    float _S475 = 1.0f - material_2.metallic;
    float3  _S476 = make_float3 (1.0f) - _S447;
    float3  _S477 = make_float3 ((1.0f - material_2.transmission) * _S475) * _S476 * scale_1;
    float3  _S478 = make_float3 (material_2.transmission * _S475) * _S476 * scale_1;
    float _S479 = (F32_max((_S474), (0.0f)));
    float _S480 = rgb_to_greyscale(_S477);
    float _S481 = (F32_max((_S480), (0.0f)));
    float _S482 = rgb_to_greyscale(_S478);
    float _S483 = sign_0(length_0(_S434));
    float _S484 = (F32_max((_S482 * _S483), (0.0f)));
    float _S485 = _S479 + _S481 + _S484 + toon_component_0;
    float _S486 = (F32_min((sheen_component_0), (1.0f)));
    bool _S487 = sheen_component_0 > 0.0f;
    bool _S488;
    if(_S487)
    {
        _S488 = !(_S485 > 0.0f);
    }
    else
    {
        _S488 = false;
    }
    float _S489 = _slang_select(_S488, 1.0f,_S486);
    float _S490 = (1.0f - _S489) / (F32_max((_S485), (0.0000152587890625f)));
    float _S491 = _S481 * _S490;
    float _S492 = _S479 * _S490;
    float _S493 = _S484 * _S490;
    return Weights_x24init_0(_S431, _S434, F_1, 1.0f, _S477, _S478, _S491, _S492, _S493, _S489, toon_component_0 * _S490, sheen_1, toon_1);
}

__device__ float translucentShare(BSDFMaterial material_3)
{
    float _S494 = rgb_to_greyscale(material_3.translucent);
    float _S495 = rgb_to_greyscale(material_3.albedo);
    float _S496 = _S494 / (_S495 + _S494);
    bool _S497 = _S494 > 0.0f;
    float _S498 = _slang_select(_S497, _S496,0.0f);
    return _S498;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float n_i_dot_v_0, BSDFMaterial material_4, Weights w_1)
{
    float _S499 = translucentShare(material_4);
    float _S500 = w_1.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S501 = w_1.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S502 = 1.0f - _S499;
    bool _S503 = n_i_dot_l_0 < 0.0f;
    float _S504 = _slang_select(_S503, _S499,_S502);
    float _S505 = _S501 * _S504;
    bool _S506 = _S499 > 0.0f;
    float _S507 = _slang_select(_S506, _S505,_S500);
    bool _S508 = n_i_dot_v_0 > 0.0f;
    float _S509 = _slang_select(_S508, _S507,0.0f);
    return _S509;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_5, BSDFMaterial material_5, Weights w_2)
{
    float _S510 = translucentShare(material_5);
    bool _S511 = (dot_0(n_i_5, l_0)) < 0.0f;
    float3  _S512 = _slang_select(_S511, material_5.translucent,material_5.albedo);
    float _S513 = 1.0f - _S510;
    float _S514 = _slang_select(_S511, _S510,_S513);
    float3  _S515 = _S512 / make_float3 (_S514);
    bool _S516 = _S510 > 0.0f;
    float3  _S517 = _slang_select(_S516, _S515,material_5.albedo);
    return w_2.diffuse_weight * _S517 / make_float3 (w_2.p_diffuse);
}

__device__ float smithG1(float alpha_3, float n_dot_x_0)
{
    float _S518 = alpha_3 * alpha_3;
    float _S519 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S518 + (1.0f - _S518) * n_dot_x_0 * n_dot_x_0))));
    bool _S520 = alpha_3 > 0.0f;
    float _S521 = _slang_select(_S520, _S519,1.0f);
    return _S521;
}

__device__ float trowbridgeReitz(float alpha_4, float n_dot_h_0)
{
    float _S522 = alpha_4 * alpha_4;
    float _S523 = (1.0f - n_dot_h_0) * (1.0f + n_dot_h_0) + _S522 * n_dot_h_0 * n_dot_h_0;
    return _S522 / (F32_max((3.14159274101257324f * _S523 * _S523), (1.17549435082228751e-38f)));
}

__device__ float anisotropicG1(float3  w_3, float2  alphas_1)
{
    float _S524 = (F32_max((w_3.z), (0.0f)));
    return 2.0f * _S524 / (_S524 + length_0(make_float3 (alphas_1.x * w_3.x, alphas_1.y * w_3.y, _S524)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_2)
{
    float _S525 = alphas_2.x;
    float _S526 = h_0.x / _S525;
    float _S527 = alphas_2.y;
    float _S528 = h_0.y / _S527;
    float _S529 = h_0.z;
    float _S530 = _S526 * _S526 + _S528 * _S528 + _S529 * _S529;
    return 1.0f / (F32_max((3.14159274101257324f * _S525 * _S527 * _S530 * _S530), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float3  v_6, float3  h_1, float3  n_i_6, float n_i_dot_v_1, float alpha_5, AnisotropicFrame frame_3, float v_dot_h_1)
{
    float _S531 = dot_0(n_i_6, h_1);
    float _S532 = smithG1(alpha_5, n_i_dot_v_1);
    float _S533 = _S532 * v_dot_h_1;
    float _S534 = trowbridgeReitz(alpha_5, _S531);
    float _S535 = _S533 * _S534 / n_i_dot_v_1;
    bool _S536 = alpha_5 > 0.0f;
    bool _S537;
    if(_S536)
    {
        _S537 = v_dot_h_1 > 0.0f;
    }
    else
    {
        _S537 = false;
    }
    if(_S537)
    {
        _S537 = _S531 > 0.0f;
    }
    else
    {
        _S537 = false;
    }
    if(_S537)
    {
        _S537 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S537 = false;
    }
    float _S538 = _slang_select(_S537, _S535,0.0f);
    bool _S539 = (frame_3.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S539)
    {
        float3  _S540 = anisotropicLocal(v_6, frame_3.tangent, n_i_6);
        float _S541 = anisotropicG1(_S540, frame_3.alphas);
        float3  _S542 = anisotropicLocal(h_1, frame_3.tangent, n_i_6);
        float _S543 = anisotropicD(_S542, frame_3.alphas);
        float _S544 = _S541 * _S543;
        float _S545 = _S544 * v_dot_h_1 / n_i_dot_v_1;
        bool _S546 = v_dot_h_1 > 0.0f;
        if(_S546)
        {
            _S537 = _S531 > 0.0f;
        }
        else
        {
            _S537 = false;
        }
        if(_S537)
        {
            _S537 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S537 = false;
        }
        float _S547 = _slang_select(_S537, _S545,0.0f);
        pdf_h_0 = _S547;
    }
    else
    {
        pdf_h_0 = _S538;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float l_dot_h_0, float pdf_h_1, Weights w_4, float eta_i_3, float eta_o_3)
{
    float _S548 = eta_i_3 * w_4.v_dot_h + eta_o_3 * l_dot_h_0;
    float _S549 = w_4.p_refract * pdf_h_1 * eta_o_3 * eta_o_3 * (F32_abs((l_dot_h_0))) / (_S548 * _S548);
    bool _S550 = eta_i_3 != eta_o_3;
    bool _S551;
    if(_S550)
    {
        _S551 = l_dot_h_0 < 0.0f;
    }
    else
    {
        _S551 = false;
    }
    float _S552 = _slang_select(_S551, _S549,0.0f);
    return _S552;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_7, float alpha_6, AnisotropicFrame frame_4, BSDFMaterial material_6, Weights w_5)
{
    float _S553 = - dot_0(n_i_7, l_1);
    float _S554 = smithG1(alpha_6, (F32_max((_S553), (0.0f))));
    bool _S555 = (frame_4.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S555)
    {
        float3  _S556 = negate_0(n_i_7);
        float3  _S557 = anisotropicLocal(l_1, frame_4.tangent, _S556);
        float _S558 = anisotropicG1(_S557, frame_4.alphas);
        G1_l_0 = _S558;
    }
    else
    {
        G1_l_0 = _S554;
    }
    bool _S559 = (material_6.ior) == 1.0f;
    float _S560 = _slang_select(_S559, 1.0f,G1_l_0);
    return w_5.refract_weight * make_float3 (_S560) * material_6.albedo / make_float3 (w_5.p_refract);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_1, float n_i_dot_v_2, Weights w_6)
{
    float _S561 = w_6.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S562 = n_i_dot_l_1 > 0.0f;
    bool _S563;
    if(_S562)
    {
        _S563 = n_i_dot_v_2 > 0.0f;
    }
    else
    {
        _S563 = false;
    }
    float _S564 = _slang_select(_S563, _S561,0.0f);
    return _S564;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  v_7, float3  n_i_8, BSDFMaterial material_7, Weights w_7)
{
    float3  _S565 = l_2 + v_7;
    float3  _S566 = ((((_S565)) * make_float3(rnorm3df(((_S565)).x, ((_S565)).y, ((_S565)).z))));
    float _S567 = dot_0(n_i_8, _S566);
    float _S568 = (F32_max((dot_0(n_i_8, l_2)), (0.0f)));
    float _S569 = (F32_max((dot_0(n_i_8, v_7)), (0.0f)));
    float _S570 = 1.0f / (F32_max((material_7.sheen_roughness), (0.05000000074505806f)));
    float _S571 = 1.0f - _S567 * _S567;
    float _S572 = (2.0f + _S570) * (F32_pow(((F32_max((_S571), (0.0f)))), (0.5f * _S570))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S568 + _S569 - _S568 * _S569)), (0.0000152587890625f)));
    bool _S573 = (material_7.velvet) > 0.0f;
    float f_1;
    if(_S573)
    {
        float _S574 = (F32_max((material_7.sheen_roughness), (0.00999999977648258f)));
        float _S575 = _S574 * _S574;
        float _S576 = (F32_max((_S571), (0.0000152587890625f)));
        float _S577 = (F32_exp((- _S567 * _S567 / (_S576 * _S575)))) / (3.14159274101257324f * _S575 * _S576 * _S576) * (F32_min((1.0f), (2.0f * _S567 * (F32_min((_S568), (_S569))) / (F32_max(((F32_abs((dot_0(_S566, v_7))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S568 * _S569), (0.0000152587890625f)));
        f_1 = _S577;
    }
    else
    {
        f_1 = _S572;
    }
    return w_7.sheen * make_float3 (f_1 * _S568 * 2.0f * 3.14159274101257324f / w_7.p_sheen_velvet);
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
    float _S578 = (F32_max((1.0f - (t_13 - a_5) / (F32_max((s_0), (0.0000152587890625f)))), (0.0f)));
    bool _S579 = t_13 < a_5;
    float _S580 = _slang_select(_S579, 1.0f,_S578);
    return _S580;
}

__device__ __forceinline__ float toonIntegral(float t_14, float a_6, float s_1, bool glossy_0)
{
    float _S581 = (F32_min((t_14), (a_6)));
    float _S582 = (F32_sin((_S581)));
    float _S583 = _S582 * _S582 / 2.0f;
    float _S584 = 1.0f - (F32_cos((_S581)));
    float _S585 = _slang_select(glossy_0, _S584,_S583);
    bool _S586 = t_14 > a_6;
    bool _S587;
    if(_S586)
    {
        _S587 = s_1 > 0.0f;
    }
    else
    {
        _S587 = false;
    }
    float integral_0;
    if(_S587)
    {
        if(glossy_0)
        {
            float _S588 = (F32_cos((a_6)));
            float _S589 = (F32_cos((t_14)));
            integral_0 = (1.0f + a_6 / s_1) * (_S588 - _S589) - ((F32_sin((t_14))) - t_14 * _S589 - ((F32_sin((a_6))) - a_6 * _S588)) / s_1;
        }
        else
        {
            float _S590 = 2.0f * a_6;
            float _S591 = (F32_cos((_S590)));
            float _S592 = 2.0f * t_14;
            float _S593 = (F32_cos((_S592)));
            integral_0 = (1.0f + a_6 / s_1) * (_S591 - _S593) / 4.0f - ((F32_sin((_S592))) / 8.0f - t_14 * _S593 / 4.0f - ((F32_sin((_S590))) / 8.0f - a_6 * _S591 / 4.0f)) / s_1;
        }
        float integral_1 = _S585 + integral_0;
        integral_0 = integral_1;
    }
    else
    {
        integral_0 = _S585;
    }
    return integral_0;
}

static __device__ ToonProfile ToonProfile_x24init_0(bool glossy_1, float a_7, float s_2, float b_1, float norm_0, float view_0, float3  axis_0)
{
    ToonProfile _S594;
    (&_S594)->glossy = glossy_1;
    (&_S594)->a = a_7;
    (&_S594)->s = s_2;
    (&_S594)->b = b_1;
    (&_S594)->norm = norm_0;
    (&_S594)->view = view_0;
    (&_S594)->axis = axis_0;
    return _S594;
}

__device__ __forceinline__ ToonProfile toonProfile(float3  v_8, float3  n_i_9, BSDFMaterial material_8)
{
    float _S595 = material_8.toon.x;
    bool _S596 = _S595 < 0.0f;
    float _S597 = clamp_1(material_8.toon.y / _S595, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S598 = clamp_1(material_8.toon.z / _S595, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S599 = (F32_min((_S597 + _S598), (1.57079637050628662f)));
    float _S600 = dot_0(n_i_9, v_8);
    float _S601 = toonP((F32_acos(((F32_min((_S600), (1.0f)))))), _S597, _S598);
    float3  _S602 = make_float3 (2.0f * _S600) * n_i_9 - v_8;
    float3  _S603 = ((((_S602)) * make_float3(rnorm3df(((_S602)).x, ((_S602)).y, ((_S602)).z))));
    float3  _S604 = _slang_select(_S596, _S603,n_i_9);
    float _S605 = toonIntegral(_S599, _S597, _S598, _S596);
    return ToonProfile_x24init_0(_S596, _S597, _S598, _S599, 6.28318548202514648f * _S605, _S601, _S604);
}

__device__ __forceinline__ float toonPDF(float3  l_3, float3  n_i_10, ToonProfile profile_1, Weights w_8)
{
    float _S606 = dot_0(n_i_10, l_3);
    float _S607 = dot_0(l_3, profile_1.axis);
    float _S608 = _slang_select(profile_1.glossy, _S607,_S606);
    float _S609 = (F32_acos((clamp_1(_S608, -1.0f, 1.0f))));
    float _S610 = toonP(_S609, profile_1.a, profile_1.s);
    float _S611 = w_8.p_toon * _S610;
    float _S612 = _slang_select(profile_1.glossy, 1.0f,_S606);
    float _S613 = _S611 * _S612 / profile_1.norm;
    bool _S614;
    if(profile_1.glossy)
    {
        _S614 = true;
    }
    else
    {
        _S614 = _S606 > 0.0f;
    }
    float _S615 = _slang_select(_S614, _S613,0.0f);
    return _S615;
}

__device__ __forceinline__ float3  toonBSDF(float3  l_4, float3  n_i_11, ToonProfile profile_2, Weights w_9)
{
    float _S616 = (F32_max((dot_0(n_i_11, l_4)), (0.0f)));
    float _S617 = _slang_select(profile_2.glossy, _S616,profile_2.view);
    return w_9.toon * make_float3 (_S617) / make_float3 (w_9.p_toon);
}

__device__ __forceinline__ float reflectPDF(float pdf_h_2, Weights w_10)
{
    float _S618 = w_10.p_reflect * pdf_h_2 / (4.0f * w_10.v_dot_h);
    bool _S619 = pdf_h_2 > 0.0f;
    float _S620 = _slang_select(_S619, _S618,0.0f);
    return _S620;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_5, float3  n_i_12, float alpha_7, AnisotropicFrame frame_5, Weights w_11)
{
    float _S621 = dot_0(n_i_12, l_5);
    float _S622 = smithG1(alpha_7, (F32_max((_S621), (0.0f))));
    bool _S623 = (frame_5.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S623)
    {
        float3  _S624 = anisotropicLocal(l_5, frame_5.tangent, n_i_12);
        float _S625 = anisotropicG1(_S624, frame_5.alphas);
        G1_l_1 = _S625;
    }
    else
    {
        G1_l_1 = _S622;
    }
    return make_float3 (w_11.reflect_weight * G1_l_1) * w_11.F / make_float3 (w_11.p_reflect);
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_3, float3  out_dir_2, float3  n_6, BSDFMaterial material_9, float eta_i_4, float eta_o_4, bool refracted_2, uint random_state_4, FixedArray<float3 , 5>  * throughputs_0, FixedArray<float, 5>  * pdfs_0)
{
    float3  ggx_n_1;
    float3  _S626 = negate_0(in_dir_3);
    float _S627 = dot_0(n_6, _S626);
    float _S628 = sign_0(_S627);
    float3  _S629 = n_6 * make_float3 (_S628);
    float _S630 = dot_0(_S629, out_dir_2);
    float _S631 = material_9.roughness;
    float _S632 = _S631 * _S631;
    AnisotropicFrame _S633 = anisotropicFrame(material_9, _S629);
    SheenProfile _S634 = sheenProfile(_S626, _S629, material_9);
    float _S635 = rgb_to_greyscale(material_9.translucent);
    bool _S636 = _S635 > 0.0f;
    bool _S637 = (dot_0(n_6, out_dir_2) * _S627) < 0.0f;
    bool _S638 = (F32_abs((material_9.toon.x))) > 0.0f;
    uint _S639;
    if(_S638)
    {
        _S639 = 5U;
    }
    else
    {
        _S639 = 4U;
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
        float3  _S640 = make_float3 (0.0f);
        (*throughputs_0)[i_7] = _S640;
        (*pdfs_0)[i_7] = 0.0f;
        uint i_8 = i_7 + 1U;
        i_7 = i_8;
    }
    float3  _S641 = make_float3 (0.0f);
    Weights _S642 = Weights_x24init_0(0.0f, _S641, _S641, 0.0f, _S641, _S641, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, _S641, _S641);
    uint half_of_0 = 4294967295U;
    Weights w_12 = _S642;
    float3  ggx_n_2 = _S641;
    i_7 = 0U;
    for(;;)
    {
        if(i_7 < _S639)
        {
        }
        else
        {
            break;
        }
        uint _S643;
        if(i_7 == 3U)
        {
            _S643 = 4U;
        }
        else
        {
            if(i_7 == 4U)
            {
                _S643 = 6U;
            }
            else
            {
                _S643 = i_7;
            }
        }
        bool _S644 = _S643 == 0U;
        bool _S645;
        if(_S644)
        {
            _S645 = _S636;
        }
        else
        {
            _S645 = false;
        }
        bool _S646;
        if(_S645)
        {
            _S646 = _S637;
        }
        else
        {
            _S646 = _S643 == 1U;
        }
        bool _S647 = _S646 != refracted_2;
        if(_S647)
        {
            ggx_n_1 = ggx_n_2;
            uint i_9 = i_7 + 1U;
            ggx_n_2 = ggx_n_1;
            i_7 = i_9;
            continue;
        }
        uint _S648;
        if(_S643 == 6U)
        {
            _S648 = 0U;
        }
        else
        {
            if(_S643 == 4U)
            {
                _S648 = 2U;
            }
            else
            {
                _S648 = _S643;
            }
        }
        bool _S649 = _S648 != half_of_0;
        uint half_of_1;
        Weights w_13;
        if(_S649)
        {
            bool _S650 = _S648 == 0U;
            if(_S650)
            {
                float3  _S651 = sampledHalf(_S626, _S629, _S632, _S633, random_state_4);
                ggx_n_1 = _S651;
            }
            else
            {
                bool _S652 = _S648 == 1U;
                if(_S652)
                {
                    float3  _S653 = refractedHalf(in_dir_3, out_dir_2, n_6, eta_i_4, eta_o_4);
                    ggx_n_1 = _S653;
                }
                else
                {
                    float3  _S654 = reflectedHalf(in_dir_3, out_dir_2);
                    ggx_n_1 = _S654;
                }
            }
            Weights _S655 = lobeWeights(in_dir_3, _S626, _S629, ggx_n_1, _S633, _S634, material_9, eta_i_4, eta_o_4);
            w_13 = _S655;
            half_of_1 = _S648;
        }
        else
        {
            w_13 = w_12;
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S643)
        {
        case 0U:
            {
                float _S656 = diffusePDF(_S630, (F32_abs((_S627))), material_9, w_13);
                (*pdfs_0)[int(0)] = _S656;
                float3  _S657 = diffuseBSDF(out_dir_2, _S629, material_9, w_13);
                (*throughputs_0)[int(0)] = _S657;
                break;
            }
        case 1U:
            {
                float _S658 = dot_0(out_dir_2, ggx_n_1);
                float _S659 = vndfPDF(_S626, ggx_n_1, _S629, (F32_abs((_S627))), _S632, _S633, w_13.v_dot_h);
                float _S660 = refractPDF(_S658, _S659, w_13, eta_i_4, eta_o_4);
                (*pdfs_0)[int(1)] = _S660;
                float3  _S661 = refractBSDF(out_dir_2, _S629, _S632, _S633, material_9, w_13);
                (*throughputs_0)[int(1)] = _S661;
                break;
            }
        case 4U:
            {
                float _S662 = sheenVelvetPDF(_S630, (F32_abs((_S627))), w_13);
                (*pdfs_0)[int(3)] = _S662;
                float3  _S663 = sheenVelvetBSDF(out_dir_2, _S626, _S629, material_9, w_13);
                (*throughputs_0)[int(3)] = _S663;
                break;
            }
        case 6U:
            {
                ToonProfile _S664 = toonProfile(_S626, _S629, material_9);
                float _S665 = toonPDF(out_dir_2, _S629, _S664, w_13);
                (*pdfs_0)[int(4)] = _S665;
                float3  _S666 = toonBSDF(out_dir_2, _S629, _S664, w_13);
                (*throughputs_0)[int(4)] = _S666;
                break;
            }
        default:
            {
                float _S667 = vndfPDF(_S626, ggx_n_1, _S629, (F32_abs((_S627))), _S632, _S633, w_13.v_dot_h);
                float _S668 = reflectPDF(_S667, w_13);
                (*pdfs_0)[int(2)] = _S668;
                float3  _S669 = reflectBSDF(out_dir_2, _S629, _S632, _S633, w_13);
                (*throughputs_0)[int(2)] = _S669;
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
    ggx_n_1 = _S641;
    for(;;)
    {
        if(i_7 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S670 = ((*pdfs_0)[i_7]) > 0.0f;
        if(_S670)
        {
            float3  f_2 = ggx_n_1 + (*throughputs_0)[i_7] * make_float3 ((*pdfs_0)[i_7]);
            ggx_n_1 = f_2;
        }
        uint i_10 = i_7 + 1U;
        i_7 = i_10;
    }
    return ggx_n_1;
}

static __device__ __forceinline__ float3  skyLobes_0(float3  in_dir_4, float3  dir_4, FKSurface * surface_1, float2  eta_1, bool is_inside_2, float pdf_0, uint random_state_5, FixedArray<float3 , 5>  * terms_0, FixedArray<float, 5>  * pdfs_1)
{
    bool _S671 = wrongSide_0(is_inside_2, false, dir_4, surface_1->geometry_n);
    float3  _S672 = BSDF(in_dir_4, dir_4, surface_1->smooth_n, surface_1->material, eta_1.x, eta_1.y, _S671, random_state_5, terms_0, pdfs_1);
    float3  _S673 = make_float3 (0.0f);
    uint i_11 = 0U;
    float3  f_3 = _S673;
    for(;;)
    {
        if(i_11 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S674 = ((*pdfs_1)[i_11]) > 0.0f;
        if(_S674)
        {
            float3  _S675 = (*terms_0)[i_11] * make_float3 ((*pdfs_1)[i_11]) / make_float3 ((*pdfs_1)[i_11] + pdf_0);
            (*terms_0)[i_11] = _S675;
            float3  f_4 = f_3 + (*terms_0)[i_11];
            f_3 = f_4;
        }
        uint i_12 = i_11 + 1U;
        i_11 = i_12;
    }
    return f_3;
}

__device__ float3  skyBSDF(float3  in_dir_5, float3  dir_5, FKSurface surface_2, float2  eta_2, bool is_inside_3, float pdf_1, uint random_state_6)
{
    FKSurface _S676 = surface_2;
    FixedArray<float3 , 5>  terms_1;
    FixedArray<float, 5>  pdfs_2;
    float3  _S677 = skyLobes_0(in_dir_5, dir_5, &_S676, eta_2, is_inside_3, pdf_1, random_state_6, &terms_1, &pdfs_2);
    return _S677;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_6, float3  radiance_0, float3  color_0, uint random_state_7)
{
    SkySample _S678;
    (&_S678)->dir = dir_6;
    (&_S678)->radiance = radiance_0;
    (&_S678)->color = color_0;
    (&_S678)->random_state = random_state_7;
    return _S678;
}

static __device__ __noinline__ float3  skyColor_0(float3  in_dir_6, float3  dir_7, FKSurface * surface_3, float2  eta_3, bool is_inside_4, float pdf_2, uint random_state_8, uint depth_0)
{
    FixedArray<float3 , 5>  terms_2;
    FixedArray<float, 5>  pdfs_3;
    float3  _S679 = skyLobes_0(in_dir_6, dir_7, surface_3, eta_3, is_inside_4, pdf_2, random_state_8, &terms_2, &pdfs_3);
    float3  _S680 = make_float3 (0.0f);
    bool shaded_0 = false;
    float3  world_0 = _S680;
    uint i_13 = 0U;
    float3  color_1 = _S680;
    for(;;)
    {
        if(i_13 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S681 = (pdfs_3[i_13]) > 0.0f;
        if(_S681)
        {
            bool _S682 = (fcptWorldReadsPath());
            bool _S683;
            if(_S682)
            {
                _S683 = true;
            }
            else
            {
                _S683 = !shaded_0;
            }
            bool shaded_1;
            float3  world_1;
            if(_S683)
            {
                uint _S684;
                if(i_13 == 3U)
                {
                    _S684 = 4U;
                }
                else
                {
                    if(i_13 == 4U)
                    {
                        _S684 = 6U;
                    }
                    else
                    {
                        _S684 = i_13;
                    }
                }
                float3  _S685 = (fcptEnvMapSample((dir_7), (depth_0), (_S684)));
                world_1 = _S685;
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

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_4, float2  eta_4, bool is_inside_5, uint init_random_state_0, uint lobe_state_0, ShadowContext * context_2)
{
    uint2  _S686 = (fcptEnvironmentCdfSize());
    uint2  _S687 = make_uint2 (1U, 0U);
    uint2  _S688 = _S686 - _S687;
    Random _S689 = pcg(init_random_state_0);
    Random _S690 = pcg(_S689.state);
    Random _S691 = pcg(_S690.state);
    Random _S692 = pcg(_S691.state);
    uint _S693 = _S688.x;
    uint _S694 = searchCDF_0(make_uint2 (_S693, 0U), make_uint2 (0U, 1U), _S688.y, _S689.value);
    uint _S695 = searchCDF_0(make_uint2 (0U, _S694), _S687, _S693, _S690.value);
    float2  _S696 = make_float2 ((float)_S688.x, (float)_S688.y);
    float2  _S697 = (make_float2 (float(_S695), float(_S694)) + make_float2 (_S691.value, _S692.value)) / _S696 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S698 = _S697.y;
    float _S699 = (F32_sin((_S698)));
    float _S700 = _S697.x;
    float3  _S701 = skyFrame_0(make_float3 (_S699 * (F32_cos((_S700))), (F32_cos((_S698))), _S699 * (F32_sin((_S700)))));
    float _S702 = environmentPdf_0(_S701);
    float3  _S703 = ray_0->unit_direction;
    float3  _S704 = skyBSDF(ray_0->unit_direction, _S701, *surface_4, eta_4, is_inside_5, _S702, lobe_state_0);
    bool _S705 = !(_S702 > 0.0f);
    bool _S706;
    if(_S705)
    {
        _S706 = true;
    }
    else
    {
        _S706 = all_1(_S704 == make_float3 (0.0f));
    }
    if(_S706)
    {
        float3  _S707 = make_float3 (0.0f);
        return SkySample_x24init_0(_S701, _S707, _S707, _S692.state);
    }
    bool _S708 = (fcptWorldReadsPath());
    float3  seen_0;
    if(_S708)
    {
        float3  _S709 = skyColor_0(_S703, _S701, surface_4, eta_4, is_inside_5, _S702, lobe_state_0, context_2->depth + 1U);
        seen_0 = _S709;
    }
    else
    {
        seen_0 = _S704;
    }
    float3  _S710 = skyRadiance_0(ray_0->origin, surface_4, is_inside_5, _S701, context_2, _S692.state);
    return SkySample_x24init_0(_S701, _S710, seen_0 * _S710, _S692.state);
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
    SampleBSDF _S711 = (fcptConnectHair((surface_5->hair), ((&surface_5->material)->albedo), ((&surface_5->material)->specular_tint), (in_dir_7), (light_1->dir)));
    float3  _S712 = _S711.throughput * make_float3 (_S711.pdf);
    float _S713 = light_1->density;
    float _S714 = 1.0f + _S711.pdf * _S711.pdf / (light_1->density * light_1->density);
    bool _S715;
    if(competing_0)
    {
        _S715 = _S713 > 0.0f;
    }
    else
    {
        _S715 = false;
    }
    float _S716 = _slang_select(_S715, _S714,1.0f);
    return _S712 / make_float3 (_S716) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_8, float3  radiance_1, float density_0, uint random_state_9)
{
    TreeSample _S717;
    (&_S717)->dir = dir_8;
    (&_S717)->radiance = radiance_1;
    (&_S717)->density = density_0;
    (&_S717)->random_state = random_state_9;
    return _S717;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_13, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S718 = importance(first_1, p_13, normal_3);
    float _S719 = importance(second_1, p_13, normal_3);
    float2  _S720 = make_float2 (_S718, _S719);
    bool _S721 = _S718 == 0.0f;
    bool _S722;
    if(_S721)
    {
        _S722 = _S719 == 0.0f;
    }
    else
    {
        _S722 = false;
    }
    if(_S722)
    {
        return 2U;
    }
    float _S723 = _S718 + _S719;
    bool _S724 = _S719 > 0.0f;
    if(_S724)
    {
        _S722 = (*pick_0 * _S723) >= _S718;
    }
    else
    {
        _S722 = false;
    }
    uint _S725 = uint(_S722);
    float _S726 = (F32_min(((*pick_0 * _S723 - float(_S725) * _S718) / _slang_vector_get_element(_S720, _S725)), (0.99999994039535522f)));
    *pick_0 = _S726;
    float _S727 = *probability_3 * (_slang_vector_get_element(_S720, _S725) / _S723);
    *probability_3 = _S727;
    return _S725;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_14, float u1_0, float u2_0)
{
    float3  _S728 = center_1 - p_14;
    float _S729 = radius_1 * radius_1 / dot_0(_S728, _S728);
    float _S730 = u1_0 * _S729 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S729), (0.0f)))))));
    float _S731 = 2.0f * u1_0;
    bool _S732 = _S729 >= 1.0f;
    float _S733 = _slang_select(_S732, _S731,_S730);
    float _S734 = (F32_sqrt(((F32_max((_S733 * (2.0f - _S733)), (0.0f))))));
    float _S735 = 6.28318548202514648f * u2_0;
    float3  _S736 = make_float3 (_S734 * (F32_cos((_S735))), 1.0f - _S733, _S734 * (F32_sin((_S735))));
    float3  _S737 = ((((_S728)) * make_float3(rnorm3df(((_S728)).x, ((_S728)).y, ((_S728)).z))));
    float3  _S738 = tangentToWorld(_S736, _S737);
    return _S738;
}

__device__ float3  pointLightRadiance(float3  color_3, float intensity_0, float radius_2)
{
    return color_3 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S739 = center_2 - ray_1->origin;
    float _S740 = dot_0(_S739, ray_1->unit_direction);
    float _S741 = dot_0(_S739, _S739) - _S740 * _S740;
    float _S742 = radius_3 * radius_3;
    bool _S743 = _S741 > _S742;
    if(_S743)
    {
        return 4.294967296e+09f;
    }
    float _S744 = (F32_sqrt((_S742 - _S741)));
    float _S745 = _S740 - _S744;
    float _S746 = _S740 + _S744;
    bool _S747 = _S745 > 0.0000152587890625f;
    bool _S748;
    if(_S747)
    {
        _S748 = _S745 < max_len_0;
    }
    else
    {
        _S748 = false;
    }
    if(_S748)
    {
        return _S745;
    }
    bool _S749 = _S746 > 0.0000152587890625f;
    if(_S749)
    {
        _S748 = _S746 < max_len_0;
    }
    else
    {
        _S748 = false;
    }
    if(_S748)
    {
        return _S746;
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

static __device__ float3  emitted_0(float3  emissive_0, float3  dir_9, float3  n_7)
{
    float _S750 = sign_0(dot_0(- dir_9, n_7));
    float3  _S751 = emissive_0 * make_float3 ((F32_max((_S750), (0.0f))));
    bool _S752 = ((true));
    float3  _S753 = _slang_select(_S752, emissive_0,_S751);
    return _S753;
}

static __device__ __forceinline__ TreeSample sampleLightTree_0(float3  origin_4, float3  smooth_n_2, float3  geometry_n_1, float geometry_offset_1, bool sided_0, uint init_random_state_1, ShadowContext * context_3)
{
    Random _S754 = pcg(init_random_state_1);
    Random _S755 = pcg(_S754.state);
    Random _S756 = pcg(_S755.state);
    float3  _S757 = make_float3 (0.0f);
    TreeSample _S758 = TreeSample_x24init_0(_S757, _S757, 0.0f, _S756.state);
    TreeSample sample_0 = _S758;
    float3  _S759 = _slang_select(sided_0, _S757,smooth_n_2);
    float3  _S760 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S754.value;
    float probability_4 = 1.0f;
    uint n_8 = 0U;
    for(;;)
    {
        uint4  _S761 = (fcptLightNode((n_8)));
        if((_S761.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S762 = (fcptLightSecond((n_8)));
        uint _S763 = n_8 + 1U;
        LightNode _S764 = (fcptLightBounds((_S763)));
        LightNode _S765 = (fcptLightBounds((_S762)));
        uint _S766 = pickChild(_S764, _S765, origin_4, _S759, &pick_1, &probability_4);
        bool _S767 = _S766 > 1U;
        if(_S767)
        {
            return sample_0;
        }
        bool _S768 = _S766 == 1U;
        uint _S769 = _slang_select(_S768, _S762,_S763);
        n_8 = _S769;
    }
    bool _S770 = n_8 == 0U;
    bool _S771;
    if(_S770)
    {
        LightNode _S772 = (fcptLightBounds((0U)));
        float _S773 = importance(_S772, origin_4, _S759);
        _S771 = !(_S773 > 0.0f);
    }
    else
    {
        _S771 = false;
    }
    if(_S771)
    {
        return sample_0;
    }
    uint4  _S774 = (fcptLightNode((n_8)));
    FKHit _S775 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S776 = (_S774.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S776)
    {
        FKLight _S777 = (fcptLight((_S774.y)));
        if(sided_0)
        {
            float _S778 = sign_0(dot_0(geometry_n_1, _S777.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S778);
            float3  _S779 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S779;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S760;
            lift_n_0 = smooth_n_2;
        }
        bool _S780 = (_S777.variance) == 0.0f;
        if(_S780)
        {
            float3  _S781 = _S777.position - emitter_point_0;
            float3  _S782 = ((((_S781)) * make_float3(rnorm3df(((_S781)).x, ((_S781)).y, ((_S781)).z))));
            (&sample_0)->dir = _S782;
            float3  _S783 = _S777.color * make_float3 (_S777.intensity) / make_float3 (dot_0(_S781, _S781) * probability_4);
            (&sample_0)->radiance = _S783;
            shadow_1 = _S781;
        }
        else
        {
            float3  _S784 = sampleSphere(_S777.position, _S777.variance, emitter_point_0, _S755.value, _S756.value);
            (&sample_0)->dir = _S784;
            float _S785 = sphereDensity(_S777.position, _S777.variance, emitter_point_0);
            float _S786 = probability_4 * _S785;
            (&sample_0)->density = _S786;
            float3  _S787 = pointLightRadiance(_S777.color, _S777.intensity, _S777.variance);
            float3  _S788 = _S787 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S788;
            FKRay _S789 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S790 = raySphere_0(_S777.position, _S777.variance, &_S789, 4.294967296e+09f);
            float3  _S791 = (&sample_0)->dir * make_float3 (_S790);
            shadow_1 = _S791;
        }
        emitter_0 = _S775;
        emitter_point_0 = _S757;
    }
    else
    {
        uint _S792 = _S774.y;
        uint _S793 = (fcptTriangleOffset((_S792)));
        uint _S794 = _S793 + _S774.z;
        Matrix<float, 3, 3>  _S795 = (fcptWorldTriangle((_S792), (_S794)));
        float _S796 = (F32_sqrt((_S755.value)));
        float2  _S797 = make_float2 (_S796 * (1.0f - _S756.value), _S796 * _S756.value);
        float3  _S798 = mul_0(make_float3 (1.0f - _S796, _S797.x, _S797.y), _S795);
        if(sided_0)
        {
            float _S799 = sign_0(dot_0(geometry_n_1, _S798 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S799);
            float3  _S800 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S800;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S801 = !((dot_0(smooth_n_2, _S798 - origin_4)) > 0.0f);
            if(_S801)
            {
                return sample_0;
            }
            emitter_point_0 = _S760;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S797, _S792, _S794, 0U, 0.0f);
        float3  _S802 = _S798 - emitter_point_0;
        float3  _S803 = ((((_S802)) * make_float3(rnorm3df(((_S802)).x, ((_S802)).y, ((_S802)).z))));
        (&sample_0)->dir = _S803;
        float _S804 = solidAngle(probability_4, cross_0(_S795.rows[int(1)] - _S795.rows[int(0)], _S795.rows[int(2)] - _S795.rows[int(0)]), _S802);
        (&sample_0)->density = _S804;
        bool _S805 = (fcptShadowFirst());
        bool _S806 = !_S805;
        if(_S806)
        {
            FKSurface _S807 = (fcptLightSurfaceAt((emitter_1), (_S798), (_S756.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S798 - origin_4))));
            (&sample_0)->random_state = _S807.random_state;
            float3  _S808 = emitted_0(_S807.material.emissive, (&sample_0)->dir, _S807.smooth_n);
            float3  _S809 = _slang_select(_S807.skip, _S757,_S808);
            float3  _S810 = _S809 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S810;
        }
        shadow_1 = _S802;
        emitter_0 = emitter_1;
        emitter_point_0 = _S798;
    }
    FKHit _S811 = emitter_0;
    float3  _S812 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S756.state, &_S811);
    bool _S813 = (fcptShadowFirst());
    if(_S813)
    {
        _S771 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S771 = false;
    }
    if(_S771)
    {
        _S771 = !all_1(_S812 == _S757);
    }
    else
    {
        _S771 = false;
    }
    if(_S771)
    {
        FKSurface _S814 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S756.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S814.random_state;
        float3  _S815 = emitted_0(_S814.material.emissive, (&sample_0)->dir, _S814.smooth_n);
        float3  _S816 = _slang_select(_S814.skip, _S757,_S815);
        float3  _S817 = _S816 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S817;
    }
    float3  _S818 = (&sample_0)->radiance * _S812;
    bool _S819 = all_1(_S812 == _S757);
    float3  _S820 = _slang_select(_S819, _S757,_S818);
    (&sample_0)->radiance = _S820;
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
    float _S821 = 1.0f / (1.0f + b_2 / a_8 * (b_2 / a_8));
    bool _S822 = b_2 > 0.0f;
    float _S823 = _slang_select(_S822, _S821,1.0f);
    return _S823;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S824 = vertex_0->none;
    if(_S824)
    {
        return 1.0f;
    }
    uint _S825 = (fcptLightSlot((*hit_1)));
    float _S826 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S825, light_point_1);
    float _S827 = powerHeuristic(vertex_0->pdf, _S826);
    return _S827;
}

static __device__ float3  environment_0(float3  dir_10, uint depth_1, uint lobe_0)
{
    uint2  _S828 = (fcptEnvironmentMapSize());
    bool _S829 = all_0(_S828 > make_uint2 (1U));
    if(_S829)
    {
        float3  _S830 = (fcptEnvMapSample((dir_10), (depth_1), (lobe_0)));
        return _S830;
    }
    float3  _S831 = (fcptAmbient());
    return _S831;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S832 = (fcptEnvironmentCdfSize());
    bool _S833 = !all_0(_S832 > make_uint2 (1U));
    if(_S833)
    {
        return false;
    }
    uint2  _S834 = (fcptEnvironmentMapSize());
    return all_0(_S834 > make_uint2 (1U));
}

static __device__ float escapeWeight_0(float pdf_3, float3  dir_11)
{
    bool _S835 = pdf_3 <= 0.0f;
    bool _S836;
    if(_S835)
    {
        _S836 = true;
    }
    else
    {
        bool _S837 = environmentMapped_0();
        _S836 = !_S837;
    }
    if(_S836)
    {
        return 1.0f;
    }
    float _S838 = environmentPdf_0(dir_11);
    return pdf_3 / (pdf_3 + _S838);
}

static __device__ void restir_duplicates_0(uint3  global_invocation_id_1, uint3  local_invocation_id_0, uint local_invocation_index_3)
{
    uint2  _S839 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S840 = make_int2 ((int)_S839.x, (int)_S839.y);
    uint _S841 = previousSeed_0(_S840);
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
            uint _S842 = previousSeed_0(_S840 + make_int2 (x_16, y_5));
            bool _S843 = _S842 == _S841;
            uint _S844 = _slang_select(_S843, 1U,0U);
            uint count_3 = count_2 + _S844;
            int x_17 = x_16 + int(1);
            x_16 = x_17;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S845 = float(count_2 - 1U) / 288.0f;
    bool _S846 = _S841 != 0U;
    float _S847 = _slang_select(_S846, _S845,0.0f);
    fcptStoreDuplication((_S840), (make_uint4 ((F32_asuint((_S847))), 0U, 0U, 0U)));
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
    float _S848 = rgb_to_greyscale(abs_0(f_5));
    return _S848;
}

__device__ uint stream(uint seed_3, uint index_0)
{
    uint _S849 = hash(index_0);
    uint _S850 = hash(seed_3 ^ _S849);
    return _S850;
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
    float _S851 = resamplingTarget(weight_0);
    bool _S852 = _S851 > 0.0f;
    bool _S853;
    if(_S852)
    {
        _S853 = _S851 < 3.00000000549775576e+38f;
    }
    else
    {
        _S853 = false;
    }
    bool _S854 = !_S853;
    if(_S854)
    {
        return;
    }
    bool _S855 = sel_2->sums;
    if(_S855)
    {
        float3  _S856 = sel_2->color + weight_0;
        sel_2->color = _S856;
        return;
    }
    float _S857 = sel_2->w_sum + _S851;
    sel_2->w_sum = _S857;
    float3  _S858 = sel_2->color + weight_0;
    sel_2->color = _S858;
    Random _S859 = pcg(sel_2->random_state);
    sel_2->random_state = _S859.state;
    bool _S860 = (_S859.value * sel_2->w_sum) <= _S851;
    if(_S860)
    {
        sel_2->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_3;
    float3  _S861 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S861;
    float _S862 = r_3.jac * shifted_0.jac;
    (&candidate_1)->jac = _S862;
    offer(sel_3, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S863 = resamplingTarget((&r_4)->f);
    float _S864 = sel_4.w_sum / _S863;
    bool _S865 = _S863 > 0.0f;
    float _S866 = _slang_select(_S865, _S864,0.0f);
    (&r_4)->w = _S866;
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
    uint2  _S867 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S868 = make_int2 ((int)_S867.x, (int)_S867.y);
    float3  _S869 = make_float3 (0.0f);
    FKHit _S870 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S871 = Domain_x24init_0(_S869, _S869, &_S870, 0.0f, 0.0f);
    Domain dom_4 = _S871;
    bool _S872 = (fcptCurrentDomain((_S868), (&dom_4)));
    bool _S873 = !_S872;
    if(_S873)
    {
        Reservoir _S874 = (Reservoir{});
        fcptStoreReservoirPrevious((_S868), (_S874), ((&dom_4)->hit));
        return;
    }
    Reservoir _S875 = (fcptLoadReservoirTemporal((_S868)));
    uint t_15 = 0U;
    float count_4 = 0.0f;
    float c_sum_0 = _S875.c;
    for(;;)
    {
        uint _S876 = (fcptRestirNeighbours());
        if(t_15 < _S876)
        {
        }
        else
        {
            break;
        }
        int2  _S877 = partner_0(_S868, t_15);
        Domain neighbor_0 = _S871;
        bool _S878 = (fcptCurrentDomain((_S877), (&neighbor_0)));
        if(_S878)
        {
            float count_5 = count_4 + 1.0f;
            uint4  _S879 = (fcptReservoirTemporal((_S877), (0U)));
            float c_sum_1 = c_sum_0 + (U32_asfloat((_S879.w)));
            count_4 = count_5;
            c_sum_0 = c_sum_1;
        }
        uint t_16 = t_15 + 1U;
        t_15 = t_16;
    }
    float _S880 = _S875.c / (F32_max((count_4), (1.0f)));
    float _S881 = resamplingTarget(_S875.f);
    bool _S882 = count_4 == 0.0f;
    float _S883 = _slang_select(_S882, 1.0f,0.0f);
    Selection _S884 = (Selection{});
    Selection sel_5 = _S884;
    uint _S885 = (fcptFrame());
    uint _S886 = hash(_S885);
    uint _S887 = global_invocation_id_2.x;
    uint2  _S888 = (fcptRenderSize());
    uint _S889 = stream(_S886, _S887 + _S888.x * global_invocation_id_2.y);
    uint _S890 = stream(_S889, 195U);
    (&sel_5)->random_state = _S890;
    t_15 = 0U;
    float canonical_mis_0 = _S883;
    for(;;)
    {
        uint _S891 = (fcptRestirNeighbours());
        if(t_15 < _S891)
        {
        }
        else
        {
            break;
        }
        int2  _S892 = partner_0(_S868, t_15);
        Domain neighbor_dom_0 = _S871;
        bool _S893 = (fcptCurrentDomain((_S892), (&neighbor_dom_0)));
        if(_S893)
        {
            Reservoir _S894 = (fcptLoadReservoirTemporal((_S892)));
            uint4  _S895 = (fcptShiftData((_S892), (t_15)));
            float4  _S896 = asfloat_0(_S895);
            uint4  _S897 = (fcptShiftData((_S868), (t_15)));
            float4  _S898 = asfloat_0(_S897);
            float _S899 = (_S894.c + _S880) / c_sum_0;
            bool _S900 = _S881 > 0.0f;
            float canonical_mis_1;
            if(_S900)
            {
                float _S901 = _S899 * _S880 * _S881;
                float _S902 = _S880 * _S881;
                float _S903 = resamplingTarget(float3 {_S898.x, _S898.y, _S898.z});
                float canonical_mis_2 = canonical_mis_0 + _S901 / (_S902 + _S894.c * _S903);
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float _S904 = resamplingTarget(_S894.f);
            float3  _S905 = float3 {_S896.x, _S896.y, _S896.z};
            Shift _S906 = Shift_x24init_0(_S905, _S896.w);
            float _S907 = _S899 * _S894.c * _S904;
            float _S908 = _S894.c * _S904;
            float _S909 = resamplingTarget(_S905);
            offerShifted(&sel_5, _S894, _S906, _S907 / (_S908 + _S880 * _S909));
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_17 = t_15 + 1U;
        t_15 = t_17;
    }
    offerShifted(&sel_5, _S875, Shift_x24init_0(_S875.f, 1.0f), canonical_mis_0);
    Reservoir _S910 = finalize(sel_5, c_sum_0);
    fcptStoreReservoirPrevious((_S868), (_S910), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S868), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S868), (make_float4 ((&sel_5)->color.x, (&sel_5)->color.y, (&sel_5)->color.z, 0.0f)));
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
    uint _S911 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S912 = _S911 != 4294967295U;
    if(_S912)
    {
        uint2  _S913 = make_uint2 (_S911, _S911 >> 14U) & make_uint2 (16383U);
        int2  _S914 = make_int2 ((int)_S913.x, (int)_S913.y);
        ShiftJob _S915 = (ShiftJob{});
        ShiftJob shift_job_0 = _S915;
        Shift _S916 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S917 = _S911 >> 28U;
        bool _S918 = spatialJob_0(_S914, _S917, &shift_job_0, true);
        Shift shifted_1;
        if(_S918)
        {
            Domain _S919 = (&shift_job_0)->dom;
            Reservoir _S920 = (&shift_job_0)->r;
            Shift _S921 = passShift_0(&_S919, &_S920);
            shifted_1 = _S921;
        }
        else
        {
            shifted_1 = _S916;
        }
        fcptStoreShiftData((_S914), (_S917), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S922 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S923 = make_int2 ((int)_S922.x, (int)_S922.y);
    FixedArray<uint, 3>  _S924;
    spatialBins_0(_S923, &_S924);
    FixedArray<uint, 3>  _S925 = _S924;
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
        bool _S926 = (_S925[t_18]) == 40U;
        if(_S926)
        {
            fcptStoreShiftData((_S923), (t_18), (make_uint4 (0U)));
        }
        uint t_19 = t_18 + 1U;
        t_18 = t_19;
    }
    FixedArray<uint, 3>  _S927 = _S925;
    queueShifts_0(_S923, &_S927, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S928 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S929 = make_int2 ((int)_S928.x, (int)_S928.y);
    FixedArray<uint, 3>  _S930;
    spatialBins_0(_S929, &_S930);
    FixedArray<uint, 3>  _S931 = _S930;
    countShifts_0(&_S931, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S932 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S933 = _S932 != 4294967295U;
    if(_S933)
    {
        uint2  _S934 = make_uint2 (_S932, _S932 >> 14U) & make_uint2 (16383U);
        int2  _S935 = make_int2 ((int)_S934.x, (int)_S934.y);
        int2  _S936 = storedNeighbor_0(_S935);
        uint _S937 = _S932 >> 28U;
        Shift _S938 = temporalShiftAt_0(_S935, _S936, _S937);
        fcptStoreTemporalShift((_S935), (_S937), (make_uint4 (asuint_1(_S938.f).x, asuint_1(_S938.f).y, asuint_1(_S938.f).z, (F32_asuint((_S938.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S939 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S940 = make_int2 ((int)_S939.x, (int)_S939.y);
    FixedArray<uint, 3>  _S941;
    temporalBins_0(_S940, &_S941);
    FixedArray<uint, 3>  _S942 = _S941;
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
        bool _S943 = (_S942[t_20]) == 40U;
        if(_S943)
        {
            fcptStoreTemporalShift((_S940), (t_20), (make_uint4 (0U)));
        }
        uint t_21 = t_20 + 1U;
        t_20 = t_21;
    }
    FixedArray<uint, 3>  _S944 = _S942;
    queueShifts_0(_S940, &_S944, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S945 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S946 = make_int2 ((int)_S945.x, (int)_S945.y);
    bool _S947 = (fcptSceneUnchanged());
    bool _S948 = !_S947;
    bool _S949;
    if(_S948)
    {
        uint2  _S950 = (fcptRenderSize());
        int2  _S951 = make_int2 ((int)_S950.x, (int)_S950.y);
        _S949 = all_0(_S946 < _S951);
    }
    else
    {
        _S949 = false;
    }
    if(_S949)
    {
        Reservoir _S952 = (fcptLoadReservoirInitial((_S946)));
        int2  _S953 = sampleNeighbor_0(_S946, _S952.seed);
        fcptStoreTemporalNeighbor((_S946), (_S953));
    }
    FixedArray<uint, 3>  _S954;
    temporalBins_0(_S946, &_S954);
    FixedArray<uint, 3>  _S955 = _S954;
    countShifts_0(&_S955, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_9, float b_3, float t_22)
{
    return a_9 + (b_3 - a_9) * t_22;
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S956 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S957 = make_int2 ((int)_S956.x, (int)_S956.y);
    float3  _S958 = make_float3 (0.0f);
    FKHit _S959 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S960 = Domain_x24init_0(_S958, _S958, &_S959, 0.0f, 0.0f);
    Domain dom_5 = _S960;
    bool _S961 = (fcptCurrentDomain((_S957), (&dom_5)));
    bool _S962 = !_S961;
    if(_S962)
    {
        Reservoir _S963 = (Reservoir{});
        fcptStoreReservoirTemporal((_S957), (_S963), ((&dom_5)->hit));
        return;
    }
    Reservoir _S964 = (fcptLoadReservoirInitial((_S957)));
    bool _S965 = (fcptTemporalQueued());
    bool _S966 = (fcptSceneUnchanged());
    bool _S967;
    if(_S966)
    {
        _S967 = true;
    }
    else
    {
        _S967 = !_S965;
    }
    int2  _S968;
    if(_S967)
    {
        int2  _S969 = sampleNeighbor_0(_S957, _S964.seed);
        _S968 = _S969;
    }
    else
    {
        int2  _S970 = storedNeighbor_0(_S957);
        _S968 = _S970;
    }
    bool _S971 = (_S968.x) >= int(0);
    Reservoir r_5;
    if(_S971)
    {
        Reservoir _S972 = (fcptLoadReservoirPrevious((_S968)));
        uint4  _S973 = (fcptDuplication((_S968)));
        float _S974 = (U32_asfloat((_S973.x)));
        uint _S975 = (fcptRestirDecorrelation());
        bool _S976 = _S975 == 1U;
        float _S977 = _slang_select(_S976, _S974,0.0f);
        float _S978 = interpolate_0(20.0f, 1.0f, (F32_pow((_S977), (0.10000000149011612f))));
        float _S979 = (F32_min((_S972.c), (_S978)));
        bool _S980 = (fcptSceneUnchanged());
        float4  _S981 = make_float4 (_S972.f.x, _S972.f.y, _S972.f.z, 1.0f);
        bool _S982 = !_S980;
        if(_S982)
        {
            _S967 = _S965;
        }
        else
        {
            _S967 = false;
        }
        float4  to_current_0;
        if(_S967)
        {
            uint4  _S983 = (fcptTemporalShift((_S957), (0U)));
            float4  _S984 = asfloat_0(_S983);
            to_current_0 = _S984;
        }
        else
        {
            if(_S982)
            {
                Shift _S985 = temporalShiftAt_0(_S957, _S968, 0U);
                float4  _S986 = make_float4 (_S985.f.x, _S985.f.y, _S985.f.z, _S985.jac);
                to_current_0 = _S986;
            }
            else
            {
                to_current_0 = _S981;
            }
        }
        Domain own_1 = _S960;
        if(_S980)
        {
            _S967 = true;
        }
        else
        {
            bool _S987 = (fcptPreviousScenes());
            bool _S988 = !_S987;
            if(_S988)
            {
                _S967 = (_S964.w) > 0.0f;
            }
            else
            {
                _S967 = false;
            }
            if(_S967)
            {
                bool _S989 = (fcptStoredDomainInitial((_S957), (_S964.seed), (&own_1)));
                _S967 = _S989;
            }
            else
            {
                _S967 = false;
            }
            if(_S967)
            {
                Domain _S990 = (fcptPreviousDomain((_S968), (_S964.seed)));
                Domain _S991 = _S990;
                Domain _S992 = own_1;
                bool _S993 = sameDomain_0(&_S991, &_S992);
                _S967 = _S993;
            }
            else
            {
                _S967 = false;
            }
        }
        float4  _S994 = make_float4 (_S964.f.x, _S964.f.y, _S964.f.z, 1.0f);
        bool _S995 = !_S967;
        if(_S995)
        {
            _S967 = _S965;
        }
        else
        {
            _S967 = false;
        }
        float4  to_previous_0;
        if(_S967)
        {
            uint4  _S996 = (fcptTemporalShift((_S957), (1U)));
            float4  _S997 = asfloat_0(_S996);
            to_previous_0 = _S997;
        }
        else
        {
            if(_S995)
            {
                Shift _S998 = temporalShiftAt_0(_S957, _S968, 1U);
                float4  _S999 = make_float4 (_S998.f.x, _S998.f.y, _S998.f.z, _S998.jac);
                to_previous_0 = _S999;
            }
            else
            {
                to_previous_0 = _S994;
            }
        }
        float _S1000 = resamplingTarget(_S964.f);
        float _S1001 = resamplingTarget(_S972.f);
        Selection _S1002 = (Selection{});
        Selection sel_6 = _S1002;
        uint _S1003 = (fcptFrame());
        uint _S1004 = hash(_S1003);
        uint _S1005 = global_invocation_id_7.x;
        uint2  _S1006 = (fcptRenderSize());
        uint _S1007 = stream(_S1004, _S1005 + _S1006.x * global_invocation_id_7.y);
        uint _S1008 = stream(_S1007, 194U);
        (&sel_6)->random_state = _S1008;
        float _S1009 = _S964.c * _S1000;
        float4  _S1010 = to_previous_0;
        float _S1011 = resamplingTarget(float3 {_S1010.x, _S1010.y, _S1010.z});
        float _S1012 = _S1009 / (_S1009 + _S979 * _S1011);
        float _S1013 = _S979 * _S1001;
        float4  _S1014 = to_current_0;
        float3  _S1015 = float3 {_S1014.x, _S1014.y, _S1014.z};
        float _S1016 = resamplingTarget(_S1015);
        float _S1017 = _S1013 / (_S1013 + _S964.c * _S1016);
        float2  _S1018 = make_float2 (_S1012, _S1017);
        offerShifted(&sel_6, _S964, Shift_x24init_0(_S964.f, 1.0f), _S1012);
        offerShifted(&sel_6, _S972, Shift_x24init_0(_S1015, to_current_0.w), _S1017);
        Reservoir _S1019 = finalize(sel_6, _S964.c + _S979);
        r_5 = _S1019;
    }
    else
    {
        r_5 = _S964;
    }
    fcptStoreReservoirTemporal((_S957), (r_5), ((&dom_5)->hit));
    return;
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S1020 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S1021 = make_int2 ((int)_S1020.x, (int)_S1020.y);
    float3  _S1022 = make_float3 (0.0f);
    float2  _S1023 = make_float2 (0.0f);
    FKHit _S1024 = Hit_x24init_0(_S1023, 0U, 0U, 0U, 0.0f);
    Domain _S1025 = Domain_x24init_0(_S1022, _S1022, &_S1024, 0.0f, 0.0f);
    Domain dom_6 = _S1025;
    bool _S1026 = (fcptCurrentDomain((_S1021), (&dom_6)));
    bool _S1027 = !_S1026;
    if(_S1027)
    {
        Reservoir _S1028 = (Reservoir{});
        fcptStoreReservoirInitial((_S1021), (_S1028), ((&dom_6)->hit));
        return;
    }
    uint _S1029 = (fcptFrame());
    uint _S1030 = hash(_S1029);
    uint _S1031 = global_invocation_id_8.x;
    uint2  _S1032 = (fcptRenderSize());
    uint _S1033 = stream(_S1030, _S1031 + _S1032.x * global_invocation_id_8.y);
    Selection _S1034 = (Selection{});
    Selection initial_0 = _S1034;
    uint _S1035 = stream(_S1033, 193U);
    (&initial_0)->random_state = _S1035;
    bool _S1036 = (fcptRestirUsed());
    bool _S1037 = !_S1036;
    (&initial_0)->sums = _S1037;
    uint _S1038 = stream(_S1033, 0U);
    (&(&initial_0)->r)->seed = _S1038;
    FKHit _S1039 = Hit_x24init_0(_S1023, 4294967295U, 0U, 0U, 0.0f);
    uint _S1040 = (fcptSamples());
    float _S1041 = 1.0f / float(_S1040);
    FKHit hit_2 = _S1039;
    uint i_20 = 0U;
    float3  seen_1 = _S1022;
    for(;;)
    {
        uint _S1042 = (fcptSamples());
        if(i_20 < _S1042)
        {
        }
        else
        {
            break;
        }
        Reservoir _S1043 = (Reservoir{});
        Reservoir r_6 = _S1043;
        uint _S1044 = stream(_S1033, i_20);
        (&r_6)->seed = _S1044;
        Domain path_0 = _S1025;
        bool _S1045 = (fcptStoredDomainInitial((_S1021), ((&r_6)->seed), (&path_0)));
        bool _S1046 = !_S1045;
        if(_S1046)
        {
            float3  _S1047 = (fcptMissed((_S1021), (path_0), (_S1041)));
            float3  seen_2 = seen_1 + _S1047;
            seen_1 = seen_2;
            uint i_21 = i_20 + 1U;
            i_20 = i_21;
            continue;
        }
        Domain _S1048 = path_0;
        Reservoir _S1049 = r_6;
        Shift _S1050 = passWalk_0(&_S1048, &_S1049, false, _S1041, &initial_0);
        bool _S1051 = ((&(&initial_0)->r)->seed) == ((&r_6)->seed);
        FKHit hit_3;
        if(_S1051)
        {
            FKHit _S1052 = (&path_0)->hit;
            hit_3 = _S1052;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_21 = i_20 + 1U;
        i_20 = i_21;
    }
    uint _S1053 = (fcptSamples());
    float3  seen_3 = seen_1 + (&initial_0)->glow / make_float3 (float(_S1053));
    float3  _S1054 = seen_3 + (&initial_0)->color;
    bool _S1055 = (&initial_0)->sums;
    float3  _S1056 = _slang_select(_S1055, _S1054,seen_3);
    fcptAddColor((_S1021), (make_float4 (_S1056.x, _S1056.y, _S1056.z, 1.0f)));
    Reservoir _S1057 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S1021), (_S1057), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_4, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S1058;
    (&_S1058)->none = none_0;
    (&_S1058)->pdf = pdf_4;
    (&_S1058)->origin = origin_5;
    (&_S1058)->smooth_n = smooth_n_3;
    (&_S1058)->start = start_6;
    return _S1058;
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
    Vertex _S1059;
    (&_S1059)->rough = rough_0;
    (&_S1059)->lobe = lobe_1;
    (&_S1059)->pdf = pdf_5;
    (&_S1059)->cos = cos_0;
    (&_S1059)->inside = inside_0;
    return _S1059;
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
    float3  _S1060 = exp_0((make_float3 (sigma_0) - extinction_0) * make_float3 (distance_2));
    float3  _S1061 = scatter_0 * _S1060 / make_float3 (sigma_0);
    float3  _S1062 = _slang_select(scatters_0, _S1061,_S1060);
    return _S1062;
}

static __device__ uint arrivalLobe_0(uint b_4, uint prev_lobe_0)
{
    bool _S1063 = b_4 > 0U;
    uint _S1064 = _slang_select(_S1063, prev_lobe_0,3U);
    return _S1064;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_2, uint lobe_2, bool surface_6, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S1065;
    (&_S1065)->extinction_behind = extinction_behind_0;
    (&_S1065)->extinction_front = extinction_front_0;
    (&_S1065)->fillings = fillings_0;
    (&_S1065)->side = side_0;
    (&_S1065)->depth = depth_2;
    (&_S1065)->lobe = lobe_2;
    (&_S1065)->surface = surface_6;
    (&_S1065)->length = length_2;
    (&_S1065)->width = width_1;
    (&_S1065)->own = *own_2;
    (&_S1065)->fiber = fiber_0;
    return _S1065;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S1066 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S1066)
    {
        return 0.07957746833562851f;
    }
    float _S1067 = g_0 * g_0;
    return (1.0f - _S1067) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S1067 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_10, float3  b_5)
{
    float3  _S1068 = a_10 / b_5;
    float3  _S1069 = make_float3 (0.0f);
    bool3  _S1070 = b_5 == _S1069;
    float3  _S1071 = _slang_select(_S1070, _S1069,_S1068);
    return _S1071;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_6)
{
    uint _S1072 = (1U << count_6) - 1U;
    return (e_2 & (~(_S1072 << offset_1))) | ((newbits_0 & _S1072) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_7, uint end_type_0, uint end_0, float3  f_6)
{
    Reservoir candidate_2 = r_7;
    uint _S1073 = insertBits_0(r_7.path, end_0, 0U, 5U);
    uint _S1074 = insertBits_0(_S1073, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S1074;
    (&candidate_2)->f = f_6;
    return candidate_2;
}

__device__ float survivalProbability(float3  throughput_0, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_0.x), ((F32_max((throughput_0.y), (throughput_0.z)))))) / density_1), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_10)
{
    Random _S1075 = pcg(random_state_10);
    Random _S1076 = pcg(_S1075.state);
    float _S1077 = 1.0f - 2.0f * _S1075.value;
    float _S1078 = (F32_sqrt(((F32_max((1.0f - _S1077 * _S1077), (0.0f))))));
    float _S1079 = 6.28318548202514648f * _S1076.value;
    return make_float3 (_S1078 * (F32_cos((_S1079))), _S1078 * (F32_sin((_S1079))), _S1077);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_12, uint random_state_11, float * pdf_6)
{
    bool _S1080 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1080)
    {
        *pdf_6 = 0.07957746833562851f;
        float3  _S1081 = isotropic_0(random_state_11);
        return _S1081;
    }
    Random _S1082 = pcg(random_state_11);
    Random _S1083 = pcg(_S1082.state);
    float _S1084 = g_1 * g_1;
    float _S1085 = 2.0f * g_1;
    float _S1086 = (1.0f - _S1084) / (1.0f - g_1 + _S1085 * _S1082.value);
    float _S1087 = clamp_1((1.0f + _S1084 - _S1086 * _S1086) / _S1085, -1.0f, 1.0f);
    float _S1088 = (F32_sqrt(((F32_max((1.0f - _S1087 * _S1087), (0.0f))))));
    float _S1089 = 6.28318548202514648f * _S1083.value;
    float _S1090 = phaseHG_0(g_1, _S1087);
    *pdf_6 = _S1090;
    float3  _S1091 = tangentToWorld(make_float3 (_S1088 * (F32_cos((_S1089))), _S1087, _S1088 * (F32_sin((_S1089)))), dir_12);
    float3  _S1092 = ((((_S1091)) * make_float3(rnorm3df(((_S1091)).x, ((_S1091)).y, ((_S1091)).z))));
    return _S1092;
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_1, float3  emissive_1, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_1, float velvet_0, float3  toon_2, float dispersion_0)
{
    BSDFMaterial _S1093;
    (&_S1093)->albedo = albedo_1;
    (&_S1093)->emissive = emissive_1;
    (&_S1093)->roughness = roughness_0;
    (&_S1093)->metallic = metallic_0;
    (&_S1093)->transmission = transmission_0;
    (&_S1093)->ior = ior_0;
    (&_S1093)->absorption = absorption_0;
    (&_S1093)->specular_tint = specular_tint_0;
    (&_S1093)->specular_level = specular_level_0;
    (&_S1093)->translucent = translucent_0;
    (&_S1093)->sheen = sheen_2;
    (&_S1093)->sheen_roughness = sheen_roughness_0;
    (&_S1093)->anisotropy = anisotropy_0;
    (&_S1093)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1093)->tangent = tangent_1;
    (&_S1093)->velvet = velvet_0;
    (&_S1093)->toon = toon_2;
    (&_S1093)->dispersion = dispersion_0;
    return _S1093;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1094;
    (&_S1094)->scatter = scatter_1;
    (&_S1094)->extinction = extinction_1;
    (&_S1094)->g = g_2;
    return _S1094;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_10, bool skip_0, uint random_state_12, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1095;
    (&_S1095)->smooth_n = smooth_n_4;
    (&_S1095)->geometry_n = geometry_n_2;
    (&_S1095)->geometry_offset = geometry_offset_2;
    (&_S1095)->material = *material_10;
    (&_S1095)->skip = skip_0;
    (&_S1095)->random_state = random_state_12;
    (&_S1095)->coverage = coverage_0;
    (&_S1095)->encloses = encloses_0;
    (&_S1095)->volume = *volume_0;
    (&_S1095)->fills = fills_0;
    (&_S1095)->hair = hair_0;
    return _S1095;
}

static __device__ FKSurface emitting_0(FKSurface * surface_7, bool top_0)
{
    FKSurface lower_0 = *surface_7;
    float3  _S1096 = (&surface_7->material)->emissive;
    float3  _S1097 = make_float3 (0.0f);
    bool _S1098 = !top_0;
    float3  _S1099 = _slang_select(_S1098, _S1097,_S1096);
    (&(&lower_0)->material)->emissive = _S1099;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_8, float u_1)
{
    float _S1100 = surface_8->coverage;
    bool _S1101 = u_1 < _S1100;
    if(_S1101)
    {
        return *surface_8;
    }
    float3  _S1102 = make_float3 (0.0f);
    float3  _S1103 = make_float3 (1.0f);
    BSDFMaterial _S1104 = Material_x24init_0(_S1102, _S1102, 0.0f, 0.0f, 0.0f, 0.0f, _S1102, _S1103, 1.0f, _S1102, _S1102, 0.5f, 0.0f, 0.0f, _S1102, 0.0f, _S1102, 0.0f);
    BSDFMaterial material_11 = _S1104;
    (&material_11)->albedo = _S1103;
    (&material_11)->emissive = (&surface_8->material)->emissive;
    (&material_11)->transmission = 1.0f;
    (&material_11)->ior = 1.0f;
    (&material_11)->absorption = (&surface_8->material)->absorption;
    FKSurface through_0 = *surface_8;
    (&through_0)->material = material_11;
    return through_0;
}

__device__ float facingSign(float transmission_1, float3  face_0, float3  direction_0)
{
    bool _S1105 = transmission_1 > 0.0f;
    bool _S1106;
    if(_S1105)
    {
        _S1106 = true;
    }
    else
    {
        _S1106 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1107 = _slang_select(_S1106, 1.0f,-1.0f);
    return _S1107;
}

static __device__ bool arrivesBehind_0(float3  dir_13, float3  n_9)
{
    return (dot_0(dir_13, n_9)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_9, float3  dir_14)
{
    float3  _S1108 = surface_9->geometry_n;
    float _S1109 = facingSign((&surface_9->material)->transmission, surface_9->geometry_n, dir_14);
    FKSurface faced_0 = *surface_9;
    float3  _S1110 = surface_9->smooth_n * make_float3 (_S1109);
    (&faced_0)->smooth_n = _S1110;
    float3  _S1111 = _S1108 * make_float3 (_S1109);
    (&faced_0)->geometry_n = _S1111;
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
    float3  _S1112 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1112));
}

__device__ bool dispersive(BSDFMaterial material_12)
{
    bool _S1113 = (material_12.dispersion) > 0.0f;
    bool _S1114;
    if(_S1113)
    {
        _S1114 = (material_12.ior) != 1.0f;
    }
    else
    {
        _S1114 = false;
    }
    return _S1114;
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
        uint _S1115 = (low_1 + high_1 + 1U) / 2U;
        bool _S1116 = (WAVELENGTH_CDF_0[_S1115]) <= u_2;
        if(_S1116)
        {
            low_1 = _S1115;
        }
        else
        {
            uint _S1117 = _S1115 - 1U;
            high_1 = _S1117;
        }
    }
    uint _S1118 = low_1;
    float _S1119 = WAVELENGTH_CDF_0[low_1 + 1U] - WAVELENGTH_CDF_0[low_1];
    return make_float2 (0.37999999523162842f + 0.00499999988824129f * (float(low_1) + (u_2 - WAVELENGTH_CDF_0[_S1118]) / _S1119), _S1119 / 0.00499999988824129f);
}

__device__ static const FixedArray<float, 243>  WAVELENGTH_WEIGHTS_0 = { {
    0.00547470012679696f, -0.00465690018609166f, 0.03257500007748604f, 0.00934640038758516f, -0.00796370021998882f, 0.05577300116419792f, 0.01846100017428398f, -0.01579399965703487f, 0.11072999984025955f, 0.0416410006582737f, -0.03577499836683273f, 0.2513900101184845f, 0.09349299967288971f, -0.08071800321340561f, 0.56742000579833984f, 0.1585099995136261f, -0.13764999806880951f, 0.97018998861312866f, 0.30943000316619873f, -0.27083000540733337f, 1.91740000247955322f, 0.55217999219894409f, -0.48754000663757324f, 3.46889996528625488f, 0.95016998052597046f, -0.84802001714706421f, 6.09439992904663086f, 1.42110002040863037f, -1.28929996490478516f, 9.45199966430664062f, 1.73409998416900635f, -1.6062999963760376f, 12.12800025939941406f, 2.08030009269714355f, -1.98810005187988281f, 15.68700027465820312f, 2.20600008964538574f, -2.20120000839233398f, 18.47699928283691406f, 2.03040003776550293f, -2.17700004577636719f, 19.92700004577636719f, 1.63429999351501465f, -2.00340008735656738f, 20.86899948120117188f, 0.99410998821258545f, -1.62629997730255127f, 20.57799911499023438f, 0.20011000335216522f, -1.11409997940063477f, 19.72100067138671875f, -0.67960000038146973f, -0.45403000712394714f, 17.77599906921386719f, -1.61679995059967041f, 0.37860000133514404f, 14.71500015258789062f, -2.53410005569458008f, 1.27540004253387451f, 11.86499977111816406f, -3.39079999923706055f, 2.2146000862121582f, 9.17669963836669922f, -4.03749990463256836f, 3.0522000789642334f, 6.59509992599487305f, -4.61299991607666016f, 3.89779996871948242f, 4.64589977264404297f, -5.43039989471435547f, 5.0121002197265625f, 3.3199000358581543f, -6.37769985198974609f, 6.33809995651245117f, 2.29699993133544922f, -7.44140005111694336f, 7.91739988327026367f, 1.45389997959136963f, -8.38580036163330078f, 9.60109996795654297f, 0.66465997695922852f, -9.0167999267578125f, 11.23999977111816406f, -0.04403600096702576f, -9.17749977111816406f, 12.63199996948242188f, -0.58126997947692871f, -8.97550010681152344f, 13.91499996185302734f, -0.95730000734329224f, -8.25290012359619141f, 14.86200046539306641f, -1.24430000782012939f, -6.92129993438720703f, 15.03899955749511719f, -1.43069994449615479f, -5.29169988632202148f, 14.90900039672851562f, -1.55149996280670166f, -3.43219995498657227f, 14.70499992370605469f, -1.63569998741149902f, -1.27190005779266357f, 14.24400043487548828f, -1.67030000686645508f, 1.15170001983642578f, 13.32199954986572266f, -1.636199951171875f, 3.73889994621276855f, 12.21199989318847656f, -1.56920003890991211f, 6.43590021133422852f, 10.94699954986572266f, -1.47730004787445068f, 9.16440010070800781f, 9.54769992828369141f, -1.36399996280670166f, 12.02000045776367188f, 8.18799972534179688f, -1.25450003147125244f, 14.78699970245361328f, 6.74429988861083984f, -1.13110005855560303f, 16.72299957275390625f, 5.08780002593994141f, -0.96561002731323242f, 18.14299964904785156f, 3.57019996643066406f, -0.80725997686386108f, 19.91900062561035156f, 2.36269998550415039f, -0.69273000955581665f, 21.05500030517578125f, 1.31369996070861816f, -0.58597999811172485f, 21.3899993896484375f, 0.42390000820159912f, -0.48298001289367676f, 20.99300003051757812f, -0.23857000470161438f, -0.39412000775337219f, 19.82200050354003906f, -0.6866300106048584f, -0.31501999497413635f, 18.12000083923339844f, -0.9412500262260437f, -0.24890999495983124f, 15.7089996337890625f, -1.02020001411437988f, -0.19076000154018402f, 13.19799995422363281f, -0.98919999599456787f, -0.14401000738143921f, 11.23999977111816406f, -0.93347001075744629f, -0.11133000254631042f, 9.36649990081787109f, -0.83820998668670654f, -0.08524099737405777f, 7.41249990463256836f, -0.70064002275466919f, -0.06283199787139893f, 5.71229982376098633f, -0.56079000234603882f, -0.04586699977517128f, 4.42280006408691406f, -0.44653001427650452f, -0.03396600112318993f, 3.34489989280700684f, -0.34457001090049744f, -0.02482499927282333f, 2.49309992790222168f, -0.26017999649047852f, -0.01808100007474422f, 1.82239997386932373f, -0.1921599954366684f, -0.01296999957412481f, 1.29499995708465576f, -0.13766999542713165f, -0.00907570030540228f, 0.92928999662399292f, -0.09956400096416473f, -0.00641620019450784f, 0.61835998296737671f, -0.06671299785375595f, -0.00421149982139468f, 0.40211999416351318f, -0.04354599863290787f, -0.00271830009296536f, 0.2844499945640564f, -0.03087200038135052f, -0.00191440002527088f, 0.20672999322414398f, -0.02246100082993507f, -0.00138829997740686f, 0.15044000744819641f, -0.01634499989449978f, -0.00101030000951141f, 0.10942000150680542f, -0.01188699994236231f, -0.0007347899954766f, 0.07099699974060059f, -0.00771349994465709f, -0.00047679000999779f, 0.04539500176906586f, -0.00493190018460155f, -0.00030484999297187f, 0.03424099832773209f, -0.00372010003775358f, -0.00022995000472292f, 0.02557599917054176f, -0.00277870008721948f, -0.00017175999528263f, 0.01842200011014938f, -0.00200140010565519f, -0.0001237099932041f, 0.01316899992525578f, -0.00143079995177686f, -0.00008843900286593f, 0.00838890019804239f, -0.00091141002485529f, -0.00005633700129692f, 0.00537079991772771f, -0.00058350997278467f, -0.00003606799873523f, 0.00328280008397996f, -0.00035665999166667f, -0.00002204600059486f, 0.00196009990759194f, -0.00021296000340953f, -0.00001316300040344f, 0.00168939994182438f, -0.00018354000349063f, -0.00001134499962063f, 0.00141050003003329f, -0.00015325000276789f, -0.00000947250009631f, 0.00097123999148607f, -0.00010551999730524f, -6.52239987175562419e-06f, 0.00066868000430986f, -0.00007264900341397f, -4.49060007667867467e-06f
} };
__device__ float3  wavelengthWeights(float wavelength_0)
{
    float _S1120 = clamp_1((wavelength_0 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    uint _S1121 = (U32_min((uint(_S1120)), (79U)));
    uint _S1122 = 3U * _S1121;
    float3  _S1123 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1122], WAVELENGTH_WEIGHTS_0[_S1122 + 1U], WAVELENGTH_WEIGHTS_0[_S1122 + 2U]);
    float3  _S1124 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1122 + 3U], WAVELENGTH_WEIGHTS_0[_S1122 + 4U], WAVELENGTH_WEIGHTS_0[_S1122 + 5U]);
    return _S1123 + (_S1124 - _S1123) * make_float3 (_S1120 - float(_S1121));
}

__device__ float dispersedIor(float ior_1, float dispersion_1, float wavelength_1)
{
    float _S1125 = (ior_1 - 1.0f) * dispersion_1 / 1.90962409973144531f;
    float _S1126 = _S1125 * (1.0f / (wavelength_1 * wavelength_1) - 2.89662933349609375f);
    bool _S1127 = dispersion_1 > 0.0f;
    float _S1128 = _slang_select(_S1127, _S1126,0.0f);
    return ior_1 + _S1128;
}

__device__ float2  vertexEta(BSDFMaterial material_13, float n_dot_v_0)
{
    bool _S1129 = n_dot_v_0 < 0.0f;
    float _S1130 = _slang_select(_S1129, material_13.ior,1.0f);
    float _S1131 = _slang_select(_S1129, 1.0f,material_13.ior);
    return make_float2 (_S1130, _S1131);
}

__device__ bool neeDecision(BSDFMaterial material_14, float n_dot_v_1, float eta_i_5, float eta_o_5)
{
    float _S1132 = fresnel((F32_abs((n_dot_v_1))), eta_i_5, eta_o_5);
    float3  _S1133 = mix_0(make_float3 (_S1132), material_14.albedo, material_14.metallic);
    float _S1134 = rgb_to_greyscale(_S1133);
    float _S1135 = (F32_max(((1.0f - _S1134) * (1.0f - material_14.metallic) * (1.0f - material_14.transmission)), (0.0f)));
    bool _S1136 = _S1135 > 0.03999999910593033f;
    bool _S1137;
    if(_S1136)
    {
        _S1137 = true;
    }
    else
    {
        _S1137 = (material_14.roughness) > 0.20000000298023224f;
    }
    return _S1137;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_15)
{
    float _S1138 = rgb_to_greyscale(material_15->translucent);
    return _S1138 > 0.0f;
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
    MediumSides _S1139;
    (&_S1139)->behind = *behind_0;
    (&_S1139)->front = *front_0;
    (&_S1139)->fillings = fillings_1;
    (&_S1139)->face = face_1;
    return _S1139;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_10, FKMedium * medium_0, uint filling_0, float3  dir_15, FKMedium * outside_0)
{
    float3  _S1140 = surface_10->geometry_n;
    MediumSides _S1141 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_10->geometry_n);
    MediumSides sides_0 = _S1141;
    bool _S1142 = surface_10->encloses;
    if(_S1142)
    {
        (&sides_0)->behind = surface_10->volume;
        *&((&(&sides_0)->fillings)->x) = surface_10->fills;
        bool _S1143 = (dot_0(dir_15, _S1140)) > 0.0f;
        if(_S1143)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_11, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_16, uint depth_3, uint lobe_3, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1144 = surface_11->geometry_n;
    ShadowContext _S1145 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_11->geometry_n, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
    bool _S1146 = surface_11->encloses;
    ShadowContext context_4;
    if(_S1146)
    {
        FKSurface faced_1 = *surface_11;
        float3  _S1147 = - _S1144;
        float3  _S1148 = _slang_select(turned_0, _S1147,_S1144);
        (&faced_1)->geometry_n = _S1148;
        FKMedium _S1149 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1150 = faced_1;
        FKMedium _S1151 = _S1149;
        MediumSides _S1152 = mediumSides_0(&_S1150, &_S1151, filling_1, dir_16, outside_1);
        ShadowContext _S1153 = ShadowContext_x24init_0(_S1152.behind.extinction, _S1152.front.extinction, _S1152.fillings, _S1144, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
        if(turned_0)
        {
            uint2  _S1154 = _S1152.fillings;
            ShadowContext _S1155 = ShadowContext_x24init_0(_S1152.front.extinction, _S1152.behind.extinction, uint2 {_S1154.y, _S1154.x}, _S1144, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
            context_4 = _S1155;
        }
        else
        {
            context_4 = _S1153;
        }
    }
    else
    {
        context_4 = _S1145;
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

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_8, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_3, BSDFMaterial * material_16, float eta_i_6, float eta_o_6, bool competing_1, uint random_state_13)
{
    float3  _S1156 = light_2->dir;
    bool _S1157 = (dot_0(geometry_n_3, - in_dir_8) * dot_0(geometry_n_3, light_2->dir)) <= 0.0f;
    FixedArray<float3 , 5>  throughputs_1;
    FixedArray<float, 5>  pdfs_4;
    float3  _S1158 = BSDF(in_dir_8, _S1156, smooth_n_5, *material_16, eta_i_6, eta_o_6, _S1157, random_state_13, &throughputs_1, &pdfs_4);
    bool _S1159 = !competing_1;
    bool _S1160;
    if(_S1159)
    {
        _S1160 = true;
    }
    else
    {
        _S1160 = (light_2->density) == 0.0f;
    }
    if(_S1160)
    {
        return _S1158 * light_2->radiance;
    }
    float3  _S1161 = make_float3 (0.0f);
    uint i_26 = 0U;
    float3  weighted_0 = _S1161;
    for(;;)
    {
        if(i_26 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S1162 = (pdfs_4[i_26]) > 0.0f;
        if(_S1162)
        {
            float _S1163 = light_2->density;
            float _S1164 = pdfs_4[i_26] / light_2->density;
            float3  weighted_1 = weighted_0 + throughputs_1[i_26] * make_float3 (pdfs_4[i_26]) / make_float3 (_S1163 * (1.0f + _S1164 * _S1164));
            weighted_0 = weighted_1;
        }
        uint i_27 = i_26 + 1U;
        i_26 = i_27;
    }
    return weighted_0 * light_2->radiance * make_float3 (light_2->density);
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_1, uint random_state_14, bool refracted_3, uint lobe_4, float pdf_7)
{
    SampleBSDF _S1165;
    (&_S1165)->unit_direction = unit_direction_1;
    (&_S1165)->throughput = throughput_1;
    (&_S1165)->random_state = random_state_14;
    (&_S1165)->refracted = refracted_3;
    (&_S1165)->lobe = lobe_4;
    (&_S1165)->pdf = pdf_7;
    return _S1165;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  v_9, float3  n_i_13, float n_i_dot_v_3, BSDFMaterial material_17, Weights w_14, uint random_state_15)
{
    float3  _S1166 = make_float3 (1.0f);
    SampleBSDF _S1167 = SampleBSDF_x24init_0(_S1166, _S1166, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S1167;
    Random _S1168 = pcg(random_state_15);
    Random _S1169 = pcg(_S1168.state);
    (&sample_1)->random_state = _S1169.state;
    float _S1170 = _S1168.value;
    float _S1171 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1170 * _S1170))))));
    float _S1172 = 6.28318548202514648f * _S1169.value;
    float3  _S1173 = tangentToWorld(make_float3 (_S1171 * (F32_cos((_S1172))), _S1168.value, _S1171 * (F32_sin((_S1172)))), n_i_13);
    (&sample_1)->unit_direction = _S1173;
    (&sample_1)->lobe = 4U;
    float3  _S1174 = sheenVelvetBSDF((&sample_1)->unit_direction, v_9, n_i_13, material_17, w_14);
    (&sample_1)->throughput = _S1174;
    float _S1175 = sheenVelvetPDF(_S1168.value, n_i_dot_v_3, w_14);
    (&sample_1)->pdf = _S1175;
    return sample_1;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1176 = (F32_sqrt((random_1_0)));
    float _S1177 = 6.28318548202514648f * random_2_0;
    float _S1178 = _S1176 * (F32_cos((_S1177)));
    float _S1179 = _S1176 * (F32_sin((_S1177)));
    float _S1180 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1178 * _S1178 - _S1179 * _S1179))))));
    return make_float3 (_S1178, _S1180, _S1179);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_3, float3  n_i_14, float n_i_dot_v_4, BSDFMaterial material_18, Weights w_15, uint random_state_16)
{
    float3  _S1181 = make_float3 (1.0f);
    SampleBSDF _S1182 = SampleBSDF_x24init_0(_S1181, _S1181, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S1182;
    Random _S1183 = pcg(random_state_16);
    Random _S1184 = pcg(_S1183.state);
    (&sample_2)->random_state = _S1184.state;
    float3  _S1185 = sampleCosWeightedHemisphere(_S1183.value, _S1184.value);
    float _S1186 = translucentShare(material_18);
    bool _S1187 = u_3 < (w_15.p_diffuse * _S1186);
    float _S1188 = _S1185.y;
    float _S1189 = - _S1188;
    float _S1190 = _slang_select(_S1187, _S1189,_S1188);
    float3  _S1191 = tangentToWorld(make_float3 (_S1185.x, _S1190, _S1185.z), n_i_14);
    (&sample_2)->unit_direction = _S1191;
    (&sample_2)->refracted = _S1187;
    (&sample_2)->lobe = 0U;
    float3  _S1192 = diffuseBSDF((&sample_2)->unit_direction, n_i_14, material_18, w_15);
    (&sample_2)->throughput = _S1192;
    float _S1193 = diffusePDF(_S1190, n_i_dot_v_4, material_18, w_15);
    (&sample_2)->pdf = _S1193;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF toonSample(float3  n_i_15, ToonProfile profile_3, Weights w_16, uint random_state_17)
{
    float3  _S1194 = make_float3 (1.0f);
    Random _S1195 = pcg(random_state_17);
    Random _S1196 = pcg(_S1195.state);
    float _S1197 = _S1195.value * profile_3.norm / 6.28318548202514648f;
    float _S1198 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1197)))), (1.0f))))));
    float _S1199 = (F32_acos((clamp_1(1.0f - _S1197, -1.0f, 1.0f))));
    float _S1200 = _slang_select(profile_3.glossy, _S1199,_S1198);
    float _S1201 = (profile_3.a + profile_3.b) / 2.0f;
    bool _S1202 = _S1200 < (profile_3.a);
    float _S1203 = _slang_select(_S1202, _S1200,_S1201);
    float t_23 = _S1203;
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
        float _S1204 = toonP(t_23, profile_3.a, profile_3.s);
        float _S1205 = _S1204 * (F32_sin((t_23)));
        float _S1206 = (F32_cos((t_23)));
        float _S1207 = _slang_select(profile_3.glossy, 1.0f,_S1206);
        float _S1208 = _S1205 * _S1207;
        float _S1209 = toonIntegral(t_23, profile_3.a, profile_3.s, profile_3.glossy);
        float _S1210 = (_S1209 - _S1197) / _S1208;
        bool _S1211 = _S1208 > 0.0f;
        float _S1212 = _slang_select(_S1211, _S1210,0.0f);
        float _S1213 = clamp_1(t_23 - _S1212, 0.0f, profile_3.b);
        int k_1 = k_0 + int(1);
        t_23 = _S1213;
        k_0 = k_1;
    }
    float _S1214 = 6.28318548202514648f * _S1196.value;
    float _S1215 = (F32_sin((t_23)));
    float3  _S1216 = tangentToWorld(make_float3 (_S1215 * (F32_cos((_S1214))), (F32_cos((t_23))), _S1215 * (F32_sin((_S1214)))), profile_3.axis);
    float3  _S1217 = toonBSDF(_S1216, n_i_15, profile_3, w_16);
    bool _S1218 = (dot_0(n_i_15, _S1216)) < 0.0f;
    float _S1219 = toonPDF(_S1216, n_i_15, profile_3, w_16);
    return SampleBSDF_x24init_0(_S1216, _S1217, _S1196.state, _S1218, 6U, _S1219);
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_16, float alpha_8, AnisotropicFrame frame_6, BSDFMaterial material_19, Weights w_17, float pdf_h_3, float eta_i_7, float eta_o_7, uint random_state_18)
{
    float3  _S1220 = make_float3 (1.0f);
    SampleBSDF _S1221 = SampleBSDF_x24init_0(_S1220, _S1220, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S1221;
    (&sample_3)->unit_direction = w_17.refracted;
    (&sample_3)->random_state = random_state_18;
    (&sample_3)->refracted = true;
    (&sample_3)->lobe = 1U;
    float3  _S1222 = refractBSDF((&sample_3)->unit_direction, n_i_16, alpha_8, frame_6, material_19, w_17);
    (&sample_3)->throughput = _S1222;
    float _S1223 = refractPDF(dot_0((&sample_3)->unit_direction, ggx_n_3), pdf_h_3, w_17, eta_i_7, eta_o_7);
    (&sample_3)->pdf = _S1223;
    return sample_3;
}

static __device__ float3  reflect_0(float3  i_28, float3  n_10)
{
    return i_28 - make_float3 (2.0f * dot_0(n_10, i_28)) * n_10;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_9, float3  ggx_n_4, float3  n_i_17, float alpha_9, AnisotropicFrame frame_7, Weights w_18, float pdf_h_4, uint random_state_19)
{
    float3  _S1224 = make_float3 (1.0f);
    SampleBSDF _S1225 = SampleBSDF_x24init_0(_S1224, _S1224, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S1225;
    float3  _S1226 = reflect_0(in_dir_9, ggx_n_4);
    float3  _S1227 = ((((_S1226)) * make_float3(rnorm3df(((_S1226)).x, ((_S1226)).y, ((_S1226)).z))));
    (&sample_4)->unit_direction = _S1227;
    (&sample_4)->random_state = random_state_19;
    (&sample_4)->lobe = 2U;
    float3  _S1228 = reflectBSDF((&sample_4)->unit_direction, n_i_17, alpha_9, frame_7, w_18);
    (&sample_4)->throughput = _S1228;
    float _S1229 = reflectPDF(pdf_h_4, w_18);
    (&sample_4)->pdf = _S1229;
    return sample_4;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_10, float3  n_11, BSDFMaterial material_20, float eta_i_8, float eta_o_8, uint random_init_0, float2  screen_space_0)
{
    uint random_state_20 = random_init_0;
    float3  _S1230 = negate_0(in_dir_10);
    float _S1231 = dot_0(n_11, _S1230);
    float _S1232 = sign_0(_S1231);
    float3  n_i_18 = n_11 * make_float3 (_S1232);
    float _S1233 = (F32_abs((_S1231)));
    float _S1234 = material_20.roughness;
    float _S1235 = _S1234 * _S1234;
    AnisotropicFrame _S1236 = anisotropicFrame(material_20, n_i_18);
    SheenProfile _S1237 = sheenProfile(_S1230, n_i_18, material_20);
    float3  _S1238 = sampleHalfVector(_S1230, n_i_18, _S1235, _S1236, &random_state_20);
    Weights _S1239 = lobeWeights(in_dir_10, _S1230, n_i_18, _S1238, _S1236, _S1237, material_20, eta_i_8, eta_o_8);
    Random _S1240 = pcg(random_state_20);
    random_state_20 = _S1240.state;
    bool _S1241 = (_S1240.value) < (_S1239.p_sheen_velvet);
    if(_S1241)
    {
        SampleBSDF _S1242 = sheenVelvetSample(_S1230, n_i_18, _S1233, material_20, _S1239, random_state_20);
        return _S1242;
    }
    float _S1243 = _S1240.value - _S1239.p_sheen_velvet;
    bool _S1244 = _S1243 < (_S1239.p_diffuse);
    if(_S1244)
    {
        SampleBSDF _S1245 = diffuseSample(_S1243, n_i_18, _S1233, material_20, _S1239, random_state_20);
        return _S1245;
    }
    bool _S1246 = _S1243 < (_S1239.p_diffuse + _S1239.p_toon);
    if(_S1246)
    {
        ToonProfile _S1247 = toonProfile(_S1230, n_i_18, material_20);
        SampleBSDF _S1248 = toonSample(n_i_18, _S1247, _S1239, random_state_20);
        return _S1248;
    }
    float _S1249 = vndfPDF(_S1230, _S1238, n_i_18, _S1233, _S1235, _S1236, _S1239.v_dot_h);
    bool _S1250 = (_S1243 - _S1239.p_toon) < (_S1239.p_diffuse + _S1239.p_refract);
    if(_S1250)
    {
        SampleBSDF _S1251 = refractSample(_S1238, n_i_18, _S1235, _S1236, material_20, _S1239, _S1249, eta_i_8, eta_o_8, random_state_20);
        return _S1251;
    }
    SampleBSDF _S1252 = reflectSample(in_dir_10, _S1238, n_i_18, _S1235, _S1236, _S1239, _S1249, random_state_20);
    return _S1252;
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
    bool _S1253;
    bool _S1254;
    float density_2;
    float threshold_0;
    float width_3;
    float sky_pdf_0;
    float wavelength_2;
    uint b_6;
    uint layer_0;
    float3  throughput_2;
    float3  chain_throughput_0;
    TreeSample light_3;
    int _S1255;
    Shift ended_0;
    float density_3;
    float spread_2;
    float width_4;
    float sky_pdf_1;
    float spread_3;
    float width_5;
    uint b_7;
    float3  _S1256 = make_float3 (0.0f);
    Shift _S1257 = Shift_x24init_0(_S1256, 0.0f);
    uint _S1258 = r_8->path;
    uint _S1259 = extractBits_0(r_8->path, 0U, 5U);
    uint _S1260 = extractBits_0(_S1258, 5U, 5U);
    uint _S1261 = extractBits_0(_S1258, 10U, 2U);
    uint _S1262 = extractBits_0(_S1258, 12U, 3U);
    bool passes_0;
    if(replay_1)
    {
        bool _S1263 = _S1262 >= 3U;
        uint _S1264 = _slang_select(_S1263, 1U,0U);
        uint _S1265 = _S1259 + _S1264;
        uint _S1266 = (fcptMaxBounces());
        passes_0 = _S1265 > _S1266;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1257;
    }
    uint _S1267 = _S1260 - 1U;
    bool _S1268 = _S1262 == 3U;
    uint _S1269 = _slang_select(_S1268, 1U,0U);
    uint _S1270 = _S1259 + _S1269;
    bool _S1271 = _S1261 == 0U;
    uint _S1272 = _slang_select(_S1271, _S1270,_S1267);
    FKHit _S1273 = (fcptReservoirHit((*r_8)));
    float3  _S1274 = dom_7->x0;
    float3  _S1275 = dom_7->x1 - dom_7->x0;
    float3  _S1276 = ((((_S1275)) * make_float3(rnorm3df(((_S1275)).x, ((_S1275)).y, ((_S1275)).z))));
    FKRay _S1277 = Ray_x24init_0(dom_7->x1, _S1276);
    FKRay ray_2 = _S1277;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1256;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_1 = throughput_3;
    float3  glowed_0 = _S1256;
    float3  extinction_in_0 = _S1256;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1278 = dom_7->spread;
    float _S1279 = dom_7->width;
    float _S1280 = length_0(_S1275);
    NEEVertex _S1281 = NEEVertex_x24init_0(true, 0.0f, _S1256, _S1256, _S1256);
    NEEVertex nee_vertex_0 = _S1281;
    Vertex _S1282 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S1282;
    Reservoir _S1283 = (Reservoir{});
    Reservoir chain_0 = _S1283;
    uint _S1284 = r_8->seed;
    (&chain_0)->seed = r_8->seed;
    (&ray_2)->origin = _S1274;
    (&hit_4)->distance = _S1280;
    FKMedium _S1285 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1286 = filling_2;
    bool _S1287 = (fcptVaryingUsed());
    uint _S1288 = _slang_select(_S1287, _S1286,4294967295U);
    filling_2 = _S1288;
    scatter_in_0 = _S1285.scatter;
    extinction_in_0 = _S1285.extinction;
    g_in_0 = _S1285.g;
    Reservoir _S1289 = chain_0;
    uint _S1290 = filling_2;
    for(;;)
    {
        bool _S1291 = (fcptVaryingUsed());
        if(_S1291)
        {
            passes_0 = _S1290 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1292 = (fcptMajorant((_S1290)));
            spread_1 = _S1292;
        }
        else
        {
            spread_1 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_1)
        {
            turned_1 = 4294967295U == _S1272;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1261 == 1U;
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
            ended_0 = _S1257;
            sky_pdf_0 = 0.0f;
            spread_1 = _S1278;
            width_3 = _S1279;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_6 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1293 = (&prev_0)->rough;
        if(_S1293)
        {
            turned_1 = !(spread_1 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S1294 = stream(_S1284, 384U);
        uint tracking_0 = _S1294;
        weight_1 = throughput_3;
        glowed_0 = _S1256;
        b_6 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        threshold_0 = _S1278;
        width_3 = _S1279;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1255 = int(1);
                break;
            }
            uint _S1295 = b_6 + 320U;
            bool _S1296 = b_6 == 4294967295U;
            uint _S1297 = _slang_select(_S1296, 384U,_S1295);
            uint _S1298 = stream(_S1284, _S1297);
            Random _S1299 = pcg(_S1298);
            float _S1300 = - (F32_log((1.0f - _S1299.value))) / spread_1;
            if(passes_0)
            {
                float3  _S1301 = (&ray_2)->origin;
                float3  _S1302 = (&ray_2)->unit_direction;
                float _S1303 = (&hit_4)->distance;
                uint _S1304 = _slang_select(_S1296, 0U,b_6);
                uint _S1305 = (&prev_0)->lobe;
                uint _S1306 = _slang_select(_S1296, 3U,_S1305);
                float _S1307 = (fcptTrackMedium((_S1290), (_S1301), (_S1302), (_S1303), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1304), (_S1306), (_S1296)));
                wavelength_2 = _S1307;
            }
            else
            {
                wavelength_2 = _S1300;
            }
            bool _S1308 = !(wavelength_2 < ((&hit_4)->distance));
            if(_S1308)
            {
                _S1255 = int(1);
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
                float3  _S1309 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S1310 = sel_7->glow + _S1309;
                sel_7->glow = _S1310;
            }
            else
            {
            }
            glowed_0 = _S1256;
            uint b_8 = b_6 + 1U;
            float3  _S1311 = (&ray_2)->origin + make_float3 (wavelength_2) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1311;
            float3  _S1312 = flightWeight_0(scatter_in_0, extinction_in_0, spread_1, wavelength_2, true);
            float3  _S1313 = weight_1;
            float3  _S1314 = _slang_select(passes_0, _S1313,_S1312);
            float3  throughput_4 = throughput_2 * _S1314;
            uint _S1315 = stream(_S1284, b_8 + 320U);
            tracking_0 = _S1315;
            weight_1 = throughput_3;
            float width_6 = width_3 + threshold_0 * wavelength_2;
            float _S1316 = threshold_0 + 3.14159274101257324f;
            bool _S1317 = !replay_1;
            if(_S1317)
            {
                is_inside_6 = true;
            }
            else
            {
                bool _S1318 = b_8 == _S1272;
                if(_S1318)
                {
                    is_inside_6 = !passes_0;
                }
                else
                {
                    is_inside_6 = false;
                }
            }
            TreeSample _S1319 = TreeSample_x24init_0(_S1256, _S1256, 0.0f, 0U);
            if(is_inside_6)
            {
                float3  _S1320 = (&ray_2)->origin;
                float3  _S1321 = (&ray_2)->unit_direction;
                float3  _S1322 = (&ray_2)->unit_direction;
                uint _S1323 = stream(_S1284, b_8 + 64U);
                float3  _S1324 = extinction_in_0;
                float3  _S1325 = extinction_in_0;
                uint2  _S1326 = make_uint2 (_S1290);
                float3  _S1327 = (&ray_2)->unit_direction;
                uint _S1328 = arrivalLobe_0(b_8, (&prev_0)->lobe);
                FKHit _S1329 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1330 = _S1329;
                ShadowContext _S1331 = ShadowContext_x24init_0(_S1324, _S1325, _S1326, _S1327, b_8, _S1328, false, wavelength_2, width_6, &_S1330, false);
                ShadowContext _S1332 = _S1331;
                TreeSample _S1333 = sampleLightTree_0(_S1320, _S1321, _S1322, 0.0f, true, _S1323, &_S1332);
                light_3 = _S1333;
            }
            else
            {
                light_3 = _S1319;
            }
            float _S1334 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S1335 = (fcptMaxBounces());
            bool _S1336 = b_8 < _S1335;
            if(_S1336)
            {
                viewed_0 = (light_3.density) > 0.0f;
            }
            else
            {
                viewed_0 = false;
            }
            float _S1337 = _slang_select(viewed_0, _S1334,0.0f);
            float3  _S1338 = throughput_4 * light_3.radiance;
            float _S1339 = powerHeuristic(light_3.density, _S1337);
            float3  _S1340 = _S1338 * make_float3 (_S1334 * _S1339);
            float3  _S1341 = _slang_select(is_inside_6, _S1340,_S1256);
            if(replay_1)
            {
                _S1253 = b_8 == _S1272;
            }
            else
            {
                _S1253 = false;
            }
            if(_S1253)
            {
                bool _S1342 = _S1261 == 2U;
                if(_S1342)
                {
                    float _S1343 = resamplingTarget(_S1341);
                    passes_0 = _S1343 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1344 = Shift_x24init_0(_S1341, 1.0f);
                    _S1255 = int(0);
                    ended_0 = _S1344;
                    spread_1 = _S1316;
                    wavelength_2 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_8;
                    break;
                }
                _S1255 = int(0);
                ended_0 = _S1257;
                spread_1 = _S1316;
                wavelength_2 = width_6;
                chain_throughput_0 = throughput_4;
                layer_0 = b_8;
                break;
            }
            if(_S1317)
            {
                Reservoir candidate_3 = _S1289;
                uint _S1345 = extractBits_0(_S1289.path, 10U, 2U);
                bool _S1346 = _S1345 == 1U;
                if(_S1346)
                {
                    float3  _S1347 = safeDivide(_S1341, _S1256);
                    (&candidate_3)->radiance = _S1347;
                }
                else
                {
                    uint _S1348 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                    uint _S1349 = insertBits_0(_S1348, 2U, 10U, 2U);
                    (&candidate_3)->path = _S1349;
                }
                Reservoir _S1350 = withEnd(candidate_3, 0U, b_8, _S1341);
                offer(sel_7, _S1350, _S1341 * make_float3 (scale_3) / make_float3 (density_2));
                float _S1351 = survivalProbability(abs_0(throughput_4), density_2);
                uint _S1352 = stream(_S1284, b_8 + 128U);
                Random _S1353 = pcg(_S1352);
                bool _S1354 = _S1351 < (_S1353.value);
                if(_S1354)
                {
                    _S1254 = true;
                }
                else
                {
                    uint _S1355 = (fcptMaxBounces());
                    _S1254 = b_8 >= _S1355;
                }
                if(_S1254)
                {
                    _S1255 = int(0);
                    ended_0 = _S1257;
                    spread_1 = _S1316;
                    wavelength_2 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_8;
                    break;
                }
                float _S1356 = density_2 * _S1351;
                density_2 = _S1356;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1357 = stream(_S1284, b_8);
            float3  _S1358 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1357, &phase_pdf_0);
            (&ray_2)->unit_direction = _S1358;
            NEEVertex _S1359 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S1256, (&ray_2)->origin);
            nee_vertex_0 = _S1359;
            Vertex _S1360 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, false);
            prev_0 = _S1360;
            float _S1361 = (&prev_0)->pdf;
            FKRay _S1362 = ray_2;
            FKHit _S1363 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1364 = (fcptTraverseInstanceBVH((_S1362), (true), (4.294967296e+09f), (false), (_S1363), (false)));
            hit_4 = _S1364;
            b_6 = b_8;
            throughput_2 = throughput_4;
            threshold_0 = _S1316;
            width_3 = width_6;
            sky_pdf_0 = _S1361;
        }
        if(_S1255 != int(1))
        {
            width_3 = wavelength_2;
            throughput_2 = chain_throughput_0;
            b_6 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1257;
        spread_1 = threshold_0;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1365 = b_6 == 4294967295U;
    bool _S1366 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1366)
    {
        bool _S1367 = !(&nee_vertex_0)->none;
        float _S1368 = _slang_select(_S1367, sky_pdf_0,0.0f);
        float _S1369 = escapeWeight_0(_S1368, (&ray_2)->unit_direction);
        float3  _S1370 = environment_0((&ray_2)->unit_direction, b_6, (&prev_0)->lobe);
        float3  _S1371 = throughput_2 * _S1370;
        if(replay_1)
        {
            bool _S1372 = b_6 == _S1272;
            if(_S1372)
            {
                passes_0 = _S1261 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S1371 * make_float3 (_S1369) / make_float3 (r_8->jac), density_2 / r_8->jac);
            }
            if(_S1271)
            {
                passes_0 = _S1268;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_6 == _S1259;
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
                return Shift_x24init_0(_S1371 * make_float3 (_S1369), 1.0f);
            }
            return _S1257;
        }
        Reservoir candidate_4 = chain_0;
        uint _S1373 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1374 = _S1373 == 1U;
        if(_S1374)
        {
            uint _S1375 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S1376 = _S1375 == b_6;
            float _S1377 = _slang_select(_S1376, 1.0f,_S1369);
            float3  _S1378 = safeDivide(_S1371 * make_float3 (_S1377), _S1256);
            (&candidate_4)->radiance = _S1378;
        }
        else
        {
            bool _S1379 = (&prev_0)->rough;
            if(_S1379)
            {
                uint _S1380 = insertBits_0(0U, b_6 + 1U, 5U, 5U);
                uint _S1381 = insertBits_0(_S1380, 3U, 10U, 2U);
                uint _S1382 = insertBits_0(_S1381, (&prev_0)->lobe, 15U, 3U);
                bool _S1383 = (&prev_0)->inside;
                uint _S1384 = _slang_select(_S1383, 1U,0U);
                uint _S1385 = insertBits_0(_S1382, _S1384, 22U, 1U);
                (&candidate_4)->path = _S1385;
                (&candidate_4)->jac = (&prev_0)->pdf;
                (&candidate_4)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S1386 = _S1371 * make_float3 (_S1369);
        Reservoir _S1387 = withEnd(candidate_4, 3U, b_6, _S1386);
        offer(sel_7, _S1387, _S1386 * make_float3 (scale_3) / make_float3 (density_2));
        return _S1257;
    }
    float3  _S1388 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S1388;
    bool _S1389 = (fcptVaryingUsed());
    if(_S1389)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1390 = !replay_1;
        if(_S1390)
        {
            float3  _S1391 = throughput_2 * glowed_0 / make_float3 (density_2);
            float3  _S1392 = sel_7->glow + _S1391;
            sel_7->glow = _S1392;
        }
        float3  _S1393 = throughput_2 * weight_1;
        throughput_2 = _S1393;
    }
    else
    {
        float3  _S1394 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
        float3  _S1395 = throughput_2 * _S1394;
        throughput_2 = _S1395;
    }
    float _S1396 = width_3 + spread_1 * (&hit_4)->distance;
    uint _S1397 = b_6 + 1U;
    b_6 = _S1397;
    layer_0 = 0U;
    width_3 = _S1396;
    passes_0 = false;
    threshold_0 = 0.0f;
    turned_1 = false;
    is_inside_6 = false;
    wavelength_2 = 0.0f;
    chain_throughput_0 = _S1256;
    float3  reconnection_0 = _S1256;
    viewed_0 = _S1365;
    for(;;)
    {
        bool _S1398 = ((&hit_4)->is_point_light) == 1U;
        if(replay_1)
        {
            _S1253 = _S1261 == 1U;
        }
        else
        {
            _S1253 = false;
        }
        if(_S1253)
        {
            _S1254 = b_6 == _S1260;
        }
        else
        {
            _S1254 = false;
        }
        bool _S1399;
        if(_S1254)
        {
            bool _S1400 = ((&hit_4)->instance_index) != (_S1273.instance_index);
            if(_S1400)
            {
                _S1399 = true;
            }
            else
            {
                _S1399 = ((&hit_4)->triangle_index) != (_S1273.triangle_index);
            }
        }
        else
        {
            _S1399 = false;
        }
        if(_S1399)
        {
            return _S1257;
        }
        FKMedium _S1401 = Medium_x24init_0(_S1256, _S1256, 0.0f);
        BSDFMaterial _S1402 = Material_x24init_0(_S1256, _S1256, 0.0f, 0.0f, 0.0f, 0.0f, _S1256, throughput_3, 1.0f, _S1256, _S1256, 0.5f, 0.0f, 0.0f, _S1256, 0.0f, _S1256, 0.0f);
        FKMedium _S1403 = _S1401;
        FKSurface _S1404 = Surface_x24init_0(_S1256, _S1256, 0.0f, &_S1402, false, 0U, 1.0f, false, &_S1403, 4294967295U, _S1256);
        bool _S1405 = !_S1398;
        bool scatter_2;
        bool is_inside_7;
        float geometry_density_0;
        float3  throughput_5;
        float3  front_n_0;
        FKSurface surface_13;
        if(_S1405)
        {
            uint _S1406 = stream(_S1284, b_6);
            uint _S1407 = arrivalLobe_0(b_6, (&prev_0)->lobe);
            FKSurface _S1408 = (fcptSurfaceAtPath((hit_4), ((&ray_2)->origin), (_S1406), (width_3), (layer_0), (b_6), (_S1407), ((&ray_2)->unit_direction)));
            bool _S1409 = !passes_0;
            FKSurface _S1410 = _S1408;
            FKSurface _S1411 = emitting_0(&_S1410, _S1409);
            uint _S1412 = stream(_S1284, b_6 + 256U);
            Random _S1413 = pcg(_S1412);
            FKSurface _S1414 = _S1411;
            FKSurface _S1415 = uncovered_0(&_S1414, _S1413.value);
            float _S1416 = facingSign(_S1415.material.transmission, _S1415.geometry_n, (&ray_2)->unit_direction);
            bool _S1417 = _S1416 < 0.0f;
            bool _S1418 = (_S1415.material.transmission) > 0.0f;
            if(_S1418)
            {
                bool _S1419 = arrivesBehind_0((&ray_2)->unit_direction, _S1415.geometry_n);
                scatter_2 = _S1419;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1420 = _S1415;
            FKSurface _S1421 = facingRay_0(&_S1420, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S1422 = arrivesBehind_0((&ray_2)->unit_direction, _S1421.geometry_n);
                is_inside_7 = _S1422;
            }
            else
            {
                is_inside_7 = scatter_2;
            }
            if(is_inside_7)
            {
                float3  _S1423 = beerLambert((&hit_4)->distance, _S1421.material.absorption);
                float3  _S1424 = throughput_2 * _S1423;
                throughput_5 = _S1424;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S1425 = !_S1421.skip;
            float geometry_density_1 = (F32_abs((dot_0(_S1421.geometry_n, (&ray_2)->unit_direction)))) / ((&hit_4)->distance * (&hit_4)->distance);
            bool _S1426 = b_6 == _S1397;
            if(_S1426)
            {
                float _S1427 = 0.00251327408477664f / geometry_density_1;
                geometry_density_0 = _S1427;
            }
            else
            {
                geometry_density_0 = threshold_0;
            }
            float _S1428 = geometry_density_0;
            scatter_2 = _S1425;
            geometry_density_0 = geometry_density_1;
            threshold_0 = _S1428;
            surface_13 = _S1421;
            front_n_0 = _S1415.smooth_n;
            turned_1 = _S1417;
        }
        else
        {
            scatter_2 = false;
            geometry_density_0 = 0.0f;
            surface_13 = _S1404;
            throughput_5 = throughput_2;
            front_n_0 = _S1256;
            is_inside_7 = is_inside_6;
        }
        bool _S1429;
        if(scatter_2)
        {
            _S1429 = (&prev_0)->rough;
        }
        else
        {
            _S1429 = false;
        }
        bool _S1430;
        if(_S1429)
        {
            _S1430 = ((&prev_0)->pdf * geometry_density_0 * threshold_0) <= 1.0f;
        }
        else
        {
            _S1430 = false;
        }
        FKSurface _S1431 = surface_13;
        FKSurface _S1432 = surface_13;
        float _S1433 = dot_0(surface_13.smooth_n, - (&ray_2)->unit_direction);
        bool _S1434 = (fcptDispersionUsed());
        bool _S1435;
        if(_S1434)
        {
            _S1435 = wavelength_2 == 0.0f;
        }
        else
        {
            _S1435 = false;
        }
        bool _S1436;
        if(_S1435)
        {
            _S1436 = scatter_2;
        }
        else
        {
            _S1436 = false;
        }
        bool _S1437;
        if(_S1436)
        {
            bool _S1438 = dispersive(_S1431.material);
            _S1437 = _S1438;
        }
        else
        {
            _S1437 = false;
        }
        float3  throughput_6;
        if(_S1437)
        {
            uint _S1439 = stream(_S1284, 512U);
            Random _S1440 = pcg(_S1439);
            float2  _S1441 = sampleWavelength(_S1440.value);
            float _S1442 = _S1441.x;
            float3  _S1443 = wavelengthWeights(_S1442);
            float3  _S1444 = throughput_5 * (_S1443 / make_float3 (_S1441.y));
            wavelength_2 = _S1442;
            throughput_6 = _S1444;
        }
        else
        {
            throughput_6 = throughput_5;
        }
        BSDFMaterial refractive_0 = _S1431.material;
        float _S1445 = dispersedIor(_S1431.material.ior, _S1431.material.dispersion, wavelength_2);
        bool _S1446 = wavelength_2 > 0.0f;
        float _S1447 = _slang_select(_S1446, _S1445,_S1431.material.ior);
        (&refractive_0)->ior = _S1447;
        float2  _S1448 = vertexEta(refractive_0, _S1433);
        bool _S1449;
        if(scatter_2)
        {
            uint _S1450 = (fcptMaxBounces());
            bool _S1451 = b_6 >= _S1450;
            if(_S1451)
            {
                _S1449 = true;
            }
            else
            {
                bool _S1452 = neeDecision(_S1431.material, _S1433, _S1448.x, _S1448.y);
                _S1449 = _S1452;
            }
        }
        else
        {
            _S1449 = false;
        }
        bool _S1453;
        if(passes_0)
        {
            _S1453 = true;
        }
        else
        {
            _S1453 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1453)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1449;
        }
        bool _S1454 = (fcptHairUsed());
        bool _S1455;
        if(_S1454)
        {
            float3  _S1456 = surface_13.hair;
            _S1455 = (dot_0(_S1456, _S1456)) > 0.0f;
        }
        else
        {
            _S1455 = false;
        }
        bool _S1457;
        if(_S1455)
        {
            _S1457 = true;
        }
        else
        {
            BSDFMaterial _S1458 = _S1431.material;
            bool _S1459 = isTranslucent_0(&_S1458);
            _S1457 = _S1459;
        }
        bool _S1460;
        if(_S1457)
        {
            _S1460 = true;
        }
        else
        {
            bool _S1461 = (_S1431.material.transmission) > 0.0f;
            if(_S1461)
            {
                uint _S1462 = (fcptLayers((hit_4)));
                _S1460 = _S1462 == 1U;
            }
            else
            {
                _S1460 = false;
            }
        }
        float3  _S1463 = emitted_0(_S1431.material.emissive, (&ray_2)->unit_direction, front_n_0);
        float3  emission_0;
        if(_S1398)
        {
            float3  _S1464 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1464;
        }
        else
        {
            emission_0 = _S1463;
        }
        bool _S1465 = !replay_1;
        bool _S1466;
        if(_S1465)
        {
            _S1466 = true;
        }
        else
        {
            _S1466 = b_6 >= _S1272;
        }
        bool _S1467;
        if(_S1466)
        {
            float _S1468 = rgb_to_greyscale(emission_0);
            _S1467 = _S1468 > 0.0f;
        }
        else
        {
            _S1467 = false;
        }
        float3  emission_1;
        if(_S1467)
        {
            NEEVertex _S1469 = nee_vertex_0;
            FKHit _S1470 = hit_4;
            float _S1471 = emissionWeight_0(&_S1469, &_S1470, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1471);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1472;
        if(replay_1)
        {
            _S1472 = _S1261 == 1U;
        }
        else
        {
            _S1472 = false;
        }
        bool _S1473;
        if(_S1472)
        {
            _S1473 = b_6 > _S1260;
        }
        else
        {
            _S1473 = false;
        }
        bool _S1474;
        if(_S1473)
        {
            _S1474 = b_6 == _S1259;
        }
        else
        {
            _S1474 = false;
        }
        bool _S1475;
        if(_S1474)
        {
            bool _S1476 = _S1262 == 1U;
            if(_S1476)
            {
                _S1475 = true;
            }
            else
            {
                _S1475 = _S1262 == 2U;
            }
        }
        else
        {
            _S1475 = false;
        }
        if(_S1475)
        {
            bool _S1477 = _S1398 != (_S1262 == 2U);
            if(_S1477)
            {
                return _S1257;
            }
            return Shift_x24init_0(throughput_6 * emission_1 / make_float3 (r_8->jac), density_2 / r_8->jac);
        }
        uint _S1478 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1479 = _S1478 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1480 = insertBits_0(0U, b_6, 5U, 5U);
        uint _S1481 = insertBits_0(_S1480, 1U, 10U, 2U);
        uint _S1482 = insertBits_0(_S1481, (&prev_0)->lobe, 15U, 3U);
        bool _S1483 = (&prev_0)->inside;
        uint _S1484 = _slang_select(_S1483, 1U,0U);
        uint _S1485 = insertBits_0(_S1482, _S1484, 22U, 1U);
        (&here_0)->path = _S1485;
        uint _S1486 = (&here_0)->path;
        uint _S1487 = _slang_select(_S1446, 1U,0U);
        uint _S1488 = insertBits_0(_S1486, _S1487, 23U, 1U);
        (&here_0)->path = _S1488;
        float _S1489 = (&prev_0)->pdf * geometry_density_0;
        (&here_0)->jac = _S1489;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1490;
        if(replay_1)
        {
            _S1490 = _S1261 == 1U;
        }
        else
        {
            _S1490 = false;
        }
        bool _S1491;
        if(_S1490)
        {
            _S1491 = b_6 == _S1260;
        }
        else
        {
            _S1491 = false;
        }
        bool _S1492 = b_6 == _S1272;
        bool _S1493;
        if(_S1492)
        {
            bool _S1494 = !scatter_2;
            if(_S1494)
            {
                _S1493 = true;
            }
            else
            {
                bool _S1495 = _S1261 != 1U;
                if(_S1495)
                {
                    _S1493 = _S1261 != 3U;
                }
                else
                {
                    _S1493 = false;
                }
            }
        }
        else
        {
            _S1493 = false;
        }
        bool _S1496;
        if(_S1493)
        {
            _S1496 = _S1261 == 2U;
        }
        else
        {
            _S1496 = false;
        }
        bool _S1497;
        if(_S1496)
        {
            _S1497 = !_S1430;
        }
        else
        {
            _S1497 = false;
        }
        bool _S1498;
        if(_S1497)
        {
            _S1498 = _S1262 != 4U;
        }
        else
        {
            _S1498 = false;
        }
        bool _S1499 = _S1260 == _S1259;
        bool _S1500;
        if(_S1499)
        {
            _S1500 = _S1262 == 0U;
        }
        else
        {
            _S1500 = false;
        }
        bool _S1501;
        if(_S1500)
        {
            _S1501 = ((&hit_4)->instance_index) == (_S1273.instance_index);
        }
        else
        {
            _S1501 = false;
        }
        bool _S1502;
        if(_S1501)
        {
            _S1502 = ((&hit_4)->triangle_index) == (_S1273.triangle_index);
        }
        else
        {
            _S1502 = false;
        }
        bool _S1503;
        if(_S1502)
        {
            _S1503 = _S1430;
        }
        else
        {
            _S1503 = false;
        }
        bool _S1504 = _slang_select(_S1491, _S1503,_S1498);
        bool _S1505;
        if(nee_0)
        {
            _S1505 = _slang_select(replay_1, _S1504,scatter_2);
        }
        else
        {
            _S1505 = false;
        }
        TreeSample _S1506 = TreeSample_x24init_0(_S1256, _S1256, 0.0f, 0U);
        uint2  _S1507 = make_uint2 (0U);
        float2  _S1508 = make_float2 (0.0f);
        FKHit _S1509 = Hit_x24init_0(_S1508, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1510 = _S1509;
        ShadowContext _S1511 = ShadowContext_x24init_0(_S1256, _S1256, _S1507, _S1256, 0U, 0U, false, 0.0f, 0.0f, &_S1510, false);
        bool _S1512;
        if(nee_0)
        {
            _S1512 = _S1466;
        }
        else
        {
            _S1512 = false;
        }
        ShadowContext context_5;
        if(_S1512)
        {
            uint _S1513 = arrivalLobe_0(b_6, (&prev_0)->lobe);
            FKMedium _S1514 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1515 = surface_13;
            FKHit _S1516 = hit_4;
            FKMedium _S1517 = _S1514;
            ShadowContext _S1518 = shadowContext_0(&_S1515, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_6, _S1513, (&hit_4)->distance, width_3, &_S1516, _S1455, &_S1517);
            context_5 = _S1518;
        }
        else
        {
            context_5 = _S1511;
        }
        float3  throughput_7;
        float3  lit_0;
        if(_S1505)
        {
            float3  _S1519 = (&ray_2)->origin;
            if(_S1455)
            {
                throughput_7 = _S1256;
            }
            else
            {
                throughput_7 = _S1432.smooth_n;
            }
            FKSurface _S1520 = surface_13;
            uint _S1521 = stream(_S1284, b_6 + 64U);
            ShadowContext _S1522 = context_5;
            TreeSample _S1523 = sampleLightTree_0(_S1519, throughput_7, surface_13.geometry_n, surface_13.geometry_offset, _S1460, _S1521, &_S1522);
            bool _S1524 = any_1((_S1523.radiance) != _S1256);
            if(_S1524)
            {
                if(_S1455)
                {
                    uint _S1525 = (fcptMaxBounces());
                    bool _S1526 = b_6 < _S1525;
                    FKSurface _S1527 = surface_13;
                    TreeSample _S1528 = _S1523;
                    float3  _S1529 = hairLight_0(&_S1527, (&ray_2)->unit_direction, &_S1528, _S1526);
                    lit_0 = _S1529;
                }
                else
                {
                    float _S1530 = _S1448.x;
                    float _S1531 = _S1448.y;
                    uint _S1532 = (fcptMaxBounces());
                    bool _S1533 = b_6 < _S1532;
                    TreeSample _S1534 = _S1523;
                    BSDFMaterial _S1535 = _S1431.material;
                    float3  _S1536 = lightBSDF_0((&ray_2)->unit_direction, &_S1534, _S1432.smooth_n, _S1520.geometry_n, &_S1535, _S1530, _S1531, _S1533, surface_13.random_state);
                    lit_0 = _S1536;
                }
            }
            else
            {
                lit_0 = _S1256;
            }
            light_3 = _S1523;
        }
        else
        {
            light_3 = _S1506;
            lit_0 = _S1256;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1537;
        bool _S1538;
        float density_4;
        if(_S1491)
        {
            bool _S1539 = !_S1430;
            if(_S1539)
            {
                return _S1257;
            }
            uint _S1540 = extractBits_0(_S1258, 23U, 1U);
            bool _S1541 = _S1446 != (_S1540 == 1U);
            if(_S1541)
            {
                return _S1257;
            }
            float3  throughput_8 = throughput_6 * make_float3 (geometry_density_0);
            float density_5 = density_2 * geometry_density_0;
            if(_S1499)
            {
                viewed_1 = _S1262 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                return Shift_x24init_0(throughput_8 * emission_1 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1499)
            {
                refracted_4 = _S1262 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S1542 = !nee_0;
                if(_S1542)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1543 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1543 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1257;
                }
                return Shift_x24init_0(throughput_8 * lit_0 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1499)
            {
                wrong_side_0 = _S1262 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1544 = !nee_0;
                if(_S1544)
                {
                    return _S1257;
                }
                bool _S1545 = (fcptWorldReadsPath());
                if(_S1545)
                {
                    float _S1546 = environmentPdf_0(r_8->dir);
                    uint _S1547 = b_6 + 1U;
                    FKSurface _S1548 = surface_13;
                    float3  _S1549 = skyColor_0((&ray_2)->unit_direction, r_8->dir, &_S1548, _S1448, is_inside_7, _S1546, surface_13.random_state, _S1547);
                    return Shift_x24init_0(throughput_8 * (_S1549 * r_8->radiance) / make_float3 (r_8->jac), density_5 / r_8->jac);
                }
                float _S1550 = environmentPdf_0(r_8->dir);
                float3  _S1551 = skyBSDF((&ray_2)->unit_direction, r_8->dir, surface_13, _S1448, is_inside_7, _S1550, surface_13.random_state);
                return Shift_x24init_0(throughput_8 * _S1551 * r_8->radiance / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            uint _S1552 = extractBits_0(_S1258, 21U, 1U);
            bool _S1553 = nee_0 != (_S1552 == 1U);
            if(_S1553)
            {
                return _S1257;
            }
            throughput_7 = throughput_8;
            density_4 = density_5;
        }
        else
        {
            if(replay_1)
            {
                viewed_1 = _S1492;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1554 = !scatter_2;
                if(_S1554)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1555 = _S1261 != 1U;
                    if(_S1555)
                    {
                        refracted_4 = _S1261 != 3U;
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
                bool _S1556 = _S1261 == 2U;
                if(_S1556)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1430;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1262 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1455)
                    {
                        return _S1257;
                    }
                    uint _S1557 = stream(_S1284, b_6 + 448U);
                    FKRay _S1558 = ray_2;
                    FKSurface _S1559 = surface_13;
                    ShadowContext _S1560 = context_5;
                    SkySample _S1561 = sampleSky_0(&_S1558, &_S1559, _S1448, is_inside_7, _S1557, surface_13.random_state, &_S1560);
                    return Shift_x24init_0(throughput_6 * _S1561.color, 1.0f);
                }
                if(_S1556)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1430;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1562 = rgb_to_greyscale(light_3.radiance);
                    bool _S1563 = !(_S1562 > 0.0f);
                    if(_S1563)
                    {
                        return _S1257;
                    }
                    return Shift_x24init_0(throughput_6 * lit_0, 1.0f);
                }
                if(_S1271)
                {
                    passes_0 = _S1262 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1398;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_6 * emission_1, 1.0f);
                }
                if(_S1271)
                {
                    passes_0 = _S1262 == 1U;
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
                    passes_0 = !_S1430;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_6 * emission_1, 1.0f);
                }
                return _S1257;
            }
            else
            {
                if(_S1465)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1564 = b_6 > 0U;
                    if(_S1564)
                    {
                        Reservoir candidate_5 = chain_0;
                        if(_S1479)
                        {
                            float3  _S1565 = safeDivide(throughput_6 * emission_1, chain_throughput_0);
                            (&candidate_5)->radiance = _S1565;
                        }
                        else
                        {
                            if(_S1430)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1566 = throughput_6 * emission_1;
                        Reservoir _S1567 = withEnd(candidate_5, 1U, b_6, _S1566);
                        offer(sel_7, _S1567, _S1566 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1568 = throughput_6 * emission_1;
                        float3  _S1569 = sel_7->glow + _S1568;
                        sel_7->glow = _S1569;
                    }
                    if(nee_0)
                    {
                        float3  _S1570 = throughput_6 * lit_0;
                        Reservoir candidate_6 = chain_0;
                        if(_S1479)
                        {
                            float3  _S1571 = safeDivide(_S1570, chain_throughput_0);
                            (&candidate_6)->radiance = _S1571;
                        }
                        else
                        {
                            if(_S1430)
                            {
                                candidate_6 = here_0;
                                uint _S1572 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1572;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1573 = insertBits_0(0U, b_6 + 1U, 5U, 5U);
                                uint _S1574 = insertBits_0(_S1573, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1574;
                            }
                        }
                        Reservoir _S1575 = withEnd(candidate_6, 0U, b_6, _S1570);
                        offer(sel_7, _S1575, _S1570 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1455)
                        {
                            _S1537 = false;
                        }
                        else
                        {
                            bool _S1576 = environmentMapped_0();
                            _S1537 = _S1576;
                        }
                    }
                    else
                    {
                        _S1537 = false;
                    }
                    if(_S1537)
                    {
                        uint _S1577 = (fcptMaxBounces());
                        _S1538 = b_6 < _S1577;
                    }
                    else
                    {
                        _S1538 = false;
                    }
                    if(_S1538)
                    {
                        uint _S1578 = stream(_S1284, b_6 + 448U);
                        FKRay _S1579 = ray_2;
                        FKSurface _S1580 = surface_13;
                        ShadowContext _S1581 = context_5;
                        SkySample _S1582 = sampleSky_0(&_S1579, &_S1580, _S1448, is_inside_7, _S1578, surface_13.random_state, &_S1581);
                        float3  _S1583 = throughput_6 * _S1582.color;
                        Reservoir candidate_7 = chain_0;
                        if(_S1479)
                        {
                            float3  _S1584 = safeDivide(_S1583, chain_throughput_0);
                            (&candidate_7)->radiance = _S1584;
                        }
                        else
                        {
                            if(_S1430)
                            {
                                candidate_7 = here_0;
                                uint _S1585 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1585;
                                (&candidate_7)->dir = _S1582.dir;
                                (&candidate_7)->radiance = _S1582.radiance;
                            }
                            else
                            {
                                uint _S1586 = insertBits_0(0U, b_6 + 1U, 5U, 5U);
                                uint _S1587 = insertBits_0(_S1586, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1587;
                            }
                        }
                        Reservoir _S1588 = withEnd(candidate_7, 4U, b_6, _S1583);
                        offer(sel_7, _S1588, _S1583 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                }
            }
            throughput_7 = throughput_6;
            density_4 = density_2;
        }
        bool _S1589;
        bool _S1590;
        bool _S1591;
        bool straight_0;
        bool _S1592;
        bool _S1593;
        bool _S1594;
        bool _S1595;
        bool _S1596;
        bool _S1597;
        bool _S1598;
        bool _S1599;
        bool _S1600;
        bool _S1601;
        bool _S1602;
        bool _S1603;
        bool _S1604;
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
                viewed_1 = _S1492;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1605 = extractBits_0(_S1258, 15U, 3U);
            uint _S1606 = extractBits_0(_S1258, 18U, 3U);
            uint _S1607 = _slang_select(_S1491, _S1606,_S1605);
            float3  _S1608 = r_8->dir;
            bool refracted_5 = _S1607 == 1U;
            SampleBSDF _S1609 = SampleBSDF_x24init_0(_S1256, _S1256, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1609;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1610 = extractBits_0(_S1258, 22U, 1U);
                bool _S1611 = is_inside_7 != (_S1610 == 1U);
                if(_S1611)
                {
                    return _S1257;
                }
                bool _S1612 = _S1261 == 1U;
                if(_S1612)
                {
                    float3  _S1613 = (fcptHitPosition((_S1273)));
                    throughput_9 = _S1613;
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
                    BSDFMaterial _S1614 = _S1431.material;
                    bool _S1615 = isTranslucent_0(&_S1614);
                    if(_S1615)
                    {
                        refracted_4 = _S1607 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1616 = throughput_9 - (&ray_2)->origin;
                        float3  _S1617 = _slang_select(_S1612, _S1616,_S1608);
                        wrong_side_0 = (dot_0(_S1432.smooth_n, _S1617) * _S1433) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1612)
                {
                    float3  _S1618 = (&ray_2)->origin;
                    FKSurface _S1619 = surface_13;
                    float3  _S1620 = - _S1432.smooth_n;
                    bool _S1621 = is_inside_7 != refracted_4;
                    float3  _S1622 = _slang_select(_S1621, _S1620,_S1432.smooth_n);
                    float3  _S1623 = throughput_9 - (_S1618 + make_float3 (_S1619.geometry_offset) * _S1622);
                    float3  _S1624 = ((((_S1623)) * make_float3(rnorm3df(((_S1623)).x, ((_S1623)).y, ((_S1623)).z))));
                    reconnection_1 = _S1624;
                }
                else
                {
                    reconnection_1 = _S1608;
                }
                if(_S1455)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1625 = wrongSide_0(is_inside_7, refracted_4, reconnection_1, surface_13.geometry_n);
                    wrong_side_0 = _S1625;
                }
                if(wrong_side_0)
                {
                    return _S1257;
                }
                float3  _S1626 = throughput_9;
                throughput_9 = reconnection_1;
                b_9 = _S1607;
                wrong_side_0 = false;
                reconnection_1 = _S1626;
            }
            else
            {
                bool _S1627 = !_S1491;
                if(_S1627)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1628;
                    if(_S1455)
                    {
                        SampleBSDF _S1629 = (fcptSampleHair((surface_13.hair), (_S1431.material.albedo), (_S1431.material.specular_tint), ((&ray_2)->unit_direction), (surface_13.random_state)));
                        _S1628 = _S1629;
                    }
                    else
                    {
                        SampleBSDF _S1630 = sampleBSDF((&ray_2)->unit_direction, _S1432.smooth_n, _S1431.material, _S1448.x, _S1448.y, surface_13.random_state, _S1508);
                        _S1628 = _S1630;
                    }
                    bsdf_sampled_0 = _S1628;
                    if(_S1455)
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
                            return _S1257;
                        }
                        break;
                    }
                    if(_S1455)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1631 = wrongSide_0(is_inside_7, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_13.geometry_n);
                        wrong_side_0 = _S1631;
                    }
                    if(wrong_side_0)
                    {
                        _S1537 = (_S1431.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1537 = false;
                    }
                    if(_S1537)
                    {
                        SampleBSDF _S1632 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_13.geometry_n, _S1431.material, _S1448.x, _S1448.y, (&bsdf_sampled_0)->random_state, _S1508);
                        (&bsdf_sampled_0)->unit_direction = _S1632.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1632.refracted;
                        (&bsdf_sampled_0)->throughput = _S1632.throughput;
                        (&bsdf_sampled_0)->lobe = _S1632.lobe;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1633 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_13.geometry_n)) * surface_13.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1633;
                        }
                    }
                    uint _S1634 = (&bsdf_sampled_0)->lobe;
                    float3  _S1635 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1636 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1637 = (&bsdf_sampled_0)->pdf;
                    float _S1638 = _slang_select(wrong_side_0, 0.0f,_S1637);
                    (&lobe_5)->pdf = _S1638;
                    throughput_9 = _S1635;
                    b_9 = _S1634;
                    refracted_4 = _S1636;
                }
                else
                {
                    throughput_9 = _S1608;
                    b_9 = _S1607;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1537 = true;
            }
            else
            {
                _S1537 = _S1491;
            }
            float3  chain_throughput_1;
            if(_S1537)
            {
                if(_S1455)
                {
                    SampleBSDF _S1639 = (fcptConnectHair((surface_13.hair), (_S1431.material.albedo), (_S1431.material.specular_tint), ((&ray_2)->unit_direction), (throughput_9)));
                    lobe_5 = _S1639;
                }
                else
                {
                    float3  _S1640 = (&ray_2)->unit_direction;
                    float3  _S1641 = negate_0(_S1640);
                    float _S1642 = sign_0(_S1433);
                    float3  _S1643 = _S1432.smooth_n * make_float3 (_S1642);
                    float _S1644 = dot_0(_S1643, throughput_9);
                    float _S1645 = _S1431.material.roughness;
                    float _S1646 = _S1645 * _S1645;
                    AnisotropicFrame _S1647 = anisotropicFrame(_S1431.material, _S1643);
                    SheenProfile _S1648 = sheenProfile(_S1641, _S1643, _S1431.material);
                    float3  _S1649 = reflectedHalf(_S1640, throughput_9);
                    bool _S1650 = b_9 == 1U;
                    if(_S1650)
                    {
                        float3  _S1651 = refractedHalf(_S1640, throughput_9, _S1432.smooth_n, _S1448.x, _S1448.y);
                        throughput_10 = _S1651;
                    }
                    else
                    {
                        throughput_10 = _S1649;
                    }
                    bool _S1652 = b_9 == 0U;
                    if(_S1652)
                    {
                        _S1538 = true;
                    }
                    else
                    {
                        _S1538 = b_9 == 6U;
                    }
                    if(_S1538)
                    {
                        float3  _S1653 = sampledHalf(_S1641, _S1643, _S1646, _S1647, surface_13.random_state);
                        throughput_11 = _S1653;
                    }
                    else
                    {
                        throughput_11 = throughput_10;
                    }
                    float _S1654 = _S1448.x;
                    float _S1655 = _S1448.y;
                    Weights _S1656 = lobeWeights(_S1640, _S1641, _S1643, throughput_11, _S1647, _S1648, _S1431.material, _S1654, _S1655);
                    float _S1657 = (F32_abs((_S1433)));
                    float _S1658 = vndfPDF(_S1641, throughput_11, _S1643, _S1657, _S1646, _S1647, _S1656.v_dot_h);
                    switch(b_9)
                    {
                    case 0U:
                        {
                            float _S1659 = diffusePDF(_S1644, _S1657, _S1431.material, _S1656);
                            float3  _S1660 = diffuseBSDF(throughput_9, _S1643, _S1431.material, _S1656);
                            density_6 = _S1659;
                            chain_throughput_1 = _S1660;
                            break;
                        }
                    case 1U:
                        {
                            float _S1661 = refractPDF(dot_0(throughput_9, throughput_11), _S1658, _S1656, _S1654, _S1655);
                            float3  _S1662 = refractBSDF(throughput_9, _S1643, _S1646, _S1647, _S1431.material, _S1656);
                            density_6 = _S1661;
                            chain_throughput_1 = _S1662;
                            break;
                        }
                    case 4U:
                        {
                            float _S1663 = sheenVelvetPDF(_S1644, _S1657, _S1656);
                            float3  _S1664 = sheenVelvetBSDF(throughput_9, _S1641, _S1643, _S1431.material, _S1656);
                            density_6 = _S1663;
                            chain_throughput_1 = _S1664;
                            break;
                        }
                    case 6U:
                        {
                            ToonProfile _S1665 = toonProfile(_S1641, _S1643, _S1431.material);
                            float _S1666 = toonPDF(throughput_9, _S1643, _S1665, _S1656);
                            float3  _S1667 = toonBSDF(throughput_9, _S1643, _S1665, _S1656);
                            density_6 = _S1666;
                            chain_throughput_1 = _S1667;
                            break;
                        }
                    default:
                        {
                            float _S1668 = reflectPDF(_S1658, _S1656);
                            float3  _S1669 = reflectBSDF(throughput_9, _S1643, _S1646, _S1647, _S1656);
                            density_6 = _S1668;
                            chain_throughput_1 = _S1669;
                            break;
                        }
                    }
                    bool _S1670 = density_6 > 0.0f;
                    if(_S1670)
                    {
                        SampleBSDF _S1671 = SampleBSDF_x24init_0(throughput_9, chain_throughput_1, surface_13.random_state, _S1650, b_9, density_6);
                        lobe_5 = _S1671;
                    }
                }
            }
            bool _S1672 = b_9 == 0U;
            if(_S1672)
            {
                _S1538 = true;
            }
            else
            {
                _S1538 = b_9 == 4U;
            }
            if(_S1538)
            {
                _S1589 = true;
            }
            else
            {
                _S1589 = b_9 == 6U;
            }
            if(_S1455)
            {
                _S1590 = false;
            }
            else
            {
                bool _S1673 = !_S1589;
                if(_S1673)
                {
                    bool _S1674 = (_S1431.material.roughness) == 0.0f;
                    if(_S1674)
                    {
                        _S1590 = true;
                    }
                    else
                    {
                        bool _S1675 = b_9 == 1U;
                        if(_S1675)
                        {
                            _S1590 = (_S1448.x) == (_S1448.y);
                        }
                        else
                        {
                            _S1590 = false;
                        }
                    }
                }
                else
                {
                    _S1590 = false;
                }
            }
            bool _S1676 = !_S1455;
            if(_S1676)
            {
                _S1591 = b_9 == 1U;
            }
            else
            {
                _S1591 = false;
            }
            if(_S1591)
            {
                straight_0 = (_S1431.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1592 = _S1676;
            }
            else
            {
                _S1592 = false;
            }
            if(_S1592)
            {
                _S1593 = b_9 == 1U;
            }
            else
            {
                _S1593 = false;
            }
            if(_S1593)
            {
                _S1594 = (_S1448.x) == (_S1448.y);
            }
            else
            {
                _S1594 = false;
            }
            BSDFMaterial _S1677 = _S1431.material;
            bool _S1678 = isTranslucent_0(&_S1677);
            if(_S1678)
            {
                _S1595 = _S1672;
            }
            else
            {
                _S1595 = false;
            }
            if(_S1595)
            {
                _S1596 = (dot_0(throughput_9, surface_13.geometry_n)) < 0.0f;
            }
            else
            {
                _S1596 = false;
            }
            if(nee_0)
            {
                _S1597 = !_S1590;
            }
            else
            {
                _S1597 = false;
            }
            if(_S1597)
            {
                _S1598 = !wrong_side_0;
            }
            else
            {
                _S1598 = false;
            }
            if(_S1598)
            {
                float _S1679 = (&lobe_5)->pdf;
                float3  _S1680 = (&ray_2)->origin;
                float3  _S1681 = _slang_select(_S1460, _S1256,_S1432.smooth_n);
                float3  _S1682 = (&ray_2)->origin;
                FKSurface _S1683 = surface_13;
                float3  _S1684 = - _S1432.smooth_n;
                float3  _S1685 = _slang_select(_S1596, _S1684,_S1432.smooth_n);
                NEEVertex _S1686 = NEEVertex_x24init_0(false, _S1679, _S1680, _S1681, _S1682 + make_float3 (_S1683.geometry_offset) * _S1685);
                nee_vertex_0 = _S1686;
            }
            else
            {
                if(_S1455)
                {
                    _S1599 = true;
                }
                else
                {
                    bool _S1687 = b_9 != 1U;
                    if(_S1687)
                    {
                        _S1599 = true;
                    }
                    else
                    {
                        _S1599 = (_S1448.x) != (_S1448.y);
                    }
                }
                if(_S1599)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1688 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1688)
            {
                if(_S1589)
                {
                    _S1599 = true;
                }
                else
                {
                    _S1599 = ((&lobe_5)->pdf * (&prev_0)->cos / ((&hit_4)->distance * (&hit_4)->distance) * threshold_0) <= 1.0f;
                }
            }
            else
            {
                _S1599 = false;
            }
            bool _S1689 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1689)
            {
                if(_S1589)
                {
                    _S1600 = true;
                }
                else
                {
                    _S1600 = (_S1431.material.roughness) >= 0.20000000298023224f;
                }
            }
            else
            {
                _S1600 = false;
            }
            if(_S1491)
            {
                bool _S1690 = !_S1599;
                if(_S1690)
                {
                    return _S1257;
                }
                bool _S1691 = _S1262 != 1U;
                if(_S1691)
                {
                    _S1601 = _S1262 != 2U;
                }
                else
                {
                    _S1601 = false;
                }
                if(_S1601)
                {
                    float _S1692 = (&lobe_5)->pdf;
                    float _S1693 = _slang_select(nee_0, _S1692,0.0f);
                    float _S1694 = escapeWeight_0(_S1693, _S1608);
                    if(_S1499)
                    {
                        passes_0 = _S1268;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1695 = _slang_select(passes_0, _S1694,1.0f);
                    return Shift_x24init_0(throughput_7 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_8->radiance * make_float3 (_S1695) / make_float3 (r_8->jac), density_4 * (&lobe_5)->pdf / r_8->jac);
                }
                float3  _S1696 = throughput_7 * make_float3 ((&lobe_5)->pdf);
                float _S1697 = density_4 * (&lobe_5)->pdf;
                throughput_10 = _S1696;
                density_6 = _S1697;
            }
            else
            {
                throughput_10 = throughput_7;
                density_6 = density_4;
            }
            uint _S1698 = (fcptLayers((hit_4)));
            bool _S1699 = _S1698 > 1U;
            if(_S1699)
            {
                _S1601 = (b_9 == 1U) != passes_0;
            }
            else
            {
                _S1601 = false;
            }
            if(viewed_1)
            {
                _S1602 = _S1601;
            }
            else
            {
                _S1602 = false;
            }
            if(_S1602)
            {
                return _S1257;
            }
            if(replay_1)
            {
                _S1603 = b_6 <= _S1272;
            }
            else
            {
                _S1603 = false;
            }
            if(_S1603)
            {
                _S1604 = _S1430;
            }
            else
            {
                _S1604 = false;
            }
            bool _S1700;
            if(_S1604)
            {
                _S1700 = _S1599;
            }
            else
            {
                _S1700 = false;
            }
            bool _S1701;
            if(_S1700)
            {
                _S1701 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1701 = !_S1600;
                }
                else
                {
                    _S1701 = false;
                }
            }
            if(_S1701)
            {
                return _S1257;
            }
            if(viewed_1)
            {
                float3  _S1702 = throughput_10 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1703 = (&lobe_5)->pdf;
                throughput_11 = _S1702;
                sky_pdf_2 = _S1703;
            }
            else
            {
                float3  _S1704 = throughput_10 * max_0((&lobe_5)->throughput, _S1256);
                throughput_11 = _S1704;
                sky_pdf_2 = density_6;
            }
            bool _S1705;
            if(_S1465)
            {
                _S1705 = !_S1479;
            }
            else
            {
                _S1705 = false;
            }
            bool _S1706;
            if(_S1705)
            {
                _S1706 = _S1430;
            }
            else
            {
                _S1706 = false;
            }
            bool _S1707;
            if(_S1706)
            {
                _S1707 = _S1599;
            }
            else
            {
                _S1707 = false;
            }
            if(_S1707)
            {
                chain_0 = here_0;
                uint _S1708 = insertBits_0((&chain_0)->path, b_9, 18U, 3U);
                uint _S1709 = _slang_select(nee_0, 1U,0U);
                uint _S1710 = insertBits_0(_S1708, _S1709, 21U, 1U);
                (&chain_0)->path = _S1710;
                float _S1711 = (&chain_0)->jac * (&lobe_5)->pdf;
                (&chain_0)->jac = _S1711;
                (&chain_0)->dir = throughput_9;
                chain_throughput_1 = throughput_11;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1712 = surface_13;
            Vertex _S1713 = Vertex_x24init_0(_S1600, b_9, (&lobe_5)->pdf, (F32_abs((dot_0(surface_13.geometry_n, throughput_9)))), is_inside_7);
            prev_0 = _S1713;
            float _S1714 = (&lobe_5)->pdf;
            bool _S1715 = b_9 == 1U;
            bool _S1716;
            if(_S1715)
            {
                _S1716 = (_S1448.x) == (_S1448.y);
            }
            else
            {
                _S1716 = false;
            }
            float sky_pdf_3 = _slang_select(_S1716, sky_pdf_0,_S1714);
            float _S1717 = _slang_select(_S1455, 0.0f,sky_pdf_3);
            float _S1718 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * (&lobe_5)->pdf))))), (3.14159274101257324f)));
            bool _S1719 = !_S1590;
            float _S1720 = _slang_select(_S1719, _S1718,0.0f);
            float _S1721 = spread_1 + _S1720;
            bool _S1722;
            if(refracted_4)
            {
                _S1722 = !_S1596;
            }
            else
            {
                _S1722 = false;
            }
            bool is_inside_8;
            if(_S1722)
            {
                bool _S1723 = !is_inside_7;
                is_inside_8 = _S1723;
            }
            else
            {
                is_inside_8 = is_inside_7;
            }
            FKSurface _S1724 = surface_13;
            bool _S1725 = boundsVolume_0(&_S1724);
            bool _S1726;
            if(_S1725)
            {
                _S1726 = !_S1601;
            }
            else
            {
                _S1726 = false;
            }
            if(_S1726)
            {
                FKSurface faced_2 = surface_13;
                float3  _S1727 = - _S1712.geometry_n;
                float3  _S1728 = _slang_select(turned_1, _S1727,_S1712.geometry_n);
                (&faced_2)->geometry_n = _S1728;
                FKMedium _S1729 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1730 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1731 = faced_2;
                FKMedium _S1732 = _S1729;
                FKMedium _S1733 = _S1730;
                MediumSides _S1734 = mediumSides_0(&_S1731, &_S1732, filling_2, (&ray_2)->unit_direction, &_S1733);
                bool _S1735 = ((dot_0(throughput_9, _S1712.geometry_n)) > 0.0f) == ((dot_0(_S1712.geometry_n, (&faced_2)->geometry_n)) > 0.0f);
                float3  _S1736 = _slang_select(_S1735, _S1734.front.scatter,_S1734.behind.scatter);
                scatter_in_0 = _S1736;
                float3  _S1737 = _slang_select(_S1735, _S1734.front.extinction,_S1734.behind.extinction);
                extinction_in_0 = _S1737;
                float _S1738 = _slang_select(_S1735, _S1734.front.g,_S1734.behind.g);
                g_in_0 = _S1738;
                uint _S1739 = _S1734.fillings.x;
                uint _S1740 = _S1734.fillings.y;
                uint _S1741 = _slang_select(_S1735, _S1740,_S1739);
                bool _S1742 = (fcptVaryingUsed());
                uint _S1743 = _slang_select(_S1742, _S1741,4294967295U);
                filling_2 = _S1743;
            }
            (&ray_2)->unit_direction = throughput_9;
            bool _S1744 = !_S1601;
            if(_S1744)
            {
                FKSurface _S1745 = surface_13;
                float _S1746 = _slang_select(straight_0, 0.0f,_S1745.geometry_offset);
                float3  _S1747 = - _S1432.smooth_n;
                bool _S1748 = is_inside_8 != _S1596;
                float3  _S1749 = _slang_select(_S1748, _S1747,_S1432.smooth_n);
                float3  _S1750 = (&ray_2)->origin + make_float3 (_S1746) * _S1749;
                (&ray_2)->origin = _S1750;
            }
            throughput_10 = throughput_11;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1601;
            viewed_1 = _S1594;
            sky_pdf_2 = _S1717;
            spread_4 = _S1721;
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
        if(_S1465)
        {
            if(_S1398)
            {
                float3  _S1751 = throughput_10 * emission_1;
                Reservoir candidate_8 = chain_0;
                uint _S1752 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1753 = _S1752 == 1U;
                if(_S1753)
                {
                    float3  _S1754 = safeDivide(_S1751, chain_throughput_0);
                    (&candidate_8)->radiance = _S1754;
                }
                Reservoir _S1755 = withEnd(candidate_8, 2U, b_6, _S1751);
                offer(sel_7, _S1755, _S1751 * make_float3 (scale_3) / make_float3 (density_6));
            }
            if(_S1398)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1756 = survivalProbability(abs_0(throughput_10), density_6);
                density_7 = _S1756;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1757 = stream(_S1284, b_6 + 128U);
            Random _S1758 = pcg(_S1757);
            bool _S1759 = density_7 < (_S1758.value);
            if(_S1759)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1760 = (fcptMaxBounces());
                wrong_side_0 = b_6 >= _S1760;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1761 = density_6 * density_7;
            density_7 = _S1761;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1762 = layer_0 ^ 1U;
        uint _S1763 = _slang_select(passes_0, _S1762,0U);
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
            uint _S1764 = b_9 + 1U;
            b_6 = _S1764;
            layer_0 = _S1763;
            continue;
        }
        FKRay _S1765 = ray_2;
        float _S1766 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_1)
        {
            refracted_4 = _S1492;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S1261 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1767 = _slang_select(wrong_side_0, _S1766,4.294967296e+09f);
        bool _S1768 = !_S1455;
        if(straight_0)
        {
            _S1537 = true;
        }
        else
        {
            _S1537 = _S1455;
        }
        FKHit _S1769;
        if(_S1537)
        {
            _S1769 = hit_4;
        }
        else
        {
            _S1769 = _S1509;
        }
        FKHit _S1770 = (fcptTraverseInstanceBVH((_S1765), (_S1405), (_S1767), (_S1768), (_S1769), (viewed_1)));
        hit_4 = _S1770;
        if(replay_1)
        {
            _S1538 = _S1492;
        }
        else
        {
            _S1538 = false;
        }
        if(_S1538)
        {
            _S1589 = _S1261 == 1U;
        }
        else
        {
            _S1589 = false;
        }
        if(_S1589)
        {
            _S1590 = ((&hit_4)->instance_index) == (_S1273.instance_index);
        }
        else
        {
            _S1590 = false;
        }
        if(_S1590)
        {
            _S1591 = ((&hit_4)->triangle_index) == (_S1273.triangle_index);
        }
        else
        {
            _S1591 = false;
        }
        if(_S1591)
        {
            (&hit_4)->uv = _S1273.uv;
            float _S1771 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S1771;
        }
        if(replay_1)
        {
            _S1592 = _S1492;
        }
        else
        {
            _S1592 = false;
        }
        if(_S1592)
        {
            _S1593 = _S1261 == 3U;
        }
        else
        {
            _S1593 = false;
        }
        if(_S1593)
        {
            _S1594 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1594 = false;
        }
        if(_S1594)
        {
            return _S1257;
        }
        Reservoir _S1772 = chain_0;
        uint _S1773 = filling_2;
        for(;;)
        {
            bool _S1774 = (fcptVaryingUsed());
            if(_S1774)
            {
                _S1595 = _S1773 != 4294967295U;
            }
            else
            {
                _S1595 = false;
            }
            float _S1775;
            if(_S1595)
            {
                float _S1776 = (fcptMajorant((_S1773)));
                _S1775 = _S1776;
            }
            else
            {
                _S1775 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_1)
            {
                _S1596 = _S1492;
            }
            else
            {
                _S1596 = false;
            }
            if(_S1596)
            {
                _S1597 = _S1261 == 1U;
            }
            else
            {
                _S1597 = false;
            }
            if(_S1597)
            {
                _S1598 = _S1775 > 0.0f;
            }
            else
            {
                _S1598 = false;
            }
            if(_S1598)
            {
                ended_0 = _S1257;
                sky_pdf_1 = sky_pdf_2;
                spread_2 = spread_4;
                width_4 = width_3;
                density_3 = density_7;
                throughput_11 = throughput_10;
                b_9 = b_6;
                _S1599 = true;
                break;
            }
            bool _S1777 = (&prev_0)->rough;
            if(_S1777)
            {
                _S1599 = !(_S1775 > 0.0f);
            }
            else
            {
                _S1599 = false;
            }
            (&prev_0)->rough = _S1599;
            uint _S1778 = b_6 + 320U;
            bool _S1779 = b_6 == 4294967295U;
            uint _S1780 = _slang_select(_S1779, 384U,_S1778);
            uint _S1781 = stream(_S1284, _S1780);
            uint tracking_1 = _S1781;
            weight_1 = throughput_3;
            glowed_0 = _S1256;
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
                    _S1255 = int(2);
                    break;
                }
                uint _S1782 = b_9 + 320U;
                bool _S1783 = b_9 == 4294967295U;
                uint _S1784 = _slang_select(_S1783, 384U,_S1782);
                uint _S1785 = stream(_S1284, _S1784);
                Random _S1786 = pcg(_S1785);
                float _S1787 = - (F32_log((1.0f - _S1786.value))) / _S1775;
                if(_S1595)
                {
                    float3  _S1788 = (&ray_2)->origin;
                    float3  _S1789 = (&ray_2)->unit_direction;
                    float _S1790 = (&hit_4)->distance;
                    uint _S1791 = _slang_select(_S1783, 0U,b_9);
                    uint _S1792 = (&prev_0)->lobe;
                    uint _S1793 = _slang_select(_S1783, 3U,_S1792);
                    float _S1794 = (fcptTrackMedium((_S1773), (_S1788), (_S1789), (_S1790), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1791), (_S1793), (_S1783)));
                    spread_3 = _S1794;
                }
                else
                {
                    spread_3 = _S1787;
                }
                bool _S1795 = !(spread_3 < ((&hit_4)->distance));
                if(_S1795)
                {
                    _S1255 = int(2);
                    break;
                }
                if(_S1595)
                {
                    _S1600 = _S1465;
                }
                else
                {
                    _S1600 = false;
                }
                if(_S1600)
                {
                    float3  _S1796 = throughput_11 * glowed_0 / make_float3 (density_3);
                    float3  _S1797 = sel_7->glow + _S1796;
                    sel_7->glow = _S1797;
                }
                else
                {
                }
                glowed_0 = _S1256;
                uint b_10 = b_9 + 1U;
                float3  _S1798 = (&ray_2)->origin + make_float3 (spread_3) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1798;
                float3  _S1799 = flightWeight_0(scatter_in_0, extinction_in_0, _S1775, spread_3, true);
                float3  _S1800 = weight_1;
                float3  _S1801 = _slang_select(_S1595, _S1800,_S1799);
                float3  throughput_12 = throughput_11 * _S1801;
                uint _S1802 = stream(_S1284, b_10 + 320U);
                tracking_1 = _S1802;
                weight_1 = throughput_3;
                float width_7 = width_4 + spread_2 * spread_3;
                float _S1803 = spread_2 + 3.14159274101257324f;
                if(_S1465)
                {
                    _S1601 = true;
                }
                else
                {
                    bool _S1804 = b_10 == _S1272;
                    if(_S1804)
                    {
                        _S1601 = !_S1595;
                    }
                    else
                    {
                        _S1601 = false;
                    }
                }
                TreeSample light_4;
                if(_S1601)
                {
                    float3  _S1805 = (&ray_2)->origin;
                    float3  _S1806 = (&ray_2)->unit_direction;
                    float3  _S1807 = (&ray_2)->unit_direction;
                    uint _S1808 = stream(_S1284, b_10 + 64U);
                    float3  _S1809 = extinction_in_0;
                    float3  _S1810 = extinction_in_0;
                    uint2  _S1811 = make_uint2 (_S1773);
                    float3  _S1812 = (&ray_2)->unit_direction;
                    uint _S1813 = arrivalLobe_0(b_10, (&prev_0)->lobe);
                    FKHit _S1814 = _S1509;
                    ShadowContext _S1815 = ShadowContext_x24init_0(_S1809, _S1810, _S1811, _S1812, b_10, _S1813, false, spread_3, width_7, &_S1814, false);
                    ShadowContext _S1816 = _S1815;
                    TreeSample _S1817 = sampleLightTree_0(_S1805, _S1806, _S1807, 0.0f, true, _S1808, &_S1816);
                    light_4 = _S1817;
                }
                else
                {
                    light_4 = _S1506;
                }
                float _S1818 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1819 = (fcptMaxBounces());
                bool _S1820 = b_10 < _S1819;
                if(_S1820)
                {
                    _S1602 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1602 = false;
                }
                float _S1821 = _slang_select(_S1602, _S1818,0.0f);
                float3  _S1822 = throughput_12 * light_4.radiance;
                float _S1823 = powerHeuristic(light_4.density, _S1821);
                float3  _S1824 = _S1822 * make_float3 (_S1818 * _S1823);
                float3  _S1825 = _slang_select(_S1601, _S1824,_S1256);
                if(replay_1)
                {
                    _S1603 = b_10 == _S1272;
                }
                else
                {
                    _S1603 = false;
                }
                if(_S1603)
                {
                    bool _S1826 = _S1261 == 2U;
                    if(_S1826)
                    {
                        float _S1827 = resamplingTarget(_S1825);
                        _S1604 = _S1827 > 0.0f;
                    }
                    else
                    {
                        _S1604 = false;
                    }
                    if(_S1604)
                    {
                        Shift _S1828 = Shift_x24init_0(_S1825, 1.0f);
                        _S1255 = int(1);
                        ended_0 = _S1828;
                        spread_3 = _S1803;
                        width_5 = width_7;
                        throughput_9 = throughput_12;
                        b_7 = b_10;
                        break;
                    }
                    _S1255 = int(1);
                    ended_0 = _S1257;
                    spread_3 = _S1803;
                    width_5 = width_7;
                    throughput_9 = throughput_12;
                    b_7 = b_10;
                    break;
                }
                if(_S1465)
                {
                    Reservoir candidate_9 = _S1772;
                    uint _S1829 = extractBits_0(_S1772.path, 10U, 2U);
                    bool _S1830 = _S1829 == 1U;
                    if(_S1830)
                    {
                        float3  _S1831 = safeDivide(_S1825, chain_throughput_0);
                        (&candidate_9)->radiance = _S1831;
                    }
                    else
                    {
                        uint _S1832 = insertBits_0(0U, b_10 + 1U, 5U, 5U);
                        uint _S1833 = insertBits_0(_S1832, 2U, 10U, 2U);
                        (&candidate_9)->path = _S1833;
                    }
                    Reservoir _S1834 = withEnd(candidate_9, 0U, b_10, _S1825);
                    offer(sel_7, _S1834, _S1825 * make_float3 (scale_3) / make_float3 (density_3));
                    float _S1835 = survivalProbability(abs_0(throughput_12), density_3);
                    uint _S1836 = stream(_S1284, b_10 + 128U);
                    Random _S1837 = pcg(_S1836);
                    bool _S1838 = _S1835 < (_S1837.value);
                    if(_S1838)
                    {
                        _S1604 = true;
                    }
                    else
                    {
                        uint _S1839 = (fcptMaxBounces());
                        _S1604 = b_10 >= _S1839;
                    }
                    if(_S1604)
                    {
                        _S1255 = int(1);
                        ended_0 = _S1257;
                        spread_3 = _S1803;
                        width_5 = width_7;
                        throughput_9 = throughput_12;
                        b_7 = b_10;
                        break;
                    }
                    float _S1840 = density_3 * _S1835;
                    density_3 = _S1840;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1841 = stream(_S1284, b_10);
                float3  _S1842 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1841, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1842;
                NEEVertex _S1843 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1256, (&ray_2)->origin);
                nee_vertex_0 = _S1843;
                Vertex _S1844 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_6);
                prev_0 = _S1844;
                float _S1845 = (&prev_0)->pdf;
                FKRay _S1846 = ray_2;
                FKHit _S1847 = (fcptTraverseInstanceBVH((_S1846), (true), (4.294967296e+09f), (false), (_S1509), (false)));
                hit_4 = _S1847;
                b_9 = b_10;
                throughput_11 = throughput_12;
                spread_2 = _S1803;
                width_4 = width_7;
                sky_pdf_1 = _S1845;
            }
            if(_S1255 != int(2))
            {
                spread_2 = spread_3;
                width_4 = width_5;
                throughput_11 = throughput_9;
                b_9 = b_7;
                _S1599 = true;
                break;
            }
            ended_0 = _S1257;
            _S1599 = false;
            break;
        }
        if(_S1599)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1600 = b_9 == b_6;
        }
        else
        {
            _S1600 = false;
        }
        bool _S1848 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S1848)
        {
            bool _S1849 = !(&nee_vertex_0)->none;
            float _S1850 = _slang_select(_S1849, sky_pdf_1,0.0f);
            float _S1851 = escapeWeight_0(_S1850, (&ray_2)->unit_direction);
            float3  _S1852 = environment_0((&ray_2)->unit_direction, b_9, (&prev_0)->lobe);
            float3  _S1853 = throughput_11 * _S1852;
            if(replay_1)
            {
                bool _S1854 = b_9 == _S1272;
                if(_S1854)
                {
                    passes_0 = _S1261 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1853 * make_float3 (_S1851) / make_float3 (r_8->jac), density_3 / r_8->jac);
                }
                if(_S1271)
                {
                    passes_0 = _S1268;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_9 == _S1259;
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
                    return Shift_x24init_0(_S1853 * make_float3 (_S1851), 1.0f);
                }
                return _S1257;
            }
            Reservoir candidate_10 = chain_0;
            uint _S1855 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1856 = _S1855 == 1U;
            if(_S1856)
            {
                uint _S1857 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1858 = _S1857 == b_9;
                float _S1859 = _slang_select(_S1858, 1.0f,_S1851);
                float3  _S1860 = safeDivide(_S1853 * make_float3 (_S1859), chain_throughput_0);
                (&candidate_10)->radiance = _S1860;
            }
            else
            {
                bool _S1861 = (&prev_0)->rough;
                if(_S1861)
                {
                    uint _S1862 = insertBits_0(0U, b_9 + 1U, 5U, 5U);
                    uint _S1863 = insertBits_0(_S1862, 3U, 10U, 2U);
                    uint _S1864 = insertBits_0(_S1863, (&prev_0)->lobe, 15U, 3U);
                    bool _S1865 = (&prev_0)->inside;
                    uint _S1866 = _slang_select(_S1865, 1U,0U);
                    uint _S1867 = insertBits_0(_S1864, _S1866, 22U, 1U);
                    (&candidate_10)->path = _S1867;
                    (&candidate_10)->jac = (&prev_0)->pdf;
                    (&candidate_10)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1868 = _S1853 * make_float3 (_S1851);
            Reservoir _S1869 = withEnd(candidate_10, 3U, b_9, _S1868);
            offer(sel_7, _S1869, _S1868 * make_float3 (scale_3) / make_float3 (density_3));
            break;
        }
        float3  _S1870 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1870;
        bool _S1871 = (fcptVaryingUsed());
        if(_S1871)
        {
            _S1601 = filling_2 != 4294967295U;
        }
        else
        {
            _S1601 = false;
        }
        if(_S1601)
        {
            if(_S1465)
            {
                float3  _S1872 = throughput_11 * glowed_0 / make_float3 (density_3);
                float3  _S1873 = sel_7->glow + _S1872;
                sel_7->glow = _S1873;
            }
            float3  _S1874 = throughput_11 * weight_1;
            throughput_9 = _S1874;
        }
        else
        {
            float3  _S1875 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S1876 = throughput_11 * _S1875;
            throughput_9 = _S1876;
        }
        float _S1877 = width_4 + spread_2 * (&hit_4)->distance;
        viewed_0 = _S1600;
        width_3 = _S1877;
        throughput_2 = throughput_9;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_1 = spread_2;
        uint _S1764 = b_9 + 1U;
        b_6 = _S1764;
        layer_0 = _S1763;
    }
    return _S1257;
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
    Random _S1878 = pcg(state_3);
    Random _S1879 = pcg(_S1878.state);
    float _S1880 = 6.28318548202514648f * _S1878.value;
    float _S1881 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S1879.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1879.state, _S1881 * (F32_cos((_S1880))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_4, float3  value_2)
{
    RandomSphere _S1882;
    (&_S1882)->state = state_4;
    (&_S1882)->value = value_2;
    return _S1882;
}

__device__ RandomSphere random_sphere(uint state_5)
{
    Random _S1883 = normal_distribution(state_5);
    Random _S1884 = normal_distribution(_S1883.state);
    Random _S1885 = normal_distribution(_S1884.state);
    float3  _S1886 = make_float3 (_S1883.value, _S1884.value, _S1885.value);
    float3  _S1887 = ((((_S1886)) * make_float3(rnorm3df(((_S1886)).x, ((_S1886)).y, ((_S1886)).z))));
    return RandomSphere_x24init_0(_S1885.state, _S1887);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_12)
{
    float3  _S1888 = p1_0 - p0_0;
    float3  _S1889 = p2_0 - p0_0;
    float2  _S1890 = uv1_0 - uv0_0;
    float2  _S1891 = uv2_0 - uv0_0;
    float _S1892 = _S1890.x;
    float _S1893 = _S1891.y;
    float _S1894 = _S1890.y;
    float _S1895 = _S1891.x;
    float _S1896 = _S1892 * _S1893 - _S1894 * _S1895;
    float _S1897 = 1.0f / _S1896;
    float3  t_24 = (_S1888 * make_float3 (_S1893) - _S1889 * make_float3 (_S1894)) * make_float3 (_S1897);
    float3  _S1898 = (_S1889 * make_float3 (_S1892) - _S1888 * make_float3 (_S1895)) * make_float3 (_S1897);
    float3  _S1899 = t_24 - n_12 * make_float3 (dot_0(n_12, t_24));
    float3  _S1900 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_12);
    bool _S1901 = (dot_0(_S1899, _S1899)) > 0.0f;
    float3  _S1902 = _slang_select(_S1901, _S1899,_S1900);
    float3  _S1903 = ((((_S1902)) * make_float3(rnorm3df(((_S1902)).x, ((_S1902)).y, ((_S1902)).z))));
    bool _S1904 = (dot_0(cross_0(n_12, _S1903), _S1898)) > 0.0f;
    float3  t_25;
    if(_S1904)
    {
        float3  _S1905 = negate_0(_S1903);
        t_25 = _S1905;
    }
    else
    {
        t_25 = _S1903;
    }
    float3  _S1906 = cross_0(n_12, t_25);
    return makeMatrix<float, 3, 3> (t_25, _S1906, n_12);
}

__device__ float3  tangentToWorldNormalMap(float3  v_10, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_10, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_4, float3  uvw_0, float3  position_1)
{
    float3  _S1907 = t1_0 - t0_0;
    float3  _S1908 = t2_2 - t0_0;
    float3  _S1909 = t2_2 - t1_0;
    float _S1910 = (F32_min((length_0(_S1907)), ((F32_min((length_0(_S1908)), (length_0(_S1909)))))));
    float3  _S1911 = make_float3 (distance_1(position_1, t0_0), distance_1(position_1, t1_0), distance_1(position_1, t2_2));
    float3  _S1912 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1913 = dot_0(geometry_n_4, _S1912);
    float3  _S1914 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1915 = dot_0(geometry_n_4, _S1914);
    float3  _S1916 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1917 = acos_0(abs_0(make_float3 (_S1913, _S1915, dot_0(geometry_n_4, _S1916))));
    float3  _S1918 = clamp_2(tan_0(_S1917), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S1911 * _S1918, uvw_0), 0.0f, _S1910 * 0.125f);
}

__device__ float3  straightThrough(BSDFMaterial material_21)
{
    return make_float3 (material_21.transmission * (1.0f - material_21.metallic)) * material_21.albedo;
}

__device__ float hairRow(float3  in_dir_11, float3  t_26, float3  out_dir_3, uint p_15, float w_19, float alpha_10, uint nt_0)
{
    uint _S1919 = p_15 % 4U;
    float _S1920 = w_19 * HAIR_WIDTHS_0[_S1919];
    float _S1921 = (F32_asin((clamp_1(dot_0(out_dir_3, t_26), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_11, t_26), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1919] * alpha_10;
    return ((F32_asinh((_S1921 / _S1920))) / (F32_asinh((3.14159274101257324f / _S1920))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_12, float3  t_27, float3  out_dir_4, uint np_0)
{
    float3  _S1922 = worldToTangent(out_dir_4, t_27);
    float3  _S1923 = worldToTangent(in_dir_12, t_27);
    return (F32_frac((((F32_atan2((_S1922.z), (_S1922.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1923.z), (1.17549435082228751e-38f - _S1923.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_13, float3  t_28, uint p_16, float row_0, float column_0, float w_20, float alpha_11, uint nt_1, uint np_1)
{
    float3  _S1924 = worldToTangent(in_dir_13, t_28);
    uint _S1925 = p_16 % 4U;
    float _S1926 = w_20 * HAIR_WIDTHS_0[_S1925];
    float _S1927 = (F32_asin((clamp_1(dot_0(in_dir_13, t_28), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1925] * alpha_11 + _S1926 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1926))))));
    float _S1928 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1924.z), (1.17549435082228751e-38f - _S1924.x)));
    float _S1929 = (F32_cos((_S1927)));
    float3  _S1930 = tangentToWorld(make_float3 (_S1929 * (F32_cos((_S1928))), (F32_sin((_S1927))), _S1929 * (F32_sin((_S1928)))), t_28);
    return _S1930;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_13, BSDFMaterial material_22, float coverage_1)
{
    float3  _S1931;
    if((material_22.ior) == 1.0f)
    {
        float3  _S1932 = straightThrough(material_22);
        _S1931 = _S1932;
    }
    else
    {
        _S1931 = make_float3 (0.0f);
    }
    return _S1931 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_8, Reservoir r_9, bool replay_2, float scale_4, Selection * sel_8)
{
    Domain _S1933 = dom_8;
    Reservoir _S1934 = r_9;
    Shift _S1935 = walk_0(&_S1933, &_S1934, replay_2, scale_4, sel_8);
    return _S1935;
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
