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
    Weights _S362;
    (&_S362)->v_dot_h = v_dot_h_0;
    (&_S362)->refracted = refracted_1;
    (&_S362)->F = F_0;
    (&_S362)->reflect_weight = reflect_weight_0;
    (&_S362)->diffuse_weight = diffuse_weight_0;
    (&_S362)->refract_weight = refract_weight_0;
    (&_S362)->p_diffuse = p_diffuse_0;
    (&_S362)->p_reflect = p_reflect_0;
    (&_S362)->p_refract = p_refract_0;
    (&_S362)->p_sheen_velvet = p_sheen_velvet_0;
    (&_S362)->p_toon = p_toon_0;
    (&_S362)->sheen = sheen_0;
    (&_S362)->toon = toon_0;
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

__device__ __forceinline__ float3  sampledHalf(float3  v_4, float3  n_i_3, float alpha_2, AnisotropicFrame frame_1, uint random_state_3)
{
    uint state_2 = random_state_3;
    float3  _S405 = sampleHalfVector(v_4, n_i_3, alpha_2, frame_1, &state_2);
    return _S405;
}

__device__ __forceinline__ float3  refractedHalf(float3  in_dir_0, float3  out_dir_0, float3  n_4, float eta_i_0, float eta_o_0)
{
    float3  _S406 = negate_0(in_dir_0);
    float3  _S407 = negate_0(make_float3 (eta_i_0) * _S406 + make_float3 (eta_o_0) * out_dir_0);
    float3  _S408 = ((((_S407)) * make_float3(rnorm3df(((_S407)).x, ((_S407)).y, ((_S407)).z))));
    float _S409 = sign_0(dot_0(n_4, _S406));
    float _S410 = sign_0(dot_0(_S407, n_4 * make_float3 (_S409)));
    return _S408 * make_float3 (_S410);
}

__device__ __forceinline__ float3  reflectedHalf(float3  in_dir_1, float3  out_dir_1)
{
    float3  _S411 = negate_0(in_dir_1);
    float3  _S412 = _S411 + out_dir_1;
    float3  _S413 = ((((_S412)) * make_float3(rnorm3df(((_S412)).x, ((_S412)).y, ((_S412)).z))));
    return _S413;
}

static __device__ float3  refract_0(float3  i_5, float3  n_5, float eta_0)
{
    float _S414 = dot_0(n_5, i_5);
    float _S415 = 1.0f - eta_0 * eta_0 * (1.0f - _S414 * _S414);
    if(_S415 < 0.0f)
    {
        return make_float3 (0.0f);
    }
    return make_float3 (eta_0) * i_5 - make_float3 (eta_0 * _S414 + (F32_sqrt((_S415)))) * n_5;
}

__device__ float fresnel(float cos_theta_0, float eta_i_1, float eta_o_1)
{
    float _S416 = (F32_sqrt(((F32_max((0.0f), (1.0f - cos_theta_0 * cos_theta_0))))));
    float _S417 = eta_i_1 / eta_o_1 * _S416;
    bool _S418 = _S417 < 1.0f;
    float kr_0;
    if(_S418)
    {
        float _S419 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S417 * _S417))))));
        bool _S420 = eta_i_1 == eta_o_1;
        float _S421 = _slang_select(_S420, cos_theta_0,_S419);
        float _S422 = eta_o_1 * cos_theta_0;
        float _S423 = eta_i_1 * _S421;
        float _S424 = (_S422 - _S423) / (_S422 + _S423);
        float _S425 = eta_i_1 * cos_theta_0;
        float _S426 = eta_o_1 * _S421;
        float _S427 = (_S425 - _S426) / (_S425 + _S426);
        float _S428 = (_S424 * _S424 + _S427 * _S427) / 2.0f;
        kr_0 = _S428;
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
    float _S429 = dot_0(ggx_n_0, v_5);
    float _S430 = eta_i_2 / eta_o_2;
    float3  _S431 = refract_0(in_dir_2, ggx_n_0, _S430);
    float3  _S432 = ((((_S431)) * make_float3(rnorm3df(((_S431)).x, ((_S431)).y, ((_S431)).z))));
    float _S433 = (F32_min(((F32_sqrt((material_2.specular_level))) * (F32_abs((eta_i_2 - eta_o_2))) / (eta_i_2 + eta_o_2)), (0.9999847412109375f)));
    float _S434 = _S433 * _S433;
    float _S435 = (1.0f + _S433) / (1.0f - _S433);
    float _S436 = (F32_abs((_S429)));
    bool _S437 = eta_i_2 > eta_o_2;
    float _S438 = _slang_select(_S437, _S435,1.0f);
    float _S439 = _slang_select(_S437, 1.0f,_S435);
    float _S440 = fresnel(_S436, _S438, _S439);
    bool _S441 = (eta_i_2 * eta_i_2 * (1.0f - _S429 * _S429)) >= (eta_o_2 * eta_o_2);
    float3  _S442 = material_2.specular_tint * make_float3 (_S434);
    float3  _S443 = _S442 + (make_float3 (1.0f) - _S442) * make_float3 (_S440 - _S434) / make_float3 (1.0f - _S434);
    float3  _S444 = make_float3 (1.0f);
    float3  _S445 = _slang_select(_S441, _S444,_S443);
    float3  _S446 = make_float3 (0.0f);
    float sheen_component_0;
    float3  sheen_1;
    float3  scale_1;
    if(sheen_profile_0.on)
    {
        float _S447 = (F32_min((sheen_profile_0.albedo), (1.0f)));
        float3  _S448 = make_float3 (1.0f) - material_2.sheen * make_float3 (_S447);
        float _S449 = rgb_to_greyscale(material_2.sheen);
        float _S450 = _S449 * _S447;
        float3  _S451 = material_2.sheen / make_float3 ((F32_max((sheen_profile_0.albedo), (1.0f))));
        sheen_component_0 = _S450;
        sheen_1 = _S451;
        scale_1 = _S448;
    }
    else
    {
        sheen_component_0 = 0.0f;
        sheen_1 = _S446;
        scale_1 = _S444;
    }
    float _S452 = (F32_abs((material_2.toon.x)));
    bool _S453 = _S452 > 0.0f;
    float toon_component_0;
    float3  toon_1;
    if(_S453)
    {
        float _S454 = (F32_min((_S452), (1.0f)));
        float3  scale_2 = scale_1 * make_float3 (1.0f - _S454);
        float _S455 = rgb_to_greyscale(material_2.albedo);
        float _S456 = _S454 * _S455;
        float3  _S457 = make_float3 (_S454) * material_2.albedo;
        toon_component_0 = _S456;
        toon_1 = _S457;
        scale_1 = scale_2;
    }
    else
    {
        toon_component_0 = 0.0f;
        toon_1 = _S446;
    }
    bool _S458 = (material_2.metallic) > 0.0f;
    float3  rebounce_0;
    if(_S458)
    {
        float _S459 = frame_2.alphas.x;
        float _S460 = (F32_sqrt(((F32_min((_S459), (frame_2.alphas.y))))));
        bool _S461 = _S459 > 0.0f;
        float _S462 = _slang_select(_S461, _S460,material_2.roughness);
        float _S463 = _S462 * _S462;
        float _S464 = (F32_pow((_S463), (1.81585001945495605f))) * (2.15371990203857422f - 0.73285001516342163f * _S463) / (1.0f + 1.28094995021820068f * _S463);
        bool _S465 = _S463 > 0.0f;
        float _S466 = _slang_select(_S465, _S464,0.0f);
        float _S467 = clamp_1(dot_0(n_i_4, v_5), 0.0f, 1.0f);
        float _S468 = _S463 * _S462;
        float _S469 = (F32_min((1.00064504146575928f - _S462 * (0.00375499995425344f + _S467 * (-0.04133399948477745f + _S467 * (-0.90938502550125122f + _S467 * 0.35275399684906006f))) - _S463 * (0.27602800726890564f + _S467 * (1.27023398876190186f + _S467 * 0.04740000143647194f)) - _S468 * (0.31452900171279907f - _S467 * 0.34830701351165771f) + _S468 * _S462 * 0.27229699492454529f), (1.0f)));
        float3  _S470 = min_1(make_float3 (1.0f) / (make_float3 (1.0f) - material_2.albedo * make_float3 (_S466)), make_float3 (1.0f / (F32_max((_S469), (0.0000152587890625f)))));
        rebounce_0 = _S470;
    }
    else
    {
        rebounce_0 = _S444;
    }
    float3  _S471 = mix_0(_S445, material_2.albedo * rebounce_0, material_2.metallic);
    float3  F_1 = _S471 * scale_1;
    float _S472 = rgb_to_greyscale(F_1);
    float _S473 = 1.0f - material_2.metallic;
    float3  _S474 = make_float3 (1.0f) - _S445;
    float3  _S475 = make_float3 ((1.0f - material_2.transmission) * _S473) * _S474 * scale_1;
    float3  _S476 = make_float3 (material_2.transmission * _S473) * _S474 * scale_1;
    float _S477 = (F32_max((_S472), (0.0f)));
    float _S478 = rgb_to_greyscale(_S475);
    float _S479 = (F32_max((_S478), (0.0f)));
    float _S480 = rgb_to_greyscale(_S476);
    float _S481 = sign_0(length_0(_S432));
    float _S482 = (F32_max((_S480 * _S481), (0.0f)));
    float _S483 = _S477 + _S479 + _S482 + toon_component_0;
    float _S484 = (F32_min((sheen_component_0), (1.0f)));
    bool _S485 = sheen_component_0 > 0.0f;
    bool _S486;
    if(_S485)
    {
        _S486 = !(_S483 > 0.0f);
    }
    else
    {
        _S486 = false;
    }
    float _S487 = _slang_select(_S486, 1.0f,_S484);
    float _S488 = (1.0f - _S487) / (F32_max((_S483), (0.0000152587890625f)));
    float _S489 = _S479 * _S488;
    float _S490 = _S477 * _S488;
    float _S491 = _S482 * _S488;
    return Weights_x24init_0(_S429, _S432, F_1, 1.0f, _S475, _S476, _S489, _S490, _S491, _S487, toon_component_0 * _S488, sheen_1, toon_1);
}

__device__ float translucentShare(BSDFMaterial material_3)
{
    float _S492 = rgb_to_greyscale(material_3.translucent);
    float _S493 = rgb_to_greyscale(material_3.albedo);
    float _S494 = _S492 / (_S493 + _S492);
    bool _S495 = _S492 > 0.0f;
    float _S496 = _slang_select(_S495, _S494,0.0f);
    return _S496;
}

__device__ __forceinline__ float diffusePDF(float n_i_dot_l_0, float n_i_dot_v_0, BSDFMaterial material_4, Weights w_1)
{
    float _S497 = translucentShare(material_4);
    float _S498 = w_1.p_diffuse * n_i_dot_l_0 * 0.31830987334251404f;
    float _S499 = w_1.p_diffuse * (F32_abs((n_i_dot_l_0))) * 0.31830987334251404f;
    float _S500 = 1.0f - _S497;
    bool _S501 = n_i_dot_l_0 < 0.0f;
    float _S502 = _slang_select(_S501, _S497,_S500);
    float _S503 = _S499 * _S502;
    bool _S504 = _S497 > 0.0f;
    float _S505 = _slang_select(_S504, _S503,_S498);
    bool _S506 = n_i_dot_v_0 > 0.0f;
    float _S507 = _slang_select(_S506, _S505,0.0f);
    return _S507;
}

__device__ __forceinline__ float3  diffuseBSDF(float3  l_0, float3  n_i_5, BSDFMaterial material_5, Weights w_2)
{
    float _S508 = translucentShare(material_5);
    bool _S509 = (dot_0(n_i_5, l_0)) < 0.0f;
    float3  _S510 = _slang_select(_S509, material_5.translucent,material_5.albedo);
    float _S511 = 1.0f - _S508;
    float _S512 = _slang_select(_S509, _S508,_S511);
    float3  _S513 = _S510 / make_float3 (_S512);
    bool _S514 = _S508 > 0.0f;
    float3  _S515 = _slang_select(_S514, _S513,material_5.albedo);
    return w_2.diffuse_weight * _S515 / make_float3 (w_2.p_diffuse);
}

__device__ float smithG1(float alpha_3, float n_dot_x_0)
{
    float _S516 = alpha_3 * alpha_3;
    float _S517 = 2.0f * n_dot_x_0 / (n_dot_x_0 + (F32_sqrt((_S516 + (1.0f - _S516) * n_dot_x_0 * n_dot_x_0))));
    bool _S518 = alpha_3 > 0.0f;
    float _S519 = _slang_select(_S518, _S517,1.0f);
    return _S519;
}

__device__ float trowbridgeReitz(float alpha_4, float n_dot_h_0)
{
    float _S520 = alpha_4 * alpha_4;
    float _S521 = (1.0f - n_dot_h_0) * (1.0f + n_dot_h_0) + _S520 * n_dot_h_0 * n_dot_h_0;
    return _S520 / (F32_max((3.14159274101257324f * _S521 * _S521), (1.17549435082228751e-38f)));
}

__device__ float anisotropicG1(float3  w_3, float2  alphas_1)
{
    float _S522 = (F32_max((w_3.z), (0.0f)));
    return 2.0f * _S522 / (_S522 + length_0(make_float3 (alphas_1.x * w_3.x, alphas_1.y * w_3.y, _S522)));
}

__device__ float anisotropicD(float3  h_0, float2  alphas_2)
{
    float _S523 = alphas_2.x;
    float _S524 = h_0.x / _S523;
    float _S525 = alphas_2.y;
    float _S526 = h_0.y / _S525;
    float _S527 = h_0.z;
    float _S528 = _S524 * _S524 + _S526 * _S526 + _S527 * _S527;
    return 1.0f / (F32_max((3.14159274101257324f * _S523 * _S525 * _S528 * _S528), (1.17549435082228751e-38f)));
}

__device__ __forceinline__ float vndfPDF(float3  v_6, float3  h_1, float3  n_i_6, float n_i_dot_v_1, float alpha_5, AnisotropicFrame frame_3, float v_dot_h_1)
{
    float _S529 = dot_0(n_i_6, h_1);
    float _S530 = smithG1(alpha_5, n_i_dot_v_1);
    float _S531 = _S530 * v_dot_h_1;
    float _S532 = trowbridgeReitz(alpha_5, _S529);
    float _S533 = _S531 * _S532 / n_i_dot_v_1;
    bool _S534 = alpha_5 > 0.0f;
    bool _S535;
    if(_S534)
    {
        _S535 = v_dot_h_1 > 0.0f;
    }
    else
    {
        _S535 = false;
    }
    if(_S535)
    {
        _S535 = _S529 > 0.0f;
    }
    else
    {
        _S535 = false;
    }
    if(_S535)
    {
        _S535 = n_i_dot_v_1 > 0.0f;
    }
    else
    {
        _S535 = false;
    }
    float _S536 = _slang_select(_S535, _S533,0.0f);
    bool _S537 = (frame_3.alphas.x) > 0.0f;
    float pdf_h_0;
    if(_S537)
    {
        float3  _S538 = anisotropicLocal(v_6, frame_3.tangent, n_i_6);
        float _S539 = anisotropicG1(_S538, frame_3.alphas);
        float3  _S540 = anisotropicLocal(h_1, frame_3.tangent, n_i_6);
        float _S541 = anisotropicD(_S540, frame_3.alphas);
        float _S542 = _S539 * _S541;
        float _S543 = _S542 * v_dot_h_1 / n_i_dot_v_1;
        bool _S544 = v_dot_h_1 > 0.0f;
        if(_S544)
        {
            _S535 = _S529 > 0.0f;
        }
        else
        {
            _S535 = false;
        }
        if(_S535)
        {
            _S535 = n_i_dot_v_1 > 0.0f;
        }
        else
        {
            _S535 = false;
        }
        float _S545 = _slang_select(_S535, _S543,0.0f);
        pdf_h_0 = _S545;
    }
    else
    {
        pdf_h_0 = _S536;
    }
    return pdf_h_0;
}

__device__ __forceinline__ float refractPDF(float l_dot_h_0, float pdf_h_1, Weights w_4, float eta_i_3, float eta_o_3)
{
    float _S546 = eta_i_3 * w_4.v_dot_h + eta_o_3 * l_dot_h_0;
    float _S547 = w_4.p_refract * pdf_h_1 * eta_o_3 * eta_o_3 * (F32_abs((l_dot_h_0))) / (_S546 * _S546);
    bool _S548 = eta_i_3 != eta_o_3;
    bool _S549;
    if(_S548)
    {
        _S549 = l_dot_h_0 < 0.0f;
    }
    else
    {
        _S549 = false;
    }
    float _S550 = _slang_select(_S549, _S547,0.0f);
    return _S550;
}

__device__ __forceinline__ float3  refractBSDF(float3  l_1, float3  n_i_7, float alpha_6, AnisotropicFrame frame_4, BSDFMaterial material_6, Weights w_5)
{
    float _S551 = - dot_0(n_i_7, l_1);
    float _S552 = smithG1(alpha_6, (F32_max((_S551), (0.0f))));
    bool _S553 = (frame_4.alphas.x) > 0.0f;
    float G1_l_0;
    if(_S553)
    {
        float3  _S554 = negate_0(n_i_7);
        float3  _S555 = anisotropicLocal(l_1, frame_4.tangent, _S554);
        float _S556 = anisotropicG1(_S555, frame_4.alphas);
        G1_l_0 = _S556;
    }
    else
    {
        G1_l_0 = _S552;
    }
    bool _S557 = (material_6.ior) == 1.0f;
    float _S558 = _slang_select(_S557, 1.0f,G1_l_0);
    return w_5.refract_weight * make_float3 (_S558) * material_6.albedo / make_float3 (w_5.p_refract);
}

__device__ __forceinline__ float sheenVelvetPDF(float n_i_dot_l_1, float n_i_dot_v_2, Weights w_6)
{
    float _S559 = w_6.p_sheen_velvet * 0.5f * 0.31830987334251404f;
    bool _S560 = n_i_dot_l_1 > 0.0f;
    bool _S561;
    if(_S560)
    {
        _S561 = n_i_dot_v_2 > 0.0f;
    }
    else
    {
        _S561 = false;
    }
    float _S562 = _slang_select(_S561, _S559,0.0f);
    return _S562;
}

__device__ __forceinline__ float3  sheenVelvetBSDF(float3  l_2, float3  v_7, float3  n_i_8, BSDFMaterial material_7, Weights w_7)
{
    float3  _S563 = l_2 + v_7;
    float3  _S564 = ((((_S563)) * make_float3(rnorm3df(((_S563)).x, ((_S563)).y, ((_S563)).z))));
    float _S565 = dot_0(n_i_8, _S564);
    float _S566 = (F32_max((dot_0(n_i_8, l_2)), (0.0f)));
    float _S567 = (F32_max((dot_0(n_i_8, v_7)), (0.0f)));
    float _S568 = 1.0f / (F32_max((material_7.sheen_roughness), (0.05000000074505806f)));
    float _S569 = 1.0f - _S565 * _S565;
    float _S570 = (2.0f + _S568) * (F32_pow(((F32_max((_S569), (0.0f)))), (0.5f * _S568))) * 0.5f * 0.31830987334251404f / (F32_max((4.0f * (_S566 + _S567 - _S566 * _S567)), (0.0000152587890625f)));
    bool _S571 = (material_7.velvet) > 0.0f;
    float f_1;
    if(_S571)
    {
        float _S572 = (F32_max((material_7.sheen_roughness), (0.00999999977648258f)));
        float _S573 = _S572 * _S572;
        float _S574 = (F32_max((_S569), (0.0000152587890625f)));
        float _S575 = (F32_exp((- _S565 * _S565 / (_S574 * _S573)))) / (3.14159274101257324f * _S573 * _S574 * _S574) * (F32_min((1.0f), (2.0f * _S565 * (F32_min((_S566), (_S567))) / (F32_max(((F32_abs((dot_0(_S564, v_7))))), (0.0000152587890625f)))))) / (F32_max((4.0f * _S566 * _S567), (0.0000152587890625f)));
        f_1 = _S575;
    }
    else
    {
        f_1 = _S570;
    }
    return w_7.sheen * make_float3 (f_1 * _S566 * 2.0f * 3.14159274101257324f / w_7.p_sheen_velvet);
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
    float _S576 = (F32_max((1.0f - (t_13 - a_5) / (F32_max((s_0), (0.0000152587890625f)))), (0.0f)));
    bool _S577 = t_13 < a_5;
    float _S578 = _slang_select(_S577, 1.0f,_S576);
    return _S578;
}

__device__ __forceinline__ float toonIntegral(float t_14, float a_6, float s_1, bool glossy_0)
{
    float _S579 = (F32_min((t_14), (a_6)));
    float _S580 = (F32_sin((_S579)));
    float _S581 = _S580 * _S580 / 2.0f;
    float _S582 = 1.0f - (F32_cos((_S579)));
    float _S583 = _slang_select(glossy_0, _S582,_S581);
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
    float integral_0;
    if(_S585)
    {
        if(glossy_0)
        {
            float _S586 = (F32_cos((a_6)));
            float _S587 = (F32_cos((t_14)));
            integral_0 = (1.0f + a_6 / s_1) * (_S586 - _S587) - ((F32_sin((t_14))) - t_14 * _S587 - ((F32_sin((a_6))) - a_6 * _S586)) / s_1;
        }
        else
        {
            float _S588 = 2.0f * a_6;
            float _S589 = (F32_cos((_S588)));
            float _S590 = 2.0f * t_14;
            float _S591 = (F32_cos((_S590)));
            integral_0 = (1.0f + a_6 / s_1) * (_S589 - _S591) / 4.0f - ((F32_sin((_S590))) / 8.0f - t_14 * _S591 / 4.0f - ((F32_sin((_S588))) / 8.0f - a_6 * _S589 / 4.0f)) / s_1;
        }
        float integral_1 = _S583 + integral_0;
        integral_0 = integral_1;
    }
    else
    {
        integral_0 = _S583;
    }
    return integral_0;
}

static __device__ ToonProfile ToonProfile_x24init_0(bool glossy_1, float a_7, float s_2, float b_1, float norm_0, float view_0, float3  axis_0)
{
    ToonProfile _S592;
    (&_S592)->glossy = glossy_1;
    (&_S592)->a = a_7;
    (&_S592)->s = s_2;
    (&_S592)->b = b_1;
    (&_S592)->norm = norm_0;
    (&_S592)->view = view_0;
    (&_S592)->axis = axis_0;
    return _S592;
}

