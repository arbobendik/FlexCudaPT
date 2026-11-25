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
    float _S345;
    if(_S341 == 4294967295U)
    {
        Random _S346 = pcg(_S344.state);
        _S345 = _slang_select(_S342, _S346.value,_S344.value);
    }
    else
    {
        uint _S347 = _S341 & 65535U;
        uint _S348 = _S341 >> 16U;
        _S345 = (float(_slang_select(_S342, _S348,_S347)) + 0.5f) / 6.5536e+04f;
    }
    return Random_x24init_0(address_0, _S345);
}

__device__ static const FixedArray<float, 243>  SPECTRAL_PRIMARIES_0 = { {
    0.028201999142766f, 9.99999997475242708e-07f, 0.97179698944091797f, 0.02820000052452087f, 0.0f, 0.97180002927780151f, 0.02819300070405006f, 0.0f, 0.97180700302124023f, 0.0281750001013279f, 0.0f, 0.9718250036239624f, 0.02813299931585789f, 0.0f, 0.97186702489852905f, 0.02804199978709221f, 0.0f, 0.9719579815864563f, 0.02786399982869625f, 0.0f, 0.97213602066040039f, 0.0275299996137619f, 0.0f, 0.9724699854850769f, 0.02692800015211105f, 0.0f, 0.97307199239730835f, 0.02592499926686287f, 0.0f, 0.97407501935958862f, 0.02444599941372871f, 0.0f, 0.97555398941040039f, 0.02258899994194508f, 0.0f, 0.97741097211837769f, 0.02068600058555603f, 0.0f, 0.97931402921676636f, 0.01939599961042404f, 0.0f, 0.98060399293899536f, 0.01972600072622299f, 0.0f, 0.9802740216255188f, 0.02305700071156025f, 0.0f, 0.97694301605224609f, 0.0282990001142025f, 0.00548999989405274f, 0.96621102094650269f, 0.02276800014078617f, 0.04560500010848045f, 0.93162697553634644f, 0.0118180001154542f, 0.11352799832820892f, 0.87465399503707886f, 0.00192399998195469f, 0.20037899911403656f, 0.79769700765609741f, 0.0f, 0.29692500829696655f, 0.70307499170303345f, 0.0f, 0.40064999461174011f, 0.5993499755859375f, 0.0f, 0.50742298364639282f, 0.49257698655128479f, 0.0f, 0.61289197206497192f, 0.38710799813270569f, 0.0f, 0.71311402320861816f, 0.28688600659370422f, 0.0f, 0.8042140007019043f, 0.1957859992980957f, 0.0f, 0.88220900297164917f, 0.11779099702835083f, 0.0f, 0.94313102960586548f, 0.05686900019645691f, 0.0f, 0.98336499929428101f, 0.01663500070571899f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.99855601787567139f, 0.00144400005228817f, 0.0f, 0.97892600297927856f, 0.02107400074601173f, 0.03028500080108643f, 0.92923498153686523f, 0.04047999903559685f, 0.10447199642658234f, 0.84615302085876465f, 0.04937500134110451f, 0.21104000508785248f, 0.73897498846054077f, 0.04998499900102615f, 0.33820000290870667f, 0.61719298362731934f, 0.04460699856281281f, 0.47420701384544373f, 0.49019300937652588f, 0.03559999912977219f, 0.60847699642181396f, 0.3664110004901886f, 0.02511199936270714f, 0.73185497522354126f, 0.25317299365997314f, 0.01497200038284063f, 0.83687901496887207f, 0.15642799437046051f, 0.00669299997389317f, 0.91802400350570679f, 0.08053100109100342f, 0.00144499994348735f, 0.97194302082061768f, 0.02805699966847897f, 0.0f, 0.99879997968673706f, 0.00120000005699694f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.99999898672103882f, 0.0f, 9.99999997475242708e-07f, 0.99999898672103882f, 0.0f, 9.99999997475242708e-07f, 0.99999898672103882f, 0.0f, 9.99999997475242708e-07f, 0.99999797344207764f, 9.99999997475242708e-07f, 9.99999997475242708e-07f, 0.99999797344207764f, 9.99999997475242708e-07f, 9.99999997475242708e-07f, 0.99999701976776123f, 9.99999997475242708e-07f, 1.99999999495048542e-06f, 0.99999499320983887f, 1.99999999495048542e-06f, 3.00000010611256585e-06f, 0.99999302625656128f, 1.99999999495048542e-06f, 4.99999987368937582e-06f, 0.99998897314071655f, 3.99999998990097083e-06f, 7.00000009601353668e-06f, 0.9999840259552002f, 6.00000021222513169e-06f, 0.00000999999974738f, 0.99997901916503906f, 0.0000079999999798f, 0.00001299999985349f, 0.99997401237487793f, 0.00000999999974738f, 0.0000159999999596f, 0.99997299909591675f, 0.00001200000042445f, 0.00001499999962107f, 0.99996697902679443f, 0.00001499999962107f, 0.00001800000063668f, 0.9999690055847168f, 0.00001499999962107f, 0.0000159999999596f, 0.9999619722366333f, 0.00001700000029814f, 0.00002099999983329f
} };
__device__ float upsample(float3  rgb_0, float wavelength_0)
{
    float _S349 = clamp_1((wavelength_0 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    uint _S350 = (U32_min((uint(_S349)), (79U)));
    uint _S351 = 3U * _S350;
    float3  _S352 = make_float3 (SPECTRAL_PRIMARIES_0[_S351], SPECTRAL_PRIMARIES_0[_S351 + 1U], SPECTRAL_PRIMARIES_0[_S351 + 2U]);
    float3  _S353 = make_float3 (SPECTRAL_PRIMARIES_0[_S351 + 3U], SPECTRAL_PRIMARIES_0[_S351 + 4U], SPECTRAL_PRIMARIES_0[_S351 + 5U]);
    return dot_0(rgb_0, _S352 + (_S353 - _S352) * make_float3 (_S349 - float(_S350)));
}

__device__ BSDFMaterial atWavelength(BSDFMaterial material_0, float wavelength_1)
{
    BSDFMaterial at_0 = material_0;
    float _S354 = upsample(material_0.albedo, wavelength_1);
    float3  _S355 = make_float3 (_S354);
    (&at_0)->albedo = _S355;
    float _S356 = upsample(material_0.emissive, wavelength_1);
    float3  _S357 = make_float3 (_S356);
    (&at_0)->emissive = _S357;
    float _S358 = upsample(material_0.absorption, wavelength_1);
    float3  _S359 = make_float3 (_S358);
    (&at_0)->absorption = _S359;
    float _S360 = upsample(material_0.specular_tint, wavelength_1);
    float3  _S361 = make_float3 (_S360);
    (&at_0)->specular_tint = _S361;
    float _S362 = upsample(material_0.translucent, wavelength_1);
    float3  _S363 = make_float3 (_S362);
    (&at_0)->translucent = _S363;
    float _S364 = upsample(material_0.sheen, wavelength_1);
    float3  _S365 = make_float3 (_S364);
    (&at_0)->sheen = _S365;
    float _S366 = upsample(material_0.coat_tint, wavelength_1);
    float3  _S367 = make_float3 (_S366);
    (&at_0)->coat_tint = _S367;
    return at_0;
}

__device__ BSDFMaterial pathMaterial(BSDFMaterial material_1, float wavelength_2)
{
    BSDFMaterial _S368;
    if(wavelength_2 > 0.0f)
    {
        BSDFMaterial _S369 = atWavelength(material_1, wavelength_2);
        _S368 = _S369;
    }
    else
    {
        _S368 = material_1;
    }
    return _S368;
}

static __device__ float3  negate_0(float3  x_13)
{
    return - x_13;
}

static __device__ float sign_0(float e_1)
{
    bool _S370 = e_1 < 0.0f;
    float _S371 = _slang_select(_S370, -1.0f,0.0f);
    bool _S372 = e_1 > 0.0f;
    float _S373 = _slang_select(_S372, 1.0f,_S371);
    return _S373;
}

struct AnisotropicFrame
{
    float3  tangent;
    float2  alphas;
};

static __device__ AnisotropicFrame AnisotropicFrame_x24init_0(float3  tangent_0, float2  alphas_0)
{
    AnisotropicFrame _S374;
    (&_S374)->tangent = tangent_0;
    (&_S374)->alphas = alphas_0;
    return _S374;
}

__device__ float3  tangentToWorld(float3  v_0, float3  n_1)
{
    float3  a_1 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S375 = (F32_abs((dot_0(n_1, a_1)))) > 0.9999847412109375f;
    float3  a_2;
    if(_S375)
    {
        float3  _S376 = make_float3 (1.0f, 0.0f, 0.0f);
        a_2 = _S376;
    }
    else
    {
        a_2 = a_1;
    }
    float3  _S377 = cross_0(n_1, a_2);
    float3  _S378 = ((((_S377)) * make_float3(rnorm3df(((_S377)).x, ((_S377)).y, ((_S377)).z))));
    float3  _S379 = cross_0(n_1, _S378);
    return make_float3 (v_0.x) * _S378 + make_float3 (v_0.y) * n_1 + make_float3 (v_0.z) * _S379;
}

__device__ AnisotropicFrame anisotropicFrame(BSDFMaterial material_2, float3  n_i_0)
{
    float _S380 = material_2.roughness;
    float _S381 = _S380 * _S380;
    bool _S382 = (material_2.anisotropy) == 0.0f;
    bool _S383;
    if(_S382)
    {
        _S383 = true;
    }
    else
    {
        _S383 = !(_S381 > 0.0f);
    }
    if(_S383)
    {
        return AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f));
    }
    float3  _S384 = material_2.tangent - n_i_0 * make_float3 (dot_0(n_i_0, material_2.tangent));
    float3  _S385 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_i_0);
    bool _S386 = (dot_0(_S384, _S384)) > 0.0f;
    float3  _S387 = _slang_select(_S386, _S384,_S385);
    float3  _S388 = ((((_S387)) * make_float3(rnorm3df(((_S387)).x, ((_S387)).y, ((_S387)).z))));
    float _S389 = 6.28318548202514648f * material_2.anisotropic_rotation;
    float _S390 = (F32_sqrt((1.0f - 0.89999997615814209f * (F32_abs((material_2.anisotropy))))));
    float _S391 = 1.0f / _S390;
    bool _S392 = (material_2.anisotropy) < 0.0f;
    float _S393 = _slang_select(_S392, _S391,_S390);
    return AnisotropicFrame_x24init_0(_S388 * make_float3 ((F32_cos((_S389)))) + cross_0(n_i_0, _S388) * make_float3 ((F32_sin((_S389)))), make_float2 (_S381 / _S393, _S381 * _S393));
}

struct SheenProfile
{
    bool on;
    float albedo;
};

static __device__ SheenProfile SheenProfile_x24init_0(bool on_0, float albedo_0)
{
    SheenProfile _S394;
    (&_S394)->on = on_0;
    (&_S394)->albedo = albedo_0;
    return _S394;
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
    SheenProfile _S395 = SheenProfile_x24init_0(false, 0.0f);
    float _S396 = rgb_to_greyscale(material_3.sheen);
    bool _S397 = _S396 > 0.0f;
    SheenProfile profile_0;
    if(_S397)
    {
        float _S398 = clamp_1((F32_sqrt(((F32_max((dot_0(n_i_1, v_1)), (0.0f)))))), 0.0f, 1.0f) * 23.0f;
        uint _S399 = (U32_min((uint(_S398)), (22U)));
        float _S400 = (F32_sqrt((0.05000000074505806f)));
        float _S401 = (F32_sqrt((0.00999999977648258f)));
        bool _S402 = (material_3.velvet) > 0.0f;
        float _S403 = _slang_select(_S402, _S401,_S400);
        float _S404 = (clamp_1((F32_sqrt(((F32_max((material_3.sheen_roughness), (0.0f)))))), _S403, 1.0f) - _S403) / (1.0f - _S403) * 23.0f;
        uint _S405 = (U32_min((uint(_S404)), (22U)));
        uint _S406 = _S399 * 24U + _S405;
        float _S407 = _S398 - float(_S399);
        float _S408 = _S404 - float(_S405);
        if(_S402)
        {
            uint _S409 = _S406 + 24U;
            float _S410 = VELVET_ALBEDO_0[_S406] + (VELVET_ALBEDO_0[_S409] - VELVET_ALBEDO_0[_S406]) * _S407;
            uint _S411 = _S406 + 1U;
            float _S412 = VELVET_ALBEDO_0[_S411] + (VELVET_ALBEDO_0[_S409 + 1U] - VELVET_ALBEDO_0[_S411]) * _S407;
            SheenProfile _S413 = SheenProfile_x24init_0(true, _S410 + (_S412 - _S410) * _S408);
            profile_0 = _S413;
        }
        else
        {
            uint _S414 = _S406 + 24U;
            float _S415 = SHEEN_ALBEDO_0[_S406] + (SHEEN_ALBEDO_0[_S414] - SHEEN_ALBEDO_0[_S406]) * _S407;
            uint _S416 = _S406 + 1U;
            float _S417 = SHEEN_ALBEDO_0[_S416] + (SHEEN_ALBEDO_0[_S414 + 1U] - SHEEN_ALBEDO_0[_S416]) * _S407;
            SheenProfile _S418 = SheenProfile_x24init_0(true, (F32_exp((_S415 + (_S417 - _S415) * _S408))));
            profile_0 = _S418;
        }
    }
    else
    {
        profile_0 = _S395;
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
    CoatFrame _S419;
    (&_S419)->normal = normal_3;
    (&_S419)->alpha = alpha_0;
    (&_S419)->ior = ior_0;
    return _S419;
}

__device__ __forceinline__ CoatFrame coatFrame(BSDFMaterial material_4, float3  n_2)
{
    CoatFrame _S420 = CoatFrame_x24init_0(make_float3 (0.0f), 0.0f, 0.0f);
    bool _S421 = (material_4.coat) > 0.0f;
    CoatFrame frame_0;
    if(_S421)
    {
        float3  _S422 = material_4.coat_normal;
        bool _S423 = (dot_0(_S422, _S422)) > 0.0f;
        float3  _S424 = material_4.coat_normal;
        float3  _S425 = ((((_S424)) * make_float3(rnorm3df(((_S424)).x, ((_S424)).y, ((_S424)).z))));
        float3  _S426 = _slang_select(_S423, _S425,n_2);
        float _S427 = sign_0(dot_0(_S426, n_2));
        float _S428 = material_4.coat_roughness;
        CoatFrame _S429 = CoatFrame_x24init_0(_S426 * make_float3 (_S427), _S428 * _S428, (F32_max((material_4.coat_ior), (1.00999999046325684f))));
        frame_0 = _S429;
    }
    else
    {
        frame_0 = _S420;
    }
    return frame_0;
}

__device__ __forceinline__ float3  coatSeries(CoatFrame coat_frame_0, BSDFMaterial material_5)
{
    float3  _S430 = make_float3 (0.0f);
    bool _S431 = (coat_frame_0.ior) > 0.0f;
    float3  series_0;
    if(_S431)
    {
        float _S432 = coat_frame_0.ior * coat_frame_0.ior;
        float _S433 = _S432 * _S432;
        float _S434 = coat_frame_0.ior - 1.0f;
        float _S435 = coat_frame_0.ior + 1.0f;
        float _S436 = _S432 - 1.0f;
        float _S437 = _S432 + 1.0f;
        float _S438 = _S433 - 1.0f;
        float _S439 = _S437 * _S438;
        float _S440 = 0.5f + _S434 * (3.0f * coat_frame_0.ior + 1.0f) / (6.0f * _S435 * _S435) + _S432 * _S436 * _S436 / (_S437 * _S437 * _S437) * (F32_log((_S434 / _S435))) - 2.0f * _S432 * coat_frame_0.ior * (_S432 + 2.0f * coat_frame_0.ior - 1.0f) / _S439 + 8.0f * _S433 * (_S433 + 1.0f) / (_S439 * _S438) * (F32_log((coat_frame_0.ior)));
        float _S441 = 1.0f - (1.0f - _S440) / _S432;
        float3  _S442 = material_5.coat_tint;
        float3  _S443 = _S442 * _S442 * make_float3 (1.0f - _S441) / (make_float3 (1.0f) - material_5.albedo * make_float3 (_S441));
        series_0 = _S443;
    }
    else
    {
        series_0 = _S430;
    }
    return series_0;
}

__device__ __forceinline__ float3  reflectedHalf(float3  in_dir_0, float3  out_dir_0)
{
    float3  _S444 = negate_0(in_dir_0);
    float3  _S445 = _S444 + out_dir_0;
    float3  _S446 = ((((_S445)) * make_float3(rnorm3df(((_S445)).x, ((_S445)).y, ((_S445)).z))));
    return _S446;
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
    float _S447 = dot_0(n_3, i_6);
    float _S448 = 1.0f - eta_0 * eta_0 * (1.0f - _S447 * _S447);
    if(_S448 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_6 - make_float3 (eta_0 * _S447 + (F32_sqrt((_S448)))) * n_3;
}

__device__ float fresnel(float cos_theta_0, float eta_i_0, float eta_o_0)
{
    float _S449 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S450 = eta_i_0 / eta_o_0 * _S449;
    bool _S451 = _S450 < 1.0f;
    float kr_0;
    if(_S451)
    {
        float _S452 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S450 * _S450))))));
        bool _S453 = eta_i_0 == eta_o_0;
        float _S454 = _slang_select(_S453, cos_theta_0,_S452);
        float _S455 = eta_o_0 * cos_theta_0;
        float _S456 = eta_i_0 * _S454;
        float _S457 = (_S455 - _S456) / (_S455 + _S456);
        float _S458 = eta_i_0 * cos_theta_0;
        float _S459 = eta_o_0 * _S454;
        float _S460 = (_S458 - _S459) / (_S458 + _S459);
        float _S461 = (_S457 * _S457 + _S460 * _S460) / 2.0f;
        kr_0 = _S461;
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
    float _S462 = alpha_1 * alpha_1;
    float _S463 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S462 + (1.0f - _S462) * n_dot_x_0 * n_dot_x_0))));
    bool _S464 = alpha_1 > 0.0f;
    float _S465 = _slang_select(_S464, _S463,1.0f);
    return _S465;
}

__device__ __forceinline__ float coatFresnel(float3  in_dir_1, float3  v_2, float3  coat_h_0, CoatFrame coat_frame_1, float eta_i_1, bool behind_0)
{
    float _S466 = dot_0(coat_frame_1.normal, reflect_0(in_dir_1, coat_h_0));
    float _S467 = (F32_abs((dot_0(v_2, coat_h_0))));
    float _S468 = eta_i_1 / coat_frame_1.ior * (F32_sqrt(((F32_max((1.0f - _S467 * _S467), (0.0f))))));
    float _S469 = (F32_sqrt(((F32_max((1.0f - _S468 * _S468), (0.0f))))));
    float _S470 = _slang_select(behind_0, _S469,_S467);
    float _S471 = _slang_select(behind_0, coat_frame_1.ior,1.0f);
    float _S472 = _slang_select(behind_0, 1.0f,coat_frame_1.ior);
    float _S473 = fresnel(_S470, _S471, _S472);
    float _S474 = smithG1(coat_frame_1.alpha, _S466);
    float _S475 = _S473 * _S474;
    bool _S476 = _S466 > 0.0f;
    float _S477 = _slang_select(_S476, _S475,0.0f);
    return _S477;
}

static __device__ float3  mix_0(float3  e1_0, float3  e2_0, float e3_0)
{
    return e1_0 * make_float3 (1.0f - e3_0) + e2_0 * make_float3 (e3_0);
}

static __device__ Weights Weights_x24init_0(float v_dot_h_0, float3  refracted_1, float3  F_0, float reflect_weight_0, float3  diffuse_weight_0, float3  refract_weight_0, float p_diffuse_0, float p_reflect_0, float p_refract_0, float p_sheen_velvet_0, float p_toon_0, float3  sheen_0, float3  toon_0, float3  coat_0, float p_coat_0)
{
    Weights _S478;
    (&_S478)->v_dot_h = v_dot_h_0;
    (&_S478)->refracted = refracted_1;
    (&_S478)->F = F_0;
    (&_S478)->reflect_weight = reflect_weight_0;
    (&_S478)->diffuse_weight = diffuse_weight_0;
    (&_S478)->refract_weight = refract_weight_0;
    (&_S478)->p_diffuse = p_diffuse_0;
    (&_S478)->p_reflect = p_reflect_0;
    (&_S478)->p_refract = p_refract_0;
    (&_S478)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S478)->p_toon = p_toon_0;
    (&_S478)->sheen = sheen_0;
    (&_S478)->toon = toon_0;
    (&_S478)->coat = coat_0;
    (&_S478)->p_coat = p_coat_0;
    return _S478;
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
    float _S479 = (F32_min(((F32_sqrt((material_6.specular_level))) * (F32_abs((eta_i_2 - eta_o_1))) / (eta_i_2 + eta_o_1)), (0.9999847412109375f)));
    float _S480 = _S479 * _S479;
    float _S481 = (1.0f + _S479) / (1.0f - _S479);
    float3  _S482 = make_float3 (1.0f);
    float3  _S483 = make_float3 (0.0f);
    float sheen_component_0;
    float3  sheen_1;
    float3  scale_1;
    if(sheen_profile_0.on)
    {
        float _S484 = (F32_min((sheen_profile_0.albedo), (1.0f)));
        float3  _S485 = make_float3 (1.0f) - material_6.sheen * make_float3 (_S484);
        float _S486 = rgb_to_greyscale(material_6.sheen);
        float _S487 = _S486 * _S484;
        float3  _S488 = material_6.sheen / make_float3 ((F32_max((sheen_profile_0.albedo), (1.0f))));
        sheen_component_0 = _S487;
        sheen_1 = _S488;
        scale_1 = _S485;
    }
    else
    {
        sheen_component_0 = 0.0f;
        sheen_1 = _S483;
        scale_1 = _S482;
    }
    float _S489 = (F32_abs((material_6.toon.x)));
    bool _S490 = _S489 > 0.0f;
    float toon_component_0;
    float3  toon_1;
    if(_S490)
    {
        float _S491 = (F32_min((_S489), (1.0f)));
        float3  scale_2 = scale_1 * make_float3 (1.0f - _S491);
        float _S492 = rgb_to_greyscale(material_6.albedo);
        float _S493 = _S491 * _S492;
        float3  _S494 = make_float3 (_S491) * material_6.albedo;
        toon_component_0 = _S493;
        toon_1 = _S494;
        scale_1 = scale_2;
    }
    else
    {
        toon_component_0 = 0.0f;
        toon_1 = _S483;
    }
    bool _S495 = (material_6.metallic) > 0.0f;
    float3  rebounce_0;
    if(_S495)
    {
        float _S496 = frame_1.alphas.x;
        float _S497 = (F32_sqrt(((F32_min((_S496), (frame_1.alphas.y))))));
        bool _S498 = _S496 > 0.0f;
        float _S499 = _slang_select(_S498, _S497,material_6.roughness);
        float _S500 = _S499 * _S499;
        float _S501 = (F32_pow((_S500), (1.81585001945495605f))) * (2.15371990203857422f - 0.73285001516342163f * _S500) / (1.0f + 1.28094995021820068f * _S500);
        bool _S502 = _S500 > 0.0f;
        float _S503 = _slang_select(_S502, _S501,0.0f);
        float _S504 = clamp_1(dot_0(n_i_2, v_3), 0.0f, 1.0f);
        float _S505 = _S500 * _S499;
        float _S506 = (F32_min((1.00064504146575928f - _S499 * (0.00375499995425344f + _S504 * (-0.04133399948477745f + _S504 * (-0.90938502550125122f + _S504 * 0.35275399684906006f))) - _S500 * (0.27602800726890564f + _S504 * (1.27023398876190186f + _S504 * 0.04740000143647194f)) - _S505 * (0.31452900171279907f - _S504 * 0.34830701351165771f) + _S505 * _S499 * 0.27229699492454529f), (1.0f)));
        float3  _S507 = min_1(make_float3 (1.0f) / (make_float3 (1.0f) - material_6.albedo * make_float3 (_S503)), make_float3 (1.0f / (F32_max((_S506), (0.0000152587890625f)))));
        rebounce_0 = _S507;
    }
    else
    {
        rebounce_0 = _S482;
    }
    float _S508 = dot_0(h_0, v_3);
    float _S509 = eta_i_2 / eta_o_1;
    float3  _S510 = refract_0(in_dir_2, h_0, _S509);
    float3  _S511 = ((((_S510)) * make_float3(rnorm3df(((_S510)).x, ((_S510)).y, ((_S510)).z))));
    float _S512 = (F32_abs((_S508)));
    bool _S513 = eta_i_2 > eta_o_1;
    float _S514 = _slang_select(_S513, _S481,1.0f);
    float _S515 = _slang_select(_S513, 1.0f,_S481);
    float _S516 = fresnel(_S512, _S514, _S515);
    float _S517 = eta_i_2 * eta_i_2;
    float _S518 = eta_o_1 * eta_o_1;
    bool _S519 = (_S517 * (1.0f - _S508 * _S508)) >= _S518;
    float3  _S520 = material_6.specular_tint * make_float3 (_S480);
    float3  _S521 = make_float3 (1.0f) - _S520;
    float _S522 = 1.0f - _S480;
    float3  _S523 = _S520 + _S521 * make_float3 (_S516 - _S480) / make_float3 (_S522);
    float3  _S524 = _slang_select(_S519, _S482,_S523);
    bool _S525 = (dot_0(coat_h_1, coat_h_1)) > 0.0f;
    float3  coat_1;
    float3  up_0;
    float3  through_0;
    if(_S525)
    {
        float _S526 = coatFresnel(in_dir_2, v_3, coat_h_1, coat_frame_2, eta_i_2, _S513);
        float _S527 = material_6.coat * _S526;
        float3  _S528 = material_6.coat_tint;
        float3  _S529 = _S528 * _S528;
        float3  _S530 = _slang_select(_S513, _S529,_S482);
        float3  _S531 = make_float3 (_S527) * _S530;
        float _S532 = 1.0f - _S526;
        bool _S533 = !_S513;
        float3  _S534 = _slang_select(_S533, coat_series_0,_S482);
        float3  _S535 = mix_0(_S482, make_float3 (_S532) * _S534, material_6.coat);
        float3  _S536 = mix_0(_S482, make_float3 (_S532) * material_6.coat_tint, material_6.coat);
        coat_1 = _S531;
        up_0 = _S535;
        through_0 = _S536;
    }
    else
    {
        coat_1 = _S483;
        up_0 = _S482;
        through_0 = _S482;
    }
    float3  _S537 = scale_1 * coat_1;
    float _S538 = rgb_to_greyscale(_S537);
    float3  _S539 = material_6.albedo * rebounce_0;
    float3  _S540 = mix_0(_S524, _S539, material_6.metallic);
    float3  F_1 = _S540 * scale_1 * up_0;
    float _S541 = rgb_to_greyscale(F_1);
    float _S542 = 1.0f - material_6.metallic;
    float _S543 = (1.0f - material_6.transmission) * _S542;
    float3  _S544 = make_float3 (1.0f) - _S524;
    float3  _S545 = make_float3 (_S543) * _S544 * scale_1 * up_0;
    float _S546 = material_6.transmission * _S542;
    float3  _S547 = make_float3 (_S546) * _S544 * scale_1 * through_0;
    float _S548 = (F32_max((_S541), (0.0f)));
    float _S549 = rgb_to_greyscale(_S545);
    float _S550 = (F32_max((_S549), (0.0f)));
    float _S551 = rgb_to_greyscale(_S547);
    float _S552 = sign_0(length_0(_S511));
    float _S553 = (F32_max((_S551 * _S552), (0.0f)));
    float _S554 = _S548 + _S550 + _S553 + toon_component_0 + _S538;
    float _S555 = (F32_min((sheen_component_0), (1.0f)));
    bool _S556 = sheen_component_0 > 0.0f;
    bool _S557;
    if(_S556)
    {
        _S557 = !(_S554 > 0.0f);
    }
    else
    {
        _S557 = false;
    }
    float _S558 = _slang_select(_S557, 1.0f,_S555);
    float _S559 = (1.0f - _S558) / (F32_max((_S554), (0.0000152587890625f)));
    float _S560 = _S550 * _S559;
    float _S561 = _S548 * _S559;
    float _S562 = _S553 * _S559;
    Weights _S563 = Weights_x24init_0(_S508, _S511, F_1, 1.0f, _S545, _S547, _S560, _S561, _S562, _S558, toon_component_0 * _S559, sheen_1, toon_1, _S537, _S538 * _S559);
    bool _S564 = any_1(ggx_n_0 != h_0);
    Weights leaving_0;
    if(_S564)
    {
        float _S565 = dot_0(ggx_n_0, v_3);
        float _S566 = eta_i_2 / eta_o_1;
        float3  _S567 = refract_0(in_dir_2, ggx_n_0, _S566);
        float3  _S568 = ((((_S567)) * make_float3(rnorm3df(((_S567)).x, ((_S567)).y, ((_S567)).z))));
        float _S569 = (F32_abs((_S565)));
        float _S570 = _slang_select(_S513, _S481,1.0f);
        float _S571 = _slang_select(_S513, 1.0f,_S481);
        float _S572 = fresnel(_S569, _S570, _S571);
        bool _S573 = (_S517 * (1.0f - _S565 * _S565)) >= _S518;
        float3  _S574 = _S520 + _S521 * make_float3 (_S572 - _S480) / make_float3 (_S522);
        float3  _S575 = _slang_select(_S573, _S482,_S574);
        if(_S525)
        {
            float _S576 = coatFresnel(in_dir_2, v_3, coat_h_1, coat_frame_2, eta_i_2, _S513);
            float _S577 = material_6.coat * _S576;
            float3  _S578 = material_6.coat_tint;
            float3  _S579 = _S578 * _S578;
            float3  _S580 = _slang_select(_S513, _S579,_S482);
            float3  _S581 = make_float3 (_S577) * _S580;
            float _S582 = 1.0f - _S576;
            bool _S583 = !_S513;
            float3  _S584 = _slang_select(_S583, coat_series_0,_S482);
            float3  _S585 = mix_0(_S482, make_float3 (_S582) * _S584, material_6.coat);
            float3  _S586 = mix_0(_S482, make_float3 (_S582) * material_6.coat_tint, material_6.coat);
            coat_1 = _S581;
            up_0 = _S585;
            through_0 = _S586;
        }
        else
        {
            coat_1 = _S483;
            up_0 = _S482;
            through_0 = _S482;
        }
        float3  _S587 = scale_1 * coat_1;
        float _S588 = rgb_to_greyscale(_S587);
        float3  _S589 = mix_0(_S575, _S539, material_6.metallic);
        float3  F_2 = _S589 * scale_1 * up_0;
        float _S590 = rgb_to_greyscale(F_2);
        float3  _S591 = make_float3 (1.0f) - _S575;
        float3  _S592 = make_float3 (_S543) * _S591 * scale_1 * up_0;
        float3  _S593 = make_float3 (_S546) * _S591 * scale_1 * through_0;
        float _S594 = (F32_max((_S590), (0.0f)));
        float _S595 = rgb_to_greyscale(_S592);
        float _S596 = (F32_max((_S595), (0.0f)));
        float _S597 = rgb_to_greyscale(_S593);
        float _S598 = sign_0(length_0(_S568));
        float _S599 = (F32_max((_S597 * _S598), (0.0f)));
        float _S600 = _S594 + _S596 + _S599 + toon_component_0 + _S588;
        if(_S556)
        {
            _S557 = !(_S600 > 0.0f);
        }
        else
        {
            _S557 = false;
        }
        float _S601 = _slang_select(_S557, 1.0f,_S555);
        float _S602 = (1.0f - _S601) / (F32_max((_S600), (0.0000152587890625f)));
        float _S603 = _S596 * _S602;
        float _S604 = _S594 * _S602;
        float _S605 = _S599 * _S602;
        Weights _S606 = Weights_x24init_0(_S565, _S568, F_2, 1.0f, _S592, _S593, _S603, _S604, _S605, _S601, toon_component_0 * _S602, sheen_1, toon_1, _S587, _S588 * _S602);
        leaving_0 = _S606;
    }
    else
    {
        leaving_0 = _S563;
    }
    bool _S607 = any_1(coat_n_0 != coat_h_1);
    Weights coated_0;
    if(_S607)
    {
        float _S608 = eta_i_2 / eta_o_1;
        float3  _S609 = refract_0(in_dir_2, h_0, _S608);
        float3  _S610 = ((((_S609)) * make_float3(rnorm3df(((_S609)).x, ((_S609)).y, ((_S609)).z))));
        float _S611 = _slang_select(_S513, _S481,1.0f);
        float _S612 = _slang_select(_S513, 1.0f,_S481);
        float _S613 = fresnel(_S512, _S611, _S612);
        float3  _S614 = _S520 + _S521 * make_float3 (_S613 - _S480) / make_float3 (_S522);
        float3  _S615 = _slang_select(_S519, _S482,_S614);
        bool _S616 = (dot_0(coat_n_0, coat_n_0)) > 0.0f;
        if(_S616)
        {
            float _S617 = coatFresnel(in_dir_2, v_3, coat_n_0, coat_frame_2, eta_i_2, _S513);
            float _S618 = material_6.coat * _S617;
            float3  _S619 = material_6.coat_tint;
            float3  _S620 = _S619 * _S619;
            float3  _S621 = _slang_select(_S513, _S620,_S482);
            float3  _S622 = make_float3 (_S618) * _S621;
            float _S623 = 1.0f - _S617;
            bool _S624 = !_S513;
            float3  _S625 = _slang_select(_S624, coat_series_0,_S482);
            float3  _S626 = mix_0(_S482, make_float3 (_S623) * _S625, material_6.coat);
            float3  _S627 = mix_0(_S482, make_float3 (_S623) * material_6.coat_tint, material_6.coat);
            coat_1 = _S622;
            up_0 = _S626;
            through_0 = _S627;
        }
        else
        {
            coat_1 = _S483;
            up_0 = _S482;
            through_0 = _S482;
        }
        float3  _S628 = scale_1 * coat_1;
        float _S629 = rgb_to_greyscale(_S628);
        float3  _S630 = mix_0(_S615, _S539, material_6.metallic);
        float3  F_3 = _S630 * scale_1 * up_0;
        float _S631 = rgb_to_greyscale(F_3);
        float3  _S632 = make_float3 (1.0f) - _S615;
        float3  _S633 = make_float3 (_S543) * _S632 * scale_1 * up_0;
        float3  _S634 = make_float3 (_S546) * _S632 * scale_1 * through_0;
        float _S635 = (F32_max((_S631), (0.0f)));
        float _S636 = rgb_to_greyscale(_S633);
        float _S637 = (F32_max((_S636), (0.0f)));
        float _S638 = rgb_to_greyscale(_S634);
        float _S639 = sign_0(length_0(_S610));
        float _S640 = (F32_max((_S638 * _S639), (0.0f)));
        float _S641 = _S635 + _S637 + _S640 + toon_component_0 + _S629;
        if(_S556)
        {
            _S557 = !(_S641 > 0.0f);
        }
        else
        {
            _S557 = false;
        }
        float _S642 = _slang_select(_S557, 1.0f,_S555);
        float _S643 = (1.0f - _S642) / (F32_max((_S641), (0.0000152587890625f)));
        float _S644 = _S637 * _S643;
        float _S645 = _S635 * _S643;
        float _S646 = _S640 * _S643;
        Weights _S647 = Weights_x24init_0(_S508, _S610, F_3, 1.0f, _S633, _S634, _S644, _S645, _S646, _S642, toon_component_0 * _S643, sheen_1, toon_1, _S628, _S629 * _S643);
        coated_0 = _S647;
    }
    else
    {
        coated_0 = _S563;
    }
    return Weights_x24init_0(leaving_0.v_dot_h, leaving_0.refracted, leaving_0.F, leaving_0.reflect_weight, _S563.diffuse_weight, leaving_0.refract_weight, _S563.p_diffuse, leaving_0.p_reflect, leaving_0.p_refract, _S563.p_sheen_velvet, _S563.p_toon, sheen_1, toon_1, coated_0.coat, coated_0.p_coat);
}

