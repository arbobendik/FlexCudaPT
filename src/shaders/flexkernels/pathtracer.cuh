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
        bool _S159 = previousValid_0(p_9);
        int2  _S160;
        if(_S159)
        {
            _S160 = p_9;
        }
        else
        {
            _S160 = make_int2 (int(-1));
        }
        return _S160;
    }
    float3  _S161 = make_float3 (0.0f);
    FKHit _S162 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S163 = Domain_x24init_0(_S161, _S161, &_S162, 0.0f, 0.0f);
    Domain dom_3 = _S163;
    uint2  _S164 = (fcptRenderSize());
    int2  _S165 = make_int2 ((int)_S164.x, (int)_S164.y);
    bool _S166 = any_0(p_9 >= _S165);
    bool _S167;
    if(_S166)
    {
        _S167 = true;
    }
    else
    {
        bool _S168 = (fcptStoredDomainInitial((p_9), (seed_2), (&dom_3)));
        _S167 = !_S168;
    }
    if(_S167)
    {
        return make_int2 (int(-1));
    }
    Domain _S169 = dom_3;
    int2  _S170 = temporalNeighbor_0(p_9, &_S169, seed_2);
    return _S170;
}

static __device__ bool seedDomain_0(int2  p_10, uint seed_3, Domain * dom_4)
{
    bool _S171 = (fcptStoredDomainInitial((p_10), (seed_3), (dom_4)));
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

__device__ float importance(LightNode node_0, float3  p_11, float3  normal_0)
{
    float3  _S230 = (node_0.low + node_0.high) * make_float3 (0.5f);
    float3  _S231 = node_0.high - node_0.low;
    float3  _S232 = p_11 - _S230;
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

__device__ __forceinline__ float childShare(LightNode first_0, LightNode second_0, float3  p_12, float3  normal_1, uint child_0)
{
    float _S256 = importance(first_0, p_12, normal_1);
    float _S257 = importance(second_0, p_12, normal_1);
    float2  _S258 = make_float2 (_S256, _S257);
    float _S259 = _slang_vector_get_element(_S258, child_0) / (_S256 + _S257);
    bool _S260 = _slang_vector_get_element(_S258, child_0) > 0.0f;
    float _S261 = _slang_select(_S260, _S259,0.0f);
    return _S261;
}

__device__ float sphereDensity(float3  center_0, float radius_0, float3  p_13)
{
    float3  _S262 = center_0 - p_13;
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
        uint _S294 = _S292.y;
        FKLight _S295 = (fcptLight((_S294)));
        FKLight _S296 = (fcptLight((_S294)));
        float _S297 = sphereDensity(_S295.position, _S296.variance, start_5);
        return probability_1 * _S297;
    }
    uint _S298 = _S292.y;
    uint _S299 = (fcptTriangleOffset((_S298)));
    Matrix<float, 3, 3>  _S300 = (fcptWorldTriangle((_S298), (_S299 + _S292.z)));
    float _S301 = solidAngle(probability_1, cross_0(_S300.rows[int(1)] - _S300.rows[int(0)], _S300.rows[int(2)] - _S300.rows[int(0)]), light_point_0 - start_5);
    return _S301;
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
    uint2  _S302 = make_uint2 (k_0 * 3242174889U, k_0 * 2447445414U) >> make_uint2 (16U);
    uint _S303 = (fkBlueNoiseSize());
    return (_S302 * make_uint2 (_S303)) >> make_uint2 (16U);
}

__device__ uint stream(uint seed_4, uint index_0)
{
    uint _S304 = hash(index_0);
    uint _S305 = hash(seed_4 ^ _S304);
    return _S305;
}

static __device__ Random Random_x24init_0(uint state_0, float value_0)
{
    Random _S306;
    (&_S306)->state = state_0;
    (&_S306)->value = value_0;
    return _S306;
}

__device__ Random pcg(uint state_1)
{
    uint _S307 = hash(state_1);
    float value_1 = float(_S307 >> int(8)) * 5.9604644775390625e-08f;
    return Random_x24init_0(_S307, value_1);
}

__device__ __noinline__ Random draw(uint address_0, uint variable_0)
{
    uint _S308 = address_0 >> 22U;
    uint _S309 = _S308 / 32U;
    uint2  _S310 = make_uint2 (address_0 & 2047U, (address_0 >> 11U) & 2047U);
    uint _S311 = variable_0 & 2147483647U;
    uint2  _S312 = noiseOffset(_S311);
    uint2  _S313 = _S310 + _S312;
    uint2  _S314 = noiseOffset(4096U + _S309);
    uint2  _S315 = _S313 + _S314;
    uint _S316 = (fkBlueNoiseSize());
    uint2  _S317 = _S315 & make_uint2 (_S316 - 1U);
    uint _S318 = (fkBlueNoise((_S317.x), (_S317.y), ((_S308 + ((_S309 * 2654435769U) >> 27U)) % 32U)));
    bool _S319 = (variable_0 & 2147483648U) != 0U;
    uint _S320 = stream(address_0, _S311);
    Random _S321 = pcg(_S320);
    float _S322;
    if(_S318 == 4294967295U)
    {
        if(_S319)
        {
            Random _S323 = pcg(_S321.state);
            _S322 = _S323.value;
        }
        else
        {
            _S322 = _S321.value;
        }
    }
    else
    {
        uint _S324;
        if(_S319)
        {
            _S324 = _S318 >> 16U;
        }
        else
        {
            _S324 = _S318 & 65535U;
        }
        _S322 = (float(_S324) + 0.5f) / 6.5536e+04f;
    }
    return Random_x24init_0(address_0, _S322);
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
    uint2  _S325 = (fcptEnvironmentCdfSize());
    uint2  _S326 = _S325 - make_uint2 (1U, 0U);
    float3  _S327 = skyFrame_0(dir_3);
    float2  _S328 = make_float2 ((F32_atan2((- _S327.z), (- _S327.x))) / 6.28318548202514648f + 0.5f, (F32_acos((clamp_1(_S327.y, -1.0f, 1.0f)))) / 3.14159274101257324f);
    float2  _S329 = make_float2 ((float)_S326.x, (float)_S326.y);
    float2  _S330 = _S328 * _S329;
    uint2  _S331 = make_uint2 ((uint)_S330.x, (uint)_S330.y);
    uint2  _S332 = min_0(_S331, _S326 - make_uint2 (1U));
    float4  _S333 = (fcptEnvironmentCdf((_S332)));
    float _S334 = _S333.y;
    uint _S335 = _S326.x;
    float4  _S336 = (fcptEnvironmentCdf((make_uint2 (_S335, _S332.y))));
    float _S337 = _S334 * _S336.y;
    return _S337 * float(_S335 * _S326.y) / (19.73921012878417969f * length_1(float2 {_S327.x, _S327.z}));
}

__device__ float upsample(float3  rgb_0, float wavelength_0)
{
    float _S338 = dot_0(make_float3 (-0.08011700212955475f, 1.08901798725128174f, -0.00889899954199791f), rgb_0);
    float _S339 = dot_0(make_float3 (0.12177000194787979f, -1.22903203964233398f, 1.10724997520446777f), rgb_0);
    float _S340 = dot_0(make_float3 (1.17252397537231445f, -1.21603405475616455f, 0.04350199922919273f), rgb_0);
    float3  _S341 = make_float3 (_S338, _S339, _S340);
    float _S342 = (wavelength_0 - 0.44999998807907104f) / 0.02999999932944775f;
    float _S343 = (wavelength_0 - 0.63999998569488525f) / 0.03999999910593033f;
    return _S338 + _S339 * (F32_exp((-0.5f * _S342 * _S342))) + _S340 * (F32_exp((-0.5f * _S343 * _S343)));
}

__device__ BSDFMaterial atWavelength(BSDFMaterial material_0, float wavelength_1)
{
    BSDFMaterial at_0 = material_0;
    float _S344 = upsample(material_0.albedo, wavelength_1);
    float3  _S345 = make_float3 (_S344);
    (&at_0)->albedo = _S345;
    float _S346 = upsample(material_0.emissive, wavelength_1);
    float3  _S347 = make_float3 (_S346);
    (&at_0)->emissive = _S347;
    float _S348 = upsample(material_0.absorption, wavelength_1);
    float3  _S349 = make_float3 (_S348);
    (&at_0)->absorption = _S349;
    float _S350 = upsample(material_0.specular_tint, wavelength_1);
    float3  _S351 = make_float3 (_S350);
    (&at_0)->specular_tint = _S351;
    float _S352 = upsample(material_0.translucent, wavelength_1);
    float3  _S353 = make_float3 (_S352);
    (&at_0)->translucent = _S353;
    float _S354 = upsample(material_0.sheen, wavelength_1);
    float3  _S355 = make_float3 (_S354);
    (&at_0)->sheen = _S355;
    float _S356 = upsample(material_0.coat_tint, wavelength_1);
    float3  _S357 = make_float3 (_S356);
    (&at_0)->coat_tint = _S357;
    return at_0;
}

__device__ BSDFMaterial pathMaterial(BSDFMaterial material_1, float wavelength_2)
{
    BSDFMaterial _S358;
    if(wavelength_2 > 0.0f)
    {
        BSDFMaterial _S359 = atWavelength(material_1, wavelength_2);
        _S358 = _S359;
    }
    else
    {
        _S358 = material_1;
    }
    return _S358;
}

static __device__ float3  negate_0(float3  x_13)
{
    return - x_13;
}

static __device__ float sign_0(float e_1)
{
    float _S360;
    if(e_1 > 0.0f)
    {
        _S360 = 1.0f;
    }
    else
    {
        if(e_1 < 0.0f)
        {
            _S360 = -1.0f;
        }
        else
        {
            _S360 = 0.0f;
        }
    }
    return _S360;
}

struct AnisotropicFrame
{
    float3  tangent;
    float2  alphas;
};

static __device__ AnisotropicFrame AnisotropicFrame_x24init_0(float3  tangent_0, float2  alphas_0)
{
    AnisotropicFrame _S361;
    (&_S361)->tangent = tangent_0;
    (&_S361)->alphas = alphas_0;
    return _S361;
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_1)
{
    float3  a_1 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S362 = (F32_abs((dot_0(n_1, a_1)))) > 0.9999847412109375f;
    float3  a_2;
    if(_S362)
    {
        float3  _S363 = make_float3 (1.0f, 0.0f, 0.0f);
        a_2 = _S363;
    }
    else
    {
        a_2 = a_1;
    }
    float3  _S364 = cross_0(n_1, a_2);
    float3  _S365 = ((((_S364)) * make_float3(rnorm3df(((_S364)).x, ((_S364)).y, ((_S364)).z))));
    float3  _S366 = cross_0(n_1, _S365);
    return make_float3 (v_0.x) * _S365 + make_float3 (v_0.y) * n_1 + make_float3 (v_0.z) * _S366;
}

__device__ AnisotropicFrame anisotropicFrame(BSDFMaterial material_2, float3  n_i_0)
{
    float _S367 = material_2.roughness;
    float _S368 = _S367 * _S367;
    bool _S369 = (material_2.anisotropy) == 0.0f;
    bool _S370;
    if(_S369)
    {
        _S370 = true;
    }
    else
    {
        _S370 = !(_S368 > 0.0f);
    }
    if(_S370)
    {
        return AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f));
    }
    float3  _S371 = material_2.tangent - n_i_0 * make_float3 (dot_0(n_i_0, material_2.tangent));
    float3  _S372 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_i_0);
    bool _S373 = (dot_0(_S371, _S371)) > 0.0f;
    float3  _S374 = _slang_select(_S373, _S371,_S372);
    float3  _S375 = ((((_S374)) * make_float3(rnorm3df(((_S374)).x, ((_S374)).y, ((_S374)).z))));
    float _S376 = 6.28318548202514648f * material_2.anisotropic_rotation;
    float _S377 = (F32_sqrt((1.0f - 0.89999997615814209f * (F32_abs((material_2.anisotropy))))));
    float _S378 = 1.0f / _S377;
    bool _S379 = (material_2.anisotropy) < 0.0f;
    float _S380 = _slang_select(_S379, _S378,_S377);
    return AnisotropicFrame_x24init_0(_S375 * make_float3 ((F32_cos((_S376)))) + cross_0(n_i_0, _S375) * make_float3 ((F32_sin((_S376)))), make_float2 (_S368 / _S380, _S368 * _S380));
}

struct SheenProfile
{
    bool on;
    float albedo;
};

static __device__ SheenProfile SheenProfile_x24init_0(bool on_0, float albedo_0)
{
    SheenProfile _S381;
    (&_S381)->on = on_0;
    (&_S381)->albedo = albedo_0;
    return _S381;
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
    SheenProfile _S382 = SheenProfile_x24init_0(false, 0.0f);
    float _S383 = rgb_to_greyscale(material_3.sheen);
    bool _S384 = _S383 > 0.0f;
    SheenProfile profile_0;
    if(_S384)
    {
        float _S385 = clamp_1((F32_sqrt(((F32_max((dot_0(n_i_1, v_1)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S386 = (U32_min((uint(_S385)), (22U)));
        float _S387 = (F32_sqrt((0.05000000074505806f)));
        float _S388 = (F32_sqrt((0.10000000149011612f)));
        bool _S389 = (material_3.velvet) > 0.0f;
        float _S390 = _slang_select(_S389, _S388,_S387);
        float _S391 = (clamp_1((F32_sqrt(((F32_max((material_3.sheen_roughness), (0.0f)))))), _S390, 1.0f) - _S390) / (1.0f - _S390) * 23.0f;
        uint _S392 = (U32_min((uint(_S391)), (22U)));
        uint _S393 = _S386 * 24U + _S392;
        float _S394 = _S385 - float(_S386);
        float _S395 = _S391 - float(_S392);
        if(_S389)
        {
            uint _S396 = _S393 + 24U;
            float _S397 = VELVET_ALBEDO_0[_S393] + (VELVET_ALBEDO_0[_S396] - VELVET_ALBEDO_0[_S393]) * _S394;
            uint _S398 = _S393 + 1U;
            float _S399 = VELVET_ALBEDO_0[_S398] + (VELVET_ALBEDO_0[_S396 + 1U] - VELVET_ALBEDO_0[_S398]) * _S394;
            SheenProfile _S400 = SheenProfile_x24init_0(true, _S397 + (_S399 - _S397) * _S395);
            profile_0 = _S400;
        }
        else
        {
            uint _S401 = _S393 + 24U;
            float _S402 = SHEEN_ALBEDO_0[_S393] + (SHEEN_ALBEDO_0[_S401] - SHEEN_ALBEDO_0[_S393]) * _S394;
            uint _S403 = _S393 + 1U;
            float _S404 = SHEEN_ALBEDO_0[_S403] + (SHEEN_ALBEDO_0[_S401 + 1U] - SHEEN_ALBEDO_0[_S403]) * _S394;
            SheenProfile _S405 = SheenProfile_x24init_0(true, (F32_exp((_S402 + (_S404 - _S402) * _S395))));
            profile_0 = _S405;
        }
    }
    else
    {
        profile_0 = _S382;
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
    CoatFrame _S406;
    (&_S406)->normal = normal_3;
    (&_S406)->alpha = alpha_0;
    (&_S406)->ior = ior_0;
    return _S406;
}

__device__ __forceinline__ CoatFrame coatFrame(BSDFMaterial material_4, float3  n_2)
{
    CoatFrame _S407 = CoatFrame_x24init_0(make_float3 (0.0f), 0.0f, 0.0f);
    bool _S408 = (material_4.coat) > 0.0f;
    CoatFrame frame_0;
    if(_S408)
    {
        float3  _S409 = material_4.coat_normal;
        bool _S410 = (dot_0(_S409, _S409)) > 0.0f;
        float3  _S411 = material_4.coat_normal;
        float3  _S412 = ((((_S411)) * make_float3(rnorm3df(((_S411)).x, ((_S411)).y, ((_S411)).z))));
        float3  _S413 = _slang_select(_S410, _S412,n_2);
        float _S414 = sign_0(dot_0(_S413, n_2));
        float _S415 = material_4.coat_roughness;
        CoatFrame _S416 = CoatFrame_x24init_0(_S413 * make_float3 (_S414), _S415 * _S415, (F32_max((material_4.coat_ior), (1.00999999046325684f))));
        frame_0 = _S416;
    }
    else
    {
        frame_0 = _S407;
    }
    return frame_0;
}

__device__ __forceinline__ float3  coatSeries(CoatFrame coat_frame_0, BSDFMaterial material_5)
{
    float3  _S417 = make_float3 (0.0f);
    bool _S418 = (coat_frame_0.ior) > 0.0f;
    float3  series_0;
    if(_S418)
    {
        float _S419 = coat_frame_0.ior * coat_frame_0.ior;
        float _S420 = _S419 * _S419;
        float _S421 = coat_frame_0.ior - 1.0f;
        float _S422 = coat_frame_0.ior + 1.0f;
        float _S423 = _S419 - 1.0f;
        float _S424 = _S419 + 1.0f;
        float _S425 = _S420 - 1.0f;
        float _S426 = _S424 * _S425;
        float _S427 = 0.5f + _S421 * (3.0f * coat_frame_0.ior + 1.0f) / (6.0f * _S422 * _S422) + _S419 * _S423 * _S423 / (_S424 * _S424 * _S424) * (F32_log((_S421 / _S422))) - 2.0f * _S419 * coat_frame_0.ior * (_S419 + 2.0f * coat_frame_0.ior - 1.0f) / _S426 + 8.0f * _S420 * (_S420 + 1.0f) / (_S426 * _S425) * (F32_log((coat_frame_0.ior)));
        float _S428 = 1.0f - (1.0f - _S427) / _S419;
        float3  _S429 = material_5.coat_tint;
        float3  _S430 = _S429 * _S429 * make_float3 (1.0f - _S428) / (make_float3 (1.0f) - material_5.albedo * make_float3 (_S428));
        series_0 = _S430;
    }
    else
    {
        series_0 = _S417;
    }
    return series_0;
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
    float _S431 = dot_0(n_3, i_6);
    float _S432 = 1.0f - eta_0 * eta_0 * (1.0f - _S431 * _S431);
    if(_S432 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_6 - make_float3 (eta_0 * _S431 + (F32_sqrt((_S432)))) * n_3;
}

__device__ float fresnel(float cos_theta_0, float eta_i_0, float eta_o_0)
{
    float _S433 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S434 = eta_i_0 / eta_o_0 * _S433;
    bool _S435 = _S434 < 1.0f;
    float kr_0;
    if(_S435)
    {
        float _S436 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S434 * _S434))))));
        bool _S437 = eta_i_0 == eta_o_0;
        float _S438 = _slang_select(_S437, cos_theta_0,_S436);
        float _S439 = eta_o_0 * cos_theta_0;
        float _S440 = eta_i_0 * _S438;
        float _S441 = (_S439 - _S440) / (_S439 + _S440);
        float _S442 = eta_i_0 * cos_theta_0;
        float _S443 = eta_o_0 * _S438;
        float _S444 = (_S442 - _S443) / (_S442 + _S443);
        float _S445 = (_S441 * _S441 + _S444 * _S444) / 2.0f;
        kr_0 = _S445;
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
    float _S446 = alpha_1 * alpha_1;
    float _S447 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S446 + (1.0f - _S446) * n_dot_x_0 * n_dot_x_0))));
    bool _S448 = alpha_1 > 0.0f;
    float _S449 = _slang_select(_S448, _S447,1.0f);
    return _S449;
}

__device__ __forceinline__ float coatFresnel(float3  in_dir_0, float3  v_2, float3  coat_h_0, CoatFrame coat_frame_1, float eta_i_1, bool behind_0)
{
    float _S450 = dot_0(coat_frame_1.normal, reflect_0(in_dir_0, coat_h_0));
    float _S451 = (F32_abs((dot_0(v_2, coat_h_0))));
    float _S452 = eta_i_1 / coat_frame_1.ior * (F32_sqrt(((F32_max((1.0f - _S451 * _S451), (0.0f))))));
    float _S453 = (F32_sqrt(((F32_max((1.0f - _S452 * _S452), (0.0f))))));
    float _S454 = _slang_select(behind_0, _S453,_S451);
    float _S455 = _slang_select(behind_0, coat_frame_1.ior,1.0f);
    float _S456 = _slang_select(behind_0, 1.0f,coat_frame_1.ior);
    float _S457 = fresnel(_S454, _S455, _S456);
    float _S458 = smithG1(coat_frame_1.alpha, _S450);
    float _S459 = _S457 * _S458;
    bool _S460 = _S450 > 0.0f;
    float _S461 = _slang_select(_S460, _S459,0.0f);
    return _S461;
}

static __device__ float3  mix_0(float3  e1_0, float3  e2_0, float e3_0)
{
    return e1_0 * make_float3 (1.0f - e3_0) + e2_0 * make_float3 (e3_0);
}

static __device__ Weights Weights_x24init_0(float v_dot_h_0, float3  refracted_1, float3  F_0, float reflect_weight_0, float3  diffuse_weight_0, float3  refract_weight_0, float p_diffuse_0, float p_reflect_0, float p_refract_0, float p_sheen_velvet_0, float p_toon_0, float3  sheen_0, float3  toon_0, float3  coat_0, float p_coat_0)
{
    Weights _S462;
    (&_S462)->v_dot_h = v_dot_h_0;
    (&_S462)->refracted = refracted_1;
    (&_S462)->F = F_0;
    (&_S462)->reflect_weight = reflect_weight_0;
    (&_S462)->diffuse_weight = diffuse_weight_0;
    (&_S462)->refract_weight = refract_weight_0;
    (&_S462)->p_diffuse = p_diffuse_0;
    (&_S462)->p_reflect = p_reflect_0;
    (&_S462)->p_refract = p_refract_0;
    (&_S462)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S462)->p_toon = p_toon_0;
    (&_S462)->sheen = sheen_0;
    (&_S462)->toon = toon_0;
    (&_S462)->coat = coat_0;
    (&_S462)->p_coat = p_coat_0;
    return _S462;
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