__device__ __forceinline__ ToonProfile toonProfile(float3  v_8, float3  n_i_9, BSDFMaterial material_8)
{
    float _S593 = material_8.toon.x;
    bool _S594 = _S593 < 0.0f;
    float _S595 = clamp_1(material_8.toon.y / _S593, 0.00000999999974738f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S596 = clamp_1(material_8.toon.z / _S593, 0.0f, 1.0f) * 3.14159274101257324f / 2.0f;
    float _S597 = (F32_min((_S595 + _S596), (1.57079637050628662f)));
    float _S598 = dot_0(n_i_9, v_8);
    float _S599 = toonP((F32_acos(((F32_min((_S598), (1.0f)))))), _S595, _S596);
    float3  _S600 = make_float3 (2.0f * _S598) * n_i_9 - v_8;
    float3  _S601 = ((((_S600)) * make_float3(rnorm3df(((_S600)).x, ((_S600)).y, ((_S600)).z))));
    float3  _S602 = _slang_select(_S594, _S601,n_i_9);
    float _S603 = toonIntegral(_S597, _S595, _S596, _S594);
    return ToonProfile_x24init_0(_S594, _S595, _S596, _S597, 6.28318548202514648f * _S603, _S599, _S602);
}

__device__ __forceinline__ float toonPDF(float3  l_3, float3  n_i_10, ToonProfile profile_1, Weights w_8)
{
    float _S604 = dot_0(n_i_10, l_3);
    float _S605 = dot_0(l_3, profile_1.axis);
    float _S606 = _slang_select(profile_1.glossy, _S605,_S604);
    float _S607 = (F32_acos((clamp_1(_S606, -1.0f, 1.0f))));
    float _S608 = toonP(_S607, profile_1.a, profile_1.s);
    float _S609 = w_8.p_toon * _S608;
    float _S610 = _slang_select(profile_1.glossy, 1.0f,_S604);
    float _S611 = _S609 * _S610 / profile_1.norm;
    bool _S612;
    if(profile_1.glossy)
    {
        _S612 = true;
    }
    else
    {
        _S612 = _S604 > 0.0f;
    }
    float _S613 = _slang_select(_S612, _S611,0.0f);
    return _S613;
}

__device__ __forceinline__ float3  toonBSDF(float3  l_4, float3  n_i_11, ToonProfile profile_2, Weights w_9)
{
    float _S614 = (F32_max((dot_0(n_i_11, l_4)), (0.0f)));
    float _S615 = _slang_select(profile_2.glossy, _S614,profile_2.view);
    return w_9.toon * make_float3 (_S615) / make_float3 (w_9.p_toon);
}

__device__ __forceinline__ float reflectPDF(float pdf_h_2, Weights w_10)
{
    float _S616 = w_10.p_reflect * pdf_h_2 / (4.0f * w_10.v_dot_h);
    bool _S617 = pdf_h_2 > 0.0f;
    float _S618 = _slang_select(_S617, _S616,0.0f);
    return _S618;
}

__device__ __forceinline__ float3  reflectBSDF(float3  l_5, float3  n_i_12, float alpha_7, AnisotropicFrame frame_5, Weights w_11)
{
    float _S619 = dot_0(n_i_12, l_5);
    float _S620 = smithG1(alpha_7, (F32_max((_S619), (0.0f))));
    bool _S621 = (frame_5.alphas.x) > 0.0f;
    float G1_l_1;
    if(_S621)
    {
        float3  _S622 = anisotropicLocal(l_5, frame_5.tangent, n_i_12);
        float _S623 = anisotropicG1(_S622, frame_5.alphas);
        G1_l_1 = _S623;
    }
    else
    {
        G1_l_1 = _S620;
    }
    return make_float3 (w_11.reflect_weight * G1_l_1) * w_11.F / make_float3 (w_11.p_reflect);
}

__device__ __forceinline__ float3  BSDF(float3  in_dir_3, float3  out_dir_2, float3  n_6, BSDFMaterial material_9, float eta_i_4, float eta_o_4, bool refracted_2, uint random_state_4, FixedArray<float3 , 5>  * throughputs_0, FixedArray<float, 5>  * pdfs_0)
{
    float3  ggx_n_1;
    float3  _S624 = negate_0(in_dir_3);
    float _S625 = dot_0(n_6, _S624);
    float _S626 = sign_0(_S625);
    float3  _S627 = n_6 * make_float3 (_S626);
    float _S628 = dot_0(_S627, out_dir_2);
    float _S629 = material_9.roughness;
    float _S630 = _S629 * _S629;
    AnisotropicFrame _S631 = anisotropicFrame(material_9, _S627);
    SheenProfile _S632 = sheenProfile(_S624, _S627, material_9);
    float _S633 = rgb_to_greyscale(material_9.translucent);
    bool _S634 = _S633 > 0.0f;
    bool _S635 = (dot_0(n_6, out_dir_2) * _S625) < 0.0f;
    bool _S636 = (F32_abs((material_9.toon.x))) > 0.0f;
    uint _S637;
    if(_S636)
    {
        _S637 = 5U;
    }
    else
    {
        _S637 = 4U;
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
        float3  _S638 = make_float3 (0.0f);
        (*throughputs_0)[i_7] = _S638;
        (*pdfs_0)[i_7] = 0.0f;
        uint i_8 = i_7 + 1U;
        i_7 = i_8;
    }
    float3  _S639 = make_float3 (0.0f);
    Weights _S640 = Weights_x24init_0(0.0f, _S639, _S639, 0.0f, _S639, _S639, 0.0f, 0.0f, 0.0f, 0.0f, 0.0f, _S639, _S639);
    uint half_of_0 = 4294967295U;
    Weights w_12 = _S640;
    float3  ggx_n_2 = _S639;
    i_7 = 0U;
    for(;;)
    {
        if(i_7 < _S637)
        {
        }
        else
        {
            break;
        }
        uint _S641;
        if(i_7 == 3U)
        {
            _S641 = 4U;
        }
        else
        {
            if(i_7 == 4U)
            {
                _S641 = 6U;
            }
            else
            {
                _S641 = i_7;
            }
        }
        bool _S642 = _S641 == 0U;
        bool _S643;
        if(_S642)
        {
            _S643 = _S634;
        }
        else
        {
            _S643 = false;
        }
        bool _S644;
        if(_S643)
        {
            _S644 = _S635;
        }
        else
        {
            _S644 = _S641 == 1U;
        }
        bool _S645 = _S644 != refracted_2;
        if(_S645)
        {
            ggx_n_1 = ggx_n_2;
            uint i_9 = i_7 + 1U;
            ggx_n_2 = ggx_n_1;
            i_7 = i_9;
            continue;
        }
        uint _S646;
        if(_S641 == 6U)
        {
            _S646 = 0U;
        }
        else
        {
            if(_S641 == 4U)
            {
                _S646 = 2U;
            }
            else
            {
                _S646 = _S641;
            }
        }
        bool _S647 = _S646 != half_of_0;
        uint half_of_1;
        Weights w_13;
        if(_S647)
        {
            bool _S648 = _S646 == 0U;
            if(_S648)
            {
                float3  _S649 = sampledHalf(_S624, _S627, _S630, _S631, random_state_4);
                ggx_n_1 = _S649;
            }
            else
            {
                bool _S650 = _S646 == 1U;
                if(_S650)
                {
                    float3  _S651 = refractedHalf(in_dir_3, out_dir_2, n_6, eta_i_4, eta_o_4);
                    ggx_n_1 = _S651;
                }
                else
                {
                    float3  _S652 = reflectedHalf(in_dir_3, out_dir_2);
                    ggx_n_1 = _S652;
                }
            }
            Weights _S653 = lobeWeights(in_dir_3, _S624, _S627, ggx_n_1, _S631, _S632, material_9, eta_i_4, eta_o_4);
            w_13 = _S653;
            half_of_1 = _S646;
        }
        else
        {
            w_13 = w_12;
            ggx_n_1 = ggx_n_2;
            half_of_1 = half_of_0;
        }
        switch(_S641)
        {
        case 0U:
            {
                float _S654 = diffusePDF(_S628, (F32_abs((_S625))), material_9, w_13);
                (*pdfs_0)[int(0)] = _S654;
                float3  _S655 = diffuseBSDF(out_dir_2, _S627, material_9, w_13);
                (*throughputs_0)[int(0)] = _S655;
                break;
            }
        case 1U:
            {
                float _S656 = dot_0(out_dir_2, ggx_n_1);
                float _S657 = vndfPDF(_S624, ggx_n_1, _S627, (F32_abs((_S625))), _S630, _S631, w_13.v_dot_h);
                float _S658 = refractPDF(_S656, _S657, w_13, eta_i_4, eta_o_4);
                (*pdfs_0)[int(1)] = _S658;
                float3  _S659 = refractBSDF(out_dir_2, _S627, _S630, _S631, material_9, w_13);
                (*throughputs_0)[int(1)] = _S659;
                break;
            }
        case 4U:
            {
                float _S660 = sheenVelvetPDF(_S628, (F32_abs((_S625))), w_13);
                (*pdfs_0)[int(3)] = _S660;
                float3  _S661 = sheenVelvetBSDF(out_dir_2, _S624, _S627, material_9, w_13);
                (*throughputs_0)[int(3)] = _S661;
                break;
            }
        case 6U:
            {
                ToonProfile _S662 = toonProfile(_S624, _S627, material_9);
                float _S663 = toonPDF(out_dir_2, _S627, _S662, w_13);
                (*pdfs_0)[int(4)] = _S663;
                float3  _S664 = toonBSDF(out_dir_2, _S627, _S662, w_13);
                (*throughputs_0)[int(4)] = _S664;
                break;
            }
        default:
            {
                float _S665 = vndfPDF(_S624, ggx_n_1, _S627, (F32_abs((_S625))), _S630, _S631, w_13.v_dot_h);
                float _S666 = reflectPDF(_S665, w_13);
                (*pdfs_0)[int(2)] = _S666;
                float3  _S667 = reflectBSDF(out_dir_2, _S627, _S630, _S631, w_13);
                (*throughputs_0)[int(2)] = _S667;
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
    ggx_n_1 = _S639;
    for(;;)
    {
        if(i_7 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S668 = ((*pdfs_0)[i_7]) > 0.0f;
        if(_S668)
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
    bool _S669 = wrongSide_0(is_inside_2, false, dir_4, surface_1->geometry_n);
    float3  _S670 = BSDF(in_dir_4, dir_4, surface_1->smooth_n, surface_1->material, eta_1.x, eta_1.y, _S669, random_state_5, terms_0, pdfs_1);
    float3  _S671 = make_float3 (0.0f);
    uint i_11 = 0U;
    float3  f_3 = _S671;
    for(;;)
    {
        if(i_11 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S672 = ((*pdfs_1)[i_11]) > 0.0f;
        if(_S672)
        {
            float3  _S673 = (*terms_0)[i_11] * make_float3 ((*pdfs_1)[i_11]) / make_float3 ((*pdfs_1)[i_11] + pdf_0);
            (*terms_0)[i_11] = _S673;
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
    FKSurface _S674 = surface_2;
    FixedArray<float3 , 5>  terms_1;
    FixedArray<float, 5>  pdfs_2;
    float3  _S675 = skyLobes_0(in_dir_5, dir_5, &_S674, eta_2, is_inside_3, pdf_1, random_state_6, &terms_1, &pdfs_2);
    return _S675;
}

static __device__ SkySample SkySample_x24init_0(float3  dir_6, float3  radiance_0, float3  color_0, uint random_state_7)
{
    SkySample _S676;
    (&_S676)->dir = dir_6;
    (&_S676)->radiance = radiance_0;
    (&_S676)->color = color_0;
    (&_S676)->random_state = random_state_7;
    return _S676;
}

static __device__ SkySample sampleSky_0(FKRay * ray_0, FKSurface * surface_3, float2  eta_3, bool is_inside_4, uint init_random_state_0, uint lobe_state_0, ShadowContext * context_2)
{
    uint2  _S677 = (fcptEnvironmentCdfSize());
    uint2  _S678 = make_uint2 (1U, 0U);
    uint2  _S679 = _S677 - _S678;
    Random _S680 = pcg(init_random_state_0);
    Random _S681 = pcg(_S680.state);
    Random _S682 = pcg(_S681.state);
    Random _S683 = pcg(_S682.state);
    uint _S684 = _S679.x;
    uint _S685 = searchCDF_0(make_uint2 (_S684, 0U), make_uint2 (0U, 1U), _S679.y, _S680.value);
    uint _S686 = searchCDF_0(make_uint2 (0U, _S685), _S678, _S684, _S681.value);
    float2  _S687 = make_float2 ((float)_S679.x, (float)_S679.y);
    float2  _S688 = (make_float2 (float(_S686), float(_S685)) + make_float2 (_S682.value, _S683.value)) / _S687 * make_float2 (6.28318548202514648f, 3.14159274101257324f);
    float _S689 = _S688.y;
    float _S690 = (F32_sin((_S689)));
    float _S691 = _S688.x;
    float3  _S692 = skyFrame_0(make_float3 (_S690 * (F32_cos((_S691))), (F32_cos((_S689))), _S690 * (F32_sin((_S691)))));
    float _S693 = environmentPdf_0(_S692);
    float3  _S694 = skyBSDF(ray_0->unit_direction, _S692, *surface_3, eta_3, is_inside_4, _S693, lobe_state_0);
    bool _S695 = !(_S693 > 0.0f);
    bool _S696;
    if(_S695)
    {
        _S696 = true;
    }
    else
    {
        _S696 = all_1(_S694 == make_float3 (0.0f));
    }
    if(_S696)
    {
        float3  _S697 = make_float3 (0.0f);
        return SkySample_x24init_0(_S692, _S697, _S697, _S683.state);
    }
    float3  _S698 = skyRadiance_0(ray_0->origin, surface_3, is_inside_4, _S692, context_2, _S683.state);
    return SkySample_x24init_0(_S692, _S698, _S694 * _S698, _S683.state);
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

static __device__ float3  hairLight_0(FKSurface * surface_4, float3  in_dir_6, TreeSample * light_1, bool competing_0)
{
    SampleBSDF _S699 = (fcptConnectHair((surface_4->hair), ((&surface_4->material)->albedo), ((&surface_4->material)->specular_tint), (in_dir_6), (light_1->dir)));
    float3  _S700 = _S699.throughput * make_float3 (_S699.pdf);
    float _S701 = light_1->density;
    float _S702 = 1.0f + _S699.pdf * _S699.pdf / (light_1->density * light_1->density);
    bool _S703;
    if(competing_0)
    {
        _S703 = _S701 > 0.0f;
    }
    else
    {
        _S703 = false;
    }
    float _S704 = _slang_select(_S703, _S702,1.0f);
    return _S700 / make_float3 (_S704) * light_1->radiance;
}

static __device__ TreeSample TreeSample_x24init_0(float3  dir_7, float3  radiance_1, float density_0, uint random_state_8)
{
    TreeSample _S705;
    (&_S705)->dir = dir_7;
    (&_S705)->radiance = radiance_1;
    (&_S705)->density = density_0;
    (&_S705)->random_state = random_state_8;
    return _S705;
}

__device__ uint pickChild(LightNode first_1, LightNode second_1, float3  p_13, float3  normal_3, float * pick_0, float * probability_3)
{
    float _S706 = importance(first_1, p_13, normal_3);
    float _S707 = importance(second_1, p_13, normal_3);
    float2  _S708 = make_float2 (_S706, _S707);
    bool _S709 = _S706 == 0.0f;
    bool _S710;
    if(_S709)
    {
        _S710 = _S707 == 0.0f;
    }
    else
    {
        _S710 = false;
    }
    if(_S710)
    {
        return 2U;
    }
    float _S711 = _S706 + _S707;
    bool _S712 = _S707 > 0.0f;
    if(_S712)
    {
        _S710 = (*pick_0 * _S711) >= _S706;
    }
    else
    {
        _S710 = false;
    }
    uint _S713 = uint(_S710);
    float _S714 = (F32_min(((*pick_0 * _S711 - float(_S713) * _S706) / _slang_vector_get_element(_S708, _S713)), (0.99999994039535522f)));
    *pick_0 = _S714;
    float _S715 = *probability_3 * (_slang_vector_get_element(_S708, _S713) / _S711);
    *probability_3 = _S715;
    return _S713;
}

__device__ float3  sampleSphere(float3  center_1, float radius_1, float3  p_14, float u1_0, float u2_0)
{
    float3  _S716 = center_1 - p_14;
    float _S717 = radius_1 * radius_1 / dot_0(_S716, _S716);
    float _S718 = u1_0 * _S717 / (1.0f + (F32_sqrt(((F32_max((1.0f - _S717), (0.0f)))))));
    float _S719 = 2.0f * u1_0;
    bool _S720 = _S717 >= 1.0f;
    float _S721 = _slang_select(_S720, _S719,_S718);
    float _S722 = (F32_sqrt(((F32_max((_S721 * (2.0f - _S721)), (0.0f))))));
    float _S723 = 6.28318548202514648f * u2_0;
    float3  _S724 = make_float3 (_S722 * (F32_cos((_S723))), 1.0f - _S721, _S722 * (F32_sin((_S723))));
    float3  _S725 = ((((_S716)) * make_float3(rnorm3df(((_S716)).x, ((_S716)).y, ((_S716)).z))));
    float3  _S726 = tangentToWorld(_S724, _S725);
    return _S726;
}

__device__ float3  pointLightRadiance(float3  color_1, float intensity_0, float radius_2)
{
    return color_1 * make_float3 (intensity_0) / make_float3 (3.14159274101257324f * radius_2 * radius_2);
}

static __device__ float raySphere_0(float3  center_2, float radius_3, FKRay * ray_1, float max_len_0)
{
    float3  _S727 = center_2 - ray_1->origin;
    float _S728 = dot_0(_S727, ray_1->unit_direction);
    float _S729 = dot_0(_S727, _S727) - _S728 * _S728;
    float _S730 = radius_3 * radius_3;
    bool _S731 = _S729 > _S730;
    if(_S731)
    {
        return 4.294967296e+09f;
    }
    float _S732 = (F32_sqrt((_S730 - _S729)));
    float _S733 = _S728 - _S732;
    float _S734 = _S728 + _S732;
    bool _S735 = _S733 > 0.0000152587890625f;
    bool _S736;
    if(_S735)
    {
        _S736 = _S733 < max_len_0;
    }
    else
    {
        _S736 = false;
    }
    if(_S736)
    {
        return _S733;
    }
    bool _S737 = _S734 > 0.0000152587890625f;
    if(_S737)
    {
        _S736 = _S734 < max_len_0;
    }
    else
    {
        _S736 = false;
    }
    if(_S736)
    {
        return _S734;
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

static __device__ float3  emitted_0(float3  emissive_0, float3  dir_8, float3  n_7)
{
    float _S738 = sign_0(dot_0(- dir_8, n_7));
    float3  _S739 = emissive_0 * make_float3 ((F32_max((_S738), (0.0f))));
    bool _S740 = ((true));
    float3  _S741 = _slang_select(_S740, emissive_0,_S739);
    return _S741;
}

static __device__ __forceinline__ TreeSample sampleLightTree_0(float3  origin_4, float3  smooth_n_2, float3  geometry_n_1, float geometry_offset_1, bool sided_0, uint init_random_state_1, ShadowContext * context_3)
{
    Random _S742 = pcg(init_random_state_1);
    Random _S743 = pcg(_S742.state);
    Random _S744 = pcg(_S743.state);
    float3  _S745 = make_float3 (0.0f);
    TreeSample _S746 = TreeSample_x24init_0(_S745, _S745, 0.0f, _S744.state);
    TreeSample sample_0 = _S746;
    float3  _S747 = _slang_select(sided_0, _S745,smooth_n_2);
    float3  _S748 = origin_4 + make_float3 (geometry_offset_1) * smooth_n_2;
    float pick_1 = _S742.value;
    float probability_4 = 1.0f;
    uint n_8 = 0U;
    for(;;)
    {
        uint4  _S749 = (fcptLightNode((n_8)));
        if((_S749.x) == 0U)
        {
        }
        else
        {
            break;
        }
        uint _S750 = (fcptLightSecond((n_8)));
        uint _S751 = n_8 + 1U;
        LightNode _S752 = (fcptLightBounds((_S751)));
        LightNode _S753 = (fcptLightBounds((_S750)));
        uint _S754 = pickChild(_S752, _S753, origin_4, _S747, &pick_1, &probability_4);
        bool _S755 = _S754 > 1U;
        if(_S755)
        {
            return sample_0;
        }
        bool _S756 = _S754 == 1U;
        uint _S757 = _slang_select(_S756, _S750,_S751);
        n_8 = _S757;
    }
    bool _S758 = n_8 == 0U;
    bool _S759;
    if(_S758)
    {
        LightNode _S760 = (fcptLightBounds((0U)));
        float _S761 = importance(_S760, origin_4, _S747);
        _S759 = !(_S761 > 0.0f);
    }
    else
    {
        _S759 = false;
    }
    if(_S759)
    {
        return sample_0;
    }
    uint4  _S762 = (fcptLightNode((n_8)));
    FKHit _S763 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
    bool _S764 = (_S762.x) == 2U;
    float3  emitter_point_0;
    float3  lift_n_0;
    float3  shadow_1;
    FKHit emitter_0;
    if(_S764)
    {
        FKLight _S765 = (fcptLight((_S762.y)));
        if(sided_0)
        {
            float _S766 = sign_0(dot_0(geometry_n_1, _S765.position - origin_4));
            float3  lift_n_1 = smooth_n_2 * make_float3 (_S766);
            float3  _S767 = origin_4 + make_float3 (geometry_offset_1) * lift_n_1;
            emitter_point_0 = _S767;
            lift_n_0 = lift_n_1;
        }
        else
        {
            emitter_point_0 = _S748;
            lift_n_0 = smooth_n_2;
        }
        bool _S768 = (_S765.variance) == 0.0f;
        if(_S768)
        {
            float3  _S769 = _S765.position - emitter_point_0;
            float3  _S770 = ((((_S769)) * make_float3(rnorm3df(((_S769)).x, ((_S769)).y, ((_S769)).z))));
            (&sample_0)->dir = _S770;
            float3  _S771 = _S765.color * make_float3 (_S765.intensity) / make_float3 (dot_0(_S769, _S769) * probability_4);
            (&sample_0)->radiance = _S771;
            shadow_1 = _S769;
        }
        else
        {
            float3  _S772 = sampleSphere(_S765.position, _S765.variance, emitter_point_0, _S743.value, _S744.value);
            (&sample_0)->dir = _S772;
            float _S773 = sphereDensity(_S765.position, _S765.variance, emitter_point_0);
            float _S774 = probability_4 * _S773;
            (&sample_0)->density = _S774;
            float3  _S775 = pointLightRadiance(_S765.color, _S765.intensity, _S765.variance);
            float3  _S776 = _S775 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S776;
            FKRay _S777 = Ray_x24init_0(emitter_point_0, (&sample_0)->dir);
            float _S778 = raySphere_0(_S765.position, _S765.variance, &_S777, 4.294967296e+09f);
            float3  _S779 = (&sample_0)->dir * make_float3 (_S778);
            shadow_1 = _S779;
        }
        emitter_0 = _S763;
        emitter_point_0 = _S745;
    }
    else
    {
        uint _S780 = _S762.y;
        uint _S781 = (fcptTriangleOffset((_S780)));
        uint _S782 = _S781 + _S762.z;
        Matrix<float, 3, 3>  _S783 = (fcptWorldTriangle((_S780), (_S782)));
        float _S784 = (F32_sqrt((_S743.value)));
        float2  _S785 = make_float2 (_S784 * (1.0f - _S744.value), _S784 * _S744.value);
        float3  _S786 = mul_0(make_float3 (1.0f - _S784, _S785.x, _S785.y), _S783);
        if(sided_0)
        {
            float _S787 = sign_0(dot_0(geometry_n_1, _S786 - origin_4));
            float3  lift_n_2 = smooth_n_2 * make_float3 (_S787);
            float3  _S788 = origin_4 + make_float3 (geometry_offset_1) * lift_n_2;
            emitter_point_0 = _S788;
            lift_n_0 = lift_n_2;
        }
        else
        {
            bool _S789 = !((dot_0(smooth_n_2, _S786 - origin_4)) > 0.0f);
            if(_S789)
            {
                return sample_0;
            }
            emitter_point_0 = _S748;
            lift_n_0 = smooth_n_2;
        }
        FKHit emitter_1 = Hit_x24init_0(_S785, _S780, _S782, 0U, 0.0f);
        float3  _S790 = _S786 - emitter_point_0;
        float3  _S791 = ((((_S790)) * make_float3(rnorm3df(((_S790)).x, ((_S790)).y, ((_S790)).z))));
        (&sample_0)->dir = _S791;
        float _S792 = solidAngle(probability_4, cross_0(_S783.rows[int(1)] - _S783.rows[int(0)], _S783.rows[int(2)] - _S783.rows[int(0)]), _S790);
        (&sample_0)->density = _S792;
        bool _S793 = (fcptShadowFirst());
        bool _S794 = !_S793;
        if(_S794)
        {
            FKSurface _S795 = (fcptLightSurfaceAt((emitter_1), (_S786), (_S744.state), ((&sample_0)->dir), (context_3->depth), (length_0(_S786 - origin_4))));
            (&sample_0)->random_state = _S795.random_state;
            float3  _S796 = emitted_0(_S795.material.emissive, (&sample_0)->dir, _S795.smooth_n);
            float3  _S797 = _slang_select(_S795.skip, _S745,_S796);
            float3  _S798 = _S797 / make_float3 ((&sample_0)->density);
            (&sample_0)->radiance = _S798;
        }
        shadow_1 = _S790;
        emitter_0 = emitter_1;
        emitter_point_0 = _S786;
    }
    FKHit _S799 = emitter_0;
    float3  _S800 = lightTransmittance_0(origin_4, lift_n_0, geometry_offset_1, shadow_1, context_3, _S744.state, &_S799);
    bool _S801 = (fcptShadowFirst());
    if(_S801)
    {
        _S759 = (emitter_0.instance_index) != 4294967295U;
    }
    else
    {
        _S759 = false;
    }
    if(_S759)
    {
        _S759 = !all_1(_S800 == _S745);
    }
    else
    {
        _S759 = false;
    }
    if(_S759)
    {
        FKSurface _S802 = (fcptLightSurfaceAt((emitter_0), (emitter_point_0), (_S744.state), ((&sample_0)->dir), (context_3->depth), (length_0(emitter_point_0 - origin_4))));
        (&sample_0)->random_state = _S802.random_state;
        float3  _S803 = emitted_0(_S802.material.emissive, (&sample_0)->dir, _S802.smooth_n);
        float3  _S804 = _slang_select(_S802.skip, _S745,_S803);
        float3  _S805 = _S804 / make_float3 ((&sample_0)->density);
        (&sample_0)->radiance = _S805;
    }
    float3  _S806 = (&sample_0)->radiance * _S800;
    bool _S807 = all_1(_S800 == _S745);
    float3  _S808 = _slang_select(_S807, _S745,_S806);
    (&sample_0)->radiance = _S808;
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
    float _S809 = 1.0f / (1.0f + b_2 / a_8 * (b_2 / a_8));
    bool _S810 = b_2 > 0.0f;
    float _S811 = _slang_select(_S810, _S809,1.0f);
    return _S811;
}

static __device__ float emissionWeight_0(NEEVertex * vertex_0, FKHit * hit_1, float3  light_point_1)
{
    bool _S812 = vertex_0->none;
    if(_S812)
    {
        return 1.0f;
    }
    uint _S813 = (fcptLightSlot((*hit_1)));
    float _S814 = lightPdf_0(vertex_0->origin, vertex_0->smooth_n, vertex_0->start, _S813, light_point_1);
    float _S815 = powerHeuristic(vertex_0->pdf, _S814);
    return _S815;
}

static __device__ float3  environment_0(float3  dir_9, uint depth_0, uint lobe_0)
{
    uint2  _S816 = (fcptEnvironmentMapSize());
    bool _S817 = all_0(_S816 > make_uint2 (1U));
    if(_S817)
    {
        float3  _S818 = (fcptEnvMapSample((dir_9), (depth_0), (lobe_0)));
        return _S818;
    }
    float3  _S819 = (fcptAmbient());
    return _S819;
}

static __device__ bool environmentMapped_0()
{
    uint2  _S820 = (fcptEnvironmentCdfSize());
    bool _S821 = !all_0(_S820 > make_uint2 (1U));
    if(_S821)
    {
        return false;
    }
    uint2  _S822 = (fcptEnvironmentMapSize());
    return all_0(_S822 > make_uint2 (1U));
}

static __device__ float escapeWeight_0(float pdf_2, float3  dir_10)
{
    bool _S823 = pdf_2 <= 0.0f;
    bool _S824;
    if(_S823)
    {
        _S824 = true;
    }
    else
    {
        bool _S825 = environmentMapped_0();
        _S824 = !_S825;
    }
    if(_S824)
    {
        return 1.0f;
    }
    float _S826 = environmentPdf_0(dir_10);
    return pdf_2 / (pdf_2 + _S826);
}

static __device__ void restir_duplicates_0(uint3  global_invocation_id_1, uint3  local_invocation_id_0, uint local_invocation_index_3)
{
    uint2  _S827 = uint2 {global_invocation_id_1.x, global_invocation_id_1.y};
    int2  _S828 = make_int2 ((int)_S827.x, (int)_S827.y);
    uint _S829 = previousSeed_0(_S828);
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
            uint _S830 = previousSeed_0(_S828 + make_int2 (x_16, y_5));
            bool _S831 = _S830 == _S829;
            uint _S832 = _slang_select(_S831, 1U,0U);
            uint count_3 = count_2 + _S832;
            int x_17 = x_16 + int(1);
            x_16 = x_17;
            count_2 = count_3;
        }
        int y_6 = y_5 + int(1);
        y_5 = y_6;
    }
    float _S833 = float(count_2 - 1U) / 288.0f;
    bool _S834 = _S829 != 0U;
    float _S835 = _slang_select(_S834, _S833,0.0f);
    fcptStoreDuplication((_S828), (make_uint4 ((F32_asuint((_S835))), 0U, 0U, 0U)));
    return;
}

static __device__ float3  abs_0(float3  x_18)
{
    float3  result_7;
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
        *_slang_vector_get_element_ptr(&result_7, i_14) = (F32_abs((_slang_vector_get_element(x_18, i_14))));
        i_14 = i_14 + int(1);
    }
    return result_7;
}

__device__ float resamplingTarget(float3  f_5)
{
    float _S836 = rgb_to_greyscale(abs_0(f_5));
    return _S836;
}

__device__ uint stream(uint seed_3, uint index_0)
{
    uint _S837 = hash(index_0);
    uint _S838 = hash(seed_3 ^ _S837);
    return _S838;
}

static __device__ float4  asfloat_0(uint4  x_19)
{
    float4  result_8;
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
        *_slang_vector_get_element_ptr(&result_8, i_15) = (U32_asfloat((_slang_vector_get_element(x_19, i_15))));
        i_15 = i_15 + int(1);
    }
    return result_8;
}

__device__ void offer(Selection * sel_2, Reservoir candidate_0, float3  weight_0)
{
    float _S839 = resamplingTarget(weight_0);
    bool _S840 = _S839 > 0.0f;
    bool _S841;
    if(_S840)
    {
        _S841 = _S839 < 3.00000000549775576e+38f;
    }
    else
    {
        _S841 = false;
    }
    bool _S842 = !_S841;
    if(_S842)
    {
        return;
    }
    bool _S843 = sel_2->sums;
    if(_S843)
    {
        float3  _S844 = sel_2->color + weight_0;
        sel_2->color = _S844;
        return;
    }
    float _S845 = sel_2->w_sum + _S839;
    sel_2->w_sum = _S845;
    float3  _S846 = sel_2->color + weight_0;
    sel_2->color = _S846;
    Random _S847 = pcg(sel_2->random_state);
    sel_2->random_state = _S847.state;
    bool _S848 = (_S847.value * sel_2->w_sum) <= _S839;
    if(_S848)
    {
        sel_2->r = candidate_0;
    }
    return;
}

__device__ void offerShifted(Selection * sel_3, Reservoir r_3, Shift shifted_0, float mis_0)
{
    Reservoir candidate_1 = r_3;
    float3  _S849 = shifted_0.f / make_float3 (shifted_0.jac);
    (&candidate_1)->f = _S849;
    float _S850 = r_3.jac * shifted_0.jac;
    (&candidate_1)->jac = _S850;
    offer(sel_3, candidate_1, make_float3 (mis_0) * shifted_0.f * make_float3 (r_3.w));
    return;
}

__device__ Reservoir finalize(Selection sel_4, float c_1)
{
    Reservoir r_4 = sel_4.r;
    float _S851 = resamplingTarget((&r_4)->f);
    float _S852 = sel_4.w_sum / _S851;
    bool _S853 = _S851 > 0.0f;
    float _S854 = _slang_select(_S853, _S852,0.0f);
    (&r_4)->w = _S854;
    (&r_4)->c = c_1;
    return r_4;
}

static __device__ uint2  asuint_0(float2  x_20)
{
    uint2  result_9;
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
        *_slang_vector_get_element_ptr(&result_9, i_16) = (F32_asuint((_slang_vector_get_element(x_20, i_16))));
        i_16 = i_16 + int(1);
    }
    return result_9;
}

static __device__ void restir_spatial_0(uint3  global_invocation_id_2)
{
    uint2  _S855 = uint2 {global_invocation_id_2.x, global_invocation_id_2.y};
    int2  _S856 = make_int2 ((int)_S855.x, (int)_S855.y);
    float3  _S857 = make_float3 (0.0f);
    FKHit _S858 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S859 = Domain_x24init_0(_S857, _S857, &_S858, 0.0f, 0.0f);
    Domain dom_4 = _S859;
    bool _S860 = (fcptCurrentDomain((_S856), (&dom_4)));
    bool _S861 = !_S860;
    if(_S861)
    {
        Reservoir _S862 = (Reservoir{});
        fcptStoreReservoirPrevious((_S856), (_S862), ((&dom_4)->hit));
        return;
    }
    Reservoir _S863 = (fcptLoadReservoirTemporal((_S856)));
    uint t_15 = 0U;
    float count_4 = 0.0f;
    float c_sum_0 = _S863.c;
    for(;;)
    {
        uint _S864 = (fcptRestirNeighbours());
        if(t_15 < _S864)
        {
        }
        else
        {
            break;
        }
        int2  _S865 = partner_0(_S856, t_15);
        Domain neighbor_0 = _S859;
        bool _S866 = (fcptCurrentDomain((_S865), (&neighbor_0)));
        if(_S866)
        {
            float count_5 = count_4 + 1.0f;
            uint4  _S867 = (fcptReservoirTemporal((_S865), (0U)));
            float c_sum_1 = c_sum_0 + (U32_asfloat((_S867.w)));
            count_4 = count_5;
            c_sum_0 = c_sum_1;
        }
        uint t_16 = t_15 + 1U;
        t_15 = t_16;
    }
    float _S868 = _S863.c / (F32_max((count_4), (1.0f)));
    float _S869 = resamplingTarget(_S863.f);
    bool _S870 = count_4 == 0.0f;
    float _S871 = _slang_select(_S870, 1.0f,0.0f);
    Selection _S872 = (Selection{});
    Selection sel_5 = _S872;
    uint _S873 = (fcptFrame());
    uint _S874 = hash(_S873);
    uint _S875 = global_invocation_id_2.x;
    uint2  _S876 = (fcptRenderSize());
    uint _S877 = stream(_S874, _S875 + _S876.x * global_invocation_id_2.y);
    uint _S878 = stream(_S877, 195U);
    (&sel_5)->random_state = _S878;
    t_15 = 0U;
    float canonical_mis_0 = _S871;
    for(;;)
    {
        uint _S879 = (fcptRestirNeighbours());
        if(t_15 < _S879)
        {
        }
        else
        {
            break;
        }
        int2  _S880 = partner_0(_S856, t_15);
        Domain neighbor_dom_0 = _S859;
        bool _S881 = (fcptCurrentDomain((_S880), (&neighbor_dom_0)));
        if(_S881)
        {
            Reservoir _S882 = (fcptLoadReservoirTemporal((_S880)));
            uint4  _S883 = (fcptShiftData((_S880), (t_15)));
            float4  _S884 = asfloat_0(_S883);
            uint4  _S885 = (fcptShiftData((_S856), (t_15)));
            float4  _S886 = asfloat_0(_S885);
            float _S887 = (_S882.c + _S868) / c_sum_0;
            bool _S888 = _S869 > 0.0f;
            float canonical_mis_1;
            if(_S888)
            {
                float _S889 = _S887 * _S868 * _S869;
                float _S890 = _S868 * _S869;
                float _S891 = resamplingTarget(float3 {_S886.x, _S886.y, _S886.z});
                float canonical_mis_2 = canonical_mis_0 + _S889 / (_S890 + _S882.c * _S891);
                canonical_mis_1 = canonical_mis_2;
            }
            else
            {
                canonical_mis_1 = canonical_mis_0;
            }
            float _S892 = resamplingTarget(_S882.f);
            float3  _S893 = float3 {_S884.x, _S884.y, _S884.z};
            Shift _S894 = Shift_x24init_0(_S893, _S884.w);
            float _S895 = _S887 * _S882.c * _S892;
            float _S896 = _S882.c * _S892;
            float _S897 = resamplingTarget(_S893);
            offerShifted(&sel_5, _S882, _S894, _S895 / (_S896 + _S868 * _S897));
            canonical_mis_0 = canonical_mis_1;
        }
        uint t_17 = t_15 + 1U;
        t_15 = t_17;
    }
    offerShifted(&sel_5, _S863, Shift_x24init_0(_S863.f, 1.0f), canonical_mis_0);
    Reservoir _S898 = finalize(sel_5, c_sum_0);
    fcptStoreReservoirPrevious((_S856), (_S898), ((&dom_4)->hit));
    fcptStorePreviousLayer((_S856), (5U), (make_uint4 (asuint_0((&(&dom_4)->hit)->uv).x, asuint_0((&(&dom_4)->hit)->uv).y, 0U, 0U)));
    fcptAddColor((_S856), (make_float4 ((&sel_5)->color.x, (&sel_5)->color.y, (&sel_5)->color.z, 0.0f)));
    return;
}

static __device__ uint3  asuint_1(float3  x_21)
{
    uint3  result_10;
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
        *_slang_vector_get_element_ptr(&result_10, i_17) = (F32_asuint((_slang_vector_get_element(x_21, i_17))));
        i_17 = i_17 + int(1);
    }
    return result_10;
}

static __device__ void restir_shift_0(uint3  workgroup_id_1, uint local_invocation_index_4)
{
    uint _S899 = queuedShift_0(workgroup_id_1, local_invocation_index_4);
    bool _S900 = _S899 != 4294967295U;
    if(_S900)
    {
        uint2  _S901 = make_uint2 (_S899, _S899 >> 14U) & make_uint2 (16383U);
        int2  _S902 = make_int2 ((int)_S901.x, (int)_S901.y);
        ShiftJob _S903 = (ShiftJob{});
        ShiftJob shift_job_0 = _S903;
        Shift _S904 = Shift_x24init_0(make_float3 (0.0f), 0.0f);
        uint _S905 = _S899 >> 28U;
        bool _S906 = spatialJob_0(_S902, _S905, &shift_job_0, true);
        Shift shifted_1;
        if(_S906)
        {
            Domain _S907 = (&shift_job_0)->dom;
            Reservoir _S908 = (&shift_job_0)->r;
            Shift _S909 = passShift_0(&_S907, &_S908);
            shifted_1 = _S909;
        }
        else
        {
            shifted_1 = _S904;
        }
        fcptStoreShiftData((_S902), (_S905), (make_uint4 (asuint_1(shifted_1.f).x, asuint_1(shifted_1.f).y, asuint_1(shifted_1.f).z, (F32_asuint((shifted_1.jac))))));
    }
    return;
}

static __device__ void restir_prepass_0(uint3  global_invocation_id_3, uint local_invocation_index_5)
{
    uint2  _S910 = uint2 {global_invocation_id_3.x, global_invocation_id_3.y};
    int2  _S911 = make_int2 ((int)_S910.x, (int)_S910.y);
    FixedArray<uint, 3>  _S912;
    spatialBins_0(_S911, &_S912);
    FixedArray<uint, 3>  _S913 = _S912;
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
        bool _S914 = (_S913[t_18]) == 40U;
        if(_S914)
        {
            fcptStoreShiftData((_S911), (t_18), (make_uint4 (0U)));
        }
        uint t_19 = t_18 + 1U;
        t_18 = t_19;
    }
    FixedArray<uint, 3>  _S915 = _S913;
    queueShifts_0(_S911, &_S915, global_invocation_id_3, local_invocation_index_5);
    return;
}

static __device__ void restir_count_0(uint3  global_invocation_id_4, uint local_invocation_index_6)
{
    uint2  _S916 = uint2 {global_invocation_id_4.x, global_invocation_id_4.y};
    int2  _S917 = make_int2 ((int)_S916.x, (int)_S916.y);
    FixedArray<uint, 3>  _S918;
    spatialBins_0(_S917, &_S918);
    FixedArray<uint, 3>  _S919 = _S918;
    countShifts_0(&_S919, local_invocation_index_6);
    return;
}

static __device__ void restir_temporal_shift_0(uint3  workgroup_id_2, uint local_invocation_index_7)
{
    uint _S920 = queuedShift_0(workgroup_id_2, local_invocation_index_7);
    bool _S921 = _S920 != 4294967295U;
    if(_S921)
    {
        uint2  _S922 = make_uint2 (_S920, _S920 >> 14U) & make_uint2 (16383U);
        int2  _S923 = make_int2 ((int)_S922.x, (int)_S922.y);
        int2  _S924 = storedNeighbor_0(_S923);
        uint _S925 = _S920 >> 28U;
        Shift _S926 = temporalShiftAt_0(_S923, _S924, _S925);
        fcptStoreTemporalShift((_S923), (_S925), (make_uint4 (asuint_1(_S926.f).x, asuint_1(_S926.f).y, asuint_1(_S926.f).z, (F32_asuint((_S926.jac))))));
    }
    return;
}

static __device__ void restir_temporal_prepass_0(uint3  global_invocation_id_5, uint local_invocation_index_8)
{
    uint2  _S927 = uint2 {global_invocation_id_5.x, global_invocation_id_5.y};
    int2  _S928 = make_int2 ((int)_S927.x, (int)_S927.y);
    FixedArray<uint, 3>  _S929;
    temporalBins_0(_S928, &_S929);
    FixedArray<uint, 3>  _S930 = _S929;
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
        bool _S931 = (_S930[t_20]) == 40U;
        if(_S931)
        {
            fcptStoreTemporalShift((_S928), (t_20), (make_uint4 (0U)));
        }
        uint t_21 = t_20 + 1U;
        t_20 = t_21;
    }
    FixedArray<uint, 3>  _S932 = _S930;
    queueShifts_0(_S928, &_S932, global_invocation_id_5, local_invocation_index_8);
    return;
}

static __device__ void restir_temporal_count_0(uint3  global_invocation_id_6, uint local_invocation_index_9)
{
    uint2  _S933 = uint2 {global_invocation_id_6.x, global_invocation_id_6.y};
    int2  _S934 = make_int2 ((int)_S933.x, (int)_S933.y);
    bool _S935 = (fcptSceneUnchanged());
    bool _S936 = !_S935;
    bool _S937;
    if(_S936)
    {
        uint2  _S938 = (fcptRenderSize());
        int2  _S939 = make_int2 ((int)_S938.x, (int)_S938.y);
        _S937 = all_0(_S934 < _S939);
    }
    else
    {
        _S937 = false;
    }
    if(_S937)
    {
        Reservoir _S940 = (fcptLoadReservoirInitial((_S934)));
        int2  _S941 = sampleNeighbor_0(_S934, _S940.seed);
        fcptStoreTemporalNeighbor((_S934), (_S941));
    }
    FixedArray<uint, 3>  _S942;
    temporalBins_0(_S934, &_S942);
    FixedArray<uint, 3>  _S943 = _S942;
    countShifts_0(&_S943, local_invocation_index_9);
    return;
}

static __device__ float interpolate_0(float a_9, float b_3, float t_22)
{
    return a_9 + (b_3 - a_9) * t_22;
}

static __device__ void restir_temporal_0(uint3  global_invocation_id_7)
{
    uint2  _S944 = uint2 {global_invocation_id_7.x, global_invocation_id_7.y};
    int2  _S945 = make_int2 ((int)_S944.x, (int)_S944.y);
    float3  _S946 = make_float3 (0.0f);
    FKHit _S947 = Hit_x24init_0(make_float2 (0.0f), 0U, 0U, 0U, 0.0f);
    Domain _S948 = Domain_x24init_0(_S946, _S946, &_S947, 0.0f, 0.0f);
    Domain dom_5 = _S948;
    bool _S949 = (fcptCurrentDomain((_S945), (&dom_5)));
    bool _S950 = !_S949;
    if(_S950)
    {
        Reservoir _S951 = (Reservoir{});
        fcptStoreReservoirTemporal((_S945), (_S951), ((&dom_5)->hit));
        return;
    }
    Reservoir _S952 = (fcptLoadReservoirInitial((_S945)));
    bool _S953 = (fcptTemporalQueued());
    bool _S954 = (fcptSceneUnchanged());
    bool _S955;
    if(_S954)
    {
        _S955 = true;
    }
    else
    {
        _S955 = !_S953;
    }
    int2  _S956;
    if(_S955)
    {
        int2  _S957 = sampleNeighbor_0(_S945, _S952.seed);
        _S956 = _S957;
    }
    else
    {
        int2  _S958 = storedNeighbor_0(_S945);
        _S956 = _S958;
    }
    bool _S959 = (_S956.x) >= int(0);
    Reservoir r_5;
    if(_S959)
    {
        Reservoir _S960 = (fcptLoadReservoirPrevious((_S956)));
        uint4  _S961 = (fcptDuplication((_S956)));
        float _S962 = (U32_asfloat((_S961.x)));
        uint _S963 = (fcptRestirDecorrelation());
        bool _S964 = _S963 == 1U;
        float _S965 = _slang_select(_S964, _S962,0.0f);
        float _S966 = interpolate_0(20.0f, 1.0f, (F32_pow((_S965), (0.10000000149011612f))));
        float _S967 = (F32_min((_S960.c), (_S966)));
        bool _S968 = (fcptSceneUnchanged());
        float4  _S969 = make_float4 (_S960.f.x, _S960.f.y, _S960.f.z, 1.0f);
        bool _S970 = !_S968;
        if(_S970)
        {
            _S955 = _S953;
        }
        else
        {
            _S955 = false;
        }
        float4  to_current_0;
        if(_S955)
        {
            uint4  _S971 = (fcptTemporalShift((_S945), (0U)));
            float4  _S972 = asfloat_0(_S971);
            to_current_0 = _S972;
        }
        else
        {
            if(_S970)
            {
                Shift _S973 = temporalShiftAt_0(_S945, _S956, 0U);
                float4  _S974 = make_float4 (_S973.f.x, _S973.f.y, _S973.f.z, _S973.jac);
                to_current_0 = _S974;
            }
            else
            {
                to_current_0 = _S969;
            }
        }
        Domain own_1 = _S948;
        if(_S968)
        {
            _S955 = true;
        }
        else
        {
            bool _S975 = (fcptPreviousScenes());
            bool _S976 = !_S975;
            if(_S976)
            {
                _S955 = (_S952.w) > 0.0f;
            }
            else
            {
                _S955 = false;
            }
            if(_S955)
            {
                bool _S977 = (fcptStoredDomainInitial((_S945), (_S952.seed), (&own_1)));
                _S955 = _S977;
            }
            else
            {
                _S955 = false;
            }
            if(_S955)
            {
                Domain _S978 = (fcptPreviousDomain((_S956), (_S952.seed)));
                Domain _S979 = _S978;
                Domain _S980 = own_1;
                bool _S981 = sameDomain_0(&_S979, &_S980);
                _S955 = _S981;
            }
            else
            {
                _S955 = false;
            }
        }
        float4  _S982 = make_float4 (_S952.f.x, _S952.f.y, _S952.f.z, 1.0f);
        bool _S983 = !_S955;
        if(_S983)
        {
            _S955 = _S953;
        }
        else
        {
            _S955 = false;
        }
        float4  to_previous_0;
        if(_S955)
        {
            uint4  _S984 = (fcptTemporalShift((_S945), (1U)));
            float4  _S985 = asfloat_0(_S984);
            to_previous_0 = _S985;
        }
        else
        {
            if(_S983)
            {
                Shift _S986 = temporalShiftAt_0(_S945, _S956, 1U);
                float4  _S987 = make_float4 (_S986.f.x, _S986.f.y, _S986.f.z, _S986.jac);
                to_previous_0 = _S987;
            }
            else
            {
                to_previous_0 = _S982;
            }
        }
        float _S988 = resamplingTarget(_S952.f);
        float _S989 = resamplingTarget(_S960.f);
        Selection _S990 = (Selection{});
        Selection sel_6 = _S990;
        uint _S991 = (fcptFrame());
        uint _S992 = hash(_S991);
        uint _S993 = global_invocation_id_7.x;
        uint2  _S994 = (fcptRenderSize());
        uint _S995 = stream(_S992, _S993 + _S994.x * global_invocation_id_7.y);
        uint _S996 = stream(_S995, 194U);
        (&sel_6)->random_state = _S996;
        float _S997 = _S952.c * _S988;
        float4  _S998 = to_previous_0;
        float _S999 = resamplingTarget(float3 {_S998.x, _S998.y, _S998.z});
        float _S1000 = _S997 / (_S997 + _S967 * _S999);
        float _S1001 = _S967 * _S989;
        float4  _S1002 = to_current_0;
        float3  _S1003 = float3 {_S1002.x, _S1002.y, _S1002.z};
        float _S1004 = resamplingTarget(_S1003);
        float _S1005 = _S1001 / (_S1001 + _S952.c * _S1004);
        float2  _S1006 = make_float2 (_S1000, _S1005);
        offerShifted(&sel_6, _S952, Shift_x24init_0(_S952.f, 1.0f), _S1000);
        offerShifted(&sel_6, _S960, Shift_x24init_0(_S1003, to_current_0.w), _S1005);
        Reservoir _S1007 = finalize(sel_6, _S952.c + _S967);
        r_5 = _S1007;
    }
    else
    {
        r_5 = _S952;
    }
    fcptStoreReservoirTemporal((_S945), (r_5), ((&dom_5)->hit));
    return;
}

static __device__ void restir_initial_0(uint3  global_invocation_id_8)
{
    uint2  _S1008 = uint2 {global_invocation_id_8.x, global_invocation_id_8.y};
    int2  _S1009 = make_int2 ((int)_S1008.x, (int)_S1008.y);
    float3  _S1010 = make_float3 (0.0f);
    float2  _S1011 = make_float2 (0.0f);
    FKHit _S1012 = Hit_x24init_0(_S1011, 0U, 0U, 0U, 0.0f);
    Domain _S1013 = Domain_x24init_0(_S1010, _S1010, &_S1012, 0.0f, 0.0f);
    Domain dom_6 = _S1013;
    bool _S1014 = (fcptCurrentDomain((_S1009), (&dom_6)));
    bool _S1015 = !_S1014;
    if(_S1015)
    {
        Reservoir _S1016 = (Reservoir{});
        fcptStoreReservoirInitial((_S1009), (_S1016), ((&dom_6)->hit));
        return;
    }
    uint _S1017 = (fcptFrame());
    uint _S1018 = hash(_S1017);
    uint _S1019 = global_invocation_id_8.x;
    uint2  _S1020 = (fcptRenderSize());
    uint _S1021 = stream(_S1018, _S1019 + _S1020.x * global_invocation_id_8.y);
    Selection _S1022 = (Selection{});
    Selection initial_0 = _S1022;
    uint _S1023 = stream(_S1021, 193U);
    (&initial_0)->random_state = _S1023;
    bool _S1024 = (fcptRestirUsed());
    bool _S1025 = !_S1024;
    (&initial_0)->sums = _S1025;
    uint _S1026 = stream(_S1021, 0U);
    (&(&initial_0)->r)->seed = _S1026;
    FKHit _S1027 = Hit_x24init_0(_S1011, 4294967295U, 0U, 0U, 0.0f);
    uint _S1028 = (fcptSamples());
    float _S1029 = 1.0f / float(_S1028);
    FKHit hit_2 = _S1027;
    uint i_18 = 0U;
    float3  seen_0 = _S1010;
    for(;;)
    {
        uint _S1030 = (fcptSamples());
        if(i_18 < _S1030)
        {
        }
        else
        {
            break;
        }
        Reservoir _S1031 = (Reservoir{});
        Reservoir r_6 = _S1031;
        uint _S1032 = stream(_S1021, i_18);
        (&r_6)->seed = _S1032;
        Domain path_0 = _S1013;
        bool _S1033 = (fcptStoredDomainInitial((_S1009), ((&r_6)->seed), (&path_0)));
        bool _S1034 = !_S1033;
        if(_S1034)
        {
            float3  _S1035 = (fcptMissed((_S1009), (path_0), (_S1029)));
            float3  seen_1 = seen_0 + _S1035;
            seen_0 = seen_1;
            uint i_19 = i_18 + 1U;
            i_18 = i_19;
            continue;
        }
        Domain _S1036 = path_0;
        Reservoir _S1037 = r_6;
        Shift _S1038 = passWalk_0(&_S1036, &_S1037, false, _S1029, &initial_0);
        bool _S1039 = ((&(&initial_0)->r)->seed) == ((&r_6)->seed);
        FKHit hit_3;
        if(_S1039)
        {
            FKHit _S1040 = (&path_0)->hit;
            hit_3 = _S1040;
        }
        else
        {
            hit_3 = hit_2;
        }
        hit_2 = hit_3;
        uint i_19 = i_18 + 1U;
        i_18 = i_19;
    }
    uint _S1041 = (fcptSamples());
    float3  seen_2 = seen_0 + (&initial_0)->glow / make_float3 (float(_S1041));
    float3  _S1042 = seen_2 + (&initial_0)->color;
    bool _S1043 = (&initial_0)->sums;
    float3  _S1044 = _slang_select(_S1043, _S1042,seen_2);
    fcptAddColor((_S1009), (make_float4 (_S1044.x, _S1044.y, _S1044.z, 1.0f)));
    Reservoir _S1045 = finalize(initial_0, 1.0f);
    fcptStoreReservoirInitial((_S1009), (_S1045), (hit_2));
    return;
}

static __device__ NEEVertex NEEVertex_x24init_0(bool none_0, float pdf_3, float3  origin_5, float3  smooth_n_3, float3  start_6)
{
    NEEVertex _S1046;
    (&_S1046)->none = none_0;
    (&_S1046)->pdf = pdf_3;
    (&_S1046)->origin = origin_5;
    (&_S1046)->smooth_n = smooth_n_3;
    (&_S1046)->start = start_6;
    return _S1046;
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
    Vertex _S1047;
    (&_S1047)->rough = rough_0;
    (&_S1047)->lobe = lobe_1;
    (&_S1047)->pdf = pdf_4;
    (&_S1047)->cos = cos_0;
    (&_S1047)->inside = inside_0;
    return _S1047;
}

static __device__ float3  exp_0(float3  x_22)
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
        *_slang_vector_get_element_ptr(&result_11, i_20) = (F32_exp((_slang_vector_get_element(x_22, i_20))));
        i_20 = i_20 + int(1);
    }
    return result_11;
}

static __device__ float3  flightWeight_0(float3  scatter_0, float3  extinction_0, float sigma_0, float distance_2, bool scatters_0)
{
    float3  _S1048 = exp_0((make_float3 (sigma_0) - extinction_0) * make_float3 (distance_2));
    float3  _S1049 = scatter_0 * _S1048 / make_float3 (sigma_0);
    float3  _S1050 = _slang_select(scatters_0, _S1049,_S1048);
    return _S1050;
}

static __device__ uint arrivalLobe_0(uint b_4, uint prev_lobe_0)
{
    bool _S1051 = b_4 > 0U;
    uint _S1052 = _slang_select(_S1051, prev_lobe_0,3U);
    return _S1052;
}

static __device__ ShadowContext ShadowContext_x24init_0(float3  extinction_behind_0, float3  extinction_front_0, uint2  fillings_0, float3  side_0, uint depth_1, uint lobe_2, bool surface_5, float length_2, float width_1, FKHit * own_2, bool fiber_0)
{
    ShadowContext _S1053;
    (&_S1053)->extinction_behind = extinction_behind_0;
    (&_S1053)->extinction_front = extinction_front_0;
    (&_S1053)->fillings = fillings_0;
    (&_S1053)->side = side_0;
    (&_S1053)->depth = depth_1;
    (&_S1053)->lobe = lobe_2;
    (&_S1053)->surface = surface_5;
    (&_S1053)->length = length_2;
    (&_S1053)->width = width_1;
    (&_S1053)->own = *own_2;
    (&_S1053)->fiber = fiber_0;
    return _S1053;
}

static __device__ float phaseHG_0(float g_0, float mu_0)
{
    bool _S1054 = (F32_abs((g_0))) < 0.00100000004749745f;
    if(_S1054)
    {
        return 0.07957746833562851f;
    }
    float _S1055 = g_0 * g_0;
    return (1.0f - _S1055) * 0.25f * 0.31830987334251404f / (F32_pow((1.0f + _S1055 - 2.0f * g_0 * mu_0), (1.5f)));
}

__device__ float3  safeDivide(float3  a_10, float3  b_5)
{
    float3  _S1056 = a_10 / b_5;
    float3  _S1057 = make_float3 (0.0f);
    bool3  _S1058 = b_5 == _S1057;
    float3  _S1059 = _slang_select(_S1058, _S1057,_S1056);
    return _S1059;
}

static __device__ uint insertBits_0(uint e_2, uint newbits_0, uint offset_1, uint count_6)
{
    uint _S1060 = (1U << count_6) - 1U;
    return (e_2 & (~(_S1060 << offset_1))) | ((newbits_0 & _S1060) << offset_1);
}

__device__ Reservoir withEnd(Reservoir r_7, uint end_type_0, uint end_0, float3  f_6)
{
    Reservoir candidate_2 = r_7;
    uint _S1061 = insertBits_0(r_7.path, end_0, 0U, 5U);
    uint _S1062 = insertBits_0(_S1061, end_type_0, 12U, 3U);
    (&candidate_2)->path = _S1062;
    (&candidate_2)->f = f_6;
    return candidate_2;
}

__device__ float survivalProbability(float3  throughput_0, float density_1)
{
    return (F32_min(((F32_max(((F32_max((throughput_0.x), ((F32_max((throughput_0.y), (throughput_0.z)))))) / density_1), (0.0f)))), (1.0f)));
}

static __device__ float3  isotropic_0(uint random_state_9)
{
    Random _S1063 = pcg(random_state_9);
    Random _S1064 = pcg(_S1063.state);
    float _S1065 = 1.0f - 2.0f * _S1063.value;
    float _S1066 = (F32_sqrt(((F32_max((1.0f - _S1065 * _S1065), (0.0f))))));
    float _S1067 = 6.28318548202514648f * _S1064.value;
    return make_float3 (_S1066 * (F32_cos((_S1067))), _S1066 * (F32_sin((_S1067))), _S1065);
}

static __device__ float3  samplePhase_0(float g_1, float3  dir_11, uint random_state_10, float * pdf_5)
{
    bool _S1068 = (F32_abs((g_1))) < 0.00100000004749745f;
    if(_S1068)
    {
        *pdf_5 = 0.07957746833562851f;
        float3  _S1069 = isotropic_0(random_state_10);
        return _S1069;
    }
    Random _S1070 = pcg(random_state_10);
    Random _S1071 = pcg(_S1070.state);
    float _S1072 = g_1 * g_1;
    float _S1073 = 2.0f * g_1;
    float _S1074 = (1.0f - _S1072) / (1.0f - g_1 + _S1073 * _S1070.value);
    float _S1075 = clamp_1((1.0f + _S1072 - _S1074 * _S1074) / _S1073, -1.0f, 1.0f);
    float _S1076 = (F32_sqrt(((F32_max((1.0f - _S1075 * _S1075), (0.0f))))));
    float _S1077 = 6.28318548202514648f * _S1071.value;
    float _S1078 = phaseHG_0(g_1, _S1075);
    *pdf_5 = _S1078;
    float3  _S1079 = tangentToWorld(make_float3 (_S1076 * (F32_cos((_S1077))), _S1075, _S1076 * (F32_sin((_S1077)))), dir_11);
    float3  _S1080 = ((((_S1079)) * make_float3(rnorm3df(((_S1079)).x, ((_S1079)).y, ((_S1079)).z))));
    return _S1080;
}

static __device__ BSDFMaterial Material_x24init_0(float3  albedo_1, float3  emissive_1, float roughness_0, float metallic_0, float transmission_0, float ior_0, float3  absorption_0, float3  specular_tint_0, float specular_level_0, float3  translucent_0, float3  sheen_2, float sheen_roughness_0, float anisotropy_0, float anisotropic_rotation_0, float3  tangent_1, float velvet_0, float3  toon_2, float dispersion_0)
{
    BSDFMaterial _S1081;
    (&_S1081)->albedo = albedo_1;
    (&_S1081)->emissive = emissive_1;
    (&_S1081)->roughness = roughness_0;
    (&_S1081)->metallic = metallic_0;
    (&_S1081)->transmission = transmission_0;
    (&_S1081)->ior = ior_0;
    (&_S1081)->absorption = absorption_0;
    (&_S1081)->specular_tint = specular_tint_0;
    (&_S1081)->specular_level = specular_level_0;
    (&_S1081)->translucent = translucent_0;
    (&_S1081)->sheen = sheen_2;
    (&_S1081)->sheen_roughness = sheen_roughness_0;
    (&_S1081)->anisotropy = anisotropy_0;
    (&_S1081)->anisotropic_rotation = anisotropic_rotation_0;
    (&_S1081)->tangent = tangent_1;
    (&_S1081)->velvet = velvet_0;
    (&_S1081)->toon = toon_2;
    (&_S1081)->dispersion = dispersion_0;
    return _S1081;
}

static __device__ FKMedium Medium_x24init_0(float3  scatter_1, float3  extinction_1, float g_2)
{
    FKMedium _S1082;
    (&_S1082)->scatter = scatter_1;
    (&_S1082)->extinction = extinction_1;
    (&_S1082)->g = g_2;
    return _S1082;
}

static __device__ FKSurface Surface_x24init_0(float3  smooth_n_4, float3  geometry_n_2, float geometry_offset_2, BSDFMaterial * material_10, bool skip_0, uint random_state_11, float coverage_0, bool encloses_0, FKMedium * volume_0, uint fills_0, float3  hair_0)
{
    FKSurface _S1083;
    (&_S1083)->smooth_n = smooth_n_4;
    (&_S1083)->geometry_n = geometry_n_2;
    (&_S1083)->geometry_offset = geometry_offset_2;
    (&_S1083)->material = *material_10;
    (&_S1083)->skip = skip_0;
    (&_S1083)->random_state = random_state_11;
    (&_S1083)->coverage = coverage_0;
    (&_S1083)->encloses = encloses_0;
    (&_S1083)->volume = *volume_0;
    (&_S1083)->fills = fills_0;
    (&_S1083)->hair = hair_0;
    return _S1083;
}

static __device__ FKSurface emitting_0(FKSurface * surface_6, bool top_0)
{
    FKSurface lower_0 = *surface_6;
    float3  _S1084 = (&surface_6->material)->emissive;
    float3  _S1085 = make_float3 (0.0f);
    bool _S1086 = !top_0;
    float3  _S1087 = _slang_select(_S1086, _S1085,_S1084);
    (&(&lower_0)->material)->emissive = _S1087;
    return lower_0;
}

static __device__ FKSurface uncovered_0(FKSurface * surface_7, float u_1)
{
    float _S1088 = surface_7->coverage;
    bool _S1089 = u_1 < _S1088;
    if(_S1089)
    {
        return *surface_7;
    }
    float3  _S1090 = make_float3 (0.0f);
    float3  _S1091 = make_float3 (1.0f);
    BSDFMaterial _S1092 = Material_x24init_0(_S1090, _S1090, 0.0f, 0.0f, 0.0f, 0.0f, _S1090, _S1091, 1.0f, _S1090, _S1090, 0.5f, 0.0f, 0.0f, _S1090, 0.0f, _S1090, 0.0f);
    BSDFMaterial material_11 = _S1092;
    (&material_11)->albedo = _S1091;
    (&material_11)->emissive = (&surface_7->material)->emissive;
    (&material_11)->transmission = 1.0f;
    (&material_11)->ior = 1.0f;
    (&material_11)->absorption = (&surface_7->material)->absorption;
    FKSurface through_0 = *surface_7;
    (&through_0)->material = material_11;
    return through_0;
}

__device__ float facingSign(float transmission_1, float3  face_0, float3  direction_0)
{
    bool _S1093 = transmission_1 > 0.0f;
    bool _S1094;
    if(_S1093)
    {
        _S1094 = true;
    }
    else
    {
        _S1094 = (dot_0(face_0, direction_0)) < 0.0f;
    }
    float _S1095 = _slang_select(_S1094, 1.0f,-1.0f);
    return _S1095;
}

static __device__ bool arrivesBehind_0(float3  dir_12, float3  n_9)
{
    return (dot_0(dir_12, n_9)) > 0.0f;
}

static __device__ FKSurface facingRay_0(FKSurface * surface_8, float3  dir_13)
{
    float3  _S1096 = surface_8->geometry_n;
    float _S1097 = facingSign((&surface_8->material)->transmission, surface_8->geometry_n, dir_13);
    FKSurface faced_0 = *surface_8;
    float3  _S1098 = surface_8->smooth_n * make_float3 (_S1097);
    (&faced_0)->smooth_n = _S1098;
    float3  _S1099 = _S1096 * make_float3 (_S1097);
    (&faced_0)->geometry_n = _S1099;
    return faced_0;
}

static __device__ float3  max_0(float3  x_23, float3  y_7)
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
        *_slang_vector_get_element_ptr(&result_12, i_21) = (F32_max((_slang_vector_get_element(x_23, i_21)), (_slang_vector_get_element(y_7, i_21))));
        i_21 = i_21 + int(1);
    }
    return result_12;
}

