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
    float3  _S487 = mix_0(_S456, material_3.albedo, material_3.metallic);
    float3  F_1 = _S487 * scale_1;
    float _S488 = rgb_to_greyscale(F_1);
    float _S489 = 1.0f - material_3.metallic;
    float3  _S490 = make_float3 (1.0f) - _S456;
    float3  _S491 = make_float3 ((1.0f - material_3.transmission) * _S489) * _S490 * scale_1;
    float3  _S492 = make_float3 (material_3.transmission * _S489) * _S490 * scale_1;
    float _S493 = (F32_max((_S488), (0.0f)));
    float _S494 = rgb_to_greyscale(_S491);
    float _S495 = (F32_max((_S494), (0.0f)));
    float _S496 = rgb_to_greyscale(_S492);
    float _S497 = sign_0(length_0(_S443));
    float _S498 = (F32_max((_S496 * _S497), (0.0f)));
    float _S499 = _S493 + _S495 + _S498 + toon_component_0;
    float _S500 = (F32_min((sheen_component_0), (1.0f)));
    bool _S501 = sheen_component_0 > 0.0f;
    if(_S501)
    {
        _S467 = !(_S499 > 0.0f);
    }
    else
    {
        _S467 = false;
    }
    float _S502 = _slang_select(_S467, 1.0f,_S500);
    float _S503 = (1.0f - _S502) / (F32_max((_S499), (0.0000152587890625f)));
    float _S504 = _S495 * _S503;
    float _S505 = _S493 * _S503;
    float _S506 = _S498 * _S503;
    bool _S507 = (frame_2.alphas.x) > 0.0f;
    float visible_1;
    if(_S507)
    {
        float3  _S508 = anisotropicLocal(v_4, frame_2.tangent, n_i_3);
        float _S509 = anisotropicG1(_S508, frame_2.alphas);
        float3  _S510 = anisotropicLocal(ggx_n_0, frame_2.tangent, n_i_3);
        float _S511 = anisotropicD(_S510, frame_2.alphas);
        float _S512 = _S509 * _S511;
        visible_1 = _S512;
    }
    else
    {
        visible_1 = 0.0f;
    }
    return BSDFLobes_x24init_0(_S439, _S440, _S443, F_1, _S488, 1.0f, _S491, _S492, _S504, _S505, _S506, 0.0f, sheen_1, _S502, view_1, frame_2.tangent, frame_2.alphas, visible_1, toon_component_0 * _S503, toon_1, toon_a_1, toon_s_1, toon_b_1, _S464, toon_norm_1, toon_view_1, toon_axis_1);
}

__device__ float translucentShare(BSDFMaterial material_4)
{
    float _S513 = rgb_to_greyscale(material_4.translucent);
    float _S514 = rgb_to_greyscale(material_4.albedo);
    float _S515 = _S513 / (_S514 + _S513);
    bool _S516 = _S513 > 0.0f;
    float _S517 = _slang_select(_S516, _S515,0.0f);
    return _S517;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float l_dot_h_0, float n_i_dot_v_0, float alpha_2, BSDFLobes lobes_0, float eta_i_3, float eta_o_3)
{
    float _S518 = lobes_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S519 = lobes_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S520 = 1.0f - lobes_0.translucent_share;
    bool _S521 = n_i_dot_l_0 < 0.0f;
    float _S522 = _slang_select(_S521, lobes_0.translucent_share,_S520);
    float _S523 = _S519 * _S522;
    bool _S524 = (lobes_0.translucent_share) > 0.0f;
    float _S525 = _slang_select(_S524, _S523,_S518);
    bool _S526 = n_i_dot_v_0 > 0.0f;
    float _S527 = _slang_select(_S526, _S525,0.0f);
    return _S527;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_4, float alpha_3, BSDFMaterial material_5, BSDFLobes lobes_1)
{
    bool _S528 = (dot_0(n_i_4, l_0)) < 0.0f;
    float3  _S529 = _slang_select(_S528, material_5.translucent,material_5.albedo);
    float _S530 = 1.0f - lobes_1.translucent_share;
    float _S531 = _slang_select(_S528, lobes_1.translucent_share,_S530);
    float3  _S532 = _S529 / make_float3 (_S531);
    bool _S533 = (lobes_1.translucent_share) > 0.0f;
    float3  _S534 = _slang_select(_S533, _S532,material_5.albedo);
    return lobes_1.diffuse_weight * _S534 / make_float3 (lobes_1.p_diffuse);
}

__device__ float smithG1(float alpha_4, float n_dot_x_0)
{
    float _S535 = alpha_4 * alpha_4;
    float _S536 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S535 + (1.0f - _S535) * n_dot_x_0 * n_dot_x_0))));
    bool _S537 = alpha_4 > 0.0f;
    float _S538 = _slang_select(_S537, _S536,1.0f);
    return _S538;
}