__device__ __forceinline__ Weights lobeWeights(float3  in_dir_1, float3  v_3, float3  n_i_2, float3  h_0, float3  coat_h_1, float3  ggx_n_0, float3  coat_n_0, AnisotropicFrame frame_1, SheenProfile sheen_profile_0, CoatFrame coat_frame_2, float3  coat_series_0, BSDFMaterial material_6, float eta_i_2, float eta_o_1)
{
    float _S463 = (F32_min(((F32_sqrt((material_6.specular_level))) * (F32_abs((eta_i_2 - eta_o_1))) / (eta_i_2 + eta_o_1)), (0.9999847412109375f)));
    float _S464 = _S463 * _S463;
    float _S465 = (1.0f + _S463) / (1.0f - _S463);
    float3  _S466 = make_float3 (1.0f);
    float3  _S467 = make_float3 (0.0f);
    float sheen_component_0;
    float3  sheen_1;
    float3  scale_1;
    if(sheen_profile_0.on)
    {
        float _S468 = (F32_min((sheen_profile_0.albedo), (1.0f)));
        float3  _S469 = make_float3 (1.0f) - material_6.sheen * make_float3 (_S468);
        float _S470 = rgb_to_greyscale(material_6.sheen);
        float _S471 = _S470 * _S468;
        float3  _S472 = material_6.sheen / make_float3 ((F32_max((sheen_profile_0.albedo), (1.0f))));
        sheen_component_0 = _S471;
        sheen_1 = _S472;
        scale_1 = _S469;
    }
    else
    {
        sheen_component_0 = 0.0f;
        sheen_1 = _S467;
        scale_1 = _S466;
    }
    float _S473 = (F32_abs((material_6.toon.x)));
    bool _S474 = _S473 > 0.0f;
    float toon_component_0;
    float3  toon_1;
    if(_S474)
    {
        float _S475 = (F32_min((_S473), (1.0f)));
        float3  scale_2 = scale_1 * make_float3 (1.0f - _S475);
        float _S476 = rgb_to_greyscale(material_6.albedo);
        float _S477 = _S475 * _S476;
        float3  _S478 = make_float3 (_S475) * material_6.albedo;
        toon_component_0 = _S477;
        toon_1 = _S478;
        scale_1 = scale_2;
    }
    else
    {
        toon_component_0 = 0.0f;
        toon_1 = _S467;
    }
    bool _S479 = (material_6.metallic) > 0.0f;
    float3  rebounce_0;
    if(_S479)
    {
        float _S480 = frame_1.alphas.x;
        float _S481 = (F32_sqrt(((F32_min((_S480), (frame_1.alphas.y))))));
        bool _S482 = _S480 > 0.0f;
        float _S483 = _slang_select(_S482, _S481,material_6.roughness);
        float _S484 = _S483 * _S483;
        float _S485 = (F32_pow((_S484), (1.81585001945495605f))) * (2.15371990203857422f - 0.73285001516342163f * _S484) / (1.0f + 1.28094995021820068f * _S484);
        bool _S486 = _S484 > 0.0f;
        float _S487 = _slang_select(_S486, _S485,0.0f);
        float _S488 = clamp_1(dot_0(n_i_2, v_3), 0.0f, 1.0f);
        float _S489 = _S484 * _S483;
        float _S490 = (F32_min((1.00064504146575928f - _S483 * (0.00375499995425344f + _S488 * (-0.04133399948477745f + _S488 * (-0.90938502550125122f + _S488 * 0.35275399684906006f))) - _S484 * (0.27602800726890564f + _S488 * (1.27023398876190186f + _S488 * 0.04740000143647194f)) - _S489 * (0.31452900171279907f - _S488 * 0.34830701351165771f) + _S489 * _S483 * 0.27229699492454529f), (1.0f)));
        float3  _S491 = min_1(make_float3 (1.0f) / (make_float3 (1.0f) - material_6.albedo * make_float3 (_S487)), make_float3 (1.0f / (F32_max((_S490), (0.0000152587890625f)))));
        rebounce_0 = _S491;
    }
    else
    {
        rebounce_0 = _S466;
    }
    float _S492 = dot_0(h_0, v_3);
    float _S493 = eta_i_2 / eta_o_1;
    float3  _S494 = refract_0(in_dir_1, h_0, _S493);
    float3  _S495 = ((((_S494)) * make_float3(rnorm3df(((_S494)).x, ((_S494)).y, ((_S494)).z))));
    float _S496 = (F32_abs((_S492)));
    bool _S497 = eta_i_2 > eta_o_1;
    float _S498;
    if(_S497)
    {
        _S498 = _S465;
    }
    else
    {
        _S498 = 1.0f;
    }
    float _S499;
    if(_S497)
    {
        _S499 = 1.0f;
    }
    else
    {
        _S499 = _S465;
    }
    float _S500 = fresnel(_S496, _S498, _S499);
    float _S501 = eta_i_2 * eta_i_2;
    float _S502 = eta_o_1 * eta_o_1;
    bool _S503 = (_S501 * (1.0f - _S492 * _S492)) >= _S502;
    float3  _S504;
    if(_S503)
    {
        _S504 = _S466;
    }
    else
    {
        float3  _S505 = material_6.specular_tint * make_float3 (_S464);
        _S504 = _S505 + (make_float3 (1.0f) - _S505) * make_float3 (_S500 - _S464) / make_float3 (1.0f - _S464);
    }
    bool _S506 = (dot_0(coat_h_1, coat_h_1)) > 0.0f;
    float3  coat_1;
    float3  up_0;
    float3  through_0;
    if(_S506)
    {
        float _S507 = coatFresnel(in_dir_1, v_3, coat_h_1, coat_frame_2, eta_i_2, _S497);
        float _S508 = material_6.coat * _S507;
        float3  _S509 = material_6.coat_tint;
        float3  _S510 = _S509 * _S509;
        float3  _S511 = _slang_select(_S497, _S510,_S466);
        float3  _S512 = make_float3 (_S508) * _S511;
        float _S513 = 1.0f - _S507;
        bool _S514 = !_S497;
        float3  _S515 = _slang_select(_S514, coat_series_0,_S466);
        float3  _S516 = mix_0(_S466, make_float3 (_S513) * _S515, material_6.coat);
        float3  _S517 = mix_0(_S466, make_float3 (_S513) * material_6.coat_tint, material_6.coat);
        coat_1 = _S512;
        up_0 = _S516;
        through_0 = _S517;
    }
    else
    {
        coat_1 = _S467;
        up_0 = _S466;
        through_0 = _S466;
    }
    float3  _S518 = scale_1 * coat_1;
    float _S519 = rgb_to_greyscale(_S518);
    float3  _S520 = material_6.albedo * rebounce_0;
    float3  _S521 = mix_0(_S504, _S520, material_6.metallic);
    float3  F_1 = _S521 * scale_1 * up_0;
    float _S522 = rgb_to_greyscale(F_1);
    float _S523 = 1.0f - material_6.metallic;
    float _S524 = (1.0f - material_6.transmission) * _S523;
    float3  _S525 = make_float3 (1.0f) - _S504;
    float3  _S526 = make_float3 (_S524) * _S525 * scale_1 * up_0;
    float _S527 = material_6.transmission * _S523;
    float3  _S528 = make_float3 (_S527) * _S525 * scale_1 * through_0;
    float _S529 = (F32_max((_S522), (0.0f)));
    float _S530 = rgb_to_greyscale(_S526);
    float _S531 = (F32_max((_S530), (0.0f)));
    float _S532 = rgb_to_greyscale(_S528);
    float _S533 = sign_0(length_0(_S495));
    float _S534 = (F32_max((_S532 * _S533), (0.0f)));
    float _S535 = _S529 + _S531 + _S534 + toon_component_0 + _S519;
    float _S536 = (F32_min((sheen_component_0), (1.0f)));
    bool _S537 = sheen_component_0 > 0.0f;
    bool _S538;
    if(_S537)
    {
        _S538 = !(_S535 > 0.0f);
    }
    else
    {
        _S538 = false;
    }
    float _S539 = _slang_select(_S538, 1.0f,_S536);
    float _S540 = (1.0f - _S539) / (F32_max((_S535), (0.0000152587890625f)));
    float _S541 = _S531 * _S540;
    float _S542 = _S529 * _S540;
    float _S543 = _S534 * _S540;
    Weights _S544 = Weights_x24init_0(_S492, _S495, F_1, 1.0f, _S526, _S528, _S541, _S542, _S543, _S539, toon_component_0 * _S540, sheen_1, toon_1, _S518, _S519 * _S540);
    bool _S545 = any_1(ggx_n_0 != h_0);
    Weights leaving_0;
    if(_S545)
    {
        float _S546 = dot_0(ggx_n_0, v_3);
        float _S547 = eta_i_2 / eta_o_1;
        float3  _S548 = refract_0(in_dir_1, ggx_n_0, _S547);
        float3  _S549 = ((((_S548)) * make_float3(rnorm3df(((_S548)).x, ((_S548)).y, ((_S548)).z))));
        float _S550 = (F32_abs((_S546)));
        if(_S497)
        {
            _S498 = _S465;
        }
        else
        {
            _S498 = 1.0f;
        }
        if(_S497)
        {
            _S499 = 1.0f;
        }
        else
        {
            _S499 = _S465;
        }
        float _S551 = fresnel(_S550, _S498, _S499);
        bool _S552 = (_S501 * (1.0f - _S546 * _S546)) >= _S502;
        if(_S552)
        {
            _S504 = _S466;
        }
        else
        {
            float3  _S553 = material_6.specular_tint * make_float3 (_S464);
            _S504 = _S553 + (make_float3 (1.0f) - _S553) * make_float3 (_S551 - _S464) / make_float3 (1.0f - _S464);
        }
        if(_S506)
        {
            float _S554 = coatFresnel(in_dir_1, v_3, coat_h_1, coat_frame_2, eta_i_2, _S497);
            float _S555 = material_6.coat * _S554;
            float3  _S556 = material_6.coat_tint;
            float3  _S557 = _S556 * _S556;
            float3  _S558 = _slang_select(_S497, _S557,_S466);
            float3  _S559 = make_float3 (_S555) * _S558;
            float _S560 = 1.0f - _S554;
            bool _S561 = !_S497;
            float3  _S562 = _slang_select(_S561, coat_series_0,_S466);
            float3  _S563 = mix_0(_S466, make_float3 (_S560) * _S562, material_6.coat);
            float3  _S564 = mix_0(_S466, make_float3 (_S560) * material_6.coat_tint, material_6.coat);
            coat_1 = _S559;
            up_0 = _S563;
            through_0 = _S564;
        }
        else
        {
            coat_1 = _S467;
            up_0 = _S466;
            through_0 = _S466;
        }
        float3  _S565 = scale_1 * coat_1;
        float _S566 = rgb_to_greyscale(_S565);
        float3  _S567 = mix_0(_S504, _S520, material_6.metallic);
        float3  F_2 = _S567 * scale_1 * up_0;
        float _S568 = rgb_to_greyscale(F_2);
        float3  _S569 = make_float3 (1.0f) - _S504;
        float3  _S570 = make_float3 (_S524) * _S569 * scale_1 * up_0;
        float3  _S571 = make_float3 (_S527) * _S569 * scale_1 * through_0;
        float _S572 = (F32_max((_S568), (0.0f)));
        float _S573 = rgb_to_greyscale(_S570);
        float _S574 = (F32_max((_S573), (0.0f)));
        float _S575 = rgb_to_greyscale(_S571);
        float _S576 = sign_0(length_0(_S549));
        float _S577 = (F32_max((_S575 * _S576), (0.0f)));
        float _S578 = _S572 + _S574 + _S577 + toon_component_0 + _S566;
        if(_S537)
        {
            _S538 = !(_S578 > 0.0f);
        }
        else
        {
            _S538 = false;
        }
        float _S579 = _slang_select(_S538, 1.0f,_S536);
        float _S580 = (1.0f - _S579) / (F32_max((_S578), (0.0000152587890625f)));
        float _S581 = _S574 * _S580;
        float _S582 = _S572 * _S580;
        float _S583 = _S577 * _S580;
        Weights _S584 = Weights_x24init_0(_S546, _S549, F_2, 1.0f, _S570, _S571, _S581, _S582, _S583, _S579, toon_component_0 * _S580, sheen_1, toon_1, _S565, _S566 * _S580);
        leaving_0 = _S584;
    }
    else
    {
        leaving_0 = _S544;
    }
    bool _S585 = any_1(coat_n_0 != coat_h_1);
    Weights coated_0;
    if(_S585)
    {
        float _S586 = eta_i_2 / eta_o_1;
        float3  _S587 = refract_0(in_dir_1, h_0, _S586);
        float3  _S588 = ((((_S587)) * make_float3(rnorm3df(((_S587)).x, ((_S587)).y, ((_S587)).z))));
        if(_S497)
        {
            sheen_component_0 = _S465;
        }
        else
        {
            sheen_component_0 = 1.0f;
        }
        if(_S497)
        {
            _S498 = 1.0f;
        }
        else
        {
            _S498 = _S465;
        }
        float _S589 = fresnel(_S496, sheen_component_0, _S498);
        if(_S503)
        {
            rebounce_0 = _S466;
        }
        else
        {
            float3  _S590 = material_6.specular_tint * make_float3 (_S464);
            rebounce_0 = _S590 + (make_float3 (1.0f) - _S590) * make_float3 (_S589 - _S464) / make_float3 (1.0f - _S464);
        }
        bool _S591 = (dot_0(coat_n_0, coat_n_0)) > 0.0f;
        if(_S591)
        {
            float _S592 = coatFresnel(in_dir_1, v_3, coat_n_0, coat_frame_2, eta_i_2, _S497);
            float _S593 = material_6.coat * _S592;
            float3  _S594 = material_6.coat_tint;
            float3  _S595 = _S594 * _S594;
            float3  _S596 = _slang_select(_S497, _S595,_S466);
            float3  _S597 = make_float3 (_S593) * _S596;
            float _S598 = 1.0f - _S592;
            bool _S599 = !_S497;
            float3  _S600 = _slang_select(_S599, coat_series_0,_S466);
            float3  _S601 = mix_0(_S466, make_float3 (_S598) * _S600, material_6.coat);
            float3  _S602 = mix_0(_S466, make_float3 (_S598) * material_6.coat_tint, material_6.coat);
            coat_1 = _S597;
            up_0 = _S601;
            through_0 = _S602;
        }
        else
        {
            coat_1 = _S467;
            up_0 = _S466;
            through_0 = _S466;
        }
        float3  _S603 = scale_1 * coat_1;
        float _S604 = rgb_to_greyscale(_S603);
        float3  _S605 = mix_0(rebounce_0, _S520, material_6.metallic);
        float3  F_3 = _S605 * scale_1 * up_0;
        float _S606 = rgb_to_greyscale(F_3);
        float3  _S607 = make_float3 (1.0f) - rebounce_0;
        float3  _S608 = make_float3 (_S524) * _S607 * scale_1 * up_0;
        float3  _S609 = make_float3 (_S527) * _S607 * scale_1 * through_0;
        float _S610 = (F32_max((_S606), (0.0f)));
        float _S611 = rgb_to_greyscale(_S608);
        float _S612 = (F32_max((_S611), (0.0f)));
        float _S613 = rgb_to_greyscale(_S609);
        float _S614 = sign_0(length_0(_S588));
        float _S615 = (F32_max((_S613 * _S614), (0.0f)));
        float _S616 = _S610 + _S612 + _S615 + toon_component_0 + _S604;
        if(_S537)
        {
            _S538 = !(_S616 > 0.0f);
        }
        else
        {
            _S538 = false;
        }
        float _S617 = _slang_select(_S538, 1.0f,_S536);
        float _S618 = (1.0f - _S617) / (F32_max((_S616), (0.0000152587890625f)));
        float _S619 = _S612 * _S618;
        float _S620 = _S610 * _S618;
        float _S621 = _S615 * _S618;
        Weights _S622 = Weights_x24init_0(_S492, _S588, F_3, 1.0f, _S608, _S609, _S619, _S620, _S621, _S617, toon_component_0 * _S618, sheen_1, toon_1, _S603, _S604 * _S618);
        coated_0 = _S622;
    }
    else
    {
        coated_0 = _S544;
    }
    return Weights_x24init_0(leaving_0.v_dot_h, leaving_0.refracted, leaving_0.F, leaving_0.reflect_weight, _S544.diffuse_weight, leaving_0.refract_weight, _S544.p_diffuse, leaving_0.p_reflect, leaving_0.p_refract, _S544.p_sheen_velvet, _S544.p_toon, sheen_1, toon_1, coated_0.coat, coated_0.p_coat);
}

__device__ float translucentShare(BSDFMaterial material_7)
{
    float _S623 = rgb_to_greyscale(material_7.translucent);
    float _S624 = rgb_to_greyscale(material_7.albedo);
    float _S625 = _S623 / (_S624 + _S623);
    bool _S626 = _S623 > 0.0f;
    float _S627 = _slang_select(_S626, _S625,0.0f);
    return _S627;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float n_i_dot_v_0, BSDFMaterial material_8, Weights w_0)
{
    float _S628 = translucentShare(material_8);
    float _S629 = w_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S630 = w_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S631 = 1.0f - _S628;
    bool _S632 = n_i_dot_l_0 < 0.0f;
    float _S633 = _slang_select(_S632, _S628,_S631);
    float _S634 = _S630 * _S633;
    bool _S635 = _S628 > 0.0f;
    float _S636 = _slang_select(_S635, _S634,_S629);
    bool _S637 = n_i_dot_v_0 > 0.0f;
    float _S638 = _slang_select(_S637, _S636,0.0f);
    return _S638;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_3, BSDFMaterial material_9, Weights w_1)
{
    float _S639 = translucentShare(material_9);
    bool _S640 = (dot_0(n_i_3, l_0)) < 0.0f;
    float3  _S641 = _slang_select(_S640, material_9.translucent,material_9.albedo);
    float _S642 = 1.0f - _S639;
    float _S643 = _slang_select(_S640, _S639,_S642);
    float3  _S644 = _S641 / make_float3 (_S643);
    bool _S645 = _S639 > 0.0f;
    float3  _S646 = _slang_select(_S645, _S644,material_9.albedo);
    return w_1.diffuse_weight * _S646 / make_float3 (w_1.p_diffuse);
}

__device__ float trowbridgeReitz(float alpha_2, float n_dot_h_0)
{
    float _S647 = alpha_2 * alpha_2;
    float _S648 = (1.0f - n_dot_h_0) * (1.0f + n_dot_h_0) + _S647 * n_dot_h_0 * n_dot_h_0;
    return _S647 / (F32_max((3.14159274101257324f * _S648 * _S648), (1.17549435082228751e-38f)));
}

__device__ float3  anisotropicLocal(float3  w_2, float3  t_12, float3  n_5)
{
    return make_float3 (dot_0(w_2, t_12), dot_0(w_2, cross_0(n_5, t_12)), dot_0(w_2, n_5));
}

__device__ float anisotropicG1(float3  w_3, float2  alphas_1)
{
    float _S649 = (F32_max((w_3.z), (0.0f)));
    return 2.0f * _S649 / (_S649 + length_0(make_float3 (alphas_1.x * w_3.x, alphas_1.y * w_3.y, _S649)));
}