static __device__ float3  log_0(float3  x_24)
{
    float3  result_13;
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
        *_slang_vector_get_element_ptr(&result_13, i_22) = (F32_log((_slang_vector_get_element(x_24, i_22))));
        i_22 = i_22 + int(1);
    }
    return result_13;
}

__device__ float3  beerLambert(float distance_3, float3  absorption_1)
{
    float3  _S1100 = max_0(absorption_1, make_float3 (0.0000152587890625f));
    return exp_0(make_float3 (distance_3) * log_0(_S1100));
}

__device__ bool dispersive(BSDFMaterial material_12)
{
    bool _S1101 = (material_12.dispersion) > 0.0f;
    bool _S1102;
    if(_S1101)
    {
        _S1102 = (material_12.ior) != 1.0f;
    }
    else
    {
        _S1102 = false;
    }
    return _S1102;
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
        uint _S1103 = (low_1 + high_1 + 1U) / 2U;
        bool _S1104 = (WAVELENGTH_CDF_0[_S1103]) <= u_2;
        if(_S1104)
        {
            low_1 = _S1103;
        }
        else
        {
            uint _S1105 = _S1103 - 1U;
            high_1 = _S1105;
        }
    }
    uint _S1106 = low_1;
    float _S1107 = WAVELENGTH_CDF_0[low_1 + 1U] - WAVELENGTH_CDF_0[low_1];
    return make_float2 (0.37999999523162842f + 0.00499999988824129f * (float(low_1) + (u_2 - WAVELENGTH_CDF_0[_S1106]) / _S1107), _S1107 / 0.00499999988824129f);
}