__device__ float translucentShare(BSDFMaterial material_7)
{
    float _S648 = rgb_to_greyscale(material_7.translucent);
    float _S649 = rgb_to_greyscale(material_7.albedo);
    float _S650 = _S648 / (_S649 + _S648);
    bool _S651 = _S648 > 0.0f;
    float _S652 = _slang_select(_S651, _S650,0.0f);
    return _S652;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float n_i_dot_v_0, BSDFMaterial material_8, Weights w_0)
{
    float _S653 = translucentShare(material_8);
    float _S654 = w_0.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S655 = w_0.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S656 = 1.0f - _S653;
    bool _S657 = n_i_dot_l_0 < 0.0f;
    float _S658 = _slang_select(_S657, _S653,_S656);
    float _S659 = _S655 * _S658;
    bool _S660 = _S653 > 0.0f;
    float _S661 = _slang_select(_S660, _S659,_S654);
    bool _S662 = n_i_dot_v_0 > 0.0f;
    float _S663 = _slang_select(_S662, _S661,0.0f);
    return _S663;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_3, BSDFMaterial material_9, Weights w_1)
{
    float _S664 = translucentShare(material_9);
    bool _S665 = (dot_0(n_i_3, l_0)) < 0.0f;
    float3  _S666 = _slang_select(_S665, material_9.translucent,material_9.albedo);
    float _S667 = 1.0f - _S664;
    float _S668 = _slang_select(_S665, _S664,_S667);
    float3  _S669 = _S666 / make_float3 (_S668);
    bool _S670 = _S664 > 0.0f;
    float3  _S671 = _slang_select(_S670, _S669,material_9.albedo);
    return w_1.diffuse_weight * _S671 / make_float3 (w_1.p_diffuse);
}

__device__ float trowbridgeReitz(float alpha_2, float n_dot_h_0)
{
    float _S672 = alpha_2 * alpha_2;
    float _S673 = (1.0f - n_dot_h_0) * (1.0f + n_dot_h_0) + _S672 * n_dot_h_0 * n_dot_h_0;
    return _S672 / (F32_max((3.14159274101257324f * _S673 * _S673), (1.17549435082228751e-38f)));
}

__device__ float3  anisotropicLocal(float3  w_2, float3  t_12, float3  n_5)
{
    return make_float3 (dot_0(w_2, t_12), dot_0(w_2, cross_0(n_5, t_12)), dot_0(w_2, n_5));
}

__device__ float anisotropicG1(float3  w_3, float2  alphas_1)
{
    float _S674 = (F32_max((w_3.z), (0.0f)));
    return 2.0f * _S674 / (_S674 + length_0(make_float3 (alphas_1.x * w_3.x, alphas_1.y * w_3.y, _S674)));
}