__device__ float trowbridgeReitz(float alpha_5, float n_dot_h_1)
{
    float _S539 = alpha_5 * alpha_5;
    float _S540 = (1.0f - n_dot_h_1) * (1.0f + n_dot_h_1) + _S539 * n_dot_h_1 * n_dot_h_1;
    return _S539 / (F32_max((3.14159274101257324f * _S540 * _S540), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float n_i_dot_v_1, float alpha_6, BSDFLobes lobes_2)
{
    float _S541 = smithG1(alpha_6, n_i_dot_v_1);
    float _S542 = _S541 * lobes_2.v_dot_h;
    float _S543 = trowbridgeReitz(alpha_6, lobes_2.n_dot_h);
    float _S544 = _S542 * _S543 / n_i_dot_v_1;
    bool _S545 = alpha_6 > 0.0f;
    bool _S546;
    if(_S545)
    {
        _S546 = (lobes_2.v_dot_h) > 0.0f;
    }
    else
    {
        _S546 = false;
    }
    if(_S546)
    {
        _S546 = (lobes_2.n_dot_h) > 0.0f;
    }
    else
    {
        _S546 = false;
    }
    if(_S546)
    {
        _S546 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S546 = false;
    }
    float _S547 = _slang_select(_S546, _S544,0.0f);
    bool _S548 = (lobes_2.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S548)
    {
        float _S549 = lobes_2.visible * lobes_2.v_dot_h / n_i_dot_v_1;
        bool _S550 = (lobes_2.v_dot_h) > 0.0f;
        if(_S550)
        {
            _S546 = (lobes_2.n_dot_h) > 0.0f;
        }
        else
        {
            _S546 = false;
        }
        if(_S546)
        {
            _S546 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S546 = false;
        }
        float _S551 = _slang_select(_S546, _S549,0.0f);
        pdf_h_0 = _S551;
    }
    else
    {
        pdf_h_0 = _S547;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float n_i_dot_l_1, float l_dot_h_1, float n_i_dot_v_2, float alpha_7, BSDFLobes lobes_3, float eta_i_4, float eta_o_4)
{
    float _S552 = vndfPDF(n_i_dot_v_2, alpha_7, lobes_3);
    float _S553 = eta_i_4 * lobes_3.v_dot_h + eta_o_4 * l_dot_h_1;
    float _S554 = lobes_3.p_refract * _S552 * eta_o_4 * eta_o_4 * (F32_abs((l_dot_h_1))) / (_S553 * _S553);
    bool _S555 = eta_i_4 != eta_o_4;
    bool _S556;
    if(_S555)
    {
        _S556 = l_dot_h_1 < 0.0f;
    }
    else
    {
        _S556 = false;
    }
    float _S557 = _slang_select(_S556, _S554,0.0f);
    return _S557;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_5, float alpha_8, BSDFMaterial material_6, BSDFLobes lobes_4)
{
    float _S558 = - dot_0(n_i_5, l_1);
    float _S559 = smithG1(alpha_8, (F32_max((_S558), (0.0f))));
    bool _S560 = (lobes_4.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S560)
    {
        float3  _S561 = negate_0(n_i_5);
        float3  _S562 = anisotropicLocal(l_1, lobes_4.tangent, _S561);
        float _S563 = anisotropicG1(_S562, lobes_4.alphas);
        G1_l_0 = _S563;
    }
    else
    {
        G1_l_0 = _S559;
    }
    return lobes_4.refract_weight * make_float3 (G1_l_0) * material_6.albedo / make_float3 (lobes_4.p_refract);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_2, float l_dot_h_2, float n_i_dot_v_3, float alpha_9, BSDFLobes lobes_5, float eta_i_5, float eta_o_5)
{
    float _S564 = lobes_5.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S565 = n_i_dot_l_2 > 0.0f;
    bool _S566;
    if(_S565)
    {
        _S566 = n_i_dot_v_3 > 0.0f;
    }
    else
    {
        _S566 = false;
    }
    float _S567 = _slang_select(_S566, _S564,0.0f);
    return _S567;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  n_i_6, float alpha_10, BSDFMaterial material_7, BSDFLobes lobes_6)
{
    float3  _S568 = l_2 + lobes_6.view;
    float3  _S569 = ((((_S568)) * make_float3(rnorm3df(((_S568)).x, ((_S568)).y, ((_S568)).z))));
    float _S570 = dot_0(n_i_6, _S569);
    float _S571 = (F32_max((dot_0(n_i_6, l_2)), (0.0f)));
    float _S572 = (F32_max((dot_0(n_i_6, lobes_6.view)), (0.0f)));
    float _S573 = 1.0f / (F32_max((material_7.sheen_roughness), (0.05000000074505806f)));
    float _S574 = 1.0f - _S570 * _S570;
    float _S575 = (2.0f + _S573) * (F32_pow(((F32_max((_S574), (0.0f)))), (0.5f * _S573))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S571 + _S572 - _S571 * _S572)), (0.0000152587890625f)));
    bool _S576 = (material_7.velvet) > 0.0f;
    float f_1;
    if(_S576)
    {
        float _S577 = (F32_max((material_7.sheen_roughness), (0.00999999977648258f)));
        float _S578 = _S577 * _S577;
        float _S579 = (F32_max((_S574), (0.0000152587890625f)));
        float _S580 = (F32_exp((- _S570 * _S570 / (_S579 * _S578)))) / (3.14159274101257324f * _S578 * _S579 * _S579) * (F32_min((1.0f), (2.0f * _S570 * (F32_min((_S571), (_S572))) / (F32_max(((F32_abs((dot_0(_S569, lobes_6.view))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S571 * _S572), (0.0000152587890625f)));
        f_1 = _S580;
    }
    else
    {
        f_1 = _S575;
    }
    return lobes_6.sheen * make_float3 (f_1 * _S571 * 2.0f * 3.14159274101257324f / lobes_6.p_sheen_velvet);
}

__device__ __forceinline__ float toonPDF(float n_i_dot_l_3, float l_dot_h_3, float n_i_dot_v_4, float alpha_11, BSDFLobes lobes_7, float eta_i_6, float eta_o_6)
{
    float _S581 = _slang_select(lobes_7.toon_glossy, l_dot_h_3,n_i_dot_l_3);
    float _S582 = (F32_acos((clamp_1(_S581, -1.0f, 1.0f))));
    float _S583;
    if(_S582 < (lobes_7.toon_a))
    {
        _S583 = 1.0f;
    }
    else
    {
        _S583 = (F32_max((1.0f - (_S582 - lobes_7.toon_a) / (F32_max((lobes_7.toon_s), (0.0000152587890625f)))), (0.0f)));
    }
    float _S584 = lobes_7.p_toon * _S583;
    float _S585 = _slang_select(lobes_7.toon_glossy, 1.0f,n_i_dot_l_3);
    float _S586 = _S584 * _S585 / lobes_7.toon_norm;
    bool _S587;
    if(lobes_7.toon_glossy)
    {
        _S587 = true;
    }
    else
    {
        _S587 = n_i_dot_l_3 > 0.0f;
    }
    float _S588 = _slang_select(_S587, _S586,0.0f);
    return _S588;
}

__device__ __forceinline__ float3  toonBSDF(float3  l_3, float3  n_i_7, float alpha_12, BSDFMaterial material_8, BSDFLobes lobes_8)
{
    float _S589 = (F32_max((dot_0(n_i_7, l_3)), (0.0f)));
    float _S590 = _slang_select(lobes_8.toon_glossy, _S589,lobes_8.toon_view);
    return lobes_8.toon * make_float3 (_S590) / make_float3 (lobes_8.p_toon);
}

__device__ __forceinline__ float reflectPDF(float n_i_dot_l_4, float l_dot_h_4, float n_i_dot_v_5, float alpha_13, BSDFLobes lobes_9, float eta_i_7, float eta_o_7)
{
    float _S591 = vndfPDF(n_i_dot_v_5, alpha_13, lobes_9);
    float _S592 = lobes_9.p_reflect * _S591 / (4.0f * lobes_9.v_dot_h);
    bool _S593 = _S591 > 0.0f;
    float _S594 = _slang_select(_S593, _S592,0.0f);
    return _S594;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_4, float3  n_i_8, float alpha_14, BSDFMaterial material_9, BSDFLobes lobes_10)
{
    float _S595 = dot_0(n_i_8, l_4);
    float _S596 = smithG1(alpha_14, (F32_max((_S595), (0.0f))));
    bool _S597 = (lobes_10.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S597)
    {
        float3  _S598 = anisotropicLocal(l_4, lobes_10.tangent, n_i_8);
        float _S599 = anisotropicG1(_S598, lobes_10.alphas);
        G1_l_1 = _S599;
    }
    else
    {
        G1_l_1 = _S596;
    }
    return make_float3 (lobes_10.reflect_weight * G1_l_1) * lobes_10.F / make_float3 (lobes_10.p_reflect);
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_4, float3  out_dir_2, float3  n_7, BSDFMaterial material_10, float eta_i_8, float eta_o_8, bool refracted_2, uint random_state_4, FixedArray<float3 , 5>  * throughputs_0, FixedArray<float, 5>  * pdfs_0)
{
    float3  ggx_n_1;
    float3  _S600 = negate_0(in_dir_4);
    float _S601 = dot_0(n_7, _S600);
    float _S602 = sign_0(_S601);
    float3  _S603 = n_7 * make_float3 (_S602);
    AnisotropicFrame _S604 = anisotropicFrame(material_10, _S603);
    float _S605 = dot_0(_S603, out_dir_2);
    float _S606 = material_10.roughness;
    float _S607 = _S606 * _S606;
    SheenProfile _S608 = sheenProfile(_S600, _S603, material_10);
    float _S609 = rgb_to_greyscale(material_10.translucent);
    bool _S610 = _S609 > 0.0f;
    bool _S611 = (dot_0(n_7, out_dir_2) * _S601) < 0.0f;
    uint _S612;
    if((F32_abs((material_10.toon.x))) > 0.0f)
    {
        _S612 = 5U;
    }
    else
    {
        _S612 = 4U;
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
        float3  _S613 = make_float3 (0.0f);
        (*throughputs_0)[i_6] = _S613;
        (*pdfs_0)[i_6] = 0.0f;
        uint i_7 = i_6 + 1U;
        i_6 = i_7;
    }
    float3  _S614 = make_float3 (0.0f);
    BSDFLobes _S615 = BSDFLobes_x24init_0(0.0f, 0.0f, _S614, _S614, 0.0f, 0.0f, _S614, _S614, 0.0f, 0.0f, 0.0f, 0.0f, _S614, 0.0f, _S614, _S614, make_float2 (0.0f), 0.0f, 0.0f, _S614, 0.0f, 0.0f, 0.0f, false, 1.0f, 0.0f, _S614);
    BSDFLobes lobe_terms_0 = _S615;
    uint half_of_0 = 4294967295U;
    float3  ggx_n_2 = _S614;
    i_6 = 0U;
    for(;;)
    {
        if(i_6 < _S612)
        {
        }
        else
        {
            break;
        }
        uint _S616;
        if(i_6 == 3U)
        {
            _S616 = 4U;
        }
        else
        {
            if(i_6 == 4U)
            {
                _S616 = 6U;
            }
            else
            {
                _S616 = i_6;
            }
        }
        bool _S617 = _S616 == 0U;
        bool _S618;
        if(_S617)
        {
            _S618 = _S610;
        }
        else
        {
            _S618 = false;
        }
        bool _S619;
        if(_S618)
        {
            _S619 = _S611;
        }
        else
        {
            _S619 = _S616 == 1U;
        }
        bool _S620 = _S619 != refracted_2;
        if(_S620)
        {
            ggx_n_1 = ggx_n_2;
            uint i_8 = i_6 + 1U;
            ggx_n_2 = ggx_n_1;
            i_6 = i_8;
            continue;
        }
        uint _S621;
        if(_S616 == 6U)
        {
            _S621 = 0U;
        }
        else
        {
            if(_S616 == 4U)
            {
                _S621 = 2U;
            }
            else
            {
                _S621 = _S616;
            }
        }
        bool _S622 = _S621 != half_of_0;
        uint half_of_1;
        if(_S622)
        {
            bool _S623 = _S621 == 0U;
            if(_S623)
            {
                float3  _S624 = sampledHalf(in_dir_4, n_7, material_10, random_state_4, _S604);
                ggx_n_1 = _S624;
            }
            else
            {
                bool _S625 = _S621 == 1U;
                if(_S625)
                {
                    float3  _S626 = refractedHalf(in_dir_4, out_dir_2, n_7, eta_i_8, eta_o_8);
                    ggx_n_1 = _S626;
                }
                else
                {
                    float3  _S627 = reflectedHalf(in_dir_4, out_dir_2);
                    ggx_n_1 = _S627;
                }
            }
            float3  _S628 = negate_0(in_dir_4);
            BSDFLobes _S629 = bsdfLobes(in_dir_4, _S628, _S603, ggx_n_1, material_10, eta_i_8, eta_o_8, _S604, _S608);
            lobe_terms_0 = _S629;
            float _S630 = translucentShare(material_10);
            (&lobe_terms_0)->translucent_share = _S630;
            half_of_1 = _S621;
        }
        else
        {
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S616)
        {
        case 0U:
            {
                float _S631 = diffusePDF(_S605, 0.0f, (F32_abs((_S601))), _S607, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(0)] = _S631;
                float3  _S632 = diffuseBSDF(out_dir_2, _S603, _S607, material_10, lobe_terms_0);
                (*throughputs_0)[int(0)] = _S632;
                break;
            }
        case 1U:
            {
                float _S633 = refractPDF(_S605, dot_0(out_dir_2, ggx_n_1), (F32_abs((_S601))), _S607, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(1)] = _S633;
                float3  _S634 = refractBSDF(out_dir_2, _S603, _S607, material_10, lobe_terms_0);
                (*throughputs_0)[int(1)] = _S634;
                break;
            }
        case 4U:
            {
                float _S635 = sheenVelvetPDF(_S605, 0.0f, (F32_abs((_S601))), _S607, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(3)] = _S635;
                float3  _S636 = sheenVelvetBSDF(out_dir_2, _S603, _S607, material_10, lobe_terms_0);
                (*throughputs_0)[int(3)] = _S636;
                break;
            }
        case 6U:
            {
                float _S637 = toonPDF(_S605, dot_0(out_dir_2, (&lobe_terms_0)->toon_axis), (F32_abs((_S601))), _S607, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(4)] = _S637;
                float3  _S638 = toonBSDF(out_dir_2, _S603, _S607, material_10, lobe_terms_0);
                (*throughputs_0)[int(4)] = _S638;
                break;
            }
        default:
            {
                float _S639 = reflectPDF(_S605, 0.0f, (F32_abs((_S601))), _S607, lobe_terms_0, eta_i_8, eta_o_8);
                (*pdfs_0)[int(2)] = _S639;
                float3  _S640 = reflectBSDF(out_dir_2, _S603, _S607, material_10, lobe_terms_0);
                (*throughputs_0)[int(2)] = _S640;
                break;
            }
        }
        half_of_0 = half_of_1;
        uint i_8 = i_6 + 1U;
        ggx_n_2 = ggx_n_1;
        i_6 = i_8;
    }
    i_6 = 0U;
    ggx_n_1 = _S614;
    for(;;)
    {
        if(i_6 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S641 = ((*pdfs_0)[i_6]) > 0.0f;
        if(_S641)
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
    bool _S642 = wrongSide_0(is_inside_2, false, dir_4, surface_1->geometry_n);
    float3  _S643 = BSDF(in_dir_5, dir_4, surface_1->smooth_n, surface_1->material, eta_1.x, eta_1.y, _S642, random_state_5, terms_0, pdfs_1);
    float3  _S644 = make_float3 (0.0f);
    uint i_10 = 0U;
    float3  f_3 = _S644;
    for(;;)
    {
        if(i_10 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S645 = ((*pdfs_1)[i_10]) > 0.0f;
        if(_S645)
        {
            float3  _S646 = (*terms_0)[i_10] * make_float3 ((*pdfs_1)[i_10]) / make_float3 ((*pdfs_1)[i_10] + pdf_0);
            (*terms_0)[i_10] = _S646;
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
    FKSurface _S647 = surface_2;
    FixedArray<float3 , 5>  terms_1;
    FixedArray<float, 5>  pdfs_2;
    float3  _S648 = skyLobes_0(in_dir_6, dir_5, &_S647, eta_2, is_inside_3, pdf_1, random_state_6, &terms_1, &pdfs_2);
    return _S648;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_6, float3  radiance_0, float3  color_0, uint random_state_7)
{
    SkySample _S649;
    (&_S649)->dir = dir_6;
    (&_S649)->radiance = radiance_0;
    (&_S649)->color = color_0;
    (&_S649)->random_state = random_state_7;
    return _S649;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_3, float2  eta_3, bool is_inside_4, uint init_random_state_0, uint lobe_state_0, ShadowContext * context_2)
{
    uint2  _S650 = (fcptEnvironmentCdfSize());
    uint2  _S651 = make_uint2 (1U, 0U);
    uint2  _S652 = _S650 - _S651;
    Random _S653 = pcg(init_random_state_0);
    Random _S654 = pcg(_S653.state);
    Random _S655 = pcg(_S654.state);
    Random _S656 = pcg(_S655.state);
    uint _S657 = _S652.x;
    uint _S658 = searchCDF_0(make_uint2 (_S657, 0U), make_uint2 (0U, 1U), _S652.y, _S653.value);
    uint _S659 = searchCDF_0(make_uint2 (0U, _S658), _S651, _S657, _S654.value);
    float2  _S660 = make_float2 ((float)_S652.x, (float)_S652.y);
    float2  _S661 = (make_float2 (float(_S659), float(_S658)) + make_float2 (_S655.value, _S656.value)) / _S660 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S662 = _S661.y;
    float _S663 = (F32_sin((_S662)));
    float _S664 = _S661.x;
    float3  _S665 = skyFrame_0(make_float3 (_S663 * (F32_cos((_S664))), (F32_cos((_S662))), _S663 * (F32_sin((_S664)))));
    float _S666 = environmentPdf_0(_S665);
    float3  _S667 = skyBSDF(ray_0->unit_direction, _S665, *surface_3, eta_3, is_inside_4, _S666, lobe_state_0);
    bool _S668 = !(_S666 > 0.0f);
    bool _S669;
    if(_S668)
    {
        _S669 = true;
    }
    else
    {
        _S669 = all_1(_S667 == make_float3 (0.0f));
    }
    if(_S669)
    {
        float3  _S670 = make_float3 (0.0f);
        return SkySample_x24init_0(_S665, _S670, _S670, _S656.state);
    }
    float3  _S671 = skyRadiance_0(ray_0->origin, surface_3, is_inside_4, _S665, context_2, _S656.state);
    return SkySample_x24init_0(_S665, _S671, _S667 * _S671, _S656.state);
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
    SampleBSDF _S672 = (fcptConnectHair((surface_4->hair), ((&surface_4->material)->albedo), ((&surface_4->material)->specular_tint), (in_dir_7), (light_1->dir)));
    float3  _S673 = _S672.throughput * make_float3 (_S672.pdf);
    float _S674 = light_1->density;
    float _S675 = 1.0f + _S672.pdf * _S672.pdf / (light_1->density * light_1->density);
    bool _S676;
    if(competing_0)
    {
        _S676 = _S674 > 0.0f;
    }
    else
    {
        _S676 = false;
    }
    float _S677 = _slang_select(_S676, _S675,1.0f);
    return _S673 / make_float3 (_S677) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_7, float3  radiance_1, float density_0, uint random_state_8)
{
    TreeSample _S678;
    (&_S678)->dir = dir_7;
    (&_S678)->radiance = radiance_1;
    (&_S678)->density = density_0;
    (&_S678)->random_state = random_state_8;
    return _S678;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_13, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S679 = importance(first_1, p_13, normal_3);
    float _S680 = importance(second_1, p_13, normal_3);
    float2  _S681 = make_float2 (_S679, _S680);
    bool _S682 = _S679 == 0.0f;
    bool _S683;
    if(_S682)
    {
        _S683 = _S680 == 0.0f;
    }
    else
    {
        _S683 = false;
    }
    if(_S683)
    {
        return 2U;
    }
    float _S684 = _S679 + _S680;
    bool _S685 = _S680 > 0.0f;
    if(_S685)
    {
        _S683 = (*pick_0 * _S684) >= _S679;
    }
    else
    {
        _S683 = false;
    }
    uint _S686 = uint(_S683);
    float _S687 = (F32_min(((*pick_0 * _S684 - float(_S686) * _S679) / _slang_vector_get_element(_S681, _S686)), (0.99999994039535522f)));
    *pick_0 = _S687;
    float _S688 = *probability_3 * (_slang_vector_get_element(_S681, _S686) / _S684);
    *probability_3 = _S688;
    return _S686;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_14, float u1_0, float u2_0)
{
    float3  _S689 = center_1 - p_14;
    float _S690 = radius_1 * radius_1 / dot_0(_S689, _S689);
    float _S691 = u1_0 * _S690 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S690), (0.0f)))))));
    float _S692 = 2.0f * u1_0;
    bool _S693 = _S690 >= 1.0f;
    float _S694 = _slang_select(_S693, _S692,_S691);
    float _S695 = (F32_sqrt(((F32_max((_S694 * (2.0f - _S694)), (0.0f))))));
    float _S696 = 6.28318548202514648f * u2_0;
    float3  _S697 = make_float3 (_S695 * (F32_cos((_S696))), 1.0f - _S694, _S695 * (F32_sin((_S696))));
    float3  _S698 = ((((_S689)) * make_float3(rnorm3df(((_S689)).x, ((_S689)).y, ((_S689)).z))));
    float3  _S699 = tangentToWorld(_S697, _S698);
    return _S699;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S700 = center_2 - ray_1->origin;
    float _S701 = dot_0(_S700, ray_1->unit_direction);
    float _S702 = dot_0(_S700, _S700) - _S701 * _S701;
    float _S703 = radius_3 * radius_3;
    bool _S704 = _S702 > _S703;
    if(_S704)
    {
        return 4.294967296e+09f;
    }
    float _S705 = (F32_sqrt((_S703 - _S702)));
    float _S706 = _S701 - _S705;
    float _S707 = _S701 + _S705;
    bool _S708 = _S706 > 0.0000152587890625f;
    bool _S709;
    if(_S708)
    {
        _S709 = _S706 < max_len_0;
    }
    else
    {
        _S709 = false;
    }
    if(_S709)
    {
        return _S706;
    }
    bool _S710 = _S707 > 0.0000152587890625f;
    if(_S710)
    {
        _S709 = _S707 < max_len_0;
    }
    else
    {
        _S709 = false;
    }
    if(_S709)
    {
        return _S707;
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
    float _S711 = sign_0(dot_0(- dir_8, n_8));
    float3  _S712 = emissive_0 * make_float3 ((F32_max((_S711), (0.0f))));
    bool _S713 = ((true));
    float3  _S714 = _slang_select(_S713, emissive_0,_S712);
    return _S714;
}

static __device__ __forceinline__ TreeSample sampleLightTree_0(float3  origin_4, float3  smooth_n_2, float3  geometry_n_1, float geometry_offset_1, bool sided_0, uint init_random_state_1, ShadowContext * context_3)
{
    Random _S715 = pcg(init_random_state_1);
    Random _S716 = pcg(_S715.state);
    Random _S717 = pcg(_S716.state);
    float3  _S718 = make_float3 (0.0f);
    TreeSample _S719 = TreeSample_x24init_0(_S718, _S718, 0.0f, _S717.state);
    TreeSample sample_0 = _S719;
    float3  _S720 = _slang_select(sided_0, _S718,smooth_n_2);
    float3  _S721 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S715.value;
    float probability_4 = 1.0f;
    uint n_9 = 0U;
    for(;;)
    {
        uint4  _S722 = (fcptLightNode((n_9)));
        if((_S722.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S723 = (fcptLightSecond((n_9)));
        uint _S724 = n_9 + 1U;
        LightNode _S725 = (fcptLightBounds((_S724)));
        LightNode _S726 = (fcptLightBounds((_S723)));
        uint _S727 = pickChild(_S725, _S726, origin_4, _S720, &pick_1, &probability_4);
        bool _S728 = _S727 > 1U;
        if(_S728)
        {
            return sample_0;
        }
        bool _S729 = _S727 == 1U;
        uint _S730 = _slang_select(_S729, _S723,_S724);
        n_9 = _S730;
    }
    bool _S731 = n_9 == 0U;
    bool _S732;
    if(_S731)
    {
        LightNode _S733 = (fcptLightBounds((0U)));
        float _S734 = importance(_S733, origin_4, _S720);
        _S732 = !(_S734 > 0.0f);
    }
    else
    {
        _S732 = false;
    }
    if(_S732)
    {
        return sample_0;
    }
    uint4  _S735 = (fcptLightNode((n_9)));
    FKHit _S736 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S737 = (_S735.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S737)
    {
        FKLight _S738 = (fcptLight((_S735.y)));
        if(sided_0)
        {
            float _S739 = sign_0(dot_0(geometry_n_1, _S738.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S739);
            float3  _S740 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S740;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S721;
            lift_n_0 = smooth_n_2;
        }
        bool _S741 = (_S738.variance) == 0.0f;
        if(_S741)
        {
            float3  _S742 = _S738.position - emitter_point_0;
            float3  _S743 = ((((_S742)) * make_float3(rnorm3df(((_S742)).x, ((_S742)).y, ((_S742)).z))));
            (&sample_0)->dir = _S743;
            float3  _S744 = _S738.color * make_float3 (_S738.intensity) / make_float3 (dot_0(_S742, _S742) * probability_4);
            (&sample_0)->radiance = _S744;
            shadow_1 = _S742;
        }
        else
        {
            float3  _S745 = sampleSphere(_S738.position, _S738.variance, emitter_point_0, _S716.value, _S717.value);
            (&sample_0)->dir = _S745;
            float _S746 = sphereDensity(_S738.position, _S738.variance, emitter_point_0);
            float _S747 = probability_4 * _S746;
            (&sample_0)->density = _S747;
            float3  _S748 = pointLightRadiance(_S738.color, _S738.intensity, _S738.variance);
            float3  _S749 = _S748 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S749;
            FKRay _S750 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S751 = raySphere_0(_S738.position, _S738.variance, &_S750, 4.294967296e+09f);
            float3  _S752 = (&sample_0)->dir * make_float3 (_S751);
            shadow_1 = _S752;
        }
        emitter_0 = _S736;
        emitter_point_0 = _S718;
    }
    else
    {
        uint _S753 = _S735.y;
        uint _S754 = (fcptTriangleOffset((_S753)));
        uint _S755 = _S754 + _S735.z;
        Matrix<float, 3, 3>  _S756 = (fcptWorldTriangle((_S753), (_S755)));
        float _S757 = (F32_sqrt((_S716.value)));
        float2  _S758 = make_float2 (_S757 * (1.0f - _S717.value), _S757 * _S717.value);
        float3  _S759 = mul_0(make_float3 (1.0f - _S757, _S758.x, _S758.y), _S756);
        if(sided_0)
        {
            float _S760 = sign_0(dot_0(geometry_n_1, _S759 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S760);
            float3  _S761 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S761;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S762 = !((dot_0(smooth_n_2, _S759 - origin_4)) > 0.0f);
            if(_S762)
            {
                return sample_0;
            }
            emitter_point_0 = _S721;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S758, _S753, _S755, 0U, 0.0f);
        float3  _S763 = _S759 - emitter_point_0;
        float3  _S764 = ((((_S763)) * make_float3(rnorm3df(((_S763)).x, ((_S763)).y, ((_S763)).z))));
        (&sample_0)->dir = _S764;
        float _S765 = solidAngle(probability_4, cross_0(_S756.rows[int(1)] - _S756.rows[int(0)], _S756.rows[int(2)] - _S756.rows[int(0)]), _S763);
        (&sample_0)->density = _S765;
        bool _S766 = (fcptShadowFirst());
        bool _S767 = !_S766;
        if(_S767)
        {
            FKSurface _S768 = (fcptLightSurfaceAt((emitter_1), (_S759), (_S717.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S759 - origin_4))));
            (&sample_0)->random_state = _S768.random_state;
            float3  _S769 = emitted_0(_S768.material.emissive, (&sample_0)->dir, _S768.smooth_n);
            float3  _S770 = _slang_select(_S768.skip, _S718,_S769);
            float3  _S771 = _S770 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S771;
        }
        shadow_1 = _S763;
        emitter_0 = emitter_1;
        emitter_point_0 = _S759;
    }
    FKHit _S772 = emitter_0;
    float3  _S773 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S717.state, &_S772);
    bool _S774 = (fcptShadowFirst());
    if(_S774)
    {
        _S732 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S732 = false;
    }
    if(_S732)
    {
        _S732 = !all_1(_S773 == _S718);
    }
    else
    {
        _S732 = false;
    }
    if(_S732)
    {
        FKSurface _S775 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S717.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S775.random_state;
        float3  _S776 = emitted_0(_S775.material.emissive, (&sample_0)->dir, _S775.smooth_n);
        float3  _S777 = _slang_select(_S775.skip, _S718,_S776);
        float3  _S778 = _S777 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S778;
    }
    float3  _S779 = (&sample_0)->radiance * _S773;
    bool _S780 = all_1(_S773 == _S718);
    float3  _S781 = _slang_select(_S780, _S718,_S779);
    (&sample_0)->radiance = _S781;
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
    float _S782 = 1.0f / (1.0f + b_1 / a_5 * (b_1 / a_5));
    bool _S783 = b_1 > 0.0f;
    float _S784 = _slang_select(_S783, _S782,1.0f);
    return _S784;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S785 = vertex_0->none;
    if(_S785)
    {
        return 1.0f;
    }
    uint _S786 = (fcptLightSlot((*hit_1)));
    float _S787 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S786, light_point_1);
    float _S788 = powerHeuristic(vertex_0->pdf, _S787);
    return _S788;
}

static __device__ float3  environment_0(float3  dir_9, uint depth_0, uint lobe_0)
{
    uint2  _S789 = (fcptEnvironmentMapSize());
    bool _S790 = all_0(_S789 > make_uint2 (1U));
    if(_S790)
    {
        float3  _S791 = (fcptEnvMapSample((dir_9), (depth_0), (lobe_0)));
        return _S791;
    }
    float3  _S792 = (fcptAmbient());
    return _S792;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S793 = (fcptEnvironmentCdfSize());
    bool _S794 = !all_0(_S793 > make_uint2 (1U));
    if(_S794)
    {
        return false;
    }
    uint2  _S795 = (fcptEnvironmentMapSize());
    return all_0(_S795 > make_uint2 (1U));
}

static __device__ float escapeWeight_0(float pdf_2, float3  dir_10)
{
    bool _S796 = pdf_2 <= 0.0f;
    bool _S797;
    if(_S796)
    {
        _S797 = true;
    }
    else
    {
        bool _S798 = environmentMapped_0();
        _S797 = !_S798;
    }
    if(_S797)
    {
        return 1.0f;
    }
    float _S799 = environmentPdf_0(dir_10);
    return pdf_2 / (pdf_2 + _S799);
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
    uint2  _S800 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S801 = make_int2 ((int)_S800.x, (int)_S800.y);
    uint _S802 = previousSeed_0(_S801);
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
            uint _S803 = previousSeed_0(_S801 + make_int2 (x_16, y_5));
            bool _S804 = _S803 == _S802;
            uint _S805 = _slang_select(_S804, 1U,0U);
            uint count_3 = count_2 + _S805;
            int x_17 = x_16 + int(1);
            x_16 = x_17;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S806 = float(count_2 - 1U) / 288.0f;
    bool _S807 = _S802 != 0U;
    float _S808 = _slang_select(_S807, _S806,0.0f);
    fcptStoreDuplication((_S801), (make_uint4 ((F32_asuint((_S808))), 0U, 0U, 0U)));
    return;
}

__device__ uint stream(uint seed_3, uint index_0)
{
    uint _S809 = hash(index_0);
    uint _S810 = hash(seed_3 ^ _S809);
    return _S810;
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
    float _S811 = rgb_to_greyscale(weight_0);
    bool _S812 = _S811 > 0.0f;
    bool _S813;
    if(_S812)
    {
        _S813 = _S811 < 3.00000000549775576e+38f;
    }
    else
    {
        _S813 = false;
    }
    bool _S814 = !_S813;
    if(_S814)
    {
        return;
    }
    bool _S815 = sel_2->sums;
    if(_S815)
    {
        float3  _S816 = sel_2->color + weight_0;
        sel_2->color = _S816;
        return;
    }
    float _S817 = sel_2->w_sum + _S811;
    sel_2->w_sum = _S817;
    float3  _S818 = sel_2->color + weight_0;
    sel_2->color = _S818;
    Random _S819 = pcg(sel_2->random_state);
    sel_2->random_state = _S819.state;
    bool _S820 = (_S819.value * sel_2->w_sum) <= _S811;
    if(_S820)
    {
        sel_2->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_3;
    float3  _S821 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S821;
    float _S822 = r_3.jac * shifted_0.jac;
    (&candidate_1)->jac = _S822;
    offer(sel_3, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S823 = rgb_to_greyscale((&r_4)->f);
    float _S824 = sel_4.w_sum / _S823;
    bool _S825 = _S823 > 0.0f;
    float _S826 = _slang_select(_S825, _S824,0.0f);
    (&r_4)->w = _S826;
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
    uint2  _S827 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S828 = make_int2 ((int)_S827.x, (int)_S827.y);
    float3  _S829 = make_float3 (0.0f);
    FKHit _S830 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S831 = Domain_x24init_0(_S829, _S829, &_S830, 0.0f, 0.0f);
    Domain dom_4 = _S831;
    bool _S832 = (fcptCurrentDomain((_S828), (&dom_4)));
    bool _S833 = !_S832;
    if(_S833)
    {
        Reservoir _S834 = (Reservoir{});
        fcptStoreReservoirPrevious((_S828), (_S834), ((&dom_4)->hit));
        return;
    }
    Reservoir _S835 = (fcptLoadReservoirTemporal((_S828)));
    uint t_13 = 0U;
    float count_4 = 0.0f;
    float c_sum_0 = _S835.c;
    for(;;)
    {
        uint _S836 = (fcptRestirNeighbours());
        if(t_13 < _S836)
        {
        }
        else
        {
            break;
        }
        int2  _S837 = partner_0(_S828, t_13);
        Domain neighbor_0 = _S831;
        bool _S838 = (fcptCurrentDomain((_S837), (&neighbor_0)));
        if(_S838)
        {
            float count_5 = count_4 + 1.0f;
            uint4  _S839 = (fcptReservoirTemporal((_S837), (0U)));
            float c_sum_1 = c_sum_0 + (U32_asfloat((_S839.w)));
            count_4 = count_5;
            c_sum_0 = c_sum_1;
        }
        uint t_14 = t_13 + 1U;
        t_13 = t_14;
    }
    float _S840 = _S835.c / (F32_max((count_4), (1.0f)));
    float _S841 = rgb_to_greyscale(_S835.f);
    bool _S842 = count_4 == 0.0f;
    float _S843 = _slang_select(_S842, 1.0f,0.0f);
    Selection _S844 = (Selection{});
    Selection sel_5 = _S844;
    uint _S845 = (fcptFrame());
    uint _S846 = hash(_S845);
    uint _S847 = global_invocation_id_2.x;
    uint2  _S848 = (fcptRenderSize());
    uint _S849 = stream(_S846, _S847 + _S848.x * global_invocation_id_2.y);
    uint _S850 = stream(_S849, 195U);
    (&sel_5)->random_state = _S850;
    t_13 = 0U;
    float canonical_mis_0 = _S843;
    for(;;)
    {
        uint _S851 = (fcptRestirNeighbours());
        if(t_13 < _S851)
        {
        }
        else
        {
            break;
        }
        int2  _S852 = partner_0(_S828, t_13);
        Domain neighbor_dom_0 = _S831;
        bool _S853 = (fcptCurrentDomain((_S852), (&neighbor_dom_0)));
        if(_S853)
        {
            Reservoir _S854 = (fcptLoadReservoirTemporal((_S852)));
            uint4  _S855 = (fcptShiftData((_S852), (t_13)));
            float4  _S856 = asfloat_0(_S855);
            uint4  _S857 = (fcptShiftData((_S828), (t_13)));
            float4  _S858 = asfloat_0(_S857);
            float _S859 = (_S854.c + _S840) / c_sum_0;
            bool _S860 = _S841 > 0.0f;
            float canonical_mis_1;
            if(_S860)
            {
                float _S861 = _S859 * _S840 * _S841;
                float _S862 = _S840 * _S841;
                float _S863 = rgb_to_greyscale(float3 {_S858.x, _S858.y, _S858.z});
                float canonical_mis_2 = canonical_mis_0 + _S861 / (_S862 + _S854.c * _S863);
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float _S864 = rgb_to_greyscale(_S854.f);
            float3  _S865 = float3 {_S856.x, _S856.y, _S856.z};
            Shift _S866 = Shift_x24init_0(_S865, _S856.w);
            float _S867 = _S859 * _S854.c * _S864;
            float _S868 = _S854.c * _S864;
            float _S869 = rgb_to_greyscale(_S865);
            offerShifted(&sel_5, _S854, _S866, _S867 / (_S868 + _S840 * _S869));
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_15 = t_13 + 1U;
        t_13 = t_15;
    }
    offerShifted(&sel_5, _S835, Shift_x24init_0(_S835.f, 1.0f), canonical_mis_0);
    Reservoir _S870 = finalize(sel_5, c_sum_0);
    fcptStoreReservoirPrevious((_S828), (_S870), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S828), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S828), (make_float4 ((&sel_5)->color.x, (&sel_5)->color.y, (&sel_5)->color.z, 0.0f)));
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
    uint _S871 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S872 = _S871 != 4294967295U;
    if(_S872)
    {
        uint2  _S873 = make_uint2 (_S871, _S871 >> 14U) & make_uint2 (16383U);
        int2  _S874 = make_int2 ((int)_S873.x, (int)_S873.y);
        ShiftJob _S875 = (ShiftJob{});
        ShiftJob shift_job_0 = _S875;
        Shift _S876 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S877 = _S871 >> 28U;
        bool _S878 = spatialJob_0(_S874, _S877, &shift_job_0, true);
        Shift shifted_1;
        if(_S878)
        {
            Domain _S879 = (&shift_job_0)->dom;
            Reservoir _S880 = (&shift_job_0)->r;
            Shift _S881 = passShift_0(&_S879, &_S880);
            shifted_1 = _S881;
        }
        else
        {
            shifted_1 = _S876;
        }
        fcptStoreShiftData((_S874), (_S877), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S882 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S883 = make_int2 ((int)_S882.x, (int)_S882.y);
    FixedArray<uint, 3>  _S884;
    spatialBins_0(_S883, &_S884);
    FixedArray<uint, 3>  _S885 = _S884;
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
        bool _S886 = (_S885[t_16]) == 40U;
        if(_S886)
        {
            fcptStoreShiftData((_S883), (t_16), (make_uint4 (0U)));
        }
        uint t_17 = t_16 + 1U;
        t_16 = t_17;
    }
    FixedArray<uint, 3>  _S887 = _S885;
    queueShifts_0(_S883, &_S887, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S888 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S889 = make_int2 ((int)_S888.x, (int)_S888.y);
    FixedArray<uint, 3>  _S890;
    spatialBins_0(_S889, &_S890);
    FixedArray<uint, 3>  _S891 = _S890;
    countShifts_0(&_S891, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S892 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S893 = _S892 != 4294967295U;
    if(_S893)
    {
        uint2  _S894 = make_uint2 (_S892, _S892 >> 14U) & make_uint2 (16383U);
        int2  _S895 = make_int2 ((int)_S894.x, (int)_S894.y);
        int2  _S896 = storedNeighbor_0(_S895);
        uint _S897 = _S892 >> 28U;
        Shift _S898 = temporalShiftAt_0(_S895, _S896, _S897);
        fcptStoreTemporalShift((_S895), (_S897), (make_uint4 (asuint_1(_S898.f).x, asuint_1(_S898.f).y, asuint_1(_S898.f).z, (F32_asuint((_S898.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S899 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S900 = make_int2 ((int)_S899.x, (int)_S899.y);
    FixedArray<uint, 3>  _S901;
    temporalBins_0(_S900, &_S901);
    FixedArray<uint, 3>  _S902 = _S901;
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
        bool _S903 = (_S902[t_18]) == 40U;
        if(_S903)
        {
            fcptStoreTemporalShift((_S900), (t_18), (make_uint4 (0U)));
        }
        uint t_19 = t_18 + 1U;
        t_18 = t_19;
    }
    FixedArray<uint, 3>  _S904 = _S902;
    queueShifts_0(_S900, &_S904, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S905 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S906 = make_int2 ((int)_S905.x, (int)_S905.y);
    bool _S907 = (fcptSceneUnchanged());
    bool _S908 = !_S907;
    bool _S909;
    if(_S908)
    {
        uint2  _S910 = (fcptRenderSize());
        int2  _S911 = make_int2 ((int)_S910.x, (int)_S910.y);
        _S909 = all_0(_S906 < _S911);
    }
    else
    {
        _S909 = false;
    }
    if(_S909)
    {
        Reservoir _S912 = (fcptLoadReservoirInitial((_S906)));
        int2  _S913 = sampleNeighbor_0(_S906, _S912.seed);
        fcptStoreTemporalNeighbor((_S906), (_S913));
    }
    FixedArray<uint, 3>  _S914;
    temporalBins_0(_S906, &_S914);
    FixedArray<uint, 3>  _S915 = _S914;
    countShifts_0(&_S915, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_6, float b_2, float t_20)
{
    return a_6 + (b_2 - a_6) * t_20;
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S916 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S917 = make_int2 ((int)_S916.x, (int)_S916.y);
    float3  _S918 = make_float3 (0.0f);
    FKHit _S919 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S920 = Domain_x24init_0(_S918, _S918, &_S919, 0.0f, 0.0f);
    Domain dom_5 = _S920;
    bool _S921 = (fcptCurrentDomain((_S917), (&dom_5)));
    bool _S922 = !_S921;
    if(_S922)
    {
        Reservoir _S923 = (Reservoir{});
        fcptStoreReservoirTemporal((_S917), (_S923), ((&dom_5)->hit));
        return;
    }
    Reservoir _S924 = (fcptLoadReservoirInitial((_S917)));
    bool _S925 = (fcptTemporalQueued());
    bool _S926 = (fcptSceneUnchanged());
    bool _S927;
    if(_S926)
    {
        _S927 = true;
    }
    else
    {
        _S927 = !_S925;
    }
    int2  _S928;
    if(_S927)
    {
        int2  _S929 = sampleNeighbor_0(_S917, _S924.seed);
        _S928 = _S929;
    }
    else
    {
        int2  _S930 = (fcptLoadTemporalNeighbor((_S917)));
        _S928 = _S930;
    }
    bool _S931 = (_S928.x) >= int(0);
    Reservoir r_5;
    if(_S931)
    {
        Reservoir _S932 = (fcptLoadReservoirPrevious((_S928)));
        uint4  _S933 = (fcptDuplication((_S928)));
        float _S934 = (U32_asfloat((_S933.x)));
        uint _S935 = (fcptRestirDecorrelation());
        bool _S936 = _S935 == 1U;
        float _S937 = _slang_select(_S936, _S934,0.0f);
        float _S938 = interpolate_0(20.0f, 1.0f, (F32_pow((_S937), (0.10000000149011612f))));
        float _S939 = (F32_min((_S932.c), (_S938)));
        bool _S940 = (fcptSceneUnchanged());
        float4  _S941 = make_float4 (_S932.f.x, _S932.f.y, _S932.f.z, 1.0f);
        bool _S942 = !_S940;
        if(_S942)
        {
            _S927 = _S925;
        }
        else
        {
            _S927 = false;
        }
        float4  to_current_0;
        if(_S927)
        {
            uint4  _S943 = (fcptTemporalShift((_S917), (0U)));
            float4  _S944 = asfloat_0(_S943);
            to_current_0 = _S944;
        }
        else
        {
            if(_S942)
            {
                Shift _S945 = temporalShiftAt_0(_S917, _S928, 0U);
                float4  _S946 = make_float4 (_S945.f.x, _S945.f.y, _S945.f.z, _S945.jac);
                to_current_0 = _S946;
            }
            else
            {
                to_current_0 = _S941;
            }
        }
        Domain own_1 = _S920;
        if(_S940)
        {
            _S927 = true;
        }
        else
        {
            bool _S947 = (fcptPreviousScenes());
            bool _S948 = !_S947;
            if(_S948)
            {
                _S927 = (_S924.w) > 0.0f;
            }
            else
            {
                _S927 = false;
            }
            if(_S927)
            {
                bool _S949 = (fcptStoredDomainInitial((_S917), (_S924.seed), (&own_1)));
                _S927 = _S949;
            }
            else
            {
                _S927 = false;
            }
            if(_S927)
            {
                Domain _S950 = (fcptPreviousDomain((_S928), (_S924.seed)));
                Domain _S951 = _S950;
                Domain _S952 = own_1;
                bool _S953 = sameDomain_0(&_S951, &_S952);
                _S927 = _S953;
            }
            else
            {
                _S927 = false;
            }
        }
        float4  _S954 = make_float4 (_S924.f.x, _S924.f.y, _S924.f.z, 1.0f);
        bool _S955 = !_S927;
        if(_S955)
        {
            _S927 = _S925;
        }
        else
        {
            _S927 = false;
        }
        float4  to_previous_0;
        if(_S927)
        {
            uint4  _S956 = (fcptTemporalShift((_S917), (1U)));
            float4  _S957 = asfloat_0(_S956);
            to_previous_0 = _S957;
        }
        else
        {
            if(_S955)
            {
                Shift _S958 = temporalShiftAt_0(_S917, _S928, 1U);
                float4  _S959 = make_float4 (_S958.f.x, _S958.f.y, _S958.f.z, _S958.jac);
                to_previous_0 = _S959;
            }
            else
            {
                to_previous_0 = _S954;
            }
        }
        float _S960 = rgb_to_greyscale(_S924.f);
        float _S961 = rgb_to_greyscale(_S932.f);
        Selection _S962 = (Selection{});
        Selection sel_6 = _S962;
        uint _S963 = (fcptFrame());
        uint _S964 = hash(_S963);
        uint _S965 = global_invocation_id_7.x;
        uint2  _S966 = (fcptRenderSize());
        uint _S967 = stream(_S964, _S965 + _S966.x * global_invocation_id_7.y);
        uint _S968 = stream(_S967, 194U);
        (&sel_6)->random_state = _S968;
        float _S969 = _S924.c * _S960;
        float4  _S970 = to_previous_0;
        float _S971 = rgb_to_greyscale(float3 {_S970.x, _S970.y, _S970.z});
        float _S972 = _S969 / (_S969 + _S939 * _S971);
        float _S973 = _S939 * _S961;
        float4  _S974 = to_current_0;
        float3  _S975 = float3 {_S974.x, _S974.y, _S974.z};
        float _S976 = rgb_to_greyscale(_S975);
        float _S977 = _S973 / (_S973 + _S924.c * _S976);
        float2  _S978 = make_float2 (_S972, _S977);
        offerShifted(&sel_6, _S924, Shift_x24init_0(_S924.f, 1.0f), _S972);
        offerShifted(&sel_6, _S932, Shift_x24init_0(_S975, to_current_0.w), _S977);
        Reservoir _S979 = finalize(sel_6, _S924.c + _S939);
        r_5 = _S979;
    }
    else
    {
        r_5 = _S924;
    }
    fcptStoreReservoirTemporal((_S917), (r_5), ((&dom_5)->hit));
    return;
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S980 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S981 = make_int2 ((int)_S980.x, (int)_S980.y);
    float3  _S982 = make_float3 (0.0f);
    float2  _S983 = make_float2 (0.0f);
    FKHit _S984 = Hit_x24init_0(_S983, 0U, 0U, 0U, 0.0f);
    Domain _S985 = Domain_x24init_0(_S982, _S982, &_S984, 0.0f, 0.0f);
    Domain dom_6 = _S985;
    bool _S986 = (fcptCurrentDomain((_S981), (&dom_6)));
    bool _S987 = !_S986;
    if(_S987)
    {
        Reservoir _S988 = (Reservoir{});
        fcptStoreReservoirInitial((_S981), (_S988), ((&dom_6)->hit));
        return;
    }
    uint _S989 = (fcptFrame());
    uint _S990 = hash(_S989);
    uint _S991 = global_invocation_id_8.x;
    uint2  _S992 = (fcptRenderSize());
    uint _S993 = stream(_S990, _S991 + _S992.x * global_invocation_id_8.y);
    Selection _S994 = (Selection{});
    Selection initial_0 = _S994;
    uint _S995 = stream(_S993, 193U);
    (&initial_0)->random_state = _S995;
    bool _S996 = (fcptRestirUsed());
    bool _S997 = !_S996;
    (&initial_0)->sums = _S997;
    uint _S998 = stream(_S993, 0U);
    (&(&initial_0)->r)->seed = _S998;
    FKHit _S999 = Hit_x24init_0(_S983, 4294967295U, 0U, 0U, 0.0f);
    uint _S1000 = (fcptSamples());
    float _S1001 = 1.0f / float(_S1000);
    FKHit hit_2 = _S999;
    uint i_17 = 0U;
    float3  seen_0 = _S982;
    for(;;)
    {
        uint _S1002 = (fcptSamples());
        if(i_17 < _S1002)
        {
        }
        else
        {
            break;
        }
        Reservoir _S1003 = (Reservoir{});
        Reservoir r_6 = _S1003;
        uint _S1004 = stream(_S993, i_17);
        (&r_6)->seed = _S1004;
        Domain path_0 = _S985;
        bool _S1005 = (fcptStoredDomainInitial((_S981), ((&r_6)->seed), (&path_0)));
        bool _S1006 = !_S1005;
        if(_S1006)
        {
            float3  _S1007 = (fcptMissed((_S981), (path_0), (_S1001)));
            float3  seen_1 = seen_0 + _S1007;
            seen_0 = seen_1;
            uint i_18 = i_17 + 1U;
            i_17 = i_18;
            continue;
        }
        Domain _S1008 = path_0;
        Reservoir _S1009 = r_6;
        Shift _S1010 = passWalk_0(&_S1008, &_S1009, false, _S1001, &initial_0);
        bool _S1011 = ((&(&initial_0)->r)->seed) == ((&r_6)->seed);
        FKHit hit_3;
        if(_S1011)
        {
            FKHit _S1012 = (&path_0)->hit;
            hit_3 = _S1012;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_18 = i_17 + 1U;
        i_17 = i_18;
    }
    uint _S1013 = (fcptSamples());
    float3  seen_2 = seen_0 + (&initial_0)->glow / make_float3 (float(_S1013));
    float3  _S1014 = seen_2 + (&initial_0)->color;
    bool _S1015 = (&initial_0)->sums;
    float3  _S1016 = _slang_select(_S1015, _S1014,seen_2);
    fcptAddColor((_S981), (make_float4 (_S1016.x, _S1016.y, _S1016.z, 1.0f)));
    Reservoir _S1017 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S981), (_S1017), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_3, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S1018;
    (&_S1018)->none = none_0;
    (&_S1018)->pdf = pdf_3;
    (&_S1018)->origin = origin_5;
    (&_S1018)->smooth_n = smooth_n_3;
    (&_S1018)->start = start_6;
    return _S1018;
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
    Vertex _S1019;
    (&_S1019)->rough = rough_0;
    (&_S1019)->lobe = lobe_1;
    (&_S1019)->pdf = pdf_4;
    (&_S1019)->cos = cos_0;
    (&_S1019)->inside = inside_0;
    return _S1019;
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
    float3  _S1020 = exp_0((make_float3 (sigma_0) - extinction_0) * make_float3 (distance_2));
    float3  _S1021 = scatter_0 * _S1020 / make_float3 (sigma_0);
    float3  _S1022 = _slang_select(scatters_0, _S1021,_S1020);
    return _S1022;
}

static __device__ uint arrivalLobe_0(uint b_3, uint prev_lobe_0)
{
    bool _S1023 = b_3 > 0U;
    uint _S1024 = _slang_select(_S1023, prev_lobe_0,3U);
    return _S1024;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_2, bool surface_5, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S1025;
    (&_S1025)->extinction_behind = extinction_behind_0;
    (&_S1025)->extinction_front = extinction_front_0;
    (&_S1025)->fillings = fillings_0;
    (&_S1025)->side = side_0;
    (&_S1025)->depth = depth_1;
    (&_S1025)->lobe = lobe_2;
    (&_S1025)->surface = surface_5;
    (&_S1025)->length = length_2;
    (&_S1025)->width = width_1;
    (&_S1025)->own = *own_2;
    (&_S1025)->fiber = fiber_0;
    return _S1025;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S1026 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S1026)
    {
        return 0.07957746833562851f;
    }
    float _S1027 = g_0 * g_0;
    return (1.0f - _S1027) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S1027 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_7, float3  b_4)
{
    float3  _S1028 = a_7 / b_4;
    float3  _S1029 = make_float3 (0.0f);
    bool3  _S1030 = b_4 == _S1029;
    float3  _S1031 = _slang_select(_S1030, _S1029,_S1028);
    return _S1031;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_6)
{
    uint _S1032 = (1U << count_6) - 1U;
    return (e_2 & (~(_S1032 << offset_1))) | ((newbits_0 & _S1032) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_7, uint end_type_0, uint end_0, float3  f_5)
{
    Reservoir candidate_2 = r_7;
    uint _S1033 = insertBits_0(r_7.path, end_0, 0U, 5U);
    uint _S1034 = insertBits_0(_S1033, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S1034;
    (&candidate_2)->f = f_5;
    return candidate_2;
}

__device__ float survivalProbability(float3  throughput_0, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_0.x), ((F32_max((throughput_0.y), (throughput_0.z)))))) / density_1), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_9)
{
    Random _S1035 = pcg(random_state_9);
    Random _S1036 = pcg(_S1035.state);
    float _S1037 = 1.0f - 2.0f * _S1035.value;
    float _S1038 = (F32_sqrt(((F32_max((1.0f - _S1037 * _S1037), (0.0f))))));
    float _S1039 = 6.28318548202514648f * _S1036.value;
    return make_float3 (_S1038 * (F32_cos((_S1039))), _S1038 * (F32_sin((_S1039))), _S1037);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_11, uint random_state_10, float * pdf_5)
{
    bool _S1040 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1040)
    {
        *pdf_5 = 0.07957746833562851f;
        float3  _S1041 = isotropic_0(random_state_10);
        return _S1041;
    }
    Random _S1042 = pcg(random_state_10);
    Random _S1043 = pcg(_S1042.state);
    float _S1044 = g_1 * g_1;
    float _S1045 = 2.0f * g_1;
    float _S1046 = (1.0f - _S1044) / (1.0f - g_1 + _S1045 * _S1042.value);
    float _S1047 = clamp_1((1.0f + _S1044 - _S1046 * _S1046) / _S1045, -1.0f, 1.0f);
    float _S1048 = (F32_sqrt(((F32_max((1.0f - _S1047 * _S1047), (0.0f))))));
    float _S1049 = 6.28318548202514648f * _S1043.value;
    float _S1050 = phaseHG_0(g_1, _S1047);
    *pdf_5 = _S1050;
    float3  _S1051 = tangentToWorld(make_float3 (_S1048 * (F32_cos((_S1049))), _S1047, _S1048 * (F32_sin((_S1049)))), dir_11);
    float3  _S1052 = ((((_S1051)) * make_float3(rnorm3df(((_S1051)).x, ((_S1051)).y, ((_S1051)).z))));
    return _S1052;
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_1, float3  emissive_1, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_2, float velvet_0, float3  toon_2)
{
    BSDFMaterial _S1053;
    (&_S1053)->albedo = albedo_1;
    (&_S1053)->emissive = emissive_1;
    (&_S1053)->roughness = roughness_0;
    (&_S1053)->metallic = metallic_0;
    (&_S1053)->transmission = transmission_0;
    (&_S1053)->ior = ior_0;
    (&_S1053)->absorption = absorption_0;
    (&_S1053)->specular_tint = specular_tint_0;
    (&_S1053)->specular_level = specular_level_0;
    (&_S1053)->translucent = translucent_0;
    (&_S1053)->sheen = sheen_2;
    (&_S1053)->sheen_roughness = sheen_roughness_0;
    (&_S1053)->anisotropy = anisotropy_0;
    (&_S1053)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1053)->tangent = tangent_2;
    (&_S1053)->velvet = velvet_0;
    (&_S1053)->toon = toon_2;
    return _S1053;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1054;
    (&_S1054)->scatter = scatter_1;
    (&_S1054)->extinction = extinction_1;
    (&_S1054)->g = g_2;
    return _S1054;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_11, bool skip_0, uint random_state_11, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1055;
    (&_S1055)->smooth_n = smooth_n_4;
    (&_S1055)->geometry_n = geometry_n_2;
    (&_S1055)->geometry_offset = geometry_offset_2;
    (&_S1055)->material = *material_11;
    (&_S1055)->skip = skip_0;
    (&_S1055)->random_state = random_state_11;
    (&_S1055)->coverage = coverage_0;
    (&_S1055)->encloses = encloses_0;
    (&_S1055)->volume = *volume_0;
    (&_S1055)->fills = fills_0;
    (&_S1055)->hair = hair_0;
    return _S1055;
}

static __device__ FKSurface emitting_0(FKSurface * surface_6, bool top_0)
{
    FKSurface lower_0 = *surface_6;
    float3  _S1056 = (&surface_6->material)->emissive;
    float3  _S1057 = make_float3 (0.0f);
    bool _S1058 = !top_0;
    float3  _S1059 = _slang_select(_S1058, _S1057,_S1056);
    (&(&lower_0)->material)->emissive = _S1059;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_7, float u_1)
{
    float _S1060 = surface_7->coverage;
    bool _S1061 = u_1 < _S1060;
    if(_S1061)
    {
        return *surface_7;
    }
    float3  _S1062 = make_float3 (0.0f);
    float3  _S1063 = make_float3 (1.0f);
    BSDFMaterial _S1064 = Material_x24init_0(_S1062, _S1062, 0.0f, 0.0f, 0.0f, 0.0f, _S1062, _S1063, 1.0f, _S1062, _S1062, 0.5f, 0.0f, 0.0f, _S1062, 0.0f, _S1062);
    BSDFMaterial material_12 = _S1064;
    (&material_12)->albedo = _S1063;
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
    bool _S1065 = transmission_1 > 0.0f;
    bool _S1066;
    if(_S1065)
    {
        _S1066 = true;
    }
    else
    {
        _S1066 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1067 = _slang_select(_S1066, 1.0f,-1.0f);
    return _S1067;
}

static __device__ bool arrivesBehind_0(float3  dir_12, float3  n_10)
{
    return (dot_0(dir_12, n_10)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_8, float3  dir_13)
{
    float3  _S1068 = surface_8->geometry_n;
    float _S1069 = facingSign((&surface_8->material)->transmission, surface_8->geometry_n, dir_13);
    FKSurface faced_0 = *surface_8;
    float3  _S1070 = surface_8->smooth_n * make_float3 (_S1069);
    (&faced_0)->smooth_n = _S1070;
    float3  _S1071 = _S1068 * make_float3 (_S1069);
    (&faced_0)->geometry_n = _S1071;
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
    float3  _S1072 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1072));
}

__device__ float2  vertexEta(BSDFMaterial material_13, float n_dot_v_0)
{
    bool _S1073 = n_dot_v_0 < 0.0f;
    float _S1074 = _slang_select(_S1073, material_13.ior,1.0f);
    float _S1075 = _slang_select(_S1073, 1.0f,material_13.ior);
    return make_float2 (_S1074, _S1075);
}

__device__ bool neeDecision(BSDFMaterial material_14, float n_dot_v_1, float eta_i_9, float eta_o_9)
{
    float _S1076 = fresnel((F32_abs((n_dot_v_1))), eta_i_9, eta_o_9);
    float3  _S1077 = mix_0(make_float3 (_S1076), material_14.albedo, material_14.metallic);
    float _S1078 = rgb_to_greyscale(_S1077);
    float _S1079 = (F32_max(((1.0f - _S1078) * (1.0f - material_14.metallic) * (1.0f - material_14.transmission)), (0.0f)));
    bool _S1080 = _S1079 > 0.03999999910593033f;
    bool _S1081;
    if(_S1080)
    {
        _S1081 = true;
    }
    else
    {
        _S1081 = (material_14.roughness) > 0.20000000298023224f;
    }
    return _S1081;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_15)
{
    float _S1082 = rgb_to_greyscale(material_15->translucent);
    return _S1082 > 0.0f;
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
    MediumSides _S1083;
    (&_S1083)->behind = *behind_0;
    (&_S1083)->front = *front_0;
    (&_S1083)->fillings = fillings_1;
    (&_S1083)->face = face_1;
    return _S1083;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_9, FKMedium * medium_0, uint filling_0, float3  dir_14, FKMedium * outside_0)
{
    float3  _S1084 = surface_9->geometry_n;
    MediumSides _S1085 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_9->geometry_n);
    MediumSides sides_0 = _S1085;
    bool _S1086 = surface_9->encloses;
    if(_S1086)
    {
        (&sides_0)->behind = surface_9->volume;
        *&((&(&sides_0)->fillings)->x) = surface_9->fills;
        bool _S1087 = (dot_0(dir_14, _S1084)) > 0.0f;
        if(_S1087)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_10, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_15, uint depth_2, uint lobe_3, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1088 = surface_10->geometry_n;
    ShadowContext _S1089 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_10->geometry_n, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
    bool _S1090 = surface_10->encloses;
    ShadowContext context_4;
    if(_S1090)
    {
        FKSurface faced_1 = *surface_10;
        float3  _S1091 = - _S1088;
        float3  _S1092 = _slang_select(turned_0, _S1091,_S1088);
        (&faced_1)->geometry_n = _S1092;
        FKMedium _S1093 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1094 = faced_1;
        FKMedium _S1095 = _S1093;
        MediumSides _S1096 = mediumSides_0(&_S1094, &_S1095, filling_1, dir_15, outside_1);
        ShadowContext _S1097 = ShadowContext_x24init_0(_S1096.behind.extinction, _S1096.front.extinction, _S1096.fillings, _S1088, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
        if(turned_0)
        {
            uint2  _S1098 = _S1096.fillings;
            ShadowContext _S1099 = ShadowContext_x24init_0(_S1096.front.extinction, _S1096.behind.extinction, uint2 {_S1098.y, _S1098.x}, _S1088, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
            context_4 = _S1099;
        }
        else
        {
            context_4 = _S1097;
        }
    }
    else
    {
        context_4 = _S1089;
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
    float3  _S1100 = light_2->dir;
    bool _S1101 = (dot_0(geometry_n_3, - in_dir_8) * dot_0(geometry_n_3, light_2->dir)) <= 0.0f;
    FixedArray<float3 , 5>  throughputs_1;
    FixedArray<float, 5>  pdfs_3;
    float3  _S1102 = BSDF(in_dir_8, _S1100, smooth_n_5, *material_16, eta_i_10, eta_o_10, _S1101, random_state_12, &throughputs_1, &pdfs_3);
    bool _S1103 = !competing_1;
    bool _S1104;
    if(_S1103)
    {
        _S1104 = true;
    }
    else
    {
        _S1104 = (light_2->density) == 0.0f;
    }
    if(_S1104)
    {
        return _S1102 * light_2->radiance;
    }
    float3  _S1105 = make_float3 (0.0f);
    uint i_23 = 0U;
    float3  weighted_0 = _S1105;
    for(;;)
    {
        if(i_23 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S1106 = (pdfs_3[i_23]) > 0.0f;
        if(_S1106)
        {
            float _S1107 = light_2->density;
            float _S1108 = pdfs_3[i_23] / light_2->density;
            float3  weighted_1 = weighted_0 + throughputs_1[i_23] * make_float3 (pdfs_3[i_23]) / make_float3 (_S1107 * (1.0f + _S1108 * _S1108));
            weighted_0 = weighted_1;
        }
        uint i_24 = i_23 + 1U;
        i_23 = i_24;
    }
    return weighted_0 * light_2->radiance * make_float3 (light_2->density);
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_1, uint random_state_13, bool refracted_3, uint lobe_4, float pdf_6)
{
    SampleBSDF _S1109;
    (&_S1109)->unit_direction = unit_direction_1;
    (&_S1109)->throughput = throughput_1;
    (&_S1109)->random_state = random_state_13;
    (&_S1109)->refracted = refracted_3;
    (&_S1109)->lobe = lobe_4;
    (&_S1109)->pdf = pdf_6;
    return _S1109;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  n_i_9, float n_i_dot_v_6, float alpha_15, BSDFMaterial material_17, BSDFLobes lobes_11, float eta_i_11, float eta_o_11, uint random_state_14)
{
    float3  _S1110 = make_float3 (1.0f);
    SampleBSDF _S1111 = SampleBSDF_x24init_0(_S1110, _S1110, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S1111;
    Random _S1112 = pcg(random_state_14);
    Random _S1113 = pcg(_S1112.state);
    (&sample_1)->random_state = _S1113.state;
    float _S1114 = _S1112.value;
    float _S1115 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1114 * _S1114))))));
    float _S1116 = 6.28318548202514648f * _S1113.value;
    float3  _S1117 = tangentToWorld(make_float3 (_S1115 * (F32_cos((_S1116))), _S1112.value, _S1115 * (F32_sin((_S1116)))), n_i_9);
    (&sample_1)->unit_direction = _S1117;
    (&sample_1)->lobe = 4U;
    float3  _S1118 = sheenVelvetBSDF((&sample_1)->unit_direction, n_i_9, alpha_15, material_17, lobes_11);
    (&sample_1)->throughput = _S1118;
    float _S1119 = sheenVelvetPDF(_S1112.value, 0.0f, n_i_dot_v_6, alpha_15, lobes_11, eta_i_11, eta_o_11);
    (&sample_1)->pdf = _S1119;
    return sample_1;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1120 = (F32_sqrt((random_1_0)));
    float _S1121 = 6.28318548202514648f * random_2_0;
    float _S1122 = _S1120 * (F32_cos((_S1121)));
    float _S1123 = _S1120 * (F32_sin((_S1121)));
    float _S1124 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1122 * _S1122 - _S1123 * _S1123))))));
    return make_float3 (_S1122, _S1124, _S1123);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_2, float3  n_i_10, float n_i_dot_v_7, float alpha_16, BSDFMaterial material_18, BSDFLobes lobes_12, float eta_i_12, float eta_o_12, uint random_state_15)
{
    float3  _S1125 = make_float3 (1.0f);
    SampleBSDF _S1126 = SampleBSDF_x24init_0(_S1125, _S1125, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S1126;
    Random _S1127 = pcg(random_state_15);
    Random _S1128 = pcg(_S1127.state);
    (&sample_2)->random_state = _S1128.state;
    float3  _S1129 = sampleCosWeightedHemisphere(_S1127.value, _S1128.value);
    bool _S1130 = u_2 < (lobes_12.p_diffuse * lobes_12.translucent_share);
    float _S1131 = _S1129.y;
    float _S1132 = - _S1131;
    float _S1133 = _slang_select(_S1130, _S1132,_S1131);
    float3  _S1134 = tangentToWorld(make_float3 (_S1129.x, _S1133, _S1129.z), n_i_10);
    (&sample_2)->unit_direction = _S1134;
    (&sample_2)->refracted = _S1130;
    (&sample_2)->lobe = 0U;
    float3  _S1135 = diffuseBSDF((&sample_2)->unit_direction, n_i_10, alpha_16, material_18, lobes_12);
    (&sample_2)->throughput = _S1135;
    float _S1136 = diffusePDF(_S1133, 0.0f, n_i_dot_v_7, alpha_16, lobes_12, eta_i_12, eta_o_12);
    (&sample_2)->pdf = _S1136;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF toonSample(float3  n_i_11, float n_i_dot_v_8, float alpha_17, BSDFMaterial material_19, BSDFLobes lobes_13, float eta_i_13, float eta_o_13, uint random_state_16)
{
    float3  _S1137 = make_float3 (1.0f);
    SampleBSDF _S1138 = SampleBSDF_x24init_0(_S1137, _S1137, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S1138;
    Random _S1139 = pcg(random_state_16);
    Random _S1140 = pcg(_S1139.state);
    (&sample_3)->random_state = _S1140.state;
    float _S1141 = _S1139.value * lobes_13.toon_norm / 6.28318548202514648f;
    float t_21;
    if(lobes_13.toon_glossy)
    {
        t_21 = (F32_acos((clamp_1(1.0f - _S1141, -1.0f, 1.0f))));
    }
    else
    {
        t_21 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1141)))), (1.0f))))));
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
        float _S1142;
        if(t_21 < (lobes_13.toon_a))
        {
            _S1142 = 1.0f;
        }
        else
        {
            _S1142 = (F32_max((1.0f - (t_21 - lobes_13.toon_a) / (F32_max((lobes_13.toon_s), (0.0000152587890625f)))), (0.0f)));
        }
        float integral_1;
        if(lobes_13.toon_glossy)
        {
            integral_1 = 1.0f - (F32_cos(((F32_min((t_21), (lobes_13.toon_a))))));
        }
        else
        {
            float _S1143 = (F32_sin(((F32_min((t_21), (lobes_13.toon_a))))));
            integral_1 = _S1143 * _S1143 / 2.0f;
        }
        bool _S1144 = t_21 > (lobes_13.toon_a);
        bool _S1145;
        if(_S1144)
        {
            _S1145 = (lobes_13.toon_s) > 0.0f;
        }
        else
        {
            _S1145 = false;
        }
        float integral_2;
        if(_S1145)
        {
            if(lobes_13.toon_glossy)
            {
                float _S1146 = (F32_cos((lobes_13.toon_a)));
                float _S1147 = (F32_cos((t_21)));
                integral_2 = (1.0f + lobes_13.toon_a / lobes_13.toon_s) * (_S1146 - _S1147) - ((F32_sin((t_21))) - t_21 * _S1147 - ((F32_sin((lobes_13.toon_a))) - lobes_13.toon_a * _S1146)) / lobes_13.toon_s;
            }
            else
            {
                float _S1148 = 2.0f * lobes_13.toon_a;
                float _S1149 = (F32_cos((_S1148)));
                float _S1150 = 2.0f * t_21;
                float _S1151 = (F32_cos((_S1150)));
                integral_2 = (1.0f + lobes_13.toon_a / lobes_13.toon_s) * (_S1149 - _S1151) / 4.0f - ((F32_sin((_S1150))) / 8.0f - t_21 * _S1151 / 4.0f - ((F32_sin((_S1148))) / 8.0f - lobes_13.toon_a * _S1149 / 4.0f)) / lobes_13.toon_s;
            }
            float integral_3 = integral_1 + integral_2;
            integral_2 = integral_3;
        }
        else
        {
            integral_2 = integral_1;
        }
        float _S1152 = _S1142 * (F32_sin((t_21)));
        float _S1153;
        if(lobes_13.toon_glossy)
        {
            _S1153 = 1.0f;
        }
        else
        {
            _S1153 = (F32_cos((t_21)));
        }
        float _S1154 = _S1152 * _S1153;
        float _S1155 = (integral_2 - _S1141) / _S1154;
        bool _S1156 = _S1154 > 0.0f;
        float _S1157 = _slang_select(_S1156, _S1155,0.0f);
        float _S1158 = clamp_1(t_21 - _S1157, 0.0f, lobes_13.toon_b);
        int k_1 = k_0 + int(1);
        t_21 = _S1158;
        k_0 = k_1;
    }
    float _S1159 = 6.28318548202514648f * _S1140.value;
    float _S1160 = (F32_sin((t_21)));
    float3  _S1161 = tangentToWorld(make_float3 (_S1160 * (F32_cos((_S1159))), (F32_cos((t_21))), _S1160 * (F32_sin((_S1159)))), lobes_13.toon_axis);
    (&sample_3)->unit_direction = _S1161;
    bool _S1162 = (dot_0(n_i_11, (&sample_3)->unit_direction)) < 0.0f;
    (&sample_3)->refracted = _S1162;
    (&sample_3)->lobe = 6U;
    float3  _S1163 = toonBSDF((&sample_3)->unit_direction, n_i_11, alpha_17, material_19, lobes_13);
    (&sample_3)->throughput = _S1163;
    float _S1164 = toonPDF(dot_0(n_i_11, (&sample_3)->unit_direction), dot_0((&sample_3)->unit_direction, lobes_13.toon_axis), n_i_dot_v_8, alpha_17, lobes_13, eta_i_13, eta_o_13);
    (&sample_3)->pdf = _S1164;
    return sample_3;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_12, float n_i_dot_v_9, float alpha_18, BSDFMaterial material_20, BSDFLobes lobes_14, float eta_i_14, float eta_o_14, uint random_state_17)
{
    float3  _S1165 = make_float3 (1.0f);
    SampleBSDF _S1166 = SampleBSDF_x24init_0(_S1165, _S1165, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S1166;
    (&sample_4)->unit_direction = lobes_14.refracted;
    (&sample_4)->random_state = random_state_17;
    (&sample_4)->refracted = true;
    (&sample_4)->lobe = 1U;
    float3  _S1167 = refractBSDF((&sample_4)->unit_direction, n_i_12, alpha_18, material_20, lobes_14);
    (&sample_4)->throughput = _S1167;
    float _S1168 = refractPDF(0.0f, dot_0((&sample_4)->unit_direction, ggx_n_3), n_i_dot_v_9, alpha_18, lobes_14, eta_i_14, eta_o_14);
    (&sample_4)->pdf = _S1168;
    return sample_4;
}

static __device__ float3  reflect_0(float3  i_25, float3  n_11)
{
    return i_25 - make_float3 (2.0f * dot_0(n_11, i_25)) * n_11;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_9, float3  ggx_n_4, float3  n_i_13, float n_i_dot_v_10, float alpha_19, BSDFMaterial material_21, BSDFLobes lobes_15, float eta_i_15, float eta_o_15, uint random_state_18)
{
    float3  _S1169 = make_float3 (1.0f);
    SampleBSDF _S1170 = SampleBSDF_x24init_0(_S1169, _S1169, 0U, false, 0U, 0.0f);
    SampleBSDF sample_5 = _S1170;
    float3  _S1171 = reflect_0(in_dir_9, ggx_n_4);
    float3  _S1172 = ((((_S1171)) * make_float3(rnorm3df(((_S1171)).x, ((_S1171)).y, ((_S1171)).z))));
    (&sample_5)->unit_direction = _S1172;
    (&sample_5)->random_state = random_state_18;
    (&sample_5)->lobe = 2U;
    float3  _S1173 = reflectBSDF((&sample_5)->unit_direction, n_i_13, alpha_19, material_21, lobes_15);
    (&sample_5)->throughput = _S1173;
    float _S1174 = reflectPDF(0.0f, 0.0f, n_i_dot_v_10, alpha_19, lobes_15, eta_i_15, eta_o_15);
    (&sample_5)->pdf = _S1174;
    return sample_5;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_10, float3  n_12, BSDFMaterial material_22, float eta_i_16, float eta_o_16, uint random_init_0, float2  screen_space_0)
{
    uint random_state_19 = random_init_0;
    float3  _S1175 = negate_0(in_dir_10);
    float _S1176 = dot_0(n_12, _S1175);
    float _S1177 = sign_0(_S1176);
    float3  n_i_14 = n_12 * make_float3 (_S1177);
    float _S1178 = (F32_abs((_S1176)));
    float _S1179 = material_22.roughness;
    float _S1180 = _S1179 * _S1179;
    AnisotropicFrame _S1181 = anisotropicFrame(material_22, n_i_14);
    SheenProfile _S1182 = sheenProfile(_S1175, n_i_14, material_22);
    float3  _S1183 = sampleHalfVector(_S1175, n_i_14, _S1180, _S1181, &random_state_19);
    BSDFLobes _S1184 = bsdfLobes(in_dir_10, _S1175, n_i_14, _S1183, material_22, eta_i_16, eta_o_16, _S1181, _S1182);
    BSDFLobes lobes_16 = _S1184;
    float _S1185 = translucentShare(material_22);
    (&lobes_16)->translucent_share = _S1185;
    Random _S1186 = pcg(random_state_19);
    random_state_19 = _S1186.state;
    bool _S1187 = (_S1186.value) < ((&lobes_16)->p_sheen_velvet);
    if(_S1187)
    {
        SampleBSDF _S1188 = sheenVelvetSample(n_i_14, _S1178, _S1180, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1188;
    }
    float _S1189 = _S1186.value - (&lobes_16)->p_sheen_velvet;
    bool _S1190 = _S1189 < ((&lobes_16)->p_diffuse);
    if(_S1190)
    {
        SampleBSDF _S1191 = diffuseSample(_S1189, n_i_14, _S1178, _S1180, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1191;
    }
    bool _S1192 = _S1189 < ((&lobes_16)->p_diffuse + (&lobes_16)->p_toon);
    if(_S1192)
    {
        SampleBSDF _S1193 = toonSample(n_i_14, _S1178, _S1180, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1193;
    }
    float _S1194 = (&lobes_16)->p_toon;
    bool _S1195 = (_S1189 - _S1194) < ((&lobes_16)->p_diffuse + (&lobes_16)->p_refract);
    if(_S1195)
    {
        SampleBSDF _S1196 = refractSample(_S1183, n_i_14, _S1178, _S1180, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
        return _S1196;
    }
    SampleBSDF _S1197 = reflectSample(in_dir_10, _S1183, n_i_14, _S1178, _S1180, material_22, lobes_16, eta_i_16, eta_o_16, random_state_19);
    return _S1197;
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
    bool _S1198;
    bool _S1199;
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
    int _S1200;
    Shift ended_0;
    float density_3;
    float spread_2;
    float width_4;
    float sky_pdf_1;
    float spread_3;
    float width_5;
    uint b_6;
    float3  _S1201 = make_float3 (0.0f);
    Shift _S1202 = Shift_x24init_0(_S1201, 0.0f);
    uint _S1203 = r_8->path;
    uint _S1204 = extractBits_0(r_8->path, 0U, 5U);
    uint _S1205 = extractBits_0(_S1203, 5U, 5U);
    uint _S1206 = extractBits_0(_S1203, 10U, 2U);
    uint _S1207 = extractBits_0(_S1203, 12U, 3U);
    bool passes_0;
    if(replay_1)
    {
        bool _S1208 = _S1207 >= 3U;
        uint _S1209 = _slang_select(_S1208, 1U,0U);
        uint _S1210 = _S1204 + _S1209;
        uint _S1211 = (fcptMaxBounces());
        passes_0 = _S1210 > _S1211;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1202;
    }
    uint _S1212 = _S1205 - 1U;
    bool _S1213 = _S1207 == 3U;
    uint _S1214 = _slang_select(_S1213, 1U,0U);
    uint _S1215 = _S1204 + _S1214;
    bool _S1216 = _S1206 == 0U;
    uint _S1217 = _slang_select(_S1216, _S1215,_S1212);
    FKHit _S1218 = (fcptReservoirHit((*r_8)));
    float3  _S1219 = dom_7->x0;
    float3  _S1220 = dom_7->x1 - dom_7->x0;
    float3  _S1221 = ((((_S1220)) * make_float3(rnorm3df(((_S1220)).x, ((_S1220)).y, ((_S1220)).z))));
    FKRay _S1222 = Ray_x24init_0(dom_7->x1, _S1221);
    FKRay ray_2 = _S1222;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1201;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_1 = throughput_3;
    float3  glowed_0 = _S1201;
    float3  extinction_in_0 = _S1201;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1223 = dom_7->spread;
    float _S1224 = dom_7->width;
    float _S1225 = length_0(_S1220);
    NEEVertex _S1226 = NEEVertex_x24init_0(true, 0.0f, _S1201, _S1201, _S1201);
    NEEVertex nee_vertex_0 = _S1226;
    Vertex _S1227 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S1227;
    Reservoir _S1228 = (Reservoir{});
    Reservoir chain_0 = _S1228;
    uint _S1229 = r_8->seed;
    (&chain_0)->seed = r_8->seed;
    (&ray_2)->origin = _S1219;
    (&hit_4)->distance = _S1225;
    FKMedium _S1230 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1231 = filling_2;
    bool _S1232 = (fcptVaryingUsed());
    uint _S1233 = _slang_select(_S1232, _S1231,4294967295U);
    filling_2 = _S1233;
    scatter_in_0 = _S1230.scatter;
    extinction_in_0 = _S1230.extinction;
    g_in_0 = _S1230.g;
    Reservoir _S1234 = chain_0;
    uint _S1235 = filling_2;
    for(;;)
    {
        bool _S1236 = (fcptVaryingUsed());
        if(_S1236)
        {
            passes_0 = _S1235 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1237 = (fcptMajorant((_S1235)));
            spread_1 = _S1237;
        }
        else
        {
            spread_1 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_1)
        {
            turned_1 = 4294967295U == _S1217;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1206 == 1U;
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
            ended_0 = _S1202;
            sky_pdf_0 = 0.0f;
            spread_1 = _S1223;
            width_3 = _S1224;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_5 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1238 = (&prev_0)->rough;
        if(_S1238)
        {
            turned_1 = !(spread_1 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S1239 = stream(_S1229, 384U);
        uint tracking_0 = _S1239;
        weight_1 = throughput_3;
        glowed_0 = _S1201;
        b_5 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        threshold_0 = _S1223;
        width_3 = _S1224;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1200 = int(1);
                break;
            }
            uint _S1240 = b_5 + 320U;
            bool _S1241 = b_5 == 4294967295U;
            uint _S1242 = _slang_select(_S1241, 384U,_S1240);
            uint _S1243 = stream(_S1229, _S1242);
            Random _S1244 = pcg(_S1243);
            float _S1245 = - (F32_log((1.0f - _S1244.value))) / spread_1;
            if(passes_0)
            {
                float3  _S1246 = (&ray_2)->origin;
                float3  _S1247 = (&ray_2)->unit_direction;
                float _S1248 = (&hit_4)->distance;
                uint _S1249 = _slang_select(_S1241, 0U,b_5);
                uint _S1250 = (&prev_0)->lobe;
                uint _S1251 = _slang_select(_S1241, 3U,_S1250);
                float _S1252 = (fcptTrackMedium((_S1235), (_S1246), (_S1247), (_S1248), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1249), (_S1251), (_S1241)));
                geometry_density_0 = _S1252;
            }
            else
            {
                geometry_density_0 = _S1245;
            }
            bool _S1253 = !(geometry_density_0 < ((&hit_4)->distance));
            if(_S1253)
            {
                _S1200 = int(1);
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
                float3  _S1254 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S1255 = sel_7->glow + _S1254;
                sel_7->glow = _S1255;
            }
            else
            {
            }
            glowed_0 = _S1201;
            uint b_7 = b_5 + 1U;
            float3  _S1256 = (&ray_2)->origin + make_float3 (geometry_density_0) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1256;
            float3  _S1257 = flightWeight_0(scatter_in_0, extinction_in_0, spread_1, geometry_density_0, true);
            float3  _S1258 = weight_1;
            float3  _S1259 = _slang_select(passes_0, _S1258,_S1257);
            float3  throughput_4 = throughput_2 * _S1259;
            uint _S1260 = stream(_S1229, b_7 + 320U);
            tracking_0 = _S1260;
            weight_1 = throughput_3;
            float width_6 = width_3 + threshold_0 * geometry_density_0;
            float _S1261 = threshold_0 + 3.14159274101257324f;
            bool _S1262 = !replay_1;
            if(_S1262)
            {
                is_inside_5 = true;
            }
            else
            {
                bool _S1263 = b_7 == _S1217;
                if(_S1263)
                {
                    is_inside_5 = !passes_0;
                }
                else
                {
                    is_inside_5 = false;
                }
            }
            TreeSample _S1264 = TreeSample_x24init_0(_S1201, _S1201, 0.0f, 0U);
            if(is_inside_5)
            {
                float3  _S1265 = (&ray_2)->origin;
                float3  _S1266 = (&ray_2)->unit_direction;
                float3  _S1267 = (&ray_2)->unit_direction;
                uint _S1268 = stream(_S1229, b_7 + 64U);
                float3  _S1269 = extinction_in_0;
                float3  _S1270 = extinction_in_0;
                uint2  _S1271 = make_uint2 (_S1235);
                float3  _S1272 = (&ray_2)->unit_direction;
                uint _S1273 = arrivalLobe_0(b_7, (&prev_0)->lobe);
                FKHit _S1274 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1275 = _S1274;
                ShadowContext _S1276 = ShadowContext_x24init_0(_S1269, _S1270, _S1271, _S1272, b_7, _S1273, false, geometry_density_0, width_6, &_S1275, false);
                ShadowContext _S1277 = _S1276;
                TreeSample _S1278 = sampleLightTree_0(_S1265, _S1266, _S1267, 0.0f, true, _S1268, &_S1277);
                light_3 = _S1278;
            }
            else
            {
                light_3 = _S1264;
            }
            float _S1279 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S1280 = (fcptMaxBounces());
            bool _S1281 = b_7 < _S1280;
            if(_S1281)
            {
                viewed_0 = (light_3.density) > 0.0f;
            }
            else
            {
                viewed_0 = false;
            }
            float _S1282 = _slang_select(viewed_0, _S1279,0.0f);
            float3  _S1283 = throughput_4 * light_3.radiance;
            float _S1284 = powerHeuristic(light_3.density, _S1282);
            float3  _S1285 = _S1283 * make_float3 (_S1279 * _S1284);
            float3  _S1286 = _slang_select(is_inside_5, _S1285,_S1201);
            if(replay_1)
            {
                _S1198 = b_7 == _S1217;
            }
            else
            {
                _S1198 = false;
            }
            if(_S1198)
            {
                bool _S1287 = _S1206 == 2U;
                if(_S1287)
                {
                    float _S1288 = rgb_to_greyscale(_S1286);
                    passes_0 = _S1288 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1289 = Shift_x24init_0(_S1286, 1.0f);
                    _S1200 = int(0);
                    ended_0 = _S1289;
                    spread_1 = _S1261;
                    geometry_density_0 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_7;
                    break;
                }
                _S1200 = int(0);
                ended_0 = _S1202;
                spread_1 = _S1261;
                geometry_density_0 = width_6;
                chain_throughput_0 = throughput_4;
                layer_0 = b_7;
                break;
            }
            if(_S1262)
            {
                Reservoir candidate_3 = _S1234;
                uint _S1290 = extractBits_0(_S1234.path, 10U, 2U);
                bool _S1291 = _S1290 == 1U;
                if(_S1291)
                {
                    float3  _S1292 = safeDivide(_S1286, _S1201);
                    (&candidate_3)->radiance = _S1292;
                }
                else
                {
                    uint _S1293 = insertBits_0(0U, b_7 + 1U, 5U, 5U);
                    uint _S1294 = insertBits_0(_S1293, 2U, 10U, 2U);
                    (&candidate_3)->path = _S1294;
                }
                Reservoir _S1295 = withEnd(candidate_3, 0U, b_7, _S1286);
                offer(sel_7, _S1295, _S1286 * make_float3 (scale_3) / make_float3 (density_2));
                float _S1296 = survivalProbability(throughput_4, density_2);
                uint _S1297 = stream(_S1229, b_7 + 128U);
                Random _S1298 = pcg(_S1297);
                bool _S1299 = _S1296 < (_S1298.value);
                if(_S1299)
                {
                    _S1199 = true;
                }
                else
                {
                    uint _S1300 = (fcptMaxBounces());
                    _S1199 = b_7 >= _S1300;
                }
                if(_S1199)
                {
                    _S1200 = int(0);
                    ended_0 = _S1202;
                    spread_1 = _S1261;
                    geometry_density_0 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_7;
                    break;
                }
                float _S1301 = density_2 * _S1296;
                density_2 = _S1301;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1302 = stream(_S1229, b_7);
            float3  _S1303 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1302, &phase_pdf_0);
            (&ray_2)->unit_direction = _S1303;
            NEEVertex _S1304 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S1201, (&ray_2)->origin);
            nee_vertex_0 = _S1304;
            Vertex _S1305 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, false);
            prev_0 = _S1305;
            float _S1306 = (&prev_0)->pdf;
            FKRay _S1307 = ray_2;
            FKHit _S1308 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1309 = (fcptTraverseInstanceBVH((_S1307), (true), (4.294967296e+09f), (false), (_S1308), (false)));
            hit_4 = _S1309;
            b_5 = b_7;
            throughput_2 = throughput_4;
            threshold_0 = _S1261;
            width_3 = width_6;
            sky_pdf_0 = _S1306;
        }
        if(_S1200 != int(1))
        {
            width_3 = geometry_density_0;
            throughput_2 = chain_throughput_0;
            b_5 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1202;
        spread_1 = threshold_0;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1310 = b_5 == 4294967295U;
    bool _S1311 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1311)
    {
        bool _S1312 = !(&nee_vertex_0)->none;
        float _S1313 = _slang_select(_S1312, sky_pdf_0,0.0f);
        float _S1314 = escapeWeight_0(_S1313, (&ray_2)->unit_direction);
        float3  _S1315 = environment_0((&ray_2)->unit_direction, b_5, (&prev_0)->lobe);
        float3  _S1316 = throughput_2 * _S1315;
        if(replay_1)
        {
            bool _S1317 = b_5 == _S1217;
            if(_S1317)
            {
                passes_0 = _S1206 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S1316 * make_float3 (_S1314) / make_float3 (r_8->jac), density_2 / r_8->jac);
            }
            if(_S1216)
            {
                passes_0 = _S1213;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_5 == _S1204;
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
                return Shift_x24init_0(_S1316 * make_float3 (_S1314), 1.0f);
            }
            return _S1202;
        }
        Reservoir candidate_4 = chain_0;
        uint _S1318 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1319 = _S1318 == 1U;
        if(_S1319)
        {
            uint _S1320 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S1321 = _S1320 == b_5;
            float _S1322 = _slang_select(_S1321, 1.0f,_S1314);
            float3  _S1323 = safeDivide(_S1316 * make_float3 (_S1322), _S1201);
            (&candidate_4)->radiance = _S1323;
        }
        else
        {
            bool _S1324 = (&prev_0)->rough;
            if(_S1324)
            {
                uint _S1325 = insertBits_0(0U, b_5 + 1U, 5U, 5U);
                uint _S1326 = insertBits_0(_S1325, 3U, 10U, 2U);
                uint _S1327 = insertBits_0(_S1326, (&prev_0)->lobe, 15U, 3U);
                bool _S1328 = (&prev_0)->inside;
                uint _S1329 = _slang_select(_S1328, 1U,0U);
                uint _S1330 = insertBits_0(_S1327, _S1329, 22U, 1U);
                (&candidate_4)->path = _S1330;
                (&candidate_4)->jac = (&prev_0)->pdf;
                (&candidate_4)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S1331 = _S1316 * make_float3 (_S1314);
        Reservoir _S1332 = withEnd(candidate_4, 3U, b_5, _S1331);
        offer(sel_7, _S1332, _S1331 * make_float3 (scale_3) / make_float3 (density_2));
        return _S1202;
    }
    float3  _S1333 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S1333;
    bool _S1334 = (fcptVaryingUsed());
    if(_S1334)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1335 = !replay_1;
        if(_S1335)
        {
            float3  _S1336 = throughput_2 * glowed_0 / make_float3 (density_2);
            float3  _S1337 = sel_7->glow + _S1336;
            sel_7->glow = _S1337;
        }
        float3  _S1338 = throughput_2 * weight_1;
        throughput_2 = _S1338;
    }
    else
    {
        float3  _S1339 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
        float3  _S1340 = throughput_2 * _S1339;
        throughput_2 = _S1340;
    }
    float _S1341 = width_3 + spread_1 * (&hit_4)->distance;
    uint _S1342 = b_5 + 1U;
    b_5 = _S1342;
    layer_0 = 0U;
    width_3 = _S1341;
    passes_0 = false;
    threshold_0 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    chain_throughput_0 = _S1201;
    float3  reconnection_0 = _S1201;
    viewed_0 = _S1310;
    for(;;)
    {
        bool _S1343 = ((&hit_4)->is_point_light) == 1U;
        if(replay_1)
        {
            _S1198 = _S1206 == 1U;
        }
        else
        {
            _S1198 = false;
        }
        if(_S1198)
        {
            _S1199 = b_5 == _S1205;
        }
        else
        {
            _S1199 = false;
        }
        bool _S1344;
        if(_S1199)
        {
            bool _S1345 = ((&hit_4)->instance_index) != (_S1218.instance_index);
            if(_S1345)
            {
                _S1344 = true;
            }
            else
            {
                _S1344 = ((&hit_4)->triangle_index) != (_S1218.triangle_index);
            }
        }
        else
        {
            _S1344 = false;
        }
        if(_S1344)
        {
            return _S1202;
        }
        FKMedium _S1346 = Medium_x24init_0(_S1201, _S1201, 0.0f);
        BSDFMaterial _S1347 = Material_x24init_0(_S1201, _S1201, 0.0f, 0.0f, 0.0f, 0.0f, _S1201, throughput_3, 1.0f, _S1201, _S1201, 0.5f, 0.0f, 0.0f, _S1201, 0.0f, _S1201);
        FKMedium _S1348 = _S1346;
        FKSurface _S1349 = Surface_x24init_0(_S1201, _S1201, 0.0f, &_S1347, false, 0U, 1.0f, false, &_S1348, 4294967295U, _S1201);
        bool _S1350 = !_S1343;
        bool scatter_2;
        bool is_inside_6;
        float3  front_n_0;
        float3  throughput_5;
        FKSurface surface_12;
        if(_S1350)
        {
            uint _S1351 = stream(_S1229, b_5);
            uint _S1352 = arrivalLobe_0(b_5, (&prev_0)->lobe);
            FKSurface _S1353 = (fcptSurfaceAtPath((hit_4), ((&ray_2)->origin), (_S1351), (width_3), (layer_0), (b_5), (_S1352), ((&ray_2)->unit_direction)));
            bool _S1354 = !passes_0;
            FKSurface _S1355 = _S1353;
            FKSurface _S1356 = emitting_0(&_S1355, _S1354);
            uint _S1357 = stream(_S1229, b_5 + 256U);
            Random _S1358 = pcg(_S1357);
            FKSurface _S1359 = _S1356;
            FKSurface _S1360 = uncovered_0(&_S1359, _S1358.value);
            float _S1361 = facingSign(_S1360.material.transmission, _S1360.geometry_n, (&ray_2)->unit_direction);
            bool _S1362 = _S1361 < 0.0f;
            bool _S1363 = (_S1360.material.transmission) > 0.0f;
            if(_S1363)
            {
                bool _S1364 = arrivesBehind_0((&ray_2)->unit_direction, _S1360.geometry_n);
                scatter_2 = _S1364;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1365 = _S1360;
            FKSurface _S1366 = facingRay_0(&_S1365, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S1367 = arrivesBehind_0((&ray_2)->unit_direction, _S1366.geometry_n);
                is_inside_6 = _S1367;
            }
            else
            {
                is_inside_6 = scatter_2;
            }
            if(is_inside_6)
            {
                float3  _S1368 = beerLambert((&hit_4)->distance, _S1366.material.absorption);
                float3  _S1369 = throughput_2 * _S1368;
                front_n_0 = _S1369;
            }
            else
            {
                front_n_0 = throughput_2;
            }
            bool _S1370 = !_S1366.skip;
            float geometry_density_1 = (F32_abs((dot_0(_S1366.geometry_n, (&ray_2)->unit_direction)))) / ((&hit_4)->distance * (&hit_4)->distance);
            bool _S1371 = b_5 == _S1342;
            if(_S1371)
            {
                float _S1372 = 0.00251327408477664f / geometry_density_1;
                geometry_density_0 = _S1372;
            }
            else
            {
                geometry_density_0 = threshold_0;
            }
            float3  _S1373 = front_n_0;
            float _S1374 = geometry_density_0;
            scatter_2 = _S1370;
            geometry_density_0 = geometry_density_1;
            threshold_0 = _S1374;
            surface_12 = _S1366;
            front_n_0 = _S1360.smooth_n;
            throughput_5 = _S1373;
            turned_1 = _S1362;
        }
        else
        {
            scatter_2 = false;
            geometry_density_0 = 0.0f;
            surface_12 = _S1349;
            front_n_0 = _S1201;
            throughput_5 = throughput_2;
            is_inside_6 = is_inside_5;
        }
        bool _S1375;
        if(scatter_2)
        {
            _S1375 = (&prev_0)->rough;
        }
        else
        {
            _S1375 = false;
        }
        bool _S1376;
        if(_S1375)
        {
            _S1376 = ((&prev_0)->pdf * geometry_density_0 * threshold_0) <= 1.0f;
        }
        else
        {
            _S1376 = false;
        }
        FKSurface _S1377 = surface_12;
        FKSurface _S1378 = surface_12;
        float _S1379 = dot_0(surface_12.smooth_n, - (&ray_2)->unit_direction);
        float2  _S1380 = vertexEta(_S1377.material, _S1379);
        bool _S1381;
        if(scatter_2)
        {
            uint _S1382 = (fcptMaxBounces());
            bool _S1383 = b_5 >= _S1382;
            if(_S1383)
            {
                _S1381 = true;
            }
            else
            {
                bool _S1384 = neeDecision(_S1377.material, _S1379, _S1380.x, _S1380.y);
                _S1381 = _S1384;
            }
        }
        else
        {
            _S1381 = false;
        }
        bool _S1385;
        if(passes_0)
        {
            _S1385 = true;
        }
        else
        {
            _S1385 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1385)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1381;
        }
        bool _S1386 = (fcptHairUsed());
        bool _S1387;
        if(_S1386)
        {
            float3  _S1388 = surface_12.hair;
            _S1387 = (dot_0(_S1388, _S1388)) > 0.0f;
        }
        else
        {
            _S1387 = false;
        }
        bool _S1389;
        if(_S1387)
        {
            _S1389 = true;
        }
        else
        {
            BSDFMaterial _S1390 = _S1377.material;
            bool _S1391 = isTranslucent_0(&_S1390);
            _S1389 = _S1391;
        }
        bool _S1392;
        if(_S1389)
        {
            _S1392 = true;
        }
        else
        {
            bool _S1393 = (_S1377.material.transmission) > 0.0f;
            if(_S1393)
            {
                uint _S1394 = (fcptLayers((hit_4)));
                _S1392 = _S1394 == 1U;
            }
            else
            {
                _S1392 = false;
            }
        }
        float3  _S1395 = emitted_0(_S1377.material.emissive, (&ray_2)->unit_direction, front_n_0);
        float3  emission_0;
        if(_S1343)
        {
            float3  _S1396 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1396;
        }
        else
        {
            emission_0 = _S1395;
        }
        bool _S1397 = !replay_1;
        bool _S1398;
        if(_S1397)
        {
            _S1398 = true;
        }
        else
        {
            _S1398 = b_5 >= _S1217;
        }
        bool _S1399;
        if(_S1398)
        {
            float _S1400 = rgb_to_greyscale(emission_0);
            _S1399 = _S1400 > 0.0f;
        }
        else
        {
            _S1399 = false;
        }
        float3  emission_1;
        if(_S1399)
        {
            NEEVertex _S1401 = nee_vertex_0;
            FKHit _S1402 = hit_4;
            float _S1403 = emissionWeight_0(&_S1401, &_S1402, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1403);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1404;
        if(replay_1)
        {
            _S1404 = _S1206 == 1U;
        }
        else
        {
            _S1404 = false;
        }
        bool _S1405;
        if(_S1404)
        {
            _S1405 = b_5 > _S1205;
        }
        else
        {
            _S1405 = false;
        }
        bool _S1406;
        if(_S1405)
        {
            _S1406 = b_5 == _S1204;
        }
        else
        {
            _S1406 = false;
        }
        bool _S1407;
        if(_S1406)
        {
            bool _S1408 = _S1207 == 1U;
            if(_S1408)
            {
                _S1407 = true;
            }
            else
            {
                _S1407 = _S1207 == 2U;
            }
        }
        else
        {
            _S1407 = false;
        }
        if(_S1407)
        {
            bool _S1409 = _S1343 != (_S1207 == 2U);
            if(_S1409)
            {
                return _S1202;
            }
            return Shift_x24init_0(throughput_5 * emission_1 / make_float3 (r_8->jac), density_2 / r_8->jac);
        }
        uint _S1410 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1411 = _S1410 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1412 = insertBits_0(0U, b_5, 5U, 5U);
        uint _S1413 = insertBits_0(_S1412, 1U, 10U, 2U);
        uint _S1414 = insertBits_0(_S1413, (&prev_0)->lobe, 15U, 3U);
        bool _S1415 = (&prev_0)->inside;
        uint _S1416 = _slang_select(_S1415, 1U,0U);
        uint _S1417 = insertBits_0(_S1414, _S1416, 22U, 1U);
        (&here_0)->path = _S1417;
        float _S1418 = (&prev_0)->pdf * geometry_density_0;
        (&here_0)->jac = _S1418;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1419;
        if(replay_1)
        {
            _S1419 = _S1206 == 1U;
        }
        else
        {
            _S1419 = false;
        }
        bool _S1420;
        if(_S1419)
        {
            _S1420 = b_5 == _S1205;
        }
        else
        {
            _S1420 = false;
        }
        bool _S1421 = b_5 == _S1217;
        bool _S1422;
        if(_S1421)
        {
            bool _S1423 = !scatter_2;
            if(_S1423)
            {
                _S1422 = true;
            }
            else
            {
                bool _S1424 = _S1206 != 1U;
                if(_S1424)
                {
                    _S1422 = _S1206 != 3U;
                }
                else
                {
                    _S1422 = false;
                }
            }
        }
        else
        {
            _S1422 = false;
        }
        bool _S1425;
        if(_S1422)
        {
            _S1425 = _S1206 == 2U;
        }
        else
        {
            _S1425 = false;
        }
        bool _S1426;
        if(_S1425)
        {
            _S1426 = !_S1376;
        }
        else
        {
            _S1426 = false;
        }
        bool _S1427;
        if(_S1426)
        {
            _S1427 = _S1207 != 4U;
        }
        else
        {
            _S1427 = false;
        }
        bool _S1428 = _S1205 == _S1204;
        bool _S1429;
        if(_S1428)
        {
            _S1429 = _S1207 == 0U;
        }
        else
        {
            _S1429 = false;
        }
        bool _S1430;
        if(_S1429)
        {
            _S1430 = ((&hit_4)->instance_index) == (_S1218.instance_index);
        }
        else
        {
            _S1430 = false;
        }
        bool _S1431;
        if(_S1430)
        {
            _S1431 = ((&hit_4)->triangle_index) == (_S1218.triangle_index);
        }
        else
        {
            _S1431 = false;
        }
        bool _S1432;
        if(_S1431)
        {
            _S1432 = _S1376;
        }
        else
        {
            _S1432 = false;
        }
        bool _S1433 = _slang_select(_S1420, _S1432,_S1427);
        bool _S1434;
        if(nee_0)
        {
            _S1434 = _slang_select(replay_1, _S1433,scatter_2);
        }
        else
        {
            _S1434 = false;
        }
        TreeSample _S1435 = TreeSample_x24init_0(_S1201, _S1201, 0.0f, 0U);
        uint2  _S1436 = make_uint2 (0U);
        float2  _S1437 = make_float2 (0.0f);
        FKHit _S1438 = Hit_x24init_0(_S1437, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1439 = _S1438;
        ShadowContext _S1440 = ShadowContext_x24init_0(_S1201, _S1201, _S1436, _S1201, 0U, 0U, false, 0.0f, 0.0f, &_S1439, false);
        bool _S1441;
        if(nee_0)
        {
            _S1441 = _S1398;
        }
        else
        {
            _S1441 = false;
        }
        ShadowContext context_5;
        if(_S1441)
        {
            uint _S1442 = arrivalLobe_0(b_5, (&prev_0)->lobe);
            FKMedium _S1443 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1444 = surface_12;
            FKHit _S1445 = hit_4;
            FKMedium _S1446 = _S1443;
            ShadowContext _S1447 = shadowContext_0(&_S1444, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_5, _S1442, (&hit_4)->distance, width_3, &_S1445, _S1387, &_S1446);
            context_5 = _S1447;
        }
        else
        {
            context_5 = _S1440;
        }
        float3  throughput_6;
        float3  lit_0;
        if(_S1434)
        {
            float3  _S1448 = (&ray_2)->origin;
            if(_S1387)
            {
                throughput_6 = _S1201;
            }
            else
            {
                throughput_6 = _S1378.smooth_n;
            }
            FKSurface _S1449 = surface_12;
            uint _S1450 = stream(_S1229, b_5 + 64U);
            ShadowContext _S1451 = context_5;
            TreeSample _S1452 = sampleLightTree_0(_S1448, throughput_6, surface_12.geometry_n, surface_12.geometry_offset, _S1392, _S1450, &_S1451);
            bool _S1453 = any_1((_S1452.radiance) != _S1201);
            if(_S1453)
            {
                if(_S1387)
                {
                    uint _S1454 = (fcptMaxBounces());
                    bool _S1455 = b_5 < _S1454;
                    FKSurface _S1456 = surface_12;
                    TreeSample _S1457 = _S1452;
                    float3  _S1458 = hairLight_0(&_S1456, (&ray_2)->unit_direction, &_S1457, _S1455);
                    lit_0 = _S1458;
                }
                else
                {
                    float _S1459 = _S1380.x;
                    float _S1460 = _S1380.y;
                    uint _S1461 = (fcptMaxBounces());
                    bool _S1462 = b_5 < _S1461;
                    TreeSample _S1463 = _S1452;
                    BSDFMaterial _S1464 = _S1377.material;
                    float3  _S1465 = lightBSDF_0((&ray_2)->unit_direction, &_S1463, _S1378.smooth_n, _S1449.geometry_n, &_S1464, _S1459, _S1460, _S1462, surface_12.random_state);
                    lit_0 = _S1465;
                }
            }
            else
            {
                lit_0 = _S1201;
            }
            light_3 = _S1452;
        }
        else
        {
            light_3 = _S1435;
            lit_0 = _S1201;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1466;
        bool _S1467;
        float density_4;
        if(_S1420)
        {
            bool _S1468 = !_S1376;
            if(_S1468)
            {
                return _S1202;
            }
            float3  throughput_7 = throughput_5 * make_float3 (geometry_density_0);
            float density_5 = density_2 * geometry_density_0;
            if(_S1428)
            {
                viewed_1 = _S1207 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                return Shift_x24init_0(throughput_7 * emission_1 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1428)
            {
                refracted_4 = _S1207 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S1469 = !nee_0;
                if(_S1469)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1470 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1470 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1202;
                }
                return Shift_x24init_0(throughput_7 * lit_0 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1428)
            {
                wrong_side_0 = _S1207 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1471 = !nee_0;
                if(_S1471)
                {
                    return _S1202;
                }
                float _S1472 = environmentPdf_0(r_8->dir);
                float3  _S1473 = skyBSDF((&ray_2)->unit_direction, r_8->dir, surface_12, _S1380, is_inside_6, _S1472, surface_12.random_state);
                return Shift_x24init_0(throughput_7 * _S1473 * r_8->radiance / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            uint _S1474 = extractBits_0(_S1203, 21U, 1U);
            bool _S1475 = nee_0 != (_S1474 == 1U);
            if(_S1475)
            {
                return _S1202;
            }
            throughput_6 = throughput_7;
            density_4 = density_5;
        }
        else
        {
            if(replay_1)
            {
                viewed_1 = _S1421;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1476 = !scatter_2;
                if(_S1476)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1477 = _S1206 != 1U;
                    if(_S1477)
                    {
                        refracted_4 = _S1206 != 3U;
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
                bool _S1478 = _S1206 == 2U;
                if(_S1478)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1376;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1207 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1387)
                    {
                        return _S1202;
                    }
                    uint _S1479 = stream(_S1229, b_5 + 448U);
                    FKRay _S1480 = ray_2;
                    FKSurface _S1481 = surface_12;
                    ShadowContext _S1482 = context_5;
                    SkySample _S1483 = sampleSky_0(&_S1480, &_S1481, _S1380, is_inside_6, _S1479, surface_12.random_state, &_S1482);
                    return Shift_x24init_0(throughput_5 * _S1483.color, 1.0f);
                }
                if(_S1478)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1376;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1484 = rgb_to_greyscale(light_3.radiance);
                    bool _S1485 = !(_S1484 > 0.0f);
                    if(_S1485)
                    {
                        return _S1202;
                    }
                    return Shift_x24init_0(throughput_5 * lit_0, 1.0f);
                }
                if(_S1216)
                {
                    passes_0 = _S1207 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1343;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                if(_S1216)
                {
                    passes_0 = _S1207 == 1U;
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
                    passes_0 = !_S1376;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_5 * emission_1, 1.0f);
                }
                return _S1202;
            }
            else
            {
                if(_S1397)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1486 = b_5 > 0U;
                    if(_S1486)
                    {
                        Reservoir candidate_5 = chain_0;
                        if(_S1411)
                        {
                            float3  _S1487 = safeDivide(throughput_5 * emission_1, chain_throughput_0);
                            (&candidate_5)->radiance = _S1487;
                        }
                        else
                        {
                            if(_S1376)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1488 = throughput_5 * emission_1;
                        Reservoir _S1489 = withEnd(candidate_5, 1U, b_5, _S1488);
                        offer(sel_7, _S1489, _S1488 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1490 = throughput_5 * emission_1;
                        float3  _S1491 = sel_7->glow + _S1490;
                        sel_7->glow = _S1491;
                    }
                    if(nee_0)
                    {
                        float3  _S1492 = throughput_5 * lit_0;
                        Reservoir candidate_6 = chain_0;
                        if(_S1411)
                        {
                            float3  _S1493 = safeDivide(_S1492, chain_throughput_0);
                            (&candidate_6)->radiance = _S1493;
                        }
                        else
                        {
                            if(_S1376)
                            {
                                candidate_6 = here_0;
                                uint _S1494 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1494;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1495 = insertBits_0(0U, b_5 + 1U, 5U, 5U);
                                uint _S1496 = insertBits_0(_S1495, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1496;
                            }
                        }
                        Reservoir _S1497 = withEnd(candidate_6, 0U, b_5, _S1492);
                        offer(sel_7, _S1497, _S1492 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1387)
                        {
                            _S1466 = false;
                        }
                        else
                        {
                            bool _S1498 = environmentMapped_0();
                            _S1466 = _S1498;
                        }
                    }
                    else
                    {
                        _S1466 = false;
                    }
                    if(_S1466)
                    {
                        uint _S1499 = (fcptMaxBounces());
                        _S1467 = b_5 < _S1499;
                    }
                    else
                    {
                        _S1467 = false;
                    }
                    if(_S1467)
                    {
                        uint _S1500 = stream(_S1229, b_5 + 448U);
                        FKRay _S1501 = ray_2;
                        FKSurface _S1502 = surface_12;
                        ShadowContext _S1503 = context_5;
                        SkySample _S1504 = sampleSky_0(&_S1501, &_S1502, _S1380, is_inside_6, _S1500, surface_12.random_state, &_S1503);
                        float3  _S1505 = throughput_5 * _S1504.color;
                        Reservoir candidate_7 = chain_0;
                        if(_S1411)
                        {
                            float3  _S1506 = safeDivide(_S1505, chain_throughput_0);
                            (&candidate_7)->radiance = _S1506;
                        }
                        else
                        {
                            if(_S1376)
                            {
                                candidate_7 = here_0;
                                uint _S1507 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1507;
                                (&candidate_7)->dir = _S1504.dir;
                                (&candidate_7)->radiance = _S1504.radiance;
                            }
                            else
                            {
                                uint _S1508 = insertBits_0(0U, b_5 + 1U, 5U, 5U);
                                uint _S1509 = insertBits_0(_S1508, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1509;
                            }
                        }
                        Reservoir _S1510 = withEnd(candidate_7, 4U, b_5, _S1505);
                        offer(sel_7, _S1510, _S1505 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                }
            }
            throughput_6 = throughput_5;
            density_4 = density_2;
        }
        bool _S1511;
        bool _S1512;
        bool _S1513;
        bool straight_0;
        bool _S1514;
        bool _S1515;
        bool _S1516;
        bool _S1517;
        bool _S1518;
        bool _S1519;
        bool _S1520;
        bool _S1521;
        bool _S1522;
        bool _S1523;
        bool _S1524;
        bool _S1525;
        bool _S1526;
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
                viewed_1 = _S1421;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1527 = extractBits_0(_S1203, 15U, 3U);
            uint _S1528 = extractBits_0(_S1203, 18U, 3U);
            uint _S1529 = _slang_select(_S1420, _S1528,_S1527);
            float3  _S1530 = r_8->dir;
            bool refracted_5 = _S1529 == 1U;
            SampleBSDF _S1531 = SampleBSDF_x24init_0(_S1201, _S1201, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1531;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1532 = extractBits_0(_S1203, 22U, 1U);
                bool _S1533 = is_inside_6 != (_S1532 == 1U);
                if(_S1533)
                {
                    return _S1202;
                }
                bool _S1534 = _S1206 == 1U;
                if(_S1534)
                {
                    float3  _S1535 = (fcptHitPosition((_S1218)));
                    throughput_8 = _S1535;
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
                    BSDFMaterial _S1536 = _S1377.material;
                    bool _S1537 = isTranslucent_0(&_S1536);
                    if(_S1537)
                    {
                        refracted_4 = _S1529 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1538 = throughput_8 - (&ray_2)->origin;
                        float3  _S1539 = _slang_select(_S1534, _S1538,_S1530);
                        wrong_side_0 = (dot_0(_S1378.smooth_n, _S1539) * _S1379) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1534)
                {
                    float3  _S1540 = (&ray_2)->origin;
                    FKSurface _S1541 = surface_12;
                    float3  _S1542 = - _S1378.smooth_n;
                    bool _S1543 = is_inside_6 != refracted_4;
                    float3  _S1544 = _slang_select(_S1543, _S1542,_S1378.smooth_n);
                    float3  _S1545 = throughput_8 - (_S1540 + make_float3 (_S1541.geometry_offset) * _S1544);
                    float3  _S1546 = ((((_S1545)) * make_float3(rnorm3df(((_S1545)).x, ((_S1545)).y, ((_S1545)).z))));
                    reconnection_1 = _S1546;
                }
                else
                {
                    reconnection_1 = _S1530;
                }
                if(_S1387)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1547 = wrongSide_0(is_inside_6, refracted_4, reconnection_1, surface_12.geometry_n);
                    wrong_side_0 = _S1547;
                }
                if(wrong_side_0)
                {
                    return _S1202;
                }
                float3  _S1548 = throughput_8;
                throughput_8 = reconnection_1;
                b_8 = _S1529;
                wrong_side_0 = false;
                reconnection_1 = _S1548;
            }
            else
            {
                bool _S1549 = !_S1420;
                if(_S1549)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1550;
                    if(_S1387)
                    {
                        SampleBSDF _S1551 = (fcptSampleHair((surface_12.hair), (_S1377.material.albedo), (_S1377.material.specular_tint), ((&ray_2)->unit_direction), (surface_12.random_state)));
                        _S1550 = _S1551;
                    }
                    else
                    {
                        SampleBSDF _S1552 = sampleBSDF((&ray_2)->unit_direction, _S1378.smooth_n, _S1377.material, _S1380.x, _S1380.y, surface_12.random_state, _S1437);
                        _S1550 = _S1552;
                    }
                    bsdf_sampled_0 = _S1550;
                    if(_S1387)
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
                            return _S1202;
                        }
                        break;
                    }
                    if(_S1387)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1553 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_12.geometry_n);
                        wrong_side_0 = _S1553;
                    }
                    if(wrong_side_0)
                    {
                        _S1466 = (_S1377.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1466 = false;
                    }
                    if(_S1466)
                    {
                        SampleBSDF _S1554 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S1377.material, _S1380.x, _S1380.y, (&bsdf_sampled_0)->random_state, _S1437);
                        (&bsdf_sampled_0)->unit_direction = _S1554.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1554.refracted;
                        (&bsdf_sampled_0)->throughput = _S1554.throughput;
                        (&bsdf_sampled_0)->lobe = _S1554.lobe;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1555 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n)) * surface_12.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1555;
                        }
                    }
                    uint _S1556 = (&bsdf_sampled_0)->lobe;
                    float3  _S1557 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1558 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1559 = (&bsdf_sampled_0)->pdf;
                    float _S1560 = _slang_select(wrong_side_0, 0.0f,_S1559);
                    (&lobe_5)->pdf = _S1560;
                    throughput_8 = _S1557;
                    b_8 = _S1556;
                    refracted_4 = _S1558;
                }
                else
                {
                    throughput_8 = _S1530;
                    b_8 = _S1529;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1466 = true;
            }
            else
            {
                _S1466 = _S1420;
            }
            float3  chain_throughput_1;
            if(_S1466)
            {
                if(_S1387)
                {
                    SampleBSDF _S1561 = (fcptConnectHair((surface_12.hair), (_S1377.material.albedo), (_S1377.material.specular_tint), ((&ray_2)->unit_direction), (throughput_8)));
                    lobe_5 = _S1561;
                }
                else
                {
                    float3  _S1562 = (&ray_2)->unit_direction;
                    float _S1563 = sign_0(_S1379);
                    float3  _S1564 = _S1378.smooth_n * make_float3 (_S1563);
                    float _S1565 = dot_0(_S1564, throughput_8);
                    float _S1566 = _S1377.material.roughness;
                    float _S1567 = _S1566 * _S1566;
                    AnisotropicFrame _S1568 = anisotropicFrame(_S1377.material, _S1564);
                    float3  _S1569 = negate_0(_S1562);
                    SheenProfile _S1570 = sheenProfile(_S1569, _S1564, _S1377.material);
                    float3  _S1571 = reflectedHalf(_S1562, throughput_8);
                    bool _S1572 = b_8 == 1U;
                    if(_S1572)
                    {
                        float3  _S1573 = refractedHalf(_S1562, throughput_8, _S1378.smooth_n, _S1380.x, _S1380.y);
                        throughput_9 = _S1573;
                    }
                    else
                    {
                        throughput_9 = _S1571;
                    }
                    bool _S1574 = b_8 == 0U;
                    if(_S1574)
                    {
                        _S1467 = true;
                    }
                    else
                    {
                        _S1467 = b_8 == 6U;
                    }
                    if(_S1467)
                    {
                        float3  _S1575 = sampledHalf(_S1562, _S1378.smooth_n, _S1377.material, surface_12.random_state, _S1568);
                        throughput_10 = _S1575;
                    }
                    else
                    {
                        throughput_10 = throughput_9;
                    }
                    float3  _S1576 = negate_0(_S1562);
                    float _S1577 = _S1380.x;
                    float _S1578 = _S1380.y;
                    BSDFLobes _S1579 = bsdfLobes(_S1562, _S1576, _S1564, throughput_10, _S1377.material, _S1577, _S1578, _S1568, _S1570);
                    BSDFLobes lobe_terms_1 = _S1579;
                    float _S1580 = translucentShare(_S1377.material);
                    (&lobe_terms_1)->translucent_share = _S1580;
                    switch(b_8)
                    {
                    case 0U:
                        {
                            float _S1581 = diffusePDF(_S1565, 0.0f, (F32_abs((_S1379))), _S1567, lobe_terms_1, _S1577, _S1578);
                            float3  _S1582 = diffuseBSDF(throughput_8, _S1564, _S1567, _S1377.material, lobe_terms_1);
                            density_6 = _S1581;
                            chain_throughput_1 = _S1582;
                            break;
                        }
                    case 1U:
                        {
                            float _S1583 = refractPDF(_S1565, dot_0(throughput_8, throughput_10), (F32_abs((_S1379))), _S1567, lobe_terms_1, _S1577, _S1578);
                            float3  _S1584 = refractBSDF(throughput_8, _S1564, _S1567, _S1377.material, lobe_terms_1);
                            density_6 = _S1583;
                            chain_throughput_1 = _S1584;
                            break;
                        }
                    case 4U:
                        {
                            float _S1585 = sheenVelvetPDF(_S1565, 0.0f, (F32_abs((_S1379))), _S1567, lobe_terms_1, _S1577, _S1578);
                            float3  _S1586 = sheenVelvetBSDF(throughput_8, _S1564, _S1567, _S1377.material, lobe_terms_1);
                            density_6 = _S1585;
                            chain_throughput_1 = _S1586;
                            break;
                        }
                    case 6U:
                        {
                            float _S1587 = toonPDF(_S1565, dot_0(throughput_8, (&lobe_terms_1)->toon_axis), (F32_abs((_S1379))), _S1567, lobe_terms_1, _S1577, _S1578);
                            float3  _S1588 = toonBSDF(throughput_8, _S1564, _S1567, _S1377.material, lobe_terms_1);
                            density_6 = _S1587;
                            chain_throughput_1 = _S1588;
                            break;
                        }
                    default:
                        {
                            float _S1589 = reflectPDF(_S1565, 0.0f, (F32_abs((_S1379))), _S1567, lobe_terms_1, _S1577, _S1578);
                            float3  _S1590 = reflectBSDF(throughput_8, _S1564, _S1567, _S1377.material, lobe_terms_1);
                            density_6 = _S1589;
                            chain_throughput_1 = _S1590;
                            break;
                        }
                    }
                    bool _S1591 = density_6 > 0.0f;
                    if(_S1591)
                    {
                        SampleBSDF _S1592 = SampleBSDF_x24init_0(throughput_8, chain_throughput_1, surface_12.random_state, _S1572, b_8, density_6);
                        lobe_5 = _S1592;
                    }
                }
            }
            bool _S1593 = b_8 == 0U;
            if(_S1593)
            {
                _S1467 = true;
            }
            else
            {
                _S1467 = b_8 == 4U;
            }
            if(_S1467)
            {
                _S1511 = true;
            }
            else
            {
                _S1511 = b_8 == 6U;
            }
            if(_S1387)
            {
                _S1512 = false;
            }
            else
            {
                bool _S1594 = !_S1511;
                if(_S1594)
                {
                    bool _S1595 = (_S1377.material.roughness) == 0.0f;
                    if(_S1595)
                    {
                        _S1512 = true;
                    }
                    else
                    {
                        bool _S1596 = b_8 == 1U;
                        if(_S1596)
                        {
                            _S1512 = (_S1380.x) == (_S1380.y);
                        }
                        else
                        {
                            _S1512 = false;
                        }
                    }
                }
                else
                {
                    _S1512 = false;
                }
            }
            bool _S1597 = !_S1387;
            if(_S1597)
            {
                _S1513 = b_8 == 1U;
            }
            else
            {
                _S1513 = false;
            }
            if(_S1513)
            {
                straight_0 = (_S1377.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1514 = _S1597;
            }
            else
            {
                _S1514 = false;
            }
            if(_S1514)
            {
                _S1515 = b_8 == 1U;
            }
            else
            {
                _S1515 = false;
            }
            if(_S1515)
            {
                _S1516 = (_S1380.x) == (_S1380.y);
            }
            else
            {
                _S1516 = false;
            }
            BSDFMaterial _S1598 = _S1377.material;
            bool _S1599 = isTranslucent_0(&_S1598);
            if(_S1599)
            {
                _S1517 = _S1593;
            }
            else
            {
                _S1517 = false;
            }
            if(_S1517)
            {
                _S1518 = (dot_0(throughput_8, surface_12.geometry_n)) < 0.0f;
            }
            else
            {
                _S1518 = false;
            }
            if(nee_0)
            {
                _S1519 = !_S1512;
            }
            else
            {
                _S1519 = false;
            }
            if(_S1519)
            {
                _S1520 = !wrong_side_0;
            }
            else
            {
                _S1520 = false;
            }
            if(_S1520)
            {
                float _S1600 = (&lobe_5)->pdf;
                float3  _S1601 = (&ray_2)->origin;
                float3  _S1602 = _slang_select(_S1392, _S1201,_S1378.smooth_n);
                float3  _S1603 = (&ray_2)->origin;
                FKSurface _S1604 = surface_12;
                float3  _S1605 = - _S1378.smooth_n;
                float3  _S1606 = _slang_select(_S1518, _S1605,_S1378.smooth_n);
                NEEVertex _S1607 = NEEVertex_x24init_0(false, _S1600, _S1601, _S1602, _S1603 + make_float3 (_S1604.geometry_offset) * _S1606);
                nee_vertex_0 = _S1607;
            }
            else
            {
                if(_S1387)
                {
                    _S1521 = true;
                }
                else
                {
                    bool _S1608 = b_8 != 1U;
                    if(_S1608)
                    {
                        _S1521 = true;
                    }
                    else
                    {
                        _S1521 = (_S1380.x) != (_S1380.y);
                    }
                }
                if(_S1521)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1609 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1609)
            {
                if(_S1511)
                {
                    _S1521 = true;
                }
                else
                {
                    _S1521 = ((&lobe_5)->pdf * (&prev_0)->cos / ((&hit_4)->distance * (&hit_4)->distance) * threshold_0) <= 1.0f;
                }
            }
            else
            {
                _S1521 = false;
            }
            bool _S1610 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1610)
            {
                if(_S1511)
                {
                    _S1522 = true;
                }
                else
                {
                    _S1522 = (_S1377.material.roughness) >= 0.20000000298023224f;
                }
            }
            else
            {
                _S1522 = false;
            }
            if(_S1420)
            {
                bool _S1611 = !_S1521;
                if(_S1611)
                {
                    return _S1202;
                }
                bool _S1612 = _S1207 != 1U;
                if(_S1612)
                {
                    _S1523 = _S1207 != 2U;
                }
                else
                {
                    _S1523 = false;
                }
                if(_S1523)
                {
                    float _S1613 = (&lobe_5)->pdf;
                    float _S1614 = _slang_select(nee_0, _S1613,0.0f);
                    float _S1615 = escapeWeight_0(_S1614, _S1530);
                    if(_S1428)
                    {
                        passes_0 = _S1213;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1616 = _slang_select(passes_0, _S1615,1.0f);
                    return Shift_x24init_0(throughput_6 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_8->radiance * make_float3 (_S1616) / make_float3 (r_8->jac), density_4 * (&lobe_5)->pdf / r_8->jac);
                }
                float3  _S1617 = throughput_6 * make_float3 ((&lobe_5)->pdf);
                float _S1618 = density_4 * (&lobe_5)->pdf;
                throughput_9 = _S1617;
                density_6 = _S1618;
            }
            else
            {
                throughput_9 = throughput_6;
                density_6 = density_4;
            }
            uint _S1619 = (fcptLayers((hit_4)));
            bool _S1620 = _S1619 > 1U;
            if(_S1620)
            {
                _S1523 = (b_8 == 1U) != passes_0;
            }
            else
            {
                _S1523 = false;
            }
            if(viewed_1)
            {
                _S1524 = _S1523;
            }
            else
            {
                _S1524 = false;
            }
            if(_S1524)
            {
                return _S1202;
            }
            if(replay_1)
            {
                _S1525 = b_5 <= _S1217;
            }
            else
            {
                _S1525 = false;
            }
            if(_S1525)
            {
                _S1526 = _S1376;
            }
            else
            {
                _S1526 = false;
            }
            bool _S1621;
            if(_S1526)
            {
                _S1621 = _S1521;
            }
            else
            {
                _S1621 = false;
            }
            bool _S1622;
            if(_S1621)
            {
                _S1622 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1622 = !_S1522;
                }
                else
                {
                    _S1622 = false;
                }
            }
            if(_S1622)
            {
                return _S1202;
            }
            if(viewed_1)
            {
                float3  _S1623 = throughput_9 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1624 = (&lobe_5)->pdf;
                throughput_10 = _S1623;
                sky_pdf_2 = _S1624;
            }
            else
            {
                float3  _S1625 = throughput_9 * max_0((&lobe_5)->throughput, _S1201);
                throughput_10 = _S1625;
                sky_pdf_2 = density_6;
            }
            bool _S1626;
            if(_S1397)
            {
                _S1626 = !_S1411;
            }
            else
            {
                _S1626 = false;
            }
            bool _S1627;
            if(_S1626)
            {
                _S1627 = _S1376;
            }
            else
            {
                _S1627 = false;
            }
            bool _S1628;
            if(_S1627)
            {
                _S1628 = _S1521;
            }
            else
            {
                _S1628 = false;
            }
            if(_S1628)
            {
                chain_0 = here_0;
                uint _S1629 = insertBits_0((&chain_0)->path, b_8, 18U, 3U);
                uint _S1630 = _slang_select(nee_0, 1U,0U);
                uint _S1631 = insertBits_0(_S1629, _S1630, 21U, 1U);
                (&chain_0)->path = _S1631;
                float _S1632 = (&chain_0)->jac * (&lobe_5)->pdf;
                (&chain_0)->jac = _S1632;
                (&chain_0)->dir = throughput_8;
                chain_throughput_1 = throughput_10;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1633 = surface_12;
            Vertex _S1634 = Vertex_x24init_0(_S1522, b_8, (&lobe_5)->pdf, (F32_abs((dot_0(surface_12.geometry_n, throughput_8)))), is_inside_6);
            prev_0 = _S1634;
            float _S1635 = (&lobe_5)->pdf;
            bool _S1636 = b_8 == 1U;
            bool _S1637;
            if(_S1636)
            {
                _S1637 = (_S1380.x) == (_S1380.y);
            }
            else
            {
                _S1637 = false;
            }
            float sky_pdf_3 = _slang_select(_S1637, sky_pdf_0,_S1635);
            float _S1638 = _slang_select(_S1387, 0.0f,sky_pdf_3);
            float _S1639 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * (&lobe_5)->pdf))))), (3.14159274101257324f)));
            bool _S1640 = !_S1512;
            float _S1641 = _slang_select(_S1640, _S1639,0.0f);
            float _S1642 = spread_1 + _S1641;
            bool _S1643;
            if(refracted_4)
            {
                _S1643 = !_S1518;
            }
            else
            {
                _S1643 = false;
            }
            bool is_inside_7;
            if(_S1643)
            {
                bool _S1644 = !is_inside_6;
                is_inside_7 = _S1644;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            FKSurface _S1645 = surface_12;
            bool _S1646 = boundsVolume_0(&_S1645);
            bool _S1647;
            if(_S1646)
            {
                _S1647 = !_S1523;
            }
            else
            {
                _S1647 = false;
            }
            if(_S1647)
            {
                FKSurface faced_2 = surface_12;
                float3  _S1648 = - _S1633.geometry_n;
                float3  _S1649 = _slang_select(turned_1, _S1648,_S1633.geometry_n);
                (&faced_2)->geometry_n = _S1649;
                FKMedium _S1650 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1651 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1652 = faced_2;
                FKMedium _S1653 = _S1650;
                FKMedium _S1654 = _S1651;
                MediumSides _S1655 = mediumSides_0(&_S1652, &_S1653, filling_2, (&ray_2)->unit_direction, &_S1654);
                bool _S1656 = ((dot_0(throughput_8, _S1633.geometry_n)) > 0.0f) == ((dot_0(_S1633.geometry_n, (&faced_2)->geometry_n)) > 0.0f);
                float3  _S1657 = _slang_select(_S1656, _S1655.front.scatter,_S1655.behind.scatter);
                scatter_in_0 = _S1657;
                float3  _S1658 = _slang_select(_S1656, _S1655.front.extinction,_S1655.behind.extinction);
                extinction_in_0 = _S1658;
                float _S1659 = _slang_select(_S1656, _S1655.front.g,_S1655.behind.g);
                g_in_0 = _S1659;
                uint _S1660 = _S1655.fillings.x;
                uint _S1661 = _S1655.fillings.y;
                uint _S1662 = _slang_select(_S1656, _S1661,_S1660);
                bool _S1663 = (fcptVaryingUsed());
                uint _S1664 = _slang_select(_S1663, _S1662,4294967295U);
                filling_2 = _S1664;
            }
            (&ray_2)->unit_direction = throughput_8;
            bool _S1665 = !_S1523;
            if(_S1665)
            {
                FKSurface _S1666 = surface_12;
                float _S1667 = _slang_select(straight_0, 0.0f,_S1666.geometry_offset);
                float3  _S1668 = - _S1378.smooth_n;
                bool _S1669 = is_inside_7 != _S1518;
                float3  _S1670 = _slang_select(_S1669, _S1668,_S1378.smooth_n);
                float3  _S1671 = (&ray_2)->origin + make_float3 (_S1667) * _S1670;
                (&ray_2)->origin = _S1671;
            }
            throughput_9 = throughput_10;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1523;
            viewed_1 = _S1516;
            sky_pdf_2 = _S1638;
            spread_4 = _S1642;
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
        if(_S1397)
        {
            if(_S1343)
            {
                float3  _S1672 = throughput_9 * emission_1;
                Reservoir candidate_8 = chain_0;
                uint _S1673 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1674 = _S1673 == 1U;
                if(_S1674)
                {
                    float3  _S1675 = safeDivide(_S1672, chain_throughput_0);
                    (&candidate_8)->radiance = _S1675;
                }
                Reservoir _S1676 = withEnd(candidate_8, 2U, b_5, _S1672);
                offer(sel_7, _S1676, _S1672 * make_float3 (scale_3) / make_float3 (density_6));
            }
            if(_S1343)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1677 = survivalProbability(throughput_9, density_6);
                density_7 = _S1677;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1678 = stream(_S1229, b_5 + 128U);
            Random _S1679 = pcg(_S1678);
            bool _S1680 = density_7 < (_S1679.value);
            if(_S1680)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1681 = (fcptMaxBounces());
                wrong_side_0 = b_5 >= _S1681;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1682 = density_6 * density_7;
            density_7 = _S1682;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1683 = layer_0 ^ 1U;
        uint _S1684 = _slang_select(passes_0, _S1683,0U);
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
            uint _S1685 = b_8 + 1U;
            b_5 = _S1685;
            layer_0 = _S1684;
            continue;
        }
        FKRay _S1686 = ray_2;
        float _S1687 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_1)
        {
            refracted_4 = _S1421;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S1206 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1688 = _slang_select(wrong_side_0, _S1687,4.294967296e+09f);
        bool _S1689 = !_S1387;
        if(straight_0)
        {
            _S1466 = true;
        }
        else
        {
            _S1466 = _S1387;
        }
        FKHit _S1690;
        if(_S1466)
        {
            _S1690 = hit_4;
        }
        else
        {
            _S1690 = _S1438;
        }
        FKHit _S1691 = (fcptTraverseInstanceBVH((_S1686), (_S1350), (_S1688), (_S1689), (_S1690), (viewed_1)));
        hit_4 = _S1691;
        if(replay_1)
        {
            _S1467 = _S1421;
        }
        else
        {
            _S1467 = false;
        }
        if(_S1467)
        {
            _S1511 = _S1206 == 1U;
        }
        else
        {
            _S1511 = false;
        }
        if(_S1511)
        {
            _S1512 = ((&hit_4)->instance_index) == (_S1218.instance_index);
        }
        else
        {
            _S1512 = false;
        }
        if(_S1512)
        {
            _S1513 = ((&hit_4)->triangle_index) == (_S1218.triangle_index);
        }
        else
        {
            _S1513 = false;
        }
        if(_S1513)
        {
            (&hit_4)->uv = _S1218.uv;
            float _S1692 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S1692;
        }
        if(replay_1)
        {
            _S1514 = _S1421;
        }
        else
        {
            _S1514 = false;
        }
        if(_S1514)
        {
            _S1515 = _S1206 == 3U;
        }
        else
        {
            _S1515 = false;
        }
        if(_S1515)
        {
            _S1516 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1516 = false;
        }
        if(_S1516)
        {
            return _S1202;
        }
        Reservoir _S1693 = chain_0;
        uint _S1694 = filling_2;
        for(;;)
        {
            bool _S1695 = (fcptVaryingUsed());
            if(_S1695)
            {
                _S1517 = _S1694 != 4294967295U;
            }
            else
            {
                _S1517 = false;
            }
            float _S1696;
            if(_S1517)
            {
                float _S1697 = (fcptMajorant((_S1694)));
                _S1696 = _S1697;
            }
            else
            {
                _S1696 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_1)
            {
                _S1518 = _S1421;
            }
            else
            {
                _S1518 = false;
            }
            if(_S1518)
            {
                _S1519 = _S1206 == 1U;
            }
            else
            {
                _S1519 = false;
            }
            if(_S1519)
            {
                _S1520 = _S1696 > 0.0f;
            }
            else
            {
                _S1520 = false;
            }
            if(_S1520)
            {
                ended_0 = _S1202;
                sky_pdf_1 = sky_pdf_2;
                spread_2 = spread_4;
                width_4 = width_3;
                density_3 = density_7;
                throughput_10 = throughput_9;
                b_8 = b_5;
                _S1521 = true;
                break;
            }
            bool _S1698 = (&prev_0)->rough;
            if(_S1698)
            {
                _S1521 = !(_S1696 > 0.0f);
            }
            else
            {
                _S1521 = false;
            }
            (&prev_0)->rough = _S1521;
            uint _S1699 = b_5 + 320U;
            bool _S1700 = b_5 == 4294967295U;
            uint _S1701 = _slang_select(_S1700, 384U,_S1699);
            uint _S1702 = stream(_S1229, _S1701);
            uint tracking_1 = _S1702;
            weight_1 = throughput_3;
            glowed_0 = _S1201;
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
                    _S1200 = int(2);
                    break;
                }
                uint _S1703 = b_8 + 320U;
                bool _S1704 = b_8 == 4294967295U;
                uint _S1705 = _slang_select(_S1704, 384U,_S1703);
                uint _S1706 = stream(_S1229, _S1705);
                Random _S1707 = pcg(_S1706);
                float _S1708 = - (F32_log((1.0f - _S1707.value))) / _S1696;
                if(_S1517)
                {
                    float3  _S1709 = (&ray_2)->origin;
                    float3  _S1710 = (&ray_2)->unit_direction;
                    float _S1711 = (&hit_4)->distance;
                    uint _S1712 = _slang_select(_S1704, 0U,b_8);
                    uint _S1713 = (&prev_0)->lobe;
                    uint _S1714 = _slang_select(_S1704, 3U,_S1713);
                    float _S1715 = (fcptTrackMedium((_S1694), (_S1709), (_S1710), (_S1711), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1712), (_S1714), (_S1704)));
                    spread_3 = _S1715;
                }
                else
                {
                    spread_3 = _S1708;
                }
                bool _S1716 = !(spread_3 < ((&hit_4)->distance));
                if(_S1716)
                {
                    _S1200 = int(2);
                    break;
                }
                if(_S1517)
                {
                    _S1522 = _S1397;
                }
                else
                {
                    _S1522 = false;
                }
                if(_S1522)
                {
                    float3  _S1717 = throughput_10 * glowed_0 / make_float3 (density_3);
                    float3  _S1718 = sel_7->glow + _S1717;
                    sel_7->glow = _S1718;
                }
                else
                {
                }
                glowed_0 = _S1201;
                uint b_9 = b_8 + 1U;
                float3  _S1719 = (&ray_2)->origin + make_float3 (spread_3) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1719;
                float3  _S1720 = flightWeight_0(scatter_in_0, extinction_in_0, _S1696, spread_3, true);
                float3  _S1721 = weight_1;
                float3  _S1722 = _slang_select(_S1517, _S1721,_S1720);
                float3  throughput_11 = throughput_10 * _S1722;
                uint _S1723 = stream(_S1229, b_9 + 320U);
                tracking_1 = _S1723;
                weight_1 = throughput_3;
                float width_7 = width_4 + spread_2 * spread_3;
                float _S1724 = spread_2 + 3.14159274101257324f;
                if(_S1397)
                {
                    _S1523 = true;
                }
                else
                {
                    bool _S1725 = b_9 == _S1217;
                    if(_S1725)
                    {
                        _S1523 = !_S1517;
                    }
                    else
                    {
                        _S1523 = false;
                    }
                }
                TreeSample light_4;
                if(_S1523)
                {
                    float3  _S1726 = (&ray_2)->origin;
                    float3  _S1727 = (&ray_2)->unit_direction;
                    float3  _S1728 = (&ray_2)->unit_direction;
                    uint _S1729 = stream(_S1229, b_9 + 64U);
                    float3  _S1730 = extinction_in_0;
                    float3  _S1731 = extinction_in_0;
                    uint2  _S1732 = make_uint2 (_S1694);
                    float3  _S1733 = (&ray_2)->unit_direction;
                    uint _S1734 = arrivalLobe_0(b_9, (&prev_0)->lobe);
                    FKHit _S1735 = _S1438;
                    ShadowContext _S1736 = ShadowContext_x24init_0(_S1730, _S1731, _S1732, _S1733, b_9, _S1734, false, spread_3, width_7, &_S1735, false);
                    ShadowContext _S1737 = _S1736;
                    TreeSample _S1738 = sampleLightTree_0(_S1726, _S1727, _S1728, 0.0f, true, _S1729, &_S1737);
                    light_4 = _S1738;
                }
                else
                {
                    light_4 = _S1435;
                }
                float _S1739 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1740 = (fcptMaxBounces());
                bool _S1741 = b_9 < _S1740;
                if(_S1741)
                {
                    _S1524 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1524 = false;
                }
                float _S1742 = _slang_select(_S1524, _S1739,0.0f);
                float3  _S1743 = throughput_11 * light_4.radiance;
                float _S1744 = powerHeuristic(light_4.density, _S1742);
                float3  _S1745 = _S1743 * make_float3 (_S1739 * _S1744);
                float3  _S1746 = _slang_select(_S1523, _S1745,_S1201);
                if(replay_1)
                {
                    _S1525 = b_9 == _S1217;
                }
                else
                {
                    _S1525 = false;
                }
                if(_S1525)
                {
                    bool _S1747 = _S1206 == 2U;
                    if(_S1747)
                    {
                        float _S1748 = rgb_to_greyscale(_S1746);
                        _S1526 = _S1748 > 0.0f;
                    }
                    else
                    {
                        _S1526 = false;
                    }
                    if(_S1526)
                    {
                        Shift _S1749 = Shift_x24init_0(_S1746, 1.0f);
                        _S1200 = int(1);
                        ended_0 = _S1749;
                        spread_3 = _S1724;
                        width_5 = width_7;
                        throughput_8 = throughput_11;
                        b_6 = b_9;
                        break;
                    }
                    _S1200 = int(1);
                    ended_0 = _S1202;
                    spread_3 = _S1724;
                    width_5 = width_7;
                    throughput_8 = throughput_11;
                    b_6 = b_9;
                    break;
                }
                if(_S1397)
                {
                    Reservoir candidate_9 = _S1693;
                    uint _S1750 = extractBits_0(_S1693.path, 10U, 2U);
                    bool _S1751 = _S1750 == 1U;
                    if(_S1751)
                    {
                        float3  _S1752 = safeDivide(_S1746, chain_throughput_0);
                        (&candidate_9)->radiance = _S1752;
                    }
                    else
                    {
                        uint _S1753 = insertBits_0(0U, b_9 + 1U, 5U, 5U);
                        uint _S1754 = insertBits_0(_S1753, 2U, 10U, 2U);
                        (&candidate_9)->path = _S1754;
                    }
                    Reservoir _S1755 = withEnd(candidate_9, 0U, b_9, _S1746);
                    offer(sel_7, _S1755, _S1746 * make_float3 (scale_3) / make_float3 (density_3));
                    float _S1756 = survivalProbability(throughput_11, density_3);
                    uint _S1757 = stream(_S1229, b_9 + 128U);
                    Random _S1758 = pcg(_S1757);
                    bool _S1759 = _S1756 < (_S1758.value);
                    if(_S1759)
                    {
                        _S1526 = true;
                    }
                    else
                    {
                        uint _S1760 = (fcptMaxBounces());
                        _S1526 = b_9 >= _S1760;
                    }
                    if(_S1526)
                    {
                        _S1200 = int(1);
                        ended_0 = _S1202;
                        spread_3 = _S1724;
                        width_5 = width_7;
                        throughput_8 = throughput_11;
                        b_6 = b_9;
                        break;
                    }
                    float _S1761 = density_3 * _S1756;
                    density_3 = _S1761;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1762 = stream(_S1229, b_9);
                float3  _S1763 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1762, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1763;
                NEEVertex _S1764 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1201, (&ray_2)->origin);
                nee_vertex_0 = _S1764;
                Vertex _S1765 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_5);
                prev_0 = _S1765;
                float _S1766 = (&prev_0)->pdf;
                FKRay _S1767 = ray_2;
                FKHit _S1768 = (fcptTraverseInstanceBVH((_S1767), (true), (4.294967296e+09f), (false), (_S1438), (false)));
                hit_4 = _S1768;
                b_8 = b_9;
                throughput_10 = throughput_11;
                spread_2 = _S1724;
                width_4 = width_7;
                sky_pdf_1 = _S1766;
            }
            if(_S1200 != int(2))
            {
                spread_2 = spread_3;
                width_4 = width_5;
                throughput_10 = throughput_8;
                b_8 = b_6;
                _S1521 = true;
                break;
            }
            ended_0 = _S1202;
            _S1521 = false;
            break;
        }
        if(_S1521)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1522 = b_8 == b_5;
        }
        else
        {
            _S1522 = false;
        }
        bool _S1769 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S1769)
        {
            bool _S1770 = !(&nee_vertex_0)->none;
            float _S1771 = _slang_select(_S1770, sky_pdf_1,0.0f);
            float _S1772 = escapeWeight_0(_S1771, (&ray_2)->unit_direction);
            float3  _S1773 = environment_0((&ray_2)->unit_direction, b_8, (&prev_0)->lobe);
            float3  _S1774 = throughput_10 * _S1773;
            if(replay_1)
            {
                bool _S1775 = b_8 == _S1217;
                if(_S1775)
                {
                    passes_0 = _S1206 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1774 * make_float3 (_S1772) / make_float3 (r_8->jac), density_3 / r_8->jac);
                }
                if(_S1216)
                {
                    passes_0 = _S1213;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_8 == _S1204;
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
                    return Shift_x24init_0(_S1774 * make_float3 (_S1772), 1.0f);
                }
                return _S1202;
            }
            Reservoir candidate_10 = chain_0;
            uint _S1776 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1777 = _S1776 == 1U;
            if(_S1777)
            {
                uint _S1778 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1779 = _S1778 == b_8;
                float _S1780 = _slang_select(_S1779, 1.0f,_S1772);
                float3  _S1781 = safeDivide(_S1774 * make_float3 (_S1780), chain_throughput_0);
                (&candidate_10)->radiance = _S1781;
            }
            else
            {
                bool _S1782 = (&prev_0)->rough;
                if(_S1782)
                {
                    uint _S1783 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                    uint _S1784 = insertBits_0(_S1783, 3U, 10U, 2U);
                    uint _S1785 = insertBits_0(_S1784, (&prev_0)->lobe, 15U, 3U);
                    bool _S1786 = (&prev_0)->inside;
                    uint _S1787 = _slang_select(_S1786, 1U,0U);
                    uint _S1788 = insertBits_0(_S1785, _S1787, 22U, 1U);
                    (&candidate_10)->path = _S1788;
                    (&candidate_10)->jac = (&prev_0)->pdf;
                    (&candidate_10)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1789 = _S1774 * make_float3 (_S1772);
            Reservoir _S1790 = withEnd(candidate_10, 3U, b_8, _S1789);
            offer(sel_7, _S1790, _S1789 * make_float3 (scale_3) / make_float3 (density_3));
            break;
        }
        float3  _S1791 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1791;
        bool _S1792 = (fcptVaryingUsed());
        if(_S1792)
        {
            _S1523 = filling_2 != 4294967295U;
        }
        else
        {
            _S1523 = false;
        }
        if(_S1523)
        {
            if(_S1397)
            {
                float3  _S1793 = throughput_10 * glowed_0 / make_float3 (density_3);
                float3  _S1794 = sel_7->glow + _S1793;
                sel_7->glow = _S1794;
            }
            float3  _S1795 = throughput_10 * weight_1;
            throughput_8 = _S1795;
        }
        else
        {
            float3  _S1796 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S1797 = throughput_10 * _S1796;
            throughput_8 = _S1797;
        }
        float _S1798 = width_4 + spread_2 * (&hit_4)->distance;
        viewed_0 = _S1522;
        width_3 = _S1798;
        throughput_2 = throughput_8;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_1 = spread_2;
        uint _S1685 = b_8 + 1U;
        b_5 = _S1685;
        layer_0 = _S1684;
    }
    return _S1202;
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
    Random _S1799 = pcg(state_3);
    Random _S1800 = pcg(_S1799.state);
    float _S1801 = 6.28318548202514648f * _S1799.value;
    float _S1802 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S1800.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1800.state, _S1802 * (F32_cos((_S1801))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_4, float3  value_2)
{
    RandomSphere _S1803;
    (&_S1803)->state = state_4;
    (&_S1803)->value = value_2;
    return _S1803;
}