__device__ static const FixedArray<float, 243>  WAVELENGTH_WEIGHTS_0 = { {
    0.00547470012679696f, -0.00465690018609166f, 0.03257500007748604f, 0.00934640038758516f, -0.00796370021998882f, 0.05577300116419792f, 0.01846100017428398f, -0.01579399965703487f, 0.11072999984025955f, 0.0416410006582737f, -0.03577499836683273f, 0.2513900101184845f, 0.09349299967288971f, -0.08071800321340561f, 0.56742000579833984f, 0.1585099995136261f, -0.13764999806880951f, 0.97018998861312866f, 0.30943000316619873f, -0.27083000540733337f, 1.91740000247955322f, 0.55217999219894409f, -0.48754000663757324f, 3.46889996528625488f, 0.95016998052597046f, -0.84802001714706421f, 6.09439992904663086f, 1.42110002040863037f, -1.28929996490478516f, 9.45199966430664062f, 1.73409998416900635f, -1.6062999963760376f, 12.12800025939941406f, 2.08030009269714355f, -1.98810005187988281f, 15.68700027465820312f, 2.20600008964538574f, -2.20120000839233398f, 18.47699928283691406f, 2.03040003776550293f, -2.17700004577636719f, 19.92700004577636719f, 1.63429999351501465f, -2.00340008735656738f, 20.86899948120117188f, 0.99410998821258545f, -1.62629997730255127f, 20.57799911499023438f, 0.20011000335216522f, -1.11409997940063477f, 19.72100067138671875f, -0.67960000038146973f, -0.45403000712394714f, 17.77599906921386719f, -1.61679995059967041f, 0.37860000133514404f, 14.71500015258789062f, -2.53410005569458008f, 1.27540004253387451f, 11.86499977111816406f, -3.39079999923706055f, 2.2146000862121582f, 9.17669963836669922f, -4.03749990463256836f, 3.0522000789642334f, 6.59509992599487305f, -4.61299991607666016f, 3.89779996871948242f, 4.64589977264404297f, -5.43039989471435547f, 5.0121002197265625f, 3.3199000358581543f, -6.37769985198974609f, 6.33809995651245117f, 2.29699993133544922f, -7.44140005111694336f, 7.91739988327026367f, 1.45389997959136963f, -8.38580036163330078f, 9.60109996795654297f, 0.66465997695922852f, -9.0167999267578125f, 11.23999977111816406f, -0.04403600096702576f, -9.17749977111816406f, 12.63199996948242188f, -0.58126997947692871f, -8.97550010681152344f, 13.91499996185302734f, -0.95730000734329224f, -8.25290012359619141f, 14.86200046539306641f, -1.24430000782012939f, -6.92129993438720703f, 15.03899955749511719f, -1.43069994449615479f, -5.29169988632202148f, 14.90900039672851562f, -1.55149996280670166f, -3.43219995498657227f, 14.70499992370605469f, -1.63569998741149902f, -1.27190005779266357f, 14.24400043487548828f, -1.67030000686645508f, 1.15170001983642578f, 13.32199954986572266f, -1.636199951171875f, 3.73889994621276855f, 12.21199989318847656f, -1.56920003890991211f, 6.43590021133422852f, 10.94699954986572266f, -1.47730004787445068f, 9.16440010070800781f, 9.54769992828369141f, -1.36399996280670166f, 12.02000045776367188f, 8.18799972534179688f, -1.25450003147125244f, 14.78699970245361328f, 6.74429988861083984f, -1.13110005855560303f, 16.72299957275390625f, 5.08780002593994141f, -0.96561002731323242f, 18.14299964904785156f, 3.57019996643066406f, -0.80725997686386108f, 19.91900062561035156f, 2.36269998550415039f, -0.69273000955581665f, 21.05500030517578125f, 1.31369996070861816f, -0.58597999811172485f, 21.3899993896484375f, 0.42390000820159912f, -0.48298001289367676f, 20.99300003051757812f, -0.23857000470161438f, -0.39412000775337219f, 19.82200050354003906f, -0.6866300106048584f, -0.31501999497413635f, 18.12000083923339844f, -0.9412500262260437f, -0.24890999495983124f, 15.7089996337890625f, -1.02020001411437988f, -0.19076000154018402f, 13.19799995422363281f, -0.98919999599456787f, -0.14401000738143921f, 11.23999977111816406f, -0.93347001075744629f, -0.11133000254631042f, 9.36649990081787109f, -0.83820998668670654f, -0.08524099737405777f, 7.41249990463256836f, -0.70064002275466919f, -0.06283199787139893f, 5.71229982376098633f, -0.56079000234603882f, -0.04586699977517128f, 4.42280006408691406f, -0.44653001427650452f, -0.03396600112318993f, 3.34489989280700684f, -0.34457001090049744f, -0.02482499927282333f, 2.49309992790222168f, -0.26017999649047852f, -0.01808100007474422f, 1.82239997386932373f, -0.1921599954366684f, -0.01296999957412481f, 1.29499995708465576f, -0.13766999542713165f, -0.00907570030540228f, 0.92928999662399292f, -0.09956400096416473f, -0.00641620019450784f, 0.61835998296737671f, -0.06671299785375595f, -0.00421149982139468f, 0.40211999416351318f, -0.04354599863290787f, -0.00271830009296536f, 0.2844499945640564f, -0.03087200038135052f, -0.00191440002527088f, 0.20672999322414398f, -0.02246100082993507f, -0.00138829997740686f, 0.15044000744819641f, -0.01634499989449978f, -0.00101030000951141f, 0.10942000150680542f, -0.01188699994236231f, -0.0007347899954766f, 0.07099699974060059f, -0.00771349994465709f, -0.00047679000999779f, 0.04539500176906586f, -0.00493190018460155f, -0.00030484999297187f, 0.03424099832773209f, -0.00372010003775358f, -0.00022995000472292f, 0.02557599917054176f, -0.00277870008721948f, -0.00017175999528263f, 0.01842200011014938f, -0.00200140010565519f, -0.0001237099932041f, 0.01316899992525578f, -0.00143079995177686f, -0.00008843900286593f, 0.00838890019804239f, -0.00091141002485529f, -0.00005633700129692f, 0.00537079991772771f, -0.00058350997278467f, -0.00003606799873523f, 0.00328280008397996f, -0.00035665999166667f, -0.00002204600059486f, 0.00196009990759194f, -0.00021296000340953f, -0.00001316300040344f, 0.00168939994182438f, -0.00018354000349063f, -0.00001134499962063f, 0.00141050003003329f, -0.00015325000276789f, -0.00000947250009631f, 0.00097123999148607f, -0.00010551999730524f, -6.52239987175562419e-06f, 0.00066868000430986f, -0.00007264900341397f, -4.49060007667867467e-06f
} };
__device__ float3  wavelengthWeights(float wavelength_0)
{
    float _S1108 = clamp_1((wavelength_0 - 0.37999999523162842f) / 0.00499999988824129f, 0.0f, 80.0f);
    uint _S1109 = (U32_min((uint(_S1108)), (79U)));
    uint _S1110 = 3U * _S1109;
    float3  _S1111 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1110], WAVELENGTH_WEIGHTS_0[_S1110 + 1U], WAVELENGTH_WEIGHTS_0[_S1110 + 2U]);
    float3  _S1112 = make_float3 (WAVELENGTH_WEIGHTS_0[_S1110 + 3U], WAVELENGTH_WEIGHTS_0[_S1110 + 4U], WAVELENGTH_WEIGHTS_0[_S1110 + 5U]);
    return _S1111 + (_S1112 - _S1111) * make_float3 (_S1108 - float(_S1109));
}

__device__ float dispersedIor(float ior_1, float dispersion_1, float wavelength_1)
{
    float _S1113 = (ior_1 - 1.0f) * dispersion_1 / 1.90962409973144531f;
    float _S1114 = _S1113 * (1.0f / (wavelength_1 * wavelength_1) - 2.89662933349609375f);
    bool _S1115 = dispersion_1 > 0.0f;
    float _S1116 = _slang_select(_S1115, _S1114,0.0f);
    return ior_1 + _S1116;
}

__device__ float2  vertexEta(BSDFMaterial material_13, float n_dot_v_0)
{
    bool _S1117 = n_dot_v_0 < 0.0f;
    float _S1118 = _slang_select(_S1117, material_13.ior,1.0f);
    float _S1119 = _slang_select(_S1117, 1.0f,material_13.ior);
    return make_float2 (_S1118, _S1119);
}

__device__ bool neeDecision(BSDFMaterial material_14, float n_dot_v_1, float eta_i_5, float eta_o_5)
{
    float _S1120 = fresnel((F32_abs((n_dot_v_1))), eta_i_5, eta_o_5);
    float3  _S1121 = mix_0(make_float3 (_S1120), material_14.albedo, material_14.metallic);
    float _S1122 = rgb_to_greyscale(_S1121);
    float _S1123 = (F32_max(((1.0f - _S1122) * (1.0f - material_14.metallic) * (1.0f - material_14.transmission)), (0.0f)));
    bool _S1124 = _S1123 > 0.03999999910593033f;
    bool _S1125;
    if(_S1124)
    {
        _S1125 = true;
    }
    else
    {
        _S1125 = (material_14.roughness) > 0.20000000298023224f;
    }
    return _S1125;
}

static __device__ bool isTranslucent_0(BSDFMaterial * material_15)
{
    float _S1126 = rgb_to_greyscale(material_15->translucent);
    return _S1126 > 0.0f;
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
    MediumSides _S1127;
    (&_S1127)->behind = *behind_0;
    (&_S1127)->front = *front_0;
    (&_S1127)->fillings = fillings_1;
    (&_S1127)->face = face_1;
    return _S1127;
}

static __device__ MediumSides mediumSides_0(FKSurface * surface_9, FKMedium * medium_0, uint filling_0, float3  dir_14, FKMedium * outside_0)
{
    float3  _S1128 = surface_9->geometry_n;
    MediumSides _S1129 = MediumSides_x24init_0(medium_0, medium_0, make_uint2 (filling_0), surface_9->geometry_n);
    MediumSides sides_0 = _S1129;
    bool _S1130 = surface_9->encloses;
    if(_S1130)
    {
        (&sides_0)->behind = surface_9->volume;
        *&((&(&sides_0)->fillings)->x) = surface_9->fills;
        bool _S1131 = (dot_0(dir_14, _S1128)) > 0.0f;
        if(_S1131)
        {
            (&sides_0)->front = *outside_0;
            *&((&(&sides_0)->fillings)->y) = 4294967295U;
        }
    }
    return sides_0;
}

static __device__ ShadowContext shadowContext_0(FKSurface * surface_10, bool turned_0, float3  extinction_2, uint filling_1, float3  dir_15, uint depth_2, uint lobe_3, float length_3, float width_2, FKHit * own_3, bool fiber_1, FKMedium * outside_1)
{
    float3  _S1132 = surface_10->geometry_n;
    ShadowContext _S1133 = ShadowContext_x24init_0(extinction_2, extinction_2, make_uint2 (filling_1), surface_10->geometry_n, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
    bool _S1134 = surface_10->encloses;
    ShadowContext context_4;
    if(_S1134)
    {
        FKSurface faced_1 = *surface_10;
        float3  _S1135 = - _S1132;
        float3  _S1136 = _slang_select(turned_0, _S1135,_S1132);
        (&faced_1)->geometry_n = _S1136;
        FKMedium _S1137 = Medium_x24init_0(make_float3 (0.0f), extinction_2, 0.0f);
        FKSurface _S1138 = faced_1;
        FKMedium _S1139 = _S1137;
        MediumSides _S1140 = mediumSides_0(&_S1138, &_S1139, filling_1, dir_15, outside_1);
        ShadowContext _S1141 = ShadowContext_x24init_0(_S1140.behind.extinction, _S1140.front.extinction, _S1140.fillings, _S1132, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
        if(turned_0)
        {
            uint2  _S1142 = _S1140.fillings;
            ShadowContext _S1143 = ShadowContext_x24init_0(_S1140.front.extinction, _S1140.behind.extinction, uint2 {_S1142.y, _S1142.x}, _S1132, depth_2, lobe_3, true, length_3, width_2, own_3, fiber_1);
            context_4 = _S1143;
        }
        else
        {
            context_4 = _S1141;
        }
    }
    else
    {
        context_4 = _S1133;
    }
    return context_4;
}

static __device__ bool any_1(bool3  x_25)
{
    bool result_14 = false;
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
        if(result_14)
        {
            result_14 = true;
        }
        else
        {
            result_14 = (bool((_slang_vector_get_element(x_25, i_23))));
        }
        i_23 = i_23 + int(1);
    }
    return result_14;
}

static __device__ __forceinline__ float3  lightBSDF_0(float3  in_dir_7, TreeSample * light_2, float3  smooth_n_5, float3  geometry_n_3, BSDFMaterial * material_16, float eta_i_6, float eta_o_6, bool competing_1, uint random_state_12)
{
    float3  _S1144 = light_2->dir;
    bool _S1145 = (dot_0(geometry_n_3, - in_dir_7) * dot_0(geometry_n_3, light_2->dir)) <= 0.0f;
    FixedArray<float3 , 5>  throughputs_1;
    FixedArray<float, 5>  pdfs_3;
    float3  _S1146 = BSDF(in_dir_7, _S1144, smooth_n_5, *material_16, eta_i_6, eta_o_6, _S1145, random_state_12, &throughputs_1, &pdfs_3);
    bool _S1147 = !competing_1;
    bool _S1148;
    if(_S1147)
    {
        _S1148 = true;
    }
    else
    {
        _S1148 = (light_2->density) == 0.0f;
    }
    if(_S1148)
    {
        return _S1146 * light_2->radiance;
    }
    float3  _S1149 = make_float3 (0.0f);
    uint i_24 = 0U;
    float3  weighted_0 = _S1149;
    for(;;)
    {
        if(i_24 < 5U)
        {
        }
        else
        {
            break;
        }
        bool _S1150 = (pdfs_3[i_24]) > 0.0f;
        if(_S1150)
        {
            float _S1151 = light_2->density;
            float _S1152 = pdfs_3[i_24] / light_2->density;
            float3  weighted_1 = weighted_0 + throughputs_1[i_24] * make_float3 (pdfs_3[i_24]) / make_float3 (_S1151 * (1.0f + _S1152 * _S1152));
            weighted_0 = weighted_1;
        }
        uint i_25 = i_24 + 1U;
        i_24 = i_25;
    }
    return weighted_0 * light_2->radiance * make_float3 (light_2->density);
}

static __device__ SampleBSDF SampleBSDF_x24init_0(float3  unit_direction_1, float3  throughput_1, uint random_state_13, bool refracted_3, uint lobe_4, float pdf_6)
{
    SampleBSDF _S1153;
    (&_S1153)->unit_direction = unit_direction_1;
    (&_S1153)->throughput = throughput_1;
    (&_S1153)->random_state = random_state_13;
    (&_S1153)->refracted = refracted_3;
    (&_S1153)->lobe = lobe_4;
    (&_S1153)->pdf = pdf_6;
    return _S1153;
}

__device__ __forceinline__ SampleBSDF sheenVelvetSample(float3  v_9, float3  n_i_13, float n_i_dot_v_3, BSDFMaterial material_17, Weights w_14, uint random_state_14)
{
    float3  _S1154 = make_float3 (1.0f);
    SampleBSDF _S1155 = SampleBSDF_x24init_0(_S1154, _S1154, 0U, false, 0U, 0.0f);
    SampleBSDF sample_1 = _S1155;
    Random _S1156 = pcg(random_state_14);
    Random _S1157 = pcg(_S1156.state);
    (&sample_1)->random_state = _S1157.state;
    float _S1158 = _S1156.value;
    float _S1159 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1158 * _S1158))))));
    float _S1160 = 6.28318548202514648f * _S1157.value;
    float3  _S1161 = tangentToWorld(make_float3 (_S1159 * (F32_cos((_S1160))), _S1156.value, _S1159 * (F32_sin((_S1160)))), n_i_13);
    (&sample_1)->unit_direction = _S1161;
    (&sample_1)->lobe = 4U;
    float3  _S1162 = sheenVelvetBSDF((&sample_1)->unit_direction, v_9, n_i_13, material_17, w_14);
    (&sample_1)->throughput = _S1162;
    float _S1163 = sheenVelvetPDF(_S1156.value, n_i_dot_v_3, w_14);
    (&sample_1)->pdf = _S1163;
    return sample_1;
}