__device__ float anisotropicD(float3  h_1, float2  alphas_2)
{
    float _S675 = alphas_2.x;
    float _S676 = h_1.x / _S675;
    float _S677 = alphas_2.y;
    float _S678 = h_1.y / _S677;
    float _S679 = h_1.z;
    float _S680 = _S676 * _S676 + _S678 * _S678 + _S679 * _S679;
    return 1.0f / (F32_max((3.14159274101257324f * _S675 * _S677 * _S680 * _S680), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float3  v_4, float3  h_2, float3  n_i_4, float n_i_dot_v_1, float alpha_3, AnisotropicFrame frame_2, float v_dot_h_1)
{
    float _S681 = dot_0(n_i_4, h_2);
    float _S682 = smithG1(alpha_3, n_i_dot_v_1);
    float _S683 = _S682 * v_dot_h_1;
    float _S684 = trowbridgeReitz(alpha_3, _S681);
    float _S685 = _S683 * _S684 / n_i_dot_v_1;
    bool _S686 = alpha_3 > 0.0f;
    bool _S687;
    if(_S686)
    {
        _S687 = v_dot_h_1 > 0.0f;
    }
    else
    {
        _S687 = false;
    }
    if(_S687)
    {
        _S687 = _S681 > 0.0f;
    }
    else
    {
        _S687 = false;
    }
    if(_S687)
    {
        _S687 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S687 = false;
    }
    float _S688 = _slang_select(_S687, _S685,0.0f);
    bool _S689 = (frame_2.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S689)
    {
        float3  _S690 = anisotropicLocal(v_4, frame_2.tangent, n_i_4);
        float _S691 = anisotropicG1(_S690, frame_2.alphas);
        float3  _S692 = anisotropicLocal(h_2, frame_2.tangent, n_i_4);
        float _S693 = anisotropicD(_S692, frame_2.alphas);
        float _S694 = _S691 * _S693;
        float _S695 = _S694 * v_dot_h_1 / n_i_dot_v_1;
        bool _S696 = v_dot_h_1 > 0.0f;
        if(_S696)
        {
            _S687 = _S681 > 0.0f;
        }
        else
        {
            _S687 = false;
        }
        if(_S687)
        {
            _S687 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S687 = false;
        }
        float _S697 = _slang_select(_S687, _S695,0.0f);
        pdf_h_0 = _S697;
    }
    else
    {
        pdf_h_0 = _S688;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float l_dot_h_0, float pdf_h_1, Weights w_4, float eta_i_3, float eta_o_2)
{
    float _S698 = eta_i_3 * w_4.v_dot_h + eta_o_2 * l_dot_h_0;
    float _S699 = w_4.p_refract * pdf_h_1 * eta_o_2 * eta_o_2 * (F32_abs((l_dot_h_0))) / (_S698 * _S698);
    bool _S700 = eta_i_3 != eta_o_2;
    bool _S701;
    if(_S700)
    {
        _S701 = l_dot_h_0 < 0.0f;
    }
    else
    {
        _S701 = false;
    }
    float _S702 = _slang_select(_S701, _S699,0.0f);
    return _S702;
}

__device__ float maskingG1(float3  l_1, float3  n_i_5, float side_0, float alpha_4, AnisotropicFrame frame_3)
{
    float _S703 = smithG1(alpha_4, (F32_max((side_0 * dot_0(n_i_5, l_1)), (0.0f))));
    bool _S704 = (frame_3.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S704)
    {
        float3  _S705 = anisotropicLocal(l_1, frame_3.tangent, n_i_5 * make_float3 (side_0));
        float _S706 = anisotropicG1(_S705, frame_3.alphas);
        G1_l_0 = _S706;
    }
    else
    {
        G1_l_0 = _S703;
    }
    return G1_l_0;
}

__device__ __forceinline__ float3  refractBSDF(float G1_l_1, BSDFMaterial material_10, Weights w_5)
{
    bool _S707 = (material_10.ior) == 1.0f;
    float _S708 = _slang_select(_S707, 1.0f,G1_l_1);
    return w_5.refract_weight * make_float3 (_S708) * material_10.albedo / make_float3 (w_5.p_refract);
}

__device__ __forceinline__ float reflectPDF(float pdf_h_2, Weights w_6)
{
    float _S709 = w_6.p_reflect * pdf_h_2 / (4.0f * w_6.v_dot_h);
    bool _S710 = pdf_h_2 > 0.0f;
    float _S711 = _slang_select(_S710, _S709,0.0f);
    return _S711;
}

__device__ __forceinline__ float3  reflectBSDF(float G1_l_2, Weights w_7)
{
    return make_float3 (w_7.reflect_weight * G1_l_2) * w_7.F / make_float3 (w_7.p_reflect);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_1, float n_i_dot_v_2, Weights w_8)
{
    float _S712 = w_8.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S713 = n_i_dot_l_1 > 0.0f;
    bool _S714;
    if(_S713)
    {
        _S714 = n_i_dot_v_2 > 0.0f;
    }
    else
    {
        _S714 = false;
    }
    float _S715 = _slang_select(_S714, _S712,0.0f);
    return _S715;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  v_5, float3  n_i_6, BSDFMaterial material_11, Weights w_9)
{
    float3  _S716 = l_2 + v_5;
    float3  _S717 = ((((_S716)) * make_float3(rnorm3df(((_S716)).x, ((_S716)).y, ((_S716)).z))));
    float _S718 = dot_0(n_i_6, _S717);
    float _S719 = (F32_max((dot_0(n_i_6, l_2)), (0.0f)));
    float _S720 = (F32_max((dot_0(n_i_6, v_5)), (0.0f)));
    float _S721 = 1.0f / (F32_max((material_11.sheen_roughness), (0.05000000074505806f)));
    float _S722 = 1.0f - _S718 * _S718;
    float _S723 = (2.0f + _S721) * (F32_pow(((F32_max((_S722), (0.0f)))), (0.5f * _S721))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S719 + _S720 - _S719 * _S720)), (0.0000152587890625f)));
    bool _S724 = (material_11.velvet) > 0.0f;
    float f_1;
    if(_S724)
    {
        float _S725 = (F32_max((material_11.sheen_roughness), (0.00999999977648258f)));
        float _S726 = _S725 * _S725;
        float _S727 = (F32_max((_S722), (0.0000152587890625f)));
        float _S728 = (F32_exp((- _S718 * _S718 / (_S727 * _S726)))) / (3.14159274101257324f * _S726 * _S727 * _S727) * (F32_min((1.0f), (2.0f * _S718 * (F32_min((_S719), (_S720))) / (F32_max(((F32_abs((dot_0(_S717, v_5))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S719 * _S720), (0.0000152587890625f)));
        f_1 = _S728;
    }
    else
    {
        f_1 = _S723;
    }
    return w_9.sheen * make_float3 (f_1 * _S719 * 2.0f * 3.14159274101257324f / w_9.p_sheen_velvet);
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
    float _S729 = (F32_max((1.0f - (t_13 - a_3) / (F32_max((s_0), (0.0000152587890625f)))), (0.0f)));
    bool _S730 = t_13 < a_3;
    float _S731 = _slang_select(_S730, 1.0f,_S729);
    return _S731;
}

__device__ __forceinline__ float toonIntegral(float t_14, float a_4, float s_1, bool glossy_0)
{
    float _S732 = (F32_min((t_14), (a_4)));
    float _S733 = (F32_sin((_S732)));
    float _S734 = _S733 * _S733 / 2.0f;
    float _S735 = 1.0f - (F32_cos((_S732)));
    float _S736 = _slang_select(glossy_0, _S735,_S734);
    bool _S737 = t_14 > a_4;
    bool _S738;
    if(_S737)
    {
        _S738 = s_1 > 0.0f;
    }
    else
    {
        _S738 = false;
    }
    float integral_0;
    if(_S738)
    {
        if(glossy_0)
        {
            float _S739 = (F32_cos((a_4)));
            float _S740 = (F32_cos((t_14)));
            integral_0 = (1.0f + a_4 / s_1) * (_S739 - _S740) - ((F32_sin((t_14))) - t_14 * _S740 - ((F32_sin((a_4))) - a_4 * _S739)) / s_1;
        }
        else
        {
            float _S741 = 2.0f * a_4;
            float _S742 = (F32_cos((_S741)));
            float _S743 = 2.0f * t_14;
            float _S744 = (F32_cos((_S743)));
            integral_0 = (1.0f + a_4 / s_1) * (_S742 - _S744) / 4.0f - ((F32_sin((_S743))) / 8.0f - t_14 * _S744 / 4.0f - ((F32_sin((_S741))) / 8.0f - a_4 * _S742 / 4.0f)) / s_1;
        }
        float integral_1 = _S736 + integral_0;
        integral_0 = integral_1;
    }
    else
    {
        integral_0 = _S736;
    }
    return integral_0;
}

static __device__ ToonProfile ToonProfile_x24init_0(bool glossy_1, float a_5, float s_2, float b_1, float norm_0, float view_0, float3  axis_0)
{
    ToonProfile _S745;
    (&_S745)->glossy = glossy_1;
    (&_S745)->a = a_5;
    (&_S745)->s = s_2;
    (&_S745)->b = b_1;
    (&_S745)->norm = norm_0;
    (&_S745)->view = view_0;
    (&_S745)->axis = axis_0;
    return _S745;
}

__device__ __forceinline__ ToonProfile toonProfile(float3  v_6, float3  n_i_7, BSDFMaterial material_12)
{
    float _S746 = material_12.toon.x;
    bool _S747 = _S746 < 0.0f;
    float _S748 = clamp_1(material_12.toon.y / _S746, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S749 = clamp_1(material_12.toon.z / _S746, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S750 = (F32_min((_S748 + _S749), (1.57079637050628662f)));
    float _S751 = dot_0(n_i_7, v_6);
    float _S752 = toonP((F32_acos(((F32_min((_S751), (1.0f)))))), _S748, _S749);
    float3  _S753 = make_float3 (2.0f * _S751) * n_i_7 - v_6;
    float3  _S754 = ((((_S753)) * make_float3(rnorm3df(((_S753)).x, ((_S753)).y, ((_S753)).z))));
    float3  _S755 = _slang_select(_S747, _S754,n_i_7);
    float _S756 = toonIntegral(_S750, _S748, _S749, _S747);
    return ToonProfile_x24init_0(_S747, _S748, _S749, _S750, 6.28318548202514648f * _S756, _S752, _S755);
}

__device__ __forceinline__ float toonPDF(float3  l_3, float3  n_i_8, ToonProfile profile_1, Weights w_10)
{
    float _S757 = dot_0(n_i_8, l_3);
    float _S758 = dot_0(l_3, profile_1.axis);
    float _S759 = _slang_select(profile_1.glossy, _S758,_S757);
    float _S760 = (F32_acos((clamp_1(_S759, -1.0f, 1.0f))));
    float _S761 = toonP(_S760, profile_1.a, profile_1.s);
    float _S762 = w_10.p_toon * _S761;
    float _S763 = _slang_select(profile_1.glossy, 1.0f,_S757);
    float _S764 = _S762 * _S763 / profile_1.norm;
    bool _S765;
    if(profile_1.glossy)
    {
        _S765 = true;
    }
    else
    {
        _S765 = _S757 > 0.0f;
    }
    float _S766 = _slang_select(_S765, _S764,0.0f);
    return _S766;
}

__device__ __forceinline__ float3  toonBSDF(float3  l_4, float3  n_i_9, ToonProfile profile_2, Weights w_11)
{
    float _S767 = (F32_max((dot_0(n_i_9, l_4)), (0.0f)));
    float _S768 = _slang_select(profile_2.glossy, _S767,profile_2.view);
    return w_11.toon * make_float3 (_S768) / make_float3 (w_11.p_toon);
}

__device__ __forceinline__ float coatPDF(float3  v_7, float3  coat_h_2, CoatFrame coat_frame_3, Weights w_12)
{
    float _S769 = dot_0(coat_frame_3.normal, v_7);
    float _S770 = smithG1(coat_frame_3.alpha, _S769);
    float _S771 = trowbridgeReitz(coat_frame_3.alpha, dot_0(coat_frame_3.normal, coat_h_2));
    float _S772 = _S770 * _S771 / (4.0f * _S769);
    bool _S773 = (coat_frame_3.alpha) > 0.0f;
    float _S774 = _slang_select(_S773, _S772,0.0f);
    return w_12.p_coat * _S774;
}

__device__ __forceinline__ float3  coatBSDF(Weights w_13)
{
    return w_13.coat / make_float3 (w_13.p_coat);
}

__device__ __forceinline__ void BSDF(float3  in_dir_3, float3  out_dir_1, float3  n_6, BSDFMaterial material_13, float eta_i_4, float eta_o_3, bool refracted_2, Facets facets_0, FixedArray<float3 , 6>  * throughputs_0, FixedArray<float, 6>  * pdfs_0)
{
    float3  _S775 = negate_0(in_dir_3);
    float _S776 = dot_0(n_6, _S775);
    float _S777 = sign_0(_S776);
    float3  _S778 = n_6 * make_float3 (_S777);
    float _S779 = dot_0(_S778, out_dir_1);
    float _S780 = material_13.roughness;
    float _S781 = _S780 * _S780;
    AnisotropicFrame _S782 = anisotropicFrame(material_13, _S778);
    SheenProfile _S783 = sheenProfile(_S775, _S778, material_13);
    CoatFrame _S784 = coatFrame(material_13, _S778);
    float3  _S785 = coatSeries(_S784, material_13);
    float _S786 = rgb_to_greyscale(material_13.translucent);
    bool _S787 = _S786 > 0.0f;
    bool _S788 = (dot_0(n_6, out_dir_1) * _S776) < 0.0f;
    bool _S789 = (F32_abs((material_13.toon.x))) > 0.0f;
    float3  _S790 = facets_0.coat_h;
    bool _S791 = (dot_0(_S790, _S790)) > 0.0f;
    bool _S792;
    if(_S787)
    {
        _S792 = _S788;
    }
    else
    {
        _S792 = false;
    }
    bool _S793 = _S792 == refracted_2;
    bool _S794 = !refracted_2;
    if(_S794)
    {
        _S792 = _S789;
    }
    else
    {
        _S792 = false;
    }
    bool _S795;
    if(_S794)
    {
        _S795 = _S791;
    }
    else
    {
        _S795 = false;
    }
    float3  _S796 = negate_0(make_float3 (eta_i_4) * _S775 + make_float3 (eta_o_3) * out_dir_1);
    float3  _S797 = ((((_S796)) * make_float3(rnorm3df(((_S796)).x, ((_S796)).y, ((_S796)).z))));
    float3  _S798 = reflectedHalf(in_dir_3, out_dir_1);
    float _S799 = sign_0(dot_0(_S797, _S778));
    float3  _S800 = _S797 * make_float3 (_S799);
    float3  _S801 = _slang_select(refracted_2, _S800,_S798);
    float3  _S802 = make_float3 (0.0f);
    float3  _S803 = _slang_select(_S795, _S798,_S802);
    Weights _S804 = lobeWeights(in_dir_3, _S775, _S778, facets_0.h, facets_0.coat_h, _S801, _S803, _S782, _S783, _S784, _S785, material_13, eta_i_4, eta_o_3);
    float _S805 = (F32_abs((_S776)));
    float _S806 = diffusePDF(_S779, _S805, material_13, _S804);
    float _S807 = _slang_select(_S793, _S806,0.0f);
    (*pdfs_0)[int(0)] = _S807;
    float3  _S808 = diffuseBSDF(out_dir_1, _S778, material_13, _S804);
    float3  _S809 = _slang_select(_S793, _S808,_S802);
    (*throughputs_0)[int(0)] = _S809;
    float _S810 = vndfPDF(_S775, _S801, _S778, _S805, _S781, _S782, _S804.v_dot_h);
    float _S811 = refractPDF(dot_0(out_dir_1, _S801), _S810, _S804, eta_i_4, eta_o_3);
    float _S812 = _slang_select(refracted_2, _S811,0.0f);
    (*pdfs_0)[int(1)] = _S812;
    float _S813 = maskingG1(out_dir_1, _S778, -1.0f, _S781, _S782);
    float3  _S814 = refractBSDF(_S813, material_13, _S804);
    float3  _S815 = _slang_select(refracted_2, _S814,_S802);
    (*throughputs_0)[int(1)] = _S815;
    float _S816 = reflectPDF(_S810, _S804);
    float _S817 = _slang_select(_S794, _S816,0.0f);
    (*pdfs_0)[int(2)] = _S817;
    float _S818 = maskingG1(out_dir_1, _S778, 1.0f, _S781, _S782);
    float3  _S819 = reflectBSDF(_S818, _S804);
    float3  _S820 = _slang_select(_S794, _S819,_S802);
    (*throughputs_0)[int(2)] = _S820;
    float _S821 = sheenVelvetPDF(_S779, _S805, _S804);
    float _S822 = _slang_select(_S794, _S821,0.0f);
    (*pdfs_0)[int(3)] = _S822;
    float3  _S823 = sheenVelvetBSDF(out_dir_1, _S775, _S778, material_13, _S804);
    float3  _S824 = _slang_select(_S794, _S823,_S802);
    (*throughputs_0)[int(3)] = _S824;
    ToonProfile _S825 = toonProfile(_S775, _S778, material_13);
    float _S826 = toonPDF(out_dir_1, _S778, _S825, _S804);
    float _S827 = _slang_select(_S792, _S826,0.0f);
    (*pdfs_0)[int(4)] = _S827;
    float3  _S828 = toonBSDF(out_dir_1, _S778, _S825, _S804);
    float3  _S829 = _slang_select(_S792, _S828,_S802);
    (*throughputs_0)[int(4)] = _S829;
    float _S830 = coatPDF(_S775, _S803, _S784, _S804);
    float _S831 = _slang_select(_S795, _S830,0.0f);
    (*pdfs_0)[int(5)] = _S831;
    float3  _S832 = coatBSDF(_S804);
    float3  _S833 = _slang_select(_S795, _S832,_S802);
    (*throughputs_0)[int(5)] = _S833;
    return;
}

static __device__ __forceinline__ float3  skyLobes_0(float3  in_dir_4, float3  dir_6, FKSurface * surface_1, BSDFMaterial * material_14, float2  eta_1, bool is_inside_2, Facets * facets_1, float pdf_1, FixedArray<float3 , 6>  * terms_0, FixedArray<float, 6>  * pdfs_1)
{
    bool _S834 = wrongSide_0(is_inside_2, false, dir_6, surface_1->geometry_n);
    BSDF(in_dir_4, dir_6, surface_1->smooth_n, *material_14, eta_1.x, eta_1.y, _S834, *facets_1, terms_0, pdfs_1);
    float3  _S835 = make_float3 (0.0f);
    uint i_9 = 0U;
    float3  f_2 = _S835;
    for(;;)
    {
        if(i_9 < 6U)
        {
        }
        else
        {
            break;
        }
        bool _S836 = ((*pdfs_1)[i_9]) > 0.0f;
        if(_S836)
        {
            float3  _S837 = (*terms_0)[i_9] * make_float3 ((*pdfs_1)[i_9]) / make_float3 ((*pdfs_1)[i_9] + pdf_1);
            (*terms_0)[i_9] = _S837;
            float3  f_3 = f_2 + (*terms_0)[i_9];
            f_2 = f_3;
        }
        uint i_10 = i_9 + 1U;
        i_9 = i_10;
    }
    return f_2;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_7, float3  radiance_0, float3  color_0, uint random_state_2)
{
    SkySample _S838;
    (&_S838)->dir = dir_7;
    (&_S838)->radiance = radiance_0;
    (&_S838)->color = color_0;
    (&_S838)->random_state = random_state_2;
    return _S838;
}

static __device__ __noinline__ float3  skyColor_0(float3  dir_8, FixedArray<float3 , 6>  * terms_1, FixedArray<float, 6>  * pdfs_2, uint depth_1)
{
    float3  _S839 = make_float3 (0.0f);
    bool shaded_0 = false;
    float3  world_0 = _S839;
    uint i_11 = 0U;
    float3  color_1 = _S839;
    for(;;)
    {
        if(i_11 < 6U)
        {
        }
        else
        {
            break;
        }
        bool _S840 = ((*pdfs_2)[i_11]) > 0.0f;
        if(_S840)
        {
            bool _S841 = (fcptWorldReadsPath());
            bool _S842;
            if(_S841)
            {
                _S842 = true;
            }
            else
            {
                _S842 = !shaded_0;
            }
            bool shaded_1;
            float3  world_1;
            if(_S842)
            {
                bool _S843 = i_11 == 5U;
                uint _S844 = _slang_select(_S843, 5U,i_11);
                bool _S845 = i_11 == 4U;
                uint _S846 = _slang_select(_S845, 6U,_S844);
                bool _S847 = i_11 == 3U;
                uint _S848 = _slang_select(_S847, 4U,_S846);
                float3  _S849 = (fcptEnvMapSample((dir_8), (depth_1), (_S848)));
                world_1 = _S849;
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
    uint2  _S850 = (fcptEnvironmentCdfSize());
    uint2  _S851 = make_uint2 (1U, 0U);
    uint2  _S852 = _S850 - _S851;
    Random _S853 = draw(init_random_state_0, 6U);
    Random _S854 = draw(init_random_state_0, 2147483654U);
    Random _S855 = draw(init_random_state_0, 7U);
    Random _S856 = draw(init_random_state_0, 2147483655U);
    uint _S857 = _S852.x;
    uint _S858 = searchCDF_0(make_uint2 (_S857, 0U), make_uint2 (0U, 1U), _S852.y, _S853.value);
    uint _S859 = searchCDF_0(make_uint2 (0U, _S858), _S851, _S857, _S854.value);
    float2  _S860 = make_float2 ((float)_S852.x, (float)_S852.y);
    float2  _S861 = (make_float2 (float(_S859), float(_S858)) + make_float2 (_S855.value, _S856.value)) / _S860 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S862 = _S861.y;
    float _S863 = (F32_sin((_S862)));
    float _S864 = _S861.x;
    float3  _S865 = skyFrame_0(make_float3 (_S863 * (F32_cos((_S864))), (F32_cos((_S862))), _S863 * (F32_sin((_S864)))));
    float _S866 = environmentPdf_0(_S865);
    BSDFMaterial _S867 = pathMaterial(surface_2->material, wavelength_3);
    BSDFMaterial _S868 = _S867;
    FixedArray<float3 , 6>  terms_2;
    FixedArray<float, 6>  pdfs_3;
    float3  _S869 = skyLobes_0(ray_0->unit_direction, _S865, surface_2, &_S868, eta_2, is_inside_3, facets_2, _S866, &terms_2, &pdfs_3);
    bool _S870 = !(_S866 > 0.0f);
    bool _S871;
    if(_S870)
    {
        _S871 = true;
    }
    else
    {
        _S871 = all_1(_S869 == make_float3 (0.0f));
    }
    if(_S871)
    {
        float3  _S872 = make_float3 (0.0f);
        return SkySample_x24init_0(_S865, _S872, _S872, _S856.state);
    }
    bool _S873 = (fcptWorldReadsPath());
    float3  seen_0;
    if(_S873)
    {
        uint _S874 = context_2->depth + 1U;
        FixedArray<float3 , 6>  _S875 = terms_2;
        FixedArray<float, 6>  _S876 = pdfs_3;
        float3  _S877 = skyColor_0(_S865, &_S875, &_S876, _S874);
        seen_0 = _S877;
    }
    else
    {
        seen_0 = _S869;
    }
    float3  _S878 = skyRadiance_0(ray_0->origin, surface_2, is_inside_3, _S865, context_2, _S856.state);
    return SkySample_x24init_0(_S865, _S878, seen_0 * _S878, _S856.state);
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
    SampleBSDF _S879 = (fcptConnectHair((surface_3->hair), ((&surface_3->material)->albedo), ((&surface_3->material)->specular_tint), (in_dir_5), (light_1->dir)));
    float3  _S880 = _S879.throughput * make_float3 (_S879.pdf);
    float _S881 = light_1->density;
    float _S882 = 1.0f + _S879.pdf * _S879.pdf / (light_1->density * light_1->density);
    bool _S883;
    if(competing_0)
    {
        _S883 = _S881 > 0.0f;
    }
    else
    {
        _S883 = false;
    }
    float _S884 = _slang_select(_S883, _S882,1.0f);
    return _S880 / make_float3 (_S884) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_9, float3  radiance_1, float density_0, uint random_state_3)
{
    TreeSample _S885;
    (&_S885)->dir = dir_9;
    (&_S885)->radiance = radiance_1;
    (&_S885)->density = density_0;
    (&_S885)->random_state = random_state_3;
    return _S885;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_14, float3  normal_4, float * pick_0, float * probability_3)
{
    float _S886 = importance(first_1, p_14, normal_4);
    float _S887 = importance(second_1, p_14, normal_4);
    float2  _S888 = make_float2 (_S886, _S887);
    bool _S889 = _S886 == 0.0f;
    bool _S890;
    if(_S889)
    {
        _S890 = _S887 == 0.0f;
    }
    else
    {
        _S890 = false;
    }
    if(_S890)
    {
        return 2U;
    }
    float _S891 = _S886 + _S887;
    bool _S892 = _S887 > 0.0f;
    if(_S892)
    {
        _S890 = (*pick_0 * _S891) >= _S886;
    }
    else
    {
        _S890 = false;
    }
    uint _S893 = uint(_S890);
    float _S894 = (F32_min(((*pick_0 * _S891 - float(_S893) * _S886) / _slang_vector_get_element(_S888, _S893)), (0.99999994039535522f)));
    *pick_0 = _S894;
    float _S895 = *probability_3 * (_slang_vector_get_element(_S888, _S893) / _S891);
    *probability_3 = _S895;
    return _S893;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_15, float u1_0, float u2_0)
{
    float3  _S896 = center_1 - p_15;
    float _S897 = radius_1 * radius_1 / dot_0(_S896, _S896);
    float _S898 = u1_0 * _S897 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S897), (0.0f)))))));
    float _S899 = 2.0f * u1_0;
    bool _S900 = _S897 >= 1.0f;
    float _S901 = _slang_select(_S900, _S899,_S898);
    float _S902 = (F32_sqrt(((F32_max((_S901 * (2.0f - _S901)), (0.0f))))));
    float _S903 = 6.28318548202514648f * u2_0;
    float3  _S904 = make_float3 (_S902 * (F32_cos((_S903))), 1.0f - _S901, _S902 * (F32_sin((_S903))));
    float3  _S905 = ((((_S896)) * make_float3(rnorm3df(((_S896)).x, ((_S896)).y, ((_S896)).z))));
    float3  _S906 = tangentToWorld(_S904, _S905);
    return _S906;
}

__device__ float3  pointLightRadiance(float3  color_3, float intensity_0, float radius_2)
{
    return color_3 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S907 = center_2 - ray_1->origin;
    float _S908 = dot_0(_S907, ray_1->unit_direction);
    float _S909 = dot_0(_S907, _S907) - _S908 * _S908;
    float _S910 = radius_3 * radius_3;
    bool _S911 = _S909 > _S910;
    if(_S911)
    {
        return 4.294967296e+09f;
    }
    float _S912 = (F32_sqrt((_S910 - _S909)));
    float _S913 = _S908 - _S912;
    float _S914 = _S908 + _S912;
    bool _S915 = _S913 > 0.0000152587890625f;
    bool _S916;
    if(_S915)
    {
        _S916 = _S913 < max_len_0;
    }
    else
    {
        _S916 = false;
    }
    if(_S916)
    {
        return _S913;
    }
    bool _S917 = _S914 > 0.0000152587890625f;
    if(_S917)
    {
        _S916 = _S914 < max_len_0;
    }
    else
    {
        _S916 = false;
    }
    if(_S916)
    {
        return _S914;
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

static __device__ float3  emitted_0(float3  emissive_0, float3  dir_10, float3  n_7)
{
    float _S918 = sign_0(dot_0(- dir_10, n_7));
    float3  _S919 = emissive_0 * make_float3 ((F32_max((_S918), (0.0f))));
    bool _S920 = ((true));
    float3  _S921 = _slang_select(_S920, emissive_0,_S919);
    return _S921;
}

static __device__ __forceinline__ TreeSample sampleLightTree_0(float3  origin_4, float3  smooth_n_2, float3  geometry_n_1, float geometry_offset_1, bool sided_0, uint init_random_state_1, ShadowContext * context_3)
{
    Random _S922 = draw(init_random_state_1, 4U);
    Random _S923 = draw(init_random_state_1, 5U);
    Random _S924 = draw(init_random_state_1, 2147483653U);
    float3  _S925 = make_float3 (0.0f);
    TreeSample _S926 = TreeSample_x24init_0(_S925, _S925, 0.0f, _S924.state);
    TreeSample sample_0 = _S926;
    float3  _S927 = _slang_select(sided_0, _S925,smooth_n_2);
    float3  _S928 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S922.value;
    float probability_4 = 1.0f;
    uint n_8 = 0U;
    for(;;)
    {
        uint4  _S929 = (fcptLightNode((n_8)));
        if((_S929.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S930 = (fcptLightSecond((n_8)));
        uint _S931 = n_8 + 1U;
        LightNode _S932 = (fcptLightBounds((_S931)));
        LightNode _S933 = (fcptLightBounds((_S930)));
        uint _S934 = pickChild(_S932, _S933, origin_4, _S927, &pick_1, &probability_4);
        bool _S935 = _S934 > 1U;
        if(_S935)
        {
            return sample_0;
        }
        bool _S936 = _S934 == 1U;
        uint _S937 = _slang_select(_S936, _S930,_S931);
        n_8 = _S937;
    }
    bool _S938 = n_8 == 0U;
    bool _S939;
    if(_S938)
    {
        LightNode _S940 = (fcptLightBounds((0U)));
        float _S941 = importance(_S940, origin_4, _S927);
        _S939 = !(_S941 > 0.0f);
    }
    else
    {
        _S939 = false;
    }
    if(_S939)
    {
        return sample_0;
    }
    uint4  _S942 = (fcptLightNode((n_8)));
    FKHit _S943 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S944 = (_S942.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S944)
    {
        FKLight _S945 = (fcptLight((_S942.y)));
        if(sided_0)
        {
            float _S946 = sign_0(dot_0(geometry_n_1, _S945.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S946);
            float3  _S947 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S947;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S928;
            lift_n_0 = smooth_n_2;
        }
        bool _S948 = (_S945.variance) == 0.0f;
        if(_S948)
        {
            float3  _S949 = _S945.position - emitter_point_0;
            float3  _S950 = ((((_S949)) * make_float3(rnorm3df(((_S949)).x, ((_S949)).y, ((_S949)).z))));
            (&sample_0)->dir = _S950;
            float3  _S951 = _S945.color * make_float3 (_S945.intensity) / make_float3 (dot_0(_S949, _S949) * probability_4);
            (&sample_0)->radiance = _S951;
            shadow_1 = _S949;
        }
        else
        {
            float3  _S952 = sampleSphere(_S945.position, _S945.variance, emitter_point_0, _S923.value, _S924.value);
            (&sample_0)->dir = _S952;
            float _S953 = sphereDensity(_S945.position, _S945.variance, emitter_point_0);
            float _S954 = probability_4 * _S953;
            (&sample_0)->density = _S954;
            float3  _S955 = pointLightRadiance(_S945.color, _S945.intensity, _S945.variance);
            float3  _S956 = _S955 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S956;
            FKRay _S957 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S958 = raySphere_0(_S945.position, _S945.variance, &_S957, 4.294967296e+09f);
            float3  _S959 = (&sample_0)->dir * make_float3 (_S958);
            shadow_1 = _S959;
        }
        emitter_0 = _S943;
        emitter_point_0 = _S925;
    }
    else
    {
        uint _S960 = _S942.y;
        uint _S961 = (fcptTriangleOffset((_S960)));
        uint _S962 = _S961 + _S942.z;
        Matrix<float, 3, 3>  _S963 = (fcptWorldTriangle((_S960), (_S962)));
        float _S964 = (F32_sqrt((_S923.value)));
        float2  _S965 = make_float2 (_S964 * (1.0f - _S924.value), _S964 * _S924.value);
        float3  _S966 = mul_0(make_float3 (1.0f - _S964, _S965.x, _S965.y), _S963);
        if(sided_0)
        {
            float _S967 = sign_0(dot_0(geometry_n_1, _S966 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S967);
            float3  _S968 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S968;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S969 = !((dot_0(smooth_n_2, _S966 - origin_4)) > 0.0f);
            if(_S969)
            {
                return sample_0;
            }
            emitter_point_0 = _S928;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S965, _S960, _S962, 0U, 0.0f);
        float3  _S970 = _S966 - emitter_point_0;
        float3  _S971 = ((((_S970)) * make_float3(rnorm3df(((_S970)).x, ((_S970)).y, ((_S970)).z))));
        (&sample_0)->dir = _S971;
        float _S972 = solidAngle(probability_4, cross_0(_S963.rows[int(1)] - _S963.rows[int(0)], _S963.rows[int(2)] - _S963.rows[int(0)]), _S970);
        (&sample_0)->density = _S972;
        bool _S973 = (fcptShadowFirst());
        bool _S974 = !_S973;
        if(_S974)
        {
            FKSurface _S975 = (fcptLightSurfaceAt((emitter_1), (_S966), (_S924.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S966 - origin_4))));
            (&sample_0)->random_state = _S975.random_state;
            float3  _S976 = emitted_0(_S975.material.emissive, (&sample_0)->dir, _S975.smooth_n);
            float3  _S977 = _slang_select(_S975.skip, _S925,_S976);
            float3  _S978 = _S977 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S978;
        }
        shadow_1 = _S970;
        emitter_0 = emitter_1;
        emitter_point_0 = _S966;
    }
    FKHit _S979 = emitter_0;
    float3  _S980 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S924.state, &_S979);
    bool _S981 = (fcptShadowFirst());
    if(_S981)
    {
        _S939 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S939 = false;
    }
    if(_S939)
    {
        _S939 = !all_1(_S980 == _S925);
    }
    else
    {
        _S939 = false;
    }
    if(_S939)
    {
        FKSurface _S982 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S924.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S982.random_state;
        float3  _S983 = emitted_0(_S982.material.emissive, (&sample_0)->dir, _S982.smooth_n);
        float3  _S984 = _slang_select(_S982.skip, _S925,_S983);
        float3  _S985 = _S984 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S985;
    }
    float3  _S986 = (&sample_0)->radiance * _S980;
    bool _S987 = all_1(_S980 == _S925);
    float3  _S988 = _slang_select(_S987, _S925,_S986);
    (&sample_0)->radiance = _S988;
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
    float _S989 = 1.0f / (1.0f + b_2 / a_6 * (b_2 / a_6));
    bool _S990 = b_2 > 0.0f;
    float _S991 = _slang_select(_S990, _S989,1.0f);
    return _S991;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S992 = vertex_0->none;
    if(_S992)
    {
        return 1.0f;
    }
    uint _S993 = (fcptLightSlot((*hit_1)));
    float _S994 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S993, light_point_1);
    float _S995 = powerHeuristic(vertex_0->pdf, _S994);
    return _S995;
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
    float _S996 = upsample(f_4, wavelength_4);
    float3  _S997 = weight_0 * make_float3 (_S996);
    bool _S998 = wavelength_4 > 0.0f;
    float3  _S999 = _slang_select(_S998, _S997,f_4);
    return _S999;
}

__device__ float3  safeDivide(float3  a_7, float3  b_3)
{
    float3  _S1000 = a_7 / b_3;
    float3  _S1001 = make_float3 (0.0f);
    bool3  _S1002 = b_3 == _S1001;
    float3  _S1003 = _slang_select(_S1002, _S1001,_S1000);
    return _S1003;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_2)
{
    uint _S1004 = (1U << count_2) - 1U;
    return (e_2 & (~(_S1004 << offset_1))) | ((newbits_0 & _S1004) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_3, uint end_type_0, uint end_0, float3  f_5)
{
    Reservoir candidate_0 = r_3;
    uint _S1005 = insertBits_0(r_3.path, end_0, 0U, 5U);
    uint _S1006 = insertBits_0(_S1005, end_type_0, 12U, 3U);
    (&candidate_0)->path = _S1006;
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
    float _S1007 = rgb_to_greyscale(abs_0(f_6));
    return _S1007;
}

__device__ void offer(Selection * sel_2, Reservoir candidate_1, float3  weight_1)
{
    float _S1008 = resamplingTarget(weight_1);
    bool _S1009 = _S1008 > 0.0f;
    bool _S1010;
    if(_S1009)
    {
        _S1010 = _S1008 < 3.00000000549775576e+38f;
    }
    else
    {
        _S1010 = false;
    }
    bool _S1011 = !_S1010;
    if(_S1011)
    {
        return;
    }
    bool _S1012 = sel_2->sums;
    if(_S1012)
    {
        float3  _S1013 = sel_2->color + weight_1;
        sel_2->color = _S1013;
        return;
    }
    float _S1014 = sel_2->w_sum + _S1008;
    sel_2->w_sum = _S1014;
    float3  _S1015 = sel_2->color + weight_1;
    sel_2->color = _S1015;
    Random _S1016 = pcg(sel_2->random_state);
    sel_2->random_state = _S1016.state;
    bool _S1017 = (_S1016.value * sel_2->w_sum) <= _S1008;
    if(_S1017)
    {
        sel_2->r = candidate_1;
    }
    return;
}

static __device__ Shift escape_0(Reservoir * r_4, bool replay_1, uint stop_0, uint rc_0, uint end_1, uint end_type_1, float scale_3, uint strata_0, Reservoir * chain_0, float3  chain_throughput_0, uint b_4, FKRay * ray_2, float3  throughput_0, float density_1, Vertex * prev_0, NEEVertex * nee_vertex_0, float sky_pdf_0, float3  spectral_weight_0, float wavelength_5, Selection * sel_3)
{
    Shift _S1018 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
    bool _S1019 = !nee_vertex_0->none;
    float _S1020 = _slang_select(_S1019, sky_pdf_0,0.0f);
    float3  _S1021 = ray_2->unit_direction;
    float _S1022 = escapeWeight_0(_S1020, ray_2->unit_direction);
    uint _S1023 = prev_0->lobe;
    float3  _S1024 = environment_0(_S1021, b_4, prev_0->lobe);
    float3  _S1025 = pathColor(throughput_0 * _S1024, spectral_weight_0, wavelength_5);
    if(replay_1)
    {
        bool _S1026 = b_4 == stop_0;
        bool _S1027;
        if(_S1026)
        {
            _S1027 = rc_0 == 3U;
        }
        else
        {
            _S1027 = false;
        }
        if(_S1027)
        {
            return Shift_x24init_0(_S1025 * make_float3 (_S1022) / make_float3 (r_4->jac), density_1 / r_4->jac);
        }
        bool _S1028 = rc_0 == 0U;
        if(_S1028)
        {
            _S1027 = end_type_1 == 3U;
        }
        else
        {
            _S1027 = false;
        }
        if(_S1027)
        {
            _S1027 = b_4 == end_1;
        }
        else
        {
            _S1027 = false;
        }
        if(_S1027)
        {
            _S1027 = !prev_0->rough;
        }
        else
        {
            _S1027 = false;
        }
        if(_S1027)
        {
            return Shift_x24init_0(_S1025 * make_float3 (_S1022), 1.0f);
        }
        return _S1018;
    }
    Reservoir candidate_2 = *chain_0;
    uint _S1029 = chain_0->path;
    uint _S1030 = extractBits_0(chain_0->path, 10U, 2U);
    bool _S1031 = _S1030 == 1U;
    if(_S1031)
    {
        uint _S1032 = extractBits_0(_S1029, 5U, 5U);
        bool _S1033 = _S1032 == b_4;
        float _S1034 = _slang_select(_S1033, 1.0f,_S1022);
        float3  _S1035 = safeDivide(_S1025 * make_float3 (_S1034), chain_throughput_0);
        (&candidate_2)->radiance = _S1035;
    }
    else
    {
        bool _S1036 = prev_0->rough;
        if(_S1036)
        {
            uint _S1037 = insertBits_0(strata_0, b_4 + 1U, 5U, 5U);
            uint _S1038 = insertBits_0(_S1037, 3U, 10U, 2U);
            uint _S1039 = insertBits_0(_S1038, _S1023, 15U, 3U);
            bool _S1040 = prev_0->inside;
            uint _S1041 = _slang_select(_S1040, 1U,0U);
            uint _S1042 = insertBits_0(_S1039, _S1041, 22U, 1U);
            (&candidate_2)->path = _S1042;
            (&candidate_2)->jac = prev_0->pdf;
            (&candidate_2)->dir = _S1021;
        }
    }
    float3  _S1043 = _S1025 * make_float3 (_S1022);
    Reservoir _S1044 = withEnd(candidate_2, 3U, b_4, _S1043);
    offer(sel_3, _S1044, _S1043 * make_float3 (scale_3) / make_float3 (density_1));
    return _S1018;
}

static __device__ void restir_duplicates_0(uint3  global_invocation_id_1, uint3  local_invocation_id_0, uint local_invocation_index_3)
{
    uint2  _S1045 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S1046 = make_int2 ((int)_S1045.x, (int)_S1045.y);
    uint _S1047 = previousSeed_0(_S1046);
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
            uint _S1048 = previousSeed_0(_S1046 + make_int2 (x_17, y_5));
            bool _S1049 = _S1048 == _S1047;
            uint _S1050 = _slang_select(_S1049, 1U,0U);
            uint count_4 = count_3 + _S1050;
            int x_18 = x_17 + int(1);
            x_17 = x_18;
            count_3 = count_4;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S1051 = float(count_3 - 1U) / 288.0f;
    bool _S1052 = _S1047 != 0U;
    float _S1053 = _slang_select(_S1052, _S1051,0.0f);
    fcptStoreDuplication((_S1046), (make_uint4 ((F32_asuint((_S1053))), 0U, 0U, 0U)));
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
    float3  _S1054 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_3)->f = _S1054;
    float _S1055 = r_5.jac * shifted_0.jac;
    (&candidate_3)->jac = _S1055;
    offer(sel_4, candidate_3, make_float3 (mis_0) * shifted_0.f * make_float3 (r_5.w));
    return;
}

__device__ Reservoir finalize(Selection sel_5, float c_1)
{
    Reservoir r_6 = sel_5.r;
    float _S1056 = resamplingTarget((&r_6)->f);
    float _S1057 = sel_5.w_sum / _S1056;
    bool _S1058 = _S1056 > 0.0f;
    float _S1059 = _slang_select(_S1058, _S1057,0.0f);
    (&r_6)->w = _S1059;
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
    uint2  _S1060 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S1061 = make_int2 ((int)_S1060.x, (int)_S1060.y);
    float3  _S1062 = make_float3 (0.0f);
    FKHit _S1063 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S1064 = Domain_x24init_0(_S1062, _S1062, &_S1063, 0.0f, 0.0f);
    Domain dom_5 = _S1064;
    bool _S1065 = (fcptCurrentDomain((_S1061), (&dom_5)));
    bool _S1066 = !_S1065;
    if(_S1066)
    {
        Reservoir _S1067 = (Reservoir{});
        fcptStoreReservoirPrevious((_S1061), (_S1067), ((&dom_5)->hit));
        return;
    }
    Reservoir _S1068 = (fcptLoadReservoirTemporal((_S1061)));
    uint t_15 = 0U;
    float count_5 = 0.0f;
    float c_sum_0 = _S1068.c;
    for(;;)
    {
        uint _S1069 = (fcptRestirNeighbours());
        if(t_15 < _S1069)
        {
        }
        else
        {
            break;
        }
        int2  _S1070 = partner_0(_S1061, t_15);
        Domain neighbor_0 = _S1064;
        bool _S1071 = (fcptCurrentDomain((_S1070), (&neighbor_0)));
        if(_S1071)
        {
            float count_6 = count_5 + 1.0f;
            uint4  _S1072 = (fcptReservoirTemporal((_S1070), (0U)));
            float c_sum_1 = c_sum_0 + (U32_asfloat((_S1072.w)));
            count_5 = count_6;
            c_sum_0 = c_sum_1;
        }
        uint t_16 = t_15 + 1U;
        t_15 = t_16;
    }
    float _S1073 = _S1068.c / (F32_max((count_5), (1.0f)));
    float _S1074 = resamplingTarget(_S1068.f);
    bool _S1075 = count_5 == 0.0f;
    float _S1076 = _slang_select(_S1075, 1.0f,0.0f);
    Selection _S1077 = (Selection{});
    Selection sel_6 = _S1077;
    uint _S1078 = (fcptFrame());
    uint _S1079 = hash(_S1078);
    uint _S1080 = global_invocation_id_2.x;
    uint2  _S1081 = (fcptRenderSize());
    uint _S1082 = stream(_S1079, _S1080 + _S1081.x * global_invocation_id_2.y);
    uint _S1083 = stream(_S1082, 195U);
    (&sel_6)->random_state = _S1083;
    t_15 = 0U;
    float canonical_mis_0 = _S1076;
    for(;;)
    {
        uint _S1084 = (fcptRestirNeighbours());
        if(t_15 < _S1084)
        {
        }
        else
        {
            break;
        }
        int2  _S1085 = partner_0(_S1061, t_15);
        Domain neighbor_dom_0 = _S1064;
        bool _S1086 = (fcptCurrentDomain((_S1085), (&neighbor_dom_0)));
        if(_S1086)
        {
            Reservoir _S1087 = (fcptLoadReservoirTemporal((_S1085)));
            uint4  _S1088 = (fcptShiftData((_S1085), (t_15)));
            float4  _S1089 = asfloat_0(_S1088);
            uint4  _S1090 = (fcptShiftData((_S1061), (t_15)));
            float4  _S1091 = asfloat_0(_S1090);
            float _S1092 = (_S1087.c + _S1073) / c_sum_0;
            bool _S1093 = _S1074 > 0.0f;
            float canonical_mis_1;
            if(_S1093)
            {
                float _S1094 = _S1092 * _S1073 * _S1074;
                float _S1095 = _S1073 * _S1074;
                float _S1096 = resamplingTarget(float3 {_S1091.x, _S1091.y, _S1091.z});
                float canonical_mis_2 = canonical_mis_0 + _S1094 / (_S1095 + _S1087.c * _S1096);
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float _S1097 = resamplingTarget(_S1087.f);
            float3  _S1098 = float3 {_S1089.x, _S1089.y, _S1089.z};
            Shift _S1099 = Shift_x24init_0(_S1098, _S1089.w);
            float _S1100 = _S1092 * _S1087.c * _S1097;
            float _S1101 = _S1087.c * _S1097;
            float _S1102 = resamplingTarget(_S1098);
            offerShifted(&sel_6, _S1087, _S1099, _S1100 / (_S1101 + _S1073 * _S1102));
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_17 = t_15 + 1U;
        t_15 = t_17;
    }
    offerShifted(&sel_6, _S1068, Shift_x24init_0(_S1068.f, 1.0f), canonical_mis_0);
    Reservoir _S1103 = finalize(sel_6, c_sum_0);
    fcptStoreReservoirPrevious((_S1061), (_S1103), ((&dom_5)->hit));
    fcptStorePreviousLayer((_S1061), (5U), (make_uint4 (asuint_0((&(&dom_5)->hit)->uv).x, asuint_0((&(&dom_5)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S1061), (make_float4 ((&sel_6)->color.x, (&sel_6)->color.y, (&sel_6)->color.z, 0.0f)));
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
    uint _S1104 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S1105 = _S1104 != 4294967295U;
    if(_S1105)
    {
        uint2  _S1106 = make_uint2 (_S1104, _S1104 >> 14U) & make_uint2 (16383U);
        int2  _S1107 = make_int2 ((int)_S1106.x, (int)_S1106.y);
        ShiftJob _S1108 = (ShiftJob{});
        ShiftJob shift_job_0 = _S1108;
        Shift _S1109 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S1110 = _S1104 >> 28U;
        bool _S1111 = spatialJob_0(_S1107, _S1110, &shift_job_0, true);
        Shift shifted_1;
        if(_S1111)
        {
            Domain _S1112 = (&shift_job_0)->dom;
            Reservoir _S1113 = (&shift_job_0)->r;
            Shift _S1114 = passShift_0(&_S1112, &_S1113);
            shifted_1 = _S1114;
        }
        else
        {
            shifted_1 = _S1109;
        }
        fcptStoreShiftData((_S1107), (_S1110), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S1115 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S1116 = make_int2 ((int)_S1115.x, (int)_S1115.y);
    FixedArray<uint, 3>  _S1117;
    spatialBins_0(_S1116, &_S1117);
    FixedArray<uint, 3>  _S1118 = _S1117;
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
        bool _S1119 = (_S1118[t_18]) == 40U;
        if(_S1119)
        {
            fcptStoreShiftData((_S1116), (t_18), (make_uint4 (0U)));
        }
        uint t_19 = t_18 + 1U;
        t_18 = t_19;
    }
    FixedArray<uint, 3>  _S1120 = _S1118;
    queueShifts_0(_S1116, &_S1120, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S1121 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S1122 = make_int2 ((int)_S1121.x, (int)_S1121.y);
    FixedArray<uint, 3>  _S1123;
    spatialBins_0(_S1122, &_S1123);
    FixedArray<uint, 3>  _S1124 = _S1123;
    countShifts_0(&_S1124, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S1125 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S1126 = _S1125 != 4294967295U;
    if(_S1126)
    {
        uint2  _S1127 = make_uint2 (_S1125, _S1125 >> 14U) & make_uint2 (16383U);
        int2  _S1128 = make_int2 ((int)_S1127.x, (int)_S1127.y);
        int2  _S1129 = storedNeighbor_0(_S1128);
        uint _S1130 = _S1125 >> 28U;
        Shift _S1131 = temporalShiftAt_0(_S1128, _S1129, _S1130);
        fcptStoreTemporalShift((_S1128), (_S1130), (make_uint4 (asuint_1(_S1131.f).x, asuint_1(_S1131.f).y, asuint_1(_S1131.f).z, (F32_asuint((_S1131.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S1132 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S1133 = make_int2 ((int)_S1132.x, (int)_S1132.y);
    FixedArray<uint, 3>  _S1134;
    temporalBins_0(_S1133, &_S1134);
    FixedArray<uint, 3>  _S1135 = _S1134;
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
        bool _S1136 = (_S1135[t_20]) == 40U;
        if(_S1136)
        {
            fcptStoreTemporalShift((_S1133), (t_20), (make_uint4 (0U)));
        }
        uint t_21 = t_20 + 1U;
        t_20 = t_21;
    }
    FixedArray<uint, 3>  _S1137 = _S1135;
    queueShifts_0(_S1133, &_S1137, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S1138 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S1139 = make_int2 ((int)_S1138.x, (int)_S1138.y);
    bool _S1140 = (fcptSceneUnchanged());
    bool _S1141 = !_S1140;
    bool _S1142;
    if(_S1141)
    {
        uint2  _S1143 = (fcptRenderSize());
        int2  _S1144 = make_int2 ((int)_S1143.x, (int)_S1143.y);
        _S1142 = all_0(_S1139 < _S1144);
    }
    else
    {
        _S1142 = false;
    }
    if(_S1142)
    {
        Reservoir _S1145 = (fcptLoadReservoirInitial((_S1139)));
        int2  _S1146 = sampleNeighbor_0(_S1139, _S1145.seed);
        fcptStoreTemporalNeighbor((_S1139), (_S1146));
    }
    FixedArray<uint, 3>  _S1147;
    temporalBins_0(_S1139, &_S1147);
    FixedArray<uint, 3>  _S1148 = _S1147;
    countShifts_0(&_S1148, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_8, float b_5, float t_22)
{
    return a_8 + (b_5 - a_8) * t_22;
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S1149 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S1150 = make_int2 ((int)_S1149.x, (int)_S1149.y);
    float3  _S1151 = make_float3 (0.0f);
    FKHit _S1152 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S1153 = Domain_x24init_0(_S1151, _S1151, &_S1152, 0.0f, 0.0f);
    Domain dom_6 = _S1153;
    bool _S1154 = (fcptCurrentDomain((_S1150), (&dom_6)));
    bool _S1155 = !_S1154;
    if(_S1155)
    {
        Reservoir _S1156 = (Reservoir{});
        fcptStoreReservoirTemporal((_S1150), (_S1156), ((&dom_6)->hit));
        return;
    }
    Reservoir _S1157 = (fcptLoadReservoirInitial((_S1150)));
    bool _S1158 = (fcptTemporalQueued());
    bool _S1159 = (fcptSceneUnchanged());
    bool _S1160;
    if(_S1159)
    {
        _S1160 = true;
    }
    else
    {
        _S1160 = !_S1158;
    }
    int2  _S1161;
    if(_S1160)
    {
        int2  _S1162 = sampleNeighbor_0(_S1150, _S1157.seed);
        _S1161 = _S1162;
    }
    else
    {
        int2  _S1163 = storedNeighbor_0(_S1150);
        _S1161 = _S1163;
    }
    bool _S1164 = (_S1161.x) >= int(0);
    Reservoir r_7;
    if(_S1164)
    {
        Reservoir _S1165 = (fcptLoadReservoirPrevious((_S1161)));
        uint4  _S1166 = (fcptDuplication((_S1161)));
        float _S1167 = (U32_asfloat((_S1166.x)));
        uint _S1168 = (fcptRestirDecorrelation());
        bool _S1169 = _S1168 == 1U;
        float _S1170 = _slang_select(_S1169, _S1167,0.0f);
        float _S1171 = interpolate_0(20.0f, 1.0f, (F32_pow((_S1170), (0.10000000149011612f))));
        float _S1172 = (F32_min((_S1165.c), (_S1171)));
        bool _S1173 = (fcptSceneUnchanged());
        float4  _S1174 = make_float4 (_S1165.f.x, _S1165.f.y, _S1165.f.z, 1.0f);
        bool _S1175 = !_S1173;
        if(_S1175)
        {
            _S1160 = _S1158;
        }
        else
        {
            _S1160 = false;
        }
        float4  to_current_0;
        if(_S1160)
        {
            uint4  _S1176 = (fcptTemporalShift((_S1150), (0U)));
            float4  _S1177 = asfloat_0(_S1176);
            to_current_0 = _S1177;
        }
        else
        {
            if(_S1175)
            {
                Shift _S1178 = temporalShiftAt_0(_S1150, _S1161, 0U);
                float4  _S1179 = make_float4 (_S1178.f.x, _S1178.f.y, _S1178.f.z, _S1178.jac);
                to_current_0 = _S1179;
            }
            else
            {
                to_current_0 = _S1174;
            }
        }
        Domain own_1 = _S1153;
        if(_S1173)
        {
            _S1160 = true;
        }
        else
        {
            bool _S1180 = (fcptPreviousScenes());
            bool _S1181 = !_S1180;
            if(_S1181)
            {
                _S1160 = (_S1157.w) > 0.0f;
            }
            else
            {
                _S1160 = false;
            }
            if(_S1160)
            {
                bool _S1182 = (fcptStoredDomainInitial((_S1150), (_S1157.seed), (&own_1)));
                _S1160 = _S1182;
            }
            else
            {
                _S1160 = false;
            }
            if(_S1160)
            {
                Domain _S1183 = (fcptPreviousDomain((_S1161), (_S1157.seed)));
                Domain _S1184 = _S1183;
                Domain _S1185 = own_1;
                bool _S1186 = sameDomain_0(&_S1184, &_S1185);
                _S1160 = _S1186;
            }
            else
            {
                _S1160 = false;
            }
        }
        float4  _S1187 = make_float4 (_S1157.f.x, _S1157.f.y, _S1157.f.z, 1.0f);
        bool _S1188 = !_S1160;
        if(_S1188)
        {
            _S1160 = _S1158;
        }
        else
        {
            _S1160 = false;
        }
        float4  to_previous_0;
        if(_S1160)
        {
            uint4  _S1189 = (fcptTemporalShift((_S1150), (1U)));
            float4  _S1190 = asfloat_0(_S1189);
            to_previous_0 = _S1190;
        }
        else
        {
            if(_S1188)
            {
                Shift _S1191 = temporalShiftAt_0(_S1150, _S1161, 1U);
                float4  _S1192 = make_float4 (_S1191.f.x, _S1191.f.y, _S1191.f.z, _S1191.jac);
                to_previous_0 = _S1192;
            }
            else
            {
                to_previous_0 = _S1187;
            }
        }
        float _S1193 = resamplingTarget(_S1157.f);
        float _S1194 = resamplingTarget(_S1165.f);
        Selection _S1195 = (Selection{});
        Selection sel_7 = _S1195;
        uint _S1196 = (fcptFrame());
        uint _S1197 = hash(_S1196);
        uint _S1198 = global_invocation_id_7.x;
        uint2  _S1199 = (fcptRenderSize());
        uint _S1200 = stream(_S1197, _S1198 + _S1199.x * global_invocation_id_7.y);
        uint _S1201 = stream(_S1200, 194U);
        (&sel_7)->random_state = _S1201;
        float _S1202 = _S1157.c * _S1193;
        float4  _S1203 = to_previous_0;
        float _S1204 = resamplingTarget(float3 {_S1203.x, _S1203.y, _S1203.z});
        float _S1205 = _S1202 / (_S1202 + _S1172 * _S1204);
        float _S1206 = _S1172 * _S1194;
        float4  _S1207 = to_current_0;
        float3  _S1208 = float3 {_S1207.x, _S1207.y, _S1207.z};
        float _S1209 = resamplingTarget(_S1208);
        float _S1210 = _S1206 / (_S1206 + _S1157.c * _S1209);
        float2  _S1211 = make_float2 (_S1205, _S1210);
        offerShifted(&sel_7, _S1157, Shift_x24init_0(_S1157.f, 1.0f), _S1205);
        offerShifted(&sel_7, _S1165, Shift_x24init_0(_S1208, to_current_0.w), _S1210);
        Reservoir _S1212 = finalize(sel_7, _S1157.c + _S1172);
        r_7 = _S1212;
    }
    else
    {
        r_7 = _S1157;
    }
    fcptStoreReservoirTemporal((_S1150), (r_7), ((&dom_6)->hit));
    return;
}

__device__ uint noiseOrigin(uint2  p_16, uint k_1)
{
    uint _S1213 = ((p_16.x) >> 11U) | (((p_16.y) >> 11U) << 4U);
    uint2  _S1214 = noiseOffset(8192U + (k_1 >> 10U) + (_S1213 << 20U));
    uint2  _S1215 = (p_16 + _S1214) & make_uint2 (2047U);
    return ((_S1215.x) | ((_S1215.y) << 11U)) | ((k_1 & 1023U) << 22U);
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S1216 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S1217 = make_int2 ((int)_S1216.x, (int)_S1216.y);
    float3  _S1218 = make_float3 (0.0f);
    FKHit _S1219 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S1220 = Domain_x24init_0(_S1218, _S1218, &_S1219, 0.0f, 0.0f);
    Domain dom_7 = _S1220;
    bool _S1221 = (fcptCurrentDomain((_S1217), (&dom_7)));
    bool _S1222 = !_S1221;
    if(_S1222)
    {
        Reservoir _S1223 = (Reservoir{});
        fcptStoreReservoirInitial((_S1217), (_S1223), ((&dom_7)->hit));
        return;
    }
    uint _S1224 = (fcptFrame());
    uint _S1225 = hash(_S1224);
    uint _S1226 = global_invocation_id_8.x;
    uint2  _S1227 = (fcptRenderSize());
    uint _S1228 = global_invocation_id_8.y;
    uint _S1229 = stream(_S1225, _S1226 + _S1227.x * _S1228);
    uint2  _S1230 = (fcptRenderSize());
    uint _S1231 = stream(_S1226 + _S1230.x * _S1228, 512U);
    Selection _S1232 = (Selection{});
    Selection initial_0 = _S1232;
    uint _S1233 = stream(_S1229, 193U);
    (&initial_0)->random_state = _S1233;
    bool _S1234 = (fcptRestirUsed());
    bool _S1235 = !_S1234;
    (&initial_0)->sums = _S1235;
    uint _S1236 = stream(_S1229, 0U);
    (&(&initial_0)->r)->seed = _S1236;
    FKHit _S1237 = (&dom_7)->hit;
    uint _S1238 = (fcptSamples());
    float _S1239 = 1.0f / float(_S1238);
    FKHit hit_2 = _S1237;
    uint i_18 = 0U;
    float3  seen_1 = _S1218;
    for(;;)
    {
        uint _S1240 = (fcptSamples());
        if(i_18 < _S1240)
        {
        }
        else
        {
            break;
        }
        Reservoir _S1241 = (Reservoir{});
        Reservoir r_8 = _S1241;
        uint _S1242 = (fcptFrame());
        uint _S1243 = (fcptSamples());
        uint _S1244 = _S1242 * _S1243 + i_18;
        uint _S1245 = noiseOrigin(_S1216, _S1244);
        (&r_8)->seed = _S1245;
        uint _S1246 = insertBits_0(0U, 1U, 24U, 1U);
        uint _S1247 = insertBits_0(_S1246, (_S1231 + _S1244 * 2654435769U) >> 25U, 25U, 7U);
        (&r_8)->path = _S1247;
        Domain path_0 = dom_7;
        bool _S1248 = seedDomain_0(_S1217, (&r_8)->seed, &path_0);
        bool _S1249 = !_S1248;
        if(_S1249)
        {
            float3  _S1250 = (fcptMissed((_S1217), (path_0), (_S1239)));
            float3  seen_2 = seen_1 + _S1250;
            seen_1 = seen_2;
            uint i_19 = i_18 + 1U;
            i_18 = i_19;
            continue;
        }
        Domain _S1251 = path_0;
        Reservoir _S1252 = r_8;
        Shift _S1253 = passWalk_0(&_S1251, &_S1252, false, _S1239, &initial_0);
        bool _S1254 = ((&(&initial_0)->r)->seed) == ((&r_8)->seed);
        FKHit hit_3;
        if(_S1254)
        {
            FKHit _S1255 = (&path_0)->hit;
            hit_3 = _S1255;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_19 = i_18 + 1U;
        i_18 = i_19;
    }
    uint _S1256 = (fcptSamples());
    float3  seen_3 = seen_1 + (&initial_0)->glow / make_float3 (float(_S1256));
    float3  _S1257 = seen_3 + (&initial_0)->color;
    bool _S1258 = (&initial_0)->sums;
    float3  _S1259 = _slang_select(_S1258, _S1257,seen_3);
    fcptAddColor((_S1217), (make_float4 (_S1259.x, _S1259.y, _S1259.z, 1.0f)));
    Reservoir _S1260 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S1217), (_S1260), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_2, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S1261;
    (&_S1261)->none = none_0;
    (&_S1261)->pdf = pdf_2;
    (&_S1261)->origin = origin_5;
    (&_S1261)->smooth_n = smooth_n_3;
    (&_S1261)->start = start_6;
    return _S1261;
}

static __device__ Vertex Vertex_x24init_0(bool rough_0, uint lobe_1, float pdf_3, float cos_0, bool inside_0)
{
    Vertex _S1262;
    (&_S1262)->rough = rough_0;
    (&_S1262)->lobe = lobe_1;
    (&_S1262)->pdf = pdf_3;
    (&_S1262)->cos = cos_0;
    (&_S1262)->inside = inside_0;
    return _S1262;
}

__device__ uint noiseAddress(uint origin_6, uint bounce_0)
{
    uint2  _S1263 = make_uint2 (origin_6 & 2047U, (origin_6 >> 11U) & 2047U);
    uint2  _S1264 = noiseOffset(64U + bounce_0 * 17U);
    uint2  _S1265 = (_S1263 + _S1264) & make_uint2 (2047U);
    return ((_S1265.x) | ((_S1265.y) << 11U)) | ((origin_6 >> 22U) << 22U);
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
    float3  _S1266 = exp_0(- scatter_0 * make_float3 (distance_2));
    float3  _S1267 = make_float3 (3.0f) * exp_0(- extinction_0 * make_float3 (distance_2));
    float3  _S1268 = _S1267 / make_float3 (_S1266.x + _S1266.y + _S1266.z);
    float3  _S1269 = scatter_0 * _S1267 / make_float3 (dot_0(scatter_0, _S1266));
    float3  _S1270 = _slang_select(scatters_0, _S1269,_S1268);
    return _S1270;
}

static __device__ uint arrivalLobe_0(uint b_6, uint prev_lobe_0)
{
    bool _S1271 = b_6 > 0U;
    uint _S1272 = _slang_select(_S1271, prev_lobe_0,3U);
    return _S1272;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_1, uint depth_2, uint lobe_2, bool surface_4, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S1273;
    (&_S1273)->extinction_behind = extinction_behind_0;
    (&_S1273)->extinction_front = extinction_front_0;
    (&_S1273)->fillings = fillings_0;
    (&_S1273)->side = side_1;
    (&_S1273)->depth = depth_2;
    (&_S1273)->lobe = lobe_2;
    (&_S1273)->surface = surface_4;
    (&_S1273)->length = length_2;
    (&_S1273)->width = width_1;
    (&_S1273)->own = *own_2;
    (&_S1273)->fiber = fiber_0;
    return _S1273;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S1274 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S1274)
    {
        return 0.07957746833562851f;
    }
    float _S1275 = g_0 * g_0;
    return (1.0f - _S1275) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S1275 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float survivalProbability(float3  throughput_1, float density_2)
{
    return (F32_min(((F32_max(((F32_max((throughput_1.x), ((F32_max((throughput_1.y), (throughput_1.z)))))) / density_2), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_4)
{
    Random _S1276 = draw(random_state_4, 11U);
    Random _S1277 = draw(random_state_4, 2147483659U);
    float _S1278 = 1.0f - 2.0f * _S1276.value;
    float _S1279 = (F32_sqrt(((F32_max((1.0f - _S1278 * _S1278), (0.0f))))));
    float _S1280 = 6.28318548202514648f * _S1277.value;
    return make_float3 (_S1279 * (F32_cos((_S1280))), _S1279 * (F32_sin((_S1280))), _S1278);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_11, uint random_state_5, float * pdf_4)
{
    bool _S1281 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1281)
    {
        *pdf_4 = 0.07957746833562851f;
        float3  _S1282 = isotropic_0(random_state_5);
        return _S1282;
    }
    Random _S1283 = draw(random_state_5, 11U);
    Random _S1284 = draw(random_state_5, 2147483659U);
    float _S1285 = g_1 * g_1;
    float _S1286 = 2.0f * g_1;
    float _S1287 = (1.0f - _S1285) / (1.0f - g_1 + _S1286 * _S1283.value);
    float _S1288 = clamp_1((1.0f + _S1285 - _S1287 * _S1287) / _S1286, -1.0f, 1.0f);
    float _S1289 = (F32_sqrt(((F32_max((1.0f - _S1288 * _S1288), (0.0f))))));
    float _S1290 = 6.28318548202514648f * _S1284.value;
    float _S1291 = phaseHG_0(g_1, _S1288);
    *pdf_4 = _S1291;
    float3  _S1292 = tangentToWorld(make_float3 (_S1289 * (F32_cos((_S1290))), _S1288, _S1289 * (F32_sin((_S1290)))), dir_11);
    float3  _S1293 = ((((_S1292)) * make_float3(rnorm3df(((_S1292)).x, ((_S1292)).y, ((_S1292)).z))));
    return _S1293;
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_1, float3  emissive_1, float roughness_0, float metallic_0, float transmission_0, float ior_1, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_1, float velvet_0, float3  toon_2, float dispersion_0, float coat_2, float coat_roughness_0, float coat_ior_0, float3  coat_tint_0, float3  coat_normal_0)
{
    BSDFMaterial _S1294;
    (&_S1294)->albedo = albedo_1;
    (&_S1294)->emissive = emissive_1;
    (&_S1294)->roughness = roughness_0;
    (&_S1294)->metallic = metallic_0;
    (&_S1294)->transmission = transmission_0;
    (&_S1294)->ior = ior_1;
    (&_S1294)->absorption = absorption_0;
    (&_S1294)->specular_tint = specular_tint_0;
    (&_S1294)->specular_level = specular_level_0;
    (&_S1294)->translucent = translucent_0;
    (&_S1294)->sheen = sheen_2;
    (&_S1294)->sheen_roughness = sheen_roughness_0;
    (&_S1294)->anisotropy = anisotropy_0;
    (&_S1294)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1294)->tangent = tangent_1;
    (&_S1294)->velvet = velvet_0;
    (&_S1294)->toon = toon_2;
    (&_S1294)->dispersion = dispersion_0;
    (&_S1294)->coat = coat_2;
    (&_S1294)->coat_roughness = coat_roughness_0;
    (&_S1294)->coat_ior = coat_ior_0;
    (&_S1294)->coat_tint = coat_tint_0;
    (&_S1294)->coat_normal = coat_normal_0;
    return _S1294;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1295;
    (&_S1295)->scatter = scatter_1;
    (&_S1295)->extinction = extinction_1;
    (&_S1295)->g = g_2;
    return _S1295;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_15, bool skip_0, uint random_state_6, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1296;
    (&_S1296)->smooth_n = smooth_n_4;
    (&_S1296)->geometry_n = geometry_n_2;
    (&_S1296)->geometry_offset = geometry_offset_2;
    (&_S1296)->material = *material_15;
    (&_S1296)->skip = skip_0;
    (&_S1296)->random_state = random_state_6;
    (&_S1296)->coverage = coverage_0;
    (&_S1296)->encloses = encloses_0;
    (&_S1296)->volume = *volume_0;
    (&_S1296)->fills = fills_0;
    (&_S1296)->hair = hair_0;
    return _S1296;
}

static __device__ FKSurface emitting_0(FKSurface * surface_5, bool top_0)
{
    FKSurface lower_0 = *surface_5;
    float3  _S1297 = (&surface_5->material)->emissive;
    float3  _S1298 = make_float3 (0.0f);
    bool _S1299 = !top_0;
    float3  _S1300 = _slang_select(_S1299, _S1298,_S1297);
    (&(&lower_0)->material)->emissive = _S1300;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_6, float u_1)
{
    float _S1301 = surface_6->coverage;
    bool _S1302 = u_1 < _S1301;
    if(_S1302)
    {
        return *surface_6;
    }
    float3  _S1303 = make_float3 (0.0f);
    float3  _S1304 = make_float3 (1.0f);
    BSDFMaterial _S1305 = Material_x24init_0(_S1303, _S1303, 0.0f, 0.0f, 0.0f, 0.0f, _S1303, _S1304, 1.0f, _S1303, _S1303, 0.5f, 0.0f, 0.0f, _S1303, 0.0f, _S1303, 0.0f, 0.0f, 0.02999999932944775f, 1.5f, _S1304, _S1303);
    BSDFMaterial material_16 = _S1305;
    (&material_16)->albedo = _S1304;
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
    bool _S1306 = transmission_1 > 0.0f;
    bool _S1307;
    if(_S1306)
    {
        _S1307 = true;
    }
    else
    {
        _S1307 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1308 = _slang_select(_S1307, 1.0f,-1.0f);
    return _S1308;
}

static __device__ bool arrivesBehind_0(float3  dir_12, float3  n_9)
{
    return (dot_0(dir_12, n_9)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_7, float3  dir_13)
{
    float3  _S1309 = surface_7->geometry_n;
    float _S1310 = facingSign((&surface_7->material)->transmission, surface_7->geometry_n, dir_13);
    FKSurface faced_0 = *surface_7;
    float3  _S1311 = surface_7->smooth_n * make_float3 (_S1310);
    (&faced_0)->smooth_n = _S1311;
    float3  _S1312 = _S1309 * make_float3 (_S1310);
    (&faced_0)->geometry_n = _S1312;
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
    float3  _S1313 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1313));
}

__device__ bool dispersive(BSDFMaterial material_17)
{
    bool _S1314 = (material_17.dispersion) > 0.0f;
    bool _S1315;
    if(_S1314)
    {
        _S1315 = (material_17.ior) != 1.0f;
    }
    else
    {
        _S1315 = false;
    }
    return _S1315;
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
        uint _S1316 = (low_1 + high_1 + 1U) / 2U;
        bool _S1317 = (WAVELENGTH_CDF_0[_S1316]) <= u_2;
        if(_S1317)
        {
            low_1 = _S1316;
        }
        else
        {
            uint _S1318 = _S1316 - 1U;
            high_1 = _S1318;
        }
    }
    uint _S1319 = low_1;
    float _S1320 = WAVELENGTH_CDF_0[low_1 + 1U] - WAVELENGTH_CDF_0[low_1];
    return make_float2 (0.37999999523162842f + 0.00499999988824129f * (float(low_1) + (u_2 - WAVELENGTH_CDF_0[_S1319]) / _S1320), _S1320 / 0.00499999988824129f);
}

__device__ static const FixedArray<float, 243>  WAVELENGTH_WEIGHTS_0 = { {
    0.00547470012679696f, -0.00465690018609166f, 0.03257500007748604f, 0.00934640038758516f, -0.00796370021998882f, 0.05577300116419792f, 0.01846100017428398f, -0.01579399965703487f, 0.11072999984025955f, 0.0416410006582737f, -0.03577499836683273f, 0.2513900101184845f, 0.09349299967288971f, -0.08071800321340561f, 0.56742000579833984f, 0.1585099995136261f, -0.13764999806880951f, 0.97018998861312866f, 0.30943000316619873f, -0.27083000540733337f, 1.91740000247955322f, 0.55217999219894409f, -0.48754000663757324f, 3.46889996528625488f, 0.95016998052597046f, -0.84802001714706421f, 6.09439992904663086f, 1.42110002040863037f, -1.28929996490478516f, 9.45199966430664062f, 1.73409998416900635f, -1.6062999963760376f, 12.12800025939941406f, 2.08030009269714355f, -1.98810005187988281f, 15.68700027465820312f, 2.20600008964538574f, -2.20120000839233398f, 18.47699928283691406f, 2.03040003776550293f, -2.17700004577636719f, 19.92700004577636719f, 1.63429999351501465f, -2.00340008735656738f, 20.86899948120117188f, 0.99410998821258545f, -1.62629997730255127f, 20.57799911499023438f, 0.20011000335216522f, -1.11409997940063477f, 19.72100067138671875f, -0.67960000038146973f, -0.45403000712394714f, 17.77599906921386719f, -1.61679995059967041f, 0.37860000133514404f, 14.71500015258789062f, -2.53410005569458008f, 1.27540004253387451f, 11.86499977111816406f, -3.39079999923706055f, 2.2146000862121582f, 9.17669963836669922f, -4.03749990463256836f, 3.0522000789642334f, 6.59509992599487305f, -4.61299991607666016f, 3.89779996871948242f, 4.64589977264404297f, -5.43039989471435547f, 5.0121002197265625f, 3.3199000358581543f, -6.37769985198974609f, 6.33809995651245117f, 2.29699993133544922f, -7.44140005111694336f, 7.91739988327026367f, 1.45389997959136963f, -8.38580036163330078f, 9.60109996795654297f, 0.66465997695922852f, -9.0167999267578125f, 11.23999977111816406f, -0.04403600096702576f, -9.17749977111816406f, 12.63199996948242188f, -0.58126997947692871f, -8.97550010681152344f, 13.91499996185302734f, -0.95730000734329224f, -8.25290012359619141f, 14.86200046539306641f, -1.24430000782012939f, -6.92129993438720703f, 15.03899955749511719f, -1.43069994449615479f, -5.29169988632202148f, 14.90900039672851562f, -1.55149996280670166f, -3.43219995498657227f, 14.70499992370605469f, -1.63569998741149902f, -1.27190005779266357f, 14.24400043487548828f, -1.67030000686645508f, 1.15170001983642578f, 13.32199954986572266f, -1.636199951171875f, 3.73889994621276855f, 12.21199989318847656f, -1.56920003890991211f, 6.43590021133422852f, 10.94699954986572266f, -1.47730004787445068f, 9.16440010070800781f, 9.54769992828369141f, -1.36399996280670166f, 12.02000045776367188f, 8.18799972534179688f, -1.25450003147125244f, 14.78699970245361328f, 6.74429988861083984f, -1.13110005855560303f, 16.72299957275390625f, 5.08780002593994141f, -0.96561002731323242f, 18.14299964904785156f, 3.57019996643066406f, -0.80725997686386108f, 19.91900062561035156f, 2.36269998550415039f, -0.69273000955581665f, 21.05500030517578125f, 1.31369996070861816f, -0.58597999811172485f, 21.3899993896484375f, 0.42390000820159912f, -0.48298001289367676f, 20.99300003051757812f, -0.23857000470161438f, -0.39412000775337219f, 19.82200050354003906f, -0.6866300106048584f, -0.31501999497413635f, 18.12000083923339844f, -0.9412500262260437f, -0.24890999495983124f, 15.7089996337890625f, -1.02020001411437988f, -0.19076000154018402f, 13.19799995422363281f, -0.98919999599456787f, -0.14401000738143921f, 11.23999977111816406f, -0.93347001075744629f, -0.11133000254631042f, 9.36649990081787109f, -0.83820998668670654f, -0.08524099737405777f, 7.41249990463256836f, -0.70064002275466919f, -0.06283199787139893f, 5.71229982376098633f, -0.56079000234603882f, -0.04586699977517128f, 4.42280006408691406f, -0.44653001427650452f, -0.03396600112318993f, 3.34489989280700684f, -0.34457001090049744f, -0.02482499927282333f, 2.49309992790222168f, -0.26017999649047852f, -0.01808100007474422f, 1.82239997386932373f, -0.1921599954366684f, -0.01296999957412481f, 1.29499995708465576f, -0.13766999542713165f, -0.00907570030540228f, 0.92928999662399292f, -0.09956400096416473f, -0.00641620019450784f, 0.61835998296737671f, -0.06671299785375595f, -0.00421149982139468f, 0.40211999416351318f, -0.04354599863290787f, -0.00271830009296536f, 0.2844499945640564f, -0.03087200038135052f, -0.00191440002527088f, 0.20672999322414398f, -0.02246100082993507f, -0.00138829997740686f, 0.15044000744819641f, -0.01634499989449978f, -0.00101030000951141f, 0.10942000150680542f, -0.01188699994236231f, -0.0007347899954766f, 0.07099699974060059f, -0.00771349994465709f, -0.00047679000999779f, 0.04539500176906586f, -0.00493190018460155f, -0.00030484999297187f, 0.03424099832773209f, -0.00372010003775358f, -0.00022995000472292f, 0.02557599917054176f, -0.00277870008721948f, -0.00017175999528263f, 0.01842200011014938f, -0.00200140010565519f, -0.0001237099932041f, 0.01316899992525578f, -0.00143079995177686f, -0.00008843900286593f, 0.00838890019804239f, -0.00091141002485529f, -0.00005633700129692f, 0.00537079991772771f, -0.00058350997278467f, -0.00003606799873523f, 0.00328280008397996f, -0.00035665999166667f, -0.00002204600059486f, 0.00196009990759194f, -0.00021296000340953f, -0.00001316300040344f, 0.00168939994182438f, -0.00018354000349063f, -0.00001134499962063f, 0.00141050003003329f, -0.00015325000276789f, -0.00000947250009631f, 0.00097123999148607f, -0.00010551999730524f, -6.52239987175562419e-06f, 0.00066868000430986f, -0.00007264900341397f, -4.49060007667867467e-06f
} };
__device__ float3  wavelengthWeights(float wavelength_6)
{
    float _S1321 = clamp_1((wavelength_6 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    uint _S1322 = (U32_min((uint(_S1321)), (79U)));
    uint _S1323 = 3U * _S1322;
    float3  _S1324 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1323], WAVELENGTH_WEIGHTS_0[_S1323 + 1U], WAVELENGTH_WEIGHTS_0[_S1323 + 2U]);
    float3  _S1325 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1323 + 3U], WAVELENGTH_WEIGHTS_0[_S1323 + 4U], WAVELENGTH_WEIGHTS_0[_S1323 + 5U]);
    return _S1324 + (_S1325 - _S1324) * make_float3 (_S1321 - float(_S1322));
}

__device__ float dispersedIor(float ior_2, float dispersion_1, float wavelength_7)
{
    float _S1326 = (ior_2 - 1.0f) * dispersion_1 / 1.90962409973144531f;
    float _S1327 = _S1326 * (1.0f / (wavelength_7 * wavelength_7) - 2.89662933349609375f);
    bool _S1328 = dispersion_1 > 0.0f;
    float _S1329 = _slang_select(_S1328, _S1327,0.0f);
    return ior_2 + _S1329;
}

__device__ float2  vertexEta(BSDFMaterial material_18, float n_dot_v_0)
{
    bool _S1330 = n_dot_v_0 < 0.0f;
    float _S1331 = _slang_select(_S1330, material_18.ior,1.0f);
    float _S1332 = _slang_select(_S1330, 1.0f,material_18.ior);
    return make_float2 (_S1331, _S1332);
}

__device__ float2  wavelengthEta(BSDFMaterial material_19, float n_dot_v_1, float wavelength_8)
{
    BSDFMaterial refractive_0 = material_19;
    float _S1333 = dispersedIor(material_19.ior, material_19.dispersion, wavelength_8);
    bool _S1334 = wavelength_8 > 0.0f;
    float _S1335 = _slang_select(_S1334, _S1333,material_19.ior);
    (&refractive_0)->ior = _S1335;
    float2  _S1336 = vertexEta(refractive_0, n_dot_v_1);
    return _S1336;
}

static __device__ float unshared_0(float x_25)
{
    return x_25;
}

__device__ float3  sampleGGXVNDF(float3  Ve_0, float alpha_5, float U1_0, float U2_0)
{
    float3  _S1337 = make_float3 (alpha_5 * Ve_0.x, alpha_5 * Ve_0.y, Ve_0.z);
    float3  _S1338 = ((((_S1337)) * make_float3(rnorm3df(((_S1337)).x, ((_S1337)).y, ((_S1337)).z))));
    float _S1339 = _S1338.x;
    float _S1340 = _S1338.y;
    float _S1341 = _S1339 * _S1339 + _S1340 * _S1340;
    float3  _S1342 = make_float3 (1.0f, 0.0f, 0.0f);
    float3  _S1343 = make_float3 (- _S1340, _S1339, 0.0f);
    float _S1344 = (rsqrtf((_S1341)));
    float3  _S1345 = _S1343 * make_float3 (_S1344);
    bool _S1346 = _S1341 > 0.0f;
    float3  _S1347 = _slang_select(_S1346, _S1345,_S1342);
    float3  _S1348 = cross_0(_S1338, _S1347);
    float _S1349 = (F32_sqrt((U1_0)));
    float _S1350 = 6.28318548202514648f * U2_0;
    float _S1351 = _S1349 * (F32_cos((_S1350)));
    float t2_0 = _S1349 * (F32_sin((_S1350)));
    float _S1352 = 0.5f * (1.0f + _S1338.z);
    float t2_1 = (1.0f - _S1352) * (F32_sqrt(((F32_max((0.0f), (1.0f - _S1351 * _S1351)))))) + _S1352 * t2_0;
    float3  _S1353 = make_float3 (_S1351) * _S1347 + make_float3 (t2_1) * _S1348;
    float _S1354 = unshared_0(_S1351);
    float _S1355 = unshared_0(_S1351);
    float3  _S1356 = _S1353 + make_float3 ((F32_sqrt(((F32_max((0.0f), (1.0f - _S1354 * _S1355 - t2_1 * t2_1))))))) * _S1338;
    float3  _S1357 = make_float3 (alpha_5 * _S1356.x, alpha_5 * _S1356.y, (F32_max((0.0f), (_S1356.z))));
    float3  _S1358 = ((((_S1357)) * make_float3(rnorm3df(((_S1357)).x, ((_S1357)).y, ((_S1357)).z))));
    return _S1358;
}

__device__ float3  worldToTangent(float3  v_8, float3  n_10)
{
    float3  a_9 = make_float3 (0.0f, 1.0f, 0.0f);
    bool _S1359 = (F32_abs((dot_0(n_10, a_9)))) > 0.9999847412109375f;
    float3  a_10;
    if(_S1359)
    {
        float3  _S1360 = make_float3 (1.0f, 0.0f, 0.0f);
        a_10 = _S1360;
    }
    else
    {
        a_10 = a_9;
    }
    float3  _S1361 = cross_0(n_10, a_10);
    float3  _S1362 = ((((_S1361)) * make_float3(rnorm3df(((_S1361)).x, ((_S1361)).y, ((_S1361)).z))));
    float3  _S1363 = cross_0(n_10, _S1362);
    return make_float3 (dot_0(v_8, _S1362), dot_0(v_8, n_10), dot_0(v_8, _S1363));
}

__device__ __forceinline__ float3  sampleHalfVector(float3  v_9, float3  n_i_10, float alpha_6, AnisotropicFrame frame_4, uint * random_state_7, uint first_2)
{
    Random _S1364 = draw(*random_state_7, first_2);
    Random _S1365 = draw(*random_state_7, first_2 | 2147483648U);
    *random_state_7 = _S1365.state;
    float _S1366 = frame_4.alphas.x;
    bool _S1367 = _S1366 > 0.0f;
    if(_S1367)
    {
        float3  _S1368 = anisotropicLocal(v_9, frame_4.tangent, n_i_10);
        float _S1369 = frame_4.alphas.y;
        float3  _S1370 = make_float3 (_S1366 * _S1368.x, _S1369 * _S1368.y, _S1368.z);
        float3  _S1371 = ((((_S1370)) * make_float3(rnorm3df(((_S1370)).x, ((_S1370)).y, ((_S1370)).z))));
        float3  _S1372 = sampleGGXVNDF(_S1371, 1.0f, _S1364.value, _S1365.value);
        float3  _S1373 = make_float3 (_S1366 * _S1372.x, _S1369 * _S1372.y, _S1372.z);
        float3  _S1374 = ((((_S1373)) * make_float3(rnorm3df(((_S1373)).x, ((_S1373)).y, ((_S1373)).z))));
        return make_float3 (_S1374.x) * frame_4.tangent + make_float3 (_S1374.y) * cross_0(n_i_10, frame_4.tangent) + make_float3 (_S1374.z) * n_i_10;
    }
    float3  _S1375 = worldToTangent(v_9, n_i_10);
    float3  _S1376 = sampleGGXVNDF(float3 {_S1375.x, _S1375.z, _S1375.y}, alpha_6, _S1364.value, _S1365.value);
    float3  _S1377 = float3 {_S1376.x, _S1376.z, _S1376.y};
    float3  _S1378 = tangentToWorld(_S1377, n_i_10);
    return _S1378;
}

__device__ __forceinline__ float3  coatHalf(float3  v_10, CoatFrame coat_frame_4, uint random_state_8)
{
    bool _S1379 = !((dot_0(coat_frame_4.normal, v_10)) > 0.0f);
    if(_S1379)
    {
        return make_float3 (0.0f);
    }
    uint state_2 = random_state_8;
    float3  _S1380 = sampleHalfVector(v_10, coat_frame_4.normal, coat_frame_4.alpha, AnisotropicFrame_x24init_0(make_float3 (0.0f), make_float2 (0.0f)), &state_2, 1U);
    return _S1380;
}

static __device__ Facets Facets_x24init_0(float3  h_3, float3  coat_h_3)
{
    Facets _S1381;
    (&_S1381)->h = h_3;
    (&_S1381)->coat_h = coat_h_3;
    return _S1381;
}

__device__ Facets drawFacets(float3  in_dir_6, float3  n_11, BSDFMaterial material_20, uint random_state_9)
{
    float3  _S1382 = negate_0(in_dir_6);
    float _S1383 = sign_0(dot_0(n_11, _S1382));
    float3  _S1384 = n_11 * make_float3 (_S1383);
    uint state_3 = random_state_9;
    float _S1385 = material_20.roughness;
    float _S1386 = _S1385 * _S1385;
    AnisotropicFrame _S1387 = anisotropicFrame(material_20, _S1384);
    float3  _S1388 = sampleHalfVector(_S1382, _S1384, _S1386, _S1387, &state_3, 0U);
    CoatFrame _S1389 = coatFrame(material_20, _S1384);
    float3  _S1390 = coatHalf(_S1382, _S1389, random_state_9);
    return Facets_x24init_0(_S1388, _S1390);
}

__device__ bool neeDecision(BSDFMaterial material_21, float n_dot_v_2, float eta_i_5, float eta_o_4)
{
    float _S1391 = fresnel((F32_abs((n_dot_v_2))), eta_i_5, eta_o_4);
    float3  _S1392 = mix_0(make_float3 (_S1391), material_21.albedo, material_21.metallic);
    float _S1393 = rgb_to_greyscale(_S1392);
    float _S1394 = (F32_max(((1.0f - _S1393) * (1.0f - material_21.metallic) * (1.0f - material_21.transmission)), (0.0f)));
    bool _S1395 = _S1394 > 0.03999999910593033f;
    bool _S1396;
    if(_S1395)
    {
        _S1396 = true;
    }
    else
    {
        _S1396 = (material_21.roughness) > 0.20000000298023224f;
    }
    return _S1396;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_22)
{
    float _S1397 = rgb_to_greyscale(material_22->translucent);
    return _S1397 > 0.0f;
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
    MediumSides _S1398;
    (&_S1398)->behind = *behind_1;
    (&_S1398)->front = *front_0;
    (&_S1398)->fillings = fillings_1;
    (&_S1398)->face = face_1;
    return _S1398;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_8, FKMedium * medium_0, uint filling_0, float3  dir_14, FKMedium * outside_0)
{
    float3  _S1399 = surface_8->geometry_n;
    MediumSides _S1400 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_8->geometry_n);
    MediumSides sides_0 = _S1400;
    bool _S1401 = surface_8->encloses;
    if(_S1401)
    {
        (&sides_0)->behind = surface_8->volume;
        *&((&(&sides_0)->fillings)->x) = surface_8->fills;
        bool _S1402 = (dot_0(dir_14, _S1399)) > 0.0f;
        if(_S1402)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_9, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_15, uint depth_3, uint lobe_3, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1403 = surface_9->geometry_n;
    ShadowContext _S1404 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_9->geometry_n, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
    bool _S1405 = surface_9->encloses;
    ShadowContext context_4;
    if(_S1405)
    {
        FKSurface faced_1 = *surface_9;
        float3  _S1406 = - _S1403;
        float3  _S1407 = _slang_select(turned_0, _S1406,_S1403);
        (&faced_1)->geometry_n = _S1407;
        FKMedium _S1408 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1409 = faced_1;
        FKMedium _S1410 = _S1408;
        MediumSides _S1411 = mediumSides_0(&_S1409, &_S1410, filling_1, dir_15, outside_1);
        ShadowContext _S1412 = ShadowContext_x24init_0(_S1411.behind.extinction, _S1411.front.extinction, _S1411.fillings, _S1403, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
        if(turned_0)
        {
            uint2  _S1413 = _S1411.fillings;
            ShadowContext _S1414 = ShadowContext_x24init_0(_S1411.front.extinction, _S1411.behind.extinction, uint2 {_S1413.y, _S1413.x}, _S1403, depth_3, lobe_3, true, length_3, width_2, own_3, fiber_1);
            context_4 = _S1414;
        }
        else
        {
            context_4 = _S1412;
        }
    }
    else
    {
        context_4 = _S1404;
    }
    return context_4;
}

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_7, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_3, BSDFMaterial * material_23, float eta_i_6, float eta_o_5, bool competing_1, Facets * facets_3)
{
    float3  _S1415 = light_2->dir;
    bool _S1416 = (dot_0(geometry_n_3, - in_dir_7) * dot_0(geometry_n_3, light_2->dir)) <= 0.0f;
    FixedArray<float3 , 6>  throughputs_1;
    FixedArray<float, 6>  pdfs_4;
    BSDF(in_dir_7, _S1415, smooth_n_5, *material_23, eta_i_6, eta_o_5, _S1416, *facets_3, &throughputs_1, &pdfs_4);
    bool _S1417;
    if(competing_1)
    {
        _S1417 = (light_2->density) != 0.0f;
    }
    else
    {
        _S1417 = false;
    }
    float3  _S1418 = make_float3 (0.0f);
    uint i_23 = 0U;
    float3  f_7 = _S1418;
    for(;;)
    {
        if(i_23 < 6U)
        {
        }
        else
        {
            break;
        }
        bool _S1419 = (pdfs_4[i_23]) > 0.0f;
        if(_S1419)
        {
            float3  f_8;
            if(_S1417)
            {
                float _S1420 = light_2->density;
                float _S1421 = pdfs_4[i_23] / light_2->density;
                float3  f_9 = f_7 + throughputs_1[i_23] * make_float3 (pdfs_4[i_23]) / make_float3 (_S1420 * (1.0f + _S1421 * _S1421));
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
    float3  _S1422 = f_7 * light_2->radiance;
    float3  _S1423 = _S1422 * make_float3 (light_2->density);
    float3  _S1424 = _slang_select(_S1417, _S1423,_S1422);
    return _S1424;
}

__device__ float3  skyBSDF(float3  in_dir_8, float3  dir_16, FKSurface surface_10, BSDFMaterial material_24, float2  eta_3, bool is_inside_4, Facets facets_4, float pdf_5)
{
    FKSurface _S1425 = surface_10;
    BSDFMaterial _S1426 = material_24;
    Facets _S1427 = facets_4;
    FixedArray<float3 , 6>  terms_3;
    FixedArray<float, 6>  pdfs_5;
    float3  _S1428 = skyLobes_0(in_dir_8, dir_16, &_S1425, &_S1426, eta_3, is_inside_4, &_S1427, pdf_5, &terms_3, &pdfs_5);
    return _S1428;
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_2, uint random_state_10, bool refracted_3, uint lobe_4, float pdf_6)
{
    SampleBSDF _S1429;
    (&_S1429)->unit_direction = unit_direction_1;
    (&_S1429)->throughput = throughput_2;
    (&_S1429)->random_state = random_state_10;
    (&_S1429)->refracted = refracted_3;
    (&_S1429)->lobe = lobe_4;
    (&_S1429)->pdf = pdf_6;
    return _S1429;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  v_11, float3  n_i_11, float n_i_dot_v_3, BSDFMaterial material_25, Weights w_14, uint random_state_11)
{
    Random _S1430 = draw(random_state_11, 3U);
    Random _S1431 = draw(random_state_11, 2147483651U);
    float _S1432 = _S1430.value;
    float _S1433 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1432 * _S1432))))));
    float _S1434 = 6.28318548202514648f * _S1431.value;
    float3  _S1435 = tangentToWorld(make_float3 (_S1433 * (F32_cos((_S1434))), _S1430.value, _S1433 * (F32_sin((_S1434)))), n_i_11);
    float3  _S1436 = sheenVelvetBSDF(_S1435, v_11, n_i_11, material_25, w_14);
    float _S1437 = sheenVelvetPDF(_S1430.value, n_i_dot_v_3, w_14);
    return SampleBSDF_x24init_0(_S1435, _S1436, _S1431.state, false, 4U, _S1437);
}

__device__ __forceinline__ SampleBSDF coatSample(float3  in_dir_9, float3  v_12, float3  coat_h_4, CoatFrame coat_frame_5, Weights w_15, uint random_state_12)
{
    float3  _S1438 = reflect_0(in_dir_9, coat_h_4);
    float3  _S1439 = ((((_S1438)) * make_float3(rnorm3df(((_S1438)).x, ((_S1438)).y, ((_S1438)).z))));
    float3  _S1440 = coatBSDF(w_15);
    float _S1441 = coatPDF(v_12, coat_h_4, coat_frame_5, w_15);
    return SampleBSDF_x24init_0(_S1439, _S1440, random_state_12, false, 5U, _S1441);
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1442 = (F32_sqrt((random_1_0)));
    float _S1443 = 6.28318548202514648f * random_2_0;
    float _S1444 = _S1442 * (F32_cos((_S1443)));
    float _S1445 = _S1442 * (F32_sin((_S1443)));
    float _S1446 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1444 * _S1444 - _S1445 * _S1445))))));
    return make_float3 (_S1444, _S1446, _S1445);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_3, float3  n_i_12, float n_i_dot_v_4, BSDFMaterial material_26, Weights w_16, uint random_state_13)
{
    Random _S1447 = draw(random_state_13, 3U);
    Random _S1448 = draw(random_state_13, 2147483651U);
    float3  _S1449 = sampleCosWeightedHemisphere(_S1447.value, _S1448.value);
    float _S1450 = translucentShare(material_26);
    bool _S1451 = u_3 < (w_16.p_diffuse * _S1450);
    float _S1452 = _S1449.y;
    float _S1453 = - _S1452;
    float _S1454 = _slang_select(_S1451, _S1453,_S1452);
    float3  _S1455 = tangentToWorld(make_float3 (_S1449.x, _S1454, _S1449.z), n_i_12);
    float3  _S1456 = diffuseBSDF(_S1455, n_i_12, material_26, w_16);
    float _S1457 = diffusePDF(_S1454, n_i_dot_v_4, material_26, w_16);
    return SampleBSDF_x24init_0(_S1455, _S1456, _S1448.state, _S1451, 0U, _S1457);
}

__device__ __forceinline__ SampleBSDF toonSample(float3  n_i_13, ToonProfile profile_3, Weights w_17, uint random_state_14)
{
    Random _S1458 = draw(random_state_14, 3U);
    Random _S1459 = draw(random_state_14, 2147483651U);
    float _S1460 = _S1458.value * profile_3.norm / 6.28318548202514648f;
    float _S1461 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1460)))), (1.0f))))));
    float _S1462 = (F32_acos((clamp_1(1.0f - _S1460, -1.0f, 1.0f))));
    float _S1463 = _slang_select(profile_3.glossy, _S1462,_S1461);
    float _S1464 = (profile_3.a + profile_3.b) / 2.0f;
    bool _S1465 = _S1463 < (profile_3.a);
    float _S1466 = _slang_select(_S1465, _S1463,_S1464);
    float t_23 = _S1466;
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
        float _S1467 = toonP(t_23, profile_3.a, profile_3.s);
        float _S1468 = _S1467 * (F32_sin((t_23)));
        float _S1469 = (F32_cos((t_23)));
        float _S1470 = _slang_select(profile_3.glossy, 1.0f,_S1469);
        float _S1471 = _S1468 * _S1470;
        float _S1472 = toonIntegral(t_23, profile_3.a, profile_3.s, profile_3.glossy);
        float _S1473 = (_S1472 - _S1460) / _S1471;
        bool _S1474 = _S1471 > 0.0f;
        float _S1475 = _slang_select(_S1474, _S1473,0.0f);
        float _S1476 = clamp_1(t_23 - _S1475, 0.0f, profile_3.b);
        int k_3 = k_2 + int(1);
        t_23 = _S1476;
        k_2 = k_3;
    }
    float _S1477 = 6.28318548202514648f * _S1459.value;
    float _S1478 = (F32_sin((t_23)));
    float3  _S1479 = tangentToWorld(make_float3 (_S1478 * (F32_cos((_S1477))), (F32_cos((t_23))), _S1478 * (F32_sin((_S1477)))), profile_3.axis);
    float3  _S1480 = toonBSDF(_S1479, n_i_13, profile_3, w_17);
    bool _S1481 = (dot_0(n_i_13, _S1479)) < 0.0f;
    float _S1482 = toonPDF(_S1479, n_i_13, profile_3, w_17);
    return SampleBSDF_x24init_0(_S1479, _S1480, _S1459.state, _S1481, 6U, _S1482);
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_1, float3  n_i_14, float alpha_7, AnisotropicFrame frame_5, BSDFMaterial material_27, Weights w_18, float pdf_h_3, float eta_i_7, float eta_o_6, uint random_state_15)
{
    float _S1483 = maskingG1(w_18.refracted, n_i_14, -1.0f, alpha_7, frame_5);
    float3  _S1484 = refractBSDF(_S1483, material_27, w_18);
    float _S1485 = refractPDF(dot_0(w_18.refracted, ggx_n_1), pdf_h_3, w_18, eta_i_7, eta_o_6);
    return SampleBSDF_x24init_0(w_18.refracted, _S1484, random_state_15, true, 1U, _S1485);
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_10, float3  ggx_n_2, float3  n_i_15, float alpha_8, AnisotropicFrame frame_6, Weights w_19, float pdf_h_4, uint random_state_16)
{
    float3  _S1486 = reflect_0(in_dir_10, ggx_n_2);
    float3  _S1487 = ((((_S1486)) * make_float3(rnorm3df(((_S1486)).x, ((_S1486)).y, ((_S1486)).z))));
    float _S1488 = maskingG1(_S1487, n_i_15, 1.0f, alpha_8, frame_6);
    float3  _S1489 = reflectBSDF(_S1488, w_19);
    float _S1490 = reflectPDF(pdf_h_4, w_19);
    return SampleBSDF_x24init_0(_S1487, _S1489, random_state_16, false, 2U, _S1490);
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_11, float3  n_12, BSDFMaterial material_28, float eta_i_8, float eta_o_7, Facets facets_5, uint random_init_0, float2  screen_space_0)
{
    float3  _S1491 = negate_0(in_dir_11);
    float _S1492 = dot_0(n_12, _S1491);
    float _S1493 = sign_0(_S1492);
    float3  n_i_16 = n_12 * make_float3 (_S1493);
    float _S1494 = (F32_abs((_S1492)));
    float _S1495 = material_28.roughness;
    float _S1496 = _S1495 * _S1495;
    AnisotropicFrame _S1497 = anisotropicFrame(material_28, n_i_16);
    SheenProfile _S1498 = sheenProfile(_S1491, n_i_16, material_28);
    CoatFrame _S1499 = coatFrame(material_28, n_i_16);
    float3  _S1500 = coatSeries(_S1499, material_28);
    Weights _S1501 = lobeWeights(in_dir_11, _S1491, n_i_16, facets_5.h, facets_5.coat_h, facets_5.h, facets_5.coat_h, _S1497, _S1498, _S1499, _S1500, material_28, eta_i_8, eta_o_7);
    Random _S1502 = draw(random_init_0, 2U);
    bool _S1503 = (_S1502.value) < (_S1501.p_sheen_velvet);
    if(_S1503)
    {
        SampleBSDF _S1504 = sheenVelvetSample(_S1491, n_i_16, _S1494, material_28, _S1501, _S1502.state);
        return _S1504;
    }
    float _S1505 = _S1502.value - _S1501.p_sheen_velvet;
    bool _S1506 = _S1505 < (_S1501.p_coat);
    if(_S1506)
    {
        SampleBSDF _S1507 = coatSample(in_dir_11, _S1491, facets_5.coat_h, _S1499, _S1501, _S1502.state);
        return _S1507;
    }
    float _S1508 = _S1505 - _S1501.p_coat;
    bool _S1509 = _S1508 < (_S1501.p_diffuse);
    if(_S1509)
    {
        SampleBSDF _S1510 = diffuseSample(_S1508, n_i_16, _S1494, material_28, _S1501, _S1502.state);
        return _S1510;
    }
    bool _S1511 = _S1508 < (_S1501.p_diffuse + _S1501.p_toon);
    if(_S1511)
    {
        ToonProfile _S1512 = toonProfile(_S1491, n_i_16, material_28);
        SampleBSDF _S1513 = toonSample(n_i_16, _S1512, _S1501, _S1502.state);
        return _S1513;
    }
    float _S1514 = vndfPDF(_S1491, facets_5.h, n_i_16, _S1494, _S1496, _S1497, _S1501.v_dot_h);
    bool _S1515 = (_S1508 - _S1501.p_toon) < (_S1501.p_diffuse + _S1501.p_refract);
    if(_S1515)
    {
        SampleBSDF _S1516 = refractSample(facets_5.h, n_i_16, _S1496, _S1497, material_28, _S1501, _S1514, eta_i_8, eta_o_7, _S1502.state);
        return _S1516;
    }
    SampleBSDF _S1517 = reflectSample(in_dir_11, facets_5.h, n_i_16, _S1496, _S1497, _S1501, _S1514, _S1502.state);
    return _S1517;
}

__device__ __forceinline__ float3  refractedHalf(float3  in_dir_12, float3  out_dir_2, float3  n_13, float eta_i_9, float eta_o_8)
{
    float3  _S1518 = negate_0(in_dir_12);
    float3  _S1519 = negate_0(make_float3 (eta_i_9) * _S1518 + make_float3 (eta_o_8) * out_dir_2);
    float3  _S1520 = ((((_S1519)) * make_float3(rnorm3df(((_S1519)).x, ((_S1519)).y, ((_S1519)).z))));
    float _S1521 = sign_0(dot_0(n_13, _S1518));
    float _S1522 = sign_0(dot_0(_S1519, n_13 * make_float3 (_S1521)));
    return _S1520 * make_float3 (_S1522);
}

static __device__ bool boundsVolume_0(FKSurface * surface_11)
{
    return surface_11->encloses;
}

static __device__ Shift walk_0(Domain * dom_8, Reservoir * r_9, bool replay_2, float scale_4, Selection * sel_8)
{
    bool turned_1;
    bool is_inside_5;
    bool viewed_0;
    bool _S1523;
    bool _S1524;
    bool _S1525;
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
    int _S1526;
    Shift ended_0;
    float density_4;
    float spread_2;
    float width_4;
    float sky_pdf_2;
    uint b_8;
    float spread_3;
    float width_5;
    float3  _S1527 = make_float3 (0.0f);
    Shift _S1528 = Shift_x24init_0(_S1527, 0.0f);
    uint _S1529 = r_9->path;
    uint _S1530 = extractBits_0(r_9->path, 0U, 5U);
    uint _S1531 = extractBits_0(_S1529, 5U, 5U);
    uint _S1532 = extractBits_0(_S1529, 10U, 2U);
    uint _S1533 = extractBits_0(_S1529, 12U, 3U);
    bool passes_0;
    if(replay_2)
    {
        bool _S1534 = _S1533 >= 3U;
        uint _S1535 = _slang_select(_S1534, 1U,0U);
        uint _S1536 = _S1530 + _S1535;
        uint _S1537 = (fcptMaxBounces());
        passes_0 = _S1536 > _S1537;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1528;
    }
    uint _S1538 = _S1531 - 1U;
    bool _S1539 = _S1533 == 3U;
    uint _S1540 = _slang_select(_S1539, 1U,0U);
    uint _S1541 = _S1530 + _S1540;
    bool _S1542 = _S1532 == 0U;
    uint _S1543 = _slang_select(_S1542, _S1541,_S1538);
    FKHit _S1544 = (fcptReservoirHit((*r_9)));
    float3  _S1545 = dom_8->x0;
    float3  _S1546 = dom_8->x1 - dom_8->x0;
    float3  _S1547 = ((((_S1546)) * make_float3(rnorm3df(((_S1546)).x, ((_S1546)).y, ((_S1546)).z))));
    FKRay _S1548 = Ray_x24init_0(dom_8->x1, _S1547);
    FKRay ray_3 = _S1548;
    FKHit hit_4 = dom_8->hit;
    float3  scatter_in_0 = _S1527;
    float3  throughput_4 = make_float3 (1.0f);
    float3  weight_2 = throughput_4;
    float3  glowed_0 = _S1527;
    float3  extinction_in_0 = _S1527;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1549 = dom_8->spread;
    float _S1550 = dom_8->width;
    float _S1551 = length_0(_S1546);
    NEEVertex _S1552 = NEEVertex_x24init_0(true, 0.0f, _S1527, _S1527, _S1527);
    NEEVertex nee_vertex_1 = _S1552;
    Vertex _S1553 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_1 = _S1553;
    Reservoir _S1554 = (Reservoir{});
    Reservoir chain_1 = _S1554;
    uint _S1555 = r_9->seed;
    (&chain_1)->seed = r_9->seed;
    uint _S1556 = extractBits_0(_S1529, 24U, 8U);
    uint _S1557 = insertBits_0(0U, _S1556, 24U, 8U);
    (&chain_1)->path = _S1557;
    (&ray_3)->origin = _S1545;
    (&hit_4)->distance = _S1551;
    FKMedium _S1558 = (fcptCameraMedium(((&ray_3)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1559 = filling_2;
    bool _S1560 = (fcptVaryingUsed());
    uint _S1561 = _slang_select(_S1560, _S1559,4294967295U);
    filling_2 = _S1561;
    scatter_in_0 = _S1558.scatter;
    extinction_in_0 = _S1558.extinction;
    g_in_0 = _S1558.g;
    Reservoir _S1562 = chain_1;
    uint _S1563 = filling_2;
    for(;;)
    {
        bool _S1564 = (fcptVaryingUsed());
        if(_S1564)
        {
            passes_0 = _S1563 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1565 = (fcptMajorant((_S1563)));
            turned_1 = _S1565 > 0.0f;
        }
        else
        {
            turned_1 = any_1(scatter_in_0 > make_float3 (0.0f));
        }
        if(replay_2)
        {
            is_inside_5 = 4294967295U == _S1543;
        }
        else
        {
            is_inside_5 = false;
        }
        if(is_inside_5)
        {
            is_inside_5 = _S1532 == 1U;
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
            ended_0 = _S1528;
            sky_pdf_1 = 0.0f;
            spread_1 = _S1549;
            width_3 = _S1550;
            density_3 = 1.0f;
            throughput_3 = throughput_4;
            b_7 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1566 = (&prev_1)->rough;
        if(_S1566)
        {
            is_inside_5 = !turned_1;
        }
        else
        {
            is_inside_5 = false;
        }
        (&prev_1)->rough = is_inside_5;
        uint _S1567 = stream(_S1555, 384U);
        uint tracking_0 = _S1567;
        weight_2 = throughput_4;
        glowed_0 = _S1527;
        b_7 = 4294967295U;
        throughput_3 = throughput_4;
        density_3 = 1.0f;
        spread_1 = _S1549;
        width_3 = _S1550;
        sky_pdf_1 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1526 = int(1);
                break;
            }
            float _S1568 = (&hit_4)->distance;
            if(passes_0)
            {
                float3  _S1569 = (&ray_3)->origin;
                float3  _S1570 = (&ray_3)->unit_direction;
                float _S1571 = (&hit_4)->distance;
                bool _S1572 = b_7 == 4294967295U;
                uint _S1573 = _slang_select(_S1572, 0U,b_7);
                uint _S1574 = (&prev_1)->lobe;
                uint _S1575 = _slang_select(_S1572, 3U,_S1574);
                float _S1576 = (fcptTrackMedium((_S1563), (_S1569), (_S1570), (_S1571), (&tracking_0), (&weight_2), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1573), (_S1575), (_S1572)));
                wavelength_9 = _S1576;
            }
            else
            {
                if(turned_1)
                {
                    uint _S1577 = noiseAddress(_S1555, b_7);
                    Random _S1578 = draw(_S1577, 10U);
                    float _S1579 = 3.0f * _S1578.value;
                    uint _S1580 = (U32_min((uint(_S1579)), (2U)));
                    float _S1581 = - (F32_log((1.0f - (_S1579 - float(_S1580))))) / *_slang_vector_get_element_ptr(&scatter_in_0, _S1580);
                    wavelength_9 = _S1581;
                }
                else
                {
                    wavelength_9 = _S1568;
                }
            }
            bool _S1582 = !(wavelength_9 < ((&hit_4)->distance));
            if(_S1582)
            {
                _S1526 = int(1);
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
                float3  _S1583 = pathColor(throughput_3 * glowed_0, throughput_4, 0.0f);
                float3  _S1584 = _S1583 / make_float3 (density_3);
                float3  _S1585 = sel_8->glow + _S1584;
                sel_8->glow = _S1585;
            }
            else
            {
            }
            glowed_0 = _S1527;
            uint b_9 = b_7 + 1U;
            float3  _S1586 = (&ray_3)->origin + make_float3 (wavelength_9) * (&ray_3)->unit_direction;
            (&ray_3)->origin = _S1586;
            float3  _S1587 = flightWeight_0(scatter_in_0, extinction_in_0, wavelength_9, true);
            float3  _S1588 = weight_2;
            float _S1589 = upsample(weight_2, 0.0f);
            float3  _S1590 = make_float3 (_S1589);
            float3  _S1591 = _slang_select(false, _S1590,_S1588);
            float3  _S1592 = _slang_select(passes_0, _S1591,_S1587);
            float3  throughput_5 = throughput_3 * _S1592;
            uint _S1593 = stream(_S1555, b_9 + 320U);
            tracking_0 = _S1593;
            weight_2 = throughput_4;
            float width_6 = width_3 + spread_1 * wavelength_9;
            float _S1594 = spread_1 + 3.14159274101257324f;
            bool _S1595 = !replay_2;
            if(_S1595)
            {
                viewed_0 = true;
            }
            else
            {
                bool _S1596 = b_9 == _S1543;
                if(_S1596)
                {
                    viewed_0 = !passes_0;
                }
                else
                {
                    viewed_0 = false;
                }
            }
            TreeSample _S1597 = TreeSample_x24init_0(_S1527, _S1527, 0.0f, 0U);
            if(viewed_0)
            {
                float3  _S1598 = (&ray_3)->origin;
                float3  _S1599 = (&ray_3)->unit_direction;
                float3  _S1600 = (&ray_3)->unit_direction;
                uint _S1601 = noiseAddress(_S1555, b_9);
                float3  _S1602 = extinction_in_0;
                float3  _S1603 = extinction_in_0;
                uint2  _S1604 = make_uint2 (_S1563);
                float3  _S1605 = (&ray_3)->unit_direction;
                uint _S1606 = arrivalLobe_0(b_9, (&prev_1)->lobe);
                FKHit _S1607 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1608 = _S1607;
                ShadowContext _S1609 = ShadowContext_x24init_0(_S1602, _S1603, _S1604, _S1605, b_9, _S1606, false, wavelength_9, width_6, &_S1608, false);
                ShadowContext _S1610 = _S1609;
                TreeSample _S1611 = sampleLightTree_0(_S1598, _S1599, _S1600, 0.0f, true, _S1601, &_S1610);
                light_3 = _S1611;
            }
            else
            {
                light_3 = _S1597;
            }
            float _S1612 = phaseHG_0(g_in_0, dot_0((&ray_3)->unit_direction, light_3.dir));
            uint _S1613 = (fcptMaxBounces());
            bool _S1614 = b_9 < _S1613;
            if(_S1614)
            {
                _S1523 = (light_3.density) > 0.0f;
            }
            else
            {
                _S1523 = false;
            }
            float _S1615 = _slang_select(_S1523, _S1612,0.0f);
            float3  _S1616 = throughput_5 * light_3.radiance;
            float _S1617 = powerHeuristic(light_3.density, _S1615);
            float3  _S1618 = pathColor(_S1616 * make_float3 (_S1612 * _S1617), throughput_4, 0.0f);
            float3  _S1619 = _slang_select(viewed_0, _S1618,_S1527);
            if(replay_2)
            {
                _S1524 = b_9 == _S1543;
            }
            else
            {
                _S1524 = false;
            }
            if(_S1524)
            {
                bool _S1620 = _S1532 == 2U;
                if(_S1620)
                {
                    float _S1621 = resamplingTarget(_S1619);
                    passes_0 = _S1621 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1622 = Shift_x24init_0(_S1619, 1.0f);
                    _S1526 = int(0);
                    ended_0 = _S1622;
                    wavelength_9 = _S1594;
                    threshold_0 = width_6;
                    spectral_weight_1 = throughput_5;
                    layer_0 = b_9;
                    break;
                }
                _S1526 = int(0);
                ended_0 = _S1528;
                wavelength_9 = _S1594;
                threshold_0 = width_6;
                spectral_weight_1 = throughput_5;
                layer_0 = b_9;
                break;
            }
            if(_S1595)
            {
                Reservoir candidate_4 = _S1562;
                uint _S1623 = extractBits_0(_S1562.path, 24U, 8U);
                uint _S1624 = insertBits_0(0U, _S1623, 24U, 8U);
                uint _S1625 = extractBits_0(_S1562.path, 10U, 2U);
                bool _S1626 = _S1625 == 1U;
                if(_S1626)
                {
                    float3  _S1627 = safeDivide(_S1619, _S1527);
                    (&candidate_4)->radiance = _S1627;
                }
                else
                {
                    uint _S1628 = insertBits_0(_S1624, b_9 + 1U, 5U, 5U);
                    uint _S1629 = insertBits_0(_S1628, 2U, 10U, 2U);
                    (&candidate_4)->path = _S1629;
                }
                Reservoir _S1630 = withEnd(candidate_4, 0U, b_9, _S1619);
                offer(sel_8, _S1630, _S1619 * make_float3 (scale_4) / make_float3 (density_3));
                float _S1631 = survivalProbability(abs_0(throughput_5), density_3);
                uint _S1632 = (fcptMaxBounces());
                bool _S1633 = b_9 >= _S1632;
                if(_S1633)
                {
                    _S1525 = true;
                }
                else
                {
                    bool _S1634 = _S1631 < 1.0f;
                    if(_S1634)
                    {
                        uint _S1635 = noiseAddress(_S1555, b_9);
                        Random _S1636 = draw(_S1635, 8U);
                        _S1525 = _S1631 < (_S1636.value);
                    }
                    else
                    {
                        _S1525 = false;
                    }
                }
                if(_S1525)
                {
                    _S1526 = int(0);
                    ended_0 = _S1528;
                    wavelength_9 = _S1594;
                    threshold_0 = width_6;
                    spectral_weight_1 = throughput_5;
                    layer_0 = b_9;
                    break;
                }
                float _S1637 = density_3 * _S1631;
                density_3 = _S1637;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1638 = noiseAddress(_S1555, b_9);
            float3  _S1639 = samplePhase_0(g_in_0, (&ray_3)->unit_direction, _S1638, &phase_pdf_0);
            (&ray_3)->unit_direction = _S1639;
            NEEVertex _S1640 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_3)->origin, _S1527, (&ray_3)->origin);
            nee_vertex_1 = _S1640;
            Vertex _S1641 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, false);
            prev_1 = _S1641;
            float _S1642 = (&prev_1)->pdf;
            FKRay _S1643 = ray_3;
            FKHit _S1644 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1645 = (fcptTraverseInstanceBVH((_S1643), (true), (4.294967296e+09f), (false), (_S1644), (false)));
            hit_4 = _S1645;
            b_7 = b_9;
            throughput_3 = throughput_5;
            spread_1 = _S1594;
            width_3 = width_6;
            sky_pdf_1 = _S1642;
        }
        if(_S1526 != int(1))
        {
            spread_1 = wavelength_9;
            width_3 = threshold_0;
            throughput_3 = spectral_weight_1;
            b_7 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1528;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1646 = b_7 == 4294967295U;
    bool _S1647 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1647)
    {
        Reservoir _S1648 = chain_1;
        FKRay _S1649 = ray_3;
        Vertex _S1650 = prev_1;
        NEEVertex _S1651 = nee_vertex_1;
        Shift _S1652 = escape_0(r_9, replay_2, _S1543, _S1532, _S1530, _S1533, scale_4, _S1557, &_S1648, _S1527, b_7, &_S1649, throughput_3, density_3, &_S1650, &_S1651, sky_pdf_1, throughput_4, 0.0f, sel_8);
        return _S1652;
    }
    FKHit _S1653 = hit_4;
    uint _S1654 = filling_2;
    float3  _S1655 = scatter_in_0;
    float3  _S1656 = extinction_in_0;
    float3  _S1657 = weight_2;
    float3  _S1658 = glowed_0;
    float3  _S1659 = (&ray_3)->origin + make_float3 (_S1653.distance) * (&ray_3)->unit_direction;
    (&ray_3)->origin = _S1659;
    bool _S1660 = (fcptVaryingUsed());
    if(_S1660)
    {
        passes_0 = _S1654 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1661 = !replay_2;
        if(_S1661)
        {
            float3  _S1662 = pathColor(throughput_3 * _S1658, throughput_4, 0.0f);
            float3  _S1663 = _S1662 / make_float3 (density_3);
            float3  _S1664 = sel_8->glow + _S1663;
            sel_8->glow = _S1664;
        }
        else
        {
        }
        float3  _S1665 = throughput_3 * _S1657;
        throughput_3 = _S1665;
    }
    else
    {
        float3  _S1666 = flightWeight_0(_S1655, _S1656, _S1653.distance, false);
        float3  _S1667 = throughput_3 * _S1666;
        throughput_3 = _S1667;
    }
    float width_7 = width_3 + spread_1 * _S1653.distance;
    uint _S1668 = b_7 + 1U;
    b_7 = _S1668;
    layer_0 = 0U;
    width_3 = width_7;
    passes_0 = false;
    wavelength_9 = 0.0f;
    threshold_0 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    spectral_weight_1 = throughput_4;
    float3  chain_throughput_1 = _S1527;
    float3  reconnection_0 = _S1527;
    viewed_0 = _S1646;
    for(;;)
    {
        bool _S1669 = ((&hit_4)->is_point_light) == 1U;
        if(replay_2)
        {
            _S1523 = _S1532 == 1U;
        }
        else
        {
            _S1523 = false;
        }
        if(_S1523)
        {
            _S1524 = b_7 == _S1531;
        }
        else
        {
            _S1524 = false;
        }
        if(_S1524)
        {
            bool _S1670 = ((&hit_4)->instance_index) != (_S1544.instance_index);
            if(_S1670)
            {
                _S1525 = true;
            }
            else
            {
                _S1525 = ((&hit_4)->triangle_index) != (_S1544.triangle_index);
            }
        }
        else
        {
            _S1525 = false;
        }
        if(_S1525)
        {
            return _S1528;
        }
        FKMedium _S1671 = Medium_x24init_0(_S1527, _S1527, 0.0f);
        BSDFMaterial _S1672 = Material_x24init_0(_S1527, _S1527, 0.0f, 0.0f, 0.0f, 0.0f, _S1527, throughput_4, 1.0f, _S1527, _S1527, 0.5f, 0.0f, 0.0f, _S1527, 0.0f, _S1527, 0.0f, 0.0f, 0.02999999932944775f, 1.5f, throughput_4, _S1527);
        FKMedium _S1673 = _S1671;
        FKSurface _S1674 = Surface_x24init_0(_S1527, _S1527, 0.0f, &_S1672, false, 0U, 1.0f, false, &_S1673, 4294967295U, _S1527);
        bool _S1675 = !_S1669;
        bool scatter_2;
        bool is_inside_6;
        float3  throughput_6;
        float3  front_n_0;
        float geometry_density_0;
        FKSurface surface_12;
        if(_S1675)
        {
            uint _S1676 = noiseAddress(_S1555, b_7);
            uint _S1677 = arrivalLobe_0(b_7, (&prev_1)->lobe);
            FKSurface _S1678 = (fcptSurfaceAtPath((hit_4), ((&ray_3)->origin), (_S1676), (width_3), (layer_0), (b_7), (_S1677), ((&ray_3)->unit_direction)));
            bool _S1679 = !passes_0;
            FKSurface _S1680 = _S1678;
            FKSurface _S1681 = emitting_0(&_S1680, _S1679);
            uint _S1682 = noiseAddress(_S1555, b_7);
            Random _S1683 = draw(_S1682, 9U);
            FKSurface _S1684 = _S1681;
            FKSurface _S1685 = uncovered_0(&_S1684, _S1683.value);
            float _S1686 = facingSign(_S1685.material.transmission, _S1685.geometry_n, (&ray_3)->unit_direction);
            bool _S1687 = _S1686 < 0.0f;
            bool _S1688 = (_S1685.material.transmission) > 0.0f;
            if(_S1688)
            {
                bool _S1689 = arrivesBehind_0((&ray_3)->unit_direction, _S1685.geometry_n);
                scatter_2 = _S1689;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1690 = _S1685;
            FKSurface _S1691 = facingRay_0(&_S1690, (&ray_3)->unit_direction);
            if(passes_0)
            {
                bool _S1692 = arrivesBehind_0((&ray_3)->unit_direction, _S1691.geometry_n);
                is_inside_6 = _S1692;
            }
            else
            {
                is_inside_6 = scatter_2;
            }
            if(is_inside_6)
            {
                float _S1693 = (&hit_4)->distance;
                float _S1694 = upsample(_S1691.material.absorption, wavelength_9);
                float3  _S1695 = make_float3 (_S1694);
                bool _S1696 = wavelength_9 > 0.0f;
                float3  _S1697 = _slang_select(_S1696, _S1695,_S1691.material.absorption);
                float3  _S1698 = beerLambert(_S1693, _S1697);
                float3  _S1699 = throughput_3 * _S1698;
                throughput_6 = _S1699;
            }
            else
            {
                throughput_6 = throughput_3;
            }
            bool _S1700 = !_S1691.skip;
            float geometry_density_1 = (F32_abs((dot_0(_S1691.geometry_n, (&ray_3)->unit_direction)))) / ((&hit_4)->distance * (&hit_4)->distance);
            bool _S1701 = b_7 == _S1668;
            if(_S1701)
            {
                float _S1702 = 0.00251327408477664f / geometry_density_1;
                geometry_density_0 = _S1702;
            }
            else
            {
                geometry_density_0 = threshold_0;
            }
            float _S1703 = geometry_density_0;
            scatter_2 = _S1700;
            geometry_density_0 = geometry_density_1;
            threshold_0 = _S1703;
            surface_12 = _S1691;
            front_n_0 = _S1685.smooth_n;
            turned_1 = _S1687;
        }
        else
        {
            scatter_2 = false;
            geometry_density_0 = 0.0f;
            surface_12 = _S1674;
            throughput_6 = throughput_3;
            front_n_0 = _S1527;
            is_inside_6 = is_inside_5;
        }
        bool _S1704;
        if(scatter_2)
        {
            _S1704 = (&prev_1)->rough;
        }
        else
        {
            _S1704 = false;
        }
        bool _S1705;
        if(_S1704)
        {
            _S1705 = ((&prev_1)->pdf * geometry_density_0 * threshold_0) <= 1.0f;
        }
        else
        {
            _S1705 = false;
        }
        FKSurface _S1706 = surface_12;
        float _S1707 = dot_0(surface_12.smooth_n, - (&ray_3)->unit_direction);
        bool _S1708 = (fcptDispersionUsed());
        bool _S1709;
        if(_S1708)
        {
            _S1709 = wavelength_9 == 0.0f;
        }
        else
        {
            _S1709 = false;
        }
        bool _S1710;
        if(_S1709)
        {
            _S1710 = scatter_2;
        }
        else
        {
            _S1710 = false;
        }
        bool _S1711;
        if(_S1710)
        {
            bool _S1712 = dispersive(surface_12.material);
            _S1711 = _S1712;
        }
        else
        {
            _S1711 = false;
        }
        float3  throughput_7;
        if(_S1711)
        {
            uint _S1713 = stream(_S1555, 512U);
            Random _S1714 = pcg(_S1713);
            uint _S1715 = extractBits_0(_S1529, 25U, 7U);
            float _S1716 = (float(_S1715) + _S1714.value) / 128.0f;
            uint _S1717 = extractBits_0(_S1529, 24U, 1U);
            bool _S1718 = _S1717 == 1U;
            float _S1719 = _slang_select(_S1718, _S1716,_S1714.value);
            float2  _S1720 = sampleWavelength(_S1719);
            float wavelength_10 = _S1720.x;
            float3  _S1721 = wavelengthWeights(wavelength_10);
            float3  _S1722 = _S1721 / make_float3 (_S1720.y);
            float _S1723 = upsample(throughput_6, wavelength_10);
            float3  _S1724 = make_float3 (_S1723);
            float _S1725 = upsample(scatter_in_0, wavelength_10);
            float3  _S1726 = make_float3 (_S1725);
            scatter_in_0 = _S1726;
            float _S1727 = upsample(extinction_in_0, wavelength_10);
            float3  _S1728 = make_float3 (_S1727);
            extinction_in_0 = _S1728;
            wavelength_9 = wavelength_10;
            throughput_7 = _S1724;
            spectral_weight_1 = _S1722;
        }
        else
        {
            throughput_7 = throughput_6;
        }
        BSDFMaterial _S1729 = pathMaterial(surface_12.material, wavelength_9);
        float2  _S1730 = wavelengthEta(_S1729, _S1707, wavelength_9);
        FKSurface _S1731 = surface_12;
        Facets _S1732 = drawFacets((&ray_3)->unit_direction, _S1706.smooth_n, _S1729, surface_12.random_state);
        bool _S1733;
        if(scatter_2)
        {
            uint _S1734 = (fcptMaxBounces());
            bool _S1735 = b_7 >= _S1734;
            if(_S1735)
            {
                _S1733 = true;
            }
            else
            {
                bool _S1736 = neeDecision(_S1729, _S1707, _S1730.x, _S1730.y);
                _S1733 = _S1736;
            }
        }
        else
        {
            _S1733 = false;
        }
        bool _S1737;
        if(passes_0)
        {
            _S1737 = true;
        }
        else
        {
            _S1737 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1737)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1733;
        }
        bool _S1738 = (fcptHairUsed());
        bool _S1739;
        if(_S1738)
        {
            float3  _S1740 = surface_12.hair;
            _S1739 = (dot_0(_S1740, _S1740)) > 0.0f;
        }
        else
        {
            _S1739 = false;
        }
        bool _S1741;
        if(_S1739)
        {
            _S1741 = true;
        }
        else
        {
            BSDFMaterial _S1742 = _S1729;
            bool _S1743 = isTranslucent_0(&_S1742);
            _S1741 = _S1743;
        }
        bool _S1744;
        if(_S1741)
        {
            _S1744 = true;
        }
        else
        {
            bool _S1745 = (_S1729.transmission) > 0.0f;
            if(_S1745)
            {
                uint _S1746 = (fcptLayers((hit_4)));
                _S1744 = _S1746 == 1U;
            }
            else
            {
                _S1744 = false;
            }
        }
        float3  _S1747 = emitted_0(_S1729.emissive, (&ray_3)->unit_direction, front_n_0);
        float3  emission_0;
        if(_S1669)
        {
            float3  _S1748 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1748;
        }
        else
        {
            emission_0 = _S1747;
        }
        bool _S1749 = !replay_2;
        bool _S1750;
        if(_S1749)
        {
            _S1750 = true;
        }
        else
        {
            _S1750 = b_7 >= _S1543;
        }
        bool _S1751;
        if(_S1750)
        {
            float _S1752 = rgb_to_greyscale(emission_0);
            _S1751 = _S1752 > 0.0f;
        }
        else
        {
            _S1751 = false;
        }
        float3  emission_1;
        if(_S1751)
        {
            NEEVertex _S1753 = nee_vertex_1;
            FKHit _S1754 = hit_4;
            float _S1755 = emissionWeight_0(&_S1753, &_S1754, (&ray_3)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1755);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1756;
        if(replay_2)
        {
            _S1756 = _S1532 == 1U;
        }
        else
        {
            _S1756 = false;
        }
        bool _S1757;
        if(_S1756)
        {
            _S1757 = b_7 > _S1531;
        }
        else
        {
            _S1757 = false;
        }
        bool _S1758;
        if(_S1757)
        {
            _S1758 = b_7 == _S1530;
        }
        else
        {
            _S1758 = false;
        }
        bool _S1759;
        if(_S1758)
        {
            bool _S1760 = _S1533 == 1U;
            if(_S1760)
            {
                _S1759 = true;
            }
            else
            {
                _S1759 = _S1533 == 2U;
            }
        }
        else
        {
            _S1759 = false;
        }
        if(_S1759)
        {
            bool _S1761 = _S1669 != (_S1533 == 2U);
            if(_S1761)
            {
                return _S1528;
            }
            float3  _S1762 = pathColor(throughput_7 * emission_1, spectral_weight_1, wavelength_9);
            return Shift_x24init_0(_S1762 / make_float3 (r_9->jac), density_3 / r_9->jac);
        }
        uint _S1763 = extractBits_0((&chain_1)->path, 10U, 2U);
        bool _S1764 = _S1763 == 1U;
        Reservoir here_0 = chain_1;
        uint _S1765 = insertBits_0(_S1557, b_7, 5U, 5U);
        uint _S1766 = insertBits_0(_S1765, 1U, 10U, 2U);
        uint _S1767 = insertBits_0(_S1766, (&prev_1)->lobe, 15U, 3U);
        bool _S1768 = (&prev_1)->inside;
        uint _S1769 = _slang_select(_S1768, 1U,0U);
        uint _S1770 = insertBits_0(_S1767, _S1769, 22U, 1U);
        (&here_0)->path = _S1770;
        uint _S1771 = (&here_0)->path;
        bool _S1772 = wavelength_9 > 0.0f;
        uint _S1773 = _slang_select(_S1772, 1U,0U);
        uint _S1774 = insertBits_0(_S1771, _S1773, 23U, 1U);
        (&here_0)->path = _S1774;
        float _S1775 = (&prev_1)->pdf * geometry_density_0;
        (&here_0)->jac = _S1775;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1776;
        if(replay_2)
        {
            _S1776 = _S1532 == 1U;
        }
        else
        {
            _S1776 = false;
        }
        bool _S1777;
        if(_S1776)
        {
            _S1777 = b_7 == _S1531;
        }
        else
        {
            _S1777 = false;
        }
        bool _S1778 = b_7 == _S1543;
        bool _S1779;
        if(_S1778)
        {
            bool _S1780 = !scatter_2;
            if(_S1780)
            {
                _S1779 = true;
            }
            else
            {
                bool _S1781 = _S1532 != 1U;
                if(_S1781)
                {
                    _S1779 = _S1532 != 3U;
                }
                else
                {
                    _S1779 = false;
                }
            }
        }
        else
        {
            _S1779 = false;
        }
        bool _S1782;
        if(_S1779)
        {
            _S1782 = _S1532 == 2U;
        }
        else
        {
            _S1782 = false;
        }
        bool _S1783;
        if(_S1782)
        {
            _S1783 = !_S1705;
        }
        else
        {
            _S1783 = false;
        }
        bool _S1784;
        if(_S1783)
        {
            _S1784 = _S1533 != 4U;
        }
        else
        {
            _S1784 = false;
        }
        bool _S1785 = _S1531 == _S1530;
        bool _S1786;
        if(_S1785)
        {
            _S1786 = _S1533 == 0U;
        }
        else
        {
            _S1786 = false;
        }
        bool _S1787;
        if(_S1786)
        {
            _S1787 = ((&hit_4)->instance_index) == (_S1544.instance_index);
        }
        else
        {
            _S1787 = false;
        }
        bool _S1788;
        if(_S1787)
        {
            _S1788 = ((&hit_4)->triangle_index) == (_S1544.triangle_index);
        }
        else
        {
            _S1788 = false;
        }
        bool _S1789;
        if(_S1788)
        {
            _S1789 = _S1705;
        }
        else
        {
            _S1789 = false;
        }
        bool _S1790 = _slang_select(_S1777, _S1789,_S1784);
        bool _S1791;
        if(nee_0)
        {
            _S1791 = _slang_select(replay_2, _S1790,scatter_2);
        }
        else
        {
            _S1791 = false;
        }
        TreeSample _S1792 = TreeSample_x24init_0(_S1527, _S1527, 0.0f, 0U);
        uint2  _S1793 = make_uint2 (0U);
        float2  _S1794 = make_float2 (0.0f);
        FKHit _S1795 = Hit_x24init_0(_S1794, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1796 = _S1795;
        ShadowContext _S1797 = ShadowContext_x24init_0(_S1527, _S1527, _S1793, _S1527, 0U, 0U, false, 0.0f, 0.0f, &_S1796, false);
        bool _S1798;
        if(nee_0)
        {
            _S1798 = _S1750;
        }
        else
        {
            _S1798 = false;
        }
        ShadowContext context_5;
        if(_S1798)
        {
            uint _S1799 = arrivalLobe_0(b_7, (&prev_1)->lobe);
            FKMedium _S1800 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1801 = surface_12;
            FKHit _S1802 = hit_4;
            FKMedium _S1803 = _S1800;
            ShadowContext _S1804 = shadowContext_0(&_S1801, turned_1, extinction_in_0, filling_2, (&ray_3)->unit_direction, b_7, _S1799, (&hit_4)->distance, width_3, &_S1802, _S1739, &_S1803);
            context_5 = _S1804;
        }
        else
        {
            context_5 = _S1797;
        }
        float3  throughput_8;
        float3  lit_0;
        if(_S1791)
        {
            float3  _S1805 = (&ray_3)->origin;
            if(_S1739)
            {
                throughput_8 = _S1527;
            }
            else
            {
                throughput_8 = _S1706.smooth_n;
            }
            FKSurface _S1806 = surface_12;
            uint _S1807 = noiseAddress(_S1555, b_7);
            ShadowContext _S1808 = context_5;
            TreeSample _S1809 = sampleLightTree_0(_S1805, throughput_8, surface_12.geometry_n, surface_12.geometry_offset, _S1744, _S1807, &_S1808);
            bool _S1810 = any_1((_S1809.radiance) != _S1527);
            if(_S1810)
            {
                if(_S1739)
                {
                    uint _S1811 = (fcptMaxBounces());
                    bool _S1812 = b_7 < _S1811;
                    FKSurface _S1813 = surface_12;
                    TreeSample _S1814 = _S1809;
                    float3  _S1815 = hairLight_0(&_S1813, (&ray_3)->unit_direction, &_S1814, _S1812);
                    lit_0 = _S1815;
                }
                else
                {
                    float _S1816 = _S1730.x;
                    float _S1817 = _S1730.y;
                    uint _S1818 = (fcptMaxBounces());
                    bool _S1819 = b_7 < _S1818;
                    TreeSample _S1820 = _S1809;
                    BSDFMaterial _S1821 = _S1729;
                    Facets _S1822 = _S1732;
                    float3  _S1823 = lightBSDF_0((&ray_3)->unit_direction, &_S1820, _S1706.smooth_n, _S1806.geometry_n, &_S1821, _S1816, _S1817, _S1819, &_S1822);
                    lit_0 = _S1823;
                }
            }
            else
            {
                lit_0 = _S1527;
            }
            light_3 = _S1809;
        }
        else
        {
            light_3 = _S1792;
            lit_0 = _S1527;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1824;
        bool _S1825;
        float density_5;
        if(_S1777)
        {
            bool _S1826 = !_S1705;
            if(_S1826)
            {
                return _S1528;
            }
            uint _S1827 = extractBits_0(_S1529, 23U, 1U);
            bool _S1828 = _S1772 != (_S1827 == 1U);
            if(_S1828)
            {
                return _S1528;
            }
            float3  throughput_9 = throughput_7 * make_float3 (geometry_density_0);
            float density_6 = density_3 * geometry_density_0;
            if(_S1785)
            {
                viewed_1 = _S1533 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                float3  _S1829 = pathColor(throughput_9 * emission_1, spectral_weight_1, wavelength_9);
                return Shift_x24init_0(_S1829 / make_float3 (r_9->jac), density_6 / r_9->jac);
            }
            if(_S1785)
            {
                refracted_4 = _S1533 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S1830 = !nee_0;
                if(_S1830)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1831 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1831 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1528;
                }
                float3  _S1832 = pathColor(throughput_9 * lit_0, spectral_weight_1, wavelength_9);
                return Shift_x24init_0(_S1832 / make_float3 (r_9->jac), density_6 / r_9->jac);
            }
            if(_S1785)
            {
                wrong_side_0 = _S1533 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1833 = !nee_0;
                if(_S1833)
                {
                    return _S1528;
                }
                bool _S1834 = (fcptWorldReadsPath());
                if(_S1834)
                {
                    float3  _S1835 = r_9->dir;
                    float _S1836 = environmentPdf_0(r_9->dir);
                    FKSurface _S1837 = surface_12;
                    BSDFMaterial _S1838 = _S1729;
                    Facets _S1839 = _S1732;
                    FixedArray<float3 , 6>  terms_4;
                    FixedArray<float, 6>  pdfs_6;
                    float3  _S1840 = skyLobes_0((&ray_3)->unit_direction, _S1835, &_S1837, &_S1838, _S1730, is_inside_6, &_S1839, _S1836, &terms_4, &pdfs_6);
                    uint _S1841 = b_7 + 1U;
                    FixedArray<float3 , 6>  _S1842 = terms_4;
                    FixedArray<float, 6>  _S1843 = pdfs_6;
                    float3  _S1844 = skyColor_0(_S1835, &_S1842, &_S1843, _S1841);
                    float3  _S1845 = pathColor(throughput_9 * (_S1844 * r_9->radiance), spectral_weight_1, wavelength_9);
                    return Shift_x24init_0(_S1845 / make_float3 (r_9->jac), density_6 / r_9->jac);
                }
                float _S1846 = environmentPdf_0(r_9->dir);
                float3  _S1847 = skyBSDF((&ray_3)->unit_direction, r_9->dir, surface_12, _S1729, _S1730, is_inside_6, _S1732, _S1846);
                float3  _S1848 = pathColor(throughput_9 * _S1847 * r_9->radiance, spectral_weight_1, wavelength_9);
                return Shift_x24init_0(_S1848 / make_float3 (r_9->jac), density_6 / r_9->jac);
            }
            uint _S1849 = extractBits_0(_S1529, 21U, 1U);
            bool _S1850 = nee_0 != (_S1849 == 1U);
            if(_S1850)
            {
                return _S1528;
            }
            throughput_8 = throughput_9;
            density_5 = density_6;
        }
        else
        {
            if(replay_2)
            {
                viewed_1 = _S1778;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1851 = !scatter_2;
                if(_S1851)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1852 = _S1532 != 1U;
                    if(_S1852)
                    {
                        refracted_4 = _S1532 != 3U;
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
                bool _S1853 = _S1532 == 2U;
                if(_S1853)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1705;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1533 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1739)
                    {
                        return _S1528;
                    }
                    uint _S1854 = noiseAddress(_S1555, b_7);
                    FKRay _S1855 = ray_3;
                    FKSurface _S1856 = surface_12;
                    Facets _S1857 = _S1732;
                    ShadowContext _S1858 = context_5;
                    SkySample _S1859 = sampleSky_0(&_S1855, &_S1856, wavelength_9, _S1730, is_inside_6, _S1854, &_S1857, &_S1858);
                    float3  _S1860 = pathColor(throughput_7 * _S1859.color, spectral_weight_1, wavelength_9);
                    return Shift_x24init_0(_S1860, 1.0f);
                }
                if(_S1853)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1705;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1861 = rgb_to_greyscale(light_3.radiance);
                    bool _S1862 = !(_S1861 > 0.0f);
                    if(_S1862)
                    {
                        return _S1528;
                    }
                    float3  _S1863 = pathColor(throughput_7 * lit_0, spectral_weight_1, wavelength_9);
                    return Shift_x24init_0(_S1863, 1.0f);
                }
                if(_S1542)
                {
                    passes_0 = _S1533 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1669;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float3  _S1864 = pathColor(throughput_7 * emission_1, spectral_weight_1, wavelength_9);
                    return Shift_x24init_0(_S1864, 1.0f);
                }
                if(_S1542)
                {
                    passes_0 = _S1533 == 1U;
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
                    passes_0 = !_S1705;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float3  _S1865 = pathColor(throughput_7 * emission_1, spectral_weight_1, wavelength_9);
                    return Shift_x24init_0(_S1865, 1.0f);
                }
                return _S1528;
            }
            else
            {
                if(_S1749)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1866 = b_7 > 0U;
                    if(_S1866)
                    {
                        Reservoir candidate_5 = chain_1;
                        if(_S1764)
                        {
                            float3  _S1867 = safeDivide(throughput_7 * emission_1, chain_throughput_1);
                            (&candidate_5)->radiance = _S1867;
                        }
                        else
                        {
                            if(_S1705)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1868 = pathColor(throughput_7 * emission_1, spectral_weight_1, wavelength_9);
                        Reservoir _S1869 = withEnd(candidate_5, 1U, b_7, _S1868);
                        offer(sel_8, _S1869, _S1868 * make_float3 (scale_4) / make_float3 (density_3));
                    }
                    else
                    {
                        float3  _S1870 = pathColor(throughput_7 * emission_1, spectral_weight_1, wavelength_9);
                        float3  _S1871 = sel_8->glow + _S1870;
                        sel_8->glow = _S1871;
                    }
                    if(nee_0)
                    {
                        float3  _S1872 = pathColor(throughput_7 * lit_0, spectral_weight_1, wavelength_9);
                        Reservoir candidate_6 = chain_1;
                        if(_S1764)
                        {
                            float3  _S1873 = safeDivide(_S1872, chain_throughput_1);
                            (&candidate_6)->radiance = _S1873;
                        }
                        else
                        {
                            if(_S1705)
                            {
                                candidate_6 = here_0;
                                uint _S1874 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1874;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1875 = insertBits_0(_S1557, b_7 + 1U, 5U, 5U);
                                uint _S1876 = insertBits_0(_S1875, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1876;
                            }
                        }
                        Reservoir _S1877 = withEnd(candidate_6, 0U, b_7, _S1872);
                        offer(sel_8, _S1877, _S1872 * make_float3 (scale_4) / make_float3 (density_3));
                    }
                    if(nee_0)
                    {
                        if(_S1739)
                        {
                            _S1824 = false;
                        }
                        else
                        {
                            bool _S1878 = environmentMapped_0();
                            _S1824 = _S1878;
                        }
                    }
                    else
                    {
                        _S1824 = false;
                    }
                    if(_S1824)
                    {
                        uint _S1879 = (fcptMaxBounces());
                        _S1825 = b_7 < _S1879;
                    }
                    else
                    {
                        _S1825 = false;
                    }
                    if(_S1825)
                    {
                        uint _S1880 = noiseAddress(_S1555, b_7);
                        FKRay _S1881 = ray_3;
                        FKSurface _S1882 = surface_12;
                        Facets _S1883 = _S1732;
                        ShadowContext _S1884 = context_5;
                        SkySample _S1885 = sampleSky_0(&_S1881, &_S1882, wavelength_9, _S1730, is_inside_6, _S1880, &_S1883, &_S1884);
                        float3  _S1886 = pathColor(throughput_7 * _S1885.color, spectral_weight_1, wavelength_9);
                        Reservoir candidate_7 = chain_1;
                        if(_S1764)
                        {
                            float3  _S1887 = safeDivide(_S1886, chain_throughput_1);
                            (&candidate_7)->radiance = _S1887;
                        }
                        else
                        {
                            if(_S1705)
                            {
                                candidate_7 = here_0;
                                uint _S1888 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1888;
                                (&candidate_7)->dir = _S1885.dir;
                                (&candidate_7)->radiance = _S1885.radiance;
                            }
                            else
                            {
                                uint _S1889 = insertBits_0(_S1557, b_7 + 1U, 5U, 5U);
                                uint _S1890 = insertBits_0(_S1889, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1890;
                            }
                        }
                        Reservoir _S1891 = withEnd(candidate_7, 4U, b_7, _S1886);
                        offer(sel_8, _S1891, _S1886 * make_float3 (scale_4) / make_float3 (density_3));
                    }
                }
            }
            throughput_8 = throughput_7;
            density_5 = density_3;
        }
        bool _S1892;
        bool _S1893;
        bool _S1894;
        bool straight_0;
        bool _S1895;
        bool _S1896;
        bool _S1897;
        bool _S1898;
        bool _S1899;
        bool _S1900;
        bool _S1901;
        bool _S1902;
        bool _S1903;
        bool _S1904;
        bool _S1905;
        bool _S1906;
        bool _S1907;
        bool _S1908;
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
                viewed_1 = _S1778;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1909 = extractBits_0(_S1529, 15U, 3U);
            uint _S1910 = extractBits_0(_S1529, 18U, 3U);
            uint _S1911 = _slang_select(_S1777, _S1910,_S1909);
            float3  _S1912 = r_9->dir;
            bool refracted_5 = _S1911 == 1U;
            SampleBSDF _S1913 = SampleBSDF_x24init_0(_S1527, _S1527, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1913;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1914 = extractBits_0(_S1529, 22U, 1U);
                bool _S1915 = is_inside_6 != (_S1914 == 1U);
                if(_S1915)
                {
                    return _S1528;
                }
                bool _S1916 = _S1532 == 1U;
                if(_S1916)
                {
                    float3  _S1917 = (fcptHitPosition((_S1544)));
                    throughput_10 = _S1917;
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
                    BSDFMaterial _S1918 = _S1729;
                    bool _S1919 = isTranslucent_0(&_S1918);
                    if(_S1919)
                    {
                        refracted_4 = _S1911 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1920 = throughput_10 - (&ray_3)->origin;
                        float3  _S1921 = _slang_select(_S1916, _S1920,_S1912);
                        wrong_side_0 = (dot_0(_S1706.smooth_n, _S1921) * _S1707) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1916)
                {
                    float3  _S1922 = (&ray_3)->origin;
                    FKSurface _S1923 = surface_12;
                    float3  _S1924 = - _S1706.smooth_n;
                    bool _S1925 = is_inside_6 != refracted_4;
                    float3  _S1926 = _slang_select(_S1925, _S1924,_S1706.smooth_n);
                    float3  _S1927 = throughput_10 - (_S1922 + make_float3 (_S1923.geometry_offset) * _S1926);
                    float3  _S1928 = ((((_S1927)) * make_float3(rnorm3df(((_S1927)).x, ((_S1927)).y, ((_S1927)).z))));
                    reconnection_1 = _S1928;
                }
                else
                {
                    reconnection_1 = _S1912;
                }
                if(_S1739)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1929 = wrongSide_0(is_inside_6, refracted_4, reconnection_1, surface_12.geometry_n);
                    wrong_side_0 = _S1929;
                }
                if(wrong_side_0)
                {
                    return _S1528;
                }
                float3  _S1930 = throughput_10;
                throughput_10 = reconnection_1;
                b_10 = _S1911;
                wrong_side_0 = false;
                reconnection_1 = _S1930;
            }
            else
            {
                bool _S1931 = !_S1777;
                if(_S1931)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1932;
                    if(_S1739)
                    {
                        SampleBSDF _S1933 = (fcptSampleHair((surface_12.hair), (_S1729.albedo), (_S1729.specular_tint), ((&ray_3)->unit_direction), (_S1731.random_state)));
                        _S1932 = _S1933;
                    }
                    else
                    {
                        SampleBSDF _S1934 = sampleBSDF((&ray_3)->unit_direction, _S1706.smooth_n, _S1729, _S1730.x, _S1730.y, _S1732, _S1731.random_state, _S1794);
                        _S1932 = _S1934;
                    }
                    bsdf_sampled_0 = _S1932;
                    if(_S1739)
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
                            return _S1528;
                        }
                        break;
                    }
                    if(_S1739)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1935 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_12.geometry_n);
                        wrong_side_0 = _S1935;
                    }
                    if(wrong_side_0)
                    {
                        _S1824 = (_S1729.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1824 = false;
                    }
                    if(_S1824)
                    {
                        float _S1936 = _S1730.x;
                        float _S1937 = _S1730.y;
                        Facets _S1938 = drawFacets((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S1729, (&bsdf_sampled_0)->random_state);
                        SampleBSDF _S1939 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S1729, _S1936, _S1937, _S1938, (&bsdf_sampled_0)->random_state, _S1794);
                        (&bsdf_sampled_0)->unit_direction = _S1939.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1939.refracted;
                        (&bsdf_sampled_0)->throughput = _S1939.throughput;
                        (&bsdf_sampled_0)->lobe = _S1939.lobe;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1940 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n)) * surface_12.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1940;
                        }
                    }
                    uint _S1941 = (&bsdf_sampled_0)->lobe;
                    float3  _S1942 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1943 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1944 = (&bsdf_sampled_0)->pdf;
                    float _S1945 = _slang_select(wrong_side_0, 0.0f,_S1944);
                    (&lobe_5)->pdf = _S1945;
                    throughput_10 = _S1942;
                    b_10 = _S1941;
                    refracted_4 = _S1943;
                }
                else
                {
                    throughput_10 = _S1912;
                    b_10 = _S1911;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1824 = true;
            }
            else
            {
                _S1824 = _S1777;
            }
            if(_S1824)
            {
                if(_S1739)
                {
                    SampleBSDF _S1946 = (fcptConnectHair((surface_12.hair), (_S1729.albedo), (_S1729.specular_tint), ((&ray_3)->unit_direction), (throughput_10)));
                    lobe_5 = _S1946;
                }
                else
                {
                    float3  _S1947 = (&ray_3)->unit_direction;
                    float3  _S1948 = negate_0(_S1947);
                    float _S1949 = sign_0(_S1707);
                    float3  _S1950 = _S1706.smooth_n * make_float3 (_S1949);
                    float _S1951 = dot_0(_S1950, throughput_10);
                    float _S1952 = _S1729.roughness;
                    float _S1953 = _S1952 * _S1952;
                    AnisotropicFrame _S1954 = anisotropicFrame(_S1729, _S1950);
                    SheenProfile _S1955 = sheenProfile(_S1948, _S1950, _S1729);
                    CoatFrame _S1956 = coatFrame(_S1729, _S1950);
                    float3  _S1957 = coatSeries(_S1956, _S1729);
                    float3  _S1958 = reflectedHalf(_S1947, throughput_10);
                    bool _S1959 = b_10 == 1U;
                    if(_S1959)
                    {
                        float3  _S1960 = refractedHalf(_S1947, throughput_10, _S1706.smooth_n, _S1730.x, _S1730.y);
                        throughput_11 = _S1960;
                    }
                    else
                    {
                        throughput_11 = _S1958;
                    }
                    float3  _S1961 = _S1732.coat_h;
                    bool _S1962 = (dot_0(_S1961, _S1961)) > 0.0f;
                    float3  _S1963 = _slang_select(_S1962, _S1958,_S1527);
                    float _S1964 = _S1730.x;
                    float _S1965 = _S1730.y;
                    Weights _S1966 = lobeWeights(_S1947, _S1948, _S1950, _S1732.h, _S1732.coat_h, throughput_11, _S1963, _S1954, _S1955, _S1956, _S1957, _S1729, _S1964, _S1965);
                    float _S1967 = (F32_abs((_S1707)));
                    float _S1968 = vndfPDF(_S1948, throughput_11, _S1950, _S1967, _S1953, _S1954, _S1966.v_dot_h);
                    switch(b_10)
                    {
                    case 0U:
                        {
                            float _S1969 = diffusePDF(_S1951, _S1967, _S1729, _S1966);
                            float3  _S1970 = diffuseBSDF(throughput_10, _S1950, _S1729, _S1966);
                            density_7 = _S1969;
                            throughput_12 = _S1970;
                            break;
                        }
                    case 1U:
                        {
                            float _S1971 = refractPDF(dot_0(throughput_10, throughput_11), _S1968, _S1966, _S1964, _S1965);
                            float _S1972 = maskingG1(throughput_10, _S1950, -1.0f, _S1953, _S1954);
                            float3  _S1973 = refractBSDF(_S1972, _S1729, _S1966);
                            density_7 = _S1971;
                            throughput_12 = _S1973;
                            break;
                        }
                    case 4U:
                        {
                            float _S1974 = sheenVelvetPDF(_S1951, _S1967, _S1966);
                            float3  _S1975 = sheenVelvetBSDF(throughput_10, _S1948, _S1950, _S1729, _S1966);
                            density_7 = _S1974;
                            throughput_12 = _S1975;
                            break;
                        }
                    case 5U:
                        {
                            float _S1976 = coatPDF(_S1948, _S1963, _S1956, _S1966);
                            float3  _S1977 = coatBSDF(_S1966);
                            density_7 = _S1976;
                            throughput_12 = _S1977;
                            break;
                        }
                    case 6U:
                        {
                            ToonProfile _S1978 = toonProfile(_S1948, _S1950, _S1729);
                            float _S1979 = toonPDF(throughput_10, _S1950, _S1978, _S1966);
                            float3  _S1980 = toonBSDF(throughput_10, _S1950, _S1978, _S1966);
                            density_7 = _S1979;
                            throughput_12 = _S1980;
                            break;
                        }
                    default:
                        {
                            float _S1981 = reflectPDF(_S1968, _S1966);
                            float _S1982 = maskingG1(throughput_10, _S1950, 1.0f, _S1953, _S1954);
                            float3  _S1983 = reflectBSDF(_S1982, _S1966);
                            density_7 = _S1981;
                            throughput_12 = _S1983;
                            break;
                        }
                    }
                    bool _S1984 = density_7 > 0.0f;
                    if(_S1984)
                    {
                        SampleBSDF _S1985 = SampleBSDF_x24init_0(throughput_10, throughput_12, _S1731.random_state, _S1959, b_10, density_7);
                        lobe_5 = _S1985;
                    }
                }
            }
            bool _S1986 = b_10 == 0U;
            if(_S1986)
            {
                _S1825 = true;
            }
            else
            {
                _S1825 = b_10 == 4U;
            }
            if(_S1825)
            {
                _S1892 = true;
            }
            else
            {
                _S1892 = b_10 == 6U;
            }
            bool _S1987 = b_10 == 5U;
            float _S1988 = _slang_select(_S1987, _S1729.coat_roughness,_S1729.roughness);
            if(_S1739)
            {
                _S1893 = false;
            }
            else
            {
                bool _S1989 = !_S1892;
                if(_S1989)
                {
                    bool _S1990 = _S1988 == 0.0f;
                    if(_S1990)
                    {
                        _S1893 = true;
                    }
                    else
                    {
                        bool _S1991 = b_10 == 1U;
                        if(_S1991)
                        {
                            _S1893 = (_S1730.x) == (_S1730.y);
                        }
                        else
                        {
                            _S1893 = false;
                        }
                    }
                }
                else
                {
                    _S1893 = false;
                }
            }
            bool _S1992 = !_S1739;
            if(_S1992)
            {
                _S1894 = b_10 == 1U;
            }
            else
            {
                _S1894 = false;
            }
            if(_S1894)
            {
                straight_0 = (_S1729.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1895 = _S1992;
            }
            else
            {
                _S1895 = false;
            }
            if(_S1895)
            {
                _S1896 = b_10 == 1U;
            }
            else
            {
                _S1896 = false;
            }
            if(_S1896)
            {
                _S1897 = (_S1730.x) == (_S1730.y);
            }
            else
            {
                _S1897 = false;
            }
            BSDFMaterial _S1993 = _S1729;
            bool _S1994 = isTranslucent_0(&_S1993);
            if(_S1994)
            {
                _S1898 = _S1986;
            }
            else
            {
                _S1898 = false;
            }
            if(_S1898)
            {
                _S1899 = (dot_0(throughput_10, surface_12.geometry_n)) < 0.0f;
            }
            else
            {
                _S1899 = false;
            }
            if(nee_0)
            {
                _S1900 = !_S1893;
            }
            else
            {
                _S1900 = false;
            }
            if(_S1900)
            {
                _S1901 = !wrong_side_0;
            }
            else
            {
                _S1901 = false;
            }
            if(_S1901)
            {
                float _S1995 = (&lobe_5)->pdf;
                float3  _S1996 = (&ray_3)->origin;
                float3  _S1997 = _slang_select(_S1744, _S1527,_S1706.smooth_n);
                float3  _S1998 = (&ray_3)->origin;
                FKSurface _S1999 = surface_12;
                float3  _S2000 = - _S1706.smooth_n;
                float3  _S2001 = _slang_select(_S1899, _S2000,_S1706.smooth_n);
                NEEVertex _S2002 = NEEVertex_x24init_0(false, _S1995, _S1996, _S1997, _S1998 + make_float3 (_S1999.geometry_offset) * _S2001);
                nee_vertex_1 = _S2002;
            }
            else
            {
                if(_S1739)
                {
                    _S1902 = true;
                }
                else
                {
                    bool _S2003 = b_10 != 1U;
                    if(_S2003)
                    {
                        _S1902 = true;
                    }
                    else
                    {
                        _S1902 = (_S1730.x) != (_S1730.y);
                    }
                }
                if(_S1902)
                {
                    (&nee_vertex_1)->none = true;
                }
            }
            bool _S2004 = ((&lobe_5)->pdf) > 0.0f;
            if(_S2004)
            {
                if(_S1892)
                {
                    _S1902 = true;
                }
                else
                {
                    _S1902 = ((&lobe_5)->pdf * (&prev_1)->cos / ((&hit_4)->distance * (&hit_4)->distance) * threshold_0) <= 1.0f;
                }
            }
            else
            {
                _S1902 = false;
            }
            bool _S2005 = ((&lobe_5)->pdf) > 0.0f;
            if(_S2005)
            {
                if(_S1892)
                {
                    _S1903 = true;
                }
                else
                {
                    _S1903 = _S1988 >= 0.20000000298023224f;
                }
            }
            else
            {
                _S1903 = false;
            }
            if(_S1777)
            {
                bool _S2006 = !_S1902;
                if(_S2006)
                {
                    return _S1528;
                }
                bool _S2007 = _S1533 != 1U;
                if(_S2007)
                {
                    _S1904 = _S1533 != 2U;
                }
                else
                {
                    _S1904 = false;
                }
                if(_S1904)
                {
                    float _S2008 = (&lobe_5)->pdf;
                    float _S2009 = _slang_select(nee_0, _S2008,0.0f);
                    float _S2010 = escapeWeight_0(_S2009, _S1912);
                    if(_S1785)
                    {
                        passes_0 = _S1539;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S2011 = _slang_select(passes_0, _S2010,1.0f);
                    return Shift_x24init_0(throughput_8 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_9->radiance * make_float3 (_S2011) / make_float3 (r_9->jac), density_5 * (&lobe_5)->pdf / r_9->jac);
                }
                float3  _S2012 = throughput_8 * make_float3 ((&lobe_5)->pdf);
                float _S2013 = density_5 * (&lobe_5)->pdf;
                throughput_11 = _S2012;
                density_7 = _S2013;
            }
            else
            {
                throughput_11 = throughput_8;
                density_7 = density_5;
            }
            uint _S2014 = (fcptLayers((hit_4)));
            bool _S2015 = _S2014 > 1U;
            if(_S2015)
            {
                _S1904 = (b_10 == 1U) != passes_0;
            }
            else
            {
                _S1904 = false;
            }
            if(viewed_1)
            {
                _S1905 = _S1904;
            }
            else
            {
                _S1905 = false;
            }
            if(_S1905)
            {
                return _S1528;
            }
            if(replay_2)
            {
                _S1906 = b_7 <= _S1543;
            }
            else
            {
                _S1906 = false;
            }
            if(_S1906)
            {
                _S1907 = _S1705;
            }
            else
            {
                _S1907 = false;
            }
            if(_S1907)
            {
                _S1908 = _S1902;
            }
            else
            {
                _S1908 = false;
            }
            bool _S2016;
            if(_S1908)
            {
                _S2016 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S2016 = !_S1903;
                }
                else
                {
                    _S2016 = false;
                }
            }
            if(_S2016)
            {
                return _S1528;
            }
            if(viewed_1)
            {
                float3  _S2017 = throughput_11 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S2018 = (&lobe_5)->pdf;
                throughput_12 = _S2017;
                sky_pdf_3 = _S2018;
            }
            else
            {
                float3  _S2019 = throughput_11 * max_0((&lobe_5)->throughput, _S1527);
                throughput_12 = _S2019;
                sky_pdf_3 = density_7;
            }
            bool _S2020;
            if(_S1749)
            {
                _S2020 = !_S1764;
            }
            else
            {
                _S2020 = false;
            }
            bool _S2021;
            if(_S2020)
            {
                _S2021 = _S1705;
            }
            else
            {
                _S2021 = false;
            }
            bool _S2022;
            if(_S2021)
            {
                _S2022 = _S1902;
            }
            else
            {
                _S2022 = false;
            }
            float3  chain_throughput_2;
            if(_S2022)
            {
                chain_1 = here_0;
                uint _S2023 = insertBits_0((&chain_1)->path, b_10, 18U, 3U);
                uint _S2024 = _slang_select(nee_0, 1U,0U);
                uint _S2025 = insertBits_0(_S2023, _S2024, 21U, 1U);
                (&chain_1)->path = _S2025;
                float _S2026 = (&chain_1)->jac * (&lobe_5)->pdf;
                (&chain_1)->jac = _S2026;
                (&chain_1)->dir = throughput_10;
                chain_throughput_2 = throughput_12;
            }
            else
            {
                chain_throughput_2 = chain_throughput_1;
            }
            FKSurface _S2027 = surface_12;
            Vertex _S2028 = Vertex_x24init_0(_S1903, b_10, (&lobe_5)->pdf, (F32_abs((dot_0(surface_12.geometry_n, throughput_10)))), is_inside_6);
            prev_1 = _S2028;
            float _S2029 = (&lobe_5)->pdf;
            bool _S2030 = b_10 == 1U;
            bool _S2031;
            if(_S2030)
            {
                _S2031 = (_S1730.x) == (_S1730.y);
            }
            else
            {
                _S2031 = false;
            }
            float sky_pdf_4 = _slang_select(_S2031, sky_pdf_1,_S2029);
            float _S2032 = _slang_select(_S1739, 0.0f,sky_pdf_4);
            float _S2033 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * (&lobe_5)->pdf))))), (3.14159274101257324f)));
            bool _S2034 = !_S1893;
            float _S2035 = _slang_select(_S2034, _S2033,0.0f);
            float _S2036 = spread_1 + _S2035;
            bool _S2037;
            if(refracted_4)
            {
                _S2037 = !_S1899;
            }
            else
            {
                _S2037 = false;
            }
            bool is_inside_7;
            if(_S2037)
            {
                bool _S2038 = !is_inside_6;
                is_inside_7 = _S2038;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            FKSurface _S2039 = surface_12;
            bool _S2040 = boundsVolume_0(&_S2039);
            bool _S2041;
            if(_S2040)
            {
                _S2041 = !_S1904;
            }
            else
            {
                _S2041 = false;
            }
            if(_S2041)
            {
                FKSurface faced_2 = surface_12;
                float3  _S2042 = - _S2027.geometry_n;
                float3  _S2043 = _slang_select(turned_1, _S2042,_S2027.geometry_n);
                (&faced_2)->geometry_n = _S2043;
                FKMedium _S2044 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S2045 = (fcptOutsideMedium((hit_4)));
                FKSurface _S2046 = faced_2;
                FKMedium _S2047 = _S2044;
                FKMedium _S2048 = _S2045;
                MediumSides _S2049 = mediumSides_0(&_S2046, &_S2047, filling_2, (&ray_3)->unit_direction, &_S2048);
                bool _S2050 = ((dot_0(throughput_10, _S2027.geometry_n)) > 0.0f) == ((dot_0(_S2027.geometry_n, (&faced_2)->geometry_n)) > 0.0f);
                float3  _S2051 = _slang_select(_S2050, _S2049.front.scatter,_S2049.behind.scatter);
                scatter_in_0 = _S2051;
                float3  _S2052 = scatter_in_0;
                float _S2053 = upsample(scatter_in_0, wavelength_9);
                float3  _S2054 = make_float3 (_S2053);
                float3  _S2055 = _slang_select(_S1772, _S2054,_S2052);
                scatter_in_0 = _S2055;
                float3  _S2056 = _slang_select(_S2050, _S2049.front.extinction,_S2049.behind.extinction);
                extinction_in_0 = _S2056;
                float3  _S2057 = extinction_in_0;
                float _S2058 = upsample(extinction_in_0, wavelength_9);
                float3  _S2059 = make_float3 (_S2058);
                float3  _S2060 = _slang_select(_S1772, _S2059,_S2057);
                extinction_in_0 = _S2060;
                float _S2061 = _slang_select(_S2050, _S2049.front.g,_S2049.behind.g);
                g_in_0 = _S2061;
                uint _S2062 = _S2049.fillings.x;
                uint _S2063 = _S2049.fillings.y;
                uint _S2064 = _slang_select(_S2050, _S2063,_S2062);
                bool _S2065 = (fcptVaryingUsed());
                uint _S2066 = _slang_select(_S2065, _S2064,4294967295U);
                filling_2 = _S2066;
            }
            (&ray_3)->unit_direction = throughput_10;
            bool _S2067 = !_S1904;
            if(_S2067)
            {
                FKSurface _S2068 = surface_12;
                float _S2069 = _slang_select(straight_0, 0.0f,_S2068.geometry_offset);
                float3  _S2070 = - _S1706.smooth_n;
                bool _S2071 = is_inside_7 != _S1899;
                float3  _S2072 = _slang_select(_S2071, _S2070,_S1706.smooth_n);
                float3  _S2073 = (&ray_3)->origin + make_float3 (_S2069) * _S2072;
                (&ray_3)->origin = _S2073;
            }
            throughput_11 = throughput_12;
            chain_throughput_1 = chain_throughput_2;
            density_7 = sky_pdf_3;
            passes_0 = _S1904;
            viewed_1 = _S1897;
            sky_pdf_3 = _S2032;
            spread_4 = _S2036;
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
        if(_S1749)
        {
            if(_S1669)
            {
                float3  _S2074 = pathColor(throughput_11 * emission_1, spectral_weight_1, wavelength_9);
                Reservoir candidate_8 = chain_1;
                uint _S2075 = extractBits_0((&chain_1)->path, 10U, 2U);
                bool _S2076 = _S2075 == 1U;
                if(_S2076)
                {
                    float3  _S2077 = safeDivide(_S2074, chain_throughput_1);
                    (&candidate_8)->radiance = _S2077;
                }
                Reservoir _S2078 = withEnd(candidate_8, 2U, b_7, _S2074);
                offer(sel_8, _S2078, _S2074 * make_float3 (scale_4) / make_float3 (density_7));
            }
            if(_S1669)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S2079 = survivalProbability(abs_0(throughput_11), density_7);
                density_8 = _S2079;
            }
            else
            {
                density_8 = 1.0f;
            }
            uint _S2080 = (fcptMaxBounces());
            bool _S2081 = b_7 >= _S2080;
            if(_S2081)
            {
                wrong_side_0 = true;
            }
            else
            {
                bool _S2082 = density_8 < 1.0f;
                if(_S2082)
                {
                    uint _S2083 = noiseAddress(_S1555, b_7);
                    Random _S2084 = draw(_S2083, 8U);
                    wrong_side_0 = density_8 < (_S2084.value);
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
            float _S2085 = density_7 * density_8;
            density_8 = _S2085;
        }
        else
        {
            density_8 = density_7;
        }
        uint _S2086 = layer_0 ^ 1U;
        uint _S2087 = _slang_select(passes_0, _S2086,0U);
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
            uint _S2088 = b_10 + 1U;
            b_7 = _S2088;
            layer_0 = _S2087;
            continue;
        }
        FKRay _S2089 = ray_3;
        float _S2090 = distance_1(reconnection_0, (&ray_3)->origin) * 1.0010000467300415f;
        if(replay_2)
        {
            refracted_4 = _S1778;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S1532 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S2091 = _slang_select(wrong_side_0, _S2090,4.294967296e+09f);
        bool _S2092 = !_S1739;
        if(straight_0)
        {
            _S1824 = true;
        }
        else
        {
            _S1824 = _S1739;
        }
        FKHit _S2093;
        if(_S1824)
        {
            _S2093 = hit_4;
        }
        else
        {
            _S2093 = _S1795;
        }
        FKHit _S2094 = (fcptTraverseInstanceBVH((_S2089), (_S1675), (_S2091), (_S2092), (_S2093), (viewed_1)));
        hit_4 = _S2094;
        if(replay_2)
        {
            _S1825 = _S1778;
        }
        else
        {
            _S1825 = false;
        }
        if(_S1825)
        {
            _S1892 = _S1532 == 1U;
        }
        else
        {
            _S1892 = false;
        }
        if(_S1892)
        {
            _S1893 = ((&hit_4)->instance_index) == (_S1544.instance_index);
        }
        else
        {
            _S1893 = false;
        }
        if(_S1893)
        {
            _S1894 = ((&hit_4)->triangle_index) == (_S1544.triangle_index);
        }
        else
        {
            _S1894 = false;
        }
        if(_S1894)
        {
            (&hit_4)->uv = _S1544.uv;
            float _S2095 = distance_1(reconnection_0, (&ray_3)->origin);
            (&hit_4)->distance = _S2095;
        }
        if(replay_2)
        {
            _S1895 = _S1778;
        }
        else
        {
            _S1895 = false;
        }
        if(_S1895)
        {
            _S1896 = _S1532 == 3U;
        }
        else
        {
            _S1896 = false;
        }
        if(_S1896)
        {
            _S1897 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1897 = false;
        }
        if(_S1897)
        {
            return _S1528;
        }
        Reservoir _S2096 = chain_1;
        uint _S2097 = filling_2;
        for(;;)
        {
            bool _S2098 = (fcptVaryingUsed());
            if(_S2098)
            {
                _S1898 = _S2097 != 4294967295U;
            }
            else
            {
                _S1898 = false;
            }
            if(_S1898)
            {
                float _S2099 = (fcptMajorant((_S2097)));
                _S1899 = _S2099 > 0.0f;
            }
            else
            {
                _S1899 = any_1(scatter_in_0 > make_float3 (0.0f));
            }
            if(replay_2)
            {
                _S1900 = _S1778;
            }
            else
            {
                _S1900 = false;
            }
            if(_S1900)
            {
                _S1901 = _S1532 == 1U;
            }
            else
            {
                _S1901 = false;
            }
            if(_S1901)
            {
                _S1902 = _S1899;
            }
            else
            {
                _S1902 = false;
            }
            if(_S1902)
            {
                ended_0 = _S1528;
                sky_pdf_2 = sky_pdf_3;
                spread_2 = spread_4;
                width_4 = width_3;
                density_4 = density_8;
                throughput_12 = throughput_11;
                b_10 = b_7;
                _S1903 = true;
                break;
            }
            bool _S2100 = (&prev_1)->rough;
            if(_S2100)
            {
                _S1903 = !_S1899;
            }
            else
            {
                _S1903 = false;
            }
            (&prev_1)->rough = _S1903;
            uint _S2101 = b_7 + 320U;
            bool _S2102 = b_7 == 4294967295U;
            uint _S2103 = _slang_select(_S2102, 384U,_S2101);
            uint _S2104 = stream(_S1555, _S2103);
            uint tracking_1 = _S2104;
            weight_2 = throughput_4;
            glowed_0 = _S1527;
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
                    _S1526 = int(2);
                    break;
                }
                float _S2105 = (&hit_4)->distance;
                if(_S1898)
                {
                    float3  _S2106 = (&ray_3)->origin;
                    float3  _S2107 = (&ray_3)->unit_direction;
                    float _S2108 = (&hit_4)->distance;
                    bool _S2109 = b_10 == 4294967295U;
                    uint _S2110 = _slang_select(_S2109, 0U,b_10);
                    uint _S2111 = (&prev_1)->lobe;
                    uint _S2112 = _slang_select(_S2109, 3U,_S2111);
                    float _S2113 = (fcptTrackMedium((_S2097), (_S2106), (_S2107), (_S2108), (&tracking_1), (&weight_2), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S2110), (_S2112), (_S2109)));
                    spread_3 = _S2113;
                }
                else
                {
                    if(_S1899)
                    {
                        uint _S2114 = noiseAddress(_S1555, b_10);
                        Random _S2115 = draw(_S2114, 10U);
                        float _S2116 = 3.0f * _S2115.value;
                        uint _S2117 = (U32_min((uint(_S2116)), (2U)));
                        float _S2118 = - (F32_log((1.0f - (_S2116 - float(_S2117))))) / *_slang_vector_get_element_ptr(&scatter_in_0, _S2117);
                        spread_3 = _S2118;
                    }
                    else
                    {
                        spread_3 = _S2105;
                    }
                }
                bool _S2119 = !(spread_3 < ((&hit_4)->distance));
                if(_S2119)
                {
                    _S1526 = int(2);
                    break;
                }
                if(_S1898)
                {
                    _S1904 = _S1749;
                }
                else
                {
                    _S1904 = false;
                }
                if(_S1904)
                {
                    float3  _S2120 = pathColor(throughput_12 * glowed_0, spectral_weight_1, wavelength_9);
                    float3  _S2121 = _S2120 / make_float3 (density_4);
                    float3  _S2122 = sel_8->glow + _S2121;
                    sel_8->glow = _S2122;
                }
                else
                {
                }
                glowed_0 = _S1527;
                uint b_11 = b_10 + 1U;
                float3  _S2123 = (&ray_3)->origin + make_float3 (spread_3) * (&ray_3)->unit_direction;
                (&ray_3)->origin = _S2123;
                float3  _S2124 = flightWeight_0(scatter_in_0, extinction_in_0, spread_3, true);
                float3  _S2125 = weight_2;
                float _S2126 = upsample(weight_2, wavelength_9);
                float3  _S2127 = make_float3 (_S2126);
                float3  _S2128 = _slang_select(_S1772, _S2127,_S2125);
                float3  _S2129 = _slang_select(_S1898, _S2128,_S2124);
                float3  throughput_13 = throughput_12 * _S2129;
                uint _S2130 = stream(_S1555, b_11 + 320U);
                tracking_1 = _S2130;
                weight_2 = throughput_4;
                float width_8 = width_4 + spread_2 * spread_3;
                float _S2131 = spread_2 + 3.14159274101257324f;
                if(_S1749)
                {
                    _S1905 = true;
                }
                else
                {
                    bool _S2132 = b_11 == _S1543;
                    if(_S2132)
                    {
                        _S1905 = !_S1898;
                    }
                    else
                    {
                        _S1905 = false;
                    }
                }
                TreeSample light_4;
                if(_S1905)
                {
                    float3  _S2133 = (&ray_3)->origin;
                    float3  _S2134 = (&ray_3)->unit_direction;
                    float3  _S2135 = (&ray_3)->unit_direction;
                    uint _S2136 = noiseAddress(_S1555, b_11);
                    float3  _S2137 = extinction_in_0;
                    float3  _S2138 = extinction_in_0;
                    uint2  _S2139 = make_uint2 (_S2097);
                    float3  _S2140 = (&ray_3)->unit_direction;
                    uint _S2141 = arrivalLobe_0(b_11, (&prev_1)->lobe);
                    FKHit _S2142 = _S1795;
                    ShadowContext _S2143 = ShadowContext_x24init_0(_S2137, _S2138, _S2139, _S2140, b_11, _S2141, false, spread_3, width_8, &_S2142, false);
                    ShadowContext _S2144 = _S2143;
                    TreeSample _S2145 = sampleLightTree_0(_S2133, _S2134, _S2135, 0.0f, true, _S2136, &_S2144);
                    light_4 = _S2145;
                }
                else
                {
                    light_4 = _S1792;
                }
                float _S2146 = phaseHG_0(g_in_0, dot_0((&ray_3)->unit_direction, light_4.dir));
                uint _S2147 = (fcptMaxBounces());
                bool _S2148 = b_11 < _S2147;
                if(_S2148)
                {
                    _S1906 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1906 = false;
                }
                float _S2149 = _slang_select(_S1906, _S2146,0.0f);
                float3  _S2150 = throughput_13 * light_4.radiance;
                float _S2151 = powerHeuristic(light_4.density, _S2149);
                float3  _S2152 = pathColor(_S2150 * make_float3 (_S2146 * _S2151), spectral_weight_1, wavelength_9);
                float3  _S2153 = _slang_select(_S1905, _S2152,_S1527);
                if(replay_2)
                {
                    _S1907 = b_11 == _S1543;
                }
                else
                {
                    _S1907 = false;
                }
                if(_S1907)
                {
                    bool _S2154 = _S1532 == 2U;
                    if(_S2154)
                    {
                        float _S2155 = resamplingTarget(_S2153);
                        _S1908 = _S2155 > 0.0f;
                    }
                    else
                    {
                        _S1908 = false;
                    }
                    if(_S1908)
                    {
                        Shift _S2156 = Shift_x24init_0(_S2153, 1.0f);
                        _S1526 = int(1);
                        ended_0 = _S2156;
                        spread_3 = _S2131;
                        width_5 = width_8;
                        throughput_10 = throughput_13;
                        b_8 = b_11;
                        break;
                    }
                    _S1526 = int(1);
                    ended_0 = _S1528;
                    spread_3 = _S2131;
                    width_5 = width_8;
                    throughput_10 = throughput_13;
                    b_8 = b_11;
                    break;
                }
                if(_S1749)
                {
                    Reservoir candidate_9 = _S2096;
                    uint _S2157 = extractBits_0(_S2096.path, 24U, 8U);
                    uint _S2158 = insertBits_0(0U, _S2157, 24U, 8U);
                    uint _S2159 = extractBits_0(_S2096.path, 10U, 2U);
                    bool _S2160 = _S2159 == 1U;
                    if(_S2160)
                    {
                        float3  _S2161 = safeDivide(_S2153, chain_throughput_1);
                        (&candidate_9)->radiance = _S2161;
                    }
                    else
                    {
                        uint _S2162 = insertBits_0(_S2158, b_11 + 1U, 5U, 5U);
                        uint _S2163 = insertBits_0(_S2162, 2U, 10U, 2U);
                        (&candidate_9)->path = _S2163;
                    }
                    Reservoir _S2164 = withEnd(candidate_9, 0U, b_11, _S2153);
                    offer(sel_8, _S2164, _S2153 * make_float3 (scale_4) / make_float3 (density_4));
                    float _S2165 = survivalProbability(abs_0(throughput_13), density_4);
                    uint _S2166 = (fcptMaxBounces());
                    bool _S2167 = b_11 >= _S2166;
                    if(_S2167)
                    {
                        _S1908 = true;
                    }
                    else
                    {
                        bool _S2168 = _S2165 < 1.0f;
                        if(_S2168)
                        {
                            uint _S2169 = noiseAddress(_S1555, b_11);
                            Random _S2170 = draw(_S2169, 8U);
                            _S1908 = _S2165 < (_S2170.value);
                        }
                        else
                        {
                            _S1908 = false;
                        }
                    }
                    if(_S1908)
                    {
                        _S1526 = int(1);
                        ended_0 = _S1528;
                        spread_3 = _S2131;
                        width_5 = width_8;
                        throughput_10 = throughput_13;
                        b_8 = b_11;
                        break;
                    }
                    float _S2171 = density_4 * _S2165;
                    density_4 = _S2171;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S2172 = noiseAddress(_S1555, b_11);
                float3  _S2173 = samplePhase_0(g_in_0, (&ray_3)->unit_direction, _S2172, &phase_pdf_1);
                (&ray_3)->unit_direction = _S2173;
                NEEVertex _S2174 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_3)->origin, _S1527, (&ray_3)->origin);
                nee_vertex_1 = _S2174;
                Vertex _S2175 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_5);
                prev_1 = _S2175;
                float _S2176 = (&prev_1)->pdf;
                FKRay _S2177 = ray_3;
                FKHit _S2178 = (fcptTraverseInstanceBVH((_S2177), (true), (4.294967296e+09f), (false), (_S1795), (false)));
                hit_4 = _S2178;
                b_10 = b_11;
                throughput_12 = throughput_13;
                spread_2 = _S2131;
                width_4 = width_8;
                sky_pdf_2 = _S2176;
            }
            if(_S1526 != int(2))
            {
                spread_2 = spread_3;
                width_4 = width_5;
                throughput_12 = throughput_10;
                b_10 = b_8;
                _S1903 = true;
                break;
            }
            ended_0 = _S1528;
            _S1903 = false;
            break;
        }
        if(_S1903)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1904 = b_10 == b_7;
        }
        else
        {
            _S1904 = false;
        }
        bool _S2179 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S2179)
        {
            Reservoir _S2180 = chain_1;
            FKRay _S2181 = ray_3;
            Vertex _S2182 = prev_1;
            NEEVertex _S2183 = nee_vertex_1;
            Shift _S2184 = escape_0(r_9, replay_2, _S1543, _S1532, _S1530, _S1533, scale_4, _S1557, &_S2180, chain_throughput_1, b_10, &_S2181, throughput_12, density_4, &_S2182, &_S2183, sky_pdf_2, spectral_weight_1, wavelength_9, sel_8);
            return _S2184;
        }
        FKHit _S2185 = hit_4;
        uint _S2186 = filling_2;
        float3  _S2187 = scatter_in_0;
        float3  _S2188 = extinction_in_0;
        float3  _S2189 = weight_2;
        float3  _S2190 = glowed_0;
        float3  _S2191 = (&ray_3)->origin + make_float3 (_S2185.distance) * (&ray_3)->unit_direction;
        (&ray_3)->origin = _S2191;
        bool _S2192 = (fcptVaryingUsed());
        if(_S2192)
        {
            _S1905 = _S2186 != 4294967295U;
        }
        else
        {
            _S1905 = false;
        }
        if(_S1905)
        {
            if(_S1749)
            {
                float3  _S2193 = pathColor(throughput_12 * _S2190, spectral_weight_1, wavelength_9);
                float3  _S2194 = _S2193 / make_float3 (density_4);
                float3  _S2195 = sel_8->glow + _S2194;
                sel_8->glow = _S2195;
            }
            else
            {
            }
            float3  _S2196 = throughput_12 * _S2189;
            throughput_10 = _S2196;
        }
        else
        {
            float3  _S2197 = flightWeight_0(_S2187, _S2188, _S2185.distance, false);
            float3  _S2198 = throughput_12 * _S2197;
            throughput_10 = _S2198;
        }
        float width_9 = width_4 + spread_2 * _S2185.distance;
        viewed_0 = _S1904;
        width_3 = width_9;
        throughput_3 = throughput_10;
        density_3 = density_4;
        sky_pdf_1 = sky_pdf_2;
        spread_1 = spread_2;
        uint _S2088 = b_10 + 1U;
        b_7 = _S2088;
        layer_0 = _S2087;
    }
    return _S1528;
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
    Random _S2199 = pcg(state_4);
    Random _S2200 = pcg(_S2199.state);
    float _S2201 = 6.28318548202514648f * _S2199.value;
    float _S2202 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S2200.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S2200.state, _S2202 * (F32_cos((_S2201))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_5, float3  value_2)
{
    RandomSphere _S2203;
    (&_S2203)->state = state_5;
    (&_S2203)->value = value_2;
    return _S2203;
}