__device__ float anisotropicD(float3  h_1, float2  alphas_2)
{
    float _S650 = alphas_2.x;
    float _S651 = h_1.x / _S650;
    float _S652 = alphas_2.y;
    float _S653 = h_1.y / _S652;
    float _S654 = h_1.z;
    float _S655 = _S651 * _S651 + _S653 * _S653 + _S654 * _S654;
    return 1.0f / (F32_max((3.14159274101257324f * _S650 * _S652 * _S655 * _S655), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float3  v_4, float3  h_2, float3  n_i_4, float n_i_dot_v_1, float alpha_3, AnisotropicFrame frame_2, float v_dot_h_1)
{
    float _S656 = dot_0(n_i_4, h_2);
    float _S657 = smithG1(alpha_3, n_i_dot_v_1);
    float _S658 = _S657 * v_dot_h_1;
    float _S659 = trowbridgeReitz(alpha_3, _S656);
    float _S660 = _S658 * _S659 / n_i_dot_v_1;
    bool _S661 = alpha_3 > 0.0f;
    bool _S662;
    if(_S661)
    {
        _S662 = v_dot_h_1 > 0.0f;
    }
    else
    {
        _S662 = false;
    }
    if(_S662)
    {
        _S662 = _S656 > 0.0f;
    }
    else
    {
        _S662 = false;
    }
    if(_S662)
    {
        _S662 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S662 = false;
    }
    float _S663 = _slang_select(_S662, _S660,0.0f);
    bool _S664 = (frame_2.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S664)
    {
        float3  _S665 = anisotropicLocal(v_4, frame_2.tangent, n_i_4);
        float _S666 = anisotropicG1(_S665, frame_2.alphas);
        float3  _S667 = anisotropicLocal(h_2, frame_2.tangent, n_i_4);
        float _S668 = anisotropicD(_S667, frame_2.alphas);
        float _S669 = _S666 * _S668;
        float _S670 = _S669 * v_dot_h_1 / n_i_dot_v_1;
        bool _S671 = v_dot_h_1 > 0.0f;
        if(_S671)
        {
            _S662 = _S656 > 0.0f;
        }
        else
        {
            _S662 = false;
        }
        if(_S662)
        {
            _S662 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S662 = false;
        }
        float _S672 = _slang_select(_S662, _S670,0.0f);
        pdf_h_0 = _S672;
    }
    else
    {
        pdf_h_0 = _S663;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float l_dot_h_0, float pdf_h_1, Weights w_4, float eta_i_3, float eta_o_2)
{
    float _S673 = eta_i_3 * w_4.v_dot_h + eta_o_2 * l_dot_h_0;
    float _S674 = w_4.p_refract * pdf_h_1 * eta_o_2 * eta_o_2 * (F32_abs((l_dot_h_0))) / (_S673 * _S673);
    bool _S675 = eta_i_3 != eta_o_2;
    bool _S676;
    if(_S675)
    {
        _S676 = l_dot_h_0 < 0.0f;
    }
    else
    {
        _S676 = false;
    }
    float _S677 = _slang_select(_S676, _S674,0.0f);
    return _S677;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_5, float alpha_4, AnisotropicFrame frame_3, BSDFMaterial material_10, Weights w_5)
{
    float _S678 = - dot_0(n_i_5, l_1);
    float _S679 = smithG1(alpha_4, (F32_max((_S678), (0.0f))));
    bool _S680 = (frame_3.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S680)
    {
        float3  _S681 = negate_0(n_i_5);
        float3  _S682 = anisotropicLocal(l_1, frame_3.tangent, _S681);
        float _S683 = anisotropicG1(_S682, frame_3.alphas);
        G1_l_0 = _S683;
    }
    else
    {
        G1_l_0 = _S679;
    }
    return w_5.refract_weight * make_float3 (G1_l_0) * material_10.albedo / make_float3 (w_5.p_refract);
}

__device__ __forceinline__ float reflectPDF(float pdf_h_2, Weights w_6)
{
    float _S684 = w_6.p_reflect * pdf_h_2 / (4.0f * w_6.v_dot_h);
    bool _S685 = pdf_h_2 > 0.0f;
    float _S686 = _slang_select(_S685, _S684,0.0f);
    return _S686;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_2, float3  n_i_6, float alpha_5, AnisotropicFrame frame_4, Weights w_7)
{
    float _S687 = dot_0(n_i_6, l_2);
    float _S688 = smithG1(alpha_5, (F32_max((_S687), (0.0f))));
    bool _S689 = (frame_4.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S689)
    {
        float3  _S690 = anisotropicLocal(l_2, frame_4.tangent, n_i_6);
        float _S691 = anisotropicG1(_S690, frame_4.alphas);
        G1_l_1 = _S691;
    }
    else
    {
        G1_l_1 = _S688;
    }
    return make_float3 (w_7.reflect_weight * G1_l_1) * w_7.F / make_float3 (w_7.p_reflect);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_1, float n_i_dot_v_2, Weights w_8)
{
    float _S692 = w_8.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S693 = n_i_dot_l_1 > 0.0f;
    bool _S694;
    if(_S693)
    {
        _S694 = n_i_dot_v_2 > 0.0f;
    }
    else
    {
        _S694 = false;
    }
    float _S695 = _slang_select(_S694, _S692,0.0f);
    return _S695;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_3, float3  v_5, float3  n_i_7, BSDFMaterial material_11, Weights w_9)
{
    float3  _S696 = l_3 + v_5;
    float3  _S697 = ((((_S696)) * make_float3(rnorm3df(((_S696)).x, ((_S696)).y, ((_S696)).z))));
    float _S698 = dot_0(n_i_7, _S697);
    float _S699 = (F32_max((dot_0(n_i_7, l_3)), (0.0f)));
    float _S700 = (F32_max((dot_0(n_i_7, v_5)), (0.0f)));
    float _S701 = 1.0f / (F32_max((material_11.sheen_roughness), (0.05000000074505806f)));
    float _S702 = 1.0f - _S698 * _S698;
    float _S703 = (2.0f + _S701) * (F32_pow(((F32_max((_S702), (0.0f)))), (0.5f * _S701))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S699 + _S700 - _S699 * _S700)), (0.0000152587890625f)));
    bool _S704 = (material_11.velvet) > 0.0f;
    float f_1;
    if(_S704)
    {
        float _S705 = (F32_max((material_11.sheen_roughness), (0.00999999977648258f)));
        float _S706 = _S705 * _S705;
        float _S707 = (F32_max((_S702), (0.0000152587890625f)));
        float _S708 = (F32_exp((- _S698 * _S698 / (_S707 * _S706)))) / (3.14159274101257324f * _S706 * _S707 * _S707) * (F32_min((1.0f), (2.0f * _S698 * (F32_min((_S699), (_S700))) / (F32_max(((F32_abs((dot_0(_S697, v_5))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S699 * _S700), (0.0000152587890625f)));
        f_1 = _S708;
    }
    else
    {
        f_1 = _S703;
    }
    return w_9.sheen * make_float3 (f_1 * _S699 * 2.0f * 3.14159274101257324f / w_9.p_sheen_velvet);
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
    float _S709;
    if(t_13 < a_3)
    {
        _S709 = 1.0f;
    }
    else
    {
        _S709 = (F32_max((1.0f - (t_13 - a_3) / (F32_max((s_0), (0.0000152587890625f)))), (0.0f)));
    }
    return _S709;
}

__device__ __forceinline__ float toonIntegral(float t_14, float a_4, float s_1, bool glossy_0)
{
    float integral_0;
    if(glossy_0)
    {
        integral_0 = 1.0f - (F32_cos(((F32_min((t_14), (a_4))))));
    }
    else
    {
        float _S710 = (F32_sin(((F32_min((t_14), (a_4))))));
        integral_0 = _S710 * _S710 / 2.0f;
    }
    bool _S711 = t_14 > a_4;
    bool _S712;
    if(_S711)
    {
        _S712 = s_1 > 0.0f;
    }
    else
    {
        _S712 = false;
    }
    if(_S712)
    {
        float _S713;
        if(glossy_0)
        {
            float _S714 = (F32_cos((a_4)));
            float _S715 = (F32_cos((t_14)));
            _S713 = (1.0f + a_4 / s_1) * (_S714 - _S715) - ((F32_sin((t_14))) - t_14 * _S715 - ((F32_sin((a_4))) - a_4 * _S714)) / s_1;
        }
        else
        {
            float _S716 = 2.0f * a_4;
            float _S717 = (F32_cos((_S716)));
            float _S718 = 2.0f * t_14;
            float _S719 = (F32_cos((_S718)));
            _S713 = (1.0f + a_4 / s_1) * (_S717 - _S719) / 4.0f - ((F32_sin((_S718))) / 8.0f - t_14 * _S719 / 4.0f - ((F32_sin((_S716))) / 8.0f - a_4 * _S717 / 4.0f)) / s_1;
        }
        float integral_1 = integral_0 + _S713;
        integral_0 = integral_1;
    }
    return integral_0;
}

static __device__ ToonProfile ToonProfile_x24init_0(bool glossy_1, float a_5, float s_2, float b_1, float norm_0, float view_0, float3  axis_0)
{
    ToonProfile _S720;
    (&_S720)->glossy = glossy_1;
    (&_S720)->a = a_5;
    (&_S720)->s = s_2;
    (&_S720)->b = b_1;
    (&_S720)->norm = norm_0;
    (&_S720)->view = view_0;
    (&_S720)->axis = axis_0;
    return _S720;
}

__device__ __forceinline__ ToonProfile toonProfile(float3  v_6, float3  n_i_8, BSDFMaterial material_12)
{
    float _S721 = material_12.toon.x;
    bool _S722 = _S721 < 0.0f;
    float _S723 = clamp_1(material_12.toon.y / _S721, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S724 = clamp_1(material_12.toon.z / _S721, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S725 = (F32_min((_S723 + _S724), (1.57079637050628662f)));
    float _S726 = dot_0(n_i_8, v_6);
    float _S727 = toonP((F32_acos(((F32_min((_S726), (1.0f)))))), _S723, _S724);
    float3  _S728;
    if(_S722)
    {
        float3  _S729 = make_float3 (2.0f * _S726) * n_i_8 - v_6;
        float3  _S730 = ((((_S729)) * make_float3(rnorm3df(((_S729)).x, ((_S729)).y, ((_S729)).z))));
        _S728 = _S730;
    }
    else
    {
        _S728 = n_i_8;
    }
    float _S731 = toonIntegral(_S725, _S723, _S724, _S722);
    return ToonProfile_x24init_0(_S722, _S723, _S724, _S725, 6.28318548202514648f * _S731, _S727, _S728);
}

__device__ __forceinline__ float toonPDF(float3  l_4, float3  n_i_9, ToonProfile profile_1, Weights w_10)
{
    float _S732 = dot_0(n_i_9, l_4);
    float _S733 = dot_0(l_4, profile_1.axis);
    float _S734 = _slang_select(profile_1.glossy, _S733,_S732);
    float _S735 = (F32_acos((clamp_1(_S734, -1.0f, 1.0f))));
    float _S736 = toonP(_S735, profile_1.a, profile_1.s);
    float _S737 = w_10.p_toon * _S736;
    float _S738 = _slang_select(profile_1.glossy, 1.0f,_S732);
    float _S739 = _S737 * _S738 / profile_1.norm;
    bool _S740;
    if(profile_1.glossy)
    {
        _S740 = true;
    }
    else
    {
        _S740 = _S732 > 0.0f;
    }
    float _S741 = _slang_select(_S740, _S739,0.0f);
    return _S741;
}

__device__ __forceinline__ float3  toonBSDF(float3  l_5, float3  n_i_10, ToonProfile profile_2, Weights w_11)
{
    float _S742 = (F32_max((dot_0(n_i_10, l_5)), (0.0f)));
    float _S743 = _slang_select(profile_2.glossy, _S742,profile_2.view);
    return w_11.toon * make_float3 (_S743) / make_float3 (w_11.p_toon);
}

__device__ __forceinline__ float coatPDF(float3  v_7, float3  coat_h_2, CoatFrame coat_frame_3, Weights w_12)
{
    float _S744 = dot_0(coat_frame_3.normal, v_7);
    float _S745 = smithG1(coat_frame_3.alpha, _S744);
    float _S746 = trowbridgeReitz(coat_frame_3.alpha, dot_0(coat_frame_3.normal, coat_h_2));
    float _S747 = _S745 * _S746 / (4.0f * _S744);
    bool _S748 = (coat_frame_3.alpha) > 0.0f;
    float _S749 = _slang_select(_S748, _S747,0.0f);
    return w_12.p_coat * _S749;
}

__device__ __forceinline__ float3  coatBSDF(Weights w_13)
{
    return w_13.coat / make_float3 (w_13.p_coat);
}

__device__ __forceinline__ void BSDF(float3  in_dir_2, float3  out_dir_0, float3  n_6, BSDFMaterial material_13, float eta_i_4, float eta_o_3, bool refracted_2, Facets facets_0, FixedArray<float3 , 6>  * throughputs_0, FixedArray<float, 6>  * pdfs_0)
{
    float3  _S750 = negate_0(in_dir_2);
    float _S751 = dot_0(n_6, _S750);
    float _S752 = sign_0(_S751);
    float3  _S753 = n_6 * make_float3 (_S752);
    float _S754 = dot_0(_S753, out_dir_0);
    float _S755 = material_13.roughness;
    float _S756 = _S755 * _S755;
    AnisotropicFrame _S757 = anisotropicFrame(material_13, _S753);
    SheenProfile _S758 = sheenProfile(_S750, _S753, material_13);
    CoatFrame _S759 = coatFrame(material_13, _S753);
    float3  _S760 = coatSeries(_S759, material_13);
    float _S761 = rgb_to_greyscale(material_13.translucent);
    bool _S762 = _S761 > 0.0f;
    bool _S763 = (dot_0(n_6, out_dir_0) * _S751) < 0.0f;
    bool _S764 = (F32_abs((material_13.toon.x))) > 0.0f;
    float3  _S765 = facets_0.coat_h;
    bool _S766 = (dot_0(_S765, _S765)) > 0.0f;
    bool _S767;
    if(_S762)
    {
        _S767 = _S763;
    }
    else
    {
        _S767 = false;
    }
    bool _S768 = _S767 == refracted_2;
    bool _S769 = !refracted_2;
    if(_S769)
    {
        _S767 = _S764;
    }
    else
    {
        _S767 = false;
    }
    bool _S770;
    if(_S769)
    {
        _S770 = _S766;
    }
    else
    {
        _S770 = false;
    }
    float3  _S771 = negate_0(make_float3 (eta_i_4) * _S750 + make_float3 (eta_o_3) * out_dir_0);
    float3  _S772 = ((((_S771)) * make_float3(rnorm3df(((_S771)).x, ((_S771)).y, ((_S771)).z))));
    float3  _S773 = _S750 + out_dir_0;
    float3  _S774 = ((((_S773)) * make_float3(rnorm3df(((_S773)).x, ((_S773)).y, ((_S773)).z))));
    float _S775 = sign_0(dot_0(_S772, _S753));
    float3  _S776 = _S772 * make_float3 (_S775);
    float3  _S777 = _slang_select(refracted_2, _S776,_S774);
    float3  _S778 = make_float3 (0.0f);
    float3  _S779 = ((((_S773)) * make_float3(rnorm3df(((_S773)).x, ((_S773)).y, ((_S773)).z))));
    float3  _S780 = _slang_select(_S770, _S779,_S778);
    Weights _S781 = lobeWeights(in_dir_2, _S750, _S753, facets_0.h, facets_0.coat_h, _S777, _S780, _S757, _S758, _S759, _S760, material_13, eta_i_4, eta_o_3);
    float _S782 = (F32_abs((_S751)));
    float _S783 = diffusePDF(_S754, _S782, material_13, _S781);
    float _S784 = _slang_select(_S768, _S783,0.0f);
    (*pdfs_0)[int(0)] = _S784;
    float3  _S785 = diffuseBSDF(out_dir_0, _S753, material_13, _S781);
    float3  _S786 = _slang_select(_S768, _S785,_S778);
    (*throughputs_0)[int(0)] = _S786;
    float _S787 = vndfPDF(_S750, _S777, _S753, _S782, _S756, _S757, _S781.v_dot_h);
    float _S788 = refractPDF(dot_0(out_dir_0, _S777), _S787, _S781, eta_i_4, eta_o_3);
    float _S789 = _slang_select(refracted_2, _S788,0.0f);
    (*pdfs_0)[int(1)] = _S789;
    float3  _S790 = refractBSDF(out_dir_0, _S753, _S756, _S757, material_13, _S781);
    float3  _S791 = _slang_select(refracted_2, _S790,_S778);
    (*throughputs_0)[int(1)] = _S791;
    float _S792 = reflectPDF(_S787, _S781);
    float _S793 = _slang_select(_S769, _S792,0.0f);
    (*pdfs_0)[int(2)] = _S793;
    float3  _S794 = reflectBSDF(out_dir_0, _S753, _S756, _S757, _S781);
    float3  _S795 = _slang_select(_S769, _S794,_S778);
    (*throughputs_0)[int(2)] = _S795;
    float _S796 = sheenVelvetPDF(_S754, _S782, _S781);
    float _S797 = _slang_select(_S769, _S796,0.0f);
    (*pdfs_0)[int(3)] = _S797;
    float3  _S798 = sheenVelvetBSDF(out_dir_0, _S750, _S753, material_13, _S781);
    float3  _S799 = _slang_select(_S769, _S798,_S778);
    (*throughputs_0)[int(3)] = _S799;
    ToonProfile _S800 = toonProfile(_S750, _S753, material_13);
    float _S801 = toonPDF(out_dir_0, _S753, _S800, _S781);
    float _S802 = _slang_select(_S767, _S801,0.0f);
    (*pdfs_0)[int(4)] = _S802;
    float3  _S803 = toonBSDF(out_dir_0, _S753, _S800, _S781);
    float3  _S804 = _slang_select(_S767, _S803,_S778);
    (*throughputs_0)[int(4)] = _S804;
    float _S805 = coatPDF(_S750, _S780, _S759, _S781);
    float _S806 = _slang_select(_S770, _S805,0.0f);
    (*pdfs_0)[int(5)] = _S806;
    float3  _S807 = coatBSDF(_S781);
    float3  _S808 = _slang_select(_S770, _S807,_S778);
    (*throughputs_0)[int(5)] = _S808;
    return;
}

static __device__ __forceinline__ float3  skyLobes_0(float3  in_dir_3, float3  dir_4, FKSurface * surface_1, BSDFMaterial * material_14, float2  eta_1, bool is_inside_2, Facets * facets_1, float pdf_0, FixedArray<float3 , 6>  * terms_0, FixedArray<float, 6>  * pdfs_1)
{
    bool _S809 = wrongSide_0(is_inside_2, false, dir_4, surface_1->geometry_n);
    BSDF(in_dir_3, dir_4, surface_1->smooth_n, *material_14, eta_1.x, eta_1.y, _S809, *facets_1, terms_0, pdfs_1);
    float3  _S810 = make_float3 (0.0f);
    uint i_9 = 0U;
    float3  f_2 = _S810;
    for(;;)
    {
        if(i_9 < 6U)
        {
        }
        else
        {
            break;
        }
        bool _S811 = ((*pdfs_1)[i_9]) > 0.0f;
        if(_S811)
        {
            float3  _S812 = (*terms_0)[i_9] * make_float3 ((*pdfs_1)[i_9]) / make_float3 ((*pdfs_1)[i_9] + pdf_0);
            (*terms_0)[i_9] = _S812;
            float3  f_3 = f_2 + (*terms_0)[i_9];
            f_2 = f_3;
        }
        uint i_10 = i_9 + 1U;
        i_9 = i_10;
    }
    return f_2;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_5, float3  radiance_0, float3  color_0, uint random_state_2)
{
    SkySample _S813;
    (&_S813)->dir = dir_5;
    (&_S813)->radiance = radiance_0;
    (&_S813)->color = color_0;
    (&_S813)->random_state = random_state_2;
    return _S813;
}

static __device__ __noinline__ float3  skyColor_0(float3  dir_6, FixedArray<float3 , 6>  * terms_1, FixedArray<float, 6>  * pdfs_2, uint depth_0)
{
    float3  _S814 = make_float3 (0.0f);
    bool shaded_0 = false;
    float3  world_0 = _S814;
    uint i_11 = 0U;
    float3  color_1 = _S814;
    for(;;)
    {
        if(i_11 < 6U)
        {
        }
        else
        {
            break;
        }
        bool _S815 = ((*pdfs_2)[i_11]) > 0.0f;
        if(_S815)
        {
            bool _S816 = (fcptWorldReadsPath());
            bool _S817;
            if(_S816)
            {
                _S817 = true;
            }
            else
            {
                _S817 = !shaded_0;
            }
            bool shaded_1;
            float3  world_1;
            if(_S817)
            {
                uint _S818;
                if(i_11 == 3U)
                {
                    _S818 = 4U;
                }
                else
                {
                    if(i_11 == 4U)
                    {
                        _S818 = 6U;
                    }
                    else
                    {
                        if(i_11 == 5U)
                        {
                            _S818 = 5U;
                        }
                        else
                        {
                            _S818 = i_11;
                        }
                    }
                }
                float3  _S819 = (fcptEnvMapSample((dir_6), (depth_0), (_S818)));
                world_1 = _S819;
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
    uint2  _S820 = (fcptEnvironmentCdfSize());
    uint2  _S821 = make_uint2 (1U, 0U);
    uint2  _S822 = _S820 - _S821;
    Random _S823 = draw(init_random_state_0, 6U);
    Random _S824 = draw(init_random_state_0, 2147483654U);
    Random _S825 = draw(init_random_state_0, 7U);
    Random _S826 = draw(init_random_state_0, 2147483655U);
    uint _S827 = _S822.x;
    uint _S828 = searchCDF_0(make_uint2 (_S827, 0U), make_uint2 (0U, 1U), _S822.y, _S823.value);
    uint _S829 = searchCDF_0(make_uint2 (0U, _S828), _S821, _S827, _S824.value);
    float2  _S830 = make_float2 ((float)_S822.x, (float)_S822.y);
    float2  _S831 = (make_float2 (float(_S829), float(_S828)) + make_float2 (_S825.value, _S826.value)) / _S830 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S832 = _S831.y;
    float _S833 = (F32_sin((_S832)));
    float _S834 = _S831.x;
    float3  _S835 = skyFrame_0(make_float3 (_S833 * (F32_cos((_S834))), (F32_cos((_S832))), _S833 * (F32_sin((_S834)))));
    float _S836 = environmentPdf_0(_S835);
    BSDFMaterial _S837 = pathMaterial(surface_2->material, wavelength_3);
    BSDFMaterial _S838 = _S837;
    FixedArray<float3 , 6>  terms_2;
    FixedArray<float, 6>  pdfs_3;
    float3  _S839 = skyLobes_0(ray_0->unit_direction, _S835, surface_2, &_S838, eta_2, is_inside_3, facets_2, _S836, &terms_2, &pdfs_3);
    bool _S840 = !(_S836 > 0.0f);
    bool _S841;
    if(_S840)
    {
        _S841 = true;
    }
    else
    {
        _S841 = all_1(_S839 == make_float3 (0.0f));
    }
    if(_S841)
    {
        float3  _S842 = make_float3 (0.0f);
        return SkySample_x24init_0(_S835, _S842, _S842, _S826.state);
    }
    bool _S843 = (fcptWorldReadsPath());
    float3  seen_0;
    if(_S843)
    {
        uint _S844 = context_2->depth + 1U;
        FixedArray<float3 , 6>  _S845 = terms_2;
        FixedArray<float, 6>  _S846 = pdfs_3;
        float3  _S847 = skyColor_0(_S835, &_S845, &_S846, _S844);
        seen_0 = _S847;
    }
    else
    {
        seen_0 = _S839;
    }
    float3  _S848 = skyRadiance_0(ray_0->origin, surface_2, is_inside_3, _S835, context_2, _S826.state);
    return SkySample_x24init_0(_S835, _S848, seen_0 * _S848, _S826.state);
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

static __device__ float3  hairLight_0(FKSurface * surface_3, float3  in_dir_4, TreeSample * light_1, bool competing_0)
{
    SampleBSDF _S849 = (fcptConnectHair((surface_3->hair), ((&surface_3->material)->albedo), ((&surface_3->material)->specular_tint), (in_dir_4), (light_1->dir)));
    float3  _S850 = _S849.throughput * make_float3 (_S849.pdf);
    float _S851 = light_1->density;
    float _S852 = 1.0f + _S849.pdf * _S849.pdf / (light_1->density * light_1->density);
    bool _S853;
    if(competing_0)
    {
        _S853 = _S851 > 0.0f;
    }
    else
    {
        _S853 = false;
    }
    float _S854 = _slang_select(_S853, _S852,1.0f);
    return _S850 / make_float3 (_S854) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_7, float3  radiance_1, float density_0, uint random_state_3)
{
    TreeSample _S855;
    (&_S855)->dir = dir_7;
    (&_S855)->radiance = radiance_1;
    (&_S855)->density = density_0;
    (&_S855)->random_state = random_state_3;
    return _S855;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_14, float3  normal_4, float * pick_0, float * probability_3)
{
    float _S856 = importance(first_1, p_14, normal_4);
    float _S857 = importance(second_1, p_14, normal_4);
    float2  _S858 = make_float2 (_S856, _S857);
    bool _S859 = _S856 == 0.0f;
    bool _S860;
    if(_S859)
    {
        _S860 = _S857 == 0.0f;
    }
    else
    {
        _S860 = false;
    }
    if(_S860)
    {
        return 2U;
    }
    float _S861 = _S856 + _S857;
    bool _S862 = _S857 > 0.0f;
    if(_S862)
    {
        _S860 = (*pick_0 * _S861) >= _S856;
    }
    else
    {
        _S860 = false;
    }
    uint _S863 = uint(_S860);
    float _S864 = (F32_min(((*pick_0 * _S861 - float(_S863) * _S856) / _slang_vector_get_element(_S858, _S863)), (0.99999994039535522f)));
    *pick_0 = _S864;
    float _S865 = *probability_3 * (_slang_vector_get_element(_S858, _S863) / _S861);
    *probability_3 = _S865;
    return _S863;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_15, float u1_0, float u2_0)
{
    float3  _S866 = center_1 - p_15;
    float _S867 = radius_1 * radius_1 / dot_0(_S866, _S866);
    float _S868 = u1_0 * _S867 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S867), (0.0f)))))));
    float _S869 = 2.0f * u1_0;
    bool _S870 = _S867 >= 1.0f;
    float _S871 = _slang_select(_S870, _S869,_S868);
    float _S872 = (F32_sqrt(((F32_max((_S871 * (2.0f - _S871)), (0.0f))))));
    float _S873 = 6.28318548202514648f * u2_0;
    float3  _S874 = make_float3 (_S872 * (F32_cos((_S873))), 1.0f - _S871, _S872 * (F32_sin((_S873))));
    float3  _S875 = ((((_S866)) * make_float3(rnorm3df(((_S866)).x, ((_S866)).y, ((_S866)).z))));
    float3  _S876 = tangentToWorld(_S874, _S875);
    return _S876;
}

__device__ float3  pointLightRadiance(float3  color_3, float intensity_0, float radius_2)
{
    return color_3 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S877 = center_2 - ray_1->origin;
    float _S878 = dot_0(_S877, ray_1->unit_direction);
    float _S879 = dot_0(_S877, _S877) - _S878 * _S878;
    float _S880 = radius_3 * radius_3;
    bool _S881 = _S879 > _S880;
    if(_S881)
    {
        return 4.294967296e+09f;
    }
    float _S882 = (F32_sqrt((_S880 - _S879)));
    float _S883 = _S878 - _S882;
    float _S884 = _S878 + _S882;
    bool _S885 = _S883 > 0.0000152587890625f;
    bool _S886;
    if(_S885)
    {
        _S886 = _S883 < max_len_0;
    }
    else
    {
        _S886 = false;
    }
    if(_S886)
    {
        return _S883;
    }
    bool _S887 = _S884 > 0.0000152587890625f;
    if(_S887)
    {
        _S886 = _S884 < max_len_0;
    }
    else
    {
        _S886 = false;
    }
    if(_S886)
    {
        return _S884;
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

static __device__ float3  emitted_0(float3  emissive_0, float3  dir_8, float3  n_7)
{
    float _S888 = sign_0(dot_0(- dir_8, n_7));
    float3  _S889 = emissive_0 * make_float3 ((F32_max((_S888), (0.0f))));
    bool _S890 = ((true));
    float3  _S891 = _slang_select(_S890, emissive_0,_S889);
    return _S891;
}

static __device__ __forceinline__ TreeSample sampleLightTree_0(float3  origin_4, float3  smooth_n_2, float3  geometry_n_1, float geometry_offset_1, bool sided_0, uint init_random_state_1, ShadowContext * context_3)
{
    Random _S892 = draw(init_random_state_1, 4U);
    Random _S893 = draw(init_random_state_1, 5U);
    Random _S894 = draw(init_random_state_1, 2147483653U);
    float3  _S895 = make_float3 (0.0f);
    TreeSample _S896 = TreeSample_x24init_0(_S895, _S895, 0.0f, _S894.state);
    TreeSample sample_0 = _S896;
    float3  _S897 = _slang_select(sided_0, _S895,smooth_n_2);
    float3  _S898 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S892.value;
    float probability_4 = 1.0f;
    uint n_8 = 0U;
    for(;;)
    {
        uint4  _S899 = (fcptLightNode((n_8)));
        if((_S899.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S900 = (fcptLightSecond((n_8)));
        uint _S901 = n_8 + 1U;
        LightNode _S902 = (fcptLightBounds((_S901)));
        LightNode _S903 = (fcptLightBounds((_S900)));
        uint _S904 = pickChild(_S902, _S903, origin_4, _S897, &pick_1, &probability_4);
        bool _S905 = _S904 > 1U;
        if(_S905)
        {
            return sample_0;
        }
        bool _S906 = _S904 == 1U;
        uint _S907 = _slang_select(_S906, _S900,_S901);
        n_8 = _S907;
    }
    bool _S908 = n_8 == 0U;
    bool _S909;
    if(_S908)
    {
        LightNode _S910 = (fcptLightBounds((0U)));
        float _S911 = importance(_S910, origin_4, _S897);
        _S909 = !(_S911 > 0.0f);
    }
    else
    {
        _S909 = false;
    }
    if(_S909)
    {
        return sample_0;
    }
    uint4  _S912 = (fcptLightNode((n_8)));
    FKHit _S913 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S914 = (_S912.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S914)
    {
        FKLight _S915 = (fcptLight((_S912.y)));
        if(sided_0)
        {
            float _S916 = sign_0(dot_0(geometry_n_1, _S915.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S916);
            float3  _S917 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S917;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S898;
            lift_n_0 = smooth_n_2;
        }
        bool _S918 = (_S915.variance) == 0.0f;
        if(_S918)
        {
            float3  _S919 = _S915.position - emitter_point_0;
            float3  _S920 = ((((_S919)) * make_float3(rnorm3df(((_S919)).x, ((_S919)).y, ((_S919)).z))));
            (&sample_0)->dir = _S920;
            float3  _S921 = _S915.color * make_float3 (_S915.intensity) / make_float3 (dot_0(_S919, _S919) * probability_4);
            (&sample_0)->radiance = _S921;
            shadow_1 = _S919;
        }
        else
        {
            float3  _S922 = sampleSphere(_S915.position, _S915.variance, emitter_point_0, _S893.value, _S894.value);
            (&sample_0)->dir = _S922;
            float _S923 = sphereDensity(_S915.position, _S915.variance, emitter_point_0);
            float _S924 = probability_4 * _S923;
            (&sample_0)->density = _S924;
            float3  _S925 = pointLightRadiance(_S915.color, _S915.intensity, _S915.variance);
            float3  _S926 = _S925 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S926;
            FKRay _S927 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S928 = raySphere_0(_S915.position, _S915.variance, &_S927, 4.294967296e+09f);
            float3  _S929 = (&sample_0)->dir * make_float3 (_S928);
            shadow_1 = _S929;
        }
        emitter_0 = _S913;
        emitter_point_0 = _S895;
    }
    else
    {
        uint _S930 = _S912.y;
        uint _S931 = (fcptTriangleOffset((_S930)));
        uint _S932 = _S931 + _S912.z;
        Matrix<float, 3, 3>  _S933 = (fcptWorldTriangle((_S930), (_S932)));
        float _S934 = (F32_sqrt((_S893.value)));
        float2  _S935 = make_float2 (_S934 * (1.0f - _S894.value), _S934 * _S894.value);
        float3  _S936 = mul_0(make_float3 (1.0f - _S934, _S935.x, _S935.y), _S933);
        if(sided_0)
        {
            float _S937 = sign_0(dot_0(geometry_n_1, _S936 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S937);
            float3  _S938 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S938;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S939 = !((dot_0(smooth_n_2, _S936 - origin_4)) > 0.0f);
            if(_S939)
            {
                return sample_0;
            }
            emitter_point_0 = _S898;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S935, _S930, _S932, 0U, 0.0f);
        float3  _S940 = _S936 - emitter_point_0;
        float3  _S941 = ((((_S940)) * make_float3(rnorm3df(((_S940)).x, ((_S940)).y, ((_S940)).z))));
        (&sample_0)->dir = _S941;
        float _S942 = solidAngle(probability_4, cross_0(_S933.rows[int(1)] - _S933.rows[int(0)], _S933.rows[int(2)] - _S933.rows[int(0)]), _S940);
        (&sample_0)->density = _S942;
        bool _S943 = (fcptShadowFirst());
        bool _S944 = !_S943;
        if(_S944)
        {
            FKSurface _S945 = (fcptLightSurfaceAt((emitter_1), (_S936), (_S894.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S936 - origin_4))));
            (&sample_0)->random_state = _S945.random_state;
            float3  _S946 = emitted_0(_S945.material.emissive, (&sample_0)->dir, _S945.smooth_n);
            float3  _S947 = _slang_select(_S945.skip, _S895,_S946);
            float3  _S948 = _S947 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S948;
        }
        shadow_1 = _S940;
        emitter_0 = emitter_1;
        emitter_point_0 = _S936;
    }
    FKHit _S949 = emitter_0;
    float3  _S950 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S894.state, &_S949);
    bool _S951 = (fcptShadowFirst());
    if(_S951)
    {
        _S909 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S909 = false;
    }
    if(_S909)
    {
        _S909 = !all_1(_S950 == _S895);
    }
    else
    {
        _S909 = false;
    }
    if(_S909)
    {
        FKSurface _S952 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S894.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S952.random_state;
        float3  _S953 = emitted_0(_S952.material.emissive, (&sample_0)->dir, _S952.smooth_n);
        float3  _S954 = _slang_select(_S952.skip, _S895,_S953);
        float3  _S955 = _S954 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S955;
    }
    float3  _S956 = (&sample_0)->radiance * _S950;
    bool _S957 = all_1(_S950 == _S895);
    float3  _S958 = _slang_select(_S957, _S895,_S956);
    (&sample_0)->radiance = _S958;
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
    float _S959 = 1.0f / (1.0f + b_2 / a_6 * (b_2 / a_6));
    bool _S960 = b_2 > 0.0f;
    float _S961 = _slang_select(_S960, _S959,1.0f);
    return _S961;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S962 = vertex_0->none;
    if(_S962)
    {
        return 1.0f;
    }
    uint _S963 = (fcptLightSlot((*hit_1)));
    float _S964 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S963, light_point_1);
    float _S965 = powerHeuristic(vertex_0->pdf, _S964);
    return _S965;
}

static __device__ float3  environment_0(float3  dir_9, uint depth_1, uint lobe_0)
{
    uint2  _S966 = (fcptEnvironmentMapSize());
    bool _S967 = (_S966.x) > 1U;
    bool _S968;
    if(_S967)
    {
        uint2  _S969 = (fcptEnvironmentMapSize());
        _S968 = (_S969.y) > 1U;
    }
    else
    {
        _S968 = false;
    }
    if(_S968)
    {
        float3  _S970 = (fcptEnvMapSample((dir_9), (depth_1), (lobe_0)));
        return _S970;
    }
    float3  _S971 = (fcptAmbient());
    return _S971;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S972 = (fcptEnvironmentCdfSize());
    bool _S973 = (_S972.x) > 1U;
    bool _S974;
    if(_S973)
    {
        uint2  _S975 = (fcptEnvironmentCdfSize());
        _S974 = (_S975.y) > 1U;
    }
    else
    {
        _S974 = false;
    }
    bool _S976 = !_S974;
    if(_S976)
    {
        return false;
    }
    uint2  _S977 = (fcptEnvironmentMapSize());
    bool _S978 = (_S977.x) > 1U;
    if(_S978)
    {
        uint2  _S979 = (fcptEnvironmentMapSize());
        _S974 = (_S979.y) > 1U;
    }
    else
    {
        _S974 = false;
    }
    return _S974;
}

static __device__ float escapeWeight_0(float pdf_1, float3  dir_10)
{
    bool _S980 = pdf_1 <= 0.0f;
    bool _S981;
    if(_S980)
    {
        _S981 = true;
    }
    else
    {
        bool _S982 = environmentMapped_0();
        _S981 = !_S982;
    }
    if(_S981)
    {
        return 1.0f;
    }
    float _S983 = environmentPdf_0(dir_10);
    return pdf_1 / (pdf_1 + _S983);
}

static __device__ void restir_duplicates_0(uint3  global_invocation_id_1, uint3  local_invocation_id_0, uint local_invocation_index_3)
{
    uint2  _S984 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S985 = make_int2 ((int)_S984.x, (int)_S984.y);
    uint _S986 = previousSeed_0(_S985);
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
            uint _S987 = previousSeed_0(_S985 + make_int2 (x_16, y_5));
            bool _S988 = _S987 == _S986;
            uint _S989 = _slang_select(_S988, 1U,0U);
            uint count_3 = count_2 + _S989;
            int x_17 = x_16 + int(1);
            x_16 = x_17;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S990 = float(count_2 - 1U) / 288.0f;
    bool _S991 = _S986 != 0U;
    float _S992 = _slang_select(_S991, _S990,0.0f);
    fcptStoreDuplication((_S985), (make_uint4 ((F32_asuint((_S992))), 0U, 0U, 0U)));
    return;
}

static __device__ float3  abs_0(float3  x_18)
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
        *_slang_vector_get_element_ptr(&result_8, i_14) = (F32_abs((_slang_vector_get_element(x_18, i_14))));
        i_14 = i_14 + int(1);
    }
    return result_8;
}

__device__ float resamplingTarget(float3  f_4)
{
    float _S993 = rgb_to_greyscale(abs_0(f_4));
    return _S993;
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

__device__ void offer(Selection * sel_2, Reservoir candidate_0, float3  weight_0)
{
    float _S994 = resamplingTarget(weight_0);
    bool _S995 = _S994 > 0.0f;
    bool _S996;
    if(_S995)
    {
        _S996 = _S994 < 3.00000000549775576e+38f;
    }
    else
    {
        _S996 = false;
    }
    bool _S997 = !_S996;
    if(_S997)
    {
        return;
    }
    bool _S998 = sel_2->sums;
    if(_S998)
    {
        float3  _S999 = sel_2->color + weight_0;
        sel_2->color = _S999;
        return;
    }
    float _S1000 = sel_2->w_sum + _S994;
    sel_2->w_sum = _S1000;
    float3  _S1001 = sel_2->color + weight_0;
    sel_2->color = _S1001;
    Random _S1002 = pcg(sel_2->random_state);
    sel_2->random_state = _S1002.state;
    bool _S1003 = (_S1002.value * sel_2->w_sum) <= _S994;
    if(_S1003)
    {
        sel_2->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_3;
    float3  _S1004 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S1004;
    float _S1005 = r_3.jac * shifted_0.jac;
    (&candidate_1)->jac = _S1005;
    offer(sel_3, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S1006 = resamplingTarget((&r_4)->f);
    float _S1007 = sel_4.w_sum / _S1006;
    bool _S1008 = _S1006 > 0.0f;
    float _S1009 = _slang_select(_S1008, _S1007,0.0f);
    (&r_4)->w = _S1009;
    (&r_4)->c = c_1;
    return r_4;
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
    uint2  _S1010 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S1011 = make_int2 ((int)_S1010.x, (int)_S1010.y);
    float3  _S1012 = make_float3 (0.0f);
    FKHit _S1013 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S1014 = Domain_x24init_0(_S1012, _S1012, &_S1013, 0.0f, 0.0f);
    Domain dom_5 = _S1014;
    bool _S1015 = (fcptCurrentDomain((_S1011), (&dom_5)));
    bool _S1016 = !_S1015;
    if(_S1016)
    {
        Reservoir _S1017 = (Reservoir{});
        fcptStoreReservoirPrevious((_S1011), (_S1017), ((&dom_5)->hit));
        return;
    }
    Reservoir _S1018 = (fcptLoadReservoirTemporal((_S1011)));
    uint t_15 = 0U;
    float count_4 = 0.0f;
    float c_sum_0 = _S1018.c;
    for(;;)
    {
        uint _S1019 = (fcptRestirNeighbours());
        if(t_15 < _S1019)
        {
        }
        else
        {
            break;
        }
        int2  _S1020 = partner_0(_S1011, t_15);
        Domain neighbor_0 = _S1014;
        bool _S1021 = (fcptCurrentDomain((_S1020), (&neighbor_0)));
        if(_S1021)
        {
            float count_5 = count_4 + 1.0f;
            uint4  _S1022 = (fcptReservoirTemporal((_S1020), (0U)));
            float c_sum_1 = c_sum_0 + (U32_asfloat((_S1022.w)));
            count_4 = count_5;
            c_sum_0 = c_sum_1;
        }
        uint t_16 = t_15 + 1U;
        t_15 = t_16;
    }
    float _S1023 = _S1018.c / (F32_max((count_4), (1.0f)));
    float _S1024 = resamplingTarget(_S1018.f);
    bool _S1025 = count_4 == 0.0f;
    float _S1026 = _slang_select(_S1025, 1.0f,0.0f);
    Selection _S1027 = (Selection{});
    Selection sel_5 = _S1027;
    uint _S1028 = (fcptFrame());
    uint _S1029 = hash(_S1028);
    uint _S1030 = global_invocation_id_2.x;
    uint2  _S1031 = (fcptRenderSize());
    uint _S1032 = stream(_S1029, _S1030 + _S1031.x * global_invocation_id_2.y);
    uint _S1033 = stream(_S1032, 195U);
    (&sel_5)->random_state = _S1033;
    t_15 = 0U;
    float canonical_mis_0 = _S1026;
    for(;;)
    {
        uint _S1034 = (fcptRestirNeighbours());
        if(t_15 < _S1034)
        {
        }
        else
        {
            break;
        }
        int2  _S1035 = partner_0(_S1011, t_15);
        Domain neighbor_dom_0 = _S1014;
        bool _S1036 = (fcptCurrentDomain((_S1035), (&neighbor_dom_0)));
        if(_S1036)
        {
            Reservoir _S1037 = (fcptLoadReservoirTemporal((_S1035)));
            uint4  _S1038 = (fcptShiftData((_S1035), (t_15)));
            float4  _S1039 = asfloat_0(_S1038);
            uint4  _S1040 = (fcptShiftData((_S1011), (t_15)));
            float4  _S1041 = asfloat_0(_S1040);
            float _S1042 = (_S1037.c + _S1023) / c_sum_0;
            bool _S1043 = _S1024 > 0.0f;
            float canonical_mis_1;
            if(_S1043)
            {
                float _S1044 = _S1042 * _S1023 * _S1024;
                float _S1045 = _S1023 * _S1024;
                float _S1046 = resamplingTarget(float3 {_S1041.x, _S1041.y, _S1041.z});
                float canonical_mis_2 = canonical_mis_0 + _S1044 / (_S1045 + _S1037.c * _S1046);
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float _S1047 = resamplingTarget(_S1037.f);
            float3  _S1048 = float3 {_S1039.x, _S1039.y, _S1039.z};
            Shift _S1049 = Shift_x24init_0(_S1048, _S1039.w);
            float _S1050 = _S1042 * _S1037.c * _S1047;
            float _S1051 = _S1037.c * _S1047;
            float _S1052 = resamplingTarget(_S1048);
            offerShifted(&sel_5, _S1037, _S1049, _S1050 / (_S1051 + _S1023 * _S1052));
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_17 = t_15 + 1U;
        t_15 = t_17;
    }
    offerShifted(&sel_5, _S1018, Shift_x24init_0(_S1018.f, 1.0f), canonical_mis_0);
    Reservoir _S1053 = finalize(sel_5, c_sum_0);
    fcptStoreReservoirPrevious((_S1011), (_S1053), ((&dom_5)->hit));
    fcptStorePreviousLayer((_S1011), (5U), (make_uint4 (asuint_0((&(&dom_5)->hit)->uv).x, asuint_0((&(&dom_5)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S1011), (make_float4 ((&sel_5)->color.x, (&sel_5)->color.y, (&sel_5)->color.z, 0.0f)));
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
    uint _S1054 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S1055 = _S1054 != 4294967295U;
    if(_S1055)
    {
        uint2  _S1056 = make_uint2 (_S1054, _S1054 >> 14U) & make_uint2 (16383U);
        int2  _S1057 = make_int2 ((int)_S1056.x, (int)_S1056.y);
        ShiftJob _S1058 = (ShiftJob{});
        ShiftJob shift_job_0 = _S1058;
        Shift _S1059 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S1060 = _S1054 >> 28U;
        bool _S1061 = spatialJob_0(_S1057, _S1060, &shift_job_0, true);
        Shift shifted_1;
        if(_S1061)
        {
            Domain _S1062 = (&shift_job_0)->dom;
            Reservoir _S1063 = (&shift_job_0)->r;
            Shift _S1064 = passShift_0(&_S1062, &_S1063);
            shifted_1 = _S1064;
        }
        else
        {
            shifted_1 = _S1059;
        }
        fcptStoreShiftData((_S1057), (_S1060), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S1065 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S1066 = make_int2 ((int)_S1065.x, (int)_S1065.y);
    FixedArray<uint, 3>  _S1067;
    spatialBins_0(_S1066, &_S1067);
    FixedArray<uint, 3>  _S1068 = _S1067;
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
        bool _S1069 = (_S1068[t_18]) == 40U;
        if(_S1069)
        {
            fcptStoreShiftData((_S1066), (t_18), (make_uint4 (0U)));
        }
        uint t_19 = t_18 + 1U;
        t_18 = t_19;
    }
    FixedArray<uint, 3>  _S1070 = _S1068;
    queueShifts_0(_S1066, &_S1070, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S1071 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S1072 = make_int2 ((int)_S1071.x, (int)_S1071.y);
    FixedArray<uint, 3>  _S1073;
    spatialBins_0(_S1072, &_S1073);
    FixedArray<uint, 3>  _S1074 = _S1073;
    countShifts_0(&_S1074, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S1075 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S1076 = _S1075 != 4294967295U;
    if(_S1076)
    {
        uint2  _S1077 = make_uint2 (_S1075, _S1075 >> 14U) & make_uint2 (16383U);
        int2  _S1078 = make_int2 ((int)_S1077.x, (int)_S1077.y);
        int2  _S1079 = storedNeighbor_0(_S1078);
        uint _S1080 = _S1075 >> 28U;
        Shift _S1081 = temporalShiftAt_0(_S1078, _S1079, _S1080);
        fcptStoreTemporalShift((_S1078), (_S1080), (make_uint4 (asuint_1(_S1081.f).x, asuint_1(_S1081.f).y, asuint_1(_S1081.f).z, (F32_asuint((_S1081.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S1082 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S1083 = make_int2 ((int)_S1082.x, (int)_S1082.y);
    FixedArray<uint, 3>  _S1084;
    temporalBins_0(_S1083, &_S1084);
    FixedArray<uint, 3>  _S1085 = _S1084;
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
        bool _S1086 = (_S1085[t_20]) == 40U;
        if(_S1086)
        {
            fcptStoreTemporalShift((_S1083), (t_20), (make_uint4 (0U)));
        }
        uint t_21 = t_20 + 1U;
        t_20 = t_21;
    }
    FixedArray<uint, 3>  _S1087 = _S1085;
    queueShifts_0(_S1083, &_S1087, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S1088 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S1089 = make_int2 ((int)_S1088.x, (int)_S1088.y);
    bool _S1090 = (fcptSceneUnchanged());
    bool _S1091 = !_S1090;
    bool _S1092;
    if(_S1091)
    {
        uint2  _S1093 = (fcptRenderSize());
        int2  _S1094 = make_int2 ((int)_S1093.x, (int)_S1093.y);
        _S1092 = all_0(_S1089 < _S1094);
    }
    else
    {
        _S1092 = false;
    }
    if(_S1092)
    {
        Reservoir _S1095 = (fcptLoadReservoirInitial((_S1089)));
        int2  _S1096 = sampleNeighbor_0(_S1089, _S1095.seed);
        fcptStoreTemporalNeighbor((_S1089), (_S1096));
    }
    FixedArray<uint, 3>  _S1097;
    temporalBins_0(_S1089, &_S1097);
    FixedArray<uint, 3>  _S1098 = _S1097;
    countShifts_0(&_S1098, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_7, float b_3, float t_22)
{
    return a_7 + (b_3 - a_7) * t_22;
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S1099 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S1100 = make_int2 ((int)_S1099.x, (int)_S1099.y);
    float3  _S1101 = make_float3 (0.0f);
    FKHit _S1102 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S1103 = Domain_x24init_0(_S1101, _S1101, &_S1102, 0.0f, 0.0f);
    Domain dom_6 = _S1103;
    bool _S1104 = (fcptCurrentDomain((_S1100), (&dom_6)));
    bool _S1105 = !_S1104;
    if(_S1105)
    {
        Reservoir _S1106 = (Reservoir{});
        fcptStoreReservoirTemporal((_S1100), (_S1106), ((&dom_6)->hit));
        return;
    }
    Reservoir _S1107 = (fcptLoadReservoirInitial((_S1100)));
    bool _S1108 = (fcptTemporalQueued());
    bool _S1109 = (fcptSceneUnchanged());
    bool _S1110;
    if(_S1109)
    {
        _S1110 = true;
    }
    else
    {
        _S1110 = !_S1108;
    }
    int2  _S1111;
    if(_S1110)
    {
        int2  _S1112 = sampleNeighbor_0(_S1100, _S1107.seed);
        _S1111 = _S1112;
    }
    else
    {
        int2  _S1113 = storedNeighbor_0(_S1100);
        _S1111 = _S1113;
    }
    bool _S1114 = (_S1111.x) >= int(0);
    Reservoir r_5;
    if(_S1114)
    {
        Reservoir _S1115 = (fcptLoadReservoirPrevious((_S1111)));
        uint4  _S1116 = (fcptDuplication((_S1111)));
        float _S1117 = (U32_asfloat((_S1116.x)));
        uint _S1118 = (fcptRestirDecorrelation());
        bool _S1119 = _S1118 == 1U;
        float _S1120 = _slang_select(_S1119, _S1117,0.0f);
        float _S1121 = interpolate_0(20.0f, 1.0f, (F32_pow((_S1120), (0.10000000149011612f))));
        float _S1122 = (F32_min((_S1115.c), (_S1121)));
        bool _S1123 = (fcptSceneUnchanged());
        float4  _S1124 = make_float4 (_S1115.f.x, _S1115.f.y, _S1115.f.z, 1.0f);
        bool _S1125 = !_S1123;
        if(_S1125)
        {
            _S1110 = _S1108;
        }
        else
        {
            _S1110 = false;
        }
        float4  to_current_0;
        if(_S1110)
        {
            uint4  _S1126 = (fcptTemporalShift((_S1100), (0U)));
            float4  _S1127 = asfloat_0(_S1126);
            to_current_0 = _S1127;
        }
        else
        {
            if(_S1125)
            {
                Shift _S1128 = temporalShiftAt_0(_S1100, _S1111, 0U);
                float4  _S1129 = make_float4 (_S1128.f.x, _S1128.f.y, _S1128.f.z, _S1128.jac);
                to_current_0 = _S1129;
            }
            else
            {
                to_current_0 = _S1124;
            }
        }
        Domain own_1 = _S1103;
        if(_S1123)
        {
            _S1110 = true;
        }
        else
        {
            bool _S1130 = (fcptPreviousScenes());
            bool _S1131 = !_S1130;
            if(_S1131)
            {
                _S1110 = (_S1107.w) > 0.0f;
            }
            else
            {
                _S1110 = false;
            }
            if(_S1110)
            {
                bool _S1132 = (fcptStoredDomainInitial((_S1100), (_S1107.seed), (&own_1)));
                _S1110 = _S1132;
            }
            else
            {
                _S1110 = false;
            }
            if(_S1110)
            {
                Domain _S1133 = (fcptPreviousDomain((_S1111), (_S1107.seed)));
                Domain _S1134 = _S1133;
                Domain _S1135 = own_1;
                bool _S1136 = sameDomain_0(&_S1134, &_S1135);
                _S1110 = _S1136;
            }
            else
            {
                _S1110 = false;
            }
        }
        float4  _S1137 = make_float4 (_S1107.f.x, _S1107.f.y, _S1107.f.z, 1.0f);
        bool _S1138 = !_S1110;
        if(_S1138)
        {
            _S1110 = _S1108;
        }
        else
        {
            _S1110 = false;
        }
        float4  to_previous_0;
        if(_S1110)
        {
            uint4  _S1139 = (fcptTemporalShift((_S1100), (1U)));
            float4  _S1140 = asfloat_0(_S1139);
            to_previous_0 = _S1140;
        }
        else
        {
            if(_S1138)
            {
                Shift _S1141 = temporalShiftAt_0(_S1100, _S1111, 1U);
                float4  _S1142 = make_float4 (_S1141.f.x, _S1141.f.y, _S1141.f.z, _S1141.jac);
                to_previous_0 = _S1142;
            }
            else
            {
                to_previous_0 = _S1137;
            }
        }
        float _S1143 = resamplingTarget(_S1107.f);
        float _S1144 = resamplingTarget(_S1115.f);
        Selection _S1145 = (Selection{});
        Selection sel_6 = _S1145;
        uint _S1146 = (fcptFrame());
        uint _S1147 = hash(_S1146);
        uint _S1148 = global_invocation_id_7.x;
        uint2  _S1149 = (fcptRenderSize());
        uint _S1150 = stream(_S1147, _S1148 + _S1149.x * global_invocation_id_7.y);
        uint _S1151 = stream(_S1150, 194U);
        (&sel_6)->random_state = _S1151;
        float _S1152 = _S1107.c * _S1143;
        float4  _S1153 = to_previous_0;
        float _S1154 = resamplingTarget(float3 {_S1153.x, _S1153.y, _S1153.z});
        float _S1155 = _S1152 / (_S1152 + _S1122 * _S1154);
        float _S1156 = _S1122 * _S1144;
        float4  _S1157 = to_current_0;
        float3  _S1158 = float3 {_S1157.x, _S1157.y, _S1157.z};
        float _S1159 = resamplingTarget(_S1158);
        float _S1160 = _S1156 / (_S1156 + _S1107.c * _S1159);
        float2  _S1161 = make_float2 (_S1155, _S1160);
        offerShifted(&sel_6, _S1107, Shift_x24init_0(_S1107.f, 1.0f), _S1155);
        offerShifted(&sel_6, _S1115, Shift_x24init_0(_S1158, to_current_0.w), _S1160);
        Reservoir _S1162 = finalize(sel_6, _S1107.c + _S1122);
        r_5 = _S1162;
    }
    else
    {
        r_5 = _S1107;
    }
    fcptStoreReservoirTemporal((_S1100), (r_5), ((&dom_6)->hit));
    return;
}

__device__ uint noiseOrigin(uint2  p_16, uint k_1)
{
    uint _S1163 = ((p_16.x) >> 11U) | (((p_16.y) >> 11U) << 4U);
    uint2  _S1164 = noiseOffset(8192U + (k_1 >> 10U) + (_S1163 << 20U));
    uint2  _S1165 = (p_16 + _S1164) & make_uint2 (2047U);
    return ((_S1165.x) | ((_S1165.y) << 11U)) | ((k_1 & 1023U) << 22U);
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_6)
{
    uint _S1166 = (1U << count_6) - 1U;
    return (e_2 & (~(_S1166 << offset_1))) | ((newbits_0 & _S1166) << offset_1);
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S1167 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S1168 = make_int2 ((int)_S1167.x, (int)_S1167.y);
    float3  _S1169 = make_float3 (0.0f);
    FKHit _S1170 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S1171 = Domain_x24init_0(_S1169, _S1169, &_S1170, 0.0f, 0.0f);
    Domain dom_7 = _S1171;
    bool _S1172 = (fcptCurrentDomain((_S1168), (&dom_7)));
    bool _S1173 = !_S1172;
    if(_S1173)
    {
        Reservoir _S1174 = (Reservoir{});
        fcptStoreReservoirInitial((_S1168), (_S1174), ((&dom_7)->hit));
        return;
    }
    uint _S1175 = (fcptFrame());
    uint _S1176 = hash(_S1175);
    uint _S1177 = global_invocation_id_8.x;
    uint2  _S1178 = (fcptRenderSize());
    uint _S1179 = global_invocation_id_8.y;
    uint _S1180 = stream(_S1176, _S1177 + _S1178.x * _S1179);
    uint2  _S1181 = (fcptRenderSize());
    uint _S1182 = stream(_S1177 + _S1181.x * _S1179, 512U);
    Selection _S1183 = (Selection{});
    Selection initial_0 = _S1183;
    uint _S1184 = stream(_S1180, 193U);
    (&initial_0)->random_state = _S1184;
    bool _S1185 = (fcptRestirUsed());
    bool _S1186 = !_S1185;
    (&initial_0)->sums = _S1186;
    uint _S1187 = stream(_S1180, 0U);
    (&(&initial_0)->r)->seed = _S1187;
    FKHit _S1188 = (&dom_7)->hit;
    uint _S1189 = (fcptSamples());
    float _S1190 = 1.0f / float(_S1189);
    FKHit hit_2 = _S1188;
    uint i_18 = 0U;
    float3  seen_1 = _S1169;
    for(;;)
    {
        uint _S1191 = (fcptSamples());
        if(i_18 < _S1191)
        {
        }
        else
        {
            break;
        }
        Reservoir _S1192 = (Reservoir{});
        Reservoir r_6 = _S1192;
        uint _S1193 = (fcptFrame());
        uint _S1194 = (fcptSamples());
        uint _S1195 = _S1193 * _S1194 + i_18;
        uint _S1196 = noiseOrigin(_S1167, _S1195);
        (&r_6)->seed = _S1196;
        uint _S1197 = insertBits_0(0U, 1U, 24U, 1U);
        uint _S1198 = insertBits_0(_S1197, (_S1182 + _S1195 * 2654435769U) >> 25U, 25U, 7U);
        (&r_6)->path = _S1198;
        Domain path_0 = dom_7;
        bool _S1199 = seedDomain_0(_S1168, (&r_6)->seed, &path_0);
        bool _S1200 = !_S1199;
        if(_S1200)
        {
            float3  _S1201 = (fcptMissed((_S1168), (path_0), (_S1190)));
            float3  seen_2 = seen_1 + _S1201;
            seen_1 = seen_2;
            uint i_19 = i_18 + 1U;
            i_18 = i_19;
            continue;
        }
        Domain _S1202 = path_0;
        Reservoir _S1203 = r_6;
        Shift _S1204 = passWalk_0(&_S1202, &_S1203, false, _S1190, &initial_0);
        bool _S1205 = ((&(&initial_0)->r)->seed) == ((&r_6)->seed);
        FKHit hit_3;
        if(_S1205)
        {
            FKHit _S1206 = (&path_0)->hit;
            hit_3 = _S1206;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_19 = i_18 + 1U;
        i_18 = i_19;
    }
    uint _S1207 = (fcptSamples());
    float3  seen_3 = seen_1 + (&initial_0)->glow / make_float3 (float(_S1207));
    if((&initial_0)->sums)
    {
        seen_1 = seen_3 + (&initial_0)->color;
    }
    else
    {
        seen_1 = seen_3;
    }
    fcptAddColor((_S1168), (make_float4 (seen_1.x, seen_1.y, seen_1.z, 1.0f)));
    Reservoir _S1208 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S1168), (_S1208), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_2, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S1209;
    (&_S1209)->none = none_0;
    (&_S1209)->pdf = pdf_2;
    (&_S1209)->origin = origin_5;
    (&_S1209)->smooth_n = smooth_n_3;
    (&_S1209)->start = start_6;
    return _S1209;
}

struct Vertex
{
    bool rough;
    uint lobe;
    float pdf;
    float cos;
    bool inside;
};

static __device__ Vertex Vertex_x24init_0(bool rough_0, uint lobe_1, float pdf_3, float cos_0, bool inside_0)
{
    Vertex _S1210;
    (&_S1210)->rough = rough_0;
    (&_S1210)->lobe = lobe_1;
    (&_S1210)->pdf = pdf_3;
    (&_S1210)->cos = cos_0;
    (&_S1210)->inside = inside_0;
    return _S1210;
}

__device__ uint noiseAddress(uint origin_6, uint bounce_0)
{
    uint2  _S1211 = make_uint2 (origin_6 & 2047U, (origin_6 >> 11U) & 2047U);
    uint2  _S1212 = noiseOffset(64U + bounce_0 * 17U);
    uint2  _S1213 = (_S1211 + _S1212) & make_uint2 (2047U);
    return ((_S1213.x) | ((_S1213.y) << 11U)) | ((origin_6 >> 22U) << 22U);
}

__device__ float3  pathColor(float3  f_5, float3  weight_1, float wavelength_4)
{
    float3  _S1214;
    if(wavelength_4 > 0.0f)
    {
        float _S1215 = upsample(f_5, wavelength_4);
        _S1214 = weight_1 * make_float3 (_S1215);
    }
    else
    {
        _S1214 = f_5;
    }
    return _S1214;
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

static __device__ float3  flightWeight_0(float3  scatter_0, float3  extinction_0, float sigma_0, float distance_2, bool scatters_0)
{
    float3  _S1216 = exp_0((make_float3 (sigma_0) - extinction_0) * make_float3 (distance_2));
    float3  _S1217 = scatter_0 * _S1216 / make_float3 (sigma_0);
    float3  _S1218 = _slang_select(scatters_0, _S1217,_S1216);
    return _S1218;
}

static __device__ uint arrivalLobe_0(uint b_4, uint prev_lobe_0)
{
    bool _S1219 = b_4 > 0U;
    uint _S1220 = _slang_select(_S1219, prev_lobe_0,3U);
    return _S1220;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_2, uint lobe_2, bool surface_4, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S1221;
    (&_S1221)->extinction_behind = extinction_behind_0;
    (&_S1221)->extinction_front = extinction_front_0;
    (&_S1221)->fillings = fillings_0;
    (&_S1221)->side = side_0;
    (&_S1221)->depth = depth_2;
    (&_S1221)->lobe = lobe_2;
    (&_S1221)->surface = surface_4;
    (&_S1221)->length = length_2;
    (&_S1221)->width = width_1;
    (&_S1221)->own = *own_2;
    (&_S1221)->fiber = fiber_0;
    return _S1221;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S1222 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S1222)
    {
        return 0.07957746833562851f;
    }
    float _S1223 = g_0 * g_0;
    return (1.0f - _S1223) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S1223 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_8, float3  b_5)
{
    float3  _S1224 = a_8 / b_5;
    float3  _S1225 = make_float3 (0.0f);
    bool3  _S1226 = b_5 == _S1225;
    float3  _S1227 = _slang_select(_S1226, _S1225,_S1224);
    return _S1227;
}

__device__ Reservoir withEnd(Reservoir r_7, uint end_type_0, uint end_0, float3  f_6)
{
    Reservoir candidate_2 = r_7;
    uint _S1228 = insertBits_0(r_7.path, end_0, 0U, 5U);
    uint _S1229 = insertBits_0(_S1228, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S1229;
    (&candidate_2)->f = f_6;
    return candidate_2;
}

__device__ float survivalProbability(float3  throughput_0, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_0.x), ((F32_max((throughput_0.y), (throughput_0.z)))))) / density_1), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_4)
{
    Random _S1230 = draw(random_state_4, 11U);
    Random _S1231 = draw(random_state_4, 2147483659U);
    float _S1232 = 1.0f - 2.0f * _S1230.value;
    float _S1233 = (F32_sqrt(((F32_max((1.0f - _S1232 * _S1232), (0.0f))))));
    float _S1234 = 6.28318548202514648f * _S1231.value;
    return make_float3 (_S1233 * (F32_cos((_S1234))), _S1233 * (F32_sin((_S1234))), _S1232);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_11, uint random_state_5, float * pdf_4)
{
    bool _S1235 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1235)
    {
        *pdf_4 = 0.07957746833562851f;
        float3  _S1236 = isotropic_0(random_state_5);
        return _S1236;
    }
    Random _S1237 = draw(random_state_5, 11U);
    Random _S1238 = draw(random_state_5, 2147483659U);
    float _S1239 = g_1 * g_1;
    float _S1240 = 2.0f * g_1;
    float _S1241 = (1.0f - _S1239) / (1.0f - g_1 + _S1240 * _S1237.value);
    float _S1242 = clamp_1((1.0f + _S1239 - _S1241 * _S1241) / _S1240, -1.0f, 1.0f);
    float _S1243 = (F32_sqrt(((F32_max((1.0f - _S1242 * _S1242), (0.0f))))));
    float _S1244 = 6.28318548202514648f * _S1238.value;
    float _S1245 = phaseHG_0(g_1, _S1242);
    *pdf_4 = _S1245;
    float3  _S1246 = tangentToWorld(make_float3 (_S1243 * (F32_cos((_S1244))), _S1242, _S1243 * (F32_sin((_S1244)))), dir_11);
    float3  _S1247 = ((((_S1246)) * make_float3(rnorm3df(((_S1246)).x, ((_S1246)).y, ((_S1246)).z))));
    return _S1247;
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_1, float3  emissive_1, float roughness_0, float metallic_0, float transmission_0, float ior_1, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_1, float velvet_0, float3  toon_2, float dispersion_0, float coat_2, float coat_roughness_0, float coat_ior_0, float3  coat_tint_0, float3  coat_normal_0)
{
    BSDFMaterial _S1248;
    (&_S1248)->albedo = albedo_1;
    (&_S1248)->emissive = emissive_1;
    (&_S1248)->roughness = roughness_0;
    (&_S1248)->metallic = metallic_0;
    (&_S1248)->transmission = transmission_0;
    (&_S1248)->ior = ior_1;
    (&_S1248)->absorption = absorption_0;
    (&_S1248)->specular_tint = specular_tint_0;
    (&_S1248)->specular_level = specular_level_0;
    (&_S1248)->translucent = translucent_0;
    (&_S1248)->sheen = sheen_2;
    (&_S1248)->sheen_roughness = sheen_roughness_0;
    (&_S1248)->anisotropy = anisotropy_0;
    (&_S1248)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1248)->tangent = tangent_1;
    (&_S1248)->velvet = velvet_0;
    (&_S1248)->toon = toon_2;
    (&_S1248)->dispersion = dispersion_0;
    (&_S1248)->coat = coat_2;
    (&_S1248)->coat_roughness = coat_roughness_0;
    (&_S1248)->coat_ior = coat_ior_0;
    (&_S1248)->coat_tint = coat_tint_0;
    (&_S1248)->coat_normal = coat_normal_0;
    return _S1248;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1249;
    (&_S1249)->scatter = scatter_1;
    (&_S1249)->extinction = extinction_1;
    (&_S1249)->g = g_2;
    return _S1249;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_15, bool skip_0, uint random_state_6, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1250;
    (&_S1250)->smooth_n = smooth_n_4;
    (&_S1250)->geometry_n = geometry_n_2;
    (&_S1250)->geometry_offset = geometry_offset_2;
    (&_S1250)->material = *material_15;
    (&_S1250)->skip = skip_0;
    (&_S1250)->random_state = random_state_6;
    (&_S1250)->coverage = coverage_0;
    (&_S1250)->encloses = encloses_0;
    (&_S1250)->volume = *volume_0;
    (&_S1250)->fills = fills_0;
    (&_S1250)->hair = hair_0;
    return _S1250;
}

static __device__ FKSurface emitting_0(FKSurface * surface_5, bool top_0)
{
    FKSurface lower_0 = *surface_5;
    float3  _S1251 = (&surface_5->material)->emissive;
    float3  _S1252 = make_float3 (0.0f);
    bool _S1253 = !top_0;
    float3  _S1254 = _slang_select(_S1253, _S1252,_S1251);
    (&(&lower_0)->material)->emissive = _S1254;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_6, float u_1)
{
    float _S1255 = surface_6->coverage;
    bool _S1256 = u_1 < _S1255;
    if(_S1256)
    {
        return *surface_6;
    }
    float3  _S1257 = make_float3 (0.0f);
    float3  _S1258 = make_float3 (1.0f);
    BSDFMaterial _S1259 = Material_x24init_0(_S1257, _S1257, 0.0f, 0.0f, 0.0f, 0.0f, _S1257, _S1258, 1.0f, _S1257, _S1257, 0.5f, 0.0f, 0.0f, _S1257, 0.0f, _S1257, 0.0f, 0.0f, 0.02999999932944775f, 1.5f, _S1258, _S1257);
    BSDFMaterial material_16 = _S1259;
    (&material_16)->albedo = _S1258;
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
    bool _S1260 = transmission_1 > 0.0f;
    bool _S1261;
    if(_S1260)
    {
        _S1261 = true;
    }
    else
    {
        _S1261 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1262;
    if(_S1261)
    {
        _S1262 = 1.0f;
    }
    else
    {
        _S1262 = -1.0f;
    }
    return _S1262;
}

static __device__ bool arrivesBehind_0(float3  dir_12, float3  n_9)
{
    return (dot_0(dir_12, n_9)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_7, float3  dir_13)
{
    float3  _S1263 = surface_7->geometry_n;
    float _S1264 = facingSign((&surface_7->material)->transmission, surface_7->geometry_n, dir_13);
    FKSurface faced_0 = *surface_7;
    float3  _S1265 = surface_7->smooth_n * make_float3 (_S1264);
    (&faced_0)->smooth_n = _S1265;
    float3  _S1266 = _S1263 * make_float3 (_S1264);
    (&faced_0)->geometry_n = _S1266;
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
    float3  _S1267 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1267));
}

__device__ bool dispersive(BSDFMaterial material_17)
{
    bool _S1268 = (material_17.dispersion) > 0.0f;
    bool _S1269;
    if(_S1268)
    {
        _S1269 = (material_17.ior) != 1.0f;
    }
    else
    {
        _S1269 = false;
    }
    return _S1269;
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
        uint _S1270 = (low_1 + high_1 + 1U) / 2U;
        bool _S1271 = (WAVELENGTH_CDF_0[_S1270]) <= u_2;
        if(_S1271)
        {
            low_1 = _S1270;
        }
        else
        {
            uint _S1272 = _S1270 - 1U;
            high_1 = _S1272;
        }
    }
    uint _S1273 = low_1;
    float _S1274 = WAVELENGTH_CDF_0[low_1 + 1U] - WAVELENGTH_CDF_0[low_1];
    return make_float2 (0.37999999523162842f + 0.00499999988824129f * (float(low_1) + (u_2 - WAVELENGTH_CDF_0[_S1273]) / _S1274), _S1274 / 0.00499999988824129f);
}

__device__ static const FixedArray<float, 243>  WAVELENGTH_WEIGHTS_0 = { {
    0.00547470012679696f, -0.00465690018609166f, 0.03257500007748604f, 0.00934640038758516f, -0.00796370021998882f, 0.05577300116419792f, 0.01846100017428398f, -0.01579399965703487f, 0.11072999984025955f, 0.0416410006582737f, -0.03577499836683273f, 0.2513900101184845f, 0.09349299967288971f, -0.08071800321340561f, 0.56742000579833984f, 0.1585099995136261f, -0.13764999806880951f, 0.97018998861312866f, 0.30943000316619873f, -0.27083000540733337f, 1.91740000247955322f, 0.55217999219894409f, -0.48754000663757324f, 3.46889996528625488f, 0.95016998052597046f, -0.84802001714706421f, 6.09439992904663086f, 1.42110002040863037f, -1.28929996490478516f, 9.45199966430664062f, 1.73409998416900635f, -1.6062999963760376f, 12.12800025939941406f, 2.08030009269714355f, -1.98810005187988281f, 15.68700027465820312f, 2.20600008964538574f, -2.20120000839233398f, 18.47699928283691406f, 2.03040003776550293f, -2.17700004577636719f, 19.92700004577636719f, 1.63429999351501465f, -2.00340008735656738f, 20.86899948120117188f, 0.99410998821258545f, -1.62629997730255127f, 20.57799911499023438f, 0.20011000335216522f, -1.11409997940063477f, 19.72100067138671875f, -0.67960000038146973f, -0.45403000712394714f, 17.77599906921386719f, -1.61679995059967041f, 0.37860000133514404f, 14.71500015258789062f, -2.53410005569458008f, 1.27540004253387451f, 11.86499977111816406f, -3.39079999923706055f, 2.2146000862121582f, 9.17669963836669922f, -4.03749990463256836f, 3.0522000789642334f, 6.59509992599487305f, -4.61299991607666016f, 3.89779996871948242f, 4.64589977264404297f, -5.43039989471435547f, 5.0121002197265625f, 3.3199000358581543f, -6.37769985198974609f, 6.33809995651245117f, 2.29699993133544922f, -7.44140005111694336f, 7.91739988327026367f, 1.45389997959136963f, -8.38580036163330078f, 9.60109996795654297f, 0.66465997695922852f, -9.0167999267578125f, 11.23999977111816406f, -0.04403600096702576f, -9.17749977111816406f, 12.63199996948242188f, -0.58126997947692871f, -8.97550010681152344f, 13.91499996185302734f, -0.95730000734329224f, -8.25290012359619141f, 14.86200046539306641f, -1.24430000782012939f, -6.92129993438720703f, 15.03899955749511719f, -1.43069994449615479f, -5.29169988632202148f, 14.90900039672851562f, -1.55149996280670166f, -3.43219995498657227f, 14.70499992370605469f, -1.63569998741149902f, -1.27190005779266357f, 14.24400043487548828f, -1.67030000686645508f, 1.15170001983642578f, 13.32199954986572266f, -1.636199951171875f, 3.73889994621276855f, 12.21199989318847656f, -1.56920003890991211f, 6.43590021133422852f, 10.94699954986572266f, -1.47730004787445068f, 9.16440010070800781f, 9.54769992828369141f, -1.36399996280670166f, 12.02000045776367188f, 8.18799972534179688f, -1.25450003147125244f, 14.78699970245361328f, 6.74429988861083984f, -1.13110005855560303f, 16.72299957275390625f, 5.08780002593994141f, -0.96561002731323242f, 18.14299964904785156f, 3.57019996643066406f, -0.80725997686386108f, 19.91900062561035156f, 2.36269998550415039f, -0.69273000955581665f, 21.05500030517578125f, 1.31369996070861816f, -0.58597999811172485f, 21.3899993896484375f, 0.42390000820159912f, -0.48298001289367676f, 20.99300003051757812f, -0.23857000470161438f, -0.39412000775337219f, 19.82200050354003906f, -0.6866300106048584f, -0.31501999497413635f, 18.12000083923339844f, -0.9412500262260437f, -0.24890999495983124f, 15.7089996337890625f, -1.02020001411437988f, -0.19076000154018402f, 13.19799995422363281f, -0.98919999599456787f, -0.14401000738143921f, 11.23999977111816406f, -0.93347001075744629f, -0.11133000254631042f, 9.36649990081787109f, -0.83820998668670654f, -0.08524099737405777f, 7.41249990463256836f, -0.70064002275466919f, -0.06283199787139893f, 5.71229982376098633f, -0.56079000234603882f, -0.04586699977517128f, 4.42280006408691406f, -0.44653001427650452f, -0.03396600112318993f, 3.34489989280700684f, -0.34457001090049744f, -0.02482499927282333f, 2.49309992790222168f, -0.26017999649047852f, -0.01808100007474422f, 1.82239997386932373f, -0.1921599954366684f, -0.01296999957412481f, 1.29499995708465576f, -0.13766999542713165f, -0.00907570030540228f, 0.92928999662399292f, -0.09956400096416473f, -0.00641620019450784f, 0.61835998296737671f, -0.06671299785375595f, -0.00421149982139468f, 0.40211999416351318f, -0.04354599863290787f, -0.00271830009296536f, 0.2844499945640564f, -0.03087200038135052f, -0.00191440002527088f, 0.20672999322414398f, -0.02246100082993507f, -0.00138829997740686f, 0.15044000744819641f, -0.01634499989449978f, -0.00101030000951141f, 0.10942000150680542f, -0.01188699994236231f, -0.0007347899954766f, 0.07099699974060059f, -0.00771349994465709f, -0.00047679000999779f, 0.04539500176906586f, -0.00493190018460155f, -0.00030484999297187f, 0.03424099832773209f, -0.00372010003775358f, -0.00022995000472292f, 0.02557599917054176f, -0.00277870008721948f, -0.00017175999528263f, 0.01842200011014938f, -0.00200140010565519f, -0.0001237099932041f, 0.01316899992525578f, -0.00143079995177686f, -0.00008843900286593f, 0.00838890019804239f, -0.00091141002485529f, -0.00005633700129692f, 0.00537079991772771f, -0.00058350997278467f, -0.00003606799873523f, 0.00328280008397996f, -0.00035665999166667f, -0.00002204600059486f, 0.00196009990759194f, -0.00021296000340953f, -0.00001316300040344f, 0.00168939994182438f, -0.00018354000349063f, -0.00001134499962063f, 0.00141050003003329f, -0.00015325000276789f, -0.00000947250009631f, 0.00097123999148607f, -0.00010551999730524f, -6.52239987175562419e-06f, 0.00066868000430986f, -0.00007264900341397f, -4.49060007667867467e-06f
} };
__device__ float3  wavelengthWeights(float wavelength_5)
{
    float _S1275 = clamp_1((wavelength_5 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    uint _S1276 = (U32_min((uint(_S1275)), (79U)));
    uint _S1277 = 3U * _S1276;
    float3  _S1278 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1277], WAVELENGTH_WEIGHTS_0[_S1277 + 1U], WAVELENGTH_WEIGHTS_0[_S1277 + 2U]);
    float3  _S1279 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1277 + 3U], WAVELENGTH_WEIGHTS_0[_S1277 + 4U], WAVELENGTH_WEIGHTS_0[_S1277 + 5U]);
    return _S1278 + (_S1279 - _S1278) * make_float3 (_S1275 - float(_S1276));
}

__device__ float dispersedIor(float ior_2, float dispersion_1, float wavelength_6)
{
    float _S1280 = (ior_2 - 1.0f) * dispersion_1 / 1.90962409973144531f;
    float _S1281 = _S1280 * (1.0f / (wavelength_6 * wavelength_6) - 2.89662933349609375f);
    bool _S1282 = dispersion_1 > 0.0f;
    float _S1283 = _slang_select(_S1282, _S1281,0.0f);
    return ior_2 + _S1283;
}

__device__ float2  vertexEta(BSDFMaterial material_18, float n_dot_v_0)
{
    bool _S1284 = n_dot_v_0 < 0.0f;
    float _S1285 = _slang_select(_S1284, material_18.ior,1.0f);
    float _S1286 = _slang_select(_S1284, 1.0f,material_18.ior);
    return make_float2 (_S1285, _S1286);
}

__device__ float2  wavelengthEta(BSDFMaterial material_19, float n_dot_v_1, float wavelength_7)
{
    BSDFMaterial refractive_0 = material_19;
    float _S1287 = dispersedIor(material_19.ior, material_19.dispersion, wavelength_7);
    bool _S1288 = wavelength_7 > 0.0f;
    float _S1289 = _slang_select(_S1288, _S1287,material_19.ior);
    (&refractive_0)->ior = _S1289;
    float2  _S1290 = vertexEta(refractive_0, n_dot_v_1);
    return _S1290;
}

static __device__ float unshared_0(float x_25)
{
    return x_25;
}

__device__ float3  sampleGGXVNDF(float3  Ve_0, float alpha_6, float U1_0, float U2_0)
{
    float3  _S1291 = make_float3 (alpha_6 * Ve_0.x, alpha_6 * Ve_0.y, Ve_0.z);
    float3  _S1292 = ((((_S1291)) * make_float3(rnorm3df(((_S1291)).x, ((_S1291)).y, ((_S1291)).z))));
    float _S1293 = _S1292.x;
    float _S1294 = _S1292.y;
    float _S1295 = _S1293 * _S1293 + _S1294 * _S1294;
    float3  _S1296;
    if(_S1295 > 0.0f)
    {
        float3  _S1297 = make_float3 (- _S1294, _S1293, 0.0f);
        float _S1298 = (rsqrtf((_S1295)));
        _S1296 = _S1297 * make_float3 (_S1298);
    }
    else
    {
        _S1296 = make_float3 (1.0f, 0.0f, 0.0f);
    }
    float3  _S1299 = cross_0(_S1292, _S1296);
    float _S1300 = (F32_sqrt((U1_0)));
    float _S1301 = 6.28318548202514648f * U2_0;
    float _S1302 = _S1300 * (F32_cos((_S1301)));
    float t2_0 = _S1300 * (F32_sin((_S1301)));
    float _S1303 = 0.5f * (1.0f + _S1292.z);
    float t2_1 = (1.0f - _S1303) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S1302 * _S1302)))))) + _S1303 * t2_0;
    float3  _S1304 = make_float3 (_S1302) * _S1296 + make_float3 (t2_1) * _S1299;
    float _S1305 = unshared_0(_S1302);
    float _S1306 = unshared_0(_S1302);
    float3  _S1307 = _S1304 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S1305 * _S1306 - t2_1 * t2_1))))))) * _S1292;
    float3  _S1308 = make_float3 (alpha_6 * _S1307.x, alpha_6 * _S1307.y, (F32_max((0.0f), (_S1307.z))));
    float3  _S1309 = ((((_S1308)) * make_float3(rnorm3df(((_S1308)).x, ((_S1308)).y, ((_S1308)).z))));
    return _S1309;
}

__device__ float3  worldToTangent(float3  v_8, float3  n_10)
{
    float3  a_9 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S1310 = (F32_abs((dot_0(n_10, a_9)))) > 0.9999847412109375f;
    float3  a_10;
    if(_S1310)
    {
        float3  _S1311 = make_float3 (1.0f, 0.0f, 0.0f);
        a_10 = _S1311;
    }
    else
    {
        a_10 = a_9;
    }
    float3  _S1312 = cross_0(n_10, a_10);
    float3  _S1313 = ((((_S1312)) * make_float3(rnorm3df(((_S1312)).x, ((_S1312)).y, ((_S1312)).z))));
    float3  _S1314 = cross_0(n_10, _S1313);
    return make_float3 (dot_0(v_8, _S1313), dot_0(v_8, n_10), dot_0(v_8, _S1314));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_9, float3  n_i_11, float alpha_7, AnisotropicFrame frame_5, uint * random_state_7, uint first_2)
{
    Random _S1315 = draw(*random_state_7, first_2);
    Random _S1316 = draw(*random_state_7, first_2 | 2147483648U);
    *random_state_7 = _S1316.state;
    float _S1317 = frame_5.alphas.x;
    bool _S1318 = _S1317 > 0.0f;
    if(_S1318)
    {
        float3  _S1319 = anisotropicLocal(v_9, frame_5.tangent, n_i_11);
        float _S1320 = frame_5.alphas.y;
        float3  _S1321 = make_float3 (_S1317 * _S1319.x, _S1320 * _S1319.y, _S1319.z);
        float3  _S1322 = ((((_S1321)) * make_float3(rnorm3df(((_S1321)).x, ((_S1321)).y, ((_S1321)).z))));
        float3  _S1323 = sampleGGXVNDF(_S1322, 1.0f, _S1315.value, _S1316.value);
        float3  _S1324 = make_float3 (_S1317 * _S1323.x, _S1320 * _S1323.y, _S1323.z);
        float3  _S1325 = ((((_S1324)) * make_float3(rnorm3df(((_S1324)).x, ((_S1324)).y, ((_S1324)).z))));
        return make_float3 (_S1325.x) * frame_5.tangent + make_float3 (_S1325.y) * cross_0(n_i_11, frame_5.tangent) + make_float3 (_S1325.z) * n_i_11;
    }
    float3  _S1326 = worldToTangent(v_9, n_i_11);
    float3  _S1327 = sampleGGXVNDF(float3 {_S1326.x, _S1326.z, _S1326.y}, alpha_7, _S1315.value, _S1316.value);
    float3  _S1328 = float3 {_S1327.x, _S1327.z, _S1327.y};
    float3  _S1329 = tangentToWorld(_S1328, n_i_11);
    return _S1329;
}

__device__ __forceinline__ float3  coatHalf(float3  v_10, CoatFrame coat_frame_4, uint random_state_8)
{
    bool _S1330 = !((dot_0(coat_frame_4.normal, v_10)) > 0.0f);
    if(_S1330)
    {
        return make_float3 (0.0f);
    }
    uint state_2 = random_state_8;
    float3  _S1331 = sampleHalfVector(v_10, coat_frame_4.normal, coat_frame_4.alpha, AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f)), &state_2, 1U);
    return _S1331;
}

static __device__ Facets Facets_x24init_0(float3  h_3, float3  coat_h_3)
{
    Facets _S1332;
    (&_S1332)->h = h_3;
    (&_S1332)->coat_h = coat_h_3;
    return _S1332;
}

__device__ Facets drawFacets(float3  in_dir_5, float3  n_11, BSDFMaterial material_20, uint random_state_9)
{
    float3  _S1333 = negate_0(in_dir_5);
    float _S1334 = sign_0(dot_0(n_11, _S1333));
    float3  _S1335 = n_11 * make_float3 (_S1334);
    uint state_3 = random_state_9;
    float _S1336 = material_20.roughness;
    float _S1337 = _S1336 * _S1336;
    AnisotropicFrame _S1338 = anisotropicFrame(material_20, _S1335);
    float3  _S1339 = sampleHalfVector(_S1333, _S1335, _S1337, _S1338, &state_3, 0U);
    CoatFrame _S1340 = coatFrame(material_20, _S1335);
    float3  _S1341 = coatHalf(_S1333, _S1340, random_state_9);
    return Facets_x24init_0(_S1339, _S1341);
}

__device__ bool neeDecision(BSDFMaterial material_21, float n_dot_v_2, float eta_i_5, float eta_o_4)
{
    float _S1342 = fresnel((F32_abs((n_dot_v_2))), eta_i_5, eta_o_4);
    float3  _S1343 = mix_0(make_float3 (_S1342), material_21.albedo, material_21.metallic);
    float _S1344 = rgb_to_greyscale(_S1343);
    float _S1345 = (F32_max(((1.0f - _S1344) * (1.0f - material_21.metallic) * (1.0f - material_21.transmission)), (0.0f)));
    bool _S1346 = _S1345 > 0.03999999910593033f;
    bool _S1347;
    if(_S1346)
    {
        _S1347 = true;
    }
    else
    {
        _S1347 = (material_21.roughness) > 0.20000000298023224f;
    }
    return _S1347;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_22)
{
    float _S1348 = rgb_to_greyscale(material_22->translucent);
    return _S1348 > 0.0f;
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
    MediumSides _S1349;
    (&_S1349)->behind = *behind_1;
    (&_S1349)->front = *front_0;
    (&_S1349)->fillings = fillings_1;
    (&_S1349)->face = face_1;
    return _S1349;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_8, FKMedium * medium_0, uint filling_0, float3  dir_14, FKMedium * outside_0)
{
    float3  _S1350 = surface_8->geometry_n;
    MediumSides _S1351 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_8->geometry_n);
    MediumSides sides_0 = _S1351;
    bool _S1352 = surface_8->encloses;
    if(_S1352)
    {
        (&sides_0)->behind = surface_8->volume;
        *&((&(&sides_0)->fillings)->x) = surface_8->fills;
        bool _S1353 = (dot_0(dir_14, _S1350)) > 0.0f;
        if(_S1353)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_9, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_15, uint depth_3, uint lobe_3, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1354 = surface_9->geometry_n;
    ShadowContext _S1355 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_9->geometry_n, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
    bool _S1356 = surface_9->encloses;
    ShadowContext context_4;
    if(_S1356)
    {
        FKSurface faced_1 = *surface_9;
        float3  _S1357 = - _S1354;
        float3  _S1358 = _slang_select(turned_0, _S1357,_S1354);
        (&faced_1)->geometry_n = _S1358;
        FKMedium _S1359 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1360 = faced_1;
        FKMedium _S1361 = _S1359;
        MediumSides _S1362 = mediumSides_0(&_S1360, &_S1361, filling_1, dir_15, outside_1);
        ShadowContext _S1363 = ShadowContext_x24init_0(_S1362.behind.extinction, _S1362.front.extinction, _S1362.fillings, _S1354, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
        if(turned_0)
        {
            uint2  _S1364 = _S1362.fillings;
            ShadowContext _S1365 = ShadowContext_x24init_0(_S1362.front.extinction, _S1362.behind.extinction, uint2 {_S1364.y, _S1364.x}, _S1354, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
            context_4 = _S1365;
        }
        else
        {
            context_4 = _S1363;
        }
    }
    else
    {
        context_4 = _S1355;
    }
    return context_4;
}

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_6, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_3, BSDFMaterial * material_23, float eta_i_6, float eta_o_5, bool competing_1, Facets * facets_3)
{
    float3  _S1366 = light_2->dir;
    bool _S1367 = (dot_0(geometry_n_3, - in_dir_6) * dot_0(geometry_n_3, light_2->dir)) <= 0.0f;
    FixedArray<float3 , 6>  throughputs_1;
    FixedArray<float, 6>  pdfs_4;
    BSDF(in_dir_6, _S1366, smooth_n_5, *material_23, eta_i_6, eta_o_5, _S1367, *facets_3, &throughputs_1, &pdfs_4);
    bool _S1368;
    if(competing_1)
    {
        _S1368 = (light_2->density) != 0.0f;
    }
    else
    {
        _S1368 = false;
    }
    float3  _S1369 = make_float3 (0.0f);
    uint i_23 = 0U;
    float3  f_7 = _S1369;
    for(;;)
    {
        if(i_23 < 6U)
        {
        }
        else
        {
            break;
        }
        bool _S1370 = (pdfs_4[i_23]) > 0.0f;
        if(_S1370)
        {
            float3  f_8;
            if(_S1368)
            {
                float _S1371 = light_2->density;
                float _S1372 = pdfs_4[i_23] / light_2->density;
                float3  f_9 = f_7 + throughputs_1[i_23] * make_float3 (pdfs_4[i_23]) / make_float3 (_S1371 * (1.0f + _S1372 * _S1372));
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
    if(_S1368)
    {
        f_7 = f_7 * light_2->radiance * make_float3 (light_2->density);
    }
    else
    {
        f_7 = f_7 * light_2->radiance;
    }
    return f_7;
}

__device__ float3  skyBSDF(float3  in_dir_7, float3  dir_16, FKSurface surface_10, BSDFMaterial material_24, float2  eta_3, bool is_inside_4, Facets facets_4, float pdf_5)
{
    FKSurface _S1373 = surface_10;
    BSDFMaterial _S1374 = material_24;
    Facets _S1375 = facets_4;
    FixedArray<float3 , 6>  terms_3;
    FixedArray<float, 6>  pdfs_5;
    float3  _S1376 = skyLobes_0(in_dir_7, dir_16, &_S1373, &_S1374, eta_3, is_inside_4, &_S1375, pdf_5, &terms_3, &pdfs_5);
    return _S1376;
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_1, uint random_state_10, bool refracted_3, uint lobe_4, float pdf_6)
{
    SampleBSDF _S1377;
    (&_S1377)->unit_direction = unit_direction_1;
    (&_S1377)->throughput = throughput_1;
    (&_S1377)->random_state = random_state_10;
    (&_S1377)->refracted = refracted_3;
    (&_S1377)->lobe = lobe_4;
    (&_S1377)->pdf = pdf_6;
    return _S1377;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  v_11, float3  n_i_12, float n_i_dot_v_3, BSDFMaterial material_25, Weights w_14, uint random_state_11)
{
    float3  _S1378 = make_float3 (1.0f);
    SampleBSDF _S1379 = SampleBSDF_x24init_0(_S1378, _S1378, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S1379;
    Random _S1380 = draw(random_state_11, 3U);
    Random _S1381 = draw(random_state_11, 2147483651U);
    (&sample_1)->random_state = _S1381.state;
    float _S1382 = _S1380.value;
    float _S1383 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1382 * _S1382))))));
    float _S1384 = 6.28318548202514648f * _S1381.value;
    float3  _S1385 = tangentToWorld(make_float3 (_S1383 * (F32_cos((_S1384))), _S1380.value, _S1383 * (F32_sin((_S1384)))), n_i_12);
    (&sample_1)->unit_direction = _S1385;
    (&sample_1)->lobe = 4U;
    float3  _S1386 = sheenVelvetBSDF((&sample_1)->unit_direction, v_11, n_i_12, material_25, w_14);
    (&sample_1)->throughput = _S1386;
    float _S1387 = sheenVelvetPDF(_S1380.value, n_i_dot_v_3, w_14);
    (&sample_1)->pdf = _S1387;
    return sample_1;
}