__device__ RandomSphere random_sphere(uint state_5)
{
    Random _S1804 = normal_distribution(state_5);
    Random _S1805 = normal_distribution(_S1804.state);
    Random _S1806 = normal_distribution(_S1805.state);
    float3  _S1807 = make_float3 (_S1804.value, _S1805.value, _S1806.value);
    float3  _S1808 = ((((_S1807)) * make_float3(rnorm3df(((_S1807)).x, ((_S1807)).y, ((_S1807)).z))));
    return RandomSphere_x24init_0(_S1806.state, _S1808);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_13)
{
    float3  _S1809 = p1_0 - p0_0;
    float3  _S1810 = p2_0 - p0_0;
    float2  _S1811 = uv1_0 - uv0_0;
    float2  _S1812 = uv2_0 - uv0_0;
    float _S1813 = _S1811.x;
    float _S1814 = _S1812.y;
    float _S1815 = _S1811.y;
    float _S1816 = _S1812.x;
    float _S1817 = _S1813 * _S1814 - _S1815 * _S1816;
    float _S1818 = 1.0f / _S1817;
    float3  t_22 = (_S1809 * make_float3 (_S1814) - _S1810 * make_float3 (_S1815)) * make_float3 (_S1818);
    float3  _S1819 = (_S1810 * make_float3 (_S1813) - _S1809 * make_float3 (_S1816)) * make_float3 (_S1818);
    float3  _S1820 = t_22 - n_13 * make_float3 (dot_0(n_13, t_22));
    float3  _S1821 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_13);
    bool _S1822 = (dot_0(_S1820, _S1820)) > 0.0f;
    float3  _S1823 = _slang_select(_S1822, _S1820,_S1821);
    float3  _S1824 = ((((_S1823)) * make_float3(rnorm3df(((_S1823)).x, ((_S1823)).y, ((_S1823)).z))));
    bool _S1825 = (dot_0(cross_0(n_13, _S1824), _S1819)) > 0.0f;
    float3  t_23;
    if(_S1825)
    {
        float3  _S1826 = negate_0(_S1824);
        t_23 = _S1826;
    }
    else
    {
        t_23 = _S1824;
    }
    float3  _S1827 = cross_0(n_13, t_23);
    return makeMatrix<float, 3, 3> (t_23, _S1827, n_13);
}