__device__ float3  sampleCosWeightedHemisphere(float random_1_0, float random_2_0)
{
    float _S1164 = (F32_sqrt((random_1_0)));
    float _S1165 = 6.28318548202514648f * random_2_0;
    float _S1166 = _S1164 * (F32_cos((_S1165)));
    float _S1167 = _S1164 * (F32_sin((_S1165)));
    float _S1168 = (F32_sqrt(((F32_max((0.0f), (1.0f - _S1166 * _S1166 - _S1167 * _S1167))))));
    return make_float3 (_S1166, _S1168, _S1167);
}

__device__ __forceinline__ SampleBSDF diffuseSample(float u_3, float3  n_i_14, float n_i_dot_v_4, BSDFMaterial material_18, Weights w_15, uint random_state_15)
{
    float3  _S1169 = make_float3 (1.0f);
    SampleBSDF _S1170 = SampleBSDF_x24init_0(_S1169, _S1169, 0U, false, 0U, 0.0f);
    SampleBSDF sample_2 = _S1170;
    Random _S1171 = pcg(random_state_15);
    Random _S1172 = pcg(_S1171.state);
    (&sample_2)->random_state = _S1172.state;
    float3  _S1173 = sampleCosWeightedHemisphere(_S1171.value, _S1172.value);
    float _S1174 = translucentShare(material_18);
    bool _S1175 = u_3 < (w_15.p_diffuse * _S1174);
    float _S1176 = _S1173.y;
    float _S1177 = - _S1176;
    float _S1178 = _slang_select(_S1175, _S1177,_S1176);
    float3  _S1179 = tangentToWorld(make_float3 (_S1173.x, _S1178, _S1173.z), n_i_14);
    (&sample_2)->unit_direction = _S1179;
    (&sample_2)->refracted = _S1175;
    (&sample_2)->lobe = 0U;
    float3  _S1180 = diffuseBSDF((&sample_2)->unit_direction, n_i_14, material_18, w_15);
    (&sample_2)->throughput = _S1180;
    float _S1181 = diffusePDF(_S1178, n_i_dot_v_4, material_18, w_15);
    (&sample_2)->pdf = _S1181;
    return sample_2;
}

__device__ __forceinline__ SampleBSDF toonSample(float3  n_i_15, ToonProfile profile_3, Weights w_16, uint random_state_16)
{
    float3  _S1182 = make_float3 (1.0f);
    Random _S1183 = pcg(random_state_16);
    Random _S1184 = pcg(_S1183.state);
    float _S1185 = _S1183.value * profile_3.norm / 6.28318548202514648f;
    float _S1186 = (F32_asin(((F32_min(((F32_sqrt((2.0f * _S1185)))), (1.0f))))));
    float _S1187 = (F32_acos((clamp_1(1.0f - _S1185, -1.0f, 1.0f))));
    float _S1188 = _slang_select(profile_3.glossy, _S1187,_S1186);
    float _S1189 = (profile_3.a + profile_3.b) / 2.0f;
    bool _S1190 = _S1188 < (profile_3.a);
    float _S1191 = _slang_select(_S1190, _S1188,_S1189);
    float t_23 = _S1191;
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
        float _S1192 = toonP(t_23, profile_3.a, profile_3.s);
        float _S1193 = _S1192 * (F32_sin((t_23)));
        float _S1194 = (F32_cos((t_23)));
        float _S1195 = _slang_select(profile_3.glossy, 1.0f,_S1194);
        float _S1196 = _S1193 * _S1195;
        float _S1197 = toonIntegral(t_23, profile_3.a, profile_3.s, profile_3.glossy);
        float _S1198 = (_S1197 - _S1185) / _S1196;
        bool _S1199 = _S1196 > 0.0f;
        float _S1200 = _slang_select(_S1199, _S1198,0.0f);
        float _S1201 = clamp_1(t_23 - _S1200, 0.0f, profile_3.b);
        int k_1 = k_0 + int(1);
        t_23 = _S1201;
        k_0 = k_1;
    }
    float _S1202 = 6.28318548202514648f * _S1184.value;
    float _S1203 = (F32_sin((t_23)));
    float3  _S1204 = tangentToWorld(make_float3 (_S1203 * (F32_cos((_S1202))), (F32_cos((t_23))), _S1203 * (F32_sin((_S1202)))), profile_3.axis);
    float3  _S1205 = toonBSDF(_S1204, n_i_15, profile_3, w_16);
    bool _S1206 = (dot_0(n_i_15, _S1204)) < 0.0f;
    float _S1207 = toonPDF(_S1204, n_i_15, profile_3, w_16);
    return SampleBSDF_x24init_0(_S1204, _S1205, _S1184.state, _S1206, 6U, _S1207);
}

__device__ __forceinline__ SampleBSDF refractSample(float3  ggx_n_3, float3  n_i_16, float alpha_8, AnisotropicFrame frame_6, BSDFMaterial material_19, Weights w_17, float pdf_h_3, float eta_i_7, float eta_o_7, uint random_state_17)
{
    float3  _S1208 = make_float3 (1.0f);
    SampleBSDF _S1209 = SampleBSDF_x24init_0(_S1208, _S1208, 0U, false, 0U, 0.0f);
    SampleBSDF sample_3 = _S1209;
    (&sample_3)->unit_direction = w_17.refracted;
    (&sample_3)->random_state = random_state_17;
    (&sample_3)->refracted = true;
    (&sample_3)->lobe = 1U;
    float3  _S1210 = refractBSDF((&sample_3)->unit_direction, n_i_16, alpha_8, frame_6, material_19, w_17);
    (&sample_3)->throughput = _S1210;
    float _S1211 = refractPDF(dot_0((&sample_3)->unit_direction, ggx_n_3), pdf_h_3, w_17, eta_i_7, eta_o_7);
    (&sample_3)->pdf = _S1211;
    return sample_3;
}

static __device__ float3  reflect_0(float3  i_26, float3  n_10)
{
    return i_26 - make_float3 (2.0f * dot_0(n_10, i_26)) * n_10;
}

__device__ __forceinline__ SampleBSDF reflectSample(float3  in_dir_8, float3  ggx_n_4, float3  n_i_17, float alpha_9, AnisotropicFrame frame_7, Weights w_18, float pdf_h_4, uint random_state_18)
{
    float3  _S1212 = make_float3 (1.0f);
    SampleBSDF _S1213 = SampleBSDF_x24init_0(_S1212, _S1212, 0U, false, 0U, 0.0f);
    SampleBSDF sample_4 = _S1213;
    float3  _S1214 = reflect_0(in_dir_8, ggx_n_4);
    float3  _S1215 = ((((_S1214)) * make_float3(rnorm3df(((_S1214)).x, ((_S1214)).y, ((_S1214)).z))));
    (&sample_4)->unit_direction = _S1215;
    (&sample_4)->random_state = random_state_18;
    (&sample_4)->lobe = 2U;
    float3  _S1216 = reflectBSDF((&sample_4)->unit_direction, n_i_17, alpha_9, frame_7, w_18);
    (&sample_4)->throughput = _S1216;
    float _S1217 = reflectPDF(pdf_h_4, w_18);
    (&sample_4)->pdf = _S1217;
    return sample_4;
}