__device__ __forceinline__ SampleBSDF coatSample(float3  in_dir_8, float3  v_12, float3  coat_h_4, CoatFrame coat_frame_5, Weights w_15, uint random_state_12)
{
    float3  _S1388 = make_float3 (1.0f);
    SampleBSDF _S1389 = SampleBSDF_x24init_0(_S1388, _S1388, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S1389;
    float3  _S1390 = reflect_0(in_dir_8, coat_h_4);
    float3  _S1391 = ((((_S1390)) * make_float3(rnorm3df(((_S1390)).x, ((_S1390)).y, ((_S1390)).z))));
    (&sample_2)->unit_direction = _S1391;
    (&sample_2)->random_state = random_state_12;
    (&sample_2)->lobe = 5U;
    float3  _S1392 = coatBSDF(w_15);
    (&sample_2)->throughput = _S1392;
    float _S1393 = coatPDF(v_12, coat_h_4, coat_frame_5, w_15);
    (&sample_2)->pdf = _S1393;
    return sample_2;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1394 = (F32_sqrt((random_1_0)));
    float _S1395 = 6.28318548202514648f * random_2_0;
    float _S1396 = _S1394 * (F32_cos((_S1395)));
    float _S1397 = _S1394 * (F32_sin((_S1395)));
    float _S1398 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1396 * _S1396 - _S1397 * _S1397))))));
    return make_float3 (_S1396, _S1398, _S1397);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_3, float3  n_i_13, float n_i_dot_v_4, BSDFMaterial material_26, Weights w_16, uint random_state_13)
{
    float3  _S1399 = make_float3 (1.0f);
    SampleBSDF _S1400 = SampleBSDF_x24init_0(_S1399, _S1399, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S1400;
    Random _S1401 = draw(random_state_13, 3U);
    Random _S1402 = draw(random_state_13, 2147483651U);
    (&sample_3)->random_state = _S1402.state;
    float3  _S1403 = sampleCosWeightedHemisphere(_S1401.value, _S1402.value);
    float _S1404 = translucentShare(material_26);
    bool _S1405 = u_3 < (w_16.p_diffuse * _S1404);
    float _S1406 = _S1403.y;
    float _S1407 = - _S1406;
    float _S1408 = _slang_select(_S1405, _S1407,_S1406);
    float3  _S1409 = tangentToWorld(make_float3 (_S1403.x, _S1408, _S1403.z), n_i_13);
    (&sample_3)->unit_direction = _S1409;
    (&sample_3)->refracted = _S1405;
    (&sample_3)->lobe = 0U;
    float3  _S1410 = diffuseBSDF((&sample_3)->unit_direction, n_i_13, material_26, w_16);
    (&sample_3)->throughput = _S1410;
    float _S1411 = diffusePDF(_S1408, n_i_dot_v_4, material_26, w_16);
    (&sample_3)->pdf = _S1411;
    return sample_3;
}

__device__ __forceinline__ SampleBSDF toonSample(float3  n_i_14, ToonProfile profile_3, Weights w_17, uint random_state_14)
{
    float3  _S1412 = make_float3 (1.0f);
    SampleBSDF _S1413 = SampleBSDF_x24init_0(_S1412, _S1412, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S1413;
    Random _S1414 = draw(random_state_14, 3U);
    Random _S1415 = draw(random_state_14, 2147483651U);
    (&sample_4)->random_state = _S1415.state;
    float _S1416 = _S1414.value * profile_3.norm / 6.28318548202514648f;
    float t_23;
    if(profile_3.glossy)
    {
        t_23 = (F32_acos((clamp_1(1.0f - _S1416, -1.0f, 1.0f))));
    }
    else
    {
        t_23 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1416)))), (1.0f))))));
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
        float _S1417 = toonP(t_23, profile_3.a, profile_3.s);
        float _S1418 = _S1417 * (F32_sin((t_23)));
        float _S1419;
        if(profile_3.glossy)
        {
            _S1419 = 1.0f;
        }
        else
        {
            _S1419 = (F32_cos((t_23)));
        }
        float _S1420 = _S1418 * _S1419;
        float _S1421 = toonIntegral(t_23, profile_3.a, profile_3.s, profile_3.glossy);
        float _S1422 = (_S1421 - _S1416) / _S1420;
        bool _S1423 = _S1420 > 0.0f;
        float _S1424 = _slang_select(_S1423, _S1422,0.0f);
        float _S1425 = clamp_1(t_23 - _S1424, 0.0f, profile_3.b);
        int k_3 = k_2 + int(1);
        t_23 = _S1425;
        k_2 = k_3;
    }
    float _S1426 = 6.28318548202514648f * _S1415.value;
    float _S1427 = (F32_sin((t_23)));
    float3  _S1428 = tangentToWorld(make_float3 (_S1427 * (F32_cos((_S1426))), (F32_cos((t_23))), _S1427 * (F32_sin((_S1426)))), profile_3.axis);
    (&sample_4)->unit_direction = _S1428;
    bool _S1429 = (dot_0(n_i_14, (&sample_4)->unit_direction)) < 0.0f;
    (&sample_4)->refracted = _S1429;
    (&sample_4)->lobe = 6U;
    float3  _S1430 = toonBSDF((&sample_4)->unit_direction, n_i_14, profile_3, w_17);
    (&sample_4)->throughput = _S1430;
    float _S1431 = toonPDF((&sample_4)->unit_direction, n_i_14, profile_3, w_17);
    (&sample_4)->pdf = _S1431;
    return sample_4;
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_1, float3  n_i_15, float alpha_8, AnisotropicFrame frame_6, BSDFMaterial material_27, Weights w_18, float pdf_h_3, float eta_i_7, float eta_o_6, uint random_state_15)
{
    float3  _S1432 = make_float3 (1.0f);
    SampleBSDF _S1433 = SampleBSDF_x24init_0(_S1432, _S1432, 0U, false, 0U, 0.0f);
    SampleBSDF sample_5 = _S1433;
    (&sample_5)->unit_direction = w_18.refracted;
    (&sample_5)->random_state = random_state_15;
    (&sample_5)->refracted = true;
    (&sample_5)->lobe = 1U;
    float3  _S1434 = refractBSDF((&sample_5)->unit_direction, n_i_15, alpha_8, frame_6, material_27, w_18);
    (&sample_5)->throughput = _S1434;
    float _S1435 = refractPDF(dot_0((&sample_5)->unit_direction, ggx_n_1), pdf_h_3, w_18, eta_i_7, eta_o_6);
    (&sample_5)->pdf = _S1435;
    return sample_5;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_9, float3  ggx_n_2, float3  n_i_16, float alpha_9, AnisotropicFrame frame_7, Weights w_19, float pdf_h_4, uint random_state_16)
{
    float3  _S1436 = make_float3 (1.0f);
    SampleBSDF _S1437 = SampleBSDF_x24init_0(_S1436, _S1436, 0U, false, 0U, 0.0f);
    SampleBSDF sample_6 = _S1437;
    float3  _S1438 = reflect_0(in_dir_9, ggx_n_2);
    float3  _S1439 = ((((_S1438)) * make_float3(rnorm3df(((_S1438)).x, ((_S1438)).y, ((_S1438)).z))));
    (&sample_6)->unit_direction = _S1439;
    (&sample_6)->random_state = random_state_16;
    (&sample_6)->lobe = 2U;
    float3  _S1440 = reflectBSDF((&sample_6)->unit_direction, n_i_16, alpha_9, frame_7, w_19);
    (&sample_6)->throughput = _S1440;
    float _S1441 = reflectPDF(pdf_h_4, w_19);
    (&sample_6)->pdf = _S1441;
    return sample_6;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_10, float3  n_12, BSDFMaterial material_28, float eta_i_8, float eta_o_7, Facets facets_5, uint random_init_0, float2  screen_space_0)
{
    float3  _S1442 = negate_0(in_dir_10);
    float _S1443 = dot_0(n_12, _S1442);
    float _S1444 = sign_0(_S1443);
    float3  n_i_17 = n_12 * make_float3 (_S1444);
    float _S1445 = (F32_abs((_S1443)));
    float _S1446 = material_28.roughness;
    float _S1447 = _S1446 * _S1446;
    AnisotropicFrame _S1448 = anisotropicFrame(material_28, n_i_17);
    SheenProfile _S1449 = sheenProfile(_S1442, n_i_17, material_28);
    CoatFrame _S1450 = coatFrame(material_28, n_i_17);
    float3  _S1451 = coatSeries(_S1450, material_28);
    Weights _S1452 = lobeWeights(in_dir_10, _S1442, n_i_17, facets_5.h, facets_5.coat_h, facets_5.h, facets_5.coat_h, _S1448, _S1449, _S1450, _S1451, material_28, eta_i_8, eta_o_7);
    Random _S1453 = draw(random_init_0, 2U);
    bool _S1454 = (_S1453.value) < (_S1452.p_sheen_velvet);
    if(_S1454)
    {
        SampleBSDF _S1455 = sheenVelvetSample(_S1442, n_i_17, _S1445, material_28, _S1452, _S1453.state);
        return _S1455;
    }
    float _S1456 = _S1453.value - _S1452.p_sheen_velvet;
    bool _S1457 = _S1456 < (_S1452.p_coat);
    if(_S1457)
    {
        SampleBSDF _S1458 = coatSample(in_dir_10, _S1442, facets_5.coat_h, _S1450, _S1452, _S1453.state);
        return _S1458;
    }
    float _S1459 = _S1456 - _S1452.p_coat;
    bool _S1460 = _S1459 < (_S1452.p_diffuse);
    if(_S1460)
    {
        SampleBSDF _S1461 = diffuseSample(_S1459, n_i_17, _S1445, material_28, _S1452, _S1453.state);
        return _S1461;
    }
    bool _S1462 = _S1459 < (_S1452.p_diffuse + _S1452.p_toon);
    if(_S1462)
    {
        ToonProfile _S1463 = toonProfile(_S1442, n_i_17, material_28);
        SampleBSDF _S1464 = toonSample(n_i_17, _S1463, _S1452, _S1453.state);
        return _S1464;
    }
    float _S1465 = vndfPDF(_S1442, facets_5.h, n_i_17, _S1445, _S1447, _S1448, _S1452.v_dot_h);
    bool _S1466 = (_S1459 - _S1452.p_toon) < (_S1452.p_diffuse + _S1452.p_refract);
    if(_S1466)
    {
        SampleBSDF _S1467 = refractSample(facets_5.h, n_i_17, _S1447, _S1448, material_28, _S1452, _S1465, eta_i_8, eta_o_7, _S1453.state);
        return _S1467;
    }
    SampleBSDF _S1468 = reflectSample(in_dir_10, facets_5.h, n_i_17, _S1447, _S1448, _S1452, _S1465, _S1453.state);
    return _S1468;
}