__device__ float3  tangentToWorldNormalMap(float3  v_5, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_5, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_4, float3  uvw_0, float3  position_1)
{
    float3  _S1828 = t1_0 - t0_0;
    float3  _S1829 = t2_2 - t0_0;
    float3  _S1830 = t2_2 - t1_0;
    float _S1831 = (F32_min((length_0(_S1828)), ((F32_min((length_0(_S1829)), (length_0(_S1830)))))));
    float3  _S1832 = make_float3 (distance_1(position_1, t0_0), distance_1(position_1, t1_0), distance_1(position_1, t2_2));
    float3  _S1833 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1834 = dot_0(geometry_n_4, _S1833);
    float3  _S1835 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1836 = dot_0(geometry_n_4, _S1835);
    float3  _S1837 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1838 = acos_0(abs_0(make_float3 (_S1834, _S1836, dot_0(geometry_n_4, _S1837))));
    float3  _S1839 = clamp_2(tan_0(_S1838), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S1832 * _S1839, uvw_0), 0.0f, _S1831 * 0.125f);
}

__device__ float3  straightThrough(BSDFMaterial material_23)
{
    return make_float3 (material_23.transmission * (1.0f - material_23.metallic)) * material_23.albedo;
}

__device__ float hairRow(float3  in_dir_11, float3  t_24, float3  out_dir_3, uint p_15, float w_2, float alpha_20, uint nt_0)
{
    uint _S1840 = p_15 % 4U;
    float _S1841 = w_2 * HAIR_WIDTHS_0[_S1840];
    float _S1842 = (F32_asin((clamp_1(dot_0(out_dir_3, t_24), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_11, t_24), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1840] * alpha_20;
    return ((F32_asinh((_S1842 / _S1841))) / (F32_asinh((3.14159274101257324f / _S1841))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_12, float3  t_25, float3  out_dir_4, uint np_0)
{
    float3  _S1843 = worldToTangent(out_dir_4, t_25);
    float3  _S1844 = worldToTangent(in_dir_12, t_25);
    return (F32_frac((((F32_atan2((_S1843.z), (_S1843.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1844.z), (1.17549435082228751e-38f - _S1844.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_13, float3  t_26, uint p_16, float row_0, float column_0, float w_3, float alpha_21, uint nt_1, uint np_1)
{
    float3  _S1845 = worldToTangent(in_dir_13, t_26);
    uint _S1846 = p_16 % 4U;
    float _S1847 = w_3 * HAIR_WIDTHS_0[_S1846];
    float _S1848 = (F32_asin((clamp_1(dot_0(in_dir_13, t_26), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1846] * alpha_21 + _S1847 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1847))))));
    float _S1849 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1845.z), (1.17549435082228751e-38f - _S1845.x)));
    float _S1850 = (F32_cos((_S1848)));
    float3  _S1851 = tangentToWorld(make_float3 (_S1850 * (F32_cos((_S1849))), (F32_sin((_S1848))), _S1850 * (F32_sin((_S1849)))), t_26);
    return _S1851;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_14, BSDFMaterial material_24, float coverage_1)
{
    float3  _S1852;
    if((material_24.ior) == 1.0f)
    {
        float3  _S1853 = straightThrough(material_24);
        _S1852 = _S1853;
    }
    else
    {
        _S1852 = make_float3 (0.0f);
    }
    return _S1852 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_8, Reservoir r_9, bool replay_2, float scale_4, Selection * sel_8)
{
    Domain _S1854 = dom_8;
    Reservoir _S1855 = r_9;
    Shift _S1856 = walk_0(&_S1854, &_S1855, replay_2, scale_4, sel_8);
    return _S1856;
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