__device__ __forceinline__ SampleBSDF sampleBSDF(float3  in_dir_9, float3  n_11, BSDFMaterial material_20, float eta_i_8, float eta_o_8, uint random_init_0, float2  screen_space_0)
{
    uint random_state_19 = random_init_0;
    float3  _S1218 = negate_0(in_dir_9);
    float _S1219 = dot_0(n_11, _S1218);
    float _S1220 = sign_0(_S1219);
    float3  n_i_18 = n_11 * make_float3 (_S1220);
    float _S1221 = (F32_abs((_S1219)));
    float _S1222 = material_20.roughness;
    float _S1223 = _S1222 * _S1222;
    AnisotropicFrame _S1224 = anisotropicFrame(material_20, n_i_18);
    SheenProfile _S1225 = sheenProfile(_S1218, n_i_18, material_20);
    float3  _S1226 = sampleHalfVector(_S1218, n_i_18, _S1223, _S1224, &random_state_19);
    Weights _S1227 = lobeWeights(in_dir_9, _S1218, n_i_18, _S1226, _S1224, _S1225, material_20, eta_i_8, eta_o_8);
    Random _S1228 = pcg(random_state_19);
    random_state_19 = _S1228.state;
    bool _S1229 = (_S1228.value) < (_S1227.p_sheen_velvet);
    if(_S1229)
    {
        SampleBSDF _S1230 = sheenVelvetSample(_S1218, n_i_18, _S1221, material_20, _S1227, random_state_19);
        return _S1230;
    }
    float _S1231 = _S1228.value - _S1227.p_sheen_velvet;
    bool _S1232 = _S1231 < (_S1227.p_diffuse);
    if(_S1232)
    {
        SampleBSDF _S1233 = diffuseSample(_S1231, n_i_18, _S1221, material_20, _S1227, random_state_19);
        return _S1233;
    }
    bool _S1234 = _S1231 < (_S1227.p_diffuse + _S1227.p_toon);
    if(_S1234)
    {
        ToonProfile _S1235 = toonProfile(_S1218, n_i_18, material_20);
        SampleBSDF _S1236 = toonSample(n_i_18, _S1235, _S1227, random_state_19);
        return _S1236;
    }
    float _S1237 = vndfPDF(_S1218, _S1226, n_i_18, _S1221, _S1223, _S1224, _S1227.v_dot_h);
    bool _S1238 = (_S1231 - _S1227.p_toon) < (_S1227.p_diffuse + _S1227.p_refract);
    if(_S1238)
    {
        SampleBSDF _S1239 = refractSample(_S1226, n_i_18, _S1223, _S1224, material_20, _S1227, _S1237, eta_i_8, eta_o_8, random_state_19);
        return _S1239;
    }
    SampleBSDF _S1240 = reflectSample(in_dir_9, _S1226, n_i_18, _S1223, _S1224, _S1227, _S1237, random_state_19);
    return _S1240;
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
    bool _S1241;
    bool _S1242;
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
    int _S1243;
    Shift ended_0;
    float density_3;
    float spread_2;
    float width_4;
    float sky_pdf_1;
    float spread_3;
    float width_5;
    uint b_7;
    float3  _S1244 = make_float3 (0.0f);
    Shift _S1245 = Shift_x24init_0(_S1244, 0.0f);
    uint _S1246 = r_8->path;
    uint _S1247 = extractBits_0(r_8->path, 0U, 5U);
    uint _S1248 = extractBits_0(_S1246, 5U, 5U);
    uint _S1249 = extractBits_0(_S1246, 10U, 2U);
    uint _S1250 = extractBits_0(_S1246, 12U, 3U);
    bool passes_0;
    if(replay_1)
    {
        bool _S1251 = _S1250 >= 3U;
        uint _S1252 = _slang_select(_S1251, 1U,0U);
        uint _S1253 = _S1247 + _S1252;
        uint _S1254 = (fcptMaxBounces());
        passes_0 = _S1253 > _S1254;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        return _S1245;
    }
    uint _S1255 = _S1248 - 1U;
    bool _S1256 = _S1250 == 3U;
    uint _S1257 = _slang_select(_S1256, 1U,0U);
    uint _S1258 = _S1247 + _S1257;
    bool _S1259 = _S1249 == 0U;
    uint _S1260 = _slang_select(_S1259, _S1258,_S1255);
    FKHit _S1261 = (fcptReservoirHit((*r_8)));
    float3  _S1262 = dom_7->x0;
    float3  _S1263 = dom_7->x1 - dom_7->x0;
    float3  _S1264 = ((((_S1263)) * make_float3(rnorm3df(((_S1263)).x, ((_S1263)).y, ((_S1263)).z))));
    FKRay _S1265 = Ray_x24init_0(dom_7->x1, _S1264);
    FKRay ray_2 = _S1265;
    FKHit hit_4 = dom_7->hit;
    float3  scatter_in_0 = _S1244;
    float3  throughput_3 = make_float3 (1.0f);
    float3  weight_1 = throughput_3;
    float3  glowed_0 = _S1244;
    float3  extinction_in_0 = _S1244;
    float g_in_0 = 0.0f;
    uint filling_2 = 4294967295U;
    float _S1266 = dom_7->spread;
    float _S1267 = dom_7->width;
    float _S1268 = length_0(_S1263);
    NEEVertex _S1269 = NEEVertex_x24init_0(true, 0.0f, _S1244, _S1244, _S1244);
    NEEVertex nee_vertex_0 = _S1269;
    Vertex _S1270 = Vertex_x24init_0(false, 0U, 0.0f, 0.0f, false);
    Vertex prev_0 = _S1270;
    Reservoir _S1271 = (Reservoir{});
    Reservoir chain_0 = _S1271;
    uint _S1272 = r_8->seed;
    (&chain_0)->seed = r_8->seed;
    (&ray_2)->origin = _S1262;
    (&hit_4)->distance = _S1268;
    FKMedium _S1273 = (fcptCameraMedium(((&ray_2)->unit_direction), ((&hit_4)->distance), (&filling_2)));
    uint _S1274 = filling_2;
    bool _S1275 = (fcptVaryingUsed());
    uint _S1276 = _slang_select(_S1275, _S1274,4294967295U);
    filling_2 = _S1276;
    scatter_in_0 = _S1273.scatter;
    extinction_in_0 = _S1273.extinction;
    g_in_0 = _S1273.g;
    Reservoir _S1277 = chain_0;
    uint _S1278 = filling_2;
    for(;;)
    {
        bool _S1279 = (fcptVaryingUsed());
        if(_S1279)
        {
            passes_0 = _S1278 != 4294967295U;
        }
        else
        {
            passes_0 = false;
        }
        if(passes_0)
        {
            float _S1280 = (fcptMajorant((_S1278)));
            spread_1 = _S1280;
        }
        else
        {
            spread_1 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
        }
        if(replay_1)
        {
            turned_1 = 4294967295U == _S1260;
        }
        else
        {
            turned_1 = false;
        }
        if(turned_1)
        {
            turned_1 = _S1249 == 1U;
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
            ended_0 = _S1245;
            sky_pdf_0 = 0.0f;
            spread_1 = _S1266;
            width_3 = _S1267;
            density_2 = 1.0f;
            throughput_2 = throughput_3;
            b_6 = 4294967295U;
            passes_0 = true;
            break;
        }
        bool _S1281 = (&prev_0)->rough;
        if(_S1281)
        {
            turned_1 = !(spread_1 > 0.0f);
        }
        else
        {
            turned_1 = false;
        }
        (&prev_0)->rough = turned_1;
        uint _S1282 = stream(_S1272, 384U);
        uint tracking_0 = _S1282;
        weight_1 = throughput_3;
        glowed_0 = _S1244;
        b_6 = 4294967295U;
        throughput_2 = throughput_3;
        density_2 = 1.0f;
        threshold_0 = _S1266;
        width_3 = _S1267;
        sky_pdf_0 = 0.0f;
        for(;;)
        {
            if(((&hit_4)->instance_index) != 4294967295U)
            {
            }
            else
            {
                _S1243 = int(1);
                break;
            }
            uint _S1283 = b_6 + 320U;
            bool _S1284 = b_6 == 4294967295U;
            uint _S1285 = _slang_select(_S1284, 384U,_S1283);
            uint _S1286 = stream(_S1272, _S1285);
            Random _S1287 = pcg(_S1286);
            float _S1288 = - (F32_log((1.0f - _S1287.value))) / spread_1;
            if(passes_0)
            {
                float3  _S1289 = (&ray_2)->origin;
                float3  _S1290 = (&ray_2)->unit_direction;
                float _S1291 = (&hit_4)->distance;
                uint _S1292 = _slang_select(_S1284, 0U,b_6);
                uint _S1293 = (&prev_0)->lobe;
                uint _S1294 = _slang_select(_S1284, 3U,_S1293);
                float _S1295 = (fcptTrackMedium((_S1278), (_S1289), (_S1290), (_S1291), (&tracking_0), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1292), (_S1294), (_S1284)));
                wavelength_2 = _S1295;
            }
            else
            {
                wavelength_2 = _S1288;
            }
            bool _S1296 = !(wavelength_2 < ((&hit_4)->distance));
            if(_S1296)
            {
                _S1243 = int(1);
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
                float3  _S1297 = throughput_2 * glowed_0 / make_float3 (density_2);
                float3  _S1298 = sel_7->glow + _S1297;
                sel_7->glow = _S1298;
            }
            else
            {
            }
            glowed_0 = _S1244;
            uint b_8 = b_6 + 1U;
            float3  _S1299 = (&ray_2)->origin + make_float3 (wavelength_2) * (&ray_2)->unit_direction;
            (&ray_2)->origin = _S1299;
            float3  _S1300 = flightWeight_0(scatter_in_0, extinction_in_0, spread_1, wavelength_2, true);
            float3  _S1301 = weight_1;
            float3  _S1302 = _slang_select(passes_0, _S1301,_S1300);
            float3  throughput_4 = throughput_2 * _S1302;
            uint _S1303 = stream(_S1272, b_8 + 320U);
            tracking_0 = _S1303;
            weight_1 = throughput_3;
            float width_6 = width_3 + threshold_0 * wavelength_2;
            float _S1304 = threshold_0 + 3.14159274101257324f;
            bool _S1305 = !replay_1;
            if(_S1305)
            {
                is_inside_5 = true;
            }
            else
            {
                bool _S1306 = b_8 == _S1260;
                if(_S1306)
                {
                    is_inside_5 = !passes_0;
                }
                else
                {
                    is_inside_5 = false;
                }
            }
            TreeSample _S1307 = TreeSample_x24init_0(_S1244, _S1244, 0.0f, 0U);
            if(is_inside_5)
            {
                float3  _S1308 = (&ray_2)->origin;
                float3  _S1309 = (&ray_2)->unit_direction;
                float3  _S1310 = (&ray_2)->unit_direction;
                uint _S1311 = stream(_S1272, b_8 + 64U);
                float3  _S1312 = extinction_in_0;
                float3  _S1313 = extinction_in_0;
                uint2  _S1314 = make_uint2 (_S1278);
                float3  _S1315 = (&ray_2)->unit_direction;
                uint _S1316 = arrivalLobe_0(b_8, (&prev_0)->lobe);
                FKHit _S1317 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
                FKHit _S1318 = _S1317;
                ShadowContext _S1319 = ShadowContext_x24init_0(_S1312, _S1313, _S1314, _S1315, b_8, _S1316, false, wavelength_2, width_6, &_S1318, false);
                ShadowContext _S1320 = _S1319;
                TreeSample _S1321 = sampleLightTree_0(_S1308, _S1309, _S1310, 0.0f, true, _S1311, &_S1320);
                light_3 = _S1321;
            }
            else
            {
                light_3 = _S1307;
            }
            float _S1322 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_3.dir));
            uint _S1323 = (fcptMaxBounces());
            bool _S1324 = b_8 < _S1323;
            if(_S1324)
            {
                viewed_0 = (light_3.density) > 0.0f;
            }
            else
            {
                viewed_0 = false;
            }
            float _S1325 = _slang_select(viewed_0, _S1322,0.0f);
            float3  _S1326 = throughput_4 * light_3.radiance;
            float _S1327 = powerHeuristic(light_3.density, _S1325);
            float3  _S1328 = _S1326 * make_float3 (_S1322 * _S1327);
            float3  _S1329 = _slang_select(is_inside_5, _S1328,_S1244);
            if(replay_1)
            {
                _S1241 = b_8 == _S1260;
            }
            else
            {
                _S1241 = false;
            }
            if(_S1241)
            {
                bool _S1330 = _S1249 == 2U;
                if(_S1330)
                {
                    float _S1331 = resamplingTarget(_S1329);
                    passes_0 = _S1331 > 0.0f;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    Shift _S1332 = Shift_x24init_0(_S1329, 1.0f);
                    _S1243 = int(0);
                    ended_0 = _S1332;
                    spread_1 = _S1304;
                    wavelength_2 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_8;
                    break;
                }
                _S1243 = int(0);
                ended_0 = _S1245;
                spread_1 = _S1304;
                wavelength_2 = width_6;
                chain_throughput_0 = throughput_4;
                layer_0 = b_8;
                break;
            }
            if(_S1305)
            {
                Reservoir candidate_3 = _S1277;
                uint _S1333 = extractBits_0(_S1277.path, 10U, 2U);
                bool _S1334 = _S1333 == 1U;
                if(_S1334)
                {
                    float3  _S1335 = safeDivide(_S1329, _S1244);
                    (&candidate_3)->radiance = _S1335;
                }
                else
                {
                    uint _S1336 = insertBits_0(0U, b_8 + 1U, 5U, 5U);
                    uint _S1337 = insertBits_0(_S1336, 2U, 10U, 2U);
                    (&candidate_3)->path = _S1337;
                }
                Reservoir _S1338 = withEnd(candidate_3, 0U, b_8, _S1329);
                offer(sel_7, _S1338, _S1329 * make_float3 (scale_3) / make_float3 (density_2));
                float _S1339 = survivalProbability(abs_0(throughput_4), density_2);
                uint _S1340 = stream(_S1272, b_8 + 128U);
                Random _S1341 = pcg(_S1340);
                bool _S1342 = _S1339 < (_S1341.value);
                if(_S1342)
                {
                    _S1242 = true;
                }
                else
                {
                    uint _S1343 = (fcptMaxBounces());
                    _S1242 = b_8 >= _S1343;
                }
                if(_S1242)
                {
                    _S1243 = int(0);
                    ended_0 = _S1245;
                    spread_1 = _S1304;
                    wavelength_2 = width_6;
                    chain_throughput_0 = throughput_4;
                    layer_0 = b_8;
                    break;
                }
                float _S1344 = density_2 * _S1339;
                density_2 = _S1344;
            }
            else
            {
            }
            float phase_pdf_0 = 0.0f;
            uint _S1345 = stream(_S1272, b_8);
            float3  _S1346 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1345, &phase_pdf_0);
            (&ray_2)->unit_direction = _S1346;
            NEEVertex _S1347 = NEEVertex_x24init_0(false, phase_pdf_0, (&ray_2)->origin, _S1244, (&ray_2)->origin);
            nee_vertex_0 = _S1347;
            Vertex _S1348 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, false);
            prev_0 = _S1348;
            float _S1349 = (&prev_0)->pdf;
            FKRay _S1350 = ray_2;
            FKHit _S1351 = Hit_x24init_0(make_float2 (0.0f), 4294967295U, 0U, 0U, 0.0f);
            FKHit _S1352 = (fcptTraverseInstanceBVH((_S1350), (true), (4.294967296e+09f), (false), (_S1351), (false)));
            hit_4 = _S1352;
            b_6 = b_8;
            throughput_2 = throughput_4;
            threshold_0 = _S1304;
            width_3 = width_6;
            sky_pdf_0 = _S1349;
        }
        if(_S1243 != int(1))
        {
            width_3 = wavelength_2;
            throughput_2 = chain_throughput_0;
            b_6 = layer_0;
            passes_0 = true;
            break;
        }
        ended_0 = _S1245;
        spread_1 = threshold_0;
        passes_0 = false;
        break;
    }
    if(passes_0)
    {
        return ended_0;
    }
    bool _S1353 = b_6 == 4294967295U;
    bool _S1354 = ((&hit_4)->instance_index) == 4294967295U;
    if(_S1354)
    {
        bool _S1355 = !(&nee_vertex_0)->none;
        float _S1356 = _slang_select(_S1355, sky_pdf_0,0.0f);
        float _S1357 = escapeWeight_0(_S1356, (&ray_2)->unit_direction);
        float3  _S1358 = environment_0((&ray_2)->unit_direction, b_6, (&prev_0)->lobe);
        float3  _S1359 = throughput_2 * _S1358;
        if(replay_1)
        {
            bool _S1360 = b_6 == _S1260;
            if(_S1360)
            {
                passes_0 = _S1249 == 3U;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                return Shift_x24init_0(_S1359 * make_float3 (_S1357) / make_float3 (r_8->jac), density_2 / r_8->jac);
            }
            if(_S1259)
            {
                passes_0 = _S1256;
            }
            else
            {
                passes_0 = false;
            }
            if(passes_0)
            {
                passes_0 = b_6 == _S1247;
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
                return Shift_x24init_0(_S1359 * make_float3 (_S1357), 1.0f);
            }
            return _S1245;
        }
        Reservoir candidate_4 = chain_0;
        uint _S1361 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1362 = _S1361 == 1U;
        if(_S1362)
        {
            uint _S1363 = extractBits_0((&chain_0)->path, 5U, 5U);
            bool _S1364 = _S1363 == b_6;
            float _S1365 = _slang_select(_S1364, 1.0f,_S1357);
            float3  _S1366 = safeDivide(_S1359 * make_float3 (_S1365), _S1244);
            (&candidate_4)->radiance = _S1366;
        }
        else
        {
            bool _S1367 = (&prev_0)->rough;
            if(_S1367)
            {
                uint _S1368 = insertBits_0(0U, b_6 + 1U, 5U, 5U);
                uint _S1369 = insertBits_0(_S1368, 3U, 10U, 2U);
                uint _S1370 = insertBits_0(_S1369, (&prev_0)->lobe, 15U, 3U);
                bool _S1371 = (&prev_0)->inside;
                uint _S1372 = _slang_select(_S1371, 1U,0U);
                uint _S1373 = insertBits_0(_S1370, _S1372, 22U, 1U);
                (&candidate_4)->path = _S1373;
                (&candidate_4)->jac = (&prev_0)->pdf;
                (&candidate_4)->dir = (&ray_2)->unit_direction;
            }
        }
        float3  _S1374 = _S1359 * make_float3 (_S1357);
        Reservoir _S1375 = withEnd(candidate_4, 3U, b_6, _S1374);
        offer(sel_7, _S1375, _S1374 * make_float3 (scale_3) / make_float3 (density_2));
        return _S1245;
    }
    float3  _S1376 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
    (&ray_2)->origin = _S1376;
    bool _S1377 = (fcptVaryingUsed());
    if(_S1377)
    {
        passes_0 = filling_2 != 4294967295U;
    }
    else
    {
        passes_0 = false;
    }
    if(passes_0)
    {
        bool _S1378 = !replay_1;
        if(_S1378)
        {
            float3  _S1379 = throughput_2 * glowed_0 / make_float3 (density_2);
            float3  _S1380 = sel_7->glow + _S1379;
            sel_7->glow = _S1380;
        }
        float3  _S1381 = throughput_2 * weight_1;
        throughput_2 = _S1381;
    }
    else
    {
        float3  _S1382 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
        float3  _S1383 = throughput_2 * _S1382;
        throughput_2 = _S1383;
    }
    float _S1384 = width_3 + spread_1 * (&hit_4)->distance;
    uint _S1385 = b_6 + 1U;
    b_6 = _S1385;
    layer_0 = 0U;
    width_3 = _S1384;
    passes_0 = false;
    threshold_0 = 0.0f;
    turned_1 = false;
    is_inside_5 = false;
    wavelength_2 = 0.0f;
    chain_throughput_0 = _S1244;
    float3  reconnection_0 = _S1244;
    viewed_0 = _S1353;
    for(;;)
    {
        bool _S1386 = ((&hit_4)->is_point_light) == 1U;
        if(replay_1)
        {
            _S1241 = _S1249 == 1U;
        }
        else
        {
            _S1241 = false;
        }
        if(_S1241)
        {
            _S1242 = b_6 == _S1248;
        }
        else
        {
            _S1242 = false;
        }
        bool _S1387;
        if(_S1242)
        {
            bool _S1388 = ((&hit_4)->instance_index) != (_S1261.instance_index);
            if(_S1388)
            {
                _S1387 = true;
            }
            else
            {
                _S1387 = ((&hit_4)->triangle_index) != (_S1261.triangle_index);
            }
        }
        else
        {
            _S1387 = false;
        }
        if(_S1387)
        {
            return _S1245;
        }
        FKMedium _S1389 = Medium_x24init_0(_S1244, _S1244, 0.0f);
        BSDFMaterial _S1390 = Material_x24init_0(_S1244, _S1244, 0.0f, 0.0f, 0.0f, 0.0f, _S1244, throughput_3, 1.0f, _S1244, _S1244, 0.5f, 0.0f, 0.0f, _S1244, 0.0f, _S1244, 0.0f);
        FKMedium _S1391 = _S1389;
        FKSurface _S1392 = Surface_x24init_0(_S1244, _S1244, 0.0f, &_S1390, false, 0U, 1.0f, false, &_S1391, 4294967295U, _S1244);
        bool _S1393 = !_S1386;
        bool scatter_2;
        bool is_inside_6;
        float geometry_density_0;
        float3  throughput_5;
        float3  front_n_0;
        FKSurface surface_12;
        if(_S1393)
        {
            uint _S1394 = stream(_S1272, b_6);
            uint _S1395 = arrivalLobe_0(b_6, (&prev_0)->lobe);
            FKSurface _S1396 = (fcptSurfaceAtPath((hit_4), ((&ray_2)->origin), (_S1394), (width_3), (layer_0), (b_6), (_S1395), ((&ray_2)->unit_direction)));
            bool _S1397 = !passes_0;
            FKSurface _S1398 = _S1396;
            FKSurface _S1399 = emitting_0(&_S1398, _S1397);
            uint _S1400 = stream(_S1272, b_6 + 256U);
            Random _S1401 = pcg(_S1400);
            FKSurface _S1402 = _S1399;
            FKSurface _S1403 = uncovered_0(&_S1402, _S1401.value);
            float _S1404 = facingSign(_S1403.material.transmission, _S1403.geometry_n, (&ray_2)->unit_direction);
            bool _S1405 = _S1404 < 0.0f;
            bool _S1406 = (_S1403.material.transmission) > 0.0f;
            if(_S1406)
            {
                bool _S1407 = arrivesBehind_0((&ray_2)->unit_direction, _S1403.geometry_n);
                scatter_2 = _S1407;
            }
            else
            {
                scatter_2 = false;
            }
            FKSurface _S1408 = _S1403;
            FKSurface _S1409 = facingRay_0(&_S1408, (&ray_2)->unit_direction);
            if(passes_0)
            {
                bool _S1410 = arrivesBehind_0((&ray_2)->unit_direction, _S1409.geometry_n);
                is_inside_6 = _S1410;
            }
            else
            {
                is_inside_6 = scatter_2;
            }
            if(is_inside_6)
            {
                float3  _S1411 = beerLambert((&hit_4)->distance, _S1409.material.absorption);
                float3  _S1412 = throughput_2 * _S1411;
                throughput_5 = _S1412;
            }
            else
            {
                throughput_5 = throughput_2;
            }
            bool _S1413 = !_S1409.skip;
            float geometry_density_1 = (F32_abs((dot_0(_S1409.geometry_n, (&ray_2)->unit_direction)))) / ((&hit_4)->distance * (&hit_4)->distance);
            bool _S1414 = b_6 == _S1385;
            if(_S1414)
            {
                float _S1415 = 0.00251327408477664f / geometry_density_1;
                geometry_density_0 = _S1415;
            }
            else
            {
                geometry_density_0 = threshold_0;
            }
            float _S1416 = geometry_density_0;
            scatter_2 = _S1413;
            geometry_density_0 = geometry_density_1;
            threshold_0 = _S1416;
            surface_12 = _S1409;
            front_n_0 = _S1403.smooth_n;
            turned_1 = _S1405;
        }
        else
        {
            scatter_2 = false;
            geometry_density_0 = 0.0f;
            surface_12 = _S1392;
            throughput_5 = throughput_2;
            front_n_0 = _S1244;
            is_inside_6 = is_inside_5;
        }
        bool _S1417;
        if(scatter_2)
        {
            _S1417 = (&prev_0)->rough;
        }
        else
        {
            _S1417 = false;
        }
        bool _S1418;
        if(_S1417)
        {
            _S1418 = ((&prev_0)->pdf * geometry_density_0 * threshold_0) <= 1.0f;
        }
        else
        {
            _S1418 = false;
        }
        FKSurface _S1419 = surface_12;
        FKSurface _S1420 = surface_12;
        float _S1421 = dot_0(surface_12.smooth_n, - (&ray_2)->unit_direction);
        bool _S1422 = (fcptDispersionUsed());
        bool _S1423;
        if(_S1422)
        {
            _S1423 = wavelength_2 == 0.0f;
        }
        else
        {
            _S1423 = false;
        }
        bool _S1424;
        if(_S1423)
        {
            _S1424 = scatter_2;
        }
        else
        {
            _S1424 = false;
        }
        bool _S1425;
        if(_S1424)
        {
            bool _S1426 = dispersive(_S1419.material);
            _S1425 = _S1426;
        }
        else
        {
            _S1425 = false;
        }
        float3  throughput_6;
        if(_S1425)
        {
            uint _S1427 = stream(_S1272, 512U);
            Random _S1428 = pcg(_S1427);
            float2  _S1429 = sampleWavelength(_S1428.value);
            float _S1430 = _S1429.x;
            float3  _S1431 = wavelengthWeights(_S1430);
            float3  _S1432 = throughput_5 * (_S1431 / make_float3 (_S1429.y));
            wavelength_2 = _S1430;
            throughput_6 = _S1432;
        }
        else
        {
            throughput_6 = throughput_5;
        }
        BSDFMaterial refractive_0 = _S1419.material;
        float _S1433 = dispersedIor(_S1419.material.ior, _S1419.material.dispersion, wavelength_2);
        bool _S1434 = wavelength_2 > 0.0f;
        float _S1435 = _slang_select(_S1434, _S1433,_S1419.material.ior);
        (&refractive_0)->ior = _S1435;
        float2  _S1436 = vertexEta(refractive_0, _S1421);
        bool _S1437;
        if(scatter_2)
        {
            uint _S1438 = (fcptMaxBounces());
            bool _S1439 = b_6 >= _S1438;
            if(_S1439)
            {
                _S1437 = true;
            }
            else
            {
                bool _S1440 = neeDecision(_S1419.material, _S1421, _S1436.x, _S1436.y);
                _S1437 = _S1440;
            }
        }
        else
        {
            _S1437 = false;
        }
        bool _S1441;
        if(passes_0)
        {
            _S1441 = true;
        }
        else
        {
            _S1441 = layer_0 != 0U;
        }
        bool nee_0;
        if(_S1441)
        {
            nee_0 = false;
        }
        else
        {
            nee_0 = _S1437;
        }
        bool _S1442 = (fcptHairUsed());
        bool _S1443;
        if(_S1442)
        {
            float3  _S1444 = surface_12.hair;
            _S1443 = (dot_0(_S1444, _S1444)) > 0.0f;
        }
        else
        {
            _S1443 = false;
        }
        bool _S1445;
        if(_S1443)
        {
            _S1445 = true;
        }
        else
        {
            BSDFMaterial _S1446 = _S1419.material;
            bool _S1447 = isTranslucent_0(&_S1446);
            _S1445 = _S1447;
        }
        bool _S1448;
        if(_S1445)
        {
            _S1448 = true;
        }
        else
        {
            bool _S1449 = (_S1419.material.transmission) > 0.0f;
            if(_S1449)
            {
                uint _S1450 = (fcptLayers((hit_4)));
                _S1448 = _S1450 == 1U;
            }
            else
            {
                _S1448 = false;
            }
        }
        float3  _S1451 = emitted_0(_S1419.material.emissive, (&ray_2)->unit_direction, front_n_0);
        float3  emission_0;
        if(_S1386)
        {
            float3  _S1452 = (fcptCalculatePointLightContrib(((&hit_4)->instance_index)));
            emission_0 = _S1452;
        }
        else
        {
            emission_0 = _S1451;
        }
        bool _S1453 = !replay_1;
        bool _S1454;
        if(_S1453)
        {
            _S1454 = true;
        }
        else
        {
            _S1454 = b_6 >= _S1260;
        }
        bool _S1455;
        if(_S1454)
        {
            float _S1456 = rgb_to_greyscale(emission_0);
            _S1455 = _S1456 > 0.0f;
        }
        else
        {
            _S1455 = false;
        }
        float3  emission_1;
        if(_S1455)
        {
            NEEVertex _S1457 = nee_vertex_0;
            FKHit _S1458 = hit_4;
            float _S1459 = emissionWeight_0(&_S1457, &_S1458, (&ray_2)->origin);
            float3  emission_2 = emission_0 * make_float3 (_S1459);
            emission_1 = emission_2;
        }
        else
        {
            emission_1 = emission_0;
        }
        bool _S1460;
        if(replay_1)
        {
            _S1460 = _S1249 == 1U;
        }
        else
        {
            _S1460 = false;
        }
        bool _S1461;
        if(_S1460)
        {
            _S1461 = b_6 > _S1248;
        }
        else
        {
            _S1461 = false;
        }
        bool _S1462;
        if(_S1461)
        {
            _S1462 = b_6 == _S1247;
        }
        else
        {
            _S1462 = false;
        }
        bool _S1463;
        if(_S1462)
        {
            bool _S1464 = _S1250 == 1U;
            if(_S1464)
            {
                _S1463 = true;
            }
            else
            {
                _S1463 = _S1250 == 2U;
            }
        }
        else
        {
            _S1463 = false;
        }
        if(_S1463)
        {
            bool _S1465 = _S1386 != (_S1250 == 2U);
            if(_S1465)
            {
                return _S1245;
            }
            return Shift_x24init_0(throughput_6 * emission_1 / make_float3 (r_8->jac), density_2 / r_8->jac);
        }
        uint _S1466 = extractBits_0((&chain_0)->path, 10U, 2U);
        bool _S1467 = _S1466 == 1U;
        Reservoir here_0 = chain_0;
        uint _S1468 = insertBits_0(0U, b_6, 5U, 5U);
        uint _S1469 = insertBits_0(_S1468, 1U, 10U, 2U);
        uint _S1470 = insertBits_0(_S1469, (&prev_0)->lobe, 15U, 3U);
        bool _S1471 = (&prev_0)->inside;
        uint _S1472 = _slang_select(_S1471, 1U,0U);
        uint _S1473 = insertBits_0(_S1470, _S1472, 22U, 1U);
        (&here_0)->path = _S1473;
        uint _S1474 = (&here_0)->path;
        uint _S1475 = _slang_select(_S1434, 1U,0U);
        uint _S1476 = insertBits_0(_S1474, _S1475, 23U, 1U);
        (&here_0)->path = _S1476;
        float _S1477 = (&prev_0)->pdf * geometry_density_0;
        (&here_0)->jac = _S1477;
        fcptWithReservoirHit((&here_0), (&hit_4));
        bool _S1478;
        if(replay_1)
        {
            _S1478 = _S1249 == 1U;
        }
        else
        {
            _S1478 = false;
        }
        bool _S1479;
        if(_S1478)
        {
            _S1479 = b_6 == _S1248;
        }
        else
        {
            _S1479 = false;
        }
        bool _S1480 = b_6 == _S1260;
        bool _S1481;
        if(_S1480)
        {
            bool _S1482 = !scatter_2;
            if(_S1482)
            {
                _S1481 = true;
            }
            else
            {
                bool _S1483 = _S1249 != 1U;
                if(_S1483)
                {
                    _S1481 = _S1249 != 3U;
                }
                else
                {
                    _S1481 = false;
                }
            }
        }
        else
        {
            _S1481 = false;
        }
        bool _S1484;
        if(_S1481)
        {
            _S1484 = _S1249 == 2U;
        }
        else
        {
            _S1484 = false;
        }
        bool _S1485;
        if(_S1484)
        {
            _S1485 = !_S1418;
        }
        else
        {
            _S1485 = false;
        }
        bool _S1486;
        if(_S1485)
        {
            _S1486 = _S1250 != 4U;
        }
        else
        {
            _S1486 = false;
        }
        bool _S1487 = _S1248 == _S1247;
        bool _S1488;
        if(_S1487)
        {
            _S1488 = _S1250 == 0U;
        }
        else
        {
            _S1488 = false;
        }
        bool _S1489;
        if(_S1488)
        {
            _S1489 = ((&hit_4)->instance_index) == (_S1261.instance_index);
        }
        else
        {
            _S1489 = false;
        }
        bool _S1490;
        if(_S1489)
        {
            _S1490 = ((&hit_4)->triangle_index) == (_S1261.triangle_index);
        }
        else
        {
            _S1490 = false;
        }
        bool _S1491;
        if(_S1490)
        {
            _S1491 = _S1418;
        }
        else
        {
            _S1491 = false;
        }
        bool _S1492 = _slang_select(_S1479, _S1491,_S1486);
        bool _S1493;
        if(nee_0)
        {
            _S1493 = _slang_select(replay_1, _S1492,scatter_2);
        }
        else
        {
            _S1493 = false;
        }
        TreeSample _S1494 = TreeSample_x24init_0(_S1244, _S1244, 0.0f, 0U);
        uint2  _S1495 = make_uint2 (0U);
        float2  _S1496 = make_float2 (0.0f);
        FKHit _S1497 = Hit_x24init_0(_S1496, 4294967295U, 0U, 0U, 0.0f);
        FKHit _S1498 = _S1497;
        ShadowContext _S1499 = ShadowContext_x24init_0(_S1244, _S1244, _S1495, _S1244, 0U, 0U, false, 0.0f, 0.0f, &_S1498, false);
        bool _S1500;
        if(nee_0)
        {
            _S1500 = _S1454;
        }
        else
        {
            _S1500 = false;
        }
        ShadowContext context_5;
        if(_S1500)
        {
            uint _S1501 = arrivalLobe_0(b_6, (&prev_0)->lobe);
            FKMedium _S1502 = (fcptOutsideMedium((hit_4)));
            FKSurface _S1503 = surface_12;
            FKHit _S1504 = hit_4;
            FKMedium _S1505 = _S1502;
            ShadowContext _S1506 = shadowContext_0(&_S1503, turned_1, extinction_in_0, filling_2, (&ray_2)->unit_direction, b_6, _S1501, (&hit_4)->distance, width_3, &_S1504, _S1443, &_S1505);
            context_5 = _S1506;
        }
        else
        {
            context_5 = _S1499;
        }
        float3  throughput_7;
        float3  lit_0;
        if(_S1493)
        {
            float3  _S1507 = (&ray_2)->origin;
            if(_S1443)
            {
                throughput_7 = _S1244;
            }
            else
            {
                throughput_7 = _S1420.smooth_n;
            }
            FKSurface _S1508 = surface_12;
            uint _S1509 = stream(_S1272, b_6 + 64U);
            ShadowContext _S1510 = context_5;
            TreeSample _S1511 = sampleLightTree_0(_S1507, throughput_7, surface_12.geometry_n, surface_12.geometry_offset, _S1448, _S1509, &_S1510);
            bool _S1512 = any_1((_S1511.radiance) != _S1244);
            if(_S1512)
            {
                if(_S1443)
                {
                    uint _S1513 = (fcptMaxBounces());
                    bool _S1514 = b_6 < _S1513;
                    FKSurface _S1515 = surface_12;
                    TreeSample _S1516 = _S1511;
                    float3  _S1517 = hairLight_0(&_S1515, (&ray_2)->unit_direction, &_S1516, _S1514);
                    lit_0 = _S1517;
                }
                else
                {
                    float _S1518 = _S1436.x;
                    float _S1519 = _S1436.y;
                    uint _S1520 = (fcptMaxBounces());
                    bool _S1521 = b_6 < _S1520;
                    TreeSample _S1522 = _S1511;
                    BSDFMaterial _S1523 = _S1419.material;
                    float3  _S1524 = lightBSDF_0((&ray_2)->unit_direction, &_S1522, _S1420.smooth_n, _S1508.geometry_n, &_S1523, _S1518, _S1519, _S1521, surface_12.random_state);
                    lit_0 = _S1524;
                }
            }
            else
            {
                lit_0 = _S1244;
            }
            light_3 = _S1511;
        }
        else
        {
            light_3 = _S1494;
            lit_0 = _S1244;
        }
        bool viewed_1;
        bool refracted_4;
        bool wrong_side_0;
        bool _S1525;
        bool _S1526;
        float density_4;
        if(_S1479)
        {
            bool _S1527 = !_S1418;
            if(_S1527)
            {
                return _S1245;
            }
            uint _S1528 = extractBits_0(_S1246, 23U, 1U);
            bool _S1529 = _S1434 != (_S1528 == 1U);
            if(_S1529)
            {
                return _S1245;
            }
            float3  throughput_8 = throughput_6 * make_float3 (geometry_density_0);
            float density_5 = density_2 * geometry_density_0;
            if(_S1487)
            {
                viewed_1 = _S1250 == 1U;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                return Shift_x24init_0(throughput_8 * emission_1 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1487)
            {
                refracted_4 = _S1250 == 0U;
            }
            else
            {
                refracted_4 = false;
            }
            if(refracted_4)
            {
                bool _S1530 = !nee_0;
                if(_S1530)
                {
                    passes_0 = true;
                }
                else
                {
                    float _S1531 = rgb_to_greyscale(light_3.radiance);
                    passes_0 = !(_S1531 > 0.0f);
                }
                if(passes_0)
                {
                    return _S1245;
                }
                return Shift_x24init_0(throughput_8 * lit_0 / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            if(_S1487)
            {
                wrong_side_0 = _S1250 == 4U;
            }
            else
            {
                wrong_side_0 = false;
            }
            if(wrong_side_0)
            {
                bool _S1532 = !nee_0;
                if(_S1532)
                {
                    return _S1245;
                }
                float _S1533 = environmentPdf_0(r_8->dir);
                float3  _S1534 = skyBSDF((&ray_2)->unit_direction, r_8->dir, surface_12, _S1436, is_inside_6, _S1533, surface_12.random_state);
                return Shift_x24init_0(throughput_8 * _S1534 * r_8->radiance / make_float3 (r_8->jac), density_5 / r_8->jac);
            }
            uint _S1535 = extractBits_0(_S1246, 21U, 1U);
            bool _S1536 = nee_0 != (_S1535 == 1U);
            if(_S1536)
            {
                return _S1245;
            }
            throughput_7 = throughput_8;
            density_4 = density_5;
        }
        else
        {
            if(replay_1)
            {
                viewed_1 = _S1480;
            }
            else
            {
                viewed_1 = false;
            }
            if(viewed_1)
            {
                bool _S1537 = !scatter_2;
                if(_S1537)
                {
                    refracted_4 = true;
                }
                else
                {
                    bool _S1538 = _S1249 != 1U;
                    if(_S1538)
                    {
                        refracted_4 = _S1249 != 3U;
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
                bool _S1539 = _S1249 == 2U;
                if(_S1539)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1418;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1250 == 4U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    if(_S1443)
                    {
                        return _S1245;
                    }
                    uint _S1540 = stream(_S1272, b_6 + 448U);
                    FKRay _S1541 = ray_2;
                    FKSurface _S1542 = surface_12;
                    ShadowContext _S1543 = context_5;
                    SkySample _S1544 = sampleSky_0(&_S1541, &_S1542, _S1436, is_inside_6, _S1540, surface_12.random_state, &_S1543);
                    return Shift_x24init_0(throughput_6 * _S1544.color, 1.0f);
                }
                if(_S1539)
                {
                    passes_0 = nee_0;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = !_S1418;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    float _S1545 = rgb_to_greyscale(light_3.radiance);
                    bool _S1546 = !(_S1545 > 0.0f);
                    if(_S1546)
                    {
                        return _S1245;
                    }
                    return Shift_x24init_0(throughput_6 * lit_0, 1.0f);
                }
                if(_S1259)
                {
                    passes_0 = _S1250 == 2U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = _S1386;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_6 * emission_1, 1.0f);
                }
                if(_S1259)
                {
                    passes_0 = _S1250 == 1U;
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
                    passes_0 = !_S1418;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(throughput_6 * emission_1, 1.0f);
                }
                return _S1245;
            }
            else
            {
                if(_S1453)
                {
                    wrong_side_0 = scatter_2;
                }
                else
                {
                    wrong_side_0 = false;
                }
                if(wrong_side_0)
                {
                    bool _S1547 = b_6 > 0U;
                    if(_S1547)
                    {
                        Reservoir candidate_5 = chain_0;
                        if(_S1467)
                        {
                            float3  _S1548 = safeDivide(throughput_6 * emission_1, chain_throughput_0);
                            (&candidate_5)->radiance = _S1548;
                        }
                        else
                        {
                            if(_S1418)
                            {
                                candidate_5 = here_0;
                            }
                        }
                        float3  _S1549 = throughput_6 * emission_1;
                        Reservoir _S1550 = withEnd(candidate_5, 1U, b_6, _S1549);
                        offer(sel_7, _S1550, _S1549 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    else
                    {
                        float3  _S1551 = throughput_6 * emission_1;
                        float3  _S1552 = sel_7->glow + _S1551;
                        sel_7->glow = _S1552;
                    }
                    if(nee_0)
                    {
                        float3  _S1553 = throughput_6 * lit_0;
                        Reservoir candidate_6 = chain_0;
                        if(_S1467)
                        {
                            float3  _S1554 = safeDivide(_S1553, chain_throughput_0);
                            (&candidate_6)->radiance = _S1554;
                        }
                        else
                        {
                            if(_S1418)
                            {
                                candidate_6 = here_0;
                                uint _S1555 = insertBits_0((&candidate_6)->path, 1U, 21U, 1U);
                                (&candidate_6)->path = _S1555;
                                (&candidate_6)->dir = light_3.dir;
                                (&candidate_6)->radiance = light_3.radiance;
                            }
                            else
                            {
                                uint _S1556 = insertBits_0(0U, b_6 + 1U, 5U, 5U);
                                uint _S1557 = insertBits_0(_S1556, 2U, 10U, 2U);
                                (&candidate_6)->path = _S1557;
                            }
                        }
                        Reservoir _S1558 = withEnd(candidate_6, 0U, b_6, _S1553);
                        offer(sel_7, _S1558, _S1553 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                    if(nee_0)
                    {
                        if(_S1443)
                        {
                            _S1525 = false;
                        }
                        else
                        {
                            bool _S1559 = environmentMapped_0();
                            _S1525 = _S1559;
                        }
                    }
                    else
                    {
                        _S1525 = false;
                    }
                    if(_S1525)
                    {
                        uint _S1560 = (fcptMaxBounces());
                        _S1526 = b_6 < _S1560;
                    }
                    else
                    {
                        _S1526 = false;
                    }
                    if(_S1526)
                    {
                        uint _S1561 = stream(_S1272, b_6 + 448U);
                        FKRay _S1562 = ray_2;
                        FKSurface _S1563 = surface_12;
                        ShadowContext _S1564 = context_5;
                        SkySample _S1565 = sampleSky_0(&_S1562, &_S1563, _S1436, is_inside_6, _S1561, surface_12.random_state, &_S1564);
                        float3  _S1566 = throughput_6 * _S1565.color;
                        Reservoir candidate_7 = chain_0;
                        if(_S1467)
                        {
                            float3  _S1567 = safeDivide(_S1566, chain_throughput_0);
                            (&candidate_7)->radiance = _S1567;
                        }
                        else
                        {
                            if(_S1418)
                            {
                                candidate_7 = here_0;
                                uint _S1568 = insertBits_0((&candidate_7)->path, 1U, 21U, 1U);
                                (&candidate_7)->path = _S1568;
                                (&candidate_7)->dir = _S1565.dir;
                                (&candidate_7)->radiance = _S1565.radiance;
                            }
                            else
                            {
                                uint _S1569 = insertBits_0(0U, b_6 + 1U, 5U, 5U);
                                uint _S1570 = insertBits_0(_S1569, 2U, 10U, 2U);
                                (&candidate_7)->path = _S1570;
                            }
                        }
                        Reservoir _S1571 = withEnd(candidate_7, 4U, b_6, _S1566);
                        offer(sel_7, _S1571, _S1566 * make_float3 (scale_3) / make_float3 (density_2));
                    }
                }
            }
            throughput_7 = throughput_6;
            density_4 = density_2;
        }
        bool _S1572;
        bool _S1573;
        bool _S1574;
        bool straight_0;
        bool _S1575;
        bool _S1576;
        bool _S1577;
        bool _S1578;
        bool _S1579;
        bool _S1580;
        bool _S1581;
        bool _S1582;
        bool _S1583;
        bool _S1584;
        bool _S1585;
        bool _S1586;
        bool _S1587;
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
                viewed_1 = _S1480;
            }
            else
            {
                viewed_1 = false;
            }
            uint _S1588 = extractBits_0(_S1246, 15U, 3U);
            uint _S1589 = extractBits_0(_S1246, 18U, 3U);
            uint _S1590 = _slang_select(_S1479, _S1589,_S1588);
            float3  _S1591 = r_8->dir;
            bool refracted_5 = _S1590 == 1U;
            SampleBSDF _S1592 = SampleBSDF_x24init_0(_S1244, _S1244, 0U, false, 0U, 0.0f);
            SampleBSDF lobe_5 = _S1592;
            float3  reconnection_1;
            if(viewed_1)
            {
                uint _S1593 = extractBits_0(_S1246, 22U, 1U);
                bool _S1594 = is_inside_6 != (_S1593 == 1U);
                if(_S1594)
                {
                    return _S1245;
                }
                bool _S1595 = _S1249 == 1U;
                if(_S1595)
                {
                    float3  _S1596 = (fcptHitPosition((_S1261)));
                    throughput_9 = _S1596;
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
                    BSDFMaterial _S1597 = _S1419.material;
                    bool _S1598 = isTranslucent_0(&_S1597);
                    if(_S1598)
                    {
                        refracted_4 = _S1590 == 0U;
                    }
                    else
                    {
                        refracted_4 = false;
                    }
                    if(refracted_4)
                    {
                        float3  _S1599 = throughput_9 - (&ray_2)->origin;
                        float3  _S1600 = _slang_select(_S1595, _S1599,_S1591);
                        wrong_side_0 = (dot_0(_S1420.smooth_n, _S1600) * _S1421) < 0.0f;
                    }
                    else
                    {
                        wrong_side_0 = false;
                    }
                    refracted_4 = wrong_side_0;
                }
                if(_S1595)
                {
                    float3  _S1601 = (&ray_2)->origin;
                    FKSurface _S1602 = surface_12;
                    float3  _S1603 = - _S1420.smooth_n;
                    bool _S1604 = is_inside_6 != refracted_4;
                    float3  _S1605 = _slang_select(_S1604, _S1603,_S1420.smooth_n);
                    float3  _S1606 = throughput_9 - (_S1601 + make_float3 (_S1602.geometry_offset) * _S1605);
                    float3  _S1607 = ((((_S1606)) * make_float3(rnorm3df(((_S1606)).x, ((_S1606)).y, ((_S1606)).z))));
                    reconnection_1 = _S1607;
                }
                else
                {
                    reconnection_1 = _S1591;
                }
                if(_S1443)
                {
                    wrong_side_0 = false;
                }
                else
                {
                    bool _S1608 = wrongSide_0(is_inside_6, refracted_4, reconnection_1, surface_12.geometry_n);
                    wrong_side_0 = _S1608;
                }
                if(wrong_side_0)
                {
                    return _S1245;
                }
                float3  _S1609 = throughput_9;
                throughput_9 = reconnection_1;
                b_9 = _S1590;
                wrong_side_0 = false;
                reconnection_1 = _S1609;
            }
            else
            {
                bool _S1610 = !_S1479;
                if(_S1610)
                {
                    SampleBSDF bsdf_sampled_0;
                    SampleBSDF _S1611;
                    if(_S1443)
                    {
                        SampleBSDF _S1612 = (fcptSampleHair((surface_12.hair), (_S1419.material.albedo), (_S1419.material.specular_tint), ((&ray_2)->unit_direction), (surface_12.random_state)));
                        _S1611 = _S1612;
                    }
                    else
                    {
                        SampleBSDF _S1613 = sampleBSDF((&ray_2)->unit_direction, _S1420.smooth_n, _S1419.material, _S1436.x, _S1436.y, surface_12.random_state, _S1496);
                        _S1611 = _S1613;
                    }
                    bsdf_sampled_0 = _S1611;
                    if(_S1443)
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
                            return _S1245;
                        }
                        break;
                    }
                    if(_S1443)
                    {
                        wrong_side_0 = false;
                    }
                    else
                    {
                        bool _S1614 = wrongSide_0(is_inside_6, (&bsdf_sampled_0)->refracted, (&bsdf_sampled_0)->unit_direction, surface_12.geometry_n);
                        wrong_side_0 = _S1614;
                    }
                    if(wrong_side_0)
                    {
                        _S1525 = (_S1419.material.transmission) > 0.0f;
                    }
                    else
                    {
                        _S1525 = false;
                    }
                    if(_S1525)
                    {
                        SampleBSDF _S1615 = sampleBSDF((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n, _S1419.material, _S1436.x, _S1436.y, (&bsdf_sampled_0)->random_state, _S1496);
                        (&bsdf_sampled_0)->unit_direction = _S1615.unit_direction;
                        (&bsdf_sampled_0)->refracted = _S1615.refracted;
                        (&bsdf_sampled_0)->throughput = _S1615.throughput;
                        (&bsdf_sampled_0)->lobe = _S1615.lobe;
                    }
                    else
                    {
                        if(wrong_side_0)
                        {
                            float3  _S1616 = (&bsdf_sampled_0)->unit_direction - make_float3 (2.0f * dot_0((&bsdf_sampled_0)->unit_direction, surface_12.geometry_n)) * surface_12.geometry_n;
                            (&bsdf_sampled_0)->unit_direction = _S1616;
                        }
                    }
                    uint _S1617 = (&bsdf_sampled_0)->lobe;
                    float3  _S1618 = (&bsdf_sampled_0)->unit_direction;
                    bool _S1619 = (&bsdf_sampled_0)->refracted;
                    lobe_5 = bsdf_sampled_0;
                    float _S1620 = (&bsdf_sampled_0)->pdf;
                    float _S1621 = _slang_select(wrong_side_0, 0.0f,_S1620);
                    (&lobe_5)->pdf = _S1621;
                    throughput_9 = _S1618;
                    b_9 = _S1617;
                    refracted_4 = _S1619;
                }
                else
                {
                    throughput_9 = _S1591;
                    b_9 = _S1590;
                    wrong_side_0 = false;
                    refracted_4 = refracted_5;
                }
                reconnection_1 = reconnection_0;
            }
            if(viewed_1)
            {
                _S1525 = true;
            }
            else
            {
                _S1525 = _S1479;
            }
            float3  chain_throughput_1;
            if(_S1525)
            {
                if(_S1443)
                {
                    SampleBSDF _S1622 = (fcptConnectHair((surface_12.hair), (_S1419.material.albedo), (_S1419.material.specular_tint), ((&ray_2)->unit_direction), (throughput_9)));
                    lobe_5 = _S1622;
                }
                else
                {
                    float3  _S1623 = (&ray_2)->unit_direction;
                    float3  _S1624 = negate_0(_S1623);
                    float _S1625 = sign_0(_S1421);
                    float3  _S1626 = _S1420.smooth_n * make_float3 (_S1625);
                    float _S1627 = dot_0(_S1626, throughput_9);
                    float _S1628 = _S1419.material.roughness;
                    float _S1629 = _S1628 * _S1628;
                    AnisotropicFrame _S1630 = anisotropicFrame(_S1419.material, _S1626);
                    SheenProfile _S1631 = sheenProfile(_S1624, _S1626, _S1419.material);
                    float3  _S1632 = reflectedHalf(_S1623, throughput_9);
                    bool _S1633 = b_9 == 1U;
                    if(_S1633)
                    {
                        float3  _S1634 = refractedHalf(_S1623, throughput_9, _S1420.smooth_n, _S1436.x, _S1436.y);
                        throughput_10 = _S1634;
                    }
                    else
                    {
                        throughput_10 = _S1632;
                    }
                    bool _S1635 = b_9 == 0U;
                    if(_S1635)
                    {
                        _S1526 = true;
                    }
                    else
                    {
                        _S1526 = b_9 == 6U;
                    }
                    if(_S1526)
                    {
                        float3  _S1636 = sampledHalf(_S1624, _S1626, _S1629, _S1630, surface_12.random_state);
                        throughput_11 = _S1636;
                    }
                    else
                    {
                        throughput_11 = throughput_10;
                    }
                    float _S1637 = _S1436.x;
                    float _S1638 = _S1436.y;
                    Weights _S1639 = lobeWeights(_S1623, _S1624, _S1626, throughput_11, _S1630, _S1631, _S1419.material, _S1637, _S1638);
                    float _S1640 = (F32_abs((_S1421)));
                    float _S1641 = vndfPDF(_S1624, throughput_11, _S1626, _S1640, _S1629, _S1630, _S1639.v_dot_h);
                    switch(b_9)
                    {
                    case 0U:
                        {
                            float _S1642 = diffusePDF(_S1627, _S1640, _S1419.material, _S1639);
                            float3  _S1643 = diffuseBSDF(throughput_9, _S1626, _S1419.material, _S1639);
                            density_6 = _S1642;
                            chain_throughput_1 = _S1643;
                            break;
                        }
                    case 1U:
                        {
                            float _S1644 = refractPDF(dot_0(throughput_9, throughput_11), _S1641, _S1639, _S1637, _S1638);
                            float3  _S1645 = refractBSDF(throughput_9, _S1626, _S1629, _S1630, _S1419.material, _S1639);
                            density_6 = _S1644;
                            chain_throughput_1 = _S1645;
                            break;
                        }
                    case 4U:
                        {
                            float _S1646 = sheenVelvetPDF(_S1627, _S1640, _S1639);
                            float3  _S1647 = sheenVelvetBSDF(throughput_9, _S1624, _S1626, _S1419.material, _S1639);
                            density_6 = _S1646;
                            chain_throughput_1 = _S1647;
                            break;
                        }
                    case 6U:
                        {
                            ToonProfile _S1648 = toonProfile(_S1624, _S1626, _S1419.material);
                            float _S1649 = toonPDF(throughput_9, _S1626, _S1648, _S1639);
                            float3  _S1650 = toonBSDF(throughput_9, _S1626, _S1648, _S1639);
                            density_6 = _S1649;
                            chain_throughput_1 = _S1650;
                            break;
                        }
                    default:
                        {
                            float _S1651 = reflectPDF(_S1641, _S1639);
                            float3  _S1652 = reflectBSDF(throughput_9, _S1626, _S1629, _S1630, _S1639);
                            density_6 = _S1651;
                            chain_throughput_1 = _S1652;
                            break;
                        }
                    }
                    bool _S1653 = density_6 > 0.0f;
                    if(_S1653)
                    {
                        SampleBSDF _S1654 = SampleBSDF_x24init_0(throughput_9, chain_throughput_1, surface_12.random_state, _S1633, b_9, density_6);
                        lobe_5 = _S1654;
                    }
                }
            }
            bool _S1655 = b_9 == 0U;
            if(_S1655)
            {
                _S1526 = true;
            }
            else
            {
                _S1526 = b_9 == 4U;
            }
            if(_S1526)
            {
                _S1572 = true;
            }
            else
            {
                _S1572 = b_9 == 6U;
            }
            if(_S1443)
            {
                _S1573 = false;
            }
            else
            {
                bool _S1656 = !_S1572;
                if(_S1656)
                {
                    bool _S1657 = (_S1419.material.roughness) == 0.0f;
                    if(_S1657)
                    {
                        _S1573 = true;
                    }
                    else
                    {
                        bool _S1658 = b_9 == 1U;
                        if(_S1658)
                        {
                            _S1573 = (_S1436.x) == (_S1436.y);
                        }
                        else
                        {
                            _S1573 = false;
                        }
                    }
                }
                else
                {
                    _S1573 = false;
                }
            }
            bool _S1659 = !_S1443;
            if(_S1659)
            {
                _S1574 = b_9 == 1U;
            }
            else
            {
                _S1574 = false;
            }
            if(_S1574)
            {
                straight_0 = (_S1419.material.ior) == 1.0f;
            }
            else
            {
                straight_0 = false;
            }
            if(viewed_0)
            {
                _S1575 = _S1659;
            }
            else
            {
                _S1575 = false;
            }
            if(_S1575)
            {
                _S1576 = b_9 == 1U;
            }
            else
            {
                _S1576 = false;
            }
            if(_S1576)
            {
                _S1577 = (_S1436.x) == (_S1436.y);
            }
            else
            {
                _S1577 = false;
            }
            BSDFMaterial _S1660 = _S1419.material;
            bool _S1661 = isTranslucent_0(&_S1660);
            if(_S1661)
            {
                _S1578 = _S1655;
            }
            else
            {
                _S1578 = false;
            }
            if(_S1578)
            {
                _S1579 = (dot_0(throughput_9, surface_12.geometry_n)) < 0.0f;
            }
            else
            {
                _S1579 = false;
            }
            if(nee_0)
            {
                _S1580 = !_S1573;
            }
            else
            {
                _S1580 = false;
            }
            if(_S1580)
            {
                _S1581 = !wrong_side_0;
            }
            else
            {
                _S1581 = false;
            }
            if(_S1581)
            {
                float _S1662 = (&lobe_5)->pdf;
                float3  _S1663 = (&ray_2)->origin;
                float3  _S1664 = _slang_select(_S1448, _S1244,_S1420.smooth_n);
                float3  _S1665 = (&ray_2)->origin;
                FKSurface _S1666 = surface_12;
                float3  _S1667 = - _S1420.smooth_n;
                float3  _S1668 = _slang_select(_S1579, _S1667,_S1420.smooth_n);
                NEEVertex _S1669 = NEEVertex_x24init_0(false, _S1662, _S1663, _S1664, _S1665 + make_float3 (_S1666.geometry_offset) * _S1668);
                nee_vertex_0 = _S1669;
            }
            else
            {
                if(_S1443)
                {
                    _S1582 = true;
                }
                else
                {
                    bool _S1670 = b_9 != 1U;
                    if(_S1670)
                    {
                        _S1582 = true;
                    }
                    else
                    {
                        _S1582 = (_S1436.x) != (_S1436.y);
                    }
                }
                if(_S1582)
                {
                    (&nee_vertex_0)->none = true;
                }
            }
            bool _S1671 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1671)
            {
                if(_S1572)
                {
                    _S1582 = true;
                }
                else
                {
                    _S1582 = ((&lobe_5)->pdf * (&prev_0)->cos / ((&hit_4)->distance * (&hit_4)->distance) * threshold_0) <= 1.0f;
                }
            }
            else
            {
                _S1582 = false;
            }
            bool _S1672 = ((&lobe_5)->pdf) > 0.0f;
            if(_S1672)
            {
                if(_S1572)
                {
                    _S1583 = true;
                }
                else
                {
                    _S1583 = (_S1419.material.roughness) >= 0.20000000298023224f;
                }
            }
            else
            {
                _S1583 = false;
            }
            if(_S1479)
            {
                bool _S1673 = !_S1582;
                if(_S1673)
                {
                    return _S1245;
                }
                bool _S1674 = _S1250 != 1U;
                if(_S1674)
                {
                    _S1584 = _S1250 != 2U;
                }
                else
                {
                    _S1584 = false;
                }
                if(_S1584)
                {
                    float _S1675 = (&lobe_5)->pdf;
                    float _S1676 = _slang_select(nee_0, _S1675,0.0f);
                    float _S1677 = escapeWeight_0(_S1676, _S1591);
                    if(_S1487)
                    {
                        passes_0 = _S1256;
                    }
                    else
                    {
                        passes_0 = false;
                    }
                    float _S1678 = _slang_select(passes_0, _S1677,1.0f);
                    return Shift_x24init_0(throughput_7 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf)) * r_8->radiance * make_float3 (_S1678) / make_float3 (r_8->jac), density_4 * (&lobe_5)->pdf / r_8->jac);
                }
                float3  _S1679 = throughput_7 * make_float3 ((&lobe_5)->pdf);
                float _S1680 = density_4 * (&lobe_5)->pdf;
                throughput_10 = _S1679;
                density_6 = _S1680;
            }
            else
            {
                throughput_10 = throughput_7;
                density_6 = density_4;
            }
            uint _S1681 = (fcptLayers((hit_4)));
            bool _S1682 = _S1681 > 1U;
            if(_S1682)
            {
                _S1584 = (b_9 == 1U) != passes_0;
            }
            else
            {
                _S1584 = false;
            }
            if(viewed_1)
            {
                _S1585 = _S1584;
            }
            else
            {
                _S1585 = false;
            }
            if(_S1585)
            {
                return _S1245;
            }
            if(replay_1)
            {
                _S1586 = b_6 <= _S1260;
            }
            else
            {
                _S1586 = false;
            }
            if(_S1586)
            {
                _S1587 = _S1418;
            }
            else
            {
                _S1587 = false;
            }
            bool _S1683;
            if(_S1587)
            {
                _S1683 = _S1582;
            }
            else
            {
                _S1683 = false;
            }
            bool _S1684;
            if(_S1683)
            {
                _S1684 = true;
            }
            else
            {
                if(viewed_1)
                {
                    _S1684 = !_S1583;
                }
                else
                {
                    _S1684 = false;
                }
            }
            if(_S1684)
            {
                return _S1245;
            }
            if(viewed_1)
            {
                float3  _S1685 = throughput_10 * ((&lobe_5)->throughput * make_float3 ((&lobe_5)->pdf));
                float _S1686 = (&lobe_5)->pdf;
                throughput_11 = _S1685;
                sky_pdf_2 = _S1686;
            }
            else
            {
                float3  _S1687 = throughput_10 * max_0((&lobe_5)->throughput, _S1244);
                throughput_11 = _S1687;
                sky_pdf_2 = density_6;
            }
            bool _S1688;
            if(_S1453)
            {
                _S1688 = !_S1467;
            }
            else
            {
                _S1688 = false;
            }
            bool _S1689;
            if(_S1688)
            {
                _S1689 = _S1418;
            }
            else
            {
                _S1689 = false;
            }
            bool _S1690;
            if(_S1689)
            {
                _S1690 = _S1582;
            }
            else
            {
                _S1690 = false;
            }
            if(_S1690)
            {
                chain_0 = here_0;
                uint _S1691 = insertBits_0((&chain_0)->path, b_9, 18U, 3U);
                uint _S1692 = _slang_select(nee_0, 1U,0U);
                uint _S1693 = insertBits_0(_S1691, _S1692, 21U, 1U);
                (&chain_0)->path = _S1693;
                float _S1694 = (&chain_0)->jac * (&lobe_5)->pdf;
                (&chain_0)->jac = _S1694;
                (&chain_0)->dir = throughput_9;
                chain_throughput_1 = throughput_11;
            }
            else
            {
                chain_throughput_1 = chain_throughput_0;
            }
            FKSurface _S1695 = surface_12;
            Vertex _S1696 = Vertex_x24init_0(_S1583, b_9, (&lobe_5)->pdf, (F32_abs((dot_0(surface_12.geometry_n, throughput_9)))), is_inside_6);
            prev_0 = _S1696;
            float _S1697 = (&lobe_5)->pdf;
            bool _S1698 = b_9 == 1U;
            bool _S1699;
            if(_S1698)
            {
                _S1699 = (_S1436.x) == (_S1436.y);
            }
            else
            {
                _S1699 = false;
            }
            float sky_pdf_3 = _slang_select(_S1699, sky_pdf_0,_S1697);
            float _S1700 = _slang_select(_S1443, 0.0f,sky_pdf_3);
            float _S1701 = (F32_min((2.0f * (F32_sqrt((1.0f / (3.14159274101257324f * (&lobe_5)->pdf))))), (3.14159274101257324f)));
            bool _S1702 = !_S1573;
            float _S1703 = _slang_select(_S1702, _S1701,0.0f);
            float _S1704 = spread_1 + _S1703;
            bool _S1705;
            if(refracted_4)
            {
                _S1705 = !_S1579;
            }
            else
            {
                _S1705 = false;
            }
            bool is_inside_7;
            if(_S1705)
            {
                bool _S1706 = !is_inside_6;
                is_inside_7 = _S1706;
            }
            else
            {
                is_inside_7 = is_inside_6;
            }
            FKSurface _S1707 = surface_12;
            bool _S1708 = boundsVolume_0(&_S1707);
            bool _S1709;
            if(_S1708)
            {
                _S1709 = !_S1584;
            }
            else
            {
                _S1709 = false;
            }
            if(_S1709)
            {
                FKSurface faced_2 = surface_12;
                float3  _S1710 = - _S1695.geometry_n;
                float3  _S1711 = _slang_select(turned_1, _S1710,_S1695.geometry_n);
                (&faced_2)->geometry_n = _S1711;
                FKMedium _S1712 = Medium_x24init_0(scatter_in_0, extinction_in_0, g_in_0);
                FKMedium _S1713 = (fcptOutsideMedium((hit_4)));
                FKSurface _S1714 = faced_2;
                FKMedium _S1715 = _S1712;
                FKMedium _S1716 = _S1713;
                MediumSides _S1717 = mediumSides_0(&_S1714, &_S1715, filling_2, (&ray_2)->unit_direction, &_S1716);
                bool _S1718 = ((dot_0(throughput_9, _S1695.geometry_n)) > 0.0f) == ((dot_0(_S1695.geometry_n, (&faced_2)->geometry_n)) > 0.0f);
                float3  _S1719 = _slang_select(_S1718, _S1717.front.scatter,_S1717.behind.scatter);
                scatter_in_0 = _S1719;
                float3  _S1720 = _slang_select(_S1718, _S1717.front.extinction,_S1717.behind.extinction);
                extinction_in_0 = _S1720;
                float _S1721 = _slang_select(_S1718, _S1717.front.g,_S1717.behind.g);
                g_in_0 = _S1721;
                uint _S1722 = _S1717.fillings.x;
                uint _S1723 = _S1717.fillings.y;
                uint _S1724 = _slang_select(_S1718, _S1723,_S1722);
                bool _S1725 = (fcptVaryingUsed());
                uint _S1726 = _slang_select(_S1725, _S1724,4294967295U);
                filling_2 = _S1726;
            }
            (&ray_2)->unit_direction = throughput_9;
            bool _S1727 = !_S1584;
            if(_S1727)
            {
                FKSurface _S1728 = surface_12;
                float _S1729 = _slang_select(straight_0, 0.0f,_S1728.geometry_offset);
                float3  _S1730 = - _S1420.smooth_n;
                bool _S1731 = is_inside_7 != _S1579;
                float3  _S1732 = _slang_select(_S1731, _S1730,_S1420.smooth_n);
                float3  _S1733 = (&ray_2)->origin + make_float3 (_S1729) * _S1732;
                (&ray_2)->origin = _S1733;
            }
            throughput_10 = throughput_11;
            chain_throughput_0 = chain_throughput_1;
            density_6 = sky_pdf_2;
            passes_0 = _S1584;
            viewed_1 = _S1577;
            sky_pdf_2 = _S1700;
            spread_4 = _S1704;
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
        if(_S1453)
        {
            if(_S1386)
            {
                float3  _S1734 = throughput_10 * emission_1;
                Reservoir candidate_8 = chain_0;
                uint _S1735 = extractBits_0((&chain_0)->path, 10U, 2U);
                bool _S1736 = _S1735 == 1U;
                if(_S1736)
                {
                    float3  _S1737 = safeDivide(_S1734, chain_throughput_0);
                    (&candidate_8)->radiance = _S1737;
                }
                Reservoir _S1738 = withEnd(candidate_8, 2U, b_6, _S1734);
                offer(sel_7, _S1738, _S1734 * make_float3 (scale_3) / make_float3 (density_6));
            }
            if(_S1386)
            {
                refracted_4 = true;
            }
            else
            {
                refracted_4 = scatter_2;
            }
            if(refracted_4)
            {
                float _S1739 = survivalProbability(abs_0(throughput_10), density_6);
                density_7 = _S1739;
            }
            else
            {
                density_7 = 1.0f;
            }
            uint _S1740 = stream(_S1272, b_6 + 128U);
            Random _S1741 = pcg(_S1740);
            bool _S1742 = density_7 < (_S1741.value);
            if(_S1742)
            {
                wrong_side_0 = true;
            }
            else
            {
                uint _S1743 = (fcptMaxBounces());
                wrong_side_0 = b_6 >= _S1743;
            }
            if(wrong_side_0)
            {
                break;
            }
            float _S1744 = density_6 * density_7;
            density_7 = _S1744;
        }
        else
        {
            density_7 = density_6;
        }
        uint _S1745 = layer_0 ^ 1U;
        uint _S1746 = _slang_select(passes_0, _S1745,0U);
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
            uint _S1747 = b_9 + 1U;
            b_6 = _S1747;
            layer_0 = _S1746;
            continue;
        }
        FKRay _S1748 = ray_2;
        float _S1749 = distance_1(reconnection_0, (&ray_2)->origin) * 1.0010000467300415f;
        if(replay_1)
        {
            refracted_4 = _S1480;
        }
        else
        {
            refracted_4 = false;
        }
        if(refracted_4)
        {
            wrong_side_0 = _S1249 == 1U;
        }
        else
        {
            wrong_side_0 = false;
        }
        float _S1750 = _slang_select(wrong_side_0, _S1749,4.294967296e+09f);
        bool _S1751 = !_S1443;
        if(straight_0)
        {
            _S1525 = true;
        }
        else
        {
            _S1525 = _S1443;
        }
        FKHit _S1752;
        if(_S1525)
        {
            _S1752 = hit_4;
        }
        else
        {
            _S1752 = _S1497;
        }
        FKHit _S1753 = (fcptTraverseInstanceBVH((_S1748), (_S1393), (_S1750), (_S1751), (_S1752), (viewed_1)));
        hit_4 = _S1753;
        if(replay_1)
        {
            _S1526 = _S1480;
        }
        else
        {
            _S1526 = false;
        }
        if(_S1526)
        {
            _S1572 = _S1249 == 1U;
        }
        else
        {
            _S1572 = false;
        }
        if(_S1572)
        {
            _S1573 = ((&hit_4)->instance_index) == (_S1261.instance_index);
        }
        else
        {
            _S1573 = false;
        }
        if(_S1573)
        {
            _S1574 = ((&hit_4)->triangle_index) == (_S1261.triangle_index);
        }
        else
        {
            _S1574 = false;
        }
        if(_S1574)
        {
            (&hit_4)->uv = _S1261.uv;
            float _S1754 = distance_1(reconnection_0, (&ray_2)->origin);
            (&hit_4)->distance = _S1754;
        }
        if(replay_1)
        {
            _S1575 = _S1480;
        }
        else
        {
            _S1575 = false;
        }
        if(_S1575)
        {
            _S1576 = _S1249 == 3U;
        }
        else
        {
            _S1576 = false;
        }
        if(_S1576)
        {
            _S1577 = ((&hit_4)->instance_index) != 4294967295U;
        }
        else
        {
            _S1577 = false;
        }
        if(_S1577)
        {
            return _S1245;
        }
        Reservoir _S1755 = chain_0;
        uint _S1756 = filling_2;
        for(;;)
        {
            bool _S1757 = (fcptVaryingUsed());
            if(_S1757)
            {
                _S1578 = _S1756 != 4294967295U;
            }
            else
            {
                _S1578 = false;
            }
            float _S1758;
            if(_S1578)
            {
                float _S1759 = (fcptMajorant((_S1756)));
                _S1758 = _S1759;
            }
            else
            {
                _S1758 = (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f;
            }
            if(replay_1)
            {
                _S1579 = _S1480;
            }
            else
            {
                _S1579 = false;
            }
            if(_S1579)
            {
                _S1580 = _S1249 == 1U;
            }
            else
            {
                _S1580 = false;
            }
            if(_S1580)
            {
                _S1581 = _S1758 > 0.0f;
            }
            else
            {
                _S1581 = false;
            }
            if(_S1581)
            {
                ended_0 = _S1245;
                sky_pdf_1 = sky_pdf_2;
                spread_2 = spread_4;
                width_4 = width_3;
                density_3 = density_7;
                throughput_11 = throughput_10;
                b_9 = b_6;
                _S1582 = true;
                break;
            }
            bool _S1760 = (&prev_0)->rough;
            if(_S1760)
            {
                _S1582 = !(_S1758 > 0.0f);
            }
            else
            {
                _S1582 = false;
            }
            (&prev_0)->rough = _S1582;
            uint _S1761 = b_6 + 320U;
            bool _S1762 = b_6 == 4294967295U;
            uint _S1763 = _slang_select(_S1762, 384U,_S1761);
            uint _S1764 = stream(_S1272, _S1763);
            uint tracking_1 = _S1764;
            weight_1 = throughput_3;
            glowed_0 = _S1244;
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
                    _S1243 = int(2);
                    break;
                }
                uint _S1765 = b_9 + 320U;
                bool _S1766 = b_9 == 4294967295U;
                uint _S1767 = _slang_select(_S1766, 384U,_S1765);
                uint _S1768 = stream(_S1272, _S1767);
                Random _S1769 = pcg(_S1768);
                float _S1770 = - (F32_log((1.0f - _S1769.value))) / _S1758;
                if(_S1578)
                {
                    float3  _S1771 = (&ray_2)->origin;
                    float3  _S1772 = (&ray_2)->unit_direction;
                    float _S1773 = (&hit_4)->distance;
                    uint _S1774 = _slang_select(_S1766, 0U,b_9);
                    uint _S1775 = (&prev_0)->lobe;
                    uint _S1776 = _slang_select(_S1766, 3U,_S1775);
                    float _S1777 = (fcptTrackMedium((_S1756), (_S1771), (_S1772), (_S1773), (&tracking_1), (&weight_1), (&glowed_0), (&scatter_in_0), (&extinction_in_0), (&g_in_0), (_S1774), (_S1776), (_S1766)));
                    spread_3 = _S1777;
                }
                else
                {
                    spread_3 = _S1770;
                }
                bool _S1778 = !(spread_3 < ((&hit_4)->distance));
                if(_S1778)
                {
                    _S1243 = int(2);
                    break;
                }
                if(_S1578)
                {
                    _S1583 = _S1453;
                }
                else
                {
                    _S1583 = false;
                }
                if(_S1583)
                {
                    float3  _S1779 = throughput_11 * glowed_0 / make_float3 (density_3);
                    float3  _S1780 = sel_7->glow + _S1779;
                    sel_7->glow = _S1780;
                }
                else
                {
                }
                glowed_0 = _S1244;
                uint b_10 = b_9 + 1U;
                float3  _S1781 = (&ray_2)->origin + make_float3 (spread_3) * (&ray_2)->unit_direction;
                (&ray_2)->origin = _S1781;
                float3  _S1782 = flightWeight_0(scatter_in_0, extinction_in_0, _S1758, spread_3, true);
                float3  _S1783 = weight_1;
                float3  _S1784 = _slang_select(_S1578, _S1783,_S1782);
                float3  throughput_12 = throughput_11 * _S1784;
                uint _S1785 = stream(_S1272, b_10 + 320U);
                tracking_1 = _S1785;
                weight_1 = throughput_3;
                float width_7 = width_4 + spread_2 * spread_3;
                float _S1786 = spread_2 + 3.14159274101257324f;
                if(_S1453)
                {
                    _S1584 = true;
                }
                else
                {
                    bool _S1787 = b_10 == _S1260;
                    if(_S1787)
                    {
                        _S1584 = !_S1578;
                    }
                    else
                    {
                        _S1584 = false;
                    }
                }
                TreeSample light_4;
                if(_S1584)
                {
                    float3  _S1788 = (&ray_2)->origin;
                    float3  _S1789 = (&ray_2)->unit_direction;
                    float3  _S1790 = (&ray_2)->unit_direction;
                    uint _S1791 = stream(_S1272, b_10 + 64U);
                    float3  _S1792 = extinction_in_0;
                    float3  _S1793 = extinction_in_0;
                    uint2  _S1794 = make_uint2 (_S1756);
                    float3  _S1795 = (&ray_2)->unit_direction;
                    uint _S1796 = arrivalLobe_0(b_10, (&prev_0)->lobe);
                    FKHit _S1797 = _S1497;
                    ShadowContext _S1798 = ShadowContext_x24init_0(_S1792, _S1793, _S1794, _S1795, b_10, _S1796, false, spread_3, width_7, &_S1797, false);
                    ShadowContext _S1799 = _S1798;
                    TreeSample _S1800 = sampleLightTree_0(_S1788, _S1789, _S1790, 0.0f, true, _S1791, &_S1799);
                    light_4 = _S1800;
                }
                else
                {
                    light_4 = _S1494;
                }
                float _S1801 = phaseHG_0(g_in_0, dot_0((&ray_2)->unit_direction, light_4.dir));
                uint _S1802 = (fcptMaxBounces());
                bool _S1803 = b_10 < _S1802;
                if(_S1803)
                {
                    _S1585 = (light_4.density) > 0.0f;
                }
                else
                {
                    _S1585 = false;
                }
                float _S1804 = _slang_select(_S1585, _S1801,0.0f);
                float3  _S1805 = throughput_12 * light_4.radiance;
                float _S1806 = powerHeuristic(light_4.density, _S1804);
                float3  _S1807 = _S1805 * make_float3 (_S1801 * _S1806);
                float3  _S1808 = _slang_select(_S1584, _S1807,_S1244);
                if(replay_1)
                {
                    _S1586 = b_10 == _S1260;
                }
                else
                {
                    _S1586 = false;
                }
                if(_S1586)
                {
                    bool _S1809 = _S1249 == 2U;
                    if(_S1809)
                    {
                        float _S1810 = resamplingTarget(_S1808);
                        _S1587 = _S1810 > 0.0f;
                    }
                    else
                    {
                        _S1587 = false;
                    }
                    if(_S1587)
                    {
                        Shift _S1811 = Shift_x24init_0(_S1808, 1.0f);
                        _S1243 = int(1);
                        ended_0 = _S1811;
                        spread_3 = _S1786;
                        width_5 = width_7;
                        throughput_9 = throughput_12;
                        b_7 = b_10;
                        break;
                    }
                    _S1243 = int(1);
                    ended_0 = _S1245;
                    spread_3 = _S1786;
                    width_5 = width_7;
                    throughput_9 = throughput_12;
                    b_7 = b_10;
                    break;
                }
                if(_S1453)
                {
                    Reservoir candidate_9 = _S1755;
                    uint _S1812 = extractBits_0(_S1755.path, 10U, 2U);
                    bool _S1813 = _S1812 == 1U;
                    if(_S1813)
                    {
                        float3  _S1814 = safeDivide(_S1808, chain_throughput_0);
                        (&candidate_9)->radiance = _S1814;
                    }
                    else
                    {
                        uint _S1815 = insertBits_0(0U, b_10 + 1U, 5U, 5U);
                        uint _S1816 = insertBits_0(_S1815, 2U, 10U, 2U);
                        (&candidate_9)->path = _S1816;
                    }
                    Reservoir _S1817 = withEnd(candidate_9, 0U, b_10, _S1808);
                    offer(sel_7, _S1817, _S1808 * make_float3 (scale_3) / make_float3 (density_3));
                    float _S1818 = survivalProbability(abs_0(throughput_12), density_3);
                    uint _S1819 = stream(_S1272, b_10 + 128U);
                    Random _S1820 = pcg(_S1819);
                    bool _S1821 = _S1818 < (_S1820.value);
                    if(_S1821)
                    {
                        _S1587 = true;
                    }
                    else
                    {
                        uint _S1822 = (fcptMaxBounces());
                        _S1587 = b_10 >= _S1822;
                    }
                    if(_S1587)
                    {
                        _S1243 = int(1);
                        ended_0 = _S1245;
                        spread_3 = _S1786;
                        width_5 = width_7;
                        throughput_9 = throughput_12;
                        b_7 = b_10;
                        break;
                    }
                    float _S1823 = density_3 * _S1818;
                    density_3 = _S1823;
                }
                else
                {
                }
                float phase_pdf_1 = 0.0f;
                uint _S1824 = stream(_S1272, b_10);
                float3  _S1825 = samplePhase_0(g_in_0, (&ray_2)->unit_direction, _S1824, &phase_pdf_1);
                (&ray_2)->unit_direction = _S1825;
                NEEVertex _S1826 = NEEVertex_x24init_0(false, phase_pdf_1, (&ray_2)->origin, _S1244, (&ray_2)->origin);
                nee_vertex_0 = _S1826;
                Vertex _S1827 = Vertex_x24init_0(false, 0U, 0.0f, 1.0f, is_inside_5);
                prev_0 = _S1827;
                float _S1828 = (&prev_0)->pdf;
                FKRay _S1829 = ray_2;
                FKHit _S1830 = (fcptTraverseInstanceBVH((_S1829), (true), (4.294967296e+09f), (false), (_S1497), (false)));
                hit_4 = _S1830;
                b_9 = b_10;
                throughput_11 = throughput_12;
                spread_2 = _S1786;
                width_4 = width_7;
                sky_pdf_1 = _S1828;
            }
            if(_S1243 != int(2))
            {
                spread_2 = spread_3;
                width_4 = width_5;
                throughput_11 = throughput_9;
                b_9 = b_7;
                _S1582 = true;
                break;
            }
            ended_0 = _S1245;
            _S1582 = false;
            break;
        }
        if(_S1582)
        {
            return ended_0;
        }
        if(viewed_1)
        {
            _S1583 = b_9 == b_6;
        }
        else
        {
            _S1583 = false;
        }
        bool _S1831 = ((&hit_4)->instance_index) == 4294967295U;
        if(_S1831)
        {
            bool _S1832 = !(&nee_vertex_0)->none;
            float _S1833 = _slang_select(_S1832, sky_pdf_1,0.0f);
            float _S1834 = escapeWeight_0(_S1833, (&ray_2)->unit_direction);
            float3  _S1835 = environment_0((&ray_2)->unit_direction, b_9, (&prev_0)->lobe);
            float3  _S1836 = throughput_11 * _S1835;
            if(replay_1)
            {
                bool _S1837 = b_9 == _S1260;
                if(_S1837)
                {
                    passes_0 = _S1249 == 3U;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    return Shift_x24init_0(_S1836 * make_float3 (_S1834) / make_float3 (r_8->jac), density_3 / r_8->jac);
                }
                if(_S1259)
                {
                    passes_0 = _S1256;
                }
                else
                {
                    passes_0 = false;
                }
                if(passes_0)
                {
                    passes_0 = b_9 == _S1247;
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
                    return Shift_x24init_0(_S1836 * make_float3 (_S1834), 1.0f);
                }
                return _S1245;
            }
            Reservoir candidate_10 = chain_0;
            uint _S1838 = extractBits_0((&chain_0)->path, 10U, 2U);
            bool _S1839 = _S1838 == 1U;
            if(_S1839)
            {
                uint _S1840 = extractBits_0((&chain_0)->path, 5U, 5U);
                bool _S1841 = _S1840 == b_9;
                float _S1842 = _slang_select(_S1841, 1.0f,_S1834);
                float3  _S1843 = safeDivide(_S1836 * make_float3 (_S1842), chain_throughput_0);
                (&candidate_10)->radiance = _S1843;
            }
            else
            {
                bool _S1844 = (&prev_0)->rough;
                if(_S1844)
                {
                    uint _S1845 = insertBits_0(0U, b_9 + 1U, 5U, 5U);
                    uint _S1846 = insertBits_0(_S1845, 3U, 10U, 2U);
                    uint _S1847 = insertBits_0(_S1846, (&prev_0)->lobe, 15U, 3U);
                    bool _S1848 = (&prev_0)->inside;
                    uint _S1849 = _slang_select(_S1848, 1U,0U);
                    uint _S1850 = insertBits_0(_S1847, _S1849, 22U, 1U);
                    (&candidate_10)->path = _S1850;
                    (&candidate_10)->jac = (&prev_0)->pdf;
                    (&candidate_10)->dir = (&ray_2)->unit_direction;
                }
            }
            float3  _S1851 = _S1836 * make_float3 (_S1834);
            Reservoir _S1852 = withEnd(candidate_10, 3U, b_9, _S1851);
            offer(sel_7, _S1852, _S1851 * make_float3 (scale_3) / make_float3 (density_3));
            break;
        }
        float3  _S1853 = (&ray_2)->origin + make_float3 ((&hit_4)->distance) * (&ray_2)->unit_direction;
        (&ray_2)->origin = _S1853;
        bool _S1854 = (fcptVaryingUsed());
        if(_S1854)
        {
            _S1584 = filling_2 != 4294967295U;
        }
        else
        {
            _S1584 = false;
        }
        if(_S1584)
        {
            if(_S1453)
            {
                float3  _S1855 = throughput_11 * glowed_0 / make_float3 (density_3);
                float3  _S1856 = sel_7->glow + _S1855;
                sel_7->glow = _S1856;
            }
            float3  _S1857 = throughput_11 * weight_1;
            throughput_9 = _S1857;
        }
        else
        {
            float3  _S1858 = flightWeight_0(scatter_in_0, extinction_in_0, (scatter_in_0.x + scatter_in_0.y + scatter_in_0.z) / 3.0f, (&hit_4)->distance, false);
            float3  _S1859 = throughput_11 * _S1858;
            throughput_9 = _S1859;
        }
        float _S1860 = width_4 + spread_2 * (&hit_4)->distance;
        viewed_0 = _S1583;
        width_3 = _S1860;
        throughput_2 = throughput_9;
        density_2 = density_3;
        sky_pdf_0 = sky_pdf_1;
        spread_1 = spread_2;
        uint _S1747 = b_9 + 1U;
        b_6 = _S1747;
        layer_0 = _S1746;
    }
    return _S1245;
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
        *_slang_vector_get_element_ptr(&result_15, i_27) = (F32_tan((_slang_vector_get_element(x_27, i_27))));
        i_27 = i_27 + int(1);
    }
    return result_15;
}