__device__ __forceinline__ float3  reflectedHalf(float3  in_dir_11, float3  out_dir_1)
{
    float3  _S1469 = negate_0(in_dir_11);
    float3  _S1470 = _S1469 + out_dir_1;
    float3  _S1471 = ((((_S1470)) * make_float3(rnorm3df(((_S1470)).x, ((_S1470)).y, ((_S1470)).z))));
    return _S1471;
}

__device__ __forceinline__ float3  refractedHalf(float3  in_dir_12, float3  out_dir_2, float3  n_13, float eta_i_9, float eta_o_8)
{
    float3  _S1472 = negate_0(in_dir_12);
    float3  _S1473 = negate_0(make_float3 (eta_i_9) * _S1472 + make_float3 (eta_o_8) * out_dir_2);
    float3  _S1474 = ((((_S1473)) * make_float3(rnorm3df(((_S1473)).x, ((_S1473)).y, ((_S1473)).z))));
    float _S1475 = sign_0(dot_0(n_13, _S1472));
    float _S1476 = sign_0(dot_0(_S1473, n_13 * make_float3 (_S1475)));
    return _S1474 * make_float3 (_S1476);
}

static __device__ bool boundsVolume_0(FKSurface * surface_11)
{
    return surface_11->encloses;
}

static __device__ Shift walk_0(Domain * dom_8, Reservoir * r_8, bool replay_1, float scale_3, Selection * sel_7)
{
    float spread_1;
    bool turned_1;
    bool is_inside_5;
    bool viewed_0;
    bool _S1477;
    bool _S1478;
    float density_2;
    float wavelength_8;
    float width_3;
    float sky_pdf_0;
    float threshold_0;
    uint b_6;
    uint layer_0;
    float3  throughput_2;
    float3  spectral_weight_0;
    TreeSample light_3;
    int _S1479;
    Shift ended_0;
    float density_3;
    float spread_2;
    float width_4;
    float sky_pdf_1;
    float spread_3;
    float width_5;
    uint b_7;
    float3  _S1480 = make_float3 (0.0f);
    Shift _S1481 = Shift_x24init_0(_S1480, 0.0f);
    uint _S1482 = r_8->path;
    uint _S1483 = extractBits_0(r_8->path, 0U, 5U);
    uint _S1484 = extractBits_0(_S1482, 5U, 5U);
    uint _S1485 = extractBits_0(_S1482, 10U, 2U);
    uint _S1486 = extractBits_0(_S1482, 12U, 3U);
    bool passes_0;
    if(replay_1)
    {
        bool _S1487 = _S1486 >= 3U;
        uint _S1488 = _slang_select(_S1487, 1U,0U);
        uint _S1489 = _S1483 + _S1488;
        uint _S1490 = (fcptMaxBounces());
        passes_0 = _S1489 > _S1490;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1481;
    }
    uint _S1491 = _S1484 - 1U;
    bool _S1492 = _S1486 == 3U;
    uint _S1493 = _slang_select(_S1492, 1U,0U);
    uint _S1494 = _S1483 + _S1493;
    bool _S1495 = _S1485 == 0U;
    uint _S1496 = _slang_select(_S1495, _S1494,_S1491);
    FKHit _S1497 = (fcptReservoirHit((*r_8)));
    float3  _S1498 = dom_8->x0;
    float3  _S1499 = dom_8->x1 - dom_8->x0;
    float3  _S1500 = ((((_S1499)) * make_float3(rnorm3df(((_S1499)).x, ((_S1499)).y, ((_S1499)).z))));
    FKRay _S1501 = Ray_x24init_0(dom_8->x1, _S1500);
    FKRay ray_2 = _S1501;
    FKHit hit_4 = dom_8->hit;
    float3  scatter_in_0 = _S1480;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_2 = throughput_3;
    float3  glowed_0 = _S1480;
    float3  extinction_in_0 = _S1480;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1502 = dom_8->spread;
    float _S1503 = dom_8->width;
    float _S1504 = length_0(_S1499);
    NEEVertex _S1505 = NEEVertex_x24init_0(true, 0.0f, _S1480, _S1480, _S1480);
    NEEVertex nee_vertex_0 = _S1505;
    Vertex _S1506 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S1506;
    Reservoir _S1507 = (Reservoir{});
    Reservoir chain_0 = _S1507;
    uint _S1508 = r_8->seed;
    (&chain_0)->seed = r_8->seed;
    uint _S1509 = extractBits_0(_S1482, 24U, 8U);
    uint _S1510 = insertBits_0(0U, _S1509, 24U, 8U);
    (&chain_0)->path = _S1510;
    (&ray_2)->origin = _S1498;
    (&hit_4)->distance = _S1504;
    FKMedium _S1511 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1512 = filling_2;
    bool _S1513 = (fcptVaryingUsed());
    uint _S1514 = _slang_select(_S1513, _S1512,4294967295U);
    filling_2 = _S1514;
    scatter_in_0 = _S1511.scatter;
    extinction_in_0 = _S1511.extinction;
    g_in_0 = _S1511.g;
    Reservoir _S1515 = chain_0;
    uint _S1516 = filling_2;
    for(;;)
    {
        bool _S1517 = (fcptVaryingUsed());
        if(_S1517)
        {
            passes_0 = _S1516 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1518 = (fcptMajorant((_S1516)));
            spread_1 = _S1518;
        }
        else
        {
            spread_1 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_1)
        {
            turned_1 = 4294967295U == _S1496;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1485 == 1U;
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
            ended_0 = _S1481;
            sky_pdf_0 = 0.0f;
            spread_1 = _S1502;
            width_3 = _S1503;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_6 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1519 = (&prev_0)->rough;
        if(_S1519)
        {
            turned_1 = !(spread_1 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S1520 = stream(_S1508, 384U);
        uint tracking_0 = _S1520;
        weight_2 = throughput_3;
        glowed_0 = _S1480;
        b_6 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        wavelength_8 = _S1502;
        width_3 = _S1503;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1479 = int(1);
                break;
            }
            float _S1521 = (&hit_4)->distance;
            if(passes_0)
            {
                float3  _S1522 = (&ray_2)->origin;
                float3  _S1523 = (&ray_2)->unit_direction;
                float _S1524 = (&hit_4)->distance;
                bool _S1525 = b_6 == 4294967295U;
                uint _S1526 = _slang_select(_S1525, 0U,b_6);
                uint _S1527 = (&prev_0)->lobe;
                uint _S1528 = _slang_select(_S1525, 3U,_S1527);
                float _S1529 = (fcptTrackMedium((_S1516), (_S1522), (_S1523), (_S1524), (&tracking_0), (&weight_2), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1526), (_S1528), (_S1525)));
                threshold_0 = _S1529;
            }
            else
            {
                bool _S1530 = spread_1 > 0.0f;
                if(_S1530)
                {
                    uint _S1531 = noiseAddress(_S1508, b_6);
                    Random _S1532 = draw(_S1531, 10U);
                    float _S1533 = - (F32_log((1.0f - _S1532.value))) / spread_1;
                    threshold_0 = _S1533;
                }
                else
                {
                    threshold_0 = _S1521;
                }
            }
            bool _S1534 = !(threshold_0 < ((&hit_4)->distance));
            if(_S1534)
            {
                _S1479 = int(1);
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
                float3  _S1535 = pathColor(throughput_2 * glowed_0, throughput_3, 0.0f);
                float3  _S1536 = _S1535 / make_float3 (density_2);
                float3  _S1537 = sel_7->glow + _S1536;
                sel_7->glow = _S1537;
            }
            else
            {
            }
            glowed_0 = _S1480;
            uint b_8 = b_6 + 1U;
            float3  _S1538 = (&ray_2)->origin + make_float3 (threshold_0) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1538;
            float3  _S1539 = flightWeight_0(scatter_in_0, extinction_in_0, spread_1, threshold_0, true);
            float3  _S1540 = weight_2;
            float _S1541 = upsample(weight_2, 0.0f);
            float3  _S1542 = make_float3 (_S1541);
            float3  _S1543 = _slang_select(false, _S1542,_S1540);
            float3  _S1544 = _slang_select(passes_0, _S1543,_S1539);
            float3  throughput_4 = throughput_2 * _S1544;
            uint _S1545 = stream(_S1508, b_8 + 320U);
            tracking_0 = _S1545;
            weight_2 = throughput_3;
            float width_6 = width_3 + wavelength_8 * threshold_0;
            float _S1546 = wavelength_8 + 3.14159274101257324f;
            bool _S1547 = !replay_1;
            if(_S1547)
            {
                is_inside_5 = true;
            }
            else
            {
                bool _S1548 = b_8 == _S1496;
                if(_S1548)
                {
                    is_inside_5 = !passes_0;
                }
                else
                {
                    is_inside_5 = false;
                }
            }
            TreeSample _S1549 = TreeSample_x24init_0(_S1480, _S1480, 0.0f, 0U);
            if(is_inside_5)
            {
                float3  _S1550 = (&ray_2)->origin;
                float3  _S1551 = (&ray_2)->unit_direction;
                float3  _S1552 = (&ray_2)->unit_direction;
                uint _S1553 = noiseAddress(_S1508, b_8);
                float3  _S1554 = extinction_in_0;
                float3  _S1555 = extinction_in_0;
                uint2  _S1556 = make_uint2 (_S1516);
                float3  _S1557 = (&ray_2)->unit_direction;
                uint _S1558 = arrivalLobe_0(b_8, (&prev_0)->lobe);
                FKHit _S1559 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1560 = _S1559;
                ShadowContext _S1561 = ShadowContext_x24init_0(_S1554, _S1555, _S1556, _S1557, b_8, _S1558, false, threshold_0, width_6, &_S1560, false);
                ShadowContext _S1562 = _S1561;
                TreeSample _S1563 = sampleLightTree_0(_S1550, _S1551, _S1552, 0.0f, true, _S1553, &_S1562);
                light_3 = _S1563;
            }
            else
            {
                light_3 = _S1549;
            }
            float _S1564 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S1565 = (fcptMaxBounces());
            bool _S1566 = b_8 < _S1565;
            if(_S1566)
            {
                viewed_0 = (light_3.density) > 0.0f;
            }
            else
            {
                viewed_0 = false;
            }
            float _S1567 = _slang_select(viewed_0, _S1564,0.0f);
            float3  _S1568 = throughput_4 * light_3.radiance;
            float _S1569 = powerHeuristic(light_3.density, _S1567);
            float3  _S1570 = pathColor(_S1568 * make_float3 (_S1564 * _S1569), throughput_3, 0.0f);
            float3  _S1571 = _slang_select(is_inside_5, _S1570,_S1480);
            if(replay_1)
            {
                _S1477 = b_8 == _S1496;
            }
            else
            {
                _S1477 = false;
            }
            if(_S1477)
            {
                bool _S1572 = _S1485 == 2U;
                if(_S1572)
                {
                    float _S1573 = resamplingTarget(_S1571);
                    passes_0 = _S1573 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1574 = Shift_x24init_0(_S1571, 1.0f);
                    _S1479 = int(0);
                    ended_0 = _S1574;
                    spread_1 = _S1546;
                    threshold_0 = width_6;
                    spectral_weight_0 = throughput_4;
                    layer_0 = b_8;
                    break;
                }
                _S1479 = int(0);
                ended_0 = _S1481;
                spread_1 = _S1546;
                threshold_0 = width_6;
                spectral_weight_0 = throughput_4;
                layer_0 = b_8;
                break;
            }
            if(_S1547)
            {
                Reservoir candidate_3 = _S1515;
                uint _S1575 = extractBits_0(_S1515.path, 24U, 8U);
                uint _S1576 = insertBits_0(0U, _S1575, 24U, 8U);
                uint _S1577 = extractBits_0(_S1515.path, 10U, 2U);
                bool _S1578 = _S1577 == 1U;
                if(_S1578)
                {
                    float3  _S1579 = safeDivide(_S1571, _S1480);
                    (&candidate_3)->radiance = _S1579;
                }
                else
                {
                    uint _S1580 = insertBits_0(_S1576, b_8 + 1U, 5U, 5U);
                    uint _S1581 = insertBits_0(_S1580, 2U, 10U, 2U);
                    (&candidate_3)->path = _S1581;
                }
                Reservoir _S1582 = withEnd(candidate_3, 0U, b_8, _S1571);
                offer(sel_7, _S1582, _S1571 * make_float3 (scale_3) / make_float3 (density_2));
                float _S1583 = survivalProbability(abs_0(throughput_4), density_2);
                uint _S1584 = (fcptMaxBounces());
                bool _S1585 = b_8 >= _S1584;
                if(_S1585)
                {
                    _S1478 = true;
                }
                else
                {
                    bool _S1586 = _S1583 < 1.0f;
                    if(_S1586)
                    {
                        uint _S1587 = noiseAddress(_S1508, b_8);
                        Random _S1588 = draw(_S1587, 8U);
                        _S1478 = _S1583 < (_S1588.value);
                    }
                    else
                    {
                        _S1478 = false;
                    }
                }
                if(_S1478)
                {
                    _S1479 = int(0);
                    ended_0 = _S1481;
                    spread_1 = _S1546;
                    threshold_0 = width_6;
                    spectral_weight_0 = throughput_4;
                    layer_0 = b_8;
                    break;
                }
                float _S1589 = density_2 * _S1583;
                density_2 = _S1589;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1590 = noiseAddress(_S1508, b_8);
            float3  _S1591 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1590, &phase_pdf_0);
            (&ray_2)->unit_direction = _S1591;
            NEEVertex _S1592 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S1480, (&ray_2)->origin);
            nee_vertex_0 = _S1592;
            Vertex _S1593 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, false);
            prev_0 = _S1593;
            float _S1594 = (&prev_0)->pdf;
            FKRay _S1595 = ray_2;
            FKHit _S1596 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1597 = (fcptTraverseInstanceBVH((_S1595), (true), (4.294967296e+09f), (false), (_S1596), (false)));
            hit_4 = _S1597;
            b_6 = b_8;
            throughput_2 = throughput_4;
            wavelength_8 = _S1546;
            width_3 = width_6;
            sky_pdf_0 = _S1594;
        }
        if(_S1479 != int(1))
        {
            width_3 = threshold_0;
            throughput_2 = spectral_weight_0;
            b_6 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1481;
        spread_1 = wavelength_8;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1598 = b_6 == 4294967295U;
    bool _S1599 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1599)
    {
        bool _S1600 = !(&nee_vertex_0)->none;
        float _S1601 = _slang_select(_S1600, sky_pdf_0,0.0f);
        float _S1602 = escapeWeight_0(_S1601, (&ray_2)->unit_direction);
        float3  _S1603 = environment_0((&ray_2)->unit_direction, b_6, (&prev_0)->lobe);
        float3  _S1604 = pathColor(throughput_2 * _S1603, throughput_3, 0.0f);
        if(replay_1)
        {
            bool _S1605 = b_6 == _S1496;
            if(_S1605)
            {
                passes_0 = _S1485 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S1604 * make_float3 (_S1602) / make_float3 (r_8->jac), density_2 / r_8->jac);
            }
            if(_S1495)
            {
                passes_0 = _S1492;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_6 == _S1483;
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
                return Shift_x24init_0(_S1604 * make_float3 (_S1602), 1.0f);
            }
            return _S1481;
        }
        Reservoir candidate_4 = chain_0;
        uint _S1606 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1607 = _S1606 == 1U;
        if(_S1607)
        {
            uint _S1608 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S1609 = _S1608 == b_6;
            float _S1610 = _slang_select(_S1609, 1.0f,_S1602);
            float3  _S1611 = safeDivide(_S1604 * make_float3 (_S1610), _S1480);
            (&candidate_4)->radiance = _S1611;
        }
        else
        {
            bool _S1612 = (&prev_0)->rough;
            if(_S1612)
            {
                uint _S1613 = insertBits_0(_S1510, b_6 + 1U, 5U, 5U);
                uint _S1614 = insertBits_0(_S1613, 3U, 10U, 2U);
                uint _S1615 = insertBits_0(_S1614, (&prev_0)->lobe, 15U, 3U);
                bool _S1616 = (&prev_0)->inside;
                uint _S1617 = _slang_select(_S1616, 1U,0U);
                uint _S1618 = insertBits_0(_S1615, _S1617, 22U, 1U);
                (&candidate_4)->path = _S1618;
                (&candidate_4)->jac = (&prev_0)->pdf;
                (&candidate_4)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S1619 = _S1604 * make_float3 (_S1602);
        Reservoir _S1620 = withEnd(candidate_4, 3U, b_6, _S1619);
        offer(sel_7, _S1620, _S1619 * make_float3 (scale_3) / make_float3 (density_2));
        return _S1481;
    }
    float3  _S1621 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S1621;
    bool _S1622 = (fcptVaryingUsed());
    if(_S1622)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1623 = !replay_1;
        if(_S1623)
        {
            float3  _S1624 = pathColor(throughput_2 * glowed_0, throughput_3, 0.0f);
            float3  _S1625 = _S1624 / make_float3 (density_2);
            float3  _S1626 = sel_7->glow + _S1625;
            sel_7->glow = _S1626;
        }
        float3  _S1627 = throughput_2 * weight_2;
        throughput_2 = _S1627;
    }
    else
    {
        float3  _S1628 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
        float3  _S1629 = throughput_2 * _S1628;
        throughput_2 = _S1629;
    }
    float _S1630 = width_3 + spread_1 * (&hit_4)->distance;
    uint _S1631 = b_6 + 1U;
    b_6 = _S1631;
    layer_0 = 0U;
    width_3 = _S1630;
    passes_0 = false;
    wavelength_8 = 0.0f;
    threshold_0 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    spectral_weight_0 = throughput_3;
    float3  chain_throughput_0 = _S1480;
    float3  reconnection_0 = _S1480;
    viewed_0 = _S1598;
    for(;;)
    {
        bool _S1632 = ((&hit_4)->is_point_light) == 1U;
        if(replay_1)
        {
            _S1477 = _S1485 == 1U;
        }
        else
        {
            _S1477 = false;
        }
        if(_S1477)
        {
            _S1478 = b_6 == _S1484;
        }
        else
        {
            _S1478 = false;
        }
        bool _S1633;
        if(_S1478)
        {
            bool _S1634 = ((&hit_4)->instance_index) != (_S1497.instance_index);
            if(_S1634)
            {
                _S1633 = true;
            }
            else
            {
                _S1633 = ((&hit_4)->triangle_index) != (_S1497.triangle_index);
            }
        }
        else
        {
            _S1633 = false;
        }
        if(_S1633)
        {
            return _S1481;
        }
        FKMedium _S1635 = Medium_x24init_0(_S1480, _S1480, 0.0f);
        BSDFMaterial _S1636 = Material_x24init_0(_S1480, _S1480, 0.0f, 0.0f, 0.0f, 0.0f, _S1480, throughput_3, 1.0f, _S1480, _S1480, 0.5f, 0.0f, 0.0f, _S1480, 0.0f, _S1480, 0.0f, 0.0f, 0.02999999932944775f, 1.5f, throughput_3, _S1480);
        FKMedium _S1637 = _S1635;
        FKSurface _S1638 = Surface_x24init_0(_S1480, _S1480, 0.0f, &_S1636, false, 0U, 1.0f, false, &_S1637, 4294967295U, _S1480);
        bool _S1639 = !_S1632;
        bool scatter_2;
        bool is_inside_6;
        float geometry_density_0;
        float3  throughput_5;
        float3  front_n_0;
        FKSurface surface_12;
        if(_S1639)
        {
            uint _S1640 = noiseAddress(_S1508, b_6);
            uint _S1641 = arrivalLobe_0(b_6, (&prev_0)->lobe);
            FKSurface _S1642 = (fcptSurfaceAtPath((hit_4), ((&ray_2)->origin), (_S1640), (width_3), (layer_0), (b_6), (_S1641), ((&ray_2)->unit_direction)));
            bool _S1643 = !passes_0;
            FKSurface _S1644 = _S1642;
            FKSurface _S1645 = emitting_0(&_S1644, _S1643);
            uint _S1646 = noiseAddress(_S1508, b_6);
            Random _S1647 = draw(_S1646, 9U);
            FKSurface _S1648 = _S1645;
            FKSurface _S1649 = uncovered_0(&_S1648, _S1647.value);
            float _S1650 = facingSign(_S1649.material.transmission, _S1649.geometry_n, (&ray_2)->unit_direction);
            bool _S1651 = _S1650 < 0.0f;
            bool _S1652 = (_S1649.material.transmission) > 0.0f;
            if(_S1652)
            {
                bool _S1653 = arrivesBehind_0((&ray_2)->unit_direction, _S1649.geometry_n);
                scatter_2 = _S1653;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1654 = _S1649;
            FKSurface _S1655 = facingRay_0(&_S1654, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S1656 = arrivesBehind_0((&ray_2)->unit_direction, _S1655.geometry_n);
                is_inside_6 = _S1656;
            }
            else
            {
                is_inside_6 = scatter_2;
            }
            if(is_inside_6)
            {
                float _S1657 = (&hit_4)->distance;
                float _S1658 = upsample(_S1655.material.absorption, wavelength_8);
                float3  _S1659 = make_float3 (_S1658);
                bool _S1660 = wavelength_8 > 0.0f;
                float3  _S1661 = _slang_select(_S1660, _S1659,_S1655.material.absorption);
                float3  _S1662 = beerLambert(_S1657, _S1661);
                float3  _S1663 = throughput_2 * _S1662;
                throughput_5 = _S1663;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S1664 = !_S1655.skip;
            float geometry_density_1 = (F32_abs((dot_0(_S1655.geometry_n, (&ray_2)->unit_direction)))) / ((&hit_4)->distance * (&hit_4)->distance);
            bool _S1665 = b_6 == _S1631;
            if(_S1665)
            {
                float _S1666 = 0.00251327408477664f / geometry_density_1;
                geometry_density_0 = _S1666;
            }
            else
            {
                geometry_density_0 = threshold_0;
            }
            float _S1667 = geometry_density_0;
            scatter_2 = _S1664;
            geometry_density_0 = geometry_density_1;
            threshold_0 = _S1667;
            surface_12 = _S1655;
            front_n_0 = _S1649.smooth_n;
            turned_1 = _S1651;
        }
        else
        {
            scatter_2 = false;
            geometry_density_0 = 0.0f;
            surface_12 = _S1638;
            throughput_5 = throughput_2;
            front_n_0 = _S1480;
            is_inside_6 = is_inside_5;
        }
        bool _S1668;
        if(scatter_2)
        {
            _S1668 = (&prev_0)->rough;
        }
        else
        {
            _S1668 = false;
        }
        bool _S1669;
        if(_S1668)
        {
            _S1669 = ((&prev_0)->pdf * geometry_density_0 * threshold_0) <= 1.0f;
        }
        else
        {
            _S1669 = false;
        }
        FKSurface _S1670 = surface_12;
        float _S1671 = dot_0(surface_12.smooth_n, - (&ray_2)->unit_direction);
        bool _S1672 = (fcptDispersionUsed());
        bool _S1673;
        if(_S1672)
        {
            _S1673 = wavelength_8 == 0.0f;
        }
        else
        {
            _S1673 = false;
        }
        bool _S1674;
        if(_S1673)
        {
            _S1674 = scatter_2;
        }
        else
        {
            _S1674 = false;
        }
        bool _S1675;
        if(_S1674)
        {
            bool _S1676 = dispersive(surface_12.material);
            _S1675 = _S1676;
        }
        else
        {
            _S1675 = false;
        }
        float3  throughput_6;
        if(_S1675)
        {
            uint _S1677 = stream(_S1508, 512U);
            Random _S1678 = pcg(_S1677);
            uint _S1679 = extractBits_0(_S1482, 25U, 7U);
            float _S1680 = (float(_S1679) + _S1678.value) / 128.0f;
            uint _S1681 = extractBits_0(_S1482, 24U, 1U);
            bool _S1682 = _S1681 == 1U;
            float _S1683 = _slang_select(_S1682, _S1680,_S1678.value);
            float2  _S1684 = sampleWavelength(_S1683);
            float wavelength_9 = _S1684.x;
            float3  _S1685 = wavelengthWeights(wavelength_9);
            float3  _S1686 = _S1685 / make_float3 (_S1684.y);
            float _S1687 = upsample(throughput_5, wavelength_9);
            float3  _S1688 = make_float3 (_S1687);
            float _S1689 = upsample(scatter_in_0, wavelength_9);
            float3  _S1690 = make_float3 (_S1689);
            scatter_in_0 = _S1690;
            float _S1691 = upsample(extinction_in_0, wavelength_9);
            float3  _S1692 = make_float3 (_S1691);
            extinction_in_0 = _S1692;
            wavelength_8 = wavelength_9;
            throughput_6 = _S1688;
            spectral_weight_0 = _S1686;
        }
        else
        {
            throughput_6 = throughput_5;
        }
        BSDFMaterial _S1693 = pathMaterial(surface_12.material, wavelength_8);
        float2  _S1694 = wavelengthEta(_S1693, _S1671, wavelength_8);
        FKSurface _S1695 = surface_12;
        Facets _S1696 = drawFacets((&ray_2)->unit_direction, _S1670.smooth_n, _S1693, surface_12.random_state);
        bool _S1697;
        if(scatter_2)
        {
            bool _S1698 = neeDecision(_S1693, _S1671, _S1694.x, _S1694.y);
            _S1697 = _S1698;
        }
        else
        {
            _S1697 = false;
        }
        bool _S1699;
        if(passes_0)
        {
            _S1699 = true;
        }
        else
        {
            _S1699 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1699)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1697;
        }
        bool _S1700 = (fcptHairUsed());
        bool _S1701;
        if(_S1700)
        {
            float3  _S1702 = surface_12.hair;
            _S1701 = (dot_0(_S1702, _S1702)) > 0.0f;
        }
        else
        {
            _S1701 = false;
        }
        bool _S1703;
        if(_S1701)
        {
            _S1703 = true;
        }
        else
        {
            BSDFMaterial _S1704 = _S1693;
            bool _S1705 = isTranslucent_0(&_S1704);
            _S1703 = _S1705;
        }
        bool _S1706;
        if(_S1703)
        {
            _S1706 = true;
        }
        else
        {
            bool _S1707 = (_S1693.transmission) > 0.0f;
            if(_S1707)
            {
                uint _S1708 = (fcptLayers((hit_4)));
                _S1706 = _S1708 == 1U;
            }
            else
            {
                _S1706 = false;
            }
        }
        float3  _S1709 = emitted_0(_S1693.emissive, (&ray_2)->unit_direction, front_n_0);
        float3  emission_0;
        if(_S1632)
        {
            float3  _S1710 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1710;
        }
        else
        {
            emission_0 = _S1709;
        }
        bool _S1711 = !replay_1;
        bool _S1712;
        if(_S1711)
        {
            _S1712 = true;
        }
        else
        {
            _S1712 = b_6 >= _S1496;
        }
        bool _S1713;
        if(_S1712)
        {
            float _S1714 = rgb_to_greyscale(emission_0);
            _S1713 = _S1714 > 0.0f;
        }
        else
        {
            _S1713 = false;
        }
        float3  emission_1;
        if(_S1713)
        {
            NEEVertex _S1715 = nee_vertex_0;
            FKHit _S1716 = hit_4;
            float _S1717 = emissionWeight_0(&_S1715, &_S1716, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1717);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1718;
        if(replay_1)
        {
            _S1718 = _S1485 == 1U;
        }
        else
        {
            _S1718 = false;
        }
        bool _S1719;
        if(_S1718)
        {
            _S1719 = b_6 > _S1484;
        }
        else
        {
            _S1719 = false;
        }
        bool _S1720;
        if(_S1719)
        {
            _S1720 = b_6 == _S1483;
        }
        else
        {
            _S1720 = false;
        }
        bool _S1721;
        if(_S1720)
        {
            bool _S1722 = _S1486 == 1U;
            if(_S1722)
            {
                _S1721 = true;
            }
            else
            {
                _S1721 = _S1486 == 2U;
            }
        }
        else
        {
            _S1721 = false;
        }
        if(_S1721)
        {
            bool _S1723 = _S1632 != (_S1486 == 2U);
            if(_S1723)
            {
                return _S1481;
            }
            float3  _S1724 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_8);
            return Shift_x24init_0(_S1724 / make_float3 (r_8->jac), density_2 / r_8->jac);
        }
        uint _S1725 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1726 = _S1725 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1727 = insertBits_0(_S1510, b_6, 5U, 5U);
        uint _S1728 = insertBits_0(_S1727, 1U, 10U, 2U);
        uint _S1729 = insertBits_0(_S1728, (&prev_0)->lobe, 15U, 3U);
        bool _S1730 = (&prev_0)->inside;
        uint _S1731 = _slang_select(_S1730, 1U,0U);
        uint _S1732 = insertBits_0(_S1729, _S1731, 22U, 1U);
        (&here_0)->path = _S1732;
        uint _S1733 = (&here_0)->path;
        bool _S1734 = wavelength_8 > 0.0f;
        uint _S1735 = _slang_select(_S1734, 1U,0U);
        uint _S1736 = insertBits_0(_S1733, _S1735, 23U, 1U);
        (&here_0)->path = _S1736;
        float _S1737 = (&prev_0)->pdf * geometry_density_0;
        (&here_0)->jac = _S1737;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1738;
        if(replay_1)
        {
            _S1738 = _S1485 == 1U;
        }
        else
        {
            _S1738 = false;
        }
        bool _S1739;
        if(_S1738)
        {
            _S1739 = b_6 == _S1484;
        }
        else
        {
            _S1739 = false;
        }
        bool _S1740 = b_6 == _S1496;
        bool _S1741;
        if(_S1740)
        {
            bool _S1742 = !scatter_2;
            if(_S1742)
            {
                _S1741 = true;
            }
            else
            {
                bool _S1743 = _S1485 != 1U;
                if(_S1743)
                {
                    _S1741 = _S1485 != 3U;
                }
                else
                {
                    _S1741 = false;
                }
            }
        }
        else
        {
            _S1741 = false;
        }
        bool _S1744;
        if(_S1741)
        {
            _S1744 = _S1485 == 2U;
        }
        else
        {
            _S1744 = false;
        }
        bool _S1745;
        if(_S1744)
        {
            _S1745 = !_S1669;
        }
        else
        {
            _S1745 = false;
        }
        bool _S1746;
        if(_S1745)
        {
            _S1746 = _S1486 != 4U;
        }
        else
        {
            _S1746 = false;
        }
        bool _S1747 = _S1484 == _S1483;
        bool _S1748;
        if(_S1747)
        {
            _S1748 = _S1486 == 0U;
        }
        else
        {
            _S1748 = false;
        }
        bool _S1749;
        if(_S1748)
        {
            _S1749 = ((&hit_4)->instance_index) == (_S1497.instance_index);
        }
        else
        {
            _S1749 = false;
        }
        bool _S1750;
        if(_S1749)
        {
            _S1750 = ((&hit_4)->triangle_index) == (_S1497.triangle_index);
        }
        else
        {
            _S1750 = false;
        }
        bool _S1751;
        if(_S1750)
        {
            _S1751 = _S1669;
        }
        else
        {
            _S1751 = false;
        }
        bool _S1752 = _slang_select(_S1739, _S1751,_S1746);
        bool _S1753;
        if(nee_0)
        {
            _S1753 = _slang_select(replay_1, _S1752,scatter_2);
        }
        else
        {
            _S1753 = false;
        }
        TreeSample _S1754 = TreeSample_x24init_0(_S1480, _S1480, 0.0f, 0U);
        uint2  _S1755 = make_uint2 (0U);
        float2  _S1756 = make_float2 (0.0f);
        FKHit _S1757 = Hit_x24init_0(_S1756, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1758 = _S1757;
        ShadowContext _S1759 = ShadowContext_x24init_0(_S1480, _S1480, _S1755, _S1480, 0U, 0U, false, 0.0f, 0.0f, &_S1758, false);
        bool _S1760;
        if(nee_0)
        {
            _S1760 = _S1712;
        }
        else
        {
            _S1760 = false;
        }
        ShadowContext context_5;
        if(_S1760)
        {
            uint _S1761 = arrivalLobe_0(b_6, (&prev_0)->lobe);
            FKMedium _S1762 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1763 = surface_12;
            FKHit _S1764 = hit_4;
            FKMedium _S1765 = _S1762;
            ShadowContext _S1766 = shadowContext_0(&_S1763, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_6, _S1761, (&hit_4)->distance, width_3, &_S1764, _S1701, &_S1765);
            context_5 = _S1766;
        }
        else
        {
            context_5 = _S1759;
        }
        float3  throughput_7;
        float3  lit_0;
        if(_S1753)
        {
            float3  _S1767 = (&ray_2)->origin;
            if(_S1701)
            {
                throughput_7 = _S1480;
            }
            else
            {
                throughput_7 = _S1670.smooth_n;
            }
            FKSurface _S1768 = surface_12;
            uint _S1769 = noiseAddress(_S1508, b_6);
            ShadowContext _S1770 = context_5;
            TreeSample _S1771 = sampleLightTree_0(_S1767, throughput_7, surface_12.geometry_n, surface_12.geometry_offset, _S1706, _S1769, &_S1770);
            bool _S1772 = any_1((_S1771.radiance) != _S1480);
            if(_S1772)
            {
                if(_S1701)
                {
                    uint _S1773 = (fcptMaxBounces());
                    bool _S1774 = b_6 < _S1773;
                    FKSurface _S1775 = surface_12;
                    TreeSample _S1776 = _S1771;
                    float3  _S1777 = hairLight_0(&_S1775, (&ray_2)->unit_direction, &_S1776, _S1774);
                    lit_0 = _S1777;
                }
                else
                {
                    float _S1778 = _S1694.x;
                    float _S1779 = _S1694.y;
                    uint _S1780 = (fcptMaxBounces());
                    bool _S1781 = b_6 < _S1780;
                    TreeSample _S1782 = _S1771;
                    BSDFMaterial _S1783 = _S1693;
                    Facets _S1784 = _S1696;
                    float3  _S1785 = lightBSDF_0((&ray_2)->unit_direction, &_S1782, _S1670.smooth_n, _S1768.geometry_n, &_S1783, _S1778, _S1779, _S1781, &_S1784);
                    lit_0 = _S1785;
                }
            }
            else
            {
                lit_0 = _S1480;
            }
            light_3 = _S1771;
        }
        else
        {
            light_3 = _S1754;
            lit_0 = _S1480;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1786;
        bool _S1787;
        float density_4;
        if(_S1739)
        {
            bool _S1788 = !_S1669;
            if(_S1788)
            {
                return _S1481;
            }
            uint _S1789 = extractBits_0(_S1482, 23U, 1U);
            bool _S1790 = _S1734 != (_S1789 == 1U);
            if(_S1790)
            {
                return _S1481;
            }
            float3  throughput_8 = throughput_6 * make_float3 (geometry_density_0);
            float density_5 = density_2 * geometry_density_0;
            if(_S1747)
            {
                viewed_1 = _S1486 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                float3  _S1791 = pathColor(throughput_8 * emission_1, spectral_weight_0, wavelength_8);
                return Shift_x24init_0(_S1791 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1747)
            {
                refracted_4 = _S1486 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S1792 = !nee_0;
                if(_S1792)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1793 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1793 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1481;
                }
                float3  _S1794 = pathColor(throughput_8 * lit_0, spectral_weight_0, wavelength_8);
                return Shift_x24init_0(_S1794 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1747)
            {
                wrong_side_0 = _S1486 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1795 = !nee_0;
                if(_S1795)
                {
                    return _S1481;
                }
                bool _S1796 = (fcptWorldReadsPath());
                if(_S1796)
                {
                    float3  _S1797 = r_8->dir;
                    float _S1798 = environmentPdf_0(r_8->dir);
                    FKSurface _S1799 = surface_12;
                    BSDFMaterial _S1800 = _S1693;
                    Facets _S1801 = _S1696;
                    FixedArray<float3 , 6>  terms_4;
                    FixedArray<float, 6>  pdfs_6;
                    float3  _S1802 = skyLobes_0((&ray_2)->unit_direction, _S1797, &_S1799, &_S1800, _S1694, is_inside_6, &_S1801, _S1798, &terms_4, &pdfs_6);
                    uint _S1803 = b_6 + 1U;
                    FixedArray<float3 , 6>  _S1804 = terms_4;
                    FixedArray<float, 6>  _S1805 = pdfs_6;
                    float3  _S1806 = skyColor_0(_S1797, &_S1804, &_S1805, _S1803);
                    float3  _S1807 = pathColor(throughput_8 * (_S1806 * r_8->radiance), spectral_weight_0, wavelength_8);
                    return Shift_x24init_0(_S1807 / make_float3 (r_8->jac), density_5 / r_8->jac);
                }
                float _S1808 = environmentPdf_0(r_8->dir);
                float3  _S1809 = skyBSDF((&ray_2)->unit_direction, r_8->dir, surface_12, _S1693, _S1694, is_inside_6, _S1696, _S1808);
                float3  _S1810 = pathColor(throughput_8 * _S1809 * r_8->radiance, spectral_weight_0, wavelength_8);
                return Shift_x24init_0(_S1810 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            uint _S1811 = extractBits_0(_S1482, 21U, 1U);
            bool _S1812 = nee_0 != (_S1811 == 1U);
            if(_S1812)
            {
                return _S1481;
            }
            throughput_7 = throughput_8;
            density_4 = density_5;
        }
        else
        {
            if(replay_1)
            {
                viewed_1 = _S1740;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1813 = !scatter_2;
                if(_S1813)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1814 = _S1485 != 1U;
                    if(_S1814)
                    {
                        refracted_4 = _S1485 != 3U;
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
                bool _S1815 = _S1485 == 2U;
                if(_S1815)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1669;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1486 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1701)
                    {
                        return _S1481;
                    }
                    uint _S1816 = noiseAddress(_S1508, b_6);
                    FKRay _S1817 = ray_2;
                    FKSurface _S1818 = surface_12;
                    Facets _S1819 = _S1696;
                    ShadowContext _S1820 = context_5;
                    SkySample _S1821 = sampleSky_0(&_S1817, &_S1818, wavelength_8, _S1694, is_inside_6, _S1816, &_S1819, &_S1820);
                    float3  _S1822 = pathColor(throughput_6 * _S1821.color, spectral_weight_0, wavelength_8);
                    return Shift_x24init_0(_S1822, 1.0f);
                }
                if(_S1815)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1669;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1823 = rgb_to_greyscale(light_3.radiance);
                    bool _S1824 = !(_S1823 > 0.0f);
                    if(_S1824)
                    {
                        return _S1481;
                    }
                    float3  _S1825 = pathColor(throughput_6 * lit_0, spectral_weight_0, wavelength_8);
                    return Shift_x24init_0(_S1825, 1.0f);
                }
                if(_S1495)
                {
                    passes_0 = _S1486 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1632;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float3  _S1826 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_8);
                    return Shift_x24init_0(_S1826, 1.0f);
                }
                if(_S1495)
                {
                    passes_0 = _S1486 == 1U;
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
                    passes_0 = !_S1669;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float3  _S1827 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_8);
                    return Shift_x24init_0(_S1827, 1.0f);
                }
                return _S1481;
            }
            else
            {
                if(_S1711)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1828 = b_6 > 0U;
                    if(_S1828)
                    {
                        Reservoir candidate_5 = chain_0;
                        if(_S1726)
                        {
                            float3  _S1829 = safeDivide(throughput_6 * emission_1, chain_throughput_0);
                            (&candidate_5)->radiance = _S1829;
                        }
                        else
                        {
                            if(_S1669)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1830 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_8);
                        Reservoir _S1831 = withEnd(candidate_5, 1U, b_6, _S1830);
                        offer(sel_7, _S1831, _S1830 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1832 = pathColor(throughput_6 * emission_1, spectral_weight_0, wavelength_8);
                        float3  _S1833 = sel_7->glow + _S1832;
                        sel_7->glow = _S1833;
                    }
                    if(nee_0)
                    {
                        float3  _S1834 = pathColor(throughput_6 * lit_0, spectral_weight_0, wavelength_8);
                        Reservoir candidate_6 = chain_0;
                        if(_S1726)
                        {
                            float3  _S1835 = safeDivide(_S1834, chain_throughput_0);
                            (&candidate_6)->radiance = _S1835;
                        }
                        else
                        {
                            if(_S1669)
                            {
                                candidate_6 = here_0;
                                uint _S1836 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1836;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1837 = insertBits_0(_S1510, b_6 + 1U, 5U, 5U);
                                uint _S1838 = insertBits_0(_S1837, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1838;
                            }
                        }
                        Reservoir _S1839 = withEnd(candidate_6, 0U, b_6, _S1834);
                        offer(sel_7, _S1839, _S1834 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1701)
                        {
                            _S1786 = false;
                        }
                        else
                        {
                            bool _S1840 = environmentMapped_0();
                            _S1786 = _S1840;
                        }
                    }
                    else
                    {
                        _S1786 = false;
                    }
                    if(_S1786)
                    {
                        uint _S1841 = (fcptMaxBounces());
                        _S1787 = b_6 < _S1841;
                    }
                    else
                    {
                        _S1787 = false;
                    }
                    if(_S1787)
                    {
                        uint _S1842 = noiseAddress(_S1508, b_6);
                        FKRay _S1843 = ray_2;
                        FKSurface _S1844 = surface_12;
                        Facets _S1845 = _S1696;
                        ShadowContext _S1846 = context_5;
                        SkySample _S1847 = sampleSky_0(&_S1843, &_S1844, wavelength_8, _S1694, is_inside_6, _S1842, &_S1845, &_S1846);
                        float3  _S1848 = pathColor(throughput_6 * _S1847.color, spectral_weight_0, wavelength_8);
                        Reservoir candidate_7 = chain_0;
                        if(_S1726)
                        {
                            float3  _S1849 = safeDivide(_S1848, chain_throughput_0);
                            (&candidate_7)->radiance = _S1849;
                        }
                        else
                        {
                            if(_S1669)
                            {
                                candidate_7 = here_0;
                                uint _S1850 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1850;
                                (&candidate_7)->dir = _S1847.dir;
                                (&candidate_7)->radiance = _S1847.radiance;
                            }
                            else
                            {
                                uint _S1851 = insertBits_0(_S1510, b_6 + 1U, 5U, 5U);
                                uint _S1852 = insertBits_0(_S1851, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1852;
                            }
                        }
                        Reservoir _S1853 = withEnd(candidate_7, 4U, b_6, _S1848);
                        offer(sel_7, _S1853, _S1848 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                }
            }
            throughput_7 = throughput_6;
            density_4 = density_2;
        }
        bool _S1854;
        bool _S1855;
        bool _S1856;
        bool straight_0;
        bool _S1857;
        bool _S1858;
        bool _S1859;
        bool _S1860;
        bool _S1861;
        bool _S1862;
        bool _S1863;
        bool _S1864;
        bool _S1865;
        bool _S1866;
        bool _S1867;
        bool _S1868;
        bool _S1869;
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
                viewed_1 = _S1740;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1870 = extractBits_0(_S1482, 15U, 3U);
            uint _S1871 = extractBits_0(_S1482, 18U, 3U);
            uint _S1872 = _slang_select(_S1739, _S1871,_S1870);
            float3  _S1873 = r_8->dir;
            bool refracted_5 = _S1872 == 1U;
            SampleBSDF _S1874 = SampleBSDF_x24init_0(_S1480, _S1480, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1874;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1875 = extractBits_0(_S1482, 22U, 1U);
                bool _S1876 = is_inside_6 != (_S1875 == 1U);
                if(_S1876)
                {
                    return _S1481;
                }
                bool _S1877 = _S1485 == 1U;
                if(_S1877)
                {
                    float3  _S1878 = (fcptHitPosition((_S1497)));
                    throughput_9 = _S1878;
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
                    BSDFMaterial _S1879 = _S1693;
                    bool _S1880 = isTranslucent_0(&_S1879);
                    if(_S1880)
                    {
                        refracted_4 = _S1872 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1881 = throughput_9 - (&ray_2)->origin;
                        float3  _S1882 = _slang_select(_S1877, _S1881,_S1873);
                        wrong_side_0 = (dot_0(_S1670.smooth_n, _S1882) * _S1671) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1877)
                {
                    float3  _S1883 = (&ray_2)->origin;
                    FKSurface _S1884 = surface_12;
                    float3  _S1885 = - _S1670.smooth_n;
                    bool _S1886 = is_inside_6 != refracted_4;
                    float3  _S1887 = _slang_select(_S1886, _S1885,_S1670.smooth_n);
                    float3  _S1888 = throughput_9 - (_S1883 + make_float3 (_S1884.geometry_offset) * _S1887);
                    float3  _S1889 = ((((_S1888)) * make_float3(rnorm3df(((_S1888)).x, ((_S1888)).y, ((_S1888)).z))));
                    reconnection_1 = _S1889;
                }
                else
                {
                    reconnection_1 = _S1873;
                }
                if(_S1701)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1890 = wrongSide_0(is_inside_6, refracted_4, reconnection_1, surface_12.geometry_n);
                    wrong_side_0 = _S1890;
                }
                if(wrong_side_0)
                {
                    return _S1481;
                }
                float3  _S1891 = throughput_9;
                throughput_9 = reconnection_1;
                b_9 = _S1872;
                wrong_side_0 = false;
                reconnection_1 = _S1891;
            }
            else
            {
                bool _S1892 = !_S1739;
                if(_S1892)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1893;
                    if(_S1701)
                    {
                        SampleBSDF _S1894 = (fcptSampleHair((surface_12.hair), (_S1693.albedo), (_S1693.specular_tint), ((&ray_2)->unit_direction), (_S1695.random_state)));
                        _S1893 = _S1894;
                    }
                    else
                    {
                        SampleBSDF _S1895 = sampleBSDF((&ray_2)->unit_direction, _S1670.smooth_n, _S1693, _S1694.x, _S1694.y, _S1696, _S1695.random_state, _S1756);
                        _S1893 = _S1895;
                    }
                    bsdf_sampled_0 = _S1893;
                    if(_S1701)
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
                            return _S1481;
                        }
                        break;
                    }
                    if(_S1701)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1896 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_12.geometry_n);
                        wrong_side_0 = _S1896;
                    }
                    if(wrong_side_0)
                    {
                        _S1786 = (_S1693.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1786 = false;
                    }
                    if(_S1786)
                    {
                        float _S1897 = _S1694.x;
                        float _S1898 = _S1694.y;
                        Facets _S1899 = drawFacets((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S1693, (&bsdf_sampled_0)->random_state);
                        SampleBSDF _S1900 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S1693, _S1897, _S1898, _S1899, (&bsdf_sampled_0)->random_state, _S1756);
                        (&bsdf_sampled_0)->unit_direction = _S1900.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1900.refracted;
                        (&bsdf_sampled_0)->throughput = _S1900.throughput;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1901 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n)) * surface_12.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1901;
                        }
                    }
                    uint _S1902 = (&bsdf_sampled_0)->lobe;
                    float3  _S1903 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1904 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1905 = (&bsdf_sampled_0)->pdf;
                    float _S1906 = _slang_select(wrong_side_0, 0.0f,_S1905);
                    (&lobe_5)->pdf = _S1906;
                    throughput_9 = _S1903;
                    b_9 = _S1902;
                    refracted_4 = _S1904;
                }
                else
                {
                    throughput_9 = _S1873;
                    b_9 = _S1872;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1786 = true;
            }
            else
            {
                _S1786 = _S1739;
            }
            if(_S1786)
            {
                if(_S1701)
                {
                    SampleBSDF _S1907 = (fcptConnectHair((surface_12.hair), (_S1693.albedo), (_S1693.specular_tint), ((&ray_2)->unit_direction), (throughput_9)));
                    lobe_5 = _S1907;
                }
                else
                {
                    float3  _S1908 = (&ray_2)->unit_direction;
                    float3  _S1909 = negate_0(_S1908);
                    float _S1910 = sign_0(_S1671);
                    float3  _S1911 = _S1670.smooth_n * make_float3 (_S1910);
                    float _S1912 = dot_0(_S1911, throughput_9);
                    float _S1913 = _S1693.roughness;
                    float _S1914 = _S1913 * _S1913;
                    AnisotropicFrame _S1915 = anisotropicFrame(_S1693, _S1911);
                    SheenProfile _S1916 = sheenProfile(_S1909, _S1911, _S1693);
                    CoatFrame _S1917 = coatFrame(_S1693, _S1911);
                    float3  _S1918 = coatSeries(_S1917, _S1693);
                    float3  _S1919 = reflectedHalf(_S1908, throughput_9);
                    bool _S1920 = b_9 == 1U;
                    if(_S1920)
                    {
                        float3  _S1921 = refractedHalf(_S1908, throughput_9, _S1670.smooth_n, _S1694.x, _S1694.y);
                        throughput_10 = _S1921;
                    }
                    else
                    {
                        throughput_10 = _S1919;
                    }
                    float3  _S1922 = reflectedHalf(_S1908, throughput_9);
                    float3  _S1923 = _S1696.coat_h;
                    bool _S1924 = (dot_0(_S1923, _S1923)) > 0.0f;
                    float3  _S1925 = _slang_select(_S1924, _S1922,_S1480);
                    float _S1926 = _S1694.x;
                    float _S1927 = _S1694.y;
                    Weights _S1928 = lobeWeights(_S1908, _S1909, _S1911, _S1696.h, _S1696.coat_h, throughput_10, _S1925, _S1915, _S1916, _S1917, _S1918, _S1693, _S1926, _S1927);
                    float _S1929 = (F32_abs((_S1671)));
                    float _S1930 = vndfPDF(_S1909, throughput_10, _S1911, _S1929, _S1914, _S1915, _S1928.v_dot_h);
                    switch(b_9)
                    {
                    case 0U:
                        {
                            float _S1931 = diffusePDF(_S1912, _S1929, _S1693, _S1928);
                            float3  _S1932 = diffuseBSDF(throughput_9, _S1911, _S1693, _S1928);
                            density_6 = _S1931;
                            throughput_11 = _S1932;
                            break;
                        }
                    case 1U:
                        {
                            float _S1933 = refractPDF(dot_0(throughput_9, throughput_10), _S1930, _S1928, _S1926, _S1927);
                            float3  _S1934 = refractBSDF(throughput_9, _S1911, _S1914, _S1915, _S1693, _S1928);
                            density_6 = _S1933;
                            throughput_11 = _S1934;
                            break;
                        }
                    case 4U:
                        {
                            float _S1935 = sheenVelvetPDF(_S1912, _S1929, _S1928);
                            float3  _S1936 = sheenVelvetBSDF(throughput_9, _S1909, _S1911, _S1693, _S1928);
                            density_6 = _S1935;
                            throughput_11 = _S1936;
                            break;
                        }
                    case 5U:
                        {
                            float _S1937 = coatPDF(_S1909, _S1925, _S1917, _S1928);
                            float3  _S1938 = coatBSDF(_S1928);
                            density_6 = _S1937;
                            throughput_11 = _S1938;
                            break;
                        }
                    case 6U:
                        {
                            ToonProfile _S1939 = toonProfile(_S1909, _S1911, _S1693);
                            float _S1940 = toonPDF(throughput_9, _S1911, _S1939, _S1928);
                            float3  _S1941 = toonBSDF(throughput_9, _S1911, _S1939, _S1928);
                            density_6 = _S1940;
                            throughput_11 = _S1941;
                            break;
                        }
                    default:
                        {
                            float _S1942 = reflectPDF(_S1930, _S1928);
                            float3  _S1943 = reflectBSDF(throughput_9, _S1911, _S1914, _S1915, _S1928);
                            density_6 = _S1942;
                            throughput_11 = _S1943;
                            break;
                        }
                    }
                    bool _S1944 = density_6 > 0.0f;
                    if(_S1944)
                    {
                        SampleBSDF _S1945 = SampleBSDF_x24init_0(throughput_9, throughput_11, _S1695.random_state, _S1920, b_9, density_6);
                        lobe_5 = _S1945;
                    }
                }
            }
            bool _S1946 = b_9 == 0U;
            if(_S1946)
            {
                _S1787 = true;
            }
            else
            {
                _S1787 = b_9 == 4U;
            }
            if(_S1787)
            {
                _S1854 = true;
            }
            else
            {
                _S1854 = b_9 == 6U;
            }
            bool _S1947 = b_9 == 5U;
            float _S1948 = _slang_select(_S1947, _S1693.coat_roughness,_S1693.roughness);
            if(_S1701)
            {
                _S1855 = false;
            }
            else
            {
                bool _S1949 = !_S1854;
                if(_S1949)
                {
                    bool _S1950 = _S1948 == 0.0f;
                    if(_S1950)
                    {
                        _S1855 = true;
                    }
                    else
                    {
                        bool _S1951 = b_9 == 1U;
                        if(_S1951)
                        {
                            _S1855 = (_S1694.x) == (_S1694.y);
                        }
                        else
                        {
                            _S1855 = false;
                        }
                    }
                }
                else
                {
                    _S1855 = false;
                }
            }
            bool _S1952 = !_S1701;
            if(_S1952)
            {
                _S1856 = b_9 == 1U;
            }
            else
            {
                _S1856 = false;
            }
            if(_S1856)
            {
                straight_0 = (_S1693.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1857 = _S1952;
            }
            else
            {
                _S1857 = false;
            }
            if(_S1857)
            {
                _S1858 = b_9 == 1U;
            }
            else
            {
                _S1858 = false;
            }
            if(_S1858)
            {
                _S1859 = (_S1694.x) == (_S1694.y);
            }
            else
            {
                _S1859 = false;
            }
            BSDFMaterial _S1953 = _S1693;
            bool _S1954 = isTranslucent_0(&_S1953);
            if(_S1954)
            {
                _S1860 = _S1946;
            }
            else
            {
                _S1860 = false;
            }
            if(_S1860)
            {
                _S1861 = (dot_0(throughput_9, surface_12.geometry_n)) < 0.0f;
            }
            else
            {
                _S1861 = false;
            }
            if(nee_0)
            {
                _S1862 = !_S1855;
            }
            else
            {
                _S1862 = false;
            }
            if(_S1862)
            {
                _S1863 = !wrong_side_0;
            }
            else
            {
                _S1863 = false;
            }
            if(_S1863)
            {
                float _S1955 = (&lobe_5)->pdf;
                float3  _S1956 = (&ray_2)->origin;
                float3  _S1957 = _slang_select(_S1706, _S1480,_S1670.smooth_n);
                float3  _S1958 = (&ray_2)->origin;
                FKSurface _S1959 = surface_12;
                float3  _S1960 = - _S1670.smooth_n;
                float3  _S1961 = _slang_select(_S1861, _S1960,_S1670.smooth_n);
                NEEVertex _S1962 = NEEVertex_x24init_0(false, _S1955, _S1956, _S1957, _S1958 + make_float3 (_S1959.geometry_offset) * _S1961);
                nee_vertex_0 = _S1962;
            }
            else
            {
                if(_S1701)
                {
                    _S1864 = true;
                }
                else
                {
                    bool _S1963 = b_9 != 1U;
                    if(_S1963)
                    {
                        _S1864 = true;
                    }
                    else
                    {
                        _S1864 = (_S1694.x) != (_S1694.y);
                    }
                }
                if(_S1864)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1964 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1964)
            {
                if(_S1854)
                {
                    _S1864 = true;
                }
                else
                {
                    _S1864 = ((&lobe_5)->pdf * (&prev_0)->cos / ((&hit_4)->distance * (&hit_4)->distance) * threshold_0) <= 1.0f;
                }
            }
            else
            {
                _S1864 = false;
            }
            bool _S1965 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1965)
            {
                if(_S1854)
                {
                    _S1865 = true;
                }
                else
                {
                    _S1865 = _S1948 >= 0.20000000298023224f;
                }
            }
            else
            {
                _S1865 = false;
            }
            if(_S1739)
            {
                bool _S1966 = !_S1864;
                if(_S1966)
                {
                    return _S1481;
                }
                bool _S1967 = _S1486 != 1U;
                if(_S1967)
                {
                    _S1866 = _S1486 != 2U;
                }
                else
                {
                    _S1866 = false;
                }
                if(_S1866)
                {
                    float _S1968 = (&lobe_5)->pdf;
                    float _S1969 = _slang_select(nee_0, _S1968,0.0f);
                    float _S1970 = escapeWeight_0(_S1969, _S1873);
                    if(_S1747)
                    {
                        passes_0 = _S1492;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1971 = _slang_select(passes_0, _S1970,1.0f);
                    return Shift_x24init_0(throughput_7 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_8->radiance * make_float3 (_S1971) / make_float3 (r_8->jac), density_4 * (&lobe_5)->pdf / r_8->jac);
                }
                float3  _S1972 = throughput_7 * make_float3 ((&lobe_5)->pdf);
                float _S1973 = density_4 * (&lobe_5)->pdf;
                throughput_10 = _S1972;
                density_6 = _S1973;
            }
            else
            {
                throughput_10 = throughput_7;
                density_6 = density_4;
            }
            uint _S1974 = (fcptLayers((hit_4)));
            bool _S1975 = _S1974 > 1U;
            if(_S1975)
            {
                _S1866 = (b_9 == 1U) != passes_0;
            }
            else
            {
                _S1866 = false;
            }
            if(viewed_1)
            {
                _S1867 = _S1866;
            }
            else
            {
                _S1867 = false;
            }
            if(_S1867)
            {
                return _S1481;
            }
            if(replay_1)
            {
                _S1868 = b_6 <= _S1496;
            }
            else
            {
                _S1868 = false;
            }
            if(_S1868)
            {
                _S1869 = _S1669;
            }
            else
            {
                _S1869 = false;
            }
            bool _S1976;
            if(_S1869)
            {
                _S1976 = _S1864;
            }
            else
            {
                _S1976 = false;
            }
            bool _S1977;
            if(_S1976)
            {
                _S1977 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1977 = !_S1865;
                }
                else
                {
                    _S1977 = false;
                }
            }
            if(_S1977)
            {
                return _S1481;
            }
            if(viewed_1)
            {
                float3  _S1978 = throughput_10 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1979 = (&lobe_5)->pdf;
                throughput_11 = _S1978;
                sky_pdf_2 = _S1979;
            }
            else
            {
                float3  _S1980 = throughput_10 * max_0((&lobe_5)->throughput, _S1480);
                throughput_11 = _S1980;
                sky_pdf_2 = density_6;
            }
            bool _S1981;
            if(_S1711)
            {
                _S1981 = !_S1726;
            }
            else
            {
                _S1981 = false;
            }
            bool _S1982;
            if(_S1981)
            {
                _S1982 = _S1669;
            }
            else
            {
                _S1982 = false;
            }
            bool _S1983;
            if(_S1982)
            {
                _S1983 = _S1864;
            }
            else
            {
                _S1983 = false;
            }
            float3  chain_throughput_1;
            if(_S1983)
            {
                chain_0 = here_0;
                uint _S1984 = insertBits_0((&chain_0)->path, b_9, 18U, 3U);
                uint _S1985 = _slang_select(nee_0, 1U,0U);
                uint _S1986 = insertBits_0(_S1984, _S1985, 21U, 1U);
                (&chain_0)->path = _S1986;
                float _S1987 = (&chain_0)->jac * (&lobe_5)->pdf;
                (&chain_0)->jac = _S1987;
                (&chain_0)->dir = throughput_9;
                chain_throughput_1 = throughput_11;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1988 = surface_12;
            Vertex _S1989 = Vertex_x24init_0(_S1865, b_9, (&lobe_5)->pdf, (F32_abs((dot_0(surface_12.geometry_n, throughput_9)))), is_inside_6);
            prev_0 = _S1989;
            float _S1990 = (&lobe_5)->pdf;
            bool _S1991 = b_9 == 1U;
            bool _S1992;
            if(_S1991)
            {
                _S1992 = (_S1694.x) == (_S1694.y);
            }
            else
            {
                _S1992 = false;
            }
            float sky_pdf_3 = _slang_select(_S1992, sky_pdf_0,_S1990);
            float _S1993 = _slang_select(_S1701, 0.0f,sky_pdf_3);
            float _S1994 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * (&lobe_5)->pdf))))), (3.14159274101257324f)));
            bool _S1995 = !_S1855;
            float _S1996 = _slang_select(_S1995, _S1994,0.0f);
            float _S1997 = spread_1 + _S1996;
            bool _S1998;
            if(refracted_4)
            {
                _S1998 = !_S1861;
            }
            else
            {
                _S1998 = false;
            }
            bool is_inside_7;
            if(_S1998)
            {
                bool _S1999 = !is_inside_6;
                is_inside_7 = _S1999;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            FKSurface _S2000 = surface_12;
            bool _S2001 = boundsVolume_0(&_S2000);
            bool _S2002;
            if(_S2001)
            {
                _S2002 = !_S1866;
            }
            else
            {
                _S2002 = false;
            }
            if(_S2002)
            {
                FKSurface faced_2 = surface_12;
                float3  _S2003 = - _S1988.geometry_n;
                float3  _S2004 = _slang_select(turned_1, _S2003,_S1988.geometry_n);
                (&faced_2)->geometry_n = _S2004;
                FKMedium _S2005 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S2006 = (fcptOutsideMedium((hit_4)));
                FKSurface _S2007 = faced_2;
                FKMedium _S2008 = _S2005;
                FKMedium _S2009 = _S2006;
                MediumSides _S2010 = mediumSides_0(&_S2007, &_S2008, filling_2, (&ray_2)->unit_direction, &_S2009);
                bool _S2011 = ((dot_0(throughput_9, _S1988.geometry_n)) > 0.0f) == ((dot_0(_S1988.geometry_n, (&faced_2)->geometry_n)) > 0.0f);
                float3  _S2012 = _slang_select(_S2011, _S2010.front.scatter,_S2010.behind.scatter);
                scatter_in_0 = _S2012;
                float3  _S2013 = scatter_in_0;
                float _S2014 = upsample(scatter_in_0, wavelength_8);
                float3  _S2015 = make_float3 (_S2014);
                float3  _S2016 = _slang_select(_S1734, _S2015,_S2013);
                scatter_in_0 = _S2016;
                float3  _S2017 = _slang_select(_S2011, _S2010.front.extinction,_S2010.behind.extinction);
                extinction_in_0 = _S2017;
                float3  _S2018 = extinction_in_0;
                float _S2019 = upsample(extinction_in_0, wavelength_8);
                float3  _S2020 = make_float3 (_S2019);
                float3  _S2021 = _slang_select(_S1734, _S2020,_S2018);
                extinction_in_0 = _S2021;
                float _S2022 = _slang_select(_S2011, _S2010.front.g,_S2010.behind.g);
                g_in_0 = _S2022;
                uint _S2023 = _S2010.fillings.x;
                uint _S2024 = _S2010.fillings.y;
                uint _S2025 = _slang_select(_S2011, _S2024,_S2023);
                bool _S2026 = (fcptVaryingUsed());
                uint _S2027 = _slang_select(_S2026, _S2025,4294967295U);
                filling_2 = _S2027;
            }
            (&ray_2)->unit_direction = throughput_9;
            bool _S2028 = !_S1866;
            if(_S2028)
            {
                FKSurface _S2029 = surface_12;
                float _S2030 = _slang_select(straight_0, 0.0f,_S2029.geometry_offset);
                float3  _S2031 = - _S1670.smooth_n;
                bool _S2032 = is_inside_7 != _S1861;
                float3  _S2033 = _slang_select(_S2032, _S2031,_S1670.smooth_n);
                float3  _S2034 = (&ray_2)->origin + make_float3 (_S2030) * _S2033;
                (&ray_2)->origin = _S2034;
            }
            throughput_10 = throughput_11;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1866;
            viewed_1 = _S1859;
            sky_pdf_2 = _S1993;
            spread_4 = _S1997;
            reconnection_0 = reconnection_1;
            is_inside_5 = is_inside_7;
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
            is_inside_5 = is_inside_6;
        }
        float density_7;
        if(_S1711)
        {
            if(_S1632)
            {
                float3  _S2035 = pathColor(throughput_10 * emission_1, spectral_weight_0, wavelength_8);
                Reservoir candidate_8 = chain_0;
                uint _S2036 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S2037 = _S2036 == 1U;
                if(_S2037)
                {
                    float3  _S2038 = safeDivide(_S2035, chain_throughput_0);
                    (&candidate_8)->radiance = _S2038;
                }
                Reservoir _S2039 = withEnd(candidate_8, 2U, b_6, _S2035);
                offer(sel_7, _S2039, _S2035 * make_float3 (scale_3) / make_float3 (density_6));
            }
            if(_S1632)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S2040 = survivalProbability(abs_0(throughput_10), density_6);
                density_7 = _S2040;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S2041 = (fcptMaxBounces());
            bool _S2042 = b_6 >= _S2041;
            if(_S2042)
            {
                wrong_side_0 = true;
            }
            else
            {
                bool _S2043 = density_7 < 1.0f;
                if(_S2043)
                {
                    uint _S2044 = noiseAddress(_S1508, b_6);
                    Random _S2045 = draw(_S2044, 8U);
                    wrong_side_0 = density_7 < (_S2045.value);
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
            float _S2046 = density_6 * density_7;
            density_7 = _S2046;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S2047 = layer_0 ^ 1U;
        uint _S2048 = _slang_select(passes_0, _S2047,0U);
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
            uint _S2049 = b_9 + 1U;
            b_6 = _S2049;
            layer_0 = _S2048;
            continue;
        }
        FKRay _S2050 = ray_2;
        float _S2051 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_1)
        {
            refracted_4 = _S1740;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S1485 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S2052 = _slang_select(wrong_side_0, _S2051,4.294967296e+09f);
        bool _S2053 = !_S1701;
        if(straight_0)
        {
            _S1786 = true;
        }
        else
        {
            _S1786 = _S1701;
        }
        FKHit _S2054;
        if(_S1786)
        {
            _S2054 = hit_4;
        }
        else
        {
            _S2054 = _S1757;
        }
        FKHit _S2055 = (fcptTraverseInstanceBVH((_S2050), (_S1639), (_S2052), (_S2053), (_S2054), (viewed_1)));
        hit_4 = _S2055;
        if(replay_1)
        {
            _S1787 = _S1740;
        }
        else
        {
            _S1787 = false;
        }
        if(_S1787)
        {
            _S1854 = _S1485 == 1U;
        }
        else
        {
            _S1854 = false;
        }
        if(_S1854)
        {
            _S1855 = ((&hit_4)->instance_index) == (_S1497.instance_index);
        }
        else
        {
            _S1855 = false;
        }
        if(_S1855)
        {
            _S1856 = ((&hit_4)->triangle_index) == (_S1497.triangle_index);
        }
        else
        {
            _S1856 = false;
        }
        if(_S1856)
        {
            (&hit_4)->uv = _S1497.uv;
            float _S2056 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S2056;
        }
        if(replay_1)
        {
            _S1857 = _S1740;
        }
        else
        {
            _S1857 = false;
        }
        if(_S1857)
        {
            _S1858 = _S1485 == 3U;
        }
        else
        {
            _S1858 = false;
        }
        if(_S1858)
        {
            _S1859 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1859 = false;
        }
        if(_S1859)
        {
            return _S1481;
        }
        Reservoir _S2057 = chain_0;
        uint _S2058 = filling_2;
        for(;;)
        {
            bool _S2059 = (fcptVaryingUsed());
            if(_S2059)
            {
                _S1860 = _S2058 != 4294967295U;
            }
            else
            {
                _S1860 = false;
            }
            float _S2060;
            if(_S1860)
            {
                float _S2061 = (fcptMajorant((_S2058)));
                _S2060 = _S2061;
            }
            else
            {
                _S2060 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_1)
            {
                _S1861 = _S1740;
            }
            else
            {
                _S1861 = false;
            }
            if(_S1861)
            {
                _S1862 = _S1485 == 1U;
            }
            else
            {
                _S1862 = false;
            }
            if(_S1862)
            {
                _S1863 = _S2060 > 0.0f;
            }
            else
            {
                _S1863 = false;
            }
            if(_S1863)
            {
                ended_0 = _S1481;
                sky_pdf_1 = sky_pdf_2;
                spread_2 = spread_4;
                width_4 = width_3;
                density_3 = density_7;
                throughput_11 = throughput_10;
                b_9 = b_6;
                _S1864 = true;
                break;
            }
            bool _S2062 = (&prev_0)->rough;
            if(_S2062)
            {
                _S1864 = !(_S2060 > 0.0f);
            }
            else
            {
                _S1864 = false;
            }
            (&prev_0)->rough = _S1864;
            uint _S2063 = b_6 + 320U;
            bool _S2064 = b_6 == 4294967295U;
            uint _S2065 = _slang_select(_S2064, 384U,_S2063);
            uint _S2066 = stream(_S1508, _S2065);
            uint tracking_1 = _S2066;
            weight_2 = throughput_3;
            glowed_0 = _S1480;
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
                    _S1479 = int(2);
                    break;
                }
                float _S2067 = (&hit_4)->distance;
                if(_S1860)
                {
                    float3  _S2068 = (&ray_2)->origin;
                    float3  _S2069 = (&ray_2)->unit_direction;
                    float _S2070 = (&hit_4)->distance;
                    bool _S2071 = b_9 == 4294967295U;
                    uint _S2072 = _slang_select(_S2071, 0U,b_9);
                    uint _S2073 = (&prev_0)->lobe;
                    uint _S2074 = _slang_select(_S2071, 3U,_S2073);
                    float _S2075 = (fcptTrackMedium((_S2058), (_S2068), (_S2069), (_S2070), (&tracking_1), (&weight_2), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S2072), (_S2074), (_S2071)));
                    spread_3 = _S2075;
                }
                else
                {
                    bool _S2076 = _S2060 > 0.0f;
                    if(_S2076)
                    {
                        uint _S2077 = noiseAddress(_S1508, b_9);
                        Random _S2078 = draw(_S2077, 10U);
                        float _S2079 = - (F32_log((1.0f - _S2078.value))) / _S2060;
                        spread_3 = _S2079;
                    }
                    else
                    {
                        spread_3 = _S2067;
                    }
                }
                bool _S2080 = !(spread_3 < ((&hit_4)->distance));
                if(_S2080)
                {
                    _S1479 = int(2);
                    break;
                }
                if(_S1860)
                {
                    _S1865 = _S1711;
                }
                else
                {
                    _S1865 = false;
                }
                if(_S1865)
                {
                    float3  _S2081 = pathColor(throughput_11 * glowed_0, spectral_weight_0, wavelength_8);
                    float3  _S2082 = _S2081 / make_float3 (density_3);
                    float3  _S2083 = sel_7->glow + _S2082;
                    sel_7->glow = _S2083;
                }
                else
                {
                }
                glowed_0 = _S1480;
                uint b_10 = b_9 + 1U;
                float3  _S2084 = (&ray_2)->origin + make_float3 (spread_3) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S2084;
                float3  _S2085 = flightWeight_0(scatter_in_0, extinction_in_0, _S2060, spread_3, true);
                float3  _S2086 = weight_2;
                float _S2087 = upsample(weight_2, wavelength_8);
                float3  _S2088 = make_float3 (_S2087);
                float3  _S2089 = _slang_select(_S1734, _S2088,_S2086);
                float3  _S2090 = _slang_select(_S1860, _S2089,_S2085);
                float3  throughput_12 = throughput_11 * _S2090;
                uint _S2091 = stream(_S1508, b_10 + 320U);
                tracking_1 = _S2091;
                weight_2 = throughput_3;
                float width_7 = width_4 + spread_2 * spread_3;
                float _S2092 = spread_2 + 3.14159274101257324f;
                if(_S1711)
                {
                    _S1866 = true;
                }
                else
                {
                    bool _S2093 = b_10 == _S1496;
                    if(_S2093)
                    {
                        _S1866 = !_S1860;
                    }
                    else
                    {
                        _S1866 = false;
                    }
                }
                TreeSample light_4;
                if(_S1866)
                {
                    float3  _S2094 = (&ray_2)->origin;
                    float3  _S2095 = (&ray_2)->unit_direction;
                    float3  _S2096 = (&ray_2)->unit_direction;
                    uint _S2097 = noiseAddress(_S1508, b_10);
                    float3  _S2098 = extinction_in_0;
                    float3  _S2099 = extinction_in_0;
                    uint2  _S2100 = make_uint2 (_S2058);
                    float3  _S2101 = (&ray_2)->unit_direction;
                    uint _S2102 = arrivalLobe_0(b_10, (&prev_0)->lobe);
                    FKHit _S2103 = _S1757;
                    ShadowContext _S2104 = ShadowContext_x24init_0(_S2098, _S2099, _S2100, _S2101, b_10, _S2102, false, spread_3, width_7, &_S2103, false);
                    ShadowContext _S2105 = _S2104;
                    TreeSample _S2106 = sampleLightTree_0(_S2094, _S2095, _S2096, 0.0f, true, _S2097, &_S2105);
                    light_4 = _S2106;
                }
                else
                {
                    light_4 = _S1754;
                }
                float _S2107 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S2108 = (fcptMaxBounces());
                bool _S2109 = b_10 < _S2108;
                if(_S2109)
                {
                    _S1867 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1867 = false;
                }
                float _S2110 = _slang_select(_S1867, _S2107,0.0f);
                float3  _S2111 = throughput_12 * light_4.radiance;
                float _S2112 = powerHeuristic(light_4.density, _S2110);
                float3  _S2113 = pathColor(_S2111 * make_float3 (_S2107 * _S2112), spectral_weight_0, wavelength_8);
                float3  _S2114 = _slang_select(_S1866, _S2113,_S1480);
                if(replay_1)
                {
                    _S1868 = b_10 == _S1496;
                }
                else
                {
                    _S1868 = false;
                }
                if(_S1868)
                {
                    bool _S2115 = _S1485 == 2U;
                    if(_S2115)
                    {
                        float _S2116 = resamplingTarget(_S2114);
                        _S1869 = _S2116 > 0.0f;
                    }
                    else
                    {
                        _S1869 = false;
                    }
                    if(_S1869)
                    {
                        Shift _S2117 = Shift_x24init_0(_S2114, 1.0f);
                        _S1479 = int(1);
                        ended_0 = _S2117;
                        spread_3 = _S2092;
                        width_5 = width_7;
                        throughput_9 = throughput_12;
                        b_7 = b_10;
                        break;
                    }
                    _S1479 = int(1);
                    ended_0 = _S1481;
                    spread_3 = _S2092;
                    width_5 = width_7;
                    throughput_9 = throughput_12;
                    b_7 = b_10;
                    break;
                }
                if(_S1711)
                {
                    Reservoir candidate_9 = _S2057;
                    uint _S2118 = extractBits_0(_S2057.path, 24U, 8U);
                    uint _S2119 = insertBits_0(0U, _S2118, 24U, 8U);
                    uint _S2120 = extractBits_0(_S2057.path, 10U, 2U);
                    bool _S2121 = _S2120 == 1U;
                    if(_S2121)
                    {
                        float3  _S2122 = safeDivide(_S2114, chain_throughput_0);
                        (&candidate_9)->radiance = _S2122;
                    }
                    else
                    {
                        uint _S2123 = insertBits_0(_S2119, b_10 + 1U, 5U, 5U);
                        uint _S2124 = insertBits_0(_S2123, 2U, 10U, 2U);
                        (&candidate_9)->path = _S2124;
                    }
                    Reservoir _S2125 = withEnd(candidate_9, 0U, b_10, _S2114);
                    offer(sel_7, _S2125, _S2114 * make_float3 (scale_3) / make_float3 (density_3));
                    float _S2126 = survivalProbability(abs_0(throughput_12), density_3);
                    uint _S2127 = (fcptMaxBounces());
                    bool _S2128 = b_10 >= _S2127;
                    if(_S2128)
                    {
                        _S1869 = true;
                    }
                    else
                    {
                        bool _S2129 = _S2126 < 1.0f;
                        if(_S2129)
                        {
                            uint _S2130 = noiseAddress(_S1508, b_10);
                            Random _S2131 = draw(_S2130, 8U);
                            _S1869 = _S2126 < (_S2131.value);
                        }
                        else
                        {
                            _S1869 = false;
                        }
                    }
                    if(_S1869)
                    {
                        _S1479 = int(1);
                        ended_0 = _S1481;
                        spread_3 = _S2092;
                        width_5 = width_7;
                        throughput_9 = throughput_12;
                        b_7 = b_10;
                        break;
                    }
                    float _S2132 = density_3 * _S2126;
                    density_3 = _S2132;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S2133 = noiseAddress(_S1508, b_10);
                float3  _S2134 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S2133, &phase_pdf_1);
                (&ray_2)->unit_direction = _S2134;
                NEEVertex _S2135 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1480, (&ray_2)->origin);
                nee_vertex_0 = _S2135;
                Vertex _S2136 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_5);
                prev_0 = _S2136;
                float _S2137 = (&prev_0)->pdf;
                FKRay _S2138 = ray_2;
                FKHit _S2139 = (fcptTraverseInstanceBVH((_S2138), (true), (4.294967296e+09f), (false), (_S1757), (false)));
                hit_4 = _S2139;
                b_9 = b_10;
                throughput_11 = throughput_12;
                spread_2 = _S2092;
                width_4 = width_7;
                sky_pdf_1 = _S2137;
            }
            if(_S1479 != int(2))
            {
                spread_2 = spread_3;
                width_4 = width_5;
                throughput_11 = throughput_9;
                b_9 = b_7;
                _S1864 = true;
                break;
            }
            ended_0 = _S1481;
            _S1864 = false;
            break;
        }
        if(_S1864)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1865 = b_9 == b_6;
        }
        else
        {
            _S1865 = false;
        }
        bool _S2140 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S2140)
        {
            bool _S2141 = !(&nee_vertex_0)->none;
            float _S2142 = _slang_select(_S2141, sky_pdf_1,0.0f);
            float _S2143 = escapeWeight_0(_S2142, (&ray_2)->unit_direction);
            float3  _S2144 = environment_0((&ray_2)->unit_direction, b_9, (&prev_0)->lobe);
            float3  _S2145 = pathColor(throughput_11 * _S2144, spectral_weight_0, wavelength_8);
            if(replay_1)
            {
                bool _S2146 = b_9 == _S1496;
                if(_S2146)
                {
                    passes_0 = _S1485 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S2145 * make_float3 (_S2143) / make_float3 (r_8->jac), density_3 / r_8->jac);
                }
                if(_S1495)
                {
                    passes_0 = _S1492;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_9 == _S1483;
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
                    return Shift_x24init_0(_S2145 * make_float3 (_S2143), 1.0f);
                }
                return _S1481;
            }
            Reservoir candidate_10 = chain_0;
            uint _S2147 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S2148 = _S2147 == 1U;
            if(_S2148)
            {
                uint _S2149 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S2150 = _S2149 == b_9;
                float _S2151 = _slang_select(_S2150, 1.0f,_S2143);
                float3  _S2152 = safeDivide(_S2145 * make_float3 (_S2151), chain_throughput_0);
                (&candidate_10)->radiance = _S2152;
            }
            else
            {
                bool _S2153 = (&prev_0)->rough;
                if(_S2153)
                {
                    uint _S2154 = insertBits_0(_S1510, b_9 + 1U, 5U, 5U);
                    uint _S2155 = insertBits_0(_S2154, 3U, 10U, 2U);
                    uint _S2156 = insertBits_0(_S2155, (&prev_0)->lobe, 15U, 3U);
                    bool _S2157 = (&prev_0)->inside;
                    uint _S2158 = _slang_select(_S2157, 1U,0U);
                    uint _S2159 = insertBits_0(_S2156, _S2158, 22U, 1U);
                    (&candidate_10)->path = _S2159;
                    (&candidate_10)->jac = (&prev_0)->pdf;
                    (&candidate_10)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S2160 = _S2145 * make_float3 (_S2143);
            Reservoir _S2161 = withEnd(candidate_10, 3U, b_9, _S2160);
            offer(sel_7, _S2161, _S2160 * make_float3 (scale_3) / make_float3 (density_3));
            break;
        }
        float3  _S2162 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S2162;
        bool _S2163 = (fcptVaryingUsed());
        if(_S2163)
        {
            _S1866 = filling_2 != 4294967295U;
        }
        else
        {
            _S1866 = false;
        }
        if(_S1866)
        {
            if(_S1711)
            {
                float3  _S2164 = pathColor(throughput_11 * glowed_0, spectral_weight_0, wavelength_8);
                float3  _S2165 = _S2164 / make_float3 (density_3);
                float3  _S2166 = sel_7->glow + _S2165;
                sel_7->glow = _S2166;
            }
            float3  _S2167 = throughput_11 * weight_2;
            throughput_9 = _S2167;
        }
        else
        {
            float3  _S2168 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S2169 = throughput_11 * _S2168;
            throughput_9 = _S2169;
        }
        float _S2170 = width_4 + spread_2 * (&hit_4)->distance;
        viewed_0 = _S1865;
        width_3 = _S2170;
        throughput_2 = throughput_9;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_1 = spread_2;
        uint _S2049 = b_9 + 1U;
        b_6 = _S2049;
        layer_0 = _S2048;
    }
    return _S1481;
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
    Random _S2171 = pcg(state_4);
    Random _S2172 = pcg(_S2171.state);
    float _S2173 = 6.28318548202514648f * _S2171.value;
    float _S2174 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S2172.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S2172.state, _S2174 * (F32_cos((_S2173))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_5, float3  value_2)
{
    RandomSphere _S2175;
    (&_S2175)->state = state_5;
    (&_S2175)->value = value_2;
    return _S2175;
}