__device__ RandomSphere random_sphere(uint state_6)
{
    Random _S2204 = normal_distribution(state_6);
    Random _S2205 = normal_distribution(_S2204.state);
    Random _S2206 = normal_distribution(_S2205.state);
    float3  _S2207 = make_float3 (_S2204.value, _S2205.value, _S2206.value);
    float3  _S2208 = ((((_S2207)) * make_float3(rnorm3df(((_S2207)).x, ((_S2207)).y, ((_S2207)).z))));
    return RandomSphere_x24init_0(_S2206.state, _S2208);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_14)
{
    float3  _S2209 = p1_0 - p0_0;
    float3  _S2210 = p2_0 - p0_0;
    float2  _S2211 = uv1_0 - uv0_0;
    float2  _S2212 = uv2_0 - uv0_0;
    float _S2213 = _S2211.x;
    float _S2214 = _S2212.y;
    float _S2215 = _S2211.y;
    float _S2216 = _S2212.x;
    float _S2217 = _S2213 * _S2214 - _S2215 * _S2216;
    float _S2218 = 1.0f / _S2217;
    float3  t_24 = (_S2209 * make_float3 (_S2214) - _S2210 * make_float3 (_S2215)) * make_float3 (_S2218);
    float3  _S2219 = (_S2210 * make_float3 (_S2213) - _S2209 * make_float3 (_S2216)) * make_float3 (_S2218);
    float3  _S2220 = t_24 - n_14 * make_float3 (dot_0(n_14, t_24));
    float3  _S2221 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_14);
    bool _S2222 = (dot_0(_S2220, _S2220)) > 0.0f;
    float3  _S2223 = _slang_select(_S2222, _S2220,_S2221);
    float3  _S2224 = ((((_S2223)) * make_float3(rnorm3df(((_S2223)).x, ((_S2223)).y, ((_S2223)).z))));
    bool _S2225 = (dot_0(cross_0(n_14, _S2224), _S2219)) > 0.0f;
    float3  t_25;
    if(_S2225)
    {
        float3  _S2226 = negate_0(_S2224);
        t_25 = _S2226;
    }
    else
    {
        t_25 = _S2224;
    }
    float3  _S2227 = cross_0(n_14, t_25);
    return makeMatrix<float, 3, 3> (t_25, _S2227, n_14);
}