static __device__ float3  acos_0(float3  x_28)
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
        *_slang_vector_get_element_ptr(&result_16, i_28) = (F32_acos((_slang_vector_get_element(x_28, i_28))));
        i_28 = i_28 + int(1);
    }
    return result_16;
}

__device__ Random normal_distribution(uint state_3)
{
    Random _S1861 = pcg(state_3);
    Random _S1862 = pcg(_S1861.state);
    float _S1863 = 6.28318548202514648f * _S1861.value;
    float _S1864 = (F32_sqrt((-2.0f * clamp_1((F32_log((_S1862.value))), -8.388607e+06f, 0.0f))));
    return Random_x24init_0(_S1862.state, _S1864 * (F32_cos((_S1863))));
}

struct RandomSphere
{
    uint state;
    float3  value;
};

static __device__ RandomSphere RandomSphere_x24init_0(uint state_4, float3  value_2)
{
    RandomSphere _S1865;
    (&_S1865)->state = state_4;
    (&_S1865)->value = value_2;
    return _S1865;
}

__device__ RandomSphere random_sphere(uint state_5)
{
    Random _S1866 = normal_distribution(state_5);
    Random _S1867 = normal_distribution(_S1866.state);
    Random _S1868 = normal_distribution(_S1867.state);
    float3  _S1869 = make_float3 (_S1866.value, _S1867.value, _S1868.value);
    float3  _S1870 = ((((_S1869)) * make_float3(rnorm3df(((_S1869)).x, ((_S1869)).y, ((_S1869)).z))));
    return RandomSphere_x24init_0(_S1868.state, _S1870);
}