__device__ RandomSphere random_sphere(uint state_6)
{
    Random _S2176 = normal_distribution(state_6);
    Random _S2177 = normal_distribution(_S2176.state);
    Random _S2178 = normal_distribution(_S2177.state);
    float3  _S2179 = make_float3 (_S2176.value, _S2177.value, _S2178.value);
    float3  _S2180 = ((((_S2179)) * make_float3(rnorm3df(((_S2179)).x, ((_S2179)).y, ((_S2179)).z))));
    return RandomSphere_x24init_0(_S2178.state, _S2180);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_14)
{
    float3  _S2181 = p1_0 - p0_0;
    float3  _S2182 = p2_0 - p0_0;
    float2  _S2183 = uv1_0 - uv0_0;
    float2  _S2184 = uv2_0 - uv0_0;
    float _S2185 = _S2183.x;
    float _S2186 = _S2184.y;
    float _S2187 = _S2183.y;
    float _S2188 = _S2184.x;
    float _S2189 = _S2185 * _S2186 - _S2187 * _S2188;
    float _S2190 = 1.0f / _S2189;
    float3  t_24 = (_S2181 * make_float3 (_S2186) - _S2182 * make_float3 (_S2187)) * make_float3 (_S2190);
    float3  _S2191 = (_S2182 * make_float3 (_S2185) - _S2181 * make_float3 (_S2188)) * make_float3 (_S2190);
    float3  _S2192 = t_24 - n_14 * make_float3 (dot_0(n_14, t_24));
    float3  t_25 = ((((_S2192)) * make_float3(rnorm3df(((_S2192)).x, ((_S2192)).y, ((_S2192)).z))));
    bool _S2193 = (dot_0(cross_0(n_14, t_25), _S2191)) > 0.0f;
    float3  t_26;
    if(_S2193)
    {
        float3  _S2194 = negate_0(t_25);
        t_26 = _S2194;
    }
    else
    {
        t_26 = t_25;
    }
    float3  _S2195 = cross_0(n_14, t_26);
    return makeMatrix<float, 3, 3> (t_26, _S2195, n_14);
}