__device__ float3  tangentToWorldNormalMap(float3  v_13, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_13, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_4, float3  uvw_0, float3  position_1)
{
    float3  _S2228 = t1_0 - t0_0;
    float3  _S2229 = t2_2 - t0_0;
    float3  _S2230 = t2_2 - t1_0;
    float _S2231 = (F32_min((length_0(_S2228)), ((F32_min((length_0(_S2229)), (length_0(_S2230)))))));
    float3  _S2232 = make_float3 (distance_1(position_1, t0_0), distance_1(position_1, t1_0), distance_1(position_1, t2_2));
    float3  _S2233 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S2234 = dot_0(geometry_n_4, _S2233);
    float3  _S2235 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S2236 = dot_0(geometry_n_4, _S2235);
    float3  _S2237 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S2238 = acos_0(abs_0(make_float3 (_S2234, _S2236, dot_0(geometry_n_4, _S2237))));
    float3  _S2239 = clamp_2(tan_0(_S2238), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S2232 * _S2239, uvw_0), 0.0f, _S2231 * 0.125f);
}

__device__ float3  straightThrough(BSDFMaterial material_29)
{
    return make_float3 (material_29.transmission * (1.0f - material_29.metallic)) * material_29.albedo;
}

__device__ float hairRow(float3  in_dir_13, float3  t_26, float3  out_dir_3, uint p_17, float w_20, float alpha_9, uint nt_0)
{
    uint _S2240 = p_17 % 4U;
    float _S2241 = w_20 * HAIR_WIDTHS_0[_S2240];
    float _S2242 = (F32_asin((clamp_1(dot_0(out_dir_3, t_26), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_13, t_26), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S2240] * alpha_9;
    return ((F32_asinh((_S2242 / _S2241))) / (F32_asinh((3.14159274101257324f / _S2241))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_14, float3  t_27, float3  out_dir_4, uint np_0)
{
    float3  _S2243 = worldToTangent(out_dir_4, t_27);
    float3  _S2244 = worldToTangent(in_dir_14, t_27);
    return (F32_frac((((F32_atan2((_S2243.z), (_S2243.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S2244.z), (1.17549435082228751e-38f - _S2244.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_15, float3  t_28, uint p_18, float row_0, float column_0, float w_21, float alpha_10, uint nt_1, uint np_1)
{
    float3  _S2245 = worldToTangent(in_dir_15, t_28);
    uint _S2246 = p_18 % 4U;
    float _S2247 = w_21 * HAIR_WIDTHS_0[_S2246];
    float _S2248 = (F32_asin((clamp_1(dot_0(in_dir_15, t_28), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S2246] * alpha_10 + _S2247 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S2247))))));
    float _S2249 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S2245.z), (1.17549435082228751e-38f - _S2245.x)));
    float _S2250 = (F32_cos((_S2248)));
    float3  _S2251 = tangentToWorld(make_float3 (_S2250 * (F32_cos((_S2249))), (F32_sin((_S2248))), _S2250 * (F32_sin((_S2249)))), t_28);
    return _S2251;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_15, BSDFMaterial material_30, float coverage_1)
{
    float3  through_2;
    if((material_30.ior) == 1.0f)
    {
        float3  _S2252 = straightThrough(material_30);
        through_2 = _S2252;
    }
    else
    {
        through_2 = make_float3 (0.0f);
    }
    CoatFrame _S2253 = coatFrame(material_30, n_15);
    bool _S2254 = (_S2253.ior) > 0.0f;
    if(_S2254)
    {
        float _S2255 = fresnel((F32_abs((dot_0(_S2253.normal, toward_1)))), 1.0f, _S2253.ior);
        float3  _S2256 = mix_0(make_float3 (1.0f), make_float3 (1.0f - _S2255) * material_30.coat_tint, material_30.coat);
        float3  through_3 = through_2 * _S2256;
        through_2 = through_3;
    }
    return through_2 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_9, Reservoir r_10, bool replay_3, float scale_5, Selection * sel_9)
{
    Domain _S2257 = dom_9;
    Reservoir _S2258 = r_10;
    Shift _S2259 = walk_0(&_S2257, &_S2258, replay_3, scale_5, sel_9);
    return _S2259;
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
        uint _S2260 = size_0 - 1U;
        uint _S2261 = (x_29 + size_0 / 2U) & _S2260;
        bool _S2262 = i_27 < 2U;
        uint _S2263 = _slang_select(_S2262, x_29,_S2261);
        uint l_5 = _S2263;
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
            uint _S2264 = hash(((r_11 ^ (t_29 << 16U)) ^ (k_4 << 28U)) ^ ((i_27 & 1U) << 31U));
            uint _S2265 = l_5 ^ (_S2264 & _S2260);
            uint k_5 = k_4 + 1U;
            l_5 = r_11;
            r_11 = _S2265;
            k_4 = k_5;
        }
        uint _S2266 = l_5 + r_11 * size_0;
        uint _S2267 = size_0 * size_0;
        uint _S2268;
        if(_S2267 >= 65536U)
        {
            uint _S2269 = _S2266 / (_S2267 / 65536U);
            _S2268 = _S2269;
        }
        else
        {
            uint _S2270 = 65536U / _S2267;
            _S2268 = _S2266 * _S2270;
        }
        ranks_0[i_27] = _S2268;
        uint i_28 = i_27 + 1U;
        i_27 = i_28;
    }
    bool _S2271 = (ranks_0[int(0)]) == 65535U;
    bool _S2272;
    if(_S2271)
    {
        _S2272 = (ranks_0[int(1)]) == 65535U;
    }
    else
    {
        _S2272 = false;
    }
    bool _S2273 = (ranks_0[int(2)]) == 65535U;
    bool _S2274;
    if(_S2273)
    {
        _S2274 = (ranks_0[int(3)]) == 65535U;
    }
    else
    {
        _S2274 = false;
    }
    if(_S2272)
    {
        _S2272 = (ranks_0[int(3)]) != 65535U;
    }
    else
    {
        _S2272 = false;
    }
    if(_S2272)
    {
        _S2272 = true;
    }
    else
    {
        if(_S2274)
        {
            _S2272 = (ranks_0[int(1)]) != 65535U;
        }
        else
        {
            _S2272 = false;
        }
    }
    uint _S2275 = ranks_0[int(0)];
    uint _S2276 = ranks_0[int(1)];
    uint _S2277 = ranks_0[int(3)];
    uint _S2278 = _slang_select(_S2272, _S2277,_S2276);
    return _S2275 | (_S2278 << 16U);
}

__device__ uint3  noiseBlock(uint sweep_0, uint colour_0, uint block_0, uint size_1)
{
    uint _S2279 = hash(sweep_0 * 7919U + 1U);
    uint _S2280 = size_1 / 16U;
    uint _S2281 = block_0 % _S2280;
    uint _S2282 = block_0 / _S2280;
    uint _S2283 = _S2282 % _S2280;
    uint _S2284 = block_0 / (_S2280 * _S2280);
    uint3  _S2285 = make_uint3 (_S2281, _S2283, _S2284);
    uint3  _S2286 = make_uint3 (colour_0 & 1U, (colour_0 >> 1U) & 1U, colour_0 >> 2U);
    return _S2285 * make_uint3 (16U) + _S2286 * make_uint3 (8U) + make_uint3 (_S2279 & 7U, (_S2279 >> 3U) & 7U, (_S2279 >> 6U) & 7U);
}

#undef Matrix