__device__ Matrix<float, 3, 3>  normalMapTBN(float3  p0_0, float3  p1_0, float3  p2_0, float2  uv0_0, float2  uv1_0, float2  uv2_0, float3  n_12)
{
    float3  _S1871 = p1_0 - p0_0;
    float3  _S1872 = p2_0 - p0_0;
    float2  _S1873 = uv1_0 - uv0_0;
    float2  _S1874 = uv2_0 - uv0_0;
    float _S1875 = _S1873.x;
    float _S1876 = _S1874.y;
    float _S1877 = _S1873.y;
    float _S1878 = _S1874.x;
    float _S1879 = _S1875 * _S1876 - _S1877 * _S1878;
    float _S1880 = 1.0f / _S1879;
    float3  t_24 = (_S1871 * make_float3 (_S1876) - _S1872 * make_float3 (_S1877)) * make_float3 (_S1880);
    float3  _S1881 = (_S1872 * make_float3 (_S1875) - _S1871 * make_float3 (_S1878)) * make_float3 (_S1880);
    float3  _S1882 = t_24 - n_12 * make_float3 (dot_0(n_12, t_24));
    float3  _S1883 = tangentToWorld(make_float3 (1.0f, 0.0f, 0.0f), n_12);
    bool _S1884 = (dot_0(_S1882, _S1882)) > 0.0f;
    float3  _S1885 = _slang_select(_S1884, _S1882,_S1883);
    float3  _S1886 = ((((_S1885)) * make_float3(rnorm3df(((_S1885)).x, ((_S1885)).y, ((_S1885)).z))));
    bool _S1887 = (dot_0(cross_0(n_12, _S1886), _S1881)) > 0.0f;
    float3  t_25;
    if(_S1887)
    {
        float3  _S1888 = negate_0(_S1886);
        t_25 = _S1888;
    }
    else
    {
        t_25 = _S1886;
    }
    float3  _S1889 = cross_0(n_12, t_25);
    return makeMatrix<float, 3, 3> (t_25, _S1889, n_12);
}

__device__ float3  tangentToWorldNormalMap(float3  v_10, Matrix<float, 3, 3>  tbn_0)
{
    return mul_0(v_10, tbn_0);
}

__device__ float geometryOffset(float3  t0_0, float3  t1_0, float3  t2_2, float3  n0_0, float3  n1_0, float3  n2_0, float3  geometry_n_4, float3  uvw_0, float3  position_1)
{
    float3  _S1890 = t1_0 - t0_0;
    float3  _S1891 = t2_2 - t0_0;
    float3  _S1892 = t2_2 - t1_0;
    float _S1893 = (F32_min((length_0(_S1890)), ((F32_min((length_0(_S1891)), (length_0(_S1892)))))));
    float3  _S1894 = make_float3 (distance_1(position_1, t0_0), distance_1(position_1, t1_0), distance_1(position_1, t2_2));
    float3  _S1895 = ((((n0_0)) * make_float3(rnorm3df(((n0_0)).x, ((n0_0)).y, ((n0_0)).z))));
    float _S1896 = dot_0(geometry_n_4, _S1895);
    float3  _S1897 = ((((n1_0)) * make_float3(rnorm3df(((n1_0)).x, ((n1_0)).y, ((n1_0)).z))));
    float _S1898 = dot_0(geometry_n_4, _S1897);
    float3  _S1899 = ((((n2_0)) * make_float3(rnorm3df(((n2_0)).x, ((n2_0)).y, ((n2_0)).z))));
    float3  _S1900 = acos_0(abs_0(make_float3 (_S1896, _S1898, dot_0(geometry_n_4, _S1899))));
    float3  _S1901 = clamp_2(tan_0(_S1900), make_float3 (0.0f), make_float3 (0.78539818525314331f));
    return clamp_1(dot_0(_S1894 * _S1901, uvw_0), 0.0f, _S1893 * 0.125f);
}

__device__ float3  straightThrough(BSDFMaterial material_21)
{
    return make_float3 (material_21.transmission * (1.0f - material_21.metallic)) * material_21.albedo;
}

__device__ float hairRow(float3  in_dir_10, float3  t_26, float3  out_dir_3, uint p_15, float w_19, float alpha_10, uint nt_0)
{
    uint _S1902 = p_15 % 4U;
    float _S1903 = w_19 * HAIR_WIDTHS_0[_S1902];
    float _S1904 = (F32_asin((clamp_1(dot_0(out_dir_3, t_26), -1.0f, 1.0f)))) - (F32_asin((clamp_1(dot_0(in_dir_10, t_26), -1.0f, 1.0f)))) - HAIR_TILTS_0[_S1902] * alpha_10;
    return ((F32_asinh((_S1904 / _S1903))) / (F32_asinh((3.14159274101257324f / _S1903))) + 1.0f) * 0.5f * float(nt_0);
}

__device__ float hairColumn(float3  in_dir_11, float3  t_27, float3  out_dir_4, uint np_0)
{
    float3  _S1905 = worldToTangent(out_dir_4, t_27);
    float3  _S1906 = worldToTangent(in_dir_11, t_27);
    return (F32_frac((((F32_atan2((_S1905.z), (_S1905.x + 1.17549435082228751e-38f))) - (F32_atan2((- _S1906.z), (1.17549435082228751e-38f - _S1906.x)))) / 6.28318548202514648f + 0.5f))) * float(np_0);
}

__device__ float3  hairDirection(float3  in_dir_12, float3  t_28, uint p_16, float row_0, float column_0, float w_20, float alpha_11, uint nt_1, uint np_1)
{
    float3  _S1907 = worldToTangent(in_dir_12, t_28);
    uint _S1908 = p_16 % 4U;
    float _S1909 = w_20 * HAIR_WIDTHS_0[_S1908];
    float _S1910 = (F32_asin((clamp_1(dot_0(in_dir_12, t_28), -1.0f, 1.0f)))) + HAIR_TILTS_0[_S1908] * alpha_11 + _S1909 * (F32_sinh(((row_0 * 2.0f / float(nt_1) - 1.0f) * (F32_asinh((3.14159274101257324f / _S1909))))));
    float _S1911 = column_0 * 2.0f * 3.14159274101257324f / float(np_1) - 3.14159274101257324f + (F32_atan2((- _S1907.z), (1.17549435082228751e-38f - _S1907.x)));
    float _S1912 = (F32_cos((_S1910)));
    float3  _S1913 = tangentToWorld(make_float3 (_S1912 * (F32_cos((_S1911))), (F32_sin((_S1910))), _S1912 * (F32_sin((_S1911)))), t_28);
    return _S1913;
}

__device__ float3  occluderTransmittance(float3  toward_1, float3  n_13, BSDFMaterial material_22, float coverage_1)
{
    float3  _S1914;
    if((material_22.ior) == 1.0f)
    {
        float3  _S1915 = straightThrough(material_22);
        _S1914 = _S1915;
    }
    else
    {
        _S1914 = make_float3 (0.0f);
    }
    return _S1914 * make_float3 (coverage_1) + make_float3 (1.0f - coverage_1);
}

__device__ Shift walk_hook(Domain dom_8, Reservoir r_9, bool replay_2, float scale_4, Selection * sel_8)
{
    Domain _S1916 = dom_8;
    Reservoir _S1917 = r_9;
    Shift _S1918 = walk_0(&_S1916, &_S1917, replay_2, scale_4, sel_8);
    return _S1918;
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