__device__ float3  tangentToWorldNormalMap(float3  v_13, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_13, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_4, float3  uvw_0, float3  position_1)
{
    float3  _S2196 = t1_0 - t0_0;
    float3  _S2197 = t2_2 - t0_0;
    float3  _S2198 = t2_2 - t1_0;
    float _S2199 = (F32_min((length_0(_S2196)), ((F32_min((length_0(_S2197)), (length_0(_S2198)))))));
    float3  _S2200 = make_float3 (distance_1(position_1, t0_0), distance_1(position_1, t1_0), distance_1(position_1, t2_2));
    float3  _S2201 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S2202 = dot_0(geometry_n_4, _S2201);
    float3  _S2203 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S2204 = dot_0(geometry_n_4, _S2203);
    float3  _S2205 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S2206 = acos_0(abs_0(make_float3 (_S2202, _S2204, dot_0(geometry_n_4, _S2205))));
    float3  _S2207 = clamp_2(tan_0(_S2206), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S2200 * _S2207, uvw_0), 0.0f, _S2199 * 0.125f);
}

__device__ float3  straightThrough(float3  dir_17, float3  n_15, BSDFMaterial material_29)
{
    float3  _S2208 = negate_0(dir_17);
    float _S2209 = sign_0(dot_0(n_15, _S2208));
    float3  _S2210 = n_15 * make_float3 (_S2209);
    AnisotropicFrame _S2211 = anisotropicFrame(material_29, _S2210);
    bool _S2212 = (_S2211.alphas.x) > 0.0f;
    if(_S2212)
    {
        float _S2213 = material_29.transmission * (1.0f - material_29.metallic);
        float3  _S2214 = negate_0(_S2210);
        float3  _S2215 = anisotropicLocal(dir_17, _S2211.tangent, _S2214);
        float _S2216 = anisotropicG1(_S2215, _S2211.alphas);
        return make_float3 (_S2213 * _S2216) * material_29.albedo;
    }
    float _S2217 = material_29.transmission * (1.0f - material_29.metallic);
    float _S2218 = material_29.roughness;
    float _S2219 = smithG1(_S2218 * _S2218, (F32_abs((dot_0(n_15, dir_17)))));
    return make_float3 (_S2217 * _S2219) * material_29.albedo;
}

__device__ float hairRow(float3  in_dir_13, float3  t_27, float3  out_dir_3, uint p_17, float w_20, float alpha_10, uint nt_0)
{
    uint _S2220 = p_17 % 4U;
    float _S2221 = w_20 * HAIR_WIDTHS_0[_S2220];
    float _S2222 = (F32_asin((clamp_1(dot_0(out_dir_3, t_27), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_13, t_27), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S2220] * alpha_10;
    return ((F32_asinh((_S2222 / _S2221))) / (F32_asinh((3.14159274101257324f / _S2221))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_14, float3  t_28, float3  out_dir_4, uint np_0)
{
    float3  _S2223 = worldToTangent(out_dir_4, t_28);
    float3  _S2224 = worldToTangent(in_dir_14, t_28);
    return (F32_frac((((F32_atan2((_S2223.z), (_S2223.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S2224.z), (1.17549435082228751e-38f - _S2224.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_15, float3  t_29, uint p_18, float row_0, float column_0, float w_21, float alpha_11, uint nt_1, uint np_1)
{
    float3  _S2225 = worldToTangent(in_dir_15, t_29);
    uint _S2226 = p_18 % 4U;
    float _S2227 = w_21 * HAIR_WIDTHS_0[_S2226];
    float _S2228 = (F32_asin((clamp_1(dot_0(in_dir_15, t_29), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S2226] * alpha_11 + _S2227 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S2227))))));
    float _S2229 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S2225.z), (1.17549435082228751e-38f - _S2225.x)));
    float _S2230 = (F32_cos((_S2228)));
    float3  _S2231 = tangentToWorld(make_float3 (_S2230 * (F32_cos((_S2229))), (F32_sin((_S2228))), _S2230 * (F32_sin((_S2229)))), t_29);
    return _S2231;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_16, BSDFMaterial material_30, float coverage_1)
{
    float3  through_2;
    if((material_30.ior) == 1.0f)
    {
        float3  _S2232 = straightThrough(toward_1, n_16, material_30);
        through_2 = _S2232;
    }
    else
    {
        through_2 = make_float3 (0.0f);
    }
    CoatFrame _S2233 = coatFrame(material_30, n_16);
    bool _S2234 = (_S2233.ior) > 0.0f;
    if(_S2234)
    {
        float _S2235 = fresnel((F32_abs((dot_0(_S2233.normal, toward_1)))), 1.0f, _S2233.ior);
        float3  _S2236 = mix_0(make_float3 (1.0f), make_float3 (1.0f - _S2235) * material_30.coat_tint, material_30.coat);
        float3  through_3 = through_2 * _S2236;
        through_2 = through_3;
    }
    return through_2 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_9, Reservoir r_9, bool replay_2, float scale_4, Selection * sel_8)
{
    Domain _S2237 = dom_9;
    Reservoir _S2238 = r_9;
    Shift _S2239 = walk_0(&_S2237, &_S2238, replay_2, scale_4, sel_8);
    return _S2239;
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
        uint _S2240;
        if(i_27 < 2U)
        {
            _S2240 = x_29;
        }
        else
        {
            _S2240 = (x_29 + size_0 / 2U) & (size_0 - 1U);
        }
        uint l_6 = _S2240;
        uint r_10 = y_8;
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
            uint _S2241 = hash(((r_10 ^ (t_30 << 16U)) ^ (k_4 << 28U)) ^ ((i_27 & 1U) << 31U));
            uint _S2242 = l_6 ^ (_S2241 & (size_0 - 1U));
            uint k_5 = k_4 + 1U;
            l_6 = r_10;
            r_10 = _S2242;
            k_4 = k_5;
        }
        uint _S2243 = l_6 + r_10 * size_0;
        uint _S2244 = size_0 * size_0;
        uint _S2245;
        if(_S2244 >= 65536U)
        {
            uint _S2246 = _S2243 / (_S2244 / 65536U);
            _S2245 = _S2246;
        }
        else
        {
            uint _S2247 = 65536U / _S2244;
            _S2245 = _S2243 * _S2247;
        }
        ranks_0[i_27] = _S2245;
        uint i_28 = i_27 + 1U;
        i_27 = i_28;
    }
    bool _S2248 = (ranks_0[int(0)]) == 65535U;
    bool _S2249;
    if(_S2248)
    {
        _S2249 = (ranks_0[int(1)]) == 65535U;
    }
    else
    {
        _S2249 = false;
    }
    bool _S2250 = (ranks_0[int(2)]) == 65535U;
    bool _S2251;
    if(_S2250)
    {
        _S2251 = (ranks_0[int(3)]) == 65535U;
    }
    else
    {
        _S2251 = false;
    }
    if(_S2249)
    {
        _S2249 = (ranks_0[int(3)]) != 65535U;
    }
    else
    {
        _S2249 = false;
    }
    if(_S2249)
    {
        _S2249 = true;
    }
    else
    {
        if(_S2251)
        {
            _S2249 = (ranks_0[int(1)]) != 65535U;
        }
        else
        {
            _S2249 = false;
        }
    }
    uint _S2252 = ranks_0[int(0)];
    if(_S2249)
    {
        i_27 = ranks_0[int(3)];
    }
    else
    {
        i_27 = ranks_0[int(1)];
    }
    return _S2252 | (i_27 << 16U);
}

__device__ uint3  noiseBlock(uint sweep_0, uint colour_0, uint block_0, uint size_1)
{
    uint _S2253 = hash(sweep_0 * 7919U + 1U);
    uint _S2254 = size_1 / 16U;
    uint _S2255 = block_0 % _S2254;
    uint _S2256 = block_0 / _S2254;
    uint _S2257 = _S2256 % _S2254;
    uint _S2258 = block_0 / (_S2254 * _S2254);
    uint3  _S2259 = make_uint3 (_S2255, _S2257, _S2258);
    uint3  _S2260 = make_uint3 (colour_0 & 1U, (colour_0 >> 1U) & 1U, colour_0 >> 2U);
    return _S2259 * make_uint3 (16U) + _S2260 * make_uint3 (8U) + make_uint3 (_S2253 & 7U, (_S2253 >> 3U) & 7U, (_S2253 >> 6U) & 7U);
}

#undef Matrix
